//! Shared Advance Wars GBA memory addresses and core game structs verified
//! against live EWRAM/IWRAM and ROM disassembly inspection.

const std = @import("std");

/// Verified RAM addresses in Advance Wars (USA Rev 1).
pub const addr = struct {
    pub const vs_player_select_state: u32 = 0x0200_0036;
    pub const oam_queue: u32 = 0x0201_1D24;
    pub const map_workspace: u32 = 0x0201_57F8;

    pub const proc_table: u32 = 0x0300_0E10;
    pub const script_pool: u32 = 0x0300_1D50;
    pub const anim_pool: u32 = 0x0300_2320;
    pub const turn_phase: u32 = 0x0300_357C;
    pub const battle_substate: u32 = 0x0300_35EC;
    pub const reachability_rows: u32 = 0x0300_3600;
    pub const cursor_x_px: u32 = 0x0300_36A0;
    pub const cursor_y_px: u32 = 0x0300_36A2;
    pub const cursor_tile_x: u32 = 0x0300_36A4;
    pub const cursor_tile_y: u32 = 0x0300_36A6;
    pub const battle_lock_a: u32 = 0x0300_43C8;
    pub const battle_lock_b: u32 = 0x0300_4470;
    pub const main_scene_fn: u32 = 0x0300_4478;
};

/// Map workspace header at `addr.map_workspace` (`0x0201_57F8`).
pub const MapWorkspace = extern struct {
    width: u16,
    height: u16,
    cam_x: i16,
    cam_y: i16,
};

/// 40-slot GBA proc entry in `addr.proc_table` (`0x0300_0E10`, stride `0x60` bytes).
pub const proc_slot_count: usize = 40;
pub const proc_slot_stride: usize = 0x60;

pub const ProcSlot = extern struct {
    script_start: u32,
    script_cursor: u32,
    on_idle: u32,
    on_cycle: u32,
    sleep_timer: u16,
    _pad12: [0x14]u8,
    anim_slot: u16,
    card_x: i16,
    card_y: i16,
    _pad2c: [0x0C]u8,
    state38: u16,
    _pad3a: [0x26]u8,
};

/// Secondary cutscene/script pool at `addr.script_pool` (`0x0300_1D50`, stride `0x18` bytes).
pub const script_slot_stride: usize = 0x18;

/// Sprite/animator entry pool at `addr.anim_pool` (`0x0300_2320`, stride `0x4C` bytes).
pub const anim_slot_stride: usize = 0x4C;

/// OAM queue entry stride at `addr.oam_queue` (`0x0201_1D24`, stride `0x10` bytes).
pub const oam_queue_stride: usize = 0x10;

test "Advance Wars core extern struct sizes match GBA memory layout" {
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(MapWorkspace));
    try std.testing.expectEqual(@as(usize, proc_slot_stride), @sizeOf(ProcSlot));
    try std.testing.expectEqual(@as(usize, 0x26), @offsetOf(ProcSlot, "anim_slot"));
    try std.testing.expectEqual(@as(usize, 0x38), @offsetOf(ProcSlot, "state38"));
    try std.testing.expectEqual(@as(usize, 0x0201_57F8), addr.map_workspace);
    try std.testing.expectEqual(@as(usize, 0x0300_0E10), addr.proc_table);
}
