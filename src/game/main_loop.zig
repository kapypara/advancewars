//! Lifted Advance Wars main frame loop and soft-reset check (`0x080383F8`, `0x08038824`).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const mem = @import("mem.zig");
const types = @import("types.zig");

/// Return true if active-low `KEYINPUT` has A + B + Select + Start pressed simultaneously.
pub fn isSoftResetComboPressed(keyinput: u16) bool {
    const pressed = types.key_mask_all & ~@as(u32, keyinput);
    return (pressed & types.key_mask_soft_reset) == types.key_mask_soft_reset;
}

/// Check `KEYINPUT` for A+B+Select+Start soft-reset combo and trigger soft reset (`0x08038824`).
fn func_08038824() callconv(.c) void {
    if (!abi.enter(0x08038824)) return;
    abi.fetches(12);
    abi.pushLr();

    const keyinput = mem.readU16(types.addr.reg_keyinput);
    const pressed_combo = (types.key_mask_all & ~@as(u32, keyinput)) & types.key_mask_soft_reset;
    rt.r[2] = types.key_mask_all;
    rt.r[1] = types.key_mask_soft_reset;
    rt.r[0] = pressed_combo;
    rt.cpuSub(null, pressed_combo, types.key_mask_soft_reset, true);

    if (isSoftResetComboPressed(keyinput)) {
        abi.fetches(4);
        if (!abi.call(decls.func_080386D8, 0x0803883D)) return;
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
            .{ .func = decls.func_080159CC, .ret = 0x08038407 },
            .{ .func = decls.func_0801122C, .ret = 0x0803840B },
            .{ .func = decls.func_0805BA34, .ret = 0x0803840F },
            .{ .func = decls.func_08018530, .ret = 0x08038413 },
            .{ .func = decls.func_080138F8, .ret = 0x08038417 },
            .{ .func = decls.func_080134E0, .ret = 0x0803841B },
            .{ .func = decls.func_08015874, .ret = 0x0803841F },
            .{ .func = decls.func_0803D7A8, .ret = 0x08038423 },
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

comptime {
    if (!builtin.is_test) {
        @export(&func_08038824, .{ .name = "func_08038824", .linkage = .strong });
        @export(&func_080383F8, .{ .name = "func_080383F8", .linkage = .strong });
    }
}

test "isSoftResetComboPressed detects active-low A+B+Select+Start" {
    try std.testing.expect(!isSoftResetComboPressed(0x03FF));
    try std.testing.expect(!isSoftResetComboPressed(0x03F1)); // A released
    try std.testing.expect(!isSoftResetComboPressed(0x03F7)); // Start released
    try std.testing.expect(isSoftResetComboPressed(0x03F0)); // A+B+Select+Start pressed
    try std.testing.expect(isSoftResetComboPressed(0x0000)); // all keys pressed
}
