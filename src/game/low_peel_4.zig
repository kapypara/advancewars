//! Low-ROM (< 0x08080000) block-peeled wave 4 (31..60 reachable lines, next 185).

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

fn func_080242DC() callconv(.c) void {
    if (!abi.enter(0x080242DC)) return;
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
            if (!abi.call(decls.func_0802425C, 0x080242EF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
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
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0xFE);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08023EDC, 0x08024301)) return;
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

fn func_080244FC() callconv(.c) void {
    if (!abi.enter(0x080244FC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[5] = abi.read32(0x08024520);
            rt.r[4] = abi.read32(0x08024524);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[1], 0xFF);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[0], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0xC, true);
            rt.cpuSub(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[5] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08024884() callconv(.c) void {
    if (!abi.enter(0x08024884)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[3] = abi.read32(0x080248A8);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_080248AC() callconv(.c) void {
    if (!abi.enter(0x080248AC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(26);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x080248E0);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2F, true);
            rt.r[3] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[3] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 1);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x31, true);
            rt.r[3] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[3] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read32(0x080248E4);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_08024B50() callconv(.c) void {
    if (!abi.enter(0x08024B50)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 16);
            rt.r[1] = abi.read32(0x08024B74);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[2], true);
            rt.r[1] = abi.read16(rt.r[2] +% 0x34);
            rt.r[3] = abi.read32(0x08024B78);
            rt.cpuSub(&rt.r[0], rt.r[3], rt.r[1], true);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if ((rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[1], true);
            abi.write16(rt.r[2] +% 0x34, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.write16(rt.r[2] +% 0x34, @truncate(rt.r[3]));
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

fn func_08024B88() callconv(.c) void {
    if (!abi.enter(0x08024B88)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x08024BAC);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[2] = abi.read16(rt.r[1] +% 0x16);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            abi.write16(rt.r[1] +% 0x16, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.r[3] = abi.read16(rt.r[1] +% 0x18);
            rt.cpuSub(null, rt.r[0], rt.r[3], true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.write16(rt.r[1] +% 0x18, @truncate(rt.r[2]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_08024BB0() callconv(.c) void {
    if (!abi.enter(0x08024BB0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0xA);
            if (!abi.call(decls.func_08024B4C, 0x08024BCB)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[1], 0x5);
            if (!abi.call(decls.func_08024B4C, 0x08024BC3)) return;
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

fn func_08024CD0() callconv(.c) void {
    if (!abi.enter(0x08024CD0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x08024CF0);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[1]);
            rt.cpuAdd(&rt.r[1], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1B);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[1] +% 0x14);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_08024CF8() callconv(.c) void {
    if (!abi.enter(0x08024CF8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
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
            if (!abi.call(func_08024CD0, 0x08024D13)) return;
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
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_08024D58() callconv(.c) void {
    if (!abi.enter(0x08024D58)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x08024D84);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x5, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08016938, 0x08024D6F)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            if (!abi.call(func_08024CD0, 0x08024D79)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
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
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08025138() callconv(.c) void {
    if (!abi.enter(0x08025138)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x6, true);
            rt.cpuSub(null, rt.r[0], 0xC, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read32(0x0802514C);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            switch (rt.r[0] & ~@as(u32, 1)) {
                0x08025184 => continue :blk 3,
                0x08025190 => continue :blk 2,
                else => {},
            }
            decls.awre_cpu_bx(rt.r[0] | 1); return;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0802518C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x28);
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_08025194() callconv(.c) void {
    if (!abi.enter(0x08025194)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x080251B4);
            rt.r[2] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x68);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x29, true);
            abi.setRegNz(&rt.r[0], 0x80);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_080253D4() callconv(.c) void {
    if (!abi.enter(0x080253D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(24);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.r[1] >> 16);
            rt.r[2] = abi.read32(0x08025404);
            rt.r[4] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x68);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[3]);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x27, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x28, true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
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
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_08025410() callconv(.c) void {
    if (!abi.enter(0x08025410)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(21);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x0802543C);
            rt.r[1] = abi.read32(0x08025440);
            rt.r[4] = abi.read32(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[3]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x26, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 22));
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8E, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
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
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_0802544C() callconv(.c) void {
    if (!abi.enter(0x0802544C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(22);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 22));
            rt.r[2] = abi.read32(0x08025478);
            rt.r[4] = abi.read32(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x68);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[2], rt.r[2] *% rt.r[3]);
            rt.cpuAdd(&rt.r[2], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x8E, true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 22));
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8E, true);
            rt.r[2] = abi.read8(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
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
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_08025484() callconv(.c) void {
    if (!abi.enter(0x08025484)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 24);
            abi.setRegNz(&rt.r[3], rt.r[1] >> 29);
            rt.cpuSub(null, rt.r[3], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(17);
            abi.setRegNz(&rt.r[1], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 22));
            rt.r[0] = abi.read32(0x080254B4);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x8E, true);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[3]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x26, true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
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
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_080254BC() callconv(.c) void {
    if (!abi.enter(0x080254BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[2], rt.r[2] << 16);
            abi.setRegNz(&rt.r[1], rt.r[2] >> 16);
            rt.r[0] = abi.read32(0x080254F8);
            rt.r[0] = abi.read8(rt.r[0] +% 0xD);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(0x080254FC);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1C);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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
            abi.fetches(11);
            rt.r[0] = abi.read32(0x08025500);
            abi.setRegNz(&rt.r[1], rt.r[3] << 3);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x20, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
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
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08025508() callconv(.c) void {
    if (!abi.enter(0x08025508)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[0] = abi.read32(0x0802552C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x40);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x7A, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[1] +% 0x9);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.r[4] = abi.read8(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[4]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x68, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 5;
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
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_08025540() callconv(.c) void {
    if (!abi.enter(0x08025540)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x1);
            rt.r[0] = abi.read32(0x08025554);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x68, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[2] = abi.read8(rt.r[0] +% 0x1B);
            rt.cpuSub(null, rt.r[2], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[1] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x68, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(null, rt.r[1], 0x4, true);
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

fn func_080255C4() callconv(.c) void {
    if (!abi.enter(0x080255C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[4] = abi.read32(0x080255E8);
            abi.setRegNz(&rt.r[1], 0x68);
            abi.setRegNz(&rt.r[1], rt.r[1] *% rt.r[0]);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x4F, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x18, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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

fn func_080276E4() callconv(.c) void {
    if (!abi.enter(0x080276E4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0802770C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[3], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0x1E, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08027578, 0x08027707)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[3]));
            abi.write32(rt.r[2] +% 0x8, rt.r[3]);
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

fn func_08027F7C() callconv(.c) void {
    if (!abi.enter(0x08027F7C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08027F94);
            if (!abi.call(decls.func_08013B70, 0x08027F85)) return;
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_08028400() callconv(.c) void {
    if (!abi.enter(0x08028400)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[2] = abi.read32(0x08028430);
            rt.r[0] = abi.read8(rt.r[2] +% 0x1);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08028438);
            abi.setRegNz(&rt.r[0], 0xF);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x08028434);
            rt.r[3] = abi.read8(rt.r[2] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[3] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08018400, 0x08028427)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0802877C() callconv(.c) void {
    if (!abi.enter(0x0802877C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            if (!abi.call(func_08024CD0, 0x0802878B)) return;
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
            rt.r[0] = abi.read32(0x0802879C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[4], true);
            if (rt.CPU_Z) {
                continue :blk 2;
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08029B08() callconv(.c) void {
    if (!abi.enter(0x08029B08)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
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
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x50);
            if (!abi.call(decls.func_0803D880, 0x08029B1D)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0802BF70() callconv(.c) void {
    if (!abi.enter(0x0802BF70)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802BF8C);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x7, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802BFAC);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x8, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[1], 0x3);
            abi.write32(rt.r[0] +% 0x4, rt.r[1]);
            abi.write32(rt.r[0] +% 0xC, rt.r[1]);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(10);
            rt.r[1] = abi.read32(0x0802BF90);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0xA0);
            abi.write32(rt.r[1] +% 0x4, rt.r[0]);
            abi.setRegNz(&rt.r[0], 0x94);
            abi.write32(rt.r[1] +% 0xC, rt.r[0]);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.write8(rt.r[1] +% 0x10, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0x2);
            abi.write8(rt.r[1] +% 0x11, @truncate(rt.r[0]));
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_0802C574() callconv(.c) void {
    if (!abi.enter(0x0802C574)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0802C598);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_0802C540, 0x0802C57F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802C59C);
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
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x11);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08034988, 0x0802C595)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0802C5E0() callconv(.c) void {
    if (!abi.enter(0x0802C5E0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
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
            abi.fetches(3);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            rt.cpuSub(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], rt.r[4], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0802C76C() callconv(.c) void {
    if (!abi.enter(0x0802C76C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0802C794);
            rt.r[3] = abi.read16(rt.r[4] +% 0x1E);
            abi.setRegNz(&rt.r[1], rt.r[3] << 16);
            abi.setRegNz(&rt.r[2], rt.asrConst(rt.r[1], 16));
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 17));
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuSub(null, rt.r[2], 0xB, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x0802C798);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[2] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[2]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x0802C79C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0802C793)) return;
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
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802C828() callconv(.c) void {
    if (!abi.enter(0x0802C828)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0802C848);
            rt.r[1] = abi.read16(rt.r[2] +% 0x1E);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(&rt.r[0], rt.r[1], 0x1, true);
            abi.write16(rt.r[2] +% 0x1E, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080104B0, 0x0802C83D)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802C84C);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0802C845)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802C858() callconv(.c) void {
    if (!abi.enter(0x0802C858)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[1] = abi.read32(rt.r[0] +% 0x20);
            rt.r[0] = abi.read32(0x0802C88C);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(rt.r[2] +% 0x4);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_08012830, 0x0802C883)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(13);
            rt.r[0] = abi.read32(0x0802C890);
            rt.r[3] = abi.read16(rt.r[2] +% 0x4);
            abi.setRegNz(&rt.r[1], rt.r[3] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 20));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x7, true);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[2] = abi.read16(rt.r[2] +% 0x6);
            abi.setRegNz(&rt.r[1], rt.r[2] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 20));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x5, true);
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[1]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0802C894);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0802C988() callconv(.c) void {
    if (!abi.enter(0x0802C988)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 2, 3, 5, 14 });
            abi.setRegNz(&rt.r[0], 0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[4] = abi.read8(rt.r[4] +% 0x2);
            rt.r[5] = abi.read8(rt.r[5] +% 0x2);
            rt.cpuSub(null, rt.r[4], rt.r[5], true);
            if (!rt.CPU_C) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0802C998);
            continue :blk 4;
        },
        3 => {
            abi.fetches(3);
            rt.r[0] = abi.read32(0x0802C9A4);
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

fn func_0802D77C() callconv(.c) void {
    if (!abi.enter(0x0802D77C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            rt.r[2] = abi.read32(0x0802D794);
            rt.r[1] = abi.read32(0x0802D798);
            rt.r[3] = abi.read8(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[3] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1E);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
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

fn func_0802D808() callconv(.c) void {
    if (!abi.enter(0x0802D808)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0802D820);
            rt.r[0] = abi.read8(rt.r[0] +% 0x2);
            rt.cpuSub(null, rt.r[0], 0x74, true);
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
            if (!abi.call(decls.func_0802D7A0, 0x0802D817)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
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

fn func_0802D82C() callconv(.c) void {
    if (!abi.enter(0x0802D82C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0802D7A0, 0x0802D833)) return;
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
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D7E4, 0x0802D83F)) return;
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
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802D850);
            rt.r[0] = abi.read8(rt.r[0] +% 0x9);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802D85C() callconv(.c) void {
    if (!abi.enter(0x0802D85C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0802D7A0, 0x0802D863)) return;
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
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D7E4, 0x0802D86F)) return;
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
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802D880);
            rt.r[0] = abi.read8(rt.r[0] +% 0x9);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802D88C() callconv(.c) void {
    if (!abi.enter(0x0802D88C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0802D7A0, 0x0802D893)) return;
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
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D7E4, 0x0802D89F)) return;
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
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802D8B0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x9);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802D8BC() callconv(.c) void {
    if (!abi.enter(0x0802D8BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0802D7A0, 0x0802D8C3)) return;
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
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D7E4, 0x0802D8CF)) return;
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
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802D8E0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x9);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802D8EC() callconv(.c) void {
    if (!abi.enter(0x0802D8EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0802D7A0, 0x0802D8F3)) return;
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
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802D7E4, 0x0802D8FF)) return;
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
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802D910);
            rt.r[0] = abi.read8(rt.r[0] +% 0x9);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802D988() callconv(.c) void {
    if (!abi.enter(0x0802D988)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            rt.r[2] = abi.read32(0x0802D9A0);
            rt.r[1] = abi.read32(0x0802D9A4);
            rt.r[3] = abi.read8(rt.r[1] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[3] << 4);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1E);
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

fn func_0802D9AC() callconv(.c) void {
    if (!abi.enter(0x0802D9AC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0802D9C4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_0801C07C, 0x0802D9B7)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0802D9C8);
            rt.r[1] = abi.read8(rt.r[1] +% 0x7);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_0802DA30() callconv(.c) void {
    if (!abi.enter(0x0802DA30)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x0802DA58);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read32(0x0802DA5C);
            rt.r[0] = abi.read16(rt.r[3] +% 0x2);
            abi.setRegNz(&rt.r[2], rt.r[0] << 1);
            rt.r[4] = abi.read32(0x0802DA60);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[4], true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[3] = abi.read16(rt.r[3] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[3], rt.r[0], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x12, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
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
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_0802DB18() callconv(.c) void {
    if (!abi.enter(0x0802DB18)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0802DB44);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
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
            abi.fetches(4);
            if (!abi.call(decls.func_0802DACC, 0x0802DB27)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 5;
        },
        5 => {
            abi.fetches(12);
            rt.r[2] = abi.read32(0x0802DB48);
            rt.r[0] = abi.read32(0x0802DB4C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802DB58() callconv(.c) void {
    if (!abi.enter(0x0802DB58)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0802DACC, 0x0802DB5F)) return;
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
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802DB84);
            rt.r[0] = abi.read8(rt.r[0] +% 0x8);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(12);
            rt.r[2] = abi.read32(0x0802DB88);
            rt.r[0] = abi.read32(0x0802DB8C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x68);
            rt.r[2] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] *% rt.r[2]);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (rt.CPU_Z) {
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

fn func_0802DD5C() callconv(.c) void {
    if (!abi.enter(0x0802DD5C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0802DD78);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            abi.setRegNz(&rt.r[2], 0x2);
            rt.r[1] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(decls.func_08025AA4, 0x0802DD6D)) return;
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_0802DD84() callconv(.c) void {
    if (!abi.enter(0x0802DD84)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_0802DD5C, 0x0802DD8B)) return;
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
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0802DDB0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x0802DDB4);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            abi.setRegNz(&rt.r[3], 0x2);
            rt.r[2] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            if (!abi.call(decls.func_080259C4, 0x0802DDA3)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 2;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802DDC0() callconv(.c) void {
    if (!abi.enter(0x0802DDC0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_0802DD5C, 0x0802DDC7)) return;
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
            abi.fetches(11);
            rt.r[0] = abi.read32(0x0802DDEC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[2] = abi.read32(0x0802DDF0);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            abi.setRegNz(&rt.r[3], 0x2);
            rt.r[2] = rt.sext16(abi.read16(rt.r[2] +% rt.r[3]));
            if (!abi.call(decls.func_08025A34, 0x0802DDDF)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 6;
            }
            continue :blk 2;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802DFB8() callconv(.c) void {
    if (!abi.enter(0x0802DFB8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0802DFD0);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[2] = abi.read8(rt.r[1] +% 0xC);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[2], true);
            abi.write8(rt.r[1] +% 0xC, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0xC);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803D968, 0x0802DFD9)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x1, true);
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
            rt.r[0] = abi.read32(0x0802DFEC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_0801BE88, 0x0802DFE3)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080192F0, 0x0802DFE7)) return;
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

fn func_0802E04C() callconv(.c) void {
    if (!abi.enter(0x0802E04C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_08019608, 0x0802E053)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x0802E084);
            rt.r[0] = abi.read32(0x0802E088);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
            rt.r[0] = abi.read32(0x0802E08C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802E090);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_0801C120, 0x0802E07B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802E090);
            rt.r[2] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xE);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08034988, 0x0802E073)) return;
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021DF8, 0x0802E07F)) return;
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

fn func_0802E094() callconv(.c) void {
    if (!abi.enter(0x0802E094)) return;
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
            if (!abi.call(decls.func_08019A1C, 0x0802E0A7)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08019608, 0x0802E0AB)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080351E8, 0x0802E0AF)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08046DEC, 0x0802E0B3)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0802E0B8() callconv(.c) void {
    if (!abi.enter(0x0802E0B8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_08019608, 0x0802E0BF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08026750, 0x0802E0C3)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0802E0DC);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
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
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2E, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(func_08034940, 0x0802E0D9)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802E0E0() callconv(.c) void {
    if (!abi.enter(0x0802E0E0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0802E0F4);
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2C, true);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[1], 0x1, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        3 => {
            abi.fetches(8);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08035274, 0x0802E107)) return;
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

fn func_0802E10C() callconv(.c) void {
    if (!abi.enter(0x0802E10C)) return;
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
            if (!abi.call(decls.func_08019608, 0x0802E11F)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802C660, 0x0802E123)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0802E2B4() callconv(.c) void {
    if (!abi.enter(0x0802E2B4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0802E2C8);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0802E2E8);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0802E2CC);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_08029BEC, 0x0802E2DB)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08019608, 0x0802E2DF)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035220, 0x0802E2E3)) return;
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

fn func_0802E30C() callconv(.c) void {
    if (!abi.enter(0x0802E30C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0802E33C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08019608, 0x0802E319)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08066E7C, 0x0802E31D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08026060, 0x0802E321)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802E340);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
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
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802E344);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xA);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08034988, 0x0802E339)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802E348() callconv(.c) void {
    if (!abi.enter(0x0802E348)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0802E378);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            if (!abi.call(decls.func_08019608, 0x0802E355)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08066E98, 0x0802E359)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08026060, 0x0802E35D)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802E37C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
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
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802E380);
            rt.r[1] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xB);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.setRegNz(&rt.r[3], 0x0);
            if (!abi.call(decls.func_08034988, 0x0802E375)) return;
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0802E4E8() callconv(.c) void {
    if (!abi.enter(0x0802E4E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0802E4FC);
            if (!abi.call(decls.func_0806CB80, 0x0802E4F1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x48, true);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xF, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x10);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_0802E650() callconv(.c) void {
    if (!abi.enter(0x0802E650)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], 0x11);
            if (!abi.call(decls.func_08018BA8, 0x0802E659)) return;
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
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08019A6C, 0x0802E661)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035220, 0x0802E665)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0802EF2C() callconv(.c) void {
    if (!abi.enter(0x0802EF2C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0802EF4C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF);
            rt.r[1] = abi.read16(rt.r[1] +% 0x10);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0802EF50);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x0802EF54);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_0802F902() callconv(.c) void {
    if (!abi.enter(0x0802F902)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            continue :blk 1;
        },
        1 => {
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
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0802F948);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[6]));
            if (!abi.call(decls.func_0803AC5C, 0x0802F921)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x69);
            if (!abi.call(decls.func_0803D880, 0x0802F927)) return;
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

fn func_0802FA08() callconv(.c) void {
    if (!abi.enter(0x0802FA08)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0802FA28);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0802FA3C);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080367F0, 0x0802FA17)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08023EDC, 0x0802FA1B)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0802FA2C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            rt.r[1] = abi.read8(rt.r[1] +% 0x3);
            if (!abi.call(decls.func_0802F7E4, 0x0802FA27)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0802FBF2() callconv(.c) void {
    if (!abi.enter(0x0802FBF2)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[2] = rt.r[12];
            abi.write16(rt.r[0] +% 0x2, @truncate(rt.r[2]));
            rt.r[1] = abi.read32(0x0802FC34);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[3] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
            continue :blk 2;
        },
        2 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[4] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x0802FC38);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
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
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_0802FBFA() callconv(.c) void {
    if (!abi.enter(0x0802FBFA)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[3] = rt.r[12];
            abi.setRegNz(&rt.r[0], rt.r[3] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 14));
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[4] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x0802FC38);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 2;
        },
        2 => {
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
        else => unreachable,
    }
}

fn func_0802FC00() callconv(.c) void {
    if (!abi.enter(0x0802FC00)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[4] = rt.r[8];
            abi.setRegNz(&rt.r[1], rt.r[4] << 16);
            abi.setRegNz(&rt.r[1], rt.asrConst(rt.r[1], 16));
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x0802FC38);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 1;
        },
        1 => {
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
        else => unreachable,
    }
}

fn func_0802FDD4() callconv(.c) void {
    if (!abi.enter(0x0802FDD4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(14);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0802FDF8);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0802FDFC);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x0802FE00);
            rt.r[1] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x9);
            abi.setRegNz(&rt.r[0], rt.r[0] & ~rt.r[1]);
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
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0802FE04);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0802FDF5)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0802FF0E() callconv(.c) void {
    if (!abi.enter(0x0802FF0E)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x0802FF4C);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.write32(rt.r[2] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802FF50);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        6 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5 });
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            popRegsSeq(&.{ 1 });
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_0802FF12() callconv(.c) void {
    if (!abi.enter(0x0802FF12)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            abi.setRegNz(&rt.r[0], 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[2] = abi.read32(0x0802FF4C);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.write32(rt.r[2] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0xF0);
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            continue :blk 4;
        },
        4 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0802FF50);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[5] +% 0x0, rt.r[0]);
            continue :blk 2;
        },
        5 => {
            abi.fetches(3);
            popRegsSeq(&.{ 4, 5 });
            continue :blk 6;
        },
        6 => {
            abi.fetches(3);
            popRegsSeq(&.{ 1 });
            continue :blk 7;
        },
        7 => {
            abi.fetches(3);
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        else => unreachable,
    }
}

fn func_08030064() callconv(.c) void {
    if (!abi.enter(0x08030064)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08030090);
            rt.cpuSub(null, rt.r[2], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08030094);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08030090);
            rt.cpuSub(null, rt.r[3], rt.r[0], true);
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 8;
            }
            continue :blk 7;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08030010, 0x08030089)) return;
            continue :blk 8;
        },
        8 => {
            abi.fetches(4);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            continue :blk 9;
        },
        9 => {
            abi.fetches(3);
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080300AC() callconv(.c) void {
    if (!abi.enter(0x080300AC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x080300D8);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x080300DC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            rt.r[2] = abi.read32(0x080300E4);
            rt.r[0] = abi.read32(0x080300E8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[3], 0xC1);
            abi.setRegNz(&rt.r[3], rt.r[3] << 7);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write16(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x080300E0);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x3);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_0803083C() callconv(.c) void {
    if (!abi.enter(0x0803083C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(12);
            rt.r[1] = abi.read32(0x08030854);
            rt.r[1] = abi.read32(rt.r[1] +% 0x0);
            rt.r[1] = abi.read8(rt.r[1] +% 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], rt.armAsr(rt.r[1], rt.r[0] & 0xFF));
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            rt.cpuSub(null, rt.r[1], 0x0, true);
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

fn func_0803091A() callconv(.c) void {
    if (!abi.enter(0x0803091A)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[4] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            if (!abi.call(decls.func_0803081C, 0x08030903)) return;
            continue :blk 3;
        },
        2 => {
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
        3 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        4 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0803092C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[1] +% 0x7);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[2] = abi.read8(rt.r[1] +% 0x7);
            abi.write8(rt.r[1] +% 0x7, @truncate(rt.r[0]));
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x3, true);
            continue :blk 0;
        },
        else => unreachable,
    }
}

fn func_080309F0() callconv(.c) void {
    if (!abi.enter(0x080309F0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.r[2] = abi.read16(rt.r[0] +% 0x0);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x1, true);
            rt.r[0] = rt.r[8];
            abi.setRegNz(&rt.r[5], rt.r[5] & rt.r[0]);
            rt.r[0] = abi.read16(rt.r[7] +% 0x0);
            rt.cpuSub(null, rt.r[5], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], rt.r[6], true);
            if ((rt.CPU_N != rt.CPU_V)) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], rt.r[5] << 1);
            rt.r[0] +%= rt.r[12];
            rt.r[1] = abi.read16(rt.r[4] +% 0x0);
            continue :blk 0;
        },
        4 => {
            abi.fetches(3);
            rt.r[1] = abi.read32(0x08030A1C);
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
            abi.fetches(4);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[5]));
            rt.cpuAdd(&rt.r[0], rt.r[6], 0x0, true);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_08031F38() callconv(.c) void {
    if (!abi.enter(0x08031F38)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0802FED4, 0x08031F3F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(14);
            rt.r[2] = abi.read32(0x08031F5C);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[3] = abi.read8(rt.r[1] +% 0x6);
            abi.write8(rt.r[1] +% 0x6, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x6);
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_080333D0() callconv(.c) void {
    if (!abi.enter(0x080333D0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08033404);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x3);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1C);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080796A4, 0x080333E5)) return;
            continue :blk 5;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08033408);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x080333FD)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080112C0, 0x080333E9)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1C);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1C, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08033420() callconv(.c) void {
    if (!abi.enter(0x08033420)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(decls.func_080796A4, 0x08033429)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080112C0, 0x0803342D)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            rt.r[0] = abi.read16(rt.r[4] +% 0x1E);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if ((rt.CPU_N == rt.CPU_V)) {
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
            rt.r[0] = abi.read32(0x08033448);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x08033441)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08033464() callconv(.c) void {
    if (!abi.enter(0x08033464)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], 0x6C);
            if (!abi.call(decls.func_0803D880, 0x0803346D)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08033490);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x3, true);
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
            abi.fetches(9);
            rt.r[4] = abi.read32(0x08033494);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xC);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08032B34, 0x08033485)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08033498() callconv(.c) void {
    if (!abi.enter(0x08033498)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            pushRegs(&.{ 4, 14 });
            rt.r[0] = abi.read32(0x080334BC);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x3, true);
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
            rt.r[4] = abi.read32(0x080334C0);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[1], 0xD);
            abi.setRegNz(&rt.r[2], 0x0);
            if (!abi.call(decls.func_08032B34, 0x080334B3)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_080334C4() callconv(.c) void {
    if (!abi.enter(0x080334C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x080334E8);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x3, true);
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
            abi.fetches(11);
            rt.r[0] = abi.read8(rt.r[1] +% 0x1C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x5, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x080334EC);
            abi.setRegNz(&rt.r[2], 0xE5);
            abi.setRegNz(&rt.r[2], rt.r[2] << 3);
            if (!abi.call(decls.func_0801A7A4, 0x080334E5)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08033A28() callconv(.c) void {
    if (!abi.enter(0x08033A28)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x08033A44);
            rt.r[2] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x9);
            rt.r[0] = abi.read32(0x08033A48);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x7);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[1], 0x6);
            continue :blk 3;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[2], 0x2);
            if (!abi.call(decls.func_08032B34, 0x08033A57)) return;
            continue :blk 4;
        },
        4 => {
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

fn func_080347BC() callconv(.c) void {
    if (!abi.enter(0x080347BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.r[0] = abi.read32(0x080347D4);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(0x080347D8);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(func_080347EC, 0x080347E1)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x4, true);
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
            abi.fetches(4);
            if (!abi.call(func_0803482C, 0x080347E7)) return;
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

fn func_080347EC() callconv(.c) void {
    if (!abi.enter(0x080347EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_080349EC, 0x080347F3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0803481C);
            if (!abi.call(decls.func_08031C98, 0x080347F9)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
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
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(11);
            rt.r[1] = abi.read32(0x08034820);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08034824);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08034828);
            abi.setRegNz(&rt.r[0], 0x4);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0803482C() callconv(.c) void {
    if (!abi.enter(0x0803482C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_080349EC, 0x08034833)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080667A4, 0x08034837)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08034848);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0803484C);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08034850() callconv(.c) void {
    if (!abi.enter(0x08034850)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 6, 7, 14 });
            rt.cpuAdd(&rt.r[6], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[4], 0x0);
            abi.setRegNz(&rt.r[5], 0xF);
            rt.cpuAdd(&rt.r[3], rt.r[0], 0x0, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(16);
            rt.cpuAdd(&rt.r[2], rt.r[6], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[5], 0x0, true);
            rt.r[0] = abi.read8(rt.r[3] +% 0x0);
            abi.setRegNz(&rt.r[1], rt.r[1] & rt.r[0]);
            abi.setRegNz(&rt.r[1], rt.r[1] << 4);
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x0, true);
            rt.r[7] = abi.read8(rt.r[3] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[7]);
            abi.setRegNz(&rt.r[1], rt.r[1] | rt.r[0]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x2, true);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x5, true);
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

fn func_080348BC() callconv(.c) void {
    if (!abi.enter(0x080348BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x080348F0);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
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
            abi.fetches(17);
            rt.r[1] = abi.read32(0x080348F4);
            rt.r[2] = abi.read32(0x080348F8);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.write8(rt.r[1] +% 0x2, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0x2);
            abi.write8(rt.r[1] +% 0x3, @truncate(rt.r[0]));
            rt.r[2] = abi.read32(0x080348FC);
            rt.r[0] = abi.read16(rt.r[2] +% 0x0);
            abi.write8(rt.r[1] +% 0x4, @truncate(rt.r[0]));
            rt.r[0] = abi.read16(rt.r[2] +% 0x2);
            abi.write8(rt.r[1] +% 0x5, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08034900);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xC, true);
            if (!abi.call(func_08034850, 0x080348E5)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08034940() callconv(.c) void {
    if (!abi.enter(0x08034940)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(19);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x08034980);
            abi.setRegNz(&rt.r[1], 0xC);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            abi.write8(rt.r[2] +% 0x6, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x08034984);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[2] +% 0x7, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            abi.write8(rt.r[2] +% 0xC, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x2);
            abi.write8(rt.r[2] +% 0xD, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[3], 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            abi.setRegNz(&rt.r[0], 0xE);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[12] = rt.r[0];
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.r[4] = rt.r[12];
            abi.write8(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.r[12] +%= rt.r[0];
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0x3, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08031BA0, 0x0803497B)) return;
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

fn func_080349EC() callconv(.c) void {
    if (!abi.enter(0x080349EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_080212B8, 0x080349F3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021010, 0x080349F7)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08021398, 0x080349FB)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08034A18);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x3);
            if (!abi.call(decls.func_08026FC8, 0x08034A13)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08030D90, 0x08034A0D)) return;
            continue :blk 4;
        },
        6 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08034E1C() callconv(.c) void {
    if (!abi.enter(0x08034E1C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_08034CE4, 0x08034E23)) return;
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
            if (!abi.call(decls.func_080220F8, 0x08034E31)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0802C340, 0x08034E2D)) return;
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08016F0C, 0x08034E35)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x08034E40);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080350C0() callconv(.c) void {
    if (!abi.enter(0x080350C0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_0803D9B4, 0x080350C7)) return;
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080350D8);
            abi.setRegNz(&rt.r[0], 0xB);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08035170() callconv(.c) void {
    if (!abi.enter(0x08035170)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_08027F58, 0x08035177)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08035184);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(0x08035198);
            abi.setRegNz(&rt.r[0], 0x7);
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08035188);
            abi.setRegNz(&rt.r[0], 0x8);
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_080351C8() callconv(.c) void {
    if (!abi.enter(0x080351C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 14 });
            if (!abi.call(decls.func_0801833C, 0x080351CF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0x0, true);
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
            if (!abi.call(decls.func_08039EEC, 0x080351DB)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x080351E4);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[4]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_080351F4() callconv(.c) void {
    if (!abi.enter(0x080351F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x08035218);
            rt.r[0] = abi.read16(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[1] = abi.read32(0x0803521C);
            abi.setRegNz(&rt.r[0], 0x5);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08019A6C, 0x08035203)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035220, 0x08035207)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[4] +% 0x0, @truncate(rt.r[0]));
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08035388() callconv(.c) void {
    if (!abi.enter(0x08035388)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0x0, true);
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
            rt.r[0] = abi.read32(0x080353A4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035348, 0x080353A1)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08035454() callconv(.c) void {
    if (!abi.enter(0x08035454)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.r[4] = abi.read32(0x08035480);
            rt.cpuAdd(&rt.r[5], rt.r[4], 0x0, true);
            rt.cpuAdd(&rt.r[5], rt.r[5], 0x2E, true);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            if (!abi.call(func_08035388, 0x08035463)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x2C, true);
            rt.r[4] = abi.read8(rt.r[4] +% 0x0);
            rt.r[0] = abi.read8(rt.r[5] +% 0x0);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
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
            rt.r[0] = abi.read32(0x08035484);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08035475)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            rt.r[1] = abi.read8(rt.r[5] +% 0x0);
            abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[1]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_080357D8() callconv(.c) void {
    if (!abi.enter(0x080357D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[0] = abi.read32(0x080357F0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2C, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035518, 0x080357F9)) return;
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
            abi.fetches(3);
            continue :blk 5;
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
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        6 => {
            abi.fetches(3);
            continue :blk 5;
        },
        7 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08035648, 0x080357FF)) return;
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_08035A54() callconv(.c) void {
    if (!abi.enter(0x08035A54)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x08035A74);
            rt.r[0] = abi.read8(rt.r[0] +% 0x9);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.r[0] = abi.read32(0x08035A78);
            abi.setRegNz(&rt.r[1], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            rt.r[1] = abi.read16(rt.r[1] +% 0x18);
            abi.setRegNz(&rt.r[0], rt.r[1] << 17);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            continue :blk 3;
        },
        2 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08035A8C);
            abi.setRegNz(&rt.r[1], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[2], 0x18);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_08035E38() callconv(.c) void {
    if (!abi.enter(0x08035E38)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08035E60);
            rt.r[2] = abi.read8(rt.r[4] +% 0x9);
            abi.setRegNz(&rt.r[1], rt.r[2] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            rt.r[1] = abi.read16(rt.r[1] +% 0x1E);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08035DD0, 0x08035E6F)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08035E64);
            if (!abi.call(decls.func_0801329C, 0x08035E59)) return;
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
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08035DD0, 0x08035E5F)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08035F58() callconv(.c) void {
    if (!abi.enter(0x08035F58)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            abi.pushLr();
            rt.cpuAdd(&rt.r[2], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x08035F7C);
            rt.r[3] = abi.read8(rt.r[2] +% 0x9);
            abi.setRegNz(&rt.r[1], rt.r[3] << 3);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[3], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 8);
            rt.r[1] = abi.read16(rt.r[1] +% 0x1E);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
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
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08035DD0, 0x08035F79)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_080361D4() callconv(.c) void {
    if (!abi.enter(0x080361D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x08036200);
            rt.r[0] = abi.read32(0x08036204);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x18, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08026A1C, 0x080361EF)) return;
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
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write8(rt.r[4] +% 0x8, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08036208() callconv(.c) void {
    if (!abi.enter(0x08036208)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(16);
            pushRegs(&.{ 4, 14 });
            rt.r[2] = abi.read32(0x0803623C);
            rt.r[0] = abi.read32(0x08036240);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[1] = rt.sext16(abi.read16(rt.r[0] +% rt.r[3]));
            abi.setRegNz(&rt.r[0], rt.r[1] << 1);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 5);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x18, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[2], true);
            rt.r[4] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036244);
            if (!abi.call(decls.func_08013B70, 0x08036225)) return;
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
            abi.setRegNz(&rt.r[0], 0x2);
            abi.write8(rt.r[4] +% 0x8, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08036720() callconv(.c) void {
    if (!abi.enter(0x08036720)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.r[0] = abi.read32(0x0803674C);
            if (!abi.call(decls.func_08013B70, 0x0803672B)) return;
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
            abi.fetches(5);
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[2] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[1], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_08036750, 0x08036745)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08036844() callconv(.c) void {
    if (!abi.enter(0x08036844)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(15);
            abi.pushLr();
            rt.r[1] = abi.read32(0x08036878);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
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
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            if (!abi.call(decls.func_08036880, 0x0803686D)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0xF9);
            rt.r[3] = abi.read8(rt.r[1] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[3]);
            abi.write8(rt.r[1] +% 0x1, @truncate(rt.r[0]));
            continue :blk 1;
        },
        3 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0803687C);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08036984() callconv(.c) void {
    if (!abi.enter(0x08036984)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036998);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x0803699C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080369AC);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080369A0);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
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
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08036A34() callconv(.c) void {
    if (!abi.enter(0x08036A34)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08036A48);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08036A4C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036A5C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08036A50);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
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
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08036C64() callconv(.c) void {
    if (!abi.enter(0x08036C64)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[2] = abi.read32(0x08036C88);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read32(0x08036C8C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.r[0] = abi.read32(0x08036C94);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (!rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036C90);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        3 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08036C90);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_08037078() callconv(.c) void {
    if (!abi.enter(0x08037078)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0803708C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037090);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x080370A0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08037094);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
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
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08037630() callconv(.c) void {
    if (!abi.enter(0x08037630)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037644);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            rt.r[0] = abi.read32(0x08037648);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037658);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0803764C);
            rt.cpuSub(null, rt.r[1], rt.r[0], true);
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
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_080376D4() callconv(.c) void {
    if (!abi.enter(0x080376D4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080376F8);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xF8);
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
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], 0x7);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x8);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080376FC);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803776C() callconv(.c) void {
    if (!abi.enter(0x0803776C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x08037780);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[3], 0x1);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read32(0x08037794);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
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

fn func_08037798() callconv(.c) void {
    if (!abi.enter(0x08037798)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080377AC);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            abi.setRegNz(&rt.r[0], 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080377C0);
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

fn func_080377C4() callconv(.c) void {
    if (!abi.enter(0x080377C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x080377D8);
            rt.r[2] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read8(rt.r[2] +% 0x0);
            abi.setRegNz(&rt.r[0], 0xFC);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[1] = abi.read32(0x080377F0);
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

fn func_080378D8() callconv(.c) void {
    if (!abi.enter(0x080378D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_0801C07C, 0x080378E1)) return;
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
            abi.fetches(8);
            rt.r[0] = abi.read32(0x08037900);
            abi.setRegNz(&rt.r[1], 0x1);
            abi.write32(rt.r[0] +% 0x0, rt.r[1]);
            rt.r[0] = abi.read32(0x08037904);
            if (!abi.call(decls.func_080183C0, 0x080378F7)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08018CB4, 0x080378FB)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        6 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        else => unreachable,
    }
}

fn func_08037918() callconv(.c) void {
    if (!abi.enter(0x08037918)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], 0x1);
            if (!abi.call(decls.func_0801C07C, 0x08037921)) return;
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
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08037938);
            if (!abi.call(decls.func_080183C0, 0x0803792D)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0803793C);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08037A8C() callconv(.c) void {
    if (!abi.enter(0x08037A8C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037AA8);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x21, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08037AC4);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xA, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08037AAC);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xE, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037AC8);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        5 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08037AB0);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_08037B0C() callconv(.c) void {
    if (!abi.enter(0x08037B0C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x08037B28);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x21, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08037B44);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0xC, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08037B2C);
            rt.r[0] = abi.read16(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x10, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 4;
            }
            continue :blk 5;
        },
        3 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08037B48);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 4;
        },
        4 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        5 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x08037B30);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write32(rt.r[1] +% 0x0, rt.r[0]);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_080386B4() callconv(.c) void {
    if (!abi.enter(0x080386B4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_080385CC, 0x080386BB)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080386D0);
            if (!abi.call(decls.func_0803826C, 0x080386C1)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x080386D4);
            if (!abi.call(decls.func_08038260, 0x080386C7)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08052368, 0x080386CB)) return;
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

fn func_08038BF4() callconv(.c) void {
    if (!abi.enter(0x08038BF4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08038C18);
            if (!abi.call(decls.func_08013B70, 0x08038BFD)) return;
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
            rt.r[0] = abi.read32(0x08038C1C);
            if (!abi.call(decls.func_0803826C, 0x08038C0F)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08038C20);
            if (!abi.call(decls.func_08038260, 0x08038C15)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_08038EBC() callconv(.c) void {
    if (!abi.enter(0x08038EBC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[3] = abi.read32(0x08038EF0);
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x4, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x60, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0xD, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x36, true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], 0xD);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08038EF4() callconv(.c) void {
    if (!abi.enter(0x08038EF4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[3] = abi.read32(0x08038F28);
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x4, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x60, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x21, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x36, true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], 0xD);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08038F2C() callconv(.c) void {
    if (!abi.enter(0x08038F2C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[3] = abi.read32(0x08038F60);
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x4, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x5E, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x36, true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], 0x5E);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08038F64() callconv(.c) void {
    if (!abi.enter(0x08038F64)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[1], 0x0);
            rt.r[3] = abi.read32(0x08038F98);
            rt.cpuAdd(&rt.r[4], rt.r[3], 0x4, true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuAdd(&rt.r[2], rt.r[0], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x5E, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(12);
            rt.cpuAdd(&rt.r[1], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x36, true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], 0x5E);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08039C60() callconv(.c) void {
    if (!abi.enter(0x08039C60)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08039C8C);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[1] = abi.read32(0x08039C90);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.setRegNz(&rt.r[1], 0x80);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(0x08039CA8);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08039C94);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803A664, 0x08039C7F)) return;
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
            abi.fetches(5);
            rt.r[1] = abi.read32(0x08039C98);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0803A244() callconv(.c) void {
    if (!abi.enter(0x0803A244)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_08034B50, 0x0803A24B)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(7);
            rt.r[0] = abi.read32(0x0803A25C);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803E39C, 0x0803A265)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803DB6C, 0x0803A259)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803DB6C, 0x0803A269)) return;
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            continue :blk 7;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_080320E4, 0x0803A26D)) return;
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

fn func_0803A2E8() callconv(.c) void {
    if (!abi.enter(0x0803A2E8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            rt.r[1] = abi.read32(0x0803A314);
            abi.setRegNz(&rt.r[2], 0x1);
            rt.r[0] = abi.read32(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.cpuSub(&rt.r[0], rt.r[2], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.recompReturn(rt.r[14]); return;
        },
        2 => {
            abi.fetches(3);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            continue :blk 3;
        },
        3 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[1], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[0], rt.r[1] << 3);
            rt.cpuSub(&rt.r[0], rt.r[0], rt.r[1], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803A318() callconv(.c) void {
    if (!abi.enter(0x0803A318)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[2] = abi.read32(0x0803A334);
            abi.setRegNz(&rt.r[1], rt.r[0] << 3);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x7);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read8(rt.r[0] +% 0x0);
            continue :blk 5;
        },
        3 => {
            abi.fetches(3);
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.r[3] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 5;
        },
        5 => {
            abi.fetches(4);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_0803A354() callconv(.c) void {
    if (!abi.enter(0x0803A354)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[2] = abi.read32(0x0803A370);
            abi.setRegNz(&rt.r[1], rt.r[0] << 3);
            rt.cpuSub(&rt.r[1], rt.r[1], rt.r[0], true);
            abi.setRegNz(&rt.r[1], rt.r[1] << 2);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x7);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x4, true);
            if (rt.CPU_Z) {
                continue :blk 4;
            }
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            continue :blk 5;
        },
        3 => {
            abi.fetches(3);
            continue :blk 5;
        },
        4 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x8, true);
            rt.cpuAdd(&rt.r[0], rt.r[1], rt.r[0], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            abi.write32(rt.r[0] +% 0x0, rt.r[3]);
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_0803A61C() callconv(.c) void {
    if (!abi.enter(0x0803A61C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(13);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0803A648);
            rt.r[0] = abi.read32(rt.r[1] +% 0x14);
            abi.write32(rt.r[1] +% 0x18, rt.r[0]);
            abi.write32(rt.r[1] +% 0x1C, rt.r[0]);
            abi.write32(rt.r[1] +% 0x20, rt.r[0]);
            rt.cpuAdd(&rt.r[2], rt.r[1], 0x0, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x2C, true);
            rt.r[0] = abi.read8(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x3, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x0803A64C);
            if (!abi.call(decls.func_0801329C, 0x0803A643)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x2D, true);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
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

fn func_0803B3DC() callconv(.c) void {
    if (!abi.enter(0x0803B3DC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            if (!abi.call(decls.func_0803B3A8, 0x0803B3E5)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[1], 0x1E);
            rt.r[0] = rt.sext16(abi.read16(rt.r[4] +% rt.r[1]));
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
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write16(rt.r[4] +% 0x1E, @truncate(rt.r[0]));
            abi.write32(rt.r[4] +% 0x8, rt.r[0]);
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0803B3F8() callconv(.c) void {
    if (!abi.enter(0x0803B3F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.r[0] = abi.read16(rt.r[1] +% 0x20);
            rt.cpuSub(&rt.r[0], rt.r[0], 0x8, true);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            rt.cpuSub(null, rt.r[0], 0x81, true);
            if ((!rt.CPU_Z and rt.CPU_N == rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            if (!abi.call(decls.func_0803B3A8, 0x0803B419)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], 0x82);
            abi.write16(rt.r[1] +% 0x20, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write32(rt.r[1] +% 0x8, rt.r[0]);
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

fn func_0803BC0C() callconv(.c) void {
    if (!abi.enter(0x0803BC0C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0803BC24);
            rt.r[0] = abi.read16(rt.r[0] +% 0x1C);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], rt.r[1], true);
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
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803BC28);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0803BC21)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803D450() callconv(.c) void {
    if (!abi.enter(0x0803D450)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0800F894, 0x0803D457)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[0] = abi.read32(0x0803D474);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
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
            abi.fetches(4);
            if (!abi.call(decls.func_0803D2B0, 0x0803D46B)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(0x0803D478);
            abi.setRegNz(&rt.r[0], 0x1);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0803D4FC() callconv(.c) void {
    if (!abi.enter(0x0803D4FC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0803D52C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x9);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08010A84, 0x0803D51F)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x71);
            if (!abi.call(decls.func_0803D880, 0x0803D513)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(7);
            rt.r[2] = abi.read32(0x0803D534);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.setRegNz(&rt.r[1], 0x98);
            if (!abi.call(decls.func_0800FADC, 0x0803D529)) return;
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803D530);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0803D51B)) return;
            continue :blk 1;
        },
        5 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0803D890() callconv(.c) void {
    if (!abi.enter(0x0803D890)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 16);
            rt.r[0] = abi.read32(0x0803D8A8);
            rt.r[0] = abi.read8(rt.r[0] +% 0xC);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0803D8BC);
            abi.write16(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[1] = abi.read32(0x0803D8C0);
            rt.r[2] = abi.read32(0x0803D8C4);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            abi.write16(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
            if (!abi.call(decls.func_0803D8C8, 0x0803D8A7)) return;
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

fn func_0803D988() callconv(.c) void {
    if (!abi.enter(0x0803D988)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0803D9A8);
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
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803D9AC);
            abi.setRegNz(&rt.r[1], 0x2);
            if (!abi.call(decls.func_08078488, 0x0803D99B)) return;
            continue :blk 3;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803D9B0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x0803D9A3)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803D9B4() callconv(.c) void {
    if (!abi.enter(0x0803D9B4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0803D9CC);
            if (!abi.call(decls.func_08013B70, 0x0803D9BD)) return;
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_0803D9D8() callconv(.c) void {
    if (!abi.enter(0x0803D9D8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0803D9F0);
            rt.r[0] = abi.read32(0x0803D9F4);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
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
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(decls.func_0803D8C8, 0x0803D9ED)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803D9F8() callconv(.c) void {
    if (!abi.enter(0x0803D9F8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.pushLr();
            rt.r[1] = abi.read32(0x0803DA10);
            rt.r[0] = abi.read32(0x0803DA14);
            rt.r[2] = abi.read16(rt.r[1] +% 0x0);
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
            abi.fetches(6);
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[0] = rt.sext16(abi.read16(rt.r[1] +% rt.r[2]));
            if (!abi.call(func_0803D890, 0x0803DA0D)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803DB50() callconv(.c) void {
    if (!abi.enter(0x0803DB50)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], 0x15);
            if (!abi.call(decls.func_0803E244, 0x0803DB59)) return;
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
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x15);
            if (!abi.call(decls.func_0803E280, 0x0803DB65)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803E2F0, 0x0803DB69)) return;
            continue :blk 2;
        },
        else => unreachable,
    }
}

fn func_0803DC6C() callconv(.c) void {
    if (!abi.enter(0x0803DC6C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0803DC84);
            rt.r[0] = abi.read8(rt.r[0] +% 0x3);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803DC44, 0x0803DC8D)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x4);
            if (!abi.call(decls.func_08016918, 0x0803DC81)) return;
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

fn func_0803DC90() callconv(.c) void {
    if (!abi.enter(0x0803DC90)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0803DCB0);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803DE28, 0x0803DCB9)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_08015E3C, 0x0803DCA5)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            if (!abi.call(decls.func_08016918, 0x0803DCAF)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0803DCF8() callconv(.c) void {
    if (!abi.enter(0x0803DCF8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0803DD18);
            rt.r[0] = abi.read8(rt.r[0] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803DE0C, 0x0803DD21)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x2);
            if (!abi.call(decls.func_08015E3C, 0x0803DD0D)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        4 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 8));
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            if (!abi.call(decls.func_08016918, 0x0803DD17)) return;
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0803DE60() callconv(.c) void {
    if (!abi.enter(0x0803DE60)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(18);
            pushRegs(&.{ 4, 14 });
            rt.r[3] = abi.read32(0x0803DE94);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x21, true);
            abi.setRegNz(&rt.r[2], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            rt.r[0] = abi.read32(rt.r[3] +% 0x24);
            rt.r[1] = abi.read32(0x0803DE98);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            abi.write32(rt.r[3] +% 0x24, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x24, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[2]));
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(func_0803EF74, 0x0803DE89)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[4], rt.r[4], 0x1, true);
            rt.cpuSub(null, rt.r[4], 0x12, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
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

fn func_0803DE9C() callconv(.c) void {
    if (!abi.enter(0x0803DE9C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0803F064, 0x0803DEA5)) return;
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
            abi.fetches(9);
            rt.r[0] = abi.read32(0x0803DEBC);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x4);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803DEC8() callconv(.c) void {
    if (!abi.enter(0x0803DEC8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_0803DE60, 0x0803DECF)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(func_0803DE9C, 0x0803DED3)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x0803DEFC);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x21, true);
            continue :blk 5;
        },
        4 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803DEE4);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x21, true);
            abi.setRegNz(&rt.r[1], 0x1);
            continue :blk 5;
        },
        5 => {
            abi.fetches(5);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            if (!abi.call(decls.func_08015FF0, 0x0803DEF3)) return;
            continue :blk 6;
        },
        6 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803DF00, 0x0803DEF7)) return;
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

fn func_0803DF40() callconv(.c) void {
    if (!abi.enter(0x0803DF40)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803E008, 0x0803DF47)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x2, true);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
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

fn func_0803DF58() callconv(.c) void {
    if (!abi.enter(0x0803DF58)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803DFA0, 0x0803DF5F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x2, true);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
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

fn func_0803DF70() callconv(.c) void {
    if (!abi.enter(0x0803DF70)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_0803DFB8, 0x0803DF77)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x2, true);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
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

fn func_0803DF88() callconv(.c) void {
    if (!abi.enter(0x0803DF88)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(func_0803DFE0, 0x0803DF8F)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0x2, true);
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
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
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

fn func_0803DFB8() callconv(.c) void {
    if (!abi.enter(0x0803DFB8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803DFC4);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0803DFD8);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
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
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 5;
        },
        4 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 5;
        },
        5 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_0803DFE0() callconv(.c) void {
    if (!abi.enter(0x0803DFE0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803DFEC);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x1, true);
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
            abi.fetches(8);
            rt.r[0] = abi.read32(0x0803E000);
            rt.r[0] = abi.read8(rt.r[0] +% 0x2);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
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
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x2);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0803E038() callconv(.c) void {
    if (!abi.enter(0x0803E038)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], 0x6);
            if (!abi.call(decls.func_0803F064, 0x0803E041)) return;
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
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803E054);
            rt.r[0] = abi.read32(rt.r[0] +% 0x14);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 5;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803E3BC() callconv(.c) void {
    if (!abi.enter(0x0803E3BC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(6);
            rt.r[2] = abi.read32(0x0803E3FC);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.setRegNz(&rt.r[0], 0x3);
            abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(27);
            abi.setRegNz(&rt.r[3], 0x1);
            abi.write8(rt.r[2] +% 0xD, @truncate(rt.r[3]));
            abi.write8(rt.r[2] +% 0x7, @truncate(rt.r[3]));
            abi.write8(rt.r[2] +% 0x8, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x31, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.write8(rt.r[2] +% 0x9, @truncate(rt.r[3]));
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_0803E3C4() callconv(.c) void {
    if (!abi.enter(0x0803E3C4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(27);
            abi.setRegNz(&rt.r[3], 0x1);
            abi.write8(rt.r[2] +% 0xD, @truncate(rt.r[3]));
            abi.write8(rt.r[2] +% 0x7, @truncate(rt.r[3]));
            abi.write8(rt.r[2] +% 0x8, @truncate(rt.r[3]));
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2D, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[3]));
            rt.cpuSub(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x2, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            abi.setRegNz(&rt.r[0], 0xFA);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            abi.write32(rt.r[2] +% 0x28, rt.r[0]);
            rt.cpuAdd(&rt.r[0], rt.r[2], 0x0, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x31, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(3);
            abi.write8(rt.r[2] +% 0x9, @truncate(rt.r[3]));
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_0803E960() callconv(.c) void {
    if (!abi.enter(0x0803E960)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803EFE8, 0x0803E967)) return;
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
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_0803E978() callconv(.c) void {
    if (!abi.enter(0x0803E978)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803EFE8, 0x0803E97F)) return;
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
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_0803EA50() callconv(.c) void {
    if (!abi.enter(0x0803EA50)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            rt.r[0] = abi.read32(0x0803EA60);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x0);
            if (!abi.call(decls.func_0803F064, 0x0803EA6B)) return;
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
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        6 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803EA7C() callconv(.c) void {
    if (!abi.enter(0x0803EA7C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803F014, 0x0803EA83)) return;
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
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_0803EB04() callconv(.c) void {
    if (!abi.enter(0x0803EB04)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803F02C, 0x0803EB0B)) return;
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
            rt.r[0] = abi.read32(0x0803EB24);
            rt.r[0] = abi.read8(rt.r[0] +% 0x1D);
            rt.cpuSub(null, rt.r[0], 0x2, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 5;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 6;
        },
        4 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 6;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_0803EC38() callconv(.c) void {
    if (!abi.enter(0x0803EC38)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            abi.pushLr();
            if (!abi.call(decls.func_0803F048, 0x0803EC3F)) return;
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
            abi.setRegNz(&rt.r[0], 0x1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_0803ED10() callconv(.c) void {
    if (!abi.enter(0x0803ED10)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[2] = abi.read32(0x0803ED20);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.r[1] = abi.read32(rt.r[2] +% 0x0);
            rt.cpuSub(null, rt.r[1], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
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
            abi.write32(rt.r[2] +% 0x0, rt.r[0]);
            rt.r[0] = abi.read8(rt.r[2] +% 0x4);
            continue :blk 6;
        },
        4 => {
            abi.fetches(5);
            rt.r[0] = abi.read8(rt.r[2] +% 0x4);
            rt.cpuSub(null, rt.r[0], 0x1, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
                continue :blk 7;
            }
            continue :blk 6;
        },
        5 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x8, true);
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x1, true);
            rt.cpuSub(null, rt.r[3], 0xF, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
                continue :blk 1;
            }
            continue :blk 7;
        },
        6 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.write8(rt.r[2] +% 0x4, @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 8;
        },
        7 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x0);
            continue :blk 8;
        },
        8 => {
            abi.fetches(3);
            rt.recompReturn(rt.r[14]); return;
        },
        else => unreachable,
    }
}

fn func_0803EF74() callconv(.c) void {
    if (!abi.enter(0x0803EF74)) return;
    abi.fetches(22);
    pushRegs(&.{ 4, 14 });
    abi.setRegNz(&rt.r[1], rt.r[1] << 24);
    abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
    rt.r[2] = abi.read32(0x0803EF9C);
    abi.setRegNz(&rt.r[3], rt.r[0] >> 3);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x1D, true);
    rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[2], true);
    abi.setRegNz(&rt.r[2], 0x7);
    abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
    abi.setRegNz(&rt.r[0], 0x1);
    abi.setRegNz(&rt.r[0], rt.armLsl(rt.r[0], rt.r[2] & 0xFF));
    rt.r[4] = abi.read8(rt.r[3] +% 0x0);
    abi.setRegNz(&rt.r[4], rt.r[4] & ~rt.r[0]);
    rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
    abi.setRegNz(&rt.r[1], rt.armLsl(rt.r[1], rt.r[2] & 0xFF));
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
    popRegsSeq(&.{ 4 });
    popRegsSeq(&.{ 0 });
    rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
}

fn func_0803EFA0() callconv(.c) void {
    if (!abi.enter(0x0803EFA0)) return;
    abi.fetches(22);
    pushRegs(&.{ 4, 14 });
    abi.setRegNz(&rt.r[1], rt.r[1] << 24);
    abi.setRegNz(&rt.r[1], rt.r[1] >> 24);
    rt.r[2] = abi.read32(0x0803EFC8);
    abi.setRegNz(&rt.r[3], rt.r[0] >> 3);
    rt.cpuAdd(&rt.r[2], rt.r[2], 0x21, true);
    rt.cpuAdd(&rt.r[3], rt.r[3], rt.r[2], true);
    abi.setRegNz(&rt.r[2], 0x7);
    abi.setRegNz(&rt.r[2], rt.r[2] & rt.r[0]);
    abi.setRegNz(&rt.r[0], 0x1);
    abi.setRegNz(&rt.r[0], rt.armLsl(rt.r[0], rt.r[2] & 0xFF));
    rt.r[4] = abi.read8(rt.r[3] +% 0x0);
    abi.setRegNz(&rt.r[4], rt.r[4] & ~rt.r[0]);
    rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
    abi.setRegNz(&rt.r[1], rt.armLsl(rt.r[1], rt.r[2] & 0xFF));
    abi.setRegNz(&rt.r[0], rt.r[0] | rt.r[1]);
    abi.write8(rt.r[3] +% 0x0, @truncate(rt.r[0]));
    popRegsSeq(&.{ 4 });
    popRegsSeq(&.{ 0 });
    rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
}

fn func_0803F080() callconv(.c) void {
    if (!abi.enter(0x0803F080)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuSub(&rt.r[1], rt.r[1], 0xA4, true);
            abi.setRegNz(&rt.r[0], rt.r[1] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[0], 0xB, true);
            if ((rt.CPU_C and !rt.CPU_Z)) {
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
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[1], 0x3);
            if (!abi.call(decls.func_080796C8, 0x0803F09B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        4 => {
            abi.fetches(6);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_0803F0A8() callconv(.c) void {
    if (!abi.enter(0x0803F0A8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 16);
            if (!abi.call(decls.func_08022814, 0x0803F0B3)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[0], 0xFF, true);
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
            abi.fetches(4);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 5;
            }
            continue :blk 2;
        },
        4 => {
            abi.fetches(4);
            popRegsSeq(&.{ 1 });
            rt.r[15] = rt.r[1]; rt.recompReturn(rt.r[1]); return;
        },
        5 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
            continue :blk 4;
        },
        else => unreachable,
    }
}

fn func_0803F0C8() callconv(.c) void {
    if (!abi.enter(0x0803F0C8)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[3], 0x0);
            rt.r[0] = abi.read8(rt.r[4] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[3], true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        2 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[2], rt.r[5], rt.r[3], true);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803F0E6() callconv(.c) void {
    if (!abi.enter(0x0803F0E6)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[0], rt.r[4], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(10);
            rt.cpuAdd(&rt.r[2], rt.r[5], rt.r[3], true);
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[3], true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[2] +% 0x0, @truncate(rt.r[0]));
            rt.r[0] = abi.read8(rt.r[1] +% 0x1);
            abi.write8(rt.r[2] +% 0x1, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            continue :blk 0;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[1], rt.r[5], rt.r[3], true);
            abi.setRegNz(&rt.r[0], 0x0);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_0803F0FC() callconv(.c) void {
    if (!abi.enter(0x0803F0FC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.cpuAdd(&rt.r[3], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            rt.r[1] = abi.read32(0x0803F11C);
            abi.setRegNz(&rt.r[2], rt.r[0] >> 19);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[1], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x15);
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
            abi.fetches(7);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.cpuAdd(&rt.r[1], rt.r[2], rt.r[1], true);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x0, true);
            if (!abi.call(func_0803F0C8, 0x0803F119)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
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

fn func_0803F314() callconv(.c) void {
    if (!abi.enter(0x0803F314)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            pushRegs(&.{ 4, 14 });
            rt.cpuAdd(&rt.r[4], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[1], rt.r[0] >> 24);
            rt.r[0] = abi.read32(0x0803F340);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x32, true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (!rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(0x0803F344);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803F6D8, 0x0803F33B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(8);
            rt.cpuAdd(&rt.r[0], rt.r[1], 0x5, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.r[1] = abi.read32(0x0803F344);
            if (!abi.call(decls.func_0801AC1C, 0x0803F333)) return;
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

fn func_0803F5FE() callconv(.c) void {
    if (!abi.enter(0x0803F5FE)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(8);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[0]));
            rt.cpuAdd(&rt.r[0], rt.r[5], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[5], rt.r[0] >> 16);
            rt.cpuSub(null, rt.r[5], 0x4, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(10);
            rt.r[13] +%= 0x2C;
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
            rt.cpuAdd(&rt.r[1], rt.r[4], rt.r[5], true);
            rt.cpuAdd(&rt.r[0], rt.r[5], rt.r[2], true);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            continue :blk 0;
        },
        else => unreachable,
    }
}

fn func_0803F87C() callconv(.c) void {
    if (!abi.enter(0x0803F87C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(5);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x0, true);
            if (!abi.call(decls.func_0803F898, 0x0803F887)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(7);
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], 0xB, true);
            if ((!rt.CPU_C or rt.CPU_Z)) {
                continue :blk 1;
            }
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

fn func_0803F8F2() callconv(.c) void {
    if (!abi.enter(0x0803F8F2)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(3);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            continue :blk 1;
        },
        1 => {
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
            continue :blk 2;
        },
        2 => {
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
                continue :blk 2;
            }
            continue :blk 3;
        },
        3 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_0803F8F4() callconv(.c) void {
    if (!abi.enter(0x0803F8F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
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
            continue :blk 1;
        },
        1 => {
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
                continue :blk 1;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(3);
            abi.setRegNz(&rt.r[0], 0x1);
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

fn func_0803FB18() callconv(.c) void {
    if (!abi.enter(0x0803FB18)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 5, 14 });
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[5] = abi.read32(0x0803FB3C);
            rt.r[4] = abi.read32(0x0803FB40);
            abi.setRegNz(&rt.r[3], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[5], true);
            rt.r[1] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[1], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x1A);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[3], rt.r[3], 0x68, true);
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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
        else => unreachable,
    }
}

fn func_0803FB44() callconv(.c) void {
    if (!abi.enter(0x0803FB44)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[2], 0x0);
            rt.r[4] = abi.read32(0x0803FB64);
            rt.r[1] = abi.read32(0x0803FB68);
            rt.cpuAdd(&rt.r[3], rt.r[0], rt.r[1], true);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.cpuAdd(&rt.r[0], rt.r[2], rt.r[4], true);
            rt.cpuAdd(&rt.r[1], rt.r[3], rt.r[2], true);
            rt.r[1] = abi.read8(rt.r[1] +% 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.cpuAdd(&rt.r[2], rt.r[2], 0x1, true);
            rt.cpuSub(null, rt.r[2], 0x4, true);
            if ((rt.CPU_Z or rt.CPU_N != rt.CPU_V)) {
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

fn func_0803FB6C() callconv(.c) void {
    if (!abi.enter(0x0803FB6C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(7);
            abi.pushLr();
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
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
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_08015E24, 0x0803FB81)) return;
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_0803FB84() callconv(.c) void {
    if (!abi.enter(0x0803FB84)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            pushRegs(&.{ 4, 5, 14 });
            rt.cpuAdd(&rt.r[5], rt.r[1], 0x0, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuAdd(&rt.r[4], rt.r[0], 0x0, true);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x0803FBB0);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x0803FBA5)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 24));
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_08015E24, 0x0803FB9D)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(7);
            abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[4]));
            abi.write32(rt.r[0] +% 0x18, rt.r[5]);
            popRegsSeq(&.{ 4, 5 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

fn func_08040022() callconv(.c) void {
    if (!abi.enter(0x08040022)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803FD1C, 0x08040027)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[1], true);
            abi.write8(rt.r[4] +% 0x1B, @truncate(rt.r[0]));
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

fn func_080400EC() callconv(.c) void {
    if (!abi.enter(0x080400EC)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            if (!abi.call(decls.func_0803FD1C, 0x080400F1)) return;
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            rt.r[1] = abi.read32(rt.r[5] +% 0x0);
            rt.cpuAdd(&rt.r[4], rt.r[4], rt.r[1], true);
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.write8(rt.r[4] +% 0x1D, @truncate(rt.r[0]));
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

fn func_080400F4() callconv(.c) void {
    if (!abi.enter(0x080400F4)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            abi.write8(rt.r[4] +% 0x1D, @truncate(rt.r[0]));
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08040160);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x3);
            rt.r[1] = abi.read16(rt.r[1] +% 0x4);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08025000, 0x08040147)) return;
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
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08040164);
            rt.r[0] = abi.read8(rt.r[0] +% 0x0);
            if (!abi.call(decls.func_08013BD0, 0x0804014F)) return;
            continue :blk 3;
        },
        else => unreachable,
    }
}

fn func_08040A3E() callconv(.c) void {
    if (!abi.enter(0x08040A3E)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(9);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            rt.r[13] -%= 0x190;
            abi.setRegNz(&rt.r[6], 0);
            rt.cpuAdd(&rt.r[0], rt.r[3], 0x4, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0xF4, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 12);
            continue :blk 1;
        },
        1 => {
            abi.fetches(9);
            rt.r[0] = abi.read32(0x08040A60);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            rt.cpuAdd(&rt.r[1], rt.r[0], 0x0, true);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x5E, true);
            rt.r[0] = abi.read8(rt.r[1] +% 0x0);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(4);
            abi.write8(rt.r[1] +% 0x0, @truncate(rt.r[2]));
            continue :blk 4;
        },
        3 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08040988, 0x08040A69)) return;
            continue :blk 4;
        },
        4 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08040328, 0x08040A6D)) return;
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

fn func_08040A74() callconv(.c) void {
    if (!abi.enter(0x08040A74)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(5);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[4], 0x0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08022800, 0x08040A8B)) return;
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 24);
            abi.setRegNz(&rt.r[0], rt.r[0] >> 24);
            rt.cpuSub(null, rt.r[4], rt.r[0], true);
            if (!rt.CPU_C) {
                continue :blk 3;
            }
            continue :blk 4;
        },
        3 => {
            abi.fetches(5);
            rt.r[0] = abi.read32(0x08040A98);
            if (!abi.call(decls.func_0801329C, 0x08040A81)) return;
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
            rt.cpuAdd(&rt.r[0], rt.r[4], 0x1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            continue :blk 1;
        },
        else => unreachable,
    }
}

fn func_08041F1C() callconv(.c) void {
    if (!abi.enter(0x08041F1C)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(4);
            pushRegs(&.{ 6, 14 });
            abi.setRegNz(&rt.r[6], 0);
            continue :blk 1;
        },
        1 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08041F3C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 3;
            }
            continue :blk 2;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08041F40);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08041F3B)) return;
            continue :blk 4;
        },
        3 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08041F50);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08041F4D)) return;
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

fn func_08041F20() callconv(.c) void {
    if (!abi.enter(0x08041F20)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(11);
            abi.pushLr();
            rt.r[0] = abi.read32(0x08041F3C);
            rt.r[1] = abi.read32(rt.r[0] +% 0x0);
            abi.setRegNz(&rt.r[0], 0x80);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.r[1] = abi.read16(rt.r[1] +% 0x0);
            abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[1]);
            rt.cpuSub(null, rt.r[0], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 2;
            }
            continue :blk 1;
        },
        1 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08041F40);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08041F3B)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(6);
            rt.r[0] = abi.read32(0x08041F50);
            abi.setRegNz(&rt.r[1], 0x0);
            if (!abi.call(decls.func_0801320C, 0x08041F4D)) return;
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

fn func_08042284() callconv(.c) void {
    if (!abi.enter(0x08042284)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[3], rt.r[0] >> 16);
            abi.setRegNz(&rt.r[1], rt.r[1] << 16);
            abi.setRegNz(&rt.r[4], rt.r[1] >> 16);
            abi.setRegNz(&rt.r[2], rt.r[2] << 24);
            rt.cpuSub(null, rt.r[2], 0x0, true);
            if (rt.CPU_Z) {
                continue :blk 1;
            }
            continue :blk 2;
        },
        1 => {
            abi.fetches(9);
            rt.r[1] = abi.read32(0x080422BC);
            abi.setRegNz(&rt.r[0], rt.r[3] << 3);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 2);
            rt.cpuAdd(&rt.r[1], rt.r[1], 0x4, true);
            rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[1], true);
            rt.r[0] = abi.read32(rt.r[0] +% 0x0);
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            rt.r[0] = abi.read32(0x08042298);
            continue :blk 3;
        },
        3 => {
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], rt.r[4] << 5);
            rt.r[2] = abi.read32(0x080422C0);
            rt.cpuAdd(&rt.r[1], rt.r[1], rt.r[2], true);
            if (!abi.call(decls.func_0800FE24, 0x080422B5)) return;
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

fn func_080438B0() callconv(.c) void {
    if (!abi.enter(0x080438B0)) return;
    blk: switch (@as(u32, 0)) {
        0 => {
            abi.fetches(10);
            pushRegs(&.{ 4, 14 });
            rt.r[4] = abi.read32(0x080438DC);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.r[1] = abi.read32(0x080438E0);
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
            if (!abi.call(decls.func_080226A4, 0x080438C9)) return;
            continue :blk 3;
        },
        2 => {
            abi.fetches(4);
            if (!abi.call(decls.func_08043780, 0x080438C5)) return;
            continue :blk 1;
        },
        3 => {
            abi.fetches(12);
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x41, true);
            abi.setRegNz(&rt.r[1], 0x0);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            rt.r[0] = abi.read32(rt.r[4] +% 0x0);
            rt.cpuAdd(&rt.r[0], rt.r[0], 0x42, true);
            abi.write8(rt.r[0] +% 0x0, @truncate(rt.r[1]));
            popRegsSeq(&.{ 4 });
            popRegsSeq(&.{ 0 });
            rt.r[15] = rt.r[0]; rt.recompReturn(rt.r[0]); return;
        },
        else => unreachable,
    }
}

comptime {
    if (!builtin.is_test) {
        @export(&func_080242DC, .{ .name = "func_080242DC", .linkage = .strong });
        @export(&func_080244FC, .{ .name = "func_080244FC", .linkage = .strong });
        @export(&func_08024884, .{ .name = "func_08024884", .linkage = .strong });
        @export(&func_080248AC, .{ .name = "func_080248AC", .linkage = .strong });
        @export(&func_08024B50, .{ .name = "func_08024B50", .linkage = .strong });
        @export(&func_08024B88, .{ .name = "func_08024B88", .linkage = .strong });
        @export(&func_08024BB0, .{ .name = "func_08024BB0", .linkage = .strong });
        @export(&func_08024CD0, .{ .name = "func_08024CD0", .linkage = .strong });
        @export(&func_08024CF8, .{ .name = "func_08024CF8", .linkage = .strong });
        @export(&func_08024D58, .{ .name = "func_08024D58", .linkage = .strong });
        @export(&func_08025138, .{ .name = "func_08025138", .linkage = .strong });
        @export(&func_08025194, .{ .name = "func_08025194", .linkage = .strong });
        @export(&func_080253D4, .{ .name = "func_080253D4", .linkage = .strong });
        @export(&func_08025410, .{ .name = "func_08025410", .linkage = .strong });
        @export(&func_0802544C, .{ .name = "func_0802544C", .linkage = .strong });
        @export(&func_08025484, .{ .name = "func_08025484", .linkage = .strong });
        @export(&func_080254BC, .{ .name = "func_080254BC", .linkage = .strong });
        @export(&func_08025508, .{ .name = "func_08025508", .linkage = .strong });
        @export(&func_08025540, .{ .name = "func_08025540", .linkage = .strong });
        @export(&func_080255C4, .{ .name = "func_080255C4", .linkage = .strong });
        @export(&func_080276E4, .{ .name = "func_080276E4", .linkage = .strong });
        @export(&func_08027F7C, .{ .name = "func_08027F7C", .linkage = .strong });
        @export(&func_08028400, .{ .name = "func_08028400", .linkage = .strong });
        @export(&func_0802877C, .{ .name = "func_0802877C", .linkage = .strong });
        @export(&func_08029B08, .{ .name = "func_08029B08", .linkage = .strong });
        @export(&func_0802BF70, .{ .name = "func_0802BF70", .linkage = .strong });
        @export(&func_0802C574, .{ .name = "func_0802C574", .linkage = .strong });
        @export(&func_0802C5E0, .{ .name = "func_0802C5E0", .linkage = .strong });
        @export(&func_0802C76C, .{ .name = "func_0802C76C", .linkage = .strong });
        @export(&func_0802C828, .{ .name = "func_0802C828", .linkage = .strong });
        @export(&func_0802C858, .{ .name = "func_0802C858", .linkage = .strong });
        @export(&func_0802C988, .{ .name = "func_0802C988", .linkage = .strong });
        @export(&func_0802D77C, .{ .name = "func_0802D77C", .linkage = .strong });
        @export(&func_0802D808, .{ .name = "func_0802D808", .linkage = .strong });
        @export(&func_0802D82C, .{ .name = "func_0802D82C", .linkage = .strong });
        @export(&func_0802D85C, .{ .name = "func_0802D85C", .linkage = .strong });
        @export(&func_0802D88C, .{ .name = "func_0802D88C", .linkage = .strong });
        @export(&func_0802D8BC, .{ .name = "func_0802D8BC", .linkage = .strong });
        @export(&func_0802D8EC, .{ .name = "func_0802D8EC", .linkage = .strong });
        @export(&func_0802D988, .{ .name = "func_0802D988", .linkage = .strong });
        @export(&func_0802D9AC, .{ .name = "func_0802D9AC", .linkage = .strong });
        @export(&func_0802DA30, .{ .name = "func_0802DA30", .linkage = .strong });
        @export(&func_0802DB18, .{ .name = "func_0802DB18", .linkage = .strong });
        @export(&func_0802DB58, .{ .name = "func_0802DB58", .linkage = .strong });
        @export(&func_0802DD5C, .{ .name = "func_0802DD5C", .linkage = .strong });
        @export(&func_0802DD84, .{ .name = "func_0802DD84", .linkage = .strong });
        @export(&func_0802DDC0, .{ .name = "func_0802DDC0", .linkage = .strong });
        @export(&func_0802DFB8, .{ .name = "func_0802DFB8", .linkage = .strong });
        @export(&func_0802E04C, .{ .name = "func_0802E04C", .linkage = .strong });
        @export(&func_0802E094, .{ .name = "func_0802E094", .linkage = .strong });
        @export(&func_0802E0B8, .{ .name = "func_0802E0B8", .linkage = .strong });
        @export(&func_0802E0E0, .{ .name = "func_0802E0E0", .linkage = .strong });
        @export(&func_0802E10C, .{ .name = "func_0802E10C", .linkage = .strong });
        @export(&func_0802E2B4, .{ .name = "func_0802E2B4", .linkage = .strong });
        @export(&func_0802E30C, .{ .name = "func_0802E30C", .linkage = .strong });
        @export(&func_0802E348, .{ .name = "func_0802E348", .linkage = .strong });
        @export(&func_0802E4E8, .{ .name = "func_0802E4E8", .linkage = .strong });
        @export(&func_0802E650, .{ .name = "func_0802E650", .linkage = .strong });
        @export(&func_0802EF2C, .{ .name = "func_0802EF2C", .linkage = .strong });
        @export(&func_0802F902, .{ .name = "func_0802F902", .linkage = .strong });
        @export(&func_0802FA08, .{ .name = "func_0802FA08", .linkage = .strong });
        @export(&func_0802FBF2, .{ .name = "func_0802FBF2", .linkage = .strong });
        @export(&func_0802FBFA, .{ .name = "func_0802FBFA", .linkage = .strong });
        @export(&func_0802FC00, .{ .name = "func_0802FC00", .linkage = .strong });
        @export(&func_0802FDD4, .{ .name = "func_0802FDD4", .linkage = .strong });
        @export(&func_0802FF0E, .{ .name = "func_0802FF0E", .linkage = .strong });
        @export(&func_0802FF12, .{ .name = "func_0802FF12", .linkage = .strong });
        @export(&func_08030064, .{ .name = "func_08030064", .linkage = .strong });
        @export(&func_080300AC, .{ .name = "func_080300AC", .linkage = .strong });
        @export(&func_0803083C, .{ .name = "func_0803083C", .linkage = .strong });
        @export(&func_0803091A, .{ .name = "func_0803091A", .linkage = .strong });
        @export(&func_080309F0, .{ .name = "func_080309F0", .linkage = .strong });
        @export(&func_08031F38, .{ .name = "func_08031F38", .linkage = .strong });
        @export(&func_080333D0, .{ .name = "func_080333D0", .linkage = .strong });
        @export(&func_08033420, .{ .name = "func_08033420", .linkage = .strong });
        @export(&func_08033464, .{ .name = "func_08033464", .linkage = .strong });
        @export(&func_08033498, .{ .name = "func_08033498", .linkage = .strong });
        @export(&func_080334C4, .{ .name = "func_080334C4", .linkage = .strong });
        @export(&func_08033A28, .{ .name = "func_08033A28", .linkage = .strong });
        @export(&func_080347BC, .{ .name = "func_080347BC", .linkage = .strong });
        @export(&func_080347EC, .{ .name = "func_080347EC", .linkage = .strong });
        @export(&func_0803482C, .{ .name = "func_0803482C", .linkage = .strong });
        @export(&func_08034850, .{ .name = "func_08034850", .linkage = .strong });
        @export(&func_080348BC, .{ .name = "func_080348BC", .linkage = .strong });
        @export(&func_08034940, .{ .name = "func_08034940", .linkage = .strong });
        @export(&func_080349EC, .{ .name = "func_080349EC", .linkage = .strong });
        @export(&func_08034E1C, .{ .name = "func_08034E1C", .linkage = .strong });
        @export(&func_080350C0, .{ .name = "func_080350C0", .linkage = .strong });
        @export(&func_08035170, .{ .name = "func_08035170", .linkage = .strong });
        @export(&func_080351C8, .{ .name = "func_080351C8", .linkage = .strong });
        @export(&func_080351F4, .{ .name = "func_080351F4", .linkage = .strong });
        @export(&func_08035388, .{ .name = "func_08035388", .linkage = .strong });
        @export(&func_08035454, .{ .name = "func_08035454", .linkage = .strong });
        @export(&func_080357D8, .{ .name = "func_080357D8", .linkage = .strong });
        @export(&func_08035A54, .{ .name = "func_08035A54", .linkage = .strong });
        @export(&func_08035E38, .{ .name = "func_08035E38", .linkage = .strong });
        @export(&func_08035F58, .{ .name = "func_08035F58", .linkage = .strong });
        @export(&func_080361D4, .{ .name = "func_080361D4", .linkage = .strong });
        @export(&func_08036208, .{ .name = "func_08036208", .linkage = .strong });
        @export(&func_08036720, .{ .name = "func_08036720", .linkage = .strong });
        @export(&func_08036844, .{ .name = "func_08036844", .linkage = .strong });
        @export(&func_08036984, .{ .name = "func_08036984", .linkage = .strong });
        @export(&func_08036A34, .{ .name = "func_08036A34", .linkage = .strong });
        @export(&func_08036C64, .{ .name = "func_08036C64", .linkage = .strong });
        @export(&func_08037078, .{ .name = "func_08037078", .linkage = .strong });
        @export(&func_08037630, .{ .name = "func_08037630", .linkage = .strong });
        @export(&func_080376D4, .{ .name = "func_080376D4", .linkage = .strong });
        @export(&func_0803776C, .{ .name = "func_0803776C", .linkage = .strong });
        @export(&func_08037798, .{ .name = "func_08037798", .linkage = .strong });
        @export(&func_080377C4, .{ .name = "func_080377C4", .linkage = .strong });
        @export(&func_080378D8, .{ .name = "func_080378D8", .linkage = .strong });
        @export(&func_08037918, .{ .name = "func_08037918", .linkage = .strong });
        @export(&func_08037A8C, .{ .name = "func_08037A8C", .linkage = .strong });
        @export(&func_08037B0C, .{ .name = "func_08037B0C", .linkage = .strong });
        @export(&func_080386B4, .{ .name = "func_080386B4", .linkage = .strong });
        @export(&func_08038BF4, .{ .name = "func_08038BF4", .linkage = .strong });
        @export(&func_08038EBC, .{ .name = "func_08038EBC", .linkage = .strong });
        @export(&func_08038EF4, .{ .name = "func_08038EF4", .linkage = .strong });
        @export(&func_08038F2C, .{ .name = "func_08038F2C", .linkage = .strong });
        @export(&func_08038F64, .{ .name = "func_08038F64", .linkage = .strong });
        @export(&func_08039C60, .{ .name = "func_08039C60", .linkage = .strong });
        @export(&func_0803A244, .{ .name = "func_0803A244", .linkage = .strong });
        @export(&func_0803A2E8, .{ .name = "func_0803A2E8", .linkage = .strong });
        @export(&func_0803A318, .{ .name = "func_0803A318", .linkage = .strong });
        @export(&func_0803A354, .{ .name = "func_0803A354", .linkage = .strong });
        @export(&func_0803A61C, .{ .name = "func_0803A61C", .linkage = .strong });
        @export(&func_0803B3DC, .{ .name = "func_0803B3DC", .linkage = .strong });
        @export(&func_0803B3F8, .{ .name = "func_0803B3F8", .linkage = .strong });
        @export(&func_0803BC0C, .{ .name = "func_0803BC0C", .linkage = .strong });
        @export(&func_0803D450, .{ .name = "func_0803D450", .linkage = .strong });
        @export(&func_0803D4FC, .{ .name = "func_0803D4FC", .linkage = .strong });
        @export(&func_0803D890, .{ .name = "func_0803D890", .linkage = .strong });
        @export(&func_0803D988, .{ .name = "func_0803D988", .linkage = .strong });
        @export(&func_0803D9B4, .{ .name = "func_0803D9B4", .linkage = .strong });
        @export(&func_0803D9D8, .{ .name = "func_0803D9D8", .linkage = .strong });
        @export(&func_0803D9F8, .{ .name = "func_0803D9F8", .linkage = .strong });
        @export(&func_0803DB50, .{ .name = "func_0803DB50", .linkage = .strong });
        @export(&func_0803DC6C, .{ .name = "func_0803DC6C", .linkage = .strong });
        @export(&func_0803DC90, .{ .name = "func_0803DC90", .linkage = .strong });
        @export(&func_0803DCF8, .{ .name = "func_0803DCF8", .linkage = .strong });
        @export(&func_0803DE60, .{ .name = "func_0803DE60", .linkage = .strong });
        @export(&func_0803DE9C, .{ .name = "func_0803DE9C", .linkage = .strong });
        @export(&func_0803DEC8, .{ .name = "func_0803DEC8", .linkage = .strong });
        @export(&func_0803DF40, .{ .name = "func_0803DF40", .linkage = .strong });
        @export(&func_0803DF58, .{ .name = "func_0803DF58", .linkage = .strong });
        @export(&func_0803DF70, .{ .name = "func_0803DF70", .linkage = .strong });
        @export(&func_0803DF88, .{ .name = "func_0803DF88", .linkage = .strong });
        @export(&func_0803DFB8, .{ .name = "func_0803DFB8", .linkage = .strong });
        @export(&func_0803DFE0, .{ .name = "func_0803DFE0", .linkage = .strong });
        @export(&func_0803E038, .{ .name = "func_0803E038", .linkage = .strong });
        @export(&func_0803E3BC, .{ .name = "func_0803E3BC", .linkage = .strong });
        @export(&func_0803E3C4, .{ .name = "func_0803E3C4", .linkage = .strong });
        @export(&func_0803E960, .{ .name = "func_0803E960", .linkage = .strong });
        @export(&func_0803E978, .{ .name = "func_0803E978", .linkage = .strong });
        @export(&func_0803EA50, .{ .name = "func_0803EA50", .linkage = .strong });
        @export(&func_0803EA7C, .{ .name = "func_0803EA7C", .linkage = .strong });
        @export(&func_0803EB04, .{ .name = "func_0803EB04", .linkage = .strong });
        @export(&func_0803EC38, .{ .name = "func_0803EC38", .linkage = .strong });
        @export(&func_0803ED10, .{ .name = "func_0803ED10", .linkage = .strong });
        @export(&func_0803EF74, .{ .name = "func_0803EF74", .linkage = .strong });
        @export(&func_0803EFA0, .{ .name = "func_0803EFA0", .linkage = .strong });
        @export(&func_0803F080, .{ .name = "func_0803F080", .linkage = .strong });
        @export(&func_0803F0A8, .{ .name = "func_0803F0A8", .linkage = .strong });
        @export(&func_0803F0C8, .{ .name = "func_0803F0C8", .linkage = .strong });
        @export(&func_0803F0E6, .{ .name = "func_0803F0E6", .linkage = .strong });
        @export(&func_0803F0FC, .{ .name = "func_0803F0FC", .linkage = .strong });
        @export(&func_0803F314, .{ .name = "func_0803F314", .linkage = .strong });
        @export(&func_0803F5FE, .{ .name = "func_0803F5FE", .linkage = .strong });
        @export(&func_0803F87C, .{ .name = "func_0803F87C", .linkage = .strong });
        @export(&func_0803F8F2, .{ .name = "func_0803F8F2", .linkage = .strong });
        @export(&func_0803F8F4, .{ .name = "func_0803F8F4", .linkage = .strong });
        @export(&func_0803FB18, .{ .name = "func_0803FB18", .linkage = .strong });
        @export(&func_0803FB44, .{ .name = "func_0803FB44", .linkage = .strong });
        @export(&func_0803FB6C, .{ .name = "func_0803FB6C", .linkage = .strong });
        @export(&func_0803FB84, .{ .name = "func_0803FB84", .linkage = .strong });
        @export(&func_08040022, .{ .name = "func_08040022", .linkage = .strong });
        @export(&func_080400EC, .{ .name = "func_080400EC", .linkage = .strong });
        @export(&func_080400F4, .{ .name = "func_080400F4", .linkage = .strong });
        @export(&func_08040A3E, .{ .name = "func_08040A3E", .linkage = .strong });
        @export(&func_08040A74, .{ .name = "func_08040A74", .linkage = .strong });
        @export(&func_08041F1C, .{ .name = "func_08041F1C", .linkage = .strong });
        @export(&func_08041F20, .{ .name = "func_08041F20", .linkage = .strong });
        @export(&func_08042284, .{ .name = "func_08042284", .linkage = .strong });
        @export(&func_080438B0, .{ .name = "func_080438B0", .linkage = .strong });
    }
}
