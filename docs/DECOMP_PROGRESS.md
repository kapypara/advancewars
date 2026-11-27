# Side-by-Side Zig Decompilation Progress

Clean native Zig source in `src/game/` runs side-by-side with the weak-linked fallback shards in `gen/`. Every lifted function overrides its corresponding `func_080XXXXX` symbol automatically across both native SDL2 (`awre`) and WebAssembly (`awre.wasm`).

## Summary
- **Baseline Tag:** `zig-recomp-v1`
- **Stage:** Stage 5 — Map Tilemap/Viewport, Script Pointer Copies & Battle Control
- **Total ROM Functions (`gen/`):** 7,577 (`funcs_*` + `stubs_*`)
- **Lifted to Clean Zig (`src/game/`):** 153 / 7,577 (2.02%)

## Lifted Modules
- `src/game/bios.zig` (9): `0x080796A0` (`noop`), `0x080796BC` (`bgAffineSet`), `0x080796C0` (`cpuFastSet`), `0x080796C4` (`cpuSet`), `0x080796C8` (`div`), `0x080796CC` (`mod`), `0x080796D4` (`huffUnComp`), `0x080796D8` (`lz77UnCompVram`), `0x080796DC` (`lz77UnCompWram`)
- `src/game/math.zig` (3): `0x08010A84` (`advanceRng`), `0x0807AF30` (`cosDeg`), `0x0800FCFA` (`readSignedGlobal16`)
- `src/game/dma.zig` (3): `0x0800FD94` (`cpuCopy16`), `0x0800FDCC` (`cpuFastCopy32`), `0x08010AC8` (`setFlagBit10`)
- `src/game/sound.zig` (10): `0x08079610..0x0807968C` (8 `MusicPlayerTrack` bytecode handlers), `0x0803D79C` (`m4aSoundVSync`), `0x0803D7AC` (`m4aSoundMain`)
- `src/game/hw.zig` (15): `0x08002E88`, `0x080045A8`, `0x08004F34`, `0x080076FC`, `0x0800F094`, `0x0800F170`, `0x0800F578`, `0x08010444`, `0x080104B0`, `0x08012BAC`, `0x080134E0`, `0x080134EC`, `0x08015A08`, `0x08015A38`, `0x08015A54`
- `src/game/proc.zig` (25): `0x08013D14`, `0x08013D3C`, `0x08013DA0`, `0x08013DF0`, `0x08013DF4`, `0x08014078`, `0x0802ABF0` (`0x0300_0E10` proc opcodes), `0x08016F18..0x08018240` (`0x0300_1D50` script pool write/pointer/cursor opcodes)
- `src/game/sprite_anim.zig` (17): `0x08011CF0`, `0x08013598..0x080138CC`, `0x0801A0EC..0x0801A1BC` (`0x0300_2320` animator setters/getters), `0x08014B54`, `0x08014CE8` (`0x0201_1924` / `0x0201_1D24` OAM tables)
- `src/game/map.zig` (6): `0x0801FD98` (`clearMapCell2x2Tiles`), `0x0802055C` (`setCursorPixels`), `0x08020568` (`syncCursorPixelsFromTile`), `0x08033108`, `0x08033E28` (`initMapDisplayControl`), `0x0803B73C` (`applyViewportScroll`)
- `src/game/campaign.zig` (6): `0x0803EEBC`, `0x0803EF1C`, `0x0803EF48`, `0x0803F014`, `0x0803F064` (`0x0201_F9A8` unlock bitsets), `0x0803F148` (`0x0201_F9F0` mission record field getter)
- `src/game/state.zig` (59): `0x08018AAC..0x0803FD78` (`0x0300_4310` battle/UI substate setters & counters, `0x0201_AB34` entity flags, `0x0300_3200`/`0x0300_43C8` battle flags)

## Subsystem Roadmap
- [x] **Stage 0:** Weak-linkage generator, `src/game/` scaffold, native + WASM + test wiring, baseline verified (`bd32afd`).
- [x] **Stage 1:** BIOS SWI wrappers, RNG math & CpuSet/DMA copy helpers (`bb9ecba`, 15 functions).
- [x] **Stage 2:** m4a audio track handlers & hardware register helpers (`3ed98f7`, 35 total).
- [x] **Stage 3:** Proc opcodes, cutscene script commands & sprite/animator pool (`a0c3296`, 57 total).
- [x] **Stage 4:** Campaign unlock bitsets, script cursor opcodes & battle/UI state helpers (`2bc0d8c`, 101 total).
- [x] **Stage 5:** Map tilemap/viewport helpers, script pointer copies & battle controls (153 total).
- [ ] **Stage 6:** Sound engine, math & late-ROM utility helpers (`sound.zig`, `math.zig`, `ui.zig`)
- [ ] **Stage 7:** Units, movement & reachability (`unit.zig`)
- [ ] **Stage 8:** Battle engine & damage calculations (`battle.zig`)
- [ ] **Stage 9:** AI controller & full ROM replacement (`ai.zig`)

## Verification Gate (Every Milestone)
1. `zig build test --summary all`
2. `zig build -Doptimize=ReleaseFast && zig build wasm`
3. `bash scripts/conformance.sh` (`GBA_VALIDATE=3` live ARM7TDMI agreement)
4. `bash scripts/smoke.sh` (`FT_EXACT` 0-byte diff vs `scratch/ref_ft.bmp`)
5. `sha256sum game/aw.sav` unchanged
