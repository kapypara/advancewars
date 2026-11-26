const std = @import("std");
const dma_mod = @import("dma.zig");

const BusMode = dma_mod.BusMode;
const cycles_per_scanline: u32 = 1232;
const scanlines_per_frame: usize = 228;

fn divCycles(ctx: anytype, num: i32, den: i32) void {
    const den_clz: i32 = @intCast(@clz(@as(u32, @bitCast(den))));
    const num_clz: i32 = @intCast(@clz(@as(u32, @bitCast(num))));
    const loops: i32 = @max(den_clz - num_clz, 1);
    ctx.advanceCycles(@intCast(4 + 13 * loops + 7));
}

/// Dispatch a GBA BIOS Software Interrupt (`SWI #number`) using HLE timing and math.
pub fn swi(ctx: anytype, number: u32) void {
    ctx.logSwi(number);

    if (number == 0x00 or number == 0x02 or number == 0x04 or number == 0x05) {
        swiInner(ctx, number);
        return;
    }

    const waitcnt = ctx.ioRead16(0x204);
    const seq_wait: u32 = if ((waitcnt & 0x10) != 0) 1 else 2;
    const rom_nonseq = ctx.accessCycles(0x0800_0000, false);
    ctx.advanceCycles(45 +% 2 *% (rom_nonseq -% 1) +% seq_wait);
    if (ctx.softResetPending()) return;

    const saved_mode = ctx.getBusMode();
    ctx.setBusMode(if (number == 0x0B or number == 0x0C) .ram_code else .bios_hle);
    swiInner(ctx, number);
    ctx.setBusMode(saved_mode);
}

fn swiInner(ctx: anytype, number: u32) void {
    const r = ctx.regs();
    switch (number) {
        0x00 => { // SoftReset
            @memset(ctx.iwram()[0x7E00..0x8000], 0);
            @memset(r, 0);
            r[13] = 0x0300_7F00;
            r[15] = 0x0800_0000;
            ctx.setCpsrRaw(0x0000_001F);
            ctx.triggerSoftReset();
        },
        0x01 => { // RegisterRamReset
            const flags = r[0];
            if ((flags & 0x01) != 0) @memset(ctx.ewram()[0..0x40000], 0);
            if ((flags & 0x02) != 0) @memset(ctx.iwram()[0..0x7E00], 0);
            if ((flags & 0x04) != 0) @memset(ctx.palette()[0..0x400], 0);
            if ((flags & 0x08) != 0) @memset(ctx.vram()[0..0x18000], 0);
            if ((flags & 0x10) != 0) @memset(ctx.oam()[0..0x400], 0);
        },
        0x02 => { // Halt
            ctx.advanceCycles(cycles_per_scanline);
        },
        0x04 => { // IntrWait
            const discard = r[0] != 0;
            const wait_flags: u16 = @truncate(r[1]);
            const iw = ctx.iwram();
            if (discard) {
                var bios_if: u16 = @as(u16, iw[0x7FF8]) | (@as(u16, iw[0x7FF9]) << 8);
                bios_if &= ~wait_flags;
                iw[0x7FF8] = @truncate(bios_if);
                iw[0x7FF9] = @truncate(bios_if >> 8);
            }

            var safety: usize = 0;
            while (safety < scanlines_per_frame * 2) : (safety += 1) {
                ctx.advanceCycles(cycles_per_scanline);
                if (ctx.softResetPending()) return;
                const bios_if: u16 = @as(u16, iw[0x7FF8]) | (@as(u16, iw[0x7FF9]) << 8);
                if ((bios_if & wait_flags) != 0) break;
            }
        },
        0x05 => { // VBlankIntrWait
            r[0] = 1;
            r[1] = 1;
            swi(ctx, 0x04);
        },
        0x06 => { // Div: r0 / r1
            const num: i32 = @bitCast(r[0]);
            const den: i32 = @bitCast(r[1]);
            if (den != 0) {
                const q: i64 = @divTrunc(@as(i64, num), @as(i64, den));
                const rem: i64 = @rem(@as(i64, num), @as(i64, den));
                r[0] = @truncate(@as(u64, @bitCast(q)));
                r[1] = @truncate(@as(u64, @bitCast(rem)));
                const abs_q: u64 = if (q < 0) @intCast(-q) else @intCast(q);
                r[3] = @truncate(abs_q);
            }
            divCycles(ctx, num, den);
        },
        0x07 => { // DivArm: r1 / r0
            const den: i32 = @bitCast(r[0]);
            const num: i32 = @bitCast(r[1]);
            if (den != 0) {
                const q: i64 = @divTrunc(@as(i64, num), @as(i64, den));
                const rem: i64 = @rem(@as(i64, num), @as(i64, den));
                r[0] = @truncate(@as(u64, @bitCast(q)));
                r[1] = @truncate(@as(u64, @bitCast(rem)));
                const abs_q: u64 = if (q < 0) @intCast(-q) else @intCast(q);
                r[3] = @truncate(abs_q);
            }
            divCycles(ctx, num, den);
        },
        0x08 => { // Sqrt
            var val = r[0];
            var result: u32 = 0;
            var bit: u32 = @as(u32, 1) << 30;
            while (bit > val) bit >>= 2;
            while (bit != 0) {
                if (val >= result + bit) {
                    val -= result + bit;
                    result = (result >> 1) + bit;
                } else {
                    result >>= 1;
                }
                bit >>= 2;
            }
            r[0] = result;
        },
        0x09 => { // ArcTan
            const a16: i16 = @bitCast(@as(u16, @truncate(r[0])));
            const a: i32 = a16;
            const res: i32 = a -% @divTrunc(@divTrunc(a *% a *% a, 3), @as(i32, 1) << 28);
            const res16: i16 = @truncate(res);
            r[0] = @bitCast(@as(i32, res16));
        },
        0x0A => { // ArcTan2
            const x: i16 = @bitCast(@as(u16, @truncate(r[0])));
            const y: i16 = @bitCast(@as(u16, @truncate(r[1])));
            if (x == 0 and y == 0) {
                r[0] = 0;
            } else {
                const angle = std.math.atan2(@as(f64, @floatFromInt(y)), @as(f64, @floatFromInt(x)));
                var normalized = angle / (2.0 * std.math.pi) + 0.5;
                if (normalized < 0.0) normalized += 1.0;
                if (normalized >= 1.0) normalized -= 1.0;
                const scaled: u32 = @intFromFloat(@max(0.0, normalized * 65536.0));
                r[0] = @as(u16, @truncate(scaled));
            }
        },
        0x0B, 0x0C => { // CpuSet / CpuFastSet
            const src = r[0];
            const dst = r[1];
            const cnt = r[2];
            var count = cnt & 0x1F_FFFF;
            const fill = ((cnt >> 24) & 1) != 0;
            const word = (number == 0x0C) or (((cnt >> 26) & 1) != 0);

            if (number == 0x0C) {
                count = (count +% 7) & ~@as(u32, 7);
            }

            if (word) {
                const fill_val = ctx.busRead32(src);
                var i: u32 = 0;
                while (i < count) : (i += 1) {
                    const burst = (number == 0x0C) and ((i & 7) != 0);
                    const val = if (fill)
                        fill_val
                    else if (burst)
                        ctx.busRead32s(src +% i *% 4)
                    else
                        ctx.busRead32(src +% i *% 4);
                    ctx.setVramBurst(burst);
                    ctx.busWrite32(dst +% i *% 4, val);
                    ctx.setVramBurst(false);
                    if (number == 0x0B) {
                        ctx.advanceCycles(4);
                    } else if ((i & 7) == 7) {
                        ctx.advanceCycles(5);
                    }
                    if (ctx.softResetPending()) return;
                }
            } else {
                const fill_val = ctx.busRead16(src);
                var i: u32 = 0;
                while (i < count) : (i += 1) {
                    const val = if (fill) fill_val else ctx.busRead16(src +% i *% 2);
                    ctx.busWrite16(dst +% i *% 2, val);
                    ctx.advanceCycles(4);
                    if (ctx.softResetPending()) return;
                }
            }
        },
        0x0E => { // BgAffineSet
            var src = r[0];
            var dst = r[1];
            const count = r[2];
            var i: u32 = 0;
            while (i < count) : ({
                i += 1;
                src +%= 20;
                dst +%= 16;
            }) {
                const ox: f32 = @as(f32, @floatFromInt(@as(i32, @bitCast(ctx.busRead32(src))))) / 256.0;
                const oy: f32 = @as(f32, @floatFromInt(@as(i32, @bitCast(ctx.busRead32(src +% 4))))) / 256.0;
                const cx: f32 = @floatFromInt(@as(i16, @bitCast(ctx.busRead16(src +% 8))));
                const cy: f32 = @floatFromInt(@as(i16, @bitCast(ctx.busRead16(src +% 10))));
                const sx: f32 = @as(f32, @floatFromInt(@as(i16, @bitCast(ctx.busRead16(src +% 12))))) / 256.0;
                const sy: f32 = @as(f32, @floatFromInt(@as(i16, @bitCast(ctx.busRead16(src +% 14))))) / 256.0;
                const th: f32 = (@as(f32, @floatFromInt(ctx.busRead16(src +% 16) >> 8)) / 128.0) * 3.14159265;
                const a: f32 = @cos(th) * sx;
                const b: f32 = -@sin(th) * sx;
                const c: f32 = @sin(th) * sy;
                const d: f32 = @cos(th) * sy;

                ctx.busWrite16(dst, @bitCast(@as(i16, @truncate(@as(i32, @intFromFloat(a * 256.0))))));
                ctx.busWrite16(dst +% 2, @bitCast(@as(i16, @truncate(@as(i32, @intFromFloat(b * 256.0))))));
                ctx.busWrite16(dst +% 4, @bitCast(@as(i16, @truncate(@as(i32, @intFromFloat(c * 256.0))))));
                ctx.busWrite16(dst +% 6, @bitCast(@as(i16, @truncate(@as(i32, @intFromFloat(d * 256.0))))));
                ctx.busWrite32(dst +% 8, @bitCast(@as(i32, @intFromFloat((ox - (a * cx + b * cy)) * 256.0))));
                ctx.busWrite32(dst +% 12, @bitCast(@as(i32, @intFromFloat((oy - (c * cx + d * cy)) * 256.0))));
            }
        },
        0x0F => { // ObjAffineSet
            var src = r[0];
            var dst = r[1];
            const count = r[2];
            const stride = r[3];
            var i: u32 = 0;
            while (i < count) : ({
                i += 1;
                src +%= 8;
                dst +%= stride *% 4;
            }) {
                const sx: f32 = @as(f32, @floatFromInt(@as(i16, @bitCast(ctx.busRead16(src))))) / 256.0;
                const sy: f32 = @as(f32, @floatFromInt(@as(i16, @bitCast(ctx.busRead16(src +% 2))))) / 256.0;
                const th: f32 = (@as(f32, @floatFromInt(ctx.busRead16(src +% 4) >> 8)) / 128.0) * 3.14159265;
                ctx.busWrite16(dst, @bitCast(@as(i16, @truncate(@as(i32, @intFromFloat(@cos(th) * sx * 256.0))))));
                ctx.busWrite16(dst +% stride, @bitCast(@as(i16, @truncate(@as(i32, @intFromFloat(-@sin(th) * sx * 256.0))))));
                ctx.busWrite16(dst +% stride *% 2, @bitCast(@as(i16, @truncate(@as(i32, @intFromFloat(@sin(th) * sy * 256.0))))));
                ctx.busWrite16(dst +% stride *% 3, @bitCast(@as(i16, @truncate(@as(i32, @intFromFloat(@cos(th) * sy * 256.0))))));
            }
        },
        0x10 => { // BitUnPack
            const src = r[0];
            const dst = r[1];
            const info = r[2];
            const src_len = ctx.busRead16(info);
            const src_bpp = ctx.busRead8(info +% 2);
            const dst_bpp = ctx.busRead8(info +% 3);
            if (src_bpp == 0) return;
            const raw_off = ctx.busRead32(info +% 4);
            const zero_flag = ((raw_off >> 31) & 1) != 0;
            const data_offset = raw_off & 0x7FFF_FFFF;

            var src_off: u32 = 0;
            var dst_off: u32 = 0;
            var buffer: u32 = 0;
            var bits_in_buffer: u32 = 0;
            const src_mask: u8 = @truncate((@as(u16, 1) << @intCast(@min(src_bpp, 8))) - 1);

            while (src_off < src_len) {
                const byte = ctx.busRead8(src +% src_off);
                src_off +%= 1;
                var bit: u32 = 0;
                while (bit < 8) : (bit += src_bpp) {
                    var val: u32 = (byte >> @intCast(bit)) & src_mask;
                    if (val != 0 or !zero_flag) {
                        val +%= data_offset;
                    }
                    if (bits_in_buffer < 32) {
                        buffer |= val << @intCast(bits_in_buffer);
                    }
                    bits_in_buffer += dst_bpp;
                    if (bits_in_buffer >= 32) {
                        ctx.busWrite32(dst +% dst_off, buffer);
                        dst_off +%= 4;
                        buffer = 0;
                        bits_in_buffer = 0;
                    }
                }
            }
            if (bits_in_buffer > 0) {
                ctx.busWrite32(dst +% dst_off, buffer);
            }
        },
        0x11 => { // LZ77UnCompWram
            const src = r[0];
            const dst = r[1];
            const header = ctx.busRead32(src);
            ctx.advanceCycles(20);
            const decomp_size = header >> 8;
            var sp = src +% 4;
            var dp: u32 = 0;

            while (dp < decomp_size) {
                const flags = ctx.busRead8(sp);
                sp +%= 1;
                ctx.advanceCycles(14);
                var i: i32 = 7;
                while (i >= 0 and dp < decomp_size) : (i -= 1) {
                    ctx.advanceCycles(32);
                    if ((flags & (@as(u8, 1) << @intCast(i))) != 0) {
                        const b1 = ctx.busRead8(sp);
                        const b2 = ctx.busRead8(sp +% 1);
                        sp +%= 2;
                        const length: u32 = ((b1 >> 4) & 0xF) + 3;
                        const disp: u32 = (@as(u32, b1 & 0xF) << 8) | b2;
                        const ref: u32 = dp -% disp -% 1;
                        var j: u32 = 0;
                        while (j < length and dp < decomp_size) : (j += 1) {
                            ctx.advanceCycles(10);
                            ctx.busWrite8(dst +% dp, ctx.busRead8(dst +% ref +% j));
                            dp +%= 1;
                        }
                    } else {
                        ctx.busWrite8(dst +% dp, ctx.busRead8(sp));
                        sp +%= 1;
                        dp +%= 1;
                    }
                }
            }
        },
        0x12 => { // LZ77UnCompVram (16-bit writes)
            const src = r[0];
            const dst = r[1];
            const header = ctx.busRead32(src);
            ctx.advanceCycles(20);
            const decomp_size = header >> 8;
            var sp = src +% 4;
            var dp: u32 = 0;
            var tmp_buf = [2]u8{ 0, 0 };
            var tmp_idx: usize = 0;

            while (dp < decomp_size) {
                const flags = ctx.busRead8(sp);
                sp +%= 1;
                ctx.advanceCycles(14);
                var i: i32 = 7;
                while (i >= 0 and dp < decomp_size) : (i -= 1) {
                    ctx.advanceCycles(32);
                    if ((flags & (@as(u8, 1) << @intCast(i))) != 0) {
                        const b1 = ctx.busRead8(sp);
                        const b2 = ctx.busRead8(sp +% 1);
                        sp +%= 2;
                        const length: u32 = ((b1 >> 4) & 0xF) + 3;
                        const disp: u32 = (@as(u32, b1 & 0xF) << 8) | b2;
                        const ref: u32 = dp -% disp -% 1;
                        var j: u32 = 0;
                        while (j < length and dp < decomp_size) : (j += 1) {
                            ctx.advanceCycles(14);
                            tmp_buf[tmp_idx] = ctx.busRead8(dst +% ref +% j);
                            tmp_idx += 1;
                            if (tmp_idx == 2) {
                                ctx.busWrite16(dst +% dp -% 1, @as(u16, tmp_buf[0]) | (@as(u16, tmp_buf[1]) << 8));
                                tmp_idx = 0;
                            }
                            dp +%= 1;
                        }
                    } else {
                        tmp_buf[tmp_idx] = ctx.busRead8(sp);
                        sp +%= 1;
                        tmp_idx += 1;
                        if (tmp_idx == 2) {
                            ctx.busWrite16(dst +% dp -% 1, @as(u16, tmp_buf[0]) | (@as(u16, tmp_buf[1]) << 8));
                            tmp_idx = 0;
                        }
                        dp +%= 1;
                    }
                }
            }
        },
        0x13 => { // HuffUnComp
            ctx.warnUnhandledSwi(number);
        },
        0x14 => { // RLUnCompWram
            const src = r[0];
            const dst = r[1];
            const header = ctx.busRead32(src);
            const decomp_size = header >> 8;
            var sp = src +% 4;
            var dp: u32 = 0;

            while (dp < decomp_size) {
                const flag = ctx.busRead8(sp);
                sp +%= 1;
                if ((flag & 0x80) != 0) {
                    const length: u32 = (flag & 0x7F) + 3;
                    const val = ctx.busRead8(sp);
                    sp +%= 1;
                    var j: u32 = 0;
                    while (j < length and dp < decomp_size) : (j += 1) {
                        ctx.busWrite8(dst +% dp, val);
                        dp +%= 1;
                    }
                } else {
                    const length: u32 = (flag & 0x7F) + 1;
                    var j: u32 = 0;
                    while (j < length and dp < decomp_size) : (j += 1) {
                        ctx.busWrite8(dst +% dp, ctx.busRead8(sp));
                        sp +%= 1;
                        dp +%= 1;
                    }
                }
            }
        },
        0x15 => { // RLUnCompVram (16-bit writes)
            const src = r[0];
            const dst = r[1];
            const header = ctx.busRead32(src);
            const decomp_size = header >> 8;
            var sp = src +% 4;
            var dp: u32 = 0;
            var tmp_buf = [2]u8{ 0, 0 };
            var tmp_idx: usize = 0;

            while (dp < decomp_size) {
                const flag = ctx.busRead8(sp);
                sp +%= 1;
                if ((flag & 0x80) != 0) {
                    const length: u32 = (flag & 0x7F) + 3;
                    const val = ctx.busRead8(sp);
                    sp +%= 1;
                    var j: u32 = 0;
                    while (j < length and dp < decomp_size) : (j += 1) {
                        tmp_buf[tmp_idx] = val;
                        tmp_idx += 1;
                        if (tmp_idx == 2) {
                            ctx.busWrite16(dst +% dp -% 1, @as(u16, tmp_buf[0]) | (@as(u16, tmp_buf[1]) << 8));
                            tmp_idx = 0;
                        }
                        dp +%= 1;
                    }
                } else {
                    const length: u32 = (flag & 0x7F) + 1;
                    var j: u32 = 0;
                    while (j < length and dp < decomp_size) : (j += 1) {
                        tmp_buf[tmp_idx] = ctx.busRead8(sp);
                        sp +%= 1;
                        tmp_idx += 1;
                        if (tmp_idx == 2) {
                            ctx.busWrite16(dst +% dp -% 1, @as(u16, tmp_buf[0]) | (@as(u16, tmp_buf[1]) << 8));
                            tmp_idx = 0;
                        }
                        dp +%= 1;
                    }
                }
            }
        },
        else => ctx.warnUnhandledSwi(number),
    }
}

test "BIOS SWI Div, Sqrt, ArcTan2, CpuSet, CpuFastSet, BitUnPack, LZ77, RL, BgAffineSet, SoftReset" {
    const MockBiosCtx = struct {
        r: [16]u32 = @splat(0),
        ewram_mem: [0x40000]u8 = @splat(0),
        iwram_mem: [0x8000]u8 = @splat(0),
        io_mem: [0x400]u8 = @splat(0),
        pal_mem: [0x400]u8 = @splat(0),
        vram_mem: [0x18000]u8 = @splat(0),
        oam_mem: [0x400]u8 = @splat(0),
        cpsr_val: u32 = 0x1F,
        mode: BusMode = .rom_code,
        vram_burst_val: bool = false,
        cycles_total: u32 = 0,
        reset_pending: bool = false,

        pub fn regs(self: *@This()) *[16]u32 {
            return &self.r;
        }
        pub fn ewram(self: *@This()) *[0x40000]u8 {
            return &self.ewram_mem;
        }
        pub fn iwram(self: *@This()) *[0x8000]u8 {
            return &self.iwram_mem;
        }
        pub fn palette(self: *@This()) *[0x400]u8 {
            return &self.pal_mem;
        }
        pub fn vram(self: *@This()) *[0x18000]u8 {
            return &self.vram_mem;
        }
        pub fn oam(self: *@This()) *[0x400]u8 {
            return &self.oam_mem;
        }
        pub fn ioRead16(self: *const @This(), off: u32) u16 {
            return @as(u16, self.io_mem[off]) | (@as(u16, self.io_mem[off + 1]) << 8);
        }
        pub fn accessCycles(_: *const @This(), _: u32, _: bool) u32 {
            return 5;
        }
        pub fn advanceCycles(self: *@This(), c: u32) void {
            self.cycles_total +%= c;
        }
        pub fn getBusMode(self: *const @This()) BusMode {
            return self.mode;
        }
        pub fn setBusMode(self: *@This(), m: BusMode) void {
            self.mode = m;
        }
        pub fn setVramBurst(self: *@This(), b: bool) void {
            self.vram_burst_val = b;
        }
        pub fn setCpsrRaw(self: *@This(), val: u32) void {
            self.cpsr_val = val;
        }
        pub fn triggerSoftReset(self: *@This()) void {
            self.reset_pending = true;
        }
        pub fn softResetPending(self: *const @This()) bool {
            return self.reset_pending;
        }
        pub fn logSwi(_: *@This(), _: u32) void {}
        pub fn warnUnhandledSwi(_: *@This(), _: u32) void {}

        fn mapPtr(self: *@This(), addr: u32) []u8 {
            return switch (addr >> 24) {
                0x02 => self.ewram_mem[(addr & 0x3FFFF)..],
                0x03 => self.iwram_mem[(addr & 0x7FFF)..],
                0x06 => self.vram_mem[(addr & 0x1FFFF)..],
                else => unreachable,
            };
        }
        pub fn busRead8(self: *@This(), addr: u32) u8 {
            return self.mapPtr(addr)[0];
        }
        pub fn busWrite8(self: *@This(), addr: u32, v: u8) void {
            self.mapPtr(addr)[0] = v;
        }
        pub fn busRead16(self: *@This(), addr: u32) u16 {
            return std.mem.readInt(u16, self.mapPtr(addr & ~@as(u32, 1))[0..2], .little);
        }
        pub fn busWrite16(self: *@This(), addr: u32, v: u16) void {
            std.mem.writeInt(u16, self.mapPtr(addr & ~@as(u32, 1))[0..2], v, .little);
        }
        pub fn busRead32(self: *@This(), addr: u32) u32 {
            return std.mem.readInt(u32, self.mapPtr(addr & ~@as(u32, 3))[0..4], .little);
        }
        pub fn busRead32s(self: *@This(), addr: u32) u32 {
            return self.busRead32(addr);
        }
        pub fn busWrite32(self: *@This(), addr: u32, v: u32) void {
            std.mem.writeInt(u32, self.mapPtr(addr & ~@as(u32, 3))[0..4], v, .little);
        }
    };

    var ctx: MockBiosCtx = .{};

    // SWI 0x06 Div (-100 / 7 = -14 rem -2, |q|=14)
    ctx.r[0] = @bitCast(@as(i32, -100));
    ctx.r[1] = 7;
    swi(&ctx, 0x06);
    try std.testing.expectEqual(@as(i32, -14), @as(i32, @bitCast(ctx.r[0])));
    try std.testing.expectEqual(@as(i32, -2), @as(i32, @bitCast(ctx.r[1])));
    try std.testing.expectEqual(@as(u32, 14), ctx.r[3]);

    // SWI 0x08 Sqrt
    ctx.r[0] = 1524157875;
    swi(&ctx, 0x08);
    try std.testing.expectEqual(@as(u32, 39040), ctx.r[0]);

    // SWI 0x0C CpuFastSet fill 8 words
    ctx.busWrite32(0x0200_0000, 0xDEAD_BEEF);
    ctx.r[0] = 0x0200_0000;
    ctx.r[1] = 0x0200_0100;
    ctx.r[2] = (1 << 24) | 8;
    swi(&ctx, 0x0C);
    try std.testing.expectEqual(@as(u32, 0xDEAD_BEEF), ctx.busRead32(0x0200_011C));

    // SWI 0x10 BitUnPack 1bpp -> 4bpp with offset=1, zero_flag=1
    ctx.busWrite8(0x0200_0200, 0b1010_0101);
    ctx.busWrite16(0x0200_0210, 1); // src_len
    ctx.busWrite8(0x0200_0212, 1); // src_bpp
    ctx.busWrite8(0x0200_0213, 4); // dst_bpp
    ctx.busWrite32(0x0200_0214, 0x8000_0001); // zero_flag + offset 1
    ctx.r[0] = 0x0200_0200;
    ctx.r[1] = 0x0200_0220;
    ctx.r[2] = 0x0200_0210;
    swi(&ctx, 0x10);
    // bits LSB->MSB: 1,0,1,0,0,1,0,1 -> mapped (val? val+1 : 0): 2,0,2,0, 0,2,0,2
    try std.testing.expectEqual(@as(u32, 0x2020_0202), ctx.busRead32(0x0200_0220));

    // SWI 0x11 LZ77UnCompWram ("AAAA" = decomp size 4, flag 0x80, len 4 -> b1=0x1_, disp=0 -> 0x10 0x00)
    ctx.busWrite32(0x0200_0300, (5 << 8) | 0x10);
    ctx.busWrite8(0x0200_0304, 0x40); // bit6 compressed
    ctx.busWrite8(0x0200_0305, 'A');
    ctx.busWrite8(0x0200_0306, 0x10); // len = 1 + 3 = 4
    ctx.busWrite8(0x0200_0307, 0x00); // disp = 0 (ref = dp - 1)
    ctx.r[0] = 0x0200_0300;
    ctx.r[1] = 0x0200_0320;
    swi(&ctx, 0x11);
    try std.testing.expectEqualStrings("AAAAA", ctx.ewram_mem[0x0320..0x0325]);

    // SWI 0x12 LZ77UnCompVram (2 literals 'A','A' flush halfword to VRAM, then back-ref len=3, disp=1 -> 5 bytes 'AAAAA')
    ctx.busWrite32(0x0200_0400, (5 << 8) | 0x10);
    ctx.busWrite8(0x0200_0404, 0x20); // bit 7=0 ('A'), bit 6=0 ('A'), bit 5=1 (copy)
    ctx.busWrite8(0x0200_0405, 'A');
    ctx.busWrite8(0x0200_0406, 'A');
    ctx.busWrite8(0x0200_0407, 0x00); // len = 0 + 3 = 3
    ctx.busWrite8(0x0200_0408, 0x01); // disp = 1 -> ref = dp - 2 (already flushed in VRAM!)
    ctx.r[0] = 0x0200_0400;
    ctx.r[1] = 0x0600_0000;
    swi(&ctx, 0x12);
    try std.testing.expectEqualStrings("AAAA", ctx.vram_mem[0..4]);

    // SWI 0x14 RLUnCompWram ("XXXXYY")
    ctx.busWrite32(0x0200_0500, (6 << 8) | 0x30);
    ctx.busWrite8(0x0200_0504, 0x81); // RLE len = 4
    ctx.busWrite8(0x0200_0505, 'X');
    ctx.busWrite8(0x0200_0506, 0x01); // uncompressed len = 2
    ctx.busWrite8(0x0200_0507, 'Y');
    ctx.busWrite8(0x0200_0508, 'Z');
    ctx.r[0] = 0x0200_0500;
    ctx.r[1] = 0x0200_0520;
    swi(&ctx, 0x14);
    try std.testing.expectEqualStrings("XXXXYZ", ctx.ewram_mem[0x0520..0x0526]);

    // SWI 0x0E BgAffineSet identity at (10, 20), center (0, 0), scale (1, 1), angle 0
    ctx.busWrite32(0x0200_0600, 10 << 8);
    ctx.busWrite32(0x0200_0604, 20 << 8);
    ctx.busWrite16(0x0200_0608, 0);
    ctx.busWrite16(0x0200_060A, 0);
    ctx.busWrite16(0x0200_060C, 0x0100);
    ctx.busWrite16(0x0200_060E, 0x0100);
    ctx.busWrite16(0x0200_0610, 0);
    ctx.r[0] = 0x0200_0600;
    ctx.r[1] = 0x0200_0640;
    ctx.r[2] = 1;
    swi(&ctx, 0x0E);
    try std.testing.expectEqual(@as(u16, 0x0100), ctx.busRead16(0x0200_0640));
    try std.testing.expectEqual(@as(u16, 0x0100), ctx.busRead16(0x0200_0646));
    try std.testing.expectEqual(@as(u32, 10 << 8), ctx.busRead32(0x0200_0648));
    try std.testing.expectEqual(@as(u32, 20 << 8), ctx.busRead32(0x0200_064C));

    // SWI 0x00 SoftReset
    swi(&ctx, 0x00);
    try std.testing.expect(ctx.reset_pending);
    try std.testing.expectEqual(@as(u32, 0x0300_7F00), ctx.r[13]);
    try std.testing.expectEqual(@as(u32, 0x0800_0000), ctx.r[15]);
}
