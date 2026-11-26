pub const display = @import("display_abi.zig");
pub const runtime = @import("runtime_abi.zig");

comptime {
    _ = display;
    _ = runtime;
}
