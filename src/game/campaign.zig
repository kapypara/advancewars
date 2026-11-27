//! Lifted Advance Wars campaign/save unlock bitsets (`0x0201_F9A8`) and mission record accessors (`0x0201_F9F0`).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
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

comptime {
    if (!builtin.is_test) {
        @export(&func_0803E37C, .{ .name = "func_0803E37C", .linkage = .strong });
        @export(&func_0803E39C, .{ .name = "func_0803E39C", .linkage = .strong });
        @export(&func_0803E538, .{ .name = "func_0803E538", .linkage = .strong });
        @export(&func_0803E53C, .{ .name = "func_0803E53C", .linkage = .strong });
        @export(&func_0803E5F0, .{ .name = "func_0803E5F0", .linkage = .strong });
        @export(&func_0803EEBC, .{ .name = "func_0803EEBC", .linkage = .strong });
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
