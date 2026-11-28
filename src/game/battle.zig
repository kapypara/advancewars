//! Lifted Advance Wars battle damage computation, combat overlays & turn phase helpers (`0x08022220..0x0802C4B4`).

const std = @import("std");
const rt = @import("runtime");
const abi = @import("abi.zig");
const bios = @import("bios.zig");
const campaign = @import("campaign.zig");
const dma = @import("dma.zig");
const hw = @import("hw.zig");
const low_peel_1 = @import("low_peel_1.zig");
const low_peel_10 = @import("low_peel_10.zig");
const low_peel_11 = @import("low_peel_11.zig");
const low_peel_12 = @import("low_peel_12.zig");
const low_peel_13 = @import("low_peel_13.zig");
const low_peel_14 = @import("low_peel_14.zig");
const low_peel_15 = @import("low_peel_15.zig");
const low_peel_16 = @import("low_peel_16.zig");
const low_peel_17 = @import("low_peel_17.zig");
const low_peel_18 = @import("low_peel_18.zig");
const low_peel_2 = @import("low_peel_2.zig");
const low_peel_3 = @import("low_peel_3.zig");
const low_peel_4 = @import("low_peel_4.zig");
const low_peel_5 = @import("low_peel_5.zig");
const low_peel_6 = @import("low_peel_6.zig");
const low_peel_7 = @import("low_peel_7.zig");
const low_peel_8 = @import("low_peel_8.zig");
const low_peel_9 = @import("low_peel_9.zig");
const map = @import("map.zig");
const math = @import("math.zig");
const mem = @import("mem.zig");
const proc = @import("proc.zig");
const sound = @import("sound.zig");
const sprite_anim = @import("sprite_anim.zig");
const state_mod = @import("state.zig");
const tail_low = @import("tail_low.zig");
const turn = @import("turn.zig");
const types = @import("types.zig");
const ui = @import("ui.zig");
const unit = @import("unit.zig");

/// Typed cross-module bridge resolving combat state (`func_0802FC70`).
pub inline fn resolveCombatStateCall(comptime ret_addr: u32) bool {
    return abi.call(func_0802FC70, ret_addr);
}

/// [Phase 4 API — uncalled while GBA_VALIDATE requires bios.func_080796C8 SWI 0x06 Div]
/// Compute raw scaled battle HP damage: `((100 - defense_pct) * base_damage) / 100`.
pub inline fn computeScaledDamage(defense_pct: i32, base_damage: i32) i32 {
    return @divTrunc((100 - defense_pct) * base_damage, 100);
}

/// [Phase 4 API — uncalled while GBA_VALIDATE requires bios.func_080796C8 SWI 0x06 Div]
/// Compute scaled counterattack power from defender remaining HP and `counter_power`: `(max(remaining_hp, 0) * counter_power) / 100`.
pub inline fn computeCounterAttackPower(remaining_hp: i16, counter_power: i16) i16 {
    const eff_hp: i32 = if (remaining_hp < 0) 0 else remaining_hp;
    return @truncate(@divTrunc(eff_hp * @as(i32, counter_power), 100));
}

pub const CombatHpPair = struct {
    a: i16,
    b: i16,
};

/// Resolve post-combat remaining HP: clamp negatives to `0`, and on mutual KO award `1` HP to whichever side stayed higher (`a >= b` favors `a`).
pub fn clampCombatRemainingHp(a_hp: i16, b_hp: i16) CombatHpPair {
    if (a_hp <= 0 and b_hp <= 0) {
        return if (a_hp >= b_hp) .{ .a = 1, .b = 0 } else .{ .a = 0, .b = 1 };
    }
    return .{
        .a = if (a_hp < 0) 0 else a_hp,
        .b = if (b_hp < 0) 0 else b_hp,
    };
}

/// Forward to `0x080220F8` (`0x08022220`).
pub fn func_08022220() callconv(.c) void {
    if (!abi.enter(0x08022220)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(ui.func_080220F8, 0x08022227)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Trigger effect `0x08015824(0x0802_2329, 0xA)` (`0x080224C8`).
pub fn func_080224C8() callconv(.c) void {
    if (!abi.enter(0x080224C8)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x080224D8);
    abi.setRegNz(&rt.r[1], 0xA);
    if (!abi.call(low_peel_6.func_08015824, 0x080224D3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Release proc `*(0x0300_4228)` via `0x08012E14` (`0x080226A4`).
pub fn func_080226A4() callconv(.c) void {
    if (!abi.enter(0x080226A4)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(abi.read32(0x080226B4));
    if (!abi.call(low_peel_3.func_08012E14, 0x080226AF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Compute scaled battle damage `((100 - r0.0xE) * r1.0xC) / 100`, store in `r0.0x12`, subtract from target HP into `r0.0x8` (`0x080234A0`).
pub fn func_080234A0() callconv(.c) void {
    if (!abi.enter(0x080234A0)) return;
    abi.fetches(14);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const ctx = rt.r[0];
    rt.r[4] = ctx;
    const def_ctx = mem.readBattleSideCtx(ctx);
    const atk_ctx = mem.readBattleSideCtx(rt.r[1]);
    rt.r[0] = @bitCast((100 -% @as(i32, def_ctx.defense_pct)) *% @as(i32, atk_ctx.attack_power));
    rt.r[2] = 0xC;
    abi.setRegNz(&rt.r[1], 100);
    if (!bios.divSwiCall(0x080234B9)) return;

    abi.fetches(12);
    const dmg = rt.r[0];
    abi.write16(ctx +% @offsetOf(@import("types.zig").BattleSideCtx, "dealt_damage"), @truncate(dmg));
    const cur_hp: u32 = mem.readUnitHp(def_ctx.unit_ptr);
    rt.cpuSub(&rt.r[1], cur_hp, dmg, true);
    abi.write16(ctx +% @offsetOf(@import("types.zig").BattleSideCtx, "remaining_hp"), @truncate(rt.r[1]));

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Resolve full combat exchange: attacker (`r0`) strikes defender (`r1`), scales defender counterattack power, and defender counterstrikes (`0x080234CC`).
pub fn func_080234CC() callconv(.c) void {
    if (!abi.enter(0x080234CC)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const atk = rt.r[0];
    const def = rt.r[1];
    rt.r[5] = atk;
    rt.r[4] = def;
    rt.r[0] = def;
    rt.r[1] = atk;
    if (!abi.call(func_080234A0, 0x080234DB)) return;

    abi.fetches(7);
    const rem_off = @offsetOf(types.BattleSideCtx, "remaining_hp");
    const rem_hp: i32 = mem.readI16(def +% rem_off);
    var eff_hp: i32 = 0;
    rt.cpuSub(null, @bitCast(rem_hp), 0, true);
    if (rt.CPU_N == rt.CPU_V) {
        abi.fetches(3);
        eff_hp = rem_hp;
    }

    abi.fetches(10);
    const cp_off = @offsetOf(types.BattleSideCtx, "counter_power");
    const cpower: i32 = mem.readI16(def +% cp_off);
    abi.setRegNz(&rt.r[0], @bitCast(eff_hp *% cpower));
    abi.setRegNz(&rt.r[1], 100);
    if (!bios.divSwiCall(0x080234F7)) return;

    abi.fetches(7);
    mem.writeU16(def +% @offsetOf(types.BattleSideCtx, "attack_power"), @truncate(rt.r[0]));
    rt.r[0] = atk;
    rt.r[1] = def;
    if (!abi.call(func_080234A0, 0x08023501)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Normalize remaining HP on both battle sides (`r0`, `r1`), preventing mutual KO by keeping the higher side at `1` (`0x08023508`).
pub fn func_08023508() callconv(.c) void {
    if (!abi.enter(0x08023508)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const side_a = rt.r[0];
    const side_b = rt.r[1];
    const rem_off = @offsetOf(types.BattleSideCtx, "remaining_hp");
    rt.r[2] = side_a;
    rt.r[3] = side_b;
    rt.r[1] = rem_off;
    const a_i16 = mem.readI16(side_a +% rem_off);
    const a_hp: i32 = a_i16;
    const b_i16 = mem.readI16(side_b +% rem_off);
    const b_hp: i32 = b_i16;
    const resolved = clampCombatRemainingHp(a_i16, b_i16);
    rt.r[0] = @bitCast(a_hp);
    rt.cpuSub(null, rt.r[0], 0, true);

    var check_b_neg = false;
    if (!rt.CPU_Z and rt.CPU_N == rt.CPU_V) {
        check_b_neg = true;
    } else {
        abi.fetches(6);
        rt.r[4] = rem_off;
        rt.r[1] = @bitCast(b_hp);
        rt.cpuSub(null, rt.r[1], 0, true);
        if (!rt.CPU_Z and rt.CPU_N == rt.CPU_V) {
            abi.fetches(4);
            rt.cpuSub(null, @bitCast(a_hp), 0, true);
            if (rt.CPU_N != rt.CPU_V) {
                abi.fetches(4);
                abi.setRegNz(&rt.r[0], 0);
                mem.writeI16(side_a +% rem_off, resolved.a);
            }
            check_b_neg = true;
        } else {
            abi.fetches(4);
            rt.cpuSub(null, @bitCast(a_hp), @bitCast(b_hp), true);
            abi.fetches(7);
            abi.setRegNz(&rt.r[1], 0);
            abi.setRegNz(&rt.r[0], 1);
            mem.writeI16(side_a +% rem_off, resolved.a);
            mem.writeI16(side_b +% rem_off, resolved.b);
        }
    }

    if (check_b_neg) {
        abi.fetches(6);
        rt.r[1] = rem_off;
        rt.r[0] = @bitCast(b_hp);
        rt.cpuSub(null, rt.r[0], 0, true);
        if (rt.CPU_N != rt.CPU_V) {
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 0);
            mem.writeI16(side_b +% rem_off, resolved.b);
        }
    }

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Forward signed 16-bit pair `(i16(r0), i16(r1))` to `0x08023550` (`0x08023888`).
pub fn func_08023888() callconv(.c) void {
    if (!abi.enter(0x08023888)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(rt.r[1])));
    rt.updateNz(rt.r[1]);
    if (!abi.call(low_peel_11.func_08023550, 0x08023897)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward signed 16-bit pair `(i16(r0), i16(r1))` to `0x08023550` (`0x0802389C`).
pub fn func_0802389C() callconv(.c) void {
    if (!abi.enter(0x0802389C)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(rt.r[1])));
    rt.updateNz(rt.r[1]);
    if (!abi.call(low_peel_11.func_08023550, 0x080238AB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Run `0x08023AA8` while preserving/restoring `[0x0300_3570]` halfword, returning callee `r0` (`0x08023B88`).
pub fn func_08023B88() callconv(.c) void {
    if (!abi.enter(0x08023B88)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const save_addr = abi.read32(0x08023B9C);
    const prev_val = abi.read16(save_addr);
    rt.r[4] = save_addr;
    rt.r[5] = prev_val;
    if (!abi.call(low_peel_11.func_08023AA8, 0x08023B93)) return;

    abi.fetches(6);
    abi.write16(save_addr, prev_val);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Look up entity/unit `u16(r0)` (stride `12` at `*(0x0828_2CB8)`), test `0x08023BFC`, return `u8` in `r0` (`0x08023D2C`).
pub fn func_08023D2C() callconv(.c) void {
    if (!abi.enter(0x08023D2C)) return;
    abi.fetches(15);
    abi.pushLr();
    const idx: u16 = @truncate(rt.r[0]);
    const entry = mem.unitRecordAddr(mem.unitListBase(), idx);
    rt.r[0] = entry;
    rt.r[1] = mem.readU8(entry +% @offsetOf(types.UnitRecord, "tile_x"));
    rt.r[2] = mem.readU8(entry +% @offsetOf(types.UnitRecord, "tile_y"));
    if (!abi.call(low_peel_14.func_08023BFC, 0x08023D47)) return;

    abi.fetches(6);
    const byte_res: u32 = @as(u8, @truncate(rt.r[0]));
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.setRegNz(&rt.r[0], byte_res);
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Clear `[0x0300_3570] = 0` and call `0x0801E188` (`0x08024D88`).
pub fn func_08024D88() callconv(.c) void {
    if (!abi.enter(0x08024D88)) return;
    abi.fetches(8);
    abi.pushLr();
    abi.write16(abi.read32(0x08024D98), 0);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(low_peel_14.func_0801E188, 0x08024D95)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward to `0x08024D9C` (`0x08024EB8`).
pub fn func_08024EB8() callconv(.c) void {
    if (!abi.enter(0x08024EB8)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(low_peel_11.func_08024D9C, 0x08024EBF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward `(i16(r0), 0, cursor_state)` to `0x08026CA0` (`0x08026C88`).
pub fn func_08026C88() callconv(.c) void {
    if (!abi.enter(0x08026C88)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    rt.r[2] = abi.read16(abi.read32(0x08026C9C));
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(low_peel_15.func_08026CA0, 0x08026C99)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn callWith26C88Arg(comptime flag: u8, comptime tbl_off: u32, comptime state_ref: u32, comptime tbl_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(12);
    abi.pushLr();
    const state = abi.read32(state_ref);
    abi.write8(state, flag);
    const val: u32 = @bitCast(abi.signExtend16(abi.read16(abi.read32(tbl_ref) +% tbl_off)));
    abi.write32(state +% 4, val);
    rt.r[0] = val;
    rt.r[1] = state;
    rt.r[2] = tbl_off;
    if (!abi.call(func_08026C88, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Initialize left-side battle preview using `0x0808_1850[0]` and invoke `func_08026C88` (`0x08026F30`).
pub fn func_08026F30() callconv(.c) void {
    if (!abi.enter(0x08026F30)) return;
    callWith26C88Arg(0, 0, 0x08026F48, 0x08026F4C, 0x08026F45);
}

/// Initialize right-side battle preview using `0x0808_1850[1]` and invoke `func_08026C88` (`0x08026F50`).
pub fn func_08026F50() callconv(.c) void {
    if (!abi.enter(0x08026F50)) return;
    callWith26C88Arg(1, 2, 0x08026F68, 0x08026F6C, 0x08026F65);
}

/// Dispatch combat indicator `0x0802C11C` for object `*(0x0828_A6B4)` (`0x08027578`).
pub fn func_08027578() callconv(.c) void {
    if (!abi.enter(0x08027578)) return;
    abi.fetches(15);
    abi.pushLr();
    const obj = abi.read32(abi.read32(0x08027598));
    rt.r[0] = abi.read16(obj +% 0x10);
    rt.r[1] = (abi.read16(obj +% 0x12) +% 0x10) & 0xFFFF;
    const val_i8 = abi.signExtend8(abi.read8(obj +% 4));
    rt.r[2] = @bitCast(val_i8);
    rt.updateNz(rt.r[2]);
    if (!abi.call(low_peel_7.func_0802C11C, 0x08027593)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Copy `0x200` words from `0x080B_D0FC + (u16(r0) << 9)` into VRAM `0x0601_29A0 + (u16(r1) << 9)` (`0x08027E18`).
pub fn func_08027E18() callconv(.c) void {
    if (!abi.enter(0x08027E18)) return;
    abi.fetches(15);
    abi.pushLr();
    const src_idx: u16 = @truncate(rt.r[0]);
    const dst_idx: u16 = @truncate(rt.r[1]);
    rt.r[0] = (@as(u32, src_idx) << 9) +% abi.read32(0x08027E38);
    rt.r[1] = (@as(u32, dst_idx) << 9) +% abi.read32(0x08027E3C);
    abi.setRegNz(&rt.r[2], 0x200);
    if (!dma.enqueueOrCopyAbiCall(0x08027E33)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Update HUD card for `[0x0300_36AC]` via `0x080199A0` (`0x08027F44`).
pub fn func_08027F44() callconv(.c) void {
    if (!abi.enter(0x08027F44)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read16(abi.read32(0x08027F54));
    if (!abi.call(map.func_080199A0, 0x08027F4F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear `[0x0300_4200]`, sync tile cursor `0x0300_36A4` from `0x0300_33AC`, spawn proc `0x080290CC` (`0x0802962C`).
pub fn func_0802962C() callconv(.c) void {
    if (!abi.enter(0x0802962C)) return;
    abi.fetches(14);
    abi.pushLr();
    abi.write16(abi.read32(0x08029648), 0);
    const dst = abi.read32(0x0802964C);
    const src = abi.read32(0x08029650);
    abi.write16(dst, abi.read16(src));
    const v1 = abi.read16(src +% 2);
    abi.write16(dst +% 2, v1);
    rt.r[2] = dst;
    rt.r[1] = src;
    rt.r[0] = v1;
    if (!abi.call(unit.func_080290CC, 0x08029645)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Draw unit overlay at `(u8(r0.0x20), u8(r0.0x22))` via `0x08026934` (`0x08029F6C`).
pub fn func_08029F6C() callconv(.c) void {
    if (!abi.enter(0x08029F6C)) return;
    abi.fetches(12);
    abi.pushLr();
    const obj = rt.r[0];
    const x: u32 = @as(u8, @truncate(abi.read16(obj +% 0x20)));
    const y: u32 = @as(u8, @truncate(abi.read16(obj +% 0x22)));
    rt.r[2] = abi.read16(obj +% 0x20);
    rt.r[1] = y;
    rt.r[0] = x;
    rt.updateNz(y);
    if (!abi.call(low_peel_7.func_08026934, 0x08029F81)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Trigger combat marker at active entity's `(0x2B, 0x2C)` tile via `0x0802928C` (`0x0802A97C`).
pub fn func_0802A97C() callconv(.c) void {
    if (!abi.enter(0x0802A97C)) return;
    abi.fetches(17);
    abi.pushLr();
    const active = abi.read16(abi.read32(0x0802A9A0));
    const base = abi.read32(abi.read32(0x0802A9A4));
    const ent = base +% (@as(u32, active) *% unit.entity_stride);
    rt.r[2] = base;
    rt.r[0] = abi.read8(ent +% 0x2B);
    rt.r[1] = abi.read8(ent +% 0x2C);
    if (!abi.call(low_peel_15.func_0802928C, 0x0802A99B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward `0` to `0x08026FC8` (`0x0802A9A8`).
pub fn func_0802A9A8() callconv(.c) void {
    if (!abi.enter(0x0802A9A8)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(low_peel_7.func_08026FC8, 0x0802A9B1)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Draw battle overlay `0x0828_AE34` via `hw.func_0801B888` (`0x0802BF48`).
pub fn func_0802BF48() callconv(.c) void {
    if (!abi.enter(0x0802BF48)) return;
    abi.fetches(17);
    abi.pushLr();
    rt.r[0] &= 0x1FF;
    const masked_y: i16 = @bitCast(@as(u16, @truncate(rt.r[1] | 0x400)));
    rt.r[1] = @bitCast(@as(i32, masked_y));
    rt.r[2] = abi.read32(0x0802BF6C);
    abi.setRegNz(&rt.r[3], 0x1C);
    if (!hw.drawDispatchCall(0x0802BF67)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Invoke `0x0802BFB0` for `(active_cursor - 1)` entry in `0x0808_1850` (`0x0802C034`).
pub fn func_0802C034() callconv(.c) void {
    if (!abi.enter(0x0802C034)) return;
    abi.fetches(13);
    abi.pushLr();
    const tbl = abi.read32(0x0802C050);
    const active: u32 = abi.read16(abi.read32(0x0802C054));
    const idx = active -% 1;
    rt.r[1] = 0;
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(tbl +% (idx << 1))));
    rt.updateNz(rt.r[1]);
    if (!abi.call(func_0802BFB0, 0x0802C04B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Enqueue battle transition callback `0x0802_C035` via `0x08015824` (`0x0802C0AC`).
pub fn func_0802C0AC() callconv(.c) void {
    if (!abi.enter(0x0802C0AC)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0802C0BC);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(low_peel_6.func_08015824, 0x0802C0B7)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn call2C368WithId(comptime id: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], id);
    if (!abi.call(low_peel_11.func_0802C368, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Battle outcome overlay `0` (`0x0802C49C` -> `0x0802C368(0)`).
pub fn func_0802C49C() callconv(.c) void {
    if (!abi.enter(0x0802C49C)) return;
    call2C368WithId(0, 0x0802C4A5);
}

/// Battle outcome overlay `1` (`0x0802C4A8` -> `0x0802C368(1)`).
pub fn func_0802C4A8() callconv(.c) void {
    if (!abi.enter(0x0802C4A8)) return;
    call2C368WithId(1, 0x0802C4B1);
}

/// Battle outcome overlay `2` (`0x0802C4B4` -> `0x0802C368(2)`).
pub fn func_0802C4B4() callconv(.c) void {
    if (!abi.enter(0x0802C4B4)) return;
    call2C368WithId(2, 0x0802C4BD);
}

fn call2E508WithPool(comptime pool_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(pool_ref);
    if (!abi.call(func_0802E508, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward directly to `0x08019608` battle UI refresh (`0x0802D724`).
pub fn func_0802D724() callconv(.c) void {
    if (!abi.enter(0x0802D724)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(proc.func_08019608, 0x0802D72B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Record battle animation parameter `u8(r1)`, refresh via `0x08019608`, and set phase `2` (`0x0802D968`).
pub fn func_0802D968() callconv(.c) void {
    if (!abi.enter(0x0802D968)) return;
    abi.fetches(9);
    abi.pushLr();
    abi.write32(abi.read32(0x0802D980), rt.r[1] & 0xFF);
    if (!abi.call(proc.func_08019608, 0x0802D977)) return;
    abi.fetches(7);
    abi.write16(abi.read32(0x0802D984), 2);
    abi.popReturn();
}

/// Dispatch combat sprite/overlay descriptor `0x0802E5C0` via `0x0802E508` (`0x0802E5B4`).
pub fn func_0802E5B4() callconv(.c) void {
    if (!abi.enter(0x0802E5B4)) return;
    call2E508WithPool(0x0802E5C0, 0x0802E5BD);
}

/// Dispatch combat sprite/overlay descriptor `0x0802E5D0` via `0x0802E508` (`0x0802E5C4`).
pub fn func_0802E5C4() callconv(.c) void {
    if (!abi.enter(0x0802E5C4)) return;
    call2E508WithPool(0x0802E5D0, 0x0802E5CD);
}

/// Dispatch combat sprite/overlay descriptor `0x0802E5E0` via `0x0802E508` (`0x0802E5D4`).
pub fn func_0802E5D4() callconv(.c) void {
    if (!abi.enter(0x0802E5D4)) return;
    call2E508WithPool(0x0802E5E0, 0x0802E5DD);
}

/// Dispatch combat sprite/overlay descriptor `0x0802E5F0` via `0x0802E508` (`0x0802E5E4`).
pub fn func_0802E5E4() callconv(.c) void {
    if (!abi.enter(0x0802E5E4)) return;
    call2E508WithPool(0x0802E5F0, 0x0802E5ED);
}

/// Flush pending combat overlay effects via `0x0802E558` (`0x0802E5F4`).
pub fn func_0802E5F4() callconv(.c) void {
    if (!abi.enter(0x0802E5F4)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_0802E558, 0x0802E5FB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Enqueue battle message/effect script `0x0802EF28` at `(0, 0)` (`0x0802EF18`).
pub fn func_0802EF18() callconv(.c) void {
    if (!abi.enter(0x0802EF18)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0802EF28);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0);
    if (!abi.call(ui.func_08018C1C, 0x0802EF25)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Advance unit/battle state via `0x08022148` and enter phase `8` (`0x0802F634`).
pub fn func_0802F634() callconv(.c) void {
    if (!abi.enter(0x0802F634)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(map.func_08022148, 0x0802F63B)) return;
    abi.fetches(7);
    abi.write16(abi.read32(0x0802F644), 8);
    abi.popReturn();
}

/// Dispatch `[0x08066AE0]` bytes `(+2, +3, +1)` to `0x080243DC` and set phase `[0x08066AE4] = 6` (`0x08066AC8`).
pub fn func_08066AC8() callconv(.c) void {
    if (!abi.enter(0x08066AC8)) return;
    abi.fetches(9);
    abi.pushLr();
    const st = abi.read32(0x08066AE0);
    rt.r[0] = abi.read8(st +% 2);
    rt.r[1] = abi.read8(st +% 3);
    rt.r[2] = abi.read8(st +% 1);
    if (!abi.call(low_peel_11.func_080243DC, 0x08066AD7)) return;

    abi.fetches(7);
    rt.r[1] = abi.read32(0x08066AE4);
    abi.setRegNz(&rt.r[0], 6);
    abi.write16(rt.r[1], 6);
    abi.popReturn();
}

/// Invoke `0x0801C120` with byte `[0x08066BB0]+6` (`0x08066BA0`).
pub fn func_08066BA0() callconv(.c) void {
    if (!abi.enter(0x08066BA0)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read8(abi.read32(0x08066BB0) +% 6);
    if (!abi.call(unit.func_0801C120, 0x08066BAB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear unit selection via `0x0802615C([0x08066CA4]+6)` and set phases `(2, 0)` (`0x08066C88`).
pub fn func_08066C88() callconv(.c) void {
    if (!abi.enter(0x08066C88)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read8(abi.read32(0x08066CA4) +% 6);
    if (!abi.call(ui.func_0802615C, 0x08066C93)) return;

    abi.fetches(10);
    abi.write16(abi.read32(0x08066CA8), 2);
    rt.r[1] = abi.read32(0x08066CAC);
    abi.setRegNz(&rt.r[0], 0);
    abi.write16(rt.r[1], 0);
    abi.popReturn();
}

/// Enable battle overlay via `0x0802C4A8` and set flag bit `0x20` on `*(0x08066E94)+1` (`0x08066E7C`).
pub fn func_08066E7C() callconv(.c) void {
    if (!abi.enter(0x08066E7C)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_0802C4A8, 0x08066E83)) return;

    abi.fetches(10);
    rt.r[1] = abi.read32(abi.read32(0x08066E94));
    rt.r[2] = abi.read8(rt.r[1] +% 1);
    rt.r[0] = 0x20 | rt.r[2];
    abi.write8(rt.r[1] +% 1, @truncate(rt.r[0]));
    abi.popReturn();
}

/// Disable battle overlay via `0x0802C49C` and clear flag bit `0x20` on `*(0x08066EB0)+1` (`0x08066E98`).
pub fn func_08066E98() callconv(.c) void {
    if (!abi.enter(0x08066E98)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_0802C49C, 0x08066E9F)) return;

    abi.fetches(10);
    rt.r[1] = abi.read32(abi.read32(0x08066EB0));
    rt.r[2] = abi.read8(rt.r[1] +% 1);
    rt.r[0] = 0xDF & rt.r[2];
    abi.write8(rt.r[1] +% 1, @truncate(rt.r[0]));
    abi.popReturn();
}

/// Advance battle state `[0x08066EC4]` via `0x0802AAF8` (`0x08066EB4`).
pub fn func_08066EB4() callconv(.c) void {
    if (!abi.enter(0x08066EB4)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(abi.read32(0x08066EC4));
    if (!abi.call(unit.func_0802AAF8, 0x08066EBF)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn writeArg1Byte19608AndThen(
    comptime pool_ref: u32,
    comptime ret1: u32,
    comptime next_fn: fn () callconv(.c) void,
    comptime ret2: u32,
) void {
    abi.fetches(9);
    abi.pushLr();
    const val = rt.r[1] & 0xFF;
    rt.updateNz(val);
    rt.r[1] = val;
    rt.r[0] = abi.read32(pool_ref);
    abi.write32(rt.r[0], val);
    if (!abi.call(proc.func_08019608, ret1)) return;
    abi.fetches(4);
    if (!abi.call(next_fn, ret2)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn runBattleAction19A1C(comptime next_fn: fn () callconv(.c) void, comptime r0: u32, comptime r1: u32, comptime r2: u32) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(low_peel_3.func_08019A1C, r0)) return;
    abi.fetches(4);
    if (!abi.call(proc.func_08019608, r1)) return;
    abi.fetches(4);
    if (!abi.call(next_fn, r2)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Set battle flag `[0x0802D748] = u8(r1)`, open overlay `0x08019608`, and trigger `0x0802E650` (`0x0802D730`).
pub fn func_0802D730() callconv(.c) void {
    if (!abi.enter(0x0802D730)) return;
    writeArg1Byte19608AndThen(0x0802D748, 0x0802D73F, low_peel_4.func_0802E650, 0x0802D743);
}

/// Set battle flag `[0x0802D764] = u8(r1)`, open overlay `0x08019608`, and trigger `0x0802E650` (`0x0802D74C`).
pub fn func_0802D74C() callconv(.c) void {
    if (!abi.enter(0x0802D74C)) return;
    writeArg1Byte19608AndThen(0x0802D764, 0x0802D75B, low_peel_4.func_0802E650, 0x0802D75F);
}

/// Dispatch battle menu entry `[0x0802D960][read8([0x0802D964]+2) - 0x82]` via `0x08018400` (`0x0802D944`).
pub fn func_0802D944() callconv(.c) void {
    if (!abi.enter(0x0802D944)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(proc.func_08019608, 0x0802D94B)) return;
    abi.fetches(11);
    const idx = abi.read8(abi.read32(0x0802D964) +% 2) -% 0x82;
    rt.r[1] = abi.read32(0x0802D960);
    rt.r[0] = abi.read32((idx << 2) +% rt.r[1]);
    if (!abi.call(low_peel_6.func_08018400, 0x0802D95D)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Close battle submenu (`0x08019A1C`, `0x08019608`) and run `0x0802E668` (`0x0802DEBC`).
pub fn func_0802DEBC() callconv(.c) void {
    if (!abi.enter(0x0802DEBC)) return;
    runBattleAction19A1C(low_peel_7.func_0802E668, 0x0802DEC3, 0x0802DEC7, 0x0802DECB);
}

/// Close battle submenu (`0x08019A1C`, `0x08019608`) and run `0x0802E6BC` (`0x0802DED0`).
pub fn func_0802DED0() callconv(.c) void {
    if (!abi.enter(0x0802DED0)) return;
    runBattleAction19A1C(low_peel_7.func_0802E6BC, 0x0802DED7, 0x0802DEDB, 0x0802DEDF);
}

/// Set battle flag `[0x0802E008] = u8(r1)`, open overlay `0x08019608`, and trigger `0x0802C530` (`0x0802DFF0`).
pub fn func_0802DFF0() callconv(.c) void {
    if (!abi.enter(0x0802DFF0)) return;
    writeArg1Byte19608AndThen(0x0802E008, 0x0802DFFF, unit.func_0802C530, 0x0802E003);
}

/// Set battle flag `[0x0802E028] = u8(r1)`, open overlay `0x08019608`, and apply `0x08018D84(read8([0x0802E02C]), 0x10)` (`0x0802E00C`).
pub fn func_0802E00C() callconv(.c) void {
    if (!abi.enter(0x0802E00C)) return;
    abi.fetches(9);
    abi.pushLr();
    const val = rt.r[1] & 0xFF;
    rt.updateNz(val);
    rt.r[1] = val;
    rt.r[0] = abi.read32(0x0802E028);
    abi.write32(rt.r[0], val);
    if (!abi.call(proc.func_08019608, 0x0802E01B)) return;
    abi.fetches(7);
    rt.r[0] = abi.read8(abi.read32(0x0802E02C));
    abi.setRegNz(&rt.r[1], 0x10);
    if (!abi.call(low_peel_6.func_08018D84, 0x0802E025)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Set battle flag `[0x0802E048] = u8(r1)`, open overlay `0x08019608`, and trigger `0x0802C5A0` (`0x0802E030`).
pub fn func_0802E030() callconv(.c) void {
    if (!abi.enter(0x0802E030)) return;
    writeArg1Byte19608AndThen(0x0802E048, 0x0802E03F, unit.func_0802C5A0, 0x0802E043);
}

/// Close menu `0x08019608`, query unit state `0x08015E3C`, and invoke `0x08015EF8` (`0x0802E128`).
pub fn func_0802E128() callconv(.c) void {
    if (!abi.enter(0x0802E128)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(proc.func_08019608, 0x0802E12F)) return;
    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x0802E144) +% 1);
    if (!abi.call(low_peel_6.func_08015E3C, 0x0802E137)) return;
    abi.fetches(7);
    const val: u16 = @bitCast(@as(i16, @as(i8, @bitCast(@as(u8, @truncate(rt.r[0]))))));
    abi.setRegNz(&rt.r[0], val);
    if (!abi.call(low_peel_6.func_08015EF8, 0x0802E141)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Reset battle window `0x08026724` and open overlay `0x08019608` (`0x0802E2A4`).
pub fn func_0802E2A4() callconv(.c) void {
    if (!abi.enter(0x0802E2A4)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(unit.func_08026724, 0x0802E2AB)) return;
    abi.fetches(4);
    if (!abi.call(proc.func_08019608, 0x0802E2AF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Mark `[0x0802E308] = 1`, dispatch `0x08029BEC(1)`, `0x08019608`, and `0x08035220` (`0x0802E2EC`).
pub fn func_0802E2EC() callconv(.c) void {
    if (!abi.enter(0x0802E2EC)) return;
    abi.fetches(9);
    abi.pushLr();
    const dst = abi.read32(0x0802E308);
    abi.write8(dst, 1);
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], 1);
    if (!abi.call(unit.func_08029BEC, 0x0802E2FB)) return;
    abi.fetches(4);
    if (!abi.call(proc.func_08019608, 0x0802E2FF)) return;
    abi.fetches(4);
    if (!abi.call(state_mod.func_08035220, 0x0802E303)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn popReturnR1Battle() void {
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Update tactical HUD (`0x08020D6C`, `0x080381C4`) and reset overlay cursor via `0x08021DF8` (`0x0802E710`).
pub fn func_0802E710() callconv(.c) void {
    if (!abi.enter(0x0802E710)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(map.func_08020D6C, 0x0802E717)) return;
    abi.fetches(4);
    if (!abi.call(campaign.func_080381C4, 0x0802E71B)) return;
    abi.fetches(4);
    if (!abi.call(unit.func_08021DF8, 0x0802E71F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Prepare battle submenu slot `u16(r0)` (`0x0802E984`) and commit `i16(r0)` (`0x0802EA80`) (`0x0802ECC0`).
pub fn func_0802ECC0() callconv(.c) void {
    if (!abi.enter(0x0802ECC0)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const slot_u16 = rt.r[0] & 0xFFFF;
    rt.updateNz(slot_u16);
    rt.r[4] = slot_u16;
    if (!abi.call(low_peel_7.func_0802E984, 0x0802ECCD)) return;
    abi.fetches(7);
    const slot_i32: u32 = @bitCast(abi.signExtend16(@truncate(slot_u16)));
    rt.r[4] = slot_i32;
    abi.setRegNz(&rt.r[0], slot_i32);
    if (!abi.call(low_peel_15.func_0802EA80, 0x0802ECD7)) return;
    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Commit display/window registers via `0x080104B0` then `0x080104D4` (`0x0802EFD8`).
pub fn func_0802EFD8() callconv(.c) void {
    if (!abi.enter(0x0802EFD8)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(hw.func_080104B0, 0x0802EFDF)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_3.func_080104D4, 0x0802EFE3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Play cancel cue `0x76` and close submenu via `0x0802C694` (`0x0802F5C4`).
pub fn func_0802F5C4() callconv(.c) void {
    if (!abi.enter(0x0802F5C4)) return;
    abi.fetches(6);
    abi.pushLr();
    if (!sound.playSfxCall(0x76, 0x0802F5CD)) return;
    abi.fetches(4);
    if (!abi.call(ui.func_0802C694, 0x0802F5D1)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Select map cursor from pair `[0x0802FA64]` via `0x08020538`, set `[0x0802FA68] = 1`, notify `0x08026060`, zero `[0x0802FA6C]` (`0x0802FA40`).
pub fn func_0802FA40() callconv(.c) void {
    if (!abi.enter(0x0802FA40)) return;
    abi.fetches(10);
    abi.pushLr();
    const pair = abi.read32(0x0802FA64);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(pair)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(pair +% 2)));
    rt.r[2] = 2;
    if (!abi.call(map.func_08020538, 0x0802FA51)) return;

    abi.fetches(7);
    abi.write8(abi.read32(0x0802FA68), 1);
    if (!abi.call(low_peel_7.func_08026060, 0x0802FA5B)) return;

    abi.fetches(7);
    rt.r[1] = abi.read32(0x0802FA6C);
    abi.setRegNz(&rt.r[0], 0);
    abi.write16(rt.r[1], 0);
    abi.popReturn();
}

/// Copy battle icon tiles (`u16 r1` entry in `[0x0802FCB0]`) via `0x0800FDA4` and return `width * height` (`0x0802FC70`).
pub fn func_0802FC70() callconv(.c) void {
    if (!abi.enter(0x0802FC70)) return;
    abi.fetches(26);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const dst_tile = rt.r[0] & 0xFFFF;
    const entry = ((rt.r[1] & 0xFFFF) << 3) +% abi.read32(0x0802FCB0);
    const w = abi.read8(entry +% 2);
    const h = abi.read8(entry +% 3);
    const area: u32 = @as(u32, h) *% @as(u32, w);
    const dst_vram = (dst_tile << 5) +% abi.read32(0x0802FCB8);
    rt.r[0] = (@as(u32, abi.read16(entry)) << 5) +% abi.read32(0x0802FCB4);
    rt.r[1] = dst_vram;
    rt.r[2] = (area << 21) >> 16;
    rt.r[3] = dst_vram;
    rt.r[4] = entry;
    rt.r[5] = h;
    rt.updateNz(rt.r[2]);
    if (!dma.copyAutoAbiCall(0x0802FCA1)) return;

    abi.fetches(9);
    const w2 = abi.read8(entry +% 2);
    const h2 = abi.read8(entry +% 3);
    const res: u32 = @as(u32, w2) *% @as(u32, h2);
    rt.r[2] = w2;
    rt.r[5] = h2;
    abi.setRegNz(&rt.r[0], res);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnR1Battle();
}

/// Reset battle animation header `*[0x08030624]` (`0x080305E4`).
pub fn func_080305E4() callconv(.c) void {
    if (!abi.enter(0x080305E4)) return;
    abi.fetches(38);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const ptr_slot = abi.read32(0x08030624);
    const s = abi.read32(ptr_slot);
    _ = abi.read16(s);
    abi.write16(s, 0);
    _ = abi.read16(s +% 2);
    abi.write16(s +% 2, 0);
    _ = abi.read8(s +% 4);
    abi.write8(s +% 4, 1);

    const s2 = abi.read32(ptr_slot);
    _ = abi.read8(s2 +% 5);
    abi.write8(s2 +% 5, 0);

    const s3 = abi.read32(ptr_slot);
    _ = abi.read16(s3 +% 6);
    abi.write16(s3 +% 6, @truncate(abi.read32(0x08030628)));

    const off_210 = s3 +% (0x84 << 2);
    _ = abi.read16(off_210);
    abi.write16(off_210, @truncate(abi.read32(0x0803062C)));

    const tail = s3 +% abi.read32(0x08030630);
    _ = abi.read16(tail);
    abi.write16(tail, 0);

    rt.r[0] = tail;
    rt.r[1] = 0;
    rt.r[2] = off_210;
    rt.r[3] = 0;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Copy 8-byte sound cue table `[0x08030DF4]` onto stack and play halfword entry `u8(r0)` via `0x0803D880` (`0x08030DC8`).
pub fn func_08030DC8() callconv(.c) void {
    if (!abi.enter(0x08030DC8)) return;
    abi.fetches(12);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const idx = rt.r[0] & 0xFF;
    rt.r[4] = idx;
    rt.r[0] = rt.r[13];
    rt.r[1] = abi.read32(0x08030DF4);
    abi.setRegNz(&rt.r[2], 8);
    if (!abi.call(low_peel_5.func_0807A8A0, 0x08030DDD)) return;

    abi.fetches(9);
    rt.r[4] = idx << 1;
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(rt.r[13] +% (idx << 1))));
    rt.r[1] = 0;
    if (!abi.call(sound.func_0803D880, 0x08030DEB)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Apply action preview `0x080243DC`, clear map unit bytes `+9/+0xA`, copy `b6 -> +0xB`, and set mode `6` (`0x08066AE8`).
pub fn func_08066AE8() callconv(.c) void {
    if (!abi.enter(0x08066AE8)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const state_ptr = abi.read32(0x08066B34);
    rt.r[4] = state_ptr;
    rt.r[0] = abi.read8(state_ptr +% 2);
    rt.r[1] = abi.read8(state_ptr +% 3);
    rt.r[2] = abi.read8(state_ptr +% 1);
    if (!abi.call(low_peel_11.func_080243DC, 0x08066AF7)) return;

    abi.fetches(32);
    const map_base = abi.read32(abi.read32(0x08066B3C));
    const y = abi.read8(state_ptr +% 3);
    const x = abi.read8(state_ptr +% 2);
    const row_ptr = map_base +% abi.read32(0x08066B40) +% (@as(u32, y) << 1);
    const col_off = abi.read16(row_ptr) +% x;
    const unit_idx = abi.read8(map_base +% 0x12 +% col_off);
    const unit_ptr = abi.read32(abi.read32(0x08066B38)) +% (@as(u32, unit_idx) *% 12);
    abi.write8(unit_ptr +% 9, 0);
    abi.write8(unit_ptr +% 0xA, 0);
    abi.write8(unit_ptr +% 0xB, abi.read8(state_ptr +% 6));
    abi.write16(abi.read32(0x08066B44), 6);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Update unit status `[0x08066CC8]+6` via `0x0802615C` and clear script flag `0x08013BD0` (`0x08066CB0`).
pub fn func_08066CB0() callconv(.c) void {
    if (!abi.enter(0x08066CB0)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read8(abi.read32(0x08066CC8) +% 6);
    if (!abi.call(ui.func_0802615C, 0x08066CBB)) return;

    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x08066CCC));
    if (!proc.clearProcSlotCall(0x08066CC3)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Refresh tactical board `0x08020D6C` and spawn combat proc `[0x08066CE4]` (`0x08066CD0`).
pub fn func_08066CD0() callconv(.c) void {
    if (!abi.enter(0x08066CD0)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(map.func_08020D6C, 0x08066CD7)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x08066CE4);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(low_peel_3.func_080131E0, 0x08066CDF)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Run battle scene step `0x080685D0` then post-step `0x08061DA0` (`0x08068A54`).
pub fn func_08068A54() callconv(.c) void {
    if (!abi.enter(0x08068A54)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(low_peel_17.func_080685D0, 0x08068A5B)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_5.func_08061DA0, 0x08068A5F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Prepare battle unit slot `u8(r0)` via `0x0806959C` and `0x080691FC` (`0x08069730`).
pub fn func_08069730() callconv(.c) void {
    if (!abi.enter(0x08069730)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const slot_id = rt.r[0] & 0xFF;
    rt.r[4] = slot_id;
    rt.updateNz(slot_id);
    rt.r[0] = slot_id;
    if (!abi.call(low_peel_17.func_0806959C, 0x0806973D)) return;

    abi.fetches(5);
    abi.copyRegFlags(&rt.r[0], slot_id);
    if (!abi.call(low_peel_18.func_080691FC, 0x08069743)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// DMA battle UI tiles `[0x0806A2F4]`, upload palette `[0x0806A2FC]`, and init `0x0806CB34(0xA)` (`0x0806A2D0`).
pub fn func_0806A2D0() callconv(.c) void {
    if (!abi.enter(0x0806A2D0)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0806A2F4);
    rt.r[1] = abi.read32(0x0806A2F8);
    abi.setRegNz(&rt.r[2], @as(u32, 0xFC) << 5);
    if (!dma.enqueueOrCopyAbiCall(0x0806A2DF)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x0806A2FC);
    abi.setRegNz(&rt.r[1], @as(u32, 0x80) << 2);
    abi.setRegNz(&rt.r[2], 0x40);
    if (!dma.copyPaletteCall(0x0806A2EB)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0xA);
    if (!abi.call(hw.func_0806CB34, 0x0806A2F1)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Configure cursor overlay box via `0x08010C70`, finish `0x0806A7EC`, and clear flag `[0x0806A7E8]` (`0x0806A798`).
pub fn func_0806A798() callconv(.c) void {
    if (!abi.enter(0x0806A798)) return;
    abi.fetches(27);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const proc_ptr = rt.r[0];
    rt.r[4] = proc_ptr;
    abi.write16(proc_ptr +% 0x42, abi.read16(proc_ptr +% 0x46) << 1);
    abi.write16(proc_ptr +% 0x44, 0);

    abi.write32(rt.r[13], 2);
    abi.write32(rt.r[13] +% 4, abi.read32(0x0806A7E4));
    rt.r[0] = abi.read32(0x0806A7E0);
    abi.setRegNz(&rt.r[1], 0xC);
    rt.r[2] = (abi.read32(proc_ptr +% 0x28) << 13) >> 16;
    abi.setRegNz(&rt.r[3], 0x14);
    if (!hw.fillTileRectCall(0x0806A7CB)) return;

    abi.fetches(5);
    abi.copyRegFlags(&rt.r[0], proc_ptr);
    if (!abi.call(low_peel_13.func_0806A7EC, 0x0806A7D1)) return;

    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x0806A7E8));
    if (!proc.clearProcSlotCall(0x0806A7D9)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Draw battle cursor box via `0x080498C4` and clear script flag `[0x0806A8B0]` (`0x0806A890`).
pub fn func_0806A890() callconv(.c) void {
    if (!abi.enter(0x0806A890)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const base_tile = abi.read16(rt.r[0] +% 0x2C);
    rt.r[4] = base_tile;
    rt.r[1] = abi.read16(rt.r[0] +% 0x24);
    rt.r[2] = abi.read16(rt.r[0] +% 0x28);
    abi.setRegNz(&rt.r[3], @as(u32, 0x80) << 2);
    abi.copyRegFlags(&rt.r[0], base_tile);
    if (!abi.call(low_peel_12.func_080498C4, 0x0806A8A3)) return;

    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x0806A8B0));
    if (!proc.clearProcSlotCall(0x0806A8AB)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down battle panel (`0x0806A324`, `0x0806A300`), set `+0x44 = 8`, and run `0x0806B2EC` (`0x0806AC9C`).
pub fn func_0806AC9C() callconv(.c) void {
    if (!abi.enter(0x0806AC9C)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const proc_ptr = rt.r[0];
    rt.r[4] = proc_ptr;
    if (!abi.call(low_peel_9.func_0806A324, 0x0806ACA5)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_5.func_0806A300, 0x0806ACA9)) return;

    abi.fetches(7);
    abi.write16(proc_ptr +% 0x44, 8);
    rt.r[4] = proc_ptr +% 0x44;
    abi.setRegNz(&rt.r[0], 8);
    if (!abi.call(low_peel_13.func_0806B2EC, 0x0806ACB3)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear `[0x0806AEAC]` and `r0+0x44`, then call `0x0806AEB0` and `0x0806B40C` (`0x0806AE90`).
pub fn func_0806AE90() callconv(.c) void {
    if (!abi.enter(0x0806AE90)) return;
    abi.fetches(11);
    abi.pushLr();
    abi.write8(abi.read32(0x0806AEAC), 0);
    abi.write16(rt.r[0] +% 0x44, 0);
    if (!abi.call(low_peel_17.func_0806AEB0, 0x0806AEA3)) return;
    abi.fetches(4);
    if (!abi.call(func_0806B40C, 0x0806AEA7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear flag `[0x0806B138]`, set `r0+0x44 = 8`, and advance panel via `0x0806B13C` (`0x0806B118`).
pub fn func_0806B118() callconv(.c) void {
    if (!abi.enter(0x0806B118)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const proc_ptr = rt.r[0];
    rt.r[4] = proc_ptr;
    rt.r[0] = abi.read8(abi.read32(0x0806B138));
    if (!proc.clearProcSlotCall(0x0806B125)) return;

    abi.fetches(9);
    abi.write16(proc_ptr +% 0x44, 8);
    abi.copyRegFlags(&rt.r[0], proc_ptr);
    if (!abi.call(low_peel_13.func_0806B13C, 0x0806B133)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn enterBattleSubmenu(
    comptime flag_ref: u32,
    comptime tail_proc_ref: u32,
    comptime tail_fn: ?fn () callconv(.c) void,
    comptime r1: u32,
    comptime r2: u32,
    comptime r3: u32,
    comptime r4: u32,
) void {
    abi.fetches(9);
    abi.pushLr();
    const val = rt.r[1] & 0xFF;
    rt.updateNz(val);
    abi.write32(abi.read32(flag_ref), val);
    if (!abi.call(low_peel_3.func_08019A1C, r1)) return;
    abi.fetches(4);
    if (!abi.call(proc.func_08019608, r2)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_1.func_080351E8, r3)) return;
    if (tail_fn) |fn_ptr| {
        abi.fetches(4);
        if (!abi.call(fn_ptr, r4)) return;
    } else {
        abi.fetches(6);
        rt.r[0] = abi.read32(tail_proc_ref);
        abi.setRegNz(&rt.r[1], 0);
        if (!abi.call(low_peel_6.func_0801320C, r4)) return;
    }
    abi.fetches(4);
    abi.popReturn();
}

/// Render battle preview rows/badges via `0x0802C11C` x2 and `0x0801B888` x2, then set `[0x0802C030] = 1` (`0x0802BFB0`).
pub fn func_0802BFB0() callconv(.c) void {
    if (!abi.enter(0x0802BFB0)) return;
    abi.fetches(20);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const base_x_i32 = abi.signExtend16(@truncate(rt.r[0]));
    const unit_idx = abi.read16(abi.read32(0x0802C018));
    const tbl = abi.read32(abi.read32(0x0802C01C));
    const unit_ptr = (unit_idx *% 0x68) +% tbl;
    rt.r[4] = @bitCast(base_x_i32);
    rt.r[0] = (@as(u32, @bitCast(base_x_i32)) +% 0x46) & 0xFFFF;
    abi.setRegNz(&rt.r[1], 5);
    rt.r[2] = abi.read32(unit_ptr);
    if (!abi.call(low_peel_7.func_0802C11C, 0x0802BFD5)) return;

    abi.fetches(11);
    rt.r[0] = (@as(u32, @bitCast(base_x_i32)) +% 0xE) & 0xFFFF;
    abi.setRegNz(&rt.r[1], 5);
    rt.r[2] = abi.read16(abi.read32(0x0802C020));
    if (!abi.call(low_peel_7.func_0802C11C, 0x0802BFE7)) return;

    abi.fetches(12);
    const aux_pal = abi.read32(0x0802C024);
    rt.r[5] = aux_pal;
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(@as(u32, @bitCast(base_x_i32)) +% 0x16)));
    abi.setRegNz(&rt.r[1], 5);
    rt.r[2] = aux_pal;
    rt.r[3] = abi.read32(0x0802C028);
    if (!hw.drawDispatchCall(0x0802BFFB)) return;

    abi.fetches(11);
    rt.r[4] = @bitCast(abi.signExtend16(@truncate(@as(u32, @bitCast(base_x_i32)) +% 0x4E)));
    abi.copyRegFlags(&rt.r[0], rt.r[4]);
    abi.setRegNz(&rt.r[1], 6);
    rt.r[2] = aux_pal;
    rt.r[3] = abi.read32(0x0802C02C);
    if (!hw.drawDispatchCall(0x0802C00D)) return;

    abi.fetches(8);
    abi.write16(abi.read32(0x0802C030), 1);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Set `[0x0802DF04] = u8(r1)`, reset UI, and enter `0x08040AEC` (`0x0802DEE4`).
pub fn func_0802DEE4() callconv(.c) void {
    if (!abi.enter(0x0802DEE4)) return;
    enterBattleSubmenu(0x0802DF04, 0, ui.func_08040AEC, 0x0802DEF3, 0x0802DEF7, 0x0802DEFB, 0x0802DEFF);
}

/// Set `[0x0802DF28] = u8(r1)`, reset UI, and enter `0x08041F20` (`0x0802DF08`).
pub fn func_0802DF08() callconv(.c) void {
    if (!abi.enter(0x0802DF08)) return;
    enterBattleSubmenu(0x0802DF28, 0, low_peel_4.func_08041F20, 0x0802DF17, 0x0802DF1B, 0x0802DF1F, 0x0802DF23);
}

/// Set `[0x0802DF50] = u8(r1)`, reset UI, and spawn `[0x0802DF54]` (`0x0802DF2C`).
pub fn func_0802DF2C() callconv(.c) void {
    if (!abi.enter(0x0802DF2C)) return;
    enterBattleSubmenu(0x0802DF50, 0x0802DF54, null, 0x0802DF3B, 0x0802DF3F, 0x0802DF43, 0x0802DF4B);
}

/// Focus target (`0x0801D048`, `0x0801E5F8`), spawn `[0x0802E438]`, reset HUD, set map mode `0x08022074`, release lock (`0x0802E3FC`).
pub fn func_0802E3FC() callconv(.c) void {
    if (!abi.enter(0x0802E3FC)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0xFF);
    if (!abi.call(map.func_0801D048, 0x0802E405)) return;

    abi.fetches(11);
    const cur = abi.read32(0x0802E430);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(cur)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(cur +% 2)));
    rt.r[2] = abi.read32(abi.read32(0x0802E434));
    if (!abi.call(low_peel_10.func_0801E5F8, 0x0802E417)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x0802E438);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(low_peel_3.func_080131E0, 0x0802E41F)) return;

    abi.fetches(4);
    if (!abi.call(proc.func_08019608, 0x0802E423)) return;
    abi.fetches(4);
    if (!abi.call(map.func_08022074, 0x0802E427)) return;
    abi.fetches(4);
    if (!abi.call(state_mod.func_08035220, 0x0802E42B)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Draw battle window `0x080197D8(..., 0xE, 0xD, 6)`, focus `[0x0802E550]`, and open overlay `0x08012340` (`0x0802E508`).
pub fn func_0802E508() callconv(.c) void {
    if (!abi.enter(0x0802E508)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const a0 = rt.r[0];
    rt.r[5] = a0;
    if (!abi.call(low_peel_4.func_0802E4E8, 0x0802E513)) return;

    abi.fetches(10);
    const val = abi.signExtend16(@truncate(rt.r[0]));
    rt.r[4] = @bitCast(val);
    rt.r[0] = @bitCast(val);
    abi.setRegNz(&rt.r[1], 0xE);
    abi.setRegNz(&rt.r[2], 0xD);
    abi.setRegNz(&rt.r[3], 6);
    if (!abi.call(low_peel_10.func_080197D8, 0x0802E523)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x0802E550);
    if (!proc.killProcByCallbackCall(0x0802E529)) return;

    abi.fetches(17);
    const row_y: u32 = @bitCast(abi.signExtend16(@truncate(@as(u32, @bitCast(val +% 1)))));
    rt.r[4] = row_y;
    abi.write32(rt.r[13], 0x4000);
    abi.write32(rt.r[13] +% 4, 0x100);
    rt.r[0] = row_y;
    abi.setRegNz(&rt.r[1], 0xF);
    rt.r[2] = abi.read32(0x0802E554);
    rt.r[3] = a0;
    if (!abi.call(sprite_anim.func_08012340, 0x0802E547)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear battle window BG boxes (`0xE x 0xD`) via `0x08010C70` x2 and commit BG layers (`0x0802E558`).
pub fn func_0802E558() callconv(.c) void {
    if (!abi.enter(0x0802E558)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;
    if (!abi.call(low_peel_4.func_0802E4E8, 0x0802E561)) return;

    abi.fetches(6);
    const row_y = rt.r[0] & 0xFFFF;
    rt.r[4] = row_y;
    rt.r[0] = abi.read32(0x0802E5A4);
    if (!proc.killProcByCallbackCall(0x0802E569)) return;

    abi.fetches(15);
    rt.r[5] = 6;
    abi.write32(rt.r[13], 6);
    abi.write32(rt.r[13] +% 4, 0x174);
    rt.r[0] = abi.read32(0x0802E5A8);
    rt.r[1] = row_y;
    abi.setRegNz(&rt.r[2], 0xE);
    abi.setRegNz(&rt.r[3], 0xD);
    if (!hw.fillTileRectCall(0x0802E583)) return;

    abi.fetches(11);
    abi.write32(rt.r[13], 6);
    abi.write32(rt.r[13] +% 4, abi.read32(0x0802E5B0));
    rt.r[0] = abi.read32(0x0802E5AC);
    rt.r[1] = row_y;
    abi.setRegNz(&rt.r[2], 0xE);
    abi.setRegNz(&rt.r[3], 0xD);
    if (!hw.fillTileRectCall(0x0802E595)) return;

    abi.fetches(4);
    if (!hw.markDisplayDirtyCall(0x0802E599)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_1.func_08011824, 0x0802E59D)) return;

    abi.fetches(6);
    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Complete battle confirmation (`0x08026FC8(1)`, `0x08021E1C`, `0x08012830(0)`, `0x08035230`) (`0x0802EEFC`).
pub fn func_0802EEFC() callconv(.c) void {
    if (!abi.enter(0x0802EEFC)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 1);
    if (!abi.call(low_peel_7.func_08026FC8, 0x0802EF05)) return;
    abi.fetches(4);
    if (!abi.call(map.func_08021E1C, 0x0802EF09)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(low_peel_1.func_08012830, 0x0802EF0F)) return;
    abi.fetches(4);
    if (!abi.call(turn.func_08035230, 0x0802EF13)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Finalize combat/supply cleanup (`0x080212B8`, `0x08021010`, `0x08021398`, `0x0802EF2C`) (`0x0802F5D4`).
pub fn func_0802F5D4() callconv(.c) void {
    if (!abi.enter(0x0802F5D4)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(low_peel_3.func_080212B8, 0x0802F5DB)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_10.func_08021010, 0x0802F5DF)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_14.func_08021398, 0x0802F5E3)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_4.func_0802EF2C, 0x0802F5E7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Tear down battle display layers/VRAM/palettes, reset IRQ/DMA masks, and set battle end flags (`0x0802FD30`).
pub fn func_0802FD30() callconv(.c) void {
    if (!abi.enter(0x0802FD30)) return;
    abi.fetches(22);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const disp = abi.read32(0x0802FDAC);
    const b1_init = ((abi.read8(disp +% 1) | 1) & @as(u8, @truncate(((((0 -% @as(u32, 3)) -% 2) -% 4) -% 8))));
    abi.write8(disp +% 1, b1_init);
    rt.r[0] = abi.read32(0x0802FDB0);
    abi.setRegNz(&rt.r[1], @as(u32, 0xC0) << 19);
    if (!dma.copyVramCheckedCall(0x0802FD59)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x0802FDB4);
    rt.r[1] = abi.read32(0x0802FDB8);
    if (!dma.copyVramCheckedCall(0x0802FD61)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x0802FDBC);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!dma.copyPaletteCall(0x0802FD6B)) return;

    abi.fetches(15);
    abi.write16(abi.read32(0x0802FDC0), 0);
    abi.write16(abi.read32(0x0802FDC4), 0);
    const p2 = abi.read32(0x0802FDC8);
    abi.write16(p2, 0);
    abi.write16(p2 -% 0xC, 0);
    rt.r[4] = 0;
    abi.setRegNz(&rt.r[0], 7);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(hw.func_0807AE50, 0x0802FD85)) return;

    abi.fetches(6);
    abi.setRegNz(&rt.r[0], 6);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(hw.func_0807AE50, 0x0802FD8D)) return;

    abi.fetches(7);
    abi.setRegNz(&rt.r[0], 1);
    rt.r[1] = 0 -% @as(u32, 0xC1);
    if (!abi.call(low_peel_9.func_0807AE60, 0x0802FD97)) return;

    abi.fetches(13);
    abi.write8(abi.read32(abi.read32(0x0802FDCC)) +% 6, 0xFF);
    abi.write8(abi.read32(0x0802FDD0) +% 0x32, 0);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Initialize tactical range/cursor preview overlays and clear offset registers (`0x0802EC3C`).
pub fn func_0802EC3C() callconv(.c) void {
    if (!abi.enter(0x0802EC3C)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(unit.func_08021DF8, 0x0802EC43)) return;
    abi.fetches(4);
    if (!abi.call(map.func_08021E04, 0x0802EC47)) return;

    abi.fetches(25);
    const p1 = abi.read32(0x0802ECAC);
    abi.write16(p1, 0);
    abi.write16(abi.read32(0x0802ECA8), abi.read16(p1));
    const slot_idx: u32 = @bitCast(abi.signExtend16(abi.read16(abi.read32(0x0802ECB0))));
    const slot_ptr = (slot_idx *% 3 << 5) +% abi.read32(0x0802ECB4);
    abi.write16(slot_ptr +% 0x1E, 0);
    abi.write16(slot_ptr +% 0x20, 0);
    const limit = abi.read16(abi.read32(0x0802ECB8)) -% 1;
    abi.write16(slot_ptr +% 0x22, limit);
    if (!abi.call(low_peel_11.func_0802E9C8, 0x0802EC75)) return;

    abi.fetches(8);
    rt.r[0] = 1;
    rt.r[1] = 4;
    rt.r[2] = 0xF;
    rt.r[3] = 0x10;
    if (!abi.call(low_peel_10.func_080197D8, 0x0802EC81)) return;

    abi.fetches(5);
    rt.r[0] = 0;
    if (!abi.call(low_peel_15.func_0802EA80, 0x0802EC87)) return;

    abi.fetches(6);
    rt.r[0] = 8;
    rt.r[1] = 0x28;
    if (!abi.call(map.func_0802055C, 0x0802EC8F)) return;

    abi.fetches(5);
    rt.r[0] = 0x65;
    if (!abi.call(sound.func_0803D880, 0x0802EC95)) return;

    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x0802ECBC));
    if (!abi.call(campaign.func_0803CC90, 0x0802EC9D)) return;

    abi.fetches(5);
    rt.r[0] = 1;
    if (!abi.call(low_peel_7.func_08026FC8, 0x0802ECA3)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch tactical forecast / HP / terrain card draws for current active battle slot (`0x080539B4`).
pub fn func_080539B4() callconv(.c) void {
    if (!abi.enter(0x080539B4)) return;
    abi.fetches(21);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const tbl = abi.read32(0x08053A00);
    rt.r[6] = abi.read32(0x08053A04);
    const slot: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[6])));
    const entry_off = slot *% 3 << 5;
    rt.r[5] = abi.read16(entry_off +% tbl +% 0x30);
    rt.r[4] = abi.read16(entry_off +% tbl +% 0x34);

    rt.r[0] = rt.r[5];
    rt.r[1] = rt.r[4];
    if (!abi.call(low_peel_16.func_08053A08, 0x080539DB)) return;

    abi.fetches(8);
    rt.r[0] = rt.r[5];
    rt.r[1] = rt.r[4];
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(rt.r[6])));
    if (!abi.call(low_peel_12.func_08052E2C, 0x080539E7)) return;

    abi.fetches(8);
    rt.r[0] = rt.r[5];
    rt.r[1] = rt.r[4];
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(rt.r[6])));
    if (!abi.call(ui.func_08054BA8, 0x080539F3)) return;

    abi.fetches(6);
    rt.r[0] = rt.r[5];
    rt.r[1] = rt.r[4];
    if (!abi.call(low_peel_5.func_0805DD00, 0x080539FB)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Tear down tactical sub-controllers and clear active OAM/sprite state (`0x08059E50`).
pub fn func_08059E50() callconv(.c) void {
    if (!abi.enter(0x08059E50)) return;
    abi.fetches(5);
    abi.pushLr();
    const steps = .{
        .{ sound.func_0803D920, @as(u32, 0x08059E57) },
        .{ low_peel_18.func_0805B5E0, @as(u32, 0x08059E5B) },
        .{ low_peel_8.func_0805B9CC, @as(u32, 0x08059E5F) },
        .{ low_peel_16.func_0805EA78, @as(u32, 0x08059E63) },
        .{ dma.func_0800F894, @as(u32, 0x08059E67) },
    };
    inline for (steps) |s| {
        if (!abi.call(s[0], s[1])) return;
        abi.fetches(4);
    }
    abi.popReturn();
}

/// Initialize both sides (0 and 1) of combat UI status/badge panels (`0x0805AEC8`).
pub fn func_0805AEC8() callconv(.c) void {
    if (!abi.enter(0x0805AEC8)) return;
    abi.fetches(6);
    abi.pushLr();
    const steps = .{
        .{ low_peel_8.func_0805B1A0, @as(u32, 0), @as(u32, 0x0805AED1) },
        .{ low_peel_8.func_0805B1A0, @as(u32, 1), @as(u32, 0x0805AED7) },
        .{ low_peel_8.func_0805B388, @as(u32, 0), @as(u32, 0x0805AEDD) },
        .{ low_peel_8.func_0805B388, @as(u32, 1), @as(u32, 0x0805AEE3) },
        .{ ui.func_0805A5B4, @as(u32, 0), @as(u32, 0x0805AEE9) },
        .{ ui.func_0805A5B4, @as(u32, 1), @as(u32, 0x0805AEEF) },
    };
    inline for (steps) |s| {
        rt.r[0] = s[1];
        if (!abi.call(s[0], s[2])) return;
        abi.fetches(5);
    }
    abi.fetches(4);
    abi.popReturn();
}

/// Prepare battle-result/replay summary screen transition and trigger mode `2` (`0x08066964`).
pub fn func_08066964() callconv(.c) void {
    if (!abi.enter(0x08066964)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[0] = abi.read32(abi.read32(0x08066990));
    if (!abi.call(low_peel_8.func_08036520, 0x0806696F)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_14.func_08023EDC, 0x08066973)) return;

    abi.fetches(7);
    rt.r[4] = abi.read32(0x08066998);
    rt.r[0] = abi.read32(0x08066994);
    rt.r[1] = rt.r[4];
    if (!abi.call(low_peel_7.func_0803487C, 0x0806697D)) return;

    abi.fetches(5);
    rt.r[0] = rt.r[4];
    if (!abi.call(low_peel_3.func_080241B0, 0x08066983)) return;

    abi.fetches(8);
    abi.write16(abi.read32(0x0806699C), 2);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Set up initial 3-layer tactical viewports (`(0,1)`, `(1,6)`, `(2,5)`) (`0x08068ABC`).
pub fn func_08068ABC() callconv(.c) void {
    if (!abi.enter(0x08068ABC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(low_peel_9.func_08068AE0, 0x08068AC3)) return;
    const layers = [_][3]u32{
        .{ 0, 1, 0x08068ACB },
        .{ 1, 6, 0x08068AD3 },
        .{ 2, 5, 0x08068ADB },
    };
    inline for (layers) |l| {
        abi.fetches(6);
        rt.r[0] = l[0];
        rt.r[1] = l[1];
        if (!abi.call(low_peel_17.func_08068B1C, l[2])) return;
    }
    abi.fetches(4);
    abi.popReturn();
}

/// Reset battle animation sub-state, palettes, and sound tracks (`0x0806A5DC`).
pub fn func_0806A5DC() callconv(.c) void {
    if (!abi.enter(0x0806A5DC)) return;
    abi.fetches(5);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    if (!abi.call(low_peel_2.func_08044644, 0x0806A5E3)) return;

    abi.fetches(8);
    abi.write16(abi.read32(0x0806A610) +% 2, @truncate(rt.r[0]));
    rt.r[0] = abi.read32(0x0806A614);
    rt.r[1] = 0;
    if (!abi.call(low_peel_9.func_0806A8F4, 0x0806A5EF)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x0806A618);
    if (!proc.killProcByCallbackCall(0x0806A5F5)) return;

    abi.fetches(6);
    rt.r[4] = abi.read32(0x0806A61C);
    rt.r[0] = rt.r[4];
    if (!proc.killProcByCallbackCall(0x0806A5FD)) return;

    abi.fetches(6);
    rt.r[0] = rt.r[4];
    rt.r[1] = 1;
    if (!proc.spawnProcCall(0x0806A605)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x0806A620);
    if (!proc.killProcByCallbackCall(0x0806A60B)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Transform 3D particle position `[r0+0x24..0x2C]` and spawn sprite via `0x0806CF50`/`0x0806A988` (`0x0806AB1C`).
pub fn func_0806AB1C() callconv(.c) void {
    if (!abi.enter(0x0806AB1C)) return;
    abi.fetches(50);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 0x10;

    rt.r[4] = rt.r[0];
    rt.r[5] = rt.r[13];
    rt.r[7] = rt.r[13] +% 4;
    const mat_slot: u32 = @bitCast(abi.signExtend16(abi.read16(abi.read32(0x0806ABA0))));
    const mat_off = (mat_slot *% 3) << 2;
    rt.r[13] -%= mat_off;
    const tmp_in = rt.r[13] +% 4 +% mat_off;
    abi.write32(tmp_in +% 0, abi.read32(rt.r[4] +% 0x24));
    abi.write32(tmp_in +% 4, abi.read32(rt.r[4] +% 0x28));
    abi.write32(tmp_in +% 8, abi.read32(rt.r[4] +% 0x2C));
    rt.r[0] = tmp_in;
    rt.r[1] = abi.read32(0x0806ABA4);
    rt.r[2] = rt.r[7];
    if (!abi.call(math.func_0806CF50, 0x0806AB7D)) return;

    abi.fetches(15);
    const sx: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x44)));
    const sy: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x46)));
    abi.write32(rt.r[13] +% 0, sy);
    rt.r[0] = abi.read32(rt.r[7] +% 0);
    rt.r[1] = abi.read32(rt.r[7] +% 4);
    rt.r[2] = abi.read32(rt.r[7] +% 8);
    rt.r[3] = sx;
    if (!abi.call(low_peel_17.func_0806A988, 0x0806AB97)) return;

    abi.fetches(7);
    rt.r[13] = rt.r[5] +% 0x10;
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

/// Draw left and right battle combatant unit/terrain panels (`0x0806B40C`).
pub fn func_0806B40C() callconv(.c) void {
    if (!abi.enter(0x0806B40C)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = abi.read32(0x0806B430);
    rt.r[0] = rt.r[4];
    if (!abi.call(low_peel_5.func_0806CB50, 0x0806B417)) return;
    abi.fetches(5);
    rt.r[0] = rt.r[4];
    if (!abi.call(low_peel_5.func_0806CBAC, 0x0806B41D)) return;

    abi.fetches(6);
    rt.r[4] = abi.read32(0x0806B434);
    rt.r[0] = rt.r[4];
    if (!abi.call(low_peel_5.func_0806CB50, 0x0806B425)) return;
    abi.fetches(5);
    rt.r[0] = rt.r[4];
    if (!abi.call(low_peel_5.func_0806CBAC, 0x0806B42B)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn primary combat animation particle proc at `(r0, r1)` and return proc ptr (`0x0806BDC4`).
pub fn func_0806BDC4() callconv(.c) void {
    if (!abi.enter(0x0806BDC4)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[5] = rt.r[0];
    rt.r[6] = rt.r[1];
    rt.r[0] = abi.read32(0x0806BE20);
    rt.r[1] = 2;
    if (!proc.spawnProcCall(0x0806BDD3)) return;

    abi.fetches(28);
    rt.r[4] = rt.r[0];
    rt.r[7] = rt.r[4] +% 0x46;
    abi.write16(rt.r[7], @truncate(rt.r[5]));
    abi.write16(rt.r[4] +% 0x42, @truncate(rt.r[6]));
    abi.write16(rt.r[4] +% 0x44, 0x42);
    const z_val: u32 = @bitCast(abi.signExtend16(abi.read16((rt.r[5] << 1) +% abi.read32(0x0806BE24))));
    abi.write32(rt.r[4] +% 0x2C, z_val << 8);
    abi.write16(rt.r[4] +% 0x1C, 0);
    rt.r[1] = abi.read16((rt.r[5] << 3) +% abi.read32(0x0806BE28) +% 4);
    rt.r[0] = rt.r[4];
    if (!abi.call(low_peel_9.func_0806BC1C, 0x0806BE07)) return;

    abi.fetches(7);
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(rt.r[7])));
    rt.r[0] = rt.r[4];
    if (!abi.call(low_peel_9.func_0806B840, 0x0806BE11)) return;

    abi.fetches(5);
    rt.r[0] = rt.r[4];
    if (!abi.call(ui.func_0806BADC, 0x0806BE17)) return;

    abi.fetches(6);
    rt.r[0] = rt.r[4];
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[7] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Spawn secondary combat projectile/effect animation proc at `(r0, r1)` (`0x0806BE94`).
pub fn func_0806BE94() callconv(.c) void {
    if (!abi.enter(0x0806BE94)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[5] = rt.r[0];
    rt.r[6] = rt.r[1];
    rt.r[0] = abi.read32(0x0806BF18);
    rt.r[1] = 2;
    if (!proc.spawnProcCall(0x0806BEA3)) return;

    abi.fetches(44);
    rt.r[4] = rt.r[0];
    rt.r[7] = rt.r[4] +% 0x46;
    abi.write16(rt.r[7], @truncate(rt.r[5]));
    abi.write16(rt.r[4] +% 0x42, @truncate(rt.r[6]));
    abi.write16(rt.r[4] +% 0x44, 0);
    const z_val: u32 = @bitCast(abi.signExtend16(abi.read16((rt.r[5] << 1) +% abi.read32(0x0806BF1C))));
    abi.write32(rt.r[4] +% 0x2C, z_val << 8);
    abi.write16(rt.r[4] +% 0x1C, 0);
    abi.write32(rt.r[4] +% 0x30, 0xF0 << 8);
    abi.write32(rt.r[4] +% 0x34, abi.read32(0x0806BF20));
    abi.write32(rt.r[4] +% 0x38, abi.read32(0x0806BF24));
    abi.write8(rt.r[4] +% 0x48, 0);

    const frame_base = @as(u32, abi.read16(abi.read32(0x0806BF2C) +% 2)) -% 0x60;
    const anim_idx = (frame_base *% 5) +% rt.r[5];
    rt.r[1] = abi.read16((anim_idx << 3) +% abi.read32(0x0806BF28) +% 4);
    rt.r[0] = rt.r[4];
    rt.r[2] = 1;
    if (!abi.call(low_peel_9.func_0806BC1C, 0x0806BEF7)) return;

    abi.fetches(12);
    const slot_s: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[7])));
    const is_nonzero: u32 = @bitCast(@as(i32, @bitCast((0 -% slot_s) | slot_s)) >> 31);
    rt.r[1] = is_nonzero & 4;
    rt.r[0] = rt.r[4];
    if (!abi.call(low_peel_9.func_0806B840, 0x0806BF0B)) return;

    abi.fetches(5);
    rt.r[0] = rt.r[4];
    if (!abi.call(ui.func_0806BADC, 0x0806BF11)) return;

    abi.fetches(5);
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

/// Queue dual half-frame sprites for combatant effect `r0` via `0x0801B888` (`0x0806C378`).
pub fn func_0806C378() callconv(.c) void {
    if (!abi.enter(0x0806C378)) return;
    abi.fetches(23);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[6] = abi.read32(0x0806C3C8);
    rt.r[5] = rt.r[4] +% 0x48;
    const phase0: u32 = abi.read8(rt.r[5]);
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(abi.read32(rt.r[4] +% 0x24) +% 4)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x28)));
    rt.r[2] = rt.r[6];
    rt.r[3] = ((phase0 << 4) +% abi.read32(0x0806C3CC)) & 0xFFFF;
    if (!hw.drawDispatchCall(0x0806C3A3)) return;

    abi.fetches(18);
    const phase1: u32 = abi.read8(rt.r[5]);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x24)));
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(abi.read32(rt.r[4] +% 0x28) +% 0x10)));
    rt.r[2] = rt.r[6];
    rt.r[3] = ((phase1 << 4) +% abi.read32(0x0806C3D0)) & 0xFFFF;
    if (!hw.drawDispatchCall(0x0806C3C3)) return;

    abi.fetches(5);
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

/// Spawn damage/FX burst proc at `(r0, r1)` with slot index `r2` and mode `r3` (`0x0806C3D4`).
pub fn func_0806C3D4() callconv(.c) void {
    if (!abi.enter(0x0806C3D4)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[8]);

    rt.r[4] = rt.r[0];
    rt.r[6] = rt.r[1];
    rt.r[5] = rt.r[2];
    rt.r[8] = rt.r[3];
    rt.r[0] = abi.read32(0x0806C428);
    rt.r[1] = 0;
    if (!proc.spawnProcCall(0x0806C3EB)) return;

    abi.fetches(18);
    abi.write32(rt.r[0] +% 0x24, rt.r[4]);
    abi.write32(rt.r[0] +% 0x28, rt.r[6]);
    abi.write16(rt.r[0] +% 0x1C, @truncate(rt.r[5]));
    abi.write16(rt.r[0] +% 0x42, @truncate(rt.r[8]));
    rt.r[4] = abi.read32(0x0806C42C);
    const cnt0 = abi.read16(rt.r[4]);
    abi.write8(rt.r[0] +% 0x48, @truncate(cnt0));
    rt.r[0] = rt.r[5];
    rt.r[1] = @as(u32, cnt0) << 4;
    if (!abi.call(hw.func_0806CC18, 0x0806C40B)) return;

    abi.fetches(8);
    const cnt1: u32 = abi.read16(rt.r[4]);
    rt.r[0] = rt.r[5];
    rt.r[1] = (cnt1 << 4) +% 8;
    if (!abi.call(hw.func_0806CC4C, 0x0806C417)) return;

    abi.fetches(10);
    abi.write16(rt.r[4], abi.read16(rt.r[4]) +% 1);
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

/// Tear down secondary combat screen panels, terrain view, and sound hooks (`0x0806C90C`).
pub fn func_0806C90C() callconv(.c) void {
    if (!abi.enter(0x0806C90C)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0806C928);
    if (!abi.call(low_peel_5.func_0806CB50, 0x0806C915)) return;
    const steps = .{
        .{ ui.func_08049834, @as(u32, 0x0806C919) },
        .{ low_peel_5.func_0806C494, @as(u32, 0x0806C91D) },
        .{ ui.func_0806A8E4, @as(u32, 0x0806C921) },
        .{ ui.func_0806C368, @as(u32, 0x0806C925) },
    };
    inline for (steps) |s| {
        abi.fetches(4);
        if (!abi.call(s[0], s[1])) return;
    }
    abi.fetches(4);
    abi.popReturn();
}

inline fn packOamFlipFlag(slot: u32, cur_oam3: u8) u8 {
    const bit: u8 = @truncate(((slot ^ 1) & 1) << 4);
    return (cur_oam3 & @as(u8, 0xEF)) | bit;
}

inline fn packOamHighTileBits(val: u32, cur_oam5: u8) u8 {
    return (cur_oam5 & 0x0F) | @as(u8, @truncate((val << 4) & 0xF0));
}

inline fn packOamPrioBits(prio: u32, cur_oam5: u8) u8 {
    return (cur_oam5 & @as(u8, 0xF3)) | @as(u8, @truncate((prio & 3) << 2));
}

fn popCalleeRegs(comptime has_r7: bool, comptime high_regs: u8) void {
    if (high_regs == 1) {
        rt.r[3] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
        rt.r[8] = rt.r[3];
    } else if (high_regs == 2) {
        rt.r[3] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
        rt.r[4] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
        rt.r[8] = rt.r[3];
        rt.r[9] = rt.r[4];
    } else if (high_regs == 3) {
        rt.r[3] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
        rt.r[4] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
        rt.r[5] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
        rt.r[8] = rt.r[3];
        rt.r[9] = rt.r[4];
        rt.r[10] = rt.r[5];
    }
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    if (has_r7) {
        rt.r[7] = abi.read32(rt.r[13]);
        rt.r[13] +%= 4;
    }
}

const CombatPortraitOamCfg = struct {
    slot_pool: u32,
    anim_pool: u32,
    side_pool: u32,
    other_pool: u32,
    pal_tbl_pool: u32,
    tile_mask_pool: u32,
    oam4_mask_pool: u32,
    prio_tbl_pool: u32,
    prio_idx_pool: u32,
    pos_tbl_pool: u32,
    end_arg_pool: u32,
    tile_add: u32,
    ret_get: u32,
    ret_set_oam: u32,
    ret_set_pos: u32,
    ret_end: u32,
};

fn initCombatPortraitOam(comptime cfg: CombatPortraitOamCfg) void {
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const slot_ref = abi.read32(cfg.slot_pool);
    const oam_buf = rt.r[13];
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = oam_buf;
    if (!abi.call(sprite_anim.func_080135FC, cfg.ret_get)) return;

    abi.fetches(104);
    const anim_base = abi.read32(cfg.anim_pool);
    const side_ref = abi.read32(cfg.side_pool);
    const other_ref = abi.read32(cfg.other_pool);
    const slot_sx: u32 = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    const anim_off = anim_base +% (slot_sx *% 0x60);
    abi.write32(anim_off +% 0x28, 0);
    abi.write32(anim_off +% 0x2C, 0);
    abi.write32(anim_off +% 0x30, abi.read16(side_ref));
    abi.write32(anim_off +% 0x34, abi.read16(other_ref));

    const side = abi.read16(side_ref);
    abi.write8(oam_buf +% 3, packOamFlipFlag(side, abi.read8(oam_buf +% 3)));
    const pal_idx = abi.read16(abi.read32(cfg.pal_tbl_pool) +% (@as(u32, side) *% 6));
    abi.write8(oam_buf +% 5, packOamHighTileBits(pal_idx, abi.read8(oam_buf +% 5)));

    const tile_bits = ((@as(u32, side) << 8) +% cfg.tile_add) & abi.read32(cfg.tile_mask_pool);
    const cur_oam4 = abi.read16(oam_buf +% 4);
    abi.write16(oam_buf +% 4, @truncate((cur_oam4 & abi.read32(cfg.oam4_mask_pool)) | tile_bits));

    const other_idx = abi.read16(abi.read32(cfg.prio_idx_pool));
    const prio = abi.read16(abi.read32(cfg.prio_tbl_pool) +% ((side ^ other_idx) << 1));
    abi.write8(oam_buf +% 5, packOamPrioBits(prio, abi.read8(oam_buf +% 5)));

    rt.r[0] = slot_sx;
    rt.r[1] = abi.read32(oam_buf);
    rt.r[2] = abi.read32(oam_buf +% 4);
    if (!abi.call(sprite_anim.func_08013598, cfg.ret_set_oam)) return;

    abi.fetches(23);
    const pos_tbl = abi.read32(cfg.pos_tbl_pool);
    const entry_off = (abi.read16(other_ref) *% 0x24) +% (abi.read16(side_ref) *% 0xB4);
    const entry = pos_tbl +% entry_off;
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(entry +% 8)));
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(entry +% 0xA)));
    if (!abi.call(sprite_anim.func_08013550, cfg.ret_set_pos)) return;

    abi.fetches(7);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = abi.read32(cfg.end_arg_pool);
    if (!abi.call(sprite_anim.func_080138CC, cfg.ret_end)) return;

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

const CombatStatIconOamCfg = struct {
    anim_pool: u32,
    slot_pool: u32,
    stat_pool: u32,
    pal_tbl_pool: u32,
    ret_sub: u32,
    ret_get: u32,
    ret_set: u32,
};

fn initCombatStatIconOam(comptime cfg: CombatStatIconOamCfg) void {
    abi.fetches(24);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const anim_base = abi.read32(cfg.anim_pool);
    const slot_ref = abi.read32(cfg.slot_pool);
    const slot_sx: u32 = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    const a_off = slot_sx *% 0x60;
    const v0 = abi.read16(anim_base +% a_off +% 0x30);
    const v1 = abi.read16(anim_base +% a_off +% 0x34);
    rt.r[0] = v0;
    rt.r[1] = v1;
    if (!abi.call(ui.func_08054BA8, cfg.ret_sub)) return;

    abi.fetches(8);
    const oam_buf = rt.r[13];
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = oam_buf;
    if (!abi.call(sprite_anim.func_080135FC, cfg.ret_get)) return;

    abi.fetches(39);
    const stat_base = abi.read32(cfg.stat_pool) +% (v0 *% 0x90) +% (v1 << 1);
    const s0 = abi.read16(stat_base +% 0x26);
    const s1 = abi.read16(stat_base +% 0x30);
    const shifted: u32 = @bitCast(@as(i32, @bitCast((@as(u32, s0) +% s1) << 16)) >> 15);
    const pal = abi.read16(abi.read32(cfg.pal_tbl_pool) +% shifted +% (v0 *% 12));
    abi.write8(oam_buf +% 5, packOamHighTileBits(pal, abi.read8(oam_buf +% 5)));

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = abi.read32(oam_buf);
    rt.r[2] = abi.read32(oam_buf +% 4);
    if (!abi.call(sprite_anim.func_08013598, cfg.ret_set)) return;

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

const CombatHudBadgeOamCfg = struct {
    clear_zero_fields: bool,
    slot_pool: u32,
    anim_pool: u32,
    side_pool: u32,
    other_pool: u32,
    pal_tbl_pool: u32,
    tile_mask_pool: u32,
    oam4_mask_pool: u32,
    prio_tbl_pool: u32,
    prio_idx_pool: u32,
    end_arg_pool: u32 = 0,
    tile_add: u32,
    ret_get: u32,
    ret_set: u32,
    ret_end: u32 = 0,
};

fn initCombatHudBadgeOam(comptime cfg: CombatHudBadgeOamCfg) void {
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const slot_ref = abi.read32(cfg.slot_pool);
    const oam_buf = rt.r[13];
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = oam_buf;
    if (!abi.call(sprite_anim.func_080135FC, cfg.ret_get)) return;

    abi.fetches(if (cfg.clear_zero_fields) 103 else 83);
    const anim_base = abi.read32(cfg.anim_pool);
    const side_ref = abi.read32(cfg.side_pool);
    const other_ref = abi.read32(cfg.other_pool);
    const slot_sx: u32 = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    const a_off = slot_sx *% 0x60;
    if (cfg.clear_zero_fields) {
        abi.write32(anim_base +% a_off +% 0x28, 0);
        abi.write32(anim_base +% a_off +% 0x2C, 0);
    }
    abi.write32(anim_base +% a_off +% 0x30, abi.read16(side_ref));
    abi.write32(anim_base +% a_off +% 0x34, abi.read16(other_ref));

    const side = abi.read16(side_ref);
    abi.write8(oam_buf +% 3, packOamFlipFlag(side, abi.read8(oam_buf +% 3)));
    const pal_idx = abi.read16(abi.read32(cfg.pal_tbl_pool) +% (@as(u32, side) *% 6));
    abi.write8(oam_buf +% 5, packOamHighTileBits(pal_idx, abi.read8(oam_buf +% 5)));

    const tile_bits = ((@as(u32, side) << 8) +% cfg.tile_add) & abi.read32(cfg.tile_mask_pool);
    const cur_oam4 = abi.read16(oam_buf +% 4);
    abi.write16(oam_buf +% 4, @truncate((cur_oam4 & abi.read32(cfg.oam4_mask_pool)) | tile_bits));

    const other_idx = abi.read16(abi.read32(cfg.prio_idx_pool));
    const prio = abi.read16(abi.read32(cfg.prio_tbl_pool) +% ((side ^ other_idx) << 1));
    abi.write8(oam_buf +% 5, packOamPrioBits(prio, abi.read8(oam_buf +% 5)));

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = abi.read32(oam_buf);
    rt.r[2] = abi.read32(oam_buf +% 4);
    if (!abi.call(sprite_anim.func_08013598, cfg.ret_set)) return;

    if (cfg.ret_end != 0) {
        abi.fetches(7);
        rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
        rt.r[1] = abi.read32(cfg.end_arg_pool);
        if (!abi.call(sprite_anim.func_080138CC, cfg.ret_end)) return;
    }

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

const CombatUnitPanelCfg = struct {
    xor_prio: bool,
    slot_pool: u32,
    anim_pool: u32,
    unit_idx_pool: u32,
    other_idx_pool: u32,
    pal_tbl_pool: u32,
    tile_mask_pool: u32,
    oam4_mask_pool: u32,
    prio_tbl_pool: u32,
    prio_ref_pool: u32,
    anim_ptr_tbl_pool: u32,
    unit_arr_pool: u32,
    lookup0_pool: u32,
    lookup1_pool: u32,
    pos_tbl_pool: u32,
    off_x_tbl_pool: u32,
    off_y_tbl_pool: u32,
    end_tbl_pool: u32,
    ret_get: u32,
    ret_set_anim: u32,
    ret_set_oam: u32,
    ret_set_pos: u32,
    ret_end: u32,
};

fn initCombatUnitPanelSprites(comptime cfg: CombatUnitPanelCfg) void {
    abi.fetches(16);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    const saved_r10 = rt.r[10];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r10);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 0xC;

    const slot_ref = abi.read32(cfg.slot_pool);
    const oam_buf = rt.r[13];
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = oam_buf;
    if (!abi.call(sprite_anim.func_080135FC, cfg.ret_get)) return;

    abi.fetches(if (cfg.xor_prio) 191 else 190);
    const anim_base = abi.read32(cfg.anim_pool);
    const unit_ref = abi.read32(cfg.unit_idx_pool);
    const other_ref = abi.read32(cfg.other_idx_pool);
    const slot_sx: u32 = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    const a_off = slot_sx *% 0x60;
    abi.write32(anim_base +% a_off +% 0x2C, 0);
    abi.write32(anim_base +% a_off +% 0x30, abi.read16(unit_ref));
    abi.write32(anim_base +% a_off +% 0x34, abi.read16(other_ref));

    const u_idx = abi.read16(unit_ref);
    abi.write8(oam_buf +% 3, packOamFlipFlag(u_idx, abi.read8(oam_buf +% 3)));
    const pal = abi.read16(abi.read32(cfg.pal_tbl_pool) +% (@as(u32, u_idx) *% 6));
    abi.write8(oam_buf +% 5, packOamHighTileBits(pal, abi.read8(oam_buf +% 5)));

    const tile_bits = (@as(u32, u_idx) << 8) & abi.read32(cfg.tile_mask_pool);
    abi.write16(oam_buf +% 4, @truncate((abi.read16(oam_buf +% 4) & abi.read32(cfg.oam4_mask_pool)) | tile_bits));

    const prio_ref = abi.read16(abi.read32(cfg.prio_ref_pool));
    const prio_idx = if (cfg.xor_prio) (prio_ref ^ u_idx) << 1 else (prio_ref +% (u_idx << 1)) << 1;
    const prio = abi.read16(abi.read32(cfg.prio_tbl_pool) +% prio_idx);
    abi.write8(oam_buf +% 5, packOamPrioBits(prio, abi.read8(oam_buf +% 5)));

    const unit_arr = abi.read32(cfg.unit_arr_pool);
    const arr_off = @as(u32, u_idx) << 4;
    const sub0 = abi.read16(unit_arr +% arr_off +% 6);
    const sub1 = abi.read16(unit_arr +% arr_off +% abi.read32(cfg.lookup1_pool));
    const sub1_tbl = abi.read16(abi.read32(cfg.lookup0_pool) +% (sub1 *% 20));
    const anim_ptr_tbl = abi.read32(cfg.anim_ptr_tbl_pool) +% (((sub0 *% 0x18) +% sub1_tbl) << 2);
    const anim_ptr = abi.read32(anim_ptr_tbl);

    const pos_tbl = abi.read32(cfg.pos_tbl_pool);
    const o_idx = abi.read16(other_ref);
    const p_entry = pos_tbl +% (o_idx *% 0x24) +% (u_idx *% 0xB4);
    const src_a_off = ((u_idx *% 5) +% o_idx) << 2;
    abi.write16(p_entry +% 4, abi.read16(anim_ptr +% src_a_off));
    abi.write16(p_entry +% 8, abi.read16(p_entry +% 4));
    abi.write16(p_entry +% 6, abi.read16(anim_ptr +% src_a_off +% 2));
    abi.write16(p_entry +% 0xA, abi.read16(p_entry +% 6));
    abi.write16(p_entry +% 0x1E, 0);

    rt.r[0] = u_idx;
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(low_peel_8.func_08052C3C, cfg.ret_set_anim)) return;

    abi.fetches(9);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = abi.read32(oam_buf);
    rt.r[2] = abi.read32(oam_buf +% 4);
    if (!abi.call(sprite_anim.func_08013598, cfg.ret_set_oam)) return;

    abi.fetches(37);
    const u_idx2 = abi.read16(unit_ref);
    const off_x_ptr = abi.read32(abi.read32(cfg.off_x_tbl_pool) +% (@as(u32, u_idx2) << 2));
    const off_y_ptr = abi.read32(abi.read32(cfg.off_y_tbl_pool) +% (@as(u32, u_idx2) << 2));
    const p_entry2 = pos_tbl +% (abi.read16(other_ref) *% 0x24) +% (u_idx2 *% 0xB4);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(p_entry2 +% 8) -% abi.read16(off_x_ptr)));
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(p_entry2 +% 0xA) -% abi.read16(off_y_ptr)));
    if (!abi.call(sprite_anim.func_08013550, cfg.ret_set_pos)) return;

    abi.fetches(29);
    const u_idx3 = abi.read16(unit_ref);
    const arr_off3 = @as(u32, u_idx3) << 4;
    const s3 = abi.read16(unit_arr +% arr_off3 +% 4);
    const s4 = abi.read16(unit_arr +% arr_off3 +% abi.read32(cfg.lookup1_pool));
    const end_idx = (s4 *% 9) +% (s3 *% 3);
    const end_base = abi.read32(cfg.end_tbl_pool) +% 8;
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = abi.read32(end_base +% (end_idx << 2));
    if (!abi.call(sprite_anim.func_080138CC, cfg.ret_end)) return;

    abi.fetches(10);
    rt.r[13] +%= 0xC;
    rt.r[3] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[8] = rt.r[3];
    rt.r[9] = rt.r[4];
    rt.r[10] = rt.r[5];
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

const CombatGaugeHudCfg = struct {
    clear_zero28: bool,
    pal_tbl_mode: bool,
    pre_hook_9d30: bool,
    has_unit_arr4: bool,
    prio_bit: u8,
    slot_pool: u32,
    anim_pool: u32,
    side_pool: u32,
    other_pool: u32,
    pal_tbl_pool: u32 = 0,
    tbl6c_pool: u32,
    tile_mask_pool: u32,
    oam4_mask_pool: u32,
    pos_tbl_pool: u32,
    off_tbl_pool: u32,
    arr_off_pool: u32 = 0,
    arr_base_pool: u32 = 0,
    ret_get: u32,
    ret_hook: u32 = 0,
    ret_set_oam: u32,
    ret_hud: u32,
};

fn initCombatGaugeHud(comptime cfg: CombatGaugeHudCfg) void {
    abi.fetches(16);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    const saved_r10 = rt.r[10];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r10);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const slot_ref = abi.read32(cfg.slot_pool);
    const oam_buf = rt.r[13];
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = oam_buf;
    if (!abi.call(sprite_anim.func_080135FC, cfg.ret_get)) return;

    abi.fetches(if (cfg.pre_hook_9d30) 115 else if (cfg.pal_tbl_mode) 150 else if (cfg.clear_zero28) 137 else 131);
    const anim_base = abi.read32(cfg.anim_pool);
    const side_ref = abi.read32(cfg.side_pool);
    const other_ref = abi.read32(cfg.other_pool);
    const slot_sx: u32 = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    const a_off = slot_sx *% 0x60;
    if (cfg.clear_zero28) abi.write32(anim_base +% a_off +% 0x28, 0);
    abi.write32(anim_base +% a_off +% 0x30, abi.read16(side_ref));
    abi.write32(anim_base +% a_off +% 0x34, abi.read16(other_ref));

    if (cfg.pal_tbl_mode) {
        const pal = abi.read16(abi.read32(cfg.pal_tbl_pool) +% ((abi.read16(other_ref) *% 2 +% abi.read16(side_ref)) << 1));
        abi.write8(oam_buf +% 5, packOamHighTileBits(pal, abi.read8(oam_buf +% 5)));
    } else {
        abi.write8(oam_buf +% 5, (abi.read8(oam_buf +% 5) & 0x0F) | 0x80);
    }

    const side = abi.read16(side_ref);
    const tbl6c = abi.read32(cfg.tbl6c_pool);
    const tbl_side_off = @as(u32, side) *% 0x6C;
    const sub_idx = abi.read16(tbl6c +% tbl_side_off +% 0x2E);
    const tile_word = abi.read16(tbl6c +% tbl_side_off +% 0x3A +% (@as(u32, sub_idx) << 1));
    const tile_bits = tile_word & abi.read32(cfg.tile_mask_pool);
    abi.write16(oam_buf +% 4, @truncate((abi.read16(oam_buf +% 4) & abi.read32(cfg.oam4_mask_pool)) | tile_bits));
    abi.write8(oam_buf +% 5, (abi.read8(oam_buf +% 5) & @as(u8, 0xF3)) | cfg.prio_bit);

    const other = abi.read16(other_ref);
    const pos_base = abi.read32(cfg.pos_tbl_pool) +% (other *% 0x24) +% (@as(u32, side) *% 0xB4);
    const off_tbl = abi.read32(cfg.off_tbl_pool);
    const unit_sub = abi.read16(tbl6c +% tbl_side_off +% 0x30 +% (@as(u32, other) << 1));
    const unit_sub28 = @as(u32, unit_sub) *% 28;
    const x_base = (abi.read16(pos_base +% 8) +% abi.read16(off_tbl +% (side << 1) +% unit_sub28 +% 2)) & 0xFFFF;
    const y_base = (abi.read16(pos_base +% 0xA) +% abi.read16(off_tbl +% unit_sub28 +% 6)) & 0xFFFF;

    var hud_x = x_base;
    var hud_y = y_base;
    if (cfg.has_unit_arr4) {
        const unit_arr4 = abi.read32(cfg.arr_off_pool);
        const side_arr = abi.read32(cfg.arr_base_pool);
        const sub_w = abi.read16(side_arr +% (@as(u32, side) << 4) +% 2);
        const sub_off = @as(u32, sub_w) *% 24;
        const arr_x = abi.read16(unit_arr4 +% (side << 1) +% (other << 3) +% sub_off);
        const arr_y = abi.read16(unit_arr4 +% (other << 3) +% sub_off +% 4);
        hud_x = (hud_x +% arr_x) & 0xFFFF;
        hud_y = (hud_y +% arr_y) & 0xFFFF;
    }

    if (cfg.pre_hook_9d30) {
        rt.r[0] = hud_x;
        rt.r[1] = hud_y;
        abi.setRegNz(&rt.r[2], 0);
        if (!abi.call(low_peel_8.func_08059D30, cfg.ret_hook)) return;
        abi.fetches(9);
    }

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = abi.read32(oam_buf);
    rt.r[2] = abi.read32(oam_buf +% 4);
    if (!abi.call(sprite_anim.func_08013598, cfg.ret_set_oam)) return;

    abi.fetches(if (cfg.pre_hook_9d30) 14 else 15);
    rt.r[0] = abi.read16(other_ref);
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[2] = @bitCast(abi.signExtend16(@truncate(hud_x)));
    rt.r[3] = @bitCast(abi.signExtend16(@truncate(hud_y)));
    if (!abi.call(low_peel_8.func_080574BC, cfg.ret_hud)) return;

    abi.fetches(10);
    rt.r[13] +%= 8;
    popCalleeRegs(true, 3);
    abi.popReturn();
}

const BattleCueEffectCfg = struct {
    has_sfx: bool,
    write_flag: bool,
    entry_fetches: u32,
    slot_pool0: u32,
    slot_pool1: u32,
    tbl6c_pool: u32,
    tbl24_pool: u32,
    param_tbl_pool: u32,
    flag_pool: u32 = 0,
    tail_scale: u32,
    ret_render: u32,
    ret_anim: u32,
    ret_mid0: u32,
    ret_mid1: u32 = 0,
    ret_mid2: u32 = 0,
    ret_f0: u32,
    ret_f1: u32,
    ret_t0: u32,
    ret_t1: u32,
    ret_end: u32,
};

fn spawnBattleCueEffect(comptime cfg: BattleCueEffectCfg) void {
    abi.fetches(cfg.entry_fetches);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    const saved_r10 = rt.r[10];
    if (cfg.write_flag) {
        rt.r[13] -%= 4;
        abi.write32(rt.r[13], saved_r10);
    }
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 4;

    const a0 = rt.r[0] & 0xFFFF;
    const a1 = rt.r[1] & 0xFFFF;
    abi.write16(abi.read32(cfg.slot_pool0), @truncate(a0));
    abi.write16(abi.read32(cfg.slot_pool1), @truncate(a1));

    const tbl6c_off = a0 *% 0x6C;
    const tbl24_base = abi.read32(cfg.tbl24_pool);
    const sub_idx = abi.read16(tbl24_base +% tbl6c_off +% 0x2E);
    const rec_off = (@as(u32, sub_idx) << 2) +% tbl6c_off;
    rt.r[0] = abi.read32(cfg.tbl6c_pool);
    abi.setRegNz(&rt.r[1], 1);
    rt.r[2] = abi.read32(tbl24_base +% rec_off +% 0x44);
    rt.r[3] = abi.read32(tbl24_base +% rec_off +% 0x58);
    abi.write32(rt.r[13], 0);
    if (!abi.call(low_peel_10.func_08013330, cfg.ret_render)) return;

    abi.fetches(13);
    const slot_ptr = tbl24_base +% tbl6c_off +% 0x24 +% (a1 << 1);
    abi.write16(slot_ptr, @truncate(@as(u32, @bitCast(abi.signExtend8(@truncate(rt.r[0]))))));
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ptr)));
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(sprite_anim.func_08013494, cfg.ret_anim)) return;

    if (cfg.has_sfx) {
        abi.fetches(5);
        abi.setRegNz(&rt.r[0], 0x3B);
        if (!abi.call(low_peel_5.func_080783BC, cfg.ret_mid0)) return;
        abi.fetches(5);
        abi.setRegNz(&rt.r[0], 0x3C);
        if (!abi.call(low_peel_5.func_080783BC, cfg.ret_mid1)) return;
        abi.fetches(5);
        abi.setRegNz(&rt.r[0], 0x51);
        if (!abi.call(low_peel_8.func_0803D830, cfg.ret_mid2)) return;
        abi.fetches(11);
    } else {
        abi.fetches(6);
        rt.r[0] = a0;
        abi.setRegNz(&rt.r[1], 0x23);
        if (!abi.call(low_peel_8.func_0805743C, cfg.ret_mid0)) return;
        abi.fetches(10);
    }

    const p_val = abi.read16(abi.read32(cfg.param_tbl_pool) +% (a0 << 1));
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ptr)));
    if (!abi.call(proc.func_080147B8, cfg.ret_f0)) return;

    abi.fetches(6);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ptr)));
    if (!abi.call(sprite_anim.func_080148DC, cfg.ret_f1)) return;

    abi.fetches(9);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ptr)));
    rt.r[1] = @bitCast(abi.signExtend16(p_val));
    if (!abi.call(sprite_anim.func_08013744, cfg.ret_t0)) return;

    abi.fetches(8);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ptr)));
    rt.r[1] = cfg.tail_scale;
    if (!abi.call(sprite_anim.func_08013794, cfg.ret_t1)) return;

    abi.fetches(if (cfg.write_flag) 11 else 6);
    if (cfg.write_flag) {
        abi.write16((a0 << 2) +% abi.read32(cfg.flag_pool), 1);
    }
    rt.r[0] = a0;
    rt.r[1] = a1;
    if (!abi.call(low_peel_16.func_08059748, cfg.ret_end)) return;

    abi.fetches(if (cfg.write_flag) 10 else 9);
    rt.r[13] +%= 4;
    popCalleeRegs(false, if (cfg.write_flag) 3 else 2);
    abi.popReturn();
}

const CombatTileBankCfg = struct {
    invert_sides: bool,
    write_one_flag: bool,
    entry_fetches: u32,
    head_lut_pool: ?u32,
    side_pool: u32,
    flag_pool: u32 = 0,
    bank0_pool: u32,
    lut_pool: u32,
    bank1_pool: u32,
    bank2_pool: u32,
    bank3_pool: u32,
    ret_head: u32,
    ret_items: [40]u32,
};

fn uploadCombatUiTileBank(comptime cfg: CombatTileBankCfg) void {
    abi.fetches(cfg.entry_fetches);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);

    const side_ptr = abi.read32(cfg.side_pool);
    const side = abi.read16(side_ptr);
    rt.r[0] = if (cfg.head_lut_pool) |hlp| abi.read16(abi.read32(hlp) +% (@as(u32, side) << 1)) else side;
    if (!abi.call(ui.func_0805EC38, cfg.ret_head)) return;

    const lut_base = abi.read32(cfg.lut_pool);
    if (cfg.write_one_flag) {
        abi.fetches(18);
        abi.write16(abi.read32(cfg.flag_pool), 1);
    } else {
        abi.fetches(12);
    }

    const offsets = [40]u32{
        // bank 0
        0x18, 0x3C, 0x60, 0x84, 0xA8, 0xCC, 0xF0, 0x114, 0x138, 0x15C,
        // bank 1
        0x00, 0x02, 0x04, 0x06, 0x08, 0x0A, 0x0C, 0x0E, 0x10, 0x12,
        // bank 2
        0x24, 0x26, 0x28, 0x2A, 0x2C, 0x90, 0x92, 0x94, 0x96, 0x98,
        // bank 3
        0x02, 0x04, 0x06, 0x08, 0x0A, 0x2A, 0x2C, 0x2E, 0x30, 0x32,
    };
    const banks = [4]u32{ cfg.bank0_pool, cfg.bank1_pool, cfg.bank2_pool, cfg.bank3_pool };

    inline for (0..40) |k| {
        const bank_idx = k / 10;
        const pos_in_bank = k % 10;
        const xor_side = (pos_in_bank >= 5) != cfg.invert_sides;
        if (k != 0) {
            if (pos_in_bank == 0) {
                abi.fetches(if (xor_side) 13 else 11);
            } else {
                const f: u32 = if (xor_side)
                    (if (bank_idx == 0 and pos_in_bank >= 8 and !cfg.invert_sides) 15 else if (bank_idx == 0 or bank_idx == 2) 14 else 12)
                else
                    (if ((bank_idx == 0 and pos_in_bank >= 8) or (bank_idx == 0 and cfg.invert_sides and pos_in_bank >= 8)) 13 else if (bank_idx == 0 or bank_idx == 2) 12 else 10);
                abi.fetches(f);
            }
        }
        const cur_side = abi.read16(side_ptr);
        const eff_side = if (xor_side) (cur_side ^ 1) else cur_side;
        const src_base = abi.read32(banks[bank_idx]);
        rt.r[0] = @bitCast(abi.signExtend16(abi.read16(src_base +% offsets[k])));
        rt.r[1] = abi.read16(lut_base +% (@as(u32, eff_side) << 1));
        if (!abi.call(low_peel_8.func_0805A568, cfg.ret_items[k])) return;
    }

    abi.fetches(7);
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

/// Update primary combat backdrop OAM animator slot via `0x080135C8` / `0x08013598` / `0x08013550` (`0x08052410`).
pub fn func_08052410() callconv(.c) void {
    if (!abi.enter(0x08052410)) return;
    abi.fetches(15);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    const saved_r10 = rt.r[10];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r10);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const slot_ptr = abi.read32(0x08052504);
    const oam_buf = rt.r[13];
    rt.r[0] = oam_buf;
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(slot_ptr)));
    if (!abi.call(sprite_anim.func_080135C8, 0x0805242B)) return;

    abi.fetches(81);
    const oam01 = abi.read32(oam_buf);
    const oam2 = abi.read32(oam_buf +% 4);
    const anim_base = abi.read32(0x08052508);
    const idx0_ptr = abi.read32(0x0805250C);
    const idx1_ptr = abi.read32(0x08052510);
    const slot_sx: u32 = @bitCast(abi.signExtend16(abi.read16(slot_ptr)));
    const a_off = slot_sx *% 0x60;
    abi.write32(anim_base +% a_off +% 0x30, abi.read16(idx0_ptr));
    abi.write32(anim_base +% a_off +% 0x34, abi.read16(idx1_ptr));

    const v0 = abi.read16(idx0_ptr);
    const v1 = abi.read16(idx1_ptr);
    const flip_bit = ((@as(u32, v0) ^ 1) & 1) << 28;
    const new_oam01 = (oam01 & abi.read32(0x08052514)) | flip_bit;
    const prio = (abi.read16(abi.read32(0x08052518) +% ((@as(u32, v0) *% 3 +% 1) << 1)) & 0xF) << 12;
    const oam2_p = (oam2 & abi.read32(0x0805251C)) | prio;
    const tile = abi.read16(abi.read32(0x08052520) +% (@as(u32, v0) << 1)) & abi.read32(0x08052524);
    const oam2_t = (oam2_p & abi.read32(0x08052528)) | tile;
    const pal_idx = (v0 ^ abi.read16(abi.read32(0x08052530))) << 1;
    const pal = (abi.read16(abi.read32(0x0805252C) +% pal_idx) & 3) << 10;
    const new_oam2 = (oam2_t & abi.read32(0x08052534)) | pal;

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ptr)));
    rt.r[1] = new_oam01;
    rt.r[2] = new_oam2;
    if (!abi.call(sprite_anim.func_08013598, 0x080524C9)) return;

    abi.fetches(24);
    const pos_tbl = abi.read32(0x08052538);
    const pos_entry = pos_tbl +% (@as(u32, v1) *% 0x24) +% (@as(u32, v0) *% 0xB4);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ptr)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(pos_entry +% 4)));
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(pos_entry +% 0xA)));
    if (!sprite_anim.updateSpriteAnimCall(0x080524F5)) return;

    abi.fetches(10);
    rt.r[13] +%= 8;
    popCalleeRegs(false, 3);
    abi.popReturn();
}

/// Update combat portrait OAM attributes for `(a0, a1, a2)` and commit side flags (`0x08052F10`).
pub fn func_08052F10() callconv(.c) void {
    if (!abi.enter(0x08052F10)) return;
    abi.fetches(19);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const a0 = rt.r[0] & 0xFFFF;
    const a2: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[2])));
    const oam_buf = rt.r[13];
    rt.r[0] = a0;
    rt.r[1] = oam_buf;
    if (!abi.call(sprite_anim.func_080135FC, 0x08052F33)) return;

    abi.fetches(81);
    abi.write8(oam_buf +% 3, packOamFlipFlag(a0, abi.read8(oam_buf +% 3)));
    const pal = abi.read16(abi.read32(0x08052FDC) +% (a0 *% 6));
    abi.write8(oam_buf +% 5, packOamHighTileBits(pal, abi.read8(oam_buf +% 5)));

    const sub_tbl = abi.read32(0x08052FE0);
    const side_w = abi.read16(abi.read32(0x08052FE4) +% (a0 << 4) +% 2);
    const factor = abi.read16(sub_tbl +% (side_w *% 20) +% 0x12);
    const tile_bits = ((a0 << 8) +% (factor *% a2)) & abi.read32(0x08052FE8);
    abi.write16(oam_buf +% 4, @truncate((abi.read16(oam_buf +% 4) & abi.read32(0x08052FEC)) | tile_bits));

    const out_ptr = abi.read32(0x08052FF0);
    abi.write16(out_ptr +% 2, @truncate(a0));
    const flag_ptr = abi.read32(0x08052FF4);
    const eff = abi.read16(flag_ptr) +% a0;
    abi.write16(out_ptr +% 4, @truncate(eff & 1));
    const prio = abi.read16(abi.read32(0x08052FF8) +% ((eff & 1) << 1));
    abi.write8(oam_buf +% 5, packOamPrioBits(prio, abi.read8(oam_buf +% 5)));

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(abi.read32(0x08052FFC))));
    rt.r[1] = abi.read32(oam_buf);
    rt.r[2] = abi.read32(oam_buf +% 4);
    if (!abi.call(sprite_anim.func_08013598, 0x08052FD1)) return;

    abi.fetches(8);
    rt.r[13] +%= 8;
    popCalleeRegs(true, 1);
    abi.popReturn();
}

/// Spawn unit portrait effect slot for side `(a0, a1)` and store handle in `+0x18` (`0x080531BC`).
pub fn func_080531BC() callconv(.c) void {
    if (!abi.enter(0x080531BC)) return;
    abi.fetches(78);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    const saved_r10 = rt.r[10];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r10);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const a0 = rt.r[0] & 0xFFFF;
    const a1 = rt.r[1] & 0xFFFF;
    abi.write16(abi.read32(0x0805327C), @truncate(a0));
    abi.write16(abi.read32(0x08053280), @truncate(a1));

    const side_base = abi.read32(0x08053284) +% (a0 << 4);
    const prio_idx = abi.read16(abi.read32(0x08053288) +% (((a0 *% 5) +% a1) << 1));
    const prio = (prio_idx *% 7 +% 4) & 0xFF;

    const ptr_tbl = abi.read32(0x0805328C);
    const data_tbl = abi.read32(0x08053290);
    const sub_w = abi.read16(side_base +% 4);
    const tbl_idx = abi.read16(side_base +% 2);
    const tbl_w = abi.read16(abi.read32(0x08053294) +% (tbl_idx *% 20));

    abi.write32(rt.r[13], prio);
    rt.r[0] = abi.read32(data_tbl +% (((tbl_w *% 9) +% (sub_w *% 3)) << 2));
    abi.setRegNz(&rt.r[1], 1);
    rt.r[2] = abi.read32(ptr_tbl +% (a0 << 5) +% 4);
    rt.r[3] = abi.read32(ptr_tbl +% (a0 << 5));
    if (!abi.call(low_peel_10.func_08013330, 0x08053255)) return;

    abi.fetches(22);
    const out_base = abi.read32(0x08053298);
    const out_off = (a1 *% 0x24) +% (a0 *% 0xB4);
    abi.write16(out_base +% out_off +% 0x18, @truncate(@as(u32, @bitCast(abi.signExtend8(@truncate(rt.r[0]))))));

    rt.r[13] +%= 8;
    popCalleeRegs(true, 3);
    abi.popReturn();
}

/// Spawn unit backdrop effect slot for side `a0` and store handle in `+0x18` (`0x0805329C`).
pub fn func_0805329C() callconv(.c) void {
    if (!abi.enter(0x0805329C)) return;
    abi.fetches(62);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    const saved_r10 = rt.r[10];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r10);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 4;

    const a0 = rt.r[0] & 0xFFFF;
    const slot_ref = abi.read32(0x08053348);
    const other_ref = abi.read32(0x0805334C);
    abi.write16(slot_ref, @truncate(a0));
    abi.write16(other_ref, abi.read16(abi.read32(0x08053350) +% (a0 << 1)));

    const side_idx = abi.read16(slot_ref);
    const side_arr = abi.read32(0x08053354) +% (@as(u32, side_idx) << 4);
    const ptr_tbl = abi.read32(0x08053358);
    const data_tbl = abi.read32(0x0805335C);
    const sub_w = abi.read16(side_arr +% 4);
    const tbl_idx = abi.read16(side_arr +% 2);
    const tbl_w = abi.read16(abi.read32(0x08053360) +% (tbl_idx *% 20));

    abi.write32(rt.r[13], 0xFE);
    rt.r[0] = abi.read32(data_tbl +% (((tbl_w *% 9) +% (sub_w *% 3)) << 2));
    abi.setRegNz(&rt.r[1], 1);
    rt.r[2] = abi.read32(ptr_tbl +% (@as(u32, side_idx) << 5) +% 4);
    rt.r[3] = abi.read32(ptr_tbl +% (@as(u32, side_idx) << 5));
    if (!abi.call(low_peel_10.func_08013330, 0x08053315)) return;

    abi.fetches(27);
    const out_base = abi.read32(0x08053364);
    const out_off = (abi.read16(other_ref) *% 0x24) +% (abi.read16(slot_ref) *% 0xB4);
    abi.write16(out_base +% out_off +% 0x18, @truncate(@as(u32, @bitCast(abi.signExtend8(@truncate(rt.r[0]))))));

    rt.r[13] +%= 4;
    popCalleeRegs(true, 3);
    abi.popReturn();
}

/// Set up CO name/bar sub-sprite & palette for battle side `a0` (`0x08053420`).
pub fn func_08053420() callconv(.c) void {
    if (!abi.enter(0x08053420)) return;
    abi.fetches(29);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 4;

    const a0 = rt.r[0] & 0xFFFF;
    abi.write16(abi.read32(0x080534C8), @truncate(a0));
    abi.write16(abi.read32(0x080534CC), abi.read16(abi.read32(0x080534D0) +% (a0 << 1)));
    const arr_base = abi.read32(0x080534D4) +% (a0 << 4);
    const key_id = abi.read16(arr_base);
    const aux_id = abi.read16(arr_base +% 8);

    rt.r[0] = a0;
    if (!abi.call(low_peel_8.func_08053368, 0x08053457)) return;

    abi.fetches(18);
    const gfx_tbl = abi.read32(0x080534D8);
    const pal_lut = abi.read8(aux_id +% abi.read32(0x080534DC));
    rt.r[0] = abi.read32(gfx_tbl +% (@as(u32, pal_lut) *% 12));
    rt.r[1] = abi.read32(abi.read32(0x080534E0) +% (a0 << 2));
    if (!dma.copyVramCheckedCall(0x08053477)) return;

    abi.fetches(29);
    const idx2 = abi.read16(abi.read32(0x080534E4) +% (a0 *% 10) +% 8);
    const prio = (idx2 *% 7) & 0xFF;
    const sub_tbl = abi.read32(0x080534E8) +% (@as(u32, key_id) *% 12);
    abi.write32(rt.r[13], prio);
    rt.r[0] = abi.read32(gfx_tbl +% (@as(u32, pal_lut) *% 12));
    abi.setRegNz(&rt.r[1], 1);
    rt.r[2] = abi.read32(sub_tbl +% 8);
    rt.r[3] = abi.read32(sub_tbl +% 4);
    if (!abi.call(low_peel_10.func_08013330, 0x080534AD)) return;

    abi.fetches(15);
    const out_base = abi.read32(0x080534EC) +% 8;
    abi.write16(out_base +% (a0 *% 10), @truncate(@as(u32, @bitCast(abi.signExtend8(@truncate(rt.r[0]))))));

    rt.r[13] +%= 4;
    popCalleeRegs(false, 2);
    abi.popReturn();
}

/// Initialize primary combatant portrait OAM card (`0x08053648`).
pub fn func_08053648() callconv(.c) void {
    if (!abi.enter(0x08053648)) return;
    initCombatPortraitOam(.{
        .slot_pool = 0x0805376C,
        .anim_pool = 0x08053770,
        .side_pool = 0x08053774,
        .other_pool = 0x08053778,
        .pal_tbl_pool = 0x0805377C,
        .tile_mask_pool = 0x08053780,
        .oam4_mask_pool = 0x08053784,
        .prio_tbl_pool = 0x08053788,
        .prio_idx_pool = 0x0805378C,
        .pos_tbl_pool = 0x08053790,
        .end_arg_pool = 0x08053794,
        .tile_add = 0x50,
        .ret_get = 0x0805365F,
        .ret_set_oam = 0x0805372B,
        .ret_set_pos = 0x08053755,
        .ret_end = 0x0805375F,
    });
}

/// Initialize primary combatant stat/weapon badge OAM (`0x08053798`).
pub fn func_08053798() callconv(.c) void {
    if (!abi.enter(0x08053798)) return;
    initCombatStatIconOam(.{
        .anim_pool = 0x08053828,
        .slot_pool = 0x0805382C,
        .stat_pool = 0x08053830,
        .pal_tbl_pool = 0x08053834,
        .ret_sub = 0x080537C5,
        .ret_get = 0x080537D1,
        .ret_set = 0x0805381B,
    });
}

/// Initialize secondary combatant portrait OAM card (`0x08053B90`).
pub fn func_08053B90() callconv(.c) void {
    if (!abi.enter(0x08053B90)) return;
    initCombatPortraitOam(.{
        .slot_pool = 0x08053CB4,
        .anim_pool = 0x08053CB8,
        .side_pool = 0x08053CBC,
        .other_pool = 0x08053CC0,
        .pal_tbl_pool = 0x08053CC4,
        .tile_mask_pool = 0x08053CC8,
        .oam4_mask_pool = 0x08053CCC,
        .prio_tbl_pool = 0x08053CD0,
        .prio_idx_pool = 0x08053CD4,
        .pos_tbl_pool = 0x08053CD8,
        .end_arg_pool = 0x08053CDC,
        .tile_add = 0x80,
        .ret_get = 0x08053BA7,
        .ret_set_oam = 0x08053C73,
        .ret_set_pos = 0x08053C9D,
        .ret_end = 0x08053CA7,
    });
}

/// Initialize secondary combatant stat/weapon badge OAM (`0x08053CE0`).
pub fn func_08053CE0() callconv(.c) void {
    if (!abi.enter(0x08053CE0)) return;
    initCombatStatIconOam(.{
        .anim_pool = 0x08053D70,
        .slot_pool = 0x08053D74,
        .stat_pool = 0x08053D78,
        .pal_tbl_pool = 0x08053D7C,
        .ret_sub = 0x08053D0D,
        .ret_get = 0x08053D19,
        .ret_set = 0x08053D63,
    });
}

/// Initialize primary combatant unit sprites, terrain panel & position (`0x080541C8`).
pub fn func_080541C8() callconv(.c) void {
    if (!abi.enter(0x080541C8)) return;
    initCombatUnitPanelSprites(.{
        .xor_prio = true,
        .slot_pool = 0x080543F8,
        .anim_pool = 0x080543FC,
        .unit_idx_pool = 0x08054400,
        .other_idx_pool = 0x08054404,
        .pal_tbl_pool = 0x08054408,
        .tile_mask_pool = 0x0805440C,
        .oam4_mask_pool = 0x08054410,
        .prio_tbl_pool = 0x08054414,
        .prio_ref_pool = 0x08054418,
        .anim_ptr_tbl_pool = 0x0805441C,
        .unit_arr_pool = 0x08054420,
        .lookup0_pool = 0x08054424,
        .lookup1_pool = 0x08054428,
        .pos_tbl_pool = 0x0805442C,
        .off_x_tbl_pool = 0x08054430,
        .off_y_tbl_pool = 0x08054434,
        .end_tbl_pool = 0x08054438,
        .ret_get = 0x080541E5,
        .ret_set_anim = 0x0805435F,
        .ret_set_oam = 0x0805436D,
        .ret_set_pos = 0x080543B3,
        .ret_end = 0x080543E9,
    });
}

/// Configure combat HUD badge OAM variant A (`0x08054680`).
pub fn func_08054680() callconv(.c) void {
    if (!abi.enter(0x08054680)) return;
    initCombatHudBadgeOam(.{
        .clear_zero_fields = false,
        .slot_pool = 0x0805473C,
        .anim_pool = 0x08054740,
        .side_pool = 0x08054744,
        .other_pool = 0x08054748,
        .pal_tbl_pool = 0x0805474C,
        .tile_mask_pool = 0x08054750,
        .oam4_mask_pool = 0x08054754,
        .prio_tbl_pool = 0x08054758,
        .prio_idx_pool = 0x0805475C,
        .tile_add = 0x10,
        .ret_get = 0x08054693,
        .ret_set = 0x08054735,
    });
}

/// Configure combat HUD badge OAM variant B (`0x08054760`).
pub fn func_08054760() callconv(.c) void {
    if (!abi.enter(0x08054760)) return;
    initCombatHudBadgeOam(.{
        .clear_zero_fields = false,
        .slot_pool = 0x0805481C,
        .anim_pool = 0x08054820,
        .side_pool = 0x08054824,
        .other_pool = 0x08054828,
        .pal_tbl_pool = 0x0805482C,
        .tile_mask_pool = 0x08054830,
        .oam4_mask_pool = 0x08054834,
        .prio_tbl_pool = 0x08054838,
        .prio_idx_pool = 0x0805483C,
        .tile_add = 0x40,
        .ret_get = 0x08054773,
        .ret_set = 0x08054815,
    });
}

/// Configure combat HUD badge OAM variant C with `0x080138CC` tail (`0x08054870`).
pub fn func_08054870() callconv(.c) void {
    if (!abi.enter(0x08054870)) return;
    initCombatHudBadgeOam(.{
        .clear_zero_fields = true,
        .slot_pool = 0x08054960,
        .anim_pool = 0x08054964,
        .side_pool = 0x08054968,
        .other_pool = 0x0805496C,
        .pal_tbl_pool = 0x08054970,
        .tile_mask_pool = 0x08054974,
        .oam4_mask_pool = 0x08054978,
        .prio_tbl_pool = 0x0805497C,
        .prio_idx_pool = 0x08054980,
        .end_arg_pool = 0x08054984,
        .tile_add = 0x60,
        .ret_get = 0x08054883,
        .ret_set = 0x0805494D,
        .ret_end = 0x08054957,
    });
}

/// Load battle backdrop tiles/palette & spawn effect sub-layer for side `a0` (`0x08054A5C`).
pub fn func_08054A5C() callconv(.c) void {
    if (!abi.enter(0x08054A5C)) return;
    abi.fetches(30);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    const saved_r10 = rt.r[10];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r10);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 0xC;

    const a0 = rt.r[0] & 0xFFFF;
    abi.write16(abi.read32(0x08054B74), @truncate(a0));
    abi.write16(abi.read32(0x08054B78), abi.read16(abi.read32(0x08054B7C) +% (a0 << 1)));
    const arr = abi.read32(0x08054B80) +% (a0 << 4);
    const key_id = abi.read16(arr);
    const aux_id = abi.read16(arr +% 8);

    rt.r[0] = a0;
    if (!abi.call(low_peel_8.func_08053368, 0x08054A95)) return;

    abi.fetches(44);
    const tile_dst_off = ((a0 << 13) +% 0x800) & 0xFFFF;
    const tbl9 = abi.read32(0x08054B84);
    const prio0 = (abi.read16(tbl9 +% (a0 *% 10) +% 4) *% 7) & 0xFF;
    const gfx_tbl = abi.read32(0x08054B8C);
    const sub_off0 = @as(u32, key_id) *% 12;
    abi.write32(rt.r[13], prio0);
    rt.r[0] = abi.read32(0x08054B88);
    abi.setRegNz(&rt.r[1], 1);
    rt.r[2] = abi.read32(gfx_tbl +% sub_off0 +% 8);
    rt.r[3] = abi.read32(gfx_tbl +% sub_off0 +% 4);
    if (!abi.call(low_peel_10.func_08013330, 0x08054AE9)) return;

    abi.fetches(24);
    const out_tbl = abi.read32(0x08054B90);
    abi.write16(out_tbl +% (a0 *% 10) +% 4, @truncate(@as(u32, @bitCast(abi.signExtend8(@truncate(rt.r[0]))))));
    const pal_lut = abi.read8(aux_id +% abi.read32(0x08054B94));
    rt.r[0] = abi.read32(gfx_tbl +% (@as(u32, pal_lut) *% 12));
    rt.r[1] = tile_dst_off +% abi.read32(0x08054B98);
    rt.r[2] = 0x400;
    if (!abi.call(bios.func_080796C0, 0x08054B15)) return;

    abi.fetches(12);
    const sub_tbl = abi.read32(0x08054B9C);
    rt.r[0] = abi.read32(sub_tbl +% sub_off0);
    rt.r[1] = abi.read32(abi.read32(0x08054BA0) +% (a0 << 2));
    if (!dma.copyVramCheckedCall(0x08054B29)) return;

    abi.fetches(26);
    const prio1 = (abi.read16(tbl9 +% 8 +% (a0 *% 10)) *% 7) & 0xFF;
    abi.write32(rt.r[13], prio1);
    rt.r[0] = abi.read32(0x08054BA4);
    abi.setRegNz(&rt.r[1], 1);
    rt.r[2] = abi.read32(sub_tbl +% 8 +% sub_off0);
    rt.r[3] = abi.read32(sub_tbl +% 4 +% sub_off0);
    if (!abi.call(low_peel_10.func_08013330, 0x08054B59)) return;

    abi.fetches(16);
    abi.write16(out_tbl +% 8 +% (a0 *% 10), @truncate(@as(u32, @bitCast(abi.signExtend8(@truncate(rt.r[0]))))));

    rt.r[13] +%= 0xC;
    popCalleeRegs(true, 3);
    abi.popReturn();
}

/// Initialize secondary combatant unit sprites, terrain panel & position (`0x08054BF4`).
pub fn func_08054BF4() callconv(.c) void {
    if (!abi.enter(0x08054BF4)) return;
    initCombatUnitPanelSprites(.{
        .xor_prio = false,
        .slot_pool = 0x08054E24,
        .anim_pool = 0x08054E28,
        .unit_idx_pool = 0x08054E2C,
        .other_idx_pool = 0x08054E30,
        .pal_tbl_pool = 0x08054E34,
        .tile_mask_pool = 0x08054E38,
        .oam4_mask_pool = 0x08054E3C,
        .prio_tbl_pool = 0x08054E40,
        .prio_ref_pool = 0x08054E44,
        .anim_ptr_tbl_pool = 0x08054E48,
        .unit_arr_pool = 0x08054E4C,
        .lookup0_pool = 0x08054E50,
        .lookup1_pool = 0x08054E54,
        .pos_tbl_pool = 0x08054E58,
        .off_x_tbl_pool = 0x08054E5C,
        .off_y_tbl_pool = 0x08054E60,
        .end_tbl_pool = 0x08054E64,
        .ret_get = 0x08054C11,
        .ret_set_anim = 0x08054D89,
        .ret_set_oam = 0x08054D97,
        .ret_set_pos = 0x08054DDD,
        .ret_end = 0x08054E13,
    });
}

/// Configure combat HUD badge OAM variant D (`0x08055090`).
pub fn func_08055090() callconv(.c) void {
    if (!abi.enter(0x08055090)) return;
    initCombatHudBadgeOam(.{
        .clear_zero_fields = false,
        .slot_pool = 0x0805514C,
        .anim_pool = 0x08055150,
        .side_pool = 0x08055154,
        .other_pool = 0x08055158,
        .pal_tbl_pool = 0x0805515C,
        .tile_mask_pool = 0x08055160,
        .oam4_mask_pool = 0x08055164,
        .prio_tbl_pool = 0x08055168,
        .prio_idx_pool = 0x0805516C,
        .tile_add = 0x40,
        .ret_get = 0x080550A3,
        .ret_set = 0x08055145,
    });
}

/// Configure combat HUD badge OAM variant E with `0x080138CC` tail (`0x08055170`).
pub fn func_08055170() callconv(.c) void {
    if (!abi.enter(0x08055170)) return;
    initCombatHudBadgeOam(.{
        .clear_zero_fields = false,
        .slot_pool = 0x08055238,
        .anim_pool = 0x0805523C,
        .side_pool = 0x08055240,
        .other_pool = 0x08055244,
        .pal_tbl_pool = 0x08055248,
        .tile_mask_pool = 0x0805524C,
        .oam4_mask_pool = 0x08055250,
        .prio_tbl_pool = 0x08055254,
        .prio_idx_pool = 0x08055258,
        .end_arg_pool = 0x0805525C,
        .tile_add = 0xC0,
        .ret_get = 0x08055183,
        .ret_set = 0x08055225,
        .ret_end = 0x0805522F,
    });
}

/// Configure combat HUD badge OAM variant F (`clear_zero_fields` + `0x080138CC`, `0x08055310`).
pub fn func_08055310() callconv(.c) void {
    if (!abi.enter(0x08055310)) return;
    initCombatHudBadgeOam(.{
        .clear_zero_fields = true,
        .slot_pool = 0x08055400,
        .anim_pool = 0x08055404,
        .side_pool = 0x08055408,
        .other_pool = 0x0805540C,
        .pal_tbl_pool = 0x08055410,
        .tile_mask_pool = 0x08055414,
        .oam4_mask_pool = 0x08055418,
        .prio_tbl_pool = 0x0805541C,
        .prio_idx_pool = 0x08055420,
        .end_arg_pool = 0x08055424,
        .tile_add = 0xC0,
        .ret_get = 0x08055323,
        .ret_set = 0x080553ED,
        .ret_end = 0x080553F7,
    });
}

/// Set up combat unit panel sub-animator (variant A: clears `+0x28` to `idx << 3`, `0x08055E48`).
pub fn func_08055E48() callconv(.c) void {
    if (!abi.enter(0x08055E48)) return;
    abi.fetches(16);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    const saved_r10 = rt.r[10];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r10);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const slot_ref = abi.read32(0x08056014);
    const oam_buf = rt.r[13];
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = oam_buf;
    if (!abi.call(sprite_anim.func_080135FC, 0x08055E65)) return;

    abi.fetches(99);
    const anim_base = abi.read32(0x08056018);
    const other_ref = abi.read32(0x0805601C);
    const side_ref = abi.read32(0x08056020);
    const slot_sx: u32 = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    const a_off = slot_sx *% 0x60;
    abi.write32(anim_base +% a_off +% 0x28, @as(u32, abi.read16(other_ref)) << 3);
    abi.write32(anim_base +% a_off +% 0x30, abi.read16(side_ref));
    abi.write32(anim_base +% a_off +% 0x34, abi.read16(other_ref));

    const side = abi.read16(side_ref);
    abi.write8(oam_buf +% 3, packOamFlipFlag(side, abi.read8(oam_buf +% 3)));
    const pal = abi.read16(abi.read32(0x08056024) +% (@as(u32, side) *% 6));
    abi.write8(oam_buf +% 5, packOamHighTileBits(pal, abi.read8(oam_buf +% 5)));
    const tile_bits = (@as(u32, side) << 8) & abi.read32(0x08056028);
    abi.write16(oam_buf +% 4, @truncate((abi.read16(oam_buf +% 4) & abi.read32(0x0805602C)) | tile_bits));
    const prio = abi.read16(abi.read32(0x08056030) +% ((abi.read16(abi.read32(0x08056034)) ^ side) << 1));
    abi.write8(oam_buf +% 5, packOamPrioBits(prio, abi.read8(oam_buf +% 5)));

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = abi.read32(oam_buf);
    rt.r[2] = abi.read32(oam_buf +% 4);
    if (!abi.call(sprite_anim.func_08013598, 0x08055F27)) return;

    abi.fetches(112);
    const anim_ptr_tbl = abi.read32(0x08056038);
    const unit_arr = abi.read32(0x0805603C);
    const side2 = abi.read16(side_ref);
    const arr_off = @as(u32, side2) << 4;
    const sub0 = abi.read16(unit_arr +% arr_off +% 6);
    const sub1 = abi.read16(unit_arr +% arr_off +% 2);
    const sub1_w = abi.read16(abi.read32(0x08056040) +% (sub1 *% 20));
    const anim_ptr = abi.read32(anim_ptr_tbl +% (((sub0 *% 0x18) +% sub1_w) << 2));

    const pos_tbl = abi.read32(0x08056044);
    const o_idx = abi.read16(other_ref);
    const p_entry = pos_tbl +% (o_idx *% 0x24) +% (side2 *% 0xB4);
    const src_off = ((side2 *% 5) +% o_idx) << 2;
    abi.write16(p_entry +% 4, abi.read16(anim_ptr +% src_off));
    abi.write16(p_entry +% 8, abi.read16(p_entry +% 4));
    abi.write16(p_entry +% 6, abi.read16(anim_ptr +% src_off +% 2));
    abi.write16(p_entry +% 0xA, abi.read16(p_entry +% 6));

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(p_entry +% 8)));
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(p_entry +% 0xA)));
    if (!sprite_anim.updateSpriteAnimCall(0x08056003)) return;

    abi.fetches(10);
    rt.r[13] +%= 8;
    popCalleeRegs(false, 3);
    abi.popReturn();
}

/// Apply battle sprite camera scroll delta via `0x08052E2C` and reposition OAM (`0x08056048`).
pub fn func_08056048() callconv(.c) void {
    if (!abi.enter(0x08056048)) return;
    abi.fetches(25);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);

    const anim_base = abi.read32(0x080560E0);
    const slot_ref = abi.read32(0x080560E4);
    const slot_sx: u32 = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    const a_off = slot_sx *% 0x60;
    const side = abi.read16(anim_base +% a_off +% 0x30);
    const other = abi.read16(anim_base +% a_off +% 0x34);
    rt.r[0] = side;
    rt.r[1] = other;
    if (!abi.call(low_peel_12.func_08052E2C, 0x08056077)) return;

    abi.fetches(49);
    const off_y_ptr = abi.read32(abi.read32(0x080560E8) +% (@as(u32, side) << 2));
    const pos_tbl = abi.read32(0x080560EC);
    const p_entry = pos_tbl +% (@as(u32, other) *% 0x24) +% (@as(u32, side) *% 0xB4);
    const dx_idx = ((rt.r[0] << 16) >> 15) +% (@as(u32, side) *% 12);
    const dx = abi.read16(abi.read32(0x080560F0) +% dx_idx);
    const nx: u16 = abi.read16(p_entry +% 8) +% dx;
    abi.write16(p_entry +% 8, nx);

    const tbl_idx = abi.read16(abi.read32(0x080560F8) +% (@as(u32, side) << 2) +% 2);
    const dy = abi.read16(abi.read32(0x080560F4) +% (@as(u32, tbl_idx) << 1));
    const ny: u16 = abi.read16(p_entry +% 0xA) -% dy;
    abi.write16(p_entry +% 0xA, ny);

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = @bitCast(abi.signExtend16(nx));
    rt.r[2] = @bitCast(abi.signExtend16(ny -% abi.read16(off_y_ptr)));
    if (!sprite_anim.updateSpriteAnimCall(0x080560D5)) return;

    abi.fetches(8);
    popCalleeRegs(false, 2);
    abi.popReturn();
}

/// Set up secondary unit combat panel sprite, tile base & position (`0x08056994`).
pub fn func_08056994() callconv(.c) void {
    if (!abi.enter(0x08056994)) return;
    abi.fetches(15);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    const saved_r9 = rt.r[9];
    const saved_r10 = rt.r[10];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r10);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r9);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const slot_ref = abi.read32(0x08056C00);
    const oam_buf = rt.r[13];
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = oam_buf;
    if (!abi.call(sprite_anim.func_080135FC, 0x080569AF)) return;

    abi.fetches(103);
    const anim_base = abi.read32(0x08056C04);
    const side_ref = abi.read32(0x08056C08);
    const other_ref = abi.read32(0x08056C0C);
    const slot_sx: u32 = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    const a_off = slot_sx *% 0x60;
    abi.write32(anim_base +% a_off +% 0x30, abi.read16(side_ref));
    abi.write32(anim_base +% a_off +% 0x34, abi.read16(other_ref));

    const side = abi.read16(side_ref);
    abi.write8(oam_buf +% 3, packOamFlipFlag(side, abi.read8(oam_buf +% 3)));
    const pal = abi.read16(abi.read32(0x08056C10) +% (@as(u32, side) *% 6));
    abi.write8(oam_buf +% 5, packOamHighTileBits(pal, abi.read8(oam_buf +% 5)));

    const lookup0 = abi.read32(0x08056C14);
    const unit_arr = abi.read32(0x08056C18);
    const lookup1 = abi.read32(0x08056C1C);
    const sub_w = abi.read16(lookup1 +% (@as(u32, side) << 4));
    const entry_off = @as(u32, sub_w) *% 20;
    const other_val = abi.read16(other_ref);
    const tile_mul = @as(u32, other_val) *% abi.read16(lookup0 +% entry_off +% 0x12);
    const tile_bits = ((@as(u32, side) << 8) +% tile_mul) & abi.read32(0x08056C20);
    abi.write16(oam_buf +% 4, @truncate((abi.read16(oam_buf +% 4) & abi.read32(0x08056C24)) | tile_bits));

    const prio = abi.read16(abi.read32(0x08056C28) +% ((abi.read16(abi.read32(0x08056C2C)) ^ side) << 1));
    abi.write8(oam_buf +% 5, packOamPrioBits(prio, abi.read8(oam_buf +% 5)));

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = abi.read32(oam_buf);
    rt.r[2] = abi.read32(oam_buf +% 4);
    if (!abi.call(sprite_anim.func_08013598, 0x08056A79)) return;

    abi.fetches(142);
    const anim_ptr_tbl = abi.read32(0x08056C30);
    const pos_tbl = abi.read32(0x08056C34);
    const side2 = abi.read16(side_ref);
    const arr_off = @as(u32, side2) << 4;
    const sub0 = abi.read16(unit_arr +% arr_off +% 6);
    const sub1 = abi.read16(lookup1 +% arr_off);
    const sub1_w = abi.read16(lookup0 +% (@as(u32, sub1) *% 20));
    const anim_ptr = abi.read32(anim_ptr_tbl +% (((sub0 *% 0x18) +% sub1_w) << 2));

    const o_idx = abi.read16(other_ref);
    const p_entry = pos_tbl +% (o_idx *% 0x24) +% (side2 *% 0xB4);
    const arr_sub = abi.read16(unit_arr +% arr_off +% 0xA);
    const src_off = ((@as(u32, o_idx) << 1) +% (side2 *% 10) +% (@as(u32, arr_sub) *% 20)) << 1;
    abi.write16(p_entry +% 4, abi.read16(anim_ptr +% src_off));
    abi.write16(p_entry +% 8, abi.read16(p_entry +% 4));
    abi.write16(p_entry +% 6, abi.read16(anim_ptr +% src_off +% 2));
    abi.write16(p_entry +% 0xA, abi.read16(p_entry +% 6));

    rt.r[0] = side2;
    rt.r[1] = o_idx;
    abi.setRegNz(&rt.r[2], 0);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(low_peel_8.func_08052C3C, 0x08056B91)) return;

    abi.fetches(23);
    const p_entry2 = pos_tbl +% (abi.read16(other_ref) *% 0x24) +% (abi.read16(side_ref) *% 0xB4);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(p_entry2 +% 8)));
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(p_entry2 +% 0xA)));
    if (!sprite_anim.updateSpriteAnimCall(0x08056BBB)) return;

    abi.fetches(29);
    const side3 = abi.read16(side_ref);
    const arr_off3 = @as(u32, side3) << 4;
    const s3 = abi.read16(unit_arr +% arr_off3 +% 4);
    const s4 = abi.read16(lookup1 +% arr_off3);
    const end_idx = (s4 *% 9) +% (s3 *% 3);
    const end_base = abi.read32(0x08056C38) +% 8;
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = abi.read32(end_base +% (end_idx << 2));
    if (!abi.call(sprite_anim.func_080138CC, 0x08056BF1)) return;

    abi.fetches(10);
    rt.r[13] +%= 8;
    popCalleeRegs(true, 3);
    abi.popReturn();
}

/// Set up terrain backdrop OAM badge `+0xF0`, copy LUT halfword & set timer `0x96` (`0x08056F90`).
pub fn func_08056F90() callconv(.c) void {
    if (!abi.enter(0x08056F90)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;

    const slot_ref = abi.read32(0x0805703C);
    const oam_buf = rt.r[13];
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = oam_buf;
    if (!abi.call(sprite_anim.func_080135FC, 0x08056FA3)) return;

    abi.fetches(61);
    const anim_base = abi.read32(0x08057040);
    const side_ref = abi.read32(0x08057044);
    const slot_sx: u32 = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    abi.write32(anim_base +% (slot_sx *% 0x60) +% 0x30, abi.read16(side_ref));

    const side = abi.read16(side_ref);
    abi.write8(oam_buf +% 3, packOamFlipFlag(side, abi.read8(oam_buf +% 3)));
    const pal = abi.read16(abi.read32(0x08057048) +% (@as(u32, side) *% 6));
    abi.write8(oam_buf +% 5, packOamHighTileBits(pal, abi.read8(oam_buf +% 5)));
    const tile_bits = ((@as(u32, side) << 8) +% 0xF0) & abi.read32(0x0805704C);
    abi.write16(oam_buf +% 4, @truncate((abi.read16(oam_buf +% 4) & abi.read32(0x08057050)) | tile_bits));
    abi.write8(oam_buf +% 5, (abi.read8(oam_buf +% 5) & @as(u8, 0xF3)) | 8);

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = abi.read32(oam_buf);
    rt.r[2] = abi.read32(oam_buf +% 4);
    if (!abi.call(sprite_anim.func_08013598, 0x08057019)) return;

    abi.fetches(20);
    const s2 = abi.read16(side_ref);
    abi.write16(abi.read32(0x08057054) +% (@as(u32, s2) << 1), abi.read16(abi.read32(0x08057058) +% (@as(u32, s2) << 1)));
    abi.write16(abi.read32(0x0805705C) +% (@as(u32, s2) << 1), 0x96);

    rt.r[13] +%= 8;
    popCalleeRegs(false, 0);
    abi.popReturn();
}

/// Configure weapon flash/projectile OAM badge and run `0x0807B454` (`0x08057AE8`).
pub fn func_08057AE8() callconv(.c) void {
    if (!abi.enter(0x08057AE8)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const slot_ref = abi.read32(0x08057BD0);
    const oam_buf = rt.r[13];
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = oam_buf;
    if (!abi.call(sprite_anim.func_080135FC, 0x08057AFF)) return;

    abi.fetches(81);
    const anim_base = abi.read32(0x08057BD4);
    const side_ref = abi.read32(0x08057BD8);
    const other_ref = abi.read32(0x08057BDC);
    const slot_sx: u32 = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    const a_off = slot_sx *% 0x60;
    abi.write32(anim_base +% a_off +% 0x30, abi.read16(side_ref));
    abi.write32(anim_base +% a_off +% 0x34, abi.read16(other_ref));

    const side = abi.read16(side_ref);
    abi.write8(oam_buf +% 3, packOamFlipFlag(side, abi.read8(oam_buf +% 3)));
    abi.write8(oam_buf +% 5, (abi.read8(oam_buf +% 5) & 0x0F) | 0x80);

    const tile_w = abi.read16(abi.read32(0x08057BE0) +% (@as(u32, side) *% 40));
    const tile_bits = tile_w & abi.read32(0x08057BE4);
    abi.write16(oam_buf +% 4, @truncate((abi.read16(oam_buf +% 4) & abi.read32(0x08057BE8)) | tile_bits));
    const prio = abi.read16(abi.read32(0x08057BEC) +% ((abi.read16(abi.read32(0x08057BF0)) ^ side) << 1));
    abi.write8(oam_buf +% 5, packOamPrioBits(prio, abi.read8(oam_buf +% 5)));

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = abi.read32(oam_buf);
    rt.r[2] = abi.read32(oam_buf +% 4);
    if (!abi.call(sprite_anim.func_08013598, 0x08057B9D)) return;

    abi.fetches(22);
    const side2 = abi.read16(side_ref);
    const idx = abi.read16(abi.read32(0x08057BFC) +% (@as(u32, side2) << 4) +% 2);
    const div_arg = abi.read16(abi.read32(0x08057BF8) +% (@as(u32, idx) *% 20) +% 4);
    rt.r[2] = abi.read32(abi.read32(0x08057BF4) +% (@as(u32, div_arg) << 2));
    rt.r[1] = abi.read16(other_ref);
    if (!abi.call(tail_low.func_0807B454, 0x08057BC5)) return;

    abi.fetches(8);
    rt.r[13] +%= 8;
    popCalleeRegs(false, 1);
    abi.popReturn();
}

/// Set up combat HP gauge OAM A and draw via `0x080574BC` (`0x08058970`).
pub fn func_08058970() callconv(.c) void {
    if (!abi.enter(0x08058970)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const slot_ref = abi.read32(0x08058A40);
    const oam_buf = rt.r[13];
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = oam_buf;
    if (!abi.call(sprite_anim.func_080135FC, 0x08058987)) return;

    abi.fetches(67);
    const anim_base = abi.read32(0x08058A44);
    const side_ref = abi.read32(0x08058A48);
    const other_ref = abi.read32(0x08058A4C);
    const slot_sx: u32 = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    const a_off = slot_sx *% 0x60;
    abi.write32(anim_base +% a_off +% 0x30, abi.read16(side_ref));
    abi.write32(anim_base +% a_off +% 0x34, abi.read16(other_ref));

    const side = abi.read16(side_ref);
    abi.write8(oam_buf +% 3, packOamFlipFlag(side, abi.read8(oam_buf +% 3)));
    abi.write8(oam_buf +% 5, (abi.read8(oam_buf +% 5) & 0x0F) | 0x80);
    const tile_w = abi.read16(abi.read32(0x08058A50) +% (@as(u32, side) *% 36));
    abi.write16(oam_buf +% 4, @truncate((abi.read16(oam_buf +% 4) & abi.read32(0x08058A58)) | (tile_w & abi.read32(0x08058A54))));
    abi.write8(oam_buf +% 5, abi.read8(oam_buf +% 5) | 0xC);

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = abi.read32(oam_buf);
    rt.r[2] = abi.read32(oam_buf +% 4);
    if (!abi.call(sprite_anim.func_08013598, 0x08058A09)) return;

    abi.fetches(23);
    const p_entry = abi.read32(0x08058A5C) +% (abi.read16(other_ref) *% 0x24) +% (abi.read16(side_ref) *% 0xB4);
    rt.r[0] = abi.read16(side_ref);
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(p_entry +% 8)));
    rt.r[3] = @bitCast(abi.signExtend16(abi.read16(p_entry +% 0xA)));
    if (!abi.call(low_peel_8.func_080574BC, 0x08058A33)) return;

    abi.fetches(8);
    rt.r[13] +%= 8;
    popCalleeRegs(false, 1);
    abi.popReturn();
}

/// Set up combat gauge HUD variant B (`0x08058CEC`).
pub fn func_08058CEC() callconv(.c) void {
    if (!abi.enter(0x08058CEC)) return;
    initCombatGaugeHud(.{
        .clear_zero28 = false,
        .pal_tbl_mode = false,
        .pre_hook_9d30 = false,
        .has_unit_arr4 = true,
        .prio_bit = 4,
        .slot_pool = 0x08058E34,
        .anim_pool = 0x08058E38,
        .side_pool = 0x08058E3C,
        .other_pool = 0x08058E40,
        .tbl6c_pool = 0x08058E44,
        .tile_mask_pool = 0x08058E48,
        .oam4_mask_pool = 0x08058E4C,
        .pos_tbl_pool = 0x08058E50,
        .off_tbl_pool = 0x08058E54,
        .arr_off_pool = 0x08058E58,
        .arr_base_pool = 0x08058E5C,
        .ret_get = 0x08058D09,
        .ret_set_oam = 0x08058E0B,
        .ret_hud = 0x08058E25,
    });
}

/// Set up combat HP/ammo bar OAM C (clears `+0x28`, direct `pos_tbl +0x8/+0xA`, `0x0805906C`).
pub fn func_0805906C() callconv(.c) void {
    if (!abi.enter(0x0805906C)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved_r8 = rt.r[8];
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], saved_r8);
    rt.r[13] -%= 8;

    const slot_ref = abi.read32(0x08059168);
    const oam_buf = rt.r[13];
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = oam_buf;
    if (!abi.call(sprite_anim.func_080135FC, 0x08059083)) return;

    abi.fetches(99);
    const anim_base = abi.read32(0x0805916C);
    const side_ref = abi.read32(0x08059170);
    const other_ref = abi.read32(0x08059174);
    const slot_sx: u32 = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    const a_off = slot_sx *% 0x60;
    abi.write32(anim_base +% a_off +% 0x28, 0);
    abi.write32(anim_base +% a_off +% 0x30, abi.read16(side_ref));
    abi.write32(anim_base +% a_off +% 0x34, abi.read16(other_ref));

    abi.write8(oam_buf +% 5, (abi.read8(oam_buf +% 5) & 0x0F) | 0x80);
    const side = abi.read16(side_ref);
    const tbl6c = abi.read32(0x08059178);
    const s6c = @as(u32, side) *% 0x6C;
    const sub_idx = abi.read16(tbl6c +% s6c +% 0x2E);
    const tile_w = abi.read16(tbl6c +% s6c +% 0x3A +% (@as(u32, sub_idx) << 1));
    abi.write16(oam_buf +% 4, @truncate((abi.read16(oam_buf +% 4) & abi.read32(0x08059180)) | (tile_w & abi.read32(0x0805917C))));
    abi.write8(oam_buf +% 5, (abi.read8(oam_buf +% 5) & @as(u8, 0xF3)) | 4);

    const p_entry = abi.read32(0x08059184) +% (abi.read16(other_ref) *% 0x24) +% (@as(u32, side) *% 0xB4);
    const x_delta = abi.read16(abi.read32(0x08059188) +% 0x56 +% (@as(u32, side) << 1));
    const hud_x = (abi.read16(p_entry +% 8) +% x_delta) & 0xFFFF;
    const hud_y = abi.read16(p_entry +% 0xA);

    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[1] = abi.read32(oam_buf);
    rt.r[2] = abi.read32(oam_buf +% 4);
    if (!abi.call(sprite_anim.func_08013598, 0x08059145)) return;

    abi.fetches(14);
    rt.r[0] = abi.read16(side_ref);
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(slot_ref)));
    rt.r[2] = @bitCast(abi.signExtend16(@truncate(hud_x)));
    rt.r[3] = @bitCast(abi.signExtend16(hud_y));
    if (!abi.call(low_peel_8.func_080574BC, 0x0805915D)) return;

    abi.fetches(8);
    rt.r[13] +%= 8;
    popCalleeRegs(true, 1);
    abi.popReturn();
}

/// Spawn battle cue effect with SFX cues (`0x3B`, `0x3C`, `0x51`) and scale `0x100` (`0x0805930C`).
pub fn func_0805930C() callconv(.c) void {
    if (!abi.enter(0x0805930C)) return;
    spawnBattleCueEffect(.{
        .has_sfx = true,
        .write_flag = false,
        .entry_fetches = 43,
        .slot_pool0 = 0x080593D0,
        .slot_pool1 = 0x080593D4,
        .tbl6c_pool = 0x080593D8,
        .tbl24_pool = 0x080593DC,
        .param_tbl_pool = 0x080593E0,
        .tail_scale = 0x100,
        .ret_render = 0x0805935F,
        .ret_anim = 0x08059375,
        .ret_mid0 = 0x0805937B,
        .ret_mid1 = 0x08059381,
        .ret_mid2 = 0x08059387,
        .ret_f0 = 0x08059399,
        .ret_f1 = 0x080593A1,
        .ret_t0 = 0x080593AF,
        .ret_t1 = 0x080593BB,
        .ret_end = 0x080593C3,
    });
}

/// Set up combat gauge HUD variant D (LUT palette + `clear_zero28`, `0x080593E4`).
pub fn func_080593E4() callconv(.c) void {
    if (!abi.enter(0x080593E4)) return;
    initCombatGaugeHud(.{
        .clear_zero28 = true,
        .pal_tbl_mode = true,
        .pre_hook_9d30 = false,
        .has_unit_arr4 = true,
        .prio_bit = 4,
        .slot_pool = 0x08059554,
        .anim_pool = 0x08059558,
        .side_pool = 0x0805955C,
        .other_pool = 0x08059560,
        .pal_tbl_pool = 0x08059564,
        .tbl6c_pool = 0x08059568,
        .tile_mask_pool = 0x0805956C,
        .oam4_mask_pool = 0x08059570,
        .pos_tbl_pool = 0x08059574,
        .off_tbl_pool = 0x08059578,
        .arr_off_pool = 0x0805957C,
        .arr_base_pool = 0x08059580,
        .ret_get = 0x08059401,
        .ret_set_oam = 0x08059529,
        .ret_hud = 0x08059543,
    });
}

/// Set up combat gauge HUD variant E (`clear_zero28` + fixed `0x80` high tile nibble, `0x080598A4`).
pub fn func_080598A4() callconv(.c) void {
    if (!abi.enter(0x080598A4)) return;
    initCombatGaugeHud(.{
        .clear_zero28 = true,
        .pal_tbl_mode = false,
        .pre_hook_9d30 = false,
        .has_unit_arr4 = true,
        .prio_bit = 4,
        .slot_pool = 0x080599F8,
        .anim_pool = 0x080599FC,
        .side_pool = 0x08059A00,
        .other_pool = 0x08059A04,
        .tbl6c_pool = 0x08059A08,
        .tile_mask_pool = 0x08059A0C,
        .oam4_mask_pool = 0x08059A10,
        .pos_tbl_pool = 0x08059A14,
        .off_tbl_pool = 0x08059A18,
        .arr_off_pool = 0x08059A1C,
        .arr_base_pool = 0x08059A20,
        .ret_get = 0x080598C1,
        .ret_set_oam = 0x080599CF,
        .ret_hud = 0x080599E9,
    });
}

/// Spawn battle cue effect via `0x0805743C(a0, 0x23)`, scale `0x180`, write active flag (`0x08059AEC`).
pub fn func_08059AEC() callconv(.c) void {
    if (!abi.enter(0x08059AEC)) return;
    spawnBattleCueEffect(.{
        .has_sfx = false,
        .write_flag = true,
        .entry_fetches = 48,
        .slot_pool0 = 0x08059BBC,
        .slot_pool1 = 0x08059BC0,
        .tbl6c_pool = 0x08059BC4,
        .tbl24_pool = 0x08059BC8,
        .param_tbl_pool = 0x08059BCC,
        .flag_pool = 0x08059BD0,
        .tail_scale = 0x180,
        .ret_render = 0x08059B49,
        .ret_anim = 0x08059B5F,
        .ret_mid0 = 0x08059B67,
        .ret_f0 = 0x08059B77,
        .ret_f1 = 0x08059B7F,
        .ret_t0 = 0x08059B8D,
        .ret_t1 = 0x08059B99,
        .ret_end = 0x08059BAB,
    });
}

/// Set up combat gauge HUD variant F (`pre_hook_9d30`, priority `8`, 2-term offsets, `0x08059BD4`).
pub fn func_08059BD4() callconv(.c) void {
    if (!abi.enter(0x08059BD4)) return;
    initCombatGaugeHud(.{
        .clear_zero28 = true,
        .pal_tbl_mode = false,
        .pre_hook_9d30 = true,
        .has_unit_arr4 = false,
        .prio_bit = 8,
        .slot_pool = 0x08059D08,
        .anim_pool = 0x08059D0C,
        .side_pool = 0x08059D10,
        .other_pool = 0x08059D14,
        .tbl6c_pool = 0x08059D18,
        .tile_mask_pool = 0x08059D1C,
        .oam4_mask_pool = 0x08059D20,
        .pos_tbl_pool = 0x08059D24,
        .off_tbl_pool = 0x08059D28,
        .ret_get = 0x08059BF1,
        .ret_hook = 0x08059CD3,
        .ret_set_oam = 0x08059CE1,
        .ret_hud = 0x08059CF9,
    });
}

/// Upload combat UI sprite bank (primary side order, `0x0805A7A0`).
pub fn func_0805A7A0() callconv(.c) void {
    if (!abi.enter(0x0805A7A0)) return;
    uploadCombatUiTileBank(.{
        .invert_sides = false,
        .write_one_flag = false,
        .entry_fetches = 13,
        .head_lut_pool = 0x0805AAD8,
        .side_pool = 0x0805AADC,
        .bank0_pool = 0x0805AAE0,
        .lut_pool = 0x0805AAE4,
        .bank1_pool = 0x0805AAE8,
        .bank2_pool = 0x0805AAEC,
        .bank3_pool = 0x0805AAF0,
        .ret_head = 0x0805A7B7,
        .ret_items = .{
            0x0805A7CB, 0x0805A7DB, 0x0805A7EF, 0x0805A803, 0x0805A817,
            0x0805A833, 0x0805A84B, 0x0805A865, 0x0805A87F, 0x0805A899,
            0x0805A8AB, 0x0805A8BB, 0x0805A8CB, 0x0805A8DB, 0x0805A8EB,
            0x0805A8FF, 0x0805A913, 0x0805A927, 0x0805A93B, 0x0805A94F,
            0x0805A961, 0x0805A971, 0x0805A981, 0x0805A991, 0x0805A9A1,
            0x0805A9B9, 0x0805A9D1, 0x0805A9E9, 0x0805AA01, 0x0805AA19,
            0x0805AA2B, 0x0805AA3B, 0x0805AA4B, 0x0805AA5B, 0x0805AA6B,
            0x0805AA7F, 0x0805AA93, 0x0805AAA7, 0x0805AABB, 0x0805AACF,
        },
    });
}

/// Upload combat UI sprite bank (inverted side order + set `[0x0805AE2C] = 1`, `0x0805AAF4`).
pub fn func_0805AAF4() callconv(.c) void {
    if (!abi.enter(0x0805AAF4)) return;
    uploadCombatUiTileBank(.{
        .invert_sides = true,
        .write_one_flag = true,
        .entry_fetches = 9,
        .head_lut_pool = null,
        .side_pool = 0x0805AE28,
        .flag_pool = 0x0805AE2C,
        .bank0_pool = 0x0805AE30,
        .lut_pool = 0x0805AE34,
        .bank1_pool = 0x0805AE38,
        .bank2_pool = 0x0805AE3C,
        .bank3_pool = 0x0805AE40,
        .ret_head = 0x0805AB03,
        .ret_items = .{
            0x0805AB23, 0x0805AB37, 0x0805AB4F, 0x0805AB67, 0x0805AB7F,
            0x0805AB93, 0x0805ABA7, 0x0805ABBD, 0x0805ABD3, 0x0805ABE9,
            0x0805ABFF, 0x0805AC13, 0x0805AC27, 0x0805AC3B, 0x0805AC4F,
            0x0805AC5F, 0x0805AC6F, 0x0805AC7F, 0x0805AC8F, 0x0805AC9F,
            0x0805ACB5, 0x0805ACC9, 0x0805ACDD, 0x0805ACF1, 0x0805AD05,
            0x0805AD19, 0x0805AD2D, 0x0805AD41, 0x0805AD55, 0x0805AD69,
            0x0805AD7F, 0x0805AD93, 0x0805ADA7, 0x0805ADBB, 0x0805ADCF,
            0x0805ADDF, 0x0805ADEF, 0x0805ADFF, 0x0805AE0F, 0x0805AE1F,
        },
    });
}

/// Initialize both combat scene panels, side HUDs, and status overlays (`0x0805AE88`).
pub fn func_0805AE88() callconv(.c) void {
    if (!abi.enter(0x0805AE88)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const side_ptr = abi.read32(0x0805AEC4);
    rt.r[4] = side_ptr;
    rt.r[0] = abi.read16(side_ptr);
    if (!abi.call(low_peel_16.func_0805AEF4, 0x0805AE93)) return;

    abi.fetches(5);
    rt.r[0] = abi.read16(side_ptr);
    if (!abi.call(low_peel_12.func_0805B064, 0x0805AE99)) return;

    const steps = [_]struct { f: *const fn () callconv(.c) void, a0: u32, ret: u32 }{
        .{ .f = low_peel_8.func_0805B1A0, .a0 = 0, .ret = 0x0805AE9F },
        .{ .f = low_peel_8.func_0805B1A0, .a0 = 1, .ret = 0x0805AEA5 },
        .{ .f = low_peel_8.func_0805B388, .a0 = 0, .ret = 0x0805AEAB },
        .{ .f = low_peel_8.func_0805B388, .a0 = 1, .ret = 0x0805AEB1 },
        .{ .f = ui.func_0805A5B4, .a0 = 0, .ret = 0x0805AEB7 },
        .{ .f = ui.func_0805A5B4, .a0 = 1, .ret = 0x0805AEBD },
    };
    inline for (steps) |s| {
        abi.fetches(5);
        abi.setRegNz(&rt.r[0], s.a0);
        if (!abi.call(s.f, s.ret)) return;
    }

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn battle animation slot with signed `(x, y)` position and layer/tile priority (`0x08027B7C`).
pub fn func_08027B7C() callconv(.c) void {
    if (!abi.enter(0x08027B7C)) return;
    abi.fetches(3);
    abi.pushLr();
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.fetches(23);
    abi.pushReg(8);
    rt.r[13] -%= 0xC;
    const x: u32 = rt.r[0] & 0xFFFF;
    const y: u32 = rt.r[1] & 0xFFFF;
    var prio: u32 = rt.r[2] & 0xFFFF;
    rt.r[6] = x;
    rt.r[8] = y;
    rt.r[5] = prio;

    abi.write32(rt.r[13] +% 0x0, 0);
    rt.r[0] = abi.read32(0x08027C24);
    rt.r[1] = 0;
    rt.r[2] = abi.read32(0x08027C28);
    rt.r[3] = 0;
    rt.updateNz(0);
    if (!abi.call(low_peel_10.func_080133C0, 0x08027BA9)) return;

    abi.fetches(9);
    const slot: u32 = @bitCast(abi.signExtend8(@truncate(rt.r[0])));
    rt.r[4] = slot;
    rt.r[0] = rt.r[13] +% 0x4;
    rt.r[1] = slot;
    if (!abi.call(sprite_anim.func_080135C8, 0x08027BB7)) return;

    abi.fetches(20);
    rt.r[1] = abi.read32(rt.r[13] +% 0x4);
    const old_flags = abi.read32(rt.r[13] +% 0x8);
    var flags = (old_flags & abi.read32(0x08027C2C)) | (0xC0 << 6);
    prio = (prio +% abi.read32(0x08027C30)) & abi.read32(0x08027C34);
    flags = (flags & abi.read32(0x08027C38)) | prio;
    rt.r[5] = prio;
    rt.r[0] = slot;
    rt.r[2] = flags;
    rt.updateNz(flags);
    if (!abi.call(sprite_anim.func_08013598, 0x08027BDB)) return;

    abi.fetches(13);
    const sx: u32 = @bitCast(abi.signExtend16(@truncate(x)));
    const sy: u32 = @bitCast(abi.signExtend16(@truncate(y)));
    rt.r[6] = sx;
    rt.r[8] = sy;
    rt.r[0] = slot;
    rt.r[1] = sx;
    rt.r[2] = sy;
    rt.updateNz(sy);
    if (!sprite_anim.updateSpriteAnimCall(0x08027BF1)) return;

    abi.fetches(5);
    rt.r[0] = slot;
    if (!abi.call(proc.func_080147B8, 0x08027BF7)) return;

    abi.fetches(5);
    rt.r[0] = slot;
    if (!abi.call(sprite_anim.func_080148DC, 0x08027BFD)) return;

    abi.fetches(8);
    rt.r[5] = 0x200;
    rt.r[0] = slot;
    rt.r[1] = 0x200;
    rt.updateNz(0x200);
    if (!abi.call(sprite_anim.func_08013744, 0x08027C09)) return;

    abi.fetches(6);
    rt.r[0] = slot;
    rt.r[1] = 0x200;
    if (!abi.call(sprite_anim.func_08013794, 0x08027C11)) return;

    abi.fetches(6);
    rt.r[0] = slot;
    rt.r[1] = 0x20;
    rt.updateNz(0x20);
    if (!abi.call(sprite_anim.func_08013878, 0x08027C19)) return;

    abi.fetches(8);
    rt.r[13] +%= 0xC;
    rt.r[8] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    abi.popReturn();
}

/// Apply cursor map focus from `[0x0802FA00]`, reset preview state, and set battle phase to 4 (`0x0802F9E0`).
pub fn func_0802F9E0() callconv(.c) void {
    if (!abi.enter(0x0802F9E0)) return;
    abi.fetches(10);
    abi.pushLr();
    const pos_ptr = abi.read32(0x0802FA00);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(pos_ptr +% 0)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(pos_ptr +% 2)));
    rt.r[2] = 2;
    rt.updateNz(2);
    if (!abi.call(map.func_08020538, 0x0802F9F1)) return;

    abi.fetches(4);
    if (!abi.call(low_peel_7.func_0802E730, 0x0802F9F5)) return;

    abi.fetches(3);
    const phase_ptr = abi.read32(0x0802FA04);
    rt.r[1] = phase_ptr;
    abi.fetches(5);
    rt.r[0] = 4;
    rt.updateNz(4);
    abi.write16(phase_ptr, 4);
    abi.fetches(3);
    const lr = abi.popReg();
    rt.r[0] = lr;
    rt.r[15] = lr;
    rt.recompReturn(lr);
}


test "computeScaledDamage matches Advance Wars integer division formula" {
    try std.testing.expectEqual(@as(i32, 55), computeScaledDamage(0, 55));
    try std.testing.expectEqual(@as(i32, 44), computeScaledDamage(20, 55));
    try std.testing.expectEqual(@as(i32, 0), computeScaledDamage(100, 99));
    try std.testing.expectEqual(@as(i16, 40), computeCounterAttackPower(8, 500));
    try std.testing.expectEqual(@as(i16, 0), computeCounterAttackPower(0, 500));
    try std.testing.expectEqual(@as(i16, 0), computeCounterAttackPower(-3, 500));
    try std.testing.expectEqual(CombatHpPair{ .a = 7, .b = 4 }, clampCombatRemainingHp(7, 4));
    try std.testing.expectEqual(CombatHpPair{ .a = 0, .b = 4 }, clampCombatRemainingHp(-2, 4));
    try std.testing.expectEqual(CombatHpPair{ .a = 5, .b = 0 }, clampCombatRemainingHp(5, -1));
    try std.testing.expectEqual(CombatHpPair{ .a = 1, .b = 0 }, clampCombatRemainingHp(0, 0));
    try std.testing.expectEqual(CombatHpPair{ .a = 1, .b = 0 }, clampCombatRemainingHp(-1, -3));
    try std.testing.expectEqual(CombatHpPair{ .a = 0, .b = 1 }, clampCombatRemainingHp(-4, -1));
}
