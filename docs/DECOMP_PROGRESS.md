# Side-by-Side Zig Decompilation Progress

Clean native Zig source in `src/game/` runs side-by-side with the weak-linked fallback shards in `gen/`. Every lifted function overrides its corresponding `func_080XXXXX` symbol automatically across both native SDL2 (`awre`) and WebAssembly (`awre.wasm`).

## Summary
- **Baseline Tag:** `zig-recomp-v1`
- **Stage:** Stage 4 — Campaign Unlock Bitsets, Cursor/Script Opcodes & State Helpers
- **Total ROM Functions (`gen/`):** 7,577 (`funcs_*` + `stubs_*`)
- **Lifted to Clean Zig (`src/game/`):** 101 / 7,577 (1.33%)

## Lifted Modules
- `src/game/bios.zig` (9): `0x080796A0` (`noop`), `0x080796BC` (`bgAffineSet`), `0x080796C0` (`cpuFastSet`), `0x080796C4` (`cpuSet`), `0x080796C8` (`div`), `0x080796CC` (`mod`), `0x080796D4` (`huffUnComp`), `0x080796D8` (`lz77UnCompVram`), `0x080796DC` (`lz77UnCompWram`)
- `src/game/math.zig` (3): `0x08010A84` (`advanceRng`), `0x0807AF30` (`cosDeg`), `0x0800FCFA` (`readSignedGlobal16`)
- `src/game/dma.zig` (3): `0x0800FD94` (`cpuCopy16`), `0x0800FDCC` (`cpuFastCopy32`), `0x08010AC8` (`setFlagBit10`)
- `src/game/sound.zig` (10): `0x08079610..0x0807968C` (8 `MusicPlayerTrack` bytecode handlers), `0x0803D79C` (`m4aSoundVSync`), `0x0803D7AC` (`m4aSoundMain`)
- `src/game/hw.zig` (10): `0x0800F094`, `0x0800F170`, `0x0800F578`, `0x08010444`, `0x080104B0`, `0x080134E0`, `0x080134EC`, `0x08015A08`, `0x08015A38`, `0x08015A54`
- `src/game/proc.zig` (18): `0x08013D14`, `0x08013D3C`, `0x08013DA0`, `0x08013DF0`, `0x08013DF4`, `0x08014078` (`0x0300_0E10` proc opcodes), `0x08017104..0x08018240` (`0x0300_1D50` script pool write/cursor opcodes, lock/sync helpers)
- `src/game/sprite_anim.zig` (15): `0x08013598..0x080138CC`, `0x0801A0EC..0x0801A1BC` (`0x0300_2320` animator setters/getters), `0x08014CE8` (`0x0201_1D24` OAM queue entry)
- `src/game/campaign.zig` (6): `0x0803EEBC`, `0x0803EF1C`, `0x0803EF48`, `0x0803F014`, `0x0803F064` (`0x0201_F9A8` unlock bitsets), `0x0803F148` (`0x0201_F9F0` mission record field getter)
- `src/game/state.zig` (27): `0x08018AAC..0x0803FD78` (`0x0300_4310` battle/UI substate setters & counters, `0x0201_AB34` entity flags, `0x0300_3200`/`0x0300_43C8` battle flags)

## Subsystem Roadmap
- [x] **Stage 0:** Weak-linkage generator, `src/game/` scaffold, native + WASM + test wiring, baseline verified (`bd32afd`).
- [x] **Stage 1:** BIOS SWI wrappers, RNG math & CpuSet/DMA copy helpers (`bb9ecba`, 15 functions).
- [x] **Stage 2:** m4a audio track handlers & hardware register helpers (`3ed98f7`, 35 total).
- [x] **Stage 3:** Proc opcodes, cutscene script commands & sprite/animator pool (`a0c3296`, 57 total).
- [x] **Stage 4:** Campaign unlock bitsets, script cursor opcodes & battle/UI state helpers (101 total).
- [ ] **Stage 5:** Map state, terrain & reachability (`map.zig`)
- [ ] **Stage 6:** Units, movement & properties (`unit.zig`)
- [ ] **Stage 7:** Battle engine & damage calculations (`battle.zig`)
- [ ] **Stage 8:** UI, cursor, menus & HUD (`ui.zig`)
- [ ] **Stage 9:** AI controller & remaining ROM subsystems (`ai.zig`)

## Verification Gate (Every Milestone)
1. `zig build test --summary all`
2. `zig build -Doptimize=ReleaseFast && zig build wasm`
3. `bash scripts/conformance.sh` (`GBA_VALIDATE=3` live ARM7TDMI agreement)
4. `bash scripts/smoke.sh` (`FT_EXACT` 0-byte diff vs `scratch/ref_ft.bmp`)
5. `sha256sum game/aw.sav` unchanged
