//! Lifted GBA PPU/OAM shadow register, palette fade, and VRAM bulk-copy helpers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const abi = @import("abi.zig");
const bios = @import("bios.zig");
const clusters_low = @import("clusters_low.zig");
const dma = @import("dma.zig");
const low_peel_1 = @import("low_peel_1.zig");
const low_peel_11 = @import("low_peel_11.zig");
const low_peel_13 = @import("low_peel_13.zig");
const low_peel_15 = @import("low_peel_15.zig");
const low_peel_2 = @import("low_peel_2.zig");
const low_peel_3 = @import("low_peel_3.zig");
const low_peel_5 = @import("low_peel_5.zig");
const low_peel_6 = @import("low_peel_6.zig");
const low_peel_9 = @import("low_peel_9.zig");
const math = @import("math.zig");
const mem = @import("mem.zig");
const sound = @import("sound.zig");
const tail_low = @import("tail_low.zig");
const types = @import("types.zig");

/// Decode active-low GBA `KEYINPUT` halfword into active-high 10-bit button mask.
pub inline fn decodeActiveLowKeys(raw_keyinput: u16) u16 {
    return @truncate(types.key_mask_all & ~@as(u32, raw_keyinput));
}

/// Poll GBA `KEYINPUT` (or replay stream when `battle_ui_state+0x32 != 0`) and update `key_state` (`0x0801122C`).
pub fn func_0801122C() callconv(.c) void {
    if (!abi.enter(0x0801122C)) return;
    abi.fetches(8);
    abi.pushLr();
    abi.pushReg(4);

    const mode = mem.readU8(types.addr.battle_ui_state +% 0x32);
    rt.r[0] = mode;
    rt.cpuSub(null, mode, 0, true);

    var poll_hw = (mode == 0);
    if (!poll_hw) {
        abi.fetches(4);
        if (!abi.call(low_peel_1.func_080316B4, 0x0801123D)) return;
        abi.fetches(6);
        const is_replay: u8 = @truncate(rt.r[0]);
        abi.setRegNz(&rt.r[0], is_replay);
        rt.cpuSub(null, is_replay, 1, true);
        if (is_replay == 1) {
            abi.fetches(4);
            if (!abi.call(low_peel_15.func_080316CC, 0x08011249)) return;
            abi.fetches(6);
            abi.setRegNz(&rt.r[0], rt.r[0] << 16);
            abi.setRegNz(&rt.r[4], rt.r[0] >> 16);
            if (!abi.call(low_peel_15.func_08031544, 0x08011251)) return;
            abi.fetches(3);
            poll_hw = false;
        } else {
            poll_hw = true;
        }
    }

    if (poll_hw) {
        abi.fetches(8);
        const raw_keys = mem.readU16(types.addr.reg_keyinput);
        const pressed = decodeActiveLowKeys(raw_keys);
        rt.r[0] = types.key_mask_all;
        rt.r[1] = raw_keys;
        rt.r[2] = types.key_mask_all;
        abi.setRegNz(&rt.r[4], pressed);
    }

    abi.fetches(7);
    rt.r[0] = types.addr.key_state;
    const keys_s16: i16 = @bitCast(@as(u16, @truncate(rt.r[4])));
    abi.setRegNz(&rt.r[1], @bitCast(@as(i32, keys_s16)));
    if (!abi.call(low_peel_6.func_080111A8, 0x0801126F)) return;

    abi.fetches(5);
    rt.r[4] = abi.popReg();
    abi.popReturn();
}

/// Sync shadow palette buffer (`0x0300_1EF0`) into Palette RAM when `[0x0300_0048] == 1` (`0x0801129C`).
pub fn func_0801129C() callconv(.c) void {
    if (!abi.enter(0x0801129C)) return;
    abi.fetches(7);
    abi.pushLr();

    const synced = mem.readU8(types.addr.palette_synced_flag);
    rt.r[0] = synced;
    rt.cpuSub(null, synced, 1, true);

    if (synced == 1) {
        abi.fetches(9);
        if (!dma.copyAutoCall(types.addr.palette_shadow_buf, types.addr.pal_ram, types.pal_ram_size, 0x080112B5)) return;
    }

    abi.fetches(4);
    abi.popReturn();
}

/// Clear all 32 palette dirty flags at `0x0201_04B4` (`0x080113D0`).
pub fn func_080113D0() callconv(.c) void {
    if (!abi.enter(0x080113D0)) return;
    abi.fetches(5);
    var i: i32 = @intCast(types.palette_dirty_count - 1);
    while (i >= 0) : (i -= 1) {
        abi.fetches(7);
        mem.writeU8(types.addr.palette_dirty_flags +% @as(u32, @intCast(i)), 0);
    }
    abi.fetches(3);
    rt.r[0] = types.addr.palette_dirty_flags;
    rt.r[1] = 0xFFFF_FFFF;
    rt.r[2] = 0;
    rt.r[3] = types.addr.palette_dirty_flags;
    rt.cpuSub(null, 0xFFFF_FFFF, 0, true);
    abi.retLr();
}

/// Flush shadow palette buffer (`0x0300_1EF0`) into GBA Palette RAM (`0x0500_0000`) (`0x080112C0`).
pub fn func_080112C0() callconv(.c) void {
    if (!abi.enter(0x080112C0)) return;
    abi.fetches(9);
    abi.pushLr();
    abi.pushReg(4);

    const dispcnt_lo = mem.readU8(types.addr.dispcnt_shadow);
    const forced_blank: u32 = @as(u32, dispcnt_lo) & types.dispcnt_forced_blank;
    rt.r[1] = dispcnt_lo;
    rt.r[0] = forced_blank;
    rt.cpuSub(null, forced_blank, 0, true);

    if (forced_blank != 0) {
        abi.fetches(9);
        if (!dma.copyAutoCall(types.addr.palette_shadow_buf, types.addr.pal_ram, types.pal_ram_size, 0x080112DD)) return;
        abi.fetches(3);
    } else {
        abi.fetches(6);
        rt.r[4] = types.addr.palette_synced_flag;
        const synced = mem.readU8(types.addr.palette_synced_flag);
        rt.r[0] = synced;
        rt.cpuSub(null, synced, 0, true);
        if (synced == 0) {
            abi.fetches(9);
            if (!dma.enqueueOrCopyCall(types.addr.palette_shadow_buf, types.addr.pal_ram, types.pal_ram_size, 0x080112FF)) return;
            abi.fetches(4);
            abi.setRegNz(&rt.r[0], 1);
            mem.writeU8(types.addr.palette_synced_flag, 1);
        }
    }

    abi.fetches(5);
    rt.r[4] = abi.popReg();
    abi.popReturn();
}

const bg_scroll_ptr_addrs = [_]u32{
    0x0801047C, 0x08010480, 0x08010484, 0x08010488, 0x0801048C,
    0x08010490, 0x08010494, 0x08010498, 0x0801049C, 0x080104A0,
    0x080104A4, 0x080104A8, 0x080104AC,
};

const window_reg_ptr_addrs = [_]u32{
    0x080104C4, 0x080104C8, 0x080104CC, 0x080104D0,
};

fn zeroHalfwordPtrTable(comptime pool_addrs: []const u32, comptime fetches_n: u32) void {
    abi.fetches(fetches_n);
    var last_ptr: u32 = 0;
    for (pool_addrs) |pool_addr| {
        last_ptr = abi.read32(pool_addr);
        abi.write16(last_ptr, 0);
    }
    abi.setRegNz(&rt.r[1], 0);
    rt.r[0] = last_ptr;
    abi.retLr();
}

/// Shared no-op frame callback (`0x0800F094`).
pub fn func_0800F094() callconv(.c) void {
    if (!abi.enter(0x0800F094)) return;
    abi.fetches(3);
    abi.retLr();
}

/// Initialize display window / blend shadow registers (`0x0800F170`).
pub fn func_0800F170() callconv(.c) void {
    if (!abi.enter(0x0800F170)) return;
    abi.fetches(26);
    const win_ctl_ptr = abi.read32(0x0800F1A0);
    abi.write16(win_ctl_ptr, 0);
    const enabled_mask: u32 = @as(u32, abi.read8(win_ctl_ptr)) | 0x3F;
    abi.write8(win_ctl_ptr, @truncate(enabled_mask));

    abi.write16(abi.read32(0x0800F1A4), 0);
    abi.write16(abi.read32(0x0800F1A8), 0);
    const last_ptr = abi.read32(0x0800F1AC);
    abi.write16(last_ptr, 0);

    rt.r[2] = win_ctl_ptr;
    rt.r[3] = 0;
    rt.r[1] = 0x20;
    abi.setRegNz(&rt.r[0], last_ptr);
    abi.retLr();
}

/// Copy 16-bit shadow display control register from `[0x0800F588]` to `[0x0800F584]` (`0x0800F578`).
pub fn func_0800F578() callconv(.c) void {
    if (!abi.enter(0x0800F578)) return;
    abi.fetches(7);
    const dst = abi.read32(0x0800F584);
    const src = abi.read32(0x0800F588);
    const val = abi.read16(src);
    abi.write16(dst, val);
    rt.r[0] = dst;
    rt.r[1] = val;
    abi.retLr();
}

/// Clear all 13 BG scroll/control shadow registers (`0x08010444`).
pub fn func_08010444() callconv(.c) void {
    if (!abi.enter(0x08010444)) return;
    zeroHalfwordPtrTable(&bg_scroll_ptr_addrs, 30);
}

/// Clear all 4 window shadow registers (`0x080104B0`).
pub fn func_080104B0() callconv(.c) void {
    if (!abi.enter(0x080104B0)) return;
    zeroHalfwordPtrTable(&window_reg_ptr_addrs, 12);
}

/// OAM queue flush wrapper A (`0x080134E0` -> `0x0801A61C`).
pub fn func_080134E0() callconv(.c) void {
    if (!abi.enter(0x080134E0)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(low_peel_6.func_0801A61C, 0x080134E7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// OAM queue flush wrapper B (`0x080134EC` -> `0x0801A660`).
pub fn func_080134EC() callconv(.c) void {
    if (!abi.enter(0x080134EC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(low_peel_3.func_0801A660, 0x080134F3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Reset palette fade state (`0x08015A08`: calls `0x08014B14(0, 16)` and zeroes `[0x08015A1C]`).
pub fn func_08015A08() callconv(.c) void {
    if (!abi.enter(0x08015A08)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    abi.setRegNz(&rt.r[1], 0x10);
    if (!abi.call(clusters_low.func_08014B14, 0x08015A13)) return;
    abi.fetches(7);
    abi.write16(abi.read32(0x08015A1C), 0);
    abi.popReturn();
}

/// Copy `0x380` bytes of BG tilemap/tile data using `cpuFastCopy32` (`0x08015A38`).
pub fn func_08015A38() callconv(.c) void {
    if (!abi.enter(0x08015A38)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08015A4C);
    rt.r[1] = abi.read32(0x08015A50);
    abi.setRegNz(&rt.r[2], @as(u32, 0xE0) << 2);
    if (!abi.call(dma.func_0800FDCC, 0x08015A47)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Copy `0x80` bytes from `[0x08015A68]` into `0x0700_0000` (OAM) using `cpuFastCopy32` (`0x08015A54`).
pub fn func_08015A54() callconv(.c) void {
    if (!abi.enter(0x08015A54)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08015A68);
    abi.setRegNz(&rt.r[1], @as(u32, 0xE0) << 19);
    abi.setRegNz(&rt.r[2], 0x80);
    if (!abi.call(dma.func_0800FDCC, 0x08015A63)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Initialize 4 system timer/counter bytes `[+0x72..+0x75] = 0x32` on `*(0x0201_00B0)` (`0x08002E88`).
pub fn func_08002E88() callconv(.c) void {
    if (!abi.enter(0x08002E88)) return;
    abi.fetches(17);
    const ptr_loc = abi.read32(0x08002EA8);
    const sys_base = abi.read32(ptr_loc);
    var off: u32 = 0x72;
    while (off <= 0x75) : (off += 1) {
        abi.write8(sys_base +% off, 0x32);
    }
    rt.r[2] = ptr_loc;
    abi.setRegNz(&rt.r[1], 0x32);
    rt.r[0] = sys_base +% 0x75;
    abi.retLr();
}

/// System predicate returning `0` (`0x080045A8`).
pub fn func_080045A8() callconv(.c) void {
    if (!abi.enter(0x080045A8)) return;
    abi.fetches(4);
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Clear system byte `[*(0x0201_00B0) + 0x9C] = 0` (`0x08004F34`).
pub fn func_08004F34() callconv(.c) void {
    if (!abi.enter(0x08004F34)) return;
    abi.fetches(8);
    const dst = abi.read32(abi.read32(0x08004F40)) +% 0x9C;
    abi.write8(dst, 0);
    rt.r[0] = dst;
    abi.setRegNz(&rt.r[1], 0);
    abi.retLr();
}

/// Reset system hardware/timing halfwords `+0x6E = 0x0780`, `+0x70 = 0x0970`, `+0x6C = 0` on `*(0x0201_00B0)` (`0x080076FC`).
pub fn func_080076FC() callconv(.c) void {
    if (!abi.enter(0x080076FC)) return;
    abi.fetches(18);
    const sys_base = abi.read32(abi.read32(0x0800771C));
    abi.write16(sys_base +% 0x6E, 0x0780);
    abi.write16(sys_base +% 0x70, 0x0970);
    abi.write8(sys_base +% 0x6C, 0);
    rt.r[3] = sys_base;
    rt.r[2] = 0;
    rt.r[1] = sys_base +% 0x70;
    rt.r[0] = sys_base +% 0x6C;
    abi.retLr();
}

/// Clear hardware init flag `[0x0300_2F24] = 0` (`u8`) (`0x08012BAC`).
pub fn func_08012BAC() callconv(.c) void {
    if (!abi.enter(0x08012BAC)) return;
    abi.fetches(6);
    const dst = abi.read32(0x08012BB4);
    abi.write8(dst, 0);
    rt.r[1] = dst;
    abi.setRegNz(&rt.r[0], 0);
    abi.retLr();
}

/// Reset SIO registers (`RCNT`, `SIOCNT=0x2003`, `SIODATA8=0`) and link-state fields on `[r0]` (`0x08069B1C`).
pub fn func_08069B1C() callconv(.c) void {
    if (!abi.enter(0x08069B1C)) return;
    abi.fetches(24);
    const link = rt.r[0];
    abi.write8(link +% 0x1E, 0);
    abi.write8(link +% 0x18, 0);
    abi.write8(link +% 0x1D, 0);
    abi.write8(link +% 0x4A, 0xF);
    abi.write8(link +% 0x48, 0);
    abi.write16(link +% 0x16, 0);

    const rcnt = abi.read32(0x08069B48);
    abi.write16(rcnt, 0);
    const siocnt = abi.read32(0x08069B4C);
    const siocnt_val = abi.read32(0x08069B50);
    abi.write16(siocnt, @truncate(siocnt_val));
    const siodata = abi.read32(0x08069B54);
    abi.write16(siodata, 0);

    rt.r[2] = siocnt;
    rt.r[3] = siocnt_val;
    rt.r[1] = 0;
    rt.r[0] = siodata;
    abi.retLr();
}

/// Arm hardware timer `u8(r0)` IRQ and configure reload/control registers (`0x08079958`).
pub fn func_08079958() callconv(.c) void {
    if (!abi.enter(0x08079958)) return;
    abi.fetches(69);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 8;
    const frame = rt.r[13];

    const slot_idx: u8 = @truncate(rt.r[0]);
    abi.write8(frame, slot_idx);
    const slot_ptr = abi.read32(abi.read32(0x080799E0)) +% (@as(u32, slot_idx) *% 6);
    abi.write32(frame +% 4, slot_ptr);

    const ime_addr = abi.read32(0x080799E8);
    abi.write16(abi.read32(0x080799E4), abi.read16(ime_addr));
    abi.write16(ime_addr, 1);

    const ie_addr = abi.read32(0x080799EC);
    const timer_shift: u5 = @truncate(abi.read8(abi.read32(0x080799F0)));
    const irq_mask: u32 = @as(u32, 8) << timer_shift;
    abi.write16(ie_addr, @truncate(abi.read16(ie_addr) | irq_mask));
    abi.write8(abi.read32(0x080799F4), 0);

    var cur = slot_ptr;
    const reload_val = abi.read16(cur);
    abi.write16(abi.read32(0x080799F8), reload_val);
    cur +%= 2;

    const timer_reg_ptr = abi.read32(0x080799FC);
    const mmio_base = abi.read32(timer_reg_ptr);
    abi.write16(mmio_base, abi.read16(cur));
    cur +%= 2;
    const last_val = abi.read16(cur);
    abi.write16(mmio_base +% 2, last_val);
    cur +%= 2;
    abi.write32(frame +% 4, cur);
    abi.write32(timer_reg_ptr, mmio_base);

    rt.r[1] = mmio_base;
    rt.r[2] = frame +% 4;
    rt.r[3] = cur;
    rt.updateNz(mmio_base);

    rt.r[13] +%= 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[7] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Disarm hardware timer IRQ and restore `IME` (`0x08079A00`).
pub fn func_08079A00() callconv(.c) void {
    if (!abi.enter(0x08079A00)) return;
    abi.fetches(37);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const timer_reg_ptr = abi.read32(0x08079A48);
    const mmio_base = abi.read32(timer_reg_ptr);
    abi.write16(mmio_base, 0);
    abi.write16(mmio_base +% 2, 0);
    abi.write32(timer_reg_ptr, mmio_base);

    const ie_addr = abi.read32(0x08079A4C);
    const timer_shift: u5 = @truncate(abi.read8(abi.read32(0x08079A50)));
    const inv_mask: u32 = ~(@as(u32, 8) << timer_shift);
    abi.write16(ie_addr, @truncate(abi.read16(ie_addr) & inv_mask));

    const ime_addr = abi.read32(0x08079A54);
    const saved_ime_addr = abi.read32(0x08079A58);
    const saved_ime = abi.read16(saved_ime_addr);
    abi.write16(ime_addr, saved_ime);

    rt.r[1] = saved_ime_addr;
    rt.r[2] = saved_ime;
    rt.r[3] = inv_mask;

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[7] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Hardware runtime no-op stub (`0x0807AE10`).
pub fn func_0807AE10() callconv(.c) void {
    if (!abi.enter(0x0807AE10)) return;
    abi.fetches(3);
    abi.retLr();
}

/// Register IRQ handler `r1` at vector index `r0` (`0x0300_6630[r0]`) (`0x0807AE50`).
pub fn func_0807AE50() callconv(.c) void {
    if (!abi.enter(0x0807AE50)) return;
    abi.fetches(7);
    const table = abi.read32(0x0807AE5C);
    const slot = (rt.r[0] << 2) +% table;
    abi.write32(slot, rt.r[1]);
    rt.r[2] = table;
    rt.r[0] = slot;
    abi.retLr();
}

/// Trigger immediate DMA3 copy `(src=r0, dst=r1, count=u16(r2))` (`0x0807B2DC`).
pub fn func_0807B2DC() callconv(.c) void {
    if (!abi.enter(0x0807B2DC)) return;
    abi.fetches(22);
    const sad: u32 = abi.read32(0x0807B304);
    abi.write16(sad, @truncate(rt.r[0]));
    abi.write16(sad +% 2, @truncate(rt.asrConst(rt.r[0], 16)));
    const dad = abi.read32(0x0807B308);
    abi.write16(dad, @truncate(rt.r[1]));
    abi.write16(dad +% 2, @truncate(rt.asrConst(rt.r[1], 16)));
    abi.write16(dad +% 4, @truncate(rt.r[2]));
    const cnt_hi = abi.read32(0x0807B30C);
    abi.write16(cnt_hi, 0x8000);

    rt.r[3] = sad +% 2;
    rt.r[2] = 0x8000;
    rt.r[1] = cnt_hi;
    abi.setRegNz(&rt.r[0], 0x8000);
    abi.retLr();
}

/// Configure arbitrary GBA DMA channel `r0` (`sad=r2, dad=r1, cnt_lo=r3, cnt_hi=sp[0]`) (`0x0807B310`).
pub fn func_0807B310() callconv(.c) void {
    if (!abi.enter(0x0807B310)) return;
    abi.fetches(20);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const cnt_hi_arg: u16 = @truncate(abi.read32(rt.r[13] +% 0x10));
    const ch_off = rt.r[0] *% 12;
    const sad_base = abi.read32(0x0807B334);
    abi.write32(ch_off +% sad_base, rt.r[2]);
    const dad_base = abi.read32(0x0807B338);
    abi.write32(ch_off +% dad_base, rt.r[1]);
    abi.write16(ch_off +% (sad_base +% 8), @truncate(rt.r[3]));
    const cnt_hi_base = abi.read32(0x0807B33C);
    const dst_hi = ch_off +% cnt_hi_base;
    abi.write16(dst_hi, cnt_hi_arg);

    rt.r[0] = dst_hi;
    rt.r[1] = cnt_hi_base;
    rt.r[2] = dad_base;
    rt.r[3] = sad_base +% 8;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;

    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Runtime library no-op stub (`0x0807B51C`).
pub fn func_0807B51C() callconv(.c) void {
    if (!abi.enter(0x0807B51C)) return;
    abi.fetches(3);
    abi.retLr();
}

/// Indirect call via `r1` to IWRAM handler `0x0300_6A0D` (`0x0801B850`).
pub fn func_0801B850() callconv(.c) void {
    if (!abi.enter(0x0801B850)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[1] = abi.read32(0x0801B85C);
    if (!abi.call(tail_low.func_0807B450, 0x0801B859)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Indirect call via `r1` to IWRAM handler `0x0300_6CCD` (`0x0801B860`).
pub fn func_0801B860() callconv(.c) void {
    if (!abi.enter(0x0801B860)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[1] = abi.read32(0x0801B86C);
    if (!abi.call(tail_low.func_0807B450, 0x0801B869)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Indirect call via `r3` to IWRAM handler `0x0300_680D` with `u16(r1, r2)` (`0x0801B870`).
pub fn func_0801B870() callconv(.c) void {
    if (!abi.enter(0x0801B870)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[1] &= 0xFFFF;
    rt.r[2] &= 0xFFFF;
    rt.updateNz(rt.r[2]);
    rt.r[3] = abi.read32(0x0801B884);
    if (!abi.call(tail_low.func_0807B458, 0x0801B881)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Indirect call via `r4` to IWRAM handler `0x0300_6725` with `(i16(r0), i16(r1), r2, u16(r3))` (`0x0801B888`).
pub fn func_0801B888() callconv(.c) void {
    if (!abi.enter(0x0801B888)) return;
    abi.fetches(12);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[3] &= 0xFFFF;
    rt.r[4] = abi.read32(0x0801B8A4);
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(rt.r[1])));
    rt.updateNz(rt.r[1]);
    if (!abi.call(tail_low.func_0807B45C, 0x0801B89D)) return;
    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Indirect call via `r3` to IWRAM handler `0x0300_666D` with `u16(r2)` (`0x0801B8A8`).
pub fn func_0801B8A8() callconv(.c) void {
    if (!abi.enter(0x0801B8A8)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[2] &= 0xFFFF;
    rt.updateNz(rt.r[2]);
    rt.r[3] = abi.read32(0x0801B8B8);
    if (!abi.call(tail_low.func_0807B458, 0x0801B8B5)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward `(r0.+2, r0.+3, r0.+0, 0x78, 0)` through `main_callback_slot` (`0x0300_0D8C`) (`0x0801DAB8`).
pub fn func_0801DAB8() callconv(.c) void {
    if (!abi.enter(0x0801DAB8)) return;
    abi.fetches(15);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 4;

    const obj = rt.r[0];
    const arg0 = abi.read8(obj +% 2);
    const arg1 = abi.read8(obj +% 3);
    const arg2 = abi.read8(obj);
    abi.write32(rt.r[13], 0);
    rt.r[5] = arg0;
    rt.r[4] = abi.read32(abi.read32(0x0801DADC));
    rt.r[2] = arg2;
    rt.r[1] = arg1;
    rt.r[0] = arg0;
    abi.setRegNz(&rt.r[3], 0x78);
    if (!abi.call(tail_low.func_0807B45C, 0x0801DAD3)) return;
    abi.fetches(6);
    rt.r[13] +%= 4;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Clear/initialize hardware buffers via `0x0800FE24` (`0x0800FE18`).
pub fn func_0800FE18() callconv(.c) void {
    if (!abi.enter(0x0800FE18)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(low_peel_3.func_0800FE24, 0x0800FE1F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Set fade/window mask `(0x14, 6)`, sync display shadow, and zero scroll registers (`0x0801036C`).
pub fn func_0801036C() callconv(.c) void {
    if (!abi.enter(0x0801036C)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0x14);
    abi.setRegNz(&rt.r[1], 6);
    if (!abi.call(low_peel_1.func_080103AC, 0x08010377)) return;
    abi.fetches(17);
    abi.write16(abi.read32(0x08010394), abi.read16(abi.read32(0x08010398)));
    inline for ([_]u32{ 0x0801039C, 0x080103A0, 0x080103A4, 0x080103A8 }) |ref| {
        abi.write16(abi.read32(ref), 0);
    }
    abi.popReturn();
}

/// Disable display/VBlank IRQ flags (`0x11`) and mask DMA channel flags via `0x0807AE60` (`0x08010AD8`).
pub fn func_08010AD8() callconv(.c) void {
    if (!abi.enter(0x08010AD8)) return;
    abi.fetches(14);
    abi.pushLr();
    const ctrl = abi.read32(0x08010AF4);
    abi.write8(ctrl, abi.read8(ctrl) & ~@as(u8, 0x11));
    abi.setRegNz(&rt.r[0], 1);
    rt.r[1] = @bitCast(@as(i32, -3));
    if (!abi.call(low_peel_9.func_0807AE60, 0x08010AF1)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear/flush hardware state block `0x08010B24` via `0x0800FBEC` (`0x08010B18`).
pub fn func_08010B18() callconv(.c) void {
    if (!abi.enter(0x08010B18)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08010B24);
    if (!abi.call(low_peel_3.func_0800FBEC, 0x08010B21)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward to `func_08010AD8` (`0x08010B44`).
pub fn func_08010B44() callconv(.c) void {
    if (!abi.enter(0x08010B44)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_08010AD8, 0x08010B4B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Enable IRQ flag bit `0x08`, sync shadow register, and configure timer/IRQ via `0x0807AE60` (`0x08010B50`).
pub fn func_08010B50() callconv(.c) void {
    if (!abi.enter(0x08010B50)) return;
    abi.fetches(15);
    abi.pushLr();
    const ctrl = abi.read32(0x08010B70);
    abi.write8(ctrl, abi.read8(ctrl) | 0x08);
    abi.write16(abi.read32(0x08010B74), abi.read16(ctrl));
    abi.setRegNz(&rt.r[0], 2);
    abi.setRegNz(&rt.r[1], 1);
    if (!abi.call(low_peel_9.func_0807AE60, 0x08010B6B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear IRQ bits `0x09`, sync shadow register, and mask via `0x0807AE60` (`0x08010B78`).
pub fn func_08010B78() callconv(.c) void {
    if (!abi.enter(0x08010B78)) return;
    abi.fetches(17);
    abi.pushLr();
    const ctrl = abi.read32(0x08010B9C);
    abi.write8(ctrl, abi.read8(ctrl) & ~@as(u8, 0x09));
    abi.write16(abi.read32(0x08010BA0), abi.read16(ctrl));
    abi.setRegNz(&rt.r[0], 1);
    rt.r[1] = @bitCast(@as(i32, -2));
    if (!abi.call(low_peel_9.func_0807AE60, 0x08010B97)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch 5-arg `(i16 r0, i16 r1, 0x080422E8, packed (arg4<<12 | r3))` via IWRAM trampoline (`0x080422C4`).
pub fn func_080422C4() callconv(.c) void {
    if (!abi.enter(0x080422C4)) return;
    abi.fetches(16);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const arg3_hi = rt.r[3] << 16;
    const arg4 = abi.read32(rt.r[13] +% 8);
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(rt.r[1])));
    rt.r[2] = abi.read32(0x080422E8);
    rt.r[3] = ((arg4 << 28) | arg3_hi) >> 16;
    if (!abi.call(func_0801B888, 0x080422E1)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Transfer `0x4000`-strided BG/OBJ block from bits `[3:2]` of `[0x08043854]` via `0x0801B850` (`0x0804383C`).
pub fn func_0804383C() callconv(.c) void {
    if (!abi.enter(0x0804383C)) return;
    abi.fetches(12);
    abi.pushLr();
    const bank = (abi.read32(abi.read32(0x08043854)) << 28) >> 30;
    rt.r[1] = abi.read32(0x08043858);
    rt.r[0] = (bank << 14) +% rt.r[1];
    if (!abi.call(func_0801B850, 0x08043851)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Transfer `0x4000`-strided BG/OBJ block from bits `[3:2]` of `[0x08043884]` via `0x0801B860` and clear `*(0x0804388C)+0x8D0` (`0x0804385C`).
pub fn func_0804385C() callconv(.c) void {
    if (!abi.enter(0x0804385C)) return;
    abi.fetches(12);
    abi.pushLr();
    const bank = (abi.read32(abi.read32(0x08043884)) << 28) >> 30;
    rt.r[1] = abi.read32(0x08043888);
    rt.r[0] = (bank << 14) +% rt.r[1];
    if (!abi.call(func_0801B860, 0x08043871)) return;

    abi.fetches(11);
    const dst = abi.read32(abi.read32(0x0804388C)) +% (0x8D << 4);
    rt.r[0] = dst;
    abi.setRegNz(&rt.r[1], 0);
    abi.write8(dst, 0);
    abi.popReturn();
}

/// Upload masked `[0..0xF0)` BG/sprite table slice via `0x0801B888` (`0x0804890C`).
pub fn func_0804890C() callconv(.c) void {
    if (!abi.enter(0x0804890C)) return;
    abi.fetches(16);
    abi.pushLr();
    const cur = abi.read16(abi.read32(abi.read32(0x0804892C)) +% 0x2A);
    const mask = abi.read32(0x08048930);
    rt.r[0] = (0xF0 -% cur) & mask;
    rt.r[2] = abi.read32(0x08048934);
    rt.r[3] = abi.read32(0x08048938);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(func_0801B888, 0x08048929)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn uploadBgTileSliceFFA8(
    comptime r2_shift: u5,
    comptime count_shift: u5,
    comptime src_tbl_ref: u32,
    comptime dst_base_ref: u32,
    comptime ret_addr: u32,
) void {
    abi.fetches(21);
    abi.pushLr();
    const idx = rt.r[0] & 0xFFFF;
    const dst_off = (rt.r[2] << r2_shift) >> 16;
    const src_off = (idx << 29) >> 16;
    const tbl = abi.read32(src_tbl_ref) +% 0x18;
    rt.r[3] = tbl;
    rt.r[0] = abi.read32(tbl +% (idx << 5)) +% dst_off;
    rt.r[1] = src_off +% abi.read32(dst_base_ref);
    abi.setRegNz(&rt.r[2], @as(u32, 0x80) << count_shift);
    if (!abi.call(dma.func_0800FFA8, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

fn drawWrappedObj1B888(comptime mask_ref: u32, comptime data_ref: u32, comptime attr_or_ref: u32, comptime is_imm_attr: bool, comptime ret_addr: u32) void {
    abi.fetches(if (is_imm_attr) 19 else 18);
    abi.pushLr();
    rt.r[0] = (rt.r[0] +% 0x200) & abi.read32(mask_ref);
    rt.r[1] = (rt.r[1] +% 0x100) & 0xFF;
    rt.r[2] = abi.read32(data_ref);
    if (is_imm_attr) {
        abi.setRegNz(&rt.r[3], attr_or_ref);
    } else {
        rt.r[3] = abi.read32(attr_or_ref);
    }
    if (!abi.call(func_0801B888, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Decompress LZ77 resource from `0x18`-strided table `[0x08052AB0]+4[r0]` (`0x08052A98`).
pub fn func_08052A98() callconv(.c) void {
    if (!abi.enter(0x08052A98)) return;
    abi.fetches(12);
    abi.pushLr();
    const base = abi.read32(0x08052AB0) +% 4;
    rt.r[3] = base;
    rt.r[2] = (((rt.r[0] << 1) +% rt.r[0]) << 3) +% base;
    rt.r[0] = abi.read32(rt.r[2]);
    if (!abi.call(bios.func_080796D8, 0x08052AAD)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// CpuFastSet upload from `0x18`-strided table `[0x08052ADC]+0xC[r0]` indexed by `[0x08052AE0]` (`0x08052AB4`).
pub fn func_08052AB4() callconv(.c) void {
    if (!abi.enter(0x08052AB4)) return;
    abi.fetches(18);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const tbl = abi.read32(0x08052ADC) +% 0xC;
    const sub: u32 = @as(u32, abi.read16(abi.read32(0x08052AE0))) << 2;
    const slot = ((rt.r[0] << 1) +% rt.r[0]) << 3;
    rt.r[5] = tbl;
    rt.r[3] = slot;
    rt.r[4] = tbl +% (sub +% slot);
    rt.r[0] = abi.read32(rt.r[4]);
    rt.r[2] = (rt.r[2] << 9) >> 11;
    if (!abi.call(bios.func_080796C0, 0x08052AD5)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// DMA tile slice (`0x200` bytes) via `0x0800FFA8` (`0x08054194`).
pub fn func_08054194() callconv(.c) void {
    if (!abi.enter(0x08054194)) return;
    uploadBgTileSliceFFA8(25, 2, 0x080541C0, 0x080541C4, 0x080541BB);
}

/// DMA tile slice (`0x400` bytes) via `0x0800FFA8` (`0x08054610`).
pub fn func_08054610() callconv(.c) void {
    if (!abi.enter(0x08054610)) return;
    uploadBgTileSliceFFA8(26, 3, 0x0805463C, 0x08054640, 0x08054637);
}

/// DMA tile slice (`0x800` bytes) via `0x0800FFA8` (`0x0805505C`).
pub fn func_0805505C() callconv(.c) void {
    if (!abi.enter(0x0805505C)) return;
    uploadBgTileSliceFFA8(27, 4, 0x08055088, 0x0805508C, 0x08055083);
}

/// Set display/blend IRQ flags at `0x08059E3C`/`0x08059E40` and refresh via `0x08010574` (`0x08059E14`).
pub fn func_08059E14() callconv(.c) void {
    if (!abi.enter(0x08059E14)) return;
    abi.fetches(19);
    abi.pushLr();
    const r_a = abi.read32(0x08059E3C);
    abi.write8(r_a, abi.read8(r_a) | 0x08);
    const r_b = abi.read32(0x08059E40);
    abi.write8(r_b, abi.read8(r_b) | 0x01);
    rt.r[1] = r_b;
    rt.r[2] = abi.read8(r_b +% 1);
    rt.r[0] = 0x80 | rt.r[2];
    abi.write8(r_b +% 1, @truncate(rt.r[0]));
    if (!abi.call(low_peel_6.func_08010574, 0x08059E37)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Draw masked sprite from descriptor `[r0+0x24/+0x28/+0x3C/+0x40]` via `0x0801B888` (`0x0806A638`).
pub fn func_0806A638() callconv(.c) void {
    if (!abi.enter(0x0806A638)) return;
    abi.fetches(21);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const mask = abi.read32(0x0806A664);
    rt.r[4] = (abi.read32(rt.r[0] +% 0x24) +% 0x200) & mask;
    rt.r[1] = (abi.read32(rt.r[0] +% 0x28) +% (mask -% 0xFF)) & 0xFF;
    rt.r[2] = abi.read32(rt.r[0] +% 0x3C);
    rt.r[3] = abi.read16(rt.r[0] +% 0x40);
    rt.r[0] = rt.r[4];
    if (!abi.call(func_0801B888, 0x0806A65F)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Sync parent `(r0+0x20)` coordinates `+0x24/+0x28` and render via `0x0801B888` (`0x0806BB20`).
pub fn func_0806BB20() callconv(.c) void {
    if (!abi.enter(0x0806BB20)) return;
    abi.fetches(17);
    abi.pushLr();
    const parent = abi.read32(rt.r[0] +% 0x20);
    const x = abi.read32(parent +% 0x24);
    const y = abi.read32(parent +% 0x28);
    abi.write32(rt.r[0] +% 0x24, x);
    abi.write32(rt.r[0] +% 0x28, y);
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(x)));
    rt.r[1] = @bitCast(abi.signExtend16(@truncate(y)));
    rt.r[2] = abi.read32(0x0806BB44);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(func_0801B888, 0x0806BB3F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Upload 32-byte OBJ palette bank `(r0 & 0xF) + 0x10` from `0x0806CB4C` via `0x08011330` (`0x0806CB34`).
pub fn func_0806CB34() callconv(.c) void {
    if (!abi.enter(0x0806CB34)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[1] = (((rt.r[0] & 0xF) +% 0x10) << 5);
    rt.r[0] = abi.read32(0x0806CB4C);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x0806CB47)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Upload `0x100`-byte OBJ tiles into `0x0601_0000 + ((r1 & [0x0806CC44]) << 5)` via `0x0800FFA8` (`0x0806CC18`).
pub fn func_0806CC18() callconv(.c) void {
    if (!abi.enter(0x0806CC18)) return;
    abi.fetches(21);
    abi.pushLr();
    const slot = (rt.r[1] & abi.read32(0x0806CC44)) << 5;
    rt.r[0] = ((rt.r[0] +% 6) << 8) +% abi.read32(0x0806CC48);
    rt.r[3] = (slot | 0x10000) +% 0x0600_0000;
    rt.r[1] = rt.r[3];
    abi.setRegNz(&rt.r[2], 0x100);
    if (!abi.call(dma.func_0800FFA8, 0x0806CC3F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Select tile descriptor `0x0806CC70[r0]` and upload via `0x0800FE18` (`0x0806CC4C`).
pub fn func_0806CC4C() callconv(.c) void {
    if (!abi.enter(0x0806CC4C)) return;
    abi.fetches(15);
    abi.pushLr();
    const slot = (rt.r[1] & abi.read32(0x0806CC6C)) << 5;
    rt.r[0] = abi.read32(abi.read32(0x0806CC70) +% (rt.r[0] << 2));
    rt.r[2] = slot +% abi.read32(0x0806CC74);
    rt.r[1] = rt.r[2];
    if (!abi.call(func_0800FE18, 0x0806CC67)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Upload `0x580` bytes from `0x0806CCA0` into `0x0601_0000 + ((r0 & [0x0806CC9C]) << 5)` via `0x0800FFA8` (`0x0806CC78`).
pub fn func_0806CC78() callconv(.c) void {
    if (!abi.enter(0x0806CC78)) return;
    abi.fetches(17);
    abi.pushLr();
    const slot = (rt.r[0] & abi.read32(0x0806CC9C)) << 5;
    rt.r[0] = abi.read32(0x0806CCA0);
    rt.r[1] = (slot | 0x10000) +% 0x0600_0000;
    abi.setRegNz(&rt.r[2], 0x580);
    if (!abi.call(dma.func_0800FFA8, 0x0806CC97)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Upload 32-byte palette slot `(r0 & 0x7FF) << 5` from `0x0806CEB8` via `0x08011330` (`0x0806CEA4`).
pub fn func_0806CEA4() callconv(.c) void {
    if (!abi.enter(0x0806CEA4)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[1] = (rt.r[0] << 21) >> 16;
    rt.r[0] = abi.read32(0x0806CEB8);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(dma.func_08011330, 0x0806CEB5)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Draw wrapped `(x+0x200, y+0x100)` OBJ with `attr=0xD000` via `0x0801B888` (`0x0806D7AC`).
pub fn func_0806D7AC() callconv(.c) void {
    if (!abi.enter(0x0806D7AC)) return;
    drawWrappedObj1B888(0x0806D7D4, 0x0806D7D8, 0xD000, true, 0x0806D7CF);
}

/// Draw wrapped `(x+0x200, y+0x100)` OBJ with `[0x0806D808]` attr via `0x0801B888` (`0x0806D7DC`).
pub fn func_0806D7DC() callconv(.c) void {
    if (!abi.enter(0x0806D7DC)) return;
    drawWrappedObj1B888(0x0806D800, 0x0806D804, 0x0806D808, false, 0x0806D7FD);
}

fn popPcReturn() void {
    rt.r[15] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.recompReturn(rt.r[15]);
}

fn clearFlashCmdZero(comptime ret_addr: u32) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_0807B51C, ret_addr)) return;
    abi.fetches(4);
    abi.setRegNz(&rt.r[0], 0);
    popPcReturn();
}

/// Draw masked OBJ at `(r0+[0x0806E0D0], r1+[0x0806E0D8])` with attr from `[*(0x0806E0CC)+0xD+r2]` (`0x0806E098`).
pub fn func_0806E098() callconv(.c) void {
    if (!abi.enter(0x0806E098)) return;
    abi.fetches(24);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const st = abi.read32(abi.read32(0x0806E0CC));
    const attr_hi = @as(u32, abi.read8(st +% 0xD +% rt.r[2])) << 18;
    const mask = abi.read32(0x0806E0D4);
    rt.r[4] = abi.read32(0x0806E0E0);
    rt.r[0] = (rt.r[0] +% abi.read32(0x0806E0D0)) & mask;
    rt.r[1] = (rt.r[1] +% abi.read32(0x0806E0D8)) & 0xFF;
    rt.r[2] = abi.read32(0x0806E0DC);
    rt.r[3] = (attr_hi +% rt.r[4]) >> 16;
    if (!abi.call(func_0801B888, 0x0806E0C5)) return;

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Draw wrapped OBJ from `[r0+0x28, r0+0x2A]` with `0x0806F594` via `0x0801B888` (`0x0806F56C`).
pub fn func_0806F56C() callconv(.c) void {
    if (!abi.enter(0x0806F56C)) return;
    abi.fetches(20);
    abi.pushLr();
    const obj = rt.r[0];
    rt.r[0] = (abi.read16(obj +% 0x28) +% 0x200) & 0x1FF;
    rt.r[1] = (abi.read16(obj +% 0x2A) +% 0x100) & 0xFF;
    rt.r[2] = abi.read32(0x0806F594);
    abi.setRegNz(&rt.r[3], 0);
    if (!abi.call(func_0801B888, 0x0806F591)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Draw wrapped OBJ at `([0x08073D6C], [0x08073D78])` with `attr=0x1000` via `0x0801B888` (`0x08073D40`).
pub fn func_08073D40() callconv(.c) void {
    if (!abi.enter(0x08073D40)) return;
    abi.fetches(21);
    abi.pushLr();
    const mask = abi.read32(0x08073D74);
    rt.r[0] = (abi.read16(abi.read32(0x08073D6C)) +% abi.read32(0x08073D70)) & mask;
    rt.r[1] = (abi.read16(abi.read32(0x08073D78)) +% (mask -% 0xFB)) & 0xFF;
    rt.r[2] = abi.read32(0x08073D7C);
    abi.setRegNz(&rt.r[3], 0x80 << 5);
    if (!abi.call(func_0801B888, 0x08073D67)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Draw fixed-position OBJ at `(0x38, 0x8C)` with data `0x08075B28` and `attr=0x2200` (`0x08075B14`).
pub fn func_08075B14() callconv(.c) void {
    if (!abi.enter(0x08075B14)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[2] = abi.read32(0x08075B28);
    abi.setRegNz(&rt.r[3], 0x88 << 6);
    abi.setRegNz(&rt.r[0], 0x38);
    abi.setRegNz(&rt.r[1], 0x8C);
    if (!abi.call(func_0801B888, 0x08075B25)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Copy `16`-byte block `0x0807ACF8 -> 0x0807ACFC` via `0x0807AFF4` (`0x0807ACE8`).
pub fn func_0807ACE8() callconv(.c) void {
    if (!abi.enter(0x0807ACE8)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0807ACF8);
    rt.r[1] = abi.read32(0x0807ACFC);
    abi.setRegNz(&rt.r[2], 0x10);
    if (!abi.call(low_peel_5.func_0807AFF4, 0x0807ACF5)) return;
    abi.fetches(3);
    popPcReturn();
}

/// Dispatch serial/hardware link callback `0x0807B090(0x0807AD70, r0)` (`0x0807AD64`).
pub fn func_0807AD64() callconv(.c) void {
    if (!abi.enter(0x0807AD64)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[1] = rt.r[0];
    rt.r[0] = abi.read32(0x0807AD70);
    if (!abi.call(low_peel_13.func_0807B090, 0x0807AD6F)) return;
    abi.fetches(3);
    popPcReturn();
}

/// Forward `r0 + 0x400` to SRAM/Flash sector accessor `0x0807B340` (`0x0807B37C`).
pub fn func_0807B37C() callconv(.c) void {
    if (!abi.enter(0x0807B37C)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    abi.setRegNz(&rt.r[4], 0x80 << 4);
    rt.r[0] +%= rt.r[4];
    if (!abi.call(low_peel_9.func_0807B340, 0x0807B389)) return;
    abi.fetches(3);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popPcReturn();
}

/// Clear Flash command state via `0x0807B51C` and return `0` (`0x0807B628`).
pub fn func_0807B628() callconv(.c) void {
    if (!abi.enter(0x0807B628)) return;
    clearFlashCmdZero(0x0807B62F);
}

/// Clear Flash command state via `0x0807B51C` and return `0` (`0x0807B6A2`).
pub fn func_0807B6A2() callconv(.c) void {
    if (!abi.enter(0x0807B6A2)) return;
    clearFlashCmdZero(0x0807B6A9);
}

/// Clear Flash command state via `0x0807B51C` and return `0` (`0x0807B762`).
pub fn func_0807B762() callconv(.c) void {
    if (!abi.enter(0x0807B762)) return;
    clearFlashCmdZero(0x0807B769);
}

/// Spill `{r0..r3}` on stack and invoke `0x0807C508(sp)` (`0x0807CE10`).
pub fn func_0807CE10() callconv(.c) void {
    if (!abi.enter(0x0807CE10)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[13] -%= 0x10;
    abi.write32(rt.r[13], rt.r[0]);
    abi.write32(rt.r[13] +% 4, rt.r[1]);
    abi.write32(rt.r[13] +% 8, rt.r[2]);
    abi.write32(rt.r[13] +% 12, rt.r[3]);
    rt.r[0] = rt.r[13];
    if (!abi.call(low_peel_13.func_0807C508, 0x0807CE23)) return;
    abi.fetches(4);
    rt.r[13] +%= 0x10;
    popPcReturn();
}

/// Set `[0x08010568] = 0x80`, zero `[0x0801056C]` and `[0x08010570]`, and run display init sequence (`0x08010544`).
pub fn func_08010544() callconv(.c) void {
    if (!abi.enter(0x08010544)) return;
    abi.fetches(13);
    abi.pushLr();
    abi.write16(abi.read32(0x08010568), 0x80);
    abi.write16(abi.read32(0x0801056C), 0);
    abi.setRegNz(&rt.r[1], 0);
    abi.write16(abi.read32(0x08010570), 0);
    if (!abi.call(func_08010444, 0x0801055B)) return;

    abi.fetches(4);
    if (!abi.call(func_080104B0, 0x0801055F)) return;

    abi.fetches(4);
    if (!abi.call(low_peel_3.func_080104D4, 0x08010563)) return;

    abi.fetches(4);
    abi.popReturn();
}

fn setupIrqMasksAndTail(
    comptime call_tail: fn () callconv(.c) void,
    comptime tail_arg_ref: ?u32,
    comptime ret1: u32,
    comptime ret2: u32,
    comptime ret3: u32,
) void {
    abi.fetches(7);
    abi.pushLr();
    rt.r[1] = rt.r[0];
    abi.setRegNz(&rt.r[0], 1);
    if (!abi.call(func_0807AE50, ret1)) return;

    abi.fetches(6);
    abi.setRegNz(&rt.r[0], 2);
    abi.setRegNz(&rt.r[1], 2);
    if (!abi.call(low_peel_9.func_0807AE60, ret2)) return;

    abi.fetches(if (tail_arg_ref != null) 5 else 4);
    if (tail_arg_ref) |ref| {
        rt.r[0] = abi.read32(ref);
    }
    if (!abi.call(call_tail, ret3)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Register IRQ handlers `(1, r0)` / `(2, 2)` and flush `[0x08010B14]` (`0x08010AF8`).
pub fn func_08010AF8() callconv(.c) void {
    if (!abi.enter(0x08010AF8)) return;
    setupIrqMasksAndTail(low_peel_3.func_0800FBEC, 0x08010B14, 0x08010B03, 0x08010B0B, 0x08010B11);
}

/// Register IRQ handlers `(1, r0)` / `(2, 2)` and reset hardware state (`0x08010B28`).
pub fn func_08010B28() callconv(.c) void {
    if (!abi.enter(0x08010B28)) return;
    setupIrqMasksAndTail(dma.func_08010AC8, null, 0x08010B33, 0x08010B3B, 0x08010B3F);
}

/// Select IRQ vector `0x08017854[i16([0x08017858])]` via `0x08010AF8` and init audio (`0x08017838`).
pub fn func_08017838() callconv(.c) void {
    if (!abi.enter(0x08017838)) return;
    abi.fetches(12);
    abi.pushLr();
    const tbl = abi.read32(0x08017854);
    const idx = @as(u32, @bitCast(abi.signExtend16(abi.read16(abi.read32(0x08017858))) << 2));
    rt.r[0] = abi.read32(idx +% tbl);
    if (!abi.call(func_08010AF8, 0x0801784D)) return;

    abi.fetches(4);
    if (!abi.call(sound.func_0803D784, 0x08017851)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Reset display/IRQ via `0x08010B18` and reset audio mixer via `0x0803D790` (`0x0801785C`).
pub fn func_0801785C() callconv(.c) void {
    if (!abi.enter(0x0801785C)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_08010B18, 0x08017863)) return;

    abi.fetches(4);
    if (!abi.call(sound.func_0803D790, 0x08017867)) return;

    abi.fetches(4);
    abi.popReturn();
}

fn popReturnPcHw() void {
    const pc_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[15] = pc_val;
    rt.recompReturn(pc_val);
}

/// Clear IRQ mask via `0x0807AE60(0, 0)` and flush `0x0807ACE8` (`0x0807AD00`).
pub fn func_0807AD00() callconv(.c) void {
    if (!abi.enter(0x0807AD00)) return;
    abi.fetches(7);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(low_peel_9.func_0807AE60, 0x0807AD0B)) return;
    abi.fetches(4);
    if (!abi.call(func_0807ACE8, 0x0807AD0F)) return;
    abi.fetches(3);
    popReturnPcHw();
}

/// Reset hardware via `0x0807AD00` and sync audio/state `0x080386E4` (`0x0807AD10`).
pub fn func_0807AD10() callconv(.c) void {
    if (!abi.enter(0x0807AD10)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_0807AD00, 0x0807AD17)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_11.func_080386E4, 0x0807AD1B)) return;
    abi.fetches(3);
    popReturnPcHw();
}

/// Configure Flash timing `0x0807B13C([0x0807AD84])` and finish `0x0807AD64` (`0x0807AD74`).
pub fn func_0807AD74() callconv(.c) void {
    if (!abi.enter(0x0807AD74)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0807AD84);
    if (!abi.call(low_peel_5.func_0807B13C, 0x0807AD7D)) return;
    abi.fetches(4);
    if (!abi.call(func_0807AD64, 0x0807AD81)) return;
    abi.fetches(3);
    popReturnPcHw();
}

/// Poll hardware ready `0x0807AD88` then commit `0x0807ADF0` (`0x0807AE04`).
pub fn func_0807AE04() callconv(.c) void {
    if (!abi.enter(0x0807AE04)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(low_peel_9.func_0807AD88, 0x0807AE0B)) return;
    abi.fetches(4);
    if (!abi.call(low_peel_2.func_0807ADF0, 0x0807AE0F)) return;
    abi.fetches(3);
    popReturnPcHw();
}

/// Fill a `(width, height)` BG tilemap rectangle at `base + x*2 + y*0x40` with `fill_val` (`0x08010C70`).
pub fn func_08010C70() callconv(.c) void {
    if (!abi.enter(0x08010C70)) return;
    abi.fetches(21);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[7]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const base = rt.r[0];
    const tx = rt.r[1] & 0xFFFF;
    const ty = rt.r[2] & 0xFFFF;
    const width = rt.r[3] & 0xFFFF;
    const height = abi.read32(rt.r[13] +% 0x14) & 0xFFFF;
    const fill_val: u16 = @truncate(abi.read32(rt.r[13] +% 0x18));
    const start_addr = base +% (tx << 1) +% (ty << 6);

    var out_r0 = base +% (tx << 1);
    var out_r1 = tx << 1;
    var row: u32 = 0;
    var row_tiles: u32 = 0;
    while (row < height) {
        abi.fetches(9);
        out_r1 = start_addr +% (row_tiles << 1);
        out_r0 = 0;
        row_tiles +%= 0x20;
        row +%= 1;
        while (out_r0 < width) {
            abi.fetches(9);
            abi.write16(out_r1, fill_val);
            out_r1 +%= 2;
            out_r0 = (out_r0 +% 1) & 0xFFFF;
        }
        abi.fetches(8);
        row_tiles &= 0xFFFF;
        row &= 0xFFFF;
    }

    rt.r[0] = out_r0;
    rt.r[1] = out_r1;
    rt.r[2] = row;
    rt.r[3] = row_tiles;
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

/// Reset display/OAM buffers and clear two VRAM/buffer regions via `0x0807AE60`/`0x0807B2DC` (`0x0807AE14`).
pub fn func_0807AE14() callconv(.c) void {
    if (!abi.enter(0x0807AE14)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[0] = 0;
    rt.r[1] = 0;
    if (!abi.call(low_peel_9.func_0807AE60, 0x0807AE1F)) return;

    abi.fetches(7);
    rt.r[0] = abi.read32(0x0807AE3C);
    rt.r[1] = abi.read32(0x0807AE40);
    rt.r[2] = 0x1E;
    if (!abi.call(func_0807B2DC, 0x0807AE29)) return;

    abi.fetches(9);
    rt.r[0] = abi.read32(0x0807AE44);
    rt.r[4] = abi.read32(0x0807AE48);
    rt.r[1] = rt.r[4];
    rt.r[2] = 0x100;
    if (!abi.call(func_0807B2DC, 0x0807AE37)) return;

    abi.fetches(5);
    rt.r[0] = abi.read32(0x0807AE4C);
    abi.write32(rt.r[0], rt.r[4]);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnPcHw();
}

/// Decompress/transfer `(src -> temp -> dst)` via SRAM/WRAM staging buffer (`0x0800FDDC`).
pub fn func_0800FDDC() callconv(.c) void {
    if (!abi.enter(0x0800FDDC)) return;
    abi.fetches(11);
    abi.pushLr();
    abi.pushReg(6);
    abi.pushReg(5);
    abi.pushReg(4);
    abi.pushReg(8);
    const dst = rt.r[0];
    const src = rt.r[1];
    const len = rt.r[2];
    rt.r[6] = dst;
    rt.r[8] = src;
    rt.r[4] = len;
    rt.r[0] = len;
    if (!abi.call(low_peel_3.func_08012D8C, 0x0800FDEF)) return;

    abi.fetches(7);
    const tmp = rt.r[0];
    rt.r[5] = tmp;
    rt.r[0] = dst;
    rt.r[1] = tmp;
    if (!abi.call(low_peel_3.func_0800FE24, 0x0800FDF9)) return;

    abi.fetches(9);
    const len16 = len & 0xFFFF;
    rt.r[4] = len16;
    rt.r[0] = tmp;
    rt.r[1] = src;
    rt.r[2] = len16;
    rt.updateNz(len16);
    if (!abi.call(dma.func_0800FDA4, 0x0800FE07)) return;

    abi.fetches(5);
    rt.r[0] = tmp;
    if (!abi.call(low_peel_3.func_08012E14, 0x0800FE0D)) return;

    abi.fetches(7);
    rt.r[8] = abi.popReg();
    rt.r[4] = abi.popReg();
    rt.r[5] = abi.popReg();
    rt.r[6] = abi.popReg();
    abi.popReturn();
}

fn enableDisplayLayersMask(reg_addr: u32, set_b0: u8) void {
    abi.write8(reg_addr +% 0, (abi.read8(reg_addr +% 0) | set_b0));
    const b1 = abi.read8(reg_addr +% 1);
    abi.write8(reg_addr +% 1, b1 & 0xE0);
}

/// Enable display mode flags with `0x42` phase tag (`0x080702FC`).
pub fn func_080702FC() callconv(.c) void {
    if (!abi.enter(0x080702FC)) return;
    abi.fetches(4);
    abi.pushLr();
    abi.pushReg(4);
    const state = rt.r[0];
    rt.r[4] = state;
    abi.fetches(3);
    if (!abi.call(func_080104B0, 0x08070305)) return;
    abi.fetches(3);
    abi.fetches(50);
    const disp_ptr = abi.read32(0x08070364);
    abi.write8(disp_ptr +% 0, (abi.read8(disp_ptr +% 0) & 0x3F) | 0x9F);
    abi.write8(disp_ptr +% 1, abi.read8(disp_ptr +% 1) & 0xE0);
    const p1 = abi.read32(0x08070368);
    abi.write8(p1, abi.read8(p1) | 0x20);
    const p2 = abi.read32(0x0807036C);
    abi.write8(p2, abi.read8(p2) & 0xDF);
    rt.r[0] = 0x42;
    rt.updateNz(0x42);
    abi.write16(state +% 0x42, 0x42);
    rt.r[4] = abi.popReg();
    abi.popReturn();
}

/// Reset BG window/blend shadow registers and clear `state+0x44` (`0x080703B0`).
pub fn func_080703B0() callconv(.c) void {
    if (!abi.enter(0x080703B0)) return;
    abi.fetches(41);
    abi.write8(abi.read32(0x08070410), 0);
    abi.write8(abi.read32(0x08070414), 0);
    abi.write8(abi.read32(0x08070418), 0xF0);
    abi.write8(abi.read32(0x0807041C), 0);
    const p20 = abi.read32(0x08070420);
    abi.write8(p20 +% 1, abi.read8(p20 +% 1) | 0x20);
    const p24 = abi.read32(0x08070424);
    abi.write8(p24, (abi.read8(p24) | 0x0F) & 0xEF);
    const p28 = abi.read32(0x08070428);
    abi.fetches(3 + 3 + 3 + 8);
    abi.write8(p28, (abi.read8(p28) & 0xF0) | 0x10);
    abi.write16(rt.r[0] +% 0x44, 0);
    rt.r[1] = 0;
    rt.updateNz(0);
    abi.retLr();
}

/// Enable BG/OBJ layers and window bits, clearing `state+0x44` (`0x08070AF0`).
pub fn func_08070AF0() callconv(.c) void {
    if (!abi.enter(0x08070AF0)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.pushReg(4);
    const state = rt.r[0];
    rt.r[4] = state;
    if (!abi.call(func_080104B0, 0x08070AF9)) return;
    abi.fetches(12 + 36);
    enableDisplayLayersMask(abi.read32(0x08070B50), 0xDF);
    const p54 = abi.read32(0x08070B54);
    abi.write8(p54, abi.read8(p54) | 0x20);
    const p58 = abi.read32(0x08070B58);
    const prev58 = abi.read8(p58);
    abi.write8(p58, prev58 | 0x20);
    rt.r[1] = p58;
    rt.r[2] = prev58;
    rt.r[0] = 0;
    rt.updateNz(0);
    abi.write16(state +% 0x44, 0);
    rt.r[4] = abi.popReg();
    abi.popReturn();
}

/// Convert RGB555 components `(r, g, b)` to greyscale RGB555 luminance (`(3r + 6g + b) / 10`) (`0x08074430`).
pub fn func_08074430() callconv(.c) void {
    if (!abi.enter(0x08074430)) return;
    abi.fetches(11);
    abi.pushLr();
    const r = rt.r[0] & 0xFFFF;
    const g = rt.r[1] & 0xFFFF;
    const b = rt.r[2] & 0xFFFF;
    abi.fetches(11);
    rt.r[0] = r *% 3 +% g *% 6 +% b;
    rt.r[1] = 0xA;
    rt.updateNz(0xA);
    if (!abi.call(math.func_0807B488, 0x08074455)) return;

    abi.fetches(14);
    const luma = rt.r[0] & 0xFFFF;
    const grey = (((luma >> 1) << 10) +% (luma << 5) +% luma) & 0xFFFF;
    rt.r[0] = grey;
    rt.r[1] = grey;
    rt.updateNz(grey);
    const lr = abi.popReg();
    rt.r[1] = lr;
    rt.r[15] = lr;
    rt.recompReturn(lr);
}

/// Dereference `*(u8*)ptr` via stack home slot and return via shared Flash helper epilogue (`0x08079A5C`).
pub fn func_08079A5C() callconv(.c) void {
    if (!abi.enter(0x08079A5C)) return;
    abi.fetches(10);
    abi.pushLr();
    abi.pushReg(7);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[0]);
    const byte = abi.read8(abi.read32(rt.r[13]));
    rt.r[0] = byte;
    rt.r[1] = byte;
    rt.updateNz(byte);
    // Inlined tail epilogue enter_08078238(50)
    abi.fetches(6);
    rt.r[13] +%= 4;
    rt.r[7] = abi.popReg();
    const lr = abi.popReg();
    rt.r[1] = lr;
    rt.r[15] = lr;
    rt.recompReturn(lr);
}

const FlashOpCfg = struct {
    frame_size: u32,
    buf_off: u32,
    save_off: u32,
    info_off: u16,
    pre_setup: bool,
    pool_io: u32,
    pool_mask: u32,
    pool_info: u32,
    pool_cmd_aa: u32,
    pool_cmd_55: u32,
    pool_timer: u32,
    ret_setup: u32,
    ret_verify: u32,
};

fn writeFlashChipUnlock(cmd_aa_addr: u32, cmd_55_addr: u32, opcode: u8) void {
    const a5 = abi.read32(cmd_aa_addr);
    const a2 = abi.read32(cmd_55_addr);
    abi.write8(a5, 0xAA);
    abi.write8(a2, 0x55);
    abi.write8(a5, 0x80);
    abi.write8(a5, 0xAA);
    abi.write8(a2, 0x55);
    abi.write8(a5, opcode);
}

fn runFlashEraseAndVerify(comptime cfg: FlashOpCfg) void {
    abi.pushLr();
    abi.pushReg(7);
    rt.r[13] -%= cfg.frame_size;
    const fp = rt.r[13];
    rt.r[7] = fp;

    if (!cfg.pre_setup) {
        rt.r[0] = fp +% cfg.buf_off;
        if (!abi.call(low_peel_9.func_08079A74, cfg.ret_setup)) return;
        abi.fetches(39);
    }

    const io_ptr = abi.read32(cfg.pool_io);
    const mask = abi.read32(cfg.pool_mask);
    const info = abi.read16(abi.read32(abi.read32(cfg.pool_info)) +% cfg.info_off);
    abi.write16(io_ptr, @truncate((abi.read16(io_ptr) & mask) | info));
    writeFlashChipUnlock(cfg.pool_cmd_aa, cfg.pool_cmd_55, 0x10);

    if (cfg.pre_setup) {
        rt.r[0] = fp +% cfg.buf_off;
        if (!abi.call(low_peel_9.func_08079A74, cfg.ret_setup)) return;
    }

    abi.fetches(10);
    rt.r[3] = abi.read32(abi.read32(cfg.pool_timer));
    rt.r[0] = 3;
    rt.r[1] = 0xE0 << 20;
    rt.r[2] = 0xFF;
    rt.updateNz(0xFF);
    if (!abi.call(tail_low.func_0807B458, cfg.ret_verify)) return;

    abi.fetches(22);
    abi.write16(fp +% cfg.save_off, @truncate(rt.r[0]));
    const post_io = abi.read32(cfg.pool_io);
    abi.write16(post_io, @truncate((abi.read16(post_io) & mask) | 3));
    const status = abi.read16(fp +% cfg.save_off);
    rt.r[0] = status;
    rt.r[1] = status;
    rt.updateNz(status);

    // Inlined epilogue from enter_080779F0(76/82)
    abi.fetches(6);
    rt.r[13] +%= cfg.frame_size;
    rt.r[7] = abi.popReg();
    const lr = abi.popReg();
    rt.r[1] = lr;
    rt.r[15] = lr;
    rt.recompReturn(lr);
}

/// Erase full Flash save chip and verify timeout using timing table `+0x10` (`0x08079E78`).
pub fn func_08079E78() callconv(.c) void {
    if (!abi.enter(0x08079E78)) return;
    abi.fetches(39);
    runFlashEraseAndVerify(.{
        .frame_size = 0x48,
        .buf_off = 0x4,
        .save_off = 0x44,
        .info_off = 0x10,
        .pre_setup = true,
        .pool_io = 0x08079EFC,
        .pool_mask = 0x08079F00,
        .pool_info = 0x08079F04,
        .pool_cmd_aa = 0x08079F08,
        .pool_cmd_55 = 0x08079F0C,
        .pool_timer = 0x08079F10,
        .ret_setup = 0x08079EC3,
        .ret_verify = 0x08079ED3,
    });
}

/// Erase full Flash save chip and verify timeout using timing table `+0x24` (`0x0807A3BC`).
pub fn func_0807A3BC() callconv(.c) void {
    if (!abi.enter(0x0807A3BC)) return;
    abi.fetches(10);
    runFlashEraseAndVerify(.{
        .frame_size = 0x4C,
        .buf_off = 0xC,
        .save_off = 0x8,
        .info_off = 0x24,
        .pre_setup = false,
        .pool_io = 0x0807A440,
        .pool_mask = 0x0807A444,
        .pool_info = 0x0807A448,
        .pool_cmd_aa = 0x0807A44C,
        .pool_cmd_55 = 0x0807A450,
        .pool_timer = 0x0807A454,
        .ret_setup = 0x0807A3CD,
        .ret_verify = 0x0807A417,
    });
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08002E88, .{ .name = "func_08002E88", .linkage = .strong });
        @export(&func_08010544, .{ .name = "func_08010544", .linkage = .strong });
        @export(&func_08010AF8, .{ .name = "func_08010AF8", .linkage = .strong });
        @export(&func_08010B28, .{ .name = "func_08010B28", .linkage = .strong });
        @export(&func_08017838, .{ .name = "func_08017838", .linkage = .strong });
        @export(&func_0801785C, .{ .name = "func_0801785C", .linkage = .strong });
        @export(&func_0806E098, .{ .name = "func_0806E098", .linkage = .strong });
        @export(&func_0806F56C, .{ .name = "func_0806F56C", .linkage = .strong });
        @export(&func_08073D40, .{ .name = "func_08073D40", .linkage = .strong });
        @export(&func_08075B14, .{ .name = "func_08075B14", .linkage = .strong });
        @export(&func_0807ACE8, .{ .name = "func_0807ACE8", .linkage = .strong });
        @export(&func_0807AD64, .{ .name = "func_0807AD64", .linkage = .strong });
        @export(&func_0807B37C, .{ .name = "func_0807B37C", .linkage = .strong });
        @export(&func_0807B628, .{ .name = "func_0807B628", .linkage = .strong });
        @export(&func_0807B6A2, .{ .name = "func_0807B6A2", .linkage = .strong });
        @export(&func_0807B762, .{ .name = "func_0807B762", .linkage = .strong });
        @export(&func_0807CE10, .{ .name = "func_0807CE10", .linkage = .strong });
        @export(&func_08052A98, .{ .name = "func_08052A98", .linkage = .strong });
        @export(&func_08052AB4, .{ .name = "func_08052AB4", .linkage = .strong });
        @export(&func_08054194, .{ .name = "func_08054194", .linkage = .strong });
        @export(&func_08054610, .{ .name = "func_08054610", .linkage = .strong });
        @export(&func_0805505C, .{ .name = "func_0805505C", .linkage = .strong });
        @export(&func_08059E14, .{ .name = "func_08059E14", .linkage = .strong });
        @export(&func_0806A638, .{ .name = "func_0806A638", .linkage = .strong });
        @export(&func_0806BB20, .{ .name = "func_0806BB20", .linkage = .strong });
        @export(&func_0806CB34, .{ .name = "func_0806CB34", .linkage = .strong });
        @export(&func_0806CC18, .{ .name = "func_0806CC18", .linkage = .strong });
        @export(&func_0806CC4C, .{ .name = "func_0806CC4C", .linkage = .strong });
        @export(&func_0806CC78, .{ .name = "func_0806CC78", .linkage = .strong });
        @export(&func_0806CEA4, .{ .name = "func_0806CEA4", .linkage = .strong });
        @export(&func_0806D7AC, .{ .name = "func_0806D7AC", .linkage = .strong });
        @export(&func_0806D7DC, .{ .name = "func_0806D7DC", .linkage = .strong });
        @export(&func_080045A8, .{ .name = "func_080045A8", .linkage = .strong });
        @export(&func_08004F34, .{ .name = "func_08004F34", .linkage = .strong });
        @export(&func_080076FC, .{ .name = "func_080076FC", .linkage = .strong });
        @export(&func_0800F094, .{ .name = "func_0800F094", .linkage = .strong });
        @export(&func_0800F170, .{ .name = "func_0800F170", .linkage = .strong });
        @export(&func_0800F578, .{ .name = "func_0800F578", .linkage = .strong });
        @export(&func_0800FE18, .{ .name = "func_0800FE18", .linkage = .strong });
        @export(&func_0801036C, .{ .name = "func_0801036C", .linkage = .strong });
        @export(&func_08010444, .{ .name = "func_08010444", .linkage = .strong });
        @export(&func_080104B0, .{ .name = "func_080104B0", .linkage = .strong });
        @export(&func_08010AD8, .{ .name = "func_08010AD8", .linkage = .strong });
        @export(&func_08010B18, .{ .name = "func_08010B18", .linkage = .strong });
        @export(&func_08010B44, .{ .name = "func_08010B44", .linkage = .strong });
        @export(&func_08010B50, .{ .name = "func_08010B50", .linkage = .strong });
        @export(&func_08010B78, .{ .name = "func_08010B78", .linkage = .strong });
        @export(&func_08012BAC, .{ .name = "func_08012BAC", .linkage = .strong });
        @export(&func_080134E0, .{ .name = "func_080134E0", .linkage = .strong });
        @export(&func_080134EC, .{ .name = "func_080134EC", .linkage = .strong });
        @export(&func_08015A08, .{ .name = "func_08015A08", .linkage = .strong });
        @export(&func_08015A38, .{ .name = "func_08015A38", .linkage = .strong });
        @export(&func_08015A54, .{ .name = "func_08015A54", .linkage = .strong });
        @export(&func_0801B850, .{ .name = "func_0801B850", .linkage = .strong });
        @export(&func_0801B860, .{ .name = "func_0801B860", .linkage = .strong });
        @export(&func_0801B870, .{ .name = "func_0801B870", .linkage = .strong });
        @export(&func_0801B888, .{ .name = "func_0801B888", .linkage = .strong });
        @export(&func_0801B8A8, .{ .name = "func_0801B8A8", .linkage = .strong });
        @export(&func_0801DAB8, .{ .name = "func_0801DAB8", .linkage = .strong });
        @export(&func_080422C4, .{ .name = "func_080422C4", .linkage = .strong });
        @export(&func_0804383C, .{ .name = "func_0804383C", .linkage = .strong });
        @export(&func_0804385C, .{ .name = "func_0804385C", .linkage = .strong });
        @export(&func_0804890C, .{ .name = "func_0804890C", .linkage = .strong });
        @export(&func_08069B1C, .{ .name = "func_08069B1C", .linkage = .strong });
        @export(&func_08079958, .{ .name = "func_08079958", .linkage = .strong });
        @export(&func_08079A00, .{ .name = "func_08079A00", .linkage = .strong });
        @export(&func_0807AE10, .{ .name = "func_0807AE10", .linkage = .strong });
        @export(&func_0807AE50, .{ .name = "func_0807AE50", .linkage = .strong });
        @export(&func_0807B2DC, .{ .name = "func_0807B2DC", .linkage = .strong });
        @export(&func_0807B310, .{ .name = "func_0807B310", .linkage = .strong });
        @export(&func_0807B51C, .{ .name = "func_0807B51C", .linkage = .strong });
        @export(&func_0807AD00, .{ .name = "func_0807AD00", .linkage = .strong });
        @export(&func_0807AD10, .{ .name = "func_0807AD10", .linkage = .strong });
        @export(&func_0807AD74, .{ .name = "func_0807AD74", .linkage = .strong });
        @export(&func_0807AE04, .{ .name = "func_0807AE04", .linkage = .strong });
        @export(&func_0807AE14, .{ .name = "func_0807AE14", .linkage = .strong });
        @export(&func_08010C70, .{ .name = "func_08010C70", .linkage = .strong });
        @export(&func_0800FDDC, .{ .name = "func_0800FDDC", .linkage = .strong });
        @export(&func_080702FC, .{ .name = "func_080702FC", .linkage = .strong });
        @export(&func_080703B0, .{ .name = "func_080703B0", .linkage = .strong });
        @export(&func_08070AF0, .{ .name = "func_08070AF0", .linkage = .strong });
        @export(&func_08074430, .{ .name = "func_08074430", .linkage = .strong });
        @export(&func_08079A5C, .{ .name = "func_08079A5C", .linkage = .strong });
        @export(&func_08079E78, .{ .name = "func_08079E78", .linkage = .strong });
        @export(&func_0807A3BC, .{ .name = "func_0807A3BC", .linkage = .strong });
        @export(&func_0801122C, .{ .name = "func_0801122C", .linkage = .strong });
        @export(&func_0801129C, .{ .name = "func_0801129C", .linkage = .strong });
        @export(&func_080112C0, .{ .name = "func_080112C0", .linkage = .strong });
        @export(&func_080113D0, .{ .name = "func_080113D0", .linkage = .strong });
    }
}

test "decodeActiveLowKeys maps active-low KEYINPUT bits to active-high mask" {
    try std.testing.expectEqual(@as(u16, 0x0000), decodeActiveLowKeys(0x03FF));
    try std.testing.expectEqual(@as(u16, 0x000F), decodeActiveLowKeys(0x03F0));
    try std.testing.expectEqual(@as(u16, 0x03FF), decodeActiveLowKeys(0x0000));
    try std.testing.expectEqual(@as(u16, 0x0000), decodeActiveLowKeys(0xFFFF));
}

test "register literal pool tables are sorted and contiguous in ROM" {
    try std.testing.expectEqual(@as(usize, 13), bg_scroll_ptr_addrs.len);
    try std.testing.expectEqual(@as(usize, 4), window_reg_ptr_addrs.len);
    for (1..bg_scroll_ptr_addrs.len) |i| {
        try std.testing.expectEqual(bg_scroll_ptr_addrs[i - 1] + 4, bg_scroll_ptr_addrs[i]);
    }
    for (1..window_reg_ptr_addrs.len) |i| {
        try std.testing.expectEqual(window_reg_ptr_addrs[i - 1] + 4, window_reg_ptr_addrs[i]);
    }
}
