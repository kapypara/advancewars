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

fn replaceOnce(
    allocator: std.mem.Allocator,
    src: []const u8,
    needle: []const u8,
    replacement: []const u8,
    label: []const u8,
) []const u8 {
    const idx = std.mem.indexOf(u8, src, needle) orelse {
        std.debug.panic("gen/runtime.c temporary patch target not found: {s}", .{label});
    };
    return std.mem.concat(allocator, u8, &.{
        src[0..idx],
        replacement,
        src[idx + needle.len ..],
    }) catch @panic("OOM");
}

/// Temporary Phase 3C build-time fixes for `gen/runtime.c` (keeping `ext/gbarecomp`
/// untouched; removed automatically in Phase 4 when `runtime.c` is ported to Zig):
///   1. ARM register-shift-by-0 no-op (`ROR Rs` / `LSR Rs` / `ASR Rs` when `Rs == 0`).
///   2. Atomic `LDM`/`STM` register transfer before charging cycles/delivering IRQs.
///   3. Bounds-check GBA region `0x04` (`0x04000000..0x040003FF`) so unmapped writes
///      do not wrap onto live LCD registers.
///   4. Export `ewram`/`iwram` pointers for side-effect-free PPU/touch/audio peeks.
fn patchRuntimeTemp(allocator: std.mem.Allocator, src: []const u8) []const u8 {
    var out = src;

    // 1. ARM register-shift-by-0 fix
    out = replaceOnce(allocator, out,
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
    ,
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
    , "arm-register-shifts");

    // 2. Atomic ARM LDM/STM transfer before charging cycles (prevents mid-STMDB IRQ stack smash)
    out = replaceOnce(allocator, out,
        \\                u32 addr2 = start;
        \\                for (int i2 = 0; i2 < 16; i2++) {
        \\                    if (!(rlist & (1 << i2))) continue;
        \\                    if (l) {
        \\                        r[i2] = bus_read32(addr2);
        \\                        if (i2 == 15) {
        \\                            pc = r[15] & ~3u;
        \\                            u8 reg3 = pc >> 24;
        \\                            if (reg3 != 0x00 && reg3 != 0x02 && reg3 != 0x03 && reg3 != 0x08) {
        \\                                static int _lmpc = 0;
        \\                                if (_lmpc++ < 5)
        \\                                    fprintf(stderr, "[interp] LDM pc <- 0x%08X from [0x%08X] rlist=0x%04X (S=%d) base=0x%08X\n",
        \\                                            pc, addr2, rlist, s_bit2, r[rn_idx]);
        \\                            }
        \\                        }
        \\                    } else {
        \\                        bus_write32(addr2, r[i2]);
        \\                    }
        \\                    addr2 += 4;
        \\                }
        \\                if (w) r[rn_idx] = u ? base + count * 4 : base - count * 4;
        \\                if (l && (rlist & 0x8000)) {
        \\                    if ((r[15] & ~1u) == (return_sentinel & ~1u)) goto done;
        \\                    if ((r[15] >> 24) == 0x08) { g_ret = r[15] | 1u; goto done; }
        \\                }
    ,
        \\                u32 addr2 = start;
        \\                s32 ldm_cycles = 0;
        \\                for (int i2 = 0; i2 < 16; i2++) {
        \\                    if (!(rlist & (1 << i2))) continue;
        \\                    if (l) {
        \\                        ldm_cycles += data_cycles(addr2, 1, 1);
        \\                        r[i2] = read32_(addr2);
        \\                        if (i2 == 15) {
        \\                            pc = r[15] & ~3u;
        \\                            u8 reg3 = pc >> 24;
        \\                            if (reg3 != 0x00 && reg3 != 0x02 && reg3 != 0x03 && reg3 != 0x08) {
        \\                                static int _lmpc = 0;
        \\                                if (_lmpc++ < 5)
        \\                                    fprintf(stderr, "[interp] LDM pc <- 0x%08X from [0x%08X] rlist=0x%04X (S=%d) base=0x%08X\n",
        \\                                            pc, addr2, rlist, s_bit2, r[rn_idx]);
        \\                            }
        \\                        }
        \\                    } else {
        \\                        bus_write32_(addr2, r[i2]);
        \\                        ldm_cycles += data_cycles(addr2, 1, 0);
        \\                    }
        \\                    addr2 += 4;
        \\                }
        \\                if (w && (!l || !(rlist & (1 << rn_idx))))
        \\                    r[rn_idx] = u ? base + count * 4 : base - count * 4;
        \\                if (ldm_cycles) charge(ldm_cycles);
        \\                if (l && (rlist & 0x8000)) {
        \\                    if ((r[15] & ~1u) == (return_sentinel & ~1u)) goto done;
        \\                    if ((r[15] >> 24) == 0x08) { g_ret = r[15] | 1u; goto done; }
        \\                }
    , "arm-ldm-stm-atomic");

    // 3. Bounds-check I/O region 0x04 (< 0x400) so unmapped open-bus writes don't mirror onto LCD regs
    out = replaceOnce(allocator, out,
        \\    case 0x04: {
        \\        offset = addr & 0x3FF;
        \\        /* Timer counter reads return the running counter, not the reload */
    ,
        \\    case 0x04: {
        \\        if ((addr & 0x00FFFFFFu) >= 0x400u) return 0;
        \\        offset = addr & 0x3FF;
        \\        /* Timer counter reads return the running counter, not the reload */
    , "io-bounds-read32");
    out = replaceOnce(allocator, out,
        \\    case 0x04: {
        \\        offset = addr & 0x3FF;
        \\        /* Timer counter reads */
    ,
        \\    case 0x04: {
        \\        if ((addr & 0x00FFFFFFu) >= 0x400u) return 0;
        \\        offset = addr & 0x3FF;
        \\        /* Timer counter reads */
    , "io-bounds-read16");
    out = replaceOnce(allocator, out,
        \\    case 0x04: return io_regs[addr & 0x3FF];
    ,
        \\    case 0x04: return ((addr & 0x00FFFFFFu) >= 0x400u) ? 0 : io_regs[addr & 0x3FF];
    , "io-bounds-read8");
    out = replaceOnce(allocator, out,
        \\    case 0x04: {
        \\        u32 off = addr & 0x3FF;
        \\        /* IF register: write-1-to-clear semantics */
    ,
        \\    case 0x04: {
        \\        if ((addr & 0x00FFFFFFu) >= 0x400u) break;
        \\        u32 off = addr & 0x3FF;
        \\        /* IF register: write-1-to-clear semantics */
    , "io-bounds-write32");
    out = replaceOnce(allocator, out,
        \\    case 0x04: {
        \\        u32 off = addr & 0x3FF;
        \\        /* IF register: write-1-to-clear */
    ,
        \\    case 0x04: {
        \\        if ((addr & 0x00FFFFFFu) >= 0x400u) break;
        \\        u32 off = addr & 0x3FF;
        \\        /* IF register: write-1-to-clear */
    , "io-bounds-write16");
    out = replaceOnce(allocator, out,
        \\    case 0x04: {
        \\        u32 off = addr & 0x3FF;
        \\        /* IF byte write: write-1-to-clear */
    ,
        \\    case 0x04: {
        \\        if ((addr & 0x00FFFFFFu) >= 0x400u) break;
        \\        u32 off = addr & 0x3FF;
        \\        /* IF byte write: write-1-to-clear */
    , "io-bounds-write8");

    // 4. Expose EWRAM/IWRAM pointers for zero-side-effect PPU/audio/touch peeks
    out = replaceOnce(allocator, out,
        \\static u8* ewram     = NULL;  /* 256KB */
        \\static u8* iwram     = NULL;  /* 32KB */
    ,
        \\u8* ewram     = NULL;  /* 256KB */
        \\u8* iwram     = NULL;  /* 32KB */
    , "expose-ewram-iwram");

    return out;
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
                patched_runtime_src = patchRuntimeTemp(b.graph.arena, raw_rt);
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
