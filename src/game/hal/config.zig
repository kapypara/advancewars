//! Compile-time HAL backend configuration (`gba_validate` vs `native`).

const std = @import("std");
const rt = @import("runtime");

pub const Backend = enum {
    gba_validate,
    native,
};

pub const backend: Backend = if (rt.native_hal) .native else .gba_validate;
pub const is_native: bool = backend == .native;
pub const trace_enabled: bool = rt.enable_trace;

test "hal.config backend matches runtime native_hal option" {
    const expected: Backend = if (rt.native_hal) .native else .gba_validate;
    try std.testing.expectEqual(expected, backend);
    try std.testing.expectEqual(rt.native_hal, is_native);
    try std.testing.expectEqual(rt.enable_trace, trace_enabled);
}
