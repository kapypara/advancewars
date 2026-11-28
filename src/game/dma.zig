//! Lifted CpuSet / CpuFastSet memory copy wrappers and hardware flag helpers.

const std = @import("std");
const rt = @import("runtime");
const abi = @import("abi.zig");
const bios = @import("bios.zig");
const hw = @import("hw.zig");
const low_peel_3 = @import("low_peel_3.zig");
const low_peel_6 = @import("low_peel_6.zig");
const types = @import("types.zig");

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

/// Return true when `size_bytes` (`u16`) is a multiple of 32 bytes for `CpuFastSet`.
pub inline fn isFastCopyAligned(size_bytes: u32) bool {
    return (size_bytes & 0x1F) == 0;
}

/// [Phase 4 API — uncalled while func_0800FDA4 preserves exact abi.fetches/SWI branches]
/// Copy `size_bytes` from `src` to `dst` via `CpuFastSet` when 32-byte aligned, else `CpuSet` (`0x0800FDA4`).
pub fn cpuCopyAuto(src: u32, dst: u32, size_bytes: u32) void {
    if (isFastCopyAligned(size_bytes)) {
        cpuFastCopy32(src, dst, size_bytes);
    } else {
        cpuCopy16(src, dst, size_bytes);
    }
}

/// Typed cross-module bridge calling `func_0800FDA4(src, dst, size_bytes)` with exact ABI registers.
pub inline fn copyAutoCall(src: u32, dst: u32, size_bytes: u32, comptime ret_addr: u32) bool {
    rt.r[0] = src;
    abi.setRegNz(&rt.r[1], dst);
    abi.setRegNz(&rt.r[2], size_bytes);
    return abi.call(func_0800FDA4, ret_addr);
}

/// Typed cross-module bridge calling `func_0800FFA8(src, dst, size_bytes)` with exact ABI registers.
pub inline fn enqueueOrCopyCall(src: u32, dst: u32, size_bytes: u32, comptime ret_addr: u32) bool {
    rt.r[0] = src;
    abi.setRegNz(&rt.r[1], dst);
    abi.setRegNz(&rt.r[2], size_bytes);
    return abi.call(func_0800FFA8, ret_addr);
}

/// Typed cross-module bridge calling masked palette copy & commit helper `func_08011330` with exact ABI state.
pub inline fn copyPaletteCall(comptime ret_addr: u32) bool {
    return abi.call(func_08011330, ret_addr);
}

/// Typed cross-module bridge forwarding existing register state to `func_0800FDA4` (`cpuCopyAuto`).
pub inline fn copyAutoAbiCall(comptime ret_addr: u32) bool {
    return abi.call(func_0800FDA4, ret_addr);
}

/// Typed cross-module bridge forwarding existing register state to `func_0800FFA8` (VBlank DMA queue/copy).
pub inline fn enqueueOrCopyAbiCall(comptime ret_addr: u32) bool {
    return abi.call(func_0800FFA8, ret_addr);
}

/// Typed cross-module bridge copying checked VRAM/palette data (`func_0800FE24`).
pub inline fn copyVramCheckedCall(comptime ret_addr: u32) bool {
    return abi.call(low_peel_3.func_0800FE24, ret_addr);
}

/// Typed cross-module bridge copying OAM or tile data (`func_0800FADC`).
pub inline fn copyOamOrTilesCall(comptime ret_addr: u32) bool {
    return abi.call(low_peel_6.func_0800FADC, ret_addr);
}

/// Copy `u16(r2)` bytes from `r0` to `r1` using `CpuFastSet` if 32-byte aligned, else `CpuSet` (`0x0800FDA4`).
pub fn func_0800FDA4() callconv(.c) void {
    if (!abi.enter(0x0800FDA4)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.cpuAdd(&rt.r[3], rt.r[0], 0, true);
    abi.setRegNz(&rt.r[2], rt.r[2] << 16);
    abi.setRegNz(&rt.r[0], 0xF8);
    abi.setRegNz(&rt.r[0], rt.r[0] << 13);
    abi.setRegNz(&rt.r[0], rt.r[0] & rt.r[2]);
    rt.cpuSub(null, rt.r[0], 0, true);
    if (rt.CPU_Z) {
        abi.fetches(6);
        abi.setRegNz(&rt.r[2], rt.r[2] >> 18);
        rt.cpuAdd(&rt.r[0], rt.r[3], 0, true);
        if (!abi.call(bios.func_080796C0, 0x0800FDC7)) return;
    } else {
        abi.fetches(6);
        abi.setRegNz(&rt.r[2], rt.r[2] >> 17);
        rt.cpuAdd(&rt.r[0], rt.r[3], 0, true);
        if (!abi.call(bios.func_080796C4, 0x0800FDBD)) return;
        abi.fetches(3);
    }
    abi.fetches(4);
    rt.r[0] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[15] = rt.r[0];
    rt.recompReturn(rt.r[0]);
}

/// Enqueue a `size_bytes` (`r2`) copy from `r0` (`src`) to `r1` (`dst`) in the VBlank DMA queue,
/// or execute immediately via `func_0800FDA4` when `[addr.dma_immediate_flag]` is non-zero (`0x0800FFA8`).
pub fn func_0800FFA8() callconv(.c) void {
    if (!abi.enter(0x0800FFA8)) return;
    abi.fetches(12);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.cpuAdd(&rt.r[3], rt.r[0], 0, true);
    rt.cpuAdd(&rt.r[5], rt.r[1], 0, true);
    abi.setRegNz(&rt.r[2], rt.r[2] << 16);
    abi.setRegNz(&rt.r[2], rt.r[2] >> 16);
    rt.cpuAdd(&rt.r[6], rt.r[2], 0, true);

    const imm = abi.read16(types.addr.dma_immediate_flag);
    rt.r[0] = imm;
    rt.cpuSub(null, rt.r[0], 0, true);
    if (!rt.CPU_Z) {
        abi.fetches(5);
        rt.cpuAdd(&rt.r[0], rt.r[3], 0, true);
        if (!abi.call(func_0800FDA4, 0x0800FFC3)) return;
        abi.fetches(4);
        abi.setRegNz(&rt.r[0], 0);
    } else {
        abi.fetches(6);
        const count_addr = types.addr.dma_queue_count;
        rt.r[4] = count_addr;
        const prev_count = abi.read16(count_addr);
        rt.r[0] = prev_count;
        rt.cpuSub(null, rt.r[0], types.dma_queue_cap, true);
        if (rt.CPU_Z) {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 1);
            rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
        } else {
            abi.fetches(59);
            const buf_base = types.addr.dma_queue_buf;
            const entry_off = @as(u32, @bitCast(@as(i32, @as(i16, @bitCast(prev_count))) * @as(i32, @sizeOf(types.DmaQueueEntry))));
            const entry_addr = buf_base +% entry_off;
            abi.write32(entry_addr +% @offsetOf(types.DmaQueueEntry, "src"), rt.r[3]);
            abi.write32(entry_addr +% @offsetOf(types.DmaQueueEntry, "dst"), rt.r[5]);
            abi.write16(entry_addr +% @offsetOf(types.DmaQueueEntry, "size"), @truncate(rt.r[6]));
            const old_mode = abi.read8(entry_addr +% @offsetOf(types.DmaQueueEntry, "mode"));
            abi.write8(entry_addr +% @offsetOf(types.DmaQueueEntry, "mode"), 0);

            const next_count: u16 = prev_count +% 1;
            abi.write16(count_addr, next_count);
            rt.r[2] = buf_base;
            rt.r[1] = old_mode;
            rt.r[3] = 0;
            rt.cpuSub(&rt.r[0], next_count, 1, true);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[0], rt.asrConst(rt.r[0], 16));
        }
    }

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[15] = rt.r[1];
    rt.recompReturn(rt.r[1]);
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
    if (!abi.call(func_0800FD94, ret_addr)) return;
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
    if (!abi.call(func_0800FDA4, 0x0800F8A3)) return;
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
    if (!abi.call(func_0800FFA8, 0x08017903)) return;
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
    if (!abi.call(func_0800FDA4, 0x0803C33B)) return;
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
    if (!abi.call(func_0800FD94, ret_copy)) return;

    abi.fetches(4);
    if (!abi.call(hw.func_080112C0, ret_sync)) return;

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
    if (!abi.call(func_0800FD94, 0x080113B7)) return;

    abi.fetches(10);
    rt.r[5] +%= types.addr.pal_ram;
    rt.r[0] = rt.r[6];
    rt.r[1] = rt.r[5];
    rt.r[2] = rt.r[4];
    if (!abi.call(func_0800FD94, 0x080113C7)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}


test "CpuSet and CpuFastSet transfer size conversions truncate cleanly to u16 counts" {
    try std.testing.expectEqual(@as(u32, 0x1C0), byteCountToWords(0x700));
    try std.testing.expectEqual(@as(u32, 0x20), byteCountToHalfwords(0x40));
    try std.testing.expectEqual(@as(u32, 0), byteCountToWords(0x1_0000));
    try std.testing.expect(isFastCopyAligned(0x200));
    try std.testing.expect(!isFastCopyAligned(0x204));
    try std.testing.expectEqual(@as(usize, 12), @sizeOf(types.DmaQueueEntry));
}

test "dma typed call bridges have expected inline signatures" {
    inline for (.{ copyPaletteCall, copyAutoAbiCall, enqueueOrCopyAbiCall, copyVramCheckedCall, copyOamOrTilesCall }) |bridge| {
        const info = @typeInfo(@TypeOf(bridge)).@"fn";
        try std.testing.expectEqual(@as(usize, 1), info.param_types.len);
        try std.testing.expect(info.param_types[0].? == u32);
        try std.testing.expect(info.return_type.? == bool);
    }
}
