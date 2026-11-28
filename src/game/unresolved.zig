// Unresolved branch/veneer trap stubs (78 targets)
const std = @import("std");
const builtin = @import("builtin");

fn impl_func_080419A8() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_080419A8 called\n", .{});
    }
}
comptime { @export(&impl_func_080419A8, .{ .name = "func_080419A8", .linkage = .weak }); }

fn impl_func_0804B728() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0804B728 called\n", .{});
    }
}
comptime { @export(&impl_func_0804B728, .{ .name = "func_0804B728", .linkage = .weak }); }

fn impl_func_0807B48C() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0807B48C called\n", .{});
    }
}
comptime { @export(&impl_func_0807B48C, .{ .name = "func_0807B48C", .linkage = .weak }); }

fn impl_func_0807B510() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0807B510 called\n", .{});
    }
}
comptime { @export(&impl_func_0807B510, .{ .name = "func_0807B510", .linkage = .weak }); }

fn impl_func_0807B56E() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0807B56E called\n", .{});
    }
}
comptime { @export(&impl_func_0807B56E, .{ .name = "func_0807B56E", .linkage = .weak }); }

fn impl_func_0807B6B8() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0807B6B8 called\n", .{});
    }
}
comptime { @export(&impl_func_0807B6B8, .{ .name = "func_0807B6B8", .linkage = .weak }); }

fn impl_func_080B5D86() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_080B5D86 called\n", .{});
    }
}
comptime { @export(&impl_func_080B5D86, .{ .name = "func_080B5D86", .linkage = .weak }); }

fn impl_func_08132798() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08132798 called\n", .{});
    }
}
comptime { @export(&impl_func_08132798, .{ .name = "func_08132798", .linkage = .weak }); }

fn impl_func_08142328() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08142328 called\n", .{});
    }
}
comptime { @export(&impl_func_08142328, .{ .name = "func_08142328", .linkage = .weak }); }

fn impl_func_081490AE() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081490AE called\n", .{});
    }
}
comptime { @export(&impl_func_081490AE, .{ .name = "func_081490AE", .linkage = .weak }); }

fn impl_func_08156928() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08156928 called\n", .{});
    }
}
comptime { @export(&impl_func_08156928, .{ .name = "func_08156928", .linkage = .weak }); }

fn impl_func_0815F5A6() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0815F5A6 called\n", .{});
    }
}
comptime { @export(&impl_func_0815F5A6, .{ .name = "func_0815F5A6", .linkage = .weak }); }

fn impl_func_0815FAD6() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0815FAD6 called\n", .{});
    }
}
comptime { @export(&impl_func_0815FAD6, .{ .name = "func_0815FAD6", .linkage = .weak }); }

fn impl_func_0815FB02() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0815FB02 called\n", .{});
    }
}
comptime { @export(&impl_func_0815FB02, .{ .name = "func_0815FB02", .linkage = .weak }); }

fn impl_func_0815FC12() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0815FC12 called\n", .{});
    }
}
comptime { @export(&impl_func_0815FC12, .{ .name = "func_0815FC12", .linkage = .weak }); }

fn impl_func_081600EC() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081600EC called\n", .{});
    }
}
comptime { @export(&impl_func_081600EC, .{ .name = "func_081600EC", .linkage = .weak }); }

fn impl_func_081601CE() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081601CE called\n", .{});
    }
}
comptime { @export(&impl_func_081601CE, .{ .name = "func_081601CE", .linkage = .weak }); }

fn impl_func_081601D8() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081601D8 called\n", .{});
    }
}
comptime { @export(&impl_func_081601D8, .{ .name = "func_081601D8", .linkage = .weak }); }

fn impl_func_081601DE() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081601DE called\n", .{});
    }
}
comptime { @export(&impl_func_081601DE, .{ .name = "func_081601DE", .linkage = .weak }); }

fn impl_func_0816035E() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0816035E called\n", .{});
    }
}
comptime { @export(&impl_func_0816035E, .{ .name = "func_0816035E", .linkage = .weak }); }

fn impl_func_081603FE() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081603FE called\n", .{});
    }
}
comptime { @export(&impl_func_081603FE, .{ .name = "func_081603FE", .linkage = .weak }); }

fn impl_func_08160672() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08160672 called\n", .{});
    }
}
comptime { @export(&impl_func_08160672, .{ .name = "func_08160672", .linkage = .weak }); }

fn impl_func_081606BC() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081606BC called\n", .{});
    }
}
comptime { @export(&impl_func_081606BC, .{ .name = "func_081606BC", .linkage = .weak }); }

fn impl_func_0816073C() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0816073C called\n", .{});
    }
}
comptime { @export(&impl_func_0816073C, .{ .name = "func_0816073C", .linkage = .weak }); }

fn impl_func_08160758() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08160758 called\n", .{});
    }
}
comptime { @export(&impl_func_08160758, .{ .name = "func_08160758", .linkage = .weak }); }

fn impl_func_08160802() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08160802 called\n", .{});
    }
}
comptime { @export(&impl_func_08160802, .{ .name = "func_08160802", .linkage = .weak }); }

fn impl_func_08160A74() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08160A74 called\n", .{});
    }
}
comptime { @export(&impl_func_08160A74, .{ .name = "func_08160A74", .linkage = .weak }); }

fn impl_func_08160AA2() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08160AA2 called\n", .{});
    }
}
comptime { @export(&impl_func_08160AA2, .{ .name = "func_08160AA2", .linkage = .weak }); }

fn impl_func_08160AD6() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08160AD6 called\n", .{});
    }
}
comptime { @export(&impl_func_08160AD6, .{ .name = "func_08160AD6", .linkage = .weak }); }

fn impl_func_08160B44() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08160B44 called\n", .{});
    }
}
comptime { @export(&impl_func_08160B44, .{ .name = "func_08160B44", .linkage = .weak }); }

fn impl_func_08160DA8() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08160DA8 called\n", .{});
    }
}
comptime { @export(&impl_func_08160DA8, .{ .name = "func_08160DA8", .linkage = .weak }); }

fn impl_func_08160F08() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08160F08 called\n", .{});
    }
}
comptime { @export(&impl_func_08160F08, .{ .name = "func_08160F08", .linkage = .weak }); }

fn impl_func_081BDBEA() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081BDBEA called\n", .{});
    }
}
comptime { @export(&impl_func_081BDBEA, .{ .name = "func_081BDBEA", .linkage = .weak }); }

fn impl_func_081BE6E6() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081BE6E6 called\n", .{});
    }
}
comptime { @export(&impl_func_081BE6E6, .{ .name = "func_081BE6E6", .linkage = .weak }); }

fn impl_func_081BEE4A() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081BEE4A called\n", .{});
    }
}
comptime { @export(&impl_func_081BEE4A, .{ .name = "func_081BEE4A", .linkage = .weak }); }

fn impl_func_081BEE4C() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081BEE4C called\n", .{});
    }
}
comptime { @export(&impl_func_081BEE4C, .{ .name = "func_081BEE4C", .linkage = .weak }); }

fn impl_func_081BEF34() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081BEF34 called\n", .{});
    }
}
comptime { @export(&impl_func_081BEF34, .{ .name = "func_081BEF34", .linkage = .weak }); }

fn impl_func_081BF14A() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081BF14A called\n", .{});
    }
}
comptime { @export(&impl_func_081BF14A, .{ .name = "func_081BF14A", .linkage = .weak }); }

fn impl_func_081BF5AE() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081BF5AE called\n", .{});
    }
}
comptime { @export(&impl_func_081BF5AE, .{ .name = "func_081BF5AE", .linkage = .weak }); }

fn impl_func_081C61EC() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081C61EC called\n", .{});
    }
}
comptime { @export(&impl_func_081C61EC, .{ .name = "func_081C61EC", .linkage = .weak }); }

fn impl_func_081D040A() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081D040A called\n", .{});
    }
}
comptime { @export(&impl_func_081D040A, .{ .name = "func_081D040A", .linkage = .weak }); }

fn impl_func_081D11F8() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081D11F8 called\n", .{});
    }
}
comptime { @export(&impl_func_081D11F8, .{ .name = "func_081D11F8", .linkage = .weak }); }

fn impl_func_081D44A8() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081D44A8 called\n", .{});
    }
}
comptime { @export(&impl_func_081D44A8, .{ .name = "func_081D44A8", .linkage = .weak }); }

fn impl_func_081DC81E() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081DC81E called\n", .{});
    }
}
comptime { @export(&impl_func_081DC81E, .{ .name = "func_081DC81E", .linkage = .weak }); }

fn impl_func_081E3F04() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081E3F04 called\n", .{});
    }
}
comptime { @export(&impl_func_081E3F04, .{ .name = "func_081E3F04", .linkage = .weak }); }

fn impl_func_081E530A() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081E530A called\n", .{});
    }
}
comptime { @export(&impl_func_081E530A, .{ .name = "func_081E530A", .linkage = .weak }); }

fn impl_func_081E79EC() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081E79EC called\n", .{});
    }
}
comptime { @export(&impl_func_081E79EC, .{ .name = "func_081E79EC", .linkage = .weak }); }

fn impl_func_081E8110() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_081E8110 called\n", .{});
    }
}
comptime { @export(&impl_func_081E8110, .{ .name = "func_081E8110", .linkage = .weak }); }

fn impl_func_08203454() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08203454 called\n", .{});
    }
}
comptime { @export(&impl_func_08203454, .{ .name = "func_08203454", .linkage = .weak }); }

fn impl_func_08207EBE() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08207EBE called\n", .{});
    }
}
comptime { @export(&impl_func_08207EBE, .{ .name = "func_08207EBE", .linkage = .weak }); }

fn impl_func_0820B2D8() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0820B2D8 called\n", .{});
    }
}
comptime { @export(&impl_func_0820B2D8, .{ .name = "func_0820B2D8", .linkage = .weak }); }

fn impl_func_0820B936() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0820B936 called\n", .{});
    }
}
comptime { @export(&impl_func_0820B936, .{ .name = "func_0820B936", .linkage = .weak }); }

fn impl_func_082153EE() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_082153EE called\n", .{});
    }
}
comptime { @export(&impl_func_082153EE, .{ .name = "func_082153EE", .linkage = .weak }); }

fn impl_func_08217FA6() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08217FA6 called\n", .{});
    }
}
comptime { @export(&impl_func_08217FA6, .{ .name = "func_08217FA6", .linkage = .weak }); }

fn impl_func_08218F70() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08218F70 called\n", .{});
    }
}
comptime { @export(&impl_func_08218F70, .{ .name = "func_08218F70", .linkage = .weak }); }

fn impl_func_08266DD2() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08266DD2 called\n", .{});
    }
}
comptime { @export(&impl_func_08266DD2, .{ .name = "func_08266DD2", .linkage = .weak }); }

fn impl_func_0826732E() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0826732E called\n", .{});
    }
}
comptime { @export(&impl_func_0826732E, .{ .name = "func_0826732E", .linkage = .weak }); }

fn impl_func_08267432() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08267432 called\n", .{});
    }
}
comptime { @export(&impl_func_08267432, .{ .name = "func_08267432", .linkage = .weak }); }

fn impl_func_08267446() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08267446 called\n", .{});
    }
}
comptime { @export(&impl_func_08267446, .{ .name = "func_08267446", .linkage = .weak }); }

fn impl_func_0826AF3A() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0826AF3A called\n", .{});
    }
}
comptime { @export(&impl_func_0826AF3A, .{ .name = "func_0826AF3A", .linkage = .weak }); }

fn impl_func_0826C946() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0826C946 called\n", .{});
    }
}
comptime { @export(&impl_func_0826C946, .{ .name = "func_0826C946", .linkage = .weak }); }

fn impl_func_0826DCAC() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0826DCAC called\n", .{});
    }
}
comptime { @export(&impl_func_0826DCAC, .{ .name = "func_0826DCAC", .linkage = .weak }); }

fn impl_func_0826DCD6() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0826DCD6 called\n", .{});
    }
}
comptime { @export(&impl_func_0826DCD6, .{ .name = "func_0826DCD6", .linkage = .weak }); }

fn impl_func_0826E58C() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0826E58C called\n", .{});
    }
}
comptime { @export(&impl_func_0826E58C, .{ .name = "func_0826E58C", .linkage = .weak }); }

fn impl_func_08273264() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08273264 called\n", .{});
    }
}
comptime { @export(&impl_func_08273264, .{ .name = "func_08273264", .linkage = .weak }); }

fn impl_func_08273324() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08273324 called\n", .{});
    }
}
comptime { @export(&impl_func_08273324, .{ .name = "func_08273324", .linkage = .weak }); }

fn impl_func_0827332C() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0827332C called\n", .{});
    }
}
comptime { @export(&impl_func_0827332C, .{ .name = "func_0827332C", .linkage = .weak }); }

fn impl_func_08273338() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_08273338 called\n", .{});
    }
}
comptime { @export(&impl_func_08273338, .{ .name = "func_08273338", .linkage = .weak }); }

fn impl_func_082799BC() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_082799BC called\n", .{});
    }
}
comptime { @export(&impl_func_082799BC, .{ .name = "func_082799BC", .linkage = .weak }); }

fn impl_func_0827ACE0() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0827ACE0 called\n", .{});
    }
}
comptime { @export(&impl_func_0827ACE0, .{ .name = "func_0827ACE0", .linkage = .weak }); }

fn impl_func_0827B344() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0827B344 called\n", .{});
    }
}
comptime { @export(&impl_func_0827B344, .{ .name = "func_0827B344", .linkage = .weak }); }

fn impl_func_0827B35C() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0827B35C called\n", .{});
    }
}
comptime { @export(&impl_func_0827B35C, .{ .name = "func_0827B35C", .linkage = .weak }); }

fn impl_func_0827B37E() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0827B37E called\n", .{});
    }
}
comptime { @export(&impl_func_0827B37E, .{ .name = "func_0827B37E", .linkage = .weak }); }

fn impl_func_0827B3F4() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_0827B3F4 called\n", .{});
    }
}
comptime { @export(&impl_func_0827B3F4, .{ .name = "func_0827B3F4", .linkage = .weak }); }

fn impl_func_083D709C() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_083D709C called\n", .{});
    }
}
comptime { @export(&impl_func_083D709C, .{ .name = "func_083D709C", .linkage = .weak }); }

fn impl_func_083D717E() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_083D717E called\n", .{});
    }
}
comptime { @export(&impl_func_083D717E, .{ .name = "func_083D717E", .linkage = .weak }); }

fn impl_func_083D72C8() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_083D72C8 called\n", .{});
    }
}
comptime { @export(&impl_func_083D72C8, .{ .name = "func_083D72C8", .linkage = .weak }); }

fn impl_func_083E7186() callconv(.c) void {
    const S = struct { var warn: u32 = 0; };
    S.warn +%= 1;
    if (builtin.os.tag != .freestanding and S.warn <= 3) {
        std.debug.print("[unresolved] func_083E7186 called\n", .{});
    }
}
comptime { @export(&impl_func_083E7186, .{ .name = "func_083E7186", .linkage = .weak }); }

