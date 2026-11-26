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
- **Phase 3B — Pure Touch Controls (`src/zig/touch.zig`) (Done):**
  - **Tier 1 (Corner HUD):** minimal translucent rounded pills (`L`, `ST`, `R`, `B`, `A`, toggleable with `F2`) mapped to GBA `KEYINPUT`, supporting simultaneous multi-touch/pointer holds.
  - **Tier 2 (Native direct-touch & gestures):** samples Advance Wars cursor (`0x030036A4`/`0x030036A6`), active map/dialog flags (`0x030036AC`, `0x030033E0`, `0x03001D18`), and `BG3HOFS`/`BG3VOFS` to navigate directly to tapped map tiles (with stall guard), tap-to-confirm on the active tile, swipe menus/maps, and tap through title/dialog screens.
  - Wired into `display_abi.zig` and `platform_sdl2.zig` (mouse + touch finger events) in live mode only; headless conformance (`165/165`) and BMP parity (`0 bytes diff`) remain untouched.
- **Phase 3C — GBA Audio Mixer (`src/zig/audio.zig`) (Done):**
  - Pure-Zig GBA DirectSound A/B mixer reading `SOUNDCNT_H`/`SOUNDCNT_X`, `TM0CNT_L`, `DMA1`/`DMA2`, and `m4a` `SoundInfo` (`0x03007FF0` -> `"Smsh"` + `pcmDmaCounter`) to extract each frame's 224-sample stereo ring slice (~13.38 kHz) and continuously resample it to 48 kHz stereo `i16` over SDL2 audio (`F3` or `M` toggles mute).
  - Upgraded DSP & timing: 2-sample-shifted 4-tap Catmull-Rom cubic Hermite resampler (C1 cross-frame continuity, zero boundary clamping), stereo 2-pole Butterworth low-pass (`fc = 6000 Hz`, `Q = 1/sqrt(2)`), 1-pole DC blocker (`alpha = 0.995`), stale `pcmDmaCounter` silence guard (`>= 2` stuck frames), ±1.5% dynamic rate control targeting `10,560` queued bytes (~55 ms), ~45 ms SDL pre-buffer before unpause, high-resolution GBA-clock frame pacing (`280896 / 16777216 = 16.743 ms`), and removed `SDL_RENDERER_PRESENTVSYNC` so 60.0 Hz VSync no longer fights 59.73 Hz GBA pacing.
  - Temporary build-time `gen/runtime.c` fix (`patchRuntimeArmShifts` in `build.zig`, removed automatically when `runtime.c` is replaced in Phase 4): fixed ARM7TDMI interpreter register-shift-by-0 (`ROR Rs` / `LSR Rs` / `ASR Rs` with `Rs == 0` wrongly executing `RRX` / `>> 32`), eliminating `±128` byte-rotation spikes when `m4a`'s IWRAM `SoundMainRAM` (`0x03000C0C`/`0x03000C10`) ends a sample (`F1211` `intra_a`/`intra_b` dropped from `129`/`131` to `40`/`47`; `F2511` dropped from `133`/`134` to `15`/`15`).
  - Verified with `zig build test`, `zig build -Dheadless=true`, `zig build`, `165/165` conformance, `0 bytes diff` BMP parity, and native Arch Linux `ldd` + 10-frame run.

## Phase 4 — Incremental GBA Runtime Port (`runtime.c` -> Zig)
- Port `ext/gbarecomp/src/runtime.c` module-by-module behind the same C ABI (`memory.zig`, `flash.zig`, `dma.zig`, `timers.zig`, `irq.zig`, `bios.zig`, `interp.zig`).
- Avoid host `setjmp`/`longjmp` in the Zig runtime (use clean state flags for SoftReset) so the exact same Zig runtime compiles cleanly for Linux and WASM.
- Keep `conformance.py` (`165/165`) and Mission 1 & 2 headless replays (`tools/field_training_win.txt`, `tools/field_training_m2.txt`) green in Podman after each module swap.

## Phase 5 — WebAssembly Browser Port (`wasm32-freestanding`)
- Compile the pure Zig core + runtime to `wasm32-freestanding` running inside a Web Worker (60 Hz loop without blocking the browser UI thread or pulling in Emscripten), serving desktop and mobile browsers (with pure touch controls).
- Minimal browser JS shell (~150 lines) presenting the `240x160` framebuffer via Canvas2D / WebGL2, AudioWorklet audio, browser Pointer/Touch events wired into `touch.zig`, local ROM file drop (never uploaded), and 64 KB Flash persistence in `IndexedDB`.

## Phase 6 — Full Zig Recompiler (`ext/gbarecomp` -> Zig)
- Port `gbarecomp`'s ROM loader, ARM/Thumb decoders, CFG/entry-point analyzer, and code generator (`src/rom.c`, `arm.c`, `thumb.c`, `disasm.c`, `analysis.c`, `translate.c`, `main.c`) into Zig (`src/recomp/`), emitting pure `.zig` instead of C.
- Eliminate all remaining C code, C flags (`.sanitize_c = .off`, `-std=gnu11`, `-O1`), and CMake/Clang/GCC tooling across Linux and WASM for 100% pure, fully-optimized Zig (`ReleaseFast`).

## Phase 7 — Post-Port Polish & Native UX Enhancements (After Main Plan)
- **Direct UI/Menu Mouse & Touch Hooking:** Hook Advance Wars' non-map UI screens (name entry character grid + `BACK`/`OK!`, title/main menus, unit action menus, CO select) for direct tap/click selection.
- **Outside-Frame Touch Controls:** Render touch buttons in window/screen pillarbox and letterbox margins outside the aspect-preserved game viewport whenever extra screen space is available.
- **Widescreen / Wider Viewport Mode:** Extend the Zig PPU beyond `240x160` for mobile and desktop widescreen screens.

## Deferred / Optional (Skipped for Now)
- **Android Native Port (`aarch64-linux-android` + Pure Touch APK):** Deferred indefinitely in favor of the Phase 5 WebAssembly port for mobile browser play with touch controls; can be revisited later using `zig build -Dtarget=aarch64-linux-android` + `touch.zig`.
