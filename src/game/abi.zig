//! ABI bridge helpers connecting lifted Zig game functions with the generated
//! ARM7TDMI register/bus layer during incremental side-by-side decompilation.

const std = @import("std");
const rt = @import("runtime");

/// Check entry tracing gate matching generated shards before executing a lifted function.
pub inline fn enter(addr: u32) bool {
    return rt.recompEnter(addr);
}

/// Account approximate instruction cycles when running timing-sensitive paths.
pub inline fn fetches(n: u32) void {
    rt.cpu_fetches(n);
}

/// Push `r14` (`lr`) onto the emulated GBA stack.
pub inline fn pushLr() void {
    rt.r[13] -%= 4;
    rt.bus_write32(rt.r[13], rt.r[14]);
}

/// Pop return address from the emulated GBA stack into `r0`/`r15` and return.
pub inline fn popReturn() void {
    const lr_val = rt.bus_read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Return to caller using `r14` (`bx lr`).
pub inline fn retLr() void {
    rt.recompReturn(rt.r[14]);
}

/// Invoke GBA BIOS software interrupt `#num`.
pub inline fn swi(num: u32) void {
    rt.gba_swi(num);
}

/// Call a function pointer using GBA `bl` conventions (`lr = ret_addr`, `g_ret = 0`).
pub inline fn call(func: *const fn () callconv(.c) void, ret_addr: u32) bool {
    rt.r[14] = ret_addr;
    rt.g_ret = 0;
    func();
    return rt.recompCalled(ret_addr);
}

/// Assign a register and update N/Z flags (matching Thumb `movs`).
pub inline fn setRegNz(reg: *u32, val: u32) void {
    reg.* = val;
    rt.updateNz(val);
}

/// Assign a register using `rt.cpuAdd` semantics (sets all NZCV flags).
pub inline fn copyRegFlags(dst: *u32, src: u32) void {
    rt.cpuAdd(dst, src, 0, true);
}

/// Read argument register `r0..r3`.
pub inline fn arg(comptime idx: u2) u32 {
    return rt.r[idx];
}

/// Read argument register `r0..r3` as signed `i32`.
pub inline fn argI32(comptime idx: u2) i32 {
    return @bitCast(rt.r[idx]);
}

/// Return unsigned `u32` via `r0` (and update `g_ret` tracking cleanly if needed).
pub inline fn retU32(val: u32) void {
    rt.r[0] = val;
}

/// Return signed `i32` via `r0`.
pub inline fn retI32(val: i32) void {
    rt.r[0] = @bitCast(val);
}

/// Return boolean via `r0` (`1` or `0`).
pub inline fn retBool(val: bool) void {
    rt.r[0] = @intFromBool(val);
}

pub inline fn read8(addr: u32) u8 {
    return rt.bus_read8(addr);
}

pub inline fn read16(addr: u32) u16 {
    return rt.bus_read16(addr);
}

pub inline fn read32(addr: u32) u32 {
    return rt.bus_read32(addr);
}

pub inline fn write8(addr: u32, val: u8) void {
    rt.bus_write8(addr, val);
}

pub inline fn write16(addr: u32, val: u16) void {
    rt.bus_write16(addr, val);
}

pub inline fn write32(addr: u32, val: u32) void {
    rt.bus_write32(addr, val);
}

/// Sign-extend an 8-bit value to `i32`.
pub inline fn signExtend8(v: u8) i32 {
    return @as(i8, @bitCast(v));
}

/// Sign-extend a 16-bit value to `i32`.
pub inline fn signExtend16(v: u16) i32 {
    return @as(i16, @bitCast(v));
}

test "abi pure sign extension helpers preserve two's complement values" {
    try std.testing.expectEqual(@as(i32, -1), signExtend8(0xFF));
    try std.testing.expectEqual(@as(i32, 127), signExtend8(0x7F));
    try std.testing.expectEqual(@as(i32, -32768), signExtend16(0x8000));
    try std.testing.expectEqual(@as(i32, 32767), signExtend16(0x7FFF));
}
