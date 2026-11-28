//! Remaining closed low-ROM (`< 0x08080000`) shared-body `enter_*` clusters (Stage 41).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const abi = @import("abi.zig");
const bios = @import("bios.zig");
const clusters_low = @import("clusters_low.zig");
const dma = @import("dma.zig");
const hw = @import("hw.zig");
const low_peel_1 = @import("low_peel_1.zig");
const low_peel_13 = @import("low_peel_13.zig");
const low_peel_6 = @import("low_peel_6.zig");
const proc = @import("proc.zig");
const sprite_anim = @import("sprite_anim.zig");
const state = @import("state.zig");
const tail_low = @import("tail_low.zig");

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

// === COMP [1] funcs=22 enters=14 lines=1719 ===
pub fn func_0800F164() callconv(.c) void {
    if (!abi.enter(0x0800F164)) return;
    enter_0800F164(0);
}

pub fn func_0800FBC4() callconv(.c) void {
    if (!abi.enter(0x0800FBC4)) return;
    enter_0800FBC4(0);
}

pub fn func_0800FC58() callconv(.c) void {
    if (!abi.enter(0x0800FC58)) return;
    enter_0800FC58(0);
}

pub fn func_0800FD54() callconv(.c) void {
    if (!abi.enter(0x0800FD54)) return;
    enter_0800FD54(0);
}

pub fn func_08010A00() callconv(.c) void {
    if (!abi.enter(0x08010A00)) return;
    enter_08010A00(0);
}

pub fn func_0801114C() callconv(.c) void {
    if (!abi.enter(0x0801114C)) return;
    enter_0801114C(0);
}

pub fn func_080130A0() callconv(.c) void {
    if (!abi.enter(0x080130A0)) return;
    enter_080130A0(0);
}

pub fn func_080130BE() callconv(.c) void {
    if (!abi.enter(0x080130BE)) return;
    enter_080130A0(2);
}

pub fn func_080134D4() callconv(.c) void {
    if (!abi.enter(0x080134D4)) return;
    enter_080134D4(0);
}

pub fn func_080139D4() callconv(.c) void {
    if (!abi.enter(0x080139D4)) return;
    enter_080139D4(0);
}

pub fn func_080149E0() callconv(.c) void {
    if (!abi.enter(0x080149E0)) return;
    enter_080149E0(0);
}

pub fn func_08018290() callconv(.c) void {
    if (!abi.enter(0x08018290)) return;
    enter_08018290(0);
}

pub fn func_0801A69C() callconv(.c) void {
    if (!abi.enter(0x0801A69C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[5] = abi.read32(0x0801A6D0);
            rt.r[4] = abi.read32(0x0801A6D4);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], 0x80, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            enter_080134D4(4); return;
        },
        else => unreachable,
    }
}

pub fn func_0801B700() callconv(.c) void {
    if (!abi.enter(0x0801B700)) return;
    enter_0801B700(0);
}

pub fn func_0801F114() callconv(.c) void {
    if (!abi.enter(0x0801F114)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x0801F134);
            rt.r[0] = abi.read32(0x0801F138);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[4] = abi.read32(0x0801F13C);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], rt.r[4], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            enter_080149E0(4); return;
        },
        else => unreachable,
    }
}

pub fn func_08034BA8() callconv(.c) void {
    if (!abi.enter(0x08034BA8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(43);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[0] = abi.read32(0x08034C44);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            rt.r[0] = abi.read32(0x08034C48);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            rt.r[6] = abi.read32(0x08034C4C);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x39, true);
            abi.setRegNz(&rt.r[7], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[7]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[7]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[7]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[7]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x8, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[7]));
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x35, true);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[5], 0x3);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x37, true);
            abi.setRegNz(&rt.r[1], 0x4);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x7, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[7]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            if (!abi.call(state.func_08024EC4, 0x08034BFB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(35);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x30, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.write32(rt.r[6] +% 0x28, rt.r[0]);
            abi.write32(rt.r[6] +% 0x24, rt.r[4]);
            abi.write32(rt.r[6] +% 0x14, rt.r[4]);
            abi.write32(rt.r[6] +% 0x18, rt.r[4]);
            abi.write32(rt.r[6] +% 0x1C, rt.r[4]);
            abi.write32(rt.r[6] +% 0x20, rt.r[4]);
            abi.write8(rt.r[6] +% 0xD, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2F, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x3, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            abi.write8(rt.r[6] +% 0x4, @truncate(rt.r[5]));
            abi.write8(rt.r[6] +% 0x5, @truncate(rt.r[7]));
            abi.write8(rt.r[6] +% 0x6, @truncate(rt.r[4]));
            abi.write8(rt.r[6] +% 0x8, @truncate(rt.r[7]));
            rt.r[0] = abi.read32(0x08034C50);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1A);
            abi.write8(rt.r[6] +% 0x9, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[6] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                enter_080134D4(6); return;
            }
            enter_080134D4(5); return;
        },
        else => unreachable,
    }
}

pub fn func_08036464() callconv(.c) void {
    if (!abi.enter(0x08036464)) return;
    enter_08036464(0);
}

pub fn func_08077EB0() callconv(.c) void {
    if (!abi.enter(0x08077EB0)) return;
    abi.fetches(8);
    pushRegs(&.{ 4, 5, 6, 14 });
    rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
    rt.r[1] = abi.read8(rt.r[5] +% 0x0);
    abi.setRegNz(&rt.r[0], 0x80);
    rt.updateNz(rt.r[0] & rt.r[1]);
    if (rt.CPU_Z) {
        enter_0800FBC4(11); return;
    }
    enter_0800FBC4(10); return;
}

pub fn func_08078424() callconv(.c) void {
    if (!abi.enter(0x08078424)) return;
    abi.fetches(8);
    pushRegs(&.{ 4, 5, 14 });
    rt.r[0] = abi.read32(0x08078448);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
    rt.cpuSub(null, rt.r[0], 0x0, true);
    if (rt.CPU_Z) {
        enter_080139D4(6); return;
    }
    enter_080139D4(3); return;
}

pub fn func_08078A9C() callconv(.c) void {
    if (!abi.enter(0x08078A9C)) return;
    abi.fetches(8);
    pushRegs(&.{ 4, 5, 6, 14 });
    rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
    rt.r[1] = abi.read32(rt.r[6] +% 0x34);
    rt.r[0] = abi.read32(0x08078AD8);
    rt.cpuSub(null, rt.r[1], rt.r[0], true);
    if (!rt.CPU_Z) {
        enter_080134D4(9); return;
    }
    enter_080134D4(8); return;
}

fn enter_0800F164(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0800F16C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.recompReturn(rt.r[14]); return;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[4]));
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[4]));
            if (!abi.call(proc.func_08016F18, 0x080182E7)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(state.func_08016F44, 0x080182EB)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(proc.func_08016FA8, 0x080182EF)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x08018328);
            abi.setRegNz(&rt.r[1], 0x8);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[4]));
            abi.write8(rt.r[0] +% 0x2, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(0x0801832C);
            rt.r[1] = abi.read32(0x08018330);
            abi.setRegNz(&rt.r[4], 0x80);
            abi.setRegNz(&rt.r[4], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(dma.func_0800FDA4, 0x08018307)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08018334);
            rt.r[1] = abi.read32(0x08018338);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(dma.func_0800FDA4, 0x08018311)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xB4);
            rt.cpuSub(&rt.r[1], rt.r[0], rt.r[1], true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0xB3, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                enter_0801114C(4); return;
            }
            enter_0801114C(3); return;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x1);
            abi.setRegNz(&rt.r[4], rt.r[4] << 28);
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if (rt.CPU_C) {
                enter_0801114C(6); return;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_C) {
                enter_0801114C(6); return;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            abi.setRegNz(&rt.r[3], rt.r[3] << 4);
            continue :blk 10;
        },
        13 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.r[4] = rt.r[12];
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_N) {
                enter_0801114C(8); return;
            }
            enter_0801114C(7); return;
        },
        else => unreachable,
    }
}

fn enter_0800FBC4(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0800FBE4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[3] = abi.read32(0x0800FBE8);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        3 => {
            abi.fetches(4);
            rt.r[6] = abi.read32(0x08013A3C);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(tail_low.func_0807B450, 0x08013A2B)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            enter_080139D4(2); return;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            enter_08018290(4); return;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(low_peel_6.func_0801B6B8, 0x0801B73B)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[1], rt.r[4] << 12);
            rt.r[0] = abi.read32(0x0801B754);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(low_peel_1.func_0801B7F4, 0x0801B74B)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            enter_08018290(4); return;
        },
        10 => {
            abi.fetches(5);
            rt.r[4] = abi.read32(rt.r[5] +% 0x20);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                enter_08018290(6); return;
            }
            enter_08018290(5); return;
        },
        11 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn enter_0800FC58(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[3] = abi.read32(0x0800FC70);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                enter_080139D4(2); return;
            }
            enter_0800FBC4(3); return;
        },
        4 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0801B728);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(tail_low.func_0807B454, 0x0801B71F)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            enter_08018290(4); return;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                enter_0800FBC4(7); return;
            }
            enter_0800FBC4(6); return;
        },
        else => unreachable,
    }
}

fn enter_0800FD54(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[1] = abi.read32(0x0800FD8C);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[4] = abi.read32(0x0800FD90);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[4], 0x4, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            rt.r[0] = abi.read16(rt.r[1] +% 0x8);
            abi.write16(rt.r[1] +% 0x8, @truncate(rt.r[3]));
            rt.r[0] = abi.read8(rt.r[1] +% 0xA);
            abi.write8(rt.r[1] +% 0xA, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[2], 0x2F, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                enter_080139D4(2); return;
            }
            enter_0800FC58(3); return;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(sprite_anim.func_08014B3C, 0x08014A1B)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(clusters_low.func_08014AF0, 0x08014A1F)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(func_08077EB0, 0x08078AC7)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x50, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08078AD8);
            abi.write32(rt.r[6] +% 0x34, rt.r[0]);
            enter_080134D4(9); return;
        },
        else => unreachable,
    }
}

fn enter_08010A00(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08010A0C);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.recompReturn(rt.r[14]); return;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if (rt.CPU_C) {
                continue :blk 4;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_C) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.setRegNz(&rt.r[3], rt.r[3] << 1);
            continue :blk 1;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_C) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[3]);
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 1);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_C) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[4], rt.r[3] >> 1);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[4]);
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 2);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_C) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[4], rt.r[3] >> 2);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[4]);
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 3);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_C) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[4], rt.r[3] >> 3);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[4]);
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                enter_0800F164(13); return;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 4);
            if (rt.CPU_Z) {
                enter_0800F164(13); return;
            }
            continue :blk 14;
        },
        14 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 4);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn enter_0801114C(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[1] = abi.read32(0x08011198);
            abi.setRegNz(&rt.r[0], 0xA);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.r[1] = abi.read32(0x0801119C);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[5] = abi.read32(0x080111A0);
            rt.r[4] = abi.read32(0x080111A4);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x50, true);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(23);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write16(rt.r[0] +% 0x6, @truncate(rt.r[2]));
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[2]));
            abi.write16(rt.r[0] +% 0x10, @truncate(rt.r[2]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[2]));
            abi.write16(rt.r[0] +% 0xE, @truncate(rt.r[2]));
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[2]));
            abi.write16(rt.r[0] +% 0xC, @truncate(rt.r[2]));
            abi.write16(rt.r[0] +% 0xA, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.write32(rt.r[5] +% 0x0, rt.r[4]);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            continue :blk 5;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], rt.r[4] << 3);
            enter_08010A00(1); return;
        },
        7 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            popRegsSeq(&.{ 4 });
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn enter_080130A0(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[4] = abi.read32(0x080130C8);
            rt.r[3] = abi.read32(0x080130CC);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0x27, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[5] = abi.read32(0x0801831C);
            rt.r[6] = abi.read32(0x08018320);
            rt.r[3] = abi.read32(0x08018324);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], 0x9, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            enter_0800F164(1); return;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[4] +% 0x1);
            abi.setRegNz(&rt.r[3], 0x7);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.r[3] = abi.read32(0x08077EF0);
            rt.r[3] = abi.read32(rt.r[3] +% 0x0);
            rt.r[3] = abi.read32(rt.r[3] +% 0x2C);
            if (!abi.call(tail_low.func_08077EA0, 0x08077EDD)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[6]));
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            abi.write32(rt.r[4] +% 0x2C, rt.r[6]);
            rt.r[4] = abi.read32(rt.r[4] +% 0x34);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            enter_08018290(6); return;
        },
        10 => {
            abi.fetches(3);
            rt.r[2] = abi.read32(0x0807AF1C);
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0xB3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                enter_08036464(3); return;
            }
            enter_08036464(2); return;
        },
        13 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            continue :blk 14;
        },
        14 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_N) {
                enter_08036464(5); return;
            }
            enter_08036464(4); return;
        },
        else => unreachable,
    }
}

fn enter_080134D4(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(clusters_low.func_0801A03C, 0x080134DB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x10, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                enter_080139D4(2); return;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                enter_080139D4(2); return;
            }
            enter_0800FD54(3); return;
        },
        4 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[4] +% 0x4, rt.r[0]);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.write32(rt.r[5] +% 0x4, rt.r[0]);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            enter_0801B700(1); return;
        },
        6 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08034C60);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x7, @truncate(rt.r[0]));
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.write32(rt.r[6] +% 0x34, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[6] +% 0x4);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write32(rt.r[6] +% 0x4, rt.r[0]);
            rt.r[4] = abi.read8(rt.r[6] +% 0x8);
            rt.r[5] = abi.read32(rt.r[6] +% 0x2C);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                enter_0800FD54(9); return;
            }
            enter_0800FD54(7); return;
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

fn enter_080139D4(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.r[3] = abi.read32(0x08013A38);
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[2], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                enter_080134D4(3); return;
            }
            enter_080134D4(2); return;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(4);
            rt.r[5] = abi.read32(0x0807844C);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(func_08078A9C, 0x0807843B)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0xC, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn enter_080149E0(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[0] = abi.read32(0x08014A24);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            if (!abi.call(func_0801A69C, 0x080149ED)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x08014A28);
            abi.setRegNz(&rt.r[0], 0x10);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08014A2C);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            abi.setRegNz(&rt.r[5], 0x80);
            abi.setRegNz(&rt.r[5], rt.r[5] << 1);
            rt.r[6] = abi.read32(0x08014A30);
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[6], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(sprite_anim.func_08014C98, 0x08014A11)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x1F, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            enter_0800FD54(4); return;
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

fn enter_08018290(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(state.func_08018AAC, 0x08018299)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(state.func_08018CB4, 0x0801829D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[3] = abi.read32(0x08018318);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], 0x9, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            enter_080130A0(3); return;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], 0x0);
            enter_080130A0(5); return;
        },
        6 => {
            abi.fetches(3);
            abi.write32(rt.r[5] +% 0x20, rt.r[4]);
            enter_0800FBC4(11); return;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xB4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0807AF18);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                enter_080130A0(12); return;
            }
            enter_080130A0(10); return;
        },
        10 => {
            abi.fetches(10);
            pushRegs(&.{ 4 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] ^ rt.r[1]);
            rt.r[12] = rt.r[4];
            abi.setRegNz(&rt.r[3], 0x1);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_N) {
                enter_080130A0(14); return;
            }
            enter_080130A0(13); return;
        },
        11 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(hw.func_0807B51C, 0x0807B517)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            popRegsSeq(&.{ 15 });
            rt.recompReturn(rt.r[15]); return;
        },
        else => unreachable,
    }
}

fn enter_0801B700(start_block: u32) void {
    switch (start_block) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x0801B724);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                enter_0800FC58(6); return;
            }
            enter_0800FC58(4); return;
        },
        1 => {
            abi.fetches(4);
            abi.write8(rt.r[6] +% 0x7, @truncate(rt.r[7]));
            enter_080134D4(7); return;
        },
        else => unreachable,
    }
}

fn enter_08035230(start_block: u32) void {
    blk: switch (start_block) {
        1 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08036498);
            abi.setRegNz(&rt.r[2], 0xC0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(dma.func_0800FFA8, 0x0803648B)) return;
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

fn enter_08036464(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[4] = abi.read32(0x08036490);
            rt.r[3] = abi.read32(0x08036494);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write8(rt.r[0] +% 0x8, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[1], 0x2, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            enter_08035230(1); return;
        },
        2 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[1], rt.r[1], 0xB4, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x5A, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                enter_0800F164(8); return;
            }
            enter_0800F164(7); return;
        },
        4 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_C) {
                enter_0800F164(13); return;
            }
            enter_0800F164(9); return;
        },
        else => unreachable,
    }
}

// === COMP [2] funcs=10 enters=6 lines=1235 ===
pub fn func_080303E0() callconv(.c) void {
    if (!abi.enter(0x080303E0)) return;
    enter_080303E0(0);
}

pub fn func_080303F4() callconv(.c) void {
    if (!abi.enter(0x080303F4)) return;
    enter_080303E0(1);
}

pub fn func_080304FE() callconv(.c) void {
    if (!abi.enter(0x080304FE)) return;
    enter_080303E0(10);
}

pub fn func_0803050A() callconv(.c) void {
    if (!abi.enter(0x0803050A)) return;
    enter_080303E0(12);
}

pub fn func_08030634() callconv(.c) void {
    if (!abi.enter(0x08030634)) return;
    enter_08030634(0);
}

pub fn func_08042E24() callconv(.c) void {
    if (!abi.enter(0x08042E24)) return;
    enter_08042E24(0);
}

pub fn func_08078258() callconv(.c) void {
    if (!abi.enter(0x08078258)) return;
    enter_08078258(0);
}

pub fn func_080784E0() callconv(.c) void {
    if (!abi.enter(0x080784E0)) return;
    enter_080784E0(0);
}

pub fn func_08078630() callconv(.c) void {
    if (!abi.enter(0x08078630)) return;
    enter_08078630(0);
}

pub fn func_080787CC() callconv(.c) void {
    if (!abi.enter(0x080787CC)) return;
    abi.fetches(10);
    pushRegs(&.{ 4, 5, 14 });
    rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
    rt.r[0] = abi.read32(0x08078858);
    rt.r[5] = abi.read32(rt.r[0] +% 0x0);
    rt.r[1] = abi.read32(rt.r[5] +% 0x0);
    rt.r[0] = abi.read32(0x0807885C);
    rt.cpuSub(null, rt.r[1], rt.r[0], true);
    if (!rt.CPU_Z) {
        enter_08078258(6); return;
    }
    enter_08078258(5); return;
}

fn enter_080303E0(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[0] = abi.read32(0x080305A0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.r[3] = abi.read32(0x080305A4);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(46);
            rt.r[2] = abi.read16(rt.r[0] +% 0x20);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[1]));
            rt.r[4] = abi.read16(rt.r[0] +% 0x22);
            abi.write16(rt.r[0] +% 0x22, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x080305A8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[7] = abi.read32(0x080305AC);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read32(0x080305B0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[7], rt.r[7], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1A);
            abi.write8(rt.r[0] +% 0x1A, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1B);
            abi.write8(rt.r[0] +% 0x1B, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1F);
            abi.write8(rt.r[0] +% 0x1F, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x080305B4);
            rt.r[9] = rt.r[0];
            rt.r[1] = abi.read32(0x080305B8);
            rt.r[10] = rt.r[1];
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[2] = abi.read32(0x080305BC);
            rt.r[8] = rt.r[2];
            rt.r[7] = abi.read32(0x080305C0);
            rt.r[12] = rt.r[7];
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(26);
            rt.r[1] = abi.read32(0x080305A4);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xA, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.r[2] = abi.read32(0x080305A4);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x16, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xE, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x24, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[5], 0x3F);
            continue :blk 3;
        },
        3 => {
            abi.fetches(14);
            rt.r[7] = rt.r[8];
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[7] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[7]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x8, true);
            rt.cpuSub(&rt.r[5], rt.r[5], 0x1, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(22);
            rt.r[0] = rt.r[8];
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x82);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[7]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = rt.r[9];
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[5] = abi.read32(0x080305C4);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[3] = abi.read32(0x080305A4);
            continue :blk 6;
        },
        6 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[5], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x7F, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(8);
            rt.r[7] = abi.read32(0x080305A4);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[6], 0x96);
            abi.setRegNz(&rt.r[6], rt.r[6] << 1);
            abi.setRegNz(&rt.r[5], 0x1F);
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[6], true);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            abi.setRegNz(&rt.r[4], 0x7F);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x85, true);
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x88, true);
            rt.cpuSub(&rt.r[5], rt.r[5], 0x1, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[7] = abi.read32(0x080305A4);
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[6] = abi.read32(0x080305C8);
            continue :blk 13;
        },
        13 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[5] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[4], 0x7F);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x85, true);
            continue :blk 14;
        },
        14 => {
            abi.fetches(7);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 14;
            }
            continue :blk 15;
        },
        15 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            rt.cpuSub(null, rt.r[5], 0xF, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 16;
        },
        16 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[2] = rt.r[10];
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.r[7] = abi.read32(0x080305CC);
            abi.write16(rt.r[7] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = abi.read32(0x080305D0);
            abi.setRegNz(&rt.r[4], 0x80);
            abi.setRegNz(&rt.r[4], rt.r[4] << 2);
            continue :blk 17;
        },
        17 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 17;
            }
            continue :blk 18;
        },
        18 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = abi.read32(0x080305D4);
            rt.r[9] = rt.r[0];
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[1] = abi.read32(0x080305D8);
            rt.r[12] = rt.r[1];
            rt.r[2] = abi.read32(0x080305DC);
            rt.r[8] = rt.r[2];
            rt.r[7] = abi.read32(0x080305E0);
            continue :blk 19;
        },
        19 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[2], rt.r[5] << 1);
            rt.r[0] = rt.r[9];
            rt.cpuAdd(&rt.r[3], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[7], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x1, true);
            rt.r[2] +%= rt.r[8];
            rt.r[4] = rt.r[12];
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 20;
        },
        20 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x8, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 20;
            }
            continue :blk 21;
        },
        21 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            rt.cpuSub(null, rt.r[5], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 19;
            }
            continue :blk 22;
        },
        22 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        23 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            abi.write8(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn enter_08030634(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[4] = abi.read32(0x080306F8);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[4] = abi.read32(0x080306FC);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[4] = abi.read32(0x08030700);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x16, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x080306F8);
            rt.r[12] = rt.r[0];
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[9] = rt.r[4];
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[3] = rt.r[12];
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x20, true);
            abi.setRegNz(&rt.r[5], 0x0);
            abi.setRegNz(&rt.r[7], 0x36);
            rt.r[7] +%= rt.r[12];
            rt.r[8] = rt.r[7];
            abi.setRegNz(&rt.r[1], 0xB);
            continue :blk 7;
        },
        7 => {
            abi.fetches(12);
            abi.write16(rt.r[3] +% 0x2, @truncate(rt.r[6]));
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[6]));
            rt.r[0] = rt.r[9];
            abi.write8(rt.r[3] +% 0x15, @truncate(rt.r[0]));
            abi.write8(rt.r[3] +% 0x1C, @truncate(rt.r[0]));
            abi.write8(rt.r[3] +% 0x1B, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[2], 0x10);
            rt.r[4] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x34, true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(7);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[2], 0x4);
            rt.r[7] = rt.r[8];
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[7], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
            continue :blk 10;
        },
        10 => {
            abi.fetches(7);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x20, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x20, true);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[6] = abi.read32(0x08030704);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[5], 0xD);
            continue :blk 13;
        },
        13 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[2], 0xC);
            continue :blk 14;
        },
        14 => {
            abi.fetches(8);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 14;
            }
            continue :blk 15;
        },
        15 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 16;
        },
        16 => {
            abi.fetches(8);
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        17 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x080782DC);
            rt.r[8] = rt.r[1];
            rt.r[5] = rt.r[8];
            abi.setRegNz(&rt.r[7], 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            continue :blk 18;
        },
        18 => {
            abi.fetches(11);
            rt.r[4] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = rt.r[8];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[0], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read8(rt.r[5] +% 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(clusters_low.func_08078970, 0x080782A7)) return;
            continue :blk 19;
        },
        19 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080782E0);
            abi.write32(rt.r[4] +% 0x18, rt.r[0]);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0xC, true);
            rt.cpuAdd(&rt.r[7], rt.r[7], 0xC, true);
            rt.cpuSub(&rt.r[6], rt.r[6], 0x1, true);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 18;
            }
            continue :blk 20;
        },
        20 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        21 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x080786EC);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 22;
        },
        22 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x080786F0);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                enter_080784E0(5); return;
            }
            enter_080784E0(4); return;
        },
        else => unreachable,
    }
}

fn enter_08042E24(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[1] = abi.read32(0x08042E58);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[5] = abi.read32(0x08042E5C);
            rt.r[6] = abi.read32(0x08042E60);
            rt.r[4] = abi.read32(0x08042E64);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[3] = abi.read32(0x08042E68);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0x8, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            enter_080303E0(23); return;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x7F);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[0]);
            abi.write8(rt.r[5] +% 0x5, @truncate(rt.r[4]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], 0xF0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 4);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[3]);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                enter_08078630(3); return;
            }
            enter_08078630(1); return;
        },
        else => unreachable,
    }
}

fn enter_08078258(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.r[0] = abi.read32(0x080782C0);
            abi.setRegNz(&rt.r[1], 0x2);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read32(0x080782C4);
            rt.r[2] = abi.read32(0x080782C8);
            if (!abi.call(bios.func_080796C4, 0x0807826F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080782CC);
            if (!abi.call(func_08078630, 0x08078275)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080782D0);
            if (!abi.call(func_080784E0, 0x0807827B)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080782D4);
            if (!abi.call(func_080787CC, 0x08078281)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080782D8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                enter_08030634(20); return;
            }
            enter_08030634(17); return;
        },
        5 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[4], 0xFF);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[3]);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                enter_08042E24(3); return;
            }
            enter_08042E24(2); return;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn enter_080784E0(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(37);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x080785AC);
            abi.setRegNz(&rt.r[0], 0x8F);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x080785B0);
            abi.setRegNz(&rt.r[0], 0x77);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080785B4);
            abi.setRegNz(&rt.r[1], 0x8);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x14, true);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x080785B8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080785BC);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080785C0);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            rt.r[6] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read32(0x080785C4);
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(42);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x1, true);
            abi.write32(rt.r[4] +% 0x0, rt.r[0]);
            rt.r[1] = abi.read32(0x080785C8);
            rt.r[0] = abi.read32(0x080785CC);
            abi.write32(rt.r[1] +% 0x20, rt.r[0]);
            rt.r[0] = abi.read32(0x080785D0);
            abi.write32(rt.r[1] +% 0x44, rt.r[0]);
            rt.r[0] = abi.read32(0x080785D4);
            abi.write32(rt.r[1] +% 0x4C, rt.r[0]);
            rt.r[0] = abi.read32(0x080785D8);
            abi.write32(rt.r[1] +% 0x70, rt.r[0]);
            rt.r[0] = abi.read32(0x080785DC);
            abi.write32(rt.r[1] +% 0x74, rt.r[0]);
            rt.r[0] = abi.read32(0x080785E0);
            abi.write32(rt.r[1] +% 0x78, rt.r[0]);
            rt.r[0] = abi.read32(0x080785E4);
            abi.write32(rt.r[1] +% 0x7C, rt.r[0]);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x80, true);
            rt.r[0] = abi.read32(0x080785E8);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x84, true);
            rt.r[0] = abi.read32(0x080785EC);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            abi.write32(rt.r[4] +% 0x1C, rt.r[5]);
            rt.r[0] = abi.read32(0x080785F0);
            abi.write32(rt.r[4] +% 0x28, rt.r[0]);
            rt.r[0] = abi.read32(0x080785F4);
            abi.write32(rt.r[4] +% 0x2C, rt.r[0]);
            rt.r[0] = abi.read32(0x080785F8);
            abi.write32(rt.r[4] +% 0x30, rt.r[0]);
            rt.r[0] = abi.read32(0x080785FC);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[4] +% 0xC, @truncate(rt.r[0]));
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            rt.r[2] = abi.read32(0x08078600);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(bios.func_080796C4, 0x08078577)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(25);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[5] +% 0x1, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x11);
            abi.write8(rt.r[5] +% 0x1C, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x41, true);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1B, true);
            abi.setRegNz(&rt.r[0], 0x22);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x25, true);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1B, true);
            abi.setRegNz(&rt.r[0], 0x44);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x24, true);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x88);
            abi.write8(rt.r[1] +% 0x1C, @truncate(rt.r[0]));
            abi.write32(rt.r[4] +% 0x0, rt.r[6]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x080786EC);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 5;
        },
        5 => {
            abi.fetches(47);
            rt.r[0] = abi.read32(0x080786F4);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xC, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x080786F8);
            abi.setRegNz(&rt.r[0], 0x8F);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[2] = abi.read32(0x080786FC);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x08078700);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x3F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x40);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08078704);
            abi.setRegNz(&rt.r[2], 0xD4);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[2], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.r[0] = abi.read32(0x08078708);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            abi.setRegNz(&rt.r[2], 0x98);
            abi.setRegNz(&rt.r[2], rt.r[2] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[2], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.r[0] = abi.read32(0x0807870C);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(0x08078710);
            abi.write32(rt.r[0] +% 0x0, rt.r[5]);
            abi.write32(rt.r[13] +% 0x0, rt.r[3]);
            rt.r[2] = abi.read32(0x08078714);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(bios.func_080796C4, 0x080786B5)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.write8(rt.r[5] +% 0x6, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xF);
            abi.write8(rt.r[5] +% 0x7, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08078718);
            abi.write32(rt.r[5] +% 0x38, rt.r[0]);
            rt.r[0] = abi.read32(0x0807871C);
            abi.write32(rt.r[5] +% 0x28, rt.r[0]);
            abi.write32(rt.r[5] +% 0x2C, rt.r[0]);
            abi.write32(rt.r[5] +% 0x30, rt.r[0]);
            abi.write32(rt.r[5] +% 0x3C, rt.r[0]);
            rt.r[4] = abi.read32(0x08078720);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(tail_low.func_08077A40, 0x080786D3)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            abi.write32(rt.r[5] +% 0x34, rt.r[4]);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 11);
            if (!abi.call(clusters_low.func_08078728, 0x080786DD)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08078724);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[4] >> 12);
            abi.write8(rt.r[5] +% 0x7, @truncate(rt.r[0]));
            continue :blk 10;
        },
        10 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], 0xB0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[3]);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], 0xC0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 14);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 14);
            rt.r[2] = abi.read32(0x08078860);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x3F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[4]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 12;
        },
        12 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], 0xF0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 12);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[3]);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 15;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(clusters_low.func_080788B8, 0x08078849)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(clusters_low.func_08078728, 0x0807884F)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0807885C);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            enter_08078258(6); return;
        },
        else => unreachable,
    }
}

fn enter_08078630(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.write32(rt.r[5] +% 0x0, rt.r[3]);
            rt.r[1] = abi.read32(0x080786E8);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 18);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                enter_08030634(22); return;
            }
            enter_08030634(21); return;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[4] >> 8);
            abi.write8(rt.r[5] +% 0x6, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[4], 0xC);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x50, true);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], 0xF0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 8);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[3]);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                enter_080784E0(10); return;
            }
            enter_080784E0(9); return;
        },
        else => unreachable,
    }
}

// === COMP [3] funcs=1 enters=1 lines=508 ===
pub fn func_0806EE0A() callconv(.c) void {
    if (!abi.enter(0x0806EE0A)) return;
    enter_0806EC18(34);
}

fn enter_0806EC18(start_block: u32) void {
    blk: switch (start_block) {
        34 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x80);
            if (!abi.call(dma.func_08011330, 0x0806EE11)) return;
            continue :blk 35;
        },
        35 => {
            abi.fetches(10);
            rt.r[6] = abi.read8(rt.r[6] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[6] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[1], 0xC0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(dma.func_08011330, 0x0806EE21)) return;
            continue :blk 36;
        },
        36 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x34, true);
            rt.r[2] = rt.r[8];
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[5] = abi.read32(0x0806EEB8);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.write16(rt.r[1] +% 0x4, @truncate(rt.r[0]));
            if (!abi.call(low_peel_13.func_0806E4B8, 0x0806EE37)) return;
            continue :blk 37;
        },
        37 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x34, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[1] = rt.r[9];
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[1]));
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

comptime {
    if (!builtin.is_test) {
        @export(&func_0800F164, .{ .name = "func_0800F164", .linkage = .strong });
        @export(&func_0800FBC4, .{ .name = "func_0800FBC4", .linkage = .strong });
        @export(&func_0800FC58, .{ .name = "func_0800FC58", .linkage = .strong });
        @export(&func_0800FD54, .{ .name = "func_0800FD54", .linkage = .strong });
        @export(&func_08010A00, .{ .name = "func_08010A00", .linkage = .strong });
        @export(&func_0801114C, .{ .name = "func_0801114C", .linkage = .strong });
        @export(&func_080130A0, .{ .name = "func_080130A0", .linkage = .strong });
        @export(&func_080130BE, .{ .name = "func_080130BE", .linkage = .strong });
        @export(&func_080134D4, .{ .name = "func_080134D4", .linkage = .strong });
        @export(&func_080139D4, .{ .name = "func_080139D4", .linkage = .strong });
        @export(&func_080149E0, .{ .name = "func_080149E0", .linkage = .strong });
        @export(&func_08018290, .{ .name = "func_08018290", .linkage = .strong });
        @export(&func_0801A69C, .{ .name = "func_0801A69C", .linkage = .strong });
        @export(&func_0801B700, .{ .name = "func_0801B700", .linkage = .strong });
        @export(&func_0801F114, .{ .name = "func_0801F114", .linkage = .strong });
        @export(&func_08034BA8, .{ .name = "func_08034BA8", .linkage = .strong });
        @export(&func_08036464, .{ .name = "func_08036464", .linkage = .strong });
        @export(&func_08077EB0, .{ .name = "func_08077EB0", .linkage = .strong });
        @export(&func_08078424, .{ .name = "func_08078424", .linkage = .strong });
        @export(&func_08078A9C, .{ .name = "func_08078A9C", .linkage = .strong });
        @export(&func_080303E0, .{ .name = "func_080303E0", .linkage = .strong });
        @export(&func_080303F4, .{ .name = "func_080303F4", .linkage = .strong });
        @export(&func_080304FE, .{ .name = "func_080304FE", .linkage = .strong });
        @export(&func_0803050A, .{ .name = "func_0803050A", .linkage = .strong });
        @export(&func_08030634, .{ .name = "func_08030634", .linkage = .strong });
        @export(&func_08042E24, .{ .name = "func_08042E24", .linkage = .strong });
        @export(&func_08078258, .{ .name = "func_08078258", .linkage = .strong });
        @export(&func_080784E0, .{ .name = "func_080784E0", .linkage = .strong });
        @export(&func_08078630, .{ .name = "func_08078630", .linkage = .strong });
        @export(&func_080787CC, .{ .name = "func_080787CC", .linkage = .strong });
        @export(&func_0806EE0A, .{ .name = "func_0806EE0A", .linkage = .strong });
    }
}

test "clusters_low_2 exports are callable" {
    try std.testing.expect(@TypeOf(func_0800F164) == fn () callconv(.c) void);
    try std.testing.expect(@TypeOf(func_0806EE0A) == fn () callconv(.c) void);
}
