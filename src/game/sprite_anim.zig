//! Lifted proc sprite/animator pool (`0x0300_2320`, stride `0x4C`) and OAM queue helpers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const abi = @import("abi.zig");
const types = @import("types.zig");

/// Compute address of animator struct owned by proc `proc_idx` (`(proc.anim_slot) * 0x4C`).
pub inline fn resolveAnimAddr(proc_base: u32, anim_base: u32, proc_idx: i16) u32 {
    const proc_off: u32 = @bitCast(@as(i32, proc_idx) *% @as(i32, types.proc_slot_stride));
    const slot_idx = abi.read16(proc_base +% proc_off +% 0x26);
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
    const anim_base = abi.read32(0x080135C0);
    const proc_base = abi.read32(0x080135C4);
    const proc_idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const proc_off: u32 = @bitCast(@as(i32, proc_idx) *% 0x60);
    const slot_idx = abi.read16(proc_base +% proc_off +% 0x26);
    const anim = anim_base +% @as(u32, slot_idx) *% @as(u32, types.anim_slot_stride);
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
    const queue_base = abi.read32(0x08014CFC);
    const entry = queue_base +% (rt.r[0] << 4);
    abi.write16(entry +% 0x6, @truncate(rt.r[1]));
    abi.write16(entry +% 0x8, @truncate(rt.r[2]));
    abi.write16(entry +% 0xA, @truncate(rt.r[3]));
    rt.r[0] = rt.r[14];
    rt.recompReturn(rt.r[14]);
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
    const table_base = abi.read32(0x08014BA4);
    const base_slot = rt.r[0] << 4;

    abi.write16(table_base +% ((base_slot +% 3) << 1), @truncate(rt.r[1]));
    abi.write16(table_base +% ((base_slot +% 7) << 1), @truncate(rt.r[2]));
    const old2 = abi.read16(table_base +% ((base_slot +% 11) << 1));
    abi.write16(table_base +% ((base_slot +% 11) << 1), @truncate(rt.r[3]));
    const old3 = abi.read16(table_base +% ((base_slot +% 15) << 1));
    abi.write16(table_base +% ((base_slot +% 15) << 1), arg3);

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
    const anim_base = abi.read32(0x0801A104);
    const slot = (rt.r[0] *% @as(u32, types.anim_slot_stride)) +% anim_base;
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
    const anim_base = abi.read32(0x0801A1B8);
    const slot = (rt.r[0] *% @as(u32, types.anim_slot_stride)) +% anim_base;
    rt.r[1] = anim_base;
    rt.r[0] = abi.read32(slot +% 0x2C);
    abi.retLr();
}

/// Read and clear animator `+0x2C` word for slot `r0` (`0x0801A1BC`).
pub fn func_0801A1BC() callconv(.c) void {
    if (!abi.enter(0x0801A1BC)) return;
    abi.fetches(10);
    const anim_base = abi.read32(0x0801A1CC);
    const slot = (rt.r[0] *% @as(u32, types.anim_slot_stride)) +% anim_base;
    const prev = abi.read32(slot +% 0x2C);
    abi.write32(slot +% 0x2C, 0);
    rt.r[0] = prev;
    rt.r[1] = slot;
    abi.setRegNz(&rt.r[2], 0);
    abi.retLr();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08011CF0, .{ .name = "func_08011CF0", .linkage = .strong });
        @export(&func_08013598, .{ .name = "func_08013598", .linkage = .strong });
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
        @export(&func_08014CE8, .{ .name = "func_08014CE8", .linkage = .strong });
        @export(&func_0801A0EC, .{ .name = "func_0801A0EC", .linkage = .strong });
        @export(&func_0801A1AC, .{ .name = "func_0801A1AC", .linkage = .strong });
        @export(&func_0801A1BC, .{ .name = "func_0801A1BC", .linkage = .strong });
    }
}

test "animator and OAM queue strides match GBA pool layout" {
    _ = finishPoppedLr;
    try std.testing.expectEqual(@as(usize, 0x4C), types.anim_slot_stride);
    try std.testing.expectEqual(@as(usize, 0x10), types.oam_queue_stride);
    try std.testing.expectEqual(@as(u32, 0x0300_2320), types.addr.anim_pool);
    try std.testing.expectEqual(@as(u32, 0x0201_1D24), types.addr.oam_queue);
}
