const std = @import("std");
const types = @import("types.zig");
const rom_mod = @import("rom.zig");
const arm_mod = @import("arm.zig");
const thumb_mod = @import("thumb.zig");
const analysis_mod = @import("analysis.zig");

const GbaRom = rom_mod.GbaRom;
const AnalysisCtx = analysis_mod.AnalysisCtx;
const BasicBlock = analysis_mod.BasicBlock;
const Function = analysis_mod.Function;
const ArmInsn = arm_mod.ArmInsn;
const ThumbInsn = thumb_mod.ThumbInsn;
const ShiftType = types.ShiftType;
const ArmCondition = types.ArmCondition;

pub const target_func_shards: usize = 64;
pub const stubs_per_file: usize = 256;

fn orderU32(lhs: u32, rhs: u32) std.math.Order {
    return std.math.order(lhs, rhs);
}

pub const TranslateStats = struct {
    num_func_files: usize,
    num_stub_files: usize,
    num_functions: usize,
    num_stubs: usize,
    num_unresolved: usize,
    num_prongs_emitted: usize,
    num_delegated_funcs: usize,
};

const ShardKind = enum {
    func,
    stub,
    unresolved,
};

const ShardLoc = struct {
    kind: ShardKind,
    shard_idx: usize,
};

const Emitter = struct {
    allocator: std.mem.Allocator,
    rom: *const GbaRom,
    analysis: *const AnalysisCtx,
    buf: std.ArrayList(u8),
    indent: usize = 0,
    current_kind: ShardKind = .func,
    current_shard: usize = 0,
    setjmp_resume: u32 = 0,
    local_prongs: *std.AutoHashMap(u32, u32),
    effective_owners: []const u32,
    target_to_shard: *const std.AutoHashMap(u32, ShardLoc),
    blocks_by_start: *const std.AutoHashMap(u32, usize),
    jts_by_branch: *const std.AutoHashMap(u32, usize),
    func_idx_by_entry: *const std.AutoHashMap(u32, usize),
    func_emit_blocks: []const []u32,

    fn writeIndent(self: *Emitter) !void {
        for (0..self.indent) |_| {
            try self.buf.appendSlice(self.allocator, "    ");
        }
    }

    fn line(self: *Emitter, comptime fmt: []const u8, args: anytype) !void {
        try self.writeIndent();
        try self.buf.print(self.allocator, fmt ++ "\n", args);
    }

    fn raw(self: *Emitter, comptime fmt: []const u8, args: anytype) !void {
        try self.buf.print(self.allocator, fmt, args);
    }

    fn formatCall(self: *const Emitter, addr: u32, buf: []u8) []const u8 {
        if (self.target_to_shard.get(addr)) |loc| {
            const same = (loc.kind == self.current_kind and loc.shard_idx == self.current_shard);
            if (same) {
                return std.fmt.bufPrint(buf, "func_{X:0>8}()", .{addr}) catch unreachable;
            }
            return std.fmt.bufPrint(buf, "decls.func_{X:0>8}()", .{addr}) catch unreachable;
        }
        return std.fmt.bufPrint(buf, "func_{X:0>8}()", .{addr}) catch unreachable;
    }

    fn lookupDenseIdx(self: *const Emitter, owner: u32, block_addr: u32) ?u32 {
        const fi = self.func_idx_by_entry.get(owner) orelse return null;
        const slice = self.func_emit_blocks[fi];
        const idx = std.sort.binarySearch(u32, slice, block_addr, orderU32) orelse return null;
        return @intCast(idx);
    }

    fn formatEnter(self: *const Emitter, owner: u32, block_addr: u32, buf: []u8) []const u8 {
        const dense_idx = self.lookupDenseIdx(owner, block_addr) orelse return self.formatCall(block_addr, buf);
        if (self.target_to_shard.get(owner)) |loc| {
            if (loc.kind == .func) {
                if (self.current_kind == .func and loc.shard_idx == self.current_shard) {
                    return std.fmt.bufPrint(buf, "enter_{X:0>8}({d})", .{ owner, dense_idx }) catch unreachable;
                }
                return std.fmt.bufPrint(buf, "decls.enter_{X:0>8}({d})", .{
                    owner,
                    dense_idx,
                }) catch unreachable;
            }
        }
        return self.formatCall(block_addr, buf);
    }

    fn condToZig(cond: ArmCondition) ?[]const u8 {
        return switch (cond) {
            .eq => "rt.CPU_Z",
            .ne => "!rt.CPU_Z",
            .cs => "rt.CPU_C",
            .cc => "!rt.CPU_C",
            .mi => "rt.CPU_N",
            .pl => "!rt.CPU_N",
            .vs => "rt.CPU_V",
            .vc => "!rt.CPU_V",
            .hi => "(rt.CPU_C and !rt.CPU_Z)",
            .ls => "(!rt.CPU_C or rt.CPU_Z)",
            .ge => "(rt.CPU_N == rt.CPU_V)",
            .lt => "(rt.CPU_N != rt.CPU_V)",
            .gt => "(!rt.CPU_Z and rt.CPU_N == rt.CPU_V)",
            .le => "(rt.CPU_Z or rt.CPU_N != rt.CPU_V)",
            .al => null,
            .nv => "false",
        };
    }

    fn regZ(reg: u4) []const u8 {
        const names = [16][]const u8{
            "rt.r[0]",  "rt.r[1]",  "rt.r[2]",  "rt.r[3]",
            "rt.r[4]",  "rt.r[5]",  "rt.r[6]",  "rt.r[7]",
            "rt.r[8]",  "rt.r[9]",  "rt.r[10]", "rt.r[11]",
            "rt.r[12]", "rt.r[13]", "rt.r[14]", "rt.r[15]",
        };
        return names[reg];
    }

    fn operand2ToZig(insn: *const ArmInsn, buf: []u8) []const u8 {
        if (insn.i) {
            return std.fmt.bufPrint(buf, "0x{X}", .{insn.imm}) catch unreachable;
        }
        if (insn.shift_reg) {
            return switch (insn.shift_type) {
                .lsl => std.fmt.bufPrint(buf, "rt.armLsl({s}, {s} & 0xFF)", .{ regZ(insn.rm), regZ(insn.rs) }) catch unreachable,
                .lsr => std.fmt.bufPrint(buf, "rt.armLsr({s}, {s} & 0xFF)", .{ regZ(insn.rm), regZ(insn.rs) }) catch unreachable,
                .asr => std.fmt.bufPrint(buf, "rt.armAsr({s}, {s} & 0xFF)", .{ regZ(insn.rm), regZ(insn.rs) }) catch unreachable,
                .ror => std.fmt.bufPrint(buf, "rt.ror32({s}, {s} & 0xFF)", .{ regZ(insn.rm), regZ(insn.rs) }) catch unreachable,
            };
        }
        if (insn.shift_amount == 0 and insn.shift_type == .lsl) {
            return std.fmt.bufPrint(buf, "{s}", .{regZ(insn.rm)}) catch unreachable;
        }
        return switch (insn.shift_type) {
            .lsl => std.fmt.bufPrint(buf, "({s} << {d})", .{ regZ(insn.rm), insn.shift_amount }) catch unreachable,
            .lsr => if (insn.shift_amount == 0)
                "0"
            else
                std.fmt.bufPrint(buf, "({s} >> {d})", .{ regZ(insn.rm), insn.shift_amount }) catch unreachable,
            .asr => if (insn.shift_amount == 0)
                std.fmt.bufPrint(buf, "rt.asrConst({s}, 31)", .{regZ(insn.rm)}) catch unreachable
            else
                std.fmt.bufPrint(buf, "rt.asrConst({s}, {d})", .{ regZ(insn.rm), insn.shift_amount }) catch unreachable,
            .ror => if (insn.shift_amount == 0)
                std.fmt.bufPrint(buf, "rt.rrx({s})", .{regZ(insn.rm)}) catch unreachable
            else
                std.fmt.bufPrint(buf, "rt.ror32({s}, {d})", .{ regZ(insn.rm), insn.shift_amount }) catch unreachable,
        };
    }

    fn beginCond(self: *Emitter, cond: ArmCondition) !bool {
        if (condToZig(cond)) |c| {
            try self.line("if ({s}) {{", .{c});
            self.indent += 1;
            return true;
        }
        return false;
    }

    fn endCond(self: *Emitter, cond_open: bool) !void {
        if (cond_open) {
            self.indent -= 1;
            try self.line("}}", .{});
        }
    }

    fn emitBranchTarget(self: *Emitter, target: u32) !void {
        if (self.local_prongs.get(target)) |idx| {
            try self.line("continue :blk {d};", .{idx});
            return;
        }
        if (self.blocks_by_start.get(target)) |bi| {
            const owner = self.effective_owners[bi];
            if (self.target_to_shard.get(target)) |loc| {
                if (loc.kind == .func and (owner == target or thumbBxVeneerReg(self.rom, target) != null)) {
                    var cbuf: [64]u8 = undefined;
                    try self.line("{s}; return;", .{self.formatCall(target, &cbuf)});
                    return;
                }
            }
            if (owner != 0) {
                var ebuf: [80]u8 = undefined;
                try self.line("{s}; return;", .{self.formatEnter(owner, target, &ebuf)});
                return;
            }
        }
        var cbuf: [64]u8 = undefined;
        try self.line("{s}; return;", .{self.formatCall(target, &cbuf)});
    }

    fn emitCalled(self: *Emitter, retaddr: u32) !void {
        if (self.setjmp_resume != 0) {
            if (self.local_prongs.get(self.setjmp_resume & ~@as(u32, 1))) |resume_idx| {
                try self.line(
                    "if (((rt.g_ret ^ 0x{X:0>8}) & ~@as(u32, 1)) == 0) {{ rt.g_ret = 0; continue :blk {d}; }}",
                    .{ self.setjmp_resume, resume_idx },
                );
            }
        }
        try self.line("if (!rt.recompCalled(0x{X:0>8})) return;", .{retaddr});
    }

    fn translateArmInsn(self: *Emitter, insn: *const ArmInsn, addr: u32) !bool {
        var op2_buf: [128]u8 = undefined;
        var call_buf: [64]u8 = undefined;
        var terminated = false;

        var reads_pc = (insn.rn == 15 or insn.rm == 15 or (!insn.i and insn.shift_reg and insn.rs == 15));
        if (insn.type == .ldr or insn.type == .str) reads_pc = (insn.rn == 15);
        if (insn.type == .mov or insn.type == .mvn or insn.type == .add or insn.type == .sub) {
            if (!insn.i and insn.rm == 15) reads_pc = true;
            if (insn.rn == 15) reads_pc = true;
        }
        if (reads_pc) {
            try self.line("rt.r[15] = 0x{X:0>8};", .{addr +% 8});
        }

        const is_uncond = (insn.cond == .al);

        switch (insn.type) {
            .mov => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                try self.line("{s} = {s};", .{ regZ(insn.rd), op2 });
                if (insn.s and insn.rd != 15) {
                    try self.line("rt.updateNz({s});", .{regZ(insn.rd)});
                }
                if (insn.rd == 15 and std.mem.eql(u8, op2, "rt.r[14]")) {
                    try self.line("rt.recompReturn(rt.r[14]); return;", .{});
                    if (is_uncond) terminated = true;
                } else if (insn.rd == 15) {
                    try self.line("decls.awre_cpu_bx(rt.r[15] & ~@as(u32, 3)); return;", .{});
                    if (is_uncond) terminated = true;
                }
                try self.endCond(co);
            },
            .mvn => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                try self.line("{s} = ~@as(u32, {s});", .{ regZ(insn.rd), op2 });
                if (insn.s and insn.rd != 15) try self.line("rt.updateNz({s});", .{regZ(insn.rd)});
                try self.endCond(co);
            },
            .and_op => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                try self.line("{s} = {s} & {s};", .{ regZ(insn.rd), regZ(insn.rn), op2 });
                if (insn.s) try self.line("rt.updateNz({s});", .{regZ(insn.rd)});
                try self.endCond(co);
            },
            .orr => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                try self.line("{s} = {s} | {s};", .{ regZ(insn.rd), regZ(insn.rn), op2 });
                if (insn.s) try self.line("rt.updateNz({s});", .{regZ(insn.rd)});
                try self.endCond(co);
            },
            .eor => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                try self.line("{s} = {s} ^ {s};", .{ regZ(insn.rd), regZ(insn.rn), op2 });
                if (insn.s) try self.line("rt.updateNz({s});", .{regZ(insn.rd)});
                try self.endCond(co);
            },
            .bic => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                try self.line("{s} = {s} & ~@as(u32, {s});", .{ regZ(insn.rd), regZ(insn.rn), op2 });
                if (insn.s) try self.line("rt.updateNz({s});", .{regZ(insn.rd)});
                try self.endCond(co);
            },
            .add => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                if (insn.s and insn.rd != 15) {
                    try self.line("rt.cpuAdd(&{s}, {s}, {s}, true);", .{ regZ(insn.rd), regZ(insn.rn), op2 });
                } else {
                    try self.line("{s} = {s} +% {s};", .{ regZ(insn.rd), regZ(insn.rn), op2 });
                }
                try self.endCond(co);
            },
            .adc => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                try self.line("rt.cpuAdc(&{s}, {s}, {s}, {});", .{ regZ(insn.rd), regZ(insn.rn), op2, insn.s });
                try self.endCond(co);
            },
            .sub => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                if (insn.s and insn.rd != 15) {
                    try self.line("rt.cpuSub(&{s}, {s}, {s}, true);", .{ regZ(insn.rd), regZ(insn.rn), op2 });
                } else {
                    try self.line("{s} = {s} -% {s};", .{ regZ(insn.rd), regZ(insn.rn), op2 });
                }
                try self.endCond(co);
            },
            .rsb => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                if (insn.s and insn.rd != 15) {
                    try self.line("rt.cpuSub(&{s}, {s}, {s}, true);", .{ regZ(insn.rd), op2, regZ(insn.rn) });
                } else {
                    try self.line("{s} = {s} -% {s};", .{ regZ(insn.rd), op2, regZ(insn.rn) });
                }
                try self.endCond(co);
            },
            .sbc => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                try self.line("rt.cpuSbc(&{s}, {s}, {s}, {});", .{ regZ(insn.rd), regZ(insn.rn), op2, insn.s });
                try self.endCond(co);
            },
            .rsc => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                try self.line("rt.cpuSbc(&{s}, {s}, {s}, {});", .{ regZ(insn.rd), op2, regZ(insn.rn), insn.s });
                try self.endCond(co);
            },
            .cmp => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                try self.line("rt.cpuSub(null, {s}, {s}, true);", .{ regZ(insn.rn), op2 });
                try self.endCond(co);
            },
            .cmn => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                try self.line("rt.cpuAdd(null, {s}, {s}, true);", .{ regZ(insn.rn), op2 });
                try self.endCond(co);
            },
            .tst => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                try self.line("rt.updateNz({s} & {s});", .{ regZ(insn.rn), op2 });
                try self.endCond(co);
            },
            .teq => {
                const co = try self.beginCond(insn.cond);
                const op2 = operand2ToZig(insn, &op2_buf);
                try self.line("rt.updateNz({s} ^ {s});", .{ regZ(insn.rn), op2 });
                try self.endCond(co);
            },
            .mul => {
                const co = try self.beginCond(insn.cond);
                try self.line("{s} = {s} *% {s};", .{ regZ(insn.rd), regZ(insn.rm), regZ(insn.rs) });
                if (insn.s) try self.line("rt.updateNz({s});", .{regZ(insn.rd)});
                try self.endCond(co);
            },
            .mla => {
                const co = try self.beginCond(insn.cond);
                try self.line("{s} = {s} *% {s} +% {s};", .{ regZ(insn.rd), regZ(insn.rm), regZ(insn.rs), regZ(insn.rn) });
                if (insn.s) try self.line("rt.updateNz({s});", .{regZ(insn.rd)});
                try self.endCond(co);
            },
            .umull => {
                const co = try self.beginCond(insn.cond);
                try self.line("{{", .{});
                self.indent += 1;
                try self.line("const _res: u64 = @as(u64, {s}) *% @as(u64, {s});", .{ regZ(insn.rm), regZ(insn.rs) });
                try self.line("{s} = @truncate(_res);", .{regZ(insn.rd)});
                try self.line("{s} = @truncate(_res >> 32);", .{regZ(insn.rn)});
                self.indent -= 1;
                try self.line("}}", .{});
                try self.endCond(co);
            },
            .smull => {
                const co = try self.beginCond(insn.cond);
                try self.line("{{", .{});
                self.indent += 1;
                try self.line("const _s: i64 = @as(i64, @as(i32, @bitCast({s}))) *% @as(i64, @as(i32, @bitCast({s})));", .{ regZ(insn.rm), regZ(insn.rs) });
                try self.line("const _res: u64 = @bitCast(_s);", .{});
                try self.line("{s} = @truncate(_res);", .{regZ(insn.rd)});
                try self.line("{s} = @truncate(_res >> 32);", .{regZ(insn.rn)});
                self.indent -= 1;
                try self.line("}}", .{});
                try self.endCond(co);
            },
            .umlal => {
                const co = try self.beginCond(insn.cond);
                try self.line("{{", .{});
                self.indent += 1;
                try self.line("const _acc: u64 = (@as(u64, {s}) << 32) | {s};", .{ regZ(insn.rn), regZ(insn.rd) });
                try self.line("const _res: u64 = _acc +% @as(u64, {s}) *% @as(u64, {s});", .{ regZ(insn.rm), regZ(insn.rs) });
                try self.line("{s} = @truncate(_res);", .{regZ(insn.rd)});
                try self.line("{s} = @truncate(_res >> 32);", .{regZ(insn.rn)});
                self.indent -= 1;
                try self.line("}}", .{});
                try self.endCond(co);
            },
            .smlal => {
                const co = try self.beginCond(insn.cond);
                try self.line("{{", .{});
                self.indent += 1;
                try self.line("const _acc: i64 = (@as(i64, @as(i32, @bitCast({s}))) << 32) | @as(u64, {s});", .{ regZ(insn.rn), regZ(insn.rd) });
                try self.line("const _s: i64 = _acc +% @as(i64, @as(i32, @bitCast({s}))) *% @as(i64, @as(i32, @bitCast({s})));", .{ regZ(insn.rm), regZ(insn.rs) });
                try self.line("const _res: u64 = @bitCast(_s);", .{});
                try self.line("{s} = @truncate(_res);", .{regZ(insn.rd)});
                try self.line("{s} = @truncate(_res >> 32);", .{regZ(insn.rn)});
                self.indent -= 1;
                try self.line("}}", .{});
                try self.endCond(co);
            },
            .b => {
                const target = addr +% 8 +% @as(u32, @bitCast(insn.branch_offset));
                if (is_uncond) {
                    try self.emitBranchTarget(target);
                    terminated = true;
                } else {
                    const co = try self.beginCond(insn.cond);
                    try self.emitBranchTarget(target);
                    try self.endCond(co);
                }
            },
            .bl => {
                const target = addr +% 8 +% @as(u32, @bitCast(insn.branch_offset));
                const co = try self.beginCond(insn.cond);
                try self.line("rt.r[14] = 0x{X:0>8};", .{addr +% 4});
                try self.line("rt.g_ret = 0; {s};", .{self.formatCall(target, &call_buf)});
                try self.emitCalled(addr +% 4);
                try self.endCond(co);
            },
            .bx => {
                const co = try self.beginCond(insn.cond);
                if (insn.rm == 14) {
                    try self.line("rt.recompReturn(rt.r[14]); return;", .{});
                    if (is_uncond) terminated = true;
                } else if (addr >= 4 and self.rom.read32(addr - 4) == 0xE1A0_E00F) {
                    try self.line("rt.g_ret = 0; decls.awre_cpu_bx({s});", .{regZ(insn.rm)});
                    try self.emitCalled(addr +% 4);
                } else {
                    try self.line("decls.awre_cpu_bx({s}); return;", .{regZ(insn.rm)});
                    if (is_uncond) terminated = true;
                }
                try self.endCond(co);
            },
            .ldr => {
                const co = try self.beginCond(insn.cond);
                const fn_name: []const u8 = if (insn.b) "bus_read8" else "bus_read32";
                const sign: []const u8 = if (insn.u) "+%" else "-%";
                if (insn.p) {
                    if (!insn.i) {
                        try self.line("{s} = rt.{s}({s} {s} 0x{X});", .{ regZ(insn.rd), fn_name, regZ(insn.rn), sign, insn.imm });
                    } else {
                        const op2 = operand2ToZig(insn, &op2_buf);
                        try self.line("{s} = rt.{s}({s} {s} {s});", .{ regZ(insn.rd), fn_name, regZ(insn.rn), sign, op2 });
                    }
                    if (insn.w) {
                        const wbop: []const u8 = if (insn.u) "+%=" else "-%=";
                        if (!insn.i) {
                            try self.line("{s} {s} 0x{X};", .{ regZ(insn.rn), wbop, insn.imm });
                        } else {
                            const op2 = operand2ToZig(insn, &op2_buf);
                            try self.line("{s} {s} {s};", .{ regZ(insn.rn), wbop, op2 });
                        }
                    }
                } else {
                    try self.line("{s} = rt.{s}({s});", .{ regZ(insn.rd), fn_name, regZ(insn.rn) });
                    const wbop: []const u8 = if (insn.u) "+%=" else "-%=";
                    if (!insn.i) {
                        try self.line("{s} {s} 0x{X};", .{ regZ(insn.rn), wbop, insn.imm });
                    } else {
                        const op2 = operand2ToZig(insn, &op2_buf);
                        try self.line("{s} {s} {s};", .{ regZ(insn.rn), wbop, op2 });
                    }
                }
                try self.endCond(co);
            },
            .str => {
                const co = try self.beginCond(insn.cond);
                const sign: []const u8 = if (insn.u) "+%" else "-%";
                var val_buf: [32]u8 = undefined;
                const val_expr = if (insn.b)
                    std.fmt.bufPrint(&val_buf, "@truncate({s})", .{regZ(insn.rd)}) catch unreachable
                else
                    regZ(insn.rd);
                const fn_name: []const u8 = if (insn.b) "bus_write8" else "bus_write32";
                if (insn.p) {
                    if (!insn.i) {
                        try self.line("rt.{s}({s} {s} 0x{X}, {s});", .{ fn_name, regZ(insn.rn), sign, insn.imm, val_expr });
                    } else {
                        const op2 = operand2ToZig(insn, &op2_buf);
                        try self.line("rt.{s}({s} {s} {s}, {s});", .{ fn_name, regZ(insn.rn), sign, op2, val_expr });
                    }
                    if (insn.w and !insn.i) {
                        const wbop: []const u8 = if (insn.u) "+%=" else "-%=";
                        try self.line("{s} {s} 0x{X};", .{ regZ(insn.rn), wbop, insn.imm });
                    }
                } else {
                    try self.line("rt.{s}({s}, {s});", .{ fn_name, regZ(insn.rn), val_expr });
                    if (!insn.i) {
                        const wbop: []const u8 = if (insn.u) "+%=" else "-%=";
                        try self.line("{s} {s} 0x{X};", .{ regZ(insn.rn), wbop, insn.imm });
                    }
                }
                try self.endCond(co);
            },
            .ldrh, .ldrsh, .ldrsb => {
                const co = try self.beginCond(insn.cond);
                const sign: []const u8 = if (insn.u) "+%" else "-%";
                var addr_buf: [64]u8 = undefined;
                const aexpr = if (insn.i)
                    std.fmt.bufPrint(&addr_buf, "{s} {s} 0x{X}", .{ regZ(insn.rn), sign, insn.imm }) catch unreachable
                else
                    std.fmt.bufPrint(&addr_buf, "{s} {s} {s}", .{ regZ(insn.rn), sign, regZ(insn.rm) }) catch unreachable;
                switch (insn.type) {
                    .ldrh => try self.line("{s} = rt.bus_read16({s});", .{ regZ(insn.rd), aexpr }),
                    .ldrsh => try self.line("{s} = rt.sext16(rt.bus_read16({s}));", .{ regZ(insn.rd), aexpr }),
                    .ldrsb => try self.line("{s} = rt.sext8(rt.bus_read8({s}));", .{ regZ(insn.rd), aexpr }),
                    else => unreachable,
                }
                try self.endCond(co);
            },
            .strh => {
                const co = try self.beginCond(insn.cond);
                const sign: []const u8 = if (insn.u) "+%" else "-%";
                if (insn.i) {
                    try self.line("rt.bus_write16({s} {s} 0x{X}, @truncate({s}));", .{ regZ(insn.rn), sign, insn.imm, regZ(insn.rd) });
                } else {
                    try self.line("rt.bus_write16({s} {s} {s}, @truncate({s}));", .{ regZ(insn.rn), sign, regZ(insn.rm), regZ(insn.rd) });
                }
                try self.endCond(co);
            },
            .ldm, .stm => {
                const co = try self.beginCond(insn.cond);
                try self.line("{{", .{});
                self.indent += 1;
                const n: i32 = @intCast(@popCount(insn.reg_list));
                const start_off: i32 = if (insn.u) (if (insn.p) 4 else 0) else (if (insn.p) -4 * n else -4 * n + 4);
                const start_u: u32 = @bitCast(start_off);
                const loads_rn = (insn.type == .ldm) and ((insn.reg_list & (@as(u16, 1) << insn.rn)) != 0);
                const addr_qual: []const u8 = if (insn.reg_list != 0) "var" else "const";
                try self.line("{s} _addr: u32 = {s} +% 0x{X};", .{ addr_qual, regZ(insn.rn), start_u });
                if (insn.w and !loads_rn) {
                    const delta_u: u32 = @bitCast(if (insn.u) 4 * n else -4 * n);
                    try self.line("{s} +%= 0x{X};", .{ regZ(insn.rn), delta_u });
                }
                var rd32: []const u8 = "bus_read32";
                for (0..16) |ri| {
                    if ((insn.reg_list & (@as(u16, 1) << @intCast(ri))) == 0) continue;
                    if (insn.type == .ldm) {
                        try self.line("rt.r[{d}] = rt.{s}(_addr); _addr +%= 4;", .{ ri, rd32 });
                        rd32 = "bus_read32s";
                    } else {
                        try self.line("rt.bus_write32(_addr, rt.r[{d}]); _addr +%= 4;", .{ri});
                    }
                }
                if (insn.type == .ldm and (insn.reg_list & (@as(u16, 1) << 15)) != 0) {
                    try self.line("rt.recompReturn(rt.r[15]); return;", .{});
                    if (is_uncond) terminated = true;
                }
                self.indent -= 1;
                try self.line("}}", .{});
                try self.endCond(co);
            },
            .mrs => {
                const co = try self.beginCond(insn.cond);
                const src_fn: []const u8 = if (insn.r) "cpu_get_spsr" else "cpu_get_cpsr";
                try self.line("{s} = rt.{s}();", .{ regZ(insn.rd), src_fn });
                try self.endCond(co);
            },
            .msr => {
                const co = try self.beginCond(insn.cond);
                const dst_fn: []const u8 = if (insn.r) "cpu_set_spsr" else "cpu_set_cpsr";
                if (insn.i) {
                    try self.line("rt.{s}(0x{X}, 0x{X});", .{ dst_fn, insn.imm, insn.msr_mask });
                } else {
                    try self.line("rt.{s}({s}, 0x{X});", .{ dst_fn, regZ(insn.rm), insn.msr_mask });
                }
                try self.endCond(co);
            },
            .swp => {
                const co = try self.beginCond(insn.cond);
                try self.line("{{ const _tmp = rt.bus_read32({s}); rt.bus_write32({s}, {s}); {s} = _tmp; }}", .{
                    regZ(insn.rn),
                    regZ(insn.rn),
                    regZ(insn.rm),
                    regZ(insn.rd),
                });
                try self.endCond(co);
            },
            .swpb => {
                const co = try self.beginCond(insn.cond);
                try self.line("{{ const _tmp: u32 = rt.bus_read8({s}); rt.bus_write8({s}, @truncate({s})); {s} = _tmp; }}", .{
                    regZ(insn.rn),
                    regZ(insn.rn),
                    regZ(insn.rm),
                    regZ(insn.rd),
                });
                try self.endCond(co);
            },
            .swi => {
                const co = try self.beginCond(insn.cond);
                try self.line("rt.gba_swi(0x{X});", .{insn.swi_number});
                try self.endCond(co);
            },
            .undefined => {
                try self.line("rt.cpu_undefined(0x{X:0>8});", .{insn.raw});
            },
        }
        return terminated;
    }

    fn translateThumbInsn(self: *Emitter, insn: *const ThumbInsn, addr: u32) !bool {
        var call_buf: [64]u8 = undefined;
        var terminated = false;

        switch (insn.type) {
            .move_shifted => {
                switch (insn.shift_type) {
                    .lsl => if (insn.shift_amount == 0) {
                        try self.line("{s} = {s};", .{ regZ(insn.rd), regZ(insn.rs) });
                    } else {
                        try self.line("{s} = {s} << {d};", .{ regZ(insn.rd), regZ(insn.rs), insn.shift_amount });
                    },
                    .lsr => if (insn.shift_amount == 0) {
                        try self.line("{s} = 0;", .{regZ(insn.rd)});
                    } else {
                        try self.line("{s} = {s} >> {d};", .{ regZ(insn.rd), regZ(insn.rs), insn.shift_amount });
                    },
                    .asr => if (insn.shift_amount == 0) {
                        try self.line("{s} = rt.asrConst({s}, 31);", .{ regZ(insn.rd), regZ(insn.rs) });
                    } else {
                        try self.line("{s} = rt.asrConst({s}, {d});", .{ regZ(insn.rd), regZ(insn.rs), insn.shift_amount });
                    },
                    .ror => try self.line("{s} = {s};", .{ regZ(insn.rd), regZ(insn.rs) }),
                }
                try self.line("rt.updateNz({s});", .{regZ(insn.rd)});
            },
            .add_sub => {
                const op_fn: []const u8 = if (insn.is_subtract) "cpuSub" else "cpuAdd";
                if (insn.is_imm) {
                    try self.line("rt.{s}(&{s}, {s}, 0x{X}, true);", .{ op_fn, regZ(insn.rd), regZ(insn.rs), insn.imm });
                } else {
                    try self.line("rt.{s}(&{s}, {s}, {s}, true);", .{ op_fn, regZ(insn.rd), regZ(insn.rs), regZ(insn.rm) });
                }
            },
            .mov_cmp_add_sub_imm => switch (@intFromEnum(insn.hi_op)) {
                0 => {
                    try self.line("{s} = 0x{X}; rt.updateNz({s});", .{ regZ(insn.rd), insn.imm, regZ(insn.rd) });
                },
                1 => try self.line("rt.cpuSub(null, {s}, 0x{X}, true);", .{ regZ(insn.rd), insn.imm }),
                2 => try self.line("rt.cpuAdd(&{s}, {s}, 0x{X}, true);", .{ regZ(insn.rd), regZ(insn.rd), insn.imm }),
                3 => try self.line("rt.cpuSub(&{s}, {s}, 0x{X}, true);", .{ regZ(insn.rd), regZ(insn.rd), insn.imm }),
            },
            .alu_ops => switch (insn.alu_op) {
                .and_op => try self.line("{s} &= {s}; rt.updateNz({s});", .{ regZ(insn.rd), regZ(insn.rs), regZ(insn.rd) }),
                .eor => try self.line("{s} ^= {s}; rt.updateNz({s});", .{ regZ(insn.rd), regZ(insn.rs), regZ(insn.rd) }),
                .orr => try self.line("{s} |= {s}; rt.updateNz({s});", .{ regZ(insn.rd), regZ(insn.rs), regZ(insn.rd) }),
                .bic => try self.line("{s} &= ~{s}; rt.updateNz({s});", .{ regZ(insn.rd), regZ(insn.rs), regZ(insn.rd) }),
                .mvn => try self.line("{s} = ~{s}; rt.updateNz({s});", .{ regZ(insn.rd), regZ(insn.rs), regZ(insn.rd) }),
                .neg => try self.line("rt.cpuSub(&{s}, 0, {s}, true);", .{ regZ(insn.rd), regZ(insn.rs) }),
                .cmp => try self.line("rt.cpuSub(null, {s}, {s}, true);", .{ regZ(insn.rd), regZ(insn.rs) }),
                .cmn => try self.line("rt.cpuAdd(null, {s}, {s}, true);", .{ regZ(insn.rd), regZ(insn.rs) }),
                .tst => try self.line("rt.updateNz({s} & {s});", .{ regZ(insn.rd), regZ(insn.rs) }),
                .lsl => try self.line("{s} = rt.armLsl({s}, {s} & 0xFF); rt.updateNz({s});", .{ regZ(insn.rd), regZ(insn.rd), regZ(insn.rs), regZ(insn.rd) }),
                .lsr => try self.line("{s} = rt.armLsr({s}, {s} & 0xFF); rt.updateNz({s});", .{ regZ(insn.rd), regZ(insn.rd), regZ(insn.rs), regZ(insn.rd) }),
                .asr => try self.line("{s} = rt.armAsr({s}, {s} & 0xFF); rt.updateNz({s});", .{ regZ(insn.rd), regZ(insn.rd), regZ(insn.rs), regZ(insn.rd) }),
                .ror => try self.line("{s} = rt.ror32({s}, {s} & 0xFF); rt.updateNz({s});", .{ regZ(insn.rd), regZ(insn.rd), regZ(insn.rs), regZ(insn.rd) }),
                .adc => try self.line("rt.cpuAdc(&{s}, {s}, {s}, true);", .{ regZ(insn.rd), regZ(insn.rd), regZ(insn.rs) }),
                .sbc => try self.line("rt.cpuSbc(&{s}, {s}, {s}, true);", .{ regZ(insn.rd), regZ(insn.rd), regZ(insn.rs) }),
                .mul => try self.line("{s} *%= {s}; rt.updateNz({s});", .{ regZ(insn.rd), regZ(insn.rs), regZ(insn.rd) }),
            },
            .hi_reg_ops => switch (insn.hi_op) {
                .add => if (insn.rd == 15) {
                    try self.line("decls.awre_cpu_bx((0x{X:0>8} +% {s}) | 1); return;", .{ addr +% 4, regZ(insn.rs) });
                    terminated = true;
                } else {
                    try self.line("{s} +%= {s};", .{ regZ(insn.rd), regZ(insn.rs) });
                },
                .cmp => try self.line("rt.cpuSub(null, {s}, {s}, true);", .{ regZ(insn.rd), regZ(insn.rs) }),
                .mov => if (insn.rd == 15) {
                    if (insn.rs == 14) {
                        try self.line("rt.recompReturn(rt.r[14]); return;", .{});
                        terminated = true;
                    } else {
                        if (self.jts_by_branch.get(addr)) |ti| {
                            const jt = &self.analysis.jump_tables.items[ti];
                            try self.line("switch ({s} & ~@as(u32, 1)) {{", .{regZ(insn.rs)});
                            self.indent += 1;
                            for (jt.targets.items, 0..) |tgt, i| {
                                var dup = false;
                                for (0..i) |k| {
                                    if (jt.targets.items[k] == tgt) {
                                        dup = true;
                                        break;
                                    }
                                }
                                if (!dup) {
                                    if (self.local_prongs.get(tgt)) |tgt_idx| {
                                        try self.line("0x{X:0>8} => continue :blk {d},", .{ tgt, tgt_idx });
                                    } else if (self.blocks_by_start.get(tgt)) |bi| {
                                        const owner = self.effective_owners[bi];
                                        if (owner != 0) {
                                            var ebuf: [80]u8 = undefined;
                                            try self.line("0x{X:0>8} => {{ {s}; return; }},", .{ tgt, self.formatEnter(owner, tgt, &ebuf) });
                                        }
                                    }
                                }
                            }
                            try self.line("else => {{}},", .{});
                            self.indent -= 1;
                            try self.line("}}", .{});
                        }
                        try self.line("decls.awre_cpu_bx({s} | 1); return;", .{regZ(insn.rs)});
                        terminated = true;
                    }
                } else {
                    try self.line("{s} = {s};", .{ regZ(insn.rd), regZ(insn.rs) });
                },
                .bx => {},
            },
            .bx => {
                if (insn.rs == 14) {
                    try self.line("rt.recompReturn(rt.r[14]); return;", .{});
                    terminated = true;
                } else if (insn.rs == 15) {
                    const target = (addr +% 4) & ~@as(u32, 3);
                    try self.line("{s}; return;", .{self.formatCall(target, &call_buf)});
                    terminated = true;
                } else {
                    var is_pop_bx_return = false;
                    if (addr >= 2 and self.analysis.getType(addr - 2) == .thumb) {
                        const prev_raw = self.rom.read16(addr - 2);
                        if ((prev_raw & 0xFF00) == 0xBC00 and (prev_raw & 0xFF) == (@as(u16, 1) << insn.rs)) {
                            is_pop_bx_return = true;
                        }
                    }
                    if (is_pop_bx_return) {
                        try self.line("rt.r[15] = {s}; rt.recompReturn({s}); return;", .{ regZ(insn.rs), regZ(insn.rs) });
                        terminated = true;
                    } else if (addr >= 2 and self.rom.read16(addr - 2) == 0x46FE) {
                        try self.line("rt.g_ret = 0; decls.awre_cpu_bx({s});", .{regZ(insn.rs)});
                        try self.emitCalled(addr +% 2);
                    } else {
                        try self.line("decls.awre_cpu_bx({s}); return;", .{regZ(insn.rs)});
                        terminated = true;
                    }
                }
            },
            .pc_rel_load => {
                const base = (addr +% 4) & ~@as(u32, 3);
                const pool_addr = base +% insn.imm;
                try self.line("{s} = rt.bus_read32(0x{X:0>8});", .{ regZ(insn.rd), pool_addr });
            },
            .load_store_reg => if (insn.is_load) {
                const fn_name: []const u8 = if (insn.is_byte) "bus_read8" else "bus_read32";
                try self.line("{s} = rt.{s}({s} +% {s});", .{ regZ(insn.rd), fn_name, regZ(insn.rs), regZ(insn.rm) });
            } else if (insn.is_byte) {
                try self.line("rt.bus_write8({s} +% {s}, @truncate({s}));", .{ regZ(insn.rs), regZ(insn.rm), regZ(insn.rd) });
            } else {
                try self.line("rt.bus_write32({s} +% {s}, {s});", .{ regZ(insn.rs), regZ(insn.rm), regZ(insn.rd) });
            },
            .load_store_sign => if (!insn.is_load) {
                try self.line("rt.bus_write16({s} +% {s}, @truncate({s}));", .{ regZ(insn.rs), regZ(insn.rm), regZ(insn.rd) });
            } else if (insn.is_half and !insn.is_signed) {
                try self.line("{s} = rt.bus_read16({s} +% {s});", .{ regZ(insn.rd), regZ(insn.rs), regZ(insn.rm) });
            } else if (insn.is_byte and insn.is_signed) {
                try self.line("{s} = rt.sext8(rt.bus_read8({s} +% {s}));", .{ regZ(insn.rd), regZ(insn.rs), regZ(insn.rm) });
            } else {
                try self.line("{s} = rt.sext16(rt.bus_read16({s} +% {s}));", .{ regZ(insn.rd), regZ(insn.rs), regZ(insn.rm) });
            },
            .load_store_imm => if (insn.is_load) {
                const fn_name: []const u8 = if (insn.is_byte) "bus_read8" else "bus_read32";
                try self.line("{s} = rt.{s}({s} +% 0x{X});", .{ regZ(insn.rd), fn_name, regZ(insn.rs), insn.imm });
            } else if (insn.is_byte) {
                try self.line("rt.bus_write8({s} +% 0x{X}, @truncate({s}));", .{ regZ(insn.rs), insn.imm, regZ(insn.rd) });
            } else {
                try self.line("rt.bus_write32({s} +% 0x{X}, {s});", .{ regZ(insn.rs), insn.imm, regZ(insn.rd) });
            },
            .load_store_half => if (insn.is_load) {
                try self.line("{s} = rt.bus_read16({s} +% 0x{X});", .{ regZ(insn.rd), regZ(insn.rs), insn.imm });
            } else {
                try self.line("rt.bus_write16({s} +% 0x{X}, @truncate({s}));", .{ regZ(insn.rs), insn.imm, regZ(insn.rd) });
            },
            .sp_rel_load_store => if (insn.is_load) {
                try self.line("{s} = rt.bus_read32(rt.r[13] +% 0x{X});", .{ regZ(insn.rd), insn.imm });
            } else {
                try self.line("rt.bus_write32(rt.r[13] +% 0x{X}, {s});", .{ insn.imm, regZ(insn.rd) });
            },
            .load_addr => if (insn.is_sp) {
                try self.line("{s} = rt.r[13] +% 0x{X};", .{ regZ(insn.rd), insn.imm });
            } else {
                const base = (addr +% 4) & ~@as(u32, 3);
                try self.line("{s} = 0x{X:0>8};", .{ regZ(insn.rd), base +% insn.imm });
            },
            .add_sp => if (insn.is_subtract) {
                try self.line("rt.r[13] -%= 0x{X};", .{insn.imm});
            } else {
                try self.line("rt.r[13] +%= 0x{X};", .{insn.imm});
            },
            .push_pop => {
                try self.line("{{", .{});
                self.indent += 1;
                if (insn.is_load) {
                    var rd32: []const u8 = "bus_read32";
                    for (0..8) |i| {
                        if ((insn.rlist & (@as(u8, 1) << @intCast(i))) != 0) {
                            try self.line("rt.r[{d}] = rt.{s}(rt.r[13]); rt.r[13] +%= 4;", .{ i, rd32 });
                            rd32 = "bus_read32s";
                        }
                    }
                    if (insn.pc_or_lr) {
                        try self.line("rt.r[15] = rt.{s}(rt.r[13]); rt.r[13] +%= 4;", .{rd32});
                        try self.line("rt.recompReturn(rt.r[15]); return;", .{});
                        terminated = true;
                    }
                } else {
                    if (insn.pc_or_lr) {
                        try self.line("rt.r[13] -%= 4; rt.bus_write32(rt.r[13], rt.r[14]);", .{});
                    }
                    var i: i32 = 7;
                    while (i >= 0) : (i -= 1) {
                        if ((insn.rlist & (@as(u8, 1) << @intCast(i))) != 0) {
                            try self.line("rt.r[13] -%= 4; rt.bus_write32(rt.r[13], rt.r[{d}]);", .{i});
                        }
                    }
                }
                self.indent -= 1;
                try self.line("}}", .{});
            },
            .multi_load_store => {
                try self.line("{{", .{});
                self.indent += 1;
                const addr_qual: []const u8 = if (insn.rlist != 0) "var" else "const";
                try self.line("{s} _addr: u32 = {s};", .{ addr_qual, regZ(insn.rs) });
                var rd32: []const u8 = "bus_read32";
                for (0..8) |i| {
                    if ((insn.rlist & (@as(u8, 1) << @intCast(i))) == 0) continue;
                    if (insn.is_load) {
                        try self.line("rt.r[{d}] = rt.{s}(_addr); _addr +%= 4;", .{ i, rd32 });
                        rd32 = "bus_read32s";
                    } else {
                        try self.line("rt.bus_write32(_addr, rt.r[{d}]); _addr +%= 4;", .{i});
                    }
                }
                try self.line("{s} = _addr;", .{regZ(insn.rs)});
                self.indent -= 1;
                try self.line("}}", .{});
            },
            .cond_branch => {
                const target = addr +% 4 +% @as(u32, @bitCast(insn.offset));
                if (condToZig(insn.cond)) |c| {
                    try self.line("if ({s}) {{", .{c});
                    self.indent += 1;
                    try self.emitBranchTarget(target);
                    self.indent -= 1;
                    try self.line("}}", .{});
                } else {
                    try self.emitBranchTarget(target);
                    terminated = true;
                }
            },
            .swi => try self.line("rt.gba_swi(0x{X:0>2});", .{insn.swi_num}),
            .branch => {
                const target = addr +% 4 +% @as(u32, @bitCast(insn.offset));
                try self.emitBranchTarget(target);
                terminated = true;
            },
            .long_branch => {},
            .undefined => try self.line("rt.cpu_undefined(0x{X:0>4});", .{insn.raw}),
        }
        return terminated;
    }

    fn emitSwitchBody(
        self: *Emitter,
        blocks: []const u32,
        initial_prong: ?u32,
    ) !usize {
        self.local_prongs.clearRetainingCapacity();
        for (blocks, 0..) |ba, idx| {
            try self.local_prongs.put(ba, @intCast(idx));
        }

        const switch_keyword_pos = self.buf.items.len + self.indent * 4;
        if (initial_prong) |init_idx| {
            try self.line("switch (@as(u32, {d})) {{", .{init_idx});
        } else {
            try self.line("switch (start_block) {{", .{});
        }
        self.indent += 1;

        var call_buf: [64]u8 = undefined;
        var enter_buf: [80]u8 = undefined;

        for (blocks, 0..) |block_addr, prong_idx| {
            const bi = self.blocks_by_start.get(block_addr) orelse continue;
            const block = self.analysis.blocks.items[bi];

            try self.line("{d} => {{", .{prong_idx});
            self.indent += 1;
            try self.line("rt.cpu_fetches({d});", .{((block.end - block.start) / 2) + 2});

            var terminated = false;
            if (block.mode == .arm) {
                var addr = block.start;
                while (addr < block.end) : (addr +%= 4) {
                    const insn = arm_mod.decode(self.rom.read32(addr));
                    terminated = try self.translateArmInsn(&insn, addr);
                    if (terminated) break;
                }
            } else {
                var addr = block.start;
                while (addr < block.end) {
                    const raw16 = self.rom.read16(addr);
                    const insn = thumb_mod.decode(raw16);
                    if (insn.type == .long_branch and !insn.is_suffix and addr + 2 < types.gba_rom_start + self.rom.data.len) {
                        const next_raw = self.rom.read16(addr + 2);
                        if (thumb_mod.isBlSuffix(next_raw)) {
                            const suffix = thumb_mod.decode(next_raw);
                            const bl_target = (addr +% 4) +% @as(u32, @bitCast(insn.offset)) +% suffix.imm;
                            try self.line("rt.r[14] = 0x{X:0>8};", .{(addr +% 4) | 1});
                            try self.line("rt.g_ret = 0; {s};", .{self.formatCall(bl_target, &call_buf)});
                            try self.emitCalled((addr +% 4) | 1);
                            addr += 4;
                            continue;
                        }
                    }
                    terminated = try self.translateThumbInsn(&insn, addr);
                    if (terminated) break;
                    addr += 2;
                }
            }

            if (!terminated) {
                var falls_through = false;
                for (0..block.num_successors) |s| {
                    if (block.successors[s] == block.end) falls_through = true;
                }
                if (falls_through) {
                    if (self.local_prongs.get(block.end)) |next_idx| {
                        try self.line("continue :blk {d};", .{next_idx});
                    } else {
                        var ends_in_call = false;
                        var into_prologue = false;
                        if (block.mode == .thumb and block.end >= 2) {
                            const last = self.rom.read16(block.end - 2);
                            ends_in_call = (last & 0xF800) == 0xF800 or (last & 0xFF00) == 0xDF00;
                            into_prologue = (self.rom.read16(block.end) & 0xFE00) == 0xB400;
                        } else if (block.mode == .arm and block.end >= 4) {
                            const last = self.rom.read32(block.end - 4);
                            ends_in_call = (last & 0x0F00_0000) == 0x0B00_0000 or (last & 0x0F00_0000) == 0x0F00_0000;
                            into_prologue = (self.rom.read32(block.end) & 0xFFFF_0000) == 0xE92D_0000;
                        }
                        const is_func_entry = if (self.target_to_shard.get(block.end)) |loc| loc.kind == .func else false;
                        if (self.blocks_by_start.get(block.end)) |next_bi| {
                            const next_owner = self.effective_owners[next_bi];
                            if (is_func_entry and into_prologue) {
                                if (!ends_in_call) {
                                    try self.line("{s}; return;", .{self.formatCall(block.end, &call_buf)});
                                }
                            } else if (next_owner != 0) {
                                try self.line("{s}; return;", .{self.formatEnter(next_owner, block.end, &enter_buf)});
                            } else if (into_prologue and !ends_in_call) {
                                try self.line("{s}; return;", .{self.formatCall(block.end, &call_buf)});
                            }
                        } else if (into_prologue and !ends_in_call) {
                            try self.line("{s}; return;", .{self.formatCall(block.end, &call_buf)});
                        }
                    }
                }
            }

            self.indent -= 1;
            try self.line("}},", .{});
        }

        try self.line("else => unreachable,", .{});
        self.indent -= 1;
        try self.line("}}", .{});
        if (std.mem.indexOf(u8, self.buf.items[switch_keyword_pos..], "continue :blk ") != null) {
            try self.buf.insertSlice(self.allocator, switch_keyword_pos, "blk: ");
        }
        return blocks.len;
    }
};

fn isSetjmp(rom: *const GbaRom, target_in: u32) bool {
    var target = target_in;
    if ((target & 1) == 0 and rom.read16(target) == 0x4778) {
        target = (target +% 4) & ~@as(u32, 3);
    }
    var w = rom.read32(target);
    if ((w & 0xFF00_0000) == 0xEA00_0000) {
        const off: i32 = @as(i32, @bitCast(w << 8)) >> 6;
        w = rom.read32(target +% 8 +% @as(u32, @bitCast(off)));
    }
    return (w & 0xFFFF_4000) == 0xE8A0_4000;
}

fn collectSortedExistingBlocks(
    allocator: std.mem.Allocator,
    raw_addrs: []const u32,
    blocks_by_start: *const std.AutoHashMap(u32, usize),
) ![]u32 {
    var list: std.ArrayList(u32) = .empty;
    errdefer list.deinit(allocator);
    for (raw_addrs) |ba| {
        if (blocks_by_start.contains(ba)) {
            try list.append(allocator, ba);
        }
    }
    std.mem.sort(u32, list.items, {}, std.sort.asc(u32));
    var write_i: usize = 0;
    for (list.items, 0..) |v, i| {
        if (i == 0 or v != list.items[write_i - 1]) {
            list.items[write_i] = v;
            write_i += 1;
        }
    }
    list.items.len = write_i;
    return list.toOwnedSlice(allocator);
}

fn findSetjmpResume(
    rom: *const GbaRom,
    analysis: *const AnalysisCtx,
    sorted_blocks: []const u32,
    blocks_by_start: *const std.AutoHashMap(u32, usize),
) u32 {
    for (sorted_blocks) |bstart| {
        const bi = blocks_by_start.get(bstart) orelse continue;
        const bb = analysis.blocks.items[bi];
        if (bb.mode != .thumb or bb.end < bb.start + 2) continue;
        var a = bb.start;
        while (a < bb.end) : (a += 2) {
            if (a + 2 >= types.gba_rom_start + rom.data.len) break;
            const hi = rom.read16(a);
            const lo = rom.read16(a + 2);
            if ((hi & 0xF800) != 0xF000 or (lo & 0xF800) != 0xF800) continue;
            const off_hi: i32 = @as(i32, @bitCast(@as(u32, hi) << 21)) >> 9;
            const off_lo: u32 = @as(u32, lo & 0x07FF) << 1;
            const t = (a +% 4) +% @as(u32, @bitCast(off_hi)) +% off_lo;
            if (isSetjmp(rom, t)) return (a +% 4) | 1;
        }
    }
    return 0;
}

/// Unify every multi-block SCC in the block-level CFG under a single majority owner
/// (ties broken by smallest `owner_entry`) so every loop stays on `continue :blk`
/// and cross-owner `enter_*` calls form a finite DAG without block duplication.
fn unifyBlockSccOwners(
    allocator: std.mem.Allocator,
    analysis: *const AnalysisCtx,
    blocks_by_start: *const std.AutoHashMap(u32, usize),
    jts_by_branch: *const std.AutoHashMap(u32, usize),
) ![]u32 {
    const num_blocks = analysis.blocks.items.len;
    const effective_owners = try allocator.alloc(u32, num_blocks);
    errdefer allocator.free(effective_owners);
    for (analysis.blocks.items, 0..) |b, i| {
        effective_owners[i] = b.owner_entry;
    }
    if (num_blocks == 0) return effective_owners;

    // Build flat CSR outgoing adjacency list over 0..num_blocks
    const edge_start = try allocator.alloc(usize, num_blocks + 1);
    defer allocator.free(edge_start);
    var edges: std.ArrayList(usize) = .empty;
    defer edges.deinit(allocator);

    for (analysis.blocks.items, 0..) |blk, bi| {
        edge_start[bi] = edges.items.len;
        for (0..blk.num_successors) |s| {
            const tgt = blk.successors[s];
            if (tgt == 0) continue;
            if (blocks_by_start.get(tgt)) |ti| {
                try edges.append(allocator, ti);
            }
        }
        var a = blk.start;
        while (a < blk.end) : (a +%= 2) {
            if (jts_by_branch.get(a)) |jti| {
                for (analysis.jump_tables.items[jti].targets.items) |tgt| {
                    if (blocks_by_start.get(tgt)) |ti| {
                        try edges.append(allocator, ti);
                    }
                }
            }
        }
    }
    edge_start[num_blocks] = edges.items.len;

    // Iterative Tarjan's SCC over block indices
    const indices = try allocator.alloc(i32, num_blocks);
    defer allocator.free(indices);
    @memset(indices, -1);
    const low = try allocator.alloc(i32, num_blocks);
    defer allocator.free(low);
    const on_stack = try allocator.alloc(bool, num_blocks);
    defer allocator.free(on_stack);
    @memset(on_stack, false);

    var scc_stack: std.ArrayList(usize) = .empty;
    defer scc_stack.deinit(allocator);
    const Frame = struct { node: usize, edge_idx: usize };
    var call_stack: std.ArrayList(Frame) = .empty;
    defer call_stack.deinit(allocator);

    var owner_counts = std.AutoHashMap(u32, usize).init(allocator);
    defer owner_counts.deinit();

    var next_index: i32 = 0;
    for (0..num_blocks) |start| {
        if (indices[start] >= 0) continue;

        indices[start] = next_index;
        low[start] = next_index;
        next_index += 1;
        try scc_stack.append(allocator, start);
        on_stack[start] = true;
        try call_stack.append(allocator, .{ .node = start, .edge_idx = edge_start[start] });

        while (call_stack.items.len > 0) {
            const top = &call_stack.items[call_stack.items.len - 1];
            const v = top.node;
            const end_e = edge_start[v + 1];
            if (top.edge_idx < end_e) {
                const w = edges.items[top.edge_idx];
                top.edge_idx += 1;
                if (indices[w] < 0) {
                    indices[w] = next_index;
                    low[w] = next_index;
                    next_index += 1;
                    try scc_stack.append(allocator, w);
                    on_stack[w] = true;
                    try call_stack.append(allocator, .{ .node = w, .edge_idx = edge_start[w] });
                } else if (on_stack[w] and indices[w] < low[v]) {
                    low[v] = indices[w];
                }
            } else {
                call_stack.items.len -= 1;
                if (call_stack.items.len > 0) {
                    const p = call_stack.items[call_stack.items.len - 1].node;
                    if (low[v] < low[p]) low[p] = low[v];
                }
                if (low[v] == indices[v]) {
                    var comp_start = scc_stack.items.len;
                    while (true) {
                        comp_start -= 1;
                        const w = scc_stack.items[comp_start];
                        on_stack[w] = false;
                        if (w == v) break;
                    }
                    const comp = scc_stack.items[comp_start..];
                    if (comp.len > 1) {
                        owner_counts.clearRetainingCapacity();
                        for (comp) |bi| {
                            const o = effective_owners[bi];
                            if (o == 0) continue;
                            const gop = try owner_counts.getOrPut(o);
                            if (!gop.found_existing) gop.value_ptr.* = 0;
                            gop.value_ptr.* += 1;
                        }
                        var best_owner: u32 = 0;
                        var best_count: usize = 0;
                        var it = owner_counts.iterator();
                        while (it.next()) |kv| {
                            const o = kv.key_ptr.*;
                            const c = kv.value_ptr.*;
                            if (c > best_count or (c == best_count and (best_owner == 0 or o < best_owner))) {
                                best_owner = o;
                                best_count = c;
                            }
                        }
                        if (best_owner != 0) {
                            for (comp) |bi| {
                                effective_owners[bi] = best_owner;
                            }
                        }
                    }
                    scc_stack.items.len = comp_start;
                }
            }
        }
    }

    return effective_owners;
}

fn thumbBxVeneerReg(rom: *const GbaRom, addr: u32) ?u4 {
    const raw = rom.read16(addr);
    if ((raw & 0xFF87) != 0x4700) return null;
    const rs: u4 = @truncate((raw >> 3) & 0xF);
    return if (rs < 14) rs else null;
}

/// Emit sharded pure-Zig translation into `outdir` (`funcs_*.zig`, `stubs_*.zig`, `unresolved.zig`, `game.zig`).
pub fn translateToDir(
    allocator: std.mem.Allocator,
    io: std.Io,
    rom: *const GbaRom,
    analysis: *const AnalysisCtx,
    outdir: []const u8,
) !TranslateStats {
    var out_dir = try std.Io.Dir.cwd().createDirPathOpen(io, outdir, .{});
    defer out_dir.close(io);

    // Clean stale shards so shard-count adjustments never leave orphaned `.zig` files.
    {
        var iter_dir = try std.Io.Dir.cwd().openDir(io, outdir, .{ .iterate = true });
        defer iter_dir.close(io);
        var stale_files: std.ArrayList([]u8) = .empty;
        defer {
            for (stale_files.items) |name| allocator.free(name);
            stale_files.deinit(allocator);
        }
        var it = iter_dir.iterate();
        while (try it.next(io)) |entry| {
            if (entry.kind != .file) continue;
            if (!std.mem.endsWith(u8, entry.name, ".zig")) continue;
            if (std.mem.startsWith(u8, entry.name, "funcs_") or
                std.mem.startsWith(u8, entry.name, "stubs_"))
            {
                try stale_files.append(allocator, try allocator.dupe(u8, entry.name));
            }
        }
        for (stale_files.items) |name| {
            try out_dir.deleteFile(io, name);
        }
    }

    // Quick indices
    var blocks_by_start = std.AutoHashMap(u32, usize).init(allocator);
    defer blocks_by_start.deinit();
    for (analysis.blocks.items, 0..) |b, i| {
        const gop = try blocks_by_start.getOrPut(b.start);
        if (!gop.found_existing or (analysis.blocks.items[gop.value_ptr.*].owner_entry == 0 and b.owner_entry != 0)) {
            gop.value_ptr.* = i;
        }
    }

    var jts_by_branch = std.AutoHashMap(u32, usize).init(allocator);
    defer jts_by_branch.deinit();
    for (analysis.jump_tables.items, 0..) |jt, i| {
        try jts_by_branch.put(jt.branch_addr, i);
    }

    // Compute sorted block lists and setjmp self-contained functions
    const num_funcs = analysis.functions.items.len;
    const func_sorted_blocks = try allocator.alloc([]u32, num_funcs);
    defer {
        for (func_sorted_blocks) |s| allocator.free(s);
        allocator.free(func_sorted_blocks);
    }
    var setjmp_resumes = std.AutoHashMap(u32, u32).init(allocator);
    defer setjmp_resumes.deinit();
    var self_contained = std.AutoHashMap(u32, void).init(allocator);
    defer self_contained.deinit();

    for (analysis.functions.items, 0..) |f, i| {
        func_sorted_blocks[i] = try collectSortedExistingBlocks(allocator, f.block_addrs.items, &blocks_by_start);
        const sj = findSetjmpResume(rom, analysis, func_sorted_blocks[i], &blocks_by_start);
        if (sj != 0) {
            try setjmp_resumes.put(f.entry, sj);
            try self_contained.put(f.entry, {});
        }
    }

    // Unify every multi-block CFG SCC under a single majority owner so every loop
    // stays local on `continue :blk` and cross-owner `enter_*` calls form a DAG.
    const effective_owners = try unifyBlockSccOwners(allocator, analysis, &blocks_by_start, &jts_by_branch);
    defer allocator.free(effective_owners);

    var owner_blocks = std.AutoHashMap(u32, std.ArrayList(u32)).init(allocator);
    defer {
        var oit = owner_blocks.valueIterator();
        while (oit.next()) |l| l.deinit(allocator);
        owner_blocks.deinit();
    }
    for (analysis.blocks.items, 0..) |b, bi| {
        const owner = effective_owners[bi];
        if (owner == 0) continue;
        const gop = try owner_blocks.getOrPut(owner);
        if (!gop.found_existing) gop.value_ptr.* = .empty;
        try gop.value_ptr.append(allocator, b.start);
    }

    // Compute per-function prongs: `setjmp` functions keep union(all_blocks, owned_blocks)
    // so `longjmp` resumes stay local; all other functions emit only blocks with `effective_owner == f.entry`.
    const func_emit_blocks = try allocator.alloc([]u32, num_funcs);
    defer {
        for (func_emit_blocks) |s| allocator.free(s);
        allocator.free(func_emit_blocks);
    }

    var num_delegated_funcs: usize = 0;
    for (analysis.functions.items, 0..) |f, fi| {
        const owned = if (owner_blocks.getPtr(f.entry)) |l| l.items else &[_]u32{};
        if (self_contained.contains(f.entry)) {
            var merged: std.ArrayList(u32) = .empty;
            defer merged.deinit(allocator);
            try merged.appendSlice(allocator, func_sorted_blocks[fi]);
            try merged.appendSlice(allocator, owned);
            func_emit_blocks[fi] = try collectSortedExistingBlocks(allocator, merged.items, &blocks_by_start);
        } else {
            func_emit_blocks[fi] = try collectSortedExistingBlocks(allocator, owned, &blocks_by_start);
            if (func_emit_blocks[fi].len == 0 and func_sorted_blocks[fi].len > 0) {
                num_delegated_funcs += 1;
            }
        }
    }

    var func_idx_by_entry = std.AutoHashMap(u32, usize).init(allocator);
    defer func_idx_by_entry.deinit();
    for (analysis.functions.items, 0..) |f, fi| {
        try func_idx_by_entry.put(f.entry, fi);
    }

    // Weight-balanced LPT assignment across shards (avoids compiling-tail stragglers).
    const num_func_files: usize = if (num_funcs <= target_func_shards) 1 else target_func_shards;
    const func_weights = try allocator.alloc(u64, num_funcs);
    defer allocator.free(func_weights);
    const func_order = try allocator.alloc(usize, num_funcs);
    defer allocator.free(func_order);
    const func_to_shard = try allocator.alloc(usize, num_funcs);
    defer allocator.free(func_to_shard);

    for (0..num_funcs) |fi| {
        func_order[fi] = fi;
        var w: u64 = 4;
        const blocks_for_w = if (func_emit_blocks[fi].len > 0) func_emit_blocks[fi] else func_sorted_blocks[fi];
        for (blocks_for_w) |ba| {
            if (blocks_by_start.get(ba)) |bi| {
                const blk = analysis.blocks.items[bi];
                w +%= @as(u64, blk.end -% blk.start);
            }
        }
        func_weights[fi] = w;
    }

    const WeightSortCtx = struct {
        weights: []const u64,
        fn lessThan(ctx: @This(), a: usize, b: usize) bool {
            if (ctx.weights[a] != ctx.weights[b]) return ctx.weights[a] > ctx.weights[b];
            return a < b;
        }
    };
    std.mem.sort(usize, func_order, WeightSortCtx{ .weights = func_weights }, WeightSortCtx.lessThan);

    var shard_loads: [target_func_shards]u64 = @splat(0);
    const shard_funcs = try allocator.alloc(std.ArrayList(usize), num_func_files);
    defer {
        for (shard_funcs) |*sf| sf.deinit(allocator);
        allocator.free(shard_funcs);
    }
    for (shard_funcs) |*sf| sf.* = .empty;

    for (func_order) |fi| {
        var best_shard: usize = 0;
        var best_load = shard_loads[0];
        for (1..num_func_files) |si| {
            if (shard_loads[si] < best_load) {
                best_load = shard_loads[si];
                best_shard = si;
            }
        }
        func_to_shard[fi] = best_shard;
        shard_loads[best_shard] += func_weights[fi];
        try shard_funcs[best_shard].append(allocator, fi);
    }
    for (shard_funcs) |*sf| {
        std.mem.sort(usize, sf.items, {}, std.sort.asc(usize));
    }

    // Collect stub targets (missing branch targets + BL targets not in analysis.functions)
    var defined_set = std.AutoHashMap(u32, void).init(allocator);
    defer defined_set.deinit();
    var target_to_shard = std.AutoHashMap(u32, ShardLoc).init(allocator);
    defer target_to_shard.deinit();

    for (analysis.functions.items, 0..) |f, fi| {
        try defined_set.put(f.entry, {});
        try target_to_shard.put(f.entry, .{ .kind = .func, .shard_idx = func_to_shard[fi] });
    }

    var stubs_list: std.ArrayList(u32) = .empty;
    defer stubs_list.deinit(allocator);
    var stub_set = std.AutoHashMap(u32, void).init(allocator);
    defer stub_set.deinit();

    for (analysis.functions.items) |f| {
        var fblock_set = std.AutoHashMap(u32, void).init(allocator);
        defer fblock_set.deinit();
        for (f.block_addrs.items) |ba| try fblock_set.put(ba, {});

        for (f.block_addrs.items) |ba| {
            const bi = blocks_by_start.get(ba) orelse continue;
            const blk = analysis.blocks.items[bi];
            for (0..blk.num_successors) |s| {
                const t = blk.successors[s];
                if (t == 0 or fblock_set.contains(t) or defined_set.contains(t) or stub_set.contains(t)) continue;
                try stub_set.put(t, {});
                try stubs_list.append(allocator, t);
            }
        }
    }
    for (analysis.blocks.items) |blk| {
        if (blk.mode == .thumb and blk.end >= blk.start + 2) {
            var a = blk.start;
            while (a < blk.end) : (a += 2) {
                if (a + 2 >= types.gba_rom_start + rom.data.len) break;
                const raw = rom.read16(a);
                if (thumb_mod.isBlPrefix(raw)) {
                    const nxt = rom.read16(a + 2);
                    if (thumb_mod.isBlSuffix(nxt)) {
                        const p = thumb_mod.decode(raw);
                        const s = thumb_mod.decode(nxt);
                        const t = (a +% 4) +% @as(u32, @bitCast(p.offset)) +% s.imm;
                        if (!defined_set.contains(t) and !stub_set.contains(t)) {
                            try stub_set.put(t, {});
                            try stubs_list.append(allocator, t);
                        }
                        a += 2;
                    }
                }
            }
        } else if (blk.mode == .arm) {
            var a = blk.start;
            while (a < blk.end) : (a +%= 4) {
                const insn = arm_mod.decode(rom.read32(a));
                if (insn.type == .bl) {
                    const t = a +% 8 +% @as(u32, @bitCast(insn.branch_offset));
                    if (!defined_set.contains(t) and !stub_set.contains(t)) {
                        try stub_set.put(t, {});
                        try stubs_list.append(allocator, t);
                    }
                }
            }
        }
    }

    for (stubs_list.items, 0..) |st, si| {
        try defined_set.put(st, {});
        try target_to_shard.put(st, .{ .kind = .stub, .shard_idx = si / stubs_per_file });
    }

    // Collect any remaining unresolved targets referenced by fallthrough prologues, BX pc veneers, etc.
    var unres_list: std.ArrayList(u32) = .empty;
    defer unres_list.deinit(allocator);
    for (analysis.blocks.items) |blk| {
        var addr = blk.start;
        if (blk.mode == .thumb) {
            while (addr < blk.end) : (addr += 2) {
                const insn = thumb_mod.decode(rom.read16(addr));
                if (insn.type == .bx and insn.rs == 15) {
                    const t = (addr +% 4) & ~@as(u32, 3);
                    if (!defined_set.contains(t)) {
                        try defined_set.put(t, {});
                        try target_to_shard.put(t, .{ .kind = .unresolved, .shard_idx = 0 });
                        try unres_list.append(allocator, t);
                    }
                }
            }
            if (blk.end >= 2) {
                const last = rom.read16(blk.end - 2);
                const ends_in_call = (last & 0xF800) == 0xF800 or (last & 0xFF00) == 0xDF00;
                const into_prologue = (rom.read16(blk.end) & 0xFE00) == 0xB400;
                if (!ends_in_call and into_prologue and !defined_set.contains(blk.end)) {
                    try defined_set.put(blk.end, {});
                    try target_to_shard.put(blk.end, .{ .kind = .unresolved, .shard_idx = 0 });
                    try unres_list.append(allocator, blk.end);
                }
            }
        } else if (blk.mode == .arm and blk.end >= 4) {
            const last = rom.read32(blk.end - 4);
            const ends_in_call = (last & 0x0F00_0000) == 0x0B00_0000 or (last & 0x0F00_0000) == 0x0F00_0000;
            const into_prologue = (rom.read32(blk.end) & 0xFFFF_0000) == 0xE92D_0000;
            if (!ends_in_call and into_prologue and !defined_set.contains(blk.end)) {
                try defined_set.put(blk.end, {});
                try target_to_shard.put(blk.end, .{ .kind = .unresolved, .shard_idx = 0 });
                try unres_list.append(allocator, blk.end);
            }
        }
    }

    // Pre-scan which `enter_*` entrypoints actually need local or exported definitions.
    const needs_enter_local = try allocator.alloc(bool, num_funcs);
    defer allocator.free(needs_enter_local);
    @memset(needs_enter_local, false);
    const needs_enter_export = try allocator.alloc(bool, num_funcs);
    defer allocator.free(needs_enter_export);
    @memset(needs_enter_export, false);

    const EnterScan = struct {
        fn mark(
            f_idx_map: *const std.AutoHashMap(u32, usize),
            f_shard: []const usize,
            local_flags: []bool,
            export_flags: []bool,
            caller_is_func: bool,
            caller_shard: usize,
            owner: u32,
        ) void {
            const ofi = f_idx_map.get(owner) orelse return;
            local_flags[ofi] = true;
            if (!caller_is_func or f_shard[ofi] != caller_shard) {
                export_flags[ofi] = true;
            }
        }

        fn scanBranchTarget(
            rom_ref: *const GbaRom,
            target_shard_map: *const std.AutoHashMap(u32, ShardLoc),
            block_map: *const std.AutoHashMap(u32, usize),
            eff_owners: []const u32,
            f_idx_map: *const std.AutoHashMap(u32, usize),
            f_shard: []const usize,
            local_flags: []bool,
            export_flags: []bool,
            blocks_to_scan: []const u32,
            caller_shard: usize,
            t: u32,
        ) void {
            if (t == 0 or std.sort.binarySearch(u32, blocks_to_scan, t, orderU32) != null) return;
            const tbi = block_map.get(t) orelse return;
            const owner = eff_owners[tbi];
            if (owner == 0) return;
            const calls_func = if (target_shard_map.get(t)) |loc|
                loc.kind == .func and (owner == t or thumbBxVeneerReg(rom_ref, t) != null)
            else
                false;
            if (!calls_func) {
                mark(f_idx_map, f_shard, local_flags, export_flags, true, caller_shard, owner);
            }
        }
    };

    for (analysis.functions.items, 0..) |f, fi| {
        const caller_shard = func_to_shard[fi];
        const entry_owner = if (blocks_by_start.get(f.entry)) |ebi| effective_owners[ebi] else 0;
        if (!(f.mode == .thumb and thumbBxVeneerReg(rom, f.entry) != null) and
            !(self_contained.contains(f.entry) and func_emit_blocks[fi].len > 0) and
            entry_owner != 0 and entry_owner != f.entry)
        {
            EnterScan.mark(&func_idx_by_entry, func_to_shard, needs_enter_local, needs_enter_export, true, caller_shard, entry_owner);
        }

        const blocks_to_scan = if (func_emit_blocks[fi].len > 0) func_emit_blocks[fi] else func_sorted_blocks[fi];
        for (blocks_to_scan) |ba| {
            const bi = blocks_by_start.get(ba) orelse continue;
            const blk = analysis.blocks.items[bi];

            for (0..blk.num_successors) |s| {
                const t = blk.successors[s];
                if (t == 0) continue;
                if (std.sort.binarySearch(u32, blocks_to_scan, t, orderU32) != null) continue;
                if (t == blk.end) {
                    if (blocks_by_start.get(t)) |tbi| {
                        const owner = effective_owners[tbi];
                        if (owner != 0) {
                            const is_func_entry = if (target_to_shard.get(t)) |loc| loc.kind == .func else false;
                            const into_prologue = if (blk.mode == .thumb)
                                (rom.read16(blk.end) & 0xFE00) == 0xB400
                            else
                                (rom.read32(blk.end) & 0xFFFF_0000) == 0xE92D_0000;
                            if (!(is_func_entry and into_prologue and (owner == t or thumbBxVeneerReg(rom, t) != null))) {
                                EnterScan.mark(&func_idx_by_entry, func_to_shard, needs_enter_local, needs_enter_export, true, caller_shard, owner);
                            }
                        }
                    }
                } else {
                    EnterScan.scanBranchTarget(
                        rom,
                        &target_to_shard,
                        &blocks_by_start,
                        effective_owners,
                        &func_idx_by_entry,
                        func_to_shard,
                        needs_enter_local,
                        needs_enter_export,
                        blocks_to_scan,
                        caller_shard,
                        t,
                    );
                }
            }

            if (blk.mode == .arm) {
                var a = blk.start;
                while (a < blk.end) : (a +%= 4) {
                    const insn = arm_mod.decode(rom.read32(a));
                    if (insn.type == .b) {
                        const t = a +% 8 +% @as(u32, @bitCast(insn.branch_offset));
                        EnterScan.scanBranchTarget(
                            rom,
                            &target_to_shard,
                            &blocks_by_start,
                            effective_owners,
                            &func_idx_by_entry,
                            func_to_shard,
                            needs_enter_local,
                            needs_enter_export,
                            blocks_to_scan,
                            caller_shard,
                            t,
                        );
                    }
                }
            } else {
                var a = blk.start;
                while (a < blk.end) : (a += 2) {
                    const insn = thumb_mod.decode(rom.read16(a));
                    if (insn.type == .branch or insn.type == .cond_branch) {
                        const t = a +% 4 +% @as(u32, @bitCast(insn.offset));
                        EnterScan.scanBranchTarget(
                            rom,
                            &target_to_shard,
                            &blocks_by_start,
                            effective_owners,
                            &func_idx_by_entry,
                            func_to_shard,
                            needs_enter_local,
                            needs_enter_export,
                            blocks_to_scan,
                            caller_shard,
                            t,
                        );
                    }
                    if (jts_by_branch.get(a)) |jti| {
                        for (analysis.jump_tables.items[jti].targets.items) |tgt| {
                            if (std.sort.binarySearch(u32, blocks_to_scan, tgt, orderU32) != null) continue;
                            if (blocks_by_start.get(tgt)) |tbi| {
                                const owner = effective_owners[tbi];
                                if (owner != 0) {
                                    EnterScan.mark(&func_idx_by_entry, func_to_shard, needs_enter_local, needs_enter_export, true, caller_shard, owner);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    for (stubs_list.items) |addr| {
        if (blocks_by_start.get(addr)) |bi| {
            const owner = effective_owners[bi];
            if (owner != 0) {
                EnterScan.mark(&func_idx_by_entry, func_to_shard, needs_enter_local, needs_enter_export, false, 0, owner);
            }
        }
    }

    var local_prongs = std.AutoHashMap(u32, u32).init(allocator);
    defer local_prongs.deinit();

    var emitter: Emitter = .{
        .allocator = allocator,
        .rom = rom,
        .analysis = analysis,
        .buf = .empty,
        .local_prongs = &local_prongs,
        .effective_owners = effective_owners,
        .target_to_shard = &target_to_shard,
        .blocks_by_start = &blocks_by_start,
        .jts_by_branch = &jts_by_branch,
        .func_idx_by_entry = &func_idx_by_entry,
        .func_emit_blocks = func_emit_blocks,
    };
    defer emitter.buf.deinit(allocator);

    var num_prongs_emitted: usize = 0;

    // 1. Emit funcs_XXX.zig shards
    for (0..num_func_files) |file_idx| {
        emitter.buf.clearRetainingCapacity();
        emitter.current_kind = .func;
        emitter.current_shard = file_idx;
        emitter.indent = 0;

        try emitter.raw(
            \\// Auto-generated by gbarecomp-zig ({s}) - Part {d}/{d}
            \\const rt = @import("runtime");
            \\const decls = @import("decls");
            \\
            \\comptime {{
            \\    _ = rt;
            \\    _ = decls;
            \\}}
            \\
            \\
        , .{ rom.titleStr(), file_idx + 1, num_func_files });

        for (shard_funcs[file_idx].items) |fi| {
            const f = analysis.functions.items[fi];
            emitter.setjmp_resume = setjmp_resumes.get(f.entry) orelse 0;
            const emit_blocks = func_emit_blocks[fi];
            const all_blocks = func_sorted_blocks[fi];
            const entry_owner = if (blocks_by_start.get(f.entry)) |ebi|
                effective_owners[ebi]
            else
                0;
            const can_inline_body = !needs_enter_local[fi] and emit_blocks.len > 0 and
                (self_contained.contains(f.entry) or entry_owner == f.entry);

            try emitter.raw("pub export fn func_{X:0>8}() void {{\n", .{f.entry});
            emitter.indent = 1;
            try emitter.line("if (!rt.recompEnter(0x{X:0>8})) return;", .{f.entry});

            if (f.mode == .thumb and thumbBxVeneerReg(rom, f.entry) != null) {
                const rs = thumbBxVeneerReg(rom, f.entry).?;
                try emitter.line("rt.cpu_fetches(3);", .{});
                try emitter.line("decls.awre_cpu_bx(rt.r[{d}]);", .{rs});
            } else if (can_inline_body) {
                const entry_arg = if (emitter.blocks_by_start.contains(f.entry)) f.entry else emit_blocks[0];
                const entry_idx = emitter.lookupDenseIdx(f.entry, entry_arg) orelse 0;
                num_prongs_emitted += try emitter.emitSwitchBody(emit_blocks, entry_idx);
            } else if (self_contained.contains(f.entry) and emit_blocks.len > 0) {
                const entry_arg = if (emitter.blocks_by_start.contains(f.entry)) f.entry else emit_blocks[0];
                const entry_idx = emitter.lookupDenseIdx(f.entry, entry_arg) orelse 0;
                try emitter.line("enter_{X:0>8}({d});", .{ f.entry, entry_idx });
            } else if (entry_owner != 0) {
                var ebuf: [80]u8 = undefined;
                try emitter.line("{s};", .{emitter.formatEnter(entry_owner, f.entry, &ebuf)});
            } else if (all_blocks.len > 0) {
                num_prongs_emitted += try emitter.emitSwitchBody(all_blocks, 0);
            }

            emitter.indent = 0;
            try emitter.raw("}}\n\n", .{});

            if (emit_blocks.len > 0 and needs_enter_local[fi]) {
                const vis: []const u8 = if (needs_enter_export[fi]) "pub export " else "";
                try emitter.raw("{s}fn enter_{X:0>8}(start_block: u32) void {{\n", .{ vis, f.entry });
                emitter.indent = 1;
                num_prongs_emitted += try emitter.emitSwitchBody(emit_blocks, null);
                emitter.indent = 0;
                try emitter.raw("}}\n\n", .{});
            }
        }

        var fname_buf: [64]u8 = undefined;
        const fname = std.fmt.bufPrint(&fname_buf, "funcs_{d:0>3}.zig", .{file_idx}) catch unreachable;
        try out_dir.writeFile(io, .{ .sub_path = fname, .data = emitter.buf.items });
    }

    // 2. Emit stubs_XXX.zig shards
    const num_stub_files = @max(@as(usize, 1), (stubs_list.items.len + stubs_per_file - 1) / stubs_per_file);
    for (0..num_stub_files) |sf| {
        emitter.buf.clearRetainingCapacity();
        emitter.current_kind = .stub;
        emitter.current_shard = sf;
        emitter.setjmp_resume = 0;
        emitter.indent = 0;

        try emitter.raw(
            \\// Stub functions - part {d}/{d}
            \\const rt = @import("runtime");
            \\const decls = @import("decls");
            \\
            \\comptime {{
            \\    _ = rt;
            \\    _ = decls;
            \\}}
            \\
            \\
        , .{ sf + 1, num_stub_files });

        const s_start = sf * stubs_per_file;
        const s_end = @min(s_start + stubs_per_file, stubs_list.items.len);
        for (stubs_list.items[s_start..s_end]) |addr| {
            if (blocks_by_start.get(addr)) |bi| {
                const owner = effective_owners[bi];
                if (owner != 0) {
                    var ebuf: [80]u8 = undefined;
                    try emitter.raw("pub export fn func_{X:0>8}() void {{ {s}; }}\n", .{
                        addr,
                        emitter.formatEnter(owner, addr, &ebuf),
                    });
                    continue;
                }
            }
            try emitter.raw("pub export fn func_{X:0>8}() void {{}}\n", .{addr});
        }

        var sname_buf: [64]u8 = undefined;
        const sname = std.fmt.bufPrint(&sname_buf, "stubs_{d:0>3}.zig", .{sf}) catch unreachable;
        try out_dir.writeFile(io, .{ .sub_path = sname, .data = emitter.buf.items });
    }

    // 3. Emit unresolved.zig
    {
        emitter.buf.clearRetainingCapacity();
        try emitter.raw(
            \\// Unresolved branch/veneer trap stubs ({d} targets)
            \\const std = @import("std");
            \\
            \\
        , .{unres_list.items.len});
        for (unres_list.items) |addr| {
            try emitter.raw(
                \\pub export fn func_{X:0>8}() void {{
                \\    const S = struct {{ var warn: u32 = 0; }};
                \\    S.warn +%= 1;
                \\    if (S.warn <= 3) {{
                \\        std.debug.print("[unresolved] func_{X:0>8} called\n", .{{}});
                \\    }}
                \\}}
                \\
                \\
            , .{ addr, addr });
        }
        try out_dir.writeFile(io, .{ .sub_path = "unresolved.zig", .data = emitter.buf.items });
    }

    // 4. Emit decls.zig (external symbol forward declarations for parallel `.o` shards)
    {
        emitter.buf.clearRetainingCapacity();
        try emitter.raw(
            \\// Auto-generated external symbol declarations for parallel Zig shard compilation
            \\pub extern fn awre_cpu_bx(target: u32) void;
            \\
            \\// Functions ({d})
            \\
        , .{num_funcs});
        for (analysis.functions.items) |f| {
            try emitter.raw("pub extern fn func_{X:0>8}() void;\n", .{f.entry});
        }
        try emitter.raw("\n// Block entrypoints\n", .{});
        for (analysis.functions.items, 0..) |f, fi| {
            if (func_emit_blocks[fi].len > 0 and needs_enter_export[fi]) {
                try emitter.raw("pub extern fn enter_{X:0>8}(start_block: u32) void;\n", .{f.entry});
            }
        }
        try emitter.raw("\n// Stubs ({d})\n", .{stubs_list.items.len});
        for (stubs_list.items) |addr| {
            try emitter.raw("pub extern fn func_{X:0>8}() void;\n", .{addr});
        }
        try emitter.raw("\n// Unresolved ({d})\n", .{unres_list.items.len});
        for (unres_list.items) |addr| {
            try emitter.raw("pub extern fn func_{X:0>8}() void;\n", .{addr});
        }
        try out_dir.writeFile(io, .{ .sub_path = "decls.zig", .data = emitter.buf.items });
    }

    // 5. Emit game.zig root module with BX dispatch table
    {
        emitter.buf.clearRetainingCapacity();
        try emitter.raw(
            \\// Auto-generated by gbarecomp-zig - {s}
            \\const std = @import("std");
            \\const rt = @import("runtime");
            \\const decls = @import("decls");
            \\
            \\
        , .{rom.titleStr()});

        const entry_raw = rom.read32(types.gba_rom_start);
        const entry_insn = arm_mod.decode(entry_raw);
        const entry_target: u32 = if (entry_insn.type == .b)
            types.gba_rom_start +% 8 +% @as(u32, @bitCast(entry_insn.branch_offset))
        else
            types.gba_rom_start;

        try emitter.raw(
            \\pub fn gameEntry() void {{
            \\    decls.func_{X:0>8}();
            \\}}
            \\
            \\pub const BxEntry = struct {{
            \\    addr: u32,
            \\    func: *const fn () callconv(.c) void,
            \\}};
            \\
            \\pub const bx_table = [_]BxEntry{{
            \\
        , .{entry_target});

        for (analysis.functions.items) |f| {
            const bx_addr = f.entry | @as(u32, if (f.mode == .thumb) 1 else 0);
            try emitter.raw("    .{{ .addr = 0x{X:0>8}, .func = decls.func_{X:0>8} }},\n", .{
                bx_addr,
                f.entry,
            });
        }

        try emitter.raw(
            \\}};
            \\
            \\fn bxFind(addr: u32) ?usize {{
            \\    var lo: usize = 0;
            \\    var hi: usize = bx_table.len;
            \\    while (lo < hi) {{
            \\        const mid = lo + (hi - lo) / 2;
            \\        const a = bx_table[mid].addr & ~@as(u32, 1);
            \\        if (a == addr) return mid;
            \\        if (a < addr) {{
            \\            lo = mid + 1;
            \\        }} else {{
            \\            hi = mid;
            \\        }}
            \\    }}
            \\    return null;
            \\}}
            \\
            \\pub fn recompLookup(addr: u32) u32 {{
            \\    const idx = bxFind(addr) orelse return 0;
            \\    return bx_table[idx].addr;
            \\}}
            \\
            \\pub fn recompLookupFn(addr: u32) ?*const fn () callconv(.c) void {{
            \\    const idx = bxFind(addr) orelse return null;
            \\    return bx_table[idx].func;
            \\}}
            \\
            \\pub var g_bx_depth: i32 = 0;
            \\var bx_depth_warns: u32 = 0;
            \\
            \\pub export fn awre_cpu_bx(target: u32) void {{
            \\    if (target == 0 or target == 1) return;
            \\    if (g_bx_depth > 512) {{
            \\        if (bx_depth_warns < 5) {{
            \\            bx_depth_warns += 1;
            \\            std.debug.print("[cpu_bx] depth limit: dropping call to 0x{{X:0>8}}\n", .{{target}});
            \\        }}
            \\        rt.r[15] = target;
            \\        return;
            \\    }}
            \\    const region = target >> 24;
            \\    if (region == 0x02 or region == 0x03) {{
            \\        rt.run_iwram_function(target);
            \\        return;
            \\    }}
            \\    var lo: usize = 0;
            \\    var hi: usize = bx_table.len;
            \\    while (lo < hi) {{
            \\        const mid = lo + (hi - lo) / 2;
            \\        if (bx_table[mid].addr == target) {{
            \\            g_bx_depth += 1;
            \\            bx_table[mid].func();
            \\            g_bx_depth -= 1;
            \\            return;
            \\        }} else if (bx_table[mid].addr < target) {{
            \\            lo = mid + 1;
            \\        }} else {{
            \\            hi = mid;
            \\        }}
            \\    }}
            \\    if (region >= 0x08 and region <= 0x0D) {{
            \\        rt.run_iwram_function(target);
            \\        return;
            \\    }}
            \\    rt.r[15] = target;
            \\}}
            \\
            \\comptime {{
            \\    _ = &awre_cpu_bx;
            \\}}
            \\
        , .{});

        try out_dir.writeFile(io, .{ .sub_path = "game.zig", .data = emitter.buf.items });
    }

    return .{
        .num_func_files = num_func_files,
        .num_stub_files = num_stub_files,
        .num_functions = num_funcs,
        .num_stubs = stubs_list.items.len,
        .num_unresolved = unres_list.items.len,
        .num_prongs_emitted = num_prongs_emitted,
        .num_delegated_funcs = num_delegated_funcs,
    };
}

test "translateToDir generates valid Zig files for a minimal ARM+Thumb ROM" {
    var rom_buf: [512]u8 = @splat(0);
    std.mem.writeInt(u32, rom_buf[0x000..0x004], 0xEA00_002E, .little);
    @memcpy(rom_buf[0xA0..0xAC], "TESTROM     ");
    std.mem.writeInt(u32, rom_buf[0x0C0..0x0C4], 0xE59F_1008, .little);
    std.mem.writeInt(u32, rom_buf[0x0C4..0x0C8], 0xE1A0_E00F, .little);
    std.mem.writeInt(u32, rom_buf[0x0C8..0x0CC], 0xE12F_FF11, .little);
    std.mem.writeInt(u32, rom_buf[0x0CC..0x0D0], 0xEAFF_FFFE, .little);
    std.mem.writeInt(u32, rom_buf[0x0D0..0x0D4], 0x0800_0101, .little);
    std.mem.writeInt(u16, rom_buf[0x100..0x102], 0x2001, .little);
    std.mem.writeInt(u16, rom_buf[0x102..0x104], 0x3002, .little);
    std.mem.writeInt(u16, rom_buf[0x104..0x106], 0x4770, .little);

    var rom = try GbaRom.fromBorrowedSlice(&rom_buf);
    var ctx = try AnalysisCtx.init(std.testing.allocator, &rom);
    defer ctx.deinit();
    try ctx.run();

    var threaded: std.Io.Threaded = .init(std.testing.allocator, .{});
    defer threaded.deinit();
    const io = threaded.io();

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    const out_sub = try std.fmt.allocPrint(std.testing.allocator, ".zig-cache/tmp/{s}/gen_zig", .{tmp.sub_path});
    defer std.testing.allocator.free(out_sub);

    const stats = try translateToDir(std.testing.allocator, io, &rom, &ctx, out_sub);
    try std.testing.expectEqual(@as(usize, 2), stats.num_functions);
    try std.testing.expectEqual(@as(usize, 1), stats.num_func_files);
    const game_zig = try tmp.dir.readFileAlloc(io, "gen_zig/game.zig", std.testing.allocator, .limited(1024 * 1024));
    defer std.testing.allocator.free(game_zig);
    try std.testing.expect(std.mem.indexOf(u8, game_zig, "pub fn gameEntry() void") != null);
    try std.testing.expect(std.mem.indexOf(u8, game_zig, "decls.func_08000100") != null);
    try std.testing.expect(std.mem.indexOf(u8, game_zig, "pub export fn awre_cpu_bx") != null);
    const decls_zig = try tmp.dir.readFileAlloc(io, "gen_zig/decls.zig", std.testing.allocator, .limited(1024 * 1024));
    defer std.testing.allocator.free(decls_zig);
    try std.testing.expect(std.mem.indexOf(u8, decls_zig, "pub extern fn awre_cpu_bx") != null);
    try std.testing.expect(std.mem.indexOf(u8, decls_zig, "pub extern fn func_08000100() void;") != null);
    try std.testing.expect(std.mem.indexOf(u8, decls_zig, "enter_08000100") == null);

    const funcs_zig = try tmp.dir.readFileAlloc(io, "gen_zig/funcs_000.zig", std.testing.allocator, .limited(1024 * 1024));
    defer std.testing.allocator.free(funcs_zig);
    try std.testing.expect(std.mem.indexOf(u8, funcs_zig, "switch (@as(u32, 0)) {") != null);
    try std.testing.expect(std.mem.indexOf(u8, funcs_zig, "0 => {") != null);
    try std.testing.expect(std.mem.indexOf(u8, funcs_zig, "enter_08000100") == null);
}

test "unifyBlockSccOwners merges split-owner block cycles under a single canonical owner" {
    var rom_buf: [256]u8 = @splat(0);
    var rom = try GbaRom.fromBorrowedSlice(&rom_buf);
    var ctx = try AnalysisCtx.init(std.testing.allocator, &rom);
    defer ctx.deinit();

    // Create a 3-block CFG with a 2-block cycle split across two owners (B0 <-> B1) and exit B2
    try ctx.blocks.append(std.testing.allocator, .{
        .start = 0x0800_1000,
        .end = 0x0800_1010,
        .mode = .thumb,
        .successors = .{ 0x0800_1010, 0 },
        .num_successors = 1,
        .owner_entry = 0x0800_2000,
    });
    try ctx.blocks.append(std.testing.allocator, .{
        .start = 0x0800_1010,
        .end = 0x0800_1020,
        .mode = .thumb,
        .successors = .{ 0x0800_1000, 0x0800_1020 },
        .num_successors = 2,
        .owner_entry = 0x0800_3000,
    });
    try ctx.blocks.append(std.testing.allocator, .{
        .start = 0x0800_1020,
        .end = 0x0800_1030,
        .mode = .thumb,
        .successors = .{ 0, 0 },
        .num_successors = 0,
        .owner_entry = 0x0800_4000,
    });

    var by_start = std.AutoHashMap(u32, usize).init(std.testing.allocator);
    defer by_start.deinit();
    for (ctx.blocks.items, 0..) |b, i| try by_start.put(b.start, i);
    var jts = std.AutoHashMap(u32, usize).init(std.testing.allocator);
    defer jts.deinit();

    const eff = try unifyBlockSccOwners(std.testing.allocator, &ctx, &by_start, &jts);
    defer std.testing.allocator.free(eff);

    // Cycle B0 <-> B1 unified to smaller address on count tie (0x0800_2000), exit B2 untouched
    try std.testing.expectEqual(@as(u32, 0x0800_2000), eff[0]);
    try std.testing.expectEqual(@as(u32, 0x0800_2000), eff[1]);
    try std.testing.expectEqual(@as(u32, 0x0800_4000), eff[2]);
}
