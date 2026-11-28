//! Host save-file path resolution, backup persistence (SRAM/Flash/EEPROM), and snapshot dumps.

const std = @import("std");
const builtin = @import("builtin");
const core = @import("awre_core");
const state = @import("state.zig");

const has_posix = builtin.os.tag != .freestanding;

pub const save_debounce_frames: u32 = 30;

const c_host = if (has_posix) struct {
    const FILE = std.c.FILE;
    extern "c" fn fopen(filename: [*:0]const u8, mode: [*:0]const u8) ?*FILE;
    extern "c" fn fclose(stream: *FILE) c_int;
    extern "c" fn fread(ptr: [*]u8, size: usize, nmemb: usize, stream: *FILE) usize;
    extern "c" fn fwrite(ptr: [*]const u8, size: usize, nmemb: usize, stream: *FILE) usize;
    extern "c" fn readlink(pathname: [*:0]const u8, buf: [*]u8, bufsiz: usize) isize;
    extern "c" fn rename(oldpath: [*:0]const u8, newpath: [*:0]const u8) c_int;
    extern "c" fn remove(pathname: [*:0]const u8) c_int;
} else struct {
    const FILE = opaque {};
};

pub fn buildSidecarPath(base_slice: []const u8, ext: []const u8, dst: *[512]u8) usize {
    const max_base = 507;
    const truncated = if (base_slice.len > max_base) base_slice[0..max_base] else base_slice;
    const last_fwd = std.mem.lastIndexOfScalar(u8, truncated, '/');
    const last_back = std.mem.lastIndexOfScalar(u8, truncated, '\\');
    const sep_end: usize = blk: {
        if (last_fwd != null and last_back != null) break :blk @max(last_fwd.?, last_back.?) + 1;
        if (last_fwd) |i| break :blk i + 1;
        if (last_back) |i| break :blk i + 1;
        break :blk 0;
    };
    const stem = if (std.mem.lastIndexOfScalar(u8, truncated, '.')) |dot_idx|
        if (dot_idx > sep_end) truncated[0..dot_idx] else truncated
    else
        truncated;
    const formatted = std.mem.printSentinel(dst, "{s}{s}", .{ stem, ext }, 0) catch return 0;
    return formatted.len;
}

pub fn resolveSelfExePath(exe_arg0: ?[*:0]const u8, dst: *[512]u8) []const u8 {
    if (has_posix) {
        const n = c_host.readlink("/proc/self/exe", dst, dst.len - 1);
        if (n > 0) {
            const len: usize = @intCast(n);
            dst[len] = 0;
            return dst[0..len];
        }
        if (exe_arg0) |arg0| {
            const span = std.mem.span(arg0);
            const copy_len = @min(span.len, dst.len - 1);
            @memcpy(dst[0..copy_len], span[0..copy_len]);
            dst[copy_len] = 0;
            return dst[0..copy_len];
        }
    }
    return "awre";
}

pub fn writeAtomicFile(final_path_c: [*:0]const u8, final_slice: []const u8, data: []const u8) bool {
    if (!has_posix) return false;
    var tmp_buf: [520]u8 = undefined;
    const tmp_slice = std.mem.printSentinel(&tmp_buf, "{s}.tmp", .{final_slice}, 0) catch return false;
    const f = c_host.fopen(tmp_slice.ptr, "wb") orelse return false;
    const written = c_host.fwrite(data.ptr, 1, data.len, f);
    const close_rc = c_host.fclose(f);
    if (written != data.len or close_rc != 0) {
        _ = c_host.remove(tmp_slice.ptr);
        return false;
    }
    if (c_host.rename(tmp_slice.ptr, final_path_c) != 0) {
        _ = c_host.remove(tmp_slice.ptr);
        return false;
    }
    return true;
}

pub fn readFileInto(path: [*:0]const u8, dst: []u8) bool {
    if (!has_posix) return false;
    const f = c_host.fopen(path, "rb") orelse return false;
    defer _ = c_host.fclose(f);
    _ = c_host.fread(dst.ptr, 1, dst.len, f);
    return true;
}

pub fn pollBackupFlush() void {
    if (state.flash_state.dirty) {
        if (state.flash_state.write_seq != state.sram_last_seq) {
            state.sram_last_seq = state.flash_state.write_seq;
            state.sram_dirty_frames = save_debounce_frames;
        } else if (state.sram_dirty_frames > 0) {
            state.sram_dirty_frames -= 1;
            if (state.sram_dirty_frames == 0) sramSave();
        }
    }
    if (state.eeprom_state.dirty) {
        if (state.eeprom_state.write_seq != state.eeprom_last_seq) {
            state.eeprom_last_seq = state.eeprom_state.write_seq;
            state.eeprom_dirty_frames = save_debounce_frames;
        } else if (state.eeprom_dirty_frames > 0) {
            state.eeprom_dirty_frames -= 1;
            if (state.eeprom_dirty_frames == 0) eepromSave();
        }
    }
}

pub fn sramLoad() void {
    if (!has_posix or !state.sram_active or state.sram_path_len == 0) return;
    const path: [*:0]const u8 = @ptrCast(&state.sram_path_buf);
    if (!readFileInto(path, state.sram_buf[0..state.flash_state.backup_size])) return;
    core.gba.logPrint("[runtime] Loaded SRAM from {s}\n", .{state.sram_path_buf[0..state.sram_path_len]});
}

pub fn sramSave() void {
    if (!state.sram_active or !state.flash_state.dirty) return;
    if (!has_posix) {
        core.platform.WasmBackend.saveSram(&state.sram_buf, state.flash_state.backup_size);
        state.flash_state.dirty = false;
        state.sram_dirty_frames = 0;
        return;
    }
    if (state.sram_path_len == 0) return;
    const path_slice = state.sram_path_buf[0..state.sram_path_len];
    const path: [*:0]const u8 = @ptrCast(&state.sram_path_buf);
    if (writeAtomicFile(path, path_slice, state.sram_buf[0..state.flash_state.backup_size])) {
        state.flash_state.dirty = false;
        state.sram_dirty_frames = 0;
        core.gba.logPrint("[runtime] Saved Flash to {s}\n", .{path_slice});
    }
}

pub fn eepromLoad() void {
    if (!has_posix or !state.eeprom_state.present or state.eeprom_path_len == 0) return;
    const path: [*:0]const u8 = @ptrCast(&state.eeprom_path_buf);
    if (!readFileInto(path, &state.eeprom_state.storage)) return;
    core.gba.logPrint("[runtime] Loaded EEPROM from {s}\n", .{state.eeprom_path_buf[0..state.eeprom_path_len]});
}

pub fn eepromSave() void {
    if (!has_posix or !state.eeprom_state.present or state.eeprom_path_len == 0 or !state.eeprom_state.dirty) return;
    const path_slice = state.eeprom_path_buf[0..state.eeprom_path_len];
    const path: [*:0]const u8 = @ptrCast(&state.eeprom_path_buf);
    if (writeAtomicFile(path, path_slice, &state.eeprom_state.storage)) {
        state.eeprom_state.dirty = false;
        state.eeprom_dirty_frames = 0;
        core.gba.logPrint("[runtime] Saved EEPROM to {s}\n", .{path_slice});
    }
}

pub fn writeDumpAtSnapshot(dump_path: ?[*:0]const u8) void {
    if (!has_posix) return;
    const dp = dump_path orelse return;
    const df = c_host.fopen(dp, "wb") orelse return;
    defer _ = c_host.fclose(df);
    _ = c_host.fwrite(&state.ewram_buf, 1, state.ewram_buf.len, df);
    _ = c_host.fwrite(&state.iwram_buf, 1, state.iwram_buf.len, df);
    _ = c_host.fwrite(&state.io_regs_buf, 1, state.io_regs_buf.len, df);
    _ = c_host.fwrite(&state.palette_buf, 1, state.palette_buf.len, df);
    _ = c_host.fwrite(&state.vram_buf, 1, state.vram_buf.len, df);
    _ = c_host.fwrite(&state.oam_buf, 1, state.oam_buf.len, df);
}

pub fn nativeSaveRead(offset: u32) u8 {
    if (!state.sram_active) return 0;
    return state.sram_buf[offset & 0xFFFF];
}

pub fn nativeSaveWrite(offset: u32, val: u8) void {
    if (!state.sram_active) return;
    const off: usize = offset & 0xFFFF;
    if (state.sram_buf[off] != val) {
        state.sram_buf[off] = val;
        state.flash_state.dirty = true;
        state.flash_state.write_seq +%= 1;
    }
}

pub fn nativeSaveEraseSector(sector: u8) void {
    if (!state.sram_active) return;
    const sec_off: usize = @as(usize, sector & 0x0F) * 0x1000;
    const sec = state.sram_buf[sec_off .. sec_off + 0x1000];
    if (std.mem.indexOfNone(u8, sec, &.{0xFF}) != null) {
        @memset(sec, 0xFF);
        state.flash_state.dirty = true;
        state.flash_state.write_seq +%= 1;
    }
}

pub fn nativeSaveEraseChip() void {
    if (!state.sram_active) return;
    const size = @min(@as(usize, state.flash_state.backup_size), state.sram_buf.len);
    const chip = state.sram_buf[0..size];
    if (std.mem.indexOfNone(u8, chip, &.{0xFF}) != null) {
        @memset(chip, 0xFF);
        state.flash_state.dirty = true;
        state.flash_state.write_seq +%= 1;
    }
}

test "save_io.buildSidecarPath handles extensions and directory dots" {
    var buf: [512]u8 = undefined;
    const len1 = buildSidecarPath("game/aw.gba", ".sav", &buf);
    try std.testing.expectEqualStrings("game/aw.sav", buf[0..len1]);

    const len2 = buildSidecarPath("dir.v1/aw", ".eep", &buf);
    try std.testing.expectEqualStrings("dir.v1/aw.eep", buf[0..len2]);

    const len3 = buildSidecarPath("C:\\roms\\aw.gba", ".sav", &buf);
    try std.testing.expectEqualStrings("C:\\roms\\aw.sav", buf[0..len3]);
}

test "save_io native 64KB direct save read, write, sector erase, and chip erase" {
    state.resetCommon();
    defer state.resetCommon();

    nativeSaveWrite(0x0042, 0x5A);
    nativeSaveWrite(0x1042, 0xA5);
    try std.testing.expectEqual(@as(u8, 0x5A), nativeSaveRead(0x0042));
    try std.testing.expectEqual(@as(u8, 0xA5), nativeSaveRead(0x1042));
    try std.testing.expect(state.flash_state.dirty);
    const seq1 = state.flash_state.write_seq;

    // Identical write does not bump dirty/write_seq
    state.flash_state.dirty = false;
    nativeSaveWrite(0x0042, 0x5A);
    try std.testing.expect(!state.flash_state.dirty);
    try std.testing.expectEqual(seq1, state.flash_state.write_seq);

    // Erase sector 0 clears 0x0042 while preserving sector 1 (0x1042)
    nativeSaveEraseSector(0);
    try std.testing.expectEqual(@as(u8, 0xFF), nativeSaveRead(0x0042));
    try std.testing.expectEqual(@as(u8, 0xA5), nativeSaveRead(0x1042));
    try std.testing.expect(state.flash_state.dirty);

    // Full 64KB chip erase clears sector 1 as well; second erase is idempotent
    nativeSaveEraseChip();
    try std.testing.expectEqual(@as(u8, 0xFF), nativeSaveRead(0x1042));
    state.flash_state.dirty = false;
    const seq2 = state.flash_state.write_seq;
    nativeSaveEraseChip();
    try std.testing.expect(!state.flash_state.dirty);
    try std.testing.expectEqual(seq2, state.flash_state.write_seq);
}
