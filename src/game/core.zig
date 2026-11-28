//! Cross-importing core domain modules compiled together as a single object
//! so shared `@import`s do not duplicate strong `@export` symbols.

pub const bios = @import("bios.zig");
pub const dma = @import("dma.zig");
pub const hw = @import("hw.zig");
pub const unit = @import("unit.zig");
pub const battle = @import("battle.zig");

comptime {
    _ = bios;
    _ = dma;
    _ = hw;
    _ = unit;
    _ = battle;
}
