//! Shared Advance Wars GBA memory addresses and core game structs verified
//! against live EWRAM/IWRAM inspection.

const std = @import("std");

/// Verified RAM addresses in Advance Wars (USA Rev 1).
pub const addr = struct {
    pub const vs_player_select_state: u32 = 0x0200_0036;
    pub const map_workspace: u32 = 0x0201_57F8;

    pub const proc_table: u32 = 0x0300_0E10;
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

/// 40-slot GBA proc entry in `addr.proc_table` (`0x0300_0E10`, stride `0x44` bytes).
pub const proc_slot_count: usize = 40;
pub const proc_slot_stride: usize = 0x44;

pub const ProcSlot = extern struct {
    script_ptr: u32,
    code_ptr: u32,
    on_idle: u32,
    on_end: u32,
    parent: u32,
    first_child: u32,
    prev_sibling: u32,
    next_sibling: u32,
    _reserved: [0x24]u8,
};

test "Advance Wars core extern struct sizes match GBA memory layout" {
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(MapWorkspace));
    try std.testing.expectEqual(@as(usize, proc_slot_stride), @sizeOf(ProcSlot));
    try std.testing.expectEqual(@as(usize, 0x0201_57F8), addr.map_workspace);
    try std.testing.expectEqual(@as(usize, 0x0300_0E10), addr.proc_table);
}
