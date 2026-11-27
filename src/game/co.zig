//! Lifted Advance Wars Commanding Officer (CO) portraits, palette & data table getters (`0x0801BDDC..0x0801BEE4`).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");

/// Compute ROM address of large CO portrait tiles (`0x080C_931C + co_id * 0x100 + 0x540`).
pub inline fn coPortraitTilesAddr(co_id: u8) u32 {
    return 0x080C_931C +% (@as(u32, co_id) << 8) +% 0x540;
}

/// Compute ROM address of small CO portrait tiles (`0x080C_931C + co_id * 0x80 + 0x3720`).
pub inline fn coPortraitSmallTilesAddr(co_id: u8) u32 {
    return 0x080C_931C +% (@as(u32, co_id) << 7) +% 0x3720;
}

/// Reset active CO selection cursor `[0x0201_FD1D] = 0` after `0x0801BD84` (`0x0801BDDC`).
pub fn func_0801BDDC() callconv(.c) void {
    if (!abi.enter(0x0801BDDC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0801BD84, 0x0801BDE3)) return;
    abi.fetches(7);
    const dst = abi.read32(0x0801BDEC);
    abi.write8(dst, 0);
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], 0);
    abi.popReturn();
}

/// Return ROM pointer to active player's CO large portrait tiles (`0x0801BE10`).
pub fn func_0801BE10() callconv(.c) void {
    if (!abi.enter(0x0801BE10)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_0801BE04, 0x0801BE1B)) return;
    abi.fetches(10);
    const tbl = abi.read32(0x0801BE2C);
    const res = (rt.r[0] << 8) +% 0x540 +% tbl;
    abi.setRegNz(&rt.r[0], res);
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Return ROM pointer to active player's CO small portrait tiles (`0x0801BE30`).
pub fn func_0801BE30() callconv(.c) void {
    if (!abi.enter(0x0801BE30)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_0801BE04, 0x0801BE3B)) return;
    abi.fetches(9);
    const off = abi.read32(0x0801BE48);
    const tbl = abi.read32(0x0801BE4C);
    const res = (rt.r[0] << 7) +% off +% tbl;
    abi.setRegNz(&rt.r[0], res);
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Return ROM pointer to CO tag/overlay data (`0x080B_EDC8 + u8(co) * 0x200`) (`0x0801BEA0`).
pub fn func_0801BEA0() callconv(.c) void {
    if (!abi.enter(0x0801BEA0)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_0801BE04, 0x0801BEAB)) return;
    abi.fetches(8);
    const co_idx: u8 = @truncate(rt.r[0]);
    const tbl = abi.read32(0x0801BEB8);
    const res = (@as(u32, co_idx) << 9) +% tbl;
    abi.setRegNz(&rt.r[0], res);
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Read `u32` entry from CO subtable `0x0828_57D4[(co * 5 + u8(r1)) * 4]` (`0x0801BEBC`).
pub fn func_0801BEBC() callconv(.c) void {
    if (!abi.enter(0x0801BEBC)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const sub: u32 = @as(u8, @truncate(rt.r[1]));
    rt.r[0] &= 0xFF;
    rt.r[4] = sub;
    rt.updateNz(sub);
    if (!abi.call(decls.func_0801BE04, 0x0801BECD)) return;
    abi.fetches(12);
    const tbl = abi.read32(0x0801BEE0);
    const entry = ((rt.r[0] *% 5) +% sub) << 2;
    rt.r[2] = tbl;
    rt.r[1] = entry +% tbl;
    rt.updateNz(entry);
    rt.r[0] = abi.read32(rt.r[1]);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Return ROM pointer to CO unit palette (`0x080C_05C8 + u8(co) * 32`) (`0x0801BEE4`).
pub fn func_0801BEE4() callconv(.c) void {
    if (!abi.enter(0x0801BEE4)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_0801BE04, 0x0801BEEF)) return;
    abi.fetches(8);
    const co_idx: u8 = @truncate(rt.r[0]);
    const tbl = abi.read32(0x0801BEFC);
    const res = (@as(u32, co_idx) << 5) +% tbl;
    abi.setRegNz(&rt.r[0], res);
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

fn callCoPortrait1BF50(comptime pool_r1_ref: ?u32, comptime const_r1: u32, comptime ret_addr: u32) void {
    abi.fetches(if (const_r1 == @as(u32, @bitCast(@as(i32, -1)))) 9 else 8);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    if (pool_r1_ref) |ref| {
        rt.r[1] = abi.read32(ref);
    } else {
        rt.r[1] = const_r1;
    }
    if (!abi.call(decls.func_0801BF50, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Look up CO table field `+0x0C` (`u16`, stride `292`) for entity `u8(r0)` (`0x0801BE50`).
pub fn func_0801BE50() callconv(.c) void {
    if (!abi.enter(0x0801BE50)) return;
    abi.fetches(14);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = abi.read32(0x0801BE80);
    const entities = abi.read32(abi.read32(0x0801BE84));
    rt.r[0] = abi.read8(entities +% ((rt.r[0] & 0xFF) *% 0x68) +% 0x1D);
    if (!abi.call(decls.func_0801BE04, 0x0801BE69)) return;

    abi.fetches(14);
    const co_idx = rt.r[0] & 0xFF;
    rt.r[0] = abi.read16(rt.r[4] +% (co_idx * 292) +% 0xC);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Apply CO visual sheet preset `0x08038074` for CO `u8(r0)` (`0x08038064`).
pub fn func_08038064() callconv(.c) void {
    if (!abi.enter(0x08038064)) return;
    callCoPortrait1BF50(0x08038074, 0, 0x08038071);
}

/// Reset CO visual sheet (`-1`) for CO `u8(r0)` (`0x08038078`).
pub fn func_08038078() callconv(.c) void {
    if (!abi.enter(0x08038078)) return;
    callCoPortrait1BF50(null, @bitCast(@as(i32, -1)), 0x08038087);
}

/// Clear CO visual sheet (`0`) for CO `u8(r0)` (`0x0803808C`).
pub fn func_0803808C() callconv(.c) void {
    if (!abi.enter(0x0803808C)) return;
    callCoPortrait1BF50(null, 0, 0x08038099);
}

comptime {
    if (!builtin.is_test) {
        @export(&func_0801BDDC, .{ .name = "func_0801BDDC", .linkage = .strong });
        @export(&func_0801BE10, .{ .name = "func_0801BE10", .linkage = .strong });
        @export(&func_0801BE30, .{ .name = "func_0801BE30", .linkage = .strong });
        @export(&func_0801BE50, .{ .name = "func_0801BE50", .linkage = .strong });
        @export(&func_0801BEA0, .{ .name = "func_0801BEA0", .linkage = .strong });
        @export(&func_0801BEBC, .{ .name = "func_0801BEBC", .linkage = .strong });
        @export(&func_0801BEE4, .{ .name = "func_0801BEE4", .linkage = .strong });
        @export(&func_08038064, .{ .name = "func_08038064", .linkage = .strong });
        @export(&func_08038078, .{ .name = "func_08038078", .linkage = .strong });
        @export(&func_0803808C, .{ .name = "func_0803808C", .linkage = .strong });
    }
}

test "CO portrait ROM stride helpers align with GBA tables" {
    try std.testing.expectEqual(@as(u32, 0x080C_985C), coPortraitTilesAddr(0));
    try std.testing.expectEqual(@as(u32, 0x080C_995C), coPortraitTilesAddr(1));
    try std.testing.expectEqual(@as(u32, 0x080C_CA3C), coPortraitSmallTilesAddr(0));
    try std.testing.expectEqual(@as(u32, 0x080C_CABC), coPortraitSmallTilesAddr(1));
}
