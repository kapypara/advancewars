//! Turn transitions, day/CO phase controllers, and tactical menu flow.

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

fn updateTurnPhaseVia32B34(
    comptime phase: u32,
    comptime ptr_ref: u32,
    comptime ret_addr: u32,
    comptime fetches_after: u32,
    comptime copy_src_ref: ?u32,
    comptime copy_dst_ref: ?u32,
) void {
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = abi.read32(ptr_ref);
    rt.r[0] = abi.read16(abi.read32(rt.r[4]));
    abi.setRegNz(&rt.r[1], phase);
    abi.setRegNz(&rt.r[2], 2);
    if (!abi.call(decls.func_08032B34, ret_addr)) return;

    abi.fetches(fetches_after);
    abi.write16(abi.read32(rt.r[4]), @truncate(rt.r[0]));
    if (copy_src_ref) |src_ref| {
        const dst_ptr = abi.read32(copy_dst_ref.?);
        const src_val = abi.read16(abi.read32(src_ref));
        abi.write16(dst_ptr, src_val);
    }

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Center an 8px-per-tile label horizontally across the 240px GBA screen.
pub fn centerTileSpanX(tile_count: u32) u32 {
    return (0xF0 -% (tile_count << 3)) >> 1;
}

/// Reset hardware audio/display state and enable battle transition blending (`0x08032200`).
pub fn func_08032200() callconv(.c) void {
    if (!abi.enter(0x08032200)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080104B0, 0x08032207)) return;
    abi.fetches(25);
    const reg_addr = abi.read32(0x08032234);
    abi.write8(reg_addr, @truncate((abi.read8(reg_addr) & 0x3F) | 0x44));
    abi.write8(reg_addr +% 1, @truncate(abi.read8(reg_addr +% 1) | 0x18));
    abi.write16(abi.read32(0x08032238), 0xF);
    abi.write16(abi.read32(0x0803223C), 6);
    abi.popReturn();
}

/// Advance turn controller state to step `5` (`0x080334F0`).
pub fn func_080334F0() callconv(.c) void {
    if (!abi.enter(0x080334F0)) return;
    updateTurnPhaseVia32B34(5, 0x0803350C, 0x08033501, 7, null, null);
}

/// Advance turn controller state to step `11` (`0x080335D4`).
pub fn func_080335D4() callconv(.c) void {
    if (!abi.enter(0x080335D4)) return;
    updateTurnPhaseVia32B34(0xB, 0x080335F0, 0x080335E5, 7, null, null);
}

/// Advance turn controller state to step `15` and mirror backup state (`0x0803362C`).
pub fn func_0803362C() callconv(.c) void {
    if (!abi.enter(0x0803362C)) return;
    updateTurnPhaseVia32B34(0xF, 0x08033650, 0x0803363D, 11, 0x08033658, 0x08033654);
}

/// End day-banner proc `0x0828_C54C` and reset substate offset `+2` to `3` (`0x080338FC`).
pub fn func_080338FC() callconv(.c) void {
    if (!abi.enter(0x080338FC)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08033910);
    if (!abi.call(decls.func_0801329C, 0x08033905)) return;
    abi.fetches(8);
    const ctrl_ptr = abi.read32(abi.read32(0x08033914));
    abi.write16(ctrl_ptr +% 2, 3);
    abi.popReturn();
}

/// Clear active tile selection in `0x0300_4358` via `0x08030C28(..., -1)` (`0x080343F4`).
pub fn func_080343F4() callconv(.c) void {
    if (!abi.enter(0x080343F4)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08034404);
    rt.r[1] = @bitCast(@as(i32, -1));
    if (!abi.call(decls.func_08030C28, 0x08034401)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Reset display slot scratch fields (`+0x20..+0x2A`), flag `0x0300_48C4`, and refresh via `0x080303E0` (`0x08034514`).
pub fn func_08034514() callconv(.c) void {
    if (!abi.enter(0x08034514)) return;
    abi.fetches(27);
    abi.pushLr();
    const state_ptr = abi.read32(abi.read32(0x0803454C));
    abi.write8(abi.read32(0x08034550), 0);
    inline for ([_]u32{ 0x20, 0x22, 0x2A, 0x28, 0x26, 0x24 }) |off| {
        abi.write16(state_ptr +% off, 0);
    }
    if (!abi.call(decls.func_080303E0, 0x08034547)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn `0x0828_C9FC` proc storing `(r1, r0)` at `+0x20` / `+0x24` and zeroing fields (`0x080346E4`).
pub fn func_080346E4() callconv(.c) void {
    if (!abi.enter(0x080346E4)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[5] = rt.r[0];
    rt.r[4] = rt.r[1];
    rt.r[0] = abi.read32(0x08034708);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x080346F3)) return;

    abi.fetches(12);
    abi.write32(rt.r[0] +% 0x20, rt.r[4]);
    abi.write32(rt.r[0] +% 0x24, rt.r[5]);
    abi.write8(rt.r[0] +% 0x2F, 0);
    abi.write16(rt.r[0] +% 0x2C, 0);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Return centered horizontal X coordinate `(240 - width_tiles * 8) / 2` (`0x08034E44`).
pub fn func_08034E44() callconv(.c) void {
    if (!abi.enter(0x08034E44)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0807A868, 0x08034E4B)) return;
    abi.fetches(9);
    abi.setRegNz(&rt.r[0], centerTileSpanX(rt.r[0]));
    popReturnValue();
}

/// Refresh map fog/HUD via `0x0802ACF8` and transition phase to `8` (`0x08035004`).
pub fn func_08035004() callconv(.c) void {
    if (!abi.enter(0x08035004)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0802ACF8, 0x0803500B)) return;
    abi.fetches(7);
    abi.write16(abi.read32(0x08035014), 8);
    abi.popReturn();
}

/// Clear active action overlay via `0x0802A9D8` and set phase to `10` (`0x08035018`).
pub fn func_08035018() callconv(.c) void {
    if (!abi.enter(0x08035018)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0802A9D8, 0x0803501F)) return;
    abi.fetches(7);
    abi.write16(abi.read32(0x08035028), 0xA);
    abi.popReturn();
}

/// Promote pending sub-phase into `0x0300_357C`, clear `0x0300_48C8`, and update map (`0x0803519C`).
pub fn func_0803519C() callconv(.c) void {
    if (!abi.enter(0x0803519C)) return;
    abi.fetches(11);
    abi.pushLr();
    const dst = abi.read32(0x080351B4);
    const src = abi.read32(0x080351B8);
    abi.write16(dst, abi.read16(src));
    abi.write16(src, 0);
    if (!abi.call(decls.func_08028B9C, 0x080351AF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Store proc halfword `+0x20` as byte `[0x0300_4310 + 0x2C]` and apply via `0x08035274` (`0x080352B8`).
pub fn func_080352B8() callconv(.c) void {
    if (!abi.enter(0x080352B8)) return;
    abi.fetches(10);
    abi.pushLr();
    const dst = abi.read32(0x080352CC) +% 0x2C;
    const val: u8 = @truncate(abi.read16(rt.r[0] +% 0x20));
    abi.write8(dst, val);
    rt.r[0] = abi.read8(dst);
    if (!abi.call(decls.func_08035274, 0x080352C9)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Play sound effect indexed by `proc->+0x20` from 8-byte entry table (`0x080352D0`).
pub fn func_080352D0() callconv(.c) void {
    if (!abi.enter(0x080352D0)) return;
    abi.fetches(12);
    abi.pushLr();
    const tbl = abi.read32(0x080352E8);
    const idx: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[0] +% 0x20)));
    const se_id: u32 = @bitCast(abi.signExtend16(abi.read16(tbl +% (idx << 3) +% 4)));
    rt.r[0] = se_id;
    if (!abi.call(decls.func_0803D880, 0x080352E5)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Call `0x08035E38` for slot struct selected by `proc->+0x1E` (`0x08035884`).
pub fn func_08035884() callconv(.c) void {
    if (!abi.enter(0x08035884)) return;
    abi.fetches(10);
    abi.pushLr();
    const slot: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[0] +% 0x1E)));
    rt.r[0] = (slot << 5) +% abi.read32(0x08035898);
    if (!abi.call(decls.func_08035E38, 0x08035895)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear active byte `+8` on slot struct `proc->+0x1E` and call `0x08035E74` (`0x0803589C`).
pub fn func_0803589C() callconv(.c) void {
    if (!abi.enter(0x0803589C)) return;
    abi.fetches(16);
    abi.pushLr();
    const base = abi.read32(0x080358BC);
    const slot: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[0] +% 0x1E)));
    const entry = (slot << 5) +% base;
    abi.write8(entry +% 8, 0);
    rt.r[0] = entry;
    if (!abi.call(decls.func_08035E74, 0x080358B9)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Look up portrait/frame entry in `0x0808_1B5C` by CO faction and slot (`0x08035A90`).
pub fn func_08035A90() callconv(.c) void {
    if (!abi.enter(0x08035A90)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[5] = abi.read32(0x08035AB8);
    rt.r[0] = abi.read8(rt.r[4] +% 0xA) +% 1;
    if (!abi.call(decls.func_0801BD04, 0x08035A9F)) return;

    abi.fetches(14);
    const col_off = (rt.r[0] & 0xFF) << 2;
    const row_idx = abi.read8(rt.r[4] +% 9);
    const row_off = (row_idx * 9) << 2;
    rt.r[0] = abi.read32(rt.r[5] +% col_off +% row_off);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnValue();
}

/// Invoke `0x08078488(r0, 1)` (`0x08035D34`).
pub fn func_08035D34() callconv(.c) void {
    if (!abi.enter(0x08035D34)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_08078488, 0x08035D3D)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Allocate `0xA20`-byte buffer via `0x08012D8C` and store pointer at `arg->+0x1C` (`0x08036428`).
pub fn func_08036428() callconv(.c) void {
    if (!abi.enter(0x08036428)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    abi.setRegNz(&rt.r[0], 0xA20);
    if (!abi.call(decls.func_08012D8C, 0x08036435)) return;

    abi.fetches(6);
    abi.write32(rt.r[4] +% 0x1C, rt.r[0]);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Free active proc-slot `0x18->+0x1C` allocation via `0x08012E14` (`0x0803643C`).
pub fn func_0803643C() callconv(.c) void {
    if (!abi.enter(0x0803643C)) return;
    abi.fetches(16);
    abi.pushLr();
    const proc_base = abi.read32(0x0803645C);
    const slot: u32 = @bitCast(abi.signExtend16(abi.read16(abi.read32(0x08036460))));
    const slot_data = abi.read32(proc_base +% 0x18 +% (slot * 96));
    rt.r[0] = abi.read32(slot_data +% 0x1C);
    if (!abi.call(decls.func_08012E14, 0x08036459)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Deactivate turn panel slot `+0x18->+8 = 0` and release via `0x08013248` (`0x08036880`).
pub fn func_08036880() callconv(.c) void {
    if (!abi.enter(0x08036880)) return;
    abi.fetches(16);
    abi.pushLr();
    const proc_base = abi.read32(0x080368A0);
    const slot: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    const slot_data = abi.read32(proc_base +% 0x18 +% (slot * 96));
    abi.write8(slot_data +% 8, 0);
    if (!abi.call(decls.func_08013248, 0x0803689D)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Initialize turn panel slot `r0` via `0x08035EE4`, mark active, and clear `0x0300_4470` (`0x080368A4`).
pub fn func_080368A4() callconv(.c) void {
    if (!abi.enter(0x080368A4)) return;
    abi.fetches(15);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const proc_base = abi.read32(0x080368D0);
    const slot: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    rt.r[4] = abi.read32(proc_base +% 0x18 +% (slot * 96));
    rt.r[0] = rt.r[4];
    if (!abi.call(decls.func_08035EE4, 0x080368BF)) return;

    abi.fetches(10);
    abi.write8(rt.r[4] +% 8, 1);
    abi.write16(abi.read32(0x080368D4), 0);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Request unit/map redraw mode `1` via `0x080255C4` (`0x080370D0`).
pub fn func_080370D0() callconv(.c) void {
    if (!abi.enter(0x080370D0)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 1);
    if (!abi.call(decls.func_080255C4, 0x080370D9)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Read ROM message/label string `0x082C_AF8C` via `0x08018400` (`0x080378B8`).
pub fn func_080378B8() callconv(.c) void {
    if (!abi.enter(0x080378B8)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x080378C4);
    if (!abi.call(decls.func_08018400, 0x080378C1)) return;
    abi.fetches(4);
    popReturnValue();
}

fn enterTurnDayPhase(
    comptime base_ref: u32,
    comptime mode_ref: u32,
    comptime tail_ref: u32,
    comptime arg0_val_ref: ?u32,
    comptime mode_byte: ?u8,
    comptime ret1: u32,
    comptime ret2: u32,
    comptime ret3: u32,
) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08034C74, ret1)) return;

    abi.fetches(if (mode_byte != null) 33 else 32);
    const base = abi.read32(base_ref);
    const p32 = base +% 0x32;
    abi.write8(p32, 1);
    abi.write8(p32 +% 7, 0);
    abi.write8(p32 +% 8, 0);
    abi.write8(p32 +% 9, 0);
    abi.write8(p32 +% 10, 0);
    abi.write8(base +% 0xD, 1);
    abi.write8(base +% 0x7, 1);
    abi.write8(base +% 0x2C, 0);
    abi.write8(base +% 0x2D, 1);

    const mode_ptr = abi.read32(abi.read32(mode_ref));
    _ = abi.read8(mode_ptr);
    abi.write8(mode_ptr, mode_byte orelse 1);
    abi.write16(abi.read32(abi.read32(tail_ref)) +% 2, 0);

    rt.r[3] = if (mode_byte) |b| b else abi.read8(mode_ptr);
    rt.r[2] = 0;
    rt.r[1] = 1;
    abi.setRegNz(&rt.r[0], if (arg0_val_ref) |r| abi.read32(r) else 0);
    if (!abi.call(decls.func_08012A30, ret2)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_080322EC, ret3)) return;

    abi.fetches(4);
    abi.popReturn();
}

fn updateTurnHudValue(
    comptime update_fn: fn () callconv(.c) void,
    comptime load_3_args: bool,
    comptime ref0: u32,
    comptime ref1: u32,
    comptime ref2: u32,
    comptime ref3: u32,
    comptime val1: u32,
    comptime r0: u32,
    comptime r1: u32,
    comptime r2: u32,
) void {
    abi.fetches(if (load_3_args) 9 else 7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[0] = abi.read32(ref0);
    rt.r[1] = abi.read32(ref1);
    if (load_3_args) {
        rt.r[2] = abi.read32(ref2);
        abi.setRegNz(&rt.r[3], 0);
    }
    if (!abi.call(update_fn, r0)) return;

    abi.fetches(9);
    const dst_ptr_slot = abi.read32(if (load_3_args) ref3 else ref2);
    rt.r[4] = dst_ptr_slot;
    rt.r[0] = abi.read16(abi.read32(dst_ptr_slot));
    abi.setRegNz(&rt.r[1], val1);
    abi.setRegNz(&rt.r[2], 2);
    if (!abi.call(decls.func_08032B34, r1)) return;

    abi.fetches(7);
    abi.write16(abi.read32(dst_ptr_slot), @truncate(rt.r[0]));
    abi.setRegNz(&rt.r[0], 0x6B);
    if (!abi.call(decls.func_0803D880, r2)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn setTurnDelayAndClearOverlay(comptime neg_one: bool, comptime target_fn: fn () callconv(.c) void, comptime r0: u32, comptime r1: u32) void {
    abi.fetches(if (neg_one) 9 else 8);
    abi.pushLr();
    abi.write16(rt.r[0] +% 0x1E, 0x20);
    abi.setRegNz(&rt.r[0], if (neg_one) @as(u32, @bitCast(@as(i32, -1))) else 1);
    if (!abi.call(target_fn, r0)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080112C0, r1)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Initialize victory/turn summary UI (`0x08031EE0`, `0x08031EE4`, `0x0802FE08`, `0x0802FEA8`) (`0x08031EB4`).
pub fn func_08031EB4() callconv(.c) void {
    if (!abi.enter(0x08031EB4)) return;
    abi.fetches(14);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const obj = abi.read32(0x08031EE0);
    abi.write16(obj +% 6, 0x66);
    abi.write16(obj +% 0xA, 0x66);
    const mgr_slot = abi.read32(0x08031EE4);
    rt.r[4] = mgr_slot;
    abi.write8(abi.read32(mgr_slot) +% 1, 1);
    if (!abi.call(decls.func_0802FE08, 0x08031ECD)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_0802FEA8, 0x08031ED1)) return;

    abi.fetches(9);
    const mgr = abi.read32(mgr_slot);
    _ = abi.read16(mgr +% 4);
    abi.write16(mgr +% 4, 3);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Set turn-end banner flags and notify `0x08030C28`, `0x08013BD0` (`0x08031F68`).
pub fn func_08031F68() callconv(.c) void {
    if (!abi.enter(0x08031F68)) return;
    abi.fetches(15);
    abi.pushLr();
    const mgr = abi.read32(abi.read32(0x08031F90));
    _ = abi.read16(mgr +% 4);
    abi.write16(mgr +% 4, 5);
    abi.write8(abi.read32(0x08031F94) +% 0x32, 1);
    rt.r[0] = abi.read32(0x08031F98);
    if (!abi.call(decls.func_08030C28, 0x08031F83)) return;

    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x08031F9C));
    if (!abi.call(decls.func_08013BD0, 0x08031F8B)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Enter turn-start banner mode `1` (`0x08032590`).
pub fn func_08032590() callconv(.c) void {
    if (!abi.enter(0x08032590)) return;
    enterTurnDayPhase(0x080325DC, 0x080325E0, 0x080325E4, null, null, 0x08032597, 0x080325D3, 0x080325D7);
}

/// Enter turn-start banner mode `3` (`0x080325E8`).
pub fn func_080325E8() callconv(.c) void {
    if (!abi.enter(0x080325E8)) return;
    enterTurnDayPhase(0x08032634, 0x08032638, 0x0803263C, 0x08032640, 3, 0x080325EF, 0x0803262D, 0x08032631);
}

/// Enter turn-start banner mode `2` (`0x08032644`).
pub fn func_08032644() callconv(.c) void {
    if (!abi.enter(0x08032644)) return;
    enterTurnDayPhase(0x08032690, 0x08032694, 0x08032698, null, 2, 0x0803264B, 0x08032689, 0x0803268D);
}

/// Spawn turn card sprite via `0x080498C4` and notify `0x08013BD0([0x08032908])` (`0x080328E8`).
pub fn func_080328E8() callconv(.c) void {
    if (!abi.enter(0x080328E8)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const obj = rt.r[0];
    rt.r[4] = abi.read16(obj +% 0x22);
    rt.r[0] = rt.r[4];
    rt.r[1] = abi.read16(obj +% 0x1E);
    rt.r[2] = abi.read16(obj +% 0x20);
    abi.setRegNz(&rt.r[3], 0x80 << 2);
    if (!abi.call(decls.func_080498C4, 0x080328FB)) return;

    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x08032908));
    if (!abi.call(decls.func_08013BD0, 0x08032903)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Center prompt window `(10, 5, 12, 10)` via `0x080197D8` and start day timer via `0x08032240(0)` (`0x08032B1C`).
pub fn func_08032B1C() callconv(.c) void {
    if (!abi.enter(0x08032B1C)) return;
    abi.fetches(9);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0xA);
    abi.setRegNz(&rt.r[1], 5);
    abi.setRegNz(&rt.r[2], 0xC);
    abi.setRegNz(&rt.r[3], 0xA);
    if (!abi.call(decls.func_080197D8, 0x08032B2B)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_08032240, 0x08032B31)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Update turn HUD pair `(10, 2)` via `0x080346E4` + `0x08032B34` and play SFX `0x6B` (`0x08033118`).
pub fn func_08033118() callconv(.c) void {
    if (!abi.enter(0x08033118)) return;
    updateTurnHudValue(func_080346E4, false, 0x08033140, 0x08033144, 0x08033148, 0, 10, 0x08033123, 0x08033131, 0x0803313B);
}

/// Update turn HUD pair `(9, 2)` via `0x08034678` + `0x08032B34` and play SFX `0x6B` (`0x0803314C`).
pub fn func_0803314C() callconv(.c) void {
    if (!abi.enter(0x0803314C)) return;
    updateTurnHudValue(decls.func_08034678, true, 0x08033178, 0x0803317C, 0x08033180, 0x08033184, 9, 0x0803315B, 0x08033169, 0x08033173);
}

/// Set delay `0x20`, step `0x0801163C(1)`, and clear BG overlay `0x080112C0` (`0x0803340C`).
pub fn func_0803340C() callconv(.c) void {
    if (!abi.enter(0x0803340C)) return;
    setTurnDelayAndClearOverlay(false, decls.func_0801163C, 0x08033419, 0x0803341D);
}

/// Set delay `0x20`, step `0x080116D8(-1)`, and clear BG overlay `0x080112C0` (`0x0803344C`).
pub fn func_0803344C() callconv(.c) void {
    if (!abi.enter(0x0803344C)) return;
    setTurnDelayAndClearOverlay(true, decls.func_080116D8, 0x0803345B, 0x0803345F);
}

/// Sync turn unit selection flags (`[0x080335AC..0x080335B8]`) and look up unit status (`0x0807B564`, `0x0807B488`) (`0x08033574`).
pub fn func_08033574() callconv(.c) void {
    if (!abi.enter(0x08033574)) return;
    abi.fetches(19);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const dst_flag = abi.read32(0x080335AC);
    const src_flag = abi.read32(0x080335B0);
    abi.write8(src_flag, 0);
    abi.write8(dst_flag, abi.read8(src_flag));

    const mgr_slot = abi.read32(0x080335B4);
    const mgr0 = abi.read32(mgr_slot);
    abi.write16(mgr0 +% 2, 3);
    const info_ptr = abi.read32(0x080335B8);
    rt.r[6] = mgr_slot;
    rt.r[5] = mgr0;
    rt.r[4] = info_ptr;
    rt.r[0] = abi.read8(info_ptr +% 2) -% 0xA4;
    abi.setRegNz(&rt.r[1], 3);
    if (!abi.call(decls.func_0807B564, 0x08033597)) return;

    abi.fetches(9);
    abi.write8(mgr0 +% 8, @truncate(rt.r[0]));
    const mgr1 = abi.read32(mgr_slot);
    rt.r[5] = mgr1;
    rt.r[0] = abi.read8(info_ptr +% 2) -% 0xA4;
    abi.setRegNz(&rt.r[1], 3);
    if (!abi.call(decls.func_0807B488, 0x080335A5)) return;

    abi.fetches(6);
    abi.write8(mgr1 +% 9, @truncate(rt.r[0]));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Refresh CO banner `0x080337A8` and compute prompt Y coordinate (`0x0803385C`) (`0x080338B8`).
pub fn func_080338B8() callconv(.c) void {
    if (!abi.enter(0x080338B8)) return;
    abi.fetches(5);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    if (!abi.call(decls.func_080337A8, 0x080338BF)) return;

    abi.fetches(18);
    const s = abi.read32(abi.read32(0x080338E4));
    const v4: i32 = abi.signExtend16(abi.read16(s +% 4));
    const v6: i32 = abi.signExtend16(abi.read16(s +% 6));
    const va: u32 = abi.read16(s +% 0xA);
    const term: u32 = ((@as(u32, @bitCast(v6 -% v4)) << 3) *% va) +% (@as(u32, @bitCast(v4)) << 4);
    const res: u32 = @bitCast(abi.signExtend16(@truncate(term)));
    abi.setRegNz(&rt.r[0], res);
    rt.r[4] = 6;
    if (!abi.call(decls.func_0803385C, 0x080338DF)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down turn menu via `0x08033D38` and reset state via `0x08033C90` (`0x08033FF8`).
pub fn func_08033FF8() callconv(.c) void {
    if (!abi.enter(0x08033FF8)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08033D38, 0x08033FFF)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08033C90, 0x08034003)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Initialize turn stats/phase workspace `[0x08034168..0x08034180]` (`0x0803411C`).
pub fn func_0803411C() callconv(.c) void {
    if (!abi.enter(0x0803411C)) return;
    abi.fetches(19);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const obj = rt.r[0];
    rt.r[6] = obj;
    const init_val = abi.read32(0x0803416C);
    abi.write32(abi.read32(0x08034168), init_val);
    abi.write32(abi.read32(0x08034170), abi.read32(0x08034174) -% init_val);
    const work = abi.read32(0x08034178);
    abi.write32(work +% 0x28, init_val);
    abi.write8(work +% 0x4B, 0);
    rt.r[5] = 0;
    if (!abi.call(decls.func_08069B1C, 0x0803413F)) return;

    abi.fetches(17);
    const s2 = abi.read32(abi.read32(0x0803417C));
    _ = abi.read8(s2 +% 0xA);
    abi.write8(s2 +% 0xA, 4);
    _ = abi.read8(s2 +% 6);
    abi.write8(s2 +% 6, 0);
    const slot4 = abi.read32(0x08034180);
    rt.r[4] = slot4;
    rt.r[0] = abi.read16(abi.read32(slot4));
    abi.setRegNz(&rt.r[1], 1);
    abi.setRegNz(&rt.r[2], 0);
    if (!abi.call(decls.func_08032B34, 0x0803415D)) return;

    abi.fetches(8);
    abi.write16(abi.read32(slot4), @truncate(rt.r[0]));
    abi.write16(obj +% 0x1E, 0);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Enter phase `[0x08034C94]` (`0xC=1, +1=3, +2=1`), sync via `0x08034BA8`/`0x08034C64`, and set `+9=1` (`0x08034C74`).
pub fn func_08034C74() callconv(.c) void {
    if (!abi.enter(0x08034C74)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const p = abi.read32(0x08034C94);
    rt.r[4] = p;
    rt.r[5] = 1;
    abi.write8(p +% 0xC, 1);
    abi.write8(p +% 1, 3);
    abi.write8(p +% 2, 1);
    if (!abi.call(decls.func_08034BA8, 0x08034C87)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08034C64, 0x08034C8B)) return;

    abi.fetches(6);
    abi.write8(p +% 9, 1);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Reset timer words `[0x08034CB4]`/`[0x08034CBC]` from `*[0x08034CB8]` and invoke `0x08018AAC(0)` + `0x0801F114` (`0x08034C98`).
pub fn func_08034C98() callconv(.c) void {
    if (!abi.enter(0x08034C98)) return;
    abi.fetches(12);
    abi.pushLr();
    const v = abi.read32(abi.read32(0x08034CB8));
    abi.write32(abi.read32(0x08034CB4), v);
    abi.write32(abi.read32(0x08034CBC), v);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_08018AAC, 0x08034CAD)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0801F114, 0x08034CB1)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Resolve faction turn slot `0x08034E44(r1)` and dispatch `0x0800FADC` with `u16(r0), r1` (`0x08034E58`).
pub fn func_08034E58() callconv(.c) void {
    if (!abi.enter(0x08034E58)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const a0 = rt.r[0];
    const a1 = rt.r[1];
    rt.r[4] = a0;
    rt.r[5] = a1;
    rt.r[0] = a1;
    if (!abi.call(func_08034E44, 0x08034E65)) return;

    abi.fetches(10);
    rt.r[0] &= 0xFFFF;
    rt.r[4] = a0 & 0xFFFF;
    rt.r[1] = rt.r[4];
    rt.r[2] = a1;
    rt.updateNz(rt.r[4]);
    if (!abi.call(decls.func_0800FADC, 0x08034E75)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Decrement turn reference halfword `[0x0803523C]` (`0x08035230`).
pub fn func_08035230() callconv(.c) void {
    if (!abi.enter(0x08035230)) return;
    abi.fetches(7);
    const ptr = abi.read32(0x0803523C);
    const old_v = abi.read16(ptr);
    rt.cpuSub(&rt.r[0], old_v, 1, true);
    abi.write16(ptr, @truncate(rt.r[0]));
    rt.r[1] = ptr;
    abi.retLr();
}

/// Spawn turn prompt proc `[0x080353D0]` after `0x08035348(u8(r0))`, set `[0x080353CC] = 0x32`, store `r0` at `+0x20` (`0x080353A8`).
pub fn func_080353A8() callconv(.c) void {
    if (!abi.enter(0x080353A8)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const val = rt.r[0] & 0xFF;
    rt.r[4] = val;
    rt.r[0] = val;
    rt.updateNz(val);
    if (!abi.call(decls.func_08035348, 0x080353B5)) return;

    abi.fetches(9);
    abi.write8(abi.read32(0x080353CC), 0x32);
    rt.r[0] = abi.read32(0x080353D0);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x080353C3)) return;

    abi.fetches(6);
    abi.write16(rt.r[0] +% 0x20, @truncate(val));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear/commit both turn menu subwindows `0x08035488` and `0x080355B4` (`0x080357C8`).
pub fn func_080357C8() callconv(.c) void {
    if (!abi.enter(0x080357C8)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08035488, 0x080357CF)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080355B4, 0x080357D3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Update cursor indicator position via `0x08013550` relative to viewport `*[0x08035B14]` (`0x08035AD4`).
pub fn func_08035AD4() callconv(.c) void {
    if (!abi.enter(0x08035AD4)) return;
    abi.fetches(26);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const slot_idx: i32 = abi.signExtend16(abi.read16(abi.read32(0x08035B0C)));
    const slot_off: u32 = @bitCast((slot_idx *% 3) << 5);
    const slot_ptr = slot_off +% abi.read32(0x08035B10);
    const cam = abi.read32(abi.read32(0x08035B14));
    const sx = abi.read16(slot_ptr +% 0x1E);
    const cx = abi.read16(cam +% 4);
    const sy = abi.read16(slot_ptr +% 0x20);
    const cy = abi.read16(cam +% 6);
    const dx: u32 = @bitCast(abi.signExtend16(@truncate(sx -% cx)));
    const dy: u32 = @bitCast(abi.signExtend16(@truncate(sy -% cy -% 2)));
    rt.r[0] = @bitCast(slot_idx);
    rt.r[1] = dx;
    rt.r[2] = dy;
    rt.r[3] = cy;
    rt.r[4] = sx;
    rt.r[5] = cx;
    rt.updateNz(dy);
    if (!abi.call(decls.func_08013550, 0x08035B05)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down both prompt windows `[0x08035D5C]`/`[0x08035D60]` and clear `u16[r0 + 0x1E]` (`0x08035D40`).
pub fn func_08035D40() callconv(.c) void {
    if (!abi.enter(0x08035D40)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved = rt.r[0];
    rt.r[4] = saved;
    rt.r[0] = abi.read32(0x08035D5C);
    if (!abi.call(func_08035D34, 0x08035D4B)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x08035D60);
    if (!abi.call(func_08035D34, 0x08035D51)) return;

    abi.fetches(7);
    abi.setRegNz(&rt.r[0], 0);
    abi.write16(saved +% 0x1E, 0);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Trigger turn transition audio tracks `[0x08035DC8]` and `[0x08035DCC]` via `0x08079244(..., 1, 0)` (`0x08035DAC`).
pub fn func_08035DAC() callconv(.c) void {
    if (!abi.enter(0x08035DAC)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08035DC8);
    abi.setRegNz(&rt.r[1], 1);
    abi.setRegNz(&rt.r[2], 0);
    if (!abi.call(decls.func_08079244, 0x08035DB9)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x08035DCC);
    abi.setRegNz(&rt.r[1], 1);
    abi.setRegNz(&rt.r[2], 0);
    if (!abi.call(decls.func_08079244, 0x08035DC3)) return;

    abi.fetches(4);
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08032200, .{ .name = "func_08032200", .linkage = .strong });
        @export(&func_080334F0, .{ .name = "func_080334F0", .linkage = .strong });
        @export(&func_080335D4, .{ .name = "func_080335D4", .linkage = .strong });
        @export(&func_0803362C, .{ .name = "func_0803362C", .linkage = .strong });
        @export(&func_080338FC, .{ .name = "func_080338FC", .linkage = .strong });
        @export(&func_080343F4, .{ .name = "func_080343F4", .linkage = .strong });
        @export(&func_08034514, .{ .name = "func_08034514", .linkage = .strong });
        @export(&func_080346E4, .{ .name = "func_080346E4", .linkage = .strong });
        @export(&func_08034E44, .{ .name = "func_08034E44", .linkage = .strong });
        @export(&func_08035004, .{ .name = "func_08035004", .linkage = .strong });
        @export(&func_08035018, .{ .name = "func_08035018", .linkage = .strong });
        @export(&func_0803519C, .{ .name = "func_0803519C", .linkage = .strong });
        @export(&func_080352B8, .{ .name = "func_080352B8", .linkage = .strong });
        @export(&func_080352D0, .{ .name = "func_080352D0", .linkage = .strong });
        @export(&func_08035884, .{ .name = "func_08035884", .linkage = .strong });
        @export(&func_0803589C, .{ .name = "func_0803589C", .linkage = .strong });
        @export(&func_08035A90, .{ .name = "func_08035A90", .linkage = .strong });
        @export(&func_08035D34, .{ .name = "func_08035D34", .linkage = .strong });
        @export(&func_08036428, .{ .name = "func_08036428", .linkage = .strong });
        @export(&func_0803643C, .{ .name = "func_0803643C", .linkage = .strong });
        @export(&func_08036880, .{ .name = "func_08036880", .linkage = .strong });
        @export(&func_080368A4, .{ .name = "func_080368A4", .linkage = .strong });
        @export(&func_080370D0, .{ .name = "func_080370D0", .linkage = .strong });
        @export(&func_080378B8, .{ .name = "func_080378B8", .linkage = .strong });
        @export(&func_08031EB4, .{ .name = "func_08031EB4", .linkage = .strong });
        @export(&func_08031F68, .{ .name = "func_08031F68", .linkage = .strong });
        @export(&func_08032590, .{ .name = "func_08032590", .linkage = .strong });
        @export(&func_080325E8, .{ .name = "func_080325E8", .linkage = .strong });
        @export(&func_08032644, .{ .name = "func_08032644", .linkage = .strong });
        @export(&func_080328E8, .{ .name = "func_080328E8", .linkage = .strong });
        @export(&func_08032B1C, .{ .name = "func_08032B1C", .linkage = .strong });
        @export(&func_08033118, .{ .name = "func_08033118", .linkage = .strong });
        @export(&func_0803314C, .{ .name = "func_0803314C", .linkage = .strong });
        @export(&func_0803340C, .{ .name = "func_0803340C", .linkage = .strong });
        @export(&func_0803344C, .{ .name = "func_0803344C", .linkage = .strong });
        @export(&func_08033574, .{ .name = "func_08033574", .linkage = .strong });
        @export(&func_080338B8, .{ .name = "func_080338B8", .linkage = .strong });
        @export(&func_08033FF8, .{ .name = "func_08033FF8", .linkage = .strong });
        @export(&func_0803411C, .{ .name = "func_0803411C", .linkage = .strong });
        @export(&func_08034C74, .{ .name = "func_08034C74", .linkage = .strong });
        @export(&func_08034C98, .{ .name = "func_08034C98", .linkage = .strong });
        @export(&func_08034E58, .{ .name = "func_08034E58", .linkage = .strong });
        @export(&func_08035230, .{ .name = "func_08035230", .linkage = .strong });
        @export(&func_080353A8, .{ .name = "func_080353A8", .linkage = .strong });
        @export(&func_080357C8, .{ .name = "func_080357C8", .linkage = .strong });
        @export(&func_08035AD4, .{ .name = "func_08035AD4", .linkage = .strong });
        @export(&func_08035D40, .{ .name = "func_08035D40", .linkage = .strong });
        @export(&func_08035DAC, .{ .name = "func_08035DAC", .linkage = .strong });
    }
}

test "centerTileSpanX centers 8px tiles across 240px viewport" {
    try std.testing.expectEqual(@as(u32, 120), centerTileSpanX(0));
    try std.testing.expectEqual(@as(u32, 80), centerTileSpanX(10));
    try std.testing.expectEqual(@as(u32, 0), centerTileSpanX(30));
}
