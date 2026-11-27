const std = @import("std");
const types = @import("types.zig");

/// Loaded GBA cartridge ROM image and parsed 192-byte header.
pub const GbaRom = struct {
    data: []u8,
    owns_data: bool,
    entry_point: u32,
    title: [12]u8,
    game_code: [4]u8,
    maker_code: [2]u8,
    fixed_value: u8,
    unit_code: u8,
    device_type: u8,
    software_version: u8,
    header_checksum: u8,

    /// Parse a GBA header from a borrowed slice (useful in tests).
    pub fn fromBorrowedSlice(bytes: []u8) error{InvalidRom}!GbaRom {
        if (bytes.len < 0xC0) return error.InvalidRom;
        return parseFromSlice(bytes, false);
    }

    /// Load a GBA ROM file from disk. Caller must call `deinit(allocator)`.
    pub fn load(allocator: std.mem.Allocator, io: std.Io, path: []const u8) !GbaRom {
        const data = try std.Io.Dir.cwd().readFileAlloc(
            io,
            path,
            allocator,
            .limited(64 * 1024 * 1024),
        );
        errdefer allocator.free(data);

        if (data.len < 0xC0) {
            return error.InvalidRom;
        }
        return parseFromSlice(data, true);
    }

    fn parseFromSlice(data: []u8, owns_data: bool) GbaRom {
        return .{
            .data = data,
            .owns_data = owns_data,
            .entry_point = std.mem.readInt(u32, data[0..4], .little),
            .title = data[0xA0..0xAC].*,
            .game_code = data[0xAC..0xB0].*,
            .maker_code = data[0xB0..0xB2].*,
            .fixed_value = data[0xB2],
            .unit_code = data[0xB3],
            .device_type = data[0xB4],
            .software_version = data[0xBC],
            .header_checksum = data[0xBD],
        };
    }

    pub fn deinit(self: *GbaRom, allocator: std.mem.Allocator) void {
        if (self.owns_data) {
            allocator.free(self.data);
        }
        self.data = &.{};
    }

    pub fn titleStr(self: *const GbaRom) []const u8 {
        const zero = std.mem.indexOfScalar(u8, &self.title, 0) orelse self.title.len;
        return self.title[0..zero];
    }

    inline fn resolveOffset(self: *const GbaRom, addr: u32) usize {
        if (addr >= types.gba_rom_start and addr < types.gba_rom_end) {
            return @as(usize, addr - types.gba_rom_start) % self.data.len;
        }
        return addr;
    }

    pub fn read32(self: *const GbaRom, addr: u32) u32 {
        const off = self.resolveOffset(addr);
        if (off + 4 > self.data.len) return 0;
        return std.mem.readInt(u32, self.data[off..][0..4], .little);
    }

    pub fn read16(self: *const GbaRom, addr: u32) u16 {
        const off = self.resolveOffset(addr);
        if (off + 2 > self.data.len) return 0;
        return std.mem.readInt(u16, self.data[off..][0..2], .little);
    }

    pub fn read8(self: *const GbaRom, addr: u32) u8 {
        const off = self.resolveOffset(addr);
        if (off >= self.data.len) return 0;
        return self.data[off];
    }

    /// Validate Nintendo header complement checksum over `0xA0..0xBC`.
    pub fn validateHeader(self: *const GbaRom) bool {
        var checksum: u8 = 0;
        for (self.data[0xA0 .. 0xBC + 1]) |b| {
            checksum -%= b;
        }
        checksum -%= 0x19;
        return checksum == self.header_checksum;
    }

    pub fn printInfo(self: *const GbaRom) void {
        const size_mb = @as(f64, @floatFromInt(self.data.len)) / (1024.0 * 1024.0);
        const fixed_ok: []const u8 = if (self.fixed_value == 0x96) "(OK)" else "(INVALID)";
        const sum_ok: []const u8 = if (self.validateHeader()) "(OK)" else "(INVALID)";
        std.debug.print(
            "=== GBA ROM Info ===\n" ++
                "  Title:       {s}\n" ++
                "  Game Code:   {s}\n" ++
                "  Maker Code:  {s}\n" ++
                "  ROM Size:    {d} bytes ({d:.1} MB)\n" ++
                "  Entry Point: 0x{X:0>8}\n" ++
                "  Fixed Value: 0x{X:0>2} {s}\n" ++
                "  Unit Code:   0x{X:0>2}\n" ++
                "  Version:     {d}\n" ++
                "  Checksum:    0x{X:0>2} {s}\n" ++
                "====================\n",
            .{
                self.titleStr(),
                &self.game_code,
                &self.maker_code,
                self.data.len,
                size_mb,
                self.entry_point,
                self.fixed_value,
                fixed_ok,
                self.unit_code,
                self.software_version,
                self.header_checksum,
                sum_ok,
            },
        );
    }
};

test "GbaRom header checksum and mirrored bus reads" {
    var raw: [0x200]u8 = @splat(0);
    std.mem.writeInt(u32, raw[0..4], 0xEA00_002E, .little);
    @memcpy(raw[0xA0..0xAC], "ADVANCEWARS ");
    @memcpy(raw[0xAC..0xB0], "AWRE");
    @memcpy(raw[0xB0..0xB2], "01");
    raw[0xB2] = 0x96;
    var sum: u8 = 0;
    for (raw[0xA0..0xBD]) |b| sum -%= b;
    sum -%= 0x19;
    raw[0xBD] = sum;
    std.mem.writeInt(u32, raw[0x100..0x104], 0x1234_5678, .little);

    var rom = try GbaRom.fromBorrowedSlice(&raw);
    try std.testing.expect(rom.validateHeader());
    try std.testing.expectEqual(@as(u32, 0xEA00_002E), rom.read32(0x0800_0000));
    try std.testing.expectEqual(@as(u32, 0x1234_5678), rom.read32(0x0A00_0100)); // ROM mirror wrap
    try std.testing.expectEqual(@as(u16, 0x5678), rom.read16(0x0800_0100));
    try std.testing.expectEqual(@as(u8, 0x12), rom.read8(0x0800_0103));
}
