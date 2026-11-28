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
- **Status:** Complete (`extern struct` layouts + comptime size/offset tests in [types.zig](../src/game/types.zig); typed struct/RAM readers & writers in [mem.zig](../src/game/mem.zig))
- **Verified Structs (`types.zig`):** `MapWorkspace`, `ProcSlot` (`flags` at `0x12`), `ScriptSlot`, `AnimSlot`, `OamAttr`, `OamQueueEntry`, `CursorState`, `CameraState`, `UnitEntity`, `UnitRecord`, `BattleSideCtx`, `MenuGuardEntry`.
- **Typed Accessors (`mem.zig`):** `readU8/U16/I16/U32`, `writeU8/U16/I16/U32`, `readStruct`/`writeStruct`, `procSlotAddr`/`readProcSlot`/`writeProcSlot`, `scriptSlotAddr`/`readScriptSlot`, `animSlotAddr`/`readAnimSlot`, `oamAttrAddr`/`readOamAttr`, `oamQueueAddr`, `entitySlotAddr`/`entityTableBase`, `readMapWorkspace`, `readCursorTile`/`readCursorState`/`writeCursorState`, `cameraStateAddr`/`readCameraState`, `readBattleSideCtx`, `readUnitHp`.
- **Verification:** `@sizeOf` / `@offsetOf` layout assertions + stride unit tests in `zig build test`.

## Phase 3 — Bottom-Up Idiomatic Zig Subsystems (Thin ABI Bridge Pattern)
Refactor subsystems bottom-up into typed Zig functions while keeping thin 3–5 line `func_08XXXXXX` ABI bridges until all callers become native Zig:

- **3A — Low-Level Utilities & Top Hot Loops (`math.zig`, `main_loop.zig`, `tail_low.zig`, `bios.zig`, `dma.zig`):**
  - Pure Zig PRNG (`nextRngSeed`), fixed-point Q12 3x3 matrix*vector (`mulMat3Vec3Q12` in [math.zig](../src/game/math.zig)).
  - Top 3 dynamic hot functions (`97.7%` of Field Training calls) refactored/documented: `func_08038824` (soft-reset key combo) and `func_080383F8` (per-frame 8-step tick dispatcher) lifted to [main_loop.zig](../src/game/main_loop.zig); `func_0807B44C` documented as GCC `__call_via_r0` trampoline in [tail_low.zig](../src/game/tail_low.zig).
  - Next 3 hottest active peeled functions (`54,154` calls in `low_peel_6.zig`) lifted into domain modules: `func_08018B68` (`lookupGuardTable` in [menu.zig](../src/game/menu.zig)), `func_080112C0` (palette RAM sync in [hw.zig](../src/game/hw.zig)), `func_08013984` (proc slot tick in [proc.zig](../src/game/proc.zig)).
  - Next Phase 3A hot batch (`23,804` calls): `func_0803849C` (secondary gated tick dispatcher) & `func_0805BA34` (input shadow snapshot, directly connected inside `main_loop.zig`) lifted to [main_loop.zig](../src/game/main_loop.zig); `func_0801A6D8` (task queue head pop) lifted to [proc.zig](../src/game/proc.zig); `pal_ram` symbol cleanup in [dma.zig](../src/game/dma.zig).
  - Remaining: `CpuSet`/`CpuFastSet`/`LZ77`/`HuffUnComp` callers & `low_peel_13.zig` hot loops (`func_0807B6AC`, `func_0807B564`).
- **3B — Core Game Data & Simulation (`map.zig`, `unit.zig`, `co.zig`, `battle.zig`):**
  - Typed tile/unit lookups, movement cost, BFS reachability, damage calculation, capture/supply/vision rules.
- **3C — Engine, Task Scheduler & Hardware (`proc.zig`, `hw.zig`, `sprite_anim.zig`, `sound.zig`, `state.zig`):**
  - Typed `Proc` tree scheduler, OAM/BG queue builders, audio triggers, main state loop.
- **3D — Gameplay, UI, Turns & AI (`turn.zig`, `menu.zig`, `ui.zig`, `campaign.zig`, `overlay*.zig`, hot `low_peel_*` / `clusters_low*`):**
  - Turn phase machine, command menus, CO power logic, campaign flow, AI evaluation.

## Phase 4 — Cross-Module Direct Calls & ABI Bridge Removal
- **Objective:** Import refactored subsystems directly between `src/game/` modules, call typed Zig functions instead of `decls.func_XXXXXXXX()`, and delete obsolete `func_08XXXXXX` wrappers and `rt.r[..]` shuffling.

## Phase 5 — Hardware Decoupling
- **Objective:** Replace direct GBA MMIO (`0x0400_0000`) register writes and PPU frame-lock loops with native rendering, audio, and input interfaces so the game can eventually run independent of GBA hardware emulation.

---

## Mandatory 5-Part Verification Gate (Every Milestone)
1. `zig build test --summary all` (20/20 unit tests including layout & helper tests pass)
2. `zig build -Doptimize=ReleaseFast && zig build wasm`
3. `bash scripts/conformance.sh` (`164/164 functions agree`)
4. `GBA_VALIDATE=1` (`08000000-08400000`, 2,500 frames on `replays/field_training.txt`): `436/436 functions agree` with zero `VALIDATE .* FAIL`
5. `bash scripts/smoke.sh` + `cmp` vs `scratch/ref_ft.bmp` (`FT_EXACT`) and unchanged `game/aw.sav` SHA-256 (`bb3b5651dd61b18f01dc0225e389d4d3251c7bc30706aedb97c4eb74e3644622`)
