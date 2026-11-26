const std = @import("std");

pub const gba = @import("gba.zig");
pub const ppu = @import("ppu.zig");
pub const headless = @import("headless.zig");
pub const platform = @import("platform.zig");
pub const touch = @import("touch.zig");
pub const audio = @import("audio.zig");
pub const flash = @import("runtime/flash.zig");
pub const timers = @import("runtime/timers.zig");
pub const dma = @import("runtime/dma.zig");
pub const bios = @import("runtime/bios.zig");
pub const interp = @import("runtime/interp.zig");
pub const is_headless: bool = @import("build_options").headless;

test {
    std.testing.refAllDecls(@This());
}
