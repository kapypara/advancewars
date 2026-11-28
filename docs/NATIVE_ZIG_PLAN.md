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
- **Status:** Pending
- **Objective:** Trace all executed functions across gameplay replays (`replays/title.txt`, `replays/field_training.txt`) using `GBA_VALIDATE=3` and map every active address to its owning module and line count in `src/game/`.
- **Why:** Separate the ~400–1,500 hot engine and gameplay functions from cold/rare hi-ROM code so refactoring focuses on live code first.

## Phase 2 — Typed Memory & Core Game Structs (`types.zig`, `mem.zig`)
- **Status:** In Progress
- **Objective:** Replace raw hex EWRAM/IWRAM/MMIO reads (`abi.read16(0x0202...)`) with verified `extern struct` definitions in [types.zig](../src/game/types.zig) and zero-overhead typed accessors in [mem.zig](../src/game/mem.zig):
  - `MapWorkspace`, `ProcSlot`, `ScriptSlot`, `AnimSlot`, `OamEntry`
  - `CursorState`, `Tile`, `Unit`, `Army`, `CO`, `BattleState`
- **Verification:** Comptime `@sizeOf` / `@offsetOf` layout assertions in `zig build test`.

## Phase 3 — Bottom-Up Idiomatic Zig Subsystems (Thin ABI Bridge Pattern)
Refactor subsystems bottom-up into typed Zig functions while keeping thin 3–5 line `func_08XXXXXX` ABI bridges until all callers become native Zig:

- **3A — Low-Level Utilities (`math.zig`, `bios.zig`, `dma.zig`):**
  - Pure Zig PRNG, fixed-point Q12 math, `CpuSet`/`CpuFastSet`/`LZ77`/`HuffUnComp` wrappers, DMA helpers.
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
