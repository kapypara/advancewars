//! Lifted Advance Wars tilemap buffer, cursor position & display control helpers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const mem = @import("mem.zig");
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

    const cam = mem.readCameraState();
    const cell_off = wrappedTilemapByteOffset(@truncate(rt.r[0]), @truncate(rt.r[1]), cam.cam_x, cam.cam_y);
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
    mem.writeCursorPx(@truncate(rt.r[0]), @truncate(rt.r[1]));
    rt.r[2] = types.addr.cursor_x_px;
    abi.retLr();
}

/// Sync pixel cursor (`0x0300_36A0`) = tile cursor (`0x0300_36A4`) * 16 (`0x08020568`).
pub fn func_08020568() callconv(.c) void {
    if (!abi.enter(0x08020568)) return;
    abi.fetches(11);
    const tile = mem.readCursorTile();
    const py: u32 = @as(u32, tile.y) << 4;
    mem.writeCursorPx(tile.x << 4, @truncate(py));
    rt.r[3] = tile.x;
    rt.r[2] = types.addr.cursor_x_px;
    rt.r[1] = tile.y;
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

fn clearMapRegion0FBEC(comptime pool_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(pool_ref);
    if (!abi.call(decls.func_0800FBEC, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear map overlay region `0x0802C64C` via `0x0800FBEC` (`0x0802C640`).
pub fn func_0802C640() callconv(.c) void {
    if (!abi.enter(0x0802C640)) return;
    clearMapRegion0FBEC(0x0802C64C, 0x0802C649);
}

/// Clear map overlay region `0x0802C65C` via `0x0800FBEC` (`0x0802C650`).
pub fn func_0802C650() callconv(.c) void {
    if (!abi.enter(0x0802C650)) return;
    clearMapRegion0FBEC(0x0802C65C, 0x0802C659);
}

/// Spawn `0x080380AC` map/FX proc via `0x080131E0` (`0x0803809C`).
pub fn func_0803809C() callconv(.c) void {
    if (!abi.enter(0x0803809C)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x080380AC);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, 0x080380A7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear `32`-byte row `u16(r0)` of map/palette staging via `0x0800FE24` (`0x08038C70`).
pub fn func_08038C70() callconv(.c) void {
    if (!abi.enter(0x08038C70)) return;
    abi.fetches(11);
    abi.pushLr();
    const row_off = (rt.r[0] & 0xFFFF) << 5;
    rt.r[0] = abi.read32(0x08038C88);
    rt.r[1] = row_off +% abi.read32(0x08038C8C);
    if (!abi.call(decls.func_0800FE24, 0x08038C83)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Map lookup index `u8(r0)` through `0x08038FB0` table and forward to `0x08038E10` (`0x08038F9C`).
pub fn func_08038F9C() callconv(.c) void {
    if (!abi.enter(0x08038F9C)) return;
    abi.fetches(10);
    abi.pushLr();
    const table = abi.read32(0x08038FB0);
    rt.r[0] = abi.read8((rt.r[0] & 0xFF) +% table);
    if (!abi.call(decls.func_08038E10, 0x08038FAD)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn `0x08039018` proc storing `r0` pointer at `proc->+0x18` (`0x08039004`).
pub fn func_08039004() callconv(.c) void {
    if (!abi.enter(0x08039004)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[0] = abi.read32(0x08039018);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08039011)) return;

    abi.fetches(6);
    abi.write32(rt.r[0] +% 0x18, rt.r[4]);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// End `0x08039028` map overlay proc (`0x0803901C`).
pub fn func_0803901C() callconv(.c) void {
    if (!abi.enter(0x0803901C)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08039028);
    if (!abi.call(decls.func_0801329C, 0x08039025)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear/reset tilemap buffer `0x08039190` via `0x0800FC9C` (`0x08039184`).
pub fn func_08039184() callconv(.c) void {
    if (!abi.enter(0x08039184)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08039190);
    if (!abi.call(decls.func_0800FC9C, 0x0803918D)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Upload 2-byte scroll/cursor icon into BG VRAM slot via `0x08011398` (`0x08039194`).
pub fn func_08039194() callconv(.c) void {
    if (!abi.enter(0x08039194)) return;
    abi.fetches(19);
    abi.pushLr();
    const src_off = (abi.read32(abi.read32(0x080391BC)) & 0x3C) >> 1;
    rt.r[0] = src_off +% abi.read32(0x080391C0);
    rt.r[1] = ((abi.read32(abi.read32(0x080391C4)) << 5) +% 0x1C) & 0xFFFF;
    abi.setRegNz(&rt.r[2], 2);
    if (!abi.call(decls.func_08011398, 0x080391B7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Store map cursor `(r0+0x20, r0+0x22)` into `(0x0803B3C4, 0x0803B3C8)` and enqueue `0x08015824` (`0x0803B3A8`).
pub fn func_0803B3A8() callconv(.c) void {
    if (!abi.enter(0x0803B3A8)) return;
    abi.fetches(13);
    abi.pushLr();
    abi.write16(abi.read32(0x0803B3C4), abi.read16(rt.r[0] +% 0x20));
    abi.write16(abi.read32(0x0803B3C8), abi.read16(rt.r[0] +% 0x22));
    rt.r[0] = abi.read32(0x0803B3CC);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_08015824, 0x0803B3BF)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn popReturnR1Map() void {
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Prepare tile/window `0x08019A0C` and apply `0x08019424` with 4 `u16` args (`0x080193E4`).
pub fn func_080193E4() callconv(.c) void {
    if (!abi.enter(0x080193E4)) return;
    abi.fetches(21);
    abi.pushLr();
    const saved_r8 = rt.r[8];
    const saved_r4 = rt.r[4];
    const saved_r5 = rt.r[5];
    const saved_r6 = rt.r[6];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const a0 = rt.r[0];
    const a1 = rt.r[1] & 0xFFFF;
    const a2 = rt.r[2] & 0xFFFF;
    const a3 = rt.r[3] & 0xFFFF;
    const a4 = abi.read32(rt.r[13] +% 0x1C) & 0xFFFF;
    rt.r[8] = a0;
    rt.r[5] = a1;
    rt.r[6] = a2;
    rt.r[3] = a3;
    rt.r[4] = a4;
    rt.updateNz(a4);
    abi.write32(rt.r[13] +% 4, a3);
    if (!abi.call(decls.func_08019A0C, 0x0801940B)) return;

    abi.fetches(9);
    abi.write32(rt.r[13], a4);
    rt.r[0] = a0;
    rt.r[1] = a1;
    rt.r[2] = a2;
    rt.r[3] = abi.read32(rt.r[13] +% 4);
    if (!abi.call(decls.func_08019424, 0x08019419)) return;

    abi.fetches(8);
    rt.r[13] +%= 8;
    const r8_pop = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = r8_pop;
    rt.r[3] = r8_pop;
    rt.r[4] = saved_r4;
    rt.r[5] = saved_r5;
    rt.r[6] = saved_r6;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnR1Map();
}

/// Prepare tile/window `0x08019A0C` and forward to `func_080193E4(..., 0)` (`0x080195AC`).
pub fn func_080195AC() callconv(.c) void {
    if (!abi.enter(0x080195AC)) return;
    abi.fetches(18);
    abi.pushLr();
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 4;

    const a0 = rt.r[0];
    const a1 = rt.r[1] & 0xFFFF;
    const a2 = rt.r[2] & 0xFFFF;
    const a3 = rt.r[3] & 0xFFFF;
    rt.r[8] = a0;
    rt.r[4] = a1;
    rt.r[5] = a2;
    rt.r[6] = a3;
    rt.updateNz(a3);
    if (!abi.call(decls.func_08019A0C, 0x080195CD)) return;

    abi.fetches(10);
    abi.write32(rt.r[13], 0);
    rt.r[0] = a0;
    rt.r[1] = a1;
    rt.r[2] = a2;
    rt.r[3] = a3;
    if (!abi.call(func_080193E4, 0x080195DD)) return;

    abi.fetches(8);
    rt.r[13] +%= 4;
    const r8_pop = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = r8_pop;
    rt.r[3] = r8_pop;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnR1Map();
}

fn uploadBgCharSlotFromDispcnt(comptime src_ref: u32, comptime ctrl_ref: u32, comptime base_ref: u32, comptime ret_addr: u32) bool {
    const ctrl_val = abi.read32(abi.read32(ctrl_ref));
    const char_bank = ((ctrl_val << 28) >> 30) << 14;
    const dst = char_bank +% abi.read32(base_ref);
    rt.r[0] = abi.read32(src_ref);
    rt.r[1] = dst;
    rt.r[2] = abi.read32(base_ref);
    return abi.call(decls.func_0800FE24, ret_addr);
}

/// Decompress map tileset `[0x080199C8]` into active BG char bank and apply `0x0801990C(u16(r0))` (`0x080199A0`).
pub fn func_080199A0() callconv(.c) void {
    if (!abi.enter(0x080199A0)) return;
    abi.fetches(16);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[4] = rt.r[0] & 0xFFFF;
    rt.updateNz(rt.r[4]);
    if (!uploadBgCharSlotFromDispcnt(0x080199C8, 0x080199CC, 0x080199D0, 0x080199BD)) return;

    abi.fetches(5);
    rt.r[0] = rt.r[4];
    if (!abi.call(decls.func_0801990C, 0x080199C3)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Decompress map tileset `[0x080199F8]` and DMA `0x20`-byte palette (`[0x08019A04] -> [0x08019A08]`) (`0x080199D4`).
pub fn func_080199D4() callconv(.c) void {
    if (!abi.enter(0x080199D4)) return;
    abi.fetches(13);
    abi.pushLr();
    if (!uploadBgCharSlotFromDispcnt(0x080199F8, 0x080199FC, 0x08019A00, 0x080199EB)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x08019A04);
    rt.r[1] = abi.read32(0x08019A08);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_0800FFA8, 0x080199F5)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Forward packed map tilemap write `(base + x*2 + y*64)` to `0x0801FB14` with fixed flags (`0x0801FD54`).
pub fn func_0801FD54() callconv(.c) void {
    if (!abi.enter(0x0801FD54)) return;
    abi.fetches(32);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 0x10;

    const x_off = (rt.r[1] << 16) >> 15;
    const y_off = (rt.r[2] << 16) >> 10;
    const a1 = rt.r[3] & 0xFF;
    const a2 = abi.read32(rt.r[13] +% 0x20) & 0xFFFF;
    const a3 = abi.read32(rt.r[13] +% 0x24) & 0xFF;
    const stack_flag = abi.read32(rt.r[13] +% 0x28) & 0xFF;

    abi.write32(rt.r[13], stack_flag);
    abi.write32(rt.r[13] +% 4, 0);
    abi.write32(rt.r[13] +% 8, 0);
    abi.write32(rt.r[13] +% 0xC, 1);
    rt.r[0] = rt.r[0] +% x_off +% y_off;
    rt.r[1] = a1;
    rt.r[2] = a2;
    rt.r[3] = a3;
    rt.r[4] = stack_flag;
    rt.r[5] = a1;
    rt.r[6] = a2;
    if (!abi.call(decls.func_0801FB14, 0x0801FD91)) return;

    abi.fetches(6);
    rt.r[13] +%= 0x10;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Write a 2x2 BG tilemap block (`[0x08020008]`) at wrapped viewport tile `(r0, r1)` (`0x0801FFB8`).
pub fn func_0801FFB8() callconv(.c) void {
    if (!abi.enter(0x0801FFB8)) return;
    abi.fetches(41);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const cam = abi.read32(abi.read32(0x08020000));
    const cam_x = abi.read16(cam +% 0xC);
    const cam_y = abi.read16(cam +% 0xE);
    const base = abi.read32(0x08020004);
    const val: u16 = @truncate(abi.read32(0x08020008));

    const off = wrappedTilemapByteOffset(@truncate(rt.r[0]), @truncate(rt.r[1]), cam_x, cam_y);
    abi.write16(base +% off, val);
    abi.write16(base +% off +% 2, val);
    abi.write16(base +% off +% 0x40, val);
    abi.write16(base +% off +% 0x42, val);

    rt.r[0] = base +% off +% 0x42;
    rt.r[1] = base +% off +% 0x40;
    rt.r[2] = base +% 0x42;
    rt.r[3] = val;
    rt.r[4] = abi.read32(0x08020008);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn configMapWindowBlendRegs(
    comptime disp_ref: u32,
    comptime reg_a: u32,
    comptime reg_b: u32,
    comptime reg_c: u32,
    comptime reg_d: u32,
    comptime bg_a: u32,
    comptime bg_b: u32,
    bg0_prio: u8,
    bg1_prio: u8,
    bg2_prio: u8,
    t1_mask: u8,
    t2_mask: u8,
    val_a: u16,
    val_b: u16,
    save_r5: bool,
    mid_fetches: u32,
    comptime ret1: u32,
    comptime ret2: u32,
) void {
    abi.fetches(30);
    abi.pushLr();
    rt.r[13] -%= 4;
    if (save_r5) {
        abi.write32(rt.r[13], rt.r[5]);
        rt.r[13] -%= 4;
    }
    abi.write32(rt.r[13], rt.r[4]);

    const mask_fc: u8 = 0xFC;
    const p0 = abi.read32(disp_ref);
    abi.write8(p0, (abi.read8(p0) & mask_fc) | bg0_prio);
    const p1 = abi.read32(reg_a);
    abi.write8(p1, (abi.read8(p1) & mask_fc) | bg1_prio);
    const p2 = abi.read32(reg_b);
    abi.write8(p2, (abi.read8(p2) & mask_fc) | bg2_prio);
    const p3 = abi.read32(reg_c);
    abi.write8(p3, abi.read8(p3) | 3);
    if (!abi.call(decls.func_080104B0, ret1)) return;

    abi.fetches(mid_fetches);
    const ctrl = abi.read32(reg_d);
    abi.write8(ctrl, (abi.read8(ctrl) & 0x3F) | 0x40 | t1_mask);
    abi.write8(ctrl +% 1, abi.read8(ctrl +% 1) | t2_mask);
    abi.write16(abi.read32(bg_a), val_a);
    abi.write16(abi.read32(bg_b), val_b);
    if (!abi.call(decls.func_080104D4, ret2)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    if (save_r5) {
        rt.r[5] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
    }
    abi.popReturn();
}

/// Enable WIN0 `(r0, r1, r2, r3)` region `[0x08018E90..0x08018E9C]` and set blend weights `(0x3F, 0x1F)` (`0x08018E4C`).
pub fn func_08018E4C() callconv(.c) void {
    if (!abi.enter(0x08018E4C)) return;
    abi.fetches(35);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const d = abi.read32(0x08018E90);
    abi.write8(d +% 1, abi.read8(d +% 1) | 0x20);
    const x0 = abi.signExtend16(@truncate(rt.r[0]));
    const y0 = abi.signExtend16(@truncate(rt.r[1]));
    const w = abi.signExtend16(@truncate(rt.r[2]));
    const h = abi.signExtend16(@truncate(rt.r[3]));
    const wh: u16 = @truncate((@as(u32, @bitCast(x0)) << 8) | (@as(u32, @bitCast(x0 +% w))));
    const wv: u16 = @truncate((@as(u32, @bitCast(y0)) << 8) | (@as(u32, @bitCast(y0 +% h))));
    abi.write16(abi.read32(0x08018E94), wh);
    abi.write16(abi.read32(0x08018E98), wv);
    const win_in = abi.read32(0x08018E9C);
    abi.write16(win_in, 0x3F);
    abi.write16(win_in +% 2, 0x1F);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear HUD cursor `0x08020568`/`0x08019058`, DMA `0x400`-byte tiles, and dispatch `0x080132D8(r0+0x44)` (`0x08019168`).
pub fn func_08019168() callconv(.c) void {
    if (!abi.enter(0x08019168)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const st = rt.r[0];
    rt.r[4] = st;
    if (!abi.call(func_08020568, 0x08019171)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08019058, 0x08019175)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x0801918C);
    rt.r[1] = abi.read32(0x08019190);
    abi.setRegNz(&rt.r[2], @as(u32, 0x80) << 4);
    if (!abi.call(decls.func_0800FFA8, 0x08019181)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(st +% 0x44);
    if (!abi.call(decls.func_080132D8, 0x08019187)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Reset panel `func_08019168`, clear window `(0, 1, 6, 0xC)`, reset units/cursor, and release turn lock `0x08035230` (`0x080191C4`).
pub fn func_080191C4() callconv(.c) void {
    if (!abi.enter(0x080191C4)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_08019168, 0x080191CB)) return;

    abi.fetches(8);
    abi.setRegNz(&rt.r[0], 0);
    abi.setRegNz(&rt.r[1], 1);
    abi.setRegNz(&rt.r[2], 6);
    abi.setRegNz(&rt.r[3], 0xC);
    if (!abi.call(decls.func_080198FC, 0x080191D7)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_0801FF70, 0x080191DB)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08020190, 0x080191DF)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08035230, 0x080191E3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Reset map display state `[0x0801F0B0..0x0801F0E0]` around `0x0802BF70`, `0x08035240`, `0x08016F0C`, `0x080244FC` (`0x0801F058`).
pub fn func_0801F058() callconv(.c) void {
    if (!abi.enter(0x0801F058)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[6] = 0;
    rt.r[4] = 0;
    const p0 = abi.read32(0x0801F0B0);
    abi.write16(p0, 0);
    abi.write16(p0 +% 2, 0);
    const p1 = abi.read32(0x0801F0B4);
    abi.write16(p1, 0);
    abi.write16(p1 +% 2, 0);
    if (!abi.call(decls.func_0802BF70, 0x0801F06F)) return;

    abi.fetches(8);
    abi.write32(abi.read32(0x0801F0B8), 0);
    abi.write32(abi.read32(0x0801F0BC), 0);
    if (!abi.call(decls.func_08035240, 0x0801F07B)) return;

    abi.fetches(18);
    abi.write16(abi.read32(0x0801F0C0), 0);
    abi.write16(abi.read32(0x0801F0C4), 0);
    abi.write16(abi.read32(0x0801F0C8), 0);
    abi.write32(abi.read32(0x0801F0CC), 1);
    abi.write16(abi.read32(0x0801F0D0), 0xB);
    abi.write16(abi.read32(0x0801F0D4), 0);
    rt.r[5] = 1;
    if (!abi.call(decls.func_08016F0C, 0x0801F09B)) return;

    abi.fetches(10);
    abi.write16(abi.read32(0x0801F0D8), 0);
    abi.write16(abi.read32(0x0801F0DC), 1);
    abi.write8(abi.read32(0x0801F0E0), 0);
    if (!abi.call(decls.func_080244FC, 0x0801F0AB)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down movement/range overlays (`0x08025080`, `0x08024EE8`, `0x08024D58`, `0x080356EC`) (`0x0801F0E4`).
pub fn func_0801F0E4() callconv(.c) void {
    if (!abi.enter(0x0801F0E4)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08025080, 0x0801F0EB)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08024EE8, 0x0801F0EF)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08024D58, 0x0801F0F3)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080356EC, 0x0801F0F7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Sync field sprites/camera (`0x0801F4B8`, `0x080251BC`, `0x080689A8`, `0x08068A64`) (`0x0801F0FC`).
pub fn func_0801F0FC() callconv(.c) void {
    if (!abi.enter(0x0801F0FC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0801F4B8, 0x0801F103)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080251BC, 0x0801F107)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080689A8, 0x0801F10B)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08068A64, 0x0801F10F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear map overlays (`0x08011910`, `0x08011804`, `0x08020190`, `0x080220F8`), zero `[0x0802040C]`, focus `[0x08020410]` (`0x080203E8`).
pub fn func_080203E8() callconv(.c) void {
    if (!abi.enter(0x080203E8)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08011910, 0x080203EF)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011804, 0x080203F3)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08020190, 0x080203F7)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080220F8, 0x080203FB)) return;

    abi.fetches(8);
    abi.write8(abi.read32(0x0802040C), 0);
    rt.r[0] = abi.read32(0x08020410);
    if (!abi.call(decls.func_0801329C, 0x08020407)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Load cursor/map marker graphics and palettes (`[0x080204F0..0x0802050C]`) (`0x080204B4`).
pub fn func_080204B4() callconv(.c) void {
    if (!abi.enter(0x080204B4)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x080204F0);
    rt.r[1] = abi.read32(0x080204F4);
    if (!abi.call(decls.func_0800FE24, 0x080204BF)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x080204F8);
    abi.setRegNz(&rt.r[1], @as(u32, 0x88) << 2);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, 0x080204CB)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x080204FC);
    rt.r[1] = abi.read32(0x08020500);
    if (!abi.call(decls.func_0800FE24, 0x080204D3)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08020504);
    abi.setRegNz(&rt.r[1], @as(u32, 0x80) << 2);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, 0x080204DF)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08020508);
    rt.r[1] = abi.read32(0x0802050C);
    abi.setRegNz(&rt.r[2], @as(u32, 0xA0) << 2);
    if (!abi.call(decls.func_0800FDA4, 0x080204EB)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Convert active cursor `[0x08020D64]` via `0x08020C0C` and pan camera `0x08020B48` with speed `i16(r0)` (`0x08020D14`).
pub fn func_08020D14() callconv(.c) void {
    if (!abi.enter(0x08020D14)) return;
    abi.fetches(21);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const speed: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    const cur = abi.read32(0x08020D64);
    const py_ptr = rt.r[13] +% 6;
    const px_ptr = rt.r[13] +% 4;
    rt.r[4] = speed;
    rt.r[5] = py_ptr;
    abi.write32(rt.r[13], py_ptr);
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(@as(u32, abi.read16(cur)) << 4)));
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(@as(u32, abi.read16(cur +% 2)) << 4)));
    rt.r[2] = speed;
    rt.r[3] = px_ptr;
    if (!abi.call(decls.func_08020C0C, 0x08020D3B)) return;

    abi.fetches(18);
    const cam = abi.read32(abi.read32(0x08020D68));
    const sx = abi.read16(px_ptr);
    const cx = abi.read16(cam +% 4);
    const sy = abi.read16(py_ptr);
    const cy = abi.read16(cam +% 6);
    rt.r[5] = sy;
    rt.r[0] = @bitCast(abi.signExtend16(sx -% cx));
    rt.r[1] = @bitCast(abi.signExtend16(sy -% cy));
    rt.r[2] = speed;
    if (!abi.call(decls.func_08020B48, 0x08020D5B)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Update tile ownership bits at `(i16 r0, i16 r1)` from `[0x08021B34]` and refresh map layers (`0x08021ADC`).
pub fn func_08021ADC() callconv(.c) void {
    if (!abi.enter(0x08021ADC)) return;
    abi.fetches(31);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const tx = abi.signExtend16(@truncate(rt.r[0]));
    const ty = abi.signExtend16(@truncate(rt.r[1]));
    const map_base = abi.read32(abi.read32(0x08021B28));
    const row_off = abi.read16(map_base +% abi.read32(0x08021B2C) +% @as(u32, @bitCast(ty << 1)));
    const tile_addr = map_base +% abi.read32(0x08021B30) +% @as(u32, @bitCast(@as(i32, row_off) +% tx));
    const old_val = abi.read8(tile_addr) & 0x1F;
    const owner = abi.read8(abi.read32(0x08021B34));
    const new_val: u8 = @truncate(owner +% old_val);
    abi.write8(tile_addr, new_val);
    rt.r[4] = tile_addr;
    rt.r[5] = abi.read8(tile_addr);
    rt.r[0] = @bitCast(tx);
    rt.r[1] = @bitCast(ty);
    abi.setRegNz(&rt.r[2], @as(u32, new_val) & 0xE0);
    if (!abi.call(decls.func_08021B38, 0x08021B17)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08021DF8, 0x08021B1B)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0801F4B8, 0x08021B1F)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080251BC, 0x08021B23)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Configure map PPU BG/blend registers for tactical mode 1 (`0x08021EEC`).
pub fn func_08021EEC() callconv(.c) void {
    if (!abi.enter(0x08021EEC)) return;
    configMapWindowBlendRegs(0x08021F5C, 0x08021F60, 0x08021F64, 0x08021F68, 0x08021F6C, 0x08021F70, 0x08021F74, 0, 2, 1, 0x01, 0x1E, 0, 0x10, true, 27, 0x08021F25, 0x08021F57);
}

/// Configure map PPU BG/blend registers for tactical mode 2 (`0x08022074`).
pub fn func_08022074() callconv(.c) void {
    if (!abi.enter(0x08022074)) return;
    configMapWindowBlendRegs(0x080220DC, 0x080220E0, 0x080220E4, 0x080220E8, 0x080220EC, 0x080220F0, 0x080220F4, 2, 1, 0, 0x01, 0x0C, 0x10, 0x10, false, 23, 0x080220AD, 0x080220D7);
}

/// Configure map PPU BG/blend registers for tactical mode 3 (`0x08022148`).
pub fn func_08022148() callconv(.c) void {
    if (!abi.enter(0x08022148)) return;
    configMapWindowBlendRegs(0x080221B4, 0x080221B8, 0x080221BC, 0x080221C0, 0x080221C4, 0x080221C8, 0x080221CC, 0, 2, 1, 0x02, 0x18, 6, 0x10, false, 24, 0x08022181, 0x080221AD);
}

fn drawMapLayerEntry(
    comptime arg4_ref: u32,
    comptime pal_ref: u32,
    comptime rows_ref: u32,
    comptime ret1: u32,
    comptime ret2: u32,
    comptime ret2_b: ?u32,
    comptime ret3: u32,
    comptime ret4: u32,
) void {
    abi.fetches(19);
    abi.pushLr();
    const saved_r9 = rt.r[9];
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);

    const p0 = rt.r[0];
    const bg_id = rt.r[1];
    const tx = rt.r[2];
    const ty = rt.r[3];
    const pal_bank = abi.read32(rt.r[13] +% 0x18);
    abi.write32(abi.read32(arg4_ref), pal_bank);
    rt.r[0] = abi.read32(pal_ref);
    abi.setRegNz(&rt.r[1], (pal_bank << 21) >> 16);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, ret1)) return;

    if (ret2_b) |r2b| {
        abi.fetches(5);
        rt.r[0] = p0;
        if (!abi.call(decls.func_0801B850, ret2)) return;
        abi.fetches(5);
        rt.r[0] = p0;
        if (!abi.call(decls.func_0801B860, r2b)) return;
    } else {
        abi.fetches(5);
        rt.r[0] = p0;
        if (!abi.call(decls.func_080391C8, ret2)) return;
    }

    abi.fetches(16);
    const row_base = abi.read32(abi.read32(rows_ref) +% (bg_id << 2));
    rt.r[0] = row_base +% (ty << 6) +% (tx << 1);
    abi.setRegNz(&rt.r[1], pal_bank << 12);
    if (!abi.call(decls.func_0803942C, ret3)) return;

    abi.fetches(7);
    abi.setRegNz(&rt.r[0], bg_id & 0xFF);
    if (!abi.call(decls.func_080117EC, ret4)) return;

    abi.fetches(8);
    rt.r[3] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[9] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = rt.r[3];
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Draw map layer entry via `0x080391C8` + `0x0803942C` (`0x08039080`).
pub fn func_08039080() callconv(.c) void {
    if (!abi.enter(0x08039080)) return;
    drawMapLayerEntry(0x080390DC, 0x080390E0, 0x080390E4, 0x080390A3, 0x080390A9, null, 0x080390C5, 0x080390CF);
}

/// Draw map layer entry via `0x0801B850`/`0x0801B860` + `0x0803942C` (`0x080390E8`).
pub fn func_080390E8() callconv(.c) void {
    if (!abi.enter(0x080390E8)) return;
    drawMapLayerEntry(0x08039148, 0x0803914C, 0x08039150, 0x0803910B, 0x08039111, 0x08039117, 0x08039133, 0x0803913D);
}

/// Apply map layer palette `0x08022640(u16(r0+0x1E))`, init map viewport/windows, and sync `0x080226A4` (`0x08039730`).
pub fn func_08039730() callconv(.c) void {
    if (!abi.enter(0x08039730)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read16(rt.r[0] +% 0x1E);
    if (!abi.call(decls.func_08022640, 0x08039739)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x0803977C);
    if (!abi.call(decls.func_080392A4, 0x0803973F)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_080395B4, 0x08039743)) return;

    abi.fetches(28);
    const cam = abi.read32(abi.read32(0x08039784));
    abi.write16(abi.read32(0x08039780), @truncate((@as(u32, abi.read16(cam)) << 1) -% 0xA8));
    abi.write16(abi.read32(0x08039788), @truncate((@as(u32, abi.read16(cam +% 2)) << 1) -% 0x60));
    abi.write8(abi.read32(0x0803978C), 0x5D);
    abi.write8(abi.read32(0x08039790), 0xF0);
    abi.write8(abi.read32(0x08039794), 0);
    abi.write8(abi.read32(0x08039798), 0xA0);
    if (!abi.call(decls.func_080226A4, 0x08039777)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Clear map overlay flags `[0x0803C954]`, switch to map view mode 2, and update cursor `0x080197D8` (`0x0803C91C`).
pub fn func_0803C91C() callconv(.c) void {
    if (!abi.enter(0x0803C91C)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const state_ref = abi.read32(0x0803C954);
    const state = abi.read32(state_ref);
    abi.write8(state +% 9, 0);
    abi.write8(state +% 0xA, 0xFF);
    abi.setRegNz(&rt.r[0], 2);
    if (!abi.call(func_08020D14, 0x0803C933)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x0803C958);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x0803C93B)) return;

    abi.fetches(9);
    const st = abi.read32(state_ref);
    rt.r[0] = abi.read8(st +% 2);
    rt.r[1] = abi.read8(st +% 3);
    abi.setRegNz(&rt.r[2], 0x10);
    abi.setRegNz(&rt.r[3], 0xA);
    if (!abi.call(decls.func_080197D8, 0x0803C949)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 2);
    if (!abi.call(decls.func_080117EC, 0x0803C94F)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn uploadFactionPalettes(
    state_ptr_pool: u32,
    pal_a_pool: u32,
    pal_b_pool: u32,
    pal_c_pool: u32,
    rets: [11]u32,
) bool {
    const state = abi.read32(abi.read32(state_ptr_pool));
    const pal_a = abi.read32(pal_a_pool);
    const a_srcs = [_]u32{ 0x82, 0xEA, 0x152, 0x1BA };
    const a_dsts = [_]u32{ 0x180, 0x1A0, 0x1C0, 0x1E0 };
    inline for (0..4) |i| {
        const idx = @as(u32, abi.read8(state +% a_srcs[i])) -% 1;
        rt.r[0] = (idx << 5) +% pal_a;
        rt.r[1] = a_dsts[i];
        rt.r[2] = 0x20;
        if (!abi.call(decls.func_08011330, rets[i])) return false;
        abi.fetches(if (i < 3) 14 else 12);
    }

    const pal_b = abi.read32(pal_b_pool);
    const b_srcs = [_]u32{ 0x1A, 0x82, 0xEA, 0x152, 0x1BA };
    inline for (0..5) |i| {
        const idx: u32 = abi.read8(state +% b_srcs[i]);
        rt.r[0] = (idx << 5) +% pal_b;
        rt.r[1] = 0x300 +% @as(u32, i * 0x20);
        rt.r[2] = 0x20;
        if (!abi.call(decls.func_08011330, rets[4 + i])) return false;
        abi.fetches(if (i < 4) 12 else 9);
    }

    rt.r[0] = pal_b +% 0xC0;
    rt.r[1] = 0x3A0;
    rt.r[2] = 0x20;
    if (!abi.call(decls.func_08011330, rets[9])) return false;

    if (rets[10] != 0) {
        abi.fetches(8);
        rt.r[0] = abi.read32(pal_c_pool);
        rt.r[1] = 0x140;
        rt.r[2] = 0x20;
        if (!abi.call(decls.func_08011330, rets[10])) return false;
    }
    return true;
}

fn refreshMapViewAndCursor(view_pool: u32, cursor_pool: u32, rets: [4]u32) bool {
    abi.fetches(7);
    rt.r[0] = abi.read8(abi.read32(view_pool) +% 0x2C);
    if (!abi.call(decls.func_08035274, rets[0])) return false;
    abi.fetches(4);
    if (!abi.call(func_080204B4, rets[1])) return false;
    abi.fetches(6);
    const cursor_ptr = abi.read32(cursor_pool);
    rt.r[4] = cursor_ptr;
    rt.r[0] = abi.read16(cursor_ptr);
    if (!abi.call(func_080199A0, rets[2])) return false;
    abi.fetches(5);
    rt.r[0] = abi.read16(rt.r[4]);
    if (!abi.call(decls.func_08019970, rets[3])) return false;
    return true;
}

/// Reset display state, upload all faction/UI palettes, and refresh map view & cursor (`0x0801CA34`).
pub fn func_0801CA34() callconv(.c) void {
    if (!abi.enter(0x0801CA34)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[8]);

    rt.r[0] = abi.read32(0x0801CB58);
    if (!abi.call(decls.func_0800FC74, 0x0801CA41)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x0801CB5C);
    if (!abi.call(decls.func_0800FC74, 0x0801CA47)) return;
    abi.fetches(15);

    if (!uploadFactionPalettes(0x0801CB60, 0x0801CB64, 0x0801CB68, 0x0801CB6C, .{
        0x0801CA61, 0x0801CA79, 0x0801CA93, 0x0801CAA9,
        0x0801CABD, 0x0801CAD1, 0x0801CAE5, 0x0801CAF9, 0x0801CB0D,
        0x0801CB1B, 0x0801CB27,
    })) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x0801CB70);
    rt.r[1] = 0x240;
    rt.r[2] = 0x20;
    if (!abi.call(decls.func_08011330, 0x0801CB33)) return;

    if (!refreshMapViewAndCursor(0x0801CB74, 0x0801CB78, .{
        0x0801CB3D, 0x0801CB41, 0x0801CB49, 0x0801CB4F,
    })) return;

    abi.fetches(7);
    rt.r[3] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = rt.r[3];
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn jittered particle effect around `(i16 r0, i16 r1)` using entry `u8 r2` (`0x08020414`).
pub fn func_08020414() callconv(.c) void {
    if (!abi.enter(0x08020414)) return;
    abi.fetches(27);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[9]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[8]);
    rt.r[13] -%= 0x10;

    const base_x = rt.r[0] & 0xFFFF;
    const base_y = rt.r[1] & 0xFFFF;
    const kind = rt.r[2] & 0xFF;
    abi.write32(rt.r[13] +% 0x8, 0);
    abi.write32(rt.r[13] +% 0xC, 0);
    rt.r[8] = abi.read32(0x080204A8);
    rt.r[0] = abi.read32(abi.read32(0x080204AC));
    rt.r[1] = 7;
    if (!abi.call(decls.func_0807B634, 0x08020447)) return;

    abi.fetches(43);
    const scale: u32 = abi.read8((rt.r[0] & 3) +% rt.r[8]);
    const entry = (kind << 3) +% abi.read32(0x080204B0);
    const dx: u32 = @bitCast(abi.signExtend8(abi.read8(entry +% 4)));
    const dy: u32 = @bitCast(abi.signExtend8(abi.read8(entry +% 5)));
    const attr_addr = rt.r[13] +% 0x8;
    abi.write8(attr_addr +% 5, @truncate((@as(u32, abi.read8(attr_addr +% 5)) & 0xF) | 0x10));

    const sx: u32 = @bitCast(abi.signExtend16(@truncate(base_x)));
    const sy: u32 = @bitCast(abi.signExtend16(@truncate(base_y)));
    const out_x = sx +% (scale *% dx);
    const out_y = sy +% (scale *% dy);
    const sprite_desc = abi.read32(entry);
    const attr0 = abi.read32(rt.r[13] +% 0x8);
    const attr1 = abi.read32(rt.r[13] +% 0xC);
    abi.write32(rt.r[13] +% 0x0, attr1);
    abi.write32(rt.r[13] +% 0x4, 0);
    rt.r[0] = out_x;
    rt.r[1] = out_y;
    rt.r[2] = sprite_desc;
    rt.r[3] = attr0;
    if (!abi.call(decls.func_080157E4, 0x08020499)) return;

    abi.fetches(9);
    rt.r[13] +%= 0x10;
    rt.r[3] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = rt.r[3];
    rt.r[9] = rt.r[4];
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Full battle-map graphics, tileset, UI, palette, and cursor initialization (`0x08020D6C`).
pub fn func_08020D6C() callconv(.c) void {
    if (!abi.enter(0x08020D6C)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[9]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[8]);

    if (!abi.call(decls.func_0800FC58, 0x08020D79)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0800F1B0, 0x08020D7D)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x08020F78);
    if (!abi.call(decls.func_08010D00, 0x08020D83)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080212F4, 0x08020D87)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08010974, 0x08020D8B)) return;

    abi.fetches(7);
    const vram_base = abi.read32(0x08020F80);
    rt.r[0] = abi.read32(0x08020F7C);
    rt.r[1] = vram_base;
    if (!abi.call(decls.func_0800FE24, 0x08020D95)) return;

    abi.fetches(9);
    rt.r[0] = abi.read32(0x08020F84);
    rt.r[1] = vram_base +% 0x8000;
    if (!abi.call(decls.func_0800FE24, 0x08020DA3)) return;

    abi.fetches(5);
    rt.r[0] = 0;
    if (!abi.call(decls.func_08012830, 0x08020DA9)) return;

    abi.fetches(8);
    rt.r[4] = abi.read32(0x08020F88);
    rt.r[0] = rt.r[4];
    rt.r[1] = abi.read32(0x08020F8C);
    rt.r[2] = 0xA0;
    if (!abi.call(decls.func_0800FDA4, 0x08020DB5)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08020F90);
    rt.r[1] = abi.read32(0x08020F94);
    rt.r[2] = 0xC00;
    if (!abi.call(decls.func_0800FDA4, 0x08020DC1)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08020F98);
    rt.r[1] = abi.read32(0x08020F9C);
    rt.r[2] = 0x200;
    if (!abi.call(decls.func_0800FDA4, 0x08020DCD)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x08020FA0);
    rt.r[1] = abi.read32(0x08020FA4);
    if (!abi.call(decls.func_0800FE24, 0x08020DD5)) return;

    abi.fetches(9);
    rt.r[0] = abi.read32(0x08020FA8);
    rt.r[1] = abi.read32(0x08020FAC);
    rt.r[2] = 0x180;
    if (!abi.call(decls.func_0800FDA4, 0x08020DE3)) return;

    abi.fetches(8);
    rt.r[0] = rt.r[4] +% 0xA0;
    rt.r[1] = abi.read32(0x08020FB0);
    rt.r[2] = 0x20;
    if (!abi.call(decls.func_0800FDA4, 0x08020DEF)) return;

    const dma_0800: [3][3]u32 = .{
        .{ 0x08020FB4, 0x08020FB8, 0x08020DFD },
        .{ 0x08020FBC, 0x08020FC0, 0x08020E07 },
        .{ 0x08020FC4, 0x08020FC8, 0x08020E11 },
    };
    inline for (dma_0800, 0..) |d, i| {
        abi.fetches(if (i == 0) 9 else 7);
        rt.r[0] = abi.read32(d[0]);
        rt.r[1] = abi.read32(d[1]);
        rt.r[2] = 0x800;
        if (!abi.call(decls.func_0800FDA4, d[2])) return;
    }

    abi.fetches(14);
    if (!uploadFactionPalettes(0x08020FCC, 0x08020FD0, 0x08020FD4, 0x08020FD8, .{
        0x08020E29, 0x08020E3F, 0x08020E59, 0x08020E6F,
        0x08020E83, 0x08020E97, 0x08020EAB, 0x08020EBF, 0x08020ED3,
        0x08020EE1, 0,
    })) return;

    abi.fetches(4);
    if (!abi.call(decls.func_0802E488, 0x08020EE5)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(0x08020FD8);
    rt.r[1] = 0x140;
    rt.r[2] = 0x20;
    if (!abi.call(decls.func_08011330, 0x08020EF1)) return;

    const obj_dmas: [3][4]u32 = .{
        .{ 0x08020FDC, 0x08020FE0, 0x800, 0x08020EFB },
        .{ 0x08020FE4, 0x08020FE8, 0x160, 0x08020F07 },
        .{ 0x08020FEC, 0x08020FF0, 0x6C0, 0x08020F13 },
    };
    inline for (obj_dmas, 0..) |d, i| {
        abi.fetches(if (i == 0) 7 else 8);
        rt.r[0] = abi.read32(d[0]);
        rt.r[1] = abi.read32(d[1]);
        rt.r[2] = d[2];
        if (!abi.call(decls.func_0800FDA4, d[3])) return;
    }

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08020FF4);
    rt.r[1] = 0x240;
    rt.r[2] = 0x20;
    if (!abi.call(decls.func_08011330, 0x08020F1F)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08020FF8);
    rt.r[1] = 0x2A0;
    rt.r[2] = 0x20;
    if (!abi.call(decls.func_08011330, 0x08020F2B)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x08020FFC);
    if (!abi.call(func_08038C70, 0x08020F31)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08021DF8, 0x08020F35)) return;
    abi.fetches(4);
    if (!abi.call(func_080203E8, 0x08020F39)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x08021000);
    rt.r[1] = abi.read32(0x08021004);
    rt.r[2] = 0x800;
    if (!abi.call(decls.func_0800FDA4, 0x08020F43)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08036464, 0x08020F47)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0800F894, 0x08020F4B)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080357C8, 0x08020F4F)) return;

    if (!refreshMapViewAndCursor(0x08021008, 0x0802100C, .{
        0x08020F59, 0x08020F5D, 0x08020F65, 0x08020F6B,
    })) return;

    abi.fetches(8);
    rt.r[3] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = rt.r[3];
    rt.r[9] = rt.r[4];
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Reload faction/UI palettes and refresh map view & cursor (`0x080226B8`).
pub fn func_080226B8() callconv(.c) void {
    if (!abi.enter(0x080226B8)) return;
    abi.fetches(18);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[8]);

    if (!uploadFactionPalettes(0x080227D0, 0x080227D4, 0x080227D8, 0x080227DC, .{
        0x080226D9, 0x080226F1, 0x0802270B, 0x08022721,
        0x08022735, 0x08022749, 0x0802275D, 0x08022771, 0x08022785,
        0x08022793, 0x0802279F,
    })) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x080227E0);
    rt.r[1] = 0x240;
    rt.r[2] = 0x20;
    if (!abi.call(decls.func_08011330, 0x080227AB)) return;

    if (!refreshMapViewAndCursor(0x080227E4, 0x080227E8, .{
        0x080227B5, 0x080227B9, 0x080227C1, 0x080227C7,
    })) return;

    abi.fetches(7);
    rt.r[3] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = rt.r[3];
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Copy 3KB map graphics chunk (`slot * 0xC00`) to `*[0x0801F818]` from active layer bank (`0x0801F7EC`).
pub fn func_0801F7EC() callconv(.c) void {
    if (!abi.enter(0x0801F7EC)) return;
    abi.fetches(4);
    abi.pushLr();
    const slot = abi.arg(0) & 0xFF;
    abi.fetches(10);
    const dst = slot *% 0xC00 +% abi.read32(0x0801F818);
    const bank_bits = abi.read32(abi.read32(0x0801F81C));
    abi.fetches(4);
    const bank = (bank_bits << 28) >> 30;
    abi.fetches(10);
    const src = (bank << 14) +% abi.read32(0x0801F820);
    rt.r[0] = dst;
    rt.r[1] = src;
    rt.r[2] = 0xC00;
    rt.r[3] = dst;
    rt.updateNz(rt.r[2]);
    if (!abi.call(decls.func_0800FDA4, 0x0801F815)) return;
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
        @export(&func_0802C640, .{ .name = "func_0802C640", .linkage = .strong });
        @export(&func_0802C650, .{ .name = "func_0802C650", .linkage = .strong });
        @export(&func_08033108, .{ .name = "func_08033108", .linkage = .strong });
        @export(&func_08033E28, .{ .name = "func_08033E28", .linkage = .strong });
        @export(&func_0803809C, .{ .name = "func_0803809C", .linkage = .strong });
        @export(&func_08038C70, .{ .name = "func_08038C70", .linkage = .strong });
        @export(&func_08038F9C, .{ .name = "func_08038F9C", .linkage = .strong });
        @export(&func_08039004, .{ .name = "func_08039004", .linkage = .strong });
        @export(&func_0803901C, .{ .name = "func_0803901C", .linkage = .strong });
        @export(&func_08039184, .{ .name = "func_08039184", .linkage = .strong });
        @export(&func_08039194, .{ .name = "func_08039194", .linkage = .strong });
        @export(&func_0803B3A8, .{ .name = "func_0803B3A8", .linkage = .strong });
        @export(&func_0803B73C, .{ .name = "func_0803B73C", .linkage = .strong });
        @export(&func_080193E4, .{ .name = "func_080193E4", .linkage = .strong });
        @export(&func_080195AC, .{ .name = "func_080195AC", .linkage = .strong });
        @export(&func_080199A0, .{ .name = "func_080199A0", .linkage = .strong });
        @export(&func_080199D4, .{ .name = "func_080199D4", .linkage = .strong });
        @export(&func_0801FD54, .{ .name = "func_0801FD54", .linkage = .strong });
        @export(&func_0801FFB8, .{ .name = "func_0801FFB8", .linkage = .strong });
        @export(&func_08018E4C, .{ .name = "func_08018E4C", .linkage = .strong });
        @export(&func_08019168, .{ .name = "func_08019168", .linkage = .strong });
        @export(&func_080191C4, .{ .name = "func_080191C4", .linkage = .strong });
        @export(&func_0801F058, .{ .name = "func_0801F058", .linkage = .strong });
        @export(&func_0801F0E4, .{ .name = "func_0801F0E4", .linkage = .strong });
        @export(&func_0801F0FC, .{ .name = "func_0801F0FC", .linkage = .strong });
        @export(&func_080203E8, .{ .name = "func_080203E8", .linkage = .strong });
        @export(&func_080204B4, .{ .name = "func_080204B4", .linkage = .strong });
        @export(&func_08020D14, .{ .name = "func_08020D14", .linkage = .strong });
        @export(&func_08021ADC, .{ .name = "func_08021ADC", .linkage = .strong });
        @export(&func_08021EEC, .{ .name = "func_08021EEC", .linkage = .strong });
        @export(&func_08022074, .{ .name = "func_08022074", .linkage = .strong });
        @export(&func_08022148, .{ .name = "func_08022148", .linkage = .strong });
        @export(&func_08039080, .{ .name = "func_08039080", .linkage = .strong });
        @export(&func_080390E8, .{ .name = "func_080390E8", .linkage = .strong });
        @export(&func_08039730, .{ .name = "func_08039730", .linkage = .strong });
        @export(&func_0803C91C, .{ .name = "func_0803C91C", .linkage = .strong });
        @export(&func_0801CA34, .{ .name = "func_0801CA34", .linkage = .strong });
        @export(&func_08020414, .{ .name = "func_08020414", .linkage = .strong });
        @export(&func_08020D6C, .{ .name = "func_08020D6C", .linkage = .strong });
        @export(&func_080226B8, .{ .name = "func_080226B8", .linkage = .strong });
        @export(&func_0801F7EC, .{ .name = "func_0801F7EC", .linkage = .strong });
    }
}

test "wrapped 2x2 tilemap offset wraps inside 16x16 meta-grid" {
    try std.testing.expectEqual(@as(u32, 0), wrappedTilemapByteOffset(4, 5, 4, 5));
    try std.testing.expectEqual(@as(u32, (2 << 2) + (3 << 7)), wrappedTilemapByteOffset(6, 8, 4, 5));
    try std.testing.expectEqual(@as(u32, (15 << 2)), wrappedTilemapByteOffset(3, 5, 4, 5));
}
