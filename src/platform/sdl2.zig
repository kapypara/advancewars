const std = @import("std");
const sdl = @import("sdl2");
const gba = @import("../gba/defs.zig");
const audio = @import("../gba/audio.zig");
const platform = @import("backend.zig");
const touch_mod = @import("touch.zig");

const max_pointer_queue: usize = 64;

fn mapSdlKey(sym: sdl.SDL_Keycode) u16 {
    return switch (sym) {
        sdl.SDLK_z => gba.Key.a.mask(),
        sdl.SDLK_x => gba.Key.b.mask(),
        sdl.SDLK_BACKSPACE => gba.Key.select.mask(),
        sdl.SDLK_RETURN => gba.Key.start.mask(),
        sdl.SDLK_RIGHT => gba.Key.right.mask(),
        sdl.SDLK_LEFT => gba.Key.left.mask(),
        sdl.SDLK_UP => gba.Key.up.mask(),
        sdl.SDLK_DOWN => gba.Key.down.mask(),
        sdl.SDLK_s => gba.Key.r.mask(),
        sdl.SDLK_a => gba.Key.l.mask(),
        else => 0,
    };
}

fn computeGameRect(area_w: i32, area_h: i32, view_w: u16, view_h: u16) sdl.SDL_Rect {
    const safe_w = @max(area_w, 1);
    const safe_h = @max(area_h, 1);
    const gba_w: i32 = @max(@as(i32, view_w), @as(i32, @intCast(gba.width)));
    const gba_h: i32 = @max(@as(i32, view_h), @as(i32, @intCast(gba.height)));

    var rw: i32 = undefined;
    var rh: i32 = undefined;
    if (@as(i64, safe_w) * gba_h <= @as(i64, safe_h) * gba_w) {
        rw = safe_w;
        rh = @max(@divTrunc(safe_w * gba_h, gba_w), 1);
    } else {
        rh = safe_h;
        rw = @max(@divTrunc(safe_h * gba_w, gba_h), 1);
    }
    return .{
        .x = @divTrunc(safe_w - rw, 2),
        .y = @divTrunc(safe_h - rh, 2),
        .w = rw,
        .h = rh,
    };
}

/// Native Linux / desktop SDL2 platform backend.
pub const Sdl2Backend = struct {
    window: ?*sdl.SDL_Window = null,
    renderer: ?*sdl.SDL_Renderer = null,
    texture: ?*sdl.SDL_Texture = null,
    tex_w: u16 = gba.width,
    tex_h: u16 = gba.height,
    view_w: u16 = gba.width,
    view_h: u16 = gba.height,
    hud_texture: ?*sdl.SDL_Texture = null,
    hud_tex_w: u16 = 0,
    audio_dev: sdl.SDL_AudioDeviceID = 0,
    audio_started: bool = false,
    keys_pressed: u16 = 0,
    next_frame_ticks: u64 = 0,
    pointer_buf: [max_pointer_queue]platform.PointerEvent = undefined,
    pointer_count: usize = 0,

    pub fn init(self: *Sdl2Backend, win_width: u32, win_height: u32) bool {
        if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO | sdl.SDL_INIT_AUDIO) != 0) {
            if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
                sdl.SDL_Log("SDL_Init failed: %s", sdl.SDL_GetError());
                return false;
            }
            sdl.SDL_Log("SDL audio unavailable; continuing muted: %s", sdl.SDL_GetError());
        }

        // Crisp nearest-neighbor scaling must be hinted before renderer/texture creation.
        _ = sdl.SDL_SetHint(sdl.SDL_HINT_RENDER_SCALE_QUALITY, "0");

        const window = sdl.SDL_CreateWindow(
            "Advance Wars",
            @intCast(sdl.SDL_WINDOWPOS_CENTERED),
            @intCast(sdl.SDL_WINDOWPOS_CENTERED),
            @intCast(win_width),
            @intCast(win_height),
            sdl.SDL_WINDOW_SHOWN | sdl.SDL_WINDOW_RESIZABLE,
        ) orelse {
            sdl.SDL_Log("SDL_CreateWindow failed: %s", sdl.SDL_GetError());
            sdl.SDL_Quit();
            return false;
        };

        const renderer = sdl.SDL_CreateRenderer(
            window,
            -1,
            sdl.SDL_RENDERER_ACCELERATED,
        ) orelse sdl.SDL_CreateRenderer(window, -1, 0) orelse {
            sdl.SDL_Log("SDL_CreateRenderer failed: %s", sdl.SDL_GetError());
            sdl.SDL_DestroyWindow(window);
            sdl.SDL_Quit();
            return false;
        };

        const texture = sdl.SDL_CreateTexture(
            renderer,
            @intCast(sdl.SDL_PIXELFORMAT_ARGB8888),
            sdl.SDL_TEXTUREACCESS_STREAMING,
            @intCast(gba.width),
            @intCast(gba.height),
        ) orelse {
            sdl.SDL_Log("SDL_CreateTexture failed: %s", sdl.SDL_GetError());
            sdl.SDL_DestroyRenderer(renderer);
            sdl.SDL_DestroyWindow(window);
            sdl.SDL_Quit();
            return false;
        };

        self.window = window;
        self.renderer = renderer;
        self.texture = texture;
        self.tex_w = gba.width;
        self.tex_h = gba.height;
        self.view_w = gba.width;
        self.view_h = gba.height;
        self.audio_started = false;

        const perf_freq = sdl.SDL_GetPerformanceFrequency();
        const frame_ticks: u64 = if (perf_freq > 0)
            @intCast((@as(u128, perf_freq) * audio.cycles_per_frame) / audio.gba_cpu_hz)
        else
            0;
        self.next_frame_ticks = sdl.SDL_GetPerformanceCounter() +% frame_ticks;

        if ((sdl.SDL_WasInit(sdl.SDL_INIT_AUDIO) & sdl.SDL_INIT_AUDIO) != 0) {
            var desired = std.mem.zeroes(sdl.SDL_AudioSpec);
            desired.freq = @intCast(audio.output_sample_rate);
            desired.format = @intCast(sdl.AUDIO_S16SYS);
            desired.channels = 2;
            desired.samples = 1024;
            const dev = sdl.SDL_OpenAudioDevice(null, 0, &desired, null, 0);
            if (dev != 0) {
                self.audio_dev = dev;
                // Keep paused until ~45 ms of pre-buffered audio is queued.
                sdl.SDL_PauseAudioDevice(dev, 1);
            } else {
                sdl.SDL_Log("SDL_OpenAudioDevice failed: %s", sdl.SDL_GetError());
            }
        }
        return true;
    }

    pub fn queuedAudioBytes(self: *const Sdl2Backend) u32 {
        if (self.audio_dev == 0) return 0;
        return sdl.SDL_GetQueuedAudioSize(self.audio_dev);
    }

    pub fn pushAudio(self: *Sdl2Backend, samples: []const i16) void {
        if (self.audio_dev == 0 or samples.len == 0) return;
        const prebuffer_bytes: u32 = audio.output_sample_rate * 4 * 45 / 1000; // ~45 ms (8,640 B)
        const max_queued_bytes: u32 = audio.output_sample_rate * 4 * 220 / 1000; // ~220 ms ceiling (42,240 B)

        if (sdl.SDL_GetQueuedAudioSize(self.audio_dev) > max_queued_bytes) {
            sdl.SDL_ClearQueuedAudio(self.audio_dev);
            self.audio_started = false;
            sdl.SDL_PauseAudioDevice(self.audio_dev, 1);
        }
        _ = sdl.SDL_QueueAudio(
            self.audio_dev,
            @ptrCast(samples.ptr),
            @intCast(samples.len * @sizeOf(i16)),
        );
        if (!self.audio_started and sdl.SDL_GetQueuedAudioSize(self.audio_dev) >= prebuffer_bytes) {
            self.audio_started = true;
            sdl.SDL_PauseAudioDevice(self.audio_dev, 0);
        }
    }

    pub fn present(self: *Sdl2Backend, frame: platform.VideoFrame, hud: platform.HudFrame) void {
        const renderer = self.renderer orelse return;
        const frame_w: u16 = @max(frame.width, @as(u16, @intCast(gba.width)));
        const frame_h: u16 = @max(frame.height, @as(u16, @intCast(gba.height)));
        if (frame.pixels.len < @as(usize, frame_w) * @as(usize, frame_h)) return;

        if (self.texture == null or self.tex_w != frame_w or self.tex_h != frame_h) {
            if (self.texture) |old| sdl.SDL_DestroyTexture(old);
            self.texture = null;
            self.tex_w = 0;
            self.tex_h = 0;

            _ = sdl.SDL_SetHint(sdl.SDL_HINT_RENDER_SCALE_QUALITY, "0");
            self.texture = sdl.SDL_CreateTexture(
                renderer,
                @intCast(sdl.SDL_PIXELFORMAT_ARGB8888),
                sdl.SDL_TEXTUREACCESS_STREAMING,
                @intCast(frame_w),
                @intCast(frame_h),
            ) orelse return;
            self.tex_w = frame_w;
            self.tex_h = frame_h;
        }
        const texture = self.texture orelse return;
        self.view_w = frame_w;
        self.view_h = frame_h;

        var out_w: c_int = @intCast(gba.width);
        var out_h: c_int = @intCast(gba.height);
        _ = sdl.SDL_GetRendererOutputSize(renderer, &out_w, &out_h);
        var dst_rect = computeGameRect(@intCast(out_w), @intCast(out_h), frame_w, frame_h);

        _ = sdl.SDL_UpdateTexture(
            texture,
            null,
            @ptrCast(frame.pixels.ptr),
            @intCast(@as(usize, frame_w) * @sizeOf(u32)),
        );
        _ = sdl.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = sdl.SDL_RenderClear(renderer);
        _ = sdl.SDL_RenderCopy(renderer, texture, null, &dst_rect);

        if (hud.visible and hud.width >= gba.width and hud.pixels.len >= @as(usize, hud.width) * gba.height) {
            var recreated = false;
            if (self.hud_texture == null or self.hud_tex_w != hud.width) {
                if (self.hud_texture) |old| sdl.SDL_DestroyTexture(old);
                self.hud_texture = null;
                self.hud_tex_w = 0;

                _ = sdl.SDL_SetHint(sdl.SDL_HINT_RENDER_SCALE_QUALITY, "0");
                if (sdl.SDL_CreateTexture(
                    renderer,
                    @intCast(sdl.SDL_PIXELFORMAT_ARGB8888),
                    sdl.SDL_TEXTUREACCESS_STREAMING,
                    @intCast(hud.width),
                    @intCast(gba.height),
                )) |tex| {
                    _ = sdl.SDL_SetTextureBlendMode(tex, sdl.SDL_BLENDMODE_BLEND);
                    self.hud_texture = tex;
                    self.hud_tex_w = hud.width;
                    recreated = true;
                }
            }

            if (self.hud_texture) |tex| {
                if (hud.dirty or recreated) {
                    _ = sdl.SDL_UpdateTexture(
                        tex,
                        null,
                        @ptrCast(hud.pixels.ptr),
                        @intCast(@as(usize, hud.width) * @sizeOf(u32)),
                    );
                }
                const hud_dst_h: i32 = @max(@divTrunc(dst_rect.h * @as(i32, @intCast(gba.height)), @as(i32, frame_h)), 1);
                const hud_dst_w: i32 = @max(@divTrunc(@as(i32, hud.width) * hud_dst_h, @as(i32, @intCast(gba.height))), dst_rect.w);
                var hud_dst = sdl.SDL_Rect{
                    .x = @divTrunc(@as(i32, out_w) - hud_dst_w, 2),
                    .y = dst_rect.y + @divTrunc(dst_rect.h - hud_dst_h, 2),
                    .w = hud_dst_w,
                    .h = hud_dst_h,
                };
                _ = sdl.SDL_RenderCopy(renderer, tex, null, &hud_dst);
            }
        }

        sdl.SDL_RenderPresent(renderer);
    }

    pub fn pace(self: *Sdl2Backend) void {
        const perf_freq = sdl.SDL_GetPerformanceFrequency();
        if (perf_freq == 0) {
            sdl.SDL_Delay(16);
            return;
        }
        const frame_ticks: u64 = @intCast((@as(u128, perf_freq) * audio.cycles_per_frame) / audio.gba_cpu_hz);
        if (self.next_frame_ticks == 0) {
            self.next_frame_ticks = sdl.SDL_GetPerformanceCounter() +% frame_ticks;
        }

        var now = sdl.SDL_GetPerformanceCounter();
        if (now < self.next_frame_ticks) {
            const rem_ticks = self.next_frame_ticks - now;
            const rem_ms = (rem_ticks * 1000) / perf_freq;
            if (rem_ms > 1) {
                sdl.SDL_Delay(@intCast(rem_ms - 1));
            }
            while (sdl.SDL_GetPerformanceCounter() < self.next_frame_ticks) {}
            now = sdl.SDL_GetPerformanceCounter();
        }

        // Prevent frame bursts after pauses or window drags (> 2 frames behind).
        if (now > self.next_frame_ticks +% frame_ticks * 2) {
            self.next_frame_ticks = now +% frame_ticks;
        } else {
            self.next_frame_ticks +%= frame_ticks;
        }
    }

    fn pushPointer(self: *Sdl2Backend, ev: platform.PointerEvent) void {
        if (self.pointer_count < self.pointer_buf.len) {
            self.pointer_buf[self.pointer_count] = ev;
            self.pointer_count += 1;
        }
    }

    fn windowToLogical(self: *Sdl2Backend, win_x: f32, win_y: f32) struct { x: f32, y: f32 } {
        const window = self.window orelse return .{ .x = win_x, .y = win_y };
        var win_w: c_int = @intCast(gba.width);
        var win_h: c_int = @intCast(gba.height);
        sdl.SDL_GetWindowSize(window, &win_w, &win_h);
        const view_w = @max(self.view_w, @as(u16, @intCast(gba.width)));
        const view_h = @max(self.view_h, @as(u16, @intCast(gba.height)));
        const rect = computeGameRect(@intCast(win_w), @intCast(win_h), view_w, view_h);
        const rx: f32 = @floatFromInt(rect.x);
        const ry: f32 = @floatFromInt(rect.y);
        const rw: f32 = @floatFromInt(rect.w);
        const rh: f32 = @floatFromInt(rect.h);
        const pad_l: f32 = @floatFromInt(@divTrunc(@as(i32, view_w) - @as(i32, @intCast(gba.width)), 2));
        const pad_t: f32 = @floatFromInt(@divTrunc(@as(i32, view_h) - @as(i32, @intCast(gba.height)), 2));
        return .{
            .x = (win_x - rx) * (@as(f32, @floatFromInt(view_w)) / rw) - pad_l,
            .y = (win_y - ry) * (@as(f32, @floatFromInt(view_h)) / rh) - pad_t,
        };
    }

    fn toggleFullscreen(self: *Sdl2Backend) void {
        const window = self.window orelse return;
        const flags = sdl.SDL_GetWindowFlags(window);
        const is_fs = (flags & sdl.SDL_WINDOW_FULLSCREEN_DESKTOP) != 0;
        _ = sdl.SDL_SetWindowFullscreen(window, if (is_fs) 0 else sdl.SDL_WINDOW_FULLSCREEN_DESKTOP);
    }

    fn currentWideDims(self: *const Sdl2Backend) struct { wide_w: u16, wide_h: u16, hud_w: u16 } {
        const window = self.window orelse return .{
            .wide_w = @intCast(gba.width),
            .wide_h = @intCast(gba.height),
            .hud_w = @intCast(gba.width),
        };
        var win_w: c_int = @intCast(gba.width);
        var win_h: c_int = @intCast(gba.height);
        sdl.SDL_GetWindowSize(window, &win_w, &win_h);
        if (win_w <= 0 or win_h <= 0) {
            return .{
                .wide_w = @intCast(gba.width),
                .wide_h = @intCast(gba.height),
                .hud_w = @intCast(gba.width),
            };
        }
        const gba_w_i: i64 = @intCast(gba.width);
        const gba_h_i: i64 = @intCast(gba.height);
        if (@as(i64, win_w) * gba_h_i >= @as(i64, win_h) * gba_w_i) {
            const wide_w = touch_mod.computeHudWidth(@intCast(win_w), @intCast(win_h));
            return .{
                .wide_w = wide_w,
                .wide_h = @intCast(gba.height),
                .hud_w = wide_w,
            };
        }
        const raw_h = @divTrunc(@as(i64, win_h) * gba_w_i, @as(i64, win_w));
        const clamped_h: u16 = @intCast(std.math.clamp(
            raw_h,
            gba_h_i,
            @as(i64, @intCast(gba.max_wide_height)),
        ));
        return .{
            .wide_w = @intCast(gba.width),
            .wide_h = clamped_h - @mod(clamped_h, 2),
            .hud_w = @intCast(gba.width),
        };
    }

    pub fn poll(self: *Sdl2Backend) platform.PollResult {
        var toggle_hud = false;
        var toggle_mute = false;
        var toggle_widescreen = false;
        var ev: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&ev) != 0) {
            switch (ev.type) {
                sdl.SDL_QUIT => {
                    const dims = self.currentWideDims();
                    return .{
                        .quit = true,
                        .keys_pressed = self.keys_pressed,
                        .toggle_hud = toggle_hud,
                        .toggle_mute = toggle_mute,
                        .toggle_widescreen = toggle_widescreen,
                        .hud_width = dims.hud_w,
                        .wide_width = dims.wide_w,
                        .wide_height = dims.wide_h,
                    };
                },
                sdl.SDL_KEYDOWN, sdl.SDL_KEYUP => {
                    if (ev.type == sdl.SDL_KEYDOWN and ev.key.repeat == 0) {
                        if (ev.key.keysym.sym == sdl.SDLK_F11) {
                            self.toggleFullscreen();
                        } else if (ev.key.keysym.sym == sdl.SDLK_F2) {
                            toggle_hud = true;
                        } else if (ev.key.keysym.sym == sdl.SDLK_F3 or ev.key.keysym.sym == sdl.SDLK_m) {
                            toggle_mute = true;
                        } else if (ev.key.keysym.sym == sdl.SDLK_F4) {
                            toggle_widescreen = true;
                        }
                    }
                    const bit = mapSdlKey(ev.key.keysym.sym);
                    if (bit != 0) {
                        if (ev.type == sdl.SDL_KEYDOWN) {
                            self.keys_pressed |= bit;
                        } else {
                            self.keys_pressed &= ~bit;
                        }
                    }
                },
                sdl.SDL_MOUSEBUTTONDOWN, sdl.SDL_MOUSEBUTTONUP => {
                    const fx: f32 = @floatFromInt(ev.button.x);
                    const fy: f32 = @floatFromInt(ev.button.y);
                    if (ev.button.button == sdl.SDL_BUTTON_LEFT) {
                        const log = self.windowToLogical(fx, fy);
                        self.pushPointer(.{
                            .id = -1,
                            .phase = if (ev.type == sdl.SDL_MOUSEBUTTONDOWN) .down else .up,
                            .x = fx,
                            .y = fy,
                            .logical_x = log.x,
                            .logical_y = log.y,
                        });
                    } else if (ev.button.button == sdl.SDL_BUTTON_RIGHT) {
                        const log = self.windowToLogical(fx, fy);
                        self.pushPointer(.{
                            .id = -2,
                            .phase = if (ev.type == sdl.SDL_MOUSEBUTTONDOWN) .right_down else .right_up,
                            .x = fx,
                            .y = fy,
                            .logical_x = log.x,
                            .logical_y = log.y,
                        });
                    }
                },
                sdl.SDL_MOUSEWHEEL => {
                    var dy: i32 = ev.wheel.y;
                    if (ev.wheel.direction == sdl.SDL_MOUSEWHEEL_FLIPPED) {
                        dy = -dy;
                    }
                    if (dy != 0) {
                        const steps: usize = @min(@as(usize, @abs(dy)), 4);
                        const phase: platform.PointerPhase = if (dy > 0) .scroll_up else .scroll_down;
                        for (0..steps) |_| {
                            self.pushPointer(.{
                                .id = -3,
                                .phase = phase,
                                .x = 0,
                                .y = 0,
                                .logical_x = 0,
                                .logical_y = 0,
                            });
                        }
                    }
                },
                sdl.SDL_MOUSEMOTION => {
                    if ((ev.motion.state & sdl.SDL_BUTTON_LMASK) != 0) {
                        const fx: f32 = @floatFromInt(ev.motion.x);
                        const fy: f32 = @floatFromInt(ev.motion.y);
                        const log = self.windowToLogical(fx, fy);
                        self.pushPointer(.{
                            .id = -1,
                            .phase = .move,
                            .x = fx,
                            .y = fy,
                            .logical_x = log.x,
                            .logical_y = log.y,
                        });
                    }
                },
                sdl.SDL_FINGERDOWN, sdl.SDL_FINGERUP, sdl.SDL_FINGERMOTION => {
                    var ww: c_int = @intCast(gba.width);
                    var wh: c_int = @intCast(gba.height);
                    if (self.window) |w| sdl.SDL_GetWindowSize(w, &ww, &wh);
                    const wx = ev.tfinger.x * @as(f32, @floatFromInt(ww));
                    const wy = ev.tfinger.y * @as(f32, @floatFromInt(wh));
                    const log = self.windowToLogical(wx, wy);
                    const phase: platform.PointerPhase = switch (ev.type) {
                        sdl.SDL_FINGERDOWN => .down,
                        sdl.SDL_FINGERUP => .up,
                        else => .move,
                    };
                    self.pushPointer(.{
                        .id = ev.tfinger.fingerId,
                        .phase = phase,
                        .x = wx,
                        .y = wy,
                        .logical_x = log.x,
                        .logical_y = log.y,
                    });
                },
                else => {},
            }
        }
        const dims = self.currentWideDims();
        return .{
            .quit = false,
            .keys_pressed = self.keys_pressed,
            .toggle_hud = toggle_hud,
            .toggle_mute = toggle_mute,
            .toggle_widescreen = toggle_widescreen,
            .hud_width = dims.hud_w,
            .wide_width = dims.wide_w,
            .wide_height = dims.wide_h,
        };
    }

    pub fn drainPointers(self: *Sdl2Backend, out: []platform.PointerEvent) []const platform.PointerEvent {
        const n = @min(self.pointer_count, out.len);
        @memcpy(out[0..n], self.pointer_buf[0..n]);
        self.pointer_count = 0;
        return out[0..n];
    }

    pub fn shutdown(self: *Sdl2Backend) void {
        if (self.audio_dev != 0) {
            sdl.SDL_CloseAudioDevice(self.audio_dev);
            self.audio_dev = 0;
        }
        if (self.hud_texture) |t| {
            sdl.SDL_DestroyTexture(t);
            self.hud_texture = null;
            self.hud_tex_w = 0;
        }
        if (self.texture) |t| {
            sdl.SDL_DestroyTexture(t);
            self.texture = null;
        }
        if (self.renderer) |r| {
            sdl.SDL_DestroyRenderer(r);
            self.renderer = null;
        }
        if (self.window) |w| {
            sdl.SDL_DestroyWindow(w);
            self.window = null;
        }
        sdl.SDL_Quit();
    }
};
