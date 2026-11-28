const std = @import("std");
const builtin = @import("builtin");
const core = @import("awre_core");
const disp = @import("platform/display.zig");
const adapters = @import("runtime/adapters.zig");
const bus = @import("runtime/bus.zig");
const diagnostics = @import("runtime/diagnostics.zig");
const save_io = @import("runtime/save_io.zig");
const state = @import("runtime/state.zig");
const timing = @import("runtime/timing.zig");
const validate_mod = @import("validate/validate.zig");
const rt_options = @import("rt_options");

const embedded_rom_bytes: []const u8 = if (rt_options.has_embedded_rom) @embedFile("embedded_rom") else &.{};

pub fn hasEmbeddedRom() bool {
    return embedded_rom_bytes.len > 0;
}

const bios_mod = core.bios;
const interp_mod = core.interp;
const BusMode = state.BusMode;

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

// ---- ROM Storage & Scheduler Constants ----
pub fn romSlice() ?[]const u8 {
    return state.romSlice();
}

const wasm_rom_max: usize = 16 * 1024 * 1024;
var wasm_rom_buf: if (!has_posix) [wasm_rom_max]u8 else [0]u8 = @splat(0);

const save_debounce_frames = save_io.save_debounce_frames;
const cycles_per_scanline = timing.cycles_per_scanline;
const visible_scanlines = timing.visible_scanlines;
const scanlines_per_frame = timing.scanlines_per_frame;
const cycles_per_frame = timing.cycles_per_frame;
const hblank_start_cycle = timing.hblank_start_cycle;
const poll_interval = timing.poll_interval;

// ---- Fetch Timing State ----
var fetch_x16: u32 = 0;
var fetch_frac: u32 = 0;

// ---- Timing & Waitstates ----
inline fn accessCycles(addr: u32, wide: bool) u32 {
    return timing.accessCycles(addr, wide, state.ioRead16(0x204));
}

inline fn dataCycles(addr: u32, wide: bool, load: bool) i32 {
    return timing.dataCycles(addr, wide, load, state.bus_mode, &state.io_regs_buf, state.scanline, state.scanline_cycles, state.vram_burst);
}

fn charge(c_delta: i32) void {
    const c = c_delta + state.cycle_credit;
    state.cycle_credit = if (c < 0) c else 0;
    if (c > 0) advanceCycles(@intCast(c));
}

const rt_file = @This();

// ---- DMA Bus Interface ----
var dma_bus: bus.DmaBus(AdapterRt) = .{};

// ---- Interrupt Delivery ----
fn checkInterrupts() void {
    if (state.soft_reset_pending or validate_mod.g_validating or (state.in_irq and (state.cpsr & 0x80) != 0)) return;

    const ime = state.ioRead16(0x208);
    if (ime == 0) return;

    const ie = state.ioRead16(0x200);
    const if_val = state.ioRead16(0x202);
    const pending = ie & if_val;
    if (pending == 0) return;

    const handler_addr = @as(u32, state.iwram_buf[0x7FFC]) |
        (@as(u32, state.iwram_buf[0x7FFD]) << 8) |
        (@as(u32, state.iwram_buf[0x7FFE]) << 16) |
        (@as(u32, state.iwram_buf[0x7FFF]) << 24);
    if (handler_addr == 0) return;

    const was_in_irq = state.in_irq;
    const saved_cpsr = state.cpsr;
    const saved_spsr = state.spsr;
    state.spsr = cpu_get_cpsr();
    state.cpsr = (state.cpsr & ~@as(u32, 0xFF)) | 0x92;
    state.in_irq = true;

    const bios_if = (@as(u16, state.iwram_buf[0x7FF8]) | (@as(u16, state.iwram_buf[0x7FF9]) << 8)) | pending;
    state.iwram_buf[0x7FF8] = @truncate(bios_if);
    state.iwram_buf[0x7FF9] = @truncate(bios_if >> 8);

    const saved_r = r;
    const saved_N = CPU_N;
    const saved_Z = CPU_Z;
    const saved_C = CPU_C;
    const saved_V = CPU_V;
    const saved_ret = g_ret;
    g_ret = 0;
    const saved_mode = state.bus_mode;
    state.bus_mode = .rom_code;

    cbCpuBx(handler_addr);

    state.bus_mode = saved_mode;
    state.in_irq = was_in_irq;
    if (state.soft_reset_pending) return;

    g_ret = saved_ret;
    r = saved_r;
    CPU_N = saved_N;
    CPU_Z = saved_Z;
    CPU_C = saved_C;
    CPU_V = saved_V;
    state.cpsr = saved_cpsr;
    state.spsr = saved_spsr;
}

// ---- Scanline Scheduler ----
fn advanceCycles(cycles: u32) void {
    if (state.soft_reset_pending) return;

    var remaining: u32 = cycles;
    while (remaining > 0) {
        // Slice cycles at HBlank/scanline boundaries so scanline_cycles never overshoots
        // past a boundary before a re-entrant IRQ handler runs at that boundary.
        const next_boundary: u32 = if (!state.hblank_done) hblank_start_cycle else cycles_per_scanline;
        const to_boundary: u32 = if (state.scanline_cycles < next_boundary) next_boundary - state.scanline_cycles else 0;
        const step: u32 = @min(remaining, to_boundary);
        if (step > 0) {
            state.cycle_counter +%= step;
            state.scanline_cycles +%= step;
            remaining -= step;
            validate_mod.checkDeadline(state.cycle_counter);
            const timer_irqs = state.timer_state.tick(step);
            if (timer_irqs != 0) state.raiseIrqBits(timer_irqs);
        }

        if (!state.hblank_done and state.scanline_cycles >= hblank_start_cycle) {
            state.hblank_done = true;
            if (state.scanline < visible_scanlines and !validate_mod.g_validating) {
                disp.display_render_line(@intCast(state.scanline));
            }
            state.ioWrite16(0x004, state.ioRead16(0x004) | 2);
            if ((state.ioRead16(0x004) & 0x10) != 0) {
                state.ioWrite16(0x202, state.ioRead16(0x202) | 2);
            }
            if (state.scanline < visible_scanlines) {
                state.dma_state.triggerHBlank(&dma_bus);
            }
            checkInterrupts();
            if (state.soft_reset_pending) return;
            continue;
        }
        if (state.scanline_cycles >= cycles_per_scanline) {
            state.scanline_cycles -= cycles_per_scanline;
            state.hblank_done = false;

            const prev_scanline = state.scanline;
            state.scanline = (state.scanline + 1) % scanlines_per_frame;

            state.io_regs_buf[0x006] = @truncate(state.scanline & 0xFF);
            state.io_regs_buf[0x007] = 0;

            var dispstat = state.ioRead16(0x004);
            const vcount_target = (dispstat >> 8) & 0xFF;
            dispstat &= ~@as(u16, 0x0007);
            if (state.scanline >= visible_scanlines) dispstat |= 1;
            if (state.scanline == vcount_target) dispstat |= 4;
            state.ioWrite16(0x004, dispstat);

            if (state.scanline == visible_scanlines and prev_scanline != visible_scanlines) {
                state.ioWrite16(0x202, state.ioRead16(0x202) | 1);
                state.dma_state.triggerVBlank(&dma_bus);

                state.frame_count +%= 1;

                const keys = disp.display_get_keys();
                state.io_regs_buf[0x130] = @truncate(keys);
                state.io_regs_buf[0x131] = @truncate(keys >> 8);

                if (!validate_mod.g_validating) {
                    disp.display_render_frame();
                }
                disp.display_pace();

                diagnostics.checkHistFrame(state.frame_count, &g_hist_on);
                writeDumpAtSnapshot();
                if (!validate_mod.g_validating) pollBackupFlush();

                const log_every = disp.display_log_every();
                if (state.frame_count <= 5 or (log_every != 0 and @mod(state.frame_count, @as(u32, @intCast(log_every))) == 0)) {
                    const dispcnt = state.ioRead16(0x000);
                    const pal0 = @as(u16, state.palette_buf[0]) | (@as(u16, state.palette_buf[1]) << 8);
                    const pal1 = @as(u16, state.palette_buf[2]) | (@as(u16, state.palette_buf[3]) << 8);
                    core.gba.logPrint(
                        "[frame {d}] DISPCNT=0x{X:0>4} mode={d} BG={d}{d}{d}{d} OBJ={d} BLDCNT=0x{X:0>4} BLDY={d} pal0=0x{X:0>4} pal1=0x{X:0>4}\n",
                        .{
                            state.frame_count,
                            dispcnt,
                            dispcnt & 7,
                            (dispcnt >> 8) & 1,
                            (dispcnt >> 9) & 1,
                            (dispcnt >> 10) & 1,
                            (dispcnt >> 11) & 1,
                            (dispcnt >> 12) & 1,
                            state.ioRead16(0x050),
                            state.ioRead16(0x054) & 31,
                            pal0,
                            pal1,
                        },
                    );
                }
            }

            if (state.scanline == vcount_target and (dispstat & 0x20) != 0) {
                state.ioWrite16(0x202, state.ioRead16(0x202) | 4);
            }

            checkInterrupts();
            if (state.soft_reset_pending) return;
            continue;
        }
        if (step == 0) break;
    }

    if (state.cycle_counter -% state.last_poll_cycle > poll_interval) {
        state.last_poll_cycle = state.cycle_counter;
        if (disp.display_poll_events() != 0) {
            if (!state.wasm_stop_requested) gba_shutdown();
            if (has_posix) {
                c_host.exit(0);
            } else {
                state.wasm_stop_requested = true;
                state.soft_reset_pending = true;
                g_ret = 0xFFFF_FFFF;
                return;
            }
        }
    }
}

// ---- Bus & CPU Timing API ----
pub export fn bus_read32(addr: u32) u32 {
    charge(dataCycles(addr, true, true));
    return bus.read32Raw(addr);
}

pub export fn bus_read32s(addr: u32) u32 {
    charge(dataCycles(addr, true, false));
    return bus.read32Raw(addr);
}

pub export fn bus_read16(addr: u32) u16 {
    charge(dataCycles(addr, false, true));
    return bus.read16Raw(addr);
}

pub export fn bus_read8(addr: u32) u8 {
    charge(dataCycles(addr, false, true));
    return bus.read8Raw(addr);
}

pub export fn bus_write32(addr: u32, value: u32) void {
    bus.write32Raw(addr, value, &dma_bus, &g_func_ring, g_func_ring_i, r[14]);
    charge(dataCycles(addr, true, false));
}

pub export fn bus_write16(addr: u32, value: u16) void {
    bus.write16Raw(addr, value, &dma_bus, &g_func_ring, g_func_ring_i, r[14]);
    charge(dataCycles(addr, false, false));
}

pub export fn bus_write8(addr: u32, value: u8) void {
    bus.write8Raw(addr, value, &dma_bus, &g_func_ring, g_func_ring_i, r[14]);
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
    const w = state.ioRead16(0x204);
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
    return flags | (state.cpsr & 0x0FFF_FFFF);
}

pub export fn cpu_set_cpsr(value: u32, mask: u32) void {
    if ((mask & 8) != 0) {
        CPU_N = ((value >> 31) & 1) != 0;
        CPU_Z = ((value >> 30) & 1) != 0;
        CPU_C = ((value >> 29) & 1) != 0;
        CPU_V = ((value >> 28) & 1) != 0;
    }
    if ((mask & 1) != 0) {
        state.cpsr = (state.cpsr & ~@as(u32, 0xFF)) | (value & 0xFF);
    }
}

pub export fn cpu_get_spsr() u32 {
    return state.spsr;
}

pub export fn cpu_set_spsr(value: u32, mask: u32) void {
    if ((mask & 8) != 0) state.spsr = (state.spsr & 0x0FFF_FFFF) | (value & 0xF000_0000);
    if ((mask & 1) != 0) state.spsr = (state.spsr & ~@as(u32, 0xFF)) | (value & 0xFF);
}

// ---- Runtime Context Adapters & Exports ----
const AdapterRt = struct {
    pub fn regs() *[16]u32 {
        return &r;
    }
    pub fn ewram() *[0x40000]u8 {
        return &state.ewram_buf;
    }
    pub fn iwram() *[0x8000]u8 {
        return &state.iwram_buf;
    }
    pub fn palette() *[0x400]u8 {
        return &state.palette_buf;
    }
    pub fn vram() *[0x18000]u8 {
        return &state.vram_buf;
    }
    pub fn oam() *[0x400]u8 {
        return &state.oam_buf;
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
        state.cpsr = val;
    }
    pub fn getSpsr() u32 {
        return cpu_get_spsr();
    }
    pub fn setSpsr(val: u32, mask: u32) void {
        cpu_set_spsr(val, mask);
    }
    pub fn getBusMode() BusMode {
        return state.bus_mode;
    }
    pub fn setBusMode(m: BusMode) void {
        state.bus_mode = m;
    }
    pub fn setVramBurst(b: bool) void {
        state.vram_burst = b;
    }
    pub fn triggerSoftReset() void {
        state.soft_reset_pending = true;
        g_ret = 0xFFFF_FFFF;
    }
    pub fn softResetPending() bool {
        return state.soft_reset_pending;
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
        return state.frame_count;
    }
    pub fn scanline() u32 {
        return state.scanline;
    }
    pub fn cycleCounter() u32 {
        return state.cycle_counter;
    }
    pub fn romSize() u32 {
        return state.rom_size;
    }
    pub fn romByte(off: u32) u8 {
        return state.romByte(off);
    }
    pub fn ioRead16(off: u32) u16 {
        return state.ioRead16(off);
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
        return bus.read32Raw(addr);
    }
    pub fn read16Raw(addr: u32) u16 {
        return bus.read16Raw(addr);
    }
    pub fn busWrite32Raw(addr: u32, val: u32) void {
        bus.write32Raw(addr, val, &dma_bus, &g_func_ring, g_func_ring_i, r[14]);
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
        state.saveMachineState(s, r, CPU_N, CPU_Z, CPU_C, CPU_V);
    }
    pub fn stateLoad(s: *const validate_mod.MachineState) void {
        state.loadMachineState(s, &r, &CPU_N, &CPU_Z, &CPU_C, &CPU_V);
    }
};

var bios_ctx: adapters.BiosCtx(AdapterRt) = .{};

pub export fn gba_swi(number: u32) void {
    if (state.soft_reset_pending) {
        g_ret = 0xFFFF_FFFF;
        return;
    }
    bios_mod.swi(&bios_ctx, number);
}

var interp_ctx: adapters.InterpCtx(AdapterRt) = .{};

pub fn run_iwram_function(target: u32) void {
    if (state.soft_reset_pending) {
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
    return state.scanline >= visible_scanlines;
}

pub fn ppu_in_hblank() bool {
    return state.scanline_cycles >= hblank_start_cycle;
}

pub fn apu_step(_: u32) void {}

pub fn dma_check() void {}

pub fn timer_step(cycles: u32) void {
    const timer_irqs = state.timer_state.tick(cycles);
    if (timer_irqs != 0) state.raiseIrqBits(timer_irqs);
}

pub fn irq_check() void {
    checkInterrupts();
}

pub fn gba_frame() void {
    const target_cycle = ((state.cycle_counter / cycles_per_frame) + 1) * cycles_per_frame +
        visible_scanlines * cycles_per_scanline;
    while (state.cycle_counter < target_cycle) {
        advanceCycles(cycles_per_scanline);
        if (state.soft_reset_pending) return;
    }
}

pub fn gba_run(entry_func: *const fn () void) void {
    while (true) {
        state.soft_reset_pending = false;
        state.in_irq = false;
        g_ret = 0;
        entry_func();
        if (state.wasm_stop_requested or !state.soft_reset_pending) break;
        state.soft_reset_count +%= 1;
        if (state.soft_reset_count <= 5) {
            core.gba.logPrint("[runtime] SoftReset #{d}\n", .{state.soft_reset_count});
        }
    }
}

// ---- Save / Dump / Tracing / Validation ----
fn pollBackupFlush() void {
    if (state.flash_state.dirty) {
        if (state.flash_state.write_seq != state.sram_last_seq) {
            state.sram_last_seq = state.flash_state.write_seq;
            state.sram_dirty_frames = save_debounce_frames;
        } else if (state.sram_dirty_frames > 0) {
            state.sram_dirty_frames -= 1;
            if (state.sram_dirty_frames == 0) sramSave();
        }
    }
    if (state.eeprom_state.dirty) {
        if (state.eeprom_state.write_seq != state.eeprom_last_seq) {
            state.eeprom_last_seq = state.eeprom_state.write_seq;
            state.eeprom_dirty_frames = save_debounce_frames;
        } else if (state.eeprom_dirty_frames > 0) {
            state.eeprom_dirty_frames -= 1;
            if (state.eeprom_dirty_frames == 0) eepromSave();
        }
    }
}

fn sramLoad() void {
    if (!has_posix or !state.sram_active or state.sram_path_len == 0) return;
    const path: [*:0]const u8 = @ptrCast(&state.sram_path_buf);
    if (!save_io.readFileInto(path, state.sram_buf[0..state.flash_state.backup_size])) return;
    core.gba.logPrint("[runtime] Loaded SRAM from {s}\n", .{state.sram_path_buf[0..state.sram_path_len]});
}

fn sramSave() void {
    if (!state.sram_active or !state.flash_state.dirty) return;
    if (!has_posix) {
        core.platform.WasmBackend.saveSram(&state.sram_buf, state.flash_state.backup_size);
        state.flash_state.dirty = false;
        state.sram_dirty_frames = 0;
        return;
    }
    if (state.sram_path_len == 0) return;
    const path_slice = state.sram_path_buf[0..state.sram_path_len];
    const path: [*:0]const u8 = @ptrCast(&state.sram_path_buf);
    if (save_io.writeAtomicFile(path, path_slice, state.sram_buf[0..state.flash_state.backup_size])) {
        state.flash_state.dirty = false;
        state.sram_dirty_frames = 0;
        core.gba.logPrint("[runtime] Saved Flash to {s}\n", .{path_slice});
    }
}

fn eepromLoad() void {
    if (!has_posix or !state.eeprom_state.present or state.eeprom_path_len == 0) return;
    const path: [*:0]const u8 = @ptrCast(&state.eeprom_path_buf);
    if (!save_io.readFileInto(path, &state.eeprom_state.storage)) return;
    core.gba.logPrint("[runtime] Loaded EEPROM from {s}\n", .{state.eeprom_path_buf[0..state.eeprom_path_len]});
}

fn eepromSave() void {
    if (!has_posix or !state.eeprom_state.present or state.eeprom_path_len == 0 or !state.eeprom_state.dirty) return;
    const path_slice = state.eeprom_path_buf[0..state.eeprom_path_len];
    const path: [*:0]const u8 = @ptrCast(&state.eeprom_path_buf);
    if (save_io.writeAtomicFile(path, path_slice, &state.eeprom_state.storage)) {
        state.eeprom_state.dirty = false;
        state.eeprom_dirty_frames = 0;
        core.gba.logPrint("[runtime] Saved EEPROM to {s}\n", .{path_slice});
    }
}

fn writeDumpAtSnapshot() void {
    if (!has_posix) return;
    const dp = disp.display_dump_path(@intCast(state.frame_count)) orelse return;
    const df = c_host.fopen(dp, "wb") orelse return;
    defer _ = c_host.fclose(df);
    _ = c_host.fwrite(&state.ewram_buf, 1, state.ewram_buf.len, df);
    _ = c_host.fwrite(&state.iwram_buf, 1, state.iwram_buf.len, df);
    _ = c_host.fwrite(&state.io_regs_buf, 1, state.io_regs_buf.len, df);
    _ = c_host.fwrite(&state.palette_buf, 1, state.palette_buf.len, df);
    _ = c_host.fwrite(&state.vram_buf, 1, state.vram_buf.len, df);
    _ = c_host.fwrite(&state.oam_buf, 1, state.oam_buf.len, df);
}

pub export fn recomp_enter(addr: u32) bool {
    g_func_ring[g_func_ring_i & 4095] = addr;
    g_func_ring_i +%= 1;
    if (g_hist_on != 0) recomp_hist(addr);
    if (g_validate != 0 and recomp_validate(addr) != 0) return false;
    return true;
}

pub export fn recomp_called_slow(retaddr: u32) bool {
    if (state.soft_reset_pending) {
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
    diagnostics.noteUnwind(state.frame_count, retaddr, g_ret, &g_func_ring, g_func_ring_i, &g_unwind_trace);
}

pub export fn recomp_hist(addr: u32) void {
    diagnostics.recordHist(addr);
}

var validate_host: adapters.ValidateHost(AdapterRt) = .{};

pub export fn recomp_validate(addr: u32) c_int {
    return validate_mod.runValidate(
        addr,
        g_validate,
        state.in_irq,
        state.frame_count,
        &validate_host,
        run_iwram_function,
    );
}

// ---- Lifecycle ----
fn resetCommonState() void {
    state.resetCommon();

    ewram = &state.ewram_buf;
    iwram = &state.iwram_buf;
    io_regs = &state.io_regs_buf;
    palette = &state.palette_buf;
    vram = &state.vram_buf;
    oam = &state.oam_buf;

    g_ret = 0;
    g_func_ring_i = 0;
    @memset(&g_func_ring, 0);
}

pub fn wasmRomBufPtr() [*]u8 {
    return if (!has_posix) &wasm_rom_buf else state.sram_buf[0..1].ptr;
}

pub fn wasmRomBufCap() u32 {
    return wasm_rom_max;
}

pub fn wasmSramBufPtr() [*]u8 {
    return &state.sram_buf;
}

pub fn wasmSramSize() u32 {
    return state.flash_state.backup_size;
}

pub fn wasmMarkSramClean() void {
    state.flash_state.dirty = false;
    state.flash_state.write_seq = 0;
    state.sram_last_seq = 0;
    state.sram_dirty_frames = 0;
}

pub fn gba_init_memory(rom_len: u32) bool {
    if (rom_len > wasm_rom_max) return false;
    resetCommonState();

    const rom_slice: []const u8 = if (rom_len > 0)
        (if (!has_posix) wasm_rom_buf[0..rom_len] else &.{})
    else
        embedded_rom_bytes;
    if (rom_slice.len == 0) return false;

    state.rom_ptr = rom_slice.ptr;
    state.rom_size = @intCast(rom_slice.len);
    state.rom_owned = false;

    if (state.flash_state.detect(rom_slice) != null) {
        @memset(state.sram_buf[0..state.flash_state.backup_size], 0xFF);
    }
    state.flash_state.dirty = false;
    state.flash_state.write_seq = 0;
    state.sram_last_seq = 0;

    _ = state.eeprom_state.detect(rom_slice);
    state.eeprom_state.dirty = false;
    state.eeprom_state.write_seq = 0;
    state.eeprom_last_seq = 0;

    initPostRomRegs();
    return disp.display_init() == 0;
}

fn initPostRomRegs() void {
    @memset(&r, 0);
    r[13] = 0x0300_7F00;
    r[15] = 0x0800_0000;
    state.cpsr = 0x0000_001F;
    state.spsr = 0;

    // KEYINPUT active-low all released, default SOUNDBIAS = 0x0200, SIOMULTI pull-ups 0xFFFF
    state.io_regs_buf[0x130] = 0xFF;
    state.io_regs_buf[0x131] = 0x03;
    state.io_regs_buf[0x088] = 0x00;
    state.io_regs_buf[0x089] = 0x02;
    @memset(state.io_regs_buf[0x120..0x128], 0xFF);
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
        state.rom_size = @intCast(raw_len);
        _ = c_host.fseek(f, 0, 0); // SEEK_SET
        const mem = c_host.malloc(state.rom_size) orelse {
            _ = c_host.fclose(f);
            core.gba.logPrint("[runtime] Failed to allocate ROM buffer ({d} bytes)\n", .{state.rom_size});
            c_host.exit(1);
        };
        if (c_host.fread(mem, 1, state.rom_size, f) != state.rom_size) {
            _ = c_host.fclose(f);
            core.gba.logPrint("[runtime] Failed to read ROM\n", .{});
            c_host.exit(1);
        }
        _ = c_host.fclose(f);
        state.rom_ptr = mem;
        state.rom_owned = true;
        rom_slice = mem[0..state.rom_size];
        default_base = std.mem.span(rom_path_c);
        rom_label = default_base;
    } else if (embedded_rom_bytes.len > 0) {
        state.rom_ptr = embedded_rom_bytes.ptr;
        state.rom_size = @intCast(embedded_rom_bytes.len);
        state.rom_owned = false;
        rom_slice = embedded_rom_bytes;
        default_base = save_io.resolveSelfExePath(exe_arg0, &state.exe_path_buf);
        rom_label = "embedded";
    } else {
        core.gba.logPrint("[runtime] No ROM embedded and no ROM path given. Usage: awre <rom.gba> [options]\n", .{});
        c_host.exit(1);
    }

    if (save_path_opt) |sp| {
        const sp_slice = std.mem.span(sp);
        const formatted = std.mem.printSentinel(&state.sram_path_buf, "{s}", .{sp_slice}, 0) catch "";
        state.sram_path_len = formatted.len;
    } else {
        state.sram_path_len = save_io.buildSidecarPath(default_base, ".sav", &state.sram_path_buf);
    }
    if (state.flash_state.detect(rom_slice)) |tag| {
        const size_label: []const u8 = if (state.flash_state.large) "128KB" else "64KB";
        core.gba.logPrint("[runtime] Flash {s} detected ({s})\n", .{ size_label, tag });
        @memset(state.sram_buf[0..state.flash_state.backup_size], 0xFF);
    }
    sramLoad();
    state.flash_state.dirty = false;
    state.flash_state.write_seq = 0;
    state.sram_last_seq = 0;

    if (state.eeprom_state.detect(rom_slice)) |ee_addr| {
        core.gba.logPrint("[runtime] EEPROM detected at ROM 0x{X:0>8} (assuming 8KB)\n", .{ee_addr});
        const ee_base = if (save_path_opt) |sp| std.mem.span(sp) else default_base;
        state.eeprom_path_len = save_io.buildSidecarPath(ee_base, ".eep", &state.eeprom_path_buf);
        eepromLoad();
        state.eeprom_state.dirty = false;
        state.eeprom_state.write_seq = 0;
        state.eeprom_last_seq = 0;
    }

    initPostRomRegs();

    core.gba.logPrint("[runtime] GBA static recomp runtime initialized\n", .{});
    core.gba.logPrint("[runtime] ROM: {d} bytes ({s})\n", .{ state.rom_size, rom_label });
    if (state.sram_path_len > 0) {
        core.gba.logPrint("[runtime] Save path: {s}\n", .{state.sram_path_buf[0..state.sram_path_len]});
    }

    if (disp.display_init() != 0) {
        core.gba.logPrint("[runtime] Failed to initialize display\n", .{});
        c_host.exit(1);
    }
}

pub fn gba_shutdown() void {
    if (has_posix) {
        if (c_host.getenv("GBA_FUNC_TRACE") != null) diagnostics.funcRingDump(state.frame_count, &g_func_ring, g_func_ring_i);
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
    state.sram_active = false;
    state.bios_mem_ptr = null;

    if (has_posix) {
        if (state.rom_owned) {
            if (state.rom_ptr) |ptr| {
                c_host.free(@constCast(ptr));
            }
        }
        state.rom_ptr = null;
        state.rom_owned = false;
    }
    state.rom_size = 0;
    core.gba.logPrint("[runtime] Shutdown\n", .{});
}

test {
    _ = state;
    _ = bus;
    _ = timing;
    _ = save_io;
    _ = diagnostics;
    _ = adapters;
}
