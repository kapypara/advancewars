//! Low-ROM (`< 0x08080000`) branching, main loop, and tail-call dispatchers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const clusters_low = @import("clusters_low.zig");
const clusters_low_2 = @import("clusters_low_2.zig");
const hw = @import("hw.zig");
const low_peel_1 = @import("low_peel_1.zig");
const low_peel_10 = @import("low_peel_10.zig");
const low_peel_12 = @import("low_peel_12.zig");
const low_peel_13 = @import("low_peel_13.zig");
const low_peel_14 = @import("low_peel_14.zig");
const low_peel_17 = @import("low_peel_17.zig");
const low_peel_19 = @import("low_peel_19.zig");
const low_peel_2 = @import("low_peel_2.zig");
const low_peel_3 = @import("low_peel_3.zig");
const low_peel_5 = @import("low_peel_5.zig");
const low_peel_6 = @import("low_peel_6.zig");
const low_peel_7 = @import("low_peel_7.zig");
const low_peel_8 = @import("low_peel_8.zig");
const low_peel_9 = @import("low_peel_9.zig");
const math = @import("math.zig");
const menu = @import("menu.zig");
const sprite_anim = @import("sprite_anim.zig");
const ui = @import("ui.zig");

/// Typed cross-module bridge calling indirect branch trampoline `__call_via_r4` (`func_0807B45C`).
pub inline fn callViaR4Call(comptime ret_addr: u32) bool {
    return abi.call(func_0807B45C, ret_addr);
}

fn bxReg(addr: u32, comptime reg: u5) void {
    if (!abi.enter(addr)) return;
    abi.fetches(3);
    decls.awre_cpu_bx(rt.r[reg]);
}

fn tailCall0(addr: u32, comptime target: fn () callconv(.c) void) void {
    if (!abi.enter(addr)) return;
    abi.fetches(3);
    target();
}

fn pushRegs(comptime regs: []const u5) void {
    inline for (0..regs.len) |i| {
        const idx = regs[regs.len - 1 - i];
        rt.r[13] -%= 4;
        abi.write32(rt.r[13], rt.r[idx]);
    }
}

fn popRegsSeq(comptime regs: []const u5) void {
    inline for (regs, 0..) |idx, i| {
        rt.r[idx] = if (i == 0) rt.bus_read32(rt.r[13]) else rt.bus_read32s(rt.r[13]);
        rt.r[13] +%= 4;
    }
}

fn writeUnpackFieldByte(addr: u32, lr: u32, comptime field_off: u32) void {
    if (!abi.enter(addr)) return;
    abi.fetches(5);
    rt.r[12] = rt.r[14];
    if (!abi.call(low_peel_2.func_08077A74, lr)) return;
    abi.fetches(4);
    abi.write8(rt.r[1] +% field_off, @truncate(rt.r[3]));
    decls.awre_cpu_bx(rt.r[12]);
}

fn writeUnpackFlagsByte(
    addr: u32,
    lr: u32,
    comptime sub40: bool,
    comptime field_off: u32,
    comptime flag_mask: u32,
) void {
    if (!abi.enter(addr)) return;
    abi.fetches(5);
    rt.r[12] = rt.r[14];
    if (!abi.call(low_peel_2.func_08077A74, lr)) return;
    abi.fetches(if (sub40) @as(u32, 9) else 8);
    if (sub40) rt.cpuSub(&rt.r[3], rt.r[3], 0x40, true);
    abi.write8(rt.r[1] +% field_off, @truncate(rt.r[3]));
    const cur = abi.read8(rt.r[1]);
    abi.setRegNz(&rt.r[2], flag_mask);
    abi.setRegNz(&rt.r[3], cur | flag_mask);
    abi.write8(rt.r[1], @truncate(rt.r[3]));
    decls.awre_cpu_bx(rt.r[12]);
}

fn callCheckJumpTarget(comptime target: fn () callconv(.c) void, lr: u32, jump_pc: u32) enum { next, jumped, ret } {
    rt.r[14] = lr;
    rt.g_ret = 0;
    target();
    if (((rt.g_ret ^ jump_pc) & ~@as(u32, 1)) == 0) {
        rt.g_ret = 0;
        return .jumped;
    }
    if (!rt.recompCalled(lr)) return .ret;
    return .next;
}

pub fn func_0800F8FA() callconv(.c) void { bxReg(0x0800F8FA, 0); }
pub fn func_0800FCF8() callconv(.c) void { bxReg(0x0800FCF8, 0); }
pub fn func_08010970() callconv(.c) void { bxReg(0x08010970, 0); }
pub fn func_0801FFFC() callconv(.c) void { bxReg(0x0801FFFC, 0); }
pub fn func_0802F9FC() callconv(.c) void { bxReg(0x0802F9FC, 0); }
pub fn func_08030004() callconv(.c) void { bxReg(0x08030004, 1); }
pub fn func_0803008C() callconv(.c) void { bxReg(0x0803008C, 0); }
pub fn func_0803FCF6() callconv(.c) void { bxReg(0x0803FCF6, 0); }
pub fn func_0803FD02() callconv(.c) void { bxReg(0x0803FD02, 0); }
pub fn func_0803FD1A() callconv(.c) void { bxReg(0x0803FD1A, 0); }
pub fn func_0804FA04() callconv(.c) void { bxReg(0x0804FA04, 0); }
pub fn func_080779D2() callconv(.c) void { bxReg(0x080779D2, 3); }
pub fn func_08077EA0() callconv(.c) void { bxReg(0x08077EA0, 3); }
/// GCC `__call_via_r0`..`__call_via_ip` indirect branch trampolines (`func_0807B44C` accounts for ~32.6% of dynamic calls).
pub fn func_0807B44C() callconv(.c) void { bxReg(0x0807B44C, 0); }
pub fn func_0807B450() callconv(.c) void { bxReg(0x0807B450, 1); }
pub fn func_0807B454() callconv(.c) void { bxReg(0x0807B454, 2); }
pub fn func_0807B458() callconv(.c) void { bxReg(0x0807B458, 3); }
pub fn func_0807B45C() callconv(.c) void { bxReg(0x0807B45C, 4); }
pub fn func_0807B460() callconv(.c) void { bxReg(0x0807B460, 5); }
pub fn func_0807B464() callconv(.c) void { bxReg(0x0807B464, 6); }
pub fn func_0807B46C() callconv(.c) void { bxReg(0x0807B46C, 8); }
pub fn func_0807B47C() callconv(.c) void { bxReg(0x0807B47C, 12); }

pub fn func_080385C8() callconv(.c) void {
    if (!abi.enter(0x080385C8)) return;
    while (true) {
        abi.fetches(3);
    }
}

pub fn func_080796A4() callconv(.c) void { tailCall0(0x080796A4, clusters_low.func_080796A8); }
pub fn func_080796AC() callconv(.c) void { tailCall0(0x080796AC, clusters_low.func_080796B0); }
pub fn func_080796B4() callconv(.c) void { tailCall0(0x080796B4, clusters_low.func_080796B8); }

pub fn func_080775A0() callconv(.c) void {
    if (!abi.enter(0x080775A0)) return;
    abi.fetches(4);
    rt.r[2] = 0x080775A4;
    decls.awre_cpu_bx(0x080775A4);
}

pub fn func_0800F2C2() callconv(.c) void {
    if (!abi.enter(0x0800F2C2)) return;
    abi.fetches(3);
    rt.updateNz(rt.r[0]);
    low_peel_6.func_0800F2C4();
}

pub fn func_0800F7F6() callconv(.c) void {
    if (!abi.enter(0x0800F7F6)) return;
    abi.fetches(3);
    abi.setRegNz(&rt.r[0], rt.r[0] << 12);
    low_peel_3.func_0800F7F8();
}

pub fn func_08020704() callconv(.c) void {
    if (!abi.enter(0x08020704)) return;
    abi.fetches(5);
    _ = abi.read8(rt.r[1] +% rt.r[5]);
    abi.setRegNz(&rt.r[0], 0);
}

pub fn func_0803E9EE() callconv(.c) void {
    if (!abi.enter(0x0803E9EE)) return;
    abi.fetches(3);
    rt.updateNz(rt.r[0]);
    low_peel_8.func_0803E9F0();
}

pub fn func_0804F7FE() callconv(.c) void {
    if (!abi.enter(0x0804F7FE)) return;
    abi.fetches(3);
    abi.setRegNz(&rt.r[0], 0);
    ui.func_0804F800();
}

pub fn func_08060706() callconv(.c) void {
    if (!abi.enter(0x08060706)) return;
    abi.fetches(3);
    abi.setRegNz(&rt.r[0], rt.r[0] << 12);
    low_peel_12.func_08060708();
}

pub fn func_0806F426() callconv(.c) void {
    if (!abi.enter(0x0806F426)) return;
    abi.fetches(3);
    rt.updateNz(rt.r[0]);
    ui.func_0806F428();
}

pub fn func_080702FA() callconv(.c) void {
    if (!abi.enter(0x080702FA)) return;
    abi.fetches(3);
    abi.setRegNz(&rt.r[3], 0);
    hw.func_080702FC();
}

pub fn func_0806F2F4() callconv(.c) void {
    if (!abi.enter(0x0806F2F4)) return;
    abi.fetches(4);
    abi.write32(rt.r[13] +% 0x230, rt.r[1]);
    abi.setRegNz(&rt.r[3], 0);
    low_peel_17.func_0806F2F8();
}

pub fn func_080055A8() callconv(.c) void {
    if (!abi.enter(0x080055A8)) return;
    abi.fetches(4);
    rt.updateNz(rt.r[1] << 14);
    abi.setRegNz(&rt.r[0], 0);
    low_peel_10.func_080055AC();
}

pub fn func_0800FC10() callconv(.c) void {
    if (!abi.enter(0x0800FC10)) return;
    abi.fetches(6);
    rt.cpuAdd(&rt.r[3], rt.r[3], 0x90, true);
    rt.r[0] <<= 12;
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x90, true);
    abi.setRegNz(&rt.r[0], rt.r[0] << 12);
    low_peel_6.func_0800FC18();
}

pub fn func_08011636() callconv(.c) void {
    if (!abi.enter(0x08011636)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], rt.r[0] << 12);
    abi.setRegNz(&rt.r[4], rt.r[2] << 19);
    abi.setRegNz(&rt.r[1], rt.r[0] << 8);
    low_peel_3.func_0801163C();
}

pub fn func_08060A16() callconv(.c) void {
    if (!abi.enter(0x08060A16)) return;
    abi.fetches(7);
    abi.write32(rt.r[7] +% rt.r[6], rt.r[0]);
    abi.setRegNz(&rt.r[0], rt.r[0] << 12);
}

pub fn func_0800EE12() callconv(.c) void {
    if (!abi.enter(0x0800EE12)) return;
    abi.fetches(7);
    rt.r[10] = 0;
    abi.setRegNz(&rt.r[2], rt.r[4] >> 8);
    abi.setRegNz(&rt.r[0], 0);
    low_peel_3.func_0800EE1C();
}

pub fn func_0801BCB4() callconv(.c) void {
    if (!abi.enter(0x0801BCB4)) return;
    abi.fetches(8);
    rt.r[13] -%= 8;
    abi.write32(rt.r[13], rt.r[12]);
    abi.write32(rt.r[13] +% 4, rt.r[14]);
    rt.r[15] = 0x0801BCC0;
    rt.r[14] = 0x0801BCC0;
    rt.g_ret = 0;
    decls.awre_cpu_bx(rt.r[0]);
    _ = rt.recompCalled(0x0801BCC0);
}

pub fn func_08077B00() callconv(.c) void { writeUnpackFieldByte(0x08077B00, 0x08077B07, 0x1D); }
pub fn func_08077BB4() callconv(.c) void { writeUnpackFieldByte(0x08077BB4, 0x08077BBB, 0x1B); }

pub fn func_080796F0() callconv(.c) void {
    if (!abi.enter(0x080796F0)) return;
    abi.fetches(8);
    rt.r[3] = abi.read32(0x08079700);
    abi.setRegNz(&rt.r[2], 0);
    abi.write8(rt.r[3], 0);
    rt.r[1] = abi.read32(0x08079704);
    rt.r[13] = rt.r[1];
    abi.swi(0x01);
    abi.fetches(3);
    abi.swi(0x00);
}

pub fn func_0800F710() callconv(.c) void {
    if (!abi.enter(0x0800F710)) return;
    abi.fetches(8);
    abi.setRegNz(&rt.r[4], rt.r[0] >> 19);
    rt.r[0] = (rt.r[2] >> 24) << 12;
    rt.cpuAdd(&rt.r[3], rt.r[3], 0x88, true);
    abi.setRegNz(&rt.r[0], rt.r[0] << 12);
    menu.func_0800F71C();
}

pub fn func_0805F70E() callconv(.c) void {
    if (!abi.enter(0x0805F70E)) return;
    abi.fetches(9);
    rt.cpuSub(null, rt.r[4], 0xB8, true);
    rt.cpuAdd(&rt.r[6], rt.r[6], 0, true);
    rt.r[0] = abi.read8(rt.r[6] +% 0x17);
    abi.setRegNz(&rt.r[3], 0);
    low_peel_12.func_0805F71C();
}

pub fn func_08033374() callconv(.c) void {
    if (!abi.enter(0x08033374)) return;
    abi.fetches(10);
    rt.cpuSub(null, rt.r[4], 0xB8, true);
    rt.r[4] +%= rt.r[12];
    rt.cpuSub(null, rt.r[3], 0x40, true);
    rt.r[1] = 0;
    rt.cpuSub(&rt.r[0], rt.r[2], rt.r[2], true);
    abi.setRegNz(&rt.r[0], 0);
    ui.func_08033384();
}

pub fn func_08077B20() callconv(.c) void { writeUnpackFlagsByte(0x08077B20, 0x08077B27, false, 0xA, 0xC); }
pub fn func_08077B64() callconv(.c) void { writeUnpackFlagsByte(0x08077B64, 0x08077B6B, false, 0x12, 0x3); }
pub fn func_08077BA0() callconv(.c) void { writeUnpackFlagsByte(0x08077BA0, 0x08077BA7, false, 0xF, 0xC); }

pub fn func_0800BBEC() callconv(.c) void {
    if (!abi.enter(0x0800BBEC)) return;
    abi.fetches(10);
    abi.setRegNz(&rt.r[1], (rt.r[6] << 2) << 8);
    rt.cpuSub(null, rt.r[4], 0xB4, true);
    rt.r[10] = 0;
    abi.setRegNz(&rt.r[2], rt.r[4] >> 8);
    abi.setRegNz(&rt.r[0], 0);
    low_peel_10.func_0800BBFC();
}

pub fn func_0802FDF8() callconv(.c) void {
    if (!abi.enter(0x0802FDF8)) return;
    abi.fetches(10);
    rt.cpuAdd(&rt.r[0], rt.r[1], 5, true);
    abi.setRegNz(&rt.r[4], rt.r[7] >> 22);
    rt.cpuAdd(&rt.r[0], rt.r[3], 4, true);
    abi.setRegNz(&rt.r[0], rt.r[0] << 12);
    low_peel_7.func_0802FE08();
}

pub fn func_08061114() callconv(.c) void {
    if (!abi.enter(0x08061114)) return;
    abi.fetches(13);
    rt.cpuAdd(&rt.r[6], rt.r[6], 0, true);
    const rot = rt.ror32(rt.r[0] << 12, rt.r[5] & 0xFF) << 12;
    abi.write32(rt.r[4] +% rt.r[5], rot);
    const val = rot << 12;
    rt.r[10] = val;
    rt.cpuSub(null, rt.r[4], 0xB8, true);
    abi.setRegNz(&rt.r[0], 0);
}

pub fn func_08077B78() callconv(.c) void { writeUnpackFlagsByte(0x08077B78, 0x08077B7F, true, 0x14, 0x3); }
pub fn func_08077B8C() callconv(.c) void { writeUnpackFlagsByte(0x08077B8C, 0x08077B93, true, 0xE, 0xC); }
pub fn func_08077BD8() callconv(.c) void { writeUnpackFlagsByte(0x08077BD8, 0x08077BDF, true, 0xC, 0xC); }

pub fn func_08077BEC() callconv(.c) void {
    if (!abi.enter(0x08077BEC)) return;
    abi.fetches(10);
    rt.r[12] = rt.r[14];
    var p = abi.read32(rt.r[1] +% 0x40);
    const idx: u32 = abi.read8(p);
    rt.r[3] = idx;
    rt.cpuAdd(&p, p, 1, true);
    rt.r[2] = p;
    abi.write32(rt.r[1] +% 0x40, p);
    rt.cpuAdd(&rt.r[0], abi.read32(0x08077C00), idx, true);
    if (!abi.call(low_peel_2.func_08077A76, 0x08077BFD)) return;
    abi.fetches(4);
    abi.write8(rt.r[0], @truncate(rt.r[3]));
    decls.awre_cpu_bx(rt.r[12]);
}

pub fn func_08077B0C() callconv(.c) void {
    if (!abi.enter(0x08077B0C)) return;
    abi.fetches(5);
    rt.r[12] = rt.r[14];
    if (!abi.call(low_peel_2.func_08077A74, 0x08077B13)) return;
    abi.fetches(9);
    const val = rt.r[3] << 1;
    abi.write16(rt.r[0] +% 0x1C, @truncate(val));
    rt.r[2] = abi.read16(rt.r[0] +% 0x1E);
    var prod = val *% rt.r[2];
    rt.updateNz(prod);
    prod >>= 8;
    abi.setRegNz(&rt.r[3], prod);
    abi.write16(rt.r[0] +% 0x20, @truncate(prod));
    decls.awre_cpu_bx(rt.r[12]);
}

pub fn func_08077A40() callconv(.c) void {
    if (!abi.enter(0x08077A40)) return;
    abi.fetches(5);
    rt.r[12] = rt.r[14];
    abi.setRegNz(&rt.r[1], 0x24);
    rt.r[2] = abi.read32(0x08077A70);
    while (true) {
        abi.fetches(5);
        rt.r[3] = abi.read32(rt.r[2]);
        if (!abi.call(func_08077A5A, 0x08077A4D)) return;
        abi.fetches(6);
        abi.write32(rt.r[0], rt.r[3]);
        rt.r[0] +%= 4;
        rt.cpuAdd(&rt.r[2], rt.r[2], 4, true);
        rt.cpuSub(&rt.r[1], rt.r[1], 1, true);
        if (!(!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) break;
    }
    abi.fetches(3);
    decls.awre_cpu_bx(rt.r[12]);
}

pub fn func_0807C49E() callconv(.c) void {
    if (!abi.enter(0x0807C49E)) return;
    abi.fetches(15);
    pushRegs(&.{ 4, 14 });
    rt.r[13] -%= 0x14;
    abi.write32(rt.r[13] +% 0x1C, rt.r[3]);
    rt.r[3] = abi.read32(rt.r[13] +% 0x1C);
    rt.r[4] = abi.read32(rt.r[13] +% 0x20);
    abi.write32(rt.r[13] +% 0x0, rt.r[0]);
    abi.write32(rt.r[13] +% 0x4, rt.r[1]);
    abi.write32(rt.r[13] +% 0x8, rt.r[2]);
    abi.write32(rt.r[13] +% 0xC, rt.r[3]);
    abi.write32(rt.r[13] +% 0x10, rt.r[4]);
    rt.r[0] = rt.r[13];
    if (!abi.call(low_peel_13.func_0807B76C, 0x0807C4B9)) return;
    abi.fetches(7);
    rt.r[13] +%= 0x14;
    popRegsSeq(&.{4});
    rt.r[3] = abi.popReg();
    rt.r[13] +%= 4;
    decls.awre_cpu_bx(rt.r[3]);
}

pub fn func_08077A5A() callconv(.c) void {
    if (!abi.enter(0x08077A5A)) return;
    abi.fetches(5);
    pushRegs(&.{0});
    abi.setRegNz(&rt.r[0], rt.r[2] >> 25);
    if (rt.CPU_Z) {
        abi.fetches(5);
        rt.r[0] = abi.read32(0x08077A70);
        rt.cpuSub(null, rt.r[2], rt.r[0], true);
        if (!rt.CPU_C) {
            abi.fetches(3);
            abi.setRegNz(&rt.r[3], 0);
        } else {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[2] >> 14);
            if (!rt.CPU_Z) {
                abi.fetches(3);
                abi.setRegNz(&rt.r[3], 0);
            }
        }
    }
    abi.fetches(4);
    rt.r[0] = abi.popReg();
    rt.recompReturn(rt.r[14]);
}

pub fn func_08077B34() callconv(.c) void {
    if (!abi.enter(0x08077B34)) return;
    abi.fetches(15);
    rt.r[12] = rt.r[14];
    var cur = abi.read32(rt.r[1] +% 0x40);
    const idx: u32 = abi.read8(cur);
    rt.cpuAdd(&cur, cur, 1, true);
    abi.write32(rt.r[1] +% 0x40, cur);
    var off = (idx << 1) +% idx;
    rt.updateNz(idx << 1);
    off <<= 2;
    const base = abi.read32(rt.r[0] +% 0x30);
    rt.cpuAdd(&rt.r[2], off, base, true);

    inline for (.{
        .{ 0x0, 0x24, @as(u32, 0x08077B4F) },
        .{ 0x4, 0x28, @as(u32, 0x08077B57) },
        .{ 0x8, 0x2C, @as(u32, 0x08077B5F) },
    }) |step| {
        rt.r[3] = abi.read32(rt.r[2] +% step[0]);
        if (!abi.call(func_08077A5A, step[2])) return;
        abi.fetches(if (step[0] == 0x8) @as(u32, 4) else 6);
        abi.write32(rt.r[1] +% step[1], rt.r[3]);
    }
    decls.awre_cpu_bx(rt.r[12]);
}

pub fn func_08059DD4() callconv(.c) void {
    if (!abi.enter(0x08059DD4)) return;
    abi.fetches(5);
    abi.pushLr();
    const init_seq = .{
        .{ &low_peel_5.func_0807B434, @as(u32, 0x08059DDB) },
        .{ &hw.func_08010544, @as(u32, 0x08059DDF) },
        .{ &low_peel_6.func_08010574, @as(u32, 0x08059DE3) },
        .{ &clusters_low_2.func_0800FD54, @as(u32, 0x08059DE7) },
        .{ &clusters_low_2.func_080130A0, @as(u32, 0x08059DEB) },
    };
    inline for (init_seq) |s| {
        if (!abi.call(s[0].*, s[1])) return;
        abi.fetches(if (s[1] == 0x08059DEB) @as(u32, 6) else 4);
    }
    rt.r[0] = abi.read32(0x08059E10);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(low_peel_3.func_080131E0, 0x08059DF3)) return;
    abi.fetches(4);

    while (true) {
        const frame_seq = .{
            .{ &sprite_anim.func_08014B3C, @as(u32, 0x08059DF7) },
            .{ &low_peel_6.func_080138F8, @as(u32, 0x08059DFB) },
            .{ &low_peel_6.func_0801A0A8, @as(u32, 0x08059DFF) },
            .{ &low_peel_9.func_0807AD88, @as(u32, 0x08059E03) },
            .{ &low_peel_14.func_08010144, @as(u32, 0x08059E07) },
            .{ &low_peel_6.func_08010574, @as(u32, 0x08059E0B) },
            .{ &low_peel_3.func_0801A06C, @as(u32, 0x08059E0F) },
        };
        inline for (frame_seq) |s| {
            if (!abi.call(s[0].*, s[1])) return;
            abi.fetches(if (s[1] == 0x08059E0F) @as(u32, 3) else 4);
        }
    }
}

pub fn func_0800020C() callconv(.c) void {
    if (!abi.enter(0x0800020C)) return;
    abi.fetches(8);
    abi.pushLr();
    const mode = abi.read16(abi.read32(abi.read32(0x08000224)) +% 4);
    rt.r[0] = mode;
    rt.cpuSub(null, mode, 9, true);
    if (!(rt.CPU_C and !rt.CPU_Z)) {
        abi.fetches(7);
        abi.setRegNz(&rt.r[0], mode << 2);
        rt.r[1] = abi.read32(0x08000228);
        rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
        const target = abi.read32(rt.r[0]);
        rt.r[0] = target;
        switch (target & ~@as(u32, 1)) {
            0x08000254 => {
                abi.fetches(4);
                if (!abi.call(low_peel_6.func_0800028C, 0x08000259)) return;
                abi.fetches(3);
            },
            0x0800025A => {
                abi.fetches(4);
                if (!abi.call(low_peel_19.func_080004BC, 0x0800025F)) return;
                abi.fetches(3);
            },
            0x08000260 => {
                abi.fetches(4);
                if (!abi.call(low_peel_19.func_08005D44, 0x08000265)) return;
                abi.fetches(3);
            },
            0x08000266 => {
                abi.fetches(4);
                if (!abi.call(low_peel_10.func_080049EC, 0x0800026B)) return;
                abi.fetches(3);
            },
            0x0800026C => {
                abi.fetches(4);
                if (!abi.call(low_peel_14.func_08000340, 0x08000271)) return;
                abi.fetches(3);
            },
            0x08000272 => {
                abi.fetches(4);
                if (!abi.call(low_peel_1.func_080002E0, 0x08000277)) return;
                abi.fetches(3);
            },
            0x08000278 => {
                abi.fetches(4);
                if (!abi.call(low_peel_6.func_080002F4, 0x0800027D)) return;
            },
            0x0800027C => {},
            else => {
                decls.awre_cpu_bx(target | 1);
                return;
            },
        }
    }
    abi.fetches(4);
    const lr = abi.popReg();
    rt.r[0] = lr;
    rt.r[15] = lr;
    rt.recompReturn(lr);
}

pub fn func_080642C8() callconv(.c) void {
    if (!abi.enter(0x080642C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            const flag = abi.read8(abi.read32(0x080642E8));
            rt.r[0] = flag;
            rt.cpuAdd(&rt.r[1], flag, 0, true);
            rt.cpuSub(null, rt.r[1], 0, true);
            continue :blk if (rt.CPU_Z) @as(u32, 2) else 1;
        },
        1 => {
            abi.fetches(3);
            continue :blk 24;
        },
        2 => {
            abi.fetches(7);
            rt.r[6] = abi.read32(0x080642EC);
            rt.r[3] = abi.read32(rt.r[6]);
            rt.r[0] = abi.read8(rt.r[3]);
            rt.cpuSub(null, rt.r[0], 0, true);
            continue :blk if (!rt.CPU_Z) @as(u32, 4) else 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080642F0);
            abi.setRegNz(&rt.r[0], 1);
            continue :blk 23;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[3]);
            rt.cpuSub(null, rt.r[0], 0x40, true);
            continue :blk if (rt.CPU_Z) @as(u32, 12) else 5;
        },
        5 => {
            abi.fetches(29);
            const p_unit = abi.read32(0x0806433C);
            const opcode: u32 = abi.read8(rt.r[3]);
            abi.write8(p_unit, @truncate(opcode));
            rt.r[5] = abi.read32(0x08064340);
            const p_base = abi.read32(0x08064344);
            var row_off = ((opcode << 1) +% @as(u32, abi.read8(p_unit)));
            rt.updateNz(opcode << 1);
            row_off <<= 2;
            const list_base = abi.read32(p_base);
            rt.cpuAdd(&rt.r[4], list_base, row_off, true);
            abi.write32(rt.r[5], rt.r[4]);

            const p_rec_ptr = abi.read32(0x08064348);
            const p_rec_tbl = abi.read32(0x0806434C);
            const unit_id: u32 = abi.read8(rt.r[4]);
            rt.r[7] = unit_id;
            var u_off = ((unit_id << 1) +% unit_id) << 2;
            rt.updateNz(unit_id << 1);
            rt.cpuAdd(&u_off, u_off, 4, true);
            var rec_addr: u32 = undefined;
            rt.cpuAdd(&rec_addr, abi.read32(p_rec_tbl), u_off, true);
            rt.r[1] = rec_addr;
            rt.r[2] = p_rec_ptr;
            abi.write32(p_rec_ptr, rec_addr);

            rt.r[1] = abi.read8(rt.r[4] +% 1);
            abi.setRegNz(&rt.r[0], 1 & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0, true);
            continue :blk if (!rt.CPU_Z) @as(u32, 7) else 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4]);
            rt.cpuSub(null, rt.r[0], 0, true);
            continue :blk if (!rt.CPU_Z) @as(u32, 8) else 7;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 1, true);
            abi.write32(rt.r[6], rt.r[0]);
            continue :blk 24;
        },
        8 => {
            abi.fetches(42);
            const dst_xy = abi.read32(0x080643B0);
            rt.r[3] = 0;
            abi.write16(dst_xy, abi.read8(rt.r[4] +% 2));
            abi.write16(dst_xy +% 2, abi.read8(rt.r[4] +% 3));
            const p_b4 = abi.read32(0x080643B4);
            var m0: u32 = 2;
            rt.updateNz(2);
            rt.cpuSub(&m0, 0, m0, true);
            var m1: u32 = 3;
            rt.updateNz(3);
            rt.cpuSub(&m1, 0, m1, true);
            rt.r[6] = abi.read8(p_b4);
            abi.setRegNz(&rt.r[0], (m0 & rt.r[6]) & m1);
            abi.write8(p_b4, @truncate(rt.r[0]));

            const p_b8 = abi.read32(0x080643B8);
            abi.write8(p_b8, 0);
            abi.write8(p_b8 +% 0x13, 0);
            abi.write8(p_b8 +% 6, 0);
            abi.write8(p_b8 +% 7, 0);

            const m_base = abi.read32(abi.read32(0x080643BC));
            const y_off = @as(u32, abi.read8(rt.r[4] +% 3)) << 1;
            var mp: u32 = undefined;
            rt.cpuAdd(&mp, m_base, abi.read32(0x080643C0), true);
            rt.cpuAdd(&mp, mp, y_off, true);
            var idx: u32 = undefined;
            rt.cpuAdd(&idx, abi.read8(rt.r[4] +% 2), abi.read16(mp), true);
            var cell: u32 = undefined;
            rt.cpuAdd(&cell, m_base, 0x12, true);
            rt.cpuAdd(&cell, cell, idx, true);
            abi.write8(cell, 0);

            const s_ptr = abi.read32(rt.r[5]);
            abi.setRegNz(&rt.r[0], 4 | abi.read8(s_ptr +% 1));
            abi.write8(s_ptr +% 1, @truncate(rt.r[0]));
            rt.r[1] = s_ptr;
            rt.r[2] = y_off;
            rt.r[4] = abi.read8(rt.r[4] +% 2);
            rt.r[6] = abi.read32(0x080643C0);
            rt.r[7] = abi.read8(s_ptr +% 1);
            switch (callCheckJumpTarget(math.func_08010A84, 0x080643A1, 0x080643CF)) {
                .jumped => continue :blk 14,
                .ret => return,
                .next => continue :blk 9,
            }
        },
        9 => {
            abi.fetches(6);
            rt.r[4] = abi.read32(rt.r[5]);
            abi.setRegNz(&rt.r[1], 0x64);
            switch (callCheckJumpTarget(math.func_0807B6AC, 0x080643A9, 0x080643CF)) {
                .jumped => continue :blk 14,
                .ret => return,
                .next => continue :blk 10,
            }
        },
        10 => {
            abi.fetches(5);
            abi.write8(rt.r[4] +% 0xA, @truncate(rt.r[0]));
            switch (callCheckJumpTarget(low_peel_9.func_08061A64, 0x080643AF, 0x080643CF)) {
                .jumped => continue :blk 14,
                .ret => return,
                .next => continue :blk 11,
            }
        },
        11 => {
            abi.fetches(3);
            continue :blk 13;
        },
        12 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0806443C);
            abi.write8(rt.r[0] +% 0x13, @truncate(rt.r[1]));
            continue :blk 13;
        },
        13 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08064440);
            switch (callCheckJumpTarget(func_080796AC, 0x080643CF, 0x080643CF)) {
                .jumped, .next => continue :blk 14,
                .ret => return,
            }
        },
        14 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0, true);
            continue :blk if (!rt.CPU_Z) @as(u32, 18) else 15;
        },
        15 => {
            abi.fetches(7);
            rt.r[0] = abi.read8(abi.read32(abi.read32(0x08064444)));
            rt.cpuSub(null, rt.r[0], 0x40, true);
            continue :blk if (rt.CPU_Z) @as(u32, 17) else 16;
        },
        16 => {
            abi.fetches(4);
            switch (callCheckJumpTarget(low_peel_13.func_08065590, 0x080643E1, 0x080643CF)) {
                .jumped => continue :blk 14,
                .ret => return,
                .next => continue :blk 17,
            }
        },
        17 => {
            abi.fetches(12);
            const p_flag = abi.read32(0x08064448);
            var mask3: u32 = 3;
            rt.updateNz(3);
            rt.cpuSub(&mask3, 0, mask3, true);
            rt.r[2] = abi.read8(p_flag);
            abi.setRegNz(&rt.r[0], mask3 & rt.r[2]);
            abi.write8(p_flag, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(abi.read32(0x0806444C));
            switch (callCheckJumpTarget(func_0807B44C, 0x080643F5, 0x080643CF)) {
                .jumped => continue :blk 14,
                .ret => return,
                .next => continue :blk 18,
            }
        },
        18 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(abi.read32(0x0806443C) +% 0x13);
            rt.cpuSub(null, rt.r[0], 0, true);
            continue :blk if (!rt.CPU_Z) @as(u32, 22) else 19;
        },
        19 => {
            abi.fetches(7);
            rt.r[4] = abi.read32(0x08064444);
            rt.r[0] = abi.read8(abi.read32(rt.r[4]));
            rt.cpuSub(null, rt.r[0], 0x40, true);
            continue :blk if (rt.CPU_Z) @as(u32, 21) else 20;
        },
        20 => {
            abi.fetches(19);
            const m_base = abi.read32(abi.read32(0x08064450));
            const pos = abi.read32(abi.read32(0x08064454));
            const y_off = @as(u32, abi.read8(pos +% 3)) << 1;
            var mp: u32 = undefined;
            rt.cpuAdd(&mp, m_base, abi.read32(0x08064458), true);
            rt.cpuAdd(&mp, mp, y_off, true);
            var idx: u32 = undefined;
            rt.cpuAdd(&idx, abi.read8(pos +% 2), abi.read16(mp), true);
            var cell: u32 = undefined;
            rt.cpuAdd(&cell, m_base, 0x12, true);
            rt.cpuAdd(&cell, cell, idx, true);
            const val = abi.read8(abi.read32(0x0806445C));
            abi.write8(cell, val);
            rt.r[0] = val;
            rt.r[1] = cell;
            rt.r[2] = y_off;
            rt.r[3] = abi.read8(pos +% 2);
            rt.r[5] = abi.read8(pos +% 3);
            rt.r[6] = abi.read32(0x08064458);
            continue :blk 21;
        },
        21 => {
            abi.fetches(12);
            const pos = abi.read32(abi.read32(0x08064454));
            const b1 = abi.read8(pos +% 1);
            rt.r[1] = pos;
            rt.r[7] = b1;
            abi.setRegNz(&rt.r[0], 0xFB & b1);
            abi.write8(pos +% 1, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], abi.read32(rt.r[4]), 1, true);
            abi.write32(rt.r[4], rt.r[0]);
            continue :blk 24;
        },
        22 => {
            abi.fetches(8);
            const p = abi.read32(0x08064474);
            rt.cpuAdd(&rt.r[0], abi.read32(p), 1, true);
            abi.write32(p, rt.r[0]);
            rt.r[1] = abi.read32(0x08064478);
            abi.setRegNz(&rt.r[0], 3);
            continue :blk 23;
        },
        23 => {
            abi.fetches(3);
            abi.write16(rt.r[1], @truncate(rt.r[0]));
            continue :blk 24;
        },
        24 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            const lr = abi.popReg();
            rt.r[0] = lr;
            rt.r[15] = lr;
            rt.recompReturn(lr);
        },
        else => unreachable,
    }
}

comptime {
    if (!builtin.is_test) {
        @export(&func_0800F8FA, .{ .name = "func_0800F8FA", .linkage = .strong });
        @export(&func_0800FCF8, .{ .name = "func_0800FCF8", .linkage = .strong });
        @export(&func_08010970, .{ .name = "func_08010970", .linkage = .strong });
        @export(&func_0801FFFC, .{ .name = "func_0801FFFC", .linkage = .strong });
        @export(&func_0802F9FC, .{ .name = "func_0802F9FC", .linkage = .strong });
        @export(&func_08030004, .{ .name = "func_08030004", .linkage = .strong });
        @export(&func_0803008C, .{ .name = "func_0803008C", .linkage = .strong });
        @export(&func_0803FCF6, .{ .name = "func_0803FCF6", .linkage = .strong });
        @export(&func_0803FD02, .{ .name = "func_0803FD02", .linkage = .strong });
        @export(&func_0803FD1A, .{ .name = "func_0803FD1A", .linkage = .strong });
        @export(&func_0804FA04, .{ .name = "func_0804FA04", .linkage = .strong });
        @export(&func_080779D2, .{ .name = "func_080779D2", .linkage = .strong });
        @export(&func_08077EA0, .{ .name = "func_08077EA0", .linkage = .strong });
        @export(&func_0807B44C, .{ .name = "func_0807B44C", .linkage = .strong });
        @export(&func_0807B450, .{ .name = "func_0807B450", .linkage = .strong });
        @export(&func_0807B454, .{ .name = "func_0807B454", .linkage = .strong });
        @export(&func_0807B458, .{ .name = "func_0807B458", .linkage = .strong });
        @export(&func_0807B45C, .{ .name = "func_0807B45C", .linkage = .strong });
        @export(&func_0807B460, .{ .name = "func_0807B460", .linkage = .strong });
        @export(&func_0807B464, .{ .name = "func_0807B464", .linkage = .strong });
        @export(&func_0807B46C, .{ .name = "func_0807B46C", .linkage = .strong });
        @export(&func_0807B47C, .{ .name = "func_0807B47C", .linkage = .strong });
        @export(&func_080385C8, .{ .name = "func_080385C8", .linkage = .strong });
        @export(&func_080796A4, .{ .name = "func_080796A4", .linkage = .strong });
        @export(&func_080796AC, .{ .name = "func_080796AC", .linkage = .strong });
        @export(&func_080796B4, .{ .name = "func_080796B4", .linkage = .strong });
        @export(&func_080775A0, .{ .name = "func_080775A0", .linkage = .strong });
        @export(&func_0800F2C2, .{ .name = "func_0800F2C2", .linkage = .strong });
        @export(&func_0800F7F6, .{ .name = "func_0800F7F6", .linkage = .strong });
        @export(&func_08020704, .{ .name = "func_08020704", .linkage = .strong });
        @export(&func_0803E9EE, .{ .name = "func_0803E9EE", .linkage = .strong });
        @export(&func_0804F7FE, .{ .name = "func_0804F7FE", .linkage = .strong });
        @export(&func_08060706, .{ .name = "func_08060706", .linkage = .strong });
        @export(&func_0806F426, .{ .name = "func_0806F426", .linkage = .strong });
        @export(&func_080702FA, .{ .name = "func_080702FA", .linkage = .strong });
        @export(&func_0806F2F4, .{ .name = "func_0806F2F4", .linkage = .strong });
        @export(&func_080055A8, .{ .name = "func_080055A8", .linkage = .strong });
        @export(&func_0800FC10, .{ .name = "func_0800FC10", .linkage = .strong });
        @export(&func_08011636, .{ .name = "func_08011636", .linkage = .strong });
        @export(&func_08060A16, .{ .name = "func_08060A16", .linkage = .strong });
        @export(&func_0800EE12, .{ .name = "func_0800EE12", .linkage = .strong });
        @export(&func_0801BCB4, .{ .name = "func_0801BCB4", .linkage = .strong });
        @export(&func_08077B00, .{ .name = "func_08077B00", .linkage = .strong });
        @export(&func_08077BB4, .{ .name = "func_08077BB4", .linkage = .strong });
        @export(&func_080796F0, .{ .name = "func_080796F0", .linkage = .strong });
        @export(&func_0800F710, .{ .name = "func_0800F710", .linkage = .strong });
        @export(&func_0805F70E, .{ .name = "func_0805F70E", .linkage = .strong });
        @export(&func_08033374, .{ .name = "func_08033374", .linkage = .strong });
        @export(&func_08077B20, .{ .name = "func_08077B20", .linkage = .strong });
        @export(&func_08077B64, .{ .name = "func_08077B64", .linkage = .strong });
        @export(&func_08077BA0, .{ .name = "func_08077BA0", .linkage = .strong });
        @export(&func_0800BBEC, .{ .name = "func_0800BBEC", .linkage = .strong });
        @export(&func_0802FDF8, .{ .name = "func_0802FDF8", .linkage = .strong });
        @export(&func_08061114, .{ .name = "func_08061114", .linkage = .strong });
        @export(&func_08077B78, .{ .name = "func_08077B78", .linkage = .strong });
        @export(&func_08077B8C, .{ .name = "func_08077B8C", .linkage = .strong });
        @export(&func_08077BD8, .{ .name = "func_08077BD8", .linkage = .strong });
        @export(&func_08077BEC, .{ .name = "func_08077BEC", .linkage = .strong });
        @export(&func_08077B0C, .{ .name = "func_08077B0C", .linkage = .strong });
        @export(&func_08077A40, .{ .name = "func_08077A40", .linkage = .strong });
        @export(&func_0807C49E, .{ .name = "func_0807C49E", .linkage = .strong });
        @export(&func_08077A5A, .{ .name = "func_08077A5A", .linkage = .strong });
        @export(&func_08077B34, .{ .name = "func_08077B34", .linkage = .strong });
        @export(&func_08059DD4, .{ .name = "func_08059DD4", .linkage = .strong });
        @export(&func_0800020C, .{ .name = "func_0800020C", .linkage = .strong });
        @export(&func_080642C8, .{ .name = "func_080642C8", .linkage = .strong });
    }
}

test "tail_low trampoline exports are callable" {
    try std.testing.expect(@TypeOf(func_0807B44C) == fn () callconv(.c) void);
    try std.testing.expect(@TypeOf(func_080796A4) == fn () callconv(.c) void);
}
