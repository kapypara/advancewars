//! Lifted Advance Wars battle/menu/entity state helpers (`0x0300_4310`, `0x0201_AB34`, etc.).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
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

/// Sync `[0x0300_4310 + 0x3E]` byte from `[0x0201_FD1D]` (`0x0801BDF0`).
pub fn func_0801BDF0() callconv(.c) void {
    if (!abi.enter(0x0801BDF0)) return;
    abi.fetches(8);
    const base = abi.read32(0x0801BDFC);
    const val = abi.read8(abi.read32(0x0801BE00));
    const dst = base +% 0x3E;
    abi.write8(dst, val);
    rt.r[0] = dst;
    rt.r[1] = val;
    abi.retLr();
}

/// Read byte `+0x1E` of entity slot `u8(r0)` (`*(0x0828_2CBC)`) (`0x0801BFD0`).
pub fn func_0801BFD0() callconv(.c) void {
    if (!abi.enter(0x0801BFD0)) return;
    abi.fetches(11);
    const slot_idx: u8 = @truncate(rt.r[0]);
    const table_base = abi.read32(abi.read32(0x0801BFE4));
    rt.r[2] = table_base;
    rt.r[1] = entity_stride;
    rt.r[0] = abi.read8(entityFieldAddr(table_base, slot_idx, 0x1E));
    abi.retLr();
}

fn returnConstOne() void {
    abi.fetches(4);
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

/// Constant predicate returning `1` (`0x0801C1C4`).
pub fn func_0801C1C4() callconv(.c) void {
    if (!abi.enter(0x0801C1C4)) return;
    returnConstOne();
}

/// Constant predicate returning `1` (`0x0801C1C8`).
pub fn func_0801C1C8() callconv(.c) void {
    if (!abi.enter(0x0801C1C8)) return;
    returnConstOne();
}

/// Set `[0x0300_0D8C] = 0x0801_CD01` callback pointer (`0x0801CCF0`).
pub fn func_0801CCF0() callconv(.c) void {
    if (!abi.enter(0x0801CCF0)) return;
    abi.fetches(6);
    const dst = abi.read32(0x0801CCF8);
    const cb = abi.read32(0x0801CCFC);
    abi.write32(dst, cb);
    rt.r[1] = dst;
    rt.r[0] = cb;
    abi.retLr();
}

/// Clear `[0x0300_4310 + 0x32] = 0` (`0x08034C64`).
pub fn func_08034C64() callconv(.c) void {
    if (!abi.enter(0x08034C64)) return;
    writeByteAtPoolPtr(7, 0x08034C70, 0x32, 0);
}

/// Set turn phase `[0x0300_357C] = 0x0F` (`u16`) (`0x080351BC`).
pub fn func_080351BC() callconv(.c) void {
    if (!abi.enter(0x080351BC)) return;
    abi.fetches(6);
    const dst = abi.read32(0x080351C4);
    abi.write16(dst, 0xF);
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], 0xF);
    abi.retLr();
}

fn incU16AtPool(comptime pool_ref: u32) void {
    abi.fetches(7);
    const dst = abi.read32(pool_ref);
    const next: u32 = @as(u32, abi.read16(dst)) +% 1;
    abi.write16(dst, @truncate(next));
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], next);
    abi.retLr();
}

/// Increment `[0x0300_43C8]` (`u16`) (`0x08035220`).
pub fn func_08035220() callconv(.c) void {
    if (!abi.enter(0x08035220)) return;
    incU16AtPool(0x0803522C);
}

/// Increment `[0x0300_4474]` (`u16`) (`0x0803524C`).
pub fn func_0803524C() callconv(.c) void {
    if (!abi.enter(0x0803524C)) return;
    incU16AtPool(0x08035258);
}

/// Set `[0x0300_4310 + 0x2D] = 1` (`0x08035804`).
pub fn func_08035804() callconv(.c) void {
    if (!abi.enter(0x08035804)) return;
    writeByteAtPoolPtr(7, 0x08035810, 0x2D, 1);
}

/// No-op state callback (`0x0803626C`).
pub fn func_0803626C() callconv(.c) void {
    if (!abi.enter(0x0803626C)) return;
    abi.fetches(3);
    abi.retLr();
}

/// No-op state callback (`0x08036270`).
pub fn func_08036270() callconv(.c) void {
    if (!abi.enter(0x08036270)) return;
    abi.fetches(3);
    abi.retLr();
}

/// Set `[0x0300_3200] = 1` (`0x08036AE4`).
pub fn func_08036AE4() callconv(.c) void {
    if (!abi.enter(0x08036AE4)) return;
    writeWordOneAtPool(0x08036AEC);
}

/// Set `[0x0300_3200] = 1` (`0x08036B38`).
pub fn func_08036B38() callconv(.c) void {
    if (!abi.enter(0x08036B38)) return;
    writeWordOneAtPool(0x08036B40);
}

/// Set `[0x0300_3200] = 1` (`0x08036E44`).
pub fn func_08036E44() callconv(.c) void {
    if (!abi.enter(0x08036E44)) return;
    writeWordOneAtPool(0x08036E4C);
}

/// Set `[0x0300_3200] = 1` (`0x08037048`).
pub fn func_08037048() callconv(.c) void {
    if (!abi.enter(0x08037048)) return;
    writeWordOneAtPool(0x08037050);
}

/// Set `[0x0300_3200] = 1` (`0x080370A4`).
pub fn func_080370A4() callconv(.c) void {
    if (!abi.enter(0x080370A4)) return;
    writeWordOneAtPool(0x080370AC);
}

/// Set `[0x0300_3200] = 1` (`0x08037124`).
pub fn func_08037124() callconv(.c) void {
    if (!abi.enter(0x08037124)) return;
    writeWordOneAtPool(0x0803712C);
}

/// Set `[0x0300_3200] = 1` (`0x08037218`).
pub fn func_08037218() callconv(.c) void {
    if (!abi.enter(0x08037218)) return;
    writeWordOneAtPool(0x08037220);
}

/// Set `[0x0300_3200] = 1` (`0x08037248`).
pub fn func_08037248() callconv(.c) void {
    if (!abi.enter(0x08037248)) return;
    writeWordOneAtPool(0x08037250);
}

/// Set `[0x0300_3200] = 1` (`0x08037398`).
pub fn func_08037398() callconv(.c) void {
    if (!abi.enter(0x08037398)) return;
    writeWordOneAtPool(0x080373A0);
}

/// Set `[0x0300_3200] = 1` (`0x080373C8`).
pub fn func_080373C8() callconv(.c) void {
    if (!abi.enter(0x080373C8)) return;
    writeWordOneAtPool(0x080373D0);
}

/// Set `[0x0300_3200] = 1` (`0x0803741C`).
pub fn func_0803741C() callconv(.c) void {
    if (!abi.enter(0x0803741C)) return;
    writeWordOneAtPool(0x08037424);
}

/// Set `[0x0300_3200] = 1` (`0x08037548`).
pub fn func_08037548() callconv(.c) void {
    if (!abi.enter(0x08037548)) return;
    writeWordOneAtPool(0x08037550);
}

/// Set `[0x0300_3200] = 1` (`0x08037578`).
pub fn func_08037578() callconv(.c) void {
    if (!abi.enter(0x08037578)) return;
    writeWordOneAtPool(0x08037580);
}

/// Zero 10 command words (`0x28` bytes) at `0x0300_3200` (`0x08037F98`).
pub fn func_08037F98() callconv(.c) void {
    if (!abi.enter(0x08037F98)) return;
    abi.fetches(15);
    const base = abi.read32(0x08037FB4);
    var i: u32 = 0;
    while (i < 10) : (i += 1) {
        abi.write32(base +% (i << 2), 0);
    }
    rt.r[1] = base;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Set `[0x0300_4310 + 0x0D] = 1` (`0x08037FB8`).
pub fn func_08037FB8() callconv(.c) void {
    if (!abi.enter(0x08037FB8)) return;
    abi.fetches(6);
    const base = abi.read32(0x08037FC0);
    abi.write8(base +% 0xD, 1);
    rt.r[1] = base;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

fn writeBattleUiField7(comptime pool_ref: u32, comptime val: u8) void {
    abi.fetches(6);
    const base = abi.read32(pool_ref);
    abi.write8(base +% 7, val);
    rt.r[1] = base;
    abi.setRegNz(&rt.r[0], val);
    abi.retLr();
}

/// Set `[0x0300_4310 + 0x07] = 1` (`0x08038010`).
pub fn func_08038010() callconv(.c) void {
    if (!abi.enter(0x08038010)) return;
    writeBattleUiField7(0x08038018, 1);
}

/// Clear `[0x0300_4310 + 0x07] = 0` (`0x0803801C`).
pub fn func_0803801C() callconv(.c) void {
    if (!abi.enter(0x0803801C)) return;
    writeBattleUiField7(0x08038024, 0);
}

/// Set active scene callback `[0x0300_4478] = r0` (`0x08038260`).
pub fn func_08038260() callconv(.c) void {
    if (!abi.enter(0x08038260)) return;
    abi.fetches(5);
    const dst = abi.read32(0x08038268);
    abi.write32(dst, rt.r[0]);
    rt.r[1] = dst;
    abi.retLr();
}

/// Clear UI scroll halfword `[0x0300_47E4] = 0` (`0x080385BC`).
pub fn func_080385BC() callconv(.c) void {
    if (!abi.enter(0x080385BC)) return;
    abi.fetches(6);
    const dst = abi.read32(0x080385C4);
    abi.write16(dst, 0);
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// No-op state callback (`0x0803A2E0`).
pub fn func_0803A2E0() callconv(.c) void {
    if (!abi.enter(0x0803A2E0)) return;
    abi.fetches(3);
    abi.retLr();
}

/// Clear `[0x0300_1D44] = 0` and call `0x08035230` (`0x08018CB4`).
pub fn func_08018CB4() callconv(.c) void {
    if (!abi.enter(0x08018CB4)) return;
    abi.fetches(8);
    abi.pushLr();
    abi.write32(abi.read32(0x08018CC4), 0);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_08035230, 0x08018CC1)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Read signed byte at flag/slot `i8(r0)` resolved via `0x08015DD4` (`0x08015E10`).
pub fn func_08015E10() callconv(.c) void {
    if (!abi.enter(0x08015E10)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = @bitCast(abi.signExtend8(@truncate(rt.r[0])));
    if (!abi.call(decls.func_08015DD4, 0x08015E1B)) return;
    abi.fetches(7);
    abi.setRegNz(&rt.r[0], @bitCast(abi.signExtend8(abi.read8(rt.r[0]))));
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Write byte `u8(r1)` to flag/slot `i8(r0)` resolved via `0x08015DD4` (`0x08015E24`).
pub fn func_08015E24() callconv(.c) void {
    if (!abi.enter(0x08015E24)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[1] & 0xFF;
    rt.r[0] = @bitCast(abi.signExtend8(@truncate(rt.r[0])));
    if (!abi.call(decls.func_08015DD4, 0x08015E35)) return;

    abi.fetches(6);
    abi.write8(rt.r[0], @truncate(rt.r[4]));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn `0x08016930` proc storing `u16(r0)` at `+0x1E` (`0x08016918`).
pub fn func_08016918() callconv(.c) void {
    if (!abi.enter(0x08016918)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0] & 0xFFFF;
    rt.r[0] = abi.read32(0x08016930);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08016929)) return;

    abi.fetches(6);
    abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[4]));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Trigger transition via `0x08010C70` with `(0x08016F64, 0, 0, 0x1E, stack: 6, 0x174)` (`0x08016F44`).
pub fn func_08016F44() callconv(.c) void {
    if (!abi.enter(0x08016F44)) return;
    abi.fetches(15);
    abi.pushLr();
    rt.r[13] -%= 8;
    rt.r[0] = abi.read32(0x08016F64);
    abi.write32(rt.r[13], 6);
    abi.write32(rt.r[13] +% 4, 0xBA << 1);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0x1E);
    if (!abi.call(decls.func_08010C70, 0x08016F5F)) return;
    abi.fetches(5);
    rt.r[13] +%= 8;
    abi.popReturn();
}

fn setBattleSubmodeAfter19608(comptime mode: u8, comptime ptr_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019608, ret_addr)) return;
    abi.fetches(8);
    abi.write8(abi.read32(abi.read32(ptr_ref)), mode);
    abi.popReturn();
}

/// Switch active script table to `0x0803E23C` and dispatch `0x0803E170` with `0x0803E240` (`0x0803E224`).
pub fn func_0803E224() callconv(.c) void {
    if (!abi.enter(0x0803E224)) return;
    abi.fetches(9);
    abi.pushLr();
    const val = abi.read32(0x0803E23C);
    abi.write32(abi.read32(0x0803E238), val);
    rt.r[0] = val;
    rt.r[1] = abi.read32(0x0803E240);
    if (!abi.call(decls.func_0803E170, 0x0803E233)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Reset battle/UI state block `0x0803E438` preserving field `+0x0C` across `0x08034C74` (`0x0803E400`).
pub fn func_0803E400() callconv(.c) void {
    if (!abi.enter(0x0803E400)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[5] = abi.read32(0x0803E438);
    rt.r[4] = abi.read8(rt.r[5] +% 0xC);
    if (!abi.call(decls.func_08034C74, 0x0803E40B)) return;

    abi.fetches(25);
    abi.write8(rt.r[5] +% 0xC, @truncate(rt.r[4]));
    inline for ([_]u32{ 0x39, 0x3A, 0x3B, 0x3C, 0x2C }) |off| {
        abi.write8(rt.r[5] +% off, 0);
    }
    inline for ([_]u32{ 0xD, 0x7, 0x8, 0x2D, 0x0 }) |off| {
        abi.write8(rt.r[5] +% off, 1);
    }
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Refresh HUD via `0x08019608` and enter phase `2` (`0x0803E43C`).
pub fn func_0803E43C() callconv(.c) void {
    if (!abi.enter(0x0803E43C)) return;
    setBattleSubmodeAfter19608(2, 0x0803E450, 0x0803E443);
}

/// Refresh HUD via `0x08019608` and enter phase `3` (`0x0803E454`).
pub fn func_0803E454() callconv(.c) void {
    if (!abi.enter(0x0803E454)) return;
    setBattleSubmodeAfter19608(3, 0x0803E468, 0x0803E45B);
}

/// Refresh HUD via `0x08019608` and enter phase `4` (`0x0803E46C`).
pub fn func_0803E46C() callconv(.c) void {
    if (!abi.enter(0x0803E46C)) return;
    setBattleSubmodeAfter19608(4, 0x0803E480, 0x0803E473);
}

/// Run turn/AI step helper `0x080247DC` (`0x0803E5DC`).
pub fn func_0803E5DC() callconv(.c) void {
    if (!abi.enter(0x0803E5DC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080247DC, 0x0803E5E3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Resolve message block `0x0803FCDC` via `0x08018400` and copy `u8(arg->+0x1E)` into `+0x10` (`0x0803FCC8`).
pub fn func_0803FCC8() callconv(.c) void {
    if (!abi.enter(0x0803FCC8)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[0] = abi.read32(0x0803FCDC);
    if (!abi.call(decls.func_08018400, 0x0803FCD3)) return;

    abi.fetches(7);
    abi.write8(rt.r[0] +% 0x10, @truncate(abi.read16(rt.r[4] +% 0x1E)));
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear/flush campaign state helper `0x0800FC58` (`0x0803FCE0`).
pub fn func_0803FCE0() callconv(.c) void {
    if (!abi.enter(0x0803FCE0)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0800FC58, 0x0803FCE7)) return;
    abi.fetches(4);
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08015E10, .{ .name = "func_08015E10", .linkage = .strong });
        @export(&func_08015E24, .{ .name = "func_08015E24", .linkage = .strong });
        @export(&func_08016918, .{ .name = "func_08016918", .linkage = .strong });
        @export(&func_08016F44, .{ .name = "func_08016F44", .linkage = .strong });
        @export(&func_08018AAC, .{ .name = "func_08018AAC", .linkage = .strong });
        @export(&func_0803E224, .{ .name = "func_0803E224", .linkage = .strong });
        @export(&func_0803E400, .{ .name = "func_0803E400", .linkage = .strong });
        @export(&func_0803E43C, .{ .name = "func_0803E43C", .linkage = .strong });
        @export(&func_0803E454, .{ .name = "func_0803E454", .linkage = .strong });
        @export(&func_0803E46C, .{ .name = "func_0803E46C", .linkage = .strong });
        @export(&func_0803E5DC, .{ .name = "func_0803E5DC", .linkage = .strong });
        @export(&func_0803FCC8, .{ .name = "func_0803FCC8", .linkage = .strong });
        @export(&func_0803FCE0, .{ .name = "func_0803FCE0", .linkage = .strong });
        @export(&func_08018C60, .{ .name = "func_08018C60", .linkage = .strong });
        @export(&func_08018C6C, .{ .name = "func_08018C6C", .linkage = .strong });
        @export(&func_08018C9C, .{ .name = "func_08018C9C", .linkage = .strong });
        @export(&func_08018CB4, .{ .name = "func_08018CB4", .linkage = .strong });
        @export(&func_08019248, .{ .name = "func_08019248", .linkage = .strong });
        @export(&func_08019A0C, .{ .name = "func_08019A0C", .linkage = .strong });
        @export(&func_0801BDF0, .{ .name = "func_0801BDF0", .linkage = .strong });
        @export(&func_0801BFD0, .{ .name = "func_0801BFD0", .linkage = .strong });
        @export(&func_0801C108, .{ .name = "func_0801C108", .linkage = .strong });
        @export(&func_0801C1C4, .{ .name = "func_0801C1C4", .linkage = .strong });
        @export(&func_0801C1C8, .{ .name = "func_0801C1C8", .linkage = .strong });
        @export(&func_0801C34C, .{ .name = "func_0801C34C", .linkage = .strong });
        @export(&func_0801C358, .{ .name = "func_0801C358", .linkage = .strong });
        @export(&func_0801CCF0, .{ .name = "func_0801CCF0", .linkage = .strong });
        @export(&func_08022888, .{ .name = "func_08022888", .linkage = .strong });
        @export(&func_080228DC, .{ .name = "func_080228DC", .linkage = .strong });
        @export(&func_080228EC, .{ .name = "func_080228EC", .linkage = .strong });
        @export(&func_0802290C, .{ .name = "func_0802290C", .linkage = .strong });
        @export(&func_08024EC4, .{ .name = "func_08024EC4", .linkage = .strong });
        @export(&func_0802C540, .{ .name = "func_0802C540", .linkage = .strong });
        @export(&func_08034C64, .{ .name = "func_08034C64", .linkage = .strong });
        @export(&func_080351BC, .{ .name = "func_080351BC", .linkage = .strong });
        @export(&func_08035220, .{ .name = "func_08035220", .linkage = .strong });
        @export(&func_08035240, .{ .name = "func_08035240", .linkage = .strong });
        @export(&func_0803524C, .{ .name = "func_0803524C", .linkage = .strong });
        @export(&func_08035804, .{ .name = "func_08035804", .linkage = .strong });
        @export(&func_0803626C, .{ .name = "func_0803626C", .linkage = .strong });
        @export(&func_08036270, .{ .name = "func_08036270", .linkage = .strong });
        @export(&func_080369F8, .{ .name = "func_080369F8", .linkage = .strong });
        @export(&func_08036A04, .{ .name = "func_08036A04", .linkage = .strong });
        @export(&func_08036A84, .{ .name = "func_08036A84", .linkage = .strong });
        @export(&func_08036A90, .{ .name = "func_08036A90", .linkage = .strong });
        @export(&func_08036AE4, .{ .name = "func_08036AE4", .linkage = .strong });
        @export(&func_08036B38, .{ .name = "func_08036B38", .linkage = .strong });
        @export(&func_08036E44, .{ .name = "func_08036E44", .linkage = .strong });
        @export(&func_08037048, .{ .name = "func_08037048", .linkage = .strong });
        @export(&func_080370A4, .{ .name = "func_080370A4", .linkage = .strong });
        @export(&func_08037124, .{ .name = "func_08037124", .linkage = .strong });
        @export(&func_08037218, .{ .name = "func_08037218", .linkage = .strong });
        @export(&func_08037248, .{ .name = "func_08037248", .linkage = .strong });
        @export(&func_08037398, .{ .name = "func_08037398", .linkage = .strong });
        @export(&func_080373C8, .{ .name = "func_080373C8", .linkage = .strong });
        @export(&func_0803741C, .{ .name = "func_0803741C", .linkage = .strong });
        @export(&func_08037548, .{ .name = "func_08037548", .linkage = .strong });
        @export(&func_08037578, .{ .name = "func_08037578", .linkage = .strong });
        @export(&func_0803798C, .{ .name = "func_0803798C", .linkage = .strong });
        @export(&func_08037ADC, .{ .name = "func_08037ADC", .linkage = .strong });
        @export(&func_08037BB8, .{ .name = "func_08037BB8", .linkage = .strong });
        @export(&func_08037BE8, .{ .name = "func_08037BE8", .linkage = .strong });
        @export(&func_08037C98, .{ .name = "func_08037C98", .linkage = .strong });
        @export(&func_08037F98, .{ .name = "func_08037F98", .linkage = .strong });
        @export(&func_08037FB8, .{ .name = "func_08037FB8", .linkage = .strong });
        @export(&func_08038000, .{ .name = "func_08038000", .linkage = .strong });
        @export(&func_08038010, .{ .name = "func_08038010", .linkage = .strong });
        @export(&func_0803801C, .{ .name = "func_0803801C", .linkage = .strong });
        @export(&func_08038260, .{ .name = "func_08038260", .linkage = .strong });
        @export(&func_080385BC, .{ .name = "func_080385BC", .linkage = .strong });
        @export(&func_0803A2E0, .{ .name = "func_0803A2E0", .linkage = .strong });
        @export(&func_0803FD78, .{ .name = "func_0803FD78", .linkage = .strong });
    }
}

test "entity table stride matches GBA layout" {
    try std.testing.expectEqual(@as(u32, 0x0201_AB59), entityFieldAddr(0x0201_AB34, 0, 0x25));
    try std.testing.expectEqual(@as(u32, 0x0201_ABC1), entityFieldAddr(0x0201_AB34, 1, 0x25));
    try std.testing.expectEqual(@as(u32, 0x0300_4310), types.addr.battle_ui_state);
}
