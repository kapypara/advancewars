const std = @import("std");
const rt = @import("runtime");
const game = @import("game");

pub fn main(init: std.process.Init.Minimal) u8 {
    rt.linkShardExports();
    rt.registerGameCallbacks(.{
        .bx_depth = &game.g_bx_depth,
        .cpu_bx = game.awre_cpu_bx,
        .recomp_lookup = game.recompLookup,
        .recomp_lookup_fn = game.recompLookupFn,
    });
    const rom_path = rt.dispParseArgs(init.args.vector);
    const save_path = rt.dispSavePath();
    const exe_arg0: ?[*:0]const u8 = if (init.args.vector.len > 0) init.args.vector[0] else null;
    rt.gba_init(rom_path, save_path, exe_arg0);
    rt.gba_run(game.gameEntry);
    rt.gba_shutdown();
    return 0;
}
