//! Low-ROM (< 0x08080000) block-peeled wave 6 (61..120 reachable lines, first 208).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const bios = @import("bios.zig");
const campaign = @import("campaign.zig");
const clusters_low = @import("clusters_low.zig");
const clusters_low_2 = @import("clusters_low_2.zig");
const co = @import("co.zig");
const dma = @import("dma.zig");
const hw = @import("hw.zig");
const low_peel_1 = @import("low_peel_1.zig");
const low_peel_10 = @import("low_peel_10.zig");
const low_peel_12 = @import("low_peel_12.zig");
const low_peel_13 = @import("low_peel_13.zig");
const low_peel_14 = @import("low_peel_14.zig");
const low_peel_19 = @import("low_peel_19.zig");
const low_peel_2 = @import("low_peel_2.zig");
const low_peel_3 = @import("low_peel_3.zig");
const low_peel_4 = @import("low_peel_4.zig");
const low_peel_5 = @import("low_peel_5.zig");
const low_peel_7 = @import("low_peel_7.zig");
const low_peel_8 = @import("low_peel_8.zig");
const map = @import("map.zig");
const math = @import("math.zig");
const menu = @import("menu.zig");
const proc = @import("proc.zig");
const sound = @import("sound.zig");
const sprite_anim = @import("sprite_anim.zig");
const state = @import("state.zig");
const tail_low = @import("tail_low.zig");
const turn = @import("turn.zig");
const ui = @import("ui.zig");
const unit = @import("unit.zig");

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

pub fn func_0800028C() callconv(.c) void {
    if (!abi.enter(0x0800028C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[2] = abi.read32(0x080002D4);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x6);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x6, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1E);
            abi.write32(rt.r[1] +% 0xC, rt.r[0]);
            continue :blk 1;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[1] +% 0xC);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[1] +% 0xC, rt.r[0]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            if (!abi.call(func_08004BF4, 0x080002C1)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080002D8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            rt.r[1] = abi.read32(0x080002DC);
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(func_08018400, 0x080002CF)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_080002F4() callconv(.c) void {
    if (!abi.enter(0x080002F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x08000338);
            rt.r[2] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x6);
            rt.r[0] = rt.sext8(abi.read8(rt.r[2] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[2] +% 0x6, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            if (!abi.call(func_08003444, 0x0800030F)) return;
            continue :blk 1;
        },
        3 => {
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
            if (!hw.drawDispatchCall(0x0800032F)) return;
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
            if (!abi.call(func_080033CC, 0x08000333)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08000802() callconv(.c) void {
    if (!abi.enter(0x08000802)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x3);
            if (!abi.call(low_peel_1.func_080001FC, 0x08000813)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08000840);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[3]);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
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
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.write8(rt.r[0] +% 0x7, @truncate(rt.r[4]));
            continue :blk 7;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
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
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(low_peel_1.func_080001FC, 0x08000859)) return;
            continue :blk 10;
        },
        8 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x7, @truncate(rt.r[0]));
            continue :blk 7;
        },
        9 => {
            abi.fetches(8);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            rt.r[1] = abi.read32(0x08000870);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[2] +% 0x8, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x2);
            abi.write16(rt.r[2] +% 0xA, @truncate(rt.r[0]));
            continue :blk 6;
        },
        10 => {
            abi.fetches(3);
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_08000874() callconv(.c) void {
    if (!abi.enter(0x08000874)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x080008B4);
            rt.r[3] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x7);
            rt.r[0] = rt.sext8(abi.read8(rt.r[3] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.r[4] = abi.read16(rt.r[3] +% 0x24);
            abi.setRegNz(&rt.r[1], 0x8);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[1]));
            abi.setRegNz(&rt.r[2], 0xA);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[2]));
            if (!abi.call(low_peel_3.func_0800875C, 0x080008D3)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(21);
            rt.r[0] = abi.read32(0x080008B8);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xA);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[4] = abi.read32(0x080008BC);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[4], 0x8);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[4]));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read32(0x080008C0);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[4] = abi.read16(rt.r[3] +% 0x2A);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x65, true);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x65, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_080008E4() callconv(.c) void {
    if (!abi.enter(0x080008E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            if (!sound.playSfxCall(0x65, 0x080008ED)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08000920);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x7);
            rt.r[0] = rt.sext8(abi.read8(rt.r[3] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[2], 0x8);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[2]));
            abi.setRegNz(&rt.r[4], 0xA);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[4]));
            if (!abi.call(low_peel_3.func_0800875C, 0x0800093D)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08000924);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xA);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[4] = abi.read32(0x08000928);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(low_peel_10.func_08000948, 0x08000941)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
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
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_08000A74() callconv(.c) void {
    if (!abi.enter(0x08000A74)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x08000AB4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(clusters_low_2.func_0801F114, 0x08000A83)) return;
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
            abi.fetches(11);
            rt.r[0] = abi.read32(0x08000ABC);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08000AC0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            if (!abi.call(low_peel_4.func_0802BF70, 0x08000AAD)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x08000AB8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[4]));
            abi.write16(rt.r[0] +% 0x6, @truncate(rt.r[4]));
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[4]));
            abi.write16(rt.r[0] +% 0xA, @truncate(rt.r[4]));
            abi.write16(rt.r[0] +% 0xC, @truncate(rt.r[4]));
            abi.write16(rt.r[0] +% 0xE, @truncate(rt.r[4]));
            if (!abi.call(low_peel_10.func_08003938, 0x08000A9B)) return;
            continue :blk 2;
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

pub fn func_08000DAC() callconv(.c) void {
    if (!abi.enter(0x08000DAC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08000DD4);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[3] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[6] = abi.read32(0x08000DFC);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            rt.r[4] = abi.read32(0x08000E00);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_080011E4() callconv(.c) void {
    if (!abi.enter(0x080011E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x08001214);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[6] << 1);
            rt.r[3] = abi.read32(0x08001218);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[2] = abi.read32(0x0800121C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[4], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[7], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(func_080090B4, 0x0800120F)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_3.func_08008818, 0x0800122B)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            continue :blk 3;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.cpuSub(null, rt.r[4], 0x7, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0xD, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x13, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[7], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 7;
        },
        else => unreachable,
    }
}

pub fn func_08001924() callconv(.c) void {
    if (!abi.enter(0x08001924)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08001954);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x3F);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[4], 0x3F);
            rt.r[3] = abi.read32(0x08001988);
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x1F);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[4], 0x1F);
            rt.r[3] = abi.read32(0x08001958);
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.r[5] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.r[5] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x12, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 9;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0xD, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 10;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        10 => {
            abi.fetches(3);
            continue :blk 8;
        },
        else => unreachable,
    }
}

pub fn func_08002B50() callconv(.c) void {
    if (!abi.enter(0x08002B50)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08002BA8);
            rt.r[1] = abi.read32(0x08002BAC);
            abi.setRegNz(&rt.r[2], 0x8C);
            abi.setRegNz(&rt.r[2], rt.r[2] << 3);
            if (!dma.enqueueOrCopyAbiCall(0x08002B5F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08002BB0);
            rt.r[1] = abi.read32(0x08002BB4);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            if (!dma.enqueueOrCopyAbiCall(0x08002B6B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08002BB8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.r[2] = abi.read32(0x08002BBC);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08002BC4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x80);
            if (!dma.enqueueOrCopyAbiCall(0x08002B87)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.r[2] = abi.read32(0x08002BC0);
            continue :blk 3;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08002BC8);
            rt.r[1] = abi.read32(0x08002BCC);
            abi.setRegNz(&rt.r[2], 0x80);
            if (!dma.enqueueOrCopyAbiCall(0x08002B91)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08002BD0);
            rt.r[1] = abi.read32(0x08002BD4);
            abi.setRegNz(&rt.r[2], 0x40);
            if (!dma.enqueueOrCopyAbiCall(0x08002B9B)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08002BD8);
            rt.r[1] = abi.read32(0x08002BDC);
            abi.setRegNz(&rt.r[2], 0x40);
            if (!dma.enqueueOrCopyAbiCall(0x08002BA5)) return;
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

pub fn func_08002DEC() callconv(.c) void {
    if (!abi.enter(0x08002DEC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x4;
            rt.r[1] = abi.read32(0x08002E4C);
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[2], 0x4);
            if (!abi.call(low_peel_5.func_0807A8A0, 0x08002DFB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x9);
            abi.setRegNz(&rt.r[1], 0x2);
            abi.setRegNz(&rt.r[2], 0xB);
            abi.setRegNz(&rt.r[3], 0x11);
            if (!abi.call(low_peel_10.func_080197D8, 0x08002E07)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(low_peel_1.func_080117EC, 0x08002E0D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x08002E50);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x4, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(16);
            rt.r[1] = rt.r[13];
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            rt.r[1] = abi.read32(0x08002E54);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.r[2] = abi.read32(0x08002E58);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xC0);
            if (!dma.enqueueOrCopyAbiCall(0x08002E2F)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            ldmRegs(5, &.{ 1 });
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.r[0] = abi.read32(0x08002E5C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(0x08002E60);
            abi.setRegNz(&rt.r[2], 0x40);
            if (!dma.enqueueOrCopyAbiCall(0x08002E3F)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
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

pub fn func_08003332() callconv(.c) void {
    if (!abi.enter(0x08003332)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[5], 16));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x92, true);
            rt.r[3] = abi.read32(rt.r[13] +% 0x38);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[3], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            if (!math.cosDegCall(0x08003349)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8A, true);
            rt.r[2] = abi.read32(rt.r[13] +% 0x38);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[3]));
            if (!math.divSigned32Call(0x0800335D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = rt.r[10];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.r[1] = rt.r[9];
            rt.r[2] = rt.r[8];
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(sprite_anim.func_08014B54, 0x08003373)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(35);
            abi.setRegNz(&rt.r[3], 0xC0);
            abi.setRegNz(&rt.r[3], rt.r[3] << 2);
            rt.r[0] = rt.r[13];
            rt.r[0] +%= rt.r[10];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1C, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.r[4] = abi.read32(rt.r[13] +% 0x2C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[2] = abi.read32(0x080033C8);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = rt.r[13];
            rt.r[1] +%= rt.r[10];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x20, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            rt.r[4] = abi.read32(rt.r[13] +% 0x30);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[3]);
            rt.r[3] = rt.r[10];
            abi.setRegNz(&rt.r[2], rt.r[3] << 2);
            rt.r[2] +%= rt.r[13];
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xC, true);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 7);
            if (!hw.drawDispatchCall(0x080033B5)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            rt.r[13] +%= 0x3C;
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

pub fn func_080033CC() callconv(.c) void {
    if (!abi.enter(0x080033CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x8;
            rt.r[1] = abi.read32(0x0800343C);
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[2], 0x8);
            if (!abi.call(low_peel_5.func_0807A8A0, 0x080033E3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], 0xF);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[1], 0xC8);
            abi.setRegNz(&rt.r[1], rt.r[1] << 14);
            rt.r[10] = rt.r[1];
            rt.r[7] = rt.r[13];
            rt.r[2] = abi.read32(0x08003440);
            rt.r[9] = rt.r[2];
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read16(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[7], rt.r[7], 0x2, true);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[4], rt.r[4] | rt.r[1]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[6] << 2);
            rt.r[1] +%= rt.r[9];
            rt.r[5] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(low_peel_1.func_08001904, 0x08003413)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 28);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.r[1] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[1], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!hw.drawDispatchCall(0x08003425)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x11);
            rt.r[8] +%= rt.r[2];
            rt.cpuSub(null, rt.r[6], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08003402() callconv(.c) void {
    if (!abi.enter(0x08003402)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[6] << 2);
            rt.r[1] +%= rt.r[9];
            rt.r[5] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(low_peel_1.func_08001904, 0x08003413)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 28);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.r[1] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[1], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!hw.drawDispatchCall(0x08003425)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x11);
            rt.r[8] +%= rt.r[2];
            rt.cpuSub(null, rt.r[6], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            rt.r[0] = abi.read16(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[7], rt.r[7], 0x2, true);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[4], rt.r[4] | rt.r[1]);
            continue :blk 0;
        },
        5 => {
            abi.fetches(6);
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08003444() callconv(.c) void {
    if (!abi.enter(0x08003444)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x4;
            rt.r[1] = abi.read32(0x08003494);
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[2], 0x4);
            if (!abi.call(low_peel_5.func_0807A8A0, 0x08003453)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x08003498);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x4, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(17);
            rt.r[1] = rt.r[13];
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            rt.r[1] = abi.read32(0x0800349C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.r[2] = abi.read32(0x080034A0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xC0);
            if (!dma.enqueueOrCopyAbiCall(0x08003477)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            ldmRegs(5, &.{ 1 });
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.r[0] = abi.read32(0x080034A4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(0x080034A8);
            abi.setRegNz(&rt.r[2], 0x40);
            if (!dma.enqueueOrCopyAbiCall(0x08003487)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080035CC() callconv(.c) void {
    if (!abi.enter(0x080035CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[6] = abi.read32(0x08003624);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x3E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[4], 0xCE);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            rt.r[2] = abi.read32(0x08003628);
            abi.setRegNz(&rt.r[5], 0xD0);
            abi.setRegNz(&rt.r[5], rt.r[5] << 8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xE);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!hw.drawDispatchCall(0x080035EF)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x2);
            continue :blk 1;
        },
        3 => {
            abi.fetches(8);
            rt.r[2] = abi.read32(0x0800362C);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x18);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!hw.drawDispatchCall(0x080035FB)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x18, true);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x8);
            rt.r[2] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xE);
            if (!abi.call(low_peel_7.func_0802C11C, 0x0800360D)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xA);
            rt.r[2] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x18);
            if (!abi.call(low_peel_7.func_0802C11C, 0x0800361D)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08003630() callconv(.c) void {
    if (!abi.enter(0x08003630)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[1] = abi.read32(0x08003658);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[3] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[1] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xA);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[1] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x2);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x1, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[0], 0x3);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            continue :blk 4;
        },
        6 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x3E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], 0xD0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x20);
            continue :blk 9;
        },
        9 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.r[2] = abi.read32(0x080036A0);
            abi.setRegNz(&rt.r[3], 0xD0);
            abi.setRegNz(&rt.r[3], rt.r[3] << 8);
            if (!hw.drawDispatchCall(0x08003699)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(func_080035CC, 0x0800369D)) return;
            continue :blk 7;
        },
        else => unreachable,
    }
}

pub fn func_08003C70() callconv(.c) void {
    if (!abi.enter(0x08003C70)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[7], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08003CC8);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[7], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
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
            abi.fetches(9);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x1, true);
            rt.r[8] = rt.r[1];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.r[5] = abi.read32(0x08003CC8);
            abi.setRegNz(&rt.r[6], rt.r[7] << 1);
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            rt.r[7] = rt.r[8];
            continue :blk 1;
        },
        6 => {
            abi.fetches(16);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[2] = abi.read32(0x08003CCC);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[2] = abi.read32(0x08003CD0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(low_peel_10.func_08003B6C, 0x08003CA9)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08004554() callconv(.c) void {
    if (!abi.enter(0x08004554)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_10.func_08003CD4, 0x0800455B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[0] = abi.read32(0x08004584);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(10);
            rt.r[2] = rt.r[9];
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.r[0] +%= rt.r[13];
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[9] +%= rt.r[0];
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            continue :blk 0;
        },
        4 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[5], rt.r[6], 0x0, true);
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08004584);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(10);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x1, true);
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08004668() callconv(.c) void {
    if (!abi.enter(0x08004668)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x8;
            if (!abi.call(low_peel_10.func_08002D04, 0x08004671)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[4] = abi.read32(0x080046C0);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x7);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(12);
            rt.r[0] = abi.read32(0x080046C4);
            abi.setRegNz(&rt.r[1], 0x11);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            rt.r[1] = abi.read32(0x080046C8);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x9);
            abi.setRegNz(&rt.r[2], 0x2);
            abi.setRegNz(&rt.r[3], 0xB);
            if (!hw.fillTileRectCall(0x08004693)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(low_peel_1.func_08011824, 0x08004697)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_10.func_08002BE0, 0x0800469B)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(func_08002B50, 0x0800469F)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080046CC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x080046A7)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080046D0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08004B20() callconv(.c) void {
    if (!abi.enter(0x08004B20)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08004B3C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(func_0800537C, 0x08004B5D)) return;
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
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(3);
            continue :blk 6;
        },
        8 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(func_08005300, 0x08004B51)) return;
            continue :blk 11;
        },
        9 => {
            abi.fetches(3);
            continue :blk 6;
        },
        10 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(func_080053F8, 0x08004B69)) return;
            continue :blk 6;
        },
        11 => {
            abi.fetches(3);
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_08004B8C() callconv(.c) void {
    if (!abi.enter(0x08004B8C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x8;
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[5], 0x7);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(19);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[0], true);
            rt.r[6] = abi.read32(0x08004BE4);
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x3, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[1], rt.r[4] >> 16);
            abi.setRegNz(&rt.r[5], rt.r[5] << 16);
            abi.setRegNz(&rt.r[2], rt.r[5] >> 16);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0xBA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x9);
            if (!hw.fillTileRectCall(0x08004BBD)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[5], 0x5);
            continue :blk 1;
        },
        3 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[5], 16));
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[7], 0x0, true);
            if (!sprite_anim.spawnSpriteAnimCall(0x08004BD7)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!hw.markDisplayDirtyCall(0x08004BDB)) return;
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

pub fn func_08004BF4() callconv(.c) void {
    if (!abi.enter(0x08004BF4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x08004C2C);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_4.func_0803F0FC, 0x08004C01)) return;
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_4.func_0803F0FC, 0x08004C11)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_4.func_0803F0FC, 0x08004C21)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08004C8C() callconv(.c) void {
    if (!abi.enter(0x08004C8C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            rt.r[4] = abi.read32(0x08004CC4);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(proc.func_08019608, 0x08004CAB)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x10, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08004CC8);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(func_0801320C, 0x08004CB9)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x7);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08004CCC() callconv(.c) void {
    if (!abi.enter(0x08004CCC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            rt.r[4] = abi.read32(0x08004D04);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(proc.func_08019608, 0x08004CEB)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x10, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08004D08);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(func_0801320C, 0x08004CF9)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x7);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08004D0C() callconv(.c) void {
    if (!abi.enter(0x08004D0C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            rt.r[4] = abi.read32(0x08004D44);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(proc.func_08019608, 0x08004D2B)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write8(rt.r[1] +% 0x10, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08004D48);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(func_0801320C, 0x08004D39)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x7);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08005300() callconv(.c) void {
    if (!abi.enter(0x08005300)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.pushLr();
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[13] -%= 0x8;
            rt.r[1] = abi.read32(0x08005334);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(low_peel_4.func_0803F0FC, 0x0800530D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(campaign.func_0803F2BC, 0x08005319)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(campaign.func_0803F2BC, 0x08005341)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08005338);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xE);
            abi.setRegNz(&rt.r[2], 0x4);
            abi.setRegNz(&rt.r[3], 0xF);
            if (!hw.fillTileRectCall(0x0800532F)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08005370);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xE);
            abi.setRegNz(&rt.r[2], 0x4);
            abi.setRegNz(&rt.r[3], 0xF);
            if (!hw.fillTileRectCall(0x08005357)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            if (!hw.markDisplayDirtyCall(0x08005333)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0xE);
            abi.setRegNz(&rt.r[1], 0x4);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(low_peel_8.func_0803F1DC, 0x08005361)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(3);
            continue :blk 11;
        },
        10 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08005374);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08005378);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08005302() callconv(.c) void {
    if (!abi.enter(0x08005302)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[13] -%= 0x8;
            rt.r[1] = abi.read32(0x08005334);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(low_peel_4.func_0803F0FC, 0x0800530D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(campaign.func_0803F2BC, 0x08005319)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(campaign.func_0803F2BC, 0x08005341)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08005338);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xE);
            abi.setRegNz(&rt.r[2], 0x4);
            abi.setRegNz(&rt.r[3], 0xF);
            if (!hw.fillTileRectCall(0x0800532F)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08005370);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xE);
            abi.setRegNz(&rt.r[2], 0x4);
            abi.setRegNz(&rt.r[3], 0xF);
            if (!hw.fillTileRectCall(0x08005357)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            if (!hw.markDisplayDirtyCall(0x08005333)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0xE);
            abi.setRegNz(&rt.r[1], 0x4);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(low_peel_8.func_0803F1DC, 0x08005361)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(3);
            continue :blk 10;
        },
        9 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08005374);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08005378);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800537C() callconv(.c) void {
    if (!abi.enter(0x0800537C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[13] -%= 0x8;
            rt.r[1] = abi.read32(0x080053B0);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(low_peel_4.func_0803F0FC, 0x08005389)) return;
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
            abi.fetches(4);
            if (!abi.call(campaign.func_0803F2BC, 0x080053BD)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(campaign.func_0803F2BC, 0x08005395)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x080053EC);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xE);
            abi.setRegNz(&rt.r[2], 0x4);
            abi.setRegNz(&rt.r[3], 0xF);
            if (!hw.fillTileRectCall(0x080053D3)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x080053B4);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xE);
            abi.setRegNz(&rt.r[2], 0x4);
            abi.setRegNz(&rt.r[3], 0xF);
            if (!hw.fillTileRectCall(0x080053AB)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0xE);
            abi.setRegNz(&rt.r[1], 0x4);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(low_peel_8.func_0803F1DC, 0x080053DD)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            if (!hw.markDisplayDirtyCall(0x080053AF)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080053F0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x080053F4);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 10;
        },
        9 => {
            abi.fetches(3);
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080053F8() callconv(.c) void {
    if (!abi.enter(0x080053F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[13] -%= 0x8;
            rt.r[1] = abi.read32(0x0800542C);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(low_peel_4.func_0803F0FC, 0x08005405)) return;
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
            abi.fetches(4);
            if (!abi.call(campaign.func_0803F2BC, 0x08005439)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(campaign.func_0803F2BC, 0x08005411)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08005468);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xE);
            abi.setRegNz(&rt.r[2], 0x4);
            abi.setRegNz(&rt.r[3], 0xF);
            if (!hw.fillTileRectCall(0x0800544F)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08005430);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xE);
            abi.setRegNz(&rt.r[2], 0x4);
            abi.setRegNz(&rt.r[3], 0xF);
            if (!hw.fillTileRectCall(0x08005427)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0xE);
            abi.setRegNz(&rt.r[1], 0x4);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(low_peel_8.func_0803F1DC, 0x08005459)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            if (!hw.markDisplayDirtyCall(0x0800542B)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0800546C);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08005470);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 10;
        },
        9 => {
            abi.fetches(3);
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080056A0() callconv(.c) void {
    if (!abi.enter(0x080056A0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], 0x70);
            if (!abi.call(unit.func_0801B8D4, 0x080056AB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x080056C0);
            rt.r[0] = abi.read32(0x080056C4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x10);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
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
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x2);
            abi.setRegNz(&rt.r[2], 0x6);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(ui.func_080193C0, 0x080056D9)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_10.func_080055AC, 0x080056DD)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080056EC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080076A8() callconv(.c) void {
    if (!abi.enter(0x080076A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x080076D8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x3A);
            rt.r[2] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[3], 0x7);
            rt.r[3] = rt.sext8(abi.read8(rt.r[0] +% rt.r[3]));
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x3, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x9, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x4, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[1], rt.r[1], 0xA, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x36, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x38, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3, true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x080076F8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[4]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800775A() callconv(.c) void {
    if (!abi.enter(0x0800775A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0xA);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(17);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x6E, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[5] = rt.sext16(abi.read16(rt.r[1] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x9C);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 3));
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[0], true);
            rt.r[0] = abi.read32(0x0800778C);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[5], 0x9A);
            abi.setRegNz(&rt.r[5], rt.r[5] << 4);
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[5]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(22);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x6E, true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[1], 20));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x70, true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 20));
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] | rt.r[4]);
            rt.r[2] = abi.read32(0x08007838);
            abi.setRegNz(&rt.r[0], 0x64);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!hw.drawDispatchCall(0x08007825)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[5], rt.r[5] | rt.r[4]);
            rt.r[2] = abi.read32(0x0800783C);
            abi.setRegNz(&rt.r[0], 0x86);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!hw.drawDispatchCall(0x08007833)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08007890() callconv(.c) void {
    if (!abi.enter(0x08007890)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            if (!abi.call(low_peel_3.func_08008818, 0x0800789B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(16);
            rt.r[0] = abi.read32(0x080078D4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[5] << 1);
            rt.r[3] = abi.read32(0x080078D8);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[2] = abi.read32(0x080078DC);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x13, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x2A);
            if (!map.writeTileGridCall(0x080078C5)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x7);
            if (!map.readTileGridCall(0x080078CF)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_080078E0() callconv(.c) void {
    if (!abi.enter(0x080078E0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            if (!abi.call(low_peel_14.func_08007B08, 0x080078EB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x2A);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!map.writeTileGridCall(0x0800791F)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(0x08007934);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[6] << 1);
            rt.r[3] = abi.read32(0x08007938);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[2] = abi.read32(0x0800793C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x7, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 2;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x2A, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x7);
            if (!map.readTileGridCall(0x0800792D)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08007AA8() callconv(.c) void {
    if (!abi.enter(0x08007AA8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            if (!abi.call(menu.func_080012D0, 0x08007AB3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!map.writeTileGridCall(0x08007ABD)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08007AE4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x2, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(menu.func_080012D0, 0x08007AD3)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!map.writeTileGridCall(0x08007ADD)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08007BB6() callconv(.c) void {
    if (!abi.enter(0x08007BB6)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(0x08007BEC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[7] << 1);
            rt.r[3] = abi.read32(0x08007BF0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[2] = abi.read32(0x08007BF4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xD, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(func_080011E4, 0x08007BC1)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(low_peel_19.func_0800B12C, 0x08007BE7)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 1;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 9;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0xC, true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(low_peel_3.func_08008818, 0x08007C0F)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08007C38);
            abi.setRegNz(&rt.r[0], rt.r[6] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            continue :blk 9;
        },
        12 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08007C20);
            abi.setRegNz(&rt.r[0], rt.r[6] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            continue :blk 9;
        },
        else => unreachable,
    }
}

pub fn func_08007C3C() callconv(.c) void {
    if (!abi.enter(0x08007C3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            if (!map.writeTileGridCall(0x08007C49)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x2A, true);
            if (rt.CPU_Z) {
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.cpuSub(&rt.r[4], rt.r[6], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(func_08000DAC, 0x08007C5D)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(func_08007AA8, 0x08007C7B)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_14.func_08007CC4, 0x08007C83)) return;
            continue :blk 10;
        },
        8 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!map.writeTileGridCall(0x08007C6B)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_19.func_0800A6F8, 0x08007C73)) return;
            continue :blk 5;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_14.func_0800A100, 0x08007C8B)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08007C90() callconv(.c) void {
    if (!abi.enter(0x08007C90)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            if (!map.writeTileGridCall(0x08007C9B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuSub(&rt.r[6], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(func_08000DAC, 0x08007CA7)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(func_08007AA8, 0x08007CBD)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!map.writeTileGridCall(0x08007CB5)) return;
            continue :blk 3;
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

pub fn func_08008398() callconv(.c) void {
    if (!abi.enter(0x08008398)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_10.func_0800B038, 0x080083A1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(menu.func_0800C314, 0x080083AD)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_10.func_0800B5B0, 0x080083D5)) return;
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
            abi.fetches(3);
            continue :blk 7;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_10.func_0800C0DC, 0x080083B9)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(func_080087A4, 0x08008557)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!map.readTileGridCall(0x080083C3)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08008568);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6A, true);
            abi.setRegNz(&rt.r[1], 0x4B);
            continue :blk 11;
        },
        10 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(func_08007C3C, 0x080083CD)) return;
            continue :blk 3;
        },
        11 => {
            abi.fetches(3);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 12;
        },
        12 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08008708() callconv(.c) void {
    if (!abi.enter(0x08008708)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x08008740);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.r[6] = abi.read32(0x08008744);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x12, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x08008748);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(unit.func_0802AAF8, 0x0800873F)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(menu.func_0800856C, 0x08008753)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080087A4() callconv(.c) void {
    if (!abi.enter(0x080087A4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            if (!abi.call(low_peel_3.func_0800875C, 0x080087AF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[7], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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
            abi.fetches(34);
            rt.r[4] = abi.read32(0x08008804);
            rt.r[0] = abi.read32(0x08008808);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[6] << 1);
            rt.r[3] = abi.read32(0x0800880C);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[2] = abi.read32(0x08008810);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[2], 0x1F);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[1]);
            rt.r[3] = abi.read32(0x08008814);
            abi.setRegNz(&rt.r[1], 0x3F);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[7]);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x60, true);
            rt.r[3] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            if (!abi.call(func_08008708, 0x080087FF)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0800889C() callconv(.c) void {
    if (!abi.enter(0x0800889C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[1], rt.r[4], 0x1, true);
            if (!abi.call(low_peel_14.func_08009340, 0x080088AF)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_14.func_08009340, 0x080088BD)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(8);
            rt.r[7] = abi.read32(0x080088F4);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], rt.r[0] << 3);
            continue :blk 1;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 4;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_14.func_08009340, 0x080088D5)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 8;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_14.func_08009340, 0x080088EB)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 11;
        },
        else => unreachable,
    }
}

pub fn func_080088F8() callconv(.c) void {
    if (!abi.enter(0x080088F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[1], rt.r[4], 0x1, true);
            if (!abi.call(func_080011E4, 0x0800890B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], rt.r[0] << 3);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_080011E4, 0x08008919)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(8);
            rt.r[7] = abi.read32(0x08008950);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 6;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_080011E4, 0x08008931)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 9;
        },
        11 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(func_080011E4, 0x08008947)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        13 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 12;
        },
        else => unreachable,
    }
}

pub fn func_080088FE() callconv(.c) void {
    if (!abi.enter(0x080088FE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[1], rt.r[4], 0x1, true);
            if (!abi.call(func_080011E4, 0x0800890B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], rt.r[0] << 3);
            continue :blk 2;
        },
        4 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_080011E4, 0x08008919)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(8);
            rt.r[7] = abi.read32(0x08008950);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 5;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_080011E4, 0x08008931)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 8;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(func_080011E4, 0x08008947)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 11;
        },
        else => unreachable,
    }
}

pub fn func_080090B4() callconv(.c) void {
    if (!abi.enter(0x080090B4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(21);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x080090F4);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[4] = abi.read32(0x080090F8);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x080090FC);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0xFC, true);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x8E);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080092E4() callconv(.c) void {
    if (!abi.enter(0x080092E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = abi.read32(0x08009314);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[5] << 1);
            rt.r[6] = abi.read32(0x08009318);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[2] = abi.read32(0x0800931C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[3], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0xD, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(3);
            continue :blk 3;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(func_080090B4, 0x08009335)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x13, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        9 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_080096F4() callconv(.c) void {
    if (!abi.enter(0x080096F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x0800972C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[4] << 1);
            rt.r[5] = abi.read32(0x08009730);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[2] = abi.read32(0x08009734);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x2, true);
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
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_080090B4, 0x0800971F)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0800AA34() callconv(.c) void {
    if (!abi.enter(0x0800AA34)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0800AA80);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[6], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x3);
            if (!abi.call(func_08000DAC, 0x0800AA49)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x3);
            if (!abi.call(func_08000DAC, 0x0800AA6D)) return;
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
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_14.func_0800AB58, 0x0800AA55)) return;
            continue :blk 1;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_14.func_0800AB58, 0x0800AA79)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0800AA84() callconv(.c) void {
    if (!abi.enter(0x0800AA84)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            if (!abi.call(low_peel_3.func_0800128C, 0x0800AA8F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x3);
            if (!map.readTileGridCall(0x0800AAA7)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!map.readTileGridCall(0x0800AA9D)) return;
            continue :blk 2;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_14.func_0800AB58, 0x0800AAAF)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_14.func_0800A100, 0x0800AAB7)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_19.func_0800A6F8, 0x0800AABF)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_14.func_08007CC4, 0x0800AAC7)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_10.func_0800B9DC, 0x0800AACF)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_19.func_0800E75C, 0x0800AAD7)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800AD0C() callconv(.c) void {
    if (!abi.enter(0x0800AD0C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x0800AD34);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[4] = abi.read32(0x0800AD38);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x0800AD3C);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
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
            rt.cpuSub(null, rt.r[0], 0x20, true);
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
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x22, true);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 3;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0800B0D0() callconv(.c) void {
    if (!abi.enter(0x0800B0D0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[1], rt.r[4], 0x1, true);
            if (!abi.call(low_peel_3.func_0800B000, 0x0800B0E3)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_3.func_0800B000, 0x0800B0F1)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(8);
            rt.r[7] = abi.read32(0x0800B128);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], rt.r[0] << 3);
            continue :blk 1;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 4;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_3.func_0800B000, 0x0800B109)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 8;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_3.func_0800B000, 0x0800B11F)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 11;
        },
        else => unreachable,
    }
}

pub fn func_0800C044() callconv(.c) void {
    if (!abi.enter(0x0800C044)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x0, true);
            rt.r[0] = abi.read32(0x0800C0C4);
            rt.r[12] = rt.r[0];
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x12);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x5B, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
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
            abi.fetches(22);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0800C0C8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[6] << 1);
            rt.r[4] = abi.read32(0x0800C0CC);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[2] = abi.read32(0x0800C0D0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            rt.r[2] = abi.read32(0x0800C0D4);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[7]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            continue :blk 3;
        },
        3 => {
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
        else => unreachable,
    }
}

pub fn func_0800C1BC() callconv(.c) void {
    if (!abi.enter(0x0800C1BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuSub(null, rt.r[0], 0x48, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x48, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(11);
            rt.r[5] = abi.read32(0x0800C22C);
            rt.r[3] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x17, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[0] = rt.sext8(abi.read8(rt.r[2] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x28, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x68, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        6 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1B, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 12;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        8 => {
            abi.fetches(3);
            continue :blk 7;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 3;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x88, true);
            if (rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        11 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], 0x2);
            continue :blk 3;
        },
        12 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[0] = rt.sext8(abi.read8(rt.r[2] +% rt.r[0]));
            abi.write32(rt.r[6] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1B, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 7;
        },
        13 => {
            abi.fetches(3);
            continue :blk 7;
        },
        14 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0800C230() callconv(.c) void {
    if (!abi.enter(0x0800C230)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x48, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[3], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x48, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0800C274);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x17, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1B, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x28, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x68, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(3);
            continue :blk 6;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 3;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x88, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[3], 0x2);
            continue :blk 3;
        },
        11 => {
            abi.fetches(3);
            continue :blk 6;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[3], 0x3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0800C278() callconv(.c) void {
    if (!abi.enter(0x0800C278)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 14 });
            rt.cpuSub(null, rt.r[0], 0x48, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x48, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(16);
            rt.r[3] = abi.read32(0x0800C2C4);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x17, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[2], 0xFF);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1B, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[1]);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x28, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x68, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(3);
            continue :blk 6;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 3;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x88, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x2);
            continue :blk 3;
        },
        11 => {
            abi.fetches(3);
            continue :blk 6;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0800C374() callconv(.c) void {
    if (!abi.enter(0x0800C374)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = abi.read32(0x0800C3A8);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xB6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[4], rt.r[1], rt.r[0], true);
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            continue :blk 5;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800E208() callconv(.c) void {
    if (!abi.enter(0x0800E208)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[3] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[3], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x86, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            low_peel_1.func_0800E38E(); return;
        },
        2 => {
            abi.fetches(12);
            rt.cpuSub(&rt.r[0], rt.r[3], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x86, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            low_peel_1.func_0800E38E(); return;
        },
        4 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x86, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            low_peel_1.func_0800E38E(); return;
        },
        6 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x86, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            low_peel_1.func_0800E38E(); return;
        },
        8 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[5], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            if (!map.updateTileOverlayCall(0x0800E26B)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            low_peel_1.func_0800E38E(); return;
        },
        else => unreachable,
    }
}

pub fn func_0800E5B8() callconv(.c) void {
    if (!abi.enter(0x0800E5B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x0800E614);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[6] << 1);
            rt.r[3] = abi.read32(0x0800E618);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[2] = abi.read32(0x0800E61C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x86, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
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
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x25);
            if (!menu.refreshTileCellCall(0x0800E5ED)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[5], rt.r[6], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x65);
            if (!menu.refreshTileCellCall(0x0800E5F9)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x27);
            if (!map.writeTileGridCall(0x0800E605)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x67);
            if (!map.writeTileGridCall(0x0800E60F)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800E620() callconv(.c) void {
    if (!abi.enter(0x0800E620)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x0800E68C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[7] << 1);
            rt.r[3] = abi.read32(0x0800E690);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[2] = abi.read32(0x0800E694);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x4, true);
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
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x25);
            if (!menu.refreshTileCellCall(0x0800E64D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[6], rt.r[7], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x45);
            if (!menu.refreshTileCellCall(0x0800E659)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[5], rt.r[7], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x65);
            if (!menu.refreshTileCellCall(0x0800E665)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x27);
            if (!map.writeTileGridCall(0x0800E671)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x47);
            if (!map.writeTileGridCall(0x0800E67B)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x67);
            if (!map.writeTileGridCall(0x0800E685)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800E69C() callconv(.c) void {
    if (!abi.enter(0x0800E69C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 7 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x0800E72C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[7] << 1);
            rt.r[3] = abi.read32(0x0800E730);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[2] = abi.read32(0x0800E734);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x4, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x25);
            if (!menu.refreshTileCellCall(0x0800E6C9)) return;
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
            abi.fetches(8);
            rt.cpuAdd(&rt.r[6], rt.r[7], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x45);
            if (!menu.refreshTileCellCall(0x0800E6D5)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[3], rt.r[7], 0x2, true);
            rt.r[8] = rt.r[3];
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.r[1] = rt.r[8];
            abi.setRegNz(&rt.r[2], 0x65);
            if (!menu.refreshTileCellCall(0x0800E6E3)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[5], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x26);
            if (!map.writeTileGridCall(0x0800E6EF)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x27);
            if (!map.writeTileGridCall(0x0800E6FB)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x46);
            if (!map.writeTileGridCall(0x0800E705)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x47);
            if (!map.writeTileGridCall(0x0800E70F)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.r[1] = rt.r[8];
            abi.setRegNz(&rt.r[2], 0x66);
            if (!map.writeTileGridCall(0x0800E719)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.r[1] = rt.r[8];
            abi.setRegNz(&rt.r[2], 0x67);
            if (!map.writeTileGridCall(0x0800E723)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0800EA02() callconv(.c) void {
    if (!abi.enter(0x0800EA02)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[4] = rt.r[8];
            rt.cpuSub(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x87);
            if (!menu.refreshTileCellCall(0x0800EA11)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[6], rt.r[7], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x25);
            if (!menu.refreshTileCellCall(0x0800EA1D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[5], rt.r[7], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x27);
            if (!map.writeTileGridCall(0x0800EA29)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.r[1] = rt.r[9];
            abi.setRegNz(&rt.r[2], 0x87);
            if (!menu.refreshTileCellCall(0x0800EA33)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.r[1] = rt.r[9];
            abi.setRegNz(&rt.r[2], 0x65);
            if (!menu.refreshTileCellCall(0x0800EA3D)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.r[1] = rt.r[9];
            abi.setRegNz(&rt.r[2], 0x67);
            if (!map.writeTileGridCall(0x0800EA47)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.r[1] = rt.r[8];
            abi.setRegNz(&rt.r[2], 0x87);
            if (!menu.refreshTileCellCall(0x0800EA51)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.r[1] = rt.r[8];
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x87);
            if (!menu.refreshTileCellCall(0x0800ED7D)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.r[1] = rt.r[8];
            if (!abi.call(low_peel_3.func_0800C9D4, 0x0800EE05)) return;
            continue :blk 11;
        },
        11 => {
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

pub fn func_0800EE54() callconv(.c) void {
    if (!abi.enter(0x0800EE54)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x0800EE94);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[4] = abi.read32(0x0800EE98);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[2] = abi.read32(0x0800EE9C);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[4] = abi.read32(0x0800EEA0);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuSub(null, rt.r[1], 0x5, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0xC, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x13, true);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800EEA4() callconv(.c) void {
    if (!abi.enter(0x0800EEA4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x0800EEE4);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[4] = abi.read32(0x0800EEE8);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[2] = abi.read32(0x0800EEEC);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[4] = abi.read32(0x0800EEF0);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuSub(null, rt.r[2], 0x5, true);
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
            rt.cpuSub(null, rt.r[2], 0xC, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
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
            rt.cpuSub(null, rt.r[1], 0x16, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x36, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800EEF4() callconv(.c) void {
    if (!abi.enter(0x0800EEF4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[1], rt.r[4], 0x1, true);
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            continue :blk 6;
        },
        4 => {
            abi.fetches(8);
            rt.r[7] = abi.read32(0x0800EF50);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(func_0800EEA4, 0x0800EF07)) return;
            continue :blk 9;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(func_0800EE54, 0x0800EF15)) return;
            continue :blk 10;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_0800EE54, 0x0800EF2D)) return;
            continue :blk 11;
        },
        8 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        9 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], rt.r[0] << 7);
            continue :blk 1;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 4;
        },
        11 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 8;
        },
        12 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(func_0800EEA4, 0x0800EF43)) return;
            continue :blk 14;
        },
        13 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        14 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 13;
        },
        else => unreachable,
    }
}

pub fn func_0800EF02() callconv(.c) void {
    if (!abi.enter(0x0800EF02)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            if (!abi.call(func_0800EEA4, 0x0800EF07)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], rt.r[0] << 7);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(8);
            rt.r[7] = abi.read32(0x0800EF50);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(func_0800EE54, 0x0800EF15)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_0800EE54, 0x0800EF2D)) return;
            continue :blk 9;
        },
        7 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 4;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 7;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(func_0800EEA4, 0x0800EF43)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        12 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 11;
        },
        else => unreachable,
    }
}

pub fn func_0800EF10() callconv(.c) void {
    if (!abi.enter(0x0800EF10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            if (!abi.call(func_0800EE54, 0x0800EF15)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.r[7] = abi.read32(0x0800EF50);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_0800EE54, 0x0800EF2D)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 4;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(func_0800EEA4, 0x0800EF43)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            continue :blk 7;
        },
        else => unreachable,
    }
}

pub fn func_0800F016() callconv(.c) void {
    if (!abi.enter(0x0800F016)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
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
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0xC);
            if (!abi.call(func_08000DAC, 0x0800F027)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_10.func_08008E28, 0x0800F033)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 3;
        },
        5 => {
            abi.fetches(3);
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x5);
            if (!map.readTileGridCall(0x0800F03F)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_10.func_0800EF54, 0x0800F047)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!map.writeTileGridCall(0x0800F051)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(menu.func_080012D0, 0x0800F059)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!map.writeTileGridCall(0x0800F063)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_14.func_0800A100, 0x0800F06B)) return;
            continue :blk 13;
        },
        13 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_19.func_0800A6F8, 0x0800F073)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_14.func_08007CC4, 0x0800F07B)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_10.func_0800B9DC, 0x0800F083)) return;
            continue :blk 16;
        },
        16 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_19.func_0800E75C, 0x0800F08B)) return;
            continue :blk 7;
        },
        else => unreachable,
    }
}

pub fn func_0800F0CC() callconv(.c) void {
    if (!abi.enter(0x0800F0CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[4], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 15);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[0], true);
            rt.r[6] = abi.read32(0x0800F104);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!math.modUnsigned32Call(0x0800F0E7)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            rt.r[1] = abi.read16(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[5], rt.r[5], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(low_peel_13.func_0807B634, 0x0800F0F7)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
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

pub fn func_0800F108() callconv(.c) void {
    if (!abi.enter(0x0800F108)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 11);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
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
            rt.r[1] = abi.read32(0x0800F13C);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x20, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x40, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.r[4] = abi.read16(rt.r[1] +% 0x2);
            rt.r[5] = abi.read32(0x0800F140);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[5], true);
            rt.r[4] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            continue :blk 8;
        },
        7 => {
            abi.fetches(7);
            rt.r[5] = abi.read16(rt.r[1] +% 0x0);
            rt.r[4] = abi.read32(0x0800F160);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[4], true);
            rt.r[5] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800F1D8() callconv(.c) void {
    if (!abi.enter(0x0800F1D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.r[1] = abi.read32(0x0800F1F0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0800F1F4);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(func_08013248, 0x0800F1ED)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(hw.func_0800F170, 0x0800F201)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 6;
        },
        5 => {
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

pub fn func_0800F1F4() callconv(.c) void {
    if (!abi.enter(0x0800F1F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x4, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(hw.func_0800F170, 0x0800F201)) return;
            continue :blk 4;
        },
        4 => {
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

pub fn func_0800F24C() callconv(.c) void {
    if (!abi.enter(0x0800F24C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[5] = abi.read32(0x0800F264);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1F, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(25);
            rt.r[4] = abi.read32(0x0800F2B8);
            rt.r[3] = abi.read32(0x0800F2BC);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[6] = abi.read16(rt.r[0] +% 0x20);
            rt.r[2] = abi.read16(rt.r[0] +% 0x1E);
            rt.cpuAdd(&rt.r[1], rt.r[6], rt.r[2], true);
            abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[6]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            rt.r[0] = abi.read32(0x0800F2C0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0800F268);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(func_08013248, 0x0800F261)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0x20, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x20);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800F2C4() callconv(.c) void {
    if (!abi.enter(0x0800F2C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0800F2DC);
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
            if (!abi.call(hw.func_0800F170, 0x0800F2ED)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0800F2E0);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(func_08013248, 0x0800F2D9)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x0800F328);
            abi.setRegNz(&rt.r[0], 0xC0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0800F32C);
            abi.setRegNz(&rt.r[0], 0x1F);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[3] = abi.read32(0x0800F330);
            rt.r[2] = abi.read32(0x0800F334);
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 6;
        },
        5 => {
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

pub fn func_0800F338() callconv(.c) void {
    if (!abi.enter(0x0800F338)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[4] = abi.read32(0x0800F398);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(24);
            rt.r[3] = abi.read32(0x0800F3A0);
            rt.r[2] = abi.read32(0x0800F39C);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[5]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[6] = abi.read16(rt.r[0] +% 0x20);
            rt.r[5] = abi.read16(rt.r[0] +% 0x1E);
            rt.cpuSub(&rt.r[1], rt.r[6], rt.r[5], true);
            abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[6]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[5], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[5]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0800F39C);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(func_08013248, 0x0800F34D)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[6]));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x20);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800F50C() callconv(.c) void {
    if (!abi.enter(0x0800F50C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x0800F520);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0800F550);
            rt.r[1] = abi.read32(0x0800F554);
            abi.setRegNz(&rt.r[4], 0xA0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[3] +% 0x1E, @truncate(rt.r[0]));
            if (!abi.call(low_peel_3.func_0800F490, 0x0800F541)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            if (!abi.call(func_080132D8, 0x0800F51F)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(low_peel_1.func_0800F4E4, 0x0800F545)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0800F558);
            if (!abi.call(hw.func_08010B28, 0x0800F54B)) return;
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

pub fn func_0800F58C() callconv(.c) void {
    if (!abi.enter(0x0800F58C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(0x0800F5C0);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.r[1] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[3], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[3]));
            abi.setRegNz(&rt.r[3], 0xA0);
            abi.setRegNz(&rt.r[3], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[1] = abi.read32(0x0800F5DC);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            if (!abi.call(low_peel_3.func_0800F490, 0x0800F5B5)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(3);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0800F5E0);
            if (!abi.call(low_peel_3.func_0800FBEC, 0x0800F5D7)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_1.func_0800F4E4, 0x0800F5B9)) return;
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
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[4] +% 0x8, rt.r[0]);
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_0800F754() callconv(.c) void {
    if (!abi.enter(0x0800F754)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x0800F798);
            if (!proc.allocProcSlotCall(0x0800F75D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
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
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0800F79C);
            if (!proc.allocProcSlotCall(0x0800F76F)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0800F7A0);
            if (!proc.allocProcSlotCall(0x0800F77D)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[5], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0800F7A4);
            if (!proc.allocProcSlotCall(0x0800F78B)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0800F8B0() callconv(.c) void {
    if (!abi.enter(0x0800F8B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.r[2] >> 16);
            rt.r[3] = abi.read32(0x0800F8FC);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x80, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            continue :blk 3;
        },
        2 => {
            abi.fetches(22);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.r[0] = abi.read32(0x0800F900);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read32(0x0800F904);
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            rt.r[4] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[0] = abi.read32(0x0800F908);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.r[4] = abi.read16(rt.r[2] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x4);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[6], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800FADC() callconv(.c) void {
    if (!abi.enter(0x0800FADC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
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
            if (!abi.call(low_peel_10.func_0800F90C, 0x0800FAF7)) return;
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
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800FB0C() callconv(.c) void {
    if (!abi.enter(0x0800FB0C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0xF);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[5]);
            rt.cpuSub(null, rt.r[2], 0x9, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[1], 0xF4);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(func_0800F8B0, 0x0800FB31)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0800FB54);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(func_0800F8B0, 0x0800FB3F)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x8, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[5] >> 4);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0800FB58() callconv(.c) void {
    if (!abi.enter(0x0800FB58)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!math.modUnsigned32Call(0x0800FB6D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0xF4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(func_0800F8B0, 0x0800FB81)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x8, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(low_peel_13.func_0807B634, 0x0800FB91)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
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

pub fn func_0800FC18() callconv(.c) void {
    if (!abi.enter(0x0800FC18)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[1] = abi.read32(0x0800FC50);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(clusters_low_2.func_0800FBC4, 0x0800FC49)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.r[6] = abi.read32(0x0800FC54);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            if (!abi.call(tail_low.func_0807B44C, 0x0800FC35)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0800FE64() callconv(.c) void {
    if (!abi.enter(0x0800FE64)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[3] = abi.read32(0x0800FEBC);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x30, true);
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
            abi.fetches(38);
            rt.r[2] = abi.read32(0x0800FEC0);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[5]);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[1], 0x3);
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

pub fn func_0800FED0() callconv(.c) void {
    if (!abi.enter(0x0800FED0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[3] = abi.read32(0x0800FF28);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x30, true);
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
            abi.fetches(15);
            rt.r[2] = abi.read32(0x0800FF2C);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.r[1] = abi.read16(rt.r[0] +% 0x8);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[5]));
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            continue :blk 7;
        },
        7 => {
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
        else => unreachable,
    }
}

pub fn func_0800FF3C() callconv(.c) void {
    if (!abi.enter(0x0800FF3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[3] = abi.read32(0x0800FF94);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x30, true);
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
            abi.fetches(38);
            rt.r[2] = abi.read32(0x0800FF98);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x8);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[5]));
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[1], 0x5);
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

pub fn func_08010044() callconv(.c) void {
    if (!abi.enter(0x08010044)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.r[2] >> 16);
            rt.r[3] = abi.read32(0x080100B0);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x30, true);
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
            abi.fetches(47);
            rt.r[2] = abi.read32(0x080100B4);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[5]);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
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
            abi.setRegNz(&rt.r[1], 0x1);
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
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_080100C4() callconv(.c) void {
    if (!abi.enter(0x080100C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.r[2] >> 16);
            rt.r[3] = abi.read32(0x08010130);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x30, true);
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
            abi.fetches(27);
            rt.r[2] = abi.read32(0x08010134);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[5]);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
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
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_080102F8() callconv(.c) void {
    if (!abi.enter(0x080102F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.r[0] = abi.read32(0x08010364);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(func_0800FB0C, 0x0801030F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[8] = rt.r[0];
            rt.r[5] = abi.read32(0x08010368);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[7], 0x80);
            abi.setRegNz(&rt.r[7], rt.r[7] << 12);
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[4], rt.r[7] >> 16);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_0800FB0C, 0x08010327)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[2] = abi.read32(rt.r[5] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x84);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_0800FB0C, 0x08010331)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(12);
            rt.r[1] = abi.read16(rt.r[6] +% 0x8);
            rt.r[0] = abi.read8(rt.r[6] +% 0xA);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[0]);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            abi.setRegNz(&rt.r[0], 0x98);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_0800FB0C, 0x08010345)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0xC, true);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0xC, true);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            rt.cpuAdd(&rt.r[7], rt.r[7], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[8] +%= rt.r[0];
            rt.r[0] = rt.r[8];
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
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

pub fn func_080103C0() callconv(.c) void {
    if (!abi.enter(0x080103C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[0] = abi.read32(0x0801040C);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x08010410);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] ^ rt.r[1]);
            rt.r[6] = abi.read32(0x08010414);
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[3]));
            rt.r[1] = abi.read32(0x08010418);
            rt.r[2] = abi.read32(0x0801041C);
            rt.r[4] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & ~rt.r[4]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[5] = abi.read32(0x08010420);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0801043C);
            rt.r[1] = abi.read32(0x08010440);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x08010424);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(0x08010428);
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08010574() callconv(.c) void {
    if (!abi.enter(0x08010574)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(73);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 19);
            rt.r[0] = abi.read32(0x08010644);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.r[0] = abi.read32(0x08010648);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.r[0] = abi.read32(0x0801064C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[0] = abi.read32(0x08010650);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[0] = abi.read32(0x08010654);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[0] = abi.read32(0x08010658);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[0] = abi.read32(0x0801065C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[0] = abi.read32(0x08010660);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[0] = abi.read32(0x08010664);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[0] = abi.read32(0x08010668);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2E, true);
            rt.r[0] = abi.read32(0x0801066C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[1], rt.r[1], 0x44, true);
            rt.r[0] = abi.read32(0x08010670);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[0] = abi.read32(0x08010674);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[0] = abi.read32(0x08010678);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[0] = abi.read32(0x0801067C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.r[0] = abi.read32(0x08010680);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[3] = abi.read32(0x08010684);
            rt.r[2] = abi.read32(0x08010688);
            rt.r[0] = abi.read32(0x0801068C);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 8);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            continue :blk 1;
        },
        1 => {
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
        },
        else => unreachable,
    }
}

pub fn func_08010974() callconv(.c) void {
    if (!abi.enter(0x08010974)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_08010574, 0x0801097B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(low_peel_10.func_080106A4, 0x0801097F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(44);
            rt.r[1] = abi.read32(0x080109D4);
            rt.r[0] = abi.read32(0x080109D8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[0] = abi.read32(0x080109DC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3, true);
            rt.r[0] = abi.read32(0x080109E0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[0] = abi.read32(0x080109E4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[1], rt.r[1], 0x3, true);
            rt.r[0] = abi.read32(0x080109E8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[0] = abi.read32(0x080109EC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3, true);
            rt.r[0] = abi.read32(0x080109F0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[0] = abi.read32(0x080109F4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[0] = abi.read32(0x080109F8);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[0] = abi.read32(0x080109FC);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_08010C18() callconv(.c) void {
    if (!abi.enter(0x08010C18)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(22);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(rt.r[13] +% 0x14);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[12] = rt.r[0];
            rt.r[6] = abi.read8(rt.r[5] +% 0x0);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 8);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 15);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[2], true);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 10);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x2, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[7], true);
            if (rt.CPU_C) {
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
            rt.r[0] +%= rt.r[12];
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
            rt.cpuSub(null, rt.r[1], rt.r[7], true);
            if (!rt.CPU_C) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080111A8() callconv(.c) void {
    if (!abi.enter(0x080111A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[3], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], 0x30);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x30, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], 0xC0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0xC0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x30);
            abi.setRegNz(&rt.r[1], rt.r[1] ^ rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            continue :blk 1;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xC0);
            abi.setRegNz(&rt.r[0], rt.r[0] ^ rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            continue :blk 4;
        },
        4 => {
            abi.fetches(12);
            rt.r[1] = abi.read16(rt.r[2] +% 0x8);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[1]));
            abi.write16(rt.r[2] +% 0x8, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & ~rt.r[1]);
            abi.write16(rt.r[2] +% 0xA, @truncate(rt.r[0]));
            abi.write16(rt.r[2] +% 0xC, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08011228);
            continue :blk 8;
        },
        7 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[2] +% 0x10);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0x10, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        8 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write16(rt.r[2] +% 0x10, @truncate(rt.r[0]));
            continue :blk 9;
        },
        9 => {
            abi.fetches(13);
            rt.r[0] = abi.read16(rt.r[2] +% 0x8);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0xC);
            abi.write16(rt.r[2] +% 0x4, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0xA);
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0xE);
            abi.write16(rt.r[2] +% 0x6, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        10 => {
            abi.fetches(5);
            abi.write16(rt.r[2] +% 0xA, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(0x08011208);
            continue :blk 8;
        },
        else => unreachable,
    }
}

pub fn func_080114B0() callconv(.c) void {
    if (!abi.enter(0x080114B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[9] = rt.r[0];
            abi.setRegNz(&rt.r[1], 0x1F);
            rt.r[0] = abi.read32(0x08011530);
            rt.r[10] = rt.r[0];
            rt.r[2] = abi.read32(0x08011534);
            rt.r[8] = rt.r[2];
            rt.r[5] = abi.read32(0x08011538);
            abi.setRegNz(&rt.r[6], 0x1F);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.r[7] = rt.r[10];
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[7], true);
            rt.r[2] = rt.r[9];
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[7], rt.r[1] << 4);
            abi.write32(rt.r[13] +% 0x0, rt.r[7]);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[12] = rt.r[1];
            continue :blk 2;
        },
        2 => {
            abi.fetches(30);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[3], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[5], true);
            rt.r[3] +%= rt.r[8];
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.r[7] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[7]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[5], true);
            rt.r[7] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 5);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] >> 10);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0xF, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[1] = rt.r[12];
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(10);
            rt.r[13] +%= 0x4;
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

pub fn func_0801153C() callconv(.c) void {
    if (!abi.enter(0x0801153C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[9] = rt.r[0];
            abi.setRegNz(&rt.r[1], 0x1F);
            rt.r[0] = abi.read32(0x080115B8);
            rt.r[10] = rt.r[0];
            rt.r[2] = abi.read32(0x080115BC);
            rt.r[8] = rt.r[2];
            rt.r[5] = abi.read32(0x080115C0);
            abi.setRegNz(&rt.r[6], 0x1F);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.r[7] = rt.r[10];
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[7], true);
            rt.r[2] = rt.r[9];
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[7], rt.r[1] << 4);
            abi.write32(rt.r[13] +% 0x0, rt.r[7]);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[12] = rt.r[1];
            continue :blk 2;
        },
        2 => {
            abi.fetches(27);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[3], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[5], true);
            rt.r[3] +%= rt.r[8];
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.r[7] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[7]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[5], true);
            rt.r[7] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 5);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] >> 10);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0xF, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[1] = rt.r[12];
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(10);
            rt.r[13] +%= 0x4;
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

pub fn func_080115C4() callconv(.c) void {
    if (!abi.enter(0x080115C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[2] = abi.read32(0x08011630);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = abi.read32(0x08011634);
            rt.r[12] = rt.r[2];
            rt.r[6] = abi.read32(0x08011638);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[5], 0x1F);
            continue :blk 1;
        },
        1 => {
            abi.fetches(35);
            abi.setRegNz(&rt.r[3], rt.r[1] << 24);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[3], 24));
            rt.r[7] = rt.r[8];
            rt.cpuAdd(&rt.r[2], rt.r[7], rt.r[3], true);
            abi.setRegNz(&rt.r[4], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[6], true);
            rt.r[4] +%= rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.r[7] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[7]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.r[7] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 5);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[6], true);
            rt.r[4] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] >> 10);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 24);
            abi.setRegNz(&rt.r[1], rt.r[3] >> 24);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[3], 24));
            rt.cpuSub(null, rt.r[3], 0xF, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
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

pub fn func_08011660() callconv(.c) void {
    if (!abi.enter(0x08011660)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[2] = abi.read32(0x080116CC);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = abi.read32(0x080116D0);
            rt.r[12] = rt.r[2];
            rt.r[6] = abi.read32(0x080116D4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[5], 0x1F);
            continue :blk 1;
        },
        1 => {
            abi.fetches(35);
            abi.setRegNz(&rt.r[3], rt.r[1] << 24);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[3], 24));
            rt.r[7] = rt.r[8];
            rt.cpuAdd(&rt.r[2], rt.r[7], rt.r[3], true);
            abi.setRegNz(&rt.r[4], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[6], true);
            rt.r[4] +%= rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.r[7] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[7]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.r[7] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 5);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[6], true);
            rt.r[4] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] >> 10);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 24);
            abi.setRegNz(&rt.r[1], rt.r[3] >> 24);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[3], 24));
            rt.cpuSub(null, rt.r[3], 0xF, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
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

pub fn func_08012480() callconv(.c) void {
    if (!abi.enter(0x08012480)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x080124C8);
            if (!proc.allocProcSlotCall(0x08012489)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[5], 0x1);
            rt.cpuSub(&rt.r[5], 0, rt.r[5], true);
            rt.r[0] = ~rt.r[0]; rt.updateNz(rt.r[0]);
            rt.cpuSub(&rt.r[1], 0, rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 31);
            rt.r[0] = abi.read32(0x080124CC);
            if (!proc.allocProcSlotCall(0x0801249F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080124D0);
            if (!proc.allocProcSlotCall(0x080124AF)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801272C() callconv(.c) void {
    if (!abi.enter(0x0801272C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x08012784);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(sprite_anim.func_0801256C, 0x0801273F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08012788);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(sprite_anim.func_0801256C, 0x0801274D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[6], 0xA4);
            abi.setRegNz(&rt.r[6], rt.r[6] << 16);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[6] >> 16);
            if (!abi.call(low_peel_4.func_0803F0A8, 0x0801275B)) return;
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
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[4] << 5);
            rt.r[1] = abi.read32(0x0801278C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            if (!abi.call(sprite_anim.func_0801253C, 0x0801276B)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 9);
            rt.cpuAdd(&rt.r[6], rt.r[6], rt.r[0], true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0xB, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08012790);
            if (!abi.call(sprite_anim.func_0801253C, 0x0801277D)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08012B04() callconv(.c) void {
    if (!abi.enter(0x08012B04)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[3], 0x0, true);
            rt.r[3] = abi.read32(rt.r[13] +% 0x14);
            rt.r[4] = abi.read32(rt.r[13] +% 0x18);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[7], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 15));
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 10));
            rt.cpuAdd(&rt.r[5], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[4], rt.r[0] << 2);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!math.modUnsigned32Call(0x08012B2F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x40, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[7]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[5], rt.r[5], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(low_peel_13.func_0807B634, 0x08012B4D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (!rt.CPU_Z) {
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

pub fn func_08012B58() callconv(.c) void {
    if (!abi.enter(0x08012B58)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            rt.r[3] = abi.read32(rt.r[13] +% 0x10);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[6], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 15));
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 10));
            rt.cpuAdd(&rt.r[4], rt.r[2], rt.r[1], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!math.modSigned32Call(0x08012B77)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(18);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x08012BA4);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[6]);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x40, true);
            rt.r[3] = abi.read32(0x08012BA8);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[6]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!math.divSigned32Call(0x08012B97)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (!rt.CPU_Z) {
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

pub fn func_08012C7C() callconv(.c) void {
    if (!abi.enter(0x08012C7C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x40, true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.cpuSub(null, rt.r[1], 0x7, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x32, true);
            continue :blk 5;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(14);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x8, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x34);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            abi.write16(rt.r[3] +% 0x34, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08012DB0() callconv(.c) void {
    if (!abi.enter(0x08012DB0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
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
            abi.fetches(8);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x10, true);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(7);
            rt.r[4] = abi.read32(rt.r[2] +% 0x0);
            rt.r[1] = abi.read32(rt.r[2] +% 0x4);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x10, true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read32(rt.r[2] +% 0x0);
            continue :blk 6;
        },
        8 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 13;
        },
        11 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            abi.write32(rt.r[2] +% 0x0, rt.r[4]);
            abi.write32(rt.r[2] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[2] +% 0x8, rt.r[0]);
            continue :blk 3;
        },
        13 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x10, true);
            rt.r[0] = abi.read32(rt.r[3] +% 0x4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            continue :blk 12;
        },
        14 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            continue :blk 8;
        },
        else => unreachable,
    }
}

pub fn func_08012EE0() callconv(.c) void {
    if (!abi.enter(0x08012EE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08012F04);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[5], 0x1);
            rt.cpuSub(&rt.r[5], 0, rt.r[5], true);
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
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
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_3.func_08012D8C, 0x08012EFB)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            continue :blk 3;
        },
        8 => {
            abi.fetches(7);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        else => unreachable,
    }
}

pub fn func_08013000() callconv(.c) void {
    if (!abi.enter(0x08013000)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x10, true);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x20, true);
            abi.write32(rt.r[2] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write32(rt.r[2] +% 0x8, rt.r[1]);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x20, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[9], rt.r[4], true);
            if (!rt.CPU_C) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(21);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[6], true);
            abi.write32(rt.r[3] +% 0x0, rt.r[1]);
            abi.write32(rt.r[3] +% 0x4, rt.r[6]);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[3] +% 0x8, rt.r[0]);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.r[0] = rt.r[10];
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            rt.r[3] = rt.r[9];
            rt.cpuSub(&rt.r[1], rt.r[3], rt.r[6], true);
            rt.r[3] = rt.r[8];
            rt.cpuSub(&rt.r[0], rt.r[7], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 2));
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[2] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[2] +% 0x8, rt.r[0]);
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            rt.r[0] = rt.r[10];
            abi.write32(rt.r[3] +% 0x0, rt.r[0]);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 2));
            abi.write32(rt.r[3] +% 0x4, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[3] +% 0x8, rt.r[0]);
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            continue :blk 6;
        },
        6 => {
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

pub fn func_0801320C() callconv(.c) void {
    if (!abi.enter(0x0801320C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 24);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!proc.allocProcSlotCall(0x0801321B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[1], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[1], 24));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
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
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(clusters_low.func_0801319C, 0x08013235)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x08013244);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08013248() callconv(.c) void {
    if (!abi.enter(0x08013248)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[6] = abi.read32(0x08013294);
            rt.r[7] = abi.read16(rt.r[6] +% 0x0);
            rt.r[2] = abi.read32(0x08013298);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write32(rt.r[4] +% 0x0, rt.r[1]);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xC, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read16(rt.r[4] +% 0x12);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(tail_low.func_0807B450, 0x08013275)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(proc.func_08014850, 0x08013285)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[7]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            if (!abi.call(sprite_anim.func_080134F8, 0x0801328D)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0801329C() callconv(.c) void {
    if (!abi.enter(0x0801329C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[2] = abi.read32(0x080132C0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_08013248, 0x080132B9)) return;
            continue :blk 4;
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
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_080132D8() callconv(.c) void {
    if (!abi.enter(0x080132D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[2] = abi.read32(0x080132F8);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_08013248, 0x080132F3)) return;
            continue :blk 4;
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
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_080138F8() callconv(.c) void {
    if (!abi.enter(0x080138F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[4] = abi.read32(0x08013934);
            abi.setRegNz(&rt.r[3], 0x1);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0x12);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write16(rt.r[1] +% 0x12, @truncate(rt.r[0]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[2], 0x27, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(low_peel_10.func_08013A40, 0x08013923)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(proc.func_08013B34, 0x08013927)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
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

pub fn func_08013938() callconv(.c) void {
    if (!abi.enter(0x08013938)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[3] = abi.read32(0x08013980);
            abi.setRegNz(&rt.r[4], 0x80);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.r[5] = abi.read8(rt.r[1] +% 0x14);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[2], 0x27, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[5] = abi.read16(rt.r[1] +% 0x12);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[5]);
            abi.write16(rt.r[1] +% 0x12, @truncate(rt.r[0]));
            continue :blk 3;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_10.func_08013A40, 0x0801396F)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(proc.func_08013B34, 0x08013973)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
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

pub fn func_08013CC4() callconv(.c) void {
    if (!abi.enter(0x08013CC4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[5] = abi.read32(0x08013CF0);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
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
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[3], 0x27, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08013D64() callconv(.c) void {
    if (!abi.enter(0x08013D64)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[2] = abi.read32(0x08013D94);
            abi.setRegNz(&rt.r[4], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 5);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[5], rt.r[4], rt.r[5], true);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(tail_low.func_0807B450, 0x08013D83)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
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
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08013F04() callconv(.c) void {
    if (!abi.enter(0x08013F04)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.r[2] = abi.read32(0x08013F30);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            if (!abi.call(tail_low.func_0807B450, 0x08013F23)) return;
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

pub fn func_08014DA4() callconv(.c) void {
    if (!abi.enter(0x08014DA4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(40);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[12] = rt.r[0];
            rt.r[10] = rt.r[1];
            rt.r[0] = abi.read32(rt.r[13] +% 0x28);
            rt.r[9] = rt.r[0];
            rt.r[5] = abi.read32(0x08014E08);
            rt.r[7] = abi.read32(0x08014E0C);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[5], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[8] = rt.r[1];
            rt.r[1] = rt.r[10];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[5], true);
            abi.write32(rt.r[4] +% 0x0, rt.r[3]);
            rt.r[2] = rt.r[8];
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[2]));
            rt.r[1] = abi.read32(rt.r[13] +% 0x20);
            rt.r[2] = abi.read32(rt.r[13] +% 0x24);
            abi.write32(rt.r[0] +% 0xC, rt.r[1]);
            abi.write32(rt.r[0] +% 0x10, rt.r[2]);
            rt.r[2] = rt.r[9];
            abi.write16(rt.r[0] +% 0xA, @truncate(rt.r[2]));
            rt.r[1] = rt.r[12];
            abi.setRegNz(&rt.r[6], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[6], 16));
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(func_0801A6F0, 0x08014DF1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
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
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        4 => {
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

pub fn func_08014F1C() callconv(.c) void {
    if (!abi.enter(0x08014F1C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(27);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.r[5] = abi.read32(0x08014F64);
            rt.r[7] = abi.read32(0x08014F68);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[5], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[5], true);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 23);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[3]);
            abi.write32(rt.r[4] +% 0x0, rt.r[1]);
            rt.r[1] = rt.r[13];
            rt.r[1] = abi.read16(rt.r[1] +% 0x14);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[6], rt.r[6] << 16);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[6], 16));
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(func_0801A6F0, 0x08014F4F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
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
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08015344() callconv(.c) void {
    if (!abi.enter(0x08015344)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(27);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.r[5] = abi.read32(0x0801538C);
            rt.r[7] = abi.read32(0x08015390);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[5], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[5], true);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[3]);
            abi.write32(rt.r[4] +% 0x0, rt.r[1]);
            rt.r[1] = rt.r[13];
            rt.r[1] = abi.read16(rt.r[1] +% 0x14);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[6], rt.r[6] << 16);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[6], 16));
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(func_0801A6F0, 0x08015377)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
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
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801574C() callconv(.c) void {
    if (!abi.enter(0x0801574C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(48);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x4;
            rt.r[9] = rt.r[0];
            abi.write32(rt.r[13] +% 0x0, rt.r[3]);
            rt.r[5] = abi.read32(rt.r[13] +% 0x24);
            rt.r[6] = abi.read32(rt.r[13] +% 0x28);
            rt.r[0] = abi.read32(rt.r[13] +% 0x2C);
            rt.r[12] = rt.r[0];
            rt.r[3] = abi.read32(0x080157C0);
            rt.r[8] = rt.r[3];
            rt.r[7] = abi.read32(0x080157C4);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[3], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[10] = rt.r[3];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[1], 0x4);
            rt.r[8] +%= rt.r[1];
            rt.r[4] +%= rt.r[8];
            rt.r[3] = abi.read32(rt.r[13] +% 0x0);
            abi.write32(rt.r[4] +% 0x0, rt.r[3]);
            rt.r[1] = rt.r[10];
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x080157C8);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[5]);
            rt.r[2] = abi.read32(0x080157CC);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[2]);
            abi.write32(rt.r[0] +% 0xC, rt.r[5]);
            abi.write32(rt.r[0] +% 0x10, rt.r[6]);
            rt.r[3] = rt.r[12];
            abi.write16(rt.r[0] +% 0xA, @truncate(rt.r[3]));
            rt.r[1] = rt.r[9];
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[9] = rt.r[1];
            if (!abi.call(func_0801A6F0, 0x080157A9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
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
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[7] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        4 => {
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

pub fn func_080157E6() callconv(.c) void {
    if (!abi.enter(0x080157E6)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0xC;
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            abi.write32(rt.r[13] +% 0x20, rt.r[3]);
            rt.r[1] = abi.read32(rt.r[13] +% 0x20);
            rt.r[2] = abi.read32(rt.r[13] +% 0x24);
            rt.r[0] = abi.read32(rt.r[13] +% 0x28);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.write32(rt.r[13] +% 0x4, rt.r[2]);
            abi.setRegNz(&rt.r[7], 0x1);
            rt.cpuSub(&rt.r[7], 0, rt.r[7], true);
            abi.write32(rt.r[13] +% 0x8, rt.r[7]);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[6], 0x0, true);
            if (!abi.call(func_0801574C, 0x08015811)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 3 });
            rt.r[13] +%= 0x4;
            decls.awre_cpu_bx(rt.r[3]); return;
        },
        else => unreachable,
    }
}

pub fn func_08015824() callconv(.c) void {
    if (!abi.enter(0x08015824)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(21);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0xC;
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[5], 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 24);
            abi.setRegNz(&rt.r[3], rt.r[3] | rt.r[2]);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            abi.write32(rt.r[13] +% 0x4, rt.r[5]);
            abi.setRegNz(&rt.r[4], 0x1);
            rt.cpuSub(&rt.r[4], 0, rt.r[4], true);
            abi.write32(rt.r[13] +% 0x8, rt.r[4]);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(func_0801574C, 0x0801584B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08015874() callconv(.c) void {
    if (!abi.enter(0x08015874)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0xC;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(proc.func_0801A6D8, 0x080158C5)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x080158E0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            if (!abi.call(clusters_low_2.func_0801A69C, 0x080158D5)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.r[6] = abi.read32(rt.r[5] +% 0x4);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0801588C);
            abi.setRegNz(&rt.r[6], rt.r[6] & rt.r[0]);
            if (!abi.call(tail_low.func_0807B464, 0x08015889)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(20);
            rt.r[7] = abi.read32(0x080158DC);
            rt.r[0] = abi.read16(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
            abi.setRegNz(&rt.r[3], 0x2);
            rt.r[2] = rt.sext16(abi.read16(rt.r[5] +% rt.r[3]));
            rt.r[3] = abi.read32(rt.r[5] +% 0xC);
            rt.r[4] = abi.read32(rt.r[5] +% 0x10);
            abi.write32(rt.r[13] +% 0x0, rt.r[3]);
            abi.write32(rt.r[13] +% 0x4, rt.r[4]);
            abi.setRegNz(&rt.r[4], 0xA);
            rt.r[3] = rt.sext16(abi.read16(rt.r[5] +% rt.r[4]));
            abi.write32(rt.r[13] +% 0x8, rt.r[3]);
            rt.cpuAdd(&rt.r[3], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_19.func_0801541C, 0x080158B5)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(3);
            continue :blk 1;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = abi.read16(rt.r[7] +% 0x0);
            rt.r[6] = abi.read16(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            abi.write16(rt.r[7] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08015AB0() callconv(.c) void {
    if (!abi.enter(0x08015AB0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            if (!abi.call(low_peel_3.func_08015A88, 0x08015ABD)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08015ADC);
            abi.setRegNz(&rt.r[1], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xB0, true);
            continue :blk 8;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08015AF8);
            abi.setRegNz(&rt.r[1], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[2], 0x9C);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_08015AFC() callconv(.c) void {
    if (!abi.enter(0x08015AFC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            if (!abi.call(low_peel_3.func_08015A88, 0x08015B0B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[5] = abi.read32(0x08015B40);
            abi.setRegNz(&rt.r[2], rt.r[6] << 2);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(6);
            rt.r[5] = abi.read32(0x08015B74);
            abi.setRegNz(&rt.r[2], rt.r[6] << 2);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xB0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xB0, true);
            continue :blk 11;
        },
        9 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            abi.setRegNz(&rt.r[6], 0x9C);
            abi.setRegNz(&rt.r[6], rt.r[6] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0x9C);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[2], true);
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08015E3C() callconv(.c) void {
    if (!abi.enter(0x08015E3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x2, true);
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
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x3);
            continue :blk 5;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        11 => {
            abi.fetches(3);
            continue :blk 10;
        },
        12 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x4);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08015EF8() callconv(.c) void {
    if (!abi.enter(0x08015EF8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
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
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x08015F34);
            if (!abi.call(low_peel_10.func_0801AC1C, 0x08015F0D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(low_peel_19.func_08016438, 0x08015F11)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08015F38);
            rt.r[0] = abi.read8(rt.r[0] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x5C, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0xB, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08015F3C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08015F40);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x3);
            if (!abi.call(low_peel_4.func_0803F314, 0x08015F2D)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(low_peel_10.func_08016820, 0x08015F31)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08015F44() callconv(.c) void {
    if (!abi.enter(0x08015F44)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[5] = abi.read32(0x08015F78);
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
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_0801AD38, 0x08015F5B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
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
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_10.func_0801AC1C, 0x08015F67)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08015F7C);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            rt.r[1] = abi.read32(0x08015F80);
            if (!abi.call(low_peel_5.func_0807A84C, 0x08015F71)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08016008() callconv(.c) void {
    if (!abi.enter(0x08016008)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[6] = abi.read32(0x08016080);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_10.func_0801AC1C, 0x08016015)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
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
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[3] = abi.read32(0x08016084);
            rt.r[7] = abi.read32(0x08016088);
            rt.r[5] = abi.read32(0x0801608C);
            rt.r[0] = abi.read32(0x08016090);
            rt.cpuAdd(&rt.r[4], rt.r[6], rt.r[0], true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08016084);
            abi.setRegNz(&rt.r[2], 0xD1);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[6], rt.r[2], true);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x24, true);
            abi.setRegNz(&rt.r[2], 0x22);
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            ldmRegs(1, &.{ 0 });
            stmRegs(4, &.{ 0 });
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(25);
            abi.setRegNz(&rt.r[1], 0xD0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[2] = abi.read32(0x08016094);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x21, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            abi.write32(rt.r[3] +% 0x10, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[7] +% 0x4);
            abi.write32(rt.r[3] +% 0x14, rt.r[0]);
            rt.r[1] = abi.read32(0x08016098);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x0801609C);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_08016F68() callconv(.c) void {
    if (!abi.enter(0x08016F68)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[0], 0xBA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.setRegNz(&rt.r[3], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[3], 10));
            continue :blk 2;
        },
        2 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], 0x16, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 9);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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

pub fn func_0801701C() callconv(.c) void {
    if (!abi.enter(0x0801701C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[2] = abi.read32(0x0801704C);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[4], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[5], rt.r[4], rt.r[5], true);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x4);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(tail_low.func_0807B450, 0x0801703B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
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
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801728C() callconv(.c) void {
    if (!abi.enter(0x0801728C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x080172D8);
            rt.r[4] = abi.read32(0x080172DC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(16);
            rt.r[3] = abi.read32(0x080172E0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[2] +% 0x8);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            rt.r[0] = abi.read32(rt.r[2] +% 0xC);
            abi.write16(rt.r[1] +% 0xC, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08017370() callconv(.c) void {
    if (!abi.enter(0x08017370)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[2] = abi.read32(0x080173B8);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write32(rt.r[2] +% 0x0, rt.r[1]);
            rt.r[6] = abi.read32(0x080173BC);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0x9, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[3], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_080173C0() callconv(.c) void {
    if (!abi.enter(0x080173C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x08017420);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x08017428);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(27);
            rt.r[5] = abi.read32(0x08017424);
            rt.r[3] = abi.read32(0x08017428);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x4, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x8);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write8(rt.r[5] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0xA);
            abi.write8(rt.r[5] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            abi.write16(rt.r[0] +% 0xE, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x8, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[0] = abi.read32(0x0801742C);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            if (!sound.playSfxCall(0x73, 0x08017403)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08017430() callconv(.c) void {
    if (!abi.enter(0x08017430)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(0x0801746C);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[0], 0xE6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[12] = rt.r[0];
            rt.r[0] = abi.read32(0x08017470);
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[5], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[3], rt.r[0] << 1);
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.cpuSub(null, rt.r[0], 0x5, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            continue :blk 5;
        },
        5 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[8];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[2], 0x5, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[6] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0x5, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(dma.func_080178F4, 0x08017497)) return;
            continue :blk 8;
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

pub fn func_08017500() callconv(.c) void {
    if (!abi.enter(0x08017500)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x08017554);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x0801755C);
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
            abi.setRegNz(&rt.r[0], 0x0);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(21);
            rt.r[3] = abi.read32(0x08017558);
            rt.r[2] = abi.read32(0x0801755C);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x8);
            abi.write8(rt.r[3] +% 0x1, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0xA);
            abi.write8(rt.r[3] +% 0x2, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[3] +% 0x1);
            rt.r[1] = abi.read8(rt.r[3] +% 0x2);
            if (!abi.call(func_08017560, 0x08017537)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08017560() callconv(.c) void {
    if (!abi.enter(0x08017560)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.cpuSub(null, rt.r[4], 0xC, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(co.func_0801BEBC, 0x08017597)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08017588);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 28);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 30);
            abi.setRegNz(&rt.r[0], rt.r[0] << 14);
            rt.r[1] = abi.read32(0x0801758C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x90);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            if (!abi.call(func_0800FED0, 0x08017585)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x080175C0);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 28);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 30);
            abi.setRegNz(&rt.r[1], rt.r[1] << 14);
            rt.r[2] = abi.read32(0x080175C4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            if (!abi.call(low_peel_3.func_0800FE24, 0x080175A9)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(co.func_0801BEE4, 0x080175AF)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x90);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!dma.copyPaletteCall(0x080175B9)) return;
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

pub fn func_080175C8() callconv(.c) void {
    if (!abi.enter(0x080175C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[9] = rt.r[0];
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.r[8] = rt.r[1];
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(0x08017630);
            rt.r[12] = rt.r[0];
            abi.setRegNz(&rt.r[0], 0xE6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08017634);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[4], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[3], rt.r[0] << 1);
            continue :blk 2;
        },
        2 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[7], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[2], 0x5, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[1], 0x5, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = rt.r[9];
            rt.r[1] = rt.r[8];
            if (!abi.call(func_08017560, 0x08017621)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(dma.func_080178F4, 0x08017625)) return;
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

pub fn func_08017928() callconv(.c) void {
    if (!abi.enter(0x08017928)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x8;
            rt.r[6] = abi.read32(0x0801799C);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[5], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[5], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x4);
            if (!abi.call(low_peel_10.func_08011C80, 0x08017945)) return;
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
            rt.r[0] = abi.read32(0x080179A0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080179A0);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        4 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x080179A4);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[3] = abi.read32(rt.r[0] +% 0x4);
            rt.r[0] = abi.read32(0x080179A8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 28);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x7);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(sprite_anim.func_080123A8, 0x08017977)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write32(rt.r[4] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x080179AC);
            abi.write32(rt.r[0] +% 0x3C, rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x38, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.r[1] = abi.read32(0x080179B0);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_080179B4() callconv(.c) void {
    if (!abi.enter(0x080179B4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x8;
            rt.r[6] = abi.read32(0x08017A28);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[5], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[5], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x4);
            if (!abi.call(low_peel_10.func_08011C80, 0x080179D1)) return;
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
            rt.r[0] = abi.read32(0x08017A2C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08017A2C);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        4 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x08017A30);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[3] = abi.read32(rt.r[0] +% 0x4);
            rt.r[0] = abi.read32(0x08017A34);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 28);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x7);
            abi.setRegNz(&rt.r[1], 0xF);
            if (!abi.call(sprite_anim.func_080123A8, 0x08017A03)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write32(rt.r[4] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x08017A38);
            abi.write32(rt.r[0] +% 0x3C, rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x38, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.r[1] = abi.read32(0x08017A3C);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_08017BC0() callconv(.c) void {
    if (!abi.enter(0x08017BC0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[2] = abi.read32(0x08017BE4);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x8);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[2] = rt.sext16(abi.read16(rt.r[1] +% rt.r[0]));
            rt.r[0] = abi.read32(0x08017C2C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1A);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x5);
            continue :blk 3;
        },
        3 => {
            abi.fetches(12);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x08017C30);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08017C34);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!dma.copyPaletteCall(0x08017C0D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x08017C38);
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
            abi.setRegNz(&rt.r[0], 0x1);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08017CDC() callconv(.c) void {
    if (!abi.enter(0x08017CDC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[6] = abi.read32(0x08017D0C);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[4], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[5], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[5], rt.r[4], rt.r[5], true);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x4);
            rt.r[0] = abi.read32(rt.r[0] +% 0xC);
            if (!abi.call(tail_low.func_0807B450, 0x08017CF9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[6], true);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
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
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08017E54() callconv(.c) void {
    if (!abi.enter(0x08017E54)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x08017E90);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read32(rt.r[4] +% 0x0);
            rt.r[3] = abi.read32(rt.r[2] +% 0x4);
            rt.r[0] = abi.read32(0x08017E94);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(rt.r[2] +% 0xC);
            rt.r[1] = abi.read16(rt.r[1] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x0);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(tail_low.func_0807B458, 0x08017E7D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(low_peel_1.func_080172E4, 0x08017E81)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write32(rt.r[4] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08017EB8() callconv(.c) void {
    if (!abi.enter(0x08017EB8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[1] = abi.read32(0x08017EE4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read32(rt.r[0] +% 0xC);
            if (!abi.call(tail_low.func_0807B44C, 0x08017ED3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_1.func_08017E98, 0x08017EEF)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write32(rt.r[4] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
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

pub fn func_08018098() callconv(.c) void {
    if (!abi.enter(0x08018098)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[2] = abi.read32(0x080180B4);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[4] = abi.read32(rt.r[0] +% 0x4);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            rt.r[2] = abi.read32(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(menu.func_08018AC0, 0x080180C3)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x080180E8);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
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
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x8, true);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08018184() callconv(.c) void {
    if (!abi.enter(0x08018184)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[5], rt.r[4], 0x0, true);
            rt.r[0] = abi.read32(0x080181CC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x080181D4);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
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
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080181D0);
            if (!abi.call(func_08018400, 0x0801819B)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(12);
            rt.r[3] = abi.read32(0x080181D4);
            abi.setRegNz(&rt.r[2], rt.r[4] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.write32(rt.r[0] +% 0x14, rt.r[1]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080183C0() callconv(.c) void {
    if (!abi.enter(0x080183C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[3] = abi.read32(0x080183E4);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
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
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_1.func_080183A8, 0x080183E1)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
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
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_08018400() callconv(.c) void {
    if (!abi.enter(0x08018400)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            if (!abi.call(state.func_08018C9C, 0x08018409)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(low_peel_3.func_0801836C, 0x0801840F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        4 => {
            abi.fetches(20);
            rt.r[3] = abi.read32(0x08018440);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[5]);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x8, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write32(rt.r[2] +% 0x0, rt.r[4]);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[5]);
            abi.write16(rt.r[0] +% 0xC, @truncate(rt.r[4]));
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

pub fn func_0801844C() callconv(.c) void {
    if (!abi.enter(0x0801844C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[4] = abi.read32(0x080184B0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[2], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[4], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
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
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0xC);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0xC, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[6] = abi.read32(0x080184B4);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(tail_low.func_0807B450, 0x080184A5)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080184B8() callconv(.c) void {
    if (!abi.enter(0x080184B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = abi.read32(0x08018524);
            rt.r[0] = abi.read32(0x08018528);
            rt.r[3] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
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
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(menu.func_08018B68, 0x080184D9)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(24);
            rt.r[0] = abi.read32(0x0801852C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[2] = ~rt.r[0]; rt.updateNz(rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.r[3] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.r[3] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write16(rt.r[1] +% 0x4, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.r[3] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x6);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            abi.write16(rt.r[1] +% 0x6, @truncate(rt.r[2]));
            continue :blk 6;
        },
        6 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x2, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 15));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[6], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080185C8() callconv(.c) void {
    if (!abi.enter(0x080185C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[5] = abi.read32(0x0801860C);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x9);
            rt.r[1] = abi.read16(rt.r[1] +% 0xC);
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
            abi.fetches(4);
            if (!abi.call(low_peel_10.func_08012BB8, 0x080185DF)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[1] = abi.read16(rt.r[1] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x28);
            if (!abi.call(func_08016F68, 0x080185FD)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08018610);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 5;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x2C);
            if (!abi.call(tail_low.func_0807B44C, 0x08018603)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[4] +% 0x8, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080186AC() callconv(.c) void {
    if (!abi.enter(0x080186AC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x080186F4);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x12);
            rt.r[1] = abi.read16(rt.r[1] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[2] = abi.read32(0x080186D0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 6;
        },
        4 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[1] = abi.read16(rt.r[1] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[1] = abi.read16(rt.r[1] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 9;
        },
        6 => {
            abi.fetches(6);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(ui.func_0801862C, 0x080186ED)) return;
            continue :blk 10;
        },
        7 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0801872C);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x28);
            if (!abi.call(func_08016F68, 0x08018711)) return;
            continue :blk 11;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 6;
        },
        10 => {
            abi.fetches(5);
            if (!sound.playSfxCall(0x67, 0x080186F3)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x2C);
            if (!abi.call(tail_low.func_0807B44C, 0x08018717)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(3);
            continue :blk 8;
        },
        13 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08018730);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x0801871F)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(5);
            if (!sound.playSfxCall(0x65, 0x08018725)) return;
            continue :blk 8;
        },
        else => unreachable,
    }
}

pub fn func_08018734() callconv(.c) void {
    if (!abi.enter(0x08018734)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            abi.setRegNz(&rt.r[3], rt.r[3] << 24);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 24);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (rt.CPU_C) {
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
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[5] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[3], true);
            continue :blk 3;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (!rt.CPU_C) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08018D84() callconv(.c) void {
    if (!abi.enter(0x08018D84)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[7], rt.r[1] >> 24);
            abi.setRegNz(&rt.r[4], 0x1);
            abi.setRegNz(&rt.r[5], 0x68);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[6], rt.r[6] *% rt.r[5]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x08018DDC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x26, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_4.func_08024CD0, 0x08018DB5)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(low_peel_4.func_08028400, 0x08018DD1)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(low_peel_1.func_08028714, 0x08018DC3)) return;
            continue :blk 3;
        },
        7 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08018DE0);
            abi.setRegNz(&rt.r[0], 0xE);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801912C() callconv(.c) void {
    if (!abi.enter(0x0801912C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(low_peel_10.func_08018FC4, 0x08019135)) return;
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
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08019164);
            if (!proc.allocProcSlotCall(0x08019147)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_10.func_08018EA0, 0x08019141)) return;
            continue :blk 2;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[4] +% 0x44);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x40, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write16(rt.r[0] +% 0x22, @truncate(rt.r[1]));
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

pub fn func_08019288() callconv(.c) void {
    if (!abi.enter(0x08019288)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(3);
            rt.r[5] = abi.read32(0x080192B0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0xA, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x9, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 9;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 10;
        },
        8 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        10 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            continue :blk 8;
        },
        else => unreachable,
    }
}

pub fn func_08019640() callconv(.c) void {
    if (!abi.enter(0x08019640)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x1);
            rt.r[3] = abi.read8(rt.r[2] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read8(rt.r[2] +% 0x3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[4] = abi.read8(rt.r[2] +% 0x5);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[3], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.write8(rt.r[2] +% 0x3, @truncate(rt.r[0]));
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_08019678() callconv(.c) void {
    if (!abi.enter(0x08019678)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            rt.r[1] = abi.read32(0x080196C8);
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[2], 0x4);
            if (!abi.call(low_peel_5.func_0807A8A0, 0x0801968D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x080196CC);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x2, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuSub(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x080196D0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
            continue :blk 4;
        },
        4 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[13];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0801977C() callconv(.c) void {
    if (!abi.enter(0x0801977C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            rt.r[1] = abi.read32(0x080197CC);
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[2], 0x4);
            if (!abi.call(low_peel_5.func_0807A8A0, 0x08019791)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x080197D0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x2, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuSub(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x080197D4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
            continue :blk 4;
        },
        4 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[13];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0801990C() callconv(.c) void {
    if (!abi.enter(0x0801990C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            rt.r[5] = abi.read32(0x08019964);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            abi.setRegNz(&rt.r[4], rt.r[4] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1A);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x08019968);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!dma.copyPaletteCall(0x08019947)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08019924);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!dma.copyPaletteCall(0x08019923)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x1A);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x0801996C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0xB8);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!dma.copyPaletteCall(0x0801995F)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
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

pub fn func_08019A6C() callconv(.c) void {
    if (!abi.enter(0x08019A6C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x4;
            rt.r[1] = abi.read32(0x08019AB0);
            rt.r[4] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read32(0x08019AB4);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(25);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x8, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[4]);
            rt.r[0] = abi.read32(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[1] = rt.sext8(abi.read8(rt.r[4] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[2] = rt.sext8(abi.read8(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], 0x3);
            rt.r[3] = rt.sext8(abi.read8(rt.r[4] +% rt.r[3]));
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.r[4] = abi.read8(rt.r[4] +% 0x2);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 24));
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            if (!abi.call(low_peel_14.func_08019424, 0x08019AA9)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08019ABC() callconv(.c) void {
    if (!abi.enter(0x08019ABC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0xC;
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.r[6] = abi.read32(rt.r[13] +% 0x1C);
            rt.r[1] = abi.read32(rt.r[13] +% 0x2C);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(rt.r[13] +% 0x24);
            rt.r[1] = abi.read32(rt.r[13] +% 0x28);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.write32(rt.r[13] +% 0x8, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(func_08014DA4, 0x08019AFD)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[13] +% 0x20);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(func_08014F1C, 0x08019AE3)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 4, 5, 6 });
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

pub fn func_08019F18() callconv(.c) void {
    if (!abi.enter(0x08019F18)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x0, true);
            rt.r[2] = abi.read32(rt.r[13] +% 0x1C);
            rt.r[1] = abi.read32(rt.r[13] +% 0x18);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
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
            abi.fetches(3);
            rt.r[4] = abi.read32(0x08019F48);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x4C);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            abi.write32(rt.r[13] +% 0x0, rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[7], 0x0, true);
            if (!abi.call(low_peel_10.func_08019E60, 0x08019F47)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        7 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_08019FD8() callconv(.c) void {
    if (!abi.enter(0x08019FD8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0801A014);
            rt.r[12] = rt.r[0];
            abi.setRegNz(&rt.r[6], 0x4C);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[6]);
            rt.r[5] = rt.r[12];
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(0x0801A018);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x1, true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
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
            abi.fetches(5);
            rt.cpuSub(&rt.r[2], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[6]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            abi.write32(rt.r[4] +% 0x0, rt.r[3]);
            continue :blk 1;
        },
        6 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], 0x4C);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.write32(rt.r[4] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801A0A8() callconv(.c) void {
    if (!abi.enter(0x0801A0A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x0801A0E4);
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
            rt.r[5] = abi.read32(0x0801A0E8);
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
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(low_peel_19.func_08019B04, 0x0801A0CB)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[0] = abi.read32(0x0801A0E4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            if (!abi.call(low_peel_10.func_0801A26C, 0x0801A0D3)) return;
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_0801A218() callconv(.c) void {
    if (!abi.enter(0x0801A218)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[1], 0x1F);
            rt.r[3] = abi.read32(0x0801A238);
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[5]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
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
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0801A33C() callconv(.c) void {
    if (!abi.enter(0x0801A33C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = abi.read32(0x0801A370);
            rt.r[12] = rt.r[0];
            abi.setRegNz(&rt.r[4], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.r[2] << 16);
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], 0x4C);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[5], 16));
            if (!abi.call(func_0801A38C, 0x0801A36B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x28, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
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

pub fn func_0801A38C() callconv(.c) void {
    if (!abi.enter(0x0801A38C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(63);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], 0x4C);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] *% rt.r[0]);
            rt.r[0] = abi.read32(0x0801A414);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.r[12] = rt.r[4];
            abi.setRegNz(&rt.r[5], 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = rt.r[12];
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[4]));
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            abi.write32(rt.r[0] +% 0x10, rt.r[4]);
            abi.write32(rt.r[0] +% 0xC, rt.r[4]);
            abi.write32(rt.r[0] +% 0x18, rt.r[4]);
            abi.write32(rt.r[0] +% 0x14, rt.r[4]);
            abi.write16(rt.r[0] +% 0x1C, @truncate(rt.r[4]));
            abi.write32(rt.r[0] +% 0x48, rt.r[1]);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 14));
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x4);
            rt.r[2] = rt.r[12];
            abi.write32(rt.r[2] +% 0x4, rt.r[0]);
            abi.write32(rt.r[2] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.write32(rt.r[2] +% 0x20, rt.r[0]);
            abi.write8(rt.r[2] +% 0x1E, @truncate(rt.r[3]));
            abi.write16(rt.r[2] +% 0x26, @truncate(rt.r[4]));
            abi.write32(rt.r[2] +% 0x2C, rt.r[4]);
            abi.write16(rt.r[2] +% 0x24, @truncate(rt.r[4]));
            rt.r[1] = abi.read32(0x0801A418);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.r[1] = abi.read16(rt.r[2] +% 0x38);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            abi.write16(rt.r[2] +% 0x38, @truncate(rt.r[1]));
            rt.r[2] = abi.read16(rt.r[2] +% 0x3A);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            rt.r[1] = rt.r[12];
            abi.write16(rt.r[1] +% 0x3A, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write16(rt.r[1] +% 0x3C, @truncate(rt.r[0]));
            abi.write16(rt.r[1] +% 0x3E, @truncate(rt.r[0]));
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x18, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            abi.write32(rt.r[1] +% 0x44, rt.r[4]);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = rt.r[12];
            abi.write32(rt.r[2] +% 0x30, rt.r[0]);
            abi.write32(rt.r[2] +% 0x34, rt.r[1]);
            rt.r[1] = abi.read32(0x0801A41C);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x1, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801A61C() callconv(.c) void {
    if (!abi.enter(0x0801A61C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x0801A658);
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
            rt.r[5] = abi.read32(0x0801A65C);
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
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(low_peel_14.func_0801A420, 0x0801A63F)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[0] = abi.read32(0x0801A658);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            if (!abi.call(low_peel_10.func_0801A26C, 0x0801A647)) return;
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_0801A6F0() callconv(.c) void {
    if (!abi.enter(0x0801A6F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[3], rt.r[1] >> 16);
            rt.r[0] = abi.read32(0x0801A70C);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[4]));
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x80, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[7], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[7]));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(0x0801A734);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[2]);
            abi.write16(rt.r[1] +% 0x8, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0xC, true);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[7] = abi.read16(rt.r[2] +% 0x8);
            abi.setRegNz(&rt.r[0], rt.r[7] << 16);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(5);
            abi.write32(rt.r[1] +% 0x4, rt.r[2]);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            abi.write32(rt.r[4] +% 0x4, rt.r[1]);
            abi.write32(rt.r[1] +% 0x4, rt.r[2]);
            continue :blk 10;
        },
        8 => {
            abi.fetches(4);
            abi.write32(rt.r[1] +% 0x4, rt.r[0]);
            abi.write32(rt.r[2] +% 0x4, rt.r[1]);
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            continue :blk 3;
        },
        10 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[6] +% 0x4);
            abi.write32(rt.r[5] +% 0x4, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0801ABC0() callconv(.c) void {
    if (!abi.enter(0x0801ABC0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], 0x0, true);
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
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0801AC08);
            rt.r[0] = abi.read32(0x0801AC0C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(tail_low.func_0807B450, 0x0801ABD7)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0xFF);
            rt.r[3] = abi.read32(0x0801AC10);
            abi.setRegNz(&rt.r[2], 0xF);
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[1] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.r[0] = abi.read8(rt.r[3] +% 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[4]);
            abi.write8(rt.r[3] +% 0x10, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[4]);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0801AC0C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_19.func_0801A7A4, 0x0801AC05)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0801AD38() callconv(.c) void {
    if (!abi.enter(0x0801AD38)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0xFF, true);
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
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_14.func_0801B0F0, 0x0801AD49)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[1] = abi.read32(0x0801AD54);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        5 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = abi.read32(0x0801AD78);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x20, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[5], 0x10);
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(3);
            continue :blk 1;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0xF, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0801AFEC() callconv(.c) void {
    if (!abi.enter(0x0801AFEC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x0801B034);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x0801B038);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(low_peel_3.func_0801B654, 0x0801AFFF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[7] = abi.read32(0x0801B03C);
            rt.r[0] = abi.read32(0x0801B040);
            rt.cpuAdd(&rt.r[4], rt.r[5], rt.r[0], true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 5);
            if (!abi.call(low_peel_3.func_0801B7B8, 0x0801B015)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(func_0801B758, 0x0801B01D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(func_0801B070, 0x0801B025)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x1, true);
            rt.cpuSub(null, rt.r[6], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0801B06C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 11;
        },
        9 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x4);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x4);
            continue :blk 11;
        },
        10 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0xFA);
            rt.r[2] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801AFFE() callconv(.c) void {
    if (!abi.enter(0x0801AFFE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[7] = abi.read32(0x0801B03C);
            rt.r[0] = abi.read32(0x0801B040);
            rt.cpuAdd(&rt.r[4], rt.r[5], rt.r[0], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 5);
            if (!abi.call(low_peel_3.func_0801B7B8, 0x0801B015)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(func_0801B758, 0x0801B01D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(func_0801B070, 0x0801B025)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x1, true);
            rt.cpuSub(null, rt.r[6], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0801B06C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 10;
        },
        8 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x4);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x4);
            continue :blk 10;
        },
        9 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0xFA);
            rt.r[2] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801B01C() callconv(.c) void {
    if (!abi.enter(0x0801B01C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(func_0801B070, 0x0801B025)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x1, true);
            rt.cpuSub(null, rt.r[6], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0801B06C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 8;
        },
        5 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 5);
            if (!abi.call(low_peel_3.func_0801B7B8, 0x0801B015)) return;
            continue :blk 9;
        },
        6 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x4);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x4);
            continue :blk 8;
        },
        7 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0xFA);
            rt.r[2] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(func_0801B758, 0x0801B01D)) return;
            continue :blk 0;
        },
        else => unreachable,
    }
}

pub fn func_0801B070() callconv(.c) void {
    if (!abi.enter(0x0801B070)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x0801B090);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x0801B094);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[2], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x55, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0801B098);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xAA, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0xAA, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 8;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(3);
            continue :blk 2;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[4] = abi.read32(0x0801B0E0);
            rt.r[3] = abi.read32(0x0801B0E4);
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0801B0E0);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x55, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 7;
        },
        9 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x6);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(8);
            rt.r[0] = ~rt.r[2]; rt.updateNz(rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read8(rt.r[1] +% 0x7);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(5);
            rt.r[5] = abi.read8(rt.r[5] +% 0x5);
            rt.cpuSub(null, rt.r[5], 0x9, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_0801B4F8() callconv(.c) void {
    if (!abi.enter(0x0801B4F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[0] = abi.read32(0x0801B51C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0801B520);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x0801B524);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(low_peel_3.func_0801B654, 0x0801B50F)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[7] = abi.read32(0x0801B528);
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[5], 0x0);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x3, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 5);
            if (!abi.call(low_peel_3.func_0801B7B8, 0x0801B541)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x4, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(func_0801B758, 0x0801B549)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[1], rt.r[6] << 12);
            rt.r[0] = abi.read32(0x0801B56C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(0x0801B570);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 5);
            if (!abi.call(low_peel_1.func_0801B7F4, 0x0801B561)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 8;
        },
        12 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x1, true);
            rt.cpuSub(null, rt.r[6], 0xF, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 14;
        },
        13 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            continue :blk 6;
        },
        14 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0801B6B8() callconv(.c) void {
    if (!abi.enter(0x0801B6B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.r[0] = abi.read32(0x0801B6D8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0801B6DC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(tail_low.func_0807B450, 0x0801B6D3)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0xF, true);
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
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[1] << 12);
            rt.r[1] = abi.read32(0x0801B6FC);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            if (!abi.call(low_peel_1.func_0801B80C, 0x0801B6F7)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_0801B758() callconv(.c) void {
    if (!abi.enter(0x0801B758)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x0801B770);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = abi.read32(0x0801B7A8);
            abi.setRegNz(&rt.r[0], rt.r[4] << 12);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.r[4] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_13.func_08079D48, 0x0801B76F)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            rt.r[4] = abi.read32(0x0801B7AC);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            continue :blk 6;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            continue :blk 9;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], rt.r[4], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 10;
        },
        7 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            continue :blk 9;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        10 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.r[5] = abi.read8(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 4;
        },
        else => unreachable,
    }
}

pub fn func_0801BA08() callconv(.c) void {
    if (!abi.enter(0x0801BA08)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.r[0] = abi.read32(0x0801BA74);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(0x0801BA78);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(0x0801BA7C);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.r[1] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x7, true);
            abi.setRegNz(&rt.r[1], 0x8);
            if (!bios.divSwiCall(0x0801BA6D)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0801BA7C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(low_peel_3.func_0801BA80, 0x0801BA35)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(10);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            rt.r[1] = abi.read32(0x0801BA78);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[6], 0x0, true);
            if (!abi.call(low_peel_12.func_08052230, 0x0801BA4D)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0801BA74);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            if (!abi.call(low_peel_3.func_0801BA80, 0x0801BA55)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x40, true);
            continue :blk 5;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x40, true);
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801BD28() callconv(.c) void {
    if (!abi.enter(0x0801BD28)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[7] = abi.read32(0x0801BD78);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0xA, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0xB, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], 0xB, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0801BD7C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0801BD80);
            rt.cpuAdd(&rt.r[4], rt.r[5], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            if (!abi.call(low_peel_2.func_0803F02C, 0x0801BD4B)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0801BD78);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0xFF);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0801BD84() callconv(.c) void {
    if (!abi.enter(0x0801BD84)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            if (!abi.call(func_0801BD28, 0x0801BD8B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x5, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0801BDD8);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0xFF);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(3);
            rt.r[5] = abi.read32(0x0801BDD8);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if (rt.CPU_C) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            continue :blk 7;
        },
        6 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x5, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 2;
        },
        7 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if (!rt.CPU_C) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_0801BF68() callconv(.c) void {
    if (!abi.enter(0x0801BF68)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.r[8] = rt.r[1];
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            rt.r[0] = abi.read32(0x0801BFB4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x7);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(state.func_0801BFD0, 0x0801BF83)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            rt.r[7] = abi.read32(0x0801BFB8);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            rt.cpuAdd(&rt.r[5], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[5], rt.r[5] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0x20);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[4] +%= rt.r[8];
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(func_0801C018, 0x0801BFA3)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(func_0801C018, 0x0801BFAD)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x20);
            rt.r[0] +%= rt.r[8];
            continue :blk 10;
        },
        9 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[1], true);
            continue :blk 10;
        },
        10 => {
            abi.fetches(3);
            abi.write32(rt.r[1] +% 0x20, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801C018() callconv(.c) void {
    if (!abi.enter(0x0801C018)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(state.func_0801C108, 0x0801C025)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x9, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(state.func_0801C108, 0x0801C037)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[3], 0xC8);
            continue :blk 5;
        },
        4 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 18);
            abi.setRegNz(&rt.r[0], 0xC8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 15);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[3], rt.r[1] >> 16);
            continue :blk 5;
        },
        5 => {
            abi.fetches(21);
            rt.r[2] = abi.read32(0x0801C074);
            rt.r[0] = abi.read32(0x0801C078);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            abi.setRegNz(&rt.r[1], 0x64);
            if (!bios.divSwiCall(0x0801C06F)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801C0A4() callconv(.c) void {
    if (!abi.enter(0x0801C0A4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.r[5] = abi.read32(0x0801C0D8);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
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
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(low_peel_3.func_0801C07C, 0x0801C0C5)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
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
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0801C1CC() callconv(.c) void {
    if (!abi.enter(0x0801C1CC)) return;
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0xA, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0xB, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x15, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0801C35C() callconv(.c) void {
    if (!abi.enter(0x0801C35C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(21);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[3] = abi.read32(0x0801C394);
            rt.r[1] = abi.read32(0x0801C398);
            rt.r[0] = abi.read32(0x0801C39C);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1);
            if (!abi.call(unit.func_0801CCB8, 0x0801C3AF)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(turn.func_08035230, 0x0801C387)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[5] +% 0x22, @truncate(rt.r[0]));
            abi.write16(rt.r[5] +% 0x1E, @truncate(rt.r[1]));
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0801C3A0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(func_080132D8, 0x0801C391)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
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

pub fn func_0801D148() callconv(.c) void {
    if (!abi.enter(0x0801D148)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = abi.read32(0x0801D1A4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0801D1A8);
            rt.r[8] = rt.r[0];
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[3], rt.r[1], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(19);
            rt.r[1] = rt.r[8];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = rt.r[8];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x21, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(5);
            rt.r[12] = rt.r[4];
            rt.r[6] = abi.read32(0x0801D1AC);
            rt.r[7] = abi.read32(0x0801D1B0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(14);
            rt.r[1] = rt.r[12];
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            stmRegs(7, &.{ 0 });
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x2);
            rt.cpuSub(null, rt.r[3], rt.r[2], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801D1B4() callconv(.c) void {
    if (!abi.enter(0x0801D1B4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(0x0801D1E4);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read16(rt.r[2] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[3], true);
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
            abi.fetches(5);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[4] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_0801DBCC() callconv(.c) void {
    if (!abi.enter(0x0801DBCC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[4] = abi.read32(0x0801DC34);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0801DC30);
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x0801DC30);
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[1]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0801DC30);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0801DC30);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
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

pub fn func_0801DE0C() callconv(.c) void {
    if (!abi.enter(0x0801DE0C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x14;
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(11);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = rt.r[13];
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.r[1] = rt.r[13];
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            rt.r[13] +%= 0x14;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0801DEB8() callconv(.c) void {
    if (!abi.enter(0x0801DEB8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = abi.read32(0x0801DF2C);
            rt.r[12] = rt.r[0];
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[3], rt.r[1], true);
            if ((rt.CPU_N == rt.CPU_V)) {
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
            abi.fetches(4);
            rt.r[8] = rt.r[0];
            rt.r[9] = rt.r[12];
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[5], rt.r[3] << 16);
            rt.r[4] = rt.r[8];
            rt.r[4] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[4], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.r[0] = rt.r[9];
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[5], 15));
            rt.r[4] = abi.read32(0x0801DF30);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 9);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[2], true);
            abi.setRegNz(&rt.r[3], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[4] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[1], true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        else => unreachable,
    }
}

pub fn func_0801E038() callconv(.c) void {
    if (!abi.enter(0x0801E038)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[0] = abi.read32(0x0801E058);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x68);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1B);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x26, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
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

pub fn func_0801E07C() callconv(.c) void {
    if (!abi.enter(0x0801E07C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[5], 0x1);
            rt.r[2] = abi.read32(0x0801E094);
            abi.setRegNz(&rt.r[7], 0x68);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[6], rt.r[5], true);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[4], 0x4, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            if (!abi.call(func_0801E038, 0x0801E0A7)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[5], 0x3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 10;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[7]);
            continue :blk 11;
        },
        9 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[4], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[7]);
            continue :blk 11;
        },
        10 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 12;
        },
        11 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1B);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 13;
        },
        12 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        13 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 12;
        },
        else => unreachable,
    }
}

pub fn func_0801E8DE() callconv(.c) void {
    if (!abi.enter(0x0801E8DE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_7.func_08023D54, 0x0801E8E9)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 2;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 6;
        },
        5 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.r[2] = abi.read32(0x0801E930);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.r[0] +%= rt.r[8];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(8);
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(15);
            rt.r[0] = abi.read32(0x0801E934);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x10, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 6;
        },
        else => unreachable,
    }
}

pub fn func_0801EF00() callconv(.c) void {
    if (!abi.enter(0x0801EF00)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[7], 16));
            if (!abi.call(low_peel_10.func_0801EB68, 0x0801EF13)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(20);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read32(0x0801EF58);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            rt.r[2] +%= rt.r[9];
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.r[2] = abi.read32(0x0801EF5C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0xE0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[3] = rt.r[10];
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            continue :blk 0;
        },
        4 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 9);
            rt.r[1] +%= rt.r[8];
            abi.setRegNz(&rt.r[3], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0801EF50);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
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
        6 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            rt.r[8] = rt.r[3];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(8);
            rt.r[5] = abi.read32(0x0801EF50);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[3], 16));
            abi.setRegNz(&rt.r[2], rt.r[6] << 1);
            rt.r[9] = rt.r[2];
            rt.r[3] = abi.read32(rt.r[13] +% 0x4);
            abi.setRegNz(&rt.r[7], rt.r[3] << 16);
            continue :blk 3;
        },
        else => unreachable,
    }
}

pub fn func_0801F302() callconv(.c) void {
    if (!abi.enter(0x0801F302)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(16);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[2] = rt.r[8];
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.r[7] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.r[7] = abi.read32(0x0801F344);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[7], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read32(0x0801F348);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            continue :blk 0;
        },
        2 => {
            abi.fetches(8);
            rt.r[2] = rt.r[12];
            rt.r[1] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x1, true);
            rt.r[12] = rt.r[7];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.r[5] = abi.read32(0x0801F334);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            rt.r[6] = rt.r[10];
            rt.r[0] = abi.read32(0x0801F340);
            rt.r[8] = rt.r[0];
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0801F75C() callconv(.c) void {
    if (!abi.enter(0x0801F75C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(28);
            rt.r[0] = abi.read32(0x0801F7AC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[2], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 20));
            rt.r[3] = abi.read16(rt.r[1] +% 0xC);
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[4] = abi.read16(rt.r[1] +% 0x6);
            abi.setRegNz(&rt.r[3], rt.r[4] << 16);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[3], 20));
            rt.r[1] = abi.read16(rt.r[1] +% 0xE);
            rt.cpuSub(&rt.r[1], rt.r[3], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.r[5] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            rt.cpuAdd(&rt.r[3], rt.r[4], rt.r[3], true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            if (!abi.call(low_peel_10.func_0802162C, 0x0801F795)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[5], rt.r[4] >> 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuSub(null, rt.r[4], 0xF, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(low_peel_1.func_08011834, 0x0801F7A5)) return;
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

pub fn func_0801FA94() callconv(.c) void {
    if (!abi.enter(0x0801FA94)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(low_peel_3.func_0800FD10, 0x0801FA9B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 21);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
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
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0801FAC4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x32);
            if (!math.modUnsigned32Call(0x0801FAB5)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x11, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x11, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0801FAE0);
            continue :blk 9;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x19, true);
            if (rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        9 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0801FAF8);
            abi.setRegNz(&rt.r[2], 0xD0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 4);
            if (!dma.copyAutoAbiCall(0x0801FAF1)) return;
            continue :blk 14;
        },
        10 => {
            abi.fetches(3);
            continue :blk 2;
        },
        11 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0801FAD8);
            continue :blk 9;
        },
        12 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2A, true);
            if (rt.CPU_Z) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        13 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0801FAF4);
            continue :blk 9;
        },
        14 => {
            abi.fetches(3);
            continue :blk 2;
        },
        15 => {
            abi.fetches(3);
            continue :blk 2;
        },
        16 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0801FB0C);
            rt.r[1] = abi.read32(0x0801FB10);
            continue :blk 17;
        },
        17 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0xD0);
            continue :blk 18;
        },
        18 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], rt.r[2] << 4);
            if (!dma.copyAutoAbiCall(0x0801FB09)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0801FCF2() callconv(.c) void {
    if (!abi.enter(0x0801FCF2)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x68, true);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1C);
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[13] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0801FD30);
            rt.r[2] = abi.read32(rt.r[13] +% 0x8);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x76, true);
            continue :blk 8;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x3, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            continue :blk 8;
        },
        7 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x68, true);
            rt.r[2] = abi.read32(rt.r[13] +% 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(11);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[13] +%= 0x14;
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

pub fn func_0801FCF6() callconv(.c) void {
    if (!abi.enter(0x0801FCF6)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1C);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[13] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0801FD30);
            rt.r[2] = abi.read32(rt.r[13] +% 0x8);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x76, true);
            continue :blk 7;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x3, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            continue :blk 7;
        },
        6 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x68, true);
            rt.r[2] = abi.read32(rt.r[13] +% 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(11);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[13] +%= 0x14;
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

comptime {
    if (!builtin.is_test) {
        @export(&func_0800028C, .{ .name = "func_0800028C", .linkage = .strong });
        @export(&func_080002F4, .{ .name = "func_080002F4", .linkage = .strong });
        @export(&func_08000802, .{ .name = "func_08000802", .linkage = .strong });
        @export(&func_08000874, .{ .name = "func_08000874", .linkage = .strong });
        @export(&func_080008E4, .{ .name = "func_080008E4", .linkage = .strong });
        @export(&func_08000A74, .{ .name = "func_08000A74", .linkage = .strong });
        @export(&func_08000DAC, .{ .name = "func_08000DAC", .linkage = .strong });
        @export(&func_080011E4, .{ .name = "func_080011E4", .linkage = .strong });
        @export(&func_08001924, .{ .name = "func_08001924", .linkage = .strong });
        @export(&func_08002B50, .{ .name = "func_08002B50", .linkage = .strong });
        @export(&func_08002DEC, .{ .name = "func_08002DEC", .linkage = .strong });
        @export(&func_08003332, .{ .name = "func_08003332", .linkage = .strong });
        @export(&func_080033CC, .{ .name = "func_080033CC", .linkage = .strong });
        @export(&func_08003402, .{ .name = "func_08003402", .linkage = .strong });
        @export(&func_08003444, .{ .name = "func_08003444", .linkage = .strong });
        @export(&func_080035CC, .{ .name = "func_080035CC", .linkage = .strong });
        @export(&func_08003630, .{ .name = "func_08003630", .linkage = .strong });
        @export(&func_08003C70, .{ .name = "func_08003C70", .linkage = .strong });
        @export(&func_08004554, .{ .name = "func_08004554", .linkage = .strong });
        @export(&func_08004668, .{ .name = "func_08004668", .linkage = .strong });
        @export(&func_08004B20, .{ .name = "func_08004B20", .linkage = .strong });
        @export(&func_08004B8C, .{ .name = "func_08004B8C", .linkage = .strong });
        @export(&func_08004BF4, .{ .name = "func_08004BF4", .linkage = .strong });
        @export(&func_08004C8C, .{ .name = "func_08004C8C", .linkage = .strong });
        @export(&func_08004CCC, .{ .name = "func_08004CCC", .linkage = .strong });
        @export(&func_08004D0C, .{ .name = "func_08004D0C", .linkage = .strong });
        @export(&func_08005300, .{ .name = "func_08005300", .linkage = .strong });
        @export(&func_08005302, .{ .name = "func_08005302", .linkage = .strong });
        @export(&func_0800537C, .{ .name = "func_0800537C", .linkage = .strong });
        @export(&func_080053F8, .{ .name = "func_080053F8", .linkage = .strong });
        @export(&func_080056A0, .{ .name = "func_080056A0", .linkage = .strong });
        @export(&func_080076A8, .{ .name = "func_080076A8", .linkage = .strong });
        @export(&func_0800775A, .{ .name = "func_0800775A", .linkage = .strong });
        @export(&func_08007890, .{ .name = "func_08007890", .linkage = .strong });
        @export(&func_080078E0, .{ .name = "func_080078E0", .linkage = .strong });
        @export(&func_08007AA8, .{ .name = "func_08007AA8", .linkage = .strong });
        @export(&func_08007BB6, .{ .name = "func_08007BB6", .linkage = .strong });
        @export(&func_08007C3C, .{ .name = "func_08007C3C", .linkage = .strong });
        @export(&func_08007C90, .{ .name = "func_08007C90", .linkage = .strong });
        @export(&func_08008398, .{ .name = "func_08008398", .linkage = .strong });
        @export(&func_08008708, .{ .name = "func_08008708", .linkage = .strong });
        @export(&func_080087A4, .{ .name = "func_080087A4", .linkage = .strong });
        @export(&func_0800889C, .{ .name = "func_0800889C", .linkage = .strong });
        @export(&func_080088F8, .{ .name = "func_080088F8", .linkage = .strong });
        @export(&func_080088FE, .{ .name = "func_080088FE", .linkage = .strong });
        @export(&func_080090B4, .{ .name = "func_080090B4", .linkage = .strong });
        @export(&func_080092E4, .{ .name = "func_080092E4", .linkage = .strong });
        @export(&func_080096F4, .{ .name = "func_080096F4", .linkage = .strong });
        @export(&func_0800AA34, .{ .name = "func_0800AA34", .linkage = .strong });
        @export(&func_0800AA84, .{ .name = "func_0800AA84", .linkage = .strong });
        @export(&func_0800AD0C, .{ .name = "func_0800AD0C", .linkage = .strong });
        @export(&func_0800B0D0, .{ .name = "func_0800B0D0", .linkage = .strong });
        @export(&func_0800C044, .{ .name = "func_0800C044", .linkage = .strong });
        @export(&func_0800C1BC, .{ .name = "func_0800C1BC", .linkage = .strong });
        @export(&func_0800C230, .{ .name = "func_0800C230", .linkage = .strong });
        @export(&func_0800C278, .{ .name = "func_0800C278", .linkage = .strong });
        @export(&func_0800C374, .{ .name = "func_0800C374", .linkage = .strong });
        @export(&func_0800E208, .{ .name = "func_0800E208", .linkage = .strong });
        @export(&func_0800E5B8, .{ .name = "func_0800E5B8", .linkage = .strong });
        @export(&func_0800E620, .{ .name = "func_0800E620", .linkage = .strong });
        @export(&func_0800E69C, .{ .name = "func_0800E69C", .linkage = .strong });
        @export(&func_0800EA02, .{ .name = "func_0800EA02", .linkage = .strong });
        @export(&func_0800EE54, .{ .name = "func_0800EE54", .linkage = .strong });
        @export(&func_0800EEA4, .{ .name = "func_0800EEA4", .linkage = .strong });
        @export(&func_0800EEF4, .{ .name = "func_0800EEF4", .linkage = .strong });
        @export(&func_0800EF02, .{ .name = "func_0800EF02", .linkage = .strong });
        @export(&func_0800EF10, .{ .name = "func_0800EF10", .linkage = .strong });
        @export(&func_0800F016, .{ .name = "func_0800F016", .linkage = .strong });
        @export(&func_0800F0CC, .{ .name = "func_0800F0CC", .linkage = .strong });
        @export(&func_0800F108, .{ .name = "func_0800F108", .linkage = .strong });
        @export(&func_0800F1D8, .{ .name = "func_0800F1D8", .linkage = .strong });
        @export(&func_0800F1F4, .{ .name = "func_0800F1F4", .linkage = .strong });
        @export(&func_0800F24C, .{ .name = "func_0800F24C", .linkage = .strong });
        @export(&func_0800F2C4, .{ .name = "func_0800F2C4", .linkage = .strong });
        @export(&func_0800F338, .{ .name = "func_0800F338", .linkage = .strong });
        @export(&func_0800F50C, .{ .name = "func_0800F50C", .linkage = .strong });
        @export(&func_0800F58C, .{ .name = "func_0800F58C", .linkage = .strong });
        @export(&func_0800F754, .{ .name = "func_0800F754", .linkage = .strong });
        @export(&func_0800F8B0, .{ .name = "func_0800F8B0", .linkage = .strong });
        @export(&func_0800FADC, .{ .name = "func_0800FADC", .linkage = .strong });
        @export(&func_0800FB0C, .{ .name = "func_0800FB0C", .linkage = .strong });
        @export(&func_0800FB58, .{ .name = "func_0800FB58", .linkage = .strong });
        @export(&func_0800FC18, .{ .name = "func_0800FC18", .linkage = .strong });
        @export(&func_0800FE64, .{ .name = "func_0800FE64", .linkage = .strong });
        @export(&func_0800FED0, .{ .name = "func_0800FED0", .linkage = .strong });
        @export(&func_0800FF3C, .{ .name = "func_0800FF3C", .linkage = .strong });
        @export(&func_08010044, .{ .name = "func_08010044", .linkage = .strong });
        @export(&func_080100C4, .{ .name = "func_080100C4", .linkage = .strong });
        @export(&func_080102F8, .{ .name = "func_080102F8", .linkage = .strong });
        @export(&func_080103C0, .{ .name = "func_080103C0", .linkage = .strong });
        @export(&func_08010574, .{ .name = "func_08010574", .linkage = .strong });
        @export(&func_08010974, .{ .name = "func_08010974", .linkage = .strong });
        @export(&func_08010C18, .{ .name = "func_08010C18", .linkage = .strong });
        @export(&func_080111A8, .{ .name = "func_080111A8", .linkage = .strong });
        @export(&func_080114B0, .{ .name = "func_080114B0", .linkage = .strong });
        @export(&func_0801153C, .{ .name = "func_0801153C", .linkage = .strong });
        @export(&func_080115C4, .{ .name = "func_080115C4", .linkage = .strong });
        @export(&func_08011660, .{ .name = "func_08011660", .linkage = .strong });
        @export(&func_08012480, .{ .name = "func_08012480", .linkage = .strong });
        @export(&func_0801272C, .{ .name = "func_0801272C", .linkage = .strong });
        @export(&func_08012B04, .{ .name = "func_08012B04", .linkage = .strong });
        @export(&func_08012B58, .{ .name = "func_08012B58", .linkage = .strong });
        @export(&func_08012C7C, .{ .name = "func_08012C7C", .linkage = .strong });
        @export(&func_08012DB0, .{ .name = "func_08012DB0", .linkage = .strong });
        @export(&func_08012EE0, .{ .name = "func_08012EE0", .linkage = .strong });
        @export(&func_08013000, .{ .name = "func_08013000", .linkage = .strong });
        @export(&func_0801320C, .{ .name = "func_0801320C", .linkage = .strong });
        @export(&func_08013248, .{ .name = "func_08013248", .linkage = .strong });
        @export(&func_0801329C, .{ .name = "func_0801329C", .linkage = .strong });
        @export(&func_080132D8, .{ .name = "func_080132D8", .linkage = .strong });
        @export(&func_080138F8, .{ .name = "func_080138F8", .linkage = .strong });
        @export(&func_08013938, .{ .name = "func_08013938", .linkage = .strong });
        @export(&func_08013CC4, .{ .name = "func_08013CC4", .linkage = .strong });
        @export(&func_08013D64, .{ .name = "func_08013D64", .linkage = .strong });
        @export(&func_08013F04, .{ .name = "func_08013F04", .linkage = .strong });
        @export(&func_08014DA4, .{ .name = "func_08014DA4", .linkage = .strong });
        @export(&func_08014F1C, .{ .name = "func_08014F1C", .linkage = .strong });
        @export(&func_08015344, .{ .name = "func_08015344", .linkage = .strong });
        @export(&func_0801574C, .{ .name = "func_0801574C", .linkage = .strong });
        @export(&func_080157E6, .{ .name = "func_080157E6", .linkage = .strong });
        @export(&func_08015824, .{ .name = "func_08015824", .linkage = .strong });
        @export(&func_08015874, .{ .name = "func_08015874", .linkage = .strong });
        @export(&func_08015AB0, .{ .name = "func_08015AB0", .linkage = .strong });
        @export(&func_08015AFC, .{ .name = "func_08015AFC", .linkage = .strong });
        @export(&func_08015E3C, .{ .name = "func_08015E3C", .linkage = .strong });
        @export(&func_08015EF8, .{ .name = "func_08015EF8", .linkage = .strong });
        @export(&func_08015F44, .{ .name = "func_08015F44", .linkage = .strong });
        @export(&func_08016008, .{ .name = "func_08016008", .linkage = .strong });
        @export(&func_08016F68, .{ .name = "func_08016F68", .linkage = .strong });
        @export(&func_0801701C, .{ .name = "func_0801701C", .linkage = .strong });
        @export(&func_0801728C, .{ .name = "func_0801728C", .linkage = .strong });
        @export(&func_08017370, .{ .name = "func_08017370", .linkage = .strong });
        @export(&func_080173C0, .{ .name = "func_080173C0", .linkage = .strong });
        @export(&func_08017430, .{ .name = "func_08017430", .linkage = .strong });
        @export(&func_08017500, .{ .name = "func_08017500", .linkage = .strong });
        @export(&func_08017560, .{ .name = "func_08017560", .linkage = .strong });
        @export(&func_080175C8, .{ .name = "func_080175C8", .linkage = .strong });
        @export(&func_08017928, .{ .name = "func_08017928", .linkage = .strong });
        @export(&func_080179B4, .{ .name = "func_080179B4", .linkage = .strong });
        @export(&func_08017BC0, .{ .name = "func_08017BC0", .linkage = .strong });
        @export(&func_08017CDC, .{ .name = "func_08017CDC", .linkage = .strong });
        @export(&func_08017E54, .{ .name = "func_08017E54", .linkage = .strong });
        @export(&func_08017EB8, .{ .name = "func_08017EB8", .linkage = .strong });
        @export(&func_08018098, .{ .name = "func_08018098", .linkage = .strong });
        @export(&func_08018184, .{ .name = "func_08018184", .linkage = .strong });
        @export(&func_080183C0, .{ .name = "func_080183C0", .linkage = .strong });
        @export(&func_08018400, .{ .name = "func_08018400", .linkage = .strong });
        @export(&func_0801844C, .{ .name = "func_0801844C", .linkage = .strong });
        @export(&func_080184B8, .{ .name = "func_080184B8", .linkage = .strong });
        @export(&func_080185C8, .{ .name = "func_080185C8", .linkage = .strong });
        @export(&func_080186AC, .{ .name = "func_080186AC", .linkage = .strong });
        @export(&func_08018734, .{ .name = "func_08018734", .linkage = .strong });
        @export(&func_08018D84, .{ .name = "func_08018D84", .linkage = .strong });
        @export(&func_0801912C, .{ .name = "func_0801912C", .linkage = .strong });
        @export(&func_08019288, .{ .name = "func_08019288", .linkage = .strong });
        @export(&func_08019640, .{ .name = "func_08019640", .linkage = .strong });
        @export(&func_08019678, .{ .name = "func_08019678", .linkage = .strong });
        @export(&func_0801977C, .{ .name = "func_0801977C", .linkage = .strong });
        @export(&func_0801990C, .{ .name = "func_0801990C", .linkage = .strong });
        @export(&func_08019A6C, .{ .name = "func_08019A6C", .linkage = .strong });
        @export(&func_08019ABC, .{ .name = "func_08019ABC", .linkage = .strong });
        @export(&func_08019F18, .{ .name = "func_08019F18", .linkage = .strong });
        @export(&func_08019FD8, .{ .name = "func_08019FD8", .linkage = .strong });
        @export(&func_0801A0A8, .{ .name = "func_0801A0A8", .linkage = .strong });
        @export(&func_0801A218, .{ .name = "func_0801A218", .linkage = .strong });
        @export(&func_0801A33C, .{ .name = "func_0801A33C", .linkage = .strong });
        @export(&func_0801A38C, .{ .name = "func_0801A38C", .linkage = .strong });
        @export(&func_0801A61C, .{ .name = "func_0801A61C", .linkage = .strong });
        @export(&func_0801A6F0, .{ .name = "func_0801A6F0", .linkage = .strong });
        @export(&func_0801ABC0, .{ .name = "func_0801ABC0", .linkage = .strong });
        @export(&func_0801AD38, .{ .name = "func_0801AD38", .linkage = .strong });
        @export(&func_0801AFEC, .{ .name = "func_0801AFEC", .linkage = .strong });
        @export(&func_0801AFFE, .{ .name = "func_0801AFFE", .linkage = .strong });
        @export(&func_0801B01C, .{ .name = "func_0801B01C", .linkage = .strong });
        @export(&func_0801B070, .{ .name = "func_0801B070", .linkage = .strong });
        @export(&func_0801B4F8, .{ .name = "func_0801B4F8", .linkage = .strong });
        @export(&func_0801B6B8, .{ .name = "func_0801B6B8", .linkage = .strong });
        @export(&func_0801B758, .{ .name = "func_0801B758", .linkage = .strong });
        @export(&func_0801BA08, .{ .name = "func_0801BA08", .linkage = .strong });
        @export(&func_0801BD28, .{ .name = "func_0801BD28", .linkage = .strong });
        @export(&func_0801BD84, .{ .name = "func_0801BD84", .linkage = .strong });
        @export(&func_0801BF68, .{ .name = "func_0801BF68", .linkage = .strong });
        @export(&func_0801C018, .{ .name = "func_0801C018", .linkage = .strong });
        @export(&func_0801C0A4, .{ .name = "func_0801C0A4", .linkage = .strong });
        @export(&func_0801C1CC, .{ .name = "func_0801C1CC", .linkage = .strong });
        @export(&func_0801C35C, .{ .name = "func_0801C35C", .linkage = .strong });
        @export(&func_0801D148, .{ .name = "func_0801D148", .linkage = .strong });
        @export(&func_0801D1B4, .{ .name = "func_0801D1B4", .linkage = .strong });
        @export(&func_0801DBCC, .{ .name = "func_0801DBCC", .linkage = .strong });
        @export(&func_0801DE0C, .{ .name = "func_0801DE0C", .linkage = .strong });
        @export(&func_0801DEB8, .{ .name = "func_0801DEB8", .linkage = .strong });
        @export(&func_0801E038, .{ .name = "func_0801E038", .linkage = .strong });
        @export(&func_0801E07C, .{ .name = "func_0801E07C", .linkage = .strong });
        @export(&func_0801E8DE, .{ .name = "func_0801E8DE", .linkage = .strong });
        @export(&func_0801EF00, .{ .name = "func_0801EF00", .linkage = .strong });
        @export(&func_0801F302, .{ .name = "func_0801F302", .linkage = .strong });
        @export(&func_0801F75C, .{ .name = "func_0801F75C", .linkage = .strong });
        @export(&func_0801FA94, .{ .name = "func_0801FA94", .linkage = .strong });
        @export(&func_0801FCF2, .{ .name = "func_0801FCF2", .linkage = .strong });
        @export(&func_0801FCF6, .{ .name = "func_0801FCF6", .linkage = .strong });
    }
}

test "low_peel_6 exports are callable" {
    try std.testing.expect(@TypeOf(func_0800028C) == fn () callconv(.c) void);
    try std.testing.expect(@TypeOf(func_0801FCF6) == fn () callconv(.c) void);
}
