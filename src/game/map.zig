//! Lifted Advance Wars tilemap buffer, cursor position & display control helpers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const types = @import("types.zig");

/// Blank tile index (`0xBA << 1`) written into BG tilemap buffers (`0x0201_3340`).
pub const blank_tile_entry: u16 = 0x0174;

/// Compute byte offset inside a 32x32 halfword tilemap (`0x40` bytes/row) relative to `(cam_x, cam_y)`.
pub inline fn wrappedTilemapByteOffset(tile_x: u16, tile_y: u16, cam_x: u16, cam_y: u16) u32 {
    const local_x: u32 = (tile_x -% cam_x) & 0xF;
    const local_y: u32 = (tile_y -% cam_y) & 0xF;
    return (local_x << 2) +% (local_y << 7);
}

/// Clear a 2x2 meta-tile at `(r0, r1)` in BG tilemap buffer `0x0201_3340` relative to active camera (`0x0801FD98`).
pub fn func_0801FD98() callconv(.c) void {
    if (!abi.enter(0x0801FD98)) return;
    abi.fetches(38);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const cam_base = abi.read32(abi.read32(0x0801FDE0));
    const cam_x = abi.read16(cam_base +% 0xC);
    const cam_y = abi.read16(cam_base +% 0xE);
    const cell_off = wrappedTilemapByteOffset(@truncate(rt.r[0]), @truncate(rt.r[1]), cam_x, cam_y);
    const buf_base = abi.read32(0x0801FDE4);

    abi.write16(cell_off +% buf_base, blank_tile_entry);
    abi.write16(cell_off +% (buf_base +% 2), blank_tile_entry);
    abi.write16(cell_off +% (buf_base +% 0x40), blank_tile_entry);
    const last_dst = cell_off +% (buf_base +% 0x42);
    abi.write16(last_dst, blank_tile_entry);

    rt.r[1] = cell_off +% (buf_base +% 0x40);
    rt.r[2] = buf_base +% 0x42;
    rt.r[3] = blank_tile_entry;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;

    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.updateNz(blank_tile_entry);
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Write pixel cursor coordinates `(x, y)` to `0x0300_36A0` (`0x0802055C`).
pub fn func_0802055C() callconv(.c) void {
    if (!abi.enter(0x0802055C)) return;
    abi.fetches(6);
    const dst = abi.read32(0x08020564);
    abi.write16(dst, @truncate(rt.r[0]));
    abi.write16(dst +% 2, @truncate(rt.r[1]));
    rt.r[2] = dst;
    abi.retLr();
}

/// Sync pixel cursor (`0x0300_36A0`) = tile cursor (`0x0300_36A4`) * 16 (`0x08020568`).
pub fn func_08020568() callconv(.c) void {
    if (!abi.enter(0x08020568)) return;
    abi.fetches(11);
    const px_addr = abi.read32(0x0802057C);
    const tile_addr = abi.read32(0x08020580);
    const tx = abi.read16(tile_addr);
    abi.write16(px_addr, tx << 4);
    const ty = abi.read16(tile_addr +% 2);
    const py: u32 = @as(u32, ty) << 4;
    abi.write16(px_addr +% 2, @truncate(py));
    rt.r[3] = tx;
    rt.r[2] = px_addr;
    rt.r[1] = ty;
    abi.setRegNz(&rt.r[0], py);
    abi.retLr();
}

/// Store `[r0 + 0x2F]` byte into `[*(0x0828_C05C) + 0x0A]` (`0x08033108`).
pub fn func_08033108() callconv(.c) void {
    if (!abi.enter(0x08033108)) return;
    abi.fetches(8);
    const target = abi.read32(abi.read32(0x08033114));
    const val = abi.read8(rt.r[0] +% 0x2F);
    abi.write16(target +% 0xA, val);
    rt.r[1] = target;
    rt.r[0] = val;
    abi.retLr();
}

/// Configure battle/map display control flags and blend parameters (`0x08033E28`).
pub fn func_08033E28() callconv(.c) void {
    if (!abi.enter(0x08033E28)) return;
    abi.fetches(57);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[8]);

    const dispcnt_hi_addr = abi.read32(0x08033E98);
    abi.write8(dispcnt_hi_addr +% 1, abi.read8(dispcnt_hi_addr +% 1) | 0x20);
    abi.write8(abi.read32(0x08033E9C), 0x5E);
    abi.write8(abi.read32(0x08033EA0), 0xDC);
    abi.write8(abi.read32(0x08033EA4), 0x20);
    abi.write8(abi.read32(0x08033EA8), 0x80);

    const bldcnt_lo_addr = abi.read32(0x08033EAC);
    const bld_lo: u32 = (abi.read8(bldcnt_lo_addr) | 0x1F) & @as(u32, @bitCast(-@as(i32, 0x21)));
    abi.write8(bldcnt_lo_addr, @truncate(bld_lo));

    const bldcnt_hi_addr = abi.read32(0x08033EB0);
    const bld_hi: u32 = (((0x01 | abi.read8(bldcnt_hi_addr)) & @as(u32, @bitCast(-@as(i32, 3)))) | 0x3C);
    abi.write8(bldcnt_hi_addr, @truncate(bld_hi));

    rt.r[8] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;

    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[1] = bld_hi;
    rt.r[2] = bldcnt_hi_addr;
    rt.r[3] = 0x10;
    rt.updateNz(bld_hi);
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Apply `(dx, dy)` deltas from `[r0 + 0x1E]` and `[r0 + 0x20]` to scroll globals `0x0300_1D48` / `0x0300_0DBC` (`0x0803B73C`).
pub fn func_0803B73C() callconv(.c) void {
    if (!abi.enter(0x0803B73C)) return;
    abi.fetches(13);
    const scroll_x_addr = abi.read32(0x0803B754);
    const cur_x = abi.read16(scroll_x_addr);
    const dx = abi.read16(rt.r[0] +% 0x1E);
    abi.write16(scroll_x_addr, cur_x +% dx);

    const scroll_y_addr = abi.read32(0x0803B758);
    const cur_y = abi.read16(scroll_y_addr);
    const dy = abi.read16(rt.r[0] +% 0x20);
    const next_y: u32 = @as(u32, cur_y) +% dy;
    abi.write16(scroll_y_addr, @truncate(next_y));

    rt.r[3] = dx;
    rt.r[2] = scroll_y_addr;
    rt.r[1] = next_y;
    rt.r[0] = dy;
    abi.retLr();
}

/// Sync pixel cursor (`0x0300_36A0`) from object `obj.0x24`, `(obj.0x22 << 4) + obj.0x26` (`0x080191E8`).
pub fn func_080191E8() callconv(.c) void {
    if (!abi.enter(0x080191E8)) return;
    abi.fetches(15);
    abi.pushLr();
    const obj = rt.r[0];
    const x: u32 = @bitCast(abi.signExtend16(abi.read16(obj +% 0x24)));
    const y_base: i32 = abi.signExtend16(abi.read16(obj +% 0x22)) << 4;
    const y_off: i32 = abi.read16(obj +% 0x26);
    const y_val: u32 = @bitCast(@as(i32, @as(i16, @truncate(y_base +% y_off))));
    rt.r[3] = 0x22;
    rt.r[2] = x;
    abi.setRegNz(&rt.r[1], y_val);
    rt.r[0] = x;
    if (!abi.call(func_0802055C, 0x08019203)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Upload map tiles (`0x080A_4698 -> 0x0600_2E00`, `0x80` words) and clear `obj.0x20` (`0x080202A0`).
pub fn func_080202A0() callconv(.c) void {
    if (!abi.enter(0x080202A0)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[4] = rt.r[0];
    rt.r[0] = abi.read32(0x080202B8);
    rt.r[1] = abi.read32(0x080202BC);
    abi.setRegNz(&rt.r[2], 0x80);
    if (!abi.call(decls.func_0800FFA8, 0x080202AF)) return;
    abi.fetches(7);
    abi.write16(rt.r[4] +% 0x20, 0);
    abi.setRegNz(&rt.r[0], 0);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Load palette from `0x080A_22F8[( *(0x0300_4358) >> 1 & 7 ) * 2]` to slot `0x210` (`0x10` bytes) (`0x08020510`).
pub fn func_08020510() callconv(.c) void {
    if (!abi.enter(0x08020510)) return;
    abi.fetches(16);
    abi.pushLr();
    const state_word = abi.read32(abi.read32(0x08020530));
    const idx = (state_word >> 1) & 7;
    const pal_base = abi.read32(0x08020534);
    rt.r[0] = (idx << 1) +% pal_base;
    rt.r[1] = 0x210;
    abi.setRegNz(&rt.r[2], 0x10);
    if (!abi.call(decls.func_08011398, 0x0802052D)) return;
    abi.fetches(4);
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_080191E8, .{ .name = "func_080191E8", .linkage = .strong });
        @export(&func_0801FD98, .{ .name = "func_0801FD98", .linkage = .strong });
        @export(&func_080202A0, .{ .name = "func_080202A0", .linkage = .strong });
        @export(&func_08020510, .{ .name = "func_08020510", .linkage = .strong });
        @export(&func_0802055C, .{ .name = "func_0802055C", .linkage = .strong });
        @export(&func_08020568, .{ .name = "func_08020568", .linkage = .strong });
        @export(&func_08033108, .{ .name = "func_08033108", .linkage = .strong });
        @export(&func_08033E28, .{ .name = "func_08033E28", .linkage = .strong });
        @export(&func_0803B73C, .{ .name = "func_0803B73C", .linkage = .strong });
    }
}

test "wrapped 2x2 tilemap offset wraps inside 16x16 meta-grid" {
    try std.testing.expectEqual(@as(u32, 0), wrappedTilemapByteOffset(4, 5, 4, 5));
    try std.testing.expectEqual(@as(u32, (2 << 2) + (3 << 7)), wrappedTilemapByteOffset(6, 8, 4, 5));
    try std.testing.expectEqual(@as(u32, (15 << 2)), wrappedTilemapByteOffset(3, 5, 4, 5));
}
