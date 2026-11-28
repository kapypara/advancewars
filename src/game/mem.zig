//! Zero-overhead typed GBA RAM accessors built on top of `abi.zig` and `types.zig`.

const std = @import("std");
const abi = @import("abi.zig");
const types = @import("types.zig");

pub const CursorTile = struct {
    x: u16,
    y: u16,
};

pub inline fn readU8(addr: u32) u8 {
    return abi.read8(addr);
}

pub inline fn readU16(addr: u32) u16 {
    return abi.read16(addr);
}

pub inline fn readI16(addr: u32) i16 {
    return @bitCast(abi.read16(addr));
}

pub inline fn readU32(addr: u32) u32 {
    return abi.read32(addr);
}

pub inline fn writeU8(addr: u32, val: u8) void {
    abi.write8(addr, val);
}

pub inline fn writeU16(addr: u32, val: u16) void {
    abi.write16(addr, val);
}

pub inline fn writeI16(addr: u32, val: i16) void {
    abi.write16(addr, @bitCast(val));
}

pub inline fn writeU32(addr: u32, val: u32) void {
    abi.write32(addr, val);
}

pub inline fn procSlotAddr(idx: usize) u32 {
    return types.addr.proc_table +% @as(u32, @intCast(idx * types.proc_slot_stride));
}

pub inline fn scriptSlotAddr(idx: usize) u32 {
    return types.addr.script_pool +% @as(u32, @intCast(idx * types.script_slot_stride));
}

pub inline fn animSlotAddr(idx: usize) u32 {
    return types.addr.anim_pool +% @as(u32, @intCast(idx * types.anim_slot_stride));
}

pub inline fn oamQueueAddr(idx: usize) u32 {
    return types.addr.oam_queue +% @as(u32, @intCast(idx * types.oam_queue_stride));
}

pub inline fn readMapWorkspace() types.MapWorkspace {
    const base = types.addr.map_workspace;
    return .{
        .width = readU16(base),
        .height = readU16(base +% 2),
        .cam_x = readI16(base +% 4),
        .cam_y = readI16(base +% 6),
    };
}

pub inline fn readCursorTile() CursorTile {
    return .{
        .x = readU16(types.addr.cursor_tile_x),
        .y = readU16(types.addr.cursor_tile_y),
    };
}

test "typed pool slot address calculations match GBA memory strides" {
    try std.testing.expectEqual(@as(u32, 0x0300_0E10), procSlotAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_0E70), procSlotAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0300_1D50), scriptSlotAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_1D68), scriptSlotAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0300_2320), animSlotAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_236C), animSlotAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0201_1D24), oamQueueAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0201_1D34), oamQueueAddr(1));
}
