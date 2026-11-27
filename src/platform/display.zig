const std = @import("std");
const builtin = @import("builtin");
const core = @import("awre_core");
const rt = @import("../runtime.zig");

const gba = core.gba;
const audio = core.audio;
const Ppu = core.ppu.Ppu;
const Runner = core.headless.Runner;
const Backend = core.platform.Backend;
const HudFrame = core.platform.HudFrame;
const PointerEvent = core.platform.PointerEvent;
const TouchController = core.touch.TouchController;
const GameState = core.touch.GameState;
const UiMode = core.touch.UiMode;

const is_freestanding = builtin.os.tag == .freestanding;
const default_scale: u32 = 3;

var s_ppu: Ppu = .{};
var s_runner: Runner = .{};
var s_backend: Backend = .{};
var s_touch: TouchController = .{};
var s_audio: audio.Mixer = .{};
var s_present_buf: [gba.width * gba.height]u32 = @splat(0);
var s_hud_buf: [core.touch.max_hud_width * gba.height]u32 = @splat(0);
var s_hud_rendered: bool = false;
var s_last_hud_visible: bool = false;
var s_last_hud_width: u16 = gba.width;
var s_last_hud_held: u16 = 0;
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

inline fn peek8(addr: u32) u8 {
    return switch (addr >> 24) {
        0x02 => if (rt.ewram) |ptr| ptr[addr & 0x3FFFF] else 0,
        0x03 => if (rt.iwram) |ptr| ptr[addr & 0x7FFF] else 0,
        else => 0,
    };
}

inline fn peek16(addr: u32) u16 {
    const aligned = addr & ~@as(u32, 1);
    return @as(u16, peek8(aligned)) | (@as(u16, peek8(aligned + 1)) << 8);
}

inline fn peek32(addr: u32) u32 {
    const aligned = addr & ~@as(u32, 3);
    return @as(u32, peek8(aligned)) |
        (@as(u32, peek8(aligned + 1)) << 8) |
        (@as(u32, peek8(aligned + 2)) << 16) |
        (@as(u32, peek8(aligned + 3)) << 24);
}

fn readRamSignedBytes(addr: u32, dst: []i8) void {
    var i: usize = 0;
    if ((addr & 3) == 0) {
        while (i + 4 <= dst.len) : (i += 4) {
            const w = peek32(addr + @as(u32, @intCast(i)));
            dst[i + 0] = @bitCast(@as(u8, @truncate(w)));
            dst[i + 1] = @bitCast(@as(u8, @truncate(w >> 8)));
            dst[i + 2] = @bitCast(@as(u8, @truncate(w >> 16)));
            dst[i + 3] = @bitCast(@as(u8, @truncate(w >> 24)));
        }
    }
    while (i < dst.len) : (i += 1) {
        dst[i] = @bitCast(peek8(addr + @as(u32, @intCast(i))));
    }
}

fn findActiveProcSlot(script_addr: u32) ?u32 {
    const proc_table_base: u32 = 0x0300_0E10;
    const proc_stride: u32 = 0x60;
    const proc_count: usize = 40;
    for (0..proc_count) |slot| {
        const base = proc_table_base + @as(u32, @intCast(slot)) * proc_stride;
        if (peek32(base) == script_addr) {
            return base;
        }
    }
    return null;
}

fn hasActiveProc(script_addr: u32) bool {
    return findActiveProcSlot(script_addr) != null;
}

fn sampleGameState() GameState {
    const io = rt.io_regs orelse return .{};
    const dispcnt = readIo16(io, gba.io_reg.dispcnt);
    const disp_mode = dispcnt & 7;
    const bg3_hofs = readIo16(io, gba.io_reg.bg3hofs) & 0x1FF;
    const bg3_vofs = readIo16(io, gba.io_reg.bg3vofs) & 0x1FF;

    const battle_lock: i16 = @bitCast(peek16(0x0300_43C8));
    const battle_lock2: i16 = @bitCast(peek16(0x0300_4470));
    const turn_phase = peek16(0x0300_357C);
    const substate = peek16(0x0300_35EC);
    const main_scene_fn = peek32(0x0300_4478);
    const in_battle_scene = (main_scene_fn == 0x0803_849D);
    const dialog_active = hasActiveProc(0x0828_0E0C);
    const frontend_root = hasActiveProc(0x082F_1160);
    const cursor_x_raw = peek16(0x0300_36A4);
    const cursor_y_raw = peek16(0x0300_36A6);
    var cursor_x: u16 = cursor_x_raw;
    var cursor_y: u16 = cursor_y_raw;

    const raw_w = peek16(0x0201_57F8);
    const raw_h = peek16(0x0201_57FA);
    const valid_map = raw_w >= 1 and raw_w <= core.touch.max_map_dim and
        raw_h >= 1 and raw_h <= core.touch.max_map_dim;
    const cam_x: i16 = if (valid_map)
        @bitCast(peek16(0x0201_57FC))
    else if (bg3_hofs > 480)
        @as(i16, @intCast(bg3_hofs)) - 512
    else
        @intCast(bg3_hofs);
    const cam_y: i16 = if (valid_map)
        @bitCast(peek16(0x0201_57FE))
    else if (bg3_vofs > 480)
        @as(i16, @intCast(bg3_vofs)) - 512
    else
        @intCast(bg3_vofs);

    var menu_x: i16 = 0;
    var menu_y: i16 = 0;
    var menu_count: u8 = 0;
    var menu_selected: u8 = 0;

    const mode: UiMode = if (disp_mode == 4)
        .title
    else if (findActiveProcSlot(0x0828_1CE8)) |yn_slot| blk: {
        const tile_ptr = peek32(yn_slot + 0x18);
        const cell = (tile_ptr & 0x7FF) >> 1;
        const tile_x = cell % 32;
        const tile_y = cell / 32;
        menu_x = @intCast(tile_x * 8);
        menu_y = @intCast(tile_y * 8);
        const sel_raw: i16 = @bitCast(peek16(yn_slot + 0x1E));
        menu_selected = if (sel_raw != 0) 1 else 0;
        menu_count = 2;
        break :blk .yes_no_prompt;
    } else if (in_battle_scene and disp_mode == 0 and battle_lock == 0 and battle_lock2 == 0 and turn_phase == 5) blk: {
        if (dialog_active) break :blk .dialog;
        break :blk switch (substate) {
            0 => .battle_free_map,
            1 => .battle_unit_selected,
            else => .battle_overlay,
        };
    } else if (dialog_active and !frontend_root)
        .dialog
    else if (!in_battle_scene or battle_lock < 0) blk: {
        if (disp_mode == 0) {
            if (hasActiveProc(0x082F_1130) and !dialog_active) {
                cursor_x = peek16(0x0200_802E);
                cursor_y = peek16(0x0200_8030);
                break :blk .name_entry;
            }
            if (hasActiveProc(0x082F_1BE0) and !hasActiveProc(0x0828_0D0C)) {
                menu_count = peek8(0x0200_002D);
                menu_selected = peek8(0x0200_002F);
                break :blk .frontend_main_menu;
            }
            if (hasActiveProc(0x082E_BF68)) {
                menu_count = 6;
                menu_selected = peek8(0x0201_FD23);
                menu_x = 4;
                menu_y = 64;
                break :blk .frontend_map_select;
            }
            if (hasActiveProc(0x083B_93C8) or hasActiveProc(0x083B_9244)) {
                break :blk .frontend_co_setup;
            }
        }
        break :blk .frontend_menu;
    } else blk: {
        if (disp_mode == 0) {
            if (findActiveProcSlot(0x0828_1D60)) |main_slot| {
                if (findActiveProcSlot(0x0828_1D80)) |cur_slot| {
                    const item_count = peek8(main_slot + 0x3F);
                    if (item_count >= 1 and item_count <= 12) {
                        menu_count = item_count;
                        menu_selected = peek8(main_slot + 0x40);
                        menu_x = @bitCast(peek16(cur_slot + 0x24));
                        menu_y = @bitCast(peek16(cur_slot + 0x26));
                        break :blk .battle_popup_menu;
                    }
                }
            }
            if (findActiveProcSlot(0x082E_CF68)) |ul_slot| {
                const cursor_abs = peek8(ul_slot + 0x1F);
                const scroll_top = peek8(ul_slot + 0x20);
                const unit_count = peek8(ul_slot + 0x21);
                const vis = unit_count -| scroll_top;
                menu_count = if (vis > 0) @min(vis, @as(u8, 6)) else 6;
                menu_selected = cursor_abs -| scroll_top;
                menu_x = 8;
                menu_y = 56;
                break :blk .battle_unit_list;
            }
            if (hasActiveProc(0x0828_B56C)) {
                break :blk .battle_attack_target;
            }
        }
        break :blk .battle_overlay;
    };

    var state = GameState{
        .mode = mode,
        .map_width = if (valid_map) raw_w else 0,
        .map_height = if (valid_map) raw_h else 0,
        .cursor_x = cursor_x,
        .cursor_y = cursor_y,
        .cam_x = cam_x,
        .cam_y = cam_y,
        .menu_x = menu_x,
        .menu_y = menu_y,
        .menu_count = menu_count,
        .menu_selected = menu_selected,
    };

    if (mode == .battle_unit_selected and state.map_width > 0 and state.map_height > 0) {
        for (0..@as(usize, state.map_height)) |y| {
            const row_ptr = peek32(0x0300_3600 + @as(u32, @intCast(y)) * 4);
            if (row_ptr >= 0x0200_0000 and row_ptr + @as(u32, state.map_width) <= 0x0204_0000) {
                for (0..@as(usize, state.map_width)) |x| {
                    const cost: i8 = @bitCast(peek8(row_ptr + @as(u32, @intCast(x))));
                    if (cost >= 0) {
                        state.setReachable(@intCast(x), @intCast(y));
                    }
                }
            }
        }
    }

    return state;
}

fn pumpLiveAudio() void {
    const io = rt.io_regs orelse return;
    const sound_info_ptr = peek32(audio.sound_info_ptr_addr);
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
        .sound_info_ident = peek32(sound_info_ptr),
        .pcm_dma_counter = peek8(sound_info_ptr + 4),
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

pub fn parseArgsSlice(args: []const [*:0]const u8) ?[*:0]const u8 {
    return s_runner.parseArgs(args, core.is_headless);
}

pub fn savePath() ?[*:0]const u8 {
    return s_runner.save_path;
}

pub fn display_parse_args(argc: c_int, argv: [*][*:0]u8) ?[*:0]const u8 {
    if (argc <= 0) return null;
    const count: usize = @intCast(argc);
    const args: [*]const [*:0]const u8 = @ptrCast(argv);
    return parseArgsSlice(args[0..count]);
}

pub fn display_pace() void {
    if (!s_runner.headless) {
        s_backend.pace();
    }
}

fn dumpContinuousFrame(framebuf: *const [gba.width * gba.height]u32, state: GameState) void {
    if (s_runner.dump_dir == null) return;
    s_runner.dumpFrameBmp(framebuf);

    const io = rt.io_regs orelse return;
    const dispcnt = readIo16(io, gba.io_reg.dispcnt);
    const bldcnt = readIo16(io, gba.io_reg.bldcnt);
    const bldalpha = readIo16(io, gba.io_reg.bldalpha);
    const bldy = readIo16(io, gba.io_reg.bldy);
    const winin = readIo16(io, gba.io_reg.winin);
    const winout = readIo16(io, gba.io_reg.winout);
    const keyin = readIo16(io, 0x130);
    const f_u64: u64 = @intCast(@max(s_runner.frame_no, 0));

    var line_buf: [512]u8 = undefined;
    const line = std.fmt.bufPrint(
        &line_buf,
        "f={d:0>6} DISPCNT=0x{X:0>4} BLDCNT=0x{X:0>4} BLDALPHA=0x{X:0>4} BLDY=0x{X:0>4} " ++
            "WIN=0x{X:0>4}/0x{X:0>4} keyin=0x{X:0>4} live=0x{X:0>4} touch=0x{X:0>4} " ++
            "map={d} dlg={d} cur=({d},{d}) scroll=({d},{d}) sp=0x{X:0>8} lr=0x{X:0>8} " ++
            "pc=0x{X:0>8} r0=0x{X:0>8} r1=0x{X:0>8} nzcv={d}{d}{d}{d}\n",
        .{
            f_u64,
            dispcnt,
            bldcnt,
            bldalpha,
            bldy,
            winin,
            winout,
            keyin,
            s_live_keys_pressed,
            s_touch.activeKeys(),
            @intFromBool(state.isMapInteractive()),
            @intFromBool(state.mode == .dialog),
            state.cursor_x,
            state.cursor_y,
            state.cam_x,
            state.cam_y,
            rt.r[13],
            rt.r[14],
            rt.r[15],
            rt.r[0],
            rt.r[1],
            @intFromBool(rt.CPU_N),
            @intFromBool(rt.CPU_Z),
            @intFromBool(rt.CPU_C),
            @intFromBool(rt.CPU_V),
        },
    ) catch return;
    s_runner.writeDumpLogLine(line);
}

pub fn display_headless() c_int {
    return if (s_runner.headless) 1 else 0;
}

pub fn display_log_every() c_long {
    return @intCast(s_runner.log_every);
}

pub fn display_dump_path(frame: c_long) ?[*:0]const u8 {
    return s_runner.dumpPath(@intCast(frame));
}

pub fn display_init() c_int {
    const win_w: u32 = @as(u32, @intCast(gba.width)) * default_scale;
    const win_h: u32 = @as(u32, @intCast(gba.height)) * default_scale;
    if (!s_runner.initRecording(win_w, win_h)) {
        return -1;
    }
    if (!s_runner.initDumpDir()) {
        return -1;
    }
    if (s_runner.headless) return 0;

    if (core.is_headless) {
        gba.logPrint("[display] built without SDL2: run with --headless\n", .{});
        return -1;
    }

    if (!s_backend.init(win_w, win_h)) {
        return -1;
    }
    return 0;
}

pub fn display_render_line(y: c_int) void {
    const io = rt.io_regs orelse return;
    const vr = rt.vram orelse return;
    const pal = rt.palette orelse return;
    const om = rt.oam orelse return;
    if (y < 0 or y >= @as(c_int, @intCast(gba.height))) return;
    if (!s_runner.shouldRenderScanline()) return;

    s_ppu.renderLine(.{
        .io_regs = io,
        .palette = pal,
        .vram = vr,
        .oam = om,
    }, @intCast(y));
}

pub fn display_render_frame() void {
    if (rt.io_regs == null or rt.vram == null or rt.palette == null or rt.oam == null) return;
    if (s_runner.onFrame(&s_ppu.framebuf)) {
        dumpContinuousFrame(&s_ppu.framebuf, sampleGameState());
        return;
    }

    pumpLiveAudio();
    const state = sampleGameState();
    s_touch.stepFrame(state);
    s_touch.renderGameWithReticle(&s_ppu.framebuf, &s_present_buf);
    dumpContinuousFrame(&s_present_buf, state);

    const hud_w = s_touch.hud_width;
    const hud_len: usize = @as(usize, hud_w) * gba.height;
    const hud_dirty = !s_hud_rendered or
        s_touch.hud_visible != s_last_hud_visible or
        hud_w != s_last_hud_width or
        s_touch.hud_held_mask != s_last_hud_held;
    if (hud_dirty) {
        s_touch.renderHudLayer(&s_hud_buf, hud_w, is_freestanding);
        s_hud_rendered = true;
        s_last_hud_visible = s_touch.hud_visible;
        s_last_hud_width = hud_w;
        s_last_hud_held = s_touch.hud_held_mask;
    }
    const hud_frame = HudFrame{
        .visible = s_touch.hud_visible,
        .width = hud_w,
        .dirty = hud_dirty,
        .pixels = s_hud_buf[0..hud_len],
    };
    s_backend.present(&s_present_buf, hud_frame);
}

pub fn display_poll_events() c_int {
    if (s_runner.reachedFrameLimit()) return 1;
    if (s_runner.headless) return 0;

    const res = s_backend.poll();
    s_live_keys_pressed = res.keys_pressed;
    if (res.hud_width >= gba.width) {
        s_touch.setHudWidth(res.hud_width);
    }
    if (res.hud_overlay) |want_hud| {
        s_touch.setHudVisible(want_hud);
    } else if (res.toggle_hud) {
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

pub fn display_get_keys() u16 {
    const touch_keys: u16 = if (s_runner.headless) 0 else s_touch.activeKeys();
    const combined = s_runner.script_keys_pressed | s_live_keys_pressed | touch_keys;
    return gba.keyInputFromPressed(combined);
}

pub fn display_shutdown() void {
    s_runner.shutdown(&s_ppu.framebuf);
    if (!s_runner.headless) {
        s_backend.shutdown();
    }
}
