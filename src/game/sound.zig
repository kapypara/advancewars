//! Lifted m4a (MusicPlayer2000) track parameter handlers and audio driver entry wrappers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");

/// Byte offset of the current bytecode sequence cursor inside `MusicPlayerTrack`.
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

/// Advance `track + 0x40` command pointer by 1 byte, storing the byte at `track + field_off`.
pub inline fn advanceTrackByte(track_addr: u32, comptime field_off: u32) u32 {
    const cmd_ptr = abi.read32(track_addr +% track_cmd_cursor_off);
    const val = abi.read8(cmd_ptr);
    abi.write8(track_addr +% field_off, val);
    const next_ptr = cmd_ptr +% 1;
    abi.write32(track_addr +% track_cmd_cursor_off, next_ptr);
    return next_ptr;
}

fn readTrackCmdHandler(comptime field_off: u32, comptime fetches_n: u32, comptime r2_is_ptr: bool) void {
    abi.fetches(fetches_n);
    const track = rt.r[1];
    const cmd_ptr = abi.read32(track +% track_cmd_cursor_off);
    const val = abi.read8(cmd_ptr);
    const field_addr = track +% field_off;
    abi.write8(field_addr, val);
    const next_ptr = cmd_ptr +% 1;
    abi.write32(track +% track_cmd_cursor_off, next_ptr);
    rt.r[2] = if (r2_is_ptr) field_addr else val;
    abi.setRegNz(&rt.r[0], next_ptr);
    abi.retLr();
}

pub fn func_08079610() callconv(.c) void {
    if (!abi.enter(0x08079610)) return;
    readTrackCmdHandler(TrackOffset.param_2c, 11, false);
}

pub fn func_08079624() callconv(.c) void {
    if (!abi.enter(0x08079624)) return;
    readTrackCmdHandler(TrackOffset.param_2d, 11, true);
}

pub fn func_08079638() callconv(.c) void {
    if (!abi.enter(0x08079638)) return;
    readTrackCmdHandler(TrackOffset.param_2e, 11, true);
}

pub fn func_0807964C() callconv(.c) void {
    if (!abi.enter(0x0807964C)) return;
    readTrackCmdHandler(TrackOffset.param_2f, 11, true);
}

pub fn func_08079660() callconv(.c) void {
    if (!abi.enter(0x08079660)) return;
    readTrackCmdHandler(TrackOffset.mod_type, 8, false);
}

pub fn func_0807966C() callconv(.c) void {
    if (!abi.enter(0x0807966C)) return;
    readTrackCmdHandler(TrackOffset.mod_depth, 8, false);
}

pub fn func_08079678() callconv(.c) void {
    if (!abi.enter(0x08079678)) return;
    readTrackCmdHandler(TrackOffset.mod_speed, 11, true);
}

pub fn func_0807968C() callconv(.c) void {
    if (!abi.enter(0x0807968C)) return;
    readTrackCmdHandler(TrackOffset.mod_delay, 11, true);
}

/// m4a VSync sound DMA wrapper (`0x0803D79C` -> `0x08077C04`).
pub fn func_0803D79C() callconv(.c) void {
    if (!abi.enter(0x0803D79C)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08077C04, 0x0803D7A3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// m4a per-frame main mixer wrapper (`0x0803D7AC` -> `0x080782E4`).
pub fn func_0803D7AC() callconv(.c) void {
    if (!abi.enter(0x0803D7AC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080782E4, 0x0803D7B3)) return;
    abi.fetches(4);
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08079610, .{ .name = "func_08079610", .linkage = .strong });
        @export(&func_08079624, .{ .name = "func_08079624", .linkage = .strong });
        @export(&func_08079638, .{ .name = "func_08079638", .linkage = .strong });
        @export(&func_0807964C, .{ .name = "func_0807964C", .linkage = .strong });
        @export(&func_08079660, .{ .name = "func_08079660", .linkage = .strong });
        @export(&func_0807966C, .{ .name = "func_0807966C", .linkage = .strong });
        @export(&func_08079678, .{ .name = "func_08079678", .linkage = .strong });
        @export(&func_0807968C, .{ .name = "func_0807968C", .linkage = .strong });
        @export(&func_0803D79C, .{ .name = "func_0803D79C", .linkage = .strong });
        @export(&func_0803D7AC, .{ .name = "func_0803D7AC", .linkage = .strong });
    }
}

test "MusicPlayerTrack offsets stay distinct and ordered" {
    try std.testing.expect(TrackOffset.mod_type < TrackOffset.mod_depth);
    try std.testing.expect(TrackOffset.mod_depth < TrackOffset.mod_speed);
    try std.testing.expect(TrackOffset.mod_speed < TrackOffset.mod_delay);
    try std.testing.expect(TrackOffset.mod_delay < TrackOffset.param_2c);
    try std.testing.expectEqual(@as(u32, 0x40), track_cmd_cursor_off);
}
