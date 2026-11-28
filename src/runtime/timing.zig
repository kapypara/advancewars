//! GBA memory waitstate, PPU VRAM bus stall, and CPU cycle timing helpers.

const std = @import("std");
const BusMode = @import("awre_core").dma.BusMode;

pub const cycles_per_scanline: u32 = 1232;
pub const visible_scanlines: u32 = 160;
pub const scanlines_per_frame: u32 = 228;
pub const cycles_per_frame: u32 = cycles_per_scanline * scanlines_per_frame;
pub const hblank_start_cycle: u32 = 960;
pub const poll_interval: u32 = 10000;

const nwait_table = [4]u8{ 4, 3, 2, 8 };

const vs_a2: u16 = 0x100;
const vs_a3: u16 = 0x200;
const vs_b: u16 = 0x400;

inline fn vsT4(comptime x: u4) u16 {
    return @as(u16, 0x011) << x;
}

inline fn vsT8(comptime x: u4) u16 {
    return @as(u16, 0x010) << x;
}

const vram_stall_lut = [32]u16{
    vsT4(0) | vs_a3, vsT4(1) | vs_a3, vsT4(2) | vs_a2, vsT4(3) | vs_a2 | vs_b,
    vsT4(0) | vs_a3, vsT4(1) | vs_a3, vsT4(2) | vs_a2, vsT4(3) | vs_a2 | vs_b,
    vs_a3,           vs_a3,           vs_a2,           vs_a2 | vs_b,
    vsT8(0) | vs_a3, vsT8(1) | vs_a3, vsT8(2) | vs_a2, vsT8(3) | vs_a2 | vs_b,
    vs_a3,           vs_a3,           vs_a2,           vs_a2 | vs_b,
    vsT4(0) | vs_a3, vsT4(1) | vs_a3, vsT4(2) | vs_a2, vsT4(3) | vs_a2 | vs_b,
    vs_a3,           vs_a3,           vs_a2,           vs_a2 | vs_b,
    vsT8(0) | vs_a3, vsT8(1) | vs_a3, vsT8(2) | vs_a2, vsT8(3) | vs_a2 | vs_b,
};

inline fn ioRead16(io_regs: *const [0x400]u8, off: u32) u16 {
    return @as(u16, io_regs[off]) | (@as(u16, io_regs[off + 1]) << 8);
}

pub fn accessCycles(addr: u32, wide: bool, waitcnt: u16) u32 {
    return switch (addr >> 24) {
        0x02 => if (wide) 6 else 3,
        0x05, 0x06 => if (wide) 2 else 1,
        0x08...0x0D => blk: {
            const n: u32 = 1 + @as(u32, nwait_table[(waitcnt >> 2) & 3]);
            const s: u32 = if ((waitcnt & 0x10) != 0) 2 else 3;
            break :blk if (wide) n + s else n;
        },
        0x0E, 0x0F => 1 + @as(u32, nwait_table[waitcnt & 3]),
        else => 1,
    };
}

pub fn vramStall(
    addr: u32,
    wide: bool,
    io_regs: *const [0x400]u8,
    scanline: u32,
    scanline_cycles: u32,
    vram_burst: bool,
) u32 {
    const hdraw: u32 = 1008;
    if ((addr >> 24) != 0x06 or vram_burst or scanline >= visible_scanlines or scanline_cycles >= hdraw) {
        return 0;
    }
    const dispcnt = ioRead16(io_regs, 0x000);
    const mode = dispcnt & 7;
    if ((dispcnt & 0x80) != 0 or (addr & 0x1FFFF) >= (if (mode >= 3) @as(u32, 0x14000) else 0x10000)) {
        return 0;
    }

    var mask: u16 = 0;
    if (mode <= 1) {
        const bg_lim: u32 = if (mode != 0) 2 else 4;
        var i: u32 = 0;
        while (i < bg_lim) : (i += 1) {
            if ((dispcnt & (@as(u16, 0x100) << @intCast(i))) != 0) {
                const is_8bpp = (ioRead16(io_regs, 0x008 + 2 * i) & 0x80) != 0;
                const sh: u4 = @intCast(i);
                mask |= if (is_8bpp) (@as(u16, 0x010) << sh) else (@as(u16, 0x011) << sh);
            }
        }
    }
    if (mode == 1 and (dispcnt & 0x400) != 0) mask |= vs_a2;
    if (mode == 2) {
        if ((dispcnt & 0x400) != 0) mask |= vs_a2;
        if ((dispcnt & 0x800) != 0) mask |= vs_a3;
    }
    if (mode >= 3 and mode <= 5 and (dispcnt & 0x400) != 0) mask |= vs_b;
    if (mask == 0) return 0;

    const until: i32 = @as(i32, @intCast(hdraw)) - @as(i32, @intCast(scanline_cycles));
    var stall: i32 = until;
    var extra: i32 = if (wide) 1 else 0;
    var i: i32 = 0;
    while (i < 16) : (i += 1) {
        const lut_idx: usize = @intCast(@as(u32, @bitCast(-until + i)) & 31);
        if ((vram_stall_lut[lut_idx] & mask) == 0) {
            if (extra == 0) {
                stall = i;
                break;
            }
            extra -= 1;
        }
    }
    stall -= if (wide) @as(i32, 1) else 0;
    return if (stall > 0) @intCast(stall) else 0;
}

pub fn dataCycles(
    addr: u32,
    wide: bool,
    load: bool,
    bus_mode: BusMode,
    io_regs: *const [0x400]u8,
    scanline: u32,
    scanline_cycles: u32,
    vram_burst: bool,
) i32 {
    const cart = addr >= 0x0800_0000;
    const load_c: i32 = if (load) 1 else 0;
    const waitcnt = ioRead16(io_regs, 0x204);
    return switch (bus_mode) {
        .rom_code => blk: {
            if ((io_regs[0x205] & 0x40) == 0) {
                break :blk @as(i32, @intCast(accessCycles(addr, wide, waitcnt))) + load_c + 2 + @as(i32, @intCast(vramStall(addr, wide, io_regs, scanline, scanline_cycles, vram_burst)));
            }
            break :blk if (cart) @as(i32, @intCast(accessCycles(addr, wide, waitcnt))) + load_c + 2 else 0;
        },
        .bios_hle => if (cart) @as(i32, @intCast(accessCycles(addr, wide, waitcnt))) + load_c else -2,
        .ram_code => @as(i32, @intCast(accessCycles(addr, wide, waitcnt))) + load_c + @as(i32, @intCast(vramStall(addr, wide, io_regs, scanline, scanline_cycles, vram_burst))),
        .dma => @intCast(accessCycles(addr, wide, waitcnt)),
    };
}

test "timing.accessCycles matches GBA waitstate regions" {
    try std.testing.expectEqual(@as(u32, 3), accessCycles(0x0200_0000, false, 0));
    try std.testing.expectEqual(@as(u32, 6), accessCycles(0x0200_0000, true, 0));
    try std.testing.expectEqual(@as(u32, 1), accessCycles(0x0600_0000, false, 0));
    try std.testing.expectEqual(@as(u32, 2), accessCycles(0x0600_0000, true, 0));
    try std.testing.expectEqual(@as(u32, 1), accessCycles(0x0300_0000, true, 0));
    try std.testing.expectEqual(@as(u32, 5), accessCycles(0x0800_0000, false, 0x0000));
    try std.testing.expectEqual(@as(u32, 8), accessCycles(0x0800_0000, true, 0x0000));
    try std.testing.expectEqual(@as(u32, 3), accessCycles(0x0800_0000, false, 0x0018));
    try std.testing.expectEqual(@as(u32, 5), accessCycles(0x0800_0000, true, 0x0018));
    try std.testing.expectEqual(@as(u32, 5), accessCycles(0x0E00_0000, false, 0x0000));
}

test "timing.vramStall returns zero outside active HDraw" {
    var io_regs: [0x400]u8 = @splat(0);
    // Forced blank (DISPCNT bit 7)
    io_regs[0] = 0x80;
    try std.testing.expectEqual(@as(u32, 0), vramStall(0x0600_0000, true, &io_regs, 10, 100, false));
    // VBlank scanline >= 160
    io_regs[0] = 0x00;
    io_regs[1] = 0x01; // BG0 enabled
    try std.testing.expectEqual(@as(u32, 0), vramStall(0x0600_0000, true, &io_regs, 160, 100, false));
    // VRAM burst enabled
    try std.testing.expectEqual(@as(u32, 0), vramStall(0x0600_0000, true, &io_regs, 10, 100, true));
}
