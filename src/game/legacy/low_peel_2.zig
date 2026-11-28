//! Low-ROM (`< 0x08080000`) block-peeled wave 2 (`<= 30` reachable lines, remaining 186).

const std = @import("std");
const rt = @import("runtime");
const abi = @import("../abi.zig");
const dispatch = @import("../dispatch.zig");
const hal = @import("../hal.zig");
const hw = @import("../hw.zig");
const low_peel_1 = @import("low_peel_1.zig");
const low_peel_18 = @import("low_peel_18.zig");
const low_peel_5 = @import("low_peel_5.zig");
const low_peel_7 = @import("low_peel_7.zig");
const low_peel_9 = @import("low_peel_9.zig");
const proc = @import("../proc.zig");
const sound = @import("../sound.zig");
const sprite_anim = @import("../sprite_anim.zig");
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

pub fn func_08036DD8() callconv(.c) void {
    if (!abi.enter(0x08036DD8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036DE8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036DEC);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036DF8);
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

pub fn func_08036DFC() callconv(.c) void {
    if (!abi.enter(0x08036DFC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036E0C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036E10);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036E1C);
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

pub fn func_08036E20() callconv(.c) void {
    if (!abi.enter(0x08036E20)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036E30);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036E34);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036E40);
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

pub fn func_08036E50() callconv(.c) void {
    if (!abi.enter(0x08036E50)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036E60);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036E64);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036E70);
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

pub fn func_08036E74() callconv(.c) void {
    if (!abi.enter(0x08036E74)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036E84);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036E88);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036E94);
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

pub fn func_08036E98() callconv(.c) void {
    if (!abi.enter(0x08036E98)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036EA8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036EAC);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036EB8);
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

pub fn func_08036EBC() callconv(.c) void {
    if (!abi.enter(0x08036EBC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036ECC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036ED0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036EDC);
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

pub fn func_08036EE0() callconv(.c) void {
    if (!abi.enter(0x08036EE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036EF0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036EF4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036F00);
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

pub fn func_08036F04() callconv(.c) void {
    if (!abi.enter(0x08036F04)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036F14);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036F18);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036F24);
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

pub fn func_08036F28() callconv(.c) void {
    if (!abi.enter(0x08036F28)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036F38);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036F3C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036F48);
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

pub fn func_08036F4C() callconv(.c) void {
    if (!abi.enter(0x08036F4C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036F5C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036F60);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036F6C);
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

pub fn func_08036F70() callconv(.c) void {
    if (!abi.enter(0x08036F70)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036F80);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036F84);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036F90);
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

pub fn func_08036F94() callconv(.c) void {
    if (!abi.enter(0x08036F94)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036FA4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036FA8);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036FB4);
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

pub fn func_08036FB8() callconv(.c) void {
    if (!abi.enter(0x08036FB8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036FC8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036FCC);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036FD8);
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

pub fn func_08036FDC() callconv(.c) void {
    if (!abi.enter(0x08036FDC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036FEC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036FF0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036FFC);
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

pub fn func_08037000() callconv(.c) void {
    if (!abi.enter(0x08037000)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037010);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037014);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037020);
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

pub fn func_08037024() callconv(.c) void {
    if (!abi.enter(0x08037024)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037034);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037038);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037044);
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

pub fn func_08037054() callconv(.c) void {
    if (!abi.enter(0x08037054)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037064);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037068);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037074);
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

pub fn func_080370B0() callconv(.c) void {
    if (!abi.enter(0x080370B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x080370C8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xD0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x12);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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
            rt.r[0] = abi.read32(0x080370CC);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080370DC() callconv(.c) void {
    if (!abi.enter(0x080370DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080370EC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x080370F0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080370FC);
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

pub fn func_08037100() callconv(.c) void {
    if (!abi.enter(0x08037100)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037110);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037114);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037120);
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

pub fn func_080371F4() callconv(.c) void {
    if (!abi.enter(0x080371F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037204);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037208);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037214);
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

pub fn func_08037224() callconv(.c) void {
    if (!abi.enter(0x08037224)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037234);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037238);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037244);
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

pub fn func_08037254() callconv(.c) void {
    if (!abi.enter(0x08037254)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08037260);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0803726C);
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

pub fn func_08037270() callconv(.c) void {
    if (!abi.enter(0x08037270)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803727C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xA, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037288);
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

pub fn func_0803728C() callconv(.c) void {
    if (!abi.enter(0x0803728C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08037298);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x9, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080372A4);
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

pub fn func_080372A8() callconv(.c) void {
    if (!abi.enter(0x080372A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080372B8);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
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
            rt.r[1] = abi.read32(0x080372BC);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080372C0() callconv(.c) void {
    if (!abi.enter(0x080372C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080372D0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x3, true);
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
            rt.r[1] = abi.read32(0x080372D4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080372D8() callconv(.c) void {
    if (!abi.enter(0x080372D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080372E8);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xA, true);
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080372EC);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080372F0() callconv(.c) void {
    if (!abi.enter(0x080372F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08037300);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x9, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
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
            rt.r[1] = abi.read32(0x08037304);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037308() callconv(.c) void {
    if (!abi.enter(0x08037308)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037318);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0803731C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037328);
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

pub fn func_0803732C() callconv(.c) void {
    if (!abi.enter(0x0803732C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0803733C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037340);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0803734C);
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

pub fn func_08037350() callconv(.c) void {
    if (!abi.enter(0x08037350)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037360);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037364);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037370);
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

pub fn func_08037374() callconv(.c) void {
    if (!abi.enter(0x08037374)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037384);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037388);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037394);
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

pub fn func_080373A4() callconv(.c) void {
    if (!abi.enter(0x080373A4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080373B4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x080373B8);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080373C4);
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

pub fn func_080373D4() callconv(.c) void {
    if (!abi.enter(0x080373D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080373E4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x080373E8);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080373F4);
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

pub fn func_080373F8() callconv(.c) void {
    if (!abi.enter(0x080373F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037408);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0803740C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037418);
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

pub fn func_08037428() callconv(.c) void {
    if (!abi.enter(0x08037428)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037438);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0803743C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037448);
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

pub fn func_0803744C() callconv(.c) void {
    if (!abi.enter(0x0803744C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0803745C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037460);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0803746C);
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

pub fn func_08037470() callconv(.c) void {
    if (!abi.enter(0x08037470)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037480);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037484);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037490);
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

pub fn func_08037494() callconv(.c) void {
    if (!abi.enter(0x08037494)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080374A4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x080374A8);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080374B4);
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

pub fn func_080374B8() callconv(.c) void {
    if (!abi.enter(0x080374B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080374C8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x080374CC);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080374D8);
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

pub fn func_080374DC() callconv(.c) void {
    if (!abi.enter(0x080374DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080374EC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x080374F0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080374FC);
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

pub fn func_08037500() callconv(.c) void {
    if (!abi.enter(0x08037500)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037510);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037514);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037520);
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

pub fn func_08037524() callconv(.c) void {
    if (!abi.enter(0x08037524)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037534);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037538);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037544);
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

pub fn func_08037554() callconv(.c) void {
    if (!abi.enter(0x08037554)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037564);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037568);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037574);
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

pub fn func_08037584() callconv(.c) void {
    if (!abi.enter(0x08037584)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037594);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037598);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080375A4);
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

pub fn func_080375A8() callconv(.c) void {
    if (!abi.enter(0x080375A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080375B8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x080375BC);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080375C8);
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

pub fn func_080375CC() callconv(.c) void {
    if (!abi.enter(0x080375CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080375DC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x080375E0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080375EC);
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

pub fn func_080375F0() callconv(.c) void {
    if (!abi.enter(0x080375F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037600);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037604);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037610);
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

pub fn func_08037614() callconv(.c) void {
    if (!abi.enter(0x08037614)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08037620);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0803762C);
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

pub fn func_0803765C() callconv(.c) void {
    if (!abi.enter(0x0803765C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0803767C);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x1);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08037680);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037684() callconv(.c) void {
    if (!abi.enter(0x08037684)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080376A4);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080376A8);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080376AC() callconv(.c) void {
    if (!abi.enter(0x080376AC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080376CC);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080376D0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037700() callconv(.c) void {
    if (!abi.enter(0x08037700)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037710);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037714);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037720);
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

pub fn func_08037724() callconv(.c) void {
    if (!abi.enter(0x08037724)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037734);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037738);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037744);
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

pub fn func_08037748() callconv(.c) void {
    if (!abi.enter(0x08037748)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037758);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0803775C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037768);
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

pub fn func_080377F4() callconv(.c) void {
    if (!abi.enter(0x080377F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08037814);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x1);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08037818);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0803781C() callconv(.c) void {
    if (!abi.enter(0x0803781C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0803782C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037830);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0803783C);
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

pub fn func_08037840() callconv(.c) void {
    if (!abi.enter(0x08037840)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08037860);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08037864);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037868() callconv(.c) void {
    if (!abi.enter(0x08037868)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08037888);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0803788C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037890() callconv(.c) void {
    if (!abi.enter(0x08037890)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080378B0);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080378B4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0803799C() callconv(.c) void {
    if (!abi.enter(0x0803799C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x080379B4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xD0, true);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.r[1] = abi.read8(rt.r[1] +% 0x12);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080379B8);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080379BC() callconv(.c) void {
    if (!abi.enter(0x080379BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x080379D0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x85, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x4, true);
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
            rt.r[1] = abi.read32(0x080379D4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080379D8() callconv(.c) void {
    if (!abi.enter(0x080379D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x080379EC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x85, true);
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
            rt.r[1] = abi.read32(0x080379F0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080379F4() callconv(.c) void {
    if (!abi.enter(0x080379F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08037A08);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x85, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x1, true);
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
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08037A0C);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037A10() callconv(.c) void {
    if (!abi.enter(0x08037A10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08037A24);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x85, true);
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
            rt.r[1] = abi.read32(0x08037A28);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037A2C() callconv(.c) void {
    if (!abi.enter(0x08037A2C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08037A3C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x8, true);
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037A40);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037A54() callconv(.c) void {
    if (!abi.enter(0x08037A54)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08037A68);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x85, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x1, true);
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
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08037A6C);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037A70() callconv(.c) void {
    if (!abi.enter(0x08037A70)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08037A84);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x85, true);
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
            rt.r[1] = abi.read32(0x08037A88);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037AEC() callconv(.c) void {
    if (!abi.enter(0x08037AEC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08037B04);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xD0, true);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.r[1] = abi.read8(rt.r[1] +% 0x12);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037B08);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037BC8() callconv(.c) void {
    if (!abi.enter(0x08037BC8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08037BE0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xD0, true);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.r[1] = abi.read8(rt.r[1] +% 0x12);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037BE4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037C08() callconv(.c) void {
    if (!abi.enter(0x08037C08)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08037C20);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xD0, true);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.r[1] = abi.read8(rt.r[1] +% 0x12);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037C24);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037CB8() callconv(.c) void {
    if (!abi.enter(0x08037CB8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08037CD0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xD0, true);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.r[1] = abi.read8(rt.r[1] +% 0x12);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037CD4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037D08() callconv(.c) void {
    if (!abi.enter(0x08037D08)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08037D1C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x85, true);
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
            rt.r[1] = abi.read32(0x08037D20);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037D24() callconv(.c) void {
    if (!abi.enter(0x08037D24)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08037D38);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x85, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x4, true);
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
            rt.r[1] = abi.read32(0x08037D3C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037D40() callconv(.c) void {
    if (!abi.enter(0x08037D40)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037D54);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3F, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x5, true);
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
            rt.r[1] = abi.read32(0x08037D58);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037D5C() callconv(.c) void {
    if (!abi.enter(0x08037D5C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037D70);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3F, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x3, true);
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
            rt.r[1] = abi.read32(0x08037D74);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037D78() callconv(.c) void {
    if (!abi.enter(0x08037D78)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037D8C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x8, true);
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
            rt.r[1] = abi.read32(0x08037D90);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037D94() callconv(.c) void {
    if (!abi.enter(0x08037D94)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037DA8);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x6, true);
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
            rt.r[1] = abi.read32(0x08037DAC);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037DB0() callconv(.c) void {
    if (!abi.enter(0x08037DB0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037DC4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x9, true);
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
            rt.r[1] = abi.read32(0x08037DC8);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08037F28() callconv(.c) void {
    if (!abi.enter(0x08037F28)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08037F34);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
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

pub fn func_08037F3C() callconv(.c) void {
    if (!abi.enter(0x08037F3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037F50);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x21, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037F54);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0803826C() callconv(.c) void {
    if (!abi.enter(0x0803826C)) return;
    abi.fetches(5);
    rt.r[1] = abi.read32(0x08038274);
    abi.write32(rt.r[1] +% 0x0, rt.r[0]);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08038278() callconv(.c) void {
    if (!abi.enter(0x08038278)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x08038280);
    rt.r[0] = abi.read32(rt.r[0] +% 0x0);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08038290() callconv(.c) void {
    if (!abi.enter(0x08038290)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x080382A4);
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
            if (!abi.call(tail_low.func_0807B44C, 0x0803829F)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080395A8() callconv(.c) void {
    if (!abi.enter(0x080395A8)) return;
    abi.fetches(5);
    rt.r[1] = abi.read32(0x080395B0);
    abi.write32(rt.r[1] +% 0x0, rt.r[0]);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080399E0() callconv(.c) void {
    if (!abi.enter(0x080399E0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08039A00);
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
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x08039A04);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08039A08);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08039CAC() callconv(.c) void {
    if (!abi.enter(0x08039CAC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08039CBC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            rt.r[1] = abi.read32(0x08039CC0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0803A6B4() callconv(.c) void {
    if (!abi.enter(0x0803A6B4)) return;
    abi.fetches(3);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0803A6B8() callconv(.c) void {
    if (!abi.enter(0x0803A6B8)) return;
    abi.fetches(8);
    rt.r[3] = abi.read32(0x0803A6C4);
    rt.r[2] = abi.read32(rt.r[3] +% 0x0);
    abi.write8(rt.r[2] +% 0x1E, @truncate(rt.r[0]));
    rt.r[0] = abi.read32(rt.r[3] +% 0x0);
    abi.write8(rt.r[0] +% 0x1F, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0803D598() callconv(.c) void {
    if (!abi.enter(0x0803D598)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803D5A8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0803D5AC);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0803DFA0() callconv(.c) void {
    if (!abi.enter(0x0803DFA0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0803DFB0);
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x2);
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

pub fn func_0803E008() callconv(.c) void {
    if (!abi.enter(0x0803E008)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0803E018);
            rt.r[0] = abi.read8(rt.r[0] +% 0x3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x2);
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

pub fn func_0803E024() callconv(.c) void {
    if (!abi.enter(0x0803E024)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803E030);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
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

pub fn func_0803E060() callconv(.c) void {
    if (!abi.enter(0x0803E060)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803E06C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
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

pub fn func_0803EFCC() callconv(.c) void {
    if (!abi.enter(0x0803EFCC)) return;
    abi.fetches(13);
    rt.r[1] = abi.read32(0x0803EFE4);
    abi.setRegNz(&rt.r[2], rt.r[0] >> 3);
    rt.cpuAdd(&rt.r[1], rt.r[1], 0x3, true);
    rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
    abi.setRegNz(&rt.r[1], 0x7);
    abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
    abi.setRegNz(&rt.r[0], 0x1);
    abi.setRegNz(&rt.r[0], rt.armLsl(rt.r[0], rt.r[1] & 0xFF));
    rt.r[2] = abi.read8(rt.r[2] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0803F02C() callconv(.c) void {
    if (!abi.enter(0x0803F02C)) return;
    abi.fetches(13);
    rt.r[1] = abi.read32(0x0803F044);
    abi.setRegNz(&rt.r[2], rt.r[0] >> 3);
    rt.cpuAdd(&rt.r[1], rt.r[1], 0x1A, true);
    rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
    abi.setRegNz(&rt.r[1], 0x7);
    abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
    abi.setRegNz(&rt.r[0], 0x1);
    abi.setRegNz(&rt.r[0], rt.armLsl(rt.r[0], rt.r[1] & 0xFF));
    rt.r[2] = abi.read8(rt.r[2] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0803F128() callconv(.c) void {
    if (!abi.enter(0x0803F128)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.r[2] = abi.read32(0x0803F13C);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 19);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x15);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0803F144);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0803FB00() callconv(.c) void {
    if (!abi.enter(0x0803FB00)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0803FB14);
            abi.setRegNz(&rt.r[1], 0x4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
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

pub fn func_080401FE() callconv(.c) void {
    if (!abi.enter(0x080401FE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if (!abi.call(sprite_anim.func_08013744, 0x08040203)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(sprite_anim.func_08013794, 0x0804020D)) return;
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

pub fn func_08040200() callconv(.c) void {
    if (!abi.enter(0x08040200)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(sprite_anim.func_08013794, 0x0804020D)) return;
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

pub fn func_08040602() callconv(.c) void {
    if (!abi.enter(0x08040602)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x83, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read32(0x08040624);
            rt.r[3] = abi.read32(0x08040628);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!hw.drawDispatchCall(0x08040617)) return;
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

pub fn func_08041C58() callconv(.c) void {
    if (!abi.enter(0x08041C58)) return;
    abi.fetches(12);
    rt.r[2] = abi.read32(0x08041C6C);
    rt.r[0] = abi.read32(rt.r[2] +% 0x0);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x59, true);
    abi.setRegNz(&rt.r[1], 0x1C);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.r[0] = abi.read32(rt.r[2] +% 0x0);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x5A, true);
    abi.setRegNz(&rt.r[1], 0x10);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08044644() callconv(.c) void {
    if (!abi.enter(0x08044644)) return;
    abi.fetches(11);
    rt.r[1] = abi.read32(0x08044658);
    rt.r[0] = abi.read32(0x0804465C);
    rt.r[0] = abi.read32(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[2], 0x1E);
    rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
    rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    rt.r[0] = abi.read8(rt.r[0] +% 0x0);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080468C0() callconv(.c) void {
    if (!abi.enter(0x080468C0)) return;
    abi.fetches(7);
    abi.setRegNz(&rt.r[1], 0x31);
    abi.write16(rt.r[0] +% 0x26, @truncate(rt.r[1]));
    abi.setRegNz(&rt.r[1], 0x10);
    abi.write16(rt.r[0] +% 0x24, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08047FB4() callconv(.c) void {
    if (!abi.enter(0x08047FB4)) return;
    abi.fetches(12);
    rt.r[0] = abi.read32(0x08047FC8);
    rt.r[0] = abi.read32(rt.r[0] +% 0x0);
    rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
    rt.cpuAdd(&rt.r[1], rt.r[1], 0x5D, true);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
    rt.r[1] = abi.read8(rt.r[1] +% 0x0);
    rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
    abi.setRegNz(&rt.r[1], 0x0);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08049B28() callconv(.c) void {
    if (!abi.enter(0x08049B28)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[0] = abi.read32(0x08049B38);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08049C8C() callconv(.c) void {
    if (!abi.enter(0x08049C8C)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(0x08049C98);
    rt.r[0] = abi.read32(rt.r[0] +% 0x0);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x2B, true);
    abi.setRegNz(&rt.r[1], 0x0);
    abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0804B250() callconv(.c) void {
    if (!abi.enter(0x0804B250)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0804B264);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2A, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0804B268);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0804BC74() callconv(.c) void {
    if (!abi.enter(0x0804BC74)) return;
    abi.fetches(11);
    rt.r[0] = abi.read32(0x0804BC88);
    rt.r[0] = abi.read32(rt.r[0] +% 0x0);
    rt.r[1] = abi.read16(rt.r[0] +% 0x1E);
    rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
    abi.setRegNz(&rt.r[2], 0x0);
    abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[1]));
    abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[2]));
    abi.write16(rt.r[0] +% 0x28, @truncate(rt.r[2]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0804BC8C() callconv(.c) void {
    if (!abi.enter(0x0804BC8C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[1] = abi.read32(0x0804BCA8);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read16(rt.r[2] +% 0x28);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[2] +% 0x28, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
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

pub fn func_0804C61C() callconv(.c) void {
    if (!abi.enter(0x0804C61C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0804C634);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
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
            rt.r[1] = abi.read32(0x0804C638);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0804DA48() callconv(.c) void {
    if (!abi.enter(0x0804DA48)) return;
    abi.fetches(7);
    abi.setRegNz(&rt.r[0], rt.r[0] << 24);
    abi.setRegNz(&rt.r[0], rt.r[0] >> 17);
    rt.r[1] = abi.read32(0x0804DA54);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0804DA58() callconv(.c) void {
    if (!abi.enter(0x0804DA58)) return;
    abi.fetches(22);
    rt.r[3] = abi.read32(0x0804DA80);
    rt.r[1] = abi.read32(0x0804DA84);
    rt.r[0] = abi.read32(0x0804DA88);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
    rt.r[2] = abi.read8(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.r[2] << 2);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    rt.r[0] = abi.read8(rt.r[0] +% 0x3);
    abi.setRegNz(&rt.r[1], rt.r[0] << 27);
    abi.setRegNz(&rt.r[1], rt.r[1] >> 29);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x82, true);
    abi.setRegNz(&rt.r[0], rt.r[2] << 4);
    rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
    abi.setRegNz(&rt.r[0], rt.r[0] << 2);
    rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
    rt.cpuAdd(&rt.r[3], rt.r[3], 0x30, true);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
    rt.r[0] = abi.read8(rt.r[1] +% 0x0);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0804FA02() callconv(.c) void {
    if (!abi.enter(0x0804FA02)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            popRegsSeq(&.{ 0 });
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_080502E0() callconv(.c) void {
    if (!abi.enter(0x080502E0)) return;
    abi.fetches(6);
    rt.r[1] = abi.read32(0x080502E8);
    abi.setRegNz(&rt.r[0], 0x1);
    abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08050312() callconv(.c) void {
    if (!abi.enter(0x08050312)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!proc.clearProcSlotCall(0x08050319)) return;
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

pub fn func_08050402() callconv(.c) void {
    if (!abi.enter(0x08050402)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

pub fn func_0805053E() callconv(.c) void {
    if (!abi.enter(0x0805053E)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            if (!proc.clearProcSlotCall(0x08050547)) return;
            continue :blk 2;
        },
        2 => {
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

pub fn func_08050600() callconv(.c) void {
    if (!abi.enter(0x08050600)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x08050618);
            rt.r[3] = abi.read32(0x0805061C);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!hw.drawDispatchCall(0x0805060D)) return;
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

pub fn func_08050602() callconv(.c) void {
    if (!abi.enter(0x08050602)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x08050618);
            rt.r[3] = abi.read32(0x0805061C);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!hw.drawDispatchCall(0x0805060D)) return;
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

pub fn func_08050604() callconv(.c) void {
    if (!abi.enter(0x08050604)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x08050618);
            rt.r[3] = abi.read32(0x0805061C);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!hw.drawDispatchCall(0x0805060D)) return;
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

pub fn func_08050608() callconv(.c) void {
    if (!abi.enter(0x08050608)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            if (!hw.drawDispatchCall(0x0805060D)) return;
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

pub fn func_08051E58() callconv(.c) void {
    if (!abi.enter(0x08051E58)) return;
    abi.fetches(8);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    rt.r[1] = abi.read32(0x08051E64);
    abi.setRegNz(&rt.r[0], rt.r[0] >> 14);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    rt.r[0] = abi.read32(rt.r[0] +% 0x0);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080529BC() callconv(.c) void {
    if (!abi.enter(0x080529BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = abi.read32(0x080529D0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x27, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0805FAFC() callconv(.c) void {
    if (!abi.enter(0x0805FAFC)) return;
    abi.fetches(8);
    rt.r[8] = rt.r[3];
    rt.r[9] = rt.r[4];
    rt.r[10] = rt.r[5];
    popRegsSeq(&.{ 4, 5, 6, 7 });
    popRegsSeq(&.{ 1 });
    rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
}

pub fn func_0805FD02() callconv(.c) void {
    if (!abi.enter(0x0805FD02)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[5] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[4], true);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

pub fn func_0805FEF8() callconv(.c) void {
    if (!abi.enter(0x0805FEF8)) return;
    abi.fetches(5);
    popRegsSeq(&.{ 4, 5, 6, 7 });
    popRegsSeq(&.{ 1 });
    rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
}

pub fn func_080606FC() callconv(.c) void {
    if (!abi.enter(0x080606FC)) return;
    abi.fetches(6);
    rt.r[13] +%= 0x8;
    popRegsSeq(&.{ 4, 5 });
    popRegsSeq(&.{ 0 });
    rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
}

pub fn func_080632AC() callconv(.c) void {
    if (!abi.enter(0x080632AC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x080632B8);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
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

pub fn func_08063890() callconv(.c) void {
    if (!abi.enter(0x08063890)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0806389C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
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

pub fn func_08066D4C() callconv(.c) void {
    if (!abi.enter(0x08066D4C)) return;
    abi.fetches(9);
    rt.r[1] = abi.read32(0x08066D5C);
    abi.setRegNz(&rt.r[0], 0x2);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.r[1] = abi.read32(0x08066D60);
    abi.setRegNz(&rt.r[0], 0x0);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08068760() callconv(.c) void {
    if (!abi.enter(0x08068760)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08068778);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[1], 0x5B);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.write8(rt.r[0] +% 0x5, @truncate(rt.r[2]));
            abi.write8(rt.r[0] +% 0x4, @truncate(rt.r[2]));
            abi.write8(rt.r[0] +% 0x3, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
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

pub fn func_08068824() callconv(.c) void {
    if (!abi.enter(0x08068824)) return;
    abi.fetches(18);
    abi.setRegNz(&rt.r[0], rt.r[0] << 24);
    abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
    rt.r[2] = abi.read32(0x08068844);
    abi.setRegNz(&rt.r[1], 0x68);
    abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
    rt.r[1] = abi.read32(rt.r[2] +% 0x0);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
    rt.r[2] = abi.read8(rt.r[1] +% 0xD);
    rt.r[3] = abi.read8(rt.r[1] +% 0xC);
    rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[3], true);
    rt.r[2] = abi.read8(rt.r[1] +% 0xE);
    rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
    rt.r[1] = abi.read8(rt.r[1] +% 0xF);
    rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_080688F8() callconv(.c) void {
    if (!abi.enter(0x080688F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[2] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(null, rt.r[0], 0x5B, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
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
            rt.r[2] = abi.read8(rt.r[1] +% 0x9);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write8(rt.r[1] +% 0x9, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0806A078() callconv(.c) void {
    if (!abi.enter(0x0806A078)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[0] +% 0x18);
            rt.cpuSub(null, rt.r[0], 0xE9, true);
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

pub fn func_0806A260() callconv(.c) void {
    if (!abi.enter(0x0806A260)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 19);
            rt.r[1] = abi.read32(0x0806A270);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0806A278);
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0806CBDC() callconv(.c) void {
    if (!abi.enter(0x0806CBDC)) return;
    abi.fetches(8);
    abi.write32(rt.r[0] +% 0x0, rt.r[1]);
    abi.write32(rt.r[0] +% 0x4, rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x0);
    abi.write32(rt.r[0] +% 0x8, rt.r[1]);
    abi.write16(rt.r[0] +% 0x10, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0806CCA4() callconv(.c) void {
    if (!abi.enter(0x0806CCA4)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(rt.r[0] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.r[0] >> 8);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0806CD50() callconv(.c) void {
    if (!abi.enter(0x0806CD50)) return;
    abi.fetches(18);
    rt.r[13] -%= 0x4;
    rt.r[2] = rt.r[13];
    abi.setRegNz(&rt.r[1], 0x0);
    abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[1]));
    rt.r[1] = abi.read32(0x0806CD70);
    abi.write32(rt.r[1] +% 0x0, rt.r[2]);
    abi.setRegNz(&rt.r[0], rt.r[0] << 5);
    abi.setRegNz(&rt.r[2], 0xC0);
    abi.setRegNz(&rt.r[2], rt.r[2] << 19);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
    abi.write32(rt.r[1] +% 0x4, rt.r[0]);
    rt.r[0] = abi.read32(0x0806CD74);
    abi.write32(rt.r[1] +% 0x8, rt.r[0]);
    rt.r[0] = abi.read32(rt.r[1] +% 0x8);
    rt.r[13] +%= 0x4;
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0806CE28() callconv(.c) void {
    if (!abi.enter(0x0806CE28)) return;
    abi.fetches(10);
    rt.r[1] = abi.read32(0x0806CE38);
    abi.setRegNz(&rt.r[0], rt.r[0] << 8);
    rt.r[2] = abi.read8(rt.r[1] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
    abi.setRegNz(&rt.r[0], rt.r[0] << 16);
    abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
    abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0806CF28() callconv(.c) void {
    if (!abi.enter(0x0806CF28)) return;
    abi.fetches(7);
    abi.write32(rt.r[0] +% 0x4, rt.r[1]);
    abi.setRegNz(&rt.r[1], 0x0);
    abi.write32(rt.r[0] +% 0x8, rt.r[1]);
    abi.write16(rt.r[0] +% 0x10, @truncate(rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0806CF34() callconv(.c) void {
    if (!abi.enter(0x0806CF34)) return;
    abi.fetches(11);
    rt.r[0] = abi.read32(0x0806CF48);
    abi.setRegNz(&rt.r[2], 0x0);
    rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
    abi.setRegNz(&rt.r[0], rt.r[1] << 1);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    abi.setRegNz(&rt.r[0], rt.r[0] << 5);
    rt.r[1] = abi.read32(0x0806CF4C);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0806D12C() callconv(.c) void {
    if (!abi.enter(0x0806D12C)) return;
    abi.fetches(27);
    rt.r[2] = abi.read32(rt.r[0] +% 0x0);
    abi.write32(rt.r[1] +% 0x0, rt.r[2]);
    rt.r[2] = abi.read32(rt.r[0] +% 0x4);
    abi.write32(rt.r[1] +% 0x4, rt.r[2]);
    rt.r[2] = abi.read32(rt.r[0] +% 0x8);
    abi.write32(rt.r[1] +% 0x8, rt.r[2]);
    rt.r[2] = abi.read32(rt.r[0] +% 0xC);
    abi.write32(rt.r[1] +% 0xC, rt.r[2]);
    rt.r[2] = abi.read32(rt.r[0] +% 0x10);
    abi.write32(rt.r[1] +% 0x10, rt.r[2]);
    rt.r[2] = abi.read32(rt.r[0] +% 0x14);
    abi.write32(rt.r[1] +% 0x14, rt.r[2]);
    rt.r[2] = abi.read32(rt.r[0] +% 0x18);
    abi.write32(rt.r[1] +% 0x18, rt.r[2]);
    rt.r[2] = abi.read32(rt.r[0] +% 0x1C);
    abi.write32(rt.r[1] +% 0x1C, rt.r[2]);
    rt.r[2] = abi.read32(rt.r[0] +% 0x20);
    abi.write32(rt.r[1] +% 0x20, rt.r[2]);
    rt.r[2] = abi.read32(rt.r[0] +% 0x24);
    abi.write32(rt.r[1] +% 0x24, rt.r[2]);
    rt.r[2] = abi.read32(rt.r[0] +% 0x28);
    abi.write32(rt.r[1] +% 0x28, rt.r[2]);
    rt.r[0] = abi.read32(rt.r[0] +% 0x2C);
    abi.write32(rt.r[1] +% 0x2C, rt.r[0]);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0806EBE8() callconv(.c) void {
    if (!abi.enter(0x0806EBE8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0806EC08);
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
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0806EC0C);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0806EC10);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_0806F1F4() callconv(.c) void {
    if (!abi.enter(0x0806F1F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            if (!sound.playSfxCall(0x66, 0x0806F1FB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
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

pub fn func_0806F7D0() callconv(.c) void {
    if (!abi.enter(0x0806F7D0)) return;
    abi.fetches(11);
    rt.r[1] = abi.read32(0x0806F7E4);
    rt.r[1] = abi.read32(rt.r[1] +% 0x0);
    abi.setRegNz(&rt.r[0], rt.r[0] << 2);
    rt.cpuAdd(&rt.r[1], rt.r[1], 0x78, true);
    rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
    rt.r[1] = abi.read32(rt.r[1] +% 0x0);
    abi.setRegNz(&rt.r[0], 0x0);
    abi.write32(rt.r[1] +% 0x8, rt.r[0]);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0806F900() callconv(.c) void {
    if (!abi.enter(0x0806F900)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            if (!abi.call(func_0806F7D0, 0x0806F905)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            if (!sound.playSfxCall(0x66, 0x0806F90B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
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

pub fn func_0806F9F6() callconv(.c) void {
    if (!abi.enter(0x0806F9F6)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(low_peel_7.func_08031488, 0x0806F9FD)) return;
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

pub fn func_0806F9F8() callconv(.c) void {
    if (!abi.enter(0x0806F9F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            if (!abi.call(low_peel_7.func_08031488, 0x0806F9FD)) return;
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

pub fn func_080700E2() callconv(.c) void {
    if (!abi.enter(0x080700E2)) return;
    abi.fetches(4);
    popRegsSeq(&.{ 0 });
    rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
}

pub fn func_080702EC() callconv(.c) void {
    if (!abi.enter(0x080702EC)) return;
    abi.fetches(8);
    rt.r[1] = abi.read32(0x080702F8);
    abi.setRegNz(&rt.r[0], rt.r[0] << 1);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
    abi.setRegNz(&rt.r[1], 0x0);
    rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_08070600() callconv(.c) void {
    if (!abi.enter(0x08070600)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
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

pub fn func_08071B24() callconv(.c) void {
    if (!abi.enter(0x08071B24)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xA0);
            if (!abi.call(func_0806CE28, 0x08071B37)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08071B50);
            if (!abi.call(low_peel_5.func_0806CD78, 0x08071B3D)) return;
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

pub fn func_08076A78() callconv(.c) void {
    if (!abi.enter(0x08076A78)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08076A98);
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
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x08076A9C);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08076AA0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_080775B0() callconv(.c) void {
    if (!abi.enter(0x080775B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0807761C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x08077620);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            low_peel_9.func_080775C2(); return;
        },
        else => unreachable,
    }
}

pub fn func_08077A58() callconv(.c) void {
    if (!abi.enter(0x08077A58)) return;
    abi.fetches(3);
    rt.r[3] = abi.read8(rt.r[2] +% 0x0);
    tail_low.func_08077A5A(); return;
}

pub fn func_08077A74() callconv(.c) void {
    if (!abi.enter(0x08077A74)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[2] = abi.read32(rt.r[1] +% 0x40);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x1, true);
            abi.write32(rt.r[1] +% 0x40, rt.r[3]);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            tail_low.func_08077A5A(); return;
        },
        else => unreachable,
    }
}

pub fn func_08077A76() callconv(.c) void {
    if (!abi.enter(0x08077A76)) return;
    abi.fetches(6);
    rt.cpuAdd(&rt.r[3], rt.r[2], 0x1, true);
    abi.write32(rt.r[1] +% 0x40, rt.r[3]);
    rt.r[3] = abi.read8(rt.r[2] +% 0x0);
    tail_low.func_08077A5A(); return;
}

pub fn func_08077AA0() callconv(.c) void {
    if (!abi.enter(0x08077AA0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[2] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[2], 0x3, true);
            if (rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            low_peel_5.func_08077A10(); return;
        },
        2 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read32(rt.r[1] +% 0x40);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            abi.write32(rt.r[3] +% 0x44, rt.r[2]);
            rt.r[2] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.write8(rt.r[1] +% 0x2, @truncate(rt.r[2]));
            sound.func_08077A80(); return;
        },
        else => unreachable,
    }
}

pub fn func_08077ABC() callconv(.c) void {
    if (!abi.enter(0x08077ABC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[2] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[2], 0x0, true);
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
            abi.fetches(8);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            abi.write8(rt.r[1] +% 0x2, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read32(rt.r[3] +% 0x44);
            abi.write32(rt.r[1] +% 0x40, rt.r[2]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

pub fn func_08077C50() callconv(.c) void {
    if (!abi.enter(0x08077C50)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(0x08077EAC);
            rt.r[3] = abi.read32(rt.r[0] +% 0x34);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            abi.write32(rt.r[0] +% 0x34, rt.r[3]);
            low_peel_18.func_08077C5E(); return;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08078164() callconv(.c) void {
    if (!abi.enter(0x08078164)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write8(rt.r[1] +% 0x16, @truncate(rt.r[2]));
            abi.write8(rt.r[1] +% 0x1A, @truncate(rt.r[2]));
            rt.r[2] = abi.read8(rt.r[1] +% 0x18);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[2], 0xC);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x3);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[3], rt.r[3] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08078180() callconv(.c) void {
    if (!abi.enter(0x08078180)) return;
    abi.fetches(7);
    rt.r[2] = abi.read32(rt.r[1] +% 0x40);
    rt.cpuAdd(&rt.r[3], rt.r[2], 0x1, true);
    abi.write32(rt.r[1] +% 0x40, rt.r[3]);
    rt.r[3] = abi.read8(rt.r[2] +% 0x0);
    rt.recompReturn(rt.r[14]); return;
}

pub fn func_0807818C() callconv(.c) void {
    if (!abi.enter(0x0807818C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[12] = rt.r[14];
            if (!abi.call(func_08078180, 0x08078193)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.write8(rt.r[1] +% 0x19, @truncate(rt.r[3]));
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            dispatch.awre_cpu_bx(rt.r[12]); return;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(func_08078164, 0x0807819D)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_080781A0() callconv(.c) void {
    if (!abi.enter(0x080781A0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[12] = rt.r[14];
            if (!abi.call(func_08078180, 0x080781A7)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.write8(rt.r[1] +% 0x17, @truncate(rt.r[3]));
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            dispatch.awre_cpu_bx(rt.r[12]); return;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(func_08078164, 0x080781B1)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

pub fn func_0807821C() callconv(.c) void {
    if (!abi.enter(0x0807821C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[3] = abi.read32(rt.r[2] +% 0x34);
            rt.r[0] = abi.read32(0x08078230);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[2] +% 0x4);
            rt.r[1] = abi.read32(0x08078234);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write32(rt.r[2] +% 0x4, rt.r[0]);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08078238() callconv(.c) void {
    if (!abi.enter(0x08078238)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[3] = abi.read32(rt.r[2] +% 0x34);
            rt.r[0] = abi.read32(0x08078254);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.write16(rt.r[2] +% 0x26, @truncate(rt.r[1]));
            abi.write16(rt.r[2] +% 0x24, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write16(rt.r[2] +% 0x28, @truncate(rt.r[0]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_08079320() callconv(.c) void {
    if (!abi.enter(0x08079320)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x1A, @truncate(rt.r[0]));
            abi.write8(rt.r[1] +% 0x16, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x18);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xC);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x3);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_080794A4() callconv(.c) void {
    if (!abi.enter(0x080794A4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[2]));
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

pub fn func_080796E0() callconv(.c) void {
    if (!abi.enter(0x080796E0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], 0x1);
            hal.bios.invoke(.multiboot);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807A830() callconv(.c) void {
    if (!abi.enter(0x0807A830)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807A868() callconv(.c) void {
    if (!abi.enter(0x0807A868)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

pub fn func_0807ADF0() callconv(.c) void {
    if (!abi.enter(0x0807ADF0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.r[2] = abi.read32(0x0807AE00);
            abi.setRegNz(&rt.r[3], 0x1);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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

pub fn func_0807B018() callconv(.c) void {
    if (!abi.enter(0x0807B018)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], 0xFE);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[1] +% 0x8);
            abi.write32(rt.r[1] +% 0x4, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
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

pub fn func_0807B158() callconv(.c) void {
    if (!abi.enter(0x0807B158)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[0] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
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

pub fn func_0807B210() callconv(.c) void {
    if (!abi.enter(0x0807B210)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.r[2] = abi.read32(rt.r[0] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.r[0] = abi.read8(rt.r[1] +% 0x8);
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

pub fn func_0807C49C() callconv(.c) void {
    if (!abi.enter(0x0807C49C)) return;
    abi.fetches(3);
    rt.r[13] -%= 0x4;
    tail_low.func_0807C49E(); return;
}


test "low_peel_2 exports are callable" {
    try std.testing.expect(@TypeOf(func_08036DD8) == fn () callconv(.c) void);
    try std.testing.expect(@TypeOf(func_0807C49C) == fn () callconv(.c) void);
}
