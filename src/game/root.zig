//! Native Zig game decompilation root module, compiled side-by-side with `gen/`.
//! Any strong `pub export fn func_080XXXXX()` symbol referenced here overrides the
//! corresponding weak fallback emitted by `gen/`.

pub const abi = @import("abi.zig");
pub const types = @import("types.zig");
pub const bios = @import("bios.zig");
pub const math = @import("math.zig");
pub const dma = @import("dma.zig");

comptime {
    _ = abi;
    _ = types;
    _ = bios;
    _ = math;
    _ = dma;
}

test {
    _ = abi;
    _ = types;
    _ = bios;
    _ = math;
    _ = dma;
}
