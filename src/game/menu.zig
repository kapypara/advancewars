//! Title screen, menus, sound cues, and pre-battle UI initialization.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const battle = @import("battle.zig");
const bios = @import("bios.zig");
const campaign = @import("campaign.zig");
const clusters_low_2 = @import("clusters_low_2.zig");
const co = @import("co.zig");
const dma = @import("dma.zig");
const hw = @import("hw.zig");
const map = @import("map.zig");
const mem = @import("mem.zig");
const proc = @import("proc.zig");
const sound = @import("sound.zig");
const state = @import("state.zig");
const tail_low = @import("tail_low.zig");
const types = @import("types.zig");
const ui = @import("ui.zig");
const unit = @import("unit.zig");

/// [Phase 4 API — uncalled while func_08018B68 preserves exact loop fetches/flags]
/// Look up `key` in an `0xFF`-terminated array of 8-byte menu guard entries.
pub fn lookupGuardTable(entries: []const [8]u8, key: u8, fallback: u8) u8 {
    for (entries) |entry| {
        if (entry[0] == 0xFF) break;
        if (entry[1] == key) return entry[0];
    }
    return fallback;
}

/// Look up guard byte for `u8(r0)` in `menu_guard` (`0x0300_4280`), defaulting to `[menu_selection]` (`0x08018B68`).
pub fn func_08018B68() callconv(.c) void {
    if (!abi.enter(0x08018B68)) return;
    abi.fetches(11);
    abi.pushLr();
    abi.pushReg(5);
    abi.pushReg(4);

    const key: u8 = @truncate(rt.r[0]);
    rt.r[4] = key;
    rt.r[2] = 0;
    rt.r[3] = types.addr.menu_guard;
    const first = mem.readU8(types.addr.menu_guard);
    rt.r[1] = first;

    var result_addr: u32 = types.addr.menu_selection;
    if (first == 0xFF) {
        rt.cpuSub(null, first, 0xFF, true);
        abi.fetches(3);
    } else {
        abi.fetches(3);
        rt.r[1] = types.addr.menu_guard;
        var idx: u8 = 0;
        while (true) {
            abi.fetches(7);
            const entry_addr = types.addr.menu_guard +% (@as(u32, idx) << 3);
            const entry_key = mem.readU8(entry_addr +% 1);
            rt.r[0] = entry_addr;
            rt.r[5] = entry_key;
            if (entry_key == key) {
                rt.cpuSub(null, entry_key, key, true);
                result_addr = entry_addr;
                break;
            }
            abi.fetches(10);
            idx +%= 1;
            rt.r[2] = idx;
            const next_addr = types.addr.menu_guard +% (@as(u32, idx) << 3);
            const next_sentinel = mem.readU8(next_addr);
            rt.r[0] = next_sentinel;
            if (next_sentinel == 0xFF) {
                rt.cpuSub(null, next_sentinel, 0xFF, true);
                abi.fetches(3);
                result_addr = types.addr.menu_selection;
                break;
            }
        }
    }

    abi.fetches(6);
    rt.r[0] = mem.readU8(result_addr);
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    popReturnValue();
}

/// Insert or update `(val=u8(r0), key=u8(r1), cb=r2)` in the `0xFF`-terminated `menu_guard` table (`0x08018AC0`).
pub fn func_08018AC0() callconv(.c) void {
    if (!abi.enter(0x08018AC0)) return;
    abi.fetches(14);
    abi.pushLr();
    abi.pushReg(7);
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);

    const val: u8 = @truncate(rt.r[0]);
    const key: u8 = @truncate(rt.r[1]);
    const cb: u32 = rt.r[2];
    const base = types.addr.menu_guard;
    rt.r[7] = cb;
    rt.r[6] = val;
    rt.r[4] = key;
    rt.r[5] = base;

    var idx: u32 = 0;
    var entry_addr: u32 = base;
    const first = mem.readU8(base);
    rt.r[0] = base;
    rt.r[1] = first;
    rt.r[2] = 0;
    rt.cpuSub(null, first, 0xFF, true);

    var append_sentinel = (first == 0xFF);
    if (!append_sentinel) {
        abi.fetches(5);
        const k0 = mem.readU8(base +% 1);
        rt.r[0] = k0;
        rt.cpuSub(null, k0, key, true);
        if (k0 == key) {
            abi.fetches(8);
            rt.r[1] = first;
        } else {
            abi.fetches(3);
            while (true) {
                abi.fetches(7);
                entry_addr +%= 8;
                idx +%= 1;
                const s = mem.readU8(entry_addr);
                rt.r[1] = entry_addr;
                rt.r[2] = idx;
                rt.r[0] = s;
                rt.cpuSub(null, s, 0xFF, true);
                if (s == 0xFF) {
                    append_sentinel = true;
                    break;
                }
                abi.fetches(5);
                const k = mem.readU8(entry_addr +% 1);
                rt.r[0] = k;
                rt.cpuSub(null, k, key, true);
                if (k == key) {
                    abi.fetches(8);
                    rt.r[1] = s;
                    break;
                }
            }
        }
    }

    if (append_sentinel) {
        abi.fetches(8);
        mem.writeU8(base +% ((idx +% 1) << 3), 0xFF);
        rt.r[1] = 0xFF;
    }

    abi.fetches(10);
    const slot_off = idx << 3;
    const dst = base +% slot_off;
    mem.writeU8(dst, val);
    mem.writeU8(dst +% 1, key);
    mem.writeU32(dst +% 4, cb);
    rt.r[0] = dst +% 4;
    rt.r[2] = idx;
    rt.r[3] = slot_off;
    rt.cpuSub(null, idx, 0xE, true);

    if (idx > 0xE) {
        while (true) {
            abi.fetches(3);
        }
    }

    abi.fetches(5);
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    rt.r[7] = abi.popReg();
    abi.popReturn();
}

/// Batch-register `0xFF`-terminated key list `[r1]` in `menu_guard` with guard value `u8(r0)` (`0x08018B28`).
pub fn func_08018B28() callconv(.c) void {
    if (!abi.enter(0x08018B28)) return;
    abi.fetches(11);
    abi.pushLr();
    abi.pushReg(5);
    abi.pushReg(4);

    rt.r[4] = rt.r[1];
    rt.r[5] = @as(u8, @truncate(rt.r[0]));
    rt.r[2] = types.addr.menu_guard;
    var idx: u8 = 0;
    const first = mem.readU8(types.addr.menu_guard);
    rt.r[1] = 0;
    rt.r[0] = first;
    rt.cpuSub(null, first, 0xFF, true);
    if (first != 0xFF) {
        while (true) {
            abi.fetches(10);
            idx +%= 1;
            rt.r[1] = idx;
            const s = mem.readU8(types.addr.menu_guard +% (@as(u32, idx) << 3));
            rt.r[0] = s;
            rt.cpuSub(null, s, 0xFF, true);
            if (s == 0xFF) break;
        }
        abi.fetches(3);
    }

    while (true) {
        abi.fetches(5);
        const k = mem.readU8(rt.r[4]);
        rt.r[0] = k;
        rt.cpuSub(null, k, 0xFF, true);
        if (k == 0xFF) break;
        abi.fetches(8);
        rt.r[4] +%= 1;
        rt.r[1] = k;
        rt.r[0] = rt.r[5];
        abi.setRegNz(&rt.r[2], 0);
        if (!abi.call(func_08018AC0, 0x08018B5D)) return;
    }

    abi.fetches(5);
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    abi.popReturn();
}

/// Decrement menu countdown `[r0 + 0x44]`, end active proc on underflow, and refresh every 8 ticks (`0x08074B8C`).
pub fn func_08074B8C() callconv(.c) void {
    if (!abi.enter(0x08074B8C)) return;
    abi.fetches(11);
    abi.pushLr();
    abi.pushReg(4);

    const timer_addr = rt.r[0] +% 0x44;
    rt.r[4] = timer_addr;
    const next: u16 = mem.readU16(timer_addr) -% 1;
    mem.writeU16(timer_addr, next);
    const shifted: u32 = @as(u32, next) << 16;
    rt.r[0] = shifted;
    rt.cpuSub(null, shifted, 0, true);
    if (@as(i16, @bitCast(next)) < 0) {
        abi.fetches(6);
        rt.r[0] = mem.readU8(types.addr.active_proc_idx);
        if (!abi.call(decls.func_08013BD0, 0x08074BA7)) return;
    }

    abi.fetches(7);
    const cur_timer = mem.readU16(rt.r[4]);
    rt.r[4] = cur_timer;
    const masked: u32 = cur_timer & 7;
    abi.setRegNz(&rt.r[0], masked);
    rt.cpuSub(null, masked, 0, true);
    if (masked == 0) {
        abi.fetches(4);
        if (!abi.call(decls.func_080116F4, 0x08074BB5)) return;
    }

    abi.fetches(5);
    rt.r[4] = abi.popReg();
    abi.popReturn();
}

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
    if (!abi.call(dma.func_08011330, 0x080036E3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Run menu controller step `0x0800378C` (`0x08003708`).
pub fn func_08003708() callconv(.c) void {
    if (!abi.enter(0x08003708)) return;
    callVoidFn(func_0800378C, 0x0800370F);
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
    callSingleU32(func_0800473C, 7, 6, 0x08004775, false);
}

/// Play/switch menu BGM/state track `1` via `0x0800473C` (`0x08004778`).
pub fn func_08004778() callconv(.c) void {
    if (!abi.enter(0x08004778)) return;
    callSingleU32(func_0800473C, 1, 6, 0x08004781, false);
}

/// Play/switch menu BGM/state track `3` via `0x0800473C` (`0x08004784`).
pub fn func_08004784() callconv(.c) void {
    if (!abi.enter(0x08004784)) return;
    callSingleU32(func_0800473C, 3, 6, 0x0800478D, false);
}

/// Play/switch menu BGM/state track `4` via `0x0800473C` (`0x08004790`).
pub fn func_08004790() callconv(.c) void {
    if (!abi.enter(0x08004790)) return;
    callSingleU32(func_0800473C, 4, 6, 0x08004799, false);
}

/// Stop/reset menu BGM/state track (`-1`) via `0x0800473C` (`0x0800479C`).
pub fn func_0800479C() callconv(.c) void {
    if (!abi.enter(0x0800479C)) return;
    callSingleU32(func_0800473C, @bitCast(@as(i32, -1)), 7, 0x080047A7, false);
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
    callSingleU32(sound.func_0803D880, 0x85, 6, 0x08004F95, false);
}

/// Play menu sound effect `0x86` via `0x0803D880` (`0x08004F98`).
pub fn func_08004F98() callconv(.c) void {
    if (!abi.enter(0x08004F98)) return;
    callSingleU32(sound.func_0803D880, 0x86, 6, 0x08004FA1, false);
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
    if (!abi.call(hw.func_08010B44, 0x0800F631)) return;

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
    if (!abi.call(proc.func_08019608, ret1)) return;
    abi.fetches(4);
    if (!abi.call(func_080045CC, ret2)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn callMenu19608Spawn02E4(comptime def_ref: u32, comptime r0_ret: u32, comptime r1_ret: u32, comptime r2_ret: u32) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(proc.func_08019608, r0_ret)) return;
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
    if (!abi.call(func_08002AF0, 0x08002CC7)) return;
    abi.fetches(4);
    if (!abi.call(func_08002A9C, 0x08002CCB)) return;
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
    if (!abi.call(hw.func_0801B888, 0x080034C1)) return;

    abi.fetches(9);
    rt.r[1] = 0x85 << 3;
    rt.r[2] = abi.read32(0x080034E8);
    abi.setRegNz(&rt.r[0], 0x18);
    rt.r[3] = rt.r[4];
    if (!abi.call(hw.func_0801B888, 0x080034CF)) return;

    abi.fetches(9);
    rt.r[1] = 0x89 << 3;
    rt.r[2] = abi.read32(0x080034EC);
    abi.setRegNz(&rt.r[0], 0x17);
    rt.r[3] = rt.r[4];
    if (!abi.call(hw.func_0801B888, 0x080034DD)) return;

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
    if (!abi.call(sound.func_0803D880, 0x0800459D)) return;
    finishWithMenu01FC(0x080045A3);
}

pub fn func_080045AC() callconv(.c) void {
    if (!abi.enter(0x080045AC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(proc.func_08019608, 0x080045B3)) return;
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
    if (!abi.call(sound.func_0803D880, 0x080045D9)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(abi.read32(0x080045E8));
    abi.setRegNz(&rt.r[1], 3);
    abi.write16(rt.r[0] +% 4, 3);
    if (!abi.call(func_08004994, 0x080045E5)) return;
    abi.fetches(4);
    abi.popReturn();
}

pub fn func_08004608() callconv(.c) void {
    if (!abi.enter(0x08004608)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(clusters_low_2.func_0800FC58, 0x0800460F)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(abi.read32(0x08004620)) +% 0x9C;
    abi.setRegNz(&rt.r[1], 8);
    if (!abi.call(ui.func_08048AE8, 0x0800461B)) return;
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
    if (!abi.call(proc.func_08019608, 0x08004657)) return;
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
    if (!abi.call(func_08003580, 0x08004937)) return;

    abi.fetches(11);
    rt.r[4] = abi.read32(0x08004960);
    abi.write16(abi.read32(rt.r[4]) +% 2, 2);
    rt.r[0] = abi.read32(0x08004964);
    rt.r[1] = abi.read32(0x08004968);
    abi.setRegNz(&rt.r[2], 0x80);
    if (!abi.call(dma.func_0800FFA8, 0x08004949)) return;

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
    if (!abi.call(proc.func_08019608, 0x08004F13)) return;
    abi.fetches(6);
    rt.r[0] = abi.read32(0x08004F2C);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08004F1B)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(abi.read32(0x08004F30));
    abi.setRegNz(&rt.r[1], 7);
    abi.write16(rt.r[0] +% 2, 7);
    if (!abi.call(unit.func_08021DF8, 0x08004F27)) return;
    abi.fetches(4);
    abi.popReturn();
}

pub fn func_080052C8() callconv(.c) void {
    if (!abi.enter(0x080052C8)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0x70);
    if (!abi.call(unit.func_0801B8D4, 0x080052D1)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08019A6C, 0x080052D5)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0x66);
    if (!abi.call(sound.func_0803D880, 0x080052DB)) return;
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
        if (!abi.call(battle.func_0802FC70, ent.ret)) return;
    }

    abi.fetches(12);
    const pal_idx = abi.read8(abi.read32(0x08002AE8) +% 4);
    rt.r[0] = (@as(u32, pal_idx) << 5) +% abi.read32(0x08002AEC);
    abi.setRegNz(&rt.r[1], @as(u32, 0xA0) << 2);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x08002AD3)) return;

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
    if (!abi.call(dma.func_08011330, 0x08002B07)) return;

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
        if (!abi.call(dma.func_08011330, s.ret)) return;
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
        if (!abi.call(dma.func_0800FFA8, p.ret)) return;
    }

    abi.fetches(8);
    rt.r[0] = abi.read32(0x080035C8);
    abi.setRegNz(&rt.r[1], @as(u32, 0xE8) << 2);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x080035AD)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Configure menu PPU display/window/blend registers after `0x080104B0` (`0x0800378C`).
pub fn func_0800378C() callconv(.c) void {
    if (!abi.enter(0x0800378C)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(hw.func_080104B0, 0x08003793)) return;

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
    if (!abi.call(map.func_08020D6C, 0x080045F3)) return;
    abi.fetches(4);
    if (!abi.call(campaign.func_080381C4, 0x080045F7)) return;
    abi.fetches(4);
    if (!abi.call(unit.func_08021DF8, 0x080045FB)) return;
    abi.fetches(4);
    if (!abi.call(map.func_080226B8, 0x080045FF)) return;
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
    if (!abi.call(proc.func_08019608, 0x080046EB)) return;

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
    if (!abi.call(dma.func_0800FFA8, 0x08004705)) return;

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
    if (!abi.call(proc.func_08019608, 0x08004745)) return;

    abi.fetches(5);
    abi.copyRegFlags(&rt.r[0], arg0);
    if (!abi.call(decls.func_080039F8, 0x0800474B)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08002B50, 0x0800474F)) return;
    abi.fetches(4);
    if (!abi.call(unit.func_08021DF8, 0x08004753)) return;

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
    if (!abi.call(proc.func_08019608, 0x08004977)) return;
    abi.fetches(4);
    if (!abi.call(unit.func_08021DF8, 0x0800497B)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08004990);
    abi.setRegNz(&rt.r[1], 2);
    abi.setRegNz(&rt.r[2], 3);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(ui.func_080195E8, 0x08004987)) return;

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
    if (!abi.call(func_080034F0, 0x080049A9)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x080049E4);
    rt.r[1] = abi.read32(0x080049E8);
    abi.setRegNz(&rt.r[2], 0x80);
    if (!abi.call(dma.func_0800FFA8, 0x080049B3)) return;

    abi.fetches(13);
    const ctx1 = abi.read32(ctx_ptr);
    abi.write16(ctx1 +% 0x46, 0x15);
    abi.write16(ctx1 +% 0x48, 0x10);
    abi.setRegNz(&rt.r[0], 0x70);
    if (!abi.call(unit.func_0801B8D4, 0x080049C9)) return;

    abi.fetches(6);
    abi.setRegNz(&rt.r[0], 0x10);
    abi.setRegNz(&rt.r[1], 0x10);
    if (!abi.call(map.func_0802055C, 0x080049D1)) return;

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
    if (!abi.call(hw.func_08010C70, 0x08004F5F)) return;

    abi.fetches(11);
    abi.write32(rt.r[13], 0x14);
    abi.write32(rt.r[13] +% 4, abi.read32(0x08004F88));
    rt.r[0] = abi.read32(0x08004F84);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0xE);
    abi.setRegNz(&rt.r[3], 0x1E);
    if (!abi.call(hw.func_08010C70, 0x08004F71)) return;

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
        if (!abi.call(dma.func_0800FFA8, x.ret)) return;
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
    if (!abi.call(dma.func_0800FFA8, 0x08005B0F)) return;

    abi.fetches(13);
    const st = abi.read32(abi.read32(0x08005B44));
    abi.write16(st +% 0x46, 0x15);
    abi.write16(st +% 0x48, 0x10);
    if (!abi.call(decls.func_08019A1C, 0x08005B25)) return;

    abi.fetches(4);
    if (!abi.call(proc.func_08019608, 0x08005B29)) return;

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

/// Configure display blend/window registers and screen offsets `(x0, x1, y0, y1)` (`0x08003828`).
pub fn func_08003828() callconv(.c) void {
    if (!abi.enter(0x08003828)) return;
    abi.fetches(14);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[10]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[9]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[8]);
    rt.r[13] -%= 8;

    rt.r[10] = rt.r[0];
    rt.r[7] = rt.r[1];
    abi.write32(rt.r[13] +% 0x0, rt.r[2]);
    abi.write32(rt.r[13] +% 0x4, rt.r[3]);
    if (!abi.call(hw.func_080104B0, 0x08003841)) return;

    abi.fetches(87);
    const dispcnt = abi.read32(0x080038EC);
    abi.write8(dispcnt +% 0, @truncate(((0xC0 | @as(u32, abi.read8(dispcnt))) & ~@as(u32, 6)) | 0x18));
    abi.write8(dispcnt +% 1, @truncate(@as(u32, abi.read8(dispcnt +% 1)) | 0x1E));
    abi.write16(abi.read32(0x080038F0), 0);
    abi.write16(abi.read32(0x080038F4), 0x10);
    abi.write16(abi.read32(0x080038F8), 0);
    const win_ctrl = abi.read32(0x080038FC);
    abi.write8(win_ctrl +% 1, @truncate(@as(u32, abi.read8(win_ctrl +% 1)) | 0x20));
    abi.write8(abi.read32(0x08003900), @truncate(rt.r[10]));
    abi.write8(abi.read32(0x08003904), @truncate(rt.r[7]));
    abi.write8(abi.read32(0x08003908), abi.read8(rt.r[13] +% 0x0));
    abi.write8(abi.read32(0x0800390C), abi.read8(rt.r[13] +% 0x4));
    const winin = abi.read32(0x08003910);
    abi.write8(winin, @truncate(@as(u32, abi.read8(winin)) | 0x3F));
    const winout = abi.read32(0x08003914);
    abi.write16(winout, 0);
    abi.write8(winout, @truncate((1 | @as(u32, abi.read8(winout)) | 0x1E) & ~@as(u32, 0x20)));

    rt.r[13] +%= 8;
    rt.r[3] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = rt.r[3];
    rt.r[9] = rt.r[4];
    rt.r[10] = rt.r[5];
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[7] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Initialize battle/screen state and set cursor limits to `(0x15, 0x10)` (`0x08004888`).
pub fn func_08004888() callconv(.c) void {
    if (!abi.enter(0x08004888)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019A1C, 0x0800488F)) return;
    abi.fetches(4);
    if (!abi.call(proc.func_08019608, 0x08004893)) return;
    abi.fetches(5);
    rt.r[0] = 0x70;
    if (!abi.call(unit.func_0801B8D4, 0x08004899)) return;
    abi.fetches(8);
    rt.r[0] = abi.read32(0x080048D0);
    rt.r[1] = 2;
    rt.r[2] = 2;
    rt.r[3] = 0;
    if (!abi.call(ui.func_080195E8, 0x080048A5)) return;
    abi.fetches(5);
    rt.r[0] = 7;
    if (!abi.call(decls.func_080001FC, 0x080048AB)) return;
    abi.fetches(7);
    rt.r[0] = abi.read32(0x080048D4);
    rt.r[1] = abi.read32(0x080048D8);
    rt.r[2] = 0x80;
    if (!abi.call(dma.func_0800FFA8, 0x080048B5)) return;
    abi.fetches(4);
    if (!abi.call(func_08002AF0, 0x080048B9)) return;

    abi.fetches(13);
    const ui_state = abi.read32(abi.read32(0x080048DC));
    abi.write16(ui_state +% 0x46, 0x15);
    abi.write16(ui_state +% 0x48, 0x10);
    abi.popReturn();
}

/// Tear down campaign/menu substate, load backup state, and clear active bitflags (`0x08004C38`).
pub fn func_08004C38() callconv(.c) void {
    if (!abi.enter(0x08004C38)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = abi.read32(0x08004C80);
    rt.r[0] = abi.read8(abi.read32(rt.r[4]) +% 0x10);
    rt.r[5] = abi.read32(0x08004C84);
    rt.r[1] = rt.r[5];
    if (!abi.call(campaign.func_0803F2C8, 0x08004C49)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_0800C580, 0x08004C4D)) return;

    abi.fetches(6);
    rt.r[1] = rt.r[0];
    rt.r[0] = 1;
    if (!abi.call(decls.func_0800C618, 0x08004C55)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(rt.r[4]) +% 0x9C;
    rt.r[1] = rt.r[5];
    if (!abi.call(func_08004BE8, 0x08004C5F)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_0801F4B8, 0x08004C63)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0800C3AC, 0x08004C67)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0800C348, 0x08004C6B)) return;

    abi.fetches(12);
    abi.write8(abi.read32(rt.r[4]) +% 0x12, @truncate(rt.r[0]));
    const ctx = abi.read32(rt.r[4]);
    abi.write16(ctx, @truncate(abi.read32(0x08004C88) & abi.read16(ctx)));

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

const MenuTextStrip = struct {
    x: u32,
    y: u32,
    pool: u32,
    ret: u32,
};

fn drawMenuTextStrips(base_addr: u32, comptime strips: []const MenuTextStrip) bool {
    inline for (strips) |s| {
        abi.fetches(10);
        abi.write32(rt.r[13] +% 0x0, 0x4000);
        abi.write32(rt.r[13] +% 0x4, 0);
        rt.r[0] = s.x;
        rt.r[1] = s.y;
        rt.r[2] = base_addr;
        rt.r[3] = abi.read32(s.pool);
        if (!abi.call(decls.func_08012A68, s.ret)) return false;
    }
    return true;
}

/// Draw 6 option header strips across top rows via `0x08010C70` + `0x08012A68` (`0x08005794`).
pub fn func_08005794() callconv(.c) void {
    if (!abi.enter(0x08005794)) return;
    abi.fetches(16);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const base_addr = abi.read32(0x08005824);
    abi.write32(rt.r[13] +% 0x0, 0x14);
    abi.write32(rt.r[13] +% 0x4, 0x174);
    rt.r[0] = base_addr;
    rt.r[1] = 0;
    rt.r[2] = 0;
    rt.r[3] = 0x1E;
    if (!abi.call(hw.func_08010C70, 0x080057B1)) return;

    abi.fetches(3);
    if (!drawMenuTextStrips(base_addr, &.{
        .{ .x = 3, .y = 3, .pool = 0x08005828, .ret = 0x080057C7 },
        .{ .x = 4, .y = 5, .pool = 0x0800582C, .ret = 0x080057D7 },
        .{ .x = 4, .y = 7, .pool = 0x08005830, .ret = 0x080057E7 },
        .{ .x = 3, .y = 9, .pool = 0x08005834, .ret = 0x080057F7 },
        .{ .x = 4, .y = 11, .pool = 0x08005838, .ret = 0x08005807 },
        .{ .x = 4, .y = 13, .pool = 0x0800583C, .ret = 0x08005817 },
    })) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08011804, 0x0800581B)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Draw 5 value strips into BG tilemap and refresh overlay via `0x08005720` (`0x08005840`).
pub fn func_08005840() callconv(.c) void {
    if (!abi.enter(0x08005840)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const base_addr = abi.read32(0x080058AC);
    if (!drawMenuTextStrips(base_addr, &.{
        .{ .x = 8, .y = 4, .pool = 0x080058B0, .ret = 0x0800585D },
        .{ .x = 8, .y = 6, .pool = 0x080058B4, .ret = 0x0800586D },
        .{ .x = 8, .y = 8, .pool = 0x080058B8, .ret = 0x0800587D },
        .{ .x = 8, .y = 10, .pool = 0x080058BC, .ret = 0x0800588D },
        .{ .x = 8, .y = 12, .pool = 0x080058C0, .ret = 0x0800589D },
    })) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08011804, 0x080058A1)) return;
    abi.fetches(4);
    if (!abi.call(func_08005720, 0x080058A5)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Transfer three 0x80-word backdrop strips and 0x20 tileset words at tile offset `0x3A0` (`0x080034F0`).
pub fn func_080034F0() callconv(.c) void {
    if (!abi.enter(0x080034F0)) return;
    abi.fetches(8);
    abi.pushLr();
    const pairs = [_]struct { src_pool: u32, dst_pool: u32, ret: u32 }{
        .{ .src_pool = 0x08003520, .dst_pool = 0x08003524, .ret = 0x080034FD },
        .{ .src_pool = 0x08003528, .dst_pool = 0x0800352C, .ret = 0x08003507 },
        .{ .src_pool = 0x08003530, .dst_pool = 0x08003534, .ret = 0x08003511 },
    };
    inline for (pairs, 0..) |p, idx| {
        if (idx == 1) abi.fetches(5);
        if (idx == 2) abi.fetches(7);
        rt.r[0] = abi.read32(p.src_pool);
        rt.r[1] = abi.read32(p.dst_pool);
        rt.r[2] = 0x80;
        rt.updateNz(0x80);
        if (idx == 1) abi.fetches(4);
        if (!abi.call(dma.func_0800FFA8, p.ret)) return;
    }
    abi.fetches(8);
    rt.r[0] = abi.read32(0x08003538);
    rt.r[1] = 0xE8 << 2;
    rt.r[2] = 0x20;
    rt.updateNz(0x20);
    if (!abi.call(dma.func_08011330, 0x0800351D)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Draw 3 menu title OAM strips at `(0x18, 0x420/0x430/0x440)` with attr `0xD000` (`0x0800353C`).
pub fn func_0800353C() callconv(.c) void {
    if (!abi.enter(0x0800353C)) return;
    abi.fetches(5);
    abi.pushLr();
    abi.pushReg(4);
    const items = [_]struct { y: u32, pool: u32, ret: u32 }{
        .{ .y = 0x84 << 3, .pool = 0x08003574, .ret = 0x08003551 },
        .{ .y = 0x86 << 3, .pool = 0x08003578, .ret = 0x0800355F },
        .{ .y = 0x88 << 3, .pool = 0x0800357C, .ret = 0x0800356D },
    };
    rt.r[4] = 0xD0 << 8;
    inline for (items) |it| {
        abi.fetches(9);
        rt.r[0] = 0x18;
        rt.r[1] = it.y;
        rt.r[2] = abi.read32(it.pool);
        rt.r[3] = 0xD0 << 8;
        rt.updateNz(0x18);
        if (!abi.call(hw.func_0801B888, it.ret)) return;
    }
    abi.fetches(5);
    rt.r[4] = abi.popReg();
    abi.popReturn();
}

const ScreenUiAccumCfg = struct {
    ptr_pool: u32,
    init_sum: u32,
    save_r9_zero: bool,
    pal_index_pool: u32,
    pal_base_pool: u32,
    pal_use_r5: bool,
    rets: [12]u32,
    ret_dma0: u32,
    ret_dma1: u32,
};

fn runUiMetricAccumAndPalDma(comptime cfg: ScreenUiAccumCfg) bool {
    const slot_ids = [_]u32{ 0, 1, 2, 3, 62, 63, 64, 65, 68, 67, 45 };
    const ptr_holder = abi.read32(cfg.ptr_pool);
    const base_obj = abi.read32(ptr_holder);
    if (cfg.save_r9_zero) rt.r[9] = 0;
    abi.write16(base_obj +% 0x28, @truncate(cfg.init_sum));
    rt.r[0] = cfg.init_sum;
    rt.r[1] = 0;
    rt.updateNz(0);
    if (!abi.call(battle.func_0802FC70, cfg.rets[0])) return false;

    inline for (slot_ids, 0..) |_, i| {
        const is_last = (i == slot_ids.len - 1);
        abi.fetches(if (is_last) (if (cfg.save_r9_zero) 15 else 18) else 10);
        const obj = abi.read32(ptr_holder);
        const total = rt.r[0] +% abi.read16(obj +% 0x28);
        abi.write16(obj +% 0x28, @truncate(total));
        if (!is_last) {
            rt.r[0] = total & 0xFFFF;
            rt.r[1] = slot_ids[i + 1];
            rt.updateNz(rt.r[1]);
            if (!abi.call(battle.func_0802FC70, cfg.rets[i + 1])) return false;
        }
    }

    const idx_tbl = abi.read32(cfg.pal_index_pool);
    const vram_base = abi.read32(cfg.pal_base_pool);
    if (!cfg.pal_use_r5) rt.r[4] = vram_base;
    const off0: u32 = @as(u32, abi.read8(idx_tbl +% (0xD3 << 2))) << 5;
    rt.r[0] = off0 +% vram_base;
    rt.r[1] = (0xD3 << 2) -% 0xCC;
    if (!cfg.save_r9_zero) abi.fetches(0);
    if (cfg.save_r9_zero) abi.fetches(5);
    rt.r[2] = 0x80;
    rt.updateNz(0x80);
    if (!abi.call(dma.func_08011330, cfg.ret_dma0)) return false;

    abi.fetches(10);
    const off1: u32 = @as(u32, abi.read8(idx_tbl +% 4)) << 5;
    rt.r[0] = off1 +% vram_base;
    rt.r[1] = 0xC0 << 2;
    rt.r[2] = 0x20;
    rt.updateNz(0x20);
    if (!abi.call(dma.func_08011330, cfg.ret_dma1)) return false;
    return true;
}

fn resetScreenTileLayers(rets: [7]u32) bool {
    const clears = [_]fn () callconv(.c) void{
        decls.func_08011910,
        decls.func_0801193C,
        decls.func_08011968,
        decls.func_08011804,
        decls.func_08011814,
        decls.func_08011824,
        decls.func_08011834,
    };
    inline for (clears, 0..) |fn_ptr, i| {
        if (i > 0) abi.fetches(4);
        if (!abi.call(fn_ptr, rets[i])) return false;
    }
    return true;
}

/// Shared credits / ending screen setup (`0x0806EC18` and `0x08076AA4`).
fn initCreditsOrEndingScreen(comptime is_ending: bool) void {
    abi.fetches(if (is_ending) @as(u32, 9) else 10);
    abi.pushLr();
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    const saved_r9 = rt.r[9];
    const saved_r8 = rt.r[8];
    if (!is_ending) abi.pushReg(9);
    abi.pushReg(8);
    rt.r[13] -%= 4;

    const pools = if (is_ending) .{
        .c0 = 0x08076CCC,
        .c1 = 0x08076CD0,
        .c2 = 0x08076CD4,
        .disp = 0x08076CD8,
        .bg0 = 0x08076CDC,
        .bg1 = 0x08076CE0,
        .zeros = .{ 0x08076CE4, 0x08076CE8, 0x08076CEC, 0x08076CF0, 0x08076CF4, 0x08076CF8 },
        .state = 0x08076CFC,
        .dma_dst0 = 0x08076D00,
        .dma_src0 = 0x08076D04,
        .pal0 = 0x08076D08,
        .pal1 = 0x08076D0C,
        .map_base = 0x08076D10,
        .map0 = 0x08076D14,
        .map_buf = 0x08076D18,
        .map1 = 0x08076D1C,
        .metrics = 0x08076D20,
        .idx = 0x08076D24,
        .vram = 0x08076D28,
        .rets_pre = .{ 0x08076AB3, 0x08076AB9, 0x08076ABF },
        .rets_clr = .{ 0x08076B0F, 0x08076B13, 0x08076B17, 0x08076B1B, 0x08076B1F, 0x08076B23, 0x08076B27 },
        .ret_st0 = 0x08076B4B,
        .ret_lz = 0x08076B59,
        .ret_46e00 = 0x08076B75,
        .ret_43c64 = 0x08076B7D,
        .ret_pal0 = 0x08076B87,
        .ret_pal1 = 0x08076B91,
        .ret_map0 = 0x08076BA3,
        .ret_map1 = 0x08076BB1,
        .ret_6cb34 = 0x08076BB7,
        .ret_sub = 0x08076BBB,
        .rets_acc = .{ 0x08076BCB, 0x08076BDB, 0x08076BEB, 0x08076BFB, 0x08076C0B, 0x08076C1B, 0x08076C2B, 0x08076C3B, 0x08076C4B, 0x08076C5B, 0x08076C6B, 0 },
        .ret_dma0 = 0x08076C8B,
        .ret_dma1 = 0x08076C9B,
    } else .{
        .c0 = 0x0806EE54,
        .c1 = 0x0806EE58,
        .c2 = 0x0806EE5C,
        .disp = 0x0806EE60,
        .bg0 = 0x0806EE64,
        .bg1 = 0x0806EE68,
        .zeros = .{ 0x0806EE6C, 0x0806EE70, 0x0806EE74, 0x0806EE78, 0x0806EE7C, 0x0806EE80 },
        .state = 0x0806EE84,
        .dma_dst0 = 0x0806EE88,
        .dma_src0 = 0x0806EE8C,
        .pal0 = 0x0806EE90,
        .pal1 = 0x0806EE94,
        .map_base = 0x0806EE98,
        .map0 = 0x0806EE9C,
        .map_buf = 0x0806EEA0,
        .map1 = 0x0806EEA4,
        .metrics = 0x0806EEAC,
        .idx = 0x0806EEB0,
        .vram = 0x0806EEB4,
        .rets_pre = .{ 0x0806EC29, 0x0806EC2F, 0x0806EC35 },
        .rets_clr = .{ 0x0806EC89, 0x0806EC8D, 0x0806EC91, 0x0806EC95, 0x0806EC99, 0x0806EC9D, 0x0806ECA1 },
        .ret_st0 = 0x0806ECC5,
        .ret_lz = 0x0806ECD3,
        .ret_46e00 = 0x0806ECEF,
        .ret_43c64 = 0x0806ECF7,
        .ret_pal0 = 0x0806ED01,
        .ret_pal1 = 0x0806ED0B,
        .ret_map0 = 0x0806ED1D,
        .ret_map1 = 0x0806ED2B,
        .ret_6cb34 = 0x0806ED31,
        .ret_sub = 0x0806ED35,
        .rets_acc = .{ 0x0806ED51, 0x0806ED61, 0x0806ED71, 0x0806ED81, 0x0806ED91, 0x0806EDA1, 0x0806EDB1, 0x0806EDC1, 0x0806EDD1, 0x0806EDE1, 0x0806EDF1, 0 },
        .ret_dma0 = 0x0806EE11,
        .ret_dma1 = 0x0806EE21,
    };

    rt.r[0] = abi.read32(pools.c0);
    if (!abi.call(decls.func_0803826C, pools.rets_pre[0])) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(pools.c1);
    if (!abi.call(state.func_08038260, pools.rets_pre[1])) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(pools.c2);
    if (!abi.call(decls.func_08010D00, pools.rets_pre[2])) return;

    if (!is_ending) {
        abi.fetches(4);
        if (!abi.call(decls.func_080104D4, 0x0806EC39)) return;
    }

    abi.fetches(42);
    const disp = abi.read32(pools.disp);
    abi.write8(disp +% 0, (abi.read8(disp +% 0) & 0x3F) | 0x40);
    abi.write8(disp +% 0, abi.read8(disp +% 0) & 0xE2);
    abi.write8(disp +% 0, (abi.read8(disp +% 0) | 0x02) & 0xE0);
    abi.write8(disp +% 1, (abi.read8(disp +% 1) | 0x1D) & 0xFD);
    abi.write16(abi.read32(pools.bg0), 0x000F);
    abi.write16(abi.read32(pools.bg1), 0x0006);
    if (!resetScreenTileLayers(pools.rets_clr)) return;

    abi.fetches(20);
    inline for (pools.zeros) |zpool| {
        abi.write16(abi.read32(zpool), 0);
    }
    const ui_state = abi.read32(pools.state);
    rt.r[0] = ui_state;
    if (!abi.call(decls.func_0806CCA4, pools.ret_st0)) return;

    abi.fetches(9);
    const dec_size = rt.r[0];
    const work_buf: u32 = 0x80 << 18;
    rt.r[0] = ui_state;
    rt.r[1] = work_buf;
    if (!abi.call(bios.func_080796DC, pools.ret_lz)) return;

    abi.fetches(16);
    const dma_blk = abi.read32(pools.dma_dst0);
    abi.write32(dma_blk +% 0, work_buf);
    abi.write32(dma_blk +% 4, abi.read32(pools.dma_src0));
    const sx = @as(i32, @bitCast(dec_size));
    const dma_ctrl = ((@as(u32, @bitCast(sx >> 1))) +% 0) | (0x80 << 24);
    const exact_ctrl = @as(u32, @bitCast(@divTrunc(sx, 2))) | (0x80 << 24);
    _ = dma_ctrl;
    abi.write32(dma_blk +% 8, exact_ctrl);
    rt.r[0] = abi.read32(dma_blk +% 8);
    if (!abi.call(ui.func_08046E00, pools.ret_46e00)) return;

    abi.fetches(6);
    abi.setRegNz(&rt.r[0], 0);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(ui.func_08043C64, pools.ret_43c64)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(pools.pal0);
    rt.r[1] = 0x60;
    rt.r[2] = 0x20;
    rt.updateNz(0x20);
    if (!abi.call(dma.func_08011330, pools.ret_pal0)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(pools.pal1);
    rt.r[1] = 0x20;
    rt.r[2] = 0x20;
    rt.updateNz(0x20);
    if (!abi.call(dma.func_08011330, pools.ret_pal1)) return;

    abi.fetches(11);
    const map_base = abi.read32(pools.map_base);
    const map_buf = abi.read32(pools.map_buf);
    abi.write32(rt.r[13], map_buf);
    rt.r[0] = map_base;
    rt.r[1] = abi.read32(pools.map0);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 1);
    if (!abi.call(decls.func_08010C18, pools.ret_map0)) return;

    abi.fetches(9);
    abi.write32(rt.r[13], map_buf);
    rt.r[0] = map_base;
    rt.r[1] = abi.read32(pools.map1);
    abi.setRegNz(&rt.r[2], 1);
    abi.setRegNz(&rt.r[3], 0x10);
    if (!abi.call(decls.func_08010C18, pools.ret_map1)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0xE);
    if (!abi.call(hw.func_0806CB34, pools.ret_6cb34)) return;

    abi.fetches(4);
    if (is_ending) {
        if (!abi.call(decls.func_08076944, pools.ret_sub)) return;
        abi.fetches(10);
    } else {
        if (!abi.call(decls.func_0806E994, pools.ret_sub)) return;
        abi.fetches(6);
        rt.r[0] = abi.read32(0x0806EEA8);
        abi.setRegNz(&rt.r[1], 3);
        if (!abi.call(decls.func_0801320C, 0x0806ED3D)) return;
        abi.fetches(12);
    }

    if (!runUiMetricAccumAndPalDma(.{
        .ptr_pool = pools.metrics,
        .init_sum = 0x84 << 2,
        .save_r9_zero = !is_ending,
        .pal_index_pool = pools.idx,
        .pal_base_pool = pools.vram,
        .pal_use_r5 = !is_ending,
        .rets = pools.rets_acc,
        .ret_dma0 = pools.ret_dma0,
        .ret_dma1 = pools.ret_dma1,
    })) return;

    if (is_ending) {
        abi.fetches(4);
        if (!abi.call(ui.func_08076914, 0x08076C9F)) return;
        abi.fetches(4);
        if (!abi.call(ui.func_0806A8E4, 0x08076CA3)) return;
        abi.fetches(8);
        rt.r[0] = 7;
        rt.r[1] = 0xF0 << 1;
        rt.r[2] = 0xF;
        rt.updateNz(0xF);
        if (!abi.call(ui.func_0806A8C4, 0x08076CAF)) return;
        abi.fetches(4);
        if (!abi.call(decls.func_08076778, 0x08076CB3)) return;
        abi.fetches(4);
        if (!abi.call(decls.func_080762A0, 0x08076CB7)) return;
        abi.fetches(12);
        abi.write8(abi.read32(abi.read32(pools.metrics)) +% 0x34, 0);
    } else {
        abi.fetches(13);
        abi.write8(abi.read32(abi.read32(pools.metrics)) +% 0x34, 0);
        const timer_ptr = abi.read32(0x0806EEB8);
        abi.write16(abi.read32(timer_ptr) +% 4, 0x80 << 2);
        if (!abi.call(decls.func_0806E4B8, 0x0806EE37)) return;
        abi.fetches(16);
        abi.write8(abi.read32(abi.read32(pools.metrics)) +% 0x34, 1);
        abi.write16(abi.read32(timer_ptr) +% 4, 0);
    }

    rt.r[13] +%= 4;
    rt.r[8] = abi.popReg();
    if (!is_ending) rt.r[9] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    _ = saved_r9;
    _ = saved_r8;
    abi.popReturn();
}

/// Initialize credits roll screen layout, palette uploads, and scroll metrics (`0x0806EC18`).
pub fn func_0806EC18() callconv(.c) void {
    if (!abi.enter(0x0806EC18)) return;
    initCreditsOrEndingScreen(false);
}

/// Initialize campaign ending/epilogue showcase screen (`0x08076AA4`).
pub fn func_08076AA4() callconv(.c) void {
    if (!abi.enter(0x08076AA4)) return;
    initCreditsOrEndingScreen(true);
}

const ModeMenuCfg = struct {
    pool_clear8: u32 = 0,
    pool_inc0: u32 = 0,
    pool_inc1: u32,
    pool_pal: u32 = 0,
    pool_lz0: u32 = 0,
    pool_lz1: u32 = 0,
    pool_tiles: u32 = 0,
    pool_disp_0: u32,
    pool_disp_1: u32,
    pool_map0: u32,
    pool_map1: u32,
    pool_dma_src: u32 = 0,
    pool_dma_dst: u32 = 0,
    pool_bg_chr: u32,
    pool_bg_map: u32,
    pool_bg_buf: u32,
    pool_bg_scr: u32,
    pool_sfx0: u32,
    pool_sfx1: u32,
    pool_sfx2: u32,
    pool_extra: u32,
    mode_arg: u32,
    extra_val: u16,
    final_tag: u16,
    state_pos_x: u32,
    state_pos_y: u32,
    ret_02ec: u32,
    ret_10d00: u32 = 0,
    ret_96e8: u32 = 0,
    ret_pre_tiles: u32 = 0,
    rets_clr: [7]u32,
    ret_68164: u32,
    ret_cd10: u32,
    ret_map: u32,
    ret_ffa8: u32 = 0,
    ret_tiles: u32,
    ret_ccac: u32,
    ret_sfx: [3]u32,
};

fn initModeMenuSubscreen(comptime cfg: ModeMenuCfg) void {
    abi.fetches(if (cfg.pool_clear8 != 0) @as(u32, 16) else 17);
    abi.pushLr();
    abi.pushReg(5);
    abi.pushReg(4);
    rt.r[13] -%= 8;
    const ui_state = rt.r[0];

    if (cfg.pool_clear8 != 0) abi.write8(abi.read32(cfg.pool_clear8), 0);
    if (cfg.pool_inc0 != 0) {
        const p0 = abi.read32(cfg.pool_inc0);
        abi.write8(p0, abi.read8(p0) +% 1);
    }
    const inc_ptr = abi.read32(cfg.pool_inc1);
    const old_idx = abi.read8(inc_ptr);
    abi.write8(inc_ptr, old_idx +% 1);
    rt.r[0] = old_idx;
    rt.updateNz(old_idx);
    if (!abi.call(decls.func_080702EC, cfg.ret_02ec)) return;

    abi.fetches(if (cfg.pool_clear8 != 0) @as(u32, 9) else 8);
    abi.write16(ui_state +% 0x42, @truncate(rt.r[0]));
    if (cfg.ret_10d00 != 0) {
        rt.r[0] = abi.read32(cfg.pool_pal);
        if (!abi.call(decls.func_08010D00, cfg.ret_10d00)) return;
        abi.fetches(6);
        rt.r[0] = abi.read32(cfg.pool_lz0);
        rt.r[1] = abi.read32(cfg.pool_lz1);
        if (!abi.call(bios.func_080796E8, cfg.ret_96e8)) return;
        abi.fetches(8);
        rt.r[0] = abi.read32(cfg.pool_tiles);
        rt.r[1] = 0x80 << 2;
        rt.r[2] = 0xE0;
        rt.updateNz(0xE0);
        if (!abi.call(dma.func_08011330, cfg.ret_pre_tiles)) return;
        abi.fetches(4);
    }

    inline for ([_]fn () callconv(.c) void{
        decls.func_08011910, decls.func_0801193C, decls.func_08011968,
        decls.func_08068164, decls.func_08011804, decls.func_08011814,
        decls.func_08011824, decls.func_08011834,
    }, 0..) |fn_ptr, i| {
        const ret = switch (i) {
            0 => cfg.rets_clr[0],
            1 => cfg.rets_clr[1],
            2 => cfg.rets_clr[2],
            3 => cfg.ret_68164,
            4 => cfg.rets_clr[3],
            5 => cfg.rets_clr[4],
            6 => cfg.rets_clr[5],
            else => cfg.rets_clr[6],
        };
        if (i > 0) abi.fetches(4);
        if (!abi.call(fn_ptr, ret)) return;
    }

    abi.fetches(7);
    abi.setRegNz(&rt.r[0], cfg.mode_arg);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0);
    if (!abi.call(co.func_0806CD10, cfg.ret_cd10)) return;

    abi.fetches(9);
    abi.write32(rt.r[13], 0);
    rt.r[0] = abi.read32(cfg.pool_map0);
    rt.r[1] = abi.read32(cfg.pool_map1);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], if (cfg.ret_10d00 != 0) 1 else 2);
    if (!abi.call(decls.func_08010C18, cfg.ret_map)) return;

    if (cfg.ret_ffa8 != 0) {
        abi.fetches(8);
        rt.r[0] = abi.read32(cfg.pool_dma_src);
        rt.r[1] = abi.read32(cfg.pool_dma_dst);
        rt.r[2] = 0x80 << 4;
        rt.updateNz(rt.r[2]);
        if (!abi.call(dma.func_0800FFA8, cfg.ret_ffa8)) return;
    }

    abi.fetches(7);
    rt.r[0] = abi.read32(cfg.pool_bg_chr);
    abi.setRegNz(&rt.r[1], 0x20);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, cfg.ret_tiles)) return;

    abi.fetches(13);
    abi.write32(rt.r[13] +% 0, 0xC);
    abi.write32(rt.r[13] +% 4, 0x80 << 5);
    rt.r[0] = abi.read32(cfg.pool_bg_map);
    rt.r[1] = abi.read32(cfg.pool_bg_scr);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_0806CCAC, cfg.ret_ccac)) return;

    inline for ([_]u32{ cfg.pool_sfx0, cfg.pool_sfx1, cfg.pool_sfx2 }, 0..) |sfx_pool, i| {
        abi.fetches(6);
        rt.r[0] = abi.read32(sfx_pool);
        abi.setRegNz(&rt.r[1], 0);
        if (!abi.call(decls.func_0801320C, cfg.ret_sfx[i])) return;
    }

    abi.fetches(if (cfg.ret_10d00 != 0) @as(u32, 13) else if (cfg.extra_val != 0) 15 else 14);
    abi.write16(rt.r[0] +% 0x1C, cfg.final_tag);
    if (cfg.extra_val != 0) {
        const extra_p = abi.read32(cfg.pool_extra);
        abi.write16(extra_p, cfg.extra_val);
        rt.r[1] = extra_p;
        rt.r[2] = cfg.final_tag;
    } else if (cfg.pool_extra != 0) {
        abi.write16(abi.read32(cfg.pool_extra), cfg.extra_val);
        if (cfg.ret_10d00 == 0) rt.r[1] = cfg.final_tag;
    }
    abi.write32(ui_state +% 0x34, cfg.state_pos_x);
    abi.write32(ui_state +% 0x38, cfg.state_pos_y);
    rt.r[0] = if (cfg.extra_val != 0) cfg.state_pos_x else cfg.state_pos_y;
    rt.r[13] +%= 8;
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    abi.popReturn();
}

/// Initialize sub-mode menu variant A (`0x08070BEC`).
pub fn func_08070BEC() callconv(.c) void {
    if (!abi.enter(0x08070BEC)) return;
    initModeMenuSubscreen(.{
        .pool_clear8 = 0x08070CBC,
        .pool_inc1 = 0x08070CC0,
        .pool_pal = 0x08070CC4,
        .pool_lz0 = 0x08070CC8,
        .pool_lz1 = 0x08070CCC,
        .pool_tiles = 0x08070CD0,
        .pool_disp_0 = 0,
        .pool_disp_1 = 0,
        .pool_map0 = 0x08070CD4,
        .pool_map1 = 0x08070CD8,
        .pool_dma_src = 0x08070CDC,
        .pool_dma_dst = 0x08070CE0,
        .pool_bg_chr = 0x08070CE4,
        .pool_bg_map = 0x08070CE8,
        .pool_bg_buf = 0,
        .pool_bg_scr = 0x08070CEC,
        .pool_sfx0 = 0x08070CF0,
        .pool_sfx1 = 0x08070CF4,
        .pool_sfx2 = 0x08070CF8,
        .pool_extra = 0x08070CFC,
        .mode_arg = 1,
        .extra_val = 0,
        .final_tag = 0,
        .state_pos_x = 0x18,
        .state_pos_y = 0xFFFF_FFFF,
        .ret_02ec = 0x08070C09,
        .ret_10d00 = 0x08070C17,
        .ret_96e8 = 0x08070C1F,
        .ret_pre_tiles = 0x08070C2B,
        .rets_clr = .{ 0x08070C2F, 0x08070C33, 0x08070C37, 0x08070C3F, 0x08070C43, 0x08070C47, 0x08070C4B },
        .ret_68164 = 0x08070C3B,
        .ret_cd10 = 0x08070C55,
        .ret_map = 0x08070C63,
        .ret_ffa8 = 0x08070C6F,
        .ret_tiles = 0x08070C79,
        .ret_ccac = 0x08070C8F,
        .ret_sfx = .{ 0x08070C97, 0x08070C9F, 0x08070CA7 },
    });
}

/// Initialize sub-mode menu variant B (`0x08070D00`).
pub fn func_08070D00() callconv(.c) void {
    if (!abi.enter(0x08070D00)) return;
    initModeMenuSubscreen(.{
        .pool_inc0 = 0x08070DB0,
        .pool_inc1 = 0x08070DB4,
        .pool_disp_0 = 0,
        .pool_disp_1 = 0,
        .pool_map0 = 0x08070DB8,
        .pool_map1 = 0x08070DBC,
        .pool_bg_chr = 0x08070DC0,
        .pool_bg_map = 0x08070DC4,
        .pool_bg_buf = 0,
        .pool_bg_scr = 0x08070DC8,
        .pool_sfx0 = 0x08070DCC,
        .pool_sfx1 = 0x08070DD0,
        .pool_sfx2 = 0x08070DD4,
        .pool_extra = 0x08070DD8,
        .mode_arg = 2,
        .extra_val = 0x70,
        .final_tag = 1,
        .state_pos_x = 0xFFFF_FFE8,
        .state_pos_y = 1,
        .ret_02ec = 0x08070D1F,
        .rets_clr = .{ 0x08070D2B, 0x08070D2F, 0x08070D33, 0x08070D3B, 0x08070D3F, 0x08070D43, 0x08070D47 },
        .ret_68164 = 0x08070D37,
        .ret_cd10 = 0x08070D51,
        .ret_map = 0x08070D5F,
        .ret_tiles = 0x08070D69,
        .ret_ccac = 0x08070D7F,
        .ret_sfx = .{ 0x08070D87, 0x08070D8F, 0x08070D97 },
    });
}

/// Initialize sub-mode menu variant C (`0x08070DDC`).
pub fn func_08070DDC() callconv(.c) void {
    if (!abi.enter(0x08070DDC)) return;
    initModeMenuSubscreen(.{
        .pool_inc0 = 0x08070E8C,
        .pool_inc1 = 0x08070E90,
        .pool_disp_0 = 0,
        .pool_disp_1 = 0,
        .pool_map0 = 0x08070E94,
        .pool_map1 = 0x08070E98,
        .pool_bg_chr = 0x08070E9C,
        .pool_bg_map = 0x08070EA0,
        .pool_bg_buf = 0,
        .pool_bg_scr = 0x08070EA4,
        .pool_sfx0 = 0x08070EA8,
        .pool_sfx1 = 0x08070EAC,
        .pool_sfx2 = 0x08070EB0,
        .pool_extra = 0x08070EB4,
        .mode_arg = 4,
        .extra_val = 0,
        .final_tag = 2,
        .state_pos_x = 0x18,
        .state_pos_y = 0xFFFF_FFFF,
        .ret_02ec = 0x08070DFB,
        .rets_clr = .{ 0x08070E07, 0x08070E0B, 0x08070E0F, 0x08070E17, 0x08070E1B, 0x08070E1F, 0x08070E23 },
        .ret_68164 = 0x08070E13,
        .ret_cd10 = 0x08070E2D,
        .ret_map = 0x08070E3B,
        .ret_tiles = 0x08070E45,
        .ret_ccac = 0x08070E5B,
        .ret_sfx = .{ 0x08070E63, 0x08070E6B, 0x08070E73 },
    });
}

/// Initialize tri-layer scrolling BG showcase screen A (`0x08071B54`).
pub fn func_08071B54() callconv(.c) void {
    if (!abi.enter(0x08071B54)) return;
    abi.fetches(13);
    abi.pushLr();
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    rt.r[13] -%= 8;
    const ui_state = rt.r[0];

    const inc_ptr = abi.read32(0x08071CB0);
    const prev_cnt = abi.read8(inc_ptr);
    abi.write8(inc_ptr, prev_cnt +% 1);
    rt.r[0] = prev_cnt;
    rt.updateNz(prev_cnt);
    if (!abi.call(decls.func_080702EC, 0x08071B6B)) return;

    abi.fetches(13);
    abi.write16(ui_state +% 0x42, @truncate(rt.r[0]));
    abi.write16(ui_state +% 0x44, 0);
    abi.write16(abi.read32(0x08071CB4), 0);
    rt.r[0] = abi.read32(0x08071CB8);
    if (!abi.call(decls.func_08010D00, 0x08071B81)) return;

    abi.fetches(7);
    rt.r[0] = 0x3C0;
    if (!abi.call(decls.func_0806CD50, 0x08071B8B)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080104D4, 0x08071B8F)) return;
    abi.fetches(4);
    if (!abi.call(hw.func_080104B0, 0x08071B93)) return;

    abi.fetches(12);
    const map0 = abi.read32(0x08071CBC);
    abi.write32(rt.r[13] +% 0, 0x14);
    abi.write32(rt.r[13] +% 4, 0x3C0);
    rt.r[0] = map0;
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0x20);
    if (!abi.call(hw.func_08010C70, 0x08071BA7)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08068164, 0x08071BAB)) return;

    abi.fetches(20);
    const disp_ptr = abi.read32(0x08071CC0);
    abi.write8(disp_ptr +% 1, (abi.read8(disp_ptr +% 1) & 0xF8) | 0x0A);

    const bg_cfg = [_]struct { a: u32, b: u32, c: u32, ret: u32 }{
        .{ .a = 1, .b = 0, .c = 0, .ret = 0x08071BCF },
        .{ .a = 2, .b = 0x140, .c = 1, .ret = 0x08071BDB },
        .{ .a = 4, .b = 0x280, .c = 2, .ret = 0x08071BE7 },
    };
    inline for (bg_cfg, 0..) |c, i| {
        if (i > 0) abi.fetches(8);
        rt.r[0] = c.a;
        rt.r[1] = c.b;
        rt.r[2] = c.c;
        rt.updateNz(c.c);
        if (!abi.call(co.func_0806CD10, c.ret)) return;
    }

    abi.fetches(10);
    const scr0 = abi.read32(0x08071CC4);
    const map_args = [_]struct { sp0: u32, r3: u32, ret: u32 }{
        .{ .sp0 = 0, .r3 = 0, .ret = 0x08071BF7 },
        .{ .sp0 = 0x8A << 5, .r3 = 7, .ret = 0x08071C09 },
        .{ .sp0 = 0x8A << 6, .r3 = 0xE, .ret = 0x08071C1B },
    };
    inline for (map_args, 0..) |m, i| {
        if (i > 0) abi.fetches(11);
        abi.write32(rt.r[13], m.sp0);
        rt.r[0] = map0;
        rt.r[1] = scr0;
        abi.setRegNz(&rt.r[2], 0);
        abi.setRegNz(&rt.r[3], m.r3);
        if (!abi.call(decls.func_08010C18, m.ret)) return;
    }

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08071CC8);
    rt.r[1] = abi.read32(0x08071CCC);
    rt.r[2] = 0x80 << 4;
    rt.updateNz(rt.r[2]);
    if (!abi.call(dma.func_0800FFA8, 0x08071C27)) return;

    abi.fetches(8);
    const pal_src = abi.read32(0x08071CD0);
    inline for ([_]struct { off: u32, idx: u32, ret: u32 }{
        .{ .off = 0x00, .idx = 0x60, .ret = 0x08071C33 },
        .{ .off = 0x20, .idx = 0x80, .ret = 0x08071C3F },
        .{ .off = 0x60, .idx = 0xA0, .ret = 0x08071C4B },
    }, 0..) |p, i| {
        if (i > 0) abi.fetches(8);
        rt.r[0] = pal_src +% p.off;
        rt.r[1] = p.idx;
        abi.setRegNz(&rt.r[2], 0x20);
        if (!abi.call(dma.func_08011330, p.ret)) return;
    }

    abi.fetches(15);
    const chr = abi.read32(0x08071CD4);
    const lut = abi.read32(0x08071CD8);
    inline for ([_]struct { sz: u32, r3: u32, ret: u32 }{
        .{ .sz = 0xC0 << 6, .r3 = 0, .ret = 0x08071C65 },
        .{ .sz = 0x80 << 7, .r3 = 7, .ret = 0x08071C79 },
        .{ .sz = 0xA0 << 7, .r3 = 0xE, .ret = 0x08071C8D },
    }, 0..) |b, i| {
        if (i > 0) abi.fetches(12);
        abi.write32(rt.r[13] +% 0, 6);
        abi.write32(rt.r[13] +% 4, b.sz);
        rt.r[0] = chr;
        rt.r[1] = lut;
        abi.setRegNz(&rt.r[2], 0);
        abi.setRegNz(&rt.r[3], b.r3);
        if (!abi.call(decls.func_0806CCAC, b.ret)) return;
    }

    abi.fetches(4);
    if (!abi.call(decls.func_08011814, 0x08071C91)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011834, 0x08071C95)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0xA0);
    if (!abi.call(decls.func_0806CE28, 0x08071C9B)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x08071CDC);
    if (!abi.call(decls.func_0806CD78, 0x08071CA1)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_08071878, 0x08071CA7)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    abi.popReturn();
}

/// Initialize dual-BG panoramic showcase screen B (`0x0807217C`).
pub fn func_0807217C() callconv(.c) void {
    if (!abi.enter(0x0807217C)) return;
    abi.fetches(17);
    abi.pushLr();
    abi.pushReg(7);
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.pushReg(10);
    abi.pushReg(9);
    abi.pushReg(8);
    rt.r[13] -%= 8;
    const ui_state = rt.r[0];

    const inc_ptr = abi.read32(0x08072398);
    const prev_cnt = abi.read8(inc_ptr);
    abi.write8(inc_ptr, prev_cnt +% 1);
    rt.r[0] = prev_cnt;
    rt.updateNz(prev_cnt);
    if (!abi.call(decls.func_080702EC, 0x0807219B)) return;

    abi.fetches(19);
    abi.write16(ui_state +% 0x42, @truncate(rt.r[0]));
    const neg_ca: u32 = 0 -% @as(u32, 0xCA);
    abi.write16(abi.read32(0x0807239C), @truncate(neg_ca));
    abi.write16(ui_state +% 0x44, 0);

    const b0 = abi.read32(0x080723A0);
    const b1 = abi.read32(0x080723A4);
    const b2 = abi.read32(0x080723A8);
    const b3 = abi.read32(0x080723AC);

    rt.r[0] = b0;
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_08010CD8, 0x080721BD)) return;
    abi.fetches(8);
    rt.r[0] = b1;
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_08010CD8, 0x080721C9)) return;
    abi.fetches(10);
    rt.r[0] = b2;
    rt.r[1] = 0x80 << 8;
    if (!abi.call(decls.func_08010CD8, 0x080721D9)) return;
    abi.fetches(7);
    rt.r[0] = b3;
    rt.r[1] = 0x80 << 8;
    if (!abi.call(decls.func_08010CD8, 0x080721E3)) return;

    abi.fetches(7);
    rt.r[0] = b0;
    rt.r[1] = 0xE0 << 7;
    if (!abi.call(decls.func_08010CC4, 0x080721ED)) return;
    abi.fetches(7);
    rt.r[0] = b1;
    rt.r[1] = 0xF0 << 8;
    if (!abi.call(decls.func_08010CC4, 0x080721F7)) return;
    abi.fetches(7);
    rt.r[0] = b2;
    rt.r[1] = 0xF0 << 7;
    if (!abi.call(decls.func_08010CC4, 0x08072201)) return;
    abi.fetches(7);
    rt.r[0] = b3;
    rt.r[1] = 0xF8 << 8;
    if (!abi.call(decls.func_08010CC4, 0x0807220B)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x080723B0);
    rt.r[1] = abi.read32(0x080723B4);
    if (!abi.call(bios.func_080796E8, 0x08072213)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x080723B8);
    rt.r[1] = 0x80 << 2;
    rt.r[2] = 0xE0;
    rt.updateNz(0xE0);
    if (!abi.call(dma.func_08011330, 0x0807221F)) return;

    abi.fetches(7);
    rt.r[0] = 0x3C0;
    if (!abi.call(decls.func_0806CD50, 0x08072229)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080104D4, 0x0807222D)) return;
    abi.fetches(4);
    if (!abi.call(hw.func_080104B0, 0x08072231)) return;

    abi.fetches(12);
    const map0 = abi.read32(0x080723BC);
    abi.write32(rt.r[13] +% 0, 0x14);
    abi.write32(rt.r[13] +% 4, 0x3C0);
    rt.r[0] = map0;
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0x20);
    if (!abi.call(hw.func_08010C70, 0x08072245)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08068164, 0x08072249)) return;

    abi.fetches(24);
    const disp_ptr = abi.read32(0x080723C0);
    abi.write8(disp_ptr +% 1, (abi.read8(disp_ptr +% 1) & 0xF8) | 0x0A);

    inline for ([_]struct { a: u32, b: u32, c: u32, ret: u32 }{
        .{ .a = 1, .b = 0, .c = 0, .ret = 0x08072275 },
        .{ .a = 4, .b = 0x280, .c = 2, .ret = 0x08072281 },
        .{ .a = 2, .b = 0x140, .c = 1, .ret = 0x0807228D },
    }, 0..) |c, i| {
        if (i > 0) abi.fetches(8);
        rt.r[0] = c.a;
        rt.r[1] = c.b;
        rt.r[2] = c.c;
        rt.updateNz(c.c);
        if (!abi.call(co.func_0806CD10, c.ret)) return;
    }

    abi.fetches(11);
    const scr0 = abi.read32(0x080723C4);
    inline for ([_]struct { sp0: u32, r3: u32, ret: u32 }{
        .{ .sp0 = 0, .r3 = 0, .ret = 0x0807229F },
        .{ .sp0 = 0x8A << 5, .r3 = 7, .ret = 0x080722B1 },
        .{ .sp0 = 0x8A << 6, .r3 = 0xE, .ret = 0x080722C3 },
    }, 0..) |m, i| {
        if (i > 0) abi.fetches(11);
        abi.write32(rt.r[13], m.sp0);
        rt.r[0] = map0;
        rt.r[1] = scr0;
        abi.setRegNz(&rt.r[2], 0);
        abi.setRegNz(&rt.r[3], m.r3);
        if (!abi.call(decls.func_08010C18, m.ret)) return;
    }

    abi.fetches(8);
    rt.r[0] = abi.read32(0x080723C8);
    rt.r[1] = abi.read32(0x080723CC);
    rt.r[2] = 0x80 << 4;
    rt.updateNz(rt.r[2]);
    if (!abi.call(dma.func_0800FFA8, 0x080722CF)) return;

    abi.fetches(8);
    const pal_src = abi.read32(0x080723D0);
    inline for ([_]struct { off: u32, idx: u32, ret: u32 }{
        .{ .off = 0x00, .idx = 0x60, .ret = 0x080722DB },
        .{ .off = 0x20, .idx = 0x80, .ret = 0x080722E7 },
        .{ .off = 0x60, .idx = 0xA0, .ret = 0x080722F3 },
    }, 0..) |p, i| {
        if (i > 0) abi.fetches(8);
        rt.r[0] = pal_src +% p.off;
        rt.r[1] = p.idx;
        abi.setRegNz(&rt.r[2], 0x20);
        if (!abi.call(dma.func_08011330, p.ret)) return;
    }

    abi.fetches(15);
    const chr = abi.read32(0x080723D4);
    const lut = abi.read32(0x080723D8);
    inline for ([_]struct { sz: u32, r3: u32, ret: u32 }{
        .{ .sz = 0xC0 << 6, .r3 = 0, .ret = 0x0807230D },
        .{ .sz = 0x80 << 7, .r3 = 7, .ret = 0x08072321 },
        .{ .sz = 0xA0 << 7, .r3 = 0xE, .ret = 0x08072335 },
    }, 0..) |b, i| {
        if (i > 0) abi.fetches(12);
        abi.write32(rt.r[13] +% 0, 6);
        abi.write32(rt.r[13] +% 4, b.sz);
        rt.r[0] = chr;
        rt.r[1] = lut;
        abi.setRegNz(&rt.r[2], 0);
        abi.setRegNz(&rt.r[3], b.r3);
        if (!abi.call(decls.func_0806CCAC, b.ret)) return;
    }

    abi.fetches(4);
    if (!abi.call(decls.func_08011814, 0x08072339)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011834, 0x0807233D)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0xA0);
    if (!abi.call(decls.func_0806CE28, 0x08072343)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x080723DC);
    if (!abi.call(decls.func_0806CD78, 0x08072349)) return;

    abi.fetches(41);
    abi.write8(disp_ptr +% 1, abi.read8(disp_ptr +% 1) | 0x20);
    const p_e0 = abi.read32(0x080723E0);
    abi.write8(p_e0, abi.read8(p_e0) & 0xE0);
    const p_e4 = abi.read32(0x080723E4);
    abi.write8(p_e4, abi.read8(p_e4) | 0x1F);

    rt.r[13] +%= 8;
    rt.r[8] = abi.popReg();
    rt.r[9] = abi.popReg();
    rt.r[10] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    rt.r[7] = abi.popReg();
    abi.popReturn();
}

/// Initialize showcase overlay screen C with BG blending and `0x08073C68` (`0x08073364`).
pub fn func_08073364() callconv(.c) void {
    if (!abi.enter(0x08073364)) return;
    abi.fetches(31);
    abi.pushLr();
    abi.pushReg(7);
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.pushReg(10);
    abi.pushReg(9);
    abi.pushReg(8);
    rt.r[13] -%= 8;
    const ui_state = rt.r[0];

    const b1_ptr = abi.read32(0x080734F4);
    abi.write8(b1_ptr +% 1, abi.read8(b1_ptr +% 1) | 0x1F);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_0806CDD0, 0x0807339F)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_0806CD78, 0x080733A5)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080104D4, 0x080733A9)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0x40);
    if (!abi.call(decls.func_0806CD50, 0x080733AF)) return;
    abi.fetches(6);
    rt.r[0] = 0x88 << 3;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_0806CD50, 0x080733B7)) return;

    inline for ([_]struct { pool: u32, ret: u32 }{
        .{ .pool = 0x080734F8, .ret = 0x080733CB },
        .{ .pool = 0x080734FC, .ret = 0x080733DB },
        .{ .pool = 0x08073500, .ret = 0x080733EB },
        .{ .pool = 0x08073504, .ret = 0x080733FB },
    }, 0..) |m, i| {
        abi.fetches(if (i == 0) @as(u32, 12) else 10);
        abi.write32(rt.r[13] +% 0, 0x14);
        abi.write32(rt.r[13] +% 4, 0x40);
        rt.r[0] = abi.read32(m.pool);
        abi.setRegNz(&rt.r[1], 0);
        abi.setRegNz(&rt.r[2], 0);
        abi.setRegNz(&rt.r[3], 0x20);
        if (!abi.call(hw.func_08010C70, m.ret)) return;
    }

    inline for ([_]struct { f: fn () callconv(.c) void, r: u32 }{
        .{ .f = decls.func_08011804, .r = 0x080733FF },
        .{ .f = decls.func_08011814, .r = 0x08073403 },
        .{ .f = decls.func_08011824, .r = 0x08073407 },
        .{ .f = decls.func_08011834, .r = 0x0807340B },
    }) |c| {
        abi.fetches(4);
        if (!abi.call(c.f, c.r)) return;
    }

    abi.fetches(39);
    abi.write16(ui_state +% 0x44, 0);
    const p08 = abi.read32(0x08073508);
    abi.write8(p08, abi.read8(p08) & 0xFC);
    const p0c = abi.read32(0x0807350C);
    abi.write8(p0c, (abi.read8(p0c) & 0xFC) | 1);
    const p10 = abi.read32(0x08073510);
    abi.write8(p10, (abi.read8(p10) & 0xFC) | 2);
    const p14 = abi.read32(0x08073514);
    abi.write8(p14, abi.read8(p14) | 3);

    const inc_ptr = abi.read32(0x08073518);
    const old_idx = abi.read8(inc_ptr);
    abi.write8(inc_ptr, old_idx +% 1);
    rt.r[0] = old_idx;
    rt.updateNz(old_idx);
    if (!abi.call(decls.func_080702EC, 0x08073455)) return;

    abi.fetches(13);
    abi.write16(ui_state +% 0x42, @truncate(rt.r[0]));
    const dst = abi.read32(0x0807351C);
    rt.r[0] = dst;
    rt.r[1] = 0xC0 << 19;
    rt.r[2] = 0x80 << 4;
    rt.updateNz(rt.r[2]);
    if (!abi.call(dma.func_0800FFA8, 0x0807346B)) return;

    abi.fetches(7);
    rt.r[0] = dst;
    rt.r[1] = abi.read32(0x08073520);
    rt.r[2] = 0x80 << 4;
    if (!abi.call(dma.func_0800FFA8, 0x08073475)) return;

    abi.fetches(10);
    const val = abi.read32(0x08073528);
    abi.write16(abi.read32(0x08073524), @truncate(val));
    abi.write16(abi.read32(0x0807352C), @truncate(val));
    if (!abi.call(hw.func_080104B0, 0x08073485)) return;

    abi.fetches(39);
    const p30 = abi.read32(0x08073530);
    abi.write8(p30 +% 0, (abi.read8(p30 +% 0) & 0x3F) | 0x9F);
    abi.write8(p30 +% 1, abi.read8(p30 +% 1) & 0xE0);
    abi.write16(abi.read32(0x08073534), 0x10);
    rt.r[0] = abi.read32(0x08073538);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x080734CF)) return;

    abi.fetches(13);
    const p3c = abi.read32(0x0807353C);
    abi.write8(p3c, abi.read8(p3c) | 0x20);
    const p40 = abi.read32(0x08073540);
    abi.write8(p40, abi.read8(p40) | 0x20);
    if (!abi.call(decls.func_08073C68, 0x080734E5)) return;

    abi.fetches(10);
    rt.r[13] +%= 8;
    rt.r[8] = abi.popReg();
    rt.r[9] = abi.popReg();
    rt.r[10] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    rt.r[7] = abi.popReg();
    abi.popReturn();
}

/// Initialize quad-BG battle/menu showcase with DMA transfer and window clip (`0x080749A0`).
pub fn func_080749A0() callconv(.c) void {
    if (!abi.enter(0x080749A0)) return;
    abi.fetches(19);
    abi.pushLr();
    abi.pushReg(7);
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.pushReg(10);
    abi.pushReg(9);
    abi.pushReg(8);
    rt.r[13] -%= 0xC;
    const ui_state = rt.r[0];

    abi.write32(rt.r[13] +% 8, 0);
    rt.r[0] = rt.r[13] +% 8;
    rt.r[1] = 0xC0 << 19;
    rt.r[2] = abi.read32(0x08074B24);
    rt.updateNz(rt.r[1]);
    if (!abi.call(bios.func_080796C0, 0x080749C3)) return;

    const bg0 = abi.read32(0x08074B28);
    const bg1 = abi.read32(0x08074B2C);
    const bg2 = abi.read32(0x08074B34);
    const bg3 = abi.read32(0x08074B3C);
    inline for ([_]struct { bg: u32, p: u32, f_const: u32, ret: u32 }{
        .{ .bg = bg0, .p = 0, .f_const = 0xC0 << 19, .ret = 0x080749CD },
        .{ .bg = bg1, .p = 0x08074B30, .f_const = 0, .ret = 0x080749D7 },
        .{ .bg = bg2, .p = 0x08074B38, .f_const = 0, .ret = 0x080749E1 },
        .{ .bg = bg3, .p = 0x08074B40, .f_const = 0, .ret = 0x080749EB },
    }) |b| {
        abi.fetches(7);
        rt.r[0] = b.bg;
        rt.r[1] = if (b.p == 0) b.f_const else abi.read32(b.p);
        if (!abi.call(decls.func_08010CD8, b.ret)) return;
    }

    inline for ([_]struct { bg: u32, p: u32, ret: u32 }{
        .{ .bg = bg0, .p = 0x08074B44, .ret = 0x080749F3 },
        .{ .bg = bg1, .p = 0x08074B48, .ret = 0x080749FB },
        .{ .bg = bg2, .p = 0x08074B4C, .ret = 0x08074A03 },
        .{ .bg = bg3, .p = 0x08074B50, .ret = 0x08074A0B },
    }) |b| {
        abi.fetches(6);
        rt.r[0] = b.bg;
        rt.r[1] = abi.read32(b.p);
        if (!abi.call(decls.func_08010CC4, b.ret)) return;
    }

    abi.fetches(18);
    const p54 = abi.read32(0x08074B54);
    abi.write8(p54 +% 1, (abi.read8(p54 +% 1) | 1) & 0xE0);
    if (!abi.call(decls.func_080104D4, 0x08074A2B)) return;
    abi.fetches(4);
    if (!abi.call(hw.func_080104B0, 0x08074A2F)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08074B58);
    rt.r[1] = 0xB0 << 1;
    abi.setRegNz(&rt.r[2], 0x40);
    if (!abi.call(dma.func_08011330, 0x08074A3B)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0xF);
    if (!abi.call(hw.func_0806CEA4, 0x08074A41)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08074B5C);
    rt.r[1] = 0xC0 << 19;
    rt.r[2] = 0xC0 << 4;
    rt.updateNz(rt.r[2]);
    if (!abi.call(dma.func_0800FFA8, 0x08074A4D)) return;

    abi.fetches(13);
    const map_base = abi.read32(0x08074B60);
    abi.write32(rt.r[13] +% 0, 0x20);
    abi.write32(rt.r[13] +% 4, 0);
    rt.r[0] = map_base;
    abi.setRegNz(&rt.r[1], 0x10);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0x10);
    if (!abi.call(hw.func_08010C70, 0x08074A63)) return;

    abi.fetches(11);
    const map5 = abi.read32(0x08074B64);
    abi.write32(rt.r[13], 0);
    rt.r[0] = map_base;
    rt.r[1] = map5;
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_08010C18, 0x08074A75)) return;

    abi.fetches(10);
    abi.write32(rt.r[13], 0);
    rt.r[0] = map_base;
    rt.r[1] = map5;
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0x10);
    if (!abi.call(decls.func_08010C18, 0x08074A85)) return;

    abi.fetches(11);
    abi.write32(rt.r[13] +% 0, 0x20);
    abi.write32(rt.r[13] +% 4, 0);
    rt.r[0] = map_base;
    abi.setRegNz(&rt.r[1], 1);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0x10);
    if (!abi.call(hw.func_08010C70, 0x08074A97)) return;

    abi.fetches(11);
    const m68 = abi.read32(0x08074B68);
    abi.write32(rt.r[13], abi.read32(0x08074B6C));
    rt.r[0] = map_base;
    rt.r[1] = m68;
    abi.setRegNz(&rt.r[2], 5);
    abi.setRegNz(&rt.r[3], 0x14);
    if (!abi.call(decls.func_08010C18, 0x08074AA9)) return;

    abi.fetches(10);
    abi.write32(rt.r[13], abi.read32(0x08074B70));
    rt.r[0] = map_base;
    rt.r[1] = m68;
    abi.setRegNz(&rt.r[2], 9);
    abi.setRegNz(&rt.r[3], 0x14);
    if (!abi.call(decls.func_08010C18, 0x08074AB9)) return;

    abi.fetches(10);
    const vram_dst = abi.read32(0x08074B74);
    rt.r[0] = map_base;
    rt.r[1] = vram_dst;
    rt.r[2] = 0x80 << 4;
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_08010BCC, 0x08074AC9)) return;

    abi.fetches(11);
    abi.write16(ui_state +% 0x1C, 0);
    abi.write16(ui_state +% 0x44, 0x100);
    if (!abi.call(hw.func_080113D0, 0x08074ADB)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08074B78);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 1);
    abi.setRegNz(&rt.r[3], 1);
    if (!abi.call(decls.func_080113E8, 0x08074AE7)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x08074B7C);
    abi.setRegNz(&rt.r[1], 7);
    abi.setRegNz(&rt.r[2], 1);
    abi.setRegNz(&rt.r[3], 1);
    if (!abi.call(decls.func_080113E8, 0x08074AF3)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_080116F4, 0x08074AF7)) return;

    abi.fetches(11);
    const dma_ptr = abi.read32(0x08074B80);
    abi.write32(dma_ptr +% 0, vram_dst);
    abi.write32(dma_ptr +% 4, abi.read32(0x08074B44));
    abi.write32(dma_ptr +% 8, abi.read32(0x08074B84));
    rt.r[0] = abi.read32(dma_ptr +% 8);
    if (!abi.call(clusters_low_2.func_0800FC58, 0x08074B09)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x08074B88);
    if (!abi.call(decls.func_0800FC74, 0x08074B0F)) return;

    abi.fetches(4);
    if (!abi.call(ui.func_080754F4, 0x08074B13)) return;

    abi.fetches(10);
    rt.r[13] +%= 0xC;
    rt.r[8] = abi.popReg();
    rt.r[9] = abi.popReg();
    rt.r[10] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    rt.r[7] = abi.popReg();
    abi.popReturn();
}

/// Allocate decompression staging screen buffer and reset layers (`0x08074CA8`).
pub fn func_08074CA8() callconv(.c) void {
    if (!abi.enter(0x08074CA8)) return;
    abi.fetches(12);
    abi.pushLr();
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.pushReg(8);
    rt.r[13] -%= 4;
    const ui_state = rt.r[0];

    rt.r[0] = 0xA0 << 3;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_08012D8C, 0x08074CBD)) return;

    abi.fetches(7);
    const tmp = rt.r[0];
    rt.r[4] = tmp;
    rt.r[0] = abi.read32(0x08074D2C);
    rt.r[1] = tmp;
    if (!abi.call(bios.func_080796DC, 0x08074CC7)) return;

    abi.fetches(11);
    const map_base = abi.read32(0x08074D30);
    abi.write32(rt.r[13], 0);
    rt.r[0] = map_base;
    rt.r[1] = tmp;
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(decls.func_08010C18, 0x08074CD9)) return;

    abi.fetches(7);
    rt.r[0] = map_base;
    rt.r[1] = abi.read32(0x08074D34);
    rt.r[2] = 0xA0 << 3;
    if (!abi.call(dma.func_0800FFA8, 0x08074CE3)) return;

    abi.fetches(5);
    rt.r[0] = tmp;
    if (!abi.call(decls.func_08012E14, 0x08074CE9)) return;

    abi.fetches(15);
    const p38 = abi.read32(0x08074D38);
    abi.write8(p38 +% 1, abi.read8(p38 +% 1) & 0xF0);
    if (!abi.call(decls.func_080104D4, 0x08074D03)) return;

    abi.fetches(4);
    if (!abi.call(hw.func_080113D0, 0x08074D07)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x08074D3C);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x08074D11)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 1);
    if (!abi.call(decls.func_0801153C, 0x08074D17)) return;

    abi.fetches(4);
    if (!abi.call(tail_low.func_080796A4, 0x08074D1B)) return;

    abi.fetches(11);
    rt.r[0] = 0x80;
    rt.updateNz(0x80);
    abi.write16(ui_state +% 0x44, 0x80);
    rt.r[13] +%= 4;
    rt.r[8] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    abi.popReturn();
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
        @export(&func_08003828, .{ .name = "func_08003828", .linkage = .strong });
        @export(&func_08004888, .{ .name = "func_08004888", .linkage = .strong });
        @export(&func_08004C38, .{ .name = "func_08004C38", .linkage = .strong });
        @export(&func_08005794, .{ .name = "func_08005794", .linkage = .strong });
        @export(&func_08005840, .{ .name = "func_08005840", .linkage = .strong });
        @export(&func_080034F0, .{ .name = "func_080034F0", .linkage = .strong });
        @export(&func_0800353C, .{ .name = "func_0800353C", .linkage = .strong });
        @export(&func_0806EC18, .{ .name = "func_0806EC18", .linkage = .strong });
        @export(&func_08076AA4, .{ .name = "func_08076AA4", .linkage = .strong });
        @export(&func_08070BEC, .{ .name = "func_08070BEC", .linkage = .strong });
        @export(&func_08070D00, .{ .name = "func_08070D00", .linkage = .strong });
        @export(&func_08070DDC, .{ .name = "func_08070DDC", .linkage = .strong });
        @export(&func_08071B54, .{ .name = "func_08071B54", .linkage = .strong });
        @export(&func_0807217C, .{ .name = "func_0807217C", .linkage = .strong });
        @export(&func_08073364, .{ .name = "func_08073364", .linkage = .strong });
        @export(&func_080749A0, .{ .name = "func_080749A0", .linkage = .strong });
        @export(&func_08074B8C, .{ .name = "func_08074B8C", .linkage = .strong });
        @export(&func_08074CA8, .{ .name = "func_08074CA8", .linkage = .strong });
        @export(&func_08018AC0, .{ .name = "func_08018AC0", .linkage = .strong });
        @export(&func_08018B28, .{ .name = "func_08018B28", .linkage = .strong });
        @export(&func_08018B68, .{ .name = "func_08018B68", .linkage = .strong });
    }
}

test "lookupGuardTable matches key or returns fallback at 0xFF sentinel" {
    const entries = [_][8]u8{
        .{ 0x0A, 0x01, 0, 0, 0, 0, 0, 0 },
        .{ 0x0B, 0x04, 0, 0, 0, 0, 0, 0 },
        .{ 0xFF, 0x09, 0, 0, 0, 0, 0, 0 },
    };
    try std.testing.expectEqual(@as(u8, 0x0A), lookupGuardTable(&entries, 0x01, 0x77));
    try std.testing.expectEqual(@as(u8, 0x0B), lookupGuardTable(&entries, 0x04, 0x77));
    try std.testing.expectEqual(@as(u8, 0x77), lookupGuardTable(&entries, 0x09, 0x77));
    try std.testing.expectEqual(@as(u8, 0x77), lookupGuardTable(&entries, 0x02, 0x77));
}

test "calcPackedEntryAddr adds base, data offset, row offset, and column" {
    try std.testing.expectEqual(@as(u32, 0x0200_1023), calcPackedEntryAddr(0x0200_0000, 0x100, 0x1000, 0x20, 3));
}
