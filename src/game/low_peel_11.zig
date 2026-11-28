//! Low-ROM (< 0x08080000) block-peeled wave 11 (121..250 reachable lines, next 168).

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

fn func_0802164A() callconv(.c) void {
    if (!abi.enter(0x0802164A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            abi.setRegNz(&rt.r[1], rt.r[1] << 7);
            rt.r[0] = abi.read32(0x080216E8);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[10] = rt.r[1];
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[9] = rt.r[0];
            rt.r[1] = abi.read32(0x080216EC);
            rt.r[12] = rt.r[1];
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 7);
            rt.r[8] = rt.r[2];
            continue :blk 1;
        },
        1 => {
            abi.fetches(19);
            rt.r[0] = abi.read32(0x080216F0);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(rt.r[13] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.r[2] = abi.read32(0x080216F4);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[5], rt.r[0], rt.r[1], true);
            rt.r[6] = abi.read32(rt.r[13] +% 0x0);
            rt.r[6] +%= rt.r[9];
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[6], true);
            rt.r[2] = abi.read32(0x080216F8);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(52);
            abi.setRegNz(&rt.r[2], rt.r[7] << 1);
            rt.r[2] +%= rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.r[1] = abi.read32(0x080216FC);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[0] +%= rt.r[12];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] +%= rt.r[8];
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] +%= rt.r[8];
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x40, true);
            rt.r[1] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] +%= rt.r[8];
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x42, true);
            rt.r[5] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.r[1] = abi.read32(0x08021700);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] +%= rt.r[8];
            continue :blk 4;
        },
        3 => {
            abi.fetches(47);
            abi.setRegNz(&rt.r[2], rt.r[7] << 1);
            rt.r[2] +%= rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.r[1] = abi.read32(0x0802178C);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[0] +%= rt.r[12];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x40, true);
            rt.r[1] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x42, true);
            rt.r[5] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.r[1] = abi.read32(0x08021790);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(16);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x2, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], 0xF8);
            abi.setRegNz(&rt.r[1], rt.r[1] << 13);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.setRegNz(&rt.r[7], rt.r[1] >> 16);
            rt.r[0] = rt.r[9];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[9] = rt.r[0];
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            continue :blk 1;
        },
        6 => {
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

fn func_08021B38() callconv(.c) void {
    if (!abi.enter(0x08021B38)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(25);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[10] = rt.r[0];
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[9] = rt.r[1];
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = abi.read32(0x08021C0C);
            rt.r[1] = abi.read32(0x08021C10);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            rt.r[8] = rt.r[0];
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[7], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[4], 0x1);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[0]);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_0807B488, 0x08021BBB)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(18);
            rt.r[4] = rt.r[8];
            rt.r[6] = abi.read32(0x08021C14);
            rt.r[3] = abi.read32(rt.r[6] +% 0x0);
            rt.r[1] = rt.r[9];
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 15));
            rt.r[2] = abi.read32(0x08021C18);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[6] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[12] = rt.r[0];
            continue :blk 4;
        },
        3 => {
            abi.fetches(42);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[2], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read32(0x08021C14);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = rt.r[9];
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 15));
            rt.r[5] = abi.read32(0x08021C18);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[6] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x08021C1C);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 17);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.r[5] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[5] >> 4);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[8];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            rt.r[6] = abi.read32(0x08021C1C);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[6], true);
            rt.r[0] +%= rt.r[12];
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 15));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[7], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08021C20() callconv(.c) void {
    if (!abi.enter(0x08021C20)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(25);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[10] = rt.r[0];
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[9] = rt.r[1];
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = abi.read32(0x08021CF8);
            rt.r[1] = abi.read32(0x08021CFC);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            rt.r[8] = rt.r[0];
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[7], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[4], 0x1);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[0]);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_0807B488, 0x08021CA3)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(18);
            rt.r[4] = rt.r[8];
            rt.r[0] = abi.read32(0x08021D00);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[6] = rt.r[9];
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 15));
            rt.r[2] = abi.read32(0x08021D04);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[6] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[12] = rt.r[0];
            continue :blk 4;
        },
        3 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 17);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[3], 0x9, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            rt.r[6] = abi.read32(0x08021D08);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[6], true);
            rt.r[0] +%= rt.r[12];
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(28);
            rt.r[0] = abi.read32(0x08021D00);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = rt.r[9];
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 15));
            rt.r[5] = abi.read32(0x08021D04);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[6] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x08021D08);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[5] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[5] >> 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xA, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[8];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 6;
        },
        6 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 15));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[7], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08021D0C() callconv(.c) void {
    if (!abi.enter(0x08021D0C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(25);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[10] = rt.r[0];
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[9] = rt.r[1];
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = abi.read32(0x08021DE4);
            rt.r[1] = abi.read32(0x08021DE8);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            rt.r[8] = rt.r[0];
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[7], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[4], 0x1);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[0]);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_0807B488, 0x08021D8F)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(18);
            rt.r[4] = rt.r[8];
            rt.r[0] = abi.read32(0x08021DEC);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[6] = rt.r[9];
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 15));
            rt.r[2] = abi.read32(0x08021DF0);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[6] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[12] = rt.r[0];
            continue :blk 4;
        },
        3 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 17);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(null, rt.r[3], 0x27, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            rt.r[6] = abi.read32(0x08021DF4);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[6], true);
            rt.r[0] +%= rt.r[12];
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(28);
            rt.r[0] = abi.read32(0x08021DEC);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = rt.r[9];
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 15));
            rt.r[5] = abi.read32(0x08021DF0);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[6] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x08021DF4);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[5] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[5] >> 4);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x28, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[8];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 6;
        },
        6 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 15));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[7], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0802222C() callconv(.c) void {
    if (!abi.enter(0x0802222C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(22);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[10] = rt.r[0];
            rt.r[2] = abi.read32(0x08022308);
            rt.r[12] = rt.r[2];
            rt.r[5] = abi.read32(0x0802230C);
            rt.r[9] = rt.r[5];
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x80, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
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
            abi.fetches(20);
            rt.r[0] = abi.read32(0x08022310);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[3] << 1);
            rt.r[5] = abi.read32(0x08022314);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[1], 16));
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            rt.r[5] = abi.read32(0x08022318);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802231C);
            rt.r[12] = rt.r[0];
            abi.setRegNz(&rt.r[1], 0xD0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 8);
            rt.r[10] = rt.r[1];
            continue :blk 4;
        },
        4 => {
            abi.fetches(61);
            abi.setRegNz(&rt.r[4], rt.r[4] << 4);
            rt.r[5] = abi.read16(rt.r[2] +% 0x4);
            rt.cpuSub(&rt.r[4], rt.r[4], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[3] << 4);
            rt.r[2] = abi.read16(rt.r[2] +% 0x6);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = rt.r[9];
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 3);
            rt.r[0] = abi.read32(0x08022320);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[6] = abi.read16(rt.r[7] +% 0x2);
            abi.setRegNz(&rt.r[3], 0xFF);
            abi.setRegNz(&rt.r[3], rt.r[3] << 8);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[6]);
            abi.setRegNz(&rt.r[5], 0xFF);
            rt.r[8] = rt.r[5];
            abi.setRegNz(&rt.r[5], 0xFF);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.r[5] = abi.read16(rt.r[7] +% 0x4);
            abi.setRegNz(&rt.r[3], 0xFE);
            abi.setRegNz(&rt.r[3], rt.r[3] << 8);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[5]);
            rt.r[1] = abi.read32(0x08022324);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.r[0] = abi.read16(rt.r[7] +% 0x6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x36, true);
            rt.r[5] = rt.r[12];
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[0]);
            rt.r[12] = rt.r[5];
            rt.r[0] = rt.r[10];
            rt.r[0] +%= rt.r[12];
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = rt.r[9];
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_080224E0() callconv(.c) void {
    if (!abi.enter(0x080224E0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x08022500);
            rt.r[0] = abi.read32(0x08022504);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 2);
            abi.setRegNz(&rt.r[1], 0xF);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[4] = abi.read32(0x08022534);
            rt.r[1] = abi.read32(0x08022538);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011398, 0x08022515)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0802253C);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011398, 0x0802251F)) return;
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
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080225B4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x14);
            if (!abi.call(decls.func_080796C8, 0x0802257D)) return;
            continue :blk 9;
        },
        6 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08022540);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011398, 0x08022529)) return;
            continue :blk 10;
        },
        7 => {
            abi.fetches(3);
            continue :blk 5;
        },
        8 => {
            abi.fetches(8);
            rt.r[4] = abi.read32(0x080225A0);
            rt.r[1] = abi.read32(0x080225A4);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011398, 0x08022555)) return;
            continue :blk 11;
        },
        9 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        10 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08022544);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011398, 0x08022533)) return;
            continue :blk 14;
        },
        11 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x080225A8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011398, 0x0802255F)) return;
            continue :blk 15;
        },
        12 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x3, true);
            continue :blk 13;
        },
        13 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 2));
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 7);
            rt.r[1] = abi.read32(0x080225B8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(0x080225BC);
            abi.setRegNz(&rt.r[2], 0x80);
            if (!abi.call(decls.func_0800FDA4, 0x08022599)) return;
            continue :blk 16;
        },
        14 => {
            abi.fetches(3);
            continue :blk 5;
        },
        15 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x080225AC);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011398, 0x08022569)) return;
            continue :blk 17;
        },
        16 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        17 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x080225B0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08011398, 0x08022573)) return;
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_080229A8() callconv(.c) void {
    if (!abi.enter(0x080229A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0803F048, 0x080229B1)) return;
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
            abi.setRegNz(&rt.r[0], 0xE);
            if (!abi.call(decls.func_0803F048, 0x080229C5)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EFA0, 0x080229BF)) return;
            continue :blk 2;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], 0xF);
            if (!abi.call(decls.func_0803F048, 0x080229CF)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], 0x10);
            if (!abi.call(decls.func_0803F048, 0x080229D9)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], 0x11);
            if (!abi.call(decls.func_0803F048, 0x080229E3)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x5);
            if (!abi.call(decls.func_0803F048, 0x08022A05)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        12 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 15;
        },
        13 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EFA0, 0x08022A13)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x6);
            if (!abi.call(decls.func_0803F048, 0x08022A19)) return;
            continue :blk 16;
        },
        15 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x5);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EFA0, 0x080229FF)) return;
            continue :blk 9;
        },
        16 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], 0x7);
            if (!abi.call(decls.func_0803F048, 0x08022A23)) return;
            continue :blk 17;
        },
        17 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], 0x8);
            if (!abi.call(decls.func_0803F048, 0x08022A2D)) return;
            continue :blk 18;
        },
        18 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], 0x9);
            if (!abi.call(decls.func_0803F048, 0x08022A37)) return;
            continue :blk 19;
        },
        19 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 21;
            }
            continue :blk 20;
        },
        20 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 21;
            }
            continue :blk 22;
        },
        21 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        22 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 21;
            }
            continue :blk 23;
        },
        23 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 21;
            }
            continue :blk 24;
        },
        24 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EFA0, 0x08022A53)) return;
            continue :blk 21;
        },
        else => unreachable,
    }
}

fn func_08022A58() callconv(.c) void {
    if (!abi.enter(0x08022A58)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(22);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[9] = rt.r[0];
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 24);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            rt.r[1] = abi.read32(0x08022A84);
            abi.setRegNz(&rt.r[0], rt.r[2] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x10, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(32);
            rt.r[4] = abi.read32(0x08022AD4);
            abi.setRegNz(&rt.r[5], rt.r[5] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[5], 24));
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.r[12] = rt.r[0];
            rt.r[0] = abi.read32(0x08022AD8);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.r[3] = abi.read32(0x08022ADC);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[6] = rt.r[9];
            abi.setRegNz(&rt.r[6], rt.r[6] *% rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[6] +% 0x1E);
            abi.setRegNz(&rt.r[0], rt.r[1] << 7);
            rt.cpuAdd(&rt.r[7], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read32(0x08022AE0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            rt.r[10] = rt.r[3];
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(10);
            rt.r[1] = abi.read8(rt.r[6] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[7], rt.r[0], true);
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[6], 0x92);
            abi.setRegNz(&rt.r[6], rt.r[6] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[7], rt.r[6], true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(10);
            rt.r[0] = rt.r[8];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0xB);
            rt.r[0] +%= rt.r[12];
            rt.cpuSub(null, rt.r[0], 0x31, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(23);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[5], 24));
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x08022B34);
            rt.cpuAdd(&rt.r[3], rt.r[0], rt.r[1], true);
            rt.r[5] = abi.read32(0x08022B38);
            rt.r[2] = rt.r[10];
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[6] = rt.r[9];
            abi.setRegNz(&rt.r[6], rt.r[6] *% rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1E);
            abi.setRegNz(&rt.r[0], rt.r[2] << 7);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[0], true);
            rt.r[4] = abi.read32(0x08022B3C);
            rt.r[0] = abi.read8(rt.r[4] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x32);
            continue :blk 5;
        },
        9 => {
            abi.fetches(10);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[0], true);
            continue :blk 11;
        },
        10 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[6], 0x92);
            abi.setRegNz(&rt.r[6], rt.r[6] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[6], true);
            continue :blk 11;
        },
        11 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read8(rt.r[3] +% 0x8);
            rt.r[0] = abi.read8(rt.r[0] +% 0xB);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_08023550() callconv(.c) void {
    if (!abi.enter(0x08023550)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(41);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[3], 16));
            rt.r[0] = abi.read32(0x08023648);
            rt.r[9] = rt.r[0];
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[8] = rt.r[0];
            rt.r[1] +%= rt.r[8];
            rt.r[0] = abi.read32(0x0802364C);
            abi.setRegNz(&rt.r[6], rt.r[6] & rt.r[0]);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[0]);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.write8(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            rt.r[0] = rt.r[9];
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] +%= rt.r[8];
            rt.r[0] = abi.read8(rt.r[1] +% 0x3);
            abi.setRegNz(&rt.r[5], rt.r[0] << 16);
            rt.r[0] = abi.read32(0x08023650);
            abi.setRegNz(&rt.r[6], rt.r[6] & rt.r[0]);
            abi.setRegNz(&rt.r[6], rt.r[6] | rt.r[5]);
            rt.r[0] = abi.read16(rt.r[2] +% 0x2);
            abi.write8(rt.r[1] +% 0x3, @truncate(rt.r[0]));
            rt.r[7] = abi.read32(0x08023654);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_08022B6C, 0x0802359F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[5] = abi.read32(0x08023658);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08022B6C, 0x080235AD)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x2);
            rt.r[3] = abi.read8(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[4], rt.r[2], rt.r[3], true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read8(rt.r[1] +% 0x3);
            rt.r[0] = abi.read8(rt.r[0] +% 0x3);
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[4], 0, rt.r[4], true);
            continue :blk 3;
        },
        5 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x1);
            if (!abi.call(decls.func_08022BFC, 0x080235D7)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08022BFC, 0x080235E3)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_080232C8, 0x080235EB)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_080232C8, 0x080235F3)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_080234CC, 0x080235FB)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[1], 0xE);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[4], 0x64);
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[2], 0x14);
            rt.r[1] = rt.sext16(abi.read16(rt.r[7] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x64);
            if (!abi.call(decls.func_080796C8, 0x0802360F)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(12);
            abi.write16(rt.r[7] +% 0x14, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[3], 0xE);
            rt.r[0] = rt.sext16(abi.read16(rt.r[7] +% rt.r[3]));
            rt.cpuSub(&rt.r[4], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0x14);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            abi.setRegNz(&rt.r[1], 0x64);
            if (!abi.call(decls.func_080796C8, 0x08023623)) return;
            continue :blk 13;
        },
        13 => {
            abi.fetches(7);
            abi.write16(rt.r[5] +% 0x14, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08023508, 0x0802362D)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(16);
            rt.r[2] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] +%= rt.r[8];
            abi.write8(rt.r[0] +% 0x2, @truncate(rt.r[6]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] +%= rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[6] >> 16);
            abi.write8(rt.r[0] +% 0x3, @truncate(rt.r[1]));
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

fn func_0802365C() callconv(.c) void {
    if (!abi.enter(0x0802365C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[8] = rt.r[0];
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x7F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[1] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x08023683)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x6);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 7);
            abi.setRegNz(&rt.r[1], 0x8);
            rt.r[0] = rt.sext16(abi.read16(rt.r[7] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x1, true);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x0802369F)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[2], rt.r[5], rt.r[4], true);
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[1], rt.r[4], 0x1, true);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[2], rt.r[5], rt.r[1], true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[2], rt.r[2] << 7);
            abi.setRegNz(&rt.r[1], 0x7F);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.r[3] = rt.r[8];
            rt.r[3] = abi.read8(rt.r[3] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            rt.r[4] = rt.r[8];
            abi.write8(rt.r[4] +% 0x6, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[8] = rt.r[0];
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x080236D5)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 12;
        },
        11 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x1, true);
            continue :blk 12;
        },
        12 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x6);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 7);
            abi.setRegNz(&rt.r[1], 0x8);
            rt.r[0] = rt.sext16(abi.read16(rt.r[6] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x080236F1)) return;
            continue :blk 15;
        },
        14 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[4], true);
            continue :blk 16;
        },
        15 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[1], rt.r[4], 0x1, true);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            continue :blk 16;
        },
        16 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.r[0] << 7);
            abi.setRegNz(&rt.r[1], 0x7F);
            rt.r[3] = rt.r[8];
            rt.r[3] = abi.read8(rt.r[3] +% 0x6);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[3]);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            rt.r[4] = rt.r[8];
            abi.write8(rt.r[4] +% 0x6, @truncate(rt.r[1]));
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[1] >> 7);
            rt.cpuSub(null, rt.r[0], 0x63, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 18;
            }
            continue :blk 17;
        },
        17 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x6, @truncate(rt.r[0]));
            continue :blk 18;
        },
        18 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.r[2] = abi.read8(rt.r[1] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[2] >> 7);
            rt.cpuSub(null, rt.r[0], 0x63, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 20;
            }
            continue :blk 19;
        },
        19 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x6, @truncate(rt.r[0]));
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
        else => unreachable,
    }
}

fn func_08023734() callconv(.c) void {
    if (!abi.enter(0x08023734)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x7F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[1] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x08023751)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x8);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x1, true);
            continue :blk 3;
        },
        5 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x08023767)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            continue :blk 8;
        },
        7 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[1], rt.r[4], 0x1, true);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_08024124, 0x0802377B)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(28);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x7F);
            rt.r[0] = abi.read8(rt.r[5] +% 0x8);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[2] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x4, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xF);
            rt.r[0] = abi.read16(rt.r[5] +% 0xA);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.setRegNz(&rt.r[1], rt.r[1] << 7);
            rt.r[0] = abi.read32(0x080237BC);
            rt.r[3] = abi.read16(rt.r[2] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write16(rt.r[2] +% 0x4, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x7F);
            rt.r[1] = abi.read8(rt.r[2] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_0802AAF8, 0x080237B5)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080237C0() callconv(.c) void {
    if (!abi.enter(0x080237C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[4] = abi.read32(0x0802387C);
            rt.r[5] = abi.read32(0x08023880);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(func_0802365C, 0x080237CF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x8);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x8);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(37);
            rt.r[0] = abi.read32(0x08023884);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
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
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[3] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[2], rt.r[3], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.r[1] << 8);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.r[1] << 16);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 8));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            if (!abi.call(decls.func_08024B88, 0x0802381D)) return;
            continue :blk 2;
        },
        4 => {
            abi.fetches(37);
            rt.r[0] = abi.read32(0x08023884);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
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
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[3] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuSub(&rt.r[2], rt.r[3], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.r[1] << 8);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.r[1] << 16);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 8));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            if (!abi.call(decls.func_08024B88, 0x0802386B)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_08023734, 0x08023871)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(func_08023734, 0x08023877)) return;
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

fn func_08023978() callconv(.c) void {
    if (!abi.enter(0x08023978)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(36);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08023A10);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[5] +% 0x3);
            abi.setRegNz(&rt.r[2], rt.r[0] << 1);
            rt.r[3] = abi.read32(0x08023A14);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[5] +% 0x2);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[3] = abi.read32(0x08023A18);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            rt.r[2] = abi.read32(0x08023A1C);
            abi.setRegNz(&rt.r[7], 0x1F);
            abi.setRegNz(&rt.r[7], rt.r[7] & rt.r[3]);
            rt.r[4] = abi.read8(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[4] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x38, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[6] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[1] = abi.read8(rt.r[5] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[12] = rt.r[2];
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
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08023A20);
            abi.setRegNz(&rt.r[0], 0xE0);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[0]);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
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
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08023A24);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[7], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[2] = abi.read8(rt.r[5] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], 0x5);
            continue :blk 7;
        },
        7 => {
            abi.fetches(19);
            rt.r[7] = abi.read32(0x08023A28);
            rt.r[3] = abi.read8(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[3] << 2);
            rt.r[2] = abi.read32(0x08023A2C);
            rt.r[0] = abi.read32(0x08023A30);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1E);
            abi.setRegNz(&rt.r[0], rt.r[2] << 7);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read32(0x08023A34);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(9);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x92);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            continue :blk 10;
        },
        10 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0xA);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], 0x0);
            continue :blk 12;
        },
        12 => {
            abi.fetches(9);
            rt.r[2] = abi.read8(rt.r[5] +% 0x6);
            abi.setRegNz(&rt.r[4], rt.r[2] << 25);
            abi.setRegNz(&rt.r[1], rt.r[4] >> 25);
            abi.setRegNz(&rt.r[0], rt.r[6] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write8(rt.r[5] +% 0x6, @truncate(rt.r[0]));
            continue :blk 15;
        },
        14 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[4] >> 25);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[1], 0x7F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x80);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            abi.write8(rt.r[5] +% 0x6, @truncate(rt.r[1]));
            continue :blk 15;
        },
        15 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x7F);
            rt.r[5] = abi.read8(rt.r[5] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 16;
        },
        16 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.r[0] +%= rt.r[12];
            abi.setRegNz(&rt.r[1], 0x30);
            rt.r[0] = abi.read8(rt.r[0] +% 0x14);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 17;
        },
        17 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08023AA8() callconv(.c) void {
    if (!abi.enter(0x08023AA8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[1] = abi.read32(0x08023AFC);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[3], 0x32, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[3], 0x1);
            rt.cpuAdd(&rt.r[4], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[4] = abi.read32(0x08023B00);
            rt.r[5] = abi.read32(0x08023B04);
            rt.cpuAdd(&rt.r[6], rt.r[7], 0x0, true);
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            rt.r[5] = abi.read32(0x08023B64);
            rt.r[6] = abi.read32(0x08023B68);
            rt.r[12] = rt.r[4];
            continue :blk 6;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 7;
        },
        5 => {
            abi.fetches(12);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[3], true);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(12);
            rt.r[0] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[3], true);
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        8 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[1]);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 12;
        },
        9 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[3], 0x32, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        10 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[1]);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 13;
        },
        11 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[4], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 4;
        },
        12 => {
            abi.fetches(7);
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x31, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 15;
            }
            continue :blk 14;
        },
        13 => {
            abi.fetches(8);
            rt.r[1] = rt.r[12];
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x31, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 17;
            }
            continue :blk 16;
        },
        14 => {
            abi.fetches(3);
            abi.write16(rt.r[7] +% 0x0, @truncate(rt.r[2]));
            continue :blk 15;
        },
        15 => {
            abi.fetches(10);
            rt.r[4] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            continue :blk 7;
        },
        16 => {
            abi.fetches(3);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[2]));
            continue :blk 17;
        },
        17 => {
            abi.fetches(10);
            rt.r[5] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            continue :blk 7;
        },
        else => unreachable,
    }
}

fn func_08023DD0() callconv(.c) void {
    if (!abi.enter(0x08023DD0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[2] = abi.read32(0x08023EB8);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.r[8] = rt.r[0];
            rt.r[4] = abi.read8(rt.r[1] +% 0x3);
            rt.cpuSub(null, rt.r[1], 0x0, true);
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
            abi.setRegNz(&rt.r[0], 0x20);
            rt.r[3] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
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
            abi.fetches(16);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 14);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            if (!abi.call(decls.func_08025410, 0x08023E19)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(25);
            rt.r[1] = abi.read32(0x08023EBC);
            rt.r[0] = abi.read32(0x08023EC0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.r[7] = abi.read32(0x08023EC4);
            rt.r[2] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[5] << 1);
            rt.r[4] = abi.read32(0x08023EC8);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[4] = rt.r[8];
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            rt.r[3] = abi.read32(0x08023ECC);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            if (!abi.call(decls.func_08025484, 0x08023E4D)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08023D54, 0x08023E5F)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            continue :blk 10;
        },
        12 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[1], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08023D54, 0x08023E6F)) return;
            continue :blk 14;
        },
        13 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        14 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 13;
        },
        15 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08023D54, 0x08023E8B)) return;
            continue :blk 17;
        },
        16 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 19;
            }
            continue :blk 18;
        },
        17 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 16;
        },
        18 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08023D54, 0x08023EA7)) return;
            continue :blk 20;
        },
        19 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 21;
        },
        20 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 19;
        },
        21 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802430C() callconv(.c) void {
    if (!abi.enter(0x0802430C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[6] = abi.read32(0x0802437C);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(func_0802AB2C, 0x08024323)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(23);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 6));
            rt.r[3] = abi.read32(0x08024380);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xB7, true);
            rt.r[1] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xB7, true);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[2], 0x63, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x7);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x63);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        4 => {
            abi.fetches(13);
            rt.r[1] = abi.read8(rt.r[5] +% 0x7);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x7F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[1] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x08024379)) return;
            continue :blk 10;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 11;
        },
        8 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x080243C0);
            rt.r[2] = abi.read8(rt.r[5] +% 0x8);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x7F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        9 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        10 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x1, true);
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08024124, 0x0802438D)) return;
            continue :blk 14;
        },
        12 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[1] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x080243BD)) return;
            continue :blk 15;
        },
        13 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 16;
        },
        14 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x7);
            if (!abi.call(func_0802430C, 0x08024393)) return;
            continue :blk 5;
        },
        15 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x1, true);
            continue :blk 16;
        },
        16 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08024124, 0x080243CD)) return;
            continue :blk 17;
        },
        17 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x8);
            if (!abi.call(func_0802430C, 0x080243D3)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_080243DC() callconv(.c) void {
    if (!abi.enter(0x080243DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(37);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x8;
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.r[1] = abi.read32(0x08024434);
            abi.setRegNz(&rt.r[0], rt.r[6] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[7] = abi.read16(rt.r[0] +% 0x18);
            rt.r[0] = abi.read32(0x08024438);
            rt.r[12] = rt.r[0];
            abi.setRegNz(&rt.r[4], rt.r[6] << 2);
            rt.r[2] = abi.read32(0x0802443C);
            rt.r[3] = abi.read32(0x08024440);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[5] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuAdd(&rt.r[5], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[5] +% 0x1E);
            abi.setRegNz(&rt.r[0], rt.r[1] << 7);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read32(0x08024444);
            rt.r[1] = abi.read8(rt.r[0] +% 0x8);
            rt.r[9] = rt.r[12];
            rt.r[8] = rt.r[2];
            rt.r[10] = rt.r[0];
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x92);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[2], true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.r[1] = abi.read8(rt.r[5] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(23);
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            rt.cpuAdd(&rt.r[4], rt.r[7], rt.r[0], true);
            rt.r[3] = rt.r[9];
            rt.r[5] = abi.read32(0x08024488);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = rt.r[8];
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.r[5] = abi.read8(rt.r[1] +% 0x1E);
            abi.setRegNz(&rt.r[2], rt.r[5] << 7);
            rt.r[5] = rt.r[10];
            rt.r[0] = abi.read8(rt.r[5] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(10);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x92);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            abi.setRegNz(&rt.r[1], 0x64);
            if (!abi.call(decls.func_0807B488, 0x080244A1)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[1], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.r[2] = abi.read32(0x080244E4);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[3] = rt.r[8];
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_C) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(12);
            rt.r[5] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read32(rt.r[13] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[2] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[2], rt.r[6] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            if (!abi.call(decls.func_080242B8, 0x080244D1)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 11;
        },
        10 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(10);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        12 => {
            abi.fetches(7);
            rt.r[3] = rt.r[8];
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08024128, 0x080244E1)) return;
            continue :blk 13;
        },
        13 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            continue :blk 11;
        },
        else => unreachable,
    }
}

fn func_08024664() callconv(.c) void {
    if (!abi.enter(0x08024664)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
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
            abi.fetches(31);
            rt.r[0] = abi.read32(0x080246D8);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[5], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 8);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 2));
            abi.setRegNz(&rt.r[3], 0xC0);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[3]);
            rt.cpuSub(&rt.r[2], rt.r[4], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.r[0] << 8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[2], rt.r[0] << 16);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 2));
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
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
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x7);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x7);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.r[1] = abi.read8(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x7F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[1] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x080246CF)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x9, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_080246E4() callconv(.c) void {
    if (!abi.enter(0x080246E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x8;
            rt.r[10] = rt.r[0];
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            rt.r[8] = rt.r[2];
            rt.r[9] = rt.r[3];
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0xC0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            if (!abi.call(decls.func_08012D8C, 0x08024711)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            rt.r[4] = abi.read32(0x08024770);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], 0xFF);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            ldmRegs(0, &.{ 5, 6, 7 });
            stmRegs(1, &.{ 5, 6, 7 });
            rt.cpuAdd(&rt.r[4], rt.r[4], 0xC, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xC, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x4, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 1;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[13] +% 0x4);
            rt.r[1] = rt.r[10];
            if (!abi.call(decls.func_08024774, 0x08024733)) return;
            continue :blk 9;
        },
        8 => {
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
        9 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[13] +% 0x4);
            abi.setRegNz(&rt.r[2], 0xC0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read32(rt.r[13] +% 0x0);
            if (!abi.call(decls.func_08024774, 0x08024741)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(9);
            rt.r[5] = abi.read32(rt.r[13] +% 0x4);
            abi.setRegNz(&rt.r[6], 0xC0);
            abi.setRegNz(&rt.r[6], rt.r[6] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[6], true);
            rt.r[1] = rt.r[8];
            if (!abi.call(decls.func_08024774, 0x0802474F)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[7], 0x90);
            abi.setRegNz(&rt.r[7], rt.r[7] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[7], true);
            rt.r[1] = rt.r[9];
            if (!abi.call(decls.func_08024774, 0x0802475B)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[13] +% 0x4);
            if (!abi.call(decls.func_08012E14, 0x08024761)) return;
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_080247DC() callconv(.c) void {
    if (!abi.enter(0x080247DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[0] = abi.read32(0x08024840);
            rt.r[0] = abi.read8(rt.r[0] +% 0x2);
            if (!abi.call(decls.func_08022814, 0x080247EF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[5], 0x1);
            rt.cpuSub(null, rt.r[5], rt.r[8], true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 3;
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
        3 => {
            abi.fetches(11);
            rt.r[2] = abi.read32(0x08024840);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x38, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x1, true);
            rt.r[9] = rt.r[4];
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[4] = rt.r[8];
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x3D, true);
            rt.cpuAdd(&rt.r[7], rt.r[5], rt.r[6], true);
            rt.r[10] = rt.r[3];
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            rt.r[4] = rt.r[9];
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], rt.r[8], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080247A4, 0x08024821)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 12;
        },
        10 => {
            abi.fetches(8);
            rt.r[2] = abi.read32(0x08024840);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x39, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 13;
        },
        11 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 14;
        },
        12 => {
            abi.fetches(3);
            abi.write8(rt.r[7] +% 0x0, @truncate(rt.r[3]));
            continue :blk 5;
        },
        13 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3E, true);
            continue :blk 15;
        },
        14 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 16;
        },
        15 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 9;
        },
        16 => {
            abi.fetches(7);
            rt.r[2] = rt.r[10];
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 17;
        },
        17 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[6], true);
            continue :blk 15;
        },
        else => unreachable,
    }
}

fn func_08024970() callconv(.c) void {
    if (!abi.enter(0x08024970)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            if (!abi.call(decls.func_08024CD0, 0x08024983)) return;
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
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080249A4);
            rt.r[1] = abi.read8(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[1], 0x81, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(8);
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x64);
            continue :blk 4;
        },
        7 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080249A8);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x21, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 6;
        },
        8 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[3], 0x1);
            rt.r[2] = abi.read32(0x08024A10);
            rt.r[9] = rt.r[2];
            rt.r[6] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[12] = rt.r[0];
            rt.r[0] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[7]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[8] = rt.r[0];
            continue :blk 9;
        },
        9 => {
            abi.fetches(9);
            rt.r[0] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1B);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[1] = rt.r[8];
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[3], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 9;
            }
            continue :blk 13;
        },
        12 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[0] = abi.read32(0x08024A10);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x36, true);
            continue :blk 14;
        },
        13 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 15;
            }
            continue :blk 2;
        },
        14 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[2], 0x18, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 14;
            }
            continue :blk 11;
        },
        15 => {
            abi.fetches(16);
            rt.r[2] = rt.r[9];
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[7]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x18);
            abi.setRegNz(&rt.r[0], rt.r[1] << 5);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080796C8, 0x08024A31)) return;
            continue :blk 16;
        },
        16 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x64, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 18;
            }
            continue :blk 17;
        },
        17 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x64);
            continue :blk 18;
        },
        18 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08024A48() callconv(.c) void {
    if (!abi.enter(0x08024A48)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08024CD0, 0x08024A55)) return;
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08024A70);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
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
            rt.r[0] = abi.read32(0x08024A74);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x21, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], 0xA);
            continue :blk 9;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[6], 0x14);
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x64);
            continue :blk 4;
        },
        9 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[0] = abi.read32(0x08024AC8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x4F, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x36, true);
            continue :blk 10;
        },
        10 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[2], 0x18, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 10;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], rt.r[4], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x64);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_0807B488, 0x08024ABB)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x64, true);
            rt.cpuSub(&rt.r[3], rt.r[6], rt.r[0], true);
            rt.cpuSub(null, rt.r[3], 0x63, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 15;
            }
            continue :blk 8;
        },
        15 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 16;
        },
        16 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[3] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08024BD0() callconv(.c) void {
    if (!abi.enter(0x08024BD0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(24);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[10] = rt.r[0];
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 24);
            rt.r[2] = abi.read32(0x08024CA4);
            rt.r[1] = abi.read32(0x08024CA8);
            abi.setRegNz(&rt.r[0], rt.r[6] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[8] = rt.r[2];
            rt.r[9] = rt.r[1];
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.r[2] = abi.read16(rt.r[0] +% 0x20);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if (rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[6] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[0] +%= rt.r[9];
            rt.r[2] = rt.r[8];
            rt.r[3] = abi.read16(rt.r[2] +% 0x0);
            rt.r[2] = abi.read16(rt.r[0] +% 0x20);
            rt.cpuSub(null, rt.r[3], rt.r[2], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[4], 0xFA);
            abi.setRegNz(&rt.r[4], rt.r[4] << 1);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[3] = rt.r[8];
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[3], true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0xFA);
            abi.setRegNz(&rt.r[4], rt.r[4] << 1);
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], rt.r[2], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            continue :blk 8;
        },
        6 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[4], 0xFA);
            abi.setRegNz(&rt.r[4], rt.r[4] << 1);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[3] = rt.r[8];
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x20);
            rt.cpuSub(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], rt.r[4] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[0] = rt.r[10];
            if (!abi.call(decls.func_08024B4C, 0x08024C97)) return;
            continue :blk 10;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807C384, 0x08024C15)) return;
            continue :blk 11;
        },
        9 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            continue :blk 12;
        },
        10 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        11 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        12 => {
            abi.fetches(11);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x96, true);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 9);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 15;
        },
        13 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(0x08024CAC);
            rt.r[3] = abi.read32(0x08024CB0);
            if (!abi.call(decls.func_0807BBF8, 0x08024C21)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(0x08024CB4);
            rt.r[3] = abi.read32(0x08024CB8);
            if (!abi.call(decls.func_0807BC60, 0x08024C29)) return;
            continue :blk 16;
        },
        15 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x95, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 12;
            }
            continue :blk 17;
        },
        16 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0807B520, 0x08024C2D)) return;
            continue :blk 18;
        },
        17 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 7;
        },
        18 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 9);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], rt.r[7], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 19;
        },
        19 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08024CBC);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 20;
        },
        20 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08024D9C() callconv(.c) void {
    if (!abi.enter(0x08024D9C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(35);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[1] = abi.read32(0x08024E1C);
            rt.r[4] = abi.read32(0x08024E20);
            rt.r[2] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 5);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08024E24);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 6);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08024E28);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(0x08024E2C);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[6] = abi.read32(0x08024E30);
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[5], 0x68);
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x16, @truncate(rt.r[1]));
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            if (!abi.call(decls.func_0801E188, 0x08024DDF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(func_08025310, 0x08024DE3)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            if (!abi.call(decls.func_0801990C, 0x08024DE9)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            if (!abi.call(decls.func_08019970, 0x08024DEF)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08024E34);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(16);
            rt.r[1] = abi.read32(0x08024EAC);
            rt.r[0] = abi.read32(0x08024EB0);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2B, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2C, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            if (!abi.call(decls.func_08020538, 0x08024EA3)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            if (!abi.call(decls.func_08025194, 0x08024DFD)) return;
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
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[4] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[5]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x29, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2A, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            if (!abi.call(decls.func_08020538, 0x08024E1B)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08024EA8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(3);
            continue :blk 14;
        },
        12 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 13;
        },
        13 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x7, true);
            abi.setRegNz(&rt.r[3], 0x6);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[3]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        14 => {
            abi.fetches(22);
            rt.r[5] = abi.read32(0x08024EAC);
            rt.r[4] = abi.read32(0x08024EB0);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x68);
            rt.r[2] = abi.read16(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x08024EB4);
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
            continue :blk 5;
        },
        15 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 16;
        },
        16 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 4));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08020538, 0x08024E5F)) return;
            continue :blk 14;
        },
        else => unreachable,
    }
}

fn func_08024EE8() callconv(.c) void {
    if (!abi.enter(0x08024EE8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            if (!abi.call(decls.func_08022800, 0x08024EEF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], 0x4);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(39);
            rt.r[2] = abi.read32(0x08024FF4);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[3] = abi.read32(0x08024FF8);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x39, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x83, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xD0, true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3A, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x1B, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x9C);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3B, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x1B, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xD0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3C, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x1B, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            rt.r[12] = rt.r[5];
            abi.setRegNz(&rt.r[7], 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x42, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], 0x5);
            rt.r[3] = abi.read32(0x08024FF0);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 5;
        },
        4 => {
            abi.fetches(37);
            abi.setRegNz(&rt.r[2], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] *% rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[1], true);
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x33, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x1A, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[1], true);
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3D, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x1D, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[6], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x26, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x28, true);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[7]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuSub(null, rt.r[2], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 2;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            abi.write8(rt.r[5] +% 0x7, @truncate(rt.r[0]));
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08025000, 0x08024FAF)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 10;
        },
        10 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[2], rt.r[1] << 16);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[2], 16));
            rt.r[0] = abi.read32(0x08024FFC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 22));
            rt.r[0] = abi.read32(0x08024FF4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x9E, true);
            rt.r[4] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 12;
        },
        12 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08025080() callconv(.c) void {
    if (!abi.enter(0x08025080)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[6] = abi.read32(0x08025130);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[7], 0x68);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(48);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[7]);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            abi.write8(rt.r[0] +% 0x1A, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[0] +% 0x4, rt.r[3]);
            abi.write8(rt.r[0] +% 0x11, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write8(rt.r[0] +% 0x12, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[0] +% 0x14, @truncate(rt.r[3]));
            abi.write8(rt.r[0] +% 0x1B, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[0] +% 0x16, @truncate(rt.r[3]));
            abi.write16(rt.r[0] +% 0x18, @truncate(rt.r[3]));
            abi.write32(rt.r[0] +% 0x20, rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x25, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write8(rt.r[0] +% 0x1E, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[0] +% 0x32, @truncate(rt.r[3]));
            abi.write16(rt.r[0] +% 0x34, @truncate(rt.r[3]));
            abi.write8(rt.r[0] +% 0x10, @truncate(rt.r[3]));
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(15);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x36, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4F, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x18, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(23);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8F, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF7, true);
            abi.setRegNz(&rt.r[1], 0x2);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[2] = abi.read32(0x08025134);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x68, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080251BC() callconv(.c) void {
    if (!abi.enter(0x080251BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = abi.read32(0x08025200);
            rt.r[12] = rt.r[0];
            rt.r[4] = abi.read32(0x08025204);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(26);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.write32(rt.r[0] +% 0x8, rt.r[3]);
            abi.write8(rt.r[0] +% 0xC, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.write8(rt.r[0] +% 0xD, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.write8(rt.r[0] +% 0xE, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.write8(rt.r[0] +% 0xF, @truncate(rt.r[3]));
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x29, true);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.r[6] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[6]);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x68, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            rt.cpuSub(null, rt.r[5], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[6], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[7], rt.r[6], 0x1, true);
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(18);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[6] << 1);
            rt.r[3] = abi.read32(0x08025250);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[2] = abi.read32(0x08025254);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xE0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[6], rt.r[7], 0x0, true);
            continue :blk 3;
        },
        10 => {
            abi.fetches(13);
            rt.r[2] = abi.read32(0x08025258);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 29);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[2], 0x1F);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[3]);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x6, true);
            rt.cpuSub(null, rt.r[0], 0x8, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 11;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            rt.r[1] = abi.read32(0x0802530C);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[12] = rt.r[1];
            continue :blk 7;
        },
        12 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x0802525C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x080252B0 => continue :blk 15,
                0x080252EA => continue :blk 11,
                0x08025284 => continue :blk 13,
                0x080252C4 => continue :blk 16,
                0x080252D8 => continue :blk 17,
                0x0802529C => continue :blk 14,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        13 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08025138, 0x0802528B)) return;
            continue :blk 18;
        },
        14 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08025138, 0x080252A3)) return;
            continue :blk 19;
        },
        15 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08025138, 0x080252B7)) return;
            continue :blk 20;
        },
        16 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08025138, 0x080252CB)) return;
            continue :blk 21;
        },
        17 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08025138, 0x080252DF)) return;
            continue :blk 22;
        },
        18 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(rt.r[4] +% 0x8);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[4] +% 0x8, rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x29, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            continue :blk 11;
        },
        19 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[4] +% 0x8);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[4] +% 0x8, rt.r[1]);
            rt.r[0] = abi.read8(rt.r[4] +% 0xC);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[4] +% 0xC, @truncate(rt.r[0]));
            continue :blk 11;
        },
        20 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[4] +% 0x8);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[4] +% 0x8, rt.r[1]);
            rt.r[0] = abi.read8(rt.r[4] +% 0xD);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[4] +% 0xD, @truncate(rt.r[0]));
            continue :blk 11;
        },
        21 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[4] +% 0x8);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[4] +% 0x8, rt.r[1]);
            rt.r[0] = abi.read8(rt.r[4] +% 0xE);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[4] +% 0xE, @truncate(rt.r[0]));
            continue :blk 11;
        },
        22 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[4] +% 0x8);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[4] +% 0x8, rt.r[1]);
            rt.r[0] = abi.read8(rt.r[4] +% 0xF);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[4] +% 0xF, @truncate(rt.r[0]));
            continue :blk 11;
        },
        else => unreachable,
    }
}

fn func_08025310() callconv(.c) void {
    if (!abi.enter(0x08025310)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(29);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[3] = abi.read32(0x08025358);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.r[12] = rt.r[0];
            rt.r[2] = abi.read32(0x0802535C);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[4] = rt.r[12];
            abi.setRegNz(&rt.r[4], rt.r[4] *% rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            rt.r[7] = abi.read32(rt.r[4] +% 0x8);
            rt.r[6] = abi.read32(0x08025360);
            rt.r[0] = abi.read8(rt.r[4] +% 0x1E);
            abi.setRegNz(&rt.r[5], rt.r[0] << 7);
            rt.r[0] = abi.read32(0x08025364);
            rt.r[1] = abi.read8(rt.r[0] +% 0x8);
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[2];
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            rt.r[10] = rt.r[0];
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x92);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.r[1] = abi.read8(rt.r[4] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            abi.setRegNz(&rt.r[4], 0x28);
            rt.r[3] = rt.sext16(abi.read16(rt.r[0] +% rt.r[4]));
            rt.r[0] = abi.read32(0x080253A8);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(16);
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            rt.r[5] = rt.r[9];
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = rt.r[8];
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.r[5] = abi.read8(rt.r[1] +% 0x1E);
            abi.setRegNz(&rt.r[2], rt.r[5] << 7);
            rt.r[5] = rt.r[10];
            rt.r[0] = abi.read8(rt.r[5] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[3], true);
            continue :blk 8;
        },
        6 => {
            abi.fetches(10);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            continue :blk 9;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x92);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            rt.r[0] = rt.r[12];
            if (!abi.call(decls.func_08024154, 0x080253C7)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[3], true);
            continue :blk 8;
        },
        10 => {
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

fn func_0802566C() callconv(.c) void {
    if (!abi.enter(0x0802566C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.r[8] = rt.r[1];
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(18);
            rt.r[1] = abi.read32(0x08025710);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[1], rt.r[0], true);
            rt.cpuSub(&rt.r[0], rt.r[6], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[2] << 16);
            abi.setRegNz(&rt.r[7], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(decls.func_080255EC, 0x080256A1)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x4);
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(decls.func_080255EC, 0x080256B9)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[4], rt.r[4] | rt.r[0]);
            continue :blk 9;
        },
        9 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[0], 16));
            rt.r[1] = rt.r[8];
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_080255EC, 0x080256D9)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[4], rt.r[4] | rt.r[0]);
            continue :blk 12;
        },
        12 => {
            abi.fetches(10);
            rt.r[1] = rt.r[8];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_080255EC, 0x080256F5)) return;
            continue :blk 13;
        },
        13 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 15;
            }
            continue :blk 14;
        },
        14 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[4], rt.r[4] | rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            continue :blk 15;
        },
        15 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08025714() callconv(.c) void {
    if (!abi.enter(0x08025714)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x0802577C);
            rt.r[3] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x13);
            rt.cpuSub(null, rt.r[1], 0x1, true);
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
            abi.fetches(5);
            rt.r[2] = abi.read8(rt.r[0] +% 0x11);
            rt.cpuSub(null, rt.r[2], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
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
            abi.fetches(32);
            rt.r[5] = abi.read8(rt.r[0] +% 0x11);
            rt.r[6] = abi.read32(0x08025780);
            abi.setRegNz(&rt.r[3], rt.r[3] << 2);
            rt.r[0] = abi.read32(0x08025784);
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
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            rt.r[1] = abi.read32(0x08025788);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x68, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1E);
            abi.setRegNz(&rt.r[0], rt.r[2] << 7);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read32(0x0802578C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[0] +% 0x11);
            continue :blk 8;
        },
        6 => {
            abi.fetches(9);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            continue :blk 9;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x92);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            continue :blk 8;
        },
        10 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[4] = abi.read16(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_080257C8() callconv(.c) void {
    if (!abi.enter(0x080257C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x08025828);
            rt.r[3] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x11);
            rt.cpuSub(null, rt.r[1], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[0] +% 0x11);
            continue :blk 3;
        },
        2 => {
            abi.fetches(32);
            rt.r[5] = abi.read8(rt.r[0] +% 0x11);
            rt.r[6] = abi.read32(0x0802582C);
            abi.setRegNz(&rt.r[3], rt.r[3] << 2);
            rt.r[0] = abi.read32(0x08025830);
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
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            rt.r[1] = abi.read32(0x08025834);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x68, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1E);
            abi.setRegNz(&rt.r[0], rt.r[2] << 7);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read32(0x08025838);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
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
            abi.fetches(9);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            continue :blk 8;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x92);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            continue :blk 8;
        },
        6 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[4] = abi.read16(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 10;
        },
        8 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            continue :blk 3;
        },
        9 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_0802588C() callconv(.c) void {
    if (!abi.enter(0x0802588C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[3], 0x0, true);
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
            rt.r[0] = abi.read32(0x0802591C);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
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
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[1] = abi.read16(rt.r[2] +% 0x2);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.r[4] = abi.read32(0x08025920);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[3], true);
            rt.r[3] = abi.read32(0x08025924);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0xC0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.r[1] = abi.read32(0x08025928);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x0802592C);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(0x08025930);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08025934);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x08025938);
            abi.setRegNz(&rt.r[1], rt.r[2] << 3);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read16(rt.r[3] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[4] << 21);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 28);
            rt.r[2] = abi.read8(rt.r[1] +% 0xD);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(8);
            rt.r[3] = abi.read8(rt.r[3] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[3] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.r[1] = abi.read8(rt.r[1] +% 0x12);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 1;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08025AA4() callconv(.c) void {
    if (!abi.enter(0x08025AA4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(32);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[2] = abi.read32(0x08025B3C);
            rt.r[10] = rt.r[2];
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 15));
            rt.r[8] = rt.r[1];
            rt.r[3] = abi.read32(0x08025B40);
            rt.r[9] = rt.r[3];
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            rt.r[1] +%= rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[7], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x12, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            rt.r[6] = abi.read32(0x08025B44);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.r[0] << 2);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[0], rt.r[4], true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
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
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.r[1] = abi.read32(0x08025B48);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            if (!abi.call(decls.func_0802544C, 0x08025AEB)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
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
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read32(0x08025B4C);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            if (!abi.call(decls.func_08024614, 0x08025AFF)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(28);
            rt.r[1] = abi.read32(0x08025B50);
            rt.r[2] = abi.read8(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = rt.r[10];
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            rt.r[3] = rt.r[9];
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.r[0] +%= rt.r[8];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[3] = abi.read32(0x08025B54);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1A, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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

fn func_08025C70() callconv(.c) void {
    if (!abi.enter(0x08025C70)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[0] = abi.read32(0x08025C84);
            rt.r[7] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[8] = rt.r[0];
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[2] = abi.read32(0x08025D40);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[8], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[7] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08025D44);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[7], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 3));
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        3 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[1] +%= rt.r[8];
            rt.r[10] = rt.r[1];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08025D2C);
            rt.r[2] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[9] = rt.r[0];
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            rt.r[8] = rt.r[10];
            continue :blk 1;
        },
        6 => {
            abi.fetches(10);
            rt.r[1] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(15);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            rt.r[3] = rt.r[8];
            abi.setRegNz(&rt.r[2], rt.r[3] << 1);
            rt.r[3] = abi.read32(0x08025D30);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x1, true);
            rt.r[3] = abi.read32(0x08025D40);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        9 => {
            abi.fetches(7);
            rt.r[5] = abi.read32(0x08025D34);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0802544C, 0x08025CD9)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(7);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.r[2] = abi.read32(0x08025D38);
            if (!abi.call(decls.func_08023888, 0x08025CEB)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08025D3C);
            abi.setRegNz(&rt.r[1], 0x18);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(4);
            abi.write16(rt.r[7] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[7], rt.r[7], 0x8, true);
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_08025D48() callconv(.c) void {
    if (!abi.enter(0x08025D48)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x4;
            rt.r[1] = abi.read32(0x08025DE8);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(0x08025DEC);
            rt.r[9] = rt.r[0];
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[7] = abi.read32(0x08025DE8);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 3));
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(4);
            rt.r[8] = rt.r[9];
            rt.r[10] = rt.r[9];
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.r[8];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[7], rt.r[4], 0x1, true);
            abi.write32(rt.r[13] +% 0x0, rt.r[7]);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.r[1] = abi.read32(0x08025DF0);
            rt.cpuAdd(&rt.r[6], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[5], rt.r[4] << 1);
            rt.r[12] = rt.r[10];
            continue :blk 6;
        },
        5 => {
            abi.fetches(8);
            rt.r[4] = abi.read32(rt.r[13] +% 0x0);
            rt.r[3] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(15);
            rt.r[7] = rt.r[8];
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[7] = abi.read32(0x08025DF4);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[7], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[7] = abi.read32(0x08025DF8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.r[1] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        9 => {
            abi.fetches(6);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            abi.write16(rt.r[2] +% 0x4, @truncate(rt.r[3]));
            abi.write16(rt.r[2] +% 0x6, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x8, true);
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_08025DFC() callconv(.c) void {
    if (!abi.enter(0x08025DFC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.r[13] -%= 0x8;
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = abi.read32(0x08025E20);
            rt.r[5] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08025E24);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
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
            abi.fetches(9);
            abi.setRegNz(&rt.r[7], 0x0);
            rt.r[1] = abi.read32(0x08025EB8);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[9] = rt.r[1];
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08025EC0);
            abi.write16(rt.r[5] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x1, true);
            rt.r[8] = rt.r[1];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(9);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08025EBC);
            abi.setRegNz(&rt.r[0], rt.r[7] << 2);
            rt.cpuAdd(&rt.r[6], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(0x08025EB8);
            rt.r[9] = rt.r[0];
            abi.setRegNz(&rt.r[2], rt.r[7] << 16);
            continue :blk 8;
        },
        7 => {
            abi.fetches(8);
            rt.r[7] = rt.r[8];
            rt.r[1] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[7], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        8 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[2], 16));
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            abi.write32(rt.r[13] +% 0x4, rt.r[3]);
            if (!abi.call(decls.func_08025B68, 0x08025E6D)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[0] = abi.read32(0x08025EB8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        11 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            rt.r[3] = abi.read32(rt.r[13] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[4]));
            abi.write8(rt.r[5] +% 0x1, @truncate(rt.r[7]));
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.write16(rt.r[5] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x4, true);
            continue :blk 10;
        },
        else => unreachable,
    }
}

fn func_08025EC4() callconv(.c) void {
    if (!abi.enter(0x08025EC4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[0] = abi.read32(0x08025EDC);
            rt.r[6] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[7], 0x0);
            rt.r[2] = abi.read32(0x08025EE0);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[10] = rt.r[2];
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[7], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08025F7C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[6], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 3));
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        3 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x1, true);
            rt.r[9] = rt.r[1];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08025F6C);
            rt.r[10] = rt.r[2];
            abi.setRegNz(&rt.r[0], rt.r[7] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[8] = rt.r[0];
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[7] = rt.r[9];
            rt.r[2] = rt.r[10];
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            continue :blk 1;
        },
        6 => {
            abi.fetches(10);
            rt.r[1] = rt.r[8];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[7] << 1);
            rt.r[3] = abi.read32(0x08025F70);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[4] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            rt.r[3] = abi.read32(0x08025F78);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        9 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08025F74);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08024594, 0x08025F31)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            abi.write16(rt.r[6] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x8, true);
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_08025F80() callconv(.c) void {
    if (!abi.enter(0x08025F80)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.r[13] -%= 0x4;
            rt.r[0] = abi.read32(0x08025F98);
            rt.r[5] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = abi.read32(0x08025F9C);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0802601C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 3));
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        3 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x1, true);
            rt.r[8] = rt.r[1];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08026014);
            abi.setRegNz(&rt.r[0], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[7], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read32(0x08026018);
            abi.setRegNz(&rt.r[6], rt.r[2] << 16);
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[2] = rt.r[8];
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            continue :blk 1;
        },
        6 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[6], 16));
            abi.write32(rt.r[13] +% 0x0, rt.r[3]);
            if (!abi.call(func_0802588C, 0x08025FD3)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[0] = abi.read32(0x08026018);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        9 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.r[3] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            rt.r[0] = rt.r[9];
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x8, true);
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_08026870() callconv(.c) void {
    if (!abi.enter(0x08026870)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.r[9] = rt.r[1];
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 24);
            abi.setRegNz(&rt.r[5], rt.r[3] >> 24);
            abi.setRegNz(&rt.r[0], rt.r[2] >> 16);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[2], 16));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080147B8, 0x08026895)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080148DC, 0x0802689B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x080268C0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x3);
            if (!abi.call(decls.func_0801381C, 0x080268A5)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x080268C4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 20));
            rt.cpuSub(&rt.r[0], rt.r[7], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[6], 0x28);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_080136A4, 0x080268D7)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            rt.r[6] = abi.read32(0x080268C8);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080136A4, 0x080268BF)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(22);
            rt.r[1] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[7] << 4);
            rt.r[2] = abi.read32(0x08026924);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            rt.r[2] = abi.read16(rt.r[3] +% 0x4);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[6], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[4] = rt.r[9];
            abi.setRegNz(&rt.r[2], rt.r[4] << 4);
            rt.r[3] = abi.read16(rt.r[3] +% 0x6);
            rt.cpuSub(&rt.r[2], rt.r[2], rt.r[3], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x8, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            if (!abi.call(decls.func_08013550, 0x080268FF)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            continue :blk 6;
        },
        8 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08026928);
            rt.r[1] = abi.read32(0x0802692C);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 5);
            if (!abi.call(decls.func_0800FDA4, 0x0802690B)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08026930);
            abi.setRegNz(&rt.r[1], 0x98);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_08011330, 0x08026917)) return;
            continue :blk 10;
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

fn func_08026A30() callconv(.c) void {
    if (!abi.enter(0x08026A30)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(33);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.r[3] = abi.read32(0x08026A84);
            rt.r[1] = abi.read32(0x08026A88);
            rt.r[2] = abi.read32(0x08026A8C);
            rt.r[0] = abi.read32(0x08026A90);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[0]);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1D);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[3], true);
            rt.r[7] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[6], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x29, true);
            rt.r[0] = abi.read32(0x08026A94);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 1);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x08026B3C);
            abi.setRegNz(&rt.r[2], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x6);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.r[2] = abi.read32(0x08026B40);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_0801B888, 0x08026AB3)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x08026A98);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x2);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.r[2] = abi.read32(0x08026A9C);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_0801B888, 0x08026A81)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(11);
            rt.r[4] = abi.read32(0x08026B44);
            rt.cpuAdd(&rt.r[1], rt.r[6], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.r[5] = abi.read32(0x08026B48);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[2], 0xA0);
            if (!abi.call(decls.func_0800FFA8, 0x08026AC5)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            continue :blk 3;
        },
        5 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x5, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xA0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[2], 0xA0);
            if (!abi.call(decls.func_0800FFA8, 0x08026ADB)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x5, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], 0xA0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[6], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[2], 0xA0);
            if (!abi.call(decls.func_0800FFA8, 0x08026AF3)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x5, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[2], 0xF0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[6], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[2], 0xA0);
            if (!abi.call(decls.func_0800FFA8, 0x08026B0B)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(15);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x5, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], 0xA0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[1], true);
            rt.cpuAdd(&rt.r[4], rt.r[6], rt.r[4], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 5);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[2], 0xA0);
            if (!abi.call(decls.func_0800FFA8, 0x08026B25)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[1], 0xB8);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = rt.r[8];
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_08011330, 0x08026B31)) return;
            continue :blk 10;
        },
        10 => {
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

fn func_08026BE0() callconv(.c) void {
    if (!abi.enter(0x08026BE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801C000, 0x08026BEF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801C018, 0x08026BF7)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801C000, 0x08026C0F)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801C018, 0x08026C01)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801BF50, 0x08026C09)) return;
            continue :blk 3;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0801C000, 0x08026C1D)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.r[6] = abi.read32(0x08026C78);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[5], rt.r[0] << 1);
            continue :blk 11;
        },
        10 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[1], 0x76);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0801C018, 0x08026C29)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(23);
            rt.r[0] = abi.read32(0x08026C7C);
            abi.setRegNz(&rt.r[3], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[2] = abi.read16(rt.r[3] +% 0x2);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x08026C80);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[3] << 5);
            rt.r[3] = abi.read32(0x08026C84);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 21);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            if (!abi.call(decls.func_0800FFA8, 0x08026C69)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080796C8, 0x08026C31)) return;
            continue :blk 14;
        },
        13 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0xE, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 11;
            }
            continue :blk 15;
        },
        14 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            continue :blk 9;
        },
        15 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080273D8() callconv(.c) void {
    if (!abi.enter(0x080273D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(25);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.r[9] = rt.r[0];
            rt.r[6] = abi.read32(0x08027474);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[8] = rt.r[2];
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.r[5] = abi.read32(0x08027478);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[1] +% rt.r[3]));
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_080137E4, 0x08027407)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(18);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x9);
            rt.r[4] = rt.sext8(abi.read8(rt.r[1] +% rt.r[4]));
            rt.r[7] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[7] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[7], 0x0);
            rt.r[3] = rt.sext16(abi.read16(rt.r[0] +% rt.r[7]));
            rt.r[1] = abi.read8(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            rt.r[0] = abi.read32(0x0802747C);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[0]);
            abi.setRegNz(&rt.r[2], rt.r[2] << 8);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_080137E4, 0x08027439)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xFF, true);
            continue :blk 2;
        },
        4 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xA);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[1] +% rt.r[3]));
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_080137E4, 0x0802744F)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(11);
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            rt.r[7] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[7] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = rt.r[8];
            rt.r[1] = rt.r[9];
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
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

fn func_08027480() callconv(.c) void {
    if (!abi.enter(0x08027480)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08013310, 0x0802748D)) return;
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
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08013770, 0x0802749F)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[6], rt.r[4] >> 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 17);
            rt.cpuSub(&rt.r[4], rt.r[6], rt.r[4], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[6], rt.r[4] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_080137C0, 0x080274B3)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 17);
            rt.cpuSub(&rt.r[4], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.r[4] >> 16);
            rt.cpuSub(null, rt.r[6], 0x10, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x10, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08013744, 0x080274CF)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], rt.r[6] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[2], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_080137E4, 0x080274F1)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08013794, 0x080274D7)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            continue :blk 5;
        },
        12 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08013248, 0x080274DD)) return;
            continue :blk 13;
        },
        13 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_080274F8() callconv(.c) void {
    if (!abi.enter(0x080274F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.r[4] = abi.read32(0x08027574);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            abi.setRegNz(&rt.r[5], 0x1);
            rt.cpuSub(&rt.r[5], 0, rt.r[5], true);
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x9);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(func_08027480, 0x08027511)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(func_08027480, 0x08027523)) return;
            continue :blk 6;
        },
        4 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xA);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.write8(rt.r[1] +% 0x8, @truncate(rt.r[0]));
            continue :blk 1;
        },
        6 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.write8(rt.r[1] +% 0x9, @truncate(rt.r[0]));
            continue :blk 4;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(func_08027480, 0x08027535)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xB);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.write8(rt.r[1] +% 0xA, @truncate(rt.r[0]));
            continue :blk 8;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(func_08027480, 0x08027547)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(18);
            rt.r[2] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.r[0] = rt.sext8(abi.read8(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[1], 0x9);
            rt.r[1] = rt.sext8(abi.read8(rt.r[2] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0xA);
            rt.r[1] = rt.sext8(abi.read8(rt.r[2] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0xB);
            rt.r[1] = rt.sext8(abi.read8(rt.r[2] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x4);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        12 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.write8(rt.r[1] +% 0xB, @truncate(rt.r[0]));
            continue :blk 11;
        },
        13 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[6] +% 0x8, rt.r[0]);
            continue :blk 14;
        },
        14 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08027620() callconv(.c) void {
    if (!abi.enter(0x08027620)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            if (!abi.call(decls.func_08027578, 0x0802762B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            rt.r[5] = abi.read32(0x08027664);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.r[4] = rt.r[13];
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.r[1] = rt.r[13];
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013578, 0x08027641)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x5);
            rt.r[1] = rt.sext8(abi.read8(rt.r[0] +% rt.r[1]));
            rt.r[0] = abi.read8(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x2, true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(15);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(0x080276A0);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.r[1] = rt.r[13];
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[3] +% rt.r[5]));
            if (!abi.call(decls.func_08013550, 0x08027685)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x2, true);
            continue :blk 5;
        },
        7 => {
            abi.fetches(10);
            rt.r[4] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x4);
            rt.r[1] = rt.sext8(abi.read8(rt.r[4] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x5);
            rt.r[0] = rt.sext8(abi.read8(rt.r[4] +% rt.r[0]));
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            continue :blk 12;
        },
        10 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[2], rt.r[1], 0x1, true);
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            continue :blk 12;
        },
        12 => {
            abi.fetches(13);
            abi.write8(rt.r[4] +% 0x4, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(0x080276DC);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x9);
            rt.r[2] = rt.sext8(abi.read8(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[1], 0x4);
            rt.r[1] = rt.sext8(abi.read8(rt.r[0] +% rt.r[1]));
            rt.r[0] = abi.read32(0x080276E0);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xFF, true);
            continue :blk 14;
        },
        14 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 8));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08013794, 0x080276C7)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read8(rt.r[0] +% 0x4);
            rt.r[2] = abi.read8(rt.r[0] +% 0x5);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if (!rt.CPU_Z) {
                continue :blk 17;
            }
            continue :blk 16;
        },
        16 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[6] +% 0x8, rt.r[0]);
            continue :blk 17;
        },
        17 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08027710() callconv(.c) void {
    if (!abi.enter(0x08027710)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            if (!abi.call(decls.func_08027578, 0x0802771B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            rt.r[5] = abi.read32(0x080277CC);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.r[4] = rt.r[13];
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.r[1] = rt.r[13];
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013578, 0x08027731)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(16);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x2, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.r[1] = rt.r[13];
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[4] +% rt.r[3]));
            if (!abi.call(decls.func_08013550, 0x0802774D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(15);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[1] +% 0x4, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x9);
            rt.r[2] = rt.sext8(abi.read8(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[1], 0x4);
            rt.r[1] = rt.sext8(abi.read8(rt.r[0] +% rt.r[1]));
            rt.r[0] = abi.read32(0x080277D0);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 8));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08013794, 0x08027771)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xFF, true);
            continue :blk 4;
        },
        6 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0xC, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[2], 0x1C);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[3], 0x1E);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[3]));
            if (!abi.call(decls.func_08027150, 0x08027785)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x4);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0xB, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.write8(rt.r[1] +% 0xB, @truncate(rt.r[0]));
            continue :blk 8;
        },
        10 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[0], 0xB);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.r[2] = abi.read32(0x080277D4);
            rt.r[1] = abi.read8(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(decls.func_08013794, 0x080277AB)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[3] = abi.read8(rt.r[0] +% 0x4);
            rt.cpuSub(null, rt.r[3], 0x14, true);
            if (!rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(8);
            rt.r[0] = abi.read8(rt.r[0] +% 0xA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_080136A4, 0x080277BF)) return;
            continue :blk 14;
        },
        13 => {
            abi.fetches(6);
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        14 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x080277D8);
            abi.write32(rt.r[6] +% 0x8, rt.r[0]);
            continue :blk 13;
        },
        else => unreachable,
    }
}

fn func_08027AB0() callconv(.c) void {
    if (!abi.enter(0x08027AB0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x08027B28);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            if (!abi.call(decls.func_08013770, 0x08027ABD)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
            rt.r[2] = abi.read32(0x08027B2C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            if (!abi.call(decls.func_08013744, 0x08027ACF)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            if (!abi.call(decls.func_080137C0, 0x08027AD7)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
            rt.r[2] = abi.read32(0x08027B2C);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            if (!abi.call(decls.func_08013794, 0x08027AE9)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            if (!abi.call(decls.func_080138A4, 0x08027AF1)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
            rt.r[1] = abi.read32(0x08027B30);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013878, 0x08027B05)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
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
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[2]));
            if (!abi.call(decls.func_0801490C, 0x08027B11)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_080136A4, 0x08027B1B)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08027B21)) return;
            continue :blk 7;
        },
        else => unreachable,
    }
}

fn func_08027C3C() callconv(.c) void {
    if (!abi.enter(0x08027C3C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08027C88);
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
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x46, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[4] = abi.read32(0x08027C8C);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801329C, 0x08027C57)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(3);
            continue :blk 6;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x08027CAC);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08027DE2 => continue :blk 9,
                0x08027E0C => { continue :blk 6; },
                0x08027DCC => continue :blk 7,
                0x08027DDA => continue :blk 8,
                0x08027E08 => continue :blk 10,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801329C, 0x08027C5D)) return;
            continue :blk 11;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[5] +% 0x1E);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[5] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 12;
        },
        7 => {
            abi.fetches(9);
            rt.r[0] = abi.read16(rt.r[5] +% 0x20);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write16(rt.r[5] +% 0x20, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08027E04);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x63, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08027E04);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x9, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(8);
            rt.r[4] = abi.read16(rt.r[5] +% 0x20);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[5] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x5);
            if (!abi.call(decls.func_0807B488, 0x08027DEF)) return;
            continue :blk 13;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[5] +% 0x8, rt.r[0]);
            continue :blk 6;
        },
        11 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801329C, 0x08027C63)) return;
            continue :blk 14;
        },
        12 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        13 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 20);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x50);
            if (!abi.call(decls.func_08027B7C, 0x08027DFD)) return;
            continue :blk 15;
        },
        14 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801329C, 0x08027C69)) return;
            continue :blk 16;
        },
        15 => {
            abi.fetches(6);
            rt.r[0] = abi.read16(rt.r[5] +% 0x20);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x18, true);
            abi.write16(rt.r[5] +% 0x20, @truncate(rt.r[0]));
            continue :blk 6;
        },
        16 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801329C, 0x08027C6F)) return;
            continue :blk 17;
        },
        17 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801329C, 0x08027C75)) return;
            continue :blk 18;
        },
        18 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08027C90);
            if (!abi.call(decls.func_0801329C, 0x08027C7B)) return;
            continue :blk 19;
        },
        19 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08027C94);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[5] +% 0x8, rt.r[0]);
            continue :blk 12;
        },
        else => unreachable,
    }
}

fn func_08027E40() callconv(.c) void {
    if (!abi.enter(0x08027E40)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08027F08);
            rt.r[4] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[5], 0x5);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_0807B6AC, 0x08027E55)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08027E18, 0x08027E5F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.cpuSub(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_0807B634, 0x08027E6D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0xA);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_08027E18, 0x08027E7D)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0xB);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08027E18, 0x08027E85)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0xC);
            abi.setRegNz(&rt.r[1], 0x2);
            if (!abi.call(decls.func_08027E18, 0x08027E8D)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08027F0C);
            abi.setRegNz(&rt.r[1], 0x98);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_08011330, 0x08027E99)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08027F10);
            rt.r[1] = abi.read32(0x08027F14);
            abi.setRegNz(&rt.r[2], 0xC0);
            if (!abi.call(decls.func_0800FFA8, 0x08027EA3)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(19);
            rt.r[2] = abi.read32(0x08027F18);
            rt.r[0] = abi.read32(0x08027F1C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1A);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x08027F20);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x90);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_08011330, 0x08027EC5)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08027F24);
            rt.r[1] = abi.read32(0x08027F28);
            rt.r[2] = abi.read32(0x08027F2C);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x7);
            if (!abi.call(decls.func_08010C18, 0x08027ED5)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x08027ED9)) return;
            continue :blk 13;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021EEC, 0x08027EDD)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[0] = abi.read32(0x08027F08);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x9, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        15 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x2);
            continue :blk 16;
        },
        16 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x63, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 18;
            }
            continue :blk 17;
        },
        17 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x3);
            continue :blk 18;
        },
        18 => {
            abi.fetches(15);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x3, true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 3);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            abi.write16(rt.r[6] +% 0x20, @truncate(rt.r[0]));
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08028358() callconv(.c) void {
    if (!abi.enter(0x08028358)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x2C;
            rt.r[1] = abi.read32(0x080283E8);
            rt.r[0] = rt.r[13];
            abi.setRegNz(&rt.r[2], 0x12);
            if (!abi.call(decls.func_0807A8A0, 0x08028367)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(33);
            rt.r[0] = abi.read32(0x080283EC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[13] +% 0x24, rt.r[0]);
            abi.write32(rt.r[13] +% 0x28, rt.r[1]);
            rt.r[4] = rt.r[13] +% 0x14;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.r[0] = abi.read32(0x080283F0);
            ldmRegs(0, &.{ 2, 3, 5 });
            stmRegs(1, &.{ 2, 3, 5 });
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            rt.r[5] = abi.read32(0x080283F4);
            rt.r[6] = abi.read32(0x080283F8);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[6] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = rt.r[13] +% 0x24;
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[1], 0x8);
            if (!abi.call(decls.func_08011140, 0x080283A5)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(21);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[6] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[3], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[13];
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[5]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.r[2] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_08011140, 0x080283CB)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080283FC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x9);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0x2C;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[6] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x080283DF)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802887C() callconv(.c) void {
    if (!abi.enter(0x0802887C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.r[1] = abi.read32(0x08028928);
            abi.setRegNz(&rt.r[0], 0x1);
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
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(decls.func_08024CD0, 0x08028897)) return;
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
            abi.fetches(12);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[3] = abi.read32(0x0802892C);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        7 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x19, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 9);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[1], 0x18, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[5] = abi.read32(0x08028930);
            rt.r[1] = abi.read32(0x08028934);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x36, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        12 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            continue :blk 14;
        },
        13 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x33, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        14 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[5], 0x80);
            abi.setRegNz(&rt.r[5], rt.r[5] << 9);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[1], 0x32, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 15;
        },
        15 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[3] +% rt.r[5]));
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        else => unreachable,
    }
}

fn func_08028940() callconv(.c) void {
    if (!abi.enter(0x08028940)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(decls.func_08024CD0, 0x0802894D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[4] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[4], rt.r[5] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0802877C, 0x0802895D)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 9);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
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
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x20);
            if (!abi.call(decls.func_08028734, 0x0802896B)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080287A8, 0x08028973)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(3);
            continue :blk 4;
        },
        10 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x10);
            if (!abi.call(decls.func_08028734, 0x08028981)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_0802887C, 0x08028989)) return;
            continue :blk 14;
        },
        13 => {
            abi.fetches(3);
            continue :blk 4;
        },
        14 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        15 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08028734, 0x08028997)) return;
            continue :blk 17;
        },
        16 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080287E8, 0x0802899F)) return;
            continue :blk 18;
        },
        17 => {
            abi.fetches(3);
            continue :blk 4;
        },
        18 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 19;
        },
        19 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x2);
            if (!abi.call(decls.func_08028734, 0x080289AD)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_080289C0() callconv(.c) void {
    if (!abi.enter(0x080289C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(decls.func_08024CD0, 0x080289CD)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[4] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[4], rt.r[5] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0802877C, 0x080289DD)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 9);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
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
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x20);
            if (!abi.call(decls.func_08028714, 0x080289EB)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080287A8, 0x080289F3)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(3);
            continue :blk 4;
        },
        10 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x10);
            if (!abi.call(decls.func_08028714, 0x08028A01)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_0802887C, 0x08028A09)) return;
            continue :blk 14;
        },
        13 => {
            abi.fetches(3);
            continue :blk 4;
        },
        14 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        15 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08028714, 0x08028A17)) return;
            continue :blk 17;
        },
        16 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080287E8, 0x08028A1F)) return;
            continue :blk 18;
        },
        17 => {
            abi.fetches(3);
            continue :blk 4;
        },
        18 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 19;
        },
        19 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x2);
            if (!abi.call(decls.func_08028714, 0x08028A2D)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08028F94() callconv(.c) void {
    if (!abi.enter(0x08028F94)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(25);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[3] = abi.read32(0x08028FDC);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = abi.read32(0x08028FE0);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            rt.r[5] = abi.read32(0x08028FE4);
            rt.r[2] = abi.read32(0x08028FE8);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x20);
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[2];
            rt.cpuSub(null, rt.r[0], 0x8, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(15);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            rt.r[3] = rt.r[9];
            abi.setRegNz(&rt.r[7], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[7]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x10, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x08028FEC);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(decls.func_08020380, 0x08028FCF)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 6;
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
        5 => {
            abi.fetches(7);
            rt.r[1] = rt.r[9];
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(decls.func_08013248, 0x08028FD9)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            rt.r[2] = rt.r[8];
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x80, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            continue :blk 4;
        },
        8 => {
            abi.fetches(7);
            rt.r[3] = abi.read32(0x080290B4);
            rt.r[12] = rt.r[3];
            rt.r[6] = abi.read32(0x080290B8);
            rt.r[7] = abi.read16(rt.r[6] +% 0x4);
            rt.r[10] = rt.r[7];
            continue :blk 9;
        },
        9 => {
            abi.fetches(62);
            abi.setRegNz(&rt.r[2], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.r[1] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[3], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[5] = abi.read16(rt.r[0] +% 0x0);
            rt.r[7] = abi.read16(rt.r[0] +% 0x4);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[7], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[5] = abi.read16(rt.r[0] +% 0x2);
            rt.r[7] = abi.read16(rt.r[0] +% 0x6);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[7], true);
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            rt.r[5] = abi.read32(0x080290BC);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x6);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.r[7] = abi.read16(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[1], true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.r[1] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x4);
            rt.cpuSub(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[3] = abi.read32(0x080290C0);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[5] = abi.read16(rt.r[6] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.r[7] = rt.r[10];
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[7]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x4, true);
            rt.r[1] = abi.read32(0x080290C4);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            rt.r[3] = rt.r[9];
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[5]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[7] = abi.read32(0x080290C8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 16);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1E);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(7);
            rt.r[2] = rt.r[8];
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x80, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_080290EC() callconv(.c) void {
    if (!abi.enter(0x080290EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08029178);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x4);
            abi.write16(rt.r[2] +% 0x1E, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x6);
            abi.write16(rt.r[2] +% 0x20, @truncate(rt.r[0]));
            rt.r[3] = abi.read16(rt.r[2] +% 0x22);
            rt.r[4] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(&rt.r[0], rt.r[3], rt.r[4], true);
            abi.write16(rt.r[2] +% 0x26, @truncate(rt.r[0]));
            rt.r[6] = abi.read16(rt.r[2] +% 0x24);
            rt.r[1] = abi.read16(rt.r[1] +% 0x6);
            rt.cpuSub(&rt.r[0], rt.r[6], rt.r[1], true);
            abi.write16(rt.r[2] +% 0x28, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x26);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[3], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[4], 0, rt.r[1], true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[3], 0, rt.r[0], true);
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], rt.r[3], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[2] +% 0x2A, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[0], rt.r[3], 0x1, true);
            rt.r[5] = abi.read32(0x0802917C);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[5], 0x0, true);
            continue :blk 11;
        },
        10 => {
            abi.fetches(10);
            rt.r[1] = abi.read16(rt.r[2] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            abi.write16(rt.r[2] +% 0x2C, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        11 => {
            abi.fetches(10);
            rt.cpuSub(&rt.r[0], rt.r[3], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.r[6] = abi.read16(rt.r[2] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[4], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuSub(null, rt.r[1], 0x7, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            continue :blk 13;
        },
        13 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[2] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[2] +% 0x2A, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        else => unreachable,
    }
}

fn func_08029180() callconv(.c) void {
    if (!abi.enter(0x08029180)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x26);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x080291C0);
            rt.r[3] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x2C, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[4] +% 0x2C);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x0802920C);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read16(rt.r[4] +% 0x2C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.write16(rt.r[4] +% 0x2C, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[4] +% 0x2C);
            abi.setRegNz(&rt.r[3], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[3]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        8 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            continue :blk 12;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        10 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            continue :blk 14;
        },
        11 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[5], 0, rt.r[1], true);
            continue :blk 12;
        },
        12 => {
            abi.fetches(8);
            rt.r[3] = abi.read16(rt.r[4] +% 0x28);
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[2], 0x26);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            if (!abi.call(decls.func_0807B488, 0x080291D3)) return;
            continue :blk 15;
        },
        13 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[5], 0, rt.r[1], true);
            continue :blk 14;
        },
        14 => {
            abi.fetches(8);
            rt.r[1] = abi.read16(rt.r[4] +% 0x26);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], 0x28);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            if (!abi.call(decls.func_0807B488, 0x0802921F)) return;
            continue :blk 16;
        },
        15 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[3], rt.r[0] << 16);
            rt.r[0] = abi.read16(rt.r[4] +% 0x20);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            continue :blk 17;
        },
        16 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[3] = abi.read16(rt.r[4] +% 0x1E);
            abi.setRegNz(&rt.r[1], rt.r[3] << 16);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0x20);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            continue :blk 17;
        },
        17 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(0x08029270);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 19;
            }
            continue :blk 18;
        },
        18 => {
            abi.fetches(4);
            rt.r[3] = abi.read32(0x08029274);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            continue :blk 19;
        },
        19 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.write16(rt.r[2] +% 0x4, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 21;
            }
            continue :blk 20;
        },
        20 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(0x08029274);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            continue :blk 21;
        },
        21 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.write16(rt.r[2] +% 0x6, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 23;
            }
            continue :blk 22;
        },
        22 => {
            abi.fetches(11);
            rt.r[0] = abi.read16(rt.r[4] +% 0x22);
            abi.write16(rt.r[2] +% 0x4, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[4] +% 0x24);
            abi.write16(rt.r[2] +% 0x6, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08029278);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            if (!abi.call(decls.func_08013248, 0x08029269)) return;
            continue :blk 24;
        },
        23 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x2A, @truncate(rt.r[0]));
            continue :blk 25;
        },
        24 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035230, 0x0802926D)) return;
            continue :blk 26;
        },
        25 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080212F4, 0x08029285)) return;
            continue :blk 27;
        },
        26 => {
            abi.fetches(3);
            continue :blk 25;
        },
        27 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080296C0() callconv(.c) void {
    if (!abi.enter(0x080296C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            if (!abi.call(decls.func_080212B8, 0x080296C7)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021194, 0x080296CB)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021398, 0x080296CF)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08029654, 0x080296D3)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_08020D14, 0x0802974F)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(decls.func_08020D14, 0x080296DF)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08029788);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08029728);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 11;
        },
        9 => {
            abi.fetches(18);
            rt.r[2] = abi.read32(0x0802978C);
            rt.r[1] = abi.read32(0x08029790);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x2);
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08029794);
            abi.setRegNz(&rt.r[5], 0x1);
            rt.cpuSub(&rt.r[5], 0, rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08029798);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(decls.func_08013248, 0x0802977D)) return;
            continue :blk 12;
        },
        10 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        11 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802972C);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(decls.func_08013248, 0x080296F7)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080290E0, 0x08029781)) return;
            continue :blk 10;
        },
        13 => {
            abi.fetches(26);
            rt.r[1] = abi.read32(0x08029730);
            rt.r[3] = abi.read32(0x08029734);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x2);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            rt.r[4] = abi.read32(0x08029738);
            rt.r[0] = abi.read32(0x0802973C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[5] = abi.read16(rt.r[3] +% 0x2);
            abi.setRegNz(&rt.r[2], rt.r[5] << 1);
            rt.r[5] = abi.read32(0x08029740);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[2] = abi.read32(0x08029744);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_080290E0, 0x08029727)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(3);
            continue :blk 10;
        },
        else => unreachable,
    }
}

fn func_08029B20() callconv(.c) void {
    if (!abi.enter(0x08029B20)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x08029B98);
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
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(7);
            rt.r[4] = abi.read32(0x08029B9C);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            if (!abi.call(decls.func_08013248, 0x08029B37)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(13);
            rt.r[5] = abi.read32(0x08029BA0);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[2], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x22);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(decls.func_08026400, 0x08029B55)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08029BA4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08035230, 0x08029B5F)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[1], 0x24);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08023EDC, 0x08029B77)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08029BDC);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08026060, 0x08029BBF)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802DD84, 0x08029B7B)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08029BE0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 13;
        },
        12 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08029BE4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x08029BE8);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            rt.r[2] = abi.read8(rt.r[2] +% 0x1);
            if (!abi.call(decls.func_08034904, 0x08029BD7)) return;
            continue :blk 1;
        },
        13 => {
            abi.fetches(10);
            rt.r[2] = abi.read32(0x08029BA8);
            rt.r[1] = abi.read32(0x08029BAC);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x2);
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            if (!abi.call(decls.func_0802E730, 0x08029B91)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08029BB0);
            abi.setRegNz(&rt.r[0], 0x5);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08029C1C() callconv(.c) void {
    if (!abi.enter(0x08029C1C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.r[8] = rt.r[1];
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[1] = abi.read8(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x7F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[1] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x08029C43)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(15);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[0] << 21);
            rt.r[2] = abi.read32(0x08029CDC);
            rt.r[3] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 28);
            rt.r[0] = abi.read8(rt.r[0] +% 0xD);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read32(0x08029C5C);
            rt.r[3] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 3);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x1A);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            continue :blk 3;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x0, true);
            continue :blk 7;
        },
        6 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = rt.r[8];
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x08029CE0);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08029CE4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (!rt.CPU_C) {
                continue :blk 6;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(25);
            rt.cpuAdd(&rt.r[6], rt.r[6], rt.r[5], true);
            rt.r[2] = abi.read16(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[2] << 21);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 28);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xF);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 7);
            rt.r[3] = abi.read32(0x08029CE8);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[1]);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[0]);
            abi.write16(rt.r[4] +% 0x4, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[2], rt.r[2] << 21);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 28);
            rt.r[0] = abi.read8(rt.r[0] +% 0xD);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08024128, 0x08029CA1)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_08029CEC() callconv(.c) void {
    if (!abi.enter(0x08029CEC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[7], rt.r[1] >> 24);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[1] = abi.read8(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x7F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[1] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x08029D11)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(15);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x6);
            abi.setRegNz(&rt.r[1], rt.r[0] << 25);
            rt.r[2] = abi.read32(0x08029D90);
            rt.r[3] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 25);
            rt.r[0] = abi.read8(rt.r[0] +% 0x12);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            continue :blk 3;
        },
        5 => {
            abi.fetches(3);
            rt.r[8] = rt.r[2];
            continue :blk 7;
        },
        6 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[7], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x08029D94);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08029D98);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (!rt.CPU_C) {
                continue :blk 6;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(25);
            rt.cpuAdd(&rt.r[6], rt.r[6], rt.r[5], true);
            rt.r[2] = abi.read8(rt.r[4] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[2] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0x7F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[3], 0x80);
            rt.cpuSub(&rt.r[3], 0, rt.r[3], true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[1]);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[0]);
            abi.write8(rt.r[4] +% 0x6, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[2], rt.r[2] << 25);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.r[0] +%= rt.r[8];
            abi.setRegNz(&rt.r[2], rt.r[2] >> 25);
            rt.r[0] = abi.read8(rt.r[0] +% 0x12);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08024128, 0x08029D57)) return;
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_0802A6FC() callconv(.c) void {
    if (!abi.enter(0x0802A6FC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0802A774);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
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
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x2);
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
            abi.fetches(7);
            rt.r[0] = abi.read8(rt.r[4] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read8(rt.r[4] +% 0x3);
            if (!abi.call(decls.func_0802A688, 0x0802A71D)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x3);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 5;
        },
        7 => {
            abi.fetches(7);
            rt.r[0] = abi.read8(rt.r[4] +% 0x2);
            rt.r[1] = abi.read8(rt.r[4] +% 0x3);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            if (!abi.call(decls.func_0802A688, 0x0802A733)) return;
            continue :blk 10;
        },
        8 => {
            abi.fetches(9);
            rt.r[1] = abi.read8(rt.r[4] +% 0x2);
            rt.r[0] = abi.read32(0x0802A778);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        10 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        11 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            rt.r[1] = abi.read8(rt.r[4] +% 0x3);
            if (!abi.call(decls.func_0802A688, 0x0802A74F)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(9);
            rt.r[1] = abi.read8(rt.r[4] +% 0x3);
            rt.r[0] = abi.read32(0x0802A778);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 14;
        },
        13 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 12;
        },
        14 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[4] +% 0x2);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            if (!abi.call(decls.func_0802A688, 0x0802A76B)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_0802A7A4() callconv(.c) void {
    if (!abi.enter(0x0802A7A4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(21);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[7], 0x0);
            rt.r[0] = abi.read32(0x0802A82C);
            rt.r[2] = abi.read8(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 3);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x20, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if (rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0802A830);
            rt.r[8] = rt.r[0];
            rt.r[9] = rt.r[2];
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x7, true);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[7], true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(12);
            rt.r[2] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[2] = rt.r[8];
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(func_08029C1C, 0x0802A7EF)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 24);
            rt.r[1] = abi.read8(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.r[0] +%= rt.r[9];
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[7], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[6], rt.r[6], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[2] = rt.r[8];
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(func_08029CEC, 0x0802A805)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[6], rt.r[6], rt.r[0], true);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0802A8A4() callconv(.c) void {
    if (!abi.enter(0x0802A8A4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[0] = abi.read32(0x0802A90C);
            if (!abi.call(decls.func_08013B70, 0x0802A8AD)) return;
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
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(13);
            rt.r[2] = abi.read32(0x0802A910);
            rt.r[0] = abi.read32(0x0802A914);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[5] = abi.read16(rt.r[0] +% 0x38);
            rt.cpuSub(null, rt.r[5], 0x32, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.r[7] = abi.read32(0x0802A918);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x33, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x0802A91C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802A978);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0802A973)) return;
            continue :blk 2;
        },
        8 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x9);
            rt.r[2] = abi.read8(rt.r[4] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[5], 0x32, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x16, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.r[1] = abi.read32(0x0802A920);
            if (!abi.call(decls.func_0802A834, 0x0802A8FF)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_0802A6FC, 0x0802A92B)) return;
            continue :blk 14;
        },
        13 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 15;
        },
        14 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 16;
        },
        15 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802A914);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            continue :blk 17;
        },
        16 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.r[1] = abi.read32(0x0802A954);
            if (!abi.call(decls.func_0802A834, 0x0802A939)) return;
            continue :blk 18;
        },
        17 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x1, true);
            abi.write16(rt.r[0] +% 0x38, @truncate(rt.r[1]));
            continue :blk 5;
        },
        18 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 19;
        },
        19 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0802A958);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            continue :blk 17;
        },
        else => unreachable,
    }
}

fn func_0802AB2C() callconv(.c) void {
    if (!abi.enter(0x0802AB2C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.r[1] = abi.read8(rt.r[4] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.r[1] = abi.read8(rt.r[4] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(18);
            rt.r[2] = abi.read32(0x0802ABE8);
            rt.r[0] = abi.read32(0x0802ABEC);
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
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(27);
            rt.r[2] = abi.read32(0x0802ABEC);
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[4], rt.r[3], true);
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
            rt.r[12] = rt.r[0];
            abi.setRegNz(&rt.r[0], 0xC0);
            rt.r[1] = rt.r[12];
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.r[12] = rt.r[1];
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
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
            abi.fetches(4);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[5], 0x80);
            continue :blk 7;
        },
        6 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x0802ABE8);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
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
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 4;
        },
        7 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[3], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], rt.r[4], true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x33, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        10 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.r[3] = abi.read8(rt.r[3] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_0802AC10() callconv(.c) void {
    if (!abi.enter(0x0802AC10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.r[0] = abi.read32(0x0802AC98);
            if (!abi.call(decls.func_08013B70, 0x0802AC1D)) return;
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
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(15);
            rt.r[3] = abi.read32(0x0802AC9C);
            rt.r[2] = abi.read32(0x0802ACA0);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[4], 0x38);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[4]));
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x32, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802ACA4);
            rt.r[8] = rt.r[0];
            rt.cpuAdd(&rt.r[6], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[7], 0x0, true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[7] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0802ACED)) return;
            continue :blk 2;
        },
        6 => {
            abi.fetches(22);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[4]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[2], 0x38);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.r[0] = abi.read32(0x0802ACA8);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[4] = rt.r[8];
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(func_08023978, 0x0802AC79)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(23);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[5] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x38);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x38, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[3], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[5] +% rt.r[4]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            abi.setRegNz(&rt.r[1], 0x38);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x32, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(7);
            rt.r[1] = abi.read8(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x7F);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[1] << 25);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 25);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x0802AC95)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 14;
        },
        13 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x1, true);
            continue :blk 14;
        },
        14 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08024124, 0x0802ACB5)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0802AAF8, 0x0802ACBB)) return;
            continue :blk 16;
        },
        16 => {
            abi.fetches(3);
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0802B7D4() callconv(.c) void {
    if (!abi.enter(0x0802B7D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[8] = rt.r[1];
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[5], rt.r[2] >> 16);
            if (!abi.call(decls.func_08010EDC, 0x0802B7EF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[9] = rt.r[0];
            rt.r[0] = abi.read32(0x0802B870);
            if (!abi.call(decls.func_08013B70, 0x0802B7FB)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(21);
            rt.r[0] = abi.read32(0x0802B874);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x0802B878);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[4] = abi.read32(0x0802B87C);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2);
            abi.setRegNz(&rt.r[3], rt.r[1] << 1);
            rt.r[7] = abi.read32(0x0802B880);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[7], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.r[4] = abi.read16(rt.r[4] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x12, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            rt.r[2] = abi.read32(0x0802B884);
            if (!abi.call(decls.func_08023888, 0x0802B82D)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(30);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[3] = abi.read32(0x0802B888);
            abi.setRegNz(&rt.r[2], rt.r[5] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1B, true);
            rt.r[3] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[3] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[7] = rt.r[9];
            abi.setRegNz(&rt.r[2], rt.r[7] << 24);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 24));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x14, true);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read32(0x0802B88C);
            abi.setRegNz(&rt.r[3], 0x14);
            rt.r[2] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.r[3] = abi.read32(0x0802B890);
            if (!abi.call(decls.func_08038D60, 0x0802B865)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802BB44() callconv(.c) void {
    if (!abi.enter(0x0802BB44)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[4] = abi.read32(0x0802BB78);
            rt.r[5] = abi.read32(0x0802BB7C);
            rt.r[0] = abi.read8(rt.r[5] +% 0x10);
            rt.r[1] = abi.read8(rt.r[5] +% 0x11);
            if (!abi.call(decls.func_0802BAA4, 0x0802BB53)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 23);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.r[2] = abi.read32(rt.r[5] +% 0xC);
            rt.cpuSub(null, rt.r[2], 0x3, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[3] = abi.read32(0x0802BB9C);
            rt.r[2] = abi.read32(rt.r[3] +% 0xC);
            rt.cpuSub(null, rt.r[2], 0x94, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[5] +% 0x8, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x95, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802BBC4);
            rt.r[0] = abi.read32(rt.r[0] +% 0xC);
            rt.cpuSub(null, rt.r[0], 0x94, true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xF2);
            continue :blk 12;
        },
        7 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[0], true);
            continue :blk 12;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x94);
            continue :blk 13;
        },
        9 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x94, true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[0], true);
            continue :blk 13;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802BB2C, 0x0802BBBF)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        12 => {
            abi.fetches(3);
            abi.write32(rt.r[5] +% 0xC, rt.r[0]);
            continue :blk 2;
        },
        13 => {
            abi.fetches(5);
            abi.write32(rt.r[3] +% 0xC, rt.r[0]);
            if (!abi.call(decls.func_0802BB2C, 0x0802BBB3)) return;
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0802BBC8() callconv(.c) void {
    if (!abi.enter(0x0802BBC8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x0802BC00);
            rt.r[0] = abi.read8(rt.r[4] +% 0x10);
            rt.r[1] = abi.read8(rt.r[4] +% 0x11);
            if (!abi.call(decls.func_0802BAA4, 0x0802BBD5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x0802BC04);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 23);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x98, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.r[2] = abi.read32(rt.r[4] +% 0xC);
            rt.cpuSub(null, rt.r[2], 0x93, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[3] = abi.read32(0x0802BC24);
            rt.r[2] = abi.read32(rt.r[3] +% 0xC);
            rt.cpuSub(null, rt.r[2], 0x2, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[4] +% 0x8, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x1, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802BC4C);
            rt.r[0] = abi.read32(rt.r[0] +% 0xC);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x5A);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 12;
        },
        7 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[0], true);
            continue :blk 12;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x3);
            continue :blk 13;
        },
        9 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x3, true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 31);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(&rt.r[0], rt.r[2], rt.r[0], true);
            continue :blk 13;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802BB2C, 0x0802BC45)) return;
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
            abi.write32(rt.r[4] +% 0xC, rt.r[0]);
            continue :blk 2;
        },
        13 => {
            abi.fetches(5);
            abi.write32(rt.r[3] +% 0xC, rt.r[0]);
            if (!abi.call(decls.func_0802BB2C, 0x0802BC39)) return;
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_0802BEC8() callconv(.c) void {
    if (!abi.enter(0x0802BEC8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(29);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.cpuAdd(&rt.r[4], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[0] = abi.read32(0x0802BF40);
            rt.r[8] = rt.r[0];
            rt.cpuAdd(&rt.r[5], rt.r[7], 0x0, true);
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[0]);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[1], 16));
            rt.r[0] = abi.read32(0x0802BF44);
            rt.r[9] = rt.r[0];
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_0807B564, 0x0802BEFF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x10, true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.r[2] = rt.r[9];
            if (!abi.call(decls.func_0801B888, 0x0802BF11)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_0807B488, 0x0802BF19)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
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
        5 => {
            abi.fetches(12);
            rt.cpuSub(&rt.r[0], rt.r[7], 0x7, true);
            rt.r[1] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x10, true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.r[2] = rt.r[9];
            if (!abi.call(decls.func_0801B888, 0x0802BF35)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802C368() callconv(.c) void {
    if (!abi.enter(0x0802C368)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0xC;
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.r[2] = abi.read32(0x0802C460);
            rt.r[0] = abi.read32(0x0802C464);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x2);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1C);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.r[7] = abi.read32(0x0802C468);
            rt.r[6] = abi.read32(0x0802C46C);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 20));
            rt.r[3] = abi.read16(rt.r[6] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0xE, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(17);
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[6] +% 0x2);
            abi.setRegNz(&rt.r[2], rt.r[0] << 1);
            rt.r[3] = abi.read32(0x0802C470);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read16(rt.r[6] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[3] = abi.read32(0x0802C474);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(9);
            rt.r[1] = abi.read16(rt.r[1] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 20));
            rt.r[1] = abi.read16(rt.r[6] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x9, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x0802C478);
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            if (!abi.call(decls.func_0803D880, 0x0802C3DB)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x0802C47C);
            rt.r[1] = abi.read32(0x0802C480);
            abi.setRegNz(&rt.r[5], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[1], true);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_080133C0, 0x0802C3EF)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(23);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 24));
            rt.r[3] = abi.read16(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 4);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[2] = abi.read16(rt.r[0] +% 0x4);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[6] = abi.read16(rt.r[6] +% 0x2);
            abi.setRegNz(&rt.r[2], rt.r[6] << 4);
            rt.r[0] = abi.read16(rt.r[0] +% 0x6);
            rt.cpuSub(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x5, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013550, 0x0802C419)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13] +% 0x4;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080135C8, 0x0802C421)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(17);
            rt.r[1] = abi.read32(rt.r[13] +% 0x4);
            rt.r[2] = abi.read32(rt.r[13] +% 0x8);
            rt.r[0] = abi.read32(0x0802C484);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.setRegNz(&rt.r[3], 0xC0);
            abi.setRegNz(&rt.r[3], rt.r[3] << 6);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            rt.r[3] = abi.read32(0x0802C488);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            rt.r[3] = abi.read32(0x0802C48C);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013598, 0x0802C43F)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0802C490);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[1] = abi.read32(0x0802C494);
            if (!abi.call(decls.func_0800FE24, 0x0802C44B)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0802C498);
            abi.setRegNz(&rt.r[1], 0x98);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_08011330, 0x0802C457)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802CD34() callconv(.c) void {
    if (!abi.enter(0x0802CD34)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 2, 4, 5, 14 });
            abi.setRegNz(&rt.r[0], 0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            if (!abi.call(decls.func_0802CBDC, 0x0802CD3F)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(19);
            rt.r[2] = abi.read32(0x0802CDCC);
            rt.r[3] = abi.read32(0x0802CDD0);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x38);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x38, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(20);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[4]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.write16(rt.r[0] +% 0x38, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[5]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x1E);
            rt.r[4] = abi.read16(rt.r[1] +% 0x22);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
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
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 6;
        },
        6 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[5]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x20);
            rt.r[4] = abi.read16(rt.r[1] +% 0x24);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            continue :blk 8;
        },
        8 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[5]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x1E);
            rt.r[2] = abi.read16(rt.r[1] +% 0x22);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.r[4] = abi.read16(rt.r[1] +% 0x20);
            rt.r[5] = abi.read16(rt.r[1] +% 0x24);
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x1E);
            abi.write16(rt.r[1] +% 0x38, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0802CDC7)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802CD38() callconv(.c) void {
    if (!abi.enter(0x0802CD38)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            if (!abi.call(decls.func_0802CBDC, 0x0802CD3F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(19);
            rt.r[2] = abi.read32(0x0802CDCC);
            rt.r[3] = abi.read32(0x0802CDD0);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x38);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x38, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(20);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[4]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.write16(rt.r[0] +% 0x38, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[5]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x1E);
            rt.r[4] = abi.read16(rt.r[1] +% 0x22);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (rt.CPU_Z) {
                continue :blk 5;
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
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[5]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x20);
            rt.r[4] = abi.read16(rt.r[1] +% 0x24);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            continue :blk 7;
        },
        7 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[3] +% rt.r[5]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x1E);
            rt.r[2] = abi.read16(rt.r[1] +% 0x22);
            rt.cpuSub(null, rt.r[0], rt.r[2], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.r[4] = abi.read16(rt.r[1] +% 0x20);
            rt.r[5] = abi.read16(rt.r[1] +% 0x24);
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x1E);
            abi.write16(rt.r[1] +% 0x38, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0802CDC7)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802CDD4() callconv(.c) void {
    if (!abi.enter(0x0802CDD4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 6, 14 });
            if (!abi.call(decls.func_0802CBDC, 0x0802CDDB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(19);
            rt.r[4] = abi.read32(0x0802CE58);
            rt.r[6] = abi.read32(0x0802CE5C);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[6] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x38);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write16(rt.r[0] +% 0x38, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
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
            abi.fetches(18);
            rt.r[5] = abi.read32(0x0802CE60);
            rt.r[1] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[6] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x28, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(decls.func_08036844, 0x0802CE1D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(14);
            rt.r[5] = abi.read8(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[5] << 2);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[2] = rt.sext16(abi.read16(rt.r[6] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            if (!abi.call(decls.func_08023940, 0x0802CE35)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08026060, 0x0802CE39)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(func_080237C0, 0x0802CE3D)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08023EDC, 0x0802CE41)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0802CE64);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08035230, 0x0802CE4B)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[6] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0802CE51)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0802D634() callconv(.c) void {
    if (!abi.enter(0x0802D634)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 2, 14 });
            abi.setRegNz(&rt.r[0], 0);
            abi.setRegNz(&rt.r[0], rt.r[2] >> 24);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[0] = abi.read32(0x0802D68C);
            if (!abi.call(decls.func_08013B70, 0x0802D645)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0802D690);
            if (!abi.call(decls.func_08013B70, 0x0802D657)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0802D694);
            if (!abi.call(decls.func_08013B70, 0x0802D665)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0802D698);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035230, 0x0802D67D)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[1] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(decls.func_08026140, 0x0802D6A9)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802D69C);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            if (!abi.call(decls.func_08013248, 0x0802D687)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802D6B8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0802D6B1)) return;
            continue :blk 4;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802E730, 0x0802D68B)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(3);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802DB98() callconv(.c) void {
    if (!abi.enter(0x0802DB98)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0802DC18);
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        2 => {
            abi.fetches(18);
            rt.r[0] = abi.read32(0x0802DC1C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read32(0x0802DC20);
            rt.r[4] = abi.read16(rt.r[3] +% 0x2);
            abi.setRegNz(&rt.r[2], rt.r[4] << 1);
            rt.r[4] = abi.read32(0x0802DC24);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read16(rt.r[3] +% 0x0);
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
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[1] = abi.read32(0x0802DC28);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read32(0x0802DC2C);
            rt.r[4] = abi.read32(0x0802DC30);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[3] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[3] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 3);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x10);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xFF);
            if (!abi.call(decls.func_0801D048, 0x0802DBFF)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0802DC20);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            rt.r[2] = abi.read32(rt.r[4] +% 0x0);
            if (!abi.call(decls.func_0801DAE0, 0x0802DC0B)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(func_08025C70, 0x0802DC0F)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802E9C8() callconv(.c) void {
    if (!abi.enter(0x0802E9C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_08012794, 0x0802E9D1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x0802EA70);
            abi.setRegNz(&rt.r[2], 0x1);
            abi.setRegNz(&rt.r[3], 0x1);
            if (!abi.call(decls.func_0801256C, 0x0802E9DF)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[2] = abi.read32(0x0802EA74);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802EA7C);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_0801256C, 0x0802EA2D)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.r[6] = abi.read32(0x0802EA78);
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = abi.read32(0x0802EA74);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[6] = abi.read32(0x0802EA78);
            continue :blk 11;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        9 => {
            abi.fetches(12);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(decls.func_080124FC, 0x0802EA0F)) return;
            continue :blk 12;
        },
        10 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 3;
        },
        11 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        12 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            continue :blk 10;
        },
        13 => {
            abi.fetches(12);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(decls.func_080124FC, 0x0802EA59)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_0802F104() callconv(.c) void {
    if (!abi.enter(0x0802F104)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
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
            if (!abi.call(func_08023AA8, 0x0802F10D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.r[1] = abi.read8(rt.r[1] +% 0x3);
            if (!abi.call(decls.func_0802928C, 0x0802F11B)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802F158);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0802F134);
            if (!abi.call(decls.func_08013B70, 0x0802F121)) return;
            continue :blk 9;
        },
        7 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x0802F15C);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x2);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(decls.func_0802F7E4, 0x0802F155)) return;
            continue :blk 10;
        },
        8 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 12;
        },
        9 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 13;
        },
        10 => {
            abi.fetches(3);
            continue :blk 1;
        },
        11 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802AD0C, 0x0802F181)) return;
            continue :blk 14;
        },
        12 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x0802F18C);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x2);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(decls.func_0802F648, 0x0802F177)) return;
            continue :blk 15;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802EFD8, 0x0802F131)) return;
            continue :blk 16;
        },
        14 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_08026FC8, 0x0802F187)) return;
            continue :blk 1;
        },
        15 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 11;
        },
        16 => {
            abi.fetches(3);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0802F190() callconv(.c) void {
    if (!abi.enter(0x0802F190)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 14 });
            if (!abi.call(decls.func_080212B8, 0x0802F197)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021194, 0x0802F19B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021398, 0x0802F19F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(20);
            rt.r[0] = abi.read32(0x0802F1CC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read32(0x0802F1D0);
            rt.r[0] = abi.read16(rt.r[3] +% 0x2);
            abi.setRegNz(&rt.r[2], rt.r[0] << 1);
            rt.r[4] = abi.read32(0x0802F1D4);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[2] = abi.read32(0x0802F1D8);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_08020D14, 0x0802F1E3)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_08020D14, 0x0802F1C9)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803B350, 0x0802F1E7)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            continue :blk 6;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802EF2C, 0x0802F1EB)) return;
            continue :blk 9;
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
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802F210);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[4], 0x1);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[1]);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        12 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x0802F214);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[4]));
            abi.setRegNz(&rt.r[2], 0x2);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(func_0802F94C, 0x0802F20D)) return;
            continue :blk 14;
        },
        13 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 15;
        },
        14 => {
            abi.fetches(3);
            continue :blk 11;
        },
        15 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802F260);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 17;
            }
            continue :blk 16;
        },
        16 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802F264);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08034988, 0x0802F239)) return;
            continue :blk 17;
        },
        17 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0802F268);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.r[1] = abi.read8(rt.r[1] +% 0x3);
            if (!abi.call(decls.func_0802928C, 0x0802F245)) return;
            continue :blk 18;
        },
        18 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080367F0, 0x0802F249)) return;
            continue :blk 19;
        },
        19 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08023EDC, 0x0802F24D)) return;
            continue :blk 20;
        },
        20 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080203E8, 0x0802F251)) return;
            continue :blk 21;
        },
        21 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802F26C);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            abi.setRegNz(&rt.r[0], 0x66);
            if (!abi.call(decls.func_0803D880, 0x0802F25B)) return;
            continue :blk 11;
        },
        else => unreachable,
    }
}

fn func_0802F270() callconv(.c) void {
    if (!abi.enter(0x0802F270)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 6, 14 });
            if (!abi.call(decls.func_080212B8, 0x0802F277)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080210F0, 0x0802F27B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021398, 0x0802F27F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x5);
            if (!abi.call(decls.func_08020D14, 0x0802F285)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802EF2C, 0x0802F289)) return;
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
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802F2AC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[6] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x66);
            if (!abi.call(decls.func_0803D880, 0x0802F2A3)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(18);
            rt.r[0] = abi.read32(0x0802F324);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read32(0x0802F328);
            rt.r[0] = abi.read16(rt.r[3] +% 0x2);
            abi.setRegNz(&rt.r[2], rt.r[0] << 1);
            rt.r[4] = abi.read32(0x0802F32C);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0802F2B0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 6;
        },
        11 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[2] >> 6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read32(0x0802F330);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x0802F334);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read8(rt.r[5] +% 0x1);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[1]);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[6]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 14;
        },
        14 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802F338);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        15 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x10);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08034988, 0x0802F315)) return;
            continue :blk 16;
        },
        16 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0802AAF8, 0x0802F31B)) return;
            continue :blk 17;
        },
        17 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0802F33C);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0802F4EE() callconv(.c) void {
    if (!abi.enter(0x0802F4EE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[9] = rt.r[0];
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 1);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.r[6] = rt.r[9];
            abi.setRegNz(&rt.r[1], 0xA0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[3], rt.r[12], true);
            if (!rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], rt.r[1] << 7);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            continue :blk 6;
        },
        5 => {
            abi.fetches(8);
            rt.r[9] = rt.r[10];
            rt.r[7] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x1F, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(19);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 1);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 3;
        },
        7 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[7] = rt.r[8];
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[7], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x0802F5A9)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(3);
            rt.r[12] = rt.r[9];
            continue :blk 11;
        },
        10 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        11 => {
            abi.fetches(10);
            rt.r[1] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 1);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x10, true);
            abi.setRegNz(&rt.r[7], 0x80);
            abi.setRegNz(&rt.r[7], rt.r[7] << 1);
            rt.cpuAdd(&rt.r[6], rt.r[7], 0x0, true);
            continue :blk 14;
        },
        13 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.r[7] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[1] = rt.r[8];
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 8;
        },
        14 => {
            abi.fetches(24);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[0] = abi.read32(0x0802F5BC);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[7], 0xA0);
            abi.setRegNz(&rt.r[7], rt.r[7] << 7);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.r[1] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 1);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        else => unreachable,
    }
}

fn func_0802F502() callconv(.c) void {
    if (!abi.enter(0x0802F502)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], rt.r[1] << 7);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(19);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 1);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[3], rt.r[12], true);
            if (!rt.CPU_C) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 1);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(8);
            rt.r[9] = rt.r[10];
            rt.r[7] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x1F, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.r[6] = rt.r[9];
            abi.setRegNz(&rt.r[1], 0xA0);
            continue :blk 0;
        },
        6 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[7] = rt.r[8];
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[7], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x0802F5A9)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(3);
            rt.r[12] = rt.r[9];
            continue :blk 10;
        },
        9 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        10 => {
            abi.fetches(10);
            rt.r[1] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 1);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x10, true);
            abi.setRegNz(&rt.r[7], 0x80);
            abi.setRegNz(&rt.r[7], rt.r[7] << 1);
            rt.cpuAdd(&rt.r[6], rt.r[7], 0x0, true);
            continue :blk 13;
        },
        12 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.r[7] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[1] = rt.r[8];
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 7;
        },
        13 => {
            abi.fetches(24);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[0] = abi.read32(0x0802F5BC);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[7], 0xA0);
            abi.setRegNz(&rt.r[7], rt.r[7] << 7);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.r[1] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 1);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        else => unreachable,
    }
}

fn func_0802F730() callconv(.c) void {
    if (!abi.enter(0x0802F730)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x40);
            if (!abi.call(decls.func_0801D3C0, 0x0802F73B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.cpuSub(&rt.r[2], 0, rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = rt.r[10];
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 16);
            rt.r[6] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[6] >> 16);
            abi.setRegNz(&rt.r[2], 0x1);
            if (!abi.call(decls.func_08020380, 0x0802F7A7)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xFF);
            if (!abi.call(decls.func_0801D048, 0x0802F757)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.r[1] = rt.r[9];
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[2] +% 0x2);
            rt.r[1] = abi.read8(rt.r[2] +% 0x3);
            if (!abi.call(decls.func_0801D7B8, 0x0802F763)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0802F7E0);
            abi.setRegNz(&rt.r[0], 0x6);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x69);
            if (!abi.call(decls.func_0803D880, 0x0802F7B3)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 11;
        },
        10 => {
            abi.fetches(28);
            rt.r[5] = abi.read32(0x0802F7DC);
            rt.r[2] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[2], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[5], true);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[7], 16));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            continue :blk 4;
        },
        11 => {
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

fn func_0802F7FA() callconv(.c) void {
    if (!abi.enter(0x0802F7FA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 16);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0801B8D4, 0x0802F803)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.r[1] = abi.read32(0x0802F878);
            continue :blk 3;
        },
        3 => {
            abi.fetches(46);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0802F87C);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0802F880);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0802F884);
            rt.r[8] = rt.r[0];
            rt.r[1] = abi.read32(0x0802F888);
            rt.r[9] = rt.r[1];
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[7], rt.r[6] << 1);
            rt.r[2] = abi.read32(0x0802F88C);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 16);
            rt.r[10] = rt.r[5];
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[5], 16));
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.r[3] = rt.r[8];
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[5] = abi.read32(0x0802F890);
            rt.r[0] = abi.read32(0x0802F894);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_08021E40, 0x0802F85D)) return;
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
            abi.setRegNz(&rt.r[0], 0xE);
            if (!abi.call(decls.func_08018BA8, 0x0802F869)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(14);
            rt.r[0] = rt.r[9];
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x0802F8C4);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        8 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[6], 0x1);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802E600, 0x0802F8C3)) return;
            continue :blk 13;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0802E778, 0x0802F875)) return;
            continue :blk 14;
        },
        11 => {
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
        12 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2C);
            if (!abi.call(decls.func_08018BA8, 0x0802F8CF)) return;
            continue :blk 15;
        },
        13 => {
            abi.fetches(3);
            continue :blk 11;
        },
        14 => {
            abi.fetches(3);
            continue :blk 11;
        },
        15 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 16;
        },
        16 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0802F938);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_08036520, 0x0802F8DF)) return;
            continue :blk 17;
        },
        17 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021FC8, 0x0802F8E3)) return;
            continue :blk 18;
        },
        18 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08023EDC, 0x0802F8E7)) return;
            continue :blk 19;
        },
        19 => {
            abi.fetches(9);
            rt.r[4] = abi.read32(0x0802F93C);
            rt.r[3] = rt.r[8];
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] >> 6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = rt.r[9];
            continue :blk 20;
        },
        20 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            continue :blk 21;
        },
        21 => {
            abi.fetches(3);
            rt.r[2] = abi.read32(0x0802F940);
            continue :blk 22;
        },
        22 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            if (!abi.call(decls.func_0801D148, 0x0802F8FF)) return;
            continue :blk 23;
        },
        23 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_0801D968, 0x0802F905)) return;
            continue :blk 24;
        },
        24 => {
            abi.fetches(3);
            continue :blk 25;
        },
        25 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x0802F944);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[3] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[3] >> 16);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(decls.func_08020380, 0x0802F919)) return;
            continue :blk 26;
        },
        26 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802F948);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            if (!abi.call(decls.func_0803AC5C, 0x0802F921)) return;
            continue :blk 27;
        },
        27 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x69);
            if (!abi.call(decls.func_0803D880, 0x0802F927)) return;
            continue :blk 11;
        },
        else => unreachable,
    }
}

fn func_0802F800() callconv(.c) void {
    if (!abi.enter(0x0802F800)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.r[1] = abi.read32(0x0802F878);
            continue :blk 2;
        },
        2 => {
            abi.fetches(46);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0802F87C);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0802F880);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0802F884);
            rt.r[8] = rt.r[0];
            rt.r[1] = abi.read32(0x0802F888);
            rt.r[9] = rt.r[1];
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[7], rt.r[6] << 1);
            rt.r[2] = abi.read32(0x0802F88C);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 16);
            rt.r[10] = rt.r[5];
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[5], 16));
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.r[3] = rt.r[8];
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[5] = abi.read32(0x0802F890);
            rt.r[0] = abi.read32(0x0802F894);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_08021E40, 0x0802F85D)) return;
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
            abi.setRegNz(&rt.r[0], 0xE);
            if (!abi.call(decls.func_08018BA8, 0x0802F869)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(14);
            rt.r[0] = rt.r[9];
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x0802F8C4);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[6], 0x1);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802E600, 0x0802F8C3)) return;
            continue :blk 12;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0802E778, 0x0802F875)) return;
            continue :blk 13;
        },
        10 => {
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
        11 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2C);
            if (!abi.call(decls.func_08018BA8, 0x0802F8CF)) return;
            continue :blk 14;
        },
        12 => {
            abi.fetches(3);
            continue :blk 10;
        },
        13 => {
            abi.fetches(3);
            continue :blk 10;
        },
        14 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 15;
        },
        15 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0802F938);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_08036520, 0x0802F8DF)) return;
            continue :blk 16;
        },
        16 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021FC8, 0x0802F8E3)) return;
            continue :blk 17;
        },
        17 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08023EDC, 0x0802F8E7)) return;
            continue :blk 18;
        },
        18 => {
            abi.fetches(9);
            rt.r[4] = abi.read32(0x0802F93C);
            rt.r[3] = rt.r[8];
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] >> 6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = rt.r[9];
            continue :blk 19;
        },
        19 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            continue :blk 20;
        },
        20 => {
            abi.fetches(3);
            rt.r[2] = abi.read32(0x0802F940);
            continue :blk 21;
        },
        21 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            if (!abi.call(decls.func_0801D148, 0x0802F8FF)) return;
            continue :blk 22;
        },
        22 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_0801D968, 0x0802F905)) return;
            continue :blk 23;
        },
        23 => {
            abi.fetches(3);
            continue :blk 24;
        },
        24 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x0802F944);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[3] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[3] >> 16);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(decls.func_08020380, 0x0802F919)) return;
            continue :blk 25;
        },
        25 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802F948);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            if (!abi.call(decls.func_0803AC5C, 0x0802F921)) return;
            continue :blk 26;
        },
        26 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x69);
            if (!abi.call(decls.func_0803D880, 0x0802F927)) return;
            continue :blk 10;
        },
        else => unreachable,
    }
}

fn func_0802F804() callconv(.c) void {
    if (!abi.enter(0x0802F804)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(46);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0802F87C);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x0802F880);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0802F884);
            rt.r[8] = rt.r[0];
            rt.r[1] = abi.read32(0x0802F888);
            rt.r[9] = rt.r[1];
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[7], rt.r[6] << 1);
            rt.r[2] = abi.read32(0x0802F88C);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 16);
            rt.r[10] = rt.r[5];
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[5], 16));
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.r[3] = rt.r[8];
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[5] = abi.read32(0x0802F890);
            rt.r[0] = abi.read32(0x0802F894);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_08021E40, 0x0802F85D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0xE);
            if (!abi.call(decls.func_08018BA8, 0x0802F869)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(14);
            rt.r[0] = rt.r[9];
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x0802F8C4);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
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
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[6], 0x1);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802E600, 0x0802F8C3)) return;
            continue :blk 10;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0802E778, 0x0802F875)) return;
            continue :blk 11;
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
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2C);
            if (!abi.call(decls.func_08018BA8, 0x0802F8CF)) return;
            continue :blk 12;
        },
        10 => {
            abi.fetches(3);
            continue :blk 8;
        },
        11 => {
            abi.fetches(3);
            continue :blk 8;
        },
        12 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0802F938);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_08036520, 0x0802F8DF)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021FC8, 0x0802F8E3)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08023EDC, 0x0802F8E7)) return;
            continue :blk 16;
        },
        16 => {
            abi.fetches(9);
            rt.r[4] = abi.read32(0x0802F93C);
            rt.r[3] = rt.r[8];
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] >> 6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = rt.r[9];
            continue :blk 17;
        },
        17 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            continue :blk 18;
        },
        18 => {
            abi.fetches(3);
            rt.r[2] = abi.read32(0x0802F940);
            continue :blk 19;
        },
        19 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            if (!abi.call(decls.func_0801D148, 0x0802F8FF)) return;
            continue :blk 20;
        },
        20 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            if (!abi.call(decls.func_0801D968, 0x0802F905)) return;
            continue :blk 21;
        },
        21 => {
            abi.fetches(3);
            continue :blk 22;
        },
        22 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x0802F944);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[3] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[3] >> 16);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(decls.func_08020380, 0x0802F919)) return;
            continue :blk 23;
        },
        23 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802F948);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            if (!abi.call(decls.func_0803AC5C, 0x0802F921)) return;
            continue :blk 24;
        },
        24 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x69);
            if (!abi.call(decls.func_0803D880, 0x0802F927)) return;
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_0802F94C() callconv(.c) void {
    if (!abi.enter(0x0802F94C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[5], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            if (!abi.call(func_0802FA70, 0x0802F95F)) return;
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
            if (!abi.call(decls.func_080203E8, 0x0802F971)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x68);
            if (!abi.call(decls.func_0803D880, 0x0802F96B)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(22);
            rt.r[4] = abi.read32(0x0802F9C8);
            rt.r[0] = abi.read32(0x0802F9CC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x3);
            abi.write16(rt.r[4] +% 0x2, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0802F9D0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[6]));
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[5]));
            rt.r[0] = abi.read32(0x0802F9D4);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[5] = abi.read32(0x0802F9D8);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(func_0803AAB8, 0x0802F99D)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            abi.setRegNz(&rt.r[2], 0x2);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.r[4] = abi.read32(0x0802F9DC);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x4);
            if (!abi.call(decls.func_0802FB14, 0x0802F9AF)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x5);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080241B0, 0x0802F9C1)) return;
            continue :blk 7;
        },
        else => unreachable,
    }
}

fn func_0802FA70() callconv(.c) void {
    if (!abi.enter(0x0802FA70)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(33);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[4] = abi.read32(0x0802FAF0);
            rt.r[2] = abi.read32(0x0802FAF4);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[3], rt.r[6] << 1);
            rt.r[5] = abi.read32(0x0802FAF8);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[5], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x12, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[7], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(0x0802FAFC);
            abi.setRegNz(&rt.r[4], 0xC0);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[0]);
            rt.r[0] = abi.read32(0x0802FB00);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
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
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0802FB04);
            abi.setRegNz(&rt.r[1], rt.r[6] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x78, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[4]);
            rt.cpuSub(null, rt.r[2], rt.r[3], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        7 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802FB08);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(func_08024664, 0x0802FAD3)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(func_08025AA4, 0x0802FAE3)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0802FED4() callconv(.c) void {
    if (!abi.enter(0x0802FED4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x0802FEE8);
            rt.r[3] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0802FF38);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[1] = abi.read32(0x0802FF3C);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0802FF40);
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0802FEEC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 7;
        },
        5 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802FFA0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0802FFA4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 10;
        },
        7 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5 });
            continue :blk 11;
        },
        8 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x40);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 12;
        },
        9 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x0802FFD8);
            rt.r[0] = abi.read32(0x0802FFDC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x4);
            rt.r[0] = ~rt.r[0]; rt.updateNz(rt.r[0]);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0802FFE0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        10 => {
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
            continue :blk 15;
        },
        11 => {
            abi.fetches(3);
            popRegsSeq(&.{ 1 });
            continue :blk 16;
        },
        12 => {
            abi.fetches(23);
            rt.r[4] = abi.read32(0x0802FFA8);
            abi.setRegNz(&rt.r[0], 0x30);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            abi.write32(rt.r[4] +% 0x0, rt.r[0]);
            rt.r[2] = abi.read32(0x0802FFAC);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x4);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xC0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 18;
            }
            continue :blk 17;
        },
        13 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x0802FFE4);
            rt.r[0] = abi.read32(0x0802FFE8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0xC0);
            abi.setRegNz(&rt.r[3], rt.r[3] << 7);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            continue :blk 19;
        },
        14 => {
            abi.fetches(8);
            rt.r[2] = abi.read32(0x08030008);
            rt.r[0] = abi.read32(0x0803000C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[4], 0xC1);
            abi.setRegNz(&rt.r[4], rt.r[4] << 7);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            continue :blk 19;
        },
        15 => {
            abi.fetches(4);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            continue :blk 20;
        },
        16 => {
            abi.fetches(3);
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        17 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0802FFB0);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            continue :blk 18;
        },
        18 => {
            abi.fetches(5);
            abi.write32(rt.r[5] +% 0x0, rt.r[3]);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            continue :blk 7;
        },
        19 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 21;
        },
        20 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 21;
            }
            continue :blk 22;
        },
        21 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 7;
        },
        22 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x0802FF4C);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.write32(rt.r[2] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 24;
            }
            continue :blk 23;
        },
        23 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            continue :blk 24;
        },
        24 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802FF50);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            continue :blk 21;
        },
        else => unreachable,
    }
}

fn func_0803093C() callconv(.c) void {
    if (!abi.enter(0x0803093C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(29);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[10] = rt.r[0];
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            rt.r[3] = abi.read32(0x080309C8);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 17);
            rt.r[1] = abi.read32(0x080309CC);
            rt.cpuAdd(&rt.r[7], rt.r[6], rt.r[1], true);
            rt.r[2] = abi.read32(0x080309D0);
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[4] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            rt.r[4] = abi.read32(0x080309D4);
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[4]);
            rt.r[0] = abi.read32(0x080309D8);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.r[8] = rt.r[2];
            rt.r[9] = rt.r[0];
            rt.cpuSub(null, rt.r[5], rt.r[1], true);
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
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.r[0] +%= rt.r[8];
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[4]);
            rt.r[1] = rt.r[9];
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x1, true);
            rt.r[12] = rt.r[3];
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
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
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[6], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            rt.r[4] = rt.r[10];
            continue :blk 7;
        },
        6 => {
            abi.fetches(14);
            rt.r[1] = rt.r[8];
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[7]));
            rt.r[1] = abi.read32(0x080309D4);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.r[2] = rt.r[12];
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[2]);
            rt.r[3] = rt.r[9];
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 1;
        },
        7 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x1, true);
            rt.r[3] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[3], rt.r[6], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[6], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.r[12] = rt.r[8];
            rt.r[8] = rt.r[1];
            rt.r[4] = rt.r[10];
            rt.r[7] = rt.r[9];
            continue :blk 11;
        },
        10 => {
            abi.fetches(3);
            rt.r[1] = abi.read32(0x08030A1C);
            continue :blk 12;
        },
        11 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.r[0] +%= rt.r[12];
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            continue :blk 13;
        },
        12 => {
            abi.fetches(4);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            continue :blk 3;
        },
        13 => {
            abi.fetches(10);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            rt.r[0] = rt.r[8];
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[0]);
            rt.r[0] = abi.read16(rt.r[7] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 14;
        },
        14 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], rt.r[6], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        else => unreachable,
    }
}

fn func_08030AF0() callconv(.c) void {
    if (!abi.enter(0x08030AF0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x1, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x4);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[2], 23));
            rt.r[1] = rt.r[9];
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read32(0x08030B18);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
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
            abi.fetches(7);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            continue :blk 7;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 7;
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
        7 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[2], 23));
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.r[3] = abi.read32(0x08030B4C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[10] = rt.r[0];
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[6], 0x80, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(14);
            rt.r[0] = rt.r[9];
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            rt.r[0] = abi.read32(0x08030B50);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x3, true);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[5], 16));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(43);
            rt.r[1] = rt.r[9];
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.r[3] = abi.read32(0x08030C08);
            rt.r[12] = rt.r[3];
            rt.r[0] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.r[1] = abi.read32(0x08030C0C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[9] = rt.r[0];
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.r[0] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[3] = abi.read32(0x08030C10);
            rt.cpuAdd(&rt.r[1], rt.r[6], rt.r[3], true);
            rt.r[3] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[1], 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[6], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 6;
        },
        12 => {
            abi.fetches(6);
            rt.r[7] = abi.read32(0x08030C0C);
            rt.cpuAdd(&rt.r[5], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[2], 0x0, true);
            rt.r[4] = abi.read32(rt.r[13] +% 0x0);
            continue :blk 14;
        },
        13 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[8], rt.r[9], true);
            if (!rt.CPU_Z) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        14 => {
            abi.fetches(34);
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.r[0] +%= rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[8] = rt.r[0];
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            rt.r[0] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = abi.read16(rt.r[3] +% 0x0);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[1], rt.r[6], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        15 => {
            abi.fetches(6);
            rt.r[3] = rt.r[10];
            abi.setRegNz(&rt.r[0], rt.r[3] << 17);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 6;
        },
        16 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_08030C28() callconv(.c) void {
    if (!abi.enter(0x08030C28)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.r[0] = abi.read32(0x08030C40);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            rt.r[1] = abi.read32(0x08030C74);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x4);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.r[5] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[5], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
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
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(0x08030C78);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0xA);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08030CE4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x5);
            continue :blk 4;
        },
        8 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08030C7C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 12;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 12;
            }
            continue :blk 13;
        },
        11 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08030CA4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 15;
            }
            continue :blk 14;
        },
        12 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 11;
        },
        13 => {
            abi.fetches(3);
            continue :blk 11;
        },
        14 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x08030CA8);
            rt.r[0] = abi.read32(0x08030CAC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 16;
        },
        15 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 16;
        },
        16 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 18;
            }
            continue :blk 17;
        },
        17 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(decls.func_08030098, 0x08030CBD)) return;
            continue :blk 19;
        },
        18 => {
            abi.fetches(10);
            rt.r[2] = abi.read32(0x08030CDC);
            rt.r[0] = abi.read32(0x08030CE0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0xC1);
            abi.setRegNz(&rt.r[3], rt.r[3] << 7);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 7;
        },
        19 => {
            abi.fetches(3);
            continue :blk 7;
        },
        else => unreachable,
    }
}

fn func_08031364() callconv(.c) void {
    if (!abi.enter(0x08031364)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x8;
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[3] = abi.read32(0x08031478);
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[7], 0x6, true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 16);
            rt.r[8] = rt.r[5];
            abi.setRegNz(&rt.r[0], 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[12] = rt.r[0];
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x36, true);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            rt.r[5] = abi.read32(0x0803147C);
            rt.cpuAdd(&rt.r[3], rt.r[7], 0x3, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[5] = abi.read32(0x08031480);
            rt.cpuAdd(&rt.r[3], rt.r[6], 0x0, true);
            continue :blk 5;
        },
        5 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x16, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[2] = abi.read32(0x08031478);
            rt.r[9] = rt.r[2];
            rt.r[1] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            rt.r[10] = rt.r[12];
            rt.r[8] = rt.r[0];
            continue :blk 7;
        },
        7 => {
            abi.fetches(39);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 5);
            rt.r[1] = rt.r[9];
            rt.cpuAdd(&rt.r[4], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[3], rt.r[5] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[3], true);
            rt.r[12] = rt.r[0];
            rt.r[0] = abi.read16(rt.r[0] +% 0x20);
            abi.write16(rt.r[4] +% 0x20, @truncate(rt.r[0]));
            rt.r[1] = rt.r[12];
            rt.r[0] = abi.read16(rt.r[1] +% 0x22);
            abi.write16(rt.r[4] +% 0x22, @truncate(rt.r[0]));
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x35, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x35, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3B, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x6, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3C, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3C, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x1, true);
            rt.r[0] = rt.r[9];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[0] = rt.r[10];
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[0], true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(9);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x10, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.r[0] +%= rt.r[8];
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[2] = abi.read32(0x08031484);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[13] +% 0x4);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            continue :blk 10;
        },
        10 => {
            abi.fetches(9);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[5], rt.r[6], 0x0, true);
            rt.cpuSub(null, rt.r[5], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 12;
        },
        12 => {
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

fn func_08031C98() callconv(.c) void {
    if (!abi.enter(0x08031C98)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.r[8] = rt.r[0];
            continue :blk 1;
        },
        1 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x08031CD0);
            rt.r[4] = abi.read32(rt.r[2] +% 0x0);
            rt.r[7] = abi.read32(0x08031CD4);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[7], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = abi.read32(0x08031CD8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[5], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.r[3] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[3], 0x3F, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.r[1] = abi.read8(rt.r[5] +% 0x1);
            rt.r[0] = abi.read8(rt.r[4] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x24, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[5] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
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
            abi.fetches(16);
            rt.r[0] = abi.read32(0x08031D28);
            abi.setRegNz(&rt.r[1], 0x3E);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read8(rt.r[4] +% 0x6);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[1]));
            rt.r[3] = abi.read8(rt.r[5] +% 0x1);
            abi.setRegNz(&rt.r[1], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x4);
            if (!abi.call(func_0803093C, 0x08031D09)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x6, true);
            continue :blk 9;
        },
        8 => {
            abi.fetches(17);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[4]));
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[7], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[7], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        9 => {
            abi.fetches(12);
            rt.r[0] = rt.r[8];
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[2], 0x13, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(27);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[5] +% 0x1);
            rt.r[3] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x24, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[4] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.r[4] = abi.read32(0x08031D80);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[4], true);
            rt.r[1] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.r[2] = abi.read8(rt.r[3] +% 0x0);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[1]));
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[4], true);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[3]);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_08031D84() callconv(.c) void {
    if (!abi.enter(0x08031D84)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.r[8] = rt.r[0];
            continue :blk 1;
        },
        1 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x08031DBC);
            rt.r[4] = abi.read32(rt.r[2] +% 0x0);
            rt.r[6] = abi.read32(0x08031DC0);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[6], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = abi.read32(0x08031DC4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[5], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x0, true);
            rt.r[3] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[3], 0x3F, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.r[1] = abi.read8(rt.r[5] +% 0x1);
            rt.r[0] = abi.read8(rt.r[4] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x24, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[5] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
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
            abi.fetches(16);
            rt.r[0] = abi.read32(0x08031E14);
            abi.setRegNz(&rt.r[1], 0x3E);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read8(rt.r[4] +% 0x6);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[1]));
            rt.r[3] = abi.read8(rt.r[5] +% 0x1);
            abi.setRegNz(&rt.r[1], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x4);
            if (!abi.call(func_0803093C, 0x08031DF5)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 9;
        },
        8 => {
            abi.fetches(17);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[4]));
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        9 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x6, true);
            continue :blk 10;
        },
        10 => {
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
                continue :blk 10;
            }
            continue :blk 11;
        },
        11 => {
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
        else => unreachable,
    }
}

fn func_08031E12() callconv(.c) void {
    if (!abi.enter(0x08031E12)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[6], rt.r[5], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[5], 8));
            abi.setRegNz(&rt.r[0], rt.r[0]);
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], rt.r[0] << 8);
            continue :blk 5;
        },
        4 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x24, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[5] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 7;
        },
        6 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(0x08031E14);
            abi.setRegNz(&rt.r[1], 0x3E);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read8(rt.r[4] +% 0x6);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[1]));
            rt.r[3] = abi.read8(rt.r[5] +% 0x1);
            abi.setRegNz(&rt.r[1], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x4);
            if (!abi.call(func_0803093C, 0x08031DF5)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x6, true);
            continue :blk 9;
        },
        8 => {
            abi.fetches(17);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[4]));
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 10;
        },
        9 => {
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
                continue :blk 9;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x08031DBC);
            rt.r[4] = abi.read32(rt.r[2] +% 0x0);
            rt.r[6] = abi.read32(0x08031DC0);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[6], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = abi.read32(0x08031DC4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[5], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x0, true);
            rt.r[3] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[3], 0x3F, true);
            if (!rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        11 => {
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
            continue :blk 14;
        },
        12 => {
            abi.fetches(8);
            rt.r[1] = abi.read8(rt.r[5] +% 0x1);
            rt.r[0] = abi.read8(rt.r[4] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 14;
        },
        14 => {
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

fn func_08031E14() callconv(.c) void {
    if (!abi.enter(0x08031E14)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[6], rt.r[5], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[5], 8));
            abi.setRegNz(&rt.r[0], rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[1], rt.r[0] << 8);
            continue :blk 4;
        },
        3 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x24, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[5] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 6;
        },
        5 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(0x08031E14);
            abi.setRegNz(&rt.r[1], 0x3E);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read8(rt.r[4] +% 0x6);
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[1]));
            rt.r[3] = abi.read8(rt.r[5] +% 0x1);
            abi.setRegNz(&rt.r[1], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x4);
            if (!abi.call(func_0803093C, 0x08031DF5)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x6, true);
            continue :blk 8;
        },
        7 => {
            abi.fetches(17);
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[4]));
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 9;
        },
        8 => {
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
                continue :blk 8;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(17);
            rt.r[2] = abi.read32(0x08031DBC);
            rt.r[4] = abi.read32(rt.r[2] +% 0x0);
            rt.r[6] = abi.read32(0x08031DC0);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[6], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = abi.read32(0x08031DC4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[5], rt.r[4], rt.r[0], true);
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x0, true);
            rt.r[3] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[3], 0x3F, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        10 => {
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
            continue :blk 13;
        },
        11 => {
            abi.fetches(8);
            rt.r[1] = abi.read8(rt.r[5] +% 0x1);
            rt.r[0] = abi.read8(rt.r[4] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 13;
        },
        13 => {
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

fn func_08032130() callconv(.c) void {
    if (!abi.enter(0x08032130)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x080321E8);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[1], rt.r[5] << 5);
            rt.r[12] = rt.r[1];
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x2, true);
            rt.r[10] = rt.r[2];
            abi.setRegNz(&rt.r[1], rt.r[5] << 6);
            rt.r[0] = rt.r[8];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x40, true);
            rt.cpuAdd(&rt.r[3], rt.r[1], rt.r[0], true);
            rt.r[6] = rt.r[8];
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[6], true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(21);
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[5], true);
            abi.setRegNz(&rt.r[1], 0x7);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[6] = abi.read32(0x080321EC);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[6], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[7], true);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x080321F0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.write16(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x1F, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[5] >> 2);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[2] = abi.read32(0x080321F4);
            rt.r[9] = rt.r[2];
            rt.r[1] = abi.read32(0x080321F8);
            rt.cpuAdd(&rt.r[5], rt.r[0], rt.r[1], true);
            rt.r[6] = abi.read32(0x080321FC);
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[5] = rt.r[10];
            rt.cpuSub(null, rt.r[5], 0x1F, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(27);
            rt.r[3] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[4], true);
            rt.r[2] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[8];
            abi.setRegNz(&rt.r[3], rt.r[4] << 1);
            abi.write32(rt.r[13] +% 0x0, rt.r[3]);
            rt.r[3] = abi.read16(rt.r[6] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[7], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[1] +%= rt.r[8];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x40, true);
            rt.r[3] = abi.read32(rt.r[13] +% 0x0);
            rt.r[3] +%= rt.r[9];
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[7], true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x2, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x7, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011834, 0x080321D9)) return;
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

fn func_08032508() callconv(.c) void {
    if (!abi.enter(0x08032508)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(31);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[6], 0);
            rt.cpuSub(null, rt.r[3], 0xA0, true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 24);
            rt.cpu_undefined(0xB770);
            abi.setRegNz(&rt.r[6], 0);
            rt.cpuSub(null, rt.r[5], 0x20, true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 24);
            rt.cpu_undefined(0xB850);
            abi.setRegNz(&rt.r[6], 0);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 24);
            rt.r[6] = abi.read32(0x08032754);
            abi.setRegNz(&rt.r[1], 0);
            abi.setRegNz(&rt.r[1], rt.r[7] << 5);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            popRegsSeq(&.{ 2, 3, 6 });
            abi.setRegNz(&rt.r[0], 0);
            abi.write32(rt.r[13] +% 0xA0, rt.r[3]);
            abi.setRegNz(&rt.r[6], 0);
            stmRegs(0, &.{ 2, 3, 4, 5, 6 });
            abi.setRegNz(&rt.r[0], 0);
            abi.setRegNz(&rt.r[5], rt.r[1] << 5);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            rt.cpu_undefined(0xBFFC);
            abi.setRegNz(&rt.r[0], 0);
            abi.setRegNz(&rt.r[1], rt.r[6] << 6);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            if (!rt.CPU_N) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            stmRegs(0, &.{ 2, 3, 4, 6 });
            abi.setRegNz(&rt.r[0], 0);
            abi.setRegNz(&rt.r[5], rt.r[6] << 5);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            decls.func_08032644(); return;
        },
        2 => {
            abi.fetches(41);
            abi.setRegNz(&rt.r[0], 0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x20, true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 24);
            abi.write32(rt.r[7] +% rt.r[4], rt.r[4]);
            abi.setRegNz(&rt.r[0], 0);
            abi.setRegNz(&rt.r[7], rt.r[4] << 4);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            rt.r[0] = abi.read32(rt.r[5] +% 0x2C);
            abi.setRegNz(&rt.r[1], 0);
            stmRegs(0, &.{ 2, 3, 4, 7 });
            abi.setRegNz(&rt.r[0], 0);
            rt.r[6] = abi.read32(rt.r[13] +% 0x120);
            abi.setRegNz(&rt.r[6], 0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.r[1] = 0x08032684;
            abi.setRegNz(&rt.r[6], 0);
            abi.setRegNz(&rt.r[0], rt.r[0]);
            abi.setRegNz(&rt.r[1], rt.r[0] << 24);
            rt.r[0] = abi.read32(rt.r[5] +% 0x38);
            abi.setRegNz(&rt.r[1], 0);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x40, true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 8);
            rt.cpuSub(null, rt.r[6], 0x48, true);
            abi.setRegNz(&rt.r[0], 0);
            stmRegs(1, &.{ 3, 4, 5, 6, 7 });
            abi.setRegNz(&rt.r[2], 0);
            abi.setRegNz(&rt.r[0], rt.r[4] >> 23);
            abi.setRegNz(&rt.r[7], 0);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0xA0, true);
            abi.setRegNz(&rt.r[1], rt.r[0] << 24);
            abi.write16(rt.r[1] +% 0x16, @truncate(rt.r[4]));
            abi.setRegNz(&rt.r[2], 0);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.r[4] = abi.read16(rt.r[4] +% 0x24);
            abi.setRegNz(&rt.r[2], 0);
            stmRegs(0, &.{ 2, 3, 4, 6 });
            abi.setRegNz(&rt.r[0], 0);
            decls.func_08032590(); return;
        },
        else => unreachable,
    }
}

fn func_08032D68() callconv(.c) void {
    if (!abi.enter(0x08032D68)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.r[13] -%= 0x34;
            rt.r[7] = abi.read32(0x08032E04);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[4] = abi.read32(0x08032E08);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[2], rt.r[7], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[7], 0x6, true);
            abi.setRegNz(&rt.r[0], 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[1], 0x36);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[7], true);
            rt.r[9] = rt.r[1];
            rt.cpuAdd(&rt.r[4], rt.r[7], 0x3, true);
            rt.r[5] = abi.read32(0x08032E0C);
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            rt.r[5] = abi.read32(0x08032E10);
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[2], rt.r[4], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x16, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[6], 0x0);
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[4], rt.r[6] << 24);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803F148, 0x08032DCF)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[5], rt.r[6] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x35, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.r[1] = rt.r[13];
            if (!abi.call(decls.func_0803F0FC, 0x08032DDF)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[2] = abi.read32(0x08032E14);
            rt.r[12] = rt.r[2];
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x1, true);
            rt.r[0] = rt.r[8];
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[0], true);
            continue :blk 12;
        },
        11 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08032E74);
            rt.r[12] = rt.r[0];
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x1, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[3], 0x10);
            rt.r[2] = rt.r[8];
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            continue :blk 13;
        },
        12 => {
            abi.fetches(10);
            rt.r[2] = rt.r[13];
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x10, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 12;
            }
            continue :blk 14;
        },
        13 => {
            abi.fetches(7);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 15;
        },
        14 => {
            abi.fetches(3);
            continue :blk 15;
        },
        15 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08032E74);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x16, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], rt.r[0], true);
            rt.r[0] = rt.r[9];
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[3], 0x4);
            continue :blk 16;
        },
        16 => {
            abi.fetches(9);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 16;
            }
            continue :blk 17;
        },
        17 => {
            abi.fetches(15);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[5], true);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[2], rt.r[5], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x1B);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x3B, true);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read8(rt.r[2] +% 0x1C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3C, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[6], rt.r[4], 0x0, true);
            rt.cpuSub(null, rt.r[6], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 18;
        },
        18 => {
            abi.fetches(9);
            rt.r[13] +%= 0x34;
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

fn func_08032FC8() callconv(.c) void {
    if (!abi.enter(0x08032FC8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[5] = abi.read32(0x08033038);
            rt.r[4] = abi.read32(0x0803303C);
            rt.r[3] = abi.read32(0x08033040);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
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
            rt.r[4] = abi.read32(0x08033044);
            rt.r[3] = abi.read32(0x08033048);
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
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
            rt.r[4] = abi.read32(0x0803304C);
            rt.r[3] = abi.read32(0x08033050);
            continue :blk 5;
        },
        5 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[3], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x16, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[2] = abi.read32(0x08033040);
            rt.r[4] = abi.read32(0x08033054);
            abi.setRegNz(&rt.r[3], 0xB);
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        9 => {
            abi.fetches(16);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            ldmRegs(0, &.{ 5, 6, 7 });
            stmRegs(1, &.{ 5, 6, 7 });
            ldmRegs(0, &.{ 5, 6, 7 });
            stmRegs(1, &.{ 5, 6, 7 });
            ldmRegs(0, &.{ 5, 6 });
            stmRegs(1, &.{ 5, 6 });
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x20, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x20, true);
            rt.cpuSub(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_080337A8() callconv(.c) void {
    if (!abi.enter(0x080337A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[0] = abi.read32(0x0803384C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[4] = abi.read16(rt.r[0] +% 0x4);
            if (!abi.call(decls.func_080308EC, 0x080337B5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.r[0] = abi.read32(0x08033850);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x08033850);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[6] = abi.read32(0x0803384C);
            abi.setRegNz(&rt.r[2], rt.r[4] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[3] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 8));
            rt.r[2] = abi.read32(0x08033854);
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[3] << 24);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[0], 24));
            rt.r[5] = abi.read32(0x08033854);
            continue :blk 7;
        },
        5 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x4);
            abi.write16(rt.r[0] +% 0x6, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[4]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            rt.r[4] = abi.read32(0x08033858);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        7 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 9);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x67);
            if (!abi.call(decls.func_0803D880, 0x08033833)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            rt.r[4] = abi.read16(rt.r[2] +% 0x4);
            rt.r[0] = abi.read16(rt.r[2] +% 0x6);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 15;
            }
            continue :blk 14;
        },
        10 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 16);
            continue :blk 11;
        },
        11 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 2;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 13;
        },
        13 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 5;
        },
        14 => {
            abi.fetches(7);
            rt.r[0] = abi.read16(rt.r[2] +% 0xA);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write16(rt.r[2] +% 0xA, @truncate(rt.r[0]));
            continue :blk 15;
        },
        15 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08033918() callconv(.c) void {
    if (!abi.enter(0x08033918)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x8;
            rt.r[6] = abi.read32(0x080339D8);
            abi.setRegNz(&rt.r[5], 0x14);
            abi.write32(rt.r[13] +% 0x0, rt.r[5]);
            abi.setRegNz(&rt.r[4], 0xBA);
            abi.setRegNz(&rt.r[4], rt.r[4] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x20);
            if (!abi.call(decls.func_08010C70, 0x08033935)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x080339DC);
            abi.write32(rt.r[13] +% 0x0, rt.r[5]);
            abi.write32(rt.r[13] +% 0x4, rt.r[4]);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x20);
            if (!abi.call(decls.func_08010C70, 0x08033945)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x080339E0);
            abi.setRegNz(&rt.r[1], 0x4);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            rt.r[1] = abi.read32(0x080339E4);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xD);
            abi.setRegNz(&rt.r[2], 0x1);
            abi.setRegNz(&rt.r[3], 0xD);
            if (!abi.call(decls.func_08010C70, 0x08033959)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0xB);
            abi.setRegNz(&rt.r[1], 0x5);
            abi.setRegNz(&rt.r[2], 0xE);
            abi.setRegNz(&rt.r[3], 0x7);
            if (!abi.call(decls.func_080197D8, 0x08033965)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(13);
            rt.r[3] = abi.read32(0x080339E8);
            abi.setRegNz(&rt.r[5], 0x80);
            abi.setRegNz(&rt.r[5], rt.r[5] << 8);
            abi.write32(rt.r[13] +% 0x0, rt.r[5]);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write32(rt.r[13] +% 0x4, rt.r[4]);
            abi.setRegNz(&rt.r[0], 0xC);
            abi.setRegNz(&rt.r[1], 0x6);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_08012A68, 0x0803397B)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(10);
            rt.r[3] = abi.read32(0x080339EC);
            abi.write32(rt.r[13] +% 0x0, rt.r[5]);
            abi.write32(rt.r[13] +% 0x4, rt.r[4]);
            abi.setRegNz(&rt.r[0], 0xC);
            abi.setRegNz(&rt.r[1], 0x8);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_08012A68, 0x0803398B)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x0803398F)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011814, 0x08033993)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011824, 0x08033997)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(decls.func_08032240, 0x0803399D)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(9);
            rt.r[4] = abi.read32(0x080339F0);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x8);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08032B34, 0x080339AB)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(15);
            rt.r[4] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080339F4);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read8(rt.r[4] +% 0x9);
            rt.r[0] = abi.read32(0x080339F8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 13;
        },
        12 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x08033A20);
            continue :blk 14;
        },
        13 => {
            abi.fetches(9);
            rt.r[0] = abi.read8(rt.r[4] +% 0x8);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x5, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x080339FC);
            if (!abi.call(decls.func_0801AC1C, 0x080339D3)) return;
            continue :blk 15;
        },
        14 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08033A0D)) return;
            continue :blk 16;
        },
        15 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08033A00);
            continue :blk 14;
        },
        16 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08033A24);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            abi.write16(rt.r[1] +% 0x1C, @truncate(rt.r[0]));
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08033C90() callconv(.c) void {
    if (!abi.enter(0x08033C90)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[4] = abi.read32(0x08033D24);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[5] = abi.read16(rt.r[0] +% 0x4);
            rt.r[0] = abi.read32(0x08033D28);
            if (!abi.call(decls.func_08013B70, 0x08033C9F)) return;
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
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x08033D2C);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x20);
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
            abi.setRegNz(&rt.r[3], 0x3);
            rt.r[1] = abi.read32(0x08033D30);
            continue :blk 6;
        },
        5 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x10);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(8);
            rt.cpuSub(&rt.r[5], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[2], 0x3);
            rt.r[1] = abi.read32(0x08033D30);
            continue :blk 10;
        },
        8 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x4);
            abi.write16(rt.r[0] +% 0x6, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[5]));
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 11;
        },
        9 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x10, @truncate(rt.r[0]));
            continue :blk 5;
        },
        10 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(6);
            rt.r[4] = abi.read32(0x08033D28);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0801329C, 0x08033D09)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write8(rt.r[1] +% 0x10, @truncate(rt.r[0]));
            continue :blk 8;
        },
        13 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08033D34);
            if (!abi.call(decls.func_0801329C, 0x08033D0F)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08033D17)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x67);
            if (!abi.call(decls.func_0803D880, 0x08033D1D)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08033D38() callconv(.c) void {
    if (!abi.enter(0x08033D38)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x14;
            rt.r[0] = rt.r[13] +% 0x8;
            rt.r[1] = abi.read32(0x08033DFC);
            ldmRegs(1, &.{ 2, 3, 4 });
            stmRegs(0, &.{ 2, 3, 4 });
            rt.r[7] = abi.read32(0x08033E00);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0xC);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(14);
            rt.r[4] = abi.read32(0x08033E14);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0xBA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xE);
            abi.setRegNz(&rt.r[2], 0x2);
            abi.setRegNz(&rt.r[3], 0xC);
            if (!abi.call(decls.func_08010C70, 0x08033D9B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(17);
            rt.r[6] = abi.read32(0x08033E04);
            rt.r[5] = abi.read32(0x08033E08);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 3);
            abi.setRegNz(&rt.r[4], 0x3);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[4]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            abi.setRegNz(&rt.r[0], 0x58);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(0x08033E0C);
            abi.setRegNz(&rt.r[1], 0x4C);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_0801B888, 0x08033D6D)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(19);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[0] +%= rt.r[13];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[6], 0x80);
            abi.setRegNz(&rt.r[6], rt.r[6] << 8);
            abi.write32(rt.r[13] +% 0x0, rt.r[6]);
            abi.setRegNz(&rt.r[5], 0x0);
            abi.write32(rt.r[13] +% 0x4, rt.r[5]);
            abi.setRegNz(&rt.r[0], 0xE);
            abi.setRegNz(&rt.r[1], 0x2);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08012A68, 0x08033DBD)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 3);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xD8, true);
            rt.r[2] = abi.read32(0x08033E10);
            abi.setRegNz(&rt.r[1], 0x4C);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_0801B888, 0x08033D83)) return;
            continue :blk 1;
        },
        5 => {
            abi.fetches(18);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[3], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 2);
            rt.cpuSub(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read32(0x08033E18);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.write32(rt.r[13] +% 0x0, rt.r[6]);
            abi.write32(rt.r[13] +% 0x4, rt.r[5]);
            abi.setRegNz(&rt.r[0], 0x10);
            abi.setRegNz(&rt.r[1], 0x2);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08012A68, 0x08033DDD)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x08033E1C);
            rt.r[3] = abi.read32(0x08033E20);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08033E24);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0xE);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x60, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08011804, 0x08033DF3)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.r[13] +%= 0x14;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08033EB4() callconv(.c) void {
    if (!abi.enter(0x08033EB4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x3C;
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[6] = abi.read32(0x08033F48);
            rt.r[5] = abi.read32(0x08033F4C);
            rt.r[3] = abi.read32(0x08033F50);
            abi.setRegNz(&rt.r[2], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[3], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(15);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0xC, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[4], 0xA);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            rt.r[0] = abi.read32(0x08033F54);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.setRegNz(&rt.r[2], 0x5);
            abi.setRegNz(&rt.r[3], 0xC);
            if (!abi.call(decls.func_08010C70, 0x08033EE9)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x08033F58);
            abi.write32(rt.r[13] +% 0x0, rt.r[4]);
            abi.setRegNz(&rt.r[1], 0xBA);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            abi.write32(rt.r[13] +% 0x4, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xA);
            abi.setRegNz(&rt.r[2], 0x5);
            abi.setRegNz(&rt.r[3], 0xC);
            if (!abi.call(decls.func_08010C70, 0x08033EFD)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0xD);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[2], 0xD);
            abi.setRegNz(&rt.r[3], 0x4);
            if (!abi.call(decls.func_080197D8, 0x08033F09)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_08032240, 0x08033F0F)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011804, 0x08033F13)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011824, 0x08033F17)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = rt.r[13] +% 0x8;
            if (!abi.call(decls.func_0803F0FC, 0x08033F25)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08033F5C);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.r[1] = rt.r[13] +% 0x8;
            if (!abi.call(decls.func_08033094, 0x08033F37)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(0x08033FE0);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read8(rt.r[0] +% 0x9);
            rt.r[0] = abi.read32(0x08033FE4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 15;
            }
            continue :blk 14;
        },
        13 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x08033F50);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08033F48);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 16;
        },
        14 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08033FE8);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.r[1] = abi.read32(0x08033FEC);
            if (!abi.call(decls.func_0807A830, 0x08033F81)) return;
            continue :blk 17;
        },
        15 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x13, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 18;
        },
        16 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0xC);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[1] +% 0xC, @truncate(rt.r[0]));
            continue :blk 15;
        },
        17 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x08033FF0);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            continue :blk 16;
        },
        18 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[4], 0x2);
            rt.r[6] = abi.read32(0x08033FE0);
            rt.r[2] = abi.read32(0x08033FF0);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            continue :blk 19;
        },
        19 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 21;
            }
            continue :blk 20;
        },
        20 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[4]));
            abi.write16(rt.r[0] +% 0x6, @truncate(rt.r[4]));
            continue :blk 21;
        },
        21 => {
            abi.fetches(5);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 19;
            }
            continue :blk 22;
        },
        22 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write8(rt.r[0] +% 0x10, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.write16(rt.r[0] +% 0xE, @truncate(rt.r[4]));
            if (!abi.call(decls.func_08033E28, 0x08033FC7)) return;
            continue :blk 23;
        },
        23 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08033BFC, 0x08033FCB)) return;
            continue :blk 24;
        },
        24 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            abi.write16(rt.r[0] +% 0xA, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(0x08033FF4);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08033FD7)) return;
            continue :blk 25;
        },
        25 => {
            abi.fetches(6);
            rt.r[13] +%= 0x3C;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0803402C() callconv(.c) void {
    if (!abi.enter(0x0803402C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[4] = abi.read32(0x080340AC);
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
            if (!abi.call(decls.func_0803D880, 0x08034043)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            rt.r[6] = abi.read32(0x080340B0);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_08013B70, 0x08034057)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[5] = abi.read32(0x080340B4);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08013B70, 0x0803406B)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803401C, 0x08034077)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0801329C, 0x0803407D)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801329C, 0x08034083)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(15);
            rt.r[0] = abi.read32(0x080340B8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write8(rt.r[0] +% 0x8, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x080340BC);
            rt.r[0] = abi.read32(0x080340C0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x71);
            if (!abi.call(decls.func_0803D880, 0x0803409D)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x080340C4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x080340A5)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_080345B0() callconv(.c) void {
    if (!abi.enter(0x080345B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[0] = abi.read32(0x080345F8);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.r[1] = abi.read32(0x080345FC);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[5] = abi.read32(0x08034670);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(func_08031D84, 0x08034609)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            if (!abi.call(func_08031D84, 0x080345D3)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        5 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2E, true);
            rt.cpuAdd(&rt.r[6], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x2F, true);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[4] +% 0x20);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        7 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x80, true);
            abi.write32(rt.r[4] +% 0x24, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x64);
            rt.r[2] = abi.read16(rt.r[4] +% 0x2C);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            if (!abi.call(decls.func_0807B488, 0x080345F1)) return;
            continue :blk 12;
        },
        8 => {
            abi.fetches(13);
            rt.r[1] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[4] +% 0x24, rt.r[0]);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.r[1] = abi.read8(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[1], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x64);
            rt.r[2] = abi.read16(rt.r[4] +% 0x2C);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            if (!abi.call(decls.func_0807B488, 0x08034647)) return;
            continue :blk 13;
        },
        10 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0807B450, 0x0803465B)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(6);
            rt.r[0] = abi.read16(rt.r[4] +% 0x2C);
            rt.r[1] = abi.read16(rt.r[4] +% 0x2A);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_C) {
                continue :blk 15;
            }
            continue :blk 14;
        },
        12 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2F, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 16;
        },
        13 => {
            abi.fetches(3);
            abi.write8(rt.r[6] +% 0x0, @truncate(rt.r[0]));
            continue :blk 16;
        },
        14 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08034674);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0803466B)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        16 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0x2C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x2C, @truncate(rt.r[0]));
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_08034A1C() callconv(.c) void {
    if (!abi.enter(0x08034A1C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08034A44);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08034B40);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x6, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08034A48);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08034B44);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x6, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08034B48);
            if (!abi.call(decls.func_08013B70, 0x08034B21)) return;
            continue :blk 7;
        },
        5 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08034A4C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x11, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x08034A50);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08034B0A => { continue :blk 1; },
                0x08034A9C => continue :blk 11,
                0x08034AA2 => continue :blk 12,
                0x08034AA8 => continue :blk 13,
                0x08034AAE => continue :blk 14,
                0x08034AD2 => continue :blk 20,
                0x08034AD8 => continue :blk 21,
                0x08034AC0 => continue :blk 17,
                0x08034AC6 => continue :blk 18,
                0x08034ACC => continue :blk 19,
                0x08034AB4 => continue :blk 15,
                0x08034ABA => continue :blk 16,
                0x08034AF2 => continue :blk 23,
                0x08034AF8 => continue :blk 24,
                0x08034AFE => continue :blk 25,
                0x08034AEC => continue :blk 22,
                0x08034B04 => continue :blk 26,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        9 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08034B4C);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x3);
            if (!abi.call(decls.func_08026FC8, 0x08034B3D)) return;
            continue :blk 6;
        },
        11 => {
            abi.fetches(4);
            if (!abi.call(func_08034D68, 0x08034AA1)) return;
            continue :blk 27;
        },
        12 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08034E1C, 0x08034AA7)) return;
            continue :blk 28;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(func_08034EE8, 0x08034AAD)) return;
            continue :blk 29;
        },
        14 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080350C0, 0x08034AB3)) return;
            continue :blk 30;
        },
        15 => {
            abi.fetches(4);
            if (!abi.call(func_080350DC, 0x08034AB9)) return;
            continue :blk 31;
        },
        16 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035170, 0x08034ABF)) return;
            continue :blk 32;
        },
        17 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035004, 0x08034AC5)) return;
            continue :blk 33;
        },
        18 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035018, 0x08034ACB)) return;
            continue :blk 34;
        },
        19 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803502C, 0x08034AD1)) return;
            continue :blk 35;
        },
        20 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802EF60, 0x08034AD7)) return;
            continue :blk 36;
        },
        21 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08034AE8);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 37;
        },
        22 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080347BC, 0x08034AF1)) return;
            continue :blk 38;
        },
        23 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803519C, 0x08034AF7)) return;
            continue :blk 39;
        },
        24 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080351BC, 0x08034AFD)) return;
            continue :blk 40;
        },
        25 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080351C8, 0x08034B03)) return;
            continue :blk 41;
        },
        26 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080351F4, 0x08034B09)) return;
            continue :blk 42;
        },
        27 => {
            abi.fetches(3);
            continue :blk 1;
        },
        28 => {
            abi.fetches(3);
            continue :blk 1;
        },
        29 => {
            abi.fetches(3);
            continue :blk 1;
        },
        30 => {
            abi.fetches(3);
            continue :blk 1;
        },
        31 => {
            abi.fetches(3);
            continue :blk 1;
        },
        32 => {
            abi.fetches(3);
            continue :blk 1;
        },
        33 => {
            abi.fetches(3);
            continue :blk 1;
        },
        34 => {
            abi.fetches(3);
            continue :blk 1;
        },
        35 => {
            abi.fetches(3);
            continue :blk 1;
        },
        36 => {
            abi.fetches(3);
            continue :blk 1;
        },
        37 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0806820C, 0x08034AE7)) return;
            continue :blk 43;
        },
        38 => {
            abi.fetches(3);
            continue :blk 1;
        },
        39 => {
            abi.fetches(3);
            continue :blk 1;
        },
        40 => {
            abi.fetches(3);
            continue :blk 1;
        },
        41 => {
            abi.fetches(3);
            continue :blk 1;
        },
        42 => {
            abi.fetches(3);
            continue :blk 6;
        },
        43 => {
            abi.fetches(3);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08034CE4() callconv(.c) void {
    if (!abi.enter(0x08034CE4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x4;
            rt.r[1] = abi.read32(0x08034D38);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
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
            rt.r[0] = abi.read8(rt.r[1] +% 0xD);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
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
            abi.fetches(5);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1);
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[4], 0x1);
            rt.r[2] = abi.read32(0x08034D3C);
            abi.setRegNz(&rt.r[7], 0x68);
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            if (!abi.call(decls.func_08024CD0, 0x08034D11)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[6], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 1;
        },
        10 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[7]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1B);
            rt.cpuSub(null, rt.r[1], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[7]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1B);
            rt.cpuSub(null, rt.r[1], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 13;
        },
        12 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 14;
        },
        13 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[5] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[6], 0x1);
            continue :blk 9;
        },
        14 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08034D68() callconv(.c) void {
    if (!abi.enter(0x08034D68)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 5, 14 });
            if (!abi.call(decls.func_08016F0C, 0x08034D6F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08034D94);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x30, true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08034D9C);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08024D20, 0x08034D7F)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
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
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08034D98);
            rt.r[4] = abi.read8(rt.r[4] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 2;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08016F18, 0x08034DA5)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[5], 0x0);
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08024CD0, 0x08034DAF)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08034E14);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x10);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (rt.CPU_C) {
                continue :blk 12;
            }
            continue :blk 13;
        },
        12 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 9;
            }
            continue :blk 14;
        },
        13 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            continue :blk 12;
        },
        14 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 15;
        },
        15 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08024CD0, 0x08034DD9)) return;
            continue :blk 16;
        },
        16 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 18;
            }
            continue :blk 17;
        },
        17 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08034E14);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x10);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 18;
            }
            continue :blk 19;
        },
        18 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 15;
            }
            continue :blk 20;
        },
        19 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x40);
            if (!abi.call(decls.func_08028714, 0x08034DF7)) return;
            continue :blk 18;
        },
        20 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08025564, 0x08034E05)) return;
            continue :blk 21;
        },
        21 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08028400, 0x08034E09)) return;
            continue :blk 22;
        },
        22 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(0x08034E18);
            abi.setRegNz(&rt.r[0], 0xE);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08034EE8() callconv(.c) void {
    if (!abi.enter(0x08034EE8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6 });
            if (!abi.call(func_08034CE4, 0x08034EF3)) return;
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
            if (!abi.call(decls.func_08024D58, 0x08034F95)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08034FD0);
            rt.r[8] = rt.r[0];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08024CF8, 0x08034F03)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08024EB8, 0x08034F99)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[6] = abi.read32(0x08034FD4);
            rt.r[2] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[5], 0x68);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[5]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read32(0x08034FD8);
            rt.r[4] = abi.read8(rt.r[1] +% 0x1A);
            rt.cpuSub(&rt.r[4], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[4] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            if (!abi.call(decls.func_0802FC70, 0x08034F21)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08034FD0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_0801BFE8, 0x08034FA1)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x08034FDC);
            abi.setRegNz(&rt.r[4], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.r[4] = abi.read8(rt.r[4] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[4] << 5);
            rt.r[1] = abi.read32(0x08034FE0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x98);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_08011330, 0x08034F39)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021DF8, 0x08034FA5)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08034FE4);
            abi.setRegNz(&rt.r[0], 0x38);
            if (!abi.call(decls.func_08034E58, 0x08034F41)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08068A64, 0x08034FA9)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(7);
            rt.r[4] = abi.read32(0x08034FE8);
            rt.r[1] = rt.r[8];
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            if (!abi.call(decls.func_08024CF8, 0x08034F4B)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(4);
            if (!abi.call(func_08034CE4, 0x08034FAD)) return;
            continue :blk 14;
        },
        13 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[1] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[5]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1A);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x4E);
            if (!abi.call(decls.func_08034E7C, 0x08034F63)) return;
            continue :blk 15;
        },
        14 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 17;
            }
            continue :blk 16;
        },
        15 => {
            abi.fetches(8);
            rt.r[4] = abi.read32(0x08034FEC);
            rt.r[0] = abi.read32(0x08034FF0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_0807B634, 0x08034F6F)) return;
            continue :blk 18;
        },
        16 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802C354, 0x08034FB7)) return;
            continue :blk 17;
        },
        17 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035000, 0x08034FBB)) return;
            continue :blk 19;
        },
        18 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_0807B6AC, 0x08034F75)) return;
            continue :blk 20;
        },
        19 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803D968, 0x08034FBF)) return;
            continue :blk 21;
        },
        20 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x68, true);
            rt.r[1] = abi.read32(0x08034FF4);
            if (!abi.call(decls.func_08034E58, 0x08034F83)) return;
            continue :blk 22;
        },
        21 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08034FFC);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 23;
        },
        22 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08034FF8);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 23;
            }
            continue :blk 2;
        },
        23 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080350DC() callconv(.c) void {
    if (!abi.enter(0x080350DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0803515C);
            if (!abi.call(decls.func_08013B70, 0x080350E5)) return;
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
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0801B8D4, 0x080350F7)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08035160);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(12);
            rt.r[2] = abi.read32(0x08035164);
            rt.r[0] = abi.read32(0x08035168);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1B);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(16);
            rt.r[1] = abi.read32(0x08035164);
            rt.r[0] = abi.read32(0x08035168);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2B, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2C, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            if (!abi.call(decls.func_0802928C, 0x08035131)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0803515C);
            if (!abi.call(decls.func_08013B70, 0x08035137)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08035164);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_0801BE88, 0x0803514B)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802BF70, 0x0803514F)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035454, 0x08035153)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0803516C);
            abi.setRegNz(&rt.r[0], 0xC);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_080353D4() callconv(.c) void {
    if (!abi.enter(0x080353D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[2] = abi.read32(0x08035408);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            rt.r[5] = abi.read32(0x0803540C);
            rt.r[0] = abi.read8(rt.r[5] +% 0x2);
            if (!abi.call(decls.func_08010A9C, 0x080353FF)) return;
            continue :blk 7;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 11;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x1);
            continue :blk 4;
        },
        10 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[5] +% 0x1);
            if (!abi.call(decls.func_08010A9C, 0x08035417)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2F, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        12 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 15;
        },
        13 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 14;
        },
        14 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080352EC, 0x0803543D)) return;
            continue :blk 16;
        },
        15 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[4], 0x2);
            continue :blk 4;
        },
        16 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 17;
        },
        17 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08035450);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2F, true);
            rt.r[4] = abi.read8(rt.r[0] +% 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08035488() callconv(.c) void {
    if (!abi.enter(0x08035488)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[0] = abi.read32(0x08035508);
            rt.r[1] = abi.read32(0x0803550C);
            abi.setRegNz(&rt.r[2], 0x60);
            if (!abi.call(decls.func_0800FDA4, 0x08035495)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[7] = abi.read32(0x08035510);
            rt.r[6] = abi.read32(0x08035514);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010A84, 0x0803549F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[1], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[5], rt.r[1], rt.r[7], true);
            abi.setRegNz(&rt.r[1], 0xFF);
            if (!abi.call(decls.func_0807B6AC, 0x080354B1)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08010A84, 0x080354B9)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0xFF);
            if (!abi.call(decls.func_0807B6AC, 0x080354BF)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            abi.write16(rt.r[5] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(29);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[5] +% 0x4, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[5] +% 0x6, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[5] +% 0x8, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x1F, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08035518() callconv(.c) void {
    if (!abi.enter(0x08035518)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[4] = abi.read32(0x080355A4);
            rt.r[3] = abi.read32(0x080355A8);
            continue :blk 1;
        },
        1 => {
            abi.fetches(22);
            abi.setRegNz(&rt.r[2], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[5] = abi.read16(rt.r[0] +% 0x0);
            rt.r[6] = abi.read16(rt.r[0] +% 0x4);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[6], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[7] = abi.read16(rt.r[0] +% 0x2);
            rt.r[5] = abi.read16(rt.r[0] +% 0x6);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[5], true);
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuSub(null, rt.r[2], 0x1F, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[4], rt.r[0] << 20);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[6] = abi.read32(0x080355A8);
            rt.r[8] = rt.r[6];
            abi.setRegNz(&rt.r[5], 0xFF);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
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
            abi.fetches(23);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[2], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[4], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.r[2] +%= rt.r[8];
            rt.r[7] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 8);
            rt.r[1] = abi.read32(0x080355AC);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read16(rt.r[3] +% 0x4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.r[7] = abi.read16(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[1], rt.r[7] >> 8);
            rt.r[3] = abi.read16(rt.r[3] +% 0x6);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[5]);
            rt.r[3] = abi.read16(rt.r[2] +% 0x8);
            rt.r[2] = abi.read32(0x080355B0);
            if (!abi.call(decls.func_080158E4, 0x08035591)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[4], 16));
            rt.cpuSub(null, rt.r[0], rt.r[6], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_080355B4() callconv(.c) void {
    if (!abi.enter(0x080355B4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[0] = abi.read32(0x08035638);
            rt.r[1] = abi.read32(0x0803563C);
            abi.setRegNz(&rt.r[2], 0x60);
            if (!abi.call(decls.func_0800FDA4, 0x080355C1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[7] = abi.read32(0x08035640);
            rt.r[6] = abi.read32(0x08035644);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010A84, 0x080355CB)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[1], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[5], rt.r[1], rt.r[7], true);
            abi.setRegNz(&rt.r[1], 0xFF);
            if (!abi.call(decls.func_0807B6AC, 0x080355DD)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08010A84, 0x080355E5)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0xFF);
            if (!abi.call(decls.func_0807B6AC, 0x080355EB)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            abi.write16(rt.r[5] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(32);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuSub(&rt.r[0], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[2], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.r[3] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.write16(rt.r[5] +% 0x4, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            abi.write16(rt.r[5] +% 0x6, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[6], true);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[5] +% 0x8, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x1F, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08035648() callconv(.c) void {
    if (!abi.enter(0x08035648)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[4] = abi.read32(0x080356DC);
            rt.r[3] = abi.read32(0x080356E0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(22);
            abi.setRegNz(&rt.r[2], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[5] = abi.read16(rt.r[0] +% 0x0);
            rt.r[6] = abi.read16(rt.r[0] +% 0x4);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[6], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[7] = abi.read16(rt.r[0] +% 0x2);
            rt.r[5] = abi.read16(rt.r[0] +% 0x6);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[5], true);
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuSub(null, rt.r[2], 0x1F, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[4], rt.r[0] << 20);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[6] = abi.read32(0x080356E0);
            rt.r[8] = rt.r[6];
            abi.setRegNz(&rt.r[5], 0xFF);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
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
            abi.fetches(26);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[2], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[4], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            rt.r[2] +%= rt.r[8];
            rt.r[7] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 8);
            rt.r[1] = abi.read32(0x080356E4);
            rt.r[3] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read16(rt.r[3] +% 0x4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[5]);
            rt.r[7] = abi.read16(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[1], rt.r[7] >> 8);
            rt.r[3] = abi.read16(rt.r[3] +% 0x6);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[5]);
            rt.r[2] = abi.read16(rt.r[2] +% 0x8);
            abi.setRegNz(&rt.r[2], rt.r[2] << 3);
            rt.r[3] = abi.read32(0x080356E8);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_080158E4, 0x080356C7)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[4], 16));
            rt.cpuSub(null, rt.r[0], rt.r[6], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_080356EC() callconv(.c) void {
    if (!abi.enter(0x080356EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[0] = abi.read32(0x0803574C);
            abi.setRegNz(&rt.r[1], 0x6);
            abi.write8(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            abi.write8(rt.r[0] +% 0x1, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[4], 0x1);
            rt.r[10] = rt.r[0];
            rt.r[0] = abi.read32(0x08035750);
            rt.r[9] = rt.r[0];
            abi.setRegNz(&rt.r[1], 0x68);
            rt.r[8] = rt.r[1];
            rt.r[5] = rt.r[10];
            rt.r[7] = abi.read32(0x08035754);
            rt.r[12] = rt.r[7];
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[1] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[4]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1B);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(16);
            rt.r[0] = abi.read8(rt.r[5] +% 0x1);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[5] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[5] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[5] +% 0x2, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[3], 0x0, true);
            rt.r[2] = abi.read32(0x08035758);
            rt.r[7] = rt.r[12];
            rt.r[0] = abi.read8(rt.r[7] +% 0x8);
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x080357C4);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(9);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x92);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080357C8, 0x080357B5)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[6] = abi.read8(rt.r[6] +% 0x1);
            rt.r[0] = abi.read8(rt.r[0] +% 0x5);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            abi.write8(rt.r[3] +% 0x1, @truncate(rt.r[0]));
            rt.r[2] = rt.r[10];
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[7], 0x0, true);
            rt.r[1] = rt.r[12];
            rt.r[0] = abi.read8(rt.r[1] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
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
            abi.fetches(14);
            rt.r[7] = rt.r[9];
            rt.r[1] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            continue :blk 11;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x92);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            continue :blk 11;
        },
        11 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[6] = abi.read8(rt.r[6] +% 0x2);
            rt.r[0] = abi.read8(rt.r[0] +% 0x4);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            abi.write8(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_080358C0() callconv(.c) void {
    if (!abi.enter(0x080358C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[7], rt.r[1] >> 16);
            rt.r[5] = abi.read32(0x0803592C);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read32(0x08035930);
            rt.r[4] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[3]));
            rt.cpuSub(&rt.r[3], rt.r[2], rt.r[0], true);
            rt.r[12] = rt.r[1];
            rt.cpuSub(null, rt.r[3], 0x1F, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0xC0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x20, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 1;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0xC0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[7] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[2], 0x6);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(&rt.r[2], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[2], 0x1F, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x20, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x70, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x70, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 8;
        },
        8 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[6] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[0], 16));
            rt.r[0] = abi.read32(0x0803592C);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], rt.r[2], true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        11 => {
            abi.fetches(4);
            rt.r[6] = abi.read16(rt.r[4] +% 0x4);
            continue :blk 15;
        },
        12 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        13 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[3], rt.r[5] << 16);
            continue :blk 15;
        },
        14 => {
            abi.fetches(8);
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0xF, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            abi.setRegNz(&rt.r[3], rt.r[5] << 16);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 15;
            }
            continue :blk 16;
        },
        15 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[3], 16));
            rt.r[0] = abi.read32(0x08035960);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 18;
            }
            continue :blk 17;
        },
        16 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[1] << 20);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 15;
        },
        17 => {
            abi.fetches(6);
            rt.r[3] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[5] = abi.read16(rt.r[0] +% 0x6);
            continue :blk 19;
        },
        18 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 21;
            }
            continue :blk 20;
        },
        19 => {
            abi.fetches(8);
            rt.r[3] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[6]));
            abi.write16(rt.r[0] +% 0x6, @truncate(rt.r[5]));
            if (!abi.call(decls.func_080212F4, 0x0803598B)) return;
            continue :blk 12;
        },
        20 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 19;
        },
        21 => {
            abi.fetches(9);
            rt.r[2] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[2] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(&rt.r[2], rt.r[2], 0xA, true);
            abi.setRegNz(&rt.r[0], rt.r[2] << 4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 19;
            }
            continue :blk 22;
        },
        22 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[2] << 20);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            continue :blk 19;
        },
        else => unreachable,
    }
}

fn func_08035990() callconv(.c) void {
    if (!abi.enter(0x08035990)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.r[2] = abi.read32(0x080359E0);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 5);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x18, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[4] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x16);
            rt.r[1] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            rt.r[0] = abi.read32(0x080359E4);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x6);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuSub(null, rt.r[0], 0xA8, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0xF0);
            if (!abi.call(decls.func_08013550, 0x080359DD)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[6], 0x14);
            rt.r[3] = rt.sext16(abi.read16(rt.r[4] +% rt.r[6]));
            abi.setRegNz(&rt.r[6], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[6]));
            rt.cpuSub(&rt.r[2], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0xF0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 1;
        },
        5 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08035A30);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(20);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read32(0x08035A38);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[3] = abi.read16(rt.r[4] +% 0x14);
            rt.r[5] = abi.read16(rt.r[2] +% 0x4);
            rt.cpuSub(&rt.r[1], rt.r[3], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[4] = abi.read16(rt.r[4] +% 0x16);
            rt.r[2] = abi.read16(rt.r[2] +% 0x6);
            rt.cpuSub(&rt.r[2], rt.r[4], rt.r[2], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x5, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            if (!abi.call(decls.func_08013550, 0x08035A2B)) return;
            continue :blk 5;
        },
        9 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08035A34);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x10, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            if (!abi.call(func_080358C0, 0x08035A07)) return;
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_08035B18() callconv(.c) void {
    if (!abi.enter(0x08035B18)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(23);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.r[13] -%= 0xC;
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[7], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[3], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.r[8] = rt.r[1];
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[0], 16));
            rt.r[2] = abi.read32(0x08035BC8);
            rt.r[9] = rt.r[2];
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuSub(&rt.r[0], rt.r[6], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0xEF, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.r[13] +%= 0xC;
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[7] << 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[2], 0x6);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.cpuSub(&rt.r[0], rt.r[5], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x9F, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08035BCC);
            rt.r[2] = abi.read32(0x08035BD0);
            abi.setRegNz(&rt.r[1], 0x2);
            abi.write32(rt.r[13] +% 0x0, rt.r[1]);
            abi.setRegNz(&rt.r[1], 0xFF);
            if (!abi.call(decls.func_080133C0, 0x08035B63)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(26);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            rt.r[1] = abi.read32(0x08035BD4);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 24));
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = rt.r[8];
            abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[7]));
            rt.r[2] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[2] = abi.read16(rt.r[0] +% 0x4);
            rt.cpuSub(&rt.r[1], rt.r[6], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[0] = abi.read16(rt.r[0] +% 0x6);
            rt.cpuSub(&rt.r[2], rt.r[5], rt.r[0], true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013550, 0x08035B93)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = rt.r[13] +% 0x4;
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_080135C8, 0x08035B9B)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(17);
            rt.r[1] = abi.read32(rt.r[13] +% 0x4);
            rt.r[2] = abi.read32(rt.r[13] +% 0x8);
            rt.r[0] = abi.read32(0x08035BD8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.setRegNz(&rt.r[3], 0xEC);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[3]);
            rt.r[3] = abi.read32(0x08035BDC);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 8);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08013598, 0x08035BB9)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08035C54() callconv(.c) void {
    if (!abi.enter(0x08035C54)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(decls.func_08035BE0, 0x08035C5D)) return;
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
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08035C3C, 0x08035C6D)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x2D);
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
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x43);
            continue :blk 5;
        },
        7 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08035CC4);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x16);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xF, true);
            continue :blk 9;
        },
        9 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 4));
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[2] = abi.read32(0x08035CC8);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x14);
            rt.r[2] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 11;
        },
        11 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read32(0x08035CCC);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0x12, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x08035CD0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08035D28 => continue :blk 16,
                0x08035C62 => { continue :blk 3; },
                0x08035D20 => continue :blk 14,
                0x08035D24 => continue :blk 15,
                0x08035D2C => continue :blk 13,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        13 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        14 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x4B);
            continue :blk 5;
        },
        15 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x47);
            continue :blk 5;
        },
        16 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x29);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_08036318() callconv(.c) void {
    if (!abi.enter(0x08036318)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x080363F0);
            rt.r[0] = abi.read32(0x080363F4);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x18, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[4] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080363F4);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            if (!abi.call(func_08035990, 0x08036361)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x2, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(14);
            rt.r[1] = abi.read32(0x080363FC);
            rt.r[0] = abi.read32(0x08036400);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0xE);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 8;
        },
        5 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080363F8);
            rt.r[2] = abi.read8(rt.r[4] +% 0x8);
            abi.setRegNz(&rt.r[1], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            if (!abi.call(decls.func_0807B44C, 0x08036357)) return;
            continue :blk 1;
        },
        6 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08036404);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x16);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        7 => {
            abi.fetches(9);
            rt.r[3] = abi.read32(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x14);
            rt.r[2] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035F80, 0x08036349)) return;
            continue :blk 5;
        },
        9 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xF, true);
            continue :blk 10;
        },
        10 => {
            abi.fetches(14);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 4));
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[2] = abi.read32(0x08036408);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x14);
            rt.r[2] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        11 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xF, true);
            continue :blk 12;
        },
        12 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 4));
            abi.setRegNz(&rt.r[2], 0x16);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x8, true);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        13 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 14;
        },
        14 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[2] = abi.read32(0x0803640C);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 17;
            }
            continue :blk 7;
        },
        15 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xF, true);
            continue :blk 16;
        },
        16 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 4));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            if (!abi.call(decls.func_08023BFC, 0x080363DD)) return;
            continue :blk 18;
        },
        17 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x080363F4);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_08013454, 0x080363EF)) return;
            continue :blk 19;
        },
        18 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 20;
            }
            continue :blk 17;
        },
        19 => {
            abi.fetches(3);
            continue :blk 21;
        },
        20 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08036424);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_08013454, 0x0803641D)) return;
            continue :blk 21;
        },
        21 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08037130() callconv(.c) void {
    if (!abi.enter(0x08037130)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[5], 0x0);
            abi.setRegNz(&rt.r[2], 0x1);
            abi.setRegNz(&rt.r[6], 0x40);
            rt.r[0] = abi.read32(0x080371A4);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[6]);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x10, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
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
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x1);
            abi.setRegNz(&rt.r[6], 0x40);
            rt.r[0] = abi.read32(0x080371A4);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 5;
        },
        5 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[6]);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x11, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[2], 0x3F, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        11 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080371A8);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 10;
        },
        else => unreachable,
    }
}

fn func_080380B0() callconv(.c) void {
    if (!abi.enter(0x080380B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            if (!abi.call(decls.func_08018290, 0x080380BB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(0x08038144);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[3], 0x1);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.r[7] = abi.read32(0x080381A0);
            abi.setRegNz(&rt.r[5], 0x3D);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[6], true);
            rt.r[8] = rt.r[5];
            rt.cpuAdd(&rt.r[4], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x30, true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x0, true);
            rt.r[7] = abi.read32(0x08038148);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(18);
            rt.r[0] = rt.r[8];
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[0], true);
            rt.r[5] = abi.read8(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[5] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[3], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(12);
            rt.r[1] = abi.read8(rt.r[6] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[2], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[3], 0x1);
            rt.r[12] = rt.r[6];
            rt.r[8] = rt.r[7];
            rt.cpuAdd(&rt.r[4], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x34, true);
            continue :blk 10;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[7], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1E);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 9;
            }
            continue :blk 11;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803809C, 0x080381A9)) return;
            continue :blk 12;
        },
        10 => {
            abi.fetches(36);
            rt.r[2] = rt.r[12];
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x42, true);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[2], true);
            rt.r[1] = rt.r[12];
            rt.r[1] = abi.read8(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.r[5] = rt.r[12];
            rt.r[5] = abi.read8(rt.r[5] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.r[1] = rt.r[8];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x38, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x33, true);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[1], true);
            rt.r[2] = rt.r[12];
            rt.r[2] = abi.read8(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[2] << 4);
            rt.r[5] = rt.r[12];
            rt.r[5] = abi.read8(rt.r[5] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(null, rt.r[3], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        11 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(decls.func_08018400, 0x0803819F)) return;
            continue :blk 15;
        },
        12 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        13 => {
            abi.fetches(16);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x3D, true);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[6] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x30, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 14;
        },
        14 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[3], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 10;
            }
            continue :blk 16;
        },
        15 => {
            abi.fetches(3);
            continue :blk 12;
        },
        16 => {
            abi.fetches(3);
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_080385CC() callconv(.c) void {
    if (!abi.enter(0x080385CC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x08038658);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            if (!abi.call(decls.func_0800F1B0, 0x080385D9)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_08038260, 0x080385DF)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0803826C, 0x080385E5)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(16);
            rt.r[0] = abi.read32(0x0803865C);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(0x08038660);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            rt.r[0] = abi.read32(0x08038664);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            rt.r[0] = abi.read32(0x08038668);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            rt.r[0] = abi.read32(0x0803866C);
            abi.write32(rt.r[0] +% 0x0, rt.r[4]);
            rt.r[0] = abi.read32(0x08038670);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            if (!abi.call(decls.func_080385BC, 0x08038601)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0801B820, 0x08038605)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08034C98, 0x08038609)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08034C74, 0x0803860D)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080149E0, 0x08038611)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080134D4, 0x08038615)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0800FD54, 0x08038619)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0800FC58, 0x0803861D)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0800FBC4, 0x08038621)) return;
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08018290, 0x08038625)) return;
            continue :blk 13;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080130A0, 0x08038629)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08036464, 0x0803862D)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0800F164, 0x08038631)) return;
            continue :blk 16;
        },
        16 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0801114C, 0x08038635)) return;
            continue :blk 17;
        },
        17 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0801CCF0, 0x08038639)) return;
            continue :blk 18;
        },
        18 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010A00, 0x0803863D)) return;
            continue :blk 19;
        },
        19 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010974, 0x08038641)) return;
            continue :blk 20;
        },
        20 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803D72C, 0x08038645)) return;
            continue :blk 21;
        },
        21 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x3);
            if (!abi.call(decls.func_0803D760, 0x0803864B)) return;
            continue :blk 22;
        },
        22 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08030708, 0x0803864F)) return;
            continue :blk 23;
        },
        23 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08042E24, 0x08038653)) return;
            continue :blk 24;
        },
        24 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080386E4() callconv(.c) void {
    if (!abi.enter(0x080386E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(37);
            pushRegs(&.{ 4, 14 });
            rt.r[13] -%= 0x10;
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write32(rt.r[13] +% 0x8, rt.r[2]);
            rt.r[1] = abi.read32(0x080387C0);
            rt.r[0] = rt.r[13] +% 0x8;
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0xC0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 18);
            abi.write32(rt.r[1] +% 0x4, rt.r[0]);
            rt.r[0] = abi.read32(0x080387C4);
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x8);
            rt.r[0] = rt.r[13] +% 0xC;
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 18);
            abi.write32(rt.r[1] +% 0x4, rt.r[0]);
            rt.r[0] = abi.read32(0x080387C8);
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(rt.r[1] +% 0x8);
            rt.r[1] = abi.read32(0x080387CC);
            rt.r[2] = abi.read32(0x080387D0);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[2] = rt.r[13] +% 0x4;
            rt.r[0] = abi.read32(0x080387D4);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            rt.r[3] = abi.read32(0x080387D8);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & ~rt.r[1]);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_0807AE14, 0x0803872B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080387DC);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 8);
            if (!abi.call(decls.func_08012CF0, 0x08038735)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080385C8, 0x08038741)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x080387E0);
            rt.r[1] = abi.read32(0x080387E4);
            rt.r[2] = abi.read32(0x080387E8);
            rt.r[3] = abi.read32(0x080387EC);
            abi.write32(rt.r[13] +% 0x0, rt.r[3]);
            abi.setRegNz(&rt.r[3], 0x2);
            if (!abi.call(decls.func_0801A768, 0x08038751)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08015FB4, 0x08038755)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803F87C, 0x08038759)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080387F0);
            if (!abi.call(decls.func_08010A78, 0x0803875F)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010968, 0x08038763)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010974, 0x08038767)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x080387F4);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0807AE50, 0x0803876F)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(30);
            rt.r[2] = abi.read32(0x080387F8);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x85, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xD0, true);
            abi.setRegNz(&rt.r[1], 0x3);
            abi.write8(rt.r[0] +% 0x1D, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x9C);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x8);
            abi.write8(rt.r[0] +% 0x1D, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[2], 0xD0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0x6);
            abi.write8(rt.r[0] +% 0x1D, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.r[13] +% 0x4;
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if (rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(8);
            rt.r[0] = rt.r[13] +% 0x4;
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x85);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 14;
        },
        13 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        14 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
            continue :blk 13;
        },
        15 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08038848, 0x080387BD)) return;
            continue :blk 17;
        },
        16 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080386B4, 0x08038801)) return;
            continue :blk 18;
        },
        17 => {
            abi.fetches(3);
            continue :blk 18;
        },
        18 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0803881C);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(decls.func_0807AE60, 0x08038809)) return;
            continue :blk 19;
        },
        19 => {
            abi.fetches(3);
            rt.r[4] = abi.read32(0x08038820);
            continue :blk 20;
        },
        20 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 22;
            }
            continue :blk 21;
        },
        21 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0807B44C, 0x08038815)) return;
            continue :blk 22;
        },
        22 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08038824, 0x08038819)) return;
            continue :blk 23;
        },
        23 => {
            abi.fetches(3);
            continue :blk 20;
        },
        else => unreachable,
    }
}

fn func_08038734() callconv(.c) void {
    if (!abi.enter(0x08038734)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080385C8, 0x08038741)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x080387E0);
            rt.r[1] = abi.read32(0x080387E4);
            rt.r[2] = abi.read32(0x080387E8);
            rt.r[3] = abi.read32(0x080387EC);
            abi.write32(rt.r[13] +% 0x0, rt.r[3]);
            abi.setRegNz(&rt.r[3], 0x2);
            if (!abi.call(decls.func_0801A768, 0x08038751)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08015FB4, 0x08038755)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803F87C, 0x08038759)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080387F0);
            if (!abi.call(decls.func_08010A78, 0x0803875F)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010968, 0x08038763)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010974, 0x08038767)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x080387F4);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0807AE50, 0x0803876F)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(30);
            rt.r[2] = abi.read32(0x080387F8);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x85, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xD0, true);
            abi.setRegNz(&rt.r[1], 0x3);
            abi.write8(rt.r[0] +% 0x1D, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x9C);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[1], 0x8);
            abi.write8(rt.r[0] +% 0x1D, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[2], 0xD0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[1], 0x6);
            abi.write8(rt.r[0] +% 0x1D, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.r[13] +% 0x4;
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(8);
            rt.r[0] = rt.r[13] +% 0x4;
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x85);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x1);
            continue :blk 11;
        },
        13 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08038848, 0x080387BD)) return;
            continue :blk 15;
        },
        14 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080386B4, 0x08038801)) return;
            continue :blk 16;
        },
        15 => {
            abi.fetches(3);
            continue :blk 16;
        },
        16 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0803881C);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(decls.func_0807AE60, 0x08038809)) return;
            continue :blk 17;
        },
        17 => {
            abi.fetches(3);
            rt.r[4] = abi.read32(0x08038820);
            continue :blk 18;
        },
        18 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 20;
            }
            continue :blk 19;
        },
        19 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0807B44C, 0x08038815)) return;
            continue :blk 20;
        },
        20 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08038824, 0x08038819)) return;
            continue :blk 21;
        },
        21 => {
            abi.fetches(3);
            continue :blk 18;
        },
        else => unreachable,
    }
}

fn func_08038C90() callconv(.c) void {
    if (!abi.enter(0x08038C90)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[5], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.r[8] = rt.r[3];
            rt.r[2] = abi.read32(0x08038CF4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[7], 0xFF);
            abi.setRegNz(&rt.r[7], rt.r[7] << 16);
            abi.setRegNz(&rt.r[7], rt.r[7] & rt.r[1]);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x08038CF8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796CC, 0x08038CC1)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(15);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 1);
            rt.r[3] +%= rt.r[8];
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 5);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[2], true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[7], 16));
            rt.r[2] = abi.read32(0x08038CFC);
            if (!abi.call(decls.func_0801B888, 0x08038CDB)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_080796C8, 0x08038CE3)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x8, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 1;
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

fn func_08038E10() callconv(.c) void {
    if (!abi.enter(0x08038E10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            if (!abi.call(decls.func_08024884, 0x08038E21)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[7], rt.r[0] >> 24);
            rt.r[0] = abi.read32(0x08038E9C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[5], 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[6], rt.r[6] << 16);
            rt.r[0] = abi.read32(0x08038EA0);
            rt.r[9] = rt.r[0];
            rt.r[0] = abi.read32(0x08038EA4);
            rt.r[8] = rt.r[0];
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[4] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[0] +%= rt.r[9];
            abi.setRegNz(&rt.r[1], rt.r[6] >> 16);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1E);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0803F014, 0x08038E37)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            if (!abi.call(decls.func_08038DB8, 0x08038E63)) return;
            continue :blk 9;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x31, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 10;
            }
            continue :blk 11;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 2;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 13;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 14;
        },
        11 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0xAF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 10;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 15;
        },
        13 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.r[1] +%= rt.r[8];
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[4]));
            continue :blk 7;
        },
        14 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x08038EA8);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x36, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.cpuSub(&rt.r[1], rt.r[5], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x37, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 15;
        },
        15 => {
            abi.fetches(8);
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_080391C8() callconv(.c) void {
    if (!abi.enter(0x080391C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x4;
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read32(0x08039288);
            if (!abi.call(decls.func_08012D8C, 0x080391DD)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080395A8, 0x080391E1)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(14);
            rt.r[4] = abi.read32(0x0803928C);
            rt.r[2] = abi.read32(rt.r[4] +% 0x0);
            rt.r[3] = abi.read32(0x08039290);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[1] +% 0x2);
            abi.write16(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            rt.cpuSub(null, rt.r[2], rt.r[1], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            if (!abi.call(decls.func_0801B850, 0x08039251)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            rt.r[10] = rt.r[3];
            continue :blk 6;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[13] +% 0x0);
            if (!abi.call(decls.func_0801B860, 0x08039257)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[1] = rt.r[10];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[6], rt.r[2], 0x1, true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(18);
            rt.r[2] = abi.read32(0x0803929C);
            rt.r[0] = abi.read32(0x0803928C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 2);
            rt.cpuSub(&rt.r[1], rt.r[1], 0xF0, true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 1));
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.r[2] = abi.read32(0x080392A0);
            rt.r[3] = abi.read16(rt.r[0] +% 0x2);
            abi.setRegNz(&rt.r[1], rt.r[3] << 2);
            rt.cpuSub(&rt.r[1], rt.r[1], 0xA0, true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 1));
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(decls.func_08012E14, 0x08039277)) return;
            continue :blk 10;
        },
        8 => {
            abi.fetches(10);
            rt.r[3] = abi.read32(0x0803928C);
            rt.r[9] = rt.r[3];
            rt.r[0] = abi.read32(0x08039290);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[5], rt.r[2] << 1);
            rt.r[1] = abi.read32(0x08039294);
            rt.r[12] = rt.r[1];
            rt.r[7] = abi.read32(0x08039298);
            continue :blk 11;
        },
        9 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            rt.r[3] = rt.r[10];
            rt.r[0] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 3;
        },
        10 => {
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
        11 => {
            abi.fetches(21);
            rt.r[3] = rt.r[9];
            rt.r[2] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = rt.r[8];
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[7], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[2] +% 0x4, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[3], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_08039484() callconv(.c) void {
    if (!abi.enter(0x08039484)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x24;
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = abi.read32(0x08039588);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[3] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[3], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            rt.r[13] +%= 0x24;
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(3);
            abi.write32(rt.r[13] +% 0x8, rt.r[0]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x1, true);
            abi.write32(rt.r[13] +% 0xC, rt.r[4]);
            rt.r[7] = abi.read32(rt.r[13] +% 0x8);
            rt.r[7] = abi.read16(rt.r[7] +% 0x0);
            rt.cpuSub(null, rt.r[6], rt.r[7], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(26);
            rt.r[0] = abi.read32(0x08039588);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[13] +% 0x20, rt.r[0]);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.r[8] = rt.r[1];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x12, true);
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            rt.r[1] = abi.read32(0x0803958C);
            rt.r[12] = rt.r[1];
            rt.r[2] = abi.read32(0x08039590);
            abi.write32(rt.r[13] +% 0x10, rt.r[2]);
            rt.r[3] = abi.read32(0x08039594);
            abi.write32(rt.r[13] +% 0x14, rt.r[3]);
            rt.r[4] = abi.read32(0x08039598);
            abi.write32(rt.r[13] +% 0x18, rt.r[4]);
            rt.r[7] = abi.read32(0x0803959C);
            abi.write32(rt.r[13] +% 0x1C, rt.r[7]);
            rt.r[0] = abi.read32(0x080395A0);
            rt.r[10] = rt.r[0];
            rt.r[1] = abi.read32(rt.r[13] +% 0x20);
            rt.r[2] = abi.read32(0x080395A4);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.r[0] +%= rt.r[8];
            rt.r[9] = rt.r[0];
            continue :blk 6;
        },
        5 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(rt.r[13] +% 0xC);
            rt.r[4] = abi.read32(0x08039588);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(10);
            rt.r[3] = rt.r[9];
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[6], true);
            rt.r[4] = abi.read32(rt.r[13] +% 0x4);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(59);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[7] = abi.read32(rt.r[13] +% 0x10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x12, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(rt.r[13] +% 0x14);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[5], rt.r[0] << 1);
            rt.r[2] = abi.read32(rt.r[13] +% 0x18);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[2], true);
            abi.setRegNz(&rt.r[0], rt.r[6] << 1);
            rt.r[3] = abi.read32(rt.r[13] +% 0x1C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[4] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[0], true);
            rt.r[1] = rt.r[8];
            rt.r[1] +%= rt.r[10];
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[7] = rt.r[12];
            rt.r[1] = abi.read16(rt.r[7] +% 0x0);
            rt.r[7] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[7]);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[3] = rt.r[12];
            rt.r[2] = abi.read16(rt.r[3] +% 0x2);
            rt.r[3] = abi.read16(rt.r[0] +% 0x4);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[3]);
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[2]));
            rt.r[4] = rt.r[12];
            rt.r[3] = abi.read16(rt.r[4] +% 0x4);
            rt.r[4] = abi.read16(rt.r[0] +% 0x8);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[4]);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[3]));
            rt.r[7] = rt.r[12];
            rt.r[4] = abi.read16(rt.r[7] +% 0x6);
            rt.r[7] = abi.read16(rt.r[0] +% 0xC);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[7]);
            abi.write16(rt.r[0] +% 0xC, @truncate(rt.r[4]));
            rt.r[7] = abi.read16(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[7]);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read16(rt.r[5] +% 0x4);
            abi.setRegNz(&rt.r[2], rt.r[2] | rt.r[1]);
            abi.write16(rt.r[0] +% 0x4, @truncate(rt.r[2]));
            rt.r[2] = abi.read16(rt.r[5] +% 0x8);
            abi.setRegNz(&rt.r[3], rt.r[3] | rt.r[2]);
            abi.write16(rt.r[0] +% 0x8, @truncate(rt.r[3]));
            rt.r[5] = abi.read16(rt.r[5] +% 0xC);
            abi.setRegNz(&rt.r[4], rt.r[4] | rt.r[5]);
            abi.write16(rt.r[0] +% 0xC, @truncate(rt.r[4]));
            continue :blk 8;
        },
        8 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x1, true);
            rt.r[3] = abi.read32(rt.r[13] +% 0x20);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[6], rt.r[3], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_080395B4() callconv(.c) void {
    if (!abi.enter(0x080395B4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[5] = abi.read32(0x08039658);
            rt.r[4] = abi.read32(0x0803965C);
            abi.setRegNz(&rt.r[2], 0xBA);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            rt.r[1] = abi.read32(0x08039660);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[3], rt.r[1], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[0] +% 0x2);
            rt.r[4] = abi.read8(rt.r[0] +% 0x2);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x20, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[2], 0x20);
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x20, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x20);
            continue :blk 6;
        },
        6 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 1));
            rt.cpuSub(null, rt.r[3], rt.r[1], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[8] = rt.r[4];
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[4], 1));
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.r[10] = rt.r[0];
            rt.r[9] = rt.r[1];
            continue :blk 9;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08011814, 0x0803964B)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[2], rt.r[10], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        11 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x0803965C);
            rt.r[12] = rt.r[0];
            rt.r[1] = abi.read32(0x08039664);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            rt.r[1] = rt.r[8];
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[1], 1));
            abi.setRegNz(&rt.r[4], rt.r[0] << 4);
            continue :blk 13;
        },
        12 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[3], rt.r[9], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        13 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[0], rt.r[2] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[0] +%= rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[7], true);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[2], rt.r[4], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        else => unreachable,
    }
}

fn func_08039668() callconv(.c) void {
    if (!abi.enter(0x08039668)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[3] = abi.read32(0x080396C8);
            abi.write8(rt.r[3] +% 0x1, @truncate(rt.r[5]));
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[5]));
            abi.write8(rt.r[3] +% 0x2, @truncate(rt.r[5]));
            abi.write8(rt.r[3] +% 0x3, @truncate(rt.r[5]));
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(0x080396CC);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[4] = abi.read16(rt.r[2] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[4], true);
            if (rt.CPU_C) {
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
            abi.fetches(5);
            rt.r[8] = rt.r[0];
            rt.r[9] = rt.r[2];
            rt.r[10] = rt.r[8];
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x1, true);
            rt.r[0] = rt.r[9];
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (rt.CPU_C) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x080396CC);
            rt.r[6] = abi.read32(rt.r[1] +% 0x0);
            rt.r[2] = abi.read32(0x080396D0);
            rt.r[4] = abi.read32(rt.r[2] +% 0x0);
            rt.r[2] = abi.read32(0x080396C8);
            rt.r[12] = rt.r[10];
            continue :blk 6;
        },
        5 => {
            abi.fetches(13);
            rt.r[2] = rt.r[8];
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[4] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[5], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[7] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[1], 0x1F);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0xA, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0xA, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[2] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            continue :blk 11;
        },
        9 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x6, true);
            if (rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0xB, true);
            if (rt.CPU_Z) {
                continue :blk 15;
            }
            continue :blk 14;
        },
        11 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.r[1] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        12 => {
            abi.fetches(3);
            continue :blk 11;
        },
        13 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 11;
        },
        14 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0xE, true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 16;
        },
        15 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[2] +% 0x3, @truncate(rt.r[0]));
            continue :blk 11;
        },
        16 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
            continue :blk 11;
        },
        else => unreachable,
    }
}

fn func_08039814() callconv(.c) void {
    if (!abi.enter(0x08039814)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x08039838);
            if (!abi.call(decls.func_08010D00, 0x0803981D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010A00, 0x08039821)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010974, 0x08039825)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803983C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080398C0);
            rt.r[1] = abi.read32(0x080398C4);
            abi.setRegNz(&rt.r[4], 0x80);
            abi.setRegNz(&rt.r[4], rt.r[4] << 4);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0800FDA4, 0x0803987D)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x08039840);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08039858 => continue :blk 7,
                0x08039860 => continue :blk 8,
                0x08039868 => continue :blk 9,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        6 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080398C8);
            rt.r[1] = abi.read32(0x080398CC);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0800FDA4, 0x08039887)) return;
            continue :blk 10;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_080126CC, 0x0803985F)) return;
            continue :blk 11;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0801272C, 0x08039867)) return;
            continue :blk 12;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0801272C, 0x0803986F)) return;
            continue :blk 4;
        },
        10 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080398D0);
            rt.r[1] = abi.read32(0x080398D4);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0800FDA4, 0x08039891)) return;
            continue :blk 13;
        },
        11 => {
            abi.fetches(3);
            continue :blk 4;
        },
        12 => {
            abi.fetches(3);
            continue :blk 4;
        },
        13 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080398D8);
            rt.r[1] = abi.read32(0x080398DC);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0800FDA4, 0x0803989B)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x080398E0);
            rt.r[1] = abi.read32(0x080398E4);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 2);
            if (!abi.call(decls.func_0800FDA4, 0x080398A7)) return;
            continue :blk 15;
        },
        15 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x080398E8);
            abi.setRegNz(&rt.r[1], 0x20);
            abi.setRegNz(&rt.r[2], 0x20);
            if (!abi.call(decls.func_08011330, 0x080398B1)) return;
            continue :blk 16;
        },
        16 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080204B4, 0x080398B5)) return;
            continue :blk 17;
        },
        17 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_080199A0, 0x080398BB)) return;
            continue :blk 18;
        },
        18 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08039CC4() callconv(.c) void {
    if (!abi.enter(0x08039CC4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[13] -%= 0x8;
            rt.r[1] = abi.read32(0x08039CE8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.fetches(5);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1);
            rt.cpuSub(null, rt.r[1], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[13] +%= 0x8;
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803A664, 0x08039CDF)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[5] = abi.read32(0x08039D34);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x68);
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1B);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(3);
            continue :blk 11;
        },
        9 => {
            abi.fetches(8);
            rt.r[6] = rt.r[13];
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[3], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            continue :blk 10;
        },
        10 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        12 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(12);
            rt.r[1] = rt.r[13];
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 11;
        },
        else => unreachable,
    }
}

fn func_08039F5C() callconv(.c) void {
    if (!abi.enter(0x08039F5C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            if (!abi.call(decls.func_0803A664, 0x08039F65)) return;
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
            if (!abi.call(decls.func_0803A664, 0x08039F7F)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08039FA4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x2);
            rt.r[1] = abi.read32(0x08039FA8);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x96, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            if (!abi.call(decls.func_080169B8, 0x08039F7B)) return;
            continue :blk 2;
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
            rt.r[0] = abi.read32(0x08039FAC);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08039FE4);
            rt.r[1] = abi.read32(0x08039FE8);
            rt.r[1] = abi.read8(rt.r[1] +% 0x2);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x74, true);
            abi.write8(rt.r[0] +% 0x1F, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            continue :blk 8;
        },
        7 => {
            abi.fetches(7);
            rt.r[3] = abi.read32(0x08039FA4);
            rt.r[1] = abi.read8(rt.r[3] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x80, true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1F);
            rt.cpuSub(null, rt.r[0], 0xC, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        9 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write8(rt.r[2] +% 0x1D, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[4], 0x1);
            abi.setRegNz(&rt.r[0], 0xD);
            abi.write8(rt.r[2] +% 0x1F, @truncate(rt.r[0]));
            continue :blk 8;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x80, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 8;
            }
            continue :blk 13;
        },
        11 => {
            abi.fetches(3);
            abi.write8(rt.r[2] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08034B50, 0x08039FD9)) return;
            continue :blk 14;
        },
        13 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x73, true);
            abi.write8(rt.r[2] +% 0x1F, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.write8(rt.r[3] +% 0x2, @truncate(rt.r[0]));
            continue :blk 8;
        },
        14 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        15 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803DB00, 0x08039FE1)) return;
            continue :blk 17;
        },
        16 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803A004);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            if (!abi.call(decls.func_08015E3C, 0x08039FF5)) return;
            continue :blk 18;
        },
        17 => {
            abi.fetches(3);
            continue :blk 19;
        },
        18 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.r[1] = abi.read32(0x0803A008);
            if (!abi.call(decls.func_0803FB84, 0x08039FFF)) return;
            continue :blk 19;
        },
        19 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0803A00C() callconv(.c) void {
    if (!abi.enter(0x0803A00C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[7], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
            rt.r[12] = rt.r[2];
            rt.r[6] = abi.read32(0x0803A098);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = abi.read32(rt.r[6] +% 0x24);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 20);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[6] +% 0x24);
            rt.r[1] = abi.read32(0x0803A09C);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write32(rt.r[6] +% 0x24, rt.r[0]);
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[5], 0x20, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], 0x20, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(32);
            abi.setRegNz(&rt.r[2], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.r[1] = abi.read32(0x0803A0A0);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[7]);
            abi.setRegNz(&rt.r[1], rt.r[1] << 8);
            rt.r[0] = abi.read32(rt.r[2] +% 0x24);
            rt.r[3] = abi.read32(0x0803A09C);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write32(rt.r[2] +% 0x24, rt.r[0]);
            rt.r[0] = rt.r[12];
            abi.setRegNz(&rt.r[1], rt.r[0] << 4);
            abi.setRegNz(&rt.r[0], 0xF);
            rt.r[7] = abi.read16(rt.r[2] +% 0x26);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[7]);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write16(rt.r[2] +% 0x26, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[6], true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            rt.r[0] = abi.read32(rt.r[1] +% 0x24);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write32(rt.r[1] +% 0x24, rt.r[0]);
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x24);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 20);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803A140() callconv(.c) void {
    if (!abi.enter(0x0803A140)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[8] = rt.r[0];
            if (!abi.call(decls.func_0803A664, 0x0803A14F)) return;
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
            if (!abi.call(decls.func_08018E2C, 0x0803A1F1)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(18);
            rt.r[4] = abi.read32(0x0803A1D0);
            rt.r[0] = abi.read8(rt.r[4] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x82, true);
            rt.r[5] = abi.read32(0x0803A1D4);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x85, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x96, true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.r[6] = abi.read32(0x0803A1D8);
            rt.cpuAdd(&rt.r[7], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[7], 0x21, true);
            rt.r[3] = abi.read8(rt.r[7] +% 0x0);
            if (!abi.call(decls.func_08015AFC, 0x0803A175)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08034B50, 0x0803A1F5)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(13);
            rt.r[0] = abi.read8(rt.r[4] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x7E, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x0803A1DC);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x9A, true);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            if (!abi.call(func_0803A00C, 0x0803A18B)) return;
            continue :blk 7;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = rt.r[8];
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08018D5C, 0x0803A18F)) return;
            continue :blk 10;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803DB28, 0x0803A1FF)) return;
            continue :blk 11;
        },
        9 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803A21C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            if (!abi.call(decls.func_08015E3C, 0x0803A209)) return;
            continue :blk 12;
        },
        10 => {
            abi.fetches(10);
            rt.r[0] = abi.read8(rt.r[4] +% 0x2);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x7E, true);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x20, true);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            if (!abi.call(decls.func_0803A0A4, 0x0803A19F)) return;
            continue :blk 13;
        },
        11 => {
            abi.fetches(3);
            continue :blk 14;
        },
        12 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.r[1] = abi.read32(0x0803A220);
            if (!abi.call(decls.func_0803FB84, 0x0803A213)) return;
            continue :blk 14;
        },
        13 => {
            abi.fetches(5);
            rt.r[4] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[4], 0x22, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 15;
        },
        14 => {
            abi.fetches(7);
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        15 => {
            abi.fetches(4);
            if (!abi.call(func_080229A8, 0x0803A1A9)) return;
            continue :blk 16;
        },
        16 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[8] = rt.r[0];
            if (!abi.call(decls.func_0803A0E8, 0x0803A1B1)) return;
            continue :blk 17;
        },
        17 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read8(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xAC, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 19;
            }
            continue :blk 18;
        },
        18 => {
            abi.fetches(3);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            continue :blk 19;
        },
        19 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[7] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 21;
            }
            continue :blk 20;
        },
        20 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write8(rt.r[6] +% 0x1D, @truncate(rt.r[0]));
            continue :blk 4;
        },
        21 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[6] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 22;
        },
        22 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write8(rt.r[6] +% 0x1D, @truncate(rt.r[0]));
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803A38C() callconv(.c) void {
    if (!abi.enter(0x0803A38C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x8;
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[9] = rt.r[0];
            rt.r[0] = abi.read32(0x0803A428);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            abi.setRegNz(&rt.r[2], 0xBA);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            if (!abi.call(decls.func_08010BF8, 0x0803A3AB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0803A42C);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_080117EC, 0x0803A46D)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(17);
            rt.r[1] = abi.read32(0x0803A430);
            rt.r[2] = rt.r[9];
            abi.setRegNz(&rt.r[0], rt.r[2] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[5], rt.r[0] << 2);
            rt.r[1] = abi.read8(rt.r[1] +% 0x9);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[5], true);
            rt.r[1] = abi.read32(0x0803A42C);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[8] = rt.r[1];
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
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
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[8] = rt.r[2];
            continue :blk 6;
        },
        6 => {
            abi.fetches(23);
            rt.r[1] = rt.r[9];
            abi.setRegNz(&rt.r[0], rt.r[1] << 17);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 10);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[0], 16));
            rt.r[0] = abi.read32(0x0803A428);
            rt.r[10] = rt.r[0];
            rt.r[1] = abi.read32(0x0803A42C);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[7], 0x80);
            abi.setRegNz(&rt.r[7], rt.r[7] << 8);
            abi.write32(rt.r[13] +% 0x0, rt.r[7]);
            rt.r[2] = rt.r[8];
            abi.write32(rt.r[13] +% 0x4, rt.r[2]);
            abi.setRegNz(&rt.r[0], 0x8);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.r[2] = rt.r[10];
            if (!abi.call(decls.func_08012A68, 0x0803A3FF)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = rt.r[9];
            if (!abi.call(decls.func_0803A318, 0x0803A405)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(0x0803A434);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[1], true);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[13] +% 0x0, rt.r[7]);
            rt.r[2] = rt.r[8];
            abi.write32(rt.r[13] +% 0x4, rt.r[2]);
            abi.setRegNz(&rt.r[0], 0x10);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.r[2] = rt.r[10];
            if (!abi.call(decls.func_08012A68, 0x0803A427)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(11);
            abi.write32(rt.r[13] +% 0x0, rt.r[7]);
            rt.r[0] = rt.r[8];
            abi.write32(rt.r[13] +% 0x4, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x14);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.r[2] = rt.r[10];
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08012B04, 0x0803A44B)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(3);
            continue :blk 12;
        },
        12 => {
            abi.fetches(16);
            rt.r[0] = rt.r[9];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[9] = rt.r[0];
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.r[1] = rt.r[9];
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[2] = abi.read32(0x0803A47C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0803A6C8() callconv(.c) void {
    if (!abi.enter(0x0803A6C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x4;
            rt.r[2] = abi.read32(0x0803A770);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x42, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[1] = rt.sext8(abi.read8(rt.r[3] +% rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(23);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
            rt.r[3] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[1] = rt.sext8(abi.read8(rt.r[0] +% rt.r[1]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0xC, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x41, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[3], 0x1);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            rt.r[8] = rt.r[2];
            rt.r[1] = abi.read32(0x0803A774);
            rt.r[12] = rt.r[1];
            rt.r[2] = abi.read32(0x0803A778);
            rt.r[10] = rt.r[2];
            rt.r[7] = abi.read32(0x0803A77C);
            rt.r[9] = rt.r[7];
            continue :blk 5;
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
        5 => {
            abi.fetches(32);
            rt.r[0] = rt.r[8];
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[3] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[4], 24));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x36, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[6], rt.r[1], rt.r[0], true);
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], rt.r[0] << 2);
            rt.r[7] = abi.read32(0x0803A780);
            rt.r[7] = abi.read8(rt.r[7] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[7] >> 6);
            rt.r[0] = abi.read32(0x0803A784);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x68, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1E);
            abi.setRegNz(&rt.r[0], rt.r[2] << 7);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[7] = rt.r[12];
            rt.r[0] = abi.read8(rt.r[7] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(10);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x92);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(62);
            rt.r[2] = abi.read32(0x0803A818);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            rt.r[5] = abi.read32(rt.r[0] +% 0x0);
            rt.r[7] = abi.read32(0x0803A81C);
            rt.r[3] = abi.read32(rt.r[7] +% 0x0);
            rt.r[0] = rt.r[8];
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 24));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2B, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[7] = abi.read32(0x0803A820);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[7], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x20, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[4], true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[0] = rt.sext8(abi.read8(rt.r[2] +% rt.r[0]));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read32(0x0803A824);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[2], 0x1F);
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[3]);
            rt.r[3] = rt.r[10];
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            rt.r[7] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[7] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.r[0] +%= rt.r[9];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x60, true);
            rt.r[3] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[5], rt.r[5], rt.r[2], true);
            rt.r[6] = abi.read8(rt.r[6] +% 0x0);
            rt.r[5] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[6], rt.r[5], true);
            rt.r[7] = abi.read32(rt.r[13] +% 0x0);
            abi.write8(rt.r[7] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            rt.r[1] = rt.r[8];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            abi.setRegNz(&rt.r[3], rt.r[4] >> 24);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803A828() callconv(.c) void {
    if (!abi.enter(0x0803A828)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(67);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 24);
            rt.r[2] = abi.read32(0x0803A8BC);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2B, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x36, true);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[0], true);
            rt.r[8] = rt.r[2];
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[12] = rt.r[1];
            rt.r[7] = abi.read32(0x0803A8C0);
            rt.r[3] = abi.read32(0x0803A8C4);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[4], rt.r[0] << 2);
            rt.r[0] = abi.read32(0x0803A8C8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 6);
            rt.r[0] = abi.read32(0x0803A8CC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x68, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1E);
            abi.setRegNz(&rt.r[0], rt.r[2] << 7);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[3] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[3], 0x92);
            abi.setRegNz(&rt.r[3], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[3], true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[0], true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(49);
            rt.cpuAdd(&rt.r[0], rt.r[7], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x34, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0803A934);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[5] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 23));
            rt.r[5] = abi.read32(0x0803A938);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[6] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read32(0x0803A93C);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[3], 0x1F);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[3], rt.r[3] & rt.r[2]);
            rt.r[2] = abi.read32(0x0803A940);
            rt.r[0] = abi.read32(0x0803A944);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[5] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[5] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x60, true);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[2] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[3], true);
            rt.r[3] = rt.r[12];
            rt.r[3] = abi.read8(rt.r[3] +% 0x0);
            rt.r[4] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[3], rt.r[4], true);
            rt.r[5] = rt.r[8];
            abi.write8(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 3 });
            rt.r[8] = rt.r[3];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0803A9B8() callconv(.c) void {
    if (!abi.enter(0x0803A9B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(16);
            rt.r[2] = abi.read32(0x0803A9E4);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 24);
            abi.setRegNz(&rt.r[3], 0x80);
            abi.setRegNz(&rt.r[3], rt.r[3] << 17);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.cpuSub(null, rt.r[0], 0xA, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x0803A9E8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x0803AAB0 => continue :blk 7,
                0x0803AA18 => continue :blk 3,
                0x0803AA34 => continue :blk 4,
                0x0803AA84 => continue :blk 6,
                0x0803AA60 => continue :blk 5,
                0x0803A9BC => continue :blk 1,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        3 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x0803AA30);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[2] = rt.sext8(abi.read8(rt.r[0] +% rt.r[2]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x22, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            continue :blk 8;
        },
        4 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x0803AA5C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[2] = rt.sext8(abi.read8(rt.r[0] +% rt.r[2]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x22, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            continue :blk 8;
        },
        5 => {
            abi.fetches(18);
            rt.r[0] = abi.read32(0x0803AA80);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[2] = rt.sext8(abi.read8(rt.r[0] +% rt.r[2]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x22, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2B, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            continue :blk 9;
        },
        6 => {
            abi.fetches(17);
            rt.r[0] = abi.read32(0x0803AAAC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[2] = rt.sext8(abi.read8(rt.r[0] +% rt.r[2]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x22, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2B, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            continue :blk 9;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2B, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            if (!abi.call(func_0803A828, 0x0803AA5B)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            if (!abi.call(func_0803A828, 0x0803AAAB)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(3);
            continue :blk 1;
        },
        11 => {
            abi.fetches(3);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803AAB8() callconv(.c) void {
    if (!abi.enter(0x0803AAB8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            abi.setRegNz(&rt.r[6], 0x1);
            rt.r[2] = abi.read32(0x0803AAFC);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[7], rt.r[2], 0x0, true);
            rt.r[1] = abi.read32(0x0803AB00);
            rt.r[12] = rt.r[1];
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[0], rt.r[6] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[0] +%= rt.r[12];
            abi.setRegNz(&rt.r[1], 0x4);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(3);
            rt.r[5] = rt.r[12];
            continue :blk 3;
        },
        3 => {
            abi.fetches(18);
            rt.r[4] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[6] << 24);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[3], true);
            rt.cpuSub(&rt.r[2], rt.r[3], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[5], true);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(15);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[6] << 24);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 17);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[7], 0x0, true);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x42, true);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[5], true);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 6;
        },
        8 => {
            abi.fetches(14);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2B, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[5], true);
            abi.setRegNz(&rt.r[0], 0x3);
            continue :blk 6;
        },
        10 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[5], true);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0803ABE0() callconv(.c) void {
    if (!abi.enter(0x0803ABE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[0] = abi.read32(0x0803ABEC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[1] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[2], rt.r[3] << 24);
            abi.setRegNz(&rt.r[7], rt.r[1] << 24);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 6;
        },
        4 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0803AC30);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[4], true);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[6] = rt.sext8(abi.read8(rt.r[0] +% rt.r[6]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2B, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], rt.r[4], true);
            continue :blk 7;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[1], true);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            continue :blk 1;
        },
        6 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        7 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 24));
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.r[2] = abi.read8(rt.r[4] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[3] << 24);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[2], rt.r[3] << 24);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 5;
        },
        10 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0803B1DC() callconv(.c) void {
    if (!abi.enter(0x0803B1DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x0803B278);
            rt.r[2] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x36, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
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
            abi.fetches(20);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2B, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            abi.setRegNz(&rt.r[2], 0x8);
            abi.setRegNz(&rt.r[3], 0x8);
            if (!abi.call(decls.func_0803B194, 0x0803B21F)) return;
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
            abi.fetches(40);
            rt.r[4] = abi.read32(rt.r[4] +% 0x0);
            rt.r[12] = rt.r[4];
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[0], rt.r[0] << 4);
            rt.r[1] = abi.read32(0x0803B27C);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read16(rt.r[2] +% 0x4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4, true);
            rt.r[3] = abi.read32(0x0803B280);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2B, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 24));
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.r[2] = abi.read16(rt.r[2] +% 0x6);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = rt.r[12];
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x42, true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[3] = rt.sext8(abi.read8(rt.r[2] +% rt.r[3]));
            rt.cpuSub(&rt.r[2], rt.r[2], 0xC, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[3], true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 24));
            if (!abi.call(decls.func_0802C11C, 0x0803B271)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803B284() callconv(.c) void {
    if (!abi.enter(0x0803B284)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.r[0] = abi.read32(0x0803B33C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x42, true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[0] = rt.sext8(abi.read8(rt.r[5] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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
            abi.fetches(6);
            rt.r[5] = abi.read8(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[5], rt.r[5] << 24);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0803B340);
            rt.r[9] = rt.r[0];
            continue :blk 4;
        },
        4 => {
            abi.fetches(22);
            rt.r[0] = abi.read32(0x0803B33C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[7], rt.asrConst(rt.r[5], 24));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[2] = rt.sext8(abi.read8(rt.r[0] +% rt.r[2]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2B, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[7], true);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.r[0] = rt.sext8(abi.read8(rt.r[1] +% rt.r[0]));
            abi.setRegNz(&rt.r[4], rt.r[2] << 4);
            abi.setRegNz(&rt.r[6], rt.r[0] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x10);
            abi.setRegNz(&rt.r[3], 0x10);
            if (!abi.call(decls.func_0803B194, 0x0803B2D1)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(20);
            rt.r[0] = abi.read32(0x0803B344);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read16(rt.r[1] +% 0x4);
            rt.cpuSub(&rt.r[2], rt.r[4], rt.r[2], true);
            rt.r[8] = rt.r[2];
            rt.r[2] = abi.read32(0x0803B348);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.r[2] = rt.r[8];
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            rt.r[8] = rt.r[2];
            rt.r[1] = abi.read16(rt.r[1] +% 0x6);
            rt.cpuSub(&rt.r[6], rt.r[6], rt.r[1], true);
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.setRegNz(&rt.r[6], rt.r[6] & rt.r[0]);
            abi.setRegNz(&rt.r[5], rt.r[5] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0803B124, 0x0803B2FB)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[7], 0x1, true);
            abi.setRegNz(&rt.r[5], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        8 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0803B0C0, 0x0803B303)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(21);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 23);
            abi.setRegNz(&rt.r[4], rt.r[4] << 24);
            abi.setRegNz(&rt.r[4], rt.r[4] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[4] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] +%= rt.r[9];
            abi.setRegNz(&rt.r[2], 0xC0);
            abi.setRegNz(&rt.r[2], rt.r[2] << 6);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.r[3] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], rt.r[3] | rt.r[1]);
            rt.r[0] = rt.r[8];
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.r[2] = abi.read32(0x0803B34C);
            if (!abi.call(decls.func_0801B888, 0x0803B329)) return;
            continue :blk 7;
        },
        else => unreachable,
    }
}

fn func_0803B690() callconv(.c) void {
    if (!abi.enter(0x0803B690)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            rt.r[9] = rt.r[0];
            abi.setRegNz(&rt.r[0], 0xC0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 6);
            if (!abi.call(decls.func_08012D8C, 0x0803B6A3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[8] = rt.r[0];
            rt.r[0] = abi.read32(0x0803B6F8);
            rt.r[1] = rt.r[8];
            if (!abi.call(decls.func_0800FE24, 0x0803B6AD)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = rt.r[9];
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = rt.r[8];
            if (!abi.call(decls.func_08012E14, 0x0803B72F)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            rt.r[2] = rt.r[9];
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x1, true);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x20, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(8);
            popRegsSeq(&.{ 3, 4 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = abi.read32(0x0803B6FC);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[6], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[7] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.r[2] = rt.r[9];
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[6] << 8);
            rt.r[6] = abi.read32(0x0803B700);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[6], true);
            continue :blk 10;
        },
        9 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 16);
            continue :blk 7;
        },
        10 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[3], true);
            rt.r[6] = abi.read8(rt.r[4] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[6], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[2] << 8);
            rt.r[0] +%= rt.r[8];
            rt.r[2] = abi.read32(0x0803B704);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 1);
            if (!abi.call(decls.func_0800FDA4, 0x0803B6F5)) return;
            continue :blk 13;
        },
        12 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        13 => {
            abi.fetches(3);
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_0803BB30() callconv(.c) void {
    if (!abi.enter(0x0803BB30)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[1] = abi.read32(0x0803BBA4);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.write16(rt.r[0] +% 0x1C, @truncate(rt.r[1]));
            rt.r[2] = abi.read32(0x0803BBA8);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1);
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
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0803BBAC);
            rt.r[0] = abi.read8(rt.r[2] +% 0x2);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x82, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[4] = abi.read32(0x0803BC00);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            if (!abi.call(decls.func_0801C108, 0x0803BBCD)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[0] = rt.sext8(abi.read8(rt.r[4] +% rt.r[0]));
            abi.setRegNz(&rt.r[1], 0x1);
            rt.cpuSub(&rt.r[1], 0, rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            rt.r[5] = abi.read32(0x0803BBB0);
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            continue :blk 9;
        },
        8 => {
            abi.fetches(21);
            rt.r[2] = abi.read32(0x0803BC04);
            rt.r[0] = abi.read32(0x0803BC08);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[4] = abi.read16(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[4]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[0] +% 0x1D);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x8);
            if (!abi.call(decls.func_0803BB0C, 0x0803BBFB)) return;
            continue :blk 1;
        },
        9 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[2] = rt.sext8(abi.read8(rt.r[4] +% rt.r[2]));
            rt.r[3] = abi.read16(rt.r[5] +% 0x0);
            rt.r[0] = abi.read32(0x0803BBB4);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[3] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(decls.func_0801C108, 0x0803BB83)) return;
            continue :blk 12;
        },
        11 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x8, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[0] = rt.sext8(abi.read8(rt.r[4] +% rt.r[0]));
            rt.cpuSub(null, rt.r[0], rt.r[6], true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 13;
        },
        12 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read8(rt.r[4] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 14;
        },
        13 => {
            abi.fetches(3);
            continue :blk 1;
        },
        14 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        15 => {
            abi.fetches(6);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.r[1] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 16;
        },
        16 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x4);
            if (!abi.call(decls.func_0803BB0C, 0x0803BBA1)) return;
            continue :blk 17;
        },
        17 => {
            abi.fetches(3);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803BCC0() callconv(.c) void {
    if (!abi.enter(0x0803BCC0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(27);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[9];
            rt.r[6] = rt.r[8];
            pushRegs(&.{ 6, 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[9] = rt.r[0];
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[8] = rt.r[1];
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[7], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[6], rt.r[3] >> 16);
            rt.r[4] = abi.read32(0x0803BD40);
            rt.r[2] = abi.read32(0x0803BD44);
            rt.r[0] = abi.read32(0x0803BD48);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            if (!abi.call(decls.func_0801BE04, 0x0803BCF3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[5] = abi.read32(0x0803BD4C);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(decls.func_0803D880, 0x0803BD0D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803BD50);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x0803BD23)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        5 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[2] = rt.r[9];
            abi.write8(rt.r[0] +% 0x1E, @truncate(rt.r[2]));
            rt.r[2] = rt.r[8];
            abi.write8(rt.r[0] +% 0x1F, @truncate(rt.r[2]));
            abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[7]));
            abi.write16(rt.r[0] +% 0x22, @truncate(rt.r[6]));
            abi.write16(rt.r[0] +% 0x24, @truncate(rt.r[1]));
            abi.write16(rt.r[0] +% 0x26, @truncate(rt.r[1]));
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

fn func_0803BDE0() callconv(.c) void {
    if (!abi.enter(0x0803BDE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[8];
            pushRegs(&.{ 7 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[7], rt.r[0], 0x0, true);
            rt.r[1] = abi.read16(rt.r[7] +% 0x24);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[8] = rt.r[0];
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 14);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.write16(rt.r[7] +% 0x24, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0807AF30, 0x0803BE09)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x3, true);
            continue :blk 1;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
            rt.r[1] = abi.read16(rt.r[7] +% 0x24);
            if (!abi.call(decls.func_0807B488, 0x0803BE13)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[6], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[6], rt.r[6] << 16);
            abi.setRegNz(&rt.r[6], rt.asrConst(rt.r[6], 16));
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0807AED4, 0x0803BE1F)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[1] = abi.read16(rt.r[7] +% 0x24);
            if (!abi.call(decls.func_0807B488, 0x0803BE2B)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[5], rt.r[5] << 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[5], 16));
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0807AED4, 0x0803BE37)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
            rt.r[1] = abi.read16(rt.r[7] +% 0x24);
            if (!abi.call(decls.func_0807B488, 0x0803BE41)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0807AF30, 0x0803BE4D)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
            rt.r[1] = abi.read16(rt.r[7] +% 0x24);
            if (!abi.call(decls.func_0807B488, 0x0803BE57)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[2], 0x28);
            rt.r[1] = rt.sext16(abi.read16(rt.r[7] +% rt.r[2]));
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[3], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08014B54, 0x0803BE6D)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            rt.r[3] = abi.read16(rt.r[7] +% 0x24);
            rt.cpuSub(null, rt.r[3], 0xF9, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[7] +% 0x24, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[1], 0x28);
            rt.r[0] = rt.sext16(abi.read16(rt.r[7] +% rt.r[1]));
            if (!abi.call(decls.func_0801A250, 0x0803BE7F)) return;
            continue :blk 14;
        },
        13 => {
            abi.fetches(23);
            rt.r[2] = abi.read8(rt.r[7] +% 0x1E);
            abi.setRegNz(&rt.r[1], rt.r[2] << 4);
            rt.r[0] = abi.read32(0x0803BEF4);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x8, true);
            rt.r[1] = abi.read8(rt.r[7] +% 0x1F);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            abi.setRegNz(&rt.r[3], 0x6);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[2], 0x40);
            if (!abi.call(decls.func_08011114, 0x0803BEB7)) return;
            continue :blk 15;
        },
        14 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803BE88);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0803BE87)) return;
            continue :blk 16;
        },
        15 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 18;
            }
            continue :blk 17;
        },
        16 => {
            abi.fetches(3);
            continue :blk 18;
        },
        17 => {
            abi.fetches(24);
            rt.r[1] = abi.read32(0x0803BEF8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[4], rt.r[4] & rt.r[0]);
            rt.r[2] = abi.read16(rt.r[7] +% 0x28);
            abi.setRegNz(&rt.r[0], rt.r[2] << 9);
            abi.setRegNz(&rt.r[4], rt.r[4] | rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], 0xFF);
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[1]);
            rt.r[3] = rt.r[8];
            abi.setRegNz(&rt.r[5], rt.r[5] | rt.r[3]);
            rt.r[2] = abi.read32(0x0803BEFC);
            rt.r[1] = abi.read16(rt.r[7] +% 0x22);
            abi.setRegNz(&rt.r[3], rt.r[1] << 12);
            rt.r[7] = abi.read16(rt.r[7] +% 0x20);
            rt.cpuAdd(&rt.r[3], rt.r[7], rt.r[3], true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x0803BEE9)) return;
            continue :blk 18;
        },
        18 => {
            abi.fetches(8);
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

fn func_0803BF00() callconv(.c) void {
    if (!abi.enter(0x0803BF00)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[4] +% 0x24);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x3, true);
            rt.cpuSub(null, rt.r[0], 0x11, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(17);
            rt.r[1] = abi.read8(rt.r[4] +% 0x1E);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.r[5] = abi.read32(0x0803BFE8);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x4);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[3] = abi.read8(rt.r[4] +% 0x1F);
            abi.setRegNz(&rt.r[1], rt.r[3] << 4);
            abi.setRegNz(&rt.r[3], 0x6);
            rt.r[2] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[2], 0x40);
            if (!abi.call(decls.func_08011114, 0x0803BFA3)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x0803BF18);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x0803BF64 => continue :blk 4,
                0x0803BF84 => continue :blk 1,
                0x0803BF6C => continue :blk 5,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read16(rt.r[4] +% 0x20);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.write16(rt.r[4] +% 0x20, @truncate(rt.r[0]));
            continue :blk 1;
        },
        5 => {
            abi.fetches(11);
            rt.r[0] = abi.read16(rt.r[4] +% 0x20);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x10, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[4] +% 0x20, @truncate(rt.r[0]));
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0803BF80);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0803BF7F)) return;
            continue :blk 8;
        },
        6 => {
            abi.fetches(27);
            rt.r[1] = abi.read8(rt.r[4] +% 0x1E);
            abi.setRegNz(&rt.r[0], rt.r[1] << 4);
            rt.r[2] = abi.read32(rt.r[5] +% 0x0);
            rt.r[3] = abi.read16(rt.r[2] +% 0x4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.r[5] = abi.read32(0x0803BFEC);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.r[3] = abi.read8(rt.r[4] +% 0x1F);
            abi.setRegNz(&rt.r[1], rt.r[3] << 4);
            rt.r[2] = abi.read16(rt.r[2] +% 0x6);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = abi.read32(0x0803BFF0);
            rt.r[5] = abi.read16(rt.r[4] +% 0x22);
            abi.setRegNz(&rt.r[3], rt.r[5] << 12);
            rt.r[5] = abi.read16(rt.r[4] +% 0x20);
            rt.cpuAdd(&rt.r[3], rt.r[5], rt.r[3], true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            if (!abi.call(decls.func_0801B888, 0x0803BFDB)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0x24);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x24, @truncate(rt.r[0]));
            continue :blk 9;
        },
        8 => {
            abi.fetches(3);
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

fn func_0803CBC4() callconv(.c) void {
    if (!abi.enter(0x0803CBC4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(decls.func_08021DF8, 0x0803CBCD)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0803CC0C);
            abi.setRegNz(&rt.r[5], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.r[0] = abi.read32(0x0803CC10);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.r[0] = abi.read32(0x0803CC14);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x0803CBDF)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803CC18);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x0803CBE7)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[1] = abi.read8(rt.r[4] +% 0x2);
            rt.r[0] = abi.read32(0x0803CC1C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x6, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 4;
        },
        6 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x0803CC20);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x2, @truncate(rt.r[5]));
            continue :blk 8;
        },
        7 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0803CC50);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xE);
            abi.write8(rt.r[2] +% 0x2, @truncate(rt.r[0]));
            continue :blk 8;
        },
        8 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.r[1] = abi.read8(rt.r[4] +% 0x3);
            rt.r[0] = abi.read32(0x0803CC54);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x6);
            rt.r[0] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xF, true);
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 4));
            rt.cpuSub(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xA);
            continue :blk 13;
        },
        12 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 13;
        },
        13 => {
            abi.fetches(23);
            abi.write8(rt.r[1] +% 0x3, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            abi.write32(rt.r[2] +% 0x4, rt.r[4]);
            rt.r[0] = abi.read32(0x0803CC8C);
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
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[2] +% 0x8, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x65);
            if (!abi.call(decls.func_0803D880, 0x0803CC87)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0803CD88() callconv(.c) void {
    if (!abi.enter(0x0803CD88)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(20);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[5], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[7], rt.r[1] << 24);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 24);
            rt.r[9] = rt.r[0];
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[2], rt.r[2] >> 24);
            rt.r[10] = rt.r[2];
            abi.setRegNz(&rt.r[3], rt.r[3] << 24);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[3], 24));
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(31);
            rt.r[0] = abi.read32(0x0803CE60);
            rt.r[8] = rt.r[0];
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x0803CE64);
            abi.setRegNz(&rt.r[0], rt.r[5] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[5] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[5] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[6] = abi.read32(0x0803CE74);
            rt.r[2] = rt.r[9];
            abi.setRegNz(&rt.r[3], rt.r[2] << 20);
            rt.r[2] = abi.read32(0x0803CE78);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[2], true);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x0803CE25)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(33);
            rt.r[0] = abi.read32(0x0803CE60);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x0803CE64);
            abi.setRegNz(&rt.r[0], rt.r[4] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[1], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[2], 0xFF);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[2]);
            rt.r[2] = abi.read32(0x0803CE68);
            abi.setRegNz(&rt.r[3], rt.r[7] >> 25);
            abi.setRegNz(&rt.r[3], rt.r[3] << 2);
            rt.r[4] = abi.read32(0x0803CE6C);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[4], true);
            rt.r[6] = abi.read32(0x0803CE70);
            rt.cpuAdd(&rt.r[4], rt.r[6], 0x0, true);
            abi.setRegNz(&rt.r[3], rt.r[3] | rt.r[4]);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            if (!abi.call(decls.func_0801B888, 0x0803CDEB)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(24);
            rt.r[1] = rt.r[8];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[4], rt.r[4] << 16);
            abi.setRegNz(&rt.r[4], rt.asrConst(rt.r[4], 16));
            abi.setRegNz(&rt.r[5], rt.r[5] << 16);
            abi.setRegNz(&rt.r[5], rt.asrConst(rt.r[5], 16));
            rt.r[2] = rt.r[10];
            abi.setRegNz(&rt.r[3], rt.r[2] << 4);
            abi.setRegNz(&rt.r[0], rt.r[7] >> 25);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[0] = abi.read32(0x0803CE7C);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            abi.setRegNz(&rt.r[3], rt.r[3] << 16);
            abi.setRegNz(&rt.r[3], rt.r[3] >> 16);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0801B888, 0x0803CE51)) return;
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

fn func_0803CE80() callconv(.c) void {
    if (!abi.enter(0x0803CE80)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[1] = abi.read32(0x0803CEB0);
            rt.r[0] = abi.read32(0x0803CEB4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[7] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[6], 0x0);
            rt.r[0] = abi.read8(rt.r[7] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x7, true);
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
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x6, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[6], 0x4);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            continue :blk 5;
        },
        4 => {
            abi.fetches(9);
            rt.r[2] = abi.read8(rt.r[1] +% 0x0);
            rt.r[5] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        6 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        7 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[4], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 9;
            }
            continue :blk 10;
        },
        8 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[3], 0xD);
            continue :blk 9;
        },
        9 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[3], rt.r[3] << 24);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[3], 24));
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            if (!abi.call(func_0803CD88, 0x0803CF01)) return;
            continue :blk 11;
        },
        10 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x6, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 12;
        },
        11 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x2, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            continue :blk 5;
        },
        12 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x2, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 13;
        },
        13 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[3], 0xFF);
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_0803CF20() callconv(.c) void {
    if (!abi.enter(0x0803CF20)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            if (!abi.call(decls.func_0803F064, 0x0803CF2D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            rt.r[2] = abi.read32(0x0803CF84);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0800FADC, 0x0803CF41)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[5], 0x1);
            continue :blk 2;
        },
        4 => {
            abi.fetches(7);
            rt.r[2] = abi.read32(0x0803CF88);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.setRegNz(&rt.r[1], 0x8);
            if (!abi.call(decls.func_0800FADC, 0x0803CF4B)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x1E);
            rt.r[2] = rt.sext16(abi.read16(rt.r[4] +% rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x28);
            abi.setRegNz(&rt.r[1], 0x8);
            if (!abi.call(decls.func_0802C11C, 0x0803CF57)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0803CF8C);
            abi.setRegNz(&rt.r[0], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x38);
            abi.setRegNz(&rt.r[1], 0x8);
            if (!abi.call(decls.func_0800FADC, 0x0803CF67)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0803CF90);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read16(rt.r[2] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08015F8C, 0x0803CF79)) return;
            continue :blk 10;
        },
        9 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x20);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803CF94);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0803CF81)) return;
            continue :blk 13;
        },
        11 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0803EFA0, 0x0803CFAB)) return;
            continue :blk 14;
        },
        12 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        13 => {
            abi.fetches(3);
            continue :blk 17;
        },
        14 => {
            abi.fetches(3);
            continue :blk 17;
        },
        15 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EFA0, 0x0803CFBF)) return;
            continue :blk 18;
        },
        16 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x40);
            rt.r[2] = abi.read16(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 20;
            }
            continue :blk 19;
        },
        17 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        18 => {
            abi.fetches(3);
            continue :blk 17;
        },
        19 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[4] +% 0x1E);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 20;
            }
            continue :blk 21;
        },
        20 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0803CFFC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.r[1] = abi.read16(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 17;
            }
            continue :blk 22;
        },
        21 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 20;
        },
        22 => {
            abi.fetches(7);
            rt.r[1] = abi.read16(rt.r[4] +% 0x1E);
            abi.setRegNz(&rt.r[2], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[2]));
            rt.cpuSub(null, rt.r[0], 0x5, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 17;
            }
            continue :blk 23;
        },
        23 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 17;
        },
        else => unreachable,
    }
}

fn func_0803E0C8() callconv(.c) void {
    if (!abi.enter(0x0803E0C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 14 });
            rt.r[0] = abi.read32(0x0803E124);
            rt.r[0] = abi.read16(rt.r[0] +% 0x18);
            if (!abi.call(decls.func_0804B454, 0x0803E0D3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[2] = abi.read32(0x0803E128);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[2], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], 0x5, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[6] = abi.read32(0x0803E128);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08015E3C, 0x0803E0F1)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            if (!abi.call(decls.func_08015E10, 0x0803E101)) return;
            continue :blk 8;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_08015E3C, 0x0803E137)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            if (!abi.call(decls.func_08015E10, 0x0803E141)) return;
            continue :blk 12;
        },
        10 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08015F44, 0x0803E10D)) return;
            continue :blk 13;
        },
        11 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0803E124);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 15;
            }
            continue :blk 14;
        },
        12 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 17;
            }
            continue :blk 16;
        },
        13 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 11;
        },
        14 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[6], true);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 18;
        },
        15 => {
            abi.fetches(4);
            abi.write8(rt.r[6] +% 0x1, @truncate(rt.r[0]));
            continue :blk 19;
        },
        16 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08015F44, 0x0803E14D)) return;
            continue :blk 20;
        },
        17 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[6], true);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 18;
        },
        18 => {
            abi.fetches(3);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 19;
        },
        19 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], 0x3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 21;
        },
        20 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 17;
            }
            continue :blk 22;
        },
        21 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        22 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[6], true);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 18;
        },
        else => unreachable,
    }
}

fn func_0803E170() callconv(.c) void {
    if (!abi.enter(0x0803E170)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[13] -%= 0x4;
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.cpuSub(&rt.r[0], rt.r[6], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[4], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read32(rt.r[4] +% 0x4);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            if (!abi.call(decls.func_0807B44C, 0x0803E193)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[6], true);
            if (rt.CPU_C) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        4 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[6], true);
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[13] +%= 0x4;
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[2] = abi.read32(rt.r[13] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[6], rt.r[5], true);
            rt.cpuAdd(&rt.r[1], rt.r[7], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[5], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[5], rt.r[6], true);
            if (!rt.CPU_C) {
                continue :blk 6;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[6], rt.r[0] >> 24);
            continue :blk 4;
        },
        8 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[4] +% 0x0);
            continue :blk 12;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        11 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], rt.r[5] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        12 => {
            abi.fetches(3);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 11;
        },
        13 => {
            abi.fetches(3);
            continue :blk 11;
        },
        14 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[6], rt.r[1] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[0], true);
            abi.setRegNz(&rt.r[1], 0x80);
            rt.r[4] = abi.read8(rt.r[4] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[4]);
            continue :blk 12;
        },
        else => unreachable,
    }
}

fn func_0803E820() callconv(.c) void {
    if (!abi.enter(0x0803E820)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(36);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[0] = abi.read32(0x0803E8BC);
            rt.r[12] = rt.r[0];
            rt.r[3] = abi.read32(0x0803E8C0);
            rt.r[1] = abi.read32(rt.r[3] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.r[2] = rt.r[12];
            abi.write8(rt.r[2] +% 0x9, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x0803E8C4);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            abi.write16(rt.r[2] +% 0x1A, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.r[2] = rt.r[12];
            abi.write8(rt.r[2] +% 0xD, @truncate(rt.r[0]));
            rt.r[2] = abi.read8(rt.r[1] +% 0x3);
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x30, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x4);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            rt.r[2] = rt.r[12];
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            rt.r[0] = abi.read8(rt.r[1] +% 0x7);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x31, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            rt.r[1] = rt.r[12];
            abi.write8(rt.r[1] +% 0x8, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[4], 0x0);
            rt.cpuAdd(&rt.r[7], rt.r[3], 0x0, true);
            rt.r[3] = rt.r[12];
            rt.cpuAdd(&rt.r[5], rt.r[7], 0x0, true);
            rt.r[6] = rt.r[12];
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x42, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(37);
            rt.cpuAdd(&rt.r[2], rt.r[4], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x3D, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x38, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x9, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x33, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0xD, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[6], true);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x11, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            abi.setRegNz(&rt.r[4], rt.r[2] >> 24);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.r[3] = abi.read8(rt.r[0] +% 0x6);
            rt.cpuSub(null, rt.r[3], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x1, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(12);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2D, true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 7;
        },
        5 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x2, true);
            if (rt.CPU_Z) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        7 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        8 => {
            abi.fetches(3);
            continue :blk 4;
        },
        9 => {
            abi.fetches(6);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2D, true);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 12;
        },
        10 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[3], 0x3, true);
            if (rt.CPU_Z) {
                continue :blk 14;
            }
            continue :blk 13;
        },
        11 => {
            abi.fetches(5);
            rt.r[1] = rt.r[12];
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2D, true);
            abi.setRegNz(&rt.r[0], 0x3);
            continue :blk 12;
        },
        12 => {
            abi.fetches(11);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            continue :blk 7;
        },
        13 => {
            abi.fetches(3);
            continue :blk 4;
        },
        14 => {
            abi.fetches(13);
            rt.r[0] = rt.r[12];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 7;
        },
        else => unreachable,
    }
}

fn func_0803EC50() callconv(.c) void {
    if (!abi.enter(0x0803EC50)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EF1C, 0x0803EC5D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x8, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 4;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EEBC, 0x0803EC71)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0xAF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 7;
        },
        7 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EF48, 0x0803EC85)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0xB, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 10;
        },
        10 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0803EF74, 0x0803EC99)) return;
            continue :blk 11;
        },
        11 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x12, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 10;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 13;
        },
        13 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0803EFA0, 0x0803ECAD)) return;
            continue :blk 14;
        },
        14 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x6, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 13;
            }
            continue :blk 15;
        },
        15 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[2] = abi.read32(0x0803ED0C);
            rt.r[1] = abi.read32(rt.r[2] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 17;
            }
            continue :blk 16;
        },
        16 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x4, true);
            continue :blk 18;
        },
        17 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x5);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EF1C, 0x0803ED05)) return;
            continue :blk 19;
        },
        18 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xC, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x10, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0807B454, 0x0803ECE5)) return;
            continue :blk 20;
        },
        19 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        20 => {
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
                continue :blk 18;
            }
            continue :blk 17;
        },
        else => unreachable,
    }
}

fn func_0803EC5C() callconv(.c) void {
    if (!abi.enter(0x0803EC5C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x8, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EF1C, 0x0803EC5D)) return;
            continue :blk 0;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EEBC, 0x0803EC71)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0xAF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EF48, 0x0803EC85)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0xB, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0803EF74, 0x0803EC99)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x12, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 9;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 12;
        },
        12 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0803EFA0, 0x0803ECAD)) return;
            continue :blk 13;
        },
        13 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x6, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 12;
            }
            continue :blk 14;
        },
        14 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[2] = abi.read32(0x0803ED0C);
            rt.r[1] = abi.read32(rt.r[2] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 16;
            }
            continue :blk 15;
        },
        15 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x4, true);
            continue :blk 17;
        },
        16 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x5);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EF1C, 0x0803ED05)) return;
            continue :blk 18;
        },
        17 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xC, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x10, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0807B454, 0x0803ECE5)) return;
            continue :blk 19;
        },
        18 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        19 => {
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
                continue :blk 17;
            }
            continue :blk 16;
        },
        else => unreachable,
    }
}

fn func_0803EC70() callconv(.c) void {
    if (!abi.enter(0x0803EC70)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0xAF, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EEBC, 0x0803EC71)) return;
            continue :blk 0;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EF48, 0x0803EC85)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0xB, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 3;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0803EF74, 0x0803EC99)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x12, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 6;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 9;
        },
        9 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0803EFA0, 0x0803ECAD)) return;
            continue :blk 10;
        },
        10 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x6, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 9;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[2] = abi.read32(0x0803ED0C);
            rt.r[1] = abi.read32(rt.r[2] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 13;
            }
            continue :blk 12;
        },
        12 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[5], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[6], rt.r[5], 0x4, true);
            continue :blk 14;
        },
        13 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x5);
            abi.setRegNz(&rt.r[1], 0x1);
            if (!abi.call(decls.func_0803EF1C, 0x0803ED05)) return;
            continue :blk 15;
        },
        14 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[0], rt.r[4] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 3);
            rt.cpuAdd(&rt.r[2], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xC, true);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x10, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0807B454, 0x0803ECE5)) return;
            continue :blk 16;
        },
        15 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        16 => {
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
                continue :blk 14;
            }
            continue :blk 13;
        },
        else => unreachable,
    }
}

fn func_0803ED44() callconv(.c) void {
    if (!abi.enter(0x0803ED44)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[9] = rt.r[0];
            rt.r[0] = abi.read32(0x0803EDD8);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[1] = abi.read32(0x0803EDDC);
            abi.setRegNz(&rt.r[5], 0xF);
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            abi.write32(rt.r[1] +% 0x0, rt.r[2]);
            abi.write8(rt.r[1] +% 0x4, @truncate(rt.r[2]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8, true);
            rt.cpuSub(&rt.r[5], rt.r[5], 0x1, true);
            rt.cpuSub(null, rt.r[5], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[7], 0x0);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[1] = abi.read32(rt.r[2] +% 0x4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[10] = rt.r[2];
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[0], 0x10);
            rt.r[0] +%= rt.r[10];
            rt.r[8] = rt.r[0];
            continue :blk 5;
        },
        4 => {
            abi.fetches(13);
            rt.r[0] = rt.r[9];
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[7], true);
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(10);
            rt.r[0] = rt.r[10];
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[4], rt.r[6], rt.r[0], true);
            rt.r[1] = rt.r[8];
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            if (!abi.call(decls.func_0807B450, 0x0803ED8F)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            if (!abi.call(decls.func_0803ED10, 0x0803ED99)) return;
            continue :blk 9;
        },
        8 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x18, true);
            abi.setRegNz(&rt.r[0], 0x18);
            rt.r[8] +%= rt.r[0];
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            rt.cpuSub(null, rt.r[7], 0x1F, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 10;
        },
        9 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 11;
        },
        10 => {
            abi.fetches(10);
            rt.r[2] = abi.read32(0x0803EDD8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[0], true);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        11 => {
            abi.fetches(6);
            rt.r[1] = rt.r[9];
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[7], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[7], rt.r[7], 0x1, true);
            continue :blk 8;
        },
        else => unreachable,
    }
}

fn func_0803F628() callconv(.c) void {
    if (!abi.enter(0x0803F628)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x4;
            rt.r[9] = rt.r[0];
            rt.r[0] = abi.read32(0x0803F64C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[10] = rt.r[0];
            rt.r[0] = abi.read32(0x0803F650);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write32(rt.r[13] +% 0x0, rt.r[0]);
            if (!abi.call(decls.func_080244FC, 0x0803F647)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[6], 0x0);
            abi.setRegNz(&rt.r[1], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.r[2] = abi.read32(0x0803F6D4);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(17);
            rt.r[0] = abi.read32(0x0803F6C8);
            rt.r[1] = rt.r[10];
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0803F6D0);
            rt.r[2] = rt.r[13];
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[2]));
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
            abi.fetches(8);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x1, true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0803F6C8);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[5], rt.r[1] << 16);
            continue :blk 7;
        },
        6 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[7], 0x0, true);
            continue :blk 2;
        },
        7 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0803F6CC);
            rt.r[0] +%= rt.r[9];
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[3] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 24);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 30);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            rt.r[2] = rt.r[8];
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0803F6D0);
            abi.setRegNz(&rt.r[1], rt.r[1] << 6);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[4] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            abi.setRegNz(&rt.r[2], 0x3F);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[3]);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[5], 16));
            if (!abi.call(decls.func_080242DC, 0x0803F691)) return;
            continue :blk 9;
        },
        9 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[6], rt.r[6], 0x1, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.r[0] = abi.read32(0x0803F6D4);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        else => unreachable,
    }
}

fn func_0803F6D8() callconv(.c) void {
    if (!abi.enter(0x0803F6D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            rt.r[2] = abi.read32(0x0803F79C);
            rt.cpuAdd(&rt.r[1], rt.r[6], rt.r[2], true);
            if (!abi.call(decls.func_0803F0C8, 0x0803F6ED)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(14);
            rt.r[0] = abi.read32(0x0803F7A0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x0803F7A4);
            rt.cpuAdd(&rt.r[1], rt.r[6], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.r[2] = abi.read32(0x0803F7A8);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[3] = abi.read32(0x0803F7AC);
            rt.r[0] = abi.read32(0x0803F7B0);
            rt.cpuAdd(&rt.r[2], rt.r[6], rt.r[0], true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[4], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(10);
            rt.r[4] = abi.read32(0x0803F7A0);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[6] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[6] +% 0x2);
            abi.write16(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            if (!abi.call(decls.func_0801F140, 0x0803F727)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[8] = rt.r[1];
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_C) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[9];
            continue :blk 7;
        },
        6 => {
            abi.fetches(9);
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        7 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[2] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[7], rt.r[1], 0x1, true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (rt.CPU_C) {
                continue :blk 9;
            }
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            rt.r[12] = rt.r[10];
            abi.setRegNz(&rt.r[5], rt.r[1] << 1);
            continue :blk 10;
        },
        9 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[7] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.r[2] = rt.r[9];
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        10 => {
            abi.fetches(29);
            rt.r[0] = rt.r[12];
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x0803F7B4);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[1] = abi.read32(0x0803F7B8);
            rt.cpuAdd(&rt.r[2], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            rt.r[1] = rt.r[8];
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[8] = rt.r[0];
            abi.setRegNz(&rt.r[1], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[3], true);
            if (!rt.CPU_C) {
                continue :blk 10;
            }
            continue :blk 9;
        },
        else => unreachable,
    }
}

fn func_0803F7D4() callconv(.c) void {
    if (!abi.enter(0x0803F7D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.r[7] = rt.r[10];
            rt.r[6] = rt.r[9];
            rt.r[5] = rt.r[8];
            pushRegs(&.{ 5, 6, 7 });
            rt.r[13] -%= 0x4;
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[0] = abi.read32(0x0803F868);
            rt.r[12] = rt.r[0];
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_C) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0801F4B8, 0x0803F853)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[10] = rt.r[12];
            rt.r[9] = rt.r[12];
            rt.r[2] = abi.read32(0x0803F86C);
            rt.r[8] = rt.r[2];
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021DF8, 0x0803F857)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[7] = rt.r[10];
            rt.r[0] = abi.read32(rt.r[7] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x1, true);
            abi.write32(rt.r[13] +% 0x0, rt.r[2]);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (rt.CPU_C) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
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
        6 => {
            abi.fetches(5);
            rt.r[4] = rt.r[9];
            abi.setRegNz(&rt.r[6], rt.r[1] << 1);
            rt.r[5] = rt.r[8];
            continue :blk 8;
        },
        7 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(rt.r[13] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.r[2] = rt.r[12];
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 4;
            }
            continue :blk 1;
        },
        8 => {
            abi.fetches(27);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.r[7] = abi.read32(0x0803F870);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[7], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[6], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[7] = abi.read32(0x0803F874);
            rt.cpuAdd(&rt.r[2], rt.r[1], rt.r[7], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[0], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.r[7] = abi.read32(0x0803F878);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[7], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[5] +% 0x0);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        else => unreachable,
    }
}

fn func_0803F898() callconv(.c) void {
    if (!abi.enter(0x0803F898)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 6, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.r[6] = abi.read32(0x0803F8C4);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0803F8C8);
            abi.setRegNz(&rt.r[1], rt.r[4] << 5);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0xFF);
            abi.write8(rt.r[1] +% 0x15, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x5, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            if (!abi.call(decls.func_0801AD38, 0x0803F8B1)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4, 5, 6 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 1;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[6], 0x0, true);
            if (!abi.call(decls.func_0801AC1C, 0x0803F8D5)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[4], rt.r[4] << 5);
            rt.r[5] = abi.read32(0x0803F924);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[5], true);
            rt.r[2] = abi.read32(0x0803F928);
            rt.cpuAdd(&rt.r[1], rt.r[6], rt.r[2], true);
            if (!abi.call(decls.func_0803F0C8, 0x0803F8E3)) return;
            continue :blk 7;
        },
        7 => {
            abi.fetches(10);
            rt.cpuSub(&rt.r[1], rt.r[5], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[1], true);
            rt.r[2] = abi.read32(0x0803F92C);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x15, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x6, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[2], true);
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            continue :blk 9;
        },
        9 => {
            abi.fetches(11);
            abi.write8(rt.r[1] +% 0x1B, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuAdd(&rt.r[0], rt.r[6], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x1C, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[2], 0x0);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x12, true);
            rt.r[0] = abi.read32(0x0803F930);
            rt.cpuAdd(&rt.r[3], rt.r[6], rt.r[0], true);
            continue :blk 10;
        },
        10 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[2], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 10;
            }
            continue :blk 11;
        },
        11 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0803F9F2() callconv(.c) void {
    if (!abi.enter(0x0803F9F2)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.setRegNz(&rt.r[5], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[3], rt.asrConst(rt.r[0], 16));
            rt.r[0] = rt.r[13];
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[4]));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
            rt.r[0] +%= rt.r[13];
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[5]));
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[3] = rt.r[9];
            abi.setRegNz(&rt.r[4], 0x20);
            continue :blk 6;
        },
        6 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[0], 16));
            rt.r[5] = rt.r[13];
            rt.cpuAdd(&rt.r[2], rt.r[5], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(5);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[3], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            continue :blk 8;
        },
        8 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 6;
            }
            continue :blk 9;
        },
        9 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[2] = abi.read32(0x0803FAF0);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 11;
            }
            continue :blk 10;
        },
        10 => {
            abi.fetches(3);
            rt.r[8] = rt.r[2];
            continue :blk 12;
        },
        11 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[5], 0x0);
            rt.r[4] = abi.read32(0x0803FAFC);
            abi.setRegNz(&rt.r[3], 0x68);
            continue :blk 13;
        },
        12 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[4], 0x0);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[5] << 16);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 15;
            }
            continue :blk 14;
        },
        13 => {
            abi.fetches(18);
            abi.setRegNz(&rt.r[0], rt.r[5] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[3]);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[1], true);
            rt.r[5] = rt.r[13];
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[0], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[2] +% 0x1A, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 13;
            }
            continue :blk 16;
        },
        14 => {
            abi.fetches(6);
            rt.r[6] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[12] = rt.r[1];
            rt.r[7] = rt.r[9];
            continue :blk 17;
        },
        15 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[1], rt.r[5] << 16);
            abi.setRegNz(&rt.r[2], 0x80);
            abi.setRegNz(&rt.r[2], rt.r[2] << 9);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[5], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[2] = abi.read32(0x0803FAF0);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 12;
            }
            continue :blk 11;
        },
        16 => {
            abi.fetches(10);
            rt.r[13] +%= 0x10;
            popRegsSeq(&.{ 3, 4, 5 });
            rt.r[8] = rt.r[3];
            rt.r[9] = rt.r[4];
            rt.r[10] = rt.r[5];
            popRegsSeq(&.{ 4, 5, 6, 7 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        17 => {
            abi.fetches(31);
            rt.r[3] = abi.read32(rt.r[6] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[4] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            abi.setRegNz(&rt.r[1], rt.r[2] << 1);
            rt.r[4] = abi.read32(0x0803FAF4);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.r[0] +%= rt.r[12];
            rt.r[1] = abi.read32(0x0803FAF8);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[1], true);
            rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[0], true);
            rt.r[4] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x1F);
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.setRegNz(&rt.r[0], rt.r[4] >> 5);
            rt.cpuAdd(&rt.r[0], rt.r[7], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[1], true);
            abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[4], rt.r[2] >> 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[2], 16));
            rt.r[0] = abi.read32(rt.r[6] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 17;
            }
            continue :blk 15;
        },
        else => unreachable,
    }
}

comptime {
    if (!builtin.is_test) {
        @export(&func_0802164A, .{ .name = "func_0802164A", .linkage = .strong });
        @export(&func_08021B38, .{ .name = "func_08021B38", .linkage = .strong });
        @export(&func_08021C20, .{ .name = "func_08021C20", .linkage = .strong });
        @export(&func_08021D0C, .{ .name = "func_08021D0C", .linkage = .strong });
        @export(&func_0802222C, .{ .name = "func_0802222C", .linkage = .strong });
        @export(&func_080224E0, .{ .name = "func_080224E0", .linkage = .strong });
        @export(&func_080229A8, .{ .name = "func_080229A8", .linkage = .strong });
        @export(&func_08022A58, .{ .name = "func_08022A58", .linkage = .strong });
        @export(&func_08023550, .{ .name = "func_08023550", .linkage = .strong });
        @export(&func_0802365C, .{ .name = "func_0802365C", .linkage = .strong });
        @export(&func_08023734, .{ .name = "func_08023734", .linkage = .strong });
        @export(&func_080237C0, .{ .name = "func_080237C0", .linkage = .strong });
        @export(&func_08023978, .{ .name = "func_08023978", .linkage = .strong });
        @export(&func_08023AA8, .{ .name = "func_08023AA8", .linkage = .strong });
        @export(&func_08023DD0, .{ .name = "func_08023DD0", .linkage = .strong });
        @export(&func_0802430C, .{ .name = "func_0802430C", .linkage = .strong });
        @export(&func_080243DC, .{ .name = "func_080243DC", .linkage = .strong });
        @export(&func_08024664, .{ .name = "func_08024664", .linkage = .strong });
        @export(&func_080246E4, .{ .name = "func_080246E4", .linkage = .strong });
        @export(&func_080247DC, .{ .name = "func_080247DC", .linkage = .strong });
        @export(&func_08024970, .{ .name = "func_08024970", .linkage = .strong });
        @export(&func_08024A48, .{ .name = "func_08024A48", .linkage = .strong });
        @export(&func_08024BD0, .{ .name = "func_08024BD0", .linkage = .strong });
        @export(&func_08024D9C, .{ .name = "func_08024D9C", .linkage = .strong });
        @export(&func_08024EE8, .{ .name = "func_08024EE8", .linkage = .strong });
        @export(&func_08025080, .{ .name = "func_08025080", .linkage = .strong });
        @export(&func_080251BC, .{ .name = "func_080251BC", .linkage = .strong });
        @export(&func_08025310, .{ .name = "func_08025310", .linkage = .strong });
        @export(&func_0802566C, .{ .name = "func_0802566C", .linkage = .strong });
        @export(&func_08025714, .{ .name = "func_08025714", .linkage = .strong });
        @export(&func_080257C8, .{ .name = "func_080257C8", .linkage = .strong });
        @export(&func_0802588C, .{ .name = "func_0802588C", .linkage = .strong });
        @export(&func_08025AA4, .{ .name = "func_08025AA4", .linkage = .strong });
        @export(&func_08025C70, .{ .name = "func_08025C70", .linkage = .strong });
        @export(&func_08025D48, .{ .name = "func_08025D48", .linkage = .strong });
        @export(&func_08025DFC, .{ .name = "func_08025DFC", .linkage = .strong });
        @export(&func_08025EC4, .{ .name = "func_08025EC4", .linkage = .strong });
        @export(&func_08025F80, .{ .name = "func_08025F80", .linkage = .strong });
        @export(&func_08026870, .{ .name = "func_08026870", .linkage = .strong });
        @export(&func_08026A30, .{ .name = "func_08026A30", .linkage = .strong });
        @export(&func_08026BE0, .{ .name = "func_08026BE0", .linkage = .strong });
        @export(&func_080273D8, .{ .name = "func_080273D8", .linkage = .strong });
        @export(&func_08027480, .{ .name = "func_08027480", .linkage = .strong });
        @export(&func_080274F8, .{ .name = "func_080274F8", .linkage = .strong });
        @export(&func_08027620, .{ .name = "func_08027620", .linkage = .strong });
        @export(&func_08027710, .{ .name = "func_08027710", .linkage = .strong });
        @export(&func_08027AB0, .{ .name = "func_08027AB0", .linkage = .strong });
        @export(&func_08027C3C, .{ .name = "func_08027C3C", .linkage = .strong });
        @export(&func_08027E40, .{ .name = "func_08027E40", .linkage = .strong });
        @export(&func_08028358, .{ .name = "func_08028358", .linkage = .strong });
        @export(&func_0802887C, .{ .name = "func_0802887C", .linkage = .strong });
        @export(&func_08028940, .{ .name = "func_08028940", .linkage = .strong });
        @export(&func_080289C0, .{ .name = "func_080289C0", .linkage = .strong });
        @export(&func_08028F94, .{ .name = "func_08028F94", .linkage = .strong });
        @export(&func_080290EC, .{ .name = "func_080290EC", .linkage = .strong });
        @export(&func_08029180, .{ .name = "func_08029180", .linkage = .strong });
        @export(&func_080296C0, .{ .name = "func_080296C0", .linkage = .strong });
        @export(&func_08029B20, .{ .name = "func_08029B20", .linkage = .strong });
        @export(&func_08029C1C, .{ .name = "func_08029C1C", .linkage = .strong });
        @export(&func_08029CEC, .{ .name = "func_08029CEC", .linkage = .strong });
        @export(&func_0802A6FC, .{ .name = "func_0802A6FC", .linkage = .strong });
        @export(&func_0802A7A4, .{ .name = "func_0802A7A4", .linkage = .strong });
        @export(&func_0802A8A4, .{ .name = "func_0802A8A4", .linkage = .strong });
        @export(&func_0802AB2C, .{ .name = "func_0802AB2C", .linkage = .strong });
        @export(&func_0802AC10, .{ .name = "func_0802AC10", .linkage = .strong });
        @export(&func_0802B7D4, .{ .name = "func_0802B7D4", .linkage = .strong });
        @export(&func_0802BB44, .{ .name = "func_0802BB44", .linkage = .strong });
        @export(&func_0802BBC8, .{ .name = "func_0802BBC8", .linkage = .strong });
        @export(&func_0802BEC8, .{ .name = "func_0802BEC8", .linkage = .strong });
        @export(&func_0802C368, .{ .name = "func_0802C368", .linkage = .strong });
        @export(&func_0802CD34, .{ .name = "func_0802CD34", .linkage = .strong });
        @export(&func_0802CD38, .{ .name = "func_0802CD38", .linkage = .strong });
        @export(&func_0802CDD4, .{ .name = "func_0802CDD4", .linkage = .strong });
        @export(&func_0802D634, .{ .name = "func_0802D634", .linkage = .strong });
        @export(&func_0802DB98, .{ .name = "func_0802DB98", .linkage = .strong });
        @export(&func_0802E9C8, .{ .name = "func_0802E9C8", .linkage = .strong });
        @export(&func_0802F104, .{ .name = "func_0802F104", .linkage = .strong });
        @export(&func_0802F190, .{ .name = "func_0802F190", .linkage = .strong });
        @export(&func_0802F270, .{ .name = "func_0802F270", .linkage = .strong });
        @export(&func_0802F4EE, .{ .name = "func_0802F4EE", .linkage = .strong });
        @export(&func_0802F502, .{ .name = "func_0802F502", .linkage = .strong });
        @export(&func_0802F730, .{ .name = "func_0802F730", .linkage = .strong });
        @export(&func_0802F7FA, .{ .name = "func_0802F7FA", .linkage = .strong });
        @export(&func_0802F800, .{ .name = "func_0802F800", .linkage = .strong });
        @export(&func_0802F804, .{ .name = "func_0802F804", .linkage = .strong });
        @export(&func_0802F94C, .{ .name = "func_0802F94C", .linkage = .strong });
        @export(&func_0802FA70, .{ .name = "func_0802FA70", .linkage = .strong });
        @export(&func_0802FED4, .{ .name = "func_0802FED4", .linkage = .strong });
        @export(&func_0803093C, .{ .name = "func_0803093C", .linkage = .strong });
        @export(&func_08030AF0, .{ .name = "func_08030AF0", .linkage = .strong });
        @export(&func_08030C28, .{ .name = "func_08030C28", .linkage = .strong });
        @export(&func_08031364, .{ .name = "func_08031364", .linkage = .strong });
        @export(&func_08031C98, .{ .name = "func_08031C98", .linkage = .strong });
        @export(&func_08031D84, .{ .name = "func_08031D84", .linkage = .strong });
        @export(&func_08031E12, .{ .name = "func_08031E12", .linkage = .strong });
        @export(&func_08031E14, .{ .name = "func_08031E14", .linkage = .strong });
        @export(&func_08032130, .{ .name = "func_08032130", .linkage = .strong });
        @export(&func_08032508, .{ .name = "func_08032508", .linkage = .strong });
        @export(&func_08032D68, .{ .name = "func_08032D68", .linkage = .strong });
        @export(&func_08032FC8, .{ .name = "func_08032FC8", .linkage = .strong });
        @export(&func_080337A8, .{ .name = "func_080337A8", .linkage = .strong });
        @export(&func_08033918, .{ .name = "func_08033918", .linkage = .strong });
        @export(&func_08033C90, .{ .name = "func_08033C90", .linkage = .strong });
        @export(&func_08033D38, .{ .name = "func_08033D38", .linkage = .strong });
        @export(&func_08033EB4, .{ .name = "func_08033EB4", .linkage = .strong });
        @export(&func_0803402C, .{ .name = "func_0803402C", .linkage = .strong });
        @export(&func_080345B0, .{ .name = "func_080345B0", .linkage = .strong });
        @export(&func_08034A1C, .{ .name = "func_08034A1C", .linkage = .strong });
        @export(&func_08034CE4, .{ .name = "func_08034CE4", .linkage = .strong });
        @export(&func_08034D68, .{ .name = "func_08034D68", .linkage = .strong });
        @export(&func_08034EE8, .{ .name = "func_08034EE8", .linkage = .strong });
        @export(&func_080350DC, .{ .name = "func_080350DC", .linkage = .strong });
        @export(&func_080353D4, .{ .name = "func_080353D4", .linkage = .strong });
        @export(&func_08035488, .{ .name = "func_08035488", .linkage = .strong });
        @export(&func_08035518, .{ .name = "func_08035518", .linkage = .strong });
        @export(&func_080355B4, .{ .name = "func_080355B4", .linkage = .strong });
        @export(&func_08035648, .{ .name = "func_08035648", .linkage = .strong });
        @export(&func_080356EC, .{ .name = "func_080356EC", .linkage = .strong });
        @export(&func_080358C0, .{ .name = "func_080358C0", .linkage = .strong });
        @export(&func_08035990, .{ .name = "func_08035990", .linkage = .strong });
        @export(&func_08035B18, .{ .name = "func_08035B18", .linkage = .strong });
        @export(&func_08035C54, .{ .name = "func_08035C54", .linkage = .strong });
        @export(&func_08036318, .{ .name = "func_08036318", .linkage = .strong });
        @export(&func_08037130, .{ .name = "func_08037130", .linkage = .strong });
        @export(&func_080380B0, .{ .name = "func_080380B0", .linkage = .strong });
        @export(&func_080385CC, .{ .name = "func_080385CC", .linkage = .strong });
        @export(&func_080386E4, .{ .name = "func_080386E4", .linkage = .strong });
        @export(&func_08038734, .{ .name = "func_08038734", .linkage = .strong });
        @export(&func_08038C90, .{ .name = "func_08038C90", .linkage = .strong });
        @export(&func_08038E10, .{ .name = "func_08038E10", .linkage = .strong });
        @export(&func_080391C8, .{ .name = "func_080391C8", .linkage = .strong });
        @export(&func_08039484, .{ .name = "func_08039484", .linkage = .strong });
        @export(&func_080395B4, .{ .name = "func_080395B4", .linkage = .strong });
        @export(&func_08039668, .{ .name = "func_08039668", .linkage = .strong });
        @export(&func_08039814, .{ .name = "func_08039814", .linkage = .strong });
        @export(&func_08039CC4, .{ .name = "func_08039CC4", .linkage = .strong });
        @export(&func_08039F5C, .{ .name = "func_08039F5C", .linkage = .strong });
        @export(&func_0803A00C, .{ .name = "func_0803A00C", .linkage = .strong });
        @export(&func_0803A140, .{ .name = "func_0803A140", .linkage = .strong });
        @export(&func_0803A38C, .{ .name = "func_0803A38C", .linkage = .strong });
        @export(&func_0803A6C8, .{ .name = "func_0803A6C8", .linkage = .strong });
        @export(&func_0803A828, .{ .name = "func_0803A828", .linkage = .strong });
        @export(&func_0803A9B8, .{ .name = "func_0803A9B8", .linkage = .strong });
        @export(&func_0803AAB8, .{ .name = "func_0803AAB8", .linkage = .strong });
        @export(&func_0803ABE0, .{ .name = "func_0803ABE0", .linkage = .strong });
        @export(&func_0803B1DC, .{ .name = "func_0803B1DC", .linkage = .strong });
        @export(&func_0803B284, .{ .name = "func_0803B284", .linkage = .strong });
        @export(&func_0803B690, .{ .name = "func_0803B690", .linkage = .strong });
        @export(&func_0803BB30, .{ .name = "func_0803BB30", .linkage = .strong });
        @export(&func_0803BCC0, .{ .name = "func_0803BCC0", .linkage = .strong });
        @export(&func_0803BDE0, .{ .name = "func_0803BDE0", .linkage = .strong });
        @export(&func_0803BF00, .{ .name = "func_0803BF00", .linkage = .strong });
        @export(&func_0803CBC4, .{ .name = "func_0803CBC4", .linkage = .strong });
        @export(&func_0803CD88, .{ .name = "func_0803CD88", .linkage = .strong });
        @export(&func_0803CE80, .{ .name = "func_0803CE80", .linkage = .strong });
        @export(&func_0803CF20, .{ .name = "func_0803CF20", .linkage = .strong });
        @export(&func_0803E0C8, .{ .name = "func_0803E0C8", .linkage = .strong });
        @export(&func_0803E170, .{ .name = "func_0803E170", .linkage = .strong });
        @export(&func_0803E820, .{ .name = "func_0803E820", .linkage = .strong });
        @export(&func_0803EC50, .{ .name = "func_0803EC50", .linkage = .strong });
        @export(&func_0803EC5C, .{ .name = "func_0803EC5C", .linkage = .strong });
        @export(&func_0803EC70, .{ .name = "func_0803EC70", .linkage = .strong });
        @export(&func_0803ED44, .{ .name = "func_0803ED44", .linkage = .strong });
        @export(&func_0803F628, .{ .name = "func_0803F628", .linkage = .strong });
        @export(&func_0803F6D8, .{ .name = "func_0803F6D8", .linkage = .strong });
        @export(&func_0803F7D4, .{ .name = "func_0803F7D4", .linkage = .strong });
        @export(&func_0803F898, .{ .name = "func_0803F898", .linkage = .strong });
        @export(&func_0803F9F2, .{ .name = "func_0803F9F2", .linkage = .strong });
    }
}
