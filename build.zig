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

/// Temporary Phase 3C build-time fix for gen/runtime.c's ARM7TDMI interpreter
/// register-shift-by-0 bug (`ROR Rs` with `Rs == 0` wrongly executed `RRX`,
/// corrupting m4a's sample-end byte-rotation in IWRAM). Removed automatically in
/// Phase 4 once `gen/runtime.c` is replaced by pure Zig.
fn patchRuntimeArmShifts(allocator: std.mem.Allocator, src: []const u8) []const u8 {
    const needle =
        \\                    /* Register with shift */
        \\                    int rm = insn & 0xF;
        \\                    op2 = r[rm];
        \\                    if (rm == 15) op2 = pc + 4;
        \\                    int shift_type = (insn >> 5) & 3;
        \\                    u32 shift_amount;
        \\                    if (insn & (1 << 4)) {
        \\                        shift_amount = r[(insn >> 8) & 0xF] & 0xFF;
        \\                    } else {
        \\                        shift_amount = (insn >> 7) & 0x1F;
        \\                    }
        \\                    switch (shift_type) {
        \\                    case 0: /* LSL */
        \\                        if (shift_amount > 0) {
        \\                            if (shift_amount < 32) { shift_carry = (op2 >> (32 - shift_amount)) & 1; op2 <<= shift_amount; }
        \\                            else if (shift_amount == 32) { shift_carry = op2 & 1; op2 = 0; }
        \\                            else { shift_carry = 0; op2 = 0; }
        \\                        }
        \\                        break;
        \\                    case 1: /* LSR */
        \\                        if (shift_amount == 0) shift_amount = 32;
        \\                        if (shift_amount < 32) { shift_carry = (op2 >> (shift_amount - 1)) & 1; op2 >>= shift_amount; }
        \\                        else if (shift_amount == 32) { shift_carry = (op2 >> 31) & 1; op2 = 0; }
        \\                        else { shift_carry = 0; op2 = 0; }
        \\                        break;
        \\                    case 2: /* ASR */
        \\                        if (shift_amount == 0) shift_amount = 32;
        \\                        if (shift_amount >= 32) { shift_carry = (op2 >> 31) & 1; op2 = (u32)((s32)op2 >> 31); }
        \\                        else { shift_carry = (op2 >> (shift_amount - 1)) & 1; op2 = (u32)((s32)op2 >> shift_amount); }
        \\                        break;
        \\                    case 3: /* ROR/RRX */
        \\                        if (shift_amount == 0) { /* RRX */
        \\                            shift_carry = op2 & 1;
        \\                            op2 = (CPU_C ? 0x80000000u : 0) | (op2 >> 1);
        \\                        } else {
        \\                            shift_amount &= 31;
        \\                            if (shift_amount == 0) { shift_carry = (op2 >> 31) & 1; }
        \\                            else { op2 = (op2 >> shift_amount) | (op2 << (32 - shift_amount)); shift_carry = (op2 >> 31) & 1; }
        \\                        }
        \\                        break;
        \\                    }
    ;
    const replacement =
        \\                    /* Register with shift */
        \\                    int rm = insn & 0xF;
        \\                    op2 = r[rm];
        \\                    bool reg_shift = (insn & (1 << 4)) != 0;
        \\                    if (rm == 15) op2 = reg_shift ? (pc + 8) : (pc + 4);
        \\                    int shift_type = (insn >> 5) & 3;
        \\                    u32 shift_amount;
        \\                    if (reg_shift) {
        \\                        shift_amount = r[(insn >> 8) & 0xF] & 0xFF;
        \\                    } else {
        \\                        shift_amount = (insn >> 7) & 0x1F;
        \\                    }
        \\                    switch (shift_type) {
        \\                    case 0: /* LSL */
        \\                        if (shift_amount > 0) {
        \\                            if (shift_amount < 32) { shift_carry = (op2 >> (32 - shift_amount)) & 1; op2 <<= shift_amount; }
        \\                            else if (shift_amount == 32) { shift_carry = op2 & 1; op2 = 0; }
        \\                            else { shift_carry = 0; op2 = 0; }
        \\                        }
        \\                        break;
        \\                    case 1: /* LSR */
        \\                        if (reg_shift && shift_amount == 0) break;
        \\                        if (!reg_shift && shift_amount == 0) shift_amount = 32;
        \\                        if (shift_amount < 32) { shift_carry = (op2 >> (shift_amount - 1)) & 1; op2 >>= shift_amount; }
        \\                        else if (shift_amount == 32) { shift_carry = (op2 >> 31) & 1; op2 = 0; }
        \\                        else { shift_carry = 0; op2 = 0; }
        \\                        break;
        \\                    case 2: /* ASR */
        \\                        if (reg_shift && shift_amount == 0) break;
        \\                        if (!reg_shift && shift_amount == 0) shift_amount = 32;
        \\                        if (shift_amount >= 32) { shift_carry = (op2 >> 31) & 1; op2 = (u32)((s32)op2 >> 31); }
        \\                        else { shift_carry = (op2 >> (shift_amount - 1)) & 1; op2 = (u32)((s32)op2 >> shift_amount); }
        \\                        break;
        \\                    case 3: /* ROR/RRX */
        \\                        if (reg_shift && shift_amount == 0) break;
        \\                        if (!reg_shift && shift_amount == 0) { /* RRX */
        \\                            shift_carry = op2 & 1;
        \\                            op2 = (CPU_C ? 0x80000000u : 0) | (op2 >> 1);
        \\                        } else {
        \\                            shift_amount &= 31;
        \\                            if (shift_amount == 0) { shift_carry = (op2 >> 31) & 1; }
        \\                            else { op2 = (op2 >> shift_amount) | (op2 << (32 - shift_amount)); shift_carry = (op2 >> 31) & 1; }
        \\                        }
        \\                        break;
        \\                    }
    ;
    const idx = std.mem.indexOf(u8, src, needle) orelse
        @panic("gen/runtime.c ARM shift patch target not found");
    return std.mem.concat(allocator, u8, &.{
        src[0..idx],
        replacement,
        src[idx + needle.len ..],
    }) catch @panic("OOM");
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

    const awre_abi_mod = b.createModule(.{
        .root_source_file = b.path("src/zig/display_abi.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    awre_abi_mod.addImport("awre_core", awre_core_mod);

    const awre_zig_lib = b.addLibrary(.{
        .name = "awre_zig",
        .linkage = .static,
        .root_module = awre_abi_mod,
    });

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
    const test_step = b.step("test", "Run Zig unit tests");
    test_step.dependOn(&run_zig_tests.step);

    // ---- Native Advance Wars executable (`awre`) ----
    var c_files: std.ArrayList([]const u8) = .empty;
    var has_game_entry = false;
    var patched_runtime_src: ?[]const u8 = null;

    if (b.root.openDir(b.graph.io, "gen", .{ .iterate = true })) |dir_const| {
        var gen_dir = dir_const;
        defer gen_dir.close(b.graph.io);

        b.dependOnDirectoryContents(b.path("gen"));

        var it = gen_dir.iterate();
        while (it.next(b.graph.io) catch null) |entry| {
            if (entry.kind != .file) continue;
            if (!std.mem.endsWith(u8, entry.name, ".c")) continue;
            // Replaced in Phase 3A by src/zig/display_abi.zig + ppu.zig + headless.zig + platform*.zig.
            if (std.mem.eql(u8, entry.name, "display.c")) continue;
            if (std.mem.eql(u8, entry.name, "runtime.c")) {
                const raw_rt = gen_dir.readFileAlloc(
                    b.graph.io,
                    "runtime.c",
                    b.graph.arena,
                    .limited(4 * 1024 * 1024),
                ) catch @panic("failed to read gen/runtime.c");
                patched_runtime_src = patchRuntimeArmShifts(b.graph.arena, raw_rt);
                continue;
            }

            const duped = b.graph.arena.dupe(u8, entry.name) catch @panic("OOM");
            if (std.mem.eql(u8, duped, "game_entry.c")) {
                has_game_entry = true;
            }
            c_files.append(b.graph.arena, duped) catch @panic("OOM");
        }
    } else |_| {}

    if (!has_game_entry) {
        const fail_step = b.addFail("gen/ is not populated; run 'zig build translate' first");
        b.getInstallStep().dependOn(&fail_step.step);
        return;
    }

    std.mem.sort([]const u8, c_files.items, {}, stringLessThan);

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

    awre_mod.addCSourceFiles(.{
        .root = b.path("gen"),
        .files = c_files.items,
        .flags = gen_c_flags,
    });
    if (patched_runtime_src) |rt_src| {
        const wf_rt = b.addWriteFiles();
        const patched_rt = wf_rt.add("runtime.c", rt_src);
        awre_mod.addCSourceFile(.{
            .file = patched_rt,
            .flags = gen_c_flags,
        });
    }

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
