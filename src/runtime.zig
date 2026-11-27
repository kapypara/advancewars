const std = @import("std");
const builtin = @import("builtin");
const core = @import("awre_core");
const disp = @import("platform/display.zig");
const validate_mod = @import("validate/validate.zig");
const rt_options = @import("rt_options");

const embedded_rom_bytes: []const u8 = if (rt_options.has_embedded_rom) @embedFile("embedded_rom") else &.{};

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
const MachineState = validate_mod.MachineState;

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

var exe_path_buf: [512]u8 = @splat(0);
var sram_path_buf: [512]u8 = @splat(0);
var sram_path_len: usize = 0;
var eeprom_path_buf: [512]u8 = @splat(0);
var eeprom_path_len: usize = 0;

const save_debounce_frames: u32 = 30;
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

const cycles_per_scanline: u32 = 1232;
const visible_scanlines: u32 = 160;
const scanlines_per_frame: u32 = 228;
const cycles_per_frame: u32 = cycles_per_scanline * scanlines_per_frame;
const hblank_start_cycle: u32 = 960;
const poll_interval: u32 = 10000;

// ---- Diagnostics State ----
var watch_addr: u32 = 1; // sentinel 1 = not read from env yet
var fetch_x16: u32 = 0;
var fetch_frac: u32 = 0;
var swi_log_init: bool = false;
var swi_log_from: i64 = -1;
var swi_log_to: i64 = -1;
var trace_interp_left: i64 = -1;
var trace_at_init: bool = false;
var trace_at_env: ?[]const u8 = null;
var bx_trace_count: u32 = 0;
var bx_trace_last: u32 = 0;
var unmapped_bx_warns: u32 = 0;
var interp_limit_warns: u32 = 0;

const HistEntry = struct {
    addr: u32 = 0,
    count: u32 = 0,
    first: u32 = 0,
};
var hist: [16384]HistEntry = @splat(.{});
var hist_out: [16384]HistEntry = @splat(.{});
var hist_n: u32 = 0;
var hist_seq: u32 = 0;
var ring_seen: [4096]u32 = @splat(0);
var ring_count: [4096]u32 = @splat(0);

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
const nwait_table = [4]u8{ 4, 3, 2, 8 };

fn accessCycles(addr: u32, wide: bool) u32 {
    return switch (addr >> 24) {
        0x02 => if (wide) 6 else 3,
        0x05, 0x06 => if (wide) 2 else 1,
        0x08...0x0D => blk: {
            const w = ioRead16(0x204);
            const n: u32 = 1 + @as(u32, nwait_table[(w >> 2) & 3]);
            const s: u32 = if ((w & 0x10) != 0) 2 else 3;
            break :blk if (wide) n + s else n;
        },
        0x0E, 0x0F => 1 + @as(u32, nwait_table[ioRead16(0x204) & 3]),
        else => 1,
    };
}

const vs_a2: u16 = 0x100;
const vs_a3: u16 = 0x200;
const vs_b: u16 = 0x400;
inline fn vsT4(comptime x: u4) u16 {
    return @as(u16, 0x011) << x;
}
inline fn vsT8(comptime x: u4) u16 {
    return @as(u16, 0x010) << x;
}

const vram_stall_lut = [32]u16{
    vsT4(0) | vs_a3, vsT4(1) | vs_a3, vsT4(2) | vs_a2, vsT4(3) | vs_a2 | vs_b,
    vsT4(0) | vs_a3, vsT4(1) | vs_a3, vsT4(2) | vs_a2, vsT4(3) | vs_a2 | vs_b,
    vs_a3,           vs_a3,           vs_a2,           vs_a2 | vs_b,
    vsT8(0) | vs_a3, vsT8(1) | vs_a3, vsT8(2) | vs_a2, vsT8(3) | vs_a2 | vs_b,
    vs_a3,           vs_a3,           vs_a2,           vs_a2 | vs_b,
    vsT4(0) | vs_a3, vsT4(1) | vs_a3, vsT4(2) | vs_a2, vsT4(3) | vs_a2 | vs_b,
    vs_a3,           vs_a3,           vs_a2,           vs_a2 | vs_b,
    vsT8(0) | vs_a3, vsT8(1) | vs_a3, vsT8(2) | vs_a2, vsT8(3) | vs_a2 | vs_b,
};

fn vramStall(addr: u32, wide: bool) u32 {
    const hdraw: u32 = 1008;
    if ((addr >> 24) != 0x06 or vram_burst or scanline >= visible_scanlines or scanline_cycles >= hdraw) {
        return 0;
    }
    const dispcnt = ioRead16(0x000);
    const mode = dispcnt & 7;
    if ((dispcnt & 0x80) != 0 or (addr & 0x1FFFF) >= (if (mode >= 3) @as(u32, 0x14000) else 0x10000)) {
        return 0;
    }

    var mask: u16 = 0;
    if (mode <= 1) {
        const bg_lim: u32 = if (mode != 0) 2 else 4;
        var i: u32 = 0;
        while (i < bg_lim) : (i += 1) {
            if ((dispcnt & (@as(u16, 0x100) << @intCast(i))) != 0) {
                const is_8bpp = (ioRead16(0x008 + 2 * i) & 0x80) != 0;
                const sh: u4 = @intCast(i);
                mask |= if (is_8bpp) (@as(u16, 0x010) << sh) else (@as(u16, 0x011) << sh);
            }
        }
    }
    if (mode == 1 and (dispcnt & 0x400) != 0) mask |= vs_a2;
    if (mode == 2) {
        if ((dispcnt & 0x400) != 0) mask |= vs_a2;
        if ((dispcnt & 0x800) != 0) mask |= vs_a3;
    }
    if (mode >= 3 and mode <= 5 and (dispcnt & 0x400) != 0) mask |= vs_b;
    if (mask == 0) return 0;

    const until: i32 = @as(i32, @intCast(hdraw)) - @as(i32, @intCast(scanline_cycles));
    var stall: i32 = until;
    var extra: i32 = if (wide) 1 else 0;
    var i: i32 = 0;
    while (i < 16) : (i += 1) {
        const lut_idx: usize = @intCast(@as(u32, @bitCast(-until + i)) & 31);
        if ((vram_stall_lut[lut_idx] & mask) == 0) {
            if (extra == 0) {
                stall = i;
                break;
            }
            extra -= 1;
        }
    }
    stall -= if (wide) @as(i32, 1) else 0;
    return if (stall > 0) @intCast(stall) else 0;
}

fn dataCycles(addr: u32, wide: bool, load: bool) i32 {
    const cart = addr >= 0x0800_0000;
    const load_c: i32 = if (load) 1 else 0;
    return switch (bus_mode) {
        .rom_code => blk: {
            if ((io_regs_buf[0x205] & 0x40) == 0) {
                break :blk @as(i32, @intCast(accessCycles(addr, wide))) + load_c + 2 + @as(i32, @intCast(vramStall(addr, wide)));
            }
            break :blk if (cart) @as(i32, @intCast(accessCycles(addr, wide))) + load_c + 2 else 0;
        },
        .bios_hle => if (cart) @as(i32, @intCast(accessCycles(addr, wide))) + load_c else -2,
        .ram_code => @as(i32, @intCast(accessCycles(addr, wide))) + load_c + @as(i32, @intCast(vramStall(addr, wide))),
        .dma => @intCast(accessCycles(addr, wide)),
    };
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
    cycle_counter +%= cycles;
    scanline_cycles +%= cycles;

    validate_mod.checkDeadline(cycle_counter);

    const timer_irqs = timer_state.tick(cycles);
    if (timer_irqs != 0) raiseIrqBits(timer_irqs);

    while (true) {
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
        if (scanline_cycles < cycles_per_scanline) break;
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

            checkHistFrame();
            writeDumpAtSnapshot();
            if (!validate_mod.g_validating) pollBackupFlush();

            const log_every = disp.display_log_every();
            if (frame_count <= 5 or (log_every != 0 and @mod(frame_count, @as(u32, @intCast(log_every))) == 0)) {
                const dispcnt = ioRead16(0x000);
                const pal0 = @as(u16, palette_buf[0]) | (@as(u16, palette_buf[1]) << 8);
                const pal1 = @as(u16, palette_buf[2]) | (@as(u16, palette_buf[3]) << 8);
                std.debug.print(
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
    }

    if (cycle_counter -% last_poll_cycle > poll_interval) {
        last_poll_cycle = cycle_counter;
        if (disp.display_poll_events() != 0) {
            gba_shutdown();
            if (has_posix) c_host.exit(0);
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
fn watchCheck(addr: u32, value: u32, size_bytes: u32) void {
    if (!has_posix) return;
    if (watch_addr == 1) {
        if (c_host.getenv("GBA_WATCH")) |w| {
            watch_addr = @as(u32, @truncate(c_host.strtoul(w, null, 16))) & ~@as(u32, 3);
        } else {
            watch_addr = 0;
        }
    }
    if (watch_addr == 0 or (addr & ~@as(u32, 3)) != watch_addr) return;
    const tag: []const u8 = if (in_irq) " [irq]" else "";
    std.debug.print(
        "[watch] frame {d}: write{d} [{X:0>8}] = {X:0>8} in func_{X:0>8} (r14={X:0>8}){s}\n",
        .{
            frame_count,
            size_bytes * 8,
            addr,
            value,
            g_func_ring[(g_func_ring_i -% 1) & 4095],
            r[14],
            tag,
        },
    );
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

// ---- BIOS Context Adapter & Export ----
const BiosCtx = struct {
    pub fn regs(_: *@This()) *[16]u32 {
        return &r;
    }
    pub fn ewram(_: *@This()) *[0x40000]u8 {
        return &ewram_buf;
    }
    pub fn iwram(_: *@This()) *[0x8000]u8 {
        return &iwram_buf;
    }
    pub fn palette(_: *@This()) *[0x400]u8 {
        return &palette_buf;
    }
    pub fn vram(_: *@This()) *[0x18000]u8 {
        return &vram_buf;
    }
    pub fn oam(_: *@This()) *[0x400]u8 {
        return &oam_buf;
    }
    pub fn ioRead16(_: *@This(), off: u32) u16 {
        return rt_file.ioRead16(off);
    }
    pub fn accessCycles(_: *@This(), addr: u32, wide: bool) u32 {
        return rt_file.accessCycles(addr, wide);
    }
    pub fn advanceCycles(_: *@This(), cycles: u32) void {
        rt_file.advanceCycles(cycles);
    }
    pub fn getBusMode(_: *@This()) BusMode {
        return bus_mode;
    }
    pub fn setBusMode(_: *@This(), m: BusMode) void {
        bus_mode = m;
    }
    pub fn setVramBurst(_: *@This(), b: bool) void {
        vram_burst = b;
    }
    pub fn setCpsrRaw(_: *@This(), val: u32) void {
        cpsr = val;
    }
    pub fn triggerSoftReset(_: *@This()) void {
        soft_reset_pending = true;
        g_ret = 0xFFFF_FFFF;
    }
    pub fn softResetPending(_: *@This()) bool {
        return soft_reset_pending;
    }
    pub fn logSwi(_: *@This(), number: u32) void {
        if (!has_posix) return;
        if (!swi_log_init) {
            swi_log_init = true;
            if (c_host.getenv("GBA_SWI_LOG")) |e| {
                const s = std.mem.span(e);
                if (std.mem.indexOfScalar(u8, s, ',')) |comma| {
                    swi_log_from = std.fmt.parseInt(i64, s[0..comma], 10) catch -1;
                    swi_log_to = std.fmt.parseInt(i64, s[comma + 1 ..], 10) catch -1;
                }
            }
        }
        const fc: i64 = @intCast(frame_count);
        if (swi_log_from >= 0 and fc >= swi_log_from and fc <= swi_log_to) {
            std.debug.print("SWI {X:0>2} f={d} v={d} c={d} r0={X:0>8} r1={X:0>8} r2={X:0>8} lr={X:0>8}\n", .{
                number,
                frame_count,
                scanline,
                cycle_counter,
                r[0],
                r[1],
                r[2],
                r[14],
            });
        }
    }
    pub fn warnUnhandledSwi(_: *@This(), number: u32) void {
        if (number == 0x13) {
            std.debug.print("[swi] HuffUnComp not implemented\n", .{});
        } else {
            std.debug.print("[swi] Unhandled SWI 0x{X:0>2} at PC=0x{X:0>8}\n", .{ number, r[15] });
        }
    }
    pub fn busRead8(_: *@This(), addr: u32) u8 {
        return bus_read8(addr);
    }
    pub fn busWrite8(_: *@This(), addr: u32, v: u8) void {
        bus_write8(addr, v);
    }
    pub fn busRead16(_: *@This(), addr: u32) u16 {
        return bus_read16(addr);
    }
    pub fn busWrite16(_: *@This(), addr: u32, v: u16) void {
        bus_write16(addr, v);
    }
    pub fn busRead32(_: *@This(), addr: u32) u32 {
        return bus_read32(addr);
    }
    pub fn busRead32s(_: *@This(), addr: u32) u32 {
        return bus_read32s(addr);
    }
    pub fn busWrite32(_: *@This(), addr: u32, v: u32) void {
        bus_write32(addr, v);
    }
};
var bios_ctx: BiosCtx = .{};

pub export fn gba_swi(number: u32) void {
    bios_mod.swi(&bios_ctx, number);
}

// ---- Interpreter Context Adapter & Export ----
const InterpCtx = struct {
    pub fn regs(_: *@This()) *[16]u32 {
        return &r;
    }
    pub fn getN(_: *@This()) bool {
        return CPU_N;
    }
    pub fn setN(_: *@This(), b: bool) void {
        CPU_N = b;
    }
    pub fn getZ(_: *@This()) bool {
        return CPU_Z;
    }
    pub fn setZ(_: *@This(), b: bool) void {
        CPU_Z = b;
    }
    pub fn getC(_: *@This()) bool {
        return CPU_C;
    }
    pub fn setC(_: *@This(), b: bool) void {
        CPU_C = b;
    }
    pub fn getV(_: *@This()) bool {
        return CPU_V;
    }
    pub fn setV(_: *@This(), b: bool) void {
        CPU_V = b;
    }
    pub fn getCpsr(_: *@This()) u32 {
        return cpu_get_cpsr();
    }
    pub fn setCpsr(_: *@This(), val: u32, mask: u32) void {
        cpu_set_cpsr(val, mask);
    }
    pub fn getSpsr(_: *@This()) u32 {
        return cpu_get_spsr();
    }
    pub fn setSpsr(_: *@This(), val: u32, mask: u32) void {
        cpu_set_spsr(val, mask);
    }
    pub fn getBusMode(_: *@This()) BusMode {
        return bus_mode;
    }
    pub fn setBusMode(_: *@This(), m: BusMode) void {
        bus_mode = m;
    }
    pub fn setRet(_: *@This(), val: u32) void {
        g_ret = val;
    }
    pub fn softResetPending(_: *@This()) bool {
        return soft_reset_pending;
    }
    pub fn traceInterpEnter(_: *@This(), target: u32) void {
        if (!has_posix) return;
        if (trace_interp_left < 0) {
            if (c_host.getenv("GBA_TRACE_INTERP")) |e| {
                trace_interp_left = @intCast(c_host.atol(e));
            } else {
                trace_interp_left = 0;
            }
        }
        if (trace_interp_left > 0) {
            trace_interp_left -= 1;
            std.debug.print("[interp] enter 0x{X:0>8} lr=0x{X:0>8} sp=0x{X:0>8} frame={d}\n", .{
                target,
                r[14],
                r[13],
                frame_count,
            });
        }
    }
    pub fn peekCodeWord(_: *@This(), peek_addr: u32) ?u32 {
        const region = peek_addr >> 24;
        switch (region) {
            0x02 => {
                const off = peek_addr & 0x3FFFF;
                return @as(u32, ewram_buf[off]) |
                    (@as(u32, ewram_buf[(off + 1) & 0x3FFFF]) << 8) |
                    (@as(u32, ewram_buf[(off + 2) & 0x3FFFF]) << 16) |
                    (@as(u32, ewram_buf[(off + 3) & 0x3FFFF]) << 24);
            },
            0x03 => {
                const off = peek_addr & 0x7FFF;
                return @as(u32, iwram_buf[off]) |
                    (@as(u32, iwram_buf[(off + 1) & 0x7FFF]) << 8) |
                    (@as(u32, iwram_buf[(off + 2) & 0x7FFF]) << 16) |
                    (@as(u32, iwram_buf[(off + 3) & 0x7FFF]) << 24);
            },
            0x08...0x0D => {
                if (rom_size == 0) return null;
                const off = (peek_addr - 0x0800_0000) % rom_size;
                return @as(u32, romByte(off)) |
                    (@as(u32, romByte(off + 1)) << 8) |
                    (@as(u32, romByte(off + 2)) << 16) |
                    (@as(u32, romByte(off + 3)) << 24);
            },
            else => return null,
        }
    }
    pub fn accessCycles(_: *@This(), addr: u32, wide: bool) u32 {
        return rt_file.accessCycles(addr, wide);
    }
    pub fn dataCycles(_: *@This(), addr: u32, wide: bool, load: bool) i32 {
        return rt_file.dataCycles(addr, wide, load);
    }
    pub fn charge(_: *@This(), c_delta: i32) void {
        rt_file.charge(c_delta);
    }
    pub fn read32Raw(_: *@This(), addr: u32) u32 {
        return read32_(addr);
    }
    pub fn read16Raw(_: *@This(), addr: u32) u16 {
        return read16_(addr);
    }
    pub fn busWrite32Raw(_: *@This(), addr: u32, val: u32) void {
        busWrite32_(addr, val);
    }
    pub fn busRead8(_: *@This(), addr: u32) u8 {
        return bus_read8(addr);
    }
    pub fn busWrite8(_: *@This(), addr: u32, val: u8) void {
        bus_write8(addr, val);
    }
    pub fn busRead16(_: *@This(), addr: u32) u16 {
        return bus_read16(addr);
    }
    pub fn busWrite16(_: *@This(), addr: u32, val: u16) void {
        bus_write16(addr, val);
    }
    pub fn busRead32(_: *@This(), addr: u32) u32 {
        return bus_read32(addr);
    }
    pub fn busWrite32(_: *@This(), addr: u32, val: u32) void {
        bus_write32(addr, val);
    }
    pub fn swi(_: *@This(), number: u32) void {
        gba_swi(number);
    }
    pub fn cpuBx(_: *@This(), addr: u32) void {
        cbCpuBx(addr);
    }
    pub fn recompLookup(_: *@This(), addr: u32) u32 {
        return cbRecompLookup(addr);
    }
    pub fn warnUnmappedArmBx(_: *@This(), addr: u32, rm: u32, insn_pc: u32) void {
        if (unmapped_bx_warns < 5) {
            unmapped_bx_warns += 1;
            std.debug.print("[interp] ARM BX to unmapped 0x{X:0>8} (rm=r{d}, pc=0x{X:0>8}) - bailing\n", .{
                addr,
                rm,
                insn_pc,
            });
        }
    }
    pub fn warnUnknownArm(_: *@This(), insn: u32, insn_pc: u32) void {
        std.debug.print("[interp] Unknown ARM insn 0x{X:0>8} at 0x{X:0>8}\n", .{ insn, insn_pc });
    }
    pub fn warnUnknownThumb(_: *@This(), insn: u16, insn_pc: u32) void {
        std.debug.print("[interp] Unknown Thumb insn 0x{X:0>4} at 0x{X:0>8}\n", .{ insn, insn_pc });
    }
    pub fn warnStepLimit(_: *@This(), target: u32, steps: usize, pc: u32) void {
        if (interp_limit_warns < 3) {
            interp_limit_warns += 1;
            std.debug.print("[interp] step limit hit at 0x{X:0>8} ({d} steps), pc=0x{X:0>8}\n", .{
                target,
                steps,
                pc,
            });
        }
    }
};
var interp_ctx: InterpCtx = .{};

pub fn run_iwram_function(target: u32) void {
    interp_mod.runFunction(&interp_ctx, target);
}

// ---- Misc Runtime API Functions ----
pub fn cpu_bx_trace(target: u32) void {
    bx_trace_count +%= 1;
    if (target != bx_trace_last and bx_trace_count <= 100) {
        std.debug.print("[bx #{d}] -> 0x{X:0>8}\n", .{ bx_trace_count, target });
    }
    bx_trace_last = target;
}

pub export fn cpu_undefined(insn: u32) void {
    std.debug.print("[runtime] Undefined instruction 0x{X:0>8} at PC=0x{X:0>8}\n", .{ insn, r[15] });
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
        if (!soft_reset_pending) break;
        soft_reset_count +%= 1;
        if (soft_reset_count <= 5) {
            std.debug.print("[runtime] SoftReset #{d}\n", .{soft_reset_count});
        }
    }
}

// ---- Save / Dump / Tracing / Validation ----
fn buildSidecarPath(base_slice: []const u8, ext: []const u8, dst: *[512]u8) usize {
    const max_base = 507;
    const truncated = if (base_slice.len > max_base) base_slice[0..max_base] else base_slice;
    const last_fwd = std.mem.lastIndexOfScalar(u8, truncated, '/');
    const last_back = std.mem.lastIndexOfScalar(u8, truncated, '\\');
    const sep_end: usize = blk: {
        if (last_fwd != null and last_back != null) break :blk @max(last_fwd.?, last_back.?) + 1;
        if (last_fwd) |i| break :blk i + 1;
        if (last_back) |i| break :blk i + 1;
        break :blk 0;
    };
    const stem = if (std.mem.lastIndexOfScalar(u8, truncated, '.')) |dot_idx|
        if (dot_idx > sep_end) truncated[0..dot_idx] else truncated
    else
        truncated;
    const formatted = std.mem.printSentinel(dst, "{s}{s}", .{ stem, ext }, 0) catch return 0;
    return formatted.len;
}

fn resolveSelfExePath(exe_arg0: ?[*:0]const u8, dst: *[512]u8) []const u8 {
    if (has_posix) {
        const n = c_host.readlink("/proc/self/exe", dst, dst.len - 1);
        if (n > 0) {
            const len: usize = @intCast(n);
            dst[len] = 0;
            return dst[0..len];
        }
        if (exe_arg0) |arg0| {
            const span = std.mem.span(arg0);
            const copy_len = @min(span.len, dst.len - 1);
            @memcpy(dst[0..copy_len], span[0..copy_len]);
            dst[copy_len] = 0;
            return dst[0..copy_len];
        }
    }
    return "awre";
}

fn writeAtomicFile(final_path_c: [*:0]const u8, final_slice: []const u8, data: []const u8) bool {
    if (!has_posix) return false;
    var tmp_buf: [520]u8 = undefined;
    const tmp_slice = std.mem.printSentinel(&tmp_buf, "{s}.tmp", .{final_slice}, 0) catch return false;
    const f = c_host.fopen(tmp_slice.ptr, "wb") orelse return false;
    const written = c_host.fwrite(data.ptr, 1, data.len, f);
    const close_rc = c_host.fclose(f);
    if (written != data.len or close_rc != 0) {
        _ = c_host.remove(tmp_slice.ptr);
        return false;
    }
    if (c_host.rename(tmp_slice.ptr, final_path_c) != 0) {
        _ = c_host.remove(tmp_slice.ptr);
        return false;
    }
    return true;
}

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
    const f = c_host.fopen(path, "rb") orelse return;
    defer _ = c_host.fclose(f);
    _ = c_host.fread(&sram_buf, 1, flash_state.backup_size, f);
    std.debug.print("[runtime] Loaded SRAM from {s}\n", .{sram_path_buf[0..sram_path_len]});
}

fn sramSave() void {
    if (!has_posix or !sram_active or sram_path_len == 0 or !flash_state.dirty) return;
    const path_slice = sram_path_buf[0..sram_path_len];
    const path: [*:0]const u8 = @ptrCast(&sram_path_buf);
    if (writeAtomicFile(path, path_slice, sram_buf[0..flash_state.backup_size])) {
        flash_state.dirty = false;
        sram_dirty_frames = 0;
        std.debug.print("[runtime] Saved Flash to {s}\n", .{path_slice});
    }
}

fn eepromLoad() void {
    if (!has_posix or !eeprom_state.present or eeprom_path_len == 0) return;
    const path: [*:0]const u8 = @ptrCast(&eeprom_path_buf);
    const f = c_host.fopen(path, "rb") orelse return;
    defer _ = c_host.fclose(f);
    _ = c_host.fread(&eeprom_state.storage, 1, eeprom_state.storage.len, f);
    std.debug.print("[runtime] Loaded EEPROM from {s}\n", .{eeprom_path_buf[0..eeprom_path_len]});
}

fn eepromSave() void {
    if (!has_posix or !eeprom_state.present or eeprom_path_len == 0 or !eeprom_state.dirty) return;
    const path_slice = eeprom_path_buf[0..eeprom_path_len];
    const path: [*:0]const u8 = @ptrCast(&eeprom_path_buf);
    if (writeAtomicFile(path, path_slice, &eeprom_state.storage)) {
        eeprom_state.dirty = false;
        eeprom_dirty_frames = 0;
        std.debug.print("[runtime] Saved EEPROM to {s}\n", .{path_slice});
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

fn checkHistFrame() void {
    if (!has_posix) return;
    if (!trace_at_init) {
        trace_at_init = true;
        if (c_host.getenv("GBA_FUNC_TRACE_AT")) |e| {
            trace_at_env = std.mem.span(e);
        }
    }
    if (g_hist_on != 0) histDump();
    if (trace_at_env) |at_str| {
        var it = std.mem.tokenizeScalar(u8, at_str, ',');
        while (it.next()) |tok| {
            const target_f = std.fmt.parseInt(u32, std.mem.trim(u8, tok, " \t"), 10) catch continue;
            if (target_f == frame_count) {
                g_hist_on = 1;
                break;
            }
        }
    }
}

fn histLessThan(_: void, a: HistEntry, b: HistEntry) bool {
    return a.first < b.first;
}

fn histDump() void {
    var n: usize = 0;
    for (hist) |entry| {
        if (entry.addr != 0) {
            hist_out[n] = entry;
            n += 1;
        }
    }
    std.mem.sort(HistEntry, hist_out[0..n], {}, histLessThan);
    std.debug.print("[trace] frame {d}: {d} functions, in first-call order (count):", .{
        frame_count -% 1,
        n,
    });
    for (hist_out[0..n], 0..) |entry, k| {
        const sep: []const u8 = if (k % 6 != 0) " " else "\n  ";
        std.debug.print("{s}{X:0>8}({d})", .{ sep, entry.addr, entry.count });
    }
    std.debug.print("\n", .{});
    @memset(&hist, .{});
    hist_n = 0;
    hist_seq = 0;
    g_hist_on = 0;
}

fn funcRingDump() void {
    var n: usize = 0;
    for (0..4096) |i| {
        const a = g_func_ring[(g_func_ring_i +% @as(u32, @intCast(i))) & 4095];
        if (a == 0) continue;
        var k: usize = 0;
        while (k < n and ring_seen[k] != a) : (k += 1) {}
        if (k == n) {
            ring_seen[n] = a;
            ring_count[n] = 0;
            n += 1;
        }
        ring_count[k] += 1;
    }
    std.debug.print("[runtime] frame {d}: last 4096 function entries, distinct (count):", .{frame_count});
    for (0..n) |k| {
        const sep: []const u8 = if (k % 6 != 0) " " else "\n  ";
        std.debug.print("{s}{X:0>8}({d})", .{ sep, ring_seen[k], ring_count[k] });
    }
    std.debug.print("\n", .{});
}

pub export fn recomp_enter(addr: u32) bool {
    g_func_ring[g_func_ring_i & 4095] = addr;
    g_func_ring_i +%= 1;
    if (g_hist_on != 0) recomp_hist(addr);
    if (g_validate != 0 and recomp_validate(addr) != 0) return false;
    return true;
}

pub export fn recomp_called_slow(retaddr: u32) bool {
    if (((g_ret ^ retaddr) & ~@as(u32, 1)) != 0) {
        if (g_unwind_trace != 0) recomp_unwind_note(retaddr);
        return false;
    }
    g_ret = 0;
    return true;
}

pub export fn recomp_unwind_note(retaddr: u32) void {
    std.debug.print(
        "[unwind] frame {d}: call site expecting {X:0>8} saw a return to {X:0>8} (last entered func_{X:0>8})\n",
        .{
            frame_count,
            retaddr,
            g_ret,
            g_func_ring[(g_func_ring_i -% 1) & 4095],
        },
    );
    g_unwind_trace -= 1;
    if (g_unwind_trace == 0) {
        std.debug.print("[unwind] (further unwinds not logged)\n", .{});
    }
}

pub export fn recomp_hist(addr: u32) void {
    var h: usize = (addr >> 1) & 16383;
    while (hist[h].addr != 0 and hist[h].addr != addr) {
        h = (h + 1) & 16383;
    }
    if (hist[h].addr == 0) {
        hist[h].addr = addr;
        hist[h].first = hist_seq;
        hist_seq += 1;
        hist_n += 1;
    }
    hist[h].count += 1;
}

const ValidateHost = struct {
    pub fn recompLookup(_: *@This(), addr: u32) u32 {
        return cbRecompLookup(addr);
    }
    pub fn recompLookupFn(_: *@This(), addr: u32) ?*const fn () callconv(.c) void {
        return cbRecompLookupFn(addr);
    }
    pub fn regs(_: *@This()) *[16]u32 {
        return &r;
    }
    pub fn getBxDepth(_: *@This()) i32 {
        return if (game_cb) |cb| cb.bx_depth.* else 0;
    }
    pub fn setBxDepth(_: *@This(), v: i32) void {
        if (game_cb) |cb| cb.bx_depth.* = v;
    }
    pub fn getRet(_: *@This()) u32 {
        return g_ret;
    }
    pub fn setRet(_: *@This(), v: u32) void {
        g_ret = v;
    }
    pub fn getCycleCounter(_: *@This()) u32 {
        return cycle_counter;
    }
    pub fn stateSave(_: *@This(), s: *MachineState) void {
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
        s.scanline = scanline;
        s.scanline_cycles = scanline_cycles;
        s.hblank_done = if (hblank_done) 1 else 0;
        s.last_poll_cycle = last_poll_cycle;
        s.frame_count = frame_count;
        s.timers = timer_state.ch;
        s.bus_mode = bus_mode;
        s.cycle_credit = cycle_credit;
        s.vram_burst = vram_burst;
    }
    pub fn stateLoad(_: *@This(), s: *const MachineState) void {
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
        scanline = s.scanline;
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
var validate_host: ValidateHost = .{};

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
            std.debug.print("[runtime] Cannot open ROM: {s}\n", .{std.mem.span(rom_path_c)});
            c_host.exit(1);
        };
        _ = c_host.fseek(f, 0, 2); // SEEK_END
        const raw_len = c_host.ftell(f);
        if (raw_len <= 0) {
            _ = c_host.fclose(f);
            std.debug.print("[runtime] Empty or unreadable ROM: {s}\n", .{std.mem.span(rom_path_c)});
            c_host.exit(1);
        }
        rom_size = @intCast(raw_len);
        _ = c_host.fseek(f, 0, 0); // SEEK_SET
        const mem = c_host.malloc(rom_size) orelse {
            _ = c_host.fclose(f);
            std.debug.print("[runtime] Failed to allocate ROM buffer ({d} bytes)\n", .{rom_size});
            c_host.exit(1);
        };
        if (c_host.fread(mem, 1, rom_size, f) != rom_size) {
            _ = c_host.fclose(f);
            std.debug.print("[runtime] Failed to read ROM\n", .{});
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
        default_base = resolveSelfExePath(exe_arg0, &exe_path_buf);
        rom_label = "embedded";
    } else {
        std.debug.print("[runtime] No ROM embedded and no ROM path given. Usage: awre <rom.gba> [options]\n", .{});
        c_host.exit(1);
    }

    if (save_path_opt) |sp| {
        const sp_slice = std.mem.span(sp);
        const formatted = std.mem.printSentinel(&sram_path_buf, "{s}", .{sp_slice}, 0) catch "";
        sram_path_len = formatted.len;
    } else {
        sram_path_len = buildSidecarPath(default_base, ".sav", &sram_path_buf);
    }
    if (flash_state.detect(rom_slice)) |tag| {
        const size_label: []const u8 = if (flash_state.large) "128KB" else "64KB";
        std.debug.print("[runtime] Flash {s} detected ({s})\n", .{ size_label, tag });
        @memset(sram_buf[0..flash_state.backup_size], 0xFF);
    }
    sramLoad();
    flash_state.dirty = false;
    flash_state.write_seq = 0;
    sram_last_seq = 0;

    if (eeprom_state.detect(rom_slice)) |ee_addr| {
        std.debug.print("[runtime] EEPROM detected at ROM 0x{X:0>8} (assuming 8KB)\n", .{ee_addr});
        const ee_base = if (save_path_opt) |sp| std.mem.span(sp) else default_base;
        eeprom_path_len = buildSidecarPath(ee_base, ".eep", &eeprom_path_buf);
        eepromLoad();
        eeprom_state.dirty = false;
        eeprom_state.write_seq = 0;
        eeprom_last_seq = 0;
    }

    initPostRomRegs();

    std.debug.print("[runtime] GBA static recomp runtime initialized (Zig)\n", .{});
    std.debug.print("[runtime] ROM: {d} bytes ({s})\n", .{ rom_size, rom_label });
    if (sram_path_len > 0) {
        std.debug.print("[runtime] Save path: {s}\n", .{sram_path_buf[0..sram_path_len]});
    }

    if (disp.display_init() != 0) {
        std.debug.print("[runtime] Failed to initialize display\n", .{});
        c_host.exit(1);
    }
}

pub fn gba_shutdown() void {
    if (has_posix) {
        if (c_host.getenv("GBA_FUNC_TRACE") != null) funcRingDump();
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
    std.debug.print("[runtime] Shutdown\n", .{});
}
