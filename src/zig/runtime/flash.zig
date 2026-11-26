const std = @import("std");

/// GBA cartridge Flash backup (`FLASH_V` / `FLASH512_V` 64 KB, `FLASH1M_V` 128 KB).
/// Matches the GBATEK / mGBA command protocol including data# busy polling.
pub const Flash = struct {
    present: bool = false,
    large: bool = false,
    stage: u8 = 0,
    id_mode: bool = false,
    erase_armed: bool = false,
    write_next: bool = false,
    bank_next: bool = false,
    bank: u32 = 0,
    busy_until: u32 = 0,
    busy_sector: u32 = 0,
    backup_size: u32 = 0x10000,

    const flash_tags = [_][]const u8{ "FLASH1M_V", "FLASH512_V", "FLASH_V" };
    const id_small = [2]u8{ 0x32, 0x1B }; // Panasonic MN63F805MNP (64 KB)
    const id_large = [2]u8{ 0x62, 0x13 }; // Sanyo LE26FV10N1TS (128 KB)

    fn settle(self: *Flash, off: u32, cycles: u32, cycle_counter: u32) void {
        self.busy_sector = self.bank * 16 + (off >> 12);
        self.busy_until = cycle_counter +% cycles;
    }

    /// Scan `rom` for a Nintendo SDK Flash marker and configure Flash size.
    pub fn detect(self: *Flash, rom: []const u8) ?[]const u8 {
        var i: usize = 0;
        while (i + 10 <= rom.len) : (i += 1) {
            if (rom[i] != 'F') continue;
            for (flash_tags, 0..) |tag, idx| {
                if (i + tag.len <= rom.len and std.mem.eql(u8, rom[i .. i + tag.len], tag)) {
                    self.present = true;
                    self.large = (idx == 0);
                    self.backup_size = if (self.large) 0x20000 else 0x10000;
                    return tag;
                }
            }
        }
        return null;
    }

    /// Read one byte from `0x0E00_0000..0x0EFF_FFFF` (Flash or plain SRAM).
    pub fn read8(self: *const Flash, sram: []const u8, addr: u32, cycle_counter: u32) u8 {
        const off: u32 = addr & 0xFFFF;
        if (!self.present) {
            return sram[off];
        }
        if (self.id_mode and off < 2) {
            return if (self.large) id_large[off] else id_small[off];
        }
        const v = sram[self.bank * 0x10000 + off];
        const busy_rem: i32 = @bitCast(self.busy_until -% cycle_counter);
        if (busy_rem > 0 and self.busy_sector == self.bank * 16 + (off >> 12)) {
            return (v ^ 0x80) & 0x80;
        }
        return v;
    }

    /// Write one byte to `0x0E00_0000..0x0EFF_FFFF` (Flash command state machine or SRAM).
    pub fn write8(self: *Flash, sram: []u8, addr: u32, val: u8, cycle_counter: u32) void {
        const off: u32 = addr & 0xFFFF;
        if (!self.present) {
            sram[off] = val;
            return;
        }
        const bank_off: u32 = self.bank * 0x10000;
        if (self.write_next) {
            sram[bank_off + off] = val;
            self.write_next = false;
            self.settle(off, 650, cycle_counter);
            return;
        }
        if (self.bank_next) {
            if (off == 0 and self.large) {
                self.bank = val & 1;
            }
            self.bank_next = false;
            return;
        }
        if (self.stage == 0 and off == 0x5555 and val == 0xAA) {
            self.stage = 1;
            return;
        }
        if (self.stage == 1 and off == 0x2AAA and val == 0x55) {
            self.stage = 2;
            return;
        }
        if (self.stage == 2) {
            self.stage = 0;
            if (self.erase_armed and val == 0x30) {
                const sec_off = bank_off + (off & 0xF000);
                @memset(sram[sec_off .. sec_off + 0x1000], 0xFF);
                self.settle(off, 30000, cycle_counter);
                self.erase_armed = false;
                return;
            }
            if (off != 0x5555) return;
            if (self.erase_armed and val == 0x10) {
                @memset(sram[0..self.backup_size], 0xFF);
                self.erase_armed = false;
                return;
            }
            switch (val) {
                0x90 => self.id_mode = true,
                0xF0 => self.id_mode = false,
                0x80 => self.erase_armed = true,
                0xA0 => self.write_next = true,
                0xB0 => self.bank_next = true,
                else => {},
            }
            return;
        }
        self.stage = 0;
    }
};

/// GBA cartridge EEPROM (`EEPROM_V`, bit-serial protocol over `0x0D00_0000..0x0DFF_FFFF`).
pub const Eeprom = struct {
    pub const Mode = enum {
        idle,
        read_addr,
        read_stop,
        read_out,
        write_addr,
        write_data,
        write_stop,
    };

    present: bool = false,
    large: bool = false,
    mode: Mode = .idle,
    bit_cnt: u32 = 0,
    cmd_bits: u32 = 0,
    addr_buf: u32 = 0,
    data_buf: u64 = 0,
    cur_addr: u32 = 0,
    read_bit_idx: i32 = 0,
    storage: [0x2000]u8 = @splat(0),

    /// Scan `rom` for `"EEPROM_V"`. Returns matching ROM offset if found.
    pub fn detect(self: *Eeprom, rom: []const u8) ?u32 {
        if (rom.len < 8) return null;
        const needle = "EEPROM_V";
        var i: usize = 0;
        while (i + needle.len <= rom.len) : (i += 1) {
            if (std.mem.eql(u8, rom[i .. i + needle.len], needle)) {
                self.present = true;
                self.large = true;
                return @intCast(0x0800_0000 + i);
            }
        }
        return null;
    }

    /// Return true if `addr` hits the cart EEPROM aperture for `rom_size`.
    pub fn isAddr(self: *const Eeprom, addr: u32, rom_size: u32) bool {
        if (!self.present) return false;
        if (rom_size > 0x0100_0000) return (addr & 0x0FFF_FF00) == 0x0DFF_FF00;
        return (addr >> 24) == 0x0D;
    }

    /// Read next bit (in bit 0) from the EEPROM serial line.
    pub fn read(self: *Eeprom) u16 {
        if (self.mode == .read_out) {
            const idx = self.bit_cnt;
            self.bit_cnt += 1;
            if (self.bit_cnt >= 68) {
                self.mode = .idle;
                self.bit_cnt = 0;
            }
            if (idx < 4) return 0;
            const data_idx = idx - 4;
            const byte_off: usize = @intCast(self.cur_addr * 8 + (data_idx >> 3));
            const bit_off: u3 = @intCast(7 - (data_idx & 7));
            if (byte_off >= self.storage.len) return 0;
            return (self.storage[byte_off] >> bit_off) & 1;
        }
        return 1;
    }

    /// Shift one command/address/data/stop bit (bit 0 of `value`) into the EEPROM.
    pub fn write(self: *Eeprom, value: u16) void {
        const bit: u8 = @truncate(value & 1);
        const addr_bits: u32 = if (self.large) 14 else 6;

        switch (self.mode) {
            .idle => {
                self.cmd_bits = (self.cmd_bits << 1) | bit;
                self.bit_cnt += 1;
                if (self.bit_cnt == 2) {
                    const c = self.cmd_bits & 3;
                    self.cmd_bits = 0;
                    self.bit_cnt = 0;
                    if (c == 3) {
                        self.mode = .read_addr;
                    } else if (c == 2) {
                        self.mode = .write_addr;
                    }
                }
            },
            .read_addr => {
                self.addr_buf = (self.addr_buf << 1) | bit;
                self.bit_cnt += 1;
                if (self.bit_cnt == addr_bits) {
                    const mask = (@as(u32, 1) << @intCast(addr_bits)) - 1;
                    self.cur_addr = self.addr_buf & mask;
                    self.addr_buf = 0;
                    self.bit_cnt = 0;
                    self.mode = .read_stop;
                }
            },
            .read_stop => {
                self.mode = .read_out;
                self.bit_cnt = 0;
            },
            .write_addr => {
                self.addr_buf = (self.addr_buf << 1) | bit;
                self.bit_cnt += 1;
                if (self.bit_cnt == addr_bits) {
                    const mask = (@as(u32, 1) << @intCast(addr_bits)) - 1;
                    self.cur_addr = self.addr_buf & mask;
                    self.addr_buf = 0;
                    self.bit_cnt = 0;
                    self.mode = .write_data;
                }
            },
            .write_data => {
                self.data_buf = (self.data_buf << 1) | bit;
                self.bit_cnt += 1;
                if (self.bit_cnt == 64) {
                    const base: usize = @intCast(self.cur_addr * 8);
                    if (base + 8 <= self.storage.len) {
                        for (0..8) |i| {
                            const shift: u6 = @intCast(56 - i * 8);
                            self.storage[base + i] = @truncate(self.data_buf >> shift);
                        }
                    }
                    self.data_buf = 0;
                    self.bit_cnt = 0;
                    self.mode = .write_stop;
                }
            },
            .write_stop, .read_out => {
                self.mode = .idle;
                self.bit_cnt = 0;
            },
        }
    }
};

test "Flash detect, ID mode, sector erase, byte write with busy polling, and 128KB banking" {
    var sram: [0x20000]u8 = @splat(0xFF);
    var fl: Flash = .{};

    // Unconfigured SRAM pass-through
    fl.write8(&sram, 0x0E00_0042, 0x5A, 0);
    try std.testing.expectEqual(@as(u8, 0x5A), fl.read8(&sram, 0x0E00_0042, 0));

    // Detect 64KB Flash ("FLASH_V121" like Advance Wars)
    var fake_rom: [64]u8 = @splat(0);
    @memcpy(fake_rom[16..26], "FLASH_V121");
    const tag = fl.detect(&fake_rom) orelse return error.TestUnexpectedResult;
    try std.testing.expectEqualStrings("FLASH_V", tag);
    try std.testing.expect(fl.present);
    try std.testing.expect(!fl.large);
    try std.testing.expectEqual(@as(u32, 0x10000), fl.backup_size);

    // Enter ID mode and read Panasonic ID {0x32, 0x1B}
    fl.write8(&sram, 0x0E00_5555, 0xAA, 0);
    fl.write8(&sram, 0x0E00_2AAA, 0x55, 0);
    fl.write8(&sram, 0x0E00_5555, 0x90, 0);
    try std.testing.expectEqual(@as(u8, 0x32), fl.read8(&sram, 0x0E00_0000, 0));
    try std.testing.expectEqual(@as(u8, 0x1B), fl.read8(&sram, 0x0E00_0001, 0));
    fl.write8(&sram, 0x0E00_5555, 0xAA, 0);
    fl.write8(&sram, 0x0E00_2AAA, 0x55, 0);
    fl.write8(&sram, 0x0E00_5555, 0xF0, 0);

    // Write byte at cycle 1000 -> settles for 650 cycles with inverted bit 7 data# polling
    fl.write8(&sram, 0x0E00_5555, 0xAA, 1000);
    fl.write8(&sram, 0x0E00_2AAA, 0x55, 1000);
    fl.write8(&sram, 0x0E00_5555, 0xA0, 1000);
    fl.write8(&sram, 0x0E00_1234, 0x3C, 1000);
    try std.testing.expectEqual(@as(u8, 0x80), fl.read8(&sram, 0x0E00_1234, 1100));
    try std.testing.expectEqual(@as(u8, 0x3C), fl.read8(&sram, 0x0E00_1234, 1650));

    // Sector erase on sector 1 (0x1000..0x1FFF) -> settles after 30000 cycles
    fl.write8(&sram, 0x0E00_5555, 0xAA, 2000);
    fl.write8(&sram, 0x0E00_2AAA, 0x55, 2000);
    fl.write8(&sram, 0x0E00_5555, 0x80, 2000);
    fl.write8(&sram, 0x0E00_5555, 0xAA, 2000);
    fl.write8(&sram, 0x0E00_2AAA, 0x55, 2000);
    fl.write8(&sram, 0x0E00_1000, 0x30, 2000);
    try std.testing.expectEqual(@as(u8, 0x00), fl.read8(&sram, 0x0E00_1234, 10000));
    try std.testing.expectEqual(@as(u8, 0xFF), fl.read8(&sram, 0x0E00_1234, 32000));

    // 128KB Flash bank switch
    var fl1m: Flash = .{};
    @memcpy(fake_rom[16..26], "FLASH1M_V1");
    _ = fl1m.detect(&fake_rom);
    try std.testing.expect(fl1m.large);
    try std.testing.expectEqual(@as(u8, 0x62), blk: {
        fl1m.write8(&sram, 0x0E00_5555, 0xAA, 0);
        fl1m.write8(&sram, 0x0E00_2AAA, 0x55, 0);
        fl1m.write8(&sram, 0x0E00_5555, 0x90, 0);
        break :blk fl1m.read8(&sram, 0x0E00_0000, 0);
    });
    fl1m.write8(&sram, 0x0E00_5555, 0xAA, 0);
    fl1m.write8(&sram, 0x0E00_2AAA, 0x55, 0);
    fl1m.write8(&sram, 0x0E00_5555, 0xF0, 0);
    fl1m.write8(&sram, 0x0E00_5555, 0xAA, 0);
    fl1m.write8(&sram, 0x0E00_2AAA, 0x55, 0);
    fl1m.write8(&sram, 0x0E00_5555, 0xB0, 0);
    fl1m.write8(&sram, 0x0E00_0000, 1, 0);
    try std.testing.expectEqual(@as(u32, 1), fl1m.bank);
}

test "EEPROM 8KB bit-serial write and read round-trip" {
    var ee: Eeprom = .{ .present = true, .large = true };
    try std.testing.expectEqual(@as(u16, 1), ee.read());

    // Write 0x0123456789ABCDEF to block 5 (14-bit addr)
    ee.write(1);
    ee.write(0);
    var b: i32 = 13;
    while (b >= 0) : (b -= 1) {
        ee.write(@truncate((@as(u32, 5) >> @intCast(b)) & 1));
    }
    const payload: u64 = 0x0123_4567_89AB_CDEF;
    var db: i32 = 63;
    while (db >= 0) : (db -= 1) {
        ee.write(@truncate((payload >> @intCast(db)) & 1));
    }
    ee.write(0); // stop bit

    // Read block 5 back: 4 dummy 0 bits followed by 64 MSB-first bits
    ee.write(1);
    ee.write(1);
    b = 13;
    while (b >= 0) : (b -= 1) {
        ee.write(@truncate((@as(u32, 5) >> @intCast(b)) & 1));
    }
    ee.write(0); // stop bit

    for (0..4) |_| {
        try std.testing.expectEqual(@as(u16, 0), ee.read());
    }
    var got: u64 = 0;
    for (0..64) |_| {
        got = (got << 1) | ee.read();
    }
    try std.testing.expectEqual(payload, got);
    try std.testing.expectEqual(@as(u16, 1), ee.read());
}
