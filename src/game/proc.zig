//! Lifted Advance Wars proc (`0x0300_0E10`) and cutscene script (`0x0300_1D50`)
//! opcode handlers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const types = @import("types.zig");

/// Compute EWRAM/IWRAM address of proc slot `idx` (`u8`, stride `0x60`).
pub inline fn procSlotAddr(slot_idx: u8) u32 {
    return types.addr.proc_table +% @as(u32, slot_idx) *% @as(u32, types.proc_slot_stride);
}

/// Compute address of `+0x04` cursor word in secondary script slot `idx` (`i16`, stride `0x18`).
pub inline fn scriptCursorFieldAddr(slot_idx: i16) u32 {
    const signed: i32 = slot_idx;
    const off: u32 = @bitCast(signed *% @as(i32, types.script_slot_stride));
    return off +% (types.addr.script_pool + 4);
}

/// Proc command: copy `*cursor` into `proc + 0x08`, advance cursor by 8, return `0` (`0x08013D14`).
pub fn func_08013D14() callconv(.c) void {
    if (!abi.enter(0x08013D14)) return;
    abi.fetches(20);
    const idx: u8 = @truncate(rt.r[0]);
    const base = abi.read32(0x08013D38);
    const slot_off = @as(u32, idx) *% @as(u32, types.proc_slot_stride);
    const dst = slot_off +% (base +% 8);
    const cur_ptr_addr = slot_off +% (base +% 4);
    const cur = abi.read32(cur_ptr_addr);
    const val = abi.read32(cur);
    abi.write32(dst, val);
    abi.write32(cur_ptr_addr, cur +% 8);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = val;
    rt.r[3] = dst;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Proc command: set sleep timer `[proc + 0x10] = read16(cursor + 4)`, advance cursor by 8, return `0` (`0x08013D3C`).
pub fn func_08013D3C() callconv(.c) void {
    if (!abi.enter(0x08013D3C)) return;
    abi.fetches(19);
    const idx: u8 = @truncate(rt.r[0]);
    const base = abi.read32(0x08013D60);
    const slot_off = @as(u32, idx) *% @as(u32, types.proc_slot_stride);
    const proc = slot_off +% base;
    const cur_ptr_addr = slot_off +% (base +% 4);
    const cur = abi.read32(cur_ptr_addr);
    abi.write16(proc +% 0x10, abi.read16(cur +% 4));
    abi.write32(cur_ptr_addr, cur +% 8);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = base +% 4;
    rt.r[3] = proc;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Proc command: jump `cursor = *cursor`, zero `sleep_timer` & `state38`, return `1` (`0x08013DA0`).
pub fn func_08013DA0() callconv(.c) void {
    if (!abi.enter(0x08013DA0)) return;
    abi.fetches(19);
    const idx: u8 = @truncate(rt.r[0]);
    const base = abi.read32(0x08013DC4);
    const slot_off = @as(u32, idx) *% @as(u32, types.proc_slot_stride);
    const cur_ptr_addr = slot_off +% (base +% 4);
    const jump_target = abi.read32(abi.read32(cur_ptr_addr));
    abi.write32(cur_ptr_addr, jump_target);
    const proc = slot_off +% base;
    abi.write16(proc +% 0x10, 0);
    abi.write16(proc +% 0x38, 0);
    rt.r[1] = proc;
    rt.r[2] = jump_target;
    rt.r[3] = base;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

/// Proc command no-op returning `0` (`0x08013DF0`).
pub fn func_08013DF0() callconv(.c) void {
    if (!abi.enter(0x08013DF0)) return;
    abi.fetches(4);
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Proc command: set callback `[proc + 0x0C] = *cursor`, advance cursor by 8, return `1` (`0x08013DF4`).
pub fn func_08013DF4() callconv(.c) void {
    if (!abi.enter(0x08013DF4)) return;
    abi.fetches(20);
    const idx: u8 = @truncate(rt.r[0]);
    const base = abi.read32(0x08013E18);
    const slot_off = @as(u32, idx) *% @as(u32, types.proc_slot_stride);
    const dst = slot_off +% (base +% 0xC);
    const cur_ptr_addr = slot_off +% (base +% 4);
    const cur = abi.read32(cur_ptr_addr);
    const val = abi.read32(cur);
    abi.write32(dst, val);
    abi.write32(cur_ptr_addr, cur +% 8);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = val;
    rt.r[3] = dst;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

/// Proc command: set flag halfword `[0x08014098] = 1`, advance cursor by 8, return `1` (`0x08014078`).
pub fn func_08014078() callconv(.c) void {
    if (!abi.enter(0x08014078)) return;
    abi.fetches(18);
    const idx: u8 = @truncate(rt.r[0]);
    abi.write16(abi.read32(0x08014098), 1);
    const base = abi.read32(0x0801409C);
    const slot_off = @as(u32, idx) *% @as(u32, types.proc_slot_stride);
    const cur_ptr_addr = slot_off +% (base +% 4);
    const cur = abi.read32(cur_ptr_addr);
    abi.write32(cur_ptr_addr, cur +% 8);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = base +% 4;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

/// Secondary script command no-op returning `0` (`0x08017104`).
pub fn func_08017104() callconv(.c) void {
    if (!abi.enter(0x08017104)) return;
    abi.fetches(4);
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Secondary script command: write 8-bit immediate (`[cmd+0xC] -> [cmd+4]`), step `cmd += 0x10` (`0x08017108`).
pub fn func_08017108() callconv(.c) void {
    if (!abi.enter(0x08017108)) return;
    abi.fetches(19);
    const idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const base = abi.read32(0x0801712C);
    const off: u32 = @bitCast(@as(i32, idx) *% @as(i32, types.script_slot_stride));
    const cur_ptr_addr = off +% (base +% 4);
    const cmd = abi.read32(cur_ptr_addr);
    const dst = abi.read32(cmd +% 4);
    const val = abi.read32(cmd +% 0xC);
    abi.write8(dst, @truncate(val));
    abi.write32(cur_ptr_addr, cmd +% 0x10);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = dst;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

fn scriptWrite16Or32(comptime width: u8, comptime pool_ptr_addr: u32) void {
    abi.fetches(18);
    const idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const base = abi.read32(pool_ptr_addr);
    const off: u32 = @bitCast(@as(i32, idx) *% @as(i32, types.script_slot_stride));
    const cur_ptr_addr = off +% (base +% 4);
    const cmd = abi.read32(cur_ptr_addr);
    const dst = abi.read32(cmd +% 4);
    const val = abi.read32(cmd +% 0xC);
    if (width == 16) {
        abi.write16(dst, @truncate(val));
    } else {
        abi.write32(dst, val);
    }
    abi.write32(cur_ptr_addr, cmd +% 0x10);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = val;
    rt.r[3] = dst;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

/// Secondary script command: write 16-bit immediate (`[cmd+0xC] -> [cmd+4]`), step `cmd += 0x10` (`0x08017130`).
pub fn func_08017130() callconv(.c) void {
    if (!abi.enter(0x08017130)) return;
    scriptWrite16Or32(16, 0x08017150);
}

/// Secondary script command: write 32-bit immediate (`[cmd+0xC] -> [cmd+4]`), step `cmd += 0x10` (`0x08017154`).
pub fn func_08017154() callconv(.c) void {
    if (!abi.enter(0x08017154)) return;
    scriptWrite16Or32(32, 0x08017174);
}

/// Clear secondary script flag halfword `[0x0300_2F44] = 0` (`0x08016F18`).
pub fn func_08016F18() callconv(.c) void {
    if (!abi.enter(0x08016F18)) return;
    abi.fetches(6);
    const dst = abi.read32(0x08016F20);
    abi.write16(dst, 0);
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

fn scriptCopyFromPtr(comptime width: u8, comptime pool_ref: u32) void {
    abi.fetches(if (width == 8) 20 else 19);
    const base = abi.read32(pool_ref);
    const idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const off: u32 = @bitCast(@as(i32, idx) *% @as(i32, types.script_slot_stride));
    const cur_ptr_addr = off +% (base +% 4);
    const cmd = abi.read32(cur_ptr_addr);
    const dst = abi.read32(cmd +% 4);
    const src = abi.read32(cmd +% 0xC);
    switch (width) {
        8 => {
            const v = abi.read8(src);
            abi.write8(dst, v);
            rt.r[2] = dst;
        },
        16 => {
            const v = abi.read16(src);
            abi.write16(dst, v);
            rt.r[2] = v;
            rt.r[3] = dst;
        },
        32 => {
            const v = abi.read32(src);
            abi.write32(dst, v);
            rt.r[2] = v;
            rt.r[3] = dst;
        },
        else => unreachable,
    }
    abi.write32(cur_ptr_addr, cmd +% 0x10);
    rt.r[1] = cur_ptr_addr;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

/// Secondary script command: copy 8-bit `*([cmd+0xC]) -> [cmd+4]`, step `cmd += 0x10` (`0x08017178`).
pub fn func_08017178() callconv(.c) void {
    if (!abi.enter(0x08017178)) return;
    scriptCopyFromPtr(8, 0x0801719C);
}

/// Secondary script command: copy 16-bit `*([cmd+0xC]) -> [cmd+4]`, step `cmd += 0x10` (`0x080171A0`).
pub fn func_080171A0() callconv(.c) void {
    if (!abi.enter(0x080171A0)) return;
    scriptCopyFromPtr(16, 0x080171C4);
}

/// Secondary script command: copy 32-bit `*([cmd+0xC]) -> [cmd+4]`, step `cmd += 0x10` (`0x080171C8`).
pub fn func_080171C8() callconv(.c) void {
    if (!abi.enter(0x080171C8)) return;
    scriptCopyFromPtr(32, 0x080171EC);
}

/// Secondary script command: write byte `[cmd+0xA]` into `battle_ui_state[+0x38 + slot]` and `entity[slot]+0x1B` (`0x08017EF8`).
pub fn func_08017EF8() callconv(.c) void {
    if (!abi.enter(0x08017EF8)) return;
    abi.fetches(30);
    const pool = abi.read32(0x08017F30);
    const idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const off: u32 = @bitCast(@as(i32, idx) *% @as(i32, types.script_slot_stride));
    const cur_ptr_addr = off +% (pool +% 4);
    const cmd = abi.read32(cur_ptr_addr);
    const slot_byte = abi.read8(cmd +% 8);
    const val16 = abi.read16(cmd +% 0xA);
    const ui_base = abi.read32(0x08017F34);
    abi.write8(slot_byte +% (ui_base +% 0x38), @truncate(val16));
    const entity_base = abi.read32(abi.read32(0x08017F38));
    abi.write8((@as(u32, slot_byte) *% 0x68) +% entity_base +% 0x1B, @truncate(val16));
    abi.write32(cur_ptr_addr, cmd +% 0x10);
    rt.r[2] = cur_ptr_addr;
    rt.r[3] = slot_byte;
    rt.r[1] = val16;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

/// Secondary script command: write byte `[cmd+0xA]` into `entity[read8(cmd+8)]+0x1D`, step `cmd += 0x10` (`0x08017F68`).
pub fn func_08017F68() callconv(.c) void {
    if (!abi.enter(0x08017F68)) return;
    abi.fetches(27);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const pool = abi.read32(0x08017F9C);
    const idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const off: u32 = @bitCast(@as(i32, idx) *% @as(i32, types.script_slot_stride));
    const cur_ptr_addr = off +% (pool +% 4);
    const cmd = abi.read32(cur_ptr_addr);
    const entity_base = abi.read32(abi.read32(0x08017FA0));
    const slot_byte = abi.read8(cmd +% 8);
    const val16 = abi.read16(cmd +% 0xA);
    abi.write8((@as(u32, slot_byte) *% 0x68) +% entity_base +% 0x1D, @truncate(val16));
    abi.write32(cur_ptr_addr, cmd +% 0x10);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[2] = val16;
    rt.r[3] = cmd;
    abi.setRegNz(&rt.r[0], 1);
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Clear `proc.state38 = 0` on active proc `[0x0300_1D18]` (`0x0802ABF0`).
pub fn func_0802ABF0() callconv(.c) void {
    if (!abi.enter(0x0802ABF0)) return;
    abi.fetches(13);
    const proc_base = abi.read32(0x0802AC08);
    const idx_ptr = abi.read32(0x0802AC0C);
    const proc_idx: i16 = @bitCast(abi.read16(idx_ptr));
    const proc_off: u32 = @bitCast(@as(i32, proc_idx) *% @as(i32, types.proc_slot_stride));
    const slot = proc_off +% proc_base;
    abi.write16(slot +% 0x38, 0);
    rt.r[3] = 0;
    rt.r[2] = proc_base;
    rt.r[0] = slot;
    abi.setRegNz(&rt.r[1], 0);
    abi.retLr();
}

/// Clear secondary script lock halfword `[0x0300_0DA4] = 0` (`0x080172F0`).
pub fn func_080172F0() callconv(.c) void {
    if (!abi.enter(0x080172F0)) return;
    abi.fetches(6);
    const dst = abi.read32(0x080172F8);
    abi.write16(dst, 0);
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Sync display halfword `[0x0300_3358] = read16(0x0300_0DC0)` (`0x0801735C`).
pub fn func_0801735C() callconv(.c) void {
    if (!abi.enter(0x0801735C)) return;
    abi.fetches(7);
    const dst = abi.read32(0x08017368);
    const val = abi.read16(abi.read32(0x0801736C));
    abi.write16(dst, val);
    rt.r[0] = dst;
    rt.r[1] = val;
    abi.retLr();
}

/// Secondary script command: copy `[cmd+4]` word into global `[0x0300_31F8]`, step `cmd += 0x10`, return `0` (`0x08017E04`).
pub fn func_08017E04() callconv(.c) void {
    if (!abi.enter(0x08017E04)) return;
    abi.fetches(18);
    const dst = abi.read32(0x08017E24);
    const base = abi.read32(0x08017E28);
    const idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const off: u32 = @bitCast(@as(i32, idx) *% @as(i32, types.script_slot_stride));
    const cur_ptr_addr = off +% (base +% 4);
    const cmd = abi.read32(cur_ptr_addr);
    const val = abi.read32(cmd +% 4);
    abi.write32(dst, val);
    abi.write32(cur_ptr_addr, cmd +% 0x10);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = val;
    rt.r[3] = dst;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Secondary script command: store `[cmd+4]` word into slot `+0x08`, step `cmd += 0x10`, return `0` (`0x08017E2C`).
pub fn func_08017E2C() callconv(.c) void {
    if (!abi.enter(0x08017E2C)) return;
    abi.fetches(20);
    const base = abi.read32(0x08017E50);
    const idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const off: u32 = @bitCast(@as(i32, idx) *% @as(i32, types.script_slot_stride));
    const dst = off +% (base +% 8);
    const cur_ptr_addr = off +% (base +% 4);
    const cmd = abi.read32(cur_ptr_addr);
    const val = abi.read32(cmd +% 4);
    abi.write32(dst, val);
    abi.write32(cur_ptr_addr, cmd +% 0x10);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = val;
    rt.r[3] = dst;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Cutscene command no-op preserving registers (`0x08018094`).
pub fn func_08018094() callconv(.c) void {
    if (!abi.enter(0x08018094)) return;
    abi.fetches(3);
    abi.retLr();
}

fn scriptUpdateCursorTile(comptime relative: bool, comptime cursor_ref: u32, comptime pool_ref: u32) void {
    abi.fetches(if (relative) 26 else 22);
    const cursor_addr = abi.read32(cursor_ref);
    const base = abi.read32(pool_ref);
    const idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const off: u32 = @bitCast(@as(i32, idx) *% @as(i32, types.script_slot_stride));
    const cur_ptr_addr = off +% (base +% 4);
    const cmd = abi.read32(cur_ptr_addr);
    const raw_x = abi.read16(cmd +% 8);
    const raw_y = abi.read16(cmd +% 0xA);
    if (relative) {
        const cur_x = abi.read16(cursor_addr);
        abi.write16(cursor_addr, cur_x +% raw_x);
        const cur_y = abi.read16(cursor_addr +% 2);
        abi.write16(cursor_addr +% 2, cur_y +% raw_y);
        rt.r[2] = cur_y;
    } else {
        abi.write16(cursor_addr, raw_x);
        abi.write16(cursor_addr +% 2, raw_y);
        rt.r[2] = base +% 4;
    }
    abi.write32(cur_ptr_addr, cmd +% 0x10);
    rt.r[1] = cur_ptr_addr;
    rt.r[3] = cursor_addr;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Secondary script command: set cursor tile `(x, y)` at `0x0300_36A4` (`0x080180EC`).
pub fn func_080180EC() callconv(.c) void {
    if (!abi.enter(0x080180EC)) return;
    scriptUpdateCursorTile(false, 0x08018114, 0x08018118);
}

/// Secondary script command: add `(dx, dy)` to cursor tile at `0x0300_36A4` (`0x0801811C`).
pub fn func_0801811C() callconv(.c) void {
    if (!abi.enter(0x0801811C)) return;
    scriptUpdateCursorTile(true, 0x0801814C, 0x08018150);
}

/// Secondary script command: advance `cmd += 0x10` and return `1` (`0x08018240`).
pub fn func_08018240() callconv(.c) void {
    if (!abi.enter(0x08018240)) return;
    abi.fetches(15);
    const base = abi.read32(0x0801825C);
    const idx: i16 = @bitCast(@as(u16, @truncate(rt.r[0])));
    const off: u32 = @bitCast(@as(i32, idx) *% @as(i32, types.script_slot_stride));
    const cur_ptr_addr = off +% (base +% 4);
    const cmd = abi.read32(cur_ptr_addr);
    abi.write32(cur_ptr_addr, cmd +% 0x10);
    rt.r[1] = cur_ptr_addr;
    rt.r[2] = base +% 4;
    abi.setRegNz(&rt.r[0], 1);
    abi.retLr();
}

/// Test whether proc template `0x0828_1D10` is currently running (`0x08018C40` -> `0x0801836C(tbl) != -1`).
pub fn func_08018C40() callconv(.c) void {
    if (!abi.enter(0x08018C40)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08018C5C);
    if (!abi.call(decls.func_0801836C, 0x08018C49)) return;
    abi.fetches(11);
    const val_i16 = abi.signExtend16(@truncate(rt.r[0]));
    const active: u32 = if (val_i16 != -1) 1 else 0;
    rt.r[1] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.setRegNz(&rt.r[0], active);
    rt.r[15] = rt.r[1];
    rt.recompReturn(rt.r[1]);
}

/// Forwarder calling `0x08018F94` (`0x08019120`).
pub fn func_08019120() callconv(.c) void {
    if (!abi.enter(0x08019120)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08018F94, 0x08019127)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch `[0x0828_1D60]` script helper via `0x0801329C` and return handle in `r0` (`0x08019608`).
pub fn func_08019608() callconv(.c) void {
    if (!abi.enter(0x08019608)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08019614);
    if (!abi.call(decls.func_0801329C, 0x08019611)) return;
    abi.fetches(4);
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Wrapper invoking `func_08019608` (discarding return address into `r0`) (`0x08019254`).
pub fn func_08019254() callconv(.c) void {
    if (!abi.enter(0x08019254)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_08019608, 0x0801925B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Wrapper invoking `func_08019608` (discarding return address into `r0`) (`0x08019260`).
pub fn func_08019260() callconv(.c) void {
    if (!abi.enter(0x08019260)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_08019608, 0x08019267)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Convert `0x08019288()` byte/halfword count `u16(n) -> (n + 3) >> 3` (`0x080192DC`).
pub fn func_080192DC() callconv(.c) void {
    if (!abi.enter(0x080192DC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019288, 0x080192E3)) return;
    abi.fetches(8);
    const raw: u32 = @as(u16, @truncate(rt.r[0]));
    const sum = raw +% 3;
    const chunks = sum >> 3;
    rt.r[1] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.setRegNz(&rt.r[0], chunks);
    rt.r[15] = rt.r[1];
    rt.recompReturn(rt.r[1]);
}

/// Dispatch proc field `proc->+0x18` via `0x0807B44C` (`0x08010F04`).
pub fn func_08010F04() callconv(.c) void {
    if (!abi.enter(0x08010F04)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(rt.r[0] +% 0x18);
    if (!abi.call(decls.func_0807B44C, 0x08010F0D)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn `0x08010F24` proc storing caller pointer `r0` at `proc->+0x18` (`0x08010F10`).
pub fn func_08010F10() callconv(.c) void {
    if (!abi.enter(0x08010F10)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[0] = abi.read32(0x08010F24);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08010F1D)) return;

    abi.fetches(6);
    abi.write32(rt.r[0] +% 0x18, rt.r[4]);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08010F04, .{ .name = "func_08010F04", .linkage = .strong });
        @export(&func_08010F10, .{ .name = "func_08010F10", .linkage = .strong });
        @export(&func_08013D14, .{ .name = "func_08013D14", .linkage = .strong });
        @export(&func_08013D3C, .{ .name = "func_08013D3C", .linkage = .strong });
        @export(&func_08013DA0, .{ .name = "func_08013DA0", .linkage = .strong });
        @export(&func_08013DF0, .{ .name = "func_08013DF0", .linkage = .strong });
        @export(&func_08013DF4, .{ .name = "func_08013DF4", .linkage = .strong });
        @export(&func_08014078, .{ .name = "func_08014078", .linkage = .strong });
        @export(&func_08016F18, .{ .name = "func_08016F18", .linkage = .strong });
        @export(&func_08017104, .{ .name = "func_08017104", .linkage = .strong });
        @export(&func_08017108, .{ .name = "func_08017108", .linkage = .strong });
        @export(&func_08017130, .{ .name = "func_08017130", .linkage = .strong });
        @export(&func_08017154, .{ .name = "func_08017154", .linkage = .strong });
        @export(&func_08017178, .{ .name = "func_08017178", .linkage = .strong });
        @export(&func_080171A0, .{ .name = "func_080171A0", .linkage = .strong });
        @export(&func_080171C8, .{ .name = "func_080171C8", .linkage = .strong });
        @export(&func_080172F0, .{ .name = "func_080172F0", .linkage = .strong });
        @export(&func_0801735C, .{ .name = "func_0801735C", .linkage = .strong });
        @export(&func_08017E04, .{ .name = "func_08017E04", .linkage = .strong });
        @export(&func_08017E2C, .{ .name = "func_08017E2C", .linkage = .strong });
        @export(&func_08017EF8, .{ .name = "func_08017EF8", .linkage = .strong });
        @export(&func_08017F68, .{ .name = "func_08017F68", .linkage = .strong });
        @export(&func_08018094, .{ .name = "func_08018094", .linkage = .strong });
        @export(&func_080180EC, .{ .name = "func_080180EC", .linkage = .strong });
        @export(&func_0801811C, .{ .name = "func_0801811C", .linkage = .strong });
        @export(&func_08018240, .{ .name = "func_08018240", .linkage = .strong });
        @export(&func_08018C40, .{ .name = "func_08018C40", .linkage = .strong });
        @export(&func_08019120, .{ .name = "func_08019120", .linkage = .strong });
        @export(&func_08019254, .{ .name = "func_08019254", .linkage = .strong });
        @export(&func_08019260, .{ .name = "func_08019260", .linkage = .strong });
        @export(&func_080192DC, .{ .name = "func_080192DC", .linkage = .strong });
        @export(&func_08019608, .{ .name = "func_08019608", .linkage = .strong });
        @export(&func_0802ABF0, .{ .name = "func_0802ABF0", .linkage = .strong });
    }
}

test "proc and script slot address helpers match GBA strides" {
    try std.testing.expectEqual(@as(u32, 0x0300_0E10), procSlotAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_0E70), procSlotAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0300_1D54), scriptCursorFieldAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_1D6C), scriptCursorFieldAddr(1));
}
