const std = @import("std");

/// One GBA hardware timer channel (TM0..TM3).
pub const HwTimer = struct {
    internal_counter: u32 = 0,
    counter: u16 = 0,
    reload: u16 = 0,
    control: u16 = 0,
    running: bool = false,
    cascade: bool = false,
    prescaler: u2 = 0,
};

/// GBA 4-channel hardware timers (`0x0400_0100..0x0400_010F`).
pub const Timers = struct {
    pub const reg_base: u32 = 0x100;
    pub const prescaler_shift = [4]u5{ 0, 6, 8, 10 };

    ch: [4]HwTimer = @splat(.{}),

    pub inline fn cntLOffset(idx: usize) u32 {
        return reg_base + @as(u32, @intCast(idx)) * 4;
    }

    pub inline fn cntHOffset(idx: usize) u32 {
        return reg_base + @as(u32, @intCast(idx)) * 4 + 2;
    }

    fn overflow(self: *Timers, idx: usize) u16 {
        self.ch[idx].counter = self.ch[idx].reload;
        var irq_mask: u16 = 0;
        if ((self.ch[idx].control & (1 << 6)) != 0) {
            irq_mask |= @as(u16, 1) << @intCast(3 + idx);
        }
        if (idx < 3 and self.ch[idx + 1].running and self.ch[idx + 1].cascade) {
            self.ch[idx + 1].counter +%= 1;
            if (self.ch[idx + 1].counter == 0) {
                irq_mask |= self.overflow(idx + 1);
            }
        }
        return irq_mask;
    }

    /// Advance all active timers by `cycles` CPU cycles. Returns IF bits (3..6) to assert.
    pub fn tick(self: *Timers, cycles: u32) u16 {
        var irq_mask: u16 = 0;
        for (0..4) |i| {
            if (!self.ch[i].running or self.ch[i].cascade) continue;
            const shift = prescaler_shift[self.ch[i].prescaler];
            self.ch[i].internal_counter +%= cycles;

            var ticks = self.ch[i].internal_counter >> shift;
            self.ch[i].internal_counter &= (@as(u32, 1) << shift) - 1;

            while (ticks > 0) {
                const until_overflow: u32 = @as(u32, 0x10000) - @as(u32, self.ch[i].counter);
                if (ticks >= until_overflow) {
                    ticks -= until_overflow;
                    irq_mask |= self.overflow(i);
                } else {
                    self.ch[i].counter +%= @truncate(ticks);
                    ticks = 0;
                }
            }
        }
        return irq_mask;
    }

    /// Update the reload value stored when writing `TMXCNT_L`.
    pub fn writeReload(self: *Timers, idx: usize, value: u16) void {
        self.ch[idx].reload = value;
    }

    /// Update control bits for `TMXCNT_H`, reloading counter on stopped->running transition.
    pub fn writeControl(self: *Timers, idx: usize, value: u16) void {
        const was_running = self.ch[idx].running;
        const now_running = ((value >> 7) & 1) != 0;

        self.ch[idx].control = value;
        self.ch[idx].prescaler = @truncate(value & 3);
        self.ch[idx].cascade = ((value >> 2) & 1) != 0;
        self.ch[idx].running = now_running;

        if (!was_running and now_running) {
            self.ch[idx].counter = self.ch[idx].reload;
            self.ch[idx].internal_counter = 0;
        }
    }

    /// Read live counter (when running) or reload value (when stopped).
    pub fn readCounter(self: *const Timers, idx: usize) u16 {
        return if (self.ch[idx].running) self.ch[idx].counter else self.ch[idx].reload;
    }

    /// Read control register `TMXCNT_H`.
    pub fn readControl(self: *const Timers, idx: usize) u16 {
        return self.ch[idx].control;
    }
};

test "Timers prescaler, reload-on-start, overflow IRQ, and cascade" {
    var tm: Timers = .{};

    // Stopped timer returns reload value
    tm.writeReload(0, 0xFFFC);
    try std.testing.expectEqual(@as(u16, 0xFFFC), tm.readCounter(0));

    // Enable TM0 with prescaler 1 (64 cycles), IRQ enable (bit 6), start (bit 7)
    tm.writeControl(0, 0x00C1);
    // Enable TM1 in cascade mode (bit 2), IRQ enable, start
    tm.writeReload(1, 0xFFFE);
    tm.writeControl(1, 0x00C4);

    // 128 cycles -> 2 ticks on TM0: 0xFFFC -> 0xFFFE, no overflow
    try std.testing.expectEqual(@as(u16, 0), tm.tick(128));
    try std.testing.expectEqual(@as(u16, 0xFFFE), tm.readCounter(0));
    try std.testing.expectEqual(@as(u16, 0xFFFE), tm.readCounter(1));

    // Next 128 cycles -> 2 ticks on TM0 -> overflows once -> TM0 reloads to 0xFFFC,
    // TM1 cascades to 0xFFFF, TM0 IRQ (bit 3) asserted.
    try std.testing.expectEqual(@as(u16, 1 << 3), tm.tick(128));
    try std.testing.expectEqual(@as(u16, 0xFFFC), tm.readCounter(0));
    try std.testing.expectEqual(@as(u16, 0xFFFF), tm.readCounter(1));

    // 4 ticks on TM0 (256 cycles) -> overflows once more -> TM1 overflows -> IRQ bits 3 and 4
    try std.testing.expectEqual(@as(u16, (1 << 3) | (1 << 4)), tm.tick(256));
    try std.testing.expectEqual(@as(u16, 0xFFFC), tm.readCounter(0));
    try std.testing.expectEqual(@as(u16, 0xFFFE), tm.readCounter(1));
}
