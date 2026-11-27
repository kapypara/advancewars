//! Lifted core math, PRNG, and trig utility functions for Advance Wars.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");

/// Advance the Advance Wars 32-bit PRNG state: `((4*s + 2) * (4*s + 3)) >> 2`.
pub fn nextRngSeed(seed: u32) u32 {
    const scaled = seed << 2;
    return ((scaled +% 2) *% (scaled +% 3)) >> 2;
}

/// Advance global PRNG seed stored at `[0x08010A98]` and return new value (`0x08010A84`).
pub fn advanceRng() u32 {
    const seed_ptr = abi.read32(0x08010A98);
    const seed = abi.read32(seed_ptr);
    const next = nextRngSeed(seed);
    abi.write32(seed_ptr, next);
    return next;
}

pub fn func_08010A84() callconv(.c) void {
    if (!abi.enter(0x08010A84)) return;
    abi.fetches(11);
    const seed_ptr = abi.read32(0x08010A98);
    const seed = abi.read32(seed_ptr);
    const scaled = seed << 2;
    const f0 = scaled +% 2;
    const f1 = scaled +% 3;
    const next = (f0 *% f1) >> 2;
    rt.r[1] = seed_ptr;
    rt.r[2] = f1;
    abi.setRegNz(&rt.r[0], next);
    abi.write32(seed_ptr, next);
    abi.retLr();
}

/// Return signed cosine for integer degrees via `sin(deg + 90)` (`0x0807AF30`).
pub fn func_0807AF30() callconv(.c) void {
    if (!abi.enter(0x0807AF30)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x5A, true);
    if (!abi.call(decls.func_0807AED4, 0x0807AF39)) return;
    abi.fetches(5);
    const signed_val: i32 = abi.signExtend16(@truncate(rt.r[0]));
    abi.setRegNz(&rt.r[0], @bitCast(signed_val));
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Read signed 16-bit halfword from the global pointer at `0x0800FD0C` (`0x0800FCFA`).
pub fn readSignedGlobal16() i32 {
    const ptr = abi.read32(0x0800FD0C);
    return abi.signExtend16(abi.read16(ptr));
}

pub fn func_0800FCFA() callconv(.c) void {
    if (!abi.enter(0x0800FCFA)) return;
    abi.fetches(10);
    const signed_val = readSignedGlobal16();
    abi.setRegNz(&rt.r[0], @bitCast(signed_val));
    abi.retLr();
}

inline fn q12Mul(a: u32, b: u32) u32 {
    return a *% b;
}

inline fn q12Shift(val: u32) u32 {
    return @bitCast(@as(i32, @bitCast(val)) >> 12);
}

/// 3x3 fixed-point Q12 matrix * 3D vector (`out = M * v >> 12`) (`0x0806CF50`).
pub fn func_0806CF50() callconv(.c) void {
    if (!abi.enter(0x0806CF50)) return;
    abi.fetches(39);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const v0 = abi.read32(rt.r[0]);
    const v1 = abi.read32(rt.r[0] +% 4);
    const v2 = abi.read32(rt.r[0] +% 8);
    const m = rt.r[1];
    const out = rt.r[2];

    const x = q12Shift(q12Mul(abi.read32(m), v0) +% q12Mul(abi.read32(m +% 0xC), v1) +% q12Mul(abi.read32(m +% 0x18), v2));
    abi.write32(out, x);

    const y = q12Shift(q12Mul(abi.read32(m +% 4), v0) +% q12Mul(abi.read32(m +% 0x10), v1) +% q12Mul(abi.read32(m +% 0x1C), v2));
    abi.write32(out +% 4, y);

    const z1 = q12Mul(abi.read32(m +% 0x14), v1);
    const z2 = q12Mul(abi.read32(m +% 0x20), v2);
    const z = q12Shift(q12Mul(abi.read32(m +% 8), v0) +% z1 +% z2);
    abi.write32(out +% 8, z);

    rt.r[1] = z2;
    rt.r[2] = out;
    rt.r[3] = z1;
    rt.updateNz(z);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;

    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// 3D fixed-point Q12 vector dot product (`(a . b) >> 12`) (`0x0806D23C`).
pub fn func_0806D23C() callconv(.c) void {
    if (!abi.enter(0x0806D23C)) return;
    abi.fetches(19);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const a = rt.r[0];
    const b = rt.r[1];
    const a0 = abi.read32(a);
    const a1 = abi.read32(a +% 4);
    const a2 = abi.read32(a +% 8);
    const p0 = q12Mul(abi.read32(b), a0);
    const p1 = q12Mul(abi.read32(b +% 4), a1);
    const p2 = q12Mul(abi.read32(b +% 8), a2);
    const res = q12Shift(p0 +% p1 +% p2);

    rt.r[2] = a2;
    rt.r[3] = a1;
    abi.setRegNz(&rt.r[0], res);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;

    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// 3D fixed-point Q12 vector cross product (`out = (a x b) >> 12`, note arg component order matches GBA disassembly) (`0x0806D260`).
pub fn func_0806D260() callconv(.c) void {
    if (!abi.enter(0x0806D260)) return;
    abi.fetches(30);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const a = rt.r[0];
    const b = rt.r[1];
    const out = rt.r[2];
    const a0 = abi.read32(a);
    const a1 = abi.read32(a +% 4);
    const a2 = abi.read32(a +% 8);
    const b0 = abi.read32(b);
    const b1 = abi.read32(b +% 4);
    const b2 = abi.read32(b +% 8);

    const cx = q12Shift(q12Mul(b2, a1) -% q12Mul(b1, a2));
    abi.write32(out, cx);

    const cy = q12Shift(q12Mul(b0, a2) -% q12Mul(b2, a0));
    abi.write32(out +% 4, cy);

    const p_b1_a0 = q12Mul(b1, a0);
    const p_b0_a1 = q12Mul(b0, a1);
    const cz = q12Shift(p_b1_a0 -% p_b0_a1);
    abi.write32(out +% 8, cz);

    rt.r[1] = p_b0_a1;
    rt.r[2] = out;
    rt.r[3] = cy;
    rt.updateNz(cz);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;

    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Calls `func_08010A84` and returns `0` (`pop {r1}; bx r1`).
pub fn func_0803D4F0() callconv(.c) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08010A84, 0x0803D4F7)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Return uniform-like pseudo-random integer in `[r1, r0)` using `advanceRng` and BIOS `mod` (`0x08003918`).
pub fn func_08003918() callconv(.c) void {
    if (!abi.enter(0x08003918)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.cpuAdd(&rt.r[4], rt.r[0], 0, true);
    rt.cpuAdd(&rt.r[5], rt.r[1], 0, true);
    if (!abi.call(decls.func_08010A84, 0x08003923)) return;

    abi.fetches(7);
    rt.cpuSub(&rt.r[4], rt.r[4], rt.r[5], true);
    rt.r[4] = rt.r[4] << 5;
    rt.updateNz(rt.r[4]);
    rt.cpuAdd(&rt.r[1], rt.r[4], 0, true);
    if (!abi.call(decls.func_080796CC, 0x0800392D)) return;

    abi.fetches(7);
    rt.r[0] = rt.asrConst(rt.r[0], 5);
    rt.updateNz(rt.r[0]);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08010A84, .{ .name = "func_08010A84", .linkage = .strong });
        @export(&func_08003918, .{ .name = "func_08003918", .linkage = .strong });
        @export(&func_0806CF50, .{ .name = "func_0806CF50", .linkage = .strong });
        @export(&func_0806D23C, .{ .name = "func_0806D23C", .linkage = .strong });
        @export(&func_0806D260, .{ .name = "func_0806D260", .linkage = .strong });
        @export(&func_0807AF30, .{ .name = "func_0807AF30", .linkage = .strong });
        @export(&func_0800FCFA, .{ .name = "func_0800FCFA", .linkage = .strong });
        @export(&func_0803D4F0, .{ .name = "func_0803D4F0", .linkage = .strong });
    }
}

test "Q12 arithmetic shift preserves signed fixed-point scaling" {
    try std.testing.expectEqual(@as(u32, 1), q12Shift(q12Mul(4096, 4096) >> 12));
    try std.testing.expectEqual(@as(u32, 4096), q12Shift(q12Mul(4096, 4096)));
    const neg: u32 = @bitCast(-@as(i32, 8192));
    try std.testing.expectEqual(@as(i32, -2), @as(i32, @bitCast(q12Shift(neg))));
}

test "nextRngSeed matches Advance Wars (4*s+2)*(4*s+3)>>2 arithmetic across wraparound" {
    try std.testing.expectEqual(@as(u32, 1), nextRngSeed(0));
    try std.testing.expectEqual(@as(u32, 10), nextRngSeed(1));
    try std.testing.expectEqual(@as(u32, 27), nextRngSeed(2));
    // 0x4000_0000 << 2 == 0 -> ((2 * 3) >> 2) == 1
    try std.testing.expectEqual(@as(u32, 1), nextRngSeed(0x4000_0000));
    // 0xFFFF_FFFF << 2 == 0xFFFF_FFFC (-4 mod 2^32): (-2) * (-1) >> 2 == 0
    try std.testing.expectEqual(@as(u32, 0), nextRngSeed(0xFFFF_FFFF));
}
