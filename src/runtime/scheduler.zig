//! GBA scanline/HBlank/VBlank scheduler, hardware IRQ delivery, and main execution loops.

const std = @import("std");
const builtin = @import("builtin");
const core = @import("awre_core");
const disp = @import("../platform/display.zig");
const validate_mod = @import("../validate/validate.zig");
const diagnostics = @import("diagnostics.zig");
const save_io = @import("save_io.zig");
const state = @import("state.zig");
const timing = @import("timing.zig");

const has_posix = builtin.os.tag != .freestanding;

const c_host = if (has_posix) struct {
    extern "c" fn exit(status: c_int) noreturn;
} else struct {};

pub fn checkInterrupts(comptime Rt: type) void {
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
    state.spsr = Rt.getCpsr();
    state.cpsr = (state.cpsr & ~@as(u32, 0xFF)) | 0x92;
    state.in_irq = true;

    const bios_if = (@as(u16, state.iwram_buf[0x7FF8]) | (@as(u16, state.iwram_buf[0x7FF9]) << 8)) | pending;
    state.iwram_buf[0x7FF8] = @truncate(bios_if);
    state.iwram_buf[0x7FF9] = @truncate(bios_if >> 8);

    const regs = Rt.regs();
    const saved_r = regs.*;
    const saved_N = Rt.getN();
    const saved_Z = Rt.getZ();
    const saved_C = Rt.getC();
    const saved_V = Rt.getV();
    const saved_ret = Rt.getRet();
    Rt.setRet(0);
    const saved_mode = state.bus_mode;
    state.bus_mode = .rom_code;

    Rt.cpuBx(handler_addr);

    state.bus_mode = saved_mode;
    state.in_irq = was_in_irq;
    if (state.soft_reset_pending) return;

    Rt.setRet(saved_ret);
    regs.* = saved_r;
    Rt.setN(saved_N);
    Rt.setZ(saved_Z);
    Rt.setC(saved_C);
    Rt.setV(saved_V);
    state.cpsr = saved_cpsr;
    state.spsr = saved_spsr;
}

pub fn advanceCycles(comptime Rt: type, cycles: u32) void {
    if (state.soft_reset_pending) return;

    var remaining: u32 = cycles;
    while (remaining > 0) {
        // Slice cycles at HBlank/scanline boundaries so scanline_cycles never overshoots
        // past a boundary before a re-entrant IRQ handler runs at that boundary.
        const next_boundary: u32 = if (!state.hblank_done) timing.hblank_start_cycle else timing.cycles_per_scanline;
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

        if (!state.hblank_done and state.scanline_cycles >= timing.hblank_start_cycle) {
            state.hblank_done = true;
            if (state.scanline < timing.visible_scanlines and !validate_mod.g_validating) {
                disp.display_render_line(@intCast(state.scanline));
            }
            state.ioWrite16(0x004, state.ioRead16(0x004) | 2);
            if ((state.ioRead16(0x004) & 0x10) != 0) {
                state.ioWrite16(0x202, state.ioRead16(0x202) | 2);
            }
            if (state.scanline < timing.visible_scanlines) {
                state.dma_state.triggerHBlank(Rt.dmaBus());
            }
            checkInterrupts(Rt);
            if (state.soft_reset_pending) return;
            continue;
        }
        if (state.scanline_cycles >= timing.cycles_per_scanline) {
            state.scanline_cycles -= timing.cycles_per_scanline;
            state.hblank_done = false;

            const prev_scanline = state.scanline;
            state.scanline = (state.scanline + 1) % timing.scanlines_per_frame;

            state.io_regs_buf[0x006] = @truncate(state.scanline & 0xFF);
            state.io_regs_buf[0x007] = 0;

            var dispstat = state.ioRead16(0x004);
            const vcount_target = (dispstat >> 8) & 0xFF;
            dispstat &= ~@as(u16, 0x0007);
            if (state.scanline >= timing.visible_scanlines) dispstat |= 1;
            if (state.scanline == vcount_target) dispstat |= 4;
            state.ioWrite16(0x004, dispstat);

            if (state.scanline == timing.visible_scanlines and prev_scanline != timing.visible_scanlines) {
                state.ioWrite16(0x202, state.ioRead16(0x202) | 1);
                state.dma_state.triggerVBlank(Rt.dmaBus());

                state.frame_count +%= 1;

                const keys = disp.display_get_keys();
                state.io_regs_buf[0x130] = @truncate(keys);
                state.io_regs_buf[0x131] = @truncate(keys >> 8);

                if (!validate_mod.g_validating) {
                    disp.display_render_frame();
                }
                disp.display_pace();

                diagnostics.checkHistFrame(state.frame_count, Rt.histOnPtr());
                if (has_posix) {
                    save_io.writeDumpAtSnapshot(disp.display_dump_path(@intCast(state.frame_count)));
                }
                if (!validate_mod.g_validating) save_io.pollBackupFlush();

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

            checkInterrupts(Rt);
            if (state.soft_reset_pending) return;
            continue;
        }
        if (step == 0) break;
    }

    if (state.cycle_counter -% state.last_poll_cycle > timing.poll_interval) {
        state.last_poll_cycle = state.cycle_counter;
        if (disp.display_poll_events() != 0) {
            if (!state.wasm_stop_requested) Rt.shutdown();
            if (has_posix) {
                c_host.exit(0);
            } else {
                state.wasm_stop_requested = true;
                state.soft_reset_pending = true;
                Rt.setRet(0xFFFF_FFFF);
                return;
            }
        }
    }
}

pub fn charge(comptime Rt: type, c_delta: i32) void {
    const c = c_delta + state.cycle_credit;
    state.cycle_credit = if (c < 0) c else 0;
    if (c > 0) advanceCycles(Rt, @intCast(c));
}

pub fn stepFrame(comptime Rt: type) void {
    const target_cycle = ((state.cycle_counter / timing.cycles_per_frame) + 1) * timing.cycles_per_frame +
        timing.visible_scanlines * timing.cycles_per_scanline;
    while (state.cycle_counter < target_cycle) {
        advanceCycles(Rt, timing.cycles_per_scanline);
        if (state.soft_reset_pending) return;
    }
}

pub fn runLoop(entry_func: *const fn () void, g_ret: *u32) void {
    while (true) {
        state.soft_reset_pending = false;
        state.in_irq = false;
        g_ret.* = 0;
        entry_func();
        if (state.wasm_stop_requested or !state.soft_reset_pending) break;
        state.soft_reset_count +%= 1;
        if (state.soft_reset_count <= 5) {
            core.gba.logPrint("[runtime] SoftReset #{d}\n", .{state.soft_reset_count});
        }
    }
}

test "scheduler.charge accumulates negative credit before advancing cycles" {
    state.resetCommon();
    defer state.resetCommon();

    const TestRt = struct {
        var dummy_regs: [16]u32 = @splat(0);
        var dummy_flag: bool = false;
        var dummy_ret: u32 = 0;
        var dummy_hist: c_int = 0;
        const DummyDma = struct {
            pub fn ioRead16(_: *@This(), off: u32) u16 {
                return state.ioRead16(off);
            }
            pub fn ioWrite16(_: *@This(), off: u32, val: u16) void {
                state.ioWrite16(off, val);
            }
            pub fn ioRead32(_: *@This(), off: u32) u32 {
                return state.ioRead32(off);
            }
            pub fn busRead32(_: *@This(), _: u32) u32 {
                return 0;
            }
            pub fn busWrite32(_: *@This(), _: u32, _: u32) void {}
            pub fn busRead16(_: *@This(), _: u32) u16 {
                return 0;
            }
            pub fn busWrite16(_: *@This(), _: u32, _: u16) void {}
            pub fn getBusMode(_: *@This()) state.BusMode {
                return state.bus_mode;
            }
            pub fn setBusMode(_: *@This(), m: state.BusMode) void {
                state.bus_mode = m;
            }
            pub fn raiseIrq(_: *@This(), mask: u16) void {
                state.raiseIrqBits(mask);
            }
        };
        var dummy_dma: DummyDma = .{};
        pub fn regs() *[16]u32 {
            return &dummy_regs;
        }
        pub fn getN() bool {
            return dummy_flag;
        }
        pub fn setN(_: bool) void {}
        pub fn getZ() bool {
            return dummy_flag;
        }
        pub fn setZ(_: bool) void {}
        pub fn getC() bool {
            return dummy_flag;
        }
        pub fn setC(_: bool) void {}
        pub fn getV() bool {
            return dummy_flag;
        }
        pub fn setV(_: bool) void {}
        pub fn getCpsr() u32 {
            return 0x1F;
        }
        pub fn getRet() u32 {
            return dummy_ret;
        }
        pub fn setRet(val: u32) void {
            dummy_ret = val;
        }
        pub fn cpuBx(_: u32) void {}
        pub fn dmaBus() *DummyDma {
            return &dummy_dma;
        }
        pub fn histOnPtr() *c_int {
            return &dummy_hist;
        }
        pub fn shutdown() void {}
    };

    charge(TestRt, -2);
    try std.testing.expectEqual(@as(i32, -2), state.cycle_credit);
    try std.testing.expectEqual(@as(u32, 0), state.cycle_counter);

    charge(TestRt, 1);
    try std.testing.expectEqual(@as(i32, -1), state.cycle_credit);
    try std.testing.expectEqual(@as(u32, 0), state.cycle_counter);

    charge(TestRt, 5);
    try std.testing.expectEqual(@as(i32, 0), state.cycle_credit);
    try std.testing.expectEqual(@as(u32, 4), state.cycle_counter);
}
