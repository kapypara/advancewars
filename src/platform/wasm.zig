const std = @import("std");
const builtin = @import("builtin");
const gba = @import("../gba/defs.zig");
const platform = @import("backend.zig");

const is_freestanding = builtin.os.tag == .freestanding;

const env = if (is_freestanding) struct {
    extern "env" fn host_present(fb_ptr: [*]const u32, fb_w: u32, fb_h: u32, audio_ptr: [*]const i16, audio_len: u32) void;
    extern "env" fn host_present_hud(ptr: [*]const u32, w: u32, h: u32) void;
    extern "env" fn host_poll_input() u32;
    extern "env" fn host_pace() void;
    extern "env" fn host_queued_audio_bytes() u32;
    extern "env" fn host_save_sram(ptr: [*]const u8, len: u32) void;
} else struct {
    fn host_present(_: [*]const u32, _: u32, _: u32, _: [*]const i16, _: u32) void {}
    fn host_present_hud(_: [*]const u32, _: u32, _: u32) void {}
    fn host_poll_input() u32 {
        return 0;
    }
    fn host_pace() void {}
    fn host_queued_audio_bytes() u32 {
        return 0;
    }
    fn host_save_sram(_: [*]const u8, _: u32) void {}
};

const max_pointer_queue: usize = 64;

/// Freestanding WebAssembly platform backend communicating with a Web Worker shell.
pub const WasmBackend = struct {
    var s_ptr_buf: [max_pointer_queue]platform.PointerEvent = undefined;
    var s_ptr_count: usize = 0;
    var rgba_buf: [gba.max_wide_width * gba.height]u32 = @splat(0);
    var empty_audio: [2]i16 = .{ 0, 0 };

    last_audio_ptr: [*]const i16 = &empty_audio,
    last_audio_len: u32 = 0,

    pub fn pushPointerRaw(id: i32, phase_raw: u32, lx: f32, ly: f32) void {
        if (phase_raw > @intFromEnum(platform.PointerPhase.scroll_down)) return;
        if (s_ptr_count >= s_ptr_buf.len) return;
        s_ptr_buf[s_ptr_count] = .{
            .id = id,
            .phase = @enumFromInt(@as(u8, @intCast(phase_raw))),
            .x = lx,
            .y = ly,
            .logical_x = lx,
            .logical_y = ly,
        };
        s_ptr_count += 1;
    }

    pub fn saveSram(ptr: [*]const u8, len: u32) void {
        env.host_save_sram(ptr, len);
    }

    pub fn init(self: *WasmBackend, _: u32, _: u32) bool {
        s_ptr_count = 0;
        self.last_audio_ptr = &empty_audio;
        self.last_audio_len = 0;
        return true;
    }

    pub fn pushAudio(self: *WasmBackend, samples: []const i16) void {
        if (samples.len == 0) return;
        self.last_audio_ptr = samples.ptr;
        self.last_audio_len = @intCast(samples.len);
    }

    pub fn present(self: *WasmBackend, frame: platform.VideoFrame, hud: platform.HudFrame) void {
        const total: usize = @as(usize, frame.width) * frame.height;
        if (frame.pixels.len < total or total > rgba_buf.len) return;
        // Convert 0xAARRGGBB (little-endian BGRA bytes) into 0xAABBGGRR (little-endian RGBA bytes for ImageData).
        for (frame.pixels[0..total], 0..) |px, i| {
            rgba_buf[i] = (px & 0xFF00_FF00) |
                ((px & 0x00FF_0000) >> 16) |
                ((px & 0x0000_00FF) << 16);
        }
        env.host_present(&rgba_buf, frame.width, frame.height, self.last_audio_ptr, self.last_audio_len);
        self.last_audio_len = 0;

        if (hud.dirty and hud.width >= gba.width and hud.pixels.len >= @as(usize, hud.width) * gba.height) {
            env.host_present_hud(hud.pixels.ptr, hud.width, gba.height);
        }
    }

    pub fn queuedAudioBytes(_: *const WasmBackend) u32 {
        return env.host_queued_audio_bytes();
    }

    pub fn pace(_: *WasmBackend) void {
        env.host_pace();
    }

    pub fn poll(_: *WasmBackend) platform.PollResult {
        const packed_input = env.host_poll_input();
        const has_overrides = (packed_input & (1 << 19)) != 0;
        const w: u16 = @truncate((packed_input >> 21) & 0x03FF);
        return .{
            .keys_pressed = @truncate(packed_input & 0x03FF),
            .quit = (packed_input & (1 << 16)) != 0,
            .toggle_hud = (packed_input & (1 << 17)) != 0,
            .toggle_mute = (packed_input & (1 << 18)) != 0,
            .toggle_widescreen = false,
            .hud_overlay = if (has_overrides) ((packed_input & (1 << 20)) != 0) else null,
            .widescreen_override = if (has_overrides) ((packed_input & (@as(u32, 1) << 31)) != 0) else null,
            .hud_width = w,
            .wide_width = if (w >= gba.width) w else gba.width,
        };
    }

    pub fn drainPointers(_: *WasmBackend, out: []platform.PointerEvent) []const platform.PointerEvent {
        const n = @min(s_ptr_count, out.len);
        @memcpy(out[0..n], s_ptr_buf[0..n]);
        s_ptr_count = 0;
        return out[0..n];
    }

    pub fn shutdown(self: *WasmBackend) void {
        s_ptr_count = 0;
        self.last_audio_len = 0;
    }
};

test "WasmBackend queues pointer events cleanly and swaps BGRA to RGBA" {
    var wb = WasmBackend{};
    try std.testing.expect(wb.init(240, 160));
    WasmBackend.pushPointerRaw(-2, @intFromEnum(platform.PointerPhase.right_down), 12.5, 34.5);
    WasmBackend.pushPointerRaw(-3, @intFromEnum(platform.PointerPhase.scroll_up), 0, 0);
    WasmBackend.pushPointerRaw(-1, 99, 0, 0); // ignored invalid phase
    var buf: [8]platform.PointerEvent = undefined;
    const drained = wb.drainPointers(&buf);
    try std.testing.expectEqual(@as(usize, 2), drained.len);
    try std.testing.expectEqual(platform.PointerPhase.right_down, drained[0].phase);
    try std.testing.expectEqual(platform.PointerPhase.scroll_up, drained[1].phase);

    var fb: [gba.width * gba.height]u32 = @splat(0xFF112233);
    wb.present(.{ .pixels = &fb, .width = gba.width, .height = gba.height }, .{});
    try std.testing.expectEqual(@as(u32, 0xFF332211), WasmBackend.rgba_buf[0]);
}
