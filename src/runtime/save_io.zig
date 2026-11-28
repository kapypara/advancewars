//! Host save-file path resolution and atomic persistence helpers.

const std = @import("std");
const builtin = @import("builtin");

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

test "save_io.buildSidecarPath handles extensions and directory dots" {
    var buf: [512]u8 = undefined;
    const len1 = buildSidecarPath("game/aw.gba", ".sav", &buf);
    try std.testing.expectEqualStrings("game/aw.sav", buf[0..len1]);

    const len2 = buildSidecarPath("dir.v1/aw", ".eep", &buf);
    try std.testing.expectEqualStrings("dir.v1/aw.eep", buf[0..len2]);

    const len3 = buildSidecarPath("C:\\roms\\aw.gba", ".sav", &buf);
    try std.testing.expectEqualStrings("C:\\roms\\aw.sav", buf[0..len3]);
}
