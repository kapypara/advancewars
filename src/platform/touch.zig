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

/// Minimal corner HUD layout in logical 240x160 GBA coordinates (center map stays clear).
pub const hud_buttons = [_]HudSpec{
    .{ .button = .l, .rect = .{ .x = 2, .y = 2, .w = 18, .h = 12 } },
    .{ .button = .start, .rect = .{ .x = 194, .y = 2, .w = 22, .h = 12 } },
    .{ .button = .r, .rect = .{ .x = 220, .y = 2, .w = 18, .h = 12 } },
    .{ .button = .b, .rect = .{ .x = 196, .y = 141, .w = 19, .h = 17 } },
    .{ .button = .a, .rect = .{ .x = 218, .y = 141, .w = 19, .h = 17 } },
};

/// Advance Wars IWRAM/MMIO snapshot sampled once per interactive frame.
pub const GameState = struct {
    map_active: bool = false,
    dialog_waiting: bool = false,
    title_mode4: bool = false,
    cursor_x: u16 = 0,
    cursor_y: u16 = 0,
    scroll_x: u16 = 0,
    scroll_y: u16 = 0,
};

pub const TileCoord = struct {
    x: u16,
    y: u16,
};

const max_pointers = 8;
const max_pulse_queue = 16;
const drag_threshold_sq: f32 = 10.0 * 10.0;
const swipe_step_px: f32 = 16.0;
const nav_pulse_frames: u8 = 3;
const nav_gap_frames: u8 = 3;
const nav_stall_limit: u16 = 24;

const PointerSlot = struct {
    active: bool = false,
    id: i64 = 0,
    hud_button: ?HudButton = null,
    start_x: f32 = 0,
    start_y: f32 = 0,
    anchor_x: f32 = 0,
    anchor_y: f32 = 0,
    dragged: bool = false,
};

const Pulse = struct {
    mask: u16 = 0,
    on_frames: u8 = 0,
    gap_frames: u8 = 0,
};

/// Pure Zig touch + mouse controller combining Tier 1 corner HUD buttons and
/// Tier 2 direct map-tile tapping, menu/dialog taps, and swipe gestures.
pub const TouchController = struct {
    hud_visible: bool = true,
    pointers: [max_pointers]PointerSlot = @splat(.{}),
    hud_held_mask: u16 = 0,

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
    nav_prev_dist: u32 = 0,
    nav_stall_frames: u16 = 0,

    reticle_tile: ?TileCoord = null,
    reticle_scroll_x: u16 = 0,
    reticle_scroll_y: u16 = 0,
    reticle_timer: u8 = 0,

    pub fn toggleHud(self: *TouchController) void {
        self.hud_visible = !self.hud_visible;
        if (!self.hud_visible) {
            for (&self.pointers) |*slot| {
                if (slot.active and slot.hud_button != null) {
                    slot.active = false;
                    slot.hud_button = null;
                }
            }
            self.recomputeHudMask();
        }
    }

    pub fn activeKeys(self: *const TouchController) u16 {
        return self.hud_held_mask | self.pulse_active_mask | self.nav_key_mask;
    }

    pub fn hitTestHud(lx: f32, ly: f32) ?HudButton {
        for (hud_buttons) |spec| {
            if (spec.rect.contains(lx, ly)) return spec.button;
        }
        return null;
    }

    pub fn screenToTile(lx: f32, ly: f32, scroll_x: u16, scroll_y: u16) TileCoord {
        const clamped_x = std.math.clamp(@as(i32, @intFromFloat(@floor(lx))), 0, @as(i32, @intCast(gba.width)) - 1);
        const clamped_y = std.math.clamp(@as(i32, @intFromFloat(@floor(ly))), 0, @as(i32, @intCast(gba.height)) - 1);
        const sx: i32 = if (scroll_x > 480) @as(i32, scroll_x) - 512 else @as(i32, scroll_x);
        const sy: i32 = if (scroll_y > 480) @as(i32, scroll_y) - 512 else @as(i32, scroll_y);
        const wx = @max(clamped_x + sx, 0);
        const wy = @max(clamped_y + sy, 0);
        return .{
            .x = @intCast(@divTrunc(wx, 16)),
            .y = @intCast(@divTrunc(wy, 16)),
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

    fn manhattan(a: TileCoord, b: TileCoord) u32 {
        const dx: i32 = @as(i32, a.x) - @as(i32, b.x);
        const dy: i32 = @as(i32, a.y) - @as(i32, b.y);
        return @abs(dx) + @abs(dy);
    }

    pub fn handlePointer(self: *TouchController, ev: platform.PointerEvent, state: GameState) void {
        switch (ev.phase) {
            .down => {
                const slot = self.findSlot(ev.id) orelse self.allocSlot() orelse return;
                const hud_hit = if (self.hud_visible) hitTestHud(ev.logical_x, ev.logical_y) else null;
                slot.* = .{
                    .active = true,
                    .id = ev.id,
                    .hud_button = hud_hit,
                    .start_x = ev.logical_x,
                    .start_y = ev.logical_y,
                    .anchor_x = ev.logical_x,
                    .anchor_y = ev.logical_y,
                    .dragged = false,
                };
                if (hud_hit != null) {
                    self.recomputeHudMask();
                }
            },
            .move => {
                const slot = self.findSlot(ev.id) orelse return;
                if (slot.hud_button) |old_btn| {
                    const now_btn = if (self.hud_visible) hitTestHud(ev.logical_x, ev.logical_y) else null;
                    if (now_btn != old_btn) {
                        slot.hud_button = now_btn;
                        self.recomputeHudMask();
                    }
                    return;
                }

                const dx_start = ev.logical_x - slot.start_x;
                const dy_start = ev.logical_y - slot.start_y;
                if (!slot.dragged and (dx_start * dx_start + dy_start * dy_start) >= drag_threshold_sq) {
                    slot.dragged = true;
                    self.nav_target = null;
                    self.nav_key_mask = 0;
                }

                if (slot.dragged) {
                    while (ev.logical_x - slot.anchor_x >= swipe_step_px) {
                        self.enqueuePulse(gba.Key.right.mask(), 3, 2);
                        slot.anchor_x += swipe_step_px;
                    }
                    while (slot.anchor_x - ev.logical_x >= swipe_step_px) {
                        self.enqueuePulse(gba.Key.left.mask(), 3, 2);
                        slot.anchor_x -= swipe_step_px;
                    }
                    while (ev.logical_y - slot.anchor_y >= swipe_step_px) {
                        self.enqueuePulse(gba.Key.down.mask(), 3, 2);
                        slot.anchor_y += swipe_step_px;
                    }
                    while (slot.anchor_y - ev.logical_y >= swipe_step_px) {
                        self.enqueuePulse(gba.Key.up.mask(), 3, 2);
                        slot.anchor_y -= swipe_step_px;
                    }
                }
            },
            .up => {
                const slot = self.findSlot(ev.id) orelse return;
                const was_hud = slot.hud_button != null;
                const was_dragged = slot.dragged;
                slot.active = false;
                slot.hud_button = null;
                if (was_hud) {
                    self.recomputeHudMask();
                    return;
                }
                if (was_dragged) return;

                self.handleCanvasTap(ev.logical_x, ev.logical_y, state);
            },
        }
    }

    fn handleCanvasTap(self: *TouchController, lx: f32, ly: f32, state: GameState) void {
        if (lx < 0 or ly < 0 or lx >= @as(f32, @floatFromInt(gba.width)) or ly >= @as(f32, @floatFromInt(gba.height))) {
            return;
        }

        if (state.map_active) {
            const tile = screenToTile(lx, ly, state.scroll_x, state.scroll_y);
            self.reticle_tile = tile;
            self.reticle_scroll_x = state.scroll_x;
            self.reticle_scroll_y = state.scroll_y;
            self.reticle_timer = 18;

            if (tile.x == state.cursor_x and tile.y == state.cursor_y) {
                self.nav_target = null;
                self.nav_key_mask = 0;
                self.enqueuePulse(gba.Key.a.mask(), 4, 2);
            } else {
                self.nav_target = tile;
                self.nav_timer = 0;
                self.nav_in_gap = false;
                self.nav_key_mask = 0;
                self.nav_prev_dist = manhattan(.{ .x = state.cursor_x, .y = state.cursor_y }, tile);
                self.nav_stall_frames = 0;
            }
            return;
        }

        self.nav_target = null;
        self.nav_key_mask = 0;
        if (state.dialog_waiting) {
            self.enqueuePulse(gba.Key.a.mask(), 4, 2);
        } else if (state.title_mode4) {
            self.enqueuePulse(gba.Key.start.mask(), 4, 2);
        } else {
            self.enqueuePulse(gba.Key.a.mask(), 4, 2);
        }
    }

    pub fn stepFrame(self: *TouchController, state: GameState) void {
        if (self.reticle_timer > 0) {
            self.reticle_timer -= 1;
        }
        self.reticle_scroll_x = state.scroll_x;
        self.reticle_scroll_y = state.scroll_y;

        self.stepPulseQueue();
        self.stepNavigation(state);
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

        if (!state.map_active or (state.cursor_x == target.x and state.cursor_y == target.y)) {
            self.nav_target = null;
            self.nav_key_mask = 0;
            self.nav_timer = 0;
            self.nav_in_gap = false;
            return;
        }

        const dist = manhattan(.{ .x = state.cursor_x, .y = state.cursor_y }, target);
        if (dist < self.nav_prev_dist) {
            self.nav_prev_dist = dist;
            self.nav_stall_frames = 0;
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
                if (state.cursor_x < target.x) {
                    dir_mask = gba.Key.right.mask();
                } else if (state.cursor_x > target.x) {
                    dir_mask = gba.Key.left.mask();
                } else if (state.cursor_y < target.y) {
                    dir_mask = gba.Key.down.mask();
                } else if (state.cursor_y > target.y) {
                    dir_mask = gba.Key.up.mask();
                }
                self.nav_key_mask = dir_mask;
                self.nav_timer = nav_pulse_frames;
            }
        }

        if (self.nav_timer > 0) {
            self.nav_timer -= 1;
        }
    }

    /// Composite subtle corner touch controls and target reticle into `dst` without altering `src`.
    pub fn renderOverlay(
        self: *const TouchController,
        src: *const [gba.width * gba.height]u32,
        dst: *[gba.width * gba.height]u32,
    ) void {
        @memcpy(dst, src);

        if (self.nav_target != null or self.reticle_timer > 0) {
            if (self.reticle_tile) |tile| {
                drawTargetReticle(dst, tile, self.reticle_scroll_x, self.reticle_scroll_y);
            }
        }

        if (!self.hud_visible) return;

        const held = self.hud_held_mask;
        for (hud_buttons) |spec| {
            const is_pressed = (held & spec.button.keyMask()) != 0;
            drawPill(dst, spec.rect, spec.button.label(), is_pressed);
        }
    }
};

fn blendPixel(dst: *u32, r: u32, g: u32, b: u32, alpha: u32) void {
    const px = dst.*;
    const dr = (px >> 16) & 0xFF;
    const dg = (px >> 8) & 0xFF;
    const db = px & 0xFF;
    const inv = 255 - alpha;
    const nr = (r * alpha + dr * inv) / 255;
    const ng = (g * alpha + dg * inv) / 255;
    const nb = (b * alpha + db * inv) / 255;
    dst.* = 0xFF000000 | (nr << 16) | (ng << 8) | nb;
}

fn drawTargetReticle(
    dst: *[gba.width * gba.height]u32,
    tile: TileCoord,
    scroll_x: u16,
    scroll_y: u16,
) void {
    const sx: i32 = if (scroll_x > 480) @as(i32, scroll_x) - 512 else @as(i32, scroll_x);
    const sy: i32 = if (scroll_y > 480) @as(i32, scroll_y) - 512 else @as(i32, scroll_y);
    const x0: i32 = @as(i32, tile.x) * 16 - sx;
    const y0: i32 = @as(i32, tile.y) * 16 - sy;

    var dy: i32 = 0;
    while (dy < 16) : (dy += 1) {
        const py = y0 + dy;
        if (py < 0 or py >= @as(i32, @intCast(gba.height))) continue;
        var dx: i32 = 0;
        while (dx < 16) : (dx += 1) {
            const px = x0 + dx;
            if (px < 0 or px >= @as(i32, @intCast(gba.width))) continue;
            const on_edge = (dx == 0 or dx == 15 or dy == 0 or dy == 15);
            const on_corner = on_edge and ((dx < 4 or dx > 11) and (dy < 4 or dy > 11));
            const idx: usize = @intCast(@as(usize, @intCast(py)) * gba.width + @as(usize, @intCast(px)));
            if (on_corner) {
                blendPixel(&dst[idx], 255, 210, 64, 210);
            } else if (!on_edge) {
                blendPixel(&dst[idx], 255, 220, 90, 40);
            }
        }
    }
}

fn drawPill(dst: *[gba.width * gba.height]u32, rect: Rect, text: []const u8, pressed: bool) void {
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
            if (px < 0 or px >= @as(i32, @intCast(gba.width))) continue;
            // Cut 1px outer corners for rounded pill silhouette.
            const is_corner = (dx == 0 or dx == rect.w - 1) and (dy == 0 or dy == rect.h - 1);
            if (is_corner) continue;

            const is_border = (dx == 0 or dx == rect.w - 1 or dy == 0 or dy == rect.h - 1 or
                ((dx == 1 or dx == rect.w - 2) and (dy == 1 or dy == rect.h - 2)));
            const idx: usize = @intCast(@as(usize, @intCast(py)) * gba.width + @as(usize, @intCast(px)));
            if (is_border) {
                blendPixel(&dst[idx], border_r, border_g, border_b, border_a);
            } else {
                blendPixel(&dst[idx], fill_r, fill_g, fill_b, fill_a);
            }
        }
    }

    const total_text_w: i32 = @as(i32, @intCast(text.len)) * 4 - 1;
    const start_x: i32 = rect.x + @divTrunc(rect.w - total_text_w, 2);
    const start_y: i32 = rect.y + @divTrunc(rect.h - 5, 2);
    for (text, 0..) |ch, ci| {
        drawGlyph3x5(dst, start_x + @as(i32, @intCast(ci)) * 4, start_y, ch, pressed);
    }
}

fn glyphRows(ch: u8) [5]u3 {
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

fn drawGlyph3x5(dst: *[gba.width * gba.height]u32, gx: i32, gy: i32, ch: u8, bright: bool) void {
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
            if (px < 0 or px >= @as(i32, @intCast(gba.width))) continue;
            const idx: usize = @intCast(@as(usize, @intCast(py)) * gba.width + @as(usize, @intCast(px)));
            blendPixel(&dst[idx], 255, 255, 255, a);
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
        tc.handlePointer(.{ .id = 1, .phase = .up, .x = cx, .y = cy, .logical_x = cx, .logical_y = cy }, .{});
        try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());
    }
}

test "Tier 2 map tap navigates cursor to target tile and second tap emits A" {
    var tc = TouchController{};
    var state = GameState{
        .map_active = true,
        .cursor_x = 7,
        .cursor_y = 4,
        .scroll_x = 0,
        .scroll_y = 0,
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
        .map_active = true,
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
    const dialog_state = GameState{ .dialog_waiting = true };
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, dialog_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, dialog_state);
    tc.stepFrame(dialog_state);
    try std.testing.expectEqual(gba.Key.a.mask(), tc.activeKeys());

    for (0..8) |_| tc.stepFrame(dialog_state);
    try std.testing.expectEqual(@as(u16, 0), tc.activeKeys());

    const title_state = GameState{ .title_mode4 = true };
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, title_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 120, .y = 80, .logical_x = 120, .logical_y = 80 }, title_state);
    tc.stepFrame(title_state);
    try std.testing.expectEqual(gba.Key.start.mask(), tc.activeKeys());
}

test "Menu swipe emits Down pulses and suppresses tap A on release" {
    var tc = TouchController{};
    const menu_state = GameState{};
    tc.handlePointer(.{ .id = 1, .phase = .down, .x = 100, .y = 40, .logical_x = 100, .logical_y = 40 }, menu_state);
    tc.handlePointer(.{ .id = 1, .phase = .move, .x = 100, .y = 76, .logical_x = 100, .logical_y = 76 }, menu_state);
    tc.handlePointer(.{ .id = 1, .phase = .up, .x = 100, .y = 76, .logical_x = 100, .logical_y = 76 }, menu_state);

    var down_count: usize = 0;
    var a_count: usize = 0;
    for (0..20) |_| {
        tc.stepFrame(menu_state);
        if ((tc.activeKeys() & gba.Key.down.mask()) != 0) down_count += 1;
        if ((tc.activeKeys() & gba.Key.a.mask()) != 0) a_count += 1;
    }
    try std.testing.expect(down_count >= 6);
    try std.testing.expectEqual(@as(usize, 0), a_count);
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
