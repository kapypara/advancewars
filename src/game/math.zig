//! Lifted core math, PRNG, and trig utility functions for Advance Wars.

const std = @import("std");
const builtin = @import("builtin");
const rt = @import("runtime");
const abi = @import("abi.zig");
const bios = @import("bios.zig");
const hw = @import("hw.zig");
const low_peel_13 = @import("low_peel_13.zig");
const low_peel_17 = @import("low_peel_17.zig");
const low_peel_18 = @import("low_peel_18.zig");
const low_peel_2 = @import("low_peel_2.zig");
const types = @import("types.zig");

/// Advance the Advance Wars 32-bit PRNG state: `((4*s + 2) * (4*s + 3)) >> 2`.
pub fn nextRngSeed(seed: u32) u32 {
    const scaled = seed << 2;
    return ((scaled +% 2) *% (scaled +% 3)) >> 2;
}

/// Typed cross-module bridge calling PRNG helper `func_08003918` with exact ABI state.
pub inline fn nextRngCall(comptime ret_addr: u32) bool {
    return abi.call(func_08003918, ret_addr);
}

/// Typed cross-module bridge calling Q12 sine helper `func_0807AED4` with exact ABI state.
pub inline fn sinDegCall(comptime ret_addr: u32) bool {
    return abi.call(func_0807AED4, ret_addr);
}

/// Typed cross-module bridge calling Q12 cosine helper `func_0807AF30` with exact ABI state.
pub inline fn cosDegCall(comptime ret_addr: u32) bool {
    return abi.call(func_0807AF30, ret_addr);
}

/// Typed cross-module bridge calling signed 32-bit division helper `func_0807B488` with exact ABI state.
pub inline fn divSigned32Call(comptime ret_addr: u32) bool {
    return abi.call(func_0807B488, ret_addr);
}

/// Typed cross-module bridge calling unsigned 32-bit modulo helper `func_0807B6AC` with exact ABI state.
pub inline fn modUnsigned32Call(comptime ret_addr: u32) bool {
    return abi.call(func_0807B6AC, ret_addr);
}

/// Advance global PRNG seed stored at `[0x08010A98]` and return new value (`0x08010A84`).
pub fn advanceRng() u32 {
    const seed_ptr = abi.read32(0x08010A98);
    const seed = abi.read32(seed_ptr);
    const next = nextRngSeed(seed);
    abi.write32(seed_ptr, next);
    return next;
}

pub fn func_08010A84() callconv(.c) void {
    if (!abi.enter(0x08010A84)) return;
    abi.fetches(11);
    const seed_ptr = abi.read32(0x08010A98);
    const seed = abi.read32(seed_ptr);
    const scaled = seed << 2;
    const f0 = scaled +% 2;
    const f1 = scaled +% 3;
    const next = (f0 *% f1) >> 2;
    rt.r[1] = seed_ptr;
    rt.r[2] = f1;
    abi.setRegNz(&rt.r[0], next);
    abi.write32(seed_ptr, next);
    abi.retLr();
}

pub const SinIndex = struct {
    idx: u8,
    negate: bool,
};

/// Fold any signed integer degree angle into `[0, 359]`, then into `[0, 90]` + sign flag.
pub fn normalizeSinDeg(deg: i32) SinIndex {
    var d = deg;
    while (d < 0) d +%= 360;
    while (d > 359) d -%= 360;
    const negate = d > 179;
    var q = if (negate) d - 180 else d;
    if (q > 90) q = 180 - q;
    return .{ .idx = @intCast(q), .negate = negate };
}

/// Return signed Q12 sine for integer degrees `i32(r0)` (`0x0807AED4`).
pub fn func_0807AED4() callconv(.c) void {
    if (!abi.enter(0x0807AED4)) return;
    abi.fetches(6);
    const deg: i32 = @bitCast(rt.r[0]);
    var d: i32 = deg;
    rt.r[3] = types.addr.sin_table_q12;
    if (d < 0) {
        abi.fetches(4);
        while (d < 0) {
            abi.fetches(5);
            d +%= 360;
        }
    }
    abi.fetches(5);
    if (d > 359) {
        abi.fetches(3);
        while (d > 359) {
            abi.fetches(5);
            d -%= 360;
        }
    }

    const norm = normalizeSinDeg(deg);
    rt.r[2] = @bitCast(d);
    abi.fetches(5);
    if (norm.negate) abi.fetches(3);
    const half_deg = if (norm.negate) d - 180 else d;
    abi.fetches(4);
    if (half_deg > 90) abi.fetches(4);
    abi.fetches(4);

    const idx_u32: u32 = norm.idx;
    var entry_addr: u32 = undefined;
    rt.cpuAdd(&entry_addr, idx_u32 << 1, types.addr.sin_table_q12, true);
    const raw = abi.read16(entry_addr);
    if (norm.negate) {
        abi.fetches(8);
        var neg_u32: u32 = undefined;
        rt.cpuSub(&neg_u32, 0, raw, true);
        const neg_i16: i16 = @truncate(@as(i32, @bitCast(neg_u32)));
        rt.r[1] = idx_u32;
        abi.setRegNz(&rt.r[0], @bitCast(@as(i32, neg_i16)));
    } else {
        abi.fetches(7);
        abi.setRegNz(&rt.r[1], 0);
        rt.r[0] = @bitCast(@as(i32, @as(i16, @bitCast(raw))));
    }
    abi.fetches(3);
    abi.retLr();
}

/// Return signed cosine for integer degrees via `sin(deg + 90)` (`0x0807AF30`).
pub fn func_0807AF30() callconv(.c) void {
    if (!abi.enter(0x0807AF30)) return;
    abi.fetches(6);
    abi.pushLr();
    rt.cpuAdd(&rt.r[0], rt.r[0], 0x5A, true);
    if (!abi.call(func_0807AED4, 0x0807AF39)) return;
    abi.fetches(5);
    const signed_val: i32 = abi.signExtend16(@truncate(rt.r[0]));
    abi.setRegNz(&rt.r[0], @bitCast(signed_val));
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// [Reference/Test-only — native Zig callers use `@divTrunc` directly]
/// Signed 32-bit truncating division matching libgcc `__divsi3` (returns `0` on divide-by-zero
/// and wraps `minInt(i32) / -1` to `minInt(i32)`).
pub fn divSigned32(num: i32, den: i32) i32 {
    if (den == 0) return 0;
    const num_u: u32 = @bitCast(num);
    const den_u: u32 = @bitCast(den);
    const abs_num: u32 = if (num < 0) 0 -% num_u else num_u;
    const abs_den: u32 = if (den < 0) 0 -% den_u else den_u;
    const quot: u32 = abs_num / abs_den;
    return @bitCast(if ((num ^ den) < 0) 0 -% quot else quot);
}

/// Signed 32-bit division runtime helper (`__divsi3`, `0x0807B488`).
pub fn func_0807B488() callconv(.c) void {
    if (!abi.enter(0x0807B488)) return;
    if (rt.r[1] == 0) {
        abi.fetches(9);
        abi.pushLr();
        if (!abi.call(hw.func_0807B51C, 0x0807B517)) return;
        abi.fetches(4);
        abi.setRegNz(&rt.r[0], 0);
        rt.r[15] = abi.popReg();
        rt.recompReturn(rt.r[15]);
        return;
    }

    abi.fetches(14);
    abi.pushReg(4);
    const sign_xor = rt.r[0] ^ rt.r[1];
    rt.r[12] = sign_xor;

    var rem: u32 = if (@as(i32, @bitCast(rt.r[0])) < 0) 0 -% rt.r[0] else rt.r[0];
    var den: u32 = if (@as(i32, @bitCast(rt.r[1])) < 0) 0 -% rt.r[1] else rt.r[1];
    var quot: u32 = 0;
    var bit: u32 = 1;

    if (rem >= den) {
        while (den < 0x1000_0000 and den < rem) {
            abi.fetches(13);
            den <<= 4;
            bit <<= 4;
        }
        while (den < 0x8000_0000 and den < rem) {
            abi.fetches(13);
            den <<= 1;
            bit <<= 1;
        }
        while (true) {
            abi.fetches(24);
            if (rem >= den) {
                rem -%= den;
                quot |= bit;
            }
            if (rem >= (den >> 1)) {
                rem -%= (den >> 1);
                quot |= (bit >> 1);
            }
            if (rem >= (den >> 2)) {
                rem -%= (den >> 2);
                quot |= (bit >> 2);
            }
            if (rem >= (den >> 3)) {
                rem -%= (den >> 3);
                quot |= (bit >> 3);
            }
            if (rem == 0) break;
            bit >>= 4;
            if (bit == 0) break;
            den >>= 4;
        }
    }

    rt.r[1] = den;
    rt.r[2] = quot;
    rt.r[3] = bit;
    rt.r[0] = if (@as(i32, @bitCast(sign_xor)) < 0) 0 -% quot else quot;
    rt.r[4] = abi.popReg();
    abi.fetches(10);
    abi.retLr();
}

const Radix16ModResult = struct {
    rem: u32,
    den: u32,
    r2: u32,
    r3: u32,
    r12: u32,
};

/// [Reference/Test-only — native Zig callers use `%` directly]
/// Unsigned 32-bit modulo (`returns 0` on divide-by-zero).
pub fn modUnsigned32(num: u32, den: u32) u32 {
    if (den == 0) return 0;
    return num % den;
}

/// [Reference/Test-only — native Zig callers use `@rem` directly]
/// Signed 32-bit truncating modulo matching libgcc `__modsi3` (`returns 0` on divide-by-zero).
pub fn modSigned32(num: i32, den: i32) i32 {
    if (den == 0) return 0;
    const num_u: u32 = @bitCast(num);
    const den_u: u32 = @bitCast(den);
    const abs_num: u32 = if (num < 0) 0 -% num_u else num_u;
    const abs_den: u32 = if (den < 0) 0 -% den_u else den_u;
    const rem: u32 = abs_num % abs_den;
    return @bitCast(if (num < 0) 0 -% rem else rem);
}

fn modU32Radix16(num_in: u32, den_in: u32) Radix16ModResult {
    var rem = num_in;
    var den = den_in;
    var bit: u32 = 1;
    while (true) {
        abi.fetches(4);
        if (den >= 0x1000_0000) break;
        abi.fetches(4);
        if (den >= rem) break;
        abi.fetches(5);
        den <<= 4;
        bit <<= 4;
    }
    abi.fetches(3);
    while (true) {
        abi.fetches(4);
        if (den >= 0x8000_0000) break;
        abi.fetches(4);
        if (den >= rem) break;
        abi.fetches(5);
        den <<= 1;
        bit <<= 1;
    }

    var r2: u32 = 0;
    var r12: u32 = bit;
    while (true) {
        abi.fetches(5);
        r2 = 0;
        if (rem >= den) {
            abi.fetches(3);
            rem -%= den;
        }
        abi.fetches(5);
        if (rem >= (den >> 1)) {
            abi.fetches(8);
            rem -%= (den >> 1);
            r2 |= std.math.rotr(u32, bit, 1);
        }
        abi.fetches(5);
        if (rem >= (den >> 2)) {
            abi.fetches(8);
            rem -%= (den >> 2);
            r2 |= std.math.rotr(u32, bit, 2);
        }
        abi.fetches(5);
        if (rem >= (den >> 3)) {
            abi.fetches(8);
            rem -%= (den >> 3);
            r2 |= std.math.rotr(u32, bit, 3);
        }
        r12 = bit;
        abi.fetches(5);
        if (rem == 0) break;
        abi.fetches(4);
        bit >>= 4;
        if (bit == 0) break;
        abi.fetches(4);
        den >>= 4;
    }

    abi.fetches(6);
    r2 &= 0xE000_0000;
    var out_r3 = bit;
    if (r2 != 0) {
        abi.fetches(7);
        if ((r2 & std.math.rotr(u32, r12, 3)) != 0) {
            abi.fetches(4);
            rem +%= den >> 3;
        }
        abi.fetches(7);
        if ((r2 & std.math.rotr(u32, r12, 2)) != 0) {
            abi.fetches(4);
            rem +%= den >> 2;
        }
        abi.fetches(7);
        out_r3 = std.math.rotr(u32, r12, 1);
        if ((r2 & out_r3) != 0) {
            abi.fetches(4);
            rem +%= den >> 1;
        }
    }
    return .{ .rem = rem, .den = den, .r2 = r2, .r3 = out_r3, .r12 = r12 };
}

/// Unsigned 32-bit modulo runtime helper (`__umodsi3`, `0x0807B6AC`).
pub fn func_0807B6AC() callconv(.c) void {
    if (!abi.enter(0x0807B6AC)) return;
    abi.fetches(4);
    if (rt.r[1] == 0) {
        hw.func_0807B762();
        return;
    }
    abi.fetches(5);
    abi.setRegNz(&rt.r[3], 1);
    if (rt.r[0] < rt.r[1]) {
        abi.fetches(3);
        abi.retLr();
        return;
    }
    abi.fetches(5);
    abi.pushReg(4);
    const res = modU32Radix16(rt.r[0], rt.r[1]);
    rt.r[0] = res.rem;
    rt.r[1] = res.den;
    rt.r[2] = res.r2;
    rt.r[3] = res.r3;
    rt.r[12] = res.r12;
    abi.fetches(4);
    rt.r[4] = abi.popReg();
    abi.retLr();
}

/// Signed 32-bit modulo runtime helper (`__modsi3`, `0x0807B564`).
pub fn func_0807B564() callconv(.c) void {
    if (!abi.enter(0x0807B564)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[3], 1);
    if (rt.r[1] == 0) {
        hw.func_0807B628();
        return;
    }
    abi.fetches(3);
    const orig_den: i32 = @bitCast(rt.r[1]);
    if (orig_den < 0) abi.fetches(3);
    const abs_den: u32 = if (orig_den < 0) 0 -% rt.r[1] else rt.r[1];

    abi.fetches(6);
    abi.pushReg(4);
    abi.pushReg(0);
    const orig_num: i32 = @bitCast(rt.r[0]);
    if (orig_num < 0) abi.fetches(3);
    const abs_num: u32 = if (orig_num < 0) 0 -% rt.r[0] else rt.r[0];

    abi.fetches(4);
    if (abs_num >= abs_den) {
        abi.fetches(4);
        const res = modU32Radix16(abs_num, abs_den);
        rt.r[0] = res.rem;
        rt.r[1] = res.den;
        rt.r[2] = res.r2;
        rt.r[3] = res.r3;
        rt.r[12] = res.r12;
    } else {
        rt.r[0] = abs_num;
        rt.r[1] = abs_den;
    }

    abi.fetches(5);
    const saved_num: i32 = @bitCast(abi.popReg());
    if (saved_num < 0) {
        abi.fetches(3);
        rt.r[0] = 0 -% rt.r[0];
    }
    abi.fetches(4);
    rt.r[4] = abi.popReg();
    abi.retLr();
}

/// Read signed 16-bit halfword from the global pointer at `0x0800FD0C` (`0x0800FCFA`).
pub fn readSignedGlobal16() i32 {
    const ptr = abi.read32(0x0800FD0C);
    return abi.signExtend16(abi.read16(ptr));
}

pub fn func_0800FCFA() callconv(.c) void {
    if (!abi.enter(0x0800FCFA)) return;
    abi.fetches(10);
    const signed_val = readSignedGlobal16();
    abi.setRegNz(&rt.r[0], @bitCast(signed_val));
    abi.retLr();
}

inline fn q12Mul(a: u32, b: u32) u32 {
    return a *% b;
}

inline fn q12Shift(val: u32) u32 {
    return @bitCast(@as(i32, @bitCast(val)) >> 12);
}

/// Multiply column-major 3x3 fixed-point Q12 matrix `m` by 3D vector `v` (`(M * v) >> 12`).
pub fn mulMat3Vec3Q12(v: [3]u32, m: [9]u32) [3]u32 {
    const x = q12Shift(q12Mul(m[0], v[0]) +% q12Mul(m[3], v[1]) +% q12Mul(m[6], v[2]));
    const y = q12Shift(q12Mul(m[1], v[0]) +% q12Mul(m[4], v[1]) +% q12Mul(m[7], v[2]));
    const z = q12Shift(q12Mul(m[2], v[0]) +% q12Mul(m[5], v[1]) +% q12Mul(m[8], v[2]));
    return .{ x, y, z };
}

/// 3x3 fixed-point Q12 matrix * 3D vector (`out = M * v >> 12`) (`0x0806CF50`).
pub fn func_0806CF50() callconv(.c) void {
    if (!abi.enter(0x0806CF50)) return;
    abi.fetches(39);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const v: [3]u32 = .{
        abi.read32(rt.r[0]),
        abi.read32(rt.r[0] +% 4),
        abi.read32(rt.r[0] +% 8),
    };
    const m_addr = rt.r[1];
    const m: [9]u32 = .{
        abi.read32(m_addr),
        abi.read32(m_addr +% 0x04),
        abi.read32(m_addr +% 0x08),
        abi.read32(m_addr +% 0x0C),
        abi.read32(m_addr +% 0x10),
        abi.read32(m_addr +% 0x14),
        abi.read32(m_addr +% 0x18),
        abi.read32(m_addr +% 0x1C),
        abi.read32(m_addr +% 0x20),
    };
    const out_addr = rt.r[2];

    const res = mulMat3Vec3Q12(v, m);
    abi.write32(out_addr, res[0]);
    abi.write32(out_addr +% 4, res[1]);
    abi.write32(out_addr +% 8, res[2]);

    const z1 = q12Mul(m[5], v[1]);
    const z2 = q12Mul(m[8], v[2]);
    rt.r[1] = z2;
    rt.r[2] = out_addr;
    rt.r[3] = z1;
    rt.updateNz(res[2]);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;

    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// 3D fixed-point Q12 vector dot product (`(a . b) >> 12`) (`0x0806D23C`).
pub fn func_0806D23C() callconv(.c) void {
    if (!abi.enter(0x0806D23C)) return;
    abi.fetches(19);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const a = rt.r[0];
    const b = rt.r[1];
    const a0 = abi.read32(a);
    const a1 = abi.read32(a +% 4);
    const a2 = abi.read32(a +% 8);
    const p0 = q12Mul(abi.read32(b), a0);
    const p1 = q12Mul(abi.read32(b +% 4), a1);
    const p2 = q12Mul(abi.read32(b +% 8), a2);
    const res = q12Shift(p0 +% p1 +% p2);

    rt.r[2] = a2;
    rt.r[3] = a1;
    abi.setRegNz(&rt.r[0], res);
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;

    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// 3D fixed-point Q12 vector cross product (`out = (a x b) >> 12`, note arg component order matches GBA disassembly) (`0x0806D260`).
pub fn func_0806D260() callconv(.c) void {
    if (!abi.enter(0x0806D260)) return;
    abi.fetches(30);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    const a = rt.r[0];
    const b = rt.r[1];
    const out = rt.r[2];
    const a0 = abi.read32(a);
    const a1 = abi.read32(a +% 4);
    const a2 = abi.read32(a +% 8);
    const b0 = abi.read32(b);
    const b1 = abi.read32(b +% 4);
    const b2 = abi.read32(b +% 8);

    const cx = q12Shift(q12Mul(b2, a1) -% q12Mul(b1, a2));
    abi.write32(out, cx);

    const cy = q12Shift(q12Mul(b0, a2) -% q12Mul(b2, a0));
    abi.write32(out +% 4, cy);

    const p_b1_a0 = q12Mul(b1, a0);
    const p_b0_a1 = q12Mul(b0, a1);
    const cz = q12Shift(p_b1_a0 -% p_b0_a1);
    abi.write32(out +% 8, cz);

    rt.r[1] = p_b0_a1;
    rt.r[2] = out;
    rt.r[3] = cy;
    rt.updateNz(cz);

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;

    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[0] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Calls `func_08010A84` and returns `0` (`pop {r1}; bx r1`).
pub fn func_0803D4F0() callconv(.c) void {
    abi.fetches(5);
    abi.pushLr();
    if (!abi.call(func_08010A84, 0x0803D4F7)) return;
    abi.fetches(5);
    abi.setRegNz(&rt.r[0], 0);
    const lr_val = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[1] = lr_val;
    rt.r[15] = lr_val;
    rt.recompReturn(lr_val);
}

/// Return uniform-like pseudo-random integer in `[r1, r0)` using `advanceRng` and BIOS `mod` (`0x08003918`).
pub fn func_08003918() callconv(.c) void {
    if (!abi.enter(0x08003918)) return;
    abi.fetches(7);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.cpuAdd(&rt.r[4], rt.r[0], 0, true);
    rt.cpuAdd(&rt.r[5], rt.r[1], 0, true);
    if (!abi.call(func_08010A84, 0x08003923)) return;

    abi.fetches(7);
    rt.cpuSub(&rt.r[4], rt.r[4], rt.r[5], true);
    rt.r[4] = rt.r[4] << 5;
    rt.updateNz(rt.r[4]);
    rt.cpuAdd(&rt.r[1], rt.r[4], 0, true);
    if (!abi.call(bios.func_080796CC, 0x0800392D)) return;

    abi.fetches(7);
    rt.r[0] = rt.asrConst(rt.r[0], 5);
    rt.updateNz(rt.r[0]);
    rt.cpuAdd(&rt.r[0], rt.r[0], rt.r[5], true);
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

fn popReturnPcMath() void {
    const pc = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[15] = pc;
    rt.recompReturn(pc);
}

const RotAxis = enum { x, y, z };

fn writeRotationMatrix3x3(axis: RotAxis, cos_ret: u32, sin_ret: u32) void {
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);

    rt.r[6] = rt.r[0];
    const angle: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[1])));
    rt.r[5] = angle;
    rt.r[0] = angle;
    if (!abi.call(func_0807AF30, cos_ret)) return;

    abi.fetches(10);
    const cos_q12: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])) >> 2);
    rt.r[4] = cos_q12 & 0xFFFF;
    rt.r[0] = rt.r[5];
    if (!abi.call(func_0807AED4, sin_ret)) return;

    abi.fetches(22);
    const sin_q12: u32 = @bitCast(abi.signExtend16(@truncate(rt.r[0])) >> 2);
    const neg_sin: u32 = 0 -% sin_q12;
    const one: u32 = 0x1000;
    const mat: [9]u32 = switch (axis) {
        .x => .{ one, 0, 0, 0, cos_q12, neg_sin, 0, sin_q12, cos_q12 },
        .y => .{ cos_q12, 0, neg_sin, 0, one, 0, sin_q12, 0, cos_q12 },
        .z => .{ cos_q12, neg_sin, 0, sin_q12, cos_q12, 0, 0, 0, one },
    };
    inline for (mat, 0..) |entry, idx| {
        abi.write32(rt.r[6] +% @as(u32, idx * 4), entry);
    }

    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    abi.popReturn();
}

/// Build 3x3 fixed-point X-axis rotation matrix at `[r0]` for angle `i16(r1)` (`0x0806D160`).
pub fn func_0806D160() callconv(.c) void {
    if (!abi.enter(0x0806D160)) return;
    writeRotationMatrix3x3(.x, 0x0806D16F, 0x0806D17F);
}

/// Build 3x3 fixed-point Y-axis rotation matrix at `[r0]` for angle `i16(r1)` (`0x0806D1A8`).
pub fn func_0806D1A8() callconv(.c) void {
    if (!abi.enter(0x0806D1A8)) return;
    writeRotationMatrix3x3(.y, 0x0806D1B7, 0x0806D1C7);
}

/// Build 3x3 fixed-point Z-axis rotation matrix at `[r0]` for angle `i16(r1)` (`0x0806D1F0`).
pub fn func_0806D1F0() callconv(.c) void {
    if (!abi.enter(0x0806D1F0)) return;
    writeRotationMatrix3x3(.z, 0x0806D1FF, 0x0806D20F);
}

fn softfpDoubleAddSub(sub: bool, r1: u32, r2: u32, r3: u32, r4: u32) void {
    abi.fetches(12);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 0x4C;
    abi.write32(rt.r[13] +% 0x3C, rt.r[0]);
    abi.write32(rt.r[13] +% 0x40, rt.r[1]);
    abi.write32(rt.r[13] +% 0x44, rt.r[2]);
    abi.write32(rt.r[13] +% 0x48, rt.r[3]);
    rt.r[0] = rt.r[13] +% 0x3C;
    rt.r[1] = rt.r[13];
    if (!abi.call(low_peel_13.func_0807B8B4, r1)) return;

    abi.fetches(7);
    rt.r[0] = rt.r[13] +% 0x44;
    rt.r[4] = rt.r[13] +% 0x14;
    rt.r[1] = rt.r[4];
    if (!abi.call(low_peel_13.func_0807B8B4, r2)) return;

    abi.fetches(if (sub) 11 else 7);
    if (sub) {
        abi.write32(rt.r[4] +% 4, abi.read32(rt.r[4] +% 4) ^ 1);
    }
    rt.r[2] = rt.r[13] +% 0x28;
    rt.r[0] = rt.r[13];
    rt.r[1] = rt.r[4];
    if (!abi.call(low_peel_18.func_0807B98C, r3)) return;

    abi.fetches(4);
    if (!abi.call(low_peel_13.func_0807B76C, r4)) return;

    abi.fetches(4);
    rt.r[13] +%= 0x4C;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnPcMath();
}

/// Software IEEE-754 double-precision addition (`__adddf3`, `0x0807BBF8`).
pub fn func_0807BBF8() callconv(.c) void {
    if (!abi.enter(0x0807BBF8)) return;
    softfpDoubleAddSub(false, 0x0807BC0D, 0x0807BC17, 0x0807BC21, 0x0807BC25);
}

/// Software IEEE-754 double-precision subtraction (`__subdf3`, `0x0807BC28`).
pub fn func_0807BC28() callconv(.c) void {
    if (!abi.enter(0x0807BC28)) return;
    softfpDoubleAddSub(true, 0x0807BC3D, 0x0807BC47, 0x0807BC59, 0x0807BC5D);
}

/// Software IEEE-754 double-precision multiplication (`__muldf3`, `0x0807C190`).
pub fn func_0807C190() callconv(.c) void {
    if (!abi.enter(0x0807C190)) return;
    abi.fetches(12);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 0x38;
    abi.write32(rt.r[13] +% 0x28, rt.r[0]);
    abi.write32(rt.r[13] +% 0x2C, rt.r[1]);
    abi.write32(rt.r[13] +% 0x30, rt.r[2]);
    abi.write32(rt.r[13] +% 0x34, rt.r[3]);
    rt.r[0] = rt.r[13] +% 0x28;
    rt.r[1] = rt.r[13];
    if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C1A5)) return;

    abi.fetches(7);
    rt.r[0] = rt.r[13] +% 0x30;
    rt.r[4] = rt.r[13] +% 0x14;
    rt.r[1] = rt.r[4];
    if (!abi.call(low_peel_13.func_0807B8B4, 0x0807C1AF)) return;

    abi.fetches(6);
    rt.r[0] = rt.r[13];
    rt.r[1] = rt.r[4];
    if (!abi.call(low_peel_17.func_0807C090, 0x0807C1B7)) return;

    abi.fetches(4);
    rt.r[13] +%= 0x38;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnPcMath();
}

fn softfpFloatAddSub(sub: bool, r1: u32, r2: u32, r3: u32, r4: u32) void {
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 0x38;
    abi.write32(rt.r[13] +% 0x30, rt.r[0]);
    abi.write32(rt.r[13] +% 0x34, rt.r[1]);
    rt.r[0] = rt.r[13] +% 0x30;
    rt.r[1] = rt.r[13];
    if (!abi.call(low_peel_13.func_0807C5C0, r1)) return;

    abi.fetches(7);
    rt.r[0] = rt.r[13] +% 0x34;
    rt.r[4] = rt.r[13] +% 0x10;
    rt.r[1] = rt.r[4];
    if (!abi.call(low_peel_13.func_0807C5C0, r2)) return;

    abi.fetches(if (sub) 11 else 7);
    if (sub) {
        abi.write32(rt.r[4] +% 4, abi.read32(rt.r[4] +% 4) ^ 1);
    }
    rt.r[2] = rt.r[13] +% 0x20;
    rt.r[0] = rt.r[13];
    rt.r[1] = rt.r[4];
    if (!abi.call(low_peel_17.func_0807C63C, r3)) return;

    abi.fetches(4);
    if (!abi.call(low_peel_13.func_0807C508, r4)) return;

    abi.fetches(4);
    rt.r[13] +%= 0x38;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnPcMath();
}

/// Software IEEE-754 single-precision addition (`__addsf3`, `0x0807C7B8`).
pub fn func_0807C7B8() callconv(.c) void {
    if (!abi.enter(0x0807C7B8)) return;
    softfpFloatAddSub(false, 0x0807C7C9, 0x0807C7D3, 0x0807C7DD, 0x0807C7E1);
}

/// Software IEEE-754 single-precision subtraction (`__subsf3`, `0x0807C7E4`).
pub fn func_0807C7E4() callconv(.c) void {
    if (!abi.enter(0x0807C7E4)) return;
    softfpFloatAddSub(true, 0x0807C7F5, 0x0807C7FF, 0x0807C811, 0x0807C815);
}

/// Software IEEE-754 single-precision multiplication (`__mulsf3`, `0x0807CB4C`).
pub fn func_0807CB4C() callconv(.c) void {
    if (!abi.enter(0x0807CB4C)) return;
    abi.fetches(10);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 0x28;
    abi.write32(rt.r[13] +% 0x20, rt.r[0]);
    abi.write32(rt.r[13] +% 0x24, rt.r[1]);
    rt.r[0] = rt.r[13] +% 0x20;
    rt.r[1] = rt.r[13];
    if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CB5D)) return;

    abi.fetches(7);
    rt.r[0] = rt.r[13] +% 0x24;
    rt.r[4] = rt.r[13] +% 0x10;
    rt.r[1] = rt.r[4];
    if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CB67)) return;

    abi.fetches(6);
    rt.r[0] = rt.r[13];
    rt.r[1] = rt.r[4];
    if (!abi.call(low_peel_17.func_0807CA68, 0x0807CB6F)) return;

    abi.fetches(4);
    rt.r[13] +%= 0x28;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnPcMath();
}

/// Convert IEEE-754 single-precision float to signed 32-bit integer (`__fixsfsi`, `0x0807CE28`).
pub fn func_0807CE28() callconv(.c) void {
    if (!abi.enter(0x0807CE28)) return;
    abi.fetches(9);
    abi.pushLr();
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[6]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[5]);
    rt.r[13] -%= 4;
    abi.write32(rt.r[13], rt.r[4]);
    rt.r[13] -%= 0x18;
    abi.write32(rt.r[13] +% 0x14, rt.r[0]);
    rt.r[0] = rt.r[13] +% 0x14;
    rt.r[1] = rt.r[13] +% 0x4;
    if (!abi.call(low_peel_13.func_0807C5C0, 0x0807CE37)) return;

    abi.fetches(15);
    rt.r[0] = abi.read32(rt.r[13] +% 0x4);
    rt.r[1] = abi.read32(rt.r[13] +% 0x8);
    rt.r[2] = abi.read32(rt.r[13] +% 0xC);
    rt.r[3] = abi.read32(rt.r[13] +% 0x10);
    const shifted = rt.r[3] >> 2;
    abi.write32(rt.r[13] +% 0x0, shifted);
    rt.r[3] = rt.r[3] << 30;
    if (!abi.call(low_peel_2.func_0807C49C, 0x0807CE51)) return;

    abi.fetches(4);
    rt.r[13] +%= 0x18;
    rt.r[4] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[5] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    rt.r[6] = abi.read32(rt.r[13]);
    rt.r[13] +%= 4;
    popReturnPcMath();
}

/// Unsigned 32x32->64 multiply returning high 32 bits (`0x080775A4`).
pub fn func_080775A4() callconv(.c) void {
    if (!abi.enter(0x080775A4)) return;
    abi.fetches(8);
    const prod: u64 = @as(u64, rt.r[0]) *% @as(u64, rt.r[1]);
    rt.r[2] = @truncate(prod);
    rt.r[3] = @truncate(prod >> 32);
    rt.r[0] = rt.r[3];
    abi.retLr();
}

comptime {
    if (!builtin.is_test) {
        @export(&func_08010A84, .{ .name = "func_08010A84", .linkage = .strong });
        @export(&func_08003918, .{ .name = "func_08003918", .linkage = .strong });
        @export(&func_0806CF50, .{ .name = "func_0806CF50", .linkage = .strong });
        @export(&func_0806D23C, .{ .name = "func_0806D23C", .linkage = .strong });
        @export(&func_0806D260, .{ .name = "func_0806D260", .linkage = .strong });
        @export(&func_0807AED4, .{ .name = "func_0807AED4", .linkage = .strong });
        @export(&func_0807B488, .{ .name = "func_0807B488", .linkage = .strong });
        @export(&func_0807B564, .{ .name = "func_0807B564", .linkage = .strong });
        @export(&func_0807B6AC, .{ .name = "func_0807B6AC", .linkage = .strong });
        @export(&func_0807AF30, .{ .name = "func_0807AF30", .linkage = .strong });
        @export(&func_0800FCFA, .{ .name = "func_0800FCFA", .linkage = .strong });
        @export(&func_0803D4F0, .{ .name = "func_0803D4F0", .linkage = .strong });
        @export(&func_0806D160, .{ .name = "func_0806D160", .linkage = .strong });
        @export(&func_0806D1A8, .{ .name = "func_0806D1A8", .linkage = .strong });
        @export(&func_0806D1F0, .{ .name = "func_0806D1F0", .linkage = .strong });
        @export(&func_0807BBF8, .{ .name = "func_0807BBF8", .linkage = .strong });
        @export(&func_0807BC28, .{ .name = "func_0807BC28", .linkage = .strong });
        @export(&func_0807C190, .{ .name = "func_0807C190", .linkage = .strong });
        @export(&func_0807C7B8, .{ .name = "func_0807C7B8", .linkage = .strong });
        @export(&func_0807C7E4, .{ .name = "func_0807C7E4", .linkage = .strong });
        @export(&func_0807CB4C, .{ .name = "func_0807CB4C", .linkage = .strong });
        @export(&func_0807CE28, .{ .name = "func_0807CE28", .linkage = .strong });
        @export(&func_080775A4, .{ .name = "func_080775A4", .linkage = .strong });
    }
}

test "Q12 arithmetic shift preserves signed fixed-point scaling" {
    try std.testing.expectEqual(@as(u32, 1), q12Shift(q12Mul(4096, 4096) >> 12));
    try std.testing.expectEqual(@as(u32, 4096), q12Shift(q12Mul(4096, 4096)));
    const neg: u32 = @bitCast(-@as(i32, 8192));
    try std.testing.expectEqual(@as(i32, -2), @as(i32, @bitCast(q12Shift(neg))));
}

test "nextRngSeed matches Advance Wars (4*s+2)*(4*s+3)>>2 arithmetic across wraparound" {
    try std.testing.expectEqual(@as(u32, 1), nextRngSeed(0));
    try std.testing.expectEqual(@as(u32, 10), nextRngSeed(1));
    try std.testing.expectEqual(@as(u32, 27), nextRngSeed(2));
    // 0x4000_0000 << 2 == 0 -> ((2 * 3) >> 2) == 1
    try std.testing.expectEqual(@as(u32, 1), nextRngSeed(0x4000_0000));
    // 0xFFFF_FFFF << 2 == 0xFFFF_FFFC (-4 mod 2^32): (-2) * (-1) >> 2 == 0
    try std.testing.expectEqual(@as(u32, 0), nextRngSeed(0xFFFF_FFFF));
}

test "mulMat3Vec3Q12 handles identity and signed Q12 scaling" {
    const id_mat = [9]u32{
        4096, 0,    0,
        0,    4096, 0,
        0,    0,    4096,
    };
    const v = [3]u32{ 123, @bitCast(@as(i32, -456)), 789 };
    const id_res = mulMat3Vec3Q12(v, id_mat);
    try std.testing.expectEqualSlices(u32, &v, &id_res);

    const scale_mat = [9]u32{
        8192, 0,                             0,
        0,    @bitCast(@as(i32, -4096)),     0,
        0,    0,                             2048,
    };
    const res = mulMat3Vec3Q12(.{ 10, 20, @bitCast(@as(i32, -8)) }, scale_mat);
    try std.testing.expectEqual(@as(u32, 20), res[0]);
    try std.testing.expectEqual(@as(i32, -20), @as(i32, @bitCast(res[1])));
    try std.testing.expectEqual(@as(i32, -4), @as(i32, @bitCast(res[2])));
}

test "normalizeSinDeg folds all quadrants and wraparound degrees" {
    try std.testing.expectEqual(SinIndex{ .idx = 0, .negate = false }, normalizeSinDeg(0));
    try std.testing.expectEqual(SinIndex{ .idx = 45, .negate = false }, normalizeSinDeg(45));
    try std.testing.expectEqual(SinIndex{ .idx = 90, .negate = false }, normalizeSinDeg(90));
    try std.testing.expectEqual(SinIndex{ .idx = 45, .negate = false }, normalizeSinDeg(135));
    try std.testing.expectEqual(SinIndex{ .idx = 0, .negate = true }, normalizeSinDeg(180));
    try std.testing.expectEqual(SinIndex{ .idx = 45, .negate = true }, normalizeSinDeg(225));
    try std.testing.expectEqual(SinIndex{ .idx = 90, .negate = true }, normalizeSinDeg(270));
    try std.testing.expectEqual(SinIndex{ .idx = 1, .negate = true }, normalizeSinDeg(359));
    try std.testing.expectEqual(SinIndex{ .idx = 0, .negate = false }, normalizeSinDeg(-720));
    try std.testing.expectEqual(SinIndex{ .idx = 90, .negate = true }, normalizeSinDeg(-90));
    try std.testing.expectEqual(SinIndex{ .idx = 90, .negate = false }, normalizeSinDeg(450));
}

test "divSigned32 matches truncating signed division and edge cases" {
    try std.testing.expectEqual(@as(i32, 7), divSigned32(22, 3));
    try std.testing.expectEqual(@as(i32, -7), divSigned32(-22, 3));
    try std.testing.expectEqual(@as(i32, -7), divSigned32(22, -3));
    try std.testing.expectEqual(@as(i32, 7), divSigned32(-22, -3));
    try std.testing.expectEqual(@as(i32, 0), divSigned32(0, 5));
    try std.testing.expectEqual(@as(i32, 0), divSigned32(123, 0));
    try std.testing.expectEqual(std.math.minInt(i32), divSigned32(std.math.minInt(i32), -1));
    try std.testing.expectEqual(@as(i32, -1073741824), divSigned32(std.math.minInt(i32), 2));
    try std.testing.expectEqual(@as(i32, 715827882), divSigned32(std.math.maxInt(i32), 3));
}

test "modUnsigned32 and modSigned32 match libgcc modulo semantics" {
    try std.testing.expectEqual(@as(u32, 4), modUnsigned32(25, 7));
    try std.testing.expectEqual(@as(u32, 5), modUnsigned32(5, 9));
    try std.testing.expectEqual(@as(u32, 0), modUnsigned32(123, 0));
    try std.testing.expectEqual(@as(i32, 1), modSigned32(22, 3));
    try std.testing.expectEqual(@as(i32, -1), modSigned32(-22, 3));
    try std.testing.expectEqual(@as(i32, 1), modSigned32(22, -3));
    try std.testing.expectEqual(@as(i32, -1), modSigned32(-22, -3));
    try std.testing.expectEqual(@as(i32, 0), modSigned32(123, 0));
    try std.testing.expectEqual(@as(i32, 0), modSigned32(std.math.minInt(i32), -1));
}

test "math typed call bridges preserve fn pointers" {
    inline for (.{ nextRngCall, sinDegCall, cosDegCall, divSigned32Call, modUnsigned32Call }) |bridge| {
        const info = @typeInfo(@TypeOf(bridge)).@"fn";
        try std.testing.expectEqual(@as(usize, 1), info.param_types.len);
        try std.testing.expect(info.param_types[0].? == u32);
        try std.testing.expect(info.return_type.? == bool);
    }
}
