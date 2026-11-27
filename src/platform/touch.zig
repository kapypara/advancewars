const std = @import("std");
const gba = @import("../gba/defs.zig");
const platform = @import("backend.zig");

pub const HudButton = enum(u3) {
    l = 0,
    start = 1,
    r = 2,
    b = 3,
    a = 4,

    pub fn keyMask(self: HudButton) u16 {
        return switch (self) {
            .l => gba.Key.l.mask(),
            .start => gba.Key.start.mask(),
            .r => gba.Key.r.mask(),
            .b => gba.Key.b.mask(),
            .a => gba.Key.a.mask(),
        };
    }

    pub fn label(self: HudButton) []const u8 {
        return switch (self) {
            .l => "L",
            .start => "ST",
            .r => "R",
            .b => "B",
            .a => "A",
        };
    }
};

pub const Rect = struct {
    x: i32,
    y: i32,
    w: i32,
    h: i32,

    pub fn contains(self: Rect, px: f32, py: f32) bool {
        const x0: f32 = @floatFromInt(self.x);
        const y0: f32 = @floatFromInt(self.y);
        const x1: f32 = @floatFromInt(self.x + self.w);
        const y1: f32 = @floatFromInt(self.y + self.h);
        return px >= x0 and px < x1 and py >= y0 and py < y1;
    }
};

pub const HudSpec = struct {
    button: HudButton,
    rect: Rect,
};

pub const max_hud_width: usize = 512;

/// Compute total HUD layer width (in 160p GBA logical pixels) spanning the
/// centered 240x160 game plus any horizontal side margins, kept even for
/// symmetric centering.
pub fn computeHudWidth(area_w: i32, game_h: i32) u16 {
    if (area_w <= 0 or game_h <= 0) return gba.width;
    const gba_w: i32 = @intCast(gba.width);
    const gba_h: i32 = @intCast(gba.height);
    const raw_w: i32 = @divTrunc(area_w * gba_h, game_h);
    const max_w: i32 = @intCast(max_hud_width);
    const clamped: i32 = std.math.clamp(raw_w, gba_w, max_w);
    const even_w: i32 = clamped - @mod(clamped, 2);
    return @intCast(@max(even_w, gba_w));
}

/// Button rect in `(hud_w x 160)` HUD layer coordinates `[0, hud_w)`.
pub fn hudBufferRect(button: HudButton, hud_w: u16) Rect {
    const w_i: i32 = @max(@as(i32, hud_w), @as(i32, gba.width));
    return switch (button) {
        .l => .{ .x = 2, .y = 2, .w = 18, .h = 12 },
        .start => .{ .x = w_i - 46, .y = 2, .w = 22, .h = 12 },
        .r => .{ .x = w_i - 20, .y = 2, .w = 18, .h = 12 },
        .b => .{ .x = w_i - 44, .y = 141, .w = 19, .h = 17 },
        .a => .{ .x = w_i - 22, .y = 141, .w = 19, .h = 17 },
    };
}

/// Hit-test HUD buttons using game-relative logical coordinates `(lx, ly)`, where
/// `[0, 240)` is the GBA screen and negative or `>= 240` coordinates lie in side margins.
pub fn hitTestHudWidth(lx: f32, ly: f32, hud_w: u16) ?HudButton {
    const w_i: i32 = @max(@as(i32, hud_w), @as(i32, gba.width));
    const pad_l: f32 = @floatFromInt(@divTrunc(w_i - @as(i32, gba.width), 2));
    const hx = lx + pad_l;
    for (hud_buttons) |spec| {
        if (hudBufferRect(spec.button, @intCast(w_i)).contains(hx, ly)) {
            return spec.button;
        }
    }
    return null;
}

/// Minimal corner HUD layout in logical 240x160 GBA coordinates (center map stays clear).
pub const hud_buttons = [_]HudSpec{
    .{ .button = .l, .rect = .{ .x = 2, .y = 2, .w = 18, .h = 12 } },
    .{ .button = .start, .rect = .{ .x = 194, .y = 2, .w = 22, .h = 12 } },
    .{ .button = .r, .rect = .{ .x = 220, .y = 2, .w = 18, .h = 12 } },
    .{ .button = .b, .rect = .{ .x = 196, .y = 141, .w = 19, .h = 17 } },
    .{ .button = .a, .rect = .{ .x = 218, .y = 141, .w = 19, .h = 17 } },
};

pub const max_map_dim: u16 = 32;

pub const UiMode = enum {
    title,
    dialog,
    yes_no_prompt,
    name_entry,
    battle_free_map,
    battle_unit_selected,
    battle_popup_menu,
    battle_unit_list,
    battle_attack_target,
    battle_deploy_shop,
    battle_intel_status,
    battle_co_info,
    battle_overlay,
    frontend_main_menu,
    frontend_map_select,
    frontend_co_setup,
    frontend_menu,
};

/// Advance Wars IWRAM/EWRAM/MMIO snapshot sampled once per interactive frame.
pub const GameState = struct {
    mode: UiMode = .frontend_menu,
    map_width: u16 = 0,
    map_height: u16 = 0,
    cursor_x: u16 = 0,
    cursor_y: u16 = 0,
    cam_x: i16 = 0,
    cam_y: i16 = 0,
    menu_x: i16 = 0,
    menu_y: i16 = 0,
    menu_count: u8 = 0,
    menu_selected: u8 = 0,
    reach_rows: [max_map_dim]u32 = @splat(0),

    pub fn isMapInteractive(self: GameState) bool {
        return self.mode == .battle_free_map or self.mode == .battle_unit_selected;
    }

    pub fn isReachable(self: GameState, tx: u16, ty: u16) bool {
        if (tx >= max_map_dim or ty >= max_map_dim) return false;
        if (self.map_width > 0 and tx >= self.map_width) return false;
        if (self.map_height > 0 and ty >= self.map_height) return false;
        return ((self.reach_rows[ty] >> @intCast(tx)) & 1) != 0;
    }

    pub fn setReachable(self: *GameState, tx: u16, ty: u16) void {
        if (tx < max_map_dim and ty < max_map_dim) {
            self.reach_rows[ty] |= (@as(u32, 1) << @intCast(tx));
        }
    }
};

pub const TileCoord = struct {
    x: u16 = 0,
    y: u16 = 0,
};

const max_pointers = 8;
const max_pulse_queue = 16;
const drag_threshold_sq: f32 = 10.0 * 10.0;
const swipe_step_px: f32 = 16.0;
const nav_pulse_frames: u8 = 3;
const nav_gap_frames: u8 = 3;
const nav_stall_limit: u16 = 24;
const min_button_frames: u8 = 3;

const DragKind = enum {
    none,
    move_cursor,
    paint_path,
    scroll_menu,
};

const PointerSlot = struct {
    active: bool = false,
    id: i64 = 0,
    hud_button: ?HudButton = null,
    held_frames: u8 = 0,
    start_x: f32 = 0,
    start_y: f32 = 0,
    anchor_x: f32 = 0,
    anchor_y: f32 = 0,
    dragged: bool = false,
    mode_on_down: UiMode = .frontend_menu,
    drag_kind: DragKind = .none,
    start_tile: TileCoord = .{},
    last_paint_tile: ?TileCoord = null,
};

const Pulse = struct {
    mask: u16 = 0,
    on_frames: u8 = 0,
    gap_frames: u8 = 0,
};

/// Touch + mouse controller combining Tier 1 corner HUD buttons and
/// Tier 2 direct map-tile tapping, menu/dialog taps, and drag gestures.
pub const TouchController = struct {
    hud_visible: bool = true,
    hud_width: u16 = gba.width,
    pointers: [max_pointers]PointerSlot = @splat(.{}),
    hud_held_mask: u16 = 0,
    right_held: bool = false,
    right_held_frames: u8 = 0,

    pulse_queue: [max_pulse_queue]Pulse = @splat(.{}),
    pulse_head: usize = 0,
    pulse_count: usize = 0,
    pulse_active_mask: u16 = 0,
    pulse_timer: u8 = 0,
    pulse_in_gap: bool = false,
    pulse_gap_rem: u8 = 0,

    nav_target: ?TileCoord = null,
    nav_timer: u8 = 0,
    nav_in_gap: bool = false,
    nav_key_mask: u16 = 0,
    nav_last_cursor: TileCoord = .{},
    nav_stall_frames: u16 = 0,
    nav_steps: u16 = 0,

    menu_nav_target: ?u8 = null,
    menu_nav_confirm: bool = false,
    menu_nav_timer: u8 = 0,
    menu_nav_in_gap: bool = false,
    menu_nav_last_idx: u8 = 0,
    menu_nav_stall: u8 = 0,
    menu_nav_key_mask: u16 = 0,

    atk_target_goal: ?TileCoord = null,
    atk_cycle_start: TileCoord = .{},
    atk_cycle_moved: bool = false,
    atk_cycle_steps: u8 = 0,
    atk_cycle_timer: u8 = 0,
    atk_cycle_in_gap: bool = false,
    atk_cycle_last_cur: TileCoord = .{},
    atk_cycle_stall: u8 = 0,
    atk_cycle_key_mask: u16 = 0,

    name_nav_target: ?TileCoord = null,
    name_nav_timer: u8 = 0,
    name_nav_in_gap: bool = false,
    name_nav_last: TileCoord = .{},
    name_nav_stall: u8 = 0,
    name_nav_key_mask: u16 = 0,

    reticle_tile: ?TileCoord = null,
    reticle_cam_x: i16 = 0,
    reticle_cam_y: i16 = 0,
    reticle_timer: u8 = 0,

    pub fn setHudVisible(self: *TouchController, visible: bool) void {
        if (self.hud_visible == visible) return;
        self.hud_visible = visible;
        if (!self.hud_visible) {
            for (&self.pointers) |*slot| {
                if (slot.active and slot.hud_button != null) {
                    slot.active = false;
                    slot.hud_button = null;
                    slot.held_frames = 0;
                }
            }
            self.recomputeHudMask();
        }
    }

    pub fn toggleHud(self: *TouchController) void {
        self.setHudVisible(!self.hud_visible);
    }

    pub fn setHudWidth(self: *TouchController, width: u16) void {
        const clamped: u16 = std.math.clamp(
            width,
            @as(u16, @intCast(gba.width)),
            @as(u16, @intCast(max_hud_width)),
        );
        self.hud_width = clamped - @mod(clamped, 2);
    }

    pub fn activeKeys(self: *const TouchController) u16 {
        return self.hud_held_mask |
            self.pulse_active_mask |
            self.nav_key_mask |
            self.menu_nav_key_mask |
            self.atk_cycle_key_mask |
            self.name_nav_key_mask |
            (if (self.right_held) gba.Key.b.mask() else 0);
    }

    pub fn hitTestHud(lx: f32, ly: f32) ?HudButton {
        return hitTestHudWidth(lx, ly, gba.width);
    }

    pub fn screenToTile(lx: f32, ly: f32, state: GameState) TileCoord {
        const clamped_x = std.math.clamp(@as(i32, @intFromFloat(@floor(lx))), 0, @as(i32, @intCast(gba.width)) - 1);
        const clamped_y = std.math.clamp(@as(i32, @intFromFloat(@floor(ly))), 0, @as(i32, @intCast(gba.height)) - 1);
        const wx = @max(clamped_x + @as(i32, state.cam_x), 0);
        const wy = @max(clamped_y + @as(i32, state.cam_y), 0);
        var tx: i32 = @divTrunc(wx, 16);
        var ty: i32 = @divTrunc(wy, 16);
        if (state.map_width > 0) {
            tx = std.math.clamp(tx, @as(i32, 0), @as(i32, state.map_width) - 1);
        }
        if (state.map_height > 0) {
            ty = std.math.clamp(ty, @as(i32, 0), @as(i32, state.map_height) - 1);
        }
        return .{
            .x = @intCast(tx),
            .y = @intCast(ty),
        };
    }

    fn enqueuePulse(self: *TouchController, mask: u16, on_frames: u8, gap_frames: u8) void {
        if (mask == 0 or self.pulse_count >= max_pulse_queue) return;
        const tail = (self.pulse_head + self.pulse_count) % max_pulse_queue;
        self.pulse_queue[tail] = .{
            .mask = mask,
            .on_frames = on_frames,
            .gap_frames = gap_frames,
        };
        self.pulse_count += 1;
    }

    fn clearPulseQueue(self: *TouchController) void {
        self.pulse_head = 0;
        self.pulse_count = 0;
    }

    fn startNavigation(self: *TouchController, target: TileCoord, state: GameState) void {
        self.nav_target = target;
        self.nav_timer = 0;
        self.nav_in_gap = false;
        self.nav_key_mask = 0;
        self.nav_last_cursor = .{ .x = state.cursor_x, .y = state.cursor_y };
        self.nav_stall_frames = 0;
        self.nav_steps = 0;
        self.reticle_tile = target;
        self.reticle_cam_x = state.cam_x;
        self.reticle_cam_y = state.cam_y;
        self.reticle_timer = 18;
    }

    fn clearMenuNavigation(self: *TouchController) void {
        self.menu_nav_target = null;
        self.menu_nav_confirm = false;
        self.menu_nav_timer = 0;
        self.menu_nav_in_gap = false;
        self.menu_nav_last_idx = 0;
        self.menu_nav_stall = 0;
        self.menu_nav_key_mask = 0;
    }

    fn startMenuNavigation(self: *TouchController, target: u8, confirm: bool, state: GameState) void {
        self.menu_nav_target = target;
        self.menu_nav_confirm = confirm;
        self.menu_nav_timer = 0;
        self.menu_nav_in_gap = false;
        self.menu_nav_last_idx = state.menu_selected;
        self.menu_nav_stall = 0;
        self.menu_nav_key_mask = 0;
    }

    fn clearAttackTargetCycle(self: *TouchController) void {
        self.atk_target_goal = null;
        self.atk_cycle_start = .{};
        self.atk_cycle_moved = false;
        self.atk_cycle_steps = 0;
        self.atk_cycle_timer = 0;
        self.atk_cycle_in_gap = false;
        self.atk_cycle_last_cur = .{};
        self.atk_cycle_stall = 0;
        self.atk_cycle_key_mask = 0;
    }

    fn startAttackTargetCycle(self: *TouchController, goal: TileCoord, state: GameState) void {
        self.atk_target_goal = goal;
        self.atk_cycle_start = .{ .x = state.cursor_x, .y = state.cursor_y };
        self.atk_cycle_moved = false;
        self.atk_cycle_steps = 0;
        self.atk_cycle_timer = 0;
        self.atk_cycle_in_gap = false;
        self.atk_cycle_last_cur = .{ .x = state.cursor_x, .y = state.cursor_y };
        self.atk_cycle_stall = 0;
        self.atk_cycle_key_mask = 0;
    }

    fn clearNameEntryNavigation(self: *TouchController) void {
        self.name_nav_target = null;
        self.name_nav_timer = 0;
        self.name_nav_in_gap = false;
        self.name_nav_last = .{};
        self.name_nav_stall = 0;
        self.name_nav_key_mask = 0;
    }

    fn startNameEntryNavigation(self: *TouchController, target: TileCoord, state: GameState) void {
        self.name_nav_target = target;
        self.name_nav_timer = 0;
        self.name_nav_in_gap = false;
        self.name_nav_last = .{ .x = state.cursor_x, .y = state.cursor_y };
        self.name_nav_stall = 0;
        self.name_nav_key_mask = 0;
    }

    fn cancelNavigation(self: *TouchController) void {
        self.nav_target = null;
        self.nav_key_mask = 0;
        self.nav_timer = 0;
        self.nav_in_gap = false;
        self.clearMenuNavigation();
        self.clearAttackTargetCycle();
        self.clearNameEntryNavigation();
    }

    fn recomputeHudMask(self: *TouchController) void {
        var mask: u16 = 0;
        for (self.pointers) |slot| {
            if (slot.active) {
                if (slot.hud_button) |btn| {
                    mask |= btn.keyMask();
                }
            }
        }
        self.hud_held_mask = mask;
    }

    fn findSlot(self: *TouchController, id: i64) ?*PointerSlot {
        for (&self.pointers) |*slot| {
            if (slot.active and slot.id == id) return slot;
        }
        return null;
    }

    fn allocSlot(self: *TouchController) ?*PointerSlot {
        for (&self.pointers) |*slot| {
            if (!slot.active) return slot;
        }
        return null;
    }

    fn findReachableNextStep(state: GameState, start: TileCoord, goal: TileCoord) ?u16 {
        if (start.x == goal.x and start.y == goal.y) return null;
        if (start.x >= max_map_dim or start.y >= max_map_dim) return null;
        if (goal.x >= max_map_dim or goal.y >= max_map_dim) return null;

        const max_cells: usize = @as(usize, max_map_dim) * @as(usize, max_map_dim);
        var queue: [max_cells]TileCoord = undefined;
        var first_dir: [max_cells]u16 = undefined;
        var visited: [max_map_dim]u32 = @splat(0);

        var head: usize = 0;
        var tail: usize = 1;
        queue[0] = start;
        first_dir[0] = 0;
        visited[start.y] |= (@as(u32, 1) << @intCast(start.x));

        const deltas = [_]struct { dx: i32, dy: i32, mask: u16 }{
            .{ .dx = 1, .dy = 0, .mask = gba.Key.right.mask() },
            .{ .dx = -1, .dy = 0, .mask = gba.Key.left.mask() },
            .{ .dx = 0, .dy = 1, .mask = gba.Key.down.mask() },
            .{ .dx = 0, .dy = -1, .mask = gba.Key.up.mask() },
        };

        while (head < tail) : (head += 1) {
            const cur = queue[head];
            const base_dir = first_dir[head];
            for (deltas) |d| {
                const nxi: i32 = @as(i32, cur.x) + d.dx;
                const nyi: i32 = @as(i32, cur.y) + d.dy;
                if (nxi < 0 or nyi < 0 or nxi >= max_map_dim or nyi >= max_map_dim) continue;
                const nx: u16 = @intCast(nxi);
                const ny: u16 = @intCast(nyi);
                if (!state.isReachable(nx, ny)) continue;
                if (((visited[ny] >> @intCast(nx)) & 1) != 0) continue;

                const step_dir = if (base_dir != 0) base_dir else d.mask;
                if (nx == goal.x and ny == goal.y) return step_dir;

                visited[ny] |= (@as(u32, 1) << @intCast(nx));
                queue[tail] = .{ .x = nx, .y = ny };
                first_dir[tail] = step_dir;
                tail += 1;
            }
        }
        return null;
    }

    pub fn handlePointer(self: *TouchController, ev: platform.PointerEvent, state: GameState) void {
        switch (ev.phase) {
            .down => {
                const slot = self.findSlot(ev.id) orelse self.allocSlot() orelse return;
                const hud_hit = if (self.hud_visible) hitTestHudWidth(ev.logical_x, ev.logical_y, self.hud_width) else null;
                slot.* = .{
                    .active = true,
                    .id = ev.id,
                    .hud_button = hud_hit,
                    .held_frames = 0,
                    .start_x = ev.logical_x,
                    .start_y = ev.logical_y,
                    .anchor_x = ev.logical_x,
                    .anchor_y = ev.logical_y,
                    .dragged = false,
                    .mode_on_down = state.mode,
                    .drag_kind = .none,
                    .start_tile = screenToTile(ev.logical_x, ev.logical_y, state),
                    .last_paint_tile = null,
                };
                if (hud_hit != null) {
                    self.recomputeHudMask();
                }
            },
            .move => {
                const slot = self.findSlot(ev.id) orelse return;
                if (slot.hud_button) |old_btn| {
                    const now_btn = if (self.hud_visible) hitTestHudWidth(ev.logical_x, ev.logical_y, self.hud_width) else null;
                    if (now_btn != old_btn) {
                        slot.hud_button = now_btn;
                        slot.held_frames = 0;
                        self.recomputeHudMask();
                    }
                    return;
                }

                const dx_start = ev.logical_x - slot.start_x;
                const dy_start = ev.logical_y - slot.start_y;
                const dist_sq = dx_start * dx_start + dy_start * dy_start;

                if (slot.mode_on_down == .battle_free_map) {
                    if (!slot.dragged and dist_sq >= drag_threshold_sq) {
                        slot.dragged = true;
                        slot.drag_kind = .move_cursor;
                        self.cancelNavigation();
                    }
                    if (slot.drag_kind == .move_cursor) {
                        // Moving cursor on the map mimics finger motion.
                        while (ev.logical_x - slot.anchor_x >= swipe_step_px) {
                            if (self.pulse_count < 3) self.enqueuePulse(gba.Key.right.mask(), 3, 2);
                            slot.anchor_x += swipe_step_px;
                        }
                        while (slot.anchor_x - ev.logical_x >= swipe_step_px) {
                            if (self.pulse_count < 3) self.enqueuePulse(gba.Key.left.mask(), 3, 2);
                            slot.anchor_x -= swipe_step_px;
                        }
                        while (ev.logical_y - slot.anchor_y >= swipe_step_px) {
                            if (self.pulse_count < 3) self.enqueuePulse(gba.Key.down.mask(), 3, 2);
                            slot.anchor_y += swipe_step_px;
                        }
                        while (slot.anchor_y - ev.logical_y >= swipe_step_px) {
                            if (self.pulse_count < 3) self.enqueuePulse(gba.Key.up.mask(), 3, 2);
                            slot.anchor_y -= swipe_step_px;
                        }
                    }
                } else if (slot.mode_on_down == .battle_unit_selected) {
                    const gba_w: f32 = @floatFromInt(gba.width);
                    const gba_h: f32 = @floatFromInt(gba.height);
                    const in_bounds = ev.logical_x >= 0 and ev.logical_y >= 0 and ev.logical_x < gba_w and ev.logical_y < gba_h;
                    const tile = screenToTile(ev.logical_x, ev.logical_y, state);
                    if (!slot.dragged and (dist_sq >= drag_threshold_sq or tile.x != slot.start_tile.x or tile.y != slot.start_tile.y)) {
                        slot.dragged = true;
                        slot.drag_kind = .paint_path;
                    }
                    if (slot.drag_kind == .paint_path and state.mode == .battle_unit_selected and in_bounds) {
                        if (state.isReachable(tile.x, tile.y)) {
                            const changed = if (slot.last_paint_tile) |prev| (prev.x != tile.x or prev.y != tile.y) else true;
                            if (changed) {
                                slot.last_paint_tile = tile;
                                if (tile.x != state.cursor_x or tile.y != state.cursor_y) {
                                    if (self.nav_target != null) {
                                        self.nav_target = tile;
                                        self.nav_stall_frames = 0;
                                        self.reticle_tile = tile;
                                        self.reticle_cam_x = state.cam_x;
                                        self.reticle_cam_y = state.cam_y;
                                        self.reticle_timer = 18;
                                    } else {
                                        self.startNavigation(tile, state);
                                    }
                                } else {
                                    self.reticle_tile = tile;
                                    self.reticle_cam_x = state.cam_x;
                                    self.reticle_cam_y = state.cam_y;
                                    self.reticle_timer = 18;
                                }
                            }
                        }
                    }
                } else if (slot.mode_on_down == .battle_popup_menu or
                    slot.mode_on_down == .battle_unit_list or
                    slot.mode_on_down == .battle_attack_target or
                    slot.mode_on_down == .battle_deploy_shop or
                    slot.mode_on_down == .battle_intel_status or
                    slot.mode_on_down == .battle_co_info or
                    slot.mode_on_down == .battle_overlay or
                    slot.mode_on_down == .dialog or
                    slot.mode_on_down == .yes_no_prompt or
                    slot.mode_on_down == .name_entry or
                    slot.mode_on_down == .frontend_main_menu or
                    slot.mode_on_down == .frontend_map_select or
                    slot.mode_on_down == .frontend_co_setup or
                    slot.mode_on_down == .frontend_menu)
                {
                    if (!slot.dragged and dist_sq >= drag_threshold_sq) {
                        slot.dragged = true;
                        slot.drag_kind = .scroll_menu;
                        self.cancelNavigation();
                    }
                    if (slot.drag_kind == .scroll_menu) {
                        // Natural scrolling in menus: swipe up scrolls down, swipe down scrolls up.
                        while (ev.logical_x - slot.anchor_x <= -swipe_step_px) {
                            if (self.pulse_count < 3) self.enqueuePulse(gba.Key.right.mask(), 3, 2);
                            slot.anchor_x -= swipe_step_px;
                        }
                        while (ev.logical_x - slot.anchor_x >= swipe_step_px) {
                            if (self.pulse_count < 3) self.enqueuePulse(gba.Key.left.mask(), 3, 2);
                            slot.anchor_x += swipe_step_px;
                        }
                        while (ev.logical_y - slot.anchor_y <= -swipe_step_px) {
                            if (self.pulse_count < 3) self.enqueuePulse(gba.Key.down.mask(), 3, 2);
                            slot.anchor_y -= swipe_step_px;
                        }
                        while (ev.logical_y - slot.anchor_y >= swipe_step_px) {
                            if (self.pulse_count < 3) self.enqueuePulse(gba.Key.up.mask(), 3, 2);
                            slot.anchor_y += swipe_step_px;
                        }
                    }
                } else {
                    if (!slot.dragged and dist_sq >= drag_threshold_sq) {
                        slot.dragged = true;
                    }
                }
            },
            .up => {
                const slot = self.findSlot(ev.id) orelse return;
                const hud_btn = slot.hud_button;
                const held = slot.held_frames;
                const was_dragged = slot.dragged;
                const drag_kind = slot.drag_kind;
                slot.active = false;
                slot.hud_button = null;
                slot.held_frames = 0;
                slot.drag_kind = .none;
                if (hud_btn) |btn| {
                    if (held < min_button_frames) {
                        self.enqueuePulse(btn.keyMask(), min_button_frames - held, 1);
                    }
                    self.recomputeHudMask();
                    return;
                }
                if (was_dragged) {
                    if (drag_kind == .move_cursor or drag_kind == .scroll_menu) {
                        self.clearPulseQueue();
                    }
                    return;
                }

                self.handleCanvasTap(ev.logical_x, ev.logical_y, state);
            },
            .right_down => {
                self.cancelNavigation();
                self.right_held = true;
                self.right_held_frames = 0;
            },
            .right_up => {
                if (self.right_held and self.right_held_frames < min_button_frames) {
                    self.enqueuePulse(gba.Key.b.mask(), min_button_frames - self.right_held_frames, 1);
                }
                self.right_held = false;
                self.right_held_frames = 0;
            },
            .scroll_up => {
                self.cancelNavigation();
                self.enqueuePulse(gba.Key.up.mask(), 3, 2);
            },
            .scroll_down => {
                self.cancelNavigation();
                self.enqueuePulse(gba.Key.down.mask(), 3, 2);
            },
        }
    }

    fn handleCanvasTap(self: *TouchController, lx: f32, ly: f32, state: GameState) void {
        if (lx < 0 or ly < 0 or lx >= @as(f32, @floatFromInt(gba.width)) or ly >= @as(f32, @floatFromInt(gba.height))) {
            return;
        }

        switch (state.mode) {
            .battle_free_map => {
                const tile = screenToTile(lx, ly, state);
                if (tile.x == state.cursor_x and tile.y == state.cursor_y) {
                    self.cancelNavigation();
                    self.reticle_tile = tile;
                    self.reticle_cam_x = state.cam_x;
                    self.reticle_cam_y = state.cam_y;
                    self.reticle_timer = 18;
                    self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                } else {
                    self.startNavigation(tile, state);
                }
            },
            .battle_unit_selected => {
                const tile = screenToTile(lx, ly, state);
                if (state.isReachable(tile.x, tile.y)) {
                    if (tile.x == state.cursor_x and tile.y == state.cursor_y) {
                        self.cancelNavigation();
                        self.reticle_tile = tile;
                        self.reticle_cam_x = state.cam_x;
                        self.reticle_cam_y = state.cam_y;
                        self.reticle_timer = 18;
                        self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                    } else {
                        self.startNavigation(tile, state);
                    }
                } else {
                    // Tapping outside the unit's movement range simply cancels/deselects (B).
                    self.cancelNavigation();
                    self.reticle_timer = 0;
                    self.enqueuePulse(gba.Key.b.mask(), 4, 2);
                }
            },
            .battle_popup_menu => {
                const px_i: i32 = @intFromFloat(@floor(lx));
                const py_i: i32 = @intFromFloat(@floor(ly));
                const x0: i32 = @as(i32, state.menu_x) - 10;
                const x1: i32 = @as(i32, state.menu_x) + 68;
                const y0: i32 = state.menu_y;
                const y1: i32 = y0 + @as(i32, state.menu_count) * 16;
                self.cancelNavigation();
                if (state.menu_count > 0 and px_i >= x0 and px_i < x1 and py_i >= y0 and py_i < y1) {
                    const row: u8 = @intCast(@divTrunc(py_i - y0, 16));
                    if (row == state.menu_selected) {
                        self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                    } else {
                        self.startMenuNavigation(row, true, state);
                    }
                } else {
                    self.enqueuePulse(gba.Key.b.mask(), 4, 2);
                }
            },
            .battle_unit_list => {
                if (ly >= 32 and ly < 52) {
                    if (lx >= 44 and lx < 68) {
                        self.cancelNavigation();
                        self.enqueuePulse(gba.Key.left.mask(), 4, 2);
                        return;
                    } else if (lx >= 96 and lx < 120) {
                        self.cancelNavigation();
                        self.enqueuePulse(gba.Key.right.mask(), 4, 2);
                        return;
                    }
                }
                const py_i: i32 = @intFromFloat(@floor(ly));
                const vis_count: i32 = if (state.menu_count > 0) @as(i32, state.menu_count) else 6;
                if (lx >= 8 and lx < 232 and py_i >= 56 and py_i < 56 + vis_count * 16) {
                    const row: u8 = @intCast(@divTrunc(py_i - 56, 16));
                    self.cancelNavigation();
                    if (row == state.menu_selected) {
                        self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                    } else {
                        self.startMenuNavigation(row, false, state);
                    }
                }
            },
            .battle_attack_target => {
                const tile = screenToTile(lx, ly, state);
                self.cancelNavigation();
                if (tile.x == state.cursor_x and tile.y == state.cursor_y) {
                    self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                } else {
                    self.startAttackTargetCycle(tile, state);
                }
            },
            .battle_deploy_shop => {
                const py_i: i32 = @intFromFloat(@floor(ly));
                const vis_count: i32 = if (state.menu_count > 0) @as(i32, state.menu_count) else 7;
                if (lx >= 8 and lx < 128 and py_i >= 40 and py_i < 40 + vis_count * 16) {
                    const row: u8 = @intCast(@divTrunc(py_i - 40, 16));
                    self.cancelNavigation();
                    if (row == state.menu_selected) {
                        self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                    } else {
                        self.startMenuNavigation(row, false, state);
                    }
                } else if (lx >= 48 and lx < 88 and py_i >= 30 and py_i < 40) {
                    self.cancelNavigation();
                    self.enqueuePulse(gba.Key.up.mask(), 4, 2);
                } else if (lx >= 48 and lx < 88 and py_i >= 152 and py_i < 160) {
                    self.cancelNavigation();
                    self.enqueuePulse(gba.Key.down.mask(), 4, 2);
                }
            },
            .battle_intel_status => {
                if (lx < 20 and ly < 30) {
                    self.cancelNavigation();
                    self.enqueuePulse(gba.Key.left.mask(), 4, 2);
                } else if (lx >= 36 and lx < 88 and ly < 30) {
                    self.cancelNavigation();
                    self.enqueuePulse(gba.Key.right.mask(), 4, 2);
                } else if (ly >= 118) {
                    self.cancelNavigation();
                    self.enqueuePulse(gba.Key.b.mask(), 4, 2);
                }
            },
            .battle_co_info => {
                if (lx >= 4 and lx < 28 and ly >= 4 and ly < 28) {
                    self.cancelNavigation();
                    self.enqueuePulse(gba.Key.l.mask(), 4, 2);
                } else if (lx >= 108 and lx < 136 and ly >= 4 and ly < 28) {
                    self.cancelNavigation();
                    self.enqueuePulse(gba.Key.r.mask(), 4, 2);
                } else if (lx >= 4 and lx < 136 and ly >= 30) {
                    self.cancelNavigation();
                    self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                }
            },
            .battle_overlay => {
                self.cancelNavigation();
                self.enqueuePulse(gba.Key.a.mask(), 4, 2);
            },
            .dialog => {
                self.cancelNavigation();
                self.enqueuePulse(gba.Key.a.mask(), 4, 2);
            },
            .yes_no_prompt => {
                const yes_x: i32 = if (state.menu_x > 0) state.menu_x else 64;
                const px_i: i32 = @intFromFloat(@floor(lx));
                const py_i: i32 = @intFromFloat(@floor(ly));
                if (py_i < 112) return;
                if (px_i >= yes_x - 8 and px_i < yes_x + 32) {
                    self.cancelNavigation();
                    if (state.menu_selected == 0) {
                        self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                    } else {
                        self.startMenuNavigation(0, true, state);
                    }
                } else if (px_i >= yes_x + 32 and px_i < yes_x + 76) {
                    self.cancelNavigation();
                    if (state.menu_selected == 1) {
                        self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                    } else {
                        self.startMenuNavigation(1, true, state);
                    }
                }
            },
            .name_entry => {
                const px_i: i32 = @intFromFloat(@floor(lx));
                const py_i: i32 = @intFromFloat(@floor(ly));
                if (py_i >= 130 and py_i < 152) {
                    if (px_i >= 156 and px_i < 188) {
                        self.cancelNavigation();
                        self.enqueuePulse(gba.Key.b.mask(), 4, 2);
                        return;
                    } else if (px_i >= 191 and px_i < 224) {
                        self.cancelNavigation();
                        if (state.cursor_y == 5 and state.cursor_x >= 11) {
                            self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                        } else {
                            self.enqueuePulse(gba.Key.start.mask(), 4, 6);
                            self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                        }
                        return;
                    }
                }
                if (py_i >= 48 and py_i < 128 and px_i >= 86 and px_i < 222) {
                    const row: u16 = @intCast(@divTrunc(py_i - 48, 16));
                    const col: u16 = if (px_i < 131)
                        @intCast(std.math.clamp(@divTrunc(px_i - 88, 8), 0, 4))
                    else if (px_i < 176)
                        @intCast(5 + std.math.clamp(@divTrunc(px_i - 133, 8), 0, 4))
                    else
                        @intCast(10 + std.math.clamp(@divTrunc(px_i - 178, 8), 0, 4));
                    if (row == 4 and col > 9) return;
                    self.cancelNavigation();
                    if (state.cursor_x == col and state.cursor_y == row) {
                        self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                    } else {
                        self.startNameEntryNavigation(.{ .x = col, .y = row }, state);
                    }
                }
            },
            .title => {
                self.cancelNavigation();
                self.enqueuePulse(gba.Key.start.mask(), 4, 2);
            },
            .frontend_main_menu => {
                if (lx >= 8 and lx < 172) {
                    if (ly >= 4 and ly < 52) {
                        self.cancelNavigation();
                        self.enqueuePulse(gba.Key.up.mask(), 4, 2);
                    } else if (ly >= 52 and ly < 102) {
                        self.cancelNavigation();
                        self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                    } else if (ly >= 102 and ly < 156) {
                        self.cancelNavigation();
                        self.enqueuePulse(gba.Key.down.mask(), 4, 2);
                    }
                }
            },
            .frontend_map_select => {
                if (lx >= 2 and lx < 30 and ly >= 46 and ly < 64) {
                    self.cancelNavigation();
                    self.enqueuePulse(gba.Key.l.mask(), 4, 2);
                    return;
                } else if (lx >= 56 and lx < 86 and ly >= 46 and ly < 64) {
                    self.cancelNavigation();
                    self.enqueuePulse(gba.Key.r.mask(), 4, 2);
                    return;
                }
                const py_i: i32 = @intFromFloat(@floor(ly));
                if (lx >= 4 and lx < 86 and py_i >= 64 and py_i < 160) {
                    const row: u8 = @intCast(@divTrunc(py_i - 64, 16));
                    self.cancelNavigation();
                    if (row == state.menu_selected) {
                        self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                    } else {
                        self.startMenuNavigation(row, false, state);
                    }
                } else if (lx >= 120 and ly >= 48) {
                    self.cancelNavigation();
                    self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                }
            },
            .frontend_co_setup => {
                self.cancelNavigation();
                if (lx >= 170 and ly < 30) {
                    self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                } else if (ly >= 30 and ly < 64) {
                    self.enqueuePulse(gba.Key.up.mask(), 4, 2);
                } else if (ly >= 96 and ly < 128) {
                    self.enqueuePulse(gba.Key.down.mask(), 4, 2);
                } else if (ly >= 64 and ly < 96) {
                    self.enqueuePulse(gba.Key.a.mask(), 4, 2);
                }
            },
            .frontend_menu => {
                self.cancelNavigation();
                self.enqueuePulse(gba.Key.a.mask(), 4, 2);
            },
        }
    }

    pub fn stepFrame(self: *TouchController, state: GameState) void {
        if (!state.isMapInteractive()) {
            self.reticle_timer = 0;
        } else if (self.reticle_timer > 0) {
            self.reticle_timer -= 1;
        }
        self.reticle_cam_x = state.cam_x;
        self.reticle_cam_y = state.cam_y;

        for (&self.pointers) |*slot| {
            if (slot.active and slot.hud_button != null) {
                slot.held_frames = slot.held_frames +| 1;
            }
        }
        if (self.right_held) {
            self.right_held_frames = self.right_held_frames +| 1;
        }

        self.stepPulseQueue();
        self.stepNavigation(state);
        self.stepMenuNavigation(state);
        self.stepAttackTargetCycle(state);
        self.stepNameEntryNavigation(state);
    }

    fn stepPulseQueue(self: *TouchController) void {
        if (self.pulse_timer > 0) {
            self.pulse_timer -= 1;
            if (self.pulse_timer == 0) {
                if (!self.pulse_in_gap and self.pulse_gap_rem > 0) {
                    self.pulse_active_mask = 0;
                    self.pulse_in_gap = true;
                    self.pulse_timer = self.pulse_gap_rem;
                } else {
                    self.pulse_active_mask = 0;
                    self.pulse_in_gap = false;
                }
            }
        }

        if (self.pulse_timer == 0 and self.pulse_count > 0) {
            const p = self.pulse_queue[self.pulse_head];
            self.pulse_head = (self.pulse_head + 1) % max_pulse_queue;
            self.pulse_count -= 1;
            self.pulse_active_mask = p.mask;
            self.pulse_timer = p.on_frames;
            self.pulse_gap_rem = p.gap_frames;
            self.pulse_in_gap = false;
        }
    }

    fn stepNavigation(self: *TouchController, state: GameState) void {
        const target = self.nav_target orelse {
            self.nav_key_mask = 0;
            return;
        };

        if (!state.isMapInteractive() or (state.cursor_x == target.x and state.cursor_y == target.y)) {
            self.nav_target = null;
            self.nav_key_mask = 0;
            self.nav_timer = 0;
            self.nav_in_gap = false;
            return;
        }

        if (state.cursor_x != self.nav_last_cursor.x or state.cursor_y != self.nav_last_cursor.y) {
            self.nav_last_cursor = .{ .x = state.cursor_x, .y = state.cursor_y };
            self.nav_stall_frames = 0;
            self.nav_steps += 1;
            if (self.nav_steps >= 64) {
                self.nav_target = null;
                self.nav_key_mask = 0;
                self.nav_timer = 0;
                self.nav_in_gap = false;
                return;
            }
        } else {
            self.nav_stall_frames += 1;
            if (self.nav_stall_frames >= nav_stall_limit) {
                self.nav_target = null;
                self.nav_key_mask = 0;
                self.nav_timer = 0;
                self.nav_in_gap = false;
                return;
            }
        }

        if (self.nav_timer == 0) {
            if (self.nav_in_gap) {
                self.nav_in_gap = false;
            }
            if (self.nav_key_mask != 0) {
                // Finished press phase -> enter release gap so Advance Wars steps cleanly per tile.
                self.nav_key_mask = 0;
                self.nav_in_gap = true;
                self.nav_timer = nav_gap_frames;
            } else {
                var dir_mask: u16 = 0;
                if (state.mode == .battle_unit_selected and state.isReachable(target.x, target.y)) {
                    if (findReachableNextStep(state, .{ .x = state.cursor_x, .y = state.cursor_y }, target)) |bfs_dir| {
                        dir_mask = bfs_dir;
                    }
                }
                if (dir_mask == 0) {
                    if (state.cursor_x < target.x) {
                        dir_mask = gba.Key.right.mask();
                    } else if (state.cursor_x > target.x) {
                        dir_mask = gba.Key.left.mask();
                    } else if (state.cursor_y < target.y) {
                        dir_mask = gba.Key.down.mask();
                    } else if (state.cursor_y > target.y) {
                        dir_mask = gba.Key.up.mask();
                    }
                }
                self.nav_key_mask = dir_mask;
                self.nav_timer = nav_pulse_frames;
            }
        }

        if (self.nav_timer > 0) {
            self.nav_timer -= 1;
        }
    }

    fn stepMenuNavigation(self: *TouchController, state: GameState) void {
        const target = self.menu_nav_target orelse {
            self.menu_nav_key_mask = 0;
            return;
        };
        if (state.mode != .battle_popup_menu and
            state.mode != .battle_unit_list and
            state.mode != .battle_deploy_shop and
            state.mode != .yes_no_prompt and
            state.mode != .frontend_map_select)
        {
            self.clearMenuNavigation();
            return;
        }
        if (state.menu_selected == target) {
            const confirm = self.menu_nav_confirm;
            self.clearMenuNavigation();
            if (confirm) {
                self.enqueuePulse(gba.Key.a.mask(), 4, 2);
            }
            return;
        }

        if (state.menu_selected != self.menu_nav_last_idx) {
            self.menu_nav_last_idx = state.menu_selected;
            self.menu_nav_stall = 0;
        } else {
            self.menu_nav_stall += 1;
            if (self.menu_nav_stall >= 24) {
                self.clearMenuNavigation();
                return;
            }
        }

        if (self.menu_nav_timer == 0) {
            if (self.menu_nav_in_gap) {
                self.menu_nav_in_gap = false;
            }
            if (self.menu_nav_key_mask != 0) {
                self.menu_nav_key_mask = 0;
                self.menu_nav_in_gap = true;
                self.menu_nav_timer = nav_gap_frames;
            } else {
                self.menu_nav_key_mask = if (state.mode == .yes_no_prompt)
                    (if (state.menu_selected < target) gba.Key.right.mask() else gba.Key.left.mask())
                else
                    (if (state.menu_selected < target) gba.Key.down.mask() else gba.Key.up.mask());
                self.menu_nav_timer = nav_pulse_frames;
            }
        }
        if (self.menu_nav_timer > 0) {
            self.menu_nav_timer -= 1;
        }
    }

    fn stepNameEntryNavigation(self: *TouchController, state: GameState) void {
        const target = self.name_nav_target orelse {
            self.name_nav_key_mask = 0;
            return;
        };
        if (state.mode != .name_entry) {
            self.clearNameEntryNavigation();
            return;
        }
        if (state.cursor_x == target.x and state.cursor_y == target.y) {
            self.clearNameEntryNavigation();
            self.enqueuePulse(gba.Key.a.mask(), 4, 2);
            return;
        }

        if (state.cursor_x != self.name_nav_last.x or state.cursor_y != self.name_nav_last.y) {
            self.name_nav_last = .{ .x = state.cursor_x, .y = state.cursor_y };
            self.name_nav_stall = 0;
        } else {
            self.name_nav_stall += 1;
            if (self.name_nav_stall >= 24) {
                self.clearNameEntryNavigation();
                return;
            }
        }

        if (self.name_nav_timer == 0) {
            if (self.name_nav_in_gap) {
                self.name_nav_in_gap = false;
            }
            if (self.name_nav_key_mask != 0) {
                self.name_nav_key_mask = 0;
                self.name_nav_in_gap = true;
                self.name_nav_timer = nav_gap_frames;
            } else {
                self.name_nav_key_mask = if (state.cursor_y == 5)
                    gba.Key.up.mask()
                else if (state.cursor_y < target.y)
                    (if (target.y == 4 and state.cursor_x > 9) gba.Key.left.mask() else gba.Key.down.mask())
                else if (state.cursor_y > target.y)
                    gba.Key.up.mask()
                else if (state.cursor_x < target.x)
                    gba.Key.right.mask()
                else
                    gba.Key.left.mask();
                self.name_nav_timer = nav_pulse_frames;
            }
        }
        if (self.name_nav_timer > 0) {
            self.name_nav_timer -= 1;
        }
    }

    fn stepAttackTargetCycle(self: *TouchController, state: GameState) void {
        const goal = self.atk_target_goal orelse {
            self.atk_cycle_key_mask = 0;
            return;
        };
        if (state.mode != .battle_attack_target) {
            self.clearAttackTargetCycle();
            return;
        }
        if (state.cursor_x == goal.x and state.cursor_y == goal.y) {
            self.clearAttackTargetCycle();
            return;
        }

        if (state.cursor_x != self.atk_cycle_last_cur.x or state.cursor_y != self.atk_cycle_last_cur.y) {
            self.atk_cycle_last_cur = .{ .x = state.cursor_x, .y = state.cursor_y };
            self.atk_cycle_moved = true;
            self.atk_cycle_stall = 0;
            self.atk_cycle_steps += 1;
            if ((state.cursor_x == self.atk_cycle_start.x and state.cursor_y == self.atk_cycle_start.y) or self.atk_cycle_steps >= 16) {
                self.clearAttackTargetCycle();
                return;
            }
        } else {
            self.atk_cycle_stall += 1;
            if (self.atk_cycle_stall >= 14) {
                self.clearAttackTargetCycle();
                return;
            }
        }

        if (self.atk_cycle_timer == 0) {
            if (self.atk_cycle_in_gap) {
                self.atk_cycle_in_gap = false;
            }
            if (self.atk_cycle_key_mask != 0) {
                self.atk_cycle_key_mask = 0;
                self.atk_cycle_in_gap = true;
                self.atk_cycle_timer = nav_gap_frames;
            } else {
                self.atk_cycle_key_mask = gba.Key.right.mask();
                self.atk_cycle_timer = nav_pulse_frames;
            }
        }
        if (self.atk_cycle_timer > 0) {
            self.atk_cycle_timer -= 1;
        }
    }

    /// Composite only the in-game target reticle into `dst` without baking HUD buttons.
    pub fn renderGameWithReticle(
        self: *const TouchController,
        src: *const [gba.width * gba.height]u32,
        dst: *[gba.width * gba.height]u32,
    ) void {
        self.renderGameWithReticleWide(src, dst, gba.width);
    }

    /// Composite the in-game target reticle into a `view_w x 160` framebuffer centered around the 240px GBA screen.
    pub fn renderGameWithReticleWide(
        self: *const TouchController,
        src: []const u32,
        dst: []u32,
        view_w: usize,
    ) void {
        const safe_w = @max(view_w, gba.width);
        const total = safe_w * gba.height;
        if (src.len < total or dst.len < total) return;
        @memcpy(dst[0..total], src[0..total]);

        if (self.nav_target != null or self.reticle_timer > 0) {
            if (self.reticle_tile) |tile| {
                const pad_l: i32 = @intCast((safe_w - gba.width) / 2);
                drawTargetReticleWide(dst[0..total], safe_w, pad_l, tile, self.reticle_cam_x, self.reticle_cam_y);
            }
        }
    }

    /// Composite corner touch controls into a separate transparent `hud_w x 160` buffer.
    /// `rgba_order` selects little-endian RGBA bytes (`0xAABBGGRR`, for Canvas2D) vs ARGB (`0xAARRGGBB`, for SDL2).
    pub fn renderHudLayer(
        self: *const TouchController,
        dst: []u32,
        hud_w: u16,
        rgba_order: bool,
    ) void {
        const clamped: u16 = std.math.clamp(
            hud_w,
            @as(u16, @intCast(gba.width)),
            @as(u16, @intCast(max_hud_width)),
        );
        const safe_w: u16 = clamped - @mod(clamped, 2);
        const total: usize = @as(usize, safe_w) * gba.height;
        if (dst.len < total) return;
        @memset(dst[0..total], 0);
        if (!self.hud_visible) return;

        const held = self.hud_held_mask;
        for (hud_buttons) |spec| {
            const rect = hudBufferRect(spec.button, safe_w);
            const is_pressed = (held & spec.button.keyMask()) != 0;
            drawPillBuf(dst[0..total], safe_w, rect, spec.button.label(), is_pressed, rgba_order);
        }
    }

    /// Composite target reticle and subtle corner touch controls directly into `dst` without altering `src`.
    pub fn renderOverlay(
        self: *const TouchController,
        src: *const [gba.width * gba.height]u32,
        dst: *[gba.width * gba.height]u32,
    ) void {
        self.renderGameWithReticle(src, dst);
        if (!self.hud_visible) return;

        const held = self.hud_held_mask;
        for (hud_buttons) |spec| {
            const is_pressed = (held & spec.button.keyMask()) != 0;
            drawPillBuf(dst[0..], gba.width, spec.rect, spec.button.label(), is_pressed, false);
        }
    }
};

fn blendPixel(dst: *u32, r: u32, g: u32, b: u32, alpha: u32, rgba_order: bool) void {
    if (alpha == 0) return;
    const px = dst.*;
    const da = (px >> 24) & 0xFF;
    const dr = if (rgba_order) (px & 0xFF) else ((px >> 16) & 0xFF);
    const dg = (px >> 8) & 0xFF;
    const db = if (rgba_order) ((px >> 16) & 0xFF) else (px & 0xFF);

    const inv = 255 - alpha;
    const num_a = alpha * 255 + da * inv;
    const out_a = (num_a + 127) / 255;
    const nr = (r * alpha * 255 + dr * da * inv + (num_a / 2)) / num_a;
    const ng = (g * alpha * 255 + dg * da * inv + (num_a / 2)) / num_a;
    const nb = (b * alpha * 255 + db * da * inv + (num_a / 2)) / num_a;

    dst.* = if (rgba_order)
        (out_a << 24) | (nb << 16) | (ng << 8) | nr
    else
        (out_a << 24) | (nr << 16) | (ng << 8) | nb;
}

fn drawTargetReticleWide(
    dst: []u32,
    buf_w: usize,
    pad_l: i32,
    tile: TileCoord,
    cam_x: i16,
    cam_y: i16,
) void {
    const x0: i32 = @as(i32, tile.x) * 16 - @as(i32, cam_x) + pad_l;
    const y0: i32 = @as(i32, tile.y) * 16 - @as(i32, cam_y);

    var dy: i32 = 0;
    while (dy < 16) : (dy += 1) {
        const py = y0 + dy;
        if (py < 0 or py >= @as(i32, @intCast(gba.height))) continue;
        var dx: i32 = 0;
        while (dx < 16) : (dx += 1) {
            const px = x0 + dx;
            if (px < 0 or px >= @as(i32, @intCast(buf_w))) continue;
            const on_edge = (dx == 0 or dx == 15 or dy == 0 or dy == 15);
            const on_corner = on_edge and ((dx < 4 or dx > 11) and (dy < 4 or dy > 11));
            const idx: usize = @intCast(@as(usize, @intCast(py)) * buf_w + @as(usize, @intCast(px)));
            if (on_corner) {
                blendPixel(&dst[idx], 255, 210, 64, 210, false);
            } else if (!on_edge) {
                blendPixel(&dst[idx], 255, 220, 90, 40, false);
            }
        }
    }
}

fn drawPillBuf(
    dst: []u32,
    buf_w: usize,
    rect: Rect,
    text: []const u8,
    pressed: bool,
    rgba_order: bool,
) void {
    const fill_r: u32 = if (pressed) 225 else 20;
    const fill_g: u32 = if (pressed) 135 else 24;
    const fill_b: u32 = if (pressed) 35 else 34;
    const fill_a: u32 = if (pressed) 195 else 125;

    const border_r: u32 = if (pressed) 255 else 215;
    const border_g: u32 = if (pressed) 235 else 225;
    const border_b: u32 = if (pressed) 160 else 240;
    const border_a: u32 = if (pressed) 235 else 175;

    var dy: i32 = 0;
    while (dy < rect.h) : (dy += 1) {
        const py = rect.y + dy;
        if (py < 0 or py >= @as(i32, @intCast(gba.height))) continue;
        var dx: i32 = 0;
        while (dx < rect.w) : (dx += 1) {
            const px = rect.x + dx;
            if (px < 0 or px >= @as(i32, @intCast(buf_w))) continue;
            // Cut 1px outer corners for rounded pill silhouette.
            const is_corner = (dx == 0 or dx == rect.w - 1) and (dy == 0 or dy == rect.h - 1);
            if (is_corner) continue;

            const is_border = (dx == 0 or dx == rect.w - 1 or dy == 0 or dy == rect.h - 1 or
                ((dx == 1 or dx == rect.w - 2) and (dy == 1 or dy == rect.h - 2)));
            const idx: usize = @as(usize, @intCast(py)) * buf_w + @as(usize, @intCast(px));
            if (is_border) {
                blendPixel(&dst[idx], border_r, border_g, border_b, border_a, rgba_order);
            } else {
                blendPixel(&dst[idx], fill_r, fill_g, fill_b, fill_a, rgba_order);
            }
        }
    }

    const total_text_w: i32 = @as(i32, @intCast(text.len)) * 4 - 1;
    const start_x: i32 = rect.x + @divTrunc(rect.w - total_text_w, 2);
    const start_y: i32 = rect.y + @divTrunc(rect.h - 5, 2);
    for (text, 0..) |ch, ci| {
        drawGlyph3x5Buf(dst, buf_w, start_x + @as(i32, @intCast(ci)) * 4, start_y, ch, pressed, rgba_order);
    }
}

pub fn glyphRows(ch: u8) [5]u3 {
    return switch (ch) {
        'A' => .{ 0b010, 0b101, 0b111, 0b101, 0b101 },
        'B' => .{ 0b110, 0b101, 0b110, 0b101, 0b110 },
        'L' => .{ 0b100, 0b100, 0b100, 0b100, 0b111 },
        'R' => .{ 0b110, 0b101, 0b110, 0b101, 0b101 },
        'S' => .{ 0b011, 0b100, 0b010, 0b001, 0b110 },
        'T' => .{ 0b111, 0b010, 0b010, 0b010, 0b010 },
        else => .{ 0, 0, 0, 0, 0 },
    };
}

fn drawGlyph3x5Buf(
    dst: []u32,
    buf_w: usize,
    gx: i32,
    gy: i32,
    ch: u8,
    bright: bool,
    rgba_order: bool,
) void {
    const rows = glyphRows(ch);
    const a: u32 = if (bright) 255 else 225;
    for (rows, 0..) |row, ry| {
        const py = gy + @as(i32, @intCast(ry));
        if (py < 0 or py >= @as(i32, @intCast(gba.height))) continue;
        var rx: i32 = 0;
        while (rx < 3) : (rx += 1) {
            const bit_idx: u2 = @intCast(2 - rx);
            if (((row >> bit_idx) & 1) == 0) continue;
            const px = gx + rx;
            if (px < 0 or px >= @as(i32, @intCast(buf_w))) continue;
            const idx: usize = @as(usize, @intCast(py)) * buf_w + @as(usize, @intCast(px));
            blendPixel(&dst[idx], 255, 255, 255, a, rgba_order);
        }
    }
}

test "HUD buttons hit-test and hold/release keys cleanly" {
    var tc = TouchController{};
    for (hud_buttons) |spec| {
        const cx: f32 = @as(f32, @floatFromInt(spec.rect.x)) + @as(f32, @floatFromInt(spec.rect.w)) * 0.5;
        const cy: f32 = @as(f32, @floatFromInt(spec.rect.y)) + @as(f32, @floatFromInt(spec.rect.h)) * 0.5;
        tc.handlePointer(.{ .id = 1, .phase = .down, .x = cx, .y = cy, .logical_x = cx, .logical_y = cy }, .{});
        try std.testing.expectEqual(spec.button.keyMask(), tc.activeKeys());
        for (0..min_button_frames) |_| tc.stepFrame(.{});
        tc.handlePointer(.{ .id = 1, .phase = .up, .x = cx, .y = cy, .logical_x = cx, .logical_y = cy }, .{});
        try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());
    }
}

test "Tier 2 map tap navigates cursor to target tile and second tap emits A" {
    var tc = TouchController{};
    var state = GameState{
        .mode = .battle_free_map,
        .map_width = 15,
        .map_height = 10,
        .cursor_x = 7,
        .cursor_y = 4,
        .cam_x = 0,
        .cam_y = 0,
    };

    // Tap tile (5, 5) -> pixel (88, 88).
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 88, .y = 88, .logical_x = 88, .logical_y = 88 }, state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 88, .y = 88, .logical_x = 88, .logical_y = 88 }, state);
    try std.testing.expect(tc.nav_target != null);

    var ticks: usize = 0;
    while (tc.nav_target != null and ticks < 40) : (ticks += 1) {
        tc.stepFrame(state);
        const k = tc.activeKeys();
        // Simulate GBA advancing cursor once per new pulse edge.
        if (tc.nav_timer == nav_pulse_frames - 1 and !tc.nav_in_gap) {
            if ((k & gba.Key.left.mask()) != 0) state.cursor_x -= 1;
            if ((k & gba.Key.right.mask()) != 0) state.cursor_x += 1;
            if ((k & gba.Key.up.mask()) != 0) state.cursor_y -= 1;
            if ((k & gba.Key.down.mask()) != 0) state.cursor_y += 1;
        }
    }
    try std.testing.expect(tc.nav_target == null);
    try std.testing.expectEqual(@as(u16, 5), state.cursor_x);
    try std.testing.expectEqual(@as(u16, 5), state.cursor_y);

    // Tapping the current cursor tile (5, 5) again emits A.
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 88, .y = 88, .logical_x = 88, .logical_y = 88 }, state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 88, .y = 88, .logical_x = 88, .logical_y = 88 }, state);
    tc.stepFrame(state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());
}

test "Navigation stall guard aborts cleanly if cursor cannot move" {
    var tc = TouchController{};
    const state = GameState{
        .mode = .battle_free_map,
        .cursor_x = 7,
        .cursor_y = 4,
    };

    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 32, .y = 32, .logical_x = 32, .logical_y = 32 }, state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 32, .y = 32, .logical_x = 32, .logical_y = 32 }, state);
    try std.testing.expect(tc.nav_target != null);

    for (0..nav_stall_limit + 2) |_| {
        tc.stepFrame(state);
    }
    try std.testing.expect(tc.nav_target == null);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());
}

test "Dialog tap emits A and Mode 4 title tap emits Start" {
    var tc = TouchController{};
    const dialog_state = GameState{ .mode = .dialog };
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, dialog_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, dialog_state);
    tc.stepFrame(dialog_state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());

    for (0..8) |_| tc.stepFrame(dialog_state);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    // Dragging right in dialog (e.g. Yes / No save prompt) emits Key.left and clears queue on lift without A.
    tc.handlePointer(.{ .id = 2, .phase = .down, .x = 80, .y = 120, .logical_x = 80, .logical_y = 120 }, dialog_state);
    tc.handlePointer(.{ .id = 2, .phase = .move, .x = 128, .y = 120, .logical_x = 128, .logical_y = 120 }, dialog_state);
    tc.stepFrame(dialog_state);
    try std.testing.expectEqual(gba.Key.left.mask(), tc.activeKeys());
    tc.handlePointer(.{ .id = 2, .phase = .up, .x = 128, .y = 120, .logical_x = 128, .logical_y = 120 }, dialog_state);
    try std.testing.expectEqual(@as(usize, 0), tc.pulse_count);
    for (0..6) |_| tc.stepFrame(dialog_state);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    const title_state = GameState{ .mode = .title };
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, title_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, title_state);
    tc.stepFrame(title_state);
    try std.testing.expectEqual(gba.Key.start.mask(), tc.activeKeys());
}

test "Battle overlay and frontend menus use natural scrolling and tap emits A" {
    var tc = TouchController{};
    const menu_state = GameState{ .mode = .frontend_menu };
    // Natural scrolling: swipe UP scrolls DOWN (Key.down), clears queue on lift without emitting A.
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 100, .y = 90, .logical_x = 100, .logical_y = 90 }, menu_state);
    tc.handlePointer(.{ .id = 1, .phase = .move, .x = 100, .y = 42, .logical_x = 100, .logical_y = 42 }, menu_state);
    tc.stepFrame(menu_state);
    try std.testing.expectEqual(gba.Key.down.mask(), tc.activeKeys());
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 100, .y = 42, .logical_x = 100, .logical_y = 42 }, menu_state);
    try std.testing.expectEqual(@as(usize, 0), tc.pulse_count);
    for (0..6) |_| tc.stepFrame(menu_state);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    // Plain tap in frontend menu emits A.
    tc.handlePointer(.{ .id = 2, .phase = .down, .x = 100, .y = 40, .logical_x = 100, .logical_y = 40 }, menu_state);
    tc.handlePointer(.{ .id = 2, .phase = .up, .x = 100, .y = 40, .logical_x = 100, .logical_y = 40 }, menu_state);
    tc.stepFrame(menu_state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());
    for (0..6) |_| tc.stepFrame(menu_state);

    // Battle overlay (e.g. Action Menu / Map Menu / Unit List): natural scrolling + tap A, never map nav.
    const overlay_state = GameState{ .mode = .battle_overlay, .cursor_x = 3, .cursor_y = 5 };
    tc.handlePointer(.{ .id = 3, .phase = .down, .x = 100, .y = 40, .logical_x = 100, .logical_y = 40 }, overlay_state);
    tc.handlePointer(.{ .id = 3, .phase = .move, .x = 100, .y = 88, .logical_x = 100, .logical_y = 88 }, overlay_state);
    tc.stepFrame(overlay_state);
    try std.testing.expectEqual(gba.Key.up.mask(), tc.activeKeys());
    tc.handlePointer(.{ .id = 3, .phase = .up, .x = 100, .y = 88, .logical_x = 100, .logical_y = 88 }, overlay_state);
    for (0..6) |_| tc.stepFrame(overlay_state);

    tc.handlePointer(.{ .id = 4, .phase = .down, .x = 16, .y = 16, .logical_x = 16, .logical_y = 16 }, overlay_state);
    tc.handlePointer(.{ .id = 4, .phase = .up, .x = 16, .y = 16, .logical_x = 16, .logical_y = 16 }, overlay_state);
    try std.testing.expect(tc.nav_target == null);
    tc.stepFrame(overlay_state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());
}

test "Free map drag mimics finger motion and clears queue on release" {
    var tc = TouchController{};
    const fm_state = GameState{
        .mode = .battle_free_map,
        .map_width = 20,
        .map_height = 15,
        .cursor_x = 5,
        .cursor_y = 5,
    };

    // Dragging finger RIGHT moves cursor RIGHT -> emits Key.right; lifting clears queue and never emits A.
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 80, .y = 80, .logical_x = 80, .logical_y = 80 }, fm_state);
    tc.handlePointer(.{ .id = 1, .phase = .move, .x = 80 + 48, .y = 80, .logical_x = 80 + 48, .logical_y = 80 }, fm_state);
    tc.stepFrame(fm_state);
    try std.testing.expectEqual(gba.Key.right.mask(), tc.activeKeys());
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 80 + 48, .y = 80, .logical_x = 80 + 48, .logical_y = 80 }, fm_state);
    try std.testing.expectEqual(@as(usize, 0), tc.pulse_count);
    for (0..6) |_| tc.stepFrame(fm_state);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    // Dragging finger UP moves cursor UP -> emits Key.up without triggering A.
    tc.handlePointer(.{ .id = 2, .phase = .down, .x = 100, .y = 100, .logical_x = 100, .logical_y = 100 }, fm_state);
    tc.handlePointer(.{ .id = 2, .phase = .move, .x = 100, .y = 100 - 32, .logical_x = 100, .logical_y = 100 - 32 }, fm_state);
    tc.stepFrame(fm_state);
    try std.testing.expectEqual(gba.Key.up.mask(), tc.activeKeys());
}

test "Unit selected BFS detour preview, 2nd-tap confirm, unreachable B deselect, and drag path painting" {
    var tc = TouchController{};
    // Reachable U-shape detour from (2,2) to (4,2) avoiding barrier at (3,2): (2,2)->(2,3)->(3,3)->(4,3)->(4,2).
    var sel_state = GameState{
        .mode = .battle_unit_selected,
        .map_width = 10,
        .map_height = 10,
        .cursor_x = 2,
        .cursor_y = 2,
    };
    sel_state.setReachable(2, 2);
    sel_state.setReachable(2, 3);
    sel_state.setReachable(3, 3);
    sel_state.setReachable(4, 3);
    sel_state.setReachable(4, 2);

    // 1st tap on reachable (4, 2) -> px (72, 40) walks via reachable BFS detour without confirming A.
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 72, .y = 40, .logical_x = 72, .logical_y = 40 }, sel_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 72, .y = 40, .logical_x = 72, .logical_y = 40 }, sel_state);
    var first_dir: u16 = 0;
    var ticks: usize = 0;
    while (tc.nav_target != null and ticks < 50) : (ticks += 1) {
        tc.stepFrame(sel_state);
        const k = tc.activeKeys();
        if (first_dir == 0 and k != 0) first_dir = k;
        if (tc.nav_timer == nav_pulse_frames - 1 and !tc.nav_in_gap) {
            if ((k & gba.Key.left.mask()) != 0) sel_state.cursor_x -= 1;
            if ((k & gba.Key.right.mask()) != 0) sel_state.cursor_x += 1;
            if ((k & gba.Key.up.mask()) != 0) sel_state.cursor_y -= 1;
            if ((k & gba.Key.down.mask()) != 0) sel_state.cursor_y += 1;
            try std.testing.expect(sel_state.isReachable(sel_state.cursor_x, sel_state.cursor_y));
        }
    }
    try std.testing.expectEqual(gba.Key.down.mask(), first_dir);
    try std.testing.expectEqual(@as(u16, 4), sel_state.cursor_x);
    try std.testing.expectEqual(@as(u16, 2), sel_state.cursor_y);

    // Drag painting from (4,2) across (4,3) -> (3,3) does NOT auto-confirm A on release.
    tc.handlePointer(.{ .id = 2, .phase = .down, .x = 72, .y = 40, .logical_x = 72, .logical_y = 40 }, sel_state);
    tc.handlePointer(.{ .id = 2, .phase = .move, .x = 72, .y = 56, .logical_x = 72, .logical_y = 56 }, sel_state);
    tc.handlePointer(.{ .id = 2, .phase = .move, .x = 56, .y = 56, .logical_x = 56, .logical_y = 56 }, sel_state);
    try std.testing.expectEqual(TileCoord{ .x = 3, .y = 3 }, tc.nav_target.?);
    tc.handlePointer(.{ .id = 2, .phase = .up, .x = 56, .y = 56, .logical_x = 56, .logical_y = 56 }, sel_state);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys() & gba.Key.a.mask());
    sel_state.cursor_x = 4;
    sel_state.cursor_y = 2;

    // 2nd tap on cursor tile (4, 2) confirms A.
    tc.handlePointer(.{ .id = 3, .phase = .down, .x = 72, .y = 40, .logical_x = 72, .logical_y = 40 }, sel_state);
    tc.handlePointer(.{ .id = 3, .phase = .up, .x = 72, .y = 40, .logical_x = 72, .logical_y = 40 }, sel_state);
    tc.stepFrame(sel_state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(sel_state);

    // Tapping unreachable tile (8, 6) -> px (136, 104) only emits B (cancel/deselect), without moving cursor there.
    tc.handlePointer(.{ .id = 4, .phase = .down, .x = 136, .y = 104, .logical_x = 136, .logical_y = 104 }, sel_state);
    tc.handlePointer(.{ .id = 4, .phase = .up, .x = 136, .y = 104, .logical_x = 136, .logical_y = 104 }, sel_state);
    tc.stepFrame(sel_state);
    try std.testing.expectEqual(gba.Key.b.mask(), tc.activeKeys());
    try std.testing.expect(tc.nav_target == null);

    const fm_after = GameState{
        .mode = .battle_free_map,
        .map_width = 10,
        .map_height = 10,
        .cursor_x = 2,
        .cursor_y = 2,
    };
    for (0..10) |_| tc.stepFrame(fm_after);
    try std.testing.expect(tc.nav_target == null);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());
}

test "renderOverlay draws HUD pixels into dst without altering src" {
    var tc = TouchController{};
    const src: [gba.width * gba.height]u32 = @splat(0xFF406080);
    var dst: [gba.width * gba.height]u32 = @splat(0);

    tc.renderOverlay(&src, &dst);
    // Center pixel untouched.
    try std.testing.expectEqual(@as(u32, 0xFF406080), dst[80 * gba.width + 120]);
    // Inside A button (225, 149) should differ from background.
    try std.testing.expect(dst[149 * gba.width + 225] != 0xFF406080);
    // src remains untouched.
    try std.testing.expectEqual(@as(u32, 0xFF406080), src[149 * gba.width + 225]);
}

test "Mouse right-click holds B and scroll wheel emits Up/Down while cancelling map nav" {
    var tc = TouchController{};
    const map_state = GameState{
        .mode = .battle_free_map,
        .map_width = 15,
        .map_height = 10,
        .cursor_x = 2,
        .cursor_y = 2,
    };

    // Start map navigation to tile (6, 2)
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 96, .y = 32, .logical_x = 96, .logical_y = 32 }, map_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 96, .y = 32, .logical_x = 96, .logical_y = 32 }, map_state);
    try std.testing.expect(tc.nav_target != null);

    // Right click cancels nav and holds B until released
    tc.handlePointer(.{ .id = -2, .phase = .right_down, .x = 96, .y = 32, .logical_x = 96, .logical_y = 32 }, map_state);
    try std.testing.expect(tc.nav_target == null);
    try std.testing.expectEqual(@as(u16, 0), tc.nav_key_mask);
    try std.testing.expectEqual(gba.Key.b.mask(), tc.activeKeys());

    for (0..min_button_frames) |_| tc.stepFrame(map_state);
    tc.handlePointer(.{ .id = -2, .phase = .right_up, .x = 96, .y = 32, .logical_x = 96, .logical_y = 32 }, map_state);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    // Start nav again then scroll up -> cancels nav and pulses Up
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 96, .y = 32, .logical_x = 96, .logical_y = 32 }, map_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 96, .y = 32, .logical_x = 96, .logical_y = 32 }, map_state);
    try std.testing.expect(tc.nav_target != null);
    tc.handlePointer(.{ .id = -3, .phase = .scroll_up, .x = 0, .y = 0, .logical_x = 0, .logical_y = 0 }, map_state);
    try std.testing.expect(tc.nav_target == null);
    tc.stepFrame(map_state);
    try std.testing.expectEqual(gba.Key.up.mask(), tc.activeKeys());
    for (0..6) |_| tc.stepFrame(map_state);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    // Scroll down -> pulses Down
    tc.handlePointer(.{ .id = -3, .phase = .scroll_down, .x = 0, .y = 0, .logical_x = 0, .logical_y = 0 }, map_state);
    tc.stepFrame(map_state);
    try std.testing.expectEqual(gba.Key.down.mask(), tc.activeKeys());
}

test "Same-frame HUD B click and mouse right-click latch for minimum frames" {
    var tc = TouchController{};
    const b_x: f32 = 205;
    const b_y: f32 = 149;

    // Fast left click on HUD B within one poll batch
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = b_x, .y = b_y, .logical_x = b_x, .logical_y = b_y }, .{});
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = b_x, .y = b_y, .logical_x = b_x, .logical_y = b_y }, .{});
    for (0..min_button_frames) |_| {
        tc.stepFrame(.{});
        try std.testing.expectEqual(gba.Key.b.mask(), tc.activeKeys());
    }
    tc.stepFrame(.{});
    tc.stepFrame(.{});
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    // Fast right click within one poll batch
    tc.handlePointer(.{ .id = -2, .phase = .right_down, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, .{});
    tc.handlePointer(.{ .id = -2, .phase = .right_up, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, .{});
    for (0..min_button_frames) |_| {
        tc.stepFrame(.{});
        try std.testing.expectEqual(gba.Key.b.mask(), tc.activeKeys());
    }
    tc.stepFrame(.{});
    tc.stepFrame(.{});
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    // Short hold (1 frame) extends remaining latch frames, then releases cleanly
    tc.handlePointer(.{ .id = -2, .phase = .right_down, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, .{});
    tc.stepFrame(.{});
    try std.testing.expectEqual(gba.Key.b.mask(), tc.activeKeys());
    tc.handlePointer(.{ .id = -2, .phase = .right_up, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, .{});
    for (0..(min_button_frames - 1)) |_| {
        tc.stepFrame(.{});
        try std.testing.expectEqual(gba.Key.b.mask(), tc.activeKeys());
    }
    tc.stepFrame(.{});
    tc.stepFrame(.{});
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    // Held >= min_button_frames releases immediately on right_up
    tc.handlePointer(.{ .id = -2, .phase = .right_down, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, .{});
    for (0..min_button_frames) |_| tc.stepFrame(.{});
    tc.handlePointer(.{ .id = -2, .phase = .right_up, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, .{});
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());
    tc.stepFrame(.{});
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());
}

test "setHudVisible toggles and releases held HUD buttons cleanly" {
    var tc = TouchController{};
    const a_x: f32 = 227;
    const a_y: f32 = 149;

    tc.handlePointer(.{ .id = 1, .phase = .down, .x = a_x, .y = a_y, .logical_x = a_x, .logical_y = a_y }, .{});
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());

    tc.setHudVisible(false);
    try std.testing.expect(!tc.hud_visible);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    tc.handlePointer(.{ .id = 2, .phase = .down, .x = a_x, .y = a_y, .logical_x = a_x, .logical_y = a_y }, .{});
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    tc.setHudVisible(true);
    try std.testing.expect(tc.hud_visible);
    tc.handlePointer(.{ .id = 3, .phase = .down, .x = a_x, .y = a_y, .logical_x = a_x, .logical_y = a_y }, .{});
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());
}

test "Unified HUD layer extends classic corner pills into side margins" {
    try std.testing.expectEqual(@as(u16, gba.width), computeHudWidth(720, 480));
    try std.testing.expectEqual(@as(u16, 284), computeHudWidth(1280, 720));
    try std.testing.expectEqual(@as(u16, 372), computeHudWidth(2560, 1100));
    try std.testing.expectEqual(@as(u16, max_hud_width), computeHudWidth(4000, 720));

    // At 16:9 (`hud_w = 284`), L sits purely inside the left margin (`lx in [-20, -2)`),
    // and R / A extend past the right edge (`>= 240`).
    try std.testing.expectEqual(HudButton.l, hitTestHudWidth(-12.0, 7.0, 284).?);
    try std.testing.expectEqual(HudButton.r, hitTestHudWidth(250.0, 7.0, 284).?);
    try std.testing.expectEqual(HudButton.a, hitTestHudWidth(248.0, 148.0, 284).?);
    try std.testing.expect(hitTestHudWidth(120.0, 80.0, 284) == null);

    // At ultrawide (`hud_w = 374` -> clamped even `374`), all 5 buttons sit cleanly outside `[0, 240)`.
    var tc = TouchController{};
    tc.setHudWidth(374);
    try std.testing.expectEqual(@as(u16, 374), tc.hud_width);
    try std.testing.expectEqual(HudButton.l, hitTestHudWidth(-58.0, 7.0, tc.hud_width).?);
    try std.testing.expectEqual(HudButton.start, hitTestHudWidth(270.0, 7.0, tc.hud_width).?);
    try std.testing.expectEqual(HudButton.b, hitTestHudWidth(270.0, 148.0, tc.hud_width).?);

    var buf: [max_hud_width * gba.height]u32 = @splat(0);
    tc.renderHudLayer(&buf, 284, true);
    // Center pixel in L button buffer rect (`x=10, y=7`) is opaque/translucent glyph/fill;
    // cut outer corner `(2, 2)` and center screen pixel `(142, 80)` remain transparent.
    try std.testing.expect(buf[7 * 284 + 10] != 0);
    try std.testing.expectEqual(@as(u32, 0), buf[2 * 284 + 2]);
    try std.testing.expectEqual(@as(u32, 0), buf[80 * 284 + 142]);
}

test "Smooth drag-paint preserves step cadence and battle_overlay clears stale reticle" {
    var tc = TouchController{};
    var sel_state = GameState{
        .mode = .battle_unit_selected,
        .map_width = 10,
        .map_height = 10,
        .cursor_x = 2,
        .cursor_y = 2,
    };
    sel_state.setReachable(2, 2);
    sel_state.setReachable(3, 2);
    sel_state.setReachable(4, 2);

    // Start drag-paint across (3,2) -> step 1 frame -> retarget (4,2) without resetting nav_timer.
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 40, .y = 40, .logical_x = 40, .logical_y = 40 }, sel_state);
    tc.handlePointer(.{ .id = 1, .phase = .move, .x = 56, .y = 40, .logical_x = 56, .logical_y = 40 }, sel_state);
    tc.stepFrame(sel_state);
    const saved_timer = tc.nav_timer;
    const saved_mask = tc.nav_key_mask;
    try std.testing.expect(saved_mask == gba.Key.right.mask());

    tc.handlePointer(.{ .id = 1, .phase = .move, .x = 72, .y = 40, .logical_x = 72, .logical_y = 40 }, sel_state);
    try std.testing.expectEqual(TileCoord{ .x = 4, .y = 2 }, tc.nav_target.?);
    try std.testing.expectEqual(saved_timer, tc.nav_timer);
    try std.testing.expectEqual(saved_mask, tc.nav_key_mask);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 72, .y = 40, .logical_x = 72, .logical_y = 40 }, sel_state);
    try std.testing.expect(tc.reticle_timer > 0);

    // Entering battle_overlay clears stale yellow reticle immediately.
    const overlay_state = GameState{ .mode = .battle_overlay, .map_width = 10, .map_height = 10 };
    tc.stepFrame(overlay_state);
    try std.testing.expectEqual(@as(u8, 0), tc.reticle_timer);
}

test "Battle popup menu direct row click, outside B cancel, and natural scroll" {
    var tc = TouchController{};
    var pop_state = GameState{
        .mode = .battle_popup_menu,
        .menu_x = 168,
        .menu_y = 16,
        .menu_count = 4,
        .menu_selected = 0,
    };

    // Clicking same row (0, y=24) confirms A immediately.
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 195, .y = 24, .logical_x = 195, .logical_y = 24 }, pop_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 195, .y = 24, .logical_x = 195, .logical_y = 24 }, pop_state);
    tc.stepFrame(pop_state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(pop_state);

    // Clicking row 2 (y=56) steps Down twice, then auto-confirms A.
    tc.handlePointer(.{ .id = 2, .phase = .down, .x = 195, .y = 56, .logical_x = 195, .logical_y = 56 }, pop_state);
    tc.handlePointer(.{ .id = 2, .phase = .up, .x = 195, .y = 56, .logical_x = 195, .logical_y = 56 }, pop_state);
    var confirmed_a = false;
    for (0..30) |_| {
        tc.stepFrame(pop_state);
        const k = tc.activeKeys();
        if (tc.menu_nav_timer == nav_pulse_frames - 1 and !tc.menu_nav_in_gap and (k & gba.Key.down.mask()) != 0) {
            pop_state.menu_selected += 1;
        }
        if ((k & gba.Key.a.mask()) != 0) {
            confirmed_a = true;
            break;
        }
    }
    try std.testing.expectEqual(@as(u8, 2), pop_state.menu_selected);
    try std.testing.expect(confirmed_a);
    for (0..8) |_| tc.stepFrame(pop_state);

    // Tapping outside popup box emits B to close menu.
    tc.handlePointer(.{ .id = 3, .phase = .down, .x = 40, .y = 80, .logical_x = 40, .logical_y = 80 }, pop_state);
    tc.handlePointer(.{ .id = 3, .phase = .up, .x = 40, .y = 80, .logical_x = 40, .logical_y = 80 }, pop_state);
    tc.stepFrame(pop_state);
    try std.testing.expectEqual(gba.Key.b.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(pop_state);

    // Natural scroll swipe up -> Key.down still works inside popup menu.
    tc.handlePointer(.{ .id = 4, .phase = .down, .x = 100, .y = 90, .logical_x = 100, .logical_y = 90 }, pop_state);
    tc.handlePointer(.{ .id = 4, .phase = .move, .x = 100, .y = 42, .logical_x = 100, .logical_y = 42 }, pop_state);
    tc.stepFrame(pop_state);
    try std.testing.expectEqual(gba.Key.down.mask(), tc.activeKeys());
}

test "Battle unit list header pager arrows and 2-tap row selection" {
    var tc = TouchController{};
    var ul_state = GameState{
        .mode = .battle_unit_list,
        .menu_x = 8,
        .menu_y = 56,
        .menu_count = 6,
        .menu_selected = 0,
    };

    // Right column pager arrow '>' (108, 42) emits Key.right; left '<' (56, 42) emits Key.left.
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 108, .y = 42, .logical_x = 108, .logical_y = 42 }, ul_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 108, .y = 42, .logical_x = 108, .logical_y = 42 }, ul_state);
    tc.stepFrame(ul_state);
    try std.testing.expectEqual(gba.Key.right.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(ul_state);

    tc.handlePointer(.{ .id = 2, .phase = .down, .x = 56, .y = 42, .logical_x = 56, .logical_y = 42 }, ul_state);
    tc.handlePointer(.{ .id = 2, .phase = .up, .x = 56, .y = 42, .logical_x = 56, .logical_y = 42 }, ul_state);
    tc.stepFrame(ul_state);
    try std.testing.expectEqual(gba.Key.left.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(ul_state);

    // 1st tap on row 3 (y=112) steps to row 3 WITHOUT confirming A.
    tc.handlePointer(.{ .id = 3, .phase = .down, .x = 100, .y = 112, .logical_x = 100, .logical_y = 112 }, ul_state);
    tc.handlePointer(.{ .id = 3, .phase = .up, .x = 100, .y = 112, .logical_x = 100, .logical_y = 112 }, ul_state);
    for (0..30) |_| {
        tc.stepFrame(ul_state);
        const k = tc.activeKeys();
        try std.testing.expectEqual(@as(u16, 0), k & gba.Key.a.mask());
        if (tc.menu_nav_timer == nav_pulse_frames - 1 and !tc.menu_nav_in_gap and (k & gba.Key.down.mask()) != 0) {
            ul_state.menu_selected += 1;
        }
    }
    try std.testing.expectEqual(@as(u8, 3), ul_state.menu_selected);

    // 2nd tap on row 3 confirms A.
    tc.handlePointer(.{ .id = 4, .phase = .down, .x = 100, .y = 112, .logical_x = 100, .logical_y = 112 }, ul_state);
    tc.handlePointer(.{ .id = 4, .phase = .up, .x = 100, .y = 112, .logical_x = 100, .logical_y = 112 }, ul_state);
    tc.stepFrame(ul_state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());
}

test "Battle attack target 2-tap preview cycling and wrap abort" {
    var tc = TouchController{};
    var atk_state = GameState{
        .mode = .battle_attack_target,
        .map_width = 15,
        .map_height = 10,
        .cursor_x = 4,
        .cursor_y = 2,
    };

    // 1st tap on target tile (7, 3) -> px (120, 56) cycles Key.right without emitting A.
    const targets = [_]TileCoord{ .{ .x = 4, .y = 2 }, .{ .x = 7, .y = 3 } };
    var t_idx: usize = 0;
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 120, .y = 56, .logical_x = 120, .logical_y = 56 }, atk_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 120, .y = 56, .logical_x = 120, .logical_y = 56 }, atk_state);
    for (0..20) |_| {
        tc.stepFrame(atk_state);
        const k = tc.activeKeys();
        try std.testing.expectEqual(@as(u16, 0), k & gba.Key.a.mask());
        if (tc.atk_cycle_timer == nav_pulse_frames - 1 and !tc.atk_cycle_in_gap and (k & gba.Key.right.mask()) != 0) {
            t_idx = (t_idx + 1) % targets.len;
            atk_state.cursor_x = targets[t_idx].x;
            atk_state.cursor_y = targets[t_idx].y;
        }
    }
    try std.testing.expectEqual(@as(u16, 7), atk_state.cursor_x);
    try std.testing.expectEqual(@as(u16, 3), atk_state.cursor_y);

    // 2nd tap on current target (7, 3) emits A to confirm attack.
    tc.handlePointer(.{ .id = 2, .phase = .down, .x = 120, .y = 56, .logical_x = 120, .logical_y = 56 }, atk_state);
    tc.handlePointer(.{ .id = 2, .phase = .up, .x = 120, .y = 56, .logical_x = 120, .logical_y = 56 }, atk_state);
    tc.stepFrame(atk_state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(atk_state);

    // Tapping non-target tile (1, 1) -> px (24, 24) wraps cleanly back to start and stops without firing A.
    tc.handlePointer(.{ .id = 3, .phase = .down, .x = 24, .y = 24, .logical_x = 24, .logical_y = 24 }, atk_state);
    tc.handlePointer(.{ .id = 3, .phase = .up, .x = 24, .y = 24, .logical_x = 24, .logical_y = 24 }, atk_state);
    for (0..25) |_| {
        tc.stepFrame(atk_state);
        const k = tc.activeKeys();
        try std.testing.expectEqual(@as(u16, 0), k & gba.Key.a.mask());
        if (tc.atk_cycle_timer == nav_pulse_frames - 1 and !tc.atk_cycle_in_gap and (k & gba.Key.right.mask()) != 0) {
            t_idx = (t_idx + 1) % targets.len;
            atk_state.cursor_x = targets[t_idx].x;
            atk_state.cursor_y = targets[t_idx].y;
        }
    }
    try std.testing.expect(tc.atk_target_goal == null);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());
}

test "Yes/No prompt switches option, auto-confirms, ignores outside taps, and scrolls naturally" {
    var tc = TouchController{};
    var yn_state = GameState{
        .mode = .yes_no_prompt,
        .menu_x = 64,
        .menu_y = 128,
        .menu_count = 2,
        .menu_selected = 1, // Currently on No
    };

    // Tapping Yes (lx=72, ly=140) steps Left then auto-confirms A.
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 72, .y = 140, .logical_x = 72, .logical_y = 140 }, yn_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 72, .y = 140, .logical_x = 72, .logical_y = 140 }, yn_state);
    var confirmed_a = false;
    for (0..20) |_| {
        tc.stepFrame(yn_state);
        const k = tc.activeKeys();
        if (tc.menu_nav_timer == nav_pulse_frames - 1 and !tc.menu_nav_in_gap and (k & gba.Key.left.mask()) != 0) {
            yn_state.menu_selected = 0;
        }
        if ((k & gba.Key.a.mask()) != 0) {
            confirmed_a = true;
            break;
        }
    }
    try std.testing.expectEqual(@as(u8, 0), yn_state.menu_selected);
    try std.testing.expect(confirmed_a);
    for (0..8) |_| tc.stepFrame(yn_state);

    // Tapping No (lx=108, ly=140) while on Yes steps Right then auto-confirms A.
    tc.handlePointer(.{ .id = 2, .phase = .down, .x = 108, .y = 140, .logical_x = 108, .logical_y = 140 }, yn_state);
    tc.handlePointer(.{ .id = 2, .phase = .up, .x = 108, .y = 140, .logical_x = 108, .logical_y = 140 }, yn_state);
    confirmed_a = false;
    for (0..20) |_| {
        tc.stepFrame(yn_state);
        const k = tc.activeKeys();
        if (tc.menu_nav_timer == nav_pulse_frames - 1 and !tc.menu_nav_in_gap and (k & gba.Key.right.mask()) != 0) {
            yn_state.menu_selected = 1;
        }
        if ((k & gba.Key.a.mask()) != 0) {
            confirmed_a = true;
            break;
        }
    }
    try std.testing.expectEqual(@as(u8, 1), yn_state.menu_selected);
    try std.testing.expect(confirmed_a);
    for (0..8) |_| tc.stepFrame(yn_state);

    // Tapping outside the bottom Yes/No band (ly=60) emits nothing.
    tc.handlePointer(.{ .id = 3, .phase = .down, .x = 80, .y = 60, .logical_x = 80, .logical_y = 60 }, yn_state);
    tc.handlePointer(.{ .id = 3, .phase = .up, .x = 80, .y = 60, .logical_x = 80, .logical_y = 60 }, yn_state);
    tc.stepFrame(yn_state);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    // Natural scrolling: swipe right emits Key.left.
    tc.handlePointer(.{ .id = 4, .phase = .down, .x = 80, .y = 135, .logical_x = 80, .logical_y = 135 }, yn_state);
    tc.handlePointer(.{ .id = 4, .phase = .move, .x = 128, .y = 135, .logical_x = 128, .logical_y = 135 }, yn_state);
    tc.stepFrame(yn_state);
    try std.testing.expectEqual(gba.Key.left.mask(), tc.activeKeys());
}

test "Name Entry grid 2D navigation, row-4 left-first safety, BACK, and OK!" {
    var tc = TouchController{};
    var ne_state = GameState{
        .mode = .name_entry,
        .cursor_x = 0,
        .cursor_y = 0,
    };

    // Tap group-2 cell (col=10, row=1) -> lx=182, ly=72.
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 182, .y = 72, .logical_x = 182, .logical_y = 72 }, ne_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 182, .y = 72, .logical_x = 182, .logical_y = 72 }, ne_state);
    var confirmed_a = false;
    for (0..100) |_| {
        tc.stepFrame(ne_state);
        const k = tc.activeKeys();
        if (tc.name_nav_timer == nav_pulse_frames - 1 and !tc.name_nav_in_gap) {
            if ((k & gba.Key.right.mask()) != 0) ne_state.cursor_x += 1;
            if ((k & gba.Key.left.mask()) != 0) ne_state.cursor_x -= 1;
            if ((k & gba.Key.down.mask()) != 0) ne_state.cursor_y += 1;
            if ((k & gba.Key.up.mask()) != 0) ne_state.cursor_y -= 1;
        }
        if ((k & gba.Key.a.mask()) != 0) {
            confirmed_a = true;
            break;
        }
    }
    try std.testing.expectEqual(@as(u16, 10), ne_state.cursor_x);
    try std.testing.expectEqual(@as(u16, 1), ne_state.cursor_y);
    try std.testing.expect(confirmed_a);
    for (0..8) |_| tc.stepFrame(ne_state);

    // From (col=14, row=3), tapping digit '5' on row=4 (col=4, lx=124, ly=116) must step Left before Down.
    ne_state.cursor_x = 14;
    ne_state.cursor_y = 3;
    tc.handlePointer(.{ .id = 2, .phase = .down, .x = 124, .y = 116, .logical_x = 124, .logical_y = 116 }, ne_state);
    tc.handlePointer(.{ .id = 2, .phase = .up, .x = 124, .y = 116, .logical_x = 124, .logical_y = 116 }, ne_state);
    tc.stepFrame(ne_state);
    try std.testing.expectEqual(gba.Key.left.mask(), tc.activeKeys());
    tc.cancelNavigation();
    for (0..8) |_| tc.stepFrame(ne_state);

    // Tapping BACK (lx=170, ly=140) emits Key.b.
    tc.handlePointer(.{ .id = 3, .phase = .down, .x = 170, .y = 140, .logical_x = 170, .logical_y = 140 }, ne_state);
    tc.handlePointer(.{ .id = 3, .phase = .up, .x = 170, .y = 140, .logical_x = 170, .logical_y = 140 }, ne_state);
    tc.stepFrame(ne_state);
    try std.testing.expectEqual(gba.Key.b.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(ne_state);

    // Tapping OK! (lx=205, ly=140) queues Start then A.
    tc.handlePointer(.{ .id = 4, .phase = .down, .x = 205, .y = 140, .logical_x = 205, .logical_y = 140 }, ne_state);
    tc.handlePointer(.{ .id = 4, .phase = .up, .x = 205, .y = 140, .logical_x = 205, .logical_y = 140 }, ne_state);
    var saw_start = false;
    var saw_a = false;
    for (0..20) |_| {
        tc.stepFrame(ne_state);
        if ((tc.activeKeys() & gba.Key.start.mask()) != 0) saw_start = true;
        if ((tc.activeKeys() & gba.Key.a.mask()) != 0) saw_a = true;
    }
    try std.testing.expect(saw_start and saw_a);
}

test "Frontend Main Menu, Map Select, and CO Setup tap zones" {
    var tc = TouchController{};
    const mm_state = GameState{ .mode = .frontend_main_menu, .menu_count = 6, .menu_selected = 0 };

    // Top carousel -> Up, Center -> A, Bottom -> Down, Right portrait -> no-op.
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 80, .y = 24, .logical_x = 80, .logical_y = 24 }, mm_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 80, .y = 24, .logical_x = 80, .logical_y = 24 }, mm_state);
    tc.stepFrame(mm_state);
    try std.testing.expectEqual(gba.Key.up.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(mm_state);

    tc.handlePointer(.{ .id = 2, .phase = .down, .x = 80, .y = 76, .logical_x = 80, .logical_y = 76 }, mm_state);
    tc.handlePointer(.{ .id = 2, .phase = .up, .x = 80, .y = 76, .logical_x = 80, .logical_y = 76 }, mm_state);
    tc.stepFrame(mm_state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(mm_state);

    tc.handlePointer(.{ .id = 3, .phase = .down, .x = 80, .y = 128, .logical_x = 80, .logical_y = 128 }, mm_state);
    tc.handlePointer(.{ .id = 3, .phase = .up, .x = 80, .y = 128, .logical_x = 80, .logical_y = 128 }, mm_state);
    tc.stepFrame(mm_state);
    try std.testing.expectEqual(gba.Key.down.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(mm_state);

    tc.handlePointer(.{ .id = 4, .phase = .down, .x = 200, .y = 80, .logical_x = 200, .logical_y = 80 }, mm_state);
    tc.handlePointer(.{ .id = 4, .phase = .up, .x = 200, .y = 80, .logical_x = 200, .logical_y = 80 }, mm_state);
    tc.stepFrame(mm_state);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    // Map Select: <L / R> category arrows + 2-tap row + minimap confirm.
    var ms_state = GameState{ .mode = .frontend_map_select, .menu_count = 6, .menu_selected = 0 };
    tc.handlePointer(.{ .id = 5, .phase = .down, .x = 16, .y = 54, .logical_x = 16, .logical_y = 54 }, ms_state);
    tc.handlePointer(.{ .id = 5, .phase = .up, .x = 16, .y = 54, .logical_x = 16, .logical_y = 54 }, ms_state);
    tc.stepFrame(ms_state);
    try std.testing.expectEqual(gba.Key.l.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(ms_state);

    tc.handlePointer(.{ .id = 6, .phase = .down, .x = 70, .y = 54, .logical_x = 70, .logical_y = 54 }, ms_state);
    tc.handlePointer(.{ .id = 6, .phase = .up, .x = 70, .y = 54, .logical_x = 70, .logical_y = 54 }, ms_state);
    tc.stepFrame(ms_state);
    try std.testing.expectEqual(gba.Key.r.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(ms_state);

    // 1st tap row 2 (ly=104) previews without confirming A; 2nd tap or minimap emits A.
    tc.handlePointer(.{ .id = 7, .phase = .down, .x = 40, .y = 104, .logical_x = 40, .logical_y = 104 }, ms_state);
    tc.handlePointer(.{ .id = 7, .phase = .up, .x = 40, .y = 104, .logical_x = 40, .logical_y = 104 }, ms_state);
    for (0..25) |_| {
        tc.stepFrame(ms_state);
        const k = tc.activeKeys();
        try std.testing.expectEqual(@as(u16, 0), k & gba.Key.a.mask());
        if (tc.menu_nav_timer == nav_pulse_frames - 1 and !tc.menu_nav_in_gap and (k & gba.Key.down.mask()) != 0) {
            ms_state.menu_selected += 1;
        }
    }
    try std.testing.expectEqual(@as(u8, 2), ms_state.menu_selected);

    tc.handlePointer(.{ .id = 8, .phase = .down, .x = 160, .y = 80, .logical_x = 160, .logical_y = 80 }, ms_state);
    tc.handlePointer(.{ .id = 8, .phase = .up, .x = 160, .y = 80, .logical_x = 160, .logical_y = 80 }, ms_state);
    tc.stepFrame(ms_state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(ms_state);

    // CO Setup: PRESS A -> A, upper band -> Up, lower band -> Down.
    const co_state = GameState{ .mode = .frontend_co_setup };
    tc.handlePointer(.{ .id = 9, .phase = .down, .x = 200, .y = 16, .logical_x = 200, .logical_y = 16 }, co_state);
    tc.handlePointer(.{ .id = 9, .phase = .up, .x = 200, .y = 16, .logical_x = 200, .logical_y = 16 }, co_state);
    tc.stepFrame(co_state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(co_state);

    tc.handlePointer(.{ .id = 10, .phase = .down, .x = 60, .y = 48, .logical_x = 60, .logical_y = 48 }, co_state);
    tc.handlePointer(.{ .id = 10, .phase = .up, .x = 60, .y = 48, .logical_x = 60, .logical_y = 48 }, co_state);
    tc.stepFrame(co_state);
    try std.testing.expectEqual(gba.Key.up.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(co_state);

    tc.handlePointer(.{ .id = 11, .phase = .down, .x = 60, .y = 112, .logical_x = 60, .logical_y = 112 }, co_state);
    tc.handlePointer(.{ .id = 11, .phase = .up, .x = 60, .y = 112, .logical_x = 60, .logical_y = 112 }, co_state);
    tc.stepFrame(co_state);
    try std.testing.expectEqual(gba.Key.down.mask(), tc.activeKeys());
}

test "Battle deploy shop 2-tap preview/buy, scroll arrows, INTEL ignore, and natural scroll" {
    var tc = TouchController{};
    var shop_state = GameState{
        .mode = .battle_deploy_shop,
        .menu_x = 8,
        .menu_y = 40,
        .menu_count = 7,
        .menu_selected = 0,
    };

    // 1st tap row 3 (Tank, lx=64, ly=96) steps menu_selected 0 -> 3 without emitting A.
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 64, .y = 96, .logical_x = 64, .logical_y = 96 }, shop_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 64, .y = 96, .logical_x = 64, .logical_y = 96 }, shop_state);
    for (0..30) |_| {
        tc.stepFrame(shop_state);
        const k = tc.activeKeys();
        try std.testing.expectEqual(@as(u16, 0), k & gba.Key.a.mask());
        if (tc.menu_nav_timer == nav_pulse_frames - 1 and !tc.menu_nav_in_gap and (k & gba.Key.down.mask()) != 0) {
            shop_state.menu_selected += 1;
        }
    }
    try std.testing.expectEqual(@as(u8, 3), shop_state.menu_selected);

    // 2nd tap row 3 confirms A (buy/deploy).
    tc.handlePointer(.{ .id = 2, .phase = .down, .x = 64, .y = 96, .logical_x = 64, .logical_y = 96 }, shop_state);
    tc.handlePointer(.{ .id = 2, .phase = .up, .x = 64, .y = 96, .logical_x = 64, .logical_y = 96 }, shop_state);
    tc.stepFrame(shop_state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(shop_state);

    // Top scroll arrow -> Up; bottom scroll arrow -> Down.
    tc.handlePointer(.{ .id = 3, .phase = .down, .x = 68, .y = 35, .logical_x = 68, .logical_y = 35 }, shop_state);
    tc.handlePointer(.{ .id = 3, .phase = .up, .x = 68, .y = 35, .logical_x = 68, .logical_y = 35 }, shop_state);
    tc.stepFrame(shop_state);
    try std.testing.expectEqual(gba.Key.up.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(shop_state);

    tc.handlePointer(.{ .id = 4, .phase = .down, .x = 68, .y = 156, .logical_x = 68, .logical_y = 156 }, shop_state);
    tc.handlePointer(.{ .id = 4, .phase = .up, .x = 68, .y = 156, .logical_x = 68, .logical_y = 156 }, shop_state);
    tc.stepFrame(shop_state);
    try std.testing.expectEqual(gba.Key.down.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(shop_state);

    // Tapping right INTEL panel (lx=180, ly=80) emits nothing.
    tc.handlePointer(.{ .id = 5, .phase = .down, .x = 180, .y = 80, .logical_x = 180, .logical_y = 80 }, shop_state);
    tc.handlePointer(.{ .id = 5, .phase = .up, .x = 180, .y = 80, .logical_x = 180, .logical_y = 80 }, shop_state);
    tc.stepFrame(shop_state);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    // Natural scroll swipe up -> Key.down.
    tc.handlePointer(.{ .id = 6, .phase = .down, .x = 68, .y = 110, .logical_x = 68, .logical_y = 110 }, shop_state);
    tc.handlePointer(.{ .id = 6, .phase = .move, .x = 68, .y = 62, .logical_x = 68, .logical_y = 62 }, shop_state);
    tc.stepFrame(shop_state);
    try std.testing.expectEqual(gba.Key.down.mask(), tc.activeKeys());
}

test "Battle Intel Status and CO Dossier direct buttons and natural scroll" {
    var tc = TouchController{};
    const status_state = GameState{ .mode = .battle_intel_status };

    // '<' emits Key.left; '>' / 'Unit' emits Key.right; bottom strip emits Key.b.
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 8, .y = 16, .logical_x = 8, .logical_y = 16 }, status_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 8, .y = 16, .logical_x = 8, .logical_y = 16 }, status_state);
    tc.stepFrame(status_state);
    try std.testing.expectEqual(gba.Key.left.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(status_state);

    tc.handlePointer(.{ .id = 2, .phase = .down, .x = 48, .y = 16, .logical_x = 48, .logical_y = 16 }, status_state);
    tc.handlePointer(.{ .id = 2, .phase = .up, .x = 48, .y = 16, .logical_x = 48, .logical_y = 16 }, status_state);
    tc.stepFrame(status_state);
    try std.testing.expectEqual(gba.Key.right.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(status_state);

    tc.handlePointer(.{ .id = 3, .phase = .down, .x = 120, .y = 140, .logical_x = 120, .logical_y = 140 }, status_state);
    tc.handlePointer(.{ .id = 3, .phase = .up, .x = 120, .y = 140, .logical_x = 120, .logical_y = 140 }, status_state);
    tc.stepFrame(status_state);
    try std.testing.expectEqual(gba.Key.b.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(status_state);

    // Natural scroll swipe left -> Key.right.
    tc.handlePointer(.{ .id = 4, .phase = .down, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, status_state);
    tc.handlePointer(.{ .id = 4, .phase = .move, .x = 72, .y = 80, .logical_x = 72, .logical_y = 80 }, status_state);
    tc.stepFrame(status_state);
    try std.testing.expectEqual(gba.Key.right.mask(), tc.activeKeys());
    tc.handlePointer(.{ .id = 4, .phase = .up, .x = 72, .y = 80, .logical_x = 72, .logical_y = 80 }, status_state);
    for (0..8) |_| tc.stepFrame(status_state);

    const co_state = GameState{ .mode = .battle_co_info };
    tc.handlePointer(.{ .id = 5, .phase = .down, .x = 16, .y = 16, .logical_x = 16, .logical_y = 16 }, co_state);
    tc.handlePointer(.{ .id = 5, .phase = .up, .x = 16, .y = 16, .logical_x = 16, .logical_y = 16 }, co_state);
    tc.stepFrame(co_state);
    try std.testing.expectEqual(gba.Key.l.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(co_state);

    tc.handlePointer(.{ .id = 6, .phase = .down, .x = 120, .y = 16, .logical_x = 120, .logical_y = 16 }, co_state);
    tc.handlePointer(.{ .id = 6, .phase = .up, .x = 120, .y = 16, .logical_x = 120, .logical_y = 16 }, co_state);
    tc.stepFrame(co_state);
    try std.testing.expectEqual(gba.Key.r.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(co_state);

    tc.handlePointer(.{ .id = 7, .phase = .down, .x = 68, .y = 100, .logical_x = 68, .logical_y = 100 }, co_state);
    tc.handlePointer(.{ .id = 7, .phase = .up, .x = 68, .y = 100, .logical_x = 68, .logical_y = 100 }, co_state);
    tc.stepFrame(co_state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());
    for (0..8) |_| tc.stepFrame(co_state);

    // Natural scroll swipe up -> Key.down.
    tc.handlePointer(.{ .id = 8, .phase = .down, .x = 68, .y = 100, .logical_x = 68, .logical_y = 100 }, co_state);
    tc.handlePointer(.{ .id = 8, .phase = .move, .x = 68, .y = 52, .logical_x = 68, .logical_y = 52 }, co_state);
    tc.stepFrame(co_state);
    try std.testing.expectEqual(gba.Key.down.mask(), tc.activeKeys());
}

test "Widescreen reticle renders offset by pad_l in wide buffers" {
    var tc = TouchController{};
    tc.reticle_tile = .{ .x = 1, .y = 1 };
    tc.reticle_cam_x = 0;
    tc.reticle_cam_y = 0;
    tc.reticle_timer = 10;

    const vw: usize = 320;
    const pad_l: usize = (vw - gba.width) / 2;
    var src: [vw * gba.height]u32 = @splat(0xFF000000);
    var dst: [vw * gba.height]u32 = @splat(0);
    tc.renderGameWithReticleWide(&src, &dst, vw);

    // Tile (1, 1) corner sits at GBA (16, 16) -> wide buffer (pad_l + 16, 16)
    try std.testing.expect(dst[16 * vw + (pad_l + 16)] != 0xFF000000);
    try std.testing.expectEqual(@as(u32, 0xFF000000), dst[16 * vw + 16]);
}
