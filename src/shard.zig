const std = @import("std");

// External CPU/memory/runtime symbols exported from `src/runtime.zig`
// so each generated `gen/funcs_*.zig` shard compiles as an independent `.o`.
pub extern var r: [16]u32;
pub extern var CPU_N: bool;
pub extern var CPU_Z: bool;
pub extern var CPU_C: bool;
pub extern var CPU_V: bool;

pub extern var g_func_ring: [4096]u32;
pub extern var g_func_ring_i: u32;
pub extern var g_validate: c_int;
pub extern var g_ret: u32;
pub extern var g_unwind_trace: c_int;
pub extern var g_hist_on: c_int;

pub extern fn bus_read32(addr: u32) u32;
pub extern fn bus_read32s(addr: u32) u32;
pub extern fn bus_read16(addr: u32) u16;
pub extern fn bus_read8(addr: u32) u8;
pub extern fn bus_write32(addr: u32, value: u32) void;
pub extern fn bus_write16(addr: u32, value: u16) void;
pub extern fn bus_write8(addr: u32, value: u8) void;

pub extern fn cpu_fetches(n: u32) void;
pub extern fn gba_swi(number: u32) void;
pub extern fn cpu_get_cpsr() u32;
pub extern fn cpu_set_cpsr(value: u32, mask: u32) void;
pub extern fn cpu_get_spsr() u32;
pub extern fn cpu_set_spsr(value: u32, mask: u32) void;
pub extern fn cpu_undefined(insn: u32) void;

pub extern fn recomp_unwind_note(retaddr: u32) void;
pub extern fn recomp_hist(addr: u32) void;
pub extern fn recomp_validate(addr: u32) c_int;

// ---- Local pure-Zig ARM7TDMI ALU / Shift / Unwind Helpers (inlined per shard in ReleaseFast) ----
pub fn ror32(val: u32, amount: u32) u32 {
    const a: u5 = @truncate(amount);
    return std.math.rotr(u32, val, a);
}

pub fn rrx(val: u32) u32 {
    return (@as(u32, @intFromBool(CPU_C)) << 31) | (val >> 1);
}

pub fn armLsl(val: u32, amount: u32) u32 {
    if (amount == 0) return val;
    if (amount >= 32) return 0;
    return val << @intCast(amount);
}

pub fn armLsr(val: u32, amount: u32) u32 {
    if (amount == 0) return val;
    if (amount >= 32) return 0;
    return val >> @intCast(amount);
}

pub fn armAsr(val: u32, amount: u32) u32 {
    if (amount == 0) return val;
    if (amount >= 32) return if (@as(i32, @bitCast(val)) < 0) 0xFFFF_FFFF else 0;
    return @bitCast(@as(i32, @bitCast(val)) >> @intCast(amount));
}

pub fn asrConst(val: u32, shift: u5) u32 {
    return @bitCast(@as(i32, @bitCast(val)) >> shift);
}

pub fn sext8(val: u8) u32 {
    return @bitCast(@as(i32, @as(i8, @bitCast(val))));
}

pub fn sext16(val: u16) u32 {
    return @bitCast(@as(i32, @as(i16, @bitCast(val))));
}

pub fn updateNz(result: u32) void {
    CPU_N = (result >> 31) != 0;
    CPU_Z = (result == 0);
}

pub fn cpuAdd(dest: ?*u32, a: u32, b: u32, set_flags: bool) void {
    const res64 = @as(u64, a) + @as(u64, b);
    const result: u32 = @truncate(res64);
    if (dest) |d| d.* = result;
    if (set_flags) {
        CPU_N = (result >> 31) != 0;
        CPU_Z = (result == 0);
        CPU_C = (res64 >> 32) != 0;
        CPU_V = ((~(a ^ b) & (a ^ result)) >> 31) != 0;
    }
}

pub fn cpuSub(dest: ?*u32, a: u32, b: u32, set_flags: bool) void {
    const result = a -% b;
    if (dest) |d| d.* = result;
    if (set_flags) {
        CPU_N = (result >> 31) != 0;
        CPU_Z = (result == 0);
        CPU_C = (a >= b);
        CPU_V = (((a ^ b) & (a ^ result)) >> 31) != 0;
    }
}

pub fn cpuAdc(dest: ?*u32, a: u32, b: u32, set_flags: bool) void {
    const carry: u64 = @intFromBool(CPU_C);
    const res64 = @as(u64, a) + @as(u64, b) + carry;
    const result: u32 = @truncate(res64);
    if (dest) |d| d.* = result;
    if (set_flags) {
        CPU_N = (result >> 31) != 0;
        CPU_Z = (result == 0);
        CPU_C = (res64 >> 32) != 0;
        CPU_V = ((~(a ^ b) & (a ^ result)) >> 31) != 0;
    }
}

pub fn cpuSbc(dest: ?*u32, a: u32, b: u32, set_flags: bool) void {
    const borrow: u32 = if (CPU_C) 0 else 1;
    const result = a -% b -% borrow;
    if (dest) |d| d.* = result;
    if (set_flags) {
        CPU_N = (result >> 31) != 0;
        CPU_Z = (result == 0);
        CPU_C = @as(u64, a) >= @as(u64, b) + @as(u64, borrow);
        CPU_V = (((a ^ b) & (a ^ result)) >> 31) != 0;
    }
}

pub fn recompReturn(target: u32) void {
    g_ret = target | 1;
}

pub fn recompCalled(retaddr: u32) bool {
    if (g_ret != 0 and ((g_ret ^ retaddr) & ~@as(u32, 1)) != 0) {
        if (g_unwind_trace != 0) recomp_unwind_note(retaddr);
        return false;
    }
    g_ret = 0;
    return true;
}

pub fn recompEnter(addr: u32) bool {
    g_func_ring[g_func_ring_i & 4095] = addr;
    g_func_ring_i +%= 1;
    if (g_hist_on != 0) recomp_hist(addr);
    if (g_validate != 0 and recomp_validate(addr) != 0) return false;
    return true;
}
