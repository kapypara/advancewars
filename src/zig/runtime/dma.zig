const std = @import("std");

/// Bus master classification for cycle-accurate waitstates and VRAM stalls.
pub const BusMode = enum(u8) {
    rom_code = 0,
    ram_code = 1,
    dma = 2,
    bios_hle = 3,
};

/// GBA 4-channel DMA controller (`0x0400_00B0..0x0400_00DF`).
pub const Dma = struct {
    pub const reg_base: u32 = 0x0B0;

    src_latch: [4]u32 = @splat(0),
    dst_latch: [4]u32 = @splat(0),

    pub inline fn sadOffset(ch: usize) u32 {
        return reg_base + @as(u32, @intCast(ch)) * 12;
    }

    pub inline fn dadOffset(ch: usize) u32 {
        return reg_base + @as(u32, @intCast(ch)) * 12 + 4;
    }

    pub inline fn cntLOffset(ch: usize) u32 {
        return reg_base + @as(u32, @intCast(ch)) * 12 + 8;
    }

    pub inline fn cntHOffset(ch: usize) u32 {
        return reg_base + @as(u32, @intCast(ch)) * 12 + 10;
    }

    /// Latch source and destination registers when DMA channel `ch` is enabled.
    pub fn enable(self: *Dma, ch: usize, bus: anytype) void {
        const base = reg_base + @as(u32, @intCast(ch)) * 12;
        self.src_latch[ch] = bus.ioRead32(base);
        self.dst_latch[ch] = bus.ioRead32(base + 4);
    }

    /// Execute one transfer burst on DMA channel `ch`.
    pub fn transfer(self: *Dma, ch: usize, bus: anytype) void {
        const base = reg_base + @as(u32, @intCast(ch)) * 12;
        var src = self.src_latch[ch];
        var dst = self.dst_latch[ch];
        const cnt_lo = bus.ioRead16(base + 8);
        var cnt_hi = bus.ioRead16(base + 10);

        var count: u32 = cnt_lo;
        if (count == 0) {
            count = if (ch == 3) 0x10000 else 0x4000;
        }

        const word = ((cnt_hi >> 10) & 1) != 0;
        const dst_ctrl: u2 = @truncate((cnt_hi >> 5) & 3);
        const src_ctrl: u2 = @truncate((cnt_hi >> 7) & 3);
        const step: u32 = if (word) 4 else 2;

        const saved_mode = bus.getBusMode();
        bus.setBusMode(.dma);
        var i: u32 = 0;
        while (i < count) : (i += 1) {
            if (word) {
                const val = bus.busRead32(src);
                bus.busWrite32(dst, val);
            } else {
                const val = bus.busRead16(src);
                bus.busWrite16(dst, val);
            }

            switch (src_ctrl) {
                0 => src +%= step,
                1 => src -%= step,
                2, 3 => {},
            }
            switch (dst_ctrl) {
                0, 3 => dst +%= step,
                1 => dst -%= step,
                2 => {},
            }
        }
        bus.setBusMode(saved_mode);

        self.src_latch[ch] = src;
        if (dst_ctrl != 3) {
            self.dst_latch[ch] = dst;
        }

        const repeat = ((cnt_hi >> 9) & 1) != 0;
        const timing: u2 = @truncate((cnt_hi >> 12) & 3);
        if (!repeat or timing == 0) {
            cnt_hi &= ~@as(u16, 1 << 15);
            bus.ioWrite16(base + 10, cnt_hi);
        }

        if ((cnt_hi & (1 << 14)) != 0) {
            bus.raiseIrq(@as(u16, 1) << @intCast(8 + ch));
        }
    }

    /// Run channel `ch` immediately if enabled with timing mode 0.
    pub fn execute(self: *Dma, ch: usize, bus: anytype) void {
        const cnt_hi = bus.ioRead16(cntHOffset(ch));
        if ((cnt_hi & (1 << 15)) == 0) return;
        const timing: u2 = @truncate((cnt_hi >> 12) & 3);
        if (timing == 0) {
            self.transfer(ch, bus);
        }
    }

    /// Trigger all enabled VBlank DMA channels (timing mode 1).
    pub fn triggerVBlank(self: *Dma, bus: anytype) void {
        for (0..4) |ch| {
            const cnt_hi = bus.ioRead16(cntHOffset(ch));
            if ((cnt_hi & (1 << 15)) != 0 and ((cnt_hi >> 12) & 3) == 1) {
                self.transfer(ch, bus);
            }
        }
    }

    /// Trigger all enabled HBlank DMA channels (timing mode 2).
    pub fn triggerHBlank(self: *Dma, bus: anytype) void {
        for (0..4) |ch| {
            const cnt_hi = bus.ioRead16(cntHOffset(ch));
            if ((cnt_hi & (1 << 15)) != 0 and ((cnt_hi >> 12) & 3) == 2) {
                self.transfer(ch, bus);
            }
        }
    }
};

test "Dma immediate word copy, fixed-src fill, HBlank repeat reload, and IRQ" {
    const MockBus = struct {
        io: [0x400]u8 = @splat(0),
        ram: [256]u8 = @splat(0),
        mode: BusMode = .rom_code,
        if_val: u16 = 0,

        pub fn ioRead16(self: *const @This(), off: u32) u16 {
            return @as(u16, self.io[off]) | (@as(u16, self.io[off + 1]) << 8);
        }
        pub fn ioWrite16(self: *@This(), off: u32, val: u16) void {
            self.io[off] = @truncate(val);
            self.io[off + 1] = @truncate(val >> 8);
        }
        pub fn ioRead32(self: *const @This(), off: u32) u32 {
            return @as(u32, self.io[off]) |
                (@as(u32, self.io[off + 1]) << 8) |
                (@as(u32, self.io[off + 2]) << 16) |
                (@as(u32, self.io[off + 3]) << 24);
        }
        pub fn ioWrite32(self: *@This(), off: u32, val: u32) void {
            self.io[off] = @truncate(val);
            self.io[off + 1] = @truncate(val >> 8);
            self.io[off + 2] = @truncate(val >> 16);
            self.io[off + 3] = @truncate(val >> 24);
        }
        pub fn busRead32(self: *const @This(), addr: u32) u32 {
            return std.mem.readInt(u32, self.ram[addr..][0..4], .little);
        }
        pub fn busWrite32(self: *@This(), addr: u32, val: u32) void {
            std.mem.writeInt(u32, self.ram[addr..][0..4], val, .little);
        }
        pub fn busRead16(self: *const @This(), addr: u32) u16 {
            return std.mem.readInt(u16, self.ram[addr..][0..2], .little);
        }
        pub fn busWrite16(self: *@This(), addr: u32, val: u16) void {
            std.mem.writeInt(u16, self.ram[addr..][0..2], val, .little);
        }
        pub fn getBusMode(self: *const @This()) BusMode {
            return self.mode;
        }
        pub fn setBusMode(self: *@This(), m: BusMode) void {
            self.mode = m;
        }
        pub fn raiseIrq(self: *@This(), mask: u16) void {
            self.if_val |= mask;
        }
    };

    var bus: MockBus = .{};
    var dma: Dma = .{};

    // Prepare source words at 0x00, 0x04
    bus.busWrite32(0, 0x11223344);
    bus.busWrite32(4, 0x55667788);

    // DMA3 immediate 32-bit copy 2 words 0x00 -> 0x40 with IRQ enabled
    bus.ioWrite32(Dma.sadOffset(3), 0);
    bus.ioWrite32(Dma.dadOffset(3), 0x40);
    bus.ioWrite16(Dma.cntLOffset(3), 2);
    bus.ioWrite16(Dma.cntHOffset(3), 0xC400); // enable + IRQ + 32-bit + timing 0
    dma.enable(3, &bus);
    dma.execute(3, &bus);

    try std.testing.expectEqual(@as(u32, 0x11223344), bus.busRead32(0x40));
    try std.testing.expectEqual(@as(u32, 0x55667788), bus.busRead32(0x44));
    try std.testing.expectEqual(@as(u16, 1 << 11), bus.if_val);
    try std.testing.expectEqual(@as(u16, 0x4400), bus.ioRead16(Dma.cntHOffset(3)));
    try std.testing.expectEqual(BusMode.rom_code, bus.mode);

    // DMA0 HBlank repeat 16-bit fixed-source fill with dst_ctrl=3 (inc+reload)
    bus.busWrite16(0x10, 0xABCD);
    bus.busWrite16(0x12, 0xEFEF);
    bus.ioWrite32(Dma.sadOffset(0), 0x10);
    bus.ioWrite32(Dma.dadOffset(0), 0x80);
    bus.ioWrite16(Dma.cntLOffset(0), 2);
    // enable(15) | timing=2(13..12) | repeat(9) | src_ctrl=0(8..7) | dst_ctrl=3(6..5)
    bus.ioWrite16(Dma.cntHOffset(0), 0xA260);
    dma.enable(0, &bus);
    dma.triggerHBlank(&bus);
    try std.testing.expectEqual(@as(u16, 0xABCD), bus.busRead16(0x80));
    try std.testing.expectEqual(@as(u16, 0xEFEF), bus.busRead16(0x82));
    // dst_latch stays at 0x80 (reload) while src_latch advances to 0x14
    try std.testing.expectEqual(@as(u32, 0x80), dma.dst_latch[0]);
    try std.testing.expectEqual(@as(u32, 0x14), dma.src_latch[0]);
    try std.testing.expect((bus.ioRead16(Dma.cntHOffset(0)) & (1 << 15)) != 0);
}
