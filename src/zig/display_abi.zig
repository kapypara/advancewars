const std = @import("std");
const core = @import("awre_core");

const gba = core.gba;
const audio = core.audio;
const Ppu = core.ppu.Ppu;
const Runner = core.headless.Runner;
const Backend = core.platform.Backend;
const PointerEvent = core.platform.PointerEvent;
const TouchController = core.touch.TouchController;
const GameState = core.touch.GameState;

const default_scale: u32 = 3;

extern var io_regs: ?[*]u8;
extern var palette: ?[*]u8;
extern var vram: ?[*]u8;
extern var oam: ?[*]u8;

extern fn bus_read8(addr: u32) u8;
extern fn bus_read16(addr: u32) u16;
extern fn bus_read32(addr: u32) u32;

var s_ppu: Ppu = .{};
var s_runner: Runner = .{};
var s_backend: Backend = .{};
var s_touch: TouchController = .{};
var s_audio: audio.Mixer = .{};
var s_present_buf: [gba.width * gba.height]u32 = @splat(0);
var s_pcm_a: [audio.max_frame_samples]i8 = @splat(0);
var s_pcm_b: [audio.max_frame_samples]i8 = @splat(0);
var s_stereo_out: [audio.max_out_stereo_i16]i16 = @splat(0);
var s_live_keys_pressed: u16 = 0;

inline fn readIo16(io: [*]const u8, off: u32) u16 {
    return @as(u16, io[off]) | (@as(u16, io[off + 1]) << 8);
}

inline fn readIo32(io: [*]const u8, off: u32) u32 {
    return @as(u32, io[off]) |
        (@as(u32, io[off + 1]) << 8) |
        (@as(u32, io[off + 2]) << 16) |
        (@as(u32, io[off + 3]) << 24);
}

fn readRamSignedBytes(addr: u32, dst: []i8) void {
    var i: usize = 0;
    if ((addr & 3) == 0) {
        while (i + 4 <= dst.len) : (i += 4) {
            const w = bus_read32(addr + @as(u32, @intCast(i)));
            dst[i + 0] = @bitCast(@as(u8, @truncate(w)));
            dst[i + 1] = @bitCast(@as(u8, @truncate(w >> 8)));
            dst[i + 2] = @bitCast(@as(u8, @truncate(w >> 16)));
            dst[i + 3] = @bitCast(@as(u8, @truncate(w >> 24)));
        }
    }
    while (i < dst.len) : (i += 1) {
        dst[i] = @bitCast(bus_read8(addr + @as(u32, @intCast(i))));
    }
}

fn sampleGameState() GameState {
    const io = io_regs orelse return .{};
    const dispcnt = readIo16(io, gba.io_reg.dispcnt);
    const mode = dispcnt & 7;
    const bg3_hofs = readIo16(io, gba.io_reg.bg3hofs) & 0x1FF;
    const bg3_vofs = readIo16(io, gba.io_reg.bg3vofs) & 0x1FF;

    const cursor_live = bus_read8(0x030036AC) == 1;
    const battle_mode = bus_read8(0x030033E0) == 1;
    const dialog_wait = bus_read8(0x03001D18) == 1;
    const cursor_x = bus_read16(0x030036A4);
    const cursor_y = bus_read16(0x030036A6);

    return .{
        .map_active = (mode == 0) and cursor_live and battle_mode and !dialog_wait,
        .dialog_waiting = dialog_wait,
        .title_mode4 = (mode == 4),
        .cursor_x = cursor_x,
        .cursor_y = cursor_y,
        .scroll_x = bg3_hofs,
        .scroll_y = bg3_vofs,
    };
}

fn pumpLiveAudio() void {
    const io = io_regs orelse return;
    const sound_info_ptr = bus_read32(audio.sound_info_ptr_addr);
    const valid_info = (sound_info_ptr >= 0x0300_0000 and sound_info_ptr + 8 <= 0x0300_8000) or
        (sound_info_ptr >= 0x0200_0000 and sound_info_ptr + 8 <= 0x0204_0000);
    if (!valid_info) return;

    const regs = audio.SoundRegs{
        .soundcnt_h = readIo16(io, audio.io_reg.soundcnt_h),
        .soundcnt_x = readIo16(io, audio.io_reg.soundcnt_x),
        .tm0_reload = readIo16(io, audio.io_reg.tm0cnt_l),
        .dma1_sad = readIo32(io, audio.io_reg.dma1_sad),
        .dma1_dad = readIo32(io, audio.io_reg.dma1_dad),
        .dma1_cnt_h = readIo16(io, audio.io_reg.dma1_cnt_h),
        .dma2_sad = readIo32(io, audio.io_reg.dma2_sad),
        .dma2_dad = readIo32(io, audio.io_reg.dma2_dad),
        .dma2_cnt_h = readIo16(io, audio.io_reg.dma2_cnt_h),
        .sound_info_ident = bus_read32(sound_info_ptr),
        .pcm_dma_counter = bus_read8(sound_info_ptr + 4),
    };

    const slot = audio.activeSlotParams(regs) orelse return;
    if (slot.has_a) {
        readRamSignedBytes(slot.addr_a, s_pcm_a[0..slot.sample_count]);
    } else {
        @memset(s_pcm_a[0..slot.sample_count], 0);
    }
    if (slot.has_b) {
        readRamSignedBytes(slot.addr_b, s_pcm_b[0..slot.sample_count]);
    } else {
        @memset(s_pcm_b[0..slot.sample_count], 0);
    }

    const out_len = s_audio.mixFrame(
        regs,
        slot.input_rate_hz,
        s_pcm_a[0..slot.sample_count],
        s_pcm_b[0..slot.sample_count],
        s_backend.queuedAudioBytes(),
        &s_stereo_out,
    );
    if (out_len > 0) {
        s_backend.pushAudio(s_stereo_out[0..out_len]);
    }
}

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

    pumpLiveAudio();
    const state = sampleGameState();
    s_touch.stepFrame(state);
    s_touch.renderOverlay(&s_ppu.framebuf, &s_present_buf);
    s_backend.present(&s_present_buf);
}

export fn display_poll_events() c_int {
    if (s_runner.reachedFrameLimit()) return 1;
    if (s_runner.headless) return 0;

    const res = s_backend.poll();
    s_live_keys_pressed = res.keys_pressed;
    if (res.toggle_hud) {
        s_touch.toggleHud();
    }
    if (res.toggle_mute) {
        s_audio.toggleMute();
    }

    var ptr_buf: [64]PointerEvent = undefined;
    const ptrs = s_backend.drainPointers(&ptr_buf);
    if (ptrs.len > 0) {
        const state = sampleGameState();
        for (ptrs) |ev| {
            s_touch.handlePointer(ev, state);
        }
    }

    return if (res.quit) 1 else 0;
}

export fn display_get_keys() u16 {
    const touch_keys: u16 = if (s_runner.headless) 0 else s_touch.activeKeys();
    const combined = s_runner.script_keys_pressed | s_live_keys_pressed | touch_keys;
    return gba.keyInputFromPressed(combined);
}

export fn display_shutdown() void {
    s_runner.shutdown(&s_ppu.framebuf);
    if (!s_runner.headless) {
        s_backend.shutdown();
    }
}
