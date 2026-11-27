const std = @import("std");
const builtin = @import("builtin");

/// Print formatted diagnostics on hosted builds; compiled out on freestanding WASM.
pub fn logPrint(comptime fmt: []const u8, args: anytype) void {
    if (builtin.os.tag == .freestanding) return;
    std.debug.print(fmt, args);
}

/// GBA native display width in pixels.
pub const width: usize = 240;
/// GBA native display height in pixels.
pub const height: usize = 160;
/// 64 KB Flash backup size (`FLASH_V121` in Advance Wars).
pub const flash_size_64k: usize = 64 * 1024;
/// GBA Flash sector size (4 KB).
pub const flash_sector_size: usize = 4096;

/// GBA LCD MMIO register offsets relative to `0x0400_0000`.
pub const io_reg = struct {
    pub const dispcnt: u32 = 0x000;
    pub const dispstat: u32 = 0x004;
    pub const vcount: u32 = 0x006;
    pub const bg0cnt: u32 = 0x008;
    pub const bg1cnt: u32 = 0x00A;
    pub const bg2cnt: u32 = 0x00C;
    pub const bg3cnt: u32 = 0x00E;
    pub const bg0hofs: u32 = 0x010;
    pub const bg0vofs: u32 = 0x012;
    pub const bg1hofs: u32 = 0x014;
    pub const bg1vofs: u32 = 0x016;
    pub const bg2hofs: u32 = 0x018;
    pub const bg2vofs: u32 = 0x01A;
    pub const bg3hofs: u32 = 0x01C;
    pub const bg3vofs: u32 = 0x01E;
    pub const bg2pa: u32 = 0x020;
    pub const bg2x: u32 = 0x028;
    pub const bg3x: u32 = 0x038;
    pub const win0h: u32 = 0x040;
    pub const win0v: u32 = 0x044;
    pub const winin: u32 = 0x048;
    pub const winout: u32 = 0x04A;
    pub const bldcnt: u32 = 0x050;
    pub const bldalpha: u32 = 0x052;
    pub const bldy: u32 = 0x054;
};

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
pub fn rgb555ToArgb8888(bgr555: u16) u32 {
    const r5: u32 = bgr555 & 0x001F;
    const g5: u32 = (bgr555 & 0x03E0) >> 5;
    const b5: u32 = (bgr555 & 0x7C00) >> 10;

    const r8: u32 = (r5 << 3) | (r5 >> 2);
    const g8: u32 = (g5 << 3) | (g5 >> 2);
    const b8: u32 = (b5 << 3) | (b5 >> 2);

    return 0xFF000000 | (r8 << 16) | (g8 << 8) | b8;
}

/// Read-only view of GBA display memory regions (`io_regs`, `palette`, `vram`, `oam`).
pub const PpuMemory = struct {
    io_regs: [*]const u8,
    palette: [*]const u8,
    vram: [*]const u8,
    oam: [*]const u8,

    pub inline fn ioRead16(self: PpuMemory, offset: u32) u16 {
        return @as(u16, self.io_regs[offset]) | (@as(u16, self.io_regs[offset + 1]) << 8);
    }

    pub inline fn palRead16(self: PpuMemory, offset: u32) u16 {
        return @as(u16, self.palette[offset]) | (@as(u16, self.palette[offset + 1]) << 8);
    }

    pub inline fn vramRead16(self: PpuMemory, offset: u32) u16 {
        return @as(u16, self.vram[offset]) | (@as(u16, self.vram[offset + 1]) << 8);
    }

    pub inline fn vramRead8(self: PpuMemory, offset: u32) u8 {
        return self.vram[offset];
    }

    pub inline fn oamRead16(self: PpuMemory, offset: u32) u16 {
        return @as(u16, self.oam[offset]) | (@as(u16, self.oam[offset + 1]) << 8);
    }
};

test "GBA geometry and Flash constants" {
    try std.testing.expectEqual(@as(usize, 240), width);
    try std.testing.expectEqual(@as(usize, 160), height);
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
    try std.testing.expectEqual(@as(u32, 0xFFFFFFFF), rgb555ToArgb8888(0xFFFF));
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), rgb555ToArgb8888(0x001F));
    try std.testing.expectEqual(@as(u32, 0xFF00FF00), rgb555ToArgb8888(0x03E0));
    try std.testing.expectEqual(@as(u32, 0xFF0000FF), rgb555ToArgb8888(0x7C00));
    try std.testing.expectEqual(@as(u32, 0xFF840000), rgb555ToArgb8888(0x0010));
}
