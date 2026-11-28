//! Lifted m4a (MusicPlayer2000) track parameter handlers and audio driver entry wrappers.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const decls = @import("decls");
const abi = @import("abi.zig");

/// Byte offset of the current bytecode sequence cursor inside `MusicPlayerTrack`.
pub const track_cmd_cursor_off: u32 = 0x40;

pub const TrackOffset = struct {
    pub const mod_type: u32 = 0x1E;
    pub const mod_depth: u32 = 0x1F;
    pub const mod_speed: u32 = 0x26;
    pub const mod_delay: u32 = 0x27;
    pub const param_2c: u32 = 0x2C;
    pub const param_2d: u32 = 0x2D;
    pub const param_2e: u32 = 0x2E;
    pub const param_2f: u32 = 0x2F;
};

/// Advance `track + 0x40` command pointer by 1 byte, storing the byte at `track + field_off`.
pub inline fn advanceTrackByte(track_addr: u32, comptime field_off: u32) u32 {
    const cmd_ptr = abi.read32(track_addr +% track_cmd_cursor_off);
    const val = abi.read8(cmd_ptr);
    abi.write8(track_addr +% field_off, val);
    const next_ptr = cmd_ptr +% 1;
    abi.write32(track_addr +% track_cmd_cursor_off, next_ptr);
    return next_ptr;
}

fn readTrackCmdHandler(comptime field_off: u32, comptime fetches_n: u32, comptime r2_is_ptr: bool) void {
    abi.fetches(fetches_n);
    const track = rt.r[1];
    const cmd_ptr = abi.read32(track +% track_cmd_cursor_off);
    const val = abi.read8(cmd_ptr);
    const field_addr = track +% field_off;
    abi.write8(field_addr, val);
    const next_ptr = cmd_ptr +% 1;
    abi.write32(track +% track_cmd_cursor_off, next_ptr);
    rt.r[2] = if (r2_is_ptr) field_addr else val;
    abi.setRegNz(&rt.r[0], next_ptr);
    abi.retLr();
}

pub fn func_08079610() callconv(.c) void {
    if (!abi.enter(0x08079610)) return;
    readTrackCmdHandler(TrackOffset.param_2c, 11, false);
}

pub fn func_08079624() callconv(.c) void {
    if (!abi.enter(0x08079624)) return;
    readTrackCmdHandler(TrackOffset.param_2d, 11, true);
}

pub fn func_08079638() callconv(.c) void {
    if (!abi.enter(0x08079638)) return;
    readTrackCmdHandler(TrackOffset.param_2e, 11, true);
}

pub fn func_0807964C() callconv(.c) void {
    if (!abi.enter(0x0807964C)) return;
    readTrackCmdHandler(TrackOffset.param_2f, 11, true);
}

pub fn func_08079660() callconv(.c) void {
    if (!abi.enter(0x08079660)) return;
    readTrackCmdHandler(TrackOffset.mod_type, 8, false);
}

pub fn func_0807966C() callconv(.c) void {
    if (!abi.enter(0x0807966C)) return;
    readTrackCmdHandler(TrackOffset.mod_depth, 8, false);
}

pub fn func_08079678() callconv(.c) void {
    if (!abi.enter(0x08079678)) return;
    readTrackCmdHandler(TrackOffset.mod_speed, 11, true);
}

pub fn func_0807968C() callconv(.c) void {
    if (!abi.enter(0x0807968C)) return;
    readTrackCmdHandler(TrackOffset.mod_delay, 11, true);
}

/// m4a VSync sound DMA wrapper (`0x0803D79C` -> `0x08077C04`).
pub fn func_0803D79C() callconv(.c) void {
    if (!abi.enter(0x0803D79C)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_08077C04, 0x0803D7A3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// m4a per-frame main mixer wrapper (`0x0803D7AC` -> `0x080782E4`).
pub fn func_0803D7AC() callconv(.c) void {
    if (!abi.enter(0x0803D7AC)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_080782E4, 0x0803D7B3)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// m4a no-op stub (`0x0803D710`).
pub fn func_0803D710() callconv(.c) void {
    if (!abi.enter(0x0803D710)) return;
    abi.fetches(3);
    abi.retLr();
}

/// Write audio status halfword at `0x0300_00E8` (`0x0803D714`).
pub fn func_0803D714() callconv(.c) void {
    if (!abi.enter(0x0803D714)) return;
    abi.fetches(5);
    const dst = abi.read32(0x0803D71C);
    abi.write16(dst, @truncate(rt.r[0]));
    rt.r[1] = dst;
    abi.retLr();
}

/// Write audio status halfword at `0x0300_00EA` (`0x0803D720`).
pub fn func_0803D720() callconv(.c) void {
    if (!abi.enter(0x0803D720)) return;
    abi.fetches(5);
    const dst = abi.read32(0x0803D728);
    abi.write16(dst, @truncate(rt.r[0]));
    rt.r[1] = dst;
    abi.retLr();
}

/// Reset audio slot halfword `[0x0300_00E6] = 0xFFFF` (`0x0803D954`).
pub fn func_0803D954() callconv(.c) void {
    if (!abi.enter(0x0803D954)) return;
    abi.fetches(7);
    const dst = abi.read32(0x0803D960);
    const fill = abi.read32(0x0803D964);
    abi.write16(dst, @truncate(fill));
    rt.r[1] = dst;
    rt.r[2] = fill;
    abi.setRegNz(&rt.r[0], fill);
    abi.retLr();
}

/// Zero 64 bytes (`4 x 16`) at `[r0]` (`0x080779D8`).
pub fn func_080779D8() callconv(.c) void {
    if (!abi.enter(0x080779D8)) return;
    abi.fetches(13);
    const saved_r4 = rt.r[4];
    var dst = rt.r[0];
    var i: u32 = 0;
    while (i < 16) : (i += 1) {
        abi.write32(dst, 0);
        dst +%= 4;
    }
    rt.r[0] = dst;
    rt.r[1] = 0;
    rt.r[2] = 0;
    rt.r[3] = 0;
    rt.r[4] = saved_r4;
    rt.updateNz(0);
    abi.retLr();
}

/// m4a `ply_tune` / track 32-bit LE command fetch into `track + 0x28`, stepping cursor `+0x40` by 4 (`0x080795B4`).
pub fn func_080795B4() callconv(.c) void {
    if (!abi.enter(0x080795B4)) return;
    abi.fetches(29);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const track = rt.r[1];
    const cmd = abi.read32(track +% track_cmd_cursor_off);
    const b0: u32 = abi.read8(cmd);
    const b1: u32 = abi.read8(cmd +% 1);
    const b2: u32 = abi.read8(cmd +% 2);
    const b3: u32 = abi.read8(cmd +% 3);
    const word: u32 = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24);
    abi.write32(track +% 0x28, word);
    const next_cmd = cmd +% 4;
    abi.write32(track +% track_cmd_cursor_off, next_cmd);

    rt.r[2] = next_cmd;
    rt.r[3] = b3 << 24;
    rt.updateNz(word);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

fn callSoundCue(comptime target: fn () callconv(.c) void, comptime id: u32, comptime ret_addr: u32) void {
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], id);
    if (!abi.call(target, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Play sound effect `0x68` via `0x0803D880` (`0x08038028`).
pub fn func_08038028() callconv(.c) void {
    if (!abi.enter(0x08038028)) return;
    callSoundCue(func_0803D880, 0x68, 0x08038031);
}

/// Play music track `0xD7` via `0x0803D8C8` (`0x08038034`).
pub fn func_08038034() callconv(.c) void {
    if (!abi.enter(0x08038034)) return;
    callSoundCue(decls.func_0803D8C8, 0xD7, 0x0803803D);
}

/// Play music track `0xDC` via `0x0803D8C8` (`0x08038040`).
pub fn func_08038040() callconv(.c) void {
    if (!abi.enter(0x08038040)) return;
    callSoundCue(decls.func_0803D8C8, 0xDC, 0x08038049);
}

/// Play music track `0xDD` via `0x0803D8C8` (`0x0803804C`).
pub fn func_0803804C() callconv(.c) void {
    if (!abi.enter(0x0803804C)) return;
    callSoundCue(decls.func_0803D8C8, 0xDD, 0x08038055);
}

/// Play music track `0xDE` via `0x0803D8C8` (`0x08038058`).
pub fn func_08038058() callconv(.c) void {
    if (!abi.enter(0x08038058)) return;
    callSoundCue(decls.func_0803D8C8, 0xDE, 0x08038061);
}

/// Fade out audio volume using rate `0xFE` via `0x080796F0` (`0x080386D8`).
pub fn func_080386D8() callconv(.c) void {
    if (!abi.enter(0x080386D8)) return;
    callSoundCue(decls.func_080796F0, 0xFE, 0x080386E1);
}

fn callSoundVoid(comptime target: fn () callconv(.c) void, comptime ret_addr: u32) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(target, ret_addr)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Stop/end m4a driver helper proc `0x0803D70C` (`0x0803D700`).
pub fn func_0803D700() callconv(.c) void {
    if (!abi.enter(0x0803D700)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0803D70C);
    if (!abi.call(decls.func_0801329C, 0x0803D709)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Play song table entry `*(0x0803D774 + r0 * 4)` via `0x080787CC` (`0x0803D760`).
pub fn func_0803D760() callconv(.c) void {
    if (!abi.enter(0x0803D760)) return;
    abi.fetches(9);
    abi.pushLr();
    const tbl = abi.read32(0x0803D774);
    rt.r[0] = abi.read32(tbl +% (rt.r[0] << 2));
    if (!abi.call(decls.func_080787CC, 0x0803D76F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Play/configure song header `r0 << 8` via `0x080787CC` (`0x0803D778`).
pub fn func_0803D778() callconv(.c) void {
    if (!abi.enter(0x0803D778)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] <<= 8;
    if (!abi.call(decls.func_080787CC, 0x0803D781)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Trigger `m4aSongNumStop` helper `0x08078934` (`0x0803D784`).
pub fn func_0803D784() callconv(.c) void {
    if (!abi.enter(0x0803D784)) return;
    callSoundVoid(decls.func_08078934, 0x0803D78B);
}

/// Update m4a sound driver frame `0x080788B8` (`0x0803D790`).
pub fn func_0803D790() callconv(.c) void {
    if (!abi.enter(0x0803D790)) return;
    callSoundVoid(decls.func_080788B8, 0x0803D797);
}

/// Play signed sound effect `i16(r0)` via `0x0803D830` (`0x0803D880`).
pub fn func_0803D880() callconv(.c) void {
    if (!abi.enter(0x0803D880)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = @bitCast(abi.signExtend16(@truncate(rt.r[0])));
    if (!abi.call(decls.func_0803D830, 0x0803D88B)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Set audio config word `0x0803D938` into `[0x0803D934]` and init via `0x08078424` (`0x0803D920`).
pub fn func_0803D920() callconv(.c) void {
    if (!abi.enter(0x0803D920)) return;
    abi.fetches(9);
    abi.pushLr();
    const val = abi.read32(0x0803D938);
    rt.r[1] = abi.read32(0x0803D934);
    rt.r[2] = val;
    rt.cpuAdd(&rt.r[0], val, 0, true);
    abi.write16(rt.r[1], @truncate(rt.r[0]));
    if (!abi.call(decls.func_08078424, 0x0803D92F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Play sound effect `0x84` (`0x080492A0`).
pub fn func_080492A0() callconv(.c) void {
    if (!abi.enter(0x080492A0)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0x84);
    if (!abi.call(func_0803D880, 0x080492A9)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Copy `u8([*(0x0804E51C) + 0x4C])` into `r0+0x1E` and play sound effect `0x74` (`0x0804E504`).
pub fn func_0804E504() callconv(.c) void {
    if (!abi.enter(0x0804E504)) return;
    abi.fetches(11);
    abi.pushLr();
    rt.r[1] = abi.read8(abi.read32(abi.read32(0x0804E51C)) +% 0x4C);
    abi.write16(rt.r[0] +% 0x1E, @truncate(rt.r[1]));
    abi.setRegNz(&rt.r[0], 0x74);
    if (!abi.call(func_0803D880, 0x0804E517)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Set audio track/channel parameter `4` on `[0x08050C6C]` via `0x08078488` (`0x08050C5C`).
pub fn func_08050C5C() callconv(.c) void {
    if (!abi.enter(0x08050C5C)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08050C6C);
    abi.setRegNz(&rt.r[1], 4);
    if (!abi.call(func_08078488, 0x08050C67)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Play sound effect `0xCC` (`0x08051868`).
pub fn func_08051868() callconv(.c) void {
    if (!abi.enter(0x08051868)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0xCC);
    if (!abi.call(func_0803D880, 0x08051871)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward audio init to `0x080775B0` (`0x080782E4`).
pub fn func_080782E4() callconv(.c) void {
    if (!abi.enter(0x080782E4)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080775B0, 0x080782EB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Look up music track entry `u16(r0)` (`8`-byte header + `12`-byte player slot) and play via `0x080789E8` (`0x080782F0`).
pub fn func_080782F0() callconv(.c) void {
    if (!abi.enter(0x080782F0)) return;
    abi.fetches(18);
    abi.pushLr();
    const tbl = abi.read32(0x08078314);
    const entry = (rt.r[0] << 16 >> 13) +% abi.read32(0x08078318);
    const player_idx: u32 = abi.read16(entry +% 4);
    const slot_off = ((player_idx << 1) +% player_idx) << 2;
    const player_ptr = abi.read32(slot_off +% tbl);
    rt.r[3] = player_idx;
    rt.r[2] = player_ptr;
    rt.r[1] = abi.read32(entry);
    rt.r[0] = player_ptr;
    if (!abi.call(decls.func_080789E8, 0x08078311)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward audio reset/stop to `0x0807821C` (`0x08078450`).
pub fn func_08078450() callconv(.c) void {
    if (!abi.enter(0x08078450)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_0807821C, 0x08078457)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Forward masked channel count `u16(r1)` to `0x08078238` (`0x08078488`).
pub fn func_08078488() callconv(.c) void {
    if (!abi.enter(0x08078488)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[1] &= 0xFFFF;
    if (!abi.call(decls.func_08078238, 0x08078493)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch audio helper `[0x08078618]` via `0x0807B450` (`0x08078608`).
pub fn func_08078608() callconv(.c) void {
    if (!abi.enter(0x08078608)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[1] = abi.read32(abi.read32(0x08078618));
    if (!abi.call(decls.func_0807B450, 0x08078613)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch audio helper `[0x0807862C]` via `0x0807B450` (`0x0807861C`).
pub fn func_0807861C() callconv(.c) void {
    if (!abi.enter(0x0807861C)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[1] = abi.read32(abi.read32(0x0807862C));
    if (!abi.call(decls.func_0807B450, 0x08078627)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Fetch extended MML track command byte from `r1+0x40` and dispatch table `0x0807959C` via `0x0807B454` (`0x08079580`).
pub fn func_08079580() callconv(.c) void {
    if (!abi.enter(0x08079580)) return;
    abi.fetches(13);
    abi.pushLr();
    const cur = abi.read32(rt.r[1] +% 0x40);
    const op: u32 = abi.read8(cur);
    rt.r[2] = cur +% 1;
    abi.write32(rt.r[1] +% 0x40, rt.r[2]);
    const slot = (op << 2) +% abi.read32(0x0807959C);
    rt.r[3] = slot;
    rt.r[2] = abi.read32(slot);
    if (!abi.call(decls.func_0807B454, 0x08079597)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Invoke DMA/PCM callback `[0x080795B0]` via `0x0807B454` (`0x080795A0`).
pub fn func_080795A0() callconv(.c) void {
    if (!abi.enter(0x080795A0)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[2] = abi.read32(abi.read32(0x080795B0));
    if (!abi.call(decls.func_0807B454, 0x080795AB)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Reset m4a sound driver channels (`0x0803D714`, `0x0803D720`, `0x08078258`) and sound flags `[0x0803D754]`/`[0x0803D75C]` (`0x0803D72C`).
pub fn func_0803D72C() callconv(.c) void {
    if (!abi.enter(0x0803D72C)) return;
    abi.fetches(8);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    abi.setRegNz(&rt.r[4], @as(u32, 0x80) << 1);
    rt.r[0] = rt.r[4];
    if (!abi.call(func_0803D714, 0x0803D739)) return;

    abi.fetches(5);
    rt.r[0] = rt.r[4];
    if (!abi.call(func_0803D720, 0x0803D73F)) return;

    abi.fetches(4);
    if (!abi.call(decls.func_08078258, 0x0803D743)) return;

    abi.fetches(11);
    const val: u16 = @truncate(abi.read32(0x0803D758));
    abi.write16(abi.read32(0x0803D754), val);
    abi.write16(abi.read32(0x0803D75C), val);
    rt.r[1] = abi.read32(0x0803D758);
    rt.r[2] = rt.r[1];
    rt.r[0] = abi.read32(0x0803D75C);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Start music player `[0x0803D980]` (`0x08078488(..., 2)`) and spawn War Room proc `[0x0803D984]` (`0x0803D968`).
pub fn func_0803D968() callconv(.c) void {
    if (!abi.enter(0x0803D968)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read32(0x0803D980);
    abi.setRegNz(&rt.r[1], 2);
    if (!abi.call(func_08078488, 0x0803D973)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x0803D984);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x0803D97B)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Upload audio/menu palette (`0x08011330`), spawn fade overlay `0x080123A8`, and tag byte `+0x3A = 9` (`0x0803DAA0`).
pub fn func_0803DAA0() callconv(.c) void {
    if (!abi.enter(0x0803DAA0)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 8;
    rt.r[0] = abi.read32(0x0803DAD4);
    abi.setRegNz(&rt.r[1], @as(u32, 0x80) << 1);
    abi.setRegNz(&rt.r[2], 0x20);
    if (!abi.call(decls.func_08011330, 0x0803DAB1)) return;

    abi.fetches(13);
    abi.write32(rt.r[13], @as(u32, 0x80) << 8);
    abi.write32(rt.r[13] +% 4, 0);
    abi.setRegNz(&rt.r[0], 6);
    abi.setRegNz(&rt.r[1], 2);
    rt.r[2] = abi.read32(0x0803DAD8);
    rt.r[3] = abi.read32(0x0803DADC);
    if (!abi.call(decls.func_080123A8, 0x0803DAC7)) return;

    abi.fetches(8);
    abi.write8(rt.r[0] +% 0x3A, 9);
    rt.r[0] +%= 0x3A;
    abi.setRegNz(&rt.r[1], 9);
    rt.r[13] +%= 8;
    abi.popReturn();
}

/// Query selected slot `0x08015E3C(read8([0x0803DAF8]+1))` and configure sound/preview table `0x0803FB84` (`0x0803DAE0`).
pub fn func_0803DAE0() callconv(.c) void {
    if (!abi.enter(0x0803DAE0)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[0] = abi.read8(abi.read32(0x0803DAF8) +% 1);
    if (!abi.call(decls.func_08015E3C, 0x0803DAEB)) return;

    abi.fetches(7);
    const val: u32 = @bitCast(abi.signExtend8(@truncate(rt.r[0])));
    abi.setRegNz(&rt.r[0], val);
    rt.r[1] = abi.read32(0x0803DAFC);
    if (!abi.call(decls.func_0803FB84, 0x0803DAF5)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Reset state `[0x0804E674]` (`+0x2A = 0x80`, `+0x31 = 0`), spawn proc `[0x0804E678]`, and play SFX `0x74` (`0x0804E650`).
pub fn func_0804E650() callconv(.c) void {
    if (!abi.enter(0x0804E650)) return;
    abi.fetches(14);
    abi.pushLr();
    const st = abi.read32(abi.read32(0x0804E674));
    abi.write16(st +% 0x2A, 0x80);
    abi.write8(st +% 0x31, 0);
    rt.r[0] = abi.read32(0x0804E678);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x0804E669)) return;

    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0x74);
    if (!abi.call(func_0803D880, 0x0804E66F)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Play SFX `0xDA` via `0x0803D8C8` and spawn proc `[0x08051CA4]` via `0x0801320C` (`0x08051C90`).
pub fn func_08051C90() callconv(.c) void {
    if (!abi.enter(0x08051C90)) return;
    abi.fetches(6);
    abi.pushLr();
    abi.setRegNz(&rt.r[0], 0xDA);
    if (!abi.call(decls.func_0803D8C8, 0x08051C99)) return;

    abi.fetches(6);
    rt.r[0] = abi.read32(0x08051CA4);
    abi.setRegNz(&rt.r[1], 0);
    if (!abi.call(decls.func_0801320C, 0x08051CA1)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Commit display regs `0x080104B0`, configure blend `[0x080521E0..0x080521E8]`, and play SFX `0xCF` (`0x080521A4`).
pub fn func_080521A4() callconv(.c) void {
    if (!abi.enter(0x080521A4)) return;
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(decls.func_080104B0, 0x080521AB)) return;

    abi.fetches(26);
    const ctrl = abi.read32(0x080521E0);
    abi.write8(ctrl, (abi.read8(ctrl) & 0x3F) | 0x42);
    abi.write8(ctrl +% 1, abi.read8(ctrl +% 1) | 0x18);
    abi.write16(abi.read32(0x080521E4), 0xA);
    abi.write16(abi.read32(0x080521E8), 8);
    abi.setRegNz(&rt.r[0], 0xCF);
    if (!abi.call(decls.func_0803D8C8, 0x080521DB)) return;

    abi.fetches(4);
    abi.popReturn();
}

/// Dispatch 7 BGM/SFX track slot updates via `0x080791DC` from pool `[0x0803D80C..0x0803D82C]` (`0x0803D7B8`).
pub fn func_0803D7B8() callconv(.c) void {
    if (!abi.enter(0x0803D7B8)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const player_ptr = abi.read32(0x0803D810);
    const param_ptr = abi.read32(0x0803D814);
    rt.r[5] = player_ptr;
    rt.r[4] = param_ptr;

    const entries = [_]struct { pool: u32, ret: u32 }{
        .{ .pool = 0x0803D80C, .ret = 0x0803D7C9 },
        .{ .pool = 0x0803D818, .ret = 0x0803D7D3 },
        .{ .pool = 0x0803D81C, .ret = 0x0803D7DD },
        .{ .pool = 0x0803D820, .ret = 0x0803D7E7 },
        .{ .pool = 0x0803D824, .ret = 0x0803D7F1 },
        .{ .pool = 0x0803D828, .ret = 0x0803D7FB },
        .{ .pool = 0x0803D82C, .ret = 0x0803D805 },
    };
    inline for (entries, 0..) |e, i| {
        if (i != 0) abi.fetches(7);
        rt.r[0] = abi.read32(e.pool);
        rt.r[2] = abi.read16(param_ptr);
        rt.r[1] = player_ptr;
        if (!abi.call(decls.func_080791DC, e.ret)) return;
    }

    abi.fetches(5);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Dispatch dual sound setup handles from ROM pools (`0x08052200`).
pub fn func_08052200() callconv(.c) void {
    if (!abi.enter(0x08052200)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.r[0] = abi.read32(0x08052214);
    if (!abi.call(decls.func_0801329C, 0x08052209)) return;
    abi.fetches(5);
    rt.r[0] = abi.read32(0x08052218);
    if (!abi.call(decls.func_0801329C, 0x0805220F)) return;
    abi.fetches(4);
    abi.popReturn();
}

/// Decode big-endian 24-bit channel offset and merge status from `0x08077A58` (`0x08077A80`).
pub fn func_08077A80() callconv(.c) void {
    if (!abi.enter(0x08077A80)) return;
    abi.fetches(3);
    abi.pushLr();
    abi.fetches(13);
    const ptr = abi.read32(rt.r[1] +% 0x40);
    rt.r[2] = ptr;
    var val: u32 = abi.read8(ptr +% 3);
    val <<= 8;
    const b2: u32 = abi.read8(ptr +% 2);
    val |= b2;
    val <<= 8;
    const b1: u32 = abi.read8(ptr +% 1);
    val |= b1;
    val <<= 8;
    rt.r[3] = b1;
    rt.r[0] = val;
    rt.updateNz(rt.r[0]);
    if (!abi.call(decls.func_08077A58, 0x08077A99)) return;
    abi.fetches(6);
    rt.r[0] |= rt.r[3];
    rt.updateNz(rt.r[0]);
    abi.write32(rt.r[1] +% 0x40, rt.r[0]);
    abi.popReturn();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08038028, .{ .name = "func_08038028", .linkage = .strong });
        @export(&func_080782E4, .{ .name = "func_080782E4", .linkage = .strong });
        @export(&func_080782F0, .{ .name = "func_080782F0", .linkage = .strong });
        @export(&func_08078450, .{ .name = "func_08078450", .linkage = .strong });
        @export(&func_08078488, .{ .name = "func_08078488", .linkage = .strong });
        @export(&func_08078608, .{ .name = "func_08078608", .linkage = .strong });
        @export(&func_0807861C, .{ .name = "func_0807861C", .linkage = .strong });
        @export(&func_08079580, .{ .name = "func_08079580", .linkage = .strong });
        @export(&func_080795A0, .{ .name = "func_080795A0", .linkage = .strong });
        @export(&func_08050C5C, .{ .name = "func_08050C5C", .linkage = .strong });
        @export(&func_08051868, .{ .name = "func_08051868", .linkage = .strong });
        @export(&func_08038034, .{ .name = "func_08038034", .linkage = .strong });
        @export(&func_08038040, .{ .name = "func_08038040", .linkage = .strong });
        @export(&func_0803804C, .{ .name = "func_0803804C", .linkage = .strong });
        @export(&func_08038058, .{ .name = "func_08038058", .linkage = .strong });
        @export(&func_080386D8, .{ .name = "func_080386D8", .linkage = .strong });
        @export(&func_0803D700, .{ .name = "func_0803D700", .linkage = .strong });
        @export(&func_0803D710, .{ .name = "func_0803D710", .linkage = .strong });
        @export(&func_0803D714, .{ .name = "func_0803D714", .linkage = .strong });
        @export(&func_0803D720, .{ .name = "func_0803D720", .linkage = .strong });
        @export(&func_0803D760, .{ .name = "func_0803D760", .linkage = .strong });
        @export(&func_0803D778, .{ .name = "func_0803D778", .linkage = .strong });
        @export(&func_0803D784, .{ .name = "func_0803D784", .linkage = .strong });
        @export(&func_0803D790, .{ .name = "func_0803D790", .linkage = .strong });
        @export(&func_0803D79C, .{ .name = "func_0803D79C", .linkage = .strong });
        @export(&func_0803D7AC, .{ .name = "func_0803D7AC", .linkage = .strong });
        @export(&func_0803D880, .{ .name = "func_0803D880", .linkage = .strong });
        @export(&func_0803D920, .{ .name = "func_0803D920", .linkage = .strong });
        @export(&func_0803D954, .{ .name = "func_0803D954", .linkage = .strong });
        @export(&func_080492A0, .{ .name = "func_080492A0", .linkage = .strong });
        @export(&func_0804E504, .{ .name = "func_0804E504", .linkage = .strong });
        @export(&func_080779D8, .{ .name = "func_080779D8", .linkage = .strong });
        @export(&func_080795B4, .{ .name = "func_080795B4", .linkage = .strong });
        @export(&func_08079610, .{ .name = "func_08079610", .linkage = .strong });
        @export(&func_08079624, .{ .name = "func_08079624", .linkage = .strong });
        @export(&func_08079638, .{ .name = "func_08079638", .linkage = .strong });
        @export(&func_0807964C, .{ .name = "func_0807964C", .linkage = .strong });
        @export(&func_08079660, .{ .name = "func_08079660", .linkage = .strong });
        @export(&func_0807966C, .{ .name = "func_0807966C", .linkage = .strong });
        @export(&func_08079678, .{ .name = "func_08079678", .linkage = .strong });
        @export(&func_0807968C, .{ .name = "func_0807968C", .linkage = .strong });
        @export(&func_0803D72C, .{ .name = "func_0803D72C", .linkage = .strong });
        @export(&func_0803D968, .{ .name = "func_0803D968", .linkage = .strong });
        @export(&func_0803DAA0, .{ .name = "func_0803DAA0", .linkage = .strong });
        @export(&func_0803DAE0, .{ .name = "func_0803DAE0", .linkage = .strong });
        @export(&func_0804E650, .{ .name = "func_0804E650", .linkage = .strong });
        @export(&func_08051C90, .{ .name = "func_08051C90", .linkage = .strong });
        @export(&func_080521A4, .{ .name = "func_080521A4", .linkage = .strong });
        @export(&func_0803D7B8, .{ .name = "func_0803D7B8", .linkage = .strong });
        @export(&func_08052200, .{ .name = "func_08052200", .linkage = .strong });
        @export(&func_08077A80, .{ .name = "func_08077A80", .linkage = .strong });
    }
}

test "MusicPlayerTrack offsets stay distinct and ordered" {
    try std.testing.expect(TrackOffset.mod_type < TrackOffset.mod_depth);
    try std.testing.expect(TrackOffset.mod_depth < TrackOffset.mod_speed);
    try std.testing.expect(TrackOffset.mod_speed < TrackOffset.mod_delay);
    try std.testing.expect(TrackOffset.mod_delay < TrackOffset.param_2c);
    try std.testing.expectEqual(@as(u32, 0x40), track_cmd_cursor_off);
}
