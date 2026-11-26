const std = @import("std");

pub const gba = @import("gba.zig");
pub const ppu = @import("ppu.zig");
pub const headless = @import("headless.zig");
pub const platform = @import("platform.zig");
pub const is_headless: bool = @import("build_options").headless;

test {
    std.testing.refAllDecls(@This());
}
