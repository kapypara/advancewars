const std = @import("std");
const gba = @import("defs.zig");

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

/// Software per-scanline GBA PPU renderer producing a 240x160 ARGB8888 framebuffer.
pub const Ppu = struct {
    framebuf: [gba.width * gba.height]u32 = @splat(0),
    top_c: [gba.width]u16 = @splat(0),
    bot_c: [gba.width]u16 = @splat(0),
    top_l: [gba.width]u8 = @splat(0),
    bot_l: [gba.width]u8 = @splat(0),
    top_semi: [gba.width]u8 = @splat(0),
    win: [gba.width]u8 = @splat(0),
    aff_x: [2]i32 = .{ 0, 0 },
    aff_y: [2]i32 = .{ 0, 0 },
    aff_raw_x: [2]u32 = .{ 0, 0 },
    aff_raw_y: [2]u32 = .{ 0, 0 },

    inline fn plot(self: *Ppu, x: usize, color: u16, layer: u8, semi: u8) void {
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

    fn lineMode3(self: *Ppu, mem: gba.PpuMemory, y: usize) void {
        for (0..gba.width) |x| {
            const addr: u32 = @intCast((y * gba.width + x) * 2);
            self.plot(x, mem.vramRead16(addr), 2, 0);
        }
    }

    fn lineMode4(self: *Ppu, mem: gba.PpuMemory, y: usize, dispcnt: u16) void {
        const page: u32 = if ((dispcnt & 0x0010) != 0) 0xA000 else 0;
        for (0..gba.width) |x| {
            const idx = mem.vramRead8(page + @as(u32, @intCast(y * gba.width + x)));
            if (idx != 0) {
                self.plot(x, mem.palRead16(@as(u32, idx) * 2), 2, 0);
            }
        }
    }

    fn lineTextBg(self: *Ppu, mem: gba.PpuMemory, bg: u32, y: usize) void {
        const bgcnt = mem.ioRead16(gba.io_reg.bg0cnt + bg * 2);
        const hofs: u32 = mem.ioRead16(gba.io_reg.bg0hofs + bg * 4) & 0x1FF;
        const vofs: u32 = mem.ioRead16(gba.io_reg.bg0vofs + bg * 4) & 0x1FF;
        const char_base: u32 = @as(u32, (bgcnt >> 2) & 3) * 0x4000;
        const screen_base: u32 = @as(u32, (bgcnt >> 8) & 0x1F) * 0x800;
        const bpp8 = ((bgcnt >> 7) & 1) != 0;
        const size: u32 = (bgcnt >> 14) & 3;
        const w_px: u32 = if ((size & 1) != 0) 512 else 256;
        const h_px: u32 = if ((size & 2) != 0) 512 else 256;

        const by: u32 = (vofs + @as(u32, @intCast(y))) % h_px;
        const ty: u32 = by >> 3;
        const py: u32 = by & 7;
        const wide_stride: u32 = if ((size & 1) != 0) 2 else 1;

        for (0..gba.width) |x| {
            const bx: u32 = (hofs + @as(u32, @intCast(x))) % w_px;
            const tx: u32 = bx >> 3;
            const px: u32 = bx & 7;
            const block: u32 = (tx >> 5) + ((ty >> 5) * wide_stride);
            const e = mem.vramRead16(screen_base + block * 0x800 + ((ty & 31) * 32 + (tx & 31)) * 2);
            const fx: u32 = if ((e & 0x400) != 0) 7 - px else px;
            const fy: u32 = if ((e & 0x800) != 0) 7 - py else py;
            const tile: u32 = e & 0x3FF;
            if (bpp8) {
                const ci = mem.vramRead8(char_base + tile * 64 + fy * 8 + fx);
                if (ci != 0) {
                    self.plot(x, mem.palRead16(@as(u32, ci) * 2), @intCast(bg), 0);
                }
            } else {
                const b = mem.vramRead8(char_base + tile * 32 + fy * 4 + (fx >> 1));
                const ci: u32 = if ((fx & 1) != 0) (b >> 4) else (b & 15);
                if (ci != 0) {
                    const pal_bank: u32 = (e >> 12) & 15;
                    self.plot(x, mem.palRead16((pal_bank * 16 + ci) * 2), @intCast(bg), 0);
                }
            }
        }
    }

    fn lineAffineBg(self: *Ppu, mem: gba.PpuMemory, bg: u32) void {
        const i: usize = @intCast(bg - 2);
        const base: u32 = gba.io_reg.bg2pa + @as(u32, @intCast(i)) * 0x10;
        const pa: i32 = @as(i16, @bitCast(mem.ioRead16(base)));
        const pb: i32 = @as(i16, @bitCast(mem.ioRead16(base + 2)));
        const pc: i32 = @as(i16, @bitCast(mem.ioRead16(base + 4)));
        const pd: i32 = @as(i16, @bitCast(mem.ioRead16(base + 6)));
        const bgcnt = mem.ioRead16(gba.io_reg.bg0cnt + bg * 2);
        const char_base: u32 = @as(u32, (bgcnt >> 2) & 3) * 0x4000;
        const screen_base: u32 = @as(u32, (bgcnt >> 8) & 0x1F) * 0x800;
        const shift: u5 = @intCast((bgcnt >> 14) & 3);
        const size: i32 = @as(i32, 128) << shift;
        const wrap = ((bgcnt >> 13) & 1) != 0;

        self.affineLatch(mem, i, false);
        var cx: i32 = self.aff_x[i];
        var cy: i32 = self.aff_y[i];
        for (0..gba.width) |x| {
            var tx: i32 = cx >> 8;
            var ty: i32 = cy >> 8;
            if (wrap) {
                tx &= size - 1;
                ty &= size - 1;
            } else if (tx < 0 or ty < 0 or tx >= size or ty >= size) {
                cx +%= pa;
                cy +%= pc;
                continue;
            }
            const tile = mem.vramRead8(screen_base + @as(u32, @intCast((ty >> 3) * (size >> 3) + (tx >> 3))));
            const ci = mem.vramRead8(char_base + @as(u32, tile) * 64 + @as(u32, @intCast((ty & 7) * 8 + (tx & 7))));
            if (ci != 0) {
                self.plot(x, mem.palRead16(@as(u32, ci) * 2), @intCast(bg), 0);
            }
            cx +%= pa;
            cy +%= pc;
        }
        self.aff_x[i] +%= pb;
        self.aff_y[i] +%= pd;
    }

    fn lineObjs(self: *Ppu, mem: gba.PpuMemory, y: usize, dispcnt: u16, prio: i32) void {
        if ((dispcnt & 0x1000) == 0) return;
        const mapping_1d = ((dispcnt >> 6) & 1) != 0;
        const bitmap_mode = (dispcnt & 7) >= 3;
        const objwin_ctl: u8 = @truncate(mem.ioRead16(gba.io_reg.winout) >> 8);
        const y_i32: i32 = @intCast(y);

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

            const w = obj_width[shape][size];
            const h = obj_height[shape][size];
            const oy: i32 = @intCast(a0 & 0xFF);
            var ox: i32 = @intCast(a1 & 0x1FF);
            if (ox >= 240) ox -= 512;

            var bw = w;
            var bh = h;
            if (affine and (a0 & 0x200) != 0) {
                bw *= 2;
                bh *= 2;
            }
            const py: i32 = (y_i32 - oy) & 0xFF;
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

            var px: i32 = 0;
            while (px < bw) : (px += 1) {
                const sx: i32 = ox + px;
                if (sx < 0 or sx >= @as(i32, @intCast(gba.width))) continue;

                var fx: i32 = undefined;
                var fy: i32 = undefined;
                if (affine) {
                    const ix: i32 = px - @divTrunc(bw, 2);
                    fx = ((pa * ix + pb * iy) >> 8) + @divTrunc(w, 2);
                    fy = ((pc * ix + pd * iy) >> 8) + @divTrunc(h, 2);
                    if (fx < 0 or fx >= w or fy < 0 or fy >= h) continue;
                } else {
                    fx = if ((a1 & 0x1000) != 0) w - 1 - px else px;
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

                const sx_u: usize = @intCast(sx);
                if (prio < 0) {
                    self.win[sx_u] = objwin_ctl;
                    continue;
                }
                const c = if (bpp8)
                    mem.palRead16(0x200 + ci * 2)
                else
                    mem.palRead16(0x200 + (pal * 16 + ci) * 2);
                self.plot(sx_u, c, 4, if (mode == 1) 1 else 0);
            }
        }
    }

    fn windowLine(self: *Ppu, mem: gba.PpuMemory, y: usize, dispcnt: u16) void {
        if ((dispcnt & 0xE000) == 0) {
            @memset(&self.win, 0x3F);
            return;
        }
        const winin = mem.ioRead16(gba.io_reg.winin);
        const winout = mem.ioRead16(gba.io_reg.winout);
        @memset(&self.win, @truncate(winout & 0x3F));
        if ((dispcnt & 0x8000) != 0) {
            self.lineObjs(mem, y, dispcnt, -1);
        }

        const y_i32: i32 = @intCast(y);
        var w_rev: u32 = 2;
        while (w_rev > 0) {
            w_rev -= 1;
            const win_enable_shift: u4 = @intCast(w_rev);
            if ((dispcnt & (@as(u16, 0x2000) << win_enable_shift)) == 0) continue;
            if (!winContains(mem.ioRead16(gba.io_reg.win0v + w_rev * 2), y_i32, @intCast(gba.height))) continue;
            const h = mem.ioRead16(gba.io_reg.win0h + w_rev * 2);
            const ctl: u8 = @truncate((winin >> @intCast(w_rev * 8)) & 0x3F);
            for (0..gba.width) |x| {
                if (winContains(h, @intCast(x), @intCast(gba.width))) {
                    self.win[x] = ctl;
                }
            }
        }
    }

    /// Compose scanline `y` (`0 <= y < 160`) from live PPU memory into `framebuf`.
    pub fn renderLine(self: *Ppu, mem: gba.PpuMemory, y: usize) void {
        if (y >= gba.height) return;

        const dispcnt = mem.ioRead16(gba.io_reg.dispcnt);
        const mode: u32 = dispcnt & 7;
        const out = self.framebuf[y * gba.width .. (y + 1) * gba.width];

        if (y == 0) {
            self.affineLatch(mem, 0, true);
            self.affineLatch(mem, 1, true);
        }
        if ((dispcnt & 0x80) != 0) {
            @memset(out, 0xFFFFFFFF);
            return;
        }

        const backdrop = mem.palRead16(0);
        @memset(&self.top_c, backdrop);
        @memset(&self.bot_c, backdrop);
        @memset(&self.top_l, 5);
        @memset(&self.bot_l, 5);
        @memset(&self.top_semi, 0);

        self.windowLine(mem, y, dispcnt);

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
                    self.lineTextBg(mem, bg_rev, y);
                } else if ((mode == 1 and bg_rev == 2) or (mode == 2 and bg_rev >= 2)) {
                    self.lineAffineBg(mem, bg_rev);
                } else if (bg_rev == 2 and mode == 3) {
                    self.lineMode3(mem, y);
                } else if (bg_rev == 2 and mode == 4) {
                    self.lineMode4(mem, y, dispcnt);
                }
            }
            self.lineObjs(mem, y, dispcnt, @intCast(prio_rev));
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

        for (0..gba.width) |x| {
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
