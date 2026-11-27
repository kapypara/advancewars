const std = @import("std");
const types = @import("types.zig");

pub const ArmCondition = types.ArmCondition;
pub const ShiftType = types.ShiftType;
pub const ArmRegister = types.ArmRegister;

pub const ThumbInsnType = enum {
    move_shifted,
    add_sub,
    mov_cmp_add_sub_imm,
    alu_ops,
    hi_reg_ops,
    bx,
    pc_rel_load,
    load_store_reg,
    load_store_sign,
    load_store_imm,
    load_store_half,
    sp_rel_load_store,
    load_addr,
    add_sp,
    push_pop,
    multi_load_store,
    cond_branch,
    swi,
    branch,
    long_branch,
    undefined,
};

pub const ThumbAluOp = enum(u4) {
    and_op = 0x0,
    eor = 0x1,
    lsl = 0x2,
    lsr = 0x3,
    asr = 0x4,
    adc = 0x5,
    sbc = 0x6,
    ror = 0x7,
    tst = 0x8,
    neg = 0x9,
    cmp = 0xA,
    cmn = 0xB,
    orr = 0xC,
    mul = 0xD,
    bic = 0xE,
    mvn = 0xF,

    pub fn mnemonic(self: ThumbAluOp) []const u8 {
        const names = [16][]const u8{
            "AND", "EOR", "LSL", "LSR", "ASR", "ADC", "SBC", "ROR",
            "TST", "NEG", "CMP", "CMN", "ORR", "MUL", "BIC", "MVN",
        };
        return names[@intFromEnum(self)];
    }
};

pub const ThumbHiOp = enum(u2) {
    add = 0,
    cmp = 1,
    mov = 2,
    bx = 3,
};

pub const ThumbInsn = struct {
    type: ThumbInsnType = .undefined,
    raw: u16 = 0,
    rd: u4 = 0,
    rs: u4 = 0,
    rm: u4 = 0,
    imm: u32 = 0,
    offset: i32 = 0,
    cond: ArmCondition = .eq,
    shift_type: ShiftType = .lsl,
    shift_amount: u5 = 0,
    alu_op: ThumbAluOp = .and_op,
    hi_op: ThumbHiOp = .add,
    is_load: bool = false,
    is_byte: bool = false,
    is_signed: bool = false,
    is_half: bool = false,
    is_imm: bool = false,
    is_subtract: bool = false,
    is_sp: bool = false,
    is_suffix: bool = false,
    pc_or_lr: bool = false,
    rlist: u8 = 0,
    swi_num: u8 = 0,

    pub fn formatDisasm(self: *const ThumbInsn, addr: u32, buf: []u8) []const u8 {
        var fbs = std.Io.Writer.fixed(buf);
        const w = &fbs;
        switch (self.type) {
            .move_shifted => w.print("{s} {s}, {s}, #{d}", .{
                types.shiftName(self.shift_type),
                types.regName(self.rd),
                types.regName(self.rs),
                self.shift_amount,
            }) catch {},
            .add_sub => {
                const op: []const u8 = if (self.is_subtract) "SUB" else "ADD";
                if (self.is_imm) {
                    w.print("{s} {s}, {s}, #{d}", .{
                        op,
                        types.regName(self.rd),
                        types.regName(self.rs),
                        self.imm,
                    }) catch {};
                } else {
                    w.print("{s} {s}, {s}, {s}", .{
                        op,
                        types.regName(self.rd),
                        types.regName(self.rs),
                        types.regName(self.rm),
                    }) catch {};
                }
            },
            .mov_cmp_add_sub_imm => {
                const ops = [4][]const u8{ "MOV", "CMP", "ADD", "SUB" };
                w.print("{s} {s}, #0x{X}", .{
                    ops[@intFromEnum(self.hi_op)],
                    types.regName(self.rd),
                    self.imm,
                }) catch {};
            },
            .alu_ops => w.print("{s} {s}, {s}", .{
                self.alu_op.mnemonic(),
                types.regName(self.rd),
                types.regName(self.rs),
            }) catch {},
            .hi_reg_ops => {
                const ops = [4][]const u8{ "ADD", "CMP", "MOV", "BX" };
                w.print("{s} {s}, {s}", .{
                    ops[@intFromEnum(self.hi_op)],
                    types.regName(self.rd),
                    types.regName(self.rs),
                }) catch {};
            },
            .bx => w.print("BX {s}", .{types.regName(self.rs)}) catch {},
            .pc_rel_load => {
                const base = (addr +% 4) & ~@as(u32, 3);
                w.print("LDR {s}, [pc, #0x{X}]  ; =0x{X:0>8}", .{
                    types.regName(self.rd),
                    self.imm,
                    base +% self.imm,
                }) catch {};
            },
            .load_store_reg => w.print("{s}{s} {s}, [{s}, {s}]", .{
                if (self.is_load) "LDR" else "STR",
                if (self.is_byte) "B" else "",
                types.regName(self.rd),
                types.regName(self.rs),
                types.regName(self.rm),
            }) catch {},
            .load_store_sign => {
                const op: []const u8 = if (!self.is_load and self.is_half)
                    "STRH"
                else if (self.is_load and self.is_half and !self.is_signed)
                    "LDRH"
                else if (self.is_load and self.is_byte and self.is_signed)
                    "LDRSB"
                else
                    "LDRSH";
                w.print("{s} {s}, [{s}, {s}]", .{
                    op,
                    types.regName(self.rd),
                    types.regName(self.rs),
                    types.regName(self.rm),
                }) catch {};
            },
            .load_store_imm => w.print("{s}{s} {s}, [{s}, #0x{X}]", .{
                if (self.is_load) "LDR" else "STR",
                if (self.is_byte) "B" else "",
                types.regName(self.rd),
                types.regName(self.rs),
                self.imm,
            }) catch {},
            .load_store_half => w.print("{s} {s}, [{s}, #0x{X}]", .{
                if (self.is_load) "LDRH" else "STRH",
                types.regName(self.rd),
                types.regName(self.rs),
                self.imm,
            }) catch {},
            .sp_rel_load_store => w.print("{s} {s}, [sp, #0x{X}]", .{
                if (self.is_load) "LDR" else "STR",
                types.regName(self.rd),
                self.imm,
            }) catch {},
            .load_addr => w.print("ADD {s}, {s}, #0x{X}", .{
                types.regName(self.rd),
                if (self.is_sp) "sp" else "pc",
                self.imm,
            }) catch {},
            .add_sp => w.print("ADD sp, #{s}0x{X}", .{
                if (self.is_subtract) "-" else "",
                self.imm,
            }) catch {},
            .push_pop => {
                w.print("{s} {{", .{if (self.is_load) "POP" else "PUSH"}) catch {};
                var first = true;
                for (0..8) |ri| {
                    if ((self.rlist & (@as(u8, 1) << @intCast(ri))) != 0) {
                        if (!first) w.writeAll(", ") catch {};
                        w.writeAll(types.regName(@intCast(ri))) catch {};
                        first = false;
                    }
                }
                if (self.pc_or_lr) {
                    if (!first) w.writeAll(", ") catch {};
                    w.writeAll(if (self.is_load) "pc" else "lr") catch {};
                }
                w.writeAll("}") catch {};
            },
            .multi_load_store => {
                w.print("{s} {s}!, {{", .{
                    if (self.is_load) "LDMIA" else "STMIA",
                    types.regName(self.rs),
                }) catch {};
                var first = true;
                for (0..8) |ri| {
                    if ((self.rlist & (@as(u8, 1) << @intCast(ri))) != 0) {
                        if (!first) w.writeAll(", ") catch {};
                        w.writeAll(types.regName(@intCast(ri))) catch {};
                        first = false;
                    }
                }
                w.writeAll("}") catch {};
            },
            .cond_branch => {
                const target = addr +% 4 +% @as(u32, @bitCast(self.offset));
                w.print("B{s} 0x{X:0>8}", .{ types.condName(self.cond), target }) catch {};
            },
            .swi => w.print("SWI 0x{X:0>2}", .{self.swi_num}) catch {},
            .branch => {
                const target = addr +% 4 +% @as(u32, @bitCast(self.offset));
                w.print("B 0x{X:0>8}", .{target}) catch {};
            },
            .long_branch => {
                if (self.is_suffix) {
                    w.print("BL <suffix> offset_lo=0x{X}", .{self.imm}) catch {};
                } else {
                    w.print("BL <prefix> offset_hi=0x{X}", .{@as(u32, @bitCast(self.offset))}) catch {};
                }
            },
            .undefined => w.print("DCW 0x{X:0>4}  ; undefined", .{self.raw}) catch {},
        }
        return fbs.buffered();
    }
};

inline fn bits(v: u16, comptime hi: u4, comptime lo: u4) u16 {
    const width: u5 = @as(u5, hi) - @as(u5, lo) + 1;
    const mask: u16 = @truncate((@as(u17, 1) << width) - 1);
    return (v >> lo) & mask;
}

inline fn bit(v: u16, comptime n: u4) bool {
    return ((v >> n) & 1) != 0;
}

pub inline fn isBlPrefix(insn: u16) bool {
    return (insn & 0xF800) == 0xF000;
}

pub inline fn isBlSuffix(insn: u16) bool {
    return (insn & 0xF800) == 0xF800;
}

/// Decode one 16-bit Thumb instruction.
pub fn decode(raw: u16) ThumbInsn {
    const top8 = bits(raw, 15, 8);
    const top5 = bits(raw, 15, 11);
    const top3 = bits(raw, 15, 13);
    const top6 = bits(raw, 15, 10);
    const top4 = bits(raw, 15, 12);

    if (top5 == 0x1E or top5 == 0x1F) {
        if (top5 == 0x1E) {
            const off_hi: i32 = @as(i32, @bitCast(@as(u32, raw & 0x07FF) << 21)) >> 9;
            return .{ .type = .long_branch, .raw = raw, .is_suffix = false, .offset = off_hi };
        }
        return .{ .type = .long_branch, .raw = raw, .is_suffix = true, .imm = @as(u32, raw & 0x07FF) << 1 };
    }

    if (top5 == 0x1C) {
        const off: i32 = @as(i32, @bitCast(@as(u32, raw & 0x07FF) << 21)) >> 20;
        return .{ .type = .branch, .raw = raw, .offset = off };
    }

    if (top8 == 0xDF) {
        return .{ .type = .swi, .raw = raw, .swi_num = @truncate(raw & 0xFF), .imm = raw & 0xFF };
    }

    if (top4 == 0xD) {
        const cond_raw: u4 = @truncate(bits(raw, 11, 8));
        if (cond_raw == 0xF) {
            return .{ .type = .swi, .raw = raw, .swi_num = @truncate(raw & 0xFF), .imm = raw & 0xFF };
        }
        if (cond_raw == 0xE) {
            return .{ .type = .undefined, .raw = raw };
        }
        const off: i32 = @as(i32, @as(i8, @bitCast(@as(u8, @truncate(raw))))) << 1;
        return .{ .type = .cond_branch, .raw = raw, .cond = @enumFromInt(cond_raw), .offset = off };
    }

    if (top4 == 0xC) {
        return .{
            .type = .multi_load_store,
            .raw = raw,
            .rs = @truncate(bits(raw, 10, 8)),
            .is_load = bit(raw, 11),
            .rlist = @truncate(raw & 0xFF),
        };
    }

    if (top4 == 0xB) {
        if (bits(raw, 10, 9) == 2) {
            return .{
                .type = .push_pop,
                .raw = raw,
                .is_load = bit(raw, 11),
                .pc_or_lr = bit(raw, 8),
                .rlist = @truncate(raw & 0xFF),
                .rs = @intFromEnum(ArmRegister.sp),
            };
        }
        if (top8 == 0xB0) {
            return .{
                .type = .add_sp,
                .raw = raw,
                .rd = @intFromEnum(ArmRegister.sp),
                .rs = @intFromEnum(ArmRegister.sp),
                .is_subtract = bit(raw, 7),
                .imm = @as(u32, bits(raw, 6, 0)) << 2,
            };
        }
        return .{ .type = .undefined, .raw = raw };
    }

    if (top4 == 0xA) {
        const is_sp = bit(raw, 11);
        return .{
            .type = .load_addr,
            .raw = raw,
            .rd = @truncate(bits(raw, 10, 8)),
            .is_sp = is_sp,
            .rs = if (is_sp) @intFromEnum(ArmRegister.sp) else @intFromEnum(ArmRegister.pc),
            .imm = @as(u32, raw & 0xFF) << 2,
        };
    }

    if (top4 == 0x9) {
        return .{
            .type = .sp_rel_load_store,
            .raw = raw,
            .rd = @truncate(bits(raw, 10, 8)),
            .rs = @intFromEnum(ArmRegister.sp),
            .is_load = bit(raw, 11),
            .imm = @as(u32, raw & 0xFF) << 2,
        };
    }

    if (top4 == 0x8) {
        return .{
            .type = .load_store_half,
            .raw = raw,
            .rd = @truncate(bits(raw, 2, 0)),
            .rs = @truncate(bits(raw, 5, 3)),
            .is_load = bit(raw, 11),
            .is_half = true,
            .imm = @as(u32, bits(raw, 10, 6)) << 1,
        };
    }

    if (top3 == 0x3) {
        const is_byte = bit(raw, 12);
        const off5: u32 = bits(raw, 10, 6);
        return .{
            .type = .load_store_imm,
            .raw = raw,
            .rd = @truncate(bits(raw, 2, 0)),
            .rs = @truncate(bits(raw, 5, 3)),
            .is_load = bit(raw, 11),
            .is_byte = is_byte,
            .imm = if (is_byte) off5 else off5 << 2,
        };
    }

    if (top4 == 0x5) {
        if (!bit(raw, 9)) {
            return .{
                .type = .load_store_reg,
                .raw = raw,
                .rd = @truncate(bits(raw, 2, 0)),
                .rs = @truncate(bits(raw, 5, 3)),
                .rm = @truncate(bits(raw, 8, 6)),
                .is_load = bit(raw, 11),
                .is_byte = bit(raw, 10),
            };
        }
        const s = bit(raw, 10);
        const h = bit(raw, 11);
        return .{
            .type = .load_store_sign,
            .raw = raw,
            .rd = @truncate(bits(raw, 2, 0)),
            .rs = @truncate(bits(raw, 5, 3)),
            .rm = @truncate(bits(raw, 8, 6)),
            .is_load = s or h,
            .is_byte = s and !h,
            .is_half = !s or h,
            .is_signed = s,
        };
    }

    if (top5 == 0x09) {
        return .{
            .type = .pc_rel_load,
            .raw = raw,
            .rd = @truncate(bits(raw, 10, 8)),
            .imm = @as(u32, raw & 0xFF) << 2,
            .is_load = true,
        };
    }

    if (top6 == 0x11) {
        const op: ThumbHiOp = @enumFromInt(@as(u2, @truncate(bits(raw, 9, 8))));
        const rd: u4 = @truncate(bits(raw, 2, 0) | (bits(raw, 7, 7) << 3));
        const rs: u4 = @truncate(bits(raw, 5, 3) | (bits(raw, 6, 6) << 3));
        return .{
            .type = if (op == .bx) .bx else .hi_reg_ops,
            .raw = raw,
            .rd = rd,
            .rs = rs,
            .hi_op = op,
        };
    }

    if (top6 == 0x10) {
        return .{
            .type = .alu_ops,
            .raw = raw,
            .rd = @truncate(bits(raw, 2, 0)),
            .rs = @truncate(bits(raw, 5, 3)),
            .alu_op = @enumFromInt(@as(u4, @truncate(bits(raw, 9, 6)))),
        };
    }

    if (top3 == 0x1) {
        const op: u2 = @truncate(bits(raw, 12, 11));
        const alu_map = [4]ThumbAluOp{ .and_op, .cmp, .adc, .sbc };
        return .{
            .type = .mov_cmp_add_sub_imm,
            .raw = raw,
            .rd = @truncate(bits(raw, 10, 8)),
            .imm = raw & 0xFF,
            .alu_op = alu_map[op],
            .hi_op = @enumFromInt(op),
        };
    }

    if (top3 == 0x0) {
        if (bits(raw, 12, 11) == 3) {
            const is_imm = bit(raw, 10);
            const val3 = bits(raw, 8, 6);
            return .{
                .type = .add_sub,
                .raw = raw,
                .rd = @truncate(bits(raw, 2, 0)),
                .rs = @truncate(bits(raw, 5, 3)),
                .rm = if (is_imm) 0 else @truncate(val3),
                .imm = if (is_imm) val3 else 0,
                .is_subtract = bit(raw, 9),
                .is_imm = is_imm,
            };
        }
        const op = bits(raw, 12, 11);
        return .{
            .type = .move_shifted,
            .raw = raw,
            .rd = @truncate(bits(raw, 2, 0)),
            .rs = @truncate(bits(raw, 5, 3)),
            .shift_amount = @truncate(bits(raw, 10, 6)),
            .shift_type = switch (op) {
                0 => .lsl,
                1 => .lsr,
                2 => .asr,
                else => .lsl,
            },
        };
    }

    return .{ .type = .undefined, .raw = raw };
}

test "Thumb decoder handles all 19 formats cleanly" {
    const add_sub = decode(0x1E40); // SUB r0, r0, #1
    try std.testing.expectEqual(ThumbInsnType.add_sub, add_sub.type);
    try std.testing.expect(add_sub.is_subtract and add_sub.is_imm);
    try std.testing.expectEqual(@as(u32, 1), add_sub.imm);

    const lsl = decode(0x0080); // LSL r0, r0, #2
    try std.testing.expectEqual(ThumbInsnType.move_shifted, lsl.type);
    try std.testing.expectEqual(ShiftType.lsl, lsl.shift_type);
    try std.testing.expectEqual(@as(u5, 2), lsl.shift_amount);

    const bx = decode(0x4718); // BX r3
    try std.testing.expectEqual(ThumbInsnType.bx, bx.type);
    try std.testing.expectEqual(@as(u4, 3), bx.rs);

    const push = decode(0xB510); // PUSH {r4, lr}
    try std.testing.expectEqual(ThumbInsnType.push_pop, push.type);
    try std.testing.expect(!push.is_load and push.pc_or_lr);
    try std.testing.expectEqual(@as(u8, 0x10), push.rlist);

    const beq = decode(0xD0FE); // BEQ -4
    try std.testing.expectEqual(ThumbInsnType.cond_branch, beq.type);
    try std.testing.expectEqual(ArmCondition.eq, beq.cond);
    try std.testing.expectEqual(@as(i32, -4), beq.offset);

    const swi = decode(0xDF05);
    try std.testing.expectEqual(ThumbInsnType.swi, swi.type);
    try std.testing.expectEqual(@as(u8, 5), swi.swi_num);

    const b_back = decode(0xE7FE);
    try std.testing.expectEqual(ThumbInsnType.branch, b_back.type);
    try std.testing.expectEqual(@as(i32, -4), b_back.offset);

    const bl_p = decode(0xF000);
    const bl_s = decode(0xF804);
    try std.testing.expect(isBlPrefix(bl_p.raw) and isBlSuffix(bl_s.raw));
    try std.testing.expectEqual(@as(u32, 8), bl_s.imm);
}
