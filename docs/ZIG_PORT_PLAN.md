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
  - Temporary build-time `gen/runtime.c` fixes (`patchRuntimeTemp` in `build.zig`, removed automatically when `runtime.c` is replaced in Phase 4):
    - Fixed ARM7TDMI interpreter register-shift-by-0 (`ROR Rs` / `LSR Rs` / `ASR Rs` with `Rs == 0` wrongly executing `RRX` / `>> 32`), eliminating `±128` byte-rotation spikes when `m4a`'s IWRAM `SoundMainRAM` (`0x03000C0C`/`0x03000C10`) ends a sample (`F1211` `intra_a`/`intra_b` dropped from `129`/`131` to `40`/`47`; `F2511` dropped from `133`/`134` to `15`/`15`).
    - Made interpreter `LDM`/`STM` register transfers + writeback atomic before `charge()` (preventing mid-`STMDB` HBlank IRQ stack smash that corrupted `BG1CNT`/`BG2X`/`WIN0H` on frame `931`), bounds-checked I/O region `0x04` (`< 0x400`), and exposed `ewram`/`iwram` for zero-side-effect `display_abi.zig` peeks.
  - Added continuous `--dump-dir <dir>` per-frame `.bmp` + `.bin` state + `frames.log` debugging mode (see `docs/DEBUG_DUMPING.md`).
  - Verified with `zig build test`, `zig build -Dheadless=true`, `zig build`, `165/165` conformance, `0 bytes diff` BMP parity, exact replay of frame `931` (`BG1CNT=0x5E02`, `BG2X=0x00000000`, `WIN0H=0x00F0`), and native Arch Linux `ldd` + 10-frame run.

## Phase 4 — GBA Runtime Port (`runtime.c` -> Zig) (Done)
- Replaced `gen/runtime.c` and removed all temporary `build.zig` runtime C patching (`patchRuntimeTemp` / `replaceOnce`) with pure-Zig runtime modules behind the exact `gba_runtime.h` C ABI:
  - `src/zig/runtime/flash.zig` (`FLASH_V`/`FLASH512_V`/`FLASH1M_V` Flash command state machine + data# busy polling, `EEPROM_V` bit-serial protocol).
  - `src/zig/runtime/timers.zig` (4-channel GBA hardware timers, prescalers, overflow IRQs, cascading).
  - `src/zig/runtime/dma.zig` (4-channel GBA DMA controller with immediate/VBlank/HBlank triggers, address latching, repeat/reload, DMA IRQs).
  - `src/zig/runtime/bios.zig` (HLE BIOS SWIs including flag-based `SoftReset` unwind via `g_ret = 0xFFFFFFFF` with zero `setjmp`/`longjmp`, `IntrWait`/`VBlankIntrWait`, `Div`/`DivArm`, `Sqrt`, `ArcTan`/`ArcTan2`, `CpuSet`/`CpuFastSet`, `BgAffineSet`/`ObjAffineSet`, `BitUnPack`, `LZ77UnCompWram`/`Vram`, `RLUnCompWram`/`Vram`).
  - `src/zig/runtime/interp.zig` (ARM + Thumb interpreter for RAM/uncompiled-ROM calls with native ARM register-shift-by-0 fix and atomic `LDM`/`STM` register transfer/writeback before cycle charge).
  - `src/zig/runtime/validate.zig` + host-only `src/zig/runtime/validate_jmp.c` (lockstep `GBA_VALIDATE` harness gated off for `freestanding` targets).
  - `src/zig/runtime_abi.zig` & `src/zig/abi_root.zig` (static `.bss` GBA memory arrays, waitstate/VRAM-stall scheduler, `< 0x400` bounds-checked I/O bus, interrupt delivery, host `.sav`/`.eep` persistence, `display_abi.zig` direct module sharing).
- Verified all 5 core runtime modules (`flash`, `timers`, `dma`, `bios`, `interp`) compile cleanly to `wasm32-freestanding`.
- Verified in Podman (`Debug` and `ReleaseFast`, without modifying `game/aw.sav` or `ext/gbarecomp`):
  - `zig build test`: `33/33` unit tests pass.
  - `zig build -Dheadless=true` & `zig build`: compile and link with zero `gen/runtime.c` or `gen/display.c`.
  - `zig build conformance`: `165/165 functions agree`.
  - Pixel-exact BMP parity (`0 bytes diff`) against `ref_title.bmp` (1,550 frames), `ref_ft.bmp` (8,000 frames, both `Debug` and `ReleaseFast`), and `ref_win.bmp` (26,320 frames), plus full 54,600-frame `tools/field_training_m2.txt` Mission 2 replay and 64 KB Flash `.sav` round-trip.
  - Re-verified frame `931` (`--dump-dir` + `BG1CNT=0x5E02`, `BG2X=0x00000000`, `WIN0H=0x00F0` and matching `frames.log`) and clean `F1211`/`F2511` `m4a` PCM buffers (max step `<= 31`).

## Phase 5 — WebAssembly Browser Port (`wasm32-freestanding`) (Done)
- Built 100% pure-Zig `wasm32-freestanding` target (`zig build wasm` -> `zig-out/web/awre.wasm`: `17,805,156` bytes raw / `4,659,002` bytes gzipped with `game/aw.gba` embedded, `0` C files, `0` libc; `1.584s` incremental build; `-Dembed-rom=false` omits the embedded ROM) running inside a Web Worker (`src/wasm_main.zig`, `src/platform/wasm.zig`, `.rdynamic = false`, `10` exported WASM symbols: `memory` + 9 `awre_*` entrypoints including `awre_has_embedded_rom`).
- Minimal browser shell under `web/` (`index.html`, `style.css`, `main.js`, `worker.js`, `audio-worklet.js`) plus COOP/COEP dev server (`scripts/serve_web.py`):
  - Zero-click auto-boot of the embedded ROM via `gba_init_memory(0)` (falling back to the ROM overlay on `-Dembed-rom=false` while keeping manual `.gba` file load/drag-drop, `.sav` import/export, and `IndexedDB` Flash persistence on `flash_state.dirty` flush).
  - Exact `3:2` `ResizeObserver`-driven Canvas2D (`fitCanvas()`) + 48 kHz stereo `AudioWorklet` unlocked on user gesture and fed over `SharedArrayBuffer` (with initial HUD/Mute toggle sync in `web/worker.js`).
  - Browser Pointer/Touch + keyboard + mouse right-click (`B`) + scroll wheel (`Up`/`Down`) wired into `src/platform/touch.zig` (and matched across SDL2 native desktop in `src/platform/sdl2.zig`), with a `3`-frame minimum latch (`min_button_frames = 3`) so same-frame HUD clicks and fast right-clicks never drop, right-click pointer capture + stage/conditional context-menu suppression + `window`-level release/blur failsafes preventing stuck `B`, and `soft_reset_pending` unwind guards in `src/runtime.zig` for clean WASM stop exit.
- Verified via Node.js (`v26.13.1`) instantiating `zig-out/web/awre.wasm`:
  - `awre_has_embedded_rom() === 1`, `awre_init_wasm(0) === 0`; `replays/title.txt` (`1,550`-frame **`0` pixel diff** vs `scratch/ref_title.bmp`; `1,620` frames in `2.53s`), `1` save event (`65,536` bytes), `1,570` audio chunks (`1,343` non-zero).
  - Interactive menu check (`1,560` frames in `2.47s`): same-frame HUD `B` click `(205, 149)` backs out cleanly, subsequent `A` re-enters (proving `B` does not stick), same-frame right-click backs out again, and `awre_run_wasm()` unwinds cleanly at frame `1,560`.
  - `-Dembed-rom=false`: `awre_has_embedded_rom() === 0` and `awre_init_wasm(0) === -1`.

## Phase 6 — Full Zig Recompiler (`ext/gbarecomp` -> Zig) & Pure-Zig Build (Done)
Executed before Phase 5 to eliminate generated C sources and CMake/Clang compiler workarounds first:
- Ported `gbarecomp` into pure Zig (`src/recomp/{types,rom,arm,thumb,analysis,translate_zig,main}.zig`), adding ARM/Thumb decoders, recursive-descent + prologue + jump-table + code-pointer analysis (`7,577` functions, `64,740` basic blocks), block-level iterative Tarjan SCC owner unification (eliminating cross-owner loop cycles with zero block duplication), split-`BL` handling, dual-use `POP+BX` veneer detection, and parallel shard emission (`gen/zig/`).
- Replaced C `gen/*.c` compilation, `src/zig/abi_root.zig`, `gen_c_flags`, `.sanitize_c = .off`, and `-lm` in `build.zig` with pure-Zig entry (`src/zig/main.zig`), shared shard ABI (`src/zig/rt_shard.zig`), external declarations (`gen/zig/decls.zig`), BX dispatch (`gen/zig/game.zig`), and parallel `b.addObject` compilation across all 62 generated shards (keeping `src/zig/runtime/validate_jmp.c` strictly conditional on non-freestanding hosts for `GBA_VALIDATE`).
- Generated `gen/zig/` output: `41 MB` / `1,121,323` total lines (`60` func shards + `1` stub shard + `unresolved.zig` + `decls.zig` + `game.zig`; `7,577` functions, `151` stubs, `78` unresolved, `70,705` unique blocks emitted, `947` delegated) — vs `257 MB` / `~8.87M` lines in C.
- Verified in Podman (`podman compose run --rm dev ...`, without modifying `game/aw.sav` or `ext/gbarecomp`):
  - `zig build test --summary all`: all `awre_core` and `recomp` (`7/7`) unit tests pass.
  - Build & translate times: `zig build translate` takes `0.901s` cached (`24.248s` cold including `gbarecomp` fast compile); `zig build -Dheadless=true` Debug takes `5.951s`; `zig build` SDL Debug takes `5.789s` (reusing cached shards); cold `zig build -Doptimize=ReleaseFast` across 16 CPU cores takes `50.923s` (and `13.600s` / `13.639s` on an incremental `src/zig/ppu.zig` edit).
  - Lockstep conformance (`zig build conformance` and `zig build -Doptimize=ReleaseFast conformance`): `165/165 functions agree` on both `Debug` and `ReleaseFast`.
  - Pixel-exact BMP parity (`cmp -s`, `0 bytes diff`) in `ReleaseFast` against `ref_title.bmp` (`1,550` frames in `0.910s`), `ref_ft.bmp` (`8,000` frames in `5.128s`), and `ref_win.bmp` (`26,320` frames in `17.571s`).
  - Full Mission 2 replay (`tools/field_training_m2.txt`, `54,600` frames) completed cleanly in `35.541s` (~1,536 FPS) and 64 KB Flash `.sav` round-trip (`28,200` frames, `2,323` non-`0xFF` bytes written and reloaded cleanly) passed.
  - Native Arch Linux host check (`ldd zig-out/bin/awre` linking `libSDL2-2.0.so.0` + `libc.so.6` without `libm`, plus 10-frame headless smoke run) passed.

### Tree Cleanup & Reorganization (Post-Phase 6, Done)
- Removed legacy C/CMake/Windows leftovers (`build/`, `CMakeLists.txt`, `build.cmd`, `Setup.cmd`, `scripts/build.sh`, `tools/qa.cmd`, `tools/setup.ps1`, old `gen/*.c`/`*.h`, `.cache/`, old `.zig-cache/`, `scratch/edge_dump/`) and dropped the `ext/gbarecomp` submodule (inlining the conformance runner directly into `scripts/conformance.sh`), while keeping `ROADMAP.md` as historical reference.
- Reorganized sources cleanly by layer:
  - `src/zig/{gba,ppu,audio}.zig` + `src/zig/runtime/{bios,dma,flash,interp,timers}.zig` -> `src/gba/` (`defs.zig`, `ppu.zig`, `audio.zig`, `bios.zig`, `dma.zig`, `flash.zig`, `interp.zig`, `timers.zig`)
  - `src/zig/{display_abi,headless,touch,platform,platform_sdl2}.zig` -> `src/platform/` (`display.zig`, `headless.zig`, `touch.zig`, `backend.zig`, `sdl2.zig`)
  - `src/zig/runtime/{validate.zig,validate_jmp.c}` -> `src/validate/` (`validate.zig`, `jmp.c`)
  - `src/zig/{main,root,runtime_abi,rt_shard}.zig` -> `src/{main,root,runtime,shard}.zig`, `src/recomp/translate_zig.zig` -> `src/recomp/translate.zig`, `gen/zig/` -> `gen/`, `tools/*.txt` -> `replays/*.txt`.

## Phase 7 — Post-Port Polish, Smart Touch/Mouse & Native UX Enhancements (Done)
- **Milestone 7A — Web Chrome Redesign & Unified Pixel HUD / Outside-Frame Controls (Done):**
  - Clean dark-slate top bar with inline monochrome wrench SVG, collapsible `Hide` toggle with middle-right (landscape) / middle-bottom (portrait) restore tab, conditional `Load ROM` (hidden when bundled/loaded), auto-fading toast notifications, and no bottom statusbar / `Stop` / `Full` buttons.
  - Shared `TouchController.renderHudLayer` pixel-art HUD rendered onto a separate transparent `(hud_w x 160)` layer (SDL2 `hud_texture` + Web `<canvas id="hud-canvas">`) so the classic `[L]` / `[ST][R]` / `[B][A]` pixel pills keep their exact corner look and slide smoothly out into horizontal landscape margins without shrinking or overlapping the `3:2` game canvas, plus an ergonomic ~45%/55% portrait handheld split (bezel-framed screen centered in the upper half over a slate lower deck with `L`/`R` shoulders, unified pixel D-Pad, diagonal `B`/`A`, and bottom `SEL`/`ST`) and desktop auto-hide toggleable via `HUD` / `F2`.
- **Milestone 7B — True Advance Wars RAM State Machine + Map & Unit-Range Touch Engine (Done):**
  - Replaced the ambiguous dialog flag with a verified player-agnostic RAM + 40-slot proc state machine (`0x0300_4478 == 0x0803_849D` battle scene, `0x0300_43C8`/`0x0300_4470` modal locks, `0x0300_357C == 5` human turn phase across P1–P4, `0x0300_35EC` substate `0`/`1`, `0x0300_0E10` proc table for dialog `0x0828_0E0C` & frontend root `0x082F_1160`, `0x0201_57F8` map workspace/camera, and `0x0300_3600` EWRAM movement-reachability row pointers).
  - Unit-selected behavior: 1st tap previews path on reachable tiles via BFS (`findReachableNextStep`), 2nd tap on cursor confirms `A`; tapping outside movement range simply cancels/deselects (`B`); dragging smoothly paints a tile-by-tile path preview without auto-confirming; free-map drag mimics finger motion; menus (`.battle_overlay` & `.frontend_menu`) support natural scrolling + tap `A`.
- **Milestone 7C — Direct In-Battle Menu Clicking (Done):**
  - Hooked Action/Map/Options/Intel popup menus (`0x0828_1D60`/`0x0828_1D80` item count/selected/cursor pos) for direct row clicking (same-row `A`, other-row step + auto-confirm `A`, outside tap `B`), Unit List (`0x082E_CF68` visible rows relative to `+0x20` scroll + `<`/`>` column pager arrows, 2-tap select & jump), Attack Target (`0x0828_B56C` 2-tap cycle preview + confirm `A`), Factory / Base / Airport / Port Deploy Shop (`0x0828_BC1C` 7 visible rows relative to `+0x1E` scroll + top/bottom scroll arrows, 2-tap preview & buy), and Battle Intel Status (`0x082E_B550` `<`/`>` tabs & bottom exit) / Officer Dossier (`0x082E_B114` `<L`/`R>` CO switch & page advance), keeping natural scrolling across all overlay menus.
- **Milestone 7D — Direct Campaign & Pre-Battle Menu Clicking (Done):**
  - Hooked universal Yes/No prompts (`0x0828_1CE8` tilemap anchor + selection toggle/confirm), Name Entry character grid (`0x082F_1130` 2D EWRAM cursor navigation + row-4 Left-first guard + `BACK`/`OK!`), Main Menu / Mode Submenu carousel (`0x082F_1BE0` top/center/bottom tap zones), Map Select (`0x082E_BF68` `<L`/`R>` category arrows + 2-tap map rows & minimap confirm), and VS CO / Rules Setup (`0x083B_93C8` / `0x083B_9244`), keeping natural scrolling across every screen.

## Phase 8 — Widescreen / Wider Viewport Mode (Done)
- Extended `src/gba/ppu.zig` (`Ppu.setViewport`, `wide_framebuf` up to `512x160`) and implemented GBA hardware PPU Mosaic (`MOSAIC` `0x0400_004C`) while keeping `framebuf` (`240x160`) untouched for pixel-exact headless parity and BMP dumps.
- Extended wide margins across frontend scenes (`BG3` / `BG2` backmost wallpaper across menus, Hachi's Shop dialogs, and transitions), affine BGs, in-battle full-screen menus (Unit List `0x082E_CF68`, Battle Intel Status `0x082E_B550`, Officer Dossier `0x082E_B114`), and **Battle Map Widescreen** (off-screen terrain, fog-of-war, `prio=3` OAM buildings/properties, and `BG1` units across maps up to `64x64` including `42x15` Ball Islands, with seam-free camera tracking, wide-margin map tapping/path-painting, and extended-margin menu closing), toggleable via `F4` / `Wide` (defaulting ON).

## Phase 9 — Upgraded Wide Renderer (`src/gba/renderer.zig`) & Touch Polish
- **Milestone 9A — Unified Full-Width Scene Compositor (`src/gba/renderer.zig`) (Done):**
  - Separated Advance Wars wide-scene composition out of `src/gba/ppu.zig` into `src/gba/renderer.zig` (`WideScene` + `Ppu.setWideScene`), rendering the entire `0..vw` viewport in one unified pass for terrain/fog (`renderTerrainFull`), visible units (`renderUnitsFull`), and `prio=3` property buildings (`renderPropertiesFull`) with zero center/margin edge seam, plus blended side-margin movement reachability highlights (`renderReachabilityMargins`) and 100% bit-exact `240x160` fallback.
- **Milestone 9B — VS Rules/Teams Direct Touch & Non-Inverted X-Axis Dragging (`src/platform/touch.zig`) (Done):**
  - Added direct touch for VS Rules (`0x083B_9244`: 7 diagonal bubbles, up/down arrows, `PRESS A`, extended-margin `B`) and VS Teams (`0x083B_93C8`: direct player-card selection via `0x0200_0036`, up/down cycling, `PRESS A`, extended-margin `B`).
  - Fixed inverted X-axis menu dragging across `src/platform/touch.zig` so horizontal drags move directly with the pointer/finger (`drag right -> Key.right`, `drag left -> Key.left`), keeping natural scrolling only on vertical Y-axis lists.
- **Milestone 9C — WebGL2 Crisp Pixel Presenter (`web/gl_presenter.js`) (Done):**
  - Added `web/gl_presenter.js` WebGL2 quad presenter with pure `NEAREST` crisp pixel-art sampling (HiDPI backing buffer and automatic Canvas2D fallback) synchronized to a clean `requestAnimationFrame` loop (`0%` idle GPU, zero UI jitter).

## Phase 10 — Mobile UX, Remaining Touch Audit & Next-Gen Renderer
- **Milestone 10A — Software Rotate (`90°`) & IndexedDB Save Slots (Done):**
  - Added an in-page `90°` clockwise rotation toggle (`Rot`) persisted in `localStorage` so portrait-locked phones can play in full wide landscape without enabling OS auto-rotate, updating `fitCanvas()` viewport swapping and inverse-rotated `clientToLogical()` touch coordinates.
  - Added a 3-slot IndexedDB Flash save switcher (`S1`–`S3`, keeping Slot 1 compatible with existing saves) alongside `.sav` export/import and a compact mobile toolbar layout. *(Fast-forward skipped by user preference.)*
- **Milestone 10B — Remaining Screens Touch Audit (Done):**
  - Audited War Room (`0x082E_BF68` map select), Battle Animations / CO Power cut-ins (`.battle_overlay`), Victory / Day banners / Results (`0x0830_9790`), and Design Maps slot menu.
  - Enabled full wide-bounds tap-to-advance across `.battle_overlay`, `.dialog`, `.title`, and `.frontend_menu`, added extended-margin `B` support to `.frontend_map_select` (covering both War Room and VS map selection), and flushed queued `A` pulses on overlay/dialog → tactical map transitions to prevent accidental tap leakage onto units or tiles. *(Fine-grained Design Maps grid painting deferred until an unlocked editor save fixture is available.)*
- **Milestone 10C — Outer-Corner In-Battle HUD & Full-Width Reachability (Planned):**
  - Upgrade `renderReachabilityMargins` → `renderReachabilityFull` across `0..vw` in `src/gba/renderer.zig`.
  - Anchor the in-battle CO Funds badge and Terrain Info box to the outer wide corners in wide mode while preserving 100% bit-exact `240x160` fallback.
- **Milestone 10D — Vertical Widescreen (`vw x vh`), Pinch/Wheel Zoom & Decoupled Camera Panning (Planned):**
  - Extend `wide_framebuf` and `WideScene` vertically beyond `160px` height (`vw x vh`) to reveal additional map rows, add pinch-to-zoom / wheel zoom on the tactical map, and separate map scrolling from static UI overlays in the WebGL2 compositor (`web/gl_presenter.js`).

## Deferred / Optional (Skipped for Now)
- **Android Native Port (`aarch64-linux-android` + Pure Touch APK):** Deferred indefinitely in favor of the Phase 5 WebAssembly port for mobile browser play with touch controls; can be revisited later using `zig build -Dtarget=aarch64-linux-android` + `touch.zig`.
