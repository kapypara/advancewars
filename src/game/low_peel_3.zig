//! Low-ROM (`< 0x08080000`) block-peeled wave 3 (31..60 reachable lines, first 190).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const campaign = @import("campaign.zig");
const co = @import("co.zig");
const dma = @import("dma.zig");
const hw = @import("hw.zig");
const low_peel_1 = @import("low_peel_1.zig");
const low_peel_2 = @import("low_peel_2.zig");
const low_peel_4 = @import("low_peel_4.zig");
const low_peel_5 = @import("low_peel_5.zig");
const low_peel_6 = @import("low_peel_6.zig");
const low_peel_7 = @import("low_peel_7.zig");
const math = @import("math.zig");
const menu = @import("menu.zig");
const proc = @import("proc.zig");
const sound = @import("sound.zig");
const state = @import("state.zig");
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

pub fn func_08000302() callconv(.c) void {
    if (!abi.enter(0x08000302)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[2] +% 0x6, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            if (!abi.call(low_peel_6.func_08003444, 0x0800030F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x48, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.r[2] = abi.read32(0x0800033C);
            abi.setRegNz(&rt.r[3], 0xD0);
            abi.setRegNz(&rt.r[3], rt.r[3] << 8);
            if (!abi.call(hw.func_0801B888, 0x0800032F)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(low_peel_6.func_080033CC, 0x08000333)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08000400() callconv(.c) void {
    if (!abi.enter(0x08000400)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08000418);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x8);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x50);
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xA);
            abi.write32(rt.r[2] +% 0xC, rt.r[0]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08000904() callconv(.c) void {
    if (!abi.enter(0x08000904)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[4], 0x8);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[4]));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read32(0x0800092C);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            if (!abi.call(decls.func_08000948, 0x0800091D)) return;
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

pub fn func_08000A3C() callconv(.c) void {
    if (!abi.enter(0x08000A3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(tail_low.func_0800020C, 0x08000A43)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(func_08002CD4, 0x08000A47)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08000A68);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 7);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            rt.r[0] = abi.read32(0x08000A6C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08000A5F)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08000A70);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08000D68() callconv(.c) void {
    if (!abi.enter(0x08000D68)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
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
            abi.fetches(18);
            rt.r[0] = abi.read32(0x08000D9C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[4] << 1);
            rt.r[4] = abi.read32(0x08000DA0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[2] = abi.read32(0x08000DA4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read32(0x08000DA8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[0]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08000E04() callconv(.c) void {
    if (!abi.enter(0x08000E04)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x08000E34);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], rt.r[5] << 1);
            rt.r[6] = abi.read32(0x08000E38);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[3] = abi.read32(0x08000E3C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            rt.cpuSub(null, rt.r[2], 0x7, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_6.func_080087A4, 0x08000E2F)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08000E40() callconv(.c) void {
    if (!abi.enter(0x08000E40)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x1F);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x12, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x08000E54);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08000EA4 => continue :blk 3,
                0x08000EA8 => continue :blk 4,
                0x08000EAC => continue :blk 5,
                0x08000EB0 => continue :blk 6,
                0x08000EB4 => continue :blk 7,
                0x08000EB8 => continue :blk 8,
                0x08000EBC => continue :blk 9,
                0x08000EC0 => continue :blk 10,
                0x08000EC4 => continue :blk 11,
                0x08000EC8 => continue :blk 12,
                0x08000ECC => continue :blk 13,
                0x08000ED0 => continue :blk 14,
                0x08000ED4 => continue :blk 15,
                0x08000ED8 => continue :blk 16,
                0x08000EE0 => continue :blk 2,
                0x08000EDC => continue :blk 17,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 18;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 18;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 18;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x3);
            continue :blk 18;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x4);
            continue :blk 18;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x5);
            continue :blk 18;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x6);
            continue :blk 18;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x7);
            continue :blk 18;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x8);
            continue :blk 18;
        },
        11 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x9);
            continue :blk 18;
        },
        12 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xA);
            continue :blk 18;
        },
        13 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xB);
            continue :blk 18;
        },
        14 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xC);
            continue :blk 18;
        },
        15 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xD);
            continue :blk 18;
        },
        16 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xE);
            continue :blk 18;
        },
        17 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x13);
            continue :blk 18;
        },
        18 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08000EE4() callconv(.c) void {
    if (!abi.enter(0x08000EE4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x6, true);
            rt.cpuSub(null, rt.r[0], 0x88, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x08000EF8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08001120 => continue :blk 4,
                0x080011DC => continue :blk 3,
                0x08001146 => continue :blk 9,
                0x0800116A => continue :blk 14,
                0x08001194 => continue :blk 19,
                0x080011BA => continue :blk 24,
                0x08001126 => continue :blk 5,
                0x0800114C => continue :blk 10,
                0x08001174 => continue :blk 15,
                0x0800119A => continue :blk 20,
                0x080011C4 => continue :blk 25,
                0x08001130 => continue :blk 6,
                0x08001154 => continue :blk 11,
                0x0800117A => continue :blk 16,
                0x080011A4 => continue :blk 21,
                0x080011CA => continue :blk 26,
                0x08001136 => continue :blk 7,
                0x0800115A => continue :blk 12,
                0x08001184 => continue :blk 17,
                0x080011AA => continue :blk 22,
                0x080011D4 => continue :blk 27,
                0x08001140 => continue :blk 8,
                0x08001164 => continue :blk 13,
                0x0800118A => continue :blk 18,
                0x080011B4 => continue :blk 23,
                0x080011DA => continue :blk 28,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        3 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.recompReturn(rt.r[14]); return;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xE1);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x0800112C);
            continue :blk 3;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xE6);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 3;
        },
        7 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x0800113C);
            continue :blk 3;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xEB);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 3;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xE0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 3;
        },
        10 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x08001150);
            continue :blk 3;
        },
        11 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xE5);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 3;
        },
        12 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x08001160);
            continue :blk 3;
        },
        13 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xEA);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 3;
        },
        14 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x08001170);
            continue :blk 3;
        },
        15 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xE4);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 3;
        },
        16 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x08001180);
            continue :blk 3;
        },
        17 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xE9);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 3;
        },
        18 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x08001190);
            continue :blk 3;
        },
        19 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xE2);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 3;
        },
        20 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x080011A0);
            continue :blk 3;
        },
        21 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xE7);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 3;
        },
        22 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x080011B0);
            continue :blk 3;
        },
        23 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xEC);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 3;
        },
        24 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x080011C0);
            continue :blk 3;
        },
        25 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xE3);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 3;
        },
        26 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x080011D0);
            continue :blk 3;
        },
        27 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0xE8);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 3;
        },
        28 => {
            abi.fetches(3);
            rt.r[2] = abi.read32(0x080011E0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0800124C() callconv(.c) void {
    if (!abi.enter(0x0800124C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x08001280);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[4] = abi.read32(0x08001284);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read32(0x08001288);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuSub(null, rt.r[2], 0x7, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0xD, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x13);
            abi.setRegNz(&rt.r[1], rt.r[1] ^ rt.r[2]);
            rt.cpuSub(&rt.r[0], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 31);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800128C() callconv(.c) void {
    if (!abi.enter(0x0800128C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x080012C4);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[4] = abi.read32(0x080012C8);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read32(0x080012CC);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuSub(null, rt.r[2], 0x7, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0xD, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x13, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x2);
            abi.setRegNz(&rt.r[1], rt.r[1] ^ rt.r[2]);
            rt.cpuSub(&rt.r[0], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 31);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800135A() callconv(.c) void {
    if (!abi.enter(0x0800135A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08001370);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x080015A4 => continue :blk 2,
                0x080015E4 => { continue :blk 1; },
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[2]));
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x30, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 9;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[1]));
            continue :blk 10;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x21, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        8 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x30, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 13;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        11 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x1, true);
            abi.setRegNz(&rt.r[2], 0x3);
            if (!abi.call(low_peel_6.func_08000DAC, 0x080015BF)) return;
            continue :blk 14;
        },
        12 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            continue :blk 10;
        },
        13 => {
            abi.fetches(3);
            continue :blk 9;
        },
        14 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 15;
            }
            continue :blk 12;
        },
        15 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x3);
            continue :blk 10;
        },
        else => unreachable,
    }
}

pub fn func_08002CD4() callconv(.c) void {
    if (!abi.enter(0x08002CD4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_080019AC, 0x08002CDB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08002CF8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
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
            abi.setRegNz(&rt.r[0], 0x7);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080027DC, 0x08002CF5)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08002960, 0x08002D01)) return;
            continue :blk 2;
        },
        6 => {
            abi.fetches(3);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08003602() callconv(.c) void {
    if (!abi.enter(0x08003602)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xE);
            if (!abi.call(low_peel_7.func_0802C11C, 0x0800360D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xA);
            rt.r[2] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x18);
            if (!abi.call(low_peel_7.func_0802C11C, 0x0800361D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08003714() callconv(.c) void {
    if (!abi.enter(0x08003714)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x08003734);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x6, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[4]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], 0x6);
            rt.r[0] = abi.read32(0x08003738);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0800372B)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800373C() callconv(.c) void {
    if (!abi.enter(0x0800373C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x0800375C);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[4], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x08003760);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08003753)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[4]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080048F8() callconv(.c) void {
    if (!abi.enter(0x080048F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(proc.func_08019608, 0x080048FF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x9);
            if (!abi.call(low_peel_1.func_080001FC, 0x08004905)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x08004924);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read32(0x08004928);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(low_peel_6.func_08018400, 0x0800491F)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.r[1] = abi.read32(0x0800492C);
            continue :blk 3;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08005528() callconv(.c) void {
    if (!abi.enter(0x08005528)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[13] -%= 0x4;
            rt.r[2] = abi.read32(0x08005540);
            rt.r[0] = abi.read32(0x08005544);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x10);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
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
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x2);
            abi.setRegNz(&rt.r[2], 0x4);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(ui.func_080193C0, 0x08005559)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08005474, 0x0800555D)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0800556C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08005570() callconv(.c) void {
    if (!abi.enter(0x08005570)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            rt.cpuSub(null, rt.r[2], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x080055A4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            if (!abi.call(func_08019A1C, 0x08005595)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08005584);
            if (!abi.call(low_peel_6.func_08018400, 0x08005581)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(proc.func_08019608, 0x08005599)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080055A8);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(func_080131E0, 0x080055A1)) return;
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

pub fn func_080056F0() callconv(.c) void {
    if (!abi.enter(0x080056F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            rt.cpuSub(null, rt.r[2], 0x2, true);
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
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08005718);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            if (!abi.call(func_08019A1C, 0x08005707)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(proc.func_08019608, 0x0800570B)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0800571C);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(func_080131E0, 0x08005713)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08005CE8() callconv(.c) void {
    if (!abi.enter(0x08005CE8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[1] = abi.read32(0x08005D08);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(func_080131E0, 0x08005CFB)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.r[1] = abi.read32(0x08005D0C);
            continue :blk 1;
        },
        3 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08005D10);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x6B, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08005D14() callconv(.c) void {
    if (!abi.enter(0x08005D14)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x08005D40);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x6B, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[1] = rt.sext8(abi.read8(rt.r[2] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
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
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(low_peel_6.func_08013248, 0x08005D31)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6B, true);
            abi.setRegNz(&rt.r[1], 0xFF);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08007028() callconv(.c) void {
    if (!abi.enter(0x08007028)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x08007050);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x7);
            rt.r[0] = rt.sext8(abi.read8(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[3], 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.cpuSub(&rt.r[1], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[4], 0x3A);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[4]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[3], 0xA);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.write16(rt.r[2] +% 0x3C, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08007860() callconv(.c) void {
    if (!abi.enter(0x08007860)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x0800788C);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x6B, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[1] = rt.sext8(abi.read8(rt.r[2] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
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
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(low_peel_6.func_08013248, 0x0800787D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6B, true);
            abi.setRegNz(&rt.r[1], 0xFF);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08007AE8() callconv(.c) void {
    if (!abi.enter(0x08007AE8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            if (!abi.call(decls.func_08007B08, 0x08007AF3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(func_08000D68, 0x08007B03)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08008306() callconv(.c) void {
    if (!abi.enter(0x08008306)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x12, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x08008328);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08008516 => continue :blk 14,
                0x0800841C => continue :blk 7,
                0x08008488 => continue :blk 9,
                0x080084D4 => continue :blk 11,
                0x080083D6 => continue :blk 6,
                0x080084FA => continue :blk 13,
                0x08008378 => continue :blk 4,
                0x080084DE => continue :blk 12,
                0x08008560 => { continue :blk 3; },
                0x08008468 => continue :blk 8,
                0x08008398 => continue :blk 5,
                0x080084BA => continue :blk 10,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_080079D8, 0x08008381)) return;
            continue :blk 15;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800B038, 0x080083A1)) return;
            continue :blk 16;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(menu.func_0800C314, 0x080083DF)) return;
            continue :blk 17;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(menu.func_0800C314, 0x08008425)) return;
            continue :blk 18;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_08008B34, 0x08008471)) return;
            continue :blk 19;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(menu.func_0800C314, 0x08008491)) return;
            continue :blk 20;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800BA6C, 0x080084C3)) return;
            continue :blk 21;
        },
        11 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800CA04, 0x080084DD)) return;
            continue :blk 22;
        },
        12 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[2] = abi.read16(rt.r[0] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800BF24, 0x080084EB)) return;
            continue :blk 23;
        },
        13 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[2] = abi.read16(rt.r[0] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800BF24, 0x08008507)) return;
            continue :blk 24;
        },
        14 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(menu.func_0800C314, 0x0800851F)) return;
            continue :blk 25;
        },
        15 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_6.func_080087A4, 0x08008389)) return;
            continue :blk 26;
        },
        16 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 28;
            }
            continue :blk 27;
        },
        17 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 30;
            }
            continue :blk 29;
        },
        18 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 32;
            }
            continue :blk 31;
        },
        19 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_6.func_080087A4, 0x08008479)) return;
            continue :blk 33;
        },
        20 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 35;
            }
            continue :blk 34;
        },
        21 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 36;
        },
        22 => {
            abi.fetches(3);
            continue :blk 37;
        },
        23 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_6.func_080087A4, 0x080084F3)) return;
            continue :blk 38;
        },
        24 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_6.func_080087A4, 0x0800850F)) return;
            continue :blk 39;
        },
        25 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 41;
            }
            continue :blk 40;
        },
        26 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08008394);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6A, true);
            abi.setRegNz(&rt.r[1], 0x8A);
            continue :blk 42;
        },
        27 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(menu.func_0800C314, 0x080083AD)) return;
            continue :blk 43;
        },
        28 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800B5B0, 0x080083D5)) return;
            continue :blk 44;
        },
        29 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800C0DC, 0x080083EB)) return;
            continue :blk 45;
        },
        30 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800F00C, 0x08008407)) return;
            continue :blk 46;
        },
        31 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800C0DC, 0x08008431)) return;
            continue :blk 47;
        },
        32 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_08009AA0, 0x0800844D)) return;
            continue :blk 48;
        },
        33 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08008484);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6A, true);
            abi.setRegNz(&rt.r[1], 0x89);
            continue :blk 42;
        },
        34 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800C0DC, 0x0800849D)) return;
            continue :blk 49;
        },
        35 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_6.func_0800AA84, 0x080084B9)) return;
            continue :blk 50;
        },
        36 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080084D0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6A, true);
            abi.setRegNz(&rt.r[1], 0x8A);
            continue :blk 42;
        },
        37 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_6.func_080087A4, 0x08008557)) return;
            continue :blk 51;
        },
        38 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6A, true);
            abi.setRegNz(&rt.r[1], 0x88);
            continue :blk 42;
        },
        39 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6A, true);
            abi.setRegNz(&rt.r[1], 0x87);
            continue :blk 42;
        },
        40 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800C0DC, 0x0800852B)) return;
            continue :blk 41;
        },
        41 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(func_08000E04, 0x08008535)) return;
            continue :blk 52;
        },
        42 => {
            abi.fetches(3);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 3;
        },
        43 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 28;
            }
            continue :blk 53;
        },
        44 => {
            abi.fetches(3);
            continue :blk 37;
        },
        45 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(func_08000E04, 0x080083F5)) return;
            continue :blk 54;
        },
        46 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_6.func_080087A4, 0x0800840F)) return;
            continue :blk 55;
        },
        47 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(func_08000E04, 0x0800843B)) return;
            continue :blk 56;
        },
        48 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 58;
            }
            continue :blk 57;
        },
        49 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(func_08000E04, 0x080084A7)) return;
            continue :blk 59;
        },
        50 => {
            abi.fetches(3);
            continue :blk 37;
        },
        51 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08008568);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6A, true);
            abi.setRegNz(&rt.r[1], 0x4B);
            continue :blk 42;
        },
        52 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(low_peel_6.func_08007C3C, 0x0800853F)) return;
            continue :blk 60;
        },
        53 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800C0DC, 0x080083B9)) return;
            continue :blk 61;
        },
        54 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(low_peel_6.func_08007C3C, 0x080083FF)) return;
            continue :blk 30;
        },
        55 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08008418);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6A, true);
            abi.setRegNz(&rt.r[1], 0x89);
            continue :blk 42;
        },
        56 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(low_peel_6.func_08007C3C, 0x08008445)) return;
            continue :blk 32;
        },
        57 => {
            abi.fetches(3);
            continue :blk 3;
        },
        58 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_6.func_080087A4, 0x0800845B)) return;
            continue :blk 62;
        },
        59 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(low_peel_6.func_08007C3C, 0x080084B1)) return;
            continue :blk 35;
        },
        60 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800E75C, 0x08008547)) return;
            continue :blk 63;
        },
        61 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(func_08000E04, 0x080083C3)) return;
            continue :blk 64;
        },
        62 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08008464);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6A, true);
            abi.setRegNz(&rt.r[1], 0x2D);
            continue :blk 42;
        },
        63 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800B9DC, 0x0800854F)) return;
            continue :blk 37;
        },
        64 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(low_peel_6.func_08007C3C, 0x080083CD)) return;
            continue :blk 28;
        },
        else => unreachable,
    }
}

pub fn func_0800875C() callconv(.c) void {
    if (!abi.enter(0x0800875C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x19);
            rt.r[2] = abi.read32(0x08008798);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[5] = abi.read32(0x0800879C);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[5], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x12, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[3], 0xC0);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[2]);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x080087A0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[4] | rt.r[3]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08008818() callconv(.c) void {
    if (!abi.enter(0x08008818)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x0800884C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[4] << 1);
            rt.r[5] = abi.read32(0x08008850);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[2] = abi.read32(0x08008854);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0xC, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_08008860, 0x08008843)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08008832() callconv(.c) void {
    if (!abi.enter(0x08008832)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0xC, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_08008860, 0x08008843)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08008860() callconv(.c) void {
    if (!abi.enter(0x08008860)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x08008888);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[4] = abi.read32(0x0800888C);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x08008890);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x13, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x16, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08008F10() callconv(.c) void {
    if (!abi.enter(0x08008F10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x08008F28);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08008F64 => continue :blk 3,
                0x080090AC => continue :blk 4,
                0x0800909A => { continue :blk 5; },
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08008954, 0x08008F77)) return;
            continue :blk 6;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_6.func_0800889C, 0x08008F6D)) return;
            continue :blk 7;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 8;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 8;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            continue :blk 5;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        9 => {
            abi.fetches(3);
            continue :blk 5;
        },
        10 => {
            abi.fetches(3);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08009F28() callconv(.c) void {
    if (!abi.enter(0x08009F28)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            if (!abi.call(decls.func_08009740, 0x08009F33)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(func_08000E04, 0x08009F43)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            if (!abi.call(func_08000D68, 0x08009F4D)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0800AADC() callconv(.c) void {
    if (!abi.enter(0x0800AADC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x0800AB0C);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[4] = abi.read32(0x0800AB10);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read32(0x0800AB14);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x3, true);
            rt.cpuSub(null, rt.r[0], 0xB, true);
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
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x0800AB18);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x0800AB4C => continue :blk 4,
                0x0800AB50 => continue :blk 1,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0800B000() callconv(.c) void {
    if (!abi.enter(0x0800B000)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[2] = abi.read32(0x0800B02C);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[5] = abi.read32(0x0800B030);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[5], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read32(0x0800B034);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[3], 0xD, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800B768() callconv(.c) void {
    if (!abi.enter(0x0800B768)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x0800B790);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[4] = abi.read32(0x0800B794);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read32(0x0800B798);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x13, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0800B7A4() callconv(.c) void {
    if (!abi.enter(0x0800B7A4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x0800B7C8);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[4] = abi.read32(0x0800B7CC);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read32(0x0800B7D0);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[3], 0x7, true);
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
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800B9B0() callconv(.c) void {
    if (!abi.enter(0x0800B9B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x13);
            if (!abi.call(low_peel_6.func_08000DAC, 0x0800B9BD)) return;
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
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0800B7DC, 0x0800B9C9)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x7);
            if (!abi.call(func_08000E04, 0x0800B9D7)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0800C004() callconv(.c) void {
    if (!abi.enter(0x0800C004)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0800A100, 0x0800C00D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0800A6F8, 0x0800C015)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08007CC4, 0x0800C01D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0800B9DC, 0x0800C025)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0800E75C, 0x0800C02D)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800C082() callconv(.c) void {
    if (!abi.enter(0x0800C082)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(31);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[5]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write8(rt.r[0] +% 0x2, @truncate(rt.r[6]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write8(rt.r[0] +% 0x3, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            rt.r[0] = abi.read8(rt.r[1] +% 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x8, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0800C0D8);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[7]));
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[5]));
            abi.write8(rt.r[0] +% 0x2, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[4]);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[1] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x12, @truncate(rt.r[3]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800C348() callconv(.c) void {
    if (!abi.enter(0x0800C348)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = abi.read32(0x0800C370);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xB6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[0], true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.recompReturn(rt.r[14]); return;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.cpuSub(null, rt.r[1], rt.r[3], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0800C9B4() callconv(.c) void {
    if (!abi.enter(0x0800C9B4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x4);
            if (!abi.call(low_peel_6.func_08000DAC, 0x0800C9C1)) return;
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
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x87);
            if (!abi.call(func_08000D68, 0x0800C9CF)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0800C9D4() callconv(.c) void {
    if (!abi.enter(0x0800C9D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x0800CA00);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
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
            abi.fetches(6);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(menu.func_080012D0, 0x0800C9EF)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(func_08000D68, 0x0800C9F9)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800E8EC() callconv(.c) void {
    if (!abi.enter(0x0800E8EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x87);
            if (!abi.call(menu.func_0800E738, 0x0800ED7D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.r[1] = rt.r[8];
            if (!abi.call(func_0800C9D4, 0x0800EE05)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
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

pub fn func_0800EB10() callconv(.c) void {
    if (!abi.enter(0x0800EB10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x87);
            if (!abi.call(menu.func_0800E738, 0x0800EB1B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x87);
            if (!abi.call(menu.func_0800E738, 0x0800ED73)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x87);
            if (!abi.call(menu.func_0800E738, 0x0800ED7D)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.r[1] = rt.r[8];
            if (!abi.call(func_0800C9D4, 0x0800EE05)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
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

pub fn func_0800EBFA() callconv(.c) void {
    if (!abi.enter(0x0800EBFA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x87);
            if (!abi.call(menu.func_0800E738, 0x0800EC01)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[5], rt.r[7], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x67);
            if (!abi.call(func_08000D68, 0x0800EC0D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x87);
            if (!abi.call(menu.func_0800E738, 0x0800ED7D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.r[1] = rt.r[8];
            if (!abi.call(func_0800C9D4, 0x0800EE05)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
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

pub fn func_0800EDF4() callconv(.c) void {
    if (!abi.enter(0x0800EDF4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x87);
            if (!abi.call(menu.func_0800E738, 0x0800EDFD)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.r[1] = rt.r[8];
            if (!abi.call(func_0800C9D4, 0x0800EE05)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
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

pub fn func_0800EE1C() callconv(.c) void {
    if (!abi.enter(0x0800EE1C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x0800EE48);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[4] = abi.read32(0x0800EE4C);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read32(0x0800EE50);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuSub(null, rt.r[1], 0x5, true);
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
            rt.cpuSub(null, rt.r[1], 0xC, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800F1F6() callconv(.c) void {
    if (!abi.enter(0x0800F1F6)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(hw.func_0800F170, 0x0800F201)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(29);
            rt.r[1] = abi.read32(0x0800F23C);
            abi.setRegNz(&rt.r[0], 0xC0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0800F240);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(0x0800F244);
            rt.r[2] = abi.read32(0x0800F248);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[3]));
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

pub fn func_0800F1FA() callconv(.c) void {
    if (!abi.enter(0x0800F1FA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(hw.func_0800F170, 0x0800F201)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(29);
            rt.r[1] = abi.read32(0x0800F23C);
            abi.setRegNz(&rt.r[0], 0xC0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0800F240);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(0x0800F244);
            rt.r[2] = abi.read32(0x0800F248);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[3]));
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

pub fn func_0800F300() callconv(.c) void {
    if (!abi.enter(0x0800F300)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[1], 0xF8);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[1]));
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

pub fn func_0800F444() callconv(.c) void {
    if (!abi.enter(0x0800F444)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x0800F458);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0800F484);
            rt.r[1] = abi.read32(0x0800F488);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[3] +% 0x1E, @truncate(rt.r[0]));
            if (!abi.call(func_0800F490, 0x0800F475)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            if (!abi.call(low_peel_6.func_080132D8, 0x0800F457)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(low_peel_1.func_0800F4E4, 0x0800F479)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0800F48C);
            if (!abi.call(hw.func_08010B28, 0x0800F47F)) return;
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

pub fn func_0800F490() callconv(.c) void {
    if (!abi.enter(0x0800F490)) return;
    abi.fetches(37);
    rt.r[1] = abi.read32(0x0800F4D8);
    abi.setRegNz(&rt.r[3], 0x20);
    rt.r[0] = abi.read8(rt.r[1] +% 0x1);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
    abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
    rt.r[2] = abi.read32(0x0800F4DC);
    abi.setRegNz(&rt.r[0], 0x2);
    rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
    rt.r[1] = abi.read8(rt.r[2] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x3);
    rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    rt.cpuSub(&rt.r[1], rt.r[1], 0x2, true);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    rt.cpuSub(&rt.r[1], rt.r[1], 0x4, true);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    rt.cpuSub(&rt.r[1], rt.r[1], 0x8, true);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
    rt.r[2] = abi.read32(0x0800F4E0);
    abi.setRegNz(&rt.r[0], 0x1);
    rt.r[1] = abi.read8(rt.r[2] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x2);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x4);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x8);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x10);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
    abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0800F5E4() callconv(.c) void {
    if (!abi.enter(0x0800F5E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x0800F610);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[3] = abi.read16(rt.r[2] +% 0x1E);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0800F624);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0800F614);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(func_0800FBEC, 0x0800F61F)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], 0x21);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[2] +% 0x8, rt.r[0]);
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

pub fn func_0800F5EA() callconv(.c) void {
    if (!abi.enter(0x0800F5EA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[3] = abi.read16(rt.r[2] +% 0x1E);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0800F624);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0800F614);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(func_0800FBEC, 0x0800F61F)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], 0x21);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[2] +% 0x8, rt.r[0]);
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

pub fn func_0800F7B0() callconv(.c) void {
    if (!abi.enter(0x0800F7B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0800F7C8);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(hw.func_0800F170, 0x0800F7D9)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0800F7CC);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(low_peel_6.func_08013248, 0x0800F7C5)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(12);
            rt.r[2] = abi.read32(0x0800F7F0);
            abi.setRegNz(&rt.r[0], 0x3F);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0800F7F4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
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

pub fn func_0800F7F8() callconv(.c) void {
    if (!abi.enter(0x0800F7F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.pushLr();
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0800F810);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1F, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0800F814);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(low_peel_6.func_08013248, 0x0800F80D)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
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

pub fn func_0800F7FA() callconv(.c) void {
    if (!abi.enter(0x0800F7FA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0800F810);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1F, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0800F814);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(low_peel_6.func_08013248, 0x0800F80D)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
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

pub fn func_0800F824() callconv(.c) void {
    if (!abi.enter(0x0800F824)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0800F83C);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(hw.func_0800F170, 0x0800F84D)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0800F840);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(low_peel_6.func_08013248, 0x0800F839)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(12);
            rt.r[2] = abi.read32(0x0800F864);
            abi.setRegNz(&rt.r[0], 0x3F);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0800F868);
            abi.setRegNz(&rt.r[0], 0x1F);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
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

pub fn func_0800F86C() callconv(.c) void {
    if (!abi.enter(0x0800F86C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0800F88C);
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
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0800F890);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(low_peel_6.func_08013248, 0x0800F887)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800FAF4() callconv(.c) void {
    if (!abi.enter(0x0800FAF4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.r[2] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800F90C, 0x0800FAF7)) return;
            continue :blk 0;
        },
        5 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5, 6 });
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

pub fn func_0800FAF6() callconv(.c) void {
    if (!abi.enter(0x0800FAF6)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.r[2] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800F90C, 0x0800FAF7)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5, 6 });
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            continue :blk 0;
        },
        6 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800FAFA() callconv(.c) void {
    if (!abi.enter(0x0800FAFA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[2] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0800F90C, 0x0800FAF7)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5, 6 });
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            continue :blk 0;
        },
        else => unreachable,
    }
}

pub fn func_0800FBEC() callconv(.c) void {
    if (!abi.enter(0x0800FBEC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[3] = abi.read32(0x0800FC10);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x10, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0800FC14);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(3);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 14));
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[4]);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0800FBF4() callconv(.c) void {
    if (!abi.enter(0x0800FBF4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x10, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0800FC14);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(3);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 14));
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[4]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0800FC74() callconv(.c) void {
    if (!abi.enter(0x0800FC74)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x0800FC80);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_C) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        4 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.r[0] = abi.read32(0x0800FC98);
            continue :blk 1;
        },
        5 => {
            abi.fetches(3);
            abi.write32(rt.r[1] +% 0x0, rt.r[2]);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0800FC9C() callconv(.c) void {
    if (!abi.enter(0x0800FC9C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = abi.read32(0x0800FCB0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[2], 0xF, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.write32(rt.r[4] +% 0x0, rt.r[2]);
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0800FCD4() callconv(.c) void {
    if (!abi.enter(0x0800FCD4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[5] = abi.read32(0x0800FCFC);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(tail_low.func_0807B44C, 0x0800FCEB)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800FD10() callconv(.c) void {
    if (!abi.enter(0x0800FD10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = abi.read32(0x0800FD20);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
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
            abi.fetches(7);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        4 => {
            abi.fetches(3);
            rt.r[3] = abi.read32(0x0800FD50);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 3;
        },
        6 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x8);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], rt.r[1] >> 16);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_0800FE24() callconv(.c) void {
    if (!abi.enter(0x0800FE24)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read32(0x0800FE5C);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(15);
            rt.r[0] = abi.read32(0x0800FE60);
            abi.setRegNz(&rt.r[1], 0xF0);
            rt.r[5] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[5]);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 3);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(tail_low.func_0807B454, 0x0800FE55)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x0);
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

pub fn func_0800FEF8() callconv(.c) void {
    if (!abi.enter(0x0800FEF8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.r[1] = abi.read16(rt.r[0] +% 0x8);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[5]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            continue :blk 3;
        },
        3 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[1], 0x4);
            abi.write8(rt.r[0] +% 0xA, @truncate(rt.r[1]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800FEFE() callconv(.c) void {
    if (!abi.enter(0x0800FEFE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.r[1] = abi.read16(rt.r[0] +% 0x8);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[5]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            continue :blk 2;
        },
        2 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[1], 0x4);
            abi.write8(rt.r[0] +% 0xA, @truncate(rt.r[1]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800FF02() callconv(.c) void {
    if (!abi.enter(0x0800FF02)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            continue :blk 1;
        },
        1 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[1], 0x4);
            abi.write8(rt.r[0] +% 0xA, @truncate(rt.r[1]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
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

pub fn func_0800FF06() callconv(.c) void {
    if (!abi.enter(0x0800FF06)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[1], 0x4);
            abi.write8(rt.r[0] +% 0xA, @truncate(rt.r[1]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800FFFE() callconv(.c) void {
    if (!abi.enter(0x0800FFFE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.r[1] = abi.read16(rt.r[0] +% 0x8);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[6]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(19);
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0xA);
            abi.write8(rt.r[0] +% 0xA, @truncate(rt.r[3]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08010000() callconv(.c) void {
    if (!abi.enter(0x08010000)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.r[1] = abi.read16(rt.r[0] +% 0x8);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[6]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(19);
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0xA);
            abi.write8(rt.r[0] +% 0xA, @truncate(rt.r[3]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08010002() callconv(.c) void {
    if (!abi.enter(0x08010002)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.r[1] = abi.read16(rt.r[0] +% 0x8);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[6]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(19);
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0xA);
            abi.write8(rt.r[0] +% 0xA, @truncate(rt.r[3]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08010006() callconv(.c) void {
    if (!abi.enter(0x08010006)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.r[1] = abi.read16(rt.r[0] +% 0x8);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[6]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(19);
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0xA);
            abi.write8(rt.r[0] +% 0xA, @truncate(rt.r[3]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801000A() callconv(.c) void {
    if (!abi.enter(0x0801000A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[6]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(19);
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0xA);
            abi.write8(rt.r[0] +% 0xA, @truncate(rt.r[3]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801000C() callconv(.c) void {
    if (!abi.enter(0x0801000C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0xA);
            abi.write8(rt.r[0] +% 0xA, @truncate(rt.r[3]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08010108() callconv(.c) void {
    if (!abi.enter(0x08010108)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(22);
            rt.r[1] = abi.read16(rt.r[0] +% 0x8);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[6]));
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[1], 0x2);
            abi.write8(rt.r[0] +% 0xA, @truncate(rt.r[1]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_080104D4() callconv(.c) void {
    if (!abi.enter(0x080104D4)) return;
    abi.fetches(36);
    rt.r[2] = abi.read32(0x08010518);
    abi.setRegNz(&rt.r[0], 0x21);
    rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
    rt.r[1] = abi.read8(rt.r[2] +% 0x1);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x41);
    rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x7F);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
    rt.r[0] = abi.read32(0x0801051C);
    abi.setRegNz(&rt.r[1], 0x0);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(0x08010520);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(0x08010524);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(0x08010528);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(0x0801052C);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(0x08010530);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(0x08010534);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(0x08010538);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(0x0801053C);
    abi.setRegNz(&rt.r[1], 0x0);
    abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(0x08010540);
    abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08010602() callconv(.c) void {
    if (!abi.enter(0x08010602)) return;
    abi.fetches(35);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
    rt.r[1] = abi.read32(0x08010690);
    rt.r[0] = abi.read32(0x08010694);
    rt.r[0] = abi.read16(rt.r[0] +% 0x0);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.r[2] = abi.read32(0x08010698);
    rt.r[1] = abi.read32(0x0801069C);
    rt.r[0] = abi.read32(rt.r[1] +% 0x0);
    abi.write32(rt.r[2] +% 0x0, rt.r[0]);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
    rt.r[0] = abi.read32(rt.r[1] +% 0x4);
    abi.write32(rt.r[2] +% 0x0, rt.r[0]);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
    rt.r[0] = abi.read32(rt.r[1] +% 0x8);
    abi.write32(rt.r[2] +% 0x0, rt.r[0]);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
    rt.r[0] = abi.read32(rt.r[1] +% 0xC);
    abi.write32(rt.r[2] +% 0x0, rt.r[0]);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
    rt.r[1] = abi.read32(0x080106A0);
    rt.r[0] = abi.read32(rt.r[1] +% 0x0);
    abi.write32(rt.r[2] +% 0x0, rt.r[0]);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
    rt.r[0] = abi.read32(rt.r[1] +% 0x4);
    abi.write32(rt.r[2] +% 0x0, rt.r[0]);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
    rt.r[0] = abi.read32(rt.r[1] +% 0x8);
    abi.write32(rt.r[2] +% 0x0, rt.r[0]);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
    rt.r[0] = abi.read32(rt.r[1] +% 0xC);
    abi.write32(rt.r[2] +% 0x0, rt.r[0]);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08010A9C() callconv(.c) void {
    if (!abi.enter(0x08010A9C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            if (!abi.call(math.func_08010A84, 0x08010AA9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08010ABC);
            if (!abi.call(math.func_0807B6AC, 0x08010AAF)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x64);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[4]);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_C) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08010BA4() callconv(.c) void {
    if (!abi.enter(0x08010BA4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(11);
            rt.r[4] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[2], true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x2, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08010BCC() callconv(.c) void {
    if (!abi.enter(0x08010BCC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.cpuSub(null, rt.r[2], 0x0, true);
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
            abi.fetches(12);
            rt.r[5] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[3], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x2, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08010BF8() callconv(.c) void {
    if (!abi.enter(0x08010BF8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x2, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
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

pub fn func_08010EDC() callconv(.c) void {
    if (!abi.enter(0x08010EDC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08010EF0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1F);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0xB, true);
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x1B, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08011008() callconv(.c) void {
    if (!abi.enter(0x08011008)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(8);
            rt.r[2] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_08010F4C, 0x08011023)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08011010() callconv(.c) void {
    if (!abi.enter(0x08011010)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[2] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_08010F4C, 0x08011023)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08011014() callconv(.c) void {
    if (!abi.enter(0x08011014)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[2] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_08010F4C, 0x08011023)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08011090() callconv(.c) void {
    if (!abi.enter(0x08011090)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[0] = abi.read32(rt.r[0] +% 0x20);
            if (!abi.call(tail_low.func_0807B44C, 0x08011099)) return;
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
            rt.r[0] = abi.read32(0x080110AC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x080110A7)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_080110B0() callconv(.c) void {
    if (!abi.enter(0x080110B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(0x080110CC);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
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
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[1] +% 0x24);
            if (!abi.call(tail_low.func_0807B44C, 0x080110C7)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080110DC() callconv(.c) void {
    if (!abi.enter(0x080110DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x2, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(9);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x2, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            rt.r[3] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], 0x81, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            rt.recompReturn(rt.r[14]); return;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x40, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08011114() callconv(.c) void {
    if (!abi.enter(0x08011114)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 1));
            rt.cpuSub(&rt.r[3], 0, rt.r[2], true);
            rt.cpuSub(null, rt.r[4], rt.r[3], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF0, true);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[3], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x50, true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08011484() callconv(.c) void {
    if (!abi.enter(0x08011484)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
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
            rt.r[4] = abi.read32(0x080114AC);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[4], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], rt.r[1], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801163C() callconv(.c) void {
    if (!abi.enter(0x0801163C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[1], 0x1F);
            abi.setRegNz(&rt.r[5], rt.r[0] << 24);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], rt.r[1] << 24);
            abi.setRegNz(&rt.r[0], rt.r[4] >> 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[5], 24));
            if (!abi.call(low_peel_6.func_080115C4, 0x0801164D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[4] >> 24);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
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

pub fn func_080116D8() callconv(.c) void {
    if (!abi.enter(0x080116D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x1F);
            abi.setRegNz(&rt.r[5], rt.r[0] << 24);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[5], 24));
            if (!abi.call(low_peel_6.func_08011660, 0x080116E9)) return;
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
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08011910() callconv(.c) void {
    if (!abi.enter(0x08011910)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[4] = abi.read32(0x08011934);
            abi.setRegNz(&rt.r[0], 0xBA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(0x08011938);
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

pub fn func_0801193C() callconv(.c) void {
    if (!abi.enter(0x0801193C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[4] = abi.read32(0x08011960);
            abi.setRegNz(&rt.r[0], 0xBA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(0x08011964);
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

pub fn func_08011968() callconv(.c) void {
    if (!abi.enter(0x08011968)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[4] = abi.read32(0x0801198C);
            rt.r[0] = abi.read32(0x08011990);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(0x08011994);
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

pub fn func_0801222C() callconv(.c) void {
    if (!abi.enter(0x0801222C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0801224C);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08012250);
            if (!abi.call(low_peel_6.func_0801329C, 0x08012241)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08012254);
            if (!abi.call(low_peel_6.func_0801329C, 0x08012247)) return;
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

pub fn func_08012C60() callconv(.c) void {
    if (!abi.enter(0x08012C60)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 6, 14 });
            abi.setRegNz(&rt.r[6], 0);
            abi.setRegNz(&rt.r[0], rt.armLsr(rt.r[0], rt.r[1] & 0xFF));
            abi.setRegNz(&rt.r[6], 0);
            abi.write16(rt.r[3] +% 0x24, @truncate(rt.r[5]));
            abi.setRegNz(&rt.r[3], 0);
            abi.write8(rt.r[3] +% 0x1B, @truncate(rt.r[4]));
            abi.setRegNz(&rt.r[0], 0);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[1], 9));
            abi.setRegNz(&rt.r[7], 0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
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

pub fn func_08012CC4() callconv(.c) void {
    if (!abi.enter(0x08012CC4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[3], 0x1F, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(16);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            abi.setRegNz(&rt.r[1], 0x10);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.cpuSub(&rt.r[3], rt.r[3], rt.r[1], true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x10, true);
            abi.write32(rt.r[0] +% 0x4, rt.r[1]);
            abi.write32(rt.r[0] +% 0x8, rt.r[2]);
            abi.write32(rt.r[0] +% 0xC, rt.r[3]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08012CF0() callconv(.c) void {
    if (!abi.enter(0x08012CF0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x08012D08);
            if (!abi.call(func_08012CC4, 0x08012CF9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.write32(rt.r[4] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
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

pub fn func_08012D8C() callconv(.c) void {
    if (!abi.enter(0x08012D8C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08012DA4);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
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
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08012D14, 0x08012DA3)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08012E14() callconv(.c) void {
    if (!abi.enter(0x08012E14)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08012E30);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
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
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(low_peel_6.func_08012DB0, 0x08012E2B)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080131E0() callconv(.c) void {
    if (!abi.enter(0x080131E0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 24);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(proc.func_08013B70, 0x080131EF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(proc.func_08013144, 0x08013205)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08013508() callconv(.c) void {
    if (!abi.enter(0x08013508)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            abi.setRegNz(&rt.r[3], rt.r[3] << 24);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 24);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            if (!abi.call(ui.func_08019F90, 0x08013527)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(ui.func_08019F04, 0x0801351B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_080136A4() callconv(.c) void {
    if (!abi.enter(0x080136A4)) return;
    abi.fetches(24);
    abi.setRegNz(&rt.r[1], rt.r[1] << 16);
    rt.r[3] = abi.read32(0x080136D0);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
    abi.setRegNz(&rt.r[2], rt.r[0] << 1);
    rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
    abi.setRegNz(&rt.r[2], rt.r[2] << 5);
    rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
    abi.setRegNz(&rt.r[0], 0x4C);
    rt.r[2] = abi.read16(rt.r[2] +% 0x26);
    abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[0]);
    rt.r[0] = abi.read32(0x080136D4);
    rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
    abi.setRegNz(&rt.r[0], 0x0);
    abi.write16(rt.r[2] +% 0x1C, @truncate(rt.r[0]));
    rt.r[0] = abi.read32(rt.r[2] +% 0x48);
    abi.setRegNz(&rt.r[1], rt.r[1] >> 14);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
    rt.r[0] = abi.read32(rt.r[1] +% 0x4);
    abi.write32(rt.r[2] +% 0x4, rt.r[0]);
    abi.write32(rt.r[2] +% 0x8, rt.r[0]);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08013E48() callconv(.c) void {
    if (!abi.enter(0x08013E48)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            if (!abi.call(func_0801833C, 0x08013E53)) return;
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
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08013E70);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x1);
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

pub fn func_08013F44() callconv(.c) void {
    if (!abi.enter(0x08013F44)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.r[2] = abi.read32(0x08013F6C);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            if (!abi.call(tail_low.func_0807B450, 0x08013F63)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            abi.write32(rt.r[4] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
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

pub fn func_08014030() callconv(.c) void {
    if (!abi.enter(0x08014030)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x08014050);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08014074);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x08014054);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801493C() callconv(.c) void {
    if (!abi.enter(0x0801493C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (rt.CPU_Z) {
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
            abi.fetches(16);
            rt.r[2] = abi.read32(0x08014978);
            rt.r[1] = abi.read32(0x0801497C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x4C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x26);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x44, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(tail_low.func_0807B454, 0x08014971)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08014980() callconv(.c) void {
    if (!abi.enter(0x08014980)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[5] = abi.read32(0x080149A8);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x4C);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_08019FA8, 0x08014999)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x27, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
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

pub fn func_08014E20() callconv(.c) void {
    if (!abi.enter(0x08014E20)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], 0xC0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 8);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x20);
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 7);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        5 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        6 => {
            abi.fetches(3);
            continue :blk 10;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x10);
            continue :blk 5;
        },
        8 => {
            abi.fetches(3);
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x40);
            continue :blk 5;
        },
        10 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x8);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08015A88() callconv(.c) void {
    if (!abi.enter(0x08015A88)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
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
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        5 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        6 => {
            abi.fetches(3);
            continue :blk 10;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        8 => {
            abi.fetches(3);
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 5;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08015DA8() callconv(.c) void {
    if (!abi.enter(0x08015DA8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
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
            if (!abi.call(low_peel_1.func_08015A6C, 0x08015DB7)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_6.func_0801ABC0, 0x08015DBD)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08015DD0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_1.func_08015FF0, 0x08015DC9)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08015DD4() callconv(.c) void {
    if (!abi.enter(0x08015DD4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08015DFC);
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        5 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        6 => {
            abi.fetches(3);
            continue :blk 5;
        },
        7 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08015DF4);
            continue :blk 5;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08015E04);
            continue :blk 5;
        },
        10 => {
            abi.fetches(3);
            continue :blk 5;
        },
        11 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08015E0C);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08015FB4() callconv(.c) void {
    if (!abi.enter(0x08015FB4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x08015FD0);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801AC1C, 0x08015FC1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08015D1C, 0x08015FCB)) return;
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

pub fn func_08016950() callconv(.c) void {
    if (!abi.enter(0x08016950)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x08016964);
            rt.r[3] = abi.read32(rt.r[1] +% 0x10);
            rt.r[4] = abi.read32(0x08016968);
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[3], true);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            abi.write32(rt.r[1] +% 0x10, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.write32(rt.r[1] +% 0x10, rt.r[4]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[3] = abi.read32(rt.r[1] +% 0x14);
            rt.r[4] = abi.read32(0x08016980);
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[3], true);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (rt.CPU_C) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            abi.write32(rt.r[1] +% 0x14, rt.r[4]);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            abi.write32(rt.r[1] +% 0x14, rt.r[0]);
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080169B8() callconv(.c) void {
    if (!abi.enter(0x080169B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[2], rt.r[1] >> 24);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.r[0] = abi.read32(0x080169DC);
            rt.r[1] = abi.read32(0x080169E0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0xA8);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if (rt.CPU_C) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08017058() callconv(.c) void {
    if (!abi.enter(0x08017058)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(low_peel_4.func_08027F7C, 0x08017061)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(3);
            abi.write32(rt.r[4] +% 0x8, rt.r[0]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_080171F0() callconv(.c) void {
    if (!abi.enter(0x080171F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08017210);
            if (!abi.call(proc.func_08013B70, 0x080171FB)) return;
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
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[4] +% 0x8, rt.r[0]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_080174A0() callconv(.c) void {
    if (!abi.enter(0x080174A0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0xE);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0xE, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(low_peel_6.func_08017430, 0x080174B3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0xE);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(4);
            abi.write16(rt.r[4] +% 0xE, @truncate(rt.r[0]));
            abi.write32(rt.r[4] +% 0x8, rt.r[0]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_080174C4() callconv(.c) void {
    if (!abi.enter(0x080174C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0xE);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0xE, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(low_peel_6.func_08017430, 0x080174D7)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0xE);
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x72);
            if (!abi.call(sound.func_0803D880, 0x080174E3)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x080174F8);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            rt.r[1] = abi.read8(rt.r[1] +% 0x2);
            if (!abi.call(low_peel_6.func_08017560, 0x080174ED)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x080174FC);
            abi.write32(rt.r[4] +% 0x8, rt.r[0]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08017638() callconv(.c) void {
    if (!abi.enter(0x08017638)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[2] +% 0xE);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x4, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(16);
            rt.r[1] = abi.read32(0x08017670);
            rt.r[2] = abi.read16(rt.r[2] +% 0xE);
            abi.setRegNz(&rt.r[3], 0x70);
            rt.cpuSub(&rt.r[3], 0, rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08017674);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08017678);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(0x0801767C);
            if (!abi.call(func_0800FBEC, 0x0801766B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.write32(rt.r[2] +% 0x8, rt.r[1]);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[1]));
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

pub fn func_0801786C() callconv(.c) void {
    if (!abi.enter(0x0801786C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[2] = abi.read16(rt.r[1] +% 0xE);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            abi.write16(rt.r[1] +% 0xE, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x2E, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(15);
            rt.r[1] = abi.read32(0x080178A8);
            abi.setRegNz(&rt.r[3], 0x70);
            rt.cpuSub(&rt.r[3], 0, rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080178AC);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080178B0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(0x080178B4);
            if (!abi.call(func_0800FBEC, 0x080178A3)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
            if (!abi.call(hw.func_08010B18, 0x08017887)) return;
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

pub fn func_08017910() callconv(.c) void {
    if (!abi.enter(0x08017910)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(low_peel_6.func_08012480, 0x08017919)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(3);
            abi.write32(rt.r[4] +% 0x8, rt.r[0]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08017C74() callconv(.c) void {
    if (!abi.enter(0x08017C74)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x08017C9C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xA, true);
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
            abi.fetches(15);
            rt.r[2] = abi.read32(0x08017CA0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
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

pub fn func_08017CA8() callconv(.c) void {
    if (!abi.enter(0x08017CA8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x08017CD0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xA, true);
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
            abi.fetches(15);
            rt.r[2] = abi.read32(0x08017CD4);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
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

pub fn func_08017D18() callconv(.c) void {
    if (!abi.enter(0x08017D18)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08017D44);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xA, true);
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
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x12);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08017D48);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x12);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08017D4C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x11);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08017D94() callconv(.c) void {
    if (!abi.enter(0x08017D94)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08017DC0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xA, true);
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
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x11);
            if (!abi.call(state.func_0801BFD0, 0x08017DA7)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08017DC4);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[4] +% 0x8, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801820C() callconv(.c) void {
    if (!abi.enter(0x0801820C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            if (!abi.call(low_peel_7.func_0802D6BC, 0x08018217)) return;
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
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x0);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        3 => {
            abi.fetches(13);
            rt.r[2] = abi.read32(0x0801823C);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0801833C() callconv(.c) void {
    if (!abi.enter(0x0801833C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = abi.read32(0x08018358);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x9, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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

pub fn func_0801836C() callconv(.c) void {
    if (!abi.enter(0x0801836C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[3] = abi.read32(0x08018388);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
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
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x9, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08018CC8() callconv(.c) void {
    if (!abi.enter(0x08018CC8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            abi.pushLr();
            rt.r[2] = abi.read32(0x08018CF8);
            rt.r[0] = abi.read32(0x08018CFC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1B);
            rt.cpuSub(null, rt.r[0], 0x2, true);
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
            rt.r[0] = abi.read32(0x08018D00);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(tail_low.func_0807B44C, 0x08018CEB)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(state.func_08035220, 0x08018CF5)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08018D2C() callconv(.c) void {
    if (!abi.enter(0x08018D2C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x08018D54);
            rt.r[1] = abi.read32(0x08018D58);
            rt.r[3] = abi.read8(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[3] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x10, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08018E20, 0x08018D45)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(4);
            if (!abi.call(tail_low.func_0807B45C, 0x08018D4D)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08018D5C() callconv(.c) void {
    if (!abi.enter(0x08018D5C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            abi.pushLr();
            rt.r[2] = abi.read32(0x08018D7C);
            rt.r[1] = abi.read32(0x08018D80);
            rt.r[3] = abi.read8(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[3] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x14, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
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
            if (!abi.call(tail_low.func_0807B44C, 0x08018D79)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08018F94() callconv(.c) void {
    if (!abi.enter(0x08018F94)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.r[5] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x10, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[3] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(rt.r[2] +% 0x20);
            abi.setRegNz(&rt.r[0], rt.r[3] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0xC);
            rt.cpuSub(null, rt.r[4], 0x0, true);
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
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(tail_low.func_0807B45C, 0x08018FBF)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801926C() callconv(.c) void {
    if (!abi.enter(0x0801926C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08019284);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
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
            if (!abi.call(proc.func_08019608, 0x0801927F)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08019A1C() callconv(.c) void {
    if (!abi.enter(0x08019A1C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08019A64);
            if (!abi.call(low_peel_5.func_0806CB80, 0x08019A25)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
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
            abi.fetches(28);
            rt.r[1] = abi.read32(0x08019A68);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read32(rt.r[3] +% 0x20);
            abi.write32(rt.r[2] +% 0x4, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4A, true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4C, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[2] +% 0x3, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08019FA8() callconv(.c) void {
    if (!abi.enter(0x08019FA8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            abi.pushLr();
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x08019FC8);
            abi.setRegNz(&rt.r[0], 0x4C);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], 0x38);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            if (!abi.call(low_peel_6.func_08019FD8, 0x08019FD3)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(low_peel_6.func_08013248, 0x08019FC7)) return;
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

pub fn func_0801A06C() callconv(.c) void {
    if (!abi.enter(0x0801A06C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x0801A0A0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
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
            abi.fetches(3);
            rt.r[5] = abi.read32(0x0801A0A4);
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x4C);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08019B04, 0x0801A08F)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[0] = abi.read32(0x0801A0A0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801A124() callconv(.c) void {
    if (!abi.enter(0x0801A124)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x4C);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.r[0] = abi.read32(0x0801A158);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read32(rt.r[3] +% 0x14);
            rt.r[0] = abi.read32(rt.r[3] +% 0xC);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[3] +% 0x18);
            rt.r[0] = abi.read32(rt.r[3] +% 0x10);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xFF, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xFF, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801A15C() callconv(.c) void {
    if (!abi.enter(0x0801A15C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x4C);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.r[0] = abi.read32(0x0801A180);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[1] +% 0x18);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xFF, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xFF, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801A660() callconv(.c) void {
    if (!abi.enter(0x0801A660)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x0801A694);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
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
            abi.fetches(3);
            rt.r[5] = abi.read32(0x0801A698);
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x4C);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0801A420, 0x0801A683)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[0] = abi.read32(0x0801A694);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801AFC8() callconv(.c) void {
    if (!abi.enter(0x0801AFC8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x0801AFDC);
            if (!abi.call(decls.func_080797FC, 0x0801AFD1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801B654() callconv(.c) void {
    if (!abi.enter(0x0801B654)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.r[0] = abi.read32(0x0801B670);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(low_peel_5.func_08079908, 0x0801B669)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801B684() callconv(.c) void {
    if (!abi.enter(0x0801B684)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0801B69C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0801B6B4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            if (!abi.call(tail_low.func_0807B44C, 0x0801B6AD)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0801B6A0);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 9);
            if (!abi.call(low_peel_1.func_0801B80C, 0x0801B699)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801B7B8() callconv(.c) void {
    if (!abi.enter(0x0801B7B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x0801B7D4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08079BE8, 0x0801B7D1)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[1] << 12);
            rt.r[1] = abi.read32(0x0801B7F0);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            if (!abi.call(low_peel_1.func_0801B7F4, 0x0801B7E9)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
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

pub fn func_0801B9E0() callconv(.c) void {
    if (!abi.enter(0x0801B9E0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801B910, 0x0801B9F1)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_2.func_0807A868, 0x0801B9F7)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801BA80() callconv(.c) void {
    if (!abi.enter(0x0801BA80)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x0801BA9C);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[4] +% 0x0, rt.r[3]);
            rt.r[2] = abi.read32(0x0801BAA0);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[2] +% 0x0, rt.r[1]);
            rt.cpuSub(null, rt.r[3], 0x7, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x8, true);
            abi.write32(rt.r[4] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801BB9C() callconv(.c) void {
    if (!abi.enter(0x0801BB9C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(11);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
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

pub fn func_0801C07C() callconv(.c) void {
    if (!abi.enter(0x0801C07C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(co.func_0801C000, 0x0801C08B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_6.func_0801C018, 0x0801C093)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801C1FC() callconv(.c) void {
    if (!abi.enter(0x0801C1FC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xA, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0xB, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x15, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801C224() callconv(.c) void {
    if (!abi.enter(0x0801C224)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x2, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0801C240() callconv(.c) void {
    if (!abi.enter(0x0801C240)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
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
            abi.fetches(5);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x2, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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

pub fn func_0801C888() callconv(.c) void {
    if (!abi.enter(0x0801C888)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[2] +% 0x1E);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0x1E, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[3] = abi.read32(0x0801C8C0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xA, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0801C8C4);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[2] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0801C8C8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0801C8BD)) return;
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

pub fn func_0801C8CC() callconv(.c) void {
    if (!abi.enter(0x0801C8CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[2] +% 0x1E);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0x1E, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[3] = abi.read32(0x0801C904);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0801C908);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[2] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0801C90C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0801C901)) return;
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

pub fn func_0801C9DC() callconv(.c) void {
    if (!abi.enter(0x0801C9DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0801CA10);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08063358, 0x0801C9E9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.write16(rt.r[4] +% 0x20, @truncate(rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(14);
            rt.r[2] = abi.read32(0x0801CA14);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.r[1] = abi.read8(rt.r[1] +% 0x3);
            if (!abi.call(decls.func_0802928C, 0x0801CA0B)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0801CB7C() callconv(.c) void {
    if (!abi.enter(0x0801CB7C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
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
            abi.fetches(13);
            rt.r[2] = abi.read32(0x0801CBA4);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.r[1] = abi.read8(rt.r[1] +% 0x3);
            if (!abi.call(ui.func_0807427C, 0x0801CB9F)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801DE88() callconv(.c) void {
    if (!abi.enter(0x0801DE88)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[3] = abi.read32(0x0801DEB4);
            rt.r[0] = abi.read32(rt.r[3] +% 0x4);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x4, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[1], 0xAF, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801F000() callconv(.c) void {
    if (!abi.enter(0x0801F000)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_0801EE60, 0x0801F009)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(decls.func_0801EE60, 0x0801F00F)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x3);
            if (!abi.call(decls.func_0801EE60, 0x0801F015)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x4);
            if (!abi.call(decls.func_0801EE60, 0x0801F01B)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0801F002() callconv(.c) void {
    if (!abi.enter(0x0801F002)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_0801EE60, 0x0801F009)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(decls.func_0801EE60, 0x0801F00F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x3);
            if (!abi.call(decls.func_0801EE60, 0x0801F015)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x4);
            if (!abi.call(decls.func_0801EE60, 0x0801F01B)) return;
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

pub fn func_0801F140() callconv(.c) void {
    if (!abi.enter(0x0801F140)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[2] = abi.read32(0x0801F174);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.r[4] = abi.read32(0x0801F178);
            continue :blk 3;
        },
        3 => {
            abi.fetches(16);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[6] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[3]);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.r[2] = abi.read16(rt.r[2] +% 0x2);
            rt.cpuSub(null, rt.r[3], rt.r[2], true);
            if (!rt.CPU_C) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801FAF2() callconv(.c) void {
    if (!abi.enter(0x0801FAF2)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            ldmRegs(0, &.{ 2, 3, 4, 5, 6 });
            abi.setRegNz(&rt.r[0], 0);
            rt.cpuSub(&rt.r[6], rt.r[6], 0xC0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0801FB0C);
            rt.r[1] = abi.read32(0x0801FB10);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0xD0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], rt.r[2] << 4);
            if (!abi.call(dma.func_0800FDA4, 0x0801FB09)) return;
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

pub fn func_0801FAF4() callconv(.c) void {
    if (!abi.enter(0x0801FAF4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            ldmRegs(0, &.{ 2, 3, 4, 5, 6 });
            abi.setRegNz(&rt.r[0], 0);
            rt.cpuSub(&rt.r[6], rt.r[6], 0xC0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0801FB0C);
            rt.r[1] = abi.read32(0x0801FB10);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0xD0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], rt.r[2] << 4);
            if (!abi.call(dma.func_0800FDA4, 0x0801FB09)) return;
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

pub fn func_08020200() callconv(.c) void {
    if (!abi.enter(0x08020200)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            abi.write16(rt.r[3] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x40, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(16);
            rt.r[2] = abi.read32(0x08020254);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08020258);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write16(rt.r[3] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x40, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[3] = abi.read32(0x0802025C);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08020202() callconv(.c) void {
    if (!abi.enter(0x08020202)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            abi.write16(rt.r[3] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x40, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(16);
            rt.r[2] = abi.read32(0x08020254);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08020258);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write16(rt.r[3] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x40, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[3] = abi.read32(0x0802025C);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08020260() callconv(.c) void {
    if (!abi.enter(0x08020260)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0802027C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08020298);
            rt.r[1] = abi.read32(0x0802029C);
            abi.setRegNz(&rt.r[2], 0x80);
            if (!abi.call(dma.func_0800FDA4, 0x08020293)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08020280);
            rt.r[1] = abi.read32(0x08020284);
            abi.setRegNz(&rt.r[2], 0x80);
            if (!abi.call(dma.func_0800FDA4, 0x08020279)) return;
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

pub fn func_08020302() callconv(.c) void {
    if (!abi.enter(0x08020302)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x0802032C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x81);
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.setRegNz(&rt.r[2], 0x1E);
            if (!abi.call(dma.func_08011374, 0x08020315)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
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

pub fn func_080205EE() callconv(.c) void {
    if (!abi.enter(0x080205EE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[0], true);
            rt.cpuSub(&rt.r[5], rt.r[5], rt.r[7], true);
            rt.r[2] = abi.read32(0x0802063C);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[6], 0x0, true);
            if (!abi.call(hw.func_0801B888, 0x08020601)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            rt.r[4] = abi.read32(rt.r[13] +% 0x4);
            rt.r[4] +%= rt.r[10];
            rt.cpuSub(&rt.r[4], rt.r[4], rt.r[7], true);
            rt.r[0] = rt.r[8];
            abi.setRegNz(&rt.r[4], rt.r[4] | rt.r[0]);
            rt.r[2] = abi.read32(0x08020640);
            rt.r[0] = rt.r[9];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[6], 0x0, true);
            if (!abi.call(hw.func_0801B888, 0x08020617)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.r[2] = abi.read32(0x08020644);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[6], 0x0, true);
            if (!abi.call(hw.func_0801B888, 0x08020623)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.r[13] +%= 0x8;
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

pub fn func_080212B8() callconv(.c) void {
    if (!abi.enter(0x080212B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x080212EC);
            rt.r[2] = abi.read32(0x080212F0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[3] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if (rt.CPU_C) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[3] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read16(rt.r[1] +% 0x2);
            rt.r[2] = abi.read16(rt.r[2] +% 0x2);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (rt.CPU_C) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08021EA4() callconv(.c) void {
    if (!abi.enter(0x08021EA4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08021EBC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x28);
            if (!abi.call(math.func_0807B6AC, 0x08021EB1)) return;
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
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08021ECC);
            rt.r[1] = abi.read32(0x08021ED0);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(dma.func_0800FDA4, 0x08021ECB)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08021EE4);
            rt.r[1] = abi.read32(0x08021EE8);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(dma.func_0800FDA4, 0x08021EDF)) return;
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

pub fn func_08022814() callconv(.c) void {
    if (!abi.enter(0x08022814)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.r[1] = abi.read32(0x08022834);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0xB, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x5C, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(campaign.func_0803F148, 0x08022849)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08022838);
            abi.setRegNz(&rt.r[1], rt.r[2] << 4);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1C);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
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

pub fn func_08022850() callconv(.c) void {
    if (!abi.enter(0x08022850)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.r[1] = abi.read32(0x08022870);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0xB, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x5C, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(low_peel_2.func_0803F128, 0x08022885)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08022874);
            abi.setRegNz(&rt.r[1], rt.r[2] << 4);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x18, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_080228B0() callconv(.c) void {
    if (!abi.enter(0x080228B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(campaign.func_0803F048, 0x080228B9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080228D8);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x080228C8);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.write8(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802297C() callconv(.c) void {
    if (!abi.enter(0x0802297C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], 0x12);
            if (!abi.call(campaign.func_0803F048, 0x08022985)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080229A4);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08022994);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.write8(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080238D0() callconv(.c) void {
    if (!abi.enter(0x080238D0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = abi.read32(0x08023900);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 8);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.r[4] = abi.read32(0x08023904);
            abi.setRegNz(&rt.r[2], 0x31);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08023908() callconv(.c) void {
    if (!abi.enter(0x08023908)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x08023938);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[3] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0802393C);
            rt.r[0] = abi.read8(rt.r[0] +% 0xD);
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
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_0801EC90, 0x08023935)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08023940() callconv(.c) void {
    if (!abi.enter(0x08023940)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x08023970);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0xFD);
            rt.r[3] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08023974);
            rt.r[0] = abi.read8(rt.r[0] +% 0xD);
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
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0801EC90, 0x0802396B)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080240EC() callconv(.c) void {
    if (!abi.enter(0x080240EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08024110);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x33, true);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08024114);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        6 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08024128() callconv(.c) void {
    if (!abi.enter(0x08024128)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[2] = abi.read32(0x0802414C);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[2] +% 0x4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[2] +% 0x4, rt.r[0]);
            rt.r[1] = abi.read32(0x08024150);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.write32(rt.r[2] +% 0x4, rt.r[1]);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0802417C() callconv(.c) void {
    if (!abi.enter(0x0802417C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.r[2] = abi.read8(rt.r[4] +% 0x6);
            abi.setRegNz(&rt.r[3], rt.r[2] << 25);
            abi.setRegNz(&rt.r[0], rt.r[3] >> 25);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write8(rt.r[4] +% 0x6, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x7F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x80);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            abi.write8(rt.r[4] +% 0x6, @truncate(rt.r[1]));
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

pub fn func_080241B0() callconv(.c) void {
    if (!abi.enter(0x080241B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_4.func_08036720, 0x080241B7)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080241D0);
            rt.r[0] = abi.read8(rt.r[0] +% 0xD);
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
            abi.fetches(8);
            rt.r[0] = abi.read32(0x080241D4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x080241D8);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            if (!abi.call(func_0802417C, 0x080241CB)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_080242B8() callconv(.c) void {
    if (!abi.enter(0x080242B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            if (!abi.call(low_peel_7.func_0802425C, 0x080242CB)) return;
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08023EDC, 0x080242D3)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        else => unreachable,
    }
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08000302, .{ .name = "func_08000302", .linkage = .strong });
        @export(&func_08000400, .{ .name = "func_08000400", .linkage = .strong });
        @export(&func_08000904, .{ .name = "func_08000904", .linkage = .strong });
        @export(&func_08000A3C, .{ .name = "func_08000A3C", .linkage = .strong });
        @export(&func_08000D68, .{ .name = "func_08000D68", .linkage = .strong });
        @export(&func_08000E04, .{ .name = "func_08000E04", .linkage = .strong });
        @export(&func_08000E40, .{ .name = "func_08000E40", .linkage = .strong });
        @export(&func_08000EE4, .{ .name = "func_08000EE4", .linkage = .strong });
        @export(&func_0800124C, .{ .name = "func_0800124C", .linkage = .strong });
        @export(&func_0800128C, .{ .name = "func_0800128C", .linkage = .strong });
        @export(&func_0800135A, .{ .name = "func_0800135A", .linkage = .strong });
        @export(&func_08002CD4, .{ .name = "func_08002CD4", .linkage = .strong });
        @export(&func_08003602, .{ .name = "func_08003602", .linkage = .strong });
        @export(&func_08003714, .{ .name = "func_08003714", .linkage = .strong });
        @export(&func_0800373C, .{ .name = "func_0800373C", .linkage = .strong });
        @export(&func_080048F8, .{ .name = "func_080048F8", .linkage = .strong });
        @export(&func_08005528, .{ .name = "func_08005528", .linkage = .strong });
        @export(&func_08005570, .{ .name = "func_08005570", .linkage = .strong });
        @export(&func_080056F0, .{ .name = "func_080056F0", .linkage = .strong });
        @export(&func_08005CE8, .{ .name = "func_08005CE8", .linkage = .strong });
        @export(&func_08005D14, .{ .name = "func_08005D14", .linkage = .strong });
        @export(&func_08007028, .{ .name = "func_08007028", .linkage = .strong });
        @export(&func_08007860, .{ .name = "func_08007860", .linkage = .strong });
        @export(&func_08007AE8, .{ .name = "func_08007AE8", .linkage = .strong });
        @export(&func_08008306, .{ .name = "func_08008306", .linkage = .strong });
        @export(&func_0800875C, .{ .name = "func_0800875C", .linkage = .strong });
        @export(&func_08008818, .{ .name = "func_08008818", .linkage = .strong });
        @export(&func_08008832, .{ .name = "func_08008832", .linkage = .strong });
        @export(&func_08008860, .{ .name = "func_08008860", .linkage = .strong });
        @export(&func_08008F10, .{ .name = "func_08008F10", .linkage = .strong });
        @export(&func_08009F28, .{ .name = "func_08009F28", .linkage = .strong });
        @export(&func_0800AADC, .{ .name = "func_0800AADC", .linkage = .strong });
        @export(&func_0800B000, .{ .name = "func_0800B000", .linkage = .strong });
        @export(&func_0800B768, .{ .name = "func_0800B768", .linkage = .strong });
        @export(&func_0800B7A4, .{ .name = "func_0800B7A4", .linkage = .strong });
        @export(&func_0800B9B0, .{ .name = "func_0800B9B0", .linkage = .strong });
        @export(&func_0800C004, .{ .name = "func_0800C004", .linkage = .strong });
        @export(&func_0800C082, .{ .name = "func_0800C082", .linkage = .strong });
        @export(&func_0800C348, .{ .name = "func_0800C348", .linkage = .strong });
        @export(&func_0800C9B4, .{ .name = "func_0800C9B4", .linkage = .strong });
        @export(&func_0800C9D4, .{ .name = "func_0800C9D4", .linkage = .strong });
        @export(&func_0800E8EC, .{ .name = "func_0800E8EC", .linkage = .strong });
        @export(&func_0800EB10, .{ .name = "func_0800EB10", .linkage = .strong });
        @export(&func_0800EBFA, .{ .name = "func_0800EBFA", .linkage = .strong });
        @export(&func_0800EDF4, .{ .name = "func_0800EDF4", .linkage = .strong });
        @export(&func_0800EE1C, .{ .name = "func_0800EE1C", .linkage = .strong });
        @export(&func_0800F1F6, .{ .name = "func_0800F1F6", .linkage = .strong });
        @export(&func_0800F1FA, .{ .name = "func_0800F1FA", .linkage = .strong });
        @export(&func_0800F300, .{ .name = "func_0800F300", .linkage = .strong });
        @export(&func_0800F444, .{ .name = "func_0800F444", .linkage = .strong });
        @export(&func_0800F490, .{ .name = "func_0800F490", .linkage = .strong });
        @export(&func_0800F5E4, .{ .name = "func_0800F5E4", .linkage = .strong });
        @export(&func_0800F5EA, .{ .name = "func_0800F5EA", .linkage = .strong });
        @export(&func_0800F7B0, .{ .name = "func_0800F7B0", .linkage = .strong });
        @export(&func_0800F7F8, .{ .name = "func_0800F7F8", .linkage = .strong });
        @export(&func_0800F7FA, .{ .name = "func_0800F7FA", .linkage = .strong });
        @export(&func_0800F824, .{ .name = "func_0800F824", .linkage = .strong });
        @export(&func_0800F86C, .{ .name = "func_0800F86C", .linkage = .strong });
        @export(&func_0800FAF4, .{ .name = "func_0800FAF4", .linkage = .strong });
        @export(&func_0800FAF6, .{ .name = "func_0800FAF6", .linkage = .strong });
        @export(&func_0800FAFA, .{ .name = "func_0800FAFA", .linkage = .strong });
        @export(&func_0800FBEC, .{ .name = "func_0800FBEC", .linkage = .strong });
        @export(&func_0800FBF4, .{ .name = "func_0800FBF4", .linkage = .strong });
        @export(&func_0800FC74, .{ .name = "func_0800FC74", .linkage = .strong });
        @export(&func_0800FC9C, .{ .name = "func_0800FC9C", .linkage = .strong });
        @export(&func_0800FCD4, .{ .name = "func_0800FCD4", .linkage = .strong });
        @export(&func_0800FD10, .{ .name = "func_0800FD10", .linkage = .strong });
        @export(&func_0800FE24, .{ .name = "func_0800FE24", .linkage = .strong });
        @export(&func_0800FEF8, .{ .name = "func_0800FEF8", .linkage = .strong });
        @export(&func_0800FEFE, .{ .name = "func_0800FEFE", .linkage = .strong });
        @export(&func_0800FF02, .{ .name = "func_0800FF02", .linkage = .strong });
        @export(&func_0800FF06, .{ .name = "func_0800FF06", .linkage = .strong });
        @export(&func_0800FFFE, .{ .name = "func_0800FFFE", .linkage = .strong });
        @export(&func_08010000, .{ .name = "func_08010000", .linkage = .strong });
        @export(&func_08010002, .{ .name = "func_08010002", .linkage = .strong });
        @export(&func_08010006, .{ .name = "func_08010006", .linkage = .strong });
        @export(&func_0801000A, .{ .name = "func_0801000A", .linkage = .strong });
        @export(&func_0801000C, .{ .name = "func_0801000C", .linkage = .strong });
        @export(&func_08010108, .{ .name = "func_08010108", .linkage = .strong });
        @export(&func_080104D4, .{ .name = "func_080104D4", .linkage = .strong });
        @export(&func_08010602, .{ .name = "func_08010602", .linkage = .strong });
        @export(&func_08010A9C, .{ .name = "func_08010A9C", .linkage = .strong });
        @export(&func_08010BA4, .{ .name = "func_08010BA4", .linkage = .strong });
        @export(&func_08010BCC, .{ .name = "func_08010BCC", .linkage = .strong });
        @export(&func_08010BF8, .{ .name = "func_08010BF8", .linkage = .strong });
        @export(&func_08010EDC, .{ .name = "func_08010EDC", .linkage = .strong });
        @export(&func_08011008, .{ .name = "func_08011008", .linkage = .strong });
        @export(&func_08011010, .{ .name = "func_08011010", .linkage = .strong });
        @export(&func_08011014, .{ .name = "func_08011014", .linkage = .strong });
        @export(&func_08011090, .{ .name = "func_08011090", .linkage = .strong });
        @export(&func_080110B0, .{ .name = "func_080110B0", .linkage = .strong });
        @export(&func_080110DC, .{ .name = "func_080110DC", .linkage = .strong });
        @export(&func_08011114, .{ .name = "func_08011114", .linkage = .strong });
        @export(&func_08011484, .{ .name = "func_08011484", .linkage = .strong });
        @export(&func_0801163C, .{ .name = "func_0801163C", .linkage = .strong });
        @export(&func_080116D8, .{ .name = "func_080116D8", .linkage = .strong });
        @export(&func_08011910, .{ .name = "func_08011910", .linkage = .strong });
        @export(&func_0801193C, .{ .name = "func_0801193C", .linkage = .strong });
        @export(&func_08011968, .{ .name = "func_08011968", .linkage = .strong });
        @export(&func_0801222C, .{ .name = "func_0801222C", .linkage = .strong });
        @export(&func_08012C60, .{ .name = "func_08012C60", .linkage = .strong });
        @export(&func_08012CC4, .{ .name = "func_08012CC4", .linkage = .strong });
        @export(&func_08012CF0, .{ .name = "func_08012CF0", .linkage = .strong });
        @export(&func_08012D8C, .{ .name = "func_08012D8C", .linkage = .strong });
        @export(&func_08012E14, .{ .name = "func_08012E14", .linkage = .strong });
        @export(&func_080131E0, .{ .name = "func_080131E0", .linkage = .strong });
        @export(&func_08013508, .{ .name = "func_08013508", .linkage = .strong });
        @export(&func_080136A4, .{ .name = "func_080136A4", .linkage = .strong });
        @export(&func_08013E48, .{ .name = "func_08013E48", .linkage = .strong });
        @export(&func_08013F44, .{ .name = "func_08013F44", .linkage = .strong });
        @export(&func_08014030, .{ .name = "func_08014030", .linkage = .strong });
        @export(&func_0801493C, .{ .name = "func_0801493C", .linkage = .strong });
        @export(&func_08014980, .{ .name = "func_08014980", .linkage = .strong });
        @export(&func_08014E20, .{ .name = "func_08014E20", .linkage = .strong });
        @export(&func_08015A88, .{ .name = "func_08015A88", .linkage = .strong });
        @export(&func_08015DA8, .{ .name = "func_08015DA8", .linkage = .strong });
        @export(&func_08015DD4, .{ .name = "func_08015DD4", .linkage = .strong });
        @export(&func_08015FB4, .{ .name = "func_08015FB4", .linkage = .strong });
        @export(&func_08016950, .{ .name = "func_08016950", .linkage = .strong });
        @export(&func_080169B8, .{ .name = "func_080169B8", .linkage = .strong });
        @export(&func_08017058, .{ .name = "func_08017058", .linkage = .strong });
        @export(&func_080171F0, .{ .name = "func_080171F0", .linkage = .strong });
        @export(&func_080174A0, .{ .name = "func_080174A0", .linkage = .strong });
        @export(&func_080174C4, .{ .name = "func_080174C4", .linkage = .strong });
        @export(&func_08017638, .{ .name = "func_08017638", .linkage = .strong });
        @export(&func_0801786C, .{ .name = "func_0801786C", .linkage = .strong });
        @export(&func_08017910, .{ .name = "func_08017910", .linkage = .strong });
        @export(&func_08017C74, .{ .name = "func_08017C74", .linkage = .strong });
        @export(&func_08017CA8, .{ .name = "func_08017CA8", .linkage = .strong });
        @export(&func_08017D18, .{ .name = "func_08017D18", .linkage = .strong });
        @export(&func_08017D94, .{ .name = "func_08017D94", .linkage = .strong });
        @export(&func_0801820C, .{ .name = "func_0801820C", .linkage = .strong });
        @export(&func_0801833C, .{ .name = "func_0801833C", .linkage = .strong });
        @export(&func_0801836C, .{ .name = "func_0801836C", .linkage = .strong });
        @export(&func_08018CC8, .{ .name = "func_08018CC8", .linkage = .strong });
        @export(&func_08018D2C, .{ .name = "func_08018D2C", .linkage = .strong });
        @export(&func_08018D5C, .{ .name = "func_08018D5C", .linkage = .strong });
        @export(&func_08018F94, .{ .name = "func_08018F94", .linkage = .strong });
        @export(&func_0801926C, .{ .name = "func_0801926C", .linkage = .strong });
        @export(&func_08019A1C, .{ .name = "func_08019A1C", .linkage = .strong });
        @export(&func_08019FA8, .{ .name = "func_08019FA8", .linkage = .strong });
        @export(&func_0801A06C, .{ .name = "func_0801A06C", .linkage = .strong });
        @export(&func_0801A124, .{ .name = "func_0801A124", .linkage = .strong });
        @export(&func_0801A15C, .{ .name = "func_0801A15C", .linkage = .strong });
        @export(&func_0801A660, .{ .name = "func_0801A660", .linkage = .strong });
        @export(&func_0801AFC8, .{ .name = "func_0801AFC8", .linkage = .strong });
        @export(&func_0801B654, .{ .name = "func_0801B654", .linkage = .strong });
        @export(&func_0801B684, .{ .name = "func_0801B684", .linkage = .strong });
        @export(&func_0801B7B8, .{ .name = "func_0801B7B8", .linkage = .strong });
        @export(&func_0801B9E0, .{ .name = "func_0801B9E0", .linkage = .strong });
        @export(&func_0801BA80, .{ .name = "func_0801BA80", .linkage = .strong });
        @export(&func_0801BB9C, .{ .name = "func_0801BB9C", .linkage = .strong });
        @export(&func_0801C07C, .{ .name = "func_0801C07C", .linkage = .strong });
        @export(&func_0801C1FC, .{ .name = "func_0801C1FC", .linkage = .strong });
        @export(&func_0801C224, .{ .name = "func_0801C224", .linkage = .strong });
        @export(&func_0801C240, .{ .name = "func_0801C240", .linkage = .strong });
        @export(&func_0801C888, .{ .name = "func_0801C888", .linkage = .strong });
        @export(&func_0801C8CC, .{ .name = "func_0801C8CC", .linkage = .strong });
        @export(&func_0801C9DC, .{ .name = "func_0801C9DC", .linkage = .strong });
        @export(&func_0801CB7C, .{ .name = "func_0801CB7C", .linkage = .strong });
        @export(&func_0801DE88, .{ .name = "func_0801DE88", .linkage = .strong });
        @export(&func_0801F000, .{ .name = "func_0801F000", .linkage = .strong });
        @export(&func_0801F002, .{ .name = "func_0801F002", .linkage = .strong });
        @export(&func_0801F140, .{ .name = "func_0801F140", .linkage = .strong });
        @export(&func_0801FAF2, .{ .name = "func_0801FAF2", .linkage = .strong });
        @export(&func_0801FAF4, .{ .name = "func_0801FAF4", .linkage = .strong });
        @export(&func_08020200, .{ .name = "func_08020200", .linkage = .strong });
        @export(&func_08020202, .{ .name = "func_08020202", .linkage = .strong });
        @export(&func_08020260, .{ .name = "func_08020260", .linkage = .strong });
        @export(&func_08020302, .{ .name = "func_08020302", .linkage = .strong });
        @export(&func_080205EE, .{ .name = "func_080205EE", .linkage = .strong });
        @export(&func_080212B8, .{ .name = "func_080212B8", .linkage = .strong });
        @export(&func_08021EA4, .{ .name = "func_08021EA4", .linkage = .strong });
        @export(&func_08022814, .{ .name = "func_08022814", .linkage = .strong });
        @export(&func_08022850, .{ .name = "func_08022850", .linkage = .strong });
        @export(&func_080228B0, .{ .name = "func_080228B0", .linkage = .strong });
        @export(&func_0802297C, .{ .name = "func_0802297C", .linkage = .strong });
        @export(&func_080238D0, .{ .name = "func_080238D0", .linkage = .strong });
        @export(&func_08023908, .{ .name = "func_08023908", .linkage = .strong });
        @export(&func_08023940, .{ .name = "func_08023940", .linkage = .strong });
        @export(&func_080240EC, .{ .name = "func_080240EC", .linkage = .strong });
        @export(&func_08024128, .{ .name = "func_08024128", .linkage = .strong });
        @export(&func_0802417C, .{ .name = "func_0802417C", .linkage = .strong });
        @export(&func_080241B0, .{ .name = "func_080241B0", .linkage = .strong });
        @export(&func_080242B8, .{ .name = "func_080242B8", .linkage = .strong });
    }
}

test "low_peel_3 exports are callable" {
    try std.testing.expect(@TypeOf(func_08000302) == fn () callconv(.c) void);
    try std.testing.expect(@TypeOf(func_080242B8) == fn () callconv(.c) void);
}
