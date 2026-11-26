const std = @import("std");

/// GBA native display width in pixels.
pub const gba_width: u32 = 240;
/// GBA native display height in pixels.
pub const gba_height: u32 = 160;
/// 64 KB Flash backup size (`FLASH_V121` in Advance Wars).
pub const flash_size_64k: usize = 64 * 1024;
/// GBA Flash sector size (4 KB).
pub const flash_sector_size: usize = 4096;

/// GBA KEYINPUT bit positions (bits 0..9; hardware register is active-low).
pub const Key = enum(u4) {
    a = 0,
    b = 1,
    select = 2,
    start = 3,
    right = 4,
    left = 5,
    up = 6,
    down = 7,
    r = 8,
    l = 9,

    /// Return the 10-bit mask for this button.
    pub fn mask(self: Key) u16 {
        return @as(u16, 1) << @intFromEnum(self);
    }
};

/// Convert an active-high pressed bitmask into GBA KEYINPUT active-low bits (0..9).
pub fn keyInputFromPressed(pressed_mask: u16) u16 {
    return (~pressed_mask) & 0x03FF;
}

/// Convert GBA 15-bit `xBBBBBGGGGGRRRRR` color to 32-bit `0xFFRRGGBB` ARGB8888.
/// Bit-identical to `gba_to_argb` in `ext/gbarecomp/src/display.c`.
pub fn rgb555ToArgb8888(bgr555: u16) u32 {
    const r5: u32 = bgr555 & 0x001F;
    const g5: u32 = (bgr555 & 0x03E0) >> 5;
    const b5: u32 = (bgr555 & 0x7C00) >> 10;

    const r8: u32 = (r5 << 3) | (r5 >> 2);
    const g8: u32 = (g5 << 3) | (g5 >> 2);
    const b8: u32 = (b5 << 3) | (b5 >> 2);

    return 0xFF000000 | (r8 << 16) | (g8 << 8) | b8;
}

/// Exported C-ABI probe proving the Zig runtime support library is linked into `awre`.
export fn awre_zig_abi_version() u32 {
    return 1;
}

test "GBA geometry and Flash constants" {
    try std.testing.expectEqual(@as(u32, 240), gba_width);
    try std.testing.expectEqual(@as(u32, 160), gba_height);
    try std.testing.expectEqual(@as(usize, 65536), flash_size_64k);
    try std.testing.expectEqual(@as(usize, 4096), flash_sector_size);
}

test "keyInputFromPressed produces active-low 10-bit KEYINPUT" {
    try std.testing.expectEqual(@as(u16, 0x03FF), keyInputFromPressed(0));
    try std.testing.expectEqual(@as(u16, 0x03FE), keyInputFromPressed(Key.a.mask()));
    try std.testing.expectEqual(@as(u16, 0x03F7), keyInputFromPressed(Key.start.mask()));
    try std.testing.expectEqual(@as(u16, 0x0000), keyInputFromPressed(0xFFFF));
    try std.testing.expectEqual(@as(u16, 0x03FF & ~Key.l.mask()), keyInputFromPressed(Key.l.mask()));
}

test "rgb555ToArgb8888 matches GBA 5-to-8 bit expansion" {
    try std.testing.expectEqual(@as(u32, 0xFF000000), rgb555ToArgb8888(0x0000));
    try std.testing.expectEqual(@as(u32, 0xFFFFFFFF), rgb555ToArgb8888(0x7FFF));
    // Bit 15 is unused on GBA BGR555 and must be ignored.
    try std.testing.expectEqual(@as(u32, 0xFFFFFFFF), rgb555ToArgb8888(0xFFFF));
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), rgb555ToArgb8888(0x001F));
    try std.testing.expectEqual(@as(u32, 0xFF00FF00), rgb555ToArgb8888(0x03E0));
    try std.testing.expectEqual(@as(u32, 0xFF0000FF), rgb555ToArgb8888(0x7C00));
    // Mid-tone check: 5-bit 0b10000 (16) -> 0b10000_100 (0x84).
    try std.testing.expectEqual(@as(u32, 0xFF840000), rgb555ToArgb8888(0x0010));
}
