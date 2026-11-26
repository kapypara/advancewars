const std = @import("std");
const core = @import("awre_core");

const gba = core.gba;
const Ppu = core.ppu.Ppu;
const Runner = core.headless.Runner;
const Backend = core.platform.Backend;

const default_scale: u32 = 3;

extern var io_regs: ?[*]u8;
extern var palette: ?[*]u8;
extern var vram: ?[*]u8;
extern var oam: ?[*]u8;

var s_ppu: Ppu = .{};
var s_runner: Runner = .{};
var s_backend: Backend = .{};
var s_live_keys_pressed: u16 = 0;

export fn display_parse_args(argc: c_int, argv: [*][*:0]u8) ?[*:0]const u8 {
    if (argc <= 0) return null;
    const count: usize = @intCast(argc);
    const args: [*]const [*:0]const u8 = @ptrCast(argv);
    return s_runner.parseArgs(args[0..count], core.is_headless);
}

export fn display_pace() void {
    if (!s_runner.headless) {
        s_backend.pace();
    }
}

export fn display_headless() c_int {
    return if (s_runner.headless) 1 else 0;
}

export fn display_log_every() c_long {
    return @intCast(s_runner.log_every);
}

export fn display_dump_path(frame: c_long) ?[*:0]const u8 {
    return s_runner.dumpPath(@intCast(frame));
}

export fn display_init() c_int {
    const win_w: u32 = @as(u32, @intCast(gba.width)) * default_scale;
    const win_h: u32 = @as(u32, @intCast(gba.height)) * default_scale;
    if (!s_runner.initRecording(win_w, win_h)) {
        return -1;
    }
    if (s_runner.headless) return 0;

    if (core.is_headless) {
        std.debug.print("[display] built without SDL2: run with --headless\n", .{});
        return -1;
    }

    if (!s_backend.init(win_w, win_h)) {
        return -1;
    }
    return 0;
}

export fn display_render_line(y: c_int) void {
    const io = io_regs orelse return;
    const vr = vram orelse return;
    const pal = palette orelse return;
    const om = oam orelse return;
    if (y < 0 or y >= @as(c_int, @intCast(gba.height))) return;
    if (!s_runner.shouldRenderScanline()) return;

    s_ppu.renderLine(.{
        .io_regs = io,
        .palette = pal,
        .vram = vr,
        .oam = om,
    }, @intCast(y));
}

export fn display_render_frame() void {
    if (io_regs == null or vram == null or palette == null or oam == null) return;
    if (s_runner.onFrame(&s_ppu.framebuf)) return;
    s_backend.present(&s_ppu.framebuf);
}

export fn display_poll_events() c_int {
    if (s_runner.reachedFrameLimit()) return 1;
    if (s_runner.headless) return 0;

    const res = s_backend.poll();
    s_live_keys_pressed = res.keys_pressed;
    return if (res.quit) 1 else 0;
}

export fn display_get_keys() u16 {
    const combined = s_runner.script_keys_pressed | s_live_keys_pressed;
    return gba.keyInputFromPressed(combined);
}

export fn display_shutdown() void {
    s_runner.shutdown(&s_ppu.framebuf);
    if (!s_runner.headless) {
        s_backend.shutdown();
    }
}
