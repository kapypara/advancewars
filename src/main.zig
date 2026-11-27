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
    const rom_path = rt.dispParseArgs(init.args.vector) orelse "game.gba";
    rt.gba_init(rom_path);
    rt.gba_run(game.gameEntry);
    rt.gba_shutdown();
    return 0;
}
