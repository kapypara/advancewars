const std = @import("std");
const builtin = @import("builtin");
const core = @import("awre_core");
const disp = @import("platform/display.zig");
const adapters = @import("runtime/adapters.zig");
const diagnostics = @import("runtime/diagnostics.zig");
const save_io = @import("runtime/save_io.zig");
const timing = @import("runtime/timing.zig");
const validate_mod = @import("validate/validate.zig");
const rt_options = @import("rt_options");

const embedded_rom_bytes: []const u8 = if (rt_options.has_embedded_rom) @embedFile("embedded_rom") else &.{};

pub fn hasEmbeddedRom() bool {
    return embedded_rom_bytes.len > 0;
}

const flash_mod = core.flash;
const timers_mod = core.timers;
const dma_mod = core.dma;
const bios_mod = core.bios;
const interp_mod = core.interp;

const Flash = flash_mod.Flash;
const Eeprom = flash_mod.Eeprom;
const Timers = timers_mod.Timers;
const Dma = dma_mod.Dma;
const BusMode = dma_mod.BusMode;

const has_posix = builtin.os.tag != .freestanding;

const c_host = if (has_posix) struct {
    const FILE = std.c.FILE;
    extern "c" fn getenv(name: [*:0]const u8) ?[*:0]const u8;
    extern "c" fn fopen(filename: [*:0]const u8, mode: [*:0]const u8) ?*FILE;
    extern "c" fn fclose(stream: *FILE) c_int;
    extern "c" fn fread(ptr: [*]u8, size: usize, nmemb: usize, stream: *FILE) usize;
    extern "c" fn fwrite(ptr: [*]const u8, size: usize, nmemb: usize, stream: *FILE) usize;
    extern "c" fn fseek(stream: *FILE, offset: c_long, whence: c_int) c_int;
    extern "c" fn ftell(stream: *FILE) c_long;
    extern "c" fn malloc(size: usize) ?[*]u8;
    extern "c" fn free(ptr: ?*anyopaque) void;
    extern "c" fn exit(status: c_int) noreturn;
    extern "c" fn atoi(nptr: [*:0]const u8) c_int;
    extern "c" fn atol(nptr: [*:0]const u8) c_long;
    extern "c" fn strtoul(nptr: [*:0]const u8, endptr: ?*?[*]u8, base: c_int) c_ulong;
    extern "c" fn readlink(pathname: [*:0]const u8, buf: [*]u8, bufsiz: usize) isize;
    extern "c" fn rename(oldpath: [*:0]const u8, newpath: [*:0]const u8) c_int;
    extern "c" fn remove(pathname: [*:0]const u8) c_int;
} else struct {
    const FILE = opaque {};
};

// Callbacks registered at startup by `src/main.zig` from generated `game.zig`.
pub const GameCallbacks = struct {
    bx_depth: *i32,
    cpu_bx: *const fn (u32) callconv(.c) void,
    recomp_lookup: *const fn (u32) u32,
    recomp_lookup_fn: *const fn (u32) ?*const fn () callconv(.c) void,
};

var game_cb: ?GameCallbacks = null;

pub fn registerGameCallbacks(cb: GameCallbacks) void {
    game_cb = cb;
}

inline fn cbCpuBx(target: u32) void {
    if (game_cb) |cb| cb.cpu_bx(target);
}

inline fn cbRecompLookup(addr: u32) u32 {
    return if (game_cb) |cb| cb.recomp_lookup(addr) else 0;
}

inline fn cbRecompLookupFn(addr: u32) ?*const fn () callconv(.c) void {
    return if (game_cb) |cb| cb.recomp_lookup_fn(addr) else null;
}

// ---- CPU & Memory Globals (exported to independent gen shards) ----
pub export var r: [16]u32 = @splat(0);
pub export var CPU_N: bool = false;
pub export var CPU_Z: bool = false;
pub export var CPU_C: bool = false;
pub export var CPU_V: bool = false;

pub var ewram: ?[*]u8 = null;
pub var iwram: ?[*]u8 = null;
pub var io_regs: ?[*]u8 = null;
pub var palette: ?[*]u8 = null;
pub var vram: ?[*]u8 = null;
pub var oam: ?[*]u8 = null;

pub export var g_func_ring: [4096]u32 = @splat(0);
pub export var g_func_ring_i: u32 = 0;
pub export var g_validate: c_int = 0;
pub export var g_ret: u32 = 0;
pub export var g_unwind_trace: c_int = 0;
pub export var g_hist_on: c_int = 0;

pub fn dispParseArgs(args: []const [*:0]const u8) ?[*:0]const u8 {
    return disp.parseArgsSlice(args);
}

pub fn dispSavePath() ?[*:0]const u8 {
    return disp.savePath();
}

pub fn linkShardExports() void {
    const syms = .{
        &r,             &CPU_N,        &CPU_Z,        &CPU_C,           &CPU_V,
        &g_func_ring,   &g_func_ring_i, &g_validate,  &g_ret,           &g_unwind_trace,
        &g_hist_on,     &bus_read32,   &bus_read32s,  &bus_read16,      &bus_read8,
        &bus_write32,   &bus_write16,  &bus_write8,   &cpu_fetches,     &gba_swi,
        &cpu_get_cpsr,  &cpu_set_cpsr, &cpu_get_spsr, &cpu_set_spsr,    &cpu_undefined,
        &recomp_enter,  &recomp_called_slow, &recomp_unwind_note, &recomp_hist, &recomp_validate,
        &awre_run_iwram_function,
    };
    inline for (syms) |s| {
        std.mem.doNotOptimizeAway(s);
    }
}

// ---- Backing Memory Storage ----
var ewram_buf: [0x40000]u8 = @splat(0);
var iwram_buf: [0x8000]u8 = @splat(0);
var io_regs_buf: [0x400]u8 = @splat(0);
var palette_buf: [0x400]u8 = @splat(0);
var vram_buf: [0x18000]u8 = @splat(0);
var oam_buf: [0x400]u8 = @splat(0);
var sram_buf: [0x20000]u8 = @splat(0);
var sram_active: bool = false;

var rom_ptr: ?[*]const u8 = null;
var rom_size: u32 = 0;
var rom_owned: bool = false;
var bios_mem_ptr: ?[*]u8 = null;

pub fn romSlice() ?[]const u8 {
    const p = rom_ptr orelse return null;
    if (rom_size == 0) return null;
    return p[0..rom_size];
}

const wasm_rom_max: usize = 16 * 1024 * 1024;
var wasm_rom_buf: if (!has_posix) [wasm_rom_max]u8 else [0]u8 = @splat(0);
var wasm_stop_requested: bool = false;

var exe_path_buf: [512]u8 = @splat(0);
var sram_path_buf: [512]u8 = @splat(0);
var sram_path_len: usize = 0;
var eeprom_path_buf: [512]u8 = @splat(0);
var eeprom_path_len: usize = 0;

const save_debounce_frames = save_io.save_debounce_frames;
var sram_dirty_frames: u32 = 0;
var sram_last_seq: u32 = 0;
var eeprom_dirty_frames: u32 = 0;
var eeprom_last_seq: u32 = 0;

// ---- CPU Mode, Backup, Peripherals & Scheduler State ----
var cpsr: u32 = 0x0000_001F;
var spsr: u32 = 0;

var flash_state: Flash = .{};
var eeprom_state: Eeprom = .{};
var timer_state: Timers = .{};
var dma_state: Dma = .{};

var cycle_counter: u32 = 0;
var scanline: u32 = 0;
var frame_count: u32 = 0;
var scanline_cycles: u32 = 0;
var hblank_done: bool = false;
var last_poll_cycle: u32 = 0;

var bus_mode: BusMode = .rom_code;
var cycle_credit: i32 = 0;
var vram_burst: bool = false;
var in_irq: bool = false;
var soft_reset_pending: bool = false;
var soft_reset_count: u32 = 0;

const cycles_per_scanline = timing.cycles_per_scanline;
const visible_scanlines = timing.visible_scanlines;
const scanlines_per_frame = timing.scanlines_per_frame;
const cycles_per_frame = timing.cycles_per_frame;
const hblank_start_cycle = timing.hblank_start_cycle;
const poll_interval = timing.poll_interval;

// ---- Fetch Timing State ----
var fetch_x16: u32 = 0;
var fetch_frac: u32 = 0;

// ---- Inline I/O & Memory Helpers ----
inline fn ioRead16(off: u32) u16 {
    return @as(u16, io_regs_buf[off]) | (@as(u16, io_regs_buf[off + 1]) << 8);
}

inline fn ioWrite16(off: u32, val: u16) void {
    io_regs_buf[off] = @truncate(val);
    io_regs_buf[off + 1] = @truncate(val >> 8);
}

inline fn ioRead32(off: u32) u32 {
    return @as(u32, io_regs_buf[off]) |
        (@as(u32, io_regs_buf[off + 1]) << 8) |
        (@as(u32, io_regs_buf[off + 2]) << 16) |
        (@as(u32, io_regs_buf[off + 3]) << 24);
}

inline fn memWrite16Raw(mem: []u8, off: u32, val: u16) void {
    mem[off] = @truncate(val);
    mem[off + 1] = @truncate(val >> 8);
}

inline fn memWrite32Raw(mem: []u8, off: u32, val: u32) void {
    mem[off] = @truncate(val);
    mem[off + 1] = @truncate(val >> 8);
    mem[off + 2] = @truncate(val >> 16);
    mem[off + 3] = @truncate(val >> 24);
}

inline fn raiseIrqBits(mask: u16) void {
    ioWrite16(0x202, ioRead16(0x202) | mask);
}

// ---- Timing & Waitstates ----
inline fn accessCycles(addr: u32, wide: bool) u32 {
    return timing.accessCycles(addr, wide, ioRead16(0x204));
}

inline fn dataCycles(addr: u32, wide: bool, load: bool) i32 {
    return timing.dataCycles(addr, wide, load, bus_mode, &io_regs_buf, scanline, scanline_cycles, vram_burst);
}

fn charge(c_delta: i32) void {
    const c = c_delta + cycle_credit;
    cycle_credit = if (c < 0) c else 0;
    if (c > 0) advanceCycles(@intCast(c));
}

const rt_file = @This();

// ---- DMA Bus Interface ----
const DmaBus = struct {
    pub fn ioRead16(_: *@This(), off: u32) u16 {
        return rt_file.ioRead16(off);
    }
    pub fn ioWrite16(_: *@This(), off: u32, val: u16) void {
        rt_file.ioWrite16(off, val);
    }
    pub fn ioRead32(_: *@This(), off: u32) u32 {
        return rt_file.ioRead32(off);
    }
    pub fn busRead32(_: *@This(), addr: u32) u32 {
        return bus_read32(addr);
    }
    pub fn busWrite32(_: *@This(), addr: u32, val: u32) void {
        bus_write32(addr, val);
    }
    pub fn busRead16(_: *@This(), addr: u32) u16 {
        return bus_read16(addr);
    }
    pub fn busWrite16(_: *@This(), addr: u32, val: u16) void {
        bus_write16(addr, val);
    }
    pub fn getBusMode(_: *@This()) BusMode {
        return bus_mode;
    }
    pub fn setBusMode(_: *@This(), m: BusMode) void {
        bus_mode = m;
    }
    pub fn raiseIrq(_: *@This(), mask: u16) void {
        raiseIrqBits(mask);
    }
};
var dma_bus: DmaBus = .{};

// ---- Interrupt Delivery ----
fn checkInterrupts() void {
    if (soft_reset_pending or validate_mod.g_validating or (in_irq and (cpsr & 0x80) != 0)) return;

    const ime = ioRead16(0x208);
    if (ime == 0) return;

    const ie = ioRead16(0x200);
    const if_val = ioRead16(0x202);
    const pending = ie & if_val;
    if (pending == 0) return;

    const handler_addr = @as(u32, iwram_buf[0x7FFC]) |
        (@as(u32, iwram_buf[0x7FFD]) << 8) |
        (@as(u32, iwram_buf[0x7FFE]) << 16) |
        (@as(u32, iwram_buf[0x7FFF]) << 24);
    if (handler_addr == 0) return;

    const was_in_irq = in_irq;
    const saved_cpsr = cpsr;
    const saved_spsr = spsr;
    spsr = cpu_get_cpsr();
    cpsr = (cpsr & ~@as(u32, 0xFF)) | 0x92;
    in_irq = true;

    const bios_if = (@as(u16, iwram_buf[0x7FF8]) | (@as(u16, iwram_buf[0x7FF9]) << 8)) | pending;
    iwram_buf[0x7FF8] = @truncate(bios_if);
    iwram_buf[0x7FF9] = @truncate(bios_if >> 8);

    const saved_r = r;
    const saved_N = CPU_N;
    const saved_Z = CPU_Z;
    const saved_C = CPU_C;
    const saved_V = CPU_V;
    const saved_ret = g_ret;
    g_ret = 0;
    const saved_mode = bus_mode;
    bus_mode = .rom_code;

    cbCpuBx(handler_addr);

    bus_mode = saved_mode;
    in_irq = was_in_irq;
    if (soft_reset_pending) return;

    g_ret = saved_ret;
    r = saved_r;
    CPU_N = saved_N;
    CPU_Z = saved_Z;
    CPU_C = saved_C;
    CPU_V = saved_V;
    cpsr = saved_cpsr;
    spsr = saved_spsr;
}

// ---- Scanline Scheduler ----
fn advanceCycles(cycles: u32) void {
    if (soft_reset_pending) return;

    var remaining: u32 = cycles;
    while (remaining > 0) {
        // Slice cycles at HBlank/scanline boundaries so scanline_cycles never overshoots
        // past a boundary before a re-entrant IRQ handler runs at that boundary.
        const next_boundary: u32 = if (!hblank_done) hblank_start_cycle else cycles_per_scanline;
        const to_boundary: u32 = if (scanline_cycles < next_boundary) next_boundary - scanline_cycles else 0;
        const step: u32 = @min(remaining, to_boundary);
        if (step > 0) {
            cycle_counter +%= step;
            scanline_cycles +%= step;
            remaining -= step;
            validate_mod.checkDeadline(cycle_counter);
            const timer_irqs = timer_state.tick(step);
            if (timer_irqs != 0) raiseIrqBits(timer_irqs);
        }

        if (!hblank_done and scanline_cycles >= hblank_start_cycle) {
            hblank_done = true;
            if (scanline < visible_scanlines and !validate_mod.g_validating) {
                disp.display_render_line(@intCast(scanline));
            }
            ioWrite16(0x004, ioRead16(0x004) | 2);
            if ((ioRead16(0x004) & 0x10) != 0) {
                ioWrite16(0x202, ioRead16(0x202) | 2);
            }
            if (scanline < visible_scanlines) {
                dma_state.triggerHBlank(&dma_bus);
            }
            checkInterrupts();
            if (soft_reset_pending) return;
            continue;
        }
        if (scanline_cycles >= cycles_per_scanline) {
            scanline_cycles -= cycles_per_scanline;
            hblank_done = false;

            const prev_scanline = scanline;
            scanline = (scanline + 1) % scanlines_per_frame;

            io_regs_buf[0x006] = @truncate(scanline & 0xFF);
            io_regs_buf[0x007] = 0;

            var dispstat = ioRead16(0x004);
            const vcount_target = (dispstat >> 8) & 0xFF;
            dispstat &= ~@as(u16, 0x0007);
            if (scanline >= visible_scanlines) dispstat |= 1;
            if (scanline == vcount_target) dispstat |= 4;
            ioWrite16(0x004, dispstat);

            if (scanline == visible_scanlines and prev_scanline != visible_scanlines) {
                ioWrite16(0x202, ioRead16(0x202) | 1);
                dma_state.triggerVBlank(&dma_bus);

                frame_count +%= 1;

                const keys = disp.display_get_keys();
                io_regs_buf[0x130] = @truncate(keys);
                io_regs_buf[0x131] = @truncate(keys >> 8);

                if (!validate_mod.g_validating) {
                    disp.display_render_frame();
                }
                disp.display_pace();

                diagnostics.checkHistFrame(frame_count, &g_hist_on);
                writeDumpAtSnapshot();
                if (!validate_mod.g_validating) pollBackupFlush();

                const log_every = disp.display_log_every();
                if (frame_count <= 5 or (log_every != 0 and @mod(frame_count, @as(u32, @intCast(log_every))) == 0)) {
                    const dispcnt = ioRead16(0x000);
                    const pal0 = @as(u16, palette_buf[0]) | (@as(u16, palette_buf[1]) << 8);
                    const pal1 = @as(u16, palette_buf[2]) | (@as(u16, palette_buf[3]) << 8);
                    core.gba.logPrint(
                        "[frame {d}] DISPCNT=0x{X:0>4} mode={d} BG={d}{d}{d}{d} OBJ={d} BLDCNT=0x{X:0>4} BLDY={d} pal0=0x{X:0>4} pal1=0x{X:0>4}\n",
                        .{
                            frame_count,
                            dispcnt,
                            dispcnt & 7,
                            (dispcnt >> 8) & 1,
                            (dispcnt >> 9) & 1,
                            (dispcnt >> 10) & 1,
                            (dispcnt >> 11) & 1,
                            (dispcnt >> 12) & 1,
                            ioRead16(0x050),
                            ioRead16(0x054) & 31,
                            pal0,
                            pal1,
                        },
                    );
                }
            }

            if (scanline == vcount_target and (dispstat & 0x20) != 0) {
                ioWrite16(0x202, ioRead16(0x202) | 4);
            }

            checkInterrupts();
            if (soft_reset_pending) return;
            continue;
        }
        if (step == 0) break;
    }

    if (cycle_counter -% last_poll_cycle > poll_interval) {
        last_poll_cycle = cycle_counter;
        if (disp.display_poll_events() != 0) {
            if (!wasm_stop_requested) gba_shutdown();
            if (has_posix) {
                c_host.exit(0);
            } else {
                wasm_stop_requested = true;
                soft_reset_pending = true;
                g_ret = 0xFFFF_FFFF;
                return;
            }
        }
    }
}

// ---- I/O Write Hook ----
fn ioWriteHook(off: u32) void {
    for (0..4) |ch| {
        const cnt_hi_off = Dma.cntHOffset(ch);
        if (off == cnt_hi_off or off == cnt_hi_off + 1) {
            const cnt_hi = ioRead16(cnt_hi_off);
            if ((cnt_hi & (1 << 15)) != 0) {
                dma_state.enable(ch, &dma_bus);
                dma_state.execute(ch, &dma_bus);
            }
        }
    }

    for (0..4) |t| {
        const cnt_l = Timers.cntLOffset(t);
        const cnt_h = Timers.cntHOffset(t);
        if (off == cnt_l or off == cnt_l + 1) {
            timer_state.writeReload(t, ioRead16(cnt_l));
        }
        if (off == cnt_h or off == cnt_h + 1) {
            const v = ioRead16(cnt_h);
            timer_state.writeControl(t, v);
            ioWrite16(cnt_h, v);
        }
    }

    if (off == 0x128 or off == 0x129) {
        var siocnt = ioRead16(0x128);
        if ((siocnt & 0x80) != 0) {
            const sio_send = ioRead16(0x12A);
            ioWrite16(0x120, sio_send);
            ioWrite16(0x122, 0xFFFF);
            ioWrite16(0x124, 0xFFFF);
            ioWrite16(0x126, 0xFFFF);
            siocnt = (siocnt & ~@as(u16, 0x80)) | 0x40;
            ioWrite16(0x128, siocnt);
            if ((siocnt & 0x4000) != 0) {
                raiseIrqBits(0x80);
                const bios_if = (@as(u16, iwram_buf[0x7FF8]) | (@as(u16, iwram_buf[0x7FF9]) << 8)) | 0x80;
                iwram_buf[0x7FF8] = @truncate(bios_if);
                iwram_buf[0x7FF9] = @truncate(bios_if >> 8);
            }
        }
    }
}

// ---- Memory Bus Implementation ----
inline fn watchCheck(addr: u32, value: u32, size_bytes: u32) void {
    diagnostics.watchCheck(addr, value, size_bytes, in_irq, frame_count, &g_func_ring, g_func_ring_i, r[14]);
}

inline fn romByte(off: u32) u8 {
    const ptr = rom_ptr orelse return 0;
    return ptr[off % rom_size];
}

fn read32_(addr_in: u32) u32 {
    const addr = addr_in & ~@as(u32, 3);
    const region = addr >> 24;
    switch (region) {
        0x00 => {
            const off = addr & 0x3FFF;
            if (bios_mem_ptr) |bm| {
                return @as(u32, bm[off]) |
                    (@as(u32, bm[off + 1]) << 8) |
                    (@as(u32, bm[off + 2]) << 16) |
                    (@as(u32, bm[off + 3]) << 24);
            }
            return 0;
        },
        0x02 => {
            const off = addr & 0x3FFFF;
            return @as(u32, ewram_buf[off]) |
                (@as(u32, ewram_buf[off + 1]) << 8) |
                (@as(u32, ewram_buf[off + 2]) << 16) |
                (@as(u32, ewram_buf[off + 3]) << 24);
        },
        0x03 => {
            const off = addr & 0x7FFF;
            return @as(u32, iwram_buf[off]) |
                (@as(u32, iwram_buf[off + 1]) << 8) |
                (@as(u32, iwram_buf[off + 2]) << 16) |
                (@as(u32, iwram_buf[off + 3]) << 24);
        },
        0x04 => {
            if ((addr & 0x00FF_FFFF) >= 0x400) return 0;
            const off = addr & 0x3FF;
            for (0..4) |t| {
                if (off == Timers.cntLOffset(t)) {
                    const cnt = timer_state.readCounter(t);
                    const ctl = timer_state.readControl(t);
                    return @as(u32, cnt) | (@as(u32, ctl) << 16);
                }
            }
            return ioRead32(off);
        },
        0x05 => {
            const off = addr & 0x3FF;
            return @as(u32, palette_buf[off]) |
                (@as(u32, palette_buf[off + 1]) << 8) |
                (@as(u32, palette_buf[off + 2]) << 16) |
                (@as(u32, palette_buf[off + 3]) << 24);
        },
        0x06 => {
            var off = addr & 0x1FFFF;
            if (off >= 0x18000) off -= 0x8000;
            return @as(u32, vram_buf[off]) |
                (@as(u32, vram_buf[off + 1]) << 8) |
                (@as(u32, vram_buf[off + 2]) << 16) |
                (@as(u32, vram_buf[off + 3]) << 24);
        },
        0x07 => {
            const off = addr & 0x3FF;
            return @as(u32, oam_buf[off]) |
                (@as(u32, oam_buf[off + 1]) << 8) |
                (@as(u32, oam_buf[off + 2]) << 16) |
                (@as(u32, oam_buf[off + 3]) << 24);
        },
        0x08...0x0D => {
            if (eeprom_state.isAddr(addr, rom_size)) {
                const v0 = eeprom_state.read();
                const v1 = eeprom_state.read();
                return @as(u32, v0) | (@as(u32, v1) << 16);
            }
            if (rom_size == 0) return 0;
            const off = (addr - 0x0800_0000) % rom_size;
            return @as(u32, romByte(off)) |
                (@as(u32, romByte(off + 1)) << 8) |
                (@as(u32, romByte(off + 2)) << 16) |
                (@as(u32, romByte(off + 3)) << 24);
        },
        0x0E, 0x0F => {
            if (!sram_active) return 0;
            const val: u32 = flash_state.read8(&sram_buf, addr, cycle_counter);
            return val | (val << 8) | (val << 16) | (val << 24);
        },
        else => return 0,
    }
}

fn read16_(addr_in: u32) u16 {
    const addr = addr_in & ~@as(u32, 1);
    const region = addr >> 24;
    switch (region) {
        0x02 => {
            const off = addr & 0x3FFFF;
            return @as(u16, ewram_buf[off]) | (@as(u16, ewram_buf[off + 1]) << 8);
        },
        0x03 => {
            const off = addr & 0x7FFF;
            return @as(u16, iwram_buf[off]) | (@as(u16, iwram_buf[off + 1]) << 8);
        },
        0x04 => {
            if ((addr & 0x00FF_FFFF) >= 0x400) return 0;
            const off = addr & 0x3FF;
            for (0..4) |t| {
                if (off == Timers.cntLOffset(t)) return timer_state.readCounter(t);
                if (off == Timers.cntHOffset(t)) return timer_state.readControl(t);
            }
            return ioRead16(off);
        },
        0x05 => {
            const off = addr & 0x3FF;
            return @as(u16, palette_buf[off]) | (@as(u16, palette_buf[off + 1]) << 8);
        },
        0x06 => {
            var off = addr & 0x1FFFF;
            if (off >= 0x18000) off -= 0x8000;
            return @as(u16, vram_buf[off]) | (@as(u16, vram_buf[off + 1]) << 8);
        },
        0x07 => {
            const off = addr & 0x3FF;
            return @as(u16, oam_buf[off]) | (@as(u16, oam_buf[off + 1]) << 8);
        },
        0x08...0x0D => {
            if (eeprom_state.isAddr(addr, rom_size)) return eeprom_state.read();
            if (rom_size == 0) return 0;
            const off = (addr - 0x0800_0000) % rom_size;
            return @as(u16, romByte(off)) | (@as(u16, romByte(off + 1)) << 8);
        },
        0x0E, 0x0F => {
            const v: u16 = if (sram_active) flash_state.read8(&sram_buf, addr, cycle_counter) else 0;
            return v * 0x0101;
        },
        else => return 0,
    }
}

fn read8_(addr: u32) u8 {
    return switch (addr >> 24) {
        0x02 => ewram_buf[addr & 0x3FFFF],
        0x03 => iwram_buf[addr & 0x7FFF],
        0x04 => if ((addr & 0x00FF_FFFF) >= 0x400) 0 else io_regs_buf[addr & 0x3FF],
        0x05 => palette_buf[addr & 0x3FF],
        0x06 => blk: {
            var off = addr & 0x1FFFF;
            if (off >= 0x18000) off -= 0x8000;
            break :blk vram_buf[off];
        },
        0x07 => oam_buf[addr & 0x3FF],
        0x08...0x0D => blk: {
            if (eeprom_state.isAddr(addr, rom_size)) break :blk @truncate(eeprom_state.read());
            if (rom_size == 0) break :blk 0;
            break :blk romByte((addr - 0x0800_0000) % rom_size);
        },
        0x0E, 0x0F => if (sram_active) flash_state.read8(&sram_buf, addr, cycle_counter) else 0,
        else => 0,
    };
}

fn busWrite32_(addr_in: u32, value: u32) void {
    watchCheck(addr_in, value, 4);
    const addr = addr_in & ~@as(u32, 3);
    switch (addr >> 24) {
        0x02 => memWrite32Raw(&ewram_buf, addr & 0x3FFFF, value),
        0x03 => memWrite32Raw(&iwram_buf, addr & 0x7FFF, value),
        0x04 => {
            if ((addr & 0x00FF_FFFF) >= 0x400) return;
            const off = addr & 0x3FF;
            if (off == 0x200) {
                memWrite16Raw(&io_regs_buf, 0x200, @truncate(value));
                const if_clear: u16 = @truncate(value >> 16);
                ioWrite16(0x202, ioRead16(0x202) & ~if_clear);
            } else {
                memWrite32Raw(&io_regs_buf, off, value);
                ioWriteHook(off);
                ioWriteHook(off + 2);
            }
        },
        0x05 => memWrite32Raw(&palette_buf, addr & 0x3FF, value),
        0x06 => {
            var off = addr & 0x1FFFF;
            if (off >= 0x18000) off -= 0x8000;
            memWrite32Raw(&vram_buf, off, value);
        },
        0x07 => memWrite32Raw(&oam_buf, addr & 0x3FF, value),
        0x08...0x0D => {
            if (eeprom_state.isAddr(addr, rom_size)) {
                eeprom_state.write(@truncate(value));
                eeprom_state.write(@truncate(value >> 16));
            }
        },
        0x0E, 0x0F => {
            if (sram_active) flash_state.write8(&sram_buf, addr, @truncate(value), cycle_counter);
        },
        else => {},
    }
}

fn busWrite16_(addr_in: u32, value: u16) void {
    watchCheck(addr_in, value, 2);
    const addr = addr_in & ~@as(u32, 1);
    switch (addr >> 24) {
        0x02 => memWrite16Raw(&ewram_buf, addr & 0x3FFFF, value),
        0x03 => memWrite16Raw(&iwram_buf, addr & 0x7FFF, value),
        0x04 => {
            if ((addr & 0x00FF_FFFF) >= 0x400) return;
            const off = addr & 0x3FF;
            if (off == 0x202) {
                ioWrite16(0x202, ioRead16(0x202) & ~value);
            } else {
                memWrite16Raw(&io_regs_buf, off, value);
                ioWriteHook(off);
            }
        },
        0x05 => memWrite16Raw(&palette_buf, addr & 0x3FF, value),
        0x06 => {
            var off = addr & 0x1FFFF;
            if (off >= 0x18000) off -= 0x8000;
            memWrite16Raw(&vram_buf, off, value);
        },
        0x07 => memWrite16Raw(&oam_buf, addr & 0x3FF, value),
        0x08...0x0D => {
            if (eeprom_state.isAddr(addr, rom_size)) eeprom_state.write(value);
        },
        0x0E, 0x0F => {
            if (sram_active) flash_state.write8(&sram_buf, addr, @truncate(value), cycle_counter);
        },
        else => {},
    }
}

fn busWrite8_(addr: u32, value: u8) void {
    watchCheck(addr, value, 1);
    switch (addr >> 24) {
        0x02 => ewram_buf[addr & 0x3FFFF] = value,
        0x03 => iwram_buf[addr & 0x7FFF] = value,
        0x04 => {
            if ((addr & 0x00FF_FFFF) >= 0x400) return;
            const off = addr & 0x3FF;
            if (off == 0x202 or off == 0x203) {
                const if_val = ioRead16(0x202);
                if (off == 0x202) {
                    ioWrite16(0x202, if_val & ~@as(u16, value));
                } else {
                    ioWrite16(0x202, if_val & ~(@as(u16, value) << 8));
                }
            } else {
                io_regs_buf[off] = value;
                ioWriteHook(off);
            }
        },
        0x05 => {
            const off = addr & 0x3FE;
            palette_buf[off] = value;
            palette_buf[off + 1] = value;
        },
        0x06 => {
            var off = addr & 0x1FFFE;
            if (off >= 0x18000) off -= 0x8000;
            vram_buf[off] = value;
            vram_buf[off + 1] = value;
        },
        0x0E, 0x0F => {
            if (sram_active) flash_state.write8(&sram_buf, addr, value, cycle_counter);
        },
        else => {},
    }
}

// ---- Bus & CPU Timing API ----
pub export fn bus_read32(addr: u32) u32 {
    charge(dataCycles(addr, true, true));
    return read32_(addr);
}

pub export fn bus_read32s(addr: u32) u32 {
    charge(dataCycles(addr, true, false));
    return read32_(addr);
}

pub export fn bus_read16(addr: u32) u16 {
    charge(dataCycles(addr, false, true));
    return read16_(addr);
}

pub export fn bus_read8(addr: u32) u8 {
    charge(dataCycles(addr, false, true));
    return read8_(addr);
}

pub export fn bus_write32(addr: u32, value: u32) void {
    busWrite32_(addr, value);
    charge(dataCycles(addr, true, false));
}

pub export fn bus_write16(addr: u32, value: u16) void {
    busWrite16_(addr, value);
    charge(dataCycles(addr, false, false));
}

pub export fn bus_write8(addr: u32, value: u8) void {
    busWrite8_(addr, value);
    charge(dataCycles(addr, false, false));
}

pub export fn cpu_fetches(n: u32) void {
    if (fetch_x16 == 0) {
        if (has_posix) {
            if (c_host.getenv("GBA_FETCH_X16")) |e| {
                fetch_x16 = @truncate(@as(u32, @bitCast(c_host.atoi(e))));
            }
        }
        if (fetch_x16 == 0) fetch_x16 = 16;
    }
    const w = ioRead16(0x204);
    const seq_cost: u32 = if ((w & 0x10) != 0) 2 else 3;
    fetch_frac +%= n *% fetch_x16 *% seq_cost;
    charge(@intCast(fetch_frac >> 4));
    fetch_frac &= 15;
}

// ---- CPSR / SPSR ----
pub export fn cpu_get_cpsr() u32 {
    var flags: u32 = 0;
    if (CPU_N) flags |= 1 << 31;
    if (CPU_Z) flags |= 1 << 30;
    if (CPU_C) flags |= 1 << 29;
    if (CPU_V) flags |= 1 << 28;
    return flags | (cpsr & 0x0FFF_FFFF);
}

pub export fn cpu_set_cpsr(value: u32, mask: u32) void {
    if ((mask & 8) != 0) {
        CPU_N = ((value >> 31) & 1) != 0;
        CPU_Z = ((value >> 30) & 1) != 0;
        CPU_C = ((value >> 29) & 1) != 0;
        CPU_V = ((value >> 28) & 1) != 0;
    }
    if ((mask & 1) != 0) {
        cpsr = (cpsr & ~@as(u32, 0xFF)) | (value & 0xFF);
    }
}

pub export fn cpu_get_spsr() u32 {
    return spsr;
}

pub export fn cpu_set_spsr(value: u32, mask: u32) void {
    if ((mask & 8) != 0) spsr = (spsr & 0x0FFF_FFFF) | (value & 0xF000_0000);
    if ((mask & 1) != 0) spsr = (spsr & ~@as(u32, 0xFF)) | (value & 0xFF);
}

// ---- Runtime Context Adapters & Exports ----
const AdapterRt = struct {
    pub fn regs() *[16]u32 {
        return &r;
    }
    pub fn ewram() *[0x40000]u8 {
        return &ewram_buf;
    }
    pub fn iwram() *[0x8000]u8 {
        return &iwram_buf;
    }
    pub fn palette() *[0x400]u8 {
        return &palette_buf;
    }
    pub fn vram() *[0x18000]u8 {
        return &vram_buf;
    }
    pub fn oam() *[0x400]u8 {
        return &oam_buf;
    }
    pub fn getN() bool {
        return CPU_N;
    }
    pub fn setN(b: bool) void {
        CPU_N = b;
    }
    pub fn getZ() bool {
        return CPU_Z;
    }
    pub fn setZ(b: bool) void {
        CPU_Z = b;
    }
    pub fn getC() bool {
        return CPU_C;
    }
    pub fn setC(b: bool) void {
        CPU_C = b;
    }
    pub fn getV() bool {
        return CPU_V;
    }
    pub fn setV(b: bool) void {
        CPU_V = b;
    }
    pub fn getCpsr() u32 {
        return cpu_get_cpsr();
    }
    pub fn setCpsr(val: u32, mask: u32) void {
        cpu_set_cpsr(val, mask);
    }
    pub fn setCpsrRaw(val: u32) void {
        cpsr = val;
    }
    pub fn getSpsr() u32 {
        return cpu_get_spsr();
    }
    pub fn setSpsr(val: u32, mask: u32) void {
        cpu_set_spsr(val, mask);
    }
    pub fn getBusMode() BusMode {
        return bus_mode;
    }
    pub fn setBusMode(m: BusMode) void {
        bus_mode = m;
    }
    pub fn setVramBurst(b: bool) void {
        vram_burst = b;
    }
    pub fn triggerSoftReset() void {
        soft_reset_pending = true;
        g_ret = 0xFFFF_FFFF;
    }
    pub fn softResetPending() bool {
        return soft_reset_pending;
    }
    pub fn getBxDepth() i32 {
        return if (game_cb) |cb| cb.bx_depth.* else 0;
    }
    pub fn setBxDepth(v: i32) void {
        if (game_cb) |cb| cb.bx_depth.* = v;
    }
    pub fn getRet() u32 {
        return g_ret;
    }
    pub fn setRet(val: u32) void {
        g_ret = val;
    }
    pub fn frameCount() u32 {
        return frame_count;
    }
    pub fn scanline() u32 {
        return rt_file.scanline;
    }
    pub fn cycleCounter() u32 {
        return cycle_counter;
    }
    pub fn romSize() u32 {
        return rom_size;
    }
    pub fn romByte(off: u32) u8 {
        return rt_file.romByte(off);
    }
    pub fn ioRead16(off: u32) u16 {
        return rt_file.ioRead16(off);
    }
    pub fn accessCycles(addr: u32, wide: bool) u32 {
        return rt_file.accessCycles(addr, wide);
    }
    pub fn advanceCycles(cycles: u32) void {
        rt_file.advanceCycles(cycles);
    }
    pub fn dataCycles(addr: u32, wide: bool, load: bool) i32 {
        return rt_file.dataCycles(addr, wide, load);
    }
    pub fn charge(c_delta: i32) void {
        rt_file.charge(c_delta);
    }
    pub fn read32Raw(addr: u32) u32 {
        return read32_(addr);
    }
    pub fn read16Raw(addr: u32) u16 {
        return read16_(addr);
    }
    pub fn busWrite32Raw(addr: u32, val: u32) void {
        busWrite32_(addr, val);
    }
    pub fn busRead8(addr: u32) u8 {
        return bus_read8(addr);
    }
    pub fn busWrite8(addr: u32, v: u8) void {
        bus_write8(addr, v);
    }
    pub fn busRead16(addr: u32) u16 {
        return bus_read16(addr);
    }
    pub fn busWrite16(addr: u32, v: u16) void {
        bus_write16(addr, v);
    }
    pub fn busRead32(addr: u32) u32 {
        return bus_read32(addr);
    }
    pub fn busRead32s(addr: u32) u32 {
        return bus_read32s(addr);
    }
    pub fn busWrite32(addr: u32, v: u32) void {
        bus_write32(addr, v);
    }
    pub fn swi(number: u32) void {
        gba_swi(number);
    }
    pub fn cpuBx(addr: u32) void {
        cbCpuBx(addr);
    }
    pub fn recompLookup(addr: u32) u32 {
        return cbRecompLookup(addr);
    }
    pub fn recompLookupFn(addr: u32) ?*const fn () callconv(.c) void {
        return cbRecompLookupFn(addr);
    }
    pub fn stateSave(s: *validate_mod.MachineState) void {
        @memcpy(&s.ewram, &ewram_buf);
        @memcpy(&s.iwram, &iwram_buf);
        @memcpy(&s.io, &io_regs_buf);
        @memcpy(&s.pal, &palette_buf);
        @memcpy(&s.vram, &vram_buf);
        @memcpy(&s.oam, &oam_buf);
        s.r = r;
        s.n = CPU_N;
        s.z = CPU_Z;
        s.c = CPU_C;
        s.v = CPU_V;
        s.cpsr = cpsr;
        s.spsr = spsr;
        s.cycle_counter = cycle_counter;
        s.scanline = rt_file.scanline;
        s.scanline_cycles = scanline_cycles;
        s.hblank_done = if (hblank_done) 1 else 0;
        s.last_poll_cycle = last_poll_cycle;
        s.frame_count = frame_count;
        s.timers = timer_state.ch;
        s.bus_mode = bus_mode;
        s.cycle_credit = cycle_credit;
        s.vram_burst = vram_burst;
    }
    pub fn stateLoad(s: *const validate_mod.MachineState) void {
        @memcpy(&ewram_buf, &s.ewram);
        @memcpy(&iwram_buf, &s.iwram);
        @memcpy(&io_regs_buf, &s.io);
        @memcpy(&palette_buf, &s.pal);
        @memcpy(&vram_buf, &s.vram);
        @memcpy(&oam_buf, &s.oam);
        r = s.r;
        CPU_N = s.n;
        CPU_Z = s.z;
        CPU_C = s.c;
        CPU_V = s.v;
        cpsr = s.cpsr;
        spsr = s.spsr;
        cycle_counter = s.cycle_counter;
        rt_file.scanline = s.scanline;
        scanline_cycles = s.scanline_cycles;
        hblank_done = (s.hblank_done != 0);
        last_poll_cycle = s.last_poll_cycle;
        frame_count = s.frame_count;
        timer_state.ch = s.timers;
        bus_mode = s.bus_mode;
        cycle_credit = s.cycle_credit;
        vram_burst = s.vram_burst;
    }
};

var bios_ctx: adapters.BiosCtx(AdapterRt) = .{};

pub export fn gba_swi(number: u32) void {
    if (soft_reset_pending) {
        g_ret = 0xFFFF_FFFF;
        return;
    }
    bios_mod.swi(&bios_ctx, number);
}

var interp_ctx: adapters.InterpCtx(AdapterRt) = .{};

pub fn run_iwram_function(target: u32) void {
    if (soft_reset_pending) {
        g_ret = 0xFFFF_FFFF;
        return;
    }
    interp_mod.runFunction(&interp_ctx, target);
}

pub export fn awre_run_iwram_function(target: u32) void {
    run_iwram_function(target);
}

// ---- Misc Runtime API Functions ----
pub fn cpu_bx_trace(target: u32) void {
    diagnostics.traceCpuBx(target);
}

pub export fn cpu_undefined(insn: u32) void {
    core.gba.logPrint("[runtime] Undefined instruction 0x{X:0>8} at PC=0x{X:0>8}\n", .{ insn, r[15] });
}

pub fn ppu_render_scanline() void {}

pub fn ppu_in_vblank() bool {
    return scanline >= visible_scanlines;
}

pub fn ppu_in_hblank() bool {
    return scanline_cycles >= hblank_start_cycle;
}

pub fn apu_step(_: u32) void {}

pub fn dma_check() void {}

pub fn timer_step(cycles: u32) void {
    const timer_irqs = timer_state.tick(cycles);
    if (timer_irqs != 0) raiseIrqBits(timer_irqs);
}

pub fn irq_check() void {
    checkInterrupts();
}

pub fn gba_frame() void {
    const target_cycle = ((cycle_counter / cycles_per_frame) + 1) * cycles_per_frame +
        visible_scanlines * cycles_per_scanline;
    while (cycle_counter < target_cycle) {
        advanceCycles(cycles_per_scanline);
        if (soft_reset_pending) return;
    }
}

pub fn gba_run(entry_func: *const fn () void) void {
    while (true) {
        soft_reset_pending = false;
        in_irq = false;
        g_ret = 0;
        entry_func();
        if (wasm_stop_requested or !soft_reset_pending) break;
        soft_reset_count +%= 1;
        if (soft_reset_count <= 5) {
            core.gba.logPrint("[runtime] SoftReset #{d}\n", .{soft_reset_count});
        }
    }
}

// ---- Save / Dump / Tracing / Validation ----
fn pollBackupFlush() void {
    if (flash_state.dirty) {
        if (flash_state.write_seq != sram_last_seq) {
            sram_last_seq = flash_state.write_seq;
            sram_dirty_frames = save_debounce_frames;
        } else if (sram_dirty_frames > 0) {
            sram_dirty_frames -= 1;
            if (sram_dirty_frames == 0) sramSave();
        }
    }
    if (eeprom_state.dirty) {
        if (eeprom_state.write_seq != eeprom_last_seq) {
            eeprom_last_seq = eeprom_state.write_seq;
            eeprom_dirty_frames = save_debounce_frames;
        } else if (eeprom_dirty_frames > 0) {
            eeprom_dirty_frames -= 1;
            if (eeprom_dirty_frames == 0) eepromSave();
        }
    }
}

fn sramLoad() void {
    if (!has_posix or !sram_active or sram_path_len == 0) return;
    const path: [*:0]const u8 = @ptrCast(&sram_path_buf);
    if (!save_io.readFileInto(path, sram_buf[0..flash_state.backup_size])) return;
    core.gba.logPrint("[runtime] Loaded SRAM from {s}\n", .{sram_path_buf[0..sram_path_len]});
}

fn sramSave() void {
    if (!sram_active or !flash_state.dirty) return;
    if (!has_posix) {
        core.platform.WasmBackend.saveSram(&sram_buf, flash_state.backup_size);
        flash_state.dirty = false;
        sram_dirty_frames = 0;
        return;
    }
    if (sram_path_len == 0) return;
    const path_slice = sram_path_buf[0..sram_path_len];
    const path: [*:0]const u8 = @ptrCast(&sram_path_buf);
    if (save_io.writeAtomicFile(path, path_slice, sram_buf[0..flash_state.backup_size])) {
        flash_state.dirty = false;
        sram_dirty_frames = 0;
        core.gba.logPrint("[runtime] Saved Flash to {s}\n", .{path_slice});
    }
}

fn eepromLoad() void {
    if (!has_posix or !eeprom_state.present or eeprom_path_len == 0) return;
    const path: [*:0]const u8 = @ptrCast(&eeprom_path_buf);
    if (!save_io.readFileInto(path, &eeprom_state.storage)) return;
    core.gba.logPrint("[runtime] Loaded EEPROM from {s}\n", .{eeprom_path_buf[0..eeprom_path_len]});
}

fn eepromSave() void {
    if (!has_posix or !eeprom_state.present or eeprom_path_len == 0 or !eeprom_state.dirty) return;
    const path_slice = eeprom_path_buf[0..eeprom_path_len];
    const path: [*:0]const u8 = @ptrCast(&eeprom_path_buf);
    if (save_io.writeAtomicFile(path, path_slice, &eeprom_state.storage)) {
        eeprom_state.dirty = false;
        eeprom_dirty_frames = 0;
        core.gba.logPrint("[runtime] Saved EEPROM to {s}\n", .{path_slice});
    }
}

fn writeDumpAtSnapshot() void {
    if (!has_posix) return;
    const dp = disp.display_dump_path(@intCast(frame_count)) orelse return;
    const df = c_host.fopen(dp, "wb") orelse return;
    defer _ = c_host.fclose(df);
    _ = c_host.fwrite(&ewram_buf, 1, ewram_buf.len, df);
    _ = c_host.fwrite(&iwram_buf, 1, iwram_buf.len, df);
    _ = c_host.fwrite(&io_regs_buf, 1, io_regs_buf.len, df);
    _ = c_host.fwrite(&palette_buf, 1, palette_buf.len, df);
    _ = c_host.fwrite(&vram_buf, 1, vram_buf.len, df);
    _ = c_host.fwrite(&oam_buf, 1, oam_buf.len, df);
}

pub export fn recomp_enter(addr: u32) bool {
    g_func_ring[g_func_ring_i & 4095] = addr;
    g_func_ring_i +%= 1;
    if (g_hist_on != 0) recomp_hist(addr);
    if (g_validate != 0 and recomp_validate(addr) != 0) return false;
    return true;
}

pub export fn recomp_called_slow(retaddr: u32) bool {
    if (soft_reset_pending) {
        g_ret = 0xFFFF_FFFF;
        return false;
    }
    if (((g_ret ^ retaddr) & ~@as(u32, 1)) != 0) {
        if (g_unwind_trace != 0) recomp_unwind_note(retaddr);
        return false;
    }
    g_ret = 0;
    return true;
}

pub export fn recomp_unwind_note(retaddr: u32) void {
    diagnostics.noteUnwind(frame_count, retaddr, g_ret, &g_func_ring, g_func_ring_i, &g_unwind_trace);
}

pub export fn recomp_hist(addr: u32) void {
    diagnostics.recordHist(addr);
}

var validate_host: adapters.ValidateHost(AdapterRt) = .{};

pub export fn recomp_validate(addr: u32) c_int {
    return validate_mod.runValidate(
        addr,
        g_validate,
        in_irq,
        frame_count,
        &validate_host,
        run_iwram_function,
    );
}

// ---- Lifecycle ----
fn resetCommonState() void {
    @memset(&ewram_buf, 0);
    @memset(&iwram_buf, 0);
    @memset(&io_regs_buf, 0);
    @memset(&palette_buf, 0);
    @memset(&vram_buf, 0);
    @memset(&oam_buf, 0);
    @memset(&sram_buf, 0);

    ewram = &ewram_buf;
    iwram = &iwram_buf;
    io_regs = &io_regs_buf;
    palette = &palette_buf;
    vram = &vram_buf;
    oam = &oam_buf;
    sram_active = true;

    flash_state = .{};
    eeprom_state = .{};
    timer_state = .{};
    dma_state = .{};

    cycle_counter = 0;
    scanline = 0;
    frame_count = 0;
    scanline_cycles = 0;
    hblank_done = false;
    last_poll_cycle = 0;
    bus_mode = .rom_code;
    cycle_credit = 0;
    vram_burst = false;
    in_irq = false;
    soft_reset_pending = false;
    soft_reset_count = 0;
    g_ret = 0;
    g_func_ring_i = 0;
    @memset(&g_func_ring, 0);
    sram_dirty_frames = 0;
    sram_last_seq = 0;
    eeprom_dirty_frames = 0;
    eeprom_last_seq = 0;
    wasm_stop_requested = false;
}

pub fn wasmRomBufPtr() [*]u8 {
    return if (!has_posix) &wasm_rom_buf else sram_buf[0..1].ptr;
}

pub fn wasmRomBufCap() u32 {
    return wasm_rom_max;
}

pub fn wasmSramBufPtr() [*]u8 {
    return &sram_buf;
}

pub fn wasmSramSize() u32 {
    return flash_state.backup_size;
}

pub fn wasmMarkSramClean() void {
    flash_state.dirty = false;
    flash_state.write_seq = 0;
    sram_last_seq = 0;
    sram_dirty_frames = 0;
}

pub fn gba_init_memory(rom_len: u32) bool {
    if (rom_len > wasm_rom_max) return false;
    resetCommonState();

    const rom_slice: []const u8 = if (rom_len > 0)
        (if (!has_posix) wasm_rom_buf[0..rom_len] else &.{})
    else
        embedded_rom_bytes;
    if (rom_slice.len == 0) return false;

    rom_ptr = rom_slice.ptr;
    rom_size = @intCast(rom_slice.len);
    rom_owned = false;

    if (flash_state.detect(rom_slice) != null) {
        @memset(sram_buf[0..flash_state.backup_size], 0xFF);
    }
    flash_state.dirty = false;
    flash_state.write_seq = 0;
    sram_last_seq = 0;

    _ = eeprom_state.detect(rom_slice);
    eeprom_state.dirty = false;
    eeprom_state.write_seq = 0;
    eeprom_last_seq = 0;

    initPostRomRegs();
    return disp.display_init() == 0;
}

fn initPostRomRegs() void {
    @memset(&r, 0);
    r[13] = 0x0300_7F00;
    r[15] = 0x0800_0000;
    cpsr = 0x0000_001F;
    spsr = 0;

    // KEYINPUT active-low all released, default SOUNDBIAS = 0x0200, SIOMULTI pull-ups 0xFFFF
    io_regs_buf[0x130] = 0xFF;
    io_regs_buf[0x131] = 0x03;
    io_regs_buf[0x088] = 0x00;
    io_regs_buf[0x089] = 0x02;
    @memset(io_regs_buf[0x120..0x128], 0xFF);
}

pub fn gba_init(rom_path_opt: ?[*:0]const u8, save_path_opt: ?[*:0]const u8, exe_arg0: ?[*:0]const u8) void {
    if (!has_posix) return;

    if (c_host.getenv("GBA_VALIDATE")) |e| g_validate = c_host.atoi(e);
    if (c_host.getenv("GBA_TRACE_UNWIND")) |e| g_unwind_trace = c_host.atoi(e);

    resetCommonState();

    var rom_slice: []const u8 = undefined;
    var default_base: []const u8 = undefined;
    var rom_label: []const u8 = undefined;

    if (rom_path_opt) |rom_path_c| {
        const f = c_host.fopen(rom_path_c, "rb") orelse {
            core.gba.logPrint("[runtime] Cannot open ROM: {s}\n", .{std.mem.span(rom_path_c)});
            c_host.exit(1);
        };
        _ = c_host.fseek(f, 0, 2); // SEEK_END
        const raw_len = c_host.ftell(f);
        if (raw_len <= 0) {
            _ = c_host.fclose(f);
            core.gba.logPrint("[runtime] Empty or unreadable ROM: {s}\n", .{std.mem.span(rom_path_c)});
            c_host.exit(1);
        }
        rom_size = @intCast(raw_len);
        _ = c_host.fseek(f, 0, 0); // SEEK_SET
        const mem = c_host.malloc(rom_size) orelse {
            _ = c_host.fclose(f);
            core.gba.logPrint("[runtime] Failed to allocate ROM buffer ({d} bytes)\n", .{rom_size});
            c_host.exit(1);
        };
        if (c_host.fread(mem, 1, rom_size, f) != rom_size) {
            _ = c_host.fclose(f);
            core.gba.logPrint("[runtime] Failed to read ROM\n", .{});
            c_host.exit(1);
        }
        _ = c_host.fclose(f);
        rom_ptr = mem;
        rom_owned = true;
        rom_slice = mem[0..rom_size];
        default_base = std.mem.span(rom_path_c);
        rom_label = default_base;
    } else if (embedded_rom_bytes.len > 0) {
        rom_ptr = embedded_rom_bytes.ptr;
        rom_size = @intCast(embedded_rom_bytes.len);
        rom_owned = false;
        rom_slice = embedded_rom_bytes;
        default_base = save_io.resolveSelfExePath(exe_arg0, &exe_path_buf);
        rom_label = "embedded";
    } else {
        core.gba.logPrint("[runtime] No ROM embedded and no ROM path given. Usage: awre <rom.gba> [options]\n", .{});
        c_host.exit(1);
    }

    if (save_path_opt) |sp| {
        const sp_slice = std.mem.span(sp);
        const formatted = std.mem.printSentinel(&sram_path_buf, "{s}", .{sp_slice}, 0) catch "";
        sram_path_len = formatted.len;
    } else {
        sram_path_len = save_io.buildSidecarPath(default_base, ".sav", &sram_path_buf);
    }
    if (flash_state.detect(rom_slice)) |tag| {
        const size_label: []const u8 = if (flash_state.large) "128KB" else "64KB";
        core.gba.logPrint("[runtime] Flash {s} detected ({s})\n", .{ size_label, tag });
        @memset(sram_buf[0..flash_state.backup_size], 0xFF);
    }
    sramLoad();
    flash_state.dirty = false;
    flash_state.write_seq = 0;
    sram_last_seq = 0;

    if (eeprom_state.detect(rom_slice)) |ee_addr| {
        core.gba.logPrint("[runtime] EEPROM detected at ROM 0x{X:0>8} (assuming 8KB)\n", .{ee_addr});
        const ee_base = if (save_path_opt) |sp| std.mem.span(sp) else default_base;
        eeprom_path_len = save_io.buildSidecarPath(ee_base, ".eep", &eeprom_path_buf);
        eepromLoad();
        eeprom_state.dirty = false;
        eeprom_state.write_seq = 0;
        eeprom_last_seq = 0;
    }

    initPostRomRegs();

    core.gba.logPrint("[runtime] GBA static recomp runtime initialized\n", .{});
    core.gba.logPrint("[runtime] ROM: {d} bytes ({s})\n", .{ rom_size, rom_label });
    if (sram_path_len > 0) {
        core.gba.logPrint("[runtime] Save path: {s}\n", .{sram_path_buf[0..sram_path_len]});
    }

    if (disp.display_init() != 0) {
        core.gba.logPrint("[runtime] Failed to initialize display\n", .{});
        c_host.exit(1);
    }
}

pub fn gba_shutdown() void {
    if (has_posix) {
        if (c_host.getenv("GBA_FUNC_TRACE") != null) diagnostics.funcRingDump(frame_count, &g_func_ring, g_func_ring_i);
    }
    validate_mod.printSummary(g_validate != 0);
    sramSave();
    eepromSave();
    disp.display_shutdown();

    ewram = null;
    iwram = null;
    io_regs = null;
    palette = null;
    vram = null;
    oam = null;
    sram_active = false;
    bios_mem_ptr = null;

    if (has_posix) {
        if (rom_owned) {
            if (rom_ptr) |ptr| {
                c_host.free(@constCast(ptr));
            }
        }
        rom_ptr = null;
        rom_owned = false;
    }
    rom_size = 0;
    core.gba.logPrint("[runtime] Shutdown\n", .{});
}

test {
    _ = timing;
    _ = save_io;
    _ = diagnostics;
    _ = adapters;
}
