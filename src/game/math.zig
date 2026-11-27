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

comptime {
    if (!builtin.is_test) {
        @export(&func_08010A84, .{ .name = "func_08010A84", .linkage = .strong });
        @export(&func_0807AF30, .{ .name = "func_0807AF30", .linkage = .strong });
        @export(&func_0800FCFA, .{ .name = "func_0800FCFA", .linkage = .strong });
    }
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
