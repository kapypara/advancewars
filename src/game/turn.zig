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
    }
}

test "centerTileSpanX centers 8px tiles across 240px viewport" {
    try std.testing.expectEqual(@as(u32, 120), centerTileSpanX(0));
    try std.testing.expectEqual(@as(u32, 80), centerTileSpanX(10));
    try std.testing.expectEqual(@as(u32, 0), centerTileSpanX(30));
}
