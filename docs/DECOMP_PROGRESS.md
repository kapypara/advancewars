# Side-by-Side Zig Decompilation Progress

Clean native Zig source in `src/game/` runs side-by-side with the weak-linked fallback shards in `gen/`. Every lifted function overrides its corresponding `func_080XXXXX` symbol automatically across both native SDL2 (`awre`) and WebAssembly (`awre.wasm`).

## Summary
- **Baseline Tag:** `zig-recomp-v1`
- **Stage:** Stage 0 — Weak-Linkage Scaffold & Baseline Verified
- **Total ROM Functions (`gen/`):** 7,577 (`funcs_*` + `stubs_*`)
- **Lifted to Clean Zig (`src/game/`):** 0 / 7,577 (0.0%)

## Subsystem Roadmap
- [x] **Stage 0:** Weak-linkage generator (`src/recomp/translate.zig`), `src/game/` scaffold (`root.zig`, `abi.zig`, `types.zig`, `math.zig`), native + WASM + test wiring in `build.zig`, exact conformance & `FT_EXACT` baseline.
- [ ] **Stage 1:** Core utilities, math & memory helpers (`src/game/math.zig`)
- [ ] **Stage 2:** Proc scheduler & main scene loop (`src/game/proc.zig`)
- [ ] **Stage 3:** Map state, terrain & reachability (`src/game/map.zig`)
- [ ] **Stage 4:** Units, movement & properties (`src/game/unit.zig`)
- [ ] **Stage 5:** Battle engine & damage calculations (`src/game/battle.zig`)
- [ ] **Stage 6:** UI, cursor, menus, HUD & audio helpers (`src/game/ui.zig`, `src/game/sound.zig`)
- [ ] **Stage 7:** AI controller & remaining ROM subsystems (`src/game/ai.zig`)

## Verification Gate (Every Milestone)
1. `zig build test --summary all` (unit + differential equivalence tests)
2. `zig build -Doptimize=ReleaseFast && zig build wasm`
3. `bash scripts/conformance.sh` (live ARM7TDMI agreement)
4. `bash scripts/smoke.sh` (`FT_EXACT` 0-byte diff vs `scratch/ref_ft.bmp`)
5. `sha256sum game/aw.sav` unchanged
