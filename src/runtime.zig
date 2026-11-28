//! Slim C-ABI runtime export facade over modular `src/runtime/` subsystems.

const std = @import("std");
const builtin = @import("builtin");
const core = @import("awre_core");
const disp = @import("platform/display.zig");
const adapters = @import("runtime/adapters.zig");
const bus = @import("runtime/bus.zig");
const diagnostics = @import("runtime/diagnostics.zig");
const lifecycle = @import("runtime/lifecycle.zig");
const scheduler = @import("runtime/scheduler.zig");
const state = @import("runtime/state.zig");
const timing = @import("runtime/timing.zig");
const validate_mod = @import("validate/validate.zig");

const bios_mod = core.bios;
const interp_mod = core.interp;

const has_posix = builtin.os.tag != .freestanding;

const c_host = if (has_posix) struct {
    extern "c" fn getenv(name: [*:0]const u8) ?[*:0]const u8;
    extern "c" fn atoi(nptr: [*:0]const u8) c_int;
} else struct {};

pub const GameCallbacks = state.GameCallbacks;

pub fn registerGameCallbacks(cb: GameCallbacks) void {
    state.registerGameCallbacks(cb);
}

// ---- CPU & Memory Globals (exported to independent shards & platform/display) ----
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

pub fn dispParseArgs(args: []const [*:0]const u8) ?[*:0]const u8 {
    return disp.parseArgsSlice(args);
}

pub fn dispSavePath() ?[*:0]const u8 {
    return disp.savePath();
}

pub fn romSlice() ?[]const u8 {
    return state.romSlice();
}

pub fn linkShardExports() void {
    const syms = .{
        &r,                     &CPU_N,                   &CPU_Z,                        &CPU_C,                   &CPU_V,
        &state.g_func_ring,     &state.g_func_ring_i,     &state.g_validate,             &state.g_ret,             &state.g_unwind_trace,
        &state.g_hist_on,       &bus_read32,              &bus_read32s,                  &bus_read16,              &bus_read8,
        &bus_write32,           &bus_write16,             &bus_write8,                   &cpu_fetches,             &gba_swi,
        &cpu_get_cpsr,          &cpu_set_cpsr,            &cpu_get_spsr,                 &cpu_set_spsr,            &cpu_undefined,
        &recomp_enter,          &recomp_called_slow,      &recomp_unwind_note,           &recomp_hist,             &recomp_validate,
        &awre_run_iwram_function,
    };
    inline for (syms) |s| {
        std.mem.doNotOptimizeAway(s);
    }
}

// ---- Fetch Timing & DMA Bus ----
var fetch_x16: u32 = 0;
var fetch_frac: u32 = 0;
var dma_bus: bus.DmaBus(AdapterRt) = .{};

inline fn dataCycles(addr: u32, wide: bool, load: bool) i32 {
    return timing.dataCycles(addr, wide, load, state.bus_mode, &state.io_regs_buf, state.scanline, state.scanline_cycles, state.vram_burst);
}

inline fn charge(c_delta: i32) void {
    scheduler.charge(AdapterRt, c_delta);
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
    bus.write32Raw(addr, value, &dma_bus, &state.g_func_ring, state.g_func_ring_i, r[14]);
    charge(dataCycles(addr, true, false));
}

pub export fn bus_write16(addr: u32, value: u16) void {
    bus.write16Raw(addr, value, &dma_bus, &state.g_func_ring, state.g_func_ring_i, r[14]);
    charge(dataCycles(addr, false, false));
}

pub export fn bus_write8(addr: u32, value: u8) void {
    bus.write8Raw(addr, value, &dma_bus, &state.g_func_ring, state.g_func_ring_i, r[14]);
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

// ---- Runtime Context Glue & Exports ----
const AdapterRt = struct {
    pub fn regs() *[16]u32 {
        return &r;
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
    pub fn getSpsr() u32 {
        return cpu_get_spsr();
    }
    pub fn setSpsr(val: u32, mask: u32) void {
        cpu_set_spsr(val, mask);
    }
    pub fn advanceCycles(cycles: u32) void {
        scheduler.advanceCycles(AdapterRt, cycles);
    }
    pub fn charge(c_delta: i32) void {
        scheduler.charge(AdapterRt, c_delta);
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
    pub fn dmaBus() *bus.DmaBus(AdapterRt) {
        return &dma_bus;
    }
    pub fn shutdown() void {
        gba_shutdown();
    }
    pub fn bindMemoryPtrs() void {
        ewram = &state.ewram_buf;
        iwram = &state.iwram_buf;
        io_regs = &state.io_regs_buf;
        palette = &state.palette_buf;
        vram = &state.vram_buf;
        oam = &state.oam_buf;
    }
    pub fn clearMemoryPtrs() void {
        ewram = null;
        iwram = null;
        io_regs = null;
        palette = null;
        vram = null;
        oam = null;
    }
    pub fn stateSave(s: *validate_mod.MachineState) void {
        state.saveMachineState(s, r, CPU_N, CPU_Z, CPU_C, CPU_V);
    }
    pub fn stateLoad(s: *const validate_mod.MachineState) void {
        state.loadMachineState(s, &r, &CPU_N, &CPU_Z, &CPU_C, &CPU_V);
    }
};

var bios_ctx: adapters.BiosCtx(AdapterRt) = .{};
var interp_ctx: adapters.InterpCtx(AdapterRt) = .{};
var validate_host: adapters.ValidateHost(AdapterRt) = .{};

pub export fn gba_swi(number: u32) void {
    if (state.soft_reset_pending) {
        state.g_ret = 0xFFFF_FFFF;
        return;
    }
    bios_mod.swi(&bios_ctx, number);
}

pub fn run_iwram_function(target: u32) void {
    if (state.soft_reset_pending) {
        state.g_ret = 0xFFFF_FFFF;
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
    return state.scanline >= timing.visible_scanlines;
}

pub fn ppu_in_hblank() bool {
    return state.scanline_cycles >= timing.hblank_start_cycle;
}

pub fn apu_step(_: u32) void {}

pub fn dma_check() void {}

pub fn timer_step(cycles: u32) void {
    const timer_irqs = state.timer_state.tick(cycles);
    if (timer_irqs != 0) state.raiseIrqBits(timer_irqs);
}

pub fn irq_check() void {
    scheduler.checkInterrupts(AdapterRt);
}

pub fn gba_frame() void {
    scheduler.stepFrame(AdapterRt);
}

pub fn gba_run(entry_func: *const fn () void) void {
    scheduler.runLoop(entry_func);
}

// ---- Validation Hooks ----
pub export fn recomp_enter(addr: u32) bool {
    state.g_func_ring[state.g_func_ring_i & 4095] = addr;
    state.g_func_ring_i +%= 1;
    if (state.g_hist_on != 0) recomp_hist(addr);
    if (state.g_validate != 0 and recomp_validate(addr) != 0) return false;
    return true;
}

pub export fn recomp_called_slow(retaddr: u32) bool {
    if (state.soft_reset_pending) {
        state.g_ret = 0xFFFF_FFFF;
        return false;
    }
    if (((state.g_ret ^ retaddr) & ~@as(u32, 1)) != 0) {
        if (state.g_unwind_trace != 0) recomp_unwind_note(retaddr);
        return false;
    }
    state.g_ret = 0;
    return true;
}

pub export fn recomp_unwind_note(retaddr: u32) void {
    diagnostics.noteUnwind(
        state.frame_count,
        retaddr,
        state.g_ret,
        &state.g_func_ring,
        state.g_func_ring_i,
        &state.g_unwind_trace,
    );
}

pub export fn recomp_hist(addr: u32) void {
    diagnostics.recordHist(addr);
}

pub export fn recomp_validate(addr: u32) c_int {
    return validate_mod.runValidate(
        addr,
        state.g_validate,
        state.in_irq,
        state.frame_count,
        &validate_host,
        run_iwram_function,
    );
}

// ---- Lifecycle & WASM Buffers ----
pub fn hasEmbeddedRom() bool {
    return lifecycle.hasEmbeddedRom();
}

pub fn wasmRomBufPtr() [*]u8 {
    return lifecycle.wasmRomBufPtr();
}

pub fn wasmRomBufCap() u32 {
    return lifecycle.wasmRomBufCap();
}

pub fn wasmSramBufPtr() [*]u8 {
    return lifecycle.wasmSramBufPtr();
}

pub fn wasmSramSize() u32 {
    return lifecycle.wasmSramSize();
}

pub fn wasmMarkSramClean() void {
    lifecycle.wasmMarkSramClean();
}

pub fn gba_init_memory(rom_len: u32) bool {
    return lifecycle.initMemory(AdapterRt, rom_len);
}

pub fn gba_init(rom_path_opt: ?[*:0]const u8, save_path_opt: ?[*:0]const u8, exe_arg0: ?[*:0]const u8) void {
    lifecycle.initHost(AdapterRt, rom_path_opt, save_path_opt, exe_arg0);
}

pub fn gba_shutdown() void {
    lifecycle.shutdown(AdapterRt);
}

test {
    _ = state;
    _ = bus;
    _ = scheduler;
    _ = lifecycle;
    _ = timing;
    _ = @import("runtime/save_io.zig");
    _ = diagnostics;
    _ = adapters;
}
