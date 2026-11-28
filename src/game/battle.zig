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
    if (!abi.call(decls.func_08020D6C, 0x0802E717)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080381C4, 0x0802E71B)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08021DF8, 0x0802E71F)) return;
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
    if (!abi.call(decls.func_0802E984, 0x0802ECCD)) return;
    abi.fetches(7);
    const slot_i32: u32 = @bitCast(abi.signExtend16(@truncate(slot_u16)));
    rt.r[4] = slot_i32;
    abi.setRegNz(&rt.r[0], slot_i32);
    if (!abi.call(decls.func_0802EA80, 0x0802ECD7)) return;
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
    if (!abi.call(decls.func_080104B0, 0x0802EFDF)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080104D4, 0x0802EFE3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Play cancel cue `0x76` and close submenu via `0x0802C694` (`0x0802F5C4`).
pub fn func_0802F5C4() callconv(.c) void {
    if (!abi.enter(0x0802F5C4)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0x76);
    if (!abi.call(decls.func_0803D880, 0x0802F5CD)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0802C694, 0x0802F5D1)) return;
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
    if (!abi.call(decls.func_08020538, 0x0802FA51)) return;

    abi.fetches(7);
    abi.write8(abi.read32(0x0802FA68), 1);
    if (!abi.call(decls.func_08026060, 0x0802FA5B)) return;

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
    if (!abi.call(decls.func_0800FDA4, 0x0802FCA1)) return;

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
    if (!abi.call(decls.func_0807A8A0, 0x08030DDD)) return;

    abi.fetches(9);
    rt.r[4] = idx << 1;
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(rt.r[13] +% (idx << 1))));
    rt.r[1] = 0;
    if (!abi.call(decls.func_0803D880, 0x08030DEB)) return;

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
    if (!abi.call(decls.func_080243DC, 0x08066AF7)) return;

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
    if (!abi.call(decls.func_0802615C, 0x08066CBB)) return;

    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x08066CCC));
    if (!abi.call(decls.func_08013BD0, 0x08066CC3)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Refresh tactical board `0x08020D6C` and spawn combat proc `[0x08066CE4]` (`0x08066CD0`).
pub fn func_08066CD0() callconv(.c) void {
    if (!abi.enter(0x08066CD0)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08020D6C, 0x08066CD7)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x08066CE4);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, 0x08066CDF)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Run battle scene step `0x080685D0` then post-step `0x08061DA0` (`0x08068A54`).
pub fn func_08068A54() callconv(.c) void {
    if (!abi.enter(0x08068A54)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080685D0, 0x08068A5B)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08061DA0, 0x08068A5F)) return;
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
    if (!abi.call(decls.func_0806959C, 0x0806973D)) return;

    abi.fetches(5);
    abi.copyRegFlags(&rt.r[0], slot_id);
    if (!abi.call(decls.func_080691FC, 0x08069743)) return;

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
    if (!abi.call(decls.func_0800FFA8, 0x0806A2DF)) return;

    abi.fetches(8);
    rt.r[0] = abi.read32(0x0806A2FC);
    abi.setRegNz(&rt.r[1], @as(u32, 0x80) << 2);
    abi.setRegNz(&rt.r[2], 0x40);
    if (!abi.call(decls.func_08011330, 0x0806A2EB)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0xA);
    if (!abi.call(decls.func_0806CB34, 0x0806A2F1)) return;

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
    if (!abi.call(decls.func_08010C70, 0x0806A7CB)) return;

    abi.fetches(5);
    abi.copyRegFlags(&rt.r[0], proc_ptr);
    if (!abi.call(decls.func_0806A7EC, 0x0806A7D1)) return;

    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x0806A7E8));
    if (!abi.call(decls.func_08013BD0, 0x0806A7D9)) return;

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
    if (!abi.call(decls.func_080498C4, 0x0806A8A3)) return;

    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x0806A8B0));
    if (!abi.call(decls.func_08013BD0, 0x0806A8AB)) return;

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
    if (!abi.call(decls.func_0806A324, 0x0806ACA5)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0806A300, 0x0806ACA9)) return;

    abi.fetches(7);
    abi.write16(proc_ptr +% 0x44, 8);
    rt.r[4] = proc_ptr +% 0x44;
    abi.setRegNz(&rt.r[0], 8);
    if (!abi.call(decls.func_0806B2EC, 0x0806ACB3)) return;

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
    if (!abi.call(decls.func_0806AEB0, 0x0806AEA3)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0806B40C, 0x0806AEA7)) return;
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
    if (!abi.call(decls.func_08013BD0, 0x0806B125)) return;

    abi.fetches(9);
    abi.write16(proc_ptr +% 0x44, 8);
    abi.copyRegFlags(&rt.r[0], proc_ptr);
    if (!abi.call(decls.func_0806B13C, 0x0806B133)) return;

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
    if (!abi.call(decls.func_08019A1C, r1)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08019608, r2)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_080351E8, r3)) return;
    if (tail_fn) |fn_ptr| {
        abi.fetches(4);
        if (!abi.call(fn_ptr, r4)) return;
    } else {
        abi.fetches(6);
        rt.r[0] = abi.read32(tail_proc_ref);
        abi.setRegNz(&rt.r[1], 0);
        if (!abi.call(decls.func_0801320C, r4)) return;
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
    if (!abi.call(decls.func_0802C11C, 0x0802BFD5)) return;

    abi.fetches(11);
    rt.r[0] = (@as(u32, @bitCast(base_x_i32)) +% 0xE) & 0xFFFF;
    abi.setRegNz(&rt.r[1], 5);
    rt.r[2] = abi.read16(abi.read32(0x0802C020));
    if (!abi.call(decls.func_0802C11C, 0x0802BFE7)) return;

    abi.fetches(12);
    const aux_pal = abi.read32(0x0802C024);
    rt.r[5] = aux_pal;
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(@as(u32, @bitCast(base_x_i32)) +% 0x16)));
    abi.setRegNz(&rt.r[1], 5);
    rt.r[2] = aux_pal;
    rt.r[3] = abi.read32(0x0802C028);
    if (!abi.call(decls.func_0801B888, 0x0802BFFB)) return;

    abi.fetches(11);
    rt.r[4] = @bitCast(abi.signExtend16(@truncate(@as(u32, @bitCast(base_x_i32)) +% 0x4E)));
    abi.copyRegFlags(&rt.r[0], rt.r[4]);
    abi.setRegNz(&rt.r[1], 6);
    rt.r[2] = aux_pal;
    rt.r[3] = abi.read32(0x0802C02C);
    if (!abi.call(decls.func_0801B888, 0x0802C00D)) return;

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
    enterBattleSubmenu(0x0802DF04, 0, decls.func_08040AEC, 0x0802DEF3, 0x0802DEF7, 0x0802DEFB, 0x0802DEFF);
}

/// Set `[0x0802DF28] = u8(r1)`, reset UI, and enter `0x08041F20` (`0x0802DF08`).
pub fn func_0802DF08() callconv(.c) void {
    if (!abi.enter(0x0802DF08)) return;
    enterBattleSubmenu(0x0802DF28, 0, decls.func_08041F20, 0x0802DF17, 0x0802DF1B, 0x0802DF1F, 0x0802DF23);
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
    if (!abi.call(decls.func_0801D048, 0x0802E405)) return;

    abi.fetches(11);
    const cur = abi.read32(0x0802E430);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(cur)));
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(cur +% 2)));
    rt.r[2] = abi.read32(abi.read32(0x0802E434));
    if (!abi.call(decls.func_0801E5F8, 0x0802E417)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x0802E438);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, 0x0802E41F)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08019608, 0x0802E423)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08022074, 0x0802E427)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08035220, 0x0802E42B)) return;

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
    if (!abi.call(decls.func_0802E4E8, 0x0802E513)) return;

    abi.fetches(10);
    const val = abi.signExtend16(@truncate(rt.r[0]));
    rt.r[4] = @bitCast(val);
    rt.r[0] = @bitCast(val);
    abi.setRegNz(&rt.r[1], 0xE);
    abi.setRegNz(&rt.r[2], 0xD);
    abi.setRegNz(&rt.r[3], 6);
    if (!abi.call(decls.func_080197D8, 0x0802E523)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x0802E550);
    if (!abi.call(decls.func_0801329C, 0x0802E529)) return;

    abi.fetches(17);
    const row_y: u32 = @bitCast(abi.signExtend16(@truncate(@as(u32, @bitCast(val +% 1)))));
    rt.r[4] = row_y;
    abi.write32(rt.r[13], 0x4000);
    abi.write32(rt.r[13] +% 4, 0x100);
    rt.r[0] = row_y;
    abi.setRegNz(&rt.r[1], 0xF);
    rt.r[2] = abi.read32(0x0802E554);
    rt.r[3] = a0;
    if (!abi.call(decls.func_08012340, 0x0802E547)) return;

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
    if (!abi.call(decls.func_0802E4E8, 0x0802E561)) return;

    abi.fetches(6);
    const row_y = rt.r[0] & 0xFFFF;
    rt.r[4] = row_y;
    rt.r[0] = abi.read32(0x0802E5A4);
    if (!abi.call(decls.func_0801329C, 0x0802E569)) return;

    abi.fetches(15);
    rt.r[5] = 6;
    abi.write32(rt.r[13], 6);
    abi.write32(rt.r[13] +% 4, 0x174);
    rt.r[0] = abi.read32(0x0802E5A8);
    rt.r[1] = row_y;
    abi.setRegNz(&rt.r[2], 0xE);
    abi.setRegNz(&rt.r[3], 0xD);
    if (!abi.call(decls.func_08010C70, 0x0802E583)) return;

    abi.fetches(11);
    abi.write32(rt.r[13], 6);
    abi.write32(rt.r[13] +% 4, abi.read32(0x0802E5B0));
    rt.r[0] = abi.read32(0x0802E5AC);
    rt.r[1] = row_y;
    abi.setRegNz(&rt.r[2], 0xE);
    abi.setRegNz(&rt.r[3], 0xD);
    if (!abi.call(decls.func_08010C70, 0x0802E595)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08011804, 0x0802E599)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08011824, 0x0802E59D)) return;

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
    if (!abi.call(decls.func_08026FC8, 0x0802EF05)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08021E1C, 0x0802EF09)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    if (!abi.call(decls.func_08012830, 0x0802EF0F)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08035230, 0x0802EF13)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Finalize combat/supply cleanup (`0x080212B8`, `0x08021010`, `0x08021398`, `0x0802EF2C`) (`0x0802F5D4`).
pub fn func_0802F5D4() callconv(.c) void {
    if (!abi.enter(0x0802F5D4)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080212B8, 0x0802F5DB)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08021010, 0x0802F5DF)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08021398, 0x0802F5E3)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_0802EF2C, 0x0802F5E7)) return;
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
    if (!abi.call(decls.func_0800FE24, 0x0802FD59)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x0802FDB4);
    rt.r[1] = abi.read32(0x0802FDB8);
    if (!abi.call(decls.func_0800FE24, 0x0802FD61)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x0802FDBC);
    abi.setRegNz(&rt.r[1], 0);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, 0x0802FD6B)) return;

    abi.fetches(15);
    abi.write16(abi.read32(0x0802FDC0), 0);
    abi.write16(abi.read32(0x0802FDC4), 0);
    const p2 = abi.read32(0x0802FDC8);
    abi.write16(p2, 0);
    abi.write16(p2 -% 0xC, 0);
    rt.r[4] = 0;
    abi.setRegNz(&rt.r[0], 7);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0807AE50, 0x0802FD85)) return;

    abi.fetches(6);
    abi.setRegNz(&rt.r[0], 6);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0807AE50, 0x0802FD8D)) return;

    abi.fetches(7);
    abi.setRegNz(&rt.r[0], 1);
    rt.r[1] = 0 -% @as(u32, 0xC1);
    if (!abi.call(decls.func_0807AE60, 0x0802FD97)) return;

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
    if (!abi.call(decls.func_08021DF8, 0x0802EC43)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08021E04, 0x0802EC47)) return;

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
    if (!abi.call(decls.func_0802E9C8, 0x0802EC75)) return;

    abi.fetches(8);
    rt.r[0] = 1;
    rt.r[1] = 4;
    rt.r[2] = 0xF;
    rt.r[3] = 0x10;
    if (!abi.call(decls.func_080197D8, 0x0802EC81)) return;

    abi.fetches(5);
    rt.r[0] = 0;
    if (!abi.call(decls.func_0802EA80, 0x0802EC87)) return;

    abi.fetches(6);
    rt.r[0] = 8;
    rt.r[1] = 0x28;
    if (!abi.call(decls.func_0802055C, 0x0802EC8F)) return;

    abi.fetches(5);
    rt.r[0] = 0x65;
    if (!abi.call(decls.func_0803D880, 0x0802EC95)) return;

    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x0802ECBC));
    if (!abi.call(decls.func_0803CC90, 0x0802EC9D)) return;

    abi.fetches(5);
    rt.r[0] = 1;
    if (!abi.call(decls.func_08026FC8, 0x0802ECA3)) return;

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
    if (!abi.call(decls.func_08053A08, 0x080539DB)) return;

    abi.fetches(8);
    rt.r[0] = rt.r[5];
    rt.r[1] = rt.r[4];
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(rt.r[6])));
    if (!abi.call(decls.func_08052E2C, 0x080539E7)) return;

    abi.fetches(8);
    rt.r[0] = rt.r[5];
    rt.r[1] = rt.r[4];
    rt.r[2] = @bitCast(abi.signExtend16(abi.read16(rt.r[6])));
    if (!abi.call(decls.func_08054BA8, 0x080539F3)) return;

    abi.fetches(6);
    rt.r[0] = rt.r[5];
    rt.r[1] = rt.r[4];
    if (!abi.call(decls.func_0805DD00, 0x080539FB)) return;

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
        .{ decls.func_0803D920, @as(u32, 0x08059E57) },
        .{ decls.func_0805B5E0, @as(u32, 0x08059E5B) },
        .{ decls.func_0805B9CC, @as(u32, 0x08059E5F) },
        .{ decls.func_0805EA78, @as(u32, 0x08059E63) },
        .{ decls.func_0800F894, @as(u32, 0x08059E67) },
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
        .{ decls.func_0805B1A0, @as(u32, 0), @as(u32, 0x0805AED1) },
        .{ decls.func_0805B1A0, @as(u32, 1), @as(u32, 0x0805AED7) },
        .{ decls.func_0805B388, @as(u32, 0), @as(u32, 0x0805AEDD) },
        .{ decls.func_0805B388, @as(u32, 1), @as(u32, 0x0805AEE3) },
        .{ decls.func_0805A5B4, @as(u32, 0), @as(u32, 0x0805AEE9) },
        .{ decls.func_0805A5B4, @as(u32, 1), @as(u32, 0x0805AEEF) },
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
    if (!abi.call(decls.func_08036520, 0x0806696F)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08023EDC, 0x08066973)) return;

    abi.fetches(7);
    rt.r[4] = abi.read32(0x08066998);
    rt.r[0] = abi.read32(0x08066994);
    rt.r[1] = rt.r[4];
    if (!abi.call(decls.func_0803487C, 0x0806697D)) return;

    abi.fetches(5);
    rt.r[0] = rt.r[4];
    if (!abi.call(decls.func_080241B0, 0x08066983)) return;

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
    if (!abi.call(decls.func_08068AE0, 0x08068AC3)) return;
    const layers = [_][3]u32{
        .{ 0, 1, 0x08068ACB },
        .{ 1, 6, 0x08068AD3 },
        .{ 2, 5, 0x08068ADB },
    };
    inline for (layers) |l| {
        abi.fetches(6);
        rt.r[0] = l[0];
        rt.r[1] = l[1];
        if (!abi.call(decls.func_08068B1C, l[2])) return;
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

    if (!abi.call(decls.func_08044644, 0x0806A5E3)) return;

    abi.fetches(8);
    abi.write16(abi.read32(0x0806A610) +% 2, @truncate(rt.r[0]));
    rt.r[0] = abi.read32(0x0806A614);
    rt.r[1] = 0;
    if (!abi.call(decls.func_0806A8F4, 0x0806A5EF)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x0806A618);
    if (!abi.call(decls.func_0801329C, 0x0806A5F5)) return;

    abi.fetches(6);
    rt.r[4] = abi.read32(0x0806A61C);
    rt.r[0] = rt.r[4];
    if (!abi.call(decls.func_0801329C, 0x0806A5FD)) return;

    abi.fetches(6);
    rt.r[0] = rt.r[4];
    rt.r[1] = 1;
    if (!abi.call(decls.func_0801320C, 0x0806A605)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x0806A620);
    if (!abi.call(decls.func_0801329C, 0x0806A60B)) return;

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
    if (!abi.call(decls.func_0806CF50, 0x0806AB7D)) return;

    abi.fetches(15);
    const sx: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x44)));
    const sy: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x46)));
    abi.write32(rt.r[13] +% 0, sy);
    rt.r[0] = abi.read32(rt.r[7] +% 0);
    rt.r[1] = abi.read32(rt.r[7] +% 4);
    rt.r[2] = abi.read32(rt.r[7] +% 8);
    rt.r[3] = sx;
    if (!abi.call(decls.func_0806A988, 0x0806AB97)) return;

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
    if (!abi.call(decls.func_0806CB50, 0x0806B417)) return;
    abi.fetches(5);
    rt.r[0] = rt.r[4];
    if (!abi.call(decls.func_0806CBAC, 0x0806B41D)) return;

    abi.fetches(6);
    rt.r[4] = abi.read32(0x0806B434);
    rt.r[0] = rt.r[4];
    if (!abi.call(decls.func_0806CB50, 0x0806B425)) return;
    abi.fetches(5);
    rt.r[0] = rt.r[4];
    if (!abi.call(decls.func_0806CBAC, 0x0806B42B)) return;

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
    if (!abi.call(decls.func_0801320C, 0x0806BDD3)) return;

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
    if (!abi.call(decls.func_0806BC1C, 0x0806BE07)) return;

    abi.fetches(7);
    rt.r[1] = @bitCast(abi.signExtend16(abi.read16(rt.r[7])));
    rt.r[0] = rt.r[4];
    if (!abi.call(decls.func_0806B840, 0x0806BE11)) return;

    abi.fetches(5);
    rt.r[0] = rt.r[4];
    if (!abi.call(decls.func_0806BADC, 0x0806BE17)) return;

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
    if (!abi.call(decls.func_0801320C, 0x0806BEA3)) return;

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
    if (!abi.call(decls.func_0806BC1C, 0x0806BEF7)) return;

    abi.fetches(12);
    const slot_s: u32 = @bitCast(abi.signExtend16(abi.read16(rt.r[7])));
    const is_nonzero: u32 = @bitCast(@as(i32, @bitCast((0 -% slot_s) | slot_s)) >> 31);
    rt.r[1] = is_nonzero & 4;
    rt.r[0] = rt.r[4];
    if (!abi.call(decls.func_0806B840, 0x0806BF0B)) return;

    abi.fetches(5);
    rt.r[0] = rt.r[4];
    if (!abi.call(decls.func_0806BADC, 0x0806BF11)) return;

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
    if (!abi.call(decls.func_0801B888, 0x0806C3A3)) return;

    abi.fetches(18);
    const phase1: u32 = abi.read8(rt.r[5]);
    rt.r[0] = @bitCast(abi.signExtend16(abi.read16(rt.r[4] +% 0x24)));
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(abi.read32(rt.r[4] +% 0x28) +% 0x10)));
    rt.r[2] = rt.r[6];
    rt.r[3] = ((phase1 << 4) +% abi.read32(0x0806C3D0)) & 0xFFFF;
    if (!abi.call(decls.func_0801B888, 0x0806C3C3)) return;

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
    if (!abi.call(decls.func_0801320C, 0x0806C3EB)) return;

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
    if (!abi.call(decls.func_0806CC18, 0x0806C40B)) return;

    abi.fetches(8);
    const cnt1: u32 = abi.read16(rt.r[4]);
    rt.r[0] = rt.r[5];
    rt.r[1] = (cnt1 << 4) +% 8;
    if (!abi.call(decls.func_0806CC4C, 0x0806C417)) return;

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
    if (!abi.call(decls.func_0806CB50, 0x0806C915)) return;
    const steps = .{
        .{ decls.func_08049834, @as(u32, 0x0806C919) },
        .{ decls.func_0806C494, @as(u32, 0x0806C91D) },
        .{ decls.func_0806A8E4, @as(u32, 0x0806C921) },
        .{ decls.func_0806C368, @as(u32, 0x0806C925) },
    };
    inline for (steps) |s| {
        abi.fetches(4);
        if (!abi.call(s[0], s[1])) return;
    }
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
        @export(&func_0802E710, .{ .name = "func_0802E710", .linkage = .strong });
        @export(&func_0802ECC0, .{ .name = "func_0802ECC0", .linkage = .strong });
        @export(&func_0802EFD8, .{ .name = "func_0802EFD8", .linkage = .strong });
        @export(&func_0802F5C4, .{ .name = "func_0802F5C4", .linkage = .strong });
        @export(&func_0802FA40, .{ .name = "func_0802FA40", .linkage = .strong });
        @export(&func_0802FC70, .{ .name = "func_0802FC70", .linkage = .strong });
        @export(&func_080305E4, .{ .name = "func_080305E4", .linkage = .strong });
        @export(&func_08030DC8, .{ .name = "func_08030DC8", .linkage = .strong });
        @export(&func_08066AE8, .{ .name = "func_08066AE8", .linkage = .strong });
        @export(&func_08066CB0, .{ .name = "func_08066CB0", .linkage = .strong });
        @export(&func_08066CD0, .{ .name = "func_08066CD0", .linkage = .strong });
        @export(&func_08068A54, .{ .name = "func_08068A54", .linkage = .strong });
        @export(&func_08069730, .{ .name = "func_08069730", .linkage = .strong });
        @export(&func_0806A2D0, .{ .name = "func_0806A2D0", .linkage = .strong });
        @export(&func_0806A798, .{ .name = "func_0806A798", .linkage = .strong });
        @export(&func_0806A890, .{ .name = "func_0806A890", .linkage = .strong });
        @export(&func_0806AC9C, .{ .name = "func_0806AC9C", .linkage = .strong });
        @export(&func_0806AE90, .{ .name = "func_0806AE90", .linkage = .strong });
        @export(&func_0806B118, .{ .name = "func_0806B118", .linkage = .strong });
        @export(&func_0802BFB0, .{ .name = "func_0802BFB0", .linkage = .strong });
        @export(&func_0802DEE4, .{ .name = "func_0802DEE4", .linkage = .strong });
        @export(&func_0802DF08, .{ .name = "func_0802DF08", .linkage = .strong });
        @export(&func_0802DF2C, .{ .name = "func_0802DF2C", .linkage = .strong });
        @export(&func_0802E3FC, .{ .name = "func_0802E3FC", .linkage = .strong });
        @export(&func_0802E508, .{ .name = "func_0802E508", .linkage = .strong });
        @export(&func_0802E558, .{ .name = "func_0802E558", .linkage = .strong });
        @export(&func_0802EEFC, .{ .name = "func_0802EEFC", .linkage = .strong });
        @export(&func_0802F5D4, .{ .name = "func_0802F5D4", .linkage = .strong });
        @export(&func_0802FD30, .{ .name = "func_0802FD30", .linkage = .strong });
        @export(&func_0802EC3C, .{ .name = "func_0802EC3C", .linkage = .strong });
        @export(&func_080539B4, .{ .name = "func_080539B4", .linkage = .strong });
        @export(&func_08059E50, .{ .name = "func_08059E50", .linkage = .strong });
        @export(&func_0805AEC8, .{ .name = "func_0805AEC8", .linkage = .strong });
        @export(&func_08066964, .{ .name = "func_08066964", .linkage = .strong });
        @export(&func_08068ABC, .{ .name = "func_08068ABC", .linkage = .strong });
        @export(&func_0806A5DC, .{ .name = "func_0806A5DC", .linkage = .strong });
        @export(&func_0806AB1C, .{ .name = "func_0806AB1C", .linkage = .strong });
        @export(&func_0806B40C, .{ .name = "func_0806B40C", .linkage = .strong });
        @export(&func_0806BDC4, .{ .name = "func_0806BDC4", .linkage = .strong });
        @export(&func_0806BE94, .{ .name = "func_0806BE94", .linkage = .strong });
        @export(&func_0806C378, .{ .name = "func_0806C378", .linkage = .strong });
        @export(&func_0806C3D4, .{ .name = "func_0806C3D4", .linkage = .strong });
        @export(&func_0806C90C, .{ .name = "func_0806C90C", .linkage = .strong });
    }
}

test "computeScaledDamage matches Advance Wars integer division formula" {
    try std.testing.expectEqual(@as(i32, 55), computeScaledDamage(0, 55));
    try std.testing.expectEqual(@as(i32, 44), computeScaledDamage(20, 55));
    try std.testing.expectEqual(@as(i32, 0), computeScaledDamage(100, 99));
}
