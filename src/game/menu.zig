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

fn callMenu19608Then45CC(comptime ret1: u32, comptime ret2: u32) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019608, ret1)) return;
    abi.fetches(4);
    if (!abi.call(func_080045CC, ret2)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn callMenu19608Spawn02E4(comptime def_ref: u32, comptime r0_ret: u32, comptime r1_ret: u32, comptime r2_ret: u32) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019608, r0_ret)) return;
    abi.fetches(6);
    rt.r[0] = abi.read32(def_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, r1_ret)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080002E4, r2_ret)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn finishWithMenu01FC(comptime ret_addr: u32) void {
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 1);
    if (!abi.call(decls.func_080001FC, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

pub fn func_08002CC0() callconv(.c) void {
    if (!abi.enter(0x08002CC0)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08002AF0, 0x08002CC7)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08002A9C, 0x08002CCB)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08002BE0, 0x08002CCF)) return;
    abi.fetches(4);
    abi.popReturn();
}

pub fn func_080034AC() callconv(.c) void {
    if (!abi.enter(0x080034AC)) return;
    abi.fetches(12);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[1] = 0x83 << 3;
    rt.r[2] = abi.read32(0x080034E4);
    abi.setRegNz(&rt.r[4], @as(u32, 0xD0) << 8);
    abi.setRegNz(&rt.r[0], 0x18);
    rt.r[3] = rt.r[4];
    if (!abi.call(decls.func_0801B888, 0x080034C1)) return;

    abi.fetches(9);
    rt.r[1] = 0x85 << 3;
    rt.r[2] = abi.read32(0x080034E8);
    abi.setRegNz(&rt.r[0], 0x18);
    rt.r[3] = rt.r[4];
    if (!abi.call(decls.func_0801B888, 0x080034CF)) return;

    abi.fetches(9);
    rt.r[1] = 0x89 << 3;
    rt.r[2] = abi.read32(0x080034EC);
    abi.setRegNz(&rt.r[0], 0x17);
    rt.r[3] = rt.r[4];
    if (!abi.call(decls.func_0801B888, 0x080034DD)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

pub fn func_08004594() callconv(.c) void {
    if (!abi.enter(0x08004594)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0x66);
    if (!abi.call(decls.func_0803D880, 0x0800459D)) return;
    finishWithMenu01FC(0x080045A3);
}

pub fn func_080045AC() callconv(.c) void {
    if (!abi.enter(0x080045AC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019608, 0x080045B3)) return;
    finishWithMenu01FC(0x080045B9);
}

pub fn func_080045BC() callconv(.c) void {
    if (!abi.enter(0x080045BC)) return;
    callMenu19608Then45CC(0x080045C3, 0x080045C7);
}

pub fn func_080045CC() callconv(.c) void {
    if (!abi.enter(0x080045CC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019A6C, 0x080045D3)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0x66);
    if (!abi.call(decls.func_0803D880, 0x080045D9)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(abi.read32(0x080045E8));
    abi.setRegNz(&rt.r[1], 3);
    abi.write16(rt.r[0] +% 4, 3);
    if (!abi.call(decls.func_08004994, 0x080045E5)) return;
    abi.fetches(4);
    abi.popReturn();
}

pub fn func_08004608() callconv(.c) void {
    if (!abi.enter(0x08004608)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0800FC58, 0x0800460F)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(abi.read32(0x08004620)) +% 0x9C;
    abi.setRegNz(&rt.r[1], 8);
    if (!abi.call(decls.func_08048AE8, 0x0800461B)) return;
    abi.fetches(4);
    abi.popReturn();
}

pub fn func_08004624() callconv(.c) void {
    if (!abi.enter(0x08004624)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0xD8);
    if (!abi.call(decls.func_0803D8C8, 0x0800462D)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 1);
    if (!abi.call(decls.func_080001FC, 0x08004633)) return;
    abi.fetches(9);
    rt.r[0] = abi.read32(abi.read32(0x08004640)) +% 0xAE;
    abi.setRegNz(&rt.r[1], 0);
    abi.write8(rt.r[0], 0);
    abi.popReturn();
}

pub fn func_08004650() callconv(.c) void {
    if (!abi.enter(0x08004650)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019608, 0x08004657)) return;
    abi.fetches(6);
    rt.r[0] = abi.read32(0x08004664);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x0800465F)) return;
    abi.fetches(4);
    abi.popReturn();
}

pub fn func_0800472C() callconv(.c) void {
    if (!abi.enter(0x0800472C)) return;
    callMenu19608Then45CC(0x08004733, 0x08004737);
}

pub fn func_080047AC() callconv(.c) void {
    if (!abi.enter(0x080047AC)) return;
    callMenu19608Spawn02E4(0x080047C4, 0x080047B3, 0x080047BB, 0x080047BF);
}

pub fn func_080047C8() callconv(.c) void {
    if (!abi.enter(0x080047C8)) return;
    callMenu19608Spawn02E4(0x080047E0, 0x080047CF, 0x080047D7, 0x080047DB);
}

pub fn func_080047E4() callconv(.c) void {
    if (!abi.enter(0x080047E4)) return;
    callMenu19608Spawn02E4(0x080047FC, 0x080047EB, 0x080047F3, 0x080047F7);
}

pub fn func_08004800() callconv(.c) void {
    if (!abi.enter(0x08004800)) return;
    callMenu19608Spawn02E4(0x08004818, 0x08004807, 0x0800480F, 0x08004813);
}

pub fn func_0800481C() callconv(.c) void {
    if (!abi.enter(0x0800481C)) return;
    callMenu19608Spawn02E4(0x08004834, 0x08004823, 0x0800482B, 0x0800482F);
}

pub fn func_08004930() callconv(.c) void {
    if (!abi.enter(0x08004930)) return;
    abi.fetches(5);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    if (!abi.call(decls.func_08003580, 0x08004937)) return;

    abi.fetches(11);
    rt.r[4] = abi.read32(0x08004960);
    abi.write16(abi.read32(rt.r[4]) +% 2, 2);
    rt.r[0] = abi.read32(0x08004964);
    rt.r[1] = abi.read32(0x08004968);
    abi.setRegNz(&rt.r[2], 0x80);
    if (!abi.call(decls.func_0800FFA8, 0x08004949)) return;

    abi.fetches(13);
    rt.r[1] = abi.read32(rt.r[4]);
    abi.write16(rt.r[1] +% 0x46, 0x15);
    rt.r[1] +%= 0x48;
    abi.setRegNz(&rt.r[0], 0x18);
    abi.write16(rt.r[1], 0x18);
    rt.r[2] = abi.read32(rt.r[4]) +% 0x46;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

pub fn func_08004B08() callconv(.c) void {
    if (!abi.enter(0x08004B08)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0800199C, 0x08004B0F)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08002E64, 0x08004B13)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x08004B1C);
    if (!abi.call(decls.func_08018400, 0x08004B19)) return;
    abi.fetches(4);
    abi.popReturn();
}

pub fn func_08004F0C() callconv(.c) void {
    if (!abi.enter(0x08004F0C)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019608, 0x08004F13)) return;
    abi.fetches(6);
    rt.r[0] = abi.read32(0x08004F2C);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08004F1B)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(abi.read32(0x08004F30));
    abi.setRegNz(&rt.r[1], 7);
    abi.write16(rt.r[0] +% 2, 7);
    if (!abi.call(decls.func_08021DF8, 0x08004F27)) return;
    abi.fetches(4);
    abi.popReturn();
}

pub fn func_080052C8() callconv(.c) void {
    if (!abi.enter(0x080052C8)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0x70);
    if (!abi.call(decls.func_0801B8D4, 0x080052D1)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08019A6C, 0x080052D5)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0x66);
    if (!abi.call(decls.func_0803D880, 0x080052DB)) return;
    abi.fetches(4);
    abi.popReturn();
}

pub fn func_0800E738() callconv(.c) void {
    if (!abi.enter(0x0800E738)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 8;
    abi.write32(rt.r[13], rt.r[4]);
    abi.write32(rt.r[13] +% 4, rt.r[5]);
    rt.r[4] = rt.r[0];
    rt.r[5] = rt.r[1];
    if (!abi.call(decls.func_08000D68, 0x0800E743)) return;
    abi.fetches(6);
    rt.r[0] = rt.r[4];
    rt.r[1] = rt.r[5];
    if (!abi.call(func_080012D0, 0x0800E74B)) return;
    abi.fetches(7);
    rt.r[2] = rt.r[0];
    rt.r[0] = rt.r[4];
    rt.r[1] = rt.r[5];
    if (!abi.call(decls.func_08000D68, 0x0800E755)) return;
    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[5] = abi.read32(rt.r[13] +% 4);
    rt.r[13] +%= 8;
    abi.popReturn();
}

/// Upload 4 menu unit icon tiles `0..3` via `0x0802FC70` and palette slice `(read8([0x08002AE8]+4)<<5)+[0x08002AEC]` at `0x280` (`0x08002A9C`).
pub fn func_08002A9C() callconv(.c) void {
    if (!abi.enter(0x08002A9C)) return;
    abi.fetches(7);
    abi.pushLr();
    const entries = [_]struct { ref: u32, ret: u32 }{
        .{ .ref = 0x08002AD8, .ret = 0x08002AA7 },
        .{ .ref = 0x08002ADC, .ret = 0x08002AAF },
        .{ .ref = 0x08002AE0, .ret = 0x08002AB7 },
        .{ .ref = 0x08002AE4, .ret = 0x08002ABF },
    };
    inline for (entries, 0..) |ent, idx| {
        if (idx > 0) abi.fetches(6);
        rt.r[0] = abi.read32(ent.ref);
        abi.setRegNz(&rt.r[1], @intCast(idx));
        if (!abi.call(decls.func_0802FC70, ent.ret)) return;
    }

    abi.fetches(12);
    const pal_idx = abi.read8(abi.read32(0x08002AE8) +% 4);
    rt.r[0] = (@as(u32, pal_idx) << 5) +% abi.read32(0x08002AEC);
    abi.setRegNz(&rt.r[1], @as(u32, 0xA0) << 2);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, 0x08002AD3)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Upload selected menu faction palette and 4 menu UI palette banks `[0x08002B4C]` via `0x08011330` (`0x08002AF0`).
pub fn func_08002AF0() callconv(.c) void {
    if (!abi.enter(0x08002AF0)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const pal_idx = abi.read8(abi.read32(0x08002B44) +% 4);
    rt.r[0] = (@as(u32, pal_idx) << 5) +% abi.read32(0x08002B48);
    abi.setRegNz(&rt.r[1], @as(u32, 0xA0) << 2);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, 0x08002B07)) return;

    const base = abi.read32(0x08002B4C);
    const slots = [_]struct { off: u32, dst: u32, ret: u32 }{
        .{ .off = 0x00, .dst = @as(u32, 0xB8) << 2, .ret = 0x08002B15 },
        .{ .off = 0x20, .dst = @as(u32, 0xB0) << 2, .ret = 0x08002B23 },
        .{ .off = 0x40, .dst = @as(u32, 0xF0) << 2, .ret = 0x08002B31 },
        .{ .off = 0x60, .dst = @as(u32, 0xF8) << 2, .ret = 0x08002B3F },
    };
    inline for (slots) |s| {
        abi.fetches(9);
        rt.r[4] = base +% s.off;
        rt.r[0] = rt.r[4];
        abi.setRegNz(&rt.r[1], s.dst);
        abi.setRegNz(&rt.r[2], 0x20);
        if (!abi.call(decls.func_08011330, s.ret)) return;
    }

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Dispatch 4 menu icon rows `0..3` via `0x08002EE0(idx, r0, r1)` (`0x08002EAC`).
pub fn func_08002EAC() callconv(.c) void {
    if (!abi.enter(0x08002EAC)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const a0 = rt.r[0];
    const a1 = rt.r[1];
    rt.r[4] = a0;
    rt.r[5] = a1;
    const rets = [_]u32{ 0x08002EBD, 0x08002EC7, 0x08002ED1, 0x08002EDB };
    inline for (rets, 0..) |ret_addr, i| {
        if (i > 0) abi.fetches(7);
        abi.setRegNz(&rt.r[0], @intCast(i));
        abi.copyRegFlags(&rt.r[1], a0);
        abi.copyRegFlags(&rt.r[2], a1);
        if (!abi.call(decls.func_08002EE0, ret_addr)) return;
    }

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// DMA 3 menu icon blocks `0x80` bytes via `0x0800FFA8` and upload palette `[0x080035C8]` at `0x3A0` (`0x08003580`).
pub fn func_08003580() callconv(.c) void {
    if (!abi.enter(0x08003580)) return;
    abi.fetches(8);
    abi.pushLr();
    const pairs = [_]struct { src: u32, dst: u32, ret: u32 }{
        .{ .src = 0x080035B0, .dst = 0x080035B4, .ret = 0x0800358D },
        .{ .src = 0x080035B8, .dst = 0x080035BC, .ret = 0x08003597 },
        .{ .src = 0x080035C0, .dst = 0x080035C4, .ret = 0x080035A1 },
    };
    inline for (pairs, 0..) |p, idx| {
        if (idx > 0) abi.fetches(7);
        rt.r[0] = abi.read32(p.src);
        rt.r[1] = abi.read32(p.dst);
        abi.setRegNz(&rt.r[2], 0x80);
        if (!abi.call(decls.func_0800FFA8, p.ret)) return;
    }

    abi.fetches(8);
    rt.r[0] = abi.read32(0x080035C8);
    abi.setRegNz(&rt.r[1], @as(u32, 0xE8) << 2);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, 0x080035AD)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Configure menu PPU display/window/blend registers after `0x080104B0` (`0x0800378C`).
pub fn func_0800378C() callconv(.c) void {
    if (!abi.enter(0x0800378C)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080104B0, 0x08003793)) return;

    abi.fetches(58);
    const disp = abi.read32(0x08003804);
    const mask_fe: u8 = @truncate(0 -% @as(u32, 2));
    abi.write8(disp, ((abi.read8(disp) | 0xC0) & mask_fe) | 0x1E);
    const mask_lo: u8 = @truncate((((0 -% @as(u32, 3)) -% 2) -% 4) -% 8);
    abi.write8(disp +% 1, abi.read8(disp +% 1) & mask_fe & mask_lo);
    abi.write16(abi.read32(0x08003808), 0);
    abi.write16(abi.read32(0x0800380C), 0x10);
    abi.write16(abi.read32(0x08003810), 0);
    const win = abi.read32(0x08003814);
    const w_mask: u8 = @truncate((0 -% @as(u32, 0x21)) & (0 -% @as(u32, 0x41)));
    abi.write8(win +% 1, abi.read8(win +% 1) & w_mask);
    abi.write8(abi.read32(0x08003818), 0);
    abi.write8(abi.read32(0x0800381C), 0);
    abi.write8(abi.read32(0x08003820), 0xA0);
    abi.write8(abi.read32(0x08003824), 0xA0);
    abi.popReturn();
}

/// Tear down tactical submenus and reload main menu icon palettes via `0x08002AF0` (`0x080045EC`).
pub fn func_080045EC() callconv(.c) void {
    if (!abi.enter(0x080045EC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08020D6C, 0x080045F3)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080381C4, 0x080045F7)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08021DF8, 0x080045FB)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080226B8, 0x080045FF)) return;
    abi.fetches(4);
    if (!abi.call(func_08002AF0, 0x08004603)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Open menu panel `6` (`0x080001FC`), spawn `[0x0800471C]`, DMA `[0x08004720]`, and init `[0x08004728]` coords `(0x57, 0x10)` (`0x080046E0`).
pub fn func_080046E0() callconv(.c) void {
    if (!abi.enter(0x080046E0)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019A1C, 0x080046E7)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08019608, 0x080046EB)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 6);
    if (!abi.call(decls.func_080001FC, 0x080046F1)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x0800471C);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x080046F9)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08004720);
    rt.r[1] = abi.read32(0x08004724);
    abi.setRegNz(&rt.r[2], 0x100);
    if (!abi.call(decls.func_0800FFA8, 0x08004705)) return;

    abi.fetches(13);
    const st = abi.read32(abi.read32(0x08004728));
    abi.write16(st +% 0x46, 0x57);
    abi.write16(st +% 0x48, 0x10);
    abi.popReturn();
}

/// Reset field UI, dispatch `0x080039F8(r0)` -> `0x08002B50` -> `0x08021DF8`, and set bit `0x1000` in `*[0x08004768]` (`0x0800473C`).
pub fn func_0800473C() callconv(.c) void {
    if (!abi.enter(0x0800473C)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const arg0 = rt.r[0];
    rt.r[4] = arg0;
    if (!abi.call(decls.func_08019608, 0x08004745)) return;

    abi.fetches(5);
    abi.copyRegFlags(&rt.r[0], arg0);
    if (!abi.call(decls.func_080039F8, 0x0800474B)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08002B50, 0x0800474F)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08021DF8, 0x08004753)) return;

    abi.fetches(13);
    const st = abi.read32(abi.read32(0x08004768));
    abi.write16(st, abi.read16(st) | 0x1000);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Enter map/field setup: `0x08019A1C`, `0x08019608`, `0x08021DF8`, `0x080195E8([0x08004990], 2, 3, 0)`, `0x08004930` (`0x0800496C`).
pub fn func_0800496C() callconv(.c) void {
    if (!abi.enter(0x0800496C)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019A1C, 0x08004973)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08019608, 0x08004977)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08021DF8, 0x0800497B)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08004990);
    abi.setRegNz(&rt.r[1], 2);
    abi.setRegNz(&rt.r[2], 3);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_080195E8, 0x08004987)) return;

    abi.fetches(4);
    if (!abi.call(func_08004930, 0x0800498B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Initialize menu prompt workspace `[0x080049E0]`, DMA UI tiles, reset palette `0x70`, and sync `0x0802055C` (`0x08004994`).
pub fn func_08004994() callconv(.c) void {
    if (!abi.enter(0x08004994)) return;
    abi.fetches(12);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const ctx_ptr = abi.read32(0x080049E0);
    rt.r[4] = ctx_ptr;
    const ctx0 = abi.read32(ctx_ptr);
    abi.write8(ctx0 +% 6, 0);
    abi.write16(ctx0 +% 2, 1);
    if (!abi.call(decls.func_080034F0, 0x080049A9)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x080049E4);
    rt.r[1] = abi.read32(0x080049E8);
    abi.setRegNz(&rt.r[2], 0x80);
    if (!abi.call(decls.func_0800FFA8, 0x080049B3)) return;

    abi.fetches(13);
    const ctx1 = abi.read32(ctx_ptr);
    abi.write16(ctx1 +% 0x46, 0x15);
    abi.write16(ctx1 +% 0x48, 0x10);
    abi.setRegNz(&rt.r[0], 0x70);
    if (!abi.call(decls.func_0801B8D4, 0x080049C9)) return;

    abi.fetches(6);
    abi.setRegNz(&rt.r[0], 0x10);
    abi.setRegNz(&rt.r[1], 0x10);
    if (!abi.call(decls.func_0802055C, 0x080049D1)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_0800199C, 0x080049D5)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080036F0, 0x080049D9)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Fill dual `(0, 0xE, 0x1E)` tilemap boxes (`0x14` tall) via `0x08010C70` and flush BG `0x08011804`/`0x08011824` (`0x08004F44`).
pub fn func_08004F44() callconv(.c) void {
    if (!abi.enter(0x08004F44)) return;
    abi.fetches(15);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    rt.r[4] = 0x14;
    abi.write32(rt.r[13], 0x14);
    abi.write32(rt.r[13] +% 4, 0x174);
    rt.r[0] = abi.read32(0x08004F80);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0xE);
    abi.setRegNz(&rt.r[3], 0x1E);
    if (!abi.call(decls.func_08010C70, 0x08004F5F)) return;

    abi.fetches(11);
    abi.write32(rt.r[13], 0x14);
    abi.write32(rt.r[13] +% 4, abi.read32(0x08004F88));
    rt.r[0] = abi.read32(0x08004F84);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0xE);
    abi.setRegNz(&rt.r[3], 0x1E);
    if (!abi.call(decls.func_08010C70, 0x08004F71)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08011804, 0x08004F75)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011824, 0x08004F79)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// DMA 6 menu graphic/tile blocks `[0x08005764..0x08005790]` via `0x0800FFA8` (`0x08005720`).
pub fn func_08005720() callconv(.c) void {
    if (!abi.enter(0x08005720)) return;
    abi.fetches(8);
    abi.pushLr();
    const xfers = [_]struct { src: u32, dst: u32, len: u32, ret: u32 }{
        .{ .src = 0x08005764, .dst = 0x08005768, .len = 0x80, .ret = 0x0800572D },
        .{ .src = 0x0800576C, .dst = 0x08005770, .len = 0x80, .ret = 0x08005737 },
        .{ .src = 0x08005774, .dst = 0x08005778, .len = 0x80, .ret = 0x08005741 },
        .{ .src = 0x0800577C, .dst = 0x08005780, .len = 0x80, .ret = 0x0800574B },
        .{ .src = 0x08005784, .dst = 0x08005788, .len = 0x100, .ret = 0x08005757 },
        .{ .src = 0x0800578C, .dst = 0x08005790, .len = 0x40, .ret = 0x08005761 },
    };
    inline for (xfers, 0..) |x, idx| {
        if (idx > 0) abi.fetches(if (x.len >= 0x100) 8 else 7);
        rt.r[0] = abi.read32(x.src);
        rt.r[1] = abi.read32(x.dst);
        abi.setRegNz(&rt.r[2], x.len);
        if (!abi.call(decls.func_0800FFA8, x.ret)) return;
    }

    abi.fetches(4);
    abi.popReturn();
}

/// Open submenu `8`, DMA `[0x08005B3C]`, set `[0x08005B44]` coords `(0x15, 0x10)`, spawn `[0x08005B48]`, close `8` (`0x08005AFC`).
pub fn func_08005AFC() callconv(.c) void {
    if (!abi.enter(0x08005AFC)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 8);
    if (!abi.call(decls.func_080001FC, 0x08005B05)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x08005B3C);
    rt.r[1] = abi.read32(0x08005B40);
    abi.setRegNz(&rt.r[2], 0x80);
    if (!abi.call(decls.func_0800FFA8, 0x08005B0F)) return;

    abi.fetches(13);
    const st = abi.read32(abi.read32(0x08005B44));
    abi.write16(st +% 0x46, 0x15);
    abi.write16(st +% 0x48, 0x10);
    if (!abi.call(decls.func_08019A1C, 0x08005B25)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08019608, 0x08005B29)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x08005B48);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08005B31)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 8);
    if (!abi.call(decls.func_080001FC, 0x08005B37)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Cache 4 mode/faction values `0x080238D0(1..4)` into `*[0x080085A0] + 0x13..0x16` (`0x0800856C`).
pub fn func_0800856C() callconv(.c) void {
    if (!abi.enter(0x0800856C)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const dst_ptr = abi.read32(0x080085A0);
    rt.r[4] = dst_ptr;

    const rets = [_]u32{ 0x08008575, 0x08008581, 0x0800858B, 0x08008595 };
    inline for (rets, 0..) |ret_addr, i| {
        if (i == 0) {
            abi.setRegNz(&rt.r[0], 1);
        } else {
            abi.fetches(if (i == 1) 8 else 7);
            abi.write8(abi.read32(dst_ptr) +% 0x12 +% @as(u32, @intCast(i)), @truncate(rt.r[0]));
            abi.setRegNz(&rt.r[0], @intCast(i + 1));
        }
        if (!abi.call(decls.func_080238D0, ret_addr)) return;
    }

    abi.fetches(7);
    abi.write8(abi.read32(dst_ptr) +% 0x16, @truncate(rt.r[0]));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Accumulate 4 icon tile metrics `0x0800C1BC(0x28, 0x68, 0x48, 0x88)` onto stack scratch and return total (`0x0800C17C`).
pub fn func_0800C17C() callconv(.c) void {
    if (!abi.enter(0x0800C17C)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const out_ptr = rt.r[13] +% 4;
    rt.r[5] = out_ptr;
    const cmds = [_]struct { arg: u32, ret: u32 }{
        .{ .arg = 0x28, .ret = 0x0800C18D },
        .{ .arg = 0x68, .ret = 0x0800C199 },
        .{ .arg = 0x48, .ret = 0x0800C1A5 },
        .{ .arg = 0x88, .ret = 0x0800C1B1 },
    };
    var acc: u32 = 0;
    inline for (cmds, 0..) |c, idx| {
        if (idx > 0) {
            abi.fetches(8);
            acc = if (idx == 1) rt.r[0] else acc +% rt.r[0];
        }
        abi.setRegNz(&rt.r[0], c.arg);
        rt.r[1] = rt.r[13];
        rt.r[2] = out_ptr;
        if (!abi.call(decls.func_0800C1BC, c.ret)) return;
    }

    abi.fetches(8);
    acc +%= rt.r[0];
    abi.copyRegFlags(&rt.r[0], acc);
    rt.r[13] +%= 8;
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
        @export(&func_08002CC0, .{ .name = "func_08002CC0", .linkage = .strong });
        @export(&func_080034AC, .{ .name = "func_080034AC", .linkage = .strong });
        @export(&func_08004594, .{ .name = "func_08004594", .linkage = .strong });
        @export(&func_080045AC, .{ .name = "func_080045AC", .linkage = .strong });
        @export(&func_080045BC, .{ .name = "func_080045BC", .linkage = .strong });
        @export(&func_080045CC, .{ .name = "func_080045CC", .linkage = .strong });
        @export(&func_08004608, .{ .name = "func_08004608", .linkage = .strong });
        @export(&func_08004624, .{ .name = "func_08004624", .linkage = .strong });
        @export(&func_08004650, .{ .name = "func_08004650", .linkage = .strong });
        @export(&func_0800472C, .{ .name = "func_0800472C", .linkage = .strong });
        @export(&func_080047AC, .{ .name = "func_080047AC", .linkage = .strong });
        @export(&func_080047C8, .{ .name = "func_080047C8", .linkage = .strong });
        @export(&func_080047E4, .{ .name = "func_080047E4", .linkage = .strong });
        @export(&func_08004800, .{ .name = "func_08004800", .linkage = .strong });
        @export(&func_0800481C, .{ .name = "func_0800481C", .linkage = .strong });
        @export(&func_08004930, .{ .name = "func_08004930", .linkage = .strong });
        @export(&func_08004B08, .{ .name = "func_08004B08", .linkage = .strong });
        @export(&func_08004F0C, .{ .name = "func_08004F0C", .linkage = .strong });
        @export(&func_080052C8, .{ .name = "func_080052C8", .linkage = .strong });
        @export(&func_0800E738, .{ .name = "func_0800E738", .linkage = .strong });
        @export(&func_08002A9C, .{ .name = "func_08002A9C", .linkage = .strong });
        @export(&func_08002AF0, .{ .name = "func_08002AF0", .linkage = .strong });
        @export(&func_08002EAC, .{ .name = "func_08002EAC", .linkage = .strong });
        @export(&func_08003580, .{ .name = "func_08003580", .linkage = .strong });
        @export(&func_0800378C, .{ .name = "func_0800378C", .linkage = .strong });
        @export(&func_080045EC, .{ .name = "func_080045EC", .linkage = .strong });
        @export(&func_080046E0, .{ .name = "func_080046E0", .linkage = .strong });
        @export(&func_0800473C, .{ .name = "func_0800473C", .linkage = .strong });
        @export(&func_0800496C, .{ .name = "func_0800496C", .linkage = .strong });
        @export(&func_08004994, .{ .name = "func_08004994", .linkage = .strong });
        @export(&func_08004F44, .{ .name = "func_08004F44", .linkage = .strong });
        @export(&func_08005720, .{ .name = "func_08005720", .linkage = .strong });
        @export(&func_08005AFC, .{ .name = "func_08005AFC", .linkage = .strong });
        @export(&func_0800856C, .{ .name = "func_0800856C", .linkage = .strong });
        @export(&func_0800C17C, .{ .name = "func_0800C17C", .linkage = .strong });
    }
}

test "calcPackedEntryAddr adds base, data offset, row offset, and column" {
    try std.testing.expectEqual(@as(u32, 0x0200_1023), calcPackedEntryAddr(0x0200_0000, 0x100, 0x1000, 0x20, 3));
}
