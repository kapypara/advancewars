const std = @import("std");
const builtin = @import("builtin");
const gba = @import("../gba/defs.zig");

const has_posix_stdio = builtin.os.tag != .freestanding;

const c_stdio = if (has_posix_stdio) struct {
    const FILE = std.c.FILE;
    extern "c" fn fopen(filename: [*:0]const u8, mode: [*:0]const u8) ?*FILE;
    extern "c" fn fclose(stream: *FILE) c_int;
    extern "c" fn fwrite(ptr: [*]const u8, size: usize, nmemb: usize, stream: *FILE) usize;
    extern "c" fn fgets(buf: [*]u8, size: c_int, stream: *FILE) ?[*]u8;
    extern "c" fn popen(command: [*:0]const u8, mode: [*:0]const u8) ?*FILE;
    extern "c" fn pclose(stream: *FILE) c_int;
    extern "c" fn fflush(stream: *FILE) c_int;
    extern "c" fn mkdir(path: [*:0]const u8, mode: u32) c_int;
} else struct {
    const FILE = opaque {};
};

pub const max_dumps: usize = 16;

pub const DumpPoint = struct {
    frame: i64 = 0,
    path: ?[*:0]const u8 = null,
};

pub const InputEvent = struct {
    frame: i64,
    keys: u16,
};

/// Build the 54-byte top-down 32-bit BGRA BMP header matching `display.c:write_bmp`.
pub fn makeBmpHeader(w_px: u32, h_px: u32) [54]u8 {
    var header: [54]u8 = @splat(0);
    const data_bytes: u32 = w_px * h_px * 4;
    const file_size: u32 = 54 + data_bytes;
    const w_i32: i32 = @intCast(w_px);
    const h_neg: i32 = -@as(i32, @intCast(h_px));

    header[0] = 'B';
    header[1] = 'M';
    std.mem.writeInt(u32, header[2..6], file_size, .little);
    std.mem.writeInt(u32, header[10..14], 54, .little);
    std.mem.writeInt(u32, header[14..18], 40, .little);
    std.mem.writeInt(i32, header[18..22], w_i32, .little);
    std.mem.writeInt(i32, header[22..26], h_neg, .little);
    std.mem.writeInt(u16, header[26..28], 1, .little);
    std.mem.writeInt(u16, header[28..30], 32, .little);
    std.mem.writeInt(u32, header[34..38], data_bytes, .little);
    return header;
}

/// Parse one line of an input script (`"<frame> <hex_keys>"`, ignoring `#` comments and blanks).
pub fn parseInputLine(raw_line: []const u8) ?InputEvent {
    const trimmed = std.mem.trim(u8, raw_line, " \t\r\n");
    if (trimmed.len == 0 or trimmed[0] == '#') return null;

    var it = std.mem.tokenizeAny(u8, trimmed, " \t");
    const frame_tok = it.next() orelse return null;
    const keys_tok = it.next() orelse return null;

    const frame = std.fmt.parseInt(i64, frame_tok, 10) catch return null;
    const hex_str = if (std.mem.startsWith(u8, keys_tok, "0x") or std.mem.startsWith(u8, keys_tok, "0X"))
        keys_tok[2..]
    else
        keys_tok;
    const keys_u32 = std.fmt.parseInt(u32, hex_str, 16) catch return null;
    return .{
        .frame = frame,
        .keys = @truncate(keys_u32),
    };
}

/// Write a `240x160` ARGB8888 framebuffer to a 32-bit BMP file.
pub fn writeBmp(path: [*:0]const u8, framebuf: *const [gba.width * gba.height]u32) bool {
    if (!has_posix_stdio) return false;
    const f = c_stdio.fopen(path, "wb") orelse return false;
    defer _ = c_stdio.fclose(f);

    const header = makeBmpHeader(@intCast(gba.width), @intCast(gba.height));
    if (c_stdio.fwrite(&header, 1, header.len, f) != header.len) return false;

    const pixel_bytes: [*]const u8 = @ptrCast(framebuf);
    const total_bytes = gba.width * gba.height * @sizeOf(u32);
    return c_stdio.fwrite(pixel_bytes, 1, total_bytes, f) == total_bytes;
}

/// CLI config, input-script playback, screenshot capture, and headless ffmpeg recording.
pub const Runner = struct {
    headless: bool = false,
    log_every: i64 = 300,
    max_frames: i64 = 0,
    frame_no: i64 = 0,
    script_keys_pressed: u16 = 0,

    rom_path: ?[*:0]const u8 = null,
    save_path: ?[*:0]const u8 = null,
    record_path: ?[*:0]const u8 = null,
    shot_path: ?[*:0]const u8 = null,
    input_path: ?[*:0]const u8 = null,
    dump_dir: ?[*:0]const u8 = null,

    dumps: [max_dumps]DumpPoint = @splat(.{}),
    num_dumps: usize = 0,

    dump_path_buf: [512]u8 = @splat(0),
    dump_log: ?*c_stdio.FILE = null,
    record_pipe: ?*c_stdio.FILE = null,
    input_file: ?*c_stdio.FILE = null,
    next_input_frame: i64 = -1,
    next_input_keys: u16 = 0,

    pub fn parseArgs(self: *Runner, argv: []const [*:0]const u8, default_headless: bool) ?[*:0]const u8 {
        self.* = .{};
        if (default_headless) self.headless = true;

        var i: usize = 1;
        while (i < argv.len) : (i += 1) {
            const arg = std.mem.span(argv[i]);
            if (std.mem.eql(u8, arg, "--headless")) {
                self.headless = true;
            } else if (std.mem.eql(u8, arg, "--record") and i + 1 < argv.len) {
                i += 1;
                self.record_path = argv[i];
                self.headless = true;
            } else if (std.mem.eql(u8, arg, "--frames") and i + 1 < argv.len) {
                i += 1;
                self.max_frames = std.fmt.parseInt(i64, std.mem.span(argv[i]), 10) catch 0;
            } else if (std.mem.eql(u8, arg, "--log-every") and i + 1 < argv.len) {
                i += 1;
                self.log_every = std.fmt.parseInt(i64, std.mem.span(argv[i]), 10) catch 300;
            } else if (std.mem.eql(u8, arg, "--dump-at") and i + 2 < argv.len and self.num_dumps < max_dumps) {
                i += 1;
                const frame = std.fmt.parseInt(i64, std.mem.span(argv[i]), 10) catch 0;
                i += 1;
                self.dumps[self.num_dumps] = .{ .frame = frame, .path = argv[i] };
                self.num_dumps += 1;
            } else if (std.mem.eql(u8, arg, "--dump-dir") and i + 1 < argv.len) {
                i += 1;
                self.dump_dir = argv[i];
            } else if (std.mem.eql(u8, arg, "--screenshot") and i + 1 < argv.len) {
                i += 1;
                self.shot_path = argv[i];
            } else if (std.mem.eql(u8, arg, "--save") and i + 1 < argv.len) {
                i += 1;
                self.save_path = argv[i];
            } else if (std.mem.eql(u8, arg, "--input") and i + 1 < argv.len) {
                i += 1;
                self.input_path = argv[i];
                if (has_posix_stdio) {
                    self.input_file = c_stdio.fopen(argv[i], "r");
                    if (self.input_file == null) {
                        gba.logPrint("[display] cannot open input script {s}\n", .{std.mem.span(argv[i])});
                    }
                }
            } else if (arg.len > 0 and arg[0] != '-' and self.rom_path == null) {
                self.rom_path = argv[i];
            } else {
                gba.logPrint("[display] unknown option {s}\n", .{arg});
            }
        }
        return self.rom_path;
    }

    pub fn dumpPath(self: *Runner, frame: i64) ?[*:0]const u8 {
        for (self.dumps[0..self.num_dumps]) |d| {
            if (d.frame == frame) return d.path;
        }
        if (self.dump_dir) |dir| {
            if (frame < 0) return null;
            const f_u64: u64 = @intCast(frame);
            const path = std.mem.printSentinel(
                &self.dump_path_buf,
                "{s}/f{d:0>6}.bin",
                .{ std.mem.span(dir), f_u64 },
                0,
            ) catch return null;
            return path.ptr;
        }
        return null;
    }

    /// Skip PPU scanline rasterization on discarded headless frames for speed.
    pub fn shouldRenderScanline(self: *const Runner) bool {
        if (!self.headless) return true;
        if (self.record_path != null) return true;
        if (self.dump_dir != null) return true;
        if (self.shot_path != null) {
            return self.max_frames == 0 or (self.frame_no + 1 >= self.max_frames);
        }
        return false;
    }

    pub fn initDumpDir(self: *Runner) bool {
        const dir = self.dump_dir orelse return true;
        if (!has_posix_stdio) return false;

        _ = c_stdio.mkdir(dir, 0o755);
        var log_path_buf: [512]u8 = undefined;
        const log_path = std.mem.printSentinel(
            &log_path_buf,
            "{s}/frames.log",
            .{std.mem.span(dir)},
            0,
        ) catch return false;
        self.dump_log = c_stdio.fopen(log_path.ptr, "wb");
        if (self.dump_log == null) {
            gba.logPrint("[dump-dir] cannot open {s}\n", .{std.mem.span(log_path.ptr)});
            return false;
        }
        gba.logPrint("[dump-dir] continuous frame+state dump -> {s}\n", .{std.mem.span(dir)});
        return true;
    }

    pub fn dumpFrameBmp(self: *Runner, framebuf: *const [gba.width * gba.height]u32) void {
        const dir = self.dump_dir orelse return;
        if (!has_posix_stdio) return;

        var bmp_path_buf: [512]u8 = undefined;
        const f_u64: u64 = @intCast(@max(self.frame_no, 0));
        const bmp_path = std.mem.printSentinel(
            &bmp_path_buf,
            "{s}/f{d:0>6}.bmp",
            .{ std.mem.span(dir), f_u64 },
            0,
        ) catch return;
        _ = writeBmp(bmp_path.ptr, framebuf);

        if (self.frame_no == 1 or @mod(self.frame_no, 60) == 0) {
            gba.logPrint("[dump-dir] frame {d}\n", .{self.frame_no});
        }
    }

    pub fn writeDumpLogLine(self: *Runner, line: []const u8) void {
        if (!has_posix_stdio or line.len == 0) return;
        if (self.dump_log) |f| {
            _ = c_stdio.fwrite(line.ptr, 1, line.len, f);
            _ = c_stdio.fflush(f);
        }
    }

    pub fn initRecording(self: *Runner, win_width: u32, win_height: u32) bool {
        const rec_ptr = self.record_path orelse return true;
        if (!has_posix_stdio) return false;

        var cmd_buf: [1024]u8 = undefined;
        const cmd = std.mem.printSentinel(
            &cmd_buf,
            "ffmpeg -loglevel error -y -f rawvideo -pix_fmt bgra -s {d}x{d} -r 60 -i - " ++
                "-vf scale={d}:{d}:flags=neighbor -pix_fmt yuv420p \"{s}\"",
            .{ gba.width, gba.height, win_width, win_height, std.mem.span(rec_ptr) },
            0,
        ) catch return false;

        self.record_pipe = c_stdio.popen(cmd.ptr, "wb");
        if (self.record_pipe == null) {
            gba.logPrint("[display] cannot start ffmpeg\n", .{});
            return false;
        }
        return true;
    }

    pub fn stepInputScript(self: *Runner) void {
        if (!has_posix_stdio) return;
        while (self.input_file) |f| {
            if (self.next_input_frame < 0) {
                var line_buf: [128]u8 = undefined;
                const got = c_stdio.fgets(&line_buf, @intCast(line_buf.len), f);
                if (got == null) {
                    _ = c_stdio.fclose(f);
                    self.input_file = null;
                    return;
                }
                const line_slice = std.mem.sliceTo(&line_buf, 0);
                if (parseInputLine(line_slice)) |ev| {
                    self.next_input_frame = ev.frame;
                    self.next_input_keys = ev.keys;
                } else {
                    self.next_input_frame = -1;
                    continue;
                }
            }
            if (self.frame_no < self.next_input_frame) return;
            self.script_keys_pressed = self.next_input_keys;
            self.next_input_frame = -1;
        }
    }

    /// Advance frame counter, apply scripted inputs, write video/screenshot when due.
    /// Returns true if the caller should skip live window presentation (reached `max_frames` or headless).
    pub fn onFrame(self: *Runner, framebuf: *const [gba.width * gba.height]u32) bool {
        self.frame_no += 1;
        self.stepInputScript();
        if (has_posix_stdio) {
            if (self.record_pipe) |pipe| {
                const pixel_bytes: [*]const u8 = @ptrCast(framebuf);
                _ = c_stdio.fwrite(pixel_bytes, 4, gba.width * gba.height, pipe);
            }
        }
        if (self.max_frames > 0 and self.frame_no >= self.max_frames) {
            if (self.shot_path) |shot| {
                _ = writeBmp(shot, framebuf);
            }
            return true;
        }
        return self.headless;
    }

    pub fn reachedFrameLimit(self: *const Runner) bool {
        return self.max_frames > 0 and self.frame_no >= self.max_frames;
    }

    pub fn shutdown(self: *Runner, framebuf: *const [gba.width * gba.height]u32) void {
        if (self.shot_path) |shot| {
            if (!(self.max_frames > 0 and self.frame_no >= self.max_frames)) {
                _ = writeBmp(shot, framebuf);
            }
        }
        if (has_posix_stdio) {
            if (self.record_pipe) |pipe| {
                _ = c_stdio.fflush(pipe);
                _ = c_stdio.pclose(pipe);
                self.record_pipe = null;
            }
            if (self.input_file) |f| {
                _ = c_stdio.fclose(f);
                self.input_file = null;
            }
            if (self.dump_log) |f| {
                _ = c_stdio.fflush(f);
                _ = c_stdio.fclose(f);
                self.dump_log = null;
                if (self.dump_dir) |dir| {
                    gba.logPrint("[dump-dir] saved {d} frames in {s}\n", .{ self.frame_no, std.mem.span(dir) });
                }
            }
        }
    }
};

test "makeBmpHeader matches 240x160 top-down 32-bit BGRA format" {
    const hdr = makeBmpHeader(240, 160);
    try std.testing.expectEqual(@as(u8, 'B'), hdr[0]);
    try std.testing.expectEqual(@as(u8, 'M'), hdr[1]);
    try std.testing.expectEqual(@as(u32, 54 + 240 * 160 * 4), std.mem.readInt(u32, hdr[2..6], .little));
    try std.testing.expectEqual(@as(u32, 54), std.mem.readInt(u32, hdr[10..14], .little));
    try std.testing.expectEqual(@as(u32, 40), std.mem.readInt(u32, hdr[14..18], .little));
    try std.testing.expectEqual(@as(i32, 240), std.mem.readInt(i32, hdr[18..22], .little));
    try std.testing.expectEqual(@as(i32, -160), std.mem.readInt(i32, hdr[22..26], .little));
    try std.testing.expectEqual(@as(u16, 1), std.mem.readInt(u16, hdr[26..28], .little));
    try std.testing.expectEqual(@as(u16, 32), std.mem.readInt(u16, hdr[28..30], .little));
    try std.testing.expectEqual(@as(u32, 240 * 160 * 4), std.mem.readInt(u32, hdr[34..38], .little));
}

test "parseInputLine handles comments, blanks, and hex masks" {
    try std.testing.expect(parseInputLine("# comment") == null);
    try std.testing.expect(parseInputLine("   \r\n") == null);
    try std.testing.expect(parseInputLine("invalid") == null);

    const e1 = parseInputLine("600 008").?;
    try std.testing.expectEqual(@as(i64, 600), e1.frame);
    try std.testing.expectEqual(@as(u16, 0x0008), e1.keys);

    const e2 = parseInputLine("1500 0x001\r\n").?;
    try std.testing.expectEqual(@as(i64, 1500), e2.frame);
    try std.testing.expectEqual(@as(u16, 0x0001), e2.keys);
}

test "Runner.parseArgs parses CLI options and dump points" {
    const argv = [_][*:0]const u8{
        "awre",
        "game/aw.gba",
        "--headless",
        "--frames",
        "760",
        "--log-every",
        "0",
        "--dump-at",
        "615",
        "scratch/d.bin",
        "--screenshot",
        "scratch/shot.bmp",
    };

    var runner = Runner{};
    const rom = runner.parseArgs(&argv, false);
    try std.testing.expect(rom != null);
    try std.testing.expectEqualStrings("game/aw.gba", std.mem.span(rom.?));
    try std.testing.expect(runner.headless);
    try std.testing.expectEqual(@as(i64, 760), runner.max_frames);
    try std.testing.expectEqual(@as(i64, 0), runner.log_every);
    try std.testing.expectEqualStrings("scratch/d.bin", std.mem.span(runner.dumpPath(615).?));
    try std.testing.expect(runner.dumpPath(616) == null);
    try std.testing.expect(!runner.shouldRenderScanline());
    runner.frame_no = 759;
    try std.testing.expect(runner.shouldRenderScanline());
}

test "Runner.parseArgs supports continuous --dump-dir path formatting" {
    const argv = [_][*:0]const u8{
        "awre",
        "game/aw.gba",
        "--headless",
        "--dump-dir",
        "scratch/tmp_test",
    };

    var runner = Runner{};
    _ = runner.parseArgs(&argv, false);
    try std.testing.expect(runner.dump_dir != null);
    try std.testing.expectEqualStrings("scratch/tmp_test", std.mem.span(runner.dump_dir.?));
    try std.testing.expect(runner.shouldRenderScanline());
    try std.testing.expectEqualStrings("scratch/tmp_test/f000042.bin", std.mem.span(runner.dumpPath(42).?));
}
