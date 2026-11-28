//! Lifted GBA BIOS SWI wrapper functions (`0x080796A0..0x080796DC`).

const std = @import("std");
const rt = @import("runtime");
const abi = @import("abi.zig");
const hal = @import("hal.zig");

/// No-op callback stub (`0x080796A0`).
pub fn noop() void {}

/// Typed cross-module bridge calling GBA BIOS `Div` (`SWI 0x06`, `func_080796C8`) with exact ABI state.
pub inline fn divSwiCall(comptime ret_addr: u32) bool {
    return abi.call(func_080796C8, ret_addr);
}

pub fn func_080796A0() callconv(.c) void {
    if (!abi.enter(0x080796A0)) return;
    abi.fetches(3);
    noop();
    abi.retLr();
}

/// Perform GBA BIOS `BgAffineSet` (`SWI 0x0E`, `0x080796BC`).
pub fn bgAffineSet(src: u32, dst: u32, count: u32) void {
    hal.bios.bgAffineSet(src, dst, count);
}

pub fn func_080796BC() callconv(.c) void {
    if (!abi.enter(0x080796BC)) return;
    abi.fetches(6);
    hal.bios.invoke(.bg_affine_set);
    abi.retLr();
}

/// Perform GBA BIOS `CpuFastSet` (`SWI 0x0C`, `0x080796C0`).
pub fn cpuFastSet(src: u32, dst: u32, control: u32) void {
    hal.bios.cpuFastSet(src, dst, control);
}

pub fn func_080796C0() callconv(.c) void {
    if (!abi.enter(0x080796C0)) return;
    abi.fetches(6);
    hal.bios.invoke(.cpu_fast_set);
    abi.retLr();
}

/// Perform GBA BIOS `CpuSet` (`SWI 0x0B`, `0x080796C4`).
pub fn cpuSet(src: u32, dst: u32, control: u32) void {
    hal.bios.cpuSet(src, dst, control);
}

pub fn func_080796C4() callconv(.c) void {
    if (!abi.enter(0x080796C4)) return;
    abi.fetches(6);
    hal.bios.invoke(.cpu_set);
    abi.retLr();
}

/// Perform signed integer division via GBA BIOS `Div` (`SWI 0x06`, `0x080796C8`).
pub fn div(num: i32, den: i32) i32 {
    return hal.bios.div(num, den).quot;
}

pub fn func_080796C8() callconv(.c) void {
    if (!abi.enter(0x080796C8)) return;
    abi.fetches(6);
    hal.bios.invoke(.div);
    abi.retLr();
}

/// Perform signed modulo via GBA BIOS `Div` (`SWI 0x06`, returning `r1` in `r0`, `0x080796CC`).
pub fn mod(num: i32, den: i32) i32 {
    return hal.bios.div(num, den).rem;
}

pub fn func_080796CC() callconv(.c) void {
    if (!abi.enter(0x080796CC)) return;
    abi.fetches(7);
    hal.bios.invoke(.div);
    abi.copyRegFlags(&rt.r[0], rt.r[1]);
    abi.retLr();
}

/// Decompress Huffman stream via GBA BIOS `HuffUnComp` (`SWI 0x13`, `0x080796D4`).
pub fn huffUnComp(src: u32, dst: u32) void {
    hal.bios.huffUnComp(src, dst);
}

pub fn func_080796D4() callconv(.c) void {
    if (!abi.enter(0x080796D4)) return;
    abi.fetches(6);
    hal.bios.invoke(.huff_uncomp);
    abi.retLr();
}

/// Decompress LZ77 stream directly to VRAM via GBA BIOS `LZ77UnCompVram` (`SWI 0x12`, `0x080796D8`).
pub fn lz77UnCompVram(src: u32, dst: u32) void {
    hal.bios.lz77UnCompVram(src, dst);
}

pub fn func_080796D8() callconv(.c) void {
    if (!abi.enter(0x080796D8)) return;
    abi.fetches(6);
    hal.bios.invoke(.lz77_uncomp_vram);
    abi.retLr();
}

/// Decompress LZ77 stream to WRAM via GBA BIOS `LZ77UnCompWram` (`SWI 0x11`, `0x080796DC`).
pub fn lz77UnCompWram(src: u32, dst: u32) void {
    hal.bios.lz77UnCompWram(src, dst);
}

pub fn func_080796DC() callconv(.c) void {
    if (!abi.enter(0x080796DC)) return;
    abi.fetches(6);
    hal.bios.invoke(.lz77_uncomp_wram);
    abi.retLr();
}

/// Decompress RLE stream directly to VRAM via GBA BIOS `RLUnCompVram` (`SWI 0x15`, `0x080796E8`).
pub fn rlUnCompVram(src: u32, dst: u32) void {
    hal.bios.rlUnCompVram(src, dst);
}

pub fn func_080796E8() callconv(.c) void {
    if (!abi.enter(0x080796E8)) return;
    abi.fetches(6);
    hal.bios.invoke(.rl_uncomp_vram);
    abi.retLr();
}

/// Decompress RLE stream to WRAM via GBA BIOS `RLUnCompWram` (`SWI 0x14`, `0x080796EC`).
pub fn rlUnCompWram(src: u32, dst: u32) void {
    hal.bios.rlUnCompWram(src, dst);
}

pub fn func_080796EC() callconv(.c) void {
    if (!abi.enter(0x080796EC)) return;
    abi.fetches(6);
    hal.bios.invoke(.rl_uncomp_wram);
    abi.retLr();
}


test "game.bios module compiles cleanly" {
    _ = noop;
}
