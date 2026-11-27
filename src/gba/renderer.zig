const std = @import("std");
const gba = @import("defs.zig");
const ppu_mod = @import("ppu.zig");
const Ppu = ppu_mod.Ppu;

inline fn readLe16(ptr: [*]const u8, off: usize) u16 {
    return @as(u16, ptr[off]) | (@as(u16, ptr[off + 1]) << 8);
}

inline fn readLe32(ptr: [*]const u8, off: usize) u32 {
    return @as(u32, ptr[off]) |
        (@as(u32, ptr[off + 1]) << 8) |
        (@as(u32, ptr[off + 2]) << 16) |
        (@as(u32, ptr[off + 3]) << 24);
}

/// Optional wide scene state for full-width Advance Wars battle map composition beyond the 256px GBA BG wrap limit.
pub const WideScene = struct {
    ewram: [*]const u8,
    iwram: ?[*]const u8 = null,
    rom: [*]const u8,
    rom_len: usize,
    map_width: u16,
    map_height: u16,
    view_wx: i32,
    view_wy: i32,
    show_reachability: bool = false,
};

fn computeMarginCoord(
    sx: usize,
    pad_l: usize,
    view_wx: i32,
    max_wx: i32,
    bg_mos: bool,
    bg_h: usize,
) ?i32 {
    const pad_i: i32 = @intCast(pad_l);
    const bg_h_i: i32 = @intCast(bg_h);
    const gx: i32 = @as(i32, @intCast(sx)) - pad_i;
    const eff_gx: i32 = if (bg_mos and bg_h > 1) gx - @mod(gx, bg_h_i) else gx;
    const wx: i32 = view_wx + eff_gx;
    if (wx < 0 or wx >= max_wx) return null;
    return wx;
}

/// Render full-width battle map terrain and fog-of-war across `0..vw` on BG3 with zero center/margin seam.
pub fn renderTerrainFull(
    ppu: *Ppu,
    mem: gba.PpuMemory,
    scene: WideScene,
    vw: usize,
    pad_l: usize,
    char_base: u32,
    bpp8: bool,
    bg_mos: bool,
    bg_h: usize,
    eff_y: usize,
) void {
    const wy: i32 = scene.view_wy + @as(i32, @intCast(eff_y));
    if (wy < 0 or wy >= @as(i32, scene.map_height) * 16) return;

    const my: usize = @intCast(wy >> 4);
    const sub_y: usize = @intCast((wy >> 3) & 1);
    const py_bm: u32 = @intCast(wy & 7);
    const map_base_off: usize = 0x157F8;
    const row_off: usize = readLe16(scene.ewram, map_base_off + 0x4682 + my * 2);
    const max_wx: i32 = @as(i32, scene.map_width) * 16;

    for (0..vw) |sx| {
        const wx = computeMarginCoord(sx, pad_l, scene.view_wx, max_wx, bg_mos, bg_h) orelse continue;
        const mx: usize = @intCast(wx >> 4);
        const cell_idx: usize = row_off + mx;
        if (map_base_off + 0x234A + cell_idx >= 0x40000 or
            map_base_off + 0x0A22 + cell_idx * 2 + 1 >= 0x40000) continue;

        const vis = scene.ewram[map_base_off + 0x234A + cell_idx];
        const tile_id: usize = readLe16(scene.ewram, map_base_off + 0x0A22 + cell_idx * 2);
        const sub_x: usize = @intCast((wx >> 3) & 1);
        const rom_off: usize = 0x0D1FC0 + tile_id * 8 + sub_x * 4 + sub_y * 2;
        if (rom_off + 1 >= scene.rom_len) continue;

        var e: u16 = readLe16(scene.rom, rom_off);
        if (vis == 0) e +%= 0x4000;
        const px_bm: u32 = @intCast(wx & 7);
        ppu.plotTilePixel(mem, sx, 3, char_base, bpp8, e, px_bm, py_bm);
    }
}

/// Render off-screen movement/attack reachability highlights into left/right widescreen side margins on BG2.
pub fn renderReachabilityMargins(
    ppu: *Ppu,
    scene: WideScene,
    vw: usize,
    pad_l: usize,
    eff_y: usize,
) void {
    if (!scene.show_reachability) return;
    const iwram = scene.iwram orelse return;
    const wy: i32 = scene.view_wy + @as(i32, @intCast(eff_y));
    if (wy < 0 or wy >= @as(i32, scene.map_height) * 16) return;

    const my: usize = @intCast(wy >> 4);
    if (my >= 40) return;
    const row_ptr = readLe32(iwram, 0x3600 + my * 4);
    if (row_ptr < 0x0200_0000 or row_ptr + @as(u32, scene.map_width) > 0x0204_0000) return;
    const row_off: usize = row_ptr & 0x3FFFF;
    const max_wx: i32 = @as(i32, scene.map_width) * 16;
    const pad_i: i32 = @intCast(pad_l);
    const highlight_color: u16 = 0x7FFF; // Bright highlight blended via PPU semi-transparent BG2 alpha

    const spans = [2][2]usize{
        .{ 0, pad_l },
        .{ pad_l + gba.width, vw },
    };
    for (spans) |span| {
        for (span[0]..span[1]) |sx| {
            const wx: i32 = scene.view_wx + (@as(i32, @intCast(sx)) - pad_i);
            if (wx < 0 or wx >= max_wx) continue;
            const mx: usize = @intCast(wx >> 4);
            const cost: i8 = @bitCast(scene.ewram[row_off + mx]);
            if (cost >= 0) {
                ppu.plot(sx, highlight_color, 2, 1);
            }
        }
    }
}

/// Render full-width visible battle units across `0..vw` on BG1 with zero center/margin seam.
pub fn renderUnitsFull(
    ppu: *Ppu,
    mem: gba.PpuMemory,
    scene: WideScene,
    vw: usize,
    pad_l: usize,
    vofs: u32,
    char_base: u32,
    bpp8: bool,
    bg_mos: bool,
    bg_h: usize,
    eff_y: usize,
) void {
    const bg3_vofs: u32 = mem.ioRead16(gba.io_reg.bg3vofs) & 0x1FF;
    var dv: i32 = @as(i32, @intCast(vofs)) - @as(i32, @intCast(bg3_vofs));
    if (dv >= 256) dv -= 512 else if (dv < -256) dv += 512;

    const wy: i32 = scene.view_wy + dv + @as(i32, @intCast(eff_y));
    if (wy < 0 or wy >= @as(i32, scene.map_height) * 16) return;

    const my: usize = @intCast(wy >> 4);
    const sub_y: usize = @intCast((wy >> 3) & 1);
    const py_bm: u32 = @intCast(wy & 7);
    const map_base_off: usize = 0x157F8;
    const row_off: usize = readLe16(scene.ewram, map_base_off + 0x4682 + my * 2);
    const max_wx: i32 = @as(i32, scene.map_width) * 16;

    for (0..vw) |sx| {
        const wx = computeMarginCoord(sx, pad_l, scene.view_wx, max_wx, bg_mos, bg_h) orelse continue;
        const mx: usize = @intCast(wx >> 4);
        const cell_idx: usize = row_off + mx;
        if (map_base_off + 0x234A + cell_idx >= 0x40000 or
            map_base_off + 0x051A + cell_idx >= 0x40000) continue;

        if (scene.ewram[map_base_off + 0x234A + cell_idx] == 0) continue;

        const uid: usize = scene.ewram[map_base_off + 0x051A + cell_idx];
        if (uid == 0) continue;

        const u_off: usize = 0x19F34 + uid * 12;
        if (u_off + 11 >= 0x40000) continue;
        const utype: usize = scene.ewram[u_off];
        const flags = scene.ewram[u_off + 1];
        if (utype == 0 or (flags & 0x04) != 0) continue;

        const army_idx: usize = (uid - 1) >> 6;
        const style_off: usize = 0x1AB34 + (army_idx + 1) * 0x68 + 0x1A;
        const style: usize = if (style_off < 0x40000) scene.ewram[style_off] else 0;
        const tid_off: usize = 0x28_2F2C + style * 0x32 + utype * 2;
        if (tid_off + 1 >= scene.rom_len) continue;
        const tid_base: u16 = readLe16(scene.rom, tid_off) *% 4;

        const pal_idx: usize = if ((flags & 1) != 0) 0 else (army_idx + 1);
        const pal_off: usize = 0x08_0D50 + pal_idx * 2;
        if (pal_off + 1 >= scene.rom_len) continue;
        const pal_base: u16 = readLe16(scene.rom, pal_off);

        const sub_x: usize = @intCast((wx >> 3) & 1);
        const is_flipped = (army_idx & 1) == 0;
        const sub_idx: u16 = @intCast(sub_y * 2 + (if (is_flipped) 1 - sub_x else sub_x));
        const hflip: u16 = if (is_flipped) 0x0400 else 0;
        const e: u16 = pal_base +% tid_base +% sub_idx +% hflip;
        const px_bm: u32 = @intCast(wx & 7);
        ppu.plotTilePixel(mem, sx, 1, char_base, bpp8, e, px_bm, py_bm);
    }
}

fn propertyAttr2(scene: WideScene, btype: u8, owner: u8, vis: u8) ?u16 {
    var idx: usize = owner;
    const tbl_addr: u32 = switch (btype) {
        6 => 0x0828_5FB8, // City
        10 => 0x0828_5FE0, // Base / Factory
        11 => 0x0828_5FF4, // Airport
        14 => blk: { // Port
            if (vis == 0) idx = 0;
            break :blk 0x0828_5FCC;
        },
        8 => blk: { // HQ
            const army_off = 0x1AB34 + @as(usize, owner) * 0x68 + 0x1A;
            const style: usize = if (owner > 0 and army_off < 0x40000) scene.ewram[army_off] else 1;
            const o_idx: usize = if (owner > 0) owner - 1 else 0;
            const s_idx: usize = if (style > 0) (style - 1) * 4 else 0;
            idx = o_idx + s_idx;
            break :blk 0x0828_6008;
        },
        else => return null,
    };
    const tbl_off: usize = (tbl_addr - 0x0800_0000) + idx * 4;
    if (tbl_off + 3 >= scene.rom_len) return null;
    const desc_ptr = readLe32(scene.rom, tbl_off);
    if (desc_ptr < 0x0800_0000) return null;
    const desc_off: usize = desc_ptr - 0x0800_0000;
    if (desc_off + 7 >= scene.rom_len) return null;
    var attr2 = readLe16(scene.rom, desc_off + 6) +% 0x36;
    if (vis == 0) attr2 = (attr2 & 0x0FFF) | 0xD000;
    return attr2;
}

/// Render full-width map buildings/properties across `0..vw` from IWRAM's OAM list.
pub fn renderPropertiesFull(
    ppu: *Ppu,
    mem: gba.PpuMemory,
    scene: WideScene,
    y: usize,
    vw: usize,
    pad_l: usize,
) void {
    const iwram = scene.iwram orelse return;
    const wy: i32 = scene.view_wy + @as(i32, @intCast(y));

    const prop_base: usize = 0x3400;
    var count: usize = 0;
    while (count < 128) : (count += 1) {
        if (iwram[prop_base + count * 4] == 0xFF) break;
    }
    if (count == 0) return;

    const pad_i: i32 = @intCast(pad_l);
    const map_base_off: usize = 0x157F8;

    var rev = count;
    while (rev > 0) {
        rev -= 1;
        const entry_off = prop_base + rev * 4;
        const b = iwram[entry_off];
        const mx: usize = iwram[entry_off + 1];
        const my: usize = iwram[entry_off + 2];
        if (mx >= scene.map_width or my >= scene.map_height) continue;

        const wy0: i32 = @as(i32, @intCast(my)) * 16 - 16;
        if (wy < wy0 or wy >= wy0 + 32) continue;

        const wx0: i32 = @as(i32, @intCast(mx)) * 16;
        const ox: i32 = wx0 - scene.view_wx + pad_i;
        if (ox + 16 <= 0 or ox >= @as(i32, @intCast(vw))) continue;

        const row_off: usize = readLe16(scene.ewram, map_base_off + 0x4682 + my * 2);
        const cell_idx: usize = row_off + mx;
        if (map_base_off + 0x234A + cell_idx >= 0x40000) continue;
        const vis = scene.ewram[map_base_off + 0x234A + cell_idx];

        const btype = b & 0x1F;
        const owner = (b >> 5) & 7;
        const attr2 = propertyAttr2(scene, btype, owner, vis) orelse continue;
        const tile_idx: u32 = attr2 & 0x3FF;
        const pal: u32 = (attr2 >> 12) & 15;
        const fy_u: u32 = @intCast(wy - wy0);
        const ty: u32 = fy_u >> 3;

        var px: i32 = 0;
        while (px < 16) : (px += 1) {
            const sx_i = ox + px;
            if (sx_i < 0 or sx_i >= @as(i32, @intCast(vw))) continue;
            const sx: usize = @intCast(sx_i);

            const fx_u: u32 = @intCast(px);
            const tx: u32 = fx_u >> 3;
            const tn: u32 = tile_idx +% ty * 2 +% tx;
            const addr: u32 = 0x10000 + (tn & 0x3FF) * 32;
            const byte = mem.vramRead8(addr + (fy_u & 7) * 4 + ((fx_u & 7) >> 1));
            const ci: u32 = if ((fx_u & 1) != 0) (byte >> 4) else (byte & 15);
            if (ci == 0) continue;

            const c = mem.palRead16(0x200 + (pal * 16 + ci) * 2);
            ppu.plot(sx, c, 4, 0);
        }
    }
}

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

    fn write32(buf: []u8, off: usize, val: u32) void {
        buf[off] = @truncate(val);
        buf[off + 1] = @truncate(val >> 8);
        buf[off + 2] = @truncate(val >> 16);
        buf[off + 3] = @truncate(val >> 24);
    }
};

test "WideScene renders off-screen terrain with map-bounds clamp and fog shift" {
    const allocator = std.testing.allocator;
    const ewram = try allocator.alloc(u8, 0x40000);
    defer allocator.free(ewram);
    @memset(ewram, 0);
    const rom = try allocator.alloc(u8, 0x0D2020);
    defer allocator.free(rom);
    @memset(rom, 0);

    const map_base: usize = 0x157F8;
    // mx=0 & mx=1 visible (vis=1, tid=1), mx=16 in fog (vis=0, tid=1)
    ewram[map_base + 0x234A + 0] = 1;
    ewram[map_base + 0x0A22 + 0] = 1;
    ewram[map_base + 0x234A + 1] = 1;
    ewram[map_base + 0x0A22 + 1 * 2] = 1;
    ewram[map_base + 0x234A + 16] = 0;
    ewram[map_base + 0x0A22 + 16 * 2] = 1;
    rom[0x0D1FC0 + 1 * 8 + 0] = 1;
    rom[0x0D1FC0 + 1 * 8 + 4] = 1;

    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x0800);
    TestMem.write16(&mem.io_regs, gba.io_reg.bg3cnt, 0x1F0B);
    TestMem.write16(&mem.io_regs, gba.io_reg.bg3hofs, 16);
    TestMem.write16(&mem.palette, 0, 0x0000);
    TestMem.write16(&mem.palette, 1 * 2, 0x001F); // Bank 0 red
    TestMem.write16(&mem.palette, (4 * 16 + 1) * 2, 0x03E0); // Bank 4 fog green
    @memset(mem.vram[0x8000 + 32 .. 0x8000 + 64], 0x11);

    var ppu = Ppu{};
    ppu.setViewport(320, 0, false); // pad_l = 40
    ppu.setWideScene(.{
        .ewram = ewram.ptr,
        .rom = rom.ptr,
        .rom_len = rom.len,
        .map_width = 20,
        .map_height = 10,
        .view_wx = 16,
        .view_wy = 0,
    });
    ppu.renderLine(mem.view(), 0);
    const wide = ppu.activeFrameSlice();

    try std.testing.expectEqual(@as(u32, 0xFF000000), wide[0]);
    try std.testing.expectEqual(@as(u32, 0xFF000000), wide[23]);
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), wide[24]);
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), wide[39]); // left margin edge
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), wide[40]); // center region rendered uniformly
    try std.testing.expectEqual(@as(u32, 0xFF00FF00), wide[280]);
}

test "WideScene survives zeroed BG3HOFS and draws off-screen properties" {
    const allocator = std.testing.allocator;
    const ewram = try allocator.alloc(u8, 0x40000);
    defer allocator.free(ewram);
    @memset(ewram, 0);
    const iwram = try allocator.alloc(u8, 0x8000);
    defer allocator.free(iwram);
    @memset(iwram, 0);
    const rom = try allocator.alloc(u8, 0x28_6100);
    defer allocator.free(rom);
    @memset(rom, 0);

    const map_base: usize = 0x157F8;
    for (0..10) |my| {
        const ro: u16 = @intCast(my * 22);
        ewram[map_base + 0x4682 + my * 2] = @truncate(ro);
        ewram[map_base + 0x4682 + my * 2 + 1] = @truncate(ro >> 8);
    }
    ewram[map_base + 0x234A + 22 + 0] = 1;
    ewram[map_base + 0x0A22 + (22 + 0) * 2] = 1;
    ewram[map_base + 0x234A + 22 + 18] = 1;
    ewram[map_base + 0x0A22 + (22 + 18) * 2] = 1;
    rom[0x0D1FC0 + 1 * 8 + 0] = 1;

    TestMem.write32(rom, 0x28_5FB8, 0x0828_5E78);
    TestMem.write16(rom, 0x28_5E78 + 6, 0x8000);

    iwram[0x3400 + 0] = 6;
    iwram[0x3400 + 1] = 18;
    iwram[0x3400 + 2] = 1;
    iwram[0x3400 + 4] = 0xFF;

    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x1F00);
    TestMem.write16(&mem.io_regs, gba.io_reg.bg3cnt, 0x1F0B);
    TestMem.write16(&mem.io_regs, gba.io_reg.bg3hofs, 0);
    TestMem.write16(&mem.palette, 0, 0x0000);
    TestMem.write16(&mem.palette, 1 * 2, 0x03E0);
    TestMem.write16(&mem.palette, 0x200 + (8 * 16 + 2) * 2, 0x7C00);
    @memset(mem.vram[0x8000 + 32 .. 0x8000 + 64], 0x11);
    @memset(mem.vram[0x10000 + 0x36 * 32 .. 0x10000 + 0x37 * 32], 0x22);

    var ppu = Ppu{};
    ppu.setViewport(400, 0, false); // pad_l = 80

    ppu.setWideScene(.{
        .ewram = ewram.ptr,
        .iwram = iwram.ptr,
        .rom = rom.ptr,
        .rom_len = rom.len,
        .map_width = 22,
        .map_height = 10,
        .view_wx = 64,
        .view_wy = 0,
    });
    ppu.renderLine(mem.view(), 16);
    try std.testing.expectEqual(@as(u32, 0xFF00FF00), ppu.activeFrameSlice()[16 * 400 + 16]);

    ppu.setWideScene(.{
        .ewram = ewram.ptr,
        .iwram = iwram.ptr,
        .rom = rom.ptr,
        .rom_len = rom.len,
        .map_width = 22,
        .map_height = 10,
        .view_wx = 0,
        .view_wy = 0,
    });
    ppu.renderLine(mem.view(), 0);
    try std.testing.expectEqual(@as(u32, 0xFF0000FF), ppu.activeFrameSlice()[368]);
}

test "WideScene draws off-screen BG1 units with fog culling" {
    const allocator = std.testing.allocator;
    const ewram = try allocator.alloc(u8, 0x40000);
    defer allocator.free(ewram);
    @memset(ewram, 0);
    const rom = try allocator.alloc(u8, 0x28_3000);
    defer allocator.free(rom);
    @memset(rom, 0);

    const map_base: usize = 0x157F8;
    for (0..10) |my| {
        const ro: u16 = @intCast(my * 22);
        ewram[map_base + 0x4682 + my * 2] = @truncate(ro);
        ewram[map_base + 0x4682 + my * 2 + 1] = @truncate(ro >> 8);
    }

    ewram[map_base + 0x234A + 1 * 22 + 17] = 0;
    ewram[map_base + 0x0A22 + (1 * 22 + 17) * 2] = 1;
    ewram[map_base + 0x234A + 2 * 22 + 16] = 1;
    ewram[map_base + 0x0A22 + (2 * 22 + 16) * 2] = 1;
    ewram[map_base + 0x051A + 2 * 22 + 16] = 1;
    ewram[map_base + 0x234A + 2 * 22 + 17] = 0;
    ewram[map_base + 0x0A22 + (2 * 22 + 17) * 2] = 1;
    ewram[map_base + 0x051A + 2 * 22 + 17] = 2;
    rom[0x0D1FC0 + 1 * 8 + 0] = 1;
    rom[0x0D1FC0 + 1 * 8 + 2] = 1;

    ewram[0x19F34 + 1 * 12] = 1;
    ewram[0x19F34 + 2 * 12] = 1;
    TestMem.write16(rom, 0x28_2F2C + 1 * 2, 1);
    TestMem.write16(rom, 0x08_0D50 + 2, 0x2000);

    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x0A00);
    TestMem.write16(&mem.io_regs, gba.io_reg.bg1cnt, 0x1E02);
    TestMem.write16(&mem.io_regs, gba.io_reg.bg3cnt, 0x1F0B);
    TestMem.write16(&mem.io_regs, gba.io_reg.bg1vofs, 3);
    TestMem.write16(&mem.palette, 0, 0x0000);
    TestMem.write16(&mem.palette, 1 * 2, 0x001F);
    TestMem.write16(&mem.palette, (4 * 16 + 1) * 2, 0x03E0);
    TestMem.write16(&mem.palette, (2 * 16 + 3) * 2, 0x03FF);
    @memset(mem.vram[0x8000 + 32 .. 0x8000 + 64], 0x11);
    @memset(mem.vram[0x0000 + 5 * 32 .. 0x0000 + 6 * 32], 0x33);

    var ppu = Ppu{};
    ppu.setViewport(320, 0, false); // pad_l = 40
    ppu.setWideScene(.{
        .ewram = ewram.ptr,
        .rom = rom.ptr,
        .rom_len = rom.len,
        .map_width = 22,
        .map_height = 10,
        .view_wx = 0,
        .view_wy = 0,
    });
    ppu.renderLine(mem.view(), 29);
    const wide = ppu.activeFrameSlice();
    try std.testing.expectEqual(@as(u32, 0xFFFFFF00), wide[29 * 320 + 296]);
    try std.testing.expectEqual(@as(u32, 0xFF00FF00), wide[29 * 320 + 312]);
}

test "WideScene blends reachability highlights into side margins only for reachable tiles" {
    const allocator = std.testing.allocator;
    const ewram = try allocator.alloc(u8, 0x40000);
    defer allocator.free(ewram);
    @memset(ewram, 0);
    const iwram = try allocator.alloc(u8, 0x8000);
    defer allocator.free(iwram);
    @memset(iwram, 0);
    const rom = try allocator.alloc(u8, 0x0D2020);
    defer allocator.free(rom);
    @memset(rom, 0);

    const map_base: usize = 0x157F8;
    // row 0: off = 0
    ewram[map_base + 0x4682] = 0;
    ewram[map_base + 0x4683] = 0;
    ewram[map_base + 0x234A + 16] = 1; // mx=16 visible
    ewram[map_base + 0x0A22 + 16 * 2] = 1;
    ewram[map_base + 0x234A + 17] = 1; // mx=17 visible
    ewram[map_base + 0x0A22 + 17 * 2] = 1;
    rom[0x0D1FC0 + 1 * 8 + 0] = 1;

    // Reachability cost table at 0x0202_0000: mx=16 reachable (cost=1), mx=17 unreachable (-1)
    TestMem.write32(iwram, 0x3600, 0x0202_0000);
    ewram[0x20000 + 16] = 1;
    ewram[0x20000 + 17] = 0xFF;

    var mem = TestMem{};
    TestMem.write16(&mem.io_regs, gba.io_reg.dispcnt, 0x0C00); // Mode 0 + BG2 + BG3
    TestMem.write16(&mem.io_regs, gba.io_reg.bg2cnt, 0x0F09); // cbb=2, sbb=15, prio=1
    TestMem.write16(&mem.io_regs, gba.io_reg.bg3cnt, 0x1F0B); // cbb=2, sbb=31, prio=3
    TestMem.write16(&mem.io_regs, gba.io_reg.bldcnt, 0x0844); // BG2 -> BG3 alpha
    TestMem.write16(&mem.io_regs, gba.io_reg.bldalpha, 0x0808); // 50/50 blend
    TestMem.write16(&mem.palette, 0, 0x0000);
    TestMem.write16(&mem.palette, 1 * 2, 0x001F); // Pure red terrain
    @memset(mem.vram[0x8000 + 32 .. 0x8000 + 64], 0x11);

    var ppu = Ppu{};
    ppu.setViewport(320, 0, false); // pad_l = 40; sx=296 is mx=16, sx=312 is mx=17
    ppu.setWideScene(.{
        .ewram = ewram.ptr,
        .iwram = iwram.ptr,
        .rom = rom.ptr,
        .rom_len = rom.len,
        .map_width = 20,
        .map_height = 10,
        .view_wx = 0,
        .view_wy = 0,
        .show_reachability = true,
    });
    ppu.renderLine(mem.view(), 0);
    const wide = ppu.activeFrameSlice();

    // mx=16 (sx=296) is blended with yellow (0x03FF) over red -> green channel > 0; mx=17 (sx=312) stays pure red.
    try std.testing.expect(wide[296] != 0xFFFF0000);
    try std.testing.expectEqual(@as(u32, 0xFFFF0000), wide[312]);
}
