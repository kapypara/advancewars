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

## Phase 2 — Zig Build System (`build.zig`)
- Add Zig `0.17.1` to `Containerfile`.
- Add `build.zig` and `build.zig.zon` at repo root to replace the CMake/shell orchestration:
  - `zig build recompiler` — compiles `ext/gbarecomp` using Zig's C toolchain.
  - `zig build translate` — translates `game/aw.gba` -> `gen/`.
  - `zig build` — compiles `gen/` C TUs (`-O1`) + Zig sources into `zig-out/bin/awre`.
  - `zig build test` / `zig build conformance` — runs Zig unit tests, headless replays, and `165/165` lockstep validation inside Podman.

## Phase 3 — Display/PPU, Audio & Pure Touch Controls in Zig (`src/zig/`)
- Replace `display.c` behind the existing `display_*` C ABI:
  - `ppu.zig` — per-scanline GBA PPU renderer (Modes 0/3/4, sprites, affine BG/OBJ, windows, alpha/brightness blends, plus PPU mosaic). Verified pixel-for-pixel against C PPU on headless replays.
  - `headless.zig` — `--headless`, `--frames`, `--input`, `--screenshot` (BMP/PNG), `--record`.
  - `platform_sdl.zig` — native Linux Wayland/X11 SDL2 window, crisp integer/nearest scaling, keyboard + mouse/touch pointer input.
  - `touch.zig` — Pure Touch Controls:
    - **Tier 1 (Universal fallback):** clean contextual touch gestures & minimal on-screen action buttons (`A`, `B`, `L`, `R`, `Start`, `Select`) mapped to GBA `KEYINPUT` so all screens/menus/dialogs work immediately.
    - **Tier 2 (Native direct-touch):** read live cursor coordinates, camera scroll (`BGHOFS`/`BGVOFS`), and active menu/UI state directly from GBA RAM so players can tap map tiles/units directly, drag to pan, and tap menu items natively.
  - `audio.zig` — GBA DirectSound FIFO (DMA1/DMA2 + Timer 0/1) & PSG mixer feeding native Linux audio and later Android audio.

## Phase 4 — Incremental GBA Runtime Port (`runtime.c` -> Zig)
- Port `ext/gbarecomp/src/runtime.c` module-by-module behind the same C ABI (`memory.zig`, `flash.zig`, `dma.zig`, `timers.zig`, `irq.zig`, `bios.zig`, `interp.zig`).
- Keep `conformance.py` (`165/165`) and Mission 1 & 2 headless replays (`tools/field_training_win.txt`, `tools/field_training_m2.txt`) green in Podman after each module swap.

## Phase 5 — Android Port (`aarch64-linux-android` + Pure Touch APK)
- Add Android NDK + minimal SDK build-tools (`aapt2`, `d8`, `apksigner`) to a Podman Android build target (`Containerfile.android` / compose service).
- Cross-compile `libawre.so` via `zig build -Dtarget=aarch64-linux-android` (with `ANativeActivity` + GLES2 framebuffer presentation + AAudio/OpenSL + `touch.zig`).
- Package signed APK with app-scoped storage loading for `aw.gba` and `aw.sav`.

## Phase 6 — Full Zig Recompiler (`ext/gbarecomp` -> Zig)
- Port `gbarecomp`'s ROM loader, ARM/Thumb decoders, CFG/entry-point analyzer, and C/Zig code generator (`src/rom.c`, `arm.c`, `thumb.c`, `disasm.c`, `analysis.c`, `translate.c`, `main.c`) into Zig (`src/recomp/`).
- Eliminate the remaining C toolchain dependency for the toolkit itself while preserving `165/165` conformance and full replay parity.
