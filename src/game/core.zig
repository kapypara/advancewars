//! Cross-importing core domain modules compiled together as a single object
//! so shared `@import`s do not duplicate strong `@export` symbols.

pub const bios = @import("bios.zig");
pub const math = @import("math.zig");
pub const dma = @import("dma.zig");
pub const hw = @import("hw.zig");
pub const main_loop = @import("main_loop.zig");
pub const sound = @import("sound.zig");
pub const proc = @import("proc.zig");
pub const sprite_anim = @import("sprite_anim.zig");
pub const state = @import("state.zig");
pub const map = @import("map.zig");
pub const co = @import("co.zig");
pub const unit = @import("unit.zig");
pub const battle = @import("battle.zig");
pub const turn = @import("turn.zig");
pub const menu = @import("menu.zig");
pub const campaign = @import("campaign.zig");
pub const ui = @import("ui.zig");

comptime {
    _ = bios;
    _ = math;
    _ = dma;
    _ = hw;
    _ = main_loop;
    _ = sound;
    _ = proc;
    _ = sprite_anim;
    _ = state;
    _ = map;
    _ = co;
    _ = unit;
    _ = battle;
    _ = turn;
    _ = menu;
    _ = campaign;
    _ = ui;
}
