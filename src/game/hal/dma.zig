//! GBA DMA transfer & VBlank deferred copy queue abstraction submodule.

const std = @import("std");
const bios = @import("bios.zig");
const mem = @import("../mem.zig");
const types = @import("../types.zig");

pub const QueueEntry = types.DmaQueueEntry;
pub const queue_cap: usize = types.dma_queue_cap;

pub inline fn byteCountToHalfwords(byte_count: u32) u32 {
    return (byte_count & 0xFFFF) >> 1;
}

pub inline fn byteCountToWords(byte_count: u32) u32 {
    return (byte_count & 0xFFFF) >> 2;
}

pub inline fn isFastCopyAligned(size_bytes: u32) bool {
    return (size_bytes & 0x1F) == 0;
}

pub inline fn copy16(src: u32, dst: u32, size_bytes: u32) void {
    bios.cpuSet(src, dst, byteCountToHalfwords(size_bytes));
}

pub inline fn fastCopy32(src: u32, dst: u32, size_bytes: u32) void {
    bios.cpuFastSet(src, dst, byteCountToWords(size_bytes));
}

pub inline fn copyAuto(src: u32, dst: u32, size_bytes: u32) void {
    if (isFastCopyAligned(size_bytes)) {
        fastCopy32(src, dst, size_bytes);
    } else {
        copy16(src, dst, size_bytes);
    }
}

pub inline fn readImmediateFlag() u16 {
    return mem.readU16(types.addr.dma_immediate_flag);
}

pub inline fn isImmediateMode() bool {
    return readImmediateFlag() != 0;
}

pub inline fn readQueueCount() u16 {
    return mem.readU16(types.addr.dma_queue_count);
}

pub inline fn writeQueueCount(count: u16) void {
    mem.writeU16(types.addr.dma_queue_count, count);
}

pub inline fn queueEntryAddr(index: u16) u32 {
    return types.addr.dma_queue_buf +% @as(u32, @bitCast(@as(i32, @as(i16, @bitCast(index))) * @as(i32, @sizeOf(QueueEntry))));
}

pub inline fn writeQueueEntry(index: u16, src: u32, dst: u32, size: u16, mode: u8) u8 {
    const entry_addr = queueEntryAddr(index);
    mem.writeU32(entry_addr +% @offsetOf(QueueEntry, "src"), src);
    mem.writeU32(entry_addr +% @offsetOf(QueueEntry, "dst"), dst);
    mem.writeU16(entry_addr +% @offsetOf(QueueEntry, "size"), size);
    const old_mode = mem.readU8(entry_addr +% @offsetOf(QueueEntry, "mode"));
    mem.writeU8(entry_addr +% @offsetOf(QueueEntry, "mode"), mode);
    return old_mode;
}

test "hal.dma transfer sizing and queue entry addressing" {
    try std.testing.expectEqual(@as(u32, 0x20), byteCountToHalfwords(0x40));
    try std.testing.expectEqual(@as(u32, 0x1C0), byteCountToWords(0x700));
    try std.testing.expect(isFastCopyAligned(0x200));
    try std.testing.expect(!isFastCopyAligned(0x204));
    try std.testing.expectEqual(types.addr.dma_queue_buf, queueEntryAddr(0));
    try std.testing.expectEqual(types.addr.dma_queue_buf + 12, queueEntryAddr(1));
    try std.testing.expectEqual(types.addr.dma_queue_buf + 47 * 12, queueEntryAddr(47));
}
