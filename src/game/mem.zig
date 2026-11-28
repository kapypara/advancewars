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

pub inline fn writeStruct(comptime T: type, base_addr: u32, val: T) void {
    for (std.mem.asBytes(&val), 0..) |b, i| {
        writeU8(base_addr +% @as(u32, @intCast(i)), b);
    }
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

pub inline fn cameraStateAddr() u32 {
    return readU32(types.addr.camera_state_ptr);
}

pub inline fn readProcSlot(idx: usize) types.ProcSlot {
    return readStruct(types.ProcSlot, procSlotAddr(idx));
}

pub inline fn writeProcSlot(idx: usize, slot: types.ProcSlot) void {
    writeStruct(types.ProcSlot, procSlotAddr(idx), slot);
}

pub inline fn readScriptSlot(idx: usize) types.ScriptSlot {
    return readStruct(types.ScriptSlot, scriptSlotAddr(idx));
}

pub inline fn readAnimSlot(idx: usize) types.AnimSlot {
    return readStruct(types.AnimSlot, animSlotAddr(idx));
}

pub inline fn readOamAttr(idx: usize) types.OamAttr {
    return readStruct(types.OamAttr, oamAttrAddr(idx));
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

pub inline fn readCursorState() types.CursorState {
    const base = types.addr.cursor_x_px;
    return .{
        .x_px = readU16(base),
        .y_px = readU16(base +% 2),
        .tile_x = readU16(base +% 4),
        .tile_y = readU16(base +% 6),
    };
}

pub inline fn writeCursorState(c: types.CursorState) void {
    const base = types.addr.cursor_x_px;
    writeU16(base, c.x_px);
    writeU16(base +% 2, c.y_px);
    writeU16(base +% 4, c.tile_x);
    writeU16(base +% 6, c.tile_y);
}

pub inline fn readCameraState() types.CameraState {
    return readStruct(types.CameraState, cameraStateAddr());
}

pub inline fn readBattleSideCtx(ctx_addr: u32) types.BattleSideCtx {
    return readStruct(types.BattleSideCtx, ctx_addr);
}

pub inline fn readUnitHp(unit_ptr: u32) u8 {
    return readStruct(types.UnitRecord, unit_ptr).hp();
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
    const rec = types.UnitRecord{ ._pad00 = .{ 0, 0, 0, 0 }, .hp_flags = 0x8A };
    try std.testing.expectEqual(@as(u8, 10), rec.hp());
}
