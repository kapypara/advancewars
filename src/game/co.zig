//! Lifted Advance Wars Commanding Officer (CO) portraits, palette & data table getters (`0x0801BDDC..0x0801BEE4`).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");

/// Compute ROM address of large CO portrait tiles (`0x080C_931C + co_id * 0x100 + 0x540`).
pub inline fn coPortraitTilesAddr(co_id: u8) u32 {
    return 0x080C_931C +% (@as(u32, co_id) << 8) +% 0x540;
}

/// Compute ROM address of small CO portrait tiles (`0x080C_931C + co_id * 0x80 + 0x3720`).
pub inline fn coPortraitSmallTilesAddr(co_id: u8) u32 {
    return 0x080C_931C +% (@as(u32, co_id) << 7) +% 0x3720;
}

/// Reset active CO selection cursor `[0x0201_FD1D] = 0` after `0x0801BD84` (`0x0801BDDC`).
pub fn func_0801BDDC() callconv(.c) void {
    if (!abi.enter(0x0801BDDC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0801BD84, 0x0801BDE3)) return;
    abi.fetches(7);
    const dst = abi.read32(0x0801BDEC);
    abi.write8(dst, 0);
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], 0);
    abi.popReturn();
}

/// Return ROM pointer to active player's CO large portrait tiles (`0x0801BE10`).
pub fn func_0801BE10() callconv(.c) void {
    if (!abi.enter(0x0801BE10)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_0801BE04, 0x0801BE1B)) return;
    abi.fetches(10);
    const tbl = abi.read32(0x0801BE2C);
    const res = (rt.r[0] << 8) +% 0x540 +% tbl;
    abi.setRegNz(&rt.r[0], res);
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Return ROM pointer to active player's CO small portrait tiles (`0x0801BE30`).
pub fn func_0801BE30() callconv(.c) void {
    if (!abi.enter(0x0801BE30)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_0801BE04, 0x0801BE3B)) return;
    abi.fetches(9);
    const off = abi.read32(0x0801BE48);
    const tbl = abi.read32(0x0801BE4C);
    const res = (rt.r[0] << 7) +% off +% tbl;
    abi.setRegNz(&rt.r[0], res);
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Return ROM pointer to CO tag/overlay data (`0x080B_EDC8 + u8(co) * 0x200`) (`0x0801BEA0`).
pub fn func_0801BEA0() callconv(.c) void {
    if (!abi.enter(0x0801BEA0)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_0801BE04, 0x0801BEAB)) return;
    abi.fetches(8);
    const co_idx: u8 = @truncate(rt.r[0]);
    const tbl = abi.read32(0x0801BEB8);
    const res = (@as(u32, co_idx) << 9) +% tbl;
    abi.setRegNz(&rt.r[0], res);
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Read `u32` entry from CO subtable `0x0828_57D4[(co * 5 + u8(r1)) * 4]` (`0x0801BEBC`).
pub fn func_0801BEBC() callconv(.c) void {
    if (!abi.enter(0x0801BEBC)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const sub: u32 = @as(u8, @truncate(rt.r[1]));
    rt.r[0] &= 0xFF;
    rt.r[4] = sub;
    rt.updateNz(sub);
    if (!abi.call(decls.func_0801BE04, 0x0801BECD)) return;
    abi.fetches(12);
    const tbl = abi.read32(0x0801BEE0);
    const entry = ((rt.r[0] *% 5) +% sub) << 2;
    rt.r[2] = tbl;
    rt.r[1] = entry +% tbl;
    rt.updateNz(entry);
    rt.r[0] = abi.read32(rt.r[1]);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Return ROM pointer to CO unit palette (`0x080C_05C8 + u8(co) * 32`) (`0x0801BEE4`).
pub fn func_0801BEE4() callconv(.c) void {
    if (!abi.enter(0x0801BEE4)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_0801BE04, 0x0801BEEF)) return;
    abi.fetches(8);
    const co_idx: u8 = @truncate(rt.r[0]);
    const tbl = abi.read32(0x0801BEFC);
    const res = (@as(u32, co_idx) << 5) +% tbl;
    abi.setRegNz(&rt.r[0], res);
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

fn callCoPortrait1BF50(comptime pool_r1_ref: ?u32, comptime const_r1: u32, comptime ret_addr: u32) void {
    abi.fetches(if (const_r1 == @as(u32, @bitCast(@as(i32, -1)))) 9 else 8);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    if (pool_r1_ref) |ref| {
        rt.r[1] = abi.read32(ref);
    } else {
        rt.r[1] = const_r1;
    }
    if (!abi.call(decls.func_0801BF50, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Look up CO table field `+0x0C` (`u16`, stride `292`) for entity `u8(r0)` (`0x0801BE50`).
pub fn func_0801BE50() callconv(.c) void {
    if (!abi.enter(0x0801BE50)) return;
    abi.fetches(14);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = abi.read32(0x0801BE80);
    const entities = abi.read32(abi.read32(0x0801BE84));
    rt.r[0] = abi.read8(entities +% ((rt.r[0] & 0xFF) *% 0x68) +% 0x1D);
    if (!abi.call(decls.func_0801BE04, 0x0801BE69)) return;

    abi.fetches(14);
    const co_idx = rt.r[0] & 0xFF;
    rt.r[0] = abi.read16(rt.r[4] +% (co_idx * 292) +% 0xC);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Apply CO visual sheet preset `0x08038074` for CO `u8(r0)` (`0x08038064`).
pub fn func_08038064() callconv(.c) void {
    if (!abi.enter(0x08038064)) return;
    callCoPortrait1BF50(0x08038074, 0, 0x08038071);
}

/// Reset CO visual sheet (`-1`) for CO `u8(r0)` (`0x08038078`).
pub fn func_08038078() callconv(.c) void {
    if (!abi.enter(0x08038078)) return;
    callCoPortrait1BF50(null, @bitCast(@as(i32, -1)), 0x08038087);
}

/// Clear CO visual sheet (`0`) for CO `u8(r0)` (`0x0803808C`).
pub fn func_0803808C() callconv(.c) void {
    if (!abi.enter(0x0803808C)) return;
    callCoPortrait1BF50(null, 0, 0x08038099);
}

fn popReturnR1Co() void {
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

fn callAudioC4ThenVoid(comptime next_fn: fn () callconv(.c) void, comptime ret1: u32, comptime ret2: u32) void {
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0xC4);
    if (!abi.call(decls.func_0803D880, ret1)) return;
    abi.fetches(4);
    if (!abi.call(next_fn, ret2)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Trigger CO portrait setup `0x0801B8D4` and clear via `0x0801B9E0([0x0801B8D0], 0)` (`0x0801B8BC`).
pub fn func_0801B8BC() callconv(.c) void {
    if (!abi.enter(0x0801B8BC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0801B8D4, 0x0801B8C3)) return;
    abi.fetches(6);
    rt.r[0] = abi.read32(0x0801B8D0);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801B9E0, 0x0801B8CB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Look up CO table field via `0x0801BE50(u8(r0))` and forward `i16` to `0x0803D890` (`0x0801BE88`).
pub fn func_0801BE88() callconv(.c) void {
    if (!abi.enter(0x0801BE88)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(func_0801BE50, 0x0801BE93)) return;
    abi.fetches(6);
    const s: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    abi.setRegNz(&rt.r[0], s);
    if (!abi.call(decls.func_0803D890, 0x0801BE9B)) return;
    abi.fetches(4);
    popReturnR1Co();
}

/// Upload `0x200`-byte CO tag tiles `0x0801BEA0(u16(r0))` to `[0x0801BF28] + u16(r1) * 0x20` (`0x0801BF00`).
pub fn func_0801BF00() callconv(.c) void {
    if (!abi.enter(0x0801BF00)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[0] &= 0xFFFF;
    const dst_idx = rt.r[1] & 0xFFFF;
    rt.updateNz(dst_idx);
    rt.r[4] = dst_idx;
    if (!abi.call(func_0801BEA0, 0x0801BF11)) return;
    abi.fetches(10);
    rt.r[4] = (dst_idx << 5) +% abi.read32(0x0801BF28);
    rt.r[1] = rt.r[4];
    abi.setRegNz(&rt.r[2], 0x200);
    if (!abi.call(decls.func_0800FFA8, 0x0801BF21)) return;
    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Upload CO unit palette `0x0801BEE4(u16(r0))` to OBJ palette slot `(u16(r1) + 0x10) << 5` via `0x08011330` (`0x0801BF2C`).
pub fn func_0801BF2C() callconv(.c) void {
    if (!abi.enter(0x0801BF2C)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[0] &= 0xFFFF;
    const pal_idx = rt.r[1] & 0xFFFF;
    rt.updateNz(pal_idx);
    rt.r[4] = pal_idx;
    if (!abi.call(func_0801BEE4, 0x0801BF3D)) return;
    abi.fetches(9);
    rt.r[4] = (((pal_idx +% 0x10) << 21) >> 16);
    rt.r[1] = rt.r[4];
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, 0x0801BF4B)) return;
    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Play SFX `0x23`, set flag via `0x080353A8(1)`, and update CO state `0x0801C150` (`0x0801C19C`).
pub fn func_0801C19C() callconv(.c) void {
    if (!abi.enter(0x0801C19C)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0x23);
    if (!abi.call(decls.func_0803D880, 0x0801C1A5)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 1);
    if (!abi.call(decls.func_080353A8, 0x0801C1AB)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0801C150, 0x0801C1AF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Play SFX `0xC4` and enter CO substate `0x0801C188` (`0x0801C1B4`).
pub fn func_0801C1B4() callconv(.c) void {
    if (!abi.enter(0x0801C1B4)) return;
    callAudioC4ThenVoid(decls.func_0801C188, 0x0801C1BD, 0x0801C1C1);
}

/// Tear down BG layers (`0x08011910`, `0x08011804`) and spawn CO panel proc `[0x0801C924]` (`0x0801C910`).
pub fn func_0801C910() callconv(.c) void {
    if (!abi.enter(0x0801C910)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08011910, 0x0801C917)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011804, 0x0801C91B)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x0801C924);
    if (!abi.call(decls.func_0801329C, 0x0801C921)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Play SFX `0xC4` and enter CO substate `0x0801C150` (`0x0801C93C`).
pub fn func_0801C93C() callconv(.c) void {
    if (!abi.enter(0x0801C93C)) return;
    callAudioC4ThenVoid(decls.func_0801C150, 0x0801C945, 0x0801C949);
}

/// Unpack both CO screen buffers `[0x0801CA2C]` and `[0x0801CA30]` via `0x0800FC9C` (`0x0801CA18`).
pub fn func_0801CA18() callconv(.c) void {
    if (!abi.enter(0x0801CA18)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0801CA2C);
    if (!abi.call(decls.func_0800FC9C, 0x0801CA21)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x0801CA30);
    if (!abi.call(decls.func_0800FC9C, 0x0801CA27)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Upload CO unit palette `0x0801BEE4(u16(r0))` to OBJ palette `(r1 & 0xF) + 0x10` via `0x08011330` (`0x0806C9A0`).
pub fn func_0806C9A0() callconv(.c) void {
    if (!abi.enter(0x0806C9A0)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const pal_slot = rt.r[1] & 0xF;
    rt.r[4] = pal_slot;
    rt.updateNz(pal_slot);
    rt.r[0] &= 0xFFFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(func_0801BEE4, 0x0806C9AF)) return;

    abi.fetches(8);
    const dst = (pal_slot +% 0x10) << 5;
    rt.r[4] = dst;
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, 0x0806C9BB)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Upload `0x200`-byte CO tag tiles `0x0801BEA0(u16(r0))` to masked OBJ VRAM slot (`0x0806CA08`).
pub fn func_0806CA08() callconv(.c) void {
    if (!abi.enter(0x0806CA08)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const slot = abi.read32(0x0806CA34) & rt.r[1];
    rt.r[4] = slot;
    rt.updateNz(slot);
    rt.r[0] &= 0xFFFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(func_0801BEA0, 0x0806CA17)) return;

    abi.fetches(14);
    const dst = ((slot << 5) | (@as(u32, 0x80) << 9)) +% (@as(u32, 0xC0) << 19);
    rt.r[4] = dst;
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[2], @as(u32, 0x80) << 2);
    if (!abi.call(decls.func_0800FFA8, 0x0806CA2F)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Decompress CO graphic `0x0801BEBC(u8(r0), u8(r1))` to `[0x0806CA60] + masked(r2) * 32` (`0x0806CA38`).
pub fn func_0806CA38() callconv(.c) void {
    if (!abi.enter(0x0806CA38)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const slot = abi.read32(0x0806CA5C) & rt.r[2];
    rt.r[4] = slot;
    rt.r[0] &= 0xFF;
    rt.r[1] &= 0xFF;
    rt.updateNz(rt.r[1]);
    if (!abi.call(func_0801BEBC, 0x0806CA4B)) return;

    abi.fetches(8);
    const dst = (slot << 5) +% abi.read32(0x0806CA60);
    rt.r[4] = dst;
    rt.r[1] = dst;
    if (!abi.call(decls.func_0800FE24, 0x0806CA57)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// LZ77-decompress CO asset `[0x0806CD4C][r0 * 36]` to tile `r1` and upload palette `0x0801BEE4` to `r2` (`0x0806CD10`).
pub fn func_0806CD10() callconv(.c) void {
    if (!abi.enter(0x0806CD10)) return;
    abi.fetches(17);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const co_id = rt.r[0];
    const pal_slot = rt.r[2];
    rt.r[4] = co_id;
    rt.r[5] = pal_slot;
    const tbl = abi.read32(0x0806CD4C);
    rt.r[0] = abi.read32((co_id *% 36) +% tbl);
    rt.r[1] = (rt.r[1] << 5) +% (@as(u32, 0xC0) << 19);
    abi.setRegNz(&rt.r[2], @as(u32, 0xC0) << 19);
    if (!abi.call(decls.func_0800FE18, 0x0806CD2F)) return;

    abi.fetches(7);
    const co_u16 = co_id & 0xFFFF;
    rt.r[4] = co_u16;
    abi.copyRegFlags(&rt.r[0], co_u16);
    if (!abi.call(func_0801BEE4, 0x0806CD39)) return;

    abi.fetches(8);
    const pal_off = (pal_slot << 21) >> 16;
    rt.r[5] = pal_off;
    rt.updateNz(pal_off);
    abi.copyRegFlags(&rt.r[1], pal_off);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, 0x0806CD45)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Load CO icon `0x08051E58(u16(r0))` and LZ77-decompress to VRAM tile `r1` via `0x0800FE18` (`0x0806CE84`).
pub fn func_0806CE84() callconv(.c) void {
    if (!abi.enter(0x0806CE84)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const tile_idx = rt.r[1];
    rt.r[4] = tile_idx;
    rt.r[0] &= 0xFFFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_08051E58, 0x0806CE91)) return;

    abi.fetches(9);
    const dst = (tile_idx << 5) +% (@as(u32, 0xC0) << 19);
    rt.r[4] = dst;
    rt.r[1] = dst;
    if (!abi.call(decls.func_0800FE18, 0x0806CE9F)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// DMA UI graphic `[0x0801C5A0]` into BG char bank `[0x0801C5A4]`, fill frame `0x08010C18`, upload palette `0x100`, flush BG (`0x0801C55C`).
pub fn func_0801C55C() callconv(.c) void {
    if (!abi.enter(0x0801C55C)) return;
    abi.fetches(16);
    abi.pushLr();
    rt.r[13] -%= 4;

    const char_bank = ((abi.read32(abi.read32(0x0801C5A4)) << 28) >> 30) << 14;
    rt.r[0] = abi.read32(0x0801C5A0);
    rt.r[1] = char_bank +% abi.read32(0x0801C5A8);
    abi.setRegNz(&rt.r[2], @as(u32, 0x80) << 4);
    if (!abi.call(decls.func_0800FFA8, 0x0801C579)) return;

    abi.fetches(10);
    abi.write32(rt.r[13], abi.read32(0x0801C5B4));
    rt.r[0] = abi.read32(0x0801C5AC);
    rt.r[1] = abi.read32(0x0801C5B0);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_08010C18, 0x0801C589)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x0801C5B8);
    abi.setRegNz(&rt.r[1], @as(u32, 0x80) << 1);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, 0x0801C595)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08011804, 0x0801C599)) return;

    abi.fetches(5);
    rt.r[13] +%= 4;
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_0801BDDC, .{ .name = "func_0801BDDC", .linkage = .strong });
        @export(&func_0801BE10, .{ .name = "func_0801BE10", .linkage = .strong });
        @export(&func_0801BE30, .{ .name = "func_0801BE30", .linkage = .strong });
        @export(&func_0801BE50, .{ .name = "func_0801BE50", .linkage = .strong });
        @export(&func_0801BEA0, .{ .name = "func_0801BEA0", .linkage = .strong });
        @export(&func_0801BEBC, .{ .name = "func_0801BEBC", .linkage = .strong });
        @export(&func_0801BEE4, .{ .name = "func_0801BEE4", .linkage = .strong });
        @export(&func_08038064, .{ .name = "func_08038064", .linkage = .strong });
        @export(&func_08038078, .{ .name = "func_08038078", .linkage = .strong });
        @export(&func_0803808C, .{ .name = "func_0803808C", .linkage = .strong });
        @export(&func_0801B8BC, .{ .name = "func_0801B8BC", .linkage = .strong });
        @export(&func_0801BE88, .{ .name = "func_0801BE88", .linkage = .strong });
        @export(&func_0801BF00, .{ .name = "func_0801BF00", .linkage = .strong });
        @export(&func_0801BF2C, .{ .name = "func_0801BF2C", .linkage = .strong });
        @export(&func_0801C19C, .{ .name = "func_0801C19C", .linkage = .strong });
        @export(&func_0801C1B4, .{ .name = "func_0801C1B4", .linkage = .strong });
        @export(&func_0801C910, .{ .name = "func_0801C910", .linkage = .strong });
        @export(&func_0801C93C, .{ .name = "func_0801C93C", .linkage = .strong });
        @export(&func_0801CA18, .{ .name = "func_0801CA18", .linkage = .strong });
        @export(&func_0806C9A0, .{ .name = "func_0806C9A0", .linkage = .strong });
        @export(&func_0806CA08, .{ .name = "func_0806CA08", .linkage = .strong });
        @export(&func_0806CA38, .{ .name = "func_0806CA38", .linkage = .strong });
        @export(&func_0806CD10, .{ .name = "func_0806CD10", .linkage = .strong });
        @export(&func_0806CE84, .{ .name = "func_0806CE84", .linkage = .strong });
        @export(&func_0801C55C, .{ .name = "func_0801C55C", .linkage = .strong });
    }
}

test "CO portrait ROM stride helpers align with GBA tables" {
    try std.testing.expectEqual(@as(u32, 0x080C_985C), coPortraitTilesAddr(0));
    try std.testing.expectEqual(@as(u32, 0x080C_995C), coPortraitTilesAddr(1));
    try std.testing.expectEqual(@as(u32, 0x080C_CA3C), coPortraitSmallTilesAddr(0));
    try std.testing.expectEqual(@as(u32, 0x080C_CABC), coPortraitSmallTilesAddr(1));
}
