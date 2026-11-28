# Side-by-Side Zig Decompilation Progress

Clean native Zig source in `src/game/` runs side-by-side with the weak-linked fallback shards in `gen/`. Every lifted function overrides its corresponding `func_080XXXXX` symbol automatically across both native SDL2 (`awre`) and WebAssembly (`awre.wasm`).

## Summary
- **Baseline Tag:** `zig-recomp-v1`
- **Stage:** Stage 74 — Hi-ROM Deduplicated Component Wave 3 (`96.56%`)
- **Total ROM Functions (`gen/`):** 7,577 (`funcs_*` + `stubs_*`)
- **Lifted to Clean Zig (`src/game/`):** 7,316 / 7,577 (96.56%)

## Lifted Modules
- `src/game/bios.zig` (11): `0x080796A0` (`noop`), `0x080796BC` (`bgAffineSet`), `0x080796C0` (`cpuFastSet`), `0x080796C4` (`cpuSet`), `0x080796C8` (`div`), `0x080796CC` (`mod`), `0x080796D4` (`huffUnComp`), `0x080796D8` (`lz77UnCompVram`), `0x080796DC` (`lz77UnCompWram`), `0x080796E8` (`rlUnCompVram`), `0x080796EC` (`rlUnCompWram`)
- `src/game/math.zig` (19): `0x08003918`, `0x08010A84` (`advanceRng`), `0x0803D4F0`, `0x0806D160..0x0806D260`, `0x080775A4` (`umull` hi), `0x0807AF30`, `0x0800FCFA`, `0x0807BBF8..0x0807CE28` (softfp add/sub/mul/fixsfsi)
- `src/game/dma.zig` (11): `0x0800F894`, `0x0800FD94`, `0x0800FDCC`, `0x08010AC8`, `0x08011310..0x08011398`, `0x080178F4`, `0x0803C32C`
- `src/game/sound.zig` (51): `0x08038028..0x080386D8`, `0x0803D700..0x0803DAE0`, `0x080492A0..0x08052200`, `0x080779D8..0x0807968C` (m4a driver, cues & track handlers)
- `src/game/hw.zig` (85): `0x08002E88..0x0801785C`, `0x0801B850..0x0801B8A8`/`0x0801DAB8`, `0x080422C4..0x08075B14`, `0x08079958..0x0807A3BC` (incl. Flash erase/verify & display masks), `0x0807ACE8..0x0807CE10`
- `src/game/proc.zig` (78): `0x08010F04..0x08019608`, `0x0802ABF0` (`0x0300_0E10` proc opcodes, proc-script & `0x0300_1D50` cutscene script opcodes)
- `src/game/sprite_anim.zig` (68): `0x08011CF0..0x08015A20`, `0x0801A0EC..0x0801A1BC`, `0x08049554` (`0x0300_2320` animator pool & OAM buffers)
- `src/game/menu.zig` (93): `0x08000280..0x0800F738`, `0x0806EC18..0x08076AA4` (title/menu flow, mode dispatchers, subscreen/ending initializers & menu proc spawners)
- `src/game/map.zig` (47): `0x08018E4C..0x0803C91C` (tilemap, faction palettes, viewport, BG staging & cursor helpers)
- `src/game/campaign.zig` (85): `0x080378C8..0x08040310` (campaign/War Room flows, save flag shadow copy, unlock bitsets `0x0201_F9A8`, mission records & flag queries)
- `src/game/state.zig` (106): `0x08015E10..0x0804F924` (`0x0300_4310` battle/UI substate setters & counters, `0x0201_AB34` entity flags, `0x0300_3200`/`0x0300_43C8` battle flags)
- `src/game/ui.zig` (446): `0x0801862C..0x0802C8D8`, `0x08040218..0x08077580`, `0x083BE6B4..0x083CC848` (War Room, dialogue/cursor panels, BG priority layers, result summaries, overlay procs, transitions & tail thunks)
- `src/game/co.zig` (26): `0x0801B8BC..0x0801CA18`, `0x08038064..0x0803BC48`, `0x0806C9A0..0x0806CE84` (CO selection reset, panel triggers & portrait/palette/data ROM lookups)
- `src/game/unit.zig` (76): `0x08017B20`, `0x08019970..0x0805E930` (unit palette upload, card tiles, action flags, camera focus, marker/badge/overlay helpers & spawners)
- `src/game/battle.zig` (131): `0x08022220..0x08030DC8`, `0x08052410..0x0806C90C` (`computeScaledDamage`, battle previews/icons, action dispatchers & combat overlays)
- `src/game/turn.zig` (61): `0x0802FCBC..0x080378B8` (turn transitions, day/CO phase state setters, proc slot panel lifecycle & prompt centering)
- `src/game/overlay.zig` (180): `0x083BD7BC..0x083D91E8` (secondary ROM segment thunks, BIOS/SWI leaves, RNG, DMA/LZ wrappers, slot record accessors & multi-step sub-handlers)
- `src/game/overlay_ext.zig` (120): `0x083BD31C..0x083D8A38` (bitset writers, `0x60`/`0x18`-stride slot dispatchers, tilemap clearers, softfp arithmetic & palette/DMA helpers)
- `src/game/overlay_mid.zig` (110): `0x080D51E2..0x083D7838` (remaining `0x083B..0x083D` overlay init/slot/cursor/softfp routines & all `0x0808..0x083A` straight-line functions)
- `src/game/tail_low.zig` (66): `0x0800020C..0x0807C49E` (low-ROM indirect branch trampolines, BIOS soft-reset/math, main loop `08059DD4`, mode jump table `0800020C`, script step `080642C8`)
- `src/game/tail_hi.zig` (160): `0x08086D48..0x083F86F6` (hi-ROM/overlay indirect trampolines, tail dispatchers & small code/data fragments)
- `src/game/tail_hi_2.zig` (99): `0x08088140..0x083D9338` (hi-ROM tail-call wave 3: fragment dispatchers, LDM/STM & SWI stubs)
- `src/game/tail_hi_3.zig` (96): `0x08083180..0x083EB53C` (final hi-ROM tail-call wave 4: overlay/init `0x083D2288` & hi-ROM code/data fragments; 3 giant linear data blobs deferred)
- `src/game/clusters_low.zig` (81): `0x080000C0..0x08078970` (self-contained low-ROM shared-body `enter_*` clusters, reset/palette-fade/sound/unit/map helpers)
- `src/game/clusters_low_2.zig` (33): `0x0800F164..0x0807B488` (remaining 3 closed low-ROM shared-body `enter_*` clusters: math/div/trig, VRAM/OAM clear, menu/overlay helpers)
- `src/game/low_peel_1.zig` (185): `0x080001FC..0x08036DB4` (low-ROM block-peeled wave 1: first 185 functions `<= 30` reachable lines)
- `src/game/low_peel_2.zig` (186): `0x08036DD8..0x0807C49C` (low-ROM block-peeled wave 2: remaining 186 functions `<= 30` reachable lines)
- `src/game/low_peel_3.zig` (190): `0x08000302..0x080242B8` (low-ROM block-peeled wave 3: first 190 functions `31..60` reachable lines)
- `src/game/low_peel_4.zig` (185): `0x080242DC..0x080438B0` (low-ROM block-peeled wave 4: next 185 functions `31..60` reachable lines)
- `src/game/low_peel_5.zig` (186): `0x080438E4..0x0807CEF8` (low-ROM block-peeled wave 5: remaining 186 functions `31..60` reachable lines)
- `src/game/low_peel_6.zig` (208): `0x0800028C..0x0801FCF6` (low-ROM block-peeled wave 6: first 208 functions `61..120` reachable lines)
- `src/game/low_peel_7.zig` (209): `0x0801FCF8..0x08035DD0` (low-ROM block-peeled wave 7: next 209 functions `61..120` reachable lines)
- `src/game/low_peel_8.zig` (209): `0x08035E74..0x0805F0E4` (low-ROM block-peeled wave 8: next 209 functions `61..120` reachable lines)
- `src/game/low_peel_9.zig` (209): `0x0805F150..0x0807CF10` (low-ROM block-peeled wave 9: remaining 209 functions `61..120` reachable lines)
- `src/game/low_peel_10.zig` (168): `0x0800070C..0x0802162C` (low-ROM block-peeled wave 10: first 168 functions `121..250` reachable lines)
- `src/game/low_peel_11.zig` (168): `0x0802164A..0x0803F9F2` (low-ROM block-peeled wave 11: next 168 functions `121..250` reachable lines)
- `src/game/low_peel_12.zig` (168): `0x0803F9F6..0x08063A1C` (low-ROM block-peeled wave 12: next 168 functions `121..250` reachable lines)
- `src/game/low_peel_13.zig` (168): `0x08063ADC..0x0807FFFC` (low-ROM block-peeled wave 13: remaining 168 functions `121..250` reachable lines)
- `src/game/low_peel_14.zig` (87): `0x08000340..0x08026178` (low-ROM block-peeled wave 14: first 87 functions `251..500` reachable lines)
- `src/game/low_peel_15.zig` (87): `0x0802649C..0x0804B554` (low-ROM block-peeled wave 15: next 87 functions `251..500` reachable lines)
- `src/game/low_peel_16.zig` (87): `0x0804B77C..0x0806138C` (low-ROM block-peeled wave 16: next 87 functions `251..500` reachable lines)
- `src/game/low_peel_17.zig` (87): `0x080614A8..0x0807FF00` (low-ROM block-peeled wave 17: remaining 87 functions `251..500` reachable lines)
- `src/game/low_peel_18.zig` (45): `0x0803FE00..0x0807BC60` (low-ROM block-peeled wave 18: 45 functions `> 500` reachable lines)
- `src/game/low_peel_19.zig` (46): `0x080004BC..0x0807FDFE` (low-ROM block-peeled wave 19: remaining 46 functions `> 500` reachable lines — 100% low-ROM complete)
- `src/game/clusters_hi.zig` (109): `0x0808F5F2..0x083D8BCC` (46 closed hi-ROM shared-body `enter_*` clusters; 3 large ASCII/data clusters `COMP[28..30]` / 6 funcs deferred alongside 3 non-`enter` data blobs)
- `src/game/hi_peel_1.zig` (270): `0x08080908..0x083E9F6C` (hi-ROM block-peeled wave 1: all 270 hi-ROM functions `<= 30` reachable lines)
- `src/game/hi_peel_2.zig` (192): `0x08080906..0x08316EA6` (hi-ROM block-peeled wave 2: first 192 functions `31..60` reachable lines)
- `src/game/hi_peel_3.zig` (193): `0x08316EEA..0x083E90AC` (hi-ROM block-peeled wave 3: remaining 193 functions `31..60` reachable lines)
- `src/game/hi_peel_4.zig` (176): `0x080837AC..0x0820A66C` (hi-ROM block-peeled wave 4: first 176 functions `61..120` reachable lines)
- `src/game/hi_peel_5.zig` (176): `0x0820AF2C..0x083C4A3C` (hi-ROM block-peeled wave 5: next 176 functions `61..120` reachable lines)
- `src/game/hi_peel_6.zig` (176): `0x083C4B3C..0x083EC25C` (hi-ROM block-peeled wave 6: remaining 176 functions `61..120` reachable lines)
- `src/game/hi_peel_7.zig` (136): `0x08080008..0x081C4780` (hi-ROM block-peeled wave 7: first 136 functions `121..250` reachable lines)
- `src/game/hi_peel_8.zig` (136): `0x081C4886..0x083C3238` (hi-ROM block-peeled wave 8: next 136 functions `121..250` reachable lines)
- `src/game/hi_peel_9.zig` (137): `0x083C3334..0x083F75E4` (hi-ROM block-peeled wave 9: remaining 137 functions `121..250` reachable lines)
- `src/game/hi_peel_10.zig` (112): `0x080A0E08..0x081D4E8A` (hi-ROM block-peeled wave 10: first 112 functions `251..500` reachable lines)
- `src/game/hi_peel_11.zig` (112): `0x081D6182..0x083F7B8C` (hi-ROM block-peeled wave 11: remaining 112 functions `251..500` reachable lines)
- `src/game/hi_cluster_1.zig` (55): `0x080802A6..0x080B5D58` (hi-ROM deduplicated component wave 1: 7 components / 55 functions `> 500` reachable lines)
- `src/game/hi_cluster_2.zig` (48): `0x080D2460..0x08113510` (hi-ROM deduplicated component wave 2: 16 components / 48 functions `> 500` reachable lines)
- `src/game/hi_cluster_3.zig` (71): `0x08123242..0x081AD24E` (hi-ROM deduplicated component wave 3: 14 components / 71 functions `> 500` reachable lines)

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
- [x] **Stage 22:** Tier 2 early/mid menus, map layers, OAM windows & battle panels (`0x08002A..0x080322`, `fa248e0`, `1,154 total`).
- [x] **Stage 23:** Tier 2 tactical, campaign & UI flows (`0x080332..0x080539`, `1,214 total`).
- [x] **Stage 24:** Remaining Tier 2, Softfp Math & Clean Helpers `< 0x08080000` (`0ba0c68`, `1,274 total`).
- [x] **Stage 25:** Campaign, UI Animator Spawners & Combat HUD Builders `< 0x08080000` (`ff4e63c`, `1,334 total`).
- [x] **Stage 26:** Remaining Straight-Line, Flash/Menu Screen & Tail Thunks (`3b4c6d9`, `1,394 total`).
- [x] **Stage 27:** Overlay Tail Thunks & Argument Wrappers (`91aa0f4`, `1,454 total`).
- [x] **Stage 28:** Overlay Straight-Line Wrappers (`25dd790`, `1,514 total`).
- [x] **Stage 29:** Overlay Field Accessors & Multi-Step Calls (`4de151b`, `1,574 total`).
- [x] **Stage 30:** Overlay Extended Bitsets & Slot Handlers (`51e3c27`, `1,634 total`).
- [x] **Stage 31:** Overlay Slot Cursors, Tilemaps & Softfp Math (`c8444e6`, `1,694 total`).
- [x] **Stage 32:** Remaining Overlay & Mid-ROM Straight-Line Wave (`1a224c6`, `1,754 total`).
- [x] **Stage 33:** Final `0x0808..0x083A` straight-line functions (`ee45538`, `1,804 total`).
- [x] **Stage 34:** Low-ROM branching & tail-call dispatch (`a3f1b4e`, `1,870 total`).
- [x] **Stage 35:** Hi-ROM tail-call wave 1 (`1054f2f`, `1,950 total`).
- [x] **Stage 36:** Hi-ROM tail-call wave 2 (`34b1252`, `2,030 total`).
- [x] **Stage 37:** Small low-ROM shared-body `enter_*` clusters (`6b0f60e`, `2,111 total`).
- [x] **Stage 38:** Hi-ROM tail-call wave 3 (`69d3585`, `2,210 total`).
- [x] **Stage 39:** Final hi-ROM tail-call wave 4 (`64f193c`, `2,306 total`, 3 giant linear data blobs deferred).
- [x] **Stage 40:** Closed hi-ROM shared-body `enter_*` clusters (`8fac607`, `2,415 total`, 46 clusters lifted; 3 giant data clusters `COMP[28..30]` deferred).
- [x] **Stage 41:** Remaining closed low-ROM shared-body `enter_*` clusters (`cc49930`, `2,448 total`, 3 clusters / 33 funcs).
- [x] **Stage 42:** Low-ROM block-peeled wave 1 (`fceb2d1`, `2,633 total`, first 185 `<= 30L` functions).
- [x] **Stage 43:** Low-ROM block-peeled wave 2 (`89a7209`, `2,819 total`, remaining 186 `<= 30L` functions).
- [x] **Stage 44:** Hi-ROM block-peeled wave 1 (`a5d546c`, `3,089 total`, 270 `<= 30L` hi-ROM functions).
- [x] **Stage 45:** Low-ROM block-peeled wave 3 (`d99ccb2`, `3,279 total`, first 190 `31..60L` functions).
- [x] **Stage 46:** Low-ROM block-peeled wave 4 (`e758bec`, `3,464 total`, next 185 `31..60L` functions + 7 jump-table peeling fixes in `low_peel_1`/`3`).
- [x] **Stage 47:** Low-ROM block-peeled wave 5 (`1cc4f44`, `3,650 total`, remaining 186 `31..60L` functions).
- [x] **Stage 48:** Hi-ROM block-peeled wave 2 (`f955fca`, `3,842 total`, first 192 `31..60L` hi-ROM functions).
- [x] **Stage 49:** Hi-ROM block-peeled wave 3 (`bbb3775`, `4,035 total`, remaining 193 `31..60L` hi-ROM functions).
- [x] **Stage 50:** Low-ROM block-peeled wave 6 (`308c4f2`, `4,243 total`, first 208 `61..120L` functions).
- [x] **Stage 51:** Low-ROM block-peeled wave 7 (`ef9f30d`, `4,452 total`, next 209 `61..120L` functions).
- [x] **Stage 52:** Low-ROM block-peeled wave 8 (`906f33b`, `4,661 total`, next 209 `61..120L` functions).
- [x] **Stage 53:** Low-ROM block-peeled wave 9 (`57c598d`, `4,870 total`, remaining 209 `61..120L` functions).
- [x] **Stage 54:** Hi-ROM block-peeled wave 4 (`cebcdc2`, `5,046 total`, first 176 `61..120L` hi-ROM functions).
- [x] **Stage 55:** Hi-ROM block-peeled wave 5 (`4e7cf5f`, `5,222 total`, next 176 `61..120L` hi-ROM functions).
- [x] **Stage 56:** Hi-ROM block-peeled wave 6 (`51e8700`, `5,398 total`, remaining 176 `61..120L` hi-ROM functions).
- [x] **Stage 57:** Low-ROM block-peeled wave 10 (`8205f9a`, `5,566 total`, first 168 `121..250L` functions).
- [x] **Stage 58:** Low-ROM block-peeled wave 11 (`33daaa3`, `5,734 total`, next 168 `121..250L` functions).
- [x] **Stage 59:** Low-ROM block-peeled wave 12 (`e12185a`, `5,902 total`, next 168 `121..250L` functions).
- [x] **Stage 60:** Low-ROM block-peeled wave 13 (`5cbce6e`, `6,070 total`, remaining 168 `121..250L` functions).
- [x] **Stage 61:** Hi-ROM block-peeled wave 7 (`b11e081`, `6,206 total`, first 136 `121..250L` hi-ROM functions).
- [x] **Stage 62:** Hi-ROM block-peeled wave 8 (`f96d14c`, `6,342 total`, next 136 `121..250L` hi-ROM functions).
- [x] **Stage 63:** Hi-ROM block-peeled wave 9 (`13e74af`, `6,479 total`, remaining 137 `121..250L` hi-ROM functions).
- [x] **Stage 64:** Low-ROM block-peeled wave 14 (`4ef04a4`, `6,566 total`, first 87 `251..500L` functions).
- [x] **Stage 65:** Low-ROM block-peeled wave 15 (`21bc62b`, `6,653 total`, next 87 `251..500L` functions).
- [x] **Stage 66:** Low-ROM block-peeled wave 16 (`18704ad`, `6,740 total`, next 87 `251..500L` functions).
- [x] **Stage 67:** Low-ROM block-peeled wave 17 (`0b2eb59`, `6,827 total`, remaining 87 `251..500L` functions).
- [x] **Stage 68:** Hi-ROM block-peeled wave 10 (`1137fe9`, `6,939 total`, first 112 `251..500L` hi-ROM functions).
- [x] **Stage 69:** Hi-ROM block-peeled wave 11 (`0bed36c`, `7,051 total`, remaining 112 `251..500L` hi-ROM functions).
- [x] **Stage 70:** Low-ROM block-peeled wave 18 (`36a65c8`, `7,096 total`, first 45 `> 500L` functions).
- [x] **Stage 71:** Low-ROM block-peeled wave 19 (`94335da`, `7,142 total`, remaining 46 `> 500L` functions — 100% low-ROM complete).
- [x] **Stage 72:** Hi-ROM deduplicated component wave 1 (`e1fa112`, `7,197 total`, 7 components / 55 `> 500L` hi-ROM functions).
- [x] **Stage 73:** Hi-ROM deduplicated component wave 2 (`db2dfa0`, `7,245 total`, 16 components / 48 `> 500L` hi-ROM functions).
- [x] **Stage 74:** Hi-ROM deduplicated component wave 3 (`7,316 total`, 14 components / 71 `> 500L` hi-ROM functions).

## Verification Gate (Every Milestone)
1. `zig build test --summary all`
2. `zig build -Doptimize=ReleaseFast && zig build wasm`
3. `bash scripts/conformance.sh` (`GBA_VALIDATE=3` live ARM7TDMI agreement)
4. `bash scripts/smoke.sh` (`FT_EXACT` 0-byte diff vs `scratch/ref_ft.bmp`)
5. `sha256sum game/aw.sav` unchanged
