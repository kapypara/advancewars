//! Lifted GBA PPU/OAM shadow register, palette fade, and VRAM bulk-copy helpers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const dma = @import("dma.zig");

const bg_scroll_ptr_addrs = [_]u32{
    0x0801047C, 0x08010480, 0x08010484, 0x08010488, 0x0801048C,
    0x08010490, 0x08010494, 0x08010498, 0x0801049C, 0x080104A0,
    0x080104A4, 0x080104A8, 0x080104AC,
};

const window_reg_ptr_addrs = [_]u32{
    0x080104C4, 0x080104C8, 0x080104CC, 0x080104D0,
};

fn zeroHalfwordPtrTable(comptime pool_addrs: []const u32, comptime fetches_n: u32) void {
    abi.fetches(fetches_n);
    var last_ptr: u32 = 0;
    for (pool_addrs) |pool_addr| {
        last_ptr = abi.read32(pool_addr);
        abi.write16(last_ptr, 0);
    }
    abi.setRegNz(&rt.r[1], 0);
    rt.r[0] = last_ptr;
    abi.retLr();
}

/// Shared no-op frame callback (`0x0800F094`).
pub fn func_0800F094() callconv(.c) void {
    if (!abi.enter(0x0800F094)) return;
    abi.fetches(3);
    abi.retLr();
}

/// Initialize display window / blend shadow registers (`0x0800F170`).
pub fn func_0800F170() callconv(.c) void {
    if (!abi.enter(0x0800F170)) return;
    abi.fetches(26);
    const win_ctl_ptr = abi.read32(0x0800F1A0);
    abi.write16(win_ctl_ptr, 0);
    const enabled_mask: u32 = @as(u32, abi.read8(win_ctl_ptr)) | 0x3F;
    abi.write8(win_ctl_ptr, @truncate(enabled_mask));

    abi.write16(abi.read32(0x0800F1A4), 0);
    abi.write16(abi.read32(0x0800F1A8), 0);
    const last_ptr = abi.read32(0x0800F1AC);
    abi.write16(last_ptr, 0);

    rt.r[2] = win_ctl_ptr;
    rt.r[3] = 0;
    rt.r[1] = 0x20;
    abi.setRegNz(&rt.r[0], last_ptr);
    abi.retLr();
}

/// Copy 16-bit shadow display control register from `[0x0800F588]` to `[0x0800F584]` (`0x0800F578`).
pub fn func_0800F578() callconv(.c) void {
    if (!abi.enter(0x0800F578)) return;
    abi.fetches(7);
    const dst = abi.read32(0x0800F584);
    const src = abi.read32(0x0800F588);
    const val = abi.read16(src);
    abi.write16(dst, val);
    rt.r[0] = dst;
    rt.r[1] = val;
    abi.retLr();
}

/// Clear all 13 BG scroll/control shadow registers (`0x08010444`).
pub fn func_08010444() callconv(.c) void {
    if (!abi.enter(0x08010444)) return;
    zeroHalfwordPtrTable(&bg_scroll_ptr_addrs, 30);
}

/// Clear all 4 window shadow registers (`0x080104B0`).
pub fn func_080104B0() callconv(.c) void {
    if (!abi.enter(0x080104B0)) return;
    zeroHalfwordPtrTable(&window_reg_ptr_addrs, 12);
}

/// OAM queue flush wrapper A (`0x080134E0` -> `0x0801A61C`).
pub fn func_080134E0() callconv(.c) void {
    if (!abi.enter(0x080134E0)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0801A61C, 0x080134E7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// OAM queue flush wrapper B (`0x080134EC` -> `0x0801A660`).
pub fn func_080134EC() callconv(.c) void {
    if (!abi.enter(0x080134EC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0801A660, 0x080134F3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Reset palette fade state (`0x08015A08`: calls `0x08014B14(0, 16)` and zeroes `[0x08015A1C]`).
pub fn func_08015A08() callconv(.c) void {
    if (!abi.enter(0x08015A08)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    abi.setRegNz(&rt.r[1], 0x10);
    if (!abi.call(decls.func_08014B14, 0x08015A13)) return;
    abi.fetches(7);
    abi.write16(abi.read32(0x08015A1C), 0);
    abi.popReturn();
}

/// Copy `0x380` bytes of BG tilemap/tile data using `cpuFastCopy32` (`0x08015A38`).
pub fn func_08015A38() callconv(.c) void {
    if (!abi.enter(0x08015A38)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08015A4C);
    rt.r[1] = abi.read32(0x08015A50);
    abi.setRegNz(&rt.r[2], @as(u32, 0xE0) << 2);
    if (!abi.call(dma.func_0800FDCC, 0x08015A47)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Copy `0x80` bytes from `[0x08015A68]` into `0x0700_0000` (OAM) using `cpuFastCopy32` (`0x08015A54`).
pub fn func_08015A54() callconv(.c) void {
    if (!abi.enter(0x08015A54)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08015A68);
    abi.setRegNz(&rt.r[1], @as(u32, 0xE0) << 19);
    abi.setRegNz(&rt.r[2], 0x80);
    if (!abi.call(dma.func_0800FDCC, 0x08015A63)) return;
    abi.fetches(4);
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_0800F094, .{ .name = "func_0800F094", .linkage = .strong });
        @export(&func_0800F170, .{ .name = "func_0800F170", .linkage = .strong });
        @export(&func_0800F578, .{ .name = "func_0800F578", .linkage = .strong });
        @export(&func_08010444, .{ .name = "func_08010444", .linkage = .strong });
        @export(&func_080104B0, .{ .name = "func_080104B0", .linkage = .strong });
        @export(&func_080134E0, .{ .name = "func_080134E0", .linkage = .strong });
        @export(&func_080134EC, .{ .name = "func_080134EC", .linkage = .strong });
        @export(&func_08015A08, .{ .name = "func_08015A08", .linkage = .strong });
        @export(&func_08015A38, .{ .name = "func_08015A38", .linkage = .strong });
        @export(&func_08015A54, .{ .name = "func_08015A54", .linkage = .strong });
    }
}

test "register literal pool tables are sorted and contiguous in ROM" {
    try std.testing.expectEqual(@as(usize, 13), bg_scroll_ptr_addrs.len);
    try std.testing.expectEqual(@as(usize, 4), window_reg_ptr_addrs.len);
    for (1..bg_scroll_ptr_addrs.len) |i| {
        try std.testing.expectEqual(bg_scroll_ptr_addrs[i - 1] + 4, bg_scroll_ptr_addrs[i]);
    }
    for (1..window_reg_ptr_addrs.len) |i| {
        try std.testing.expectEqual(window_reg_ptr_addrs[i - 1] + 4, window_reg_ptr_addrs[i]);
    }
}
