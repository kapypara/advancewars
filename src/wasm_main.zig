const core = @import("awre_core");
const rt = @import("runtime");
const game = @import("game");

pub export fn awre_has_embedded_rom() u32 {
    return if (rt.hasEmbeddedRom()) 1 else 0;
}

pub export fn awre_rom_buf_ptr() [*]u8 {
    return rt.wasmRomBufPtr();
}

pub export fn awre_rom_buf_cap() u32 {
    return rt.wasmRomBufCap();
}

pub export fn awre_sram_buf_ptr() [*]u8 {
    return rt.wasmSramBufPtr();
}

pub export fn awre_sram_size() u32 {
    return rt.wasmSramSize();
}

pub export fn awre_init_wasm(rom_len: u32) c_int {
    rt.linkShardExports();
    rt.registerGameCallbacks(.{
        .bx_depth = &game.g_bx_depth,
        .cpu_bx = game.awre_cpu_bx,
        .recomp_lookup = game.recompLookup,
        .recomp_lookup_fn = game.recompLookupFn,
    });
    return if (rt.gba_init_memory(rom_len)) 0 else -1;
}

pub export fn awre_mark_sram_clean() void {
    rt.wasmMarkSramClean();
}

pub export fn awre_run_wasm() void {
    rt.gba_run(game.gameEntry);
}

pub export fn awre_push_pointer(id: i32, phase: u32, lx: f32, ly: f32) void {
    core.platform.WasmBackend.pushPointerRaw(id, phase, lx, ly);
}
