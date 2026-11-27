//! Lifted GBA PPU/OAM shadow register, palette fade, and VRAM bulk-copy helpers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");
const dma = @import("dma.zig");

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
    if (!abi.call(decls.func_0801A61C, 0x080134E7)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// OAM queue flush wrapper B (`0x080134EC` -> `0x0801A660`).
pub fn func_080134EC() callconv(.c) void {
    if (!abi.enter(0x080134EC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0801A660, 0x080134F3)) return;
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
    if (!abi.call(decls.func_08014B14, 0x08015A13)) return;
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
    if (!abi.call(decls.func_0807B450, 0x0801B859)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Indirect call via `r1` to IWRAM handler `0x0300_6CCD` (`0x0801B860`).
pub fn func_0801B860() callconv(.c) void {
    if (!abi.enter(0x0801B860)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[1] = abi.read32(0x0801B86C);
    if (!abi.call(decls.func_0807B450, 0x0801B869)) return;
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
    if (!abi.call(decls.func_0807B458, 0x0801B881)) return;
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
    if (!abi.call(decls.func_0807B45C, 0x0801B89D)) return;
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
    if (!abi.call(decls.func_0807B458, 0x0801B8B5)) return;
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
    if (!abi.call(decls.func_0807B45C, 0x0801DAD3)) return;
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
    if (!abi.call(decls.func_0800FE24, 0x0800FE1F)) return;
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
    if (!abi.call(decls.func_080103AC, 0x08010377)) return;
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
    if (!abi.call(decls.func_0807AE60, 0x08010AF1)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Clear/flush hardware state block `0x08010B24` via `0x0800FBEC` (`0x08010B18`).
pub fn func_08010B18() callconv(.c) void {
    if (!abi.enter(0x08010B18)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08010B24);
    if (!abi.call(decls.func_0800FBEC, 0x08010B21)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward to `func_08010AD8` (`0x08010B44`).
pub fn func_08010B44() callconv(.c) void {
    if (!abi.enter(0x08010B44)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08010AD8, 0x08010B4B)) return;
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
    if (!abi.call(decls.func_0807AE60, 0x08010B6B)) return;
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
    if (!abi.call(decls.func_0807AE60, 0x08010B97)) return;
    abi.fetches(4);
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08002E88, .{ .name = "func_08002E88", .linkage = .strong });
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
        @export(&func_08069B1C, .{ .name = "func_08069B1C", .linkage = .strong });
        @export(&func_08079958, .{ .name = "func_08079958", .linkage = .strong });
        @export(&func_08079A00, .{ .name = "func_08079A00", .linkage = .strong });
        @export(&func_0807AE10, .{ .name = "func_0807AE10", .linkage = .strong });
        @export(&func_0807AE50, .{ .name = "func_0807AE50", .linkage = .strong });
        @export(&func_0807B2DC, .{ .name = "func_0807B2DC", .linkage = .strong });
        @export(&func_0807B310, .{ .name = "func_0807B310", .linkage = .strong });
        @export(&func_0807B51C, .{ .name = "func_0807B51C", .linkage = .strong });
    }
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
