const std = @import("std");
const dma_mod = @import("dma.zig");

const BusMode = dma_mod.BusMode;
const return_sentinel: u32 = 0xDEAD_0000;
const max_steps: usize = 2_000_000;

inline fn isRamAddr(addr: u32) bool {
    const region = addr >> 24;
    return region == 0x02 or region == 0x03;
}

inline fn updateNz(ctx: anytype, result: u32) void {
    ctx.setN((result >> 31) != 0);
    ctx.setZ(result == 0);
}

inline fn cpuAdd(ctx: anytype, dest: ?*u32, a: u32, b: u32, set_flags: bool) void {
    const res64: u64 = @as(u64, a) + @as(u64, b);
    const res: u32 = @truncate(res64);
    if (dest) |d| d.* = res;
    if (set_flags) {
        ctx.setN((res >> 31) != 0);
        ctx.setZ(res == 0);
        ctx.setC((res64 >> 32) != 0);
        ctx.setV(((~(a ^ b) & (a ^ res)) >> 31) != 0);
    }
}

inline fn cpuSub(ctx: anytype, dest: ?*u32, a: u32, b: u32, set_flags: bool) void {
    const res: u32 = a -% b;
    if (dest) |d| d.* = res;
    if (set_flags) {
        ctx.setN((res >> 31) != 0);
        ctx.setZ(res == 0);
        ctx.setC(a >= b);
        ctx.setV((((a ^ b) & (a ^ res)) >> 31) != 0);
    }
}

inline fn cpuAdc(ctx: anytype, dest: ?*u32, a: u32, b: u32, set_flags: bool) void {
    const carry: u64 = if (ctx.getC()) 1 else 0;
    const res64: u64 = @as(u64, a) + @as(u64, b) + carry;
    const res: u32 = @truncate(res64);
    if (dest) |d| d.* = res;
    if (set_flags) {
        ctx.setN((res >> 31) != 0);
        ctx.setZ(res == 0);
        ctx.setC((res64 >> 32) != 0);
        ctx.setV(((~(a ^ b) & (a ^ res)) >> 31) != 0);
    }
}

inline fn cpuSbc(ctx: anytype, dest: ?*u32, a: u32, b: u32, set_flags: bool) void {
    const borrow: u32 = if (ctx.getC()) 0 else 1;
    const res: u32 = a -% b -% borrow;
    if (dest) |d| d.* = res;
    if (set_flags) {
        ctx.setN((res >> 31) != 0);
        ctx.setZ(res == 0);
        ctx.setC(@as(u64, a) >= @as(u64, b) + @as(u64, borrow));
        ctx.setV((((a ^ b) & (a ^ res)) >> 31) != 0);
    }
}

inline fn condMatch(ctx: anytype, cond: u4) bool {
    return switch (cond) {
        0x0 => ctx.getZ(),
        0x1 => !ctx.getZ(),
        0x2 => ctx.getC(),
        0x3 => !ctx.getC(),
        0x4 => ctx.getN(),
        0x5 => !ctx.getN(),
        0x6 => ctx.getV(),
        0x7 => !ctx.getV(),
        0x8 => ctx.getC() and !ctx.getZ(),
        0x9 => !ctx.getC() or ctx.getZ(),
        0xA => ctx.getN() == ctx.getV(),
        0xB => ctx.getN() != ctx.getV(),
        0xC => !ctx.getZ() and (ctx.getN() == ctx.getV()),
        0xD => ctx.getZ() or (ctx.getN() != ctx.getV()),
        0xE => true,
        0xF => false,
    };
}

inline fn leaveToRom(ctx: anytype, addr: u32) bool {
    if (ctx.recompLookup(addr & ~@as(u32, 1)) != 0) {
        ctx.setRet(0);
        ctx.cpuBx(addr);
        return true;
    }
    ctx.setRet(addr | 1);
    return true;
}

/// Interpret an ARM or Thumb function in IWRAM, EWRAM, or uncompiled ROM.
pub fn runFunction(ctx: anytype, target: u32) void {
    const saved_mode = ctx.getBusMode();
    ctx.setBusMode(.ram_code);
    defer ctx.setBusMode(saved_mode);

    runFunctionInner(ctx, target);
}

fn runFunctionInner(ctx: anytype, target: u32) void {
    const r = ctx.regs();

    // Side-effect-free check for blank/invalid memory mistakenly jumped to as code.
    if (ctx.peekCodeWord(target & ~@as(u32, 1))) |w| {
        var is_data = (w == 0 or w == 0xFFFF_FFFF or (w & 0xFFFF_0000) == 0xFFFF_0000);
        if (!is_data and (target & 1) == 0 and ((w >> 28) & 0xF) == 0xF) {
            is_data = true;
        }
        if (is_data) {
            r[15] = r[14] & ~@as(u32, 1);
            return;
        }
    }

    ctx.traceInterpEnter(target);

    var thumb = (target & 1) != 0;
    var pc = target & ~@as(u32, 1);
    const saved_lr = r[14];
    r[14] = return_sentinel | 1;

    var steps: usize = 0;
    var next_pc = pc;

    while (steps < max_steps) {
        steps += 1;
        if (pc != next_pc) {
            ctx.charge(@intCast(2 * ctx.accessCycles(pc, !thumb)));
            if (ctx.softResetPending()) return;
        }

        if (!thumb) {
            ctx.charge(@intCast(ctx.accessCycles(pc, true)));
            if (ctx.softResetPending()) return;
            const insn = ctx.read32Raw(pc);
            next_pc = pc +% 4;
            pc +%= 4;

            const cond: u4 = @truncate((insn >> 28) & 0xF);
            if (!condMatch(ctx, cond)) continue;

            // BX Rm
            if ((insn & 0x0FFF_FFF0) == 0x012F_FF10) {
                const rm: usize = @intCast(insn & 0xF);
                const addr = r[rm];
                if ((addr & ~@as(u32, 1)) == return_sentinel) break;
                if ((addr >> 24) == 0x08) {
                    if (isRamAddr(r[14])) {
                        ctx.cpuBx(addr);
                        if (ctx.softResetPending()) return;
                        ctx.setRet(0);
                        continue;
                    }
                    _ = leaveToRom(ctx, addr);
                    if (ctx.softResetPending()) return;
                    break;
                }
                const region: u8 = @truncate(addr >> 24);
                if (region != 0x02 and region != 0x03 and region != 0x00) {
                    ctx.warnUnmappedArmBx(addr, @intCast(rm), pc -% 4);
                    break;
                }
                thumb = (addr & 1) != 0;
                pc = addr & ~@as(u32, 1);
                continue;
            }

            // B / BL
            if ((insn & 0x0E00_0000) == 0x0A00_0000) {
                const offset: i32 = @as(i32, @bitCast(insn << 8)) >> 6;
                if (((insn >> 24) & 1) != 0) r[14] = pc;
                pc = @bitCast(@as(i32, @bitCast(pc)) +% offset +% 4);
                continue;
            }

            // MSR (must precede data processing)
            if ((insn & 0x0FB0_F000) == 0x0120_F000) {
                const val: u32 = if ((insn & (1 << 25)) != 0) blk: {
                    const imm: u32 = insn & 0xFF;
                    const rot: u5 = @intCast(((insn >> 8) & 0xF) * 2);
                    break :blk if (rot != 0) std.math.rotr(u32, imm, rot) else imm;
                } else r[@intCast(insn & 0xF)];
                var mask: u32 = 0;
                if ((insn & (1 << 19)) != 0) mask |= 0xF000_0000;
                if ((insn & (1 << 16)) != 0) mask |= 0x0000_00FF;
                const spsr = ((insn >> 22) & 1) != 0;
                // Preserves runtime.c's exact `mask >> 28` convention.
                if (spsr) ctx.setSpsr(val, mask >> 28) else ctx.setCpsr(val, mask >> 28);
                continue;
            }

            // MRS (must precede data processing)
            if ((insn & 0x0FBF_0FFF) == 0x010F_0000) {
                const rd_idx: usize = @intCast((insn >> 12) & 0xF);
                const spsr = ((insn >> 22) & 1) != 0;
                r[rd_idx] = if (spsr) ctx.getSpsr() else ctx.getCpsr();
                continue;
            }

            // Data Processing
            const is_half_or_signed = ((insn & (1 << 25)) == 0) and ((insn & 0x90) == 0x90) and ((insn & 0x60) != 0);
            const is_multiply = ((insn & (1 << 25)) == 0) and ((insn & 0xF0) == 0x90);
            if ((insn & 0x0C00_0000) == 0 and !is_half_or_signed and !is_multiply) {
                const opcode: u4 = @truncate((insn >> 21) & 0xF);
                const s_bit = ((insn >> 20) & 1) != 0;
                const rn: usize = @intCast((insn >> 16) & 0xF);
                const rd: usize = @intCast((insn >> 12) & 0xF);

                var op2: u32 = undefined;
                var shift_carry = ctx.getC();
                if ((insn & (1 << 25)) != 0) {
                    const imm: u32 = insn & 0xFF;
                    const rot: u5 = @intCast(((insn >> 8) & 0xF) * 2);
                    if (rot > 0) {
                        op2 = std.math.rotr(u32, imm, rot);
                        shift_carry = (op2 >> 31) != 0;
                    } else {
                        op2 = imm;
                    }
                } else {
                    const rm: usize = @intCast(insn & 0xF);
                    const reg_shift = (insn & (1 << 4)) != 0;
                    op2 = if (rm == 15) (if (reg_shift) pc +% 8 else pc +% 4) else r[rm];
                    const shift_type: u2 = @truncate((insn >> 5) & 3);
                    var shift_amount: u32 = if (reg_shift)
                        r[@intCast((insn >> 8) & 0xF)] & 0xFF
                    else
                        (insn >> 7) & 0x1F;

                    switch (shift_type) {
                        0 => { // LSL
                            if (shift_amount > 0) {
                                if (shift_amount < 32) {
                                    shift_carry = ((op2 >> @intCast(32 - shift_amount)) & 1) != 0;
                                    op2 <<= @intCast(shift_amount);
                                } else if (shift_amount == 32) {
                                    shift_carry = (op2 & 1) != 0;
                                    op2 = 0;
                                } else {
                                    shift_carry = false;
                                    op2 = 0;
                                }
                            }
                        },
                        1 => { // LSR (register shift by 0 is a no-op; imm 0 means LSR #32)
                            if (!(reg_shift and shift_amount == 0)) {
                                if (!reg_shift and shift_amount == 0) shift_amount = 32;
                                if (shift_amount < 32) {
                                    shift_carry = ((op2 >> @intCast(shift_amount - 1)) & 1) != 0;
                                    op2 >>= @intCast(shift_amount);
                                } else if (shift_amount == 32) {
                                    shift_carry = (op2 >> 31) != 0;
                                    op2 = 0;
                                } else {
                                    shift_carry = false;
                                    op2 = 0;
                                }
                            }
                        },
                        2 => { // ASR (register shift by 0 is a no-op; imm 0 means ASR #32)
                            if (!(reg_shift and shift_amount == 0)) {
                                if (!reg_shift and shift_amount == 0) shift_amount = 32;
                                if (shift_amount >= 32) {
                                    shift_carry = (op2 >> 31) != 0;
                                    op2 = @bitCast(@as(i32, @bitCast(op2)) >> 31);
                                } else {
                                    shift_carry = ((op2 >> @intCast(shift_amount - 1)) & 1) != 0;
                                    op2 = @bitCast(@as(i32, @bitCast(op2)) >> @intCast(shift_amount));
                                }
                            }
                        },
                        3 => { // ROR / RRX (register shift by 0 is a no-op; imm 0 means RRX)
                            if (!(reg_shift and shift_amount == 0)) {
                                if (!reg_shift and shift_amount == 0) {
                                    shift_carry = (op2 & 1) != 0;
                                    op2 = (if (ctx.getC()) @as(u32, 0x8000_0000) else 0) | (op2 >> 1);
                                } else {
                                    shift_amount &= 31;
                                    if (shift_amount == 0) {
                                        shift_carry = (op2 >> 31) != 0;
                                    } else {
                                        op2 = std.math.rotr(u32, op2, @as(u5, @intCast(shift_amount)));
                                        shift_carry = (op2 >> 31) != 0;
                                    }
                                }
                            }
                        },
                    }
                }

                const a: u32 = if (rn == 15) pc +% 4 else r[rn];
                const dst_opt: ?*u32 = if (rd < 15) &r[rd] else null;
                var result: u32 = 0;
                var handled_arith = false;

                switch (opcode) {
                    0x0 => {
                        result = a & op2;
                        if (dst_opt) |d| d.* = result;
                    },
                    0x1 => {
                        result = a ^ op2;
                        if (dst_opt) |d| d.* = result;
                    },
                    0x2 => {
                        cpuSub(ctx, dst_opt, a, op2, s_bit);
                        handled_arith = true;
                    },
                    0x3 => {
                        cpuSub(ctx, dst_opt, op2, a, s_bit);
                        handled_arith = true;
                    },
                    0x4 => {
                        cpuAdd(ctx, dst_opt, a, op2, s_bit);
                        handled_arith = true;
                    },
                    0x5 => {
                        cpuAdc(ctx, dst_opt, a, op2, s_bit);
                        handled_arith = true;
                    },
                    0x6 => {
                        cpuSbc(ctx, dst_opt, a, op2, s_bit);
                        handled_arith = true;
                    },
                    0x7 => {
                        const tmp = ctx.getC();
                        cpuSbc(ctx, dst_opt, op2, a, s_bit);
                        if (!s_bit) ctx.setC(tmp);
                        handled_arith = true;
                    },
                    0x8 => result = a & op2,
                    0x9 => result = a ^ op2,
                    0xA => {
                        cpuSub(ctx, null, a, op2, true);
                        handled_arith = true;
                    },
                    0xB => {
                        cpuAdd(ctx, null, a, op2, true);
                        handled_arith = true;
                    },
                    0xC => {
                        result = a | op2;
                        if (dst_opt) |d| d.* = result;
                    },
                    0xD => {
                        result = op2;
                        if (dst_opt) |d| d.* = result;
                    },
                    0xE => {
                        result = a & ~op2;
                        if (dst_opt) |d| d.* = result;
                    },
                    0xF => {
                        result = ~op2;
                        if (dst_opt) |d| d.* = result;
                    },
                }

                if (handled_arith) continue;

                if (s_bit) {
                    updateNz(ctx, result);
                    ctx.setC(shift_carry);
                }
                if (rd == 15) {
                    pc = result & ~@as(u32, 3);
                }
                continue;
            }

            // Single data transfer: LDR / STR
            if ((insn & 0x0C00_0000) == 0x0400_0000) {
                const i_bit = ((insn >> 25) & 1) != 0;
                const p_bit = ((insn >> 24) & 1) != 0;
                const u_bit = ((insn >> 23) & 1) != 0;
                const b_bit = ((insn >> 22) & 1) != 0;
                const w_bit = ((insn >> 21) & 1) != 0;
                const l_bit = ((insn >> 20) & 1) != 0;
                const rn_idx: usize = @intCast((insn >> 16) & 0xF);
                const rd_idx: usize = @intCast((insn >> 12) & 0xF);

                const base: u32 = if (rn_idx == 15) pc +% 4 else r[rn_idx];
                var offset2: u32 = undefined;
                if (!i_bit) {
                    offset2 = insn & 0xFFF;
                } else {
                    const rm: usize = @intCast(insn & 0xF);
                    offset2 = r[rm];
                    const shift_type: u2 = @truncate((insn >> 5) & 3);
                    const shift_amt: u5 = @truncate((insn >> 7) & 0x1F);
                    offset2 = switch (shift_type) {
                        0 => if (shift_amt != 0) offset2 << shift_amt else offset2,
                        1 => if (shift_amt != 0) offset2 >> shift_amt else 0,
                        2 => if (shift_amt != 0)
                            @bitCast(@as(i32, @bitCast(offset2)) >> shift_amt)
                        else
                            @bitCast(@as(i32, @bitCast(offset2)) >> 31),
                        3 => if (shift_amt != 0)
                            std.math.rotr(u32, offset2, shift_amt)
                        else
                            (if (ctx.getC()) @as(u32, 0x8000_0000) else 0) | (offset2 >> 1),
                    };
                }

                var addr: u32 = if (p_bit) (if (u_bit) base +% offset2 else base -% offset2) else base;
                if (l_bit) {
                    r[rd_idx] = if (b_bit) ctx.busRead8(addr) else ctx.busRead32(addr);
                    if (ctx.softResetPending()) return;
                    if (rd_idx == 15) {
                        pc = r[15] & ~@as(u32, 3);
                    }
                } else {
                    const val: u32 = if (rd_idx == 15) pc +% 4 else r[rd_idx];
                    if (b_bit) ctx.busWrite8(addr, @truncate(val)) else ctx.busWrite32(addr, val);
                    if (ctx.softResetPending()) return;
                }
                if (!p_bit) {
                    addr = if (u_bit) base +% offset2 else base -% offset2;
                }
                if (w_bit or !p_bit) {
                    r[rn_idx] = addr;
                }
                continue;
            }

            // Block data transfer: LDM / STM (atomic transfer + writeback before cycle charge)
            if ((insn & 0x0E00_0000) == 0x0800_0000) {
                const p_bit = ((insn >> 24) & 1) != 0;
                const u_bit = ((insn >> 23) & 1) != 0;
                const w_bit = ((insn >> 21) & 1) != 0;
                const l_bit = ((insn >> 20) & 1) != 0;
                const rn_idx: usize = @intCast((insn >> 16) & 0xF);
                const rlist: u16 = @truncate(insn & 0xFFFF);

                const base = r[rn_idx];
                const count: u32 = @popCount(rlist);
                const start: u32 = if (u_bit)
                    (if (p_bit) base +% 4 else base)
                else
                    (if (p_bit) base -% count *% 4 else base -% count *% 4 +% 4);

                var addr2 = start;
                var ldm_cycles: i32 = 0;
                for (0..16) |reg_idx| {
                    if ((rlist & (@as(u16, 1) << @intCast(reg_idx))) == 0) continue;
                    if (l_bit) {
                        ldm_cycles +%= ctx.dataCycles(addr2, true, true);
                        r[reg_idx] = ctx.read32Raw(addr2);
                        if (reg_idx == 15) {
                            pc = r[15] & ~@as(u32, 3);
                        }
                    } else {
                        ctx.busWrite32Raw(addr2, r[reg_idx]);
                        ldm_cycles +%= ctx.dataCycles(addr2, true, false);
                    }
                    addr2 +%= 4;
                }
                if (w_bit and (!l_bit or (rlist & (@as(u16, 1) << @intCast(rn_idx))) == 0)) {
                    r[rn_idx] = if (u_bit) base +% count *% 4 else base -% count *% 4;
                }
                if (ldm_cycles != 0) {
                    ctx.charge(ldm_cycles);
                    if (ctx.softResetPending()) return;
                }
                if (l_bit and (rlist & 0x8000) != 0) {
                    if ((r[15] & ~@as(u32, 1)) == return_sentinel) break;
                    if ((r[15] >> 24) == 0x08) {
                        ctx.setRet(r[15] | 1);
                        break;
                    }
                }
                continue;
            }

            // MUL / MLA
            if ((insn & 0x0FC0_00F0) == 0x0000_0090) {
                const rd_idx: usize = @intCast((insn >> 16) & 0xF);
                const rn_idx2: usize = @intCast((insn >> 12) & 0xF);
                const rs_idx: usize = @intCast((insn >> 8) & 0xF);
                const rm_idx: usize = @intCast(insn & 0xF);
                const accumulate = ((insn >> 21) & 1) != 0;
                const s_mul = ((insn >> 20) & 1) != 0;
                var result = r[rm_idx] *% r[rs_idx];
                if (accumulate) result +%= r[rn_idx2];
                r[rd_idx] = result;
                if (s_mul) updateNz(ctx, result);
                continue;
            }

            // UMULL / UMLAL / SMULL / SMLAL
            if ((insn & 0x0F80_00F0) == 0x0080_0090) {
                const hi_idx: usize = @intCast((insn >> 16) & 0xF);
                const lo_idx: usize = @intCast((insn >> 12) & 0xF);
                const rs_idx: usize = @intCast((insn >> 8) & 0xF);
                const rm_idx: usize = @intCast(insn & 0xF);
                const sgn = ((insn >> 22) & 1) != 0;
                const acc = ((insn >> 21) & 1) != 0;
                const s_mul = ((insn >> 20) & 1) != 0;

                var res: u64 = if (sgn) blk: {
                    const m_s: i64 = @as(i32, @bitCast(r[rm_idx]));
                    const s_s: i64 = @as(i32, @bitCast(r[rs_idx]));
                    break :blk @bitCast(m_s *% s_s);
                } else @as(u64, r[rm_idx]) *% @as(u64, r[rs_idx]);

                if (acc) {
                    res +%= (@as(u64, r[hi_idx]) << 32) | r[lo_idx];
                }
                r[lo_idx] = @truncate(res);
                r[hi_idx] = @truncate(res >> 32);
                if (s_mul) {
                    ctx.setN((res >> 63) != 0);
                    ctx.setZ(res == 0);
                }
                continue;
            }

            // SWI
            if ((insn & 0x0F00_0000) == 0x0F00_0000) {
                ctx.swi((insn >> 16) & 0xFF);
                if (ctx.softResetPending()) return;
                continue;
            }

            // Halfword / signed transfer: LDRH / STRH / LDRSB / LDRSH
            if ((insn & 0x0E00_0090) == 0x0000_0090 and (insn & 0x0000_0060) != 0) {
                const p_bit = ((insn >> 24) & 1) != 0;
                const u_bit = ((insn >> 23) & 1) != 0;
                const imm_off = ((insn >> 22) & 1) != 0;
                const w_bit = ((insn >> 21) & 1) != 0;
                const l_bit = ((insn >> 20) & 1) != 0;
                const rn_idx: usize = @intCast((insn >> 16) & 0xF);
                const rd_idx: usize = @intCast((insn >> 12) & 0xF);
                const sh: u2 = @truncate((insn >> 5) & 3);

                const base = r[rn_idx];
                const off: u32 = if (imm_off) ((insn >> 4) & 0xF0) | (insn & 0xF) else r[@intCast(insn & 0xF)];
                var addr = if (p_bit) (if (u_bit) base +% off else base -% off) else base;
                if (l_bit) {
                    switch (sh) {
                        1 => r[rd_idx] = ctx.busRead16(addr),
                        2 => r[rd_idx] = @bitCast(@as(i32, @as(i8, @bitCast(ctx.busRead8(addr))))),
                        3 => r[rd_idx] = @bitCast(@as(i32, @as(i16, @bitCast(ctx.busRead16(addr))))),
                        0 => {},
                    }
                    if (ctx.softResetPending()) return;
                } else if (sh == 1) {
                    ctx.busWrite16(addr, @truncate(r[rd_idx]));
                    if (ctx.softResetPending()) return;
                }
                if (!p_bit) {
                    addr = if (u_bit) base +% off else base -% off;
                }
                if (w_bit or !p_bit) {
                    r[rn_idx] = addr;
                }
                continue;
            }

            ctx.warnUnknownArm(insn, pc -% 4);
            break;
        }

        // Thumb mode interpreter
        ctx.charge(@intCast(ctx.accessCycles(pc, false)));
        if (ctx.softResetPending()) return;
        const insn: u16 = ctx.read16Raw(pc);
        next_pc = pc +% 2;
        pc +%= 2;

        // Format 2: Add/Sub (must precede Format 1)
        if ((insn & 0xF800) == 0x1800) {
            const imm_flag = ((insn >> 10) & 1) != 0;
            const op = ((insn >> 9) & 1) != 0;
            const rn_or_imm: u32 = (insn >> 6) & 7;
            const rs: usize = @intCast((insn >> 3) & 7);
            const rd: usize = @intCast(insn & 7);
            const operand = if (imm_flag) rn_or_imm else r[@intCast(rn_or_imm)];
            if (op) cpuSub(ctx, &r[rd], r[rs], operand, true) else cpuAdd(ctx, &r[rd], r[rs], operand, true);
            continue;
        }

        // Format 1: Move shifted register
        if ((insn & 0xE000) == 0x0000) {
            const op: u2 = @truncate((insn >> 11) & 3);
            var offset: u32 = (insn >> 6) & 0x1F;
            const rs: usize = @intCast((insn >> 3) & 7);
            const rd: usize = @intCast(insn & 7);
            var val = r[rs];
            switch (op) {
                0 => {
                    if (offset > 0) {
                        ctx.setC(((val >> @intCast(32 - offset)) & 1) != 0);
                        val <<= @intCast(offset);
                    }
                },
                1 => {
                    if (offset == 0) offset = 32;
                    ctx.setC(((val >> @intCast(offset - 1)) & 1) != 0);
                    val = if (offset >= 32) 0 else val >> @intCast(offset);
                },
                2 => {
                    if (offset == 0) offset = 32;
                    const s_val: i32 = @bitCast(val);
                    const c_sh: u5 = @intCast(if (offset > 31) 31 else offset - 1);
                    const v_sh: u5 = @intCast(if (offset > 31) 31 else offset);
                    ctx.setC(((s_val >> c_sh) & 1) != 0);
                    val = @bitCast(s_val >> v_sh);
                },
                3 => {},
            }
            r[rd] = val;
            updateNz(ctx, val);
            continue;
        }

        // Format 3: Mov / Cmp / Add / Sub immediate
        if ((insn & 0xE000) == 0x2000) {
            const op: u2 = @truncate((insn >> 11) & 3);
            const rd: usize = @intCast((insn >> 8) & 7);
            const imm: u32 = insn & 0xFF;
            switch (op) {
                0 => {
                    r[rd] = imm;
                    updateNz(ctx, imm);
                },
                1 => cpuSub(ctx, null, r[rd], imm, true),
                2 => cpuAdd(ctx, &r[rd], r[rd], imm, true),
                3 => cpuSub(ctx, &r[rd], r[rd], imm, true),
            }
            continue;
        }

        // Format 4: ALU operations
        if ((insn & 0xFC00) == 0x4000) {
            const op: u4 = @truncate((insn >> 6) & 0xF);
            const rs: usize = @intCast((insn >> 3) & 7);
            const rd: usize = @intCast(insn & 7);
            const a = r[rd];
            const b = r[rs];
            var result: u32 = 0;
            switch (op) {
                0x0 => {
                    result = a & b;
                    r[rd] = result;
                    updateNz(ctx, result);
                },
                0x1 => {
                    result = a ^ b;
                    r[rd] = result;
                    updateNz(ctx, result);
                },
                0x2 => {
                    const shift = b & 0xFF;
                    result = if (shift >= 32) 0 else a << @intCast(shift);
                    if (shift > 0 and shift <= 32) ctx.setC(((a >> @intCast(32 - shift)) & 1) != 0);
                    r[rd] = result;
                    updateNz(ctx, result);
                },
                0x3 => {
                    const shift = b & 0xFF;
                    result = if (shift >= 32) 0 else a >> @intCast(shift);
                    if (shift > 0 and shift <= 32) ctx.setC(((a >> @intCast(shift - 1)) & 1) != 0);
                    r[rd] = result;
                    updateNz(ctx, result);
                },
                0x4 => {
                    const shift = b & 0xFF;
                    const sa: i32 = @bitCast(a);
                    result = if (shift >= 32) @bitCast(sa >> 31) else @bitCast(sa >> @intCast(shift));
                    r[rd] = result;
                    updateNz(ctx, result);
                },
                0x5 => cpuAdc(ctx, &r[rd], a, b, true),
                0x6 => cpuSbc(ctx, &r[rd], a, b, true),
                0x7 => {
                    const shift = b & 0xFF;
                    if (shift == 0) {
                        result = a;
                    } else {
                        const sh: u5 = @truncate(shift);
                        result = if (sh != 0) std.math.rotr(u32, a, sh) else a;
                        ctx.setC((a >> 31) != 0);
                    }
                    r[rd] = result;
                    updateNz(ctx, result);
                },
                0x8 => updateNz(ctx, a & b),
                0x9 => cpuSub(ctx, &r[rd], 0, b, true),
                0xA => cpuSub(ctx, null, a, b, true),
                0xB => cpuAdd(ctx, null, a, b, true),
                0xC => {
                    result = a | b;
                    r[rd] = result;
                    updateNz(ctx, result);
                },
                0xD => {
                    result = @bitCast(@as(i32, @bitCast(a)) *% @as(i32, @bitCast(b)));
                    r[rd] = result;
                    updateNz(ctx, result);
                },
                0xE => {
                    result = a & ~b;
                    r[rd] = result;
                    updateNz(ctx, result);
                },
                0xF => {
                    result = ~b;
                    r[rd] = result;
                    updateNz(ctx, result);
                },
            }
            continue;
        }

        // Format 5: Hi register ops / BX
        if ((insn & 0xFC00) == 0x4400) {
            const op: u2 = @truncate((insn >> 8) & 3);
            const h1: usize = @intCast((insn >> 7) & 1);
            const h2: usize = @intCast((insn >> 6) & 1);
            const rs: usize = @intCast(((insn >> 3) & 7) | (h2 << 3));
            const rd: usize = @intCast((insn & 7) | (h1 << 3));
            const val: u32 = if (rs == 15) pc +% 2 else r[rs];
            switch (op) {
                0 => {
                    r[rd] +%= val;
                    if (rd == 15) pc = r[15] & ~@as(u32, 1);
                },
                1 => cpuSub(ctx, null, r[rd], val, true),
                2 => {
                    r[rd] = val;
                    if (rd == 15) pc = r[15] & ~@as(u32, 1);
                },
                3 => {
                    if ((val & ~@as(u32, 1)) == return_sentinel) break;
                    if ((val >> 24) == 0x08) {
                        if (isRamAddr(r[14])) {
                            ctx.cpuBx(val);
                            if (ctx.softResetPending()) return;
                            ctx.setRet(0);
                        } else {
                            _ = leaveToRom(ctx, val);
                            if (ctx.softResetPending()) return;
                            break;
                        }
                    } else {
                        thumb = (val & 1) != 0;
                        pc = val & ~@as(u32, 1);
                    }
                },
            }
            continue;
        }

        // Format 6: PC-relative load
        if ((insn & 0xF800) == 0x4800) {
            const rd: usize = @intCast((insn >> 8) & 7);
            const offset: u32 = @as(u32, insn & 0xFF) << 2;
            const addr = ((pc +% 2) & ~@as(u32, 3)) +% offset;
            r[rd] = ctx.busRead32(addr);
            if (ctx.softResetPending()) return;
            continue;
        }

        // Format 7: Load/store register offset
        if ((insn & 0xF200) == 0x5000) {
            const ro: usize = @intCast((insn >> 6) & 7);
            const rb: usize = @intCast((insn >> 3) & 7);
            const rd: usize = @intCast(insn & 7);
            const addr = r[rb] +% r[ro];
            const op: u2 = @truncate((insn >> 10) & 3);
            switch (op) {
                0 => ctx.busWrite32(addr, r[rd]),
                1 => ctx.busWrite8(addr, @truncate(r[rd])),
                2 => r[rd] = ctx.busRead32(addr),
                3 => r[rd] = ctx.busRead8(addr),
            }
            if (ctx.softResetPending()) return;
            continue;
        }

        // Format 8: Load/store sign-extended byte/halfword
        if ((insn & 0xF200) == 0x5200) {
            const ro: usize = @intCast((insn >> 6) & 7);
            const rb: usize = @intCast((insn >> 3) & 7);
            const rd: usize = @intCast(insn & 7);
            const addr = r[rb] +% r[ro];
            const op: u2 = @truncate((insn >> 10) & 3);
            switch (op) {
                0 => ctx.busWrite16(addr, @truncate(r[rd])),
                1 => r[rd] = @bitCast(@as(i32, @as(i8, @bitCast(ctx.busRead8(addr))))),
                2 => r[rd] = ctx.busRead16(addr),
                3 => r[rd] = @bitCast(@as(i32, @as(i16, @bitCast(ctx.busRead16(addr))))),
            }
            if (ctx.softResetPending()) return;
            continue;
        }

        // Format 9: Load/store immediate offset
        if ((insn & 0xE000) == 0x6000) {
            const b_bit = ((insn >> 12) & 1) != 0;
            const l_bit = ((insn >> 11) & 1) != 0;
            const offset: u32 = (insn >> 6) & 0x1F;
            const rb: usize = @intCast((insn >> 3) & 7);
            const rd: usize = @intCast(insn & 7);
            if (b_bit) {
                const addr = r[rb] +% offset;
                if (l_bit) r[rd] = ctx.busRead8(addr) else ctx.busWrite8(addr, @truncate(r[rd]));
            } else {
                const addr = r[rb] +% (offset << 2);
                if (l_bit) r[rd] = ctx.busRead32(addr) else ctx.busWrite32(addr, r[rd]);
            }
            if (ctx.softResetPending()) return;
            continue;
        }

        // Format 10: Load/store halfword
        if ((insn & 0xF000) == 0x8000) {
            const l_bit = ((insn >> 11) & 1) != 0;
            const offset: u32 = @as(u32, (insn >> 6) & 0x1F) << 1;
            const rb: usize = @intCast((insn >> 3) & 7);
            const rd: usize = @intCast(insn & 7);
            const addr = r[rb] +% offset;
            if (l_bit) r[rd] = ctx.busRead16(addr) else ctx.busWrite16(addr, @truncate(r[rd]));
            if (ctx.softResetPending()) return;
            continue;
        }

        // Format 11: SP-relative load/store
        if ((insn & 0xF000) == 0x9000) {
            const l_bit = ((insn >> 11) & 1) != 0;
            const rd: usize = @intCast((insn >> 8) & 7);
            const offset: u32 = @as(u32, insn & 0xFF) << 2;
            const addr = r[13] +% offset;
            if (l_bit) r[rd] = ctx.busRead32(addr) else ctx.busWrite32(addr, r[rd]);
            if (ctx.softResetPending()) return;
            continue;
        }

        // Format 12: Load address
        if ((insn & 0xF000) == 0xA000) {
            const sp_flag = ((insn >> 11) & 1) != 0;
            const rd: usize = @intCast((insn >> 8) & 7);
            const offset: u32 = @as(u32, insn & 0xFF) << 2;
            r[rd] = if (sp_flag) r[13] +% offset else ((pc +% 2) & ~@as(u32, 3)) +% offset;
            continue;
        }

        // Format 13: Add offset to SP
        if ((insn & 0xFF00) == 0xB000) {
            const offset: u32 = @as(u32, insn & 0x7F) << 2;
            if ((insn & 0x80) != 0) r[13] -%= offset else r[13] +%= offset;
            continue;
        }

        // Format 14: Push/Pop
        if ((insn & 0xF600) == 0xB400) {
            const l_bit = ((insn >> 11) & 1) != 0;
            const pclr = ((insn >> 8) & 1) != 0;
            const rlist: u8 = @truncate(insn & 0xFF);
            if (l_bit) {
                for (0..8) |i| {
                    if ((rlist & (@as(u8, 1) << @intCast(i))) != 0) {
                        r[i] = ctx.busRead32(r[13]);
                        r[13] +%= 4;
                        if (ctx.softResetPending()) return;
                    }
                }
                if (pclr) {
                    const val = ctx.busRead32(r[13]);
                    r[13] +%= 4;
                    if (ctx.softResetPending()) return;
                    if ((val & ~@as(u32, 1)) == return_sentinel) break;
                    if ((val >> 24) == 0x08) {
                        r[15] = val;
                        ctx.setRet(val | 1);
                        break;
                    }
                    thumb = (val & 1) != 0;
                    pc = val & ~@as(u32, 1);
                }
            } else {
                if (pclr) {
                    r[13] -%= 4;
                    ctx.busWrite32(r[13], r[14]);
                    if (ctx.softResetPending()) return;
                }
                var i: i32 = 7;
                while (i >= 0) : (i -= 1) {
                    if ((rlist & (@as(u8, 1) << @intCast(i))) != 0) {
                        r[13] -%= 4;
                        ctx.busWrite32(r[13], r[@intCast(i)]);
                        if (ctx.softResetPending()) return;
                    }
                }
            }
            continue;
        }

        // Format 15: LDMIA / STMIA
        if ((insn & 0xF000) == 0xC000) {
            const l_bit = ((insn >> 11) & 1) != 0;
            const rb: usize = @intCast((insn >> 8) & 7);
            const rlist: u8 = @truncate(insn & 0xFF);
            var addr = r[rb];
            for (0..8) |i| {
                if ((rlist & (@as(u8, 1) << @intCast(i))) != 0) {
                    if (l_bit) r[i] = ctx.busRead32(addr) else ctx.busWrite32(addr, r[i]);
                    if (ctx.softResetPending()) return;
                    addr +%= 4;
                }
            }
            r[rb] = addr;
            continue;
        }

        // Format 16: Conditional branch (cond 0xF overlaps SWI Format 17)
        if ((insn & 0xF000) == 0xD000) {
            const cond: u4 = @truncate((insn >> 8) & 0xF);
            if (cond == 0xF) {
                ctx.swi(insn & 0xFF);
                if (ctx.softResetPending()) return;
                continue;
            }
            const offset: i32 = @as(i32, @as(i8, @bitCast(@as(u8, @truncate(insn & 0xFF))))) << 1;
            if (condMatch(ctx, cond)) {
                pc = @bitCast(@as(i32, @bitCast(pc)) +% offset +% 2);
            }
            continue;
        }

        // Format 18: Unconditional branch
        if ((insn & 0xF800) == 0xE000) {
            const offset: i32 = @as(i32, @bitCast(@as(u32, insn) << 21)) >> 20;
            pc = @bitCast(@as(i32, @bitCast(pc)) +% offset +% 2);
            continue;
        }

        // Format 19: Long branch with link (BL)
        if ((insn & 0xF800) == 0xF000) {
            ctx.charge(@intCast(ctx.accessCycles(pc, false)));
            if (ctx.softResetPending()) return;
            const insn2 = ctx.read16Raw(pc);
            pc +%= 2;
            if ((insn2 & 0xF800) == 0xF800) {
                const off_hi: i32 = @as(i32, @bitCast(@as(u32, insn & 0x07FF) << 21)) >> 9;
                const off_lo: i32 = @intCast(@as(u32, insn2 & 0x07FF) << 1);
                const bl_target: u32 = @bitCast(@as(i32, @bitCast(pc)) +% off_hi +% off_lo);
                r[14] = pc | 1;
                if ((bl_target >> 24) == 0x08) {
                    ctx.cpuBx(bl_target | 1);
                    if (ctx.softResetPending()) return;
                    ctx.setRet(0);
                } else {
                    pc = bl_target;
                }
            }
            continue;
        }

        ctx.warnUnknownThumb(insn, pc -% 2);
        break;
    }

    for (0..15) |i| {
        if ((r[i] & ~@as(u32, 1)) == return_sentinel) r[i] = saved_lr;
    }
    if (steps >= max_steps) {
        ctx.warnStepLimit(target, steps, pc);
    }
}

test "Interp ARM register-shift-by-0, atomic STMDB before charge, UMULL, and Thumb loop" {
    const MockInterpCtx = struct {
        r: [16]u32 = @splat(0),
        iwram_mem: [0x8000]u8 = @splat(0),
        n: bool = false,
        z: bool = false,
        c: bool = false,
        v: bool = false,
        cpsr_val: u32 = 0x1F,
        spsr_val: u32 = 0,
        mode: BusMode = .rom_code,
        ret_val: u32 = 0,
        irq_on_charge: bool = false,
        irq_saw_sp: u32 = 0,

        pub fn regs(self: *@This()) *[16]u32 {
            return &self.r;
        }
        pub fn getN(self: *const @This()) bool {
            return self.n;
        }
        pub fn setN(self: *@This(), b: bool) void {
            self.n = b;
        }
        pub fn getZ(self: *const @This()) bool {
            return self.z;
        }
        pub fn setZ(self: *@This(), b: bool) void {
            self.z = b;
        }
        pub fn getC(self: *const @This()) bool {
            return self.c;
        }
        pub fn setC(self: *@This(), b: bool) void {
            self.c = b;
        }
        pub fn getV(self: *const @This()) bool {
            return self.v;
        }
        pub fn setV(self: *@This(), b: bool) void {
            self.v = b;
        }
        pub fn getCpsr(self: *const @This()) u32 {
            return self.cpsr_val;
        }
        pub fn setCpsr(self: *@This(), val: u32, _: u32) void {
            self.cpsr_val = val;
        }
        pub fn getSpsr(self: *const @This()) u32 {
            return self.spsr_val;
        }
        pub fn setSpsr(self: *@This(), val: u32, _: u32) void {
            self.spsr_val = val;
        }
        pub fn getBusMode(self: *const @This()) BusMode {
            return self.mode;
        }
        pub fn setBusMode(self: *@This(), m: BusMode) void {
            self.mode = m;
        }
        pub fn setRet(self: *@This(), val: u32) void {
            self.ret_val = val;
        }
        pub fn softResetPending(_: *const @This()) bool {
            return false;
        }
        pub fn traceInterpEnter(_: *@This(), _: u32) void {}
        pub fn peekCodeWord(self: *const @This(), addr: u32) ?u32 {
            return self.read32Raw(addr);
        }
        pub fn accessCycles(_: *const @This(), _: u32, _: bool) u32 {
            return 1;
        }
        pub fn dataCycles(_: *const @This(), _: u32, _: bool, _: bool) i32 {
            return 1;
        }
        pub fn charge(self: *@This(), _: i32) void {
            if (self.irq_on_charge) {
                self.irq_saw_sp = self.r[13];
                // Simulate IRQ pushing a marker below current SP
                self.busWrite32Raw(self.r[13] -% 4, 0x0400_0200);
            }
        }
        pub fn read32Raw(self: *const @This(), addr: u32) u32 {
            const off = addr & 0x7FFC;
            return std.mem.readInt(u32, self.iwram_mem[off..][0..4], .little);
        }
        pub fn read16Raw(self: *const @This(), addr: u32) u16 {
            const off = addr & 0x7FFE;
            return std.mem.readInt(u16, self.iwram_mem[off..][0..2], .little);
        }
        pub fn busWrite32Raw(self: *@This(), addr: u32, val: u32) void {
            const off = addr & 0x7FFC;
            std.mem.writeInt(u32, self.iwram_mem[off..][0..4], val, .little);
        }
        pub fn busRead8(self: *@This(), addr: u32) u8 {
            return self.iwram_mem[addr & 0x7FFF];
        }
        pub fn busWrite8(self: *@This(), addr: u32, val: u8) void {
            self.iwram_mem[addr & 0x7FFF] = val;
        }
        pub fn busRead16(self: *@This(), addr: u32) u16 {
            return self.read16Raw(addr);
        }
        pub fn busWrite16(self: *@This(), addr: u32, val: u16) void {
            const off = addr & 0x7FFE;
            std.mem.writeInt(u16, self.iwram_mem[off..][0..2], val, .little);
        }
        pub fn busRead32(self: *@This(), addr: u32) u32 {
            return self.read32Raw(addr);
        }
        pub fn busWrite32(self: *@This(), addr: u32, val: u32) void {
            self.busWrite32Raw(addr, val);
        }
        pub fn swi(_: *@This(), _: u32) void {}
        pub fn cpuBx(_: *@This(), _: u32) void {}
        pub fn recompLookup(_: *const @This(), _: u32) u32 {
            return 0;
        }
        pub fn warnUnmappedArmBx(_: *@This(), _: u32, _: u32, _: u32) void {}
        pub fn warnUnknownArm(_: *@This(), _: u32, _: u32) void {}
        pub fn warnUnknownThumb(_: *@This(), _: u16, _: u32) void {}
        pub fn warnStepLimit(_: *@This(), _: u32, _: usize, _: u32) void {}
    };

    var ctx: MockInterpCtx = .{};

    // 1) ARM: MOVS r6, r6, ROR r0 (with r0 == 0, C=1) MUST be a no-op (not RRX!), then BX lr
    ctx.r[0] = 0;
    ctx.r[6] = 0x1234_5678;
    ctx.r[14] = 0x0800_1234;
    ctx.c = true;
    ctx.busWrite32Raw(0x0300_0000, 0xE1B0_6076); // MOVS r6, r6, ROR r0
    ctx.busWrite32Raw(0x0300_0004, 0xE12F_FF1E); // BX lr
    runFunction(&ctx, 0x0300_0000);
    try std.testing.expectEqual(@as(u32, 0x1234_5678), ctx.r[6]);
    try std.testing.expect(ctx.c);
    try std.testing.expectEqual(@as(u32, 0x0800_1234), ctx.r[14]);

    // 2) ARM: STMDB sp!, {r4, r12} atomic before charge()
    ctx = .{};
    ctx.r[4] = 0xAAAA_BBBB;
    ctx.r[12] = 0xCCCC_DDDD;
    ctx.r[13] = 0x0300_7B80;
    ctx.r[14] = 0x0800_2000;
    ctx.irq_on_charge = true;
    ctx.busWrite32Raw(0x0300_0100, 0xE92D_1010); // STMDB sp!, {r4, r12}
    ctx.busWrite32Raw(0x0300_0104, 0xE12F_FF1E); // BX lr
    runFunction(&ctx, 0x0300_0100);
    // SP must already be 0x0300_7B78 when STM charges, so IRQ writes to 0x0300_7B74, not 0x7B78!
    try std.testing.expectEqual(@as(u32, 0x0300_7B78), ctx.irq_saw_sp);
    try std.testing.expectEqual(@as(u32, 0xAAAA_BBBB), ctx.read32Raw(0x0300_7B78));
    try std.testing.expectEqual(@as(u32, 0xCCCC_DDDD), ctx.read32Raw(0x0300_7B7C));

    // 3) ARM UMULL r0, r1, r2, r3 (low=r0, hi=r1): 0x1_0000_0000 = 0x10000 * 0x10000
    ctx = .{};
    ctx.r[2] = 0x0001_0000;
    ctx.r[3] = 0x0001_0000;
    ctx.r[14] = 0x0800_3000;
    ctx.busWrite32Raw(0x0300_0200, 0xE081_0392); // UMULL r0, r1, r2, r3
    ctx.busWrite32Raw(0x0300_0204, 0xE12F_FF1E); // BX lr
    runFunction(&ctx, 0x0300_0200);
    try std.testing.expectEqual(@as(u32, 0), ctx.r[0]);
    try std.testing.expectEqual(@as(u32, 1), ctx.r[1]);

    // 4) Thumb function: PUSH {r4, lr}; MOV r0, #10; ADD r0, #5; LSL r0, r0, #1; POP {r4, pc}
    ctx = .{};
    ctx.r[13] = 0x0300_7F00;
    ctx.r[4] = 0x5555_5555;
    ctx.r[14] = 0x0800_4445;
    ctx.busWrite16(0x0300_0300, 0xB510); // PUSH {r4, lr}
    ctx.busWrite16(0x0300_0302, 0x200A); // MOV r0, #10
    ctx.busWrite16(0x0300_0304, 0x3005); // ADD r0, #5
    ctx.busWrite16(0x0300_0306, 0x0040); // LSL r0, r0, #1 -> 30
    ctx.busWrite16(0x0300_0308, 0xBD10); // POP {r4, pc}
    runFunction(&ctx, 0x0300_0301);
    try std.testing.expectEqual(@as(u32, 30), ctx.r[0]);
    try std.testing.expectEqual(@as(u32, 0x0300_7F00), ctx.r[13]);
}
