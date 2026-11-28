//! Unified Hardware Abstraction Layer (HAL) barrel module.
//! Submodules live under `src/game/hal/` (`bios`, `input`, `save`, `dma`, `audio`, `video`).

pub const bios = @import("hal/bios.zig");
pub const input = @import("hal/input.zig");
pub const save = @import("hal/save.zig");
pub const dma = @import("hal/dma.zig");
pub const audio = @import("hal/audio.zig");
pub const video = @import("hal/video.zig");

pub const Swi = bios.Swi;
pub const DivResult = bios.DivResult;
pub const divPure = bios.divPure;

test {
    _ = bios;
    _ = input;
    _ = save;
    _ = dma;
    _ = audio;
    _ = video;
}
