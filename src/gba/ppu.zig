const std = @import("std");
const gba = @import("defs.zig");
const renderer = @import("renderer.zig");

const obj_width = [3][4]i32{
    .{ 8, 16, 32, 64 }, // Square
    .{ 16, 32, 32, 64 }, // Horizontal
    .{ 8, 8, 16, 32 }, // Vertical
};

const obj_height = [3][4]i32{
    .{ 8, 16, 32, 64 }, // Square
    .{ 8, 8, 16, 32 }, // Horizontal
    .{ 16, 32, 32, 64 }, // Vertical
};

fn sext28(v: u32) i32 {
    const shifted: i32 = @bitCast(v << 4);
    return shifted >> 4;
}

fn winContains(range: u16, v: i32, limit_in: i32) bool {
    const a: i32 = @intCast(range >> 8);
    var b: i32 = @intCast(range & 0xFF);
    if (a > b) return v >= a or v < b;
    if (b > limit_in) b = limit_in;
    return v >= a and v < b;
}

/// Software per-scanline GBA PPU renderer producing a `240x160` (or toggleable widescreen up to `512x160`) ARGB8888 framebuffer.
pub const Ppu = struct {
    framebuf: [gba.width * gba.height]u32 = @splat(0),
    wide_framebuf: [gba.max_wide_width * gba.height]u32 = @splat(0),
    view_width: usize = gba.width,
    wide_bg_mask: u4 = 0,
    wide_obj: bool = false,
    wide_scene: ?renderer.WideScene = null,
    top_c: [gba.max_wide_width]u16 = @splat(0),
    bot_c: [gba.max_wide_width]u16 = @splat(0),
    top_l: [gba.max_wide_width]u8 = @splat(0),
    bot_l: [gba.max_wide_width]u8 = @splat(0),
    top_semi: [gba.max_wide_width]u8 = @splat(0),
    win: [gba.max_wide_width]u8 = @splat(0),
    aff_x: [2]i32 = .{ 0, 0 },
    aff_y: [2]i32 = .{ 0, 0 },
    aff_raw_x: [2]u32 = .{ 0, 0 },
    aff_raw_y: [2]u32 = .{ 0, 0 },
    aff_mos_x: [2]i32 = .{ 0, 0 },
    aff_mos_y: [2]i32 = .{ 0, 0 },

    /// Configure output viewport width (clamped to even `[240, 512]`) and which layers extend into widescreen margins.
    pub fn setViewport(self: *Ppu, width: usize, wide_bg_mask: u4, wide_obj: bool) void {
        const clamped = std.math.clamp(width, gba.width, gba.max_wide_width);
        self.view_width = clamped - (clamped & 1);
        self.wide_bg_mask = wide_bg_mask;
        self.wide_obj = wide_obj;
    }

    /// Configure optional scene compositor sources for extended widescreen composition (null disables).
    pub fn setWideScene(self: *Ppu, scene: ?renderer.WideScene) void {
        self.wide_scene = scene;
    }

    /// Return the active framebuffer slice (`240x160` in native mode, `view_width x 160` in widescreen mode).
    pub fn activeFrameSlice(self: *const Ppu) []const u32 {
        if (self.view_width <= gba.width) return &self.framebuf;
        return self.wide_framebuf[0 .. self.view_width * gba.height];
    }

    inline fn padLeft(self: *const Ppu) usize {
        return (self.view_width - gba.width) / 2;
    }

    pub inline fn plot(self: *Ppu, x: usize, color: u16, layer: u8, semi: u8) void {
        if (((self.win[x] >> @intCast(layer)) & 1) == 0) return;
        self.bot_c[x] = self.top_c[x];
        self.bot_l[x] = self.top_l[x];
        self.top_c[x] = color;
        self.top_l[x] = layer;
        self.top_semi[x] = semi;
    }

    fn affineLatch(self: *Ppu, mem: gba.PpuMemory, i: usize, force: bool) void {
        const base: u32 = gba.io_reg.bg2x + @as(u32, @intCast(i)) * 0x10;
        const rx: u32 = @as(u32, mem.ioRead16(base)) | (@as(u32, mem.ioRead16(base + 2)) << 16);
        const ry: u32 = @as(u32, mem.ioRead16(base + 4)) | (@as(u32, mem.ioRead16(base + 6)) << 16);
        if (force or rx != self.aff_raw_x[i]) {
            self.aff_raw_x[i] = rx;
            self.aff_x[i] = sext28(rx);
        }
        if (force or ry != self.aff_raw_y[i]) {
            self.aff_raw_y[i] = ry;
            self.aff_y[i] = sext28(ry);
        }
    }

    fn lineMode3(self: *Ppu, mem: gba.PpuMemory, y: usize, pad_l: usize, bg_h: usize, bg_v: usize) void {
        const bg_mos = (mem.ioRead16(gba.io_reg.bg2cnt) & 0x0040) != 0;
        const eff_y = if (bg_mos and bg_v > 1) y - (y % bg_v) else y;
        for (0..gba.width) |x| {
            const eff_x = if (bg_mos and bg_h > 1) x - (x % bg_h) else x;
            const addr: u32 = @intCast((eff_y * gba.width + eff_x) * 2);
            self.plot(pad_l + x, mem.vramRead16(addr), 2, 0);
        }
    }

    fn lineMode4(self: *Ppu, mem: gba.PpuMemory, y: usize, dispcnt: u16, pad_l: usize, bg_h: usize, bg_v: usize) void {
        const page: u32 = if ((dispcnt & 0x0010) != 0) 0xA000 else 0;
        const bg_mos = (mem.ioRead16(gba.io_reg.bg2cnt) & 0x0040) != 0;
        const eff_y = if (bg_mos and bg_v > 1) y - (y % bg_v) else y;
        for (0..gba.width) |x| {
            const eff_x = if (bg_mos and bg_h > 1) x - (x % bg_h) else x;
            const idx = mem.vramRead8(page + @as(u32, @intCast(eff_y * gba.width + eff_x)));
            if (idx != 0) {
                self.plot(pad_l + x, mem.palRead16(@as(u32, idx) * 2), 2, 0);
            }
        }
    }

    pub inline fn plotTilePixel(
        self: *Ppu,
        mem: gba.PpuMemory,
        dst_x: usize,
        bg: u32,
        char_base: u32,
        bpp8: bool,
        e: u16,
        px: u32,
        py: u32,
    ) void {
        const fx: u32 = if ((e & 0x400) != 0) 7 - px else px;
        const fy: u32 = if ((e & 0x800) != 0) 7 - py else py;
        const tile: u32 = e & 0x3FF;
        if (bpp8) {
            const ci = mem.vramRead8(char_base + tile * 64 + fy * 8 + fx);
            if (ci != 0) {
                self.plot(dst_x, mem.palRead16(@as(u32, ci) * 2), @intCast(bg), 0);
            }
        } else {
            const b = mem.vramRead8(char_base + tile * 32 + fy * 4 + (fx >> 1));
            const ci: u32 = if ((fx & 1) != 0) (b >> 4) else (b & 15);
            if (ci != 0) {
                const pal_bank: u32 = (e >> 12) & 15;
                self.plot(dst_x, mem.palRead16((pal_bank * 16 + ci) * 2), @intCast(bg), 0);
            }
        }
    }

    fn lineTextBg(self: *Ppu, mem: gba.PpuMemory, bg: u32, y: usize, vw: usize, pad_l: usize, bg_h: usize, bg_v: usize) void {
        const bgcnt = mem.ioRead16(gba.io_reg.bg0cnt + bg * 2);
        const hofs: u32 = mem.ioRead16(gba.io_reg.bg0hofs + bg * 4) & 0x1FF;
        const vofs: u32 = mem.ioRead16(gba.io_reg.bg0vofs + bg * 4) & 0x1FF;
        const char_base: u32 = @as(u32, (bgcnt >> 2) & 3) * 0x4000;
        const screen_base: u32 = @as(u32, (bgcnt >> 8) & 0x1F) * 0x800;
        const bg_mos = ((bgcnt >> 6) & 1) != 0;
        const bpp8 = ((bgcnt >> 7) & 1) != 0;
        const size: u32 = (bgcnt >> 14) & 3;
        const w_px: u32 = if ((size & 1) != 0) 512 else 256;
        const h_px: u32 = if ((size & 2) != 0) 512 else 256;

        const eff_y: usize = if (bg_mos and bg_v > 1) y - (y % bg_v) else y;
        const by: u32 = (vofs + @as(u32, @intCast(eff_y))) % h_px;
        const ty: u32 = by >> 3;
        const py: u32 = by & 7;
        const wide_stride: u32 = if ((size & 1) != 0) 2 else 1;
        const extend_wide = vw > gba.width and ((self.wide_bg_mask & (@as(u4, 1) << @intCast(bg))) != 0);
        if (bg == 3 and vw > gba.width and !extend_wide) {
            if (self.wide_scene) |scene| {
                renderer.renderTerrainFull(self, mem, scene, vw, pad_l, char_base, bpp8, bg_mos, bg_h, eff_y);
                return;
            }
        } else if (bg == 1 and vw > gba.width and !extend_wide and char_base == 0 and screen_base == 30 * 0x800) {
            if (self.wide_scene) |scene| {
                renderer.renderUnitsFull(self, mem, scene, vw, pad_l, vofs, char_base, bpp8, bg_mos, bg_h, eff_y);
                return;
            }
        }

        const loop_len: usize = if (extend_wide) vw else gba.width;
        const pad_i: i32 = @intCast(pad_l);
        const hofs_i: i32 = @intCast(hofs);
        const w_px_i: i32 = @intCast(w_px);
        const bg_h_i: i32 = @intCast(bg_h);

        for (0..loop_len) |idx| {
            const dst_x: usize = if (extend_wide) idx else (pad_l + idx);
            const bx: u32 = if (extend_wide) blk: {
                const gx: i32 = @as(i32, @intCast(idx)) - pad_i;
                const eff_gx: i32 = if (bg_mos and bg_h > 1) gx - @mod(gx, bg_h_i) else gx;
                break :blk @intCast(@mod(hofs_i + eff_gx, w_px_i));
            } else blk: {
                const eff_x: usize = if (bg_mos and bg_h > 1) idx - (idx % bg_h) else idx;
                break :blk (hofs + @as(u32, @intCast(eff_x))) % w_px;
            };
            const tx: u32 = bx >> 3;
            const px: u32 = bx & 7;
            const block: u32 = (tx >> 5) + ((ty >> 5) * wide_stride);
            const e = mem.vramRead16(screen_base + block * 0x800 + ((ty & 31) * 32 + (tx & 31)) * 2);
            self.plotTilePixel(mem, dst_x, bg, char_base, bpp8, e, px, py);
        }

        if (bg == 2 and vw > gba.width and !extend_wide) {
            if (self.wide_scene) |scene| {
                renderer.renderReachabilityFull(self, scene, vw, pad_l, eff_y);
            }
        }
    }

    fn lineAffineBg(self: *Ppu, mem: gba.PpuMemory, bg: u32, y: usize, vw: usize, pad_l: usize, bg_h: usize, bg_v: usize) void {
        const i: usize = @intCast(bg - 2);
        const base: u32 = gba.io_reg.bg2pa + @as(u32, @intCast(i)) * 0x10;
        const pa: i32 = @as(i16, @bitCast(mem.ioRead16(base)));
        const pb: i32 = @as(i16, @bitCast(mem.ioRead16(base + 2)));
        const pc: i32 = @as(i16, @bitCast(mem.ioRead16(base + 4)));
        const pd: i32 = @as(i16, @bitCast(mem.ioRead16(base + 6)));
        const bgcnt = mem.ioRead16(gba.io_reg.bg0cnt + bg * 2);
        const bg_mos = ((bgcnt >> 6) & 1) != 0;
        const char_base: u32 = @as(u32, (bgcnt >> 2) & 3) * 0x4000;
        const screen_base: u32 = @as(u32, (bgcnt >> 8) & 0x1F) * 0x800;
        const shift: u5 = @intCast((bgcnt >> 14) & 3);
        const size: i32 = @as(i32, 128) << shift;
        const wrap = ((bgcnt >> 13) & 1) != 0;

        self.affineLatch(mem, i, false);
        if (y == 0 or bg_v == 1 or (y % bg_v) == 0) {
            self.aff_mos_x[i] = self.aff_x[i];
            self.aff_mos_y[i] = self.aff_y[i];
        }
        const base_x = if (bg_mos and bg_v > 1) self.aff_mos_x[i] else self.aff_x[i];
        const base_y = if (bg_mos and bg_v > 1) self.aff_mos_y[i] else self.aff_y[i];
        var cx: i32 = base_x -% pa *% @as(i32, @intCast(pad_l));
        var cy: i32 = base_y -% pc *% @as(i32, @intCast(pad_l));
        const pad_i: i32 = @intCast(pad_l);
        const bg_h_i: i32 = @intCast(bg_h);
        var held_valid = false;
        var held_color: u16 = 0;

        for (0..vw) |x| {
            const need_sample = !(bg_mos and bg_h > 1) or x == 0 or @mod(@as(i32, @intCast(x)) - pad_i, bg_h_i) == 0;
            if (need_sample) {
                held_valid = false;
                var tx: i32 = cx >> 8;
                var ty: i32 = cy >> 8;
                var in_bounds = true;
                if (wrap) {
                    tx &= size - 1;
                    ty &= size - 1;
                } else if (tx < 0 or ty < 0 or tx >= size or ty >= size) {
                    in_bounds = false;
                }
                if (in_bounds) {
                    const tile = mem.vramRead8(screen_base + @as(u32, @intCast((ty >> 3) * (size >> 3) + (tx >> 3))));
                    const ci = mem.vramRead8(char_base + @as(u32, tile) * 64 + @as(u32, @intCast((ty & 7) * 8 + (tx & 7))));
                    if (ci != 0) {
                        held_valid = true;
                        held_color = mem.palRead16(@as(u32, ci) * 2);
                    }
                }
            }
            if (held_valid) {
                self.plot(x, held_color, @intCast(bg), 0);
            }
            cx +%= pa;
            cy +%= pc;
        }
        self.aff_x[i] +%= pb;
        self.aff_y[i] +%= pd;
    }

    fn lineObjs(self: *Ppu, mem: gba.PpuMemory, y: usize, dispcnt: u16, prio: i32, vw: usize, pad_l: usize, obj_h: usize, obj_v: usize) void {
        if ((dispcnt & 0x1000) == 0) return;
        const mapping_1d = ((dispcnt >> 6) & 1) != 0;
        const bitmap_mode = (dispcnt & 7) >= 3;
        const objwin_ctl: u8 = @truncate(mem.ioRead16(gba.io_reg.winout) >> 8);
        const y_i32: i32 = @intCast(y);
        const clip_wide = prio >= 0 and vw > gba.width and self.wide_obj;
        const max_sx: i32 = @intCast(if (clip_wide) vw else gba.width);
        const pad_i: i32 = @intCast(pad_l);
        const obj_h_i: i32 = @intCast(obj_h);

        var idx_rev: usize = 128;
        while (idx_rev > 0) {
            idx_rev -= 1;
            const o: u32 = @intCast(idx_rev * 8);
            const a0 = mem.oamRead16(o);
            const a1 = mem.oamRead16(o + 2);
            const a2 = mem.oamRead16(o + 4);
            const mode = (a0 >> 10) & 3;
            if (mode == 3) continue;
            if ((mode == 2) != (prio < 0)) continue;
            const affine = ((a0 >> 8) & 1) != 0;
            if (!affine and (a0 & 0x200) != 0) continue;
            if (prio >= 0 and @as(i32, @intCast((a2 >> 10) & 3)) != prio) continue;

            const shape: usize = a0 >> 14;
            const size: usize = a1 >> 14;
            if (shape > 2) continue;
            if (prio == 3 and vw > gba.width and self.wide_scene != null and shape == 2 and size == 2) continue;

            const w = obj_width[shape][size];
            const h = obj_height[shape][size];
            const obj_mos = (a0 & 0x1000) != 0;
            const oy: i32 = @intCast(a0 & 0xFF);
            var ox: i32 = @intCast(a1 & 0x1FF);
            if (ox >= 240) ox -= 512;

            var bw = w;
            var bh = h;
            if (affine and (a0 & 0x200) != 0) {
                bw *= 2;
                bh *= 2;
            }
            const eff_y: i32 = if (obj_mos and obj_v > 1) @intCast(y - (y % obj_v)) else y_i32;
            const py: i32 = (eff_y - oy) & 0xFF;
            if (py >= bh) continue;

            var pa: i32 = 256;
            var pb: i32 = 0;
            var pc: i32 = 0;
            var pd: i32 = 256;
            if (affine) {
                const pp: u32 = @as(u32, (a1 >> 9) & 31) * 32;
                pa = @as(i16, @bitCast(mem.oamRead16(pp + 6)));
                pb = @as(i16, @bitCast(mem.oamRead16(pp + 14)));
                pc = @as(i16, @bitCast(mem.oamRead16(pp + 22)));
                pd = @as(i16, @bitCast(mem.oamRead16(pp + 30)));
            }

            const iy: i32 = py - @divTrunc(bh, 2);
            const tile_idx: u32 = a2 & 0x3FF;
            if (bitmap_mode and tile_idx < 512) continue;

            const bpp8 = ((a0 >> 13) & 1) != 0;
            const pal: u32 = a2 >> 12;
            const tile_step: u32 = if (bpp8) 2 else 1;
            const tiles_per_row: u32 = @intCast(@divTrunc(w, 8));
            const hud_dx: i32 = if (!clip_wide and prio == 0 and vw > gba.width) blk: {
                if (self.wide_scene) |ws| {
                    if ((ws.hud_shift_l > 0 or ws.hud_shift_r > 0) and renderer.isBattleHudSprite(tile_idx, ox)) {
                        break :blk if (ox < 120) -@as(i32, @intCast(ws.hud_shift_l)) else @as(i32, @intCast(ws.hud_shift_r));
                    }
                }
                break :blk 0;
            } else 0;

            var px: i32 = 0;
            while (px < bw) : (px += 1) {
                const sx: i32 = if (clip_wide) ox + px + pad_i else ox + px;
                if (sx < 0 or sx >= max_sx) continue;

                const eff_px: i32 = if (prio >= 0 and obj_mos and obj_h > 1) blk: {
                    const sx_gba = ox + px;
                    const mos_sx = sx_gba - @mod(sx_gba, obj_h_i);
                    break :blk std.math.clamp(mos_sx - ox, 0, bw - 1);
                } else px;

                var fx: i32 = undefined;
                var fy: i32 = undefined;
                if (affine) {
                    const ix: i32 = eff_px - @divTrunc(bw, 2);
                    fx = ((pa * ix + pb * iy) >> 8) + @divTrunc(w, 2);
                    fy = ((pc * ix + pd * iy) >> 8) + @divTrunc(h, 2);
                    if (fx < 0 or fx >= w or fy < 0 or fy >= h) continue;
                } else {
                    fx = if ((a1 & 0x1000) != 0) w - 1 - eff_px else eff_px;
                    fy = if ((a1 & 0x2000) != 0) h - 1 - py else py;
                }

                const fx_u: u32 = @intCast(fx);
                const fy_u: u32 = @intCast(fy);
                const tx: u32 = fx_u >> 3;
                const ty: u32 = fy_u >> 3;
                const tn: u32 = if (mapping_1d)
                    tile_idx +% (ty *% tiles_per_row +% tx) *% tile_step
                else
                    tile_idx +% ty *% 32 +% tx *% tile_step;
                const addr: u32 = 0x10000 + (tn & 0x3FF) * 32;

                var ci: u32 = undefined;
                if (bpp8) {
                    ci = mem.vramRead8(addr + (fy_u & 7) * 8 + (fx_u & 7));
                } else {
                    const b = mem.vramRead8(addr + (fy_u & 7) * 4 + ((fx_u & 7) >> 1));
                    ci = if ((fx_u & 1) != 0) (b >> 4) else (b & 15);
                }
                if (ci == 0) continue;

                const dst_x_i: i32 = if (clip_wide) sx else @as(i32, @intCast(pad_l)) + sx + hud_dx;
                if (dst_x_i < 0 or dst_x_i >= @as(i32, @intCast(vw))) continue;
                const dst_x: usize = @intCast(dst_x_i);
                if (prio < 0) {
                    self.win[dst_x] = objwin_ctl;
                    continue;
                }
                const c = if (bpp8)
                    mem.palRead16(0x200 + ci * 2)
                else
                    mem.palRead16(0x200 + (pal * 16 + ci) * 2);
                self.plot(dst_x, c, 4, if (mode == 1) 1 else 0);
            }
        }

        if (prio == 3 and vw > gba.width) {
            if (self.wide_scene) |scene| {
                renderer.renderPropertiesFull(self, mem, scene, y, vw, pad_l);
            }
        }
    }

    fn windowLine(self: *Ppu, mem: gba.PpuMemory, y: usize, dispcnt: u16, vw: usize, pad_l: usize, obj_h: usize, obj_v: usize) void {
        if ((dispcnt & 0xE000) == 0) {
            @memset(self.win[0..vw], 0x3F);
            return;
        }
        const winin = mem.ioRead16(gba.io_reg.winin);
        const winout = mem.ioRead16(gba.io_reg.winout);
        @memset(self.win[0..vw], @truncate(winout & 0x3F));
        if ((dispcnt & 0x8000) != 0) {
            self.lineObjs(mem, y, dispcnt, -1, vw, pad_l, obj_h, obj_v);
        }

        const y_i32: i32 = @intCast(y);
        var win0_shifted = false;
        var w_rev: u32 = 2;
        while (w_rev > 0) {
            w_rev -= 1;
            const win_enable_shift: u4 = @intCast(w_rev);
            if ((dispcnt & (@as(u16, 0x2000) << win_enable_shift)) == 0) continue;
            if (!winContains(mem.ioRead16(gba.io_reg.win0v + w_rev * 2), y_i32, @intCast(gba.height))) continue;
            const h = mem.ioRead16(gba.io_reg.win0h + w_rev * 2);
            const ctl: u8 = @truncate((winin >> @intCast(w_rev * 8)) & 0x3F);

            var shift_dir: i32 = 0;
            if (w_rev == 0 and vw > gba.width) {
                if (self.wide_scene) |ws| {
                    const wx0: usize = h >> 8;
                    const wx1: usize = h & 0xFF;
                    if (ws.hud_shift_l > 0 and wx0 <= 12 and wx1 > wx0 and wx1 <= 112) {
                        shift_dir = -@as(i32, @intCast(ws.hud_shift_l));
                        win0_shifted = true;
                    } else if (ws.hud_shift_r > 0 and wx0 >= 128 and wx0 < gba.width and ((wx1 > wx0 and wx1 <= gba.width) or wx1 == 0)) {
                        shift_dir = @as(i32, @intCast(ws.hud_shift_r));
                        win0_shifted = true;
                    }
                }
            }

            if (shift_dir != 0) {
                for (0..gba.width) |x| {
                    if (winContains(h, @intCast(x), @intCast(gba.width))) {
                        const dst_x_i: i32 = @as(i32, @intCast(pad_l + x)) + shift_dir;
                        if (dst_x_i >= 0 and dst_x_i < @as(i32, @intCast(vw))) {
                            self.win[@intCast(dst_x_i)] = ctl;
                        }
                    }
                }
            } else {
                for (0..gba.width) |x| {
                    if (winContains(h, @intCast(x), @intCast(gba.width))) {
                        self.win[pad_l + x] = ctl;
                    }
                }
                if (pad_l > 0) {
                    @memset(self.win[0..pad_l], self.win[pad_l]);
                    @memset(self.win[pad_l + gba.width .. vw], self.win[pad_l + gba.width - 1]);
                }
            }
        }
        if (pad_l > 0 and !win0_shifted) {
            @memset(self.win[0..pad_l], self.win[pad_l]);
            @memset(self.win[pad_l + gba.width .. vw], self.win[pad_l + gba.width - 1]);
        }
    }

    /// Compose scanline `y` (`0 <= y < 160`) from live PPU memory into `framebuf` (and `wide_framebuf` when `view_width > 240`).
    pub fn renderLine(self: *Ppu, mem: gba.PpuMemory, y: usize) void {
        if (y >= gba.height) return;

        const vw = self.view_width;
        const pad_l = self.padLeft();
        const dispcnt = mem.ioRead16(gba.io_reg.dispcnt);
        const mode: u32 = dispcnt & 7;
        const mosaic = mem.ioRead16(gba.io_reg.mosaic);
        const bg_h: usize = @as(usize, mosaic & 0xF) + 1;
        const bg_v: usize = @as(usize, (mosaic >> 4) & 0xF) + 1;
        const obj_h: usize = @as(usize, (mosaic >> 8) & 0xF) + 1;
        const obj_v: usize = @as(usize, (mosaic >> 12) & 0xF) + 1;
        const out = if (vw > gba.width)
            self.wide_framebuf[y * vw .. (y + 1) * vw]
        else
            self.framebuf[y * gba.width .. (y + 1) * gba.width];

        if (y == 0) {
            self.affineLatch(mem, 0, true);
            self.affineLatch(mem, 1, true);
            self.aff_mos_x = self.aff_x;
            self.aff_mos_y = self.aff_y;
        }
        if ((dispcnt & 0x80) != 0) {
            @memset(out, 0xFFFFFFFF);
            if (vw > gba.width) {
                @memset(self.framebuf[y * gba.width .. (y + 1) * gba.width], 0xFFFFFFFF);
            }
            return;
        }

        const backdrop = mem.palRead16(0);
        @memset(self.top_c[0..vw], backdrop);
        @memset(self.bot_c[0..vw], backdrop);
        @memset(self.top_l[0..vw], 5);
        @memset(self.bot_l[0..vw], 5);
        @memset(self.top_semi[0..vw], 0);

        self.windowLine(mem, y, dispcnt, vw, pad_l, obj_h, obj_v);

        var prio_rev: u32 = 4;
        while (prio_rev > 0) {
            prio_rev -= 1;
            var bg_rev: u32 = 4;
            while (bg_rev > 0) {
                bg_rev -= 1;
                const bg_bit: u4 = @intCast(bg_rev);
                if ((dispcnt & (@as(u16, 0x100) << bg_bit)) == 0) continue;
                if ((mem.ioRead16(gba.io_reg.bg0cnt + bg_rev * 2) & 3) != prio_rev) continue;

                if (mode == 0 or (mode == 1 and bg_rev < 2)) {
                    self.lineTextBg(mem, bg_rev, y, vw, pad_l, bg_h, bg_v);
                } else if ((mode == 1 and bg_rev == 2) or (mode == 2 and bg_rev >= 2)) {
                    self.lineAffineBg(mem, bg_rev, y, vw, pad_l, bg_h, bg_v);
                } else if (bg_rev == 2 and mode == 3) {
                    self.lineMode3(mem, y, pad_l, bg_h, bg_v);
                } else if (bg_rev == 2 and mode == 4) {
                    self.lineMode4(mem, y, dispcnt, pad_l, bg_h, bg_v);
                }
            }
            self.lineObjs(mem, y, dispcnt, @intCast(prio_rev), vw, pad_l, obj_h, obj_v);
        }

        for (0..2) |i| {
            const bg: u32 = @intCast(i + 2);
            const bg_bit: u4 = @intCast(bg);
            const drawn = (dispcnt & (@as(u16, 0x100) << bg_bit)) != 0 and ((mode == 1 and bg == 2) or mode == 2);
            if (!drawn) {
                const base: u32 = gba.io_reg.bg2pa + @as(u32, @intCast(i)) * 0x10;
                const pb: i32 = @as(i16, @bitCast(mem.ioRead16(base + 2)));
                const pd: i32 = @as(i16, @bitCast(mem.ioRead16(base + 6)));
                self.aff_x[i] +%= pb;
                self.aff_y[i] +%= pd;
            }
        }

        const bldcnt = mem.ioRead16(gba.io_reg.bldcnt);
        const bldalpha = mem.ioRead16(gba.io_reg.bldalpha);
        const effect = (bldcnt >> 6) & 3;
        const t1: u32 = bldcnt & 0x3F;
        const t2: u32 = (bldcnt >> 8) & 0x3F;
        const eva: i32 = @min(@as(i32, bldalpha & 0x1F), 16);
        const evb: i32 = @min(@as(i32, (bldalpha >> 8) & 0x1F), 16);
        const evy: i32 = @min(@as(i32, mem.ioRead16(gba.io_reg.bldy) & 0x1F), 16);

        for (0..vw) |x| {
            const c = self.top_c[x];
            const top_in_t1 = ((t1 >> @intCast(self.top_l[x])) & 1) != 0;
            const bot_in_t2 = ((t2 >> @intCast(self.bot_l[x])) & 1) != 0;
            var r: i32 = @intCast(c & 31);
            var g: i32 = @intCast((c >> 5) & 31);
            var b: i32 = @intCast((c >> 10) & 31);

            if ((self.win[x] & 0x20) == 0) {
                // Effects disabled in this window.
            } else if ((self.top_semi[x] != 0 or (effect == 1 and top_in_t1)) and bot_in_t2) {
                const d = self.bot_c[x];
                const dr: i32 = @intCast(d & 31);
                const dg: i32 = @intCast((d >> 5) & 31);
                const db: i32 = @intCast((d >> 10) & 31);
                r = @min((r * eva + dr * evb) >> 4, 31);
                g = @min((g * eva + dg * evb) >> 4, 31);
                b = @min((b * eva + db * evb) >> 4, 31);
            } else if (effect == 2 and top_in_t1) {
                r += ((31 - r) * evy) >> 4;
                g += ((31 - g) * evy) >> 4;
                b += ((31 - b) * evy) >> 4;
            } else if (effect == 3 and top_in_t1) {
                r -= (r * evy) >> 4;
                g -= (g * evy) >> 4;
                b -= (b * evy) >> 4;
            }

            const blended: u16 = @intCast(r | (g << 5) | (b << 10));
            out[x] = gba.rgb555ToArgb8888(blended);
        }
        if (vw > gba.width) {
            @memcpy(self.framebuf[y * gba.width .. (y + 1) * gba.width], out[pad_l .. pad_l + gba.width]);
        }
    }
};

const TestMem = struct {
    io_regs: [0x400]u8 = @splat(0),
    palette: [0x400]u8 = @splat(0),
    vram: [0x18000]u8 = @splat(0),
    oam: [0x400]u8 = @splat(0),

    fn view(self: *const TestMem) gba.PpuMemory {
        return .{
            .io_regs = &self.io_regs,
            .palette = &self.palette,
            .vram = &self.vram,
            .oam = &self.oam,
        };
    }

    fn write16(buf: []u8, off: usize, val: u16) void {
        buf[off] = @truncate(val);
        buf[off + 1] = @truncate(val >> 8);
    }
};

test "Ppu forced blank renders white scanline" {
    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x0080);

    var ppu = Ppu{};
    ppu.renderLine(mem.view(), 0);
    for (ppu.framebuf[0..gba.width]) |px| {
        try std.testing.expectEqual(@as(u32, 0xFFFFFFFF), px);
    }
}

test "Ppu backdrop and Mode 3 direct pixel" {
    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x0403); // Mode 3 + BG2
    TestMem.write16(&mem.palette, 0, 0x7C00); // Blue backdrop
    TestMem.write16(&mem.vram, 10 * 2, 0x001F); // Red at (10, 0)

    var ppu = Ppu{};
    ppu.renderLine(mem.view(), 0);
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), ppu.framebuf[10]);
}

test "Ppu Mode 4 palette lookup and transparency" {
    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x0404); // Mode 4 + BG2 page 0
    TestMem.write16(&mem.palette, 0, 0x03E0); // Backdrop green
    TestMem.write16(&mem.palette, 2 * 2, 0x001F); // Index 2 = red
    mem.vram[0] = 0; // Transparent -> backdrop
    mem.vram[1] = 2;

    var ppu = Ppu{};
    ppu.renderLine(mem.view(), 0);
    try std.testing.expectEqual(@as(u32, 0xFF00FF00), ppu.framebuf[0]);
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), ppu.framebuf[1]);
}

test "Ppu Mode 0 4bpp tile with horizontal flip and WIN0 masking" {
    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x2100); // WIN0 + BG0
    TestMem.write16(&mem.io_regs, gba.io_reg.bg0cnt, 0x0100); // char_base=0, screen_base=1 (0x800)
    TestMem.write16(&mem.io_regs, gba.io_reg.win0h, (2 << 8) | 8); // WIN0 X=[2..8)
    TestMem.write16(&mem.io_regs, gba.io_reg.win0v, (0 << 8) | 8); // WIN0 Y=[0..8)
    TestMem.write16(&mem.io_regs, gba.io_reg.winin, 0x003F); // All enabled in WIN0
    TestMem.write16(&mem.io_regs, gba.io_reg.winout, 0x0000); // BG0 disabled outside WIN0

    TestMem.write16(&mem.palette, 0, 0x0000); // Backdrop black
    TestMem.write16(&mem.palette, 1 * 2, 0x001F); // Color 1 = red
    TestMem.write16(&mem.palette, 2 * 2, 0x03E0); // Color 2 = green

    // Tile 1, row 0: pixel 0 = color 1, pixel 5 = color 2 -> with hflip, pixel 7=1, pixel 2=2
    mem.vram[32 + 0] = 0x01; // fx 0 -> 1, fx 1 -> 0
    mem.vram[32 + 2] = 0x20; // fx 4 -> 0, fx 5 -> 2
    TestMem.write16(&mem.vram, 0x800, 0x0401); // tile=1, hflip=1

    var ppu = Ppu{};
    ppu.renderLine(mem.view(), 0);
    // x=0 masked out by WIN0 -> backdrop black
    try std.testing.expectEqual(@as(u32, 0xFF000000), ppu.framebuf[0]);
    // x=2 inside WIN0, hflip maps x=2 -> fx=5 -> color 2 (green)
    try std.testing.expectEqual(@as(u32, 0xFF00FF00), ppu.framebuf[2]);
    // x=7 inside WIN0, hflip maps x=7 -> fx=0 -> color 1 (red)
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), ppu.framebuf[7]);
}

test "Ppu alpha blend between BG0 and backdrop" {
    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x0103); // Mode 3 (ignored) - use Mode 0 + BG0:
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x0100); // Mode 0 + BG0
    TestMem.write16(&mem.io_regs, gba.io_reg.bg0cnt, 0x0180); // 8bpp, screen_base=1 (0x800)
    TestMem.write16(&mem.palette, 0, 0x0000); // Backdrop black
    TestMem.write16(&mem.palette, 1 * 2, 0x001E); // Red=30 (even for exact >> 1 check)
    mem.vram[64] = 1; // tile 1 pixel 0 = index 1
    TestMem.write16(&mem.vram, 0x800, 1);

    // BLDCNT: effect=1 (alpha), target1=BG0 (bit 0), target2=backdrop (bit 13 = 0x2000)
    TestMem.write16(&mem.io_regs, gba.io_reg.bldcnt, 0x2041);
    // BLDALPHA: EVA=8, EVB=8 (50/50)
    TestMem.write16(&mem.io_regs, gba.io_reg.bldalpha, 0x0808);

    var ppu = Ppu{};
    ppu.renderLine(mem.view(), 0);
    // Red 30 * 8 / 16 = 15 -> rgb555ToArgb8888(15) = (15<<3)|(15>>2) = 120|3 = 123 (0x7B)
    try std.testing.expectEqual(@as(u32, 0xFF7B0000), ppu.framebuf[0]);
}

test "Ppu affine BG reference latches on y=0 and advances per line" {
    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x0402); // Mode 2 + BG2
    TestMem.write16(&mem.io_regs, gba.io_reg.bg2pa, 0x0100); // PA=1.0
    TestMem.write16(&mem.io_regs, gba.io_reg.bg2pa + 6, 0x0100); // PD=1.0
    TestMem.write16(&mem.io_regs, gba.io_reg.bg2x, 0x0000);
    TestMem.write16(&mem.io_regs, gba.io_reg.bg2x + 4, 0x0000);

    var ppu = Ppu{};
    ppu.renderLine(mem.view(), 0);
    try std.testing.expectEqual(@as(i32, 256), ppu.aff_y[0]);
    ppu.renderLine(mem.view(), 1);
    try std.testing.expectEqual(@as(i32, 512), ppu.aff_y[0]);
}

test "Ppu widescreen Mode 0 extends flagged BG3 while centering BG0 and framebuf" {
    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x0900); // Mode 0 + BG0 + BG3
    TestMem.write16(&mem.io_regs, gba.io_reg.bg0cnt, 0x0100); // prio=0, sbb=1
    TestMem.write16(&mem.io_regs, gba.io_reg.bg3cnt, 0x0203); // prio=3, sbb=2, 256x256
    TestMem.write16(&mem.palette, 0, 0x0000); // Backdrop black
    TestMem.write16(&mem.palette, 1 * 2, 0x001F); // Color 1 = red
    TestMem.write16(&mem.palette, 2 * 2, 0x03E0); // Color 2 = green

    // Solid tile 1 = color 1 (red), solid tile 2 = color 2 (green)
    @memset(mem.vram[32..64], 0x11);
    @memset(mem.vram[64..96], 0x22);
    // BG0 tilemap (sbb=1, 0x800): all tile 2 at col 0
    TestMem.write16(&mem.vram, 0x800, 2);
    // BG3 tilemap (sbb=2, 0x1000): fill row 0 (all 32 cols) with tile 1
    for (0..32) |tx| {
        TestMem.write16(&mem.vram, 0x1000 + tx * 2, 1);
    }

    var ppu = Ppu{};
    ppu.setViewport(320, 0b1000, false); // Only BG3 widens to 320px (pad_l=40)
    ppu.renderLine(mem.view(), 0);

    const wide = ppu.activeFrameSlice();
    try std.testing.expectEqual(@as(usize, 320 * gba.height), wide.len);
    // Margin x=0 renders BG3 red, not BG0 or black backdrop
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), wide[0]);
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), wide[319]);
    // Core GBA x=0 (at wide[40]) has BG0 green above BG3 red
    try std.testing.expectEqual(@as(u32, 0xFF00FF00), wide[40]);
    // 240x160 centered framebuf stays exact
    try std.testing.expectEqual(@as(u32, 0xFF00FF00), ppu.framebuf[0]);
}

test "Ppu widescreen affine BG renders side margins with centered aff_x parity" {
    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x0402); // Mode 2 + BG2
    TestMem.write16(&mem.io_regs, gba.io_reg.bg2cnt, 0x2000); // wrap=1, 128x128
    TestMem.write16(&mem.io_regs, gba.io_reg.bg2pa, 0x0100); // PA=1.0
    TestMem.write16(&mem.io_regs, gba.io_reg.bg2pa + 6, 0x0100); // PD=1.0
    TestMem.write16(&mem.palette, 0, 0x0000);
    TestMem.write16(&mem.palette, 1 * 2, 0x7C00); // Color 1 = blue
    @memset(mem.vram[64..128], 1); // Tile 1 = solid color 1 (8bpp)
    for (0..16) |tx| mem.vram[tx] = 1; // Fill row 0 tiles in 128x128 map

    var ppu = Ppu{};
    ppu.setViewport(320, 0, false);
    ppu.renderLine(mem.view(), 0);
    const wide = ppu.activeFrameSlice();
    try std.testing.expectEqual(@as(u32, 0xFF0000FF), wide[0]);
    try std.testing.expectEqual(@as(u32, 0xFF0000FF), wide[40]);
    try std.testing.expectEqual(@as(u32, 0xFF0000FF), wide[319]);
    try std.testing.expectEqual(@as(i32, 256), ppu.aff_y[0]);
}

test "Ppu Mode 0 horizontal and vertical mosaic snaps BG0 only when bit 6 set" {
    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x0100); // Mode 0 + BG0
    TestMem.write16(&mem.io_regs, gba.io_reg.bg0cnt, 0x0140); // mosaic=1 (bit 6), sbb=1
    TestMem.write16(&mem.io_regs, gba.io_reg.mosaic, 0x0012); // bg_h = 3 (N=2), bg_v = 2 (N=1)
    TestMem.write16(&mem.palette, 0, 0x0000);
    TestMem.write16(&mem.palette, 1 * 2, 0x001F); // red
    TestMem.write16(&mem.palette, 2 * 2, 0x03E0); // green
    TestMem.write16(&mem.palette, 3 * 2, 0x7C00); // blue

    // Tile 1 row 0: px 0=red, px 3=green; row 1: px 0=blue
    mem.vram[32 + 0] = 0x01; // px 0=1, px 1=0
    mem.vram[32 + 1] = 0x20; // px 2=0, px 3=2
    mem.vram[32 + 4] = 0x03; // row 1 px 0=3
    TestMem.write16(&mem.vram, 0x800, 1);

    var ppu = Ppu{};
    ppu.renderLine(mem.view(), 0);
    ppu.renderLine(mem.view(), 1);
    // Horizontal block size 3 -> x=0,1,2 all sample x=0 (red); x=3 samples x=3 (green)
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), ppu.framebuf[0]);
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), ppu.framebuf[1]);
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), ppu.framebuf[2]);
    try std.testing.expectEqual(@as(u32, 0xFF00FF00), ppu.framebuf[3]);
    // Vertical block size 2 -> y=1 repeats y=0 (red), not row 1 (blue)
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), ppu.framebuf[gba.width + 0]);

    // Clearing BG0CNT bit 6 disables mosaic even while MOSAIC register stays non-zero
    TestMem.write16(&mem.io_regs, gba.io_reg.bg0cnt, 0x0100);
    ppu.renderLine(mem.view(), 1);
    try std.testing.expectEqual(@as(u32, 0xFF0000FF), ppu.framebuf[gba.width + 0]);
}

test "Ppu OBJ horizontal and vertical mosaic snaps sprites with attr0 bit 12 set" {
    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x1000); // OBJ enabled
    TestMem.write16(&mem.io_regs, gba.io_reg.mosaic, 0x1100); // obj_h = 2 (N=1), obj_v = 2 (N=1)
    TestMem.write16(&mem.palette, 0, 0x0000);
    TestMem.write16(&mem.palette, 0x200 + 1 * 2, 0x001F); // OBJ color 1 = red
    TestMem.write16(&mem.palette, 0x200 + 2 * 2, 0x03E0); // OBJ color 2 = green

    // Sprite at (0, 0), 8x8, mosaic bit 12 set (0x1000), tile 0
    TestMem.write16(&mem.oam, 0, 0x1000);
    TestMem.write16(&mem.oam, 2, 0x0000);
    TestMem.write16(&mem.oam, 4, 0x0000);
    // Tile 0 (4bpp at 0x10000): row 0 px 0=1, row 1 px 0=2
    mem.vram[0x10000 + 0] = 0x01; // row 0: px 0=1, px 1=0
    mem.vram[0x10000 + 4] = 0x02; // row 1: px 0=2

    var ppu = Ppu{};
    ppu.renderLine(mem.view(), 0);
    ppu.renderLine(mem.view(), 1);
    // obj_h=2 repeats x=0 color (red) onto x=1; obj_v=2 repeats y=0 onto y=1
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), ppu.framebuf[0]);
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), ppu.framebuf[1]);
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), ppu.framebuf[gba.width + 0]);
}
