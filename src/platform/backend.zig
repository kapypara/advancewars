const build_options = @import("build_options");
const gba = @import("../gba/defs.zig");

pub const PointerPhase = enum {
    down,
    move,
    up,
};

pub const PointerEvent = struct {
    id: i64,
    phase: PointerPhase,
    x: f32,
    y: f32,
    logical_x: f32,
    logical_y: f32,
};

pub const PollResult = struct {
    quit: bool = false,
    keys_pressed: u16 = 0,
    toggle_hud: bool = false,
    toggle_mute: bool = false,
};

const NoopBackend = struct {
    pub fn init(_: *NoopBackend, _: u32, _: u32) bool {
        return true;
    }

    pub fn present(_: *NoopBackend, _: *const [gba.width * gba.height]u32) void {}

    pub fn pushAudio(_: *NoopBackend, _: []const i16) void {}

    pub fn queuedAudioBytes(_: *const NoopBackend) u32 {
        return 0;
    }

    pub fn pace(_: *NoopBackend) void {}

    pub fn poll(_: *NoopBackend) PollResult {
        return .{};
    }

    pub fn drainPointers(_: *NoopBackend, _: []PointerEvent) []const PointerEvent {
        return &.{};
    }

    pub fn shutdown(_: *NoopBackend) void {}
};

pub const Backend = if (build_options.headless)
    NoopBackend
else
    @import("sdl2.zig").Sdl2Backend;
