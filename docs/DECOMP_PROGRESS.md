# Side-by-Side Zig Decompilation Progress

Clean native Zig source in `src/game/` runs side-by-side with the weak-linked fallback shards in `gen/`. Every lifted function overrides its corresponding `func_080XXXXX` symbol automatically across both native SDL2 (`awre`) and WebAssembly (`awre.wasm`).

## Summary
- **Baseline Tag:** `zig-recomp-v1`
- **Stage:** Stage 14 — UI Scene Spawners, Screen Transitions & Animator Helpers
- **Total ROM Functions (`gen/`):** 7,577 (`funcs_*` + `stubs_*`)
- **Lifted to Clean Zig (`src/game/`):** 674 / 7,577 (8.90%)

## Lifted Modules
- `src/game/bios.zig` (9): `0x080796A0` (`noop`), `0x080796BC` (`bgAffineSet`), `0x080796C0` (`cpuFastSet`), `0x080796C4` (`cpuSet`), `0x080796C8` (`div`), `0x080796CC` (`mod`), `0x080796D4` (`huffUnComp`), `0x080796D8` (`lz77UnCompVram`), `0x080796DC` (`lz77UnCompWram`)
- `src/game/math.zig` (7): `0x08010A84` (`advanceRng`), `0x0803D4F0`, `0x0806CF50`, `0x0806D23C`, `0x0806D260`, `0x0807AF30`, `0x0800FCFA`
- `src/game/dma.zig` (8): `0x0800F894`, `0x0800FD94`, `0x0800FDCC`, `0x08010AC8`, `0x08011310`, `0x08011354`, `0x080178F4`, `0x0803C32C`
- `src/game/sound.zig` (31): `0x08038028..0x080386D8`, `0x0803D700..0x0803D954`, `0x080492A0`, `0x0804E504`, `0x080779D8`, `0x080795B4..0x0807968C` (m4a driver, cues & track handlers)
- `src/game/hw.zig` (40): `0x08002E88..0x08015A54`, `0x0801B850..0x0801B8A8`/`0x0801DAB8`, `0x080422C4..0x0804890C`, `0x08069B1C`, `0x08079958`/`0x08079A00`, `0x0807AE10..0x0807B51C`
- `src/game/proc.zig` (66): `0x08010F04..0x08019608`, `0x0802ABF0` (`0x0300_0E10` proc opcodes, proc-script & `0x0300_1D50` cutscene script opcodes)
- `src/game/sprite_anim.zig` (39): `0x08011CF0..0x08015A20`, `0x0801A0EC..0x0801A1BC`, `0x08049554` (`0x0300_2320` animator pool & OAM buffers)
- `src/game/menu.zig` (41): `0x08000280..0x0800F738` (title/menu flow, mode dispatchers, sound triggers, save/campaign checks & menu proc spawners)
- `src/game/map.zig` (19): `0x080191E8..0x0803B73C` (tilemap, palette, viewport, BG staging & cursor helpers)
- `src/game/campaign.zig` (38): `0x080378C8..0x08040310` (save flag shadow copy, unlock bitsets `0x0201_F9A8`, mission records & flag queries)
- `src/game/state.zig` (73): `0x08015E10..0x0804B430` (`0x0300_4310` battle/UI substate setters & counters, `0x0201_AB34` entity flags, `0x0300_3200`/`0x0300_43C8` battle flags)
- `src/game/ui.zig` (185): `0x08018DE4..0x08019F90`, `0x0802C660..0x0807660C` (result summaries, menu grids, windows, overlay procs, fade/blend transitions)
- `src/game/co.zig` (10): `0x0801BDDC..0x0801BEE4`, `0x08038064..0x0803808C` (CO selection reset & portrait/palette/data ROM lookups)
- `src/game/unit.zig` (49): `0x08019970`, `0x0801B8D4..0x08028D24`, `0x0802A97C..0x08043810` (unit palette upload, marker/badge/overlay helpers & spawners)
- `src/game/battle.zig` (35): `0x08022220..0x0802F634` (`computeScaledDamage`, unit health checks, battle previews, VRAM icon uploads & combat overlays/markers)
- `src/game/turn.zig` (24): `0x08032200..0x080378B8` (turn transitions, day/CO phase state setters, proc slot panel lifecycle & prompt centering)

## Subsystem Roadmap
- [x] **Stage 0:** Weak-linkage generator, `src/game/` scaffold, native + WASM + test wiring, baseline verified (`bd32afd`).
- [x] **Stage 1:** BIOS SWI wrappers, RNG math & CpuSet/DMA copy helpers (`bb9ecba`, 15 functions).
- [x] **Stage 2:** m4a audio track handlers & hardware register helpers (`3ed98f7`, 35 total).
- [x] **Stage 3:** Proc opcodes, cutscene script commands & sprite/animator pool (`a0c3296`, 57 total).
- [x] **Stage 4:** Campaign unlock bitsets, script cursor opcodes & battle/UI state helpers (`2bc0d8c`, 101 total).
- [x] **Stage 5:** Map tilemap/viewport helpers, script pointer copies & battle controls (`c917ede`, 153 total).
- [x] **Stage 6:** Sound driver, campaign save shadow, UI panels, Q12 matrix math & DMA/IRQ helpers (`d98ffbb`, 223 total).
- [x] **Stage 7:** CO portrait lookups, unit/overlay helpers & structured dispatchers (`1821832`/`2f6ee53`, 266 total).
- [x] **Stage 8:** Battle damage formula, combat overlays & turn spawners (`c1dd358`, 316 total).
- [x] **Stage 9:** Turn transitions, overlay proc lifecycles & combat marker helpers (`fd1418f`, 374 total).
- [x] **Stage 10:** Menus, early-ROM IRQ/DMA control & animator bindings (`a55714c`, 434 total).
- [x] **Stage 11:** Proc/cutscene script opcodes, OAM buffers & campaign unlocks (`e429a58`, 494 total).
- [x] **Stage 12:** Map/BG transfers, CO portraits, sound cues & cutscene flows (`554 total`).
- [x] **Stage 13:** UI windows, sound helpers & save flags (`0x0803C3..0x08042C`, `614 total`).
- [x] **Stage 14:** UI scene spawners, blend transitions & animator helpers (`0x080438..0x0804F8`, `674 total`).
- [ ] **Stage 15:** Remaining `<=2 cases, <=1 call` ROM helpers (`0x0804F8..0x0807C0`), then 2-3 call subsystems.

## Verification Gate (Every Milestone)
1. `zig build test --summary all`
2. `zig build -Doptimize=ReleaseFast && zig build wasm`
3. `bash scripts/conformance.sh` (`GBA_VALIDATE=3` live ARM7TDMI agreement)
4. `bash scripts/smoke.sh` (`FT_EXACT` 0-byte diff vs `scratch/ref_ft.bmp`)
5. `sha256sum game/aw.sav` unchanged
