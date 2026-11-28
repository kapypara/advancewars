//! Lifted Advance Wars UI, menus, result screens, BG tilemaps & fade transitions (`0x0803D038..0x0807660C`).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const battle = @import("battle.zig");
const bios = @import("bios.zig");
const campaign = @import("campaign.zig");
const co = @import("co.zig");
const dma = @import("dma.zig");
const hw = @import("hw.zig");
const map = @import("map.zig");
const math = @import("math.zig");
const mem = @import("mem.zig");
const proc_mod = @import("proc.zig");
const sound = @import("sound.zig");
const sprite_anim = @import("sprite_anim.zig");
const state_mod = @import("state.zig");
const turn = @import("turn.zig");
const types = @import("types.zig");
const unit = @import("unit.zig");

/// Encode a 4bpp GBA screen entry `(tile_id | (hflip_pal_fields))`.
pub inline fn encodeScreenEntry(tile: u16, pal_bank: u16, extra: u16) u16 {
    return (tile +% (pal_bank << 12)) | (extra << 10);
}

/// Write UI dialog state halfwords `+0x1A = u16(r0)` and `+0x1E = u16(r1)` (`0x08049000`).
pub fn func_08049000() callconv(.c) void {
    if (!abi.enter(0x08049000)) return;
    abi.fetches(7);
    const state_ptr = mem.readU32(types.addr.ui_dialog_state_ptr);
    rt.r[2] = state_ptr;
    mem.writeU16(state_ptr +% 0x1A, @truncate(rt.r[0]));
    mem.writeU16(state_ptr +% 0x1E, @truncate(rt.r[1]));
    abi.retLr();
}

/// Read UI dialog state halfword `+0x1A` (`0x08049010`).
pub fn func_08049010() callconv(.c) void {
    if (!abi.enter(0x08049010)) return;
    abi.fetches(6);
    const state_ptr = mem.readU32(types.addr.ui_dialog_state_ptr);
    rt.r[0] = mem.readU16(state_ptr +% 0x1A);
    abi.retLr();
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
    if (!abi.call(func_080193C0, 0x08019601)) return;
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
    if (!abi.call(func_0803291C, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn checkProcActive(comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(def_ref);
    if (!abi.call(proc_mod.func_08013B70, ret_addr)) return;
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
    if (!abi.call(func_08020CDC, 0x08033873)) return;
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
    if (!abi.call(turn.func_080353A8, ret_addr)) return;
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
    if (!abi.call(state_mod.func_08035804, 0x08037FD7)) return;
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
    if (!abi.call(proc_mod.func_08019608, 0x080389E3)) return;
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
    if (!abi.call(proc_mod.func_08011060, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn queryUI13BA0(comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(def_ref);
    if (!abi.call(proc_mod.func_08013BA0, ret_addr)) return;
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
    if (!abi.call(func_08048AA4, 0x0803D57F)) return;
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
    if (!abi.call(func_0806A3A0, 0x0803DD9B)) return;
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
    if (!abi.call(func_0804DA34, 0x0803DDF7)) return;
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
    if (!abi.call(hw.func_080104B0, 0x08042B2F)) return;
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
    if (!abi.call(map.func_08020D14, 0x08045571)) return;
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
    if (!abi.call(unit.func_0801B8D4, 0x08045A15)) return;
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
    if (!abi.call(unit.func_0801B8D4, 0x08046DB5)) return;
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
    if (!abi.call(hw.func_080104B0, 0x08047243)) return;
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
    if (!abi.call(proc_mod.func_08013B70, 0x08048B49)) return;

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
    if (!abi.call(sprite_anim.func_080122D8, 0x0804A1DF)) return;
    abi.fetches(5);
    rt.r[13] +%= 8;
    abi.popReturn();
}

/// Reset hardware audio/display state and apply blend preset `(0x46, 0x18, 0xF, 6)` (`0x0804A3BC`).
pub fn func_0804A3BC() callconv(.c) void {
    if (!abi.enter(0x0804A3BC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(hw.func_080104B0, 0x0804A3C3)) return;
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
    if (!abi.call(func_08049010, 0x0804C231)) return;

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
    if (!abi.call(hw.func_080104B0, 0x0804DC6F)) return;
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
    if (!abi.call(func_0804F7AC, 0x0804F6D7)) return;

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
    if (!abi.call(func_08054BA8, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn checkUIProc13B70Active(comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(def_ref);
    if (!abi.call(proc_mod.func_08013B70, ret_addr)) return;

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
    if (!abi.call(unit.func_0801B8D4, 0x08051C25)) return;

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
    if (!abi.call(unit.func_080573B4, 0x080573AF)) return;
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
    if (!abi.call(func_08075808, 0x0806C975)) return;
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
    if (!abi.call(func_0806DE20, 0x0806E2CB)) return;

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
    if (!abi.call(func_08075A90, 0x08073C57)) return;

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
    if (!abi.call(sound.func_0803D920, 0x08073CAF)) return;

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
    callVoidForward(func_0806A8E4, 0x08077543);
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
    if (!abi.call(hw.func_080104B0, ret1)) return;
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
    if (!abi.call(state_mod.func_08035220, 0x08018C2B)) return;

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
    if (!abi.call(map.func_08019168, 0x0801919D)) return;

    abi.fetches(12);
    abi.write32(rt.r[13], 0x14);
    abi.write32(rt.r[13] +% 4, abi.read32(0x080191C0));
    rt.r[0] = abi.read32(0x080191BC);
    rt.r[1] = 0;
    rt.r[2] = 0;
    abi.setRegNz(&rt.r[3], 0x20);
    if (!abi.call(hw.func_08010C70, 0x080191B1)) return;

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
    if (!abi.call(dma.func_0800FFA8, 0x08020369)) return;
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
    if (!abi.call(unit.func_08026020, 0x0802611F)) return;
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
    if (!abi.call(sound.func_0803D880, 0x080275F7)) return;

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
    if (!abi.call(hw.func_0801B888, 0x0802BCD5)) return;

    abi.fetches(10);
    rt.r[0] = abi.read32(0x0802BCF4);
    const pal_dst = (slot_scaled << 5) +% abi.read32(0x0802BCF8);
    rt.r[4] = pal_dst;
    rt.r[1] = pal_dst;
    abi.setRegNz(&rt.r[2], 0x80);
    if (!abi.call(dma.func_0800FFA8, 0x0802BCE5)) return;

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
    if (!abi.call(map.func_08020D6C, 0x0802C8CF)) return;
    abi.fetches(4);
    if (!abi.call(campaign.func_080381C4, 0x0802C8D3)) return;
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
    if (!abi.call(turn.func_08035230, 0x0802C8ED)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn fillBoxWith174ThenSync(
    comptime call_first: fn () callconv(.c) void,
    comptime box_ref: u32,
    comptime sp0: u32,
    comptime a1: u32,
    comptime a2: u32,
    comptime a3: u32,
    comptime sync_41328: bool,
    comptime r0: u32,
    comptime r1: u32,
    comptime r2: u32,
) void {
    abi.fetches(if (sync_41328) 15 else 6);
    abi.pushLr();
    rt.r[13] -%= 8;
    if (!sync_41328) {
        if (!abi.call(call_first, r0)) return;
        abi.fetches(13);
    }
    abi.write32(rt.r[13], sp0);
    abi.write32(rt.r[13] +% 4, 0xBA << 1);
    rt.r[0] = abi.read32(box_ref);
    abi.setRegNz(&rt.r[1], a1);
    abi.setRegNz(&rt.r[2], a2);
    abi.setRegNz(&rt.r[3], a3);
    if (!abi.call(hw.func_08010C70, if (sync_41328) r0 else r1)) return;
    if (sync_41328) {
        abi.fetches(4);
        if (!abi.call(call_first, r1)) return;
    }
    abi.fetches(4);
    if (!abi.call(decls.func_08011804, r2)) return;
    abi.fetches(5);
    rt.r[13] +%= 8;
    abi.popReturn();
}

fn dmaPaletteAndResetPanel(
    comptime src1_ref: u32,
    comptime dst1_ref: u32,
    comptime src2_ref: ?u32,
    comptime dst2_ref: ?u32,
    comptime reset_ref: u32,
    comptime r0: u32,
    comptime r1: u32,
    comptime r2: u32,
) void {
    abi.fetches(if (src2_ref != null) 10 else 9);
    abi.pushLr();
    if (src2_ref != null) {
        rt.r[13] -%= 4;
        abi.write32(rt.r[13], rt.r[4]);
        rt.r[4] = @as(u32, 0x80) << 1;
    }
    rt.r[0] = abi.read32(src1_ref);
    rt.r[1] = abi.read32(dst1_ref);
    abi.setRegNz(&rt.r[2], @as(u32, 0x80) << 1);
    if (!abi.call(dma.func_0800FDA4, r0)) return;
    if (src2_ref) |s2| {
        abi.fetches(7);
        rt.r[0] = abi.read32(s2);
        rt.r[1] = abi.read32(dst2_ref.?);
        rt.r[2] = @as(u32, 0x80) << 1;
        if (!abi.call(dma.func_0800FDA4, r1)) return;
    }
    abi.fetches(5);
    rt.r[0] = abi.read32(reset_ref);
    if (!abi.call(decls.func_0800FC74, if (src2_ref != null) r2 else r1)) return;
    abi.fetches(if (src2_ref != null) 5 else 4);
    if (src2_ref != null) {
        rt.r[4] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
    }
    abi.popReturn();
}

fn clearPalAndDraw1B888(
    comptime clear_ref: u32,
    comptime tbl2_ref: u32,
    comptime tbl3_ref: u32,
    comptime ret1: u32,
    comptime ret2: u32,
) void {
    abi.fetches(15);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const x_u16 = rt.r[0] & 0xFFFF;
    const y_u16 = rt.r[1] & 0xFFFF;
    rt.r[4] = x_u16;
    rt.r[5] = y_u16;
    rt.r[0] = abi.read32(clear_ref);
    abi.setRegNz(&rt.r[1], @as(u32, 0x9C) << 2);
    abi.setRegNz(&rt.r[2], 2);
    if (!abi.call(dma.func_08011374, ret1)) return;

    abi.fetches(12);
    rt.r[4] = @bitCast(abi.signExtend16(@truncate(x_u16)));
    rt.r[5] = @bitCast(abi.signExtend16(@truncate(y_u16)));
    rt.r[0] = rt.r[4];
    rt.r[1] = rt.r[5];
    rt.r[2] = abi.read32(tbl2_ref);
    rt.r[3] = abi.read32(tbl3_ref);
    if (!abi.call(hw.func_0801B888, ret2)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn spawnUiProcAndZeroArg(comptime proc_ref: u32, comptime ret1: u32, comptime ret2: u32) void {
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const proc = abi.read32(proc_ref);
    rt.r[4] = proc;
    rt.r[0] = proc;
    if (!abi.call(decls.func_0801329C, ret1)) return;
    abi.fetches(6);
    rt.r[0] = proc;
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, ret2)) return;
    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn spawn48WindowWithMode(
    comptime flag_5c: u8,
    comptime proc_ref: u32,
    comptime mgr_ref: u32,
    comptime ret_addr: u32,
) void {
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved = rt.r[0];
    const mode = rt.r[1] & 0xFF;
    rt.r[5] = saved;
    rt.r[4] = mode;
    rt.r[0] = abi.read32(proc_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, ret_addr)) return;

    abi.fetches(23);
    const mgr = abi.read32(abi.read32(mgr_ref));
    abi.write8(mgr +% 0x5C, flag_5c);
    abi.write8(mgr +% 0x5E, @truncate(mode));
    abi.write8(mgr +% 0x5F, @truncate(mode << 1));
    abi.write8(mgr +% 0x60, @truncate(mode << 3));
    abi.write32(mgr +% 0x58, saved);
    rt.r[0] = mgr;
    rt.r[1] = mode << 1;
    rt.r[2] = abi.read32(mgr_ref);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn openOverlayTilemap4C7C0(
    comptime init_first_pal: bool,
    comptime pal_or_proc_ref: u32,
    comptime state_ref: u32,
    comptime tbl2_ref: u32,
    comptime off_ref: u32,
    comptime stack_flag: u32,
    comptime r0: u32,
    comptime r1: u32,
    comptime r2: u32,
) void {
    abi.fetches(if (init_first_pal) 9 else 7);
    abi.pushLr();
    rt.r[13] -%= 4;
    if (init_first_pal) {
        rt.r[0] = abi.read32(pal_or_proc_ref);
        abi.setRegNz(&rt.r[1], 0x80);
        abi.setRegNz(&rt.r[2], 0x20);
        if (!abi.call(dma.func_08011330, r0)) return;
    } else {
        rt.r[0] = abi.read32(pal_or_proc_ref);
        if (!abi.call(decls.func_0801329C, r0)) return;
    }

    abi.fetches(21);
    const st = abi.read32(abi.read32(state_ref));
    const sx = abi.read16(st +% 0x1E);
    const sy = abi.read16(st +% 0x20);
    const row_byte = ((@as(u32, sx -% sy) << 25) +% (@as(u32, 0xA0) << 19)) >> 24;
    abi.write32(rt.r[13], stack_flag);
    abi.setRegNz(&rt.r[0], 1);
    rt.r[1] = row_byte;
    rt.r[2] = abi.read32(tbl2_ref);
    rt.r[3] = abi.read8(sx +% abi.read32(off_ref));
    if (!abi.call(func_0804C7C0, r1)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08011804, r2)) return;

    abi.fetches(5);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear War Room window region `(1, 11, 28, 8)` to `0x174` and commit `0x08041328` + `0x08011804` (`0x080416B8`).
pub fn func_080416B8() callconv(.c) void {
    if (!abi.enter(0x080416B8)) return;
    fillBoxWith174ThenSync(decls.func_08041328, 0x080416E0, 8, 1, 0xB, 0x1C, true, 0x080416D3, 0x080416D7, 0x080416DB);
}

/// Clear briefing window region `(1, 5, 15, 10)` to `0x174` after `0x080124D4` and commit `0x08011804` (`0x080420D0`).
pub fn func_080420D0() callconv(.c) void {
    if (!abi.enter(0x080420D0)) return;
    fillBoxWith174ThenSync(sprite_anim.func_080124D4, 0x080420F8, 0xA, 1, 5, 0xF, false, 0x080420D9, 0x080420EF, 0x080420F3);
}

/// Render War Room CO emblem slot `i8([*p+0x22] + [0x08042144])` via `0x080122D8` (`0x080420FC`).
pub fn func_080420FC() callconv(.c) void {
    if (!abi.enter(0x080420FC)) return;
    abi.fetches(29);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const st = abi.read32(abi.read32(0x08042148));
    const idx: u32 = @bitCast(abi.signExtend16(abi.read16(st +% 0x22)));
    const entry_id = abi.read8(idx +% abi.read32(0x08042144));
    const ptr = (entry_id *% 36) +% (abi.read32(0x08042140) +% 0xC);
    abi.write32(rt.r[13], @as(u32, 0xC0) << 6);
    abi.write32(rt.r[13] +% 4, @as(u32, 0x80) << 1);
    abi.setRegNz(&rt.r[0], 1);
    abi.setRegNz(&rt.r[1], 5);
    rt.r[2] = abi.read32(0x0804213C);
    rt.r[3] = abi.read32(ptr);
    rt.r[4] = entry_id;
    rt.r[5] = 0x22;
    if (!abi.call(sprite_anim.func_080122D8, 0x08042133)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Draw CO badge `0x080402D4` and upload CO unit palette `0x0801BEE4` to slot `r2 + 0x10` (`0x080422EC`).
pub fn func_080422EC() callconv(.c) void {
    if (!abi.enter(0x080422EC)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const pal_slot = rt.r[2] & 0xFFFF;
    const raw_co = rt.r[0];
    rt.r[4] = pal_slot;
    rt.r[5] = (raw_co << 16) >> 16;
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(raw_co)));
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(rt.r[1])));
    if (!abi.call(func_080402D4, 0x08042303)) return;

    abi.fetches(5);
    rt.r[0] = (raw_co << 16) >> 16;
    if (!abi.call(co.func_0801BEE4, 0x08042309)) return;

    abi.fetches(9);
    const dst_pal = ((pal_slot +% 0x10) << 21) >> 16;
    rt.r[4] = dst_pal;
    rt.r[1] = dst_pal;
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x08042317)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Look up CO info `0x08040310` for selection `[0x080427C4]` and render via `0x0801B888` (`0x0804278C`).
pub fn func_0804278C() callconv(.c) void {
    if (!abi.enter(0x0804278C)) return;
    abi.fetches(12);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const st_slot = abi.read32(0x080427C4);
    rt.r[4] = st_slot;
    const idx: u32 = @bitCast(abi.signExtend16(abi.read16(abi.read32(st_slot) +% 0x22)));
    rt.r[0] = abi.read8(idx +% abi.read32(0x080427C0));
    if (!abi.call(campaign.func_08040310, 0x080427A1)) return;

    abi.fetches(14);
    const base_x = rt.r[0] +% 0x80 +% abi.read8(abi.read32(st_slot) +% 0x42);
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(base_x)));
    abi.setRegNz(&rt.r[1], 8);
    rt.r[2] = abi.read32(0x080427C8);
    rt.r[3] = abi.read32(0x080427CC);
    if (!abi.call(hw.func_0801B888, 0x080427B9)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// DMA dual `0x100`-byte UI tilemaps and clear overlay `[0x08042E20]` (`0x08042DE8`).
pub fn func_08042DE8() callconv(.c) void {
    if (!abi.enter(0x08042DE8)) return;
    dmaPaletteAndResetPanel(0x08042E10, 0x08042E14, 0x08042E18, 0x08042E1C, 0x08042E20, 0x08042DF9, 0x08042E03, 0x08042E09);
}

/// Clear War Room BG layers (`0x0801193C`, `0x08011814`) around `0x0803942C` (`0x08043890`).
pub fn func_08043890() callconv(.c) void {
    if (!abi.enter(0x08043890)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0801193C, 0x08043897)) return;
    abi.fetches(6);
    rt.r[0] = abi.read32(0x080438A8);
    rt.r[1] = abi.read32(0x080438AC);
    if (!abi.call(decls.func_0803942C, 0x0804389F)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011814, 0x080438A3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Upload cursor palette slice `[0x08043A70]` and draw `(x, y)` panel via `0x0801B888` (`0x08043A3C`).
pub fn func_08043A3C() callconv(.c) void {
    if (!abi.enter(0x08043A3C)) return;
    clearPalAndDraw1B888(0x08043A70, 0x08043A74, 0x08043A78, 0x08043A57, 0x08043A6B);
}

/// Clear status panel `0x08043C64(8, 0)` and flush `0x08011834` (`0x08043EF0`).
pub fn func_08043EF0() callconv(.c) void {
    if (!abi.enter(0x08043EF0)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 8);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(func_08043C64, 0x08043EFB)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011834, 0x08043EFF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Focus and spawn submenu proc `[0x08044350]` (`0x08044338`).
pub fn func_08044338() callconv(.c) void {
    if (!abi.enter(0x08044338)) return;
    spawnUiProcAndZeroArg(0x08044350, 0x08044343, 0x0804434B);
}

/// Sync display regs `0x080104B0`, configure window blend masks, and tag byte in `0x08044398..0x080443A8` (`0x08044354`).
pub fn func_08044354() callconv(.c) void {
    if (!abi.enter(0x08044354)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(hw.func_080104B0, 0x0804435B)) return;

    abi.fetches(34);
    const ctrl = abi.read32(0x08044398);
    abi.write8(ctrl, (abi.read8(ctrl) & 0x3F) | 0x44);
    abi.write8(ctrl +% 1, abi.read8(ctrl +% 1) | 0x1A);
    abi.write16(abi.read32(0x0804439C), 0xF);
    abi.write16(abi.read32(0x080443A0), 6);
    const dst = abi.read32(abi.read32(0x080443A4)) +% abi.read32(0x080443A8);
    abi.write8(dst, 0xF);
    rt.r[0] = dst;
    rt.r[1] = abi.read32(0x080443A8);
    rt.r[2] = 0xF;
    abi.popReturn();
}

/// Tear down result overlay (`0x08021DF8`, `0x08011910`, `0x08011804`) (`0x08046D98`).
pub fn func_08046D98() callconv(.c) void {
    if (!abi.enter(0x08046D98)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(unit.func_08021DF8, 0x08046D9F)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011910, 0x08046DA3)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011804, 0x08046DA7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// DMA `0x100`-byte result palette `[0x08046E18] -> [0x08046E1C]` and reset `[0x08046E20]` (`0x08046E00`).
pub fn func_08046E00() callconv(.c) void {
    if (!abi.enter(0x08046E00)) return;
    dmaPaletteAndResetPanel(0x08046E18, 0x08046E1C, null, null, 0x08046E20, 0x08046E0F, 0x08046E15, 0);
}

/// Upload UI palette slice `[0x08046FF0]` and draw `(x, y)` panel via `0x0801B888` (`0x08046FBC`).
pub fn func_08046FBC() callconv(.c) void {
    if (!abi.enter(0x08046FBC)) return;
    clearPalAndDraw1B888(0x08046FF0, 0x08046FF4, 0x08046FF8, 0x08046FD7, 0x08046FEB);
}

/// Spawn campaign dialogue proc `[0x080471EC]` and play script indexed by `read16(*[0x080471F4] + 0x2A)` (`0x080471C8`).
pub fn func_080471C8() callconv(.c) void {
    if (!abi.enter(0x080471C8)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x080471EC);
    if (!abi.call(decls.func_0801329C, 0x080471D1)) return;
    abi.fetches(11);
    const idx = abi.read16(abi.read32(abi.read32(0x080471F4)) +% 0x2A);
    rt.r[0] = abi.read32(abi.read32(0x080471F0) +% (@as(u32, idx) << 2));
    if (!abi.call(decls.func_080183C0, 0x080471E3)) return;
    abi.fetches(4);
    if (!abi.call(proc_mod.func_08016F30, 0x080471E7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn dialogue proc `[0x08047234]` and play script `u16(r0)` from `[0x08047238]` (`0x08047210`).
pub fn func_08047210() callconv(.c) void {
    if (!abi.enter(0x08047210)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const idx = rt.r[0] & 0xFFFF;
    rt.r[4] = idx;
    rt.r[0] = abi.read32(0x08047234);
    if (!abi.call(decls.func_0801329C, 0x0804721F)) return;
    abi.fetches(8);
    rt.r[4] = abi.read32(0x08047238) +% (idx << 2);
    rt.r[0] = abi.read32(rt.r[4]);
    if (!abi.call(decls.func_080183C0, 0x0804722B)) return;
    abi.fetches(4);
    if (!abi.call(proc_mod.func_08016F30, 0x0804722F)) return;
    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Wrap scroll coords via `0x08013578`/`0x08013550` and save `x` into animator `+0x24` (`0x08047944`).
pub fn func_08047944() callconv(.c) void {
    if (!abi.enter(0x08047944)) return;
    abi.fetches(18);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    const anim_idx_ptr = abi.read32(0x08047994);
    const anim_idx: i32 = abi.signExtend16(abi.read16(anim_idx_ptr));
    const slot_ptr = @as(u32, @bitCast((anim_idx *% 3) << 5)) +% abi.read32(0x08047998);
    const sp_x = rt.r[13];
    const sp_y = rt.r[13] +% 2;
    rt.r[4] = slot_ptr;
    rt.r[5] = sp_y;
    rt.r[6] = anim_idx_ptr;
    rt.r[0] = @bitCast(anim_idx);
    rt.r[1] = sp_x;
    rt.r[2] = sp_y;
    if (!abi.call(sprite_anim.func_08013578, 0x08047965)) return;

    abi.fetches(22);
    const px = abi.read16(sp_x);
    abi.write16(slot_ptr +% 0x24, px);
    const wrapped_x = (px -% abi.read16(abi.read32(0x0804799C))) & abi.read32(0x080479A0);
    abi.write16(sp_x, @truncate(wrapped_x));
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(anim_idx_ptr)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(sp_x)));
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(sp_y)));
    rt.r[3] = 0;
    if (!abi.call(sprite_anim.func_08013550, 0x0804798D)) return;

    abi.fetches(6);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn UI manager `[0x08048AE0]` with mode `0` (`0x08048AA4`).
pub fn func_08048AA4() callconv(.c) void {
    if (!abi.enter(0x08048AA4)) return;
    spawn48WindowWithMode(0, 0x08048AE0, 0x08048AE4, 0x08048AB5);
}

/// Spawn UI manager `[0x08048B24]` with mode `1` (`0x08048AE8`).
pub fn func_08048AE8() callconv(.c) void {
    if (!abi.enter(0x08048AE8)) return;
    spawn48WindowWithMode(1, 0x08048B24, 0x08048B28, 0x08048AF9);
}

/// Draw submenu cursor label relative to `*[0x080491FC]` via `0x0801B888` (`0x080491C0`).
pub fn func_080491C0() callconv(.c) void {
    if (!abi.enter(0x080491C0)) return;
    abi.fetches(28);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const s = abi.read32(abi.read32(0x080491FC));
    const mask = abi.read32(0x08049200);
    const x = (abi.read16(s +% 0x14) +% abi.read16(s +% 0x1A) +% 9) & mask;
    const y: u32 = @bitCast(abi.signExtend16(@truncate(abi.read16(s +% 0x16) +% abi.read16(s +% 0x1E) -% 0x1C)));
    const attr = ((abi.read16(s +% 0x18) +% 0xD0) | abi.read32(0x08049208)) & 0xFFFF;
    rt.r[0] = x;
    rt.r[1] = y;
    rt.r[2] = abi.read32(0x08049204);
    rt.r[3] = attr;
    rt.r[4] = abi.read32(0x08049200);
    rt.r[5] = abi.read32(0x08049208);
    rt.updateNz(attr);
    if (!abi.call(hw.func_0801B888, 0x080491F5)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Initialize result camera animator fields `[0x0804930C]` from `0x08013578` (`0x080492AC`).
pub fn func_080492AC() callconv(.c) void {
    if (!abi.enter(0x080492AC)) return;
    abi.fetches(18);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    const anim_idx: i32 = abi.signExtend16(abi.read16(abi.read32(0x08049304)));
    const slot_ptr = @as(u32, @bitCast((anim_idx *% 3) << 5)) +% abi.read32(0x08049308);
    const sp_x = rt.r[13];
    const sp_y = rt.r[13] +% 2;
    rt.r[4] = slot_ptr;
    rt.r[5] = sp_y;
    rt.r[6] = 0;
    rt.r[0] = @bitCast(anim_idx);
    rt.r[1] = sp_x;
    rt.r[2] = sp_y;
    if (!abi.call(sprite_anim.func_08013578, 0x080492CD)) return;

    abi.fetches(29);
    const mgr_slot = abi.read32(0x0804930C);
    const mgr = abi.read32(mgr_slot);
    abi.write16(mgr +% 0xA, abi.read16(sp_x));
    abi.write16(mgr +% 0xC, abi.read16(sp_y));
    abi.write16(mgr +% 0xE, @as(u16, 0xFA) << 3);
    abi.write16(mgr +% 0x10, 0);
    abi.write16(mgr +% 0x12, 0);
    abi.write16(slot_ptr +% 0x1E, 0x32);
    abi.write16(mgr +% 0x1A, 0);
    abi.write16(mgr +% 0x1E, 0);
    abi.write8(mgr +% 0x20, 0);
    abi.write8(abi.read32(mgr_slot) +% 0x21, 0);

    rt.r[0] = abi.read32(mgr_slot) +% 0x21;
    rt.r[1] = mgr +% 0x20;
    rt.r[2] = 0;
    rt.r[3] = 0;
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Allocate `0x28`-byte buffer `[0x080498AC]` via `0x08012D8C` and open menu `[0x0804B460]`/`[0x080497B8]` (`0x08049870`).
pub fn func_08049870() callconv(.c) void {
    if (!abi.enter(0x08049870)) return;
    abi.fetches(14);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const a0 = rt.r[0] & 0xFFFF;
    const a1 = rt.r[1] & 0xFFFF;
    const a2 = rt.r[2] & 0xFF;
    rt.r[4] = a0;
    rt.r[5] = a1;
    rt.r[0] = a2;
    rt.updateNz(a2);
    if (!abi.call(decls.func_0804B460, 0x08049889)) return;

    abi.fetches(8);
    abi.write8(abi.read32(0x080498A8), @truncate(rt.r[0]));
    rt.r[6] = abi.read32(0x080498AC);
    abi.setRegNz(&rt.r[0], 0x28);
    if (!abi.call(decls.func_08012D8C, 0x08049895)) return;

    abi.fetches(8);
    abi.write32(rt.r[6], rt.r[0]);
    rt.r[0] = a0;
    rt.r[1] = a1;
    abi.setRegNz(&rt.r[2], 0);
    if (!abi.call(decls.func_080497B8, 0x080498A1)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Enable portrait index `[0x08049CD8]` (`0x080136A4`) and upload tile graphic via `0x0800FE18` (`0x08049C9C`).
pub fn func_08049C9C() callconv(.c) void {
    if (!abi.enter(0x08049C9C)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(abi.read32(0x08049CD8))));
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_080136A4, 0x08049CAB)) return;

    abi.fetches(21);
    const id = abi.read8((abi.read8(abi.read32(0x08049CE8)) -% 1) +% abi.read32(0x08049CE4));
    const entry_ptr = (id *% 12) +% abi.read32(0x08049CE0);
    const tile_idx = abi.read8(entry_ptr +% 0xA);
    rt.r[4] = abi.read32(0x08049CDC);
    rt.r[0] = abi.read32(rt.r[4] +% (@as(u32, tile_idx) << 2));
    rt.r[1] = abi.read32(0x08049CEC);
    rt.r[2] = id;
    rt.r[3] = abi.read32(0x08049CE0);
    if (!abi.call(hw.func_0800FE18, 0x08049CD1)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Hide portrait index `[0x08049D98]` (`0x080136A4`) and upload backdrop tiles via `0x0800FE18` (`0x08049D68`).
pub fn func_08049D68() callconv(.c) void {
    if (!abi.enter(0x08049D68)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(abi.read32(0x08049D98))));
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080136A4, 0x08049D77)) return;

    abi.fetches(17);
    const id = abi.read8(abi.read8(abi.read32(0x08049DA4)) +% abi.read32(0x08049DA0));
    const base = abi.read32(0x08049D9C) +% 4;
    rt.r[0] = abi.read32((id *% 12) +% base);
    rt.r[1] = abi.read32(0x08049DA8);
    rt.r[2] = base;
    rt.r[3] = id;
    if (!abi.call(hw.func_0800FE18, 0x08049D95)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Set VRAM palette bank (`[0x08049DF4]`), upload `0x20`-byte palette (`0x08011330`), and finalize `0x08049C8C` (`0x08049DAC`).
pub fn func_08049DAC() callconv(.c) void {
    if (!abi.enter(0x08049DAC)) return;
    abi.fetches(33);
    abi.pushLr();
    const mgr = abi.read32(abi.read32(0x08049DF4));
    const slot = abi.read8(mgr +% 0x2F);
    abi.write32(mgr +% 0x38 +% (@as(u32, slot) << 2), @as(u32, 0x80) << 1);
    const id = abi.read8(abi.read8(abi.read32(0x08049E00)) +% abi.read32(0x08049DFC));
    const pal_id = abi.read8((id *% 12) +% abi.read32(0x08049DF8) +% 8);
    rt.r[0] = (@as(u32, pal_id) << 5) +% abi.read32(0x08049E04);
    rt.r[1] = @as(u32, 0xE0) << 2;
    abi.setRegNz(&rt.r[2], 0x20);
    rt.r[3] = id;
    if (!abi.call(dma.func_08011330, 0x08049DEB)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08049C8C, 0x08049DEF)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Query animator pos `0x08013578` for `[0x08049EFC]` and store Q8 coords `(x<<8, y<<8)` at `+0x28/+0x2C` (`0x08049EC0`).
pub fn func_08049EC0() callconv(.c) void {
    if (!abi.enter(0x08049EC0)) return;
    abi.fetches(18);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    const anim_idx: i32 = abi.signExtend16(abi.read16(abi.read32(0x08049EFC)));
    const slot_ptr = @as(u32, @bitCast((anim_idx *% 3) << 5)) +% abi.read32(0x08049F00);
    const sp_x = rt.r[13];
    const sp_y = rt.r[13] +% 2;
    rt.r[4] = slot_ptr;
    rt.r[5] = sp_y;
    rt.r[0] = @bitCast(anim_idx);
    rt.r[1] = sp_x;
    rt.r[2] = sp_y;
    if (!abi.call(sprite_anim.func_08013578, 0x08049EE1)) return;

    abi.fetches(15);
    const qx: u32 = @as(u32, @bitCast(abi.signExtend16(abi.read16(sp_x)))) << 8;
    const qy: u32 = @as(u32, @bitCast(abi.signExtend16(abi.read16(sp_y)))) << 8;
    abi.write32(slot_ptr +% 0x28, qx);
    abi.write32(slot_ptr +% 0x2C, qy);
    abi.setRegNz(&rt.r[0], qy);
    rt.r[1] = 0;
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear box `(4, 2, 14, 16)` to `0x174` after `0x080124D4` and commit `0x08011804` (`0x0804A17C`).
pub fn func_0804A17C() callconv(.c) void {
    if (!abi.enter(0x0804A17C)) return;
    fillBoxWith174ThenSync(sprite_anim.func_080124D4, 0x0804A1A4, 4, 2, 0xE, 0x10, false, 0x0804A185, 0x0804A19B, 0x0804A19F);
}

/// Focus and spawn submenu proc `[0x0804A208]` (`0x0804A1F0`).
pub fn func_0804A1F0() callconv(.c) void {
    if (!abi.enter(0x0804A1F0)) return;
    spawnUiProcAndZeroArg(0x0804A208, 0x0804A1FB, 0x0804A203);
}

/// Sync field scroll counters `[0x0804B538..0x0804B548]`, mask BG via `0x08010AF8`, and spawn `[0x0804B550]` (`0x0804B50C`).
pub fn func_0804B50C() callconv(.c) void {
    if (!abi.enter(0x0804B50C)) return;
    abi.fetches(17);
    abi.pushLr();
    abi.write16(abi.read32(0x0804B538), 0);
    abi.write16(abi.read32(0x0804B53C), abi.read16(abi.read32(0x0804B540)));
    abi.write16(abi.read32(0x0804B544), abi.read16(abi.read32(0x0804B548)));
    rt.r[0] = abi.read32(0x0804B54C);
    if (!abi.call(hw.func_08010AF8, 0x0804B52B)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x0804B550);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, 0x0804B533)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Focus procs `[0x0804C5C4]` and `[0x0804C5C8]` via `0x0801329C` (`0x0804C5B0`).
pub fn func_0804C5B0() callconv(.c) void {
    if (!abi.enter(0x0804C5B0)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0804C5C4);
    if (!abi.call(decls.func_0801329C, 0x0804C5B9)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x0804C5C8);
    if (!abi.call(decls.func_0801329C, 0x0804C5BF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Unpack UI graphic `[0x0804C708]` (`0x0800FE18`) and clear palette `[0x0804C710]` (`0x08011374`) (`0x0804C6EC`).
pub fn func_0804C6EC() callconv(.c) void {
    if (!abi.enter(0x0804C6EC)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0804C708);
    rt.r[1] = abi.read32(0x0804C70C);
    if (!abi.call(hw.func_0800FE18, 0x0804C6F7)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x0804C710);
    abi.setRegNz(&rt.r[1], @as(u32, 0xBC) << 2);
    abi.setRegNz(&rt.r[2], 2);
    if (!abi.call(dma.func_08011374, 0x0804C703)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Upload palette `[0x0804D198]`, open tilemap row (`stack=4`) via `0x0804C7C0`, and flush BG `0x08011804` (`0x0804D158`).
pub fn func_0804D158() callconv(.c) void {
    if (!abi.enter(0x0804D158)) return;
    openOverlayTilemap4C7C0(true, 0x0804D198, 0x0804D19C, 0x0804D1A0, 0x0804D1A4, 4, 0x0804D167, 0x0804D18D, 0x0804D191);
}

/// Activate proc `[0x0804D230]`, open tilemap row (`stack=3`) via `0x0804C7C0`, and flush BG `0x08011804` (`0x0804D1F4`).
pub fn func_0804D1F4() callconv(.c) void {
    if (!abi.enter(0x0804D1F4)) return;
    openOverlayTilemap4C7C0(false, 0x0804D230, 0x0804D234, 0x0804D238, 0x0804D23C, 3, 0x0804D1FF, 0x0804D225, 0x0804D229);
}

/// DMA `0x100`-byte UI tileset `[0x0804DA00] -> [0x0804DA04]` and reset `[0x0804DA08]` (`0x0804D9E8`).
pub fn func_0804D9E8() callconv(.c) void {
    if (!abi.enter(0x0804D9E8)) return;
    dmaPaletteAndResetPanel(0x0804DA00, 0x0804DA04, null, null, 0x0804DA08, 0x0804D9F7, 0x0804D9FD, 0);
}

fn callFn0And1(comptime step_fn: fn () callconv(.c) void, comptime ret1: u32, comptime ret2: u32) void {
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(step_fn, ret1)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 1);
    if (!abi.call(step_fn, ret2)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn drawPanelCopy1B888(comptime tbl_copy: u32, comptime tbl_pal: u32, comptime ret1: u32, comptime ret2: u32) void {
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const panel_ptr = rt.r[0];
    rt.r[4] = panel_ptr;
    rt.r[0] = rt.r[13];
    rt.r[1] = abi.read32(tbl_copy);
    abi.setRegNz(&rt.r[2], 8);
    if (!abi.call(decls.func_0807A8A0, ret1)) return;

    abi.fetches(21);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(panel_ptr +% 0x28)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(panel_ptr +% 0x2A) +% 0xC));
    rt.r[2] = abi.read32(tbl_pal);
    const idx = abi.read8(panel_ptr +% 0x48);
    rt.r[4] = idx;
    rt.r[3] = (abi.read16(rt.r[13] +% (@as(u32, idx) << 1)) +% (@as(u32, 0xC0) << 7)) & 0xFFFF;
    if (!abi.call(hw.func_0801B888, ret2)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn dialoguePortraitWordAddr(idx: u32, comptime tbl_ptr: u32, comptime state_ptr: u32, comptime aux_ptr: u32) u32 {
    const tbl = abi.read32(tbl_ptr);
    const state = abi.read32(state_ptr);
    const aux = abi.read32(aux_ptr);
    const slot_base = (idx *% 36) +% state;
    const sub_idx = abi.read8(aux +% 0x20);
    const row = abi.read8(slot_base +% 0xB);
    return (row +% (sub_idx *% 7)) *% 4 +% (tbl +% 4);
}

/// Update dialogue CO index `+0x28 = +0x1E` and select portrait via `0x08018400` (`0x0804DBB8`).
pub fn func_0804DBB8() callconv(.c) void {
    if (!abi.enter(0x0804DBB8)) return;
    abi.fetches(5);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    if (!abi.call(decls.func_08018E04, 0x0804DBBF)) return;

    abi.fetches(30);
    const ctx = abi.read32(abi.read32(0x0804DBFC));
    abi.write16(ctx +% 0x28, abi.read16(ctx +% 0x1E));
    const idx: u32 = @bitCast(abi.signExtend16(abi.read16(ctx +% 0x1E)));
    const entry_id = abi.read8(ctx +% 0x4D +% idx);
    rt.r[0] = abi.read32(dialoguePortraitWordAddr(entry_id, 0x0804DC00, 0x0804DC04, 0x0804DC08));
    if (!abi.call(decls.func_08018400, 0x0804DBF7)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Focus dialogue proc `[0x0804DC54]`, set portrait `0x080183C0`, and clear panel `0x08016F30` (`0x0804DC0C`).
pub fn func_0804DC0C() callconv(.c) void {
    if (!abi.enter(0x0804DC0C)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[0] = abi.read32(0x0804DC54);
    if (!abi.call(decls.func_0801329C, 0x0804DC15)) return;

    abi.fetches(28);
    const ctx = abi.read32(abi.read32(0x0804DC60));
    const idx: u32 = @bitCast(abi.signExtend16(abi.read16(ctx +% 0x28)));
    const entry_id = abi.read8(ctx +% 0x4D +% idx);
    rt.r[0] = abi.read32(dialoguePortraitWordAddr(entry_id, 0x0804DC58, 0x0804DC5C, 0x0804DC64));
    if (!abi.call(decls.func_080183C0, 0x0804DC49)) return;

    abi.fetches(4);
    if (!abi.call(proc_mod.func_08016F30, 0x0804DC4D)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Initialize dialogue portrait window offsets from ROM table `[0x0804F070]` and run `0x0804EDE4` (`0x0804F018`).
pub fn func_0804F018() callconv(.c) void {
    if (!abi.enter(0x0804F018)) return;
    abi.fetches(42);
    abi.pushLr();
    const s = abi.read32(abi.read32(0x0804F06C));
    abi.write8(s +% 0x47, 1);
    abi.write16(s +% 0x26, abi.read16(s +% 0x1E));
    const idx: u32 = @bitCast(abi.signExtend16(abi.read16(s +% 0x1E)));
    const tbl_entry = (abi.read8(s +% 0x79 +% idx) << 2) +% abi.read32(0x0804F070);
    abi.write16(s +% 0x38, abi.read16(tbl_entry) -% 0x7A);
    abi.write16(s +% 0x3A, abi.read16(tbl_entry +% 2) -% 0x47);
    abi.write16(s +% 0x40, abi.read16(abi.read32(0x0804F074)));
    abi.write16(s +% 0x42, abi.read16(abi.read32(0x0804F078)));
    abi.write8(s +% 0x33, 0);
    if (!abi.call(decls.func_0804EDE4, 0x0804F069)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Allocate `0x7C`-byte dialogue buffer into `[0x0804F81C]` and spawn proc `[0x0804F820]` (`0x0804F800`).
pub fn func_0804F800() callconv(.c) void {
    if (!abi.enter(0x0804F800)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const slot_ptr = abi.read32(0x0804F81C);
    rt.r[4] = slot_ptr;
    abi.setRegNz(&rt.r[0], 0x7C);
    if (!abi.call(decls.func_08012D8C, 0x0804F80B)) return;

    abi.fetches(7);
    abi.write32(slot_ptr, rt.r[0]);
    rt.r[0] = abi.read32(0x0804F820);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x0804F815)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Query Q0 coords via `0x08013578`, write Q8 position to slot `[0x0804FA58][i16([0x0804FA54])]`, and increment counter `[0x0804FA5C]` (`0x0804FA10`).
pub fn func_0804FA10() callconv(.c) void {
    if (!abi.enter(0x0804FA10)) return;
    abi.fetches(18);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    const slot_idx: u32 = @bitCast(abi.signExtend16(abi.read16(abi.read32(0x0804FA54))));
    const ent = ((slot_idx *% 3) << 5) +% abi.read32(0x0804FA58);
    rt.r[4] = ent;
    rt.r[5] = rt.r[13] +% 2;
    rt.r[1] = rt.r[13];
    rt.r[2] = rt.r[13] +% 2;
    if (!abi.call(sprite_anim.func_08013578, 0x0804FA31)) return;

    abi.fetches(19);
    const x_q8: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[13])) << 8);
    const y_q8: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[13] +% 2)) << 8);
    abi.write32(ent +% 0x28, x_q8);
    abi.write32(ent +% 0x2C, y_q8);
    const cnt_ptr = abi.read32(0x0804FA5C);
    abi.write8(cnt_ptr, abi.read8(cnt_ptr) +% 1);

    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Focus proc `[0x080502DC]` twice via `0x0801329C` (`0x080502C4`).
pub fn func_080502C4() callconv(.c) void {
    if (!abi.enter(0x080502C4)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const proc_desc = abi.read32(0x080502DC);
    rt.r[4] = proc_desc;
    abi.copyRegFlags(&rt.r[0], proc_desc);
    if (!abi.call(decls.func_0801329C, 0x080502CF)) return;

    abi.fetches(5);
    abi.copyRegFlags(&rt.r[0], proc_desc);
    if (!abi.call(decls.func_0801329C, 0x080502D5)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Close overlay `0x08016F30` and restore portrait `[0x08050354]` via `0x08018400` (`0x08050344`).
pub fn func_08050344() callconv(.c) void {
    if (!abi.enter(0x08050344)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(proc_mod.func_08016F30, 0x0805034B)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x08050354);
    if (!abi.call(decls.func_08018400, 0x08050351)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Draw dialogue frame `[0x0805044C]` (`0xD`, `0`), clear `[0x08050450]`, and render `[0x08050454]` (`0x38`) via `0x080495C0` (`0x0805041C`).
pub fn func_0805041C() callconv(.c) void {
    if (!abi.enter(0x0805041C)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    const frame_ptr = abi.read32(0x0805044C);
    rt.r[4] = frame_ptr;
    abi.copyRegFlags(&rt.r[0], frame_ptr);
    abi.setRegNz(&rt.r[1], 0xD);
    abi.setRegNz(&rt.r[2], 0);
    if (!abi.call(func_08049870, 0x0805042D)) return;

    abi.fetches(13);
    abi.write8(abi.read32(0x08050450), 0);
    abi.write32(rt.r[13], 0);
    rt.r[0] = abi.read32(0x08050454);
    abi.setRegNz(&rt.r[1], 0x38);
    abi.copyRegFlags(&rt.r[2], frame_ptr);
    abi.setRegNz(&rt.r[3], 0xD);
    if (!abi.call(decls.func_080495C0, 0x08050443)) return;

    abi.fetches(6);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// DMA `0x180` UI tiles `[0x080508B4] -> [0x080508B8]` and upload `0x20`-byte palette `[0x080508BC]` at `0x3A0` (`0x08050894`).
pub fn func_08050894() callconv(.c) void {
    if (!abi.enter(0x08050894)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = abi.read32(0x080508B4);
    rt.r[1] = abi.read32(0x080508B8);
    abi.setRegNz(&rt.r[2], @as(u32, 0xC0) << 1);
    if (!abi.call(dma.func_0800FDA4, 0x080508A3)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x080508BC);
    abi.setRegNz(&rt.r[1], @as(u32, 0xE8) << 2);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x080508AF)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Upload `0x20`-byte palette `[0x08050A6C]` at `0x220` and setup `[0x08050A70]` via `0x0806CC78` (`0x08050A54`).
pub fn func_08050A54() callconv(.c) void {
    if (!abi.enter(0x08050A54)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08050A6C);
    abi.setRegNz(&rt.r[1], @as(u32, 0x88) << 2);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x08050A63)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x08050A70);
    if (!abi.call(hw.func_0806CC78, 0x08050A69)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Sync window `0x080104D4`, reset palette `0x0801B8D4(0)`, update map focus `0x080199A0`, and clear scene flags (`0x08050DE4`).
pub fn func_08050DE4() callconv(.c) void {
    if (!abi.enter(0x08050DE4)) return;
    abi.fetches(5);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    if (!abi.call(decls.func_080104D4, 0x08050DEB)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(unit.func_0801B8D4, 0x08050DF1)) return;

    abi.fetches(8);
    const ctx_ptr = abi.read32(0x08050E14);
    rt.r[4] = ctx_ptr;
    rt.r[0] = abi.read8(abi.read32(ctx_ptr) +% 0x2E);
    if (!abi.call(map.func_080199A0, 0x08050DFD)) return;

    abi.fetches(13);
    abi.write16(abi.read32(0x08050E18), 0);
    abi.write8(abi.read32(ctx_ptr) +% 0x46, 0);
    abi.write8(abi.read32(0x08050E1C), 0);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear `[0x08051B20]`, upload `0x20`-byte palette `[0x08051B24]` at `0x260`, and decompress `[0x08051B28] -> [0x08051B2C]` (`0x08051B00`).
pub fn func_08051B00() callconv(.c) void {
    if (!abi.enter(0x08051B00)) return;
    abi.fetches(12);
    abi.pushLr();
    abi.write8(abi.read32(0x08051B20), 0);
    rt.r[0] = abi.read32(0x08051B24);
    abi.setRegNz(&rt.r[1], @as(u32, 0x98) << 2);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x08051B15)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x08051B28);
    rt.r[1] = abi.read32(0x08051B2C);
    if (!abi.call(hw.func_0800FE18, 0x08051B1D)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Run `0x0805266C` for indices `0` and `1` (`0x08052658`).
pub fn func_08052658() callconv(.c) void {
    if (!abi.enter(0x08052658)) return;
    callFn0And1(decls.func_0805266C, 0x08052661, 0x08052667);
}

/// Copy `0x10` words via `0x080796C0` from table `[0x08052CCC][r0][r1]` to `r2` and call `0x08052CD0(*entry, r3)` (`0x08052C98`).
pub fn func_08052C98() callconv(.c) void {
    if (!abi.enter(0x08052C98)) return;
    abi.fetches(20);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const col = rt.r[0] & 0xFFFF;
    const row = rt.r[1] & 0xFFFF;
    const entry = (col << 2) +% (row *% 20) +% abi.read32(0x08052CCC);
    const aux = rt.r[3];
    rt.r[4] = entry;
    rt.r[5] = aux;
    rt.r[0] = abi.read32(entry);
    rt.r[1] = rt.r[2];
    abi.setRegNz(&rt.r[2], 0x10);
    if (!abi.call(bios.func_080796C0, 0x08052CBD)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(entry);
    rt.r[1] = aux;
    if (!abi.call(decls.func_08052CD0, 0x08052CC5)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Run `0x08056ED8` for indices `0` and `1` (`0x08053054`).
pub fn func_08053054() callconv(.c) void {
    if (!abi.enter(0x08053054)) return;
    callFn0And1(decls.func_08056ED8, 0x0805305D, 0x08053063);
}

/// DMA `0x400`-byte tile slice from `*(0x08054678 + 0x18 + u16(r0)*32) + ((r2<<26)>>16)` to VRAM (`0x08054644`).
pub fn func_08054644() callconv(.c) void {
    if (!abi.enter(0x08054644)) return;
    abi.fetches(25);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const bank = rt.r[0] & 0xFFFF;
    const src_off = (rt.r[2] << 26) >> 16;
    const dst_off = ((bank << 13) +% 0x400) & 0xFFFF;
    const src_ptr = abi.read32(abi.read32(0x08054678) +% 0x18 +% (bank << 5));
    rt.r[0] = src_ptr +% src_off;
    rt.r[1] = dst_off +% abi.read32(0x0805467C);
    rt.r[2] = 0x400;
    rt.r[4] = 0x400;
    if (!abi.call(dma.func_0800FFA8, 0x08054673)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Forward entry coords from `[0x08054BF0][r0][r1]` relative to `*[0x08054BEC][r0]` into `0x08013550` (`0x08054BA8`).
pub fn func_08054BA8() callconv(.c) void {
    if (!abi.enter(0x08054BA8)) return;
    abi.fetches(32);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const grp = rt.r[0] & 0xFFFF;
    const slot = rt.r[1] & 0xFFFF;
    const val: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[2])));
    const ref_ptr = abi.read32(abi.read32(0x08054BEC) +% (grp << 2));
    const ent = (slot *% 36) +% (grp *% 0xB4) +% abi.read32(0x08054BF0);
    rt.r[4] = val;
    rt.r[5] = abi.read16(ref_ptr);
    rt.r[0] = val;
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(ent +% 8)));
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(ent +% 0xA) -% abi.read16(ref_ptr)));
    if (!abi.call(sprite_anim.func_08013550, 0x08054BE5)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Forward `(u16(r0), u16(r1), u16(r2))` to `0x080559B8` then `0x08055A50` (`0x08055988`).
pub fn func_08055988() callconv(.c) void {
    if (!abi.enter(0x08055988)) return;
    abi.fetches(17);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const a0 = rt.r[0] & 0xFFFF;
    const a1 = rt.r[1] & 0xFFFF;
    const a2 = rt.r[2] & 0xFFFF;
    rt.r[4] = a0;
    rt.r[5] = a1;
    rt.r[6] = a2;
    rt.r[0] = a0;
    rt.r[1] = a1;
    rt.r[2] = a2;
    rt.updateNz(a2);
    if (!abi.call(unit.func_080559B8, 0x080559A7)) return;

    abi.fetches(7);
    rt.r[0] = a0;
    rt.r[1] = a1;
    rt.r[2] = a2;
    if (!abi.call(unit.func_08055A50, 0x080559B1)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Compute delta `(x, y)` for slot `i16([0x080570B0])` in `[0x080570AC]` and forward to `0x08013550` (`0x08057060`).
pub fn func_08057060() callconv(.c) void {
    if (!abi.enter(0x08057060)) return;
    abi.fetches(37);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const slot_idx: u32 = @bitCast(abi.signExtend16(abi.read16(abi.read32(0x080570B0))));
    const ent = ((slot_idx *% 3) << 5) +% (abi.read32(0x080570AC) +% 0x30);
    const id = abi.read16(ent);
    const ptr_x = abi.read32((@as(u32, id) << 2) +% abi.read32(0x080570B4));
    const ptr_y = abi.read32((@as(u32, id) << 2) +% abi.read32(0x080570B8));
    const target_x = abi.read16((@as(u32, id) << 1) +% abi.read32(0x080570BC));
    const target_y = abi.read16((@as(u32, id) << 1) +% abi.read32(0x080570C0));
    rt.r[4] = abi.read16(ptr_x);
    rt.r[5] = abi.read16(ptr_y);
    rt.r[0] = slot_idx;
    rt.r[1] = @bitCast(abi.signExtend16(target_x -% abi.read16(ptr_x)));
    rt.r[2] = @bitCast(abi.signExtend16(target_y -% abi.read16(ptr_y)));
    rt.updateNz(rt.r[2]);
    if (!abi.call(sprite_anim.func_08013550, 0x080570A7)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Update overlay step `0x0805C284` then `0x0805BAC0` (`0x0805A008`).
pub fn func_0805A008() callconv(.c) void {
    if (!abi.enter(0x0805A008)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0805C284, 0x0805A00F)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0805BAC0, 0x0805A013)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Run overlay trio `0x0805DD64`, `0x0805E414`, `0x0805E808` (`0x0805DD50`).
pub fn func_0805DD50() callconv(.c) void {
    if (!abi.enter(0x0805DD50)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_0805DD64, 0x0805DD57)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0805E414, 0x0805DD5B)) return;
    abi.fetches(4);
    if (!abi.call(unit.func_0805E808, 0x0805DD5F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Run `0x0805E7B4` for indices `0` and `1` (`0x0805E7A0`).
pub fn func_0805E7A0() callconv(.c) void {
    if (!abi.enter(0x0805E7A0)) return;
    callFn0And1(decls.func_0805E7B4, 0x0805E7A9, 0x0805E7AF);
}

/// Run summary screen trio `0x080651AC`, `0x08065300`, `0x08066040` (`0x080648EC`).
pub fn func_080648EC() callconv(.c) void {
    if (!abi.enter(0x080648EC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080651AC, 0x080648F3)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08065300, 0x080648F7)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08066040, 0x080648FB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn cursor proc `[0x0806C354]`, configure fields/flags, and DMA `[0x0806C360] -> [0x0806C364]` (`0x0806C328`).
pub fn func_0806C328() callconv(.c) void {
    if (!abi.enter(0x0806C328)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0806C354);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x0806C333)) return;

    abi.fetches(17);
    const p = rt.r[0];
    abi.write32(p +% 0x24, 0x66);
    abi.write32(p +% 0x28, 6);
    abi.write32(p +% 0x3C, abi.read32(0x0806C358));
    abi.write16(p +% 0x40, @truncate(abi.read32(0x0806C35C)));
    rt.r[0] = abi.read32(0x0806C360);
    rt.r[1] = abi.read32(0x0806C364);
    abi.setRegNz(&rt.r[2], @as(u32, 0xE0) << 1);
    if (!abi.call(dma.func_0800FFA8, 0x0806C351)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Reset BG2/BG3 affine transforms `[0x0806CE7C]` and `[0x0806CE80]` to identity centered at `(120, 80)` (`0x0806CE3C`).
pub fn func_0806CE3C() callconv(.c) void {
    if (!abi.enter(0x0806CE3C)) return;
    abi.fetches(26);
    abi.pushLr();
    rt.r[13] -%= 0x14;
    abi.write32(rt.r[13], @as(u32, 0xF0) << 7);
    abi.write32(rt.r[13] +% 4, @as(u32, 0xA0) << 7);
    abi.write16(rt.r[13] +% 8, 0x78);
    abi.write16(rt.r[13] +% 0xA, 0x50);
    abi.write16(rt.r[13] +% 0xC, 0x100);
    abi.write16(rt.r[13] +% 0xE, 0x100);
    abi.write16(rt.r[13] +% 0x10, 0);
    rt.r[0] = rt.r[13];
    rt.r[1] = abi.read32(0x0806CE7C);
    abi.setRegNz(&rt.r[2], 1);
    if (!abi.call(bios.func_080796BC, 0x0806CE6D)) return;

    abi.fetches(7);
    rt.r[0] = rt.r[13];
    rt.r[1] = abi.read32(0x0806CE80);
    abi.setRegNz(&rt.r[2], 1);
    if (!abi.call(bios.func_080796BC, 0x0806CE77)) return;

    abi.fetches(5);
    rt.r[13] +%= 0x14;
    abi.popReturn();
}

/// LZ77-decompress pair of ROM tile assets `[0x0806CEF0][r0]` and `[0x0806CEF4][r0]` to OBJ VRAM tiles `r1` and `r1 + 8` (`0x0806CEBC`).
pub fn func_0806CEBC() callconv(.c) void {
    if (!abi.enter(0x0806CEBC)) return;
    abi.fetches(15);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const idx_off = rt.r[0] << 2;
    const base_tile = rt.r[1];
    const vram_base = @as(u32, 0xC0) << 19;
    rt.r[5] = idx_off;
    rt.r[4] = base_tile;
    rt.r[6] = vram_base;
    rt.r[0] = abi.read32(idx_off +% abi.read32(0x0806CEF0));
    rt.r[1] = (base_tile << 5) +% vram_base;
    if (!abi.call(hw.func_0800FE18, 0x0806CED7)) return;

    abi.fetches(11);
    rt.r[5] = idx_off +% abi.read32(0x0806CEF4);
    rt.r[0] = abi.read32(rt.r[5]);
    rt.r[4] = (base_tile +% 8) << 5;
    rt.r[4] +%= vram_base;
    rt.r[1] = rt.r[4];
    if (!abi.call(hw.func_0800FE18, 0x0806CEE9)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Copy `[0x0806DA44]` tile IDs to stack and draw text at `(x, y+12)` via `0x0801B888` (`0x0806DA04`).
pub fn func_0806DA04() callconv(.c) void {
    if (!abi.enter(0x0806DA04)) return;
    drawPanelCopy1B888(0x0806DA44, 0x0806DA48, 0x0806DA15, 0x0806DA3B);
}

/// Copy `[0x0806DCB4]` tile IDs to stack and draw text at `(x, y+12)` via `0x0801B888` (`0x0806DC74`).
pub fn func_0806DC74() callconv(.c) void {
    if (!abi.enter(0x0806DC74)) return;
    drawPanelCopy1B888(0x0806DCB4, 0x0806DCB8, 0x0806DC85, 0x0806DCAB);
}

/// Compute tilemap char/OAM coords from `[0x0806DE90]` and render via `0x0801B888` (`0x0806DE4C`).
pub fn func_0806DE4C() callconv(.c) void {
    if (!abi.enter(0x0806DE4C)) return;
    abi.fetches(32);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const s = rt.r[0];
    const x = (abi.read16(s +% 0x28) +% 0x200) & 0x1FF;
    const ch = abi.read8(abi.read32(abi.read32(0x0806DE90)) +% 0x11 +% abi.read16(s +% 0x1C));
    const y = (abi.read16(s +% 0x2A) +% (@as(u32, ch) << 2) +% 0x100) & 0xFF;
    const tile = ((@as(u32, ch) << 20) +% abi.read32(0x0806DE98)) >> 16;
    rt.r[4] = x;
    rt.r[0] = x;
    rt.r[1] = y;
    rt.r[2] = abi.read32(0x0806DE94);
    rt.r[3] = tile;
    rt.updateNz(tile);
    if (!abi.call(hw.func_0801B888, 0x0806DE89)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Decompress endings banner `[0x08073820]` to WRAM, populate pointers `[0x08073824]`, upload palette & DMA tiles (`0x080737D8`).
pub fn func_080737D8() callconv(.c) void {
    if (!abi.enter(0x080737D8)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const p = rt.r[0];
    const wram_buf: u32 = @as(u32, 0x80) << 18;
    rt.r[5] = p;
    rt.r[4] = wram_buf;
    rt.r[0] = abi.read32(0x08073820);
    rt.r[1] = wram_buf;
    if (!abi.call(bios.func_080796DC, 0x080737E9)) return;

    abi.fetches(14);
    const tbl = abi.read32(0x08073824);
    abi.write32(tbl, wram_buf);
    abi.write32(tbl +% 4, abi.read32(0x08073828));
    abi.write32(tbl +% 8, abi.read32(0x0807382C));
    rt.r[0] = abi.read32(0x08073830);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x08073801)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08073834);
    rt.r[1] = abi.read32(0x08073838);
    abi.setRegNz(&rt.r[2], @as(u32, 0x80) << 2);
    if (!abi.call(dma.func_0800FFA8, 0x0807380D)) return;

    abi.fetches(12);
    abi.write32(p +% 0x24, 0x110);
    abi.write32(p +% 0x28, 0x110);
    abi.write16(p +% 0x44, 0);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Update affine scale matrix `[0x08073888]` from proc `+0x24/+0x28/+0x44` via `0x080796BC` and advance `+0x44 += 2` (`0x0807383C`).
pub fn func_0807383C() callconv(.c) void {
    if (!abi.enter(0x0807383C)) return;
    abi.fetches(33);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 0x14;

    const p = rt.r[0];
    const step_ptr = p +% 0x44;
    const step = abi.read16(step_ptr);
    rt.r[4] = step_ptr;
    rt.r[5] = 0;
    rt.r[6] = abi.read16(p +% 0x24);
    abi.write32(rt.r[13], @as(u32, 0x98) << 7);
    abi.write32(rt.r[13] +% 4, @as(u32, 0xD0) << 6);
    abi.write16(rt.r[13] +% 8, 0x78);
    abi.write16(rt.r[13] +% 0xA, 0x50);
    abi.write16(rt.r[13] +% 0xC, @truncate(rt.r[6] -% step));
    abi.write16(rt.r[13] +% 0xE, abi.read16(p +% 0x28) -% step);
    abi.write16(rt.r[13] +% 0x10, 0);
    rt.r[0] = rt.r[13];
    rt.r[1] = abi.read32(0x08073888);
    abi.setRegNz(&rt.r[2], 1);
    if (!abi.call(bios.func_080796BC, 0x0807387B)) return;

    abi.fetches(9);
    abi.write16(step_ptr, abi.read16(step_ptr) +% 2);
    rt.r[13] +%= 0x14;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Focus procs `[0x08074274]` and `[0x08074278]` via `0x0801329C` (`0x08074260`).
pub fn func_08074260() callconv(.c) void {
    if (!abi.enter(0x08074260)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08074274);
    if (!abi.call(decls.func_0801329C, 0x08074269)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x08074278);
    if (!abi.call(decls.func_0801329C, 0x0807426F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Play SFX `0xC5`, spawn cursor proc `[0x080742B8]`, and scroll to `(r0, r1)` via `0x08073F04` (`0x0807427C`).
pub fn func_0807427C() callconv(.c) void {
    if (!abi.enter(0x0807427C)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const tx = rt.r[0];
    const ty = rt.r[1];
    rt.r[4] = tx;
    rt.r[5] = ty;
    abi.setRegNz(&rt.r[0], 0xC5);
    if (!abi.call(sound.func_0803D880, 0x08074289)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x080742B8);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08074291)) return;

    abi.fetches(18);
    const cam = abi.read32(abi.read32(0x080742BC));
    const cam_x: u32 = @bitCast(abi.signExtend16(abi.read16(cam +% 4)));
    const cam_y: u32 = @bitCast(abi.signExtend16(abi.read16(cam +% 6)));
    const dx = (tx << 4) -% (cam_x -% 8);
    const dy = (ty << 4) -% (cam_y -% 8);
    rt.r[4] = dx;
    rt.r[5] = dy;
    rt.r[1] = dx;
    rt.r[2] = dy;
    if (!abi.call(decls.func_08073F04, 0x080742B1)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Query unlocked count `0x0803A128`, pass `5 - val` to `0x080501DC(0xF0, ...)`, and store `[0x08075300]+4 = r4` (`0x080752E0`).
pub fn func_080752E0() callconv(.c) void {
    if (!abi.enter(0x080752E0)) return;
    abi.fetches(5);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    if (!abi.call(state_mod.func_0803A128, 0x080752E7)) return;

    abi.fetches(10);
    const cnt = rt.r[0];
    rt.r[4] = cnt;
    abi.setRegNz(&rt.r[0], 0xF0);
    rt.r[1] = (5 -% cnt) & 0xFFFF;
    rt.updateNz(rt.r[1]);
    if (!abi.call(func_080501DC, 0x080752F7)) return;

    abi.fetches(7);
    abi.write8(abi.read32(0x08075300) +% 4, @truncate(cnt));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Fade out BGM `0x080787CC(0xB00)`, zero UI bytes `[0x080754C4..0x080754CC]`, play `0xDF`, and spawn `[0x080754D0]` (`0x08075490`).
pub fn func_08075490() callconv(.c) void {
    if (!abi.enter(0x08075490)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], @as(u32, 0xB0) << 4);
    if (!abi.call(decls.func_080787CC, 0x0807549B)) return;

    abi.fetches(17);
    const base = abi.read32(0x080754C4);
    abi.write16(base, 0);
    abi.write8(base +% 2, 0);
    abi.write8(base +% 3, 0);
    abi.write8(base +% 4, 0);
    abi.write8(base +% 5, 0);
    abi.write16(abi.read32(0x080754C8), 0);
    abi.write16(abi.read32(0x080754CC), 0);
    abi.setRegNz(&rt.r[0], 0xDF);
    if (!abi.call(decls.func_0803D8C8, 0x080754B9)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x080754D0);
    abi.setRegNz(&rt.r[1], 0x80);
    if (!abi.call(decls.func_0801320C, 0x080754C1)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Measure/decompress asset `[0x08075B58]` to WRAM (`0x02000000`) and DMA `[0x08075B5C]` bytes (`0x08075B2C`).
pub fn func_08075B2C() callconv(.c) void {
    if (!abi.enter(0x08075B2C)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const wram_buf: u32 = @as(u32, 0x80) << 18;
    const src = abi.read32(0x08075B58);
    rt.r[6] = wram_buf;
    rt.r[5] = src;
    rt.r[0] = src;
    if (!abi.call(decls.func_0806CCA4, 0x08075B3B)) return;

    abi.fetches(7);
    const sz = rt.r[0];
    rt.r[4] = sz;
    rt.r[0] = src;
    rt.r[1] = wram_buf;
    if (!abi.call(bios.func_080796DC, 0x08075B45)) return;

    abi.fetches(9);
    const sz16 = sz & 0xFFFF;
    rt.r[4] = sz16;
    rt.r[0] = wram_buf;
    rt.r[1] = abi.read32(0x08075B5C);
    rt.r[2] = sz16;
    rt.updateNz(sz16);
    if (!abi.call(dma.func_0800FFA8, 0x08075B53)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Upload dual `0x180`-byte HUD blocks via `0x0802C5E0` and sync BG layers `0` & `2` via `0x080117EC` (`0x0802C604`).
pub fn func_0802C604() callconv(.c) void {
    if (!abi.enter(0x0802C604)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[4] = 0x180;
    rt.r[0] = abi.read32(0x0802C630);
    rt.r[1] = abi.read32(0x0802C634);
    abi.setRegNz(&rt.r[2], 0x180);
    if (!abi.call(decls.func_0802C5E0, 0x0802C615)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x0802C638);
    rt.r[1] = abi.read32(0x0802C63C);
    abi.setRegNz(&rt.r[2], 0x180);
    if (!abi.call(decls.func_0802C5E0, 0x0802C61F)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_080117EC, 0x0802C625)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 2);
    if (!abi.call(decls.func_080117EC, 0x0802C62B)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down tactical HUD (`0x08021DF8`, `0x08011910`, `0x08011804`, `0x0803906C`) and set `r0+0x1E = 6` (`0x0802C808`).
pub fn func_0802C808() callconv(.c) void {
    if (!abi.enter(0x0802C808)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const st = rt.r[0];
    rt.r[4] = st;
    if (!abi.call(unit.func_08021DF8, 0x0802C811)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011910, 0x0802C815)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011804, 0x0802C819)) return;
    abi.fetches(4);
    if (!abi.call(state_mod.func_0803906C, 0x0802C81D)) return;

    abi.fetches(7);
    abi.write16(st +% 0x1E, 6);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn fillDualBgBoxesAndFlush(
    comptime buf_ref: u32,
    comptime y1: u32,
    comptime h1: u32,
    comptime y2: u32,
    comptime w2: u32,
    comptime h2: u32,
    comptime ret1: u32,
    comptime ret2: u32,
    comptime ret3: u32,
) bool {
    abi.fetches(14);
    const bg_buf = abi.read32(buf_ref);
    const fill_tile: u32 = 0x174;
    abi.write32(rt.r[13], h1);
    abi.write32(rt.r[13] +% 4, fill_tile);
    rt.r[0] = bg_buf;
    abi.setRegNz(&rt.r[1], 1);
    abi.setRegNz(&rt.r[2], y1);
    abi.setRegNz(&rt.r[3], 0x10);
    if (!abi.call(hw.func_08010C70, ret1)) return false;

    abi.fetches(11);
    abi.write32(rt.r[13], h2);
    abi.write32(rt.r[13] +% 4, fill_tile);
    rt.r[0] = bg_buf;
    abi.setRegNz(&rt.r[1], 1);
    abi.setRegNz(&rt.r[2], y2);
    abi.setRegNz(&rt.r[3], w2);
    if (!abi.call(hw.func_08010C70, ret2)) return false;

    abi.fetches(4);
    if (!abi.call(decls.func_08011804, ret3)) return false;
    return true;
}

/// Write shop item index `r0` to `[[0x0804076C]]+0x62`, clear dual menu boxes, and spawn proc `[0x08040774]` (`0x0804071C`).
pub fn func_0804071C() callconv(.c) void {
    if (!abi.enter(0x0804071C)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    abi.write8(abi.read32(abi.read32(0x0804076C)) +% 0x62, @truncate(rt.r[0]));
    if (!abi.call(sprite_anim.func_080124D4, 0x0804072D)) return;

    if (!fillDualBgBoxesAndFlush(0x08040770, 7, 2, 9, 0xF, 0xA, 0x08040745, 0x08040757, 0x0804075B)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x08040774);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, 0x08040763)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Open CO/shop detail header via `0x080402D4`, `0x0801BEE4`, palette `0x3E0`, clear top box, and run `func_0804071C` (`0x08040778`).
pub fn func_08040778() callconv(.c) void {
    if (!abi.enter(0x08040778)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const item_u16 = rt.r[0] & 0xFFFF;
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(item_u16)));
    abi.setRegNz(&rt.r[1], 0x19C);
    if (!abi.call(func_080402D4, 0x0804078B)) return;

    abi.fetches(5);
    rt.r[0] = item_u16;
    if (!abi.call(co.func_0801BEE4, 0x08040791)) return;

    abi.fetches(7);
    abi.setRegNz(&rt.r[1], 0x3E0);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x0804079B)) return;

    abi.fetches(13);
    abi.write32(rt.r[13], 2);
    abi.write32(rt.r[13] +% 4, 0x174);
    rt.r[0] = abi.read32(0x080407C0);
    abi.setRegNz(&rt.r[1], 1);
    abi.setRegNz(&rt.r[2], 5);
    abi.setRegNz(&rt.r[3], 0xF);
    if (!abi.call(hw.func_08010C70, 0x080407B1)) return;

    abi.fetches(5);
    rt.r[0] = item_u16;
    if (!abi.call(func_0804071C, 0x080407B7)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear shop/map overlay dual BG boxes via `0x080124D4` + `0x08010C70` and call `0x0801990C([0x08040AE8])` (`0x08040A9C`).
pub fn func_08040A9C() callconv(.c) void {
    if (!abi.enter(0x08040A9C)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    if (!abi.call(sprite_anim.func_080124D4, 0x08040AA5)) return;

    if (!fillDualBgBoxesAndFlush(0x08040AE4, 5, 4, 9, 0xF, 0xA, 0x08040ABD, 0x08040ACF, 0x08040AD3)) return;

    abi.fetches(6);
    rt.r[0] = abi.read16(abi.read32(0x08040AE8));
    if (!abi.call(decls.func_0801990C, 0x08040ADB)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Draw shop/War Room option strip rows (`0x08020414` + `0x0801B888`) indexed by `[[0x08041EEC]+0x57]` (`0x08041E94`).
pub fn func_08041E94() callconv(.c) void {
    if (!abi.enter(0x08041E94)) return;
    abi.fetches(15);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const state_ref = abi.read32(0x08041EEC);
    const val0 = abi.read8(abi.read32(state_ref) +% 0x57);
    abi.setRegNz(&rt.r[0], ((@as(u32, val0) *% 5) << 3) +% 4);
    abi.setRegNz(&rt.r[1], 0x12);
    abi.setRegNz(&rt.r[2], 2);
    if (!abi.call(map.func_08020414, 0x08041EAF)) return;

    abi.fetches(16);
    const val1 = abi.read8(abi.read32(state_ref) +% 0x57);
    const signed_x = rt.asrConst(((@as(u32, val1) *% 5) << 19) +% (@as(u32, 0xB0) << 14), 16);
    abi.setRegNz(&rt.r[0], signed_x);
    abi.setRegNz(&rt.r[1], 0x12);
    abi.setRegNz(&rt.r[2], 3);
    if (!abi.call(map.func_08020414, 0x08041ECB)) return;

    abi.fetches(15);
    const val2 = abi.read8(abi.read32(state_ref) +% 0x57);
    const x_tbl = abi.read32(0x08041EF0);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(x_tbl +% (@as(u32, val2) << 1))));
    abi.setRegNz(&rt.r[1], 0x10);
    rt.r[2] = abi.read32(0x08041EF4);
    rt.r[3] = abi.read32(0x08041EF8);
    if (!abi.call(hw.func_0801B888, 0x08041EE5)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn drawAnimatedMenuIconPalette(
    comptime has_stack_idx: bool,
    comptime tbl_ref: u32,
    comptime cnt_ref: u32,
    comptime spr_ref: u32,
    comptime ret1: u32,
    comptime ret2: u32,
    comptime ret3: u32,
) void {
    abi.fetches(if (has_stack_idx) 23 else 18);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const sx: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    const sy: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[1])));
    const tile_lo = rt.r[2] & 0xFFFF;
    const pal_bank = rt.r[3] & 0xFFFF;
    const gfx = if (has_stack_idx)
        abi.read32(abi.read32(tbl_ref) +% ((abi.read32(rt.r[13] +% 0xC) & 0xFFFF) << 2))
    else
        abi.read32(tbl_ref);

    rt.r[0] = sx;
    rt.r[1] = sy;
    rt.r[2] = gfx;
    abi.setRegNz(&rt.r[3], tile_lo | ((pal_bank & 0xF) << 12));
    if (!abi.call(hw.func_0801B888, ret1)) return;

    abi.fetches(8);
    abi.setRegNz(&rt.r[0], abi.read32(abi.read32(cnt_ref)) >> 2);
    abi.setRegNz(&rt.r[1], 0xF);
    if (!abi.call(math.func_0807B6AC, ret2)) return;

    abi.fetches(14);
    rt.r[0] = abi.read32(spr_ref) +% (rt.r[0] << 1);
    abi.setRegNz(&rt.r[1], ((pal_bank +% 0x10) << 5) +% 0xE);
    abi.setRegNz(&rt.r[2], 2);
    if (!abi.call(dma.func_08011374, ret3)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Draw indexed menu cursor icon (`0x0801B888`) and DMA blink palette `0x08011374` (`0x08041F90`).
pub fn func_08041F90() callconv(.c) void {
    if (!abi.enter(0x08041F90)) return;
    drawAnimatedMenuIconPalette(true, 0x08041FE4, 0x08041FE8, 0x08041FEC, 0x08041FBB, 0x08041FC7, 0x08041FDF);
}

/// Draw fixed menu cursor icon (`0x0801B888`) and DMA blink palette `0x08011374` (`0x08041FF0`).
pub fn func_08041FF0() callconv(.c) void {
    if (!abi.enter(0x08041FF0)) return;
    drawAnimatedMenuIconPalette(false, 0x0804203C, 0x08042040, 0x08042044, 0x08042011, 0x0804201D, 0x08042035);
}

/// Reposition menu cursor via `0x08013578`/`0x08013550`, spawn proc `[0x080420CC]`, and play cue `0x72` (`0x08042084`).
pub fn func_08042084() callconv(.c) void {
    if (!abi.enter(0x08042084)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    const slot_ref = abi.read32(0x080420C8);
    const sp_base = rt.r[13];
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = sp_base;
    rt.r[2] = sp_base +% 2;
    if (!abi.call(sprite_anim.func_08013578, 0x0804209B)) return;

    abi.fetches(13);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(sp_base)));
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(sp_base +% 2) -% 2));
    if (!abi.call(sprite_anim.func_08013550, 0x080420B1)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x080420CC);
    abi.setRegNz(&rt.r[1], 0x7F);
    if (!abi.call(decls.func_0801320C, 0x080420B9)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0x72);
    if (!abi.call(sound.func_0803D880, 0x080420BF)) return;

    abi.fetches(6);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down `[0x08042DB8..0x08042DC0]` procs after `0x080124D4` (`0x08042D9C`).
pub fn func_08042D9C() callconv(.c) void {
    if (!abi.enter(0x08042D9C)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(sprite_anim.func_080124D4, 0x08042DA3)) return;
    inline for ([_]u32{ 0x08042DB8, 0x08042DBC, 0x08042DC0 }, [_]u32{ 0x08042DA9, 0x08042DAF, 0x08042DB5 }) |ref, ret_addr| {
        abi.fetches(5);
        rt.r[0] = abi.read32(ref);
        if (!abi.call(decls.func_0801329C, ret_addr)) return;
    }
    abi.fetches(4);
    abi.popReturn();
}

/// Clear `8x2` UI box and strip-draw `[0x08043000][[0x08043004]]` via `0x08012A68` (`0x08042FA8`).
pub fn func_08042FA8() callconv(.c) void {
    if (!abi.enter(0x08042FA8)) return;
    abi.fetches(21);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const pal_bank = rt.r[0] & 0xFFFF;
    const bg_buf = abi.read32(abi.read32(0x08042FF8)) +% abi.read32(0x08042FFC);
    abi.write32(rt.r[13], 2);
    abi.write32(rt.r[13] +% 4, 0x174);
    rt.r[0] = bg_buf;
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 8);
    if (!abi.call(hw.func_08010C70, 0x08042FCF)) return;

    abi.fetches(18);
    const dst = abi.read32(abi.read32(0x08042FF8)) +% abi.read32(0x08042FFC);
    const mode = abi.read8(abi.read32(0x08043004));
    const src = abi.read32(abi.read32(0x08043000) +% (@as(u32, mode) << 2));
    abi.write32(rt.r[13], (pal_bank << 28) >> 16);
    abi.write32(rt.r[13] +% 4, 0);
    abi.setRegNz(&rt.r[0], 0);
    abi.setRegNz(&rt.r[1], 0);
    rt.r[2] = dst;
    rt.r[3] = src;
    if (!abi.call(decls.func_08012A68, 0x08042FEF)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Load sub-panel tiles `0x0800FE18`, palette `0x1C0`, and fill BG frame `0x08010C18` (`0x08043C64`).
pub fn func_08043C64() callconv(.c) void {
    if (!abi.enter(0x08043C64)) return;
    abi.fetches(16);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    const tile_idx = rt.r[0] & 0xFFFF;
    const pal_idx = rt.r[1] & 0xFFFF;
    rt.r[0] = abi.read32(0x08043CB0);
    abi.setRegNz(&rt.r[1], (tile_idx << 5) +% abi.read32(0x08043CB4));
    if (!abi.call(hw.func_0800FE18, 0x08043C81)) return;

    abi.fetches(11);
    rt.r[0] = (pal_idx << 6) +% abi.read32(0x08043CB8);
    abi.setRegNz(&rt.r[1], 0x1C0);
    abi.setRegNz(&rt.r[2], 0x40);
    if (!abi.call(dma.func_08011330, 0x08043C93)) return;

    abi.fetches(13);
    abi.write32(rt.r[13], tile_idx | 0xE000);
    rt.r[0] = abi.read32(0x08043CBC);
    rt.r[1] = abi.read32(0x08043CC0);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_08010C18, 0x08043CA9)) return;

    abi.fetches(6);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down UI procs `[0x08044ED8..0x08044EE4]` via `0x0801329C` (`0x08044EB8`).
pub fn func_08044EB8() callconv(.c) void {
    if (!abi.enter(0x08044EB8)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08044ED8);
    if (!abi.call(decls.func_0801329C, 0x08044EC1)) return;
    inline for ([_]u32{ 0x08044EDC, 0x08044EE0, 0x08044EE4 }, [_]u32{ 0x08044EC7, 0x08044ECD, 0x08044ED3 }) |ref, ret_addr| {
        abi.fetches(5);
        rt.r[0] = abi.read32(ref);
        if (!abi.call(decls.func_0801329C, ret_addr)) return;
    }
    abi.fetches(4);
    abi.popReturn();
}

/// Draw UI detail dialog for slot `r0` via `0x08045AC8`, clear BG regions, draw strip `0x08012B04`, and refresh (`0x08046564`).
pub fn func_08046564() callconv(.c) void {
    if (!abi.enter(0x08046564)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const obj = rt.r[0];
    rt.r[1] = abi.read8(obj +% 0x1E);
    if (!abi.call(decls.func_08045AC8, 0x08046571)) return;

    abi.fetches(14);
    const bg_buf = abi.read32(0x080465C4);
    abi.write32(rt.r[13], 2);
    abi.write32(rt.r[13] +% 4, 0x174);
    rt.r[0] = bg_buf;
    abi.setRegNz(&rt.r[1], 0xF);
    abi.setRegNz(&rt.r[2], 1);
    abi.setRegNz(&rt.r[3], 1);
    if (!abi.call(hw.func_08010C70, 0x08046589)) return;

    abi.fetches(11);
    abi.write32(rt.r[13], 0xC);
    abi.write32(rt.r[13] +% 4, 0x174);
    rt.r[0] = bg_buf;
    abi.setRegNz(&rt.r[1], 1);
    abi.setRegNz(&rt.r[2], 7);
    abi.setRegNz(&rt.r[3], 0x1C);
    if (!abi.call(hw.func_08010C70, 0x0804659B)) return;

    abi.fetches(14);
    abi.write32(rt.r[13], 0x4000);
    abi.write32(rt.r[13] +% 4, 0);
    abi.setRegNz(&rt.r[0], 0x10);
    abi.setRegNz(&rt.r[1], 1);
    rt.r[2] = bg_buf;
    abi.setRegNz(&rt.r[3], @as(u32, abi.read8(obj +% 0x1F)) +% 1);
    if (!abi.call(decls.func_08012B04, 0x080465B3)) return;

    abi.fetches(5);
    rt.r[0] = obj;
    if (!abi.call(decls.func_0804625C, 0x080465B9)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08011804, 0x080465BD)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Upload UI panel chars (`0x0800FE18`), map (`0x08010C18`), and palette (`0x08011310`) (`0x08046E24`).
pub fn func_08046E24() callconv(.c) void {
    if (!abi.enter(0x08046E24)) return;
    abi.fetches(19);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    const tile_idx = rt.r[0] & 0xFFFF;
    const pal_bank = rt.r[1] & 0xFFFF;
    const pal_idx = rt.r[2] & 0xFF;
    rt.r[0] = abi.read32(0x08046E78);
    abi.setRegNz(&rt.r[1], (tile_idx << 5) +% abi.read32(0x08046E7C));
    if (!abi.call(hw.func_0800FE18, 0x08046E47)) return;

    abi.fetches(13);
    abi.write32(rt.r[13], ((pal_bank << 12) | tile_idx) & 0xFFFF);
    rt.r[0] = abi.read32(0x08046E80);
    rt.r[1] = abi.read32(0x08046E84);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_08010C18, 0x08046E5D)) return;

    abi.fetches(12);
    rt.r[0] = (pal_idx << 5) +% abi.read32(0x08046E88);
    abi.setRegNz(&rt.r[1], (pal_bank << 21) >> 16);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011310, 0x08046E71)) return;

    abi.fetches(6);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Reset summary cursor globals `[0x08048A78..0x08048A7C]` and tear down procs `[0x08048A80..0x08048A88]` (`0x08048A44`).
pub fn func_08048A44() callconv(.c) void {
    if (!abi.enter(0x08048A44)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    abi.write16(abi.read32(0x08048A78), 0);
    abi.write16(abi.read32(0x08048A7C), 0);
    rt.r[0] = abi.read32(0x08048A80);
    if (!abi.call(decls.func_0801329C, 0x08048A57)) return;

    abi.fetches(6);
    const shared_proc = abi.read32(0x08048A84);
    inline for ([_]u32{ 0x08048A5F, 0x08048A65, 0x08048A6B }) |ret_addr| {
        if (ret_addr != 0x08048A5F) abi.fetches(5);
        rt.r[0] = shared_proc;
        if (!abi.call(decls.func_0801329C, ret_addr)) return;
    }

    abi.fetches(5);
    rt.r[0] = abi.read32(0x08048A88);
    if (!abi.call(decls.func_0801329C, 0x08048A71)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Position and draw battle results panel via `0x08013578`, `0x08048F5C`, palettes `0x380`/`0x360`, and spawn `[0x0804929C]` (`0x08049220`).
pub fn func_08049220() callconv(.c) void {
    if (!abi.enter(0x08049220)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    const sp_base = rt.r[13];
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(abi.read32(0x0804928C))));
    rt.r[1] = sp_base;
    rt.r[2] = sp_base +% 2;
    if (!abi.call(sprite_anim.func_08013578, 0x08049237)) return;

    abi.fetches(24);
    const panel = abi.read32(abi.read32(0x08049290));
    const px = abi.read16(sp_base);
    const py = abi.read16(sp_base +% 2);
    const prev_st = abi.read16(panel +% 4);
    abi.write16(panel +% 0x14, px -% 4);
    abi.write16(panel +% 0x16, py +% 2);
    abi.write16(panel +% 0x18, prev_st);
    rt.r[0] = (px +% 0x2A) & 0xFFFF;
    rt.r[1] = (py +% 7) & 0xFFFF;
    rt.r[2] = (prev_st +% 0xC0) & 0xFFFF;
    rt.r[3] = panel;
    if (!abi.call(decls.func_08048F5C, 0x08049263)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08049294);
    abi.setRegNz(&rt.r[1], 0x380);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x0804926F)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08049298);
    abi.setRegNz(&rt.r[1], 0x360);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x0804927B)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x0804929C);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, 0x08049283)) return;

    abi.fetches(6);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// DMA two-digit countdown glyphs (`0x61 - r1`) into BG VRAM row `r0` (`0x08049674`).
pub fn func_08049674() callconv(.c) void {
    if (!abi.enter(0x08049674)) return;
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

    const row = rt.r[0] & 0xFFFF;
    const digits_val = (0x61 -% (rt.r[1] & 0xFFFF)) & 0xFFFF;
    rt.r[0] = digits_val;
    abi.setRegNz(&rt.r[1], 0xA);
    if (!abi.call(decls.func_0807B634, 0x08049695)) return;

    abi.fetches(15);
    const gfx_src = abi.read32(0x080496DC);
    const vram_dst = abi.read32(0x080496E0);
    rt.r[0] = ((rt.r[0] << 16) >> 11) +% gfx_src;
    abi.setRegNz(&rt.r[1], ((row +% 0x1D) << 5) +% vram_dst);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_0800FDA4, 0x080496AF)) return;

    abi.fetches(6);
    rt.r[0] = digits_val;
    abi.setRegNz(&rt.r[1], 0xA);
    if (!abi.call(math.func_0807B6AC, 0x080496B7)) return;

    abi.fetches(15);
    rt.r[0] = ((rt.r[0] << 16) >> 11) +% 0x140 +% gfx_src;
    abi.setRegNz(&rt.r[1], ((row +% 0x1E) << 5) +% vram_dst);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_0800FDA4, 0x080496D1)) return;

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

/// DMA two halves (`q*0x100` & `rem*0x100+0x600`) of numeric/letter strip for `(r0 - 1) /% 6` (`0x080496E4`).
pub fn func_080496E4() callconv(.c) void {
    if (!abi.enter(0x080496E4)) return;
    abi.fetches(17);
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

    const idx = (rt.r[0] & 0xFFFF) -% 1;
    const base_tile = rt.r[1] & 0xFFFF;
    rt.r[0] = idx;
    abi.setRegNz(&rt.r[1], 6);
    if (!abi.call(math.func_0807B564, 0x08049703)) return;

    abi.fetches(17);
    const gfx_src = abi.read32(0x08049750);
    const vram_dst = abi.read32(0x08049754);
    rt.r[0] = ((rt.r[0] << 16) >> 8) +% gfx_src;
    abi.setRegNz(&rt.r[1], ((base_tile +% 0xC0) << 5) +% vram_dst);
    abi.setRegNz(&rt.r[2], 0x100);
    if (!abi.call(dma.func_0800FDA4, 0x08049721)) return;

    abi.fetches(6);
    rt.r[0] = idx;
    abi.setRegNz(&rt.r[1], 6);
    if (!abi.call(math.func_0807B488, 0x08049729)) return;

    abi.fetches(15);
    rt.r[0] = ((rt.r[0] << 16) >> 8) +% 0x600 +% gfx_src;
    abi.setRegNz(&rt.r[1], ((base_tile +% 0xC8) << 5) +% vram_dst);
    abi.setRegNz(&rt.r[2], 0x100);
    if (!abi.call(dma.func_0800FDA4, 0x08049743)) return;

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

/// Decompress `(r0 - 1) /% 6` rank/header graphics via `0x0800FE24` into `base_tile + 0xDC/0xE4` (`0x08049758`).
pub fn func_08049758() callconv(.c) void {
    if (!abi.enter(0x08049758)) return;
    abi.fetches(14);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const idx = (rt.r[0] & 0xFFFF) -% 1;
    const base_tile = rt.r[1] & 0xFFFF;
    rt.r[0] = idx;
    abi.setRegNz(&rt.r[1], 6);
    if (!abi.call(math.func_0807B564, 0x08049771)) return;

    abi.fetches(14);
    const vram_dst = abi.read32(0x080497B0);
    rt.r[0] = abi.read32(abi.read32(0x080497AC) +% ((rt.r[0] << 16) >> 14));
    abi.setRegNz(&rt.r[1], ((base_tile +% 0xDC) << 5) +% vram_dst);
    if (!abi.call(decls.func_0800FE24, 0x08049789)) return;

    abi.fetches(6);
    rt.r[0] = idx;
    abi.setRegNz(&rt.r[1], 6);
    if (!abi.call(math.func_0807B488, 0x08049791)) return;

    abi.fetches(13);
    rt.r[0] = abi.read32(abi.read32(0x080497B4) +% ((rt.r[0] << 16) >> 14));
    abi.setRegNz(&rt.r[1], ((base_tile +% 0xE4) << 5) +% vram_dst);
    if (!abi.call(decls.func_0800FE24, 0x080497A7)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down result overlay procs `[0x0804985C..0x0804986C]` and flush `0x080498B0` (`0x08049834`).
pub fn func_08049834() callconv(.c) void {
    if (!abi.enter(0x08049834)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0804985C);
    if (!abi.call(decls.func_0801329C, 0x0804983D)) return;
    inline for (
        [_]u32{ 0x08049860, 0x08049864, 0x08049868, 0x0804986C },
        [_]u32{ 0x08049843, 0x08049849, 0x0804984F, 0x08049855 },
    ) |ref, ret_addr| {
        abi.fetches(5);
        rt.r[0] = abi.read32(ref);
        if (!abi.call(decls.func_0801329C, ret_addr)) return;
    }
    abi.fetches(4);
    if (!abi.call(func_080498B0, 0x08049859)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Load active page background (`0x0800FE18`), palette `0x380`, and run `0x08049C8C` after `0x080136A4` (`0x08049CF0`).
pub fn func_08049CF0() callconv(.c) void {
    if (!abi.enter(0x08049CF0)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(abi.read32(0x08049D4C))));
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_080136A4, 0x08049CFF)) return;

    abi.fetches(20);
    const gfx_tbl = abi.read32(0x08049D50);
    const meta_tbl = abi.read32(0x08049D54);
    const map_arr = abi.read32(0x08049D58);
    const page_ptr = abi.read32(0x08049D5C);
    const item_id = abi.read8(map_arr +% abi.read8(page_ptr));
    const gfx_id = abi.read8(meta_tbl +% (@as(u32, item_id) *% 0xC) +% 0xA);
    rt.r[0] = abi.read32(gfx_tbl +% (@as(u32, gfx_id) << 2));
    rt.r[1] = abi.read32(0x08049D60);
    if (!abi.call(hw.func_0800FE18, 0x08049D23)) return;

    abi.fetches(18);
    const item_id2 = abi.read8(map_arr +% abi.read8(page_ptr));
    const pal_id = abi.read8(meta_tbl +% (@as(u32, item_id2) *% 0xC) +% 8);
    rt.r[0] = (@as(u32, pal_id) << 5) +% abi.read32(0x08049D64);
    abi.setRegNz(&rt.r[1], 0x380);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x08049D43)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08049C8C, 0x08049D47)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Bind War Room / CO slot `u8(r0)` to entry `u8(r1)` via `0x0800FE18` and palette `0x08011330` (`0x0804A20C`).
pub fn func_0804A20C() callconv(.c) void {
    if (!abi.enter(0x0804A20C)) return;
    abi.fetches(34);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const slot = rt.r[0] & 0xFF;
    const idx = rt.r[1] & 0xFF;
    const state_ref = abi.read32(0x0804A268);
    const dst_byte_addr = abi.read32(state_ref) +% 0x30 +% slot;
    abi.write8(dst_byte_addr, abi.read8(abi.read32(0x0804A26C) +% idx));
    const entry_off = @as(u32, abi.read8(dst_byte_addr) & 0x7F) *% 0xC;
    const meta_tbl = abi.read32(0x0804A270);
    rt.r[0] = abi.read32(meta_tbl +% entry_off +% 4);
    rt.r[1] = (slot << 11) +% abi.read32(0x0804A274);
    if (!abi.call(hw.func_0800FE18, 0x0804A24D)) return;

    abi.fetches(13);
    const pal_id = abi.read8(meta_tbl +% entry_off +% 8);
    rt.r[0] = (@as(u32, pal_id) << 5) +% abi.read32(0x0804A278);
    abi.setRegNz(&rt.r[1], (slot +% 0x16) << 5);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x0804A263)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Measure stacked text lines (`0x0802FC70` ids `0x6D`, `0x6E`) and upload rank icon palette (`0x08011330`) (`0x0804B72C`).
pub fn func_0804B72C() callconv(.c) void {
    if (!abi.enter(0x0804B72C)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    var cur_y = rt.r[0] & 0xFFFF;
    const pal_slot = rt.r[1] & 0xFFFF;
    rt.r[0] = cur_y;
    abi.setRegNz(&rt.r[1], 0x6D);
    if (!abi.call(battle.func_0802FC70, 0x0804B743)) return;

    abi.fetches(9);
    cur_y = (cur_y +% rt.r[0]) & 0xFFFF;
    rt.r[0] = cur_y;
    abi.setRegNz(&rt.r[1], 0x6E);
    if (!abi.call(battle.func_0802FC70, 0x0804B751)) return;

    abi.fetches(17);
    const pal_idx = abi.read8(abi.read32(0x0804B774) +% 0x194);
    rt.r[0] = (@as(u32, pal_idx) << 5) +% abi.read32(0x0804B778);
    abi.setRegNz(&rt.r[1], ((pal_slot +% 0x10) << 21) >> 16);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x0804B76F)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear `17x4` panel box on `[0x0804C6DC]`, tear down proc `[0x0804C6E0]`, and run callback `0x080183C0` (`0x0804C69C`).
pub fn func_0804C69C() callconv(.c) void {
    if (!abi.enter(0x0804C69C)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 8;

    abi.setRegNz(&rt.r[0], 1);
    if (!abi.call(decls.func_08018E10, 0x0804C6A7)) return;

    abi.fetches(13);
    abi.write32(rt.r[13], 4);
    abi.write32(rt.r[13] +% 4, 0x174);
    rt.r[0] = abi.read32(0x0804C6DC);
    abi.setRegNz(&rt.r[1], 7);
    abi.setRegNz(&rt.r[2], 0xF);
    abi.setRegNz(&rt.r[3], 0x17);
    if (!abi.call(hw.func_08010C70, 0x0804C6BD)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08011804, 0x0804C6C1)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x0804C6E0);
    if (!abi.call(decls.func_0801329C, 0x0804C6C7)) return;

    abi.fetches(9);
    rt.r[0] = abi.read32(abi.read32(abi.read32(0x0804C6E4)) +% abi.read32(0x0804C6E8));
    if (!abi.call(decls.func_080183C0, 0x0804C6D5)) return;

    abi.fetches(5);
    rt.r[13] +%= 8;
    abi.popReturn();
}

/// Enable UI overlay window + alpha blend registers (`[0x0804CC70..0x0804CC94]`) around `0x080104B0` (`0x0804CBE0`).
pub fn func_0804CBE0() callconv(.c) void {
    if (!abi.enter(0x0804CBE0)) return;
    abi.fetches(7);
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

    if (!abi.call(decls.func_080104D4, 0x0804CBEB)) return;

    abi.fetches(45);
    const dispcnt_hi_ptr = abi.read32(0x0804CC70) +% 1;
    abi.write8(dispcnt_hi_ptr, abi.read8(dispcnt_hi_ptr) | 0x20);
    abi.write8(abi.read32(0x0804CC74), 2);
    abi.write8(abi.read32(0x0804CC78), 0x72);
    abi.write8(abi.read32(0x0804CC7C), 0xEF);
    abi.write8(abi.read32(0x0804CC80), 0xA0);
    const winin_lo = abi.read32(0x0804CC84);
    abi.write8(winin_lo, abi.read8(winin_lo) | 1 | 2 | 4 | 8 | 0x10);
    const winout_lo = abi.read32(0x0804CC88);
    abi.write8(winout_lo, abi.read8(winout_lo) | 1 | 2 | 4 | 8 | 0x10 | 0x20);
    if (!abi.call(hw.func_080104B0, 0x0804CC41)) return;

    abi.fetches(25);
    const bld = abi.read32(0x0804CC8C);
    const bld_lo = (abi.read8(bld) & 0x3F) | 0x40 | 2;
    abi.write8(bld, bld_lo);
    abi.write8(bld +% 1, abi.read8(bld +% 1) | 8 | 0x10);
    abi.write16(abi.read32(0x0804CC90), 0xF);
    const bldy_ptr = abi.read32(0x0804CC94);
    abi.write16(bldy_ptr, 6);
    abi.setRegNz(&rt.r[0], 6);
    rt.r[1] = bldy_ptr;
    rt.r[2] = bld;
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

/// DMA four 0x100-byte portrait/UI strips (`[0x0804DAC0..0x0804DADC]`) via `0x0800FDA4` (`0x0804DA8C`).
pub fn func_0804DA8C() callconv(.c) void {
    if (!abi.enter(0x0804DA8C)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[0] = abi.read32(0x0804DAC0);
    rt.r[1] = abi.read32(0x0804DAC4);
    abi.setRegNz(&rt.r[2], 0x100);
    if (!abi.call(dma.func_0800FDA4, 0x0804DA9D)) return;

    inline for (
        [_][2]u32{
            .{ 0x0804DAC8, 0x0804DACC },
            .{ 0x0804DAD0, 0x0804DAD4 },
            .{ 0x0804DAD8, 0x0804DADC },
        },
        [_]u32{ 0x0804DAA7, 0x0804DAB1, 0x0804DABB },
    ) |pair, ret_addr| {
        abi.fetches(7);
        rt.r[0] = abi.read32(pair[0]);
        rt.r[1] = abi.read32(pair[1]);
        abi.setRegNz(&rt.r[2], 0x100);
        if (!abi.call(dma.func_0800FDA4, ret_addr)) return;
    }

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Upload dual `0x100`-byte font/border strips (`[0x0804F890..0x0804F898]`), configure alpha blend, and call `0x0800FC74` (`0x0804F838`).
pub fn func_0804F838() callconv(.c) void {
    if (!abi.enter(0x0804F838)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[0] = abi.read32(0x0804F890);
    abi.setRegNz(&rt.r[1], @as(u32, 0xC0) << 19);
    abi.setRegNz(&rt.r[2], 0x100);
    if (!abi.call(dma.func_0800FDA4, 0x0804F84B)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x0804F894);
    rt.r[1] = abi.read32(0x0804F898);
    abi.setRegNz(&rt.r[2], 0x100);
    if (!abi.call(dma.func_0800FDA4, 0x0804F855)) return;

    abi.fetches(4);
    if (!abi.call(hw.func_080104B0, 0x0804F859)) return;

    abi.fetches(26);
    const bld = abi.read32(0x0804F89C);
    abi.write8(bld, (abi.read8(bld) & 0x3F) | 0x40 | 2);
    abi.write8(bld +% 1, abi.read8(bld +% 1) | 8 | 0x10);
    abi.write16(abi.read32(0x0804F8A0), 0xF);
    abi.write16(abi.read32(0x0804F8A4), 6);
    rt.r[0] = abi.read32(0x0804F8A8);
    if (!abi.call(decls.func_0800FC74, 0x0804F889)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear dialog overlay (`func_08046E24(0,0,0)`), hide BG3 (`0x08011834`), VBlank wait, and fade in (`0x0804F944`).
pub fn func_0804F944() callconv(.c) void {
    if (!abi.enter(0x0804F944)) return;
    abi.fetches(8);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0);
    if (!abi.call(func_08046E24, 0x0804F951)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011834, 0x0804F955)) return;
    abi.fetches(4);
    if (!abi.call(hw.func_080113D0, 0x0804F959)) return;
    abi.fetches(7);
    abi.setRegNz(&rt.r[0], 0);
    rt.cpuSub(&rt.r[1], 0, 1, true);
    if (!abi.call(decls.func_08011660, 0x0804F963)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Render battle preview header lines (`0x080501DC`, `0x0802FC70` ids `0x54..0x56`), palette `0x260`, and chars `0x0800FE18` (`0x08050568`).
pub fn func_08050568() callconv(.c) void {
    if (!abi.enter(0x08050568)) return;
    abi.fetches(21);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const idx_byte = abi.read8(abi.read32(abi.read32(0x080505D4)) +% 0x2E);
    const row_addr = abi.read32(abi.read32(0x080505D8)) +% (@as(u32, idx_byte) *% 0x68) +% 0x2E;
    rt.r[0] = abi.read32(0x080505D0);
    abi.setRegNz(&rt.r[1], (@as(u32, 5) -% abi.read8(row_addr)) & 0xFFFF);
    if (!abi.call(func_080501DC, 0x0805058F)) return;

    abi.fetches(7);
    var y_cur = abi.read32(0x080505DC);
    rt.r[0] = y_cur;
    abi.setRegNz(&rt.r[1], 0x54);
    if (!abi.call(battle.func_0802FC70, 0x08050599)) return;

    abi.fetches(10);
    y_cur = (y_cur +% rt.r[0]) & 0xFFFF;
    rt.r[0] = y_cur;
    abi.setRegNz(&rt.r[1], 0x55);
    if (!abi.call(battle.func_0802FC70, 0x080505A9)) return;

    abi.fetches(9);
    y_cur = (y_cur +% rt.r[0]) & 0xFFFF;
    rt.r[0] = y_cur;
    abi.setRegNz(&rt.r[1], 0x56);
    if (!abi.call(battle.func_0802FC70, 0x080505B7)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x080505E0);
    abi.setRegNz(&rt.r[1], 0x260);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x080505C3)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x080505E4);
    rt.r[1] = abi.read32(0x080505E8);
    if (!abi.call(hw.func_0800FE18, 0x080505CB)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Reset BG scroll/window registers `[0x08050E98]=0`, `[0x08050E9C]=3` and disable BG1/2 layers (`0x08050E74`).
pub fn func_08050E74() callconv(.c) void {
    if (!abi.enter(0x08050E74)) return;
    abi.fetches(11);
    abi.pushLr();
    abi.write16(abi.read32(0x08050E98), 0);
    abi.write16(abi.read32(0x08050E9C), 3);
    if (!abi.call(decls.func_0801193C, 0x08050E87)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011968, 0x08050E8B)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011814, 0x08050E8F)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011824, 0x08050E93)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Tear down primary `[0x08051CD0]` and four shared `[0x08051CD4]` overlay procs (`0x08051CA8`).
pub fn func_08051CA8() callconv(.c) void {
    if (!abi.enter(0x08051CA8)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[0] = abi.read32(0x08051CD0);
    if (!abi.call(decls.func_0801329C, 0x08051CB1)) return;

    abi.fetches(6);
    const shared_proc = abi.read32(0x08051CD4);
    inline for ([_]u32{ 0x08051CB9, 0x08051CBF, 0x08051CC5, 0x08051CCB }) |ret_addr| {
        if (ret_addr != 0x08051CB9) abi.fetches(5);
        rt.r[0] = shared_proc;
        if (!abi.call(decls.func_0801329C, ret_addr)) return;
    }

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Setup tactical unit/CO action panel slot `u16(r0)` (`0x08053368`, `0x0800FE24`, `0x08013330`) (`0x0805390C`).
pub fn func_0805390C() callconv(.c) void {
    if (!abi.enter(0x0805390C)) return;
    abi.fetches(22);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const slot = rt.r[0] & 0xFFFF;
    abi.write16(abi.read32(0x08053990), @truncate(slot));
    const idx_val = abi.read16(abi.read32(0x08053998) +% (slot << 1));
    abi.write16(abi.read32(0x08053994), idx_val);
    const entry_off = @as(u32, idx_val) *% 0xC;
    const tag = abi.read16(abi.read32(0x0805399C) +% (slot << 4));
    rt.r[0] = slot;
    if (!abi.call(decls.func_08053368, 0x08053935)) return;

    abi.fetches(15);
    const anim_tbl = abi.read32(0x080539A0);
    const tag_off = @as(u32, tag) *% 0xC;
    abi.write32(rt.r[13] +% 4, anim_tbl);
    rt.r[0] = abi.read32(anim_tbl +% tag_off);
    rt.r[1] = abi.read32(abi.read32(0x080539A4) +% (slot << 2));
    if (!abi.call(decls.func_0800FE24, 0x0805394F)) return;

    abi.fetches(25);
    const unit_tbl = abi.read32(0x080539A8);
    const anim_ref = abi.read32(rt.r[13] +% 4);
    const byte1 = abi.read16(unit_tbl +% (slot *% 0xA) +% 8);
    const delay_byte = ((byte1 *% 7) & 0xFF);
    abi.write32(rt.r[13], delay_byte);
    rt.r[0] = abi.read32(0x080539AC);
    abi.setRegNz(&rt.r[1], 1);
    rt.r[2] = abi.read32(anim_ref +% tag_off +% 8);
    rt.r[3] = abi.read32(anim_ref +% tag_off +% 4);
    _ = entry_off;
    if (!abi.call(decls.func_08013330, 0x0805397D)) return;

    abi.fetches(12);
    const signed_ret = rt.asrConst(rt.r[0] << 24, 24);
    const out_ptr = abi.read32(0x080539B0) +% (slot *% 0xA) +% 8;
    abi.write16(out_ptr, @truncate(signed_ret));
    abi.setRegNz(&rt.r[0], signed_ret);
    rt.r[1] = abi.read32(0x080539B0) +% 8;
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Render animated battle-unit cursor bracket sprites for slot `r0` (`0x0806E0E4`).
pub fn func_0806E0E4() callconv(.c) void {
    if (!abi.enter(0x0806E0E4)) return;
    abi.fetches(12);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[7] = rt.r[0];
    rt.r[0] = @as(u32, @bitCast(abi.signExtend16(abi.read16(rt.r[7] +% 0x28)))) +% 0x20;
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(rt.r[7] +% 0x2A)));
    rt.r[2] = abi.read16(rt.r[7] +% 0x1C);
    if (!abi.call(decls.func_0806E044, 0x0806E0F9)) return;

    abi.fetches(11);
    rt.r[0] = @as(u32, @bitCast(abi.signExtend16(abi.read16(rt.r[7] +% 0x28)))) +% 0x20;
    rt.r[1] = @as(u32, @bitCast(abi.signExtend16(abi.read16(rt.r[7] +% 0x2A)))) +% 0x10;
    rt.r[2] = abi.read16(rt.r[7] +% 0x1C);
    if (!abi.call(hw.func_0806E098, 0x0806E10B)) return;

    abi.fetches(19);
    const mask_x = abi.read32(0x0806E15C);
    const mask_y_base = mask_x -% 0xE3;
    rt.r[0] = (0x200 +% abi.read16(rt.r[7] +% 0x28)) & mask_x;
    rt.r[1] = (abi.read16(rt.r[7] +% 0x2A) +% mask_y_base) & 0xFF;
    rt.r[2] = abi.read32(0x0806E160);
    rt.r[3] = abi.read16(rt.r[7] +% 0x3E);
    if (!abi.call(hw.func_0801B888, 0x0806E12D)) return;

    abi.fetches(17);
    rt.r[0] = (0x200 +% abi.read16(rt.r[7] +% 0x28)) & mask_x;
    rt.r[1] = (abi.read16(rt.r[7] +% 0x2A) +% 0x100) & 0xFF;
    rt.r[2] = abi.read32(0x0806E164);
    rt.r[3] = abi.read16(rt.r[7] +% 0x44);
    if (!abi.call(hw.func_0801B888, 0x0806E14B)) return;

    abi.fetches(10);
    abi.write8(rt.r[7] +% 0x49, abi.read8(rt.r[7] +% 0x48));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[7] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Queue active tactical dialog cursor indicator and arrow widgets (`0x0806F298`).
pub fn func_0806F298() callconv(.c) void {
    if (!abi.enter(0x0806F298)) return;
    abi.fetches(26);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const menu_ctx = abi.read32(abi.read32(0x0806F2F4));
    const slot_idx: u32 = @bitCast(abi.signExtend8(abi.read8(menu_ctx +% 0x36)));
    rt.r[4] = abi.read32(menu_ctx +% 0x48 +% (slot_idx << 2));
    rt.r[5] = @as(u32, abi.read8(menu_ctx +% 0x11 +% slot_idx)) << 2;

    const base_x: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x28)));
    const base_y: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x2A)));
    rt.r[0] = base_x;
    rt.r[1] = base_y +% rt.r[5];
    rt.r[2] = 0x11;
    rt.r[3] = 0x10;
    if (!abi.call(func_0806D714, 0x0806F2C9)) return;

    abi.fetches(11);
    rt.r[0] = @as(u32, @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x28)))) +% 9;
    rt.r[1] = @as(u32, @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x2A)))) +% (rt.r[5] -% 4);
    if (!abi.call(decls.func_0806D624, 0x0806F2DB)) return;

    abi.fetches(11);
    rt.r[0] = @as(u32, @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x28)))) +% 9;
    rt.r[1] = @as(u32, @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x2A)))) +% (rt.r[5] +% 0x1C);
    if (!abi.call(decls.func_0806D69C, 0x0806F2ED)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Configure dialog/results BG layers, scroll state, and effect timers on proc `r0` (`0x08071F68`).
pub fn func_08071F68() callconv(.c) void {
    if (!abi.enter(0x08071F68)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[5] = rt.r[0];
    if (!abi.call(hw.func_080104B0, 0x08071F71)) return;

    abi.fetches(56);
    const disp_ctl = abi.read32(0x08071FDC);
    const b0 = ((0x3F & @as(u32, abi.read8(disp_ctl))) | 0x40) & ~@as(u32, 0xF) | 0x10;
    abi.write8(disp_ctl, @truncate(b0));
    const b1 = (@as(u32, abi.read8(disp_ctl +% 1)) & ~@as(u32, 0x15)) | 0x0A;
    abi.write8(disp_ctl +% 1, @truncate(b1));
    abi.write16(abi.read32(0x08071FE0), 8);
    abi.write16(abi.read32(0x08071FE4), 8);
    const p2 = abi.read32(0x08071FE8);
    abi.write8(p2, @truncate(@as(u32, abi.read8(p2)) | 0x20));
    abi.write16(rt.r[5] +% 0x44, 0x10);
    abi.write32(rt.r[5] +% 0x30, 0x15);
    abi.write32(rt.r[5] +% 0x34, 0x4D);
    abi.write32(rt.r[5] +% 0x38, 0x85);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Launch campaign victory/match-result summary dialogue sequence for proc `r0` (`0x08072DB0`).
pub fn func_08072DB0() callconv(.c) void {
    if (!abi.enter(0x08072DB0)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 0x34;

    rt.r[4] = rt.r[0];
    rt.r[0] = 0;
    if (!abi.call(decls.func_0806CD78, 0x08072DBD)) return;

    abi.fetches(10);
    const step_ptr = abi.read32(0x08072E2C);
    const step_idx = abi.read8(step_ptr);
    abi.write8(step_ptr, step_idx +% 1);
    rt.r[0] = step_idx;
    if (!abi.call(decls.func_080702EC, 0x08072DCD)) return;

    abi.fetches(31);
    abi.write16(rt.r[4] +% 0x42, @truncate(rt.r[0]));
    const args = [_]u32{ 1, 0x64, 0x5A, 6, 4, 1, 0x13, 1, 0x64, 0xA, 1, 1 };
    inline for (args, 0..) |v, i| {
        abi.write32(rt.r[13] +% @as(u32, i * 4), v);
    }
    abi.write32(rt.r[13] +% 0x30, abi.read32(0x08072E30));
    rt.r[0] = 8;
    rt.r[1] = 3;
    rt.r[2] = 0xC;
    rt.r[3] = 0xE;
    if (!abi.call(campaign.func_08038A70, 0x08072E07)) return;

    abi.fetches(11);
    const p1 = abi.read32(0x08072E34);
    abi.write8(p1, @truncate(@as(u32, abi.read8(p1)) | 0x80));
    rt.r[0] = abi.read32(0x08072E38);
    rt.r[1] = 0;
    if (!abi.call(decls.func_0801320C, 0x08072E19)) return;

    abi.fetches(8);
    rt.r[1] = 0x10;
    rt.r[2] = 0;
    rt.r[3] = 0xFFFF_FFFE;
    if (!abi.call(func_08072C6C, 0x08072E25)) return;

    abi.fetches(6);
    rt.r[13] +%= 0x34;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Enable blend/window BG layers and clear transition countdown on proc `r0` (`0x080747F8`).
pub fn func_080747F8() callconv(.c) void {
    if (!abi.enter(0x080747F8)) return;
    abi.fetches(81);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
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

    abi.write16(rt.r[0] +% 0x44, 0x168);
    abi.write16(rt.r[0] +% 0x42, 0);

    const p1 = abi.read32(0x08074898);
    abi.write8(p1 +% 1, @truncate(@as(u32, abi.read8(p1 +% 1)) | 0x1F));

    const p2 = abi.read32(0x0807489C);
    abi.write8(p2 +% 0, @truncate(((0xC0 | @as(u32, abi.read8(p2))) & ~@as(u32, 3)) | 0x1C));
    abi.write8(p2 +% 1, @truncate(@as(u32, abi.read8(p2 +% 1)) & ~@as(u32, 0x1F)));

    abi.write16(abi.read32(0x080748A0), 0x10);
    const p4 = abi.read32(0x080748A4);
    abi.write8(p4, @truncate((@as(u32, abi.read8(p4)) | 3) & ~@as(u32, 0x1C)));

    const val = abi.read32(0x080748AC);
    abi.write16(abi.read32(0x080748A8), @truncate(val));
    abi.write16(abi.read32(0x080748B0), @truncate(val));

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
    rt.r[7] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down campaign intro/title overlay screen and reset active proc (`0x08074C84`).
pub fn func_08074C84() callconv(.c) void {
    if (!abi.enter(0x08074C84)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(campaign.func_08038C44, 0x08074C8B)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0800FC58, 0x08074C8F)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x08074CA0);
    if (!abi.call(decls.func_0801329C, 0x08074C95)) return;
    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x08074CA4));
    if (!abi.call(decls.func_08013BD0, 0x08074C9D)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear and initialize dual 32x32 BG screens for summary/credits view (`0x080754F4`).
pub fn func_080754F4() callconv(.c) void {
    if (!abi.enter(0x080754F4)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    rt.r[0] = abi.read32(0x08075538);
    rt.r[1] = abi.read32(0x0807553C);
    if (!abi.call(hw.func_0800FE18, 0x08075501)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x08075540);
    if (!abi.call(decls.func_0806CD50, 0x08075507)) return;

    const fill_val = abi.read32(0x08075548);
    const bg_fills = [_][2]u32{
        .{ 0x08075544, 0x0807551B },
        .{ 0x0807554C, 0x0807552B },
    };
    inline for (bg_fills, 0..) |f, i| {
        abi.fetches(if (i == 0) 12 else 10);
        abi.write32(rt.r[13] +% 0, 0x20);
        abi.write32(rt.r[13] +% 4, fill_val);
        rt.r[0] = abi.read32(f[0]);
        rt.r[1] = 0;
        rt.r[2] = 0;
        rt.r[3] = 0x20;
        if (!abi.call(hw.func_08010C70, f[1])) return;
    }

    abi.fetches(4);
    if (!abi.call(decls.func_08011814, 0x0807552F)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Draw campaign ending rank badge `(5 - r0)` and paired UI labels (`0x08075808`).
pub fn func_08075808() callconv(.c) void {
    if (!abi.enter(0x08075808)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    rt.r[0] = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    if (!abi.call(decls.func_080397B8, 0x08075815)) return;

    abi.fetches(15);
    const rank_val: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    abi.write16(abi.read32(0x08075870), 0);
    rt.r[4] = abi.read32(0x08075874);
    rt.r[0] = rt.r[4];
    rt.r[1] = (5 -% rank_val) & 0xFFFF;
    if (!abi.call(func_080501DC, 0x0807582F)) return;

    abi.fetches(15);
    const pal_idx: u32 = abi.read8(abi.read32(0x08075878) +% (0x9F << 2));
    rt.r[0] = (pal_idx << 5) +% abi.read32(0x0807587C);
    rt.r[1] = 0x240;
    rt.r[2] = 0x20;
    if (!abi.call(dma.func_08011330, 0x08075849)) return;

    abi.fetches(10);
    abi.write32(rt.r[13] +% 0, abi.read32(0x08075880));
    rt.r[0] = 0x46;
    rt.r[1] = 0x82;
    rt.r[2] = rt.r[4];
    rt.r[3] = 2;
    if (!abi.call(func_0804FF1C, 0x08075859)) return;

    abi.fetches(10);
    abi.write32(rt.r[13] +% 0, abi.read32(0x08075888));
    rt.r[0] = 0x46;
    rt.r[1] = 0x8A;
    rt.r[2] = abi.read32(0x08075884);
    rt.r[3] = 2;
    if (!abi.call(func_0804FF1C, 0x08075869)) return;

    abi.fetches(6);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Set summary timer `(0xAD, 0x20)`, fade-in BGM track `0x79`, and reset OAM (`0x08075EB8`).
pub fn func_08075EB8() callconv(.c) void {
    if (!abi.enter(0x08075EB8)) return;
    abi.fetches(12);
    abi.pushLr();
    abi.write16(rt.r[0] +% 0x44, 0x20);
    abi.write16(rt.r[0] +% 0x42, 0xAD);
    if (!abi.call(hw.func_080113D0, 0x08075ECD)) return;

    abi.fetches(7);
    rt.r[0] = 0x11;
    rt.r[1] = 0xFFFF_FFFF;
    if (!abi.call(decls.func_08011660, 0x08075ED7)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_080796A4, 0x08075EDB)) return;
    abi.fetches(4);
    if (!abi.call(hw.func_080112C0, 0x08075EDF)) return;

    abi.fetches(5);
    rt.r[0] = 0x79;
    if (!abi.call(sound.func_0803D880, 0x08075EE5)) return;

    abi.fetches(4);
    abi.popReturn();
}

const UiAnimatorMode = enum {
    add160_a3_arr_shr2,
    addd4_rom2f_add2,
    direct_a4_u8,
    fixed2f8_a2,
    fixed2f8_a2_prio1,
    add_pool_3_shr4,
    stack_a2_a3_shr4,
    fixed_0_6,
};

const UiAnimatorSpawnCfg = struct {
    mode: UiAnimatorMode,
    entry_fetches: u32,
    high_regs: u8,
    pool0: u32,
    pool1: u32,
    pool2: u32 = 0,
    pool3: u32 = 0,
    finish_90c: bool,
    tail_scale: u32,
    ret_spawn: u32,
    ret_anim: u32,
    ret_pos: u32,
    ret_f0: u32,
    ret_f1: u32,
    ret_prio: u32 = 0,
    ret_t0: u32,
    ret_t1: u32,
};

fn spawnUiAnimatorSlot(comptime cfg: UiAnimatorSpawnCfg) void {
    abi.fetches(cfg.entry_fetches);
    const entry_sp = rt.r[13];
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    const saved_r10 = rt.r[10];
    if (cfg.high_regs >= 3) {
        rt.r[13] -%= 4;
        abi.write32(rt.r[13], saved_r10);
    }
    if (cfg.high_regs >= 2) {
        rt.r[13] -%= 4;
        abi.write32(rt.r[13], saved_r9);
    }
    if (cfg.high_regs >= 1) {
        rt.r[13] -%= 4;
        abi.write32(rt.r[13], saved_r8);
    }
    rt.r[13] -%= 4;

    const a0 = rt.r[0] & 0xFFFF;
    const a1 = rt.r[1] & 0xFFFF;
    const a2 = rt.r[2] & 0xFFFF;
    const a3 = rt.r[3] & 0xFFFF;
    const a4 = switch (cfg.mode) {
        .direct_a4_u8 => abi.read32(entry_sp) & 0xFF,
        .stack_a2_a3_shr4 => abi.read32(entry_sp),
        else => 0,
    };

    rt.r[0] = abi.read32(cfg.pool0);
    rt.r[2] = switch (cfg.mode) {
        .stack_a2_a3_shr4 => a4,
        else => abi.read32(cfg.pool1),
    };
    abi.write32(rt.r[13], 0);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_080133C0, cfg.ret_spawn)) return;

    abi.fetches(switch (cfg.mode) {
        .add160_a3_arr_shr2 => 15,
        .addd4_rom2f_add2 => 17,
        .direct_a4_u8, .stack_a2_a3_shr4, .fixed_0_6 => 10,
        .fixed2f8_a2, .fixed2f8_a2_prio1 => 11,
        .add_pool_3_shr4 => 14,
    });
    const slot_i32 = abi.signExtend8(@truncate(rt.r[0]));
    const slot: u32 = @bitCast(slot_i32);
    rt.r[0] = slot;
    switch (cfg.mode) {
        .add160_a3_arr_shr2 => {
            rt.r[1] = (a2 +% 0x160) & 0xFFFF;
            rt.r[2] = a3;
        },
        .addd4_rom2f_add2 => {
            rt.r[1] = (a2 +% 0xD4) & 0xFFFF;
            rt.r[2] = abi.read8(abi.read32(abi.read32(cfg.pool2)) +% 0x2F) +% 2;
        },
        .direct_a4_u8, .stack_a2_a3_shr4 => {
            rt.r[1] = a2;
            rt.r[2] = a3;
        },
        .fixed2f8_a2, .fixed2f8_a2_prio1 => {
            rt.r[1] = 0x2F8;
            rt.r[2] = a2;
        },
        .add_pool_3_shr4 => {
            rt.r[1] = (a2 +% abi.read32(cfg.pool2)) & 0xFFFF;
            abi.setRegNz(&rt.r[2], 3);
        },
        .fixed_0_6 => {
            abi.setRegNz(&rt.r[1], 0);
            abi.setRegNz(&rt.r[2], 6);
        },
    }
    if (!abi.call(proc_mod.func_0801381C, cfg.ret_anim)) return;

    abi.fetches(switch (cfg.mode) {
        .add160_a3_arr_shr2, .addd4_rom2f_add2, .add_pool_3_shr4 => 13,
        else => 11,
    });
    rt.r[0] = slot;
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(a0)));
    rt.r[2] = @bitCast(abi.signExtend16(@truncate(a1)));
    if (!abi.call(sprite_anim.func_08013550, cfg.ret_pos)) return;

    switch (cfg.mode) {
        .add160_a3_arr_shr2, .direct_a4_u8, .add_pool_3_shr4, .stack_a2_a3_shr4 => {
            const arr_pool = switch (cfg.mode) {
                .add160_a3_arr_shr2, .direct_a4_u8 => cfg.pool2,
                .add_pool_3_shr4 => cfg.pool3,
                .stack_a2_a3_shr4 => cfg.pool1,
                else => unreachable,
            };
            const field_val: u16 = switch (cfg.mode) {
                .add160_a3_arr_shr2 => @truncate(a2 >> 2),
                .direct_a4_u8 => @truncate(a4),
                .add_pool_3_shr4, .stack_a2_a3_shr4 => @truncate(a2 >> 4),
                else => unreachable,
            };
            abi.fetches(if (cfg.mode == .direct_a4_u8) 12 else 13);
            abi.write16(abi.read32(arr_pool) +% (slot *% 0x60) +% 0x1C, field_val);
        },
        else => abi.fetches(5),
    }

    rt.r[0] = slot;
    if (!abi.call(proc_mod.func_080147B8, cfg.ret_f0)) return;

    abi.fetches(5);
    rt.r[0] = slot;
    if (!abi.call(if (cfg.finish_90c) sprite_anim.func_0801490C else sprite_anim.func_080148DC, cfg.ret_f1)) return;

    if (cfg.ret_prio != 0) {
        abi.fetches(6);
        rt.r[0] = slot;
        abi.setRegNz(&rt.r[1], 1);
        if (!abi.call(decls.func_080136A4, cfg.ret_prio)) return;
    }

    abi.fetches(8);
    rt.r[0] = slot;
    rt.r[1] = cfg.tail_scale;
    if (!abi.call(sprite_anim.func_08013744, cfg.ret_t0)) return;

    abi.fetches(6);
    rt.r[0] = slot;
    rt.r[1] = cfg.tail_scale;
    if (!abi.call(sprite_anim.func_08013794, cfg.ret_t1)) return;

    abi.fetches(if (cfg.high_regs == 0) 6 else 7 +% cfg.high_regs);
    rt.r[13] +%= 4;
    if (cfg.high_regs == 1) {
        rt.r[3] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
        rt.r[8] = rt.r[3];
    } else if (cfg.high_regs == 2) {
        rt.r[3] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
        rt.r[4] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
        rt.r[8] = rt.r[3];
        rt.r[9] = rt.r[4];
    } else if (cfg.high_regs == 3) {
        rt.r[3] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
        rt.r[4] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
        rt.r[5] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
        rt.r[8] = rt.r[3];
        rt.r[9] = rt.r[4];
        rt.r[10] = rt.r[5];
    }
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn UI animator slot `(a0, a1, a2 + 0x160, a3)` with `slot+0x1C = a2 >> 2` (`0x08040218`).
pub fn func_08040218() callconv(.c) void {
    if (!abi.enter(0x08040218)) return;
    spawnUiAnimatorSlot(.{
        .mode = .add160_a3_arr_shr2,
        .entry_fetches = 33,
        .high_regs = 3,
        .pool0 = 0x080402C8,
        .pool1 = 0x080402CC,
        .pool2 = 0x080402D0,
        .finish_90c = false,
        .tail_scale = 0x100,
        .ret_spawn = 0x08040257,
        .ret_anim = 0x08040271,
        .ret_pos = 0x08040287,
        .ret_f0 = 0x0804029D,
        .ret_f1 = 0x080402A3,
        .ret_t0 = 0x080402AF,
        .ret_t1 = 0x080402B7,
    });
}

/// Initialize CO/battle info screen layout, palettes, portraits & labels (`0x08041A80`).
pub fn func_08041A80() callconv(.c) void {
    if (!abi.enter(0x08041A80)) return;
    abi.fetches(14);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    rt.r[0] = abi.read32(0x08041B68);
    rt.r[1] = abi.read32(0x08041B6C);
    abi.write32(rt.r[13], abi.read32(0x08041B70));
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 4);
    if (!abi.call(decls.func_08010C18, 0x08041A99)) return;

    abi.fetches(7);
    const tile_base = abi.read32(0x08041B74);
    rt.r[0] = tile_base;
    abi.setRegNz(&rt.r[1], 0x38);
    if (!abi.call(battle.func_0802FC70, 0x08041AA3)) return;

    abi.fetches(8);
    rt.r[0] = (rt.r[0] +% tile_base) & 0xFFFF;
    abi.setRegNz(&rt.r[1], 0x3B);
    if (!abi.call(battle.func_0802FC70, 0x08041AAF)) return;

    abi.fetches(9);
    const idx_ptr = abi.read32(0x08041B78);
    rt.r[0] = abi.read16(idx_ptr);
    rt.r[1] = 0x160;
    if (!abi.call(decls.func_080465C8, 0x08041ABD)) return;

    abi.fetches(7);
    rt.r[0] = tile_base +% 0x1F;
    abi.setRegNz(&rt.r[1], 0x19);
    if (!abi.call(battle.func_0802FC70, 0x08041AC7)) return;

    const lz_pairs = [_]struct { src: u32, dst: u32, ret: u32 }{
        .{ .src = 0x08041B7C, .dst = 0x08041B80, .ret = 0x08041ACF },
        .{ .src = 0x08041B84, .dst = 0x08041B88, .ret = 0x08041AD7 },
        .{ .src = 0x08041B8C, .dst = 0x08041B90, .ret = 0x08041ADF },
    };
    inline for (lz_pairs) |p| {
        abi.fetches(6);
        rt.r[0] = abi.read32(p.src);
        rt.r[1] = abi.read32(p.dst);
        if (!abi.call(decls.func_0800FE24, p.ret)) return;
    }

    abi.fetches(12);
    const state = abi.read32(0x08041B94);
    const pal_tbl = abi.read32(0x08041B98);
    rt.r[0] = (@as(u32, abi.read8(state +% 4)) << 5) +% pal_tbl;
    rt.r[1] = 0x280;
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x08041AF3)) return;

    abi.fetches(11);
    rt.r[0] = (@as(u32, abi.read8(state +% 0xCC)) << 5) +% pal_tbl;
    rt.r[1] = 0x2A0;
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x08041B05)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(unit.func_0801B8D4, 0x08041B0B)) return;

    abi.fetches(25);
    const txt_dst = abi.read32(0x08041B9C);
    const title_tbl = abi.read32(0x08041BA0);
    const cur_idx = abi.read16(idx_ptr);
    const arr_base = abi.read32(abi.read32(0x08041BA4));
    const entry_off = cur_idx *% 0x68;
    const title_idx = abi.read8(arr_base +% entry_off +% 0x1A);
    abi.write32(rt.r[13], 0x8000);
    abi.write32(rt.r[13] +% 4, 0);
    rt.r[0] = 3;
    rt.r[1] = 5;
    rt.r[2] = txt_dst;
    rt.r[3] = abi.read32(title_tbl +% (@as(u32, title_idx) << 2));
    if (!abi.call(decls.func_08012A68, 0x08041B39)) return;

    abi.fetches(10);
    abi.write32(rt.r[13], 0x8000);
    abi.write32(rt.r[13] +% 4, 0);
    rt.r[0] = 0x10;
    rt.r[1] = 5;
    rt.r[2] = txt_dst;
    rt.r[3] = abi.read32(0x08041BA8);
    if (!abi.call(decls.func_08012A68, 0x08041B49)) return;

    abi.fetches(10);
    abi.write32(rt.r[13], 0x8000);
    abi.write32(rt.r[13] +% 4, 0);
    rt.r[0] = 0x18;
    rt.r[1] = 5;
    rt.r[2] = txt_dst;
    rt.r[3] = abi.read32(0x08041BAC);
    if (!abi.call(decls.func_08012A68, 0x08041B59)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08041428, 0x08041B5D)) return;

    abi.fetches(8);
    rt.r[13] +%= 8;
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

/// Clear menu/UI overlay state fields in `[0x08041C30]` and reload screen resources (`0x08041BB0`).
pub fn func_08041BB0() callconv(.c) void {
    if (!abi.enter(0x08041BB0)) return;
    abi.fetches(27);
    abi.pushLr();

    const ptr_ref = abi.read32(0x08041C30);
    for ([_]u32{ 0x57, 0x50, 0x53, 0x54 }) |off| {
        abi.write8(abi.read32(ptr_ref) +% off, 0);
    }
    abi.write8(abi.read32(ptr_ref) +% 0x5F, @truncate(abi.read16(abi.read32(0x08041C34))));
    abi.write8(abi.read32(ptr_ref) +% 0x5A, 0);

    if (!abi.call(decls.func_08011910, 0x08041BE3)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011968, 0x08041BE7)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x08041C38);
    rt.r[1] = abi.read32(0x08041C3C);
    abi.setRegNz(&rt.r[2], 0x60);
    if (!abi.call(dma.func_0800FDA4, 0x08041BF1)) return;

    abi.fetches(15);
    const faction = abi.read8(abi.read32(0x08041C40) +% (0x87 << 2));
    rt.r[0] = (@as(u32, faction) << 5) +% abi.read32(0x08041C44);
    rt.r[1] = 0x3C0;
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x08041C0B)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x08041C48);
    rt.r[1] = abi.read32(0x08041C4C);
    if (!abi.call(decls.func_0800FE24, 0x08041C13)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x08041C50);
    rt.r[1] = abi.read32(0x08041C54);
    if (!abi.call(decls.func_0800FE24, 0x08041C1B)) return;

    const tail_calls = [_]struct { func: *const fn () callconv(.c) void, ret: u32 }{
        .{ .func = decls.func_08040BDC, .ret = 0x08041C1F },
        .{ .func = func_08040B00, .ret = 0x08041C23 },
        .{ .func = decls.func_08011804, .ret = 0x08041C27 },
        .{ .func = decls.func_08011824, .ret = 0x08041C2B },
    };
    inline for (tail_calls) |tc| {
        abi.fetches(4);
        if (!abi.call(tc.func, tc.ret)) return;
    }

    abi.fetches(4);
    abi.popReturn();
}

/// Spawn UI animator slot `(a0, a1, a2 + 0xD4, state[0x2F] + 2)` (`0x080421EC`).
pub fn func_080421EC() callconv(.c) void {
    if (!abi.enter(0x080421EC)) return;
    spawnUiAnimatorSlot(.{
        .mode = .addd4_rom2f_add2,
        .entry_fetches = 24,
        .high_regs = 1,
        .pool0 = 0x08042278,
        .pool1 = 0x0804227C,
        .pool2 = 0x08042280,
        .finish_90c = true,
        .tail_scale = 0x100,
        .ret_spawn = 0x08042219,
        .ret_anim = 0x08042237,
        .ret_pos = 0x0804224D,
        .ret_f0 = 0x08042253,
        .ret_f1 = 0x08042259,
        .ret_t0 = 0x08042265,
        .ret_t1 = 0x0804226D,
    });
}

/// Spawn UI animator slot `(a0, a1, a2, a3)` with `u8(stack_arg)` in `slot+0x1C` (`0x08047AB0`).
pub fn func_08047AB0() callconv(.c) void {
    if (!abi.enter(0x08047AB0)) return;
    spawnUiAnimatorSlot(.{
        .mode = .direct_a4_u8,
        .entry_fetches = 37,
        .high_regs = 3,
        .pool0 = 0x08047B58,
        .pool1 = 0x08047B5C,
        .pool2 = 0x08047B60,
        .finish_90c = false,
        .tail_scale = 0x100,
        .ret_spawn = 0x08047AF7,
        .ret_anim = 0x08047B07,
        .ret_pos = 0x08047B19,
        .ret_f0 = 0x08047B2D,
        .ret_f1 = 0x08047B33,
        .ret_t0 = 0x08047B3F,
        .ret_t1 = 0x08047B47,
    });
}

/// Draw two-digit UI indicator via `0x0807B488` / `0x0807B564` and `0x0801B888` (`0x0804901C`).
pub fn func_0804901C() callconv(.c) void {
    if (!abi.enter(0x0804901C)) return;
    abi.fetches(14);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    const saved_r10 = rt.r[10];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r10);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);

    const val = abi.read8(abi.read32(0x080490EC)) -% 1;
    rt.r[0] = val;
    abi.setRegNz(&rt.r[1], 6);
    if (!abi.call(math.func_0807B488, 0x08049035)) return;

    abi.fetches(9);
    const mod_hi_x2 = (rt.r[0] & 0x7FFF) << 1;
    rt.r[0] = val;
    abi.setRegNz(&rt.r[1], 6);
    if (!abi.call(math.func_0807B564, 0x08049043)) return;

    abi.fetches(49);
    const rem_idx = rt.r[0] & 0xFFFF;
    const rem_ptr = rem_idx +% abi.read32(0x080490F0);
    const tbl_base = abi.read32(0x080490F4);
    const sum_w = abi.read8(mod_hi_x2 +% 1 +% tbl_base) +% abi.read8(rem_ptr);
    const half_w: u32 = @bitCast(@as(i32, @bitCast(@as(u32, 0x30) -% sum_w)) >> 1);
    const state = abi.read32(abi.read32(0x080490F8));
    const base_x = (half_w +% abi.read16(state +% 0x14) +% abi.read32(0x080490FC)) & 0xFFFF;
    const x_mask = abi.read32(0x08049100);
    const draw_ptr = abi.read32(0x08049104);
    const attr_or = abi.read32(0x08049108);

    rt.r[0] = (abi.read16(state +% 0x1C) +% base_x -% 4) & x_mask;
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(abi.read16(state +% 0x16) +% abi.read16(state +% 0x1E))));
    rt.r[2] = draw_ptr;
    rt.r[3] = ((abi.read16(state +% 0x18) +% 0xDC) | attr_or) & 0xFFFF;
    if (!abi.call(hw.func_0801B888, 0x080490A1)) return;

    abi.fetches(32);
    const cur_state = abi.read32(abi.read32(0x080490F8));
    const delta = abi.read8(rem_ptr) -% abi.read8(mod_hi_x2 +% abi.read32(0x080490F4));
    const x2 = (base_x +% delta) & 0xFFFF;
    rt.r[0] = (abi.read16(cur_state +% 0x1C) +% x2 -% 2) & x_mask;
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(abi.read16(cur_state +% 0x16) +% abi.read16(cur_state +% 0x1E))));
    rt.r[2] = draw_ptr;
    rt.r[3] = ((abi.read16(cur_state +% 0x18) +% 0xE4) | attr_or) & 0xFFFF;
    if (!abi.call(hw.func_0801B888, 0x080490DD)) return;

    abi.fetches(9);
    rt.r[3] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = rt.r[3];
    rt.r[9] = rt.r[4];
    rt.r[10] = rt.r[5];
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[7] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn UI animator slot `(a0, a1, 0x2F8, a2)` without priority bit (`0x0804A06C`).
pub fn func_0804A06C() callconv(.c) void {
    if (!abi.enter(0x0804A06C)) return;
    spawnUiAnimatorSlot(.{
        .mode = .fixed2f8_a2,
        .entry_fetches = 24,
        .high_regs = 1,
        .pool0 = 0x0804A0E8,
        .pool1 = 0x0804A0EC,
        .finish_90c = true,
        .tail_scale = 0x100,
        .ret_spawn = 0x0804A099,
        .ret_anim = 0x0804A0AB,
        .ret_pos = 0x0804A0BD,
        .ret_f0 = 0x0804A0C3,
        .ret_f1 = 0x0804A0C9,
        .ret_t0 = 0x0804A0D5,
        .ret_t1 = 0x0804A0DD,
    });
}

/// Spawn UI animator slot `(a0, a1, 0x2F8, a2)` and set priority flag `(slot, 1)` (`0x0804A0F0`).
pub fn func_0804A0F0() callconv(.c) void {
    if (!abi.enter(0x0804A0F0)) return;
    spawnUiAnimatorSlot(.{
        .mode = .fixed2f8_a2_prio1,
        .entry_fetches = 24,
        .high_regs = 1,
        .pool0 = 0x0804A174,
        .pool1 = 0x0804A178,
        .finish_90c = true,
        .tail_scale = 0x100,
        .ret_spawn = 0x0804A11D,
        .ret_anim = 0x0804A12F,
        .ret_pos = 0x0804A141,
        .ret_f0 = 0x0804A147,
        .ret_f1 = 0x0804A14D,
        .ret_prio = 0x0804A155,
        .ret_t0 = 0x0804A161,
        .ret_t1 = 0x0804A169,
    });
}

/// Render labeled stat triple `(header, body, label)` via `0x08012A68` / `0x08012B04` (`0x0804C7C0`).
pub fn func_0804C7C0() callconv(.c) void {
    if (!abi.enter(0x0804C7C0)) return;
    abi.fetches(37);
    const entry_sp = rt.r[13];
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    const saved_r10 = rt.r[10];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r10);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const col = rt.r[0] & 0xFF;
    const row = rt.r[1] & 0xFF;
    const dst = rt.r[2];
    const entry_idx = rt.r[3] & 0xFFFF;
    const pal_bits = (abi.read32(entry_sp) << 28) >> 16;
    const entry_base = abi.read32(0x0804C844) +% (entry_idx *% 24);

    abi.write32(rt.r[13], pal_bits);
    abi.write32(rt.r[13] +% 4, 0);
    rt.r[0] = col;
    rt.r[1] = row;
    rt.r[2] = dst;
    rt.r[3] = abi.read32(entry_base);
    if (!abi.call(decls.func_08012A68, 0x0804C807)) return;

    abi.fetches(15);
    abi.write32(rt.r[13], pal_bits);
    abi.write32(rt.r[13] +% 4, 0);
    rt.r[0] = col +% 0xE;
    rt.r[1] = row;
    rt.r[2] = dst;
    rt.r[3] = abi.read32(entry_base +% 4);
    if (!abi.call(decls.func_08012B04, 0x0804C821)) return;

    abi.fetches(12);
    abi.write32(rt.r[13], pal_bits);
    abi.write32(rt.r[13] +% 4, 0);
    rt.r[0] = col +% 0xF;
    rt.r[1] = row;
    rt.r[2] = dst;
    rt.r[3] = abi.read32(0x0804C848);
    if (!abi.call(decls.func_08012A68, 0x0804C835)) return;

    abi.fetches(10);
    rt.r[13] +%= 8;
    rt.r[3] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = rt.r[3];
    rt.r[9] = rt.r[4];
    rt.r[10] = rt.r[5];
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[7] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn UI animator slot `(a0, a1, a2 + [0x0804FCE8], 3)` with scale `0x200` (primary, `0x0804FC40`).
pub fn func_0804FC40() callconv(.c) void {
    if (!abi.enter(0x0804FC40)) return;
    spawnUiAnimatorSlot(.{
        .mode = .add_pool_3_shr4,
        .entry_fetches = 27,
        .high_regs = 2,
        .pool0 = 0x0804FCE0,
        .pool1 = 0x0804FCE4,
        .pool2 = 0x0804FCE8,
        .pool3 = 0x0804FCEC,
        .finish_90c = false,
        .tail_scale = 0x200,
        .ret_spawn = 0x0804FC73,
        .ret_anim = 0x0804FC8B,
        .ret_pos = 0x0804FCA1,
        .ret_f0 = 0x0804FCB7,
        .ret_f1 = 0x0804FCBD,
        .ret_t0 = 0x0804FCC9,
        .ret_t1 = 0x0804FCD1,
    });
}

/// Spawn UI animator slot `(a0, a1, a2 + [0x0804FDC4], 3)` with scale `0x200` (secondary, `0x0804FD1C`).
pub fn func_0804FD1C() callconv(.c) void {
    if (!abi.enter(0x0804FD1C)) return;
    spawnUiAnimatorSlot(.{
        .mode = .add_pool_3_shr4,
        .entry_fetches = 27,
        .high_regs = 2,
        .pool0 = 0x0804FDBC,
        .pool1 = 0x0804FDC0,
        .pool2 = 0x0804FDC4,
        .pool3 = 0x0804FDC8,
        .finish_90c = false,
        .tail_scale = 0x200,
        .ret_spawn = 0x0804FD4F,
        .ret_anim = 0x0804FD67,
        .ret_pos = 0x0804FD7D,
        .ret_f0 = 0x0804FD93,
        .ret_f1 = 0x0804FD99,
        .ret_t0 = 0x0804FDA5,
        .ret_t1 = 0x0804FDAD,
    });
}

/// Spawn UI animator slot `(a0, a1, a2, a3, stack_arg)` with `slot+0x1C = a2 >> 4` (primary, `0x0804FF1C`).
pub fn func_0804FF1C() callconv(.c) void {
    if (!abi.enter(0x0804FF1C)) return;
    spawnUiAnimatorSlot(.{
        .mode = .stack_a2_a3_shr4,
        .entry_fetches = 32,
        .high_regs = 3,
        .pool0 = 0x0804FFBC,
        .pool1 = 0x0804FFC0,
        .finish_90c = false,
        .tail_scale = 0x100,
        .ret_spawn = 0x0804FF59,
        .ret_anim = 0x0804FF69,
        .ret_pos = 0x0804FF7B,
        .ret_f0 = 0x0804FF91,
        .ret_f1 = 0x0804FF97,
        .ret_t0 = 0x0804FFA3,
        .ret_t1 = 0x0804FFAB,
    });
}

/// Spawn UI animator slot `(a0, a1, a2, a3, stack_arg)` with `slot+0x1C = a2 >> 4` (secondary, `0x08050134`).
pub fn func_08050134() callconv(.c) void {
    if (!abi.enter(0x08050134)) return;
    spawnUiAnimatorSlot(.{
        .mode = .stack_a2_a3_shr4,
        .entry_fetches = 32,
        .high_regs = 3,
        .pool0 = 0x080501D4,
        .pool1 = 0x080501D8,
        .finish_90c = false,
        .tail_scale = 0x100,
        .ret_spawn = 0x08050171,
        .ret_anim = 0x08050181,
        .ret_pos = 0x08050193,
        .ret_f0 = 0x080501A9,
        .ret_f1 = 0x080501AF,
        .ret_t0 = 0x080501BB,
        .ret_t1 = 0x080501C3,
    });
}

/// Load tilesets `0x62..0x65` and `0x00..0x04` sequentially via `0x0802FC70`, then finish via `0x0800FE18` (`0x08050EB4`).
pub fn func_08050EB4() callconv(.c) void {
    if (!abi.enter(0x08050EB4)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const base = abi.read32(0x08050F40);
    const group0 = [_]struct { tile: u32, ret: u32 }{
        .{ .tile = 0x62, .ret = 0x08050EC1 },
        .{ .tile = 0x63, .ret = 0x08050ED1 },
        .{ .tile = 0x64, .ret = 0x08050EDF },
        .{ .tile = 0x65, .ret = 0x08050EED },
    };
    var acc: u32 = base;
    inline for (group0, 0..) |g, i| {
        if (i != 0) abi.fetches(if (i == 1) 10 else 9);
        rt.r[0] = acc;
        abi.setRegNz(&rt.r[1], g.tile);
        if (!abi.call(battle.func_0802FC70, g.ret)) return;
        if (i == 0) {
            acc = (rt.r[0] +% base) & 0xFFFF;
        } else if (i < 3) {
            acc = (acc +% rt.r[0]) & 0xFFFF;
        }
    }

    abi.fetches(7);
    const base1 = base +% 0x10;
    acc = base1;
    const group1 = [_]struct { tile: u32, ret: u32 }{
        .{ .tile = 0, .ret = 0x08050EF7 },
        .{ .tile = 1, .ret = 0x08050F07 },
        .{ .tile = 2, .ret = 0x08050F15 },
        .{ .tile = 3, .ret = 0x08050F23 },
        .{ .tile = 4, .ret = 0x08050F31 },
    };
    inline for (group1, 0..) |g, i| {
        if (i != 0) abi.fetches(if (i == 1) 10 else 9);
        rt.r[0] = acc;
        abi.setRegNz(&rt.r[1], g.tile);
        if (!abi.call(battle.func_0802FC70, g.ret)) return;
        if (i == 0) {
            acc = (rt.r[0] +% base1) & 0xFFFF;
        } else if (i < 4) {
            acc = (acc +% rt.r[0]) & 0xFFFF;
        }
    }

    abi.fetches(6);
    rt.r[0] = abi.read32(0x08050F44);
    rt.r[1] = abi.read32(0x08050F48);
    if (!abi.call(hw.func_0800FE18, 0x08050F39)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down battle results / map procs via `0x08049834` and 20 `0x0801329C` calls (`0x080518B4`).
pub fn func_080518B4() callconv(.c) void {
    if (!abi.enter(0x080518B4)) return;
    abi.fetches(5);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    if (!abi.call(func_08049834, 0x080518BB)) return;

    const kill_list = [_]struct { pool: u32, reload: bool, ret: u32 }{
        .{ .pool = 0x0805193C, .reload = true, .ret = 0x080518C1 },
        .{ .pool = 0x08051940, .reload = true, .ret = 0x080518C7 },
        .{ .pool = 0x08051944, .reload = true, .ret = 0x080518CD },
        .{ .pool = 0x08051948, .reload = true, .ret = 0x080518D5 },
        .{ .pool = 0x08051948, .reload = false, .ret = 0x080518DB },
        .{ .pool = 0x08051948, .reload = false, .ret = 0x080518E1 },
        .{ .pool = 0x08051948, .reload = false, .ret = 0x080518E7 },
        .{ .pool = 0x0805194C, .reload = true, .ret = 0x080518EF },
        .{ .pool = 0x0805194C, .reload = false, .ret = 0x080518F5 },
        .{ .pool = 0x0805194C, .reload = false, .ret = 0x080518FB },
        .{ .pool = 0x0805194C, .reload = false, .ret = 0x08051901 },
        .{ .pool = 0x0805194C, .reload = false, .ret = 0x08051907 },
        .{ .pool = 0x0805194C, .reload = false, .ret = 0x0805190D },
        .{ .pool = 0x08051950, .reload = true, .ret = 0x08051913 },
        .{ .pool = 0x08051954, .reload = true, .ret = 0x08051919 },
        .{ .pool = 0x08051958, .reload = true, .ret = 0x0805191F },
        .{ .pool = 0x0805195C, .reload = true, .ret = 0x08051925 },
        .{ .pool = 0x08051960, .reload = true, .ret = 0x0805192B },
        .{ .pool = 0x08051964, .reload = true, .ret = 0x08051931 },
        .{ .pool = 0x08051968, .reload = true, .ret = 0x08051937 },
    };
    var cached_arg: u32 = 0;
    inline for (kill_list, 0..) |k, i| {
        const is_first_group = (i == 3 or i == 7);
        abi.fetches(if (is_first_group) 6 else 5);
        if (k.reload) cached_arg = abi.read32(k.pool);
        rt.r[0] = cached_arg;
        if (!abi.call(decls.func_0801329C, k.ret)) return;
    }

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn UI animator slot `(a0, a1, 0, 6)` with `0x0801490C` (`0x08051DE8`).
pub fn func_08051DE8() callconv(.c) void {
    if (!abi.enter(0x08051DE8)) return;
    spawnUiAnimatorSlot(.{
        .mode = .fixed_0_6,
        .entry_fetches = 17,
        .high_regs = 0,
        .pool0 = 0x08051E50,
        .pool1 = 0x08051E54,
        .finish_90c = true,
        .tail_scale = 0x100,
        .ret_spawn = 0x08051E07,
        .ret_anim = 0x08051E17,
        .ret_pos = 0x08051E29,
        .ret_f0 = 0x08051E2F,
        .ret_f1 = 0x08051E35,
        .ret_t0 = 0x08051E41,
        .ret_t1 = 0x08051E49,
    });
}

/// Upload combat summary panel graphics, palettes, unit detail rows & gauges (`0x0805DD64`).
pub fn func_0805DD64() callconv(.c) void {
    if (!abi.enter(0x0805DD64)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const head_dma = [_]struct { src: u32, dst: u32, len: u32, ret: u32 }{
        .{ .src = 0x0805DE34, .dst = 0x0805DE38, .len = 0xA0, .ret = 0x0805DD71 },
        .{ .src = 0x0805DE3C, .dst = 0x0805DE40, .len = 0xA0, .ret = 0x0805DD7B },
        .{ .src = 0x0805DE44, .dst = 0x0805DE48, .len = 0x90, .ret = 0x0805DD85 },
    };
    inline for (head_dma, 0..) |d, i| {
        if (i != 0) abi.fetches(7);
        rt.r[0] = abi.read32(d.src);
        rt.r[1] = abi.read32(d.dst);
        abi.setRegNz(&rt.r[2], d.len);
        if (!abi.call(bios.func_080796C0, d.ret)) return;
    }

    abi.fetches(12);
    const tbl_ptr = abi.read32(0x0805DE4C);
    const side_ptr = abi.read32(0x0805DE50);
    rt.r[0] = abi.read32(tbl_ptr +% (@as(u32, abi.read8(side_ptr)) << 2));
    rt.r[1] = abi.read32(0x0805DE54);
    abi.setRegNz(&rt.r[2], 8);
    if (!abi.call(bios.func_080796C0, 0x0805DD99)) return;

    abi.fetches(10);
    rt.r[0] = abi.read32(tbl_ptr +% (@as(u32, abi.read8(side_ptr +% 1)) << 2));
    rt.r[1] = abi.read32(0x0805DE58);
    abi.setRegNz(&rt.r[2], 8);
    if (!abi.call(bios.func_080796C0, 0x0805DDA9)) return;

    abi.fetches(6);
    const pair_ptr = abi.read32(0x0805DE5C);
    rt.r[0] = abi.read16(pair_ptr);
    if (!abi.call(unit.func_0805DE84, 0x0805DDB1)) return;

    abi.fetches(5);
    rt.r[0] = abi.read16(pair_ptr +% 2);
    if (!abi.call(unit.func_0805E0AC, 0x0805DDB7)) return;

    abi.fetches(7);
    const gauge_ptr = abi.read32(0x0805DE60);
    abi.setRegNz(&rt.r[0], 0);
    rt.r[1] = abi.read16(gauge_ptr);
    if (!abi.call(func_0805E2DC, 0x0805DDC1)) return;

    abi.fetches(6);
    abi.setRegNz(&rt.r[0], 1);
    rt.r[1] = abi.read16(gauge_ptr +% 2);
    if (!abi.call(func_0805E2DC, 0x0805DDC9)) return;

    abi.fetches(7);
    const stats_ptr = abi.read32(0x0805DE64);
    rt.r[0] = abi.read16(stats_ptr +% 0xE);
    abi.setRegNz(&rt.r[1], 0xA);
    if (!abi.call(decls.func_0807B634, 0x0805DDD3)) return;

    abi.fetches(9);
    const v0 = rt.r[0] & 0xFFFF;
    rt.r[0] = abi.read16(stats_ptr +% 0x1E);
    abi.setRegNz(&rt.r[1], 0xA);
    if (!abi.call(decls.func_0807B634, 0x0805DDE1)) return;

    abi.fetches(20);
    const v1 = rt.r[0] & 0xFFFF;
    const digit_tbl = abi.read32(0x0805DE68);
    const src0_off = (@as(u32, abi.read16(digit_tbl +% (v0 << 1))) << 21) >> 16;
    const src1_off = (@as(u32, abi.read16(digit_tbl +% (v1 << 1))) << 21) >> 16;
    rt.r[0] = src0_off +% abi.read32(0x0805DE6C);
    rt.r[1] = abi.read32(0x0805DE70);
    abi.setRegNz(&rt.r[2], 0x40);
    if (!abi.call(bios.func_080796C0, 0x0805DE05)) return;

    abi.fetches(10);
    rt.r[0] = src1_off +% abi.read32(0x0805DE74);
    rt.r[1] = abi.read32(0x0805DE78);
    abi.setRegNz(&rt.r[2], 0x80);
    if (!abi.call(bios.func_080796C0, 0x0805DE15)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x0805DE7C);
    rt.r[1] = abi.read32(0x0805DE80);
    abi.setRegNz(&rt.r[2], 8);
    if (!abi.call(bios.func_080796C0, 0x0805DE1F)) return;

    abi.fetches(6);
    abi.setRegNz(&rt.r[0], 0);
    abi.setRegNz(&rt.r[1], 0x30);
    if (!abi.call(unit.func_0805E3A8, 0x0805DE27)) return;

    abi.fetches(6);
    abi.setRegNz(&rt.r[0], 1);
    abi.setRegNz(&rt.r[1], 0x40);
    if (!abi.call(unit.func_0805E3A8, 0x0805DE2F)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Apply compressed UI tile strip for entry `(index_u8, offset_s16)` using LUT `[0x08040308]` (`0x080402D4`).
pub fn func_080402D4() callconv(.c) void {
    if (!abi.enter(0x080402D4)) return;
    abi.fetches(11);
    abi.pushLr();
    abi.pushReg(5);
    abi.pushReg(4);
    const y_off = abi.arg(1) & 0xFFFF;
    const lut_base = abi.read32(0x08040308);
    rt.r[4] = y_off;
    rt.r[5] = lut_base;
    rt.r[0] = abi.arg(0) & 0xFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(co.func_0801BE04, 0x080402E7)) return;

    abi.fetches(15);
    const idx = rt.r[0] & 0xFF;
    const src = abi.read32(lut_base +% (idx *% 36));
    const dst = (@as(u32, @bitCast(abi.signExtend16(@truncate(y_off)))) << 5) +% abi.read32(0x0804030C);
    rt.r[4] = dst;
    rt.r[0] = src;
    rt.r[1] = dst;
    if (!abi.call(hw.func_0800FE18, 0x08040303)) return;

    abi.fetches(3 + 3);
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn UI animator slot with stack arg `[sp]` and `slot+0x1C = a2 >> 4` (`0x0804FE74`).
pub fn func_0804FE74() callconv(.c) void {
    if (!abi.enter(0x0804FE74)) return;
    spawnUiAnimatorSlot(.{
        .mode = .stack_a2_a3_shr4,
        .entry_fetches = 32,
        .high_regs = 3,
        .pool0 = 0x0804FF14,
        .pool1 = 0x0804FF18,
        .finish_90c = false,
        .tail_scale = 0x200,
        .ret_spawn = 0x0804FEB1,
        .ret_anim = 0x0804FEC1,
        .ret_pos = 0x0804FED3,
        .ret_f0 = 0x0804FEE9,
        .ret_f1 = 0x0804FEEF,
        .ret_t0 = 0x0804FEFB,
        .ret_t1 = 0x0804FF03,
    });
}

/// Query two UI metric slots via `0x0802FC70` and chain total with slot `0x57` (`0x080501DC`).
pub fn func_080501DC() callconv(.c) void {
    if (!abi.enter(0x080501DC)) return;
    abi.fetches(14);
    abi.pushLr();
    abi.pushReg(4);
    const base_val = abi.arg(0) & 0xFFFF;
    const raw_b = abi.arg(1);
    rt.r[4] = base_val;
    rt.r[0] = base_val;
    rt.r[1] = ((raw_b << 16) +% (0x9C << 15)) >> 16;
    rt.updateNz(rt.r[1]);
    if (!abi.call(battle.func_0802FC70, 0x080501F5)) return;

    abi.fetches(3 + 6);
    const sum = (base_val +% rt.r[0]) & 0xFFFF;
    rt.r[4] = sum;
    rt.r[0] = sum;
    abi.setRegNz(&rt.r[1], 0x57);
    abi.fetches(3);
    if (!abi.call(battle.func_0802FC70, 0x08050203)) return;

    abi.fetches(3 + 3 + 4);
    rt.r[4] = abi.popReg();
    abi.popReturn();
}

fn callTextLabel(x: u32, y: u32, str_ptr: u32, ret_lr: u32) bool {
    rt.r[0] = x;
    rt.r[1] = y;
    rt.r[2] = str_ptr;
    rt.updateNz(y);
    return abi.call(decls.func_0800FADC, ret_lr);
}

fn callTextNum(x: u32, y: u32, val: u32, ret_lr: u32) bool {
    rt.r[0] = x;
    rt.r[1] = y;
    rt.r[2] = val;
    rt.updateNz(y);
    return abi.call(decls.func_0800FB58, ret_lr);
}

/// Draw unit/CO statistics summary two-column grid (`0x0805EC80`).
pub fn func_0805EC80() callconv(.c) void {
    if (!abi.enter(0x0805EC80)) return;
    abi.fetches(22);
    abi.pushLr();
    abi.pushReg(7);
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.pushReg(10);
    abi.pushReg(9);
    abi.pushReg(8);

    const h0 = abi.read16(abi.read32(0x0805EE48) +% (abi.read16(abi.read32(0x0805EE4C)) << 1));
    const h1 = abi.read16(abi.read32(0x0805EE50) +% (abi.read16(abi.read32(0x0805EE54)) << 1));
    if (!callTextLabel(h0, h1, abi.read32(0x0805EE58), 0x0805ECA9)) return;

    abi.fetches(12);
    const h2 = abi.read16(abi.read32(0x0805EE5C) +% (abi.read16(abi.read32(0x0805EE60)) << 1));
    if (!callTextLabel(h2, 0x64, abi.read32(0x0805EE64), 0x0805ECBD)) return;

    const left_labels = [_]struct { x: u32, y: u32, pool: u32, ret: u32 }{
        .{ .x = 0x00, .y = 0x00, .pool = 0x0805EE68, .ret = 0x0805ECC7 },
        .{ .x = 0x10, .y = 0x10, .pool = 0x0805EE6C, .ret = 0x0805ECD1 },
        .{ .x = 0x10, .y = 0x18, .pool = 0x0805EE70, .ret = 0x0805ECDB },
        .{ .x = 0x10, .y = 0x20, .pool = 0x0805EE74, .ret = 0x0805ECE7 },
        .{ .x = 0x10, .y = 0x28, .pool = 0x0805EE78, .ret = 0x0805ECF5 },
        .{ .x = 0x10, .y = 0x30, .pool = 0x0805EE7C, .ret = 0x0805ED03 },
        .{ .x = 0x10, .y = 0x38, .pool = 0x0805EE80, .ret = 0x0805ED11 },
        .{ .x = 0x10, .y = 0x40, .pool = 0x0805EE84, .ret = 0x0805ED1D },
        .{ .x = 0x10, .y = 0x48, .pool = 0x0805EE88, .ret = 0x0805ED29 },
    };
    const left_fetches = [_]u32{ 7, 7, 7, 8, 9, 9, 9, 8, 8 };
    inline for (left_labels, left_fetches) |row, f| {
        abi.fetches(f);
        if (!callTextLabel(row.x, row.y, abi.read32(row.pool), row.ret)) return;
    }

    abi.fetches(8);
    const stats_ptr = abi.read32(0x0805EE8C);
    const left_vals = [_]struct { off: u32, y: u32, ret: u32 }{
        .{ .off = 0x0, .y = 0x10, .ret = 0x0805ED35 },
        .{ .off = 0x2, .y = 0x18, .ret = 0x0805ED3F },
        .{ .off = 0x4, .y = 0x20, .ret = 0x0805ED49 },
        .{ .off = 0x6, .y = 0x28, .ret = 0x0805ED53 },
        .{ .off = 0x8, .y = 0x30, .ret = 0x0805ED5D },
        .{ .off = 0xA, .y = 0x38, .ret = 0x0805ED67 },
        .{ .off = 0xC, .y = 0x40, .ret = 0x0805ED71 },
        .{ .off = 0xE, .y = 0x48, .ret = 0x0805ED7B },
    };
    inline for (left_vals, 0..) |v, i| {
        if (i > 0) abi.fetches(7);
        if (!callTextNum(0x48, v.y, abi.read16(stats_ptr +% v.off), v.ret)) return;
    }

    const right_labels = [_]struct { x: u32, y: u32, pool: u32, ret: u32 }{
        .{ .x = 0x78, .y = 0x00, .pool = 0x0805EE90, .ret = 0x0805ED85 },
        .{ .x = 0x88, .y = 0x10, .pool = 0x0805EE6C, .ret = 0x0805ED8F },
        .{ .x = 0x88, .y = 0x18, .pool = 0x0805EE70, .ret = 0x0805ED99 },
        .{ .x = 0x88, .y = 0x20, .pool = 0x0805EE74, .ret = 0x0805EDA3 },
        .{ .x = 0x88, .y = 0x28, .pool = 0x0805EE78, .ret = 0x0805EDAD },
        .{ .x = 0x88, .y = 0x30, .pool = 0x0805EE7C, .ret = 0x0805EDB7 },
        .{ .x = 0x88, .y = 0x38, .pool = 0x0805EE80, .ret = 0x0805EDC1 },
        .{ .x = 0x88, .y = 0x40, .pool = 0x0805EE84, .ret = 0x0805EDCB },
        .{ .x = 0x88, .y = 0x48, .pool = 0x0805EE88, .ret = 0x0805EDD5 },
    };
    inline for (right_labels) |row| {
        abi.fetches(7);
        if (!callTextLabel(row.x, row.y, abi.read32(row.pool), row.ret)) return;
    }

    const right_vals = [_]struct { off: u32, y: u32, f: u32, ret: u32 }{
        .{ .off = 0x10, .y = 0x10, .f = 7, .ret = 0x0805EDDF },
        .{ .off = 0x12, .y = 0x18, .f = 7, .ret = 0x0805EDE9 },
        .{ .off = 0x14, .y = 0x20, .f = 4 + 5, .ret = 0x0805EDF3 },
        .{ .off = 0x16, .y = 0x28, .f = 7, .ret = 0x0805EDFD },
        .{ .off = 0x18, .y = 0x30, .f = 7, .ret = 0x0805EE07 },
        .{ .off = 0x1A, .y = 0x38, .f = 7, .ret = 0x0805EE11 },
        .{ .off = 0x1C, .y = 0x40, .f = 7, .ret = 0x0805EE1B },
        .{ .off = 0x0E, .y = 0x48, .f = 7, .ret = 0x0805EE25 },
    };
    inline for (right_vals) |v| {
        abi.fetches(v.f);
        if (!callTextNum(0xC0, v.y, abi.read16(stats_ptr +% v.off), v.ret)) return;
    }

    abi.fetches(7);
    if (!callTextLabel(0x10, 0x7C, abi.read32(0x0805EE94), 0x0805EE2F)) return;
    abi.fetches(8);
    if (!callTextNum(0x50, 0x7C, abi.read16(abi.read32(0x0805EE98)), 0x0805EE3B)) return;

    abi.fetches(9);
    rt.r[8] = abi.popReg();
    rt.r[9] = abi.popReg();
    rt.r[10] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    rt.r[7] = abi.popReg();
    abi.popReturn();
}

/// Emit two status glyphs/cards via `0x0805E5F0` and flag `[0x0805E3A4] = 1` (`0x0805E2DC`).
pub fn func_0805E2DC() callconv(.c) void {
    if (!abi.enter(0x0805E2DC)) return;
    abi.fetches(54);
    abi.pushLr();
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.pushReg(10);
    abi.pushReg(9);
    abi.pushReg(8);
    rt.r[13] -%= 0x10;
    const idx = abi.arg(0) & 0xFFFF;
    const base_x = abi.arg(1) & 0xFFFF;

    const tbl_pal = abi.read32(0x0805E394);
    const tbl_grp = abi.read32(0x0805E398);
    const tbl_ent = abi.read32(0x0805E39C);
    const tbl_aux = abi.read32(0x0805E3A0);

    const ent_ptr = (idx << 4) +% tbl_ent +% 2;
    const ent_id: u32 = abi.read16(ent_ptr);
    const grp_id: u32 = abi.read16(tbl_grp +% (ent_id *% 20) +% 2);
    const tile0 = abi.read16(tbl_pal +% ((grp_id *% 2 +% idx) << 1));
    const aux_ptr = (idx << 1) +% tbl_aux;
    const aux_val = abi.read16(aux_ptr);

    abi.write16(rt.r[13] +% 0x0, @truncate(base_x));
    abi.write16(rt.r[13] +% 0x2, 8);
    abi.write16(rt.r[13] +% 0x4, 3);
    abi.write16(rt.r[13] +% 0x6, tile0);
    abi.write16(rt.r[13] +% 0x8, aux_val);
    abi.write16(rt.r[13] +% 0xA, 0);
    abi.write32(rt.r[13] +% 0xC, aux_ptr);
    if (!abi.call(decls.func_0805E5F0, 0x0805E345)) return;

    abi.fetches(32);
    const grp1: u32 = abi.read16(tbl_grp +% (@as(u32, abi.read16(ent_ptr)) *% 20) +% 2);
    const tile1 = abi.read16(tbl_pal +% ((grp1 *% 2 +% idx) << 1)) +% 0x44;
    abi.write16(rt.r[13] +% 0x0, @truncate(base_x +% 0x10));
    abi.write16(rt.r[13] +% 0x2, 4);
    abi.write16(rt.r[13] +% 0x4, 1);
    abi.write16(rt.r[13] +% 0x6, @truncate(tile1));
    abi.write16(rt.r[13] +% 0x8, abi.read16(abi.read32(rt.r[13] +% 0xC)));
    abi.write16(rt.r[13] +% 0xA, 0);
    if (!abi.call(decls.func_0805E5F0, 0x0805E381)) return;

    abi.fetches(12);
    abi.write16(abi.read32(0x0805E3A4), 1);
    rt.r[13] +%= 0x10;
    rt.r[8] = abi.popReg();
    rt.r[9] = abi.popReg();
    rt.r[10] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    abi.popReturn();
}

/// Tear down title/mode screen controllers and reset active screen flags (`0x08068368`).
pub fn func_08068368() callconv(.c) void {
    if (!abi.enter(0x08068368)) return;
    abi.fetches(5);
    abi.pushLr();
    const pre = [_]struct { f: fn () callconv(.c) void, r: u32 }{
        .{ .f = decls.func_08068760, .r = 0x0806836F },
        .{ .f = decls.func_0806877C, .r = 0x08068373 },
        .{ .f = decls.func_080689A8, .r = 0x08068377 },
    };
    inline for (pre, 0..) |c, i| {
        if (i > 0) abi.fetches(4);
        if (!abi.call(c.f, c.r)) return;
    }
    abi.fetches(6);
    rt.r[0] = abi.read16(abi.read32(0x080683A0));
    if (!abi.call(decls.func_0806826C, 0x0806837F)) return;

    const post = [_]struct { f: fn () callconv(.c) void, r: u32 }{
        .{ .f = battle.func_08068A54, .r = 0x08068383 },
        .{ .f = decls.func_080691A4, .r = 0x08068387 },
        .{ .f = decls.func_08068910, .r = 0x0806838B },
    };
    inline for (post) |c| {
        abi.fetches(4);
        if (!abi.call(c.f, c.r)) return;
    }
    abi.fetches(12);
    abi.write16(abi.read32(0x080683A4), 1);
    abi.write32(abi.read32(0x080683AC), 0);
    abi.write8(abi.read32(0x080683A8), 0);
    abi.popReturn();
}

/// Initialize ending/map gallery menu state, palette fades, and 5 option buttons (`0x0806A484`).
pub fn func_0806A484() callconv(.c) void {
    if (!abi.enter(0x0806A484)) return;
    abi.fetches(44);
    abi.pushLr();
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.pushReg(9);
    abi.pushReg(8);

    const mgr_ptr = abi.read32(0x0806A5B8);
    const mgr = abi.read32(mgr_ptr);
    const base_u16 = abi.read32(0x0806A5BC);
    abi.write16(mgr +% 0x26, 7);
    abi.write16(mgr +% 0x28, 0x30);
    abi.write16(mgr +% 0x2A, @truncate(base_u16));
    abi.write16(mgr +% 0x2C, @truncate(base_u16 +% 0x58));
    abi.write16(mgr +% 0x2E, 0x46);
    abi.write16(mgr +% 0x30, 0x50);
    abi.write16(mgr +% 0x32, 0x4F);
    abi.write16(mgr +% 0x34, 0x38);
    abi.write16(mgr +% 0x36, 0x5B);
    abi.write8(mgr +% 0x3C, 6);
    abi.write8(abi.read32(mgr_ptr) +% 0x3E, 1);

    const st = abi.read32(mgr_ptr);
    rt.r[0] = abi.read16(st +% 0x26);
    rt.r[1] = abi.read16(st +% 0x20);
    abi.setRegNz(&rt.r[2], 3);
    if (!abi.call(decls.func_08043008, 0x0806A4D9)) return;

    abi.fetches(9);
    const pal_base = abi.read32(0x0806A5C0);
    rt.r[0] = pal_base;
    rt.r[1] = pal_base +% 0x80;
    abi.setRegNz(&rt.r[2], 0xC0);
    if (!abi.call(decls.func_0807A8A0, 0x0806A4E7)) return;

    abi.fetches(9);
    const dst5 = abi.read32(0x0806A5C4);
    inline for ([_]struct { off: i32, ret: u32 }{
        .{ .off = -0x40, .ret = 0x0806A4F5 },
        .{ .off = -0xE0, .ret = 0x0806A501 },
        .{ .off = -0xA0, .ret = 0x0806A50D },
    }, 0..) |d, i| {
        if (i > 0) abi.fetches(8);
        rt.r[0] = pal_base +% @as(u32, @bitCast(d.off));
        rt.r[1] = dst5;
        abi.setRegNz(&rt.r[2], 0x20);
        if (!abi.call(decls.func_0807A87C, d.ret)) return;
    }

    inline for ([_]struct { f: fn () callconv(.c) void, r: u32 }{
        .{ .f = battle.func_0806A2D0, .r = 0x0806A511 },
        .{ .f = decls.func_08011804, .r = 0x0806A515 },
        .{ .f = decls.func_08011814, .r = 0x0806A519 },
        .{ .f = decls.func_08011824, .r = 0x0806A51D },
        .{ .f = decls.func_08011834, .r = 0x0806A521 },
    }) |c| {
        abi.fetches(4);
        if (!abi.call(c.f, c.r)) return;
    }

    abi.fetches(7);
    rt.r[0] = 0xE;
    rt.r[1] = abi.read32(0x0806A5C8);
    rt.r[2] = 7;
    rt.updateNz(7);
    if (!abi.call(func_0806A8C4, 0x0806A52B)) return;

    inline for ([_]struct { a0: u32, a1: u32, a2: u32, ret: u32 }{
        .{ .a0 = 0x20, .a1 = 0, .a2 = 0x1A, .ret = 0x0806A535 },
        .{ .a0 = 0x40, .a1 = 1, .a2 = 0x16, .ret = 0x0806A53F },
        .{ .a0 = 0x58, .a1 = 2, .a2 = 0x12, .ret = 0x0806A549 },
        .{ .a0 = 0x70, .a1 = 3, .a2 = 0x0E, .ret = 0x0806A553 },
        .{ .a0 = 0x88, .a1 = 4, .a2 = 0x0A, .ret = 0x0806A55D },
    }) |b| {
        abi.fetches(7);
        rt.r[0] = b.a0;
        rt.r[1] = b.a1;
        rt.r[2] = b.a2;
        rt.updateNz(b.a2);
        if (!abi.call(decls.func_0806A668, b.ret)) return;
    }

    abi.fetches(47);
    const reg_ptr = abi.read32(0x0806A5CC);
    abi.write8(reg_ptr +% 0, (abi.read8(reg_ptr +% 0) & 0x34) | 0x44);
    // Exact sequence from blk 16: ((old & 0x3F) | 0x40) & 0xFE & 0xFC | 4 & 0xF7 & 0xEF
    abi.write8(reg_ptr +% 0, (((abi.read8(reg_ptr +% 0) & 0x3F) | 0x40) & 0xFC | 0x04) & 0xE7);
    // Note: reg_ptr+1 in blk 16 ORs r6=1, ORs 2, ANDs (~4)=0xFB, ORs 8, ANDs (~0x10)=0xEF => (b | 0x0B) & 0xEB
    // Wait check r1 in blk 16 line 774: r1 = (0 - 9) - 8 = 0xFFFFFFEF (~0x10)! Wait: r6 also had (1 | b | 2) & ~4 | 8 & ~0x10!
    // Write exact mask: ((abi.read8(reg_ptr +% 1) | 0x03) & 0xFB | 0x08) & 0xEF
    abi.write8(reg_ptr +% 1, (((abi.read8(reg_ptr +% 1) | 0x03) & 0xFB) | 0x08) & 0xEF);
    abi.write16(abi.read32(0x0806A5D0), 0xF);
    abi.write16(abi.read32(0x0806A5D4), 6);
    abi.write16(abi.read32(0x0806A5D8), 0);

    rt.r[8] = abi.popReg();
    rt.r[9] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    abi.popReturn();
}

/// Build rotated 3D projection matrix from `[0x0806AB14]` angle counter into `[0x0806AB18]` (`0x0806AAA0`).
pub fn func_0806AAA0() callconv(.c) void {
    if (!abi.enter(0x0806AAA0)) return;
    abi.fetches(13);
    abi.pushLr();
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.pushReg(8);
    rt.r[13] -%= 0x90;

    const ang_ptr = abi.read32(0x0806AB14);
    const scale_arg: u32 = 0xB4 << 1;

    rt.r[0] = abi.read32(ang_ptr);
    rt.r[1] = scale_arg;
    rt.updateNz(scale_arg);
    if (!abi.call(math.func_0807B6AC, 0x0806AAB7)) return;

    abi.fetches(8);
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    rt.r[0] = rt.r[13];
    if (!abi.call(math.func_0806D160, 0x0806AAC3)) return;

    abi.fetches(7);
    const m1 = rt.r[13] +% 0x30;
    rt.r[4] = m1;
    rt.r[0] = abi.read32(ang_ptr);
    rt.r[1] = scale_arg;
    if (!abi.call(math.func_0807B6AC, 0x0806AACD)) return;

    abi.fetches(8);
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(rt.r[0] << 1)));
    rt.r[0] = m1;
    if (!abi.call(math.func_0806D1A8, 0x0806AAD9)) return;

    abi.fetches(8);
    const m2 = rt.r[13] +% 0x60;
    rt.r[8] = m2;
    rt.r[0] = abi.read32(ang_ptr);
    rt.r[1] = scale_arg;
    if (!abi.call(math.func_0807B6AC, 0x0806AAE5)) return;

    abi.fetches(9);
    rt.r[1] = @bitCast(abi.signExtend16(@truncate((rt.r[0] << 1) +% rt.r[0])));
    rt.r[0] = m2;
    if (!abi.call(math.func_0806D1F0, 0x0806AAF3)) return;

    abi.fetches(7);
    rt.r[0] = rt.r[13];
    rt.r[1] = m1;
    rt.r[2] = m1;
    if (!abi.call(decls.func_0806CF9C, 0x0806AAFD)) return;

    abi.fetches(7);
    rt.r[0] = m1;
    rt.r[1] = m2;
    rt.r[2] = abi.read32(0x0806AB18);
    if (!abi.call(decls.func_0806CF9C, 0x0806AB07)) return;

    abi.fetches(8);
    rt.r[13] +%= 0x90;
    rt.r[8] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    abi.popReturn();
}

/// Reset BG layers, load dual palette banks, and allocate 5 gallery buttons (`0x0806BF30`).
pub fn func_0806BF30() callconv(.c) void {
    if (!abi.enter(0x0806BF30)) return;
    abi.fetches(5);
    abi.pushLr();
    abi.pushReg(4);
    inline for ([_]struct { f: fn () callconv(.c) void, r: u32 }{
        .{ .f = decls.func_08011910, .r = 0x0806BF37 },
        .{ .f = decls.func_0801193C, .r = 0x0806BF3B },
        .{ .f = decls.func_08011968, .r = 0x0806BF3F },
        .{ .f = decls.func_08011804, .r = 0x0806BF43 },
        .{ .f = decls.func_08011814, .r = 0x0806BF47 },
        .{ .f = decls.func_08011824, .r = 0x0806BF4B },
    }, 0..) |c, i| {
        if (i > 0) abi.fetches(4);
        if (!abi.call(c.f, c.r)) return;
    }

    abi.fetches(27);
    const disp_ptr = abi.read32(0x0806BFD8);
    abi.write8(disp_ptr +% 0, ((abi.read8(disp_ptr +% 0) & 0x3F) | 0x40) & 0xEF);
    abi.write8(disp_ptr +% 1, abi.read8(disp_ptr +% 1) | 0x0E);
    abi.write16(abi.read32(0x0806BFDC), 8);
    abi.write16(abi.read32(0x0806BFE0), 8);
    if (!abi.call(battle.func_0806A2D0, 0x0806BF7D)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_0806A368, 0x0806BF81)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x0806BFE4);
    rt.r[1] = 0xC0 << 2;
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x0806BF8D)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x0806BFE8);
    rt.r[1] = 0xA8 << 2;
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x0806BF99)) return;

    abi.fetches(9);
    abi.write16(abi.read32(0x0806BFEC), 0x90);
    const btn_base = abi.read32(0x0806BFF0);
    inline for ([_]struct { slot: u32, y: u32, off: u32, ret: u32 }{
        .{ .slot = 4, .y = 0x10, .off = 0x1C, .ret = 0x0806BFA7 },
        .{ .slot = 3, .y = 0x40, .off = 0x18, .ret = 0x0806BFB3 },
        .{ .slot = 2, .y = 0x70, .off = 0x14, .ret = 0x0806BFBD },
        .{ .slot = 1, .y = 0xA0, .off = 0x10, .ret = 0x0806BFC7 },
        .{ .slot = 0, .y = 0xE0, .off = 0x0C, .ret = 0x0806BFD1 },
    }, 0..) |b, i| {
        if (i == 1) abi.fetches(8) else if (i > 1) abi.fetches(7);
        rt.r[0] = b.slot;
        rt.r[1] = b.y;
        rt.updateNz(b.y);
        if (!abi.call(battle.func_0806BDC4, b.ret)) return;
        if (i < 4) abi.write32(btn_base +% b.off, rt.r[0]);
    }
    abi.fetches(6);
    abi.write32(btn_base +% 0xC, rt.r[0]);
    rt.r[4] = abi.popReg();
    abi.popReturn();
}

/// Draw wrapped 4-corner OAM border sprites `(x, y, w, h)` using `[0x0806D79C..A8]` (`0x0806D714`).
pub fn func_0806D714() callconv(.c) void {
    if (!abi.enter(0x0806D714)) return;
    abi.fetches(33);
    abi.pushLr();
    abi.pushReg(7);
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.pushReg(10);
    abi.pushReg(9);
    abi.pushReg(8);
    rt.r[13] -%= 4;

    const x = rt.r[0];
    const y = rt.r[1];
    const w = rt.r[2];
    abi.write32(rt.r[13], rt.r[3]);
    const mask_x: u32 = (0x80 << 2) -% 1; // 0x1FF
    const x0 = (x +% 0x200) & mask_x;
    const x1 = (x +% w +% 0x200) & mask_x;
    const y0 = (y +% 0x100) & 0xFF;
    const y1 = (y +% abi.read32(rt.r[13]) +% 0x100) & 0xFF;

    const corners = [_]struct { cx: u32, cy: u32, pool: u32, f: u32, ret: u32 }{
        .{ .cx = x0, .cy = y0, .pool = 0x0806D79C, .f = 0, .ret = 0x0806D753 },
        .{ .cx = x1, .cy = y0, .pool = 0x0806D7A0, .f = 12, .ret = 0x0806D767 },
        .{ .cx = x0, .cy = y1, .pool = 0x0806D7A4, .f = 15, .ret = 0x0806D781 },
        .{ .cx = x1, .cy = y1, .pool = 0x0806D7A8, .f = 8, .ret = 0x0806D78D },
    };
    inline for (corners) |c| {
        if (c.f > 0) abi.fetches(c.f);
        rt.r[0] = c.cx;
        rt.r[1] = c.cy;
        rt.r[2] = abi.read32(c.pool);
        abi.setRegNz(&rt.r[3], 0);
        if (!abi.call(hw.func_0801B888, c.ret)) return;
    }

    abi.fetches(10);
    rt.r[13] +%= 4;
    rt.r[8] = abi.popReg();
    rt.r[9] = abi.popReg();
    rt.r[10] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    rt.r[7] = abi.popReg();
    abi.popReturn();
}

/// Copy 8-word HUD layout table onto stack and update dual status indicators (`0x0806F10C`).
pub fn func_0806F10C() callconv(.c) void {
    if (!abi.enter(0x0806F10C)) return;
    abi.fetches(30);
    abi.pushLr();
    abi.pushReg(5);
    abi.pushReg(4);
    rt.r[13] -%= 0x20;
    const src = abi.read32(0x0806F180);
    inline for (0..8) |i| {
        abi.write32(rt.r[13] +% @as(u32, i * 4), abi.read32(src +% @as(u32, i * 4)));
    }
    const st = abi.read32(abi.read32(0x0806F184));
    const raw_idx = abi.signExtend8(@truncate(abi.read8(st +% 0x36)));
    const half = @divTrunc(raw_idx, 2);
    const entry = abi.read32(st +% 0x38 +% (@as(u32, @bitCast(half)) << 2));
    const bit0: u32 = abi.read8(st +% 0x36) & 1;
    const slot_base = rt.r[13] +% (bit0 << 4);
    rt.r[5] = entry;
    rt.r[4] = slot_base;
    rt.r[2] = st +% 0x38 +% (@as(u32, @bitCast(half)) << 2);
    rt.r[3] = abi.read8(st +% 0x36);
    rt.r[0] = @as(u32, @bitCast(raw_idx));
    rt.r[1] = @as(u32, @bitCast(half)) << 2;
    if (!abi.call(decls.func_0806D80C, 0x0806F145)) return;

    abi.fetches(16);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(entry +% 0x28)) +% abi.signExtend16(abi.read16(slot_base +% 0x8)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(entry +% 0x2A)) +% abi.signExtend16(abi.read16(slot_base +% 0xA)));
    if (!abi.call(decls.func_0806D624, 0x0806F161)) return;

    abi.fetches(14);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(entry +% 0x28)) +% abi.signExtend16(abi.read16(slot_base +% 0xC)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(entry +% 0x2A)) +% abi.signExtend16(abi.read16(slot_base +% 0xE)));
    if (!abi.call(decls.func_0806D69C, 0x0806F179)) return;

    abi.fetches(6);
    rt.r[13] +%= 0x20;
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    abi.popReturn();
}

/// Initialize 11-entry UI icon/sprite overlay bar via `0x08071350` (`0x0807138C`).
pub fn func_0807138C() callconv(.c) void {
    if (!abi.enter(0x0807138C)) return;
    abi.fetches(14);
    abi.pushLr();
    abi.pushReg(5);
    abi.pushReg(4);
    const base_r5 = abi.read32(0x08071438);
    const items = [_]struct { x: i32, y: i32, pool: u32, flag: i32, f: u32, ret: u32 }{
        .{ .x = -0x68, .y = -0x14, .pool = 0, .flag = -0xA9, .f = 0, .ret = 0x080713A5 },
        .{ .x = -0x48, .y = -0x14, .pool = 0x0807143C, .flag = -0xA4, .f = 10, .ret = 0x080713B5 },
        .{ .x = -0x28, .y = -0x14, .pool = 0x08071440, .flag = -0x99, .f = 10, .ret = 0x080713C5 },
        .{ .x = -0x08, .y = -0x14, .pool = 0, .flag = -0x6F, .f = 10, .ret = 0x080713D5 },
        .{ .x = 0x18, .y = -0x14, .pool = 0x08071444, .flag = -0x27, .f = 9, .ret = 0x080713E3 },
        .{ .x = 0x38, .y = -0x14, .pool = 0x08071448, .flag = -0x13, .f = 9, .ret = 0x080713F1 },
        .{ .x = 0x58, .y = -0x14, .pool = 0x0807144C, .flag = -0x0C, .f = 9, .ret = 0x080713FF },
        .{ .x = -0x30, .y = 0x14, .pool = 0x08071450, .flag = 0x9D, .f = 9, .ret = 0x0807140D },
        .{ .x = -0x10, .y = 0x14, .pool = 0, .flag = 0x80, .f = 9, .ret = 0x0807141B },
        .{ .x = 0x10, .y = 0x14, .pool = 0x08071454, .flag = 0x33, .f = 8, .ret = 0x08071427 },
        .{ .x = 0x30, .y = 0x14, .pool = 0x08071458, .flag = 0x16, .f = 8, .ret = 0x08071433 },
    };
    inline for (items) |it| {
        if (it.f > 0) abi.fetches(it.f);
        rt.r[0] = @bitCast(it.x);
        rt.r[1] = @bitCast(it.y);
        rt.r[2] = if (it.pool == 0) base_r5 else abi.read32(it.pool);
        rt.r[3] = @bitCast(it.flag);
        rt.updateNz(rt.r[1]);
        if (!abi.call(func_08071350, it.ret)) return;
    }
    abi.fetches(5);
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    abi.popReturn();
}

/// Initialize world-map/credits banner mode with two DMA/RL decompression buffers (`0x080715F4`).
pub fn func_080715F4() callconv(.c) void {
    if (!abi.enter(0x080715F4)) return;
    abi.fetches(18);
    abi.pushLr();
    abi.pushReg(7);
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.pushReg(10);
    abi.pushReg(9);
    abi.pushReg(8);
    const state = rt.r[0];

    const inc_ptr = abi.read32(0x08071704);
    const prev_cnt = abi.read8(inc_ptr);
    abi.write8(inc_ptr, prev_cnt +% 1);
    rt.r[0] = prev_cnt;
    rt.updateNz(prev_cnt);
    if (!abi.call(decls.func_080702EC, 0x08071615)) return;

    abi.fetches(7);
    abi.write16(state +% 0x42, @truncate(rt.r[0]));
    if (!abi.call(decls.func_080104D4, 0x0807161F)) return;
    abi.fetches(4);
    if (!abi.call(hw.func_080104B0, 0x08071623)) return;
    abi.fetches(4);
    if (!abi.call(func_0806CE3C, 0x08071627)) return;

    abi.fetches(33);
    const disp_ptr = abi.read32(0x08071708);
    abi.write8(disp_ptr +% 1, abi.read8(disp_ptr +% 1) | 0x1C);
    abi.write8(disp_ptr +% 0, (abi.read8(disp_ptr +% 0) & 0x28) | 0x44);

    rt.r[0] = abi.read32(0x0807170C);
    rt.r[1] = abi.read32(0x08071710);
    if (!abi.call(bios.func_080796E8, 0x08071665)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08071714);
    rt.r[1] = 0x80 << 2;
    abi.setRegNz(&rt.r[2], 0xE0);
    if (!abi.call(dma.func_08011330, 0x08071671)) return;

    abi.fetches(6);
    const work_buf: u32 = 0x80 << 18;
    rt.r[0] = abi.read32(0x08071718);
    rt.r[1] = work_buf;
    if (!abi.call(bios.func_080796DC, 0x08071679)) return;

    abi.fetches(14);
    const dma_blk = abi.read32(0x0807171C);
    const dma_ctrl = abi.read32(0x08071720);
    abi.write32(dma_blk +% 0, work_buf);
    abi.write32(dma_blk +% 4, 0xC0 << 19);
    abi.write32(dma_blk +% 8, dma_ctrl);
    rt.r[0] = abi.read32(0x08071724);
    rt.r[1] = work_buf;
    if (!abi.call(bios.func_080796DC, 0x08071691)) return;

    abi.fetches(12);
    abi.write32(dma_blk +% 0, work_buf);
    abi.write32(dma_blk +% 4, abi.read32(0x08071728));
    abi.write32(dma_blk +% 8, dma_ctrl);
    rt.r[0] = abi.read32(0x0807172C);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0x40);
    if (!abi.call(dma.func_08011330, 0x080716A5)) return;

    abi.fetches(19);
    const p30 = abi.read32(0x08071730);
    abi.write8(p30, abi.read8(p30) | 0x1F);

    const sfx = [_]struct { pool: u32, ret: u32, f: u32 }{
        .{ .pool = 0x08071734, .ret = 0x080716C7, .f = 0 },
        .{ .pool = 0x08071738, .ret = 0x080716CF, .f = 6 },
        .{ .pool = 0x0807173C, .ret = 0x080716DF, .f = 10 },
    };
    inline for (sfx, 0..) |s, i| {
        if (i == 1) {
            abi.fetches(6);
        } else if (i == 2) {
            abi.fetches(10);
            abi.write16(rt.r[0] +% 0x42, @truncate(abi.read16(state +% 0x42) -% 0x89));
        }
        rt.r[0] = abi.read32(s.pool);
        abi.setRegNz(&rt.r[1], 0);
        if (!abi.call(decls.func_0801320C, s.ret)) return;
    }

    abi.fetches(20);
    abi.write16(rt.r[0] +% 0x42, @truncate(abi.read16(state +% 0x42) -% 0x1B));
    abi.write16(abi.read32(0x08071740), 0);
    abi.write16(state +% 0x44, 0);
    rt.r[8] = abi.popReg();
    rt.r[9] = abi.popReg();
    rt.r[10] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    rt.r[7] = abi.popReg();
    abi.popReturn();
}

/// Initialize credits dialogue panel and spawn UI text controller via `0x08038A70` (`0x08072CE8`).
pub fn func_08072CE8() callconv(.c) void {
    if (!abi.enter(0x08072CE8)) return;
    abi.fetches(8);
    abi.pushLr();
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    rt.r[13] -%= 0x34;
    const state = rt.r[0];

    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_0806CD50, 0x08072CF5)) return;
    abi.fetches(6);
    rt.r[0] = 0x80 << 2;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_0806CD50, 0x08072CFD)) return;

    inline for ([_]struct { p: u32, r: u32 }{
        .{ .p = 0x08072D98, .r = 0x08072D11 },
        .{ .p = 0x08072D9C, .r = 0x08072D21 },
    }, 0..) |m, i| {
        abi.fetches(if (i == 0) @as(u32, 12) else 10);
        abi.write32(rt.r[13] +% 0, 0x14);
        abi.write32(rt.r[13] +% 4, 0);
        rt.r[0] = abi.read32(m.p);
        abi.setRegNz(&rt.r[1], 0);
        abi.setRegNz(&rt.r[2], 0);
        abi.setRegNz(&rt.r[3], 0x20);
        if (!abi.call(hw.func_08010C70, m.r)) return;
    }

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_0806CD78, 0x08072D27)) return;

    abi.fetches(10);
    const inc_ptr = abi.read32(0x08072DA0);
    const prev_cnt = abi.read8(inc_ptr);
    abi.write8(inc_ptr, prev_cnt +% 1);
    rt.r[0] = prev_cnt;
    rt.updateNz(prev_cnt);
    if (!abi.call(decls.func_080702EC, 0x08072D37)) return;

    abi.fetches(31);
    abi.write16(state +% 0x42, @truncate(rt.r[0]));
    const args_sp = [_]u32{ 1, 0x64, 0x5A, 3, 2, 6, 6, 2, 0x64, 0xA, 0, 0, abi.read32(0x08072DA4) };
    inline for (args_sp, 0..) |val, idx| {
        abi.write32(rt.r[13] +% @as(u32, idx * 4), val);
    }
    abi.setRegNz(&rt.r[0], 0);
    abi.setRegNz(&rt.r[1], 1);
    abi.setRegNz(&rt.r[2], 4);
    abi.setRegNz(&rt.r[3], 3);
    if (!abi.call(campaign.func_08038A70, 0x08072D71)) return;

    abi.fetches(11);
    const p_a8 = abi.read32(0x08072DA8);
    abi.write8(p_a8, abi.read8(p_a8) | 0x80);
    rt.r[0] = abi.read32(0x08072DAC);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08072D83)) return;

    abi.fetches(8);
    abi.setRegNz(&rt.r[1], 0x10);
    abi.setRegNz(&rt.r[2], 0);
    rt.r[3] = 0 -% @as(u32, 2);
    rt.updateNz(rt.r[3]);
    if (!abi.call(func_08072C6C, 0x08072D8F)) return;

    abi.fetches(6);
    rt.r[13] +%= 0x34;
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    abi.popReturn();
}

/// Set up dual-layer scroll & DMA gradient showcase (`0x080738CC`).
pub fn func_080738CC() callconv(.c) void {
    if (!abi.enter(0x080738CC)) return;
    abi.fetches(17);
    abi.pushLr();
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.pushReg(10);
    abi.pushReg(9);
    abi.pushReg(8);
    rt.r[13] -%= 4;
    const state = rt.r[0];

    const inc_ptr = abi.read32(0x08073A0C);
    const prev_cnt = abi.read8(inc_ptr);
    abi.write8(inc_ptr, prev_cnt +% 1);
    rt.r[0] = prev_cnt;
    rt.updateNz(prev_cnt);
    if (!abi.call(decls.func_080702EC, 0x080738EB)) return;

    abi.fetches(19);
    abi.write16(state +% 0x42, @truncate(rt.r[0]));
    const disp_ptr = abi.read32(0x08073A10);
    abi.write8(disp_ptr +% 0, (abi.read8(disp_ptr +% 0) & 0xF8) | 0x02);
    if (!abi.call(decls.func_080104D4, 0x0807390D)) return;
    abi.fetches(4);
    if (!abi.call(hw.func_080104B0, 0x08073911)) return;
    abi.fetches(4);
    if (!abi.call(func_0806CE3C, 0x08073915)) return;

    const l0 = abi.read32(0x08073A14);
    const l1 = abi.read32(0x08073A18);
    abi.fetches(7);
    rt.r[0] = l0;
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_08010CD8, 0x0807391F)) return;
    abi.fetches(7);
    rt.r[0] = l0;
    rt.r[1] = 0xF0 << 7;
    if (!abi.call(decls.func_08010CC4, 0x08073929)) return;
    abi.fetches(8);
    rt.r[0] = l1;
    rt.r[1] = 0x80 << 8;
    if (!abi.call(decls.func_08010CD8, 0x08073935)) return;
    abi.fetches(7);
    rt.r[0] = l1;
    rt.r[1] = 0xF8 << 8;
    if (!abi.call(decls.func_08010CC4, 0x0807393F)) return;

    abi.fetches(44);
    abi.write8(l0 +% 0, abi.read8(l0 +% 0) & 0xFC);
    abi.write8(l1 +% 0, (abi.read8(l1 +% 0) & 0xFC) | 1);
    const p1c = abi.read32(0x08073A1C);
    abi.write8(p1c, (abi.read8(p1c) & 0xFC) | 2);
    const p20 = abi.read32(0x08073A20);
    abi.write8(p20, abi.read8(p20) | 3);
    abi.write8(disp_ptr +% 1, abi.read8(disp_ptr +% 1) & 0xFC);
    abi.write8(l0 +% 1, abi.read8(l0 +% 1) | 0x20);
    abi.write8(l1 +% 1, abi.read8(l1 +% 1) | 0x20);
    rt.r[0] = l0;
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_08010CF0, 0x08073993)) return;
    abi.fetches(6);
    rt.r[0] = l1;
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_08010CF0, 0x0807399B)) return;

    abi.fetches(24);
    const dma_blk = abi.read32(0x08073A24);
    const dma_cnt = abi.read32(0x08073A2C);
    inline for ([_]u32{ 0x08073A28, 0x08073A30 }) |src_p| {
        abi.write16(rt.r[13], 0);
        abi.write32(dma_blk +% 0, rt.r[13]);
        abi.write32(dma_blk +% 4, abi.read32(src_p));
        abi.write32(dma_blk +% 8, dma_cnt);
        _ = abi.read32(dma_blk +% 8);
    }
    rt.r[0] = abi.read32(0x08073A34);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x080739C7)) return;

    abi.fetches(24);
    abi.write16(rt.r[13], @truncate(abi.read32(0x08073A38)));
    abi.write32(dma_blk +% 0, rt.r[13]);
    abi.write32(dma_blk +% 4, abi.read32(0x08073A3C));
    abi.write32(dma_blk +% 8, abi.read32(0x08073A40));
    _ = abi.read32(dma_blk +% 8);

    abi.write16(rt.r[13], @truncate(abi.read32(0x08073A44)));
    abi.write32(dma_blk +% 0, rt.r[13]);
    abi.write32(dma_blk +% 4, abi.read32(0x08073A48));
    abi.write32(dma_blk +% 8, dma_cnt);
    _ = abi.read32(dma_blk +% 8);

    rt.r[0] = abi.read32(0x08073A4C);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x080739F3)) return;

    abi.fetches(15);
    abi.write16(state +% 0x44, 0);
    rt.r[13] +%= 4;
    rt.r[8] = abi.popReg();
    rt.r[9] = abi.popReg();
    rt.r[10] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    abi.popReturn();
}

/// Initialize alternate credits/ending sequence state (`0x08075968`).
pub fn func_08075968() callconv(.c) void {
    if (!abi.enter(0x08075968)) return;
    abi.fetches(30);
    abi.pushLr();
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    const state = rt.r[0];

    const disp_ptr = abi.read32(0x08075A18);
    abi.write8(disp_ptr +% 1, abi.read8(disp_ptr +% 1) | 0x1C);
    abi.write8(disp_ptr +% 0, (abi.read8(disp_ptr +% 0) & 0x28) | 0x44);
    if (!abi.call(decls.func_080104D4, 0x080759A1)) return;
    abi.fetches(4);
    if (!abi.call(hw.func_080104B0, 0x080759A5)) return;
    abi.fetches(4);
    if (!abi.call(func_0806CE3C, 0x080759A9)) return;

    abi.fetches(9);
    rt.r[0] = abi.read32(0x08075A1C);
    rt.r[1] = 0x80 << 2;
    abi.setRegNz(&rt.r[2], 0xC0);
    if (!abi.call(dma.func_08011330, 0x080759B7)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x08075A20);
    abi.setRegNz(&rt.r[1], 0);
    rt.r[2] = 0x80 << 2;
    rt.updateNz(rt.r[2]);
    if (!abi.call(dma.func_08011330, 0x080759C1)) return;

    abi.fetches(6);
    rt.r[0] = 0 -% @as(u32, 1);
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_080116D8, 0x080759C9)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080796A4, 0x080759CD)) return;
    abi.fetches(4);
    if (!abi.call(hw.func_080112C0, 0x080759D1)) return;

    abi.fetches(9);
    abi.write16(state +% 0x44, 0x3F);
    const work_buf: u32 = 0x80 << 18;
    rt.r[0] = abi.read32(0x08075A24);
    rt.r[1] = work_buf;
    if (!abi.call(bios.func_080796DC, 0x080759DF)) return;

    abi.fetches(14);
    const dma_blk = abi.read32(0x08075A28);
    const dma_cnt = abi.read32(0x08075A2C);
    abi.write32(dma_blk +% 0, work_buf);
    abi.write32(dma_blk +% 4, 0xC0 << 19);
    abi.write32(dma_blk +% 8, dma_cnt);
    rt.r[0] = abi.read32(0x08075A30);
    rt.r[1] = work_buf;
    if (!abi.call(bios.func_080796DC, 0x080759F7)) return;

    abi.fetches(9);
    abi.write32(dma_blk +% 0, work_buf);
    abi.write32(dma_blk +% 4, abi.read32(0x08075A34));
    abi.write32(dma_blk +% 8, dma_cnt);
    if (!abi.call(func_08075B2C, 0x08075A05)) return;

    abi.fetches(4);
    if (!abi.call(sound.func_0803D968, 0x08075A09)) return;

    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x08075A38));
    if (!abi.call(decls.func_08013BD0, 0x08075A11)) return;

    abi.fetches(5);
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    abi.popReturn();
}

/// Draw 4 wrapped parallax OAM overlay sprites using camera phase table (`0x08076074`).
pub fn func_08076074() callconv(.c) void {
    if (!abi.enter(0x08076074)) return;
    abi.fetches(46);
    abi.pushLr();
    abi.pushReg(7);
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.pushReg(10);
    abi.pushReg(9);
    abi.pushReg(8);
    rt.r[13] -%= 8;

    const x = rt.r[0];
    const y = rt.r[1];
    abi.write32(rt.r[13] +% 0, rt.r[2]);
    abi.write32(rt.r[13] +% 4, rt.r[3]);

    const phase_tbl = abi.read32(0x0807611C);
    const frame_cnt = abi.read32(abi.read32(0x08076120));
    const sway = abi.read8(phase_tbl +% ((frame_cnt >> 3) & 3));
    const mask_x = abi.read32(0x08076124);
    const x0 = ((x -% sway) +% 0x200) & mask_x;
    const x1 = ((x +% abi.read32(rt.r[13] +% 0)) +% sway +% 0x200) & mask_x;
    const y0 = ((y -% sway) +% 0x100) & 0xFF;
    const y1 = ((y +% abi.read32(rt.r[13] +% 4)) +% sway +% 0x100) & 0xFF;

    const corners = [_]struct { cx: u32, cy: u32, pool: u32, f: u32, ret: u32 }{
        .{ .cx = x0, .cy = y0, .pool = 0x08076128, .f = 0, .ret = 0x080760CD },
        .{ .cx = x1, .cy = y0, .pool = 0x0807612C, .f = 14, .ret = 0x080760E5 },
        .{ .cx = x0, .cy = y1, .pool = 0x08076130, .f = 16, .ret = 0x08076101 },
        .{ .cx = x1, .cy = y1, .pool = 0x08076134, .f = 8, .ret = 0x0807610D },
    };
    inline for (corners) |c| {
        if (c.f > 0) abi.fetches(c.f);
        rt.r[0] = c.cx;
        rt.r[1] = c.cy;
        rt.r[2] = abi.read32(c.pool);
        abi.setRegNz(&rt.r[3], 0);
        if (!abi.call(hw.func_0801B888, c.ret)) return;
    }

    abi.fetches(10);
    rt.r[13] +%= 8;
    rt.r[8] = abi.popReg();
    rt.r[9] = abi.popReg();
    rt.r[10] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    rt.r[7] = abi.popReg();
    abi.popReturn();
}

/// Render status banner card labels and 3 OAM indicator sprites, bumping `card+0x49` (`0x080764E8`).
pub fn func_080764E8() callconv(.c) void {
    if (!abi.enter(0x080764E8)) return;
    abi.fetches(12);
    abi.pushLr();
    abi.pushReg(7);
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    const card = rt.r[0];

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(card +% 0x28)) +% 0x20);
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(card +% 0x2A)));
    rt.r[2] = abi.read16(card +% 0x1C);
    if (!abi.call(decls.func_0806E044, 0x080764FD)) return;

    abi.fetches(11);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(card +% 0x28)) +% 0x20);
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(card +% 0x2A)) +% 0x10);
    rt.r[2] = abi.read16(card +% 0x1C);
    if (!abi.call(hw.func_0806E098, 0x0807650F)) return;

    abi.fetches(18);
    const x_mask = abi.read32(0x08076590);
    const raw_x = abi.read16(card +% 0x28);
    const sx = (0x200 +% raw_x) & x_mask;
    const raw_y = abi.read16(card +% 0x2A);
    rt.r[0] = sx;
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(raw_y +% 0x1C)));
    rt.r[2] = abi.read32(0x08076594);
    rt.r[3] = abi.read16(card +% 0x3E);
    rt.updateNz(rt.r[1]);
    if (!abi.call(hw.func_0801B888, 0x0807652F)) return;

    abi.fetches(15);
    const tbl2 = abi.read32(0x08076598);
    rt.r[0] = (0x200 +% abi.read16(card +% 0x28)) & x_mask;
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(card +% 0x2A)));
    rt.r[2] = tbl2;
    rt.r[3] = abi.read16(card +% 0x44);
    if (!abi.call(hw.func_0801B888, 0x08076549)) return;

    abi.fetches(30);
    const cx = (@as(u32, @bitCast(abi.signExtend16(abi.read16(card +% 0x28)))) +% (0x82 << 2)) & x_mask;
    const cy_base = abi.signExtend16(abi.read16(card +% 0x2A));
    const state_tbl = abi.read32(abi.read32(0x0807659C));
    const idx_val: u32 = abi.read8(state_tbl +% 0x11 +% abi.read16(card +% 0x1C));
    const cy = (@as(u32, @bitCast(cy_base)) +% (idx_val << 2) +% (0x93 << 1)) & 0xFF;
    const attr3 = ((idx_val << 20) +% abi.read32(0x080765A0)) >> 16;
    rt.r[0] = cx;
    rt.r[1] = cy;
    rt.r[2] = tbl2;
    rt.r[3] = attr3;
    rt.updateNz(attr3);
    if (!abi.call(hw.func_0801B888, 0x08076581)) return;

    abi.fetches(10);
    abi.write8(card +% 0x49, abi.read8(card +% 0x49));
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    rt.r[7] = abi.popReg();
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
        @export(&func_080416B8, .{ .name = "func_080416B8", .linkage = .strong });
        @export(&func_080420D0, .{ .name = "func_080420D0", .linkage = .strong });
        @export(&func_080420FC, .{ .name = "func_080420FC", .linkage = .strong });
        @export(&func_080422EC, .{ .name = "func_080422EC", .linkage = .strong });
        @export(&func_0804278C, .{ .name = "func_0804278C", .linkage = .strong });
        @export(&func_08042DE8, .{ .name = "func_08042DE8", .linkage = .strong });
        @export(&func_08043890, .{ .name = "func_08043890", .linkage = .strong });
        @export(&func_08043A3C, .{ .name = "func_08043A3C", .linkage = .strong });
        @export(&func_08043EF0, .{ .name = "func_08043EF0", .linkage = .strong });
        @export(&func_08044338, .{ .name = "func_08044338", .linkage = .strong });
        @export(&func_08044354, .{ .name = "func_08044354", .linkage = .strong });
        @export(&func_08046D98, .{ .name = "func_08046D98", .linkage = .strong });
        @export(&func_08046E00, .{ .name = "func_08046E00", .linkage = .strong });
        @export(&func_08046FBC, .{ .name = "func_08046FBC", .linkage = .strong });
        @export(&func_080471C8, .{ .name = "func_080471C8", .linkage = .strong });
        @export(&func_08047210, .{ .name = "func_08047210", .linkage = .strong });
        @export(&func_08047944, .{ .name = "func_08047944", .linkage = .strong });
        @export(&func_08048AA4, .{ .name = "func_08048AA4", .linkage = .strong });
        @export(&func_08048AE8, .{ .name = "func_08048AE8", .linkage = .strong });
        @export(&func_080491C0, .{ .name = "func_080491C0", .linkage = .strong });
        @export(&func_080492AC, .{ .name = "func_080492AC", .linkage = .strong });
        @export(&func_08049870, .{ .name = "func_08049870", .linkage = .strong });
        @export(&func_08049C9C, .{ .name = "func_08049C9C", .linkage = .strong });
        @export(&func_08049D68, .{ .name = "func_08049D68", .linkage = .strong });
        @export(&func_08049DAC, .{ .name = "func_08049DAC", .linkage = .strong });
        @export(&func_08049EC0, .{ .name = "func_08049EC0", .linkage = .strong });
        @export(&func_0804A17C, .{ .name = "func_0804A17C", .linkage = .strong });
        @export(&func_0804A1F0, .{ .name = "func_0804A1F0", .linkage = .strong });
        @export(&func_0804B50C, .{ .name = "func_0804B50C", .linkage = .strong });
        @export(&func_0804C5B0, .{ .name = "func_0804C5B0", .linkage = .strong });
        @export(&func_0804C6EC, .{ .name = "func_0804C6EC", .linkage = .strong });
        @export(&func_0804D158, .{ .name = "func_0804D158", .linkage = .strong });
        @export(&func_0804D1F4, .{ .name = "func_0804D1F4", .linkage = .strong });
        @export(&func_0804D9E8, .{ .name = "func_0804D9E8", .linkage = .strong });
        @export(&func_0804DBB8, .{ .name = "func_0804DBB8", .linkage = .strong });
        @export(&func_0804DC0C, .{ .name = "func_0804DC0C", .linkage = .strong });
        @export(&func_0804F018, .{ .name = "func_0804F018", .linkage = .strong });
        @export(&func_0804F800, .{ .name = "func_0804F800", .linkage = .strong });
        @export(&func_0804FA10, .{ .name = "func_0804FA10", .linkage = .strong });
        @export(&func_080502C4, .{ .name = "func_080502C4", .linkage = .strong });
        @export(&func_08050344, .{ .name = "func_08050344", .linkage = .strong });
        @export(&func_0805041C, .{ .name = "func_0805041C", .linkage = .strong });
        @export(&func_08050894, .{ .name = "func_08050894", .linkage = .strong });
        @export(&func_08050A54, .{ .name = "func_08050A54", .linkage = .strong });
        @export(&func_08050DE4, .{ .name = "func_08050DE4", .linkage = .strong });
        @export(&func_08051B00, .{ .name = "func_08051B00", .linkage = .strong });
        @export(&func_08052658, .{ .name = "func_08052658", .linkage = .strong });
        @export(&func_08052C98, .{ .name = "func_08052C98", .linkage = .strong });
        @export(&func_08053054, .{ .name = "func_08053054", .linkage = .strong });
        @export(&func_08054644, .{ .name = "func_08054644", .linkage = .strong });
        @export(&func_08054BA8, .{ .name = "func_08054BA8", .linkage = .strong });
        @export(&func_08055988, .{ .name = "func_08055988", .linkage = .strong });
        @export(&func_08057060, .{ .name = "func_08057060", .linkage = .strong });
        @export(&func_0805A008, .{ .name = "func_0805A008", .linkage = .strong });
        @export(&func_0805DD50, .{ .name = "func_0805DD50", .linkage = .strong });
        @export(&func_0805E7A0, .{ .name = "func_0805E7A0", .linkage = .strong });
        @export(&func_080648EC, .{ .name = "func_080648EC", .linkage = .strong });
        @export(&func_0806C328, .{ .name = "func_0806C328", .linkage = .strong });
        @export(&func_0806CE3C, .{ .name = "func_0806CE3C", .linkage = .strong });
        @export(&func_0806CEBC, .{ .name = "func_0806CEBC", .linkage = .strong });
        @export(&func_0806DA04, .{ .name = "func_0806DA04", .linkage = .strong });
        @export(&func_0806DC74, .{ .name = "func_0806DC74", .linkage = .strong });
        @export(&func_0806DE4C, .{ .name = "func_0806DE4C", .linkage = .strong });
        @export(&func_080737D8, .{ .name = "func_080737D8", .linkage = .strong });
        @export(&func_0807383C, .{ .name = "func_0807383C", .linkage = .strong });
        @export(&func_08074260, .{ .name = "func_08074260", .linkage = .strong });
        @export(&func_0807427C, .{ .name = "func_0807427C", .linkage = .strong });
        @export(&func_080752E0, .{ .name = "func_080752E0", .linkage = .strong });
        @export(&func_08075490, .{ .name = "func_08075490", .linkage = .strong });
        @export(&func_08075B2C, .{ .name = "func_08075B2C", .linkage = .strong });
        @export(&func_0802C604, .{ .name = "func_0802C604", .linkage = .strong });
        @export(&func_0802C808, .{ .name = "func_0802C808", .linkage = .strong });
        @export(&func_0804071C, .{ .name = "func_0804071C", .linkage = .strong });
        @export(&func_08040778, .{ .name = "func_08040778", .linkage = .strong });
        @export(&func_08040A9C, .{ .name = "func_08040A9C", .linkage = .strong });
        @export(&func_08041E94, .{ .name = "func_08041E94", .linkage = .strong });
        @export(&func_08041F90, .{ .name = "func_08041F90", .linkage = .strong });
        @export(&func_08041FF0, .{ .name = "func_08041FF0", .linkage = .strong });
        @export(&func_08042084, .{ .name = "func_08042084", .linkage = .strong });
        @export(&func_08042D9C, .{ .name = "func_08042D9C", .linkage = .strong });
        @export(&func_08042FA8, .{ .name = "func_08042FA8", .linkage = .strong });
        @export(&func_08043C64, .{ .name = "func_08043C64", .linkage = .strong });
        @export(&func_08044EB8, .{ .name = "func_08044EB8", .linkage = .strong });
        @export(&func_08046564, .{ .name = "func_08046564", .linkage = .strong });
        @export(&func_08046E24, .{ .name = "func_08046E24", .linkage = .strong });
        @export(&func_08048A44, .{ .name = "func_08048A44", .linkage = .strong });
        @export(&func_08049220, .{ .name = "func_08049220", .linkage = .strong });
        @export(&func_08049674, .{ .name = "func_08049674", .linkage = .strong });
        @export(&func_080496E4, .{ .name = "func_080496E4", .linkage = .strong });
        @export(&func_08049758, .{ .name = "func_08049758", .linkage = .strong });
        @export(&func_08049834, .{ .name = "func_08049834", .linkage = .strong });
        @export(&func_08049CF0, .{ .name = "func_08049CF0", .linkage = .strong });
        @export(&func_0804A20C, .{ .name = "func_0804A20C", .linkage = .strong });
        @export(&func_0804B72C, .{ .name = "func_0804B72C", .linkage = .strong });
        @export(&func_0804C69C, .{ .name = "func_0804C69C", .linkage = .strong });
        @export(&func_0804CBE0, .{ .name = "func_0804CBE0", .linkage = .strong });
        @export(&func_0804DA8C, .{ .name = "func_0804DA8C", .linkage = .strong });
        @export(&func_0804F838, .{ .name = "func_0804F838", .linkage = .strong });
        @export(&func_0804F944, .{ .name = "func_0804F944", .linkage = .strong });
        @export(&func_08050568, .{ .name = "func_08050568", .linkage = .strong });
        @export(&func_08050E74, .{ .name = "func_08050E74", .linkage = .strong });
        @export(&func_08051CA8, .{ .name = "func_08051CA8", .linkage = .strong });
        @export(&func_0805390C, .{ .name = "func_0805390C", .linkage = .strong });
        @export(&func_0806E0E4, .{ .name = "func_0806E0E4", .linkage = .strong });
        @export(&func_0806F298, .{ .name = "func_0806F298", .linkage = .strong });
        @export(&func_08071F68, .{ .name = "func_08071F68", .linkage = .strong });
        @export(&func_08072DB0, .{ .name = "func_08072DB0", .linkage = .strong });
        @export(&func_080747F8, .{ .name = "func_080747F8", .linkage = .strong });
        @export(&func_08074C84, .{ .name = "func_08074C84", .linkage = .strong });
        @export(&func_080754F4, .{ .name = "func_080754F4", .linkage = .strong });
        @export(&func_08075808, .{ .name = "func_08075808", .linkage = .strong });
        @export(&func_08075EB8, .{ .name = "func_08075EB8", .linkage = .strong });
        @export(&func_08040218, .{ .name = "func_08040218", .linkage = .strong });
        @export(&func_08041A80, .{ .name = "func_08041A80", .linkage = .strong });
        @export(&func_08041BB0, .{ .name = "func_08041BB0", .linkage = .strong });
        @export(&func_080421EC, .{ .name = "func_080421EC", .linkage = .strong });
        @export(&func_08047AB0, .{ .name = "func_08047AB0", .linkage = .strong });
        @export(&func_08049000, .{ .name = "func_08049000", .linkage = .strong });
        @export(&func_08049010, .{ .name = "func_08049010", .linkage = .strong });
        @export(&func_0804901C, .{ .name = "func_0804901C", .linkage = .strong });
        @export(&func_0804A06C, .{ .name = "func_0804A06C", .linkage = .strong });
        @export(&func_0804A0F0, .{ .name = "func_0804A0F0", .linkage = .strong });
        @export(&func_0804C7C0, .{ .name = "func_0804C7C0", .linkage = .strong });
        @export(&func_0804FC40, .{ .name = "func_0804FC40", .linkage = .strong });
        @export(&func_0804FD1C, .{ .name = "func_0804FD1C", .linkage = .strong });
        @export(&func_0804FF1C, .{ .name = "func_0804FF1C", .linkage = .strong });
        @export(&func_08050134, .{ .name = "func_08050134", .linkage = .strong });
        @export(&func_08050EB4, .{ .name = "func_08050EB4", .linkage = .strong });
        @export(&func_080518B4, .{ .name = "func_080518B4", .linkage = .strong });
        @export(&func_08051DE8, .{ .name = "func_08051DE8", .linkage = .strong });
        @export(&func_0805DD64, .{ .name = "func_0805DD64", .linkage = .strong });
        @export(&func_080402D4, .{ .name = "func_080402D4", .linkage = .strong });
        @export(&func_0804FE74, .{ .name = "func_0804FE74", .linkage = .strong });
        @export(&func_080501DC, .{ .name = "func_080501DC", .linkage = .strong });
        @export(&func_0805EC80, .{ .name = "func_0805EC80", .linkage = .strong });
        @export(&func_0805E2DC, .{ .name = "func_0805E2DC", .linkage = .strong });
        @export(&func_08068368, .{ .name = "func_08068368", .linkage = .strong });
        @export(&func_0806A484, .{ .name = "func_0806A484", .linkage = .strong });
        @export(&func_0806AAA0, .{ .name = "func_0806AAA0", .linkage = .strong });
        @export(&func_0806BF30, .{ .name = "func_0806BF30", .linkage = .strong });
        @export(&func_0806D714, .{ .name = "func_0806D714", .linkage = .strong });
        @export(&func_0806F10C, .{ .name = "func_0806F10C", .linkage = .strong });
        @export(&func_0807138C, .{ .name = "func_0807138C", .linkage = .strong });
        @export(&func_080715F4, .{ .name = "func_080715F4", .linkage = .strong });
        @export(&func_08072CE8, .{ .name = "func_08072CE8", .linkage = .strong });
        @export(&func_080738CC, .{ .name = "func_080738CC", .linkage = .strong });
        @export(&func_08075968, .{ .name = "func_08075968", .linkage = .strong });
        @export(&func_08076074, .{ .name = "func_08076074", .linkage = .strong });
        @export(&func_080764E8, .{ .name = "func_080764E8", .linkage = .strong });
    }
}

test "encodeScreenEntry packs tile, palette bank, and flip flags" {
    try std.testing.expectEqual(@as(u16, 0x2015), encodeScreenEntry(0x15, 2, 0));
    try std.testing.expectEqual(@as(u16, 0x2415), encodeScreenEntry(0x15, 2, 1));
    try std.testing.expectEqual(@as(u32, 0x0300_48D4), types.addr.ui_dialog_state_ptr);
}
