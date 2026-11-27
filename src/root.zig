const std = @import("std");

pub const gba = @import("gba/defs.zig");
pub const ppu = @import("gba/ppu.zig");
pub const headless = @import("platform/headless.zig");
pub const platform = @import("platform/backend.zig");
pub const wasm_backend = @import("platform/wasm.zig");
pub const touch = @import("platform/touch.zig");
pub const audio = @import("gba/audio.zig");
pub const flash = @import("gba/flash.zig");
pub const timers = @import("gba/timers.zig");
pub const dma = @import("gba/dma.zig");
pub const bios = @import("gba/bios.zig");
pub const interp = @import("gba/interp.zig");
pub const is_headless: bool = @import("build_options").headless;

test {
    std.testing.refAllDecls(@This());
}
