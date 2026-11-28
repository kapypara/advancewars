//! Unified Hardware Abstraction Layer (HAL) barrel module.
//! Submodules live under `src/game/hal/` (`config`, `bios`, `input`, `save`, `dma`, `audio`, `video`).

pub const config = @import("hal/config.zig");
pub const bios = @import("hal/bios.zig");
pub const input = @import("hal/input.zig");
pub const save = @import("hal/save.zig");
pub const dma = @import("hal/dma.zig");
pub const audio = @import("hal/audio.zig");
pub const video = @import("hal/video.zig");

pub const Backend = config.Backend;
pub const backend = config.backend;
pub const Swi = bios.Swi;
pub const DivResult = bios.DivResult;
pub const divPure = bios.divPure;

test {
    _ = config;
    _ = bios;
    _ = input;
    _ = save;
    _ = dma;
    _ = audio;
    _ = video;
}
