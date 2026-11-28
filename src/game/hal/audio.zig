//! GBA m4a audio driver track cursor & BGM state abstraction submodule.

const std = @import("std");
const mem = @import("../mem.zig");
const types = @import("../types.zig");

pub const bgm_none: u16 = types.bgm_none;
pub const track_cmd_cursor_off: u32 = 0x40;

pub const TrackOffset = struct {
    pub const mod_type: u32 = 0x1E;
    pub const mod_depth: u32 = 0x1F;
    pub const mod_speed: u32 = 0x26;
    pub const mod_delay: u32 = 0x27;
    pub const param_2c: u32 = 0x2C;
    pub const param_2d: u32 = 0x2D;
    pub const param_2e: u32 = 0x2E;
    pub const param_2f: u32 = 0x2F;
};

pub inline fn readBgmEnabledFlag() u8 {
    return mem.readU8(types.addr.battle_ui_state +% 0xC);
}

pub inline fn isBgmEnabled() bool {
    return readBgmEnabledFlag() != 0;
}

pub inline fn deferPendingBgm(track_id: u16) void {
    mem.writeU16(types.addr.pending_bgm_id, track_id);
    mem.writeU16(types.addr.active_bgm_id, bgm_none);
}

pub inline fn readPendingBgm() u16 {
    return mem.readU16(types.addr.pending_bgm_id);
}

pub inline fn readActiveBgm() u16 {
    return mem.readU16(types.addr.active_bgm_id);
}

pub inline fn clearActiveBgm() void {
    mem.writeU16(types.addr.active_bgm_id, bgm_none);
}

pub const TrackStep = struct { next_ptr: u32, field_addr: u32, val: u8 };

pub inline fn stepTrackByte(track_addr: u32, comptime field_off: u32) TrackStep {
    const cmd_ptr = mem.readU32(track_addr +% track_cmd_cursor_off);
    const val = mem.readU8(cmd_ptr);
    const field_addr = track_addr +% field_off;
    mem.writeU8(field_addr, val);
    const next_ptr = cmd_ptr +% 1;
    mem.writeU32(track_addr +% track_cmd_cursor_off, next_ptr);
    return .{ .next_ptr = next_ptr, .field_addr = field_addr, .val = val };
}

pub inline fn readLe32(addr: u32) struct { word: u32, b3_shifted: u32 } {
    const b0: u32 = mem.readU8(addr);
    const b1: u32 = mem.readU8(addr +% 1);
    const b2: u32 = mem.readU8(addr +% 2);
    const b3: u32 = mem.readU8(addr +% 3);
    return .{
        .word = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24),
        .b3_shifted = b3 << 24,
    };
}

test "hal.audio track offsets and BGM constants" {
    try std.testing.expectEqual(@as(u16, 0xFFFF), bgm_none);
    try std.testing.expectEqual(@as(u32, 0x40), track_cmd_cursor_off);
    try std.testing.expectEqual(@as(u32, 0x1E), TrackOffset.mod_type);
    try std.testing.expectEqual(@as(u32, 0x2F), TrackOffset.param_2f);
}
