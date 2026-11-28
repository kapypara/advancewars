//! Low-ROM (< 0x08080000) block-peeled wave 9 (61..120 reachable lines, remaining 209).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const battle = @import("battle.zig");
const bios = @import("bios.zig");
const campaign = @import("campaign.zig");
const clusters_low_2 = @import("clusters_low_2.zig");
const co = @import("co.zig");
const dma = @import("dma.zig");
const hw = @import("hw.zig");
const low_peel_1 = @import("low_peel_1.zig");
const low_peel_10 = @import("low_peel_10.zig");
const low_peel_12 = @import("low_peel_12.zig");
const low_peel_13 = @import("low_peel_13.zig");
const low_peel_2 = @import("low_peel_2.zig");
const low_peel_3 = @import("low_peel_3.zig");
const low_peel_4 = @import("low_peel_4.zig");
const low_peel_5 = @import("low_peel_5.zig");
const low_peel_6 = @import("low_peel_6.zig");
const low_peel_7 = @import("low_peel_7.zig");
const low_peel_8 = @import("low_peel_8.zig");
const map = @import("map.zig");
const math = @import("math.zig");
const proc = @import("proc.zig");
const sound = @import("sound.zig");
const sprite_anim = @import("sprite_anim.zig");
const state = @import("state.zig");
const tail_low = @import("tail_low.zig");
const turn = @import("turn.zig");
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

pub fn func_0805F150() callconv(.c) void {
    if (!abi.enter(0x0805F150)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.r[6] = abi.read32(0x0805F198);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(low_peel_8.func_0805EFC0, 0x0805F15D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(25);
            rt.r[0] = abi.read32(0x0805F19C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[3] +% 0x1);
            abi.setRegNz(&rt.r[2], rt.r[0] << 1);
            rt.r[7] = abi.read32(0x0805F1A0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[7], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[2] = abi.read32(0x0805F1A4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x3, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0805F1B0() callconv(.c) void {
    if (!abi.enter(0x0805F1B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0xA0;
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 24);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = abi.read32(0x0805F224);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[12] = rt.r[0];
            rt.r[0] = abi.read16(rt.r[2] +% 0x2);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[6] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.r[7] = abi.read32(0x0805F228);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[7], true);
            rt.r[4] = rt.r[13];
            continue :blk 5;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            continue :blk 6;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0xA0;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(10);
            rt.r[7] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[6], true);
            stmRegs(4, &.{ 0 });
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x1, true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.r[7] = rt.r[13];
            rt.cpuAdd(&rt.r[3], rt.r[7], rt.r[0], true);
            continue :blk 10;
        },
        9 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 4;
        },
        10 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0805F3F2() callconv(.c) void {
    if (!abi.enter(0x0805F3F2)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x28, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[9] = rt.r[0];
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = rt.r[9];
            abi.setRegNz(&rt.r[1], rt.armAsr(rt.r[1], rt.r[4] & 0xFF));
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuAdd(&rt.r[6], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], rt.r[4] << 6);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(15);
            rt.r[0] = abi.read32(0x0805F478);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0805F47C);
            rt.r[8] = rt.r[0];
            rt.r[0] = abi.read32(0x0805F480);
            rt.r[12] = rt.r[0];
            abi.setRegNz(&rt.r[7], 0x1);
            rt.cpuSub(&rt.r[7], 0, rt.r[7], true);
            abi.setRegNz(&rt.r[0], rt.r[4] << 7);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[2], rt.r[3], rt.r[2], true);
            continue :blk 7;
        },
        6 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(7);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.r[0] +%= rt.r[8];
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 4;
        },
        10 => {
            abi.fetches(13);
            rt.r[3] = abi.read8(rt.r[1] +% 0x3);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.r[0] +%= rt.r[12];
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], rt.r[7], true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0805F3FE() callconv(.c) void {
    if (!abi.enter(0x0805F3FE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuAdd(&rt.r[6], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], rt.r[4] << 6);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(15);
            rt.r[0] = abi.read32(0x0805F478);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0805F47C);
            rt.r[8] = rt.r[0];
            rt.r[0] = abi.read32(0x0805F480);
            rt.r[12] = rt.r[0];
            abi.setRegNz(&rt.r[7], 0x1);
            rt.cpuSub(&rt.r[7], 0, rt.r[7], true);
            abi.setRegNz(&rt.r[0], rt.r[4] << 7);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[2], rt.r[3], rt.r[2], true);
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            rt.r[1] = rt.r[9];
            abi.setRegNz(&rt.r[1], rt.armAsr(rt.r[1], rt.r[4] & 0xFF));
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 0;
        },
        5 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.r[0] +%= rt.r[8];
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 2;
        },
        9 => {
            abi.fetches(13);
            rt.r[3] = abi.read8(rt.r[1] +% 0x3);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.r[0] +%= rt.r[12];
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], rt.r[7], true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            continue :blk 8;
        },
        else => unreachable,
    }
}

pub fn func_0805F6A4() callconv(.c) void {
    if (!abi.enter(0x0805F6A4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x0805F70C);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x0805F710);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[7] = abi.read32(0x0805F714);
            abi.setRegNz(&rt.r[6], 0x1);
            rt.cpuSub(&rt.r[6], 0, rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.r[5] = abi.read32(0x0805F718);
            rt.cpuSub(&rt.r[2], rt.r[3], rt.r[2], true);
            continue :blk 3;
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
            abi.fetches(7);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x7);
            rt.r[3] = abi.read8(rt.r[1] +% 0x9);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        8 => {
            abi.fetches(13);
            rt.r[3] = abi.read8(rt.r[1] +% 0x3);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], rt.r[6], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_0805FBF6() callconv(.c) void {
    if (!abi.enter(0x0805FBF6)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
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
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0805FC7C);
            abi.setRegNz(&rt.r[1], rt.r[6] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x78, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
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
        4 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x0805FC80);
            rt.r[10] = rt.r[0];
            rt.r[0] = abi.read32(0x0805FC84);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.r[0] +%= rt.r[10];
            rt.r[0] = abi.read8(rt.r[0] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x10, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(14);
            rt.r[2] = abi.read32(0x0805FC88);
            rt.r[0] = abi.read32(0x0805FC8C);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.r[12] = rt.r[0];
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x0805FC90);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[7], rt.r[7] & rt.r[0]);
            rt.cpuSub(null, rt.r[7], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[2], 0x64);
            rt.r[12] +%= rt.r[2];
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.r[1] = rt.r[8];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[12], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            rt.r[2] = rt.r[12];
            abi.write32(rt.r[1] +% 0x0, rt.r[2]);
            rt.r[0] = rt.r[9];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[6]));
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0805FC94() callconv(.c) void {
    if (!abi.enter(0x0805FC94)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(35);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.r[0] = abi.read32(0x0805FD0C);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x0805FD10);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0805FD14);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[6] << 1);
            rt.r[4] = abi.read32(0x0805FD18);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[2] = abi.read32(0x0805FD1C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1A, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(9);
            rt.r[4] = abi.read32(0x0805FD20);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[4]));
            rt.cpuSub(&rt.r[0], rt.r[7], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_0805FD30, 0x0805FCE5)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_0805FD30, 0x0805FCEF)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[1], rt.r[6], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_0805FD30, 0x0805FCF9)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_0805FD30, 0x0805FD03)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[5] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[4], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0805FDDC() callconv(.c) void {
    if (!abi.enter(0x0805FDDC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x78);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[4]));
            rt.r[1] = abi.read32(0x0805FE28);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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
            abi.fetches(3);
            rt.r[2] = abi.read32(0x0805FE2C);
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0805FE30);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[5] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[5] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
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
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[4]));
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0805FDF2() callconv(.c) void {
    if (!abi.enter(0x0805FDF2)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0805FE30);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[5] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[5] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if (!rt.CPU_Z) {
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
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[4]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08060732() callconv(.c) void {
    if (!abi.enter(0x08060732)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[3], 0x78);
            if (!abi.call(tail_low.func_0807B45C, 0x08060739)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08060858, 0x0806073F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(low_peel_8.func_0805F000, 0x08060745)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x08060788);
            rt.r[1] = abi.read32(rt.r[13] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[4] = abi.read32(0x0806078C);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[4]);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            rt.r[1] = abi.read32(0x08060790);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0xB);
            rt.r[2] = rt.r[13] +% 0x4;
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_08060980, 0x08060763)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13] +% 0x4;
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = rt.r[13] +% 0x4;
            if (!abi.call(decls.func_08060078, 0x08060771)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080607C0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            continue :blk 9;
        },
        8 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x39);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.r[2] = abi.read8(rt.r[0] +% 0x9);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            abi.setRegNz(&rt.r[2], 0x18);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
            abi.write8(rt.r[0] +% 0x9, @truncate(rt.r[1]));
            if (!abi.call(low_peel_13.func_080665B8, 0x080607B1)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08066248, 0x080607B9)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0806606C, 0x080607B5)) return;
            continue :blk 9;
        },
        11 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080607C4() callconv(.c) void {
    if (!abi.enter(0x080607C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x8;
            rt.r[0] = abi.read32(0x08060838);
            rt.r[5] = abi.read32(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_080649B0, 0x080607D1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0806083C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x08060840);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            if (!abi.call(low_peel_6.func_0801D148, 0x080607DD)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.r[4] = abi.read32(0x08060844);
            rt.r[0] = abi.read32(0x08060848);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[2] +% 0x2);
            rt.r[1] = abi.read8(rt.r[2] +% 0x3);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.write32(rt.r[13] +% 0x0, rt.r[3]);
            rt.r[4] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x78);
            if (!abi.call(tail_low.func_0807B45C, 0x080607F5)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08060858, 0x080607FB)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(low_peel_8.func_0805F000, 0x08060801)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[2] = abi.read32(0x0806084C);
            rt.r[1] = abi.read32(rt.r[13] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            rt.r[4] = abi.read32(0x08060850);
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[4]);
            continue :blk 9;
        },
        9 => {
            abi.fetches(8);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            rt.r[1] = abi.read32(0x08060854);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0xA);
            rt.r[2] = rt.r[13] +% 0x4;
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_08060980, 0x0806081F)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13] +% 0x4;
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08066248, 0x0806082B)) return;
            continue :blk 13;
        },
        13 => {
            abi.fetches(5);
            rt.r[0] = rt.r[13] +% 0x4;
            if (!abi.call(decls.func_08060078, 0x08060831)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080607EA() callconv(.c) void {
    if (!abi.enter(0x080607EA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.write32(rt.r[13] +% 0x0, rt.r[3]);
            rt.r[4] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x78);
            if (!abi.call(tail_low.func_0807B45C, 0x080607F5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08060858, 0x080607FB)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(low_peel_8.func_0805F000, 0x08060801)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[2] = abi.read32(0x0806084C);
            rt.r[1] = abi.read32(rt.r[13] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            rt.r[4] = abi.read32(0x08060850);
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[4]);
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            rt.r[1] = abi.read32(0x08060854);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0xA);
            rt.r[2] = rt.r[13] +% 0x4;
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_08060980, 0x0806081F)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13] +% 0x4;
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08066248, 0x0806082B)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            rt.r[0] = rt.r[13] +% 0x4;
            if (!abi.call(decls.func_08060078, 0x08060831)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08060A34() callconv(.c) void {
    if (!abi.enter(0x08060A34)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.r[5] = abi.read32(0x08060A74);
            rt.r[1] = abi.read16(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[3], 0x2);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            abi.setRegNz(&rt.r[3], 0x1);
            rt.cpuSub(&rt.r[3], 0, rt.r[3], true);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read32(0x08060A74);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08060A78);
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            continue :blk 7;
        },
        4 => {
            abi.fetches(7);
            abi.write16(rt.r[4] +% 0x2, @truncate(rt.r[2]));
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[4] +% 0x1);
            abi.write16(rt.r[6] +% 0x2, @truncate(rt.r[0]));
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            rt.r[5] = abi.read16(rt.r[2] +% 0x2);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.r[1] = abi.read16(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[7], 0x2);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[7]));
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[3], 16));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        8 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read32(0x08060A74);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08060ED8() callconv(.c) void {
    if (!abi.enter(0x08060ED8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0xC;
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.r[1] = abi.read32(0x08060F00);
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[2], 0xA);
            if (!abi.call(low_peel_5.func_0807A8A0, 0x08060EEB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.r[0] +%= rt.r[13];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            continue :blk 2;
        },
        4 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806198C() callconv(.c) void {
    if (!abi.enter(0x0806198C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x080619E4);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[4] = abi.read32(0x080619E8);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[4]);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read16(rt.r[5] +% 0x2);
            rt.r[6] = rt.r[13];
            rt.r[2] = rt.r[13];
            if (!abi.call(func_08063210, 0x080619AD)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read16(rt.r[5] +% 0x2);
            rt.r[2] = rt.r[13];
            if (!abi.call(func_08063210, 0x080619B9)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.r[1] = abi.read16(rt.r[5] +% 0x2);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[2] = rt.r[13];
            if (!abi.call(func_08063210, 0x080619C5)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.r[1] = abi.read16(rt.r[5] +% 0x2);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[2] = rt.r[13];
            if (!abi.call(func_08063210, 0x080619D1)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[6] +% 0x2);
            abi.write16(rt.r[5] +% 0x2, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_080619F8() callconv(.c) void {
    if (!abi.enter(0x080619F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = abi.read32(0x08061A4C);
            rt.r[0] = abi.read32(0x08061A50);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x28, true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x91, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.armAsr(rt.r[0], rt.r[3] & 0xFF));
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(14);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[6], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[7] = abi.read8(rt.r[2] +% 0x1);
            rt.cpuSub(&rt.r[0], rt.r[5], rt.r[7], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.cpuSub(null, rt.r[1], 0x4, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x68, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08061A64() callconv(.c) void {
    if (!abi.enter(0x08061A64)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x08061A8C);
            rt.r[1] = abi.read32(0x08061A90);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            rt.r[4] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[2], 0x4, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08061AAC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x7);
            rt.r[3] = abi.read8(rt.r[3] +% 0x9);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[3]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
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
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08061A94);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
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

pub fn func_08061DC0() callconv(.c) void {
    if (!abi.enter(0x08061DC0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.r[0] = abi.read32(0x08061E04);
            rt.r[8] = rt.r[0];
            rt.r[0] = rt.r[8];
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[0], rt.r[6], 0x1, true);
            if (!abi.call(low_peel_12.func_08061E14, 0x08061DDB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_08061E14, 0x08061DE5)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[1], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_08061E14, 0x08061DEF)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_12.func_08061E14, 0x08061DFB)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[5] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[8], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08062C10() callconv(.c) void {
    if (!abi.enter(0x08062C10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.r[12] = rt.r[3];
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08062C80);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[2] = abi.read16(rt.r[3] +% 0x2);
            rt.cpuSub(null, rt.r[5], rt.r[2], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], rt.r[5] << 1);
            rt.r[7] = abi.read32(0x08062C84);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[7], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x12, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(22);
            rt.r[2] = abi.read32(0x08062C88);
            rt.r[7] = abi.read32(0x08062C8C);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[7], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x1F);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[6] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4C, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.r[0] = rt.r[12];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[5]));
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08062C90() callconv(.c) void {
    if (!abi.enter(0x08062C90)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x08062CE8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[7] << 1);
            rt.r[3] = abi.read32(0x08062CEC);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
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
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[6], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(func_08062CFC, 0x08062CBD)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(func_08062CFC, 0x08062CC7)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[8] = rt.r[0];
            rt.cpuSub(&rt.r[1], rt.r[7], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(func_08062CFC, 0x08062CD1)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(func_08062CFC, 0x08062CDB)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.r[4] +%= rt.r[8];
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[5], true);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 1;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08062CFC() callconv(.c) void {
    if (!abi.enter(0x08062CFC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
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
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08062D54);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[4] = abi.read16(rt.r[3] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 8;
        },
        7 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[4] = abi.read32(0x08062D58);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x12, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        9 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x08062D5C);
            rt.r[0] = abi.read32(0x08062D60);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xBC, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[1] = rt.sext8(abi.read8(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 8;
        },
        else => unreachable,
    }
}

pub fn func_08062EF8() callconv(.c) void {
    if (!abi.enter(0x08062EF8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.r[1] = abi.read32(0x08062F34);
            rt.r[0] = abi.read32(0x08062F38);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read8(rt.r[0] +% 0xF);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.r[4] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(tail_low.func_0807B45C, 0x08062F1B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(low_peel_12.func_0805F314, 0x08062F1F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(low_peel_12.func_0805F484, 0x08062F25)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(4);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[6]));
            abi.write16(rt.r[5] +% 0x2, @truncate(rt.r[7]));
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08062F3C() callconv(.c) void {
    if (!abi.enter(0x08062F3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.r[1] = abi.read32(0x08062F7C);
            rt.r[0] = abi.read32(0x08062F80);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08062F84);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read8(rt.r[0] +% 0xF);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.r[4] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(tail_low.func_0807B45C, 0x08062F61)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(low_peel_12.func_0805F314, 0x08062F65)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(low_peel_12.func_0805F5BC, 0x08062F6B)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x5, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(4);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[6]));
            abi.write16(rt.r[5] +% 0x2, @truncate(rt.r[7]));
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08062FD8() callconv(.c) void {
    if (!abi.enter(0x08062FD8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.r[1] = abi.read32(0x08063018);
            rt.r[0] = abi.read32(0x0806301C);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08063020);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read8(rt.r[0] +% 0xF);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.r[4] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(tail_low.func_0807B45C, 0x08062FFD)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(low_peel_12.func_0805F484, 0x08063001)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(low_peel_12.func_0805F5BC, 0x08063007)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(4);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[6]));
            abi.write16(rt.r[5] +% 0x2, @truncate(rt.r[7]));
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08063188() callconv(.c) void {
    if (!abi.enter(0x08063188)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x080631E4);
            rt.r[3] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x40, true);
            rt.cpuSub(null, rt.r[3], rt.r[2], true);
            if ((rt.CPU_N == rt.CPU_V)) {
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
            abi.fetches(12);
            rt.r[0] = abi.read32(0x080631E8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[6] = abi.read32(0x080631EC);
            abi.setRegNz(&rt.r[5], 0x1);
            rt.cpuSub(&rt.r[5], 0, rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[3], rt.r[2], rt.r[3], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x14, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x7);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(13);
            rt.r[2] = abi.read8(rt.r[1] +% 0x3);
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x2);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(5);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x3);
            abi.write16(rt.r[4] +% 0x2, @truncate(rt.r[0]));
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08063210() callconv(.c) void {
    if (!abi.enter(0x08063210)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
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
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08063284);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[1] = abi.read16(rt.r[3] +% 0x2);
            rt.cpuSub(null, rt.r[5], rt.r[1], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], rt.r[5] << 1);
            rt.r[2] = abi.read32(0x08063288);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x12, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x0806328C);
            abi.setRegNz(&rt.r[0], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x08063290);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0x1F);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0xD, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0xB, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08063294);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[4]));
            abi.write16(rt.r[6] +% 0x2, @truncate(rt.r[5]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080632C4() callconv(.c) void {
    if (!abi.enter(0x080632C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x08063310);
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
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08063314);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
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
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08063318);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[2], rt.r[3], rt.r[2], true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        8 => {
            abi.fetches(7);
            rt.r[3] = abi.read8(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[3] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(null, rt.r[0], 0x5A, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        10 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_08065BFC() callconv(.c) void {
    if (!abi.enter(0x08065BFC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0xC;
            rt.r[0] = abi.read32(0x08065C60);
            rt.r[6] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = rt.r[13] +% 0x4;
            if (!abi.call(func_0805FDDC, 0x08065C0B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(15);
            rt.r[5] = abi.read32(0x08065C64);
            rt.r[0] = abi.read32(0x08065C68);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[2] +% 0x2);
            rt.r[1] = abi.read8(rt.r[2] +% 0x3);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.r[3] = rt.r[13] +% 0x4;
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            rt.r[4] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(tail_low.func_0807B45C, 0x08065C25)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_12.func_08060938, 0x08065C29)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_12.func_08060F14, 0x08065C2F)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x08065C6C);
            rt.r[0] = abi.read32(rt.r[13] +% 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[4] = abi.read32(0x08065C70);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[4]);
            abi.write32(rt.r[13] +% 0x8, rt.r[0]);
            rt.r[5] = rt.r[13] +% 0x8;
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(func_08060A34, 0x08065C45)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08060078, 0x08065C55)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(low_peel_13.func_08065A90, 0x08065C4F)) return;
            continue :blk 6;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08066248, 0x08065C59)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08066C28() callconv(.c) void {
    if (!abi.enter(0x08066C28)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            abi.pushLr();
            rt.r[2] = abi.read32(0x08066C70);
            rt.r[1] = abi.read32(0x08066C74);
            rt.r[3] = abi.read8(rt.r[1] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read32(0x08066C78);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x3);
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(map.func_08020D14, 0x08066C4B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x08066C7C);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1E, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08066C84);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08066C80);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080677B0() callconv(.c) void {
    if (!abi.enter(0x080677B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = abi.read32(0x080677E8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0xFE, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x2, true);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0xFE, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFE, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            continue :blk 5;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_080677EC() callconv(.c) void {
    if (!abi.enter(0x080677EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[6], 0x1);
            rt.r[0] = abi.read32(0x08067808);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x2, true);
            abi.setRegNz(&rt.r[7], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0806780C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x1B);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xFF);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_8.func_0805F0A4, 0x08067817)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(8);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x2, true);
            rt.cpuAdd(&rt.r[7], rt.r[7], 0xC, true);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x1, true);
            rt.cpuSub(null, rt.r[6], 0x18, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 5);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = abi.read32(0x0806784C);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(math.func_0807B488, 0x0806782B)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(math.func_0807B488, 0x08067839)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            rt.r[1] = abi.read16(rt.r[5] +% 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08067BD0() callconv(.c) void {
    if (!abi.enter(0x08067BD0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 24);
            if (!abi.call(math.func_08010A84, 0x08067BDD)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x64);
            if (!abi.call(math.func_0807B6AC, 0x08067BE3)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.r[0] = abi.read32(0x08067C04);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x14, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08067C08);
            rt.r[0] = abi.read8(rt.r[0] +% 0x6);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 10;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 10;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[5], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 11;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x6, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 7;
        },
        10 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        11 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            continue :blk 10;
        },
        else => unreachable,
    }
}

pub fn func_0806820C() callconv(.c) void {
    if (!abi.enter(0x0806820C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08068224);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x5, true);
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
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x08068228);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08068244 => continue :blk 3,
                0x0806824A => continue :blk 4,
                0x08068250 => continue :blk 5,
                0x08068256 => continue :blk 6,
                0x08068262 => continue :blk 8,
                0x0806825C => continue :blk 7,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(ui.func_08068368, 0x08068249)) return;
            continue :blk 9;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(low_peel_5.func_08068584, 0x0806824F)) return;
            continue :blk 10;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(tail_low.func_080642C8, 0x08068255)) return;
            continue :blk 11;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(low_peel_13.func_080667A4, 0x0806825B)) return;
            continue :blk 12;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(low_peel_13.func_08066EC8, 0x08068261)) return;
            continue :blk 13;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(low_peel_5.func_08068548, 0x08068267)) return;
            continue :blk 1;
        },
        9 => {
            abi.fetches(3);
            continue :blk 1;
        },
        10 => {
            abi.fetches(3);
            continue :blk 1;
        },
        11 => {
            abi.fetches(3);
            continue :blk 1;
        },
        12 => {
            abi.fetches(3);
            continue :blk 1;
        },
        13 => {
            abi.fetches(3);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080684C4() callconv(.c) void {
    if (!abi.enter(0x080684C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(38);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0x1);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0x2);
            abi.write8(rt.r[0] +% 0x2, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0x3);
            abi.write8(rt.r[0] +% 0x3, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0x4);
            abi.write8(rt.r[0] +% 0x4, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0x5);
            abi.write8(rt.r[0] +% 0x5, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0x6);
            abi.write8(rt.r[0] +% 0x6, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0x7);
            abi.write8(rt.r[0] +% 0x7, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0x8);
            abi.write8(rt.r[0] +% 0x8, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0x9);
            abi.write8(rt.r[0] +% 0x9, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0xA);
            abi.write8(rt.r[0] +% 0xA, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0xB);
            abi.write8(rt.r[0] +% 0xB, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0xC);
            abi.write8(rt.r[0] +% 0xC, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0xD);
            abi.write8(rt.r[0] +% 0xD, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0xE);
            abi.write8(rt.r[0] +% 0xE, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0xF);
            abi.write8(rt.r[0] +% 0xF, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x10, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x10, true);
            abi.setRegNz(&rt.r[3], 0x17);
            continue :blk 1;
        },
        1 => {
            abi.fetches(31);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            abi.write8(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x3);
            abi.write8(rt.r[2] +% 0x3, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x4);
            abi.write8(rt.r[2] +% 0x4, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x5);
            abi.write8(rt.r[2] +% 0x5, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x6);
            abi.write8(rt.r[2] +% 0x6, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x7);
            abi.write8(rt.r[2] +% 0x7, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x8);
            abi.write8(rt.r[2] +% 0x8, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x9);
            abi.write8(rt.r[2] +% 0x9, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0xA);
            abi.write8(rt.r[2] +% 0xA, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0xB);
            abi.write8(rt.r[2] +% 0xB, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xC, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
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

pub fn func_08068848() callconv(.c) void {
    if (!abi.enter(0x08068848)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read8(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[1] << 25);
            rt.r[1] = abi.read32(0x0806886C);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x3);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(12);
            rt.r[2] = abi.read32(0x080688C8);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0xD);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[4] +% 0x9);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x2);
            continue :blk 5;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = abi.read16(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(14);
            rt.r[1] = abi.read8(rt.r[4] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[1] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            abi.setRegNz(&rt.r[1], 0x64);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            abi.setRegNz(&rt.r[1], rt.r[3] << 3);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x12);
            if (!abi.call(math.func_0807B488, 0x080688A9)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[4] +% 0x9, @truncate(rt.r[0]));
            continue :blk 8;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[4] +% 0x9);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 5;
        },
        7 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_C) {
                continue :blk 8;
            }
            continue :blk 6;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08068A64() callconv(.c) void {
    if (!abi.enter(0x08068A64)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[0] = abi.read32(0x08068AB0);
            rt.r[5] = abi.read16(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x08068AB4);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.setRegNz(&rt.r[4], 0x1);
            rt.r[6] = abi.read32(0x08068AB8);
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08068AB0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[4]));
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(low_peel_4.func_08024CD0, 0x08068A89)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_4.func_08025194, 0x08068A95)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08068AB8);
            rt.r[0] = abi.read32(0x08068AB0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[5]));
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(battle.func_08068ABC, 0x08068A9D)) return;
            continue :blk 6;
        },
        10 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08068AE0() callconv(.c) void {
    if (!abi.enter(0x08068AE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = abi.read32(0x08068B14);
            rt.r[12] = rt.r[1];
            rt.r[5] = abi.read32(0x08068B18);
            abi.setRegNz(&rt.r[6], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[3], rt.r[0] << 5);
            continue :blk 2;
        },
        2 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            rt.r[7] = abi.read16(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[7] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 10);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] +%= rt.r[12];
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x1F, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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

pub fn func_08069134() callconv(.c) void {
    if (!abi.enter(0x08069134)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x2);
            rt.r[3] = abi.read8(rt.r[5] +% 0x2);
            rt.cpuSub(&rt.r[1], rt.r[0], rt.r[3], true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[4] = abi.read8(rt.r[2] +% 0x3);
            rt.r[3] = abi.read8(rt.r[5] +% 0x3);
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[3], true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[6], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read32(0x0806917C);
            rt.r[1] = abi.read8(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x11);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(low_peel_5.func_0805F22C, 0x0806916D)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(low_peel_5.func_0805F22C, 0x08069187)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_5.func_0805F22C, 0x08069175)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(9);
            rt.r[2] = abi.read8(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 3);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x11);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            continue :blk 10;
        },
        9 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 13;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 13;
        },
        13 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_080691A4() callconv(.c) void {
    if (!abi.enter(0x080691A4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[7] = abi.read32(0x080691F8);
            abi.setRegNz(&rt.r[0], 0x2C);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[12] = rt.r[0];
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[3], rt.r[0] << 4);
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x1, true);
            rt.r[0] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[1], 0x4);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.write32(rt.r[0] +% 0x14, rt.r[4]);
            stmRegs(0, &.{ 4 });
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            rt.r[0] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.write16(rt.r[0] +% 0x28, @truncate(rt.r[4]));
            abi.write16(rt.r[0] +% 0x2A, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuSub(null, rt.r[2], 0xB, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x9, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806A18C() callconv(.c) void {
    if (!abi.enter(0x0806A18C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[3] = abi.read32(0x0806A1C0);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x96);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            if (!abi.call(low_peel_5.func_0806A174, 0x0806A1B9)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.r[5] = abi.read32(0x0806A1C4);
            abi.setRegNz(&rt.r[4], 0x80);
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
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], rt.r[5], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0806A1C8() callconv(.c) void {
    if (!abi.enter(0x0806A1C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = abi.read32(0x0806A204);
            rt.r[12] = rt.r[0];
            rt.r[6] = abi.read32(0x0806A208);
            rt.r[7] = abi.read32(0x0806A20C);
            rt.r[4] = abi.read32(0x0806A210);
            rt.r[5] = abi.read32(0x0806A214);
            continue :blk 1;
        },
        1 => {
            abi.fetches(20);
            abi.setRegNz(&rt.r[2], rt.r[3] << 3);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x60, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            stmRegs(7, &.{ 0, 1 });
            rt.r[2] +%= rt.r[12];
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[1] = abi.read32(rt.r[2] +% 0x4);
            stmRegs(5, &.{ 0, 1 });
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806A218() callconv(.c) void {
    if (!abi.enter(0x0806A218)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x0806A240);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[3] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0806A25C);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x0806A259)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[3] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0806A244);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x0806A23D)) return;
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

pub fn func_0806A27C() callconv(.c) void {
    if (!abi.enter(0x0806A27C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xB, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(co.func_0806C9A0, 0x0806A28D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_2.func_0806A260, 0x0806A2AD)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(low_peel_2.func_0806A260, 0x0806A297)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(func_0806C9C0, 0x0806A2B9)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(func_0806CA64, 0x0806A2A5)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[1], rt.r[4] << 2);
            rt.r[0] = abi.read32(0x0806A2CC);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_5.func_0806CAF0, 0x0806A2C5)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            continue :blk 6;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806A324() callconv(.c) void {
    if (!abi.enter(0x0806A324)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = abi.read32(0x0806A34C);
            rt.r[5] = abi.read32(0x0806A350);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x20, true);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.r[0] = abi.read16(rt.r[4] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x60, true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xFF);
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806A3E8() callconv(.c) void {
    if (!abi.enter(0x0806A3E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0806A43C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.setRegNz(&rt.r[0], 0x66);
            if (!abi.call(sound.func_0803D880, 0x0806A3FF)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806A440);
            if (!abi.call(low_peel_6.func_0801329C, 0x0806A405)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[4] = abi.read32(0x0806A444);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_5.func_0806CB50, 0x0806A40D)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_5.func_0806CBAC, 0x0806A413)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806A448);
            if (!abi.call(low_peel_6.func_0801329C, 0x0806A419)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806A44C);
            if (!abi.call(low_peel_6.func_0801329C, 0x0806A41F)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806A450);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(low_peel_6.func_0801320C, 0x0806A427)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806A454);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(low_peel_6.func_0801320C, 0x0806A42F)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806A458);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806A437)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0806A668() callconv(.c) void {
    if (!abi.enter(0x0806A668)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.r[0] = abi.read32(0x0806A6A8);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(low_peel_6.func_0801320C, 0x0806A679)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(23);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x44, true);
            abi.setRegNz(&rt.r[0], 0x11);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.write32(rt.r[3] +% 0x28, rt.r[6]);
            rt.r[1] = abi.read32(0x0806A6AC);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[3] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuSub(null, rt.r[4], 0x1, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x8);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.write32(rt.r[3] +% 0x24, rt.r[0]);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806A8F4() callconv(.c) void {
    if (!abi.enter(0x0806A8F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.r[4] = abi.read32(0x0806A974);
            rt.r[0] = abi.read32(rt.r[4] +% 0x8);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(25);
            rt.r[1] = abi.read32(0x0806A978);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[1]);
            abi.setRegNz(&rt.r[3], rt.r[3] << 5);
            rt.r[0] = abi.read32(0x0806A97C);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[1]);
            abi.setRegNz(&rt.r[2], rt.r[2] << 5);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[1] = rt.r[13];
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0806A974);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            abi.write32(rt.r[0] +% 0x4, rt.r[2]);
            rt.r[1] = abi.read32(0x0806A980);
            abi.write32(rt.r[0] +% 0x8, rt.r[1]);
            rt.r[1] = abi.read32(rt.r[0] +% 0x8);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(rt.r[4] +% 0x8);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0806A974);
            rt.r[5] = abi.read32(0x0806A984);
            abi.setRegNz(&rt.r[4], 0xA);
            continue :blk 5;
        },
        5 => {
            abi.fetches(18);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xA0, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[3]);
            abi.write32(rt.r[1] +% 0x4, rt.r[2]);
            abi.write32(rt.r[1] +% 0x8, rt.r[5]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x8);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x80, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[3]);
            abi.write32(rt.r[1] +% 0x4, rt.r[2]);
            abi.write32(rt.r[1] +% 0x8, rt.r[5]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x8);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xE0, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806AE08() callconv(.c) void {
    if (!abi.enter(0x0806AE08)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[6] = abi.read32(0x0806AE4C);
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x0806AE50);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], rt.r[5] << 18);
            rt.r[0] = abi.read32(0x0806AE54);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[0], 0x94);
            rt.r[2] = abi.read32(0x0806AE58);
            if (!abi.call(hw.func_0801B888, 0x0806AE25)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[6], true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_2.func_0806A260, 0x0806AE33)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[4] = abi.read8(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(low_peel_2.func_0806A260, 0x0806AE69)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xB, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[0], 0x94);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.r[2] = abi.read32(0x0806AE5C);
            if (!abi.call(hw.func_0801B888, 0x0806AE4B)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0xB0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[0], 0x84);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.r[2] = abi.read32(0x0806AE8C);
            if (!abi.call(hw.func_0801B888, 0x0806AE7F)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            rt.cpuSub(null, rt.r[5], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806B048() callconv(.c) void {
    if (!abi.enter(0x0806B048)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(math.func_0807B564, 0x0806B067)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0xA);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            abi.write8(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(math.func_0807B488, 0x0806B071)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.write8(rt.r[7] +% 0x0, @truncate(rt.r[0]));
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(math.func_0807B564, 0x0806B079)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(7);
            abi.write8(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(math.func_0807B488, 0x0806B083)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(math.func_0807B564, 0x0806B08B)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            abi.write8(rt.r[7] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[6] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.write8(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            continue :blk 12;
        },
        12 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[7] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806B438() callconv(.c) void {
    if (!abi.enter(0x0806B438)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0806B46C);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[2] = abi.read32(0x0806B470);
            rt.r[1] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x60, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read32(0x0806B474);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[2] = abi.read16(rt.r[1] +% 0x4);
            rt.r[4] = abi.read16(rt.r[0] +% 0x4);
            rt.cpuSub(null, rt.r[2], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[2] = abi.read16(rt.r[1] +% 0x2);
            rt.r[4] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[2], rt.r[4], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 3;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806B840() callconv(.c) void {
    if (!abi.enter(0x0806B840)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x0806B868);
            abi.setRegNz(&rt.r[1], 0x4);
            if (!abi.call(low_peel_6.func_0801320C, 0x0806B84F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.write32(rt.r[5] +% 0x20, rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x44, true);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0806B890);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0806B86C);
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.write32(rt.r[5] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_2.func_0806A260, 0x0806B87B)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xB, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 12);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x40, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806B894() callconv(.c) void {
    if (!abi.enter(0x0806B894)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(rt.r[4] +% 0x20);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
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
            abi.fetches(15);
            rt.r[1] = abi.read32(0x0806B8D8);
            rt.r[0] = abi.read32(rt.r[4] +% 0x2C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[0] << 3);
            rt.r[0] = abi.read32(rt.r[2] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[4] +% 0x24, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[2] +% 0x28);
            abi.write32(rt.r[4] +% 0x28, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(hw.func_0806A638, 0x0806B8C1)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x20);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1C);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806B8DC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806B8D1)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0806BC1C() callconv(.c) void {
    if (!abi.enter(0x0806BC1C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[2] << 24);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 24);
            rt.r[0] = abi.read32(0x0806BC44);
            abi.setRegNz(&rt.r[1], 0x6);
            if (!abi.call(low_peel_6.func_0801320C, 0x0806BC2F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.write32(rt.r[3] +% 0x20, rt.r[5]);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x40, true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0806BC68);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0806BC48);
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            abi.write32(rt.r[3] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x49, true);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4A, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x4B, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(func_0806B048, 0x0806BC61)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806BD38() callconv(.c) void {
    if (!abi.enter(0x0806BD38)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x0806BD88);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[4] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[4], rt.r[4] << 11);
            rt.r[1] = abi.read32(rt.r[5] +% 0x2C);
            rt.cpuSub(&rt.r[1], rt.r[4], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x6);
            if (!abi.call(math.func_0807B488, 0x0806BD5D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(14);
            rt.cpuSub(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.write32(rt.r[5] +% 0x2C, rt.r[4]);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 8));
            abi.write32(rt.r[5] +% 0x28, rt.r[4]);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x44, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[5] +% 0x1C, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806BD8C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806BD7D)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0806BFF4() callconv(.c) void {
    if (!abi.enter(0x0806BFF4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x7A);
            if (!abi.call(sound.func_0803D880, 0x0806C019)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0806C028);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xC, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x10);
            if (!abi.call(battle.func_0806BE94, 0x0806C021)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            ldmRegs(1, &.{ 0 });
            abi.write32(rt.r[0] +% 0x8, rt.r[3]);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 1;
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

pub fn func_0806C080() callconv(.c) void {
    if (!abi.enter(0x0806C080)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(0x0806C0DC);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0806C0E4);
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
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0806C0E0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806C0E8);
            rt.r[1] = abi.read32(0x0806C0EC);
            if (!abi.call(low_peel_5.func_0806CEF8, 0x0806C0B5)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0806C0DC);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        6 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0806C0DC);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        7 => {
            abi.fetches(11);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            abi.setRegNz(&rt.r[0], 0x3C);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0806C0F0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806C0D5)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806C164() callconv(.c) void {
    if (!abi.enter(0x0806C164)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806C1A0);
            if (!abi.call(low_peel_5.func_0806CB80, 0x0806C171)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0806C1A4);
            if (!abi.call(low_peel_2.func_0806CBDC, 0x0806C177)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806C1A8);
            if (!abi.call(low_peel_5.func_0806CB80, 0x0806C183)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0806C1A4);
            if (!abi.call(low_peel_2.func_0806CBDC, 0x0806C189)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            abi.setRegNz(&rt.r[0], 0x18);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0806C1AC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806C199)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806C1B0() callconv(.c) void {
    if (!abi.enter(0x0806C1B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x5);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806C200);
            if (!abi.call(low_peel_6.func_0801329C, 0x0806C1CF)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806C204);
            if (!abi.call(low_peel_6.func_0801329C, 0x0806C1D5)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806C208);
            if (!abi.call(low_peel_6.func_0801329C, 0x0806C1DB)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806C20C);
            if (!abi.call(low_peel_6.func_0801329C, 0x0806C1E1)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806C210);
            if (!abi.call(low_peel_6.func_0801329C, 0x0806C1E7)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806C214);
            if (!abi.call(low_peel_6.func_0801329C, 0x0806C1ED)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806C218);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806C1FB)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806C2B0() callconv(.c) void {
    if (!abi.enter(0x0806C2B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x44, true);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x42, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x48, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write32(rt.r[3] +% 0x24, rt.r[0]);
            rt.r[0] = abi.read32(0x0806C2D8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806C2D5)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0806C2FC);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[4]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            continue :blk 6;
        },
        4 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x0806C320);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[4]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], 0x30);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x0806C324);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.write32(rt.r[3] +% 0x24, rt.r[0]);
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806C78C() callconv(.c) void {
    if (!abi.enter(0x0806C78C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[7] = abi.read32(0x0806C7EC);
            rt.r[6] = abi.read32(0x0806C7F0);
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[2], 0x1, true);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[3] = abi.read32(0x0806C7FC);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 3);
            abi.setRegNz(&rt.r[2], 0x3);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[5], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0806C800);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x0806C7DB)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(0x0806C7F4);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 1));
            rt.r[0] = abi.read32(0x0806C7F8);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 1));
            continue :blk 1;
        },
        3 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(0x0806C7F4);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(0x0806C7F8);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806C804() callconv(.c) void {
    if (!abi.enter(0x0806C804)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[7] = abi.read32(0x0806C864);
            rt.r[6] = abi.read32(0x0806C868);
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[2], 0x1, true);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[3] = abi.read32(0x0806C874);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 3);
            abi.setRegNz(&rt.r[2], 0x3);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0806C878);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x0806C853)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(0x0806C86C);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 1));
            rt.r[0] = abi.read32(0x0806C870);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 1));
            continue :blk 1;
        },
        3 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(0x0806C86C);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(0x0806C870);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806C87C() callconv(.c) void {
    if (!abi.enter(0x0806C87C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], 0x28);
            abi.setRegNz(&rt.r[1], 0x5F);
            if (!abi.call(func_0806C78C, 0x0806C887)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x28);
            abi.setRegNz(&rt.r[1], 0x97);
            if (!abi.call(func_0806C804, 0x0806C88F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0806C8C4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xC0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            rt.r[4] = abi.read32(0x0806C8C8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_5.func_0806CB50, 0x0806C8A5)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(12);
            rt.r[2] = abi.read32(0x0806C8CC);
            rt.r[0] = abi.read8(rt.r[2] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write8(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(low_peel_6.func_0801320C, 0x0806C8B9)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x64);
            if (!abi.call(sound.func_0803D880, 0x0806C8BF)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0806C9C0() callconv(.c) void {
    if (!abi.enter(0x0806C9C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x0806C9DC);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(co.func_0801BE10, 0x0806C9ED)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[4] << 5);
            rt.r[1] = abi.read32(0x0806C9E0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            if (!abi.call(low_peel_6.func_0800FED0, 0x0806C9D9)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[1], rt.r[4] << 5);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 9);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
            abi.setRegNz(&rt.r[2], 0xC0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 19);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            if (!abi.call(dma.func_0800FFA8, 0x0806CA03)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
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

pub fn func_0806CA64() callconv(.c) void {
    if (!abi.enter(0x0806CA64)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(22);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.r[5] = abi.read32(0x0806CAD8);
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[2]);
            rt.r[1] = rt.r[13];
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0806CADC);
            abi.write32(rt.r[2] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[5] << 5);
            rt.r[1] = abi.read32(0x0806CAE0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[2] +% 0x4, rt.r[0]);
            rt.r[0] = abi.read32(0x0806CAE4);
            abi.write32(rt.r[2] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[2] +% 0x8);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[3] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[4] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            if (!abi.call(co.func_0801BEBC, 0x0806CA99)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[4] = abi.read32(0x0806CAE8);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_3.func_0800FE24, 0x0806CAA1)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x9, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 9);
            rt.cpuAdd(&rt.r[5], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[6], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x5);
            continue :blk 5;
        },
        5 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x0806CAEC);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[5]);
            abi.setRegNz(&rt.r[0], 0xC0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 19);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0xC0);
            if (!abi.call(dma.func_0800FFA8, 0x0806CAC3)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[0], true);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0xC0, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0806CCAC() callconv(.c) void {
    if (!abi.enter(0x0806CCAC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(26);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(rt.r[13] +% 0x18);
            rt.r[1] = abi.read32(rt.r[13] +% 0x1C);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[12] = rt.r[0];
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[8] = rt.r[1];
            rt.r[6] = abi.read8(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 15);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[2], true);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 10);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x2, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[12], true);
            if (rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[1] << 6);
            rt.cpuAdd(&rt.r[4], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[3], rt.r[6], true);
            if (rt.CPU_C) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(12);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.r[0] +%= rt.r[8];
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x2, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[3], rt.r[6], true);
            if (!rt.CPU_C) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[1], rt.r[12], true);
            if (!rt.CPU_C) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0806D624() callconv(.c) void {
    if (!abi.enter(0x0806D624)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[7] = abi.read32(0x0806D684);
            rt.r[6] = abi.read32(0x0806D688);
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[2], 0x1, true);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[3] = abi.read32(0x0806D694);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 3);
            abi.setRegNz(&rt.r[2], 0x3);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[5], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0806D698);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x0806D673)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(0x0806D68C);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 1));
            rt.r[0] = abi.read32(0x0806D690);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 1));
            continue :blk 1;
        },
        3 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(0x0806D68C);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(0x0806D690);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806D69C() callconv(.c) void {
    if (!abi.enter(0x0806D69C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[7] = abi.read32(0x0806D6FC);
            rt.r[6] = abi.read32(0x0806D700);
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[2], 0x1, true);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[3] = abi.read32(0x0806D70C);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 3);
            abi.setRegNz(&rt.r[2], 0x3);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0806D710);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x0806D6EB)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(0x0806D704);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 1));
            rt.r[0] = abi.read32(0x0806D708);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 1));
            continue :blk 1;
        },
        3 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(0x0806D704);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(0x0806D708);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806D84C() callconv(.c) void {
    if (!abi.enter(0x0806D84C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(rt.r[4] +% 0x4C);
            if (!abi.call(tail_low.func_0807B450, 0x0806D857)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            rt.r[2] = abi.read32(0x0806D8A0);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xF8, true);
            abi.setRegNz(&rt.r[7], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[7]);
            rt.r[2] = abi.read32(0x0806D8A4);
            rt.r[3] = abi.read16(rt.r[4] +% 0x3E);
            if (!abi.call(hw.func_0801B888, 0x0806D877)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(16);
            rt.r[1] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            rt.r[2] = abi.read16(rt.r[4] +% 0x2A);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[7]);
            rt.r[2] = abi.read32(0x0806D8D0);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            if (!abi.call(hw.func_0801B888, 0x0806D8C9)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(16);
            rt.r[3] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            rt.r[2] = abi.read16(rt.r[4] +% 0x2A);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[7]);
            rt.r[2] = abi.read32(0x0806D8A8);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            if (!abi.call(hw.func_0801B888, 0x0806D89D)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(3);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_0806D8E8() callconv(.c) void {
    if (!abi.enter(0x0806D8E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x24);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.r[1] = abi.read16(rt.r[4] +% 0x3A);
            rt.r[2] = abi.read16(rt.r[4] +% 0x3C);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            abi.write16(rt.r[4] +% 0x3A, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_0806D84C, 0x0806D911)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0xC0, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0806D93C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_7.func_08031488, 0x0806D92D)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806D940);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806D935)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_0806D95C() callconv(.c) void {
    if (!abi.enter(0x0806D95C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x24);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x0806D9B4);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x38);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_0806D84C, 0x0806D989)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x26);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x26, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
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
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0806D9B8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_7.func_08031488, 0x0806D9A5)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806D9BC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806D9AD)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806DB38() callconv(.c) void {
    if (!abi.enter(0x0806DB38)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x48, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(11);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
            rt.r[2] = rt.r[13];
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.r[3] = rt.r[13];
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.r[1] = rt.r[13];
            if (!abi.call(func_0806B048, 0x0806DB7B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[1], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0806DB60);
            rt.r[3] = abi.read32(0x0806DB64);
            if (!abi.call(hw.func_0801B888, 0x0806DB5D)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
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
            abi.fetches(17);
            rt.r[0] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0806DBC8);
            rt.r[3] = rt.r[13];
            rt.r[3] = abi.read8(rt.r[3] +% 0x1);
            rt.r[5] = abi.read32(0x0806DBCC);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[5], true);
            if (!abi.call(hw.func_0801B888, 0x0806DBA1)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(17);
            rt.r[0] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0806DBC8);
            rt.r[3] = rt.r[13];
            rt.r[3] = abi.read8(rt.r[3] +% 0x2);
            rt.r[4] = abi.read32(0x0806DBCC);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[4], true);
            if (!abi.call(hw.func_0801B888, 0x0806DBBF)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806DBD0() callconv(.c) void {
    if (!abi.enter(0x0806DBD0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x48, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(15);
            rt.r[0] = abi.read32(0x0806DC68);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x15);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = rt.r[13];
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.r[3] = rt.r[13];
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.r[1] = rt.r[13];
            if (!abi.call(func_0806B048, 0x0806DC1B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[1], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0806DBF8);
            rt.r[3] = abi.read32(0x0806DBFC);
            if (!abi.call(hw.func_0801B888, 0x0806DBF5)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
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
            abi.fetches(17);
            rt.r[0] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0806DC6C);
            rt.r[3] = rt.r[13];
            rt.r[3] = abi.read8(rt.r[3] +% 0x1);
            rt.r[5] = abi.read32(0x0806DC70);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[5], true);
            if (!abi.call(hw.func_0801B888, 0x0806DC41)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(17);
            rt.r[0] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0806DC6C);
            rt.r[3] = rt.r[13];
            rt.r[3] = abi.read8(rt.r[3] +% 0x2);
            rt.r[4] = abi.read32(0x0806DC70);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[4], true);
            if (!abi.call(hw.func_0801B888, 0x0806DC5F)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806DDC4() callconv(.c) void {
    if (!abi.enter(0x0806DDC4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[4] = abi.read32(0x0806DE18);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(proc.func_08013B70, 0x0806DDD1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.r[12] = rt.r[4];
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[7] = abi.read32(0x0806DE1C);
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[4], 0x6);
            continue :blk 4;
        },
        4 => {
            abi.fetches(21);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x58, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x88, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[3], true);
            abi.write16(rt.r[2] +% 0x24, @truncate(rt.r[0]));
            abi.write16(rt.r[2] +% 0x3C, @truncate(rt.r[5]));
            abi.write16(rt.r[2] +% 0x3A, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x6, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = rt.r[12];
            if (!abi.call(low_peel_5.func_0806CB50, 0x0806DE13)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0806DE9C() callconv(.c) void {
    if (!abi.enter(0x0806DE9C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[5] = abi.read32(0x0806DEB4);
            rt.r[1] = abi.read16(rt.r[4] +% 0x24);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x0806DEDC);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0806DE4C, 0x0806DECD)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[4] +% 0x26);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x26, @truncate(rt.r[0]));
            continue :blk 4;
        },
        6 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_7.func_08031488, 0x0806DEEF)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806DEFC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806DEF7)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806DF64() callconv(.c) void {
    if (!abi.enter(0x0806DF64)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x3A);
            rt.r[2] = abi.read16(rt.r[4] +% 0x3C);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            abi.write16(rt.r[4] +% 0x3A, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0806DE4C, 0x0806DF7D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x2A);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0xA0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0806DFA4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_7.func_08031488, 0x0806DF95)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806DFA8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806DF9D)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0806DFDC() callconv(.c) void {
    if (!abi.enter(0x0806DFDC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[5] = abi.read32(0x0806DFF4);
            rt.r[1] = abi.read16(rt.r[4] +% 0x24);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x0806E020);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x38);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0806DE4C, 0x0806E011)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[4] +% 0x26);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x26, @truncate(rt.r[0]));
            continue :blk 4;
        },
        6 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_7.func_08031488, 0x0806E033)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806E040);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806E03B)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806E044() callconv(.c) void {
    if (!abi.enter(0x0806E044)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x0806E05C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x9, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[2] << 3);
            rt.r[1] = abi.read32(0x0806E090);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.r[4] = abi.read32(0x0806E060);
            continue :blk 3;
        },
        3 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[2], 0xFD);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x5, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(&rt.r[2], rt.r[2], 0xFF, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = abi.read32(0x0806E094);
            abi.setRegNz(&rt.r[3], rt.r[4] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            if (!abi.call(hw.func_0801B888, 0x0806E089)) return;
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

pub fn func_0806E180() callconv(.c) void {
    if (!abi.enter(0x0806E180)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x26);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x26, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0806E1CC);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0806E0E4, 0x0806E1A1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x26);
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
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0806E1D0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_7.func_08031488, 0x0806E1B9)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806E1D4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806E1C1)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x24);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0806E1D8() callconv(.c) void {
    if (!abi.enter(0x0806E1D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x26);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x26, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0806E228);
            abi.setRegNz(&rt.r[0], 0x26);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xB);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0806E0E4, 0x0806E1FD)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x26);
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
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0806E22C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_7.func_08031488, 0x0806E215)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806E230);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806E21D)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x40);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0806E24C() callconv(.c) void {
    if (!abi.enter(0x0806E24C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x24);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x0806E2A4);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x38);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0806E0E4, 0x0806E279)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x26);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x26, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
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
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0806E2A8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_7.func_08031488, 0x0806E295)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806E2AC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806E29D)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806E338() callconv(.c) void {
    if (!abi.enter(0x0806E338)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
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
            rt.cpuSub(null, rt.r[0], 0xA0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0806E0E4, 0x0806E371)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0806E378);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_7.func_08031488, 0x0806E363)) return;
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
            rt.r[0] = abi.read32(0x0806E37C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806E36B)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0806E39C() callconv(.c) void {
    if (!abi.enter(0x0806E39C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x24);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x0806E3F4);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x38);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0806E0E4, 0x0806E3C9)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x26);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x26, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
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
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0806E3F8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_7.func_08031488, 0x0806E3E5)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806E3FC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806E3ED)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806E41C() callconv(.c) void {
    if (!abi.enter(0x0806E41C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x24);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x0806E474);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x38);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0806E0E4, 0x0806E449)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x26);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x26, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
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
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0806E478);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_7.func_08031488, 0x0806E465)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806E47C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806E46D)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806E8D8() callconv(.c) void {
    if (!abi.enter(0x0806E8D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(26);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(rt.r[4] +% 0x34);
            rt.r[0] = abi.read32(rt.r[4] +% 0x38);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[4] +% 0x34, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[4] +% 0x24, rt.r[0]);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x0806E924);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read32(rt.r[4] +% 0x28);
            rt.cpuSub(&rt.r[2], rt.r[2], 0xFF, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = abi.read32(rt.r[4] +% 0x3C);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x0806E909)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x30, true);
            abi.setRegNz(&rt.r[1], 0x90);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
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
            rt.r[0] = abi.read32(0x0806E928);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806E91D)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0806F074() callconv(.c) void {
    if (!abi.enter(0x0806F074)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = abi.read32(0x0806F0C4);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
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
            rt.r[5] = abi.read32(0x0806F0C8);
            continue :blk 3;
        },
        3 => {
            abi.fetches(11);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x74, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            rt.r[1] = abi.read16(rt.r[5] +% 0x2);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x25, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x14, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[1] = abi.read32(0x0806F0C4);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0806EFC4, 0x0806F0B1)) return;
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_0806F8FC() callconv(.c) void {
    if (!abi.enter(0x0806F8FC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x14, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            continue :blk 5;
        },
        3 => {
            abi.fetches(11);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x74, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_2.func_0806F7D0, 0x0806F905)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[1] = abi.read16(rt.r[2] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x74, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 10;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x66);
            if (!abi.call(sound.func_0803D880, 0x0806F90B)) return;
            continue :blk 11;
        },
        9 => {
            abi.fetches(21);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x28);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[5], 0x2A);
            rt.r[2] = rt.sext16(abi.read16(rt.r[0] +% rt.r[5]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x11, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0806F794, 0x0806F8D7)) return;
            continue :blk 12;
        },
        10 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read16(rt.r[2] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            continue :blk 0;
        },
        11 => {
            abi.fetches(3);
            continue :blk 4;
        },
        12 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x71);
            if (!abi.call(sound.func_0803D880, 0x0806F8DD)) return;
            continue :blk 13;
        },
        13 => {
            abi.fetches(3);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806F924() callconv(.c) void {
    if (!abi.enter(0x0806F924)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = abi.read32(0x0806F968);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x8);
            rt.cpuSub(null, rt.r[2], rt.r[1], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[0], 0x24);
            abi.write16(rt.r[5] +% 0x26, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x35, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x74, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0806FA18() callconv(.c) void {
    if (!abi.enter(0x0806FA18)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x26);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x26, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x6, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0x26);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806FA74);
            if (!abi.call(low_peel_5.func_0806CB50, 0x0806FA31)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x67);
            if (!abi.call(sound.func_0803D880, 0x0806FA3D)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0806E748, 0x0806FA41)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806FA7C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0806FA5F)) return;
            continue :blk 9;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(low_peel_13.func_0806DCBC, 0x0806FA45)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0806FA78);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(low_peel_7.func_08031488, 0x0806FA6F)) return;
            continue :blk 7;
        },
        10 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0806FA78);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x34, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806FB00() callconv(.c) void {
    if (!abi.enter(0x0806FB00)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0806FB40);
            if (!abi.call(low_peel_5.func_0806CB50, 0x0806FB07)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x0806FB44);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0806FB48);
            rt.r[4] = abi.read32(0x0806FB4C);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_5.func_0806CEF8, 0x0806FB1B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806FB50);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_5.func_0806CEF8, 0x0806FB23)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806FB54);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_5.func_0806CEF8, 0x0806FB2B)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0806FB58);
            rt.r[4] = abi.read32(0x0806FB5C);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_5.func_0806CEF8, 0x0806FB35)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806FB60);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_5.func_0806CEF8, 0x0806FB3D)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806FD78() callconv(.c) void {
    if (!abi.enter(0x0806FD78)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 14 });
            rt.r[1] = abi.read32(0x0806FDDC);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x58, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x47, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[1], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x9, true);
            abi.setRegNz(&rt.r[2], 0x2A);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(&rt.r[1], rt.r[1], 0x10, true);
            if (!abi.call(func_0806D624, 0x0806FDAB)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x47, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x48, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4B, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[1], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x9, true);
            abi.setRegNz(&rt.r[2], 0x2A);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1F, true);
            if (!abi.call(func_0806D69C, 0x0806FDD7)) return;
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

pub fn func_0806FDE0() callconv(.c) void {
    if (!abi.enter(0x0806FDE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[2] = abi.read32(0x0806FE0C);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[4] = rt.sext8(abi.read8(rt.r[0] +% rt.r[4]));
            rt.r[1] = abi.read32(0x0806FE10);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            rt.r[5] = abi.read16(rt.r[3] +% 0x2);
            abi.setRegNz(&rt.r[0], 0x20);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            rt.r[3] = abi.read16(rt.r[3] +% 0x4);
            rt.cpuSub(null, rt.r[5], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 8;
        },
        5 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 3;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x6, true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x6);
            continue :blk 13;
        },
        9 => {
            abi.fetches(5);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(null, rt.r[2], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 14;
        },
        10 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 7;
        },
        11 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x2A, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x64);
            if (!abi.call(sound.func_0803D880, 0x0806FE4D)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        13 => {
            abi.fetches(3);
            continue :blk 3;
        },
        14 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 7;
        },
        else => unreachable,
    }
}

pub fn func_0806FDE6() callconv(.c) void {
    if (!abi.enter(0x0806FDE6)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[4] = rt.sext8(abi.read8(rt.r[0] +% rt.r[4]));
            rt.r[1] = abi.read32(0x0806FE10);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            rt.r[5] = abi.read16(rt.r[3] +% 0x2);
            abi.setRegNz(&rt.r[0], 0x20);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            rt.r[3] = abi.read16(rt.r[3] +% 0x4);
            rt.cpuSub(null, rt.r[5], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 7;
        },
        4 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 2;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x6, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x6);
            continue :blk 12;
        },
        8 => {
            abi.fetches(5);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(null, rt.r[2], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 13;
        },
        9 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 6;
        },
        10 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x2A, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x64);
            if (!abi.call(sound.func_0803D880, 0x0806FE4D)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        12 => {
            abi.fetches(3);
            continue :blk 2;
        },
        13 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_0806FE08() callconv(.c) void {
    if (!abi.enter(0x0806FE08)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x6, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(null, rt.r[2], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 8;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 3;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x2A, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x64);
            if (!abi.call(sound.func_0803D880, 0x0806FE4D)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0806FE12() callconv(.c) void {
    if (!abi.enter(0x0806FE12)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x6, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(5);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(null, rt.r[2], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 9;
        },
        6 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 4;
        },
        7 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x2A, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x64);
            if (!abi.call(sound.func_0803D880, 0x0806FE4D)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0806FF10() callconv(.c) void {
    if (!abi.enter(0x0806FF10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[5] = abi.read32(0x0806FF50);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x58, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x6, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(18);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x58, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08070094() callconv(.c) void {
    if (!abi.enter(0x08070094)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x080700E8);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            rt.cpuSub(null, rt.r[2], 0xF, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(31);
            rt.r[3] = abi.read32(0x080700EC);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xA, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 10);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xA, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xA4);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[1], 0xF);
            abi.setRegNz(&rt.r[0], rt.r[4] >> 1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read32(0x080700F0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.r[4] = abi.read32(0x080700F4);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[4], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x080700F8);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(hw.func_080112C0, 0x080700E1)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[2], rt.r[0], rt.r[2], true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4 });
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

pub fn func_080701B8() callconv(.c) void {
    if (!abi.enter(0x080701B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_08070094, 0x080701BF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080701E4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
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
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080701E8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x34, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_5.func_0806FD58, 0x080701E3)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0806FF54, 0x080701F1)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(low_peel_13.func_080700FC, 0x080701F5)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_080701F8() callconv(.c) void {
    if (!abi.enter(0x080701F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[13] -%= 0x8;
            rt.r[0] = abi.read32(0x0807020C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x71);
            if (!abi.call(sound.func_0803D880, 0x08070217)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x66);
            if (!abi.call(sound.func_0803D880, 0x0807020B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            if (!abi.call(func_0806DDC4, 0x0807021F)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(ui.func_0806E94C, 0x08070223)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(sprite_anim.func_080124D4, 0x08070227)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08070244);
            abi.setRegNz(&rt.r[1], 0x2);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x3);
            abi.setRegNz(&rt.r[2], 0x11);
            abi.setRegNz(&rt.r[3], 0x1A);
            if (!abi.call(hw.func_08010C70, 0x0807023D)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08070370() callconv(.c) void {
    if (!abi.enter(0x08070370)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            rt.r[4] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(math.func_0807B488, 0x08070385)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[1], 0x10, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080703A8);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x10);
            continue :blk 2;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080703AC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x080703A1)) return;
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

pub fn func_0807042C() callconv(.c) void {
    if (!abi.enter(0x0807042C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(29);
            pushRegs(&.{ 4, 14 });
            rt.r[1] = abi.read32(0x08070478);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x44, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.r[1] = abi.read32(0x0807047C);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08070480);
            abi.setRegNz(&rt.r[0], 0x30);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08070484);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08070488);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x30, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x34, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0807048C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0807046B)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08070490() callconv(.c) void {
    if (!abi.enter(0x08070490)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x44, true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[5] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xC);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(math.func_0807B488, 0x080704A7)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(21);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(rt.r[4] +% 0x20);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08070500);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read32(rt.r[2] +% 0x28);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(rt.r[4] +% 0x3C);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            if (!abi.call(hw.func_0801B888, 0x080704CD)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x20);
            rt.r[0] = abi.read32(rt.r[0] +% 0x24);
            rt.cpuSub(null, rt.r[0], 0xF0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070504);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x080704EB)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x20);
            rt.r[0] = abi.read32(rt.r[0] +% 0x24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070504);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x080704FB)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080705CC() callconv(.c) void {
    if (!abi.enter(0x080705CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x08070604);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[3], 0x28);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[3]));
            rt.r[2] = abi.read32(rt.r[4] +% 0x3C);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            if (!abi.call(hw.func_0801B888, 0x080705EF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[3]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
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
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 6;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070638);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08070623)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(3);
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070638);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08070631)) return;
            continue :blk 7;
        },
        else => unreachable,
    }
}

pub fn func_08070602() callconv(.c) void {
    if (!abi.enter(0x08070602)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[7], rt.r[7] << 7);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            continue :blk 3;
        },
        3 => {
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
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070638);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08070623)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070638);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08070631)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_0807070E() callconv(.c) void {
    if (!abi.enter(0x0807070E)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[4]));
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x28, true);
            rt.r[8] = rt.r[2];
            continue :blk 1;
        },
        1 => {
            abi.fetches(23);
            abi.write32(rt.r[7] +% 0x24, rt.r[5]);
            rt.r[2] = rt.r[8];
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[4]));
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.r[2] = abi.read32(0x080707A4);
            rt.r[3] = abi.read16(rt.r[7] +% 0x1C);
            abi.setRegNz(&rt.r[1], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[7] +% 0x28, rt.r[0]);
            abi.setRegNz(&rt.r[1], 0x4E);
            if (!abi.call(math.func_0807B564, 0x08070747)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(18);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x4E, true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[5], 16));
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.r[6] = abi.read32(0x080707A8);
            rt.r[2] = abi.read16(rt.r[7] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x08070767)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x4E, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.r[7] = abi.read16(rt.r[7] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[7] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x0807077F)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.r[3] = rt.r[8];
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080707AC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08070795)) return;
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08070804() callconv(.c) void {
    if (!abi.enter(0x08070804)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x24, rt.r[0]);
            continue :blk 4;
        },
        4 => {
            abi.fetches(34);
            rt.r[1] = abi.read32(0x08070858);
            rt.r[3] = abi.read16(rt.r[5] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.write32(rt.r[2] +% 0x38, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x70);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            rt.r[1] = abi.read32(0x0807085C);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x2C, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x46, true);
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[1] = rt.r[8];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08070860);
            abi.write32(rt.r[2] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070854);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(low_peel_6.func_0801320C, 0x080707FB)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            continue :blk 8;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[2] +% 0x1C, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[5] +% 0x1C);
            continue :blk 0;
        },
        8 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08070806() callconv(.c) void {
    if (!abi.enter(0x08070806)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x24, rt.r[0]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(34);
            rt.r[1] = abi.read32(0x08070858);
            rt.r[3] = abi.read16(rt.r[5] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.write32(rt.r[2] +% 0x38, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x70);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            rt.r[1] = abi.read32(0x0807085C);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x2C, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x46, true);
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[1] = rt.r[8];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08070860);
            abi.write32(rt.r[2] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070854);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(low_peel_6.func_0801320C, 0x080707FB)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[2] +% 0x1C, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[5] +% 0x1C);
            continue :blk 8;
        },
        7 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            continue :blk 0;
        },
        else => unreachable,
    }
}

pub fn func_08070808() callconv(.c) void {
    if (!abi.enter(0x08070808)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x24, rt.r[0]);
            continue :blk 2;
        },
        2 => {
            abi.fetches(34);
            rt.r[1] = abi.read32(0x08070858);
            rt.r[3] = abi.read16(rt.r[5] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.write32(rt.r[2] +% 0x38, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x70);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            rt.r[1] = abi.read32(0x0807085C);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x2C, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x46, true);
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[1] = rt.r[8];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08070860);
            abi.write32(rt.r[2] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070854);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(low_peel_6.func_0801320C, 0x080707FB)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[2] +% 0x1C, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[5] +% 0x1C);
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            continue :blk 0;
        },
        else => unreachable,
    }
}

pub fn func_0807080A() callconv(.c) void {
    if (!abi.enter(0x0807080A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x24, rt.r[0]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(34);
            rt.r[1] = abi.read32(0x08070858);
            rt.r[3] = abi.read16(rt.r[5] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.write32(rt.r[2] +% 0x38, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x70);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            rt.r[1] = abi.read32(0x0807085C);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x2C, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x46, true);
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[1] = rt.r[8];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08070860);
            abi.write32(rt.r[2] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070854);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(low_peel_6.func_0801320C, 0x080707FB)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[2] +% 0x1C, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[5] +% 0x1C);
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 0;
        },
        else => unreachable,
    }
}

pub fn func_0807080E() callconv(.c) void {
    if (!abi.enter(0x0807080E)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(34);
            rt.r[1] = abi.read32(0x08070858);
            rt.r[3] = abi.read16(rt.r[5] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.write32(rt.r[2] +% 0x38, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x70);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            rt.r[1] = abi.read32(0x0807085C);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x2C, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x46, true);
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[1] = rt.r[8];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08070860);
            abi.write32(rt.r[2] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070854);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(low_peel_6.func_0801320C, 0x080707FB)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[2] +% 0x1C, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[5] +% 0x1C);
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x24, rt.r[0]);
            continue :blk 0;
        },
        else => unreachable,
    }
}

pub fn func_08070900() callconv(.c) void {
    if (!abi.enter(0x08070900)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08070954);
            rt.r[3] = abi.read16(rt.r[5] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(29);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.write32(rt.r[2] +% 0x38, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x70);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            rt.r[1] = abi.read32(0x08070958);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x2C, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x46, true);
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[1] = rt.r[8];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0807095C);
            abi.write32(rt.r[2] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070950);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(low_peel_6.func_0801320C, 0x080708ED)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[2] +% 0x1C, @truncate(rt.r[0]));
            rt.r[3] = abi.read16(rt.r[5] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.write32(rt.r[2] +% 0x24, rt.r[0]);
            continue :blk 0;
        },
        else => unreachable,
    }
}

pub fn func_08070906() callconv(.c) void {
    if (!abi.enter(0x08070906)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(29);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.write32(rt.r[2] +% 0x38, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x70);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            rt.r[1] = abi.read32(0x08070958);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x2C, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x46, true);
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[1] = rt.r[8];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0807095C);
            abi.write32(rt.r[2] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070950);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(low_peel_6.func_0801320C, 0x080708ED)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[2] +% 0x1C, @truncate(rt.r[0]));
            rt.r[3] = abi.read16(rt.r[5] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.write32(rt.r[2] +% 0x24, rt.r[0]);
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08070954);
            rt.r[3] = abi.read16(rt.r[5] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            continue :blk 0;
        },
        else => unreachable,
    }
}

pub fn func_08070908() callconv(.c) void {
    if (!abi.enter(0x08070908)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(29);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.write32(rt.r[2] +% 0x38, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x70);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            rt.r[1] = abi.read32(0x08070958);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x2C, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x46, true);
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[1] = rt.r[8];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0807095C);
            abi.write32(rt.r[2] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070950);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(low_peel_6.func_0801320C, 0x080708ED)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[2] +% 0x1C, @truncate(rt.r[0]));
            rt.r[3] = abi.read16(rt.r[5] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.write32(rt.r[2] +% 0x24, rt.r[0]);
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08070954);
            rt.r[3] = abi.read16(rt.r[5] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            continue :blk 0;
        },
        else => unreachable,
    }
}

pub fn func_0807090A() callconv(.c) void {
    if (!abi.enter(0x0807090A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(29);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.write32(rt.r[2] +% 0x38, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x70);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            rt.r[1] = abi.read32(0x08070958);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.write32(rt.r[2] +% 0x2C, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x46, true);
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[1] = rt.r[8];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0807095C);
            abi.write32(rt.r[2] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070950);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(low_peel_6.func_0801320C, 0x080708ED)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[2] +% 0x1C, @truncate(rt.r[0]));
            rt.r[3] = abi.read16(rt.r[5] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.write32(rt.r[2] +% 0x24, rt.r[0]);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08070954);
            rt.r[3] = abi.read16(rt.r[5] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 0;
        },
        else => unreachable,
    }
}

pub fn func_08070A0A() callconv(.c) void {
    if (!abi.enter(0x08070A0A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.r[6] = abi.read32(0x08070A64);
            rt.r[2] = abi.read16(rt.r[7] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x08070A1F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x4E, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.r[3] = abi.read16(rt.r[7] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x08070A37)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            rt.r[1] = rt.r[8];
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x5, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(8);
            rt.r[2] = rt.r[9];
            abi.write32(rt.r[7] +% 0x34, rt.r[2]);
            rt.r[0] = abi.read32(0x08070A68);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08070A53)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08070A6C() callconv(.c) void {
    if (!abi.enter(0x08070A6C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(rt.r[7] +% 0x28);
            abi.setRegNz(&rt.r[1], 0x4E);
            if (!abi.call(math.func_0807B564, 0x08070A79)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(28);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x4E, true);
            rt.r[0] = abi.read32(rt.r[7] +% 0x34);
            rt.r[2] = abi.read32(rt.r[7] +% 0x38);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write32(rt.r[7] +% 0x34, rt.r[0]);
            rt.r[4] = abi.read32(rt.r[7] +% 0x24);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.write32(rt.r[7] +% 0x24, rt.r[4]);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[0]);
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.r[6] = abi.read32(0x08070AE8);
            rt.r[2] = abi.read16(rt.r[7] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x08070AAD)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x4E, true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[5], 16));
            rt.r[1] = abi.read16(rt.r[7] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x08070AC5)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[7] +% 0x24);
            rt.cpuSub(null, rt.r[0], 0xF0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[7] +% 0x24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070AEC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08070AD3)) return;
            continue :blk 4;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070AEC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08070AE1)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08070B88() callconv(.c) void {
    if (!abi.enter(0x08070B88)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(0x08070BD8);
            rt.r[1] = abi.read32(rt.r[3] +% 0x34);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08070BDC);
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
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x42, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x18, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[2] = abi.read32(0x08070BE0);
            rt.r[1] = abi.read32(rt.r[3] +% 0x38);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070BE4);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(low_peel_6.func_0801320C, 0x08070BBF)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070BE8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08070BD3)) return;
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

pub fn func_08070F0C() callconv(.c) void {
    if (!abi.enter(0x08070F0C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(32);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x14;
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(rt.r[4] +% 0x30);
            rt.r[0] = abi.read32(rt.r[4] +% 0x34);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[4] +% 0x30, rt.r[1]);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 7);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0xA0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 7);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            rt.r[2] = rt.r[13];
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[0], 0x78);
            abi.write16(rt.r[2] +% 0x8, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x50);
            abi.write16(rt.r[2] +% 0xA, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] >> 31);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 1));
            abi.write16(rt.r[2] +% 0xC, @truncate(rt.r[1]));
            rt.r[0] = rt.r[13];
            abi.write16(rt.r[0] +% 0xE, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x10, @truncate(rt.r[3]));
            rt.r[1] = abi.read32(0x08070F70);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(bios.func_080796BC, 0x08070F49)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[13] +%= 0x14;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08070F74);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(low_peel_6.func_0801320C, 0x08070F61)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x10);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.write32(rt.r[4] +% 0x34, rt.r[0]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08071108() callconv(.c) void {
    if (!abi.enter(0x08071108)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            if (!abi.call(hw.func_0801B888, 0x0807110D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[2], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x44, true);
            rt.r[3] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0807114C);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[1] = abi.read32(0x08071150);
            abi.setRegNz(&rt.r[0], 0x10);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[7] +% 0x2C);
            rt.cpuSub(&rt.r[0], rt.r[0], 0xE, true);
            abi.write32(rt.r[7] +% 0x2C, rt.r[0]);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08071154);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08071141)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080712F0() callconv(.c) void {
    if (!abi.enter(0x080712F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(31);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            rt.r[1] = abi.read32(rt.r[4] +% 0x30);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[4] +% 0x24, rt.r[0]);
            rt.r[1] = abi.read32(rt.r[4] +% 0x28);
            rt.r[2] = abi.read32(rt.r[4] +% 0x34);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.write32(rt.r[4] +% 0x28, rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 8));
            abi.setRegNz(&rt.r[2], 0x9E);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[3] = abi.read32(0x08071348);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.setRegNz(&rt.r[2], 0xA8);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = abi.read32(rt.r[4] +% 0x3C);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            if (!abi.call(hw.func_0801B888, 0x0807132B)) return;
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
            rt.r[0] = abi.read32(0x0807134C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08071341)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0807145C() callconv(.c) void {
    if (!abi.enter(0x0807145C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x44, true);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[4]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(23);
            rt.r[0] = abi.read32(rt.r[3] +% 0x30);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x080714B8);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read32(rt.r[3] +% 0x28);
            rt.r[2] = abi.read32(0x080714BC);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[4], 0x80);
            abi.setRegNz(&rt.r[4], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = abi.read32(0x080714C0);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            if (!abi.call(hw.func_0801B888, 0x080714B1)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(14);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[3] +% 0x34);
            rt.r[0] = abi.read32(rt.r[3] +% 0x38);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[3] +% 0x34, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[3] +% 0x30);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[3] +% 0x30, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[3] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[3] +% 0x28, rt.r[0]);
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

pub fn func_0807198C() callconv(.c) void {
    if (!abi.enter(0x0807198C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[5] +% 0x1C);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(18);
            rt.r[0] = abi.read32(0x08071A10);
            rt.r[4] = abi.read32(rt.r[5] +% 0x24);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.r[2] = abi.read32(0x08071A14);
            rt.r[1] = abi.read32(rt.r[5] +% 0x28);
            rt.r[3] = abi.read32(rt.r[5] +% 0x2C);
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[3], true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x08071A18);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08071A1C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(17);
            rt.r[1] = abi.read32(0x080719B4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[3] = abi.read32(0x080719B8);
            rt.r[1] = abi.read32(rt.r[5] +% 0x28);
            rt.r[2] = abi.read32(rt.r[5] +% 0x2C);
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[2], true);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080719BC);
            rt.r[3] = abi.read32(rt.r[5] +% 0x24);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(0x080719C0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(15);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x2, true);
            abi.write32(rt.r[5] +% 0x2C, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[5] +% 0x34);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            abi.write32(rt.r[5] +% 0x24, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x44, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x10);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08071A20);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08071A0B)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08071E14() callconv(.c) void {
    if (!abi.enter(0x08071E14)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08071E64);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 18);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.r[1] = abi.read32(0x08071E68);
            abi.write32(rt.r[0] +% 0x4, rt.r[1]);
            rt.r[4] = abi.read32(0x08071E6C);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.setRegNz(&rt.r[3], 0x9F);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_5.func_0806CDD0, 0x08071E3F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(20);
            rt.r[0] = abi.read32(0x08071E70);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08071E74);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x08071E78);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08071E7C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x44, true);
            abi.setRegNz(&rt.r[0], 0x1B);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080720A8() callconv(.c) void {
    if (!abi.enter(0x080720A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08072124);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x44, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[6] +% rt.r[2]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[7] = rt.sext16(abi.read16(rt.r[1] +% rt.r[0]));
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            abi.setRegNz(&rt.r[3], 0xA0);
            abi.setRegNz(&rt.r[3], rt.r[3] << 7);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[2], 0x34);
            rt.r[1] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
            rt.r[4] = abi.read32(0x08072128);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(hw.func_0801B888, 0x080720DD)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 6);
            continue :blk 1;
        },
        3 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(rt.r[5] +% 0x34);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[7], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 5);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(hw.func_0801B888, 0x080720F1)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(rt.r[5] +% 0x34);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[7], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[3], 0xC0);
            abi.setRegNz(&rt.r[3], rt.r[3] << 6);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(hw.func_0801B888, 0x08072105)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[6] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0807212C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08072119)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            continue :blk 7;
        },
        else => unreachable,
    }
}

pub fn func_080723E8() callconv(.c) void {
    if (!abi.enter(0x080723E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08072408);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x13, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08072418);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(low_peel_6.func_0801320C, 0x08072415)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2E, true);
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
            rt.r[0] = abi.read32(0x0807244C);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(low_peel_6.func_0801320C, 0x08072425)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x44, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08072450);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08072445)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080727A0() callconv(.c) void {
    if (!abi.enter(0x080727A0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[3] = abi.read32(0x08072800);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[2] = abi.read32(0x08072804);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x10);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x4, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(13);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0xE);
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08072808);
            if (!abi.call(low_peel_6.func_0801329C, 0x080727EB)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0807280C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x080727F9)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_08072810() callconv(.c) void {
    if (!abi.enter(0x08072810)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(rt.r[3] +% 0x38);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            rt.r[1] = abi.read32(rt.r[3] +% 0x2C);
            rt.cpuSub(null, rt.r[1], 0x59, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.r[4] = abi.read32(0x08072864);
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            rt.cpuAdd(&rt.r[4], rt.r[2], rt.r[0], true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x5A, true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(19);
            rt.r[0] = abi.read32(rt.r[3] +% 0x24);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x08072868);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read32(rt.r[3] +% 0x28);
            rt.cpuSub(&rt.r[2], rt.r[2], 0xFF, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = abi.read32(0x0807286C);
            abi.setRegNz(&rt.r[3], rt.r[4] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            if (!abi.call(hw.func_0801B888, 0x08072863)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(19);
            rt.r[0] = abi.read32(rt.r[3] +% 0x24);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x08072898);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read32(rt.r[3] +% 0x28);
            rt.cpuSub(&rt.r[2], rt.r[2], 0xFF, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = abi.read32(rt.r[3] +% 0x3C);
            abi.setRegNz(&rt.r[3], rt.r[4] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            if (!abi.call(hw.func_0801B888, 0x08072893)) return;
            continue :blk 1;
        },
        11 => {
            abi.fetches(3);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0807289C() callconv(.c) void {
    if (!abi.enter(0x0807289C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0xE);
            abi.setRegNz(&rt.r[6], 0x8C);
            abi.setRegNz(&rt.r[6], rt.r[6] << 2);
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080728EC);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(low_peel_6.func_0801320C, 0x080728B1)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(29);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[4] << 4);
            abi.write32(rt.r[2] +% 0x24, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            abi.write32(rt.r[2] +% 0x2C, rt.r[0]);
            rt.r[0] = abi.read32(0x080728F0);
            abi.setRegNz(&rt.r[1], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[2] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x4, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x14, true);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.cpuSub(&rt.r[6], rt.r[6], 0x28, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
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

pub fn func_08072A74() callconv(.c) void {
    if (!abi.enter(0x08072A74)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08072AC4);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(low_peel_6.func_0801320C, 0x08072A87)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(29);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[4] << 4);
            abi.write32(rt.r[2] +% 0x24, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            abi.write32(rt.r[2] +% 0x2C, rt.r[0]);
            rt.r[0] = abi.read32(0x08072AC8);
            abi.setRegNz(&rt.r[1], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[2] +% 0x3C, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x4, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x14, true);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x28, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0xE, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
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

pub fn func_08072E3C() callconv(.c) void {
    if (!abi.enter(0x08072E3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x42, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0xA, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08072E84);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(low_peel_6.func_0801320C, 0x08072E59)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(campaign.func_08038C44, 0x08072E6F)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x10);
            abi.setRegNz(&rt.r[3], 0x2);
            if (!abi.call(ui.func_08072C6C, 0x08072E63)) return;
            continue :blk 1;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08072E88);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08072E7F)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08072F6C() callconv(.c) void {
    if (!abi.enter(0x08072F6C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x42, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x10, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(campaign.func_08038C44, 0x08072F85)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08072FE4);
            if (!abi.call(low_peel_6.func_0801329C, 0x08072FCD)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x08072FE0);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x3);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x2, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x4, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
            if (!abi.call(low_peel_3.func_08011910, 0x08072FA3)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08072FE8);
            if (!abi.call(low_peel_5.func_0806CB50, 0x08072FD3)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(low_peel_3.func_0801193C, 0x08072FA7)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08072FEC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08072FDB)) return;
            continue :blk 4;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(low_peel_3.func_08011968, 0x08072FAB)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(low_peel_5.func_08068164, 0x08072FAF)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            if (!abi.call(low_peel_1.func_08011804, 0x08072FB3)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            if (!abi.call(low_peel_1.func_08011814, 0x08072FB7)) return;
            continue :blk 13;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(low_peel_1.func_08011824, 0x08072FBB)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(4);
            if (!abi.call(low_peel_1.func_08011834, 0x08072FBF)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08073250() callconv(.c) void {
    if (!abi.enter(0x08073250)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(32);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[3] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[1] = abi.read32(0x080732A4);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x50);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x50, true);
            rt.r[0] = abi.read32(0x080732A8);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(0x080732AC);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x080732B0);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080732B4);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.cpuSub(null, rt.r[3], 0x7, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
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
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080732B8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0807329D)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0807363C() callconv(.c) void {
    if (!abi.enter(0x0807363C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(40);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x18;
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 7);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0xA0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 7);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            rt.r[1] = rt.r[13];
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[0], 0x78);
            abi.write16(rt.r[1] +% 0x8, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x50);
            abi.write16(rt.r[1] +% 0xA, @truncate(rt.r[0]));
            rt.r[2] = rt.r[13];
            rt.cpuAdd(&rt.r[5], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x44, true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[5] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x24);
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[2] +% 0xC, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[5] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[0]));
            rt.r[0] = rt.r[13];
            abi.write16(rt.r[0] +% 0x10, @truncate(rt.r[3]));
            rt.r[1] = abi.read32(0x080736C4);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(bios.func_080796BC, 0x08073689)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x42, true);
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
            abi.fetches(6);
            rt.r[13] +%= 0x18;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(17);
            rt.r[2] = rt.r[13] +% 0x14;
            rt.r[1] = abi.read32(0x080736C8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080736CC);
            abi.write32(rt.r[1] +% 0x0, rt.r[2]);
            rt.r[0] = abi.read32(0x080736D0);
            abi.write32(rt.r[1] +% 0x4, rt.r[0]);
            rt.r[0] = abi.read32(0x080736D4);
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x8);
            rt.r[0] = abi.read32(0x080736D8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x080736BB)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08073EC4() callconv(.c) void {
    if (!abi.enter(0x08073EC4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08073EFC);
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
            if (!abi.call(tail_low.func_080796A4, 0x08073ED9)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(hw.func_080112C0, 0x08073EDD)) return;
            continue :blk 4;
        },
        4 => {
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
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08073F00);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08073EF5)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08074362() callconv(.c) void {
    if (!abi.enter(0x08074362)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(low_peel_3.func_08010BCC, 0x0807436D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x08074400);
            rt.r[2] = abi.read32(0x08074414);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[2], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[4]);
            rt.r[0] = abi.read32(0x08074404);
            abi.write32(rt.r[1] +% 0x4, rt.r[0]);
            rt.r[0] = abi.read32(0x08074408);
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x8);
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0xE0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08074418);
            rt.r[4] = abi.read32(0x0807441C);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(low_peel_3.func_08010BCC, 0x08074397)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x80, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x08074400);
            rt.r[0] = abi.read32(0x08074420);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[4]);
            rt.r[0] = abi.read32(0x08074404);
            abi.write32(rt.r[1] +% 0x4, rt.r[0]);
            rt.r[0] = abi.read32(0x08074408);
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x8);
            continue :blk 4;
        },
        6 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08074424);
            rt.r[4] = abi.read32(0x08074428);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(low_peel_3.func_08010BCC, 0x080743BD)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[7] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x08074400);
            rt.r[2] = abi.read32(0x0807442C);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[2], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[4]);
            rt.r[0] = abi.read32(0x08074404);
            abi.write32(rt.r[1] +% 0x4, rt.r[0]);
            rt.r[0] = abi.read32(0x08074408);
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x8);
            continue :blk 7;
        },
        else => unreachable,
    }
}

pub fn func_080745F4() callconv(.c) void {
    if (!abi.enter(0x080745F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x14;
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[4], rt.r[2] >> 24);
            rt.r[1] = abi.read32(0x08074628);
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[2], 0x14);
            if (!abi.call(low_peel_5.func_0807A8A0, 0x0807460B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[13] +%= 0x14;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x0807462C);
            abi.setRegNz(&rt.r[0], rt.r[5] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.r[1] +%= rt.r[13];
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08074BC0() callconv(.c) void {
    if (!abi.enter(0x08074BC0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[5] = abi.read32(0x08074C28);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(proc.func_08013B70, 0x08074BCD)) return;
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
            abi.fetches(20);
            rt.r[2] = abi.read32(0x08074C2C);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x5);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x4, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x8, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(low_peel_13.func_0807452C, 0x08074C13)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1C);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1C, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            if (!abi.call(low_peel_13.func_080756BC, 0x08074BE7)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(low_peel_13.func_0807452C, 0x08074C1B)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x80);
            if (!abi.call(low_peel_6.func_0801320C, 0x08074BEF)) return;
            continue :blk 2;
        },
        6 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08074C30);
            abi.setRegNz(&rt.r[0], 0x88);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08074F44() callconv(.c) void {
    if (!abi.enter(0x08074F44)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x42, true);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x44, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_10.func_080116F4, 0x08074F69)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x08074F88);
            abi.setRegNz(&rt.r[0], 0x10);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08074F8C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08074F83)) return;
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

pub fn func_08075098() callconv(.c) void {
    if (!abi.enter(0x08075098)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(25);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[2] = abi.read32(0x080750DC);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x44, true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[5] +% rt.r[3]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[1] +% rt.r[3]));
            rt.r[1] = abi.read32(rt.r[0] +% 0x28);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.write32(rt.r[0] +% 0x2C, rt.r[1]);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[4] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x080750E0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.r[3] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(hw.func_0801B888, 0x080750C7)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[3]));
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
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08075194() callconv(.c) void {
    if (!abi.enter(0x08075194)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(state.func_0803A128, 0x0807519D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(17);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write32(rt.r[4] +% 0x24, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.write32(rt.r[4] +% 0x28, rt.r[0]);
            rt.r[0] = abi.read32(0x080751EC);
            abi.write32(rt.r[4] +% 0x3C, rt.r[0]);
            rt.r[0] = abi.read32(0x080751F0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x21, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x84);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x44, true);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[1], 0x8E);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(ui.func_0806CEBC, 0x080751D9)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x88);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x5, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x080751F4);
            abi.setRegNz(&rt.r[1], 0x90);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(dma.func_08011330, 0x080751E9)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0807520C);
            abi.setRegNz(&rt.r[1], 0x90);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(dma.func_08011330, 0x08075205)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08075304() callconv(.c) void {
    if (!abi.enter(0x08075304)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08075350);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xB);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0807535C);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 9);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(low_peel_13.func_0807452C, 0x0807534B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x44, true);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            if (!abi.call(low_peel_6.func_080114B0, 0x08075329)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08075354);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08075331)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08075358);
            abi.setRegNz(&rt.r[1], 0x10);
            if (!abi.call(sound.func_08078488, 0x08075339)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08075360() callconv(.c) void {
    if (!abi.enter(0x08075360)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x44, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[1], 0x7);
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
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(low_peel_10.func_080116F4, 0x08075379)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x2);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080753B8);
            if (!abi.call(low_peel_6.func_0801329C, 0x08075389)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080753BC);
            if (!abi.call(low_peel_6.func_0801329C, 0x08075395)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080753C0);
            if (!abi.call(low_peel_6.func_0801329C, 0x0807539B)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080753C4);
            if (!abi.call(low_peel_5.func_0806CB50, 0x080753A1)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(sound.func_0803D72C, 0x080753A5)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x3);
            if (!abi.call(sound.func_0803D760, 0x080753AB)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080753C8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x080753B3)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08075898() callconv(.c) void {
    if (!abi.enter(0x08075898)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            if (!abi.call(math.func_0803D4F0, 0x080758A1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
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
            abi.fetches(10);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x42, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08075904);
            if (!abi.call(low_peel_5.func_0806CB80, 0x080758BF)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x1C, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08075908);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x080758CB)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0807590C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x9);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(sound.func_0803D968, 0x080758CF)) return;
            continue :blk 5;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x71);
            if (!abi.call(sound.func_0803D880, 0x080758EF)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(turn.func_080320E4, 0x080758F3)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08075910);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_2.func_0806CBDC, 0x080758FB)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            if (!abi.call(sound.func_0803D968, 0x080758FF)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0807592C() callconv(.c) void {
    if (!abi.enter(0x0807592C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08075964);
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
            if (!abi.call(tail_low.func_080796A4, 0x08075941)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(hw.func_080112C0, 0x08075945)) return;
            continue :blk 4;
        },
        4 => {
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
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(clusters_low_2.func_080130A0, 0x08075959)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(ui.func_08073CA8, 0x0807595D)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08075A3C() callconv(.c) void {
    if (!abi.enter(0x08075A3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x44, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xA, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08075A88);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(low_peel_6.func_0801320C, 0x08075A77)) return;
            continue :blk 7;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(hw.func_08075B14, 0x08075A83)) return;
            continue :blk 8;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(tail_low.func_080796A4, 0x08075A5B)) return;
            continue :blk 9;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08075A8C);
            abi.setRegNz(&rt.r[1], 0x2);
            if (!abi.call(low_peel_6.func_0801320C, 0x08075A7F)) return;
            continue :blk 4;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(hw.func_080112C0, 0x08075A5F)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_08075ACC() callconv(.c) void {
    if (!abi.enter(0x08075ACC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(ui.func_0803D4D0, 0x08075AD3)) return;
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
            abi.fetches(9);
            rt.r[2] = abi.read32(0x08075B08);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 2);
            abi.setRegNz(&rt.r[0], 0x37);
            abi.setRegNz(&rt.r[1], 0x2C);
            if (!abi.call(hw.func_0801B888, 0x08075AE7)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x08075B0C);
            abi.setRegNz(&rt.r[3], 0x90);
            abi.setRegNz(&rt.r[3], rt.r[3] << 5);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[1], 0x8);
            if (!abi.call(hw.func_0801B888, 0x08075AF5)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x08075B10);
            abi.setRegNz(&rt.r[3], 0xC8);
            abi.setRegNz(&rt.r[3], rt.r[3] << 6);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[1], 0x8);
            if (!abi.call(hw.func_0801B888, 0x08075B03)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08075C8C() callconv(.c) void {
    if (!abi.enter(0x08075C8C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(rt.r[4] +% 0x34);
            rt.r[0] = abi.read32(rt.r[4] +% 0x38);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[4] +% 0x34, rt.r[2]);
            rt.r[0] = abi.read32(rt.r[4] +% 0x30);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write32(rt.r[4] +% 0x30, rt.r[0]);
            rt.r[1] = abi.read32(0x08075CF8);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(21);
            rt.r[0] = abi.read32(rt.r[4] +% 0x30);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            rt.r[1] = abi.read32(rt.r[4] +% 0x28);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[3] = abi.read32(0x08075CFC);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = abi.read32(0x08075D00);
            abi.setRegNz(&rt.r[3], 0xC8);
            abi.setRegNz(&rt.r[3], rt.r[3] << 6);
            if (!abi.call(hw.func_0801B888, 0x08075CDB)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            abi.write32(rt.r[4] +% 0x30, rt.r[0]);
            rt.cpuSub(&rt.r[0], 0, rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0x6);
            if (!abi.call(math.func_0807B488, 0x08075CB3)) return;
            continue :blk 4;
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
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.write32(rt.r[4] +% 0x34, rt.r[0]);
            continue :blk 1;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08075D04);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08075CF3)) return;
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

pub fn func_08075D08() callconv(.c) void {
    if (!abi.enter(0x08075D08)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08075D54);
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
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x28);
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x28);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            continue :blk 4;
        },
        4 => {
            abi.fetches(21);
            rt.r[0] = abi.read32(rt.r[2] +% 0x30);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            rt.r[1] = abi.read32(rt.r[2] +% 0x28);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[3] = abi.read32(0x08075D58);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = abi.read32(0x08075D5C);
            abi.setRegNz(&rt.r[3], 0xC8);
            abi.setRegNz(&rt.r[3], rt.r[3] << 6);
            if (!abi.call(hw.func_0801B888, 0x08075D4F)) return;
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

pub fn func_08075E34() callconv(.c) void {
    if (!abi.enter(0x08075E34)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08075EA0);
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
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[5] +% 0x28);
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[5] +% 0x28);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[5] +% 0x28, rt.r[0]);
            continue :blk 1;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.write32(rt.r[5] +% 0x28, rt.r[0]);
            rt.r[0] = abi.read32(0x08075EA4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08075E5D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(20);
            rt.r[4] = abi.read32(rt.r[5] +% 0x30);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 8));
            rt.r[7] = abi.read32(rt.r[5] +% 0x28);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[1], true);
            rt.r[2] = abi.read32(0x08075EA8);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            rt.cpuSub(&rt.r[2], rt.r[2], 0xFF, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[2], true);
            abi.setRegNz(&rt.r[5], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[5]);
            rt.r[2] = abi.read32(0x08075EAC);
            abi.setRegNz(&rt.r[3], 0x90);
            abi.setRegNz(&rt.r[3], rt.r[3] << 5);
            if (!abi.call(hw.func_0801B888, 0x08075E81)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(15);
            rt.r[0] = abi.read32(0x08075EB0);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[6]);
            abi.setRegNz(&rt.r[2], 0x95);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[5]);
            rt.r[2] = abi.read32(0x08075EB4);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(hw.func_0801B888, 0x08075E9B)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08075F84() callconv(.c) void {
    if (!abi.enter(0x08075F84)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[7] = abi.read32(0x08075FE4);
            rt.r[6] = abi.read32(0x08075FE8);
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[2], 0x1, true);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[3] = abi.read32(0x08075FF4);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 3);
            abi.setRegNz(&rt.r[2], 0x3);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[5], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x08075FF8);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x08075FD3)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(0x08075FEC);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 1));
            rt.r[0] = abi.read32(0x08075FF0);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 1));
            continue :blk 1;
        },
        3 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(0x08075FEC);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(0x08075FF0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08075FFC() callconv(.c) void {
    if (!abi.enter(0x08075FFC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[7] = abi.read32(0x0807605C);
            rt.r[6] = abi.read32(0x08076060);
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[2], 0x1, true);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[3] = abi.read32(0x0807606C);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 3);
            abi.setRegNz(&rt.r[2], 0x3);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x08076070);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x0807604B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(0x08076064);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 1));
            rt.r[0] = abi.read32(0x08076068);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 1));
            continue :blk 1;
        },
        3 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(0x08076064);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(0x08076068);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08076138() callconv(.c) void {
    if (!abi.enter(0x08076138)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(rt.r[4] +% 0x4C);
            if (!abi.call(tail_low.func_0807B450, 0x08076143)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            rt.r[2] = abi.read32(0x0807618C);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x8, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x08076190);
            rt.r[3] = abi.read16(rt.r[4] +% 0x3E);
            if (!abi.call(hw.func_0801B888, 0x08076163)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(17);
            rt.r[1] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            rt.r[2] = abi.read16(rt.r[4] +% 0x2A);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = abi.read32(0x080761BC);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            if (!abi.call(hw.func_0801B888, 0x080761B7)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(17);
            rt.r[3] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            rt.r[2] = abi.read16(rt.r[4] +% 0x2A);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = abi.read32(0x08076194);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            if (!abi.call(hw.func_0801B888, 0x0807618B)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(3);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_080761D4() callconv(.c) void {
    if (!abi.enter(0x080761D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x24);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[4] +% 0x30);
            rt.r[1] = abi.read32(rt.r[4] +% 0x34);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[4] +% 0x30, rt.r[0]);
            rt.r[1] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x28, @truncate(rt.r[0]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_08076138, 0x080761FD)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0xF0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x08076220);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08076224);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08076219)) return;
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

pub fn func_08076240() callconv(.c) void {
    if (!abi.enter(0x08076240)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x24);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x08076294);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x28, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_08076138, 0x0807626D)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x26);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x26, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
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
            abi.fetches(12);
            rt.r[0] = abi.read32(0x08076298);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0807629C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x0807628D)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08076384() callconv(.c) void {
    if (!abi.enter(0x08076384)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[4] = abi.read32(0x080763D8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(proc.func_08013B70, 0x0807638F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.r[12] = rt.r[4];
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[7] = abi.read32(0x080763DC);
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[5], 0x6);
            abi.setRegNz(&rt.r[4], 0x5);
            continue :blk 4;
        },
        4 => {
            abi.fetches(21);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x58, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x88, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[0], rt.r[5], rt.r[3], true);
            abi.write16(rt.r[2] +% 0x24, @truncate(rt.r[0]));
            abi.write32(rt.r[2] +% 0x34, rt.r[4]);
            abi.write32(rt.r[2] +% 0x30, rt.r[6]);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x6, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = rt.r[12];
            if (!abi.call(low_peel_5.func_0806CB50, 0x080763D3)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_080765B8() callconv(.c) void {
    if (!abi.enter(0x080765B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x24);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[4] +% 0x30);
            rt.r[1] = abi.read32(rt.r[4] +% 0x34);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[4] +% 0x30, rt.r[0]);
            rt.r[1] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x28, @truncate(rt.r[0]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_080764E8, 0x080765E1)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x08076604);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08076608);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x080765FD)) return;
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

pub fn func_08076628() callconv(.c) void {
    if (!abi.enter(0x08076628)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x24);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x0807667C);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x28, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_080764E8, 0x08076655)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x26);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x26, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
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
            abi.fetches(12);
            rt.r[0] = abi.read32(0x08076680);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08076684);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08076675)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08076778() callconv(.c) void {
    if (!abi.enter(0x08076778)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[4] = abi.read32(0x080767D8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(proc.func_08013B70, 0x08076783)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuAdd(&rt.r[7], rt.r[4], 0x0, true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = abi.read32(0x080767DC);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[12] = rt.r[1];
            abi.setRegNz(&rt.r[5], 0x0);
            abi.setRegNz(&rt.r[4], 0x5);
            rt.cpuSub(&rt.r[4], 0, rt.r[4], true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            if (!abi.call(low_peel_5.func_0806CB50, 0x080767D3)) return;
            continue :blk 2;
        },
        6 => {
            abi.fetches(13);
            rt.r[0] = rt.r[12];
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x38, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[6], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[6]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1F, true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 5));
            abi.write16(rt.r[1] +% 0x24, @truncate(rt.r[0]));
            abi.write32(rt.r[1] +% 0x34, rt.r[4]);
            abi.write32(rt.r[1] +% 0x30, rt.r[5]);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x8);
            rt.cpuSub(null, rt.r[3], rt.r[2], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_080768C0() callconv(.c) void {
    if (!abi.enter(0x080768C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(26);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(rt.r[4] +% 0x34);
            rt.r[0] = abi.read32(rt.r[4] +% 0x38);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[4] +% 0x34, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[4] +% 0x24, rt.r[0]);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x0807690C);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read32(rt.r[4] +% 0x28);
            rt.cpuSub(&rt.r[2], rt.r[2], 0xFF, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = abi.read32(rt.r[4] +% 0x3C);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(hw.func_0801B888, 0x080768F1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x30, true);
            abi.setRegNz(&rt.r[1], 0x90);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
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
            rt.r[0] = abi.read32(0x08076910);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(low_peel_1.func_08013BD0, 0x08076905)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08076944() callconv(.c) void {
    if (!abi.enter(0x08076944)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[4] = abi.read32(0x080769A4);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read32(0x080769A8);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            if (!abi.call(decls.func_0803E608, 0x08076959)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(low_peel_13.func_080769AC, 0x0807695D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x080769A4);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x34, true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[3], 0xFF);
            abi.setRegNz(&rt.r[2], 0x7);
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x36, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[3]);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 3;
        },
        7 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08076D2C() callconv(.c) void {
    if (!abi.enter(0x08076D2C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[0] = abi.read32(0x08076D8C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x36, true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[4] = rt.sext8(abi.read8(rt.r[0] +% rt.r[4]));
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[2] = abi.read32(0x08076D90);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x10);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x64);
            if (!abi.call(sound.func_0803D880, 0x08076D51)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x64);
            if (!abi.call(sound.func_0803D880, 0x08076D71)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08076D8C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x36, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x7);
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x7);
            continue :blk 8;
        },
        7 => {
            abi.fetches(8);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 1;
        },
        8 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08077080() callconv(.c) void {
    if (!abi.enter(0x08077080)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 14 });
            rt.r[1] = abi.read32(0x080770E4);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x58, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x47, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[1], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x9, true);
            abi.setRegNz(&rt.r[2], 0x2A);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(&rt.r[1], rt.r[1], 0x10, true);
            if (!abi.call(func_08075F84, 0x080770B3)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x47, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x48, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4B, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[1], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x9, true);
            abi.setRegNz(&rt.r[2], 0x2A);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1F, true);
            if (!abi.call(func_08075FFC, 0x080770DF)) return;
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

pub fn func_080770E8() callconv(.c) void {
    if (!abi.enter(0x080770E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[2] = abi.read32(0x08077114);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[4] = rt.sext8(abi.read8(rt.r[0] +% rt.r[4]));
            rt.r[1] = abi.read32(0x08077118);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            rt.r[5] = abi.read16(rt.r[3] +% 0x2);
            abi.setRegNz(&rt.r[0], 0x20);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x6, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        4 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        5 => {
            abi.fetches(5);
            rt.r[3] = abi.read16(rt.r[3] +% 0x4);
            rt.cpuSub(null, rt.r[5], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 11;
        },
        6 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 1;
        },
        7 => {
            abi.fetches(5);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(null, rt.r[2], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 12;
        },
        8 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 4;
        },
        9 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x2A, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x64);
            if (!abi.call(sound.func_0803D880, 0x08077155)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        11 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x6);
            continue :blk 1;
        },
        12 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08077218() callconv(.c) void {
    if (!abi.enter(0x08077218)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[5] = abi.read32(0x08077258);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x58, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x6, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(18);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x58, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080775C2() callconv(.c) void {
    if (!abi.enter(0x080775C2)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[1] = rt.r[8];
            rt.r[2] = rt.r[9];
            rt.r[3] = rt.r[10];
            rt.r[4] = rt.r[11];
            pushRegs(&.{ 0, 1, 2, 3, 4 });
            rt.r[13] -%= 0x18;
            rt.r[1] = abi.read8(rt.r[0] +% 0xC);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.write32(rt.r[13] +% 0x14, rt.r[1]);
            rt.r[3] = abi.read32(rt.r[0] +% 0x20);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(0x08077628);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[2], 0xA0, true);
            if (rt.CPU_C) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[0] +% 0x24);
            if (!abi.call(tail_low.func_080779D2, 0x080775F1)) return;
            continue :blk 7;
        },
        4 => {
            abi.fetches(5);
            rt.r[3] = abi.read32(rt.r[0] +% 0x28);
            if (!abi.call(tail_low.func_080779D2, 0x080775F9)) return;
            continue :blk 8;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xE4, true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            continue :blk 1;
        },
        7 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(rt.r[13] +% 0x18);
            continue :blk 4;
        },
        8 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[13] +% 0x18);
            rt.r[3] = abi.read32(rt.r[0] +% 0x10);
            rt.r[8] = rt.r[3];
            rt.r[5] = abi.read32(0x0807762C);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[0], true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x4);
            rt.cpuSub(&rt.r[7], rt.r[4], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            rt.r[1] = abi.read8(rt.r[0] +% 0xB);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[7], true);
            rt.r[2] = rt.r[8];
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[1]);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[2], true);
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            abi.write32(rt.r[13] +% 0x8, rt.r[5]);
            rt.r[6] = abi.read32(0x08077630);
            rt.r[3] = abi.read32(0x08077624);
            decls.awre_cpu_bx(rt.r[3]); return;
        },
        else => unreachable,
    }
}

pub fn func_08077AD0() callconv(.c) void {
    if (!abi.enter(0x08077AD0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[2] = abi.read32(rt.r[1] +% 0x40);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[3] = abi.read8(rt.r[1] +% 0x3);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            abi.write8(rt.r[1] +% 0x3, @truncate(rt.r[3]));
            rt.r[12] = rt.r[3];
            if (!abi.call(low_peel_2.func_08077A74, 0x08077AED)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.write32(rt.r[1] +% 0x40, rt.r[2]);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[12], rt.r[3], true);
            if (rt.CPU_C) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(13);
            rt.r[2] = abi.read32(rt.r[1] +% 0x40);
            rt.r[0] = abi.read8(rt.r[2] +% 0x3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            rt.r[3] = abi.read8(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            rt.r[3] = abi.read8(rt.r[2] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            if (!abi.call(low_peel_2.func_08077A58, 0x08077A99)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            continue :blk 4;
        },
        6 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.write8(rt.r[1] +% 0x3, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x5, true);
            abi.write32(rt.r[1] +% 0x40, rt.r[2]);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write32(rt.r[1] +% 0x40, rt.r[0]);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08077C04() callconv(.c) void {
    if (!abi.enter(0x08077C04)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08077EA8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x08077EAC);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[3], rt.r[3], rt.r[2], true);
            rt.cpuSub(null, rt.r[3], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
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
            rt.r[1] = abi.read8(rt.r[0] +% 0x4);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x4, @truncate(rt.r[1]));
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.r[1] = abi.read8(rt.r[0] +% 0xB);
            abi.write8(rt.r[0] +% 0x4, @truncate(rt.r[1]));
            rt.r[2] = abi.read32(0x08077C48);
            rt.r[1] = abi.read32(rt.r[2] +% 0x8);
            abi.setRegNz(&rt.r[1], rt.r[1] << 7);
            if (!rt.CPU_C) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(0x08077C4C);
            abi.write32(rt.r[2] +% 0x8, rt.r[1]);
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[2] +% 0x14);
            abi.setRegNz(&rt.r[1], rt.r[1] << 7);
            if (!rt.CPU_C) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(0x08077C4C);
            abi.write32(rt.r[2] +% 0x14, rt.r[1]);
            continue :blk 7;
        },
        7 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[1], 0x4);
            abi.setRegNz(&rt.r[1], rt.r[1] << 8);
            abi.write16(rt.r[2] +% 0xA, @truncate(rt.r[1]));
            abi.write16(rt.r[2] +% 0x16, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], 0xB6);
            abi.setRegNz(&rt.r[1], rt.r[1] << 8);
            abi.write16(rt.r[2] +% 0xA, @truncate(rt.r[1]));
            abi.write16(rt.r[2] +% 0x16, @truncate(rt.r[1]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08078124() callconv(.c) void {
    if (!abi.enter(0x08078124)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5 });
            rt.r[2] = abi.read32(rt.r[1] +% 0x40);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[3], 0x80, true);
            if (rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            rt.r[3] = abi.read8(rt.r[1] +% 0x5);
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.write8(rt.r[1] +% 0x5, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.write32(rt.r[1] +% 0x40, rt.r[2]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[1] +% 0x20);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x83);
            abi.setRegNz(&rt.r[5], 0x40);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 4, 5 });
            rt.recompReturn(rt.r[14]); return;
        },
        6 => {
            abi.fetches(5);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            rt.updateNz(rt.r[2] & rt.r[4]);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.updateNz(rt.r[2] & rt.r[5]);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[1] +% 0x34);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        9 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x11);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x40);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[0]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_0807831C() callconv(.c) void {
    if (!abi.enter(0x0807831C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[2] = abi.read32(0x08078348);
            rt.r[1] = abi.read32(0x0807834C);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 13);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(rt.r[1] +% 0x4);
            rt.r[0] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            if (!abi.call(low_peel_13.func_080789E8, 0x08078345)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            if (!abi.call(low_peel_13.func_080789E8, 0x08078365)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
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

pub fn func_08078368() callconv(.c) void {
    if (!abi.enter(0x08078368)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[2] = abi.read32(0x08078394);
            rt.r[1] = abi.read32(0x08078398);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 13);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(rt.r[1] +% 0x4);
            rt.r[0] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            if (!abi.call(low_peel_13.func_080789E8, 0x08078391)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            if (!abi.call(low_peel_13.func_080789E8, 0x080783AD)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            continue :blk 8;
        },
        6 => {
            abi.fetches(3);
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(low_peel_2.func_0807821C, 0x080783B9)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08078498() callconv(.c) void {
    if (!abi.enter(0x08078498)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[5] = abi.read8(rt.r[0] +% 0x8);
            rt.r[4] = abi.read32(rt.r[0] +% 0x2C);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[7], 0x80);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[6], 0x40);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[5], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x50, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(sound.func_0807861C, 0x080784BF)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(12);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[7]));
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write8(rt.r[4] +% 0xF, @truncate(rt.r[0]));
            abi.write8(rt.r[4] +% 0x13, @truncate(rt.r[6]));
            abi.setRegNz(&rt.r[0], 0x16);
            abi.write8(rt.r[4] +% 0x19, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x24, true);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08078864() callconv(.c) void {
    if (!abi.enter(0x08078864)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[0] = abi.read32(0x080788B0);
            rt.r[6] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.r[0] = abi.read32(0x080788B4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
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
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.write32(rt.r[6] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[5], 0xC);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x50, true);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[5], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x40, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[4] = abi.read32(rt.r[6] +% 0x1C);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[5], 0x1);
            abi.setRegNz(&rt.r[7], 0x0);
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x080788B4);
            abi.write32(rt.r[6] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        7 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[5] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read32(rt.r[6] +% 0x2C);
            if (!abi.call(tail_low.func_0807B450, 0x0807889D)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(7);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[7]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x40, true);
            rt.cpuSub(null, rt.r[5], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_08078CB8() callconv(.c) void {
    if (!abi.enter(0x08078CB8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
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
            rt.r[1] = abi.read32(0x08078CE4);
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
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            continue :blk 10;
        },
        6 => {
            abi.fetches(3);
            continue :blk 11;
        },
        7 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08078CDC);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            continue :blk 10;
        },
        8 => {
            abi.fetches(3);
            continue :blk 11;
        },
        9 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08078CF0);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 12;
        },
        10 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x80);
            continue :blk 12;
        },
        11 => {
            abi.fetches(3);
            rt.r[1] = abi.read32(0x08078D04);
            continue :blk 5;
        },
        12 => {
            abi.fetches(4);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08078D08() callconv(.c) void {
    if (!abi.enter(0x08078D08)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[2], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[2] >> 24);
            rt.r[3] = abi.read8(rt.r[1] +% 0x3);
            abi.setRegNz(&rt.r[0], rt.r[3] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], rt.r[3], true);
            if (!rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_C) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[2] >> 25);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if (!rt.CPU_C) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write8(rt.r[1] +% 0x1B, @truncate(rt.r[0]));
            continue :blk 6;
        },
        4 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.write8(rt.r[1] +% 0x1B, @truncate(rt.r[0]));
            rt.r[2] = abi.read8(rt.r[1] +% 0x3);
            rt.r[3] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 4);
            continue :blk 7;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.write8(rt.r[1] +% 0x1B, @truncate(rt.r[0]));
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            rt.r[2] = abi.read8(rt.r[1] +% 0x3);
            rt.r[3] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 4);
            abi.write8(rt.r[1] +% 0xA, @truncate(rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            abi.write8(rt.r[1] +% 0xA, @truncate(rt.r[0]));
            continue :blk 9;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0xF);
            continue :blk 7;
        },
        9 => {
            abi.fetches(16);
            rt.r[2] = abi.read8(rt.r[1] +% 0x6);
            rt.r[3] = abi.read8(rt.r[1] +% 0xA);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            abi.write8(rt.r[1] +% 0x19, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x1C);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1B);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write8(rt.r[1] +% 0x1B, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080791DC() callconv(.c) void {
    if (!abi.enter(0x080791DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[7], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[6], rt.r[2] << 16);
            rt.r[3] = abi.read32(rt.r[4] +% 0x34);
            rt.r[0] = abi.read32(0x08079240);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.write32(rt.r[4] +% 0x34, rt.r[0]);
            rt.r[2] = abi.read8(rt.r[4] +% 0x8);
            rt.r[1] = abi.read32(rt.r[4] +% 0x2C);
            abi.setRegNz(&rt.r[5], 0x1);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[6], rt.r[6] >> 18);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.r[12] = rt.r[0];
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08079240);
            abi.write32(rt.r[4] +% 0x34, rt.r[0]);
            continue :blk 1;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            rt.r[0] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x50, true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 1);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        8 => {
            abi.fetches(6);
            abi.write8(rt.r[1] +% 0x13, @truncate(rt.r[6]));
            rt.r[0] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 7;
        },
        else => unreachable,
    }
}

pub fn func_08079244() callconv(.c) void {
    if (!abi.enter(0x08079244)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[12] = rt.r[1];
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.r[2] >> 16);
            rt.r[3] = abi.read32(rt.r[4] +% 0x34);
            rt.r[0] = abi.read32(0x080792B4);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
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
        2 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.write32(rt.r[4] +% 0x34, rt.r[0]);
            rt.r[2] = abi.read8(rt.r[4] +% 0x8);
            rt.r[3] = abi.read32(rt.r[4] +% 0x2C);
            abi.setRegNz(&rt.r[5], 0x1);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.r[9] = rt.r[0];
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[7], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[0], 0xC);
            rt.r[8] = rt.r[0];
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x080792B4);
            abi.write32(rt.r[4] +% 0x34, rt.r[0]);
            continue :blk 1;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.r[1] = abi.read8(rt.r[3] +% 0x0);
            rt.r[0] = rt.r[9];
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x50, true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 1);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        8 => {
            abi.fetches(7);
            abi.write8(rt.r[3] +% 0xB, @truncate(rt.r[7]));
            abi.write8(rt.r[3] +% 0xD, @truncate(rt.r[6]));
            rt.r[0] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            continue :blk 7;
        },
        else => unreachable,
    }
}

pub fn func_080792B8() callconv(.c) void {
    if (!abi.enter(0x080792B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[7], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[6], rt.r[2] >> 24);
            rt.r[3] = abi.read32(rt.r[4] +% 0x34);
            rt.r[0] = abi.read32(0x0807931C);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.write32(rt.r[4] +% 0x34, rt.r[0]);
            rt.r[2] = abi.read8(rt.r[4] +% 0x8);
            rt.r[1] = abi.read32(rt.r[4] +% 0x2C);
            abi.setRegNz(&rt.r[5], 0x1);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[0], 0x3);
            rt.r[12] = rt.r[0];
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0807931C);
            abi.write32(rt.r[4] +% 0x34, rt.r[0]);
            continue :blk 1;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            rt.r[0] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x50, true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 1);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        8 => {
            abi.fetches(6);
            abi.write8(rt.r[1] +% 0x15, @truncate(rt.r[6]));
            rt.r[0] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 7;
        },
        else => unreachable,
    }
}

pub fn func_0807981E() callconv(.c) void {
    if (!abi.enter(0x0807981E)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x2, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08079844);
            abi.write32(rt.r[7] +% 0x4, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[7] +% 0x4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x28, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x2, true);
            rt.r[1] = abi.read32(rt.r[7] +% 0x4);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x28, true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            continue :blk 6;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[7] +% 0x4);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x4, true);
            abi.write32(rt.r[7] +% 0x4, rt.r[1]);
            continue :blk 1;
        },
        6 => {
            abi.fetches(37);
            rt.r[0] = abi.read32(0x080798B0);
            rt.r[1] = abi.read32(rt.r[7] +% 0x4);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(0x080798B4);
            rt.r[1] = abi.read32(rt.r[7] +% 0x4);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(rt.r[2] +% 0x4);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(0x080798B8);
            rt.r[1] = abi.read32(rt.r[7] +% 0x4);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(rt.r[2] +% 0x8);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(0x080798BC);
            rt.r[1] = abi.read32(rt.r[7] +% 0x4);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(rt.r[2] +% 0xC);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(0x080798C0);
            rt.r[1] = abi.read32(rt.r[7] +% 0x4);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(rt.r[2] +% 0x10);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(0x080798C4);
            rt.r[1] = abi.read32(rt.r[7] +% 0x4);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x14, true);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
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

pub fn func_08079A74() callconv(.c) void {
    if (!abi.enter(0x08079A74)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 7, 14 });
            rt.r[13] -%= 0xC;
            rt.r[7] = rt.r[13];
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(0x08079AA8);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x1, true);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.r[0] = abi.read32(0x08079AAC);
            abi.write32(rt.r[7] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[7] +% 0x8);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] ^ rt.r[1]);
            abi.write32(rt.r[7] +% 0x8, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x4, true);
            rt.r[1] = abi.read32(0x08079AB0);
            rt.r[2] = abi.read32(0x08079AAC);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.r[1] >> 1);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x4, true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x0, true);
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
            abi.fetches(20);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[3] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x4, true);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
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

pub fn func_08079CE4() callconv(.c) void {
    if (!abi.enter(0x08079CE4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 7, 14 });
            rt.r[13] -%= 0xC;
            rt.r[7] = rt.r[13];
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            abi.write32(rt.r[7] +% 0x4, rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(17);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[1], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            rt.r[1] = abi.read32(0x08079D18);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x4, true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[4] = abi.read32(rt.r[7] +% 0x0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            rt.r[3] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            abi.write32(rt.r[7] +% 0x0, rt.r[4]);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
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
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[7] +% 0x4);
            rt.cpuSub(&rt.r[1], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            continue :blk 1;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 4, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08079F1C() callconv(.c) void {
    if (!abi.enter(0x08079F1C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 7, 14 });
            rt.r[13] -%= 0x50;
            rt.r[7] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(47);
            rt.r[0] = abi.read32(0x08079FC8);
            rt.r[1] = abi.read32(0x08079FC8);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            rt.r[3] = abi.read32(0x08079FCC);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[3]);
            rt.r[3] = abi.read32(0x08079FD0);
            rt.r[2] = abi.read32(rt.r[3] +% 0x0);
            rt.r[2] = abi.read16(rt.r[2] +% 0x10);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[2] = abi.read32(0x08079FD0);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x8);
            abi.setRegNz(&rt.r[0], rt.armLsl(rt.r[0], rt.r[2] & 0xFF));
            abi.setRegNz(&rt.r[2], 0xE0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 20);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            abi.write32(rt.r[7] +% 0x8, rt.r[1]);
            rt.r[0] = abi.read32(0x08079FD4);
            abi.setRegNz(&rt.r[1], 0xAA);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08079FD8);
            abi.setRegNz(&rt.r[1], 0x55);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08079FD4);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08079FD4);
            abi.setRegNz(&rt.r[1], 0xAA);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08079FD8);
            abi.setRegNz(&rt.r[1], 0x55);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[7] +% 0x8);
            abi.setRegNz(&rt.r[1], 0x30);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(func_08079A74, 0x08079F93)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08079F34);
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08079FDC);
            rt.r[1] = abi.read32(rt.r[7] +% 0x8);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[2], 0xFF);
            if (!abi.call(tail_low.func_0807B458, 0x08079FA1)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0x50;
            popRegsSeq(&.{ 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
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
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0807A638() callconv(.c) void {
    if (!abi.enter(0x0807A638)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(37);
            pushRegs(&.{ 4, 7, 14 });
            rt.r[13] -%= 0x14;
            rt.r[7] = rt.r[13];
            abi.write32(rt.r[7] +% 0x4, rt.r[1]);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(0x0807A688);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.armLsl(rt.r[0], rt.r[2] & 0xFF));
            abi.setRegNz(&rt.r[2], 0xE0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 20);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            abi.write32(rt.r[7] +% 0xC, rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            rt.r[1] = abi.read32(0x0807A68C);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(0x0807A68C);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0807A690);
            abi.setRegNz(&rt.r[1], 0xAA);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0807A694);
            abi.setRegNz(&rt.r[1], 0x55);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0807A690);
            abi.setRegNz(&rt.r[1], 0xA0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0807A688);
            rt.r[1] = abi.read32(rt.r[0] +% 0x18);
            abi.write32(rt.r[7] +% 0x8, rt.r[1]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[7] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(17);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xC, true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[7], 0x4, true);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            rt.r[4] = abi.read8(rt.r[3] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            abi.write32(rt.r[2] +% 0x0, rt.r[3]);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[7] +% 0x8);
            rt.cpuSub(&rt.r[1], rt.r[0], 0x1, true);
            abi.write32(rt.r[7] +% 0x8, rt.r[1]);
            continue :blk 1;
        },
        4 => {
            abi.fetches(21);
            rt.r[0] = abi.read32(rt.r[7] +% 0xC);
            rt.cpuSub(&rt.r[1], rt.r[0], 0x1, true);
            abi.write32(rt.r[7] +% 0xC, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[7] +% 0x4);
            rt.cpuSub(&rt.r[1], rt.r[0], 0x1, true);
            abi.write32(rt.r[7] +% 0x4, rt.r[1]);
            rt.r[0] = abi.read32(0x0807A6E4);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x10, true);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(0x0807A6E8);
            rt.r[1] = abi.read32(rt.r[7] +% 0xC);
            rt.r[3] = abi.read32(rt.r[7] +% 0x4);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(tail_low.func_0807B458, 0x0807A6DD)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[13] +%= 0x14;
            popRegsSeq(&.{ 4, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807AD1C() callconv(.c) void {
    if (!abi.enter(0x0807AD1C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[6] = abi.read32(0x0807AD44);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(low_peel_5.func_0807B2B0, 0x0807AD2D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_2.func_0807B210, 0x0807AD51)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_5.func_0807B068, 0x0807AD41)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            continue :blk 8;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(func_0807B22C, 0x0807AD5F)) return;
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5, 6, 7, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        9 => {
            abi.fetches(3);
            continue :blk 8;
        },
        else => unreachable,
    }
}

pub fn func_0807AD88() callconv(.c) void {
    if (!abi.enter(0x0807AD88)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x0807AD94);
            if (!abi.call(low_peel_2.func_0807B018, 0x0807AD91)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[5] = abi.read32(0x0807ADE8);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_2.func_0807B158, 0x0807ADB1)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x0807ADEC);
            abi.setRegNz(&rt.r[3], 0x1);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x1D, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 4;
        },
        6 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(tail_low.func_0807B45C, 0x0807AD9D)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x0807ADEC);
            abi.setRegNz(&rt.r[3], 0x1);
            continue :blk 10;
        },
        9 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_5.func_0807B034, 0x0807ADA3)) return;
            continue :blk 2;
        },
        10 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            if (!abi.call(tail_low.func_0807B45C, 0x0807ADD9)) return;
            continue :blk 14;
        },
        13 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        14 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0807ADE8);
            if (!abi.call(low_peel_5.func_0807B034, 0x0807ADDF)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 13;
        },
        else => unreachable,
    }
}

pub fn func_0807AE60() callconv(.c) void {
    if (!abi.enter(0x0807AE60)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0807AE98);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        6 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0807AEC0);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 9);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[1]);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        7 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(0x0807AE74);
            continue :blk 6;
        },
        8 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0807AE8C);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(0x0807AE80);
            continue :blk 6;
        },
        10 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0807AEBC);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            continue :blk 3;
        },
        11 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0807AEC4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 13;
        },
        12 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0807AED0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            continue :blk 13;
        },
        13 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807B188() callconv(.c) void {
    if (!abi.enter(0x0807B188)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(rt.r[5] +% 0xC);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x1);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xC, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 1;
        },
        6 => {
            abi.fetches(6);
            rt.r[3] = abi.read8(rt.r[2] +% 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.cpuSub(null, rt.r[0], 0xFE, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.r[3] = abi.read8(rt.r[2] +% 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xFF);
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            abi.write8(rt.r[2] +% 0x8, @truncate(rt.r[0]));
            continue :blk 5;
        },
        10 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0807B1C0() callconv(.c) void {
    if (!abi.enter(0x0807B1C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0xC;
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.r[1] = abi.read32(rt.r[4] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(10);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.r[0] = rt.r[13];
            rt.r[1] = abi.read8(rt.r[1] +% 0x8);
            abi.write8(rt.r[0] +% 0x8, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_13.func_0807B090, 0x0807B1EB)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 4, 5, 6, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(func_0807B188, 0x0807B1F7)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            rt.r[0] = rt.r[13];
            rt.r[3] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_13.func_0807AF64, 0x0807B205)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0807B22C() callconv(.c) void {
    if (!abi.enter(0x0807B22C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0xC;
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.r[1] = abi.read32(rt.r[5] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807B090, 0x0807B251)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 4, 5, 6, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_13.func_0807AF64, 0x0807B261)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0807B26C() callconv(.c) void {
    if (!abi.enter(0x0807B26C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0xC;
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.r[1] = abi.read32(rt.r[5] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807B090, 0x0807B291)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 4, 5, 6, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            rt.r[0] = rt.r[13];
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuAdd(&rt.r[3], rt.r[0], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807AF64, 0x0807B2A5)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0807B340() callconv(.c) void {
    if (!abi.enter(0x0807B340)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        2 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            abi.setRegNz(&rt.r[4], 0xC0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 19);
            rt.cpuAdd(&rt.r[6], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[2] << 20);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[7], rt.r[2] << 5);
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.r[3] = rt.r[8];
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[3], 16));
            if (!abi.call(hw.func_0807B2DC, 0x0807B369)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[6], rt.r[6], rt.r[0], true);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[7], true);
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

pub fn func_0807B38C() callconv(.c) void {
    if (!abi.enter(0x0807B38C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[7], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.r[3] = rt.r[8];
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[3], 16));
            if (!abi.call(hw.func_0807B2DC, 0x0807B3AF)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x40, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[7], true);
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

pub fn func_0807B3E8() callconv(.c) void {
    if (!abi.enter(0x0807B3E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[2] = abi.read32(0x0807B42C);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[2] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0807B42C);
            abi.setRegNz(&rt.r[0], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0807B430);
            if (!abi.call(func_0807CF10, 0x0807B42B)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            continue :blk 8;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            if (!abi.call(tail_low.func_0807B44C, 0x0807B41D)) return;
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        8 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 1;
        },
        9 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x4, true);
            rt.cpuSub(&rt.r[5], rt.r[5], 0x1, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0807B520() callconv(.c) void {
    if (!abi.enter(0x0807B520)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[3] = abi.read32(0x0807B540);
            rt.r[2] = abi.read32(0x0807B53C);
            if (!abi.call(func_0807C2A0, 0x0807B52F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[3] = abi.read32(0x0807B560);
            rt.r[2] = abi.read32(0x0807B55C);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(math.func_0807BBF8, 0x0807B551)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807C400, 0x0807B53B)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(low_peel_13.func_0807C400, 0x0807B555)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807C1BC() callconv(.c) void {
    if (!abi.enter(0x0807C1BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x38;
            abi.write32(rt.r[13] +% 0x28, rt.r[0]);
            abi.write32(rt.r[13] +% 0x2C, rt.r[1]);
            abi.write32(rt.r[13] +% 0x30, rt.r[2]);
            abi.write32(rt.r[13] +% 0x34, rt.r[3]);
            rt.r[0] = rt.r[13] +% 0x28;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C1D1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = rt.r[13] +% 0x30;
            rt.r[4] = rt.r[13] +% 0x14;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C1DB)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x38;
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807C090, 0x0807C203)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0807C208() callconv(.c) void {
    if (!abi.enter(0x0807C208)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x38;
            abi.write32(rt.r[13] +% 0x28, rt.r[0]);
            abi.write32(rt.r[13] +% 0x2C, rt.r[1]);
            abi.write32(rt.r[13] +% 0x30, rt.r[2]);
            abi.write32(rt.r[13] +% 0x34, rt.r[3]);
            rt.r[0] = rt.r[13] +% 0x28;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C21D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = rt.r[13] +% 0x30;
            rt.r[4] = rt.r[13] +% 0x14;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C227)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x38;
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807C090, 0x0807C24F)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0807C254() callconv(.c) void {
    if (!abi.enter(0x0807C254)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x38;
            abi.write32(rt.r[13] +% 0x28, rt.r[0]);
            abi.write32(rt.r[13] +% 0x2C, rt.r[1]);
            abi.write32(rt.r[13] +% 0x30, rt.r[2]);
            abi.write32(rt.r[13] +% 0x34, rt.r[3]);
            rt.r[0] = rt.r[13] +% 0x28;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C269)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = rt.r[13] +% 0x30;
            rt.r[4] = rt.r[13] +% 0x14;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C273)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x38;
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807C090, 0x0807C29D)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0807C2A0() callconv(.c) void {
    if (!abi.enter(0x0807C2A0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x38;
            abi.write32(rt.r[13] +% 0x28, rt.r[0]);
            abi.write32(rt.r[13] +% 0x2C, rt.r[1]);
            abi.write32(rt.r[13] +% 0x30, rt.r[2]);
            abi.write32(rt.r[13] +% 0x34, rt.r[3]);
            rt.r[0] = rt.r[13] +% 0x28;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C2B5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = rt.r[13] +% 0x30;
            rt.r[4] = rt.r[13] +% 0x14;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C2BF)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x38;
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807C090, 0x0807C2E9)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0807C2EC() callconv(.c) void {
    if (!abi.enter(0x0807C2EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x38;
            abi.write32(rt.r[13] +% 0x28, rt.r[0]);
            abi.write32(rt.r[13] +% 0x2C, rt.r[1]);
            abi.write32(rt.r[13] +% 0x30, rt.r[2]);
            abi.write32(rt.r[13] +% 0x34, rt.r[3]);
            rt.r[0] = rt.r[13] +% 0x28;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C301)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = rt.r[13] +% 0x30;
            rt.r[4] = rt.r[13] +% 0x14;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C30B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x38;
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807C090, 0x0807C333)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0807C338() callconv(.c) void {
    if (!abi.enter(0x0807C338)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x38;
            abi.write32(rt.r[13] +% 0x28, rt.r[0]);
            abi.write32(rt.r[13] +% 0x2C, rt.r[1]);
            abi.write32(rt.r[13] +% 0x30, rt.r[2]);
            abi.write32(rt.r[13] +% 0x34, rt.r[3]);
            rt.r[0] = rt.r[13] +% 0x28;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C34D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = rt.r[13] +% 0x30;
            rt.r[4] = rt.r[13] +% 0x14;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C357)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x38;
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807C090, 0x0807C37F)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0807C384() callconv(.c) void {
    if (!abi.enter(0x0807C384)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x14;
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 31);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x3C);
            abi.write32(rt.r[13] +% 0x8, rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[2], 31));
            continue :blk 8;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807B76C, 0x0807C3F9)) return;
            continue :blk 9;
        },
        6 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0807C3B8);
            rt.r[0] = abi.read32(0x0807C3B4);
            continue :blk 9;
        },
        7 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], 0, rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 31));
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            abi.write32(rt.r[13] +% 0xC, rt.r[0]);
            abi.write32(rt.r[13] +% 0x10, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[13] +% 0x10);
            rt.r[1] = abi.read32(0x0807C3FC);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x14;
            popRegsSeq(&.{ 4, 5, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[4] = abi.read32(rt.r[13] +% 0x8);
            continue :blk 11;
        },
        11 => {
            abi.fetches(15);
            rt.r[0] = abi.read32(rt.r[13] +% 0xC);
            rt.r[1] = abi.read32(rt.r[13] +% 0x10);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 31);
            abi.setRegNz(&rt.r[2], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write32(rt.r[13] +% 0xC, rt.r[0]);
            abi.write32(rt.r[13] +% 0x10, rt.r[1]);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[0] = abi.read32(rt.r[13] +% 0x10);
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 11;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(3);
            abi.write32(rt.r[13] +% 0x8, rt.r[4]);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_0807C4C4() callconv(.c) void {
    if (!abi.enter(0x0807C4C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x1C;
            abi.write32(rt.r[13] +% 0x14, rt.r[0]);
            abi.write32(rt.r[13] +% 0x18, rt.r[1]);
            rt.r[0] = rt.r[13] +% 0x14;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C4D5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(16);
            rt.r[2] = abi.read32(rt.r[13] +% 0xC);
            rt.r[3] = abi.read32(rt.r[13] +% 0x10);
            abi.setRegNz(&rt.r[5], rt.r[3] << 2);
            abi.setRegNz(&rt.r[4], rt.r[2] >> 30);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[4]);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[4] = abi.read32(0x0807C504);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.r[1] = abi.read32(rt.r[13] +% 0x4);
            rt.r[2] = abi.read32(rt.r[13] +% 0x8);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(hw.func_0807CE10, 0x0807C501)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[5], rt.r[5] | rt.r[0]);
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            rt.r[13] +%= 0x1C;
            popRegsSeq(&.{ 4, 5, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807CB74() callconv(.c) void {
    if (!abi.enter(0x0807CB74)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x28;
            abi.write32(rt.r[13] +% 0x20, rt.r[0]);
            abi.write32(rt.r[13] +% 0x24, rt.r[1]);
            rt.r[0] = rt.r[13] +% 0x20;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CB85)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = rt.r[13] +% 0x24;
            rt.r[4] = rt.r[13] +% 0x10;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CB8F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x28;
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807CA68, 0x0807CBB7)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0807CBBC() callconv(.c) void {
    if (!abi.enter(0x0807CBBC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x28;
            abi.write32(rt.r[13] +% 0x20, rt.r[0]);
            abi.write32(rt.r[13] +% 0x24, rt.r[1]);
            rt.r[0] = rt.r[13] +% 0x20;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CBCD)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = rt.r[13] +% 0x24;
            rt.r[4] = rt.r[13] +% 0x10;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CBD7)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x28;
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807CA68, 0x0807CBFF)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0807CC04() callconv(.c) void {
    if (!abi.enter(0x0807CC04)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x28;
            abi.write32(rt.r[13] +% 0x20, rt.r[0]);
            abi.write32(rt.r[13] +% 0x24, rt.r[1]);
            rt.r[0] = rt.r[13] +% 0x20;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CC15)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = rt.r[13] +% 0x24;
            rt.r[4] = rt.r[13] +% 0x10;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CC1F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x28;
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807CA68, 0x0807CC49)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0807CC4C() callconv(.c) void {
    if (!abi.enter(0x0807CC4C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x28;
            abi.write32(rt.r[13] +% 0x20, rt.r[0]);
            abi.write32(rt.r[13] +% 0x24, rt.r[1]);
            rt.r[0] = rt.r[13] +% 0x20;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CC5D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = rt.r[13] +% 0x24;
            rt.r[4] = rt.r[13] +% 0x10;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CC67)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x28;
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807CA68, 0x0807CC91)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0807CC94() callconv(.c) void {
    if (!abi.enter(0x0807CC94)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x28;
            abi.write32(rt.r[13] +% 0x20, rt.r[0]);
            abi.write32(rt.r[13] +% 0x24, rt.r[1]);
            rt.r[0] = rt.r[13] +% 0x20;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CCA5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = rt.r[13] +% 0x24;
            rt.r[4] = rt.r[13] +% 0x10;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CCAF)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x28;
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807CA68, 0x0807CCD7)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0807CCDC() callconv(.c) void {
    if (!abi.enter(0x0807CCDC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x28;
            abi.write32(rt.r[13] +% 0x20, rt.r[0]);
            abi.write32(rt.r[13] +% 0x24, rt.r[1]);
            rt.r[0] = rt.r[13] +% 0x20;
            rt.r[1] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CCED)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = rt.r[13] +% 0x24;
            rt.r[4] = rt.r[13] +% 0x10;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CCF7)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(rt.r[13] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 9;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x28;
            popRegsSeq(&.{ 4, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807CA68, 0x0807CD1F)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_0807CD24() callconv(.c) void {
    if (!abi.enter(0x0807CD24)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[13] -%= 0x10;
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[2], rt.r[1] >> 31);
            abi.write32(rt.r[13] +% 0x4, rt.r[2]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x1E);
            abi.write32(rt.r[13] +% 0x8, rt.r[0]);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(3);
            abi.write32(rt.r[13] +% 0xC, rt.r[1]);
            continue :blk 8;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = rt.r[13];
            if (!abi.call(low_peel_13.func_0807C508, 0x0807CD7B)) return;
            continue :blk 9;
        },
        6 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0807CD50);
            continue :blk 9;
        },
        7 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], 0, rt.r[1], true);
            abi.write32(rt.r[13] +% 0xC, rt.r[0]);
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(rt.r[13] +% 0xC);
            rt.r[3] = abi.read32(0x0807CD80);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            rt.r[13] +%= 0x10;
            popRegsSeq(&.{ 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        10 => {
            abi.fetches(3);
            rt.r[1] = abi.read32(rt.r[13] +% 0x8);
            continue :blk 11;
        },
        11 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 11;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            abi.write32(rt.r[13] +% 0x8, rt.r[1]);
            abi.write32(rt.r[13] +% 0xC, rt.r[0]);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_0807CE88() callconv(.c) void {
    if (!abi.enter(0x0807CE88)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(31);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x10;
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.write32(rt.r[13] +% 0x8, rt.r[2]);
            abi.write32(rt.r[13] +% 0xC, rt.r[3]);
            rt.r[3] = abi.read32(rt.r[13] +% 0x0);
            rt.r[0] = abi.read32(0x0807CEF4);
            rt.r[12] = rt.r[0];
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.r[1] = abi.read32(rt.r[13] +% 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.r[4] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[5], rt.r[5] *% rt.r[0]);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] *% rt.r[1]);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[0]);
            abi.setRegNz(&rt.r[3], rt.r[3] *% rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[5] >> 16);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[2], true);
            rt.cpuSub(null, rt.r[4], rt.r[2], true);
            if (rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(24);
            abi.setRegNz(&rt.r[0], rt.r[4] >> 16);
            rt.cpuAdd(&rt.r[7], rt.r[3], rt.r[0], true);
            rt.r[1] = rt.r[12];
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[1]);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[5]);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.r[3] = abi.read32(rt.r[13] +% 0x0);
            rt.r[4] = abi.read32(rt.r[13] +% 0xC);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[4]);
            rt.r[5] = abi.read32(rt.r[13] +% 0x4);
            rt.r[4] = abi.read32(rt.r[13] +% 0x8);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] *% rt.r[4]);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[2], true);
            rt.r[13] +%= 0x10;
            popRegsSeq(&.{ 4, 5, 6, 7, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 9);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0807CF10() callconv(.c) void {
    if (!abi.enter(0x0807CF10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.r[5] = abi.read32(0x0807CF44);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[4], 0xA4);
            abi.setRegNz(&rt.r[4], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[3] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x1F, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0xA6);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[2], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x88);
            if (!abi.call(low_peel_3.func_08012D8C, 0x0807CF39)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[3] +% 0x4);
            abi.setRegNz(&rt.r[2], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[6]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[3] +% 0x4, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5, 6, 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 6;
        },
        8 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[3] +% 0x4, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[3] +% 0x0, rt.r[1]);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            continue :blk 4;
        },
        else => unreachable,
    }
}

comptime {
    if (!builtin.is_test) {
        @export(&func_0805F150, .{ .name = "func_0805F150", .linkage = .strong });
        @export(&func_0805F1B0, .{ .name = "func_0805F1B0", .linkage = .strong });
        @export(&func_0805F3F2, .{ .name = "func_0805F3F2", .linkage = .strong });
        @export(&func_0805F3FE, .{ .name = "func_0805F3FE", .linkage = .strong });
        @export(&func_0805F6A4, .{ .name = "func_0805F6A4", .linkage = .strong });
        @export(&func_0805FBF6, .{ .name = "func_0805FBF6", .linkage = .strong });
        @export(&func_0805FC94, .{ .name = "func_0805FC94", .linkage = .strong });
        @export(&func_0805FDDC, .{ .name = "func_0805FDDC", .linkage = .strong });
        @export(&func_0805FDF2, .{ .name = "func_0805FDF2", .linkage = .strong });
        @export(&func_08060732, .{ .name = "func_08060732", .linkage = .strong });
        @export(&func_080607C4, .{ .name = "func_080607C4", .linkage = .strong });
        @export(&func_080607EA, .{ .name = "func_080607EA", .linkage = .strong });
        @export(&func_08060A34, .{ .name = "func_08060A34", .linkage = .strong });
        @export(&func_08060ED8, .{ .name = "func_08060ED8", .linkage = .strong });
        @export(&func_0806198C, .{ .name = "func_0806198C", .linkage = .strong });
        @export(&func_080619F8, .{ .name = "func_080619F8", .linkage = .strong });
        @export(&func_08061A64, .{ .name = "func_08061A64", .linkage = .strong });
        @export(&func_08061DC0, .{ .name = "func_08061DC0", .linkage = .strong });
        @export(&func_08062C10, .{ .name = "func_08062C10", .linkage = .strong });
        @export(&func_08062C90, .{ .name = "func_08062C90", .linkage = .strong });
        @export(&func_08062CFC, .{ .name = "func_08062CFC", .linkage = .strong });
        @export(&func_08062EF8, .{ .name = "func_08062EF8", .linkage = .strong });
        @export(&func_08062F3C, .{ .name = "func_08062F3C", .linkage = .strong });
        @export(&func_08062FD8, .{ .name = "func_08062FD8", .linkage = .strong });
        @export(&func_08063188, .{ .name = "func_08063188", .linkage = .strong });
        @export(&func_08063210, .{ .name = "func_08063210", .linkage = .strong });
        @export(&func_080632C4, .{ .name = "func_080632C4", .linkage = .strong });
        @export(&func_08065BFC, .{ .name = "func_08065BFC", .linkage = .strong });
        @export(&func_08066C28, .{ .name = "func_08066C28", .linkage = .strong });
        @export(&func_080677B0, .{ .name = "func_080677B0", .linkage = .strong });
        @export(&func_080677EC, .{ .name = "func_080677EC", .linkage = .strong });
        @export(&func_08067BD0, .{ .name = "func_08067BD0", .linkage = .strong });
        @export(&func_0806820C, .{ .name = "func_0806820C", .linkage = .strong });
        @export(&func_080684C4, .{ .name = "func_080684C4", .linkage = .strong });
        @export(&func_08068848, .{ .name = "func_08068848", .linkage = .strong });
        @export(&func_08068A64, .{ .name = "func_08068A64", .linkage = .strong });
        @export(&func_08068AE0, .{ .name = "func_08068AE0", .linkage = .strong });
        @export(&func_08069134, .{ .name = "func_08069134", .linkage = .strong });
        @export(&func_080691A4, .{ .name = "func_080691A4", .linkage = .strong });
        @export(&func_0806A18C, .{ .name = "func_0806A18C", .linkage = .strong });
        @export(&func_0806A1C8, .{ .name = "func_0806A1C8", .linkage = .strong });
        @export(&func_0806A218, .{ .name = "func_0806A218", .linkage = .strong });
        @export(&func_0806A27C, .{ .name = "func_0806A27C", .linkage = .strong });
        @export(&func_0806A324, .{ .name = "func_0806A324", .linkage = .strong });
        @export(&func_0806A3E8, .{ .name = "func_0806A3E8", .linkage = .strong });
        @export(&func_0806A668, .{ .name = "func_0806A668", .linkage = .strong });
        @export(&func_0806A8F4, .{ .name = "func_0806A8F4", .linkage = .strong });
        @export(&func_0806AE08, .{ .name = "func_0806AE08", .linkage = .strong });
        @export(&func_0806B048, .{ .name = "func_0806B048", .linkage = .strong });
        @export(&func_0806B438, .{ .name = "func_0806B438", .linkage = .strong });
        @export(&func_0806B840, .{ .name = "func_0806B840", .linkage = .strong });
        @export(&func_0806B894, .{ .name = "func_0806B894", .linkage = .strong });
        @export(&func_0806BC1C, .{ .name = "func_0806BC1C", .linkage = .strong });
        @export(&func_0806BD38, .{ .name = "func_0806BD38", .linkage = .strong });
        @export(&func_0806BFF4, .{ .name = "func_0806BFF4", .linkage = .strong });
        @export(&func_0806C080, .{ .name = "func_0806C080", .linkage = .strong });
        @export(&func_0806C164, .{ .name = "func_0806C164", .linkage = .strong });
        @export(&func_0806C1B0, .{ .name = "func_0806C1B0", .linkage = .strong });
        @export(&func_0806C2B0, .{ .name = "func_0806C2B0", .linkage = .strong });
        @export(&func_0806C78C, .{ .name = "func_0806C78C", .linkage = .strong });
        @export(&func_0806C804, .{ .name = "func_0806C804", .linkage = .strong });
        @export(&func_0806C87C, .{ .name = "func_0806C87C", .linkage = .strong });
        @export(&func_0806C9C0, .{ .name = "func_0806C9C0", .linkage = .strong });
        @export(&func_0806CA64, .{ .name = "func_0806CA64", .linkage = .strong });
        @export(&func_0806CCAC, .{ .name = "func_0806CCAC", .linkage = .strong });
        @export(&func_0806D624, .{ .name = "func_0806D624", .linkage = .strong });
        @export(&func_0806D69C, .{ .name = "func_0806D69C", .linkage = .strong });
        @export(&func_0806D84C, .{ .name = "func_0806D84C", .linkage = .strong });
        @export(&func_0806D8E8, .{ .name = "func_0806D8E8", .linkage = .strong });
        @export(&func_0806D95C, .{ .name = "func_0806D95C", .linkage = .strong });
        @export(&func_0806DB38, .{ .name = "func_0806DB38", .linkage = .strong });
        @export(&func_0806DBD0, .{ .name = "func_0806DBD0", .linkage = .strong });
        @export(&func_0806DDC4, .{ .name = "func_0806DDC4", .linkage = .strong });
        @export(&func_0806DE9C, .{ .name = "func_0806DE9C", .linkage = .strong });
        @export(&func_0806DF64, .{ .name = "func_0806DF64", .linkage = .strong });
        @export(&func_0806DFDC, .{ .name = "func_0806DFDC", .linkage = .strong });
        @export(&func_0806E044, .{ .name = "func_0806E044", .linkage = .strong });
        @export(&func_0806E180, .{ .name = "func_0806E180", .linkage = .strong });
        @export(&func_0806E1D8, .{ .name = "func_0806E1D8", .linkage = .strong });
        @export(&func_0806E24C, .{ .name = "func_0806E24C", .linkage = .strong });
        @export(&func_0806E338, .{ .name = "func_0806E338", .linkage = .strong });
        @export(&func_0806E39C, .{ .name = "func_0806E39C", .linkage = .strong });
        @export(&func_0806E41C, .{ .name = "func_0806E41C", .linkage = .strong });
        @export(&func_0806E8D8, .{ .name = "func_0806E8D8", .linkage = .strong });
        @export(&func_0806F074, .{ .name = "func_0806F074", .linkage = .strong });
        @export(&func_0806F8FC, .{ .name = "func_0806F8FC", .linkage = .strong });
        @export(&func_0806F924, .{ .name = "func_0806F924", .linkage = .strong });
        @export(&func_0806FA18, .{ .name = "func_0806FA18", .linkage = .strong });
        @export(&func_0806FB00, .{ .name = "func_0806FB00", .linkage = .strong });
        @export(&func_0806FD78, .{ .name = "func_0806FD78", .linkage = .strong });
        @export(&func_0806FDE0, .{ .name = "func_0806FDE0", .linkage = .strong });
        @export(&func_0806FDE6, .{ .name = "func_0806FDE6", .linkage = .strong });
        @export(&func_0806FE08, .{ .name = "func_0806FE08", .linkage = .strong });
        @export(&func_0806FE12, .{ .name = "func_0806FE12", .linkage = .strong });
        @export(&func_0806FF10, .{ .name = "func_0806FF10", .linkage = .strong });
        @export(&func_08070094, .{ .name = "func_08070094", .linkage = .strong });
        @export(&func_080701B8, .{ .name = "func_080701B8", .linkage = .strong });
        @export(&func_080701F8, .{ .name = "func_080701F8", .linkage = .strong });
        @export(&func_08070370, .{ .name = "func_08070370", .linkage = .strong });
        @export(&func_0807042C, .{ .name = "func_0807042C", .linkage = .strong });
        @export(&func_08070490, .{ .name = "func_08070490", .linkage = .strong });
        @export(&func_080705CC, .{ .name = "func_080705CC", .linkage = .strong });
        @export(&func_08070602, .{ .name = "func_08070602", .linkage = .strong });
        @export(&func_0807070E, .{ .name = "func_0807070E", .linkage = .strong });
        @export(&func_08070804, .{ .name = "func_08070804", .linkage = .strong });
        @export(&func_08070806, .{ .name = "func_08070806", .linkage = .strong });
        @export(&func_08070808, .{ .name = "func_08070808", .linkage = .strong });
        @export(&func_0807080A, .{ .name = "func_0807080A", .linkage = .strong });
        @export(&func_0807080E, .{ .name = "func_0807080E", .linkage = .strong });
        @export(&func_08070900, .{ .name = "func_08070900", .linkage = .strong });
        @export(&func_08070906, .{ .name = "func_08070906", .linkage = .strong });
        @export(&func_08070908, .{ .name = "func_08070908", .linkage = .strong });
        @export(&func_0807090A, .{ .name = "func_0807090A", .linkage = .strong });
        @export(&func_08070A0A, .{ .name = "func_08070A0A", .linkage = .strong });
        @export(&func_08070A6C, .{ .name = "func_08070A6C", .linkage = .strong });
        @export(&func_08070B88, .{ .name = "func_08070B88", .linkage = .strong });
        @export(&func_08070F0C, .{ .name = "func_08070F0C", .linkage = .strong });
        @export(&func_08071108, .{ .name = "func_08071108", .linkage = .strong });
        @export(&func_080712F0, .{ .name = "func_080712F0", .linkage = .strong });
        @export(&func_0807145C, .{ .name = "func_0807145C", .linkage = .strong });
        @export(&func_0807198C, .{ .name = "func_0807198C", .linkage = .strong });
        @export(&func_08071E14, .{ .name = "func_08071E14", .linkage = .strong });
        @export(&func_080720A8, .{ .name = "func_080720A8", .linkage = .strong });
        @export(&func_080723E8, .{ .name = "func_080723E8", .linkage = .strong });
        @export(&func_080727A0, .{ .name = "func_080727A0", .linkage = .strong });
        @export(&func_08072810, .{ .name = "func_08072810", .linkage = .strong });
        @export(&func_0807289C, .{ .name = "func_0807289C", .linkage = .strong });
        @export(&func_08072A74, .{ .name = "func_08072A74", .linkage = .strong });
        @export(&func_08072E3C, .{ .name = "func_08072E3C", .linkage = .strong });
        @export(&func_08072F6C, .{ .name = "func_08072F6C", .linkage = .strong });
        @export(&func_08073250, .{ .name = "func_08073250", .linkage = .strong });
        @export(&func_0807363C, .{ .name = "func_0807363C", .linkage = .strong });
        @export(&func_08073EC4, .{ .name = "func_08073EC4", .linkage = .strong });
        @export(&func_08074362, .{ .name = "func_08074362", .linkage = .strong });
        @export(&func_080745F4, .{ .name = "func_080745F4", .linkage = .strong });
        @export(&func_08074BC0, .{ .name = "func_08074BC0", .linkage = .strong });
        @export(&func_08074F44, .{ .name = "func_08074F44", .linkage = .strong });
        @export(&func_08075098, .{ .name = "func_08075098", .linkage = .strong });
        @export(&func_08075194, .{ .name = "func_08075194", .linkage = .strong });
        @export(&func_08075304, .{ .name = "func_08075304", .linkage = .strong });
        @export(&func_08075360, .{ .name = "func_08075360", .linkage = .strong });
        @export(&func_08075898, .{ .name = "func_08075898", .linkage = .strong });
        @export(&func_0807592C, .{ .name = "func_0807592C", .linkage = .strong });
        @export(&func_08075A3C, .{ .name = "func_08075A3C", .linkage = .strong });
        @export(&func_08075ACC, .{ .name = "func_08075ACC", .linkage = .strong });
        @export(&func_08075C8C, .{ .name = "func_08075C8C", .linkage = .strong });
        @export(&func_08075D08, .{ .name = "func_08075D08", .linkage = .strong });
        @export(&func_08075E34, .{ .name = "func_08075E34", .linkage = .strong });
        @export(&func_08075F84, .{ .name = "func_08075F84", .linkage = .strong });
        @export(&func_08075FFC, .{ .name = "func_08075FFC", .linkage = .strong });
        @export(&func_08076138, .{ .name = "func_08076138", .linkage = .strong });
        @export(&func_080761D4, .{ .name = "func_080761D4", .linkage = .strong });
        @export(&func_08076240, .{ .name = "func_08076240", .linkage = .strong });
        @export(&func_08076384, .{ .name = "func_08076384", .linkage = .strong });
        @export(&func_080765B8, .{ .name = "func_080765B8", .linkage = .strong });
        @export(&func_08076628, .{ .name = "func_08076628", .linkage = .strong });
        @export(&func_08076778, .{ .name = "func_08076778", .linkage = .strong });
        @export(&func_080768C0, .{ .name = "func_080768C0", .linkage = .strong });
        @export(&func_08076944, .{ .name = "func_08076944", .linkage = .strong });
        @export(&func_08076D2C, .{ .name = "func_08076D2C", .linkage = .strong });
        @export(&func_08077080, .{ .name = "func_08077080", .linkage = .strong });
        @export(&func_080770E8, .{ .name = "func_080770E8", .linkage = .strong });
        @export(&func_08077218, .{ .name = "func_08077218", .linkage = .strong });
        @export(&func_080775C2, .{ .name = "func_080775C2", .linkage = .strong });
        @export(&func_08077AD0, .{ .name = "func_08077AD0", .linkage = .strong });
        @export(&func_08077C04, .{ .name = "func_08077C04", .linkage = .strong });
        @export(&func_08078124, .{ .name = "func_08078124", .linkage = .strong });
        @export(&func_0807831C, .{ .name = "func_0807831C", .linkage = .strong });
        @export(&func_08078368, .{ .name = "func_08078368", .linkage = .strong });
        @export(&func_08078498, .{ .name = "func_08078498", .linkage = .strong });
        @export(&func_08078864, .{ .name = "func_08078864", .linkage = .strong });
        @export(&func_08078CB8, .{ .name = "func_08078CB8", .linkage = .strong });
        @export(&func_08078D08, .{ .name = "func_08078D08", .linkage = .strong });
        @export(&func_080791DC, .{ .name = "func_080791DC", .linkage = .strong });
        @export(&func_08079244, .{ .name = "func_08079244", .linkage = .strong });
        @export(&func_080792B8, .{ .name = "func_080792B8", .linkage = .strong });
        @export(&func_0807981E, .{ .name = "func_0807981E", .linkage = .strong });
        @export(&func_08079A74, .{ .name = "func_08079A74", .linkage = .strong });
        @export(&func_08079CE4, .{ .name = "func_08079CE4", .linkage = .strong });
        @export(&func_08079F1C, .{ .name = "func_08079F1C", .linkage = .strong });
        @export(&func_0807A638, .{ .name = "func_0807A638", .linkage = .strong });
        @export(&func_0807AD1C, .{ .name = "func_0807AD1C", .linkage = .strong });
        @export(&func_0807AD88, .{ .name = "func_0807AD88", .linkage = .strong });
        @export(&func_0807AE60, .{ .name = "func_0807AE60", .linkage = .strong });
        @export(&func_0807B188, .{ .name = "func_0807B188", .linkage = .strong });
        @export(&func_0807B1C0, .{ .name = "func_0807B1C0", .linkage = .strong });
        @export(&func_0807B22C, .{ .name = "func_0807B22C", .linkage = .strong });
        @export(&func_0807B26C, .{ .name = "func_0807B26C", .linkage = .strong });
        @export(&func_0807B340, .{ .name = "func_0807B340", .linkage = .strong });
        @export(&func_0807B38C, .{ .name = "func_0807B38C", .linkage = .strong });
        @export(&func_0807B3E8, .{ .name = "func_0807B3E8", .linkage = .strong });
        @export(&func_0807B520, .{ .name = "func_0807B520", .linkage = .strong });
        @export(&func_0807C1BC, .{ .name = "func_0807C1BC", .linkage = .strong });
        @export(&func_0807C208, .{ .name = "func_0807C208", .linkage = .strong });
        @export(&func_0807C254, .{ .name = "func_0807C254", .linkage = .strong });
        @export(&func_0807C2A0, .{ .name = "func_0807C2A0", .linkage = .strong });
        @export(&func_0807C2EC, .{ .name = "func_0807C2EC", .linkage = .strong });
        @export(&func_0807C338, .{ .name = "func_0807C338", .linkage = .strong });
        @export(&func_0807C384, .{ .name = "func_0807C384", .linkage = .strong });
        @export(&func_0807C4C4, .{ .name = "func_0807C4C4", .linkage = .strong });
        @export(&func_0807CB74, .{ .name = "func_0807CB74", .linkage = .strong });
        @export(&func_0807CBBC, .{ .name = "func_0807CBBC", .linkage = .strong });
        @export(&func_0807CC04, .{ .name = "func_0807CC04", .linkage = .strong });
        @export(&func_0807CC4C, .{ .name = "func_0807CC4C", .linkage = .strong });
        @export(&func_0807CC94, .{ .name = "func_0807CC94", .linkage = .strong });
        @export(&func_0807CCDC, .{ .name = "func_0807CCDC", .linkage = .strong });
        @export(&func_0807CD24, .{ .name = "func_0807CD24", .linkage = .strong });
        @export(&func_0807CE88, .{ .name = "func_0807CE88", .linkage = .strong });
        @export(&func_0807CF10, .{ .name = "func_0807CF10", .linkage = .strong });
    }
}

test "low_peel_9 exports are callable" {
    try std.testing.expect(@TypeOf(func_0805F150) == fn () callconv(.c) void);
    try std.testing.expect(@TypeOf(func_0807CF10) == fn () callconv(.c) void);
}
