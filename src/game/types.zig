//! Shared Advance Wars GBA memory addresses and core game structs verified
//! against live EWRAM/IWRAM and ROM disassembly inspection.

const std = @import("std");

/// Verified RAM addresses in Advance Wars (USA Rev 1).
pub const addr = struct {
    pub const vs_player_select_state: u32 = 0x0200_0036;
    pub const sys_state_ptr: u32 = 0x0201_00B0;
    pub const oam_attr_table: u32 = 0x0201_1924;
    pub const oam_queue: u32 = 0x0201_1D24;
    pub const bg2_reach_tilemap_buf: u32 = 0x0201_2B40;
    pub const bg_tilemap_buffer: u32 = 0x0201_3340;
    pub const map_workspace: u32 = 0x0201_57F8;
    pub const save_flags: u32 = 0x0201_F9A8;
    pub const save_records: u32 = 0x0201_F9F0;
    pub const ui_cursor_src_byte: u32 = 0x0201_FD1D;
    pub const camera_state_ptr: u32 = 0x0828_2CB4;
    pub const entity_table_ptr: u32 = 0x0828_2CBC;
    pub const unit_list_ptr: u32 = 0x0828_2CB8;
    pub const unit_data_table_9e88: u32 = 0x0828_9E88;
    pub const unit_cap_table_2ee5: u32 = 0x0828_2EE5;
    pub const map_overlay_ptr: u32 = 0x0828_C05C;

    pub const main_callback_slot: u32 = 0x0300_0D8C;
    pub const script_flag_0da4: u32 = 0x0300_0DA4;
    pub const camera_scroll_y_off: u32 = 0x0300_0DBC;
    pub const proc_table: u32 = 0x0300_0E10;
    pub const active_proc_idx: u32 = 0x0300_1D18;
    pub const camera_scroll_x_off: u32 = 0x0300_1D48;
    pub const script_pool: u32 = 0x0300_1D50;
    pub const anim_pool: u32 = 0x0300_2320;
    pub const oam_queue_used: u32 = 0x0300_2F00;
    pub const hw_init_flag_2f24: u32 = 0x0300_2F24;
    pub const script_flag_2f44: u32 = 0x0300_2F44;
    pub const script_var_31f8: u32 = 0x0300_31F8;
    pub const script_var_31fc: u32 = 0x0300_31FC;
    pub const battle_cmd_flag: u32 = 0x0300_3200;
    pub const turn_phase: u32 = 0x0300_357C;
    pub const menu_selection: u32 = 0x0300_3580;
    pub const battle_substate: u32 = 0x0300_35EC;
    pub const reachability_rows: u32 = 0x0300_3600;
    pub const cursor_x_px: u32 = 0x0300_36A0;
    pub const cursor_y_px: u32 = 0x0300_36A2;
    pub const cursor_tile_x: u32 = 0x0300_36A4;
    pub const cursor_tile_y: u32 = 0x0300_36A6;
    pub const active_cursor_state: u32 = 0x0300_36AC;
    pub const menu_guard: u32 = 0x0300_4280;
    pub const battle_ui_state: u32 = 0x0300_4310;
    pub const battle_lock_a: u32 = 0x0300_43C8;
    pub const battle_lock_b: u32 = 0x0300_4470;
    pub const battle_turn_counter: u32 = 0x0300_4474;
    pub const saved_cursor_tile: u32 = 0x0300_4444;
    pub const irq_handler_table: u32 = 0x0300_6630;
    pub const dispcnt_shadow: u32 = 0x0300_337C;
    pub const bldcnt_shadow: u32 = 0x0300_3354;
    pub const bldalpha_shadow: u32 = 0x0300_3384;
    pub const ui_blend_ctrl: u32 = 0x0300_3388;
    pub const ui_panel_mgr_ptr: u32 = 0x083B_918C;
    pub const save_flags_shadow: u32 = 0x0201_F9CC;
    pub const result_summary_buf: u32 = 0x0201_226C;
    pub const reg_keyinput: u32 = 0x0400_0130;
    pub const frame_tick_done: u32 = 0x0300_4434;
    pub const palette_synced_flag: u32 = 0x0300_0048;
    pub const palette_shadow_buf: u32 = 0x0300_1EF0;
    pub const pal_ram: u32 = 0x0500_0000;
    pub const frame_gate_mask: u32 = 0x0300_4358;
    pub const frame_gate_flags: u32 = 0x0300_47E4;
    pub const frame_submode: u32 = 0x0300_41FC;
    pub const unit_move_origin: u32 = 0x0300_41DC;
    pub const unit_move_target: u32 = 0x0300_33AC;
    pub const active_unit_ptr: u32 = 0x0300_4464;
    pub const task_queue_anchor: u32 = 0x0300_1ED8;
    pub const frame_input_state: u32 = 0x0300_1E70;
    pub const frame_input_shadow_a: u32 = 0x0300_4BF0;
    pub const frame_input_shadow_b: u32 = 0x0300_4B54;
    pub const sin_table_q12: u32 = 0x0827_D3A8;
    pub const dma_immediate_flag: u32 = 0x0300_48C0;
    pub const dma_queue_count: u32 = 0x0300_322C;
    pub const dma_queue_buf: u32 = 0x0201_0274;
};

pub const key_mask_all: u32 = 0x0000_03FF;
pub const key_mask_soft_reset: u32 = 0x0000_000F; // A | B | Select | Start
pub const pal_ram_size: u32 = 0x0400;
pub const dispcnt_forced_blank: u8 = 0x80;
pub const dma_queue_cap: usize = 0x30;
pub const reach_tile_tl: u16 = 0x8170;
pub const reach_tile_tr: u16 = 0x8171;
pub const reach_tile_bl: u16 = 0x8172;
pub const reach_tile_br: u16 = 0x8173;
pub const max_army_funds: u32 = 999_999;
pub const unit_record_stride: usize = 12;

/// Deferred VBlank DMA queue entry at `addr.dma_queue_buf` (`0x0201_0274`, stride 12 bytes).
pub const DmaQueueEntry = extern struct {
    src: u32,
    dst: u32,
    size: u16,
    mode: u8,
    _pad: u8,
};

/// Map workspace header at `addr.map_workspace` (`0x0201_57F8`).
pub const MapWorkspace = extern struct {
    width: u16,
    height: u16,
    cam_x: i16,
    cam_y: i16,
};

pub const map_meta_4722_off: u32 = 0x4722;
pub const map_meta_473b_off: u32 = 0x473B;

/// 40-slot GBA proc entry in `addr.proc_table` (`0x0300_0E10`, stride `0x60` bytes).
pub const proc_slot_count: usize = 40;
pub const proc_slot_stride: usize = 0x60;

pub const ProcSlot = extern struct {
    script_start: u32,
    script_cursor: u32,
    on_idle: u32,
    on_cycle: u32,
    sleep_timer: u16,
    flags: u16,
    _pad14: [0x12]u8,
    anim_slot: u16,
    card_x: i16,
    card_y: i16,
    _pad2c: [0x0C]u8,
    state38: u16,
    _pad3a: [0x26]u8,
};

/// Secondary cutscene/script pool at `addr.script_pool` (`0x0300_1D50`, stride `0x18` bytes).
pub const script_slot_stride: usize = 0x18;

pub const ScriptSlot = extern struct {
    script_start: u32,
    script_cursor: u32,
    _raw08: [0x10]u8,
};

/// Sprite/animator entry pool at `addr.anim_pool` (`0x0300_2320`, stride `0x4C` bytes).
pub const anim_slot_stride: usize = 0x4C;

pub const AnimSlot = extern struct {
    head: u32,
    script_start: u32,
    script_cursor: u32,
    _pad0c: [0x10]u8,
    timer: u16,
    _pad1e: u16,
    param0: u32,
    _pad24: [0x0C]u8,
    x_vec: u32,
    y_vec: u32,
    _pad38: [0x10]u8,
    script_table: u32,
};

/// Hardware-format OAM attribute entry at `addr.oam_attr_table` (`0x0201_1924`, stride 8 bytes).
pub const oam_attr_stride: usize = 8;

pub const OamAttr = extern struct {
    attr0: u16,
    attr1: u16,
    attr2: u16,
    affine_pad: u16,
};

/// OAM queue entry stride at `addr.oam_queue` (`0x0201_1D24`, stride `0x10` bytes).
pub const oam_queue_count: usize = 32;
pub const oam_queue_stride: usize = 0x10;

pub const OamQueueEntry = extern struct {
    raw: [0x10]u8,
};

/// Pixel and tile map cursor state at `addr.cursor_x_px` (`0x0300_36A0`).
pub const CursorState = extern struct {
    x_px: u16,
    y_px: u16,
    tile_x: u16,
    tile_y: u16,
};

/// Camera state pointed to by `addr.camera_state_ptr` (`0x0828_2CB4`).
pub const CameraState = extern struct {
    _pad00: [0x0C]u8,
    cam_x: u16,
    cam_y: u16,
};

/// Map entity table slot pointed to by `addr.entity_table_ptr` (`0x0828_2CBC`, stride `0x68`).
pub const entity_stride: usize = 0x68;

pub const UnitEntity = extern struct {
    gold: u32,
    _pad04: [0x16]u8,
    army_id: u8,
    _pad1b: [2]u8,
    co_id: u8,
    active_flag: u8,
    _pad1f: u8,
    funds: u32,
    _pad24: u8,
    counter25: u8,
    _pad26: [0x42]u8,
};

/// Map unit entry addressed by `addr.unit_list_ptr` (`0x0828_2CB8`, stride 12 bytes) and `BattleSideCtx.unit_ptr`.
pub const UnitRecord = extern struct {
    unit_type: u8,
    _pad01: u8,
    tile_x: u8,
    tile_y: u8,
    hp_flags: u8,
    state_flags: u8,
    _pad06: [6]u8,

    pub inline fn hp(self: UnitRecord) u8 {
        return self.hp_flags & 0x7F;
    }
};

/// Battle combatant context used by scaled damage helpers (`0x0802_34A0`).
pub const BattleSideCtx = extern struct {
    unit_ptr: u32,
    _pad04: u32,
    remaining_hp: i16,
    _pad0a: u16,
    attack_power: i16,
    defense_pct: i16,
    counter_power: i16,
    dealt_damage: i16,
};

/// 8-byte menu guard table entry at `addr.menu_guard` (`0x0300_4280`).
pub const MenuGuardEntry = extern struct {
    value: u8,
    key: u8,
    _pad02: [6]u8,
};

test "Advance Wars core extern struct sizes match GBA memory layout" {
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(MapWorkspace));
    try std.testing.expectEqual(@as(usize, proc_slot_stride), @sizeOf(ProcSlot));
    try std.testing.expectEqual(@as(usize, 0x12), @offsetOf(ProcSlot, "flags"));
    try std.testing.expectEqual(@as(usize, 0x26), @offsetOf(ProcSlot, "anim_slot"));
    try std.testing.expectEqual(@as(usize, 0x38), @offsetOf(ProcSlot, "state38"));
    try std.testing.expectEqual(@as(usize, script_slot_stride), @sizeOf(ScriptSlot));
    try std.testing.expectEqual(@as(usize, anim_slot_stride), @sizeOf(AnimSlot));
    try std.testing.expectEqual(@as(usize, 0x1C), @offsetOf(AnimSlot, "timer"));
    try std.testing.expectEqual(@as(usize, 0x30), @offsetOf(AnimSlot, "x_vec"));
    try std.testing.expectEqual(@as(usize, 0x48), @offsetOf(AnimSlot, "script_table"));
    try std.testing.expectEqual(@as(usize, oam_attr_stride), @sizeOf(OamAttr));
    try std.testing.expectEqual(@as(usize, oam_queue_stride), @sizeOf(OamQueueEntry));
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(CursorState));
    try std.testing.expectEqual(@as(usize, 0x10), @sizeOf(CameraState));
    try std.testing.expectEqual(@as(usize, 0x0C), @offsetOf(CameraState, "cam_x"));
    try std.testing.expectEqual(@as(usize, entity_stride), @sizeOf(UnitEntity));
    try std.testing.expectEqual(@as(usize, 0x00), @offsetOf(UnitEntity, "gold"));
    try std.testing.expectEqual(@as(usize, 0x1A), @offsetOf(UnitEntity, "army_id"));
    try std.testing.expectEqual(@as(usize, 0x1D), @offsetOf(UnitEntity, "co_id"));
    try std.testing.expectEqual(@as(usize, 0x1E), @offsetOf(UnitEntity, "active_flag"));
    try std.testing.expectEqual(@as(usize, 0x20), @offsetOf(UnitEntity, "funds"));
    try std.testing.expectEqual(@as(usize, 0x25), @offsetOf(UnitEntity, "counter25"));
    try std.testing.expectEqual(@as(usize, unit_record_stride), @sizeOf(UnitRecord));
    try std.testing.expectEqual(@as(usize, 0), @offsetOf(UnitRecord, "unit_type"));
    try std.testing.expectEqual(@as(usize, 2), @offsetOf(UnitRecord, "tile_x"));
    try std.testing.expectEqual(@as(usize, 3), @offsetOf(UnitRecord, "tile_y"));
    try std.testing.expectEqual(@as(usize, 4), @offsetOf(UnitRecord, "hp_flags"));
    try std.testing.expectEqual(@as(usize, 5), @offsetOf(UnitRecord, "state_flags"));
    try std.testing.expectEqual(@as(usize, 0x14), @sizeOf(BattleSideCtx));
    try std.testing.expectEqual(@as(usize, 0x0E), @offsetOf(BattleSideCtx, "defense_pct"));
    try std.testing.expectEqual(@as(usize, 0x10), @offsetOf(BattleSideCtx, "counter_power"));
    try std.testing.expectEqual(@as(usize, 0x12), @offsetOf(BattleSideCtx, "dealt_damage"));
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(MenuGuardEntry));
    try std.testing.expectEqual(@as(usize, 12), @sizeOf(DmaQueueEntry));
    try std.testing.expectEqual(@as(usize, 0), @offsetOf(DmaQueueEntry, "src"));
    try std.testing.expectEqual(@as(usize, 4), @offsetOf(DmaQueueEntry, "dst"));
    try std.testing.expectEqual(@as(usize, 8), @offsetOf(DmaQueueEntry, "size"));
    try std.testing.expectEqual(@as(usize, 10), @offsetOf(DmaQueueEntry, "mode"));
    try std.testing.expectEqual(@as(usize, 0x0201_57F8), addr.map_workspace);
    try std.testing.expectEqual(@as(usize, 0x0300_0E10), addr.proc_table);
}
