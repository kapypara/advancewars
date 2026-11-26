const std = @import("std");
const sdl = @import("sdl2");
const gba = @import("gba.zig");
const platform = @import("platform.zig");

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

/// Native Linux / desktop SDL2 platform backend.
pub const Sdl2Backend = struct {
    window: ?*sdl.SDL_Window = null,
    renderer: ?*sdl.SDL_Renderer = null,
    texture: ?*sdl.SDL_Texture = null,
    keys_pressed: u16 = 0,
    last_frame_ms: u64 = 0,
    pointer_buf: [max_pointer_queue]platform.PointerEvent = undefined,
    pointer_count: usize = 0,

    pub fn init(self: *Sdl2Backend, win_width: u32, win_height: u32) bool {
        if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
            sdl.SDL_Log("SDL_Init failed: %s", sdl.SDL_GetError());
            return false;
        }

        // Crisp nearest-neighbor scaling must be hinted before renderer/texture creation.
        _ = sdl.SDL_SetHint(sdl.SDL_HINT_RENDER_SCALE_QUALITY, "0");

        const window = sdl.SDL_CreateWindow(
            "Advance Wars (Zig)",
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
            sdl.SDL_RENDERER_ACCELERATED | sdl.SDL_RENDERER_PRESENTVSYNC,
        ) orelse {
            sdl.SDL_Log("SDL_CreateRenderer failed: %s", sdl.SDL_GetError());
            sdl.SDL_DestroyWindow(window);
            sdl.SDL_Quit();
            return false;
        };

        _ = sdl.SDL_RenderSetLogicalSize(renderer, @intCast(gba.width), @intCast(gba.height));

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
        self.last_frame_ms = sdl.SDL_GetTicks64();
        return true;
    }

    pub fn present(self: *Sdl2Backend, framebuf: *const [gba.width * gba.height]u32) void {
        const renderer = self.renderer orelse return;
        const texture = self.texture orelse return;

        _ = sdl.SDL_UpdateTexture(
            texture,
            null,
            @ptrCast(framebuf),
            @intCast(gba.width * @sizeOf(u32)),
        );
        _ = sdl.SDL_RenderClear(renderer);
        _ = sdl.SDL_RenderCopy(renderer, texture, null, null);
        sdl.SDL_RenderPresent(renderer);
    }

    pub fn pace(self: *Sdl2Backend) void {
        const now = sdl.SDL_GetTicks64();
        const elapsed = now -% self.last_frame_ms;
        if (elapsed < 16) {
            sdl.SDL_Delay(@intCast(16 - elapsed));
        }
        self.last_frame_ms = sdl.SDL_GetTicks64();
    }

    fn pushPointer(self: *Sdl2Backend, ev: platform.PointerEvent) void {
        if (self.pointer_count < self.pointer_buf.len) {
            self.pointer_buf[self.pointer_count] = ev;
            self.pointer_count += 1;
        }
    }

    fn windowToLogical(self: *Sdl2Backend, win_x: f32, win_y: f32) struct { x: f32, y: f32 } {
        const renderer = self.renderer orelse return .{ .x = win_x, .y = win_y };
        var lx: f32 = 0;
        var ly: f32 = 0;
        sdl.SDL_RenderWindowToLogical(renderer, @intFromFloat(win_x), @intFromFloat(win_y), &lx, &ly);
        return .{ .x = lx, .y = ly };
    }

    fn toggleFullscreen(self: *Sdl2Backend) void {
        const window = self.window orelse return;
        const flags = sdl.SDL_GetWindowFlags(window);
        const is_fs = (flags & sdl.SDL_WINDOW_FULLSCREEN_DESKTOP) != 0;
        _ = sdl.SDL_SetWindowFullscreen(window, if (is_fs) 0 else sdl.SDL_WINDOW_FULLSCREEN_DESKTOP);
    }

    pub fn poll(self: *Sdl2Backend) platform.PollResult {
        var ev: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&ev) != 0) {
            switch (ev.type) {
                sdl.SDL_QUIT => return .{ .quit = true, .keys_pressed = self.keys_pressed },
                sdl.SDL_KEYDOWN, sdl.SDL_KEYUP => {
                    if (ev.type == sdl.SDL_KEYDOWN and ev.key.keysym.sym == sdl.SDLK_F11 and ev.key.repeat == 0) {
                        self.toggleFullscreen();
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
                    if (ev.button.button == sdl.SDL_BUTTON_LEFT) {
                        const fx: f32 = @floatFromInt(ev.button.x);
                        const fy: f32 = @floatFromInt(ev.button.y);
                        const log = self.windowToLogical(fx, fy);
                        self.pushPointer(.{
                            .id = -1,
                            .phase = if (ev.type == sdl.SDL_MOUSEBUTTONDOWN) .down else .up,
                            .x = fx,
                            .y = fy,
                            .logical_x = log.x,
                            .logical_y = log.y,
                        });
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
        return .{ .quit = false, .keys_pressed = self.keys_pressed };
    }

    pub fn drainPointers(self: *Sdl2Backend, out: []platform.PointerEvent) []const platform.PointerEvent {
        const n = @min(self.pointer_count, out.len);
        @memcpy(out[0..n], self.pointer_buf[0..n]);
        self.pointer_count = 0;
        return out[0..n];
    }

    pub fn shutdown(self: *Sdl2Backend) void {
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
