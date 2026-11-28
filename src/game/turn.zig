//! Turn transitions, day/CO phase controllers, and tactical menu flow.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const battle = @import("battle.zig");
const clusters_low = @import("clusters_low.zig");
const clusters_low_2 = @import("clusters_low_2.zig");
const hw = @import("hw.zig");
const low_peel_1 = @import("low_peel_1.zig");
const low_peel_2 = @import("low_peel_2.zig");
const low_peel_3 = @import("low_peel_3.zig");
const low_peel_4 = @import("low_peel_4.zig");
const map = @import("map.zig");
const math = @import("math.zig");
const mem = @import("mem.zig");
const sound = @import("sound.zig");
const sprite_anim = @import("sprite_anim.zig");
const state = @import("state.zig");
const tail_low = @import("tail_low.zig");
const types = @import("types.zig");
const ui = @import("ui.zig");
const unit = @import("unit.zig");

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
    if (!abi.call(hw.func_080104B0, 0x08032207)) return;
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

fn advanceTurnPhaseIfMode3(comptime phase: u32, comptime arg2: u32, comptime ret_addr: u32) bool {
    const mode = mem.readU8(mem.readU32(types.addr.turn_mode_ptr));
    rt.r[0] = mode;
    rt.cpuSub(null, mode, 3, true);
    if (mode == 3) {
        abi.fetches(9);
        rt.r[4] = types.addr.map_overlay_ptr;
        rt.r[0] = mem.readU16(mem.readU32(types.addr.map_overlay_ptr));
        abi.setRegNz(&rt.r[1], phase);
        abi.setRegNz(&rt.r[2], arg2);
        if (!abi.call(decls.func_08032B34, ret_addr)) return false;
        abi.fetches(4);
        const dst = mem.readU32(rt.r[4]);
        rt.r[1] = dst;
        mem.writeU16(dst, @truncate(rt.r[0]));
    }
    return true;
}

/// Play SFX `0x6C` and advance turn controller to phase `0xC` when mode is `3` (`0x08033464`).
pub fn func_08033464() callconv(.c) void {
    if (!abi.enter(0x08033464)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.pushReg(4);
    if (!sound.playSfxCall(0x6C, 0x0803346D)) return;
    abi.fetches(7);
    if (!advanceTurnPhaseIfMode3(0xC, 2, 0x08033485)) return;
    abi.fetches(5);
    rt.r[4] = abi.popReg();
    abi.popReturn();
}

/// Advance turn controller to phase `0xD` when mode is `3` (`0x08033498`).
pub fn func_08033498() callconv(.c) void {
    if (!abi.enter(0x08033498)) return;
    abi.fetches(8);
    abi.pushLr();
    abi.pushReg(4);
    if (!advanceTurnPhaseIfMode3(0xD, 0, 0x080334B3)) return;
    abi.fetches(5);
    rt.r[4] = abi.popReg();
    abi.popReturn();
}

/// Dispatch banner/phase event `r0.0x1C + 5` via `0x0801A7A4` when mode is `3` (`0x080334C4`).
pub fn func_080334C4() callconv(.c) void {
    if (!abi.enter(0x080334C4)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.cpuAdd(&rt.r[1], rt.r[0], 0, true);
    const mode = mem.readU8(mem.readU32(types.addr.turn_mode_ptr));
    rt.r[0] = mode;
    rt.cpuSub(null, mode, 3, true);
    if (mode == 3) {
        abi.fetches(11);
        const idx: u8 = mem.readU8(rt.r[1] +% 0x1C) +% 5;
        abi.setRegNz(&rt.r[0], idx);
        rt.r[1] = 0x0202_D000;
        abi.setRegNz(&rt.r[2], @as(u32, 0xE5) << 3);
        if (!abi.call(decls.func_0801A7A4, 0x080334E5)) return;
    }
    abi.fetches(4);
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
    if (!abi.call(clusters_low_2.func_080303E0, 0x08034547)) return;
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
    if (!abi.call(low_peel_2.func_0807A868, 0x08034E4B)) return;
    abi.fetches(9);
    abi.setRegNz(&rt.r[0], centerTileSpanX(rt.r[0]));
    popReturnValue();
}

/// Refresh map fog/HUD via `0x0802ACF8` and transition phase to `8` (`0x08035004`).
pub fn func_08035004() callconv(.c) void {
    if (!abi.enter(0x08035004)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(unit.func_0802ACF8, 0x0803500B)) return;
    abi.fetches(7);
    abi.write16(abi.read32(0x08035014), 8);
    abi.popReturn();
}

/// Clear active action overlay via `0x0802A9D8` and set phase to `10` (`0x08035018`).
pub fn func_08035018() callconv(.c) void {
    if (!abi.enter(0x08035018)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(unit.func_0802A9D8, 0x0803501F)) return;
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
    if (!abi.call(sound.func_0803D880, 0x080352E5)) return;
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
    if (!abi.call(low_peel_4.func_08035E38, 0x08035895)) return;
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
    if (!abi.call(low_peel_1.func_0801BD04, 0x08035A9F)) return;

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
    if (!abi.call(sound.func_08078488, 0x08035D3D)) return;
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
    if (!abi.call(low_peel_3.func_08012D8C, 0x08036435)) return;

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
    if (!abi.call(low_peel_3.func_08012E14, 0x08036459)) return;
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
    if (!abi.call(low_peel_4.func_080255C4, 0x080370D9)) return;
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
    if (!abi.call(func_08034C74, ret1)) return;

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
    if (!abi.call(sprite_anim.func_08012A30, ret2)) return;

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
    if (!abi.call(sound.func_0803D880, r2)) return;

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
    if (!abi.call(hw.func_080112C0, r1)) return;
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
    if (!abi.call(low_peel_1.func_0802FEA8, 0x08031ED1)) return;

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
    if (!abi.call(low_peel_1.func_08013BD0, 0x08031F8B)) return;

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
    if (!abi.call(low_peel_1.func_08013BD0, 0x08032903)) return;

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
    if (!abi.call(func_08032240, 0x08032B31)) return;
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
    setTurnDelayAndClearOverlay(false, low_peel_3.func_0801163C, 0x08033419, 0x0803341D);
}

/// Set delay `0x20`, step `0x080116D8(-1)`, and clear BG overlay `0x080112C0` (`0x0803344C`).
pub fn func_0803344C() callconv(.c) void {
    if (!abi.enter(0x0803344C)) return;
    setTurnDelayAndClearOverlay(true, low_peel_3.func_080116D8, 0x0803345B, 0x0803345F);
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
    if (!abi.call(math.func_0807B564, 0x08033597)) return;

    abi.fetches(9);
    abi.write8(mgr0 +% 8, @truncate(rt.r[0]));
    const mgr1 = abi.read32(mgr_slot);
    rt.r[5] = mgr1;
    rt.r[0] = abi.read8(info_ptr +% 2) -% 0xA4;
    abi.setRegNz(&rt.r[1], 3);
    if (!abi.call(math.func_0807B488, 0x080335A5)) return;

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
    if (!abi.call(ui.func_0803385C, 0x080338DF)) return;

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
    if (!abi.call(hw.func_08069B1C, 0x0803413F)) return;

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
    if (!abi.call(clusters_low_2.func_08034BA8, 0x08034C87)) return;

    abi.fetches(4);
    if (!abi.call(state.func_08034C64, 0x08034C8B)) return;

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
    if (!abi.call(state.func_08018AAC, 0x08034CAD)) return;
    abi.fetches(4);
    if (!abi.call(clusters_low_2.func_0801F114, 0x08034CB1)) return;
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
    if (!abi.call(sprite_anim.func_08013550, 0x08035B05)) return;

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

/// Clear IRQ/DMA flags (`0x0807AE50`, `0x0807AE60`) after `0x08030708` and update `[0x08032128]`/`[0x0803212C]` (`0x080320E4`).
pub fn func_080320E4() callconv(.c) void {
    if (!abi.enter(0x080320E4)) return;
    abi.fetches(5);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    if (!abi.call(func_08030708, 0x080320EB)) return;

    abi.fetches(11);
    const base = abi.read32(0x08032124);
    abi.write16(base, 0);
    abi.write16(base -% 0xC, 0);
    abi.setRegNz(&rt.r[0], 7);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(hw.func_0807AE50, 0x080320FD)) return;

    abi.fetches(6);
    abi.setRegNz(&rt.r[0], 6);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(hw.func_0807AE50, 0x08032105)) return;

    abi.fetches(7);
    abi.setRegNz(&rt.r[0], 1);
    rt.r[1] = 0 -% @as(u32, 0xC1);
    if (!abi.call(decls.func_0807AE60, 0x0803210F)) return;

    abi.fetches(13);
    const target_obj = abi.read32(abi.read32(0x08032128));
    abi.write8(target_obj +% 6, 0xFF);
    const flag_ptr = abi.read32(0x0803212C) +% 0x32;
    abi.write8(flag_ptr, 0);
    abi.setRegNz(&rt.r[0], flag_ptr);
    rt.r[1] = target_obj;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Configure PPU BG/blend/window registers for faction `r0` from table `[0x080322D4]` and call `0x08032200` (`0x08032240`).
pub fn func_08032240() callconv(.c) void {
    if (!abi.enter(0x08032240)) return;
    abi.fetches(69);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const faction = rt.r[0];
    const disp = abi.read32(0x080322CC);
    abi.write8(disp +% 1, abi.read8(disp +% 1) | 0x40);
    const tbl = abi.read32(0x080322D4);
    const f_x2 = faction << 3;
    const f_x4 = faction << 2;
    const w0_h = abi.read8(tbl +% f_x2);
    const w1_h = abi.read8(tbl +% ((f_x4 +% 2) << 1));
    abi.write8(abi.read32(0x080322D0), w0_h);
    abi.write8(abi.read32(0x080322D8), w0_h +% w1_h);

    const w0_v_ptr = tbl +% ((f_x4 +% 1) << 1);
    const w0_v = abi.read8(w0_v_ptr);
    const w1_v = abi.read8(tbl +% ((f_x4 +% 3) << 1));
    abi.write8(abi.read32(0x080322DC), w0_v);
    abi.write8(abi.read32(0x080322E0), w0_v +% w1_v);

    const win_in = abi.read32(0x080322E4);
    const mask_in: u8 = @truncate(0 -% @as(u32, 0x21));
    abi.write8(win_in +% 1, (abi.read8(win_in +% 1) | 0x1F) & mask_in);

    const bld = abi.read32(0x080322E8);
    abi.write16(bld, 0);
    const bld_lo = ((abi.read8(bld) | 1) & @as(u8, @truncate(0 -% @as(u32, 3)))) | 0x3C;
    abi.write8(bld, bld_lo);
    if (!abi.call(func_08032200, 0x080322C7)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear `2x8` BG box `[0x0803328C]`, flush BG, and draw day-step badge at `(r0+0x1E, r0+0x20)` (`0x0803323C`).
pub fn func_0803323C() callconv(.c) void {
    if (!abi.enter(0x0803323C)) return;
    abi.fetches(16);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const obj = rt.r[0];
    abi.write32(rt.r[13], 2);
    abi.write32(rt.r[13] +% 4, 0x174);
    rt.r[0] = abi.read32(0x0803328C);
    abi.setRegNz(&rt.r[1], 0xC);
    abi.setRegNz(&rt.r[2], 8);
    abi.setRegNz(&rt.r[3], 2);
    if (!abi.call(hw.func_08010C70, 0x08033259)) return;

    abi.fetches(4);
    if (!abi.call(low_peel_1.func_08011804, 0x0803325D)) return;

    abi.fetches(13);
    const sx: u32 = @bitCast(abi.signExtend16(abi.read16(obj +% 0x1E)));
    const sy: u32 = @bitCast(abi.signExtend16(abi.read16(obj +% 0x20)));
    const icon_tbl = abi.read32(0x08033290);
    abi.setRegNz(&rt.r[0], abi.read32(abi.read32(0x08033294)) >> 3);
    abi.setRegNz(&rt.r[1], 3);
    if (!abi.call(math.func_0807B6AC, 0x08033273)) return;

    abi.fetches(10);
    const idx = (rt.r[0] << 2);
    rt.r[0] = sx;
    rt.r[1] = sy;
    rt.r[2] = abi.read32(icon_tbl +% idx);
    rt.r[3] = abi.read32(0x08033298);
    if (!abi.call(hw.func_0801B888, 0x08033283)) return;

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

/// Initialize turn banner workspace `[0x08033374]/[0x08033378]`, clear `2x8` BG box, and commit banner tiles (`0x08033300`).
pub fn func_08033300() callconv(.c) void {
    if (!abi.enter(0x08033300)) return;
    abi.fetches(27);
    abi.pushLr();
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const work = abi.read32(abi.read32(0x08033374));
    const slot_ref = abi.read32(0x08033378);
    abi.write32(slot_ref, work +% 0xC);
    const bg_buf = abi.read32(0x0803337C);
    abi.write32(rt.r[13], 2);
    abi.write32(rt.r[13] +% 4, 0x174);
    rt.r[0] = bg_buf;
    abi.setRegNz(&rt.r[1], 0xC);
    abi.setRegNz(&rt.r[2], 8);
    abi.setRegNz(&rt.r[3], 2);
    if (!abi.call(hw.func_08010C70, 0x08033333)) return;

    abi.fetches(26);
    abi.write8(work +% 0x18, 1);
    const flags = (abi.read8(work +% 0x1C) & @as(u8, @truncate(@as(u32, 1) -% 0x81))) | 0x64;
    abi.write8(work +% 0x1C, flags);
    const slot = abi.read32(slot_ref);
    abi.write8(slot, 0x17);
    abi.write8(slot +% 7, 2);
    abi.write32(rt.r[13], 0x4000);
    abi.write32(rt.r[13] +% 4, 0);
    abi.setRegNz(&rt.r[0], 0x18);
    abi.setRegNz(&rt.r[1], 8);
    rt.r[2] = bg_buf;
    rt.r[3] = abi.read32(0x08033380);
    if (!abi.call(decls.func_08012A68, 0x08033363)) return;

    abi.fetches(4);
    if (!abi.call(low_peel_1.func_08011804, 0x08033367)) return;

    abi.fetches(8);
    rt.r[13] +%= 8;
    rt.r[3] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = rt.r[3];
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

/// Reset timer `[r0+0x1C] = 0x20`, wait VBlank `0x080113D0`, set fade `0x08011660(0x11, -1)`, and flush (`0x080333B0`).
pub fn func_080333B0() callconv(.c) void {
    if (!abi.enter(0x080333B0)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.write16(rt.r[0] +% 0x1C, 0x20);
    if (!abi.call(hw.func_080113D0, 0x080333BB)) return;

    abi.fetches(7);
    abi.setRegNz(&rt.r[0], 0x11);
    rt.cpuSub(&rt.r[1], 0, 1, true);
    if (!abi.call(decls.func_08011660, 0x080333C5)) return;

    abi.fetches(4);
    if (!abi.call(tail_low.func_080796A4, 0x080333C9)) return;

    abi.fetches(4);
    if (!abi.call(hw.func_080112C0, 0x080333CD)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Clear BG layers (`0x08011910..0x08011824`) and zero `[0x080340F0]` / `[0x080340F4]` (`0x080340C8`).
pub fn func_080340C8() callconv(.c) void {
    if (!abi.enter(0x080340C8)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(low_peel_3.func_08011910, 0x080340CF)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_3.func_0801193C, 0x080340D3)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_3.func_08011968, 0x080340D7)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_1.func_08011804, 0x080340DB)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_1.func_08011814, 0x080340DF)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_1.func_08011824, 0x080340E3)) return;

    abi.fetches(9);
    const tail_ptr = abi.read32(0x080340F4);
    abi.write16(abi.read32(0x080340F0), 0);
    abi.write16(tail_ptr, 0);
    abi.setRegNz(&rt.r[0], tail_ptr);
    abi.setRegNz(&rt.r[1], 0);
    abi.popReturn();
}

/// Clear turn preview fields (`0x20..0x2A`), copy unit summary bytes from `[0x08034488]` into `[0x0803448C]`, and refresh (`0x08034408`).
pub fn func_08034408() callconv(.c) void {
    if (!abi.enter(0x08034408)) return;
    abi.fetches(27);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const work = abi.read32(abi.read32(0x0803447C));
    const ready_flag = abi.read32(0x08034480);
    abi.write8(ready_flag, 0);
    abi.write16(work +% 0x20, 0);
    abi.write16(work +% 0x22, 0);
    abi.write16(work +% 0x2A, 0);
    abi.write16(work +% 0x28, 0);
    abi.write16(work +% 0x26, 0);
    abi.write16(work +% 0x24, 0);
    if (!abi.call(clusters_low_2.func_080303E0, 0x0803443B)) return;

    abi.fetches(29);
    const unit_idx = abi.signExtend16(abi.read16(abi.read32(0x08034484)));
    const src = (@as(u32, @bitCast(unit_idx *% 3)) << 5) +% abi.read32(0x08034488);
    const dst = abi.read32(0x0803448C);
    abi.write8(dst, abi.read8(src +% 0x28));
    abi.write8(dst +% 1, @truncate(abi.read16(src +% 0x2A) >> 8));
    abi.write8(dst +% 2, @truncate(abi.read16(src +% 0x2A)));
    abi.write8(dst +% 3, abi.read8(src +% 0x2E));
    if (!abi.call(decls.func_08031BA0, 0x08034471)) return;

    abi.fetches(7);
    abi.write8(ready_flag, 1);
    abi.setRegNz(&rt.r[0], 1);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Populate turn summary struct `[0x080349DC]`, format label `[0x080349E8]` via `0x08034850`, and commit `0x08031BA0` (`0x08034988`).
pub fn func_08034988() callconv(.c) void {
    if (!abi.enter(0x08034988)) return;
    abi.fetches(35);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const idx = rt.r[1] & 0xFF;
    const rec = abi.read32(abi.read32(0x080349D8)) +% ((idx *% 3) << 2);
    const dst = abi.read32(0x080349DC);
    abi.write8(dst, @truncate(rt.r[0]));
    const p_a = abi.read32(0x080349E0);
    abi.write8(dst +% 2, @truncate(abi.read16(p_a)));
    abi.write8(dst +% 3, @truncate(abi.read16(p_a +% 2)));
    const p_b = abi.read32(0x080349E4);
    abi.write8(dst +% 4, @truncate(abi.read16(p_b)));
    abi.write8(dst +% 5, @truncate(abi.read16(p_b +% 2)));
    abi.write8(dst +% 1, @truncate(idx));
    abi.write8(dst +% 6, @truncate(rt.r[2]));
    abi.write8(dst +% 7, @truncate(rt.r[3]));
    abi.write8(dst +% 0x12, abi.read8(rec +% 6) & 0x7F);

    rt.r[0] = abi.read32(0x080349E8);
    rt.r[1] = dst +% 0xC;
    if (!abi.call(low_peel_4.func_08034850, 0x080349CB)) return;

    abi.fetches(5);
    rt.r[0] = dst;
    if (!abi.call(decls.func_08031BA0, 0x080349D1)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down tactical sub-panels (`0x0801F058`, `0x0801F17C`, `0x0801F0E4`, `0x0801F0FC`, `0x08024D9C`) (`0x08034CC0`).
pub fn func_08034CC0() callconv(.c) void {
    if (!abi.enter(0x08034CC0)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(map.func_0801F058, 0x08034CC7)) return;
    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x08034CE0) +% 2);
    if (!abi.call(decls.func_0801F17C, 0x08034CCF)) return;
    abi.fetches(4);
    if (!abi.call(map.func_0801F0E4, 0x08034CD3)) return;
    abi.fetches(4);
    if (!abi.call(map.func_0801F0FC, 0x08034CD7)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08024D9C, 0x08034CDB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Center prompt via `0x08034E44`/`0x08034E58` and draw flanking brackets via `0x0801B888` (`0x08034E7C`).
pub fn func_08034E7C() callconv(.c) void {
    if (!abi.enter(0x08034E7C)) return;
    abi.fetches(11);
    abi.pushLr();
    const saved_r9 = rt.r[9];
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);

    const base_x = rt.r[0];
    const y = rt.r[1];
    rt.r[0] = y;
    if (!abi.call(func_08034E44, 0x08034E8F)) return;

    abi.fetches(7);
    const center_x = rt.r[0];
    rt.r[0] = base_x;
    rt.r[1] = y;
    if (!abi.call(func_08034E58, 0x08034E99)) return;

    abi.fetches(18);
    const left_x: u32 = @bitCast(abi.signExtend16(@truncate(center_x -% 0x10)));
    const draw_y: u32 = @bitCast(abi.signExtend16(@truncate(base_x -% 4)));
    const gfx = abi.read32(0x08034EE0);
    const attr = abi.read32(0x08034EE4);
    rt.r[0] = left_x;
    rt.r[1] = draw_y;
    rt.r[2] = gfx;
    rt.r[3] = attr;
    if (!abi.call(hw.func_0801B888, 0x08034EB9)) return;

    abi.fetches(5);
    rt.r[0] = y;
    if (!abi.call(low_peel_2.func_0807A868, 0x08034EBF)) return;

    abi.fetches(12);
    const right_x: u32 = @bitCast(abi.signExtend16(@truncate(center_x +% (rt.r[0] << 3))));
    rt.r[0] = right_x;
    rt.r[1] = draw_y;
    rt.r[2] = gfx;
    rt.r[3] = attr;
    if (!abi.call(hw.func_0801B888, 0x08034ED3)) return;

    abi.fetches(8);
    rt.r[3] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[9] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = rt.r[3];
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Reset turn/minimap sub-controllers and cursor visuals (`0x080340F8`).
pub fn func_080340F8() callconv(.c) void {
    if (!abi.enter(0x080340F8)) return;
    abi.fetches(5);
    abi.pushLr();
    const steps = .{
        .{ ui.func_0803293C, @as(u32, 0x080340FF) },
        .{ ui.func_080328B8, @as(u32, 0x08034103) },
        .{ clusters_low_2.func_0800FC58, @as(u32, 0x08034107) },
        .{ ui.func_0803322C, @as(u32, 0x0803410B) },
        .{ ui.func_080333A0, @as(u32, 0x0803410F) },
        .{ ui.func_0803401C, @as(u32, 0x08034113) },
        .{ func_080338FC, @as(u32, 0x08034117) },
    };
    inline for (steps) |s| {
        if (!abi.call(s[0], s[1])) return;
        abi.fetches(4);
    }
    abi.popReturn();
}

/// Tear down turn/combat UI subsystems and clear active turn phase pointer (`0x0802FCBC`).
pub fn func_0802FCBC() callconv(.c) void {
    if (!abi.enter(0x0802FCBC)) return;
    abi.fetches(5);
    abi.pushLr();
    const pre_calls = .{
        .{ clusters_low.func_0801B820, @as(u32, 0x0802FCC3) },
        .{ func_08034C98, @as(u32, 0x0802FCC7) },
        .{ func_08034C74, @as(u32, 0x0802FCCB) },
        .{ clusters_low_2.func_080149E0, @as(u32, 0x0802FCCF) },
        .{ clusters_low_2.func_080134D4, @as(u32, 0x0802FCD3) },
        .{ clusters_low_2.func_0800FC58, @as(u32, 0x0802FCD7) },
        .{ clusters_low_2.func_0800FBC4, @as(u32, 0x0802FCDB) },
        .{ clusters_low_2.func_08018290, @as(u32, 0x0802FCDF) },
        .{ clusters_low_2.func_08036464, @as(u32, 0x0802FCE3) },
        .{ clusters_low_2.func_0800F164, @as(u32, 0x0802FCE7) },
        .{ state.func_0801CCF0, @as(u32, 0x0802FCEB) },
        .{ clusters_low_2.func_08010A00, @as(u32, 0x0802FCEF) },
        .{ hw.func_08010AD8, @as(u32, 0x0802FCF3) },
    };
    inline for (pre_calls) |c| {
        if (!abi.call(c[0], c[1])) return;
        abi.fetches(4);
    }
    abi.fetches(2); // blk 13 had 3 fetches, blk 14 had 3 fetches -> net +2 over fetches(4)
    if (!abi.call(low_peel_3.func_080104D4, 0x0802FCF7)) return;
    abi.fetches(6);
    if (!abi.call(hw.func_080104B0, 0x0802FCFB)) return;
    abi.fetches(7);
    if (!abi.call(decls.func_08010974, 0x0802FCFF)) return;
    abi.fetches(4);
    if (!abi.call(clusters_low_2.func_08042E24, 0x0802FD03)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x0802FD24);
    if (!abi.call(decls.func_08010D00, 0x0802FD09)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x0802FD28);
    if (!abi.call(decls.func_0806CBE8, 0x0802FD0F)) return;
    const post_calls = .{
        .{ clusters_low_2.func_0800FD54, @as(u32, 0x0802FD13) },
        .{ clusters_low_2.func_0800FBC4, @as(u32, 0x0802FD17) },
        .{ low_peel_1.func_080117E0, @as(u32, 0x0802FD1B) },
    };
    inline for (post_calls) |c| {
        abi.fetches(4);
        if (!abi.call(c[0], c[1])) return;
    }
    abi.fetches(7);
    rt.r[1] = abi.read32(0x0802FD2C);
    rt.r[0] = 0;
    rt.updateNz(0);
    abi.write32(rt.r[1], 0);
    abi.popReturn();
}

/// Reset battle/turn phase scratchpad struct and copy default bounds `[0x080307C0]->[0x080307BC]` (`0x08030708`).
pub fn func_08030708() callconv(.c) void {
    if (!abi.enter(0x08030708)) return;
    abi.fetches(4);
    abi.pushLr();
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    const g0 = abi.read32(0x080307A0);
    abi.fetches(42);
    abi.write8(g0 +% 0x32, 0);
    const mgr_ptr = abi.read32(0x080307A4);
    const mgr = abi.read32(mgr_ptr);
    abi.write8(mgr +% 0x0, 0);
    abi.write8(abi.read32(mgr_ptr) +% 0x1, 0);
    const cur = abi.read32(mgr_ptr);
    abi.write16(cur +% 0x4, 0);
    abi.write16(cur +% 0x2, 0);
    abi.write8(abi.read32(0x080307A8), 0);
    abi.write8(cur +% 0x6, 0xFF);
    for ([_]u32{ 0x7, 0x8, 0x9, 0x1C, 0x1D, 0x1E }) |off| {
        abi.write8(abi.read32(mgr_ptr) +% off, 0);
    }
    rt.r[4] = mgr_ptr;
    rt.r[5] = 0;
    rt.r[6] = 0;
    rt.r[0] = 0xFF;
    rt.updateNz(0xFF);
    if (!abi.call(battle.func_080305E4, 0x0803075D)) return;
    abi.fetches(4);
    if (!abi.call(clusters_low_2.func_080303E0, 0x08030761)) return;
    abi.fetches(4);
    if (!abi.call(clusters_low_2.func_08030634, 0x08030765)) return;

    abi.fetches(32);
    const base_a = abi.read32(mgr_ptr);
    abi.write16(base_a +% abi.read32(0x080307AC), 0);
    abi.write8(base_a +% abi.read32(0x080307B0), 0);
    const base_b = abi.read32(mgr_ptr);
    abi.write8(base_b +% abi.read32(0x080307B4), 0);
    const base_c = abi.read32(mgr_ptr);
    abi.write8(base_c +% abi.read32(0x080307B8), 0xFF);

    const dst = abi.read32(0x080307BC);
    const src = abi.read32(0x080307C0);
    const w0 = abi.read32(src +% 0);
    const w1 = abi.read32(src +% 4);
    const w2 = abi.read32(src +% 8);
    abi.write32(dst +% 0, w0);
    abi.write32(dst +% 4, w1);
    abi.write32(dst +% 8, w2);
    rt.r[1] = dst +% 12;
    rt.r[2] = w0;
    rt.r[3] = w1;
    abi.write32(abi.read32(0x080307C4), 0);
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
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
        @export(&func_08033464, .{ .name = "func_08033464", .linkage = .strong });
        @export(&func_08033498, .{ .name = "func_08033498", .linkage = .strong });
        @export(&func_080334C4, .{ .name = "func_080334C4", .linkage = .strong });
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
        @export(&func_080320E4, .{ .name = "func_080320E4", .linkage = .strong });
        @export(&func_08032240, .{ .name = "func_08032240", .linkage = .strong });
        @export(&func_0803323C, .{ .name = "func_0803323C", .linkage = .strong });
        @export(&func_08033300, .{ .name = "func_08033300", .linkage = .strong });
        @export(&func_080333B0, .{ .name = "func_080333B0", .linkage = .strong });
        @export(&func_080340C8, .{ .name = "func_080340C8", .linkage = .strong });
        @export(&func_08034408, .{ .name = "func_08034408", .linkage = .strong });
        @export(&func_08034988, .{ .name = "func_08034988", .linkage = .strong });
        @export(&func_08034CC0, .{ .name = "func_08034CC0", .linkage = .strong });
        @export(&func_08034E7C, .{ .name = "func_08034E7C", .linkage = .strong });
        @export(&func_080340F8, .{ .name = "func_080340F8", .linkage = .strong });
        @export(&func_0802FCBC, .{ .name = "func_0802FCBC", .linkage = .strong });
        @export(&func_08030708, .{ .name = "func_08030708", .linkage = .strong });
    }
}

test "centerTileSpanX centers 8px tiles across 240px viewport" {
    try std.testing.expectEqual(@as(u32, 120), centerTileSpanX(0));
    try std.testing.expectEqual(@as(u32, 80), centerTileSpanX(10));
    try std.testing.expectEqual(@as(u32, 0), centerTileSpanX(30));
    try std.testing.expectEqual(@as(u32, 0x0828_BFFC), types.addr.turn_mode_ptr);
    try std.testing.expectEqual(@as(u32, 0x0828_C05C), types.addr.map_overlay_ptr);
}
