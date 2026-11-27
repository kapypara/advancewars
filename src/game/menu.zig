//! Title screen, menus, sound cues, and pre-battle UI initialization.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");

fn popReturnValue() void {
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

fn spawnProcZero(comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(def_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn callVoidFn(comptime target: fn () callconv(.c) void, comptime ret_addr: u32) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(target, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn callSingleU32(
    comptime target: fn () callconv(.c) void,
    comptime arg0: u32,
    comptime fetches_before: u32,
    comptime ret_addr: u32,
    comptime returns_val: bool,
) void {
    abi.fetches(fetches_before);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], arg0);
    if (!abi.call(target, ret_addr)) return;
    abi.fetches(4);
    if (returns_val) popReturnValue() else abi.popReturn();
}

fn callRomPtr18400(comptime ptr_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(ptr_ref);
    if (!abi.call(decls.func_08018400, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn clearSubstate2AndSpawnProc(
    comptime substate_ref: u32,
    comptime proc_ref: u32,
    comptime ret_addr: u32,
) void {
    abi.fetches(11);
    abi.pushLr();
    const state_ptr = abi.read32(abi.read32(substate_ref));
    abi.write16(state_ptr +% 2, 0);
    rt.r[0] = abi.read32(proc_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn spawnMenuProc31E0Set1E(
    comptime def_ref: u32,
    comptime proc_pool_ref: u32,
    comptime win_ctrl_ref: ?u32,
    comptime ret_addr: u32,
) void {
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0] & 0xFFFF;
    rt.r[0] = abi.read32(def_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, ret_addr)) return;

    abi.fetches(if (win_ctrl_ref != null) 20 else 13);
    const slot_off = @as(u32, @bitCast(abi.signExtend8(@truncate(rt.r[0])))) * 96;
    const proc_addr = abi.read32(proc_pool_ref) +% slot_off;
    abi.write16(proc_addr +% 0x1E, @truncate(rt.r[4]));
    if (win_ctrl_ref) |win_ref| {
        const reg_addr = abi.read32(win_ref);
        abi.write8(reg_addr, @truncate((abi.read8(reg_addr) & 0x3F) | 0x80));
    }

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn spawnMenuProc320CSet1E(comptime def_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0] & 0xFFFF;
    rt.r[0] = abi.read32(def_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, ret_addr)) return;

    abi.fetches(6);
    abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[4]));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Decode a packed 5-bit value at `base + table_off + row_offsets[row] + col`.
pub fn calcPackedEntryAddr(base: u32, row_table_off: u32, data_off: u32, row_offset: u16, col: u32) u32 {
    _ = row_table_off;
    return base +% data_off +% row_offset +% col;
}

/// Spawn `0x080036BC` intro proc and write mode word `[state+0x42]` (`0x080036A4`).
pub fn func_080036A4() callconv(.c) void {
    if (!abi.enter(0x080036A4)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x080036BC);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x080036AF)) return;
    abi.fetches(9);
    const dst = abi.read32(abi.read32(0x080036C0)) +% 0x42;
    abi.write16(dst, @truncate(abi.read32(0x080036C4)));
    abi.popReturn();
}

/// Set flag bit `0x8` in menu display control and upload tile strip via `0x08011330` (`0x080036C8`).
pub fn func_080036C8() callconv(.c) void {
    if (!abi.enter(0x080036C8)) return;
    abi.fetches(15);
    abi.pushLr();
    const reg_ptr = abi.read32(abi.read32(0x080036E8));
    abi.write16(reg_ptr, abi.read16(reg_ptr) | 8);
    rt.r[0] = abi.read32(0x080036EC);
    abi.setRegNz(&rt.r[1], 0xE8 << 2);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, 0x080036E3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Run menu controller step `0x0800378C` (`0x08003708`).
pub fn func_08003708() callconv(.c) void {
    if (!abi.enter(0x08003708)) return;
    callVoidFn(decls.func_0800378C, 0x0800370F);
}

/// Spawn `0x08003774` menu proc (`0x08003764`).
pub fn func_08003764() callconv(.c) void {
    if (!abi.enter(0x08003764)) return;
    spawnProcZero(0x08003774, 0x0800376F);
}

/// Spawn `0x08003788` menu proc (`0x08003778`).
pub fn func_08003778() callconv(.c) void {
    if (!abi.enter(0x08003778)) return;
    spawnProcZero(0x08003788, 0x08003783);
}

/// Enter top-level game mode `1` via `0x080001FC` (`0x08004588`).
pub fn func_08004588() callconv(.c) void {
    if (!abi.enter(0x08004588)) return;
    callSingleU32(decls.func_080001FC, 1, 6, 0x08004591, false);
}

/// Enter top-level game mode `4` via `0x080001FC` (`0x08004644`).
pub fn func_08004644() callconv(.c) void {
    if (!abi.enter(0x08004644)) return;
    callSingleU32(decls.func_080001FC, 4, 6, 0x0800464D, false);
}

/// Run title/boot transition `0x08002DEC` (`0x080046D4`).
pub fn func_080046D4() callconv(.c) void {
    if (!abi.enter(0x080046D4)) return;
    callVoidFn(decls.func_08002DEC, 0x080046DB);
}

/// Play/switch menu BGM/state track `7` via `0x0800473C` (`0x0800476C`).
pub fn func_0800476C() callconv(.c) void {
    if (!abi.enter(0x0800476C)) return;
    callSingleU32(decls.func_0800473C, 7, 6, 0x08004775, false);
}

/// Play/switch menu BGM/state track `1` via `0x0800473C` (`0x08004778`).
pub fn func_08004778() callconv(.c) void {
    if (!abi.enter(0x08004778)) return;
    callSingleU32(decls.func_0800473C, 1, 6, 0x08004781, false);
}

/// Play/switch menu BGM/state track `3` via `0x0800473C` (`0x08004784`).
pub fn func_08004784() callconv(.c) void {
    if (!abi.enter(0x08004784)) return;
    callSingleU32(decls.func_0800473C, 3, 6, 0x0800478D, false);
}

/// Play/switch menu BGM/state track `4` via `0x0800473C` (`0x08004790`).
pub fn func_08004790() callconv(.c) void {
    if (!abi.enter(0x08004790)) return;
    callSingleU32(decls.func_0800473C, 4, 6, 0x08004799, false);
}

/// Stop/reset menu BGM/state track (`-1`) via `0x0800473C` (`0x0800479C`).
pub fn func_0800479C() callconv(.c) void {
    if (!abi.enter(0x0800479C)) return;
    callSingleU32(decls.func_0800473C, @bitCast(@as(i32, -1)), 7, 0x080047A7, false);
}

/// Load/resolve menu resource `0x08004844` via `0x08018400` (`0x08004838`).
pub fn func_08004838() callconv(.c) void {
    if (!abi.enter(0x08004838)) return;
    callRomPtr18400(0x08004844, 0x08004841);
}

/// Load/resolve menu resource `0x08004854` via `0x08018400` (`0x08004848`).
pub fn func_08004848() callconv(.c) void {
    if (!abi.enter(0x08004848)) return;
    callRomPtr18400(0x08004854, 0x08004851);
}

/// Load/resolve menu resource `0x08004864` via `0x08018400` (`0x08004858`).
pub fn func_08004858() callconv(.c) void {
    if (!abi.enter(0x08004858)) return;
    callRomPtr18400(0x08004864, 0x08004861);
}

/// Load/resolve menu resource `0x08004874` via `0x08018400` (`0x08004868`).
pub fn func_08004868() callconv(.c) void {
    if (!abi.enter(0x08004868)) return;
    callRomPtr18400(0x08004874, 0x08004871);
}

/// Load/resolve menu resource `0x08004884` via `0x08018400` (`0x08004878`).
pub fn func_08004878() callconv(.c) void {
    if (!abi.enter(0x08004878)) return;
    callRomPtr18400(0x08004884, 0x08004881);
}

/// Enqueue menu dialog `0x08004B7C` with mode `0` via `0x08004B8C` (`0x08004B6C`).
pub fn func_08004B6C() callconv(.c) void {
    if (!abi.enter(0x08004B6C)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[2] = abi.read32(0x08004B7C);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_08004B8C, 0x08004B77)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Enqueue menu dialog with explicit mode `2` via `0x08004B8C` (`0x08004B80`).
pub fn func_08004B80() callconv(.c) void {
    if (!abi.enter(0x08004B80)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[3], 2);
    if (!abi.call(decls.func_08004B8C, 0x08004B89)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Poll menu input / frame sync helper `0x0807A830` (`0x08004BE8`).
pub fn func_08004BE8() callconv(.c) void {
    if (!abi.enter(0x08004BE8)) return;
    callVoidFn(decls.func_0807A830, 0x08004BEF);
}

/// Play menu sound effect `0x85` via `0x0803D880` (`0x08004F8C`).
pub fn func_08004F8C() callconv(.c) void {
    if (!abi.enter(0x08004F8C)) return;
    callSingleU32(decls.func_0803D880, 0x85, 6, 0x08004F95, false);
}

/// Play menu sound effect `0x86` via `0x0803D880` (`0x08004F98`).
pub fn func_08004F98() callconv(.c) void {
    if (!abi.enter(0x08004F98)) return;
    callSingleU32(decls.func_0803D880, 0x86, 6, 0x08004FA1, false);
}

/// Check save/campaign slot `0` via `0x080051C0` (`0x08005284`).
pub fn func_08005284() callconv(.c) void {
    if (!abi.enter(0x08005284)) return;
    callSingleU32(decls.func_080051C0, 0, 6, 0x0800528D, true);
}

/// Check save/campaign slot `1` via `0x080051C0` (`0x08005290`).
pub fn func_08005290() callconv(.c) void {
    if (!abi.enter(0x08005290)) return;
    callSingleU32(decls.func_080051C0, 1, 6, 0x08005299, true);
}

/// Check save/campaign slot `2` via `0x080051C0` (`0x0800529C`).
pub fn func_0800529C() callconv(.c) void {
    if (!abi.enter(0x0800529C)) return;
    callSingleU32(decls.func_080051C0, 2, 6, 0x080052A5, true);
}

/// Clear menu substate `+2` (`0x080052C0`) and spawn proc `0x080052C4` (`0x080052A8`).
pub fn func_080052A8() callconv(.c) void {
    if (!abi.enter(0x080052A8)) return;
    clearSubstate2AndSpawnProc(0x080052C0, 0x080052C4, 0x080052BB);
}

/// Clear menu substate `+2` (`0x080052F8`) and spawn proc `0x080052FC` (`0x080052E0`).
pub fn func_080052E0() callconv(.c) void {
    if (!abi.enter(0x080052E0)) return;
    clearSubstate2AndSpawnProc(0x080052F8, 0x080052FC, 0x080052F3);
}

/// Spawn proc `0x08007858` and record slot handle at `[state+0x6B]` (`0x08007840`).
pub fn func_08007840() callconv(.c) void {
    if (!abi.enter(0x08007840)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08007858);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, 0x0800784B)) return;
    abi.fetches(8);
    const dst = abi.read32(abi.read32(0x0800785C)) +% 0x6B;
    abi.write8(dst, @truncate(rt.r[0]));
    abi.popReturn();
}

/// Resolve 5-bit tile/menu byte `(col=r0, row=r1)` and dispatch via `0x0800C2C8` (`0x0800C314`).
pub fn func_0800C314() callconv(.c) void {
    if (!abi.enter(0x0800C314)) return;
    abi.fetches(19);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const base = abi.read32(abi.read32(0x0800C33C));
    const row_tbl_off = abi.read32(0x0800C340);
    const data_off = abi.read32(0x0800C344);
    const row_off = abi.read16(base +% row_tbl_off +% (rt.r[1] << 1));
    const byte_addr = calcPackedEntryAddr(base, row_tbl_off, data_off, row_off, rt.r[0]);
    abi.setRegNz(&rt.r[0], abi.read8(byte_addr) & 0x1F);
    if (!abi.call(decls.func_0800C2C8, 0x0800C337)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnValue();
}

/// Reset script/menu buffer via `0x0807A8A0` and cache `r0` at `0x0800F0B8` (`0x0800F098`).
pub fn func_0800F098() callconv(.c) void {
    if (!abi.enter(0x0800F098)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[0] = abi.read32(0x0800F0B0);
    rt.r[1] = abi.read32(0x0800F0B4);
    abi.setRegNz(&rt.r[2], 0x3D);
    if (!abi.call(decls.func_0807A8A0, 0x0800F0A7)) return;

    abi.fetches(7);
    abi.write32(abi.read32(0x0800F0B8), rt.r[4]);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down audio/interrupt state via `0x08010B44` and clear `arg->+8` (`0x0800F628`).
pub fn func_0800F628() callconv(.c) void {
    if (!abi.enter(0x0800F628)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    if (!abi.call(decls.func_08010B44, 0x0800F631)) return;

    abi.fetches(7);
    abi.write32(rt.r[4] +% 8, 0);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn `0x0800F664` indexed proc storing `u16(r0)` at `+0x1E` (`0x0800F63C`).
pub fn func_0800F63C() callconv(.c) void {
    if (!abi.enter(0x0800F63C)) return;
    spawnMenuProc31E0Set1E(0x0800F664, 0x0800F668, null, 0x0800F64D);
}

/// Spawn `0x0800F694` indexed proc storing `u16(r0)` at `+0x1E` (`0x0800F66C`).
pub fn func_0800F66C() callconv(.c) void {
    if (!abi.enter(0x0800F66C)) return;
    spawnMenuProc31E0Set1E(0x0800F694, 0x0800F698, null, 0x0800F67D);
}

/// Spawn `0x0800F6D0` indexed proc storing `u16(r0)` at `+0x1E` and setting bit `0x80` (`0x0800F69C`).
pub fn func_0800F69C() callconv(.c) void {
    if (!abi.enter(0x0800F69C)) return;
    spawnMenuProc31E0Set1E(0x0800F6D0, 0x0800F6D4, 0x0800F6D8, 0x0800F6AD);
}

/// Spawn `0x0800F710` indexed proc storing `u16(r0)` at `+0x1E` and setting bit `0x80` (`0x0800F6DC`).
pub fn func_0800F6DC() callconv(.c) void {
    if (!abi.enter(0x0800F6DC)) return;
    spawnMenuProc31E0Set1E(0x0800F710, 0x0800F714, 0x0800F718, 0x0800F6ED);
}

/// Spawn `0x0800F734` proc storing `u16(r0)` at `+0x1E` (`0x0800F71C`).
pub fn func_0800F71C() callconv(.c) void {
    if (!abi.enter(0x0800F71C)) return;
    spawnMenuProc320CSet1E(0x0800F734, 0x0800F72D);
}

/// Spawn `0x0800F750` proc storing `u16(r0)` at `+0x1E` (`0x0800F738`).
pub fn func_0800F738() callconv(.c) void {
    if (!abi.enter(0x0800F738)) return;
    spawnMenuProc320CSet1E(0x0800F750, 0x0800F749);
}

/// Start top-level game state `1` via `0x080001FC` (`0x08000280`).
pub fn func_08000280() callconv(.c) void {
    if (!abi.enter(0x08000280)) return;
    callSingleU32(decls.func_080001FC, 1, 6, 0x08000289, false);
}

/// Set flag `[0x08000C70] = 1`, spawn `0x08000C74` proc storing `u16(r0)` at `+0x1E` (`0x08000C54`).
pub fn func_08000C54() callconv(.c) void {
    if (!abi.enter(0x08000C54)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    abi.write32(abi.read32(0x08000C70), 1);
    rt.r[0] = abi.read32(0x08000C74);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08000C67)) return;

    abi.fetches(6);
    abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[4]));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Look up 16-bit table entry at `(col=r0, row=r1)` and dispatch `0x08001304` (`0x080012D0`).
pub fn func_080012D0() callconv(.c) void {
    if (!abi.enter(0x080012D0)) return;
    abi.fetches(18);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const base = abi.read32(abi.read32(0x080012F8));
    const row_off = abi.read16(base +% abi.read32(0x080012FC) +% (rt.r[1] << 1));
    const idx = (row_off +% rt.r[0]) << 1;
    rt.r[2] = abi.read16(base +% abi.read32(0x08001300) +% idx);
    if (!abi.call(decls.func_08001304, 0x080012F1)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnValue();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08000280, .{ .name = "func_08000280", .linkage = .strong });
        @export(&func_08000C54, .{ .name = "func_08000C54", .linkage = .strong });
        @export(&func_080012D0, .{ .name = "func_080012D0", .linkage = .strong });
        @export(&func_080036A4, .{ .name = "func_080036A4", .linkage = .strong });
        @export(&func_080036C8, .{ .name = "func_080036C8", .linkage = .strong });
        @export(&func_08003708, .{ .name = "func_08003708", .linkage = .strong });
        @export(&func_08003764, .{ .name = "func_08003764", .linkage = .strong });
        @export(&func_08003778, .{ .name = "func_08003778", .linkage = .strong });
        @export(&func_08004588, .{ .name = "func_08004588", .linkage = .strong });
        @export(&func_08004644, .{ .name = "func_08004644", .linkage = .strong });
        @export(&func_080046D4, .{ .name = "func_080046D4", .linkage = .strong });
        @export(&func_0800476C, .{ .name = "func_0800476C", .linkage = .strong });
        @export(&func_08004778, .{ .name = "func_08004778", .linkage = .strong });
        @export(&func_08004784, .{ .name = "func_08004784", .linkage = .strong });
        @export(&func_08004790, .{ .name = "func_08004790", .linkage = .strong });
        @export(&func_0800479C, .{ .name = "func_0800479C", .linkage = .strong });
        @export(&func_08004838, .{ .name = "func_08004838", .linkage = .strong });
        @export(&func_08004848, .{ .name = "func_08004848", .linkage = .strong });
        @export(&func_08004858, .{ .name = "func_08004858", .linkage = .strong });
        @export(&func_08004868, .{ .name = "func_08004868", .linkage = .strong });
        @export(&func_08004878, .{ .name = "func_08004878", .linkage = .strong });
        @export(&func_08004B6C, .{ .name = "func_08004B6C", .linkage = .strong });
        @export(&func_08004B80, .{ .name = "func_08004B80", .linkage = .strong });
        @export(&func_08004BE8, .{ .name = "func_08004BE8", .linkage = .strong });
        @export(&func_08004F8C, .{ .name = "func_08004F8C", .linkage = .strong });
        @export(&func_08004F98, .{ .name = "func_08004F98", .linkage = .strong });
        @export(&func_08005284, .{ .name = "func_08005284", .linkage = .strong });
        @export(&func_08005290, .{ .name = "func_08005290", .linkage = .strong });
        @export(&func_0800529C, .{ .name = "func_0800529C", .linkage = .strong });
        @export(&func_080052A8, .{ .name = "func_080052A8", .linkage = .strong });
        @export(&func_080052E0, .{ .name = "func_080052E0", .linkage = .strong });
        @export(&func_08007840, .{ .name = "func_08007840", .linkage = .strong });
        @export(&func_0800C314, .{ .name = "func_0800C314", .linkage = .strong });
        @export(&func_0800F098, .{ .name = "func_0800F098", .linkage = .strong });
        @export(&func_0800F628, .{ .name = "func_0800F628", .linkage = .strong });
        @export(&func_0800F63C, .{ .name = "func_0800F63C", .linkage = .strong });
        @export(&func_0800F66C, .{ .name = "func_0800F66C", .linkage = .strong });
        @export(&func_0800F69C, .{ .name = "func_0800F69C", .linkage = .strong });
        @export(&func_0800F6DC, .{ .name = "func_0800F6DC", .linkage = .strong });
        @export(&func_0800F71C, .{ .name = "func_0800F71C", .linkage = .strong });
        @export(&func_0800F738, .{ .name = "func_0800F738", .linkage = .strong });
    }
}

test "calcPackedEntryAddr adds base, data offset, row offset, and column" {
    try std.testing.expectEqual(@as(u32, 0x0200_1023), calcPackedEntryAddr(0x0200_0000, 0x100, 0x1000, 0x20, 3));
}
