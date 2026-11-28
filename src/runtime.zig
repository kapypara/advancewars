const std = @import("std");
const builtin = @import("builtin");
const core = @import("awre_core");
const disp = @import("platform/display.zig");
const adapters = @import("runtime/adapters.zig");
const bus = @import("runtime/bus.zig");
const diagnostics = @import("runtime/diagnostics.zig");
const save_io = @import("runtime/save_io.zig");
const scheduler = @import("runtime/scheduler.zig");
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

const cycles_per_scanline = timing.cycles_per_scanline;
const visible_scanlines = timing.visible_scanlines;
const scanlines_per_frame = timing.scanlines_per_frame;
const hblank_start_cycle = timing.hblank_start_cycle;

// ---- Fetch Timing State ----
var fetch_x16: u32 = 0;
var fetch_frac: u32 = 0;

// ---- Timing & Waitstates ----
inline fn dataCycles(addr: u32, wide: bool, load: bool) i32 {
    return timing.dataCycles(addr, wide, load, state.bus_mode, &state.io_regs_buf, state.scanline, state.scanline_cycles, state.vram_burst);
}

inline fn charge(c_delta: i32) void {
    scheduler.charge(AdapterRt, c_delta);
}

// ---- DMA Bus Interface ----
var dma_bus: bus.DmaBus(AdapterRt) = .{};

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
    pub fn triggerSoftReset() void {
        state.soft_reset_pending = true;
        g_ret = 0xFFFF_FFFF;
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
    pub fn advanceCycles(cycles: u32) void {
        scheduler.advanceCycles(AdapterRt, cycles);
    }
    pub fn charge(c_delta: i32) void {
        scheduler.charge(AdapterRt, c_delta);
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
    pub fn dmaBus() *bus.DmaBus(AdapterRt) {
        return &dma_bus;
    }
    pub fn histOnPtr() *c_int {
        return &g_hist_on;
    }
    pub fn shutdown() void {
        gba_shutdown();
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
    scheduler.checkInterrupts(AdapterRt);
}

pub fn gba_frame() void {
    scheduler.stepFrame(AdapterRt);
}

pub fn gba_run(entry_func: *const fn () void) void {
    scheduler.runLoop(entry_func, &g_ret);
}

// ---- Validation Hooks ----

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
    save_io.sramLoad();
    state.flash_state.dirty = false;
    state.flash_state.write_seq = 0;
    state.sram_last_seq = 0;

    if (state.eeprom_state.detect(rom_slice)) |ee_addr| {
        core.gba.logPrint("[runtime] EEPROM detected at ROM 0x{X:0>8} (assuming 8KB)\n", .{ee_addr});
        const ee_base = if (save_path_opt) |sp| std.mem.span(sp) else default_base;
        state.eeprom_path_len = save_io.buildSidecarPath(ee_base, ".eep", &state.eeprom_path_buf);
        save_io.eepromLoad();
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
    save_io.sramSave();
    save_io.eepromSave();
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
    _ = scheduler;
    _ = timing;
    _ = save_io;
    _ = diagnostics;
    _ = adapters;
}
