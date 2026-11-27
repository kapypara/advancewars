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
    }
}

test "wrapped 2x2 tilemap offset wraps inside 16x16 meta-grid" {
    try std.testing.expectEqual(@as(u32, 0), wrappedTilemapByteOffset(4, 5, 4, 5));
    try std.testing.expectEqual(@as(u32, (2 << 2) + (3 << 7)), wrappedTilemapByteOffset(6, 8, 4, 5));
    try std.testing.expectEqual(@as(u32, (15 << 2)), wrappedTilemapByteOffset(3, 5, 4, 5));
}
