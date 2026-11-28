const std = @import("std");

fn stringLessThan(_: void, a: []const u8, b: []const u8) bool {
    return std.mem.lessThan(u8, a, b);
}

fn resolvePath(b: *std.Build, p: []const u8) std.Build.LazyPath {
    if (std.fs.path.isAbsolute(p)) {
        return .{ .cwd_relative = p };
    }
    return b.path(p);
}

fn addGeneratedShards(
    b: *std.Build,
    parent_mod: *std.Build.Module,
    shard_files: []const []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    strip: bool,
    rt_shard_mod: *std.Build.Module,
    decls_mod: *std.Build.Module,
) void {
    for (shard_files) |fname| {
        const rel_path = b.pathJoin(&.{ "gen", fname });
        const shard_mod = b.createModule(.{
            .root_source_file = b.path(rel_path),
            .target = target,
            .optimize = optimize,
            .strip = strip,
            .unwind_tables = .none,
        });
        if (!std.mem.eql(u8, fname, "unresolved.zig")) {
            shard_mod.addImport("runtime", rt_shard_mod);
            shard_mod.addImport("decls", decls_mod);
        }
        const stem = fname[0 .. fname.len - 4];
        const shard_obj = b.addObject(.{
            .name = stem,
            .root_module = shard_mod,
        });
        parent_mod.addObject(shard_obj);
    }
}

fn isStandaloneGameFile(name: []const u8) bool {
    const skip = [_][]const u8{
        "root.zig",
        "abi.zig",
        "types.zig",
        "mem.zig",
        "decls.zig",
        "dispatch.zig",
        "bios.zig",
        "dma.zig",
        "hw.zig",
        "math.zig",
        "main_loop.zig",
        "sound.zig",
        "proc.zig",
        "unit.zig",
        "battle.zig",
    };
    for (skip) |s| {
        if (std.mem.eql(u8, name, s)) return false;
    }
    return true;
}

fn addGameObjects(
    b: *std.Build,
    parent_mod: *std.Build.Module,
    game_files: []const []const u8,
    name_prefix: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    strip: bool,
    rt_shard_mod: *std.Build.Module,
    decls_mod: *std.Build.Module,
) void {
    for (game_files) |fname| {
        const rel_path = b.pathJoin(&.{ "src", "game", fname });
        const mod = b.createModule(.{
            .root_source_file = b.path(rel_path),
            .target = target,
            .optimize = optimize,
            .strip = strip,
            .unwind_tables = if (strip) .none else null,
        });
        mod.addImport("runtime", rt_shard_mod);
        mod.addImport("decls", decls_mod);
        const stem = fname[0 .. fname.len - 4];
        const obj_name = b.fmt("{s}{s}", .{ name_prefix, stem });
        const obj = b.addObject(.{
            .name = obj_name,
            .root_module = mod,
        });
        parent_mod.addObject(obj);
    }
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const headless = b.option(bool, "headless", "Build without SDL2 (headless only)") orelse false;
    const use_gen = b.option(
        bool,
        "use-gen",
        "Build using generated gen/ shards instead of src/game/ (run 'zig build translate' first)",
    ) orelse false;
    const rom_path = b.option([]const u8, "rom", "Path to GBA ROM (default: game/aw.gba)") orelse "game/aw.gba";
    const strip_opt = b.option(bool, "strip", "Strip debug info (default: shards always stripped, exe stripped in Release)");
    const shard_optimize = b.option(
        std.builtin.OptimizeMode,
        "shard-optimize",
        "Optimize mode for generated gen/ shards (default: small for fast/safe release builds)",
    ) orelse if (optimize == .fast or optimize == .safe) .small else optimize;
    const enable_trace = b.option(
        bool,
        "trace",
        "Enable GBA_VALIDATE / tracing hooks in shards (default: true on native hosts, false on freestanding)",
    ) orelse (target.result.os.tag != .freestanding);
    const embed_rom_opt = b.option(
        bool,
        "embed-rom",
        "Embed the GBA ROM into the executable (default: true when ROM file exists)",
    );
    const strip_exe = strip_opt orelse (optimize != .debug);
    const strip_shards = strip_opt orelse true;
    const rom_lazy = resolvePath(b, rom_path);
    const rom_exists = if (std.fs.path.isAbsolute(rom_path))
        if (std.Io.Dir.accessAbsolute(b.graph.io, rom_path, .{})) true else |_| false
    else
        if (b.root.access(b.graph.io, rom_path, .{})) true else |_| false;
    const embed_rom = embed_rom_opt orelse rom_exists;

    // ---- Host recompiler tool (`src/recomp/`) ----
    const recompiler_mod = b.createModule(.{
        .root_source_file = b.path("src/recomp/main.zig"),
        .target = b.graph.host,
        .optimize = .fast,
    });
    const recompiler_exe = b.addExecutable(.{
        .name = "gbarecomp",
        .root_module = recompiler_mod,
    });

    const install_recompiler = b.addInstallArtifact(recompiler_exe, .{});
    const recompiler_step = b.step("recompiler", "Build the gbarecomp static recompiler tool");
    recompiler_step.dependOn(&install_recompiler.step);

    // ---- ROM translation step (`gen/`) ----
    const run_translate = b.addRunArtifact(recompiler_exe);
    run_translate.addArg("translate");
    run_translate.addFileArg(rom_lazy);
    run_translate.addArgs(&.{ "-o", "gen", "--entries" });
    run_translate.addFileArg(b.path("entries.txt"));
    run_translate.has_side_effects = true;

    const translate_step = b.step("translate", "Translate the GBA ROM into generated shards under gen/");
    translate_step.dependOn(&run_translate.step);

    // ---- Core library, SDL2 bindings & unit tests ----
    const build_opts = b.addOptions();
    build_opts.addOption(bool, "headless", headless);

    const shard_opts = b.addOptions();
    shard_opts.addOption(bool, "enable_trace", enable_trace);

    const rt_shard_mod = b.createModule(.{
        .root_source_file = b.path("src/shard.zig"),
        .target = target,
        .optimize = optimize,
        .strip = strip_exe,
    });
    rt_shard_mod.addOptions("build_options", shard_opts);

    const test_opts = b.addOptions();
    test_opts.addOption(bool, "headless", true);

    const awre_core_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .strip = strip_exe,
    });
    awre_core_mod.addOptions("build_options", build_opts);

    if (!headless) {
        const wf = b.addWriteFiles();
        const sdl_h = wf.add("sdl2_wrap.h", "#include <SDL2/SDL.h>\n");
        const translate_sdl = b.addTranslateC(.{
            .root_source_file = sdl_h,
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        translate_sdl.linkSystemLibrary("SDL2", .{});
        awre_core_mod.addImport("sdl2", translate_sdl.createModule());
    }

    const awre_test_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    awre_test_mod.addOptions("build_options", test_opts);

    const core_tests = b.addTest(.{
        .root_module = awre_test_mod,
    });
    const run_core_tests = b.addRunArtifact(core_tests);

    const recomp_test_mod = b.createModule(.{
        .root_source_file = b.path("src/recomp/main.zig"),
        .target = b.graph.host,
        .optimize = optimize,
    });
    const recomp_tests = b.addTest(.{
        .root_module = recomp_test_mod,
    });
    const run_recomp_tests = b.addRunArtifact(recomp_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_core_tests.step);
    test_step.dependOn(&run_recomp_tests.step);

    // ---- Native Advance Wars executable (`awre`) ----
    var shard_files: std.ArrayList([]const u8) = .empty;
    var game_files: std.ArrayList([]const u8) = .empty;
    var has_game = false;
    var has_decls = false;

    if (use_gen) {
        if (b.root.openDir(b.graph.io, "gen", .{ .iterate = true })) |dir_const| {
            var gen_dir = dir_const;
            defer gen_dir.close(b.graph.io);

            b.dependOnDirectoryContents(b.path("gen"));

            var it = gen_dir.iterate();
            while (it.next(b.graph.io) catch null) |entry| {
                if (entry.kind != .file) continue;
                if (!std.mem.endsWith(u8, entry.name, ".zig")) continue;
                if (std.mem.eql(u8, entry.name, "game.zig")) {
                    has_game = true;
                    continue;
                }
                if (std.mem.eql(u8, entry.name, "decls.zig")) {
                    has_decls = true;
                    continue;
                }
                if (std.mem.startsWith(u8, entry.name, "funcs_") or
                    std.mem.startsWith(u8, entry.name, "stubs_") or
                    std.mem.eql(u8, entry.name, "unresolved.zig"))
                {
                    const duped = b.graph.arena.dupe(u8, entry.name) catch @panic("OOM");
                    shard_files.append(b.graph.arena, duped) catch @panic("OOM");
                }
            }
        } else |_| {}

        if (!has_game or !has_decls) {
            b.graph.poisonCache();
            const fail_step = b.addFail("gen/ is not populated; run 'zig build translate' first");
            b.getInstallStep().dependOn(&fail_step.step);
            return;
        }

        std.mem.sort([]const u8, shard_files.items, {}, stringLessThan);
    } else {
        var game_dir = b.root.openDir(b.graph.io, "src/game", .{ .iterate = true }) catch |err| {
            std.debug.panic("failed to open src/game: {s}", .{@errorName(err)});
        };
        defer game_dir.close(b.graph.io);

        b.dependOnDirectoryContents(b.path("src/game"));

        var it = game_dir.iterate();
        while (it.next(b.graph.io) catch null) |entry| {
            if (entry.kind != .file) continue;
            if (!std.mem.endsWith(u8, entry.name, ".zig")) continue;
            if (!isStandaloneGameFile(entry.name)) continue;
            const duped = b.graph.arena.dupe(u8, entry.name) catch @panic("OOM");
            game_files.append(b.graph.arena, duped) catch @panic("OOM");
        }
        std.mem.sort([]const u8, game_files.items, {}, stringLessThan);
    }

    const decls_path = if (use_gen) "gen/decls.zig" else "src/game/decls.zig";
    const dispatch_path = if (use_gen) "gen/game.zig" else "src/game/dispatch.zig";

    const rt_opts = b.addOptions();
    rt_opts.addOption(bool, "has_embedded_rom", embed_rom);

    const awre_rt_mod = b.createModule(.{
        .root_source_file = b.path("src/runtime.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .strip = strip_exe,
    });
    awre_rt_mod.addOptions("rt_options", rt_opts);
    awre_rt_mod.addImport("awre_core", awre_core_mod);
    if (embed_rom) {
        awre_rt_mod.addAnonymousImport("embedded_rom", .{
            .root_source_file = rom_lazy,
        });
    }
    if (target.result.os.tag != .freestanding) {
        awre_rt_mod.addCSourceFile(.{
            .file = b.path("src/validate/jmp.c"),
            .flags = &.{ "-std=c11", "-fno-sanitize=undefined" },
        });
    }

    const decls_mod = b.createModule(.{
        .root_source_file = b.path(decls_path),
        .target = target,
        .optimize = optimize,
        .strip = strip_exe,
    });

    const decomp_test_mod = b.createModule(.{
        .root_source_file = b.path("src/game/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    decomp_test_mod.addImport("runtime", rt_shard_mod);
    decomp_test_mod.addImport("decls", decls_mod);
    const decomp_tests = b.addTest(.{
        .root_module = decomp_test_mod,
    });
    const run_decomp_tests = b.addRunArtifact(decomp_tests);
    test_step.dependOn(&run_decomp_tests.step);

    const game_mod = b.createModule(.{
        .root_source_file = b.path(dispatch_path),
        .target = target,
        .optimize = optimize,
        .strip = strip_exe,
    });
    game_mod.addImport("runtime", awre_rt_mod);
    game_mod.addImport("decls", decls_mod);

    const awre_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .strip = strip_exe,
        .unwind_tables = if (strip_exe) .none else null,
    });
    awre_mod.addImport("runtime", awre_rt_mod);
    awre_mod.addImport("game", game_mod);
    if (!headless) {
        awre_mod.linkSystemLibrary("SDL2", .{});
    }

    if (use_gen) {
        addGeneratedShards(
            b,
            awre_mod,
            shard_files.items,
            target,
            shard_optimize,
            strip_shards,
            rt_shard_mod,
            decls_mod,
        );
    } else {
        addGameObjects(
            b,
            awre_mod,
            game_files.items,
            "game_",
            target,
            optimize,
            strip_exe,
            rt_shard_mod,
            decls_mod,
        );
    }

    const awre_exe = b.addExecutable(.{
        .name = "awre",
        .root_module = awre_mod,
    });
    awre_exe.stack_size = 16 * 1024 * 1024;
    b.installArtifact(awre_exe);

    // ---- WebAssembly browser target (`zig build wasm`) ----
    const wasm_target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
    });

    const wasm_core_opts = b.addOptions();
    wasm_core_opts.addOption(bool, "headless", false);

    const wasm_core_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = wasm_target,
        .optimize = .fast,
        .link_libc = false,
        .strip = true,
    });
    wasm_core_mod.addOptions("build_options", wasm_core_opts);

    const wasm_rt_opts = b.addOptions();
    wasm_rt_opts.addOption(bool, "has_embedded_rom", embed_rom);

    const wasm_rt_mod = b.createModule(.{
        .root_source_file = b.path("src/runtime.zig"),
        .target = wasm_target,
        .optimize = .fast,
        .link_libc = false,
        .strip = true,
    });
    wasm_rt_mod.addOptions("rt_options", wasm_rt_opts);
    if (embed_rom) {
        wasm_rt_mod.addAnonymousImport("embedded_rom", .{
            .root_source_file = rom_lazy,
        });
    }
    wasm_rt_mod.addImport("awre_core", wasm_core_mod);

    const wasm_shard_opts = b.addOptions();
    wasm_shard_opts.addOption(bool, "enable_trace", false);

    const wasm_rt_shard_mod = b.createModule(.{
        .root_source_file = b.path("src/shard.zig"),
        .target = wasm_target,
        .optimize = .small,
        .strip = true,
    });
    wasm_rt_shard_mod.addOptions("build_options", wasm_shard_opts);

    const wasm_decls_mod = b.createModule(.{
        .root_source_file = b.path(decls_path),
        .target = wasm_target,
        .optimize = .small,
        .strip = true,
    });

    const wasm_game_mod = b.createModule(.{
        .root_source_file = b.path(dispatch_path),
        .target = wasm_target,
        .optimize = .small,
        .strip = true,
    });
    wasm_game_mod.addImport("runtime", wasm_rt_mod);
    wasm_game_mod.addImport("decls", wasm_decls_mod);

    const wasm_mod = b.createModule(.{
        .root_source_file = b.path("src/wasm_main.zig"),
        .target = wasm_target,
        .optimize = .fast,
        .link_libc = false,
        .strip = true,
        .unwind_tables = .none,
    });
    wasm_mod.export_symbol_names = &.{
        "awre_has_embedded_rom",
        "awre_rom_buf_ptr",
        "awre_rom_buf_cap",
        "awre_sram_buf_ptr",
        "awre_sram_size",
        "awre_init_wasm",
        "awre_mark_sram_clean",
        "awre_run_wasm",
        "awre_push_pointer",
        "awre_cam_delta",
        "awre_set_wide_height",
    };
    wasm_mod.addImport("awre_core", wasm_core_mod);
    wasm_mod.addImport("runtime", wasm_rt_mod);
    wasm_mod.addImport("game", wasm_game_mod);

    if (use_gen) {
        addGeneratedShards(
            b,
            wasm_mod,
            shard_files.items,
            wasm_target,
            .small,
            true,
            wasm_rt_shard_mod,
            wasm_decls_mod,
        );
    } else {
        addGameObjects(
            b,
            wasm_mod,
            game_files.items,
            "wasm_game_",
            wasm_target,
            .fast,
            true,
            wasm_rt_shard_mod,
            wasm_decls_mod,
        );
    }

    const wasm_exe = b.addExecutable(.{
        .name = "awre",
        .root_module = wasm_mod,
    });
    wasm_exe.entry = .disabled;
    wasm_exe.export_memory = true;
    wasm_exe.stack_size = 4 * 1024 * 1024;
    wasm_exe.initial_memory = 64 * 1024 * 1024;
    wasm_exe.max_memory = 128 * 1024 * 1024;

    const install_wasm = b.addInstallArtifact(wasm_exe, .{
        .dest_dir = .{ .override = .{ .custom = "web" } },
    });
    const install_web_assets = b.addInstallDirectory(.{
        .source_dir = b.path("web"),
        .install_dir = .{ .custom = "web" },
        .install_subdir = "",
    });
    const wasm_step = b.step("wasm", "Build WebAssembly browser bundle in zig-out/web/");
    wasm_step.dependOn(&install_wasm.step);
    wasm_step.dependOn(&install_web_assets.step);

    // ---- Run, conformance & headless smoke steps ----
    const run_cmd = b.addRunArtifact(awre_exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (!embed_rom) {
        run_cmd.addFileArg(rom_lazy);
    }
    run_cmd.addPassthruArgs();
    const run_step = b.step("run", "Run awre against the ROM (pass flags after '--')");
    run_step.dependOn(&run_cmd.step);

    const conformance_cmd = b.addSystemCommand(&.{ "bash", "scripts/conformance.sh" });
    conformance_cmd.addArtifactArg(awre_exe);
    conformance_cmd.addFileArg(rom_lazy);
    conformance_cmd.has_side_effects = true;
    const conformance_step = b.step("conformance", "Run 165/165 lockstep conformance check without touching game/aw.sav");
    conformance_step.dependOn(&conformance_cmd.step);

    const smoke_cmd = b.addSystemCommand(&.{ "bash", "scripts/smoke.sh" });
    smoke_cmd.addArtifactArg(awre_exe);
    smoke_cmd.addFileArg(rom_lazy);
    smoke_cmd.addArg("scratch/field_training.bmp");
    smoke_cmd.has_side_effects = true;
    const smoke_step = b.step("smoke", "Run headless Field Training smoke test without touching game/aw.sav");
    smoke_step.dependOn(&smoke_cmd.step);
}
