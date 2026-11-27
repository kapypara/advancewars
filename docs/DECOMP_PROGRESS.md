# Side-by-Side Zig Decompilation Progress

Clean native Zig source in `src/game/` runs side-by-side with the weak-linked fallback shards in `gen/`. Every lifted function overrides its corresponding `func_080XXXXX` symbol automatically across both native SDL2 (`awre`) and WebAssembly (`awre.wasm`).

## Summary
- **Baseline Tag:** `zig-recomp-v1`
- **Stage:** Stage 22 — Tier 2 Menus, Windows, Tactical Map & Battle Screens (`<=120L`)
- **Total ROM Functions (`gen/`):** 7,577 (`funcs_*` + `stubs_*`)
- **Lifted to Clean Zig (`src/game/`):** 1,154 / 7,577 (15.23%)

## Lifted Modules
- `src/game/bios.zig` (11): `0x080796A0` (`noop`), `0x080796BC` (`bgAffineSet`), `0x080796C0` (`cpuFastSet`), `0x080796C4` (`cpuSet`), `0x080796C8` (`div`), `0x080796CC` (`mod`), `0x080796D4` (`huffUnComp`), `0x080796D8` (`lz77UnCompVram`), `0x080796DC` (`lz77UnCompWram`), `0x080796E8` (`rlUnCompVram`), `0x080796EC` (`rlUnCompWram`)
- `src/game/math.zig` (8): `0x08003918`, `0x08010A84` (`advanceRng`), `0x0803D4F0`, `0x0806CF50`, `0x0806D23C`, `0x0806D260`, `0x0807AF30`, `0x0800FCFA`
- `src/game/dma.zig` (11): `0x0800F894`, `0x0800FD94`, `0x0800FDCC`, `0x08010AC8`, `0x08011310..0x08011398`, `0x080178F4`, `0x0803C32C`
- `src/game/sound.zig` (48): `0x08038028..0x080386D8`, `0x0803D700..0x0803DAE0`, `0x080492A0..0x080521A4`, `0x080779D8..0x0807968C` (m4a driver, cues & track handlers)
- `src/game/hw.zig` (76): `0x08002E88..0x0801785C`, `0x0801B850..0x0801B8A8`/`0x0801DAB8`, `0x080422C4..0x08075B14`, `0x08079958`/`0x08079A00`, `0x0807ACE8..0x0807CE10`
- `src/game/proc.zig` (77): `0x08010F04..0x08019608`, `0x0802ABF0` (`0x0300_0E10` proc opcodes, proc-script & `0x0300_1D50` cutscene script opcodes)
- `src/game/sprite_anim.zig` (68): `0x08011CF0..0x08015A20`, `0x0801A0EC..0x0801A1BC`, `0x08049554` (`0x0300_2320` animator pool & OAM buffers)
- `src/game/menu.zig` (76): `0x08000280..0x0800F738` (title/menu flow, mode dispatchers, sound triggers, save/campaign checks & menu proc spawners)
- `src/game/map.zig` (38): `0x08018E4C..0x0803B73C` (tilemap, palette, viewport, BG staging & cursor helpers)
- `src/game/campaign.zig` (60): `0x080378C8..0x08040310` (campaign/War Room flows, save flag shadow copy, unlock bitsets `0x0201_F9A8`, mission records & flag queries)
- `src/game/state.zig` (105): `0x08015E10..0x0804F924` (`0x0300_4310` battle/UI substate setters & counters, `0x0201_AB34` entity flags, `0x0300_3200`/`0x0300_43C8` battle flags)
- `src/game/ui.zig` (358): `0x0801862C..0x0802C8D8`, `0x080416B8..0x08077580` (War Room, dialogue/cursor panels, BG priority layers, result summaries, overlay procs, transitions)
- `src/game/co.zig` (25): `0x0801B8BC..0x0801CA18`, `0x08038064..0x0803808C`, `0x0806C9A0..0x0806CE84` (CO selection reset, panel triggers & portrait/palette/data ROM lookups)
- `src/game/unit.zig` (62): `0x08017B20`, `0x08019970..0x08043810` (unit palette upload, action flags, camera focus, marker/badge/overlay helpers & spawners)
- `src/game/battle.zig` (81): `0x08022220..0x08030DC8`, `0x08066AC8..0x0806B118` (`computeScaledDamage`, battle previews/icons, action dispatchers & combat overlays)
- `src/game/turn.zig` (50): `0x08031EB4..0x080378B8` (turn transitions, day/CO phase state setters, proc slot panel lifecycle & prompt centering)

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
- [x] **Stage 15:** VRAM/OAM uploads, battle overlays & UI menu controllers (`0x0804F8..0x0806D8`, `734 total`).
- [x] **Stage 16:** Late-ROM audio, BIOS, Flash & UI overlay helpers (`0x08042D..0x0807CE`, `794 total`).
- [x] **Stage 17:** Early-ROM menu flows, window layers & cutscene opcodes (`0x08002C..0x08017A`, `854 total`).
- [x] **Stage 18:** Tactical map, CO portrait & battle action dispatchers (`0x08017B..0x0802E2`, `914 total`).
- [x] **Stage 19:** Battle previews, turn transitions & mid-ROM submenus (`0x0802E7..0x0803AB`, `974 total`).
- [x] **Stage 20:** Campaign select, War Room & summary overlays (`0x0803B3..0x0804DA`, `1,034 total`).
- [x] **Stage 21:** Late-ROM dialogues, CO portraits, battle panels & IRQ waits (`0x0804DB..0x0807AE`, `1,094 total`).
- [x] **Stage 22:** Tier 2 early/mid menus, map layers, OAM windows & battle panels (`0x08002A..0x080322`, `1,154 total`).
- [ ] **Stage 23:** Remaining Tier 2 functions (`0x080323..0x0807CE`, `<=120L, <=6 calls, <=8 cases`).

## Verification Gate (Every Milestone)
1. `zig build test --summary all`
2. `zig build -Doptimize=ReleaseFast && zig build wasm`
3. `bash scripts/conformance.sh` (`GBA_VALIDATE=3` live ARM7TDMI agreement)
4. `bash scripts/smoke.sh` (`FT_EXACT` 0-byte diff vs `scratch/ref_ft.bmp`)
5. `sha256sum game/aw.sav` unchanged
