const std = @import("std");
const types = @import("types.zig");

pub const ArmCondition = types.ArmCondition;
pub const ShiftType = types.ShiftType;

pub const ArmInsnType = enum {
    and_op,
    eor,
    sub,
    rsb,
    add,
    adc,
    sbc,
    rsc,
    tst,
    teq,
    cmp,
    cmn,
    orr,
    mov,
    bic,
    mvn,
    mul,
    mla,
    umull,
    umlal,
    smull,
    smlal,
    b,
    bl,
    bx,
    ldr,
    str,
    ldrh,
    strh,
    ldrsb,
    ldrsh,
    ldm,
    stm,
    swp,
    swpb,
    mrs,
    msr,
    swi,
    undefined,

    pub fn mnemonic(self: ArmInsnType) []const u8 {
        return switch (self) {
            .and_op => "AND",
            .eor => "EOR",
            .sub => "SUB",
            .rsb => "RSB",
            .add => "ADD",
            .adc => "ADC",
            .sbc => "SBC",
            .rsc => "RSC",
            .tst => "TST",
            .teq => "TEQ",
            .cmp => "CMP",
            .cmn => "CMN",
            .orr => "ORR",
            .mov => "MOV",
            .bic => "BIC",
            .mvn => "MVN",
            .mul => "MUL",
            .mla => "MLA",
            .umull => "UMULL",
            .umlal => "UMLAL",
            .smull => "SMULL",
            .smlal => "SMLAL",
            .b => "B",
            .bl => "BL",
            .bx => "BX",
            .ldr => "LDR",
            .str => "STR",
            .ldrh => "LDRH",
            .strh => "STRH",
            .ldrsb => "LDRSB",
            .ldrsh => "LDRSH",
            .ldm => "LDM",
            .stm => "STM",
            .swp => "SWP",
            .swpb => "SWPB",
            .mrs => "MRS",
            .msr => "MSR",
            .swi => "SWI",
            .undefined => "UNDEFINED",
        };
    }
};

pub const ArmInsn = struct {
    type: ArmInsnType = .undefined,
    cond: ArmCondition = .al,
    rd: u4 = 0,
    rn: u4 = 0,
    rm: u4 = 0,
    rs: u4 = 0,
    s: bool = false,
    i: bool = false,
    p: bool = false,
    u: bool = false,
    b: bool = false,
    w: bool = false,
    l: bool = false,
    shift_type: ShiftType = .lsl,
    shift_amount: u5 = 0,
    shift_reg: bool = false,
    imm: u32 = 0,
    rotate: u4 = 0,
    branch_offset: i32 = 0,
    reg_list: u16 = 0,
    swi_number: u32 = 0,
    msr_mask: u4 = 0,
    r: bool = false,
    raw: u32 = 0,

    pub fn formatDisasm(self: *const ArmInsn, addr: u32, buf: []u8) []const u8 {
        var fbs = std.Io.Writer.fixed(buf);
        const w = &fbs;
        const c = types.condName(self.cond);
        switch (self.type) {
            .and_op, .eor, .sub, .rsb, .add, .adc, .sbc, .rsc, .orr, .bic => {
                w.print("{s}{s}{s} {s}, {s}, ", .{
                    self.type.mnemonic(),
                    c,
                    if (self.s) "S" else "",
                    types.regName(self.rd),
                    types.regName(self.rn),
                }) catch {};
                fmtOperand2(w, self);
            },
            .mov, .mvn => {
                w.print("{s}{s}{s} {s}, ", .{
                    self.type.mnemonic(),
                    c,
                    if (self.s) "S" else "",
                    types.regName(self.rd),
                }) catch {};
                fmtOperand2(w, self);
            },
            .tst, .teq, .cmp, .cmn => {
                w.print("{s}{s} {s}, ", .{
                    self.type.mnemonic(),
                    c,
                    types.regName(self.rn),
                }) catch {};
                fmtOperand2(w, self);
            },
            .mul => w.print("MUL{s}{s} {s}, {s}, {s}", .{
                c,
                if (self.s) "S" else "",
                types.regName(self.rd),
                types.regName(self.rm),
                types.regName(self.rs),
            }) catch {},
            .mla => w.print("MLA{s}{s} {s}, {s}, {s}, {s}", .{
                c,
                if (self.s) "S" else "",
                types.regName(self.rd),
                types.regName(self.rm),
                types.regName(self.rs),
                types.regName(self.rn),
            }) catch {},
            .umull, .umlal, .smull, .smlal => w.print("{s}{s}{s} {s}, {s}, {s}, {s}", .{
                self.type.mnemonic(),
                c,
                if (self.s) "S" else "",
                types.regName(self.rd),
                types.regName(self.rn),
                types.regName(self.rm),
                types.regName(self.rs),
            }) catch {},
            .b, .bl => {
                const target = addr +% 8 +% @as(u32, @bitCast(self.branch_offset));
                w.print("{s}{s} 0x{X:0>8}", .{ self.type.mnemonic(), c, target }) catch {};
            },
            .bx => w.print("BX{s} {s}", .{ c, types.regName(self.rm) }) catch {},
            .ldr, .str => {
                w.print("{s}{s}{s} {s}, ", .{
                    self.type.mnemonic(),
                    c,
                    if (self.b) "B" else "",
                    types.regName(self.rd),
                }) catch {};
                fmtAddrMode(w, self);
            },
            .ldrh, .strh, .ldrsb, .ldrsh => {
                w.print("{s}{s} {s}, ", .{
                    self.type.mnemonic(),
                    c,
                    types.regName(self.rd),
                }) catch {};
                fmtHalfwordAddr(w, self);
            },
            .ldm, .stm => {
                const mode: []const u8 = if (self.u and self.p)
                    "IB"
                else if (self.u and !self.p)
                    "IA"
                else if (!self.u and self.p)
                    "DB"
                else
                    "DA";
                w.print("{s}{s}{s} {s}{s}, {{", .{
                    self.type.mnemonic(),
                    c,
                    mode,
                    types.regName(self.rn),
                    if (self.w) "!" else "",
                }) catch {};
                var first = true;
                for (0..16) |ri| {
                    if ((self.reg_list & (@as(u16, 1) << @intCast(ri))) != 0) {
                        if (!first) w.writeAll(", ") catch {};
                        w.writeAll(types.regName(@intCast(ri))) catch {};
                        first = false;
                    }
                }
                w.writeAll("}") catch {};
                if (self.s) w.writeAll("^") catch {};
            },
            .swp, .swpb => w.print("{s}{s} {s}, {s}, [{s}]", .{
                self.type.mnemonic(),
                c,
                types.regName(self.rd),
                types.regName(self.rm),
                types.regName(self.rn),
            }) catch {},
            .mrs => w.print("MRS{s} {s}, {s}", .{
                c,
                types.regName(self.rd),
                if (self.r) "SPSR" else "CPSR",
            }) catch {},
            .msr => {
                w.print("MSR{s} {s}_", .{ c, if (self.r) "SPSR" else "CPSR" }) catch {};
                if ((self.msr_mask & 1) != 0) w.writeAll("c") catch {};
                if ((self.msr_mask & 2) != 0) w.writeAll("x") catch {};
                if ((self.msr_mask & 4) != 0) w.writeAll("s") catch {};
                if ((self.msr_mask & 8) != 0) w.writeAll("f") catch {};
                w.writeAll(", ") catch {};
                if (self.i) {
                    w.print("#0x{X}", .{self.imm}) catch {};
                } else {
                    w.writeAll(types.regName(self.rm)) catch {};
                }
            },
            .swi => w.print("SWI{s} 0x{X}", .{ c, self.swi_number }) catch {},
            .undefined => w.print("DCD 0x{X:0>8}  ; undefined", .{self.raw}) catch {},
        }
        return fbs.buffered();
    }
};

fn fmtShift(w: *std.Io.Writer, insn: *const ArmInsn) void {
    if (insn.shift_reg) {
        w.print(", {s} {s}", .{ types.shiftName(insn.shift_type), types.regName(insn.rs) }) catch {};
    } else if (insn.shift_amount != 0 or insn.shift_type != .lsl) {
        w.print(", {s} #{d}", .{ types.shiftName(insn.shift_type), insn.shift_amount }) catch {};
    }
}

fn fmtOperand2(w: *std.Io.Writer, insn: *const ArmInsn) void {
    if (insn.i) {
        w.print("#0x{X}", .{insn.imm}) catch {};
    } else {
        w.writeAll(types.regName(insn.rm)) catch {};
        fmtShift(w, insn);
    }
}

fn fmtAddrMode(w: *std.Io.Writer, insn: *const ArmInsn) void {
    const sign: []const u8 = if (insn.u) "" else "-";
    if (insn.p) {
        w.print("[{s}, ", .{types.regName(insn.rn)}) catch {};
        if (!insn.i) {
            w.print("#{s}0x{X}", .{ sign, insn.imm }) catch {};
        } else {
            w.print("{s}{s}", .{ sign, types.regName(insn.rm) }) catch {};
            fmtShift(w, insn);
        }
        w.print("]{s}", .{if (insn.w) "!" else ""}) catch {};
    } else {
        w.print("[{s}], ", .{types.regName(insn.rn)}) catch {};
        if (!insn.i) {
            w.print("#{s}0x{X}", .{ sign, insn.imm }) catch {};
        } else {
            w.print("{s}{s}", .{ sign, types.regName(insn.rm) }) catch {};
            fmtShift(w, insn);
        }
    }
}

fn fmtHalfwordAddr(w: *std.Io.Writer, insn: *const ArmInsn) void {
    const sign: []const u8 = if (insn.u) "" else "-";
    if (insn.p) {
        w.print("[{s}, ", .{types.regName(insn.rn)}) catch {};
        if (insn.i) {
            w.print("#{s}0x{X}", .{ sign, insn.imm }) catch {};
        } else {
            w.print("{s}{s}", .{ sign, types.regName(insn.rm) }) catch {};
        }
        w.print("]{s}", .{if (insn.w) "!" else ""}) catch {};
    } else {
        w.print("[{s}], ", .{types.regName(insn.rn)}) catch {};
        if (insn.i) {
            w.print("#{s}0x{X}", .{ sign, insn.imm }) catch {};
        } else {
            w.print("{s}{s}", .{ sign, types.regName(insn.rm) }) catch {};
        }
    }
}

inline fn bits(v: u32, comptime hi: u5, comptime lo: u5) u32 {
    const width: u6 = @as(u6, hi) - @as(u6, lo) + 1;
    const mask: u32 = @truncate((@as(u33, 1) << width) - 1);
    return (v >> lo) & mask;
}

inline fn bit(v: u32, comptime n: u5) bool {
    return ((v >> n) & 1) != 0;
}

inline fn ror32(val: u32, amount: u32) u32 {
    const sh: u5 = @truncate(amount);
    return std.math.rotr(u32, val, sh);
}

fn decodeOperand2Imm(out: *ArmInsn, insn: u32) void {
    out.i = true;
    out.rotate = @truncate(bits(insn, 11, 8));
    const imm8 = bits(insn, 7, 0);
    out.imm = ror32(imm8, @as(u32, out.rotate) * 2);
}

fn decodeOperand2Reg(out: *ArmInsn, insn: u32) void {
    out.i = false;
    out.rm = @truncate(bits(insn, 3, 0));
    out.shift_type = @enumFromInt(@as(u2, @truncate(bits(insn, 6, 5))));
    if (bit(insn, 4)) {
        out.shift_reg = true;
        out.rs = @truncate(bits(insn, 11, 8));
        out.shift_amount = 0;
    } else {
        out.shift_reg = false;
        out.shift_amount = @truncate(bits(insn, 11, 7));
    }
}

fn decodeDataProcessing(out: *ArmInsn, insn: u32) void {
    const dp_types = [16]ArmInsnType{
        .and_op, .eor, .sub, .rsb,
        .add,    .adc, .sbc, .rsc,
        .tst,    .teq, .cmp, .cmn,
        .orr,    .mov, .bic, .mvn,
    };
    out.type = dp_types[bits(insn, 24, 21)];
    out.s = bit(insn, 20);
    out.rn = @truncate(bits(insn, 19, 16));
    out.rd = @truncate(bits(insn, 15, 12));
    if (bit(insn, 25)) decodeOperand2Imm(out, insn) else decodeOperand2Reg(out, insn);
}

fn decodeMultiply(out: *ArmInsn, insn: u32) void {
    out.type = if (bit(insn, 21)) .mla else .mul;
    out.s = bit(insn, 20);
    out.rd = @truncate(bits(insn, 19, 16));
    out.rn = @truncate(bits(insn, 15, 12));
    out.rs = @truncate(bits(insn, 11, 8));
    out.rm = @truncate(bits(insn, 3, 0));
}

fn decodeMultiplyLong(out: *ArmInsn, insn: u32) void {
    const is_signed = bit(insn, 22);
    const acc = bit(insn, 21);
    out.type = if (is_signed) (if (acc) .smlal else .smull) else (if (acc) .umlal else .umull);
    out.s = bit(insn, 20);
    out.rn = @truncate(bits(insn, 19, 16));
    out.rd = @truncate(bits(insn, 15, 12));
    out.rs = @truncate(bits(insn, 11, 8));
    out.rm = @truncate(bits(insn, 3, 0));
}

fn decodeSwap(out: *ArmInsn, insn: u32) void {
    out.b = bit(insn, 22);
    out.type = if (out.b) .swpb else .swp;
    out.rn = @truncate(bits(insn, 19, 16));
    out.rd = @truncate(bits(insn, 15, 12));
    out.rm = @truncate(bits(insn, 3, 0));
}

fn decodeHalfwordTransfer(out: *ArmInsn, insn: u32) void {
    out.p = bit(insn, 24);
    out.u = bit(insn, 23);
    out.w = bit(insn, 21);
    out.rn = @truncate(bits(insn, 19, 16));
    out.rd = @truncate(bits(insn, 15, 12));
    const is_load = bit(insn, 20);
    const sh = bits(insn, 6, 5);
    if (bit(insn, 22)) {
        out.i = true;
        out.imm = (bits(insn, 11, 8) << 4) | bits(insn, 3, 0);
    } else {
        out.i = false;
        out.rm = @truncate(bits(insn, 3, 0));
    }
    if (is_load) {
        out.type = switch (sh) {
            1 => .ldrh,
            2 => .ldrsb,
            3 => .ldrsh,
            else => .undefined,
        };
    } else {
        out.type = if (sh == 1) .strh else .undefined;
    }
}

fn decodeMsr(out: *ArmInsn, insn: u32) void {
    out.type = .msr;
    out.r = bit(insn, 22);
    out.msr_mask = @truncate(bits(insn, 19, 16));
    if (bit(insn, 25)) {
        out.i = true;
        out.rotate = @truncate(bits(insn, 11, 8));
        out.imm = ror32(bits(insn, 7, 0), @as(u32, out.rotate) * 2);
    } else {
        out.i = false;
        out.rm = @truncate(bits(insn, 3, 0));
    }
}

fn decodeSingleTransfer(out: *ArmInsn, insn: u32) void {
    out.l = bit(insn, 20);
    out.type = if (out.l) .ldr else .str;
    out.i = bit(insn, 25);
    out.p = bit(insn, 24);
    out.u = bit(insn, 23);
    out.b = bit(insn, 22);
    out.w = bit(insn, 21);
    out.rn = @truncate(bits(insn, 19, 16));
    out.rd = @truncate(bits(insn, 15, 12));
    if (!out.i) {
        out.imm = bits(insn, 11, 0);
    } else {
        out.rm = @truncate(bits(insn, 3, 0));
        out.shift_type = @enumFromInt(@as(u2, @truncate(bits(insn, 6, 5))));
        out.shift_amount = @truncate(bits(insn, 11, 7));
        out.shift_reg = false;
    }
}

fn decodeCat00(out: *ArmInsn, insn: u32) void {
    const bits_7_4 = bits(insn, 7, 4);
    if ((insn & 0x0FFF_FFF0) == 0x012F_FF10) {
        out.type = .bx;
        out.rm = @truncate(bits(insn, 3, 0));
        return;
    }
    if ((insn & 0x0FBF_0FFF) == 0x010F_0000) {
        out.type = .mrs;
        out.r = bit(insn, 22);
        out.rd = @truncate(bits(insn, 15, 12));
        return;
    }
    if ((insn & 0x0FB0_FFF0) == 0x0120_F000 or (insn & 0x0FB0_F000) == 0x0320_F000) {
        decodeMsr(out, insn);
        return;
    }
    if (bits_7_4 == 0x9 and bits(insn, 27, 22) == 0x00) {
        decodeMultiply(out, insn);
        return;
    }
    if (bits_7_4 == 0x9 and bits(insn, 27, 23) == 0x01) {
        decodeMultiplyLong(out, insn);
        return;
    }
    if (bits_7_4 == 0x9 and bits(insn, 27, 23) == 0x02 and
        bits(insn, 21, 20) == 0x0 and bits(insn, 11, 8) == 0x0)
    {
        decodeSwap(out, insn);
        return;
    }
    if (bit(insn, 7) and bit(insn, 4) and bits(insn, 6, 5) != 0) {
        decodeHalfwordTransfer(out, insn);
        return;
    }
    decodeDataProcessing(out, insn);
}

/// Decode one 32-bit ARM7TDMI instruction.
pub fn decode(insn: u32) ArmInsn {
    var out: ArmInsn = .{
        .raw = insn,
        .cond = @enumFromInt(@as(u4, @truncate(bits(insn, 31, 28)))),
        .type = .undefined,
    };
    switch (@as(u2, @truncate(bits(insn, 27, 26)))) {
        0 => decodeCat00(&out, insn),
        1 => {
            if (bit(insn, 25) and bit(insn, 4)) {
                out.type = .undefined;
            } else {
                decodeSingleTransfer(&out, insn);
            }
        },
        2 => {
            if (bit(insn, 25)) {
                out.l = bit(insn, 24);
                out.type = if (out.l) .bl else .b;
                out.branch_offset = @as(i32, @bitCast(insn << 8)) >> 6;
            } else {
                out.l = bit(insn, 20);
                out.type = if (out.l) .ldm else .stm;
                out.p = bit(insn, 24);
                out.u = bit(insn, 23);
                out.s = bit(insn, 22);
                out.w = bit(insn, 21);
                out.rn = @truncate(bits(insn, 19, 16));
                out.reg_list = @truncate(insn & 0xFFFF);
            }
        },
        3 => {
            if (bits(insn, 27, 24) == 0xF) {
                out.type = .swi;
                out.swi_number = bits(insn, 23, 0);
            } else {
                out.type = .undefined;
            }
        },
    }
    return out;
}

test "ARM decoder covers data processing, multiply, transfers, BX, MSR/MRS, B/BL, SWI" {
    const bx_lr = decode(0xE12F_FF1E);
    try std.testing.expectEqual(ArmInsnType.bx, bx_lr.type);
    try std.testing.expectEqual(@as(u4, 14), bx_lr.rm);

    const b_back = decode(0xEAFF_FFFE); // offset = -8 -> B self
    try std.testing.expectEqual(ArmInsnType.b, b_back.type);
    try std.testing.expectEqual(@as(i32, -8), b_back.branch_offset);

    const msr_imm = decode(0xE329_F01F); // MSR CPSR_fc, #0x1F
    try std.testing.expectEqual(ArmInsnType.msr, msr_imm.type);
    try std.testing.expectEqual(@as(u4, 0x9), msr_imm.msr_mask);
    try std.testing.expectEqual(@as(u32, 0x1F), msr_imm.imm);

    const mrs = decode(0xE10F_0000);
    try std.testing.expectEqual(ArmInsnType.mrs, mrs.type);
    try std.testing.expectEqual(@as(u4, 0), mrs.rd);

    const stmdb = decode(0xE92D_40F0); // STMDB sp!, {r4-r7, lr}
    try std.testing.expectEqual(ArmInsnType.stm, stmdb.type);
    try std.testing.expect(stmdb.p and !stmdb.u and stmdb.w);
    try std.testing.expectEqual(@as(u16, 0x40F0), stmdb.reg_list);

    const ldrsb = decode(0xE1D0_50D0); // LDRSB r5, [r0, #0]
    try std.testing.expectEqual(ArmInsnType.ldrsb, ldrsb.type);
    try std.testing.expectEqual(@as(u4, 5), ldrsb.rd);

    const umull = decode(0xE081_0392); // UMULL r0, r1, r2, r3
    try std.testing.expectEqual(ArmInsnType.umull, umull.type);
    try std.testing.expectEqual(@as(u4, 0), umull.rd);
    try std.testing.expectEqual(@as(u4, 1), umull.rn);

    const swp = decode(0xE101_0092); // SWP r0, r2, [r1]
    try std.testing.expectEqual(ArmInsnType.swp, swp.type);

    const undef_sdt = decode(0xE790_1012); // bit25=1 and bit4=1 in cat01
    try std.testing.expectEqual(ArmInsnType.undefined, undef_sdt.type);
}
