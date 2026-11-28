//! Unified Hardware Abstraction Layer (HAL) for GBA BIOS/SWI and platform interfaces.
//! Phase 5A routes all 23 BIOS `abi.swi(...)` call sites through `hal.bios.*`.
//! Phase 5B centralizes `KEYINPUT` (`0x0400_0130`) polling and Flash (`0x0E00_0000`) / save bitset interfaces through `hal.input.*` and `hal.save.*`.

const std = @import("std");
const rt = @import("runtime");
const mem = @import("mem.zig");
const types = @import("types.zig");

/// GBA BIOS software interrupt opcodes invoked by Advance Wars.
pub const Swi = enum(u8) {
    soft_reset = 0x00,
    register_ram_reset = 0x01,
    div = 0x06,
    cpu_set = 0x0B,
    cpu_fast_set = 0x0C,
    bg_affine_set = 0x0E,
    lz77_uncomp_wram = 0x11,
    lz77_uncomp_vram = 0x12,
    huff_uncomp = 0x13,
    rl_uncomp_wram = 0x14,
    rl_uncomp_vram = 0x15,
    multiboot = 0x25,
};

pub const DivResult = struct {
    quot: i32,
    rem: i32,
    abs_quot: u32,
};

/// Pure native Zig signed division matching GBA BIOS `Div` semantics (no trap on `den == 0` or `minInt(i32) / -1`).
pub fn divPure(num: i32, den: i32) DivResult {
    if (den == 0) return .{ .quot = 0, .rem = 0, .abs_quot = 0 };
    const q: i64 = @divTrunc(@as(i64, num), @as(i64, den));
    const rem: i64 = @rem(@as(i64, num), @as(i64, den));
    const abs_q: u64 = if (q < 0) @intCast(-q) else @intCast(q);
    return .{
        .quot = @truncate(q),
        .rem = @truncate(rem),
        .abs_quot = @truncate(abs_q),
    };
}

/// GBA BIOS hardware/platform abstraction boundary.
pub const bios = struct {
    /// Invoke the centralized BIOS SWI backend for exact cycle/validator parity.
    pub inline fn invoke(comptime op: Swi) void {
        rt.gba_swi(@intFromEnum(op));
    }

    pub inline fn softReset() void {
        invoke(.soft_reset);
    }

    pub inline fn registerRamReset(flags: u32) void {
        rt.r[0] = flags;
        invoke(.register_ram_reset);
    }

    pub inline fn div(num: i32, den: i32) DivResult {
        rt.r[0] = @bitCast(num);
        rt.r[1] = @bitCast(den);
        invoke(.div);
        return .{
            .quot = @bitCast(rt.r[0]),
            .rem = @bitCast(rt.r[1]),
            .abs_quot = rt.r[3],
        };
    }

    pub inline fn cpuSet(src: u32, dst: u32, control: u32) void {
        rt.r[0] = src;
        rt.r[1] = dst;
        rt.r[2] = control;
        invoke(.cpu_set);
    }

    pub inline fn cpuFastSet(src: u32, dst: u32, control: u32) void {
        rt.r[0] = src;
        rt.r[1] = dst;
        rt.r[2] = control;
        invoke(.cpu_fast_set);
    }

    pub inline fn bgAffineSet(src: u32, dst: u32, count: u32) void {
        rt.r[0] = src;
        rt.r[1] = dst;
        rt.r[2] = count;
        invoke(.bg_affine_set);
    }

    pub inline fn lz77UnCompWram(src: u32, dst: u32) void {
        rt.r[0] = src;
        rt.r[1] = dst;
        invoke(.lz77_uncomp_wram);
    }

    pub inline fn lz77UnCompVram(src: u32, dst: u32) void {
        rt.r[0] = src;
        rt.r[1] = dst;
        invoke(.lz77_uncomp_vram);
    }

    pub inline fn huffUnComp(src: u32, dst: u32) void {
        rt.r[0] = src;
        rt.r[1] = dst;
        invoke(.huff_uncomp);
    }

    pub inline fn rlUnCompWram(src: u32, dst: u32) void {
        rt.r[0] = src;
        rt.r[1] = dst;
        invoke(.rl_uncomp_wram);
    }

    pub inline fn rlUnCompVram(src: u32, dst: u32) void {
        rt.r[0] = src;
        rt.r[1] = dst;
        invoke(.rl_uncomp_vram);
    }

    pub inline fn multiBoot(param_ptr: u32, mode: u32) u32 {
        rt.r[0] = param_ptr;
        rt.r[1] = mode;
        invoke(.multiboot);
        return rt.r[0];
    }
};

/// GBA keypad input abstraction boundary (`KEYINPUT` `0x0400_0130`).
pub const input = struct {
    pub const Button = packed struct(u16) {
        a: bool = false,
        b: bool = false,
        select: bool = false,
        start: bool = false,
        right: bool = false,
        left: bool = false,
        up: bool = false,
        down: bool = false,
        r: bool = false,
        l: bool = false,
        _unused: u6 = 0,
    };

    pub const mask_all: u16 = @truncate(types.key_mask_all);
    pub const mask_soft_reset: u16 = @truncate(types.key_mask_soft_reset);

    pub inline fn decodeActiveLow(raw_keyinput: u16) u16 {
        return @truncate(types.key_mask_all & ~@as(u32, raw_keyinput));
    }

    pub inline fn decodeButtons(raw_keyinput: u16) Button {
        return @bitCast(decodeActiveLow(raw_keyinput));
    }

    pub inline fn readRaw() u16 {
        return mem.readU16(types.addr.reg_keyinput);
    }

    pub inline fn pollPressed() u16 {
        return decodeActiveLow(readRaw());
    }

    pub inline fn isSoftResetCombo(raw_keyinput: u16) bool {
        return (decodeActiveLow(raw_keyinput) & mask_soft_reset) == mask_soft_reset;
    }
};

/// GBA cartridge Flash (`0x0E00_0000`) & save bitset abstraction boundary.
pub const save = struct {
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
};

test "hal.divPure matches GBA BIOS Div quotient, remainder, and abs_quot" {
    const pos = divPure(23, 5);
    try std.testing.expectEqual(@as(i32, 4), pos.quot);
    try std.testing.expectEqual(@as(i32, 3), pos.rem);
    try std.testing.expectEqual(@as(u32, 4), pos.abs_quot);

    const neg = divPure(-23, 5);
    try std.testing.expectEqual(@as(i32, -4), neg.quot);
    try std.testing.expectEqual(@as(i32, -3), neg.rem);
    try std.testing.expectEqual(@as(u32, 4), neg.abs_quot);

    const zero = divPure(123, 0);
    try std.testing.expectEqual(@as(i32, 0), zero.quot);
    try std.testing.expectEqual(@as(i32, 0), zero.rem);
    try std.testing.expectEqual(@as(u32, 0), zero.abs_quot);

    const ovf = divPure(std.math.minInt(i32), -1);
    try std.testing.expectEqual(std.math.minInt(i32), ovf.quot);
    try std.testing.expectEqual(@as(i32, 0), ovf.rem);
    try std.testing.expectEqual(@as(u32, 0x8000_0000), ovf.abs_quot);
}

test "hal.Swi enum opcodes match GBA BIOS specification" {
    try std.testing.expectEqual(@as(u8, 0x00), @intFromEnum(Swi.soft_reset));
    try std.testing.expectEqual(@as(u8, 0x01), @intFromEnum(Swi.register_ram_reset));
    try std.testing.expectEqual(@as(u8, 0x06), @intFromEnum(Swi.div));
    try std.testing.expectEqual(@as(u8, 0x0B), @intFromEnum(Swi.cpu_set));
    try std.testing.expectEqual(@as(u8, 0x0C), @intFromEnum(Swi.cpu_fast_set));
    try std.testing.expectEqual(@as(u8, 0x0E), @intFromEnum(Swi.bg_affine_set));
    try std.testing.expectEqual(@as(u8, 0x11), @intFromEnum(Swi.lz77_uncomp_wram));
    try std.testing.expectEqual(@as(u8, 0x12), @intFromEnum(Swi.lz77_uncomp_vram));
    try std.testing.expectEqual(@as(u8, 0x13), @intFromEnum(Swi.huff_uncomp));
    try std.testing.expectEqual(@as(u8, 0x14), @intFromEnum(Swi.rl_uncomp_wram));
    try std.testing.expectEqual(@as(u8, 0x15), @intFromEnum(Swi.rl_uncomp_vram));
    try std.testing.expectEqual(@as(u8, 0x25), @intFromEnum(Swi.multiboot));
}

test "hal.input decodes active-low KEYINPUT buttons and soft-reset combo" {
    try std.testing.expectEqual(@as(usize, 16), @bitSizeOf(input.Button));
    try std.testing.expectEqual(@as(u16, 0x0000), input.decodeActiveLow(0x03FF));
    try std.testing.expectEqual(@as(u16, 0x000F), input.decodeActiveLow(0x03F0));
    try std.testing.expectEqual(@as(u16, 0x03FF), input.decodeActiveLow(0x0000));

    // A (bit 0), Start (bit 3), and L (bit 9) pressed simultaneously -> active-low bits cleared.
    const raw: u16 = 0x03FF & ~@as(u16, (1 << 0) | (1 << 3) | (1 << 9));
    const btns = input.decodeButtons(raw);
    try std.testing.expect(btns.a);
    try std.testing.expect(!btns.b);
    try std.testing.expect(!btns.select);
    try std.testing.expect(btns.start);
    try std.testing.expect(btns.l);
    try std.testing.expect(!btns.r);

    try std.testing.expect(input.isSoftResetCombo(0x03F0));
    try std.testing.expect(!input.isSoftResetCombo(0x03F1));
}

test "hal.save Flash geometry and bitLocation addressing" {
    try std.testing.expectEqual(@as(u32, 0), save.sectorOffset(0));
    try std.testing.expectEqual(@as(u32, 0xF000), save.sectorOffset(15));
    try std.testing.expectEqual(save.flash_size_64k, 16 * save.flash_sector_size);

    const loc = save.bitLocation(types.addr.save_flags, 0x1A, 9);
    try std.testing.expectEqual(@as(u32, types.addr.save_flags + 0x1B), loc.addr);
    try std.testing.expectEqual(@as(u3, 1), loc.shift);
    try std.testing.expectEqual(@as(u8, 0x02), loc.mask);
}
