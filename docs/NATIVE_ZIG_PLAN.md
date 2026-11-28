# Native Zig Refactoring Plan

## Current Baseline
- **ROM coverage:** `7,577 / 7,577` (`100.00%`) functions lifted into `src/game/` with strong exports and zero `gen/` dependency in default builds (`zig build translate` + `-Duse-gen=true` retained for reference).
- **Recompilation glue promoted to `src/game/`:** [decls.zig](../src/game/decls.zig), [dispatch.zig](../src/game/dispatch.zig), [stubs.zig](../src/game/stubs.zig), [unresolved.zig](../src/game/unresolved.zig), and [core.zig](../src/game/core.zig).
- **Parallel object build:** `build.zig` compiles standalone `src/game/*.zig` modules in parallel (`ReleaseFast` cold build **121s**, down from **175s**).
- **Basic call reconnecting:** `1,180` intra-file `decls.func_*` calls across `55` modules converted to direct local calls.

## Goal
Incrementally transform the lifted ARM register/bus Zig code (`rt.r[0..14]`, raw hex RAM offsets, `func_08XXXXXX` ABI wrappers) into clean, modular, idiomatic Zig with typed structs, direct calls, and hardware abstraction — keeping every milestone 100% verified via the mandatory 5-part gate.

---

## Phase 1 — Hot-Path Profiling & Reachability Map
- **Status:** Complete (`GBA_VALIDATE_PROFILE=1` added to [validate.zig](../src/validate/validate.zig))
- **Field Training Profile (2,500 frames):** `436` unique executed functions (`153` in domain modules, `283` in peel/cluster/tail modules, `0` hi-ROM `>= 0x08080000`), `12,987,168` total calls.
- **Top Modules by Call Volume:**
  - `tail_low.zig`: `6` funcs, `4,267,460` calls (`32.9%`)
  - `low_peel_8.zig`: `27` funcs, `4,239,057` calls (`32.6%`)
  - `low_peel_4.zig`: `6` funcs, `4,236,350` calls (`32.6%`)
  - `low_peel_6.zig`: `47` funcs, `80,732` calls (`0.6%`)
  - `dma.zig`: `6` funcs, `36,149` calls (`0.3%`)
  - `low_peel_13.zig`: `17` funcs, `22,272` calls (`0.2%`)
  - `clusters_low_2.zig`: `17` funcs, `20,673` calls (`0.2%`)
  - `hw.zig`: `18` funcs, `20,009` calls (`0.2%`)
  - `bios.zig`: `5` funcs, `19,798` calls (`0.2%`)
- **Top Hot Functions (`97.7%` of all calls):** `func_0807B44C` (`tail_low.zig`, `4,236,312` calls), `func_08038824` (`low_peel_4.zig`, `4,236,280` calls), `func_080383F8` (`low_peel_8.zig`, `4,219,200` calls), followed by `func_08018B68` (`24,530`), `func_080112C0` (`18,121`), `func_0800FD94` (`dma.zig`, `18,043`), `func_080796C4` (`bios.zig`, `18,042`), `func_08011374` (`dma.zig`, `17,972`), `func_0807B45C` (`17,197`), `func_0801B888` (`hw.zig`, `17,168`).

## Phase 2 — Typed Memory & Core Game Structs (`types.zig`, `mem.zig`)
- **Status:** Complete (`extern struct` layouts + `@sizeOf`/`@offsetOf` tests in [types.zig](../src/game/types.zig); typed RAM/struct helpers in [mem.zig](../src/game/mem.zig) wired into live domain code)
- **Verified Structs (`types.zig`):** `MapWorkspace`, `ProcSlot` (`flags` at `0x12`, `anim_slot` at `0x26`, `state38` at `0x38`), `ScriptSlot`, `AnimSlot`, `OamAttr`, `OamQueueEntry`, `CursorState`, `CameraState`, `UnitEntity`, `UnitRecord`, `BattleSideCtx`, `MenuGuardEntry` (remaining `_pad` bytes will be named incrementally as Phase 3 lifts more functions).
- **Wired Typed Accessors (`mem.zig`):** `readU8/U16/I16/U32`, `writeU8/U16/I16/U32`, `readStruct`, `procSlotAddr`, `scriptSlotAddr`, `animSlotAddr`, `oamAttrAddr`, `oamQueueAddr`, `entitySlotAddr`, `entityTableBase`, `cameraStateAddr`/`readCameraState` ([map.zig](../src/game/map.zig)), `readCursorTile`/`writeCursorPx` ([map.zig](../src/game/map.zig)), `readBattleSideCtx`/`readUnitHp` ([battle.zig](../src/game/battle.zig)), `entitySlotAddr`/`entityTableBase` ([unit.zig](../src/game/unit.zig)), `@offsetOf(ProcSlot, "anim_slot")` ([sprite_anim.zig](../src/game/sprite_anim.zig)), `mem.procSlotAddr` ([proc.zig](../src/game/proc.zig)).
- **Verification:** `@sizeOf` / `@offsetOf` layout assertions + stride/bitmask unit tests in `zig build test`.

## Phase 3 — Bottom-Up Idiomatic Zig Subsystems (Thin ABI Bridge Pattern)
Refactor subsystems bottom-up into typed Zig functions while keeping thin 3–5 line `func_08XXXXXX` ABI bridges until all callers become native Zig:

- **3A — Low-Level Utilities & Top Hot Loops:**
  - [x] **3A.1 — Core Math & Main Frame Loop (`math.zig`, `main_loop.zig`, `tail_low.zig`):** Pure Zig `nextRngSeed` & `mulMat3Vec3Q12` ([math.zig](../src/game/math.zig)); top hot loops `func_08038824` (`isSoftResetComboPressed`), `func_080383F8`, `func_0803849C`, and `func_0805BA34` lifted & connected in [main_loop.zig](../src/game/main_loop.zig); `func_0807B44C` (`__call_via_r0`) documented in [tail_low.zig](../src/game/tail_low.zig).
  - [x] **3A.2 — Palette Flush, Menu Guard & Proc Dispatch (`menu.zig`, `hw.zig`, `proc.zig`, `dma.zig`):** `func_08018B68` (`lookupGuardTable` in [menu.zig](../src/game/menu.zig)), `func_080112C0` (palette sync in [hw.zig](../src/game/hw.zig)), `func_08013984` (proc tick) + `func_0801A6D8` (task queue pop) in [proc.zig](../src/game/proc.zig), `types.addr.pal_ram` in [dma.zig](../src/game/dma.zig).
  - [x] **3A.3 — Fixed-Point Trig (`math.zig`):** Lift `func_0807AED4` (`sinDeg` / `normalizeSinDeg`) out of [clusters_low_2.zig](../src/game/clusters_low_2.zig) into [math.zig](../src/game/math.zig) and connect `func_0807AF30` (`cosDeg`) directly.
  - [x] **3A.4 — Integer Division Runtime Helpers (`clusters_low_2.zig` → `math.zig`):** `func_0807B488` (`__divsi3` / `divSigned32`) lifted to [math.zig](../src/game/math.zig) with edge-case tests; `func_0807B51C` (`__div0`) already clean in [hw.zig](../src/game/hw.zig).
  - [x] **3A.5 — Integer Modulo Runtime Helpers (`low_peel_13.zig` → `math.zig`):** `__umodsi3` (`func_0807B6AC`, `11,316` calls) & `__modsi3` (`func_0807B564`, `8,542` calls) lifted out of [low_peel_13.zig](../src/game/low_peel_13.zig) into [math.zig](../src/game/math.zig) via shared `modU32Radix16` + pure `modUnsigned32`/`modSigned32` helpers & tests.
  - [x] **3A.6 — Core VRAM/Palette DMA Helpers (`dma.zig` / `types.zig`):** Lift `func_0800FDA4` (`cpuCopyAuto` / `isFastCopyAligned`) from [low_peel_3.zig](../src/game/low_peel_3.zig) and `func_0800FFA8` (VBlank DMA queue + `DmaQueueEntry` in [types.zig](../src/game/types.zig)) from [low_peel_10.zig](../src/game/low_peel_10.zig) into [dma.zig](../src/game/dma.zig) and reconnect local callers (`func_0801122C` is key/input polling belonging to Phase 3C [hw.zig](../src/game/hw.zig)).
- **3B — Core Game Data & Simulation (`map.zig`, `unit.zig`, `co.zig`, `battle.zig`):**
  - [x] **3B.1 — CO Identity & Entity Field Accessors (`co.zig`, `unit.zig`, `types.zig`, `low_peel_1.zig`):** Expand `UnitEntity` (`co_id`, `funds`, `counter25`), lift `func_0801BE04` (`normalizeCoId`), `func_0801BF50`, `func_0801BFE8`, `func_0801C000`, `func_0801C0E4` out of [low_peel_1.zig](../src/game/low_peel_1.zig) into [co.zig](../src/game/co.zig), and wire `mem.entitySlotAddr`/`@offsetOf(UnitEntity, ...)` into [co.zig](../src/game/co.zig) and [unit.zig](../src/game/unit.zig).
  - [x] **3B.2 — Map Cursor & Workspace Accessors (`map.zig`, `mem.zig`, `types.zig`, `low_peel_1.zig`):** Lift `func_08020538`, `func_08021E04`, `func_08021E1C`, `func_08021E1E`, `func_080227EC`, and `func_08022800` out of [low_peel_1.zig](../src/game/low_peel_1.zig) into [map.zig](../src/game/map.zig) using `tileToPx`, `mem.writeCursorTile`, and `mem.readSavedCursorTile`/`writeSavedCursorTile`.
  - [x] **3B.3 — Map Reachability Grid & Highlight Tile Helpers (`map.zig`, `mem.zig`, `types.zig`, `low_peel_6.zig`, `low_peel_7.zig`):** Lift `func_0801D048` (`fillReachabilityGrid`) and `func_080201D8` (`drawReachabilityTile`) into [map.zig](../src/game/map.zig) sharing `writeMetaTile2x2` (`func_0801FD98`/`func_080201D8`) and typed `mem.reachabilityRowPtr`/`readReachability`.
  - [x] **3B.4 — Unit Record, Stats & Action Helpers (`unit.zig`, `types.zig`, `mem.zig`, `battle.zig`, `low_peel_1.zig`):** Expand 12-byte `UnitRecord` (`unit_type`, `tile_x`, `tile_y`, `hp_flags`, `state_flags`) and `UnitEntity.gold`, add `mem.unitListBase`/`unitRecordAddr`, wire into `func_08023D2C` ([battle.zig](../src/game/battle.zig)), and lift `func_08024154` (`clampArmyFunds`), `func_08024CC0`, `func_08025874`, `func_08026020`, `func_08026048` out of [low_peel_1.zig](../src/game/low_peel_1.zig) into [unit.zig](../src/game/unit.zig).
  - [x] **3B.5 — Battle Combat Exchange & Remaining-HP Resolution (`battle.zig`, `types.zig`, `low_peel_7.zig`):** Name `BattleSideCtx.counter_power` (`+0x10`), add `computeCounterAttackPower` and `clampCombatRemainingHp` (`CombatHpPair`) with unit tests, and lift `func_080234CC` (full attack + counterattack exchange calling local `func_080234A0`) and `func_08023508` (post-combat HP normalization) out of [low_peel_7.zig](../src/game/low_peel_7.zig) into [battle.zig](../src/game/battle.zig).
- **3C — Engine, Task Scheduler & Hardware (`proc.zig`, `hw.zig`, `sprite_anim.zig`, `sound.zig`, `state.zig`):**
  - [x] **3C.1 — Proc & Script Scheduler Helpers (`proc.zig`, `mem.zig`, `types.zig`):** Lift core proc/script slot allocation, lookup, and timer helpers and wire `mem.scriptSlotAddr`.
  - [x] **3C.2 — Sprite Animator & OAM Queue Helpers (`sprite_anim.zig`, `mem.zig`):** Lift core animator/OAM queue builders and wire `mem.animSlotAddr`, `mem.oamAttrAddr`, `mem.oamQueueAddr`.
  - [x] **3C.3 — Hardware Input, Display & IRQ Helpers (`hw.zig`, `main_loop.zig`):** Lift key polling (`func_0801122C`) and hardware register sync helpers into `hw.zig`.
  - [x] **3C.4 — Audio Triggers & Game State Helpers (`sound.zig`, `state.zig`):** Lift core SFX/BGM trigger wrappers and top-level game state transition helpers.
- **3D — Gameplay, UI, Turns & AI (`turn.zig`, `menu.zig`, `ui.zig`, `campaign.zig`, `overlay*.zig`, hot `low_peel_*` / `clusters_low*`):**
  - [x] **3D.1 — Turn Phase & Day/CO Transition Helpers (`turn.zig`):** Lift mode-gated turn phase transition helpers (`func_08033464`, `func_08033498`, `func_080334C4`) into `turn.zig`.
  - [x] **3D.2 — Command Menu & Guard Table Helpers (`menu.zig`):** Lift core tactical/command menu dispatch helpers into `menu.zig`.
  - [x] **3D.3 — Campaign Flow & UI Dialog Helpers (`campaign.zig`, `ui.zig`):** Lift core campaign progression and UI dialog helpers.
  - [x] **3D.4 — AI Evaluation & Tactical Helpers (`unit.zig`, `map.zig`, `battle.zig`):** Lift core AI target/unit evaluation helpers from hot `low_peel_*` files.

## Phase 4 — Cross-Module Direct Calls & ABI Bridge Removal
- **Objective:** Import refactored subsystems directly between `src/game/` modules, call typed Zig functions instead of `decls.func_XXXXXXXX()`, and delete obsolete `func_08XXXXXX` wrappers and `rt.r[..]` shuffling.
  - [x] **4A — Core Engine & Runtime Module Graph (`build.zig`, `core.zig`, `hw.zig`, `main_loop.zig`, `unit.zig`, `battle.zig`, `proc.zig`, `sound.zig`, `math.zig`):** Consolidate `math.zig`, `main_loop.zig`, `sound.zig`, and `proc.zig` into `core.zig` and replace cross-module `decls.*` calls (DMA, BIOS, HW, Sound, Proc) with direct Zig module calls.
  - [x] **4B — Gameplay Domain Module Graph (`map.zig`, `co.zig`, `sprite_anim.zig`, `state.zig`):** Consolidate `map.zig`, `co.zig`, `sprite_anim.zig`, and `state.zig` into `core.zig` and rewire cross-module `decls.*` calls to direct Zig imports.
  - [x] **4C — High-Level UI, Turn, Menu & Campaign Graph (`turn.zig`, `menu.zig`, `campaign.zig`):** Consolidate `turn.zig`, `menu.zig`, and `campaign.zig` into `core.zig` and rewire cross-module `decls.*` calls to direct Zig imports.
  - [x] **4D — UI Module Consolidation & Typed Zig API Call Migration (`ui.zig`, `battle.zig`, `dma.zig`, `menu.zig`, `core.zig`):** Consolidate `ui.zig` into `core.zig` and replace internal `rt.r[..] + abi.call()` sites between lifted modules with direct typed Zig function calls where safe.
  - [x] **4E — Retire Obsolete `func_08XXXXXX` Wrappers & Prune `decls.zig` (`core.zig`, `decls.zig`):** Eliminated all `228` remaining `core -> core` `decls.*` calls across `15` modules (`0` remaining inside `core.zig`) and pruned `79` unreferenced `decls.zig` extern entries (`7,806 -> 7,727`; all `1,456` core `@export`s remain referenced by `dispatch.zig` indirect jump table).
  - [x] **4F — Prune Hi-ROM Asset Disassembly & Multiboot Payloads (`src/game/`, `ui.zig`, `dispatch.zig`, `decls.zig`, `root.zig`):** Deleted `27` false-positive asset-disassembly and embedded Link-Cable multiboot `.zig` files (`407,522` lines) plus `13` multiboot functions in [ui.zig](file:///home/moon/Projects/zig/advancewars/src/game/ui.zig), and pruned [dispatch.zig](file:///home/moon/Projects/zig/advancewars/src/game/dispatch.zig) (`7,578 -> 4,440` entries) and [decls.zig](file:///home/moon/Projects/zig/advancewars/src/game/decls.zig) (`7,727 -> 4,439` externs); all `4,439` real game functions (`< 0x08080000`) and raw multiboot ROM payloads in `game/aw.gba` remain 100% intact.
  - [x] **4G — Prune Zero-Caller Recomp Stubs (`stubs.zig`, `unresolved.zig`):** Removed `src/game/stubs.zig` (`151` unreferenced weak stubs, `311` lines) and `src/game/unresolved.zig` (`78` unreferenced weak trap stubs, `706` lines); audited all `4,439` real low-ROM (`< 0x08080000`) functions and kept `100%` intact.
  - [ ] **4H — Lift Remaining Live Gameplay Out of `low_peel_*` / `clusters_low_*` / `tail_low.zig`:** Move the remaining `283` Field-Training-executed functions from unlifted low-ROM shards into the `17` domain modules in `core.zig` (starting with the hottest shards: `low_peel_6`, `low_peel_8`, `low_peel_13`, `clusters_low_2`, `low_peel_4`, `tail_low`).
    - [x] **4H.1 — Consolidate `tail_low.zig` (`66` funcs, `904` lines) into `core.zig`:** Promoted `tail_low.zig` (including the #1 hottest `__call_via_r0` trampoline `func_0807B44C`) into `core.zig` and rewired all `28` `core -> tail_low` and `9` `tail_low -> core` `decls.*` calls to direct Zig calls.
  - [ ] **4I — Retire `rt.r[]` Register ABI Inside `core.zig`:** Convert the remaining `844` `rt.r[]`-using functions across the `17` domain modules into typed Zig signatures and remove internal `rt.r[0..14]` shuffling before Phase 5.

## Phase 5 — Hardware Decoupling
- **Objective:** Replace direct GBA MMIO (`0x0400_0000`) register writes and PPU frame-lock loops with native rendering, audio, and input interfaces so the game can eventually run independent of GBA hardware emulation.

---

## Mandatory 5-Part Verification Gate (Every Milestone)
1. `zig build test --summary all` (20/20 unit tests including layout & helper tests pass)
2. `zig build -Doptimize=ReleaseFast && zig build wasm`
3. `bash scripts/conformance.sh` (`164/164 functions agree`)
4. `GBA_VALIDATE=1` (`08000000-08400000`, 2,500 frames on `replays/field_training.txt`): `436/436 functions agree` with zero `VALIDATE .* FAIL`
5. `bash scripts/smoke.sh` + `cmp` vs `scratch/ref_ft.bmp` (`FT_EXACT`) and unchanged `game/aw.sav` SHA-256 (`bb3b5651dd61b18f01dc0225e389d4d3251c7bc30706aedb97c4eb74e3644622`)
