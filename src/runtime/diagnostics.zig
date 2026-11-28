//! Runtime diagnostics: memory write watchpoints, call histogram, unwind ring, and trace logs.

const std = @import("std");
const builtin = @import("builtin");
const core = @import("awre_core");

const has_posix = builtin.os.tag != .freestanding;

const c_host = if (has_posix) struct {
    extern "c" fn getenv(name: [*:0]const u8) ?[*:0]const u8;
    extern "c" fn atol(nptr: [*:0]const u8) c_long;
    extern "c" fn strtoul(nptr: [*:0]const u8, endptr: ?*?[*]u8, base: c_int) c_ulong;
} else struct {};

pub const HistEntry = struct {
    addr: u32 = 0,
    count: u32 = 0,
    first: u32 = 0,
};

var watch_addr: u32 = 1; // sentinel 1 = not read from env yet
var swi_log_init: bool = false;
var swi_log_from: i64 = -1;
var swi_log_to: i64 = -1;
var trace_interp_left: i64 = -1;
var trace_at_init: bool = false;
var trace_at_env: ?[]const u8 = null;
var bx_trace_count: u32 = 0;
var bx_trace_last: u32 = 0;
var unmapped_bx_warns: u32 = 0;
var interp_limit_warns: u32 = 0;

pub var hist: [16384]HistEntry = @splat(.{});
var hist_out: [16384]HistEntry = @splat(.{});
pub var hist_n: u32 = 0;
pub var hist_seq: u32 = 0;
var ring_seen: [4096]u32 = @splat(0);
var ring_count: [4096]u32 = @splat(0);

pub fn watchCheck(
    addr: u32,
    value: u32,
    size_bytes: u32,
    in_irq: bool,
    frame_count: u32,
    func_ring: *const [4096]u32,
    func_ring_i: u32,
    lr: u32,
) void {
    if (!has_posix) return;
    if (watch_addr == 1) {
        if (c_host.getenv("GBA_WATCH")) |w| {
            watch_addr = @as(u32, @truncate(c_host.strtoul(w, null, 16))) & ~@as(u32, 3);
        } else {
            watch_addr = 0;
        }
    }
    if (watch_addr == 0 or (addr & ~@as(u32, 3)) != watch_addr) return;
    const tag: []const u8 = if (in_irq) " [irq]" else "";
    core.gba.logPrint(
        "[watch] frame {d}: write{d} [{X:0>8}] = {X:0>8} in func_{X:0>8} (r14={X:0>8}){s}\n",
        .{
            frame_count,
            size_bytes * 8,
            addr,
            value,
            func_ring[(func_ring_i -% 1) & 4095],
            lr,
            tag,
        },
    );
}

pub fn logSwi(number: u32, frame_count: u32, scanline: u32, cycle_counter: u32, regs: *const [16]u32) void {
    if (!has_posix) return;
    if (!swi_log_init) {
        swi_log_init = true;
        if (c_host.getenv("GBA_SWI_LOG")) |e| {
            const s = std.mem.span(e);
            if (std.mem.indexOfScalar(u8, s, ',')) |comma| {
                swi_log_from = std.fmt.parseInt(i64, s[0..comma], 10) catch -1;
                swi_log_to = std.fmt.parseInt(i64, s[comma + 1 ..], 10) catch -1;
            }
        }
    }
    const fc: i64 = @intCast(frame_count);
    if (swi_log_from >= 0 and fc >= swi_log_from and fc <= swi_log_to) {
        core.gba.logPrint("SWI {X:0>2} f={d} v={d} c={d} r0={X:0>8} r1={X:0>8} r2={X:0>8} lr={X:0>8}\n", .{
            number,
            frame_count,
            scanline,
            cycle_counter,
            regs[0],
            regs[1],
            regs[2],
            regs[14],
        });
    }
}

pub fn traceInterpEnter(target: u32, frame_count: u32, regs: *const [16]u32) void {
    if (!has_posix) return;
    if (trace_interp_left < 0) {
        if (c_host.getenv("GBA_TRACE_INTERP")) |e| {
            trace_interp_left = @intCast(c_host.atol(e));
        } else {
            trace_interp_left = 0;
        }
    }
    if (trace_interp_left > 0) {
        trace_interp_left -= 1;
        std.debug.print("[interp] enter 0x{X:0>8} lr=0x{X:0>8} sp=0x{X:0>8} frame={d}\n", .{
            target,
            regs[14],
            regs[13],
            frame_count,
        });
    }
}

pub fn traceCpuBx(target: u32) void {
    bx_trace_count +%= 1;
    if (target != bx_trace_last and bx_trace_count <= 100) {
        core.gba.logPrint("[bx #{d}] -> 0x{X:0>8}\n", .{ bx_trace_count, target });
    }
    bx_trace_last = target;
}

pub fn warnUnmappedArmBx(addr: u32, rm: u32, insn_pc: u32) void {
    if (unmapped_bx_warns < 5) {
        unmapped_bx_warns += 1;
        core.gba.logPrint("[interp] ARM BX to unmapped 0x{X:0>8} (rm=r{d}, pc=0x{X:0>8}) - bailing\n", .{
            addr,
            rm,
            insn_pc,
        });
    }
}

pub fn warnStepLimit(target: u32, steps: usize, pc: u32) void {
    if (interp_limit_warns < 3) {
        interp_limit_warns += 1;
        core.gba.logPrint("[interp] step limit hit at 0x{X:0>8} ({d} steps), pc=0x{X:0>8}\n", .{
            target,
            steps,
            pc,
        });
    }
}

pub fn resetHist() void {
    @memset(&hist, .{});
    hist_n = 0;
    hist_seq = 0;
}

pub fn recordHist(addr: u32) void {
    var h: usize = (addr >> 1) & 16383;
    while (hist[h].addr != 0 and hist[h].addr != addr) {
        h = (h + 1) & 16383;
    }
    if (hist[h].addr == 0) {
        hist[h].addr = addr;
        hist[h].first = hist_seq;
        hist_seq += 1;
        hist_n += 1;
    }
    hist[h].count += 1;
}

fn histLessThan(_: void, a: HistEntry, b: HistEntry) bool {
    return a.first < b.first;
}

pub fn histDump(frame_count: u32, g_hist_on: *c_int) void {
    var n: usize = 0;
    for (hist) |entry| {
        if (entry.addr != 0) {
            hist_out[n] = entry;
            n += 1;
        }
    }
    std.mem.sort(HistEntry, hist_out[0..n], {}, histLessThan);
    core.gba.logPrint("[trace] frame {d}: {d} functions, in first-call order (count):", .{
        frame_count -% 1,
        n,
    });
    for (hist_out[0..n], 0..) |entry, k| {
        const sep: []const u8 = if (k % 6 != 0) " " else "\n  ";
        core.gba.logPrint("{s}{X:0>8}({d})", .{ sep, entry.addr, entry.count });
    }
    core.gba.logPrint("\n", .{});
    resetHist();
    g_hist_on.* = 0;
}

pub fn checkHistFrame(frame_count: u32, g_hist_on: *c_int) void {
    if (!has_posix) return;
    if (!trace_at_init) {
        trace_at_init = true;
        if (c_host.getenv("GBA_FUNC_TRACE_AT")) |e| {
            trace_at_env = std.mem.span(e);
        }
    }
    if (g_hist_on.* != 0) histDump(frame_count, g_hist_on);
    if (trace_at_env) |at_str| {
        var it = std.mem.tokenizeScalar(u8, at_str, ',');
        while (it.next()) |tok| {
            const target_f = std.fmt.parseInt(u32, std.mem.trim(u8, tok, " \t"), 10) catch continue;
            if (target_f == frame_count) {
                g_hist_on.* = 1;
                break;
            }
        }
    }
}

pub fn funcRingDump(frame_count: u32, func_ring: *const [4096]u32, func_ring_i: u32) void {
    var n: usize = 0;
    for (0..4096) |i| {
        const a = func_ring[(func_ring_i +% @as(u32, @intCast(i))) & 4095];
        if (a == 0) continue;
        var k: usize = 0;
        while (k < n and ring_seen[k] != a) : (k += 1) {}
        if (k == n) {
            ring_seen[n] = a;
            ring_count[n] = 0;
            n += 1;
        }
        ring_count[k] += 1;
    }
    core.gba.logPrint("[runtime] frame {d}: last 4096 function entries, distinct (count):", .{frame_count});
    for (0..n) |k| {
        const sep: []const u8 = if (k % 6 != 0) " " else "\n  ";
        core.gba.logPrint("{s}{X:0>8}({d})", .{ sep, ring_seen[k], ring_count[k] });
    }
    core.gba.logPrint("\n", .{});
}

pub fn noteUnwind(
    frame_count: u32,
    retaddr: u32,
    g_ret: u32,
    func_ring: *const [4096]u32,
    func_ring_i: u32,
    g_unwind_trace: *c_int,
) void {
    core.gba.logPrint(
        "[unwind] frame {d}: call site expecting {X:0>8} saw a return to {X:0>8} (last entered func_{X:0>8})\n",
        .{
            frame_count,
            retaddr,
            g_ret,
            func_ring[(func_ring_i -% 1) & 4095],
        },
    );
    g_unwind_trace.* -= 1;
    if (g_unwind_trace.* == 0) {
        core.gba.logPrint("[unwind] (further unwinds not logged)\n", .{});
    }
}

test "diagnostics.recordHist tracks distinct counts and first-call order" {
    resetHist();
    defer resetHist();

    recordHist(0x0800_1000);
    recordHist(0x0800_2000);
    recordHist(0x0800_1000);

    try std.testing.expectEqual(@as(u32, 2), hist_n);
    try std.testing.expectEqual(@as(u32, 2), hist_seq);

    const idx1 = (0x0800_1000 >> 1) & 16383;
    const idx2 = (0x0800_2000 >> 1) & 16383;
    try std.testing.expectEqual(@as(u32, 2), hist[idx1].count);
    try std.testing.expectEqual(@as(u32, 0), hist[idx1].first);
    try std.testing.expectEqual(@as(u32, 1), hist[idx2].count);
    try std.testing.expectEqual(@as(u32, 1), hist[idx2].first);

    resetHist();
    try std.testing.expectEqual(@as(u32, 0), hist_n);
    try std.testing.expectEqual(@as(u32, 0), hist_seq);
    try std.testing.expectEqual(@as(u32, 0), hist[idx1].addr);
}
