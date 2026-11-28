//! Lifted proc sprite/animator pool (`0x0300_2320`, stride `0x4C`) and OAM queue helpers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const abi = @import("abi.zig");
const clusters_low = @import("clusters_low.zig");
const dma = @import("dma.zig");
const low_peel_1 = @import("low_peel_1.zig");
const low_peel_3 = @import("low_peel_3.zig");
const low_peel_6 = @import("low_peel_6.zig");
const mem = @import("mem.zig");
const tail_low = @import("tail_low.zig");
const types = @import("types.zig");

/// Compute address of animator struct owned by proc `proc_idx` (`(proc.anim_slot) * 0x4C`).
pub inline fn resolveAnimAddr(proc_base: u32, anim_base: u32, proc_idx: i16) u32 {
    const proc_off: u32 = @bitCast(@as(i32, proc_idx) *% @as(i32, types.proc_slot_stride));
    const slot_idx = abi.read16(proc_base +% proc_off +% @offsetOf(types.ProcSlot, "anim_slot"));
    if (anim_base == types.addr.anim_pool) return mem.animSlotAddr(slot_idx);
    return anim_base +% @as(u32, slot_idx) *% @as(u32, types.anim_slot_stride);
}

inline fn finishPoppedLr(comptime dst_reg: u2) void {
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[dst_reg] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Set animator `(x_vec, y_vec)` 32-bit words at `+0x30` and `+0x34` (`0x08013598`).
pub fn func_08013598() callconv(.c) void {
    if (!abi.enter(0x08013598)) return;
    abi.fetches(21);
    const proc_base = abi.read32(0x080135C4);
    const proc_idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const proc_off: u32 = @bitCast(@as(i32, proc_idx) *% 0x60);
    const slot_idx = abi.read16(proc_base +% proc_off +% 0x26);
    const anim = mem.animSlotAddr(slot_idx);
    const target = anim +% 0x30;
    abi.write32(target, rt.r[1]);
    abi.write32(target +% 4, rt.r[2]);
    rt.r[3] = slot_idx;
    rt.r[0] = rt.r[14];
    rt.recompReturn(rt.r[14]);
}

/// Copy animator `(x_vec, y_vec)` (`+0x30/+0x34`) for proc `r1` into `[r0]` (`0x080135C8`).
pub fn func_080135C8() callconv(.c) void {
    if (!abi.enter(0x080135C8)) return;
    abi.fetches(23);
    const anim_base = abi.read32(0x080135F4);
    const proc_base = abi.read32(0x080135F8);
    const proc_idx: i16 = @bitCast(@as(u16, @truncate(rt.r[1])));
    const anim = resolveAnimAddr(proc_base, anim_base, proc_idx);
    const src = anim +% 0x30;
    const v0 = abi.read32(src);
    const v1 = abi.read32(src +% 4);
    abi.write32(rt.r[0], v0);
    abi.write32(rt.r[0] +% 4, v1);
    rt.r[3] = anim_base +% 0x30;
    rt.r[1] = v0;
    rt.r[2] = rt.r[14];
    rt.recompReturn(rt.r[14]);
}

/// Copy animator `(x_vec, y_vec)` (`+0x30/+0x34`) for proc `r0` into `[r1]` (`0x080135FC`).
pub fn func_080135FC() callconv(.c) void {
    if (!abi.enter(0x080135FC)) return;
    abi.fetches(23);
    const anim_base = abi.read32(0x08013628);
    const proc_base = abi.read32(0x0801362C);
    const proc_idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const anim = resolveAnimAddr(proc_base, anim_base, proc_idx);
    const src = anim +% 0x30;
    const v0 = abi.read32(src);
    const v1 = abi.read32(src +% 4);
    abi.write32(rt.r[1], v0);
    abi.write32(rt.r[1] +% 4, v1);
    rt.r[2] = v0;
    rt.r[3] = v1;
    rt.r[0] = rt.r[14];
    rt.recompReturn(rt.r[14]);
}

/// Reset timer `+0x1C = 0` and set animator `+0x04/+0x08 = r1` (`0x08013678`).
pub fn func_08013678() callconv(.c) void {
    if (!abi.enter(0x08013678)) return;
    abi.fetches(19);
    const proc_base = abi.read32(0x0801369C);
    const anim_base = abi.read32(0x080136A0);
    const proc_idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const anim = resolveAnimAddr(proc_base, anim_base, proc_idx);
    abi.write16(anim +% 0x1C, 0);
    abi.write32(anim +% 4, rt.r[1]);
    abi.write32(anim +% 8, rt.r[1]);
    rt.r[0] = anim;
    abi.setRegNz(&rt.r[2], 0);
    rt.r[3] = anim_base;
    rt.recompReturn(rt.r[14]);
}

/// Assign animation script table `r1` sub-entry `r2` onto proc `r0` animator (`0x080136D8`).
pub fn func_080136D8() callconv(.c) void {
    if (!abi.enter(0x080136D8)) return;
    abi.fetches(29);
    const proc_idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const table = rt.r[1];
    const sub_idx: u16 = @truncate(rt.r[2]);
    const proc_base = abi.read32(0x08013710);
    const anim_base = abi.read32(0x08013714);
    const anim = resolveAnimAddr(proc_base, anim_base, proc_idx);
    abi.write16(anim +% 0x1C, 0);
    const script_ptr = abi.read32(table +% (@as(u32, sub_idx) << 2) +% 4);
    abi.write32(anim +% 4, script_ptr);
    abi.write32(anim +% 8, script_ptr);
    abi.write32(anim +% 0x48, table);
    const param0 = abi.read32(table);
    abi.write32(anim +% 0x20, param0);
    rt.r[1] = param0;
    rt.r[2] = script_ptr;
    rt.r[3] = 0;
    rt.r[0] = rt.r[14];
    rt.recompReturn(rt.r[14]);
}

fn writeAnim32(comptime field_off: u32, comptime anim_pool_ref: u32, comptime proc_pool_ref: u32) void {
    abi.fetches(20);
    const anim_base = abi.read32(anim_pool_ref);
    const proc_base = abi.read32(proc_pool_ref);
    const proc_idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const anim = resolveAnimAddr(proc_base, anim_base, proc_idx);
    const val = rt.r[1];
    abi.write32(anim +% field_off, val);
    rt.r[0] = anim +% field_off;
    rt.r[2] = abi.read16(proc_base +% @as(u32, @bitCast(@as(i32, proc_idx) *% 0x60)) +% 0x26);
    rt.r[3] = anim_base +% field_off;
    rt.r[0] = rt.r[14];
    rt.recompReturn(rt.r[14]);
}

fn writeAnim16(comptime field_off: u32, comptime anim_pool_ref: u32, comptime proc_pool_ref: u32, comptime add_after: bool) void {
    abi.fetches(if (add_after) 20 else 19);
    const anim_base = abi.read32(anim_pool_ref);
    const proc_base = abi.read32(proc_pool_ref);
    const proc_idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const anim = resolveAnimAddr(proc_base, anim_base, proc_idx);
    const val16: u16 = @truncate(rt.r[1]);
    abi.write16(anim +% field_off, val16);
    rt.r[2] = abi.read16(proc_base +% @as(u32, @bitCast(@as(i32, proc_idx) *% 0x60)) +% 0x26);
    rt.r[3] = proc_base;
    rt.r[0] = rt.r[14];
    rt.recompReturn(rt.r[14]);
}

/// Set animator `+0x20` (`u32`) (`0x08013718`).
pub fn func_08013718() callconv(.c) void {
    if (!abi.enter(0x08013718)) return;
    writeAnim32(0x20, 0x0801373C, 0x08013740);
}

/// Set animator X coordinate `+0x3C` (`u16`) (`0x08013744`).
pub fn func_08013744() callconv(.c) void {
    if (!abi.enter(0x08013744)) return;
    writeAnim16(0x3C, 0x08013768, 0x0801376C, false);
}

/// Set animator Y coordinate `+0x3E` (`u16`) (`0x08013794`).
pub fn func_08013794() callconv(.c) void {
    if (!abi.enter(0x08013794)) return;
    writeAnim16(0x3E, 0x080137B8, 0x080137BC, false);
}

/// Set animator `(x, y)` coordinates `+0x3C/+0x3E` (`0x080137E4`).
pub fn func_080137E4() callconv(.c) void {
    if (!abi.enter(0x080137E4)) return;
    abi.fetches(25);
    const anim_base = abi.read32(0x08013814);
    const proc_base = abi.read32(0x08013818);
    const proc_idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const anim = resolveAnimAddr(proc_base, anim_base, proc_idx);
    abi.write16(anim +% 0x3C, @truncate(rt.r[1]));
    abi.write16(anim +% 0x3E, @truncate(rt.r[2]));
    rt.r[3] = abi.read16(proc_base +% @as(u32, @bitCast(@as(i32, proc_idx) *% 0x60)) +% 0x26);
    rt.r[0] = rt.r[14];
    rt.recompReturn(rt.r[14]);
}

/// Set animator `+0x40` (`u16`) (`0x08013878`).
pub fn func_08013878() callconv(.c) void {
    if (!abi.enter(0x08013878)) return;
    writeAnim16(0x40, 0x0801389C, 0x080138A0, true);
}

/// Set animator `+0x44` (`u32`) (`0x080138CC`).
pub fn func_080138CC() callconv(.c) void {
    if (!abi.enter(0x080138CC)) return;
    writeAnim32(0x44, 0x080138F0, 0x080138F4);
}

/// Set OAM queue entry fields `+0x6, +0x8, +0xA` at `0x0201_1D24[r0 * 16]` (`0x08014CE8`).
pub fn func_08014CE8() callconv(.c) void {
    if (!abi.enter(0x08014CE8)) return;
    abi.fetches(12);
    const entry = mem.oamQueueAddr(@as(usize, @as(u16, @truncate(rt.r[0]))));
    abi.write16(entry +% 0x6, @truncate(rt.r[1]));
    abi.write16(entry +% 0x8, @truncate(rt.r[2]));
    abi.write16(entry +% 0xA, @truncate(rt.r[3]));
    rt.r[0] = rt.r[14];
    rt.recompReturn(rt.r[14]);
}

/// Set OAM queue entry halfwords `+0xC` and `+0xE` at `0x0201_1D24[r0 * 16]` (`0x08014D00`).
pub fn func_08014D00() callconv(.c) void {
    if (!abi.enter(0x08014D00)) return;
    abi.fetches(8);
    const idx: usize = @as(u16, @truncate(rt.r[0]));
    const entry = mem.oamQueueAddr(idx);
    rt.r[3] = types.addr.oam_queue;
    abi.setRegNz(&rt.r[0], rt.r[0] << 4);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[3], true);
    abi.write16(entry +% 0xC, @truncate(rt.r[1]));
    abi.write16(entry +% 0xE, @truncate(rt.r[2]));
    abi.retLr();
}

/// Read halfword at `[r0]` (`0x08014DA0`).
pub fn func_08014DA0() callconv(.c) void {
    if (!abi.enter(0x08014DA0)) return;
    abi.fetches(4);
    rt.r[0] = abi.read16(rt.r[0]);
    abi.retLr();
}

/// Allocate first free OAM queue slot in `0..31` and zero its `+0x6` and `+0xC` halfwords (`0x08014BA8`).
pub fn func_08014BA8() callconv(.c) void {
    if (!abi.enter(0x08014BA8)) return;
    abi.fetches(8);
    var idx: u32 = 0;
    while (idx < types.oam_queue_count) : (idx += 1) {
        abi.fetches(7);
        const flag_addr = types.addr.oam_queue_used +% idx;
        const used = abi.read8(flag_addr);
        rt.cpuSub(null, used, 0, true);
        if (used == 0) {
            abi.fetches(13);
            abi.write8(flag_addr, 1);
            const entry = mem.oamQueueAddr(@intCast(idx));
            abi.write16(entry +% 0x6, 0);
            abi.write16(entry +% 0xC, 0);
            rt.r[1] = rt.r[14];
            rt.r[2] = flag_addr;
            rt.r[3] = entry +% 0x6;
            rt.cpuAdd(&rt.r[0], idx, 0, true);
            abi.retLr();
            return;
        }
        abi.fetches(6);
    }
    abi.fetches(9);
    rt.r[1] = rt.r[14];
    rt.r[2] = types.addr.oam_queue_used +% (types.oam_queue_count - 1);
    rt.r[3] = mem.oamQueueAddr(types.oam_queue_count) +% 0x6;
    abi.setRegNz(&rt.r[0], 1);
    rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
    abi.retLr();
}

/// Clear sprite entry `+0x3A = 0` and reset flag `+0x39 = 0xFE` (`0x08011CF0`).
pub fn func_08011CF0() callconv(.c) void {
    if (!abi.enter(0x08011CF0)) return;
    abi.fetches(10);
    abi.write8(rt.r[0] +% 0x3A, 0);
    abi.write8(rt.r[0] +% 0x39, 0xFE);
    rt.r[2] = rt.r[0] +% 0x3A;
    abi.setRegNz(&rt.r[1], 0xFE);
    rt.r[0] +%= 0x39;
    abi.retLr();
}

/// Write 4 sprite OAM halfwords `(r1, r2, r3, sp[0])` into `0x0201_1924[(r0 << 4) + 3/7/11/15]` (`0x08014B54`).
pub fn func_08014B54() callconv(.c) void {
    if (!abi.enter(0x08014B54)) return;
    abi.fetches(42);
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
    abi.write32(rt.r[13], rt.r[8]);

    const arg3: u16 = @truncate(abi.read32(rt.r[13] +% 0x18));
    const base_slot = rt.r[0] << 4;
    const affine_base: usize = @as(usize, @as(u16, @truncate(rt.r[0]))) * 4;
    const pad_off = @offsetOf(types.OamAttr, "affine_pad");

    abi.write16(mem.oamAttrAddr(affine_base + 0) +% pad_off, @truncate(rt.r[1]));
    abi.write16(mem.oamAttrAddr(affine_base + 1) +% pad_off, @truncate(rt.r[2]));
    const old2 = abi.read16(mem.oamAttrAddr(affine_base + 2) +% pad_off);
    abi.write16(mem.oamAttrAddr(affine_base + 2) +% pad_off, @truncate(rt.r[3]));
    const old3 = abi.read16(mem.oamAttrAddr(affine_base + 3) +% pad_off);
    abi.write16(mem.oamAttrAddr(affine_base + 3) +% pad_off, arg3);

    rt.r[1] = old3;
    rt.r[2] = old2;
    rt.r[8] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[3] = rt.r[8];
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[7] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;

    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.updateNz(((base_slot +% 15) << 1));
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Set animator 24.8 fixed-point offset `(i16(r1) << 8, i16(r2) << 8)` at `+0x14/+0x18` (`0x0801A0EC`).
pub fn func_0801A0EC() callconv(.c) void {
    if (!abi.enter(0x0801A0EC)) return;
    abi.fetches(13);
    const anim_base = types.addr.anim_pool;
    const slot = mem.animSlotAddr(@as(usize, @as(u16, @truncate(rt.r[0]))));
    const fx1: i32 = @as(i32, @as(i16, @bitCast(@as(u16, @truncate(rt.r[1]))))) << 8;
    const fx2: i32 = @as(i32, @as(i16, @bitCast(@as(u16, @truncate(rt.r[2]))))) << 8;
    const val_x: u32 = @bitCast(fx1);
    const val_y: u32 = @bitCast(fx2);
    abi.write32(slot +% 0x14, val_x);
    abi.write32(slot +% 0x18, val_y);
    rt.r[0] = anim_base;
    rt.r[1] = val_x;
    abi.setRegNz(&rt.r[2], val_y);
    rt.r[3] = slot;
    abi.retLr();
}

/// Read animator `+0x2C` word for slot `r0` (`0x0801A1AC`).
pub fn func_0801A1AC() callconv(.c) void {
    if (!abi.enter(0x0801A1AC)) return;
    abi.fetches(8);
    const slot = mem.animSlotAddr(@as(usize, @as(u16, @truncate(rt.r[0]))));
    rt.r[1] = types.addr.anim_pool;
    rt.r[0] = abi.read32(slot +% 0x2C);
    abi.retLr();
}

/// Read and clear animator `+0x2C` word for slot `r0` (`0x0801A1BC`).
pub fn func_0801A1BC() callconv(.c) void {
    if (!abi.enter(0x0801A1BC)) return;
    abi.fetches(10);
    const slot = mem.animSlotAddr(@as(usize, @as(u16, @truncate(rt.r[0]))));
    const prev = abi.read32(slot +% 0x2C);
    abi.write32(slot +% 0x2C, 0);
    rt.r[0] = prev;
    rt.r[1] = slot;
    abi.setRegNz(&rt.r[2], 0);
    abi.retLr();
}

fn allocOamSheetWithOffset(comptime pool_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(11);
    abi.pushLr();
    rt.r[1] = rt.r[0] & 0xFFFF;
    rt.r[0] = abi.read32(pool_ref);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(func_0801256C, ret_addr)) return;
    abi.fetches(4);
    finishPoppedLr(1);
}

fn procSlotAnimHandle(comptime proc_pool_ref: u32, slot_reg: u32) u16 {
    const base = abi.read32(proc_pool_ref);
    const slot_i: u32 = @bitCast(abi.signExtend16(@truncate(slot_reg)));
    return abi.read16(base +% (slot_i * 96) +% 0x26);
}

/// Allocate sprite/OAM queue entry using palette/tile count from `0x08012568` (`0x0801253C`).
pub fn func_0801253C() callconv(.c) void {
    if (!abi.enter(0x0801253C)) return;
    abi.fetches(19);
    abi.pushLr();
    rt.r[13] -%= 4;

    const tbl = abi.read32(0x08012568);
    const v0 = abi.read16(tbl) << 1;
    const v1 = abi.read16(tbl +% (0x81 << 3));
    rt.r[1] = (v1 +% v0) & 0xFFFF;
    abi.write32(rt.r[13], 0);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(low_peel_1.func_080124F8, 0x0801255F)) return;

    abi.fetches(7);
    abi.setRegNz(&rt.r[0], rt.r[0] & 0xFFFF);
    rt.r[13] +%= 4;
    finishPoppedLr(1);
}

/// Bind/load sprite descriptor `0x080127AC` at offset `u16(r0)` (`0x08012794`).
pub fn func_08012794() callconv(.c) void {
    if (!abi.enter(0x08012794)) return;
    allocOamSheetWithOffset(0x080127AC, 0x080127A7);
}

/// Bind/load sprite descriptor `0x08012A2C` at offset `u16(r0)` (`0x08012A14`).
pub fn func_08012A14() callconv(.c) void {
    if (!abi.enter(0x08012A14)) return;
    allocOamSheetWithOffset(0x08012A2C, 0x08012A27);
}

/// Bind/load sprite descriptor `0x08012A48` at offset `u16(r0)` (`0x08012A30`).
pub fn func_08012A30() callconv(.c) void {
    if (!abi.enter(0x08012A30)) return;
    allocOamSheetWithOffset(0x08012A48, 0x08012A43);
}

/// Bind/load sprite descriptor `0x08012A64` at offset `u16(r0)` (`0x08012A4C`).
pub fn func_08012A4C() callconv(.c) void {
    if (!abi.enter(0x08012A4C)) return;
    allocOamSheetWithOffset(0x08012A64, 0x08012A5F);
}

/// Release/clear signed animator handle `i16(r0)` via `0x08019FD8` (`0x080134F8`).
pub fn func_080134F8() callconv(.c) void {
    if (!abi.enter(0x080134F8)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    if (!abi.call(low_peel_6.func_08019FD8, 0x08013503)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn any free animator (`0xFF`) with `(r0, r1, u8(r2))` via `0x08013508` (`0x08013530`).
pub fn func_08013530() callconv(.c) void {
    if (!abi.enter(0x08013530)) return;
    abi.fetches(12);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[5] = rt.r[1];
    rt.r[3] = rt.r[2] & 0xFF;
    abi.setRegNz(&rt.r[0], 0xFF);
    rt.r[1] = rt.r[4];
    rt.r[2] = rt.r[5];
    if (!abi.call(low_peel_3.func_08013508, 0x08013545)) return;

    abi.fetches(7);
    abi.setRegNz(&rt.r[0], @bitCast(abi.signExtend8(@truncate(rt.r[0]))));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    finishPoppedLr(1);
}

/// Set animator position `(i16(r1), i16(r2))` for proc slot `i16(r0)->+0x26` (`0x08013550`).
pub fn func_08013550() callconv(.c) void {
    if (!abi.enter(0x08013550)) return;
    abi.fetches(17);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[0] = procSlotAnimHandle(0x08013574, rt.r[0]);
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(rt.r[1])));
    rt.r[2] = @bitCast(abi.signExtend16(@truncate(rt.r[2])));
    if (!abi.call(func_0801A0EC, 0x0801356F)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Step animator for proc slot `i16(r0)->+0x26` via `0x0801A15C` (`0x08013578`).
pub fn func_08013578() callconv(.c) void {
    if (!abi.enter(0x08013578)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[0] = procSlotAnimHandle(0x08013594, rt.r[0]);
    if (!abi.call(low_peel_3.func_0801A15C, 0x0801358F)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Query signed animator state for proc slot `i16(r0)->+0x26` via `0x0801A1AC` (`0x08013630`).
pub fn func_08013630() callconv(.c) void {
    if (!abi.enter(0x08013630)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[0] = procSlotAnimHandle(0x08013650, rt.r[0]);
    if (!abi.call(func_0801A1AC, 0x08013647)) return;
    abi.fetches(6);
    abi.setRegNz(&rt.r[0], @bitCast(abi.signExtend16(@truncate(rt.r[0]))));
    finishPoppedLr(1);
}

/// Query and consume signed animator state for proc slot `i16(r0)->+0x26` via `0x0801A1BC` (`0x08013654`).
pub fn func_08013654() callconv(.c) void {
    if (!abi.enter(0x08013654)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[0] = procSlotAnimHandle(0x08013674, rt.r[0]);
    if (!abi.call(func_0801A1BC, 0x0801366B)) return;
    abi.fetches(6);
    abi.setRegNz(&rt.r[0], @bitCast(abi.signExtend16(@truncate(rt.r[0]))));
    finishPoppedLr(1);
}

/// Clear all `0x80` OAM slots via `0x08014B14` and zero counter `0x08014B50` (`0x08014B3C`).
pub fn func_08014B3C() callconv(.c) void {
    if (!abi.enter(0x08014B3C)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    abi.setRegNz(&rt.r[1], 0x80);
    if (!abi.call(clusters_low.func_08014B14, 0x08014B47)) return;
    abi.fetches(7);
    const dst = abi.read32(0x08014B50);
    rt.r[1] = dst;
    abi.write16(dst, 0);
    abi.popReturn();
}

/// Set `(x=r1, y=r2, attr=r3)` on 16-byte sprite entry `r0` and refresh via `0x08014BF8` (`0x08014C98`).
pub fn func_08014C98() callconv(.c) void {
    if (!abi.enter(0x08014C98)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[5] = abi.read32(0x08014CB0);
    rt.r[4] = (rt.r[0] << 4) +% rt.r[5];
    abi.write16(rt.r[4], @truncate(rt.r[1]));
    abi.write16(rt.r[4] +% 2, @truncate(rt.r[2]));
    abi.write16(rt.r[4] +% 4, @truncate(rt.r[3]));
    if (!abi.call(clusters_low.func_08014BF8, 0x08014CAB)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Set `(x=r1, y=r2)` on 16-byte sprite entry `r0` and refresh via `0x08014BF8` (`0x08014CB4`).
pub fn func_08014CB4() callconv(.c) void {
    if (!abi.enter(0x08014CB4)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = abi.read32(0x08014CCC);
    const entry = (rt.r[0] << 4) +% rt.r[4];
    abi.write16(entry, @truncate(rt.r[1]));
    abi.write16(entry +% 2, @truncate(rt.r[2]));
    if (!abi.call(clusters_low.func_08014BF8, 0x08014CC5)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Set `attr=r1` on 16-byte sprite entry `r0` and refresh via `0x08014BF8` (`0x08014CD0`).
pub fn func_08014CD0() callconv(.c) void {
    if (!abi.enter(0x08014CD0)) return;
    abi.fetches(9);
    abi.pushLr();
    const entry = (rt.r[0] << 4) +% abi.read32(0x08014CE4);
    abi.write16(entry +% 4, @truncate(rt.r[1]));
    if (!abi.call(clusters_low.func_08014BF8, 0x08014CDF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Push default blend/depth args `(0, 0, -1)` and invoke `0x08014DA4` (`0x0801539C`).
pub fn func_0801539C() callconv(.c) void {
    if (!abi.enter(0x0801539C)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 0xC;

    abi.write32(rt.r[13], 0);
    abi.write32(rt.r[13] +% 4, 0);
    abi.write32(rt.r[13] +% 8, @bitCast(@as(i32, -1)));
    if (!abi.call(low_peel_6.func_08014DA4, 0x080153B3)) return;

    abi.fetches(6);
    rt.r[13] +%= 0xC;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    finishPoppedLr(1);
}

/// Cache active animator's word `+0x44` to `0x08015408` and dispatch `0x0807B454` (`0x080153D4`).
pub fn func_080153D4() callconv(.c) void {
    if (!abi.enter(0x080153D4)) return;
    abi.fetches(25);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[5] = abi.read32(0x08015408);
    const anim_base = abi.read32(0x0801540C);
    const proc_base = abi.read32(0x08015410);
    rt.r[4] = abi.read32(0x08015414);
    const proc_slot: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[4])));
    const anim_slot = abi.read16(proc_base +% (proc_slot * 96) +% 0x26);
    const word_addr = anim_base +% 0x44 +% (@as(u32, anim_slot) * 0x4C);
    abi.write32(rt.r[5], abi.read32(word_addr));
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(rt.r[4])));
    rt.r[1] = abi.read32(0x08015418);
    if (!abi.call(tail_low.func_0807B454, 0x08015403)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Forward sprite queue call to `0x080157E4` with stack args `(0, i16(r3))` (`0x0801585C`).
pub fn func_0801585C() callconv(.c) void {
    if (!abi.enter(0x0801585C)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 8;
    abi.write32(rt.r[13] +% 4, @bitCast(abi.signExtend16(@truncate(rt.r[3]))));
    abi.write32(rt.r[13], 0);
    if (!abi.call(low_peel_1.func_080157E4, 0x0801586F)) return;
    abi.fetches(5);
    rt.r[13] +%= 8;
    finishPoppedLr(1);
}

/// Reset full `0x80`-entry OAM table, set limit `0x10` and zero count (`0x080159CC`).
pub fn func_080159CC() callconv(.c) void {
    if (!abi.enter(0x080159CC)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    abi.setRegNz(&rt.r[1], 0x80);
    if (!abi.call(clusters_low.func_08014B14, 0x080159D7)) return;
    abi.fetches(10);
    abi.write16(abi.read32(0x080159E8), 0x10);
    const cnt_addr = abi.read32(0x080159EC);
    rt.r[1] = cnt_addr;
    abi.write16(cnt_addr, 0);
    abi.popReturn();
}

/// Reset upper `0x70` OAM slots `(0x10..0x80)` and set limit `0x10` (`0x080159F0`).
pub fn func_080159F0() callconv(.c) void {
    if (!abi.enter(0x080159F0)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0x10);
    abi.setRegNz(&rt.r[1], 0x70);
    if (!abi.call(clusters_low.func_08014B14, 0x080159FB)) return;
    abi.fetches(7);
    const lim_addr = abi.read32(0x08015A04);
    rt.r[1] = lim_addr;
    abi.write16(lim_addr, 0x10);
    abi.popReturn();
}

/// Upload `1024`-byte OAM buffer `0x08015A34` to GBA hardware OAM `0x0700_0000` (`0x08015A20`).
pub fn func_08015A20() callconv(.c) void {
    if (!abi.enter(0x08015A20)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08015A34);
    abi.setRegNz(&rt.r[1], 0x0700_0000);
    abi.setRegNz(&rt.r[2], 0x400);
    if (!abi.call(dma.func_0800FDCC, 0x08015A31)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Position animator `r0` relative to `0x60`-strided descriptor `[0x08049588]` and camera `[0x08049590]` via `0x08013550` (`0x08049554`).
pub fn func_08049554() callconv(.c) void {
    if (!abi.enter(0x08049554)) return;
    abi.fetches(25);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    abi.setRegNz(&rt.r[1], 0);
    const idx: u32 = @bitCast(abi.signExtend16(abi.read16(abi.read32(0x08049588))));
    const entry = (((idx << 1) +% idx) << 5) +% abi.read32(0x0804958C);
    const cam = abi.read32(abi.read32(0x08049590));
    rt.r[4] = abi.read16(entry +% 0x1E);
    rt.r[5] = abi.read16(cam +% 0x1A);
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(rt.r[4] +% rt.r[5])));
    rt.r[2] = @bitCast(abi.signExtend16(@truncate(abi.read16(entry +% 0x20) +% abi.read16(cam +% 0x1E))));
    rt.r[3] = abi.read16(cam +% 0x1E);
    if (!abi.call(func_08013550, 0x08049583)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn callWin1256CStep(
    comptime p0_ref: u32,
    comptime a2: u32,
    comptime a3: u32,
    comptime ret_addr: u32,
    ptr_val: ?u32,
) bool {
    rt.r[0] = ptr_val orelse abi.read32(p0_ref);
    abi.setRegNz(&rt.r[2], a2);
    abi.setRegNz(&rt.r[3], a3);
    return abi.call(func_0801256C, ret_addr);
}

fn runWin1256CChain2(
    comptime p0_ref: u32,
    comptime r0_addr: u32,
    comptime p1_ref: u32,
    comptime r1_addr: u32,
) void {
    abi.fetches(11);
    abi.pushLr();
    rt.r[1] = rt.r[0] & 0xFFFF;
    if (!callWin1256CStep(p0_ref, 0, 0, r0_addr, null)) return;

    abi.fetches(8);
    rt.r[1] = rt.r[0];
    if (!callWin1256CStep(p1_ref, 0, 0, r1_addr, null)) return;

    abi.fetches(6);
    rt.r[1] = rt.r[0];
    finishPoppedLr(1);
}

fn runWin1256CChain3(
    comptime p0_ref: u32,
    comptime r0_addr: u32,
    comptime p1_ref: u32,
    comptime a2_1: u32,
    comptime a3_1: u32,
    comptime r1_addr: u32,
    comptime p2_ref: u32,
    comptime a2_2: u32,
    comptime a3_2: u32,
    comptime r2_addr: u32,
    comptime reuse_p1_r4: bool,
) void {
    abi.fetches(11);
    abi.pushLr();
    if (reuse_p1_r4) {
        rt.r[13] -%= 4;
        abi.write32(rt.r[13], rt.r[4]);
    }
    rt.r[1] = rt.r[0] & 0xFFFF;
    if (!callWin1256CStep(p0_ref, 0, 0, r0_addr, null)) return;

    abi.fetches(if (reuse_p1_r4) 9 else 8);
    rt.r[1] = rt.r[0];
    const p1_cached = if (reuse_p1_r4) abi.read32(p1_ref) else 0;
    if (reuse_p1_r4) rt.r[4] = p1_cached;
    if (!callWin1256CStep(p1_ref, a2_1, a3_1, r1_addr, if (reuse_p1_r4) p1_cached else null)) return;

    abi.fetches(8);
    rt.r[1] = rt.r[0];
    if (!callWin1256CStep(p2_ref, a2_2, a3_2, r2_addr, if (reuse_p1_r4) rt.r[4] else null)) return;

    abi.fetches(if (reuse_p1_r4) 7 else 6);
    rt.r[1] = rt.r[0];
    if (reuse_p1_r4) {
        rt.r[4] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
    }
    finishPoppedLr(1);
}

fn updateAnimByteFlag(comptime use_arg_bit: bool, comptime bit_shift: u5, comptime mask_or: u8, comptime clear_only: bool, comptime ret_1: u32, comptime ret_2: u32) void {
    abi.fetches(if (use_arg_bit) 15 else 12);
    abi.pushLr();
    rt.r[13] -%= 4;
    if (use_arg_bit) {
        abi.write32(rt.r[13], rt.r[6]);
        rt.r[13] -%= 4;
    }
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const slot = rt.r[0];
    const bit_val: u8 = @truncate(rt.r[1] & 1);
    const anim_idx: u32 = @bitCast(abi.signExtend16(@truncate(slot)));
    if (use_arg_bit) {
        rt.r[4] = rt.r[1] & 0xFF;
        rt.r[5] = anim_idx;
        rt.r[6] = rt.r[13];
    } else {
        rt.r[4] = anim_idx;
        rt.r[5] = rt.r[13];
    }
    rt.r[0] = anim_idx;
    rt.r[1] = rt.r[13];
    if (!abi.call(func_080135FC, ret_1)) return;

    abi.fetches(if (use_arg_bit) 16 else if (clear_only) 12 else 11);
    const sp_base = rt.r[13];
    const old_b1 = abi.read8(sp_base +% 1);
    const new_b1: u8 = if (use_arg_bit)
        (old_b1 & ~mask_or) | (bit_val << bit_shift)
    else if (clear_only)
        old_b1 & ~mask_or
    else
        old_b1 | mask_or;
    abi.write8(sp_base +% 1, new_b1);
    rt.r[0] = anim_idx;
    rt.r[1] = abi.read32(sp_base);
    rt.r[2] = abi.read32(sp_base +% 4);
    if (!abi.call(func_08013598, ret_2)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    if (use_arg_bit) {
        rt.r[6] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
    }
    abi.popReturn();
}

/// Initialize a `0x40`-byte window/sprite descriptor (`r0`) from `(r1..r3, stack args)` (`0x0801241C`).
pub fn func_0801241C() callconv(.c) void {
    if (!abi.enter(0x0801241C)) return;
    abi.fetches(49);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const obj = rt.r[0];
    rt.r[12] = obj;
    const arg4 = abi.read32(rt.r[13] +% 0x10);
    const arg5 = abi.read32(rt.r[13] +% 0x14);
    const arg6 = abi.read32(rt.r[13] +% 0x18) & 0xFFFF;
    const w = rt.r[1] & 0xFFFF;
    const h = rt.r[2] & 0xFFFF;
    rt.r[6] = obj;
    abi.write32(obj +% 0x20, arg4);
    abi.write32(obj +% 0x24, 0);
    abi.write32(obj +% 0x28, rt.r[3]);
    abi.write16(obj +% 0x2C, @truncate(arg5));
    abi.write16(obj +% 0x2E, 0);
    abi.write16(obj +% 0x36, @truncate(arg6));
    abi.write16(obj +% 0x34, @truncate(arg6));
    abi.write8(obj +% 0x38, 0);
    abi.write8(obj +% 0x30, @truncate(w));
    abi.write8(obj +% 0x31, @truncate(h));
    abi.write8(obj +% 0x32, @truncate(w));
    abi.write8(obj +% 0x33, @truncate(h));
    abi.write8(obj +% 0x39, 0xFF);
    abi.write8(obj +% 0x3A, 2);
    abi.write32(obj +% 0x3C, abi.read32(0x0801247C));
    abi.setRegNz(&rt.r[0], obj +% 0x40);
    abi.write8(rt.r[0], 0);
    abi.setRegNz(&rt.r[3], 0);
    abi.setRegNz(&rt.r[4], 0);
    abi.setRegNz(&rt.r[5], arg5);
    rt.r[1] = obj +% 0x3A;
    rt.r[2] = h;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// End all 3 UI/window proc pools `0x080124EC..0x080124F4` (`0x080124D4`).
pub fn func_080124D4() callconv(.c) void {
    if (!abi.enter(0x080124D4)) return;
    abi.fetches(6);
    abi.pushLr();
    inline for ([_]struct { ref: u32, ret: u32 }{
        .{ .ref = 0x080124EC, .ret = 0x080124DD },
        .{ .ref = 0x080124F0, .ret = 0x080124E3 },
        .{ .ref = 0x080124F4, .ret = 0x080124E9 },
    }) |step| {
        if (step.ref != 0x080124EC) abi.fetches(5);
        rt.r[0] = abi.read32(step.ref);
        if (!abi.call(low_peel_6.func_0801329C, step.ret)) return;
    }
    abi.fetches(4);
    abi.popReturn();
}

/// Look up glyph/window table word `[0x08012538][r1]` and invoke `0x080124F8` (`0x080124FC`).
pub fn func_080124FC() callconv(.c) void {
    if (!abi.enter(0x080124FC)) return;
    abi.fetches(26);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    const tbl = abi.read32(0x08012538);
    const key = rt.r[1] & 0xFF;
    const len = abi.read16(tbl +% (key << 1)) << 1;
    const off = abi.read16(tbl +% (0x81 << 3) +% (key << 1));
    rt.r[5] = tbl;
    rt.r[6] = 0x81 << 3;
    rt.r[1] = (off +% len) & 0xFFFF;
    rt.r[2] &= 0xFF;
    rt.r[3] = key;
    abi.setRegNz(&rt.r[4], 0);
    abi.write32(rt.r[13], 0);
    if (!abi.call(low_peel_1.func_080124F8, 0x0801252D)) return;

    abi.fetches(8);
    rt.r[0] &= 0xFFFF;
    rt.updateNz(rt.r[0]);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    finishPoppedLr(1);
}

/// 3-segment tile/window setup chain starting at `0x08012650` (`0x0801261C`).
pub fn func_0801261C() callconv(.c) void {
    if (!abi.enter(0x0801261C)) return;
    runWin1256CChain3(0x08012650, 0x0801262F, 0x08012654, 1, 1, 0x0801263B, 0x08012658, 0, 0, 0x08012647, false);
}

/// 3-segment tile/window setup chain starting at `0x08012694` (`0x0801265C`).
pub fn func_0801265C() callconv(.c) void {
    if (!abi.enter(0x0801265C)) return;
    runWin1256CChain3(0x08012694, 0x0801266F, 0x08012698, 1, 1, 0x0801267D, 0, 0, 0, 0x08012689, true);
}

/// 2-segment tile/window setup chain (`0x080126C4 -> 0x080126C8`) (`0x0801269C`).
pub fn func_0801269C() callconv(.c) void {
    if (!abi.enter(0x0801269C)) return;
    runWin1256CChain2(0x080126C4, 0x080126AF, 0x080126C8, 0x080126BB);
}

/// 2-segment tile/window setup chain (`0x080126F4 -> 0x080126F8`) (`0x080126CC`).
pub fn func_080126CC() callconv(.c) void {
    if (!abi.enter(0x080126CC)) return;
    runWin1256CChain2(0x080126F4, 0x080126DF, 0x080126F8, 0x080126EB);
}

/// 2-segment tile/window setup chain (`0x08012724 -> 0x08012728`) (`0x080126FC`).
pub fn func_080126FC() callconv(.c) void {
    if (!abi.enter(0x080126FC)) return;
    runWin1256CChain2(0x08012724, 0x0801270F, 0x08012728, 0x0801271B);
}

/// 3-segment tile/window setup chain starting at `0x080127E4` (`0x080127B0`).
pub fn func_080127B0() callconv(.c) void {
    if (!abi.enter(0x080127B0)) return;
    runWin1256CChain3(0x080127E4, 0x080127C3, 0x080127E8, 1, 1, 0x080127CF, 0x080127EC, 0, 0, 0x080127DB, false);
}

/// 3-segment tile/window setup chain starting at `0x08012824` (`0x080127F0`).
pub fn func_080127F0() callconv(.c) void {
    if (!abi.enter(0x080127F0)) return;
    runWin1256CChain3(0x08012824, 0x08012803, 0x08012828, 1, 1, 0x0801280F, 0x0801282C, 0, 0, 0x0801281B, false);
}

/// 3-segment tile/window setup chain starting at `0x08012868` (`0x08012834`).
pub fn func_08012834() callconv(.c) void {
    if (!abi.enter(0x08012834)) return;
    runWin1256CChain3(0x08012868, 0x08012847, 0x0801286C, 1, 1, 0x08012853, 0x08012870, 0, 0, 0x0801285F, false);
}

/// 3-segment tile/window setup chain starting at `0x080128A8` (`0x08012874`).
pub fn func_08012874() callconv(.c) void {
    if (!abi.enter(0x08012874)) return;
    runWin1256CChain3(0x080128A8, 0x08012887, 0x080128AC, 0, 0, 0x08012893, 0x080128B0, 1, 1, 0x0801289F, false);
}

/// 2-segment tile/window setup chain (`0x080128DC -> 0x080128E0`) (`0x080128B4`).
pub fn func_080128B4() callconv(.c) void {
    if (!abi.enter(0x080128B4)) return;
    runWin1256CChain2(0x080128DC, 0x080128C7, 0x080128E0, 0x080128D3);
}

/// 2-segment tile/window setup chain (`0x0801290C -> 0x08012910`) (`0x080128E4`).
pub fn func_080128E4() callconv(.c) void {
    if (!abi.enter(0x080128E4)) return;
    runWin1256CChain2(0x0801290C, 0x080128F7, 0x08012910, 0x08012903);
}

/// 2-segment tile/window setup chain (`0x0801293C -> 0x08012940`) (`0x08012914`).
pub fn func_08012914() callconv(.c) void {
    if (!abi.enter(0x08012914)) return;
    runWin1256CChain2(0x0801293C, 0x08012927, 0x08012940, 0x08012933);
}

/// 2-segment tile/window setup chain (`0x0801296C -> 0x08012970`) (`0x08012944`).
pub fn func_08012944() callconv(.c) void {
    if (!abi.enter(0x08012944)) return;
    runWin1256CChain2(0x0801296C, 0x08012957, 0x08012970, 0x08012963);
}

/// 2-segment tile/window setup chain (`0x0801299C -> 0x080129A0`) (`0x08012974`).
pub fn func_08012974() callconv(.c) void {
    if (!abi.enter(0x08012974)) return;
    runWin1256CChain2(0x0801299C, 0x08012987, 0x080129A0, 0x08012993);
}

/// 3-segment tile/window setup chain starting at `0x080129DC` (`0x080129A4`).
pub fn func_080129A4() callconv(.c) void {
    if (!abi.enter(0x080129A4)) return;
    runWin1256CChain3(0x080129DC, 0x080129B7, 0x080129E0, 1, 1, 0x080129C5, 0, 0, 0, 0x080129D1, true);
}

/// 2-segment tile/window setup chain (`0x08012A0C -> 0x08012A10`) (`0x080129E4`).
pub fn func_080129E4() callconv(.c) void {
    if (!abi.enter(0x080129E4)) return;
    runWin1256CChain2(0x08012A0C, 0x080129F7, 0x08012A10, 0x08012A03);
}

/// Set animator horizontal-flip bit (`0x10` in OAM byte `+1`) from `r1 & 1` (`0x08013454`).
pub fn func_08013454() callconv(.c) void {
    if (!abi.enter(0x08013454)) return;
    updateAnimByteFlag(true, 4, 0x10, false, 0x0801346F, 0x0801348B);
}

/// Set animator vertical-flip bit (`0x20` in OAM byte `+1`) from `r1 & 1` (`0x08013494`).
pub fn func_08013494() callconv(.c) void {
    if (!abi.enter(0x08013494)) return;
    updateAnimByteFlag(true, 5, 0x20, false, 0x080134AF, 0x080134CB);
}

/// Hide animator OAM (`byte[+1] |= 0x02`) (`0x080148DC`).
pub fn func_080148DC() callconv(.c) void {
    if (!abi.enter(0x080148DC)) return;
    updateAnimByteFlag(false, 0, 0x02, false, 0x080148F1, 0x08014903);
}

/// Unhide animator OAM (`byte[+1] &= ~0x02`) (`0x0801490C`).
pub fn func_0801490C() callconv(.c) void {
    if (!abi.enter(0x0801490C)) return;
    updateAnimByteFlag(false, 0, 0x02, true, 0x08014921, 0x08014935);
}

/// Clear `func_08014DA0(r1)` OAM slots starting at index `r0` via `0x08014B14` (`0x080153BC`).
pub fn func_080153BC() callconv(.c) void {
    if (!abi.enter(0x080153BC)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[0] = rt.r[1];
    if (!abi.call(func_08014DA0, 0x080153C7)) return;

    abi.fetches(6);
    rt.r[1] = rt.r[0];
    rt.r[0] = rt.r[4];
    if (!abi.call(clusters_low.func_08014B14, 0x080153CF)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn spawnAnimOverlayWindow(
    comptime work_ptr_ref: u32,
    comptime flag_ref: u32,
    comptime proc_ref: u32,
    comptime ret1: u32,
    comptime ret2: u32,
    comptime ret3: u32,
) void {
    abi.fetches(34);
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
    rt.r[13] -%= 0xC;

    const x: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    const y: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[1])));
    const style = rt.r[2];
    const a3 = rt.r[3];
    const s0 = abi.read32(rt.r[13] +% 0x24) & 0xFFFF;
    const s1 = abi.read32(rt.r[13] +% 0x28) & 0xFFFF;
    const work = abi.read32(work_ptr_ref);
    abi.write8(abi.read32(flag_ref), 0);
    abi.write32(rt.r[13], a3);
    abi.write32(rt.r[13] +% 4, s0);
    abi.write32(rt.r[13] +% 8, s1);

    rt.r[8] = work;
    rt.r[9] = style;
    rt.r[0] = work;
    rt.r[1] = x;
    rt.r[2] = y;
    rt.r[3] = style;
    if (!abi.call(func_0801241C, ret1)) return;

    abi.fetches(5);
    rt.r[0] = work;
    if (!abi.call(func_08011CF0, ret2)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(proc_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(low_peel_6.func_0801320C, ret3)) return;

    abi.fetches(9);
    rt.r[13] +%= 0xC;
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
    finishPoppedLr(1);
}

fn commitAnimSlotTileWindow(comptime base_ref: u32, stack_mode: u32, comptime ret_addr: u32) void {
    abi.fetches(34);
    abi.pushLr();
    const saved_r9 = rt.r[9];
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    if (stack_mode == 0) {
        rt.r[13] -%= 4;
        abi.write32(rt.r[13], saved_r9);
    }
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 4;

    const a1 = rt.r[1] & 0xFFFF;
    const a2 = rt.r[2] & 0xFFFF;
    const a3 = rt.r[3] & 0xFFFF;
    const base = abi.read32(base_ref);
    abi.write16(base +% (a3 << 1), 0);
    abi.write32(base +% 0x400 +% (a3 << 2), rt.r[0]);
    abi.write16(base +% 0x408 +% (a3 << 1), @truncate(a1));
    abi.write32(rt.r[13], stack_mode);
    rt.r[1] = a1;
    rt.r[2] = a2;
    rt.r[3] = a3;
    if (!abi.call(low_peel_1.func_080124F8, ret_addr)) return;

    abi.fetches(if (stack_mode == 0) 11 else 10);
    rt.r[0] &= 0xFFFF;
    rt.updateNz(rt.r[0]);
    rt.r[13] +%= 4;
    rt.r[3] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = rt.r[3];
    if (stack_mode == 0) {
        rt.r[9] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
    }
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[7] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    finishPoppedLr(1);
}

/// Spawn overlay window `0x0801241C` / `0x08011CF0` at `[0x08012334]` and activate proc `[0x0801233C]` (`0x080122D8`).
pub fn func_080122D8() callconv(.c) void {
    if (!abi.enter(0x080122D8)) return;
    spawnAnimOverlayWindow(0x08012334, 0x08012338, 0x0801233C, 0x08012319, 0x0801231F, 0x08012327);
}

/// Spawn overlay window `0x0801241C` / `0x08011CF0` at `[0x0801239C]` and activate proc `[0x080123A4]` (`0x08012340`).
pub fn func_08012340() callconv(.c) void {
    if (!abi.enter(0x08012340)) return;
    spawnAnimOverlayWindow(0x0801239C, 0x080123A0, 0x080123A4, 0x08012381, 0x08012387, 0x0801238F);
}

/// Allocate overlay proc `[0x08012418]`, clear `[0x08012414]`, setup `0x0801241C`, and return proc pointer (`0x080123A8`).
pub fn func_080123A8() callconv(.c) void {
    if (!abi.enter(0x080123A8)) return;
    abi.fetches(30);
    abi.pushLr();
    const saved_r10 = rt.r[10];
    const saved_r9 = rt.r[9];
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r10);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 0x10;

    const ax = rt.r[0] & 0xFFFF;
    const ay = rt.r[1] & 0xFFFF;
    const a2 = rt.r[2];
    const a3 = rt.r[3];
    const s0 = abi.read32(rt.r[13] +% 0x2C) & 0xFFFF;
    const s1 = abi.read32(rt.r[13] +% 0x30) & 0xFFFF;
    abi.write8(abi.read32(0x08012414), 0);
    abi.write32(rt.r[13] +% 0xC, s1);
    rt.r[0] = abi.read32(0x08012418);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(low_peel_6.func_0801320C, 0x080123E1)) return;

    abi.fetches(18);
    const proc_ptr = rt.r[0];
    rt.r[8] = proc_ptr;
    abi.write32(rt.r[13], a3);
    abi.write32(rt.r[13] +% 4, s0);
    abi.write32(rt.r[13] +% 8, s1);
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(ax)));
    rt.r[2] = @bitCast(abi.signExtend16(@truncate(ay)));
    rt.r[3] = a2;
    if (!abi.call(func_0801241C, 0x08012401)) return;

    abi.fetches(11);
    rt.r[0] = proc_ptr;
    rt.r[13] +%= 0x10;
    rt.r[8] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[9] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[10] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    finishPoppedLr(1);
}

/// Register primary window slot `u16(r3)` in `[0x080125C4]` via `0x080124F8(..., 0)` (`0x0801256C`).
pub fn func_0801256C() callconv(.c) void {
    if (!abi.enter(0x0801256C)) return;
    commitAnimSlotTileWindow(0x080125C4, 0, 0x080125B3);
}

/// Register secondary window slot `u16(r3)` in `[0x08012618]` via `0x080124F8(..., 1)` (`0x080125C8`).
pub fn func_080125C8() callconv(.c) void {
    if (!abi.enter(0x080125C8)) return;
    commitAnimSlotTileWindow(0x08012618, 1, 0x08012609);
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08011CF0, .{ .name = "func_08011CF0", .linkage = .strong });
        @export(&func_0801241C, .{ .name = "func_0801241C", .linkage = .strong });
        @export(&func_080124D4, .{ .name = "func_080124D4", .linkage = .strong });
        @export(&func_080124FC, .{ .name = "func_080124FC", .linkage = .strong });
        @export(&func_0801261C, .{ .name = "func_0801261C", .linkage = .strong });
        @export(&func_0801265C, .{ .name = "func_0801265C", .linkage = .strong });
        @export(&func_0801269C, .{ .name = "func_0801269C", .linkage = .strong });
        @export(&func_080126CC, .{ .name = "func_080126CC", .linkage = .strong });
        @export(&func_080126FC, .{ .name = "func_080126FC", .linkage = .strong });
        @export(&func_080127B0, .{ .name = "func_080127B0", .linkage = .strong });
        @export(&func_080127F0, .{ .name = "func_080127F0", .linkage = .strong });
        @export(&func_08012834, .{ .name = "func_08012834", .linkage = .strong });
        @export(&func_08012874, .{ .name = "func_08012874", .linkage = .strong });
        @export(&func_080128B4, .{ .name = "func_080128B4", .linkage = .strong });
        @export(&func_080128E4, .{ .name = "func_080128E4", .linkage = .strong });
        @export(&func_08012914, .{ .name = "func_08012914", .linkage = .strong });
        @export(&func_08012944, .{ .name = "func_08012944", .linkage = .strong });
        @export(&func_08012974, .{ .name = "func_08012974", .linkage = .strong });
        @export(&func_080129A4, .{ .name = "func_080129A4", .linkage = .strong });
        @export(&func_080129E4, .{ .name = "func_080129E4", .linkage = .strong });
        @export(&func_08013454, .{ .name = "func_08013454", .linkage = .strong });
        @export(&func_08013494, .{ .name = "func_08013494", .linkage = .strong });
        @export(&func_080148DC, .{ .name = "func_080148DC", .linkage = .strong });
        @export(&func_0801490C, .{ .name = "func_0801490C", .linkage = .strong });
        @export(&func_080153BC, .{ .name = "func_080153BC", .linkage = .strong });
        @export(&func_08049554, .{ .name = "func_08049554", .linkage = .strong });
        @export(&func_0801253C, .{ .name = "func_0801253C", .linkage = .strong });
        @export(&func_08012794, .{ .name = "func_08012794", .linkage = .strong });
        @export(&func_08012A14, .{ .name = "func_08012A14", .linkage = .strong });
        @export(&func_08012A30, .{ .name = "func_08012A30", .linkage = .strong });
        @export(&func_08012A4C, .{ .name = "func_08012A4C", .linkage = .strong });
        @export(&func_080134F8, .{ .name = "func_080134F8", .linkage = .strong });
        @export(&func_08013530, .{ .name = "func_08013530", .linkage = .strong });
        @export(&func_08013550, .{ .name = "func_08013550", .linkage = .strong });
        @export(&func_08013578, .{ .name = "func_08013578", .linkage = .strong });
        @export(&func_08013598, .{ .name = "func_08013598", .linkage = .strong });
        @export(&func_08013630, .{ .name = "func_08013630", .linkage = .strong });
        @export(&func_08013654, .{ .name = "func_08013654", .linkage = .strong });
        @export(&func_08014B3C, .{ .name = "func_08014B3C", .linkage = .strong });
        @export(&func_08014C98, .{ .name = "func_08014C98", .linkage = .strong });
        @export(&func_08014CB4, .{ .name = "func_08014CB4", .linkage = .strong });
        @export(&func_08014CD0, .{ .name = "func_08014CD0", .linkage = .strong });
        @export(&func_0801539C, .{ .name = "func_0801539C", .linkage = .strong });
        @export(&func_080153D4, .{ .name = "func_080153D4", .linkage = .strong });
        @export(&func_0801585C, .{ .name = "func_0801585C", .linkage = .strong });
        @export(&func_080159CC, .{ .name = "func_080159CC", .linkage = .strong });
        @export(&func_080159F0, .{ .name = "func_080159F0", .linkage = .strong });
        @export(&func_08015A20, .{ .name = "func_08015A20", .linkage = .strong });
        @export(&func_080135C8, .{ .name = "func_080135C8", .linkage = .strong });
        @export(&func_080135FC, .{ .name = "func_080135FC", .linkage = .strong });
        @export(&func_08013678, .{ .name = "func_08013678", .linkage = .strong });
        @export(&func_080136D8, .{ .name = "func_080136D8", .linkage = .strong });
        @export(&func_08013718, .{ .name = "func_08013718", .linkage = .strong });
        @export(&func_08013744, .{ .name = "func_08013744", .linkage = .strong });
        @export(&func_08013794, .{ .name = "func_08013794", .linkage = .strong });
        @export(&func_080137E4, .{ .name = "func_080137E4", .linkage = .strong });
        @export(&func_08013878, .{ .name = "func_08013878", .linkage = .strong });
        @export(&func_080138CC, .{ .name = "func_080138CC", .linkage = .strong });
        @export(&func_08014B54, .{ .name = "func_08014B54", .linkage = .strong });
        @export(&func_08014BA8, .{ .name = "func_08014BA8", .linkage = .strong });
        @export(&func_08014CE8, .{ .name = "func_08014CE8", .linkage = .strong });
        @export(&func_08014D00, .{ .name = "func_08014D00", .linkage = .strong });
        @export(&func_08014DA0, .{ .name = "func_08014DA0", .linkage = .strong });
        @export(&func_0801A0EC, .{ .name = "func_0801A0EC", .linkage = .strong });
        @export(&func_0801A1AC, .{ .name = "func_0801A1AC", .linkage = .strong });
        @export(&func_0801A1BC, .{ .name = "func_0801A1BC", .linkage = .strong });
        @export(&func_080122D8, .{ .name = "func_080122D8", .linkage = .strong });
        @export(&func_08012340, .{ .name = "func_08012340", .linkage = .strong });
        @export(&func_080123A8, .{ .name = "func_080123A8", .linkage = .strong });
        @export(&func_0801256C, .{ .name = "func_0801256C", .linkage = .strong });
        @export(&func_080125C8, .{ .name = "func_080125C8", .linkage = .strong });
    }
}

test "animator and OAM queue strides match GBA pool layout" {
    _ = finishPoppedLr;
    try std.testing.expectEqual(@as(usize, 0x4C), types.anim_slot_stride);
    try std.testing.expectEqual(@as(usize, 0x10), types.oam_queue_stride);
    try std.testing.expectEqual(@as(u32, 0x0300_2320), types.addr.anim_pool);
    try std.testing.expectEqual(@as(u32, 0x0201_1D24), types.addr.oam_queue);
    try std.testing.expectEqual(@as(u32, 0x0300_2320), mem.animSlotAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_236C), mem.animSlotAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0201_1924), mem.oamAttrAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0201_192C), mem.oamAttrAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0201_1D24), mem.oamQueueAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0201_1D34), mem.oamQueueAddr(1));
}
