//! Low-ROM (< 0x08080000) block-peeled wave 8 (61..120 reachable lines, next 209).

const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");

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

fn func_08035E74() callconv(.c) void {
    if (!abi.enter(0x08035E74)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x08035E9C);
            rt.r[2] = abi.read8(rt.r[4] +% 0x9);
            abi.setRegNz(&rt.r[0], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read16(rt.r[0] +% 0x1E);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 7);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08035EC8);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08035EB3)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(12);
            rt.r[2] = abi.read8(rt.r[4] +% 0x9);
            abi.setRegNz(&rt.r[1], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x20, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.write32(rt.r[0] +% 0x18, rt.r[1]);
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(3);
            continue :blk 9;
        },
        8 => {
            abi.fetches(3);
            continue :blk 6;
        },
        9 => {
            abi.fetches(11);
            rt.r[1] = abi.read8(rt.r[4] +% 0x9);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            if (!abi.call(func_0803D830, 0x08035EDF)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_08035EE4() callconv(.c) void {
    if (!abi.enter(0x08035EE4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x08035F0C);
            rt.r[2] = abi.read8(rt.r[4] +% 0x9);
            abi.setRegNz(&rt.r[0], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read16(rt.r[0] +% 0x1E);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 7);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08035F3C);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08035F29)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(12);
            rt.r[2] = abi.read8(rt.r[4] +% 0x9);
            abi.setRegNz(&rt.r[1], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x20, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.write32(rt.r[0] +% 0x18, rt.r[1]);
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(3);
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08035DD0, 0x08035F1F)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(11);
            rt.r[1] = abi.read8(rt.r[4] +% 0x9);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            if (!abi.call(func_0803D830, 0x08035F53)) return;
            continue :blk 6;
        },
        10 => {
            abi.fetches(3);
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_08036274() callconv(.c) void {
    if (!abi.enter(0x08036274)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x10;
            rt.r[1] = abi.read32(0x0803630C);
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[2], 0x10);
            if (!abi.call(decls.func_0807A8A0, 0x08036283)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(40);
            rt.r[2] = abi.read32(0x08036310);
            rt.r[0] = abi.read32(0x08036314);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x18, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[2] +% 0x10);
            rt.r[5] = abi.read16(rt.r[2] +% 0xE);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[5], true);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[3]));
            abi.setRegNz(&rt.r[0], 0xB);
            rt.r[0] = rt.sext8(abi.read8(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[0] +%= rt.r[13];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.r[5] = abi.read16(rt.r[2] +% 0x14);
            rt.cpuAdd(&rt.r[4], rt.r[5], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x14, @truncate(rt.r[4]));
            abi.setRegNz(&rt.r[0], 0xB);
            rt.r[0] = rt.sext8(abi.read8(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[13];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.r[5] = abi.read16(rt.r[2] +% 0x16);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x16, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[13] +%= 0x10;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(28);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x10, true);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xB);
            rt.r[0] = rt.sext8(abi.read8(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[0] +%= rt.r[13];
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            rt.r[5] = abi.read16(rt.r[2] +% 0xE);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x14, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xB);
            rt.r[0] = rt.sext8(abi.read8(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[13];
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x16, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0803649C() callconv(.c) void {
    if (!abi.enter(0x0803649C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.r[13] -%= 0x8;
            rt.r[8] = rt.r[1];
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.asrConst(rt.r[0], 16));
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(decls.func_080135C8, 0x080364B3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.r[1] = abi.read32(rt.r[13] +% 0x4);
            abi.setRegNz(&rt.r[5], rt.r[1] << 22);
            abi.setRegNz(&rt.r[0], rt.r[5] >> 22);
            rt.r[1] = rt.r[8];
            rt.r[4] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(&rt.r[6], rt.r[4], rt.r[0], true);
            rt.r[2] = abi.read32(0x08036514);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[6], rt.r[6] & rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x9);
            if (!abi.call(decls.func_0807B6AC, 0x080364CF)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[2], 0xFC);
            abi.setRegNz(&rt.r[2], rt.r[2] << 8);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[4]);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[5] >> 22);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[2] = rt.r[8];
            abi.write16(rt.r[2] +% 0x4, @truncate(rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(19);
            rt.r[1] = abi.read32(0x08036518);
            abi.setRegNz(&rt.r[0], rt.r[7] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x18, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[6] << 5);
            rt.r[0] = abi.read32(rt.r[0] +% 0x1C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[5] >> 17);
            rt.r[2] = abi.read32(0x0803651C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0x90);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            if (!abi.call(decls.func_0800FFA8, 0x08036509)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08036520() callconv(.c) void {
    if (!abi.enter(0x08036520)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(27);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x6);
            rt.r[1] = abi.read8(rt.r[4] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[4] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[4] +% 0x2);
            rt.r[1] = abi.read8(rt.r[4] +% 0x3);
            rt.r[2] = abi.read32(0x08036578);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(&rt.r[3], rt.r[4], rt.r[3], true);
            abi.setRegNz(&rt.r[2], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[3], rt.r[2] << 4);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[3], rt.r[2] << 8);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[3], rt.r[2] << 16);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            rt.cpuSub(&rt.r[2], 0, rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 8);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            rt.r[3] = abi.read8(rt.r[4] +% 0x0);
            if (!abi.call(decls.func_08036588, 0x08036553)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
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
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(13);
            rt.r[2] = abi.read32(0x0803657C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x18, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.write32(rt.r[1] +% 0x0, rt.r[4]);
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

fn func_08036750() callconv(.c) void {
    if (!abi.enter(0x08036750)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 14 });
            rt.r[3] = abi.read32(0x080367AC);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[2], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 5);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x18, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            rt.r[4] = abi.read32(rt.r[2] +% 0x0);
            abi.write32(rt.r[4] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write8(rt.r[4] +% 0x8, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080367B0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x14);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080367B4);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x10, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            abi.setRegNz(&rt.r[2], 0x16);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x080367B8);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08035E38, 0x080367A5)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xF, true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 4));
            if (!abi.call(decls.func_0802928C, 0x08036799)) return;
            continue :blk 5;
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

fn func_080367BC() callconv(.c) void {
    if (!abi.enter(0x080367BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            if (!abi.call(decls.func_08036588, 0x080367D3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 16));
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
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.r[1] = abi.read32(rt.r[13] +% 0x8);
            if (!abi.call(func_08036750, 0x080367E7)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_080367F0() callconv(.c) void {
    if (!abi.enter(0x080367F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08036838);
            if (!abi.call(decls.func_08013B70, 0x080367F9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
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
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x0803683C);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x18, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0xF9);
            rt.r[3] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08036880, 0x0803682F)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036840);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_080368D8() callconv(.c) void {
    if (!abi.enter(0x080368D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_08013B70, 0x080368E1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = abi.read32(0x08036914);
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 8;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[1], 0x2, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_08036B44() callconv(.c) void {
    if (!abi.enter(0x08036B44)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[2], 0x1);
            abi.setRegNz(&rt.r[5], 0x40);
            rt.r[0] = abi.read32(0x08036B84);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[5]);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[2], 0x3F, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036B88);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
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

fn func_080371AC() callconv(.c) void {
    if (!abi.enter(0x080371AC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[2], 0x1);
            abi.setRegNz(&rt.r[5], 0x40);
            rt.r[0] = abi.read32(0x080371EC);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[5]);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x13, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[2], 0x3F, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080371F0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
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

fn func_08037B5C() callconv(.c) void {
    if (!abi.enter(0x08037B5C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(decls.func_0803F048, 0x08037B65)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 24);
            abi.setRegNz(&rt.r[0], 0x3);
            if (!abi.call(decls.func_0803F048, 0x08037B71)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], 0x4);
            if (!abi.call(decls.func_0803F048, 0x08037B7B)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037BA4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08037B94);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_080382A8() callconv(.c) void {
    if (!abi.enter(0x080382A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x080382C0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x2E);
            if (!abi.call(decls.func_0807B6AC, 0x080382B5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[5], 0xB, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x11, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x27, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[5], 0x1);
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[5] << 5);
            rt.r[4] = abi.read32(0x080382F4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read32(0x080382F8);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_0800FDA4, 0x080382E1)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[5], 0x2);
            continue :blk 6;
        },
        8 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[5] << 6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x60, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read32(0x080382FC);
            abi.setRegNz(&rt.r[2], 0x40);
            if (!abi.call(decls.func_0800FDA4, 0x080382EF)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08038300() callconv(.c) void {
    if (!abi.enter(0x08038300)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0803831C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x32);
            if (!abi.call(decls.func_0807B6AC, 0x0803830D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x14, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08038360);
            rt.r[1] = abi.read32(0x08038364);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x14, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_0800FDA4, 0x0803835F)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x28, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        7 => {
            abi.fetches(3);
            continue :blk 12;
        },
        8 => {
            abi.fetches(3);
            continue :blk 12;
        },
        9 => {
            abi.fetches(8);
            rt.r[4] = abi.read32(0x08038344);
            rt.r[1] = abi.read32(0x08038348);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_0800FDA4, 0x08038333)) return;
            continue :blk 13;
        },
        10 => {
            abi.fetches(3);
            continue :blk 12;
        },
        11 => {
            abi.fetches(8);
            rt.r[4] = abi.read32(0x08038390);
            rt.r[1] = abi.read32(0x08038394);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_0800FDA4, 0x08038375)) return;
            continue :blk 14;
        },
        12 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        13 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x20, true);
            rt.r[1] = abi.read32(0x0803834C);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_0800FDA4, 0x0803833F)) return;
            continue :blk 15;
        },
        14 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08038398);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_0800FDA4, 0x0803837F)) return;
            continue :blk 16;
        },
        15 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08038350);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            continue :blk 4;
        },
        16 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0803839C);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_0800FDA4, 0x08038389)) return;
            continue :blk 12;
        },
        else => unreachable,
    }
}

fn func_080383A0() callconv(.c) void {
    if (!abi.enter(0x080383A0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803D79C, 0x080383A7)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08030DF8, 0x080383AB)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0800FCD4, 0x080383AF)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08015A54, 0x080383B3)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08015A08, 0x080383B7)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x080383D8);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08015A38, 0x080383C7)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080134EC, 0x080383E3)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010974, 0x080383CB)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x080383F4);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            if (!abi.call(decls.func_0803D7AC, 0x080383EF)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010144, 0x080383CF)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011844, 0x080383D3)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0800FC18, 0x080383D7)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(3);
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_08038430() callconv(.c) void {
    if (!abi.enter(0x08038430)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08038470);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(decls.func_0803D79C, 0x0803843D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08030DF8, 0x08038441)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0800FCD4, 0x08038445)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08015A54, 0x08038449)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08015A08, 0x0803844D)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08038474);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08015A38, 0x0803845D)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080134EC, 0x0803847F)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010974, 0x08038461)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08038494);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            if (!abi.call(decls.func_0803D7AC, 0x0803848B)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010144, 0x08038465)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08038498);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011844, 0x08038469)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0800FC18, 0x0803846D)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(3);
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_08038508() callconv(.c) void {
    if (!abi.enter(0x08038508)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803D79C, 0x0803850F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08030DF8, 0x08038513)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0800FCD4, 0x08038517)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08015A54, 0x0803851B)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08015A08, 0x0803851F)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08038544);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08015A38, 0x0803852F)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080134EC, 0x0803854F)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010974, 0x08038533)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08038560);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            if (!abi.call(decls.func_0803D7AC, 0x0803855B)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010144, 0x08038537)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011844, 0x0803853B)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0800FC18, 0x0803853F)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080159CC, 0x08038543)) return;
            continue :blk 16;
        },
        16 => {
            abi.fetches(3);
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_08038564() callconv(.c) void {
    if (!abi.enter(0x08038564)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x080385A4);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
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
            abi.fetches(9);
            rt.r[2] = abi.read32(0x080385A8);
            rt.r[0] = abi.read32(0x080385AC);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0801122C, 0x08038581)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0805BA34, 0x08038585)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08018530, 0x08038589)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080138F8, 0x0803858D)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080134E0, 0x08038591)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08015874, 0x08038595)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803D7A8, 0x08038599)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08038DB8() callconv(.c) void {
    if (!abi.enter(0x08038DB8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 16);
            rt.r[1] = abi.read32(0x08038DE0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0xA7, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x8, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08022814, 0x08038DD7)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1);
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_0803F0A8, 0x08038E01)) return;
            continue :blk 10;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 6;
        },
        9 => {
            abi.fetches(3);
            continue :blk 3;
        },
        10 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_08038FC8() callconv(.c) void {
    if (!abi.enter(0x08038FC8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[2] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[2] +% 0x1E, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x3F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x3E, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x18);
            if (!abi.call(decls.func_0801B850, 0x08038FF9)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x3E, true);
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
            rt.cpuSub(null, rt.r[0], 0x14, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x3F, true);
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
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x18);
            if (!abi.call(decls.func_08039484, 0x08038FF1)) return;
            continue :blk 11;
        },
        9 => {
            abi.fetches(3);
            continue :blk 6;
        },
        10 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x18);
            if (!abi.call(decls.func_0801B860, 0x08039001)) return;
            continue :blk 6;
        },
        11 => {
            abi.fetches(3);
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0803942C() callconv(.c) void {
    if (!abi.enter(0x0803942C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[12] = rt.r[0];
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x08039480);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[1], 0x2);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[1]);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[2], 1));
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x10, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.r[2] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuSub(null, rt.r[1], rt.r[7], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[3], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_080397B8() callconv(.c) void {
    if (!abi.enter(0x080397B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[1], 0xF9, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
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
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080397D0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
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
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080397E0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 3;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080397F0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x3);
            continue :blk 3;
        },
        9 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08039808);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803980C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x4);
            continue :blk 3;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x5);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08039F00() callconv(.c) void {
    if (!abi.enter(0x08039F00)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08039F18);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803A6B4, 0x08039F37)) return;
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
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803A140, 0x08039F3D)) return;
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
            abi.fetches(3);
            continue :blk 11;
        },
        7 => {
            abi.fetches(3);
            continue :blk 11;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803A6B4, 0x08039F2B)) return;
            continue :blk 12;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803A6B4, 0x08039F43)) return;
            continue :blk 15;
        },
        11 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        12 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08039F5C, 0x08039F31)) return;
            continue :blk 16;
        },
        13 => {
            abi.fetches(3);
            continue :blk 11;
        },
        14 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803A6B4, 0x08039F4F)) return;
            continue :blk 17;
        },
        15 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803A224, 0x08039F49)) return;
            continue :blk 18;
        },
        16 => {
            abi.fetches(3);
            continue :blk 11;
        },
        17 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803A244, 0x08039F55)) return;
            continue :blk 11;
        },
        18 => {
            abi.fetches(3);
            continue :blk 11;
        },
        else => unreachable,
    }
}

fn func_0803A0A4() callconv(.c) void {
    if (!abi.enter(0x0803A0A4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = abi.read32(0x0803A0E4);
            rt.r[0] = abi.read32(rt.r[1] +% 0x24);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 20);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x20, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[2], 0x20, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x24);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 20);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803A0E8() callconv(.c) void {
    if (!abi.enter(0x0803A0E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = abi.read32(0x0803A124);
            rt.r[0] = abi.read32(rt.r[2] +% 0x24);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 20);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_080796C8, 0x0803A11D)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x80, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[5] = abi.read16(rt.r[2] +% 0x26);
            abi.setRegNz(&rt.r[0], rt.r[5] >> 4);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.cpuSub(null, rt.r[2], rt.r[4], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[2] +% 0x24);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 20);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803A270() callconv(.c) void {
    if (!abi.enter(0x0803A270)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0803A2D8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x1A, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[3], 0x1);
            rt.r[2] = abi.read32(0x0803A2DC);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x33, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(19);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3E, true);
            abi.setRegNz(&rt.r[3], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3F, true);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], 0x9);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], 0x6);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[2] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x39, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0x2);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(decls.func_08024EC4, 0x0803A2D1)) return;
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

fn func_0803A664() callconv(.c) void {
    if (!abi.enter(0x0803A664)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[5], 0x0);
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08024CD0, 0x0803A671)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x0803A6A8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x8E, true);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            continue :blk 4;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 9;
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

fn func_0803A948() callconv(.c) void {
    if (!abi.enter(0x0803A948)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 24);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(0x0803A99C);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[3] = rt.sext8(abi.read8(rt.r[0] +% rt.r[3]));
            rt.cpuSub(null, rt.r[1], rt.r[3], true);
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
            abi.fetches(10);
            rt.r[12] = rt.r[2];
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[7], rt.asrConst(rt.r[0], 24));
            rt.r[6] = rt.r[12];
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x2B, true);
            abi.setRegNz(&rt.r[0], rt.r[5] << 24);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x0, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[1] << 24);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 24));
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x20, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], rt.r[7], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 17);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        7 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0803B032() callconv(.c) void {
    if (!abi.enter(0x0803B032)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_0803A6C8, 0x0803B041)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0803B074);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x0803B078);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            if (!abi.call(decls.func_0801D148, 0x0803B04D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803AB5C, 0x0803B051)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(16);
            rt.r[2] = abi.read32(0x0803B07C);
            rt.r[1] = abi.read32(0x0803B080);
            rt.r[4] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[3] = abi.read16(rt.r[1] +% 0x0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[1] = rt.sext8(abi.read8(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803ABB8, 0x0803B071)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            rt.r[2] = abi.read32(0x0803B0B4);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801DC38, 0x0803B08F)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803A9B8, 0x0803B093)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0803B0B8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[4] = abi.read32(0x0803B0BC);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            if (!abi.call(decls.func_0801D148, 0x0803B0AD)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803ABE0, 0x0803B097)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        12 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803ABB8, 0x0803B0A1)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_0803B0C0() callconv(.c) void {
    if (!abi.enter(0x0803B0C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            rt.r[0] = abi.read32(0x0803B0F0);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[4], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
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
            abi.setRegNz(&rt.r[0], 0x3);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        7 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2B, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x4);
            continue :blk 5;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803B124() callconv(.c) void {
    if (!abi.enter(0x0803B124)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.r[0] = abi.read32(0x0803B140);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(15);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
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
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x3);
            continue :blk 5;
        },
        7 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2B, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 5;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x4);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803B194() callconv(.c) void {
    if (!abi.enter(0x0803B194)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[5], rt.r[2] >> 24);
            abi.setRegNz(&rt.r[3], rt.r[3] << 24);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[0] = abi.read32(0x0803B1D0);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[6], 0x6);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[6]));
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(null, rt.r[1], rt.r[3], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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
            rt.cpuSub(null, rt.r[1], 0x9F, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
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
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[3], 0x4);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(null, rt.r[0], rt.r[5], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0xEF, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0803B41C() callconv(.c) void {
    if (!abi.enter(0x0803B41C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x80, true);
            abi.setRegNz(&rt.r[5], 0x0);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[1], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            rt.r[1] = abi.read16(rt.r[4] +% 0x20);
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x20, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], 0x80);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
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
            abi.fetches(4);
            abi.write16(rt.r[4] +% 0x20, @truncate(rt.r[1]));
            abi.write32(rt.r[4] +% 0x8, rt.r[5]);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803B3A8, 0x0803B451)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[5]));
            abi.write32(rt.r[4] +% 0x8, rt.r[5]);
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

fn func_0803B464() callconv(.c) void {
    if (!abi.enter(0x0803B464)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x0803B4D0);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x0803B471)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[3] = abi.read32(0x0803B4D4);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[2], rt.r[1] >> 31);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 1));
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013744, 0x0803B49F)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x80);
            abi.setRegNz(&rt.r[4], rt.r[4] << 1);
            continue :blk 2;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013794, 0x0803B4A9)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            if (!abi.call(decls.func_08014850, 0x0803B4B9)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_080136A4, 0x0803B4C3)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0803B4C9)) return;
            continue :blk 7;
        },
        else => unreachable,
    }
}

fn func_0803B4F8() callconv(.c) void {
    if (!abi.enter(0x0803B4F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x0803B544);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_080136A4, 0x0803B507)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x0803B50F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 14);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013744, 0x0803B525)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013794, 0x0803B52F)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0803B53D)) return;
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803B5E4() callconv(.c) void {
    if (!abi.enter(0x0803B5E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(11);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[5]));
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x20, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            abi.write32(rt.r[4] +% 0x8, rt.r[5]);
            continue :blk 3;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(11);
            rt.r[0] = abi.read16(rt.r[4] +% 0x20);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x20, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x22);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            abi.write16(rt.r[4] +% 0x22, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 1;
        },
        8 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[1], 0x22);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            if (!abi.call(decls.func_0803B548, 0x0803B62D)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(12);
            rt.r[0] = abi.read16(rt.r[4] +% 0x20);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x20, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x22);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xE, true);
            abi.write16(rt.r[4] +% 0x22, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0803B64C() callconv(.c) void {
    if (!abi.enter(0x0803B64C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0803B68C);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x0803B659)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x26, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0803B9DC() callconv(.c) void {
    if (!abi.enter(0x0803B9DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read32(0x0803BA38);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x8, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0803BA3C);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[4] +% 0x8, rt.r[0]);
            rt.r[3] = abi.read32(0x0803BA40);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[2] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            rt.r[0] = abi.read32(0x0803BA44);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            if (!abi.call(func_0803B64C, 0x0803BA29)) return;
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
            rt.r[1] = abi.read32(rt.r[4] +% 0x18);
            rt.r[0] = abi.read16(rt.r[1] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803BA54() callconv(.c) void {
    if (!abi.enter(0x0803BA54)) return;
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
            rt.r[3] = abi.read32(0x0803BA94);
            rt.cpuSub(null, rt.r[0], 0x8, true);
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
            rt.r[1] = abi.read32(0x0803BA98);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[2] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            abi.write32(rt.r[2] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(0x0803BA9C);
            if (!abi.call(decls.func_0801329C, 0x0803BA89)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011910, 0x0803BA8D)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x0803BA91)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803BD74() callconv(.c) void {
    if (!abi.enter(0x0803BD74)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            if (!abi.call(decls.func_0801A218, 0x0803BD7F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.write16(rt.r[7] +% 0x28, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
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
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0807AF30, 0x0803BD99)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            if (!abi.call(decls.func_080132D8, 0x0803BD93)) return;
            continue :blk 2;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[6], rt.r[6] << 18);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[6], 16));
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0807AED4, 0x0803BDA5)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 18);
            rt.cpuSub(&rt.r[4], 0, rt.r[4], true);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0807AED4, 0x0803BDB3)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 18);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[5], 16));
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0807AF30, 0x0803BDBF)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[0] << 18);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[2], 0x28);
            rt.r[1] = rt.sext16(abi.read16(rt.r[7] +% rt.r[2]));
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08014B54, 0x0803BDD5)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[7] +% 0x24, @truncate(rt.r[0]));
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0803C710() callconv(.c) void {
    if (!abi.enter(0x0803C710)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[4] = abi.read32(0x0803C750);
            abi.setRegNz(&rt.r[3], 0xBA);
            abi.setRegNz(&rt.r[3], rt.r[3] << 1);
            rt.r[2] = abi.read32(0x0803C754);
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x0803C737)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_080198FC, 0x0803C743)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0801FF70, 0x0803C747)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08020190, 0x0803C74B)) return;
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

fn func_0803C82C() callconv(.c) void {
    if (!abi.enter(0x0803C82C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 14 });
            if (!abi.call(decls.func_080124D4, 0x0803C833)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[4] = abi.read32(0x0803C870);
            abi.setRegNz(&rt.r[3], 0xBA);
            abi.setRegNz(&rt.r[3], rt.r[3] << 1);
            rt.r[2] = abi.read32(0x0803C874);
            continue :blk 2;
        },
        2 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x0803C857)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_080198FC, 0x0803C863)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0801FF70, 0x0803C867)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08020190, 0x0803C86B)) return;
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

fn func_0803C894() callconv(.c) void {
    if (!abi.enter(0x0803C894)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[2] = abi.read32(0x0803C8BC);
            rt.r[0] = abi.read32(0x0803C8C0);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x9);
            rt.r[3] = rt.sext8(abi.read8(rt.r[4] +% rt.r[3]));
            abi.setRegNz(&rt.r[1], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[2], true);
            rt.r[6] = abi.read8(rt.r[2] +% 0x0);
            rt.r[7] = abi.read8(rt.r[2] +% 0x2);
            rt.r[0] = abi.read32(0x0803C8C4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            rt.r[5] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[3], 0x4, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            rt.r[2] = abi.read32(0x0803C8D8);
            rt.r[1] = abi.read32(rt.r[4] +% 0x4);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0xB, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08019288, 0x0803C8F3)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(3);
            continue :blk 7;
        },
        5 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x0803C914);
            rt.r[1] = abi.read32(rt.r[4] +% 0x4);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x8, true);
            continue :blk 3;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            continue :blk 7;
        },
        7 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x0803C918);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08020584, 0x0803C90D)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0803D248() callconv(.c) void {
    if (!abi.enter(0x0803D248)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[5] = abi.read32(0x0803D2AC);
            rt.r[0] = abi.read16(rt.r[4] +% 0x20);
            abi.write8(rt.r[5] +% 0x1D, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x22);
            abi.write8(rt.r[5] +% 0x1F, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x20, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x26);
            abi.write32(rt.r[5] +% 0x10, rt.r[0]);
            rt.r[0] = abi.read16(rt.r[4] +% 0x26);
            rt.r[2] = abi.read16(rt.r[4] +% 0x28);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read16(rt.r[4] +% 0x28);
            abi.write32(rt.r[5] +% 0x14, rt.r[0]);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            if (!abi.call(func_0803A0A4, 0x0803D277)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.write16(rt.r[4] +% 0x28, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(func_0803EE5C, 0x0803D281)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2C);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[2], 0xE0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[2], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[2], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[2], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[2], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08015F8C, 0x0803D2A5)) return;
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

fn func_0803D398() callconv(.c) void {
    if (!abi.enter(0x0803D398)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xB4, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.r[2] = abi.read32(0x0803D3C0);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xC0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.r[4] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x4);
            rt.r[3] = abi.read16(rt.r[3] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[3] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803D2CC, 0x0803D3BD)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[5] +% 0x8, rt.r[0]);
            continue :blk 8;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
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
        9 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[5] +% 0x20);
            abi.setRegNz(&rt.r[4], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[4]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[5] +% 0x20, @truncate(rt.r[0]));
            continue :blk 10;
        },
        12 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[5] +% 0x20);
            abi.setRegNz(&rt.r[2], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[5] +% 0x20, @truncate(rt.r[0]));
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_0803D47C() callconv(.c) void {
    if (!abi.enter(0x0803D47C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0803D4AC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x4);
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
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_080132D8, 0x0803D4BB)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read16(rt.r[2] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0x1E, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x5A, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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
            abi.fetches(4);
            if (!abi.call(decls.func_0803D43C, 0x0803D4A1)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803D4B0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0803D4A9)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0803D628() callconv(.c) void {
    if (!abi.enter(0x0803D628)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x0803D67C);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            if (!abi.call(decls.func_080138A4, 0x0803D635)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 13);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            if (!abi.call(decls.func_08013878, 0x0803D649)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x0803D651)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x80, true);
            if (rt.CPU_Z) {
                continue :blk 4;
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
            abi.fetches(11);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x10, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013744, 0x0803D66B)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013794, 0x0803D675)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803D830() callconv(.c) void {
    if (!abi.enter(0x0803D830)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.r[4] = abi.read32(0x0803D878);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
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
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            if (!abi.call(decls.func_080782F0, 0x0803D84B)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[4] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[4] = abi.read32(0x0803D87C);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013B70, 0x0803D85D)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x0803D871)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803D8C8() callconv(.c) void {
    if (!abi.enter(0x0803D8C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.r[6] = abi.read32(0x0803D908);
            rt.r[1] = abi.read16(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[5], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[5], 16));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
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
            rt.r[0] = abi.read32(0x0803D90C);
            if (!abi.call(decls.func_0801329C, 0x0803D8E1)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[5] >> 16);
            if (!abi.call(decls.func_080782F0, 0x0803D8E7)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0803D910);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[4]));
            rt.r[2] = abi.read32(0x0803D914);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0803D918);
            rt.r[1] = abi.read32(0x0803D91C);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            if (!abi.call(decls.func_080791DC, 0x0803D903)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803DCBC() callconv(.c) void {
    if (!abi.enter(0x0803DCBC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_08015E3C, 0x0803DCC5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            if (!abi.call(decls.func_08015FF0, 0x0803DCCD)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            if (!abi.call(decls.func_08015E10, 0x0803DCD5)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803DF00, 0x0803DCF3)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08015F44, 0x0803DCE1)) return;
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
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08016918, 0x0803DCED)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0803DD24() callconv(.c) void {
    if (!abi.enter(0x0803DD24)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.r[0] = abi.read32(0x0803DD6C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[5] = abi.read32(0x0803DD70);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x38, true);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[2], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.r[4] = abi.read32(0x0803DD74);
            rt.r[0] = abi.read32(0x0803DD78);
            rt.r[12] = rt.r[0];
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x39, true);
            rt.cpuSub(&rt.r[7], rt.r[4], 0x5, true);
            abi.setRegNz(&rt.r[6], 0x2);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803DC44, 0x0803DD8F)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.cpuSub(&rt.r[1], rt.r[2], 0x1, true);
            rt.r[1] +%= rt.r[12];
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuSub(null, rt.r[2], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(4);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[2]));
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[7], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803E074() callconv(.c) void {
    if (!abi.enter(0x0803E074)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = abi.read32(0x0803E0C0);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
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
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x0803E0C4);
            abi.setRegNz(&rt.r[0], 0x7F);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[2] +% 0x8);
            if (!abi.call(decls.func_0807B44C, 0x0803E0A3)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803E244() callconv(.c) void {
    if (!abi.enter(0x0803E244)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[13] -%= 0x10;
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(func_0803E334, 0x0803E251)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x0803E274);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0xC);
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
            abi.fetches(5);
            rt.r[1] = rt.r[13];
            if (!abi.call(decls.func_0803E170, 0x0803E269)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.r[13] +%= 0x10;
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 2;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803E280() callconv(.c) void {
    if (!abi.enter(0x0803E280)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(func_0803E334, 0x0803E28B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(14);
            rt.r[3] = abi.read32(0x0803E2C4);
            rt.r[2] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0xC);
            abi.write32(rt.r[3] +% 0x0, rt.r[0]);
            rt.r[4] = abi.read32(0x0803E2C8);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803E170, 0x0803E2A3)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.r[1] = abi.read8(rt.r[4] +% 0x1);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
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
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            if (!abi.call(func_0803E244, 0x0803E2B1)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            if (!abi.call(func_0803E280, 0x0803E2BD)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803E2F0() callconv(.c) void {
    if (!abi.enter(0x0803E2F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[1] = abi.read32(0x0803E300);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.r[4] = abi.read32(0x0803E330);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803E170, 0x0803E30F)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.r[1] = abi.read8(rt.r[4] +% 0x1);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
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
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            if (!abi.call(func_0803E244, 0x0803E31D)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(func_0803E2F0, 0x0803E327)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0803E334() callconv(.c) void {
    if (!abi.enter(0x0803E334)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(0x0803E35C);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
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
            abi.setRegNz(&rt.r[3], 0x7F);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[4]);
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
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 3;
        },
        6 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803E4A0() callconv(.c) void {
    if (!abi.enter(0x0803E4A0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x0803E504);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0x4, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.r[4] = abi.read32(0x0803E508);
            abi.setRegNz(&rt.r[3], 0x1);
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            rt.r[3] = abi.read32(0x0803E508);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 6;
        },
        4 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[2] = abi.read32(0x0803E50C);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x10, true);
            rt.r[4] = abi.read32(0x0803E510);
            abi.setRegNz(&rt.r[3], 0xFA);
            abi.setRegNz(&rt.r[3], rt.r[3] << 2);
            continue :blk 7;
        },
        5 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 4;
        },
        7 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            abi.write32(rt.r[2] +% 0x28, rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 7;
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

fn func_0803E990() callconv(.c) void {
    if (!abi.enter(0x0803E990)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x5);
            if (!abi.call(decls.func_0803F014, 0x0803E99B)) return;
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
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803EFE8, 0x0803E9AB)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803E9C0() callconv(.c) void {
    if (!abi.enter(0x0803E9C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x7);
            if (!abi.call(decls.func_0803F014, 0x0803E9CB)) return;
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
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803EFE8, 0x0803E9DB)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803E9F0() callconv(.c) void {
    if (!abi.enter(0x0803E9F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(decls.func_0803F014, 0x0803E9FB)) return;
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
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803EFE8, 0x0803EA0B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803EA20() callconv(.c) void {
    if (!abi.enter(0x0803EA20)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x3);
            if (!abi.call(decls.func_0803F014, 0x0803EA2B)) return;
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
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803EFE8, 0x0803EA3B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803EA94() callconv(.c) void {
    if (!abi.enter(0x0803EA94)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803F02C, 0x0803EA9B)) return;
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
            abi.setRegNz(&rt.r[0], 0xB);
            if (!abi.call(decls.func_0803F02C, 0x0803EAAD)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803EAC0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803EACC() callconv(.c) void {
    if (!abi.enter(0x0803EACC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803F02C, 0x0803EAD3)) return;
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
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_0803F064, 0x0803EAE5)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803EAF8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803EB30() callconv(.c) void {
    if (!abi.enter(0x0803EB30)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803F02C, 0x0803EB37)) return;
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
            abi.setRegNz(&rt.r[0], 0x3);
            if (!abi.call(decls.func_0803F064, 0x0803EB49)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803EB5C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803EB68() callconv(.c) void {
    if (!abi.enter(0x0803EB68)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803F02C, 0x0803EB6F)) return;
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
            abi.setRegNz(&rt.r[0], 0x4);
            if (!abi.call(decls.func_0803F064, 0x0803EB81)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803EB94);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803EBA0() callconv(.c) void {
    if (!abi.enter(0x0803EBA0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803F02C, 0x0803EBA7)) return;
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
            abi.setRegNz(&rt.r[0], 0x5);
            if (!abi.call(decls.func_0803F064, 0x0803EBB9)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803EBCC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803EBD8() callconv(.c) void {
    if (!abi.enter(0x0803EBD8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803F02C, 0x0803EBDF)) return;
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
            abi.setRegNz(&rt.r[0], 0x5);
            if (!abi.call(decls.func_0803F02C, 0x0803EBF1)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x6);
            if (!abi.call(decls.func_0803F02C, 0x0803EBFD)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x7);
            if (!abi.call(decls.func_0803F02C, 0x0803EC09)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x8);
            if (!abi.call(decls.func_0803F02C, 0x0803EC15)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x9);
            if (!abi.call(decls.func_0803F02C, 0x0803EC21)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 15;
        },
        15 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803EDE0() callconv(.c) void {
    if (!abi.enter(0x0803EDE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[2] = abi.read32(0x0803EE18);
            rt.r[1] = abi.read32(rt.r[2] +% 0x4);
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
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x4, true);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(decls.func_0807B450, 0x0803EE09)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x18, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x18, true);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803EE5C() callconv(.c) void {
    if (!abi.enter(0x0803EE5C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[2] = abi.read32(0x0803EEB4);
            rt.r[1] = abi.read32(rt.r[2] +% 0x4);
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
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x4, true);
            rt.cpuAdd(&rt.r[7], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[7], 0x10, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[2], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[6], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0803EEB8);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[7], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0807B454, 0x0803EE97)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803F158() callconv(.c) void {
    if (!abi.enter(0x0803F158)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.r[5] = abi.read32(0x0803F1BC);
            abi.setRegNz(&rt.r[1], 0xA0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 19);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801AD38, 0x0803F173)) return;
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
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801AC1C, 0x0803F17F)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(8);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_080395A8, 0x0803F185)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0803FB44, 0x0803F18B)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(22);
            rt.r[0] = abi.read32(0x0803F1C0);
            rt.r[8] = rt.r[0];
            rt.r[5] = abi.read16(rt.r[0] +% 0x0);
            rt.r[6] = abi.read32(0x0803F1C4);
            rt.r[4] = abi.read16(rt.r[6] +% 0x0);
            rt.r[0] = abi.read32(0x0803F1C8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 28);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 30);
            abi.setRegNz(&rt.r[0], rt.r[0] << 14);
            abi.setRegNz(&rt.r[1], 0xC0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 19);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x5);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_080390E8, 0x0803F1B3)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(7);
            rt.r[1] = rt.r[8];
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[5]));
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[4]));
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803F1DC() callconv(.c) void {
    if (!abi.enter(0x0803F1DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            rt.r[5] = abi.read32(0x0803F230);
            abi.setRegNz(&rt.r[0], 0xA0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 19);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[4], rt.r[2] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801AD38, 0x0803F1F7)) return;
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
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801AC1C, 0x0803F203)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_080395A8, 0x0803F209)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0803FB44, 0x0803F20F)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(17);
            rt.r[0] = abi.read32(0x0803F234);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 28);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 30);
            abi.setRegNz(&rt.r[0], rt.r[0] << 14);
            abi.setRegNz(&rt.r[1], 0xC0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 19);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x5);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[7], 0x0, true);
            if (!abi.call(decls.func_080390E8, 0x0803F22D)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803F360() callconv(.c) void {
    if (!abi.enter(0x0803F360)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            rt.r[4] = abi.read32(0x0803F3A0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803F3AC, 0x0803F375)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803F3A4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x5, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[2], 0xE5);
            abi.setRegNz(&rt.r[2], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801A7A4, 0x0803F397)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08022800, 0x0803F381)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803F87C, 0x0803F39B)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[2] = abi.read32(0x0803F3A8);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[2], true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
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

fn func_0803FD1C() callconv(.c) void {
    if (!abi.enter(0x0803FD1C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.r[0] = abi.read32(rt.r[13] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 11;
        },
        8 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[2], 0, rt.r[1], true);
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[5], true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 15;
            }
            continue :blk 14;
        },
        10 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            continue :blk 5;
        },
        11 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 16;
            }
            continue :blk 4;
        },
        12 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 16;
            }
            continue :blk 17;
        },
        13 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[5], rt.r[4], true);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 16;
        },
        14 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[3], rt.r[4], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 15;
            }
            continue :blk 10;
        },
        15 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[1], true);
            continue :blk 5;
        },
        16 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            continue :blk 5;
        },
        17 => {
            abi.fetches(3);
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_08040008() callconv(.c) void {
    if (!abi.enter(0x08040008)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            rt.r[5] = abi.read32(0x08040030);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[4], rt.r[4] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1B);
            rt.r[2] = rt.r[9];
            abi.setRegNz(&rt.r[1], rt.r[2] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            abi.setRegNz(&rt.r[2], 0x1);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            abi.setRegNz(&rt.r[3], 0x2);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(func_0803FD1C, 0x08040027)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[1], true);
            abi.write8(rt.r[4] +% 0x1B, @truncate(rt.r[0]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08040160);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08025000, 0x08040147)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(9);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08040164);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0804014F)) return;
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_080400FC() callconv(.c) void {
    if (!abi.enter(0x080400FC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.r[4] = abi.read32(0x08040118);
            rt.r[0] = abi.read8(rt.r[4] +% 0xD);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.r[3] = rt.r[9];
            abi.setRegNz(&rt.r[1], rt.r[3] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            abi.setRegNz(&rt.r[2], 0x1);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x1);
            if (!abi.call(func_0803FD1C, 0x08040113)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.write8(rt.r[4] +% 0xD, @truncate(rt.r[0]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08040160);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08025000, 0x08040147)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(9);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08040164);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0804014F)) return;
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_08040100() callconv(.c) void {
    if (!abi.enter(0x08040100)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            rt.r[3] = rt.r[9];
            abi.setRegNz(&rt.r[1], rt.r[3] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            abi.setRegNz(&rt.r[2], 0x1);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x1);
            if (!abi.call(func_0803FD1C, 0x08040113)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.write8(rt.r[4] +% 0xD, @truncate(rt.r[0]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08040160);
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
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08025000, 0x08040147)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08040164);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0804014F)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08040190() callconv(.c) void {
    if (!abi.enter(0x08040190)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x080401C0);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x080401C4);
            rt.cpuAdd(&rt.r[5], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[5] +% 0x1C);
            rt.r[0] = abi.read32(0x080401C8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x5F, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write16(rt.r[5] +% 0x1E, @truncate(rt.r[0]));
            abi.write16(rt.r[5] +% 0x20, @truncate(rt.r[1]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0xA0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write16(rt.r[5] +% 0x1E, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[5] +% 0x20);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[5] +% 0x20, @truncate(rt.r[0]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            abi.setRegNz(&rt.r[1], 0xB4);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            if (!abi.call(decls.func_0807B564, 0x080401E5)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0807AED4, 0x080401E9)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 25));
            rt.r[5] = abi.read16(rt.r[5] +% 0x1E);
            rt.cpuAdd(&rt.r[4], rt.r[5], rt.r[4], true);
            rt.r[5] = abi.read32(0x08040214);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            if (!abi.call(decls.func_08013744, 0x08040203)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            continue :blk 8;
        },
        8 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013794, 0x0804020D)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080408F8() callconv(.c) void {
    if (!abi.enter(0x080408F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[4] = abi.read32(0x08040944);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08010C18, 0x08040907)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x08040948);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x4);
            if (!abi.call(decls.func_08010C18, 0x08040915)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x0804094C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x5F, true);
            rt.r[0] = abi.read32(0x08040930);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            if (!abi.call(decls.func_08040778, 0x0804092D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08022800, 0x08040971)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], 0x16);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[5] << 18);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[1], 0x10);
            abi.setRegNz(&rt.r[3], 0x4);
            if (!abi.call(decls.func_08040218, 0x08040967)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x0804097D)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 4;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011824, 0x08040981)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08040988() callconv(.c) void {
    if (!abi.enter(0x08040988)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.r[0] = abi.read32(0x080409B4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[0], 0xC0);
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
            abi.setRegNz(&rt.r[0], 0x40);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x080409B8);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x56, true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x080409F8);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x56, true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(14);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x5F, true);
            rt.r[0] = abi.read32(0x080409FC);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            if (!abi.call(decls.func_0804071C, 0x080409E5)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x080409E9)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011824, 0x080409ED)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x67);
            if (!abi.call(decls.func_0803D880, 0x080409F3)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08040A00() callconv(.c) void {
    if (!abi.enter(0x08040A00)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x08040A3C);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], 0x3);
            rt.r[0] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x66);
            if (!abi.call(decls.func_0803D880, 0x08040A17)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08040A60);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x5E, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08040A40);
            if (!abi.call(decls.func_0801329C, 0x08040A1D)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            continue :blk 8;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(func_08040988, 0x08040A69)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08040A74, 0x08040A21)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08040328, 0x08040A6D)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08040A44);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08040A29)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        11 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08040A48);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 10;
        },
        else => unreachable,
    }
}

fn func_08040A06() callconv(.c) void {
    if (!abi.enter(0x08040A06)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], 0x3);
            rt.r[0] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x66);
            if (!abi.call(decls.func_0803D880, 0x08040A17)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08040A60);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x5E, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08040A40);
            if (!abi.call(decls.func_0801329C, 0x08040A1D)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(func_08040988, 0x08040A69)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08040A74, 0x08040A21)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08040328, 0x08040A6D)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08040A44);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08040A29)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        10 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08040A48);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_080419C4() callconv(.c) void {
    if (!abi.enter(0x080419C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x08041A48);
            rt.r[4] = abi.read32(0x08041A4C);
            abi.setRegNz(&rt.r[0], 0x6E);
            abi.setRegNz(&rt.r[1], 0x2E);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x080419D5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[2] = abi.read32(0x08041A50);
            abi.setRegNz(&rt.r[0], 0xAE);
            abi.setRegNz(&rt.r[1], 0x2E);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x080419E1)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08041A54);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x55, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            rt.r[4] = abi.read32(0x08041A58);
            rt.r[3] = abi.read32(0x08041A5C);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.setRegNz(&rt.r[1], 0x28);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x080419FF)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080416E4, 0x080419F1)) return;
            continue :blk 3;
        },
        5 => {
            abi.fetches(8);
            rt.r[3] = abi.read32(0x08041A60);
            abi.setRegNz(&rt.r[0], 0x1C);
            abi.setRegNz(&rt.r[1], 0x40);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x08041A0B)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.r[2] = abi.read32(0x08041A64);
            rt.r[3] = abi.read32(0x08041A68);
            abi.setRegNz(&rt.r[0], 0x64);
            abi.setRegNz(&rt.r[1], 0x40);
            if (!abi.call(decls.func_0801B888, 0x08041A17)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(9);
            rt.r[4] = abi.read32(0x08041A6C);
            rt.r[3] = abi.read32(0x08041A70);
            abi.setRegNz(&rt.r[0], 0x9E);
            abi.setRegNz(&rt.r[1], 0x40);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x08041A25)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.r[3] = abi.read32(0x08041A74);
            abi.setRegNz(&rt.r[0], 0xC8);
            abi.setRegNz(&rt.r[1], 0x40);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x08041A31)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(8);
            rt.r[2] = abi.read32(0x08041A78);
            rt.r[3] = abi.read32(0x08041A7C);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[1], 0x20);
            if (!abi.call(decls.func_0801B888, 0x08041A3D)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080417A8, 0x08041A41)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08041C70() callconv(.c) void {
    if (!abi.enter(0x08041C70)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[1] = abi.read32(0x08041C98);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x59, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x37, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x59, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1B, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            rt.r[4] = abi.read8(rt.r[1] +% 0x0);
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x38);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            continue :blk 5;
        },
        5 => {
            abi.fetches(23);
            rt.r[3] = abi.read32(0x08041CE8);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x5F, true);
            rt.r[0] = abi.read32(0x08041CEC);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1A);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[4] >> 2);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08041CF0);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011374, 0x08041CD1)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x5A, true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x59, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08042048() callconv(.c) void {
    if (!abi.enter(0x08042048)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x5, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[0], 0x5);
            rt.r[1] = abi.read16(rt.r[1] +% 0x1E);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x58);
            abi.setRegNz(&rt.r[1], 0x66);
            abi.setRegNz(&rt.r[2], 0x30);
            abi.setRegNz(&rt.r[3], 0xC);
            if (!abi.call(decls.func_08041F90, 0x0804207F)) return;
            continue :blk 1;
        },
        6 => {
            abi.fetches(3);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0804214C() callconv(.c) void {
    if (!abi.enter(0x0804214C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x08042198);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x08042159)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 1));
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013744, 0x08042187)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08042191)) return;
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

fn func_0804219C() callconv(.c) void {
    if (!abi.enter(0x0804219C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[6] = abi.read32(0x080421E8);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x080421A9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[5], 0x80);
            abi.setRegNz(&rt.r[5], rt.r[5] << 1);
            rt.cpuSub(&rt.r[1], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[2], rt.r[1] >> 31);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 1));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x8, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013744, 0x080421D7)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[6] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x080421E1)) return;
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

fn func_0804231C() callconv(.c) void {
    if (!abi.enter(0x0804231C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[1] = abi.read32(0x08042364);
            rt.r[0] = abi.read32(0x08042368);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x22);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801BEBC, 0x08042333)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[4] = abi.read32(0x0804236C);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            if (!abi.call(decls.func_0800FE24, 0x0804233B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[1], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[5] << 8);
            rt.r[2] = abi.read32(0x08042370);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xC0);
            if (!abi.call(decls.func_0800FDA4, 0x08042353)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], 0x5, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 3;
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

fn func_08042374() callconv(.c) void {
    if (!abi.enter(0x08042374)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x4;
            rt.r[1] = rt.r[13];
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080423D0);
            rt.r[0] = rt.r[13];
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(0x080423D4);
            abi.write32(rt.r[1] +% 0x4, rt.r[0]);
            rt.r[0] = abi.read32(0x080423D8);
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x8);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[5] = abi.read32(0x080423DC);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x080423E0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x22);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_0801BEA0, 0x080423A3)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[1], rt.r[4] << 7);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[4] << 8);
            rt.r[2] = abi.read32(0x080423E4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0x80);
            if (!abi.call(decls.func_0800FDA4, 0x080423B3)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x78);
            abi.setRegNz(&rt.r[1], 0x88);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(decls.func_080421EC, 0x080423C7)) return;
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

fn func_080423E8() callconv(.c) void {
    if (!abi.enter(0x080423E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[4] = abi.read32(0x0804245C);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x22);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x43, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x3, true);
            if (!abi.call(decls.func_0807B564, 0x080423FF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.cpuAdd(&rt.r[7], rt.r[4], 0x0, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x43, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08042460);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[5] << 20);
            abi.setRegNz(&rt.r[0], 0xA8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 15);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801BF00, 0x0804242B)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801BF2C, 0x08042433)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(18);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], 0x7, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(func_08042374, 0x08042457)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08042464() callconv(.c) void {
    if (!abi.enter(0x08042464)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x08042484);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x33, true);
            rt.r[5] = abi.read8(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x38);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], 0x22);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x43, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[2], 0x22);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x43, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x3, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0807B564, 0x08042497)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.r[0] = abi.read32(0x080424C8);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[5] << 20);
            abi.setRegNz(&rt.r[0], 0xA8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 15);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801BF00, 0x080424B1)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801BF2C, 0x080424B9)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080424CC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2B, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080424D0() callconv(.c) void {
    if (!abi.enter(0x080424D0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[0] = abi.read32(0x08042524);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x38);
            rt.cpuSub(null, rt.r[0], 0xB, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.r[5] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[5] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x6);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(19);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[3], rt.r[1] >> 16);
            rt.cpuSub(null, rt.r[3], 0x6, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(19);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[3], true);
            rt.cpuSub(&rt.r[1], rt.r[3], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[3], rt.r[1] >> 16);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x33, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(15);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2B, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x33, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_080427D0() callconv(.c) void {
    if (!abi.enter(0x080427D0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x080427F0);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x38);
            rt.r[2] = rt.sext16(abi.read16(rt.r[3] +% rt.r[1]));
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[2], 0x1, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08042848);
            abi.setRegNz(&rt.r[1], 0x7E);
            if (!abi.call(decls.func_08015824, 0x08042831)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804284C);
            abi.setRegNz(&rt.r[1], 0x7F);
            if (!abi.call(decls.func_08015824, 0x08042839)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0xC, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read16(rt.r[3] +% 0x38);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xA, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[3] +% 0x38, @truncate(rt.r[0]));
            abi.write16(rt.r[3] +% 0x3A, @truncate(rt.r[1]));
            continue :blk 8;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0xB, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x3A);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x3A, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0xB, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(3);
            continue :blk 8;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(func_080424D0, 0x08042813)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08042840);
            if (!abi.call(decls.func_0801329C, 0x08042823)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x38, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x4);
            abi.write16(rt.r[0] +% 0x3C, @truncate(rt.r[1]));
            continue :blk 11;
        },
        13 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08042844);
            if (!abi.call(decls.func_0801329C, 0x08042829)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08042A80() callconv(.c) void {
    if (!abi.enter(0x08042A80)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08042AC0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x9);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08042B14);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(23);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[5] +% 0x8, rt.r[0]);
            rt.r[4] = abi.read32(0x08042AC4);
            rt.r[2] = abi.read32(0x08042AC8);
            rt.r[0] = abi.read32(0x08042ACC);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read32(0x08042AD0);
            abi.setRegNz(&rt.r[5], 0x22);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[5]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x71);
            if (!abi.call(decls.func_0803D880, 0x08042ABD)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
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
            abi.fetches(3);
            continue :blk 4;
        },
        6 => {
            abi.fetches(18);
            rt.r[2] = abi.read32(0x08042B18);
            rt.r[0] = abi.read32(0x08042B1C);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x44, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read32(0x08042B20);
            abi.setRegNz(&rt.r[6], 0x22);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[6]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x66);
            if (!abi.call(decls.func_0803D880, 0x08042B07)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08042B24);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.write32(rt.r[5] +% 0x8, rt.r[4]);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08042E8C() callconv(.c) void {
    if (!abi.enter(0x08042E8C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08042EC4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(23);
            rt.r[0] = abi.read32(0x08042F00);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x6);
            abi.write16(rt.r[1] +% 0x26, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x41);
            abi.write16(rt.r[1] +% 0x28, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08042F04);
            abi.write16(rt.r[1] +% 0x2A, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            abi.write16(rt.r[1] +% 0x2C, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[2], 0x4B);
            abi.write16(rt.r[1] +% 0x2E, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[0], 0x43);
            abi.write16(rt.r[1] +% 0x30, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x4F);
            abi.write16(rt.r[1] +% 0x32, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x48);
            abi.write16(rt.r[1] +% 0x34, @truncate(rt.r[0]));
            abi.write16(rt.r[1] +% 0x36, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3C, true);
            abi.setRegNz(&rt.r[0], 0x8);
            continue :blk 3;
        },
        2 => {
            abi.fetches(25);
            rt.r[0] = abi.read32(0x08042EC8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write16(rt.r[1] +% 0x26, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x29);
            abi.write16(rt.r[1] +% 0x28, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08042ECC);
            abi.write16(rt.r[1] +% 0x2A, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x58, true);
            abi.write16(rt.r[1] +% 0x2C, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x46);
            abi.write16(rt.r[1] +% 0x2E, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x50);
            abi.write16(rt.r[1] +% 0x30, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x57);
            abi.write16(rt.r[1] +% 0x32, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x30);
            abi.write16(rt.r[1] +% 0x34, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x2C);
            abi.write16(rt.r[1] +% 0x36, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3C, true);
            abi.setRegNz(&rt.r[0], 0x5);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_08043780() callconv(.c) void {
    if (!abi.enter(0x08043780)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = abi.read32(0x080437EC);
            rt.r[6] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[12] = rt.r[0];
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.r[2] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[2], rt.r[1] << 1);
            rt.r[0] = abi.read32(0x080437F4);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[3] +% 0x2E);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.r[4] = abi.read32(0x080437F0);
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            continue :blk 4;
        },
        4 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(0x080437F8);
            rt.r[7] = abi.read16(rt.r[3] +% 0x2A);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[1] = abi.read16(rt.r[6] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.r[2] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            rt.r[4] = abi.read32(0x080437F0);
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], rt.r[1] << 1);
            rt.r[0] = abi.read16(rt.r[3] +% 0x30);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            continue :blk 8;
        },
        8 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x080437FC);
            rt.r[3] = abi.read16(rt.r[3] +% 0x2C);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08043CC4() callconv(.c) void {
    if (!abi.enter(0x08043CC4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.r[2] >> 16);
            rt.r[0] = abi.read32(0x08043D1C);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 11);
            rt.r[1] = abi.read32(0x08043D20);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_0800FE18, 0x08043CE1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
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
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x11, true);
            rt.r[7] = abi.read32(0x08043D24);
            continue :blk 4;
        },
        4 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.r[2] = abi.read32(0x08043D20);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            if (!abi.call(decls.func_0800FE18, 0x08043CFF)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0x12, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08043D28);
            abi.setRegNz(&rt.r[1], rt.r[6] << 21);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_08011330, 0x08043D15)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08043E28() callconv(.c) void {
    if (!abi.enter(0x08043E28)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 24);
            rt.r[2] = abi.read32(0x08043E78);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.write16(rt.r[3] +% 0x1E, @truncate(rt.r[0]));
            abi.write16(rt.r[3] +% 0x20, @truncate(rt.r[6]));
            abi.setRegNz(&rt.r[5], 0x0);
            abi.setRegNz(&rt.r[0], 0x1E);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[0]));
            rt.r[0] = abi.read32(0x08043E7C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[5], 0x1);
            continue :blk 1;
        },
        3 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[1]));
            rt.r[3] = abi.read16(rt.r[3] +% 0x26);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            continue :blk 4;
        },
        6 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x1E, @truncate(rt.r[0]));
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
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

fn func_08044AE4() callconv(.c) void {
    if (!abi.enter(0x08044AE4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0804473C, 0x08044AEB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08044AFC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x08044B18);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x32);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x34);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.r[2] = abi.read32(0x08044B1C);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.r[3] = abi.read32(0x08044B40);
            if (!abi.call(decls.func_0801B888, 0x08044B37)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        7 => {
            abi.fetches(3);
            continue :blk 12;
        },
        8 => {
            abi.fetches(3);
            continue :blk 12;
        },
        9 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08044B38);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x32);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x34);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.r[2] = abi.read32(0x08044B3C);
            rt.r[2] = abi.read32(rt.r[2] +% 0x4);
            continue :blk 4;
        },
        10 => {
            abi.fetches(3);
            continue :blk 12;
        },
        11 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08044B60);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x32);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x34);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.r[2] = abi.read32(0x08044B64);
            rt.r[2] = abi.read32(rt.r[2] +% 0x8);
            rt.r[3] = abi.read32(0x08044B68);
            if (!abi.call(decls.func_0801B888, 0x08044B5B)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08044B98() callconv(.c) void {
    if (!abi.enter(0x08044B98)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[1] = abi.read32(0x08044BF8);
            rt.r[5] = abi.read32(0x08044BFC);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x42, true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(decls.func_0803EFCC, 0x08044BBB)) return;
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
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x76);
            if (!abi.call(decls.func_0803D880, 0x08044BC7)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(func_08043780, 0x08044BCB)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0xA3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(8);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            rt.r[1] = abi.read32(0x08044C00);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08044C0C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08044BF3)) return;
            continue :blk 1;
        },
        9 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x08044C04);
            rt.r[0] = abi.read16(rt.r[2] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x28, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08044C08);
            rt.r[0] = abi.read16(rt.r[2] +% 0x2C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_08044EE8() callconv(.c) void {
    if (!abi.enter(0x08044EE8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x08044F04);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            rt.r[6] = abi.read32(0x08044F08);
            rt.cpuAdd(&rt.r[3], rt.r[4], rt.r[6], true);
            rt.r[1] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08044F28);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[2] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[1] = abi.read32(0x08044F40);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            continue :blk 7;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[1], 0x1E);
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_080459C4() callconv(.c) void {
    if (!abi.enter(0x080459C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[4] = abi.read32(0x08045A04);
            abi.setRegNz(&rt.r[3], 0xBA);
            abi.setRegNz(&rt.r[3], rt.r[3] << 1);
            rt.r[2] = abi.read32(0x08045A08);
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x080459EB)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_080198FC, 0x080459F7)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0801FF70, 0x080459FB)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08020190, 0x080459FF)) return;
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

fn func_08045A28() callconv(.c) void {
    if (!abi.enter(0x08045A28)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[3] = abi.read32(0x08045A94);
            abi.setRegNz(&rt.r[2], 0x1F);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[1]));
            rt.r[3] = abi.read32(0x08045A98);
            abi.setRegNz(&rt.r[1], 0xE0);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08045AA0);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            if (!abi.call(decls.func_08021DF8, 0x08045A61)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[2], rt.r[1] >> 21);
            rt.r[0] = abi.read32(0x08045A9C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1A);
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08045AA4);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08045A69)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08045AA8);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08045A71)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08045AAC);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08045AB0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x6, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08045AB4);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08045AC4);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080465C8() callconv(.c) void {
    if (!abi.enter(0x080465C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[3], rt.r[1] >> 16);
            rt.r[1] = abi.read32(0x080465EC);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1A);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x2);
            if (!abi.call(decls.func_0802FC70, 0x08046615)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x3, true);
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
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x4, true);
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
            continue :blk 11;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0802FC70, 0x0804660B)) return;
            continue :blk 12;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x5, true);
            if (rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_0802FC70, 0x0804661F)) return;
            continue :blk 14;
        },
        11 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0802FC70, 0x08046601)) return;
            continue :blk 15;
        },
        12 => {
            abi.fetches(3);
            continue :blk 6;
        },
        13 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x4);
            if (!abi.call(decls.func_0802FC70, 0x08046629)) return;
            continue :blk 6;
        },
        14 => {
            abi.fetches(3);
            continue :blk 6;
        },
        15 => {
            abi.fetches(3);
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_080468CC() callconv(.c) void {
    if (!abi.enter(0x080468CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[5] +% 0x26);
            rt.cpuSub(null, rt.r[0], 0x61, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read16(rt.r[5] +% 0x26);
            rt.cpuSub(null, rt.r[1], 0x30, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[5] +% 0x26, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            rt.r[6] = abi.read16(rt.r[5] +% 0x26);
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x62);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 5;
        },
        5 => {
            abi.fetches(18);
            rt.r[3] = abi.read32(0x0804692C);
            rt.r[2] = abi.read32(0x08046930);
            rt.r[0] = abi.read32(0x08046934);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x1A);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x7);
            if (!abi.call(decls.func_0807B634, 0x0804690D)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 15);
            rt.r[2] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read32(0x08046938);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011374, 0x0804691F)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[5] +% 0x24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.r[0] = abi.read16(rt.r[5] +% 0x26);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[5] +% 0x26, @truncate(rt.r[0]));
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[5] +% 0x24, @truncate(rt.r[0]));
            continue :blk 10;
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

fn func_08046FFC() callconv(.c) void {
    if (!abi.enter(0x08046FFC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[7], rt.r[1] >> 16);
            rt.r[0] = abi.read32(0x08047054);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x78);
            if (!abi.call(decls.func_0807B6AC, 0x08047011)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 14);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[4], true);
            abi.setRegNz(&rt.r[1], 0xF);
            if (!abi.call(decls.func_0807B564, 0x0804701F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x08047058);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[4] << 17);
            abi.setRegNz(&rt.r[2], 0x9C);
            abi.setRegNz(&rt.r[2], rt.r[2] << 18);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011374, 0x08047035)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0x7, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[7] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0804705C);
            rt.r[3] = abi.read32(0x08047060);
            if (!abi.call(decls.func_0801B888, 0x0804704F)) return;
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

fn func_0804711E() callconv(.c) void {
    if (!abi.enter(0x0804711E)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x5);
            if (!abi.call(decls.func_0807B634, 0x0804712D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.write16(rt.r[6] +% 0x22, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[1], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x08047198);
            abi.setRegNz(&rt.r[1], 0x25);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0804719C);
            rt.r[3] = abi.read32(0x080471A0);
            if (!abi.call(decls.func_0801B888, 0x0804714F)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x20);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x29, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x4, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x65, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0804719C);
            rt.r[3] = abi.read32(0x080471A0);
            abi.setRegNz(&rt.r[0], 0x75);
            if (!abi.call(decls.func_0801B888, 0x08047171)) return;
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

fn func_08047588() callconv(.c) void {
    if (!abi.enter(0x08047588)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0801833C, 0x0804758F)) return;
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
            rt.r[0] = abi.read32(0x080475AC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0x1E);
            if (!abi.call(decls.func_080471F8, 0x080475A9)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0x1E);
            if (!abi.call(decls.func_080471A4, 0x080475B7)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080475C4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x080475BF)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08047716() callconv(.c) void {
    if (!abi.enter(0x08047716)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x0804775C);
            abi.setRegNz(&rt.r[1], 0x8);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[2], 0x5);
            abi.setRegNz(&rt.r[3], 0xB);
            if (!abi.call(decls.func_08010C70, 0x0804772F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x08047733)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x2);
            if (!abi.call(decls.func_08022640, 0x08047739)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08047760);
            if (!abi.call(decls.func_080392A4, 0x0804773F)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080226A4, 0x08047743)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x71);
            if (!abi.call(decls.func_0803D880, 0x08047753)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.r[4] = abi.read32(0x08047818);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080475C8, 0x080477F9)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        11 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[2] = abi.read16(rt.r[0] +% 0x1E);
            rt.r[3] = abi.read16(rt.r[0] +% 0x20);
            rt.cpuSub(&rt.r[1], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 20);
            abi.setRegNz(&rt.r[0], 0xA0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 14);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], 0x3);
            if (!abi.call(func_08046FFC, 0x08047811)) return;
            continue :blk 10;
        },
        else => unreachable,
    }
}

fn func_08047838() callconv(.c) void {
    if (!abi.enter(0x08047838)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x8;
            rt.r[3] = abi.read32(0x08047868);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0xAC);
            abi.setRegNz(&rt.r[1], 0x60);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(decls.func_080422C4, 0x0804784D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[4] = abi.read32(0x0804786C);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08047064, 0x08047881)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08047870);
            rt.r[2] = abi.read32(0x08047874);
            rt.r[3] = abi.read32(0x08047878);
            abi.setRegNz(&rt.r[0], 0x23);
            if (!abi.call(decls.func_0801B888, 0x08047865)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[2] = abi.read16(rt.r[0] +% 0x20);
            rt.r[0] = abi.read32(0x080478B8);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0xC);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x65);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[3], 0x4);
            if (!abi.call(decls.func_08043D2C, 0x08047897)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.r[2] = abi.read32(0x080478BC);
            rt.r[3] = abi.read32(0x080478C0);
            abi.setRegNz(&rt.r[0], 0x88);
            abi.setRegNz(&rt.r[1], 0x4);
            if (!abi.call(decls.func_0801B888, 0x080478A3)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080478C4);
            abi.setRegNz(&rt.r[1], 0x4);
            if (!abi.call(decls.func_08049998, 0x080478AB)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(func_080382A8, 0x080478AF)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08047F74() callconv(.c) void {
    if (!abi.enter(0x08047F74)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x08047FB0);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x5D, true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(decls.func_080478EC, 0x08047FA3)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            continue :blk 1;
        },
        3 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2C, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08048084() callconv(.c) void {
    if (!abi.enter(0x08048084)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x8;
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], 0xB0);
            if (!abi.call(decls.func_0801B8D4, 0x08048093)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(20);
            rt.r[4] = abi.read32(0x08048104);
            rt.r[5] = abi.read32(0x08048108);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x61, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x5E, true);
            rt.r[3] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0xBA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08010C70, 0x080480B7)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(16);
            rt.r[3] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x61, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2C, true);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 8);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x2);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08012A68, 0x080480D3)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            if (!abi.call(decls.func_08019288, 0x080480DB)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x5D, true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x65, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x080480FD)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x65, true);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[2], rt.r[6], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 5;
        },
        7 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08048980() callconv(.c) void {
    if (!abi.enter(0x08048980)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x8;
            rt.r[1] = abi.read32(0x080489A8);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0xA, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080489AC);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0xA, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080489B0);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read16(rt.r[2] +% 0x2A);
            abi.setRegNz(&rt.r[4], 0x2A);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[4]));
            rt.cpuSub(null, rt.r[0], 0xA0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0xA0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[3], 0x4, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(21);
            abi.write16(rt.r[2] +% 0x2A, @truncate(rt.r[0]));
            rt.r[4] = abi.read16(rt.r[1] +% 0x0);
            rt.r[0] = abi.read32(0x08048A10);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 3));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x5, true);
            abi.setRegNz(&rt.r[0], 0x1F);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[0]);
            rt.r[0] = abi.read32(0x08048A14);
            abi.setRegNz(&rt.r[5], 0x14);
            abi.write32(rt.r[13] +% 0x0, rt.r[5]);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x3);
            if (!abi.call(decls.func_08010C70, 0x080489DD)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x08048A18);
            abi.write32(rt.r[13] +% 0x0, rt.r[5]);
            rt.r[1] = abi.read32(0x08048A1C);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x3);
            if (!abi.call(decls.func_08010C70, 0x080489EF)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x080489F3)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011824, 0x080489F7)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08048A20);
            if (!abi.call(decls.func_08018400, 0x08048A01)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08048A24);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08048A09)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_08048B7C() callconv(.c) void {
    if (!abi.enter(0x08048B7C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[6] = abi.read32(0x08048BCC);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x08048B89)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[5], 0x80);
            abi.setRegNz(&rt.r[5], rt.r[5] << 1);
            rt.cpuSub(&rt.r[1], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[2], rt.r[1] >> 31);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 1));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x8, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013744, 0x08048BB7)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x79);
            if (!abi.call(decls.func_0803D880, 0x08048BC1)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[6] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08048BC7)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_08048BE0() callconv(.c) void {
    if (!abi.enter(0x08048BE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x28, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x08048BF8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08048CA0 => continue :blk 4,
                0x08048CF6 => { continue :blk 3; },
                0x08048CD4 => continue :blk 5,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        2 => {
            abi.fetches(3);
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(19);
            rt.r[0] = abi.read32(0x08048CCC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x21, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x08048CD0);
            abi.setRegNz(&rt.r[2], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_08011330, 0x08048CC3)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08048D04);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x22, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(func_0804B460, 0x08048CE5)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read16(rt.r[4] +% 0x20);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x20, @truncate(rt.r[0]));
            continue :blk 3;
        },
        7 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08048D08);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08048D0C);
            if (!abi.call(decls.func_0801329C, 0x08048CEF)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08048D10);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08048CF7)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08048E94() callconv(.c) void {
    if (!abi.enter(0x08048E94)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x08048EF4);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x08048EA1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 1));
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013744, 0x08048ECF)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(func_0804B460, 0x08048ED9)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x08048EF8);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            if (!abi.call(decls.func_080496E4, 0x08048EE7)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08048EED)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_08048EFC() callconv(.c) void {
    if (!abi.enter(0x08048EFC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[6] = abi.read32(0x08048F48);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x08048F09)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[5], 0x80);
            abi.setRegNz(&rt.r[5], rt.r[5] << 1);
            rt.cpuSub(&rt.r[1], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[2], rt.r[1] >> 31);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 1));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x8, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013744, 0x08048F37)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[6] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08048F41)) return;
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

fn func_0804912C() callconv(.c) void {
    if (!abi.enter(0x0804912C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[5], 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = rt.r[13];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.r[1] = abi.read32(0x08049190);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[7] << 5);
            rt.r[2] = abi.read32(0x08049194);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write32(rt.r[1] +% 0x4, rt.r[0]);
            rt.r[0] = abi.read32(0x08049198);
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x8);
            rt.r[1] = abi.read32(0x0804919C);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(16);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[6], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[4], 2));
            abi.setRegNz(&rt.r[2], 0xFE);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xD0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.r[2] = abi.read32(0x080491A0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08052230, 0x08049175)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[6], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08049500() callconv(.c) void {
    if (!abi.enter(0x08049500)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x4;
            rt.r[0] = abi.read32(0x08049544);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[4], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 5);
            rt.r[1] = abi.read32(0x08049548);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[1], true);
            rt.r[5] = rt.r[13];
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x2, true);
            rt.r[1] = rt.r[13];
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08013578, 0x08049521)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.r[0] = rt.r[13];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            abi.write16(rt.r[4] +% 0x20, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0804954C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08049550);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_080131E0, 0x0804953D)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_080497B8() callconv(.c) void {
    if (!abi.enter(0x080497B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(25);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[7], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[8] = rt.r[1];
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x1);
            rt.r[1] = abi.read32(0x08049824);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[6]);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[5] << 5);
            rt.r[2] = abi.read32(0x08049828);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            if (!abi.call(decls.func_0800FE18, 0x080497E7)) return;
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0804982C);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08049674, 0x080497F5)) return;
            continue :blk 2;
        },
        4 => {
            abi.fetches(7);
            rt.r[4] = abi.read32(0x0804982C);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(decls.func_080496E4, 0x08049803)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08049830);
            rt.r[1] = rt.r[8];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x10, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 21);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], 0x60);
            if (!abi.call(decls.func_08011330, 0x0804981B)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(decls.func_08049758, 0x0804980B)) return;
            continue :blk 5;
        },
        7 => {
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

fn func_08049A50() callconv(.c) void {
    if (!abi.enter(0x08049A50)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[4], 0x1);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_08038F9C, 0x08049A5B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(0x08049A8C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        3 => {
            abi.fetches(4);
            rt.r[3] = abi.read32(0x08049A90);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08049B3C() callconv(.c) void {
    if (!abi.enter(0x08049B3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[4], 0x1);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(decls.func_08038F9C, 0x08049B47)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = abi.read32(0x08049B5C);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        3 => {
            abi.fetches(5);
            rt.r[2] = abi.read32(0x08049B60);
            rt.r[1] = abi.read8(rt.r[1] +% 0x4);
            continue :blk 4;
        },
        4 => {
            abi.fetches(10);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x60, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x08049B98);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 2;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08049E20() callconv(.c) void {
    if (!abi.enter(0x08049E20)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x08049E6C);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x08049E2D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 1));
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013744, 0x08049E5B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08049E65)) return;
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

fn func_08049E70() callconv(.c) void {
    if (!abi.enter(0x08049E70)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[6] = abi.read32(0x08049EBC);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x08049E7D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[5], 0x80);
            abi.setRegNz(&rt.r[5], rt.r[5] << 1);
            rt.cpuSub(&rt.r[1], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[2], rt.r[1] >> 31);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 1));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x8, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013744, 0x08049EAB)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[6] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08049EB5)) return;
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

fn func_0804A400() callconv(.c) void {
    if (!abi.enter(0x0804A400)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[1] = abi.read32(0x0804A440);
            rt.r[4] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 14);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x38, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x50, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_0807B488, 0x0804A423)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x14, true);
            rt.r[0] = abi.read32(0x0804A444);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.write32(rt.r[5] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xB0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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
            abi.fetches(5);
            rt.r[2] = abi.read32(0x0804A448);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0804A44C() callconv(.c) void {
    if (!abi.enter(0x0804A44C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[1] = abi.read32(0x0804A488);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 14);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x50, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_0807B488, 0x0804A469)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x14, true);
            rt.r[2] = abi.read32(0x0804A48C);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(null, rt.r[4], 0xB0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(0x0804A490);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0804B3C0() callconv(.c) void {
    if (!abi.enter(0x0804B3C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0804B400);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 1);
            abi.setRegNz(&rt.r[1], 0xF);
            if (!abi.call(decls.func_0807B6AC, 0x0804B3D3)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x0804B404);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[4] << 17);
            abi.setRegNz(&rt.r[2], 0xE8);
            abi.setRegNz(&rt.r[2], rt.r[2] << 18);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011374, 0x0804B3EB)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            rt.cpuSub(null, rt.r[4], 0x7, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804B408);
            abi.setRegNz(&rt.r[1], 0x7F);
            if (!abi.call(decls.func_08015824, 0x0804B3FB)) return;
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

fn func_0804B460() callconv(.c) void {
    if (!abi.enter(0x0804B460)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.r[6] = abi.read32(0x0804B484);
            rt.r[4] = abi.read32(0x0804B488);
            rt.r[0] = abi.read32(rt.r[4] +% 0x14);
            abi.setRegNz(&rt.r[1], 0x14);
            if (!abi.call(decls.func_080796C8, 0x0804B473)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x5F, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x60);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[4] +% 0x14);
            abi.setRegNz(&rt.r[1], 0x14);
            if (!abi.call(decls.func_080796C8, 0x0804B481)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            abi.write8(rt.r[6] +% 0x8, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            continue :blk 4;
        },
        6 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0804B4AC);
            rt.r[2] = abi.read8(rt.r[1] +% 0x8);
            rt.r[3] = abi.read8(rt.r[1] +% 0x9);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        8 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[1] +% 0x9);
            continue :blk 7;
        },
        else => unreachable,
    }
}

fn func_0804BCAC() callconv(.c) void {
    if (!abi.enter(0x0804BCAC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[4] = abi.read32(0x0804BCD0);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x20);
            abi.setRegNz(&rt.r[3], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[3]));
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x26);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x26, @truncate(rt.r[0]));
            rt.r[5] = abi.read32(0x0804BD1C);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[1] = abi.read16(rt.r[5] +% 0xA);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_C) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x8, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x6C);
            if (!abi.call(decls.func_0803D880, 0x0804BCF1)) return;
            continue :blk 7;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3C, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x6B);
            if (!abi.call(decls.func_0803D880, 0x0804BCCF)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = abi.read32(0x0804BD20);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0804BD1C);
            rt.r[1] = abi.read16(rt.r[1] +% 0x26);
            rt.r[0] = abi.read16(rt.r[0] +% 0xA);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_C) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[5] +% 0xA);
            abi.write16(rt.r[1] +% 0x26, @truncate(rt.r[0]));
            continue :blk 4;
        },
        8 => {
            abi.fetches(3);
            continue :blk 6;
        },
        9 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_0804BD24() callconv(.c) void {
    if (!abi.enter(0x0804BD24)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[3] = abi.read32(0x0804BD48);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x20);
            abi.setRegNz(&rt.r[4], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[4]));
            rt.cpuSub(null, rt.r[0], 0x5, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x26);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x26, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3C, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0804BD88);
            rt.r[1] = abi.read16(rt.r[2] +% 0xC);
            rt.r[0] = abi.read32(0x0804BD8C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x6, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[2] +% 0xC, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x26);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x6B);
            if (!abi.call(decls.func_0803D880, 0x0804BD47)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0804BD90);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x26);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x6C);
            if (!abi.call(decls.func_0803D880, 0x0804BD7B)) return;
            continue :blk 6;
        },
        8 => {
            abi.fetches(3);
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0804D1A8() callconv(.c) void {
    if (!abi.enter(0x0804D1A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x0804D1EC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x78);
            if (!abi.call(decls.func_0807B6AC, 0x0804D1B5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 2);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[4], true);
            abi.setRegNz(&rt.r[1], 0xF);
            if (!abi.call(decls.func_0807B564, 0x0804D1C5)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x0804D1F0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[4] << 17);
            abi.setRegNz(&rt.r[2], 0x90);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011374, 0x0804D1DB)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
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

fn func_0804D998() callconv(.c) void {
    if (!abi.enter(0x0804D998)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0804D9D0);
            rt.r[0] = abi.read32(0x0804D9D4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x0804D9D8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_080183C0, 0x0804D9B1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0804D9DC);
            if (!abi.call(decls.func_0801329C, 0x0804D9B7)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0804D9E0);
            if (!abi.call(decls.func_0801329C, 0x0804D9BD)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[2] = abi.read32(0x0804D9E4);
            rt.r[1] = abi.read8(rt.r[2] +% 0x1C);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (rt.CPU_Z) {
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
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.write8(rt.r[2] +% 0x1C, @truncate(rt.r[0]));
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0804DAE0() callconv(.c) void {
    if (!abi.enter(0x0804DAE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.r[1] = abi.read32(0x0804DB54);
            rt.r[7] = abi.read8(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[2] = abi.read32(0x0804DB58);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
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
            abi.fetches(10);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[1] = abi.read32(0x0804DB5C);
            abi.setRegNz(&rt.r[0], rt.r[7] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[8] = rt.r[0];
            continue :blk 3;
        },
        3 => {
            abi.fetches(18);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x79, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[1], 0xFF);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4D, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3E, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = rt.r[8];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0807B44C, 0x0804DB2D)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x79, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[5] +% 0x2);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x7E, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.write8(rt.r[5] +% 0x2, @truncate(rt.r[7]));
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0804DB60() callconv(.c) void {
    if (!abi.enter(0x0804DB60)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0804DBA4);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(25);
            rt.r[2] = abi.read32(0x0804DBA8);
            rt.r[3] = abi.read32(0x0804DBAC);
            rt.r[0] = abi.read32(0x0804DBB0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x5A, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            rt.r[4] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x7A, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0804DBB4);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x47, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x10);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_08043C64, 0x0804DB9F)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
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

fn func_0804E23C() callconv(.c) void {
    if (!abi.enter(0x0804E23C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x0804E25C);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x31, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0801833C, 0x0804E269)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0804E260);
            if (!abi.call(decls.func_08018400, 0x0804E251)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x31, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804E284);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0804E279)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x31, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0804E288() callconv(.c) void {
    if (!abi.enter(0x0804E288)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[2] = abi.read32(0x0804E2C4);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x2C);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[3] +% 0x2E);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[3] = abi.read16(rt.r[1] +% 0x2C);
            abi.setRegNz(&rt.r[0], rt.r[3] >> 1);
            abi.write16(rt.r[1] +% 0x2C, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(19);
            rt.r[2] = abi.read32(0x0804E2C8);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[0], 0x1E);
            rt.r[2] = rt.sext16(abi.read16(rt.r[3] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[3] = abi.read16(rt.r[3] +% 0x2C);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(18);
            rt.r[2] = abi.read32(0x0804E304);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[0], 0x1E);
            rt.r[2] = rt.sext16(abi.read16(rt.r[3] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[3] = abi.read16(rt.r[3] +% 0x2C);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            continue :blk 5;
        },
        5 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0804E308);
            rt.r[3] = abi.read32(0x0804E30C);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0801B888, 0x0804E2FF)) return;
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

fn func_0804E310() callconv(.c) void {
    if (!abi.enter(0x0804E310)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x0804E358);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x78);
            if (!abi.call(decls.func_0807B6AC, 0x0804E31D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 14);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[4], true);
            abi.setRegNz(&rt.r[1], 0xF);
            if (!abi.call(decls.func_0807B564, 0x0804E32B)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x0804E35C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[4] << 17);
            abi.setRegNz(&rt.r[2], 0xDC);
            abi.setRegNz(&rt.r[2], rt.r[2] << 18);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011374, 0x0804E341)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0x7, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804E360);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_08015824, 0x0804E353)) return;
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

fn func_0804E520() callconv(.c) void {
    if (!abi.enter(0x0804E520)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6 });
            rt.r[8] = rt.r[0];
            rt.r[0] = abi.read32(0x0804E574);
            rt.r[6] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = rt.r[8];
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[5] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[5], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x50, true);
            rt.cpuAdd(&rt.r[5], rt.r[6], rt.r[5], true);
            rt.r[4] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_0807B634, 0x0804E543)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            rt.cpuSub(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[4]));
            rt.r[2] = rt.r[8];
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[6], rt.r[6], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_0807B634, 0x0804E559)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(7);
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0804E578);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0804E56B)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0804E820() callconv(.c) void {
    if (!abi.enter(0x0804E820)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[2] = abi.read32(0x0804E88C);
            rt.r[3] = abi.read32(0x0804E890);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[4] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[1], true);
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
            abi.fetches(3);
            rt.cpuAdd(&rt.r[6], rt.r[3], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(26);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[5], rt.r[2] << 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[5], 16));
            abi.setRegNz(&rt.r[1], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x50, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[2] = abi.read32(0x0804E894);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[1], rt.r[4] << 3);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0804E898);
            rt.r[3] = abi.read32(0x0804E89C);
            if (!abi.call(decls.func_0801B888, 0x0804E86D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x3, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 16);
            abi.setRegNz(&rt.r[2], rt.r[5] >> 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[5], 16));
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0804E8A0() callconv(.c) void {
    if (!abi.enter(0x0804E8A0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = abi.read32(0x0804E8E0);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
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
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[5], 0x40);
            continue :blk 3;
        },
        3 => {
            abi.fetches(19);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x50, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x56, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0804EDE4() callconv(.c) void {
    if (!abi.enter(0x0804EDE4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[2] = abi.read32(0x0804EE18);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read32(0x0804EE1C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[3] +% 0x34, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[5] = abi.read16(rt.r[3] +% 0x38);
            abi.setRegNz(&rt.r[1], rt.r[5] << 16);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x32, true);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[4] = abi.read16(rt.r[0] +% 0x38);
            rt.r[5] = abi.read16(rt.r[0] +% 0x34);
            continue :blk 3;
        },
        2 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x32, true);
            abi.setRegNz(&rt.r[0], 0x4);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[4] = abi.read16(rt.r[0] +% 0x34);
            rt.r[5] = abi.read16(rt.r[0] +% 0x38);
            continue :blk 3;
        },
        3 => {
            abi.fetches(13);
            rt.cpuSub(&rt.r[1], rt.r[4], rt.r[5], true);
            abi.write16(rt.r[0] +% 0x34, @truncate(rt.r[1]));
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read32(0x0804EE60);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[3] +% 0x36, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[4] = abi.read16(rt.r[3] +% 0x3A);
            abi.setRegNz(&rt.r[1], rt.r[4] << 16);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x32, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[5] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[5]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[2] = abi.read16(rt.r[0] +% 0x36);
            rt.r[3] = abi.read16(rt.r[0] +% 0x3A);
            rt.cpuSub(&rt.r[1], rt.r[2], rt.r[3], true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x32, true);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[4] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[4]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[5] = abi.read16(rt.r[0] +% 0x3A);
            rt.r[2] = abi.read16(rt.r[0] +% 0x36);
            rt.cpuSub(&rt.r[1], rt.r[5], rt.r[2], true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            abi.write16(rt.r[0] +% 0x36, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0804EF58() callconv(.c) void {
    if (!abi.enter(0x0804EF58)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[4] = abi.read32(0x0804EFC0);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
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
            abi.fetches(41);
            rt.r[0] = abi.read32(0x0804EFC4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[12] = rt.r[0];
            rt.r[2] = abi.read32(0x0804EFC8);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x5A, true);
            rt.r[3] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x7A, true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[5] = rt.r[12];
            abi.write16(rt.r[5] +% 0x38, @truncate(rt.r[0]));
            rt.r[4] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x47, true);
            abi.write16(rt.r[5] +% 0x3A, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0804EFCC);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0804EFD0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x33, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            if (!abi.call(func_0804EDE4, 0x0804EFB1)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804EFD4);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x0804EFB9)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0804F07C() callconv(.c) void {
    if (!abi.enter(0x0804F07C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x0804F0B8);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x26);
            rt.r[2] = abi.read16(rt.r[0] +% 0x1E);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x47, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0804F018, 0x0804F08F)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0804EE80, 0x0804F09D)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x33, true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[2], 0x96, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x47, true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0804F2C4() callconv(.c) void {
    if (!abi.enter(0x0804F2C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x4;
            rt.r[0] = abi.read32(0x0804F2F8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4A, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[5], 0x1);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (!rt.CPU_C) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[5], 0x2);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x24);
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0xE, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0xD, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804F450);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0804F43B)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        9 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x0804F2FC);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read32(0x0804F300);
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        10 => {
            abi.fetches(3);
            continue :blk 11;
        },
        11 => {
            abi.fetches(13);
            rt.r[2] = abi.read32(0x0804F454);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x24, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (rt.CPU_C) {
                continue :blk 5;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(3);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0804F2E4() callconv(.c) void {
    if (!abi.enter(0x0804F2E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0xD, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x0804F2FC);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read32(0x0804F300);
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        2 => {
            abi.fetches(3);
            continue :blk 3;
        },
        3 => {
            abi.fetches(13);
            rt.r[2] = abi.read32(0x0804F454);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x24, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (rt.CPU_C) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0xE, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            continue :blk 8;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804F450);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0804F43B)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x24);
            continue :blk 0;
        },
        else => unreachable,
    }
}

fn func_0804F754() callconv(.c) void {
    if (!abi.enter(0x0804F754)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x0804F7A4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x78);
            if (!abi.call(decls.func_0807B6AC, 0x0804F761)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 14);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[4], true);
            abi.setRegNz(&rt.r[1], 0xF);
            if (!abi.call(decls.func_0807B564, 0x0804F76F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[0], 0xF, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            continue :blk 5;
        },
        5 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x0804F7A8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[4] << 17);
            abi.setRegNz(&rt.r[2], 0xC0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 15);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011374, 0x0804F795)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 24);
            rt.cpuSub(null, rt.r[4], 0x7, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
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

fn func_0804F8AC() callconv(.c) void {
    if (!abi.enter(0x0804F8AC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x18;
            rt.r[1] = abi.read32(0x0804F8C4);
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[2], 0x18);
            if (!abi.call(decls.func_0807A8A0, 0x0804F8BB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[5], 0x0);
            if (!abi.call(decls.func_080113D0, 0x0804F8C1)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.r[0] = rt.r[13];
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[4], rt.r[5] << 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 24));
            rt.r[1] = rt.r[13];
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_080115C4, 0x0804F8D9)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.r[13] +%= 0x18;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[5], rt.r[4] >> 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 24));
            rt.r[1] = rt.r[13];
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0804FB38() callconv(.c) void {
    if (!abi.enter(0x0804FB38)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0804FB78);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[3] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x0804FB7C);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x28);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            rt.r[1] = abi.read32(0x0804FB80);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read32(0x0804FB84);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.r[0] = abi.read32(rt.r[2] +% 0x2C);
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
            abi.setRegNz(&rt.r[2], rt.r[0] << 8);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_08013550, 0x0804FB73)) return;
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

fn func_0804FBE4() callconv(.c) void {
    if (!abi.enter(0x0804FBE4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[1], 1));
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.write32(rt.r[4] +% 0x28, rt.r[0]);
            rt.r[1] = abi.read32(rt.r[4] +% 0x30);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            abi.write32(rt.r[4] +% 0x30, rt.r[1]);
            rt.r[7] = abi.read32(0x0804FC2C);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[5] = rt.sext16(abi.read16(rt.r[7] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xFF, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            rt.cpuSub(&rt.r[3], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x0804FC3C);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[0]);
            rt.r[1] = abi.read32(rt.r[4] +% 0x2C);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xFF, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[2], rt.r[1] << 8);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_08013550, 0x0804FC1B)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[7] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0804FC25)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0804FDCC() callconv(.c) void {
    if (!abi.enter(0x0804FDCC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x10, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x0804FDE4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x0804FE2C => continue :blk 3,
                0x0804FE64 => continue :blk 1,
                0x0804FE5C => continue :blk 4,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        3 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0804FE58);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x5);
            if (!abi.call(decls.func_0807B488, 0x0804FE3D)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0804FE70);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0804FE65)) return;
            continue :blk 1;
        },
        5 => {
            abi.fetches(15);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[0], rt.r[2] << 21);
            abi.setRegNz(&rt.r[1], 0x90);
            abi.setRegNz(&rt.r[1], rt.r[1] << 15);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 20);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[1], 0x48);
            if (!abi.call(decls.func_0804FC40, 0x0804FE57)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_080502EC() callconv(.c) void {
    if (!abi.enter(0x080502EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0805031C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x08050320);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x80);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08050324);
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08050340);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(decls.func_080502E0, 0x0805033B)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(3);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(func_0803A664, 0x0805030B)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08050328);
            continue :blk 12;
        },
        12 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08050319)) return;
            continue :blk 13;
        },
        13 => {
            abi.fetches(3);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_080502F8() callconv(.c) void {
    if (!abi.enter(0x080502F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08050324);
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08050340);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(decls.func_080502E0, 0x0805033B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(3);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(func_0803A664, 0x0805030B)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08050328);
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08050319)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(3);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_080503A8() callconv(.c) void {
    if (!abi.enter(0x080503A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x8;
            rt.r[1] = abi.read32(0x080503BC);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x8F, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x90);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0805040C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x080503CD)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(28);
            rt.r[3] = abi.read32(0x08050410);
            rt.r[2] = abi.read32(0x08050414);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x80);
            abi.setRegNz(&rt.r[4], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08050418);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 3);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[2], 0x1F);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            abi.setRegNz(&rt.r[2], 0x5);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            abi.setRegNz(&rt.r[2], 0xBA);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[2]);
            abi.setRegNz(&rt.r[2], 0x7);
            abi.setRegNz(&rt.r[3], 0x1);
            if (!abi.call(decls.func_08010C70, 0x08050401)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            if (!abi.call(decls.func_08011814, 0x08050405)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08050804() callconv(.c) void {
    if (!abi.enter(0x08050804)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            abi.write32(rt.r[13] +% 0xA0, rt.r[3]);
            abi.setRegNz(&rt.r[6], 0);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 8);
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            abi.setRegNz(&rt.r[6], rt.r[6] & rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08050620, 0x08050825)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[4] +% 0x1E);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x60, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 5;
        },
        5 => {
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

fn func_08050D78() callconv(.c) void {
    if (!abi.enter(0x08050D78)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x1E);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x08050DD4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2E, true);
            rt.r[0] = abi.read32(0x08050DD8);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            if (!abi.call(decls.func_08040310, 0x08050DB5)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x4, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x88, true);
            rt.r[4] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read32(0x08050DDC);
            rt.r[3] = abi.read32(0x08050DE0);
            abi.setRegNz(&rt.r[1], 0x8);
            if (!abi.call(decls.func_0801B888, 0x08050DC9)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08050DD0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08050D9D)) return;
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

fn func_08050E20() callconv(.c) void {
    if (!abi.enter(0x08050E20)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08050E60);
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
            abi.fetches(4);
            if (!abi.call(decls.func_0801833C, 0x08050E2F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08050E64);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x46, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08050E68);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08050E6C);
            if (!abi.call(decls.func_08018400, 0x08050E55)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08050E70);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08050E5D)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08051B30() callconv(.c) void {
    if (!abi.enter(0x08051B30)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuSub(&rt.r[0], rt.r[0], 0xA, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x28, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x08051B4C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08051BF4 => continue :blk 3,
                0x08051C0C => continue :blk 1,
                0x08051C04 => continue :blk 4,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08051C00);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08051BFD)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08051C18);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08051C0D)) return;
            continue :blk 1;
        },
        5 => {
            abi.fetches(3);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08051C40() callconv(.c) void {
    if (!abi.enter(0x08051C40)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = abi.read32(0x08051C80);
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
            abi.fetches(11);
            rt.r[0] = abi.read32(0x08051C84);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x2C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x2C, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0xDC, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08051C88);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08051C8C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08051C7D)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_080520BC() callconv(.c) void {
    if (!abi.enter(0x080520BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x0805211C);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x20);
            abi.setRegNz(&rt.r[3], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[3]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x08052120);
            rt.r[0] = abi.read32(0x0805211C);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[2] +% 0x20);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x6, true);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[2] +% 0x22);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0x22, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[1], 0x4C);
            if (!abi.call(decls.func_08051DE8, 0x080520DF)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08052124);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08052128);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08052117)) return;
            continue :blk 4;
        },
        8 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805213C() callconv(.c) void {
    if (!abi.enter(0x0805213C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08052168);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x1E);
            abi.setRegNz(&rt.r[3], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[3]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0805216C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x4, true);
            abi.write16(rt.r[1] +% 0x1E, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0804DA58, 0x08052175)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 1;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08040310, 0x0805217D)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            continue :blk 6;
        },
        8 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x80, true);
            rt.r[1] = abi.read32(0x08052198);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read32(0x0805219C);
            rt.r[3] = abi.read32(0x080521A0);
            abi.setRegNz(&rt.r[1], 0x8);
            if (!abi.call(decls.func_0801B888, 0x08052195)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0805237C() callconv(.c) void {
    if (!abi.enter(0x0805237C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(22);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 16);
            rt.r[0] = abi.read32(0x080523F0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[6] = abi.read32(0x080523F4);
            rt.r[3] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[3], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[6], true);
            rt.r[0] = abi.read32(0x080523F8);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
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
            abi.fetches(30);
            rt.r[0] = abi.read32(0x080523FC);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(0x08052400);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(0x08052404);
            abi.setRegNz(&rt.r[5], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[2], true);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[4], true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[1] << 3);
            rt.cpuSub(&rt.r[4], rt.r[4], rt.r[1], true);
            rt.r[0] = abi.read32(0x08052408);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[1], true);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x10, true);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[1], true);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 24);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08013330, 0x080523DD)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0805240C);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805253C() callconv(.c) void {
    if (!abi.enter(0x0805253C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[2] = abi.read32(0x080525AC);
            rt.r[0] = abi.read32(0x080525B0);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[5] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x30, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[3] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x34, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[4] = abi.read16(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(0x080525B4);
            abi.setRegNz(&rt.r[0], rt.r[3] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[1], 0x1, true);
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
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(30);
            rt.r[1] = abi.read32(0x080525B8);
            abi.setRegNz(&rt.r[2], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[4], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            abi.setRegNz(&rt.r[0], 0xB4);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[0] = abi.read32(0x080525BC);
            abi.setRegNz(&rt.r[1], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x080525C0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[4] = abi.read16(rt.r[2] +% 0x8);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[4], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read16(rt.r[2] +% 0xA);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08013550, 0x080525A5)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805266C() callconv(.c) void {
    if (!abi.enter(0x0805266C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.r[1] = abi.read32(0x08052694);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
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
            abi.fetches(6);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = abi.read16(rt.r[2] +% 0x2);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08052698);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read16(rt.r[0] +% 0x0);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[3]));
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080526B0);
            abi.setRegNz(&rt.r[1], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_080529D4() callconv(.c) void {
    if (!abi.enter(0x080529D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 16);
            rt.r[1] = abi.read32(0x08052A04);
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[2], 0x4);
            if (!abi.call(decls.func_0807A8A0, 0x080529EB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x08052A28);
            abi.setRegNz(&rt.r[1], rt.r[4] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.r[0] +%= rt.r[13];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0xA, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x08052A08);
            abi.setRegNz(&rt.r[1], rt.r[4] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.r[0] +%= rt.r[13];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0xA, @truncate(rt.r[0]));
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[5]));
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08052C3C() callconv(.c) void {
    if (!abi.enter(0x08052C3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x10;
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.r[0] = abi.read32(0x08052C90);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[13] +%= 0x10;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08052C94);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x40);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(13);
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[5]));
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[2]));
            abi.write16(rt.r[0] +% 0x6, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0xA, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0xC, @truncate(rt.r[3]));
            if (!abi.call(decls.func_0805DC84, 0x08052C87)) return;
            continue :blk 1;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08052CD0() callconv(.c) void {
    if (!abi.enter(0x08052CD0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[10] = rt.r[1];
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[1] = abi.read32(0x08052D44);
            rt.r[9] = rt.r[1];
            abi.setRegNz(&rt.r[1], 0x1F);
            rt.r[8] = rt.r[1];
            abi.setRegNz(&rt.r[1], 0xF8);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[12] = rt.r[1];
            abi.setRegNz(&rt.r[7], 0xF8);
            abi.setRegNz(&rt.r[7], rt.r[7] << 7);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(31);
            abi.setRegNz(&rt.r[4], rt.r[6] << 1);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.r[2] = rt.r[8];
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1F, true);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 1));
            rt.r[0] = rt.r[8];
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.r[1] = rt.r[12];
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.r[1] +%= rt.r[12];
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 1));
            rt.r[0] = rt.r[12];
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.r[3] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[7]);
            rt.r[4] +%= rt.r[9];
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x2, true);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x1, true);
            rt.cpuSub(null, rt.r[6], 0x3F, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = rt.r[9];
            rt.r[1] = rt.r[10];
            abi.setRegNz(&rt.r[2], 0x10);
            if (!abi.call(decls.func_080796C0, 0x08052D37)) return;
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

fn func_08053004() callconv(.c) void {
    if (!abi.enter(0x08053004)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.r[2] = abi.read32(0x08053044);
            rt.r[0] = abi.read32(0x08053048);
            abi.setRegNz(&rt.r[1], rt.r[3] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x12);
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
            abi.setRegNz(&rt.r[1], rt.r[3] << 29);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[0] = abi.read32(0x0805304C);
            abi.setRegNz(&rt.r[2], rt.r[3] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x18, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[2] = abi.read32(0x08053050);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 6);
            if (!abi.call(decls.func_0800FDA4, 0x0805303F)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08053368() callconv(.c) void {
    if (!abi.enter(0x08053368)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            rt.r[1] = abi.read32(0x080533EC);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0805329C, 0x0805337F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(32);
            rt.r[6] = abi.read32(0x080533F0);
            rt.r[3] = abi.read32(0x080533F4);
            abi.setRegNz(&rt.r[2], rt.r[4] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x6, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[5] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            rt.r[5] = abi.read32(0x080533F8);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            rt.r[3] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.r[6] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[7] = abi.read32(0x080533FC);
            abi.setRegNz(&rt.r[0], 0xB4);
            rt.cpuAdd(&rt.r[5], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[5], rt.r[5] *% rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[4], rt.r[0] << 1);
            continue :blk 2;
        },
        2 => {
            abi.fetches(24);
            abi.setRegNz(&rt.r[2], rt.r[3] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[5], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[7], true);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[2] +% 0x8, @truncate(rt.r[1]));
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[2] +% 0x4, @truncate(rt.r[1]));
            rt.r[1] = abi.read16(rt.r[0] +% 0x2);
            abi.write16(rt.r[2] +% 0xA, @truncate(rt.r[1]));
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            abi.write16(rt.r[2] +% 0x6, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[3], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
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

fn func_08055290() callconv(.c) void {
    if (!abi.enter(0x08055290)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.r[13] -%= 0x8;
            rt.r[8] = rt.r[1];
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.asrConst(rt.r[0], 16));
            rt.r[4] = rt.r[13];
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.r[1] = rt.r[13];
            if (!abi.call(decls.func_080135FC, 0x080552A9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(31);
            rt.r[4] = abi.read16(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[2], rt.r[4] << 22);
            abi.setRegNz(&rt.r[0], rt.r[2] >> 22);
            rt.r[1] = rt.r[8];
            rt.r[4] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(&rt.r[6], rt.r[4], rt.r[0], true);
            rt.r[3] = abi.read32(0x08055304);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[6], rt.r[6] & rt.r[0]);
            rt.r[3] = abi.read32(0x08055308);
            abi.setRegNz(&rt.r[1], rt.r[7] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[7], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x30, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[5] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xFC);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 22);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[0] = rt.r[8];
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x28, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x0805530C);
            abi.setRegNz(&rt.r[1], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[3]));
            rt.cpuSub(null, rt.r[7], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            abi.write32(rt.r[2] +% 0x0, rt.r[6]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08055D04() callconv(.c) void {
    if (!abi.enter(0x08055D04)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 16);
            rt.r[1] = abi.read32(0x08055D54);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x28, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            rt.cpuSub(null, rt.r[0], 0x90, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(22);
            rt.r[0] = abi.read32(0x08055D58);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[3] = abi.read32(0x08055D5C);
            abi.setRegNz(&rt.r[1], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[0], 0xB4);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.r[2] = abi.read16(rt.r[1] +% 0xA);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.write16(rt.r[1] +% 0xA, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805743C() callconv(.c) void {
    if (!abi.enter(0x0805743C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(28);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
            rt.r[1] = abi.read32(0x08057488);
            rt.r[8] = rt.r[1];
            rt.r[2] = abi.read32(0x0805748C);
            abi.setRegNz(&rt.r[1], 0x6C);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] *% rt.r[1]);
            rt.cpuAdd(&rt.r[5], rt.r[4], rt.r[2], true);
            rt.r[1] = abi.read16(rt.r[5] +% 0x2E);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[7], 0x30, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[8];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x3B);
            if (!abi.call(decls.func_080783BC, 0x08057497)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x3B);
            if (!abi.call(decls.func_080783BC, 0x08057477)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x3C);
            if (!abi.call(decls.func_080783BC, 0x0805749D)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x3C);
            if (!abi.call(decls.func_080783BC, 0x0805747D)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(13);
            rt.r[5] = abi.read16(rt.r[5] +% 0x2E);
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[8];
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(func_0803D830, 0x080574B3)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            if (!abi.call(func_0803D830, 0x08057485)) return;
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
            continue :blk 7;
        },
        else => unreachable,
    }
}

fn func_080574BC() callconv(.c) void {
    if (!abi.enter(0x080574BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(34);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[5], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.r[12] = rt.r[3];
            rt.r[1] = abi.read32(0x0805752C);
            abi.setRegNz(&rt.r[2], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(0x08057530);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[4] = abi.read32(rt.r[2] +% 0x0);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.r[2] = abi.read32(0x08057534);
            rt.r[1] = abi.read32(0x08057538);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[7] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[7] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[1], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[5] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[2], rt.r[3] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[3] = rt.r[12];
            rt.r[4] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[2], rt.r[3], rt.r[4], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            if (!abi.call(decls.func_08013550, 0x08057527)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08057A64() callconv(.c) void {
    if (!abi.enter(0x08057A64)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[4], rt.r[2] >> 16);
            rt.r[2] = abi.read32(0x08057A98);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[1], 0xB4);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1A);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08057A9C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013310, 0x08057AC1)) return;
            continue :blk 7;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08057AA0);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 8;
        },
        6 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(0x08057AD4);
            abi.setRegNz(&rt.r[0], 0x8);
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        9 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013248, 0x08057ACD)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08058328() callconv(.c) void {
    if (!abi.enter(0x08058328)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08013654, 0x0805833D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x1, true);
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
            abi.fetches(13);
            rt.r[2] = abi.read32(0x08058374);
            abi.setRegNz(&rt.r[0], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[1], 0xB4);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1A);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08058378);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0805837C);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0805884C() callconv(.c) void {
    if (!abi.enter(0x0805884C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[5], rt.r[2] >> 16);
            rt.r[3] = abi.read32(0x080588AC);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] ^ rt.r[2]);
            abi.setRegNz(&rt.r[2], 0xB4);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1A);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080588B0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013310, 0x0805889B)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x080588B4);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013248, 0x080588A7)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08058C80() callconv(.c) void {
    if (!abi.enter(0x08058C80)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(31);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[3] = abi.read32(0x08058CE0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[2], 0xB4);
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x08058CE4);
            abi.setRegNz(&rt.r[0], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x18);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
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
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(decls.func_08013310, 0x08058CC1)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[1], 0x18);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.r[1] = abi.read32(0x08058CE8);
            abi.setRegNz(&rt.r[2], rt.r[5] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x14, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            if (!abi.call(decls.func_08013678, 0x08058CD9)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08058FD0() callconv(.c) void {
    if (!abi.enter(0x08058FD0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(39);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[0] = abi.read32(0x08059058);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.r[0] = abi.read32(0x0805905C);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08059060);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.setRegNz(&rt.r[2], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[5], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[3] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 16);
            rt.r[4] = abi.read32(0x08059064);
            abi.setRegNz(&rt.r[0], 0x6C);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[6] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(21);
            rt.r[0] = abi.read32(0x08059068);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[4], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2E);
            abi.setRegNz(&rt.r[3], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x44, true);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[1], true);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x58, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.r[3] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[7] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08013330, 0x08059041)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x10);
            if (!abi.call(func_0805743C, 0x0805904F)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805927C() callconv(.c) void {
    if (!abi.enter(0x0805927C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(36);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[4] = abi.read32(0x080592FC);
            rt.r[2] = abi.read32(0x08059300);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x28, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[6] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[1], rt.r[6] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x30, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x34, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 18);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(26);
            rt.r[1] = abi.read32(0x08059304);
            abi.setRegNz(&rt.r[3], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[2], true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 2);
            abi.setRegNz(&rt.r[0], 0xB4);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.r[0] = abi.read32(0x08059308);
            abi.setRegNz(&rt.r[1], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x56, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[3] +% 0x8);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[1], 0xA);
            rt.r[3] = rt.sext16(abi.read16(rt.r[3] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(func_080574BC, 0x080592F7)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], 0, rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            continue :blk 1;
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

fn func_08059D30() callconv(.c) void {
    if (!abi.enter(0x08059D30)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(22);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 16);
            rt.r[0] = abi.read32(0x08059D98);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.r[0] = abi.read32(0x08059D9C);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.r[2] = abi.read32(0x08059DA0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[1], 0xB4);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[6], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[6] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x18);
            rt.r[1] = rt.sext16(abi.read16(rt.r[6] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(func_08058C80, 0x08059D6D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(19);
            rt.r[1] = abi.read32(0x08059DA4);
            abi.setRegNz(&rt.r[0], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x18);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            rt.r[1] = abi.read32(0x08059DA8);
            abi.setRegNz(&rt.r[2], rt.r[5] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x14, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            if (!abi.call(decls.func_08013678, 0x08059D8F)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08059DAC);
            abi.write16(rt.r[6] +% 0x18, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08059E6C() callconv(.c) void {
    if (!abi.enter(0x08059E6C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[7] = abi.read32(0x08059EA8);
            rt.r[0] = abi.read32(0x08059EAC);
            rt.r[12] = rt.r[0];
            rt.r[6] = abi.read32(0x08059EB0);
            rt.r[5] = abi.read32(0x08059EB4);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[3], 0x7);
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x1, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[7] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = rt.r[12];
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0805A368() callconv(.c) void {
    if (!abi.enter(0x0805A368)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[0] = abi.read32(0x0805A3CC);
            rt.r[5] = abi.read16(rt.r[0] +% 0x0);
            rt.r[6] = abi.read32(0x0805A3D0);
            rt.r[1] = abi.read32(0x0805A3D4);
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[6] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0805A3E8, 0x0805A3BF)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(26);
            rt.r[3] = abi.read32(0x0805A3D8);
            rt.r[4] = abi.read32(0x0805A3DC);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.r[0] = abi.read32(0x0805A3E0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read32(0x0805A3E4);
            abi.setRegNz(&rt.r[1], rt.r[5] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[5] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[1]));
            if (!abi.call(func_0803D830, 0x0805A3AF)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_0805A3E8, 0x0805A3C5)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
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

fn func_0805A4A8() callconv(.c) void {
    if (!abi.enter(0x0805A4A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0805A4CC);
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
            if (!abi.call(func_0805A4EC, 0x0805A4D5)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0805E6A8, 0x0805A4D9)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(func_0805A4EC, 0x0805A4C3)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_080525C4, 0x0805A4E3)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0805E7A0, 0x0805A4DD)) return;
            continue :blk 5;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0805E6A8, 0x0805A4C7)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_080525C4, 0x0805A4E9)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0805E7A0, 0x0805A4CB)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        11 => {
            abi.fetches(3);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0805A4EC() callconv(.c) void {
    if (!abi.enter(0x0805A4EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0805A50C);
            rt.r[4] = abi.read16(rt.r[0] +% 0xA);
            rt.r[1] = abi.read32(0x0805A510);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x0805A505)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0805A544);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_0805DE84, 0x0805A527)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0805A548);
            rt.r[4] = abi.read16(rt.r[0] +% 0x1A);
            rt.r[1] = abi.read32(0x0805A544);
            rt.r[0] = abi.read16(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(7);
            rt.r[0] = abi.read16(rt.r[1] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x0805A53D)) return;
            continue :blk 9;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        8 => {
            abi.fetches(3);
            continue :blk 4;
        },
        9 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 12;
        },
        10 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0805A564);
            rt.r[1] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            if (!abi.call(decls.func_0805E0AC, 0x0805A55F)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        12 => {
            abi.fetches(3);
            continue :blk 13;
        },
        13 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0805A568() callconv(.c) void {
    if (!abi.enter(0x0805A568)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x8;
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013310, 0x0805A583)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080135C8, 0x0805A591)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(rt.r[13] +% 0x0);
            rt.r[2] = abi.read32(rt.r[13] +% 0x4);
            abi.setRegNz(&rt.r[3], 0x3);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[5]);
            abi.setRegNz(&rt.r[3], rt.r[3] << 10);
            rt.r[0] = abi.read32(0x0805A5B0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013598, 0x0805A5A9)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805A5C4() callconv(.c) void {
    if (!abi.enter(0x0805A5C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(21);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.r[2] = abi.read32(0x0805A610);
            rt.r[4] = abi.read32(0x0805A614);
            abi.setRegNz(&rt.r[0], 0x6C);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1A, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
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
            abi.fetches(15);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xE, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0805A618);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.cpuSub(null, rt.r[0], 0xFE, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0805A61C, 0x0805A60B)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805A760() callconv(.c) void {
    if (!abi.enter(0x0805A760)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x0805A79C);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], 0x10);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[1], 0xD0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x50, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0805A7A0, 0x0805A773)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0805AAF4, 0x0805A78F)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0805B008() callconv(.c) void {
    if (!abi.enter(0x0805B008)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(21);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 16);
            rt.r[2] = abi.read32(0x0805B05C);
            abi.setRegNz(&rt.r[0], rt.r[5] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[1], 0xB4);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[6]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], 0x18);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_080588B8, 0x0805B055)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(decls.func_08013310, 0x0805B035)) return;
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
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[1], 0x18);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.r[1] = abi.read32(0x0805B060);
            abi.setRegNz(&rt.r[2], rt.r[6] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            if (!abi.call(decls.func_08013678, 0x0805B04D)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805B1A0() callconv(.c) void {
    if (!abi.enter(0x0805B1A0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.r[3] = abi.read32(0x0805B200);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[3], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x18);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xC, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[5] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[5], 0xFF, true);
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
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0805B204);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1E, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(21);
            rt.r[3] = abi.read32(0x0805B208);
            rt.r[2] = abi.read32(0x0805B20C);
            rt.r[0] = abi.read32(0x0805B210);
            abi.setRegNz(&rt.r[1], rt.r[4] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[6] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[6] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0807B454, 0x0805B1F9)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805B2F8() callconv(.c) void {
    if (!abi.enter(0x0805B2F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(26);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 16);
            rt.r[2] = abi.read32(0x0805B37C);
            rt.r[3] = abi.read32(0x0805B380);
            abi.setRegNz(&rt.r[0], rt.r[5] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[1], 0xB4);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[6]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], 0x18);
            rt.r[3] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2C, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
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
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_08013310, 0x0805B339)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(20);
            rt.r[2] = abi.read32(0x0805B37C);
            rt.r[3] = abi.read32(0x0805B380);
            abi.setRegNz(&rt.r[0], rt.r[5] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[1], 0xB4);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[6]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[3], 0x18);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2C, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            continue :blk 1;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[1], 0x18);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.r[1] = abi.read32(0x0805B384);
            abi.setRegNz(&rt.r[2], rt.r[6] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x10, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            if (!abi.call(decls.func_08013678, 0x0805B351)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0805B388() callconv(.c) void {
    if (!abi.enter(0x0805B388)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.r[3] = abi.read32(0x0805B3E8);
            abi.setRegNz(&rt.r[0], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[3], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1A, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[5] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[5], 0xFF, true);
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
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0805B3EC);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xC, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(21);
            rt.r[3] = abi.read32(0x0805B3F0);
            rt.r[2] = abi.read32(0x0805B3F4);
            rt.r[0] = abi.read32(0x0805B3F8);
            abi.setRegNz(&rt.r[1], rt.r[4] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[6] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[6] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0807B454, 0x0805B3E1)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805B3FC() callconv(.c) void {
    if (!abi.enter(0x0805B3FC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[7], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.r[2] = abi.read32(0x0805B480);
            abi.setRegNz(&rt.r[0], rt.r[6] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.setRegNz(&rt.r[1], 0xB4);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], 0x18);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
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
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(decls.func_08013310, 0x0805B42D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(20);
            rt.r[1] = abi.read32(0x0805B484);
            abi.setRegNz(&rt.r[0], rt.r[5] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x16);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x16, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x0805B488);
            rt.r[2] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.r[2] = abi.read8(rt.r[4] +% 0x1);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(15);
            rt.r[0] = abi.read32(0x0805B48C);
            abi.setRegNz(&rt.r[1], rt.r[5] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xA, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0805B490);
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read8(rt.r[4] +% 0x1);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_08057E7C, 0x0805B479)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805B9CC() callconv(.c) void {
    if (!abi.enter(0x0805B9CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[5] = abi.read32(0x0805BA00);
            rt.r[6] = abi.read32(0x0805BA04);
            rt.r[4] = abi.read32(0x0805BA08);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], 0x7);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xE, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x2, true);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x1, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0805BA60() callconv(.c) void {
    if (!abi.enter(0x0805BA60)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0805BA78);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(0x0805BA7C);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x8);
            continue :blk 7;
        },
        4 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            continue :blk 7;
        },
        5 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(0x0805BA9C);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x8, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x30);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        7 => {
            abi.fetches(3);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 12;
        },
        9 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            continue :blk 12;
        },
        10 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0805BABC);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] ^ rt.r[2]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 11;
        },
        11 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        12 => {
            abi.fetches(3);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0805BDA4() callconv(.c) void {
    if (!abi.enter(0x0805BDA4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.cpuSub(null, rt.r[1], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[5], 0x50);
            continue :blk 3;
        },
        2 => {
            abi.fetches(20);
            abi.setRegNz(&rt.r[1], rt.r[4] << 13);
            abi.setRegNz(&rt.r[2], 0xA0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[4] << 8);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x50, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x0805BDD8);
            rt.r[2] = abi.read32(0x0805BDDC);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xA2);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            if (!abi.call(decls.func_080796C0, 0x0805BDD7)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(21);
            rt.r[2] = abi.read32(0x0805BE08);
            abi.setRegNz(&rt.r[1], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.r[2] = abi.read32(0x0805BE0C);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.r[0] = abi.read32(0x0805BE10);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[5]));
            popRegsSeq(&.{ 4, 5 });
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

fn func_0805BEC8() callconv(.c) void {
    if (!abi.enter(0x0805BEC8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[5], 0x80);
            continue :blk 3;
        },
        2 => {
            abi.fetches(20);
            abi.setRegNz(&rt.r[1], rt.r[4] << 13);
            abi.setRegNz(&rt.r[2], 0xA0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[4] << 8);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xA0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x0805BEFC);
            rt.r[2] = abi.read32(0x0805BF00);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0xB2);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            if (!abi.call(decls.func_080796C0, 0x0805BEFB)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x0805BF18);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            popRegsSeq(&.{ 4, 5 });
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

fn func_0805C0DC() callconv(.c) void {
    if (!abi.enter(0x0805C0DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(34);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[6], rt.r[3] >> 16);
            rt.r[4] = abi.read32(0x0805C128);
            abi.setRegNz(&rt.r[3], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 3);
            rt.cpuAdd(&rt.r[7], rt.r[3], rt.r[4], true);
            abi.write16(rt.r[7] +% 0x0, @truncate(rt.r[6]));
            abi.setRegNz(&rt.r[0], rt.r[6] << 21);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[12] = rt.r[0];
            rt.r[4] = abi.read32(0x0805C12C);
            abi.setRegNz(&rt.r[3], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            rt.r[5] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.write16(rt.r[7] +% 0x0, @truncate(rt.r[5]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0805C130);
            rt.r[1] +%= rt.r[12];
            abi.setRegNz(&rt.r[2], rt.r[5] >> 2);
            if (!abi.call(decls.func_080796C0, 0x0805C127)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[5] >> 5);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
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

fn func_0805C148() callconv(.c) void {
    if (!abi.enter(0x0805C148)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[4] = abi.read32(rt.r[13] +% 0x14);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[2], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[5], rt.r[4] >> 16);
            rt.r[0] = abi.read32(0x0805C1B8);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 15);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(25);
            rt.r[1] = abi.read32(0x0805C1BC);
            abi.setRegNz(&rt.r[0], 0x58);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[7]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            abi.setRegNz(&rt.r[0], rt.r[5] << 21);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 16);
            rt.r[2] = abi.read32(0x0805C1C0);
            abi.setRegNz(&rt.r[1], rt.r[6] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[4] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.r[4] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0805C1C4);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[1], true);
            abi.setRegNz(&rt.r[2], rt.r[4] >> 2);
            if (!abi.call(decls.func_080796C0, 0x0805C1A7)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] >> 5);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805C1C8() callconv(.c) void {
    if (!abi.enter(0x0805C1C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(34);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[5], rt.r[3] >> 16);
            rt.r[4] = abi.read32(0x0805C224);
            abi.setRegNz(&rt.r[3], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 4);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[4], true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[5]));
            abi.setRegNz(&rt.r[0], rt.r[5] << 21);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 16);
            rt.r[4] = abi.read32(0x0805C228);
            abi.setRegNz(&rt.r[3], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[6] >> 5);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0805C22C);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[1], true);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 2);
            if (!abi.call(decls.func_080796C0, 0x0805C213)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805C230() callconv(.c) void {
    if (!abi.enter(0x0805C230)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(22);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 16);
            rt.r[2] = abi.read32(0x0805C278);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[4]));
            abi.write16(rt.r[2] +% 0x24, @truncate(rt.r[4]));
            rt.r[5] = abi.read32(0x0805C27C);
            abi.setRegNz(&rt.r[1], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[5], true);
            rt.r[3] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[2] << 21);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[6] >> 5);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x0805C280);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[2], rt.r[3] >> 2);
            if (!abi.call(decls.func_080796C0, 0x0805C269)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0805C4E4() callconv(.c) void {
    if (!abi.enter(0x0805C4E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(27);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
            rt.r[0] = abi.read32(0x0805C538);
            abi.setRegNz(&rt.r[5], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0805C53C);
            rt.r[0] = abi.read32(0x0805C540);
            abi.setRegNz(&rt.r[1], rt.r[4] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[7] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[7] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0805C544);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[6], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(3);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0805D52E() callconv(.c) void {
    if (!abi.enter(0x0805D52E)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[3] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], rt.r[2], true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.r[2] = rt.r[8];
            rt.cpuAdd(&rt.r[7], rt.r[0], rt.r[2], true);
            rt.r[3] = rt.r[9];
            rt.cpuAdd(&rt.r[6], rt.r[7], rt.r[3], true);
            rt.r[3] = abi.read16(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[5], rt.r[0], rt.r[2], true);
            rt.r[0] = rt.r[9];
            rt.cpuAdd(&rt.r[4], rt.r[5], rt.r[0], true);
            rt.r[2] = abi.read16(rt.r[4] +% 0x0);
            rt.r[12] = rt.r[1];
            rt.cpuSub(null, rt.r[3], 0xFF, true);
            continue :blk 0;
        },
        5 => {
            abi.fetches(7);
            rt.r[1] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[2], 0x3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read16(rt.r[4] +% 0x0);
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], rt.r[2], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 10;
        },
        8 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.r[10] = rt.r[2];
            continue :blk 4;
        },
        10 => {
            abi.fetches(11);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[3]));
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[2]));
            rt.r[2] = abi.read32(0x0805D57C);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[2], true);
            rt.r[3] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[2], true);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0805DBE8() callconv(.c) void {
    if (!abi.enter(0x0805DBE8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            rt.cpuSub(null, rt.r[1], 0x15, true);
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0805DC2C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(20);
            rt.r[0] = abi.read32(0x0805DC30);
            abi.setRegNz(&rt.r[3], rt.r[5] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[4] = abi.read32(0x0805DC34);
            rt.r[2] = abi.read32(0x0805DC38);
            rt.r[0] = abi.read32(0x0805DC3C);
            abi.setRegNz(&rt.r[1], rt.r[5] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xA, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[3] +% 0x0, rt.r[0]);
            continue :blk 6;
        },
        5 => {
            abi.fetches(25);
            rt.r[0] = abi.read32(0x0805DC74);
            abi.setRegNz(&rt.r[4], rt.r[6] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.r[5] = abi.read32(0x0805DC78);
            rt.r[2] = abi.read32(0x0805DC7C);
            rt.r[3] = abi.read32(0x0805DC80);
            abi.setRegNz(&rt.r[1], rt.r[6] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xC, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[3] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[4] +% 0x0, rt.r[0]);
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

fn func_0805E740() callconv(.c) void {
    if (!abi.enter(0x0805E740)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(33);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[2] = abi.read32(0x0805E794);
            abi.setRegNz(&rt.r[0], rt.r[5] << 3);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0805E798);
            abi.setRegNz(&rt.r[2], rt.r[5] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(0x0805E79C);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_0805E558, 0x0805E78D)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
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

fn func_0805EFC0() callconv(.c) void {
    if (!abi.enter(0x0805EFC0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x0805EFCC);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[4] = abi.read32(0x0805EFD0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[5], 0x2);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[5]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.r[4] = abi.read16(rt.r[3] +% 0x2);
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4, true);
            continue :blk 1;
        },
        6 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0805EFFC);
            abi.write16(rt.r[3] +% 0x2, @truncate(rt.r[0]));
            continue :blk 7;
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

fn func_0805F000() callconv(.c) void {
    if (!abi.enter(0x0805F000)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x0805F044);
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
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(10);
            rt.r[6] = abi.read32(0x0805F048);
            rt.r[0] = abi.read32(0x0805F04C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[2], rt.r[3], rt.r[2], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x15);
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_0805F050() callconv(.c) void {
    if (!abi.enter(0x0805F050)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = abi.read32(0x0805F098);
            rt.r[3] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x40, true);
            rt.cpuSub(null, rt.r[3], rt.r[4], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(10);
            rt.r[7] = abi.read32(0x0805F09C);
            rt.r[0] = abi.read32(0x0805F0A0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[3], rt.r[4], rt.r[3], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(12);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x14);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xC, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_0805F0A4() callconv(.c) void {
    if (!abi.enter(0x0805F0A4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x0805F0DC);
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
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0805F0E0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[2], rt.r[3], rt.r[2], true);
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
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_0805F0E4() callconv(.c) void {
    if (!abi.enter(0x0805F0E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[2] = abi.read32(0x0805F144);
            rt.r[0] = abi.read32(0x0805F148);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x28, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[12] = rt.r[0];
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[1] = rt.r[12];
            abi.setRegNz(&rt.r[1], rt.armAsr(rt.r[1], rt.r[4] & 0xFF));
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuAdd(&rt.r[5], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], rt.r[4] << 6);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x40, true);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0805F14C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 7);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[2], rt.r[3], rt.r[2], true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[7], true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x1, true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 3;
        },
        else => unreachable,
    }
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08035E74, .{ .name = "func_08035E74", .linkage = .strong });
        @export(&func_08035EE4, .{ .name = "func_08035EE4", .linkage = .strong });
        @export(&func_08036274, .{ .name = "func_08036274", .linkage = .strong });
        @export(&func_0803649C, .{ .name = "func_0803649C", .linkage = .strong });
        @export(&func_08036520, .{ .name = "func_08036520", .linkage = .strong });
        @export(&func_08036750, .{ .name = "func_08036750", .linkage = .strong });
        @export(&func_080367BC, .{ .name = "func_080367BC", .linkage = .strong });
        @export(&func_080367F0, .{ .name = "func_080367F0", .linkage = .strong });
        @export(&func_080368D8, .{ .name = "func_080368D8", .linkage = .strong });
        @export(&func_08036B44, .{ .name = "func_08036B44", .linkage = .strong });
        @export(&func_080371AC, .{ .name = "func_080371AC", .linkage = .strong });
        @export(&func_08037B5C, .{ .name = "func_08037B5C", .linkage = .strong });
        @export(&func_080382A8, .{ .name = "func_080382A8", .linkage = .strong });
        @export(&func_08038300, .{ .name = "func_08038300", .linkage = .strong });
        @export(&func_080383A0, .{ .name = "func_080383A0", .linkage = .strong });
        @export(&func_08038430, .{ .name = "func_08038430", .linkage = .strong });
        @export(&func_08038508, .{ .name = "func_08038508", .linkage = .strong });
        @export(&func_08038564, .{ .name = "func_08038564", .linkage = .strong });
        @export(&func_08038DB8, .{ .name = "func_08038DB8", .linkage = .strong });
        @export(&func_08038FC8, .{ .name = "func_08038FC8", .linkage = .strong });
        @export(&func_0803942C, .{ .name = "func_0803942C", .linkage = .strong });
        @export(&func_080397B8, .{ .name = "func_080397B8", .linkage = .strong });
        @export(&func_08039F00, .{ .name = "func_08039F00", .linkage = .strong });
        @export(&func_0803A0A4, .{ .name = "func_0803A0A4", .linkage = .strong });
        @export(&func_0803A0E8, .{ .name = "func_0803A0E8", .linkage = .strong });
        @export(&func_0803A270, .{ .name = "func_0803A270", .linkage = .strong });
        @export(&func_0803A664, .{ .name = "func_0803A664", .linkage = .strong });
        @export(&func_0803A948, .{ .name = "func_0803A948", .linkage = .strong });
        @export(&func_0803B032, .{ .name = "func_0803B032", .linkage = .strong });
        @export(&func_0803B0C0, .{ .name = "func_0803B0C0", .linkage = .strong });
        @export(&func_0803B124, .{ .name = "func_0803B124", .linkage = .strong });
        @export(&func_0803B194, .{ .name = "func_0803B194", .linkage = .strong });
        @export(&func_0803B41C, .{ .name = "func_0803B41C", .linkage = .strong });
        @export(&func_0803B464, .{ .name = "func_0803B464", .linkage = .strong });
        @export(&func_0803B4F8, .{ .name = "func_0803B4F8", .linkage = .strong });
        @export(&func_0803B5E4, .{ .name = "func_0803B5E4", .linkage = .strong });
        @export(&func_0803B64C, .{ .name = "func_0803B64C", .linkage = .strong });
        @export(&func_0803B9DC, .{ .name = "func_0803B9DC", .linkage = .strong });
        @export(&func_0803BA54, .{ .name = "func_0803BA54", .linkage = .strong });
        @export(&func_0803BD74, .{ .name = "func_0803BD74", .linkage = .strong });
        @export(&func_0803C710, .{ .name = "func_0803C710", .linkage = .strong });
        @export(&func_0803C82C, .{ .name = "func_0803C82C", .linkage = .strong });
        @export(&func_0803C894, .{ .name = "func_0803C894", .linkage = .strong });
        @export(&func_0803D248, .{ .name = "func_0803D248", .linkage = .strong });
        @export(&func_0803D398, .{ .name = "func_0803D398", .linkage = .strong });
        @export(&func_0803D47C, .{ .name = "func_0803D47C", .linkage = .strong });
        @export(&func_0803D628, .{ .name = "func_0803D628", .linkage = .strong });
        @export(&func_0803D830, .{ .name = "func_0803D830", .linkage = .strong });
        @export(&func_0803D8C8, .{ .name = "func_0803D8C8", .linkage = .strong });
        @export(&func_0803DCBC, .{ .name = "func_0803DCBC", .linkage = .strong });
        @export(&func_0803DD24, .{ .name = "func_0803DD24", .linkage = .strong });
        @export(&func_0803E074, .{ .name = "func_0803E074", .linkage = .strong });
        @export(&func_0803E244, .{ .name = "func_0803E244", .linkage = .strong });
        @export(&func_0803E280, .{ .name = "func_0803E280", .linkage = .strong });
        @export(&func_0803E2F0, .{ .name = "func_0803E2F0", .linkage = .strong });
        @export(&func_0803E334, .{ .name = "func_0803E334", .linkage = .strong });
        @export(&func_0803E4A0, .{ .name = "func_0803E4A0", .linkage = .strong });
        @export(&func_0803E990, .{ .name = "func_0803E990", .linkage = .strong });
        @export(&func_0803E9C0, .{ .name = "func_0803E9C0", .linkage = .strong });
        @export(&func_0803E9F0, .{ .name = "func_0803E9F0", .linkage = .strong });
        @export(&func_0803EA20, .{ .name = "func_0803EA20", .linkage = .strong });
        @export(&func_0803EA94, .{ .name = "func_0803EA94", .linkage = .strong });
        @export(&func_0803EACC, .{ .name = "func_0803EACC", .linkage = .strong });
        @export(&func_0803EB30, .{ .name = "func_0803EB30", .linkage = .strong });
        @export(&func_0803EB68, .{ .name = "func_0803EB68", .linkage = .strong });
        @export(&func_0803EBA0, .{ .name = "func_0803EBA0", .linkage = .strong });
        @export(&func_0803EBD8, .{ .name = "func_0803EBD8", .linkage = .strong });
        @export(&func_0803EDE0, .{ .name = "func_0803EDE0", .linkage = .strong });
        @export(&func_0803EE5C, .{ .name = "func_0803EE5C", .linkage = .strong });
        @export(&func_0803F158, .{ .name = "func_0803F158", .linkage = .strong });
        @export(&func_0803F1DC, .{ .name = "func_0803F1DC", .linkage = .strong });
        @export(&func_0803F360, .{ .name = "func_0803F360", .linkage = .strong });
        @export(&func_0803FD1C, .{ .name = "func_0803FD1C", .linkage = .strong });
        @export(&func_08040008, .{ .name = "func_08040008", .linkage = .strong });
        @export(&func_080400FC, .{ .name = "func_080400FC", .linkage = .strong });
        @export(&func_08040100, .{ .name = "func_08040100", .linkage = .strong });
        @export(&func_08040190, .{ .name = "func_08040190", .linkage = .strong });
        @export(&func_080408F8, .{ .name = "func_080408F8", .linkage = .strong });
        @export(&func_08040988, .{ .name = "func_08040988", .linkage = .strong });
        @export(&func_08040A00, .{ .name = "func_08040A00", .linkage = .strong });
        @export(&func_08040A06, .{ .name = "func_08040A06", .linkage = .strong });
        @export(&func_080419C4, .{ .name = "func_080419C4", .linkage = .strong });
        @export(&func_08041C70, .{ .name = "func_08041C70", .linkage = .strong });
        @export(&func_08042048, .{ .name = "func_08042048", .linkage = .strong });
        @export(&func_0804214C, .{ .name = "func_0804214C", .linkage = .strong });
        @export(&func_0804219C, .{ .name = "func_0804219C", .linkage = .strong });
        @export(&func_0804231C, .{ .name = "func_0804231C", .linkage = .strong });
        @export(&func_08042374, .{ .name = "func_08042374", .linkage = .strong });
        @export(&func_080423E8, .{ .name = "func_080423E8", .linkage = .strong });
        @export(&func_08042464, .{ .name = "func_08042464", .linkage = .strong });
        @export(&func_080424D0, .{ .name = "func_080424D0", .linkage = .strong });
        @export(&func_080427D0, .{ .name = "func_080427D0", .linkage = .strong });
        @export(&func_08042A80, .{ .name = "func_08042A80", .linkage = .strong });
        @export(&func_08042E8C, .{ .name = "func_08042E8C", .linkage = .strong });
        @export(&func_08043780, .{ .name = "func_08043780", .linkage = .strong });
        @export(&func_08043CC4, .{ .name = "func_08043CC4", .linkage = .strong });
        @export(&func_08043E28, .{ .name = "func_08043E28", .linkage = .strong });
        @export(&func_08044AE4, .{ .name = "func_08044AE4", .linkage = .strong });
        @export(&func_08044B98, .{ .name = "func_08044B98", .linkage = .strong });
        @export(&func_08044EE8, .{ .name = "func_08044EE8", .linkage = .strong });
        @export(&func_080459C4, .{ .name = "func_080459C4", .linkage = .strong });
        @export(&func_08045A28, .{ .name = "func_08045A28", .linkage = .strong });
        @export(&func_080465C8, .{ .name = "func_080465C8", .linkage = .strong });
        @export(&func_080468CC, .{ .name = "func_080468CC", .linkage = .strong });
        @export(&func_08046FFC, .{ .name = "func_08046FFC", .linkage = .strong });
        @export(&func_0804711E, .{ .name = "func_0804711E", .linkage = .strong });
        @export(&func_08047588, .{ .name = "func_08047588", .linkage = .strong });
        @export(&func_08047716, .{ .name = "func_08047716", .linkage = .strong });
        @export(&func_08047838, .{ .name = "func_08047838", .linkage = .strong });
        @export(&func_08047F74, .{ .name = "func_08047F74", .linkage = .strong });
        @export(&func_08048084, .{ .name = "func_08048084", .linkage = .strong });
        @export(&func_08048980, .{ .name = "func_08048980", .linkage = .strong });
        @export(&func_08048B7C, .{ .name = "func_08048B7C", .linkage = .strong });
        @export(&func_08048BE0, .{ .name = "func_08048BE0", .linkage = .strong });
        @export(&func_08048E94, .{ .name = "func_08048E94", .linkage = .strong });
        @export(&func_08048EFC, .{ .name = "func_08048EFC", .linkage = .strong });
        @export(&func_0804912C, .{ .name = "func_0804912C", .linkage = .strong });
        @export(&func_08049500, .{ .name = "func_08049500", .linkage = .strong });
        @export(&func_080497B8, .{ .name = "func_080497B8", .linkage = .strong });
        @export(&func_08049A50, .{ .name = "func_08049A50", .linkage = .strong });
        @export(&func_08049B3C, .{ .name = "func_08049B3C", .linkage = .strong });
        @export(&func_08049E20, .{ .name = "func_08049E20", .linkage = .strong });
        @export(&func_08049E70, .{ .name = "func_08049E70", .linkage = .strong });
        @export(&func_0804A400, .{ .name = "func_0804A400", .linkage = .strong });
        @export(&func_0804A44C, .{ .name = "func_0804A44C", .linkage = .strong });
        @export(&func_0804B3C0, .{ .name = "func_0804B3C0", .linkage = .strong });
        @export(&func_0804B460, .{ .name = "func_0804B460", .linkage = .strong });
        @export(&func_0804BCAC, .{ .name = "func_0804BCAC", .linkage = .strong });
        @export(&func_0804BD24, .{ .name = "func_0804BD24", .linkage = .strong });
        @export(&func_0804D1A8, .{ .name = "func_0804D1A8", .linkage = .strong });
        @export(&func_0804D998, .{ .name = "func_0804D998", .linkage = .strong });
        @export(&func_0804DAE0, .{ .name = "func_0804DAE0", .linkage = .strong });
        @export(&func_0804DB60, .{ .name = "func_0804DB60", .linkage = .strong });
        @export(&func_0804E23C, .{ .name = "func_0804E23C", .linkage = .strong });
        @export(&func_0804E288, .{ .name = "func_0804E288", .linkage = .strong });
        @export(&func_0804E310, .{ .name = "func_0804E310", .linkage = .strong });
        @export(&func_0804E520, .{ .name = "func_0804E520", .linkage = .strong });
        @export(&func_0804E820, .{ .name = "func_0804E820", .linkage = .strong });
        @export(&func_0804E8A0, .{ .name = "func_0804E8A0", .linkage = .strong });
        @export(&func_0804EDE4, .{ .name = "func_0804EDE4", .linkage = .strong });
        @export(&func_0804EF58, .{ .name = "func_0804EF58", .linkage = .strong });
        @export(&func_0804F07C, .{ .name = "func_0804F07C", .linkage = .strong });
        @export(&func_0804F2C4, .{ .name = "func_0804F2C4", .linkage = .strong });
        @export(&func_0804F2E4, .{ .name = "func_0804F2E4", .linkage = .strong });
        @export(&func_0804F754, .{ .name = "func_0804F754", .linkage = .strong });
        @export(&func_0804F8AC, .{ .name = "func_0804F8AC", .linkage = .strong });
        @export(&func_0804FB38, .{ .name = "func_0804FB38", .linkage = .strong });
        @export(&func_0804FBE4, .{ .name = "func_0804FBE4", .linkage = .strong });
        @export(&func_0804FDCC, .{ .name = "func_0804FDCC", .linkage = .strong });
        @export(&func_080502EC, .{ .name = "func_080502EC", .linkage = .strong });
        @export(&func_080502F8, .{ .name = "func_080502F8", .linkage = .strong });
        @export(&func_080503A8, .{ .name = "func_080503A8", .linkage = .strong });
        @export(&func_08050804, .{ .name = "func_08050804", .linkage = .strong });
        @export(&func_08050D78, .{ .name = "func_08050D78", .linkage = .strong });
        @export(&func_08050E20, .{ .name = "func_08050E20", .linkage = .strong });
        @export(&func_08051B30, .{ .name = "func_08051B30", .linkage = .strong });
        @export(&func_08051C40, .{ .name = "func_08051C40", .linkage = .strong });
        @export(&func_080520BC, .{ .name = "func_080520BC", .linkage = .strong });
        @export(&func_0805213C, .{ .name = "func_0805213C", .linkage = .strong });
        @export(&func_0805237C, .{ .name = "func_0805237C", .linkage = .strong });
        @export(&func_0805253C, .{ .name = "func_0805253C", .linkage = .strong });
        @export(&func_0805266C, .{ .name = "func_0805266C", .linkage = .strong });
        @export(&func_080529D4, .{ .name = "func_080529D4", .linkage = .strong });
        @export(&func_08052C3C, .{ .name = "func_08052C3C", .linkage = .strong });
        @export(&func_08052CD0, .{ .name = "func_08052CD0", .linkage = .strong });
        @export(&func_08053004, .{ .name = "func_08053004", .linkage = .strong });
        @export(&func_08053368, .{ .name = "func_08053368", .linkage = .strong });
        @export(&func_08055290, .{ .name = "func_08055290", .linkage = .strong });
        @export(&func_08055D04, .{ .name = "func_08055D04", .linkage = .strong });
        @export(&func_0805743C, .{ .name = "func_0805743C", .linkage = .strong });
        @export(&func_080574BC, .{ .name = "func_080574BC", .linkage = .strong });
        @export(&func_08057A64, .{ .name = "func_08057A64", .linkage = .strong });
        @export(&func_08058328, .{ .name = "func_08058328", .linkage = .strong });
        @export(&func_0805884C, .{ .name = "func_0805884C", .linkage = .strong });
        @export(&func_08058C80, .{ .name = "func_08058C80", .linkage = .strong });
        @export(&func_08058FD0, .{ .name = "func_08058FD0", .linkage = .strong });
        @export(&func_0805927C, .{ .name = "func_0805927C", .linkage = .strong });
        @export(&func_08059D30, .{ .name = "func_08059D30", .linkage = .strong });
        @export(&func_08059E6C, .{ .name = "func_08059E6C", .linkage = .strong });
        @export(&func_0805A368, .{ .name = "func_0805A368", .linkage = .strong });
        @export(&func_0805A4A8, .{ .name = "func_0805A4A8", .linkage = .strong });
        @export(&func_0805A4EC, .{ .name = "func_0805A4EC", .linkage = .strong });
        @export(&func_0805A568, .{ .name = "func_0805A568", .linkage = .strong });
        @export(&func_0805A5C4, .{ .name = "func_0805A5C4", .linkage = .strong });
        @export(&func_0805A760, .{ .name = "func_0805A760", .linkage = .strong });
        @export(&func_0805B008, .{ .name = "func_0805B008", .linkage = .strong });
        @export(&func_0805B1A0, .{ .name = "func_0805B1A0", .linkage = .strong });
        @export(&func_0805B2F8, .{ .name = "func_0805B2F8", .linkage = .strong });
        @export(&func_0805B388, .{ .name = "func_0805B388", .linkage = .strong });
        @export(&func_0805B3FC, .{ .name = "func_0805B3FC", .linkage = .strong });
        @export(&func_0805B9CC, .{ .name = "func_0805B9CC", .linkage = .strong });
        @export(&func_0805BA60, .{ .name = "func_0805BA60", .linkage = .strong });
        @export(&func_0805BDA4, .{ .name = "func_0805BDA4", .linkage = .strong });
        @export(&func_0805BEC8, .{ .name = "func_0805BEC8", .linkage = .strong });
        @export(&func_0805C0DC, .{ .name = "func_0805C0DC", .linkage = .strong });
        @export(&func_0805C148, .{ .name = "func_0805C148", .linkage = .strong });
        @export(&func_0805C1C8, .{ .name = "func_0805C1C8", .linkage = .strong });
        @export(&func_0805C230, .{ .name = "func_0805C230", .linkage = .strong });
        @export(&func_0805C4E4, .{ .name = "func_0805C4E4", .linkage = .strong });
        @export(&func_0805D52E, .{ .name = "func_0805D52E", .linkage = .strong });
        @export(&func_0805DBE8, .{ .name = "func_0805DBE8", .linkage = .strong });
        @export(&func_0805E740, .{ .name = "func_0805E740", .linkage = .strong });
        @export(&func_0805EFC0, .{ .name = "func_0805EFC0", .linkage = .strong });
        @export(&func_0805F000, .{ .name = "func_0805F000", .linkage = .strong });
        @export(&func_0805F050, .{ .name = "func_0805F050", .linkage = .strong });
        @export(&func_0805F0A4, .{ .name = "func_0805F0A4", .linkage = .strong });
        @export(&func_0805F0E4, .{ .name = "func_0805F0E4", .linkage = .strong });
    }
}
