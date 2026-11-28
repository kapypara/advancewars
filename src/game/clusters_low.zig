//! Self-contained low-ROM (`< 0x08080000`) shared-body `enter_*` clusters.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const battle = @import("battle.zig");
const bios = @import("bios.zig");
const clusters_low_2 = @import("clusters_low_2.zig");
const dma = @import("dma.zig");
const hw = @import("hw.zig");
const low_peel_1 = @import("low_peel_1.zig");
const low_peel_2 = @import("low_peel_2.zig");
const low_peel_3 = @import("low_peel_3.zig");
const low_peel_4 = @import("low_peel_4.zig");
const low_peel_5 = @import("low_peel_5.zig");
const low_peel_6 = @import("low_peel_6.zig");
const low_peel_7 = @import("low_peel_7.zig");
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

fn popReturnTo(comptime reg: u5) void {
    rt.r[reg] = abi.popReg();
    rt.r[15] = rt.r[reg];
    rt.recompReturn(rt.r[reg]);
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

fn zeroExt16(comptime reg: u5) void {
    abi.setRegNz(&rt.r[reg], rt.r[reg] << 16);
    abi.setRegNz(&rt.r[reg], rt.r[reg] >> 16);
}

fn signExt16(comptime reg: u5) void {
    abi.setRegNz(&rt.r[reg], rt.r[reg] << 16);
    abi.setRegNz(&rt.r[reg], rt.asrConst(rt.r[reg], 16));
}

fn zeroExt8(comptime reg: u5) void {
    abi.setRegNz(&rt.r[reg], rt.r[reg] << 24);
    abi.setRegNz(&rt.r[reg], rt.r[reg] >> 24);
}

fn signExt8(comptime reg: u5) void {
    abi.setRegNz(&rt.r[reg], rt.r[reg] << 24);
    abi.setRegNz(&rt.r[reg], rt.asrConst(rt.r[reg], 24));
}

fn negNzcv(comptime reg: u5, val: u32) void {
    rt.cpuSub(&rt.r[reg], 0, val, true);
}

fn popReturnFetches4(addr: u32) void {
    if (!abi.enter(addr)) return;
    abi.fetches(4);
    popReturnTo(0);
}

// --- Cluster 1 & 6 & 18 & 23 (tail) & 24 (tail): simple pop-return stubs ---
pub fn func_0803FD0C() callconv(.c) void { popReturnFetches4(0x0803FD0C); }
pub fn func_0805220E() callconv(.c) void { popReturnFetches4(0x0805220E); }
pub fn func_08050204() callconv(.c) void { popReturnFetches4(0x08050204); }
pub fn func_08040304() callconv(.c) void { popReturnFetches4(0x08040304); }

// --- Cluster 2: enter_0800F8FC ---
fn run0800F8FC(start_block: u32) void {
    if (start_block == 0) {
        abi.fetches(5);
        rt.cpuSub(null, rt.r[7], 0x60, true);
        abi.setRegNz(&rt.r[0], rt.r[0] << 12);
        rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[4], true);
    }
    abi.fetches(7);
    abi.setRegNz(&rt.r[1], rt.r[0] << 8);
    rt.cpu_undefined(0xED38);
    abi.setRegNz(&rt.r[7], 0);
    abi.setRegNz(&rt.r[7], rt.r[7] << 7);
    abi.setRegNz(&rt.r[0], rt.r[0]);
    decls.func_0800F90C();
}

pub fn func_0800F8FC() callconv(.c) void {
    if (!abi.enter(0x0800F8FC)) return;
    run0800F8FC(0);
}

pub fn func_0800F902() callconv(.c) void {
    if (!abi.enter(0x0800F902)) return;
    run0800F8FC(1);
}

// --- Cluster 3: enter_08070502 + enter_08070506 ---
fn run08070506() void {
    abi.fetches(3);
    abi.setRegNz(&rt.r[0], rt.r[0] << 12);
    decls.func_08070508();
}

fn run08070502(start_block: u32) void {
    if (start_block == 0) {
        abi.fetches(3);
        abi.setRegNz(&rt.r[0], rt.r[0]);
    }
    abi.fetches(3);
    rt.cpuAdd(&rt.r[0], rt.r[3], 0x4, true);
    run08070506();
}

pub fn func_08070500() callconv(.c) void {
    if (!abi.enter(0x08070500)) return;
    abi.fetches(3);
    abi.setRegNz(&rt.r[7], rt.r[7] << 7);
    run08070502(0);
}

pub fn func_08070502() callconv(.c) void {
    if (!abi.enter(0x08070502)) return;
    run08070502(0);
}

pub fn func_08070504() callconv(.c) void {
    if (!abi.enter(0x08070504)) return;
    run08070502(1);
}

pub fn func_08070506() callconv(.c) void {
    if (!abi.enter(0x08070506)) return;
    run08070506();
}

// --- Cluster 4: enter_08018CA8 (blocks 1..2 reached from func_08037950) ---
pub fn func_08037950() callconv(.c) void {
    if (!abi.enter(0x08037950)) return;
    abi.fetches(12);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08037974);
    rt.r[1] = abi.read32(rt.r[0] +% 0x0);
    rt.cpuAdd(&rt.r[1], rt.r[1], 0xD0, true);
    abi.setRegNz(&rt.r[2], 0x1);
    abi.copyRegFlags(&rt.r[0], rt.r[2]);
    rt.r[1] = abi.read8(rt.r[1] +% 0x12);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    rt.cpuSub(null, rt.r[0], 0x0, true);
    if (!rt.CPU_Z) {
        abi.fetches(8);
        rt.r[0] = abi.read32(0x08037978);
        abi.write32(rt.r[0] +% 0x0, rt.r[2]);
        abi.setRegNz(&rt.r[0], 0x1);
        abi.setRegNz(&rt.r[1], 0x1);
        if (!abi.call(low_peel_4.func_0803EF74, 0x08037971)) return;
    }
    abi.fetches(4);
    popReturnTo(0);
}

// --- Cluster 5: enter_0801A784 + enter_0801A78A ---
fn run0801A78A() void {
    abi.fetches(5);
    popRegsSeq(&.{ 4, 5 });
    popReturnTo(0);
}

fn run0801A784() void {
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0x0);
    if (!abi.call(decls.func_0801B2B8, 0x0801A78B)) return;
    run0801A78A();
}

pub fn func_0801A768() callconv(.c) void {
    if (!abi.enter(0x0801A768)) return;
    abi.fetches(16);
    pushRegs(&.{ 4, 5, 14 });
    rt.r[5] = abi.read32(rt.r[13] +% 0xC);
    rt.r[4] = abi.read32(0x0801A790);
    abi.write32(rt.r[4] +% 0x0, rt.r[0]);
    rt.r[0] = abi.read32(0x0801A794);
    abi.write32(rt.r[0] +% 0x0, rt.r[1]);
    rt.r[0] = abi.read32(0x0801A798);
    abi.write32(rt.r[0] +% 0x0, rt.r[2]);
    rt.r[0] = abi.read32(0x0801A79C);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
    rt.r[0] = abi.read32(0x0801A7A0);
    abi.write32(rt.r[0] +% 0x0, rt.r[5]);
    if (!abi.call(low_peel_3.func_0801AFC8, 0x0801A785)) return;
    run0801A784();
}

pub fn func_0801A784() callconv(.c) void {
    if (!abi.enter(0x0801A784)) return;
    run0801A784();
}

pub fn func_0801A78A() callconv(.c) void {
    if (!abi.enter(0x0801A78A)) return;
    run0801A78A();
}

// --- Cluster 7: enter_080700EE ---
fn run080700EE(start_block: u32) void {
    if (start_block == 0) {
        abi.fetches(8);
        abi.setRegNz(&rt.r[0], rt.r[0] << 12);
        stmRegs(0, &.{ 2, 5, 7 });
        abi.setRegNz(&rt.r[2], 0);
        abi.setRegNz(&rt.r[2], rt.r[6] << 14);
        abi.setRegNz(&rt.r[0], rt.r[0]);
        abi.setRegNz(&rt.r[6], rt.r[7] << 14);
    }
    abi.fetches(3);
    abi.setRegNz(&rt.r[0], rt.r[0]);
    decls.func_080700FC();
}

pub fn func_080700EE() callconv(.c) void {
    if (!abi.enter(0x080700EE)) return;
    run080700EE(0);
}

pub fn func_080700FA() callconv(.c) void {
    if (!abi.enter(0x080700FA)) return;
    run080700EE(1);
}

// --- Cluster 8: enter_08041F0C ---
fn run08041F0C(start_block: u32) void {
    if (start_block == 0) {
        abi.fetches(4);
        pushRegs(&.{ 6, 14 });
        abi.setRegNz(&rt.r[6], 0);
    }
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08041F1C);
    if (!abi.call(low_peel_6.func_0801329C, 0x08041F19)) return;
    abi.fetches(4);
    popReturnTo(0);
}

pub fn func_08041F0C() callconv(.c) void {
    if (!abi.enter(0x08041F0C)) return;
    run08041F0C(0);
}

pub fn func_08041F10() callconv(.c) void {
    if (!abi.enter(0x08041F10)) return;
    run08041F0C(1);
}

// --- Cluster 9: enter_08060602 ---
fn run08060602(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.cpuSub(null, rt.r[5], 0x5A, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 22);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            rt.r[4] +%= rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            abi.setRegNz(&rt.r[0], rt.r[0]);
        },
        else => unreachable,
    }
}

pub fn func_08060600() callconv(.c) void {
    if (!abi.enter(0x08060600)) return;
    abi.fetches(3);
    rt.cpuSub(null, rt.r[4], 0xB4, true);
    run08060602(0);
}

pub fn func_08060602() callconv(.c) void {
    if (!abi.enter(0x08060602)) return;
    run08060602(0);
}

pub fn func_08060604() callconv(.c) void {
    if (!abi.enter(0x08060604)) return;
    run08060602(1);
}

pub fn func_08060606() callconv(.c) void {
    if (!abi.enter(0x08060606)) return;
    run08060602(2);
}

pub fn func_08060608() callconv(.c) void {
    if (!abi.enter(0x08060608)) return;
    run08060602(3);
}

// --- Cluster 10: enter_0803EFE8 (block 2) ---
pub fn func_0803F008() callconv(.c) void {
    if (!abi.enter(0x0803F008)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
    popReturnTo(1);
}

// --- Cluster 11: enter_0802F9E0 (blocks 3..4) ---
pub fn func_0802F9F6() callconv(.c) void {
    if (!abi.enter(0x0802F9F6)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0x4);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.r[0] = abi.popReg();
    abi.fetches(3);
    rt.r[15] = rt.r[0];
    rt.recompReturn(rt.r[0]);
}

// --- Cluster 12: enter_08044354 (block 2) ---
pub fn func_08044374() callconv(.c) void {
    if (!abi.enter(0x08044374)) return;
    abi.fetches(19);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x10);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
    rt.r[0] = abi.read32(0x0804439C);
    abi.setRegNz(&rt.r[2], 0xF);
    abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
    rt.r[1] = abi.read32(0x080443A0);
    abi.setRegNz(&rt.r[0], 0x6);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.r[0] = abi.read32(0x080443A4);
    rt.r[0] = abi.read32(rt.r[0] +% 0x0);
    rt.r[1] = abi.read32(0x080443A8);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
    popReturnTo(0);
}

// --- Cluster 13: enter_080305E4 (blocks 1..2) ---
fn run080305E4(start_block: u32) void {
    if (start_block == 1) {
        abi.fetches(4);
        abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[3]));
        rt.r[0] = abi.read16(rt.r[1] +% 0x2);
    }
    abi.fetches(26);
    abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[3]));
    rt.r[0] = abi.read8(rt.r[1] +% 0x4);
    abi.setRegNz(&rt.r[0], 0x1);
    abi.write8(rt.r[1] +% 0x4, @truncate(rt.r[0]));
    rt.r[0] = abi.read32(rt.r[2] +% 0x0);
    rt.r[1] = abi.read8(rt.r[0] +% 0x5);
    abi.write8(rt.r[0] +% 0x5, @truncate(rt.r[4]));
    rt.r[0] = abi.read32(rt.r[2] +% 0x0);
    rt.r[1] = abi.read16(rt.r[0] +% 0x6);
    rt.r[1] = abi.read32(0x08030628);
    abi.write16(rt.r[0] +% 0x6, @truncate(rt.r[1]));
    abi.setRegNz(&rt.r[1], 0x84);
    abi.setRegNz(&rt.r[1], rt.r[1] << 2);
    rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[1], true);
    rt.r[1] = abi.read16(rt.r[2] +% 0x0);
    rt.r[1] = abi.read32(0x0803062C);
    abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[1]));
    rt.r[1] = abi.read32(0x08030630);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    rt.r[1] = abi.read16(rt.r[0] +% 0x0);
    abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
    rt.r[4] = abi.popReg();
    popReturnTo(0);
}

pub fn func_080305F0() callconv(.c) void {
    if (!abi.enter(0x080305F0)) return;
    run080305E4(1);
}

pub fn func_080305F4() callconv(.c) void {
    if (!abi.enter(0x080305F4)) return;
    run080305E4(2);
}

// --- Cluster 14: enter_08014AF0 ---
pub fn func_08014AF0() callconv(.c) void {
    if (!abi.enter(0x08014AF0)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08014B04);
    abi.setRegNz(&rt.r[1], 0xE0);
    abi.setRegNz(&rt.r[1], rt.r[1] << 19);
    abi.setRegNz(&rt.r[2], 0x80);
    abi.setRegNz(&rt.r[2], rt.r[2] << 3);
    if (!abi.call(dma.func_0800FDCC, 0x08014B01)) return;
    abi.fetches(4);
    popReturnTo(0);
}

pub fn func_08014B14() callconv(.c) void {
    if (!abi.enter(0x08014B14)) return;
    abi.fetches(7);
    rt.r[2] = abi.read32(0x08014B38);
    abi.setRegNz(&rt.r[0], rt.r[0] << 3);
    rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
    rt.cpuSub(null, rt.r[1], 0x0, true);
    if (!(rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
        abi.fetches(4);
        abi.setRegNz(&rt.r[3], 0xA0);
        abi.setRegNz(&rt.r[0], 0x0);
        while (true) {
            abi.fetches(11);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) break;
        }
    }
    abi.fetches(3);
    abi.retLr();
}

pub fn func_0801A1FC() callconv(.c) void {
    if (!abi.enter(0x0801A1FC)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[1], 0x0);
    rt.r[3] = abi.read32(0x0801A214);
    abi.setRegNz(&rt.r[2], 0x0);
    while (true) {
        abi.fetches(10);
        abi.setRegNz(&rt.r[0], rt.r[1] << 1);
        rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
        abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
        rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
        abi.setRegNz(&rt.r[0], rt.r[0] << 16);
        abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
        rt.cpuSub(null, rt.r[1], 0x1F, true);
        if (rt.CPU_C and !rt.CPU_Z) break;
    }
    abi.fetches(3);
    abi.retLr();
}

// --- Cluster 15: enter_0801F7EC (blocks 1..4) ---
fn run0801F7EC(start_block: u32) void {
    blk: switch (start_block) {
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[3], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 10);
            rt.r[0] = abi.read32(0x0801F818);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read32(0x0801F81C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], rt.r[1] << 28);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 30);
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[1], rt.r[1] << 14);
            rt.r[0] = abi.read32(0x0801F820);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[2], 0xC0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 4);
            abi.copyRegFlags(&rt.r[0], rt.r[3]);
            if (!abi.call(dma.func_0800FDA4, 0x0801F815)) return;
            abi.fetches(4);
            popReturnTo(0);
        },
        else => unreachable,
    }
}

pub fn func_0801F7F0() callconv(.c) void {
    if (!abi.enter(0x0801F7F0)) return;
    run0801F7EC(1);
}

pub fn func_0801F800() callconv(.c) void {
    if (!abi.enter(0x0801F800)) return;
    run0801F7EC(2);
}

pub fn func_0801F804() callconv(.c) void {
    if (!abi.enter(0x0801F804)) return;
    run0801F7EC(3);
}

// --- Cluster 16: enter_080034F0 (blocks 2..5) ---
pub fn func_08003502() callconv(.c) void {
    if (!abi.enter(0x08003502)) return;
    abi.fetches(4);
    if (!abi.call(dma.func_0800FFA8, 0x08003507)) return;
    abi.fetches(7);
    rt.r[0] = abi.read32(0x08003530);
    rt.r[1] = abi.read32(0x08003534);
    abi.setRegNz(&rt.r[2], 0x80);
    if (!abi.call(dma.func_0800FFA8, 0x08003511)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(0x08003538);
    abi.setRegNz(&rt.r[1], 0xE8);
    abi.setRegNz(&rt.r[1], rt.r[1] << 2);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x0800351D)) return;
    abi.fetches(4);
    popReturnTo(0);
}

// --- Cluster 17: enter_0800FB9C ---
fn run0800FB9C(start_block: u32) void {
    if (start_block == 0) {
        abi.fetches(12);
        pushRegs(&.{ 4, 5, 6, 14 });
        abi.copyRegFlags(&rt.r[4], rt.r[0]);
        abi.copyRegFlags(&rt.r[5], rt.r[1]);
        abi.copyRegFlags(&rt.r[6], rt.r[2]);
        zeroExt16(4);
        zeroExt16(5);
        if (!abi.call(sprite_anim.func_08014B3C, 0x0800FBB1)) return;
        abi.fetches(7);
        abi.copyRegFlags(&rt.r[0], rt.r[4]);
        abi.copyRegFlags(&rt.r[1], rt.r[5]);
        abi.copyRegFlags(&rt.r[2], rt.r[6]);
        if (!abi.call(low_peel_6.func_0800FADC, 0x0800FBBB)) return;
        abi.fetches(3);
        if (!abi.call(decls.func_0807AD88, 0x0800FBBF)) return;
    }
    abi.fetches(3);
    abi.fetches(4);
    if (!abi.call(low_peel_2.func_0807ADF0, 0x0800FBC3)) return;
    while (true) {
        abi.fetches(3);
    }
}

pub fn func_0800FB9C() callconv(.c) void {
    if (!abi.enter(0x0800FB9C)) return;
    run0800FB9C(0);
}

pub fn func_0800FBBC() callconv(.c) void {
    if (!abi.enter(0x0800FBBC)) return;
    run0800FB9C(3);
}

// --- Cluster 18: enter_0801FFB8 (blocks 1..2) ---
pub fn func_0801FFF6() callconv(.c) void {
    if (!abi.enter(0x0801FFF6)) return;
    abi.fetches(5);
    abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
    rt.r[4] = abi.popReg();
    rt.r[0] = abi.popReg();
    abi.fetches(3);
    rt.r[15] = rt.r[0];
    rt.recompReturn(rt.r[0]);
}

// --- Cluster 19: enter_0800353C (blocks 1..4) ---
pub fn func_08003542() callconv(.c) void {
    if (!abi.enter(0x08003542)) return;
    abi.fetches(9);
    rt.r[2] = abi.read32(0x08003574);
    abi.setRegNz(&rt.r[4], 0xD0);
    abi.setRegNz(&rt.r[4], rt.r[4] << 8);
    abi.setRegNz(&rt.r[0], 0x18);
    abi.copyRegFlags(&rt.r[3], rt.r[4]);
    if (!abi.call(hw.func_0801B888, 0x08003551)) return;
    abi.fetches(9);
    abi.setRegNz(&rt.r[1], 0x86);
    abi.setRegNz(&rt.r[1], rt.r[1] << 3);
    rt.r[2] = abi.read32(0x08003578);
    abi.setRegNz(&rt.r[0], 0x18);
    abi.copyRegFlags(&rt.r[3], rt.r[4]);
    if (!abi.call(hw.func_0801B888, 0x0800355F)) return;
    abi.fetches(9);
    abi.setRegNz(&rt.r[1], 0x88);
    abi.setRegNz(&rt.r[1], rt.r[1] << 3);
    rt.r[2] = abi.read32(0x0800357C);
    abi.setRegNz(&rt.r[0], 0x18);
    abi.copyRegFlags(&rt.r[3], rt.r[4]);
    if (!abi.call(hw.func_0801B888, 0x0800356D)) return;
    abi.fetches(5);
    rt.r[4] = abi.popReg();
    popReturnTo(0);
}

// --- Cluster 20: enter_08020CDC (blocks 2..3) ---
pub fn func_08020D00() callconv(.c) void {
    if (!abi.enter(0x08020D00)) return;
    abi.fetches(8);
    rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
    abi.setRegNz(&rt.r[2], 0x0);
    rt.r[1] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
    abi.copyRegFlags(&rt.r[2], rt.r[4]);
    if (!abi.call(low_peel_7.func_08020B48, 0x08020D0D)) return;
    abi.fetches(6);
    rt.r[13] +%= 0x8;
    popRegsSeq(&.{ 4, 5 });
    popReturnTo(0);
}

// --- Cluster 21: enter_08041F50 ---
fn run08041F50(start_block: u32) void {
    if (start_block == 0) {
        abi.fetches(4);
        pushRegs(&.{ 4, 6, 14 });
        abi.setRegNz(&rt.r[6], 0);
    }
    abi.fetches(15);
    pushRegs(&.{ 4, 14 });
    abi.copyRegFlags(&rt.r[4], rt.r[0]);
    zeroExt16(4);
    rt.r[0] = abi.read32(0x08041F84);
    abi.setRegNz(&rt.r[1], rt.r[1] << 21);
    abi.setRegNz(&rt.r[2], 0x80);
    abi.setRegNz(&rt.r[2], rt.r[2] << 18);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
    abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x08041F6F)) return;
    abi.fetches(9);
    rt.r[0] = abi.read32(0x08041F88);
    abi.setRegNz(&rt.r[4], rt.r[4] << 5);
    rt.r[1] = abi.read32(0x08041F8C);
    rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[1], true);
    abi.copyRegFlags(&rt.r[1], rt.r[4]);
    if (!abi.call(hw.func_0800FE18, 0x08041F7D)) return;
    abi.fetches(5);
    rt.r[4] = abi.popReg();
    popReturnTo(0);
}

pub fn func_08041F50() callconv(.c) void {
    if (!abi.enter(0x08041F50)) return;
    run08041F50(0);
}

pub fn func_08041F54() callconv(.c) void {
    if (!abi.enter(0x08041F54)) return;
    run08041F50(1);
}

// --- Cluster 22: enter_08074430 (blocks 1..2) ---
pub fn func_08074442() callconv(.c) void {
    if (!abi.enter(0x08074442)) return;
    abi.fetches(11);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
    abi.setRegNz(&rt.r[3], rt.r[1] << 1);
    rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
    abi.setRegNz(&rt.r[3], rt.r[3] << 1);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
    abi.setRegNz(&rt.r[1], 0xA);
    if (!abi.call(math.func_0807B488, 0x08074455)) return;
    abi.fetches(14);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
    abi.setRegNz(&rt.r[0], rt.r[0] >> 17);
    abi.setRegNz(&rt.r[0], rt.r[0] << 10);
    abi.setRegNz(&rt.r[2], rt.r[1] << 5);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
    zeroExt16(1);
    abi.copyRegFlags(&rt.r[0], rt.r[1]);
    popReturnTo(1);
}

// --- Cluster 23: enter_080501DC (blocks 2..6; block 6 via func_08050204 above) ---
fn run080501DC(start_block: u32) void {
    blk: switch (start_block) {
        2 => {
            abi.fetches(6);
            zeroExt16(4);
            abi.copyRegFlags(&rt.r[0], rt.r[4]);
            abi.setRegNz(&rt.r[1], 0x57);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            if (!abi.call(battle.func_0802FC70, 0x08050203)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            abi.fetches(3);
            rt.r[4] = abi.popReg();
            abi.fetches(4);
            popReturnTo(0);
        },
        else => unreachable,
    }
}

pub fn func_080501F6() callconv(.c) void {
    if (!abi.enter(0x080501F6)) return;
    run080501DC(2);
}

pub fn func_080501FE() callconv(.c) void {
    if (!abi.enter(0x080501FE)) return;
    run080501DC(3);
}

pub fn func_08050200() callconv(.c) void {
    if (!abi.enter(0x08050200)) return;
    run080501DC(4);
}

// --- Cluster 24: enter_080402D4 (blocks 2..4; block 4 via func_08040304 above) ---
pub fn func_08040300() callconv(.c) void {
    if (!abi.enter(0x08040300)) return;
    abi.fetches(3);
    abi.fetches(3);
    popRegsSeq(&.{ 4, 5 });
    abi.fetches(4);
    popReturnTo(0);
}

// --- Cluster 25: enter_08070AF0 (block 2) ---
pub fn func_08070B0C() callconv(.c) void {
    if (!abi.enter(0x08070B0C)) return;
    abi.fetches(36);
    abi.setRegNz(&rt.r[1], 0x8);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x10);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
    abi.setRegNz(&rt.r[0], 0x2);
    negNzcv(0, rt.r[0]);
    rt.r[1] = abi.read8(rt.r[2] +% 0x1);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x3);
    negNzcv(1, rt.r[1]);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    rt.cpuSub(&rt.r[1], rt.r[1], 0x2, true);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    rt.cpuSub(&rt.r[1], rt.r[1], 0x4, true);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    rt.cpuSub(&rt.r[1], rt.r[1], 0x8, true);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
    rt.r[2] = abi.read32(0x08070B54);
    abi.setRegNz(&rt.r[0], 0x20);
    rt.r[1] = abi.read8(rt.r[2] +% 0x0);
    abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
    abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
    rt.r[1] = abi.read32(0x08070B58);
    rt.r[2] = abi.read8(rt.r[1] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
    abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.cpuAdd(&rt.r[4], rt.r[4], 0x44, true);
    abi.setRegNz(&rt.r[0], 0x0);
    abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
    rt.r[4] = abi.popReg();
    popReturnTo(0);
}

// --- Cluster 26: enter_080703B0 (blocks 1..4) ---
fn run080703B0(start_block: u32) void {
    blk: switch (start_block) {
        1 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x4, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x10);
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.retLr();
        },
        else => unreachable,
    }
}

pub fn func_080703FE() callconv(.c) void {
    if (!abi.enter(0x080703FE)) return;
    run080703B0(1);
}

pub fn func_08070400() callconv(.c) void {
    if (!abi.enter(0x08070400)) return;
    run080703B0(2);
}

pub fn func_08070402() callconv(.c) void {
    if (!abi.enter(0x08070402)) return;
    run080703B0(3);
}

pub fn func_08070404() callconv(.c) void {
    if (!abi.enter(0x08070404)) return;
    run080703B0(4);
}

// --- Cluster 27: enter_0800FDDC (blocks 2..4) ---
pub fn func_0800FDF8() callconv(.c) void {
    if (!abi.enter(0x0800FDF8)) return;
    abi.fetches(9);
    zeroExt16(4);
    abi.copyRegFlags(&rt.r[0], rt.r[5]);
    rt.r[1] = rt.r[8];
    abi.copyRegFlags(&rt.r[2], rt.r[4]);
    if (!abi.call(dma.func_0800FDA4, 0x0800FE07)) return;
    abi.fetches(5);
    abi.copyRegFlags(&rt.r[0], rt.r[5]);
    if (!abi.call(low_peel_3.func_08012E14, 0x0800FE0D)) return;
    abi.fetches(7);
    rt.r[3] = abi.popReg();
    rt.r[8] = rt.r[3];
    popRegsSeq(&.{ 4, 5, 6 });
    popReturnTo(0);
}

// --- Cluster 28: enter_080702FC (blocks 1..3) ---
fn run080702FC(start_block: u32) void {
    if (start_block == 1) {
        abi.fetches(3);
        if (!abi.call(hw.func_080104B0, 0x08070305)) return;
    }
    abi.fetches(3);
    abi.fetches(50);
    rt.r[2] = abi.read32(0x08070364);
    abi.setRegNz(&rt.r[0], 0x3F);
    rt.r[1] = abi.read8(rt.r[2] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x80);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x1);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x2);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x4);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x8);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x10);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
    abi.setRegNz(&rt.r[0], 0x2);
    negNzcv(0, rt.r[0]);
    rt.r[1] = abi.read8(rt.r[2] +% 0x1);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x3);
    negNzcv(1, rt.r[1]);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    rt.cpuSub(&rt.r[1], rt.r[1], 0x2, true);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    rt.cpuSub(&rt.r[1], rt.r[1], 0x4, true);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    rt.cpuSub(&rt.r[1], rt.r[1], 0x8, true);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
    abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
    rt.r[1] = abi.read32(0x08070368);
    abi.setRegNz(&rt.r[0], 0x20);
    rt.r[2] = abi.read8(rt.r[1] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
    abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.r[1] = abi.read32(0x0807036C);
    abi.setRegNz(&rt.r[0], 0x21);
    negNzcv(0, rt.r[0]);
    rt.r[2] = abi.read8(rt.r[1] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
    abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.cpuAdd(&rt.r[4], rt.r[4], 0x42, true);
    abi.setRegNz(&rt.r[0], 0x42);
    abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
    rt.r[4] = abi.popReg();
    popReturnTo(0);
}

pub fn func_08070300() callconv(.c) void {
    if (!abi.enter(0x08070300)) return;
    run080702FC(1);
}

pub fn func_08070302() callconv(.c) void {
    if (!abi.enter(0x08070302)) return;
    run080702FC(2);
}

// --- Cluster 29: enter_08052368 ---
fn run08052368(start_block: u32) void {
    if (start_block == 0) {
        abi.fetches(8);
        abi.pushLr();
        rt.r[1] = abi.read32(0x08052378);
        abi.setRegNz(&rt.r[0], 0x0);
        abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
        if (!abi.call(ui.func_08073CA8, 0x08052375)) return;
        abi.fetches(4);
        popReturnTo(0);
        return;
    }
    if (start_block == 2) {
        abi.fetches(5);
        abi.setRegNz(&rt.r[6], 0xB2);
        abi.setRegNz(&rt.r[7], 0xFF);
        abi.setRegNz(&rt.r[7], rt.r[7] << 24);
    }
    // block 3..5
    abi.fetches(30);
    rt.r[3] = abi.read32(0x08078210);
    rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[3], true);
    rt.r[5] = abi.read8(rt.r[0] +% 0x0);
    rt.r[4] = abi.read32(0x08078214);
    abi.setRegNz(&rt.r[2], 0xF);
    abi.copyRegFlags(&rt.r[0], rt.r[5]);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
    abi.setRegNz(&rt.r[0], rt.r[0] << 2);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
    abi.setRegNz(&rt.r[1], rt.r[5] >> 4);
    rt.r[5] = abi.read32(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[5], rt.armLsr(rt.r[5], rt.r[1] & 0xFF));
    rt.cpuAdd(&rt.r[0], rt.r[6], 0x1, true);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
    rt.r[1] = abi.read8(rt.r[0] +% 0x0);
    abi.copyRegFlags(&rt.r[0], rt.r[1]);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
    abi.setRegNz(&rt.r[0], rt.r[0] << 2);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
    abi.setRegNz(&rt.r[1], rt.r[1] >> 4);
    rt.r[0] = abi.read32(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.armLsr(rt.r[0], rt.r[1] & 0xFF));
    rt.r[1] = rt.r[12];
    rt.r[4] = abi.read32(rt.r[1] +% 0x4);
    rt.cpuSub(&rt.r[0], rt.r[0], rt.r[5], true);
    abi.copyRegFlags(&rt.r[1], rt.r[7]);
    if (!abi.call(tail_low.func_080775A0, 0x08078201)) return;
    abi.fetches(7);
    abi.copyRegFlags(&rt.r[1], rt.r[0]);
    rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[1], true);
    abi.copyRegFlags(&rt.r[0], rt.r[4]);
    if (!abi.call(tail_low.func_080775A0, 0x0807820B)) return;
    abi.fetches(5);
    popRegsSeq(&.{ 4, 5, 6, 7 });
    popReturnTo(1);
}

pub fn func_08052368() callconv(.c) void {
    if (!abi.enter(0x08052368)) return;
    run08052368(0);
}

pub fn func_080781B4() callconv(.c) void {
    if (!abi.enter(0x080781B4)) return;
    abi.fetches(9);
    pushRegs(&.{ 4, 5, 6, 7, 14 });
    rt.r[12] = rt.r[0];
    abi.setRegNz(&rt.r[1], rt.r[1] << 24);
    abi.setRegNz(&rt.r[6], rt.r[1] >> 24);
    abi.setRegNz(&rt.r[7], rt.r[2] << 24);
    rt.cpuSub(null, rt.r[6], 0xB2, true);
    run08052368(if (!rt.CPU_C or rt.CPU_Z) 3 else 2);
}

// --- Cluster 30: enter_0801319C ---
fn run0801319C(start_block: u32) void {
    if (start_block == 0) {
        abi.fetches(14);
        pushRegs(&.{ 4, 5, 6, 14 });
        abi.copyRegFlags(&rt.r[4], rt.r[1]);
        zeroExt8(4);
        zeroExt8(2);
        rt.r[5] = abi.read32(0x080131D8);
        rt.r[6] = abi.read16(rt.r[5] +% 0x0);
        abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[4]));
        abi.copyRegFlags(&rt.r[1], rt.r[4]);
        if (!abi.call(proc.func_080130D0, 0x080131B5)) return;
        abi.fetches(12);
        rt.r[1] = abi.read32(0x080131DC);
        abi.setRegNz(&rt.r[0], rt.r[4] << 1);
        rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
        abi.setRegNz(&rt.r[0], rt.r[0] << 5);
        rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
        abi.setRegNz(&rt.r[1], 0x4);
        abi.write16(rt.r[0] +% 0x12, @truncate(rt.r[1]));
        abi.copyRegFlags(&rt.r[0], rt.r[4]);
        if (!abi.call(clusters_low_2.func_080139D4, 0x080131C9)) return;
        abi.fetches(9);
        abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[6]));
        signExt8(4);
        abi.copyRegFlags(&rt.r[0], rt.r[4]);
        popRegsSeq(&.{ 4, 5, 6 });
        popReturnTo(1);
        return;
    }
    if (start_block == 3) {
        abi.fetches(3);
        rt.cpuAdd(&rt.r[0], rt.r[0], 0x3, true);
    }
    abi.fetches(10);
    abi.setRegNz(&rt.r[2], rt.r[0] << 9);
    abi.setRegNz(&rt.r[2], rt.r[2] >> 11);
    abi.setRegNz(&rt.r[0], 0x80);
    abi.setRegNz(&rt.r[0], rt.r[0] << 19);
    abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[0]);
    abi.copyRegFlags(&rt.r[0], rt.r[3]);
    if (!abi.call(bios.func_080796C4, 0x0801B841)) return;
    abi.fetches(4);
    popReturnTo(0);
}

pub fn func_0801319C() callconv(.c) void {
    if (!abi.enter(0x0801319C)) return;
    run0801319C(0);
}

pub fn func_0801B820() callconv(.c) void {
    if (!abi.enter(0x0801B820)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[3] = abi.read32(0x0801B844);
    rt.r[1] = abi.read32(0x0801B848);
    rt.r[0] = abi.read32(0x0801B84C);
    rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
    rt.cpuSub(null, rt.r[0], 0x0, true);
    run0801319C(if (rt.CPU_N == rt.CPU_V) 4 else 3);
}

// --- Cluster 31: enter_0803D680 (blocks 7..9) ---
pub fn func_0803D6DC() callconv(.c) void {
    if (!abi.enter(0x0803D6DC)) return;
    abi.fetches(4);
    if (!abi.call(sprite_anim.func_08013744, 0x0803D6E1)) return;
    abi.fetches(6);
    abi.copyRegFlags(&rt.r[0], rt.r[4]);
    abi.copyRegFlags(&rt.r[1], rt.r[5]);
    if (!abi.call(sprite_anim.func_08013794, 0x0803D6E9)) return;
    abi.fetches(6);
    rt.r[13] +%= 0xC;
    popRegsSeq(&.{ 4, 5 });
    popReturnTo(0);
}

// --- Cluster 32: enter_08030708 (blocks 1..4) ---
pub fn func_0803070C() callconv(.c) void {
    if (!abi.enter(0x0803070C)) return;
    abi.fetches(42);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
    abi.setRegNz(&rt.r[6], 0x0);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[6]));
    rt.r[4] = abi.read32(0x080307A4);
    rt.r[0] = abi.read32(rt.r[4] +% 0x0);
    rt.r[1] = abi.read8(rt.r[0] +% 0x0);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[6]));
    rt.r[0] = abi.read32(rt.r[4] +% 0x0);
    rt.r[1] = abi.read8(rt.r[0] +% 0x1);
    abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[6]));
    rt.r[1] = abi.read32(rt.r[4] +% 0x0);
    rt.r[0] = abi.read16(rt.r[1] +% 0x4);
    abi.setRegNz(&rt.r[5], 0x0);
    abi.write16(rt.r[1] +% 0x4, @truncate(rt.r[6]));
    rt.r[0] = abi.read16(rt.r[1] +% 0x2);
    abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[6]));
    rt.r[0] = abi.read32(0x080307A8);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
    abi.setRegNz(&rt.r[0], 0xFF);
    abi.write8(rt.r[1] +% 0x6, @truncate(rt.r[0]));
    rt.r[0] = abi.read32(rt.r[4] +% 0x0);
    rt.r[1] = abi.read8(rt.r[0] +% 0x7);
    abi.write8(rt.r[0] +% 0x7, @truncate(rt.r[5]));
    rt.r[0] = abi.read32(rt.r[4] +% 0x0);
    rt.r[1] = abi.read8(rt.r[0] +% 0x8);
    abi.write8(rt.r[0] +% 0x8, @truncate(rt.r[5]));
    rt.r[0] = abi.read32(rt.r[4] +% 0x0);
    rt.r[1] = abi.read8(rt.r[0] +% 0x9);
    abi.write8(rt.r[0] +% 0x9, @truncate(rt.r[5]));
    rt.r[0] = abi.read32(rt.r[4] +% 0x0);
    rt.r[1] = abi.read8(rt.r[0] +% 0x1C);
    abi.write8(rt.r[0] +% 0x1C, @truncate(rt.r[5]));
    rt.r[0] = abi.read32(rt.r[4] +% 0x0);
    rt.r[1] = abi.read8(rt.r[0] +% 0x1D);
    abi.write8(rt.r[0] +% 0x1D, @truncate(rt.r[5]));
    rt.r[0] = abi.read32(rt.r[4] +% 0x0);
    rt.r[1] = abi.read8(rt.r[0] +% 0x1E);
    abi.write8(rt.r[0] +% 0x1E, @truncate(rt.r[5]));
    if (!abi.call(battle.func_080305E4, 0x0803075D)) return;
    abi.fetches(4);
    if (!abi.call(clusters_low_2.func_080303E0, 0x08030761)) return;
    abi.fetches(4);
    if (!abi.call(clusters_low_2.func_08030634, 0x08030765)) return;
    abi.fetches(32);
    rt.r[0] = abi.read32(rt.r[4] +% 0x0);
    rt.r[2] = abi.read32(0x080307AC);
    rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
    rt.r[2] = abi.read16(rt.r[1] +% 0x0);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[6]));
    rt.r[3] = abi.read32(0x080307B0);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
    rt.r[1] = abi.read8(rt.r[0] +% 0x0);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
    rt.r[0] = abi.read32(rt.r[4] +% 0x0);
    rt.r[1] = abi.read32(0x080307B4);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    rt.r[1] = abi.read8(rt.r[0] +% 0x0);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
    rt.r[0] = abi.read32(rt.r[4] +% 0x0);
    rt.r[2] = abi.read32(0x080307B8);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
    rt.r[1] = abi.read8(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[1], 0x1);
    negNzcv(1, rt.r[1]);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[1] = abi.read32(0x080307BC);
    rt.r[0] = abi.read32(0x080307C0);
    ldmRegs(0, &.{ 2, 3, 4 });
    stmRegs(1, &.{ 2, 3, 4 });
    rt.r[0] = abi.read32(0x080307C4);
    abi.write32(rt.r[0] +% 0x0, rt.r[6]);
    popRegsSeq(&.{ 4, 5, 6 });
    popReturnTo(0);
}

// --- Cluster 33: enter_08027B7C (blocks 1..10) ---
pub fn func_08027B7E() callconv(.c) void {
    if (!abi.enter(0x08027B7E)) return;
    abi.fetches(23);
    rt.r[6] = rt.r[8];
    abi.pushReg(6);
    rt.r[13] -%= 0xC;
    abi.copyRegFlags(&rt.r[6], rt.r[0]);
    rt.r[8] = rt.r[1];
    abi.copyRegFlags(&rt.r[5], rt.r[2]);
    zeroExt16(6);
    rt.r[0] = rt.r[8];
    zeroExt16(0);
    rt.r[8] = rt.r[0];
    zeroExt16(5);
    rt.r[0] = abi.read32(0x08027C24);
    rt.r[2] = abi.read32(0x08027C28);
    abi.setRegNz(&rt.r[1], 0x0);
    abi.write32(rt.r[13] +% 0x0, rt.r[1]);
    abi.setRegNz(&rt.r[3], 0x0);
    if (!abi.call(decls.func_080133C0, 0x08027BA9)) return;
    abi.fetches(9);
    abi.copyRegFlags(&rt.r[4], rt.r[0]);
    signExt8(4);
    rt.r[0] = rt.r[13] +% 0x4;
    abi.copyRegFlags(&rt.r[1], rt.r[4]);
    if (!abi.call(sprite_anim.func_080135C8, 0x08027BB7)) return;
    abi.fetches(20);
    rt.r[1] = abi.read32(rt.r[13] +% 0x4);
    rt.r[2] = abi.read32(rt.r[13] +% 0x8);
    rt.r[0] = abi.read32(0x08027C2C);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
    abi.setRegNz(&rt.r[3], 0xC0);
    abi.setRegNz(&rt.r[3], rt.r[3] << 6);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
    rt.r[3] = abi.read32(0x08027C30);
    rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[3], true);
    rt.r[3] = abi.read32(0x08027C34);
    abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[3]);
    rt.r[3] = abi.read32(0x08027C38);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
    abi.copyRegFlags(&rt.r[2], rt.r[0]);
    abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[5]);
    abi.copyRegFlags(&rt.r[0], rt.r[4]);
    if (!abi.call(sprite_anim.func_08013598, 0x08027BDB)) return;
    abi.fetches(13);
    signExt16(6);
    rt.r[0] = rt.r[8];
    signExt16(0);
    rt.r[8] = rt.r[0];
    abi.copyRegFlags(&rt.r[0], rt.r[4]);
    abi.copyRegFlags(&rt.r[1], rt.r[6]);
    rt.r[2] = rt.r[8];
    if (!abi.call(sprite_anim.func_08013550, 0x08027BF1)) return;
    abi.fetches(5);
    abi.copyRegFlags(&rt.r[0], rt.r[4]);
    if (!abi.call(proc.func_080147B8, 0x08027BF7)) return;
    abi.fetches(5);
    abi.copyRegFlags(&rt.r[0], rt.r[4]);
    if (!abi.call(sprite_anim.func_080148DC, 0x08027BFD)) return;
    abi.fetches(8);
    abi.setRegNz(&rt.r[5], 0x80);
    abi.setRegNz(&rt.r[5], rt.r[5] << 2);
    abi.copyRegFlags(&rt.r[0], rt.r[4]);
    abi.copyRegFlags(&rt.r[1], rt.r[5]);
    if (!abi.call(sprite_anim.func_08013744, 0x08027C09)) return;
    abi.fetches(6);
    abi.copyRegFlags(&rt.r[0], rt.r[4]);
    abi.copyRegFlags(&rt.r[1], rt.r[5]);
    if (!abi.call(sprite_anim.func_08013794, 0x08027C11)) return;
    abi.fetches(6);
    abi.copyRegFlags(&rt.r[0], rt.r[4]);
    abi.setRegNz(&rt.r[1], 0x20);
    if (!abi.call(sprite_anim.func_08013878, 0x08027C19)) return;
    abi.fetches(8);
    rt.r[13] +%= 0xC;
    rt.r[3] = abi.popReg();
    rt.r[8] = rt.r[3];
    popRegsSeq(&.{ 4, 5, 6 });
    popReturnTo(0);
}

// --- Cluster 34: enter_0804FE74 (blocks 6..11) ---
fn run0804FE74(start_block: u32) void {
    blk: switch (start_block) {
        6 => {
            abi.fetches(4);
            abi.copyRegFlags(&rt.r[0], rt.r[4]);
            abi.copyRegFlags(&rt.r[1], rt.r[5]);
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(sprite_anim.func_08013744, 0x0804FEFB)) return;
            abi.fetches(6);
            abi.copyRegFlags(&rt.r[0], rt.r[4]);
            abi.copyRegFlags(&rt.r[1], rt.r[5]);
            if (!abi.call(sprite_anim.func_08013794, 0x0804FF03)) return;
            abi.fetches(3);
            rt.r[13] +%= 0x4;
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            continue :blk 11;
        },
        11 => {
            abi.fetches(6);
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6 });
            popReturnTo(0);
        },
        else => unreachable,
    }
}

pub fn func_0804FEF2() callconv(.c) void {
    if (!abi.enter(0x0804FEF2)) return;
    run0804FE74(6);
}

pub fn func_0804FEF6() callconv(.c) void {
    if (!abi.enter(0x0804FEF6)) return;
    run0804FE74(7);
}

pub fn func_0804FF04() callconv(.c) void {
    if (!abi.enter(0x0804FF04)) return;
    run0804FE74(10);
}

pub fn func_0804FF0A() callconv(.c) void {
    if (!abi.enter(0x0804FF0A)) return;
    run0804FE74(11);
}

// --- Cluster 35: enter_08014BF8 ---
pub fn func_08014BF8() callconv(.c) void {
    if (!abi.enter(0x08014BF8)) return;
    abi.fetches(16);
    pushRegs(&.{ 4, 5, 6, 14 });
    rt.r[6] = rt.r[9];
    rt.r[5] = rt.r[8];
    pushRegs(&.{ 5, 6 });
    rt.r[13] -%= 0x4;
    rt.r[9] = rt.r[0];
    rt.r[0] = abi.read32(0x08014C94);
    rt.r[1] = rt.r[9];
    abi.setRegNz(&rt.r[4], rt.r[1] << 4);
    rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
    abi.setRegNz(&rt.r[2], 0x4);
    rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
    if (!abi.call(math.func_0807AF30, 0x08014C15)) return;
    abi.fetches(8);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
    abi.setRegNz(&rt.r[2], 0x0);
    rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
    if (!abi.call(math.func_0807B488, 0x08014C21)) return;
    abi.fetches(10);
    rt.r[8] = rt.r[0];
    signExt16(0);
    rt.r[8] = rt.r[0];
    abi.setRegNz(&rt.r[1], 0x4);
    rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
    if (!abi.call(math.func_0807AED4, 0x08014C31)) return;
    abi.fetches(9);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
    negNzcv(0, rt.r[0]);
    abi.setRegNz(&rt.r[2], 0x2);
    rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
    if (!abi.call(math.func_0807B488, 0x08014C3F)) return;
    abi.fetches(9);
    abi.copyRegFlags(&rt.r[6], rt.r[0]);
    signExt16(6);
    abi.setRegNz(&rt.r[1], 0x4);
    rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
    if (!abi.call(math.func_0807AED4, 0x08014C4D)) return;
    abi.fetches(8);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
    abi.setRegNz(&rt.r[2], 0x0);
    rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
    if (!abi.call(math.func_0807B488, 0x08014C59)) return;
    abi.fetches(9);
    abi.copyRegFlags(&rt.r[5], rt.r[0]);
    signExt16(5);
    abi.setRegNz(&rt.r[1], 0x4);
    rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
    if (!abi.call(math.func_0807AF30, 0x08014C67)) return;
    abi.fetches(8);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
    abi.setRegNz(&rt.r[2], 0x2);
    rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
    if (!abi.call(math.func_0807B488, 0x08014C73)) return;
    abi.fetches(11);
    signExt16(0);
    abi.write32(rt.r[13] +% 0x0, rt.r[0]);
    rt.r[0] = rt.r[9];
    rt.r[1] = rt.r[8];
    abi.copyRegFlags(&rt.r[2], rt.r[6]);
    abi.copyRegFlags(&rt.r[3], rt.r[5]);
    if (!abi.call(sprite_anim.func_08014B54, 0x08014C85)) return;
    abi.fetches(9);
    rt.r[13] +%= 0x4;
    popRegsSeq(&.{ 3, 4 });
    rt.r[8] = rt.r[3];
    rt.r[9] = rt.r[4];
    popRegsSeq(&.{ 4, 5, 6 });
    popReturnTo(0);
}

pub fn func_0801A03C() callconv(.c) void {
    if (!abi.enter(0x0801A03C)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0801A060);
    abi.setRegNz(&rt.r[1], 0x0);
    abi.write32(rt.r[0] +% 0x0, rt.r[1]);
    rt.r[0] = abi.read32(0x0801A064);
    abi.setRegNz(&rt.r[2], 0x0);
    abi.setRegNz(&rt.r[1], 0x27);
    rt.r[3] = abi.read32(0x0801A068);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
    while (true) {
        abi.fetches(7);
        abi.write32(rt.r[0] +% 0x0, rt.r[2]);
        rt.cpuSub(&rt.r[0], rt.r[0], 0x4C, true);
        rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
        rt.cpuSub(null, rt.r[1], 0x0, true);
        if (rt.CPU_N != rt.CPU_V) break;
    }
    abi.fetches(4);
    if (!abi.call(func_0801A1FC, 0x0801A05D)) return;
    abi.fetches(4);
    popReturnTo(0);
}

// --- Cluster 36: enter_0802FCBC (blocks 14..24) ---
fn run0802FCBC(start_block: u32) void {
    if (start_block == 14) {
        abi.fetches(3);
    }
    abi.fetches(3);
    if (start_block == 14) {
        abi.fetches(3);
        if (!abi.call(hw.func_080104B0, 0x0802FCFB)) return;
        abi.fetches(3);
    }
    abi.fetches(4);
    if (!abi.call(low_peel_6.func_08010974, 0x0802FCFF)) return;
    abi.fetches(4);
    if (!abi.call(clusters_low_2.func_08042E24, 0x0802FD03)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x0802FD24);
    if (!abi.call(decls.func_08010D00, 0x0802FD09)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x0802FD28);
    if (!abi.call(low_peel_5.func_0806CBE8, 0x0802FD0F)) return;
    abi.fetches(4);
    if (!abi.call(clusters_low_2.func_0800FD54, 0x0802FD13)) return;
    abi.fetches(4);
    if (!abi.call(clusters_low_2.func_0800FBC4, 0x0802FD17)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_1.func_080117E0, 0x0802FD1B)) return;
    abi.fetches(7);
    rt.r[1] = abi.read32(0x0802FD2C);
    abi.setRegNz(&rt.r[0], 0x0);
    abi.write32(rt.r[1] +% 0x0, rt.r[0]);
    popReturnTo(0);
}

pub fn func_0802FCF4() callconv(.c) void {
    if (!abi.enter(0x0802FCF4)) return;
    run0802FCBC(14);
}

pub fn func_0802FCF8() callconv(.c) void {
    if (!abi.enter(0x0802FCF8)) return;
    run0802FCBC(16);
}

// --- Cluster 37: enter_080000E4 (reset/IRQ setup + palette fade + context save/restore) ---
pub fn func_080000C0() callconv(.c) void {
    if (!abi.enter(0x080000C0)) return;
    abi.fetches(20);
    rt.r[0] = 0x12;
    rt.cpu_set_cpsr(rt.r[0], 0x9);
    rt.r[15] = 0x080000D0;
    rt.r[13] = abi.read32(rt.r[15] +% 0x18);
    rt.r[0] = 0x1F;
    rt.cpu_set_cpsr(rt.r[0], 0x9);
    rt.r[15] = 0x080000DC;
    rt.r[13] = abi.read32(rt.r[15] +% 0x10);
    rt.r[15] = 0x080000E0;
    rt.r[1] = abi.read32(rt.r[15] +% 0x10);
    rt.r[15] = 0x080000E4;
    rt.r[14] = rt.r[15];
    rt.g_ret = 0;
    decls.awre_cpu_bx(rt.r[1]);
    if (!rt.recompCalled(0x080000E4)) return;
    abi.fetches(3);
}

pub fn func_080000E4() callconv(.c) void {
    if (!abi.enter(0x080000E4)) return;
    abi.fetches(3);
}

fn clampChannel(comptime reg: u5, addr: u32, off: u32) void {
    abi.fetches(12);
    rt.r[reg] = abi.read8(addr +% off);
    rt.r[reg] = rt.r[reg] +% rt.r[5];
    abi.write8(addr +% off, @truncate(rt.r[reg]));
    rt.cpuSub(&rt.r[reg], rt.r[reg], 0x20, true);
    if (rt.CPU_N) {
        abi.fetches(4);
        rt.r[reg] = 0x0;
    }
    abi.fetches(6);
    rt.cpuSub(null, rt.r[reg], 0x20, true);
    if (rt.CPU_C) {
        abi.fetches(4);
        rt.r[reg] = 0x1F;
    }
}

pub fn func_080796A8() callconv(.c) void {
    if (!abi.enter(0x080796A8)) return;
    abi.fetches(4);
    abi.fetches(6);
    {
        var addr: u32 = rt.r[13] +% 0xFFFFFFF0;
        rt.r[13] +%= 0xFFFFFFF0;
        inline for ([_]u5{ 4, 5, 6, 7 }) |reg| {
            abi.write32(addr, rt.r[reg]);
            addr +%= 4;
        }
    }
    rt.r[7] = 0x3E0;
    while (true) {
        abi.fetches(12);
        rt.r[15] = 0x08000110;
        rt.r[0] = abi.read32(rt.r[15] -% 0x14);
        rt.r[0] = rt.r[0] +% (rt.r[7] >> 5);
        rt.r[5] = rt.sext8(abi.read8(rt.r[0] +% 0x0));
        rt.updateNz(rt.r[5] & rt.r[5]);
        if (!rt.CPU_Z) {
            abi.fetches(14);
            rt.r[15] = 0x08000124;
            rt.r[4] = abi.read32(rt.r[15] -% 0x2C);
            rt.r[0] = rt.r[7] >> 1;
            rt.r[0] = rt.r[0] +% (rt.r[0] << 1);
            rt.r[0] = rt.r[0] +% 0x30;
            rt.r[4] = rt.r[4] +% rt.r[0];
            rt.r[6] = 0x1E;
            while (true) {
                abi.fetches(2); // extra 2 fetches for r4 -= 3 vs r1/r2 channel blocks (14 total)
                rt.r[4] = rt.r[4] -% 0x3;
                clampChannel(0, rt.r[4], 0x0);
                clampChannel(1, rt.r[4], 0x1);
                clampChannel(2, rt.r[4], 0x2);
                abi.fetches(16);
                rt.r[0] = rt.r[0] +% (rt.r[1] << 5);
                rt.r[0] = rt.r[0] +% (rt.r[2] << 10);
                rt.r[15] = 0x080001B4;
                rt.r[1] = abi.read32(rt.r[15] -% 0xC0);
                rt.r[1] = rt.r[1] +% rt.r[6];
                abi.write16(rt.r[1] +% rt.r[7], @truncate(rt.r[0]));
                rt.cpuSub(&rt.r[6], rt.r[6], 0x2, true);
                if (rt.CPU_N) break;
            }
        }
        abi.fetches(6);
        rt.cpuSub(&rt.r[7], rt.r[7], 0x20, true);
        if (rt.CPU_N) break;
    }
    abi.fetches(6);
    {
        var addr: u32 = rt.r[13];
        rt.r[13] +%= 0x10;
        inline for ([_]u5{ 4, 5, 6, 7 }, 0..) |reg, idx| {
            rt.r[reg] = if (idx == 0) rt.bus_read32(addr) else rt.bus_read32s(addr);
            addr +%= 4;
        }
    }
    abi.retLr();
}

pub fn func_080796B0() callconv(.c) void {
    if (!abi.enter(0x080796B0)) return;
    abi.fetches(4);
    abi.fetches(10);
    {
        var addr: u32 = rt.r[0];
        rt.r[0] +%= 0x2C;
        inline for (4..15) |reg| {
            abi.write32(addr, rt.r[reg]);
            addr +%= 4;
        }
    }
    rt.r[0] = 0x0;
    rt.updateNz(rt.r[14] & 0x1);
    if (rt.CPU_Z) {
        rt.r[15] = rt.r[14];
        abi.retLr();
        return;
    }
    abi.fetches(4);
    abi.retLr();
}

pub fn func_080796B8() callconv(.c) void {
    if (!abi.enter(0x080796B8)) return;
    abi.fetches(4);
    abi.fetches(12);
    {
        var addr: u32 = rt.r[0];
        rt.r[0] +%= 0x2C;
        inline for (4..15, 0..) |reg, idx| {
            rt.r[reg] = if (idx == 0) rt.bus_read32(addr) else rt.bus_read32s(addr);
            addr +%= 4;
        }
    }
    rt.r[0] = rt.r[1];
    rt.updateNz(rt.r[0]);
    if (rt.CPU_Z) {
        rt.r[0] = 0x1;
    }
    rt.updateNz(rt.r[14] & 0x1);
    if (rt.CPU_Z) {
        rt.r[15] = rt.r[14];
        abi.retLr();
        return;
    }
    abi.fetches(4);
    abi.retLr();
}

// --- Cluster 38: enter_08078728 + enter_08078934 ---
fn run08078728(start_block: u32) void {
    blk: switch (start_block) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.copyRegFlags(&rt.r[2], rt.r[0]);
            rt.r[0] = abi.read32(0x080787A8);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[6], 0x0);
            abi.write8(rt.r[4] +% 0x8, @truncate(rt.r[2]));
            rt.r[1] = abi.read32(0x080787AC);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[5] = abi.read16(rt.r[0] +% 0x0);
            abi.write32(rt.r[4] +% 0x10, rt.r[5]);
            abi.setRegNz(&rt.r[0], 0xC6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            abi.copyRegFlags(&rt.r[1], rt.r[5]);
            if (!abi.call(math.func_0807B488, 0x08078753)) return;
            abi.fetches(10);
            abi.write8(rt.r[4] +% 0xB, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080787B0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.r[1] = abi.read32(0x080787B4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x080787B8);
            if (!abi.call(math.func_0807B488, 0x08078763)) return;
            abi.fetches(8);
            abi.copyRegFlags(&rt.r[1], rt.r[0]);
            abi.write32(rt.r[4] +% 0x14, rt.r[1]);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 17);
            if (!abi.call(math.func_0807B488, 0x0807876F)) return;
            abi.fetches(12);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            abi.write32(rt.r[4] +% 0x18, rt.r[0]);
            rt.r[0] = abi.read32(0x080787BC);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.r[4] = abi.read32(0x080787C0);
            rt.r[0] = abi.read32(0x080787C4);
            abi.copyRegFlags(&rt.r[1], rt.r[5]);
            if (!abi.call(math.func_0807B488, 0x08078783)) return;
            abi.fetches(6);
            negNzcv(0, rt.r[0]);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(func_08078934, 0x0807878B)) return;
            abi.fetches(3);
            rt.r[1] = abi.read32(0x080787C8);
            while (true) {
                abi.fetches(5);
                rt.r[0] = abi.read8(rt.r[1] +% 0x0);
                rt.cpuSub(null, rt.r[0], 0x9F, true);
                if (!rt.CPU_Z) break;
            }
            abi.fetches(3);
            rt.r[1] = abi.read32(0x080787C8);
            while (true) {
                abi.fetches(5);
                rt.r[0] = abi.read8(rt.r[1] +% 0x0);
                rt.cpuSub(null, rt.r[0], 0x9F, true);
                if (rt.CPU_Z) break;
            }
            abi.fetches(8);
            rt.r[1] = abi.read32(0x080787BC);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6 });
            popReturnTo(0);
        },
        10 => {
            abi.fetches(12);
            abi.copyRegFlags(&rt.r[0], rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xA, true);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            rt.r[1] = abi.read32(0x08078920);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 18);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                abi.fetches(4);
                rt.r[0] = abi.read32(0x08078924);
                abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            }
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08078928);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                abi.fetches(4);
                rt.r[0] = abi.read32(0x08078924);
                abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            }
            abi.fetches(18);
            rt.r[0] = abi.read32(0x0807892C);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 3);
            abi.copyRegFlags(&rt.r[1], rt.r[3]);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xC, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0xD4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[0], true);
            rt.r[2] = abi.read32(0x08078930);
            rt.r[0] = rt.r[13];
            if (!abi.call(bios.func_080796C4, 0x08078911)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(5);
            rt.r[13] +%= 0x4;
            popReturnTo(0);
        },
        16 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x10, true);
            if (rt.CPU_C and !rt.CPU_Z) {
                abi.fetches(3);
                abi.setRegNz(&rt.r[4], 0x10);
            }
            abi.fetches(8);
            rt.r[0] = abi.read32(0x080789DC);
            rt.r[5] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read32(0x080789E0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 24;
            }
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            abi.copyRegFlags(&rt.r[0], rt.r[7]);
            if (!abi.call(sound.func_0807861C, 0x0807899B)) return;
            abi.fetches(9);
            abi.write32(rt.r[7] +% 0x2C, rt.r[6]);
            abi.write8(rt.r[7] +% 0x8, @truncate(rt.r[4]));
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.write32(rt.r[7] +% 0x4, rt.r[0]);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                abi.fetches(3);
                abi.setRegNz(&rt.r[1], 0x0);
                while (true) {
                    abi.fetches(9);
                    abi.write8(rt.r[6] +% 0x0, @truncate(rt.r[1]));
                    rt.cpuSub(&rt.r[0], rt.r[4], 0x1, true);
                    abi.setRegNz(&rt.r[0], rt.r[0] << 24);
                    abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
                    rt.cpuAdd(&rt.r[6], rt.r[6], 0x50, true);
                    rt.cpuSub(null, rt.r[4], 0x0, true);
                    if (rt.CPU_Z) break;
                }
            }
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[5] +% 0x20);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            run08078934(if (rt.CPU_Z) 4 else 3);
        },
        24 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popReturnTo(0);
        },
        else => unreachable,
    }
}

fn run08078934(start_block: u32) void {
    switch (start_block) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x08078964);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read32(0x08078968);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_Z) {
                abi.fetches(15);
                rt.r[0] = abi.read32(0x0807896C);
                abi.setRegNz(&rt.r[4], 0xB6);
                abi.setRegNz(&rt.r[4], rt.r[4] << 8);
                abi.copyRegFlags(&rt.r[1], rt.r[4]);
                abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
                rt.cpuAdd(&rt.r[0], rt.r[0], 0xC, true);
                abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
                rt.r[0] = abi.read8(rt.r[2] +% 0x4);
                abi.setRegNz(&rt.r[0], 0x0);
                abi.write8(rt.r[2] +% 0x4, @truncate(rt.r[0]));
                abi.copyRegFlags(&rt.r[0], rt.r[3]);
                rt.cpuSub(&rt.r[0], rt.r[0], 0xA, true);
                abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            }
            abi.fetches(5);
            rt.r[4] = abi.popReg();
            popReturnTo(0);
        },
        3 => {
            abi.fetches(7);
            abi.write32(rt.r[7] +% 0x38, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[5] +% 0x24);
            abi.write32(rt.r[7] +% 0x3C, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[5] +% 0x20, rt.r[0]);
            abi.fetches(8);
            abi.write32(rt.r[5] +% 0x24, rt.r[7]);
            rt.r[0] = abi.read32(0x080789E4);
            abi.write32(rt.r[5] +% 0x20, rt.r[0]);
            rt.r[0] = abi.read32(0x080789E0);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            abi.write32(rt.r[7] +% 0x34, rt.r[0]);
            run08078728(24);
        },
        4 => {
            abi.fetches(8);
            abi.write32(rt.r[5] +% 0x24, rt.r[7]);
            rt.r[0] = abi.read32(0x080789E4);
            abi.write32(rt.r[5] +% 0x20, rt.r[0]);
            rt.r[0] = abi.read32(0x080789E0);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            abi.write32(rt.r[7] +% 0x34, rt.r[0]);
            run08078728(24);
        },
        else => unreachable,
    }
}

pub fn func_08078728() callconv(.c) void {
    if (!abi.enter(0x08078728)) return;
    run08078728(0);
}

pub fn func_080788B8() callconv(.c) void {
    if (!abi.enter(0x080788B8)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 0x4;
    rt.r[0] = abi.read32(0x08078918);
    rt.r[2] = abi.read32(rt.r[0] +% 0x0);
    rt.r[1] = abi.read32(rt.r[2] +% 0x0);
    rt.r[3] = abi.read32(0x0807891C);
    rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
    rt.cpuSub(null, rt.r[0], 0x1, true);
    run08078728(if (rt.CPU_C and !rt.CPU_Z) 15 else 10);
}

pub fn func_08078934() callconv(.c) void {
    if (!abi.enter(0x08078934)) return;
    run08078934(0);
}

pub fn func_08078970() callconv(.c) void {
    if (!abi.enter(0x08078970)) return;
    abi.fetches(9);
    pushRegs(&.{ 4, 5, 6, 7, 14 });
    abi.copyRegFlags(&rt.r[7], rt.r[0]);
    abi.copyRegFlags(&rt.r[6], rt.r[1]);
    abi.setRegNz(&rt.r[2], rt.r[2] << 24);
    abi.setRegNz(&rt.r[4], rt.r[2] >> 24);
    rt.cpuSub(null, rt.r[4], 0x0, true);
    run08078728(if (rt.CPU_Z) 24 else 16);
}

// --- Cluster 39: enter_0805EC80 (blocks 31..39) ---
fn run0805EC80(start_block: u32) void {
    if (start_block == 31) {
        abi.fetches(5);
        abi.setRegNz(&rt.r[1], 0x20);
        if (!abi.call(low_peel_6.func_0800FB58, 0x0805EDF3)) return;
    }
    const items = [_]struct { off: u32, y: u32, lr: u32 }{
        .{ .off = 0x16, .y = 0x28, .lr = 0x0805EDFD },
        .{ .off = 0x18, .y = 0x30, .lr = 0x0805EE07 },
        .{ .off = 0x1A, .y = 0x38, .lr = 0x0805EE11 },
        .{ .off = 0x1C, .y = 0x40, .lr = 0x0805EE1B },
        .{ .off = 0x0E, .y = 0x48, .lr = 0x0805EE25 },
    };
    inline for (items) |it| {
        abi.fetches(7);
        rt.r[2] = abi.read16(rt.r[4] +% it.off);
        abi.setRegNz(&rt.r[0], 0xC0);
        abi.setRegNz(&rt.r[1], it.y);
        if (!abi.call(low_peel_6.func_0800FB58, it.lr)) return;
    }
    abi.fetches(7);
    rt.r[2] = abi.read32(0x0805EE94);
    abi.setRegNz(&rt.r[0], 0x10);
    abi.setRegNz(&rt.r[1], 0x7C);
    if (!abi.call(low_peel_6.func_0800FADC, 0x0805EE2F)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(0x0805EE98);
    rt.r[2] = abi.read16(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[0], 0x50);
    abi.setRegNz(&rt.r[1], 0x7C);
    if (!abi.call(low_peel_6.func_0800FB58, 0x0805EE3B)) return;
    abi.fetches(9);
    popRegsSeq(&.{ 3, 4, 5 });
    rt.r[8] = rt.r[3];
    rt.r[9] = rt.r[4];
    rt.r[10] = rt.r[5];
    popRegsSeq(&.{ 4, 5, 6, 7 });
    popReturnTo(0);
}

pub fn func_0805EDEC() callconv(.c) void {
    if (!abi.enter(0x0805EDEC)) return;
    run0805EC80(31);
}

pub fn func_0805EDF2() callconv(.c) void {
    if (!abi.enter(0x0805EDF2)) return;
    run0805EC80(32);
}

comptime {
    if (!builtin.is_test) {
        @export(&func_0803FD0C, .{ .name = "func_0803FD0C", .linkage = .strong });
        @export(&func_0800F8FC, .{ .name = "func_0800F8FC", .linkage = .strong });
        @export(&func_0800F902, .{ .name = "func_0800F902", .linkage = .strong });
        @export(&func_08070500, .{ .name = "func_08070500", .linkage = .strong });
        @export(&func_08070502, .{ .name = "func_08070502", .linkage = .strong });
        @export(&func_08070504, .{ .name = "func_08070504", .linkage = .strong });
        @export(&func_08070506, .{ .name = "func_08070506", .linkage = .strong });
        @export(&func_08037950, .{ .name = "func_08037950", .linkage = .strong });
        @export(&func_0801A768, .{ .name = "func_0801A768", .linkage = .strong });
        @export(&func_0801A784, .{ .name = "func_0801A784", .linkage = .strong });
        @export(&func_0801A78A, .{ .name = "func_0801A78A", .linkage = .strong });
        @export(&func_0805220E, .{ .name = "func_0805220E", .linkage = .strong });
        @export(&func_080700EE, .{ .name = "func_080700EE", .linkage = .strong });
        @export(&func_080700FA, .{ .name = "func_080700FA", .linkage = .strong });
        @export(&func_08041F0C, .{ .name = "func_08041F0C", .linkage = .strong });
        @export(&func_08041F10, .{ .name = "func_08041F10", .linkage = .strong });
        @export(&func_08060600, .{ .name = "func_08060600", .linkage = .strong });
        @export(&func_08060602, .{ .name = "func_08060602", .linkage = .strong });
        @export(&func_08060604, .{ .name = "func_08060604", .linkage = .strong });
        @export(&func_08060606, .{ .name = "func_08060606", .linkage = .strong });
        @export(&func_08060608, .{ .name = "func_08060608", .linkage = .strong });
        @export(&func_0803F008, .{ .name = "func_0803F008", .linkage = .strong });
        @export(&func_0802F9F6, .{ .name = "func_0802F9F6", .linkage = .strong });
        @export(&func_08044374, .{ .name = "func_08044374", .linkage = .strong });
        @export(&func_080305F0, .{ .name = "func_080305F0", .linkage = .strong });
        @export(&func_080305F4, .{ .name = "func_080305F4", .linkage = .strong });
        @export(&func_08014AF0, .{ .name = "func_08014AF0", .linkage = .strong });
        @export(&func_08014B14, .{ .name = "func_08014B14", .linkage = .strong });
        @export(&func_0801A1FC, .{ .name = "func_0801A1FC", .linkage = .strong });
        @export(&func_0801F7F0, .{ .name = "func_0801F7F0", .linkage = .strong });
        @export(&func_0801F800, .{ .name = "func_0801F800", .linkage = .strong });
        @export(&func_0801F804, .{ .name = "func_0801F804", .linkage = .strong });
        @export(&func_08003502, .{ .name = "func_08003502", .linkage = .strong });
        @export(&func_0800FB9C, .{ .name = "func_0800FB9C", .linkage = .strong });
        @export(&func_0800FBBC, .{ .name = "func_0800FBBC", .linkage = .strong });
        @export(&func_0801FFF6, .{ .name = "func_0801FFF6", .linkage = .strong });
        @export(&func_08003542, .{ .name = "func_08003542", .linkage = .strong });
        @export(&func_08020D00, .{ .name = "func_08020D00", .linkage = .strong });
        @export(&func_08041F50, .{ .name = "func_08041F50", .linkage = .strong });
        @export(&func_08041F54, .{ .name = "func_08041F54", .linkage = .strong });
        @export(&func_08074442, .{ .name = "func_08074442", .linkage = .strong });
        @export(&func_080501F6, .{ .name = "func_080501F6", .linkage = .strong });
        @export(&func_080501FE, .{ .name = "func_080501FE", .linkage = .strong });
        @export(&func_08050200, .{ .name = "func_08050200", .linkage = .strong });
        @export(&func_08050204, .{ .name = "func_08050204", .linkage = .strong });
        @export(&func_08040300, .{ .name = "func_08040300", .linkage = .strong });
        @export(&func_08040304, .{ .name = "func_08040304", .linkage = .strong });
        @export(&func_08070B0C, .{ .name = "func_08070B0C", .linkage = .strong });
        @export(&func_080703FE, .{ .name = "func_080703FE", .linkage = .strong });
        @export(&func_08070400, .{ .name = "func_08070400", .linkage = .strong });
        @export(&func_08070402, .{ .name = "func_08070402", .linkage = .strong });
        @export(&func_08070404, .{ .name = "func_08070404", .linkage = .strong });
        @export(&func_0800FDF8, .{ .name = "func_0800FDF8", .linkage = .strong });
        @export(&func_08070300, .{ .name = "func_08070300", .linkage = .strong });
        @export(&func_08070302, .{ .name = "func_08070302", .linkage = .strong });
        @export(&func_08052368, .{ .name = "func_08052368", .linkage = .strong });
        @export(&func_080781B4, .{ .name = "func_080781B4", .linkage = .strong });
        @export(&func_0801319C, .{ .name = "func_0801319C", .linkage = .strong });
        @export(&func_0801B820, .{ .name = "func_0801B820", .linkage = .strong });
        @export(&func_0803D6DC, .{ .name = "func_0803D6DC", .linkage = .strong });
        @export(&func_0803070C, .{ .name = "func_0803070C", .linkage = .strong });
        @export(&func_08027B7E, .{ .name = "func_08027B7E", .linkage = .strong });
        @export(&func_0804FEF2, .{ .name = "func_0804FEF2", .linkage = .strong });
        @export(&func_0804FEF6, .{ .name = "func_0804FEF6", .linkage = .strong });
        @export(&func_0804FF04, .{ .name = "func_0804FF04", .linkage = .strong });
        @export(&func_0804FF0A, .{ .name = "func_0804FF0A", .linkage = .strong });
        @export(&func_08014BF8, .{ .name = "func_08014BF8", .linkage = .strong });
        @export(&func_0801A03C, .{ .name = "func_0801A03C", .linkage = .strong });
        @export(&func_0802FCF4, .{ .name = "func_0802FCF4", .linkage = .strong });
        @export(&func_0802FCF8, .{ .name = "func_0802FCF8", .linkage = .strong });
        @export(&func_080000C0, .{ .name = "func_080000C0", .linkage = .strong });
        @export(&func_080000E4, .{ .name = "func_080000E4", .linkage = .strong });
        @export(&func_080796A8, .{ .name = "func_080796A8", .linkage = .strong });
        @export(&func_080796B0, .{ .name = "func_080796B0", .linkage = .strong });
        @export(&func_080796B8, .{ .name = "func_080796B8", .linkage = .strong });
        @export(&func_08078728, .{ .name = "func_08078728", .linkage = .strong });
        @export(&func_080788B8, .{ .name = "func_080788B8", .linkage = .strong });
        @export(&func_08078934, .{ .name = "func_08078934", .linkage = .strong });
        @export(&func_08078970, .{ .name = "func_08078970", .linkage = .strong });
        @export(&func_0805EDEC, .{ .name = "func_0805EDEC", .linkage = .strong });
        @export(&func_0805EDF2, .{ .name = "func_0805EDF2", .linkage = .strong });
    }
}

test "clusters_low ROM entry export is callable" {
    try std.testing.expect(@TypeOf(func_080000C0) == fn () callconv(.c) void);
    try std.testing.expect(@TypeOf(func_080000E4) == fn () callconv(.c) void);
}
