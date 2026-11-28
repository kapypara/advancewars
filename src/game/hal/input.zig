//! GBA keypad input abstraction submodule (`KEYINPUT` `0x0400_0130`).

const std = @import("std");
const rt = @import("runtime");
const config = @import("config.zig");
const mem = @import("../mem.zig");
const types = @import("../types.zig");

pub const Button = packed struct(u16) {
    a: bool = false,
    b: bool = false,
    select: bool = false,
    start: bool = false,
    right: bool = false,
    left: bool = false,
    up: bool = false,
    down: bool = false,
    r: bool = false,
    l: bool = false,
    _unused: u6 = 0,
};

pub const mask_all: u16 = @truncate(types.key_mask_all);
pub const mask_soft_reset: u16 = @truncate(types.key_mask_soft_reset);

pub inline fn decodeActiveLow(raw_keyinput: u16) u16 {
    return @truncate(types.key_mask_all & ~@as(u32, raw_keyinput));
}

pub inline fn decodeButtons(raw_keyinput: u16) Button {
    return @bitCast(decodeActiveLow(raw_keyinput));
}

pub inline fn readRaw() u16 {
    if (comptime config.is_native) return rt.hal_native_read_keys();
    return mem.readU16(types.addr.reg_keyinput);
}

pub inline fn pollPressed() u16 {
    return decodeActiveLow(readRaw());
}

pub inline fn isSoftResetCombo(raw_keyinput: u16) bool {
    return (decodeActiveLow(raw_keyinput) & mask_soft_reset) == mask_soft_reset;
}

test "hal.input decodes active-low KEYINPUT buttons and soft-reset combo" {
    try std.testing.expectEqual(@as(usize, 16), @bitSizeOf(Button));
    try std.testing.expectEqual(@as(u16, 0x0000), decodeActiveLow(0x03FF));
    try std.testing.expectEqual(@as(u16, 0x000F), decodeActiveLow(0x03F0));
    try std.testing.expectEqual(@as(u16, 0x03FF), decodeActiveLow(0x0000));

    // A (bit 0), Start (bit 3), and L (bit 9) pressed simultaneously -> active-low bits cleared.
    const raw: u16 = 0x03FF & ~@as(u16, (1 << 0) | (1 << 3) | (1 << 9));
    const btns = decodeButtons(raw);
    try std.testing.expect(btns.a);
    try std.testing.expect(!btns.b);
    try std.testing.expect(!btns.select);
    try std.testing.expect(btns.start);
    try std.testing.expect(btns.l);
    try std.testing.expect(!btns.r);

    try std.testing.expect(isSoftResetCombo(0x03F0));
    try std.testing.expect(!isSoftResetCombo(0x03F1));
}
