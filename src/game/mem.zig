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

pub inline fn readStruct(comptime T: type, base_addr: u32) T {
    var val: T = undefined;
    for (std.mem.asBytes(&val), 0..) |*b, i| {
        b.* = readU8(base_addr +% @as(u32, @intCast(i)));
    }
    return val;
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

pub inline fn oamAttrAddr(idx: usize) u32 {
    return types.addr.oam_attr_table +% @as(u32, @intCast(idx * types.oam_attr_stride));
}

pub inline fn oamQueueAddr(idx: usize) u32 {
    return types.addr.oam_queue +% @as(u32, @intCast(idx * types.oam_queue_stride));
}

pub inline fn entitySlotAddr(entity_base: u32, slot_idx: usize) u32 {
    return entity_base +% @as(u32, @intCast(slot_idx * types.entity_stride));
}

pub inline fn entityTableBase() u32 {
    return readU32(types.addr.entity_table_ptr);
}

pub inline fn unitListBase() u32 {
    return readU32(types.addr.unit_list_ptr);
}

pub inline fn unitRecordAddr(list_base: u32, idx: usize) u32 {
    return list_base +% @as(u32, @intCast(idx * types.unit_record_stride));
}

pub inline fn cameraStateAddr() u32 {
    return readU32(types.addr.camera_state_ptr);
}

pub inline fn readCameraState() types.CameraState {
    return readStruct(types.CameraState, cameraStateAddr());
}

pub inline fn readCursorTile() CursorTile {
    return .{
        .x = readU16(types.addr.cursor_tile_x),
        .y = readU16(types.addr.cursor_tile_y),
    };
}

pub inline fn writeCursorTile(tile_x: u16, tile_y: u16) void {
    writeU16(types.addr.cursor_tile_x, tile_x);
    writeU16(types.addr.cursor_tile_y, tile_y);
}

pub inline fn readSavedCursorTile() CursorTile {
    return .{
        .x = readU16(types.addr.saved_cursor_tile),
        .y = readU16(types.addr.saved_cursor_tile +% 2),
    };
}

pub inline fn writeSavedCursorTile(tile_x: u16, tile_y: u16) void {
    writeU16(types.addr.saved_cursor_tile, tile_x);
    writeU16(types.addr.saved_cursor_tile +% 2, tile_y);
}

pub inline fn writeCursorPx(x_px: u16, y_px: u16) void {
    writeU16(types.addr.cursor_x_px, x_px);
    writeU16(types.addr.cursor_y_px, y_px);
}

pub inline fn readBattleSideCtx(ctx_addr: u32) types.BattleSideCtx {
    return readStruct(types.BattleSideCtx, ctx_addr);
}

pub inline fn readUnitHp(unit_ptr: u32) u8 {
    return readStruct(types.UnitRecord, unit_ptr).hp();
}

pub inline fn reachabilityRowPtr(y: u32) u32 {
    return readU32(types.addr.reachability_rows +% (y << 2));
}

pub inline fn readReachability(x: u32, y: u32) i8 {
    return @bitCast(readU8(reachabilityRowPtr(y) +% x));
}

pub inline fn writeReachability(x: u32, y: u32, val: u8) void {
    writeU8(reachabilityRowPtr(y) +% x, val);
}

test "typed pool slot address calculations match GBA memory strides" {
    try std.testing.expectEqual(@as(u32, 0x0300_0E10), procSlotAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_0E70), procSlotAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0300_1D50), scriptSlotAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_1D68), scriptSlotAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0300_2320), animSlotAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_236C), animSlotAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0201_1924), oamAttrAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0201_192C), oamAttrAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0201_1D24), oamQueueAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0201_1D34), oamQueueAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0200_0068), entitySlotAddr(0x0200_0000, 1));
    try std.testing.expectEqual(@as(u32, 0x0200_000C), unitRecordAddr(0x0200_0000, 1));
    const rec = types.UnitRecord{
        .unit_type = 0,
        ._pad01 = 0,
        .tile_x = 0,
        .tile_y = 0,
        .hp_flags = 0x8A,
        .state_flags = 0,
        ._pad06 = .{ 0, 0, 0, 0, 0, 0 },
    };
    try std.testing.expectEqual(@as(u8, 10), rec.hp());
}
