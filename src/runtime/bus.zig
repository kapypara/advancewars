//! GBA memory bus decoding (BIOS, EWRAM, IWRAM, I/O, Palette, VRAM, OAM, ROM/EEPROM, Flash/SRAM) and DMA bus hooks.

const std = @import("std");
const core = @import("awre_core");
const diagnostics = @import("diagnostics.zig");
const state = @import("state.zig");

const Timers = core.timers.Timers;
const Dma = core.dma.Dma;
const BusMode = core.dma.BusMode;

pub fn DmaBus(comptime Rt: type) type {
    return struct {
        pub fn ioRead16(_: *@This(), off: u32) u16 {
            return state.ioRead16(off);
        }
        pub fn ioWrite16(_: *@This(), off: u32, val: u16) void {
            state.ioWrite16(off, val);
        }
        pub fn ioRead32(_: *@This(), off: u32) u32 {
            return state.ioRead32(off);
        }
        pub fn busRead32(_: *@This(), addr: u32) u32 {
            return Rt.busRead32(addr);
        }
        pub fn busWrite32(_: *@This(), addr: u32, val: u32) void {
            Rt.busWrite32(addr, val);
        }
        pub fn busRead16(_: *@This(), addr: u32) u16 {
            return Rt.busRead16(addr);
        }
        pub fn busWrite16(_: *@This(), addr: u32, val: u16) void {
            Rt.busWrite16(addr, val);
        }
        pub fn getBusMode(_: *@This()) BusMode {
            return state.bus_mode;
        }
        pub fn setBusMode(_: *@This(), m: BusMode) void {
            state.bus_mode = m;
        }
        pub fn raiseIrq(_: *@This(), mask: u16) void {
            state.raiseIrqBits(mask);
        }
    };
}

pub fn ioWriteHook(off: u32, dma_bus: anytype) void {
    for (0..4) |ch| {
        const cnt_hi_off = Dma.cntHOffset(ch);
        if (off == cnt_hi_off or off == cnt_hi_off + 1) {
            const cnt_hi = state.ioRead16(cnt_hi_off);
            if ((cnt_hi & (1 << 15)) != 0) {
                state.dma_state.enable(ch, dma_bus);
                state.dma_state.execute(ch, dma_bus);
            }
        }
    }

    for (0..4) |t| {
        const cnt_l = Timers.cntLOffset(t);
        const cnt_h = Timers.cntHOffset(t);
        if (off == cnt_l or off == cnt_l + 1) {
            state.timer_state.writeReload(t, state.ioRead16(cnt_l));
        }
        if (off == cnt_h or off == cnt_h + 1) {
            const v = state.ioRead16(cnt_h);
            state.timer_state.writeControl(t, v);
            state.ioWrite16(cnt_h, v);
        }
    }

    if (off == 0x128 or off == 0x129) {
        var siocnt = state.ioRead16(0x128);
        if ((siocnt & 0x80) != 0) {
            const sio_send = state.ioRead16(0x12A);
            state.ioWrite16(0x120, sio_send);
            state.ioWrite16(0x122, 0xFFFF);
            state.ioWrite16(0x124, 0xFFFF);
            state.ioWrite16(0x126, 0xFFFF);
            siocnt = (siocnt & ~@as(u16, 0x80)) | 0x40;
            state.ioWrite16(0x128, siocnt);
            if ((siocnt & 0x4000) != 0) {
                state.raiseIrqBits(0x80);
                const bios_if = (@as(u16, state.iwram_buf[0x7FF8]) | (@as(u16, state.iwram_buf[0x7FF9]) << 8)) | 0x80;
                state.iwram_buf[0x7FF8] = @truncate(bios_if);
                state.iwram_buf[0x7FF9] = @truncate(bios_if >> 8);
            }
        }
    }
}

pub fn read32Raw(addr_in: u32) u32 {
    const addr = addr_in & ~@as(u32, 3);
    const region = addr >> 24;
    switch (region) {
        0x00 => {
            const off = addr & 0x3FFF;
            if (state.bios_mem_ptr) |bm| {
                return @as(u32, bm[off]) |
                    (@as(u32, bm[off + 1]) << 8) |
                    (@as(u32, bm[off + 2]) << 16) |
                    (@as(u32, bm[off + 3]) << 24);
            }
            return 0;
        },
        0x02 => {
            const off = addr & 0x3FFFF;
            return @as(u32, state.ewram_buf[off]) |
                (@as(u32, state.ewram_buf[off + 1]) << 8) |
                (@as(u32, state.ewram_buf[off + 2]) << 16) |
                (@as(u32, state.ewram_buf[off + 3]) << 24);
        },
        0x03 => {
            const off = addr & 0x7FFF;
            return @as(u32, state.iwram_buf[off]) |
                (@as(u32, state.iwram_buf[off + 1]) << 8) |
                (@as(u32, state.iwram_buf[off + 2]) << 16) |
                (@as(u32, state.iwram_buf[off + 3]) << 24);
        },
        0x04 => {
            if ((addr & 0x00FF_FFFF) >= 0x400) return 0;
            const off = addr & 0x3FF;
            for (0..4) |t| {
                if (off == Timers.cntLOffset(t)) {
                    const cnt = state.timer_state.readCounter(t);
                    const ctl = state.timer_state.readControl(t);
                    return @as(u32, cnt) | (@as(u32, ctl) << 16);
                }
            }
            return state.ioRead32(off);
        },
        0x05 => {
            const off = addr & 0x3FF;
            return @as(u32, state.palette_buf[off]) |
                (@as(u32, state.palette_buf[off + 1]) << 8) |
                (@as(u32, state.palette_buf[off + 2]) << 16) |
                (@as(u32, state.palette_buf[off + 3]) << 24);
        },
        0x06 => {
            var off = addr & 0x1FFFF;
            if (off >= 0x18000) off -= 0x8000;
            return @as(u32, state.vram_buf[off]) |
                (@as(u32, state.vram_buf[off + 1]) << 8) |
                (@as(u32, state.vram_buf[off + 2]) << 16) |
                (@as(u32, state.vram_buf[off + 3]) << 24);
        },
        0x07 => {
            const off = addr & 0x3FF;
            return @as(u32, state.oam_buf[off]) |
                (@as(u32, state.oam_buf[off + 1]) << 8) |
                (@as(u32, state.oam_buf[off + 2]) << 16) |
                (@as(u32, state.oam_buf[off + 3]) << 24);
        },
        0x08...0x0D => {
            if (state.eeprom_state.isAddr(addr, state.rom_size)) {
                const v0 = state.eeprom_state.read();
                const v1 = state.eeprom_state.read();
                return @as(u32, v0) | (@as(u32, v1) << 16);
            }
            if (state.rom_size == 0) return 0;
            const off = (addr - 0x0800_0000) % state.rom_size;
            return @as(u32, state.romByte(off)) |
                (@as(u32, state.romByte(off + 1)) << 8) |
                (@as(u32, state.romByte(off + 2)) << 16) |
                (@as(u32, state.romByte(off + 3)) << 24);
        },
        0x0E, 0x0F => {
            if (!state.sram_active) return 0;
            const val: u32 = state.flash_state.read8(&state.sram_buf, addr, state.cycle_counter);
            return val | (val << 8) | (val << 16) | (val << 24);
        },
        else => return 0,
    }
}

pub fn read16Raw(addr_in: u32) u16 {
    const addr = addr_in & ~@as(u32, 1);
    const region = addr >> 24;
    switch (region) {
        0x02 => {
            const off = addr & 0x3FFFF;
            return @as(u16, state.ewram_buf[off]) | (@as(u16, state.ewram_buf[off + 1]) << 8);
        },
        0x03 => {
            const off = addr & 0x7FFF;
            return @as(u16, state.iwram_buf[off]) | (@as(u16, state.iwram_buf[off + 1]) << 8);
        },
        0x04 => {
            if ((addr & 0x00FF_FFFF) >= 0x400) return 0;
            const off = addr & 0x3FF;
            for (0..4) |t| {
                if (off == Timers.cntLOffset(t)) return state.timer_state.readCounter(t);
                if (off == Timers.cntHOffset(t)) return state.timer_state.readControl(t);
            }
            return state.ioRead16(off);
        },
        0x05 => {
            const off = addr & 0x3FF;
            return @as(u16, state.palette_buf[off]) | (@as(u16, state.palette_buf[off + 1]) << 8);
        },
        0x06 => {
            var off = addr & 0x1FFFF;
            if (off >= 0x18000) off -= 0x8000;
            return @as(u16, state.vram_buf[off]) | (@as(u16, state.vram_buf[off + 1]) << 8);
        },
        0x07 => {
            const off = addr & 0x3FF;
            return @as(u16, state.oam_buf[off]) | (@as(u16, state.oam_buf[off + 1]) << 8);
        },
        0x08...0x0D => {
            if (state.eeprom_state.isAddr(addr, state.rom_size)) return state.eeprom_state.read();
            if (state.rom_size == 0) return 0;
            const off = (addr - 0x0800_0000) % state.rom_size;
            return @as(u16, state.romByte(off)) | (@as(u16, state.romByte(off + 1)) << 8);
        },
        0x0E, 0x0F => {
            const v: u16 = if (state.sram_active) state.flash_state.read8(&state.sram_buf, addr, state.cycle_counter) else 0;
            return v * 0x0101;
        },
        else => return 0,
    }
}

pub fn read8Raw(addr: u32) u8 {
    return switch (addr >> 24) {
        0x02 => state.ewram_buf[addr & 0x3FFFF],
        0x03 => state.iwram_buf[addr & 0x7FFF],
        0x04 => if ((addr & 0x00FF_FFFF) >= 0x400) 0 else state.io_regs_buf[addr & 0x3FF],
        0x05 => state.palette_buf[addr & 0x3FF],
        0x06 => blk: {
            var off = addr & 0x1FFFF;
            if (off >= 0x18000) off -= 0x8000;
            break :blk state.vram_buf[off];
        },
        0x07 => state.oam_buf[addr & 0x3FF],
        0x08...0x0D => blk: {
            if (state.eeprom_state.isAddr(addr, state.rom_size)) break :blk @truncate(state.eeprom_state.read());
            if (state.rom_size == 0) break :blk 0;
            break :blk state.romByte((addr - 0x0800_0000) % state.rom_size);
        },
        0x0E, 0x0F => if (state.sram_active) state.flash_state.read8(&state.sram_buf, addr, state.cycle_counter) else 0,
        else => 0,
    };
}

pub fn write32Raw(
    addr_in: u32,
    value: u32,
    dma_bus: anytype,
    func_ring: *const [4096]u32,
    func_ring_i: u32,
    lr: u32,
) void {
    diagnostics.watchCheck(addr_in, value, 4, state.in_irq, state.frame_count, func_ring, func_ring_i, lr);
    const addr = addr_in & ~@as(u32, 3);
    switch (addr >> 24) {
        0x02 => state.memWrite32Raw(&state.ewram_buf, addr & 0x3FFFF, value),
        0x03 => state.memWrite32Raw(&state.iwram_buf, addr & 0x7FFF, value),
        0x04 => {
            if ((addr & 0x00FF_FFFF) >= 0x400) return;
            const off = addr & 0x3FF;
            if (off == 0x200) {
                state.memWrite16Raw(&state.io_regs_buf, 0x200, @truncate(value));
                const if_clear: u16 = @truncate(value >> 16);
                state.ioWrite16(0x202, state.ioRead16(0x202) & ~if_clear);
            } else {
                state.memWrite32Raw(&state.io_regs_buf, off, value);
                ioWriteHook(off, dma_bus);
                ioWriteHook(off + 2, dma_bus);
            }
        },
        0x05 => state.memWrite32Raw(&state.palette_buf, addr & 0x3FF, value),
        0x06 => {
            var off = addr & 0x1FFFF;
            if (off >= 0x18000) off -= 0x8000;
            state.memWrite32Raw(&state.vram_buf, off, value);
        },
        0x07 => state.memWrite32Raw(&state.oam_buf, addr & 0x3FF, value),
        0x08...0x0D => {
            if (state.eeprom_state.isAddr(addr, state.rom_size)) {
                state.eeprom_state.write(@truncate(value));
                state.eeprom_state.write(@truncate(value >> 16));
            }
        },
        0x0E, 0x0F => {
            if (state.sram_active) state.flash_state.write8(&state.sram_buf, addr, @truncate(value), state.cycle_counter);
        },
        else => {},
    }
}

pub fn write16Raw(
    addr_in: u32,
    value: u16,
    dma_bus: anytype,
    func_ring: *const [4096]u32,
    func_ring_i: u32,
    lr: u32,
) void {
    diagnostics.watchCheck(addr_in, value, 2, state.in_irq, state.frame_count, func_ring, func_ring_i, lr);
    const addr = addr_in & ~@as(u32, 1);
    switch (addr >> 24) {
        0x02 => state.memWrite16Raw(&state.ewram_buf, addr & 0x3FFFF, value),
        0x03 => state.memWrite16Raw(&state.iwram_buf, addr & 0x7FFF, value),
        0x04 => {
            if ((addr & 0x00FF_FFFF) >= 0x400) return;
            const off = addr & 0x3FF;
            if (off == 0x202) {
                state.ioWrite16(0x202, state.ioRead16(0x202) & ~value);
            } else {
                state.memWrite16Raw(&state.io_regs_buf, off, value);
                ioWriteHook(off, dma_bus);
            }
        },
        0x05 => state.memWrite16Raw(&state.palette_buf, addr & 0x3FF, value),
        0x06 => {
            var off = addr & 0x1FFFF;
            if (off >= 0x18000) off -= 0x8000;
            state.memWrite16Raw(&state.vram_buf, off, value);
        },
        0x07 => state.memWrite16Raw(&state.oam_buf, addr & 0x3FF, value),
        0x08...0x0D => {
            if (state.eeprom_state.isAddr(addr, state.rom_size)) state.eeprom_state.write(value);
        },
        0x0E, 0x0F => {
            if (state.sram_active) state.flash_state.write8(&state.sram_buf, addr, @truncate(value), state.cycle_counter);
        },
        else => {},
    }
}

pub fn write8Raw(
    addr: u32,
    value: u8,
    dma_bus: anytype,
    func_ring: *const [4096]u32,
    func_ring_i: u32,
    lr: u32,
) void {
    diagnostics.watchCheck(addr, value, 1, state.in_irq, state.frame_count, func_ring, func_ring_i, lr);
    switch (addr >> 24) {
        0x02 => state.ewram_buf[addr & 0x3FFFF] = value,
        0x03 => state.iwram_buf[addr & 0x7FFF] = value,
        0x04 => {
            if ((addr & 0x00FF_FFFF) >= 0x400) return;
            const off = addr & 0x3FF;
            if (off == 0x202 or off == 0x203) {
                const if_val = state.ioRead16(0x202);
                if (off == 0x202) {
                    state.ioWrite16(0x202, if_val & ~@as(u16, value));
                } else {
                    state.ioWrite16(0x202, if_val & ~(@as(u16, value) << 8));
                }
            } else {
                state.io_regs_buf[off] = value;
                ioWriteHook(off, dma_bus);
            }
        },
        0x05 => {
            const off = addr & 0x3FE;
            state.palette_buf[off] = value;
            state.palette_buf[off + 1] = value;
        },
        0x06 => {
            var off = addr & 0x1FFFE;
            if (off >= 0x18000) off -= 0x8000;
            state.vram_buf[off] = value;
            state.vram_buf[off + 1] = value;
        },
        0x0E, 0x0F => {
            if (state.sram_active) state.flash_state.write8(&state.sram_buf, addr, value, state.cycle_counter);
        },
        else => {},
    }
}

test "bus read/write handles EWRAM, VRAM mirroring, palette 8-bit dup, and IF W1C" {
    state.resetCommon();
    defer state.resetCommon();

    const NoopDmaBus = struct {
        pub fn ioRead16(_: *@This(), off: u32) u16 {
            return state.ioRead16(off);
        }
        pub fn ioWrite16(_: *@This(), off: u32, val: u16) void {
            state.ioWrite16(off, val);
        }
        pub fn ioRead32(_: *@This(), off: u32) u32 {
            return state.ioRead32(off);
        }
        pub fn busRead32(_: *@This(), _: u32) u32 {
            return 0;
        }
        pub fn busWrite32(_: *@This(), _: u32, _: u32) void {}
        pub fn busRead16(_: *@This(), _: u32) u16 {
            return 0;
        }
        pub fn busWrite16(_: *@This(), _: u32, _: u16) void {}
        pub fn getBusMode(_: *@This()) BusMode {
            return state.bus_mode;
        }
        pub fn setBusMode(_: *@This(), m: BusMode) void {
            state.bus_mode = m;
        }
        pub fn raiseIrq(_: *@This(), mask: u16) void {
            state.raiseIrqBits(mask);
        }
    };

    var dummy_dma: NoopDmaBus = .{};
    const ring: [4096]u32 = @splat(0);

    write32Raw(0x0200_0010, 0xCAFE_BABE, &dummy_dma, &ring, 0, 0);
    try std.testing.expectEqual(@as(u32, 0xCAFE_BABE), read32Raw(0x0200_0010));

    write32Raw(0x0601_0004, 0x1122_3344, &dummy_dma, &ring, 0, 0);
    try std.testing.expectEqual(@as(u32, 0x1122_3344), read32Raw(0x0601_8004));

    write8Raw(0x0500_0002, 0xAB, &dummy_dma, &ring, 0, 0);
    try std.testing.expectEqual(@as(u16, 0xABAB), read16Raw(0x0500_0002));

    state.raiseIrqBits(0x0003);
    write16Raw(0x0400_0202, 0x0001, &dummy_dma, &ring, 0, 0);
    try std.testing.expectEqual(@as(u16, 0x0002), read16Raw(0x0400_0202));
}
