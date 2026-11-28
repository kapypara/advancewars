//! Comptime-parameterized runtime context adapters for BIOS HLE, Thumb/ARM interpreter, and validator.

const core = @import("awre_core");
const bus = @import("bus.zig");
const diagnostics = @import("diagnostics.zig");
const state = @import("state.zig");
const timing = @import("timing.zig");
const MachineState = @import("../validate/validate.zig").MachineState;

const BusMode = core.dma.BusMode;

pub fn BiosCtx(comptime Rt: type) type {
    return struct {
        pub fn regs(_: *@This()) *[16]u32 {
            return Rt.regs();
        }
        pub fn ewram(_: *@This()) *[0x40000]u8 {
            return &state.ewram_buf;
        }
        pub fn iwram(_: *@This()) *[0x8000]u8 {
            return &state.iwram_buf;
        }
        pub fn palette(_: *@This()) *[0x400]u8 {
            return &state.palette_buf;
        }
        pub fn vram(_: *@This()) *[0x18000]u8 {
            return &state.vram_buf;
        }
        pub fn oam(_: *@This()) *[0x400]u8 {
            return &state.oam_buf;
        }
        pub fn ioRead16(_: *@This(), off: u32) u16 {
            return state.ioRead16(off);
        }
        pub fn accessCycles(_: *@This(), addr: u32, wide: bool) u32 {
            return timing.accessCycles(addr, wide, state.ioRead16(0x204));
        }
        pub fn advanceCycles(_: *@This(), cycles: u32) void {
            Rt.advanceCycles(cycles);
        }
        pub fn getBusMode(_: *@This()) BusMode {
            return state.bus_mode;
        }
        pub fn setBusMode(_: *@This(), m: BusMode) void {
            state.bus_mode = m;
        }
        pub fn setVramBurst(_: *@This(), b: bool) void {
            state.vram_burst = b;
        }
        pub fn setCpsrRaw(_: *@This(), val: u32) void {
            state.cpsr = val;
        }
        pub fn triggerSoftReset(_: *@This()) void {
            Rt.triggerSoftReset();
        }
        pub fn softResetPending(_: *@This()) bool {
            return state.soft_reset_pending;
        }
        pub fn logSwi(_: *@This(), number: u32) void {
            diagnostics.logSwi(number, state.frame_count, state.scanline, state.cycle_counter, Rt.regs());
        }
        pub fn warnUnhandledSwi(_: *@This(), number: u32) void {
            if (number == 0x13) {
                core.gba.logPrint("[swi] HuffUnComp not implemented\n", .{});
            } else {
                core.gba.logPrint("[swi] Unhandled SWI 0x{X:0>2} at PC=0x{X:0>8}\n", .{ number, Rt.regs()[15] });
            }
        }
        pub fn busRead8(_: *@This(), addr: u32) u8 {
            return Rt.busRead8(addr);
        }
        pub fn busWrite8(_: *@This(), addr: u32, v: u8) void {
            Rt.busWrite8(addr, v);
        }
        pub fn busRead16(_: *@This(), addr: u32) u16 {
            return Rt.busRead16(addr);
        }
        pub fn busWrite16(_: *@This(), addr: u32, v: u16) void {
            Rt.busWrite16(addr, v);
        }
        pub fn busRead32(_: *@This(), addr: u32) u32 {
            return Rt.busRead32(addr);
        }
        pub fn busRead32s(_: *@This(), addr: u32) u32 {
            return Rt.busRead32s(addr);
        }
        pub fn busWrite32(_: *@This(), addr: u32, v: u32) void {
            Rt.busWrite32(addr, v);
        }
    };
}

pub fn InterpCtx(comptime Rt: type) type {
    return struct {
        pub fn regs(_: *@This()) *[16]u32 {
            return Rt.regs();
        }
        pub fn getN(_: *@This()) bool {
            return Rt.getN();
        }
        pub fn setN(_: *@This(), b: bool) void {
            Rt.setN(b);
        }
        pub fn getZ(_: *@This()) bool {
            return Rt.getZ();
        }
        pub fn setZ(_: *@This(), b: bool) void {
            Rt.setZ(b);
        }
        pub fn getC(_: *@This()) bool {
            return Rt.getC();
        }
        pub fn setC(_: *@This(), b: bool) void {
            Rt.setC(b);
        }
        pub fn getV(_: *@This()) bool {
            return Rt.getV();
        }
        pub fn setV(_: *@This(), b: bool) void {
            Rt.setV(b);
        }
        pub fn getCpsr(_: *@This()) u32 {
            return Rt.getCpsr();
        }
        pub fn setCpsr(_: *@This(), val: u32, mask: u32) void {
            Rt.setCpsr(val, mask);
        }
        pub fn getSpsr(_: *@This()) u32 {
            return Rt.getSpsr();
        }
        pub fn setSpsr(_: *@This(), val: u32, mask: u32) void {
            Rt.setSpsr(val, mask);
        }
        pub fn getBusMode(_: *@This()) BusMode {
            return state.bus_mode;
        }
        pub fn setBusMode(_: *@This(), m: BusMode) void {
            state.bus_mode = m;
        }
        pub fn setRet(_: *@This(), val: u32) void {
            Rt.setRet(val);
        }
        pub fn softResetPending(_: *@This()) bool {
            return state.soft_reset_pending;
        }
        pub fn traceInterpEnter(_: *@This(), target: u32) void {
            diagnostics.traceInterpEnter(target, state.frame_count, Rt.regs());
        }
        pub fn peekCodeWord(_: *@This(), peek_addr: u32) ?u32 {
            const region = peek_addr >> 24;
            switch (region) {
                0x02 => {
                    const off = peek_addr & 0x3FFFF;
                    return @as(u32, state.ewram_buf[off]) |
                        (@as(u32, state.ewram_buf[(off + 1) & 0x3FFFF]) << 8) |
                        (@as(u32, state.ewram_buf[(off + 2) & 0x3FFFF]) << 16) |
                        (@as(u32, state.ewram_buf[(off + 3) & 0x3FFFF]) << 24);
                },
                0x03 => {
                    const off = peek_addr & 0x7FFF;
                    return @as(u32, state.iwram_buf[off]) |
                        (@as(u32, state.iwram_buf[(off + 1) & 0x7FFF]) << 8) |
                        (@as(u32, state.iwram_buf[(off + 2) & 0x7FFF]) << 16) |
                        (@as(u32, state.iwram_buf[(off + 3) & 0x7FFF]) << 24);
                },
                0x08...0x0D => {
                    if (state.rom_size == 0) return null;
                    const off = (peek_addr - 0x0800_0000) % state.rom_size;
                    return @as(u32, state.romByte(off)) |
                        (@as(u32, state.romByte(off + 1)) << 8) |
                        (@as(u32, state.romByte(off + 2)) << 16) |
                        (@as(u32, state.romByte(off + 3)) << 24);
                },
                else => return null,
            }
        }
        pub fn accessCycles(_: *@This(), addr: u32, wide: bool) u32 {
            return timing.accessCycles(addr, wide, state.ioRead16(0x204));
        }
        pub fn dataCycles(_: *@This(), addr: u32, wide: bool, load: bool) i32 {
            return timing.dataCycles(addr, wide, load, state.bus_mode, &state.io_regs_buf, state.scanline, state.scanline_cycles, state.vram_burst);
        }
        pub fn charge(_: *@This(), c_delta: i32) void {
            Rt.charge(c_delta);
        }
        pub fn read32Raw(_: *@This(), addr: u32) u32 {
            return bus.read32Raw(addr);
        }
        pub fn read16Raw(_: *@This(), addr: u32) u16 {
            return bus.read16Raw(addr);
        }
        pub fn busWrite32Raw(_: *@This(), addr: u32, val: u32) void {
            Rt.busWrite32Raw(addr, val);
        }
        pub fn busRead8(_: *@This(), addr: u32) u8 {
            return Rt.busRead8(addr);
        }
        pub fn busWrite8(_: *@This(), addr: u32, val: u8) void {
            Rt.busWrite8(addr, val);
        }
        pub fn busRead16(_: *@This(), addr: u32) u16 {
            return Rt.busRead16(addr);
        }
        pub fn busWrite16(_: *@This(), addr: u32, val: u16) void {
            Rt.busWrite16(addr, val);
        }
        pub fn busRead32(_: *@This(), addr: u32) u32 {
            return Rt.busRead32(addr);
        }
        pub fn busWrite32(_: *@This(), addr: u32, val: u32) void {
            Rt.busWrite32(addr, val);
        }
        pub fn swi(_: *@This(), number: u32) void {
            Rt.swi(number);
        }
        pub fn cpuBx(_: *@This(), addr: u32) void {
            Rt.cpuBx(addr);
        }
        pub fn recompLookup(_: *@This(), addr: u32) u32 {
            return Rt.recompLookup(addr);
        }
        pub fn warnUnmappedArmBx(_: *@This(), addr: u32, rm: u32, insn_pc: u32) void {
            diagnostics.warnUnmappedArmBx(addr, rm, insn_pc);
        }
        pub fn warnUnknownArm(_: *@This(), insn: u32, insn_pc: u32) void {
            core.gba.logPrint("[interp] Unknown ARM insn 0x{X:0>8} at 0x{X:0>8}\n", .{ insn, insn_pc });
        }
        pub fn warnUnknownThumb(_: *@This(), insn: u16, insn_pc: u32) void {
            core.gba.logPrint("[interp] Unknown Thumb insn 0x{X:0>4} at 0x{X:0>8}\n", .{ insn, insn_pc });
        }
        pub fn warnStepLimit(_: *@This(), target: u32, steps: usize, pc: u32) void {
            diagnostics.warnStepLimit(target, steps, pc);
        }
    };
}

pub fn ValidateHost(comptime Rt: type) type {
    return struct {
        pub fn recompLookup(_: *@This(), addr: u32) u32 {
            return Rt.recompLookup(addr);
        }
        pub fn recompLookupFn(_: *@This(), addr: u32) ?*const fn () callconv(.c) void {
            return Rt.recompLookupFn(addr);
        }
        pub fn regs(_: *@This()) *[16]u32 {
            return Rt.regs();
        }
        pub fn getBxDepth(_: *@This()) i32 {
            return Rt.getBxDepth();
        }
        pub fn setBxDepth(_: *@This(), v: i32) void {
            Rt.setBxDepth(v);
        }
        pub fn getRet(_: *@This()) u32 {
            return Rt.getRet();
        }
        pub fn setRet(_: *@This(), v: u32) void {
            Rt.setRet(v);
        }
        pub fn getCycleCounter(_: *@This()) u32 {
            return state.cycle_counter;
        }
        pub fn stateSave(_: *@This(), s: *MachineState) void {
            Rt.stateSave(s);
        }
        pub fn stateLoad(_: *@This(), s: *const MachineState) void {
            Rt.stateLoad(s);
        }
    };
}
