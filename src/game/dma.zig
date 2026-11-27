//! Lifted CpuSet / CpuFastSet memory copy wrappers and hardware flag helpers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const abi = @import("abi.zig");
const bios = @import("bios.zig");

/// Convert a byte count (`u16`) to halfword transfer count (`>> 1`) for `CpuSet`.
pub inline fn byteCountToHalfwords(byte_count: u32) u32 {
    return (byte_count & 0xFFFF) >> 1;
}

/// Convert a byte count (`u16`) to word transfer count (`>> 2`) for `CpuFastSet`.
pub inline fn byteCountToWords(byte_count: u32) u32 {
    return (byte_count & 0xFFFF) >> 2;
}

/// Copy `size_bytes` from `src` to `dst` via `CpuSet` 16-bit transfers (`0x0800FD94`).
pub fn cpuCopy16(src: u32, dst: u32, size_bytes: u32) void {
    bios.cpuSet(src, dst, byteCountToHalfwords(size_bytes));
}

pub fn func_0800FD94() callconv(.c) void {
    if (!abi.enter(0x0800FD94)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[2], byteCountToHalfwords(rt.r[2]));
    if (!abi.call(bios.func_080796C4, 0x0800FD9F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Copy `size_bytes` from `src` to `dst` via `CpuFastSet` 32-bit transfers (`0x0800FDCC`).
pub fn cpuFastCopy32(src: u32, dst: u32, size_bytes: u32) void {
    bios.cpuFastSet(src, dst, byteCountToWords(size_bytes));
}

pub fn func_0800FDCC() callconv(.c) void {
    if (!abi.enter(0x0800FDCC)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[2], byteCountToWords(rt.r[2]));
    if (!abi.call(bios.func_080796C0, 0x0800FDD7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Set flag bit `0x10` in the byte addressed by `[0x08010AD4]` (`0x08010AC8`).
pub fn func_08010AC8() callconv(.c) void {
    if (!abi.enter(0x08010AC8)) return;
    abi.fetches(8);
    const target_addr = abi.read32(0x08010AD4);
    const prev = abi.read8(target_addr);
    const next: u32 = 0x10 | @as(u32, prev);
    rt.r[1] = target_addr;
    rt.r[2] = prev;
    abi.setRegNz(&rt.r[0], next);
    abi.write8(target_addr, @truncate(next));
    abi.retLr();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_0800FD94, .{ .name = "func_0800FD94", .linkage = .strong });
        @export(&func_0800FDCC, .{ .name = "func_0800FDCC", .linkage = .strong });
        @export(&func_08010AC8, .{ .name = "func_08010AC8", .linkage = .strong });
    }
}

test "CpuSet and CpuFastSet transfer size conversions truncate cleanly to u16 counts" {
    try std.testing.expectEqual(@as(u32, 0x1C0), byteCountToWords(0x700));
    try std.testing.expectEqual(@as(u32, 0x20), byteCountToHalfwords(0x40));
    try std.testing.expectEqual(@as(u32, 0), byteCountToWords(0x1_0000));
}
