//! Lifted Advance Wars proc (`0x0300_0E10`) and cutscene script (`0x0300_1D50`)
//! opcode handlers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const abi = @import("abi.zig");
const types = @import("types.zig");

/// Compute EWRAM/IWRAM address of proc slot `idx` (`u8`, stride `0x60`).
pub inline fn procSlotAddr(slot_idx: u8) u32 {
    return types.addr.proc_table +% @as(u32, slot_idx) *% @as(u32, types.proc_slot_stride);
}

/// Compute address of `+0x04` cursor word in secondary script slot `idx` (`i16`, stride `0x18`).
pub inline fn scriptCursorFieldAddr(slot_idx: i16) u32 {
    const signed: i32 = slot_idx;
    const off: u32 = @bitCast(signed *% @as(i32, types.script_slot_stride));
    return off +% (types.addr.script_pool + 4);
}

/// Proc command: copy `*cursor` into `proc + 0x08`, advance cursor by 8, return `0` (`0x08013D14`).
pub fn func_08013D14() callconv(.c) void {
    if (!abi.enter(0x08013D14)) return;
    abi.fetches(20);
    const idx: u8 = @truncate(rt.r[0]);
    const base = abi.read32(0x08013D38);
    const slot_off = @as(u32, idx) *% @as(u32, types.proc_slot_stride);
    const dst = slot_off +% (base +% 8);
    const cur_ptr_addr = slot_off +% (base +% 4);
    const cur = abi.read32(cur_ptr_addr);
    const val = abi.read32(cur);
    abi.write32(dst, val);
    abi.write32(cur_ptr_addr, cur +% 8);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = val;
    rt.r[3] = dst;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Proc command: set sleep timer `[proc + 0x10] = read16(cursor + 4)`, advance cursor by 8, return `0` (`0x08013D3C`).
pub fn func_08013D3C() callconv(.c) void {
    if (!abi.enter(0x08013D3C)) return;
    abi.fetches(19);
    const idx: u8 = @truncate(rt.r[0]);
    const base = abi.read32(0x08013D60);
    const slot_off = @as(u32, idx) *% @as(u32, types.proc_slot_stride);
    const proc = slot_off +% base;
    const cur_ptr_addr = slot_off +% (base +% 4);
    const cur = abi.read32(cur_ptr_addr);
    abi.write16(proc +% 0x10, abi.read16(cur +% 4));
    abi.write32(cur_ptr_addr, cur +% 8);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = base +% 4;
    rt.r[3] = proc;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Proc command: jump `cursor = *cursor`, zero `sleep_timer` & `state38`, return `1` (`0x08013DA0`).
pub fn func_08013DA0() callconv(.c) void {
    if (!abi.enter(0x08013DA0)) return;
    abi.fetches(19);
    const idx: u8 = @truncate(rt.r[0]);
    const base = abi.read32(0x08013DC4);
    const slot_off = @as(u32, idx) *% @as(u32, types.proc_slot_stride);
    const cur_ptr_addr = slot_off +% (base +% 4);
    const jump_target = abi.read32(abi.read32(cur_ptr_addr));
    abi.write32(cur_ptr_addr, jump_target);
    const proc = slot_off +% base;
    abi.write16(proc +% 0x10, 0);
    abi.write16(proc +% 0x38, 0);
    rt.r[1] = proc;
    rt.r[2] = jump_target;
    rt.r[3] = base;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

/// Proc command no-op returning `0` (`0x08013DF0`).
pub fn func_08013DF0() callconv(.c) void {
    if (!abi.enter(0x08013DF0)) return;
    abi.fetches(4);
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Proc command: set callback `[proc + 0x0C] = *cursor`, advance cursor by 8, return `1` (`0x08013DF4`).
pub fn func_08013DF4() callconv(.c) void {
    if (!abi.enter(0x08013DF4)) return;
    abi.fetches(20);
    const idx: u8 = @truncate(rt.r[0]);
    const base = abi.read32(0x08013E18);
    const slot_off = @as(u32, idx) *% @as(u32, types.proc_slot_stride);
    const dst = slot_off +% (base +% 0xC);
    const cur_ptr_addr = slot_off +% (base +% 4);
    const cur = abi.read32(cur_ptr_addr);
    const val = abi.read32(cur);
    abi.write32(dst, val);
    abi.write32(cur_ptr_addr, cur +% 8);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = val;
    rt.r[3] = dst;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

/// Proc command: set flag halfword `[0x08014098] = 1`, advance cursor by 8, return `1` (`0x08014078`).
pub fn func_08014078() callconv(.c) void {
    if (!abi.enter(0x08014078)) return;
    abi.fetches(18);
    const idx: u8 = @truncate(rt.r[0]);
    abi.write16(abi.read32(0x08014098), 1);
    const base = abi.read32(0x0801409C);
    const slot_off = @as(u32, idx) *% @as(u32, types.proc_slot_stride);
    const cur_ptr_addr = slot_off +% (base +% 4);
    const cur = abi.read32(cur_ptr_addr);
    abi.write32(cur_ptr_addr, cur +% 8);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = base +% 4;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

/// Secondary script command no-op returning `0` (`0x08017104`).
pub fn func_08017104() callconv(.c) void {
    if (!abi.enter(0x08017104)) return;
    abi.fetches(4);
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Secondary script command: write 8-bit immediate (`[cmd+0xC] -> [cmd+4]`), step `cmd += 0x10` (`0x08017108`).
pub fn func_08017108() callconv(.c) void {
    if (!abi.enter(0x08017108)) return;
    abi.fetches(19);
    const idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const base = abi.read32(0x0801712C);
    const off: u32 = @bitCast(@as(i32, idx) *% @as(i32, types.script_slot_stride));
    const cur_ptr_addr = off +% (base +% 4);
    const cmd = abi.read32(cur_ptr_addr);
    const dst = abi.read32(cmd +% 4);
    const val = abi.read32(cmd +% 0xC);
    abi.write8(dst, @truncate(val));
    abi.write32(cur_ptr_addr, cmd +% 0x10);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = dst;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

fn scriptWrite16Or32(comptime width: u8, comptime pool_ptr_addr: u32) void {
    abi.fetches(18);
    const idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const base = abi.read32(pool_ptr_addr);
    const off: u32 = @bitCast(@as(i32, idx) *% @as(i32, types.script_slot_stride));
    const cur_ptr_addr = off +% (base +% 4);
    const cmd = abi.read32(cur_ptr_addr);
    const dst = abi.read32(cmd +% 4);
    const val = abi.read32(cmd +% 0xC);
    if (width == 16) {
        abi.write16(dst, @truncate(val));
    } else {
        abi.write32(dst, val);
    }
    abi.write32(cur_ptr_addr, cmd +% 0x10);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = val;
    rt.r[3] = dst;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

/// Secondary script command: write 16-bit immediate (`[cmd+0xC] -> [cmd+4]`), step `cmd += 0x10` (`0x08017130`).
pub fn func_08017130() callconv(.c) void {
    if (!abi.enter(0x08017130)) return;
    scriptWrite16Or32(16, 0x08017150);
}

/// Secondary script command: write 32-bit immediate (`[cmd+0xC] -> [cmd+4]`), step `cmd += 0x10` (`0x08017154`).
pub fn func_08017154() callconv(.c) void {
    if (!abi.enter(0x08017154)) return;
    scriptWrite16Or32(32, 0x08017174);
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08013D14, .{ .name = "func_08013D14", .linkage = .strong });
        @export(&func_08013D3C, .{ .name = "func_08013D3C", .linkage = .strong });
        @export(&func_08013DA0, .{ .name = "func_08013DA0", .linkage = .strong });
        @export(&func_08013DF0, .{ .name = "func_08013DF0", .linkage = .strong });
        @export(&func_08013DF4, .{ .name = "func_08013DF4", .linkage = .strong });
        @export(&func_08014078, .{ .name = "func_08014078", .linkage = .strong });
        @export(&func_08017104, .{ .name = "func_08017104", .linkage = .strong });
        @export(&func_08017108, .{ .name = "func_08017108", .linkage = .strong });
        @export(&func_08017130, .{ .name = "func_08017130", .linkage = .strong });
        @export(&func_08017154, .{ .name = "func_08017154", .linkage = .strong });
    }
}

test "proc and script slot address helpers match GBA strides" {
    try std.testing.expectEqual(@as(u32, 0x0300_0E10), procSlotAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_0E70), procSlotAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0300_1D54), scriptCursorFieldAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_1D6C), scriptCursorFieldAddr(1));
}
