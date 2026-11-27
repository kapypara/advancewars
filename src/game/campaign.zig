//! Lifted Advance Wars campaign/save unlock bitsets (`0x0201_F9A8`) and mission record accessors (`0x0201_F9F0`).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const types = @import("types.zig");

/// Compute byte address and mask (`u8`) for bit `bit_idx` inside a save bitset at `base + byte_off`.
pub inline fn bitLocation(base: u32, byte_off: u32, bit_idx: u32) struct { addr: u32, shift: u3, mask: u8 } {
    const shift: u3 = @truncate(bit_idx & 7);
    return .{
        .addr = base +% byte_off +% (bit_idx >> 3),
        .shift = shift,
        .mask = @as(u8, 1) << shift,
    };
}

/// Pure bitset read helper (`byte & (1 << shift)`) used for native unit tests and lifted getters.
pub fn bitsetRead(bytes: []const u8, bit_idx: usize) bool {
    const byte = bytes[bit_idx >> 3];
    return (byte & (@as(u8, 1) << @truncate(bit_idx & 7))) != 0;
}

/// Pure bitset write helper used for native unit tests.
pub fn bitsetWrite(bytes: []u8, bit_idx: usize, val: u8) void {
    const shift: u3 = @truncate(bit_idx & 7);
    const mask: u8 = @as(u8, 1) << shift;
    bytes[bit_idx >> 3] = (bytes[bit_idx >> 3] & ~mask) | (val << shift);
}

fn writeSaveUnlockBit(comptime fetches_n: u32, comptime byte_off: u32, comptime pool_ref: u32) void {
    abi.fetches(fetches_n);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const val_byte: u8 = @truncate(rt.r[1]);
    const loc = bitLocation(abi.read32(pool_ref), byte_off, rt.r[0]);
    const cur = abi.read8(loc.addr);
    const shifted_val = @as(u32, val_byte) << loc.shift;
    const cleared: u32 = cur & ~@as(u32, loc.mask);
    const updated = cleared | shifted_val;
    abi.write8(loc.addr, @truncate(updated));

    rt.r[1] = shifted_val;
    rt.r[2] = loc.shift;
    rt.r[3] = loc.addr;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;

    const ret_lr = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = ret_lr;
    rt.updateNz(updated);
    rt.r[15] = ret_lr;
    rt.recompReturn(ret_lr);
}

fn readSaveUnlockBit(comptime fetches_n: u32, comptime byte_off: u32, comptime pool_ref: u32) void {
    abi.fetches(fetches_n);
    const loc = bitLocation(abi.read32(pool_ref), byte_off, rt.r[0]);
    const byte_val = abi.read8(loc.addr);
    const res: u32 = @as(u32, loc.mask) & byte_val;
    rt.r[1] = loc.shift;
    rt.r[2] = byte_val;
    abi.setRegNz(&rt.r[0], res);
    abi.retLr();
}

/// Set or clear campaign unlock bit in `save_flags + 0x03` (`0x0803EEBC`).
pub fn func_0803EEBC() callconv(.c) void {
    if (!abi.enter(0x0803EEBC)) return;
    writeSaveUnlockBit(22, 0x03, 0x0803EEE4);
}

/// Set or clear campaign unlock bit in `save_flags + 0x00` (`0x0803EF1C`).
pub fn func_0803EF1C() callconv(.c) void {
    if (!abi.enter(0x0803EF1C)) return;
    writeSaveUnlockBit(21, 0x00, 0x0803EF44);
}

/// Set or clear campaign unlock bit in `save_flags + 0x1A` (`0x0803EF48`).
pub fn func_0803EF48() callconv(.c) void {
    if (!abi.enter(0x0803EF48)) return;
    writeSaveUnlockBit(22, 0x1A, 0x0803EF70);
}

/// Test bit `r0` in `save_flags + 0x00` (`0x0803F014`).
pub fn func_0803F014() callconv(.c) void {
    if (!abi.enter(0x0803F014)) return;
    readSaveUnlockBit(12, 0x00, 0x0803F028);
}

/// Test bit `r0` in `save_flags + 0x21` (`0x0803F064`).
pub fn func_0803F064() callconv(.c) void {
    if (!abi.enter(0x0803F064)) return;
    readSaveUnlockBit(13, 0x21, 0x0803F07C);
}

/// Read byte `+0x15` of 32-byte save record slot `u8(r0)` at `0x0201_F9F0` (`0x0803F148`).
pub fn func_0803F148() callconv(.c) void {
    if (!abi.enter(0x0803F148)) return;
    abi.fetches(8);
    const slot_idx: u8 = @truncate(rt.r[0]);
    const records_base = abi.read32(0x0803F154);
    const val = abi.read8(records_base +% (@as(u32, slot_idx) << 5) +% 0x15);
    rt.r[1] = records_base;
    rt.r[0] = val;
    abi.retLr();
}

fn copySaveFlagsBlock(comptime dst_pool_ref: u32, comptime src_pool_ref: u32) void {
    abi.fetches(14);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    var src = abi.read32(src_pool_ref);
    var dst = abi.read32(dst_pool_ref);
    var last_w0: u32 = 0;
    var last_w1: u32 = 0;
    var i: u32 = 0;
    while (i < 9) : (i += 3) {
        const w0 = abi.read32(src);
        const w1 = abi.read32(src +% 4);
        const w2 = abi.read32(src +% 8);
        abi.write32(dst, w0);
        abi.write32(dst +% 4, w1);
        abi.write32(dst +% 8, w2);
        src +%= 12;
        dst +%= 12;
        last_w0 = w0;
        last_w1 = w1;
    }

    rt.r[1] = dst;
    rt.r[2] = last_w0;
    rt.r[3] = last_w1;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Snapshot 36 bytes of `save_flags (0x0201_F9A8)` into shadow buffer `0x0201_F9CC` (`0x0803E37C`).
pub fn func_0803E37C() callconv(.c) void {
    if (!abi.enter(0x0803E37C)) return;
    copySaveFlagsBlock(0x0803E394, 0x0803E398);
}

/// Restore 36 bytes into `save_flags (0x0201_F9A8)` from shadow buffer `0x0201_F9CC` (`0x0803E39C`).
pub fn func_0803E39C() callconv(.c) void {
    if (!abi.enter(0x0803E39C)) return;
    copySaveFlagsBlock(0x0803E3B4, 0x0803E3B8);
}

/// Campaign/save no-op callback (`0x0803E538`).
pub fn func_0803E538() callconv(.c) void {
    if (!abi.enter(0x0803E538)) return;
    abi.fetches(3);
    abi.retLr();
}

/// Clear byte `+0x01` in save work struct `*(0x082E_7B9C)` (`0x0803E53C`).
pub fn func_0803E53C() callconv(.c) void {
    if (!abi.enter(0x0803E53C)) return;
    abi.fetches(7);
    const work_ptr = abi.read32(abi.read32(0x0803E548));
    abi.write8(work_ptr +% 1, 0);
    rt.r[1] = work_ptr;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Write `*(0x082E_7B9C)[1] + 1` into UI cursor byte `0x0201_FD1D` (`0x0803E5F0`).
pub fn func_0803E5F0() callconv(.c) void {
    if (!abi.enter(0x0803E5F0)) return;
    abi.fetches(9);
    const dst = abi.read32(0x0803E600);
    const work_ptr = abi.read32(abi.read32(0x0803E604));
    const next: u32 = @as(u32, abi.read8(work_ptr +% 1)) +% 1;
    abi.write8(dst, @truncate(next));
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], next);
    abi.retLr();
}

/// Test bit `r0` in `save_flags + 0x1D` (`0x0803F048`).
pub fn func_0803F048() callconv(.c) void {
    if (!abi.enter(0x0803F048)) return;
    readSaveUnlockBit(13, 0x1D, 0x0803F060);
}

/// Read `u16` field `+0x08` of mission entry `u16(r0)` (stride `36`) at `*(0x082E_AE84)` (`0x08040310`).
pub fn func_08040310() callconv(.c) void {
    if (!abi.enter(0x08040310)) return;
    abi.fetches(11);
    const idx: u16 = @truncate(rt.r[0]);
    const table = abi.read32(0x08040324);
    const entry = table +% (@as(u32, idx) *% 36);
    rt.r[2] = table;
    rt.r[1] = entry;
    rt.r[0] = abi.read16(entry +% 8);
    abi.retLr();
}

fn popReturnValue() void {
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

fn callPool1ArgReturnVal(
    comptime target: fn () callconv(.c) void,
    comptime pool_ref: u32,
    comptime ret_addr: u32,
) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(pool_ref);
    if (!abi.call(target, ret_addr)) return;
    abi.fetches(4);
    popReturnValue();
}

fn querySaveFlagBit(comptime flag_id: u32, comptime returns_val: bool, comptime ret_addr: u32) void {
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], flag_id);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_0803EF74, ret_addr)) return;
    abi.fetches(4);
    if (returns_val) popReturnValue() else abi.popReturn();
}

/// Dispatch campaign banner/dialog lookup `0x080378D4` via `0x08018CA8` (`0x080378C8`).
pub fn func_080378C8() callconv(.c) void {
    if (!abi.enter(0x080378C8)) return;
    callPool1ArgReturnVal(decls.func_08018CA8, 0x080378D4, 0x080378D1);
}

/// Look up campaign text resource `0x08037914` via `0x08018400` (`0x08037908`).
pub fn func_08037908() callconv(.c) void {
    if (!abi.enter(0x08037908)) return;
    callPool1ArgReturnVal(decls.func_08018400, 0x08037914, 0x08037911);
}

/// Resolve campaign asset string `0x0803794C` via `0x080183C0` (`0x08037940`).
pub fn func_08037940() callconv(.c) void {
    if (!abi.enter(0x08037940)) return;
    callPool1ArgReturnVal(decls.func_080183C0, 0x0803794C, 0x08037949);
}

/// Trigger save progression flag `0` check via `0x0803EF74(0, 1)` (`0x0803797C`).
pub fn func_0803797C() callconv(.c) void {
    if (!abi.enter(0x0803797C)) return;
    querySaveFlagBit(0, false, 0x08037987);
}

/// Query campaign progression flag `2` (`0x08037A44`).
pub fn func_08037A44() callconv(.c) void {
    if (!abi.enter(0x08037A44)) return;
    querySaveFlagBit(2, true, 0x08037A4F);
}

/// Query campaign progression flag `3` (`0x08037ACC`).
pub fn func_08037ACC() callconv(.c) void {
    if (!abi.enter(0x08037ACC)) return;
    querySaveFlagBit(3, true, 0x08037AD7);
}

/// Query campaign progression flag `4` (`0x08037B4C`).
pub fn func_08037B4C() callconv(.c) void {
    if (!abi.enter(0x08037B4C)) return;
    querySaveFlagBit(4, true, 0x08037B57);
}

/// Query campaign progression flag `5` (`0x08037BA8`).
pub fn func_08037BA8() callconv(.c) void {
    if (!abi.enter(0x08037BA8)) return;
    querySaveFlagBit(5, true, 0x08037BB3);
}

/// Query campaign progression flag `6` (`0x08037BF8`).
pub fn func_08037BF8() callconv(.c) void {
    if (!abi.enter(0x08037BF8)) return;
    querySaveFlagBit(6, true, 0x08037C03);
}

/// Query campaign progression flag `7` (`0x08037C28`).
pub fn func_08037C28() callconv(.c) void {
    if (!abi.enter(0x08037C28)) return;
    querySaveFlagBit(7, true, 0x08037C33);
}

/// Query campaign progression flag `8` (`0x08037C38`).
pub fn func_08037C38() callconv(.c) void {
    if (!abi.enter(0x08037C38)) return;
    querySaveFlagBit(8, true, 0x08037C43);
}

/// Query campaign progression flag `9` (`0x08037C48`).
pub fn func_08037C48() callconv(.c) void {
    if (!abi.enter(0x08037C48)) return;
    querySaveFlagBit(9, true, 0x08037C53);
}

/// Query campaign progression flag `10` (`0x08037C58`).
pub fn func_08037C58() callconv(.c) void {
    if (!abi.enter(0x08037C58)) return;
    querySaveFlagBit(10, true, 0x08037C63);
}

/// Query campaign progression flag `11` (`0x08037C68`).
pub fn func_08037C68() callconv(.c) void {
    if (!abi.enter(0x08037C68)) return;
    querySaveFlagBit(11, true, 0x08037C73);
}

/// Query campaign progression flag `12` (`0x08037C78`).
pub fn func_08037C78() callconv(.c) void {
    if (!abi.enter(0x08037C78)) return;
    querySaveFlagBit(12, true, 0x08037C83);
}

/// Query campaign progression flag `13` (`0x08037C88`).
pub fn func_08037C88() callconv(.c) void {
    if (!abi.enter(0x08037C88)) return;
    querySaveFlagBit(13, true, 0x08037C93);
}

/// Query campaign progression flag `14` (`0x08037CA8`).
pub fn func_08037CA8() callconv(.c) void {
    if (!abi.enter(0x08037CA8)) return;
    querySaveFlagBit(14, true, 0x08037CB3);
}

/// Query campaign progression flag `15` (`0x08037CD8`).
pub fn func_08037CD8() callconv(.c) void {
    if (!abi.enter(0x08037CD8)) return;
    querySaveFlagBit(15, true, 0x08037CE3);
}

/// Query campaign progression flag `16` (`0x08037CE8`).
pub fn func_08037CE8() callconv(.c) void {
    if (!abi.enter(0x08037CE8)) return;
    querySaveFlagBit(16, true, 0x08037CF3);
}

/// Query campaign progression flag `17` (`0x08037CF8`).
pub fn func_08037CF8() callconv(.c) void {
    if (!abi.enter(0x08037CF8)) return;
    querySaveFlagBit(17, true, 0x08037D03);
}

/// Set bit resolved by `0x0801DE88(r0)` inside `save_flags + 3` to `u8(r1)` (`0x0803EEE8`).
pub fn func_0803EEE8() callconv(.c) void {
    if (!abi.enter(0x0803EEE8)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[1] & 0xFF;
    if (!abi.call(decls.func_0801DE88, 0x0803EEF3)) return;

    abi.fetches(21);
    const bit_num = rt.r[0] & 0xFFFF;
    const byte_addr = abi.read32(0x0803EF18) +% 3 +% (bit_num >> 3);
    const shift: u3 = @truncate(bit_num & 7);
    const clear_mask = ~(@as(u8, 1) << shift);
    const set_bits: u8 = @truncate(rt.r[4] << shift);
    abi.write8(byte_addr, (abi.read8(byte_addr) & clear_mask) | set_bits);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Query campaign/mission rank `0x0803F1DC(0, 0, u8(r0))` (`0x0803F294`).
pub fn func_0803F294() callconv(.c) void {
    if (!abi.enter(0x0803F294)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[2] = rt.r[0] & 0xFF;
    abi.setRegNz(&rt.r[0], 0);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0803F1DC, 0x0803F2A5)) return;
    abi.fetches(6);
    rt.r[0] &= 0xFF;
    popReturnValue();
}

/// Reset mission record slot `(0, 0)` via `0x0803F244` (`0x0803F2AC`).
pub fn func_0803F2AC() callconv(.c) void {
    if (!abi.enter(0x0803F2AC)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0803F244, 0x0803F2B7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Sync/save campaign map state via `0x0803906C` (`0x0803F2BC`).
pub fn func_0803F2BC() callconv(.c) void {
    if (!abi.enter(0x0803F2BC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0803906C, 0x0803F2C3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Mark campaign slot byte `+0x1D = 3` and commit save via `0x0803EE5C` (`0x0804017C`).
pub fn func_0804017C() callconv(.c) void {
    if (!abi.enter(0x0804017C)) return;
    abi.fetches(8);
    abi.pushLr();
    abi.write8(abi.read32(0x0804018C) +% 0x1D, 3);
    if (!abi.call(decls.func_0803EE5C, 0x08040189)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn spawnCampaignProcPair(
    comptime proc_ref: u32,
    comptime call_arg1_zero_second: bool,
    comptime ret1: u32,
    comptime ret2: u32,
) void {
    _ = call_arg1_zero_second;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(proc_ref);
    if (!abi.call(decls.func_0801329C, ret1)) return;
    abi.fetches(6);
    rt.r[0] = abi.read32(proc_ref +% 4);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, ret2)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn setCampaignModeAndUnlock(
    comptime mode_val: u8,
    comptime mode_ptr_ref: u32,
    comptime tbl_ref: u32,
    comptime idx_ptr_ref: u32,
    comptime tbl_plus4_first: bool,
    comptime proc_ref: u32,
    comptime ret1: u32,
    comptime ret2: u32,
) void {
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const st_ptr = abi.read32(mode_ptr_ref);
    rt.r[4] = st_ptr;
    abi.write8(st_ptr +% 1, mode_val);
    abi.setRegNz(&rt.r[0], mode_val);
    if (!abi.call(decls.func_08038F9C, ret1)) return;

    abi.fetches(if (tbl_plus4_first) 13 else 14);
    const val = if (tbl_plus4_first)
        abi.read8(abi.read8(abi.read32(idx_ptr_ref) +% 0x1F) +% (abi.read32(tbl_ref) +% 4))
    else
        abi.read8(abi.read8(abi.read32(idx_ptr_ref) +% 0x20) +% (abi.read32(tbl_ref) +% 4));
    abi.write8(st_ptr +% 2, val);
    rt.r[0] = abi.read32(proc_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, ret2)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Complete map summary `0x0803AE0C` and set overlay flag `[0x0803B364]` via `0x08015824(..., 2)` (`0x0803B350`).
pub fn func_0803B350() callconv(.c) void {
    if (!abi.enter(0x0803B350)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0803AE0C, 0x0803B357)) return;
    abi.fetches(6);
    rt.r[0] = abi.read32(0x0803B364);
    abi.setRegNz(&rt.r[1], 2);
    if (!abi.call(decls.func_08015824, 0x0803B35F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Look up CO display metric `0x08040310([0x0803B390])`, offset/mask, and draw label via `0x0801B888` (`0x0803B368`).
pub fn func_0803B368() callconv(.c) void {
    if (!abi.enter(0x0803B368)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read8(abi.read32(0x0803B390));
    if (!abi.call(func_08040310, 0x0803B373)) return;

    abi.fetches(14);
    const val = (abi.read16(abi.read32(0x0803B394)) +% rt.r[0]) & abi.read32(0x0803B398);
    abi.setRegNz(&rt.r[0], val);
    rt.r[1] = abi.read8(abi.read32(0x0803B39C));
    rt.r[2] = abi.read32(0x0803B3A0);
    rt.r[3] = abi.read32(0x0803B3A4);
    if (!abi.call(decls.func_0801B888, 0x0803B38B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Show/hide animator `[0x0803B4F4]` via `0x080147B8` and `0x080148DC` (`0x0803B4D8`).
pub fn func_0803B4D8() callconv(.c) void {
    if (!abi.enter(0x0803B4D8)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const slot_ptr = abi.read32(0x0803B4F4);
    rt.r[4] = slot_ptr;
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ptr)));
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080147B8, 0x0803B4E5)) return;

    abi.fetches(6);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ptr)));
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080148DC, 0x0803B4ED)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Sync CO portrait via `0x0801BF50` and apply CO color palette `[CO * 292 + 0x10]` via `0x0807B44C` (`0x0803BAA0`).
pub fn func_0803BAA0() callconv(.c) void {
    if (!abi.enter(0x0803BAA0)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const obj = rt.r[0];
    rt.r[4] = obj;
    rt.r[0] = abi.read16(obj +% 0x20) & 0xFF;
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801BF50, 0x0803BAB1)) return;

    abi.fetches(21);
    const ent_idx: u32 = @bitCast(abi.signExtend16(abi.read16(obj +% 0x20)));
    const ents = abi.read32(abi.read32(0x0803BAE0));
    const co_id = abi.read8(ents +% (ent_idx *% 0x68) +% 0x1D);
    const tbl_base = abi.read32(0x0803BADC) +% 0x10;
    rt.r[2] = tbl_base;
    rt.r[1] = co_id;
    rt.r[3] = ent_idx;
    rt.r[0] = abi.read32(tbl_base +% (@as(u32, co_id) *% 292));
    if (!abi.call(decls.func_0807B44C, 0x0803BAD7)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Enable campaign flags `[0x0803C708]` and `[0x0803C70C]` via `0x08015824(..., 1)` (`0x0803C6F0`).
pub fn func_0803C6F0() callconv(.c) void {
    if (!abi.enter(0x0803C6F0)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0803C708);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_08015824, 0x0803C6FB)) return;
    abi.fetches(6);
    rt.r[0] = abi.read32(0x0803C70C);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_08015824, 0x0803C703)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn campaign sub-procs `[0x0803C88C]` and `[0x0803C890]` via `0x0801329C` (`0x0803C878`).
pub fn func_0803C878() callconv(.c) void {
    if (!abi.enter(0x0803C878)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0803C88C);
    if (!abi.call(decls.func_0801329C, 0x0803C881)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x0803C890);
    if (!abi.call(decls.func_0801329C, 0x0803C887)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Load campaign mission `[0x0803CCC0]` via `0x080241DC(u8(r0))`, spawn `[0x0803CCC4]`, and populate `[0x0803CCC8]` (`0x0803CC90`).
pub fn func_0803CC90() callconv(.c) void {
    if (!abi.enter(0x0803CC90)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const mission_tbl = abi.read32(0x0803CCC0);
    rt.r[4] = mission_tbl;
    rt.r[1] = rt.r[0] & 0xFF;
    rt.r[0] = mission_tbl;
    rt.updateNz(rt.r[1]);
    if (!abi.call(decls.func_080241DC, 0x0803CCA1)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x0803CCC4);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x0803CCA9)) return;

    abi.fetches(14);
    const dst = abi.read32(abi.read32(0x0803CCC8));
    abi.write8(dst, 0x80);
    abi.write32(dst +% 4, mission_tbl);
    const cnt: u8 = @truncate(abi.read16(abi.read32(0x0803CCCC)));
    abi.write8(dst +% 8, cnt);
    rt.r[0] = cnt;
    rt.r[1] = dst;
    rt.r[2] = abi.read32(0x0803CCC8);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear tileset `0x0800F894` and spawn proc `[0x0803D014]` via `0x0801320C` (`0x0803D000`).
pub fn func_0803D000() callconv(.c) void {
    if (!abi.enter(0x0803D000)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0800F894, 0x0803D007)) return;
    abi.fetches(6);
    rt.r[0] = abi.read32(0x0803D014);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x0803D00F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Reset field sprites `0x0801B57C` and cursor shadow `0x08015FB4` (`0x0803D2E4`).
pub fn func_0803D2E4() callconv(.c) void {
    if (!abi.enter(0x0803D2E4)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0801B57C, 0x0803D2EB)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08015FB4, 0x0803D2EF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Focus proc `[0x0803DB94]` (`0x0801329C`) and spawn proc `[0x0803DB98]` (`0x0801320C`) (`0x0803DB80`).
pub fn func_0803DB80() callconv(.c) void {
    if (!abi.enter(0x0803DB80)) return;
    spawnCampaignProcPair(0x0803DB94, true, 0x0803DB89, 0x0803DB91);
}

/// Reset CO screen `0x0803E37C` and upload background layer via `0x08011060` (`0x0803DBE0`).
pub fn func_0803DBE0() callconv(.c) void {
    if (!abi.enter(0x0803DBE0)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_0803E37C, 0x0803DBE7)) return;
    abi.fetches(7);
    rt.r[0] = abi.read32(0x0803DBF4);
    rt.r[1] = abi.read32(0x0803DBF8);
    rt.r[2] = abi.read32(0x0803DBFC);
    if (!abi.call(decls.func_08011060, 0x0803DBF1)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Stop/release War Room sound (`0x0803D968`) and return to menu `0x08000C54(0)` (`0x0803DDFC`).
pub fn func_0803DDFC() callconv(.c) void {
    if (!abi.enter(0x0803DDFC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0803D968, 0x0803DE03)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_08000C54, 0x0803DE09)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Set campaign mode `0` (`[0x0803DE50]`) and select active mission map from `[0x0803DE54] + 4` (`0x0803DE28`).
pub fn func_0803DE28() callconv(.c) void {
    if (!abi.enter(0x0803DE28)) return;
    setCampaignModeAndUnlock(0, 0x0803DE50, 0x0803DE54, 0x0803DE58, true, 0x0803DE5C, 0x0803DE35, 0x0803DE4B);
}

/// Set campaign mode `1` (`[0x0803DF2C]`) and select active War Room map from `[0x0803DF30] + 4` (`0x0803DF00`).
pub fn func_0803DF00() callconv(.c) void {
    if (!abi.enter(0x0803DF00)) return;
    setCampaignModeAndUnlock(1, 0x0803DF2C, 0x0803DF30, 0x0803DF34, false, 0x0803DF38, 0x0803DF0D, 0x0803DF25);
}

/// Exit submenu (`0x08019608`, `0x080347A8`) and mark completion halfword `[0x0803E498] = 1` (`0x0803E484`).
pub fn func_0803E484() callconv(.c) void {
    if (!abi.enter(0x0803E484)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019608, 0x0803E48B)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080347A8, 0x0803E48F)) return;
    abi.fetches(7);
    rt.r[1] = abi.read32(0x0803E498);
    abi.setRegNz(&rt.r[0], 1);
    abi.write16(rt.r[1], 1);
    abi.popReturn();
}

/// Resolve bitflag `0x0801DE88(r0)` in `[0x0803F010] + 3` bitset (`0x0803EFE8`).
pub fn func_0803EFE8() callconv(.c) void {
    if (!abi.enter(0x0803EFE8)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[3] = rt.r[0];
    if (!abi.call(decls.func_0801DE88, 0x0803EFF1)) return;

    abi.fetches(19);
    const idx = rt.r[0] & 0xFFFF;
    const bit: u5 = @truncate(idx & 7);
    const addr = (idx >> 3) +% (abi.read32(0x0803F010) +% 3);
    const byte_val = abi.read8(addr);
    const res = (@as(u32, 1) << bit) & byte_val;
    rt.r[1] = idx & 7;
    rt.r[2] = byte_val;
    rt.r[3] = idx;
    abi.setRegNz(&rt.r[0], res);
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Update War Room slot `0x0803F314(u8(r0))` and commit `[0x0803F35C]` via `0x0803F628` (`0x0803F348`).
pub fn func_0803F348() callconv(.c) void {
    if (!abi.enter(0x0803F348)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_0803F314, 0x0803F353)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x0803F35C);
    if (!abi.call(decls.func_0803F628, 0x0803F359)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Record mission result via `0x0803F6D8`, apply rank `0x0803F628(r1)`, and finalize `0x0803F7D4` (`0x0803F7BC`).
pub fn func_0803F7BC() callconv(.c) void {
    if (!abi.enter(0x0803F7BC)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved = rt.r[1];
    rt.r[4] = saved;
    if (!abi.call(decls.func_0803F6D8, 0x0803F7C5)) return;
    abi.fetches(5);
    rt.r[0] = saved;
    if (!abi.call(decls.func_0803F628, 0x0803F7CB)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0803F7D4, 0x0803F7CF)) return;
    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Invoke `0x0807B44C` on object handle `read32(r0 + 0x18)` (`0x0803FCEC`).
pub fn func_0803FCEC() callconv(.c) void {
    if (!abi.enter(0x0803FCEC)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(rt.r[0] +% 0x18);
    if (!abi.call(decls.func_0807B44C, 0x0803FCF5)) return;
    abi.fetches(6);
    abi.popReturn();
}

/// Invoke `0x08015DA8` on object byte `read8(r0 + 0x10)` (`0x0803FCF8`).
pub fn func_0803FCF8() callconv(.c) void {
    if (!abi.enter(0x0803FCF8)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read8(rt.r[0] +% 0x10);
    if (!abi.call(decls.func_08015DA8, 0x0803FD01)) return;
    abi.fetches(6);
    abi.popReturn();
}

/// Trigger sound effect `0x85` via `0x0803D880` (`0x0803FD04`).
pub fn func_0803FD04() callconv(.c) void {
    if (!abi.enter(0x0803FD04)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0x85);
    if (!abi.call(decls.func_0803D880, 0x0803FD0D)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Trigger sound effect `0x86` via `0x0803D880` (`0x0803FD10`).
pub fn func_0803FD10() callconv(.c) void {
    if (!abi.enter(0x0803FD10)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0x86);
    if (!abi.call(decls.func_0803D880, 0x0803FD19)) return;
    abi.fetches(6);
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_080378C8, .{ .name = "func_080378C8", .linkage = .strong });
        @export(&func_08037908, .{ .name = "func_08037908", .linkage = .strong });
        @export(&func_08037940, .{ .name = "func_08037940", .linkage = .strong });
        @export(&func_0803797C, .{ .name = "func_0803797C", .linkage = .strong });
        @export(&func_08037A44, .{ .name = "func_08037A44", .linkage = .strong });
        @export(&func_08037ACC, .{ .name = "func_08037ACC", .linkage = .strong });
        @export(&func_08037B4C, .{ .name = "func_08037B4C", .linkage = .strong });
        @export(&func_08037BA8, .{ .name = "func_08037BA8", .linkage = .strong });
        @export(&func_08037BF8, .{ .name = "func_08037BF8", .linkage = .strong });
        @export(&func_08037C28, .{ .name = "func_08037C28", .linkage = .strong });
        @export(&func_08037C38, .{ .name = "func_08037C38", .linkage = .strong });
        @export(&func_08037C48, .{ .name = "func_08037C48", .linkage = .strong });
        @export(&func_08037C58, .{ .name = "func_08037C58", .linkage = .strong });
        @export(&func_08037C68, .{ .name = "func_08037C68", .linkage = .strong });
        @export(&func_08037C78, .{ .name = "func_08037C78", .linkage = .strong });
        @export(&func_08037C88, .{ .name = "func_08037C88", .linkage = .strong });
        @export(&func_08037CA8, .{ .name = "func_08037CA8", .linkage = .strong });
        @export(&func_08037CD8, .{ .name = "func_08037CD8", .linkage = .strong });
        @export(&func_08037CE8, .{ .name = "func_08037CE8", .linkage = .strong });
        @export(&func_08037CF8, .{ .name = "func_08037CF8", .linkage = .strong });
        @export(&func_0803E37C, .{ .name = "func_0803E37C", .linkage = .strong });
        @export(&func_0803E39C, .{ .name = "func_0803E39C", .linkage = .strong });
        @export(&func_0803E538, .{ .name = "func_0803E538", .linkage = .strong });
        @export(&func_0803E53C, .{ .name = "func_0803E53C", .linkage = .strong });
        @export(&func_0803E5F0, .{ .name = "func_0803E5F0", .linkage = .strong });
        @export(&func_0803EEBC, .{ .name = "func_0803EEBC", .linkage = .strong });
        @export(&func_0803EEE8, .{ .name = "func_0803EEE8", .linkage = .strong });
        @export(&func_0803F294, .{ .name = "func_0803F294", .linkage = .strong });
        @export(&func_0803F2AC, .{ .name = "func_0803F2AC", .linkage = .strong });
        @export(&func_0803F2BC, .{ .name = "func_0803F2BC", .linkage = .strong });
        @export(&func_0804017C, .{ .name = "func_0804017C", .linkage = .strong });
        @export(&func_0803EF1C, .{ .name = "func_0803EF1C", .linkage = .strong });
        @export(&func_0803EF48, .{ .name = "func_0803EF48", .linkage = .strong });
        @export(&func_0803F014, .{ .name = "func_0803F014", .linkage = .strong });
        @export(&func_0803F048, .{ .name = "func_0803F048", .linkage = .strong });
        @export(&func_0803F064, .{ .name = "func_0803F064", .linkage = .strong });
        @export(&func_0803F148, .{ .name = "func_0803F148", .linkage = .strong });
        @export(&func_08040310, .{ .name = "func_08040310", .linkage = .strong });
        @export(&func_0803B350, .{ .name = "func_0803B350", .linkage = .strong });
        @export(&func_0803B368, .{ .name = "func_0803B368", .linkage = .strong });
        @export(&func_0803B4D8, .{ .name = "func_0803B4D8", .linkage = .strong });
        @export(&func_0803BAA0, .{ .name = "func_0803BAA0", .linkage = .strong });
        @export(&func_0803C6F0, .{ .name = "func_0803C6F0", .linkage = .strong });
        @export(&func_0803C878, .{ .name = "func_0803C878", .linkage = .strong });
        @export(&func_0803CC90, .{ .name = "func_0803CC90", .linkage = .strong });
        @export(&func_0803D000, .{ .name = "func_0803D000", .linkage = .strong });
        @export(&func_0803D2E4, .{ .name = "func_0803D2E4", .linkage = .strong });
        @export(&func_0803DB80, .{ .name = "func_0803DB80", .linkage = .strong });
        @export(&func_0803DBE0, .{ .name = "func_0803DBE0", .linkage = .strong });
        @export(&func_0803DDFC, .{ .name = "func_0803DDFC", .linkage = .strong });
        @export(&func_0803DE28, .{ .name = "func_0803DE28", .linkage = .strong });
        @export(&func_0803DF00, .{ .name = "func_0803DF00", .linkage = .strong });
        @export(&func_0803E484, .{ .name = "func_0803E484", .linkage = .strong });
        @export(&func_0803EFE8, .{ .name = "func_0803EFE8", .linkage = .strong });
        @export(&func_0803F348, .{ .name = "func_0803F348", .linkage = .strong });
        @export(&func_0803F7BC, .{ .name = "func_0803F7BC", .linkage = .strong });
        @export(&func_0803FCEC, .{ .name = "func_0803FCEC", .linkage = .strong });
        @export(&func_0803FCF8, .{ .name = "func_0803FCF8", .linkage = .strong });
        @export(&func_0803FD04, .{ .name = "func_0803FD04", .linkage = .strong });
        @export(&func_0803FD10, .{ .name = "func_0803FD10", .linkage = .strong });
    }
}

test "save bitset read/write helpers toggle exact bits" {
    var buf: [40]u8 = @splat(0);
    bitsetWrite(&buf, 11, 1);
    try std.testing.expect(bitsetRead(&buf, 11));
    try std.testing.expect(!bitsetRead(&buf, 10));
    bitsetWrite(&buf, 11, 0);
    try std.testing.expect(!bitsetRead(&buf, 11));
    const loc = bitLocation(types.addr.save_flags, 0x1A, 9);
    try std.testing.expectEqual(@as(u32, types.addr.save_flags + 0x1B), loc.addr);
    try std.testing.expectEqual(@as(u8, 2), loc.mask);
}
