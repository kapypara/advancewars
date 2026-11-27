# Side-by-Side Zig Decompilation Progress

Clean native Zig source in `src/game/` runs side-by-side with the weak-linked fallback shards in `gen/`. Every lifted function overrides its corresponding `func_080XXXXX` symbol automatically across both native SDL2 (`awre`) and WebAssembly (`awre.wasm`).

## Summary
- **Baseline Tag:** `zig-recomp-v1`
- **Stage:** Stage 1 — BIOS SWI, Math/RNG & DMA Copy Helpers
- **Total ROM Functions (`gen/`):** 7,577 (`funcs_*` + `stubs_*`)
- **Lifted to Clean Zig (`src/game/`):** 15 / 7,577 (0.2%)

## Lifted Modules
- `src/game/bios.zig` (9): `0x080796A0` (`noop`), `0x080796BC` (`bgAffineSet`), `0x080796C0` (`cpuFastSet`), `0x080796C4` (`cpuSet`), `0x080796C8` (`div`), `0x080796CC` (`mod`), `0x080796D4` (`huffUnComp`), `0x080796D8` (`lz77UnCompVram`), `0x080796DC` (`lz77UnCompWram`)
- `src/game/math.zig` (3): `0x08010A84` (`advanceRng`), `0x0807AF30` (`cosDeg`), `0x0800FCFA` (`readSignedGlobal16`)
- `src/game/dma.zig` (3): `0x0800FD94` (`cpuCopy16`), `0x0800FDCC` (`cpuFastCopy32`), `0x08010AC8` (`setFlagBit10`)

## Subsystem Roadmap
- [x] **Stage 0:** Weak-linkage generator (`src/recomp/translate.zig`), `src/game/` scaffold (`root.zig`, `abi.zig`, `types.zig`, `math.zig`), native + WASM + test wiring in `build.zig`, exact conformance & `FT_EXACT` baseline.
- [x] **Stage 1:** BIOS SWI wrappers, RNG math & CpuSet/DMA copy helpers (`bios.zig`, `math.zig`, `dma.zig`) — 15 functions lifted & verified.
- [ ] **Stage 2:** m4a audio track handlers & hardware register helpers (`sound.zig`, `hw.zig`)
- [ ] **Stage 3:** Proc scheduler & main scene loop (`proc.zig`)
- [ ] **Stage 4:** Map state, terrain & reachability (`map.zig`)
- [ ] **Stage 5:** Units, movement & properties (`unit.zig`)
- [ ] **Stage 6:** Battle engine & damage calculations (`battle.zig`)
- [ ] **Stage 7:** UI, cursor, menus & HUD (`ui.zig`)
- [ ] **Stage 8:** AI controller & remaining ROM subsystems (`ai.zig`)

## Verification Gate (Every Milestone)
1. `zig build test --summary all` (unit + differential equivalence tests)
2. `zig build -Doptimize=ReleaseFast && zig build wasm`
3. `bash scripts/conformance.sh` (live ARM7TDMI agreement)
4. `bash scripts/smoke.sh` (`FT_EXACT` 0-byte diff vs `scratch/ref_ft.bmp`)
5. `sha256sum game/aw.sav` unchanged
