//! Low-ROM (< 0x08080000) block-peeled wave 5 (31..60 reachable lines, remaining 186).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const battle = @import("battle.zig");
const campaign = @import("campaign.zig");
const clusters_low_2 = @import("clusters_low_2.zig");
const dma = @import("dma.zig");
const hw = @import("hw.zig");
const low_peel_1 = @import("low_peel_1.zig");
const low_peel_10 = @import("low_peel_10.zig");
const low_peel_12 = @import("low_peel_12.zig");
const low_peel_13 = @import("low_peel_13.zig");
const low_peel_15 = @import("low_peel_15.zig");
const low_peel_17 = @import("low_peel_17.zig");
const low_peel_18 = @import("low_peel_18.zig");
const low_peel_2 = @import("low_peel_2.zig");
const low_peel_3 = @import("low_peel_3.zig");
const low_peel_4 = @import("low_peel_4.zig");
const low_peel_6 = @import("low_peel_6.zig");
const low_peel_7 = @import("low_peel_7.zig");
const low_peel_8 = @import("low_peel_8.zig");
const low_peel_9 = @import("low_peel_9.zig");
const main_loop = @import("main_loop.zig");
const math = @import("math.zig");
const proc = @import("proc.zig");
const sound = @import("sound.zig");
const sprite_anim = @import("sprite_anim.zig");
const tail_low = @import("tail_low.zig");
const ui = @import("ui.zig");

fn pushRegs(comptime regs: []const u5) void {
    inline for (0..regs.len) |i| {
        const idx = regs[regs.len - 1 - i];
        rt.r[13] -%= 4;
        abi.write32(rt.r[13], rt.r[idx]);
    }
}

fn popRegsSeq(comptime regs: []const u5) void {
    inline for (regs, 0..) |r, idx| {
        rt.r[r] = if (idx == 0) rt.bus_read32(rt.r[13]) else rt.bus_read32s(rt.r[13]);
        rt.r[13] +%= 4;
    }
}

fn stmRegs(comptime base: u5, comptime regs: []const u5) void {
    var addr: u32 = rt.r[base];
    inline for (regs) |r| {
        abi.write32(addr, rt.r[r]);
        addr +%= 4;
    }
    rt.r[base] = addr;
}

fn ldmRegs(comptime base: u5, comptime regs: []const u5) void {
    var addr: u32 = rt.r[base];
    inline for (regs, 0..) |r, idx| {
        rt.r[r] = if (idx == 0) rt.bus_read32(addr) else rt.bus_read32s(addr);
        addr +%= 4;
    }
    rt.r[base] = addr;
}

pub fn func_080438E4() callconv(.c) void {
    if (!abi.enter(0x080438E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x08043910);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x41, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08043914);
            if (!proc.killProcByCallbackCall(0x0804390B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(battle.func_080226A4, 0x080438F7)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x41, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08043E80() callconv(.c) void {
    if (!abi.enter(0x08043E80)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08043E98);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08043E9C);
            rt.r[0] = abi.read32(0x08043EA0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.r[1] = abi.read32(0x08043EB0);
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08043EB4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1E);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08043EB8() callconv(.c) void {
    if (!abi.enter(0x08043EB8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08043ED0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08043ED4);
            rt.r[0] = abi.read32(0x08043ED8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.r[1] = abi.read32(0x08043EE8);
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08043EEC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x20);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_080443AC() callconv(.c) void {
    if (!abi.enter(0x080443AC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.r[5] = abi.read32(0x080443D4);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_3.func_0801193C, 0x080443C3)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!hw.markBgDirtyCall(0x080443C7)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0804486C() callconv(.c) void {
    if (!abi.enter(0x0804486C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.r[0] = abi.read32(0x080448A8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x080448AC);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(15);
            rt.r[0] = abi.read32(0x080448A8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read16(rt.r[0] +% 0x1E);
            rt.r[2] = abi.read16(rt.r[0] +% 0x20);
            rt.cpuSub(&rt.r[1], rt.r[3], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.r[0] = abi.read16(rt.r[0] +% 0x28);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(low_peel_15.func_08043A7C, 0x080448A5)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(low_peel_15.func_080443D8, 0x0804488B)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08044B6C() callconv(.c) void {
    if (!abi.enter(0x08044B6C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08044B90);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3E, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(low_peel_12.func_08043918, 0x08044B85)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08044B94);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08044B8D)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08044E34() callconv(.c) void {
    if (!abi.enter(0x08044E34)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[3] = abi.read32(0x08044E60);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xE, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            rt.r[2] = abi.read32(0x08044E64);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08044E68);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08044E5D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080451DC() callconv(.c) void {
    if (!abi.enter(0x080451DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x8;
            rt.r[3] = abi.read32(0x08045214);
            rt.r[2] = abi.read32(0x08045218);
            rt.r[4] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], rt.r[0] << 13);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[2] = abi.read8(rt.r[2] +% 0x1);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0xBA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x8);
            if (!hw.fillTileRectCall(0x08045209)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x7, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            if (!hw.markDisplayDirtyCall(0x0804520D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08046DB8() callconv(.c) void {
    if (!abi.enter(0x08046DB8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x28);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(16);
            rt.r[2] = abi.read32(0x08046DE4);
            rt.r[0] = abi.read32(0x08046DE8);
            rt.r[1] = abi.read16(rt.r[1] +% 0x28);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.r[1] = abi.read8(rt.r[1] +% 0x3);
            if (!abi.call(low_peel_15.func_0802928C, 0x08046DDF)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0804781C() callconv(.c) void {
    if (!abi.enter(0x0804781C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_3.func_0801833C, 0x08047823)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08047834);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08047831)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_080478EC() callconv(.c) void {
    if (!abi.enter(0x080478EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.r[0] = abi.read32(0x08047910);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x5C, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x68, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x68, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08047914);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            continue :blk 7;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08047920);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            continue :blk 7;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08047934);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08047940);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08047FCC() callconv(.c) void {
    if (!abi.enter(0x08047FCC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = abi.read32(0x08047FFC);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x5F, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        3 => {
            abi.fetches(15);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x5F, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_080487D8() callconv(.c) void {
    if (!abi.enter(0x080487D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_3.func_0801833C, 0x080487DF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x080487FC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x62, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08048800);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x080487F9)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08048814() callconv(.c) void {
    if (!abi.enter(0x08048814)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_3.func_0801833C, 0x0804881B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08048834);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(low_peel_3.func_080131E0, 0x08048829)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08048838);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08048831)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08048A28() callconv(.c) void {
    if (!abi.enter(0x08048A28)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_3.func_0801833C, 0x08048A2F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08048A40);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08048A3D)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08048DCC() callconv(.c) void {
    if (!abi.enter(0x08048DCC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(sprite_anim.func_08013794, 0x08048DD9)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08048E48);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08048E4C() callconv(.c) void {
    if (!abi.enter(0x08048E4C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08048E64);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(5);
            if (!sound.playSfxCall(0x79, 0x08048E5F)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08048E68() callconv(.c) void {
    if (!abi.enter(0x08048E68)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08048E84);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x21, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(sprite_anim.func_08049554, 0x08048E91)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08048E88);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08048E83)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0804910C() callconv(.c) void {
    if (!abi.enter(0x0804910C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08049128);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x1A);
            abi.write16(rt.r[0] +% 0x1C, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x22, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(ui.func_0804901C, 0x08049123)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080491A4() callconv(.c) void {
    if (!abi.enter(0x080491A4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x080491BC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[0] +% 0x4);
            if (!abi.call(low_peel_8.func_0804912C, 0x080491B7)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080494C4() callconv(.c) void {
    if (!abi.enter(0x080494C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            abi.pushLr();
            rt.r[0] = abi.read32(0x080494F0);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[2] +% 0x1A);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x4, true);
            rt.r[3] = abi.read32(0x080494F4);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write16(rt.r[2] +% 0x1A, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080494F8);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0xCE);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write16(rt.r[2] +% 0x1A, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080494FC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x080494EB)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0804B4B0() callconv(.c) void {
    if (!abi.enter(0x0804B4B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0804B4C8);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x30, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0804B4E0);
            rt.r[1] = abi.read32(0x0804B4E4);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0xE2, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0804B4CC);
            rt.r[1] = abi.read32(0x0804B4D0);
            continue :blk 3;
        },
        5 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0804C1B8() callconv(.c) void {
    if (!abi.enter(0x0804C1B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_3.func_0801833C, 0x0804C1BF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804C1D0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0804C1CD)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0804C1D4() callconv(.c) void {
    if (!abi.enter(0x0804C1D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_12.func_08048D14, 0x0804C1DB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804C1EC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0804C1E9)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0804C1F0() callconv(.c) void {
    if (!abi.enter(0x0804C1F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0804C214);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0804C218);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x9);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804C21C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0804C211)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0804C39C() callconv(.c) void {
    if (!abi.enter(0x0804C39C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(ui.func_0806C25C, 0x0804C3A3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804C3B4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0804C3B1)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0804C5CC() callconv(.c) void {
    if (!abi.enter(0x0804C5CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[13] -%= 0x4;
            rt.r[1] = abi.read32(0x0804C5E4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0804C5E8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], 0xC4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[1], 0x3);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x58);
            abi.setRegNz(&rt.r[2], 0xE1);
            abi.setRegNz(&rt.r[3], 0xD);
            if (!abi.call(low_peel_12.func_080495C0, 0x0804C5FF)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0804C668() callconv(.c) void {
    if (!abi.enter(0x0804C668)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(campaign.func_0803F064, 0x0804C671)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0804CC98() callconv(.c) void {
    if (!abi.enter(0x0804CC98)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x0804CCB8);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[1] = abi.read32(0x0804CCBC);
            rt.cpuAdd(&rt.r[3], rt.r[0], rt.r[1], true);
            rt.r[4] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x38);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0804CCD8);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x8, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(13);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[1] = abi.read32(0x0804CCDC);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x38, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0804CCE0() callconv(.c) void {
    if (!abi.enter(0x0804CCE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0804CCFC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read32(0x0804CD00);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[3], true);
            rt.r[3] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[4]));
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read32(0x0804CD18);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0804D848() callconv(.c) void {
    if (!abi.enter(0x0804D848)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_3.func_0801833C, 0x0804D84F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804D860);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0804D85D)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0804D864() callconv(.c) void {
    if (!abi.enter(0x0804D864)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_3.func_0801833C, 0x0804D86B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(func_0804CCE0, 0x0804D875)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0804D88C);
            if (!abi.call(ui.func_0804C680, 0x0804D881)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804D890);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0804D889)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0804D894() callconv(.c) void {
    if (!abi.enter(0x0804D894)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_3.func_0801833C, 0x0804D89B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804D8B8);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0804D8BC);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804D8C0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0804D8B5)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0804E068() callconv(.c) void {
    if (!abi.enter(0x0804E068)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            abi.pushLr();
            rt.r[2] = abi.read32(0x0804E09C);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x31, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x79, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x46, true);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0804E0A0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!proc.spawnProcCall(0x0804E08F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804E0A4);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!proc.spawnProcCall(0x0804E097)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0804ED98() callconv(.c) void {
    if (!abi.enter(0x0804ED98)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0804EDB4);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4A, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x49, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x49, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x49, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2D, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0804EDE0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0804EDDB)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0804EFD8() callconv(.c) void {
    if (!abi.enter(0x0804EFD8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0804EFEC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(low_peel_12.func_0804EE80, 0x0804EFF9)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804EFF0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0804EFEB)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0804F010);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x33, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x96, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804F014);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0804F00D)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0804F1F8() callconv(.c) void {
    if (!abi.enter(0x0804F1F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x0804F218);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x45, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(0x0804F21C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.setRegNz(&rt.r[1], 0x2);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0804F6E8() callconv(.c) void {
    if (!abi.enter(0x0804F6E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0804F718);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x24, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x79, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.write16(rt.r[1] +% 0x24, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804F71C);
            rt.r[1] = abi.read32(0x0804F720);
            if (!hw.syncDisplayRegCall(0x0804F705)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804F724);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!proc.spawnProcCall(0x0804F70D)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804F728);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!proc.spawnProcCall(0x0804F715)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0804F734() callconv(.c) void {
    if (!abi.enter(0x0804F734)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0804F74C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x24);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804F750);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0804F749)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0804F8F4() callconv(.c) void {
    if (!abi.enter(0x0804F8F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x20, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804F914);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0804F90F)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(low_peel_10.func_080116F4, 0x0804F91D)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0804F8FA() callconv(.c) void {
    if (!abi.enter(0x0804F8FA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x20, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804F914);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0804F90F)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_10.func_080116F4, 0x0804F91D)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0804FCF0() callconv(.c) void {
    if (!abi.enter(0x0804FCF0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0804FD14);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x0804FD18);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1C);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(5);
            if (!sound.playSfxCall(0x79, 0x0804FD0F)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080500F2() callconv(.c) void {
    if (!abi.enter(0x080500F2)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[2] = abi.read32(0x08050128);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 14);
            rt.r[0] = abi.read32(0x0805012C);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08050130);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] | rt.r[0]);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[0], 0x5A);
            abi.setRegNz(&rt.r[1], 0x59);
            if (!hw.drawDispatchCall(0x0805010D)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080500F4() callconv(.c) void {
    if (!abi.enter(0x080500F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 14);
            rt.r[0] = abi.read32(0x0805012C);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08050130);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] | rt.r[0]);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[0], 0x5A);
            abi.setRegNz(&rt.r[1], 0x59);
            if (!hw.drawDispatchCall(0x0805010D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080500F8() callconv(.c) void {
    if (!abi.enter(0x080500F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08050130);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] | rt.r[0]);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[0], 0x5A);
            abi.setRegNz(&rt.r[1], 0x59);
            if (!hw.drawDispatchCall(0x0805010D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080500FA() callconv(.c) void {
    if (!abi.enter(0x080500FA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08050130);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] | rt.r[0]);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[0], 0x5A);
            abi.setRegNz(&rt.r[1], 0x59);
            if (!hw.drawDispatchCall(0x0805010D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08050102() callconv(.c) void {
    if (!abi.enter(0x08050102)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[0], 0x5A);
            abi.setRegNz(&rt.r[1], 0x59);
            if (!hw.drawDispatchCall(0x0805010D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080502FE() callconv(.c) void {
    if (!abi.enter(0x080502FE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08050324);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08050340);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_2.func_080502E0, 0x0805033B)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_8.func_0803A664, 0x0805030B)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08050328);
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08050319)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(3);
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_08050300() callconv(.c) void {
    if (!abi.enter(0x08050300)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08050340);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_2.func_080502E0, 0x0805033B)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(low_peel_8.func_0803A664, 0x0805030B)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08050328);
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08050319)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(3);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08050302() callconv(.c) void {
    if (!abi.enter(0x08050302)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08050340);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_2.func_080502E0, 0x0805033B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(low_peel_8.func_0803A664, 0x0805030B)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08050328);
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08050319)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08050304() callconv(.c) void {
    if (!abi.enter(0x08050304)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08050340);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_2.func_080502E0, 0x0805033B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_8.func_0803A664, 0x0805030B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08050328);
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08050319)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0805030C() callconv(.c) void {
    if (!abi.enter(0x0805030C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08050340);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_2.func_080502E0, 0x0805033B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08050328);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08050319)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08050358() callconv(.c) void {
    if (!abi.enter(0x08050358)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_3.func_0801833C, 0x0805035F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08050370);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0805036D)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08050374() callconv(.c) void {
    if (!abi.enter(0x08050374)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_3.func_0801833C, 0x0805037B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0805039C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080503A0);
            if (!abi.call(low_peel_6.func_08018400, 0x0805038F)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080503A4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08050397)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08050502() callconv(.c) void {
    if (!abi.enter(0x08050502)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[1], rt.r[1] << 14);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[1] << 20);
            abi.setRegNz(&rt.r[2], 0xB0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 15);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[2] = abi.read32(0x0805053C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x4C);
            if (!abi.call(ui.func_0804FD1C, 0x08050529)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08050504() callconv(.c) void {
    if (!abi.enter(0x08050504)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[1], rt.r[1] << 14);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[1] << 20);
            abi.setRegNz(&rt.r[2], 0xB0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 15);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[2] = abi.read32(0x0805053C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x4C);
            if (!abi.call(ui.func_0804FD1C, 0x08050529)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08050508() callconv(.c) void {
    if (!abi.enter(0x08050508)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[1], rt.r[1] << 14);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[1] << 20);
            abi.setRegNz(&rt.r[2], 0xB0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 15);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[2] = abi.read32(0x0805053C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x4C);
            if (!abi.call(ui.func_0804FD1C, 0x08050529)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080505EC() callconv(.c) void {
    if (!abi.enter(0x080505EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08050610);
            abi.setRegNz(&rt.r[1], 0x3);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08050614);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x24);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x08050618);
            rt.r[3] = abi.read32(0x0805061C);
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!hw.drawDispatchCall(0x0805060D)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08050634() callconv(.c) void {
    if (!abi.enter(0x08050634)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08050660);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!dma.copyPaletteCall(0x08050641)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08050664);
            abi.setRegNz(&rt.r[1], 0xA0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!dma.copyPaletteCall(0x0805064D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08050668);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0805066C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08050C34() callconv(.c) void {
    if (!abi.enter(0x08050C34)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08050C54);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_2.func_080502E0, 0x08050C49)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08050C58);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08050C51)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08050CFE() callconv(.c) void {
    if (!abi.enter(0x08050CFE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            abi.write32(rt.r[13] +% 0x60, rt.r[1]);
            abi.setRegNz(&rt.r[0], 0);
            rt.cpuSub(null, rt.r[4], 0xBC, true);
            abi.setRegNz(&rt.r[0], 0);
            abi.setRegNz(&rt.r[5], rt.r[1] << 5);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            rt.r[6] = abi.read32(0x08050F40);
            abi.setRegNz(&rt.r[1], 0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            rt.r[6] = rt.r[13] +% 0x210;
            abi.setRegNz(&rt.r[6], 0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08050D2C);
            rt.r[1] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x74, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(low_peel_6.func_08018400, 0x08050D29)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08051888() callconv(.c) void {
    if (!abi.enter(0x08051888)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_4.func_08025508, 0x0805188F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080518B0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!proc.spawnProcCall(0x080518AD)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080518A0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!proc.spawnProcCall(0x0805189F)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(3);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0805277C() callconv(.c) void {
    if (!abi.enter(0x0805277C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            rt.cpuSub(null, rt.r[0], 0x8, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08052798);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x15, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_080575DE() callconv(.c) void {
    if (!abi.enter(0x080575DE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[1], true);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[1], true);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 24);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(low_peel_10.func_08013330, 0x080575F9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[5], rt.r[7], rt.r[5], true);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0xC, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0805A018() callconv(.c) void {
    if (!abi.enter(0x0805A018)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_0805AE44, 0x0805A01F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(ui.func_08052658, 0x0805A023)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0805A040);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], 0x96);
            abi.setRegNz(&rt.r[0], rt.r[0] << 17);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0805A044);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0805A03D)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0805AE44() callconv(.c) void {
    if (!abi.enter(0x0805AE44)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            abi.pushLr();
            rt.r[3] = abi.read32(0x0805AE78);
            rt.r[1] = abi.read32(0x0805AE7C);
            rt.r[0] = abi.read32(0x0805AE80);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0805AE84);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(tail_low.func_0807B454, 0x0805AE75)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x40);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(3);
            rt.r[2] = abi.read32(rt.r[3] +% 0x8);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0805DBCC() callconv(.c) void {
    if (!abi.enter(0x0805DBCC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            rt.cpuSub(null, rt.r[0], 0xD, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x2);
            rt.cpuSub(null, rt.r[1], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.recompReturn(rt.r[14]); return;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0805DD00() callconv(.c) void {
    if (!abi.enter(0x0805DD00)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[3] = abi.read32(0x0805DD4C);
            abi.setRegNz(&rt.r[2], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            abi.setRegNz(&rt.r[1], 0xB4);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            rt.r[0] = abi.read16(rt.r[2] +% 0x14);
            rt.r[1] = abi.read16(rt.r[2] +% 0x16);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(22);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0x14, @truncate(rt.r[0]));
            rt.r[3] = abi.read16(rt.r[2] +% 0xC);
            rt.r[1] = abi.read16(rt.r[2] +% 0x10);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            abi.write16(rt.r[2] +% 0xC, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.r[3] = abi.read16(rt.r[2] +% 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x8, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[2] +% 0xE);
            rt.r[3] = abi.read16(rt.r[2] +% 0x12);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.r[1] = abi.read16(rt.r[2] +% 0xA);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[2] +% 0xA, @truncate(rt.r[0]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0805F1F8() callconv(.c) void {
    if (!abi.enter(0x0805F1F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.r[7] = rt.r[13];
            rt.cpuAdd(&rt.r[3], rt.r[7], rt.r[0], true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x1, true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            continue :blk 0;
        },
        5 => {
            abi.fetches(6);
            rt.r[13] +%= 0xA0;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0805F22C() callconv(.c) void {
    if (!abi.enter(0x0805F22C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            rt.r[2] = abi.read32(0x0805F248);
            rt.r[3] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 3);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x6);
            abi.setRegNz(&rt.r[2], rt.r[0] << 25);
            abi.setRegNz(&rt.r[0], rt.r[2] >> 25);
            rt.r[3] = abi.read8(rt.r[1] +% 0xC);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.r[0] = abi.read8(rt.r[1] +% 0xC);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[2] >> 25);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0805FAE8() callconv(.c) void {
    if (!abi.enter(0x0805FAE8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[6] = rt.r[10];
            abi.write32(rt.r[6] +% 0x0, rt.r[0]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.r[13] +%= 0x18;
            popRegsSeq(&.{ 3, 4, 5 });
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0805FCEE() callconv(.c) void {
    if (!abi.enter(0x0805FCEE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[1], rt.r[6], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_0805FD30, 0x0805FCF9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_0805FD30, 0x0805FD03)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[5] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[4], true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0805FE00() callconv(.c) void {
    if (!abi.enter(0x0805FE00)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x0805FE34);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0xC);
            rt.r[5] = abi.read8(rt.r[0] +% 0xE);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x78, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[4]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08060806() callconv(.c) void {
    if (!abi.enter(0x08060806)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[4] = abi.read32(0x08060850);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[4]);
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            rt.r[1] = abi.read32(0x08060854);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0xA);
            rt.r[2] = rt.r[13] +% 0x4;
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_08060980, 0x0806081F)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13] +% 0x4;
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_17.func_08066248, 0x0806082B)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = rt.r[13] +% 0x4;
            if (!abi.call(low_peel_18.func_08060078, 0x08060831)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08060808() callconv(.c) void {
    if (!abi.enter(0x08060808)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[4]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            rt.r[1] = abi.read32(0x08060854);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0xA);
            rt.r[2] = rt.r[13] +% 0x4;
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_08060980, 0x0806081F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13] +% 0x4;
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(low_peel_17.func_08066248, 0x0806082B)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = rt.r[13] +% 0x4;
            if (!abi.call(low_peel_18.func_08060078, 0x08060831)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806080A() callconv(.c) void {
    if (!abi.enter(0x0806080A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            rt.r[1] = abi.read32(0x08060854);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0xA);
            rt.r[2] = rt.r[13] +% 0x4;
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_08060980, 0x0806081F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13] +% 0x4;
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(low_peel_17.func_08066248, 0x0806082B)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = rt.r[13] +% 0x4;
            if (!abi.call(low_peel_18.func_08060078, 0x08060831)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08060816() callconv(.c) void {
    if (!abi.enter(0x08060816)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_08060980, 0x0806081F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13] +% 0x4;
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_17.func_08066248, 0x0806082B)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = rt.r[13] +% 0x4;
            if (!abi.call(low_peel_18.func_08060078, 0x08060831)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08061DA0() callconv(.c) void {
    if (!abi.enter(0x08061DA0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[4] = abi.read32(0x08061DBC);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x3F, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080625CC() callconv(.c) void {
    if (!abi.enter(0x080625CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            rt.r[2] = abi.read32(0x080625EC);
            rt.r[0] = abi.read32(0x080625F0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08062ECC() callconv(.c) void {
    if (!abi.enter(0x08062ECC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x8;
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            if (!abi.call(func_080625CC, 0x08062EDB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[2] = rt.r[13] +% 0x4;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_17.func_080625FC, 0x08062EE3)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(4);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[5]));
            abi.write16(rt.r[4] +% 0x2, @truncate(rt.r[6]));
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_080631F0() callconv(.c) void {
    if (!abi.enter(0x080631F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.r[5] = abi.read32(0x0806320C);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(main_loop.func_0805BA34, 0x080631FD)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.r[1] = abi.read16(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08063324() callconv(.c) void {
    if (!abi.enter(0x08063324)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806334C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08063350);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        4 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x2, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08066B48() callconv(.c) void {
    if (!abi.enter(0x08066B48)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[1] = abi.read32(0x08066B8C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(low_peel_7.func_08024544, 0x08066B55)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(20);
            rt.r[1] = abi.read32(0x08066B90);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08066B94);
            rt.r[2] = abi.read32(0x08066B98);
            rt.r[1] = abi.read8(rt.r[2] +% 0x6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2E, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x08066B9C);
            rt.r[0] = abi.read8(rt.r[2] +% 0x7);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[2] +% 0xC);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[2] +% 0xD);
            abi.write8(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[3], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xE, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08067650() callconv(.c) void {
    if (!abi.enter(0x08067650)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08067660);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], 0x3, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08067680);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x3);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x50, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x50);
            continue :blk 3;
        },
        5 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08068164() callconv(.c) void {
    if (!abi.enter(0x08068164)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[4] = abi.read32(0x08068184);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[2] = abi.read32(0x08068188);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08068548() callconv(.c) void {
    if (!abi.enter(0x08068548)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08068578);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_7.func_08026750, 0x08068557)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0806857C);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x08068580);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2E, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_4.func_08034940, 0x08068573)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08068584() callconv(.c) void {
    if (!abi.enter(0x08068584)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x080685A4);
            rt.r[0] = abi.read8(rt.r[0] +% 0xD);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(12);
            rt.r[3] = abi.read32(0x080685C8);
            rt.r[2] = abi.read32(0x080685CC);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(tail_low.func_0807B44C, 0x080685C5)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(12);
            rt.r[3] = abi.read32(0x080685A8);
            rt.r[2] = abi.read32(0x080685AC);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(tail_low.func_0807B44C, 0x080685A3)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_080688CC() callconv(.c) void {
    if (!abi.enter(0x080688CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x080688F4);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x12);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x5, true);
            rt.r[3] = abi.read8(rt.r[2] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[3] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x9);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write8(rt.r[2] +% 0x9, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08069F44() callconv(.c) void {
    if (!abi.enter(0x08069F44)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[3] = abi.read32(0x08069F70);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x8C);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[0]);
            rt.cpuSub(null, rt.r[4], 0x8, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(hw.func_08069B1C, 0x08069F83)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08069F74);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x08069F78);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x48, true);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[4], rt.r[4] ^ rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08069F90() callconv(.c) void {
    if (!abi.enter(0x08069F90)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x18);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4A, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.write8(rt.r[1] +% 0x1E, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x18, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(hw.func_08069B1C, 0x08069FA1)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0806A174() callconv(.c) void {
    if (!abi.enter(0x0806A174)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[2] = rt.r[15];
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            abi.setRegNz(&rt.r[1], 0xC);
            rt.cpuSub(null, rt.r[2], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0xD);
            rt.cpuSub(null, rt.r[2], 0x8, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x4);
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806A300() callconv(.c) void {
    if (!abi.enter(0x0806A300)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[5] = abi.read32(0x0806A320);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[5], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[1] = rt.sext8(abi.read8(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_9.func_0806A27C, 0x0806A313)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806A368() callconv(.c) void {
    if (!abi.enter(0x0806A368)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0806A384);
            rt.r[2] = abi.read32(0x0806A388);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x20, true);
            abi.setRegNz(&rt.r[4], 0xFF);
            abi.setRegNz(&rt.r[3], 0x4);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[2] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[4]);
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x8, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806A45C() callconv(.c) void {
    if (!abi.enter(0x0806A45C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0806A47C);
            if (!proc.allocProcSlotCall(0x0806A465)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806A480);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0806A479)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0806B01C() callconv(.c) void {
    if (!abi.enter(0x0806B01C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0806B03C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806B040);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0806B02F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806B044);
            abi.setRegNz(&rt.r[1], 0x8);
            if (!proc.spawnProcCall(0x0806B037)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0806C02C() callconv(.c) void {
    if (!abi.enter(0x0806C02C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[0] = abi.read32(0x0806C060);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 2);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[0] = abi.read32(0x0806C064);
            rt.r[5] = abi.read32(0x0806C068);
            abi.setRegNz(&rt.r[4], 0xF);
            rt.r[6] = abi.read32(0x0806C06C);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[6], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.cpuSub(&rt.r[0], rt.r[3], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0xF, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(hw.func_080112C0, 0x0806C059)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806C0F4() callconv(.c) void {
    if (!abi.enter(0x0806C0F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x42, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(low_peel_9.func_0806A324, 0x0806C10D)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(low_peel_9.func_0806B438, 0x0806C111)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_9.func_0806BFF4, 0x0806C115)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806C128);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0806C11D)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x32);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806C12C() callconv(.c) void {
    if (!abi.enter(0x0806C12C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[3]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0806C15C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806C160);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0806C159)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806C27C() callconv(.c) void {
    if (!abi.enter(0x0806C27C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x48, true);
            rt.r[4] = abi.read32(0x0806C2AC);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x28);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[2]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x44, true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806C494() callconv(.c) void {
    if (!abi.enter(0x0806C494)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[4], 0xF);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806C4AC);
            if (!proc.killProcByCallbackCall(0x0806C49F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806C8D0() callconv(.c) void {
    if (!abi.enter(0x0806C8D0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0806C900);
            rt.r[0] = abi.read8(rt.r[0] +% 0x3);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0806C904);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_9.func_0806C87C, 0x0806C8DF)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            if (!sound.playSfxCall(0x66, 0x0806C8F3)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806C908);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0806C8FB)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806CAF0() callconv(.c) void {
    if (!abi.enter(0x0806CAF0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[2] = abi.read32(0x0806CB08);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.r[0] << 7);
            rt.r[1] = abi.read32(0x0806CB30);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[2] << 5);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 9);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
            abi.setRegNz(&rt.r[2], 0xC0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 19);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0x80);
            if (!dma.enqueueOrCopyAbiCall(0x0806CB2B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[2] << 5);
            rt.r[1] = abi.read32(0x0806CB0C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x80);
            if (!abi.call(low_peel_6.func_0800FED0, 0x0806CB07)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0806CB50() callconv(.c) void {
    if (!abi.enter(0x0806CB50)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x27);
            rt.r[0] = abi.read32(0x0806CB7C);
            abi.setRegNz(&rt.r[1], 0xEA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[5], rt.r[0], rt.r[1], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[6], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!proc.clearProcSlotCall(0x0806CB6D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[5], rt.r[5], 0x60, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806CB80() callconv(.c) void {
    if (!abi.enter(0x0806CB80)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x27);
            rt.r[0] = abi.read32(0x0806CB98);
            abi.setRegNz(&rt.r[4], 0xEA);
            abi.setRegNz(&rt.r[4], rt.r[4] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x60, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806CBAC() callconv(.c) void {
    if (!abi.enter(0x0806CBAC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x27);
            rt.r[0] = abi.read32(0x0806CBD8);
            abi.setRegNz(&rt.r[1], 0xEA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[5], rt.r[0], rt.r[1], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[6], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(clusters_low_2.func_080139D4, 0x0806CBC9)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[5], rt.r[5], 0x60, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806CBE8() callconv(.c) void {
    if (!abi.enter(0x0806CBE8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x27);
            rt.r[0] = abi.read32(0x0806CC14);
            abi.setRegNz(&rt.r[1], 0xEA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[5], rt.r[0], rt.r[1], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[6], true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            if (!abi.call(low_peel_6.func_08013248, 0x0806CC05)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[5], rt.r[5], 0x60, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806CD78() callconv(.c) void {
    if (!abi.enter(0x0806CD78)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x0806CDC4);
            rt.r[0] = abi.read32(0x0806CDC8);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0806CDCC);
            abi.setRegNz(&rt.r[0], 0x21);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(16);
            rt.r[1] = abi.read32(0x0806CDA0);
            abi.setRegNz(&rt.r[0], 0x4);
            rt.r[3] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0806CDA4);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x2);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            if (!abi.call(hw.func_0807AE50, 0x0806CD9D)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0806CDD0() callconv(.c) void {
    if (!abi.enter(0x0806CDD0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x0806CE1C);
            rt.r[0] = abi.read32(0x0806CE20);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0806CE24);
            abi.setRegNz(&rt.r[0], 0x11);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(16);
            rt.r[1] = abi.read32(0x0806CDF8);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[3] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0806CDFC);
            abi.setRegNz(&rt.r[0], 0x10);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            if (!abi.call(hw.func_0807AE50, 0x0806CDF5)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0806CEF8() callconv(.c) void {
    if (!abi.enter(0x0806CEF8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[5], 0x27);
            rt.r[0] = abi.read32(0x0806CF24);
            abi.setRegNz(&rt.r[1], 0xEA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[7], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(tail_low.func_0807B464, 0x0806CF15)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x60, true);
            rt.cpuSub(&rt.r[5], rt.r[5], 0x1, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806D80C() callconv(.c) void {
    if (!abi.enter(0x0806D80C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            abi.pushLr();
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 1));
            rt.r[2] = abi.read32(0x0806D838);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x38, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[1], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[1]));
            abi.setRegNz(&rt.r[3], 0x2A);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            if (!abi.call(hw.func_0806D7AC, 0x0806D849)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1A, true);
            abi.setRegNz(&rt.r[3], 0x2A);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            if (!abi.call(hw.func_0806D7DC, 0x0806D837)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0806D9C0() callconv(.c) void {
    if (!abi.enter(0x0806D9C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(22);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[1] = abi.read16(rt.r[0] +% 0x28);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[2], true);
            rt.r[4] = abi.read32(0x0806D9FC);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[1]);
            rt.r[1] = abi.read16(rt.r[0] +% 0x2A);
            rt.cpuSub(&rt.r[4], rt.r[4], 0xF3, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[1], 0xFF);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[1]);
            rt.r[5] = abi.read32(0x0806DA00);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[4], 0xC1);
            abi.setRegNz(&rt.r[4], rt.r[4] << 7);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!hw.drawDispatchCall(0x0806D9F7)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x4, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806DF10() callconv(.c) void {
    if (!abi.enter(0x0806DF10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x3A);
            rt.r[2] = abi.read16(rt.r[4] +% 0x3C);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            abi.write16(rt.r[4] +% 0x3A, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], 0x20);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0806DE4C, 0x0806DF3D)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806DF44);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0806DF37)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806E2E4() callconv(.c) void {
    if (!abi.enter(0x0806E2E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(15);
            rt.r[1] = abi.read16(rt.r[4] +% 0x3A);
            rt.r[2] = abi.read16(rt.r[4] +% 0x3C);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            abi.write16(rt.r[4] +% 0x3A, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], 0x28);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806E318);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0806E30B)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0806E0E4, 0x0806E311)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806E2E8() callconv(.c) void {
    if (!abi.enter(0x0806E2E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            rt.r[1] = abi.read16(rt.r[4] +% 0x3A);
            rt.r[2] = abi.read16(rt.r[4] +% 0x3C);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            abi.write16(rt.r[4] +% 0x3A, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], 0x28);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806E318);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0806E30B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0806E0E4, 0x0806E311)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806E480() callconv(.c) void {
    if (!abi.enter(0x0806E480)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0806E4B4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x8);
            abi.setRegNz(&rt.r[0], 0x32);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[0]);
            abi.setRegNz(&rt.r[0], 0xF0);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            if (!math.divSigned32Call(0x0806E49B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0806E8B0() callconv(.c) void {
    if (!abi.enter(0x0806E8B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0806E8C8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x34, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[1] +% 0x34, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.write32(rt.r[1] +% 0x34, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            abi.write32(rt.r[1] +% 0x38, rt.r[0]);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806E95C() callconv(.c) void {
    if (!abi.enter(0x0806E95C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[2] = abi.read32(0x0806E988);
            abi.setRegNz(&rt.r[0], 0xB0);
            abi.setRegNz(&rt.r[1], 0x8);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!hw.drawDispatchCall(0x0806E96B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806E98C);
            if (!proc.allocProcSlotCall(0x0806E971)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806E990);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0806E985)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0806F0CC() callconv(.c) void {
    if (!abi.enter(0x0806F0CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0806F0E8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x36, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.r[1] = abi.read32(0x0806F108);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(low_peel_13.func_0806EFC4, 0x0806F103)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_17.func_0806EF38, 0x0806F0E5)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0806F538() callconv(.c) void {
    if (!abi.enter(0x0806F538)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0806F550);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(low_peel_17.func_0806F1A8, 0x0806F559)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            continue :blk 6;
        },
        4 => {
            abi.fetches(3);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_17.func_0806F448, 0x0806F55F)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806FD00() callconv(.c) void {
    if (!abi.enter(0x0806FD00)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806FD28);
            abi.setRegNz(&rt.r[1], 0x4);
            if (!proc.spawnProcCall(0x0806FD1F)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], rt.r[4], true);
            continue :blk 0;
        },
        else => unreachable,
    }
}

pub fn func_0806FD2C() callconv(.c) void {
    if (!abi.enter(0x0806FD2C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0806FD44);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(low_peel_13.func_0806FC1C, 0x0806FD4D)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            continue :blk 6;
        },
        4 => {
            abi.fetches(3);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_17.func_0806FA80, 0x0806FD53)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806FD58() callconv(.c) void {
    if (!abi.enter(0x0806FD58)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0806FD6C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(func_0806FD2C, 0x0806FD75)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(func_0806F538, 0x0806FD6B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08070248() callconv(.c) void {
    if (!abi.enter(0x08070248)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(ui.func_0806A8E4, 0x0807024F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070264);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(low_peel_13.func_0806EB34, 0x0807025B)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08070268);
            if (!proc.killProcByCallbackCall(0x08070261)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08070604() callconv(.c) void {
    if (!abi.enter(0x08070604)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[7], rt.r[7] << 7);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            continue :blk 2;
        },
        2 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[4] +% 0x34);
            rt.r[1] = abi.read32(rt.r[4] +% 0x38);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[4] +% 0x34, rt.r[0]);
            rt.r[1] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[4] +% 0x24, rt.r[1]);
            rt.cpuSub(null, rt.r[1], 0xF0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070638);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08070623)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070638);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08070631)) return;
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08070606() callconv(.c) void {
    if (!abi.enter(0x08070606)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[4] +% 0x34);
            rt.r[1] = abi.read32(rt.r[4] +% 0x38);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[4] +% 0x34, rt.r[0]);
            rt.r[1] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[4] +% 0x24, rt.r[1]);
            rt.cpuSub(null, rt.r[1], 0xF0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070638);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08070623)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070638);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08070631)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08070608() callconv(.c) void {
    if (!abi.enter(0x08070608)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[4] +% 0x34);
            rt.r[1] = abi.read32(rt.r[4] +% 0x38);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[4] +% 0x34, rt.r[0]);
            rt.r[1] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[4] +% 0x24, rt.r[1]);
            rt.cpuSub(null, rt.r[1], 0xF0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070638);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08070623)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070638);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08070631)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08070B5C() callconv(.c) void {
    if (!abi.enter(0x08070B5C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            abi.pushLr();
            rt.r[2] = abi.read32(0x08070B80);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], 0x10, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070B84);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08070B7B)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08070ED0() callconv(.c) void {
    if (!abi.enter(0x08070ED0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(tail_low.func_080796A4, 0x08070ED9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(hw.func_080112C0, 0x08070EDD)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x44, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070EF8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08070EF3)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08070F98() callconv(.c) void {
    if (!abi.enter(0x08070F98)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            abi.pushLr();
            rt.r[1] = abi.read32(0x08070FC8);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x44, true);
            rt.r[3] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(0x08070FCC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x3);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[3], 0x1, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070FD0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08070FC5)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08070FD8() callconv(.c) void {
    if (!abi.enter(0x08070FD8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[3]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xC8);
            if (!abi.call(low_peel_8.func_0803D8C8, 0x08070FF5)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08071000);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08070FFD)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08071A24() callconv(.c) void {
    if (!abi.enter(0x08071A24)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08071A60);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(17);
            rt.r[0] = abi.read32(0x08071A64);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(0x08071A68);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[1] = abi.read32(0x08071A6C);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08071A70);
            rt.r[0] = abi.read32(rt.r[2] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x18, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08071A74);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08071A5B)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08071A78() callconv(.c) void {
    if (!abi.enter(0x08071A78)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[1] = abi.read32(0x08071AAC);
            rt.r[0] = abi.read32(0x08071AB0);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 2));
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x08071AB4);
            rt.r[0] = abi.read32(0x08071AB8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x34);
            if (!abi.call(low_peel_2.func_0806CE28, 0x08071AA3)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08071ABC);
            if (!abi.call(func_0806CD78, 0x08071AA9)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08071AC0() callconv(.c) void {
    if (!abi.enter(0x08071AC0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08071AF8);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 2));
            abi.setRegNz(&rt.r[0], 0x70);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08071AFC);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x08071B00);
            rt.r[0] = abi.read32(0x08071B04);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x6C);
            if (!abi.call(low_peel_2.func_0806CE28, 0x08071AED)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08071B08);
            if (!abi.call(func_0806CD78, 0x08071AF3)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08071B0C() callconv(.c) void {
    if (!abi.enter(0x08071B0C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08071B40);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 2));
            rt.r[0] = abi.read32(0x08071B44);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[2] = abi.read32(0x08071B48);
            rt.r[0] = abi.read32(0x08071B4C);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xA0);
            if (!abi.call(low_peel_2.func_0806CE28, 0x08071B37)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08071B50);
            if (!abi.call(func_0806CD78, 0x08071B3D)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08072144() callconv(.c) void {
    if (!abi.enter(0x08072144)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x34);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            rt.r[2] = abi.read32(0x08072174);
            abi.setRegNz(&rt.r[3], 0xB8);
            abi.setRegNz(&rt.r[3], rt.r[3] << 7);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!hw.drawDispatchCall(0x08072159)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x44, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08072178);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0807216F)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08072CC0() callconv(.c) void {
    if (!abi.enter(0x08072CC0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            abi.pushLr();
            rt.r[2] = abi.read32(rt.r[0] +% 0x30);
            rt.r[1] = abi.read32(rt.r[0] +% 0x34);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            abi.write32(rt.r[0] +% 0x30, rt.r[2]);
            rt.r[1] = abi.read32(0x08072CE0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[0] +% 0x38);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08072CE4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08072CDD)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080732BC() callconv(.c) void {
    if (!abi.enter(0x080732BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(19);
            rt.r[1] = abi.read32(0x080732F8);
            abi.setRegNz(&rt.r[0], 0x21);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080732FC);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x44, true);
            abi.setRegNz(&rt.r[0], 0x10);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08073300);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x080732F3)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08073304() callconv(.c) void {
    if (!abi.enter(0x08073304)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            abi.pushLr();
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[2] = abi.read32(0x08073328);
            abi.setRegNz(&rt.r[0], 0x10);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0807332C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08073325)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08073330() callconv(.c) void {
    if (!abi.enter(0x08073330)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08073358);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x0807335C);
            abi.setRegNz(&rt.r[0], 0x21);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08073360);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08073355)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080738A0() callconv(.c) void {
    if (!abi.enter(0x080738A0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(tail_low.func_080796A4, 0x080738A9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(hw.func_080112C0, 0x080738AD)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x44, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080738C8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x080738C3)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08073B14() callconv(.c) void {
    if (!abi.enter(0x08073B14)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08073B30);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x9);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08073B34);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08073B2D)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08073C68() callconv(.c) void {
    if (!abi.enter(0x08073C68)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08073C84);
            if (!abi.call(func_0806CB80, 0x08073C71)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x48, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08073C88() callconv(.c) void {
    if (!abi.enter(0x08073C88)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08073CA4);
            if (!abi.call(func_0806CB80, 0x08073C91)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x48, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08073D80() callconv(.c) void {
    if (!abi.enter(0x08073D80)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[0] = abi.read32(rt.r[0] +% 0x20);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4E, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 2));
            rt.cpuSub(null, rt.r[2], 0x4, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x08073DB4);
            abi.setRegNz(&rt.r[0], 0x4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08073DB8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xC, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08073DBC);
            abi.setRegNz(&rt.r[1], 0x7F);
            if (!abi.call(low_peel_6.func_08015824, 0x08073DAF)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08073E84() callconv(.c) void {
    if (!abi.enter(0x08073E84)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08073EBC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_13.func_08073DC0, 0x08073E99)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x44, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x20);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08073EC0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08073EB5)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080745C0() callconv(.c) void {
    if (!abi.enter(0x080745C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[3], rt.r[2] >> 24);
            rt.cpuSub(null, rt.r[3], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(16);
            rt.r[2] = abi.read32(0x080745F0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x1, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x10, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08074980() callconv(.c) void {
    if (!abi.enter(0x08074980)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0807499C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08074999)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08074C4C() callconv(.c) void {
    if (!abi.enter(0x08074C4C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x44, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.r[4] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08074C80);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08074C67)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(tail_low.func_080796A4, 0x08074C75)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(hw.func_080112C0, 0x08074C79)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08074D40() callconv(.c) void {
    if (!abi.enter(0x08074D40)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x44, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.r[4] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08074D74);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08074D5B)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(tail_low.func_080796A4, 0x08074D69)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(hw.func_080112C0, 0x08074D6D)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08076898() callconv(.c) void {
    if (!abi.enter(0x08076898)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x080768B0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x34, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[1] +% 0x34, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.write32(rt.r[1] +% 0x34, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            abi.write32(rt.r[1] +% 0x38, rt.r[0]);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08077034() callconv(.c) void {
    if (!abi.enter(0x08077034)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0807704C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x36, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(low_peel_13.func_08076F1C, 0x08077055)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_13.func_08076E58, 0x0807704B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08077058() callconv(.c) void {
    if (!abi.enter(0x08077058)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0807707C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x36, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_9.func_08076D2C, 0x0807706F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(func_08077034, 0x08077073)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(low_peel_13.func_08076D94, 0x08077077)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08077344() callconv(.c) void {
    if (!abi.enter(0x08077344)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08077374);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1F);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[0]);
            rt.cpuSub(null, rt.r[3], 0xF, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(16);
            rt.r[2] = abi.read32(0x08077378);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xA, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 10);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xA, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[1], 0xA4);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(hw.func_080112C0, 0x08077371)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[3], rt.r[0], rt.r[3], true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807750C() callconv(.c) void {
    if (!abi.enter(0x0807750C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08077520);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            if (!sound.playSfxCall(0x71, 0x0807752B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            if (!sound.playSfxCall(0x66, 0x0807751D)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(low_peel_9.func_08076384, 0x0807752F)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_9.func_08076778, 0x08077533)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(ui.func_08076934, 0x08077537)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080779F0() callconv(.c) void {
    if (!abi.enter(0x080779F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[3] = abi.read32(rt.r[0] +% 0x2C);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[0] +% 0x34);
            rt.r[2] = abi.read32(rt.r[0] +% 0x30);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        3 => {
            abi.fetches(4);
            abi.write32(rt.r[2] +% 0x34, rt.r[1]);
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.write32(rt.r[3] +% 0x20, rt.r[1]);
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            abi.write32(rt.r[1] +% 0x30, rt.r[2]);
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write32(rt.r[0] +% 0x2C, rt.r[1]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08077A10() callconv(.c) void {
    if (!abi.enter(0x08077A10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[4] = abi.read32(rt.r[5] +% 0x20);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(6);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xC7);
            rt.updateNz(rt.r[0] & rt.r[1]);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x40);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[1]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_080779F0, 0x08077A2F)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[4] = abi.read32(rt.r[4] +% 0x34);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08077BC0() callconv(.c) void {
    if (!abi.enter(0x08077BC0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[12] = rt.r[14];
            if (!abi.call(low_peel_2.func_08077A74, 0x08077BC7)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x18);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            decls.awre_cpu_bx(rt.r[12]); return;
        },
        3 => {
            abi.fetches(7);
            abi.write8(rt.r[1] +% 0x18, @truncate(rt.r[3]));
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[2], 0xF);
            abi.setRegNz(&rt.r[3], rt.r[3] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08077EF4() callconv(.c) void {
    if (!abi.enter(0x08077EF4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            rt.r[1] = abi.read8(rt.r[4] +% 0x12);
            abi.setRegNz(&rt.r[0], 0x14);
            rt.r[2] = rt.sext8(abi.read8(rt.r[4] +% rt.r[0]));
            abi.setRegNz(&rt.r[3], 0x80);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[2], true);
            abi.setRegNz(&rt.r[3], rt.r[3] *% rt.r[1]);
            rt.r[0] = abi.read8(rt.r[5] +% 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0xFF);
            continue :blk 2;
        },
        2 => {
            abi.fetches(11);
            abi.write8(rt.r[4] +% 0x2, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[3], 0x7F);
            rt.cpuSub(&rt.r[3], rt.r[3], rt.r[2], true);
            abi.setRegNz(&rt.r[3], rt.r[3] *% rt.r[1]);
            rt.r[0] = abi.read8(rt.r[5] +% 0x11);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0xFF);
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            abi.write8(rt.r[4] +% 0x3, @truncate(rt.r[0]));
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_080783BC() callconv(.c) void {
    if (!abi.enter(0x080783BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[2] = abi.read32(0x080783E8);
            rt.r[1] = abi.read32(0x080783EC);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 13);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(clusters_low_2.func_08078A9C, 0x080783E3)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080783F0() callconv(.c) void {
    if (!abi.enter(0x080783F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[2] = abi.read32(0x0807841C);
            rt.r[1] = abi.read32(0x08078420);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 13);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(low_peel_2.func_0807821C, 0x08078417)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0807845C() callconv(.c) void {
    if (!abi.enter(0x0807845C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x08078480);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            rt.r[5] = abi.read32(0x08078484);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(low_peel_2.func_0807821C, 0x08078473)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0xC, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080791B4() callconv(.c) void {
    if (!abi.enter(0x080791B4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[3] = abi.read32(rt.r[2] +% 0x34);
            rt.r[0] = abi.read32(0x080791D8);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(8);
            abi.write16(rt.r[2] +% 0x1E, @truncate(rt.r[1]));
            rt.r[4] = abi.read16(rt.r[2] +% 0x1C);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            abi.write16(rt.r[2] +% 0x20, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080798D0() callconv(.c) void {
    if (!abi.enter(0x080798D0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 7, 14 });
            rt.r[7] = rt.r[13];
            rt.r[0] = abi.read32(0x08079900);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x08079900);
            rt.r[0] = abi.read32(0x08079900);
            rt.r[1] = abi.read32(0x08079900);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[1], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08079904);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08079908() callconv(.c) void {
    if (!abi.enter(0x08079908)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 7, 14 });
            rt.r[13] -%= 0x8;
            rt.r[7] = rt.r[13];
            abi.write32(rt.r[7] +% 0x4, rt.r[1]);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(18);
            rt.r[0] = abi.read32(0x08079940);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(0x08079944);
            rt.r[1] = abi.read32(0x08079940);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 2);
            rt.r[3] = abi.read32(0x08079948);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[3], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.r[0] = abi.read32(rt.r[7] +% 0x4);
            rt.r[1] = abi.read32(0x0807994C);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08079BB0() callconv(.c) void {
    if (!abi.enter(0x08079BB0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 7, 14 });
            rt.r[13] -%= 0xC;
            rt.r[7] = rt.r[13];
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            abi.write32(rt.r[7] +% 0x4, rt.r[1]);
            abi.write32(rt.r[7] +% 0x8, rt.r[2]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[7] +% 0x8);
            rt.cpuSub(&rt.r[1], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write32(rt.r[7] +% 0x8, rt.r[0]);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuAdd(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            continue :blk 4;
        },
        3 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x4, true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(rt.r[7] +% 0x0);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.write32(rt.r[7] +% 0x0, rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            continue :blk 1;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08079F92() callconv(.c) void {
    if (!abi.enter(0x08079F92)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08079FDC);
            rt.r[1] = abi.read32(rt.r[7] +% 0x8);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[2], 0xFF);
            if (!abi.call(tail_low.func_0807B458, 0x08079FA1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(22);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4C, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08079FC8);
            rt.r[1] = abi.read32(0x08079FC8);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            rt.r[3] = abi.read32(0x08079FCC);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[3]);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x3);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[3]);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4C, true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[13] +%= 0x50;
            popRegsSeq(&.{ 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08079FE8() callconv(.c) void {
    if (!abi.enter(0x08079FE8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(28);
            pushRegs(&.{ 7, 14 });
            rt.r[13] -%= 0x8;
            rt.r[7] = rt.r[13];
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            abi.write32(rt.r[7] +% 0x4, rt.r[1]);
            rt.r[0] = abi.read32(0x0807A024);
            abi.setRegNz(&rt.r[1], 0xAA);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0807A028);
            abi.setRegNz(&rt.r[1], 0x55);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0807A024);
            abi.setRegNz(&rt.r[1], 0xA0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[7] +% 0x4);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(0x0807A02C);
            rt.r[1] = abi.read32(rt.r[7] +% 0x4);
            rt.r[3] = abi.read32(rt.r[7] +% 0x0);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(tail_low.func_0807B458, 0x0807A01D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807A248() callconv(.c) void {
    if (!abi.enter(0x0807A248)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 7, 14 });
            rt.r[13] -%= 0x8;
            rt.r[7] = rt.r[13];
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            rt.r[1] = abi.read32(0x0807A260);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x4);
            abi.write32(rt.r[7] +% 0x4, rt.r[1]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[7] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            continue :blk 6;
        },
        4 => {
            abi.fetches(3);
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[7] +% 0x4);
            rt.cpuSub(&rt.r[1], rt.r[0], 0x1, true);
            abi.write32(rt.r[7] +% 0x4, rt.r[1]);
            continue :blk 1;
        },
        6 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[7] +% 0x4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807A288() callconv(.c) void {
    if (!abi.enter(0x0807A288)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 7, 14 });
            rt.r[13] -%= 0x8;
            rt.r[7] = rt.r[13];
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            abi.write32(rt.r[7] +% 0x4, rt.r[1]);
            rt.r[1] = abi.read32(rt.r[7] +% 0x4);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            if (!abi.call(tail_low.func_0807B450, 0x0807A29B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0807A2A4);
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807A84C() callconv(.c) void {
    if (!abi.enter(0x0807A84C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0807A87C() callconv(.c) void {
    if (!abi.enter(0x0807A87C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(7);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0807A8A0() callconv(.c) void {
    if (!abi.enter(0x0807A8A0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0807ACC4() callconv(.c) void {
    if (!abi.enter(0x0807ACC4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x0807ACD8);
            if (!abi.call(low_peel_9.func_0807CC94, 0x0807ACCF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_0807CDEC, 0x0807ACE3)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807AF40() callconv(.c) void {
    if (!abi.enter(0x0807AF40)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[2] = abi.read32(rt.r[0] +% 0xC);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 4;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xC, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], rt.r[3], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0807AFF4() callconv(.c) void {
    if (!abi.enter(0x0807AFF4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            abi.write32(rt.r[0] +% 0x4, rt.r[2]);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[3]));
            abi.write8(rt.r[0] +% 0x2, @truncate(rt.r[2]));
            abi.write32(rt.r[0] +% 0xC, rt.r[1]);
            abi.write32(rt.r[0] +% 0x8, rt.r[1]);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0807B034() callconv(.c) void {
    if (!abi.enter(0x0807B034)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[3] = abi.read32(rt.r[1] +% 0x4);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            popRegsSeq(&.{ 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0xFE);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(low_peel_2.func_0807B018, 0x0807B055)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[3] +% 0x4);
            abi.write32(rt.r[1] +% 0x4, rt.r[0]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            continue :blk 3;
        },
        7 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0807B068() callconv(.c) void {
    if (!abi.enter(0x0807B068)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            if (!abi.call(func_0807AF40, 0x0807B075)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_13.func_0807AF64, 0x0807B089)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5, 6, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        5 => {
            abi.fetches(3);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0807B13C() callconv(.c) void {
    if (!abi.enter(0x0807B13C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[1] = abi.read32(rt.r[0] +% 0x4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[0] +% 0xC);
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0xC);
            if (!math.divUnsigned32Call(0x0807B14F)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            popRegsSeq(&.{ 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0807B2B0() callconv(.c) void {
    if (!abi.enter(0x0807B2B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[0] = abi.read8(rt.r[3] +% 0x2);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.r[2] = abi.read32(rt.r[3] +% 0x8);
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            popRegsSeq(&.{ 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(rt.r[2] +% 0x4);
            continue :blk 4;
        },
        7 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[3] +% 0xC);
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0xC);
            if (!math.divUnsigned32Call(0x0807B2DB)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0807B3C0() callconv(.c) void {
    if (!abi.enter(0x0807B3C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[1] = abi.read32(0x0807B3E4);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x4, true);
            abi.write32(rt.r[4] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(tail_low.func_0807B44C, 0x0807B3DB)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0807B434() callconv(.c) void {
    if (!abi.enter(0x0807B434)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0807B448);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            popRegsSeq(&.{ 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            if (!abi.call(low_peel_9.func_0807B3E8, 0x0807B447)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0807C474() callconv(.c) void {
    if (!abi.enter(0x0807C474)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.r[13] -%= 0x1C;
            abi.write32(rt.r[13] +% 0x14, rt.r[0]);
            abi.write32(rt.r[13] +% 0x18, rt.r[1]);
            rt.r[0] = rt.r[13] +% 0x14;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C485)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            rt.r[0] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807B76C, 0x0807C497)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            rt.r[13] +%= 0x1C;
            popRegsSeq(&.{ 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807CDEC() callconv(.c) void {
    if (!abi.enter(0x0807CDEC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[13] -%= 0x14;
            abi.write32(rt.r[13] +% 0x10, rt.r[0]);
            rt.r[0] = rt.r[13] +% 0x10;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CDFB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            rt.r[0] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807C508, 0x0807CE0D)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            rt.r[13] +%= 0x14;
            popRegsSeq(&.{ 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807CE54() callconv(.c) void {
    if (!abi.enter(0x0807CE54)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5, 6, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuAdd(&rt.r[3], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.armLsr(rt.r[3], rt.r[0] & 0xFF));
            continue :blk 5;
        },
        4 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.armLsl(rt.r[1], rt.r[0] & 0xFF));
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.armLsr(rt.r[4], rt.r[2] & 0xFF));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.armLsr(rt.r[0], rt.r[2] & 0xFF));
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] | rt.r[1]);
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0807CEF8() callconv(.c) void {
    if (!abi.enter(0x0807CEF8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.cpuSub(&rt.r[2], 0, rt.r[0], true);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        2 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            continue :blk 1;
        },
        else => unreachable,
    }
}

comptime {
    if (!builtin.is_test) {
        @export(&func_080438E4, .{ .name = "func_080438E4", .linkage = .strong });
        @export(&func_08043E80, .{ .name = "func_08043E80", .linkage = .strong });
        @export(&func_08043EB8, .{ .name = "func_08043EB8", .linkage = .strong });
        @export(&func_080443AC, .{ .name = "func_080443AC", .linkage = .strong });
        @export(&func_0804486C, .{ .name = "func_0804486C", .linkage = .strong });
        @export(&func_08044B6C, .{ .name = "func_08044B6C", .linkage = .strong });
        @export(&func_08044E34, .{ .name = "func_08044E34", .linkage = .strong });
        @export(&func_080451DC, .{ .name = "func_080451DC", .linkage = .strong });
        @export(&func_08046DB8, .{ .name = "func_08046DB8", .linkage = .strong });
        @export(&func_0804781C, .{ .name = "func_0804781C", .linkage = .strong });
        @export(&func_080478EC, .{ .name = "func_080478EC", .linkage = .strong });
        @export(&func_08047FCC, .{ .name = "func_08047FCC", .linkage = .strong });
        @export(&func_080487D8, .{ .name = "func_080487D8", .linkage = .strong });
        @export(&func_08048814, .{ .name = "func_08048814", .linkage = .strong });
        @export(&func_08048A28, .{ .name = "func_08048A28", .linkage = .strong });
        @export(&func_08048DCC, .{ .name = "func_08048DCC", .linkage = .strong });
        @export(&func_08048E4C, .{ .name = "func_08048E4C", .linkage = .strong });
        @export(&func_08048E68, .{ .name = "func_08048E68", .linkage = .strong });
        @export(&func_0804910C, .{ .name = "func_0804910C", .linkage = .strong });
        @export(&func_080491A4, .{ .name = "func_080491A4", .linkage = .strong });
        @export(&func_080494C4, .{ .name = "func_080494C4", .linkage = .strong });
        @export(&func_0804B4B0, .{ .name = "func_0804B4B0", .linkage = .strong });
        @export(&func_0804C1B8, .{ .name = "func_0804C1B8", .linkage = .strong });
        @export(&func_0804C1D4, .{ .name = "func_0804C1D4", .linkage = .strong });
        @export(&func_0804C1F0, .{ .name = "func_0804C1F0", .linkage = .strong });
        @export(&func_0804C39C, .{ .name = "func_0804C39C", .linkage = .strong });
        @export(&func_0804C5CC, .{ .name = "func_0804C5CC", .linkage = .strong });
        @export(&func_0804C668, .{ .name = "func_0804C668", .linkage = .strong });
        @export(&func_0804CC98, .{ .name = "func_0804CC98", .linkage = .strong });
        @export(&func_0804CCE0, .{ .name = "func_0804CCE0", .linkage = .strong });
        @export(&func_0804D848, .{ .name = "func_0804D848", .linkage = .strong });
        @export(&func_0804D864, .{ .name = "func_0804D864", .linkage = .strong });
        @export(&func_0804D894, .{ .name = "func_0804D894", .linkage = .strong });
        @export(&func_0804E068, .{ .name = "func_0804E068", .linkage = .strong });
        @export(&func_0804ED98, .{ .name = "func_0804ED98", .linkage = .strong });
        @export(&func_0804EFD8, .{ .name = "func_0804EFD8", .linkage = .strong });
        @export(&func_0804F1F8, .{ .name = "func_0804F1F8", .linkage = .strong });
        @export(&func_0804F6E8, .{ .name = "func_0804F6E8", .linkage = .strong });
        @export(&func_0804F734, .{ .name = "func_0804F734", .linkage = .strong });
        @export(&func_0804F8F4, .{ .name = "func_0804F8F4", .linkage = .strong });
        @export(&func_0804F8FA, .{ .name = "func_0804F8FA", .linkage = .strong });
        @export(&func_0804FCF0, .{ .name = "func_0804FCF0", .linkage = .strong });
        @export(&func_080500F2, .{ .name = "func_080500F2", .linkage = .strong });
        @export(&func_080500F4, .{ .name = "func_080500F4", .linkage = .strong });
        @export(&func_080500F8, .{ .name = "func_080500F8", .linkage = .strong });
        @export(&func_080500FA, .{ .name = "func_080500FA", .linkage = .strong });
        @export(&func_08050102, .{ .name = "func_08050102", .linkage = .strong });
        @export(&func_080502FE, .{ .name = "func_080502FE", .linkage = .strong });
        @export(&func_08050300, .{ .name = "func_08050300", .linkage = .strong });
        @export(&func_08050302, .{ .name = "func_08050302", .linkage = .strong });
        @export(&func_08050304, .{ .name = "func_08050304", .linkage = .strong });
        @export(&func_0805030C, .{ .name = "func_0805030C", .linkage = .strong });
        @export(&func_08050358, .{ .name = "func_08050358", .linkage = .strong });
        @export(&func_08050374, .{ .name = "func_08050374", .linkage = .strong });
        @export(&func_08050502, .{ .name = "func_08050502", .linkage = .strong });
        @export(&func_08050504, .{ .name = "func_08050504", .linkage = .strong });
        @export(&func_08050508, .{ .name = "func_08050508", .linkage = .strong });
        @export(&func_080505EC, .{ .name = "func_080505EC", .linkage = .strong });
        @export(&func_08050634, .{ .name = "func_08050634", .linkage = .strong });
        @export(&func_08050C34, .{ .name = "func_08050C34", .linkage = .strong });
        @export(&func_08050CFE, .{ .name = "func_08050CFE", .linkage = .strong });
        @export(&func_08051888, .{ .name = "func_08051888", .linkage = .strong });
        @export(&func_0805277C, .{ .name = "func_0805277C", .linkage = .strong });
        @export(&func_080575DE, .{ .name = "func_080575DE", .linkage = .strong });
        @export(&func_0805A018, .{ .name = "func_0805A018", .linkage = .strong });
        @export(&func_0805AE44, .{ .name = "func_0805AE44", .linkage = .strong });
        @export(&func_0805DBCC, .{ .name = "func_0805DBCC", .linkage = .strong });
        @export(&func_0805DD00, .{ .name = "func_0805DD00", .linkage = .strong });
        @export(&func_0805F1F8, .{ .name = "func_0805F1F8", .linkage = .strong });
        @export(&func_0805F22C, .{ .name = "func_0805F22C", .linkage = .strong });
        @export(&func_0805FAE8, .{ .name = "func_0805FAE8", .linkage = .strong });
        @export(&func_0805FCEE, .{ .name = "func_0805FCEE", .linkage = .strong });
        @export(&func_0805FE00, .{ .name = "func_0805FE00", .linkage = .strong });
        @export(&func_08060806, .{ .name = "func_08060806", .linkage = .strong });
        @export(&func_08060808, .{ .name = "func_08060808", .linkage = .strong });
        @export(&func_0806080A, .{ .name = "func_0806080A", .linkage = .strong });
        @export(&func_08060816, .{ .name = "func_08060816", .linkage = .strong });
        @export(&func_08061DA0, .{ .name = "func_08061DA0", .linkage = .strong });
        @export(&func_080625CC, .{ .name = "func_080625CC", .linkage = .strong });
        @export(&func_08062ECC, .{ .name = "func_08062ECC", .linkage = .strong });
        @export(&func_080631F0, .{ .name = "func_080631F0", .linkage = .strong });
        @export(&func_08063324, .{ .name = "func_08063324", .linkage = .strong });
        @export(&func_08066B48, .{ .name = "func_08066B48", .linkage = .strong });
        @export(&func_08067650, .{ .name = "func_08067650", .linkage = .strong });
        @export(&func_08068164, .{ .name = "func_08068164", .linkage = .strong });
        @export(&func_08068548, .{ .name = "func_08068548", .linkage = .strong });
        @export(&func_08068584, .{ .name = "func_08068584", .linkage = .strong });
        @export(&func_080688CC, .{ .name = "func_080688CC", .linkage = .strong });
        @export(&func_08069F44, .{ .name = "func_08069F44", .linkage = .strong });
        @export(&func_08069F90, .{ .name = "func_08069F90", .linkage = .strong });
        @export(&func_0806A174, .{ .name = "func_0806A174", .linkage = .strong });
        @export(&func_0806A300, .{ .name = "func_0806A300", .linkage = .strong });
        @export(&func_0806A368, .{ .name = "func_0806A368", .linkage = .strong });
        @export(&func_0806A45C, .{ .name = "func_0806A45C", .linkage = .strong });
        @export(&func_0806B01C, .{ .name = "func_0806B01C", .linkage = .strong });
        @export(&func_0806C02C, .{ .name = "func_0806C02C", .linkage = .strong });
        @export(&func_0806C0F4, .{ .name = "func_0806C0F4", .linkage = .strong });
        @export(&func_0806C12C, .{ .name = "func_0806C12C", .linkage = .strong });
        @export(&func_0806C27C, .{ .name = "func_0806C27C", .linkage = .strong });
        @export(&func_0806C494, .{ .name = "func_0806C494", .linkage = .strong });
        @export(&func_0806C8D0, .{ .name = "func_0806C8D0", .linkage = .strong });
        @export(&func_0806CAF0, .{ .name = "func_0806CAF0", .linkage = .strong });
        @export(&func_0806CB50, .{ .name = "func_0806CB50", .linkage = .strong });
        @export(&func_0806CB80, .{ .name = "func_0806CB80", .linkage = .strong });
        @export(&func_0806CBAC, .{ .name = "func_0806CBAC", .linkage = .strong });
        @export(&func_0806CBE8, .{ .name = "func_0806CBE8", .linkage = .strong });
        @export(&func_0806CD78, .{ .name = "func_0806CD78", .linkage = .strong });
        @export(&func_0806CDD0, .{ .name = "func_0806CDD0", .linkage = .strong });
        @export(&func_0806CEF8, .{ .name = "func_0806CEF8", .linkage = .strong });
        @export(&func_0806D80C, .{ .name = "func_0806D80C", .linkage = .strong });
        @export(&func_0806D9C0, .{ .name = "func_0806D9C0", .linkage = .strong });
        @export(&func_0806DF10, .{ .name = "func_0806DF10", .linkage = .strong });
        @export(&func_0806E2E4, .{ .name = "func_0806E2E4", .linkage = .strong });
        @export(&func_0806E2E8, .{ .name = "func_0806E2E8", .linkage = .strong });
        @export(&func_0806E480, .{ .name = "func_0806E480", .linkage = .strong });
        @export(&func_0806E8B0, .{ .name = "func_0806E8B0", .linkage = .strong });
        @export(&func_0806E95C, .{ .name = "func_0806E95C", .linkage = .strong });
        @export(&func_0806F0CC, .{ .name = "func_0806F0CC", .linkage = .strong });
        @export(&func_0806F538, .{ .name = "func_0806F538", .linkage = .strong });
        @export(&func_0806FD00, .{ .name = "func_0806FD00", .linkage = .strong });
        @export(&func_0806FD2C, .{ .name = "func_0806FD2C", .linkage = .strong });
        @export(&func_0806FD58, .{ .name = "func_0806FD58", .linkage = .strong });
        @export(&func_08070248, .{ .name = "func_08070248", .linkage = .strong });
        @export(&func_08070604, .{ .name = "func_08070604", .linkage = .strong });
        @export(&func_08070606, .{ .name = "func_08070606", .linkage = .strong });
        @export(&func_08070608, .{ .name = "func_08070608", .linkage = .strong });
        @export(&func_08070B5C, .{ .name = "func_08070B5C", .linkage = .strong });
        @export(&func_08070ED0, .{ .name = "func_08070ED0", .linkage = .strong });
        @export(&func_08070F98, .{ .name = "func_08070F98", .linkage = .strong });
        @export(&func_08070FD8, .{ .name = "func_08070FD8", .linkage = .strong });
        @export(&func_08071A24, .{ .name = "func_08071A24", .linkage = .strong });
        @export(&func_08071A78, .{ .name = "func_08071A78", .linkage = .strong });
        @export(&func_08071AC0, .{ .name = "func_08071AC0", .linkage = .strong });
        @export(&func_08071B0C, .{ .name = "func_08071B0C", .linkage = .strong });
        @export(&func_08072144, .{ .name = "func_08072144", .linkage = .strong });
        @export(&func_08072CC0, .{ .name = "func_08072CC0", .linkage = .strong });
        @export(&func_080732BC, .{ .name = "func_080732BC", .linkage = .strong });
        @export(&func_08073304, .{ .name = "func_08073304", .linkage = .strong });
        @export(&func_08073330, .{ .name = "func_08073330", .linkage = .strong });
        @export(&func_080738A0, .{ .name = "func_080738A0", .linkage = .strong });
        @export(&func_08073B14, .{ .name = "func_08073B14", .linkage = .strong });
        @export(&func_08073C68, .{ .name = "func_08073C68", .linkage = .strong });
        @export(&func_08073C88, .{ .name = "func_08073C88", .linkage = .strong });
        @export(&func_08073D80, .{ .name = "func_08073D80", .linkage = .strong });
        @export(&func_08073E84, .{ .name = "func_08073E84", .linkage = .strong });
        @export(&func_080745C0, .{ .name = "func_080745C0", .linkage = .strong });
        @export(&func_08074980, .{ .name = "func_08074980", .linkage = .strong });
        @export(&func_08074C4C, .{ .name = "func_08074C4C", .linkage = .strong });
        @export(&func_08074D40, .{ .name = "func_08074D40", .linkage = .strong });
        @export(&func_08076898, .{ .name = "func_08076898", .linkage = .strong });
        @export(&func_08077034, .{ .name = "func_08077034", .linkage = .strong });
        @export(&func_08077058, .{ .name = "func_08077058", .linkage = .strong });
        @export(&func_08077344, .{ .name = "func_08077344", .linkage = .strong });
        @export(&func_0807750C, .{ .name = "func_0807750C", .linkage = .strong });
        @export(&func_080779F0, .{ .name = "func_080779F0", .linkage = .strong });
        @export(&func_08077A10, .{ .name = "func_08077A10", .linkage = .strong });
        @export(&func_08077BC0, .{ .name = "func_08077BC0", .linkage = .strong });
        @export(&func_08077EF4, .{ .name = "func_08077EF4", .linkage = .strong });
        @export(&func_080783BC, .{ .name = "func_080783BC", .linkage = .strong });
        @export(&func_080783F0, .{ .name = "func_080783F0", .linkage = .strong });
        @export(&func_0807845C, .{ .name = "func_0807845C", .linkage = .strong });
        @export(&func_080791B4, .{ .name = "func_080791B4", .linkage = .strong });
        @export(&func_080798D0, .{ .name = "func_080798D0", .linkage = .strong });
        @export(&func_08079908, .{ .name = "func_08079908", .linkage = .strong });
        @export(&func_08079BB0, .{ .name = "func_08079BB0", .linkage = .strong });
        @export(&func_08079F92, .{ .name = "func_08079F92", .linkage = .strong });
        @export(&func_08079FE8, .{ .name = "func_08079FE8", .linkage = .strong });
        @export(&func_0807A248, .{ .name = "func_0807A248", .linkage = .strong });
        @export(&func_0807A288, .{ .name = "func_0807A288", .linkage = .strong });
        @export(&func_0807A84C, .{ .name = "func_0807A84C", .linkage = .strong });
        @export(&func_0807A87C, .{ .name = "func_0807A87C", .linkage = .strong });
        @export(&func_0807A8A0, .{ .name = "func_0807A8A0", .linkage = .strong });
        @export(&func_0807ACC4, .{ .name = "func_0807ACC4", .linkage = .strong });
        @export(&func_0807AF40, .{ .name = "func_0807AF40", .linkage = .strong });
        @export(&func_0807AFF4, .{ .name = "func_0807AFF4", .linkage = .strong });
        @export(&func_0807B034, .{ .name = "func_0807B034", .linkage = .strong });
        @export(&func_0807B068, .{ .name = "func_0807B068", .linkage = .strong });
        @export(&func_0807B13C, .{ .name = "func_0807B13C", .linkage = .strong });
        @export(&func_0807B2B0, .{ .name = "func_0807B2B0", .linkage = .strong });
        @export(&func_0807B3C0, .{ .name = "func_0807B3C0", .linkage = .strong });
        @export(&func_0807B434, .{ .name = "func_0807B434", .linkage = .strong });
        @export(&func_0807C474, .{ .name = "func_0807C474", .linkage = .strong });
        @export(&func_0807CDEC, .{ .name = "func_0807CDEC", .linkage = .strong });
        @export(&func_0807CE54, .{ .name = "func_0807CE54", .linkage = .strong });
        @export(&func_0807CEF8, .{ .name = "func_0807CEF8", .linkage = .strong });
    }
}

test "low_peel_5 exports are callable" {
    try std.testing.expect(@TypeOf(func_080438E4) == fn () callconv(.c) void);
    try std.testing.expect(@TypeOf(func_0807CEF8) == fn () callconv(.c) void);
}
