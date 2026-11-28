//! Lifted Advance Wars main frame loop and soft-reset check (`0x080383F8`, `0x08038824`).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const battle = @import("battle.zig");
const hw = @import("hw.zig");
const low_peel_10 = @import("low_peel_10.zig");
const low_peel_11 = @import("low_peel_11.zig");
const low_peel_6 = @import("low_peel_6.zig");
const mem = @import("mem.zig");
const sound = @import("sound.zig");
const sprite_anim = @import("sprite_anim.zig");
const types = @import("types.zig");

/// Return true if active-low `KEYINPUT` has A + B + Select + Start pressed simultaneously.
pub fn isSoftResetComboPressed(keyinput: u16) bool {
    return (hw.decodeActiveLowKeys(keyinput) & types.key_mask_soft_reset) == types.key_mask_soft_reset;
}

/// Check `KEYINPUT` for A+B+Select+Start soft-reset combo and trigger soft reset (`0x08038824`).
fn func_08038824() callconv(.c) void {
    if (!abi.enter(0x08038824)) return;
    abi.fetches(12);
    abi.pushLr();

    const keyinput = mem.readU16(types.addr.reg_keyinput);
    const pressed_combo = hw.decodeActiveLowKeys(keyinput) & types.key_mask_soft_reset;
    rt.r[2] = types.key_mask_all;
    rt.r[1] = types.key_mask_soft_reset;
    rt.r[0] = pressed_combo;
    rt.cpuSub(null, pressed_combo, types.key_mask_soft_reset, true);

    if (isSoftResetComboPressed(keyinput)) {
        abi.fetches(4);
        if (!abi.call(sound.func_080386D8, 0x0803883D)) return;
    }

    abi.fetches(4);
    abi.popReturn();
}

/// Execute the 8 per-frame engine subsystems once per VBlank tick (`0x080383F8`).
fn func_080383F8() callconv(.c) void {
    if (!abi.enter(0x080383F8)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.pushReg(4);

    rt.r[4] = types.addr.frame_tick_done;
    const done = mem.readU8(types.addr.frame_tick_done);
    rt.r[0] = done;
    rt.cpuSub(null, done, 0, true);

    if (done == 0) {
        const frame_steps = [_]struct { func: *const fn () callconv(.c) void, ret: u32 }{
            .{ .func = sprite_anim.func_080159CC, .ret = 0x08038407 },
            .{ .func = hw.func_0801122C, .ret = 0x0803840B },
            .{ .func = func_0805BA34, .ret = 0x0803840F },
            .{ .func = low_peel_10.func_08018530, .ret = 0x08038413 },
            .{ .func = low_peel_6.func_080138F8, .ret = 0x08038417 },
            .{ .func = hw.func_080134E0, .ret = 0x0803841B },
            .{ .func = low_peel_6.func_08015874, .ret = 0x0803841F },
            .{ .func = sound.func_0803D7A8, .ret = 0x08038423 },
        };
        inline for (frame_steps) |step| {
            abi.fetches(4);
            if (!abi.call(step.func, step.ret)) return;
        }
        abi.fetches(4);
        abi.setRegNz(&rt.r[0], 1);
        mem.writeU8(types.addr.frame_tick_done, 1);
    }

    abi.fetches(5);
    rt.r[4] = abi.popReg();
    abi.popReturn();
}

/// Snapshot frame input state (`0x0300_1E70`) halfwords `+0x54` and `+0x50` into shadow slots (`0x0805BA34`).
fn func_0805BA34() callconv(.c) void {
    if (!abi.enter(0x0805BA34)) return;
    abi.fetches(15);
    _ = mem.readU16(types.addr.reg_keyinput);
    const val_a = mem.readU16(types.addr.frame_input_state +% 0x54);
    mem.writeU16(types.addr.frame_input_shadow_a, val_a);
    const val_b = mem.readU16(types.addr.frame_input_state +% 0x50);
    mem.writeU16(types.addr.frame_input_shadow_b, val_b);

    rt.r[2] = types.addr.frame_input_shadow_b;
    rt.cpuAdd(&rt.r[1], types.addr.frame_input_state, 0x50, true);
    rt.r[0] = val_b;
    abi.retLr();
}

/// Secondary per-frame gated engine tick dispatcher (`0x0803849C`).
fn func_0803849C() callconv(.c) void {
    if (!abi.enter(0x0803849C)) return;
    abi.fetches(7);
    abi.pushLr();

    const done = mem.readU8(types.addr.frame_tick_done);
    rt.r[0] = done;
    rt.cpuSub(null, done, 0, true);

    if (done == 0) {
        abi.fetches(9);
        const mask = mem.readU32(types.addr.frame_gate_mask);
        const flags = mem.readU16(types.addr.frame_gate_flags);
        const gated = mask & flags;
        rt.r[2] = types.addr.frame_gate_mask;
        rt.r[1] = flags;
        abi.setRegNz(&rt.r[0], gated);
        rt.cpuSub(null, gated, 0, true);

        if (gated == 0) {
            const pre_steps = [_]struct { func: *const fn () callconv(.c) void, ret: u32 }{
                .{ .func = sprite_anim.func_080159F0, .ret = 0x080384B9 },
                .{ .func = hw.func_0801122C, .ret = 0x080384BD },
                .{ .func = func_0805BA34, .ret = 0x080384C1 },
                .{ .func = low_peel_10.func_08018530, .ret = 0x080384C5 },
            };
            inline for (pre_steps) |step| {
                abi.fetches(4);
                if (!abi.call(step.func, step.ret)) return;
            }

            abi.fetches(6);
            const submode = mem.readU32(types.addr.frame_submode);
            rt.r[0] = submode;
            rt.cpuSub(null, submode, 0, true);
            if (submode != 0) {
                abi.fetches(4);
                rt.cpuSub(null, submode, 1, true);
                if (submode == 1) {
                    abi.fetches(4);
                    if (!abi.call(low_peel_11.func_08034A1C, 0x080384D5)) return;
                }
            }

            const post_steps = [_]struct { func: *const fn () callconv(.c) void, ret: u32 }{
                .{ .func = low_peel_6.func_080138F8, .ret = 0x080384D9 },
                .{ .func = decls.func_0802196C, .ret = 0x080384DD },
                .{ .func = battle.func_080224C8, .ret = 0x080384E1 },
                .{ .func = hw.func_080134E0, .ret = 0x080384E5 },
                .{ .func = low_peel_6.func_08015874, .ret = 0x080384E9 },
                .{ .func = sound.func_0803D7A8, .ret = 0x080384ED },
            };
            inline for (post_steps) |step| {
                abi.fetches(4);
                if (!abi.call(step.func, step.ret)) return;
            }

            abi.fetches(5);
            rt.r[1] = types.addr.frame_tick_done;
            abi.setRegNz(&rt.r[0], 1);
            mem.writeU8(types.addr.frame_tick_done, 1);
        }
    }

    abi.fetches(4);
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08038824, .{ .name = "func_08038824", .linkage = .strong });
        @export(&func_080383F8, .{ .name = "func_080383F8", .linkage = .strong });
        @export(&func_0803849C, .{ .name = "func_0803849C", .linkage = .strong });
        @export(&func_0805BA34, .{ .name = "func_0805BA34", .linkage = .strong });
    }
}

test "isSoftResetComboPressed detects active-low A+B+Select+Start" {
    try std.testing.expect(!isSoftResetComboPressed(0x03FF));
    try std.testing.expect(!isSoftResetComboPressed(0x03F1)); // A released
    try std.testing.expect(!isSoftResetComboPressed(0x03F7)); // Start released
    try std.testing.expect(isSoftResetComboPressed(0x03F0)); // A+B+Select+Start pressed
    try std.testing.expect(isSoftResetComboPressed(0x0000)); // all keys pressed
}
