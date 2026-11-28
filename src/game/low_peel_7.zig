//! Low-ROM (< 0x08080000) block-peeled wave 7 (61..120 reachable lines, next 209).

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

fn func_0801FCF8() callconv(.c) void {
    if (!abi.enter(0x0801FCF8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[13] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0801FD30);
            rt.r[2] = abi.read32(rt.r[13] +% 0x8);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x76, true);
            continue :blk 6;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x3, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x68, true);
            rt.r[2] = abi.read32(rt.r[13] +% 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            continue :blk 6;
        },
        6 => {
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

fn func_0801FEFC() callconv(.c) void {
    if (!abi.enter(0x0801FEFC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[4] = abi.read8(rt.r[4] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.write32(rt.r[13] +% 0x8, rt.r[0]);
            rt.r[6] = abi.read32(0x0801FF3C);
            continue :blk 1;
        },
        1 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[2], rt.r[5] >> 6);
            rt.r[0] = abi.read32(0x0801FF40);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x68, true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1E);
            abi.setRegNz(&rt.r[4], rt.r[0] << 7);
            rt.r[0] = abi.read32(0x0801FF44);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            rt.r[1] = abi.read8(rt.r[2] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x92);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[1], true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write32(rt.r[13] +% 0xC, rt.r[0]);
            rt.r[0] = rt.r[12];
            rt.r[1] = rt.r[8];
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[7], 0x0, true);
            if (!abi.call(decls.func_0801FB14, 0x0801FF63)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            rt.r[13] +%= 0x14;
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

fn func_0801FF08() callconv(.c) void {
    if (!abi.enter(0x0801FF08)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[2], rt.r[5] >> 6);
            rt.r[0] = abi.read32(0x0801FF40);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x68, true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1E);
            abi.setRegNz(&rt.r[4], rt.r[0] << 7);
            rt.r[0] = abi.read32(0x0801FF44);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[1] = abi.read8(rt.r[2] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x92);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[1], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write32(rt.r[13] +% 0xC, rt.r[0]);
            rt.r[0] = rt.r[12];
            rt.r[1] = rt.r[8];
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[7], 0x0, true);
            if (!abi.call(decls.func_0801FB14, 0x0801FF63)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.r[13] +%= 0x14;
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

fn func_0801FF70() callconv(.c) void {
    if (!abi.enter(0x0801FF70)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x1, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(18);
            rt.r[0] = abi.read32(0x0801FFB4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 20));
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[1] = abi.read16(rt.r[1] +% 0x6);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 20));
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            if (!abi.call(decls.func_0801FDE8, 0x0801FF99)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[5], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011814, 0x0801FFAF)) return;
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

fn func_080200FA() callconv(.c) void {
    if (!abi.enter(0x080200FA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[1] +% 0x12);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[5] = abi.read8(rt.r[5] +% 0x6);
            abi.setRegNz(&rt.r[4], rt.r[5] << 25);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 25);
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_080796C8, 0x08020111)) return;
            continue :blk 9;
        },
        7 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 15);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[4] >> 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08020144);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read32(0x08020148);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            continue :blk 10;
        },
        8 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 15);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[4] >> 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08020184);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x08020188);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(15);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[7] >> 15);
            rt.r[3] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[3] >> 10);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(0x0802018C);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read32(0x08020188);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            continue :blk 12;
        },
        11 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 5;
        },
        12 => {
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

fn func_080200FC() callconv(.c) void {
    if (!abi.enter(0x080200FC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[1] +% 0x12);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[5] = abi.read8(rt.r[5] +% 0x6);
            abi.setRegNz(&rt.r[4], rt.r[5] << 25);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 25);
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_080796C8, 0x08020111)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 15);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[4] >> 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08020144);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read32(0x08020148);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            continue :blk 9;
        },
        7 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 15);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[4] >> 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08020184);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x08020188);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(15);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[7] >> 15);
            rt.r[3] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[3] >> 10);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(0x0802018C);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read32(0x08020188);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            continue :blk 11;
        },
        10 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 4;
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

fn func_080200FE() callconv(.c) void {
    if (!abi.enter(0x080200FE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[1] +% 0x12);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[5] = abi.read8(rt.r[5] +% 0x6);
            abi.setRegNz(&rt.r[4], rt.r[5] << 25);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 25);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_080796C8, 0x08020111)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 15);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[4] >> 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08020144);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read32(0x08020148);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            continue :blk 8;
        },
        6 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 15);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[4] >> 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08020184);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x08020188);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(15);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[7] >> 15);
            rt.r[3] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[3] >> 10);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(0x0802018C);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read32(0x08020188);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            continue :blk 10;
        },
        9 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 3;
        },
        10 => {
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

fn func_08020100() callconv(.c) void {
    if (!abi.enter(0x08020100)) return;
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
            abi.fetches(5);
            rt.r[5] = abi.read8(rt.r[5] +% 0x6);
            abi.setRegNz(&rt.r[4], rt.r[5] << 25);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 25);
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_080796C8, 0x08020111)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 15);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[4] >> 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08020144);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read32(0x08020148);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            continue :blk 7;
        },
        5 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 15);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[4] >> 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08020184);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x08020188);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(15);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[7] >> 15);
            rt.r[3] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[3] >> 10);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(0x0802018C);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read32(0x08020188);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 2;
        },
        9 => {
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

fn func_0802010A() callconv(.c) void {
    if (!abi.enter(0x0802010A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_080796C8, 0x08020111)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 2;
        },
        4 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 15);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[4] >> 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08020144);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read32(0x08020148);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 15);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[4] >> 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x08020184);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x08020188);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(15);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[7] >> 15);
            rt.r[3] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[3] >> 10);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(0x0802018C);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read32(0x08020188);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            continue :blk 7;
        },
        7 => {
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

fn func_08020190() callconv(.c) void {
    if (!abi.enter(0x08020190)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x1, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(18);
            rt.r[0] = abi.read32(0x080201D4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 20));
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[1] = abi.read16(rt.r[1] +% 0x6);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 20));
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            if (!abi.call(decls.func_0802000C, 0x080201B9)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[5], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011824, 0x080201CF)) return;
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

fn func_080202C0() callconv(.c) void {
    if (!abi.enter(0x080202C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            rt.r[2] = abi.read32(0x08020320);
            rt.r[0] = abi.read32(0x08020324);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 7);
            rt.r[1] = abi.read32(0x08020318);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x0802031C);
            abi.setRegNz(&rt.r[2], 0x80);
            if (!abi.call(decls.func_0800FFA8, 0x080202DB)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08020328);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 2);
            abi.setRegNz(&rt.r[1], 0xF);
            if (!abi.call(decls.func_0807B6AC, 0x08020305)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08020354);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 2);
            abi.setRegNz(&rt.r[1], 0xF);
            if (!abi.call(decls.func_0807B6AC, 0x0802033D)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0x20);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x20, @truncate(rt.r[0]));
            continue :blk 1;
        },
        6 => {
            abi.fetches(3);
            continue :blk 8;
        },
        7 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x08020358);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x81);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.setRegNz(&rt.r[2], 0x1E);
            if (!abi.call(decls.func_08011374, 0x0802034D)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x0802032C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x81);
            continue :blk 10;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        10 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.setRegNz(&rt.r[2], 0x1E);
            if (!abi.call(decls.func_08011374, 0x08020315)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(3);
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_08020380() callconv(.c) void {
    if (!abi.enter(0x08020380)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[7], rt.r[2] >> 16);
            if (!abi.call(decls.func_08011910, 0x0802038B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x1, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(18);
            rt.r[0] = abi.read32(0x080203DC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 20));
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[1] = abi.read16(rt.r[1] +% 0x6);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 20));
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            if (!abi.call(decls.func_080201D8, 0x080203B1)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[5], 0xA, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x080203C7)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x080203E0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080203E4);
            abi.setRegNz(&rt.r[1], 0xFF);
            if (!abi.call(decls.func_0801320C, 0x080203D5)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[7]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080206F0() callconv(.c) void {
    if (!abi.enter(0x080206F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xC, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.r[6] = abi.read32(0x08020704);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[2] = rt.r[13] +% 0x8;
            rt.r[0] = abi.read32(0x08020708);
            rt.r[1] = abi.read16(rt.r[2] +% 0x4);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(35);
            abi.setRegNz(&rt.r[7], 0xDA);
            abi.setRegNz(&rt.r[7], rt.r[7] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write16(rt.r[2] +% 0x4, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xF);
            rt.r[1] = abi.read8(rt.r[2] +% 0x5);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x5, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[3], 16));
            rt.r[3] = abi.read32(0x080207B4);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[5], 16));
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[3] = abi.read32(rt.r[13] +% 0x8);
            rt.r[4] = abi.read32(rt.r[13] +% 0xC);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write32(rt.r[13] +% 0x4, rt.r[2]);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_080157E4, 0x080207A9)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[13] +%= 0x10;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08020700() callconv(.c) void {
    if (!abi.enter(0x08020700)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(35);
            abi.setRegNz(&rt.r[7], 0xDA);
            abi.setRegNz(&rt.r[7], rt.r[7] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write16(rt.r[2] +% 0x4, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xF);
            rt.r[1] = abi.read8(rt.r[2] +% 0x5);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x5, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[3], 16));
            rt.r[3] = abi.read32(0x080207B4);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[5], 16));
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[3] = abi.read32(rt.r[13] +% 0x8);
            rt.r[4] = abi.read32(rt.r[13] +% 0xC);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write32(rt.r[13] +% 0x4, rt.r[2]);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_080157E4, 0x080207A9)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[13] +%= 0x10;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080207EE() callconv(.c) void {
    if (!abi.enter(0x080207EE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x12, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.r[6] = abi.read32(0x080207FC);
            continue :blk 1;
        },
        1 => {
            abi.fetches(39);
            rt.r[2] = rt.r[13] +% 0x8;
            rt.r[0] = abi.read32(0x08020860);
            rt.r[7] = abi.read16(rt.r[2] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[7]);
            abi.setRegNz(&rt.r[7], 0xDA);
            abi.setRegNz(&rt.r[7], rt.r[7] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write16(rt.r[2] +% 0x4, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xF);
            rt.r[1] = abi.read8(rt.r[2] +% 0x5);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x5, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[3], 16));
            rt.r[3] = abi.read32(0x08020864);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[5], 16));
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[3] = abi.read32(rt.r[13] +% 0x8);
            rt.r[4] = abi.read32(rt.r[13] +% 0xC);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write32(rt.r[13] +% 0x4, rt.r[2]);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_080157E4, 0x08020855)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[13] +%= 0x10;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08020B48() callconv(.c) void {
    if (!abi.enter(0x08020B48)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[0], 0x13);
            if (!abi.call(decls.func_08018B68, 0x08020B5D)) return;
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
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[5] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[2], rt.r[6] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            if (!abi.call(decls.func_08020868, 0x08020B75)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_080212F4() callconv(.c) void {
    if (!abi.enter(0x080212F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x08021370);
            if (!abi.call(decls.func_08013B70, 0x080212FD)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(40);
            rt.r[2] = abi.read32(0x08021380);
            rt.r[0] = abi.read32(0x08021378);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[5] = abi.read16(rt.r[1] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[5] << 4);
            rt.r[4] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x08021384);
            rt.r[3] = abi.read16(rt.r[1] +% 0xE);
            abi.setRegNz(&rt.r[0], rt.r[3] << 4);
            rt.r[3] = abi.read16(rt.r[1] +% 0x6);
            rt.cpuSub(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x08021388);
            rt.r[5] = abi.read16(rt.r[1] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[5] << 4);
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0802138C);
            rt.r[5] = abi.read16(rt.r[1] +% 0xE);
            abi.setRegNz(&rt.r[0], rt.r[5] << 4);
            rt.cpuSub(&rt.r[0], rt.r[3], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x08021390);
            rt.r[5] = abi.read16(rt.r[1] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[5] << 4);
            rt.cpuSub(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[4]));
            rt.r[2] = abi.read32(0x08021394);
            rt.r[1] = abi.read16(rt.r[1] +% 0xE);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuSub(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(16);
            rt.r[2] = abi.read32(0x08021374);
            rt.r[0] = abi.read32(0x08021378);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read16(rt.r[1] +% 0xC);
            abi.setRegNz(&rt.r[0], rt.r[3] << 4);
            rt.r[5] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(&rt.r[0], rt.r[5], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0802137C);
            rt.r[3] = abi.read16(rt.r[1] +% 0xE);
            abi.setRegNz(&rt.r[0], rt.r[3] << 4);
            rt.r[1] = abi.read16(rt.r[1] +% 0x6);
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08021794() callconv(.c) void {
    if (!abi.enter(0x08021794)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[7], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[6], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[4], rt.r[7], rt.r[5], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0801FDE8, 0x080217AF)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0802000C, 0x080217B7)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[5], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
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

fn func_080217C8() callconv(.c) void {
    if (!abi.enter(0x080217C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[7], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[4], rt.r[7], rt.r[5], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801FDE8, 0x080217E3)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0802000C, 0x080217EB)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[5], 0xA, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
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

fn func_080217FC() callconv(.c) void {
    if (!abi.enter(0x080217FC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[5], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_080201D8, 0x08021815)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0xF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
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

fn func_08021824() callconv(.c) void {
    if (!abi.enter(0x08021824)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[5], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_080201D8, 0x0802183D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0xA, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
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

fn func_0802184C() callconv(.c) void {
    if (!abi.enter(0x0802184C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[5], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[4], rt.r[3] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080214CC, 0x0802186B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(func_080217C8, 0x08021877)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08021890);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(func_08021824, 0x0802188B)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08021894() callconv(.c) void {
    if (!abi.enter(0x08021894)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[5], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[4], rt.r[3] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080214CC, 0x080218B3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(func_080217C8, 0x080218BF)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080218D8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(func_08021824, 0x080218D3)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_080218DC() callconv(.c) void {
    if (!abi.enter(0x080218DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[5], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[4], rt.r[3] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0802162C, 0x080218FB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(func_08021794, 0x08021907)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08021920);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(func_080217FC, 0x0802191B)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08021924() callconv(.c) void {
    if (!abi.enter(0x08021924)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[5], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[4], rt.r[3] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0802162C, 0x08021943)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(func_08021794, 0x0802194F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08021968);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(func_080217FC, 0x08021963)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08021E40() callconv(.c) void {
    if (!abi.enter(0x08021E40)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(27);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x08021E8C);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 15));
            rt.r[4] = abi.read32(0x08021E90);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[2] = abi.read32(0x08021E94);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], 0xE0);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[1]);
            abi.setRegNz(&rt.r[2], 0x1F);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[1]);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x12, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
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
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08021E98);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
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
            rt.cpuSub(null, rt.r[2], 0xE, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0xA, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0xB, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_08021FC8() callconv(.c) void {
    if (!abi.enter(0x08021FC8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(30);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x08022034);
            abi.setRegNz(&rt.r[1], 0x4);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x08022038);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.setRegNz(&rt.r[4], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[4]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0802203C);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x08022040);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_080104B0, 0x08022001)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(21);
            rt.r[2] = abi.read32(0x08022044);
            abi.setRegNz(&rt.r[0], 0x3F);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.setRegNz(&rt.r[1], 0x40);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[4]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[1] = abi.read8(rt.r[2] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08022048);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0802206C);
            abi.setRegNz(&rt.r[0], 0x6);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08022070);
            abi.setRegNz(&rt.r[0], 0x10);
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0802204C);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08022050);
            abi.setRegNz(&rt.r[0], 0xA);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_080104D4, 0x08022065)) return;
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

fn func_080225C0() callconv(.c) void {
    if (!abi.enter(0x080225C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x0802260C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 2);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[0]);
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08022610);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1B);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(decls.func_0801BFD0, 0x080225E7)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
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
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xB, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[0] = abi.read32(0x0802263C);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011398, 0x0802262D)) return;
            continue :blk 3;
        },
        8 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x08022614);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xB, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011398, 0x0802260B)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08022640() callconv(.c) void {
    if (!abi.enter(0x08022640)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.r[1] = abi.read32(0x08022668);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0xB, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08022698);
            if (!abi.call(decls.func_08012D8C, 0x08022677)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0xE5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            if (!abi.call(decls.func_08012D8C, 0x08022659)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080395A8, 0x0802267B)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080395A8, 0x0802265D)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x0802269C);
            abi.setRegNz(&rt.r[0], rt.r[4] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x080226A0);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(decls.func_080796DC, 0x08022691)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802266C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x8);
            if (!abi.call(decls.func_0801AC1C, 0x08022667)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
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

fn func_0802292C() callconv(.c) void {
    if (!abi.enter(0x0802292C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(decls.func_0803F048, 0x08022935)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 24);
            abi.setRegNz(&rt.r[0], 0x3);
            if (!abi.call(decls.func_0803F048, 0x08022941)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], 0x4);
            if (!abi.call(decls.func_0803F048, 0x0802294B)) return;
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
            rt.r[1] = abi.read32(0x08022978);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
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
            abi.fetches(6);
            abi.write8(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
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
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08022964);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_08023BA0() callconv(.c) void {
    if (!abi.enter(0x08023BA0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(21);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x08023BE4);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 15));
            rt.r[4] = abi.read32(0x08023BE8);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read32(0x08023BEC);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 16);
            rt.cpuSub(null, rt.r[1], 0x0, true);
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
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 22);
            rt.r[0] = abi.read32(0x08023BF0);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x68, true);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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

fn func_08023D54() callconv(.c) void {
    if (!abi.enter(0x08023D54)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x08023DAC);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 15));
            rt.r[4] = abi.read32(0x08023DB0);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read32(0x08023DB4);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
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
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08023DB8);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x12, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08023DBC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08025410, 0x08023DC7)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_080241DC() callconv(.c) void {
    if (!abi.enter(0x080241DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(51);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 24);
            abi.setRegNz(&rt.r[6], 0x0);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[5]));
            abi.setRegNz(&rt.r[3], 0x1);
            abi.write8(rt.r[4] +% 0x1, @truncate(rt.r[3]));
            abi.setRegNz(&rt.r[2], 0x7F);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.r[1] = abi.read8(rt.r[4] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write8(rt.r[4] +% 0x6, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x80);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x64);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[4] +% 0x4, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08024248);
            abi.setRegNz(&rt.r[0], rt.r[5] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x12);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[1]);
            abi.write8(rt.r[4] +% 0x6, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[1], 0xF);
            rt.r[0] = abi.read8(rt.r[0] +% 0xD);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.setRegNz(&rt.r[1], rt.r[1] << 7);
            rt.r[0] = abi.read32(0x0802424C);
            rt.r[2] = abi.read16(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write16(rt.r[4] +% 0x4, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x7);
            rt.r[1] = abi.read8(rt.r[4] +% 0x5);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write8(rt.r[4] +% 0x5, @truncate(rt.r[0]));
            abi.write8(rt.r[4] +% 0x7, @truncate(rt.r[6]));
            abi.write8(rt.r[4] +% 0x8, @truncate(rt.r[6]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[4] +% 0x9, @truncate(rt.r[0]));
            abi.write8(rt.r[4] +% 0xA, @truncate(rt.r[6]));
            abi.write8(rt.r[4] +% 0xB, @truncate(rt.r[3]));
            rt.cpuSub(null, rt.r[5], 0x2, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write8(rt.r[4] +% 0xB, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x1, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
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
            abi.write8(rt.r[4] +% 0xB, @truncate(rt.r[6]));
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802425C() callconv(.c) void {
    if (!abi.enter(0x0802425C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[5], rt.r[2] >> 16);
            if (!abi.call(decls.func_080240EC, 0x0802426F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], rt.r[5] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_080241DC, 0x08024283)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        4 => {
            abi.fetches(18);
            abi.write8(rt.r[4] +% 0x2, @truncate(rt.r[7]));
            abi.write8(rt.r[4] +% 0x3, @truncate(rt.r[6]));
            rt.r[1] = abi.read32(0x080242B0);
            rt.r[0] = abi.read32(0x080242B4);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x36, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFE, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_08024544() callconv(.c) void {
    if (!abi.enter(0x08024544)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[0] = abi.read32(0x0802458C);
            rt.r[3] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x33, true);
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[3], rt.r[1], true);
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
            abi.fetches(7);
            rt.r[6] = abi.read32(0x08024590);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[4], rt.r[0] << 2);
            abi.setRegNz(&rt.r[5], 0x8);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0xC, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.r[0] = abi.read16(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x33, true);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xFE);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_08024594() callconv(.c) void {
    if (!abi.enter(0x08024594)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[2], 0xC0);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
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
            abi.fetches(19);
            rt.r[1] = abi.read32(0x08024604);
            rt.r[0] = abi.read32(0x08024608);
            rt.r[12] = rt.r[0];
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[7] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[7], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[6], rt.r[0], rt.r[3], true);
            rt.r[4] = abi.read8(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x1, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[6] +% 0x7);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(10);
            rt.r[1] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[7], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 1;
        },
        9 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08024614() callconv(.c) void {
    if (!abi.enter(0x08024614)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[3], rt.r[1] >> 24);
            rt.r[1] = abi.read32(0x08024658);
            rt.r[4] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x0, true);
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
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x7);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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

fn func_08024774() callconv(.c) void {
    if (!abi.enter(0x08024774)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[2] = abi.read32(0x080247A0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[4], 0x3F);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            ldmRegs(0, &.{ 5, 6, 7 });
            stmRegs(1, &.{ 5, 6, 7 });
            rt.cpuAdd(&rt.r[3], rt.r[3], 0xC, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xC, true);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
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

fn func_080247A4() callconv(.c) void {
    if (!abi.enter(0x080247A4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x080247D8);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010A84, 0x080247C7)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807B6AC, 0x080247CD)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_080248E8() callconv(.c) void {
    if (!abi.enter(0x080248E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.r[2] = abi.read32(0x08024930);
            rt.r[1] = abi.read32(0x08024934);
            rt.r[3] = abi.read8(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[3] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[4] = abi.read16(rt.r[0] +% 0x20);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1);
            rt.cpuSub(null, rt.r[1], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08024CD0, 0x0802491F)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08024938);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x21, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0802493C);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x82, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            continue :blk 1;
        },
        5 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08024940);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 9;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x64);
            continue :blk 9;
        },
        8 => {
            abi.fetches(6);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        10 => {
            abi.fetches(9);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[0], 0x64);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            if (!abi.call(decls.func_0807B488, 0x0802495B)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x64);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_08024AE0() callconv(.c) void {
    if (!abi.enter(0x08024AE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[5], 0x1);
            rt.r[6] = abi.read32(0x08024B48);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(func_080248E8, 0x08024AED)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] *% rt.r[1]);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[2], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2F, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08024970, 0x08024B01)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x30, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08024A48, 0x08024B0F)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x31, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_080248AC, 0x08024B1D)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[1] +% 0x32);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write16(rt.r[1] +% 0x32, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[2], 0x32);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(decls.func_080397B8, 0x08024B2F)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[1], true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2E, true);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
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

fn func_08024D20() callconv(.c) void {
    if (!abi.enter(0x08024D20)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x08024D4C);
            rt.r[4] = abi.read16(rt.r[0] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0x5, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(decls.func_08024CD0, 0x08024D3B)) return;
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
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08024D4C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_08025000() callconv(.c) void {
    if (!abi.enter(0x08025000)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[5], 0x1);
            rt.r[0] = abi.read32(0x08025078);
            rt.r[8] = rt.r[0];
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.r[2] = rt.r[8];
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1B);
            rt.cpuAdd(&rt.r[7], rt.r[5], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], 0x1);
            abi.setRegNz(&rt.r[6], 0x68);
            rt.r[0] = abi.read32(0x0802507C);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[7] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.r[12] = rt.r[0];
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], rt.r[4], true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(17);
            rt.r[2] = rt.r[8];
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[6]);
            rt.cpuAdd(&rt.r[3], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x26, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[6]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 3;
        },
        9 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x28, true);
            rt.r[2] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[1]);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_08025024() callconv(.c) void {
    if (!abi.enter(0x08025024)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[12] = rt.r[0];
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], rt.r[4], true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(17);
            rt.r[2] = rt.r[8];
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[6]);
            rt.cpuAdd(&rt.r[3], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x26, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[6]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
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
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x28, true);
            rt.r[2] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[1]);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[7] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 7;
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
        7 => {
            abi.fetches(11);
            rt.r[2] = rt.r[8];
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1B);
            rt.cpuAdd(&rt.r[7], rt.r[5], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], 0x1);
            abi.setRegNz(&rt.r[6], 0x68);
            rt.r[0] = abi.read32(0x0802507C);
            continue :blk 0;
        },
        else => unreachable,
    }
}

fn func_08025564() callconv(.c) void {
    if (!abi.enter(0x08025564)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[6], 0x1);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[6] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(decls.func_08024CD0, 0x08025571)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuAdd(&rt.r[7], rt.r[6], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[5], 0x1);
            rt.r[0] = abi.read32(0x080255C0);
            rt.r[12] = rt.r[0];
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[6], rt.r[7], 0x0, true);
            rt.cpuSub(null, rt.r[6], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], rt.r[6], true);
            if (rt.CPU_Z) {
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
            abi.fetches(11);
            rt.r[0] = rt.r[12];
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x68);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[3], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[3] +% 0x1B);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            rt.cpuSub(null, rt.r[5], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        9 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x26, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[3] +% 0x14, @truncate(rt.r[0]));
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_080255EC() callconv(.c) void {
    if (!abi.enter(0x080255EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
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
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08025654);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[5] = abi.read16(rt.r[3] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[5], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[5] = abi.read32(0x08025658);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x12, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(19);
            rt.r[2] = abi.read32(0x0802565C);
            rt.r[5] = abi.read32(0x08025660);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x1F);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[4] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x4C, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
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

fn func_08025944() callconv(.c) void {
    if (!abi.enter(0x08025944)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(35);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            rt.r[3] = abi.read32(0x080259AC);
            rt.r[4] = abi.read8(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x080259B0);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[2], rt.r[6] << 1);
            rt.r[5] = abi.read32(0x080259B4);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[1], 16));
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[1] = abi.read32(0x080259B8);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1A, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
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
            rt.r[2] = abi.read8(rt.r[7] +% 0x7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0802566C, 0x08025991)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[2] = abi.read8(rt.r[7] +% 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0802566C, 0x080259A1)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_080259C4() callconv(.c) void {
    if (!abi.enter(0x080259C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(35);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[3] = abi.read32(0x08025A1C);
            rt.r[4] = abi.read8(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08025A20);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[2], rt.r[6] << 1);
            rt.r[7] = abi.read32(0x08025A24);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[7], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x08025A28);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1A, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            rt.r[2] = abi.read8(rt.r[5] +% 0x7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0802566C, 0x08025A11)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08025A34() callconv(.c) void {
    if (!abi.enter(0x08025A34)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(35);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[3] = abi.read32(0x08025A8C);
            rt.r[4] = abi.read8(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08025A90);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[2], rt.r[6] << 1);
            rt.r[7] = abi.read32(0x08025A94);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[7], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x08025A98);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1A, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            rt.r[2] = abi.read8(rt.r[5] +% 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0802566C, 0x08025A81)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08025B68() callconv(.c) void {
    if (!abi.enter(0x08025B68)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[2] = abi.read32(0x08025BC4);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            rt.r[6] = abi.read32(0x08025BC8);
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[1], 15));
            rt.r[4] = abi.read32(0x08025BCC);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.r[1] = abi.read32(0x08025BD0);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_08025484, 0x08025B93)) return;
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
            abi.fetches(17);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.r[2] = abi.read32(0x08025BCC);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[4] = abi.read32(0x08025BD0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x6, true);
            rt.cpuSub(null, rt.r[0], 0xC, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
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
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x08025BD4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08025C0C => continue :blk 6,
                0x08025C10 => { continue :blk 2; },
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08025C18() callconv(.c) void {
    if (!abi.enter(0x08025C18)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(24);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x08025C58);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 15));
            rt.r[4] = abi.read32(0x08025C5C);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read32(0x08025C60);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xE0);
            rt.r[1] = abi.read32(0x08025C64);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
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
            abi.setRegNz(&rt.r[0], 0x1F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(null, rt.r[0], 0xA, true);
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
            rt.cpuSub(null, rt.r[0], 0xB, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0xE, true);
            if (!rt.CPU_Z) {
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

fn func_08026060() callconv(.c) void {
    if (!abi.enter(0x08026060)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 14 });
            if (!abi.call(decls.func_08026020, 0x08026067)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08016934, 0x0802606B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(14);
            rt.r[4] = abi.read32(0x080260BC);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[2] = abi.read32(0x080260C0);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.write8(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[2] +% 0x2);
            abi.write8(rt.r[1] +% 0x3, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080260C4);
            rt.r[0] = abi.read8(rt.r[0] +% 0xD);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080367F0, 0x08026091)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read32(0x080260C8);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            if (!abi.call(decls.func_0802417C, 0x0802608D)) return;
            continue :blk 3;
        },
        5 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[2] = abi.read8(rt.r[0] +% 0x1);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[2]);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08023EDC, 0x080260B1)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08018CC8, 0x080260B5)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080260CC() callconv(.c) void {
    if (!abi.enter(0x080260CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            if (!abi.call(decls.func_08026020, 0x080260D3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08016934, 0x080260D7)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            rt.r[4] = abi.read32(0x08026110);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[2] = abi.read32(0x08026114);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.write8(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[2] +% 0x2);
            abi.write8(rt.r[1] +% 0x3, @truncate(rt.r[0]));
            if (!abi.call(decls.func_080367F0, 0x080260EB)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read8(rt.r[4] +% 0x1);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[4] +% 0x1, @truncate(rt.r[0]));
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08026374() callconv(.c) void {
    if (!abi.enter(0x08026374)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(25);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[4] = abi.read32(0x080263B0);
            rt.r[0] = abi.read32(0x080263B4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read32(0x080263B8);
            rt.r[0] = abi.read16(rt.r[3] +% 0x2);
            abi.setRegNz(&rt.r[2], rt.r[0] << 1);
            rt.r[5] = abi.read32(0x080263BC);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[1], rt.r[0], true);
            if (!abi.call(decls.func_08026020, 0x080263A3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x7);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080263F8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[4] +% 0x7, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080263C0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[4] +% 0x8, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(16);
            rt.r[2] = abi.read32(0x080263FC);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[3] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x10);
            rt.r[5] = abi.read8(rt.r[4] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[5]);
            abi.write8(rt.r[4] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
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
            abi.setRegNz(&rt.r[0], 0x4F);
            if (!abi.call(decls.func_0803D880, 0x080263F1)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_08026400() callconv(.c) void {
    if (!abi.enter(0x08026400)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(52);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[2] = abi.read32(0x08026488);
            rt.r[5] = abi.read32(0x0802648C);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x7, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[7], true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0xF7);
            rt.r[6] = abi.read8(rt.r[2] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[12] = rt.r[1];
            abi.setRegNz(&rt.r[1], 0xFD);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(0x08026490);
            rt.r[3] = abi.read32(0x08026494);
            rt.r[1] = abi.read32(0x08026498);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[6]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[6] = abi.read8(rt.r[4] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            abi.write8(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[6]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[4] = abi.read8(rt.r[4] +% 0x2);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.write8(rt.r[2] +% 0x3, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x7, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[1] = rt.r[12];
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuSub(null, rt.r[7], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[5] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read8(rt.r[5] +% 0x7);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0xEF);
            rt.r[3] = abi.read8(rt.r[5] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write8(rt.r[5] +% 0x1, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(5);
            abi.write8(rt.r[1] +% 0x7, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            abi.write8(rt.r[0] +% 0x8, @truncate(rt.r[7]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08026750() callconv(.c) void {
    if (!abi.enter(0x08026750)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            if (!abi.call(decls.func_080353D4, 0x08026757)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x080267A8);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2E, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x080267AC);
            rt.r[0] = abi.read32(0x080267B0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[2] +% 0x8, rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x32, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x080267C0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(func_08024544, 0x080267A1)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(22);
            rt.r[5] = abi.read32(0x080267B4);
            rt.r[4] = abi.read32(0x080267B8);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x68);
            rt.r[2] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x080267BC);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2B, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[5] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[2] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 2;
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

fn func_080267C4() callconv(.c) void {
    if (!abi.enter(0x080267C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x080267E0);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x080267D1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x080267E4);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0802680C);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            continue :blk 4;
        },
        4 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08026810);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_080137E4, 0x08026809)) return;
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

fn func_08026824() callconv(.c) void {
    if (!abi.enter(0x08026824)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x08026868);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x08026831)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.r[2] = abi.read32(0x0802686C);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[2], true);
            rt.cpuSub(null, rt.r[2], 0x4, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[2], rt.r[4] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_080137E4, 0x08026863)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], 0x80);
            abi.setRegNz(&rt.r[4], rt.r[4] << 1);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08026855)) return;
            continue :blk 2;
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

fn func_08026934() callconv(.c) void {
    if (!abi.enter(0x08026934)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 24);
            rt.r[0] = abi.read32(0x0802699C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 20));
            rt.cpuSub(null, rt.r[6], rt.r[2], true);
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
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[1] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 20));
            rt.cpuSub(null, rt.r[5], rt.r[1], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xE, true);
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x9, true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080269A0);
            rt.r[2] = abi.read32(0x080269A4);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[3], 0x2);
            if (!abi.call(decls.func_080133C0, 0x08026977)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 24));
            abi.setRegNz(&rt.r[2], 0xC0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_080137E4, 0x08026989)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x2);
            if (!abi.call(decls.func_08026870, 0x08026995)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_080269A8() callconv(.c) void {
    if (!abi.enter(0x080269A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 24);
            rt.r[0] = abi.read32(0x08026A10);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 20));
            rt.cpuSub(null, rt.r[6], rt.r[2], true);
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
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[1] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 20));
            rt.cpuSub(null, rt.r[5], rt.r[1], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xE, true);
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x9, true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08026A14);
            rt.r[2] = abi.read32(0x08026A18);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_080133C0, 0x080269EB)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 24));
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_080137E4, 0x080269FD)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08026870, 0x08026A09)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08026B4C() callconv(.c) void {
    if (!abi.enter(0x08026B4C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x4;
            rt.r[0] = abi.read32(0x08026B94);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.r[4] = abi.read32(0x08026B98);
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
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
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08026B9C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x7);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[1] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(decls.func_0801C07C, 0x08026B75)) return;
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
            abi.fetches(14);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 1);
            abi.setRegNz(&rt.r[1], 0xF);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x08026BA0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0xBF);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011398, 0x08026B93)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(24);
            rt.r[0] = abi.read32(0x08026BD8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[4] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1A);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 2);
            abi.setRegNz(&rt.r[2], 0xF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[2] = abi.read32(0x08026BDC);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0xBF);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011398, 0x08026BD1)) return;
            continue :blk 1;
        },
        7 => {
            abi.fetches(3);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08026E34() callconv(.c) void {
    if (!abi.enter(0x08026E34)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08026E7C);
            rt.r[2] = abi.read32(rt.r[0] +% 0x4);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[2], 0x3, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x57, true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.write32(rt.r[3] +% 0x4, rt.r[0]);
            abi.setRegNz(&rt.r[1], 0x56);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[2] = abi.read32(rt.r[3] +% 0x4);
            rt.cpuSub(null, rt.r[2], 0xA0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.write32(rt.r[3] +% 0x4, rt.r[0]);
            continue :blk 2;
        },
        4 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0xA0, true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.write32(rt.r[3] +% 0x4, rt.r[0]);
            rt.cpuSub(null, rt.r[0], 0xA1, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xA0);
            abi.write32(rt.r[3] +% 0x4, rt.r[0]);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_08026E80() callconv(.c) void {
    if (!abi.enter(0x08026E80)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08026EC4);
            rt.r[2] = abi.read32(rt.r[0] +% 0x4);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[2], 0x9F, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[2] = abi.read32(rt.r[3] +% 0x4);
            rt.cpuSub(null, rt.r[2], 0x2, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0xFA, true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.write32(rt.r[3] +% 0x4, rt.r[0]);
            rt.cpuSub(null, rt.r[0], 0xF8, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(10);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x3, true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.write32(rt.r[3] +% 0x4, rt.r[0]);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x57);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.write32(rt.r[3] +% 0x4, rt.r[0]);
            continue :blk 1;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write32(rt.r[3] +% 0x4, rt.r[0]);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08026EC8() callconv(.c) void {
    if (!abi.enter(0x08026EC8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            abi.pushLr();
            rt.r[2] = abi.read32(0x08026EFC);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.r[1] = abi.read32(0x08026F00);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[3] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.r[2] = abi.read16(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[2] << 4);
            rt.r[1] = abi.read16(rt.r[1] +% 0x6);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x4F, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08026F14);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x7F, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(func_08026E34, 0x08026F11)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(func_08026E80, 0x08026F1D)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(func_08026E80, 0x08026EF9)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(3);
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08026F2C);
            abi.setRegNz(&rt.r[1], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(decls.func_08026C88, 0x08026F27)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(3);
            continue :blk 7;
        },
        9 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08026F70() callconv(.c) void {
    if (!abi.enter(0x08026F70)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            abi.pushLr();
            rt.r[2] = abi.read32(0x08026FA4);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.r[1] = abi.read32(0x08026FA8);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[3] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.r[2] = abi.read16(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[2] << 4);
            rt.r[1] = abi.read16(rt.r[1] +% 0x6);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x4F, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08026FBC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x7F, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08026F30, 0x08026FB9)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08026F50, 0x08026FC5)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08026F50, 0x08026FA1)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(3);
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
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

fn func_08026FC8() callconv(.c) void {
    if (!abi.enter(0x08026FC8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08026FF4);
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
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_08015824, 0x08027001)) return;
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
            rt.cpuSub(null, rt.r[1], 0x2, true);
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
            rt.r[0] = abi.read32(0x08026FEC);
            continue :blk 3;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        10 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08027004);
            continue :blk 3;
        },
        11 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        12 => {
            abi.fetches(3);
            continue :blk 11;
        },
        13 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08027014);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_08015824, 0x08027011)) return;
            continue :blk 11;
        },
        else => unreachable,
    }
}

fn func_0802759C() callconv(.c) void {
    if (!abi.enter(0x0802759C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(decls.func_08027578, 0x080275A5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x080275C8);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080275CC);
            rt.r[5] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[5], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], 0x9);
            rt.r[0] = rt.sext8(abi.read8(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[4], 0x14);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[4]));
            rt.r[2] = abi.read16(rt.r[2] +% 0x16);
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            if (!abi.call(decls.func_08013550, 0x080275E7)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            abi.write32(rt.r[4] +% 0x8, rt.r[1]);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x6E);
            if (!abi.call(decls.func_0803D880, 0x080275C7)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
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

fn func_080277DC() callconv(.c) void {
    if (!abi.enter(0x080277DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[5] = abi.read32(0x08027830);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x4);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08027578, 0x08027847)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(19);
            abi.setRegNz(&rt.r[2], 0x7);
            rt.r[2] = rt.sext8(abi.read8(rt.r[1] +% rt.r[2]));
            rt.r[0] = abi.read32(0x08027834);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1A);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x08027838);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0xA0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[2], 0xC);
            if (!abi.call(decls.func_08011374, 0x0802780F)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[4] +% 0x8, rt.r[0]);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x6F);
            if (!abi.call(decls.func_0803D880, 0x08027815)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0802783C);
            abi.write32(rt.r[4] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x2);
            if (!abi.call(decls.func_080136A4, 0x08027827)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[4] +% 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807B450, 0x0802782F)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_08027850() callconv(.c) void {
    if (!abi.enter(0x08027850)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(26);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            rt.r[2] = abi.read32(rt.r[13] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            abi.setRegNz(&rt.r[5], rt.r[5] << 16);
            abi.setRegNz(&rt.r[5], rt.r[5] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            rt.r[9] = rt.r[2];
            rt.r[0] = abi.read32(0x080278D4);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08027881)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(18);
            rt.r[6] = abi.read32(0x080278D8);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.r[0] = rt.r[8];
            abi.write16(rt.r[1] +% 0xC, @truncate(rt.r[0]));
            abi.write16(rt.r[1] +% 0xE, @truncate(rt.r[7]));
            abi.setRegNz(&rt.r[0], 0x14);
            rt.cpuSub(&rt.r[4], rt.r[0], rt.r[4], true);
            abi.write8(rt.r[1] +% 0x4, @truncate(rt.r[4]));
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.write8(rt.r[1] +% 0x5, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x5);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(26);
            rt.r[3] = abi.read32(rt.r[6] +% 0x0);
            rt.r[0] = abi.read32(0x080278DC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[7] << 1);
            rt.r[4] = abi.read32(0x080278E0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] +%= rt.r[8];
            rt.r[2] = abi.read32(0x080278E4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 5);
            abi.write8(rt.r[3] +% 0x6, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[4] = rt.r[9];
            abi.write8(rt.r[0] +% 0x7, @truncate(rt.r[4]));
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x5, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_080278E8() callconv(.c) void {
    if (!abi.enter(0x080278E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(29);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[4] = abi.read32(0x08027964);
            rt.r[6] = abi.read32(0x08027968);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[6] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x24);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x24, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            rt.r[5] = abi.read32(0x0802796C);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(decls.func_08013744, 0x0802791F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(decls.func_08013794, 0x0802793B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[6] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[1], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
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
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[6] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0802795F)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08027970() callconv(.c) void {
    if (!abi.enter(0x08027970)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x080279A4);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            if (!abi.call(decls.func_080137C0, 0x0802797D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], 0x10, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            if (!abi.call(decls.func_08013794, 0x080279B1)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08013794, 0x0802799B)) return;
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
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            if (!abi.call(decls.func_08013248, 0x080279A3)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_080279B8() callconv(.c) void {
    if (!abi.enter(0x080279B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[4] = abi.read32(0x08027A20);
            rt.r[3] = abi.read32(0x08027A24);
            rt.r[2] = abi.read32(0x08027A28);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 2));
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(0x08027A2C);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[5]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[5], 0x1E);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[5]));
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
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
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(19);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 2));
            abi.setRegNz(&rt.r[0], 0x10);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x1E);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], 0x20, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08027A1B)) return;
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

fn func_08027A30() callconv(.c) void {
    if (!abi.enter(0x08027A30)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[4] = abi.read32(0x08027A9C);
            rt.r[3] = abi.read32(0x08027AA0);
            rt.r[2] = abi.read32(0x08027AA4);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[5], 0x1E);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[5]));
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 2));
            abi.setRegNz(&rt.r[0], 0x8);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(0x08027AA8);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 2));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[5]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x1E);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], 0x20, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08027A95)) return;
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

fn func_08027B34() callconv(.c) void {
    if (!abi.enter(0x08027B34)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x08027B68);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x08027B41)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[0], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], 0x4, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            if (!abi.call(decls.func_08013744, 0x08027B75)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08013744, 0x08027B5F)) return;
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
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            if (!abi.call(decls.func_08013248, 0x08027B67)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08028664() callconv(.c) void {
    if (!abi.enter(0x08028664)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x20);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080286C8);
            if (!abi.call(decls.func_08013B70, 0x0802867D)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080286C4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08028677)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x22);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x32, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
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
            abi.fetches(4);
            rt.r[5] = abi.read32(0x080286CC);
            rt.r[3] = abi.read32(0x080286D0);
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080286EC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x080286E5)) return;
            continue :blk 5;
        },
        8 => {
            abi.fetches(22);
            abi.setRegNz(&rt.r[2], 0x22);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read16(rt.r[4] +% 0x22);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.write16(rt.r[4] +% 0x22, @truncate(rt.r[2]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(func_0802AA3C, 0x080286C3)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x32, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        11 => {
            abi.fetches(3);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_08028734() callconv(.c) void {
    if (!abi.enter(0x08028734)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080286F0, 0x08028749)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], rt.r[5] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08028714, 0x08028753)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08028774);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08028778);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(func_08024544, 0x08028765)) return;
            continue :blk 3;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08028B80, 0x0802876D)) return;
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

fn func_080287A8() callconv(.c) void {
    if (!abi.enter(0x080287A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(decls.func_08024CD0, 0x080287B7)) return;
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x080287DC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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

fn func_080287E8() callconv(.c) void {
    if (!abi.enter(0x080287E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.r[1] = abi.read32(0x0802885C);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read8(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[2] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08024CD0, 0x08028807)) return;
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
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08025194, 0x08028813)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
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
            abi.fetches(34);
            rt.r[1] = abi.read32(0x08028860);
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[4] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.r[0] = abi.read32(0x08028864);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08028868);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2A, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[0] << 1);
            rt.r[5] = abi.read32(0x0802886C);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x29, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read32(0x08028870);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0xE0);
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_08028A40() callconv(.c) void {
    if (!abi.enter(0x08028A40)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x08028A50);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x31, true);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[0] = abi.read32(0x08028A88);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x68);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x10);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (rt.CPU_C) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 7;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x40);
            if (!abi.call(decls.func_08018D84, 0x08028A5D)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 7;
        },
        else => unreachable,
    }
}

fn func_08028B9C() callconv(.c) void {
    if (!abi.enter(0x08028B9C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_08028A8C, 0x08028BA3)) return;
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
            abi.fetches(4);
            if (!abi.call(func_08028A40, 0x08028BBB)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080289C0, 0x08028BAD)) return;
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
            if (!abi.call(func_08025564, 0x08028BB1)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(func_08025564, 0x08028BC5)) return;
            continue :blk 9;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08028940, 0x08028BCB)) return;
            continue :blk 10;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08028400, 0x08028BB5)) return;
            continue :blk 11;
        },
        9 => {
            abi.fetches(3);
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        11 => {
            abi.fetches(3);
            continue :blk 10;
        },
        else => unreachable,
    }
}

fn func_080293F4() callconv(.c) void {
    if (!abi.enter(0x080293F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[2] = abi.read32(0x08029418);
            rt.r[5] = abi.read32(rt.r[2] +% 0x0);
            rt.r[1] = abi.read32(0x0802941C);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[3] = abi.read32(0x08029420);
            rt.r[4] = abi.read32(0x08029424);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[1]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x8, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 3));
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            if (!abi.call(decls.func_080290CC, 0x08029449)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x77);
            if (!abi.call(decls.func_0803D880, 0x0802944F)) return;
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

fn func_08029654() callconv(.c) void {
    if (!abi.enter(0x08029654)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(22);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x080296A4);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x080296A8);
            rt.r[0] = abi.read16(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.r[4] = abi.read32(0x080296AC);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[0], true);
            rt.r[2] = abi.read32(0x080296B0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[4] = abi.read32(0x080296B4);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08025410, 0x08029699)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0802979C() callconv(.c) void {
    if (!abi.enter(0x0802979C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[2] = abi.read32(0x08029804);
            rt.r[3] = abi.read32(0x08029808);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x20);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.r[6] = abi.read32(0x0802980C);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(32);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x20);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[2], 0x3);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[7], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[7]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[7], 0x20);
            rt.r[2] = rt.sext16(abi.read16(rt.r[0] +% rt.r[7]));
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x6A);
            if (!abi.call(decls.func_0803D880, 0x080297FF)) return;
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

fn func_08029810() callconv(.c) void {
    if (!abi.enter(0x08029810)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[2] = abi.read32(0x08029878);
            rt.r[3] = abi.read32(0x0802987C);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x20);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.r[6] = abi.read32(0x08029880);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(32);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x20);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[2], 0x3);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[7], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[7]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[7], 0x20);
            rt.r[2] = rt.sext16(abi.read16(rt.r[0] +% rt.r[7]));
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x6A);
            if (!abi.call(decls.func_0803D880, 0x08029873)) return;
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

fn func_08029884() callconv(.c) void {
    if (!abi.enter(0x08029884)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[1] = abi.read32(0x080298F8);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            rt.r[2] = abi.read32(0x080298FC);
            rt.r[4] = abi.read32(rt.r[2] +% 0x0);
            rt.r[6] = abi.read32(0x08029900);
            rt.r[5] = abi.read32(0x08029904);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[3] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 5);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[6], true);
            abi.setRegNz(&rt.r[3], 0x22);
            rt.r[2] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x7, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[4] +% 0x0);
            if (!abi.call(decls.func_0802566C, 0x080298AF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(32);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write16(rt.r[1] +% 0x1E, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[5] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[1], 0x3);
            abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[5] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.write16(rt.r[0] +% 0x24, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(0x08029908);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(func_0802979C, 0x080298F3)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080348BC, 0x080298EF)) return;
            continue :blk 2;
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

fn func_08029F34() callconv(.c) void {
    if (!abi.enter(0x08029F34)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            abi.setRegNz(&rt.r[2], 0x22);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            if (!abi.call(decls.func_0802928C, 0x08029F45)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[4] +% 0x24);
            rt.r[0] = abi.read32(0x08029F50);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[1], 4));
            abi.write32(rt.r[4] +% 0x2C, rt.r[0]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x32);
            continue :blk 6;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x6B);
            if (!abi.call(decls.func_0803D880, 0x08029F67)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.write32(rt.r[4] +% 0x2C, rt.r[0]);
            continue :blk 5;
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

fn func_08029F84() callconv(.c) void {
    if (!abi.enter(0x08029F84)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(rt.r[3] +% 0x24);
            rt.r[4] = abi.read32(rt.r[3] +% 0x2C);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write32(rt.r[3] +% 0x24, rt.r[0]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x30, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x30, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(11);
            rt.r[2] = abi.read32(0x08029FF4);
            rt.r[0] = abi.read32(0x08029FF8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(rt.r[3] +% 0x28);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08026814, 0x08029FDD)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x08029FB4);
            rt.r[0] = abi.read32(0x08029FB8);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08029FFC);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(decls.func_08013248, 0x08029FE7)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x6C);
            if (!abi.call(decls.func_0803D880, 0x08029FED)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0802A000() callconv(.c) void {
    if (!abi.enter(0x0802A000)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 24);
            abi.setRegNz(&rt.r[6], rt.r[3] >> 24);
            rt.r[0] = abi.read32(0x0802A048);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x0802A013)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(23);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.write32(rt.r[3] +% 0x24, rt.r[4]);
            rt.r[2] = abi.read32(0x0802A04C);
            rt.r[0] = abi.read32(0x0802A050);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write32(rt.r[3] +% 0x28, rt.r[0]);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            abi.write16(rt.r[3] +% 0x20, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[5] +% 0x2);
            abi.write16(rt.r[3] +% 0x22, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0802A054);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x47, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x30, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x30, true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
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

fn func_0802A084() callconv(.c) void {
    if (!abi.enter(0x0802A084)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.r[13] -%= 0x4;
            rt.r[8] = rt.r[0];
            rt.r[1] = abi.read32(0x0802A0F8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[5], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.r[7] = abi.read32(0x0802A0FC);
            rt.r[6] = abi.read32(0x0802A100);
            continue :blk 1;
        },
        1 => {
            abi.fetches(23);
            abi.setRegNz(&rt.r[4], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[1] = abi.read16(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x2, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.r[3] = abi.read16(rt.r[7] +% 0x2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            if (!abi.call(decls.func_0802588C, 0x0802A0C7)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[4], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[6], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[5], 0x3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[3] = rt.r[8];
            abi.write16(rt.r[3] +% 0x1E, @truncate(rt.r[0]));
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0802A104() callconv(.c) void {
    if (!abi.enter(0x0802A104)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0802A134);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read16(rt.r[2] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[0], 20));
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
            abi.fetches(7);
            rt.r[2] = abi.read16(rt.r[2] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 20));
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
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
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xE, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x9, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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

fn func_0802A688() callconv(.c) void {
    if (!abi.enter(0x0802A688)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(40);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[4] = abi.read32(0x0802A6E4);
            rt.r[2] = abi.read32(0x0802A6E8);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 15));
            rt.r[5] = abi.read32(0x0802A6EC);
            rt.cpuAdd(&rt.r[3], rt.r[2], rt.r[5], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x12, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read32(0x0802A6F0);
            rt.cpuSub(&rt.r[1], rt.r[3], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 2));
            abi.setRegNz(&rt.r[1], 0xC0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
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
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_08025874, 0x0802A6DB)) return;
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802A834() callconv(.c) void {
    if (!abi.enter(0x0802A834)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(22);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x0802A884);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[4] +% 0x3);
            abi.setRegNz(&rt.r[2], rt.r[0] << 1);
            rt.r[5] = abi.read32(0x0802A888);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[4] +% 0x2);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[5] = abi.read32(0x0802A88C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807B458, 0x0802A89B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[5] = abi.read32(0x0802A890);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807B458, 0x0802A865)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(12);
            rt.r[1] = abi.read8(rt.r[4] +% 0x3);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            rt.r[4] = abi.read8(rt.r[4] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[4]);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.r[1] = abi.read8(rt.r[5] +% 0x0);
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(func_0802A000, 0x0802A87F)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0802AA3C() callconv(.c) void {
    if (!abi.enter(0x0802AA3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
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
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[1] = abi.read8(rt.r[4] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(17);
            rt.r[0] = abi.read32(0x0802AA74);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[4], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 2));
            if (!abi.call(decls.func_0802430C, 0x0802AA6F)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[4] +% 0x2);
            rt.r[1] = abi.read8(rt.r[4] +% 0x3);
            if (!abi.call(decls.func_0802928C, 0x0802AA81)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08023EDC, 0x0802AA73)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0802AAA0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_080131E0, 0x0802AA89)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            continue :blk 1;
        },
        8 => {
            abi.fetches(3);
            continue :blk 9;
        },
        9 => {
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
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0802AD0C() callconv(.c) void {
    if (!abi.enter(0x0802AD0C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[0] = abi.read32(0x0802AD68);
            rt.r[0] = abi.read8(rt.r[0] +% 0x5);
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
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802AD6C);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08015824, 0x0802AD1F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080104B0, 0x0802AD23)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(33);
            rt.r[2] = abi.read32(0x0802AD70);
            abi.setRegNz(&rt.r[0], 0xC0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.setRegNz(&rt.r[6], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[6]);
            abi.setRegNz(&rt.r[5], 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[5]);
            abi.setRegNz(&rt.r[4], 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[4]);
            abi.setRegNz(&rt.r[3], 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[2] +% 0x1);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[6]);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[5]);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[4]);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[3]);
            abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x0802AD74);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0802AD78);
            abi.setRegNz(&rt.r[0], 0x10);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0802AD7C);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0802BAA4() callconv(.c) void {
    if (!abi.enter(0x0802BAA4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            rt.r[2] = abi.read32(0x0802BACC);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 23);
            rt.r[4] = abi.read32(0x0802BAD0);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x12, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(28);
            rt.r[1] = abi.read32(0x0802BB1C);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[1], rt.r[0], true);
            rt.cpuSub(&rt.r[1], rt.r[4], rt.r[1], true);
            abi.setRegNz(&rt.r[2], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[2] << 4);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[2] << 8);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.cpuSub(&rt.r[2], 0, rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 8));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.r[1] = abi.read32(0x0802BB20);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            if (!abi.call(decls.func_080254BC, 0x0802BB09)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(7);
            rt.r[0] = abi.read8(rt.r[4] +% 0x8);
            rt.r[1] = abi.read8(rt.r[4] +% 0x7);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 4;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802BC50() callconv(.c) void {
    if (!abi.enter(0x0802BC50)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            abi.pushLr();
            rt.r[2] = abi.read32(0x0802BC84);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.r[1] = abi.read32(0x0802BC88);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[3] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.r[2] = abi.read16(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[2] << 4);
            rt.r[1] = abi.read16(rt.r[1] +% 0x6);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x30, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802BC9C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x7F, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802BB44, 0x0802BC99)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802BBC8, 0x0802BCA5)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802BBC8, 0x0802BC81)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(3);
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
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

fn func_0802C058() callconv(.c) void {
    if (!abi.enter(0x0802C058)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            abi.pushLr();
            rt.r[2] = abi.read32(0x0802C08C);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.r[1] = abi.read32(0x0802C090);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[3] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.r[2] = abi.read16(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[2] << 4);
            rt.r[1] = abi.read16(rt.r[1] +% 0x6);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x40, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0802C0A8);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x7F, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            if (!abi.call(decls.func_0802BFB0, 0x0802C0A5)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0802C094);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
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

fn func_0802C0C4() callconv(.c) void {
    if (!abi.enter(0x0802C0C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[7], 0xFF);
            abi.setRegNz(&rt.r[7], rt.r[7] << 16);
            abi.setRegNz(&rt.r[7], rt.r[7] & rt.r[1]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0802C10C);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_0807B6AC, 0x0802C0E5)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[7], 16));
            rt.r[2] = abi.read32(0x0802C110);
            if (!abi.call(decls.func_0801B888, 0x0802C0F5)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_0807B634, 0x0802C0FD)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[6], 0x7, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 1;
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

fn func_0802C11C() callconv(.c) void {
    if (!abi.enter(0x0802C11C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[7], 0xFF);
            abi.setRegNz(&rt.r[7], rt.r[7] << 16);
            abi.setRegNz(&rt.r[7], rt.r[7] & rt.r[1]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0802C164);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_0807B6AC, 0x0802C13D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x10, true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[7], 16));
            rt.r[2] = abi.read32(0x0802C168);
            if (!abi.call(decls.func_0801B888, 0x0802C14F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_0807B634, 0x0802C157)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[6], 0x7, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 1;
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

fn func_0802C174() callconv(.c) void {
    if (!abi.enter(0x0802C174)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[5], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], 0x5, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x6);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(21);
            abi.setRegNz(&rt.r[1], rt.r[3] << 2);
            rt.r[0] = abi.read32(0x0802C1D8);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
            rt.r[1] = abi.read32(0x0802C1DC);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[5] << 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuSub(&rt.r[1], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[5], true);
            rt.cpuSub(&rt.r[7], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x2, true);
            continue :blk 5;
        },
        5 => {
            abi.fetches(14);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[2]));
            abi.write16(rt.r[3] +% 0x2, @truncate(rt.r[7]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x80, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x9, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 5;
            }
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

fn func_0802C1E0() callconv(.c) void {
    if (!abi.enter(0x0802C1E0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0802C21C);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0802C220);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0802C224);
            rt.r[1] = abi.read32(0x0802C228);
            abi.setRegNz(&rt.r[2], 0xE0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            if (!abi.call(decls.func_0800FFA8, 0x0802C1FB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(func_0802C174, 0x0802C207)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0xE, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[5] +% 0x1E, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0802C22C() callconv(.c) void {
    if (!abi.enter(0x0802C22C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0802C25C);
            rt.r[1] = abi.read32(0x0802C260);
            abi.setRegNz(&rt.r[2], 0xE0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            if (!abi.call(decls.func_0800FFA8, 0x0802C23D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x6);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(func_0802C174, 0x0802C249)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0xE, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[5] +% 0x1E, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0802C264() callconv(.c) void {
    if (!abi.enter(0x0802C264)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[6] = abi.read16(rt.r[5] +% 0x1E);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x0802C2A1)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            rt.r[2] = abi.read32(0x0802C2AC);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(func_0802C174, 0x0802C28B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[5] +% 0x1E);
            rt.cpuSub(null, rt.r[0], 0x15, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[5] +% 0x8, rt.r[0]);
            continue :blk 8;
        },
        6 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[5] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0xE, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
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

fn func_0802C2BC() callconv(.c) void {
    if (!abi.enter(0x0802C2BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x6);
            rt.r[1] = abi.read16(rt.r[5] +% 0x1E);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x0802C303)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 9);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(func_0802C174, 0x0802C2ED)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[5] +% 0x1E);
            rt.cpuSub(null, rt.r[0], 0x15, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[5] +% 0x8, rt.r[0]);
            continue :blk 8;
        },
        6 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[5] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0xE, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
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

fn func_0802C4C0() callconv(.c) void {
    if (!abi.enter(0x0802C4C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[2] = abi.read32(0x0802C4D4);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08016008, 0x0802C4F9)) return;
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
                continue :blk 6;
            }
            continue :blk 9;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803DB6C, 0x0802C4EF)) return;
            continue :blk 10;
        },
        7 => {
            abi.fetches(3);
            continue :blk 11;
        },
        8 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0802C4F0);
            rt.r[0] = abi.read8(rt.r[2] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x74, true);
            abi.write8(rt.r[1] +% 0x1F, @truncate(rt.r[0]));
            continue :blk 6;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        10 => {
            abi.fetches(3);
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        12 => {
            abi.fetches(3);
            continue :blk 11;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803DB6C, 0x0802C4FF)) return;
            continue :blk 11;
        },
        else => unreachable,
    }
}

fn func_0802C7AC() callconv(.c) void {
    if (!abi.enter(0x0802C7AC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_080212B8, 0x0802C7B3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021010, 0x0802C7B7)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021398, 0x0802C7BB)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802C7F4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            rt.r[1] = abi.read16(rt.r[1] +% 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0802C7F8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x0802C7FC);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802C800);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xB);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x66);
            if (!abi.call(decls.func_0803D880, 0x0802C7E9)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802C804);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0802C7F1)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802C8F4() callconv(.c) void {
    if (!abi.enter(0x0802C8F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0802D6F4, 0x0802C8FB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(func_08026060, 0x0802C8FF)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D70C, 0x0802C903)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(14);
            rt.r[2] = abi.read32(0x0802C938);
            rt.r[0] = abi.read32(0x0802C93C);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802C940);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0802C944);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0802C948);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08034988, 0x0802C935)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802C94C() callconv(.c) void {
    if (!abi.enter(0x0802C94C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[3] = abi.read8(rt.r[4] +% 0x2);
            rt.r[0] = abi.read8(rt.r[5] +% 0x2);
            rt.cpuSub(&rt.r[2], rt.r[3], rt.r[0], true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[1] = abi.read8(rt.r[4] +% 0x3);
            rt.r[0] = abi.read8(rt.r[5] +% 0x3);
            rt.cpuSub(&rt.r[3], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[2], rt.r[0], rt.r[3], true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            continue :blk 7;
        },
        6 => {
            abi.fetches(6);
            rt.r[4] = abi.read8(rt.r[4] +% 0x3);
            rt.r[5] = abi.read8(rt.r[5] +% 0x3);
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (rt.CPU_C) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.r[4] = abi.read8(rt.r[4] +% 0x2);
            rt.r[5] = abi.read8(rt.r[5] +% 0x2);
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (!rt.CPU_C) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        8 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0802C980);
            continue :blk 12;
        },
        9 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0802C988);
            continue :blk 12;
        },
        10 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0802C998);
            continue :blk 12;
        },
        11 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0802C9A4);
            continue :blk 12;
        },
        12 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_0802CE68() callconv(.c) void {
    if (!abi.enter(0x0802CE68)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x2);
            rt.r[0] = abi.read8(rt.r[6] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
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
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
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
            abi.fetches(40);
            rt.r[0] = abi.read32(0x0802CECC);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            rt.r[1] = abi.read32(0x0802CED0);
            rt.r[5] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x68);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[4]);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[5], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x91, true);
            rt.cpuSub(&rt.r[3], rt.r[6], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x91, true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802D63C() callconv(.c) void {
    if (!abi.enter(0x0802D63C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x0802D68C);
            if (!abi.call(decls.func_08013B70, 0x0802D645)) return;
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
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0802D690);
            if (!abi.call(decls.func_08013B70, 0x0802D657)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0802D694);
            if (!abi.call(decls.func_08013B70, 0x0802D665)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0802D698);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035230, 0x0802D67D)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[1] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(decls.func_08026140, 0x0802D6A9)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802D69C);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(decls.func_08013248, 0x0802D687)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802D6B8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0802D6B1)) return;
            continue :blk 3;
        },
        12 => {
            abi.fetches(4);
            if (!abi.call(func_0802E730, 0x0802D68B)) return;
            continue :blk 13;
        },
        13 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802D6BC() callconv(.c) void {
    if (!abi.enter(0x0802D6BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0802D6E4);
            if (!abi.call(decls.func_08013B70, 0x0802D6C5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
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
            rt.r[0] = abi.read32(0x0802D6E8);
            if (!abi.call(decls.func_08013B70, 0x0802D6D7)) return;
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
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802D9D4() callconv(.c) void {
    if (!abi.enter(0x0802D9D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[3] = abi.read32(0x0802DA20);
            rt.r[4] = abi.read32(0x0802DA24);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x33, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 6;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 6;
        },
        5 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 9);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x32, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
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
            abi.fetches(12);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0802DA6C() callconv(.c) void {
    if (!abi.enter(0x0802DA6C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0802DAB0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read32(0x0802DAB4);
            rt.r[0] = abi.read16(rt.r[3] +% 0x2);
            abi.setRegNz(&rt.r[2], rt.r[0] << 1);
            rt.r[4] = abi.read32(0x0802DAB8);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(13);
            rt.r[1] = abi.read32(0x0802DABC);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(0x0802DAC0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08024664, 0x0802DAA5)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802DACC() callconv(.c) void {
    if (!abi.enter(0x0802DACC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_0802DA6C, 0x0802DAD3)) return;
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802DD5C, 0x0802DADD)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xFF);
            if (!abi.call(decls.func_0801D048, 0x0802DAE9)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(14);
            rt.r[2] = abi.read32(0x0802DB08);
            rt.r[1] = abi.read32(0x0802DB0C);
            rt.r[3] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(decls.func_08025DFC, 0x0802DB01)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 2;
        },
        9 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802DC3C() callconv(.c) void {
    if (!abi.enter(0x0802DC3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[2] = abi.read32(0x0802DCA0);
            rt.r[5] = abi.read32(0x0802DCA4);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[3] = abi.read8(rt.r[0] +% 0x10);
            rt.cpuSub(null, rt.r[3], 0x1, true);
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
            abi.fetches(18);
            rt.r[0] = abi.read32(0x0802DCA8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[4] = abi.read32(0x0802DCAC);
            rt.r[6] = abi.read16(rt.r[4] +% 0x2);
            abi.setRegNz(&rt.r[2], rt.r[6] << 1);
            rt.r[6] = abi.read32(0x0802DCB0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read16(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read32(0x0802DCB4);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xFF);
            if (!abi.call(decls.func_0801D048, 0x0802DC89)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_0801DAE0, 0x0802DC93)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08025C70, 0x0802DC97)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 1;
        },
        10 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802DCC0() callconv(.c) void {
    if (!abi.enter(0x0802DCC0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x0802DD04);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[4] = abi.read32(0x0802DD08);
            rt.r[0] = abi.read16(rt.r[4] +% 0x2);
            abi.setRegNz(&rt.r[2], rt.r[0] << 1);
            rt.r[3] = abi.read32(0x0802DD0C);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read16(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
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
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read32(0x0802DD10);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(11);
            rt.r[2] = abi.read32(0x0802DD14);
            rt.r[0] = abi.read32(0x0802DD18);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x10);
            continue :blk 1;
        },
        5 => {
            abi.fetches(13);
            rt.r[2] = abi.read32(0x0802DD54);
            rt.r[5] = abi.read32(0x0802DD58);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xFF);
            if (!abi.call(decls.func_0801D048, 0x0802DD39)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_0801DAE0, 0x0802DD43)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08025D48, 0x0802DD47)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802DDFC() callconv(.c) void {
    if (!abi.enter(0x0802DDFC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_0802DA6C, 0x0802DE03)) return;
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802DD5C, 0x0802DE0D)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802DE3C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08025874, 0x0802DE1B)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xFF);
            if (!abi.call(decls.func_0801D048, 0x0802DE27)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0802DE40);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            if (!abi.call(decls.func_0801DBCC, 0x0802DE31)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08025F80, 0x0802DE35)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 2;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802DE4C() callconv(.c) void {
    if (!abi.enter(0x0802DE4C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0802DE7C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x18, true);
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
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(func_0802DA6C, 0x0802DE67)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802DD5C, 0x0802DE71)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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

fn func_0802DE88() callconv(.c) void {
    if (!abi.enter(0x0802DE88)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_0802DA6C, 0x0802DE8F)) return;
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802DD5C, 0x0802DE99)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802DEB0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 2;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802DF58() callconv(.c) void {
    if (!abi.enter(0x0802DF58)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(24);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x10;
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 24);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            rt.r[1] = rt.r[13];
            rt.r[0] = abi.read32(0x0802DFAC);
            ldmRegs(0, &.{ 3, 4, 7 });
            stmRegs(1, &.{ 3, 4, 7 });
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.r[4] = abi.read32(0x0802DFB0);
            rt.r[0] = abi.read8(rt.r[4] +% 0x9);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[4] +% 0x9, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            rt.r[1] = abi.read8(rt.r[4] +% 0x9);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.r[0] +%= rt.r[13];
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0807B458, 0x0802DF99)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[4] +% 0x9, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080192F0, 0x0802DF9D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x0802DFB4);
            rt.r[0] = abi.read8(rt.r[4] +% 0x9);
            abi.write16(rt.r[1] +% 0x1A, @truncate(rt.r[0]));
            rt.r[13] +%= 0x10;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0802E148() callconv(.c) void {
    if (!abi.enter(0x0802E148)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0802E18C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08019608, 0x0802E155)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D6F4, 0x0802E159)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(func_08026060, 0x0802E15D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D70C, 0x0802E161)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802E190);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802E194);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0802E1AC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            rt.r[2] = abi.read8(rt.r[2] +% 0x1);
            if (!abi.call(decls.func_08034904, 0x0802E1A9)) return;
            continue :blk 5;
        },
        9 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802E198);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08034988, 0x0802E189)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(3);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0802E1B0() callconv(.c) void {
    if (!abi.enter(0x0802E1B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0802E1E8);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08019608, 0x0802E1BD)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D6F4, 0x0802E1C1)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08026178, 0x0802E1C5)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(func_08026060, 0x0802E1C9)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D70C, 0x0802E1CD)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802E1EC);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802E1F0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08034988, 0x0802E1E5)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0802E1F4() callconv(.c) void {
    if (!abi.enter(0x0802E1F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0802E22C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08019608, 0x0802E201)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D6F4, 0x0802E205)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(func_08026374, 0x0802E209)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(func_08026060, 0x0802E20D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D70C, 0x0802E211)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802E230);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802E234);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x6);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08034988, 0x0802E229)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0802E238() callconv(.c) void {
    if (!abi.enter(0x0802E238)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[0] = abi.read32(0x0802E290);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(decls.func_08019608, 0x0802E245)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0802E294);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x32, true);
            rt.r[0] = abi.read8(rt.r[6] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D6F4, 0x0802E27D)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[5] = abi.read8(rt.r[1] +% 0xD);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802649C, 0x0802E281)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0802E298);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[4] = abi.read32(0x0802E29C);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            if (!abi.call(decls.func_0802417C, 0x0802E263)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[6] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(func_08026060, 0x0802E285)) return;
            continue :blk 10;
        },
        8 => {
            abi.fetches(3);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[5]));
            continue :blk 6;
        },
        9 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802E2A0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x9);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08034988, 0x0802E279)) return;
            continue :blk 2;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D70C, 0x0802E289)) return;
            continue :blk 11;
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

fn func_0802E384() callconv(.c) void {
    if (!abi.enter(0x0802E384)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[1] = abi.read32(0x0802E3C8);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08019608, 0x0802E391)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[4] = abi.read32(0x0802E3CC);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x7F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[1] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x0802E3AB)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802E3F4);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08024154, 0x0802E3DF)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(16);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[3] = abi.read32(0x0802E3D0);
            rt.r[2] = abi.read32(rt.r[4] +% 0x0);
            rt.r[4] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[4] << 3);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x18);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 1));
            continue :blk 4;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(func_080260CC, 0x0802E3E3)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802E3F8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_0802430C, 0x0802E3EB)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08023EDC, 0x0802E3EF)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0802E438() callconv(.c) void {
    if (!abi.enter(0x0802E438)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 2, 5, 7, 14 });
            abi.setRegNz(&rt.r[0], 0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.pushLr();
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xFF);
            if (!abi.call(decls.func_0801D048, 0x0802E451)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x0802E47C);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x2);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.r[2] = abi.read32(0x0802E480);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            if (!abi.call(decls.func_0801E6E8, 0x0802E463)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802E484);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_080131E0, 0x0802E46B)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08019608, 0x0802E46F)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08022074, 0x0802E473)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035220, 0x0802E477)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802E43C() callconv(.c) void {
    if (!abi.enter(0x0802E43C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xFF);
            if (!abi.call(decls.func_0801D048, 0x0802E451)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x0802E47C);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x2);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.r[2] = abi.read32(0x0802E480);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            if (!abi.call(decls.func_0801E6E8, 0x0802E463)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802E484);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_080131E0, 0x0802E46B)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08019608, 0x0802E46F)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08022074, 0x0802E473)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035220, 0x0802E477)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0802E484() callconv(.c) void {
    if (!abi.enter(0x0802E484)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 2, 3, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], 0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = abi.read32(0x0802E4D4);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.r[6] = abi.read32(0x0802E4D8);
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
            abi.fetches(22);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x0802E4DC);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x0802E4E0);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 28);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 30);
            abi.setRegNz(&rt.r[1], rt.r[1] << 14);
            abi.setRegNz(&rt.r[2], rt.r[4] << 7);
            rt.r[3] = abi.read32(0x0802E4E4);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0x80);
            if (!abi.call(decls.func_0800FDA4, 0x0802E4C1)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802E488() callconv(.c) void {
    if (!abi.enter(0x0802E488)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = abi.read32(0x0802E4D4);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.r[6] = abi.read32(0x0802E4D8);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(22);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x0802E4DC);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x0802E4E0);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 28);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 30);
            abi.setRegNz(&rt.r[1], rt.r[1] << 14);
            abi.setRegNz(&rt.r[2], rt.r[4] << 7);
            rt.r[3] = abi.read32(0x0802E4E4);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0x80);
            if (!abi.call(decls.func_0800FDA4, 0x0802E4C1)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0802E600() callconv(.c) void {
    if (!abi.enter(0x0802E600)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[4], 0x1);
            abi.setRegNz(&rt.r[0], 0x11);
            if (!abi.call(decls.func_08018BA8, 0x0802E60B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
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
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0802E644);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0802E648);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x6, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x14);
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021DF8, 0x0802E62F)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0802E64C);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            abi.setRegNz(&rt.r[3], 0x1);
            if (!abi.call(decls.func_080195AC, 0x0802E63B)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035220, 0x0802E63F)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0802E668() callconv(.c) void {
    if (!abi.enter(0x0802E668)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[4], 0x1);
            rt.r[0] = abi.read32(0x0802E6AC);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0802E6B0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x6, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x14);
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021DF8, 0x0802E68F)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0802E6B4);
            rt.r[1] = abi.read32(0x0802E6B8);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            abi.setRegNz(&rt.r[3], 0x1);
            if (!abi.call(decls.func_080193C0, 0x0802E6A1)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035220, 0x0802E6A5)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0802E6BC() callconv(.c) void {
    if (!abi.enter(0x0802E6BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[4], 0x1);
            rt.r[0] = abi.read32(0x0802E700);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0802E704);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x6, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x14);
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021DF8, 0x0802E6E3)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0802E708);
            rt.r[1] = abi.read32(0x0802E70C);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            abi.setRegNz(&rt.r[3], 0x1);
            if (!abi.call(decls.func_080193C0, 0x0802E6F5)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035220, 0x0802E6F9)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0802E730() callconv(.c) void {
    if (!abi.enter(0x0802E730)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[4], 0x1);
            rt.r[0] = abi.read32(0x0802E76C);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0802E770);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x6, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x14);
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021DF8, 0x0802E755)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0802E774);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x1);
            abi.setRegNz(&rt.r[3], 0x1);
            if (!abi.call(decls.func_080195AC, 0x0802E761)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035220, 0x0802E765)) return;
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

fn func_0802E778() callconv(.c) void {
    if (!abi.enter(0x0802E778)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(24);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[2] = abi.read32(0x0802E7B0);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 15));
            rt.r[5] = abi.read32(0x0802E7B4);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[5], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read32(0x0802E7B8);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuSub(null, rt.r[0], 0xA, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0802E818, 0x0802E801)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x0802E7BC);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x0802E7EC => continue :blk 4,
                0x0802E7FA => continue :blk 1,
                0x0802E7F0 => continue :blk 5,
                0x0802E7F4 => continue :blk 6,
                0x0802E7F8 => continue :blk 7,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802E814);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_080131E0, 0x0802E809)) return;
            continue :blk 8;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x7);
            continue :blk 1;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x10);
            continue :blk 1;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x20);
            continue :blk 1;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x8);
            continue :blk 1;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035220, 0x0802E80D)) return;
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

fn func_0802E984() callconv(.c) void {
    if (!abi.enter(0x0802E984)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[1], 0x5);
            rt.r[5] = abi.read32(0x0802E9C4);
            abi.setRegNz(&rt.r[4], 0xBA);
            abi.setRegNz(&rt.r[4], rt.r[4] << 1);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[3], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[3], 11));
            continue :blk 2;
        },
        2 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[1], 0xF, true);
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
            rt.cpuSub(null, rt.r[0], 0x12, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x0802E9BF)) return;
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

fn func_0802ECDC() callconv(.c) void {
    if (!abi.enter(0x0802ECDC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            rt.r[2] = abi.read16(rt.r[4] +% 0x1E);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[3], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[3]));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            abi.setRegNz(&rt.r[3], 0x1E);
            rt.r[2] = rt.sext16(abi.read16(rt.r[4] +% rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x6, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 3;
        },
        5 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x22);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x7, true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(func_0802E984, 0x0802ED19)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 6;
        },
        8 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            if (!abi.call(decls.func_0802EA80, 0x0802ED21)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0802ED38);
            abi.setRegNz(&rt.r[3], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_0803CD40, 0x0802ED31)) return;
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

fn func_0802ECE6() callconv(.c) void {
    if (!abi.enter(0x0802ECE6)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[3], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[3]));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            abi.setRegNz(&rt.r[3], 0x1E);
            rt.r[2] = rt.sext16(abi.read16(rt.r[4] +% rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x6, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 2;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x22);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x7, true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(func_0802E984, 0x0802ED19)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 5;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            if (!abi.call(decls.func_0802EA80, 0x0802ED21)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0802ED38);
            abi.setRegNz(&rt.r[3], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_0803CD40, 0x0802ED31)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0802EF60() callconv(.c) void {
    if (!abi.enter(0x0802EF60)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0802EF74);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x8, true);
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
            rt.r[1] = abi.read32(0x0802EF78);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x0802EFA0 => continue :blk 3,
                0x0802EFA6 => continue :blk 4,
                0x0802EFAC => continue :blk 5,
                0x0802EFB2 => continue :blk 6,
                0x0802EFB8 => continue :blk 7,
                0x0802EFBE => continue :blk 8,
                0x0802EFC4 => continue :blk 9,
                0x0802EFCA => continue :blk 10,
                0x0802EFD0 => continue :blk 11,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802EFE8, 0x0802EFA5)) return;
            continue :blk 12;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802F190, 0x0802EFAB)) return;
            continue :blk 13;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802F270, 0x0802EFB1)) return;
            continue :blk 14;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802F9E0, 0x0802EFB7)) return;
            continue :blk 15;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802FA08, 0x0802EFBD)) return;
            continue :blk 16;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802FA40, 0x0802EFC3)) return;
            continue :blk 17;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(func_0802F340, 0x0802EFC9)) return;
            continue :blk 18;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802F5D4, 0x0802EFCF)) return;
            continue :blk 19;
        },
        11 => {
            abi.fetches(4);
            if (!abi.call(func_0802F5EC, 0x0802EFD5)) return;
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
        14 => {
            abi.fetches(3);
            continue :blk 1;
        },
        15 => {
            abi.fetches(3);
            continue :blk 1;
        },
        16 => {
            abi.fetches(3);
            continue :blk 1;
        },
        17 => {
            abi.fetches(3);
            continue :blk 1;
        },
        18 => {
            abi.fetches(3);
            continue :blk 1;
        },
        19 => {
            abi.fetches(3);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0802F340() callconv(.c) void {
    if (!abi.enter(0x0802F340)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 14 });
            if (!abi.call(decls.func_080212B8, 0x0802F347)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021194, 0x0802F34B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021398, 0x0802F34F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_08020D14, 0x0802F355)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0802F37C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(4);
            if (!abi.call(decls.func_080367F0, 0x0802F36B)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08023EDC, 0x0802F36F)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080203E8, 0x0802F373)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0802F380);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0802F5EC() callconv(.c) void {
    if (!abi.enter(0x0802F5EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 14 });
            if (!abi.call(decls.func_080212B8, 0x0802F5F3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080210F0, 0x0802F5F7)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021398, 0x0802F5FB)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_08020D14, 0x0802F601)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802EF2C, 0x0802F605)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0802F62C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080104B0, 0x0802F621)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0802F630);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0802F8F4() callconv(.c) void {
    if (!abi.enter(0x0802F8F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.r[2] = abi.read32(0x0802F940);
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            if (!abi.call(decls.func_0801D148, 0x0802F8FF)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_0801D968, 0x0802F905)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            continue :blk 5;
        },
        5 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x0802F944);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[3] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[3] >> 16);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(func_08020380, 0x0802F919)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802F948);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            if (!abi.call(decls.func_0803AC5C, 0x0802F921)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x69);
            if (!abi.call(decls.func_0803D880, 0x0802F927)) return;
            continue :blk 8;
        },
        8 => {
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

fn func_0802F8F6() callconv(.c) void {
    if (!abi.enter(0x0802F8F6)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[2] = abi.read32(0x0802F940);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            if (!abi.call(decls.func_0801D148, 0x0802F8FF)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_0801D968, 0x0802F905)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            continue :blk 4;
        },
        4 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x0802F944);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[3] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[3] >> 16);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(func_08020380, 0x0802F919)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802F948);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            if (!abi.call(decls.func_0803AC5C, 0x0802F921)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x69);
            if (!abi.call(decls.func_0803D880, 0x0802F927)) return;
            continue :blk 7;
        },
        7 => {
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

fn func_0802F8F8() callconv(.c) void {
    if (!abi.enter(0x0802F8F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            if (!abi.call(decls.func_0801D148, 0x0802F8FF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_0801D968, 0x0802F905)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            continue :blk 3;
        },
        3 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x0802F944);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[3] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[3] >> 16);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(func_08020380, 0x0802F919)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802F948);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            if (!abi.call(decls.func_0803AC5C, 0x0802F921)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x69);
            if (!abi.call(decls.func_0803D880, 0x0802F927)) return;
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
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0802FE08() callconv(.c) void {
    if (!abi.enter(0x0802FE08)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(24);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0802FE74);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            rt.r[0] = abi.read32(0x0802FE78);
            abi.write32(rt.r[0] +% 0x0, rt.r[2]);
            rt.r[0] = abi.read32(0x0802FE7C);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            rt.r[0] = abi.read32(0x0802FE80);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            rt.r[4] = abi.read32(0x0802FE84);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.r[1] = abi.read16(rt.r[2] +% 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write32(rt.r[4] +% 0x0, rt.r[0]);
            rt.r[1] = abi.read32(0x0802FE88);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read16(rt.r[2] +% 0x6);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            rt.r[0] = abi.read32(0x0802FE8C);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[2] = abi.read32(0x0802FE90);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x80);
            abi.setRegNz(&rt.r[4], rt.r[4] << 6);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0802FE94);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[1] = abi.read32(0x0802FE98);
            abi.setRegNz(&rt.r[0], 0x7);
            if (!abi.call(decls.func_0807AE50, 0x0802FE57)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xA);
            abi.write16(rt.r[2] +% 0x6, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0802FE9C);
            abi.setRegNz(&rt.r[0], 0x6);
            if (!abi.call(decls.func_0807AE50, 0x0802FE5F)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0802FEA0);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(decls.func_0807AE60, 0x0802FE67)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0802FEA4);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0802FEF6() callconv(.c) void {
    if (!abi.enter(0x0802FEF6)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0802FF40);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            rt.r[0] = abi.read16(rt.r[0] +% 0x4);
            rt.r[0] = ~rt.r[0]; rt.updateNz(rt.r[0]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0802FF44);
            rt.r[0] = abi.read32(0x0802FF48);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[4], 0xC0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 7);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x0802FF4C);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.write32(rt.r[2] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 9;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            continue :blk 8;
        },
        8 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802FF50);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            continue :blk 6;
        },
        9 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5 });
            continue :blk 10;
        },
        10 => {
            abi.fetches(3);
            popRegsSeq(&.{ 1 });
            continue :blk 11;
        },
        11 => {
            abi.fetches(3);
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_0802FEF8() callconv(.c) void {
    if (!abi.enter(0x0802FEF8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.r[0] = abi.read16(rt.r[0] +% 0x4);
            rt.r[0] = ~rt.r[0]; rt.updateNz(rt.r[0]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0802FF44);
            rt.r[0] = abi.read32(0x0802FF48);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[4], 0xC0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 7);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x0802FF4C);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.write32(rt.r[2] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802FF50);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            continue :blk 5;
        },
        8 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5 });
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            popRegsSeq(&.{ 1 });
            continue :blk 10;
        },
        10 => {
            abi.fetches(3);
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_0802FEFA() callconv(.c) void {
    if (!abi.enter(0x0802FEFA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            rt.r[0] = abi.read16(rt.r[0] +% 0x4);
            rt.r[0] = ~rt.r[0]; rt.updateNz(rt.r[0]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0802FF44);
            rt.r[0] = abi.read32(0x0802FF48);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[4], 0xC0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 7);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x0802FF4C);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.write32(rt.r[2] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802FF50);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            continue :blk 4;
        },
        7 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5 });
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            popRegsSeq(&.{ 1 });
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_08030034() callconv(.c) void {
    if (!abi.enter(0x08030034)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(0x08030090);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08030094);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08030090);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08030094);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08030090);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08030094);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08030090);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08030094);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08030010, 0x08030089)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(4);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            continue :blk 15;
        },
        15 => {
            abi.fetches(3);
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080302B8() callconv(.c) void {
    if (!abi.enter(0x080302B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080302F0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xC0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080302F4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x080303DC);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080302F8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0xA);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08030098, 0x080302DD)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08030302() callconv(.c) void {
    if (!abi.enter(0x08030302)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            rt.r[4] = abi.read32(0x08030354);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x6, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08030C28, 0x0803030F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x6);
            rt.r[0] = abi.read32(0x08030358);
            abi.write16(rt.r[1] +% 0x6, @truncate(rt.r[0]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[5] = abi.read32(0x08030354);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x0, true);
            rt.r[3] = rt.r[13];
            continue :blk 3;
        },
        3 => {
            abi.fetches(16);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[4] << 1);
            rt.r[0] = abi.read8(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x4);
            abi.write8(rt.r[1] +% 0x4, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x3F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.r[2] = abi.read8(rt.r[1] +% 0x4);
            abi.write8(rt.r[1] +% 0x4, @truncate(rt.r[0]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x080303DC);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.r[13] +%= 0xC;
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

fn func_080307C8() callconv(.c) void {
    if (!abi.enter(0x080307C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 14 });
            rt.r[1] = abi.read32(0x080307F8);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read16(rt.r[3] +% 0x2);
            rt.r[0] = abi.read16(rt.r[3] +% 0x2);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[3] +% 0x2, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[4], 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1F);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x1F, @truncate(rt.r[1]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x080307FC);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1F);
            rt.cpuSub(null, rt.r[0], 0xA, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read8(rt.r[3] +% 0x1F);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read8(rt.r[3] +% 0x1F);
            abi.write8(rt.r[3] +% 0x1F, @truncate(rt.r[0]));
            continue :blk 3;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_0803085C() callconv(.c) void {
    if (!abi.enter(0x0803085C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[4] = abi.read32(0x080308A0);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0xA, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x5, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x9);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x9);
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 10;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x9);
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        11 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x4, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 7;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 10;
        },
        else => unreachable,
    }
}

fn func_080308BC() callconv(.c) void {
    if (!abi.enter(0x080308BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[5], 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            if (!abi.call(decls.func_0803083C, 0x080308CB)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[5] << 24);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 17);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[5] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_080308EC() callconv(.c) void {
    if (!abi.enter(0x080308EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0803092C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x7, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            if (!abi.call(decls.func_0803081C, 0x08030903)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0803092C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x7);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x7);
            abi.write8(rt.r[1] +% 0x7, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0803092C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_08030CE8() callconv(.c) void {
    if (!abi.enter(0x08030CE8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x08030D08);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[3], 0x2, true);
            rt.r[5] = abi.read32(0x08030D80);
            rt.r[2] = abi.read32(0x08030D84);
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x08030D0C);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            abi.write16(rt.r[3] +% 0x2, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x5);
            continue :blk 7;
        },
        5 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x08030D28);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[6], 0x0, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            abi.write16(rt.r[3] +% 0x2, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x2, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
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
            abi.fetches(6);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[5] = abi.read32(0x08030D88);
            rt.r[6] = abi.read32(0x08030D8C);
            rt.r[2] = abi.read32(0x08030D84);
            continue :blk 9;
        },
        9 => {
            abi.fetches(23);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08031488() callconv(.c) void {
    if (!abi.enter(0x08031488)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x080314E8);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x7);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_0801114C, 0x080314A7)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x080314EC);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = abi.read32(0x080314F0);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[3]);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(18);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = abi.read32(0x080314F4);
            abi.write16(rt.r[1] +% 0x6, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x5);
            abi.write8(rt.r[1] +% 0x5, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x4, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x080314EC);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080314F8() callconv(.c) void {
    if (!abi.enter(0x080314F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[5] = abi.read32(0x08031540);
            rt.cpuAdd(&rt.r[7], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[6], 0x82);
            abi.setRegNz(&rt.r[6], rt.r[6] << 2);
            continue :blk 1;
        },
        1 => {
            abi.fetches(17);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[6], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(16);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x5);
            abi.write8(rt.r[1] +% 0x5, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x5);
            abi.setRegNz(&rt.r[0], 0x3F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.r[2] = abi.read8(rt.r[1] +% 0x5);
            abi.write8(rt.r[1] +% 0x5, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08031880() callconv(.c) void {
    if (!abi.enter(0x08031880)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x080318E0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[4]));
            rt.r[2] = abi.read8(rt.r[0] +% 0x1);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[1]));
            if (!abi.call(decls.func_080305E4, 0x08031897)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x080318E4);
            abi.setRegNz(&rt.r[0], 0xA);
            abi.write16(rt.r[1] +% 0x6, @truncate(rt.r[0]));
            abi.write16(rt.r[1] +% 0xA, @truncate(rt.r[4]));
            rt.r[1] = abi.read32(0x080318E8);
            rt.r[0] = abi.read32(0x080318EC);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(0x080318F0);
            rt.r[2] = abi.read32(0x080318F4);
            abi.setRegNz(&rt.r[3], 0x3);
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(13);
            rt.r[2] = abi.read32(0x080318E0);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x6);
            abi.write16(rt.r[1] +% 0x4, @truncate(rt.r[0]));
            if (!abi.call(decls.func_0803D920, 0x080318D3)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xCE);
            if (!abi.call(decls.func_0803D8C8, 0x080318D9)) return;
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

fn func_080318F8() callconv(.c) void {
    if (!abi.enter(0x080318F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0803194C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x4, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[2]));
            if (!abi.call(decls.func_080303E0, 0x0803190F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x08031950);
            abi.setRegNz(&rt.r[0], 0x88);
            abi.write16(rt.r[1] +% 0xA, @truncate(rt.r[0]));
            abi.write16(rt.r[1] +% 0x6, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08031954);
            rt.r[0] = abi.read32(0x08031958);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(0x0803195C);
            rt.r[2] = abi.read32(0x08031960);
            abi.setRegNz(&rt.r[3], 0x3);
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.r[2] = abi.read32(0x0803194C);
            continue :blk 4;
        },
        4 => {
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
        },
        else => unreachable,
    }
}

fn func_08031964() callconv(.c) void {
    if (!abi.enter(0x08031964)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x080319BC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x4, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[2]));
            if (!abi.call(decls.func_080303E0, 0x0803197B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803D968, 0x0803197F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x080319C0);
            abi.setRegNz(&rt.r[0], 0x26);
            abi.write16(rt.r[1] +% 0xA, @truncate(rt.r[0]));
            abi.write16(rt.r[1] +% 0x6, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080319C4);
            rt.r[0] = abi.read32(0x080319C8);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(0x080319CC);
            rt.r[2] = abi.read32(0x080319D0);
            abi.setRegNz(&rt.r[3], 0x3);
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(14);
            rt.r[2] = abi.read32(0x080319BC);
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
        },
        else => unreachable,
    }
}

fn func_080319D4() callconv(.c) void {
    if (!abi.enter(0x080319D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x4;
            rt.r[1] = abi.read32(0x08031A34);
            rt.r[0] = rt.r[13];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08031A38);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            if (!abi.call(decls.func_080305E4, 0x080319EF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x08031A3C);
            abi.setRegNz(&rt.r[0], 0xA);
            abi.write16(rt.r[1] +% 0x6, @truncate(rt.r[0]));
            abi.write16(rt.r[1] +% 0xA, @truncate(rt.r[4]));
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08030C28, 0x080319FF)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x08031A40);
            rt.r[0] = abi.read32(0x08031A44);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(0x08031A48);
            rt.r[2] = abi.read32(0x08031A4C);
            abi.setRegNz(&rt.r[3], 0x3);
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08031A50);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x08031A54);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08031A58() callconv(.c) void {
    if (!abi.enter(0x08031A58)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x4;
            rt.r[1] = abi.read32(0x08031AAC);
            rt.r[0] = rt.r[13];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x08031AB0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08030C28, 0x08031A75)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x08031AB4);
            rt.r[0] = abi.read32(0x08031AB8);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(0x08031ABC);
            rt.r[2] = abi.read32(0x08031AC0);
            abi.setRegNz(&rt.r[3], 0x3);
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(15);
            rt.r[3] = abi.read32(0x08031AC4);
            rt.r[2] = abi.read32(0x08031AC8);
            rt.r[1] = abi.read32(0x08031ACC);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08031AD0() callconv(.c) void {
    if (!abi.enter(0x08031AD0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08031B18);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08031B1C);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0x96);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x3F, true);
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
            abi.fetches(21);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0x98);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write32(rt.r[4] +% 0x0, rt.r[0]);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            abi.setRegNz(&rt.r[1], 0x96);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
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

fn func_08031B28() callconv(.c) void {
    if (!abi.enter(0x08031B28)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(28);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[3] = abi.read32(0x08031B94);
            rt.r[2] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read32(0x08031B98);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = abi.read32(0x08031B9C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[4] +% 0x1);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x2);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x4);
            abi.write16(rt.r[1] +% 0x4, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[3], 0x0, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x4);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(19);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.r[2] = abi.read32(0x08031B98);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x6, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x6, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x4);
            rt.cpuSub(null, rt.r[2], rt.r[1], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08031BA0() callconv(.c) void {
    if (!abi.enter(0x08031BA0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(33);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.r[3] = abi.read32(0x08031C14);
            rt.r[2] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read32(0x08031C18);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            abi.setRegNz(&rt.r[1], 0x96);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x3F);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x6);
            abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x20);
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x14);
            abi.write16(rt.r[2] +% 0x4, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x20);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[4] = abi.read16(rt.r[1] +% 0x20);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x6, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x13, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(19);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[2] = abi.read32(0x08031C18);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08031C1C() callconv(.c) void {
    if (!abi.enter(0x08031C1C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(33);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[3] = abi.read32(0x08031C90);
            rt.r[2] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read32(0x08031C94);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            abi.setRegNz(&rt.r[1], 0x96);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x3F);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x6);
            abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x20);
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x80);
            abi.write16(rt.r[2] +% 0x4, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x20);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[4] = abi.read16(rt.r[1] +% 0x20);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x6, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(19);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.r[2] = abi.read32(0x08031C94);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08031E16() callconv(.c) void {
    if (!abi.enter(0x08031E16)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], rt.r[0] << 8);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x6, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(12);
            rt.r[0] = rt.r[8];
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(27);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[5] +% 0x1);
            rt.r[3] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x24, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[4] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.r[4] = abi.read32(0x08031E6C);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[1]));
            rt.r[2] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[4], true);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[3]);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_08031E18() callconv(.c) void {
    if (!abi.enter(0x08031E18)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x6, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            rt.r[0] = rt.r[8];
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(27);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[5] +% 0x1);
            rt.r[3] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x24, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[4] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.r[4] = abi.read32(0x08031E6C);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[1]));
            rt.r[2] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[4], true);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[3]);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_08031E1A() callconv(.c) void {
    if (!abi.enter(0x08031E1A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x6, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.r[0] = rt.r[8];
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(27);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[5] +% 0x1);
            rt.r[3] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x24, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[4] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.r[4] = abi.read32(0x08031E6C);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[1]));
            rt.r[2] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[4], true);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[3]);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_08031E70() callconv(.c) void {
    if (!abi.enter(0x08031E70)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[4], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 24));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xA, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 19);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[5] = abi.read32(0x08031EB0);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x16, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xA0);
            if (!abi.call(func_0802C11C, 0x08031E91)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[4] >> 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 24));
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[2] = abi.read8(rt.r[0] +% 0x1B);
            abi.setRegNz(&rt.r[0], 0xA0);
            abi.setRegNz(&rt.r[1], 0x78);
            if (!abi.call(func_0802C11C, 0x08031EA9)) return;
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

fn func_08031EE8() callconv(.c) void {
    if (!abi.enter(0x08031EE8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_08031F38, 0x08031EEF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[3], 0x1, true);
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
            abi.fetches(21);
            rt.r[2] = abi.read32(0x08031F28);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1E);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x1E, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write16(rt.r[1] +% 0x4, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x5);
            abi.write16(rt.r[1] +% 0x4, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08031F2C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(0x08031F30);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08030C28, 0x08031F1D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08031F34);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08031F25)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08031FA0() callconv(.c) void {
    if (!abi.enter(0x08031FA0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[0] = abi.read32(0x08031FB8);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x1E);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0xF, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[3] = abi.read32(0x08031FF8);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x6, true);
            rt.r[4] = abi.read32(0x08031FFC);
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x1E);
            abi.write8(rt.r[2] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0xC, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[0], 0x2C);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x6);
            abi.write8(rt.r[3] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write16(rt.r[3] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1A);
            if (!abi.call(decls.func_0803093C, 0x08031FEB)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1E);
            abi.write8(rt.r[0] +% 0x1E, @truncate(rt.r[4]));
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08032000() callconv(.c) void {
    if (!abi.enter(0x08032000)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[5] = abi.read32(0x08032020);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            if (!abi.call(decls.func_0803081C, 0x0803200F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x3, true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[5], true);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0803204C);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x08032050);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x39, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08032054() callconv(.c) void {
    if (!abi.enter(0x08032054)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[1] = abi.read32(0x080320CC);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read8(rt.r[0] +% 0x6);
            rt.r[3] = abi.read32(0x080320D0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[3] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read32(0x080320D4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read32(0x080320D8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            if (!abi.call(decls.func_0803081C, 0x08032087)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[3], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(15);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read32(0x080320D4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read32(0x080320D8);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.armLsl(rt.r[1], rt.r[4] & 0xFF));
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            continue :blk 4;
        },
        6 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x080320CC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x080320DC);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read32(0x080320E0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080320A8() callconv(.c) void {
    if (!abi.enter(0x080320A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x080320CC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x080320DC);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read32(0x080320E0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            if (!abi.call(decls.func_0803081C, 0x08032087)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[3], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(15);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read32(0x080320D4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read32(0x080320D8);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.armLsl(rt.r[1], rt.r[4] & 0xFF));
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            continue :blk 0;
        },
        else => unreachable,
    }
}

fn func_08032988() callconv(.c) void {
    if (!abi.enter(0x08032988)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x080329E4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080329E8);
            if (!abi.call(decls.func_08013B70, 0x08032997)) return;
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
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080329F0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080329EC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x080329AB)) return;
            continue :blk 2;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x66);
            if (!abi.call(decls.func_0803D880, 0x080329BF)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(9);
            rt.r[4] = abi.read32(0x080329F4);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(func_08032B34, 0x080329D9)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080329EC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x080329CB)) return;
            continue :blk 5;
        },
        7 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08032B34() callconv(.c) void {
    if (!abi.enter(0x08032B34)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x8;
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[6], rt.r[2] >> 16);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080124D4, 0x08032B4B)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(14);
            rt.r[4] = abi.read32(0x08032B90);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0xBA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x3);
            abi.setRegNz(&rt.r[2], 0x11);
            abi.setRegNz(&rt.r[3], 0x1A);
            if (!abi.call(decls.func_08010C70, 0x08032B63)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(17);
            rt.r[1] = abi.read32(0x08032B94);
            abi.setRegNz(&rt.r[0], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xC0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 6);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x98);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.setRegNz(&rt.r[1], 0x11);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080123A8, 0x08032B81)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3A, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08032E78() callconv(.c) void {
    if (!abi.enter(0x08032E78)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.r[1] = abi.read32(0x08032ECC);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            if (!abi.call(decls.func_0803081C, 0x08032E8B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08032ED0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xA, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08032ED4);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08032D68, 0x08032EB3)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            rt.r[4] = abi.read32(0x08032ED8);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x3);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(func_08032B34, 0x08032EC1)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08032EDC() callconv(.c) void {
    if (!abi.enter(0x08032EDC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08032F1C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08032F20);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08032F28);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x08032F2C);
            rt.r[2] = abi.read8(rt.r[0] +% 0x9);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08032F24);
            abi.setRegNz(&rt.r[1], 0x3B);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x08032F28);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x6);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[1], 0x84);
            if (!abi.call(decls.func_0803093C, 0x08032F09)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        4 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x08032F44);
            rt.r[0] = abi.read32(0x08032F48);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08032F4C);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
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

fn func_08032F50() callconv(.c) void {
    if (!abi.enter(0x08032F50)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x08032F9C);
            rt.r[5] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[0]);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08032FA4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x08032FAC);
            rt.r[2] = abi.read8(rt.r[0] +% 0x9);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08032FA0);
            abi.setRegNz(&rt.r[1], 0x3B);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[4] = abi.read32(0x08032FA4);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x6);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[5]));
            abi.setRegNz(&rt.r[1], 0x84);
            if (!abi.call(decls.func_0803093C, 0x08032F75)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 6;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08032FC0);
            rt.r[1] = abi.read32(0x08032FC4);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 6;
        },
        5 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x08032FA8);
            abi.setRegNz(&rt.r[1], 0x3A);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x6);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[5]));
            abi.setRegNz(&rt.r[1], 0x4);
            if (!abi.call(decls.func_0803093C, 0x08032F89)) return;
            continue :blk 1;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_080330AC() callconv(.c) void {
    if (!abi.enter(0x080330AC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x080330DC);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x6);
            rt.r[0] = abi.read32(0x080330E0);
            abi.write16(rt.r[1] +% 0x6, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080330E4);
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
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read32(0x080330E8);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x68);
            if (!abi.call(decls.func_0803D880, 0x080330CD)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x08033100);
            rt.r[0] = abi.read32(0x08033104);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
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

fn func_08033188() callconv(.c) void {
    if (!abi.enter(0x08033188)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[6] = abi.read32(0x08033200);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_0807B634, 0x08033197)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.r[2] = abi.read32(0x08033204);
            rt.r[5] = abi.read32(0x08033208);
            abi.setRegNz(&rt.r[0], 0x66);
            abi.setRegNz(&rt.r[1], 0x38);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x080331A9)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0xA, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0803320C);
            abi.setRegNz(&rt.r[1], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x6E);
            abi.setRegNz(&rt.r[1], 0x38);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x080331BF)) return;
            continue :blk 3;
        },
        5 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[4] << 19);
            abi.setRegNz(&rt.r[1], 0xDC);
            abi.setRegNz(&rt.r[1], rt.r[1] << 15);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read32(0x08033210);
            abi.setRegNz(&rt.r[1], 0xA);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x38);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x080331E1)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.r[2] = abi.read32(0x08033214);
            abi.setRegNz(&rt.r[0], 0xBE);
            abi.setRegNz(&rt.r[1], 0x38);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x080331ED)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[2] = abi.read16(rt.r[0] +% 0xA);
            rt.r[3] = abi.read32(0x08033218);
            abi.setRegNz(&rt.r[0], 0xA0);
            abi.setRegNz(&rt.r[1], 0x20);
            if (!abi.call(decls.func_08038D0C, 0x080331FB)) return;
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

fn func_0803329C() callconv(.c) void {
    if (!abi.enter(0x0803329C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x080332F0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0xA);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x64, true);
            abi.write16(rt.r[2] +% 0x22, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[4] = abi.read16(rt.r[2] +% 0x1E);
            abi.setRegNz(&rt.r[1], rt.r[4] << 16);
            rt.r[3] = abi.read32(0x080332F4);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], 0x1E);
            rt.r[5] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[6] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            rt.r[4] = abi.read32(0x080332F8);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 3);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_0807B6AC, 0x080332D9)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read32(0x080332FC);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x080332E9)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.write16(rt.r[2] +% 0x1E, @truncate(rt.r[0]));
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

fn func_08033510() callconv(.c) void {
    if (!abi.enter(0x08033510)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            if (!abi.call(decls.func_0803081C, 0x0803351F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuAdd(&rt.r[7], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[5], 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.r[2] = abi.read32(0x08033568);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read32(0x0803356C);
            rt.cpuAdd(&rt.r[3], rt.r[4], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x35, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[7], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x1, true);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read8(rt.r[3] +% 0x0);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x20, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            rt.cpuSub(null, rt.r[5], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        9 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08033570);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0803365C() callconv(.c) void {
    if (!abi.enter(0x0803365C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[3] = abi.read32(0x080336C0);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x7, true);
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
            abi.fetches(32);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write16(rt.r[1] +% 0x4, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x6);
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.write8(rt.r[1] +% 0x6, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x7);
            abi.write8(rt.r[0] +% 0x7, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x8);
            abi.write8(rt.r[0] +% 0x8, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x9);
            abi.write8(rt.r[0] +% 0x9, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1C);
            abi.write8(rt.r[0] +% 0x1C, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1D);
            abi.write8(rt.r[0] +% 0x1D, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1E);
            abi.write8(rt.r[0] +% 0x1E, @truncate(rt.r[2]));
            if (!abi.call(decls.func_080305E4, 0x080336A5)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080303E0, 0x080336A9)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08030634, 0x080336AD)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x080336C4);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080336C8);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_080336CC() callconv(.c) void {
    if (!abi.enter(0x080336CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[13] -%= 0x8;
            rt.r[0] = abi.read32(0x08033744);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            rt.r[1] = abi.read32(0x08033748);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.setRegNz(&rt.r[2], 0x5);
            abi.setRegNz(&rt.r[3], 0xC);
            if (!abi.call(decls.func_08010C70, 0x080336E5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(16);
            rt.r[5] = abi.read32(0x0803374C);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[3] = abi.read8(rt.r[0] +% 0x7);
            abi.setRegNz(&rt.r[3], rt.r[3] << 24);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[3], 7));
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 10);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[3], 16));
            abi.setRegNz(&rt.r[0], 0xA);
            abi.setRegNz(&rt.r[1], 0x5);
            abi.setRegNz(&rt.r[2], 0xC);
            if (!abi.call(decls.func_080197D8, 0x08033701)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_08032240, 0x08033707)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[4] = abi.read32(0x08033750);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x4);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(func_08032B34, 0x08033715)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(15);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[2], 0x1);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[2]));
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xA, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08033754);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(0x08033758);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0803373B)) return;
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803375C() callconv(.c) void {
    if (!abi.enter(0x0803375C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x0803379C);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
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
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x9);
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
            abi.setRegNz(&rt.r[0], 0x68);
            if (!abi.call(decls.func_0803D880, 0x08033773)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080337A0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x4);
            abi.write8(rt.r[1] +% 0x9, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x71);
            if (!abi.call(decls.func_0803D880, 0x0803378D)) return;
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
            rt.r[0] = abi.read32(0x080337A4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08033795)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08033878() callconv(.c) void {
    if (!abi.enter(0x08033878)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x080338B0);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0xA, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[4], 0x3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            if (!abi.call(decls.func_0803081C, 0x0803388D)) return;
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
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080338B4);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080338B0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write16(rt.r[0] +% 0x6, @truncate(rt.r[4]));
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[4]));
            continue :blk 4;
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

fn func_08033A60() callconv(.c) void {
    if (!abi.enter(0x08033A60)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[3] = abi.read32(0x08033AA4);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.write16(rt.r[1] +% 0xA, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(rt.r[3] +% 0x0);
            rt.r[4] = abi.read8(rt.r[2] +% 0x10);
            rt.cpuSub(null, rt.r[4], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08033AA8);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1E);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.write16(rt.r[1] +% 0xE, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08033AA8);
            rt.r[4] = abi.read16(rt.r[2] +% 0xA);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x08033AAC);
            rt.r[2] = abi.read32(0x08033AB0);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08033AB4);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0xE);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x60, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08033AB8() callconv(.c) void {
    if (!abi.enter(0x08033AB8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.r[3] = abi.read32(0x08033B18);
            rt.r[2] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[2] +% 0xA);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0xA, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[2] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read8(rt.r[2] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08033B1C);
            rt.r[4] = abi.read16(rt.r[2] +% 0xA);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], 0, rt.r[1], true);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08033B1C);
            rt.r[4] = abi.read16(rt.r[2] +% 0xA);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x08033B20);
            rt.r[2] = abi.read32(0x08033B24);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x08033B28);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0xE);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x60, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0xA);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x76);
            if (!abi.call(decls.func_0803D880, 0x08033B0B)) return;
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
            rt.r[0] = abi.read32(0x08033B2C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08033B13)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_08033B30() callconv(.c) void {
    if (!abi.enter(0x08033B30)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[3] = abi.read32(0x08033B74);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0xA, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(rt.r[3] +% 0x0);
            rt.r[4] = abi.read8(rt.r[2] +% 0x10);
            rt.cpuSub(null, rt.r[4], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08033B78);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[1] +% 0xE, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08033B78);
            rt.r[4] = abi.read16(rt.r[2] +% 0xA);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], 0, rt.r[1], true);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x08033B7C);
            rt.r[2] = abi.read32(0x08033B80);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08033B84);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0xE);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x60, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08033B88() callconv(.c) void {
    if (!abi.enter(0x08033B88)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.r[3] = abi.read32(0x08033BE4);
            rt.r[2] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[2] +% 0xA);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0xA, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[2] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read8(rt.r[2] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08033BE8);
            rt.r[4] = abi.read16(rt.r[2] +% 0xA);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08033BE8);
            rt.r[4] = abi.read16(rt.r[2] +% 0xA);
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], 0, rt.r[1], true);
            abi.write16(rt.r[2] +% 0xE, @truncate(rt.r[0]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x08033BEC);
            rt.r[2] = abi.read32(0x08033BF0);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x08033BF4);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0xE);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x60, true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[1] +% 0xA);
            rt.cpuSub(null, rt.r[1], 0xF, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08033BF8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08033BDD)) return;
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

fn func_08033BFC() callconv(.c) void {
    if (!abi.enter(0x08033BFC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x8;
            rt.r[4] = abi.read32(0x08033C80);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x4);
            if (!abi.call(decls.func_0803F158, 0x08033C0B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[7], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(14);
            rt.r[5] = abi.read32(0x08033C84);
            abi.setRegNz(&rt.r[0], 0x14);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[6], 0xBA);
            abi.setRegNz(&rt.r[6], rt.r[6] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[6]);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x20);
            if (!abi.call(decls.func_08010C70, 0x08033C2B)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x9);
            rt.r[0] = abi.read32(0x08033C88);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.write32(rt.r[13] +% 0x4, rt.r[6]);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x3);
            abi.setRegNz(&rt.r[2], 0x4);
            abi.setRegNz(&rt.r[3], 0x9);
            if (!abi.call(decls.func_08010C70, 0x08033C4F)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011814, 0x08033C77)) return;
            continue :blk 2;
        },
        7 => {
            abi.fetches(20);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[3], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 2);
            rt.cpuSub(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read32(0x08033C8C);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.write32(rt.r[13] +% 0x4, rt.r[7]);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.setRegNz(&rt.r[1], 0x4);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08012A68, 0x08033C73)) return;
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_08034490() callconv(.c) void {
    if (!abi.enter(0x08034490)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = abi.read32(0x08034504);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[7] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.r[0] = abi.read32(0x08034508);
            rt.cpuAdd(&rt.r[4], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read32(rt.r[4] +% 0x20);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0803450C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807B450, 0x080344AF)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(9);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2C);
            rt.r[6] = abi.read32(0x08034510);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x22);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x80, true);
            abi.write32(rt.r[4] +% 0x24, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x64);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            if (!abi.call(decls.func_0807B488, 0x080344D7)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            if (!abi.call(func_08031C1C, 0x080344E9)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2F, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x2C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x2C, @truncate(rt.r[0]));
            continue :blk 6;
        },
        8 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1D);
            abi.write8(rt.r[0] +% 0x1D, @truncate(rt.r[5]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x2C);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_C) {
                continue :blk 4;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[7] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x080344FD)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08034554() callconv(.c) void {
    if (!abi.enter(0x08034554)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x08034580);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x08034584);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            rt.r[5] = abi.read32(0x08034588);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08031C98, 0x0803456F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
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
            abi.fetches(16);
            rt.r[1] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x28, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read8(rt.r[5] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            rt.r[1] = abi.read8(rt.r[5] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            rt.r[1] = abi.read8(rt.r[5] +% 0x3);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2E, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_08034678() callconv(.c) void {
    if (!abi.enter(0x08034678)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            rt.r[8] = rt.r[2];
            abi.setRegNz(&rt.r[3], rt.r[3] << 24);
            abi.setRegNz(&rt.r[6], rt.r[3] >> 24);
            rt.r[0] = abi.read32(0x08034694);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 7);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[4], 0x7F);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[1]);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080346E0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x080346B7)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(18);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.write32(rt.r[2] +% 0x24, rt.r[7]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x28, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.r[0] = rt.r[8];
            abi.write32(rt.r[2] +% 0x20, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[2] +% 0x2A, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2E, true);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            abi.write16(rt.r[2] +% 0x2C, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0803487C() callconv(.c) void {
    if (!abi.enter(0x0803487C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[6], 0xFF);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 4);
            rt.cpuSub(null, rt.r[2], 0xF, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[6]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            abi.setRegNz(&rt.r[2], 0xF);
            rt.r[7] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[7]);
            rt.cpuSub(null, rt.r[2], 0xF, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[6]));
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[2]));
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x5, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
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

fn func_08034B50() callconv(.c) void {
    if (!abi.enter(0x08034B50)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_08034BA8, 0x08034B57)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(0x08034B64);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[2] +% 0x9, @truncate(rt.r[0]));
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08034BA0);
            rt.r[1] = abi.read32(0x08034BA4);
            rt.r[1] = abi.read16(rt.r[1] +% 0x1A);
            abi.write8(rt.r[0] +% 0x9, @truncate(rt.r[1]));
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(18);
            rt.r[0] = abi.read32(0x08034B90);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1A);
            abi.write8(rt.r[2] +% 0x9, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x39, true);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3A, true);
            abi.setRegNz(&rt.r[1], 0x2);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0803502C() callconv(.c) void {
    if (!abi.enter(0x0803502C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(func_08026FC8, 0x08035035)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            rt.r[2] = abi.read32(0x08035054);
            rt.r[0] = abi.read32(0x08035058);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1B);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x5, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
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
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x0803505C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08035078 => continue :blk 4,
                0x08035084 => continue :blk 5,
                0x080350B0 => continue :blk 6,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        4 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08035080);
            abi.setRegNz(&rt.r[0], 0x5);
            continue :blk 7;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080350A4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(0x080350BC);
            abi.setRegNz(&rt.r[0], 0x10);
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080308AC, 0x08035093)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x080350A8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080350AC);
            abi.setRegNz(&rt.r[0], 0x6);
            continue :blk 7;
        },
        10 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_08035274() callconv(.c) void {
    if (!abi.enter(0x08035274)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x080352AC);
            rt.cpuSub(null, rt.r[4], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x080352B0);
            abi.setRegNz(&rt.r[2], 0xE0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 4);
            if (!abi.call(decls.func_0800FDA4, 0x08035293)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0xE0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x080352B4);
            abi.setRegNz(&rt.r[0], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_08011330, 0x080352A5)) return;
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

fn func_080352EC() callconv(.c) void {
    if (!abi.enter(0x080352EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[2] = abi.read32(0x08035308);
            rt.r[0] = abi.read32(0x0803530C);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x3, true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[4], 0x1);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
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
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803533C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            continue :blk 1;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08024CD0, 0x08035329)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[6], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08035348() callconv(.c) void {
    if (!abi.enter(0x08035348)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[4], 0x1);
            rt.r[6] = abi.read32(0x0803537C);
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08024CD0, 0x08035357)) return;
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
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08035380);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[6], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.r[1] = abi.read32(0x08035384);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x1E);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08035834() callconv(.c) void {
    if (!abi.enter(0x08035834)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x0803587C);
            rt.r[1] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            continue :blk 5;
        },
        3 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[1], rt.r[4] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[5] << 4);
            abi.write16(rt.r[1] +% 0x14, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[6] << 4);
            abi.write16(rt.r[1] +% 0x16, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write8(rt.r[1] +% 0x8, @truncate(rt.r[0]));
            abi.write8(rt.r[1] +% 0x9, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(0x08035880);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08035875)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x20, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x2, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[4]));
            continue :blk 4;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08035BE0() callconv(.c) void {
    if (!abi.enter(0x08035BE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08035C28);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x16);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[1]));
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 4));
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[4] = abi.read32(0x08035C2C);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x14);
            rt.r[2] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xF, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read32(0x08035C30);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_08035D64() callconv(.c) void {
    if (!abi.enter(0x08035D64)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x1E);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            rt.r[0] = abi.read32(0x08035DA0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(12);
            rt.r[2] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x14, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(0x08035DA4);
            rt.cpuSub(&rt.r[2], 0, rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08079244, 0x08035D8B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[4] +% 0x8, rt.r[0]);
            continue :blk 1;
        },
        3 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08035DA8);
            rt.r[4] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuSub(&rt.r[2], 0, rt.r[4], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08079244, 0x08035D9B)) return;
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

fn func_08035DD0() callconv(.c) void {
    if (!abi.enter(0x08035DD0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = abi.read32(0x08035E20);
            rt.r[2] = abi.read8(rt.r[3] +% 0x9);
            abi.setRegNz(&rt.r[1], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            rt.r[6] = abi.read16(rt.r[1] +% 0x1E);
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], 0x1);
            rt.r[0] = abi.read8(rt.r[3] +% 0xC);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[0]);
            continue :blk 1;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0x1A);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[5], 0x2);
            continue :blk 4;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0x1A);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_08035C54, 0x08035E0B)) return;
            continue :blk 10;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        9 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x1A);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(decls.func_0803D830, 0x08035E33)) return;
            continue :blk 8;
        },
        10 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            if (!abi.call(decls.func_0803D830, 0x08035E1F)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(3);
            continue :blk 8;
        },
        else => unreachable,
    }
}

comptime {
    if (!builtin.is_test) {
        @export(&func_0801FCF8, .{ .name = "func_0801FCF8", .linkage = .strong });
        @export(&func_0801FEFC, .{ .name = "func_0801FEFC", .linkage = .strong });
        @export(&func_0801FF08, .{ .name = "func_0801FF08", .linkage = .strong });
        @export(&func_0801FF70, .{ .name = "func_0801FF70", .linkage = .strong });
        @export(&func_080200FA, .{ .name = "func_080200FA", .linkage = .strong });
        @export(&func_080200FC, .{ .name = "func_080200FC", .linkage = .strong });
        @export(&func_080200FE, .{ .name = "func_080200FE", .linkage = .strong });
        @export(&func_08020100, .{ .name = "func_08020100", .linkage = .strong });
        @export(&func_0802010A, .{ .name = "func_0802010A", .linkage = .strong });
        @export(&func_08020190, .{ .name = "func_08020190", .linkage = .strong });
        @export(&func_080202C0, .{ .name = "func_080202C0", .linkage = .strong });
        @export(&func_08020380, .{ .name = "func_08020380", .linkage = .strong });
        @export(&func_080206F0, .{ .name = "func_080206F0", .linkage = .strong });
        @export(&func_08020700, .{ .name = "func_08020700", .linkage = .strong });
        @export(&func_080207EE, .{ .name = "func_080207EE", .linkage = .strong });
        @export(&func_08020B48, .{ .name = "func_08020B48", .linkage = .strong });
        @export(&func_080212F4, .{ .name = "func_080212F4", .linkage = .strong });
        @export(&func_08021794, .{ .name = "func_08021794", .linkage = .strong });
        @export(&func_080217C8, .{ .name = "func_080217C8", .linkage = .strong });
        @export(&func_080217FC, .{ .name = "func_080217FC", .linkage = .strong });
        @export(&func_08021824, .{ .name = "func_08021824", .linkage = .strong });
        @export(&func_0802184C, .{ .name = "func_0802184C", .linkage = .strong });
        @export(&func_08021894, .{ .name = "func_08021894", .linkage = .strong });
        @export(&func_080218DC, .{ .name = "func_080218DC", .linkage = .strong });
        @export(&func_08021924, .{ .name = "func_08021924", .linkage = .strong });
        @export(&func_08021E40, .{ .name = "func_08021E40", .linkage = .strong });
        @export(&func_08021FC8, .{ .name = "func_08021FC8", .linkage = .strong });
        @export(&func_080225C0, .{ .name = "func_080225C0", .linkage = .strong });
        @export(&func_08022640, .{ .name = "func_08022640", .linkage = .strong });
        @export(&func_0802292C, .{ .name = "func_0802292C", .linkage = .strong });
        @export(&func_08023BA0, .{ .name = "func_08023BA0", .linkage = .strong });
        @export(&func_08023D54, .{ .name = "func_08023D54", .linkage = .strong });
        @export(&func_080241DC, .{ .name = "func_080241DC", .linkage = .strong });
        @export(&func_0802425C, .{ .name = "func_0802425C", .linkage = .strong });
        @export(&func_08024544, .{ .name = "func_08024544", .linkage = .strong });
        @export(&func_08024594, .{ .name = "func_08024594", .linkage = .strong });
        @export(&func_08024614, .{ .name = "func_08024614", .linkage = .strong });
        @export(&func_08024774, .{ .name = "func_08024774", .linkage = .strong });
        @export(&func_080247A4, .{ .name = "func_080247A4", .linkage = .strong });
        @export(&func_080248E8, .{ .name = "func_080248E8", .linkage = .strong });
        @export(&func_08024AE0, .{ .name = "func_08024AE0", .linkage = .strong });
        @export(&func_08024D20, .{ .name = "func_08024D20", .linkage = .strong });
        @export(&func_08025000, .{ .name = "func_08025000", .linkage = .strong });
        @export(&func_08025024, .{ .name = "func_08025024", .linkage = .strong });
        @export(&func_08025564, .{ .name = "func_08025564", .linkage = .strong });
        @export(&func_080255EC, .{ .name = "func_080255EC", .linkage = .strong });
        @export(&func_08025944, .{ .name = "func_08025944", .linkage = .strong });
        @export(&func_080259C4, .{ .name = "func_080259C4", .linkage = .strong });
        @export(&func_08025A34, .{ .name = "func_08025A34", .linkage = .strong });
        @export(&func_08025B68, .{ .name = "func_08025B68", .linkage = .strong });
        @export(&func_08025C18, .{ .name = "func_08025C18", .linkage = .strong });
        @export(&func_08026060, .{ .name = "func_08026060", .linkage = .strong });
        @export(&func_080260CC, .{ .name = "func_080260CC", .linkage = .strong });
        @export(&func_08026374, .{ .name = "func_08026374", .linkage = .strong });
        @export(&func_08026400, .{ .name = "func_08026400", .linkage = .strong });
        @export(&func_08026750, .{ .name = "func_08026750", .linkage = .strong });
        @export(&func_080267C4, .{ .name = "func_080267C4", .linkage = .strong });
        @export(&func_08026824, .{ .name = "func_08026824", .linkage = .strong });
        @export(&func_08026934, .{ .name = "func_08026934", .linkage = .strong });
        @export(&func_080269A8, .{ .name = "func_080269A8", .linkage = .strong });
        @export(&func_08026B4C, .{ .name = "func_08026B4C", .linkage = .strong });
        @export(&func_08026E34, .{ .name = "func_08026E34", .linkage = .strong });
        @export(&func_08026E80, .{ .name = "func_08026E80", .linkage = .strong });
        @export(&func_08026EC8, .{ .name = "func_08026EC8", .linkage = .strong });
        @export(&func_08026F70, .{ .name = "func_08026F70", .linkage = .strong });
        @export(&func_08026FC8, .{ .name = "func_08026FC8", .linkage = .strong });
        @export(&func_0802759C, .{ .name = "func_0802759C", .linkage = .strong });
        @export(&func_080277DC, .{ .name = "func_080277DC", .linkage = .strong });
        @export(&func_08027850, .{ .name = "func_08027850", .linkage = .strong });
        @export(&func_080278E8, .{ .name = "func_080278E8", .linkage = .strong });
        @export(&func_08027970, .{ .name = "func_08027970", .linkage = .strong });
        @export(&func_080279B8, .{ .name = "func_080279B8", .linkage = .strong });
        @export(&func_08027A30, .{ .name = "func_08027A30", .linkage = .strong });
        @export(&func_08027B34, .{ .name = "func_08027B34", .linkage = .strong });
        @export(&func_08028664, .{ .name = "func_08028664", .linkage = .strong });
        @export(&func_08028734, .{ .name = "func_08028734", .linkage = .strong });
        @export(&func_080287A8, .{ .name = "func_080287A8", .linkage = .strong });
        @export(&func_080287E8, .{ .name = "func_080287E8", .linkage = .strong });
        @export(&func_08028A40, .{ .name = "func_08028A40", .linkage = .strong });
        @export(&func_08028B9C, .{ .name = "func_08028B9C", .linkage = .strong });
        @export(&func_080293F4, .{ .name = "func_080293F4", .linkage = .strong });
        @export(&func_08029654, .{ .name = "func_08029654", .linkage = .strong });
        @export(&func_0802979C, .{ .name = "func_0802979C", .linkage = .strong });
        @export(&func_08029810, .{ .name = "func_08029810", .linkage = .strong });
        @export(&func_08029884, .{ .name = "func_08029884", .linkage = .strong });
        @export(&func_08029F34, .{ .name = "func_08029F34", .linkage = .strong });
        @export(&func_08029F84, .{ .name = "func_08029F84", .linkage = .strong });
        @export(&func_0802A000, .{ .name = "func_0802A000", .linkage = .strong });
        @export(&func_0802A084, .{ .name = "func_0802A084", .linkage = .strong });
        @export(&func_0802A104, .{ .name = "func_0802A104", .linkage = .strong });
        @export(&func_0802A688, .{ .name = "func_0802A688", .linkage = .strong });
        @export(&func_0802A834, .{ .name = "func_0802A834", .linkage = .strong });
        @export(&func_0802AA3C, .{ .name = "func_0802AA3C", .linkage = .strong });
        @export(&func_0802AD0C, .{ .name = "func_0802AD0C", .linkage = .strong });
        @export(&func_0802BAA4, .{ .name = "func_0802BAA4", .linkage = .strong });
        @export(&func_0802BC50, .{ .name = "func_0802BC50", .linkage = .strong });
        @export(&func_0802C058, .{ .name = "func_0802C058", .linkage = .strong });
        @export(&func_0802C0C4, .{ .name = "func_0802C0C4", .linkage = .strong });
        @export(&func_0802C11C, .{ .name = "func_0802C11C", .linkage = .strong });
        @export(&func_0802C174, .{ .name = "func_0802C174", .linkage = .strong });
        @export(&func_0802C1E0, .{ .name = "func_0802C1E0", .linkage = .strong });
        @export(&func_0802C22C, .{ .name = "func_0802C22C", .linkage = .strong });
        @export(&func_0802C264, .{ .name = "func_0802C264", .linkage = .strong });
        @export(&func_0802C2BC, .{ .name = "func_0802C2BC", .linkage = .strong });
        @export(&func_0802C4C0, .{ .name = "func_0802C4C0", .linkage = .strong });
        @export(&func_0802C7AC, .{ .name = "func_0802C7AC", .linkage = .strong });
        @export(&func_0802C8F4, .{ .name = "func_0802C8F4", .linkage = .strong });
        @export(&func_0802C94C, .{ .name = "func_0802C94C", .linkage = .strong });
        @export(&func_0802CE68, .{ .name = "func_0802CE68", .linkage = .strong });
        @export(&func_0802D63C, .{ .name = "func_0802D63C", .linkage = .strong });
        @export(&func_0802D6BC, .{ .name = "func_0802D6BC", .linkage = .strong });
        @export(&func_0802D9D4, .{ .name = "func_0802D9D4", .linkage = .strong });
        @export(&func_0802DA6C, .{ .name = "func_0802DA6C", .linkage = .strong });
        @export(&func_0802DACC, .{ .name = "func_0802DACC", .linkage = .strong });
        @export(&func_0802DC3C, .{ .name = "func_0802DC3C", .linkage = .strong });
        @export(&func_0802DCC0, .{ .name = "func_0802DCC0", .linkage = .strong });
        @export(&func_0802DDFC, .{ .name = "func_0802DDFC", .linkage = .strong });
        @export(&func_0802DE4C, .{ .name = "func_0802DE4C", .linkage = .strong });
        @export(&func_0802DE88, .{ .name = "func_0802DE88", .linkage = .strong });
        @export(&func_0802DF58, .{ .name = "func_0802DF58", .linkage = .strong });
        @export(&func_0802E148, .{ .name = "func_0802E148", .linkage = .strong });
        @export(&func_0802E1B0, .{ .name = "func_0802E1B0", .linkage = .strong });
        @export(&func_0802E1F4, .{ .name = "func_0802E1F4", .linkage = .strong });
        @export(&func_0802E238, .{ .name = "func_0802E238", .linkage = .strong });
        @export(&func_0802E384, .{ .name = "func_0802E384", .linkage = .strong });
        @export(&func_0802E438, .{ .name = "func_0802E438", .linkage = .strong });
        @export(&func_0802E43C, .{ .name = "func_0802E43C", .linkage = .strong });
        @export(&func_0802E484, .{ .name = "func_0802E484", .linkage = .strong });
        @export(&func_0802E488, .{ .name = "func_0802E488", .linkage = .strong });
        @export(&func_0802E600, .{ .name = "func_0802E600", .linkage = .strong });
        @export(&func_0802E668, .{ .name = "func_0802E668", .linkage = .strong });
        @export(&func_0802E6BC, .{ .name = "func_0802E6BC", .linkage = .strong });
        @export(&func_0802E730, .{ .name = "func_0802E730", .linkage = .strong });
        @export(&func_0802E778, .{ .name = "func_0802E778", .linkage = .strong });
        @export(&func_0802E984, .{ .name = "func_0802E984", .linkage = .strong });
        @export(&func_0802ECDC, .{ .name = "func_0802ECDC", .linkage = .strong });
        @export(&func_0802ECE6, .{ .name = "func_0802ECE6", .linkage = .strong });
        @export(&func_0802EF60, .{ .name = "func_0802EF60", .linkage = .strong });
        @export(&func_0802F340, .{ .name = "func_0802F340", .linkage = .strong });
        @export(&func_0802F5EC, .{ .name = "func_0802F5EC", .linkage = .strong });
        @export(&func_0802F8F4, .{ .name = "func_0802F8F4", .linkage = .strong });
        @export(&func_0802F8F6, .{ .name = "func_0802F8F6", .linkage = .strong });
        @export(&func_0802F8F8, .{ .name = "func_0802F8F8", .linkage = .strong });
        @export(&func_0802FE08, .{ .name = "func_0802FE08", .linkage = .strong });
        @export(&func_0802FEF6, .{ .name = "func_0802FEF6", .linkage = .strong });
        @export(&func_0802FEF8, .{ .name = "func_0802FEF8", .linkage = .strong });
        @export(&func_0802FEFA, .{ .name = "func_0802FEFA", .linkage = .strong });
        @export(&func_08030034, .{ .name = "func_08030034", .linkage = .strong });
        @export(&func_080302B8, .{ .name = "func_080302B8", .linkage = .strong });
        @export(&func_08030302, .{ .name = "func_08030302", .linkage = .strong });
        @export(&func_080307C8, .{ .name = "func_080307C8", .linkage = .strong });
        @export(&func_0803085C, .{ .name = "func_0803085C", .linkage = .strong });
        @export(&func_080308BC, .{ .name = "func_080308BC", .linkage = .strong });
        @export(&func_080308EC, .{ .name = "func_080308EC", .linkage = .strong });
        @export(&func_08030CE8, .{ .name = "func_08030CE8", .linkage = .strong });
        @export(&func_08031488, .{ .name = "func_08031488", .linkage = .strong });
        @export(&func_080314F8, .{ .name = "func_080314F8", .linkage = .strong });
        @export(&func_08031880, .{ .name = "func_08031880", .linkage = .strong });
        @export(&func_080318F8, .{ .name = "func_080318F8", .linkage = .strong });
        @export(&func_08031964, .{ .name = "func_08031964", .linkage = .strong });
        @export(&func_080319D4, .{ .name = "func_080319D4", .linkage = .strong });
        @export(&func_08031A58, .{ .name = "func_08031A58", .linkage = .strong });
        @export(&func_08031AD0, .{ .name = "func_08031AD0", .linkage = .strong });
        @export(&func_08031B28, .{ .name = "func_08031B28", .linkage = .strong });
        @export(&func_08031BA0, .{ .name = "func_08031BA0", .linkage = .strong });
        @export(&func_08031C1C, .{ .name = "func_08031C1C", .linkage = .strong });
        @export(&func_08031E16, .{ .name = "func_08031E16", .linkage = .strong });
        @export(&func_08031E18, .{ .name = "func_08031E18", .linkage = .strong });
        @export(&func_08031E1A, .{ .name = "func_08031E1A", .linkage = .strong });
        @export(&func_08031E70, .{ .name = "func_08031E70", .linkage = .strong });
        @export(&func_08031EE8, .{ .name = "func_08031EE8", .linkage = .strong });
        @export(&func_08031FA0, .{ .name = "func_08031FA0", .linkage = .strong });
        @export(&func_08032000, .{ .name = "func_08032000", .linkage = .strong });
        @export(&func_08032054, .{ .name = "func_08032054", .linkage = .strong });
        @export(&func_080320A8, .{ .name = "func_080320A8", .linkage = .strong });
        @export(&func_08032988, .{ .name = "func_08032988", .linkage = .strong });
        @export(&func_08032B34, .{ .name = "func_08032B34", .linkage = .strong });
        @export(&func_08032E78, .{ .name = "func_08032E78", .linkage = .strong });
        @export(&func_08032EDC, .{ .name = "func_08032EDC", .linkage = .strong });
        @export(&func_08032F50, .{ .name = "func_08032F50", .linkage = .strong });
        @export(&func_080330AC, .{ .name = "func_080330AC", .linkage = .strong });
        @export(&func_08033188, .{ .name = "func_08033188", .linkage = .strong });
        @export(&func_0803329C, .{ .name = "func_0803329C", .linkage = .strong });
        @export(&func_08033510, .{ .name = "func_08033510", .linkage = .strong });
        @export(&func_0803365C, .{ .name = "func_0803365C", .linkage = .strong });
        @export(&func_080336CC, .{ .name = "func_080336CC", .linkage = .strong });
        @export(&func_0803375C, .{ .name = "func_0803375C", .linkage = .strong });
        @export(&func_08033878, .{ .name = "func_08033878", .linkage = .strong });
        @export(&func_08033A60, .{ .name = "func_08033A60", .linkage = .strong });
        @export(&func_08033AB8, .{ .name = "func_08033AB8", .linkage = .strong });
        @export(&func_08033B30, .{ .name = "func_08033B30", .linkage = .strong });
        @export(&func_08033B88, .{ .name = "func_08033B88", .linkage = .strong });
        @export(&func_08033BFC, .{ .name = "func_08033BFC", .linkage = .strong });
        @export(&func_08034490, .{ .name = "func_08034490", .linkage = .strong });
        @export(&func_08034554, .{ .name = "func_08034554", .linkage = .strong });
        @export(&func_08034678, .{ .name = "func_08034678", .linkage = .strong });
        @export(&func_0803487C, .{ .name = "func_0803487C", .linkage = .strong });
        @export(&func_08034B50, .{ .name = "func_08034B50", .linkage = .strong });
        @export(&func_0803502C, .{ .name = "func_0803502C", .linkage = .strong });
        @export(&func_08035274, .{ .name = "func_08035274", .linkage = .strong });
        @export(&func_080352EC, .{ .name = "func_080352EC", .linkage = .strong });
        @export(&func_08035348, .{ .name = "func_08035348", .linkage = .strong });
        @export(&func_08035834, .{ .name = "func_08035834", .linkage = .strong });
        @export(&func_08035BE0, .{ .name = "func_08035BE0", .linkage = .strong });
        @export(&func_08035D64, .{ .name = "func_08035D64", .linkage = .strong });
        @export(&func_08035DD0, .{ .name = "func_08035DD0", .linkage = .strong });
    }
}
