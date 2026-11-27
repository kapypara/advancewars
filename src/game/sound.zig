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

/// m4a no-op stub (`0x0803D710`).
pub fn func_0803D710() callconv(.c) void {
    if (!abi.enter(0x0803D710)) return;
    abi.fetches(3);
    abi.retLr();
}

/// Write audio status halfword at `0x0300_00E8` (`0x0803D714`).
pub fn func_0803D714() callconv(.c) void {
    if (!abi.enter(0x0803D714)) return;
    abi.fetches(5);
    const dst = abi.read32(0x0803D71C);
    abi.write16(dst, @truncate(rt.r[0]));
    rt.r[1] = dst;
    abi.retLr();
}

/// Write audio status halfword at `0x0300_00EA` (`0x0803D720`).
pub fn func_0803D720() callconv(.c) void {
    if (!abi.enter(0x0803D720)) return;
    abi.fetches(5);
    const dst = abi.read32(0x0803D728);
    abi.write16(dst, @truncate(rt.r[0]));
    rt.r[1] = dst;
    abi.retLr();
}

/// Reset audio slot halfword `[0x0300_00E6] = 0xFFFF` (`0x0803D954`).
pub fn func_0803D954() callconv(.c) void {
    if (!abi.enter(0x0803D954)) return;
    abi.fetches(7);
    const dst = abi.read32(0x0803D960);
    const fill = abi.read32(0x0803D964);
    abi.write16(dst, @truncate(fill));
    rt.r[1] = dst;
    rt.r[2] = fill;
    abi.setRegNz(&rt.r[0], fill);
    abi.retLr();
}

/// Zero 64 bytes (`4 x 16`) at `[r0]` (`0x080779D8`).
pub fn func_080779D8() callconv(.c) void {
    if (!abi.enter(0x080779D8)) return;
    abi.fetches(13);
    const saved_r4 = rt.r[4];
    var dst = rt.r[0];
    var i: u32 = 0;
    while (i < 16) : (i += 1) {
        abi.write32(dst, 0);
        dst +%= 4;
    }
    rt.r[0] = dst;
    rt.r[1] = 0;
    rt.r[2] = 0;
    rt.r[3] = 0;
    rt.r[4] = saved_r4;
    rt.updateNz(0);
    abi.retLr();
}

/// m4a `ply_tune` / track 32-bit LE command fetch into `track + 0x28`, stepping cursor `+0x40` by 4 (`0x080795B4`).
pub fn func_080795B4() callconv(.c) void {
    if (!abi.enter(0x080795B4)) return;
    abi.fetches(29);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const track = rt.r[1];
    const cmd = abi.read32(track +% track_cmd_cursor_off);
    const b0: u32 = abi.read8(cmd);
    const b1: u32 = abi.read8(cmd +% 1);
    const b2: u32 = abi.read8(cmd +% 2);
    const b3: u32 = abi.read8(cmd +% 3);
    const word: u32 = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
    abi.write32(track +% 0x28, word);
    const next_cmd = cmd +% 4;
    abi.write32(track +% track_cmd_cursor_off, next_cmd);

    rt.r[2] = next_cmd;
    rt.r[3] = b3 << 24;
    rt.updateNz(word);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

comptime {
    if (!builtin.is_test) {
        @export(&func_0803D710, .{ .name = "func_0803D710", .linkage = .strong });
        @export(&func_0803D714, .{ .name = "func_0803D714", .linkage = .strong });
        @export(&func_0803D720, .{ .name = "func_0803D720", .linkage = .strong });
        @export(&func_0803D79C, .{ .name = "func_0803D79C", .linkage = .strong });
        @export(&func_0803D7AC, .{ .name = "func_0803D7AC", .linkage = .strong });
        @export(&func_0803D954, .{ .name = "func_0803D954", .linkage = .strong });
        @export(&func_080779D8, .{ .name = "func_080779D8", .linkage = .strong });
        @export(&func_080795B4, .{ .name = "func_080795B4", .linkage = .strong });
        @export(&func_08079610, .{ .name = "func_08079610", .linkage = .strong });
        @export(&func_08079624, .{ .name = "func_08079624", .linkage = .strong });
        @export(&func_08079638, .{ .name = "func_08079638", .linkage = .strong });
        @export(&func_0807964C, .{ .name = "func_0807964C", .linkage = .strong });
        @export(&func_08079660, .{ .name = "func_08079660", .linkage = .strong });
        @export(&func_0807966C, .{ .name = "func_0807966C", .linkage = .strong });
        @export(&func_08079678, .{ .name = "func_08079678", .linkage = .strong });
        @export(&func_0807968C, .{ .name = "func_0807968C", .linkage = .strong });
    }
}

test "MusicPlayerTrack offsets stay distinct and ordered" {
    try std.testing.expect(TrackOffset.mod_type < TrackOffset.mod_depth);
    try std.testing.expect(TrackOffset.mod_depth < TrackOffset.mod_speed);
    try std.testing.expect(TrackOffset.mod_speed < TrackOffset.mod_delay);
    try std.testing.expect(TrackOffset.mod_delay < TrackOffset.param_2c);
    try std.testing.expectEqual(@as(u32, 0x40), track_cmd_cursor_off);
}
