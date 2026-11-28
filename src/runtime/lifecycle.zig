//! Runtime lifecycle: embedded/host ROM loading, Flash/EEPROM detection, init, shutdown, and WASM buffers.

const std = @import("std");
const builtin = @import("builtin");
const core = @import("awre_core");
const rt_options = @import("rt_options");
const disp = @import("../platform/display.zig");
const validate_mod = @import("../validate/validate.zig");
const diagnostics = @import("diagnostics.zig");
const save_io = @import("save_io.zig");
const state = @import("state.zig");

const has_posix = builtin.os.tag != .freestanding;

const c_host = if (has_posix) struct {
    const FILE = std.c.FILE;
    extern "c" fn getenv(name: [*:0]const u8) ?[*:0]const u8;
    extern "c" fn fopen(filename: [*:0]const u8, mode: [*:0]const u8) ?*FILE;
    extern "c" fn fclose(stream: *FILE) c_int;
    extern "c" fn fread(ptr: [*]u8, size: usize, nmemb: usize, stream: *FILE) usize;
    extern "c" fn fseek(stream: *FILE, offset: c_long, whence: c_int) c_int;
    extern "c" fn ftell(stream: *FILE) c_long;
    extern "c" fn malloc(size: usize) ?[*]u8;
    extern "c" fn free(ptr: ?*anyopaque) void;
    extern "c" fn exit(status: c_int) noreturn;
    extern "c" fn atoi(nptr: [*:0]const u8) c_int;
} else struct {
    const FILE = opaque {};
};

const embedded_rom_bytes: []const u8 = if (rt_options.has_embedded_rom) @embedFile("embedded_rom") else &.{};
const wasm_rom_max: usize = 16 * 1024 * 1024;
var wasm_rom_buf: if (!has_posix) [wasm_rom_max]u8 else [0]u8 = @splat(0);

pub fn hasEmbeddedRom() bool {
    return embedded_rom_bytes.len > 0;
}

pub fn wasmRomBufPtr() [*]u8 {
    return if (!has_posix) &wasm_rom_buf else state.sram_buf[0..1].ptr;
}

pub fn wasmRomBufCap() u32 {
    return wasm_rom_max;
}

pub fn wasmSramBufPtr() [*]u8 {
    return &state.sram_buf;
}

pub fn wasmSramSize() u32 {
    return state.flash_state.backup_size;
}

pub fn wasmMarkSramClean() void {
    state.flash_state.dirty = false;
    state.flash_state.write_seq = 0;
    state.sram_last_seq = 0;
    state.sram_dirty_frames = 0;
}

pub fn initPostRomRegs(regs: *[16]u32) void {
    @memset(regs, 0);
    regs[13] = 0x0300_7F00;
    regs[15] = 0x0800_0000;
    state.cpsr = 0x0000_001F;
    state.spsr = 0;

    // KEYINPUT active-low all released, default SOUNDBIAS = 0x0200, SIOMULTI pull-ups 0xFFFF
    state.io_regs_buf[0x130] = 0xFF;
    state.io_regs_buf[0x131] = 0x03;
    state.platform_keyinput = 0x03FF;
    state.io_regs_buf[0x088] = 0x00;
    state.io_regs_buf[0x089] = 0x02;
    @memset(state.io_regs_buf[0x120..0x128], 0xFF);
}

pub fn initMemory(comptime Rt: type, rom_len: u32) bool {
    if (rom_len > wasm_rom_max) return false;
    state.resetCommon();
    Rt.bindMemoryPtrs();

    const rom_slice: []const u8 = if (rom_len > 0)
        (if (!has_posix) wasm_rom_buf[0..rom_len] else &.{})
    else
        embedded_rom_bytes;
    if (rom_slice.len == 0) return false;

    state.rom_ptr = rom_slice.ptr;
    state.rom_size = @intCast(rom_slice.len);
    state.rom_owned = false;

    if (state.flash_state.detect(rom_slice) != null) {
        @memset(state.sram_buf[0..state.flash_state.backup_size], 0xFF);
    }
    state.flash_state.dirty = false;
    state.flash_state.write_seq = 0;
    state.sram_last_seq = 0;

    _ = state.eeprom_state.detect(rom_slice);
    state.eeprom_state.dirty = false;
    state.eeprom_state.write_seq = 0;
    state.eeprom_last_seq = 0;

    initPostRomRegs(Rt.regs());
    return disp.display_init() == 0;
}

pub fn initHost(
    comptime Rt: type,
    rom_path_opt: ?[*:0]const u8,
    save_path_opt: ?[*:0]const u8,
    exe_arg0: ?[*:0]const u8,
) void {
    if (!has_posix) return;

    if (c_host.getenv("GBA_VALIDATE")) |e| state.g_validate = c_host.atoi(e);
    if (c_host.getenv("GBA_TRACE_UNWIND")) |e| state.g_unwind_trace = c_host.atoi(e);

    state.resetCommon();
    Rt.bindMemoryPtrs();

    var rom_slice: []const u8 = undefined;
    var default_base: []const u8 = undefined;
    var rom_label: []const u8 = undefined;

    if (rom_path_opt) |rom_path_c| {
        const f = c_host.fopen(rom_path_c, "rb") orelse {
            core.gba.logPrint("[runtime] Cannot open ROM: {s}\n", .{std.mem.span(rom_path_c)});
            c_host.exit(1);
        };
        _ = c_host.fseek(f, 0, 2); // SEEK_END
        const raw_len = c_host.ftell(f);
        if (raw_len <= 0) {
            _ = c_host.fclose(f);
            core.gba.logPrint("[runtime] Empty or unreadable ROM: {s}\n", .{std.mem.span(rom_path_c)});
            c_host.exit(1);
        }
        state.rom_size = @intCast(raw_len);
        _ = c_host.fseek(f, 0, 0); // SEEK_SET
        const mem = c_host.malloc(state.rom_size) orelse {
            _ = c_host.fclose(f);
            core.gba.logPrint("[runtime] Failed to allocate ROM buffer ({d} bytes)\n", .{state.rom_size});
            c_host.exit(1);
        };
        if (c_host.fread(mem, 1, state.rom_size, f) != state.rom_size) {
            _ = c_host.fclose(f);
            core.gba.logPrint("[runtime] Failed to read ROM\n", .{});
            c_host.exit(1);
        }
        _ = c_host.fclose(f);
        state.rom_ptr = mem;
        state.rom_owned = true;
        rom_slice = mem[0..state.rom_size];
        default_base = std.mem.span(rom_path_c);
        rom_label = default_base;
    } else if (embedded_rom_bytes.len > 0) {
        state.rom_ptr = embedded_rom_bytes.ptr;
        state.rom_size = @intCast(embedded_rom_bytes.len);
        state.rom_owned = false;
        rom_slice = embedded_rom_bytes;
        default_base = save_io.resolveSelfExePath(exe_arg0, &state.exe_path_buf);
        rom_label = "embedded";
    } else {
        core.gba.logPrint("[runtime] No ROM embedded and no ROM path given. Usage: awre <rom.gba> [options]\n", .{});
        c_host.exit(1);
    }

    if (save_path_opt) |sp| {
        const sp_slice = std.mem.span(sp);
        const formatted = std.mem.printSentinel(&state.sram_path_buf, "{s}", .{sp_slice}, 0) catch "";
        state.sram_path_len = formatted.len;
    } else {
        state.sram_path_len = save_io.buildSidecarPath(default_base, ".sav", &state.sram_path_buf);
    }
    if (state.flash_state.detect(rom_slice)) |tag| {
        const size_label: []const u8 = if (state.flash_state.large) "128KB" else "64KB";
        core.gba.logPrint("[runtime] Flash {s} detected ({s})\n", .{ size_label, tag });
        @memset(state.sram_buf[0..state.flash_state.backup_size], 0xFF);
    }
    save_io.sramLoad();
    state.flash_state.dirty = false;
    state.flash_state.write_seq = 0;
    state.sram_last_seq = 0;

    if (state.eeprom_state.detect(rom_slice)) |ee_addr| {
        core.gba.logPrint("[runtime] EEPROM detected at ROM 0x{X:0>8} (assuming 8KB)\n", .{ee_addr});
        const ee_base = if (save_path_opt) |sp| std.mem.span(sp) else default_base;
        state.eeprom_path_len = save_io.buildSidecarPath(ee_base, ".eep", &state.eeprom_path_buf);
        save_io.eepromLoad();
        state.eeprom_state.dirty = false;
        state.eeprom_state.write_seq = 0;
        state.eeprom_last_seq = 0;
    }

    initPostRomRegs(Rt.regs());

    core.gba.logPrint("[runtime] GBA static recomp runtime initialized\n", .{});
    core.gba.logPrint("[runtime] ROM: {d} bytes ({s})\n", .{ state.rom_size, rom_label });
    if (state.sram_path_len > 0) {
        core.gba.logPrint("[runtime] Save path: {s}\n", .{state.sram_path_buf[0..state.sram_path_len]});
    }

    if (disp.display_init() != 0) {
        core.gba.logPrint("[runtime] Failed to initialize display\n", .{});
        c_host.exit(1);
    }
}

pub fn shutdown(comptime Rt: type) void {
    if (has_posix) {
        if (c_host.getenv("GBA_FUNC_TRACE") != null) {
            diagnostics.funcRingDump(state.frame_count, &state.g_func_ring, state.g_func_ring_i);
        }
    }
    validate_mod.printSummary(state.g_validate != 0);
    save_io.sramSave();
    save_io.eepromSave();
    disp.display_shutdown();

    Rt.clearMemoryPtrs();
    state.sram_active = false;
    state.bios_mem_ptr = null;

    if (has_posix) {
        if (state.rom_owned) {
            if (state.rom_ptr) |ptr| {
                c_host.free(@constCast(ptr));
            }
        }
        state.rom_ptr = null;
        state.rom_owned = false;
    }
    state.rom_size = 0;
    core.gba.logPrint("[runtime] Shutdown\n", .{});
}

test "lifecycle.initPostRomRegs sets GBA initial SP, PC, CPSR, KEYINPUT, and SOUNDBIAS" {
    state.resetCommon();
    defer state.resetCommon();

    var regs: [16]u32 = @splat(0xDEAD_BEEF);
    initPostRomRegs(&regs);

    try std.testing.expectEqual(@as(u32, 0), regs[0]);
    try std.testing.expectEqual(@as(u32, 0x0300_7F00), regs[13]);
    try std.testing.expectEqual(@as(u32, 0x0800_0000), regs[15]);
    try std.testing.expectEqual(@as(u32, 0x0000_001F), state.cpsr);
    try std.testing.expectEqual(@as(u16, 0x03FF), state.ioRead16(0x130));
    try std.testing.expectEqual(@as(u16, 0x0200), state.ioRead16(0x088));
}
