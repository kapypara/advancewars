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

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const headless = b.option(bool, "headless", "Build without SDL2 (headless only)") orelse false;
    const rom_path = b.option([]const u8, "rom", "Path to GBA ROM (default: game/aw.gba)") orelse "game/aw.gba";
    const rom_lazy = resolvePath(b, rom_path);

    // ---- Pure-Zig host recompiler tool (`src/recomp/`) ----
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
    const recompiler_step = b.step("recompiler", "Build the pure-Zig gbarecomp static recompiler tool");
    recompiler_step.dependOn(&install_recompiler.step);

    // ---- ROM translation step (`gen/zig/`) ----
    const run_translate = b.addRunArtifact(recompiler_exe);
    run_translate.addArg("translate");
    run_translate.addFileArg(rom_lazy);
    run_translate.addArgs(&.{ "-o", "gen/zig", "--entries" });
    run_translate.addFileArg(b.path("entries.txt"));
    run_translate.has_side_effects = true;

    const translate_step = b.step("translate", "Translate the GBA ROM into pure-Zig sources under gen/zig/");
    translate_step.dependOn(&run_translate.step);

    // ---- Zig core library, SDL2 bindings & unit tests ----
    const build_opts = b.addOptions();
    build_opts.addOption(bool, "headless", headless);

    const test_opts = b.addOptions();
    test_opts.addOption(bool, "headless", true);

    const awre_core_mod = b.createModule(.{
        .root_source_file = b.path("src/zig/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
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
        .root_source_file = b.path("src/zig/root.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    awre_test_mod.addOptions("build_options", test_opts);

    const zig_tests = b.addTest(.{
        .root_module = awre_test_mod,
    });
    const run_zig_tests = b.addRunArtifact(zig_tests);

    const recomp_test_mod = b.createModule(.{
        .root_source_file = b.path("src/recomp/main.zig"),
        .target = b.graph.host,
        .optimize = optimize,
    });
    const recomp_tests = b.addTest(.{
        .root_module = recomp_test_mod,
    });
    const run_recomp_tests = b.addRunArtifact(recomp_tests);

    const test_step = b.step("test", "Run Zig unit tests");
    test_step.dependOn(&run_zig_tests.step);
    test_step.dependOn(&run_recomp_tests.step);

    // ---- Native pure-Zig Advance Wars executable (`awre`) ----
    var shard_files: std.ArrayList([]const u8) = .empty;
    var has_game_zig = false;
    var has_decls_zig = false;

    if (b.root.openDir(b.graph.io, "gen/zig", .{ .iterate = true })) |dir_const| {
        var zig_dir = dir_const;
        defer zig_dir.close(b.graph.io);

        b.dependOnDirectoryContents(b.path("gen/zig"));

        var it = zig_dir.iterate();
        while (it.next(b.graph.io) catch null) |entry| {
            if (entry.kind != .file) continue;
            if (!std.mem.endsWith(u8, entry.name, ".zig")) continue;
            if (std.mem.eql(u8, entry.name, "game.zig")) {
                has_game_zig = true;
                continue;
            }
            if (std.mem.eql(u8, entry.name, "decls.zig")) {
                has_decls_zig = true;
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

    if (!has_game_zig or !has_decls_zig) {
        b.graph.poisonCache();
        const fail_step = b.addFail("gen/zig/ is not populated; run 'zig build translate' first");
        b.getInstallStep().dependOn(&fail_step.step);
        return;
    }

    std.mem.sort([]const u8, shard_files.items, {}, stringLessThan);

    const awre_rt_mod = b.createModule(.{
        .root_source_file = b.path("src/zig/runtime_abi.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    awre_rt_mod.addImport("awre_core", awre_core_mod);
    if (target.result.os.tag != .freestanding) {
        awre_rt_mod.addCSourceFile(.{
            .file = b.path("src/zig/runtime/validate_jmp.c"),
            .flags = &.{ "-std=c11", "-fno-sanitize=undefined" },
        });
    }

    const rt_shard_mod = b.createModule(.{
        .root_source_file = b.path("src/zig/rt_shard.zig"),
        .target = target,
        .optimize = optimize,
    });

    const decls_mod = b.createModule(.{
        .root_source_file = b.path("gen/zig/decls.zig"),
        .target = target,
        .optimize = optimize,
    });

    const game_mod = b.createModule(.{
        .root_source_file = b.path("gen/zig/game.zig"),
        .target = target,
        .optimize = optimize,
    });
    game_mod.addImport("runtime", awre_rt_mod);
    game_mod.addImport("decls", decls_mod);

    const awre_mod = b.createModule(.{
        .root_source_file = b.path("src/zig/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    awre_mod.addImport("runtime", awre_rt_mod);
    awre_mod.addImport("game", game_mod);
    if (!headless) {
        awre_mod.linkSystemLibrary("SDL2", .{});
    }

    for (shard_files.items) |fname| {
        const rel_path = b.pathJoin(&.{ "gen/zig", fname });
        const shard_mod = b.createModule(.{
            .root_source_file = b.path(rel_path),
            .target = target,
            .optimize = optimize,
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
        awre_mod.addObject(shard_obj);
    }

    const awre_exe = b.addExecutable(.{
        .name = "awre",
        .root_module = awre_mod,
    });
    awre_exe.stack_size = 16 * 1024 * 1024;
    b.installArtifact(awre_exe);

    // ---- Run, conformance & headless smoke steps ----
    const run_cmd = b.addRunArtifact(awre_exe);
    run_cmd.step.dependOn(b.getInstallStep());
    run_cmd.addFileArg(rom_lazy);
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
    smoke_cmd.addArg("scratch/zig_field_training.bmp");
    smoke_cmd.has_side_effects = true;
    const smoke_step = b.step("smoke", "Run headless Field Training smoke test without touching game/aw.sav");
    smoke_step.dependOn(&smoke_cmd.step);
}
