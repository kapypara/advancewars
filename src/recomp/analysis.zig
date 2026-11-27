const std = @import("std");
const types = @import("types.zig");
const rom_mod = @import("rom.zig");
const arm_mod = @import("arm.zig");
const thumb_mod = @import("thumb.zig");

pub const CodeType = types.CodeType;
pub const GbaRom = rom_mod.GbaRom;

pub const BasicBlock = struct {
    start: u32 = 0,
    end: u32 = 0,
    mode: CodeType = .unknown,
    successors: [2]u32 = .{ 0, 0 },
    num_successors: u8 = 0,
    is_call_target: bool = false,
    is_return: bool = false,
    has_indirect: bool = false,
    /// Entry address of the single canonical owner function emitted first (0 = unowned).
    owner_entry: u32 = 0,
};

pub const Function = struct {
    entry: u32 = 0,
    mode: CodeType = .unknown,
    block_addrs: std.ArrayList(u32) = .empty,
    is_leaf: bool = true,
    has_switch: bool = false,
};

pub const JumpTable = struct {
    branch_addr: u32 = 0,
    table_addr: u32 = 0,
    targets: std.ArrayList(u32) = .empty,
    is_thumb: bool = false,
};

pub const WorkItem = struct {
    addr: u32 = 0,
    mode: CodeType = .unknown,
    caller: u32 = 0,
    is_call: bool = false,
    parent_func: u32 = 0,
};

pub const AnalysisCtx = struct {
    allocator: std.mem.Allocator,
    rom: *const GbaRom,

    codemap: []CodeType,
    /// Maps ROM halfword index -> containing BasicBlock index (`std.math.maxInt(u32)` = none).
    block_at_hw: []u32,

    blocks: std.ArrayList(BasicBlock) = .empty,
    functions: std.ArrayList(Function) = .empty,
    jump_tables: std.ArrayList(JumpTable) = .empty,

    block_by_start: std.AutoHashMap(u32, usize),
    func_by_entry: std.AutoHashMap(u32, usize),

    extra_entries: std.ArrayList(u32) = .empty,
    late_entries: std.ArrayList(u32) = .empty,

    queue: []WorkItem,
    queue_head: usize = 0,
    queue_tail: usize = 0,

    arm_insn_count: u32 = 0,
    thumb_insn_count: u32 = 0,

    const invalid_blk: u32 = std.math.maxInt(u32);

    pub fn init(allocator: std.mem.Allocator, rom: *const GbaRom) !AnalysisCtx {
        const halfwords = rom.data.len / 2;
        const codemap = try allocator.alloc(CodeType, halfwords);
        errdefer allocator.free(codemap);
        @memset(codemap, .unknown);

        const block_at_hw = try allocator.alloc(u32, halfwords);
        errdefer allocator.free(block_at_hw);
        @memset(block_at_hw, invalid_blk);

        const queue = try allocator.alloc(WorkItem, 4096);
        errdefer allocator.free(queue);

        return .{
            .allocator = allocator,
            .rom = rom,
            .codemap = codemap,
            .block_at_hw = block_at_hw,
            .block_by_start = std.AutoHashMap(u32, usize).init(allocator),
            .func_by_entry = std.AutoHashMap(u32, usize).init(allocator),
            .queue = queue,
        };
    }

    pub fn deinit(self: *AnalysisCtx) void {
        self.allocator.free(self.codemap);
        self.allocator.free(self.block_at_hw);
        self.blocks.deinit(self.allocator);
        for (self.functions.items) |*f| {
            f.block_addrs.deinit(self.allocator);
        }
        self.functions.deinit(self.allocator);
        for (self.jump_tables.items) |*jt| {
            jt.targets.deinit(self.allocator);
        }
        self.jump_tables.deinit(self.allocator);
        self.block_by_start.deinit();
        self.func_by_entry.deinit();
        self.extra_entries.deinit(self.allocator);
        self.late_entries.deinit(self.allocator);
        self.allocator.free(self.queue);
    }

    inline fn addrToIdx(addr: u32) ?usize {
        if (addr >= types.gba_rom_start) {
            return (addr - types.gba_rom_start) >> 1;
        }
        return null;
    }

    pub inline fn addrInRom(self: *const AnalysisCtx, addr: u32) bool {
        if (addr < types.gba_rom_start) return false;
        return (addr - types.gba_rom_start) < self.rom.data.len;
    }

    inline fn markCode(self: *AnalysisCtx, addr: u32, code_type: CodeType) void {
        const idx = addrToIdx(addr) orelse return;
        if (idx < self.codemap.len) {
            self.codemap[idx] = code_type;
        }
    }

    inline fn setBlockAtRange(self: *AnalysisCtx, start: u32, end: u32, blk_idx: u32) void {
        var a = start;
        while (a < end) : (a +%= 2) {
            const idx = addrToIdx(a) orelse break;
            if (idx < self.block_at_hw.len) {
                self.block_at_hw[idx] = blk_idx;
            }
        }
    }

    inline fn isVisited(self: *const AnalysisCtx, addr: u32) bool {
        const idx = addrToIdx(addr) orelse return true;
        if (idx >= self.codemap.len) return true;
        return self.codemap[idx] != .unknown;
    }

    pub fn getType(self: *const AnalysisCtx, addr: u32) CodeType {
        const idx = addrToIdx(addr) orelse return .unknown;
        if (idx >= self.codemap.len) return .unknown;
        return self.codemap[idx];
    }

    inline fn queueEmpty(self: *const AnalysisCtx) bool {
        return self.queue_head == self.queue_tail;
    }

    fn lateEntry(self: *AnalysisCtx, addr: u32, mode: CodeType) !void {
        const bit0: u32 = if (mode == .thumb) 1 else 0;
        try self.late_entries.append(self.allocator, addr | bit0);
    }

    fn queuePushEx(
        self: *AnalysisCtx,
        addr: u32,
        mode: CodeType,
        caller: u32,
        is_call: bool,
        parent_func: u32,
    ) !void {
        if (!self.addrInRom(addr)) return;
        if (self.isVisited(addr)) {
            if (is_call) try self.lateEntry(addr, mode);
            return;
        }

        const next = (self.queue_tail + 1) % self.queue.len;
        if (next == self.queue_head) {
            const new_cap = self.queue.len * 2;
            const new_q = try self.allocator.alloc(WorkItem, new_cap);
            var count: usize = 0;
            var i = self.queue_head;
            while (i != self.queue_tail) : (i = (i + 1) % self.queue.len) {
                new_q[count] = self.queue[i];
                count += 1;
            }
            self.allocator.free(self.queue);
            self.queue = new_q;
            self.queue_head = 0;
            self.queue_tail = count;
        }

        self.queue[self.queue_tail] = .{
            .addr = addr,
            .mode = mode,
            .caller = caller,
            .is_call = is_call,
            .parent_func = parent_func,
        };
        self.queue_tail = (self.queue_tail + 1) % self.queue.len;
    }

    fn queuePush(self: *AnalysisCtx, addr: u32, mode: CodeType, caller: u32, is_call: bool) !void {
        try self.queuePushEx(addr, mode, caller, is_call, 0);
    }

    fn queuePop(self: *AnalysisCtx) WorkItem {
        const item = self.queue[self.queue_head];
        self.queue_head = (self.queue_head + 1) % self.queue.len;
        return item;
    }

    pub fn addEntry(self: *AnalysisCtx, addr: u32, mode: CodeType) !void {
        try self.queuePush(addr, mode, 0, true);
    }

    /// Load `--entries <file>` extra entry points (one hex address per line, `#` comments).
    pub fn loadEntries(self: *AnalysisCtx, io: std.Io, path: []const u8) !usize {
        const text = try std.Io.Dir.cwd().readFileAlloc(io, path, self.allocator, .limited(4 * 1024 * 1024));
        defer self.allocator.free(text);
        return self.loadEntriesFromSlice(text);
    }

    pub fn loadEntriesFromSlice(self: *AnalysisCtx, text: []const u8) !usize {
        var lines = std.mem.splitScalar(u8, text, '\n');
        while (lines.next()) |raw_line| {
            const trimmed = std.mem.trim(u8, raw_line, " \t\r");
            if (trimmed.len == 0 or trimmed[0] == '#') continue;
            var end: usize = 0;
            while (end < trimmed.len and !std.ascii.isWhitespace(trimmed[end])) : (end += 1) {}
            const tok = trimmed[0..end];
            const hex_str = if (std.mem.startsWith(u8, tok, "0x") or std.mem.startsWith(u8, tok, "0X"))
                tok[2..]
            else
                tok;
            const addr = std.fmt.parseInt(u32, hex_str, 16) catch continue;
            if (addr == 0) continue;
            try self.extra_entries.append(self.allocator, addr & ~@as(u32, 1));
        }
        return self.extra_entries.items.len;
    }

    fn addBlock(self: *AnalysisCtx) !usize {
        const idx = self.blocks.items.len;
        try self.blocks.append(self.allocator, .{});
        return idx;
    }

    fn addFunction(self: *AnalysisCtx, entry: u32, mode: CodeType) !usize {
        if (self.func_by_entry.get(entry)) |existing| {
            return existing;
        }
        const idx = self.functions.items.len;
        try self.functions.append(self.allocator, .{
            .entry = entry,
            .mode = mode,
            .is_leaf = true,
        });
        try self.func_by_entry.put(entry, idx);
        return idx;
    }

    fn functionAddBlock(self: *AnalysisCtx, func_idx: usize, block_addr: u32) !void {
        const f = &self.functions.items[func_idx];
        for (f.block_addrs.items) |existing| {
            if (existing == block_addr) return;
        }
        try f.block_addrs.append(self.allocator, block_addr);
    }

    fn armIsReturn(insn: *const arm_mod.ArmInsn) bool {
        if (insn.type == .bx and insn.rm == 14) return true;
        if (insn.type == .mov and insn.rd == 15 and !insn.i and insn.rm == 14) return true;
        if (insn.type == .ldm and insn.rn == 13 and (insn.reg_list & (@as(u16, 1) << 15)) != 0) return true;
        return false;
    }

    fn armIsBlockEnd(insn: *const arm_mod.ArmInsn) bool {
        if (insn.type == .b or insn.type == .bl or insn.type == .bx or insn.type == .swi) return true;
        if ((insn.type == .mov or insn.type == .ldr or insn.type == .add or insn.type == .sub) and insn.rd == 15) return true;
        if (insn.type == .ldm and (insn.reg_list & (@as(u16, 1) << 15)) != 0) return true;
        return false;
    }

    fn analyzeArmBlock(self: *AnalysisCtx, start: u32, func_idx: ?usize) !void {
        const blk_idx = try self.addBlock();
        self.blocks.items[blk_idx].start = start;
        self.blocks.items[blk_idx].mode = .arm;
        try self.block_by_start.put(start, blk_idx);

        var addr = start;
        while (self.addrInRom(addr)) {
            if (addr != start and self.isVisited(addr)) {
                self.blocks.items[blk_idx].end = addr;
                self.blocks.items[blk_idx].successors[0] = addr;
                self.blocks.items[blk_idx].num_successors = 1;
                self.setBlockAtRange(start, addr, @intCast(blk_idx));
                if (func_idx) |fi| try self.functionAddBlock(fi, start);
                return;
            }

            self.markCode(addr, .arm);
            self.markCode(addr +% 2, .arm);

            const raw = self.rom.read32(addr);
            const insn = arm_mod.decode(raw);
            self.arm_insn_count +%= 1;

            if (armIsBlockEnd(&insn)) {
                self.blocks.items[blk_idx].end = addr +% 4;
                self.setBlockAtRange(start, addr +% 4, @intCast(blk_idx));

                if (armIsReturn(&insn)) {
                    self.blocks.items[blk_idx].is_return = true;
                    self.blocks.items[blk_idx].num_successors = 0;
                } else if (insn.type == .b) {
                    const target = addr +% 8 +% @as(u32, @bitCast(insn.branch_offset));
                    if (insn.cond == .al) {
                        self.blocks.items[blk_idx].successors[0] = target;
                        self.blocks.items[blk_idx].num_successors = 1;
                        try self.queuePush(target, .arm, addr, false);
                    } else {
                        self.blocks.items[blk_idx].successors[0] = addr +% 4;
                        self.blocks.items[blk_idx].successors[1] = target;
                        self.blocks.items[blk_idx].num_successors = 2;
                        try self.queuePush(addr +% 4, .arm, addr, false);
                        try self.queuePush(target, .arm, addr, false);
                    }
                } else if (insn.type == .bl) {
                    const target = addr +% 8 +% @as(u32, @bitCast(insn.branch_offset));
                    self.blocks.items[blk_idx].end = addr +% 4;
                    self.blocks.items[blk_idx].successors[0] = addr +% 4;
                    self.blocks.items[blk_idx].num_successors = 1;
                    if (func_idx) |fi| self.functions.items[fi].is_leaf = false;
                    try self.queuePush(target, .arm, addr, true);
                    const pfunc = if (func_idx) |fi| self.functions.items[fi].entry else 0;
                    try self.queuePushEx(addr +% 4, .arm, addr, false, pfunc);
                } else if (insn.type == .bx) {
                    if (insn.rm == 14) {
                        self.blocks.items[blk_idx].is_return = true;
                        self.blocks.items[blk_idx].num_successors = 0;
                    } else {
                        var resolved = false;
                        var is_call = false;
                        const target_reg = insn.rm;
                        if (addr >= start + 4) {
                            var scan = addr - 4;
                            const min_scan = addr -| 32;
                            while (scan >= start and scan >= min_scan) {
                                const scan_insn = arm_mod.decode(self.rom.read32(scan));
                                if (scan_insn.type == .mov and scan_insn.rd == 14 and
                                    !scan_insn.i and scan_insn.rm == 15 and scan_insn.shift_amount == 0)
                                {
                                    is_call = true;
                                }
                                if (scan_insn.type == .ldr and scan_insn.rd == target_reg and
                                    scan_insn.rn == 15 and !scan_insn.i and scan_insn.p)
                                {
                                    const pc_val = scan +% 8;
                                    const pool_addr = if (scan_insn.u) pc_val +% scan_insn.imm else pc_val -% scan_insn.imm;
                                    var target = self.rom.read32(pool_addr);
                                    const target_thumb = (target & 1) != 0;
                                    target &= ~@as(u32, 1);

                                    if (self.addrInRom(target)) {
                                        resolved = true;
                                        const tmode: CodeType = if (target_thumb) .thumb else .arm;
                                        if (is_call) {
                                            self.blocks.items[blk_idx].successors[0] = addr +% 4;
                                            self.blocks.items[blk_idx].num_successors = 1;
                                            if (func_idx) |fi| self.functions.items[fi].is_leaf = false;
                                            try self.queuePush(target, tmode, addr, true);
                                            try self.queuePush(addr +% 4, .arm, addr, false);
                                        } else {
                                            self.blocks.items[blk_idx].successors[0] = target;
                                            self.blocks.items[blk_idx].num_successors = 1;
                                            try self.queuePush(target, tmode, addr, false);
                                        }
                                    }
                                    break;
                                }
                                if (scan < 4) break;
                                scan -= 4;
                            }
                        }
                        if (!resolved) {
                            self.blocks.items[blk_idx].has_indirect = true;
                            self.blocks.items[blk_idx].num_successors = 0;
                        }
                    }
                } else if (insn.type == .ldm and (insn.reg_list & (@as(u16, 1) << 15)) != 0) {
                    self.blocks.items[blk_idx].is_return = true;
                    self.blocks.items[blk_idx].num_successors = 0;
                } else if (insn.type == .swi) {
                    self.blocks.items[blk_idx].successors[0] = addr +% 4;
                    self.blocks.items[blk_idx].num_successors = 1;
                    const pfunc = if (func_idx) |fi| self.functions.items[fi].entry else 0;
                    try self.queuePushEx(addr +% 4, .arm, addr, false, pfunc);
                } else {
                    self.blocks.items[blk_idx].has_indirect = true;
                    self.blocks.items[blk_idx].num_successors = 0;
                }

                if (insn.cond != .al and self.blocks.items[blk_idx].is_return) {
                    self.blocks.items[blk_idx].successors[0] = addr +% 4;
                    self.blocks.items[blk_idx].num_successors = 1;
                    const pfunc = if (func_idx) |fi| self.functions.items[fi].entry else 0;
                    try self.queuePushEx(addr +% 4, .arm, addr, false, pfunc);
                }

                if (func_idx) |fi| try self.functionAddBlock(fi, start);
                return;
            }
            addr +%= 4;
        }

        self.blocks.items[blk_idx].end = addr;
        self.blocks.items[blk_idx].num_successors = 0;
        self.setBlockAtRange(start, addr, @intCast(blk_idx));
        if (func_idx) |fi| try self.functionAddBlock(fi, start);
    }

    fn thumbIsReturn(insn: *const thumb_mod.ThumbInsn) bool {
        if (insn.type == .push_pop and insn.is_load and insn.pc_or_lr) return true;
        if (insn.type == .bx and insn.rs == 14) return true;
        if (insn.type == .hi_reg_ops and insn.hi_op == .mov and insn.rd == 15 and insn.rs == 14) return true;
        return false;
    }

    fn thumbIsBlockEnd(insn: *const thumb_mod.ThumbInsn) bool {
        if (insn.type == .branch or insn.type == .cond_branch or insn.type == .bx or insn.type == .swi) return true;
        if (insn.type == .long_branch and insn.is_suffix) return true;
        if (insn.type == .push_pop and insn.is_load and insn.pc_or_lr) return true;
        if (insn.type == .hi_reg_ops and insn.rd == 15 and (insn.hi_op == .mov or insn.hi_op == .add)) return true;
        return false;
    }

    fn thumbFollowsFunctionEnd(self: *const AnalysisCtx, addr: u32) bool {
        var back: u32 = 2;
        while (back <= 12) : (back += 2) {
            if (addr < types.gba_rom_start + back) return false;
            const prev = addr - back;
            const hw = self.rom.read16(prev);
            if ((hw & 0xFF87) == 0x4700) return true;
            if ((hw & 0xFF00) == 0xBD00) return true;
            if ((hw & 0xF800) == 0xE000) return true;
        }
        return false;
    }

    fn detectThumbJumpTable(self: *AnalysisCtx, mov_addr: u32, rx: u4, func_idx: ?usize) !bool {
        if (mov_addr < types.gba_rom_start + 8) return false;
        const ld = thumb_mod.decode(self.rom.read16(mov_addr - 2));
        const add = thumb_mod.decode(self.rom.read16(mov_addr - 4));
        if (ld.type != .load_store_imm or !ld.is_load or ld.is_byte or
            ld.rd != rx or ld.rs != rx or ld.imm != 0) return false;
        if (add.type != .add_sub or add.is_imm or add.is_subtract or add.rd != rx) return false;

        var table: u32 = 0;
        var idx_reg: u8 = 0xFF;
        {
            var scan = mov_addr - 6;
            const min_scan = mov_addr -| 16;
            while (scan >= min_scan and table == 0) {
                const s = thumb_mod.decode(self.rom.read16(scan));
                if (s.type == .pc_rel_load and (s.rd == add.rs or s.rd == add.rm)) {
                    table = self.rom.read32(((scan +% 4) & ~@as(u32, 3)) +% s.imm);
                    idx_reg = if (s.rd == add.rs) add.rm else add.rs;
                }
                if (scan < 2) break;
                scan -= 2;
            }
        }
        if (table == 0 or !self.addrInRom(table)) return false;

        var count: usize = 0;
        {
            var scan = mov_addr - 6;
            const min_scan = mov_addr -| 24;
            while (scan >= min_scan) {
                const s = thumb_mod.decode(self.rom.read16(scan));
                const nx = thumb_mod.decode(self.rom.read16(scan +% 2));
                if ((s.raw & 0xF800) == 0x0000 and ((s.raw >> 6) & 31) == 2 and (s.raw & 7) == idx_reg) {
                    idx_reg = @truncate((s.raw >> 3) & 7);
                }
                if (s.type == .mov_cmp_add_sub_imm and (s.raw & 0x1800) == 0x0800 and
                    s.rd == idx_reg and nx.type == .cond_branch and (nx.cond == .hi or nx.cond == .ls))
                {
                    count = @intCast(s.imm + 1);
                    break;
                }
                if (scan < 2) break;
                scan -= 2;
            }
        }
        if (count == 0) return false;

        var jt: JumpTable = .{
            .branch_addr = mov_addr,
            .table_addr = table,
            .is_thumb = true,
        };
        errdefer jt.targets.deinit(self.allocator);
        for (0..count) |i| {
            const t = self.rom.read32(table +% @as(u32, @intCast(i)) *% 4) & ~@as(u32, 1);
            if (!self.addrInRom(t)) break;
            try jt.targets.append(self.allocator, t);
            self.markCode(table +% @as(u32, @intCast(i)) *% 4, .data);
            self.markCode(table +% @as(u32, @intCast(i)) *% 4 +% 2, .data);
        }
        const pfunc = if (func_idx) |fi| self.functions.items[fi].entry else 0;
        for (jt.targets.items) |t| {
            try self.queuePushEx(t, .thumb, mov_addr, false, pfunc);
        }
        try self.jump_tables.append(self.allocator, jt);
        if (func_idx) |fi| self.functions.items[fi].has_switch = true;
        return true;
    }

    fn analyzeThumbBlock(self: *AnalysisCtx, start: u32, func_idx: ?usize) !void {
        const blk_idx = try self.addBlock();
        self.blocks.items[blk_idx].start = start;
        self.blocks.items[blk_idx].mode = .thumb;
        try self.block_by_start.put(start, blk_idx);

        var addr = start;
        var bl_prefix_offset: u32 = 0;
        var have_bl_prefix = false;

        while (self.addrInRom(addr)) {
            if (addr != start and self.isVisited(addr)) {
                self.blocks.items[blk_idx].end = addr;
                self.blocks.items[blk_idx].successors[0] = addr;
                self.blocks.items[blk_idx].num_successors = 1;
                self.setBlockAtRange(start, addr, @intCast(blk_idx));
                if (func_idx) |fi| try self.functionAddBlock(fi, start);
                return;
            }

            self.markCode(addr, .thumb);
            const raw = self.rom.read16(addr);
            const insn = thumb_mod.decode(raw);
            self.thumb_insn_count +%= 1;

            if (insn.type == .long_branch and !insn.is_suffix) {
                bl_prefix_offset = @bitCast(insn.offset);
                have_bl_prefix = true;
                addr +%= 2;
                continue;
            }

            if (insn.type == .long_branch and insn.is_suffix) {
                self.blocks.items[blk_idx].end = addr +% 2;
                self.setBlockAtRange(start, addr +% 2, @intCast(blk_idx));
                if (have_bl_prefix) {
                    const bl_addr = addr -% 2;
                    const target = (bl_addr +% 4) +% bl_prefix_offset +% insn.imm;
                    self.blocks.items[blk_idx].successors[0] = addr +% 2;
                    self.blocks.items[blk_idx].num_successors = 1;
                    if (func_idx) |fi| self.functions.items[fi].is_leaf = false;
                    try self.queuePush(target, .thumb, addr, true);
                    const pfunc = if (func_idx) |fi| self.functions.items[fi].entry else 0;
                    try self.queuePushEx(addr +% 2, .thumb, addr, false, pfunc);
                } else {
                    self.blocks.items[blk_idx].num_successors = 0;
                }
                have_bl_prefix = false;
                if (func_idx) |fi| try self.functionAddBlock(fi, start);
                return;
            }

            have_bl_prefix = false;

            if (thumbIsBlockEnd(&insn)) {
                self.blocks.items[blk_idx].end = addr +% 2;
                self.setBlockAtRange(start, addr +% 2, @intCast(blk_idx));

                if (thumbIsReturn(&insn)) {
                    self.blocks.items[blk_idx].is_return = true;
                    self.blocks.items[blk_idx].num_successors = 0;
                } else if (insn.type == .branch) {
                    const target = addr +% 4 +% @as(u32, @bitCast(insn.offset));
                    self.blocks.items[blk_idx].successors[0] = target;
                    self.blocks.items[blk_idx].num_successors = 1;
                    try self.queuePush(target, .thumb, addr, false);
                } else if (insn.type == .cond_branch) {
                    const target = addr +% 4 +% @as(u32, @bitCast(insn.offset));
                    self.blocks.items[blk_idx].successors[0] = addr +% 2;
                    self.blocks.items[blk_idx].successors[1] = target;
                    self.blocks.items[blk_idx].num_successors = 2;
                    try self.queuePush(addr +% 2, .thumb, addr, false);
                    try self.queuePush(target, .thumb, addr, false);
                } else if (insn.type == .bx) {
                    if (insn.rs == 14) {
                        self.blocks.items[blk_idx].is_return = true;
                        self.blocks.items[blk_idx].num_successors = 0;
                    } else if (insn.rs == 15) {
                        self.blocks.items[blk_idx].num_successors = 0;
                        try self.queuePush((addr +% 4) & ~@as(u32, 3), .arm, addr, true);
                    } else {
                        var is_pop_bx_return = false;
                        const bx_reg = insn.rs;
                        if (addr >= start + 2) {
                            var scan = addr - 2;
                            while (scan >= start) {
                                const scan_insn = thumb_mod.decode(self.rom.read16(scan));
                                if (scan_insn.type == .push_pop and scan_insn.is_load and
                                    bx_reg < 8 and (scan_insn.rlist & (@as(u8, 1) << @intCast(bx_reg))) != 0)
                                {
                                    is_pop_bx_return = true;
                                    break;
                                }
                                if (scan_insn.type == .mov_cmp_add_sub_imm and scan_insn.rd == bx_reg) break;
                                if ((scan_insn.type == .alu_ops or
                                    scan_insn.type == .hi_reg_ops or
                                    scan_insn.type == .move_shifted or
                                    scan_insn.type == .add_sub) and scan_insn.rd == bx_reg) break;
                                if (scan_insn.type == .pc_rel_load and scan_insn.rd == bx_reg) break;
                                if (addr - scan > 20 or scan < 2) break;
                                scan -= 2;
                            }
                        }
                        if (is_pop_bx_return) {
                            self.blocks.items[blk_idx].is_return = true;
                            self.blocks.items[blk_idx].num_successors = 0;
                        } else {
                            var resolved = false;
                            if (addr >= start + 2) {
                                var scan = addr - 2;
                                while (scan >= start) {
                                    const scan_insn = thumb_mod.decode(self.rom.read16(scan));
                                    if (scan_insn.type == .pc_rel_load and scan_insn.rd == bx_reg) {
                                        const pc_val = (scan +% 4) & ~@as(u32, 3);
                                        const pool_addr = pc_val +% scan_insn.imm;
                                        var target = self.rom.read32(pool_addr);
                                        const target_thumb = (target & 1) != 0;
                                        target &= ~@as(u32, 1);
                                        if (self.addrInRom(target)) {
                                            self.blocks.items[blk_idx].successors[0] = target;
                                            self.blocks.items[blk_idx].num_successors = 1;
                                            self.blocks.items[blk_idx].has_indirect = false;
                                            resolved = true;
                                            try self.queuePush(target, if (target_thumb) .thumb else .arm, addr, false);
                                        }
                                        break;
                                    }
                                    if (scan_insn.type == .load_addr and !scan_insn.is_sp and
                                        scan_insn.rd == bx_reg and scan + 2 == addr)
                                    {
                                        const target = ((scan +% 4) & ~@as(u32, 3)) +% scan_insn.imm;
                                        if (self.addrInRom(target)) {
                                            self.blocks.items[blk_idx].successors[0] = target;
                                            self.blocks.items[blk_idx].num_successors = 1;
                                            self.blocks.items[blk_idx].has_indirect = false;
                                            resolved = true;
                                            try self.queuePush(target, .arm, addr, true);
                                        }
                                        break;
                                    }
                                    if (addr - scan > 20 or scan < 2) break;
                                    scan -= 2;
                                }
                            }
                            if (!resolved) {
                                self.blocks.items[blk_idx].has_indirect = true;
                                self.blocks.items[blk_idx].num_successors = 0;
                            }
                        }
                    }
                } else if (insn.type == .hi_reg_ops) {
                    self.blocks.items[blk_idx].num_successors = 0;
                    const found_jt = (insn.hi_op == .mov) and
                        (try self.detectThumbJumpTable(addr, insn.rs, func_idx));
                    self.blocks.items[blk_idx].has_indirect = !found_jt;
                } else if (insn.type == .swi and insn.swi_num == 0x00) {
                    self.blocks.items[blk_idx].num_successors = 0;
                } else if (insn.type == .swi) {
                    self.blocks.items[blk_idx].successors[0] = addr +% 2;
                    self.blocks.items[blk_idx].num_successors = 1;
                    const pfunc = if (func_idx) |fi| self.functions.items[fi].entry else 0;
                    try self.queuePushEx(addr +% 2, .thumb, addr, false, pfunc);
                } else {
                    self.blocks.items[blk_idx].num_successors = 0;
                }

                if (func_idx) |fi| try self.functionAddBlock(fi, start);
                return;
            }
            addr +%= 2;
        }

        self.blocks.items[blk_idx].end = addr;
        self.blocks.items[blk_idx].num_successors = 0;
        self.setBlockAtRange(start, addr, @intCast(blk_idx));
        if (func_idx) |fi| try self.functionAddBlock(fi, start);
    }

    fn processWorkItem(self: *AnalysisCtx, item: WorkItem) !void {
        if (!self.addrInRom(item.addr)) return;
        if (self.isVisited(item.addr)) {
            if (item.is_call) try self.lateEntry(item.addr, item.mode);
            return;
        }

        var func_idx: ?usize = null;
        if (item.is_call or item.caller == 0) {
            func_idx = try self.addFunction(item.addr, item.mode);
        } else if (item.parent_func != 0) {
            func_idx = try self.addFunction(item.parent_func, item.mode);
        } else {
            var i = self.functions.items.len;
            while (i > 0) {
                i -= 1;
                if (self.functions.items[i].entry <= item.addr) {
                    func_idx = i;
                    break;
                }
            }
        }

        if (item.mode == .arm) {
            try self.analyzeArmBlock(item.addr, func_idx);
        } else {
            try self.analyzeThumbBlock(item.addr, func_idx);
        }
    }

    fn detectArmJumpTable(self: *AnalysisCtx, addr: u32) !void {
        const insn = arm_mod.decode(self.rom.read32(addr));
        if (insn.type == .add and insn.rd == 15 and insn.rn == 15 and
            !insn.i and insn.shift_type == .lsl and insn.shift_amount == 2)
        {
            const table_start = addr +% 8;
            var jt: JumpTable = .{ .branch_addr = addr, .table_addr = table_start, .is_thumb = false };
            errdefer jt.targets.deinit(self.allocator);
            for (0..256) |i| {
                const entry_addr = table_start +% @as(u32, @intCast(i)) *% 4;
                if (!self.addrInRom(entry_addr)) break;
                const entry_insn = arm_mod.decode(self.rom.read32(entry_addr));
                if (entry_insn.type != .b) break;
                const target = entry_addr +% 8 +% @as(u32, @bitCast(entry_insn.branch_offset));
                try jt.targets.append(self.allocator, target);
                try self.queuePush(target, .arm, addr, false);
                self.markCode(entry_addr, .arm);
                self.markCode(entry_addr +% 2, .arm);
            }
            try self.jump_tables.append(self.allocator, jt);
        }

        if (insn.type == .ldr and insn.rd == 15 and insn.rn == 15 and
            insn.i and insn.shift_type == .lsl and insn.shift_amount == 2)
        {
            const table_start = addr +% 8;
            var jt: JumpTable = .{ .branch_addr = addr, .table_addr = table_start, .is_thumb = false };
            errdefer jt.targets.deinit(self.allocator);
            for (0..256) |i| {
                const entry_addr = table_start +% @as(u32, @intCast(i)) *% 4;
                if (!self.addrInRom(entry_addr)) break;
                var target = self.rom.read32(entry_addr);
                if (target < types.gba_rom_start or target >= types.gba_rom_start + self.rom.data.len) break;
                const target_thumb = (target & 1) != 0;
                target &= ~@as(u32, 1);
                try jt.targets.append(self.allocator, target);
                try self.queuePush(target, if (target_thumb) .thumb else .arm, addr, false);
                self.markCode(entry_addr, .data);
                self.markCode(entry_addr +% 2, .data);
            }
            try self.jump_tables.append(self.allocator, jt);
        }
    }

    fn resolveBxTargets(self: *AnalysisCtx) !void {
        for (0..self.blocks.items.len) |i| {
            const b = self.blocks.items[i];
            if (!b.has_indirect) continue;

            if (b.mode == .arm and b.end >= b.start + 8) {
                const bx_addr = b.end - 4;
                const prev_addr = bx_addr - 4;
                const bx_insn = arm_mod.decode(self.rom.read32(bx_addr));
                if (bx_insn.type != .bx or bx_insn.rm == 14) continue;
                const prev_insn = arm_mod.decode(self.rom.read32(prev_addr));
                if (prev_insn.type == .ldr and prev_insn.rd == bx_insn.rm and
                    prev_insn.rn == 15 and !prev_insn.i and prev_insn.p)
                {
                    const pc_val = prev_addr +% 8;
                    const pool_addr = if (prev_insn.u) pc_val +% prev_insn.imm else pc_val -% prev_insn.imm;
                    var target = self.rom.read32(pool_addr);
                    const target_thumb = (target & 1) != 0;
                    target &= ~@as(u32, 1);
                    if (self.addrInRom(target)) {
                        self.blocks.items[i].successors[0] = target;
                        self.blocks.items[i].num_successors = 1;
                        self.blocks.items[i].has_indirect = false;
                        try self.queuePush(target, if (target_thumb) .thumb else .arm, bx_addr, false);
                    }
                }
            }

            if (b.mode == .thumb and b.end >= b.start + 4) {
                const bx_addr = b.end - 2;
                const prev_addr = bx_addr - 2;
                const bx_insn = thumb_mod.decode(self.rom.read16(bx_addr));
                if (bx_insn.type != .bx or bx_insn.rs == 14) continue;
                const prev_insn = thumb_mod.decode(self.rom.read16(prev_addr));
                if (prev_insn.type == .pc_rel_load) {
                    const pc_val = (prev_addr +% 4) & ~@as(u32, 3);
                    const pool_addr = pc_val +% prev_insn.imm;
                    var target = self.rom.read32(pool_addr);
                    const target_thumb = (target & 1) != 0;
                    target &= ~@as(u32, 1);
                    if (self.addrInRom(target)) {
                        self.blocks.items[i].successors[0] = target;
                        self.blocks.items[i].num_successors = 1;
                        self.blocks.items[i].has_indirect = false;
                        try self.queuePush(target, if (target_thumb) .thumb else .arm, bx_addr, false);
                    }
                }
            }
        }
        while (!self.queueEmpty()) {
            try self.processWorkItem(self.queuePop());
        }
    }

    fn detectJumpTables(self: *AnalysisCtx) !void {
        for (0..self.blocks.items.len) |i| {
            const b = self.blocks.items[i];
            if (!b.has_indirect) continue;
            if (b.mode == .arm and b.end >= 4) {
                try self.detectArmJumpTable(b.end - 4);
            }
        }
        while (!self.queueEmpty()) {
            try self.processWorkItem(self.queuePop());
        }
    }

    /// Split containing block `blk_idx` cleanly at `target` (`blk.start < target < blk.end`),
    /// propagating membership to all functions owning `blk.start` and inheriting `owner_entry`.
    fn splitBlockAt(self: *AnalysisCtx, blk_idx: usize, target: u32, block_holders: ?*std.AutoHashMap(u32, std.ArrayList(usize))) !usize {
        const orig = self.blocks.items[blk_idx];
        const new_blk: BasicBlock = .{
            .start = target,
            .end = orig.end,
            .mode = orig.mode,
            .successors = orig.successors,
            .num_successors = orig.num_successors,
            .is_return = orig.is_return,
            .has_indirect = orig.has_indirect,
            .owner_entry = orig.owner_entry,
        };
        const pstart = orig.start;

        self.blocks.items[blk_idx].end = target;
        self.blocks.items[blk_idx].successors[0] = target;
        self.blocks.items[blk_idx].num_successors = 1;
        self.blocks.items[blk_idx].is_return = false;
        self.blocks.items[blk_idx].has_indirect = false;

        const new_idx = self.blocks.items.len;
        try self.blocks.append(self.allocator, new_blk);
        try self.block_by_start.put(target, new_idx);
        self.setBlockAtRange(target, new_blk.end, @intCast(new_idx));

        if (block_holders) |bh| {
            if (bh.get(pstart)) |holders| {
                // Copy or iterate carefully since append may happen to new entry list
                for (holders.items) |fi| {
                    try self.functionAddBlock(fi, target);
                    const entry_ptr = try bh.getOrPut(target);
                    if (!entry_ptr.found_existing) entry_ptr.value_ptr.* = .empty;
                    try entry_ptr.value_ptr.append(self.allocator, fi);
                }
            }
        } else {
            for (0..self.functions.items.len) |fi| {
                for (self.functions.items[fi].block_addrs.items) |ba| {
                    if (ba == pstart) {
                        try self.functionAddBlock(fi, target);
                        break;
                    }
                }
            }
        }
        return new_idx;
    }

    /// Run all 7 analysis phases (matching `ext/gbarecomp/src/analysis.c`).
    pub fn run(self: *AnalysisCtx) !void {
        const entry_raw = self.rom.read32(types.gba_rom_start);
        const entry_insn = arm_mod.decode(entry_raw);
        if (entry_insn.type == .b) {
            const target = types.gba_rom_start +% 8 +% @as(u32, @bitCast(entry_insn.branch_offset));
            try self.addEntry(target, .arm);
        } else {
            try self.addEntry(types.gba_rom_start, .arm);
        }
        for (self.extra_entries.items) |addr| {
            try self.addEntry(addr, .thumb);
        }

        std.debug.print("[analysis] Starting recursive descent...\n", .{});
        var iteration: usize = 0;
        while (!self.queueEmpty()) {
            try self.processWorkItem(self.queuePop());
            iteration += 1;
            if (iteration % 10000 == 0) {
                std.debug.print("[analysis] {d} items processed, {d} blocks, {d} functions\n", .{
                    iteration,
                    self.blocks.items.len,
                    self.functions.items.len,
                });
            }
        }
        std.debug.print("[analysis] Phase 1 complete: {d} blocks, {d} functions\n", .{
            self.blocks.items.len,
            self.functions.items.len,
        });

        std.debug.print("[analysis] Phase 2: Resolving indirect branches...\n", .{});
        try self.resolveBxTargets();
        std.debug.print("[analysis] After BX resolution: {d} blocks, {d} functions\n", .{
            self.blocks.items.len,
            self.functions.items.len,
        });

        std.debug.print("[analysis] Phase 3: Detecting jump tables...\n", .{});
        try self.detectJumpTables();
        std.debug.print("[analysis] Found {d} jump tables, now {d} blocks, {d} functions\n", .{
            self.jump_tables.items.len,
            self.blocks.items.len,
            self.functions.items.len,
        });

        std.debug.print("[analysis] Phase 4: Scanning for function prologues...\n", .{});
        {
            const rom_size: u32 = @intCast(self.rom.data.len);
            var found: usize = 0;
            var offset: u32 = 0;
            while (offset + 2 <= rom_size) : (offset += 2) {
                const addr = types.gba_rom_start + offset;
                if (self.isVisited(addr)) continue;

                const raw = self.rom.read16(addr);
                if ((raw & 0xFF00) == 0xB500) {
                    var looks_valid = true;
                    var i: u32 = 1;
                    while (i <= 3 and looks_valid) : (i += 1) {
                        const check_addr = addr + i * 2;
                        if (check_addr + 2 > types.gba_rom_start + rom_size) {
                            looks_valid = false;
                            break;
                        }
                        const check = self.rom.read16(check_addr);
                        if (check == 0x0000 or check == 0xFFFF or check == 0xDEAD or check == 0xBEEF) {
                            looks_valid = false;
                        }
                        if ((check & 0xF800) == 0xF800 and i == 1) {
                            looks_valid = false;
                        }
                    }
                    if (looks_valid) {
                        try self.queuePush(addr, .thumb, 0, true);
                        found += 1;
                    }
                }

                if (offset % 4 == 0 and offset + 4 <= rom_size) {
                    const raw32 = self.rom.read32(addr);
                    if ((raw32 & 0xFFFF_0000) == 0xE92D_0000 and (raw32 & (1 << 14)) != 0) {
                        try self.queuePush(addr, .arm, 0, true);
                        found += 1;
                    }
                }
            }
            std.debug.print("[analysis] Found {d} potential function prologues\n", .{found});

            var new_iter: usize = 0;
            while (!self.queueEmpty()) {
                try self.processWorkItem(self.queuePop());
                new_iter += 1;
                if (new_iter % 10000 == 0) {
                    std.debug.print("[analysis] Phase 4: {d} items processed, {d} blocks, {d} functions\n", .{
                        new_iter,
                        self.blocks.items.len,
                        self.functions.items.len,
                    });
                }
            }
            std.debug.print("[analysis] Phase 4 complete: {d} blocks, {d} functions\n", .{
                self.blocks.items.len,
                self.functions.items.len,
            });
        }

        std.debug.print("[analysis] Phase 4b: Scanning ROM for Thumb code pointers...\n", .{});
        for (0..4) |pass| {
            const before = self.functions.items.len;
            var queued: usize = 0;
            var off: u32 = 0;
            while (off + 4 <= self.rom.data.len) : (off += 4) {
                const w = self.rom.read32(types.gba_rom_start + off);
                if ((w & 1) == 0) continue;
                const target = w & ~@as(u32, 1);
                if (!self.addrInRom(target) or target < types.gba_rom_start + 4) continue;
                const kind = self.getType(target);
                if (kind == .thumb) {
                    try self.lateEntry(target, .thumb);
                } else if (kind == .unknown and self.thumbFollowsFunctionEnd(target)) {
                    try self.queuePush(target, .thumb, 0, true);
                    queued += 1;
                }
            }
            while (!self.queueEmpty()) {
                try self.processWorkItem(self.queuePop());
            }
            const added = self.functions.items.len - before;
            std.debug.print("[analysis] Pass {d}: {d} new entries from code pointers ({d} analyzed fresh)\n", .{
                pass + 1,
                added,
                queued,
            });
            if (added == 0) break;
        }

        // Phase 5: Split blocks at mid-block branch targets using O(1) halfword lookup
        std.debug.print("[analysis] Phase 5: Splitting blocks at mid-block branch targets...\n", .{});
        {
            var block_holders = std.AutoHashMap(u32, std.ArrayList(usize)).init(self.allocator);
            defer {
                var it = block_holders.valueIterator();
                while (it.next()) |list| list.deinit(self.allocator);
                block_holders.deinit();
            }
            for (0..self.functions.items.len) |fi| {
                for (self.functions.items[fi].block_addrs.items) |ba| {
                    const gop = try block_holders.getOrPut(ba);
                    if (!gop.found_existing) gop.value_ptr.* = .empty;
                    try gop.value_ptr.append(self.allocator, fi);
                }
            }

            var splits: usize = 0;
            var i: usize = 0;
            while (i < self.blocks.items.len) : (i += 1) {
                const nsucc = self.blocks.items[i].num_successors;
                for (0..nsucc) |s| {
                    const target = self.blocks.items[i].successors[s];
                    if (target == 0) continue;
                    const hw_idx = addrToIdx(target) orelse continue;
                    if (hw_idx >= self.block_at_hw.len) continue;
                    const cand = self.block_at_hw[hw_idx];
                    if (cand == invalid_blk) continue;
                    const cb = self.blocks.items[cand];
                    if (target > cb.start and target < cb.end) {
                        _ = try self.splitBlockAt(cand, target, &block_holders);
                        splits += 1;
                    }
                }
            }
            std.debug.print("[analysis] Split {d} blocks\n", .{splits});
        }

        // Phase 6: Merge branch-connected blocks into functions and assign canonical first owners
        std.debug.print("[analysis] Phase 6: Merging branch-connected blocks into functions...\n", .{});
        {
            var merged: usize = 0;
            const num_blks = self.blocks.items.len;
            const block_owner = try self.allocator.alloc(i32, num_blks);
            defer self.allocator.free(block_owner);
            @memset(block_owner, -1);

            for (0..self.functions.items.len) |fi| {
                for (self.functions.items[fi].block_addrs.items) |ba| {
                    if (self.block_by_start.get(ba)) |bi| {
                        block_owner[bi] = @intCast(fi);
                        if (self.blocks.items[bi].owner_entry == 0) {
                            self.blocks.items[bi].owner_entry = self.functions.items[fi].entry;
                        }
                    }
                }
            }

            // Index jump tables per block start
            var block_jts = std.AutoHashMap(u32, std.ArrayList(usize)).init(self.allocator);
            defer {
                var it = block_jts.valueIterator();
                while (it.next()) |l| l.deinit(self.allocator);
                block_jts.deinit();
            }
            for (0..self.jump_tables.items.len) |ti| {
                const branch_addr = self.jump_tables.items[ti].branch_addr;
                if (addrToIdx(branch_addr)) |hw| {
                    if (hw < self.block_at_hw.len and self.block_at_hw[hw] != invalid_blk) {
                        const bstart = self.blocks.items[self.block_at_hw[hw]].start;
                        const gop = try block_jts.getOrPut(bstart);
                        if (!gop.found_existing) gop.value_ptr.* = .empty;
                        try gop.value_ptr.append(self.allocator, ti);
                    }
                }
            }

            var succ_buf: [2 + 256]u32 = undefined;
            for (0..self.functions.items.len) |fi| {
                var bi: usize = 0;
                while (bi < self.functions.items[fi].block_addrs.items.len) : (bi += 1) {
                    const block_addr = self.functions.items[fi].block_addrs.items[bi];
                    const blk_idx = self.block_by_start.get(block_addr) orelse continue;
                    const blk = self.blocks.items[blk_idx];

                    var nsucc: usize = 0;
                    for (0..blk.num_successors) |s| {
                        succ_buf[nsucc] = blk.successors[s];
                        nsucc += 1;
                    }
                    if (block_jts.get(blk.start)) |jts| {
                        for (jts.items) |ti| {
                            for (self.jump_tables.items[ti].targets.items) |t| {
                                if (nsucc < succ_buf.len) {
                                    succ_buf[nsucc] = t;
                                    nsucc += 1;
                                }
                            }
                        }
                    }

                    for (succ_buf[0..nsucc]) |target| {
                        if (target == 0) continue;
                        const target_idx = self.block_by_start.get(target) orelse continue;
                        if (block_owner[target_idx] == @as(i32, @intCast(fi))) continue;

                        var have = false;
                        for (self.functions.items[fi].block_addrs.items) |existing| {
                            if (existing == target) {
                                have = true;
                                break;
                            }
                        }
                        if (have) continue;

                        if (self.func_by_entry.contains(target)) {
                            var is_call = false;
                            if (blk.end >= 4) {
                                const la = blk.end - 2;
                                if (blk.mode == .thumb and la >= 2) {
                                    const hw = self.rom.read16(la);
                                    const hw2 = self.rom.read16(la - 2);
                                    if ((hw2 & 0xF800) == 0xF000 and (hw & 0xF800) == 0xF800) is_call = true;
                                    if ((hw & 0xFF00) == 0xDF00) is_call = true;
                                } else if (blk.mode == .arm) {
                                    const arm_insn = self.rom.read32(blk.end - 4);
                                    if ((arm_insn & 0x0F00_0000) == 0x0B00_0000) is_call = true;
                                    if ((arm_insn & 0x0F00_0000) == 0x0F00_0000) is_call = true;
                                }
                            }
                            if (!is_call) continue;
                        }

                        try self.functionAddBlock(fi, target);
                        if (block_owner[target_idx] < 0) {
                            block_owner[target_idx] = @intCast(fi);
                            self.blocks.items[target_idx].owner_entry = self.functions.items[fi].entry;
                        }
                        merged += 1;
                    }
                }
            }
            std.debug.print("[analysis] Merged {d} blocks in single pass\n", .{merged});
        }

        // Register late entries after Phase 6
        {
            const before = self.functions.items.len;
            std.mem.sort(u32, self.late_entries.items, {}, std.sort.asc(u32));
            for (self.late_entries.items, 0..) |e, i| {
                if (i > 0 and e == self.late_entries.items[i - 1]) continue;
                _ = try self.addFunction(e & ~@as(u32, 1), if ((e & 1) != 0) .thumb else .arm);
            }
            std.debug.print("[analysis] {d} entries from code pointers and calls into existing code\n", .{
                self.functions.items.len - before,
            });
        }

        // Phase 7: Fix empty functions (mid-function entries)
        std.debug.print("[analysis] Phase 7: Fixing empty functions (mid-function entries)...\n", .{});
        {
            var fixed: usize = 0;
            for (0..self.functions.items.len) |fi| {
                if (self.functions.items[fi].block_addrs.items.len > 0) continue;
                const entry = self.functions.items[fi].entry;
                var found_bi = self.block_by_start.get(entry);
                if (found_bi == null) {
                    if (addrToIdx(entry)) |hw| {
                        if (hw < self.block_at_hw.len and self.block_at_hw[hw] != invalid_blk) {
                            const cand = self.block_at_hw[hw];
                            const cb = self.blocks.items[cand];
                            if (cb.start < entry and entry < cb.end) {
                                found_bi = try self.splitBlockAt(cand, entry, null);
                            }
                        }
                    }
                }

                if (found_bi) |_| {
                    try self.functionAddBlock(fi, entry);
                    var bi: usize = 0;
                    while (bi < self.functions.items[fi].block_addrs.items.len) : (bi += 1) {
                        const ba = self.functions.items[fi].block_addrs.items[bi];
                        const blk_idx = self.block_by_start.get(ba) orelse continue;
                        const blk = self.blocks.items[blk_idx];
                        if (self.blocks.items[blk_idx].owner_entry == 0) {
                            self.blocks.items[blk_idx].owner_entry = entry;
                        }
                        for (0..blk.num_successors) |s| {
                            const succ = blk.successors[s];
                            if (succ == 0) continue;
                            var is_other_entry = false;
                            if (self.func_by_entry.get(succ)) |k| {
                                if (k != fi and self.functions.items[k].block_addrs.items.len > 0) {
                                    is_other_entry = true;
                                }
                            }
                            if (!is_other_entry) {
                                try self.functionAddBlock(fi, succ);
                            }
                        }
                    }
                    fixed += 1;
                }
            }
            std.debug.print("[analysis] Fixed {d} empty functions\n", .{fixed});
        }

        // Sort blocks and functions by address, rebuilding O(1) lookup maps
        std.mem.sort(BasicBlock, self.blocks.items, {}, blockLessThan);
        std.mem.sort(Function, self.functions.items, {}, funcLessThan);

        self.block_by_start.clearRetainingCapacity();
        @memset(self.block_at_hw, invalid_blk);
        for (self.blocks.items, 0..) |b, i| {
            try self.block_by_start.put(b.start, i);
            self.setBlockAtRange(b.start, b.end, @intCast(i));
        }

        self.func_by_entry.clearRetainingCapacity();
        for (self.functions.items, 0..) |f, i| {
            try self.func_by_entry.put(f.entry, i);
        }
    }

    fn blockLessThan(_: void, a: BasicBlock, b: BasicBlock) bool {
        return a.start < b.start;
    }

    fn funcLessThan(_: void, a: Function, b: Function) bool {
        return a.entry < b.entry;
    }

    pub fn findBlock(self: *const AnalysisCtx, addr: u32) ?*const BasicBlock {
        if (self.block_by_start.get(addr)) |idx| {
            return &self.blocks.items[idx];
        }
        if (addrToIdx(addr)) |hw| {
            if (hw < self.block_at_hw.len and self.block_at_hw[hw] != invalid_blk) {
                const idx = self.block_at_hw[hw];
                const b = &self.blocks.items[idx];
                if (addr >= b.start and addr < b.end) return b;
            }
        }
        return null;
    }

    pub fn findFunction(self: *const AnalysisCtx, entry: u32) ?*const Function {
        const idx = self.func_by_entry.get(entry) orelse return null;
        return &self.functions.items[idx];
    }

    pub fn printSummary(self: *const AnalysisCtx) void {
        var arm_bytes: u32 = 0;
        var thumb_bytes: u32 = 0;
        var data_bytes: u32 = 0;
        var unknown_bytes: u32 = 0;
        for (self.codemap) |ct| {
            switch (ct) {
                .arm => arm_bytes += 2,
                .thumb => thumb_bytes += 2,
                .data => data_bytes += 2,
                .unknown => unknown_bytes += 2,
            }
        }
        var indirect_blocks: usize = 0;
        for (self.blocks.items) |b| {
            if (b.has_indirect) indirect_blocks += 1;
        }
        var leaf_funcs: usize = 0;
        for (self.functions.items) |f| {
            if (f.is_leaf) leaf_funcs += 1;
        }
        const rom_sz: f64 = @floatFromInt(self.rom.data.len);
        std.debug.print(
            "\n=== Analysis Summary ===\n" ++
                "  Functions:          {d} ({d} leaf)\n" ++
                "  Basic blocks:       {d} ({d} with unresolved indirect branches)\n" ++
                "  Jump tables:        {d}\n" ++
                "  ARM instructions:   {d}\n" ++
                "  Thumb instructions: {d}\n" ++
                "  Code coverage:\n" ++
                "    ARM code:         {d} bytes ({d:.1}%)\n" ++
                "    Thumb code:       {d} bytes ({d:.1}%)\n" ++
                "    Data:             {d} bytes ({d:.1}%)\n" ++
                "    Unanalyzed:       {d} bytes ({d:.1}%)\n" ++
                "========================\n",
            .{
                self.functions.items.len,
                leaf_funcs,
                self.blocks.items.len,
                indirect_blocks,
                self.jump_tables.items.len,
                self.arm_insn_count,
                self.thumb_insn_count,
                arm_bytes,
                100.0 * @as(f64, @floatFromInt(arm_bytes)) / rom_sz,
                thumb_bytes,
                100.0 * @as(f64, @floatFromInt(thumb_bytes)) / rom_sz,
                data_bytes,
                100.0 * @as(f64, @floatFromInt(data_bytes)) / rom_sz,
                unknown_bytes,
                100.0 * @as(f64, @floatFromInt(unknown_bytes)) / rom_sz,
            },
        );
    }
};

test "AnalysisCtx discovers ARM entry, Thumb callee loop, and owner assignment" {
    var rom_buf: [512]u8 = @splat(0);
    // 0x08000000: B 0x080000C0 (offset = 0xB8 -> 0xB8/4 = 0x2E)
    std.mem.writeInt(u32, rom_buf[0x000..0x004], 0xEA00_002E, .little);
    // 0x080000C0 (ARM): LDR r1, [pc, #8] (=0x08000101); MOV lr, pc; BX r1; B 0x080000CC (self)
    std.mem.writeInt(u32, rom_buf[0x0C0..0x0C4], 0xE59F_1008, .little);
    std.mem.writeInt(u32, rom_buf[0x0C4..0x0C8], 0xE1A0_E00F, .little);
    std.mem.writeInt(u32, rom_buf[0x0C8..0x0CC], 0xE12F_FF11, .little);
    std.mem.writeInt(u32, rom_buf[0x0CC..0x0D0], 0xEAFF_FFFE, .little);
    std.mem.writeInt(u32, rom_buf[0x0D0..0x0D4], 0x0800_0101, .little);
    // 0x08000100 (Thumb): MOV r0, #1; ADD r0, #2; BX lr
    std.mem.writeInt(u16, rom_buf[0x100..0x102], 0x2001, .little);
    std.mem.writeInt(u16, rom_buf[0x102..0x104], 0x3002, .little);
    std.mem.writeInt(u16, rom_buf[0x104..0x106], 0x4770, .little);

    var rom = try GbaRom.fromBorrowedSlice(&rom_buf);
    var ctx = try AnalysisCtx.init(std.testing.allocator, &rom);
    defer ctx.deinit();

    try ctx.run();

    try std.testing.expectEqual(@as(usize, 2), ctx.functions.items.len);
    const f_entry = ctx.findFunction(0x0800_00C0) orelse return error.TestUnexpectedResult;
    try std.testing.expectEqual(CodeType.arm, f_entry.mode);
    const f_thumb = ctx.findFunction(0x0800_0100) orelse return error.TestUnexpectedResult;
    try std.testing.expectEqual(CodeType.thumb, f_thumb.mode);
    const blk0 = ctx.findBlock(0x0800_00C0) orelse return error.TestUnexpectedResult;
    try std.testing.expectEqual(@as(u32, 0x0800_00C0), blk0.owner_entry);
}
