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

fn spawnProc131E0Zero(comptime def_pool_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(def_pool_ref);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn runScript18400FromPool(comptime def_pool_ref: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(def_pool_ref);
    if (!abi.call(decls.func_08018400, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn proc `0x0828_AB58` (`0x08026724`).
pub fn func_08026724() callconv(.c) void {
    if (!abi.enter(0x08026724)) return;
    if (!spawnProcDefZero(0x08026734, 0x0802672F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn proc `0x0828_AB58` and set `+0x20 = 1` (`0x08026738`).
pub fn func_08026738() callconv(.c) void {
    if (!abi.enter(0x08026738)) return;
    if (!spawnProcDefZero(0x0802674C, 0x08026743)) return;
    abi.fetches(6);
    abi.write16(rt.r[0] +% 0x20, 1);
    abi.setRegNz(&rt.r[1], 1);
    abi.popReturn();
}

/// Dispatch `[0x0828_9EB0]` proc helper (`0x08026814`).
pub fn func_08026814() callconv(.c) void {
    if (!abi.enter(0x08026814)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08026820);
    if (!abi.call(decls.func_0801329C, 0x0802681D)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Query `u8(0x08013BA0(0x0828_9EC8))` returning `u8` in `r0` (`0x08026A1C`).
pub fn func_08026A1C() callconv(.c) void {
    if (!abi.enter(0x08026A1C)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08026A2C);
    if (!abi.call(decls.func_08013BA0, 0x08026A25)) return;
    abi.fetches(6);
    const val: u32 = @as(u8, @truncate(rt.r[0]));
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.setRegNz(&rt.r[0], val);
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Spawn proc `0x0828_A870` (`0x08027F58`).
pub fn func_08027F58() callconv(.c) void {
    if (!abi.enter(0x08027F58)) return;
    if (!spawnProcDefZero(0x08027F68, 0x08027F63)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn proc `0x0828_A910` (`0x08027FA0`).
pub fn func_08027FA0() callconv(.c) void {
    if (!abi.enter(0x08027FA0)) return;
    if (!spawnProcDefZero(0x08027FB0, 0x08027FAB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn proc `0x0828_A910` and bind `proc.+0x18 = r1` (`0x08027FB4`).
pub fn func_08027FB4() callconv(.c) void {
    if (!abi.enter(0x08027FB4)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const saved = rt.r[1];
    rt.r[4] = saved;
    rt.r[0] = abi.read32(0x08027FC8);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08027FC1)) return;
    abi.fetches(6);
    abi.write32(rt.r[0] +% 0x18, saved);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn proc `0x0828_AA14` with coordinates `(u16(r0), u16(r1))` at `+0x1E/+0x20` (`0x080286F0`).
pub fn func_080286F0() callconv(.c) void {
    if (!abi.enter(0x080286F0)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const x: u16 = @truncate(rt.r[0]);
    const y: u16 = @truncate(rt.r[1]);
    rt.r[4] = x;
    rt.r[5] = y;
    rt.r[0] = abi.read32(0x08028710);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08028707)) return;
    abi.fetches(7);
    abi.write16(rt.r[0] +% 0x1E, x);
    abi.write16(rt.r[0] +% 0x20, y);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Free proc pointed to by `[0x0300_0074]` via `0x08012E14` (`0x08028F80`).
pub fn func_08028F80() callconv(.c) void {
    if (!abi.enter(0x08028F80)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(abi.read32(0x08028F90));
    if (!abi.call(decls.func_08012E14, 0x08028F8B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn proc `0x0828_AA54` via `0x080131E0` (`0x080290CC`).
pub fn func_080290CC() callconv(.c) void {
    if (!abi.enter(0x080290CC)) return;
    spawnProc131E0Zero(0x080290DC, 0x080290D7);
}

/// Forward to `0x080203E8` (`0x080290E0`).
pub fn func_080290E0() callconv(.c) void {
    if (!abi.enter(0x080290E0)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080203E8, 0x080290E7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn proc `0x0828_AAE8` and write `u16(r0)` into spawned `proc_slot.+0x22` (`0x08029BEC`).
pub fn func_08029BEC() callconv(.c) void {
    if (!abi.enter(0x08029BEC)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const val: u16 = @truncate(rt.r[0]);
    rt.r[4] = val;
    rt.r[0] = abi.read32(0x08029C14);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, 0x08029BFD)) return;
    abi.fetches(13);
    const slot_idx = abi.signExtend8(@truncate(rt.r[0]));
    const proc_base = abi.read32(0x08029C18);
    const proc_off: u32 = @bitCast(slot_idx *% 0x60);
    const dst_slot = proc_base +% proc_off;
    abi.write16(dst_slot +% 0x22, val);
    rt.r[1] = dst_slot;
    rt.r[2] = proc_base;
    rt.updateNz(proc_off);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Spawn proc `0x0828_AB70` (param `1`) via `0x080131E0` (`0x0802A9B4`).
pub fn func_0802A9B4() callconv(.c) void {
    if (!abi.enter(0x0802A9B4)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0802A9C4);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(decls.func_080131E0, 0x0802A9BF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch `[0x0828_AB70]` via `0x0801329C` (`0x0802A9C8`).
pub fn func_0802A9C8() callconv(.c) void {
    if (!abi.enter(0x0802A9C8)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0802A9D4);
    if (!abi.call(decls.func_0801329C, 0x0802A9D1)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn proc `0x0828_AB90` via `0x080131E0` (`0x0802A9D8`).
pub fn func_0802A9D8() callconv(.c) void {
    if (!abi.enter(0x0802A9D8)) return;
    spawnProc131E0Zero(0x0802A9E8, 0x0802A9E3);
}

/// Spawn proc `0x0828_AC68` via `0x080131E0` (`0x0802ACF8`).
pub fn func_0802ACF8() callconv(.c) void {
    if (!abi.enter(0x0802ACF8)) return;
    spawnProc131E0Zero(0x0802AD08, 0x0802AD03);
}

/// Spawn proc `0x0828_AE3C` (`0x0802C318`).
pub fn func_0802C318() callconv(.c) void {
    if (!abi.enter(0x0802C318)) return;
    if (!spawnProcDefZero(0x0802C328, 0x0802C323)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn proc `0x0828_AE6C` (`0x0802C32C`).
pub fn func_0802C32C() callconv(.c) void {
    if (!abi.enter(0x0802C32C)) return;
    if (!spawnProcDefZero(0x0802C33C, 0x0802C337)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn proc `0x0828_AEA4` (`0x0802C340`).
pub fn func_0802C340() callconv(.c) void {
    if (!abi.enter(0x0802C340)) return;
    if (!spawnProcDefZero(0x0802C350, 0x0802C34B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn proc `0x0828_AECC` (`0x0802C354`).
pub fn func_0802C354() callconv(.c) void {
    if (!abi.enter(0x0802C354)) return;
    if (!spawnProcDefZero(0x0802C364, 0x0802C35F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Spawn proc `0x0828_AF34` (`0x0802C51C`).
pub fn func_0802C51C() callconv(.c) void {
    if (!abi.enter(0x0802C51C)) return;
    if (!spawnProcDefZero(0x0802C52C, 0x0802C527)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Run script `0x0828_AFB4` (`0x0802C530`).
pub fn func_0802C530() callconv(.c) void {
    if (!abi.enter(0x0802C530)) return;
    runScript18400FromPool(0x0802C53C, 0x0802C539);
}

/// Run script `0x0828_B074` (`0x0802C5A0`).
pub fn func_0802C5A0() callconv(.c) void {
    if (!abi.enter(0x0802C5A0)) return;
    runScript18400FromPool(0x0802C5AC, 0x0802C5A9);
}

/// Run script `0x0828_B144` (`0x0802C5B0`).
pub fn func_0802C5B0() callconv(.c) void {
    if (!abi.enter(0x0802C5B0)) return;
    runScript18400FromPool(0x0802C5BC, 0x0802C5B9);
}

/// Set VRAM tile offset `r0 + 0x28`, mark state active, and upload `0x500` bytes to BG VRAM (`0x0801B8D4`).
pub fn func_0801B8D4() callconv(.c) void {
    if (!abi.enter(0x0801B8D4)) return;
    abi.fetches(24);
    abi.pushLr();
    const state = abi.read32(0x0801B904);
    abi.write16(state +% (0x8B << 2), @truncate(rt.r[0] +% 0x28));
    abi.write8(state, 1);
    const slot_bits = (abi.read32(abi.read32(0x0801B90C)) << 28) >> 30;
    rt.r[0] = abi.read32(0x0801B908);
    rt.r[1] = (slot_bits << 14) +% 0x0600_0000;
    abi.setRegNz(&rt.r[2], 0x500);
    if (!abi.call(decls.func_0800FFA8, 0x0801B901)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Advance unit/sprite cursor step via `0x0801BAE4` and accumulate progress in `+0x32` / `+0x20` (`0x0801BAB4`).
pub fn func_0801BAB4() callconv(.c) void {
    if (!abi.enter(0x0801BAB4)) return;
    abi.fetches(15);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[4] = rt.r[0];
    rt.r[0] = rt.r[1];
    rt.r[3] = rt.r[2] & 0xFFFF;
    const sum = (abi.read16(rt.r[4] +% 0x2C) +% abi.read16(rt.r[4] +% 0x2E)) & 0xFFFF;
    rt.r[2] = sum;
    rt.r[1] = abi.read32(rt.r[4] +% 0x20);
    if (!abi.call(decls.func_0801BAE4, 0x0801BACF)) return;

    abi.fetches(13);
    abi.write8(rt.r[4] +% 0x32, @truncate(abi.read8(rt.r[4] +% 0x32) +% rt.r[0]));
    abi.write32(rt.r[4] +% 0x20, abi.read32(rt.r[4] +% 0x20) +% rt.r[0]);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Reset hardware audio/display state and enable unit highlight blend layers (`0x0801C840`).
pub fn func_0801C840() callconv(.c) void {
    if (!abi.enter(0x0801C840)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080104B0, 0x0801C847)) return;
    abi.fetches(29);
    const reg = abi.read32(0x0801C87C);
    abi.write8(reg, @truncate((abi.read8(reg) & 0x3F) | 0x41));
    abi.write8(reg +% 1, @truncate(abi.read8(reg +% 1) | 0x1E));
    abi.write16(abi.read32(0x0801C880), 0);
    abi.write16(abi.read32(0x0801C884), 0x10);
    abi.popReturn();
}

/// Save `[0x0801D95C] = r0`, invoke callback pointer `*[0x0801D960]` via `0x0807B45C`, then reload (`0x0801D930`).
pub fn func_0801D930() callconv(.c) void {
    if (!abi.enter(0x0801D930)) return;
    abi.fetches(17);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    const a2 = rt.r[3];
    const a3 = abi.read32(rt.r[13] +% 0x14);
    const a4 = abi.read32(rt.r[13] +% 0x18);
    rt.r[5] = abi.read32(0x0801D95C);
    abi.write16(rt.r[5], @truncate(rt.r[0]));
    abi.write32(rt.r[13], a4);
    rt.r[4] = abi.read32(abi.read32(0x0801D960));
    rt.r[0] = rt.r[1];
    rt.r[1] = rt.r[2];
    rt.r[2] = a2;
    rt.r[3] = a3;
    if (!abi.call(decls.func_0807B45C, 0x0801D94F)) return;

    abi.fetches(9);
    abi.write16(rt.r[5], abi.read16(abi.read32(0x0801D964)));
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Upload `0x1000` bytes of unit/map tileset `u8(r0)` to alternating VRAM bank (`0x0801F7B0`).
pub fn func_0801F7B0() callconv(.c) void {
    if (!abi.enter(0x0801F7B0)) return;
    abi.fetches(24);
    abi.pushLr();
    const id = rt.r[0] & 0xFF;
    const src = (id << 12) +% abi.read32(0x0801F7E0);
    const bank_bits = (abi.read32(abi.read32(0x0801F7E4)) << 28) >> 30;
    const dst = (bank_bits << 14) +% ((id & 1) << 12) +% abi.read32(0x0801F7E8);
    rt.r[0] = src;
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[2], 0x1000);
    if (!abi.call(decls.func_0800FDA4, 0x0801F7DD)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Update active proc's animator offset relative to camera via `0x08013550` (`0x08028D24`).
pub fn func_08028D24() callconv(.c) void {
    if (!abi.enter(0x08028D24)) return;
    abi.fetches(25);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const slot: u32 = @bitCast(abi.signExtend16(abi.read16(abi.read32(0x08028D58))));
    const proc_addr = abi.read32(0x08028D5C) +% (slot * 96);
    const cam = abi.read32(abi.read32(0x08028D60));
    const dx: u16 = @truncate(abi.read16(proc_addr +% 0x1E) -% abi.read16(cam +% 4));
    const dy: u16 = @truncate(abi.read16(proc_addr +% 0x20) -% abi.read16(cam +% 6));
    rt.r[0] = slot;
    rt.r[1] = @bitCast(abi.signExtend16(dx));
    rt.r[2] = @bitCast(abi.signExtend16(dy));
    if (!abi.call(decls.func_08013550, 0x08028D53)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Dispatch unit action command packet `7` (`r0=slot, r1=x, r2=y`) via `0x08031BA0` (`0x08034904`).
pub fn func_08034904() callconv(.c) void {
    if (!abi.enter(0x08034904)) return;
    abi.fetches(24);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const slot = rt.r[0] & 0xFF;
    const entry = abi.read32(abi.read32(0x08034938)) +% (slot * 12);
    const pkt = abi.read32(0x0803493C);
    abi.write8(pkt, 7);
    abi.write8(pkt +% 1, @truncate(slot));
    abi.write8(pkt +% 6, @truncate(rt.r[1]));
    abi.write8(pkt +% 7, @truncate(rt.r[2]));
    abi.write8(pkt +% 0x12, abi.read8(entry +% 6) & 0x7F);
    rt.r[0] = pkt;
    if (!abi.call(decls.func_08031BA0, 0x08034931)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Refresh current unit/CO palette via `0x0801BE88(u16 *(0x0803BAF4))` (`0x0803BAE4`).
pub fn func_0803BAE4() callconv(.c) void {
    if (!abi.enter(0x0803BAE4)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read16(abi.read32(0x0803BAF4));
    if (!abi.call(decls.func_0801BE88, 0x0803BAEF)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Center map cursor on current unit via `0x080199A0(u16 *(0x0803BB08))` (`0x0803BAF8`).
pub fn func_0803BAF8() callconv(.c) void {
    if (!abi.enter(0x0803BAF8)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read16(abi.read32(0x0803BB08));
    if (!abi.call(decls.func_080199A0, 0x0803BB03)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Show unit dialogue/status script `r0` for current entity faction via `0x08018C1C` (`0x0803BB0C`).
pub fn func_0803BB0C() callconv(.c) void {
    if (!abi.enter(0x0803BB0C)) return;
    abi.fetches(14);
    abi.pushLr();
    const idx = abi.read16(abi.read32(0x0803BB28));
    const entities = abi.read32(abi.read32(0x0803BB2C));
    rt.r[1] = abi.read8(entities +% (@as(u32, idx) *% entity_stride) +% 0x1D);
    abi.setRegNz(&rt.r[2], 0);
    if (!abi.call(decls.func_08018C1C, 0x0803BB25)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Evaluate `[*(0x08043834) + 4 + i16(*(0x08043838)+0x1E)]` via `0x08022640` and set byte flag `+0x41 = 1` (`0x08043810`).
pub fn func_08043810() callconv(.c) void {
    if (!abi.enter(0x08043810)) return;
    abi.fetches(13);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const table = abi.read32(0x08043834);
    rt.r[4] = abi.read32(0x08043838);
    abi.setRegNz(&rt.r[2], 0x1E);
    const unit_idx = abi.signExtend16(abi.read16(abi.read32(rt.r[4]) +% 0x1E));
    rt.r[1] = table +% 4;
    rt.r[0] = abi.read8(@as(u32, @bitCast(unit_idx)) +% rt.r[1]);
    if (!abi.call(decls.func_08022640, 0x08043827)) return;

    abi.fetches(9);
    rt.r[0] = abi.read32(rt.r[4]) +% 0x41;
    abi.setRegNz(&rt.r[1], 1);
    abi.write8(rt.r[0], 1);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

fn popReturnR1Unit() void {
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

fn adjustMapFocusMetric(
    comptime tbl_ref: u32,
    comptime idx_ref: u32,
    comptime cam_ref: u32,
    comptime ret1: u32,
    comptime ret2: u32,
    comptime ret3: u32,
) void {
    abi.fetches(16);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const tbl = abi.read32(tbl_ref);
    const slot_idx: i32 = abi.signExtend16(abi.read16(abi.read32(idx_ref)));
    const slot_off: u32 = @bitCast((slot_idx *% 3) << 5);
    const saved = abi.read32(slot_off +% tbl +% 0x18);
    rt.r[4] = saved;
    rt.r[0] = saved;
    if (!abi.call(decls.func_08028D64, ret1)) return;

    abi.fetches(17);
    const diff = saved -% abi.read32(abi.read32(cam_ref));
    rt.r[4] = diff;
    var scaled = (diff << 2) +% diff;
    scaled +%= scaled << 4;
    scaled +%= scaled << 8;
    scaled +%= scaled << 16;
    const neg_scaled = 0 -% scaled;
    const res: u32 = @bitCast(@as(i32, @bitCast(neg_scaled)) >> 2);
    abi.setRegNz(&rt.r[0], res);
    if (!abi.call(decls.func_0802430C, ret2)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08023EDC, ret3)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Upload palette for entity `r0` (`0x68` stride, field `+0x1A`) to OBJ palette slot `15` and advance script slot `+0x10` (`0x08017B20`).
pub fn func_08017B20() callconv(.c) void {
    if (!abi.enter(0x08017B20)) return;
    abi.fetches(25);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const slot_id = rt.r[0] & 0xFFFF;
    abi.write8(abi.read32(0x08017B6C), 0xF);
    const ent_base = abi.read32(abi.read32(0x08017B74));
    const idx = abi.read16(abi.read32(0x08017B70));
    const pal_id = abi.read8(ent_base +% (@as(u32, idx) *% 0x68) +% 0x1A) -% 1;
    rt.r[0] = (pal_id << 5) +% abi.read32(0x08017B78);
    rt.r[1] = @as(u32, 0xF) << 5;
    abi.setRegNz(&rt.r[2], 0x20);
    rt.r[4] = slot_id;
    if (!abi.call(decls.func_08011330, 0x08017B4F)) return;

    abi.fetches(17);
    const s_slot: i32 = abi.signExtend16(@truncate(slot_id));
    const slot_ptr = @as(u32, @bitCast((s_slot *% 3) << 3)) +% (abi.read32(0x08017B7C) +% 4);
    abi.write32(slot_ptr, abi.read32(slot_ptr) +% 0x10);
    rt.r[1] = slot_ptr;
    abi.setRegNz(&rt.r[0], 1);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnR1Unit();
}

/// Clear unit byte `+0x24` in `[0x0801C14C]` after `0x0801C0E4` and refresh via `0x0803BC2C` (`0x0801C120`).
pub fn func_0801C120() callconv(.c) void {
    if (!abi.enter(0x0801C120)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const unit_id = rt.r[0] & 0xFF;
    rt.r[4] = unit_id;
    rt.r[0] = unit_id;
    rt.updateNz(unit_id);
    if (!abi.call(decls.func_0801C0E4, 0x0801C12F)) return;

    abi.fetches(13);
    const units = abi.read32(abi.read32(0x0801C14C));
    abi.write8(units +% (unit_id *% 0x68) +% 0x24, 0);
    rt.r[0] = unit_id;
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0803BC2C, 0x0801C145)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Scroll camera onto active map slot `*[0x0802AA34]` (`0x0802A9EC`).
pub fn func_0802A9EC() callconv(.c) void {
    if (!abi.enter(0x0802A9EC)) return;
    adjustMapFocusMetric(0x0802AA30, 0x0802AA34, 0x0802AA38, 0x0802AA09, 0x0802AA27, 0x0802AA2B);
}

/// Scroll camera onto active map slot `*[0x0802AAF0]` (`0x0802AAA8`).
pub fn func_0802AAA8() callconv(.c) void {
    if (!abi.enter(0x0802AAA8)) return;
    adjustMapFocusMetric(0x0802AAEC, 0x0802AAF0, 0x0802AAF4, 0x0802AAC5, 0x0802AAE3, 0x0802AAE7);
}

/// Move cursor to unit `(byte +2, byte +3)`, allocate slot via `0x080131E0`, and bind `r0` to slot (`0x0802AAF8`).
pub fn func_0802AAF8() callconv(.c) void {
    if (!abi.enter(0x0802AAF8)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    const unit_ptr = rt.r[0];
    rt.r[4] = unit_ptr;
    rt.r[0] = abi.read8(unit_ptr +% 2);
    rt.r[1] = abi.read8(unit_ptr +% 3);
    if (!abi.call(decls.func_0802928C, 0x0802AB05)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x0802AB24);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_080131E0, 0x0802AB0D)) return;

    abi.fetches(14);
    const slot_idx: i32 = abi.signExtend8(@truncate(rt.r[0]));
    const tbl = abi.read32(0x0802AB28);
    const slot_off: u32 = @bitCast((slot_idx *% 3) << 5);
    abi.write32(slot_off +% (tbl +% 0x18), unit_ptr);
    rt.r[0] = @bitCast(slot_idx);
    rt.r[1] = slot_off +% (tbl +% 0x18);
    rt.r[2] = tbl +% 0x18;
    rt.updateNz(slot_off);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Finish unit menu phase `0x08038240` and update unit action flag `0x0802C4C0([0x0802C518])` (`0x0802C504`).
pub fn func_0802C504() callconv(.c) void {
    if (!abi.enter(0x0802C504)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08038240, 0x0802C50B)) return;
    abi.fetches(6);
    rt.r[0] = abi.read8(abi.read32(0x0802C518));
    if (!abi.call(decls.func_0802C4C0, 0x0802C513)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch unit action `0x0802C540([0x0802C570])` then finalize via `0x08028B80` (`0x0802C55C`).
pub fn func_0802C55C() callconv(.c) void {
    if (!abi.enter(0x0802C55C)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read8(abi.read32(0x0802C570));
    if (!abi.call(decls.func_0802C540, 0x0802C567)) return;
    abi.fetches(4);
    if (!abi.call(decls.func_08028B80, 0x0802C56B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Query `0x08015E3C` on `[0x0802C5DC]+1` and clear/update unit wait flag via `0x08015E70(..., 0)` (`0x0802C5C0`).
pub fn func_0802C5C0() callconv(.c) void {
    if (!abi.enter(0x0802C5C0)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read8(abi.read32(0x0802C5DC) +% 1);
    if (!abi.call(decls.func_08015E3C, 0x0802C5CB)) return;
    abi.fetches(8);
    const val: u16 = @bitCast(@as(i16, @as(i8, @bitCast(@as(u8, @truncate(rt.r[0]))))));
    abi.setRegNz(&rt.r[0], val);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_08015E70, 0x0802C5D7)) return;
    abi.fetches(4);
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08019970, .{ .name = "func_08019970", .linkage = .strong });
        @export(&func_08043810, .{ .name = "func_08043810", .linkage = .strong });
        @export(&func_0801B8D4, .{ .name = "func_0801B8D4", .linkage = .strong });
        @export(&func_0801BAB4, .{ .name = "func_0801BAB4", .linkage = .strong });
        @export(&func_0801C150, .{ .name = "func_0801C150", .linkage = .strong });
        @export(&func_0801C840, .{ .name = "func_0801C840", .linkage = .strong });
        @export(&func_0801D930, .{ .name = "func_0801D930", .linkage = .strong });
        @export(&func_0801F7B0, .{ .name = "func_0801F7B0", .linkage = .strong });
        @export(&func_08028D24, .{ .name = "func_08028D24", .linkage = .strong });
        @export(&func_08034904, .{ .name = "func_08034904", .linkage = .strong });
        @export(&func_0803BAE4, .{ .name = "func_0803BAE4", .linkage = .strong });
        @export(&func_0803BAF8, .{ .name = "func_0803BAF8", .linkage = .strong });
        @export(&func_0803BB0C, .{ .name = "func_0803BB0C", .linkage = .strong });
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
        @export(&func_08026724, .{ .name = "func_08026724", .linkage = .strong });
        @export(&func_08026738, .{ .name = "func_08026738", .linkage = .strong });
        @export(&func_08026814, .{ .name = "func_08026814", .linkage = .strong });
        @export(&func_08026A1C, .{ .name = "func_08026A1C", .linkage = .strong });
        @export(&func_08027F58, .{ .name = "func_08027F58", .linkage = .strong });
        @export(&func_08027FA0, .{ .name = "func_08027FA0", .linkage = .strong });
        @export(&func_08027FB4, .{ .name = "func_08027FB4", .linkage = .strong });
        @export(&func_080286F0, .{ .name = "func_080286F0", .linkage = .strong });
        @export(&func_08028F80, .{ .name = "func_08028F80", .linkage = .strong });
        @export(&func_080290CC, .{ .name = "func_080290CC", .linkage = .strong });
        @export(&func_080290E0, .{ .name = "func_080290E0", .linkage = .strong });
        @export(&func_08029BEC, .{ .name = "func_08029BEC", .linkage = .strong });
        @export(&func_0802A9B4, .{ .name = "func_0802A9B4", .linkage = .strong });
        @export(&func_0802A9C8, .{ .name = "func_0802A9C8", .linkage = .strong });
        @export(&func_0802A9D8, .{ .name = "func_0802A9D8", .linkage = .strong });
        @export(&func_0802ACF8, .{ .name = "func_0802ACF8", .linkage = .strong });
        @export(&func_0802C318, .{ .name = "func_0802C318", .linkage = .strong });
        @export(&func_0802C32C, .{ .name = "func_0802C32C", .linkage = .strong });
        @export(&func_0802C340, .{ .name = "func_0802C340", .linkage = .strong });
        @export(&func_0802C354, .{ .name = "func_0802C354", .linkage = .strong });
        @export(&func_0802C51C, .{ .name = "func_0802C51C", .linkage = .strong });
        @export(&func_0802C530, .{ .name = "func_0802C530", .linkage = .strong });
        @export(&func_0802C5A0, .{ .name = "func_0802C5A0", .linkage = .strong });
        @export(&func_0802C5B0, .{ .name = "func_0802C5B0", .linkage = .strong });
        @export(&func_08017B20, .{ .name = "func_08017B20", .linkage = .strong });
        @export(&func_0801C120, .{ .name = "func_0801C120", .linkage = .strong });
        @export(&func_0802A9EC, .{ .name = "func_0802A9EC", .linkage = .strong });
        @export(&func_0802AAA8, .{ .name = "func_0802AAA8", .linkage = .strong });
        @export(&func_0802AAF8, .{ .name = "func_0802AAF8", .linkage = .strong });
        @export(&func_0802C504, .{ .name = "func_0802C504", .linkage = .strong });
        @export(&func_0802C55C, .{ .name = "func_0802C55C", .linkage = .strong });
        @export(&func_0802C5C0, .{ .name = "func_0802C5C0", .linkage = .strong });
    }
}

test "entity table stride matches unit palette offset math" {
    try std.testing.expectEqual(@as(u32, 0x68), entity_stride);
}
