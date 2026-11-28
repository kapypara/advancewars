//! Lifted Advance Wars campaign/save unlock bitsets (`0x0201_F9A8`) and mission record accessors (`0x0201_F9F0`).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const mem = @import("mem.zig");
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

/// Finish campaign slide step via `0x0803B3A8` and stop proc if `+0x1E` != 0 (`0x0803B3DC`).
pub fn func_0803B3DC() callconv(.c) void {
    if (!abi.enter(0x0803B3DC)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.pushReg(4);

    rt.r[4] = rt.r[0];
    if (!abi.call(decls.func_0803B3A8, 0x0803B3E5)) return;

    abi.fetches(6);
    abi.setRegNz(&rt.r[1], 0x1E);
    const flag = mem.readI16(rt.r[4] +% 0x1E);
    rt.r[0] = @bitCast(@as(i32, flag));
    rt.cpuSub(null, rt.r[0], 0, true);
    if (flag != 0) {
        abi.fetches(5);
        abi.setRegNz(&rt.r[0], 0);
        mem.writeU16(rt.r[4] +% 0x1E, 0);
        mem.writeU32(rt.r[4] +% 0x8, 0);
    }

    abi.fetches(5);
    rt.r[4] = abi.popReg();
    abi.popReturn();
}

/// Decrement campaign scroll coordinate `+0x20` by 8, clamping at `0x82` (`0x0803B3F8`).
pub fn func_0803B3F8() callconv(.c) void {
    if (!abi.enter(0x0803B3F8)) return;
    abi.fetches(11);
    abi.pushLr();

    const slot = rt.r[0];
    rt.cpuAdd(&rt.r[1], slot, 0, true);
    const next_u16: u16 = mem.readU16(slot +% 0x20) -% 8;
    mem.writeU16(slot +% 0x20, next_u16);
    const next_s16: i16 = @bitCast(next_u16);
    abi.setRegNz(&rt.r[0], @bitCast(@as(i32, next_s16)));
    rt.cpuSub(null, rt.r[0], 0x81, true);
    if (next_s16 <= 0x81) {
        abi.fetches(6);
        mem.writeU16(slot +% 0x20, 0x82);
        abi.setRegNz(&rt.r[0], 0);
        mem.writeU32(slot +% 0x8, 0);
    }

    abi.fetches(5);
    rt.cpuAdd(&rt.r[0], rt.r[1], 0, true);
    if (!abi.call(decls.func_0803B3A8, 0x0803B419)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Campaign/map flow callback no-op (`0x0803CF1C`).
pub fn func_0803CF1C() callconv(.c) void {
    if (!abi.enter(0x0803CF1C)) return;
    abi.fetches(3);
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
    if (!abi.call(func_0803F244, 0x0803F2B7)) return;
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

/// Prepare campaign sub-screen via `0x080385CC`, `0x08038674`, spawn proc `[0x080386B0]`, and flush `0x080385BC` (`0x08038694`).
pub fn func_08038694() callconv(.c) void {
    if (!abi.enter(0x08038694)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080385CC, 0x0803869B)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08038674, 0x0803869F)) return;
    abi.fetches(6);
    rt.r[0] = abi.read32(0x080386B0);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, 0x080386A7)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080385BC, 0x080386AB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Tear down campaign child procs `[0x08038C64..0x08038C6C]` after `0x08014980` and flush `0x080385BC` (`0x08038C44`).
pub fn func_08038C44() callconv(.c) void {
    if (!abi.enter(0x08038C44)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08014980, 0x08038C4B)) return;
    inline for ([_]u32{ 0x08038C64, 0x08038C68, 0x08038C6C }, [_]u32{ 0x08038C51, 0x08038C57, 0x08038C5D }) |ref, ret_addr| {
        abi.fetches(5);
        rt.r[0] = abi.read32(ref);
        if (!abi.call(decls.func_0801329C, ret_addr)) return;
    }
    abi.fetches(4);
    if (!abi.call(decls.func_080385BC, 0x08038C61)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Draw masked icon via `0x0801B888` at wrapped coordinates and apply `[0x08038D5C]` before `0x08038C90` (`0x08038D0C`).
pub fn func_08038D0C() callconv(.c) void {
    if (!abi.enter(0x08038D0C)) return;
    abi.fetches(27);
    abi.pushLr();
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);

    const a0 = rt.r[0] & 0xFFFF;
    const a1 = rt.r[1] & 0xFFFF;
    const a2 = rt.r[2] & 0xFFFF;
    const a3 = rt.r[3] & 0xFFFF;
    const draw_attr = ((rt.r[3] << 16) +% abi.read32(0x08038D5C)) >> 16;
    rt.r[0] = a0 & abi.read32(0x08038D54);
    rt.r[1] = a1 & 0xFF;
    rt.r[2] = abi.read32(0x08038D58);
    abi.setRegNz(&rt.r[3], draw_attr);
    if (!abi.call(decls.func_0801B888, 0x08038D3F)) return;

    abi.fetches(8);
    rt.r[0] = a0;
    rt.r[1] = a1;
    rt.r[2] = a2;
    rt.r[3] = a3;
    if (!abi.call(decls.func_08038C90, 0x08038D4B)) return;

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
    rt.r[7] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Apply campaign cursor `0x08038C90`, then draw secondary sprite `0x0801B888` with `(-0x18, -8)` offset (`0x08038D60`).
pub fn func_08038D60() callconv(.c) void {
    if (!abi.enter(0x08038D60)) return;
    abi.fetches(19);
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
    const a3 = rt.r[3] & 0xFFFF;
    rt.r[0] = a0;
    rt.r[1] = a1;
    rt.r[2] = a2;
    rt.r[3] = a3;
    if (!abi.call(decls.func_08038C90, 0x08038D83)) return;

    abi.fetches(19);
    rt.r[0] = (a0 -% 0x18) & abi.read32(0x08038DAC);
    rt.r[1] = (a1 -% 8) & 0xFF;
    rt.r[2] = abi.read32(0x08038DB0);
    rt.r[3] = (a3 +% abi.read32(0x08038DB4)) & 0xFFFF;
    if (!abi.call(decls.func_0801B888, 0x08038DA5)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn syncCampaignPanelScreen(
    comptime arg0_ref: u32,
    comptime arg1_ref: u32,
    comptime arg2_ref: u32,
    comptime ret1: u32,
    comptime ret2: u32,
    comptime ret3: u32,
    comptime ret4: u32,
    comptime ret_r1: bool,
) void {
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read8(abi.read32(arg0_ref) +% 1);
    if (!abi.call(decls.func_08038F9C, ret1)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08039814, ret2)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(arg1_ref);
    if (!abi.call(decls.func_08038260, ret3)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(arg2_ref);
    if (!abi.call(decls.func_0803826C, ret4)) return;
    abi.fetches(4);
    if (ret_r1) {
        popReturnValue();
    } else {
        abi.popReturn();
    }
}

/// Sync campaign overview screen panel and exit via `pop {r0}` (`0x080398EC`).
pub fn func_080398EC() callconv(.c) void {
    if (!abi.enter(0x080398EC)) return;
    syncCampaignPanelScreen(0x0803990C, 0x08039910, 0x08039914, 0x080398F7, 0x080398FB, 0x08039901, 0x08039907, false);
}

/// Sync campaign overview screen panel and exit via `pop {r1}; bx r1` (`0x08039918`).
pub fn func_08039918() callconv(.c) void {
    if (!abi.enter(0x08039918)) return;
    syncCampaignPanelScreen(0x08039938, 0x0803993C, 0x08039940, 0x08039923, 0x08039927, 0x0803992D, 0x08039933, true);
}

/// Populate two campaign map row strips (rows `7` and `0xD`) via `0x08012A68` from `[0x0803C640]` (`0x0803C5CC`).
pub fn func_0803C5CC() callconv(.c) void {
    if (!abi.enter(0x0803C5CC)) return;
    abi.fetches(36);
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
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const ptr_arg = rt.r[1];
    const col_x = ((rt.r[0] & 0xFF) +% 8) >> 3;
    const dst = abi.read32(0x0803C63C);
    const tbl = abi.read32(0x0803C640);
    const entry_off1 = @as(u32, abi.read8(ptr_arg)) *% 0x70;
    abi.write32(rt.r[13], 0x4000);
    abi.write32(rt.r[13] +% 4, 0);
    rt.r[0] = col_x;
    abi.setRegNz(&rt.r[1], 7);
    rt.r[2] = dst;
    rt.r[3] = abi.read32(tbl +% entry_off1 +% 4);
    if (!abi.call(decls.func_08012A68, 0x0803C611)) return;

    abi.fetches(17);
    const entry_off2 = @as(u32, abi.read8(ptr_arg)) *% 0x70;
    abi.write32(rt.r[13], 0x4000);
    abi.write32(rt.r[13] +% 4, 0);
    rt.r[0] = col_x;
    abi.setRegNz(&rt.r[1], 0xD);
    rt.r[2] = dst;
    rt.r[3] = abi.read32(tbl +% entry_off2 +% 8);
    if (!abi.call(decls.func_08012A68, 0x0803C62F)) return;

    abi.fetches(9);
    rt.r[13] +%= 8;
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
    rt.r[7] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Enable BG2, upload palette `0x3E0` from `[0x0803C6EC]`, flush `0x080117EC(0)`, and sync `0x080221D0` (`0x0803C6CC`).
pub fn func_0803C6CC() callconv(.c) void {
    if (!abi.enter(0x0803C6CC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08011824, 0x0803C6D3)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x0803C6EC);
    abi.setRegNz(&rt.r[1], 0x3E0);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, 0x0803C6DF)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_080117EC, 0x0803C6E5)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_080221D0, 0x0803C6E9)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Open campaign mission card slot `u8(r0)` using active step `0x08013B70` and row table `[0x0803CD3C]` (`0x0803CCD0`).
pub fn func_0803CCD0() callconv(.c) void {
    if (!abi.enter(0x0803CCD0)) return;
    abi.fetches(11);
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

    const card_id = rt.r[0] & 0xFF;
    rt.r[0] = abi.read32(0x0803CD30);
    if (!abi.call(decls.func_08013B70, 0x0803CCE3)) return;

    abi.fetches(11);
    const slot_i32 = abi.signExtend8(@truncate(rt.r[0]));
    const ctx = abi.read32(0x0803CD34);
    rt.r[0] = ctx;
    rt.r[1] = card_id;
    if (!abi.call(decls.func_080241DC, 0x0803CCF5)) return;

    abi.fetches(18);
    const state_ref = abi.read32(0x0803CD38);
    const state = abi.read32(state_ref);
    abi.write32(state +% 4, ctx);
    const row_ptr = abi.read32(0x0803CD3C) +% (@as(u32, @bitCast(slot_i32 *% 3)) << 5) +% 0x18;
    rt.r[0] = abi.read8(state);
    rt.r[1] = abi.read32(row_ptr);
    if (!abi.call(decls.func_0803C348, 0x0803CD15)) return;

    abi.fetches(8);
    rt.r[0] = abi.read8(abi.read32(state_ref));
    rt.r[1] = abi.read32(row_ptr);
    if (!abi.call(func_0803C5CC, 0x0803CD21)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_080117EC, 0x0803CD27)) return;

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

/// Open default campaign card `u8(r0)` with `[0x0803CD80]` and refresh banner `func_0803C5CC` (`0x0803CD40`).
pub fn func_0803CD40() callconv(.c) void {
    if (!abi.enter(0x0803CD40)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const card_id = rt.r[0] & 0xFF;
    rt.r[0] = abi.read32(0x0803CD7C);
    if (!abi.call(decls.func_08013B70, 0x0803CD4F)) return;

    abi.fetches(7);
    const ctx = abi.read32(0x0803CD80);
    rt.r[0] = ctx;
    rt.r[1] = card_id;
    if (!abi.call(decls.func_080241DC, 0x0803CD59)) return;

    abi.fetches(9);
    const state_ref = abi.read32(0x0803CD84);
    const state = abi.read32(state_ref);
    abi.write32(state +% 4, ctx);
    rt.r[0] = abi.read8(state);
    rt.r[1] = ctx;
    if (!abi.call(decls.func_0803C348, 0x0803CD67)) return;

    abi.fetches(7);
    const st2 = abi.read32(state_ref);
    rt.r[0] = abi.read8(st2);
    rt.r[1] = abi.read32(st2 +% 4);
    if (!abi.call(func_0803C5CC, 0x0803CD71)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_080117EC, 0x0803CD77)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Draw animated campaign prompt badge at computed bobbing Y offset (`0x0803D5B0`).
pub fn func_0803D5B0() callconv(.c) void {
    if (!abi.enter(0x0803D5B0)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const y_tbl = abi.read32(0x0803D5F0);
    rt.r[0] = abi.read32(abi.read32(0x0803D5F4));
    abi.setRegNz(&rt.r[1], 3);
    if (!abi.call(decls.func_0807B634, 0x0803D5BF)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[1], 0xA);
    if (!abi.call(decls.func_0807B6AC, 0x0803D5C5)) return;

    abi.fetches(13);
    const dy: u16 = abi.read16(y_tbl +% (rt.r[0] << 1)) +% 0x6C;
    abi.setRegNz(&rt.r[0], 0x38);
    rt.r[1] = @bitCast(abi.signExtend16(dy));
    rt.r[2] = abi.read32(0x0803D5F8);
    rt.r[3] = abi.read32(0x0803D5FC);
    if (!abi.call(decls.func_0801B888, 0x0803D5DB)) return;

    abi.fetches(9);
    abi.setRegNz(&rt.r[0], 0x48);
    abi.setRegNz(&rt.r[1], 0x88);
    rt.r[2] = abi.read32(0x0803D600);
    abi.setRegNz(&rt.r[3], 0x2000);
    if (!abi.call(decls.func_0801B888, 0x0803D5E9)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Reset campaign map transition (`0x0803E37C`, `0x0803E3BC`, `0x08042E24`) and set window `0x08011060` (`0x0803DB9C`).
pub fn func_0803DB9C() callconv(.c) void {
    if (!abi.enter(0x0803DB9C)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_0803E37C, 0x0803DBA3)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0803E3BC, 0x0803DBA7)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08042E24, 0x0803DBAB)) return;
    abi.fetches(7);
    rt.r[0] = abi.read32(0x0803DBB8);
    rt.r[1] = abi.read32(0x0803DBBC);
    rt.r[2] = abi.read32(0x0803DBC0);
    if (!abi.call(decls.func_08011060, 0x0803DBB5)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Enter campaign theater scene: clear tiles `[0x0803E534]`, reset map/CO layers, fade `0x080399CC`, `0x08012A4C(0)` (`0x0803E514`).
pub fn func_0803E514() callconv(.c) void {
    if (!abi.enter(0x0803E514)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0803E534);
    if (!abi.call(decls.func_08010D00, 0x0803E51D)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080204B4, 0x0803E521)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_080199A0, 0x0803E527)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080399CC, 0x0803E52B)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_08012A4C, 0x0803E531)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Populate War Room / campaign map badge via `0x0803F3AC`, `0x080395A8`, `0x0803FB18`, and `0x0803902C` (`0x0803F244`).
pub fn func_0803F244() callconv(.c) void {
    if (!abi.enter(0x0803F244)) return;
    abi.fetches(12);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    const a0 = rt.r[0];
    const a1 = rt.r[1];
    const buf = abi.read32(0x0803F288);
    rt.r[0] = abi.read32(0x0803F28C);
    rt.r[1] = buf;
    abi.setRegNz(&rt.r[2], 1);
    if (!abi.call(decls.func_0803F3AC, 0x0803F259)) return;

    abi.fetches(5);
    rt.r[0] = buf;
    if (!abi.call(decls.func_080395A8, 0x0803F25F)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_0803FB18, 0x0803F263)) return;

    abi.fetches(17);
    const char_bank = ((abi.read32(abi.read32(0x0803F290)) << 28) >> 30) << 14;
    abi.write32(rt.r[13], 5);
    rt.r[0] = char_bank +% (@as(u32, 0xC0) << 19);
    abi.setRegNz(&rt.r[1], 0);
    rt.r[2] = a0;
    rt.r[3] = a1;
    if (!abi.call(decls.func_0803902C, 0x0803F281)) return;

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

/// Apply War Room CO/turn card `r0`/`r1` via `0x0801AC1C`, `0x0803F7BC`, `0x080246E4`, and `0x08021DF8` (`0x0803F2C8`).
pub fn func_0803F2C8() callconv(.c) void {
    if (!abi.enter(0x0803F2C8)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const a1 = rt.r[1];
    const buf = abi.read32(0x0803F30C);
    const tile_idx = ((rt.r[0] << 24) +% (@as(u32, 0xA0) << 19)) >> 24;
    abi.setRegNz(&rt.r[0], tile_idx);
    rt.r[1] = buf;
    if (!abi.call(decls.func_0801AC1C, 0x0803F2DF)) return;

    abi.fetches(6);
    rt.r[0] = a1;
    rt.r[1] = buf;
    if (!abi.call(func_0803F7BC, 0x0803F2E7)) return;

    abi.fetches(16);
    const cfg = abi.read32(0x0803F310);
    rt.r[0] = abi.read8(cfg +% 0x34);
    rt.r[1] = abi.read8(cfg +% 0x35);
    rt.r[2] = abi.read8(cfg +% 0x36);
    rt.r[3] = abi.read8(cfg +% 0x37);
    if (!abi.call(decls.func_080246E4, 0x0803F303)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08021DF8, 0x0803F307)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

const CampaignDmaPair = struct {
    src_pool: u32,
    dst_pool: u32,
    ret: u32,
};

fn uploadDmaBatch0800(comptime pairs: []const CampaignDmaPair) bool {
    inline for (pairs, 0..) |p, i| {
        abi.fetches(if (i == 0) 9 else 7);
        rt.r[0] = abi.read32(p.src_pool);
        rt.r[1] = abi.read32(p.dst_pool);
        rt.r[2] = 0x800;
        if (!abi.call(decls.func_0800FDA4, p.ret)) return false;
    }
    return true;
}

/// Initialize world/campaign screen background layer descriptors (`0x080381C4`).
pub fn func_080381C4() callconv(.c) void {
    if (!abi.enter(0x080381C4)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080220F8, 0x080381CB)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0800FC58, 0x080381CF)) return;

    const cfg_pools = [_]struct { u32, u32 }{
        .{ 0x08038214, 0x080381D5 },
        .{ 0x08038218, 0x080381DB },
        .{ 0x0803821C, 0x080381E1 },
        .{ 0x08038220, 0x080381E7 },
        .{ 0x08038224, 0x080381ED },
        .{ 0x08038228, 0x080381F3 },
        .{ 0x0803822C, 0x080381F9 },
        .{ 0x08038230, 0x080381FF },
        .{ 0x08038234, 0x08038205 },
    };
    inline for (cfg_pools) |p| {
        abi.fetches(5);
        rt.r[0] = abi.read32(p[0]);
        if (!abi.call(decls.func_0800FC74, p[1])) return;
    }

    abi.fetches(5);
    rt.r[0] = abi.read32(0x08038238);
    if (!abi.call(decls.func_0803826C, 0x0803820B)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x0803823C);
    if (!abi.call(decls.func_08038260, 0x08038211)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Set up CO/campaign battle summary screen VRAM, palettes, and UI (`0x08038864`).
pub fn func_08038864() callconv(.c) void {
    if (!abi.enter(0x08038864)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[0] = abi.read32(0x080388E4);
    if (!abi.call(decls.func_08010D00, 0x0803886D)) return;

    abi.fetches(9);
    const disp_ptr = abi.read32(0x080388E8);
    abi.write8(disp_ptr, abi.read8(disp_ptr) & 0x7F);
    if (!abi.call(decls.func_08010A00, 0x0803887B)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08010974, 0x0803887F)) return;

    if (!uploadDmaBatch0800(&.{
        .{ .src_pool = 0x080388EC, .dst_pool = 0x080388F0, .ret = 0x0803888D },
        .{ .src_pool = 0x080388F4, .dst_pool = 0x080388F8, .ret = 0x08038897 },
        .{ .src_pool = 0x080388FC, .dst_pool = 0x08038900, .ret = 0x080388A1 },
        .{ .src_pool = 0x08038904, .dst_pool = 0x08038908, .ret = 0x080388AB },
    })) return;

    abi.fetches(5);
    rt.r[0] = 0;
    if (!abi.call(decls.func_08012A14, 0x080388B1)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080221D0, 0x080388B5)) return;
    abi.fetches(5);
    rt.r[0] = 0;
    if (!abi.call(decls.func_080199A0, 0x080388BB)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x0803890C);
    rt.r[1] = 0x140;
    rt.r[2] = 0x20;
    if (!abi.call(decls.func_08011330, 0x080388C7)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_0800FC58, 0x080388CB)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x08038910);
    if (!abi.call(decls.func_0800FC74, 0x080388D1)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x08038914);
    if (!abi.call(decls.func_08038260, 0x080388D7)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x08038918);
    if (!abi.call(decls.func_0803826C, 0x080388DD)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Populate two-side CO/campaign pre-battle comparison state and trigger sound/UI (`0x08038A70`).
pub fn func_08038A70() callconv(.c) void {
    if (!abi.enter(0x08038A70)) return;
    abi.fetches(144);
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
    abi.write32(rt.r[13], rt.r[10]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[9]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[8]);
    rt.r[13] -%= 0x1C;

    const sp = rt.r[13];
    const a0 = rt.r[0] & 0xFF;
    const a1 = rt.r[1] & 0xFF;
    const a2 = rt.r[2] & 0xFF;
    const a3 = rt.r[3] & 0xFF;
    const s3c = abi.read32(sp +% 0x3C) & 0xFF;
    const s40 = abi.read32(sp +% 0x40) & 0xFF;
    const s44 = abi.read32(sp +% 0x44) & 0xFF;
    const s48 = abi.read32(sp +% 0x48) & 0xFF;
    const s4c = abi.read32(sp +% 0x4C) & 0xFF;
    const s50 = abi.read32(sp +% 0x50) & 0xFF;
    const s54 = abi.read32(sp +% 0x54) & 0xFF;
    const s58 = abi.read32(sp +% 0x58) & 0xFF;
    const s5c = abi.read32(sp +% 0x5C) & 0xFF;
    const s60 = abi.read32(sp +% 0x60) & 0xFF;
    const s64 = abi.read32(sp +% 0x64) & 0xFF;
    const s68 = abi.read32(sp +% 0x68) & 0xFF;
    const s6c = abi.read32(sp +% 0x6C) & 0xFFFF;

    abi.write32(sp +% 0x0, s3c);
    abi.write32(sp +% 0x4, s40);
    abi.write32(sp +% 0x8, s44);
    abi.write32(sp +% 0xC, s48);
    abi.write32(sp +% 0x18, s60);
    abi.write32(sp +% 0x10, s68);
    abi.write32(sp +% 0x14, s6c);

    abi.write16(abi.read32(0x08038BD0), 0);
    abi.write16(abi.read32(0x08038BD4), @truncate(s64));

    const buf = abi.read32(0x08038BD8);
    abi.write16(buf +% 0x00, @truncate(a1 -% 1));
    abi.write16(buf +% 0x10, @truncate(s4c -% 1));
    abi.write16(buf +% 0x02, @truncate(a3 -% 1));
    abi.write16(buf +% 0x12, @truncate(s54 -% 1));
    abi.write16(buf +% 0x04, @truncate(s3c));
    abi.write16(buf +% 0x14, @truncate(s58));
    abi.write16(buf +% 0x06, @truncate(a2));
    abi.write16(buf +% 0x16, @truncate(s50));
    abi.write16(buf +% 0x08, @truncate(a0));
    abi.write16(buf +% 0x18, @truncate(s48));
    abi.write16(buf +% 0x0A, @truncate(s40));
    abi.write16(buf +% 0x1A, @truncate(s5c));
    abi.write16(buf +% 0x0C, @truncate(s44));
    abi.write16(buf +% 0x1C, @truncate(s60));

    const co_tbl = abi.read32(0x08038BDC);
    abi.write16(buf +% 0x0E, @truncate(@as(u32, @bitCast(abi.signExtend8(abi.read8(co_tbl +% (a2 *% 20) +% 8))))));
    abi.write16(buf +% 0x1E, @truncate(@as(u32, @bitCast(abi.signExtend8(abi.read8(co_tbl +% (s50 *% 20) +% 8))))));

    const panel = abi.read32(0x08038BE0);
    abi.write8(panel +% 1, 0);
    const panel_refs = abi.read32(0x08038BE4);
    abi.write32(panel_refs +% 0, panel);
    abi.write32(panel_refs +% 4, panel);
    abi.write16(abi.read32(0x08038BE8), @truncate(s68));
    if (!abi.call(decls.func_0805B5AC, 0x08038B8D)) return;

    abi.fetches(27);
    const disp_state = abi.read32(0x08038BEC);
    abi.write8(disp_state, @truncate((1 | @as(u32, abi.read8(disp_state))) & ~@as(u32, 0x7E)));
    abi.write16(disp_state +% 2, @truncate(s6c));
    rt.r[0] = abi.read32(0x08038BF0);
    rt.r[1] = 0;
    if (!abi.call(decls.func_0801320C, 0x08038BBF)) return;

    abi.fetches(10);
    rt.r[13] +%= 0x1C;
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

/// Set up secondary campaign map/overview screen VRAM and sprite pools (`0x08039948`).
pub fn func_08039948() callconv(.c) void {
    if (!abi.enter(0x08039948)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[0] = abi.read32(0x080399A0);
    if (!abi.call(decls.func_08010D00, 0x08039951)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08010A00, 0x08039955)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08010974, 0x08039959)) return;

    if (!uploadDmaBatch0800(&.{
        .{ .src_pool = 0x080399A4, .dst_pool = 0x080399A8, .ret = 0x08039967 },
        .{ .src_pool = 0x080399AC, .dst_pool = 0x080399B0, .ret = 0x08039971 },
        .{ .src_pool = 0x080399B4, .dst_pool = 0x080399B8, .ret = 0x0803997B },
        .{ .src_pool = 0x080399BC, .dst_pool = 0x080399C0, .ret = 0x08039985 },
    })) return;

    abi.fetches(4);
    if (!abi.call(decls.func_080204B4, 0x08039989)) return;
    abi.fetches(5);
    rt.r[0] = 0;
    if (!abi.call(decls.func_0801269C, 0x0803998F)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x080399C4);
    if (!abi.call(decls.func_08038260, 0x08039995)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x080399C8);
    if (!abi.call(decls.func_0803826C, 0x0803999B)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

const CampaignCardCfg = struct {
    stack_bytes: u32,
    init_a0_pool: u32,
    init_a1_pool: u32,
    state_ptr_pool: u32,
    init_stack_pool: u32,
    fade_before: bool,
    gfx0_src_pool: u32,
    gfx0_dst_pool: u32,
    pal_base_pool: u32,
    gfx1_src_pool: ?u32,
    gfx1_dst_pool: ?u32,
    ret_init: u32,
    ret_fade0: u32,
    ret_gfx0: u32,
    ret_pal0: u32,
    ret_pal1: u32,
    ret_gfx1: u32,
    ret_card: u32,
    ret_tail0: u32,
    ret_tail1: u32,
    ret_tail2: u32,
    portrait_args: ?struct {
        pal_tbl_pool: u32,
        ptr_tbl_pool: u32,
        lut_pool: u32,
        ret: u32,
    },
};

fn initCampaignCardDisplay(comptime cfg: CampaignCardCfg) void {
    abi.fetches(15);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= cfg.stack_bytes;

    const state_ptr_ref = abi.read32(cfg.state_ptr_pool);
    rt.r[5] = state_ptr_ref;
    rt.r[0] = abi.read32(cfg.init_a0_pool);
    rt.r[1] = abi.read32(cfg.init_a1_pool);
    rt.r[2] = abi.read8(abi.read32(state_ptr_ref)) >> 3;
    abi.write32(rt.r[13], abi.read32(cfg.init_stack_pool));
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_08010C18, cfg.ret_init)) return;

    if (cfg.fade_before) {
        abi.fetches(5);
        abi.setRegNz(&rt.r[0], 2);
        if (!abi.call(decls.func_080117EC, cfg.ret_fade0)) return;
    }

    abi.fetches(6);
    rt.r[0] = abi.read32(cfg.gfx0_src_pool);
    rt.r[1] = abi.read32(cfg.gfx0_dst_pool);
    if (!abi.call(decls.func_0800FE24, cfg.ret_gfx0)) return;

    abi.fetches(9);
    const pal_base = abi.read32(cfg.pal_base_pool);
    rt.r[4] = pal_base;
    rt.r[0] = pal_base;
    rt.r[1] = 0x2A0;
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, cfg.ret_pal0)) return;

    abi.fetches(9);
    rt.r[4] = pal_base +% 0x40;
    rt.r[0] = pal_base +% 0x40;
    rt.r[1] = 0x2C0;
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, cfg.ret_pal1)) return;

    if (cfg.gfx1_src_pool) |src_pool| {
        abi.fetches(6);
        rt.r[0] = abi.read32(src_pool);
        rt.r[1] = abi.read32(cfg.gfx1_dst_pool.?);
        if (!abi.call(decls.func_0800FE24, cfg.ret_gfx1)) return;
    }

    abi.fetches(7);
    const state = abi.read32(state_ptr_ref);
    rt.r[0] = abi.read8(state);
    rt.r[1] = abi.read32(state +% 4);
    if (!abi.call(decls.func_0803C348, cfg.ret_card)) return;

    if (cfg.portrait_args) |pa| {
        abi.fetches(5);
        abi.setRegNz(&rt.r[0], 0);
        if (!abi.call(decls.func_080117EC, cfg.ret_tail0)) return;

        abi.fetches(4);
        if (!abi.call(decls.func_080221D0, cfg.ret_tail1)) return;

        abi.fetches(27);
        const cur_state = abi.read32(state_ptr_ref);
        const slot_val = (abi.read8(cur_state) >> 3) +% 1;
        const idx_ptr = abi.read32(cur_state +% 4);
        const lut_idx = abi.read8(idx_ptr);
        const slot_off = abi.read8(abi.read32(pa.lut_pool) +% lut_idx);
        const signed_off = abi.signExtend8(slot_off) -% 1;
        const ptr_base = abi.read32(pa.ptr_tbl_pool) +% (@as(u32, @bitCast(signed_off)) << 6);
        rt.r[0] = slot_val;
        rt.r[1] = 0xA;
        rt.r[2] = abi.read32(pa.pal_tbl_pool);
        rt.r[3] = abi.read32(ptr_base);
        abi.write32(rt.r[13], 0x8000);
        abi.write32(rt.r[13] +% 4, 0xF8);
        if (!abi.call(decls.func_080123A8, pa.ret)) return;

        abi.fetches(9);
        abi.write8(rt.r[0] +% 0x3A, 1);
    } else {
        abi.fetches(7);
        const cur_state = abi.read32(state_ptr_ref);
        rt.r[0] = abi.read8(cur_state);
        rt.r[1] = abi.read32(cur_state +% 4);
        if (!abi.call(func_0803C5CC, cfg.ret_tail2)) return;
        abi.fetches(6);
    }

    rt.r[13] +%= cfg.stack_bytes;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Reset campaign map state, setup BG3 window `(7, 1, 15, 16)`, query unlock byte into `[r0 + 0x20]` (`0x0803A480`).
pub fn func_0803A480() callconv(.c) void {
    if (!abi.enter(0x0803A480)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const ctx = rt.r[0];
    rt.r[4] = ctx;
    rt.r[0] = abi.read32(0x0803A4D0);
    if (!abi.call(decls.func_08010D00, 0x0803A48B)) return;

    abi.fetches(8);
    const flags_ptr = abi.read32(0x0803A4D4);
    abi.write8(flags_ptr +% 0xD, 1);
    abi.write8(flags_ptr +% 0x7, 1);
    if (!abi.call(decls.func_080399CC, 0x0803A497)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x0803A4D8);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, 0x0803A49F)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_080129A4, 0x0803A4A5)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_080199A0, 0x0803A4AB)) return;

    abi.fetches(8);
    rt.r[0] = 7;
    rt.r[1] = 1;
    rt.r[2] = 0xF;
    rt.r[3] = 0x10;
    if (!abi.call(decls.func_080197D8, 0x0803A4B7)) return;

    abi.fetches(5);
    rt.r[0] = ctx;
    if (!abi.call(decls.func_0803A38C, 0x0803A4BD)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_0803A2E8, 0x0803A4C1)) return;

    abi.fetches(9);
    const res = (rt.r[0] & 0xFF) -% 1;
    abi.write16(ctx +% 0x20, @truncate(res));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn campaign animator slot via `0x080133C0`, pack OAM attributes from `[sp+4..8]` (`0x0803B548`).
pub fn func_0803B548() callconv(.c) void {
    if (!abi.enter(0x0803B548)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 0xC;

    const x_pos = rt.r[0];
    const anim_idx = rt.r[1];
    rt.r[6] = x_pos;
    rt.r[5] = anim_idx;
    rt.r[0] = abi.read32(0x0803B5CC);
    rt.r[2] = abi.read32(0x0803B5D0);
    abi.setRegNz(&rt.r[1], 0);
    abi.write32(rt.r[13], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_080133C0, 0x0803B55F)) return;

    abi.fetches(9);
    const slot_i32 = abi.signExtend8(@truncate(rt.r[0]));
    const slot: u32 = @bitCast(slot_i32);
    rt.r[4] = slot;
    rt.r[0] = rt.r[13] +% 4;
    rt.r[1] = slot;
    if (!abi.call(decls.func_080135C8, 0x0803B56D)) return;

    abi.fetches(21);
    const oam01 = abi.read32(rt.r[13] +% 4);
    const oam2_in = abi.read32(rt.r[13] +% 8);
    const tile_bits = ((oam2_in & abi.read32(0x0803B5D4)) | (0xC0 << 6)) & abi.read32(0x0803B5E0);
    const pal_bits = ((anim_idx << 3) +% abi.read32(0x0803B5D8)) & abi.read32(0x0803B5DC);
    rt.r[0] = slot;
    rt.r[1] = oam01;
    rt.r[2] = tile_bits | pal_bits;
    if (!abi.call(decls.func_08013598, 0x0803B593)) return;

    abi.fetches(10);
    const sx = abi.signExtend16(@truncate(x_pos +% 0x14));
    rt.r[0] = slot;
    rt.r[1] = @bitCast(sx);
    abi.setRegNz(&rt.r[2], 0x50);
    if (!abi.call(decls.func_08013550, 0x0803B5A3)) return;

    abi.fetches(5);
    rt.r[0] = slot;
    if (!abi.call(decls.func_080147B8, 0x0803B5A9)) return;

    abi.fetches(5);
    rt.r[0] = slot;
    if (!abi.call(decls.func_080148DC, 0x0803B5AF)) return;

    abi.fetches(8);
    rt.r[0] = slot;
    rt.r[1] = 0x200;
    if (!abi.call(decls.func_08013744, 0x0803B5BB)) return;

    abi.fetches(6);
    rt.r[0] = slot;
    rt.r[1] = 0x200;
    if (!abi.call(decls.func_08013794, 0x0803B5C3)) return;

    abi.fetches(6);
    rt.r[13] +%= 0xC;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Initialize campaign card screen without fade (`0x0803C644`).
pub fn func_0803C644() callconv(.c) void {
    if (!abi.enter(0x0803C644)) return;
    initCampaignCardDisplay(.{
        .stack_bytes = 4,
        .init_a0_pool = 0x0803C6A8,
        .init_a1_pool = 0x0803C6AC,
        .state_ptr_pool = 0x0803C6B0,
        .init_stack_pool = 0x0803C6B4,
        .fade_before = false,
        .gfx0_src_pool = 0x0803C6B8,
        .gfx0_dst_pool = 0x0803C6BC,
        .pal_base_pool = 0x0803C6C0,
        .gfx1_src_pool = 0x0803C6C4,
        .gfx1_dst_pool = 0x0803C6C8,
        .ret_init = 0x0803C65F,
        .ret_fade0 = 0,
        .ret_gfx0 = 0x0803C667,
        .ret_pal0 = 0x0803C675,
        .ret_pal1 = 0x0803C683,
        .ret_gfx1 = 0x0803C68B,
        .ret_card = 0x0803C695,
        .ret_tail0 = 0,
        .ret_tail1 = 0,
        .ret_tail2 = 0x0803C69F,
        .portrait_args = null,
    });
}

/// Initialize campaign unlock/portrait screen with fade-in (`0x0803C758`).
pub fn func_0803C758() callconv(.c) void {
    if (!abi.enter(0x0803C758)) return;
    initCampaignCardDisplay(.{
        .stack_bytes = 8,
        .init_a0_pool = 0x0803C7F0,
        .init_a1_pool = 0x0803C7F4,
        .state_ptr_pool = 0x0803C7F8,
        .init_stack_pool = 0x0803C7FC,
        .fade_before = true,
        .gfx0_src_pool = 0x0803C800,
        .gfx0_dst_pool = 0x0803C804,
        .pal_base_pool = 0x0803C808,
        .gfx1_src_pool = null,
        .gfx1_dst_pool = null,
        .ret_init = 0x0803C773,
        .ret_fade0 = 0x0803C779,
        .ret_gfx0 = 0x0803C781,
        .ret_pal0 = 0x0803C78F,
        .ret_pal1 = 0x0803C79D,
        .ret_gfx1 = 0,
        .ret_card = 0x0803C7A7,
        .ret_tail0 = 0x0803C7AD,
        .ret_tail1 = 0x0803C7B1,
        .ret_tail2 = 0,
        .portrait_args = .{
            .pal_tbl_pool = 0x0803C80C,
            .ptr_tbl_pool = 0x0803C810,
            .lut_pool = 0x0803C814,
            .ret = 0x0803C7E3,
        },
    });
}

/// Set up campaign map backdrop tilesets via 4 `0x800`-byte transfers and initialize world layers (`0x0803DA20`).
pub fn func_0803DA20() callconv(.c) void {
    if (!abi.enter(0x0803DA20)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[0] = abi.read32(0x0803DA74);
    if (!abi.call(decls.func_08010D00, 0x0803DA29)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08010A00, 0x0803DA2D)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08010974, 0x0803DA31)) return;

    if (!uploadDmaBatch0800(&.{
        .{ .src_pool = 0x0803DA78, .dst_pool = 0x0803DA7C, .ret = 0x0803DA3F },
        .{ .src_pool = 0x0803DA80, .dst_pool = 0x0803DA84, .ret = 0x0803DA49 },
        .{ .src_pool = 0x0803DA88, .dst_pool = 0x0803DA8C, .ret = 0x0803DA53 },
        .{ .src_pool = 0x0803DA90, .dst_pool = 0x0803DA94, .ret = 0x0803DA5D },
    })) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_080199A0, 0x0803DA63)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x0803DA98);
    if (!abi.call(decls.func_08038260, 0x0803DA69)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x0803DA9C);
    if (!abi.call(decls.func_0803826C, 0x0803DA6F)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn campaign cursor/icon animator slot at `(0xAA, 0x20)` with OAM flags `0x4074` (`0x0803D680`).
pub fn func_0803D680() callconv(.c) void {
    if (!abi.enter(0x0803D680)) return;
    abi.fetches(11);
    abi.pushLr();
    abi.pushReg(5);
    abi.pushReg(4);
    rt.r[13] -%= 0xC;
    abi.write32(rt.r[13] +% 0x0, 0);
    rt.r[0] = abi.read32(0x0803D6F0);
    rt.r[1] = 0;
    rt.r[2] = abi.read32(0x0803D6F4);
    rt.r[3] = 0;
    rt.updateNz(0);
    if (!abi.call(decls.func_080133C0, 0x0803D693)) return;

    abi.fetches(9);
    const slot: u32 = @bitCast(abi.signExtend8(@truncate(rt.r[0])));
    rt.r[4] = slot;
    rt.r[0] = rt.r[13] +% 0x4;
    rt.r[1] = slot;
    if (!abi.call(decls.func_080135C8, 0x0803D6A1)) return;

    abi.fetches(17);
    rt.r[1] = abi.read32(rt.r[13] +% 0x4);
    const old_flags = abi.read32(rt.r[13] +% 0x8);
    const flags = ((old_flags & abi.read32(0x0803D6F8)) | (0x80 << 7)) & abi.read32(0x0803D6FC) | 0x74;
    rt.r[0] = slot;
    rt.r[2] = flags;
    rt.updateNz(flags);
    if (!abi.call(decls.func_08013598, 0x0803D6BF)) return;

    abi.fetches(7);
    rt.r[0] = slot;
    rt.r[1] = 0xAA;
    rt.r[2] = 0x20;
    rt.updateNz(0x20);
    if (!abi.call(decls.func_08013550, 0x0803D6C9)) return;

    abi.fetches(5);
    rt.r[0] = slot;
    if (!abi.call(decls.func_080147B8, 0x0803D6CF)) return;

    abi.fetches(5);
    rt.r[0] = slot;
    if (!abi.call(decls.func_080148DC, 0x0803D6D5)) return;

    abi.fetches(10);
    rt.r[5] = 0x200;
    rt.r[0] = slot;
    rt.r[1] = 0x200;
    if (!abi.call(decls.func_08013744, 0x0803D6E1)) return;

    abi.fetches(6);
    rt.r[0] = slot;
    rt.r[1] = 0x200;
    if (!abi.call(decls.func_08013794, 0x0803D6E9)) return;

    abi.fetches(6);
    rt.r[13] +%= 0xC;
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
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
        @export(&func_0803B3DC, .{ .name = "func_0803B3DC", .linkage = .strong });
        @export(&func_0803B3F8, .{ .name = "func_0803B3F8", .linkage = .strong });
        @export(&func_0803B4D8, .{ .name = "func_0803B4D8", .linkage = .strong });
        @export(&func_0803CF1C, .{ .name = "func_0803CF1C", .linkage = .strong });
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
        @export(&func_08038694, .{ .name = "func_08038694", .linkage = .strong });
        @export(&func_08038C44, .{ .name = "func_08038C44", .linkage = .strong });
        @export(&func_08038D0C, .{ .name = "func_08038D0C", .linkage = .strong });
        @export(&func_08038D60, .{ .name = "func_08038D60", .linkage = .strong });
        @export(&func_080398EC, .{ .name = "func_080398EC", .linkage = .strong });
        @export(&func_08039918, .{ .name = "func_08039918", .linkage = .strong });
        @export(&func_0803C5CC, .{ .name = "func_0803C5CC", .linkage = .strong });
        @export(&func_0803C6CC, .{ .name = "func_0803C6CC", .linkage = .strong });
        @export(&func_0803CCD0, .{ .name = "func_0803CCD0", .linkage = .strong });
        @export(&func_0803CD40, .{ .name = "func_0803CD40", .linkage = .strong });
        @export(&func_0803D5B0, .{ .name = "func_0803D5B0", .linkage = .strong });
        @export(&func_0803DB9C, .{ .name = "func_0803DB9C", .linkage = .strong });
        @export(&func_0803E514, .{ .name = "func_0803E514", .linkage = .strong });
        @export(&func_0803F244, .{ .name = "func_0803F244", .linkage = .strong });
        @export(&func_0803F2C8, .{ .name = "func_0803F2C8", .linkage = .strong });
        @export(&func_080381C4, .{ .name = "func_080381C4", .linkage = .strong });
        @export(&func_08038864, .{ .name = "func_08038864", .linkage = .strong });
        @export(&func_08038A70, .{ .name = "func_08038A70", .linkage = .strong });
        @export(&func_08039948, .{ .name = "func_08039948", .linkage = .strong });
        @export(&func_0803A480, .{ .name = "func_0803A480", .linkage = .strong });
        @export(&func_0803B548, .{ .name = "func_0803B548", .linkage = .strong });
        @export(&func_0803C644, .{ .name = "func_0803C644", .linkage = .strong });
        @export(&func_0803C758, .{ .name = "func_0803C758", .linkage = .strong });
        @export(&func_0803DA20, .{ .name = "func_0803DA20", .linkage = .strong });
        @export(&func_0803D680, .{ .name = "func_0803D680", .linkage = .strong });
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
