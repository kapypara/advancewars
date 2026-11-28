//! GBA BIOS/SWI hardware abstraction submodule.

const std = @import("std");
const rt = @import("runtime");

/// GBA BIOS software interrupt opcodes invoked by Advance Wars.
pub const Swi = enum(u8) {
    soft_reset = 0x00,
    register_ram_reset = 0x01,
    div = 0x06,
    cpu_set = 0x0B,
    cpu_fast_set = 0x0C,
    bg_affine_set = 0x0E,
    lz77_uncomp_wram = 0x11,
    lz77_uncomp_vram = 0x12,
    huff_uncomp = 0x13,
    rl_uncomp_wram = 0x14,
    rl_uncomp_vram = 0x15,
    multiboot = 0x25,
};

pub const DivResult = struct {
    quot: i32,
    rem: i32,
    abs_quot: u32,
};

/// Pure native Zig signed division matching GBA BIOS `Div` semantics (no trap on `den == 0` or `minInt(i32) / -1`).
pub fn divPure(num: i32, den: i32) DivResult {
    if (den == 0) return .{ .quot = 0, .rem = 0, .abs_quot = 0 };
    const q: i64 = @divTrunc(@as(i64, num), @as(i64, den));
    const rem: i64 = @rem(@as(i64, num), @as(i64, den));
    const abs_q: u64 = if (q < 0) @intCast(-q) else @intCast(q);
    return .{
        .quot = @truncate(q),
        .rem = @truncate(rem),
        .abs_quot = @truncate(abs_q),
    };
}

/// Invoke the centralized BIOS SWI backend for exact cycle/validator parity.
pub inline fn invoke(comptime op: Swi) void {
    rt.gba_swi(@intFromEnum(op));
}

pub inline fn softReset() void {
    invoke(.soft_reset);
}

pub inline fn registerRamReset(flags: u32) void {
    rt.r[0] = flags;
    invoke(.register_ram_reset);
}

pub inline fn div(num: i32, den: i32) DivResult {
    rt.r[0] = @bitCast(num);
    rt.r[1] = @bitCast(den);
    invoke(.div);
    return .{
        .quot = @bitCast(rt.r[0]),
        .rem = @bitCast(rt.r[1]),
        .abs_quot = rt.r[3],
    };
}

pub inline fn cpuSet(src: u32, dst: u32, control: u32) void {
    rt.r[0] = src;
    rt.r[1] = dst;
    rt.r[2] = control;
    invoke(.cpu_set);
}

pub inline fn cpuFastSet(src: u32, dst: u32, control: u32) void {
    rt.r[0] = src;
    rt.r[1] = dst;
    rt.r[2] = control;
    invoke(.cpu_fast_set);
}

pub inline fn bgAffineSet(src: u32, dst: u32, count: u32) void {
    rt.r[0] = src;
    rt.r[1] = dst;
    rt.r[2] = count;
    invoke(.bg_affine_set);
}

pub inline fn lz77UnCompWram(src: u32, dst: u32) void {
    rt.r[0] = src;
    rt.r[1] = dst;
    invoke(.lz77_uncomp_wram);
}

pub inline fn lz77UnCompVram(src: u32, dst: u32) void {
    rt.r[0] = src;
    rt.r[1] = dst;
    invoke(.lz77_uncomp_vram);
}

pub inline fn huffUnComp(src: u32, dst: u32) void {
    rt.r[0] = src;
    rt.r[1] = dst;
    invoke(.huff_uncomp);
}

pub inline fn rlUnCompWram(src: u32, dst: u32) void {
    rt.r[0] = src;
    rt.r[1] = dst;
    invoke(.rl_uncomp_wram);
}

pub inline fn rlUnCompVram(src: u32, dst: u32) void {
    rt.r[0] = src;
    rt.r[1] = dst;
    invoke(.rl_uncomp_vram);
}

pub inline fn multiBoot(param_ptr: u32, mode: u32) u32 {
    rt.r[0] = param_ptr;
    rt.r[1] = mode;
    invoke(.multiboot);
    return rt.r[0];
}

test "hal.divPure matches GBA BIOS Div quotient, remainder, and abs_quot" {
    const pos = divPure(23, 5);
    try std.testing.expectEqual(@as(i32, 4), pos.quot);
    try std.testing.expectEqual(@as(i32, 3), pos.rem);
    try std.testing.expectEqual(@as(u32, 4), pos.abs_quot);

    const neg = divPure(-23, 5);
    try std.testing.expectEqual(@as(i32, -4), neg.quot);
    try std.testing.expectEqual(@as(i32, -3), neg.rem);
    try std.testing.expectEqual(@as(u32, 4), neg.abs_quot);

    const zero = divPure(123, 0);
    try std.testing.expectEqual(@as(i32, 0), zero.quot);
    try std.testing.expectEqual(@as(i32, 0), zero.rem);
    try std.testing.expectEqual(@as(u32, 0), zero.abs_quot);

    const ovf = divPure(std.math.minInt(i32), -1);
    try std.testing.expectEqual(std.math.minInt(i32), ovf.quot);
    try std.testing.expectEqual(@as(i32, 0), ovf.rem);
    try std.testing.expectEqual(@as(u32, 0x8000_0000), ovf.abs_quot);
}

test "hal.Swi enum opcodes match GBA BIOS specification" {
    try std.testing.expectEqual(@as(u8, 0x00), @intFromEnum(Swi.soft_reset));
    try std.testing.expectEqual(@as(u8, 0x01), @intFromEnum(Swi.register_ram_reset));
    try std.testing.expectEqual(@as(u8, 0x06), @intFromEnum(Swi.div));
    try std.testing.expectEqual(@as(u8, 0x0B), @intFromEnum(Swi.cpu_set));
    try std.testing.expectEqual(@as(u8, 0x0C), @intFromEnum(Swi.cpu_fast_set));
    try std.testing.expectEqual(@as(u8, 0x0E), @intFromEnum(Swi.bg_affine_set));
    try std.testing.expectEqual(@as(u8, 0x11), @intFromEnum(Swi.lz77_uncomp_wram));
    try std.testing.expectEqual(@as(u8, 0x12), @intFromEnum(Swi.lz77_uncomp_vram));
    try std.testing.expectEqual(@as(u8, 0x13), @intFromEnum(Swi.huff_uncomp));
    try std.testing.expectEqual(@as(u8, 0x14), @intFromEnum(Swi.rl_uncomp_wram));
    try std.testing.expectEqual(@as(u8, 0x15), @intFromEnum(Swi.rl_uncomp_vram));
    try std.testing.expectEqual(@as(u8, 0x25), @intFromEnum(Swi.multiboot));
}
