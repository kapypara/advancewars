//! Lifted Advance Wars battle/menu/entity state helpers (`0x0300_4310`, `0x0201_AB34`, etc.).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const abi = @import("abi.zig");
const types = @import("types.zig");

/// Byte offset stride for entries in the battle entity/unit info table at `*[0x0828_2CBC]`.
pub const entity_stride: u32 = 0x68;

/// Compute byte address for field `field_off` in battle entity slot `slot_idx`.
pub inline fn entityFieldAddr(table_base: u32, slot_idx: u8, field_off: u32) u32 {
    return table_base +% (@as(u32, slot_idx) *% entity_stride) +% field_off;
}

fn writeByteAtPoolPtr(comptime fetches_n: u32, comptime pool_ref: u32, comptime off: u32, comptime val: u8) void {
    abi.fetches(fetches_n);
    const base = abi.read32(pool_ref);
    if (off == 0) {
        abi.write8(base, val);
        rt.r[1] = base;
        abi.setRegNz(&rt.r[0], val);
    } else {
        const dst = base +% off;
        abi.write8(dst, val);
        rt.r[0] = dst;
        abi.setRegNz(&rt.r[1], val);
    }
    abi.retLr();
}

fn writeBattleUiField6(comptime pool_ref: u32, comptime val: u8) void {
    abi.fetches(6);
    const base = abi.read32(pool_ref);
    abi.write8(base +% 6, val);
    rt.r[1] = base;
    abi.setRegNz(&rt.r[0], val);
    abi.retLr();
}

fn writeWordOneAtPool(comptime pool_ref: u32) void {
    abi.fetches(6);
    const dst = abi.read32(pool_ref);
    abi.write32(dst, 1);
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

fn addBattleUiCounter(comptime pool_ref: u32, comptime delta: u8) void {
    abi.fetches(7);
    const base = abi.read32(pool_ref);
    const updated: u32 = abi.read8(base +% 2) +% delta;
    abi.write8(base +% 2, @truncate(updated));
    rt.r[1] = base;
    abi.setRegNz(&rt.r[0], updated);
    abi.retLr();
}

fn addBattleUiCounterFromTable(comptime pool_ref: u32, comptime table_ref: u32) void {
    abi.fetches(13);
    const base = abi.read32(pool_ref);
    const table = abi.read32(table_ref);
    const idx = abi.read8(base +% 0x3E);
    const delta = abi.read8(table +% idx);
    const cur = abi.read8(base +% 2);
    const sum: u32 = @as(u32, cur) +% delta;
    abi.write8(base +% 2, @truncate(sum));
    rt.r[0] = base;
    rt.r[2] = cur;
    abi.setRegNz(&rt.r[1], sum);
    abi.retLr();
}

/// Set `[0x0300_4280] = 0xFF` and `[0x0300_3580] = u8(r0)` (`0x08018AAC`).
pub fn func_08018AAC() callconv(.c) void {
    if (!abi.enter(0x08018AAC)) return;
    abi.fetches(8);
    const guard_addr = abi.read32(0x08018AB8);
    const sel_addr = abi.read32(0x08018ABC);
    abi.write8(guard_addr, 0xFF);
    abi.write8(sel_addr, @truncate(rt.r[0]));
    rt.r[2] = guard_addr;
    abi.setRegNz(&rt.r[1], 0xFF);
    rt.r[1] = sel_addr;
    abi.retLr();
}

/// Clear `[0x0300_4310 + 0x06] = 0` (`0x08018C60`).
pub fn func_08018C60() callconv(.c) void {
    if (!abi.enter(0x08018C60)) return;
    writeBattleUiField6(0x08018C68, 0);
}

/// Set `[0x0300_4310 + 0x06] = 1` (`0x08018C6C`).
pub fn func_08018C6C() callconv(.c) void {
    if (!abi.enter(0x08018C6C)) return;
    writeBattleUiField6(0x08018C74, 1);
}

/// Clear `[0x0300_31F8] = 0` (`0x08018C9C`).
pub fn func_08018C9C() callconv(.c) void {
    if (!abi.enter(0x08018C9C)) return;
    abi.fetches(6);
    const dst = abi.read32(0x08018CA4);
    abi.write32(dst, 0);
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Constant false/zero predicate returning `0` (`0x08019248`).
pub fn func_08019248() callconv(.c) void {
    if (!abi.enter(0x08019248)) return;
    abi.fetches(4);
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Point `[0x0300_31FC]` at `0x0300_3240` (`0x08019A0C`).
pub fn func_08019A0C() callconv(.c) void {
    if (!abi.enter(0x08019A0C)) return;
    abi.fetches(6);
    const dst = abi.read32(0x08019A14);
    const val = abi.read32(0x08019A18);
    abi.write32(dst, val);
    rt.r[1] = dst;
    rt.r[0] = val;
    abi.retLr();
}

/// Read byte `+0x25` of entity slot `u8(r0)` (`*(0x0828_2CBC)`) (`0x0801C108`).
pub fn func_0801C108() callconv(.c) void {
    if (!abi.enter(0x0801C108)) return;
    abi.fetches(12);
    const slot_idx: u8 = @truncate(rt.r[0]);
    const table_base = abi.read32(abi.read32(0x0801C11C));
    rt.r[2] = table_base;
    rt.r[1] = entity_stride;
    rt.r[0] = abi.read8(entityFieldAddr(table_base, slot_idx, 0x25));
    abi.retLr();
}

/// Clear bit 0 of `[r0 + 0x01]` byte (`0x0801C34C`).
pub fn func_0801C34C() callconv(.c) void {
    if (!abi.enter(0x0801C34C)) return;
    abi.fetches(7);
    const prev = abi.read8(rt.r[0] +% 1);
    const cleared: u32 = prev & 0xFE;
    abi.write8(rt.r[0] +% 1, @truncate(cleared));
    rt.r[2] = prev;
    abi.setRegNz(&rt.r[1], cleared);
    abi.retLr();
}

/// State helper no-op preserving registers (`0x0801C358`).
pub fn func_0801C358() callconv(.c) void {
    if (!abi.enter(0x0801C358)) return;
    abi.fetches(3);
    abi.retLr();
}

/// Increment `[0x0300_4310 + 0x02]` by `1` (`0x08022888`).
pub fn func_08022888() callconv(.c) void {
    if (!abi.enter(0x08022888)) return;
    addBattleUiCounter(0x08022894, 1);
}

/// Increment `[0x0300_4310 + 0x02]` by `5` (`0x080228DC`).
pub fn func_080228DC() callconv(.c) void {
    if (!abi.enter(0x080228DC)) return;
    addBattleUiCounter(0x080228E8, 5);
}

/// Add table `[0x0828_9DB8][state.0x3E]` to `state.0x02` (`0x080228EC`).
pub fn func_080228EC() callconv(.c) void {
    if (!abi.enter(0x080228EC)) return;
    addBattleUiCounterFromTable(0x08022904, 0x08022908);
}

/// Add table `[0x0828_9DBD][state.0x3E]` to `state.0x02` (`0x0802290C`).
pub fn func_0802290C() callconv(.c) void {
    if (!abi.enter(0x0802290C)) return;
    addBattleUiCounterFromTable(0x08022924, 0x08022928);
}

/// Initialize default 4-entry player order `[0, 1, 2, 3]` at `0x0300_4310 + 0x43..0x46` (`0x08024EC4`).
pub fn func_08024EC4() callconv(.c) void {
    if (!abi.enter(0x08024EC4)) return;
    abi.fetches(17);
    const base = abi.read32(0x08024EE4);
    var p = base +% 0x43;
    abi.write8(p, 0);
    p +%= 1;
    abi.write8(p, 1);
    p +%= 1;
    abi.write8(p, 2);
    p +%= 1;
    abi.write8(p, 3);
    rt.r[2] = base;
    rt.r[1] = p;
    abi.setRegNz(&rt.r[0], 3);
    abi.retLr();
}

/// Mark byte `+0x2D = 1` on entity slot `u8(r0)` (`*(0x0828_2CBC)`) (`0x0802C540`).
pub fn func_0802C540() callconv(.c) void {
    if (!abi.enter(0x0802C540)) return;
    abi.fetches(13);
    const slot_idx: u8 = @truncate(rt.r[0]);
    const table_base = abi.read32(abi.read32(0x0802C558));
    const dst = entityFieldAddr(table_base, slot_idx, 0x2D);
    abi.write8(dst, 1);
    rt.r[2] = table_base;
    rt.r[0] = dst;
    abi.setRegNz(&rt.r[1], 1);
    abi.retLr();
}

/// Clear `[0x0300_43C8] = 0` (`u16`) (`0x08035240`).
pub fn func_08035240() callconv(.c) void {
    if (!abi.enter(0x08035240)) return;
    abi.fetches(6);
    const dst = abi.read32(0x08035248);
    abi.write16(dst, 0);
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Set `[0x0300_3200] = 1` (`0x080369F8`).
pub fn func_080369F8() callconv(.c) void {
    if (!abi.enter(0x080369F8)) return;
    writeWordOneAtPool(0x08036A00);
}

/// Set `[0x0300_3200] = 1` (`0x08036A04`).
pub fn func_08036A04() callconv(.c) void {
    if (!abi.enter(0x08036A04)) return;
    writeWordOneAtPool(0x08036A0C);
}

/// Set `[0x0300_3200] = 1` (`0x08036A84`).
pub fn func_08036A84() callconv(.c) void {
    if (!abi.enter(0x08036A84)) return;
    writeWordOneAtPool(0x08036A8C);
}

/// Set `[0x0300_3200] = 1` (`0x08036A90`).
pub fn func_08036A90() callconv(.c) void {
    if (!abi.enter(0x08036A90)) return;
    writeWordOneAtPool(0x08036A98);
}

/// Set battle UI submode `[0x0300_4310 + 0x31] = 0x0C` (`0x0803798C`).
pub fn func_0803798C() callconv(.c) void {
    if (!abi.enter(0x0803798C)) return;
    writeByteAtPoolPtr(7, 0x08037998, 0x31, 0x0C);
}

/// Set battle UI submode `[0x0300_4310 + 0x31] = 0x0F` (`0x08037ADC`).
pub fn func_08037ADC() callconv(.c) void {
    if (!abi.enter(0x08037ADC)) return;
    writeByteAtPoolPtr(7, 0x08037AE8, 0x31, 0x0F);
}

/// Set battle UI submode `[0x0300_4310 + 0x31] = 0x10` (`0x08037BB8`).
pub fn func_08037BB8() callconv(.c) void {
    if (!abi.enter(0x08037BB8)) return;
    writeByteAtPoolPtr(7, 0x08037BC4, 0x31, 0x10);
}

/// Set battle UI submode `[0x0300_4310 + 0x31] = 0x0C` (`0x08037BE8`).
pub fn func_08037BE8() callconv(.c) void {
    if (!abi.enter(0x08037BE8)) return;
    writeByteAtPoolPtr(7, 0x08037BF4, 0x31, 0x0C);
}

/// Set battle UI submode `[0x0300_4310 + 0x31] = 0x0F` (`0x08037C98`).
pub fn func_08037C98() callconv(.c) void {
    if (!abi.enter(0x08037C98)) return;
    writeByteAtPoolPtr(7, 0x08037CA4, 0x31, 0x0F);
}

/// Set battle UI byte `[0x0300_4310 + 0x2D] = 0x02` (`0x08038000`).
pub fn func_08038000() callconv(.c) void {
    if (!abi.enter(0x08038000)) return;
    writeByteAtPoolPtr(7, 0x0803800C, 0x2D, 0x02);
}

/// Snapshot `[0x0300_36AC]` (`u16`) into `[r0 + 0x1E]` and set `[r0 + 0x20] = 1` (`0x0803FD78`).
pub fn func_0803FD78() callconv(.c) void {
    if (!abi.enter(0x0803FD78)) return;
    abi.fetches(8);
    const val = abi.read16(abi.read32(0x0803FD84));
    abi.write16(rt.r[0] +% 0x1E, val);
    abi.write16(rt.r[0] +% 0x20, 1);
    abi.setRegNz(&rt.r[1], 1);
    abi.retLr();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08018AAC, .{ .name = "func_08018AAC", .linkage = .strong });
        @export(&func_08018C60, .{ .name = "func_08018C60", .linkage = .strong });
        @export(&func_08018C6C, .{ .name = "func_08018C6C", .linkage = .strong });
        @export(&func_08018C9C, .{ .name = "func_08018C9C", .linkage = .strong });
        @export(&func_08019248, .{ .name = "func_08019248", .linkage = .strong });
        @export(&func_08019A0C, .{ .name = "func_08019A0C", .linkage = .strong });
        @export(&func_0801C108, .{ .name = "func_0801C108", .linkage = .strong });
        @export(&func_0801C34C, .{ .name = "func_0801C34C", .linkage = .strong });
        @export(&func_0801C358, .{ .name = "func_0801C358", .linkage = .strong });
        @export(&func_08022888, .{ .name = "func_08022888", .linkage = .strong });
        @export(&func_080228DC, .{ .name = "func_080228DC", .linkage = .strong });
        @export(&func_080228EC, .{ .name = "func_080228EC", .linkage = .strong });
        @export(&func_0802290C, .{ .name = "func_0802290C", .linkage = .strong });
        @export(&func_08024EC4, .{ .name = "func_08024EC4", .linkage = .strong });
        @export(&func_0802C540, .{ .name = "func_0802C540", .linkage = .strong });
        @export(&func_08035240, .{ .name = "func_08035240", .linkage = .strong });
        @export(&func_080369F8, .{ .name = "func_080369F8", .linkage = .strong });
        @export(&func_08036A04, .{ .name = "func_08036A04", .linkage = .strong });
        @export(&func_08036A84, .{ .name = "func_08036A84", .linkage = .strong });
        @export(&func_08036A90, .{ .name = "func_08036A90", .linkage = .strong });
        @export(&func_0803798C, .{ .name = "func_0803798C", .linkage = .strong });
        @export(&func_08037ADC, .{ .name = "func_08037ADC", .linkage = .strong });
        @export(&func_08037BB8, .{ .name = "func_08037BB8", .linkage = .strong });
        @export(&func_08037BE8, .{ .name = "func_08037BE8", .linkage = .strong });
        @export(&func_08037C98, .{ .name = "func_08037C98", .linkage = .strong });
        @export(&func_08038000, .{ .name = "func_08038000", .linkage = .strong });
        @export(&func_0803FD78, .{ .name = "func_0803FD78", .linkage = .strong });
    }
}

test "entity table stride matches GBA layout" {
    try std.testing.expectEqual(@as(u32, 0x0201_AB59), entityFieldAddr(0x0201_AB34, 0, 0x25));
    try std.testing.expectEqual(@as(u32, 0x0201_ABC1), entityFieldAddr(0x0201_AB34, 1, 0x25));
    try std.testing.expectEqual(@as(u32, 0x0300_4310), types.addr.battle_ui_state);
}
