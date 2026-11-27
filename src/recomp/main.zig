const std = @import("std");
pub const types = @import("types.zig");
pub const rom_mod = @import("rom.zig");
pub const arm = @import("arm.zig");
pub const thumb = @import("thumb.zig");
pub const analysis = @import("analysis.zig");
pub const translate = @import("translate.zig");

const GbaRom = rom_mod.GbaRom;
const AnalysisCtx = analysis.AnalysisCtx;

fn printUsage(prog: []const u8) void {
    std.debug.print(
        \\gbarecomp-zig - Pure-Zig GBA Static Recompiler
        \\
        \\Usage:
        \\  {s} info <rom.gba>
        \\  {s} disasm <rom.gba> [--start <hex>] [--count <n>] [--thumb|--arm]
        \\  {s} analyze <rom.gba> [--entries <file>] [--functions]
        \\  {s} translate <rom.gba> -o <outdir> [--multi] [--entries <file>]
        \\
    , .{ prog, prog, prog, prog });
}

fn parseHex(s: []const u8) !u32 {
    const trimmed = if (std.mem.startsWith(u8, s, "0x") or std.mem.startsWith(u8, s, "0X")) s[2..] else s;
    return std.fmt.parseInt(u32, trimmed, 16);
}

pub fn main(init: std.process.Init) !u8 {
    const gpa = init.gpa;
    const io = init.io;
    const args = init.minimal.args.vector;
    if (args.len < 3) {
        const prog = if (args.len > 0) std.mem.span(args[0]) else "gbarecomp";
        printUsage(prog);
        return 1;
    }

    var entries_path: ?[]const u8 = null;
    {
        var i: usize = 3;
        while (i + 1 < args.len) : (i += 1) {
            if (std.mem.eql(u8, std.mem.span(args[i]), "--entries")) {
                entries_path = std.mem.span(args[i + 1]);
            }
        }
    }

    const command = std.mem.span(args[1]);
    const rom_path = std.mem.span(args[2]);

    var rom = GbaRom.load(gpa, io, rom_path) catch |err| {
        std.debug.print("Error: cannot load ROM '{s}': {}\n", .{ rom_path, err });
        return 1;
    };
    defer rom.deinit(gpa);

    if (std.mem.eql(u8, command, "info")) {
        rom.printInfo();
        const raw = rom.read32(types.gba_rom_start);
        const insn = arm.decode(raw);
        var buf: [256]u8 = undefined;
        const dis = insn.formatDisasm(types.gba_rom_start, &buf);
        std.debug.print("\nEntry instruction:\n  {X:0>8}:  {X:0>8}  {s}\n", .{
            types.gba_rom_start,
            raw,
            dis,
        });
        return 0;
    }

    if (std.mem.eql(u8, command, "disasm")) {
        var start: u32 = 0;
        var start_set = false;
        var count: usize = 64;
        var is_thumb = false;
        var i: usize = 3;
        while (i < args.len) : (i += 1) {
            const a = std.mem.span(args[i]);
            if (std.mem.eql(u8, a, "--start") and i + 1 < args.len) {
                i += 1;
                start = parseHex(std.mem.span(args[i])) catch 0;
                start_set = true;
            } else if (std.mem.eql(u8, a, "--count") and i + 1 < args.len) {
                i += 1;
                count = std.fmt.parseInt(usize, std.mem.span(args[i]), 10) catch 64;
            } else if (std.mem.eql(u8, a, "--thumb")) {
                is_thumb = true;
            } else if (std.mem.eql(u8, a, "--arm")) {
                is_thumb = false;
            }
        }
        if (!start_set) {
            const entry = arm.decode(rom.read32(types.gba_rom_start));
            start = if (entry.type == .b)
                types.gba_rom_start +% 8 +% @as(u32, @bitCast(entry.branch_offset))
            else
                types.gba_rom_start;
        }
        const step: u32 = if (is_thumb) 2 else 4;
        const rom_end = types.gba_rom_start + @as(u32, @intCast(rom.data.len));
        const end = @min(start +% @as(u32, @intCast(count)) *% step, rom_end);
        var buf: [256]u8 = undefined;
        var addr = start;
        while (addr < end) : (addr += step) {
            if (is_thumb) {
                const raw = rom.read16(addr);
                const insn = thumb.decode(raw);
                std.debug.print("  {X:0>8}:  {X:0>4}      {s}\n", .{ addr, raw, insn.formatDisasm(addr, &buf) });
            } else {
                const raw = rom.read32(addr);
                const insn = arm.decode(raw);
                std.debug.print("  {X:0>8}:  {X:0>8}  {s}\n", .{ addr, raw, insn.formatDisasm(addr, &buf) });
            }
        }
        return 0;
    }

    if (std.mem.eql(u8, command, "analyze")) {
        var show_funcs = false;
        var i: usize = 3;
        while (i < args.len) : (i += 1) {
            if (std.mem.eql(u8, std.mem.span(args[i]), "--functions")) show_funcs = true;
        }
        rom.printInfo();
        var ctx = try AnalysisCtx.init(gpa, &rom);
        defer ctx.deinit();
        if (entries_path) |ep| {
            const n = ctx.loadEntries(io, ep) catch |err| {
                std.debug.print("Error: cannot read entries file '{s}': {}\n", .{ ep, err });
                return 1;
            };
            std.debug.print("Loaded {d} extra entry points from {s}\n", .{ n, ep });
        }
        try ctx.run();
        ctx.printSummary();
        if (show_funcs) {
            for (ctx.functions.items) |f| {
                std.debug.print("0x{X:0>8}  {s}  {d} blocks\n", .{
                    f.entry,
                    if (f.mode == .arm) "ARM  " else "Thumb",
                    f.block_addrs.items.len,
                });
            }
        }
        return 0;
    }

    if (std.mem.eql(u8, command, "translate")) {
        var out_dir: ?[]const u8 = null;
        var i: usize = 3;
        while (i < args.len) : (i += 1) {
            const a = std.mem.span(args[i]);
            if (std.mem.eql(u8, a, "-o") and i + 1 < args.len) {
                i += 1;
                out_dir = std.mem.span(args[i]);
            }
        }
        const outdir = out_dir orelse {
            std.debug.print("Error: -o <outdir> is required\n", .{});
            return 1;
        };

        rom.printInfo();
        var ctx = try AnalysisCtx.init(gpa, &rom);
        defer ctx.deinit();
        if (entries_path) |ep| {
            const n = ctx.loadEntries(io, ep) catch |err| {
                std.debug.print("Error: cannot read entries file '{s}': {}\n", .{ ep, err });
                return 1;
            };
            std.debug.print("Loaded {d} extra entry points from {s}\n", .{ n, ep });
        }
        try ctx.run();
        ctx.printSummary();

        const stats = try translate.translateToDir(gpa, io, &rom, &ctx, outdir);
        std.debug.print(
            "Generated {d} func shards + {d} stub shards in '{s}': {d} functions, {d} stubs, {d} unresolved, {d} unique blocks emitted ({d} delegated)\n",
            .{
                stats.num_func_files,
                stats.num_stub_files,
                outdir,
                stats.num_functions,
                stats.num_stubs,
                stats.num_unresolved,
                stats.num_prongs_emitted,
                stats.num_delegated_funcs,
            },
        );
        return 0;
    }

    std.debug.print("Unknown command: {s}\n", .{command});
    printUsage(std.mem.span(args[0]));
    return 1;
}

test {
    std.testing.refAllDecls(@This());
}
