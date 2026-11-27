# Side-by-Side Zig Decompilation Progress

Clean native Zig source in `src/game/` runs side-by-side with the weak-linked fallback shards in `gen/`. Every lifted function overrides its corresponding `func_080XXXXX` symbol automatically across both native SDL2 (`awre`) and WebAssembly (`awre.wasm`).

## Summary
- **Baseline Tag:** `zig-recomp-v1`
- **Stage:** Stage 6 — Sound Engine, Campaign Save, UI Panels, Q12 Math & DMA/IRQ
- **Total ROM Functions (`gen/`):** 7,577 (`funcs_*` + `stubs_*`)
- **Lifted to Clean Zig (`src/game/`):** 223 / 7,577 (2.94%)

## Lifted Modules
- `src/game/bios.zig` (9): `0x080796A0` (`noop`), `0x080796BC` (`bgAffineSet`), `0x080796C0` (`cpuFastSet`), `0x080796C4` (`cpuSet`), `0x080796C8` (`div`), `0x080796CC` (`mod`), `0x080796D4` (`huffUnComp`), `0x080796D8` (`lz77UnCompVram`), `0x080796DC` (`lz77UnCompWram`)
- `src/game/math.zig` (6): `0x08010A84` (`advanceRng`), `0x0806CF50` (`mulMat3x3Vec3Q12`), `0x0806D23C` (`dotVec3Q12`), `0x0806D260` (`crossVec3Q12`), `0x0807AF30` (`cosDeg`), `0x0800FCFA` (`readSignedGlobal16`)
- `src/game/dma.zig` (3): `0x0800FD94` (`cpuCopy16`), `0x0800FDCC` (`cpuFastCopy32`), `0x08010AC8` (`setFlagBit10`)
- `src/game/sound.zig` (16): `0x0803D710..0x0803D954` (m4a driver/status helpers), `0x080779D8` (`zero64Bytes`), `0x080795B4`, `0x08079610..0x0807968C` (`MusicPlayerTrack` bytecode handlers)
- `src/game/hw.zig` (23): `0x08002E88..0x08015A54`, `0x08069B1C` (SIO reset), `0x08079958`/`0x08079A00` (timer IRQ arm/disarm), `0x0807AE10`, `0x0807AE50` (IRQ table), `0x0807B2DC` (`dma3Copy`), `0x0807B310` (`dmaSet`), `0x0807B51C`
- `src/game/proc.zig` (25): `0x08013D14`, `0x08013D3C`, `0x08013DA0`, `0x08013DF0`, `0x08013DF4`, `0x08014078`, `0x0802ABF0` (`0x0300_0E10` proc opcodes), `0x08016F18..0x08018240` (`0x0300_1D50` script pool write/pointer/cursor opcodes)
- `src/game/sprite_anim.zig` (17): `0x08011CF0`, `0x08013598..0x080138CC`, `0x0801A0EC..0x0801A1BC` (`0x0300_2320` animator setters/getters), `0x08014B54`, `0x08014CE8` (`0x0201_1924` / `0x0201_1D24` OAM tables)
- `src/game/map.zig` (6): `0x0801FD98` (`clearMapCell2x2Tiles`), `0x0802055C` (`setCursorPixels`), `0x08020568` (`syncCursorPixelsFromTile`), `0x08033108`, `0x08033E28` (`initMapDisplayControl`), `0x0803B73C` (`applyViewportScroll`)
- `src/game/campaign.zig` (13): `0x0803E37C`/`0x0803E39C` (save flag shadow copy), `0x0803E538..0x08040310`, `0x0803EEBC..0x0803F148` (`0x0201_F9A8` unlock bitsets, `0x0201_F9F0` mission records)
- `src/game/state.zig` (59): `0x08018AAC..0x0803FD78` (`0x0300_4310` battle/UI substate setters & counters, `0x0201_AB34` entity flags, `0x0300_3200`/`0x0300_43C8` battle flags)
- `src/game/ui.zig` (46): `0x0803D038..0x0807660C` (result summaries, menu grids, BG screen entry encoders, fade/blend transitions, UI manager counters)

## Subsystem Roadmap
- [x] **Stage 0:** Weak-linkage generator, `src/game/` scaffold, native + WASM + test wiring, baseline verified (`bd32afd`).
- [x] **Stage 1:** BIOS SWI wrappers, RNG math & CpuSet/DMA copy helpers (`bb9ecba`, 15 functions).
- [x] **Stage 2:** m4a audio track handlers & hardware register helpers (`3ed98f7`, 35 total).
- [x] **Stage 3:** Proc opcodes, cutscene script commands & sprite/animator pool (`a0c3296`, 57 total).
- [x] **Stage 4:** Campaign unlock bitsets, script cursor opcodes & battle/UI state helpers (`2bc0d8c`, 101 total).
- [x] **Stage 5:** Map tilemap/viewport helpers, script pointer copies & battle controls (`c917ede`, 153 total).
- [x] **Stage 6:** Sound driver, campaign save shadow, UI panels, Q12 matrix math & DMA/IRQ helpers (223 total).
- [ ] **Stage 7:** Units, movement & reachability (`unit.zig`)
- [ ] **Stage 8:** Battle engine & damage calculations (`battle.zig`)
- [ ] **Stage 9:** AI controller & full ROM replacement (`ai.zig`)

## Verification Gate (Every Milestone)
1. `zig build test --summary all`
2. `zig build -Doptimize=ReleaseFast && zig build wasm`
3. `bash scripts/conformance.sh` (`GBA_VALIDATE=3` live ARM7TDMI agreement)
4. `bash scripts/smoke.sh` (`FT_EXACT` 0-byte diff vs `scratch/ref_ft.bmp`)
5. `sha256sum game/aw.sav` unchanged
