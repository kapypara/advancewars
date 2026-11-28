//! Lifted Advance Wars proc (`0x0300_0E10`) and cutscene script (`0x0300_1D50`)
//! opcode handlers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const abi = @import("abi.zig");
const battle = @import("battle.zig");
const clusters_low_2 = @import("clusters_low_2.zig");
const dma = @import("dma.zig");
const low_peel_1 = @import("low_peel_1.zig");
const low_peel_10 = @import("low_peel_10.zig");
const low_peel_15 = @import("low_peel_15.zig");
const low_peel_19 = @import("low_peel_19.zig");
const low_peel_3 = @import("low_peel_3.zig");
const low_peel_6 = @import("low_peel_6.zig");
const low_peel_7 = @import("low_peel_7.zig");
const low_peel_8 = @import("low_peel_8.zig");
const mem = @import("mem.zig");
const menu = @import("menu.zig");
const sound = @import("sound.zig");
const sprite_anim = @import("sprite_anim.zig");
const state = @import("state.zig");
const tail_low = @import("tail_low.zig");
const types = @import("types.zig");
const unit = @import("unit.zig");

/// Tick proc slot `u8(r0)` if its active bit (`flags & 1`) is set (`0x08013984`).
pub fn func_08013984() callconv(.c) void {
    if (!abi.enter(0x08013984)) return;
    abi.fetches(16);
    abi.pushLr();
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);

    const slot_idx: u8 = @truncate(rt.r[0]);
    const slot_addr = procSlotAddr(slot_idx);
    const flags = mem.readU16(slot_addr +% 0x12);

    rt.r[1] = slot_idx;
    rt.r[6] = slot_idx;
    rt.r[5] = types.addr.proc_table;
    rt.r[4] = slot_addr -% types.addr.proc_table;
    rt.r[2] = slot_addr;
    rt.r[3] = flags;

    const active: u32 = @as(u32, flags) & 1;
    rt.r[0] = active;
    rt.cpuSub(null, active, 0, true);

    if (active != 0) {
        abi.fetches(13);
        mem.writeU16(types.addr.active_proc_idx, slot_idx);
        mem.writeU16(slot_addr +% 0x12, flags & 0xFFFE);
        const on_idle = mem.readU32(slot_addr +% 0x08);
        rt.r[0] = slot_addr +% 0x08;
        rt.r[1] = on_idle;
        rt.cpuSub(null, on_idle, 0, true);

        if (on_idle != 0) {
            abi.fetches(5);
            rt.r[0] = slot_addr;
            if (!abi.call(tail_low.func_0807B450, 0x080139BD)) return;
        }
        abi.fetches(5);
        rt.r[0] = slot_idx;
        if (!abi.call(clusters_low_2.func_080139D4, 0x080139C3)) return;
    }

    abi.fetches(5);
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    abi.popReturn();
}

/// Pop the head task node from the singly-linked queue at `task_queue_anchor` (`0x0801A6D8`).
pub fn func_0801A6D8() callconv(.c) void {
    if (!abi.enter(0x0801A6D8)) return;
    abi.fetches(6);
    rt.r[2] = types.addr.task_queue_anchor;
    const head = mem.readU32(types.addr.task_queue_anchor +% 4);
    rt.r[1] = head;
    rt.cpuSub(null, head, 0, true);
    if (head == 0) {
        abi.fetches(3);
        abi.setRegNz(&rt.r[0], 0);
    } else {
        abi.fetches(6);
        const next = mem.readU32(head +% 4);
        mem.writeU32(types.addr.task_queue_anchor +% 4, next);
        rt.r[0] = mem.readU32(head);
    }
    abi.fetches(3);
    abi.retLr();
}

/// Compute EWRAM/IWRAM address of proc slot `idx` (`u8`, stride `0x60`).
pub inline fn procSlotAddr(slot_idx: u8) u32 {
    return mem.procSlotAddr(slot_idx);
}

/// Compute address of `+0x04` cursor word in secondary script slot `idx` (`i16`, stride `0x18`).
pub inline fn scriptCursorFieldAddr(slot_idx: i16) u32 {
    if (slot_idx >= 0) {
        return mem.scriptSlotAddr(@intCast(slot_idx)) +% @offsetOf(types.ScriptSlot, "script_cursor");
    }
    const signed: i32 = slot_idx;
    const off: u32 = @bitCast(signed *% @as(i32, types.script_slot_stride));
    return off +% (types.addr.script_pool +% @offsetOf(types.ScriptSlot, "script_cursor"));
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
    if (!abi.call(low_peel_3.func_0801836C, 0x08018C49)) return;
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
    if (!abi.call(low_peel_3.func_08018F94, 0x08019127)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch `[0x0828_1D60]` script helper via `0x0801329C` and return handle in `r0` (`0x08019608`).
pub fn func_08019608() callconv(.c) void {
    if (!abi.enter(0x08019608)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08019614);
    if (!abi.call(low_peel_6.func_0801329C, 0x08019611)) return;
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
    if (!abi.call(low_peel_6.func_08019288, 0x080192E3)) return;
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
    if (!abi.call(tail_low.func_0807B44C, 0x08010F0D)) return;
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
    if (!abi.call(low_peel_6.func_0801320C, 0x08010F1D)) return;

    abi.fetches(6);
    abi.write32(rt.r[0] +% 0x18, rt.r[4]);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn popReturnValue() void {
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

const ProcScriptArgKind = enum {
    proc_31E0,
    word0_r0,
    sext16_4_r0,
    u16_4_r0,
    word0_r1,
    u16_4_r1,
};

fn runProcScriptStep(
    comptime pool_ref: u32,
    comptime kind: ProcScriptArgKind,
    comptime target: fn () callconv(.c) void,
    comptime ret_val: u32,
    comptime ret_addr: u32,
) void {
    const fetches_before: u32 = switch (kind) {
        .proc_31E0, .sext16_4_r0 => 16,
        .word0_r0, .u16_4_r0, .word0_r1, .u16_4_r1 => 15,
    };
    abi.fetches(fetches_before);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const idx = rt.r[0] & 0xFF;
    const base = abi.read32(pool_ref);
    const entry_ptr = base +% 4 +% (((idx << 1) +% idx) << 5);
    rt.r[4] = entry_ptr;
    const script = abi.read32(entry_ptr);
    switch (kind) {
        .proc_31E0 => {
            rt.r[0] = abi.read32(script);
            rt.r[1] = abi.read8(script +% 4);
        },
        .word0_r0 => rt.r[0] = abi.read32(script),
        .sext16_4_r0 => rt.r[0] = @bitCast(abi.signExtend16(abi.read16(script +% 4))),
        .u16_4_r0 => rt.r[0] = abi.read16(script +% 4),
        .word0_r1 => {
            rt.r[0] = idx;
            rt.r[1] = abi.read32(script);
        },
        .u16_4_r1 => {
            rt.r[0] = idx;
            rt.r[1] = abi.read16(script +% 4);
        },
    }
    if (!abi.call(target, ret_addr)) return;

    abi.fetches(9);
    abi.write32(entry_ptr, abi.read32(entry_ptr) +% 8);
    abi.setRegNz(&rt.r[0], ret_val);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnValue();
}

const CutsceneStepPrep = enum {
    pass_slot_u16,
    set_flag5_zero_call,
    set_flag5_one_call,
    set_byte8_read_u16,
    read_u16,
    zero_r0,
    one_r0,
    read_ptr_r0,
};

fn runCutsceneStep10(
    comptime prep: CutsceneStepPrep,
    comptime extra_a: u32,
    comptime extra_b: u32,
    comptime target: fn () callconv(.c) void,
    comptime script_pool_ref: u32,
    comptime ret_val: u32,
    comptime ret_addr: u32,
) void {
    const fetches_before: u32 = switch (prep) {
        .pass_slot_u16 => 8,
        .set_flag5_zero_call, .set_flag5_one_call => 11,
        .set_byte8_read_u16 => 13,
        .read_u16 => 10,
        .zero_r0, .one_r0, .read_ptr_r0 => 9,
    };
    abi.fetches(fetches_before);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0] & 0xFFFF;
    switch (prep) {
        .pass_slot_u16 => rt.r[0] = rt.r[4],
        .set_flag5_zero_call => abi.write8(abi.read32(extra_a) +% 5, 0),
        .set_flag5_one_call => abi.write8(abi.read32(extra_a) +% 5, 1),
        .set_byte8_read_u16 => {
            abi.write8(abi.read32(extra_a), 8);
            rt.r[0] = abi.read16(abi.read32(extra_b));
        },
        .read_u16 => rt.r[0] = abi.read16(abi.read32(extra_a)),
        .zero_r0 => abi.setRegNz(&rt.r[0], 0),
        .one_r0 => abi.setRegNz(&rt.r[0], 1),
        .read_ptr_r0 => rt.r[0] = abi.read32(extra_a),
    }
    if (!abi.call(target, ret_addr)) return;

    abi.fetches(17);
    const slot: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[4])));
    const entry_ptr = abi.read32(script_pool_ref) +% 4 +% (slot * 24);
    abi.write32(entry_ptr, abi.read32(entry_ptr) +% 0x10);
    abi.setRegNz(&rt.r[0], ret_val);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnValue();
}

fn callCutscene18B28(comptime mode: u32, comptime pool_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(17);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const slot: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    const entry_ptr = abi.read32(pool_ref) +% 4 +% (slot * 24);
    rt.r[4] = entry_ptr;
    const script = abi.read32(entry_ptr);
    rt.r[1] = abi.read32(script +% 4);
    abi.setRegNz(&rt.r[0], mode);
    abi.setRegNz(&rt.r[2], 0);
    if (!abi.call(menu.func_08018B28, ret_addr)) return;

    abi.fetches(9);
    abi.write32(entry_ptr, abi.read32(entry_ptr) +% 0x10);
    abi.setRegNz(&rt.r[0], 1);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnValue();
}

fn attachCutsceneWaitCb(
    comptime base_ref: u32,
    comptime cb_ref: u32,
    comptime has_half_a: bool,
    comptime ret_addr: u32,
) void {
    abi.fetches(if (has_half_a) 24 else 21);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const base = abi.read32(base_ref);
    const slot: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    const slot_ptr = base +% (slot * 24);
    const entry_ptr = slot_ptr +% 4;
    rt.r[4] = entry_ptr;
    const script = abi.read32(entry_ptr);
    abi.write8(slot_ptr +% 0x11, @truncate(abi.read16(script +% 8)));
    if (has_half_a) {
        abi.write16(slot_ptr +% 0x12, abi.read16(script +% 0xA));
    }
    const cb_ptr = slot_ptr +% 8;
    const cb_fn = abi.read32(cb_ref);
    abi.write32(cb_ptr, cb_fn);
    rt.r[0] = slot_ptr;
    rt.r[1] = cb_ptr;
    rt.r[2] = cb_fn;
    if (!abi.call(tail_low.func_0807B454, ret_addr)) return;

    abi.fetches(9);
    abi.write32(entry_ptr, abi.read32(entry_ptr) +% 0x10);
    abi.setRegNz(&rt.r[0], 0);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnValue();
}

/// Release proc slot `u8(r0)` via `0x08013248` and return `0` (`0x08013C84`).
pub fn func_08013C84() callconv(.c) void {
    if (!abi.enter(0x08013C84)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] &= 0xFF;
    if (!abi.call(low_peel_6.func_08013248, 0x08013C8F)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    popReturnValue();
}

/// Proc script opcode: spawn child proc `(word0, byte4)` via `0x080131E0` (`0x08013C94`).
pub fn func_08013C94() callconv(.c) void {
    if (!abi.enter(0x08013C94)) return;
    runProcScriptStep(0x08013CC0, .proc_31E0, low_peel_3.func_080131E0, 1, 0x08013CB1);
}

/// Proc script opcode: load resource string/ID `word0` via `0x08018400` (`0x08013E1C`).
pub fn func_08013E1C() callconv(.c) void {
    if (!abi.enter(0x08013E1C)) return;
    runProcScriptStep(0x08013E44, .word0_r0, low_peel_6.func_08018400, 1, 0x08013E37);
}

/// Proc script opcode: release proc `i16(half4)` via `0x08013248` (`0x08013E7C`).
pub fn func_08013E7C() callconv(.c) void {
    if (!abi.enter(0x08013E7C)) return;
    runProcScriptStep(0x08013EA8, .sext16_4_r0, low_peel_6.func_08013248, 1, 0x08013E99);
}

/// Proc script opcode: unpause/wake proc def `word0` via `0x080132D8` (`0x08013EAC`).
pub fn func_08013EAC() callconv(.c) void {
    if (!abi.enter(0x08013EAC)) return;
    runProcScriptStep(0x08013ED4, .word0_r0, low_peel_6.func_080132D8, 1, 0x08013EC7);
}

/// Proc script opcode: end proc def `word0` via `0x0801329C` (`0x08013ED8`).
pub fn func_08013ED8() callconv(.c) void {
    if (!abi.enter(0x08013ED8)) return;
    runProcScriptStep(0x08013F00, .word0_r0, low_peel_6.func_0801329C, 1, 0x08013EF3);
}

/// Proc script opcode: spawn menu proc `0x0800F63C(half4)` (`0x08013F80`).
pub fn func_08013F80() callconv(.c) void {
    if (!abi.enter(0x08013F80)) return;
    runProcScriptStep(0x08013FA8, .u16_4_r0, menu.func_0800F63C, 0, 0x08013F9B);
}

/// Proc script opcode: spawn menu proc `0x0800F66C(half4)` (`0x08013FAC`).
pub fn func_08013FAC() callconv(.c) void {
    if (!abi.enter(0x08013FAC)) return;
    runProcScriptStep(0x08013FD4, .u16_4_r0, menu.func_0800F66C, 0, 0x08013FC7);
}

/// Proc script opcode: spawn menu proc `0x0800F69C(half4)` (`0x08013FD8`).
pub fn func_08013FD8() callconv(.c) void {
    if (!abi.enter(0x08013FD8)) return;
    runProcScriptStep(0x08014000, .u16_4_r0, menu.func_0800F69C, 0, 0x08013FF3);
}

/// Proc script opcode: spawn menu proc `0x0800F6DC(half4)` (`0x08014004`).
pub fn func_08014004() callconv(.c) void {
    if (!abi.enter(0x08014004)) return;
    runProcScriptStep(0x0801402C, .u16_4_r0, menu.func_0800F6DC, 0, 0x0801401F);
}

/// Proc script opcode: play music track `i16(half4)` via `0x0803D8C8` (`0x080140A0`).
pub fn func_080140A0() callconv(.c) void {
    if (!abi.enter(0x080140A0)) return;
    runProcScriptStep(0x080140CC, .sext16_4_r0, low_peel_8.func_0803D8C8, 0, 0x080140BD);
}

/// Proc script opcode: play sound effect `i16(half4)` via `0x0803D880` (`0x080140D0`).
pub fn func_080140D0() callconv(.c) void {
    if (!abi.enter(0x080140D0)) return;
    runProcScriptStep(0x080140FC, .sext16_4_r0, sound.func_0803D880, 0, 0x080140ED);
}

/// Proc script opcode: spawn menu proc `0x0800F71C(half4)` (`0x08014100`).
pub fn func_08014100() callconv(.c) void {
    if (!abi.enter(0x08014100)) return;
    runProcScriptStep(0x08014128, .u16_4_r0, menu.func_0800F71C, 0, 0x0801411B);
}

/// Proc script opcode: spawn menu proc `0x0800F738(half4)` (`0x0801412C`).
pub fn func_0801412C() callconv(.c) void {
    if (!abi.enter(0x0801412C)) return;
    runProcScriptStep(0x08014154, .u16_4_r0, menu.func_0800F738, 0, 0x08014147);
}

/// Proc script opcode: bind animator callback `word0` via `0x08013678` (`0x08014760`).
pub fn func_08014760() callconv(.c) void {
    if (!abi.enter(0x08014760)) return;
    runProcScriptStep(0x08014788, .word0_r1, sprite_anim.func_08013678, 1, 0x0801477B);
}

/// Proc script opcode: set animator frame `half4` via `0x080136A4` (`0x0801478C`).
pub fn func_0801478C() callconv(.c) void {
    if (!abi.enter(0x0801478C)) return;
    runProcScriptStep(0x080147B4, .u16_4_r1, low_peel_3.func_080136A4, 1, 0x080147A7);
}

/// Cutscene script opcode: query flag via `0x0801DE88(word4)` and write `state+2` (`0x08017070`).
pub fn func_08017070() callconv(.c) void {
    if (!abi.enter(0x08017070)) return;
    abi.fetches(15);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const slot: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    const entry_ptr = abi.read32(0x0801709C) +% 4 +% (slot * 24);
    rt.r[4] = entry_ptr;
    const script = abi.read32(entry_ptr);
    rt.r[0] = abi.read32(script +% 4);
    if (!abi.call(low_peel_3.func_0801DE88, 0x0801708B)) return;

    abi.fetches(11);
    abi.write8(abi.read32(0x080170A0) +% 2, @truncate(rt.r[0]));
    abi.write32(entry_ptr, abi.read32(entry_ptr) +% 0x10);
    abi.setRegNz(&rt.r[0], 0);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnValue();
}

/// Cutscene script opcode: spawn unit/effect `(i16 +8, i16 +10, i16 +12)` via `0x080242B8` (`0x08017254`).
pub fn func_08017254() callconv(.c) void {
    if (!abi.enter(0x08017254)) return;
    abi.fetches(20);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const slot: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    const entry_ptr = abi.read32(0x08017288) +% 4 +% (slot * 24);
    rt.r[4] = entry_ptr;
    const script = abi.read32(entry_ptr);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(script +% 8)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(script +% 0xA)));
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(script +% 0xC)));
    if (!abi.call(low_peel_3.func_080242B8, 0x08017279)) return;

    abi.fetches(9);
    abi.write32(entry_ptr, abi.read32(entry_ptr) +% 0x10);
    abi.setRegNz(&rt.r[0], 0);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnValue();
}

/// Cutscene script opcode: dispatch `0x080172F0(slot)` and advance cursor `+0x10` (`0x080172FC`).
pub fn func_080172FC() callconv(.c) void {
    if (!abi.enter(0x080172FC)) return;
    runCutsceneStep10(.pass_slot_u16, 0, 0, func_080172F0, 0x08017328, 1, 0x08017309);
}

/// Cutscene script opcode: dispatch `0x080172E4(slot)` and advance cursor `+0x10` (`0x0801732C`).
pub fn func_0801732C() callconv(.c) void {
    if (!abi.enter(0x0801732C)) return;
    runCutsceneStep10(.pass_slot_u16, 0, 0, low_peel_1.func_080172E4, 0x08017358, 1, 0x08017339);
}

/// Cutscene script opcode: set flag `[state+5] = 1`, call `0x0802EFD8`, advance `+0x10` (`0x08017AB0`).
pub fn func_08017AB0() callconv(.c) void {
    if (!abi.enter(0x08017AB0)) return;
    runCutsceneStep10(.set_flag5_one_call, 0x08017AE0, 0, battle.func_0802EFD8, 0x08017AE4, 1, 0x08017AC3);
}

/// Cutscene script opcode: clear `[state+5] = 0`, call `0x0802EFD8`, advance `+0x10` (`0x08017AE8`).
pub fn func_08017AE8() callconv(.c) void {
    if (!abi.enter(0x08017AE8)) return;
    runCutsceneStep10(.set_flag5_zero_call, 0x08017B18, 0, battle.func_0802EFD8, 0x08017B1C, 1, 0x08017AFB);
}

/// Cutscene script opcode: mark byte `8`, focus cursor via `0x08019970`, advance `+0x10` (`0x08017B80`).
pub fn func_08017B80() callconv(.c) void {
    if (!abi.enter(0x08017B80)) return;
    runCutsceneStep10(.set_byte8_read_u16, 0x08017BB4, 0x08017BB8, unit.func_08019970, 0x08017BBC, 1, 0x08017B97);
}

/// Cutscene script opcode: focus cursor via `0x0801990C`, advance `+0x10` (`0x08017C3C`).
pub fn func_08017C3C() callconv(.c) void {
    if (!abi.enter(0x08017C3C)) return;
    runCutsceneStep10(.read_u16, 0x08017C6C, 0, low_peel_6.func_0801990C, 0x08017C70, 1, 0x08017C4D);
}

/// Cutscene script opcode: arm wait callback `0x08017D90` storing `(half8, halfA)` (`0x08017D50`).
pub fn func_08017D50() callconv(.c) void {
    if (!abi.enter(0x08017D50)) return;
    attachCutsceneWaitCb(0x08017D8C, 0x08017D90, true, 0x08017D7D);
}

/// Cutscene script opcode: arm wait callback `0x08017E00` storing `half8` (`0x08017DC8`).
pub fn func_08017DC8() callconv(.c) void {
    if (!abi.enter(0x08017DC8)) return;
    attachCutsceneWaitCb(0x08017DFC, 0x08017E00, false, 0x08017DEF);
}

/// Cutscene script opcode: reset state via `0x08018AAC(0)` and advance `+0x10` (`0x08017FD0`).
pub fn func_08017FD0() callconv(.c) void {
    if (!abi.enter(0x08017FD0)) return;
    runCutsceneStep10(.zero_r0, 0, 0, state.func_08018AAC, 0x08017FFC, 1, 0x08017FDF);
}

/// Cutscene script opcode: enable state via `0x08018AAC(1)` and advance `+0x10` (`0x08018000`).
pub fn func_08018000() callconv(.c) void {
    if (!abi.enter(0x08018000)) return;
    runCutsceneStep10(.one_r0, 0, 0, state.func_08018AAC, 0x0801802C, 1, 0x0801800F);
}

/// Cutscene script opcode: hide script dialogue (`0`) via `0x08018B28` and advance `+0x10` (`0x08018030`).
pub fn func_08018030() callconv(.c) void {
    if (!abi.enter(0x08018030)) return;
    callCutscene18B28(0, 0x0801805C, 0x0801804F);
}

/// Cutscene script opcode: show script dialogue (`1`) via `0x08018B28` and advance `+0x10` (`0x08018060`).
pub fn func_08018060() callconv(.c) void {
    if (!abi.enter(0x08018060)) return;
    callCutscene18B28(1, 0x0801808C, 0x0801807F);
}

/// Center cutscene/cursor sprite `arg->+0x14` relative to camera via `0x08020868` (`0x08018154`).
pub fn func_08018154() callconv(.c) void {
    if (!abi.enter(0x08018154)) return;
    abi.fetches(20);
    abi.pushLr();
    const s = abi.read32(rt.r[0] +% 0x14);
    const cam = abi.read32(abi.read32(0x08018180));
    const dx: u16 = @truncate(abi.read16(s +% 8) -% abi.read16(cam +% 4));
    const dy: u16 = @truncate(abi.read16(s +% 0xA) -% abi.read16(cam +% 6));
    rt.r[0] = @bitCast(abi.signExtend16(dx));
    rt.r[1] = @bitCast(abi.signExtend16(dy));
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(s +% 0xC)));
    if (!abi.call(low_peel_19.func_08020868, 0x08018179)) return;
    abi.fetches(5);
    abi.popReturn();
}

/// Cutscene script opcode: load resource string `0x08018204` via `0x080183C0`, advance `+0x10` (`0x080181D8`).
pub fn func_080181D8() callconv(.c) void {
    if (!abi.enter(0x080181D8)) return;
    runCutsceneStep10(.read_ptr_r0, 0x08018204, 0, low_peel_6.func_080183C0, 0x08018208, 1, 0x080181E7);
}

/// Cutscene script opcode: refresh tactical markers via `0x08026750`, advance `+0x10`, return `0` (`0x08018260`).
pub fn func_08018260() callconv(.c) void {
    if (!abi.enter(0x08018260)) return;
    runCutsceneStep10(.pass_slot_u16, 0, 0, low_peel_7.func_08026750, 0x0801828C, 0, 0x0801826D);
}

/// Spawn `0x0801108C` proc, init I/O state via `0x0807B460`, and store `(r1, r2)` into `+0x20/+0x24` (`0x08011060`).
pub fn func_08011060() callconv(.c) void {
    if (!abi.enter(0x08011060)) return;
    abi.fetches(12);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[6] = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);

    rt.r[5] = rt.r[0];
    rt.r[6] = rt.r[1];
    rt.r[8] = rt.r[2];
    rt.r[0] = abi.read32(0x0801108C);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(low_peel_6.func_0801320C, 0x08011075)) return;

    abi.fetches(5);
    rt.r[4] = rt.r[0];
    if (!abi.call(tail_low.func_0807B460, 0x0801107B)) return;

    abi.fetches(10);
    abi.write32(rt.r[4] +% 0x20, rt.r[6]);
    rt.r[0] = rt.r[8];
    abi.write32(rt.r[4] +% 0x24, rt.r[0]);
    const saved_r8 = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = saved_r8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Run cutscene script subsystem tear-down `0x08016438` then `0x08016820` (`0x080168D8`).
pub fn func_080168D8() callconv(.c) void {
    if (!abi.enter(0x080168D8)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(low_peel_19.func_08016438, 0x080168DF)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_10.func_08016820, 0x080168E3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Load cutscene script buffer `0x08016F40` via `0x08016F68` and flush DMA via `0x080178F4` (`0x08016F30`).
pub fn func_08016F30() callconv(.c) void {
    if (!abi.enter(0x08016F30)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08016F40);
    if (!abi.call(low_peel_6.func_08016F68, 0x08016F39)) return;
    abi.fetches(4);
    if (!abi.call(dma.func_080178F4, 0x08016F3D)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Fill `[0x08016FE4]` halfword array up to count `[0x08016FEC]` with `[0x08016FE8]` and set both cursor shadows to `[0x08016FF0]` (`0x08016FA8`).
pub fn func_08016FA8() callconv(.c) void {
    if (!abi.enter(0x08016FA8)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    var idx: i32 = 0;
    const dst_a = abi.read32(0x08016FDC);
    const dst_b = abi.read32(0x08016FE0);
    const arr = abi.read32(0x08016FE4);
    const fill = abi.read32(0x08016FE8);
    const limit = abi.read32(0x08016FEC);
    while (true) {
        abi.fetches(13);
        const cur: u32 = @bitCast(idx);
        abi.write16(arr +% (cur << 1), @truncate(fill));
        const next: i32 = @as(i16, @truncate(idx +% 1));
        if (next > @as(i32, @bitCast(limit))) {
            break;
        }
        idx = next;
    }

    abi.fetches(9);
    const end_val = abi.read32(0x08016FF0);
    abi.setRegNz(&rt.r[0], end_val);
    abi.write16(dst_a, @truncate(end_val));
    abi.write16(dst_b, @truncate(end_val));
    rt.r[1] = end_val;
    rt.r[2] = limit;
    rt.r[3] = fill;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Cutscene script opcode: set handler `[0x080170E4]`, trigger `0x08035220` + `0x08027FB4`, advance `+0x10`, return `0` (`0x080170A4`).
pub fn func_080170A4() callconv(.c) void {
    if (!abi.enter(0x080170A4)) return;
    abi.fetches(16);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const pool = abi.read32(0x080170E0);
    const slot_off = scriptCursorFieldAddr(@bitCast(@as(u16, @truncate(rt.r[0])))) -% types.addr.script_pool -% 4;
    rt.r[5] = pool;
    rt.r[4] = slot_off;
    abi.write32(pool +% 8 +% slot_off, abi.read32(0x080170E4));
    if (!abi.call(state.func_08035220, 0x080170C1)) return;

    abi.fetches(10);
    rt.r[0] = abi.read8(abi.read32(0x080170E8) +% 2);
    const ptr_field = pool +% 4 +% slot_off;
    rt.r[1] = abi.read32(abi.read32(ptr_field) +% 4);
    if (!abi.call(unit.func_08027FB4, 0x080170D1)) return;

    abi.fetches(9);
    abi.write32(ptr_field, abi.read32(ptr_field) +% 0x10);
    abi.setRegNz(&rt.r[0], 0);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnValue();
}

/// Cutscene script opcode: move cursor via `0x0802928C(i16 s+8, i16 s+0xA)`, set handler `[0x08017250]`, advance `+0x10` (`0x08017214`).
pub fn func_08017214() callconv(.c) void {
    if (!abi.enter(0x08017214)) return;
    abi.fetches(18);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const pool = abi.read32(0x0801724C);
    const slot_off = scriptCursorFieldAddr(@bitCast(@as(u16, @truncate(rt.r[0])))) -% types.addr.script_pool -% 4;
    const ptr_field = pool +% 4 +% slot_off;
    const s = abi.read32(ptr_field);
    rt.r[6] = pool;
    rt.r[4] = slot_off;
    rt.r[5] = ptr_field;
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(s +% 8)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(s +% 0xA)));
    abi.setRegNz(&rt.r[2], 0xA);
    if (!abi.call(low_peel_15.func_0802928C, 0x08017235)) return;

    abi.fetches(13);
    abi.write32(pool +% 8 +% slot_off, abi.read32(0x08017250));
    abi.write32(ptr_field, abi.read32(ptr_field) +% 0x10);
    abi.setRegNz(&rt.r[0], 0);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnValue();
}

/// Cutscene script opcode: open window via `0x080123A8`, set flags/handler, advance `+0x10`, return `0` (`0x08017A40`).
pub fn func_08017A40() callconv(.c) void {
    if (!abi.enter(0x08017A40)) return;
    abi.fetches(27);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const pool = abi.read32(0x08017AA0);
    const slot_off = scriptCursorFieldAddr(@bitCast(@as(u16, @truncate(rt.r[0])))) -% types.addr.script_pool -% 4;
    rt.r[4] = slot_off;
    rt.r[5] = pool;
    rt.r[2] = abi.read32(0x08017A9C);
    rt.r[3] = abi.read32(pool +% 0x14 +% slot_off);
    abi.write32(rt.r[13], @as(u32, abi.read8(abi.read32(0x08017AA4))) << 28 >> 16);
    abi.write32(rt.r[13] +% 4, 0x100);
    abi.setRegNz(&rt.r[0], 7);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(sprite_anim.func_080123A8, 0x08017A73)) return;

    abi.fetches(22);
    abi.write32(rt.r[0] +% 0x3C, abi.read32(0x08017AA8));
    abi.write8(rt.r[0] +% 0x38, 1);
    abi.write32(pool +% 8 +% slot_off, abi.read32(0x08017AAC));
    const ptr_field = pool +% 4 +% slot_off;
    abi.write32(ptr_field, abi.read32(ptr_field) +% 0x10);
    abi.setRegNz(&rt.r[0], 0);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnValue();
}

/// Initialize script/animator entry `u8(r1)` at `[0x08013140]` with handler `r0` and kind `u8(r2)` (`0x080130D0`).
pub fn func_080130D0() callconv(.c) void {
    if (!abi.enter(0x080130D0)) return;
    abi.fetches(57);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const handler = rt.r[0];
    const slot_idx = rt.r[1] & 0xFF;
    const base = abi.read32(0x08013140);
    const slot_off = (slot_idx *% 3) << 5;
    const ent = base +% slot_off;
    abi.write32(ent, handler);
    abi.write32(base +% 4 +% slot_off, handler);
    abi.write16(ent +% 0x10, 0);
    abi.write32(base +% 0xC +% slot_off, 0);
    abi.write16(ent +% 0x38, 0);
    abi.write8(ent +% 0x14, @truncate(rt.r[2]));
    abi.write32(base +% 0x18 +% slot_off, 0);
    abi.write32(base +% 8 +% slot_off, 0);
    const neg_one: u32 = @bitCast(@as(i32, -1));
    abi.write32(base +% 0x34 +% slot_off, neg_one);
    abi.write32(base +% 0x30 +% slot_off, neg_one);
    abi.write32(base +% 0x2C +% slot_off, neg_one);
    abi.write32(base +% 0x28 +% slot_off, neg_one);
    abi.write16(ent +% 0x24, 0);
    abi.write16(ent +% 0x22, 0);
    abi.write16(ent +% 0x20, 0);
    abi.write16(ent +% 0x1E, 0);

    rt.r[12] = base;
    rt.cpuSub(&rt.r[0], 0, 1, true);
    rt.r[1] = base +% 0x30 +% slot_off;
    rt.r[2] = base +% 0x2C +% slot_off;
    rt.r[3] = base +% 0x34 +% slot_off;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Temporarily bind `[0x08013194]` to `u16(r1)`, run `func_080130D0` + `0x080139D4`, and return `i8(r1)` (`0x08013144`).
pub fn func_08013144() callconv(.c) void {
    if (!abi.enter(0x08013144)) return;
    abi.fetches(20);
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

    const slot_id_u16 = rt.r[1] & 0xFFFF;
    const slot_id_u8 = slot_id_u16 & 0xFF;
    const active_ptr = abi.read32(0x08013194);
    const prev_id = abi.read16(active_ptr);
    rt.r[9] = prev_id;
    abi.write16(active_ptr, @truncate(slot_id_u16));
    rt.r[8] = slot_id_u8;
    rt.r[1] = slot_id_u8;
    rt.r[2] &= 0xFF;
    rt.updateNz(rt.r[2]);
    if (!abi.call(func_080130D0, 0x08013169)) return;

    abi.fetches(14);
    const slot_i32 = abi.signExtend16(@truncate(slot_id_u16));
    const slot_addr = (@as(u32, @bitCast((slot_i32 *% 3) << 5))) +% abi.read32(0x08013198);
    abi.write16(slot_addr +% 0x12, 0);
    rt.r[0] = slot_id_u8;
    if (!abi.call(clusters_low_2.func_080139D4, 0x08013181)) return;

    abi.fetches(12);
    abi.write16(active_ptr, prev_id);
    const ret_val: u32 = @bitCast(abi.signExtend8(@truncate(slot_id_u8)));
    abi.setRegNz(&rt.r[0], ret_val);

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
    popReturnValue();
}

/// Fetch OAM attributes `0x080135FC(i16(r0))`, update tile bits/palette nibble, and write back `0x08013598` (`0x0801381C`).
pub fn func_0801381C() callconv(.c) void {
    if (!abi.enter(0x0801381C)) return;
    abi.fetches(19);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 0xC;

    const slot_id: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    const tile_bits = rt.r[1] & 0xFFFF;
    const pal_bank = rt.r[2] & 0xFFFF;
    const stack_oam = rt.r[13];
    rt.r[4] = tile_bits;
    rt.r[5] = pal_bank;
    rt.r[6] = stack_oam;
    rt.r[0] = slot_id;
    rt.r[1] = stack_oam;
    abi.write32(rt.r[13] +% 8, slot_id);
    if (!abi.call(sprite_anim.func_080135FC, 0x0801383F)) return;

    abi.fetches(22);
    const tile_masked = tile_bits & abi.read32(0x08013870);
    const oam_attr2 = (abi.read16(stack_oam +% 4) & abi.read32(0x08013874)) | tile_masked;
    abi.write16(stack_oam +% 4, @truncate(oam_attr2));
    const attr2_hi = ((pal_bank << 4) | (abi.read8(stack_oam +% 5) & 0xF)) & 0xFF;
    abi.write8(stack_oam +% 5, @truncate(attr2_hi));
    rt.r[0] = slot_id;
    rt.r[1] = abi.read32(rt.r[13]);
    rt.r[2] = abi.read32(rt.r[13] +% 4);
    rt.r[3] = slot_id;
    if (!abi.call(sprite_anim.func_08013598, 0x08013867)) return;

    abi.fetches(6);
    rt.r[13] +%= 0xC;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Advance slot `i16(r0)` animator `0x0801A250` and clear OAM priority/size bits via `0x080135FC`/`0x08013598` (`0x08014850`).
pub fn func_08014850() callconv(.c) void {
    if (!abi.enter(0x08014850)) return;
    abi.fetches(25);
    abi.pushLr();
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const slot_id: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    const anim_base = abi.read32(0x080148D0);
    const slot_ent = (@as(u32, @bitCast((@as(i32, @bitCast(slot_id)) *% 3) << 5))) +% abi.read32(0x080148D4);
    rt.r[8] = anim_base;
    rt.r[5] = slot_id;
    rt.r[4] = slot_ent;
    rt.r[6] = 0x4C;
    const anim_idx = abi.read16(slot_ent +% 0x26);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(anim_base +% (anim_idx *% 0x4C) +% 0x3A)));
    if (!abi.call(low_peel_1.func_0801A250, 0x0801487F)) return;

    abi.fetches(13);
    const anim_idx2 = abi.read16(slot_ent +% 0x26);
    abi.write16(anim_base +% (anim_idx2 *% 0x4C) +% 0x3A, @truncate(abi.read32(0x080148D8)));
    rt.r[4] = rt.r[13];
    rt.r[0] = slot_id;
    rt.r[1] = rt.r[13];
    if (!abi.call(sprite_anim.func_080135FC, 0x08014895)) return;

    abi.fetches(25);
    const oam = rt.r[13];
    const b1_masked = abi.read8(oam +% 1) & @as(u8, @truncate(0xFFFF_FFFC)) & @as(u8, @truncate(0xFFFF_FFFD));
    _ = b1_masked;
    abi.write8(oam +% 1, abi.read8(oam +% 1) & 0xFC);
    const b3_clear: u8 = @truncate(0 -% @as(u32, 0x21)); // ~0x20: clears bit5+bits0..3 -> ((b3 & ~0xF) & ~0x11 & ~0x21)
    _ = b3_clear;
    const orig_b3 = abi.read8(oam +% 3);
    const step1 = orig_b3 & (@as(u8, @truncate(0 -% @as(u32, 0xF))));
    const step2 = step1 & (@as(u8, @truncate(0 -% @as(u32, 0x11))));
    const step3 = step2 & (@as(u8, @truncate((0 -% @as(u32, 0x11)) -% 0x10)));
    abi.write8(oam +% 3, step3);
    rt.r[0] = slot_id;
    rt.r[1] = abi.read32(rt.r[13]);
    rt.r[2] = abi.read32(rt.r[13] +% 4);
    if (!abi.call(sprite_anim.func_08013598, 0x080148C3)) return;

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
    abi.popReturn();
}

/// Bind sprite slot `u16(r0)` to object palette/priority attributes via `0x0801A218`/`0x080135FC` (`0x080147B8`).
pub fn func_080147B8() callconv(.c) void {
    if (!abi.enter(0x080147B8)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const slot_u16 = rt.r[0] & 0xFFFF;
    const slot_s16: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    rt.r[5] = slot_s16;
    rt.r[0] = slot_u16;
    if (!abi.call(low_peel_6.func_0801A218, 0x080147C7)) return;

    abi.fetches(23);
    const val_u8 = rt.r[0] & 0xFF;
    const val_s8: u32 = @bitCast(abi.signExtend8(@truncate(val_u8)));
    rt.r[4] = val_u8;
    const slot_entry = (slot_s16 *% 3 << 5) +% abi.read32(0x0801484C);
    const anim_idx = abi.read16(slot_entry +% 0x26);
    const anim_slot = (@as(u32, anim_idx) *% 0x4C) +% abi.read32(0x08014848);
    abi.write16(anim_slot +% 0x3A, @truncate(rt.r[0]));

    rt.r[6] = rt.r[13];
    rt.r[0] = slot_s16;
    rt.r[1] = rt.r[13];
    if (!abi.call(sprite_anim.func_080135FC, 0x080147F1)) return;

    abi.fetches(41);
    abi.write8(rt.r[6] +% 1, @truncate(@as(u32, abi.read8(rt.r[6] +% 1)) | 1));
    const old_b3: u32 = abi.read8(rt.r[6] +% 3);
    const new_b3 = (old_b3 & ~@as(u32, 0x3E)) |
        ((val_s8 & 7) << 1) |
        (((val_s8 >> 3) & 1) << 4) |
        (((val_s8 >> 4) & 1) << 5);
    abi.write8(rt.r[6] +% 3, @truncate(new_b3));

    rt.r[0] = rt.r[5];
    rt.r[1] = abi.read32(rt.r[13] +% 0x0);
    rt.r[2] = abi.read32(rt.r[13] +% 0x4);
    if (!abi.call(sprite_anim.func_08013598, 0x0801483F)) return;

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

/// Scan the 40-slot proc table for a slot whose `script_start` equals `script_start`.
fn scanProcSlotByScript(script_start: u32) ?u8 {
    rt.r[2] = script_start;
    rt.r[3] = types.addr.proc_table;
    var idx: u8 = 0;
    while (idx < types.proc_slot_count) : (idx += 1) {
        abi.fetches(9);
        const slot_addr = mem.procSlotAddr(idx);
        const cur_script = abi.read32(slot_addr +% @offsetOf(types.ProcSlot, "script_start"));
        rt.cpuSub(null, cur_script, script_start, true);
        if (rt.CPU_Z) {
            rt.r[1] = idx;
            return idx;
        }
        abi.fetches(7);
    }
    rt.r[1] = types.proc_slot_count;
    rt.cpuSub(null, @as(u32, types.proc_slot_count), @as(u32, types.proc_slot_count - 1), true);
    return null;
}

/// Return `1` if any active proc slot has `flags & 1` set, else `0` (`0x08013B34`).
pub fn func_08013B34() callconv(.c) void {
    if (!abi.enter(0x08013B34)) return;
    abi.fetches(6);
    rt.r[3] = types.addr.proc_table;
    var idx: u8 = 0;
    while (idx < types.proc_slot_count) : (idx += 1) {
        abi.fetches(9);
        const slot_addr = mem.procSlotAddr(idx);
        const script_start = abi.read32(slot_addr +% @offsetOf(types.ProcSlot, "script_start"));
        rt.cpuSub(null, script_start, 0, true);
        if (script_start != 0) {
            abi.fetches(7);
            const flags = abi.read16(slot_addr +% @offsetOf(types.ProcSlot, "flags"));
            rt.cpuSub(null, flags & 1, 0, true);
            if ((flags & 1) != 0) {
                abi.fetches(9);
                rt.r[1] = rt.r[14];
                rt.r[2] = idx;
                abi.setRegNz(&rt.r[0], 1);
                abi.retLr();
                return;
            }
        }
        abi.fetches(7);
    }
    abi.fetches(8);
    rt.r[1] = rt.r[14];
    rt.r[2] = types.proc_slot_count;
    rt.cpuSub(null, @as(u32, types.proc_slot_count - 1), @as(u32, types.proc_slot_count - 1), true);
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Return sign-extended `i8` slot index of proc with `script_start == r0`, or `-1` (`0x08013B70`).
pub fn func_08013B70() callconv(.c) void {
    if (!abi.enter(0x08013B70)) return;
    abi.fetches(5);
    if (scanProcSlotByScript(rt.r[0])) |idx| {
        abi.fetches(8);
        const s: i8 = @bitCast(idx);
        abi.setRegNz(&rt.r[0], @bitCast(@as(i32, s)));
        abi.retLr();
        return;
    }
    abi.fetches(7);
    abi.setRegNz(&rt.r[0], 1);
    rt.cpuSub(&rt.r[0], 0, rt.r[0], true);
    abi.retLr();
}

/// Return `1` if any proc has `script_start == r0`, else `0` (`0x08013BA0`).
pub fn func_08013BA0() callconv(.c) void {
    if (!abi.enter(0x08013BA0)) return;
    abi.fetches(5);
    if (scanProcSlotByScript(rt.r[0]) != null) {
        abi.fetches(7);
        abi.setRegNz(&rt.r[0], 1);
        abi.retLr();
        return;
    }
    abi.fetches(6);
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08010F04, .{ .name = "func_08010F04", .linkage = .strong });
        @export(&func_08011060, .{ .name = "func_08011060", .linkage = .strong });
        @export(&func_080168D8, .{ .name = "func_080168D8", .linkage = .strong });
        @export(&func_08016F30, .{ .name = "func_08016F30", .linkage = .strong });
        @export(&func_08016FA8, .{ .name = "func_08016FA8", .linkage = .strong });
        @export(&func_080170A4, .{ .name = "func_080170A4", .linkage = .strong });
        @export(&func_08017214, .{ .name = "func_08017214", .linkage = .strong });
        @export(&func_08017A40, .{ .name = "func_08017A40", .linkage = .strong });
        @export(&func_08010F10, .{ .name = "func_08010F10", .linkage = .strong });
        @export(&func_08013C84, .{ .name = "func_08013C84", .linkage = .strong });
        @export(&func_08013C94, .{ .name = "func_08013C94", .linkage = .strong });
        @export(&func_08013D14, .{ .name = "func_08013D14", .linkage = .strong });
        @export(&func_08013E1C, .{ .name = "func_08013E1C", .linkage = .strong });
        @export(&func_08013E7C, .{ .name = "func_08013E7C", .linkage = .strong });
        @export(&func_08013EAC, .{ .name = "func_08013EAC", .linkage = .strong });
        @export(&func_08013ED8, .{ .name = "func_08013ED8", .linkage = .strong });
        @export(&func_08013F80, .{ .name = "func_08013F80", .linkage = .strong });
        @export(&func_08013FAC, .{ .name = "func_08013FAC", .linkage = .strong });
        @export(&func_08013FD8, .{ .name = "func_08013FD8", .linkage = .strong });
        @export(&func_08014004, .{ .name = "func_08014004", .linkage = .strong });
        @export(&func_080140A0, .{ .name = "func_080140A0", .linkage = .strong });
        @export(&func_080140D0, .{ .name = "func_080140D0", .linkage = .strong });
        @export(&func_08014100, .{ .name = "func_08014100", .linkage = .strong });
        @export(&func_0801412C, .{ .name = "func_0801412C", .linkage = .strong });
        @export(&func_08014760, .{ .name = "func_08014760", .linkage = .strong });
        @export(&func_0801478C, .{ .name = "func_0801478C", .linkage = .strong });
        @export(&func_08017070, .{ .name = "func_08017070", .linkage = .strong });
        @export(&func_08017254, .{ .name = "func_08017254", .linkage = .strong });
        @export(&func_080172FC, .{ .name = "func_080172FC", .linkage = .strong });
        @export(&func_0801732C, .{ .name = "func_0801732C", .linkage = .strong });
        @export(&func_08017AB0, .{ .name = "func_08017AB0", .linkage = .strong });
        @export(&func_08017AE8, .{ .name = "func_08017AE8", .linkage = .strong });
        @export(&func_08017B80, .{ .name = "func_08017B80", .linkage = .strong });
        @export(&func_08017C3C, .{ .name = "func_08017C3C", .linkage = .strong });
        @export(&func_08017D50, .{ .name = "func_08017D50", .linkage = .strong });
        @export(&func_08017DC8, .{ .name = "func_08017DC8", .linkage = .strong });
        @export(&func_08017FD0, .{ .name = "func_08017FD0", .linkage = .strong });
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
        @export(&func_08018000, .{ .name = "func_08018000", .linkage = .strong });
        @export(&func_08018030, .{ .name = "func_08018030", .linkage = .strong });
        @export(&func_08018060, .{ .name = "func_08018060", .linkage = .strong });
        @export(&func_08018094, .{ .name = "func_08018094", .linkage = .strong });
        @export(&func_080180EC, .{ .name = "func_080180EC", .linkage = .strong });
        @export(&func_0801811C, .{ .name = "func_0801811C", .linkage = .strong });
        @export(&func_08018154, .{ .name = "func_08018154", .linkage = .strong });
        @export(&func_080181D8, .{ .name = "func_080181D8", .linkage = .strong });
        @export(&func_08018240, .{ .name = "func_08018240", .linkage = .strong });
        @export(&func_08018260, .{ .name = "func_08018260", .linkage = .strong });
        @export(&func_08018C40, .{ .name = "func_08018C40", .linkage = .strong });
        @export(&func_08019120, .{ .name = "func_08019120", .linkage = .strong });
        @export(&func_08019254, .{ .name = "func_08019254", .linkage = .strong });
        @export(&func_08019260, .{ .name = "func_08019260", .linkage = .strong });
        @export(&func_080192DC, .{ .name = "func_080192DC", .linkage = .strong });
        @export(&func_08019608, .{ .name = "func_08019608", .linkage = .strong });
        @export(&func_0802ABF0, .{ .name = "func_0802ABF0", .linkage = .strong });
        @export(&func_080130D0, .{ .name = "func_080130D0", .linkage = .strong });
        @export(&func_08013144, .{ .name = "func_08013144", .linkage = .strong });
        @export(&func_0801381C, .{ .name = "func_0801381C", .linkage = .strong });
        @export(&func_08014850, .{ .name = "func_08014850", .linkage = .strong });
        @export(&func_080147B8, .{ .name = "func_080147B8", .linkage = .strong });
        @export(&func_08013984, .{ .name = "func_08013984", .linkage = .strong });
        @export(&func_0801A6D8, .{ .name = "func_0801A6D8", .linkage = .strong });
        @export(&func_08013B34, .{ .name = "func_08013B34", .linkage = .strong });
        @export(&func_08013B70, .{ .name = "func_08013B70", .linkage = .strong });
        @export(&func_08013BA0, .{ .name = "func_08013BA0", .linkage = .strong });
    }
}

test "proc and script slot address helpers match GBA strides" {
    try std.testing.expectEqual(@as(u32, 0x0300_0E10), procSlotAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_0E70), procSlotAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0300_1D50), mem.scriptSlotAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_1D68), mem.scriptSlotAddr(1));
    try std.testing.expectEqual(@as(u32, 0x0300_1D54), scriptCursorFieldAddr(0));
    try std.testing.expectEqual(@as(u32, 0x0300_1D6C), scriptCursorFieldAddr(1));
}
