const std = @import("std");
const builtin = @import("builtin");
const core = @import("awre_core");

const HwTimer = core.timers.HwTimer;
const BusMode = core.dma.BusMode;

const has_host_validate = builtin.os.tag != .freestanding and !builtin.is_test;
const cycles_per_frame: u32 = 1232 * 228;

const host_jmp = if (has_host_validate) struct {
    extern "c" fn awre_validate_call0(func: *const fn () callconv(.c) void) c_int;
    extern "c" fn awre_validate_call_u32(func: *const fn (u32) callconv(.c) void, arg: u32) c_int;
    extern "c" fn awre_validate_abort() noreturn;
    extern "c" fn getenv(name: [*:0]const u8) ?[*:0]const u8;
    extern "c" fn strtoul(nptr: [*:0]const u8, endptr: ?*?[*]u8, base: c_int) c_ulong;
    extern "c" fn strchr(s: [*:0]const u8, c: c_int) ?[*:0]const u8;
    extern "c" fn atol(nptr: [*:0]const u8) c_long;

    var pending_call_u32: ?*const fn (u32) void = null;

    fn trampolineCallU32(arg: u32) callconv(.c) void {
        if (pending_call_u32) |f| f(arg);
    }
} else struct {};

pub const MachineState = struct {
    ewram: [0x40000]u8 = @splat(0),
    iwram: [0x8000]u8 = @splat(0),
    io: [0x400]u8 = @splat(0),
    pal: [0x400]u8 = @splat(0),
    vram: [0x18000]u8 = @splat(0),
    oam: [0x400]u8 = @splat(0),
    r: [16]u32 = @splat(0),
    n: bool = false,
    z: bool = false,
    c: bool = false,
    v: bool = false,
    cpsr: u32 = 0,
    spsr: u32 = 0,
    cycle_counter: u32 = 0,
    scanline: u32 = 0,
    scanline_cycles: u32 = 0,
    hblank_done: u32 = 0,
    last_poll_cycle: u32 = 0,
    frame_count: u32 = 0,
    timers: [4]HwTimer = @splat(.{}),
    bus_mode: BusMode = .rom_code,
    cycle_credit: i32 = 0,
    vram_burst: bool = false,
};

const SeenEntry = struct {
    addr: u32 = 0,
    calls: u16 = 0,
    failed: bool = false,
    seen: u32 = 0,
};

var v_seen: [32768]SeenEntry = @splat(.{});
var v_funcs: i32 = 0;
var v_fail: i32 = 0;

pub var g_validating: bool = false;
pub var validate_deadline: u32 = 0;

var s0: MachineState = .{};
var s_native: MachineState = .{};
var s_interp: MachineState = .{};

var filter_init: bool = false;
var filter_lo: u32 = 0;
var filter_hi: u32 = 0xFFFF_FFFF;
var filter_from: u32 = 0;
var every_init: bool = false;
var validate_every: u32 = 1;

fn firstDiff(a: []const u8, b: []const u8, skip_lo: usize, skip_hi: usize) ?usize {
    for (a, b, 0..) |ba, bb, i| {
        if (ba != bb and !(i >= skip_lo and i < skip_hi)) return i;
    }
    return null;
}

pub inline fn checkDeadline(cycle_counter: u32) void {
    if (!has_host_validate) return;
    if (g_validating and @as(i32, @bitCast(cycle_counter -% validate_deadline)) > 0) {
        host_jmp.awre_validate_abort();
    }
}

pub fn printSummary(enabled: bool) void {
    if (!has_host_validate or !enabled) return;
    core.gba.logPrint("validate: {d}/{d} functions agree (native vs interpreter)\n", .{
        v_funcs - v_fail,
        v_funcs,
    });
}

pub fn runValidate(
    addr: u32,
    g_validate_val: c_int,
    in_irq: bool,
    frame_count: u32,
    host: anytype,
    run_iwram_fn: *const fn (u32) void,
) c_int {
    if (!has_host_validate) return 0;
    if (g_validating or in_irq) return 0;

    if (!filter_init) {
        filter_init = true;
        if (host_jmp.getenv("GBA_VALIDATE_RANGE")) |r_env| {
            filter_lo = @truncate(host_jmp.strtoul(r_env, null, 16));
            if (host_jmp.strchr(r_env, '-')) |dash| {
                const after: [*:0]const u8 = @ptrCast(dash + 1);
                filter_hi = @truncate(host_jmp.strtoul(after, null, 16));
            }
        }
        if (host_jmp.getenv("GBA_VALIDATE_FROM")) |f_env| {
            filter_from = @truncate(@as(u64, @bitCast(@as(i64, host_jmp.atol(f_env)))));
        }
    }
    if (addr < filter_lo or addr > filter_hi or frame_count < filter_from) return 0;

    var h: usize = (addr >> 1) & 32767;
    while (v_seen[h].addr != 0 and v_seen[h].addr != addr) {
        h = (h + 1) & 32767;
    }
    if (v_seen[h].addr == 0) {
        v_seen[h].addr = addr;
        v_funcs += 1;
    }
    const max_calls: u16 = if (g_validate_val <= 0) 0 else @intCast(@min(g_validate_val, 0xFFFF));
    if (v_seen[h].calls >= max_calls or v_seen[h].failed) return 0;

    if (!every_init) {
        every_init = true;
        if (host_jmp.getenv("GBA_VALIDATE_EVERY")) |e_env| {
            const parsed = host_jmp.atol(e_env);
            validate_every = if (parsed > 0) @intCast(parsed) else 1;
        }
    }
    const seen_now = v_seen[h].seen;
    v_seen[h].seen +%= 1;
    if (seen_now % validate_every != 0) return 0;

    v_seen[h].calls += 1;

    const target = host.recompLookup(addr);
    const native_fn = host.recompLookupFn(addr) orelse return 0;

    g_validating = true;
    host.stateSave(&s0);
    const bx_depth0 = host.getBxDepth();
    const sp0 = host.regs()[13];
    const lr0 = host.regs()[14];

    validate_deadline = host.getCycleCounter() +% 2 * cycles_per_frame;
    host.setRet(0);
    if (host_jmp.awre_validate_call0(native_fn) != 0) {
        host.stateLoad(&s0);
        host.setBxDepth(bx_depth0);
        host.setRet(0);
        v_seen[h].calls = 0xFFFF;
        g_validating = false;
        return 0;
    }
    const ret_native = host.getRet();
    host.stateSave(&s_native);

    host.stateLoad(&s0);
    validate_deadline = host.getCycleCounter() +% 2 * cycles_per_frame;
    host.setRet(0);
    host_jmp.pending_call_u32 = run_iwram_fn;
    if (host_jmp.awre_validate_call_u32(host_jmp.trampolineCallU32, target) != 0) {
        host.stateLoad(&s0);
        host.setBxDepth(bx_depth0);
        host.setRet(0);
        v_seen[h].calls = 0xFFFF;
        g_validating = false;
        return 0;
    }

    const r_live = host.regs();
    for (0..15) |i| {
        if ((r_live[i] & ~@as(u32, 1)) == 0xDEAD_0000) r_live[i] = lr0;
    }
    r_live[14] = s_native.r[14];
    host.stateSave(&s_interp);

    const stk_hi: usize = sp0 & 0x7FFF;
    const stk_lo: usize = if (stk_hi > 0x800) stk_hi - 0x800 else 0;
    var why_buf: [160]u8 = undefined;
    var why: []const u8 = "";

    for (0..14) |i| {
        if (s_native.r[i] != s_interp.r[i]) {
            why = std.fmt.bufPrint(&why_buf, "r{d} native={X:0>8} interp={X:0>8}", .{
                i,
                s_native.r[i],
                s_interp.r[i],
            }) catch "reg diff";
            break;
        }
    }
    if (why.len == 0) {
        if (firstDiff(&s_native.ewram, &s_interp.ewram, 1, 0)) |d| {
            why = std.fmt.bufPrint(&why_buf, "EWRAM {X:0>8} native={X:0>2} interp={X:0>2}", .{
                0x0200_0000 + d,
                s_native.ewram[d],
                s_interp.ewram[d],
            }) catch "EWRAM diff";
        }
    }
    if (why.len == 0) {
        if (firstDiff(&s_native.iwram, &s_interp.iwram, stk_lo, stk_hi)) |d| {
            why = std.fmt.bufPrint(&why_buf, "IWRAM {X:0>8} native={X:0>2} interp={X:0>2}", .{
                0x0300_0000 + d,
                s_native.iwram[d],
                s_interp.iwram[d],
            }) catch "IWRAM diff";
        }
    }
    if (why.len == 0) {
        if (firstDiff(&s_native.pal, &s_interp.pal, 1, 0)) |d| {
            why = std.fmt.bufPrint(&why_buf, "PAL +{X:0>3}", .{d}) catch "PAL diff";
        }
    }
    if (why.len == 0) {
        if (firstDiff(&s_native.vram, &s_interp.vram, 1, 0)) |d| {
            why = std.fmt.bufPrint(&why_buf, "VRAM +{X:0>5}", .{d}) catch "VRAM diff";
        }
    }
    if (why.len == 0) {
        if (firstDiff(&s_native.oam, &s_interp.oam, 1, 0)) |d| {
            why = std.fmt.bufPrint(&why_buf, "OAM +{X:0>3}", .{d}) catch "OAM diff";
        }
    }
    if (why.len > 0) {
        v_seen[h].failed = true;
        v_fail += 1;
        core.gba.logPrint("VALIDATE {X:0>8} FAIL {s} (sp={X:0>8} lr={X:0>8} frame={d})\n", .{
            addr,
            why,
            sp0,
            lr0,
            frame_count,
        });
    }

    host.stateLoad(&s_native);
    host.setRet(ret_native);
    g_validating = false;
    return 1;
}
