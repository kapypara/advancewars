//! Backing RAM buffers, backup/peripheral instances, scheduler counters, and snapshot helpers.

const std = @import("std");
const core = @import("awre_core");
const MachineState = @import("../validate/validate.zig").MachineState;

pub const Flash = core.flash.Flash;
pub const Eeprom = core.flash.Eeprom;
pub const Timers = core.timers.Timers;
pub const Dma = core.dma.Dma;
pub const BusMode = core.dma.BusMode;

pub const GameCallbacks = struct {
    bx_depth: *i32,
    cpu_bx: *const fn (u32) callconv(.c) void,
    recomp_lookup: *const fn (u32) u32,
    recomp_lookup_fn: *const fn (u32) ?*const fn () callconv(.c) void,
};

pub var game_cb: ?GameCallbacks = null;

pub fn registerGameCallbacks(cb: GameCallbacks) void {
    game_cb = cb;
}

pub inline fn cbCpuBx(target: u32) void {
    if (game_cb) |cb| cb.cpu_bx(target);
}

pub inline fn cbRecompLookup(addr: u32) u32 {
    return if (game_cb) |cb| cb.recomp_lookup(addr) else 0;
}

pub inline fn cbRecompLookupFn(addr: u32) ?*const fn () callconv(.c) void {
    return if (game_cb) |cb| cb.recomp_lookup_fn(addr) else null;
}

pub inline fn getBxDepth() i32 {
    return if (game_cb) |cb| cb.bx_depth.* else 0;
}

pub inline fn setBxDepth(v: i32) void {
    if (game_cb) |cb| cb.bx_depth.* = v;
}

pub export var g_func_ring: [4096]u32 = @splat(0);
pub export var g_func_ring_i: u32 = 0;
pub export var g_validate: c_int = 0;
pub export var g_ret: u32 = 0;
pub export var g_unwind_trace: c_int = 0;
pub export var g_hist_on: c_int = 0;

pub fn triggerSoftReset() void {
    soft_reset_pending = true;
    g_ret = 0xFFFF_FFFF;
}

pub var ewram_buf: [0x40000]u8 = @splat(0);
pub var iwram_buf: [0x8000]u8 = @splat(0);
pub var io_regs_buf: [0x400]u8 = @splat(0);
pub var palette_buf: [0x400]u8 = @splat(0);
pub var vram_buf: [0x18000]u8 = @splat(0);
pub var oam_buf: [0x400]u8 = @splat(0);
pub var sram_buf: [0x20000]u8 = @splat(0);
pub var sram_active: bool = false;

pub var rom_ptr: ?[*]const u8 = null;
pub var rom_size: u32 = 0;
pub var rom_owned: bool = false;
pub var bios_mem_ptr: ?[*]u8 = null;

pub var exe_path_buf: [512]u8 = @splat(0);
pub var sram_path_buf: [512]u8 = @splat(0);
pub var sram_path_len: usize = 0;
pub var eeprom_path_buf: [512]u8 = @splat(0);
pub var eeprom_path_len: usize = 0;

pub var sram_dirty_frames: u32 = 0;
pub var sram_last_seq: u32 = 0;
pub var eeprom_dirty_frames: u32 = 0;
pub var eeprom_last_seq: u32 = 0;

pub var cpsr: u32 = 0x0000_001F;
pub var spsr: u32 = 0;

pub var flash_state: Flash = .{};
pub var eeprom_state: Eeprom = .{};
pub var timer_state: Timers = .{};
pub var dma_state: Dma = .{};

pub var cycle_counter: u32 = 0;
pub var scanline: u32 = 0;
pub var frame_count: u32 = 0;
pub var scanline_cycles: u32 = 0;
pub var hblank_done: bool = false;
pub var last_poll_cycle: u32 = 0;

pub var bus_mode: BusMode = .rom_code;
pub var platform_keyinput: u16 = 0x03FF;
pub var cycle_credit: i32 = 0;
pub var vram_burst: bool = false;
pub var in_irq: bool = false;
pub var soft_reset_pending: bool = false;
pub var soft_reset_count: u32 = 0;
pub var wasm_stop_requested: bool = false;

pub fn romSlice() ?[]const u8 {
    const p = rom_ptr orelse return null;
    if (rom_size == 0) return null;
    return p[0..rom_size];
}

pub inline fn romByte(off: u32) u8 {
    const ptr = rom_ptr orelse return 0;
    return ptr[off % rom_size];
}

pub inline fn ioRead16(off: u32) u16 {
    return @as(u16, io_regs_buf[off]) | (@as(u16, io_regs_buf[off + 1]) << 8);
}

pub inline fn ioWrite16(off: u32, val: u16) void {
    io_regs_buf[off] = @truncate(val);
    io_regs_buf[off + 1] = @truncate(val >> 8);
}

pub inline fn ioRead32(off: u32) u32 {
    return @as(u32, io_regs_buf[off]) |
        (@as(u32, io_regs_buf[off + 1]) << 8) |
        (@as(u32, io_regs_buf[off + 2]) << 16) |
        (@as(u32, io_regs_buf[off + 3]) << 24);
}

pub inline fn memWrite16Raw(mem: []u8, off: u32, val: u16) void {
    mem[off] = @truncate(val);
    mem[off + 1] = @truncate(val >> 8);
}

pub inline fn memWrite32Raw(mem: []u8, off: u32, val: u32) void {
    mem[off] = @truncate(val);
    mem[off + 1] = @truncate(val >> 8);
    mem[off + 2] = @truncate(val >> 16);
    mem[off + 3] = @truncate(val >> 24);
}

pub inline fn raiseIrqBits(mask: u16) void {
    ioWrite16(0x202, ioRead16(0x202) | mask);
}

pub fn resetCommon() void {
    @memset(&ewram_buf, 0);
    @memset(&iwram_buf, 0);
    @memset(&io_regs_buf, 0);
    @memset(&palette_buf, 0);
    @memset(&vram_buf, 0);
    @memset(&oam_buf, 0);
    @memset(&sram_buf, 0);
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
    platform_keyinput = 0x03FF;
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

pub fn saveMachineState(s: *MachineState, regs: [16]u32, n: bool, z: bool, c: bool, v: bool) void {
    @memcpy(&s.ewram, &ewram_buf);
    @memcpy(&s.iwram, &iwram_buf);
    @memcpy(&s.io, &io_regs_buf);
    @memcpy(&s.pal, &palette_buf);
    @memcpy(&s.vram, &vram_buf);
    @memcpy(&s.oam, &oam_buf);
    s.r = regs;
    s.n = n;
    s.z = z;
    s.c = c;
    s.v = v;
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

pub fn loadMachineState(s: *const MachineState, regs: *[16]u32, n: *bool, z: *bool, c: *bool, v: *bool) void {
    @memcpy(&ewram_buf, &s.ewram);
    @memcpy(&iwram_buf, &s.iwram);
    @memcpy(&io_regs_buf, &s.io);
    @memcpy(&palette_buf, &s.pal);
    @memcpy(&vram_buf, &s.vram);
    @memcpy(&oam_buf, &s.oam);
    regs.* = s.r;
    n.* = s.n;
    z.* = s.z;
    c.* = s.c;
    v.* = s.v;
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

test "state I/O helpers and IRQ flag raising" {
    resetCommon();
    defer resetCommon();

    ioWrite16(0x200, 0x1234);
    ioWrite16(0x202, 0x0001);
    try std.testing.expectEqual(@as(u16, 0x1234), ioRead16(0x200));
    try std.testing.expectEqual(@as(u32, 0x0001_1234), ioRead32(0x200));

    raiseIrqBits(0x0008);
    try std.testing.expectEqual(@as(u16, 0x0009), ioRead16(0x202));

    platform_keyinput = 0x0000;
    resetCommon();
    try std.testing.expectEqual(@as(u32, 0), ioRead32(0x200));
    try std.testing.expectEqual(@as(u16, 0x03FF), platform_keyinput);
}
