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
