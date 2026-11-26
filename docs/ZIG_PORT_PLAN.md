# Advance Wars Static Recompilation — Zig & Pure Touch Port Roadmap

Target workspace: `/home/moon/Projects/zig/advancewars` (branch `zig-port`).
All builds, translation, headless smoke tests, and conformance checks run reproducibly via Podman Compose (`Containerfile` + `compose.yaml`).

---

## Phase 1 — Linux + Podman Compose Baseline & Save Verification (Done)
- Cloned `sp00nznet/advancewars` recursively with pinned `ext/gbarecomp` submodule (`ac1176f`) into `/home/moon/Projects/zig/advancewars` on branch `zig-port`.
- Copied user ROM (`game/aw.gba`, SHA-1 `15053499d5b3f49128a941d7f2d84876f5424d0c`) and user backup save (`game/saves/user.srm` -> `game/aw.sav`, 64 KB `FLASH_V121`, SHA-256 `bb3b5651dd61b18f01dc0225e389d4d3251c7bc30706aedb97c4eb74e3644622`) read-only from backup.
- Added `Containerfile`, `compose.yaml`, `scripts/build.sh`, and Linux CMake compatibility in root `CMakeLists.txt` (`-lm`, `SDL2::SDL2main` fallback, 16 MB stack).
- Verified inside Podman (`podman compose run --rm dev ...`):
  - `gbarecomp` built and translated `game/aw.gba` -> `gen/` (7,577 functions, 64,740 basic blocks, 80 generated files).
  - `build/AWRE` built natively for Linux and links `libSDL2-2.0.so.0`, `libm.so.6`, `libc.so.6`.
  - Lockstep conformance passed (`165/165 functions agree`).
  - Headless Field Training replay (`tools/field_training.txt`, 8,000 frames) and Mission 1 win + save (`tools/field_training_win.txt`, 28,200 frames) rendered cleanly.
  - Flash `.srm` / `.sav` load & save round-trip verified (note: the backed-up `Advance Wars.srm` itself is from initial boot right before entering a name; saving after Mission 1 and rebooting confirmed `game/aw.sav` reloads straight into Field Training with Troop Orders Rank A and Terrain Intel unlocked).

## Phase 2 — Zig Build System (`build.zig`) (Done)
- Installed Zig `0.17.1` (SHA-256 verified) in `Containerfile`, mounted persistent `zig-cache` volume in `compose.yaml`, and added `.zig-cache/` and `zig-out/` to `.gitignore`.
- Added `build.zig`, `build.zig.zon`, `src/zig/root.zig`, `scripts/conformance.sh`, and `scripts/smoke.sh`:
  - `zig build test` — runs Zig unit tests in `src/zig/root.zig`.
  - `zig build recompiler` — compiles `ext/gbarecomp` via Zig's C toolchain (`zig-out/bin/gbarecomp`).
  - `zig build translate` — translates `game/aw.gba` -> `gen/`.
  - `zig build` (and `-Dheadless=true`) — compiles `gen/` C TUs (`-std=gnu11 -O1`, `.sanitize_c = .off`) + `awre_zig` static library (`awre_zig_abi_version`) into `zig-out/bin/awre`.
  - `zig build conformance` — runs `conformance.py` against a temporary scratch ROM symlink (`165/165 functions agree`) without touching `game/aw.sav`.
  - `zig build smoke` — runs the 8,000-frame headless Field Training replay (`scratch/zig_field_training.png`) without touching `game/aw.sav`.

## Phase 3 — Display/PPU, Platform Interface, Pure Touch & Audio in Zig (`src/zig/`)
Behind one thin, backend-agnostic `Platform` interface (no `wgpu-native` bloat: SDL2 on Linux first, pure Zig `ANativeActivity` + GLES3/Vulkan on Android, WebGPU/WebGL2/Canvas2D on WASM):
- **Phase 3A — Zig PPU, Headless Runner & SDL2 Backend (Done):**
  - `src/zig/gba.zig` / `src/zig/ppu.zig` — per-scanline GBA PPU renderer (Modes 0/3/4, regular & affine sprites, affine BGs, windows, alpha/brightness blends). Verified **0 bytes difference** against the C PPU across `title.txt` (1,550 frames), `field_training.txt` (8,000 frames), and `field_training_win.txt` (26,320 frames).
  - `src/zig/headless.zig` — `--headless`, `--frames`, `--input`, `--screenshot` (BMP), `--dump-at`, `--record`.
  - `src/zig/platform.zig` / `src/zig/platform_sdl2.zig` — resizable Wayland/X11 SDL2 window (`F11` fullscreen, nearest-neighbor logical `240x160` scaling), keyboard + mouse/touch pointer capture via `b.addTranslateC`.
  - `src/zig/display_abi.zig` — replaces `gen/display.c` completely behind the `display_*` C ABI (`gen/display.c` is no longer compiled; `forceUndefinedSymbol` and `awre_zig_abi_version` removed).
  - `zig build test`, `zig build -Dheadless=true`, `zig build`, and `zig build conformance` (`165/165 functions agree`) all pass in Podman.
- **Phase 3B — Pure Touch Controls (`touch.zig`):**
  - **Tier 1 (Universal fallback):** clean contextual touch gestures & minimal on-screen action buttons (`A`, `B`, `L`, `R`, `Start`, `Select`) mapped to GBA `KEYINPUT` so all screens/menus/dialogs work immediately across Linux touchscreen/mouse, Android, and WASM.
  - **Tier 2 (Native direct-touch):** read live cursor coordinates, camera scroll (`BGHOFS`/`BGVOFS`), and active menu/UI state directly from GBA RAM so players can tap map tiles/units directly, drag to pan, and tap menu items natively.
- **Phase 3C — GBA Audio Mixer (`audio.zig`):**
  - GBA DirectSound FIFO (DMA1/DMA2 + Timer 0/1) & PSG mixer feeding native Linux audio, Android AAudio, and WASM AudioWorklet.

## Phase 4 — Incremental GBA Runtime Port (`runtime.c` -> Zig)
- Port `ext/gbarecomp/src/runtime.c` module-by-module behind the same C ABI (`memory.zig`, `flash.zig`, `dma.zig`, `timers.zig`, `irq.zig`, `bios.zig`, `interp.zig`).
- Avoid host `setjmp`/`longjmp` in the Zig runtime (use clean state flags for SoftReset) so the exact same Zig runtime compiles cleanly for Linux, Android, and WASM.
- Keep `conformance.py` (`165/165`) and Mission 1 & 2 headless replays (`tools/field_training_win.txt`, `tools/field_training_m2.txt`) green in Podman after each module swap.

## Phase 5 — Android Port (`aarch64-linux-android` + Pure Touch APK)
- Add Android NDK + minimal SDK build-tools (`aapt2`, `d8`, `apksigner`) to a Podman Android build target (`Containerfile.android` / compose service).
- Cross-compile `libawre.so` via `zig build -Dtarget=aarch64-linux-android` (pure Zig `ANativeActivity` + GLES3/Vulkan framebuffer presentation + AAudio + native `AMotionEvent` wired into `touch.zig`).
- Package signed APK with app-scoped storage loading for `aw.gba` and `aw.sav`.

## Phase 6 — WebAssembly Browser Port (`wasm32-freestanding`)
- Compile the pure Zig core + runtime to `wasm32-freestanding` running inside a Web Worker (60 Hz loop without blocking the browser UI thread or pulling in Emscripten).
- Minimal browser JS shell (~150 lines) presenting the `240x160` framebuffer via WebGPU (with automatic WebGL2/Canvas2D fallback), AudioWorklet audio, browser Pointer/Touch events wired into `touch.zig`, local ROM file drop (never uploaded), and 64 KB Flash persistence in `IndexedDB`.

## Phase 7 — Full Zig Recompiler (`ext/gbarecomp` -> Zig)
- Port `gbarecomp`'s ROM loader, ARM/Thumb decoders, CFG/entry-point analyzer, and code generator (`src/rom.c`, `arm.c`, `thumb.c`, `disasm.c`, `analysis.c`, `translate.c`, `main.c`) into Zig (`src/recomp/`), emitting pure `.zig` instead of C.
- Eliminate all remaining C code, C flags (`.sanitize_c = .off`, `-std=gnu11`, `-O1`), and CMake/Clang/GCC tooling across Linux, Android, and WASM for 100% pure, fully-optimized Zig (`ReleaseFast`).
