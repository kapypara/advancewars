//! Native Zig game decompilation root module, compiled side-by-side with `gen/`.
//! Any strong `pub export fn func_080XXXXX()` symbol referenced here overrides the
//! corresponding weak fallback emitted by `gen/`.

pub const abi = @import("abi.zig");
pub const types = @import("types.zig");
pub const bios = @import("bios.zig");
pub const math = @import("math.zig");
pub const dma = @import("dma.zig");
pub const sound = @import("sound.zig");
pub const hw = @import("hw.zig");
pub const proc = @import("proc.zig");
pub const sprite_anim = @import("sprite_anim.zig");
pub const campaign = @import("campaign.zig");
pub const state = @import("state.zig");
pub const map = @import("map.zig");
pub const ui = @import("ui.zig");
pub const co = @import("co.zig");
pub const unit = @import("unit.zig");
pub const battle = @import("battle.zig");
pub const turn = @import("turn.zig");
pub const menu = @import("menu.zig");
pub const overlay = @import("overlay.zig");
pub const overlay_ext = @import("overlay_ext.zig");
pub const overlay_mid = @import("overlay_mid.zig");

comptime {
    _ = abi;
    _ = types;
    _ = bios;
    _ = math;
    _ = dma;
    _ = sound;
    _ = hw;
    _ = proc;
    _ = sprite_anim;
    _ = campaign;
    _ = state;
    _ = map;
    _ = ui;
    _ = co;
    _ = unit;
    _ = battle;
    _ = turn;
    _ = menu;
    _ = overlay;
    _ = overlay_ext;
    _ = overlay_mid;
}

test {
    _ = abi;
    _ = types;
    _ = bios;
    _ = math;
    _ = dma;
    _ = sound;
    _ = hw;
    _ = proc;
    _ = sprite_anim;
    _ = campaign;
    _ = state;
    _ = map;
    _ = ui;
    _ = co;
    _ = unit;
    _ = battle;
    _ = turn;
    _ = menu;
    _ = overlay;
    _ = overlay_ext;
    _ = overlay_mid;
}
