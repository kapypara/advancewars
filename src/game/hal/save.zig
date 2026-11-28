//! GBA cartridge Flash (`0x0E00_0000`) & save bitset abstraction submodule.

const std = @import("std");
const mem = @import("../mem.zig");
const types = @import("../types.zig");

pub const flash_base: u32 = 0x0E00_0000;
pub const flash_size_64k: u32 = 0x1_0000;
pub const flash_sector_size: u32 = 0x1000;
pub const flash_cmd_unlock_1: u8 = 0xAA;
pub const flash_cmd_unlock_2: u8 = 0x55;
pub const flash_cmd_erase_setup: u8 = 0x80;
pub const flash_cmd_erase_chip: u8 = 0x10;
pub const flash_cmd_erase_sector: u8 = 0x30;
pub const save_flags_block_bytes: usize = 36;

pub const BitLocation = struct { addr: u32, shift: u3, mask: u8 };

pub inline fn writeFlashUnlockCmd(cmd_aa_addr: u32, cmd_55_addr: u32, opcode: u8) void {
    mem.writeU8(cmd_aa_addr, flash_cmd_unlock_1);
    mem.writeU8(cmd_55_addr, flash_cmd_unlock_2);
    mem.writeU8(cmd_aa_addr, flash_cmd_erase_setup);
    mem.writeU8(cmd_aa_addr, flash_cmd_unlock_1);
    mem.writeU8(cmd_55_addr, flash_cmd_unlock_2);
    mem.writeU8(cmd_aa_addr, opcode);
}

pub inline fn readByte(offset: u16) u8 {
    return mem.readU8(flash_base + offset);
}

pub inline fn writeByte(offset: u16, val: u8) void {
    mem.writeU8(flash_base + offset, val);
}

pub inline fn sectorOffset(sector: u4) u32 {
    return @as(u32, sector) * flash_sector_size;
}

pub inline fn bitLocation(base: u32, byte_off: u32, bit_idx: u32) BitLocation {
    const shift: u3 = @truncate(bit_idx & 7);
    return .{
        .addr = base +% byte_off +% (bit_idx >> 3),
        .shift = shift,
        .mask = @as(u8, 1) << shift,
    };
}

test "hal.save Flash geometry and bitLocation addressing" {
    try std.testing.expectEqual(@as(u32, 0), sectorOffset(0));
    try std.testing.expectEqual(@as(u32, 0xF000), sectorOffset(15));
    try std.testing.expectEqual(flash_size_64k, 16 * flash_sector_size);

    const loc = bitLocation(types.addr.save_flags, 0x1A, 9);
    try std.testing.expectEqual(@as(u32, types.addr.save_flags + 0x1B), loc.addr);
    try std.testing.expectEqual(@as(u3, 1), loc.shift);
    try std.testing.expectEqual(@as(u8, 0x02), loc.mask);
}
