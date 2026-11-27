//! Lifted Advance Wars entity/unit overlay, palette & badge helpers (`0x08019970..0x08021DF8`).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");

/// Entity slot byte stride at `*[0x0828_2CBC]`.
pub const entity_stride: u32 = 0x68;

/// Load unit/army palette into palette RAM slot `0x160` size `0x20` for entity `u16(r0)` (`0x08019970`).
pub fn func_08019970() callconv(.c) void {
    if (!abi.enter(0x08019970)) return;
    abi.fetches(20);
    abi.pushLr();
    const slot_idx: u16 = @truncate(rt.r[0]);
    const entity_base = abi.read32(abi.read32(0x08019998));
    const army = abi.read8(entity_base +% (@as(u32, slot_idx) *% entity_stride) +% 0x1A);
    const pal_base = abi.read32(0x0801999C);
    rt.r[0] = ((@as(u32, army) +% 4) << 5) +% pal_base;
    rt.r[1] = 0x160;
    rt.r[2] = 0x20;
    if (!abi.call(decls.func_08011330, 0x08019995)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear scroll offsets `0x0300_1D48`/`0x0300_0DBC`, mark active entity `+0x1E=1`, run `0x08021DF8` (`0x0801C150`).
pub fn func_0801C150() callconv(.c) void {
    if (!abi.enter(0x0801C150)) return;
    abi.fetches(19);
    abi.pushLr();
    abi.write16(abi.read32(0x0801C178), 0);
    abi.write16(abi.read32(0x0801C17C), 0);
    const active = abi.read16(abi.read32(0x0801C180));
    const entity_base = abi.read32(abi.read32(0x0801C184));
    abi.write8(entity_base +% (@as(u32, active) *% entity_stride) +% 0x1E, 1);
    rt.r[2] = active;
    if (!abi.call(func_08021DF8, 0x0801C173)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn spawnProcDefZero(comptime def_pool_ref: u32, comptime ret_addr: u32) bool {
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(def_pool_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, ret_addr)) return false;
    return true;
}

/// Spawn proc `0x0828_5954` with parent `0` (`0x0801C188`).
pub fn func_0801C188() callconv(.c) void {
    if (!abi.enter(0x0801C188)) return;
    if (!spawnProcDefZero(0x0801C198, 0x0801C193)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn unit overlay proc (`0x0801C544` -> `0x0801C188`).
pub fn func_0801C544() callconv(.c) void {
    if (!abi.enter(0x0801C544)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_0801C188, 0x0801C54B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn unit overlay proc (`0x0801C550` -> `0x0801C188`).
pub fn func_0801C550() callconv(.c) void {
    if (!abi.enter(0x0801C550)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_0801C188, 0x0801C557)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Trigger effect at `(obj.+0x1E, obj.+0x20)` (`0x0801C5D8` -> `0x0802928C`).
pub fn func_0801C5D8() callconv(.c) void {
    if (!abi.enter(0x0801C5D8)) return;
    abi.fetches(10);
    abi.pushLr();
    const obj = rt.r[0];
    const x: u32 = @bitCast(abi.signExtend16(abi.read16(obj +% 0x1E)));
    const y: u32 = @bitCast(abi.signExtend16(abi.read16(obj +% 0x20)));
    rt.r[3] = 0x20;
    rt.r[2] = x;
    rt.r[1] = y;
    rt.r[0] = x;
    if (!abi.call(decls.func_0802928C, 0x0801C5E9)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn unit badge from `(u8(obj.+0x1E), u8(obj.+0x20))` (`0x0801C5EC` -> `0x0801CCD4`).
pub fn func_0801C5EC() callconv(.c) void {
    if (!abi.enter(0x0801C5EC)) return;
    abi.fetches(10);
    abi.pushLr();
    const obj = rt.r[0];
    const x: u32 = abi.read8(obj +% 0x1E);
    const y: u32 = abi.read8(obj +% 0x20) & 0xFF;
    rt.r[2] = x;
    abi.setRegNz(&rt.r[1], y);
    rt.r[0] = x;
    if (!abi.call(func_0801CCD4, 0x0801C5FD)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Initialize overlay `[+0x1E=1, +0x20=1, +0x22=0]` and place active entity marker (`0x0801C600`).
pub fn func_0801C600() callconv(.c) void {
    if (!abi.enter(0x0801C600)) return;
    abi.fetches(25);
    abi.pushLr();
    const obj = rt.r[0];
    abi.write16(obj +% 0x1E, 1);
    abi.write16(obj +% 0x20, 1);
    abi.write16(obj +% 0x22, 0);

    const pos_tbl = abi.read32(0x0801C634);
    const cursor_idx = abi.read16(abi.read32(0x0801C638));
    const entity_base = abi.read32(abi.read32(0x0801C63C));
    const icon_id = abi.read8(entity_base +% (@as(u32, cursor_idx) *% entity_stride) +% 0x1D);
    const entry = pos_tbl +% (@as(u32, icon_id) *% 12);

    rt.r[3] = pos_tbl;
    rt.r[2] = icon_id;
    rt.r[0] = abi.read8(entry);
    rt.r[1] = abi.read8(entry +% 1);
    if (!abi.call(func_0801CCB8, 0x0801C62F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn proc `0x0828_59DC` (`0x0801C928`).
pub fn func_0801C928() callconv(.c) void {
    if (!abi.enter(0x0801C928)) return;
    if (!spawnProcDefZero(0x0801C938, 0x0801C933)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn proc `0x0828_5A44` and set child `+0x1E = 0x50` (`0x0801CC88`).
pub fn func_0801CC88() callconv(.c) void {
    if (!abi.enter(0x0801CC88)) return;
    if (!spawnProcDefZero(0x0801CC9C, 0x0801CC93)) return;
    abi.fetches(6);
    abi.write16(rt.r[0] +% 0x1E, 0x50);
    abi.setRegNz(&rt.r[1], 0x50);
    abi.popReturn();
}

/// Spawn proc `0x0828_5A44` and set child `+0x1E = 0x28` (`0x0801CCA0`).
pub fn func_0801CCA0() callconv(.c) void {
    if (!abi.enter(0x0801CCA0)) return;
    if (!spawnProcDefZero(0x0801CCB4, 0x0801CCAB)) return;
    abi.fetches(6);
    abi.write16(rt.r[0] +% 0x1E, 0x28);
    abi.setRegNz(&rt.r[1], 0x28);
    abi.popReturn();
}

/// Forward to `0x0803BC48(u8(r0), u8(r1), 0x14D, 5)` (`0x0801CCB8`).
pub fn func_0801CCB8() callconv(.c) void {
    if (!abi.enter(0x0801CCB8)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    rt.r[1] &= 0xFF;
    rt.r[2] = abi.read32(0x0801CCD0);
    abi.setRegNz(&rt.r[3], 5);
    if (!abi.call(decls.func_0803BC48, 0x0801CCCB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward to `0x0803BCC0(u8(r0), u8(r1), 0x14D, 5)` (`0x0801CCD4`).
pub fn func_0801CCD4() callconv(.c) void {
    if (!abi.enter(0x0801CCD4)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    rt.r[1] &= 0xFF;
    rt.r[2] = abi.read32(0x0801CCEC);
    abi.setRegNz(&rt.r[3], 5);
    if (!abi.call(decls.func_0803BCC0, 0x0801CCE7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Refresh unit/map overlay (`0x08021DF8` -> `0x08023EDC`).
pub fn func_08021DF8() callconv(.c) void {
    if (!abi.enter(0x08021DF8)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08023EDC, 0x08021DFF)) return;
    abi.fetches(4);
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08019970, .{ .name = "func_08019970", .linkage = .strong });
        @export(&func_0801C150, .{ .name = "func_0801C150", .linkage = .strong });
        @export(&func_0801C188, .{ .name = "func_0801C188", .linkage = .strong });
        @export(&func_0801C544, .{ .name = "func_0801C544", .linkage = .strong });
        @export(&func_0801C550, .{ .name = "func_0801C550", .linkage = .strong });
        @export(&func_0801C5D8, .{ .name = "func_0801C5D8", .linkage = .strong });
        @export(&func_0801C5EC, .{ .name = "func_0801C5EC", .linkage = .strong });
        @export(&func_0801C600, .{ .name = "func_0801C600", .linkage = .strong });
        @export(&func_0801C928, .{ .name = "func_0801C928", .linkage = .strong });
        @export(&func_0801CC88, .{ .name = "func_0801CC88", .linkage = .strong });
        @export(&func_0801CCA0, .{ .name = "func_0801CCA0", .linkage = .strong });
        @export(&func_0801CCB8, .{ .name = "func_0801CCB8", .linkage = .strong });
        @export(&func_0801CCD4, .{ .name = "func_0801CCD4", .linkage = .strong });
        @export(&func_08021DF8, .{ .name = "func_08021DF8", .linkage = .strong });
    }
}

test "entity table stride matches unit palette offset math" {
    try std.testing.expectEqual(@as(u32, 0x68), entity_stride);
}
