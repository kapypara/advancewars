//! GBA PPU palette, display shadow, tilemap, and OAM queue abstraction submodule.

const std = @import("std");
const mem = @import("../mem.zig");
const types = @import("../types.zig");

pub const pal_ram_addr: u32 = types.addr.pal_ram;
pub const pal_shadow_addr: u32 = types.addr.palette_shadow_buf;
pub const pal_ram_size: u32 = types.pal_ram_size;
pub const pal_dirty_count: usize = types.palette_dirty_count;
pub const dispcnt_forced_blank: u8 = types.dispcnt_forced_blank;
pub const tilemap_row_stride_bytes: u32 = 0x40;
pub const oam_queue_count: usize = types.oam_queue_count;

pub inline fn readDispcntLow() u8 {
    return mem.readU8(types.addr.dispcnt_shadow);
}

pub inline fn isForcedBlank() bool {
    return (readDispcntLow() & dispcnt_forced_blank) != 0;
}

pub inline fn readPaletteSyncedFlag() u8 {
    return mem.readU8(types.addr.palette_synced_flag);
}

pub inline fn writePaletteSyncedFlag(val: u8) void {
    mem.writeU8(types.addr.palette_synced_flag, val);
}

pub inline fn writePaletteDirtyFlag(index: usize, val: u8) void {
    mem.writeU8(types.addr.palette_dirty_flags +% @as(u32, @intCast(index)), val);
}

pub inline fn enableBlendShadowBits(addr: u32, lo_mask: u8, hi_mask: u8) u32 {
    const v0: u32 = mem.readU8(addr) | lo_mask;
    mem.writeU8(addr, @truncate(v0));
    const v1: u32 = mem.readU8(addr +% 1) | hi_mask;
    mem.writeU8(addr +% 1, @truncate(v1));
    return v1;
}

pub inline fn wrappedTilemapByteOffset(tile_x: u16, tile_y: u16, cam_x: u16, cam_y: u16) u32 {
    const local_x: u32 = (tile_x -% cam_x) & 0xF;
    const local_y: u32 = (tile_y -% cam_y) & 0xF;
    return (local_x << 2) +% (local_y << 7);
}

pub inline fn writeMetaTile2x2(base: u32, tl: u16, tr: u16, bl: u16, br: u16) void {
    mem.writeU16(base, tl);
    mem.writeU16(base +% 2, tr);
    mem.writeU16(base +% tilemap_row_stride_bytes, bl);
    mem.writeU16(base +% tilemap_row_stride_bytes +% 2, br);
}

pub inline fn oamQueueAddr(idx: usize) u32 {
    return mem.oamQueueAddr(idx);
}

pub inline fn oamQueueUsedAddr(idx: usize) u32 {
    return types.addr.oam_queue_used +% @as(u32, @intCast(idx));
}

pub inline fn readOamQueueUsed(idx: usize) u8 {
    return mem.readU8(oamQueueUsedAddr(idx));
}

pub inline fn writeOamQueueUsed(idx: usize, val: u8) void {
    mem.writeU8(oamQueueUsedAddr(idx), val);
}

pub inline fn setOamQueueCoords(idx: usize, a: u16, b: u16, c: u16) void {
    const entry = oamQueueAddr(idx);
    mem.writeU16(entry +% 0x6, a);
    mem.writeU16(entry +% 0x8, b);
    mem.writeU16(entry +% 0xA, c);
}

pub inline fn setOamQueueTail(idx: usize, c: u16, e: u16) void {
    const entry = oamQueueAddr(idx);
    mem.writeU16(entry +% 0xC, c);
    mem.writeU16(entry +% 0xE, e);
}

pub inline fn resetOamQueueSlot(idx: usize) u32 {
    const entry = oamQueueAddr(idx);
    mem.writeU16(entry +% 0x6, 0);
    mem.writeU16(entry +% 0xC, 0);
    return entry;
}

test "hal.video palette, tilemap wrap, and OAM queue geometry" {
    try std.testing.expectEqual(@as(u32, 0x0500_0000), pal_ram_addr);
    try std.testing.expectEqual(@as(u32, 0x0400), pal_ram_size);
    try std.testing.expectEqual(@as(usize, 32), pal_dirty_count);
    try std.testing.expectEqual(@as(u32, 0), wrappedTilemapByteOffset(0, 0, 0, 0));
    try std.testing.expectEqual(@as(u32, 0), wrappedTilemapByteOffset(17, 18, 1, 2));
    try std.testing.expectEqual(@as(u32, (1 << 2) + (1 << 7)), wrappedTilemapByteOffset(2, 1, 1, 0));
    try std.testing.expectEqual(types.addr.oam_queue + 48, oamQueueAddr(3));
    try std.testing.expectEqual(types.addr.oam_queue_used + 5, oamQueueUsedAddr(5));
}
