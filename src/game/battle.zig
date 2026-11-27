//! Lifted Advance Wars battle damage computation, combat overlays & turn phase helpers (`0x08022220..0x0802C4B4`).

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const bios = @import("bios.zig");
const hw = @import("hw.zig");
const unit = @import("unit.zig");

/// Compute raw scaled battle HP damage: `((100 - defense_pct) * base_damage) / 100`.
pub inline fn computeScaledDamage(defense_pct: i32, base_damage: i32) i32 {
    return @divTrunc((100 - defense_pct) * base_damage, 100);
}

/// Forward to `0x080220F8` (`0x08022220`).
pub fn func_08022220() callconv(.c) void {
    if (!abi.enter(0x08022220)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080220F8, 0x08022227)) return;
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
    if (!abi.call(decls.func_08015824, 0x080224D3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Release proc `*(0x0300_4228)` via `0x08012E14` (`0x080226A4`).
pub fn func_080226A4() callconv(.c) void {
    if (!abi.enter(0x080226A4)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(abi.read32(0x080226B4));
    if (!abi.call(decls.func_08012E14, 0x080226AF)) return;
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
    const def_pct = abi.signExtend16(abi.read16(ctx +% 0xE));
    const atk_pwr = abi.signExtend16(abi.read16(rt.r[1] +% 0xC));
    rt.r[0] = @bitCast((100 -% def_pct) *% atk_pwr);
    rt.r[2] = 0xC;
    abi.setRegNz(&rt.r[1], 100);
    if (!abi.call(bios.func_080796C8, 0x080234B9)) return;

    abi.fetches(12);
    const dmg = rt.r[0];
    abi.write16(ctx +% 0x12, @truncate(dmg));
    const unit_ptr = abi.read32(ctx);
    const cur_hp: u32 = abi.read8(unit_ptr +% 4) & 0x7F;
    rt.cpuSub(&rt.r[1], cur_hp, dmg, true);
    abi.write16(ctx +% 8, @truncate(rt.r[1]));

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Forward signed 16-bit pair `(i16(r0), i16(r1))` to `0x08023550` (`0x08023888`).
pub fn func_08023888() callconv(.c) void {
    if (!abi.enter(0x08023888)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(rt.r[1])));
    rt.updateNz(rt.r[1]);
    if (!abi.call(decls.func_08023550, 0x08023897)) return;
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
    if (!abi.call(decls.func_08023550, 0x080238AB)) return;
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
    if (!abi.call(decls.func_08023AA8, 0x08023B93)) return;

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
    const list_base = abi.read32(abi.read32(0x08023D50));
    const entry = list_base +% (@as(u32, idx) *% 12);
    rt.r[0] = entry;
    rt.r[1] = abi.read8(entry +% 2);
    rt.r[2] = abi.read8(entry +% 3);
    if (!abi.call(decls.func_08023BFC, 0x08023D47)) return;

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
    if (!abi.call(decls.func_0801E188, 0x08024D95)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward to `0x08024D9C` (`0x08024EB8`).
pub fn func_08024EB8() callconv(.c) void {
    if (!abi.enter(0x08024EB8)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08024D9C, 0x08024EBF)) return;
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
    if (!abi.call(decls.func_08026CA0, 0x08026C99)) return;
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
    if (!abi.call(decls.func_0802C11C, 0x08027593)) return;
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
    if (!abi.call(decls.func_0800FFA8, 0x08027E33)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Update HUD card for `[0x0300_36AC]` via `0x080199A0` (`0x08027F44`).
pub fn func_08027F44() callconv(.c) void {
    if (!abi.enter(0x08027F44)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read16(abi.read32(0x08027F54));
    if (!abi.call(decls.func_080199A0, 0x08027F4F)) return;
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
    if (!abi.call(decls.func_08026934, 0x08029F81)) return;
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
    if (!abi.call(decls.func_0802928C, 0x0802A99B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward `0` to `0x08026FC8` (`0x0802A9A8`).
pub fn func_0802A9A8() callconv(.c) void {
    if (!abi.enter(0x0802A9A8)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_08026FC8, 0x0802A9B1)) return;
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
    if (!abi.call(hw.func_0801B888, 0x0802BF67)) return;
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
    if (!abi.call(decls.func_0802BFB0, 0x0802C04B)) return;
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
    if (!abi.call(decls.func_08015824, 0x0802C0B7)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn call2C368WithId(comptime id: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], id);
    if (!abi.call(decls.func_0802C368, ret_addr)) return;
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
    if (!abi.call(decls.func_0802E508, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward directly to `0x08019608` battle UI refresh (`0x0802D724`).
pub fn func_0802D724() callconv(.c) void {
    if (!abi.enter(0x0802D724)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019608, 0x0802D72B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Record battle animation parameter `u8(r1)`, refresh via `0x08019608`, and set phase `2` (`0x0802D968`).
pub fn func_0802D968() callconv(.c) void {
    if (!abi.enter(0x0802D968)) return;
    abi.fetches(9);
    abi.pushLr();
    abi.write32(abi.read32(0x0802D980), rt.r[1] & 0xFF);
    if (!abi.call(decls.func_08019608, 0x0802D977)) return;
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
    if (!abi.call(decls.func_0802E558, 0x0802E5FB)) return;
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
    if (!abi.call(decls.func_08018C1C, 0x0802EF25)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Advance unit/battle state via `0x08022148` and enter phase `8` (`0x0802F634`).
pub fn func_0802F634() callconv(.c) void {
    if (!abi.enter(0x0802F634)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08022148, 0x0802F63B)) return;
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
    if (!abi.call(decls.func_080243DC, 0x08066AD7)) return;

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
    if (!abi.call(decls.func_0801C120, 0x08066BAB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear unit selection via `0x0802615C([0x08066CA4]+6)` and set phases `(2, 0)` (`0x08066C88`).
pub fn func_08066C88() callconv(.c) void {
    if (!abi.enter(0x08066C88)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read8(abi.read32(0x08066CA4) +% 6);
    if (!abi.call(decls.func_0802615C, 0x08066C93)) return;

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
    if (!abi.call(decls.func_0802C4A8, 0x08066E83)) return;

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
    if (!abi.call(decls.func_0802C49C, 0x08066E9F)) return;

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
    if (!abi.call(decls.func_0802AAF8, 0x08066EBF)) return;
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
    if (!abi.call(decls.func_08019608, ret1)) return;
    abi.fetches(4);
    if (!abi.call(next_fn, ret2)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn runBattleAction19A1C(comptime next_fn: fn () callconv(.c) void, comptime r0: u32, comptime r1: u32, comptime r2: u32) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019A1C, r0)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08019608, r1)) return;
    abi.fetches(4);
    if (!abi.call(next_fn, r2)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Set battle flag `[0x0802D748] = u8(r1)`, open overlay `0x08019608`, and trigger `0x0802E650` (`0x0802D730`).
pub fn func_0802D730() callconv(.c) void {
    if (!abi.enter(0x0802D730)) return;
    writeArg1Byte19608AndThen(0x0802D748, 0x0802D73F, decls.func_0802E650, 0x0802D743);
}

/// Set battle flag `[0x0802D764] = u8(r1)`, open overlay `0x08019608`, and trigger `0x0802E650` (`0x0802D74C`).
pub fn func_0802D74C() callconv(.c) void {
    if (!abi.enter(0x0802D74C)) return;
    writeArg1Byte19608AndThen(0x0802D764, 0x0802D75B, decls.func_0802E650, 0x0802D75F);
}

/// Dispatch battle menu entry `[0x0802D960][read8([0x0802D964]+2) - 0x82]` via `0x08018400` (`0x0802D944`).
pub fn func_0802D944() callconv(.c) void {
    if (!abi.enter(0x0802D944)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019608, 0x0802D94B)) return;
    abi.fetches(11);
    const idx = abi.read8(abi.read32(0x0802D964) +% 2) -% 0x82;
    rt.r[1] = abi.read32(0x0802D960);
    rt.r[0] = abi.read32((idx << 2) +% rt.r[1]);
    if (!abi.call(decls.func_08018400, 0x0802D95D)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Close battle submenu (`0x08019A1C`, `0x08019608`) and run `0x0802E668` (`0x0802DEBC`).
pub fn func_0802DEBC() callconv(.c) void {
    if (!abi.enter(0x0802DEBC)) return;
    runBattleAction19A1C(decls.func_0802E668, 0x0802DEC3, 0x0802DEC7, 0x0802DECB);
}

/// Close battle submenu (`0x08019A1C`, `0x08019608`) and run `0x0802E6BC` (`0x0802DED0`).
pub fn func_0802DED0() callconv(.c) void {
    if (!abi.enter(0x0802DED0)) return;
    runBattleAction19A1C(decls.func_0802E6BC, 0x0802DED7, 0x0802DEDB, 0x0802DEDF);
}

/// Set battle flag `[0x0802E008] = u8(r1)`, open overlay `0x08019608`, and trigger `0x0802C530` (`0x0802DFF0`).
pub fn func_0802DFF0() callconv(.c) void {
    if (!abi.enter(0x0802DFF0)) return;
    writeArg1Byte19608AndThen(0x0802E008, 0x0802DFFF, decls.func_0802C530, 0x0802E003);
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
    if (!abi.call(decls.func_08019608, 0x0802E01B)) return;
    abi.fetches(7);
    rt.r[0] = abi.read8(abi.read32(0x0802E02C));
    abi.setRegNz(&rt.r[1], 0x10);
    if (!abi.call(decls.func_08018D84, 0x0802E025)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Set battle flag `[0x0802E048] = u8(r1)`, open overlay `0x08019608`, and trigger `0x0802C5A0` (`0x0802E030`).
pub fn func_0802E030() callconv(.c) void {
    if (!abi.enter(0x0802E030)) return;
    writeArg1Byte19608AndThen(0x0802E048, 0x0802E03F, decls.func_0802C5A0, 0x0802E043);
}

/// Close menu `0x08019608`, query unit state `0x08015E3C`, and invoke `0x08015EF8` (`0x0802E128`).
pub fn func_0802E128() callconv(.c) void {
    if (!abi.enter(0x0802E128)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08019608, 0x0802E12F)) return;
    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x0802E144) +% 1);
    if (!abi.call(decls.func_08015E3C, 0x0802E137)) return;
    abi.fetches(7);
    const val: u16 = @bitCast(@as(i16, @as(i8, @bitCast(@as(u8, @truncate(rt.r[0]))))));
    abi.setRegNz(&rt.r[0], val);
    if (!abi.call(decls.func_08015EF8, 0x0802E141)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Reset battle window `0x08026724` and open overlay `0x08019608` (`0x0802E2A4`).
pub fn func_0802E2A4() callconv(.c) void {
    if (!abi.enter(0x0802E2A4)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08026724, 0x0802E2AB)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08019608, 0x0802E2AF)) return;
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
    if (!abi.call(decls.func_08029BEC, 0x0802E2FB)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08019608, 0x0802E2FF)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08035220, 0x0802E303)) return;
    abi.fetches(4);
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08022220, .{ .name = "func_08022220", .linkage = .strong });
        @export(&func_08066AC8, .{ .name = "func_08066AC8", .linkage = .strong });
        @export(&func_08066BA0, .{ .name = "func_08066BA0", .linkage = .strong });
        @export(&func_08066C88, .{ .name = "func_08066C88", .linkage = .strong });
        @export(&func_08066E7C, .{ .name = "func_08066E7C", .linkage = .strong });
        @export(&func_08066E98, .{ .name = "func_08066E98", .linkage = .strong });
        @export(&func_08066EB4, .{ .name = "func_08066EB4", .linkage = .strong });
        @export(&func_080224C8, .{ .name = "func_080224C8", .linkage = .strong });
        @export(&func_080226A4, .{ .name = "func_080226A4", .linkage = .strong });
        @export(&func_080234A0, .{ .name = "func_080234A0", .linkage = .strong });
        @export(&func_08023888, .{ .name = "func_08023888", .linkage = .strong });
        @export(&func_0802389C, .{ .name = "func_0802389C", .linkage = .strong });
        @export(&func_08023B88, .{ .name = "func_08023B88", .linkage = .strong });
        @export(&func_08023D2C, .{ .name = "func_08023D2C", .linkage = .strong });
        @export(&func_08024D88, .{ .name = "func_08024D88", .linkage = .strong });
        @export(&func_08024EB8, .{ .name = "func_08024EB8", .linkage = .strong });
        @export(&func_08026C88, .{ .name = "func_08026C88", .linkage = .strong });
        @export(&func_08026F30, .{ .name = "func_08026F30", .linkage = .strong });
        @export(&func_08026F50, .{ .name = "func_08026F50", .linkage = .strong });
        @export(&func_08027578, .{ .name = "func_08027578", .linkage = .strong });
        @export(&func_08027E18, .{ .name = "func_08027E18", .linkage = .strong });
        @export(&func_08027F44, .{ .name = "func_08027F44", .linkage = .strong });
        @export(&func_0802962C, .{ .name = "func_0802962C", .linkage = .strong });
        @export(&func_08029F6C, .{ .name = "func_08029F6C", .linkage = .strong });
        @export(&func_0802A97C, .{ .name = "func_0802A97C", .linkage = .strong });
        @export(&func_0802A9A8, .{ .name = "func_0802A9A8", .linkage = .strong });
        @export(&func_0802BF48, .{ .name = "func_0802BF48", .linkage = .strong });
        @export(&func_0802C034, .{ .name = "func_0802C034", .linkage = .strong });
        @export(&func_0802C0AC, .{ .name = "func_0802C0AC", .linkage = .strong });
        @export(&func_0802C49C, .{ .name = "func_0802C49C", .linkage = .strong });
        @export(&func_0802C4A8, .{ .name = "func_0802C4A8", .linkage = .strong });
        @export(&func_0802C4B4, .{ .name = "func_0802C4B4", .linkage = .strong });
        @export(&func_0802D724, .{ .name = "func_0802D724", .linkage = .strong });
        @export(&func_0802D968, .{ .name = "func_0802D968", .linkage = .strong });
        @export(&func_0802E5B4, .{ .name = "func_0802E5B4", .linkage = .strong });
        @export(&func_0802E5C4, .{ .name = "func_0802E5C4", .linkage = .strong });
        @export(&func_0802E5D4, .{ .name = "func_0802E5D4", .linkage = .strong });
        @export(&func_0802E5E4, .{ .name = "func_0802E5E4", .linkage = .strong });
        @export(&func_0802E5F4, .{ .name = "func_0802E5F4", .linkage = .strong });
        @export(&func_0802EF18, .{ .name = "func_0802EF18", .linkage = .strong });
        @export(&func_0802F634, .{ .name = "func_0802F634", .linkage = .strong });
        @export(&func_0802D730, .{ .name = "func_0802D730", .linkage = .strong });
        @export(&func_0802D74C, .{ .name = "func_0802D74C", .linkage = .strong });
        @export(&func_0802D944, .{ .name = "func_0802D944", .linkage = .strong });
        @export(&func_0802DEBC, .{ .name = "func_0802DEBC", .linkage = .strong });
        @export(&func_0802DED0, .{ .name = "func_0802DED0", .linkage = .strong });
        @export(&func_0802DFF0, .{ .name = "func_0802DFF0", .linkage = .strong });
        @export(&func_0802E00C, .{ .name = "func_0802E00C", .linkage = .strong });
        @export(&func_0802E030, .{ .name = "func_0802E030", .linkage = .strong });
        @export(&func_0802E128, .{ .name = "func_0802E128", .linkage = .strong });
        @export(&func_0802E2A4, .{ .name = "func_0802E2A4", .linkage = .strong });
        @export(&func_0802E2EC, .{ .name = "func_0802E2EC", .linkage = .strong });
    }
}

test "computeScaledDamage matches Advance Wars integer division formula" {
    try std.testing.expectEqual(@as(i32, 55), computeScaledDamage(0, 55));
    try std.testing.expectEqual(@as(i32, 44), computeScaledDamage(20, 55));
    try std.testing.expectEqual(@as(i32, 0), computeScaledDamage(100, 99));
}
