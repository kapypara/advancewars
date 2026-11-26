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

fn isRuntimeFile(name: []const u8) bool {
    return std.mem.eql(u8, name, "game_entry.c") or
        std.mem.eql(u8, name, "runtime.c") or
        std.mem.eql(u8, name, "display.c") or
        std.mem.eql(u8, name, "unresolved.c");
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const headless = b.option(bool, "headless", "Build without SDL2 (headless only)") orelse false;
    const rom_path = b.option([]const u8, "rom", "Path to GBA ROM (default: game/aw.gba)") orelse "game/aw.gba";
    const rom_lazy = resolvePath(b, rom_path);

    // ---- Host recompiler tool (`ext/gbarecomp`) ----
    const recompiler_mod = b.createModule(.{
        .root_source_file = null,
        .target = b.graph.host,
        .optimize = .fast,
        .link_libc = true,
    });
    recompiler_mod.addIncludePath(b.path("ext/gbarecomp/include"));
    recompiler_mod.addCSourceFiles(.{
        .root = b.path("ext/gbarecomp/src"),
        .files = &.{
            "main.c",
            "rom.c",
            "arm.c",
            "thumb.c",
            "disasm.c",
            "analysis.c",
            "translate.c",
        },
        .flags = &.{
            "-std=c11",
            "-Wall",
            "-Wextra",
            "-Wno-unused-parameter",
            "-fno-sanitize=undefined",
        },
    });
    const recompiler_exe = b.addExecutable(.{
        .name = "gbarecomp",
        .root_module = recompiler_mod,
    });

    const install_recompiler = b.addInstallArtifact(recompiler_exe, .{});
    const recompiler_step = b.step("recompiler", "Build the gbarecomp static recompiler tool");
    recompiler_step.dependOn(&install_recompiler.step);

    // ---- ROM translation step (`gen/`) ----
    // Note: translate.c copies runtime sources relative to cwd (`ext/gbarecomp`).
    const run_translate = b.addRunArtifact(recompiler_exe);
    run_translate.setCwd(b.path("ext/gbarecomp"));
    run_translate.addArg("translate");
    run_translate.addFileArg2(rom_lazy, .{ .make_absolute = true });
    run_translate.addArgs(&.{ "-o", "../../gen", "--multi", "--entries" });
    run_translate.addFileArg2(b.path("entries.txt"), .{ .make_absolute = true });
    run_translate.has_side_effects = true;

    const translate_step = b.step("translate", "Translate the GBA ROM into C sources under gen/");
    translate_step.dependOn(&run_translate.step);

    // ---- Zig support library & unit tests ----
    const awre_zig_mod = b.createModule(.{
        .root_source_file = b.path("src/zig/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const awre_zig_lib = b.addLibrary(.{
        .name = "awre_zig",
        .linkage = .static,
        .root_module = awre_zig_mod,
    });

    const zig_tests = b.addTest(.{
        .root_module = awre_zig_mod,
    });
    const run_zig_tests = b.addRunArtifact(zig_tests);
    const test_step = b.step("test", "Run Zig unit tests");
    test_step.dependOn(&run_zig_tests.step);

    // ---- Native Advance Wars executable (`awre`) ----
    var runtime_files: std.ArrayList([]const u8) = .empty;
    var generated_files: std.ArrayList([]const u8) = .empty;
    var has_game_entry = false;

    if (b.root.openDir(b.graph.io, "gen", .{ .iterate = true })) |dir_const| {
        var gen_dir = dir_const;
        defer gen_dir.close(b.graph.io);

        b.dependOnDirectoryContents(b.path("gen"));

        var it = gen_dir.iterate();
        while (it.next(b.graph.io) catch null) |entry| {
            if (entry.kind != .file) continue;
            if (!std.mem.endsWith(u8, entry.name, ".c")) continue;

            const duped = b.graph.arena.dupe(u8, entry.name) catch @panic("OOM");
            if (std.mem.eql(u8, duped, "game_entry.c")) {
                has_game_entry = true;
            }
            if (isRuntimeFile(duped)) {
                runtime_files.append(b.graph.arena, duped) catch @panic("OOM");
            } else {
                generated_files.append(b.graph.arena, duped) catch @panic("OOM");
            }
        }
    } else |_| {}

    if (!has_game_entry) {
        const fail_step = b.addFail("gen/ is not populated; run 'zig build translate' first");
        b.getInstallStep().dependOn(&fail_step.step);
        return;
    }

    std.mem.sort([]const u8, runtime_files.items, {}, stringLessThan);
    std.mem.sort([]const u8, generated_files.items, {}, stringLessThan);

    const awre_mod = b.createModule(.{
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .sanitize_c = .off,
    });
    awre_mod.addIncludePath(b.path("gen"));

    const gen_c_flags: []const []const u8 = &.{
        "-std=gnu11",
        "-O1",
        "-Wall",
        "-Wno-unused-label",
        "-Wno-pointer-to-int-cast",
        "-Wno-int-to-pointer-cast",
        "-Wno-unused-variable",
        "-Wno-unused-function",
        "-Wno-deprecated-declarations",
        "-fno-sanitize=undefined",
    };

    const runtime_c_flags: []const []const u8 = if (headless)
        &.{
            "-std=gnu11",
            "-O1",
            "-Wall",
            "-Wno-unused-label",
            "-Wno-pointer-to-int-cast",
            "-Wno-int-to-pointer-cast",
            "-Wno-unused-variable",
            "-Wno-unused-function",
            "-Wno-deprecated-declarations",
            "-fno-sanitize=undefined",
            "-DGBA_NO_SDL",
        }
    else
        gen_c_flags;

    awre_mod.addCSourceFiles(.{
        .root = b.path("gen"),
        .files = runtime_files.items,
        .flags = runtime_c_flags,
    });
    awre_mod.addCSourceFiles(.{
        .root = b.path("gen"),
        .files = generated_files.items,
        .flags = gen_c_flags,
    });

    awre_mod.linkLibrary(awre_zig_lib);
    awre_mod.linkSystemLibrary("m", .{});
    if (!headless) {
        awre_mod.linkSystemLibrary("SDL2", .{});
    }

    const awre_exe = b.addExecutable(.{
        .name = "awre",
        .root_module = awre_mod,
    });
    awre_exe.stack_size = 16 * 1024 * 1024;
    awre_exe.forceUndefinedSymbol("awre_zig_abi_version");
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
