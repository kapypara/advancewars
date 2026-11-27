//! Lifted Advance Wars UI, menus, result screens, BG tilemaps & fade transitions (`0x0803D038..0x0807660C`).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");

/// Encode a 4bpp GBA screen entry `(tile_id | (hflip_pal_fields))`.
pub inline fn encodeScreenEntry(tile: u16, pal_bank: u16, extra: u16) u16 {
    return (tile +% (pal_bank << 12)) | (extra << 10);
}

fn writeTilemapScreenEntry(comptime base_pool_ref: u32) void {
    abi.fetches(19);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const tile: u16 = @truncate(rt.r[0]);
    const cell_idx: u16 = @truncate(rt.r[1]);
    const pal: u16 = @truncate(rt.r[2]);
    const extra: u16 = @truncate(rt.r[3]);
    const base = abi.read32(base_pool_ref);
    const dst = base +% (@as(u32, cell_idx) << 1);
    const entry = encodeScreenEntry(tile, pal, extra);
    abi.write16(dst, entry);

    rt.r[1] = dst;
    rt.r[2] = @as(u32, pal) << 12;
    rt.r[3] = @as(u32, extra) << 10;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;

    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.updateNz(entry);
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

fn bumpUiDirtyCounter(comptime ptr_pool_ref: u32) u32 {
    const base = abi.read32(abi.read32(ptr_pool_ref));
    const ctr_addr = base +% 0x2D;
    const next: u32 = @as(u32, abi.read8(ctr_addr)) +% 1;
    abi.write8(ctr_addr, @truncate(next));
    return ctr_addr;
}

fn uiResetCursorDirty(comptime ptr_pool_ref: u32) void {
    abi.fetches(9);
    const ctr = bumpUiDirtyCounter(ptr_pool_ref);
    rt.r[1] = abi.read8(ctr);
    rt.r[0] = ctr;
    abi.retLr();
}

fn uiSetMode16AndBump(comptime ptr_pool_ref: u32) void {
    abi.fetches(11);
    const panel = rt.r[0];
    const ctr = bumpUiDirtyCounter(ptr_pool_ref);
    const val = abi.read8(ctr);
    abi.write16(panel +% 0x26, 0x10);
    rt.r[2] = val;
    rt.r[1] = 0x10;
    abi.retLr();
}

fn uiSetActiveItem(comptime ptr_pool_ref: u32, comptime has_field_38: bool) void {
    abi.fetches(if (has_field_38) 24 else 22);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const panel = rt.r[0];
    const arg1 = rt.r[1];
    const slot_idx = rt.r[2];
    const arg3 = rt.r[3];
    abi.write16(panel +% 0x26, 0xB);
    abi.write16(panel +% 0x1C, @truncate(slot_idx));
    abi.write16(panel +% 0x28, @truncate(arg1));
    if (has_field_38) {
        abi.write16(panel +% 0x38, 0x4E);
    }
    abi.write16(panel +% 0x24, @truncate(arg3));

    const mgr_base = abi.read32(abi.read32(ptr_pool_ref));
    const slot_off = slot_idx << 2;
    abi.write32(mgr_base +% 0x48 +% slot_off, panel);
    const ctr = mgr_base +% 0x2D;
    const next: u32 = @as(u32, abi.read8(ctr)) +% 1;
    abi.write8(ctr, @truncate(next));

    rt.r[1] = mgr_base +% 0x48 +% slot_off;
    rt.r[2] = slot_off;
    rt.r[3] = ctr;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.updateNz(next);
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

fn uiSetFadeMaskFFFE(comptime mask_pool_ref: u32) void {
    abi.fetches(7);
    const mask = abi.read32(mask_pool_ref);
    abi.write16(rt.r[0] +% 0x3C, @truncate(mask));
    abi.write16(rt.r[0] +% 0x3A, 0);
    rt.r[2] = 0;
    rt.r[1] = mask;
    abi.retLr();
}

fn uiBumpAndSetFade2(comptime ptr_pool_ref: u32) void {
    abi.fetches(13);
    const ctr = bumpUiDirtyCounter(ptr_pool_ref);
    const next = abi.read8(ctr);
    abi.write16(rt.r[0] +% 0x3C, 2);
    abi.write16(rt.r[0] +% 0x3A, 0);
    rt.r[3] = 0;
    rt.r[2] = next;
    rt.r[1] = 2;
    abi.retLr();
}

fn uiApplyBlendReset(comptime ctrl_ref: u32, comptime val_a_ref: u32, comptime val_b_ref: u32, comptime val_a: u16, comptime val_b: u16, comptime tail_kind: u8) void {
    abi.fetches(switch (tail_kind) {
        0 => 49,
        1 => 44,
        2 => 39,
        3 => 50,
        else => unreachable,
    });
    if (tail_kind != 2) {
        abi.pushLr();
        rt.r[13] -%= 4;
        abi.write32(rt.r[13], rt.r[4]);
    }
    const ctrl = abi.read32(ctrl_ref);
    const b0: u32 = ((abi.read8(ctrl) & 0x3F) | 0x40) & 0xE0;
    abi.write8(ctrl, @truncate(b0));
    const b1: u32 = (abi.read8(ctrl +% 1) | 0x0F) & @as(u32, @bitCast(-@as(i32, 0x11)));
    abi.write8(ctrl +% 1, @truncate(b1));

    const addr_a = abi.read32(val_a_ref);
    abi.write16(addr_a, val_a);
    const addr_b = abi.read32(val_b_ref);
    abi.write16(addr_b, val_b);

    switch (tail_kind) {
        0 => {
            abi.write16(rt.r[0] +% 0x44, 0x19);
            abi.write32(rt.r[0] +% 0x2C, 0x200);
            rt.r[1] = 0x200;
            rt.r[2] = rt.r[0] +% 0x44;
            rt.r[3] = ctrl;
            rt.updateNz(0x200);
        },
        1 => {
            abi.write16(rt.r[0] +% 0x44, 0);
            rt.r[0] +%= 0x44;
            rt.r[1] = 0;
            rt.r[2] = val_b;
            rt.r[3] = ctrl;
            rt.updateNz(0);
        },
        2 => {
            rt.r[2] = ctrl;
            rt.r[1] = addr_b;
            abi.setRegNz(&rt.r[0], val_b);
            abi.retLr();
            return;
        },
        3 => {
            const base_obj = rt.r[0];
            abi.write16(base_obj +% 0x1C, 1);
            abi.write16(base_obj +% 0x42, 0);
            abi.write16(base_obj +% 0x44, 0);
            rt.r[0] = base_obj +% 0x44;
            rt.r[1] = base_obj +% 0x42;
            rt.r[2] = 0;
            rt.r[3] = ctrl;
        },
        else => unreachable,
    }

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Snapshot post-battle/summary stats (`0x0201_226C` & `0x0201_2B3C`) into panel `[r0 + 0x20..0x2E]` (`0x0803D038`).
pub fn func_0803D038() callconv(.c) void {
    if (!abi.enter(0x0803D038)) return;
    abi.fetches(43);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const panel = rt.r[0];
    const summary = abi.read32(0x0803D08C);
    abi.write16(panel +% 0x20, abi.read8(summary +% 0x1D));
    abi.write16(panel +% 0x22, abi.read8(summary +% 0x1F));
    abi.write16(panel +% 0x24, abi.read8(summary +% 0x20));
    abi.write16(panel +% 0x26, @truncate(abi.read32(summary +% 0x10)));
    abi.write16(panel +% 0x28, @truncate(abi.read32(summary +% 0x14)));
    abi.write16(panel +% 0x2A, 0);

    const base_off = abi.read32(0x0803D090);
    const any_sum: u32 = @as(u32, abi.read8(summary +% 0x1C0)) +%
        abi.read8(summary +% base_off) +%
        abi.read8(summary +% base_off +% 1) +%
        abi.read8(summary +% base_off +% 2);
    const has_any: u32 = @as(u32, @bitCast(-@as(i32, @bitCast(any_sum)))) >> 31;
    abi.write16(panel +% 0x2C, @truncate(has_any));

    const flag_val = abi.read8(abi.read32(0x0803D094));
    abi.write16(panel +% 0x2E, flag_val);

    rt.r[1] = flag_val;
    rt.r[2] = abi.read8(summary +% base_off +% 2);
    rt.r[3] = summary;
    rt.updateNz(has_any);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Clear panel `+0x1E = 0` and `+0x20 = 0` (`u16`) (`0x0803D2C4`).
pub fn func_0803D2C4() callconv(.c) void {
    if (!abi.enter(0x0803D2C4)) return;
    abi.fetches(6);
    abi.write16(rt.r[0] +% 0x1E, 0);
    abi.write16(rt.r[0] +% 0x20, 0);
    abi.setRegNz(&rt.r[1], 0);
    abi.retLr();
}

/// Initialize summary result flags `[0x0201_226C + 0x0C] = 0`, `[+0x1D] = 1` (`0x0803D588`).
pub fn func_0803D588() callconv(.c) void {
    if (!abi.enter(0x0803D588)) return;
    abi.fetches(8);
    const base = abi.read32(0x0803D594);
    abi.write8(base +% 0xC, 0);
    abi.write8(base +% 0x1D, 1);
    rt.r[0] = base;
    abi.setRegNz(&rt.r[1], 1);
    abi.retLr();
}

/// Increment `[*(0x082E_BB70) + 0x8CF]` (`u8`) (`0x0804505C`).
pub fn func_0804505C() callconv(.c) void {
    if (!abi.enter(0x0804505C)) return;
    abi.fetches(10);
    const dst = abi.read32(abi.read32(0x0804506C)) +% abi.read32(0x08045070);
    const next: u32 = @as(u32, abi.read8(dst)) +% 1;
    abi.write8(dst, @truncate(next));
    rt.r[0] = dst;
    abi.setRegNz(&rt.r[1], next);
    abi.retLr();
}

/// Set `[*(0x0300_48D4) + 0x22] = 1` (`0x08048BD0`).
pub fn func_08048BD0() callconv(.c) void {
    if (!abi.enter(0x08048BD0)) return;
    abi.fetches(8);
    const dst = abi.read32(abi.read32(0x08048BDC)) +% 0x22;
    abi.write8(dst, 1);
    rt.r[0] = dst;
    abi.setRegNz(&rt.r[1], 1);
    abi.retLr();
}

/// Set `[*(0x0300_48D4) + 0x20] = 0xFF` (`0x08048F4C`).
pub fn func_08048F4C() callconv(.c) void {
    if (!abi.enter(0x08048F4C)) return;
    abi.fetches(8);
    const dst = abi.read32(abi.read32(0x08048F58)) +% 0x20;
    abi.write8(dst, 0xFF);
    rt.r[0] = dst;
    abi.setRegNz(&rt.r[1], 0xFF);
    abi.retLr();
}

/// Increment menu step byte `[0x0201_FD7F]` (`0x080494B4`).
pub fn func_080494B4() callconv(.c) void {
    if (!abi.enter(0x080494B4)) return;
    abi.fetches(7);
    const dst = abi.read32(0x080494C0);
    const next: u32 = @as(u32, abi.read8(dst)) +% 1;
    abi.write8(dst, @truncate(next));
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], next);
    abi.retLr();
}

/// Set UI cursor byte `[0x0201_FD93] = u8(r0)` (`0x0804B454`).
pub fn func_0804B454() callconv(.c) void {
    if (!abi.enter(0x0804B454)) return;
    abi.fetches(5);
    const dst = abi.read32(0x0804B45C);
    abi.write8(dst, @truncate(rt.r[0]));
    rt.r[1] = dst;
    abi.retLr();
}

/// Sync cursor coordinates `[0x0300_48FC] = [0x0300_48EC]`, `[0x0300_48E4] = [0x0300_48DC]` (`0x0804B4E8`).
pub fn func_0804B4E8() callconv(.c) void {
    if (!abi.enter(0x0804B4E8)) return;
    abi.fetches(11);
    abi.write16(abi.read32(0x0804B4FC), abi.read16(abi.read32(0x0804B500)));
    const dst2 = abi.read32(0x0804B504);
    const val2 = abi.read16(abi.read32(0x0804B508));
    abi.write16(dst2, val2);
    rt.r[1] = dst2;
    rt.r[0] = val2;
    abi.retLr();
}

/// Reset `*(0x0300_4904) + 0x36 = 0` and `+0x38 = 0x10` (`0x0804C3B8`).
pub fn func_0804C3B8() callconv(.c) void {
    if (!abi.enter(0x0804C3B8)) return;
    abi.fetches(9);
    const base = abi.read32(abi.read32(0x0804C3C8));
    abi.write16(base +% 0x36, 0);
    abi.write16(base +% 0x38, 0x10);
    rt.r[1] = base;
    abi.setRegNz(&rt.r[0], 0x10);
    abi.retLr();
}

/// UI predicate returning `1` (`0x0804C664`).
pub fn func_0804C664() callconv(.c) void {
    if (!abi.enter(0x0804C664)) return;
    abi.fetches(4);
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

/// Initialize card transition state using `[0x0201_FDD5]` and `*(0x0830_9118)` (`0x0805196C`).
pub fn func_0805196C() callconv(.c) void {
    if (!abi.enter(0x0805196C)) return;
    abi.fetches(36);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const obj = rt.r[0];
    const ctr_addr = abi.read32(0x080519B0);
    const idx8 = abi.read8(ctr_addr);
    abi.write16(obj +% 0x22, idx8);
    const signed_idx: i16 = @bitCast(abi.read16(obj +% 0x22));
    const y_val: u32 = @bitCast((@as(i32, signed_idx) << 5) +% 0x38);
    abi.write16(obj +% 0x1E, @truncate(y_val));

    const other = abi.read32(abi.read32(0x080519B4));
    abi.write16(other +% 0x20, 0x40);
    abi.write8(ctr_addr, idx8 +% 1);
    abi.write8(obj +% 0x26, 0x50);
    abi.write8(obj +% 0x28, 0);
    abi.write8(other +% 0x2A, 0);
    abi.write16(obj +% 0x24, 0);

    rt.r[12] = obj;
    rt.r[0] = obj;
    rt.r[1] = other +% 0x2A;
    rt.r[2] = ctr_addr;
    rt.r[3] = 0;

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.updateNz(0x50);
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Reset `*(0x0830_95F0) + 0x26 = 0` and `+0x24 = 0x07D0` (`0x08051D18`).
pub fn func_08051D18() callconv(.c) void {
    if (!abi.enter(0x08051D18)) return;
    abi.fetches(10);
    const obj = abi.read32(abi.read32(0x08051D28));
    abi.write16(obj +% 0x26, 0);
    abi.write16(obj +% 0x24, 0x07D0);
    rt.r[1] = obj;
    abi.setRegNz(&rt.r[0], 0x07D0);
    abi.retLr();
}

/// Initialize menu layout globals from cursor table `0x083B_7BEC` / `0x083B_7C02` (`0x0805A2F8`).
pub fn func_0805A2F8() callconv(.c) void {
    if (!abi.enter(0x0805A2F8)) return;
    abi.fetches(40);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    abi.write16(abi.read32(0x0805A344), abi.read16(abi.read32(0x0805A348)));
    abi.write16(abi.read32(0x0805A34C), 0);
    abi.write16(abi.read32(0x0805A350), 0);

    const menu = abi.read32(0x0805A35C);
    const key_a = abi.read16(menu +% 0xA);
    const key_b = abi.read16(menu +% 0x1A);

    const dst_a = abi.read32(0x0805A354);
    const tbl_a = abi.read32(0x0805A358);
    abi.write16(dst_a, abi.read16(tbl_a +% (@as(u32, key_a) << 1)));
    abi.write16(dst_a +% 2, abi.read16(tbl_a +% (@as(u32, key_b) << 1)));

    const dst_b = abi.read32(0x0805A360);
    const tbl_b = abi.read32(0x0805A364);
    abi.write16(dst_b, abi.read16(tbl_b +% (@as(u32, key_a) << 1)));
    const last_v = abi.read16(tbl_b +% (@as(u32, key_b) << 1));
    abi.write16(dst_b +% 2, last_v);

    rt.r[1] = key_b;
    rt.r[2] = tbl_b;
    rt.r[3] = dst_b;
    rt.updateNz(@as(u32, key_b) << 1);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Set UI flag bits in `0x0300_4918` and reset `+0x02 = 0xFFFF` (`0x0805B5AC`).
pub fn func_0805B5AC() callconv(.c) void {
    if (!abi.enter(0x0805B5AC)) return;
    abi.fetches(24);
    const addr = abi.read32(0x0805B5D8);
    const cur = abi.read8(addr);
    const mask_clr = @as(u32, @bitCast(-@as(i32, 2))) & @as(u32, @bitCast(-@as(i32, 5))) & @as(u32, @bitCast(-@as(i32, 9)));
    _ = mask_clr;
    // Exact sequence: ((cur & ~1) | 2) & ~0xC | 0x70 -> effectively ((cur & ~0xD) | 0x72)
    const next_flags: u8 = @truncate(((cur & 0xFE) | 0x02) & 0xF3 | 0x70);
    abi.write8(addr, next_flags);
    const fill = abi.read32(0x0805B5DC);
    abi.write16(addr +% 2, @truncate(fill));
    rt.r[2] = addr;
    rt.r[1] = 0x40;
    rt.r[0] = fill;
    abi.retLr();
}

/// Populate 5 menu grid halfwords into `0x0300_4CB0[row * 0xB4 + col * 36]` (`0x0805DC84`).
pub fn func_0805DC84() callconv(.c) void {
    if (!abi.enter(0x0805DC84)) return;
    abi.fetches(62);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const src = rt.r[0];
    const base = abi.read32(0x0805DCFC);
    const row = abi.read16(src);
    const col = abi.read16(src +% 2);
    const dst = base +% (@as(u32, row) *% 0xB4) +% (@as(u32, col) *% 36);

    abi.write16(dst +% 0x0C, abi.read16(src +% 0x4));
    abi.write16(dst +% 0x10, abi.read16(src +% 0x6));
    abi.write16(dst +% 0x0E, abi.read16(src +% 0x8));
    abi.write16(dst +% 0x12, abi.read16(src +% 0xA));
    const v5 = abi.read16(src +% 0xC);
    abi.write16(dst +% 0x16, v5);

    rt.r[1] = dst;
    rt.r[2] = v5;
    rt.r[3] = 0xB4;
    rt.updateNz(dst -% base);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Write BG tilemap screen entry into `0x0202_25DC[r1]` (`0x0805E680`).
pub fn func_0805E680() callconv(.c) void {
    if (!abi.enter(0x0805E680)) return;
    writeTilemapScreenEntry(0x0805E6A4);
}

/// Write BG tilemap screen entry into `0x0202_15DC[r1]` (`0x0805E908`).
pub fn func_0805E908() callconv(.c) void {
    if (!abi.enter(0x0805E908)) return;
    writeTilemapScreenEntry(0x0805E92C);
}

/// Enable blend layer bits in `bldcnt_shadow` (`0x0300_3354`) (`0x0805EC0C`).
pub fn func_0805EC0C() callconv(.c) void {
    if (!abi.enter(0x0805EC0C)) return;
    abi.fetches(21);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const addr = abi.read32(0x0805EC34);
    const v0: u32 = abi.read8(addr) | 0x34;
    abi.write8(addr, @truncate(v0));
    const v1: u32 = abi.read8(addr +% 1) | 0x38;
    abi.write8(addr +% 1, @truncate(v1));

    rt.r[1] = addr;
    rt.r[2] = 0x20;
    rt.r[3] = 0x10;
    rt.updateNz(v1);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Configure BG control shadows (`0x0300_3364`, `0x0300_2F2C`) from table `0x083B_7CE0` (`0x0805EC38`).
pub fn func_0805EC38() callconv(.c) void {
    if (!abi.enter(0x0805EC38)) return;
    abi.fetches(29);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const idx: u16 = @truncate(rt.r[0]);
    const tbl = abi.read32(0x0805EC74);
    const alt = abi.read16(tbl +% (@as(u32, idx ^ 1) << 1));
    abi.write16(abi.read32(0x0805EC70), @truncate(0x0608 | alt));

    const dst2 = abi.read32(0x0805EC78);
    const mask2 = abi.read32(0x0805EC7C);
    const entry2 = abi.read16(tbl +% (@as(u32, idx) << 1));
    const combined: u32 = mask2 | entry2;
    abi.write16(dst2, @truncate(combined));

    rt.r[0] = tbl +% (@as(u32, idx) << 1);
    rt.r[1] = combined;
    rt.r[2] = dst2;
    rt.r[3] = mask2;
    rt.updateNz(combined);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// UI no-op stub (`0x08062EC8`).
pub fn func_08062EC8() callconv(.c) void {
    if (!abi.enter(0x08062EC8)) return;
    abi.fetches(3);
    abi.retLr();
}

/// UI no-op stub (`0x0806586C`).
pub fn func_0806586C() callconv(.c) void {
    if (!abi.enter(0x0806586C)) return;
    abi.fetches(3);
    abi.retLr();
}

/// Increment UI panel manager dirty byte `[*(0x083B_918C) + 0x2D]` (`0x0806D8D4`).
pub fn func_0806D8D4() callconv(.c) void {
    if (!abi.enter(0x0806D8D4)) return;
    uiResetCursorDirty(0x0806D8E4);
}

/// Bump UI dirty counter and set panel `+0x26 = 0x10` (`0x0806D944`).
pub fn func_0806D944() callconv(.c) void {
    if (!abi.enter(0x0806D944)) return;
    uiSetMode16AndBump(0x0806D958);
}

/// Bind active UI panel slot without updating `+0x38` (`0x0806DE20`).
pub fn func_0806DE20() callconv(.c) void {
    if (!abi.enter(0x0806DE20)) return;
    uiSetActiveItem(0x0806DE48, false);
}

/// Set fade target `0xFFFE` and clear timer `+0x3A` (`0x0806DF00`).
pub fn func_0806DF00() callconv(.c) void {
    if (!abi.enter(0x0806DF00)) return;
    uiSetFadeMaskFFFE(0x0806DF0C);
}

/// Bump UI dirty counter and set fade target `2`, `+0x3A = 0` (`0x0806DF48`).
pub fn func_0806DF48() callconv(.c) void {
    if (!abi.enter(0x0806DF48)) return;
    uiBumpAndSetFade2(0x0806DF60);
}

/// Bind active UI panel slot with `+0x38 = 0x4E` (`0x0806DFAC`).
pub fn func_0806DFAC() callconv(.c) void {
    if (!abi.enter(0x0806DFAC)) return;
    uiSetActiveItem(0x0806DFD8, true);
}

/// Set fade target `0xFFFE` and clear timer `+0x3A` (`0x0806E2D4`).
pub fn func_0806E2D4() callconv(.c) void {
    if (!abi.enter(0x0806E2D4)) return;
    uiSetFadeMaskFFFE(0x0806E2E0);
}

/// Bump UI dirty counter and set fade target `2`, `+0x3A = 0` (`0x0806E31C`).
pub fn func_0806E31C() callconv(.c) void {
    if (!abi.enter(0x0806E31C)) return;
    uiBumpAndSetFade2(0x0806E334);
}

/// Bump UI dirty counter and set panel `+0x26 = 0xB, +0x38 = 0` (`0x0806E380`).
pub fn func_0806E380() callconv(.c) void {
    if (!abi.enter(0x0806E380)) return;
    abi.fetches(13);
    const ctr = bumpUiDirtyCounter(0x0806E398);
    const val = abi.read8(ctr);
    abi.write16(rt.r[0] +% 0x26, 0xB);
    abi.write16(rt.r[0] +% 0x38, 0);
    rt.r[3] = 0;
    rt.r[2] = val;
    rt.r[1] = 0xB;
    abi.retLr();
}

/// Set panel state `[r0 + 0x26] = 3` (`0x0806F564`).
pub fn func_0806F564() callconv(.c) void {
    if (!abi.enter(0x0806F564)) return;
    abi.fetches(5);
    abi.write16(rt.r[0] +% 0x26, 3);
    abi.setRegNz(&rt.r[1], 3);
    abi.retLr();
}

/// Reset panel anim counters `+0x30 = 0x200`, `+0x34 = -1` (`0x08070EFC`).
pub fn func_08070EFC() callconv(.c) void {
    if (!abi.enter(0x08070EFC)) return;
    abi.fetches(9);
    abi.write32(rt.r[0] +% 0x30, 0x200);
    const neg1: u32 = @bitCast(-@as(i32, 1));
    abi.write32(rt.r[0] +% 0x34, neg1);
    rt.r[1] = neg1;
    abi.retLr();
}

/// Set panel `+0x44 = 0x10`, enable upper bits in `ui_blend_ctrl`, write `0x10` to `0x0300_1E40` (`0x08070F78`).
pub fn func_08070F78() callconv(.c) void {
    if (!abi.enter(0x08070F78)) return;
    abi.fetches(13);
    abi.write16(rt.r[0] +% 0x44, 0x10);
    const ctrl = abi.read32(0x08070F90);
    abi.write8(ctrl, abi.read8(ctrl) | 0xC0);
    const dst = abi.read32(0x08070F94);
    abi.write16(dst, 0x10);
    rt.r[2] = 0x10;
    rt.r[3] = abi.read8(ctrl);
    rt.r[1] = ctrl;
    rt.r[0] = dst;
    abi.retLr();
}

/// Configure blend mask + fade `0x10` / `0` and panel `+0x44=0x19, +0x2C=0x200` (`0x08071004`).
pub fn func_08071004() callconv(.c) void {
    if (!abi.enter(0x08071004)) return;
    uiApplyBlendReset(0x08071064, 0x08071068, 0x0807106C, 0x10, 0, 0);
}

/// Set panel `+0x44 = 7` (`u16`) (`0x08071184`).
pub fn func_08071184() callconv(.c) void {
    if (!abi.enter(0x08071184)) return;
    abi.fetches(6);
    rt.r[0] +%= 0x44;
    abi.write16(rt.r[0], 7);
    abi.setRegNz(&rt.r[1], 7);
    abi.retLr();
}

/// Configure blend mask + fade `8` / `8` and clear panel `+0x44 = 0` (`0x080714C4`).
pub fn func_080714C4() callconv(.c) void {
    if (!abi.enter(0x080714C4)) return;
    uiApplyBlendReset(0x08071518, 0x0807151C, 0x08071520, 8, 8, 1);
}

/// Configure full blend mask on `0x0300_3388` and store `(r1, r3, r2)` in panel `+0x30/34/38` (`0x08072C6C`).
pub fn func_08072C6C() callconv(.c) void {
    if (!abi.enter(0x08072C6C)) return;
    abi.fetches(40);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const ctrl = abi.read32(0x08072CB8);
    abi.write8(ctrl, abi.read8(ctrl) | 0xDF);
    abi.write8(ctrl +% 1, abi.read8(ctrl +% 1) & 0xF0);

    abi.write32(rt.r[0] +% 0x30, rt.r[1]);
    abi.write32(rt.r[0] +% 0x38, rt.r[2]);
    abi.write32(rt.r[0] +% 0x34, rt.r[3]);
    const dst = abi.read32(0x08072CBC);
    abi.write16(dst, @truncate(rt.r[1]));

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Clear panel `+0x48 = 0` (`u8`) and `+0x2C = 0` (`u32`) (`0x08073B08`).
pub fn func_08073B08() callconv(.c) void {
    if (!abi.enter(0x08073B08)) return;
    abi.fetches(8);
    abi.write8(rt.r[0] +% 0x48, 0);
    abi.write32(rt.r[0] +% 0x2C, 0);
    rt.r[2] = rt.r[0] +% 0x48;
    abi.setRegNz(&rt.r[1], 0);
    abi.retLr();
}

/// Configure blend mask and set fade `0` / `0x10` (`0x08073CE8`).
pub fn func_08073CE8() callconv(.c) void {
    if (!abi.enter(0x08073CE8)) return;
    uiApplyBlendReset(0x08073D34, 0x08073D38, 0x08073D3C, 0, 0x10, 2);
}

/// Write vertical 1x2 BG tile pair (`tile+0x2A`, `tile+0x3A`) into `0x0201_2B40` at `(x, y)` (`0x08074630`).
pub fn func_08074630() callconv(.c) void {
    if (!abi.enter(0x08074630)) return;
    abi.fetches(21);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const x = rt.r[0];
    const y = rt.r[1];
    const tile_base = rt.r[2];
    const buf = abi.read32(0x08074658);

    const addr_top = buf +% (((y << 5) +% x) << 1);
    abi.write16(addr_top, @truncate(tile_base +% 0x2A));
    const addr_bot = buf +% ((((y +% 1) << 5) +% x) << 1);
    const tile_bot = tile_base +% 0x3A;
    abi.write16(addr_bot, @truncate(tile_bot));

    rt.r[1] = addr_bot;
    rt.r[2] = tile_bot;
    rt.r[3] = addr_top;

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Set panel `+0x44 = 0x0F` (`u16`) (`0x08075090`).
pub fn func_08075090() callconv(.c) void {
    if (!abi.enter(0x08075090)) return;
    abi.fetches(6);
    rt.r[0] +%= 0x44;
    abi.write16(rt.r[0], 0xF);
    abi.setRegNz(&rt.r[1], 0xF);
    abi.retLr();
}

/// Configure blend mask + fade `0` / `0x10` and reset panel `+0x1C=1, +0x42=0, +0x44=0` (`0x08075B60`).
pub fn func_08075B60() callconv(.c) void {
    if (!abi.enter(0x08075B60)) return;
    uiApplyBlendReset(0x08075BC0, 0x08075BC4, 0x08075BC8, 0, 0x10, 3);
}

/// Increment UI panel manager dirty byte `[*(0x083B_918C) + 0x2D]` (`0x080761C0`).
pub fn func_080761C0() callconv(.c) void {
    if (!abi.enter(0x080761C0)) return;
    uiResetCursorDirty(0x080761D0);
}

/// Bump UI dirty counter and set panel `+0x26 = 0x10` (`0x08076228`).
pub fn func_08076228() callconv(.c) void {
    if (!abi.enter(0x08076228)) return;
    uiSetMode16AndBump(0x0807623C);
}

/// Bump UI dirty counter and set panel `+0x26 = 0x10, +0x28 = 0xF0` (`0x0807660C`).
pub fn func_0807660C() callconv(.c) void {
    if (!abi.enter(0x0807660C)) return;
    abi.fetches(13);
    const ctr = bumpUiDirtyCounter(0x08076624);
    const val = abi.read8(ctr);
    abi.write16(rt.r[0] +% 0x26, 0x10);
    abi.write16(rt.r[0] +% 0x28, 0xF0);
    rt.r[2] = val;
    rt.r[1] = 0xF0;
    abi.retLr();
}

fn callUiPanelMode16(comptime mode: u32, comptime ret_addr: u32) void {
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = mode;
    abi.setRegNz(&rt.r[1], 0x10);
    if (!abi.call(decls.func_08018D84, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward to `0x08018D84(1, 0x10)` (`0x08018DE4`).
pub fn func_08018DE4() callconv(.c) void {
    if (!abi.enter(0x08018DE4)) return;
    callUiPanelMode16(1, 0x08018DEF);
}

/// Forward to `0x08018D84(2, 0x10)` (`0x08018DF4`).
pub fn func_08018DF4() callconv(.c) void {
    if (!abi.enter(0x08018DF4)) return;
    callUiPanelMode16(2, 0x08018DFF);
}

/// Forward to `0x080193C0(r0, u16(r1), u16(r2), u16(r3), 0)` (`0x080195E8`).
pub fn func_080195E8() callconv(.c) void {
    if (!abi.enter(0x080195E8)) return;
    abi.fetches(14);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], 0);
    rt.r[1] &= 0xFFFF;
    rt.r[2] &= 0xFFFF;
    rt.r[3] &= 0xFFFF;
    rt.r[4] = 0;
    rt.updateNz(0);
    if (!abi.call(decls.func_080193C0, 0x08019601)) return;
    abi.fetches(6);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Forward to `0x08019E60(r0, r1, r2, r3, 0)` returning `r0` (`0x08019F04`).
pub fn func_08019F04() callconv(.c) void {
    if (!abi.enter(0x08019F04)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], 0);
    rt.r[4] = 0;
    rt.updateNz(0);
    if (!abi.call(decls.func_08019E60, 0x08019F11)) return;
    abi.fetches(6);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Forward to `0x08019F18(r0, r1, r2, r3, 0, 0x27)` returning `r0` (`0x08019F60`).
pub fn func_08019F60() callconv(.c) void {
    if (!abi.enter(0x08019F60)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;
    abi.write32(rt.r[13], 0);
    abi.write32(rt.r[13] +% 4, 0x27);
    rt.r[4] = 0x27;
    rt.updateNz(0x27);
    if (!abi.call(decls.func_08019F18, 0x08019F71)) return;
    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Forward to `0x08019F18(r0, r1, r2, 0, orig_r3, sp_arg)` returning `r0` (`0x08019F78`).
pub fn func_08019F78() callconv(.c) void {
    if (!abi.enter(0x08019F78)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;
    const sp_arg = abi.read32(rt.r[13] +% 0x10);
    abi.write32(rt.r[13], rt.r[3]);
    abi.write32(rt.r[13] +% 4, sp_arg);
    rt.r[4] = sp_arg;
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_08019F18, 0x08019F89)) return;
    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Forward to `0x08019F18(r0, r1, r2, 0, 0, 0x27)` returning `r0` (`0x08019F90`).
pub fn func_08019F90() callconv(.c) void {
    if (!abi.enter(0x08019F90)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 8;
    abi.write32(rt.r[13], 0);
    abi.write32(rt.r[13] +% 4, 0x27);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_08019F18, 0x08019FA3)) return;
    abi.fetches(5);
    rt.r[13] +%= 8;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

fn sendPacket4(
    comptime tag: u8,
    comptime pkt_ref: u32,
    comptime state_ref: u32,
    comptime extra_ref: ?u32,
    comptime ret_addr: u32,
) void {
    abi.fetches(if (extra_ref != null) 21 else 15);
    abi.pushLr();
    const pkt = abi.read32(pkt_ref);
    const state = abi.read32(abi.read32(state_ref));
    abi.write8(pkt, tag);
    abi.write8(pkt +% 1, abi.read8(state +% 6));
    if (extra_ref) |tbl_ref| {
        const slot_signed: u32 = @bitCast(abi.signExtend8(abi.read8(state +% 6)));
        const tbl_addr = abi.read32(tbl_ref) +% slot_signed +% 0x3E;
        abi.write16(pkt +% 2, abi.read8(tbl_addr));
    } else {
        abi.write16(pkt +% 2, 0);
    }
    rt.r[0] = pkt;
    abi.setRegNz(&rt.r[1], 4);
    if (!abi.call(decls.func_0803093C, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn spawnProcZero(comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(def_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn endProcPool(comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(def_ref);
    if (!abi.call(decls.func_0801329C, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn spawnBannerProc3291C(comptime id: u32, comptime x_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(8);
    abi.pushLr();
    rt.r[1] = abi.read32(x_ref);
    abi.setRegNz(&rt.r[0], id);
    abi.setRegNz(&rt.r[2], 0xE);
    if (!abi.call(decls.func_0803291C, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn checkProcActive(comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(def_ref);
    if (!abi.call(decls.func_08013B70, ret_addr)) return;
    abi.fetches(11);
    const active = abi.signExtend8(@truncate(rt.r[0])) != -1;
    abi.setRegNz(&rt.r[0], @intFromBool(active));
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Emit 4-byte command `0x39` with active slot & `0x0300_4310 + 0x3E` flag (`0x08030D90`).
pub fn func_08030D90() callconv(.c) void {
    if (!abi.enter(0x08030D90)) return;
    sendPacket4(0x39, 0x08030DBC, 0x08030DC0, 0x08030DC4, 0x08030DB7);
}

/// Spawn `0x0828_C17C` UI proc with `proc->+0x1C = 0` (`0x080328A0`).
pub fn func_080328A0() callconv(.c) void {
    if (!abi.enter(0x080328A0)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x080328B4);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x080328AB)) return;
    abi.fetches(6);
    abi.write16(rt.r[0] +% 0x1C, 0);
    abi.popReturn();
}

/// Clear HUD/window bits `0x41` / `0x21` and end proc `0x0828_C17C` (`0x080328B8`).
pub fn func_080328B8() callconv(.c) void {
    if (!abi.enter(0x080328B8)) return;
    abi.fetches(18);
    abi.pushLr();
    const reg_a = abi.read32(0x080328DC);
    abi.write8(reg_a +% 1, abi.read8(reg_a +% 1) & ~@as(u8, 0x41));
    const reg_b = abi.read32(0x080328E0);
    abi.write8(reg_b, abi.read8(reg_b) & ~@as(u8, 0x21));
    rt.r[0] = abi.read32(0x080328E4);
    if (!abi.call(decls.func_0801329C, 0x080328D9)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Update banner position using `(proc->+0x1E, proc->+0x20)` via `0x08049998` (`0x0803290C`).
pub fn func_0803290C() callconv(.c) void {
    if (!abi.enter(0x0803290C)) return;
    abi.fetches(8);
    abi.pushLr();
    const x = abi.read16(rt.r[0] +% 0x1E);
    const y = abi.read16(rt.r[0] +% 0x20);
    rt.r[0] = x;
    rt.r[1] = y;
    if (!abi.call(decls.func_08049998, 0x08032919)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn `0x0828_C18C` banner proc storing `(id=r0, x=r1, y=r2)` (`0x0803291C`).
pub fn func_0803291C() callconv(.c) void {
    if (!abi.enter(0x0803291C)) return;
    abi.fetches(10);
    abi.pushLr();
    inline for ([_]u8{ 6, 5, 4 }) |reg| {
        rt.r[13] -%= 4;
        abi.write32(rt.r[13], rt.r[reg]);
    }
    rt.r[6] = rt.r[0];
    rt.r[4] = rt.r[1];
    rt.r[5] = rt.r[2];
    rt.r[0] = abi.read32(0x08032938);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_0801320C, 0x0803292D)) return;
    abi.fetches(8);
    abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[4]));
    abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[5]));
    abi.write16(rt.r[0] +% 0x22, @truncate(rt.r[6]));
    inline for ([_]u8{ 4, 5, 6 }) |reg| {
        rt.r[reg] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
    }
    abi.popReturn();
}

/// End `0x0828_C18C` banner proc (`0x0803293C`).
pub fn func_0803293C() callconv(.c) void {
    if (!abi.enter(0x0803293C)) return;
    endProcPool(0x08032948, 0x08032945);
}

/// Spawn banner proc variant `0x12` at X from `0x0803295C` (`0x0803294C`).
pub fn func_0803294C() callconv(.c) void {
    if (!abi.enter(0x0803294C)) return;
    spawnBannerProc3291C(0x12, 0x0803295C, 0x08032959);
}

/// Spawn banner proc variant `0x13` at X from `0x08032970` (`0x08032960`).
pub fn func_08032960() callconv(.c) void {
    if (!abi.enter(0x08032960)) return;
    spawnBannerProc3291C(0x13, 0x08032970, 0x0803296D);
}

/// Spawn banner proc variant `0x14` at X from `0x08032984` (`0x08032974`).
pub fn func_08032974() callconv(.c) void {
    if (!abi.enter(0x08032974)) return;
    spawnBannerProc3291C(0x14, 0x08032984, 0x08032981);
}

/// End UI panel proc `0x08033238` (`0x0803322C`).
pub fn func_0803322C() callconv(.c) void {
    if (!abi.enter(0x0803322C)) return;
    endProcPool(0x08033238, 0x08033235);
}

/// Spawn `0x0828_C1BC` proc with default coordinates `(0x64, 0x48)` and ID `0x64` (`0x08033384`).
pub fn func_08033384() callconv(.c) void {
    if (!abi.enter(0x08033384)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0803339C);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x0803338F)) return;
    abi.fetches(9);
    abi.write16(rt.r[0] +% 0x22, 0x64);
    abi.write16(rt.r[0] +% 0x1E, 0x64);
    abi.write16(rt.r[0] +% 0x20, 0x48);
    abi.popReturn();
}

/// End `0x0828_C1BC` UI proc (`0x080333A0`).
pub fn func_080333A0() callconv(.c) void {
    if (!abi.enter(0x080333A0)) return;
    endProcPool(0x080333AC, 0x080333A9);
}

/// Emit 4-byte command `0x38` with active slot & zero payload (`0x080335F4`).
pub fn func_080335F4() callconv(.c) void {
    if (!abi.enter(0x080335F4)) return;
    sendPacket4(0x38, 0x08033614, 0x08033618, null, 0x0803360F);
}

/// End `0x0828_C21C` UI proc (`0x0803361C`).
pub fn func_0803361C() callconv(.c) void {
    if (!abi.enter(0x0803361C)) return;
    endProcPool(0x08033628, 0x08033625);
}

/// Play/queue UI banner effect `0x54` at signed `i16(arg0 + 48)` with priority `3` (`0x0803385C`).
pub fn func_0803385C() callconv(.c) void {
    if (!abi.enter(0x0803385C)) return;
    abi.fetches(13);
    abi.pushLr();
    const y_off: u16 = @truncate(rt.r[0] +% 0x30);
    rt.r[1] = @bitCast(abi.signExtend16(y_off));
    abi.setRegNz(&rt.r[0], 0x54);
    abi.setRegNz(&rt.r[2], 3);
    if (!abi.call(decls.func_08020CDC, 0x08033873)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn `0x0828_C54C` proc (`0x080338E8`).
pub fn func_080338E8() callconv(.c) void {
    if (!abi.enter(0x080338E8)) return;
    spawnProcZero(0x080338F8, 0x080338F3);
}

/// Spawn `0x0828_C5C4` proc (`0x08034008`).
pub fn func_08034008() callconv(.c) void {
    if (!abi.enter(0x08034008)) return;
    spawnProcZero(0x08034018, 0x08034013);
}

/// End `0x0828_C5C4` proc (`0x0803401C`).
pub fn func_0803401C() callconv(.c) void {
    if (!abi.enter(0x0803401C)) return;
    endProcPool(0x08034028, 0x08034025);
}

/// Spawn `0x0828_C2C4` UI overlay proc (`0x0803470C`).
pub fn func_0803470C() callconv(.c) void {
    if (!abi.enter(0x0803470C)) return;
    spawnProcZero(0x0803471C, 0x08034717);
}

/// Return `1` if `0x0803473C` proc is currently running, else `0` (`0x08034720`).
pub fn func_08034720() callconv(.c) void {
    if (!abi.enter(0x08034720)) return;
    checkProcActive(0x0803473C, 0x08034729);
}

/// Spawn `0x0828_C79C` UI overlay proc (`0x08034740`).
pub fn func_08034740() callconv(.c) void {
    if (!abi.enter(0x08034740)) return;
    spawnProcZero(0x08034750, 0x0803474B);
}

/// Return `1` if `0x0828_C79C` proc is currently running, else `0` (`0x08034754`).
pub fn func_08034754() callconv(.c) void {
    if (!abi.enter(0x08034754)) return;
    checkProcActive(0x08034770, 0x0803475D);
}

/// Spawn `0x0828_C974` UI overlay proc (`0x08034774`).
pub fn func_08034774() callconv(.c) void {
    if (!abi.enter(0x08034774)) return;
    spawnProcZero(0x08034784, 0x0803477F);
}

/// Return `1` if `0x0828_C974` proc is currently running, else `0` (`0x08034788`).
pub fn func_08034788() callconv(.c) void {
    if (!abi.enter(0x08034788)) return;
    checkProcActive(0x080347A4, 0x08034791);
}

/// Spawn `0x080347B8` UI overlay proc (`0x080347A8`).
pub fn func_080347A8() callconv(.c) void {
    if (!abi.enter(0x080347A8)) return;
    spawnProcZero(0x080347B8, 0x080347B3);
}

fn callUI18400Pool(comptime ptr_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(ptr_ref);
    if (!abi.call(decls.func_08018400, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn callMenuAction353A8(comptime mode: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], mode);
    if (!abi.call(decls.func_080353A8, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward 5-arg `(r0, u16 r1..r3, u16 [sp+0])` UI widget draw to `0x08019424` (`0x080193C0`).
pub fn func_080193C0() callconv(.c) void {
    if (!abi.enter(0x080193C0)) return;
    abi.fetches(16);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    rt.r[4] = abi.read32(rt.r[13] +% 0xC) & 0xFFFF;
    rt.r[1] &= 0xFFFF;
    rt.r[2] &= 0xFFFF;
    rt.r[3] &= 0xFFFF;
    abi.write32(rt.r[13], rt.r[4]);
    if (!abi.call(decls.func_08019424, 0x080193DD)) return;

    abi.fetches(6);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Resolve UI text resource `0x0802C66C` via `0x08018400` (`0x0802C660`).
pub fn func_0802C660() callconv(.c) void {
    if (!abi.enter(0x0802C660)) return;
    callUI18400Pool(0x0802C66C, 0x0802C669);
}

/// Resolve UI string `0x0802C67C` via `0x080183C0` (`0x0802C670`).
pub fn func_0802C670() callconv(.c) void {
    if (!abi.enter(0x0802C670)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0802C67C);
    if (!abi.call(decls.func_080183C0, 0x0802C679)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn `0x0802C6B0` proc and clear HUD flag bit `2` at `*(0x0802C6B4) + 1` (`0x0802C694`).
pub fn func_0802C694() callconv(.c) void {
    if (!abi.enter(0x0802C694)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0802C6B0);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x0802C69F)) return;
    abi.fetches(10);
    const dst = abi.read32(0x0802C6B4) +% 1;
    abi.write8(dst, abi.read8(dst) & ~@as(u8, 2));
    abi.popReturn();
}

/// Dispatch UI menu mode `1` via `0x080353A8` (`0x08037FC4`).
pub fn func_08037FC4() callconv(.c) void {
    if (!abi.enter(0x08037FC4)) return;
    callMenuAction353A8(1, 0x08037FCD);
}

/// Close/reset active menu panel via `0x08035804` (`0x08037FD0`).
pub fn func_08037FD0() callconv(.c) void {
    if (!abi.enter(0x08037FD0)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08035804, 0x08037FD7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch UI menu mode `0` via `0x080353A8` (`0x08037FDC`).
pub fn func_08037FDC() callconv(.c) void {
    if (!abi.enter(0x08037FDC)) return;
    callMenuAction353A8(0, 0x08037FE5);
}

/// Dispatch UI menu mode `1` via `0x080353A8` (`0x08037FE8`).
pub fn func_08037FE8() callconv(.c) void {
    if (!abi.enter(0x08037FE8)) return;
    callMenuAction353A8(1, 0x08037FF1);
}

/// Dispatch UI menu mode `2` via `0x080353A8` (`0x08037FF4`).
pub fn func_08037FF4() callconv(.c) void {
    if (!abi.enter(0x08037FF4)) return;
    callMenuAction353A8(2, 0x08037FFD);
}

/// Resolve UI text resource `0x08038928` via `0x08018400` (`0x0803891C`).
pub fn func_0803891C() callconv(.c) void {
    if (!abi.enter(0x0803891C)) return;
    callUI18400Pool(0x08038928, 0x08038925);
}

/// Refresh tactical HUD via `0x08019608` (`0x080389DC`).
pub fn func_080389DC() callconv(.c) void {
    if (!abi.enter(0x080389DC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019608, 0x080389E3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Return `1` if `0x08038C40` proc is active, else `0` (`0x08038C24`).
pub fn func_08038C24() callconv(.c) void {
    if (!abi.enter(0x08038C24)) return;
    checkProcActive(0x08038C40, 0x08038C2D);
}

/// Spawn `0x080397B4` overlay proc storing `u16(r0)` at `+0x1E` (`0x0803979C`).
pub fn func_0803979C() callconv(.c) void {
    if (!abi.enter(0x0803979C)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0] & 0xFFFF;
    rt.r[0] = abi.read32(0x080397B4);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x080397AD)) return;

    abi.fetches(6);
    abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[4]));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// End `0x08039A30` UI proc (`0x08039A24`).
pub fn func_08039A24() callconv(.c) void {
    if (!abi.enter(0x08039A24)) return;
    endProcPool(0x08039A30, 0x08039A2D);
}

/// Spawn `0x08039EFC` UI proc (`0x08039EEC`).
pub fn func_08039EEC() callconv(.c) void {
    if (!abi.enter(0x08039EEC)) return;
    spawnProcZero(0x08039EFC, 0x08039EF7);
}

/// Spawn `0x0803A660` UI proc (`0x0803A650`).
pub fn func_0803A650() callconv(.c) void {
    if (!abi.enter(0x0803A650)) return;
    spawnProcZero(0x0803A660, 0x0803A65B);
}

/// Spawn `0x0803BC44` overlay proc storing `u8(r0)` at `+0x20` (`0x0803BC2C`).
pub fn func_0803BC2C() callconv(.c) void {
    if (!abi.enter(0x0803BC2C)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0] & 0xFF;
    rt.r[0] = abi.read32(0x0803BC44);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x0803BC3D)) return;

    abi.fetches(6);
    abi.write16(rt.r[0] +% 0x20, @truncate(rt.r[4]));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Return `1` if `0x0803BD70` proc is active, else `0` (`0x0803BD54`).
pub fn func_0803BD54() callconv(.c) void {
    if (!abi.enter(0x0803BD54)) return;
    checkProcActive(0x0803BD70, 0x0803BD5D);
}

fn callUIProc31E0(comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(def_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn callUIWindow11060(
    comptime mode_val: ?u8,
    comptime mode_ref: ?u32,
    comptime a0_ref: u32,
    comptime a1_ref: u32,
    comptime a2_ref: u32,
    comptime ret_addr: u32,
) void {
    abi.fetches(if (mode_val != null) 11 else 8);
    abi.pushLr();
    if (mode_val) |m| {
        abi.write8(abi.read32(mode_ref.?) +% 1, m);
    }
    rt.r[0] = abi.read32(a0_ref);
    rt.r[1] = abi.read32(a1_ref);
    rt.r[2] = abi.read32(a2_ref);
    if (!abi.call(decls.func_08011060, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn queryUI13BA0(comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(def_ref);
    if (!abi.call(decls.func_08013BA0, ret_addr)) return;
    abi.fetches(6);
    rt.r[0] &= 0xFF;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

fn callUIStep3DD24(comptime step: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], step);
    if (!abi.call(decls.func_0803DD24, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Queue overlay callback `0x0803C828` with arg `1` via `0x08015824` (`0x0803C818`).
pub fn func_0803C818() callconv(.c) void {
    if (!abi.enter(0x0803C818)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0803C828);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_08015824, 0x0803C823)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Return `1` if `0x0803D034` UI proc is active, else `0` (`0x0803D018`).
pub fn func_0803D018() callconv(.c) void {
    if (!abi.enter(0x0803D018)) return;
    checkProcActive(0x0803D034, 0x0803D021);
}

/// Spawn `0x0803D2C0` UI proc (`0x0803D2B0`).
pub fn func_0803D2B0() callconv(.c) void {
    if (!abi.enter(0x0803D2B0)) return;
    spawnProcZero(0x0803D2C0, 0x0803D2BB);
}

/// Dispatch UI palette/panel init `0x0801B478` (`0x0803D2CC`).
pub fn func_0803D2CC() callconv(.c) void {
    if (!abi.enter(0x0803D2CC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0801B478, 0x0803D2D3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch UI palette/panel cleanup `0x0801B4F8` (`0x0803D2D8`).
pub fn func_0803D2D8() callconv(.c) void {
    if (!abi.enter(0x0803D2D8)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0801B4F8, 0x0803D2DF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn `0x0803D44C` UI proc (`0x0803D43C`).
pub fn func_0803D43C() callconv(.c) void {
    if (!abi.enter(0x0803D43C)) return;
    spawnProcZero(0x0803D44C, 0x0803D447);
}

/// End `0x0803D4CC` UI proc (`0x0803D4C0`).
pub fn func_0803D4C0() callconv(.c) void {
    if (!abi.enter(0x0803D4C0)) return;
    endProcPool(0x0803D4CC, 0x0803D4C9);
}

/// Return `1` if `0x0803D4EC` UI proc is active, else `0` (`0x0803D4D0`).
pub fn func_0803D4D0() callconv(.c) void {
    if (!abi.enter(0x0803D4D0)) return;
    checkProcActive(0x0803D4EC, 0x0803D4D9);
}

/// Clear `[0x0803D584]` flag byte and configure menu via `0x08048AA4(..., 6)` (`0x0803D570`).
pub fn func_0803D570() callconv(.c) void {
    if (!abi.enter(0x0803D570)) return;
    abi.fetches(9);
    abi.pushLr();
    const ptr = abi.read32(0x0803D584);
    abi.write8(ptr, 0);
    rt.r[0] = ptr;
    abi.setRegNz(&rt.r[1], 6);
    if (!abi.call(decls.func_08048AA4, 0x0803D57F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn indexed proc `0x0803D614` via `0x080131E0` (`0x0803D604`).
pub fn func_0803D604() callconv(.c) void {
    if (!abi.enter(0x0803D604)) return;
    callUIProc31E0(0x0803D614, 0x0803D60F);
}

/// End `0x0803D624` UI proc (`0x0803D618`).
pub fn func_0803D618() callconv(.c) void {
    if (!abi.enter(0x0803D618)) return;
    endProcPool(0x0803D624, 0x0803D621);
}

/// Spawn `0x0803DB10` UI proc (`0x0803DB00`).
pub fn func_0803DB00() callconv(.c) void {
    if (!abi.enter(0x0803DB00)) return;
    spawnProcZero(0x0803DB10, 0x0803DB0B);
}

/// Query byte proc flag `0x0803DB24` via `0x08013BA0` (`0x0803DB14`).
pub fn func_0803DB14() callconv(.c) void {
    if (!abi.enter(0x0803DB14)) return;
    queryUI13BA0(0x0803DB24, 0x0803DB1D);
}

/// Spawn `0x0803DB38` UI proc (`0x0803DB28`).
pub fn func_0803DB28() callconv(.c) void {
    if (!abi.enter(0x0803DB28)) return;
    spawnProcZero(0x0803DB38, 0x0803DB33);
}

/// Query byte proc flag `0x0803DB4C` via `0x08013BA0` (`0x0803DB3C`).
pub fn func_0803DB3C() callconv(.c) void {
    if (!abi.enter(0x0803DB3C)) return;
    queryUI13BA0(0x0803DB4C, 0x0803DB45);
}

/// Spawn `0x0803DB7C` UI proc (`0x0803DB6C`).
pub fn func_0803DB6C() callconv(.c) void {
    if (!abi.enter(0x0803DB6C)) return;
    spawnProcZero(0x0803DB7C, 0x0803DB77);
}

/// Open/draw UI window preset `0x0803DBD4..0x0803DBDC` (`0x0803DBC4`).
pub fn func_0803DBC4() callconv(.c) void {
    if (!abi.enter(0x0803DBC4)) return;
    callUIWindow11060(null, null, 0x0803DBD4, 0x0803DBD8, 0x0803DBDC, 0x0803DBD1);
}

/// Spawn `0x0803DC10` UI proc (`0x0803DC00`).
pub fn func_0803DC00() callconv(.c) void {
    if (!abi.enter(0x0803DC00)) return;
    spawnProcZero(0x0803DC10, 0x0803DC0B);
}

/// Dispatch UI panel mode `1` via `0x0803DD24` (`0x0803DC14`).
pub fn func_0803DC14() callconv(.c) void {
    if (!abi.enter(0x0803DC14)) return;
    callUIStep3DD24(1, 0x0803DC1D);
}

/// Dispatch UI panel mode `2` via `0x0803DD24` (`0x0803DC20`).
pub fn func_0803DC20() callconv(.c) void {
    if (!abi.enter(0x0803DC20)) return;
    callUIStep3DD24(2, 0x0803DC29);
}

/// Dispatch UI panel mode `3` via `0x0803DD24` (`0x0803DC2C`).
pub fn func_0803DC2C() callconv(.c) void {
    if (!abi.enter(0x0803DC2C)) return;
    callUIStep3DD24(3, 0x0803DC35);
}

/// Dispatch UI panel mode `4` via `0x0803DD24` (`0x0803DC38`).
pub fn func_0803DC38() callconv(.c) void {
    if (!abi.enter(0x0803DC38)) return;
    callUIStep3DD24(4, 0x0803DC41);
}

/// Set UI window mode byte `3` and open window `0x0803DC60..0x0803DC68` (`0x0803DC44`).
pub fn func_0803DC44() callconv(.c) void {
    if (!abi.enter(0x0803DC44)) return;
    callUIWindow11060(3, 0x0803DC5C, 0x0803DC60, 0x0803DC64, 0x0803DC68, 0x0803DC57);
}

/// Trigger UI helper `0x0806A3A0` (`0x0803DD94`).
pub fn func_0803DD94() callconv(.c) void {
    if (!abi.enter(0x0803DD94)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0806A3A0, 0x0803DD9B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Set UI window mode byte `4` and open window `0x0803DDBC..0x0803DDC4` (`0x0803DDA0`).
pub fn func_0803DDA0() callconv(.c) void {
    if (!abi.enter(0x0803DDA0)) return;
    callUIWindow11060(4, 0x0803DDB8, 0x0803DDBC, 0x0803DDC0, 0x0803DDC4, 0x0803DDB3);
}

/// Set UI window mode byte `4` and open window `0x0803DDE4..0x0803DDEC` (`0x0803DDC8`).
pub fn func_0803DDC8() callconv(.c) void {
    if (!abi.enter(0x0803DDC8)) return;
    callUIWindow11060(4, 0x0803DDE0, 0x0803DDE4, 0x0803DDE8, 0x0803DDEC, 0x0803DDDB);
}

/// Trigger UI helper `0x0804DA34` (`0x0803DDF0`).
pub fn func_0803DDF0() callconv(.c) void {
    if (!abi.enter(0x0803DDF0)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0804DA34, 0x0803DDF7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Set mode byte `2` at `*(0x0803DE20)+1` and spawn `0x0803DE24` proc (`0x0803DE0C`).
pub fn func_0803DE0C() callconv(.c) void {
    if (!abi.enter(0x0803DE0C)) return;
    abi.fetches(10);
    abi.pushLr();
    abi.write8(abi.read32(0x0803DE20) +% 1, 2);
    rt.r[0] = abi.read32(0x0803DE24);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x0803DE1D)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn `0x0803E934` UI proc (`0x0803E924`).
pub fn func_0803E924() callconv(.c) void {
    if (!abi.enter(0x0803E924)) return;
    spawnProcZero(0x0803E934, 0x0803E92F);
}

/// Return `1` if `0x0803E954` UI proc is active, else `0` (`0x0803E938`).
pub fn func_0803E938() callconv(.c) void {
    if (!abi.enter(0x0803E938)) return;
    checkProcActive(0x0803E954, 0x0803E941);
}

/// Dispatch slot entry `u8(r0)` (stride `24`) callback pair `(+0x10, 1, +0x0C)` via `0x0807B454` (`0x0803EE30`).
pub fn func_0803EE30() callconv(.c) void {
    if (!abi.enter(0x0803EE30)) return;
    abi.fetches(19);
    abi.pushLr();
    const base = abi.read32(0x0803EE58);
    const entry = base +% ((rt.r[0] & 0xFF) * 24);
    rt.r[0] = abi.read32(entry +% 0x10);
    abi.setRegNz(&rt.r[1], 1);
    rt.r[2] = abi.read32(entry +% 0xC);
    if (!abi.call(decls.func_0807B454, 0x0803EE53)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Return `1` if `0x0803FBD0` UI proc is active, else `0` (`0x0803FBB4`).
pub fn func_0803FBB4() callconv(.c) void {
    if (!abi.enter(0x0803FBB4)) return;
    checkProcActive(0x0803FBD0, 0x0803FBBD);
}

/// Spawn `0x08040178` UI proc (`0x08040168`).
pub fn func_08040168() callconv(.c) void {
    if (!abi.enter(0x08040168)) return;
    spawnProcZero(0x08040178, 0x08040173);
}

/// Spawn `0x08040AFC` UI proc (`0x08040AEC`).
pub fn func_08040AEC() callconv(.c) void {
    if (!abi.enter(0x08040AEC)) return;
    spawnProcZero(0x08040AFC, 0x08040AF7);
}

/// Trigger transition via `0x08010C18` with `(0x08040B1C, 0x08040B20, 0, 0, stack: 0x08040B24)` (`0x08040B00`).
pub fn func_08040B00() callconv(.c) void {
    if (!abi.enter(0x08040B00)) return;
    abi.fetches(12);
    abi.pushLr();
    rt.r[13] -%= 4;
    rt.r[0] = abi.read32(0x08040B1C);
    rt.r[1] = abi.read32(0x08040B20);
    abi.write32(rt.r[13], abi.read32(0x08040B24));
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_08010C18, 0x08040B15)) return;
    abi.fetches(5);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn `0x08041F0C` UI proc (`0x08041EFC`).
pub fn func_08041EFC() callconv(.c) void {
    if (!abi.enter(0x08041EFC)) return;
    spawnProcZero(0x08041F0C, 0x08041F07);
}

/// Reset hardware audio/display state and apply blend preset `(0xF, 6)` (`0x08042B28`).
pub fn func_08042B28() callconv(.c) void {
    if (!abi.enter(0x08042B28)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080104B0, 0x08042B2F)) return;
    abi.fetches(27);
    const reg = abi.read32(0x08042B60);
    abi.write8(reg, @truncate((abi.read8(reg) & 0x3F) | 0x44));
    abi.write8(reg +% 1, abi.read8(reg +% 1) | 0x1A);
    abi.write16(abi.read32(0x08042B64), 0xF);
    abi.write16(abi.read32(0x08042B68), 6);
    abi.popReturn();
}

fn callUIProc320C(comptime def_ref: u32, comptime mode: u32, comptime clear_flag_ref: ?u32, comptime ret_addr: u32) void {
    abi.fetches(if (clear_flag_ref != null) 9 else 7);
    abi.pushLr();
    if (clear_flag_ref) |flag_ref| {
        abi.write8(abi.read32(flag_ref) +% 1, 0);
    }
    rt.r[0] = abi.read32(def_ref);
    abi.setRegNz(&rt.r[1], mode);
    if (!abi.call(decls.func_0801320C, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn allocProcWorkBuf(comptime slot_ref: u32, comptime byte_size: u32, comptime ret_addr: u32) void {
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = abi.read32(slot_ref);
    abi.setRegNz(&rt.r[0], byte_size);
    if (!abi.call(decls.func_08012D8C, ret_addr)) return;

    abi.fetches(6);
    abi.write32(rt.r[4], rt.r[0]);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn freeProcWorkBuf(comptime slot_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(abi.read32(slot_ref));
    if (!abi.call(decls.func_08012E14, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn applyBlendSceneSetup(
    comptime reg_ref: u32,
    comptime bldcnt_ref: u32,
    comptime bldy_ref: u32,
    comptime mode_bits: u8,
    comptime fetches_after: u32,
) void {
    abi.fetches(fetches_after);
    const dispcnt = abi.read32(reg_ref);
    abi.write8(dispcnt, (abi.read8(dispcnt) & 0x3F) | mode_bits);
    abi.write8(dispcnt +% 1, abi.read8(dispcnt +% 1) | 0x18);
    rt.r[1] = abi.read32(bldcnt_ref);
    abi.write16(rt.r[1], 0xF);
    rt.r[2] = dispcnt;
    rt.r[1] = abi.read32(bldy_ref);
    abi.setRegNz(&rt.r[0], 6);
    abi.write16(rt.r[1], 6);
}

fn callUI18400Direct(comptime ptr_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(ptr_ref);
    if (!abi.call(decls.func_08018400, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn `0x08044E7C` UI proc (`0x08044E6C`).
pub fn func_08044E6C() callconv(.c) void {
    if (!abi.enter(0x08044E6C)) return;
    callUIProc320C(0x08044E7C, 1, null, 0x08044E77);
}

/// End `0x08044E8C` UI proc (`0x08044E80`).
pub fn func_08044E80() callconv(.c) void {
    if (!abi.enter(0x08044E80)) return;
    endProcPool(0x08044E8C, 0x08044E89);
}

/// Spawn `0x08044EA0` UI proc at priority `0x7E` (`0x08044E90`).
pub fn func_08044E90() callconv(.c) void {
    if (!abi.enter(0x08044E90)) return;
    callUIProc320C(0x08044EA0, 0x7E, null, 0x08044E9B);
}

/// Spawn `0x08044EB4` UI proc at priority `0x7F` (`0x08044EA4`).
pub fn func_08044EA4() callconv(.c) void {
    if (!abi.enter(0x08044EA4)) return;
    callUIProc320C(0x08044EB4, 0x7F, null, 0x08044EAF);
}

/// Spawn `0x08045084` UI proc (`0x08045074`).
pub fn func_08045074() callconv(.c) void {
    if (!abi.enter(0x08045074)) return;
    spawnProcZero(0x08045084, 0x0804507F);
}

/// Trigger UI helper `0x08020D14(2)` (`0x08045568`).
pub fn func_08045568() callconv(.c) void {
    if (!abi.enter(0x08045568)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 2);
    if (!abi.call(decls.func_08020D14, 0x08045571)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Invoke `0x08045308` with state bytes `[0x080459BC]` and `[0x080459C0]` (`0x080459A8`).
pub fn func_080459A8() callconv(.c) void {
    if (!abi.enter(0x080459A8)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = abi.read8(abi.read32(0x080459BC));
    rt.r[1] = abi.read8(abi.read32(0x080459C0));
    if (!abi.call(decls.func_08045308, 0x080459B7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Reset UI/unit panel state via `0x0801B8D4(0)` (`0x08045A0C`).
pub fn func_08045A0C() callconv(.c) void {
    if (!abi.enter(0x08045A0C)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_0801B8D4, 0x08045A15)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// End `0x08045A24` UI proc (`0x08045A18`).
pub fn func_08045A18() callconv(.c) void {
    if (!abi.enter(0x08045A18)) return;
    endProcPool(0x08045A24, 0x08045A21);
}

/// Reset UI/unit panel state via `0x0801B8D4(0)` (`0x08046DAC`).
pub fn func_08046DAC() callconv(.c) void {
    if (!abi.enter(0x08046DAC)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_0801B8D4, 0x08046DB5)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn `0x08046DFC` UI proc (`0x08046DEC`).
pub fn func_08046DEC() callconv(.c) void {
    if (!abi.enter(0x08046DEC)) return;
    spawnProcZero(0x08046DFC, 0x08046DF7);
}

/// Store `u16(r0)` at `*(0x080471C0)+0x2A` and dispatch table entry `0x080471C4[r0]` via `0x08018400` (`0x080471A4`).
pub fn func_080471A4() callconv(.c) void {
    if (!abi.enter(0x080471A4)) return;
    abi.fetches(14);
    abi.pushLr();
    const idx = rt.r[0] & 0xFFFF;
    rt.r[1] = abi.read32(abi.read32(0x080471C0));
    abi.write16(rt.r[1] +% 0x2A, @truncate(idx));
    rt.r[1] = abi.read32(0x080471C4);
    rt.r[0] = abi.read32(rt.r[1] +% (idx << 2));
    if (!abi.call(decls.func_08018400, 0x080471BD)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch table entry `0x0804720C[u16(r0)]` via `0x08018400` (`0x080471F8`).
pub fn func_080471F8() callconv(.c) void {
    if (!abi.enter(0x080471F8)) return;
    abi.fetches(10);
    abi.pushLr();
    const idx_off = ((rt.r[0] & 0xFFFF) << 16) >> 14;
    rt.r[1] = abi.read32(0x0804720C);
    rt.r[0] = abi.read32(rt.r[1] +% idx_off);
    if (!abi.call(decls.func_08018400, 0x08047209)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Reset hardware audio/display state and apply blend preset `(0x42, 0x18, 0xF, 6)` (`0x0804723C`).
pub fn func_0804723C() callconv(.c) void {
    if (!abi.enter(0x0804723C)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080104B0, 0x08047243)) return;
    applyBlendSceneSetup(0x08047270, 0x08047274, 0x08047278, 0x42, 25);
    abi.popReturn();
}

/// Dispatch UI callback `0x08047584` via `0x08018400` (`0x08047578`).
pub fn func_08047578() callconv(.c) void {
    if (!abi.enter(0x08047578)) return;
    callUI18400Direct(0x08047584, 0x08047581);
}

/// Spawn `0x080478D8` UI proc (`0x080478C8`).
pub fn func_080478C8() callconv(.c) void {
    if (!abi.enter(0x080478C8)) return;
    spawnProcZero(0x080478D8, 0x080478D3);
}

/// End `0x080478E8` UI proc (`0x080478DC`).
pub fn func_080478DC() callconv(.c) void {
    if (!abi.enter(0x080478DC)) return;
    endProcPool(0x080478E8, 0x080478E5);
}

/// Spawn `0x080487B0` UI proc (`0x080487A0`).
pub fn func_080487A0() callconv(.c) void {
    if (!abi.enter(0x080487A0)) return;
    spawnProcZero(0x080487B0, 0x080487AB);
}

/// Dispatch indexed callback `0x080487D0[*(0x080487D4)+0x5C]` via `0x08018400` (`0x080487B4`).
pub fn func_080487B4() callconv(.c) void {
    if (!abi.enter(0x080487B4)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[1] = abi.read32(0x080487D0);
    const idx = abi.read8(abi.read32(abi.read32(0x080487D4)) +% 0x5C);
    rt.r[0] = abi.read32(rt.r[1] +% (idx << 2));
    if (!abi.call(decls.func_08018400, 0x080487CB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch UI callback `0x08048810` via `0x08018400` (`0x08048804`).
pub fn func_08048804() callconv(.c) void {
    if (!abi.enter(0x08048804)) return;
    callUI18400Direct(0x08048810, 0x0804880D);
}

/// Allocate `0x6C`-byte UI buffer into `[0x08048AA0]` (`0x08048A8C`).
pub fn func_08048A8C() callconv(.c) void {
    if (!abi.enter(0x08048A8C)) return;
    allocProcWorkBuf(0x08048AA0, 0x6C, 0x08048A97);
}

/// Release UI buffer `[0x08048B3C]` (`0x08048B2C`).
pub fn func_08048B2C() callconv(.c) void {
    if (!abi.enter(0x08048B2C)) return;
    freeProcWorkBuf(0x08048B3C, 0x08048B37);
}

/// Return `1` if `i8(func_08013B70(0x08048B5C)) != -1`, else `0` (`0x08048B40`).
pub fn func_08048B40() callconv(.c) void {
    if (!abi.enter(0x08048B40)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08048B5C);
    if (!abi.call(decls.func_08013B70, 0x08048B49)) return;

    abi.fetches(11);
    const inverted: u32 = @bitCast(~abi.signExtend8(@truncate(rt.r[0])));
    var neg_inv: u32 = undefined;
    rt.cpuSub(&neg_inv, 0, inverted, true);
    const res = (neg_inv | inverted) >> 31;
    rt.cpuAdd(&rt.r[0], res, 0, true);
    rt.r[1] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[15] = rt.r[1];
    rt.recompReturn(rt.r[1]);
}

/// Clear flag `[0x08048B74]+1` and spawn `0x08048B78` UI proc (`0x08048B60`).
pub fn func_08048B60() callconv(.c) void {
    if (!abi.enter(0x08048B60)) return;
    callUIProc320C(0x08048B78, 0, 0x08048B74, 0x08048B6F);
}

/// Spawn indexed proc `0x0804921C` via `0x080131E0` (`0x0804920C`).
pub fn func_0804920C() callconv(.c) void {
    if (!abi.enter(0x0804920C)) return;
    callUIProc31E0(0x0804921C, 0x08049217);
}

/// Allocate `0x24`-byte UI buffer into `[0x080495A8]` (`0x08049594`).
pub fn func_08049594() callconv(.c) void {
    if (!abi.enter(0x08049594)) return;
    allocProcWorkBuf(0x080495A8, 0x24, 0x0804959F);
}

/// Release UI buffer `[0x080495BC]` (`0x080495AC`).
pub fn func_080495AC() callconv(.c) void {
    if (!abi.enter(0x080495AC)) return;
    freeProcWorkBuf(0x080495BC, 0x080495B7);
}

/// Release UI buffer `[0x080498C0]` (`0x080498B0`).
pub fn func_080498B0() callconv(.c) void {
    if (!abi.enter(0x080498B0)) return;
    freeProcWorkBuf(0x080498C0, 0x080498BB);
}

/// Set flag word `*(0x08049E1C)+0x50 = 0x40` and reset via `0x0804A400(0)` (`0x08049E08`).
pub fn func_08049E08() callconv(.c) void {
    if (!abi.enter(0x08049E08)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[1] = abi.read32(abi.read32(0x08049E1C));
    abi.write32(rt.r[1] +% 0x50, 0x40);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_0804A400, 0x08049E19)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Upload selected `0x7F`-masked UI graphics table entry via `0x080122D8` (`0x0804A1A8`).
pub fn func_0804A1A8() callconv(.c) void {
    if (!abi.enter(0x0804A1A8)) return;
    abi.fetches(29);
    abi.pushLr();
    rt.r[13] -%= 8;
    rt.r[2] = abi.read32(0x0804A1E4);
    const tbl = abi.read32(0x0804A1E8);
    const st = abi.read32(abi.read32(0x0804A1EC));
    const idx = abi.read8(st +% 0x30 +% abi.read8(st +% 0x2F)) & 0x7F;
    rt.r[3] = abi.read32(tbl +% (idx << 2));
    abi.write32(rt.r[13], 0x3000);
    abi.write32(rt.r[13] +% 4, 0x100);
    abi.setRegNz(&rt.r[0], 2);
    abi.setRegNz(&rt.r[1], 0xE);
    if (!abi.call(decls.func_080122D8, 0x0804A1DF)) return;
    abi.fetches(5);
    rt.r[13] +%= 8;
    abi.popReturn();
}

/// Reset hardware audio/display state and apply blend preset `(0x46, 0x18, 0xF, 6)` (`0x0804A3BC`).
pub fn func_0804A3BC() callconv(.c) void {
    if (!abi.enter(0x0804A3BC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080104B0, 0x0804A3C3)) return;
    applyBlendSceneSetup(0x0804A3F4, 0x0804A3F8, 0x0804A3FC, 0x46, 27);
    abi.popReturn();
}

/// Spawn `0x0804B41C` UI proc (`0x0804B40C`).
pub fn func_0804B40C() callconv(.c) void {
    if (!abi.enter(0x0804B40C)) return;
    spawnProcZero(0x0804B41C, 0x0804B417);
}

/// End `0x0804B42C` UI proc (`0x0804B420`).
pub fn func_0804B420() callconv(.c) void {
    if (!abi.enter(0x0804B420)) return;
    endProcPool(0x0804B42C, 0x0804B429);
}

/// Spawn `0x0804B450` UI proc (`0x0804B440`).
pub fn func_0804B440() callconv(.c) void {
    if (!abi.enter(0x0804B440)) return;
    spawnProcZero(0x0804B450, 0x0804B44B);
}

/// Dispatch UI callback `0x0804C1B4` via `0x08018400` (`0x0804C1A8`).
pub fn func_0804C1A8() callconv(.c) void {
    if (!abi.enter(0x0804C1A8)) return;
    callUI18400Direct(0x0804C1B4, 0x0804C1B1);
}

/// Clear byte `*(0x0804C23C)+0x33`, query `0x08049010`, and store result into `+0x34` (`0x0804C220`).
pub fn func_0804C220() callconv(.c) void {
    if (!abi.enter(0x0804C220)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = abi.read32(0x0804C23C);
    abi.write8(abi.read32(rt.r[4]) +% 0x33, 0);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_08049010, 0x0804C231)) return;

    abi.fetches(7);
    rt.r[1] = abi.read32(rt.r[4]);
    abi.write16(rt.r[1] +% 0x34, @truncate(rt.r[0]));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn `0x0804C5AC` UI proc (`0x0804C59C`).
pub fn func_0804C59C() callconv(.c) void {
    if (!abi.enter(0x0804C59C)) return;
    spawnProcZero(0x0804C5AC, 0x0804C5A7);
}

/// Allocate `0x40`-byte UI buffer into `[0x0804C618]` (`0x0804C604`).
pub fn func_0804C604() callconv(.c) void {
    if (!abi.enter(0x0804C604)) return;
    allocProcWorkBuf(0x0804C618, 0x40, 0x0804C60F);
}

/// Spawn `0x0804C64C` UI proc (`0x0804C63C`).
pub fn func_0804C63C() callconv(.c) void {
    if (!abi.enter(0x0804C63C)) return;
    spawnProcZero(0x0804C64C, 0x0804C647);
}

/// Release UI buffer `[0x0804C660]` (`0x0804C650`).
pub fn func_0804C650() callconv(.c) void {
    if (!abi.enter(0x0804C650)) return;
    freeProcWorkBuf(0x0804C660, 0x0804C65B);
}

/// Store `r0` at `*(0x0804C694) + [0x0804C698]` and forward `r0` to `0x08018400` (`0x0804C680`).
pub fn func_0804C680() callconv(.c) void {
    if (!abi.enter(0x0804C680)) return;
    abi.fetches(10);
    abi.pushLr();
    const base = abi.read32(abi.read32(0x0804C694));
    const off = abi.read32(0x0804C698);
    rt.r[2] = off;
    rt.cpuAdd(&rt.r[1], base, off, true);
    abi.write32(rt.r[1], rt.r[0]);
    if (!abi.call(decls.func_08018400, 0x0804C691)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn indexed proc `0x0804D994` via `0x080131E0` (`0x0804D984`).
pub fn func_0804D984() callconv(.c) void {
    if (!abi.enter(0x0804D984)) return;
    callUIProc31E0(0x0804D994, 0x0804D98F);
}

/// Spawn `0x0804DA44` UI proc (`0x0804DA34`).
pub fn func_0804DA34() callconv(.c) void {
    if (!abi.enter(0x0804DA34)) return;
    spawnProcZero(0x0804DA44, 0x0804DA3F);
}

/// Reset hardware audio/display state and apply blend preset `(0x44, 0x18, 0xF, 6)` (`0x0804DC68`).
pub fn func_0804DC68() callconv(.c) void {
    if (!abi.enter(0x0804DC68)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080104B0, 0x0804DC6F)) return;
    applyBlendSceneSetup(0x0804DC9C, 0x0804DCA0, 0x0804DCA4, 0x44, 25);
    abi.popReturn();
}

/// Upload VRAM `0x0804E4F0..0x0804E4F4` (`0x2000` bytes) via `0x08010C18` and apply blend `(0x44, 0x18, 0xF, 6)` (`0x0804E4A8`).
pub fn func_0804E4A8() callconv(.c) void {
    if (!abi.enter(0x0804E4A8)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    rt.r[0] = abi.read32(0x0804E4F0);
    rt.r[1] = abi.read32(0x0804E4F4);
    abi.write32(rt.r[13], 0x2000);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_08010C18, 0x0804E4BF)) return;

    applyBlendSceneSetup(0x0804E4F8, 0x0804E4FC, 0x0804E500, 0x44, 26);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// End `0x0804F1F4` UI proc (`0x0804F1E8`).
pub fn func_0804F1E8() callconv(.c) void {
    if (!abi.enter(0x0804F1E8)) return;
    endProcPool(0x0804F1F4, 0x0804F1F1);
}

/// Close UI proc via `0x0804F7AC` and set `*(0x0804F6E4)+0x24 = 0xFF` (`0x0804F6D0`).
pub fn func_0804F6D0() callconv(.c) void {
    if (!abi.enter(0x0804F6D0)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0804F7AC, 0x0804F6D7)) return;

    abi.fetches(8);
    rt.r[1] = abi.read32(abi.read32(0x0804F6E4));
    abi.setRegNz(&rt.r[0], 0xFF);
    abi.write16(rt.r[1] +% 0x24, 0xFF);
    abi.popReturn();
}

/// End `0x0804F7B8` UI proc (`0x0804F7AC`).
pub fn func_0804F7AC() callconv(.c) void {
    if (!abi.enter(0x0804F7AC)) return;
    endProcPool(0x0804F7B8, 0x0804F7B5);
}

/// End `0x0804F7C8` UI proc (`0x0804F7BC`).
pub fn func_0804F7BC() callconv(.c) void {
    if (!abi.enter(0x0804F7BC)) return;
    endProcPool(0x0804F7C8, 0x0804F7C5);
}

/// End `0x0804F7D8` UI proc (`0x0804F7CC`).
pub fn func_0804F7CC() callconv(.c) void {
    if (!abi.enter(0x0804F7CC)) return;
    endProcPool(0x0804F7D8, 0x0804F7D5);
}

/// Spawn `0x0804F7EC` UI proc at priority `0x7E` (`0x0804F7DC`).
pub fn func_0804F7DC() callconv(.c) void {
    if (!abi.enter(0x0804F7DC)) return;
    callUIProc320C(0x0804F7EC, 0x7E, null, 0x0804F7E7);
}

/// End `0x0804F7FC` UI proc (`0x0804F7F0`).
pub fn func_0804F7F0() callconv(.c) void {
    if (!abi.enter(0x0804F7F0)) return;
    endProcPool(0x0804F7FC, 0x0804F7F9);
}

fn callVoidForward(comptime target: fn () callconv(.c) void, comptime ret_addr: u32) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(target, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn callUISet2ESpawn320C(comptime ptr_ref: u32, comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(11);
    abi.pushLr();
    rt.r[1] = abi.read32(abi.read32(ptr_ref)) +% 0x2E;
    abi.write8(rt.r[1], @truncate(rt.r[0]));
    rt.r[0] = abi.read32(def_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn callUIMaskU16Step53368(comptime ret_addr: u32) void {
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] &= 0xFFFF;
    if (!abi.call(decls.func_08053368, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn callMenuMetric54BA8(comptime tbl_ref: u32, comptime idx_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(19);
    abi.pushLr();
    rt.r[3] = abi.read32(tbl_ref);
    const idx: u32 = @bitCast(abi.signExtend16(abi.read16(abi.read32(idx_ref))));
    const off = ((idx << 1) +% idx) << 5;
    rt.r[0] = abi.read16(off +% rt.r[3] +% 0x30);
    rt.r[1] = abi.read16(off +% (rt.r[3] +% 0x34));
    if (!abi.call(decls.func_08054BA8, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn checkUIProc13B70Active(comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(def_ref);
    if (!abi.call(decls.func_08013B70, ret_addr)) return;

    abi.fetches(11);
    const inverted: u32 = @bitCast(~abi.signExtend8(@truncate(rt.r[0])));
    var neg_inv: u32 = undefined;
    rt.cpuSub(&neg_inv, 0, inverted, true);
    const res = (neg_inv | inverted) >> 31;
    rt.cpuAdd(&rt.r[0], res, 0, true);
    rt.r[1] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[15] = rt.r[1];
    rt.recompReturn(rt.r[1]);
}

/// Release UI buffer `[0x0804F834]` (`0x0804F824`).
pub fn func_0804F824() callconv(.c) void {
    if (!abi.enter(0x0804F824)) return;
    freeProcWorkBuf(0x0804F834, 0x0804F82F);
}

/// Spawn `0x08050564` UI proc (`0x08050554`).
pub fn func_08050554() callconv(.c) void {
    if (!abi.enter(0x08050554)) return;
    spawnProcZero(0x08050564, 0x0805055F);
}

/// Spawn `0x08050630` UI proc (`0x08050620`).
pub fn func_08050620() callconv(.c) void {
    if (!abi.enter(0x08050620)) return;
    spawnProcZero(0x08050630, 0x0805062B);
}

/// Spawn `0x08050C80` UI proc (`0x08050C70`).
pub fn func_08050C70() callconv(.c) void {
    if (!abi.enter(0x08050C70)) return;
    spawnProcZero(0x08050C80, 0x08050C7B);
}

/// Spawn `0x08050EB0` UI proc (`0x08050EA0`).
pub fn func_08050EA0() callconv(.c) void {
    if (!abi.enter(0x08050EA0)) return;
    spawnProcZero(0x08050EB0, 0x08050EAB);
}

/// Spawn `0x08051884` UI proc (`0x08051874`).
pub fn func_08051874() callconv(.c) void {
    if (!abi.enter(0x08051874)) return;
    spawnProcZero(0x08051884, 0x0805187F);
}

/// Reset UI panel state via `0x0801B8D4(0)` and clear `[0x08051C38]` / `*(0x08051C3C)+0x2C` (`0x08051C1C`).
pub fn func_08051C1C() callconv(.c) void {
    if (!abi.enter(0x08051C1C)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_0801B8D4, 0x08051C25)) return;

    abi.fetches(11);
    abi.write8(abi.read32(0x08051C38), 0);
    rt.r[1] = abi.read32(abi.read32(0x08051C3C));
    abi.setRegNz(&rt.r[0], 0);
    abi.write16(rt.r[1] +% 0x2C, 0);
    abi.popReturn();
}

/// Store `u8(r0)` at `*(0x08051CF0)+0x2E` and spawn `0x08051CF4` UI proc (`0x08051CD8`).
pub fn func_08051CD8() callconv(.c) void {
    if (!abi.enter(0x08051CD8)) return;
    callUISet2ESpawn320C(0x08051CF0, 0x08051CF4, 0x08051CEB);
}

/// Store `u8(r0)` at `*(0x08051D10)+0x2E` and spawn `0x08051D14` UI proc (`0x08051CF8`).
pub fn func_08051CF8() callconv(.c) void {
    if (!abi.enter(0x08051CF8)) return;
    callUISet2ESpawn320C(0x08051D10, 0x08051D14, 0x08051D0B);
}

/// Spawn `0x080521FC` UI proc (`0x080521EC`).
pub fn func_080521EC() callconv(.c) void {
    if (!abi.enter(0x080521EC)) return;
    spawnProcZero(0x080521FC, 0x080521F7);
}

/// Spawn `0x0805222C` UI proc (`0x0805221C`).
pub fn func_0805221C() callconv(.c) void {
    if (!abi.enter(0x0805221C)) return;
    spawnProcZero(0x0805222C, 0x08052227);
}

/// Dispatch `u16(r0)` to `0x08053368` (`0x08053400`).
pub fn func_08053400() callconv(.c) void {
    if (!abi.enter(0x08053400)) return;
    callUIMaskU16Step53368(0x0805340B);
}

/// Dispatch `u16(r0)` to `0x08053368` (`0x08053410`).
pub fn func_08053410() callconv(.c) void {
    if (!abi.enter(0x08053410)) return;
    callUIMaskU16Step53368(0x0805341B);
}

/// Select item `u16(r0)`, copy table word `[0x08053518][r0]` into `[0x08053514]`, and dispatch `0x08053368` (`0x080534F0`).
pub fn func_080534F0() callconv(.c) void {
    if (!abi.enter(0x080534F0)) return;
    abi.fetches(15);
    abi.pushLr();
    const id = rt.r[0] & 0xFFFF;
    rt.r[0] = id;
    abi.write16(abi.read32(0x08053510), @truncate(id));
    rt.r[3] = abi.read32(0x08053514);
    rt.r[2] = abi.read32(0x08053518);
    rt.r[1] = abi.read16((id << 1) +% rt.r[2]);
    abi.write16(rt.r[3], @truncate(rt.r[1]));
    if (!abi.call(decls.func_08053368, 0x0805350B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch `0x60`-strided UI entry `(+0x30, +0x34)` via `0x08054BA8` (`0x08054840`).
pub fn func_08054840() callconv(.c) void {
    if (!abi.enter(0x08054840)) return;
    callMenuMetric54BA8(0x08054868, 0x0805486C, 0x08054863);
}

/// Dispatch `0x60`-strided UI entry `(+0x30, +0x34)` via `0x08054BA8` (`0x08055260`).
pub fn func_08055260() callconv(.c) void {
    if (!abi.enter(0x08055260)) return;
    callMenuMetric54BA8(0x08055288, 0x0805528C, 0x08055283);
}

/// Forward masked `(u16 r0, u16 r1, u16 r2)` to `0x080573B4` (`0x0805739C`).
pub fn func_0805739C() callconv(.c) void {
    if (!abi.enter(0x0805739C)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[0] &= 0xFFFF;
    rt.r[1] &= 0xFFFF;
    rt.r[2] &= 0xFFFF;
    if (!abi.call(decls.func_080573B4, 0x080573AF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Trigger UI action `0x08059E6C` (`0x08059E44`).
pub fn func_08059E44() callconv(.c) void {
    if (!abi.enter(0x08059E44)) return;
    callVoidForward(decls.func_08059E6C, 0x08059E4B);
}

/// Trigger UI action `0x0805A198` (`0x08059FFC`).
pub fn func_08059FFC() callconv(.c) void {
    if (!abi.enter(0x08059FFC)) return;
    callVoidForward(decls.func_0805A198, 0x0805A003);
}

/// Forward `u16(r0)` to `0x0805A5C4` (`0x0805A5B4`).
pub fn func_0805A5B4() callconv(.c) void {
    if (!abi.enter(0x0805A5B4)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] &= 0xFFFF;
    if (!abi.call(decls.func_0805A5C4, 0x0805A5BF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Trigger UI action `0x08061DA0` (`0x08064900`).
pub fn func_08064900() callconv(.c) void {
    if (!abi.enter(0x08064900)) return;
    callVoidForward(decls.func_08061DA0, 0x08064907);
}

/// Trigger UI action `0x08066040` (`0x08064C88`).
pub fn func_08064C88() callconv(.c) void {
    if (!abi.enter(0x08064C88)) return;
    callVoidForward(decls.func_08066040, 0x08064C8F);
}

/// Clear `[0x0806A3BC]` UI counters, set `[0x0806A3C0]+1 = 4`, and spawn `0x0806A3C4` proc (`0x0806A3A0`).
pub fn func_0806A3A0() callconv(.c) void {
    if (!abi.enter(0x0806A3A0)) return;
    abi.fetches(14);
    abi.pushLr();
    const st = abi.read32(0x0806A3BC);
    abi.write8(st, 0);
    abi.write16(st +% 2, 0);
    abi.write8(abi.read32(0x0806A3C0) +% 1, 4);
    rt.r[0] = abi.read32(0x0806A3C4);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_0801320C, 0x0806A3B9)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Return `1` if `i8(func_08013B70(0x0806A3E4)) != -1`, else `0` (`0x0806A3C8`).
pub fn func_0806A3C8() callconv(.c) void {
    if (!abi.enter(0x0806A3C8)) return;
    checkUIProc13B70Active(0x0806A3E4, 0x0806A3D1);
}

/// Pass `(u16 r0+0x24, u16 r0+0x28)` to `0x08049998` (`0x0806A8B4`).
pub fn func_0806A8B4() callconv(.c) void {
    if (!abi.enter(0x0806A8B4)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[2] = abi.read16(rt.r[0] +% 0x24);
    rt.r[1] = abi.read16(rt.r[0] +% 0x28);
    rt.r[0] = rt.r[2];
    if (!abi.call(decls.func_08049998, 0x0806A8C1)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn `0x0806A8E0` UI proc and record `(r1, r2, r0)` at `+0x24/+0x28/+0x2C` (`0x0806A8C4`).
pub fn func_0806A8C4() callconv(.c) void {
    if (!abi.enter(0x0806A8C4)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[6] = rt.r[0];
    rt.r[4] = rt.r[1];
    rt.r[5] = rt.r[2];
    rt.r[0] = abi.read32(0x0806A8E0);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_0801320C, 0x0806A8D5)) return;

    abi.fetches(8);
    abi.write32(rt.r[0] +% 0x24, rt.r[4]);
    abi.write32(rt.r[0] +% 0x28, rt.r[5]);
    abi.write32(rt.r[0] +% 0x2C, rt.r[6]);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// End `0x0806A8F0` UI proc (`0x0806A8E4`).
pub fn func_0806A8E4() callconv(.c) void {
    if (!abi.enter(0x0806A8E4)) return;
    endProcPool(0x0806A8F0, 0x0806A8ED);
}

/// Spawn `0x0806BB18` overlay proc linked to parent `r0`, initializing table ptr `+0x3C` and timer `+0x44 = 8` (`0x0806BADC`).
pub fn func_0806BADC() callconv(.c) void {
    if (!abi.enter(0x0806BADC)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[0] = abi.read32(0x0806BB18);
    abi.setRegNz(&rt.r[1], 5);
    if (!abi.call(decls.func_0801320C, 0x0806BAE9)) return;

    abi.fetches(26);
    const proc_ptr = rt.r[0];
    rt.r[3] = proc_ptr;
    abi.write32(proc_ptr +% 0x20, rt.r[4]);
    abi.write16(proc_ptr +% 0x44, 8);
    rt.r[4] = rt.r[4] +% 0x46;
    const key: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[4])));
    rt.r[1] = abi.read32(0x0806BB1C);
    abi.write32(proc_ptr +% 0x3C, abi.read32(rt.r[1] +% (key << 2)));
    abi.write16(proc_ptr +% 0x40, 0);
    rt.r[0] = key;
    rt.r[2] = 0;
    abi.setRegNz(&rt.r[5], 0);
    abi.write32(proc_ptr +% 0x2C, key);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn `0x0806BB5C` overlay proc storing parent `r0` at `+0x20` (`0x0806BB48`).
pub fn func_0806BB48() callconv(.c) void {
    if (!abi.enter(0x0806BB48)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[0] = abi.read32(0x0806BB5C);
    abi.setRegNz(&rt.r[1], 6);
    if (!abi.call(decls.func_0801320C, 0x0806BB55)) return;

    abi.fetches(6);
    abi.write32(rt.r[0] +% 0x20, rt.r[4]);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Set UI proc timers `(r0+0x1C = 1, r0+0x44 = 0x10)` and signal `0x08013BD0([0x0806BD34])` (`0x0806BD1C`).
pub fn func_0806BD1C() callconv(.c) void {
    if (!abi.enter(0x0806BD1C)) return;
    abi.fetches(12);
    abi.pushLr();
    abi.write16(rt.r[0] +% 0x1C, 1);
    abi.write16(rt.r[0] +% 0x44, 0x10);
    rt.r[1] = 0x10;
    rt.r[0] = abi.read8(abi.read32(0x0806BD34));
    if (!abi.call(decls.func_08013BD0, 0x0806BD31)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Load shifted offset `i16([0x0806BDBC][i16(r0+0x46)]) << 11` to `r0+0x2C`, zero `+0x44`, and signal `0x08013BD0` (`0x0806BD90`).
pub fn func_0806BD90() callconv(.c) void {
    if (!abi.enter(0x0806BD90)) return;
    abi.fetches(21);
    abi.pushLr();
    const key: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[0] +% 0x46)));
    const val: u32 = @bitCast(abi.signExtend16(abi.read16(abi.read32(0x0806BDBC) +% (key << 1))));
    rt.r[2] = 0;
    rt.r[1] = val << 11;
    abi.write32(rt.r[0] +% 0x2C, rt.r[1]);
    abi.write16(rt.r[0] +% 0x44, 0);
    rt.r[0] = abi.read8(abi.read32(0x0806BDC0));
    if (!abi.call(decls.func_08013BD0, 0x0806BDB7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Return `1` if `i8(func_08013B70(0x0806C278)) != -1`, else `0` (`0x0806C25C`).
pub fn func_0806C25C() callconv(.c) void {
    if (!abi.enter(0x0806C25C)) return;
    checkUIProc13B70Active(0x0806C278, 0x0806C265);
}

/// End `0x0806C374` UI proc (`0x0806C368`).
pub fn func_0806C368() callconv(.c) void {
    if (!abi.enter(0x0806C368)) return;
    endProcPool(0x0806C374, 0x0806C371);
}

/// Spawn `0x0806C93C` UI proc at priority `1` (`0x0806C92C`).
pub fn func_0806C92C() callconv(.c) void {
    if (!abi.enter(0x0806C92C)) return;
    callUIProc320C(0x0806C93C, 1, null, 0x0806C937);
}

/// Return `1` if `i8(func_08013B70(0x0806C95C)) != -1`, else `0` (`0x0806C940`).
pub fn func_0806C940() callconv(.c) void {
    if (!abi.enter(0x0806C940)) return;
    checkUIProc13B70Active(0x0806C95C, 0x0806C949);
}

/// Look up `u16([0x0806C978]+0xAC + [0x0806C97C][2]*2)` and dispatch to `0x08075808` (`0x0806C960`).
pub fn func_0806C960() callconv(.c) void {
    if (!abi.enter(0x0806C960)) return;
    abi.fetches(12);
    abi.pushLr();
    const tbl = abi.read32(0x0806C978) +% 0xAC;
    const idx: u32 = abi.read8(abi.read32(0x0806C97C) +% 2);
    rt.r[1] = tbl;
    rt.r[0] = abi.read16(tbl +% (idx << 1));
    if (!abi.call(decls.func_08075808, 0x0806C975)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Look up `u16([0x0806C998]+0xAC + [0x0806C99C][2]*2)` into `r1` and dispatch to `0x0806C6D8` (`0x0806C980`).
pub fn func_0806C980() callconv(.c) void {
    if (!abi.enter(0x0806C980)) return;
    abi.fetches(12);
    abi.pushLr();
    const tbl = abi.read32(0x0806C998) +% 0xAC;
    const idx: u32 = abi.read8(abi.read32(0x0806C99C) +% 2);
    rt.r[2] = tbl;
    rt.r[1] = abi.read16(tbl +% (idx << 1));
    rt.r[0] = idx;
    if (!abi.call(decls.func_0806C6D8, 0x0806C995)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn callUI6CB50(comptime ptr_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(ptr_ref);
    if (!abi.call(decls.func_0806CB50, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn callUI6CF28(comptime ptr_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[1] = abi.read32(ptr_ref);
    if (!abi.call(decls.func_0806CF28, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn spawnProcOffsetSet1E(comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(def_ref);
    abi.setRegNz(&rt.r[1], 3);
    if (!abi.call(decls.func_0801320C, ret_addr)) return;

    abi.fetches(11);
    abi.write32(rt.r[0] +% 0x28, 0x1E);
    abi.write32(rt.r[0] +% 0x2C, @bitCast(@as(i32, -1)));
    abi.write16(rt.r[0] +% 0x44, 0xE);
    rt.r[0] +%= 0x44;
    abi.setRegNz(&rt.r[1], 0xE);
    abi.popReturn();
}

fn setByteFlagSpawnUI320C(comptime flag_ref: u32, comptime flag_val: u8, comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(10);
    abi.pushLr();
    abi.write8(abi.read32(flag_ref), flag_val);
    rt.r[0] = abi.read32(def_ref);
    abi.setRegNz(&rt.r[1], 2);
    if (!abi.call(decls.func_0801320C, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn setUIWait114B0(comptime wait_neg: u32, comptime status_val: u16, comptime ret_addr: u32) void {
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[0] = @as(u32, 0) -% wait_neg;
    if (!abi.call(decls.func_080114B0, ret_addr)) return;

    abi.fetches(8);
    rt.r[4] +%= 0x44;
    abi.setRegNz(&rt.r[0], status_val);
    abi.write16(rt.r[4], status_val);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn `0x08042D98` UI proc (`0x08042D88`).
pub fn func_08042D88() callconv(.c) void {
    if (!abi.enter(0x08042D88)) return;
    spawnProcZero(0x08042D98, 0x08042D93);
}

/// Spawn `0x08042DE4` UI proc (`0x08042DD4`).
pub fn func_08042DD4() callconv(.c) void {
    if (!abi.enter(0x08042DD4)) return;
    spawnProcZero(0x08042DE4, 0x08042DDF);
}

/// Spawn `0x0806E2D0` UI proc and trigger `0x0806DE20` using parent `+0x28` and `+0x1C` (`0x0806E2B0`).
pub fn func_0806E2B0() callconv(.c) void {
    if (!abi.enter(0x0806E2B0)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[4] = rt.r[0];
    rt.r[0] = abi.read32(0x0806E2D0);
    abi.setRegNz(&rt.r[1], 3);
    if (!abi.call(decls.func_0801320C, 0x0806E2BD)) return;

    abi.fetches(9);
    rt.r[1] = @as(u32, @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x28)))) +% 8;
    rt.r[2] = abi.read16(rt.r[4] +% 0x1C);
    rt.r[3] = rt.r[2] << 1;
    if (!abi.call(decls.func_0806DE20, 0x0806E2CB)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn `0x0806E948` UI proc with signed offsets `(0x1E, -1, 0xE)` (`0x0806E92C`).
pub fn func_0806E92C() callconv(.c) void {
    if (!abi.enter(0x0806E92C)) return;
    spawnProcOffsetSet1E(0x0806E948, 0x0806E937);
}

/// Dispatch `0x0806E958` via `0x0806CB50` (`0x0806E94C`).
pub fn func_0806E94C() callconv(.c) void {
    if (!abi.enter(0x0806E94C)) return;
    callUI6CB50(0x0806E958, 0x0806E955);
}

/// Dispatch `0x0806F194` via `0x0806CF28` (`0x0806F188`).
pub fn func_0806F188() callconv(.c) void {
    if (!abi.enter(0x0806F188)) return;
    callUI6CF28(0x0806F194, 0x0806F191);
}

/// Dispatch `0x0806F1A4` via `0x0806CF28` (`0x0806F198`).
pub fn func_0806F198() callconv(.c) void {
    if (!abi.enter(0x0806F198)) return;
    callUI6CF28(0x0806F1A4, 0x0806F1A1);
}

/// Dispatch `0x0806F434` via `0x0806CF28` (`0x0806F428`).
pub fn func_0806F428() callconv(.c) void {
    if (!abi.enter(0x0806F428)) return;
    callUI6CF28(0x0806F434, 0x0806F431);
}

/// Dispatch `0x0806F444` via `0x0806CF28` (`0x0806F438`).
pub fn func_0806F438() callconv(.c) void {
    if (!abi.enter(0x0806F438)) return;
    callUI6CF28(0x0806F444, 0x0806F441);
}

/// Spawn `0x0806F7C8` slot `r0` UI proc at `(r1, r2)` and register pointer/tag in `[0x0806F7CC]` (`0x0806F794`).
pub fn func_0806F794() callconv(.c) void {
    if (!abi.enter(0x0806F794)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[5] = rt.r[1];
    rt.r[6] = rt.r[2];
    rt.r[0] = abi.read32(0x0806F7C8);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_0801320C, 0x0806F7A5)) return;

    abi.fetches(19);
    abi.write16(rt.r[0] +% 0x28, @truncate(rt.r[5]));
    abi.write16(rt.r[0] +% 0x2A, @truncate(rt.r[6]));
    abi.write16(rt.r[0] +% 0x1C, @truncate(rt.r[4]));
    const st = abi.read32(abi.read32(0x0806F7CC));
    rt.r[1] = st +% 0x78 +% (rt.r[4] << 2);
    abi.write32(rt.r[1], rt.r[0]);
    rt.r[2] = st +% 0x74 +% rt.r[4];
    abi.setRegNz(&rt.r[0], 0xFF);
    abi.write8(rt.r[2], 0xFF);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear `[0x08070280] = 0` and spawn `0x08070284` UI proc (`0x0807026C`).
pub fn func_0807026C() callconv(.c) void {
    if (!abi.enter(0x0807026C)) return;
    setByteFlagSpawnUI320C(0x08070280, 0, 0x08070284, 0x0807027D);
}

/// Set `[0x0807029C] = 1` and spawn `0x080702A0` UI proc (`0x08070288`).
pub fn func_08070288() callconv(.c) void {
    if (!abi.enter(0x08070288)) return;
    setByteFlagSpawnUI320C(0x0807029C, 1, 0x080702A0, 0x08070299);
}

/// Return `1` if `i8(func_08013B70(0x080702C0)) != -1`, else `0` (`0x080702A4`).
pub fn func_080702A4() callconv(.c) void {
    if (!abi.enter(0x080702A4)) return;
    checkUIProc13B70Active(0x080702C0, 0x080702AD);
}

/// Call `0x080114B0(-2)` and set `u16(r0+0x44) = 0x10` (`0x08070EB8`).
pub fn func_08070EB8() callconv(.c) void {
    if (!abi.enter(0x08070EB8)) return;
    setUIWait114B0(2, 0x10, 0x08070EC5);
}

/// Spawn `0x0807117C` UI proc at `(r0, r1, r2)` (`0x08071158`).
pub fn func_08071158() callconv(.c) void {
    if (!abi.enter(0x08071158)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[5] = rt.r[1];
    rt.r[6] = rt.r[2];
    rt.r[0] = abi.read32(0x0807117C);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08071169)) return;

    abi.fetches(11);
    abi.write32(rt.r[0] +% 0x24, rt.r[4]);
    abi.write32(rt.r[0] +% 0x28, rt.r[5]);
    rt.r[1] = abi.read32(0x08071180);
    abi.write32(rt.r[0] +% 0x3C, rt.r[1]);
    rt.r[0] +%= 0x40;
    abi.write16(rt.r[0], @truncate(rt.r[6]));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn `0x08071384` UI proc at `(r0, r1, r2, r3)` (`0x08071350`).
pub fn func_08071350() callconv(.c) void {
    if (!abi.enter(0x08071350)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[6] = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);

    rt.r[4] = rt.r[0];
    rt.r[5] = rt.r[1];
    rt.r[6] = rt.r[2];
    rt.r[8] = rt.r[3];
    rt.r[0] = abi.read32(0x08071384);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08071367)) return;

    abi.fetches(17);
    abi.write32(rt.r[0] +% 0x24, rt.r[4]);
    abi.write32(rt.r[0] +% 0x28, rt.r[5]);
    rt.r[1] = abi.read32(0x08071388);
    abi.write32(rt.r[0] +% 0x3C, rt.r[1]);
    abi.write16(rt.r[0] +% 0x40, @truncate(rt.r[6]));
    rt.r[0] +%= 0x46;
    rt.r[1] = rt.r[8];
    abi.write16(rt.r[0], @truncate(rt.r[1]));
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

/// Reset UI screens via `0x0806CDD0(0)` and `0x0806CD78(0)` (`0x08072130`).
pub fn func_08072130() callconv(.c) void {
    if (!abi.enter(0x08072130)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_0806CDD0, 0x08072139)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_0806CD78, 0x0807213F)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Signal UI proc `[0x08073000]` via `0x08013BD0` (`0x08072FF0`).
pub fn func_08072FF0() callconv(.c) void {
    if (!abi.enter(0x08072FF0)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read8(abi.read32(0x08073000));
    if (!abi.call(decls.func_08013BD0, 0x08072FFB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Set `u16(r0+0x44) = 0x20` and clear `0x0801163C(1)` (`0x0807388C`).
pub fn func_0807388C() callconv(.c) void {
    if (!abi.enter(0x0807388C)) return;
    abi.fetches(9);
    abi.pushLr();
    abi.write16(rt.r[0] +% 0x44, 0x20);
    abi.setRegNz(&rt.r[1], 0x20);
    abi.setRegNz(&rt.r[0], 1);
    if (!abi.call(decls.func_0801163C, 0x0807389B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch `0x08073B04` via `0x0806CB50` (`0x08073AF8`).
pub fn func_08073AF8() callconv(.c) void {
    if (!abi.enter(0x08073AF8)) return;
    callUI6CB50(0x08073B04, 0x08073B01);
}

/// Dismiss UI menu via `0x08075A90` and signal `[0x08073C64]` via `0x08013BD0` (`0x08073C50`).
pub fn func_08073C50() callconv(.c) void {
    if (!abi.enter(0x08073C50)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08075A90, 0x08073C57)) return;

    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x08073C64));
    if (!abi.call(decls.func_08013BD0, 0x08073C5F)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Initialize audio via `0x0803D920`, clear `[0x08073CC0]`, and spawn `0x08073CC4` (`0x08073CA8`).
pub fn func_08073CA8() callconv(.c) void {
    if (!abi.enter(0x08073CA8)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0803D920, 0x08073CAF)) return;

    abi.fetches(9);
    abi.write8(abi.read32(0x08073CC0), 0);
    rt.r[0] = abi.read32(0x08073CC4);
    abi.setRegNz(&rt.r[1], 2);
    if (!abi.call(decls.func_0801320C, 0x08073CBD)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Return `1` if `i8(func_08013B70(0x08073CE4)) != -1`, else `0` (`0x08073CC8`).
pub fn func_08073CC8() callconv(.c) void {
    if (!abi.enter(0x08073CC8)) return;
    checkUIProc13B70Active(0x08073CE4, 0x08073CD1);
}

/// Reset UI via `0x0801163C(1)` and set `u16(r0+0x44) = 8` (`0x08073E6C`).
pub fn func_08073E6C() callconv(.c) void {
    if (!abi.enter(0x08073E6C)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[4] = rt.r[0];
    abi.setRegNz(&rt.r[0], 1);
    if (!abi.call(decls.func_0801163C, 0x08073E77)) return;

    abi.fetches(8);
    rt.r[4] +%= 0x44;
    abi.setRegNz(&rt.r[0], 8);
    abi.write16(rt.r[4], 8);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Return `1` if `i8(func_08013B70(0x080742DC)) != -1`, else `0` (`0x080742C0`).
pub fn func_080742C0() callconv(.c) void {
    if (!abi.enter(0x080742C0)) return;
    checkUIProc13B70Active(0x080742DC, 0x080742C9);
}

/// Call `0x080114B0(-1)` and set `u16(r0+0x44) = 0x80` (`0x08074C34`).
pub fn func_08074C34() callconv(.c) void {
    if (!abi.enter(0x08074C34)) return;
    setUIWait114B0(1, 0x80, 0x08074C41);
}

/// Dispatch `0x08075190` via `0x0806CB50` (`0x08075184`).
pub fn func_08075184() callconv(.c) void {
    if (!abi.enter(0x08075184)) return;
    callUI6CB50(0x08075190, 0x0807518D);
}

/// Return `1` if `i8(func_08013B70(0x080754F0)) != -1`, else `0` (`0x080754D4`).
pub fn func_080754D4() callconv(.c) void {
    if (!abi.enter(0x080754D4)) return;
    checkUIProc13B70Active(0x080754F0, 0x080754DD);
}

/// Fade screen via `0x080113E8([0x08075570], 9, 1, 1)` and zero `r0+0x1C/+0x44` (`0x08075550`).
pub fn func_08075550() callconv(.c) void {
    if (!abi.enter(0x08075550)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[0] = abi.read32(0x08075570);
    abi.setRegNz(&rt.r[1], 9);
    abi.setRegNz(&rt.r[2], 1);
    abi.setRegNz(&rt.r[3], 1);
    if (!abi.call(decls.func_080113E8, 0x08075561)) return;

    abi.fetches(9);
    abi.setRegNz(&rt.r[0], 0);
    abi.write16(rt.r[4] +% 0x1C, 0);
    rt.r[4] +%= 0x44;
    abi.write16(rt.r[4], 0);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Call `0x080114B0(-1)` and set `u16(r0+0x44) = 0x20` (`0x08075914`).
pub fn func_08075914() callconv(.c) void {
    if (!abi.enter(0x08075914)) return;
    setUIWait114B0(1, 0x20, 0x08075921);
}

/// Clear `u16([0x08075AA4]) = 0` and spawn `0x08075AA8` UI proc (`0x08075A90`).
pub fn func_08075A90() callconv(.c) void {
    if (!abi.enter(0x08075A90)) return;
    abi.fetches(10);
    abi.pushLr();
    abi.write16(abi.read32(0x08075AA4), 0);
    rt.r[0] = abi.read32(0x08075AA8);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_0801320C, 0x08075AA1)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Return `1` if `i8(func_08013B70(0x08075AC8)) != -1`, else `0` (`0x08075AAC`).
pub fn func_08075AAC() callconv(.c) void {
    if (!abi.enter(0x08075AAC)) return;
    checkUIProc13B70Active(0x08075AC8, 0x08075AB5);
}

/// Spawn `0x08076930` UI proc with signed offsets `(0x1E, -1, 0xE)` (`0x08076914`).
pub fn func_08076914() callconv(.c) void {
    if (!abi.enter(0x08076914)) return;
    spawnProcOffsetSet1E(0x08076930, 0x0807691F);
}

/// Dispatch `0x08076940` via `0x0806CB50` (`0x08076934`).
pub fn func_08076934() callconv(.c) void {
    if (!abi.enter(0x08076934)) return;
    callUI6CB50(0x08076940, 0x0807693D);
}

/// Forward UI close via `0x0806A8E4` (`0x0807753C`).
pub fn func_0807753C() callconv(.c) void {
    if (!abi.enter(0x0807753C)) return;
    callVoidForward(decls.func_0806A8E4, 0x08077543);
}

/// Clear `[0x0807755C] = 0` and spawn `0x08077560` UI proc (`0x08077548`).
pub fn func_08077548() callconv(.c) void {
    if (!abi.enter(0x08077548)) return;
    setByteFlagSpawnUI320C(0x0807755C, 0, 0x08077560, 0x08077559);
}

/// Set `[0x08077578] = 1` and spawn `0x0807757C` UI proc (`0x08077564`).
pub fn func_08077564() callconv(.c) void {
    if (!abi.enter(0x08077564)) return;
    setByteFlagSpawnUI320C(0x08077578, 1, 0x0807757C, 0x08077575);
}

/// Return `1` if `i8(func_08013B70(0x0807759C)) != -1`, else `0` (`0x08077580`).
pub fn func_08077580() callconv(.c) void {
    if (!abi.enter(0x08077580)) return;
    checkUIProc13B70Active(0x0807759C, 0x08077589);
}

fn popReturnR1Ui() void {
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

fn setBgPrioritiesAndSync(
    comptime r0_ref: u32,
    comptime r1_ref: u32,
    comptime r2_ref: u32,
    comptime r3_ref: u32,
    comptime bg1_prio: u8,
    comptime bg2_prio: u8,
    comptime ret1: u32,
    comptime ret2: u32,
) void {
    abi.fetches(30);
    abi.pushLr();
    const mask: u8 = ~@as(u8, 3);
    const p0 = abi.read32(r0_ref);
    abi.write8(p0, abi.read8(p0) & mask);
    const p1 = abi.read32(r1_ref);
    abi.write8(p1, (abi.read8(p1) & mask) | bg1_prio);
    const p2 = abi.read32(r2_ref);
    const old_b2 = abi.read8(p2);
    abi.write8(p2, (old_b2 & mask) | bg2_prio);
    const p3 = abi.read32(r3_ref);
    const old_b3 = abi.read8(p3);
    abi.write8(p3, old_b3 | 3);
    rt.r[1] = p3;
    rt.r[2] = old_b3;
    rt.r[3] = old_b2;
    abi.setRegNz(&rt.r[0], old_b3 | 3);
    if (!abi.call(decls.func_080104B0, ret1)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080104D4, ret2)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn setActiveCursorModeAndNotify(comptime flag: u32, comptime ret1: u32, comptime ret2: u32) void {
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const id = rt.r[0] & 0xFF;
    rt.updateNz(id);
    rt.r[4] = id;
    rt.r[0] = id;
    if (!abi.call(func_08026118, ret1)) return;
    abi.fetches(6);
    rt.r[0] = id;
    abi.setRegNz(&rt.r[1], flag);
    if (!abi.call(decls.func_0802CF04, ret2)) return;
    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn sumDualMapChecks(comptime ret1: u32, comptime ret2: u32) void {
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_arg = rt.r[0];
    rt.r[5] = saved_arg;
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_08029C1C, ret1)) return;

    abi.fetches(7);
    const first_res = rt.r[0];
    rt.r[4] = first_res;
    rt.r[0] = saved_arg;
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_08029CEC, ret2)) return;

    abi.fetches(7);
    abi.setRegNz(&rt.r[0], first_res +% rt.r[0]);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnR1Ui();
}

fn syncUi25C70AndSpawn(comptime proc_ref: u32, comptime ret1: u32, comptime ret2: u32) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08025C70, ret1)) return;
    abi.fetches(6);
    rt.r[0] = abi.read32(proc_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, ret2)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear 4 UI dialogue tilemap entries (`0x174`) and cursor tiles, then finish via `0x0807B44C` (`0x0801862C`).
pub fn func_0801862C() callconv(.c) void {
    if (!abi.enter(0x0801862C)) return;
    abi.fetches(32);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const obj = rt.r[0];
    const base = abi.read32(obj +% 0x18);
    const blank: u16 = 0xBA << 1;
    abi.write16(base, blank);
    abi.write16(base +% 0x40, blank);
    abi.write16(base +% 8, blank);
    abi.write16(base +% 0x48, blank);

    const row = @as(u32, @bitCast(abi.signExtend16(abi.read16(obj +% 0x1E)))) << 3;
    const t0: u16 = @truncate(abi.read32(0x08018670));
    const t1: u16 = @truncate(abi.read32(0x08018674));
    abi.write16(base +% row, t0);
    abi.write16(base +% row +% 0x40, t1);
    rt.r[4] = abi.read32(0x08018670);
    rt.r[0] = abi.read32(obj +% 0x2C);
    if (!abi.call(decls.func_0807B44C, 0x08018669)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Upload dialogue portrait tiles `0x08012A68` and redraw window via `func_0801862C` (`0x08018678`).
pub fn func_08018678() callconv(.c) void {
    if (!abi.enter(0x08018678)) return;
    abi.fetches(17);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;
    const obj = rt.r[0];
    rt.r[4] = obj;
    const param = (@as(u32, abi.read8(abi.read32(0x080186A8))) << 28) >> 16;
    abi.write32(rt.r[13], param);
    abi.write32(rt.r[13] +% 4, 0);
    rt.r[0] = 0;
    rt.r[1] = 0;
    rt.r[2] = abi.read32(obj +% 0x18);
    rt.r[3] = abi.read32(0x080186A4);
    if (!abi.call(decls.func_08012A68, 0x08018697)) return;

    abi.fetches(5);
    rt.r[0] = obj;
    if (!abi.call(func_0801862C, 0x0801869D)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Set cursor state `[0x08018C38] + 1..2 = (r1, r2)`, play transition `0x08035220`, bind `r0` after `0x08018400` (`0x08018C1C`).
pub fn func_08018C1C() callconv(.c) void {
    if (!abi.enter(0x08018C1C)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved = rt.r[0];
    rt.r[4] = saved;
    const dst = abi.read32(0x08018C38);
    abi.write8(dst +% 1, @truncate(rt.r[1]));
    abi.write8(dst +% 2, @truncate(rt.r[2]));
    if (!abi.call(decls.func_08035220, 0x08018C2B)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x08018C3C);
    if (!abi.call(decls.func_08018400, 0x08018C31)) return;

    abi.fetches(6);
    abi.write32(rt.r[0] +% 0x14, saved);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Store callback/state `r0` at `[0x08018CB0]` (`0x08018CA8`).
pub fn func_08018CA8() callconv(.c) void {
    if (!abi.enter(0x08018CA8)) return;
    abi.fetches(5);
    const dst = abi.read32(0x08018CB0);
    abi.write32(dst, rt.r[0]);
    rt.r[1] = dst;
    abi.retLr();
}

/// Initialize overlay via `0x08019168`, clear tilebox `0x08010C70`, and bind layer `2` (`0x08019194`).
pub fn func_08019194() callconv(.c) void {
    if (!abi.enter(0x08019194)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 8;
    if (!abi.call(decls.func_08019168, 0x0801919D)) return;

    abi.fetches(12);
    abi.write32(rt.r[13], 0x14);
    abi.write32(rt.r[13] +% 4, abi.read32(0x080191C0));
    rt.r[0] = abi.read32(0x080191BC);
    rt.r[1] = 0;
    rt.r[2] = 0;
    abi.setRegNz(&rt.r[3], 0x20);
    if (!abi.call(decls.func_08010C70, 0x080191B1)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 2);
    if (!abi.call(decls.func_080117EC, 0x080191B7)) return;

    abi.fetches(5);
    rt.r[13] +%= 8;
    abi.popReturn();
}

/// Interpolate dialogue cursor field `+0x1E` and reposition via `func_08020CDC` (`0x08019208`).
pub fn func_08019208() callconv(.c) void {
    if (!abi.enter(0x08019208)) return;
    abi.fetches(31);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const obj = rt.r[0];
    const base_v = abi.read16(obj +% 0x26);
    const delta = @as(u32, @bitCast(abi.signExtend16(abi.read16(obj +% 0x22))));
    const target_s: u32 = @bitCast(abi.signExtend16(@truncate(base_v +% 0x10 +% (delta << 5))));
    const cur_s: u32 = @bitCast(abi.signExtend16(abi.read16(obj +% 0x1E)));
    const sum: u32 = target_s +% cur_s;
    const avg: u32 = (sum +% (sum >> 31)) >> 1;
    abi.write16(obj +% 0x1E, @truncate(avg));

    const arg0: u32 = @bitCast(abi.signExtend16(abi.read16(obj +% 0x24)));
    const arg1: u32 = @bitCast(abi.signExtend16(@truncate(base_v +% (delta << 4))));
    rt.r[0] = arg0;
    rt.r[1] = arg1;
    abi.setRegNz(&rt.r[2], 3);
    rt.r[3] = delta << 4;
    rt.r[4] = 0x22;
    if (!abi.call(func_08020CDC, 0x08019243)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Reset HUD sprites `0x08018E38` and configure BG priority order via `func_080220F8` (`0x080198FC`).
pub fn func_080198FC() callconv(.c) void {
    if (!abi.enter(0x080198FC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08018E38, 0x08019903)) return;
    abi.fetches(4);
    if (!abi.call(func_080220F8, 0x08019907)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Scroll BG window `0x0802C11C` vertically and horizontally from pair `[0x0801F054]` (`0x0801F034`).
pub fn func_0801F034() callconv(.c) void {
    if (!abi.enter(0x0801F034)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const pair = abi.read32(0x0801F054);
    rt.r[4] = pair;
    abi.setRegNz(&rt.r[0], 0xD0);
    abi.setRegNz(&rt.r[1], 0);
    rt.r[2] = abi.read16(pair);
    if (!abi.call(decls.func_0802C11C, 0x0801F043)) return;

    abi.fetches(7);
    abi.setRegNz(&rt.r[0], 0xE0);
    abi.setRegNz(&rt.r[1], 0);
    rt.r[2] = abi.read16(pair +% 2);
    if (!abi.call(decls.func_0802C11C, 0x0801F04D)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// DMA UI palette `0x0800FFA8([0x08020374], [0x08020378], 0x20)` and refresh tile state `0x0801990C` (`0x0802035C`).
pub fn func_0802035C() callconv(.c) void {
    if (!abi.enter(0x0802035C)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08020374);
    rt.r[1] = abi.read32(0x08020378);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_0800FFA8, 0x08020369)) return;
    abi.fetches(6);
    rt.r[0] = abi.read16(abi.read32(0x0802037C));
    if (!abi.call(decls.func_0801990C, 0x08020371)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Project world/tile coords `(r0, r1, r2)` via `0x08020B7C` and apply via `0x08020B48` (`0x08020CDC`).
pub fn func_08020CDC() callconv(.c) void {
    if (!abi.enter(0x08020CDC)) return;
    abi.fetches(18);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const a2: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[2])));
    const out_y = rt.r[13] +% 6;
    const out_x = rt.r[13] +% 4;
    abi.write32(rt.r[13], out_y);
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(rt.r[1])));
    rt.r[2] = a2;
    rt.r[3] = out_x;
    rt.r[4] = a2;
    rt.r[5] = out_y;
    if (!abi.call(decls.func_08020B7C, 0x08020CFD)) return;

    abi.fetches(12);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(out_x)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(out_y)));
    rt.r[2] = a2;
    if (!abi.call(decls.func_08020B48, 0x08020D0D)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Set BG priorities `(0, 1, 2, 3)` and commit DISPCNT/WIN via `0x080104B0`/`0x080104D4` (`0x08021F78`).
pub fn func_08021F78() callconv(.c) void {
    if (!abi.enter(0x08021F78)) return;
    setBgPrioritiesAndSync(0x08021FB8, 0x08021FBC, 0x08021FC0, 0x08021FC4, 1, 2, 0x08021FB1, 0x08021FB5);
}

/// Set BG priorities `(0, 2, 1, 3)` and commit DISPCNT/WIN via `0x080104B0`/`0x080104D4` (`0x080220F8`).
pub fn func_080220F8() callconv(.c) void {
    if (!abi.enter(0x080220F8)) return;
    setBgPrioritiesAndSync(0x08022138, 0x0802213C, 0x08022140, 0x08022144, 2, 1, 0x08022131, 0x08022135);
}

/// Set BG priorities `(0, 2, 1, 3)` (variant B) and commit DISPCNT/WIN via `0x080104B0`/`0x080104D4` (`0x080221D0`).
pub fn func_080221D0() callconv(.c) void {
    if (!abi.enter(0x080221D0)) return;
    setBgPrioritiesAndSync(0x08022210, 0x08022214, 0x08022218, 0x0802221C, 2, 1, 0x08022209, 0x0802220D);
}

/// Clear/reset UI panel pair `[0x080238C8]` and `[0x080238CC]` via `0x080238B0` (`0x080238B4`).
pub fn func_080238B4() callconv(.c) void {
    if (!abi.enter(0x080238B4)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x080238C8);
    if (!abi.call(decls.func_080238B0, 0x080238BD)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x080238CC);
    if (!abi.call(decls.func_080238B0, 0x080238C3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Sync cursor `(x, y)` from `[0x0802613C]` into `*[0x08026138]` and refresh `0x08023EDC` (`0x08026118`).
pub fn func_08026118() callconv(.c) void {
    if (!abi.enter(0x08026118)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08026020, 0x0802611F)) return;
    abi.fetches(12);
    const dst = abi.read32(abi.read32(0x08026138));
    const src = abi.read32(0x0802613C);
    abi.write8(dst +% 2, @truncate(abi.read16(src)));
    abi.write8(dst +% 3, @truncate(abi.read16(src +% 2)));
    if (!abi.call(decls.func_08023EDC, 0x08026133)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Snap cursor and notify `0x0802CF04(u8(r0), 1)` (`0x08026140`).
pub fn func_08026140() callconv(.c) void {
    if (!abi.enter(0x08026140)) return;
    setActiveCursorModeAndNotify(1, 0x0802614D, 0x08026155);
}

/// Snap cursor and notify `0x0802CF04(u8(r0), 0)` (`0x0802615C`).
pub fn func_0802615C() callconv(.c) void {
    if (!abi.enter(0x0802615C)) return;
    setActiveCursorModeAndNotify(0, 0x08026169, 0x08026171);
}

/// Play confirm cue `0x6D`, update flag `0x080136A4(i8(*(*[0x08027618])+0xA), 1)`, attach handler `[0x0802761C]` (`0x080275EC`).
pub fn func_080275EC() callconv(.c) void {
    if (!abi.enter(0x080275EC)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved = rt.r[0];
    rt.r[4] = saved;
    abi.setRegNz(&rt.r[0], 0x6D);
    if (!abi.call(decls.func_0803D880, 0x080275F7)) return;

    abi.fetches(10);
    const val: u32 = @bitCast(abi.signExtend8(abi.read8(abi.read32(abi.read32(0x08027618)) +% 0xA)));
    rt.r[0] = val;
    rt.updateNz(val);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_080136A4, 0x08027607)) return;

    abi.fetches(7);
    rt.r[1] = abi.read32(0x0802761C);
    abi.write32(saved +% 8, rt.r[1]);
    rt.r[0] = saved;
    if (!abi.call(decls.func_0807B450, 0x08027611)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down BG layers (`0x08011910`, `0x08011804`) and restore `(0, 2, 1, 3)` priority (`0x08027F30`).
pub fn func_08027F30() callconv(.c) void {
    if (!abi.enter(0x08027F30)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08011910, 0x08027F37)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011804, 0x08027F3B)) return;
    abi.fetches(4);
    if (!abi.call(func_080220F8, 0x08027F3F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Sum `0x08029C1C(r0, 0) + 0x08029CEC(r0, 0)` (`0x0802A064`).
pub fn func_0802A064() callconv(.c) void {
    if (!abi.enter(0x0802A064)) return;
    sumDualMapChecks(0x0802A06F, 0x0802A079);
}

/// Sum `0x08029C1C(r0, 0) + 0x08029CEC(r0, 0)` (duplicate callsite `0x0802A784`).
pub fn func_0802A784() callconv(.c) void {
    if (!abi.enter(0x0802A784)) return;
    sumDualMapChecks(0x0802A78F, 0x0802A799);
}

/// Render tile block via `0x0801B888` and upload `0x80`-byte palette via `0x0800FFA8` (`0x0802BCA8`).
pub fn func_0802BCA8() callconv(.c) void {
    if (!abi.enter(0x0802BCA8)) return;
    abi.fetches(24);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const slot_scaled = (rt.r[2] << 16) >> 14;
    rt.r[4] = slot_scaled;
    rt.r[5] = abi.read32(0x0802BCF0);
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    rt.r[1] = @as(u32, @bitCast(abi.signExtend16(@truncate(rt.r[1])))) | 0x400;
    rt.r[2] = abi.read32(abi.read32(0x0802BCEC) +% 4);
    rt.r[3] = (slot_scaled | rt.r[5]) & 0xFFFF;
    rt.updateNz(rt.r[3]);
    if (!abi.call(decls.func_0801B888, 0x0802BCD5)) return;

    abi.fetches(10);
    rt.r[0] = abi.read32(0x0802BCF4);
    const pal_dst = (slot_scaled << 5) +% abi.read32(0x0802BCF8);
    rt.r[4] = pal_dst;
    rt.r[1] = pal_dst;
    abi.setRegNz(&rt.r[2], 0x80);
    if (!abi.call(decls.func_0800FFA8, 0x0802BCE5)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Sync cursor `0x08025C70` and spawn UI proc `[0x0802C8AC]` (`0x0802C898`).
pub fn func_0802C898() callconv(.c) void {
    if (!abi.enter(0x0802C898)) return;
    syncUi25C70AndSpawn(0x0802C8AC, 0x0802C89F, 0x0802C8A7);
}

/// Sync cursor `0x08025C70` and spawn UI proc `[0x0802C8C4]` (`0x0802C8B0`).
pub fn func_0802C8B0() callconv(.c) void {
    if (!abi.enter(0x0802C8B0)) return;
    syncUi25C70AndSpawn(0x0802C8C4, 0x0802C8B7, 0x0802C8BF);
}

/// Refresh tactical overlay `0x08020D6C` and clear UI state `0x080381C4` (`0x0802C8C8`).
pub fn func_0802C8C8() callconv(.c) void {
    if (!abi.enter(0x0802C8C8)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08020D6C, 0x0802C8CF)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080381C4, 0x0802C8D3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Finalize range display (`0x080237C0`, `0x08023EDC`), set flag `[0x0802C8F0] = 1`, sync via `0x08035230` (`0x0802C8D8`).
pub fn func_0802C8D8() callconv(.c) void {
    if (!abi.enter(0x0802C8D8)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080237C0, 0x0802C8DF)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08023EDC, 0x0802C8E3)) return;
    abi.fetches(7);
    const dst = abi.read32(0x0802C8F0);
    abi.write8(dst, 1);
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], 1);
    if (!abi.call(decls.func_08035230, 0x0802C8ED)) return;
    abi.fetches(4);
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08018DE4, .{ .name = "func_08018DE4", .linkage = .strong });
        @export(&func_08042D88, .{ .name = "func_08042D88", .linkage = .strong });
        @export(&func_08042DD4, .{ .name = "func_08042DD4", .linkage = .strong });
        @export(&func_0806E2B0, .{ .name = "func_0806E2B0", .linkage = .strong });
        @export(&func_0806E92C, .{ .name = "func_0806E92C", .linkage = .strong });
        @export(&func_0806E94C, .{ .name = "func_0806E94C", .linkage = .strong });
        @export(&func_0806F188, .{ .name = "func_0806F188", .linkage = .strong });
        @export(&func_0806F198, .{ .name = "func_0806F198", .linkage = .strong });
        @export(&func_0806F428, .{ .name = "func_0806F428", .linkage = .strong });
        @export(&func_0806F438, .{ .name = "func_0806F438", .linkage = .strong });
        @export(&func_0806F794, .{ .name = "func_0806F794", .linkage = .strong });
        @export(&func_0807026C, .{ .name = "func_0807026C", .linkage = .strong });
        @export(&func_08070288, .{ .name = "func_08070288", .linkage = .strong });
        @export(&func_080702A4, .{ .name = "func_080702A4", .linkage = .strong });
        @export(&func_08070EB8, .{ .name = "func_08070EB8", .linkage = .strong });
        @export(&func_08071158, .{ .name = "func_08071158", .linkage = .strong });
        @export(&func_08071350, .{ .name = "func_08071350", .linkage = .strong });
        @export(&func_08072130, .{ .name = "func_08072130", .linkage = .strong });
        @export(&func_08072FF0, .{ .name = "func_08072FF0", .linkage = .strong });
        @export(&func_0807388C, .{ .name = "func_0807388C", .linkage = .strong });
        @export(&func_08073AF8, .{ .name = "func_08073AF8", .linkage = .strong });
        @export(&func_08073C50, .{ .name = "func_08073C50", .linkage = .strong });
        @export(&func_08073CA8, .{ .name = "func_08073CA8", .linkage = .strong });
        @export(&func_08073CC8, .{ .name = "func_08073CC8", .linkage = .strong });
        @export(&func_08073E6C, .{ .name = "func_08073E6C", .linkage = .strong });
        @export(&func_080742C0, .{ .name = "func_080742C0", .linkage = .strong });
        @export(&func_08074C34, .{ .name = "func_08074C34", .linkage = .strong });
        @export(&func_08075184, .{ .name = "func_08075184", .linkage = .strong });
        @export(&func_080754D4, .{ .name = "func_080754D4", .linkage = .strong });
        @export(&func_08075550, .{ .name = "func_08075550", .linkage = .strong });
        @export(&func_08075914, .{ .name = "func_08075914", .linkage = .strong });
        @export(&func_08075A90, .{ .name = "func_08075A90", .linkage = .strong });
        @export(&func_08075AAC, .{ .name = "func_08075AAC", .linkage = .strong });
        @export(&func_08076914, .{ .name = "func_08076914", .linkage = .strong });
        @export(&func_08076934, .{ .name = "func_08076934", .linkage = .strong });
        @export(&func_0807753C, .{ .name = "func_0807753C", .linkage = .strong });
        @export(&func_08077548, .{ .name = "func_08077548", .linkage = .strong });
        @export(&func_08077564, .{ .name = "func_08077564", .linkage = .strong });
        @export(&func_08077580, .{ .name = "func_08077580", .linkage = .strong });
        @export(&func_0804F824, .{ .name = "func_0804F824", .linkage = .strong });
        @export(&func_08050554, .{ .name = "func_08050554", .linkage = .strong });
        @export(&func_08050620, .{ .name = "func_08050620", .linkage = .strong });
        @export(&func_08050C70, .{ .name = "func_08050C70", .linkage = .strong });
        @export(&func_08050EA0, .{ .name = "func_08050EA0", .linkage = .strong });
        @export(&func_08051874, .{ .name = "func_08051874", .linkage = .strong });
        @export(&func_08051C1C, .{ .name = "func_08051C1C", .linkage = .strong });
        @export(&func_08051CD8, .{ .name = "func_08051CD8", .linkage = .strong });
        @export(&func_08051CF8, .{ .name = "func_08051CF8", .linkage = .strong });
        @export(&func_080521EC, .{ .name = "func_080521EC", .linkage = .strong });
        @export(&func_0805221C, .{ .name = "func_0805221C", .linkage = .strong });
        @export(&func_08053400, .{ .name = "func_08053400", .linkage = .strong });
        @export(&func_08053410, .{ .name = "func_08053410", .linkage = .strong });
        @export(&func_080534F0, .{ .name = "func_080534F0", .linkage = .strong });
        @export(&func_08054840, .{ .name = "func_08054840", .linkage = .strong });
        @export(&func_08055260, .{ .name = "func_08055260", .linkage = .strong });
        @export(&func_0805739C, .{ .name = "func_0805739C", .linkage = .strong });
        @export(&func_08059E44, .{ .name = "func_08059E44", .linkage = .strong });
        @export(&func_08059FFC, .{ .name = "func_08059FFC", .linkage = .strong });
        @export(&func_0805A5B4, .{ .name = "func_0805A5B4", .linkage = .strong });
        @export(&func_08064900, .{ .name = "func_08064900", .linkage = .strong });
        @export(&func_08064C88, .{ .name = "func_08064C88", .linkage = .strong });
        @export(&func_0806A3A0, .{ .name = "func_0806A3A0", .linkage = .strong });
        @export(&func_0806A3C8, .{ .name = "func_0806A3C8", .linkage = .strong });
        @export(&func_0806A8B4, .{ .name = "func_0806A8B4", .linkage = .strong });
        @export(&func_0806A8C4, .{ .name = "func_0806A8C4", .linkage = .strong });
        @export(&func_0806A8E4, .{ .name = "func_0806A8E4", .linkage = .strong });
        @export(&func_0806BADC, .{ .name = "func_0806BADC", .linkage = .strong });
        @export(&func_0806BB48, .{ .name = "func_0806BB48", .linkage = .strong });
        @export(&func_0806BD1C, .{ .name = "func_0806BD1C", .linkage = .strong });
        @export(&func_0806BD90, .{ .name = "func_0806BD90", .linkage = .strong });
        @export(&func_0806C25C, .{ .name = "func_0806C25C", .linkage = .strong });
        @export(&func_0806C368, .{ .name = "func_0806C368", .linkage = .strong });
        @export(&func_0806C92C, .{ .name = "func_0806C92C", .linkage = .strong });
        @export(&func_0806C940, .{ .name = "func_0806C940", .linkage = .strong });
        @export(&func_0806C960, .{ .name = "func_0806C960", .linkage = .strong });
        @export(&func_0806C980, .{ .name = "func_0806C980", .linkage = .strong });
        @export(&func_08018DF4, .{ .name = "func_08018DF4", .linkage = .strong });
        @export(&func_080193C0, .{ .name = "func_080193C0", .linkage = .strong });
        @export(&func_080195E8, .{ .name = "func_080195E8", .linkage = .strong });
        @export(&func_08019F04, .{ .name = "func_08019F04", .linkage = .strong });
        @export(&func_08019F60, .{ .name = "func_08019F60", .linkage = .strong });
        @export(&func_08019F78, .{ .name = "func_08019F78", .linkage = .strong });
        @export(&func_08019F90, .{ .name = "func_08019F90", .linkage = .strong });
        @export(&func_0802C660, .{ .name = "func_0802C660", .linkage = .strong });
        @export(&func_0802C670, .{ .name = "func_0802C670", .linkage = .strong });
        @export(&func_0802C694, .{ .name = "func_0802C694", .linkage = .strong });
        @export(&func_08030D90, .{ .name = "func_08030D90", .linkage = .strong });
        @export(&func_080328A0, .{ .name = "func_080328A0", .linkage = .strong });
        @export(&func_080328B8, .{ .name = "func_080328B8", .linkage = .strong });
        @export(&func_0803290C, .{ .name = "func_0803290C", .linkage = .strong });
        @export(&func_0803291C, .{ .name = "func_0803291C", .linkage = .strong });
        @export(&func_0803293C, .{ .name = "func_0803293C", .linkage = .strong });
        @export(&func_0803294C, .{ .name = "func_0803294C", .linkage = .strong });
        @export(&func_08032960, .{ .name = "func_08032960", .linkage = .strong });
        @export(&func_08032974, .{ .name = "func_08032974", .linkage = .strong });
        @export(&func_0803322C, .{ .name = "func_0803322C", .linkage = .strong });
        @export(&func_08033384, .{ .name = "func_08033384", .linkage = .strong });
        @export(&func_080333A0, .{ .name = "func_080333A0", .linkage = .strong });
        @export(&func_080335F4, .{ .name = "func_080335F4", .linkage = .strong });
        @export(&func_0803361C, .{ .name = "func_0803361C", .linkage = .strong });
        @export(&func_0803385C, .{ .name = "func_0803385C", .linkage = .strong });
        @export(&func_080338E8, .{ .name = "func_080338E8", .linkage = .strong });
        @export(&func_08034008, .{ .name = "func_08034008", .linkage = .strong });
        @export(&func_0803401C, .{ .name = "func_0803401C", .linkage = .strong });
        @export(&func_0803470C, .{ .name = "func_0803470C", .linkage = .strong });
        @export(&func_08034720, .{ .name = "func_08034720", .linkage = .strong });
        @export(&func_08034740, .{ .name = "func_08034740", .linkage = .strong });
        @export(&func_08034754, .{ .name = "func_08034754", .linkage = .strong });
        @export(&func_08034774, .{ .name = "func_08034774", .linkage = .strong });
        @export(&func_08034788, .{ .name = "func_08034788", .linkage = .strong });
        @export(&func_080347A8, .{ .name = "func_080347A8", .linkage = .strong });
        @export(&func_08037FC4, .{ .name = "func_08037FC4", .linkage = .strong });
        @export(&func_08037FD0, .{ .name = "func_08037FD0", .linkage = .strong });
        @export(&func_08037FDC, .{ .name = "func_08037FDC", .linkage = .strong });
        @export(&func_08037FE8, .{ .name = "func_08037FE8", .linkage = .strong });
        @export(&func_08037FF4, .{ .name = "func_08037FF4", .linkage = .strong });
        @export(&func_0803891C, .{ .name = "func_0803891C", .linkage = .strong });
        @export(&func_080389DC, .{ .name = "func_080389DC", .linkage = .strong });
        @export(&func_08038C24, .{ .name = "func_08038C24", .linkage = .strong });
        @export(&func_0803979C, .{ .name = "func_0803979C", .linkage = .strong });
        @export(&func_08039A24, .{ .name = "func_08039A24", .linkage = .strong });
        @export(&func_08039EEC, .{ .name = "func_08039EEC", .linkage = .strong });
        @export(&func_0803A650, .{ .name = "func_0803A650", .linkage = .strong });
        @export(&func_0803BC2C, .{ .name = "func_0803BC2C", .linkage = .strong });
        @export(&func_0803BD54, .{ .name = "func_0803BD54", .linkage = .strong });
        @export(&func_0803C818, .{ .name = "func_0803C818", .linkage = .strong });
        @export(&func_0803D018, .{ .name = "func_0803D018", .linkage = .strong });
        @export(&func_0803D038, .{ .name = "func_0803D038", .linkage = .strong });
        @export(&func_0803D2B0, .{ .name = "func_0803D2B0", .linkage = .strong });
        @export(&func_0803D2CC, .{ .name = "func_0803D2CC", .linkage = .strong });
        @export(&func_0803D2D8, .{ .name = "func_0803D2D8", .linkage = .strong });
        @export(&func_0803D43C, .{ .name = "func_0803D43C", .linkage = .strong });
        @export(&func_0803D4C0, .{ .name = "func_0803D4C0", .linkage = .strong });
        @export(&func_0803D4D0, .{ .name = "func_0803D4D0", .linkage = .strong });
        @export(&func_0803D570, .{ .name = "func_0803D570", .linkage = .strong });
        @export(&func_0803D604, .{ .name = "func_0803D604", .linkage = .strong });
        @export(&func_0803D618, .{ .name = "func_0803D618", .linkage = .strong });
        @export(&func_0803DB00, .{ .name = "func_0803DB00", .linkage = .strong });
        @export(&func_0803DB14, .{ .name = "func_0803DB14", .linkage = .strong });
        @export(&func_0803DB28, .{ .name = "func_0803DB28", .linkage = .strong });
        @export(&func_0803DB3C, .{ .name = "func_0803DB3C", .linkage = .strong });
        @export(&func_0803DB6C, .{ .name = "func_0803DB6C", .linkage = .strong });
        @export(&func_0803DBC4, .{ .name = "func_0803DBC4", .linkage = .strong });
        @export(&func_0803DC00, .{ .name = "func_0803DC00", .linkage = .strong });
        @export(&func_0803DC14, .{ .name = "func_0803DC14", .linkage = .strong });
        @export(&func_0803DC20, .{ .name = "func_0803DC20", .linkage = .strong });
        @export(&func_0803DC2C, .{ .name = "func_0803DC2C", .linkage = .strong });
        @export(&func_0803DC38, .{ .name = "func_0803DC38", .linkage = .strong });
        @export(&func_0803DC44, .{ .name = "func_0803DC44", .linkage = .strong });
        @export(&func_0803DD94, .{ .name = "func_0803DD94", .linkage = .strong });
        @export(&func_0803DDA0, .{ .name = "func_0803DDA0", .linkage = .strong });
        @export(&func_0803DDC8, .{ .name = "func_0803DDC8", .linkage = .strong });
        @export(&func_0803DDF0, .{ .name = "func_0803DDF0", .linkage = .strong });
        @export(&func_0803DE0C, .{ .name = "func_0803DE0C", .linkage = .strong });
        @export(&func_0803E924, .{ .name = "func_0803E924", .linkage = .strong });
        @export(&func_0803E938, .{ .name = "func_0803E938", .linkage = .strong });
        @export(&func_0803EE30, .{ .name = "func_0803EE30", .linkage = .strong });
        @export(&func_0803FBB4, .{ .name = "func_0803FBB4", .linkage = .strong });
        @export(&func_08040168, .{ .name = "func_08040168", .linkage = .strong });
        @export(&func_08040AEC, .{ .name = "func_08040AEC", .linkage = .strong });
        @export(&func_08040B00, .{ .name = "func_08040B00", .linkage = .strong });
        @export(&func_08041EFC, .{ .name = "func_08041EFC", .linkage = .strong });
        @export(&func_08042B28, .{ .name = "func_08042B28", .linkage = .strong });
        @export(&func_08044E6C, .{ .name = "func_08044E6C", .linkage = .strong });
        @export(&func_08044E80, .{ .name = "func_08044E80", .linkage = .strong });
        @export(&func_08044E90, .{ .name = "func_08044E90", .linkage = .strong });
        @export(&func_08044EA4, .{ .name = "func_08044EA4", .linkage = .strong });
        @export(&func_08045074, .{ .name = "func_08045074", .linkage = .strong });
        @export(&func_08045568, .{ .name = "func_08045568", .linkage = .strong });
        @export(&func_080459A8, .{ .name = "func_080459A8", .linkage = .strong });
        @export(&func_08045A0C, .{ .name = "func_08045A0C", .linkage = .strong });
        @export(&func_08045A18, .{ .name = "func_08045A18", .linkage = .strong });
        @export(&func_08046DAC, .{ .name = "func_08046DAC", .linkage = .strong });
        @export(&func_08046DEC, .{ .name = "func_08046DEC", .linkage = .strong });
        @export(&func_080471A4, .{ .name = "func_080471A4", .linkage = .strong });
        @export(&func_080471F8, .{ .name = "func_080471F8", .linkage = .strong });
        @export(&func_0804723C, .{ .name = "func_0804723C", .linkage = .strong });
        @export(&func_08047578, .{ .name = "func_08047578", .linkage = .strong });
        @export(&func_080478C8, .{ .name = "func_080478C8", .linkage = .strong });
        @export(&func_080478DC, .{ .name = "func_080478DC", .linkage = .strong });
        @export(&func_080487A0, .{ .name = "func_080487A0", .linkage = .strong });
        @export(&func_080487B4, .{ .name = "func_080487B4", .linkage = .strong });
        @export(&func_08048804, .{ .name = "func_08048804", .linkage = .strong });
        @export(&func_08048A8C, .{ .name = "func_08048A8C", .linkage = .strong });
        @export(&func_08048B2C, .{ .name = "func_08048B2C", .linkage = .strong });
        @export(&func_08048B40, .{ .name = "func_08048B40", .linkage = .strong });
        @export(&func_08048B60, .{ .name = "func_08048B60", .linkage = .strong });
        @export(&func_0804920C, .{ .name = "func_0804920C", .linkage = .strong });
        @export(&func_08049594, .{ .name = "func_08049594", .linkage = .strong });
        @export(&func_080495AC, .{ .name = "func_080495AC", .linkage = .strong });
        @export(&func_080498B0, .{ .name = "func_080498B0", .linkage = .strong });
        @export(&func_08049E08, .{ .name = "func_08049E08", .linkage = .strong });
        @export(&func_0804A1A8, .{ .name = "func_0804A1A8", .linkage = .strong });
        @export(&func_0804A3BC, .{ .name = "func_0804A3BC", .linkage = .strong });
        @export(&func_0804B40C, .{ .name = "func_0804B40C", .linkage = .strong });
        @export(&func_0804B420, .{ .name = "func_0804B420", .linkage = .strong });
        @export(&func_0804B440, .{ .name = "func_0804B440", .linkage = .strong });
        @export(&func_0804C1A8, .{ .name = "func_0804C1A8", .linkage = .strong });
        @export(&func_0804C220, .{ .name = "func_0804C220", .linkage = .strong });
        @export(&func_0804C59C, .{ .name = "func_0804C59C", .linkage = .strong });
        @export(&func_0804C604, .{ .name = "func_0804C604", .linkage = .strong });
        @export(&func_0804C63C, .{ .name = "func_0804C63C", .linkage = .strong });
        @export(&func_0804C650, .{ .name = "func_0804C650", .linkage = .strong });
        @export(&func_0804C680, .{ .name = "func_0804C680", .linkage = .strong });
        @export(&func_0804D984, .{ .name = "func_0804D984", .linkage = .strong });
        @export(&func_0804DA34, .{ .name = "func_0804DA34", .linkage = .strong });
        @export(&func_0804DC68, .{ .name = "func_0804DC68", .linkage = .strong });
        @export(&func_0804E4A8, .{ .name = "func_0804E4A8", .linkage = .strong });
        @export(&func_0804F1E8, .{ .name = "func_0804F1E8", .linkage = .strong });
        @export(&func_0804F6D0, .{ .name = "func_0804F6D0", .linkage = .strong });
        @export(&func_0804F7AC, .{ .name = "func_0804F7AC", .linkage = .strong });
        @export(&func_0804F7BC, .{ .name = "func_0804F7BC", .linkage = .strong });
        @export(&func_0804F7CC, .{ .name = "func_0804F7CC", .linkage = .strong });
        @export(&func_0804F7DC, .{ .name = "func_0804F7DC", .linkage = .strong });
        @export(&func_0804F7F0, .{ .name = "func_0804F7F0", .linkage = .strong });
        @export(&func_0803D2C4, .{ .name = "func_0803D2C4", .linkage = .strong });
        @export(&func_0803D588, .{ .name = "func_0803D588", .linkage = .strong });
        @export(&func_0804505C, .{ .name = "func_0804505C", .linkage = .strong });
        @export(&func_08048BD0, .{ .name = "func_08048BD0", .linkage = .strong });
        @export(&func_08048F4C, .{ .name = "func_08048F4C", .linkage = .strong });
        @export(&func_080494B4, .{ .name = "func_080494B4", .linkage = .strong });
        @export(&func_0804B454, .{ .name = "func_0804B454", .linkage = .strong });
        @export(&func_0804B4E8, .{ .name = "func_0804B4E8", .linkage = .strong });
        @export(&func_0804C3B8, .{ .name = "func_0804C3B8", .linkage = .strong });
        @export(&func_0804C664, .{ .name = "func_0804C664", .linkage = .strong });
        @export(&func_0805196C, .{ .name = "func_0805196C", .linkage = .strong });
        @export(&func_08051D18, .{ .name = "func_08051D18", .linkage = .strong });
        @export(&func_0805A2F8, .{ .name = "func_0805A2F8", .linkage = .strong });
        @export(&func_0805B5AC, .{ .name = "func_0805B5AC", .linkage = .strong });
        @export(&func_0805DC84, .{ .name = "func_0805DC84", .linkage = .strong });
        @export(&func_0805E680, .{ .name = "func_0805E680", .linkage = .strong });
        @export(&func_0805E908, .{ .name = "func_0805E908", .linkage = .strong });
        @export(&func_0805EC0C, .{ .name = "func_0805EC0C", .linkage = .strong });
        @export(&func_0805EC38, .{ .name = "func_0805EC38", .linkage = .strong });
        @export(&func_08062EC8, .{ .name = "func_08062EC8", .linkage = .strong });
        @export(&func_0806586C, .{ .name = "func_0806586C", .linkage = .strong });
        @export(&func_0806D8D4, .{ .name = "func_0806D8D4", .linkage = .strong });
        @export(&func_0806D944, .{ .name = "func_0806D944", .linkage = .strong });
        @export(&func_0806DE20, .{ .name = "func_0806DE20", .linkage = .strong });
        @export(&func_0806DF00, .{ .name = "func_0806DF00", .linkage = .strong });
        @export(&func_0806DF48, .{ .name = "func_0806DF48", .linkage = .strong });
        @export(&func_0806DFAC, .{ .name = "func_0806DFAC", .linkage = .strong });
        @export(&func_0806E2D4, .{ .name = "func_0806E2D4", .linkage = .strong });
        @export(&func_0806E31C, .{ .name = "func_0806E31C", .linkage = .strong });
        @export(&func_0806E380, .{ .name = "func_0806E380", .linkage = .strong });
        @export(&func_0806F564, .{ .name = "func_0806F564", .linkage = .strong });
        @export(&func_08070EFC, .{ .name = "func_08070EFC", .linkage = .strong });
        @export(&func_08070F78, .{ .name = "func_08070F78", .linkage = .strong });
        @export(&func_08071004, .{ .name = "func_08071004", .linkage = .strong });
        @export(&func_08071184, .{ .name = "func_08071184", .linkage = .strong });
        @export(&func_080714C4, .{ .name = "func_080714C4", .linkage = .strong });
        @export(&func_08072C6C, .{ .name = "func_08072C6C", .linkage = .strong });
        @export(&func_08073B08, .{ .name = "func_08073B08", .linkage = .strong });
        @export(&func_08073CE8, .{ .name = "func_08073CE8", .linkage = .strong });
        @export(&func_08074630, .{ .name = "func_08074630", .linkage = .strong });
        @export(&func_08075090, .{ .name = "func_08075090", .linkage = .strong });
        @export(&func_08075B60, .{ .name = "func_08075B60", .linkage = .strong });
        @export(&func_080761C0, .{ .name = "func_080761C0", .linkage = .strong });
        @export(&func_08076228, .{ .name = "func_08076228", .linkage = .strong });
        @export(&func_0807660C, .{ .name = "func_0807660C", .linkage = .strong });
        @export(&func_0801862C, .{ .name = "func_0801862C", .linkage = .strong });
        @export(&func_08018678, .{ .name = "func_08018678", .linkage = .strong });
        @export(&func_08018C1C, .{ .name = "func_08018C1C", .linkage = .strong });
        @export(&func_08018CA8, .{ .name = "func_08018CA8", .linkage = .strong });
        @export(&func_08019194, .{ .name = "func_08019194", .linkage = .strong });
        @export(&func_08019208, .{ .name = "func_08019208", .linkage = .strong });
        @export(&func_080198FC, .{ .name = "func_080198FC", .linkage = .strong });
        @export(&func_0801F034, .{ .name = "func_0801F034", .linkage = .strong });
        @export(&func_0802035C, .{ .name = "func_0802035C", .linkage = .strong });
        @export(&func_08020CDC, .{ .name = "func_08020CDC", .linkage = .strong });
        @export(&func_08021F78, .{ .name = "func_08021F78", .linkage = .strong });
        @export(&func_080220F8, .{ .name = "func_080220F8", .linkage = .strong });
        @export(&func_080221D0, .{ .name = "func_080221D0", .linkage = .strong });
        @export(&func_080238B4, .{ .name = "func_080238B4", .linkage = .strong });
        @export(&func_08026118, .{ .name = "func_08026118", .linkage = .strong });
        @export(&func_08026140, .{ .name = "func_08026140", .linkage = .strong });
        @export(&func_0802615C, .{ .name = "func_0802615C", .linkage = .strong });
        @export(&func_080275EC, .{ .name = "func_080275EC", .linkage = .strong });
        @export(&func_08027F30, .{ .name = "func_08027F30", .linkage = .strong });
        @export(&func_0802A064, .{ .name = "func_0802A064", .linkage = .strong });
        @export(&func_0802A784, .{ .name = "func_0802A784", .linkage = .strong });
        @export(&func_0802BCA8, .{ .name = "func_0802BCA8", .linkage = .strong });
        @export(&func_0802C898, .{ .name = "func_0802C898", .linkage = .strong });
        @export(&func_0802C8B0, .{ .name = "func_0802C8B0", .linkage = .strong });
        @export(&func_0802C8C8, .{ .name = "func_0802C8C8", .linkage = .strong });
        @export(&func_0802C8D8, .{ .name = "func_0802C8D8", .linkage = .strong });
    }
}

test "encodeScreenEntry packs tile, palette bank, and flip flags" {
    try std.testing.expectEqual(@as(u16, 0x2015), encodeScreenEntry(0x15, 2, 0));
    try std.testing.expectEqual(@as(u16, 0x2415), encodeScreenEntry(0x15, 2, 1));
}
