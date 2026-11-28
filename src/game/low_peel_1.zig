//! Low-ROM (`< 0x08080000`) block-peeled wave 1 (`<= 30` reachable lines, first 185).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const dma = @import("dma.zig");
const hw = @import("hw.zig");
const low_peel_10 = @import("low_peel_10.zig");
const low_peel_3 = @import("low_peel_3.zig");
const low_peel_6 = @import("low_peel_6.zig");
const sprite_anim = @import("sprite_anim.zig");

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

pub fn func_080001FC() callconv(.c) void {
    if (!abi.enter(0x080001FC)) return;
    abi.fetches(8);
    rt.r[1] = abi.read32(0x08000208);
    rt.r[1] = abi.read32(rt.r[1] +% 0x0);
    abi.write16(rt.r[1] +% 0x4, @truncate(rt.r[0]));
    abi.setRegNz(&rt.r[0], 0x1);
    abi.write8(rt.r[1] +% 0x6, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080002E0() callconv(.c) void {
    if (!abi.enter(0x080002E0)) return;
    abi.fetches(3);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080002E4() callconv(.c) void {
    if (!abi.enter(0x080002E4)) return;
    abi.fetches(7);
    rt.r[0] = abi.read32(0x080002F0);
    rt.r[1] = abi.read32(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[0], 0x1);
    abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08000406() callconv(.c) void {
    if (!abi.enter(0x08000406)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x50);
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xA);
            abi.write32(rt.r[2] +% 0xC, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08000908() callconv(.c) void {
    if (!abi.enter(0x08000908)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[4], 0x8);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[4]));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read32(0x0800092C);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            if (!abi.call(low_peel_10.func_08000948, 0x0800091D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
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

pub fn func_08000930() callconv(.c) void {
    if (!abi.enter(0x08000930)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[2], 0x8);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[2]));
            abi.setRegNz(&rt.r[4], 0xA);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[4]));
            if (!abi.call(low_peel_3.func_0800875C, 0x0800093D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(low_peel_10.func_08000948, 0x08000941)) return;
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

pub fn func_080009FC() callconv(.c) void {
    if (!abi.enter(0x080009FC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08000A14);
            abi.setRegNz(&rt.r[2], 0x8C);
            abi.setRegNz(&rt.r[2], rt.r[2] << 3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(dma.func_0800FFA8, 0x08000A07)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08000A02() callconv(.c) void {
    if (!abi.enter(0x08000A02)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            if (!abi.call(dma.func_0800FFA8, 0x08000A07)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08000D34() callconv(.c) void {
    if (!abi.enter(0x08000D34)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        3 => {
            abi.fetches(7);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08000DF6() callconv(.c) void {
    if (!abi.enter(0x08000DF6)) return;
    abi.fetches(5);
    popRegsSeq(&.{ 4, 5, 6 });
    popRegsSeq(&.{ 1 });
    rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
}

pub fn func_08001170() callconv(.c) void {
    if (!abi.enter(0x08001170)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[3], rt.r[0] << 7);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xE4);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08001904() callconv(.c) void {
    if (!abi.enter(0x08001904)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(0x0800190C);
            abi.setRegNz(&rt.r[0], 0xE);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800198C() callconv(.c) void {
    if (!abi.enter(0x0800198C)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(0x08001998);
    rt.r[0] = abi.read32(rt.r[0] +% 0x0);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x4C, true);
    abi.setRegNz(&rt.r[1], 0xA);
    abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0800199C() callconv(.c) void {
    if (!abi.enter(0x0800199C)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(0x080019A8);
    rt.r[0] = abi.read32(rt.r[0] +% 0x0);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x4C, true);
    abi.setRegNz(&rt.r[1], 0x0);
    abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08002E64() callconv(.c) void {
    if (!abi.enter(0x08002E64)) return;
    abi.fetches(17);
    rt.r[2] = abi.read32(0x08002E84);
    rt.r[0] = abi.read32(rt.r[2] +% 0x0);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x72, true);
    abi.setRegNz(&rt.r[1], 0x0);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(rt.r[2] +% 0x0);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x73, true);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(rt.r[2] +% 0x0);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x74, true);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(rt.r[2] +% 0x0);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x75, true);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08003434() callconv(.c) void {
    if (!abi.enter(0x08003434)) return;
    abi.fetches(6);
    rt.r[10] = rt.r[5];
    popRegsSeq(&.{ 4, 5, 6, 7 });
    popRegsSeq(&.{ 0 });
    rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
}

pub fn func_080036F0() callconv(.c) void {
    if (!abi.enter(0x080036F0)) return;
    abi.fetches(9);
    rt.r[0] = abi.read32(0x08003700);
    rt.r[1] = abi.read32(rt.r[0] +% 0x0);
    rt.r[0] = abi.read32(0x08003704);
    rt.r[2] = abi.read16(rt.r[1] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08003742() callconv(.c) void {
    if (!abi.enter(0x08003742)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[4], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x08003760);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(func_08013BD0, 0x08003753)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[4]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080075C4() callconv(.c) void {
    if (!abi.enter(0x080075C4)) return;
    abi.fetches(7);
    rt.r[1] = abi.read32(0x080075D0);
    rt.r[1] = abi.read32(rt.r[1] +% 0x0);
    rt.cpuAdd(&rt.r[1], rt.r[1], 0x2F, true);
    abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0800997A() callconv(.c) void {
    if (!abi.enter(0x0800997A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0xC, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[7], rt.r[7], 0x1, true);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800C2C8() callconv(.c) void {
    if (!abi.enter(0x0800C2C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[1], 0x1F);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x6, true);
            rt.cpuSub(null, rt.r[0], 0x8, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x0800C2E0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x0800C30C => continue :blk 4,
                0x0800C30E => continue :blk 2,
                0x0800C308 => continue :blk 3,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.recompReturn(rt.r[14]); return;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[2], 0x2);
            continue :blk 2;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0800E38E() callconv(.c) void {
    if (!abi.enter(0x0800E38E)) return;
    abi.fetches(10);
    abi.setRegNz(&rt.r[0], 0x0);
    popRegsSeq(&.{ 3, 4, 5 });
    rt.r[8] = rt.r[3];
    rt.r[9] = rt.r[4];
    rt.r[10] = rt.r[5];
    popRegsSeq(&.{ 4, 5, 6, 7 });
    popRegsSeq(&.{ 1 });
    rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
}

pub fn func_0800E5B0() callconv(.c) void {
    if (!abi.enter(0x0800E5B0)) return;
    abi.fetches(5);
    popRegsSeq(&.{ 4, 5, 6, 7 });
    popRegsSeq(&.{ 1 });
    rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
}

pub fn func_0800F1B0() callconv(.c) void {
    if (!abi.enter(0x0800F1B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(hw.func_0800F170, 0x0800F1B7)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x0800F1D0);
            abi.setRegNz(&rt.r[0], 0xC0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0800F1D4);
            abi.setRegNz(&rt.r[0], 0x1F);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(low_peel_6.func_08010974, 0x0800F1CB)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800F4E4() callconv(.c) void {
    if (!abi.enter(0x0800F4E4)) return;
    abi.fetches(14);
    rt.r[0] = abi.read32(0x0800F4FC);
    abi.setRegNz(&rt.r[1], 0x0);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(0x0800F500);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[1] = abi.read32(0x0800F504);
    abi.setRegNz(&rt.r[0], 0xF0);
    abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.r[1] = abi.read32(0x0800F508);
    abi.setRegNz(&rt.r[0], 0xA0);
    abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0800F5FA() callconv(.c) void {
    if (!abi.enter(0x0800F5FA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0800F614);
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], 0x21);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[2] +% 0x8, rt.r[0]);
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

pub fn func_0800F5FC() callconv(.c) void {
    if (!abi.enter(0x0800F5FC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0800F614);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], 0x21);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[2] +% 0x8, rt.r[0]);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800F600() callconv(.c) void {
    if (!abi.enter(0x0800F600)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], 0x21);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[2] +% 0x8, rt.r[0]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800F61A() callconv(.c) void {
    if (!abi.enter(0x0800F61A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            if (!abi.call(low_peel_3.func_0800FBEC, 0x0800F61F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800F802() callconv(.c) void {
    if (!abi.enter(0x0800F802)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0800F814);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(low_peel_6.func_08013248, 0x0800F80D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800F8F0() callconv(.c) void {
    if (!abi.enter(0x0800F8F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800FB06() callconv(.c) void {
    if (!abi.enter(0x0800FB06)) return;
    abi.fetches(4);
    popRegsSeq(&.{ 0 });
    rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
}

pub fn func_0800FBF8() callconv(.c) void {
    if (!abi.enter(0x0800FBF8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0800FC14);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 14));
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[4]);
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

pub fn func_0800FBFA() callconv(.c) void {
    if (!abi.enter(0x0800FBFA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 14));
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[4]);
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

pub fn func_0800FBFC() callconv(.c) void {
    if (!abi.enter(0x0800FBFC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 14));
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[4]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080103AC() callconv(.c) void {
    if (!abi.enter(0x080103AC)) return;
    abi.fetches(7);
    rt.r[2] = abi.read32(0x080103B8);
    abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
    rt.r[0] = abi.read32(0x080103BC);
    abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08010406() callconv(.c) void {
    if (!abi.enter(0x08010406)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801040A() callconv(.c) void {
    if (!abi.enter(0x0801040A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08010968() callconv(.c) void {
    if (!abi.enter(0x08010968)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(hw.func_08010544, 0x0801096F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            popRegsSeq(&.{ 0 });
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08010A78() callconv(.c) void {
    if (!abi.enter(0x08010A78)) return;
    abi.fetches(5);
    rt.r[1] = abi.read32(0x08010A80);
    abi.write32(rt.r[1] +% 0x0, rt.r[0]);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08010CC4() callconv(.c) void {
    if (!abi.enter(0x08010CC4)) return;
    abi.fetches(12);
    abi.setRegNz(&rt.r[1], rt.r[1] >> 11);
    abi.setRegNz(&rt.r[2], 0x1F);
    abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
    abi.setRegNz(&rt.r[2], 0x20);
    rt.cpuSub(&rt.r[2], 0, rt.r[2], true);
    rt.r[3] = abi.read8(rt.r[0] +% 0x1);
    abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[3]);
    abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[1]);
    abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[2]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08010CD8() callconv(.c) void {
    if (!abi.enter(0x08010CD8)) return;
    abi.fetches(13);
    abi.setRegNz(&rt.r[1], rt.r[1] >> 14);
    abi.setRegNz(&rt.r[2], 0x3);
    abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
    abi.setRegNz(&rt.r[1], rt.r[1] << 2);
    abi.setRegNz(&rt.r[2], 0xD);
    rt.cpuSub(&rt.r[2], 0, rt.r[2], true);
    rt.r[3] = abi.read8(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[3]);
    abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[1]);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08010CF0() callconv(.c) void {
    if (!abi.enter(0x08010CF0)) return;
    abi.fetches(9);
    abi.setRegNz(&rt.r[1], rt.r[1] << 6);
    abi.setRegNz(&rt.r[2], 0x3F);
    rt.r[3] = abi.read8(rt.r[0] +% 0x1);
    abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[3]);
    abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[1]);
    abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[2]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08010F28() callconv(.c) void {
    if (!abi.enter(0x08010F28)) return;
    abi.fetches(18);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
    abi.setRegNz(&rt.r[1], rt.r[1] << 16);
    abi.setRegNz(&rt.r[2], rt.r[2] << 16);
    abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
    rt.r[3] = abi.read32(0x08010F48);
    abi.setRegNz(&rt.r[1], rt.r[1] >> 11);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    abi.setRegNz(&rt.r[0], rt.r[0] << 1);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
    abi.setRegNz(&rt.r[3], 0xC0);
    abi.setRegNz(&rt.r[3], rt.r[3] << 8);
    rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
    abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[1]);
    abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08011140() callconv(.c) void {
    if (!abi.enter(0x08011140)) return;
    abi.fetches(5);
    pushRegs(&.{ 2, 3 });
    rt.r[13] +%= 0x8;
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080117E0() callconv(.c) void {
    if (!abi.enter(0x080117E0)) return;
    abi.fetches(6);
    rt.r[1] = abi.read32(0x080117E8);
    abi.setRegNz(&rt.r[0], 0x0);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080117EC() callconv(.c) void {
    if (!abi.enter(0x080117EC)) return;
    abi.fetches(11);
    abi.setRegNz(&rt.r[0], rt.r[0] << 24);
    abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
    rt.r[2] = abi.read32(0x08011800);
    abi.setRegNz(&rt.r[1], 0x1);
    abi.setRegNz(&rt.r[1], rt.armLsl(rt.r[1], rt.r[0] & 0xFF));
    rt.r[0] = abi.read16(rt.r[2] +% 0x0);
    abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
    abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08011804() callconv(.c) void {
    if (!abi.enter(0x08011804)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(0x08011810);
    rt.r[1] = abi.read16(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[2], 0x1);
    abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
    abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08011814() callconv(.c) void {
    if (!abi.enter(0x08011814)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(0x08011820);
    rt.r[1] = abi.read16(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[2], 0x2);
    abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
    abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08011824() callconv(.c) void {
    if (!abi.enter(0x08011824)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(0x08011830);
    rt.r[1] = abi.read16(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[2], 0x4);
    abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
    abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08011834() callconv(.c) void {
    if (!abi.enter(0x08011834)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(0x08011840);
    rt.r[1] = abi.read16(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[2], 0x8);
    abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
    abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080119C4() callconv(.c) void {
    if (!abi.enter(0x080119C4)) return;
    abi.fetches(13);
    rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
    rt.r[0] = abi.read8(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[2], rt.r[0] << 1);
    rt.r[0] = abi.read32(rt.r[1] +% 0x28);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
    rt.cpuAdd(&rt.r[1], rt.r[1], 0x33, true);
    rt.r[1] = abi.read8(rt.r[1] +% 0x0);
    abi.setRegNz(&rt.r[1], rt.r[1] << 6);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080119DC() callconv(.c) void {
    if (!abi.enter(0x080119DC)) return;
    abi.fetches(13);
    rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x30, true);
    rt.r[0] = abi.read8(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[2], rt.r[0] << 1);
    rt.r[0] = abi.read32(rt.r[1] +% 0x28);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
    rt.cpuAdd(&rt.r[1], rt.r[1], 0x31, true);
    rt.r[1] = abi.read8(rt.r[1] +% 0x0);
    abi.setRegNz(&rt.r[1], rt.r[1] << 6);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08011C6C() callconv(.c) void {
    if (!abi.enter(0x08011C6C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read16(rt.r[1] +% 0x1E);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x1E, @truncate(rt.r[0]));
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(3);
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08012064() callconv(.c) void {
    if (!abi.enter(0x08012064)) return;
    abi.fetches(12);
    rt.r[2] = abi.read16(rt.r[0] +% 0x34);
    rt.r[3] = abi.read16(rt.r[0] +% 0x2C);
    rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.cpuAdd(&rt.r[1], rt.r[1], 0x40, true);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
    abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[3]);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[2]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080124F8() callconv(.c) void {
    if (!abi.enter(0x080124F8)) return;
    abi.fetches(4);
    abi.setRegNz(&rt.r[0], 0x0);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08012830() callconv(.c) void {
    if (!abi.enter(0x08012830)) return;
    abi.fetches(3);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08013310() callconv(.c) void {
    if (!abi.enter(0x08013310)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            rt.r[2] = abi.read32(0x08013328);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08013770() callconv(.c) void {
    if (!abi.enter(0x08013770)) return;
    abi.fetches(16);
    rt.r[3] = abi.read32(0x0801378C);
    rt.r[2] = abi.read32(0x08013790);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
    abi.setRegNz(&rt.r[1], rt.r[0] << 1);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
    abi.setRegNz(&rt.r[1], rt.r[1] << 5);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
    abi.setRegNz(&rt.r[0], 0x4C);
    rt.r[1] = abi.read16(rt.r[1] +% 0x26);
    abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
    rt.r[0] = abi.read16(rt.r[0] +% 0x3C);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080137C0() callconv(.c) void {
    if (!abi.enter(0x080137C0)) return;
    abi.fetches(16);
    rt.r[3] = abi.read32(0x080137DC);
    rt.r[2] = abi.read32(0x080137E0);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
    abi.setRegNz(&rt.r[1], rt.r[0] << 1);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
    abi.setRegNz(&rt.r[1], rt.r[1] << 5);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
    abi.setRegNz(&rt.r[0], 0x4C);
    rt.r[1] = abi.read16(rt.r[1] +% 0x26);
    abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
    rt.r[0] = abi.read16(rt.r[0] +% 0x3E);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080138A4() callconv(.c) void {
    if (!abi.enter(0x080138A4)) return;
    abi.fetches(18);
    rt.r[3] = abi.read32(0x080138C4);
    rt.r[2] = abi.read32(0x080138C8);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
    abi.setRegNz(&rt.r[1], rt.r[0] << 1);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
    abi.setRegNz(&rt.r[1], rt.r[1] << 5);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
    abi.setRegNz(&rt.r[0], 0x4C);
    rt.r[1] = abi.read16(rt.r[1] +% 0x26);
    abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
    abi.setRegNz(&rt.r[1], 0x0);
    rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08013BD0() callconv(.c) void {
    if (!abi.enter(0x08013BD0)) return;
    abi.fetches(13);
    abi.setRegNz(&rt.r[0], rt.r[0] << 24);
    abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
    rt.r[2] = abi.read32(0x08013BE8);
    abi.setRegNz(&rt.r[1], rt.r[0] << 1);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
    abi.setRegNz(&rt.r[1], rt.r[1] << 5);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x8, true);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
    abi.setRegNz(&rt.r[0], 0x0);
    abi.write32(rt.r[1] +% 0x0, rt.r[0]);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080157E4() callconv(.c) void {
    if (!abi.enter(0x080157E4)) return;
    abi.fetches(3);
    rt.r[13] -%= 0x4;
    low_peel_6.func_080157E6(); return;
}

pub fn func_08015A6C() callconv(.c) void {
    if (!abi.enter(0x08015A6C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08015A80);
            rt.r[2] = abi.read32(0x08015A84);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08015FD4() callconv(.c) void {
    if (!abi.enter(0x08015FD4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08015FE4);
            rt.r[1] = abi.read32(0x08015FE8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08015FF0() callconv(.c) void {
    if (!abi.enter(0x08015FF0)) return;
    abi.fetches(9);
    rt.r[2] = abi.read32(0x08016000);
    rt.r[1] = abi.read32(0x08016004);
    rt.r[0] = abi.read32(rt.r[1] +% 0x10);
    abi.write32(rt.r[2] +% 0x0, rt.r[0]);
    rt.r[0] = abi.read32(rt.r[1] +% 0x14);
    abi.write32(rt.r[2] +% 0x4, rt.r[0]);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08016934() callconv(.c) void {
    if (!abi.enter(0x08016934)) return;
    abi.fetches(3);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08016938() callconv(.c) void {
    if (!abi.enter(0x08016938)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[2] = abi.read32(0x08016948);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.r[0] = abi.read32(0x0801694C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08016990() callconv(.c) void {
    if (!abi.enter(0x08016990)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(0x080169A0);
            rt.r[0] = abi.read32(rt.r[2] +% 0x10);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_C) {
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
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[2] +% 0x10, rt.r[0]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08016F0C() callconv(.c) void {
    if (!abi.enter(0x08016F0C)) return;
    abi.fetches(6);
    rt.r[1] = abi.read32(0x08016F14);
    abi.setRegNz(&rt.r[0], 0x1);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08016F24() callconv(.c) void {
    if (!abi.enter(0x08016F24)) return;
    abi.fetches(6);
    rt.r[0] = abi.read32(0x08016F2C);
    abi.setRegNz(&rt.r[1], 0x0);
    rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080172E4() callconv(.c) void {
    if (!abi.enter(0x080172E4)) return;
    abi.fetches(6);
    rt.r[1] = abi.read32(0x080172EC);
    abi.setRegNz(&rt.r[0], 0x1);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08017E98() callconv(.c) void {
    if (!abi.enter(0x08017E98)) return;
    abi.fetches(15);
    rt.r[2] = abi.read32(0x08017EB4);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
    abi.setRegNz(&rt.r[1], rt.r[0] << 1);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
    abi.setRegNz(&rt.r[1], rt.r[1] << 3);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
    rt.r[0] = abi.read32(rt.r[1] +% 0x0);
    rt.r[0] = abi.read32(rt.r[0] +% 0x4);
    abi.write32(rt.r[1] +% 0x0, rt.r[0]);
    abi.setRegNz(&rt.r[0], 0x1);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080183A8() callconv(.c) void {
    if (!abi.enter(0x080183A8)) return;
    abi.fetches(12);
    rt.r[2] = abi.read32(0x080183BC);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
    abi.setRegNz(&rt.r[1], rt.r[0] << 1);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
    abi.setRegNz(&rt.r[1], rt.r[1] << 3);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
    abi.setRegNz(&rt.r[0], 0x0);
    abi.write32(rt.r[1] +% 0x0, rt.r[0]);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08018614() callconv(.c) void {
    if (!abi.enter(0x08018614)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08018628);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
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
            if (!abi.call(sprite_anim.func_080124D4, 0x08018623)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08018E04() callconv(.c) void {
    if (!abi.enter(0x08018E04)) return;
    abi.fetches(6);
    rt.r[1] = abi.read32(0x08018E0C);
    abi.setRegNz(&rt.r[0], 0x0);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08018E10() callconv(.c) void {
    if (!abi.enter(0x08018E10)) return;
    abi.fetches(7);
    abi.setRegNz(&rt.r[0], rt.r[0] << 24);
    abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
    rt.r[1] = abi.read32(0x08018E1C);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08018E20() callconv(.c) void {
    if (!abi.enter(0x08018E20)) return;
    abi.fetches(6);
    rt.r[1] = abi.read32(0x08018E28);
    rt.r[0] = abi.read8(rt.r[1] +% 0x2);
    abi.write8(rt.r[1] +% 0x3, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08018E2C() callconv(.c) void {
    if (!abi.enter(0x08018E2C)) return;
    abi.fetches(6);
    rt.r[1] = abi.read32(0x08018E34);
    rt.r[0] = abi.read8(rt.r[1] +% 0x3);
    abi.write8(rt.r[1] +% 0x2, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08018E38() callconv(.c) void {
    if (!abi.enter(0x08018E38)) return;
    abi.fetches(9);
    rt.r[1] = abi.read32(0x08018E48);
    abi.setRegNz(&rt.r[0], 0x21);
    rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
    rt.r[2] = abi.read8(rt.r[1] +% 0x1);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
    abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08019058() callconv(.c) void {
    if (!abi.enter(0x08019058)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0xBA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x08019070);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801A250() callconv(.c) void {
    if (!abi.enter(0x0801A250)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
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
            rt.r[0] = abi.read32(0x0801A268);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801AFD0() callconv(.c) void {
    if (!abi.enter(0x0801AFD0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801B7F4() callconv(.c) void {
    if (!abi.enter(0x0801B7F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801B80C() callconv(.c) void {
    if (!abi.enter(0x0801B80C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0xFF);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801BD04() callconv(.c) void {
    if (!abi.enter(0x0801BD04)) return;
    abi.fetches(12);
    rt.r[2] = abi.read32(0x0801BD18);
    rt.r[1] = abi.read32(0x0801BD1C);
    rt.r[3] = abi.read32(rt.r[1] +% 0x0);
    abi.setRegNz(&rt.r[1], 0x68);
    abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
    rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
    rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
    rt.r[0] = abi.read8(rt.r[2] +% 0x0);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0801BD20() callconv(.c) void {
    if (!abi.enter(0x0801BD20)) return;
    abi.fetches(4);
    rt.r[0] = abi.read32(0x0801BD24);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0801FB00() callconv(.c) void {
    if (!abi.enter(0x0801FB00)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0xD0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], rt.r[2] << 4);
            if (!abi.call(dma.func_0800FDA4, 0x0801FB09)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801FB02() callconv(.c) void {
    if (!abi.enter(0x0801FB02)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], rt.r[2] << 4);
            if (!abi.call(dma.func_0800FDA4, 0x0801FB09)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08020304() callconv(.c) void {
    if (!abi.enter(0x08020304)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x0802032C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x81);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.setRegNz(&rt.r[2], 0x1E);
            if (!abi.call(dma.func_08011374, 0x08020315)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
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

pub fn func_0802030C() callconv(.c) void {
    if (!abi.enter(0x0802030C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.setRegNz(&rt.r[2], 0x1E);
            if (!abi.call(dma.func_08011374, 0x08020315)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
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

pub fn func_080210C6() callconv(.c) void {
    if (!abi.enter(0x080210C6)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x080210EC);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.r[3] = abi.read16(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            abi.write16(rt.r[5] +% 0x2, @truncate(rt.r[2]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08022898() callconv(.c) void {
    if (!abi.enter(0x08022898)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x080228AC);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3E, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
            abi.write8(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080238B0() callconv(.c) void {
    if (!abi.enter(0x080238B0)) return;
    abi.fetches(3);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08024124() callconv(.c) void {
    if (!abi.enter(0x08024124)) return;
    abi.fetches(3);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08024B4C() callconv(.c) void {
    if (!abi.enter(0x08024B4C)) return;
    abi.fetches(3);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08026482() callconv(.c) void {
    if (!abi.enter(0x08026482)) return;
    abi.fetches(5);
    popRegsSeq(&.{ 4, 5, 6, 7 });
    popRegsSeq(&.{ 0 });
    rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
}

pub fn func_08027F6C() callconv(.c) void {
    if (!abi.enter(0x08027F6C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[0] = abi.read32(rt.r[0] +% 0x18);
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
            if (!abi.call(low_peel_10.func_08018984, 0x08027F79)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08028714() callconv(.c) void {
    if (!abi.enter(0x08028714)) return;
    abi.fetches(14);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
    rt.r[2] = abi.read32(0x0802872C);
    rt.r[3] = abi.read32(rt.r[2] +% 0x0);
    abi.setRegNz(&rt.r[2], 0x68);
    abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
    rt.r[2] = abi.read32(0x08028730);
    rt.r[2] = abi.read16(rt.r[2] +% 0x0);
    abi.write16(rt.r[0] +% 0x14, @truncate(rt.r[2]));
    abi.write8(rt.r[0] +% 0x12, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08028B80() callconv(.c) void {
    if (!abi.enter(0x08028B80)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(0x08028B94);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0xD, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08028B98);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0xD);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08029F26() callconv(.c) void {
    if (!abi.enter(0x08029F26)) return;
    abi.fetches(9);
    popRegsSeq(&.{ 3, 4, 5 });
    rt.r[8] = rt.r[3];
    rt.r[9] = rt.r[4];
    rt.r[10] = rt.r[5];
    popRegsSeq(&.{ 4, 5, 6, 7 });
    popRegsSeq(&.{ 1 });
    rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
}

pub fn func_0802A314() callconv(.c) void {
    if (!abi.enter(0x0802A314)) return;
    abi.fetches(13);
    rt.r[2] = abi.read32(0x0802A32C);
    rt.r[0] = abi.read32(0x0802A330);
    abi.setRegNz(&rt.r[3], 0x0);
    rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
    abi.setRegNz(&rt.r[0], rt.r[1] << 1);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    abi.setRegNz(&rt.r[0], rt.r[0] << 5);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
    abi.setRegNz(&rt.r[1], 0x1);
    abi.write16(rt.r[0] +% 0x38, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0802AA86() callconv(.c) void {
    if (!abi.enter(0x0802AA86)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.r[2] = abi.read32(0x0802AAA4);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x18, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[4]);
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

pub fn func_0802BB2C() callconv(.c) void {
    if (!abi.enter(0x0802BB2C)) return;
    abi.fetches(9);
    rt.r[2] = abi.read32(0x0802BB3C);
    rt.r[1] = abi.read32(0x0802BB40);
    rt.r[0] = abi.read16(rt.r[1] +% 0x0);
    abi.write8(rt.r[2] +% 0x10, @truncate(rt.r[0]));
    rt.r[0] = abi.read16(rt.r[1] +% 0x2);
    abi.write8(rt.r[2] +% 0x11, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0802C680() callconv(.c) void {
    if (!abi.enter(0x0802C680)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0802C68C);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802C980() callconv(.c) void {
    if (!abi.enter(0x0802C980)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], 0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0802C988);
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802C998() callconv(.c) void {
    if (!abi.enter(0x0802C998)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 1, 4, 5, 14 });
            abi.setRegNz(&rt.r[0], 0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0802C9A4);
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802D6E4() callconv(.c) void {
    if (!abi.enter(0x0802D6E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 2, 14 });
            abi.setRegNz(&rt.r[0], 0);
            pushRegs(&.{ 2, 3, 7 });
            abi.setRegNz(&rt.r[0], 0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802D6F4() callconv(.c) void {
    if (!abi.enter(0x0802D6F4)) return;
    abi.fetches(9);
    rt.r[2] = abi.read32(0x0802D704);
    rt.r[1] = abi.read32(0x0802D708);
    rt.r[0] = abi.read16(rt.r[1] +% 0x0);
    abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
    rt.r[0] = abi.read16(rt.r[1] +% 0x2);
    abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0802D70C() callconv(.c) void {
    if (!abi.enter(0x0802D70C)) return;
    abi.fetches(9);
    rt.r[2] = abi.read32(0x0802D71C);
    rt.r[1] = abi.read32(0x0802D720);
    rt.r[0] = abi.read16(rt.r[1] +% 0x0);
    abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
    rt.r[0] = abi.read16(rt.r[1] +% 0x2);
    abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0802D768() callconv(.c) void {
    if (!abi.enter(0x0802D768)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802D774);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x3, true);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802D7A0() callconv(.c) void {
    if (!abi.enter(0x0802D7A0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802D7B0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802D7B8() callconv(.c) void {
    if (!abi.enter(0x0802D7B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802D7C8);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802D7D0() callconv(.c) void {
    if (!abi.enter(0x0802D7D0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802D7DC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[0], 0x74, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802D7E4() callconv(.c) void {
    if (!abi.enter(0x0802D7E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            rt.r[2] = abi.read32(0x0802D7FC);
            rt.r[1] = abi.read32(0x0802D800);
            rt.r[3] = abi.read8(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[3] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1E);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802D91C() callconv(.c) void {
    if (!abi.enter(0x0802D91C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802D928);
            rt.r[0] = abi.read8(rt.r[0] +% 0xC);
            rt.cpuSub(null, rt.r[0], 0x1, true);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802D930() callconv(.c) void {
    if (!abi.enter(0x0802D930)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802D93C);
            rt.r[0] = abi.read8(rt.r[0] +% 0xC);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802FDF2() callconv(.c) void {
    if (!abi.enter(0x0802FDF2)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802FDF4() callconv(.c) void {
    if (!abi.enter(0x0802FDF4)) return;
    abi.fetches(4);
    popRegsSeq(&.{ 0 });
    rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
}

pub fn func_0802FEA8() callconv(.c) void {
    if (!abi.enter(0x0802FEA8)) return;
    abi.fetches(16);
    rt.r[0] = abi.read32(0x0802FEC4);
    abi.setRegNz(&rt.r[2], 0x0);
    abi.write32(rt.r[0] +% 0x0, rt.r[2]);
    rt.r[3] = abi.read32(0x0802FEC8);
    rt.r[0] = abi.read32(rt.r[3] +% 0x0);
    abi.setRegNz(&rt.r[1], 0x4);
    rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    abi.write32(rt.r[3] +% 0x0, rt.r[0]);
    rt.r[0] = abi.read32(0x0802FECC);
    abi.write32(rt.r[0] +% 0x0, rt.r[2]);
    rt.r[0] = abi.read32(0x0802FED0);
    abi.write32(rt.r[0] +% 0x0, rt.r[2]);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08030000() callconv(.c) void {
    if (!abi.enter(0x08030000)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5 });
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            popRegsSeq(&.{ 1 });
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08030002() callconv(.c) void {
    if (!abi.enter(0x08030002)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            popRegsSeq(&.{ 1 });
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08030010() callconv(.c) void {
    if (!abi.enter(0x08030010)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x0803002C);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            rt.r[1] = abi.read32(0x08030030);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0803001E() callconv(.c) void {
    if (!abi.enter(0x0803001E)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08030098() callconv(.c) void {
    if (!abi.enter(0x08030098)) return;
    abi.fetches(9);
    rt.r[1] = abi.read32(0x080300A8);
    rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
    abi.setRegNz(&rt.r[0], 0xC3);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08030810() callconv(.c) void {
    if (!abi.enter(0x08030810)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0803081C() callconv(.c) void {
    if (!abi.enter(0x0803081C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x08030834);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], rt.armAsr(rt.r[1], rt.r[0] & 0xFF));
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_080308AC() callconv(.c) void {
    if (!abi.enter(0x080308AC)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(0x080308B8);
    rt.r[0] = abi.read32(rt.r[0] +% 0x0);
    rt.r[0] = abi.read8(rt.r[0] +% 0x6);
    abi.setRegNz(&rt.r[0], rt.r[0] << 24);
    abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08030A0A() callconv(.c) void {
    if (!abi.enter(0x08030A0A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
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

pub fn func_08030AFC() callconv(.c) void {
    if (!abi.enter(0x08030AFC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3, 4, 5 });
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

pub fn func_080316B4() callconv(.c) void {
    if (!abi.enter(0x080316B4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080316C4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08031870() callconv(.c) void {
    if (!abi.enter(0x08031870)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(0x0803187C);
    rt.r[1] = abi.read32(rt.r[0] +% 0x0);
    rt.r[0] = abi.read16(rt.r[1] +% 0x4);
    abi.setRegNz(&rt.r[0], 0x5);
    abi.write16(rt.r[1] +% 0x4, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08031936() callconv(.c) void {
    if (!abi.enter(0x08031936)) return;
    abi.fetches(13);
    rt.r[1] = abi.read32(rt.r[2] +% 0x0);
    rt.r[0] = abi.read8(rt.r[1] +% 0x1);
    abi.setRegNz(&rt.r[0], 0x1);
    abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
    rt.r[1] = abi.read32(rt.r[2] +% 0x0);
    rt.r[0] = abi.read16(rt.r[1] +% 0x4);
    abi.setRegNz(&rt.r[0], 0x6);
    abi.write16(rt.r[1] +% 0x4, @truncate(rt.r[0]));
    popRegsSeq(&.{ 4 });
    popRegsSeq(&.{ 0 });
    rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
}

pub fn func_08033094() callconv(.c) void {
    if (!abi.enter(0x08033094)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x10);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08035000() callconv(.c) void {
    if (!abi.enter(0x08035000)) return;
    abi.fetches(3);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080351E8() callconv(.c) void {
    if (!abi.enter(0x080351E8)) return;
    abi.fetches(6);
    rt.r[1] = abi.read32(0x080351F0);
    abi.setRegNz(&rt.r[0], 0x11);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0803525C() callconv(.c) void {
    if (!abi.enter(0x0803525C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08035270);
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
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08035A3C() callconv(.c) void {
    if (!abi.enter(0x08035A3C)) return;
    abi.fetches(12);
    rt.r[2] = abi.read32(0x08035A50);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
    abi.setRegNz(&rt.r[1], 0x1);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    abi.setRegNz(&rt.r[0], rt.r[0] << 1);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
    abi.setRegNz(&rt.r[1], 0x0);
    rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08035ABC() callconv(.c) void {
    if (!abi.enter(0x08035ABC)) return;
    abi.fetches(12);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
    rt.r[2] = abi.read32(0x08035AD0);
    abi.setRegNz(&rt.r[1], rt.r[0] << 3);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
    abi.setRegNz(&rt.r[1], rt.r[1] << 2);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x14, true);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
    rt.r[0] = abi.read32(rt.r[1] +% 0x0);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08035C3C() callconv(.c) void {
    if (!abi.enter(0x08035C3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08035C4C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036006() callconv(.c) void {
    if (!abi.enter(0x08036006)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.write8(rt.r[5] +% 0x8, @truncate(rt.r[0]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036918() callconv(.c) void {
    if (!abi.enter(0x08036918)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036928);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0803692C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036938);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0803693C() callconv(.c) void {
    if (!abi.enter(0x0803693C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0803694C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036950);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0803695C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036960() callconv(.c) void {
    if (!abi.enter(0x08036960)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036970);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036974);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036980);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_080369B0() callconv(.c) void {
    if (!abi.enter(0x080369B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080369C0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x080369C4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080369D0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_080369D4() callconv(.c) void {
    if (!abi.enter(0x080369D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080369E4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x080369E8);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080369F4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036A10() callconv(.c) void {
    if (!abi.enter(0x08036A10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036A20);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036A24);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036A30);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036A60() callconv(.c) void {
    if (!abi.enter(0x08036A60)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036A70);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036A74);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036A80);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036A9C() callconv(.c) void {
    if (!abi.enter(0x08036A9C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036AAC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036AB0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036ABC);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036AC0() callconv(.c) void {
    if (!abi.enter(0x08036AC0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036AD0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036AD4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036AE0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036AF0() callconv(.c) void {
    if (!abi.enter(0x08036AF0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036B00);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036B04);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036B10);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036B14() callconv(.c) void {
    if (!abi.enter(0x08036B14)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036B24);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036B28);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036B34);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036B8C() callconv(.c) void {
    if (!abi.enter(0x08036B8C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036B9C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036BA0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036BAC);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036BB0() callconv(.c) void {
    if (!abi.enter(0x08036BB0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036BC0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036BC4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036BD0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036BD4() callconv(.c) void {
    if (!abi.enter(0x08036BD4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036BE4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036BE8);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036BF4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036BF8() callconv(.c) void {
    if (!abi.enter(0x08036BF8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036C08);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036C0C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036C18);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036C1C() callconv(.c) void {
    if (!abi.enter(0x08036C1C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036C2C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036C30);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036C3C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036C40() callconv(.c) void {
    if (!abi.enter(0x08036C40)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036C50);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036C54);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036C60);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036CDC() callconv(.c) void {
    if (!abi.enter(0x08036CDC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036CEC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036CF0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036CFC);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036D00() callconv(.c) void {
    if (!abi.enter(0x08036D00)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036D10);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036D14);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036D20);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036D24() callconv(.c) void {
    if (!abi.enter(0x08036D24)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036D34);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036D38);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036D44);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036D48() callconv(.c) void {
    if (!abi.enter(0x08036D48)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036D58);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036D5C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036D68);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036D6C() callconv(.c) void {
    if (!abi.enter(0x08036D6C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036D7C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036D80);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036D8C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036D90() callconv(.c) void {
    if (!abi.enter(0x08036D90)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036DA0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036DA4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036DB0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08036DB4() callconv(.c) void {
    if (!abi.enter(0x08036DB4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036DC4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036DC8);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036DD4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

comptime {
    if (!builtin.is_test) {
        @export(&func_080001FC, .{ .name = "func_080001FC", .linkage = .strong });
        @export(&func_080002E0, .{ .name = "func_080002E0", .linkage = .strong });
        @export(&func_080002E4, .{ .name = "func_080002E4", .linkage = .strong });
        @export(&func_08000406, .{ .name = "func_08000406", .linkage = .strong });
        @export(&func_08000908, .{ .name = "func_08000908", .linkage = .strong });
        @export(&func_08000930, .{ .name = "func_08000930", .linkage = .strong });
        @export(&func_080009FC, .{ .name = "func_080009FC", .linkage = .strong });
        @export(&func_08000A02, .{ .name = "func_08000A02", .linkage = .strong });
        @export(&func_08000D34, .{ .name = "func_08000D34", .linkage = .strong });
        @export(&func_08000DF6, .{ .name = "func_08000DF6", .linkage = .strong });
        @export(&func_08001170, .{ .name = "func_08001170", .linkage = .strong });
        @export(&func_08001904, .{ .name = "func_08001904", .linkage = .strong });
        @export(&func_0800198C, .{ .name = "func_0800198C", .linkage = .strong });
        @export(&func_0800199C, .{ .name = "func_0800199C", .linkage = .strong });
        @export(&func_08002E64, .{ .name = "func_08002E64", .linkage = .strong });
        @export(&func_08003434, .{ .name = "func_08003434", .linkage = .strong });
        @export(&func_080036F0, .{ .name = "func_080036F0", .linkage = .strong });
        @export(&func_08003742, .{ .name = "func_08003742", .linkage = .strong });
        @export(&func_080075C4, .{ .name = "func_080075C4", .linkage = .strong });
        @export(&func_0800997A, .{ .name = "func_0800997A", .linkage = .strong });
        @export(&func_0800C2C8, .{ .name = "func_0800C2C8", .linkage = .strong });
        @export(&func_0800E38E, .{ .name = "func_0800E38E", .linkage = .strong });
        @export(&func_0800E5B0, .{ .name = "func_0800E5B0", .linkage = .strong });
        @export(&func_0800F1B0, .{ .name = "func_0800F1B0", .linkage = .strong });
        @export(&func_0800F4E4, .{ .name = "func_0800F4E4", .linkage = .strong });
        @export(&func_0800F5FA, .{ .name = "func_0800F5FA", .linkage = .strong });
        @export(&func_0800F5FC, .{ .name = "func_0800F5FC", .linkage = .strong });
        @export(&func_0800F600, .{ .name = "func_0800F600", .linkage = .strong });
        @export(&func_0800F61A, .{ .name = "func_0800F61A", .linkage = .strong });
        @export(&func_0800F802, .{ .name = "func_0800F802", .linkage = .strong });
        @export(&func_0800F8F0, .{ .name = "func_0800F8F0", .linkage = .strong });
        @export(&func_0800FB06, .{ .name = "func_0800FB06", .linkage = .strong });
        @export(&func_0800FBF8, .{ .name = "func_0800FBF8", .linkage = .strong });
        @export(&func_0800FBFA, .{ .name = "func_0800FBFA", .linkage = .strong });
        @export(&func_0800FBFC, .{ .name = "func_0800FBFC", .linkage = .strong });
        @export(&func_080103AC, .{ .name = "func_080103AC", .linkage = .strong });
        @export(&func_08010406, .{ .name = "func_08010406", .linkage = .strong });
        @export(&func_0801040A, .{ .name = "func_0801040A", .linkage = .strong });
        @export(&func_08010968, .{ .name = "func_08010968", .linkage = .strong });
        @export(&func_08010A78, .{ .name = "func_08010A78", .linkage = .strong });
        @export(&func_08010CC4, .{ .name = "func_08010CC4", .linkage = .strong });
        @export(&func_08010CD8, .{ .name = "func_08010CD8", .linkage = .strong });
        @export(&func_08010CF0, .{ .name = "func_08010CF0", .linkage = .strong });
        @export(&func_08010F28, .{ .name = "func_08010F28", .linkage = .strong });
        @export(&func_08011140, .{ .name = "func_08011140", .linkage = .strong });
        @export(&func_080117E0, .{ .name = "func_080117E0", .linkage = .strong });
        @export(&func_080117EC, .{ .name = "func_080117EC", .linkage = .strong });
        @export(&func_08011804, .{ .name = "func_08011804", .linkage = .strong });
        @export(&func_08011814, .{ .name = "func_08011814", .linkage = .strong });
        @export(&func_08011824, .{ .name = "func_08011824", .linkage = .strong });
        @export(&func_08011834, .{ .name = "func_08011834", .linkage = .strong });
        @export(&func_080119C4, .{ .name = "func_080119C4", .linkage = .strong });
        @export(&func_080119DC, .{ .name = "func_080119DC", .linkage = .strong });
        @export(&func_08011C6C, .{ .name = "func_08011C6C", .linkage = .strong });
        @export(&func_08012064, .{ .name = "func_08012064", .linkage = .strong });
        @export(&func_080124F8, .{ .name = "func_080124F8", .linkage = .strong });
        @export(&func_08012830, .{ .name = "func_08012830", .linkage = .strong });
        @export(&func_08013310, .{ .name = "func_08013310", .linkage = .strong });
        @export(&func_08013770, .{ .name = "func_08013770", .linkage = .strong });
        @export(&func_080137C0, .{ .name = "func_080137C0", .linkage = .strong });
        @export(&func_080138A4, .{ .name = "func_080138A4", .linkage = .strong });
        @export(&func_08013BD0, .{ .name = "func_08013BD0", .linkage = .strong });
        @export(&func_080157E4, .{ .name = "func_080157E4", .linkage = .strong });
        @export(&func_08015A6C, .{ .name = "func_08015A6C", .linkage = .strong });
        @export(&func_08015FD4, .{ .name = "func_08015FD4", .linkage = .strong });
        @export(&func_08015FF0, .{ .name = "func_08015FF0", .linkage = .strong });
        @export(&func_08016934, .{ .name = "func_08016934", .linkage = .strong });
        @export(&func_08016938, .{ .name = "func_08016938", .linkage = .strong });
        @export(&func_08016990, .{ .name = "func_08016990", .linkage = .strong });
        @export(&func_08016F0C, .{ .name = "func_08016F0C", .linkage = .strong });
        @export(&func_08016F24, .{ .name = "func_08016F24", .linkage = .strong });
        @export(&func_080172E4, .{ .name = "func_080172E4", .linkage = .strong });
        @export(&func_08017E98, .{ .name = "func_08017E98", .linkage = .strong });
        @export(&func_080183A8, .{ .name = "func_080183A8", .linkage = .strong });
        @export(&func_08018614, .{ .name = "func_08018614", .linkage = .strong });
        @export(&func_08018E04, .{ .name = "func_08018E04", .linkage = .strong });
        @export(&func_08018E10, .{ .name = "func_08018E10", .linkage = .strong });
        @export(&func_08018E20, .{ .name = "func_08018E20", .linkage = .strong });
        @export(&func_08018E2C, .{ .name = "func_08018E2C", .linkage = .strong });
        @export(&func_08018E38, .{ .name = "func_08018E38", .linkage = .strong });
        @export(&func_08019058, .{ .name = "func_08019058", .linkage = .strong });
        @export(&func_0801A250, .{ .name = "func_0801A250", .linkage = .strong });
        @export(&func_0801AFD0, .{ .name = "func_0801AFD0", .linkage = .strong });
        @export(&func_0801B7F4, .{ .name = "func_0801B7F4", .linkage = .strong });
        @export(&func_0801B80C, .{ .name = "func_0801B80C", .linkage = .strong });
        @export(&func_0801BD04, .{ .name = "func_0801BD04", .linkage = .strong });
        @export(&func_0801BD20, .{ .name = "func_0801BD20", .linkage = .strong });
        @export(&func_0801FB00, .{ .name = "func_0801FB00", .linkage = .strong });
        @export(&func_0801FB02, .{ .name = "func_0801FB02", .linkage = .strong });
        @export(&func_08020304, .{ .name = "func_08020304", .linkage = .strong });
        @export(&func_0802030C, .{ .name = "func_0802030C", .linkage = .strong });
        @export(&func_080210C6, .{ .name = "func_080210C6", .linkage = .strong });
        @export(&func_08022898, .{ .name = "func_08022898", .linkage = .strong });
        @export(&func_080238B0, .{ .name = "func_080238B0", .linkage = .strong });
        @export(&func_08024124, .{ .name = "func_08024124", .linkage = .strong });
        @export(&func_08024B4C, .{ .name = "func_08024B4C", .linkage = .strong });
        @export(&func_08026482, .{ .name = "func_08026482", .linkage = .strong });
        @export(&func_08027F6C, .{ .name = "func_08027F6C", .linkage = .strong });
        @export(&func_08028714, .{ .name = "func_08028714", .linkage = .strong });
        @export(&func_08028B80, .{ .name = "func_08028B80", .linkage = .strong });
        @export(&func_08029F26, .{ .name = "func_08029F26", .linkage = .strong });
        @export(&func_0802A314, .{ .name = "func_0802A314", .linkage = .strong });
        @export(&func_0802AA86, .{ .name = "func_0802AA86", .linkage = .strong });
        @export(&func_0802BB2C, .{ .name = "func_0802BB2C", .linkage = .strong });
        @export(&func_0802C680, .{ .name = "func_0802C680", .linkage = .strong });
        @export(&func_0802C980, .{ .name = "func_0802C980", .linkage = .strong });
        @export(&func_0802C998, .{ .name = "func_0802C998", .linkage = .strong });
        @export(&func_0802D6E4, .{ .name = "func_0802D6E4", .linkage = .strong });
        @export(&func_0802D6F4, .{ .name = "func_0802D6F4", .linkage = .strong });
        @export(&func_0802D70C, .{ .name = "func_0802D70C", .linkage = .strong });
        @export(&func_0802D768, .{ .name = "func_0802D768", .linkage = .strong });
        @export(&func_0802D7A0, .{ .name = "func_0802D7A0", .linkage = .strong });
        @export(&func_0802D7B8, .{ .name = "func_0802D7B8", .linkage = .strong });
        @export(&func_0802D7D0, .{ .name = "func_0802D7D0", .linkage = .strong });
        @export(&func_0802D7E4, .{ .name = "func_0802D7E4", .linkage = .strong });
        @export(&func_0802D91C, .{ .name = "func_0802D91C", .linkage = .strong });
        @export(&func_0802D930, .{ .name = "func_0802D930", .linkage = .strong });
        @export(&func_0802FDF2, .{ .name = "func_0802FDF2", .linkage = .strong });
        @export(&func_0802FDF4, .{ .name = "func_0802FDF4", .linkage = .strong });
        @export(&func_0802FEA8, .{ .name = "func_0802FEA8", .linkage = .strong });
        @export(&func_08030000, .{ .name = "func_08030000", .linkage = .strong });
        @export(&func_08030002, .{ .name = "func_08030002", .linkage = .strong });
        @export(&func_08030010, .{ .name = "func_08030010", .linkage = .strong });
        @export(&func_0803001E, .{ .name = "func_0803001E", .linkage = .strong });
        @export(&func_08030098, .{ .name = "func_08030098", .linkage = .strong });
        @export(&func_08030810, .{ .name = "func_08030810", .linkage = .strong });
        @export(&func_0803081C, .{ .name = "func_0803081C", .linkage = .strong });
        @export(&func_080308AC, .{ .name = "func_080308AC", .linkage = .strong });
        @export(&func_08030A0A, .{ .name = "func_08030A0A", .linkage = .strong });
        @export(&func_08030AFC, .{ .name = "func_08030AFC", .linkage = .strong });
        @export(&func_080316B4, .{ .name = "func_080316B4", .linkage = .strong });
        @export(&func_08031870, .{ .name = "func_08031870", .linkage = .strong });
        @export(&func_08031936, .{ .name = "func_08031936", .linkage = .strong });
        @export(&func_08033094, .{ .name = "func_08033094", .linkage = .strong });
        @export(&func_08035000, .{ .name = "func_08035000", .linkage = .strong });
        @export(&func_080351E8, .{ .name = "func_080351E8", .linkage = .strong });
        @export(&func_0803525C, .{ .name = "func_0803525C", .linkage = .strong });
        @export(&func_08035A3C, .{ .name = "func_08035A3C", .linkage = .strong });
        @export(&func_08035ABC, .{ .name = "func_08035ABC", .linkage = .strong });
        @export(&func_08035C3C, .{ .name = "func_08035C3C", .linkage = .strong });
        @export(&func_08036006, .{ .name = "func_08036006", .linkage = .strong });
        @export(&func_08036918, .{ .name = "func_08036918", .linkage = .strong });
        @export(&func_0803693C, .{ .name = "func_0803693C", .linkage = .strong });
        @export(&func_08036960, .{ .name = "func_08036960", .linkage = .strong });
        @export(&func_080369B0, .{ .name = "func_080369B0", .linkage = .strong });
        @export(&func_080369D4, .{ .name = "func_080369D4", .linkage = .strong });
        @export(&func_08036A10, .{ .name = "func_08036A10", .linkage = .strong });
        @export(&func_08036A60, .{ .name = "func_08036A60", .linkage = .strong });
        @export(&func_08036A9C, .{ .name = "func_08036A9C", .linkage = .strong });
        @export(&func_08036AC0, .{ .name = "func_08036AC0", .linkage = .strong });
        @export(&func_08036AF0, .{ .name = "func_08036AF0", .linkage = .strong });
        @export(&func_08036B14, .{ .name = "func_08036B14", .linkage = .strong });
        @export(&func_08036B8C, .{ .name = "func_08036B8C", .linkage = .strong });
        @export(&func_08036BB0, .{ .name = "func_08036BB0", .linkage = .strong });
        @export(&func_08036BD4, .{ .name = "func_08036BD4", .linkage = .strong });
        @export(&func_08036BF8, .{ .name = "func_08036BF8", .linkage = .strong });
        @export(&func_08036C1C, .{ .name = "func_08036C1C", .linkage = .strong });
        @export(&func_08036C40, .{ .name = "func_08036C40", .linkage = .strong });
        @export(&func_08036CDC, .{ .name = "func_08036CDC", .linkage = .strong });
        @export(&func_08036D00, .{ .name = "func_08036D00", .linkage = .strong });
        @export(&func_08036D24, .{ .name = "func_08036D24", .linkage = .strong });
        @export(&func_08036D48, .{ .name = "func_08036D48", .linkage = .strong });
        @export(&func_08036D6C, .{ .name = "func_08036D6C", .linkage = .strong });
        @export(&func_08036D90, .{ .name = "func_08036D90", .linkage = .strong });
        @export(&func_08036DB4, .{ .name = "func_08036DB4", .linkage = .strong });
    }
}

test "low_peel_1 exports are callable" {
    try std.testing.expect(@TypeOf(func_080001FC) == fn () callconv(.c) void);
    try std.testing.expect(@TypeOf(func_08036DB4) == fn () callconv(.c) void);
}
