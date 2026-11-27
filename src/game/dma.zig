//! Lifted CpuSet / CpuFastSet memory copy wrappers and hardware flag helpers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const bios = @import("bios.zig");

/// Convert a byte count (`u16`) to halfword transfer count (`>> 1`) for `CpuSet`.
pub inline fn byteCountToHalfwords(byte_count: u32) u32 {
    return (byte_count & 0xFFFF) >> 1;
}

/// Convert a byte count (`u16`) to word transfer count (`>> 2`) for `CpuFastSet`.
pub inline fn byteCountToWords(byte_count: u32) u32 {
    return (byte_count & 0xFFFF) >> 2;
}

/// Copy `size_bytes` from `src` to `dst` via `CpuSet` 16-bit transfers (`0x0800FD94`).
pub fn cpuCopy16(src: u32, dst: u32, size_bytes: u32) void {
    bios.cpuSet(src, dst, byteCountToHalfwords(size_bytes));
}

pub fn func_0800FD94() callconv(.c) void {
    if (!abi.enter(0x0800FD94)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[2], byteCountToHalfwords(rt.r[2]));
    if (!abi.call(bios.func_080796C4, 0x0800FD9F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Copy `size_bytes` from `src` to `dst` via `CpuFastSet` 32-bit transfers (`0x0800FDCC`).
pub fn cpuFastCopy32(src: u32, dst: u32, size_bytes: u32) void {
    bios.cpuFastSet(src, dst, byteCountToWords(size_bytes));
}

pub fn func_0800FDCC() callconv(.c) void {
    if (!abi.enter(0x0800FDCC)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[2], byteCountToWords(rt.r[2]));
    if (!abi.call(bios.func_080796C0, 0x0800FDD7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Set flag bit `0x10` in the byte addressed by `[0x08010AD4]` (`0x08010AC8`).
pub fn func_08010AC8() callconv(.c) void {
    if (!abi.enter(0x08010AC8)) return;
    abi.fetches(8);
    const target_addr = abi.read32(0x08010AD4);
    const prev = abi.read8(target_addr);
    const next: u32 = 0x10 | @as(u32, prev);
    rt.r[1] = target_addr;
    rt.r[2] = prev;
    abi.setRegNz(&rt.r[0], next);
    abi.write8(target_addr, @truncate(next));
    abi.retLr();
}

fn copyMaskedHalfwords(comptime mask_ref: u32, comptime base_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(12);
    abi.pushLr();
    const masked = rt.r[1] & abi.read32(mask_ref);
    const base = abi.read32(base_ref);
    rt.r[3] = base;
    rt.r[1] = masked +% base;
    rt.r[2] &= 0xFFFF;
    if (!abi.call(decls.func_0800FD94, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Bulk-copy `0x800` bytes from `0x0800F8A8` to `0x0800F8AC` via `0x0800FDA4` (`0x0800F894`).
pub fn func_0800F894() callconv(.c) void {
    if (!abi.enter(0x0800F894)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0800F8A8);
    rt.r[1] = abi.read32(0x0800F8AC);
    abi.setRegNz(&rt.r[2], 0x800);
    if (!abi.call(decls.func_0800FDA4, 0x0800F8A3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Copy `u16(r2)` halfwords from `r0` to masked VRAM offset `0x08011328`/`0x0801132C` (`0x08011310`).
pub fn func_08011310() callconv(.c) void {
    if (!abi.enter(0x08011310)) return;
    copyMaskedHalfwords(0x08011328, 0x0801132C, 0x08011325);
}

/// Copy `u16(r2)` halfwords from `r0` to masked VRAM offset `0x0801136C`/`0x08011370` (`0x08011354`).
pub fn func_08011354() callconv(.c) void {
    if (!abi.enter(0x08011354)) return;
    copyMaskedHalfwords(0x0801136C, 0x08011370, 0x08011369);
}

/// Copy `0x200` bytes from `0x08017908` to `0x0801790C` via `0x0800FFA8` (`0x080178F4`).
pub fn func_080178F4() callconv(.c) void {
    if (!abi.enter(0x080178F4)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08017908);
    rt.r[1] = abi.read32(0x0801790C);
    abi.setRegNz(&rt.r[2], 0x200);
    if (!abi.call(decls.func_0800FFA8, 0x08017903)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Bulk-copy `0x800` bytes from `0x0803C340` to `0x0803C344` via `0x0800FDA4` (`0x0803C32C`).
pub fn func_0803C32C() callconv(.c) void {
    if (!abi.enter(0x0803C32C)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0803C340);
    rt.r[1] = abi.read32(0x0803C344);
    abi.setRegNz(&rt.r[2], 0x800);
    if (!abi.call(decls.func_0800FDA4, 0x0803C33B)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn copyMaskedPaletteAndSync(comptime mask_ref: u32, comptime base_ref: u32, comptime ret_copy: u32, comptime ret_sync: u32) void {
    abi.fetches(12);
    abi.pushLr();
    const masked = rt.r[1] & abi.read32(mask_ref);
    const base = abi.read32(base_ref);
    rt.r[3] = base;
    rt.r[1] = masked +% base;
    rt.r[2] &= 0xFFFF;
    if (!abi.call(decls.func_0800FD94, ret_copy)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_080112C0, ret_sync)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Copy `u16(r2)` halfwords from `r0` to masked BG/OBJ palette `0x0801134C`/`0x08011350` and commit (`0x08011330`).
pub fn func_08011330() callconv(.c) void {
    if (!abi.enter(0x08011330)) return;
    copyMaskedPaletteAndSync(0x0801134C, 0x08011350, 0x08011345, 0x08011349);
}

/// Copy `u16(r2)` halfwords from `r0` to masked palette mirror `0x08011390`/`0x08011394` and commit (`0x08011374`).
pub fn func_08011374() callconv(.c) void {
    if (!abi.enter(0x08011374)) return;
    copyMaskedPaletteAndSync(0x08011390, 0x08011394, 0x08011389, 0x0801138D);
}

/// Copy `u16(r2)` palette entries from `r0` into both shadow buffer `[0x080113CC]` and HW palette RAM `0x0500_0000` (`0x08011398`).
pub fn func_08011398() callconv(.c) void {
    if (!abi.enter(0x08011398)) return;
    abi.fetches(17);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[6] = rt.r[0];
    rt.r[4] = rt.r[2] & 0xFFFF;
    const slot_off = rt.r[1] << 16;
    rt.r[5] = slot_off >> 16;
    const align_off = (slot_off >> 17) << 1;
    rt.r[1] = align_off +% abi.read32(0x080113CC);
    rt.r[2] = rt.r[4];
    if (!abi.call(decls.func_0800FD94, 0x080113B7)) return;

    abi.fetches(10);
    rt.r[5] +%= @as(u32, 0xA0) << 19;
    rt.r[0] = rt.r[6];
    rt.r[1] = rt.r[5];
    rt.r[2] = rt.r[4];
    if (!abi.call(decls.func_0800FD94, 0x080113C7)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_0800F894, .{ .name = "func_0800F894", .linkage = .strong });
        @export(&func_08011330, .{ .name = "func_08011330", .linkage = .strong });
        @export(&func_08011374, .{ .name = "func_08011374", .linkage = .strong });
        @export(&func_08011398, .{ .name = "func_08011398", .linkage = .strong });
        @export(&func_0800FD94, .{ .name = "func_0800FD94", .linkage = .strong });
        @export(&func_0800FDCC, .{ .name = "func_0800FDCC", .linkage = .strong });
        @export(&func_08010AC8, .{ .name = "func_08010AC8", .linkage = .strong });
        @export(&func_08011310, .{ .name = "func_08011310", .linkage = .strong });
        @export(&func_08011354, .{ .name = "func_08011354", .linkage = .strong });
        @export(&func_080178F4, .{ .name = "func_080178F4", .linkage = .strong });
        @export(&func_0803C32C, .{ .name = "func_0803C32C", .linkage = .strong });
    }
}

test "CpuSet and CpuFastSet transfer size conversions truncate cleanly to u16 counts" {
    try std.testing.expectEqual(@as(u32, 0x1C0), byteCountToWords(0x700));
    try std.testing.expectEqual(@as(u32, 0x20), byteCountToHalfwords(0x40));
    try std.testing.expectEqual(@as(u32, 0), byteCountToWords(0x1_0000));
}
