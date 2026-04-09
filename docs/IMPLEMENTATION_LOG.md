# Implementation Log — WBK-Bulwarks Integration Adapter

---

## Phase 1: Core Adapter — COMPLETE

**Date:** 2026-04-09  
**Status:** Built, pending in-game MVP test

### Components Delivered

| # | File | Function Name | Purpose |
|---|---|---|---|
| 1 | `hostiles/wbk/fn_spawnWBKUnit.sqf` | `EJ_fnc_spawnWBKUnit` | Single-unit spawner with Bulwarks scoring hooks |
| 2 | `hostiles/wbk/fn_wbkHitPartScore.sqf` | `EJ_fnc_wbkHitPartScore` | HitPart → Bulwarks score bridge |
| 3 | `hostiles/wbk/mvpTest.sqf` | *(debug console snippet)* | Spawns 1 Runner, verifies integration |
| 4 | `hostiles/wbk/Functions.hpp` | — | CfgFunctions class declarations |

### Files Modified

| File | Change |
|---|---|
| `description.ext` | Added `#include "hostiles\wbk\Functions.hpp"` to CfgFunctions; added `spawnWBKUnit` and `wbkHitPartScore` to CfgRemoteExec |

### Global Variable Dependencies

#### Read (existing Bulwarks globals — must be defined before use)

| Variable | Defined In | Used By |
|---|---|---|
| `SCORE_HIT` | `editMe.sqf` | `fn_wbkHitPartScore` |
| `SCORE_DAMAGE_BASE` | `editMe.sqf` | `fn_wbkHitPartScore` |
| `SCORE_KILL` | `editMe.sqf` | `fn_killed.sqf` (via Killed EH) |
| `BULWARK_RADIUS` | `editMe.sqf` | *(not used in Phase 1 — will be used by Phase 2 wave spawner)* |
| `waveUnits` | `missionLoop.sqf` | `fn_spawnWBKUnit` (body cleanup tracking) |
| `mainZeus` | `initServer.sqf` | `fn_spawnWBKUnit` (curator editability) |
| `playableUnits` | Engine | `fn_spawnWBKUnit` (initial doMove target) |

#### Read (WBK mod globals — set by CBA settings in `XEH_preInit.sqf`)

| Variable | Default | Used By |
|---|---|---|
| `WBK_Zombies_HeadshotMP` | 5 | `fn_wbkHitPartScore` |

#### Written (new adapter variables)

| Variable | Set By | Scope | Purpose |
|---|---|---|---|
| `EJ_wbk_maxHP` | `fn_spawnWBKUnit` | Per-unit (`setVariable`) | Snapshot of initial WBK_SynthHP for score normalisation |

### Architecture Notes

1. **Auto-Init Reliance:** `EJ_fnc_spawnWBKUnit` does NOT manually call WBK AI scripts or set `WBK_AI_ISZombie` / `WBK_SynthHP` / `WBK_AI_ZombieMoveSet`. These are handled automatically by `Extended_InitPost_EventHandlers` in the WBK mod's `config.cpp` when `createUnit` instantiates a WBK classname.

2. **Additive HitPart EH:** `EJ_fnc_wbkHitPartScore` is registered alongside (not replacing) the WBK-native HitPart EH. Both fire in registration order. The bridge only reads hit data for scoring — it does not modify `WBK_SynthHP`.

3. **Killed EH Chain:** When WBK's HitPart handler depletes `WBK_SynthHP` to zero, it calls `setDamage 1` which fires Arma's Killed EH. The Bulwarks `killPoints_fnc_killed` (attached by the adapter) processes this normally, reading `killPointMulti` and `points[]`.

4. **Compiled Function Names:** Via CfgFunctions tag `EJ` with subclass `wbk`, the functions compile as `EJ_fnc_spawnWBKUnit` and `EJ_fnc_wbkHitPartScore`, matching the design spec naming convention.

---

## Phase 2: Wave Spawner — NOT STARTED

Pending components:
- `EJ_fnc_initWBKRegistry` — Unit registry and budget parameters
- `EJ_fnc_buildWaveManifest` — Budget allocation algorithm
- `EJ_fnc_spawnWBKWave` — Main entry point (replaces createWave infantry loops)
- `createWave.sqf` hook modification
- `initServer.sqf` registry init call

---

## Phase 3: Special Wave Handling — NOT STARTED

Pending components:
- Bloater Rush (suicide wave replacement)
- Breach Horde (switcharoo wave replacement)
- Special wave type gating in `fn_startWave.sqf`
