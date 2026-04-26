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

## Phase 2: Wave Spawner — COMPLETE

**Date:** 2026-04-10  
**Status:** Built, pending in-game wave test

### Components Delivered

| # | File | Function Name | Purpose |
|---|---|---|---|
| 1 | `hostiles/wbk/fn_initWBKRegistry.sqf` | `EJ_fnc_initWBKRegistry` | Registry, budget params, caps, cooldown trackers |
| 2 | `hostiles/wbk/fn_buildWaveManifest.sqf` | `EJ_fnc_buildWaveManifest` | Top-down budget allocation (T5→T4→T3→T2→T1) |
| 3 | `hostiles/wbk/fn_spawnWBKWave.sqf` | `EJ_fnc_spawnWBKWave` | Main entry point: manifest → sort → batched spawn → drip-feed |

### Files Modified

| File | Change |
|---|---|
| `hostiles/wbk/Functions.hpp` | Added `initWBKRegistry`, `buildWaveManifest`, `spawnWBKWave` classes |
| `description.ext` | Added `initWBKRegistry`, `buildWaveManifest`, `spawnWBKWave` to CfgRemoteExec |
| `initServer.sqf` | Added `[] call EJ_fnc_initWBKRegistry` after editMe.sqf, before createBase.sqf |
| `hostiles/createWave.sqf` | Replaced 3 infantry `for` loops with `EJ_fnc_spawnWBKWave` call + `waitUntil { EJ_wbkSpawnComplete }` gate |

### Global Variables — Phase 2

#### Written (new adapter globals)

| Variable | Set By | Scope | Purpose |
|---|---|---|---|
| `EJ_wbk_unit_registry` | `fn_initWBKRegistry` | Server global | Array-of-arrays unit registry (Spec §2.2) |
| `EJ_wavesSinceSmasher` | `fn_initWBKRegistry` / `fn_buildWaveManifest` | `missionNamespace` | T4 cooldown tracker, persists across waves |
| `EJ_wavesSinceGoliath` | `fn_initWBKRegistry` / `fn_buildWaveManifest` | `missionNamespace` | T5 cooldown tracker, persists across waves |
| `EJ_MAX_ACTIVE_ZOMBIES` | `fn_initWBKRegistry` | Server global | Hard cap: 100 active units (RTX 5090 / 9800X3D) |
| `EJ_MAX_ACTIVE_T3_PLUS` | `fn_initWBKRegistry` | Server global | Combined T3+T4+T5 cap: 6 |
| `EJ_SPAWN_BATCH_SIZE` | `fn_initWBKRegistry` | Server global | 4 units per batch |
| `EJ_SPAWN_BATCH_DELAY` | `fn_initWBKRegistry` | Server global | 0.2s between batches |
| `EJ_SPAWN_BOSS_DELAY` | `fn_initWBKRegistry` | Server global | 2.0s extra delay after T4/T5 |
| `EJ_BUDGET_BASE` | `fn_initWBKRegistry` | Server global | 8 (min wave budget) |
| `EJ_BUDGET_WAVE_SCALE` | `fn_initWBKRegistry` | Server global | 4 (budget per wave) |
| `EJ_BUDGET_PLAYER_SCALE` | `fn_initWBKRegistry` | Server global | 6 (budget per player) |
| `EJ_spawnQueue` | `fn_initWBKRegistry` / `fn_spawnWBKWave` | Server global | Overflow drip-feed queue |
| `EJ_dripFeedHandler` | `fn_initWBKRegistry` / `fn_spawnWBKWave` | Server global | CBA PFH handle for drip-feed (-1 = inactive) |
| `EJ_wbkSpawnComplete` | `fn_spawnWBKWave` | Server global | Completion gate for createWave.sqf waitUntil |

### Architecture Notes — Phase 2

1. **Top-Down Hierarchy Spend (Spec §2.4):** Budget is allocated T5→T4→T3 first (probability gates: 40%, 60%, 80%), then T2 (90% gate per unit), then all remaining budget drains into T1 horde filler. This ensures high-value units spawn when eligible, not drowned by cheap units filling the cap.

2. **Cooldown Persistence (Spec §2.5):** `EJ_wavesSinceSmasher` and `EJ_wavesSinceGoliath` are stored in `missionNamespace` (not bare globals) to survive scope changes. Incremented by `fn_buildWaveManifest` each wave; reset to 0 when the tier spawns.

3. **Spawn Threading (Spec §4.2):** The spawn loop in `fn_spawnWBKWave` runs inside a `spawn` block to allow `sleep EJ_SPAWN_BATCH_DELAY` without blocking the unscheduled `createWave.sqf` caller. The `waitUntil { EJ_wbkSpawnComplete }` gate in `createWave.sqf` ensures `waveSpawned = true` only fires after all immediate spawning completes.

4. **Drip-Feed Overflow (Spec §4.3):** Units exceeding `EJ_MAX_ACTIVE_ZOMBIES` are pushed to `EJ_spawnQueue`. A CBA PFH polls every `EJ_SPAWN_BATCH_DELAY` seconds and spawns batches as the live count drops below the cap. The handler self-removes when the queue is empty.

### Hotfix 2.1 — Manifest Builder Variety Fix (2026-04-10)

**Symptoms:** Wave 41 test produced 133 T1, 1 T2, 1 T5 Goliath, zero T3/T4. No Screamers, Leapers, Boomers, or Smashers.

**Root Causes Identified:**

1. **`continue` in `forEach` `then` block (SQF compat):** Lines used `if (cond) then { continue };` inside `forEach`. The `continue` keyword (added SQF 2.14) inside nested `then {}` blocks has fragile cross-version behaviour. If it fails silently, execution falls through with invalid state, potentially terminating the entire `forEach` and killing T4/T3 processing. **Fix:** Replaced with nested `if-then-else` guards — zero reliance on `continue`.

2. **RNG gate on first unit of each tier (design flaw):** The `while` condition included `random 1 < _rollChance` on every iteration including the first. T4 had a 40% chance of zero Smashers per wave; T3 had 20% chance of zero Elites; T2 had 10% chance per iteration. **Fix:** First unit of each eligible tier is now GUARANTEED (no RNG gate). Probability gate applies only to additional units beyond the guaranteed first. T2 also receives the same treatment.

3. **Goliath bone/skeleton errors (WBK mod asset — NOT adapter bug):** `Bad bone name`, `Bone X doesn't exist in skeleton WBK_Goliaph_Skeleton`, and `Invalid memory point 'Spine3'` errors are inherent to the WBK_Zombies_Goliath mod asset on first load. The Goliath uses a custom skeleton that doesn't match standard Arma 3 humanoid bones. These are cosmetic/first-load warnings — the Goliath still spawned and initialized correctly (`maxHP=15000`). No adapter fix possible.

**Changes:**

| File | Change |
|---|---|
| `hostiles/wbk/fn_buildWaveManifest.sqf` | Removed `continue` statements; restructured Pass 1 with nested if-then guards; added guaranteed-first-unit logic for T5/T4/T3/T2; added per-tier diagnostic logging; improved final summary format |

**Expected Wave 41 / 4 Players after fix (budget=196):**
- T5: 1 Goliath (guaranteed, -60) = 136 remaining
- T4: 1 Smasher (guaranteed) + 0-1 extra (60% gate) = ~1-2 Smashers (-25 to -50) = ~86-111 remaining
- T3: 1 Elite (guaranteed) + 0-3 extra (80% gate) = ~1-3 Elites (-8 to -24) = ~62-103 remaining
- T2: 1 Runner (guaranteed) + ~8-12 extra (90% gate) = ~9-13 Runners (-27 to -39) = ~23-76 remaining
- T1: remainder as horde filler

### Hotfix 2.2 — AI Targeting & Movement Fix (2026-04-10)

**Symptoms:** Smasher/Goliath spawned but stood idle. Regular zombies attacked the Smasher instead of players.

**Root Causes Identified:**

1. **Smasher/Goliath idle (findNearestEnemy returns objNull):** All WBK AI scripts call `disableAI "TARGET"` which prevents standard AI target acquisition. `findNearestEnemy` only returns enemies the unit KNOWS about. Regular zombies work because their initial `doMove` gets them close enough to players that proximity detection eventually seeds knowledge. Smasher/Goliath pathfinding PFH loops (0.01s/0.5s) call `findNearestEnemy` → get `objNull` → `exitWith {}` on every tick. They have NO fallback movement case (unlike Walker's 10s `_loopPathfindDoMove` which has multiple `switch` cases). Additionally, the Smasher AI script calls `disableAI "MOVE"` / `doStop _unit` in its high-frequency PFH, cancelling the initial `doMove` before the unit can close distance.

2. **Zombies attacking Smasher (separate groups):** Each zombie was created in its own individual EAST group. `findNearestEnemy` operates on the unit's knowledge database, and with `disableAI "TARGET"` + solo groups + no knowledge sharing, edge cases in the Arma knowledge system caused units in different same-side groups to register each other as potential targets. Placing all zombies in a shared group makes them groupmates — `findNearestEnemy` never returns a groupmate.

**Changes:**

| File | Change |
|---|---|
| `hostiles/wbk/fn_spawnWBKUnit.sqf` | Added optional `_group` param (4th parameter, default `grpNull`); uses provided group or creates new one. Added `reveal [_player, 4]` for all `playableUnits` — seeds `findNearestEnemy` with max knowledge of all players immediately at spawn. |
| `hostiles/wbk/fn_spawnWBKWave.sqf` | Creates one shared EAST group per wave (`_waveGroup`), stored as `EJ_currentWaveGroup`. Passes group to all `EJ_fnc_spawnWBKUnit` calls. Drip-feed PFH uses `EJ_currentWaveGroup` with null-check fallback (creates new group if wave group was auto-deleted). |

**New Global Variables:**

| Variable | Set By | Purpose |
|---|---|---|
| `EJ_currentWaveGroup` | `fn_spawnWBKWave` | Shared EAST group for current wave; used by drip-feed PFH |

### Hotfix 2.3 — Side Config Mismatch: Smasher/Goliath Classnames (2026-04-10)

**Symptoms:** Smasher and Goliath fight each other. Regular zombies attack Smasher/Goliath. After Goliath kills Smasher, it correctly targets the player (only WEST target remaining was the player... or it fell back to proximity).

**Root Cause — Wrong classname suffix (wrong side):**

The WBK mod uses a numbered suffix system to provide the same unit on different sides:

| Suffix | Side | Config Value | Example |
|---|---|---|---|
| `_1` | WEST or INDEP (varies) | `side=1` or `side=2` | `WBK_Goliaph_1` (WEST) |
| `_2` | WEST or INDEP (varies) | `side=1` or `side=2` | `WBK_SpecialZombie_Smasher_2` (WEST) |
| `_3` | EAST (OPFOR) | `side=0` | `WBK_Goliaph_3` (EAST), `WBK_SpecialZombie_Smasher_3` (EAST) |

The registry was using `_2` Smashers (`side=1` WEST) and `_1` Goliath (`side=1` WEST). Regular zombies inherit from `O_Soldier_base_F` (`side=0` EAST). When `createUnit` places a WEST-config unit into an EAST group, Arma overrides the group assignment based on the unit's config side. Result: Smasher/Goliath end up on WEST, regular zombies on EAST → `findNearestEnemy` returns cross-side units as enemies.

**Fix:** Switched all T4/T5 registry entries to `_3` suffix classnames (EAST, `side=0`), matching regular zombies.

**Changes:**

| File | Change |
|---|---|
| `hostiles/wbk/fn_initWBKRegistry.sqf` | `WBK_SpecialZombie_Smasher_2` → `_3`, `Acid_2` → `Acid_3`, `Hellbeast_2` → `Hellbeast_3`, `WBK_Goliaph_1` → `WBK_Goliaph_3` |

---

## Phase 3: Zombies-Only Conversion — COMPLETE

**Date:** 2026-04-10  
**Status:** Implemented, pending playtest

### Scope

Converted the mission to a zombies-and-creatures-only experience. Removed three vanilla Bulwarks features that don't fit the zombie theme:
- **Vehicles/armour spawning** — stripped entirely from `createWave.sqf`
- **specMortarWave** — removed from special wave pool (vanilla mortar crews)
- **swticharooWave** — removed from special wave pool (teleport mechanic)
- **defectorWave** — removed from special wave pool (NATO soldiers)

Replaced **suicideWave** with a new **Bloater Rush** special wave (60% Bloaters + 40% T1 horde).

### Files Modified

| File | Change |
|---|---|
| `hostiles/createWave.sqf` | Removed all vehicle/armour spawning: probability tables, `spawnVehicle.sqf`/`spawnCar.sqf` calls, `wavesSinceArmour`/`wavesSinceCar` escalation counters (lines 9–78 of original). Only WBK zombie adapter call remains. |
| `bulwark/functions/fn_startWave.sqf` | **Wave 5–9 pool:** Reduced from 3 to 2 options (specCivs, fogWave). **Wave 10+ pool:** Reduced from 8 to 5 options (specCivs, fogWave, bloaterRush, nightWave, demineWave). Removed mortar/switcharoo/defector selection cases, flag blocks, and notification blocks. Replaced suicideWave flag block with `EJ_wbk_bloaterRush` flag + `suicideAudio.sqf`. Removed the switcharoo wipe-detection `while` loop. |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | Added Bloater Rush override at top of function: when `EJ_wbk_bloaterRush` is true, builds manifest as 60% Bloaters (`Zombie_Special_OPFOR_Boomer`, pointMulti=2.0) + 40% T1 horde from the budget. Resets flag after use. Increments Smasher/Goliath cooldown trackers. |
| `hostiles/moveHosToPlayer.sqf` | Added `WBK_AI_ISZombie` guard in both `forEach allUnits` loops. WBK zombies skip vanilla stance/speed/doMove commands. Removed vehicle positioning logic and `suicideWave` direct-move logic (no longer applicable). |
| `missionLoop.sqf` | Removed `wavesSinceArmour` and `wavesSinceCar` counter initialisation (no longer used). |

### New Global Variables

| Variable | Set By | Purpose |
|---|---|---|
| `EJ_wbk_bloaterRush` | `fn_startWave.sqf` | Flag for `fn_buildWaveManifest` to override with Bloater Rush composition |

### Special Wave Pool (Post-Conversion)

| Wave Range | Pool Size | Options |
|---|---|---|
| 5–9 | 2 | specCivs, fogWave |
| 10+ | 5 | specCivs, fogWave, bloaterRush, nightWave, demineWave |

### Bloater Rush Design

When `bloaterRush` is selected, the manifest builder:
1. Allocates 60% of the total budget to Bloaters (cost 8 each)
2. Returns unused bloater budget remainder to the T1 pool
3. Fills the remaining 40%+ budget with random T1 horde units (cost 1 each)
4. Skips normal tier allocation entirely (no T2–T5 units)
5. Keeps `suicideAudio.sqf` for atmospheric alarm audio

### Hotfix 3.1 — WBK_AI_ISZombie Type Mismatch (2026-04-10)

**Symptom:** RPT error at wave 10 in `moveHosToPlayer.sqf` line 17:
```
Error if: Type Number, expected Bool
```

**Root Cause:** The WBK mod's AI scripts set `WBK_AI_ISZombie` to `1` (a Number), not `true` (a Bool). SQF's `if` statement requires a Bool operand. `_x getVariable ["WBK_AI_ISZombie", false]` returns `1` when the variable exists → `if (1)` → type error. This crashes the `moveHosToPlayer.sqf` loop, halting all AI movement redirection for the remainder of the wave.

**Impact:** After the first WBK zombie spawns, the `moveHosToPlayer.sqf` while-loop crashes. No EAST units receive `doMove` commands or behaviour adjustments for the rest of the wave. WBK zombies are unaffected (they use their own PFH for movement), but vanilla units (if any existed) would stand idle.

**Fix:** Replaced `_x getVariable ["WBK_AI_ISZombie", false]` with `!isNil {_x getVariable "WBK_AI_ISZombie"}` in both guard locations. The `!isNil` check is type-safe — it returns `true` if the variable exists regardless of whether it holds `1`, `true`, or any other value. Regular Arma units never have this variable set, so `isNil` returns `true` → they continue through the vanilla behaviour path.

| File | Change |
|---|---|
| `hostiles/moveHosToPlayer.sqf` | Both `WBK_AI_ISZombie` guards changed from `getVariable ["WBK_AI_ISZombie", false]` to `!isNil {_x getVariable "WBK_AI_ISZombie"}` |

### Hotfix 3.2 — WBK Zombies Falsely Deleted by Stuck-Check (2026-04-10)

**Symptom:** Wave 1 spawns 18 zombies. After ~30–60 seconds, most begin silently disappearing. After a few minutes only 3 remain alive. No RPT errors logged.

**Root Cause — `clearStuck.sqf` false positive on slow WBK zombies:**

`clearStuck.sqf` is a vanilla Bulwarks garbage-collection loop designed for standard Arma AI using `doMove`. Every 30 seconds it checks whether each EAST unit has moved at least 15m closer to its nearest player. If it hasn't, AND the player's `knowsAbout` of the unit is below 3.5, AND the unit is more than 35m from any player and 20m from the bulwark box — it calls `deleteVehicle`.

WBK Crawlers and Shamblers are very slow zombie types. They spawn at `BULWARK_RADIUS` distance (potentially hundreds of meters out). In 30 seconds a Crawler cannot cover 15m. The player can't see them at that range, so `knowsAbout` stays below 3.5. They meet every deletion criterion and get silently removed — no error, no log, no killed event.

This only affected zombies that hadn't yet reached the player. Zombies that spawned close or were Walkers/Runners fast enough to close 15m in 30 seconds survived the check.

**Fix:** Added a `WBK_AI_ISZombie` guard in the snapshot-collection loop of `clearStuck.sqf`. WBK zombies are now excluded from the stuck-check array entirely. They are never evaluated for deletion. This is safe because:

1. WBK zombies use their own CBA PFH-driven pathfinding that continuously re-targets the nearest player — they don't rely on vanilla `doMove` and cannot get "stuck" in the same way vanilla AI can.
2. WBK zombies that are genuinely unreachable (e.g. spawned inside terrain) will still be cleaned up by the wave-end cleanup in `fn_endWave.sqf` when `EAST countSide allUnits == 0` or the wave timer expires.
3. The `!isNil` type-safe check is consistent with the pattern established in Hotfix 3.1.

| File | Change |
|---|---|
| `hostiles/clearStuck.sqf` | Added `WBK_AI_ISZombie` guard in the snapshot loop (line 14–17): WBK zombies skip the `AIStuckCheckArray pushBack` and are never evaluated for stuck-deletion. Uses `!isNil {_x getVariable "WBK_AI_ISZombie"}` for type safety. |

### Hotfix 3.3 — Remove Crawler & Walker from T1 Pool (2026-04-10)

**Symptom:** Wave 1 zombies spawn at `BULWARK_RADIUS` distance. Crawlers and Walkers take several minutes to reach the centre, creating long boring stretches where the player waits for invisible slow zombies to arrive.

**Analysis — WBK Zombie Movement Speeds:**

All WBK zombie movement is driven by custom animations (which lock root motion speed) and CBA per-frame-handler pathfinding loops. The key differentiators are the animation moveset and the `_loopPathfindDoMove` PFH interval:

| Classname | AI Script | Animation | DoMove Interval | Est. Speed |
|---|---|---|---|---|
| `Zombie_O_Crawler_CSAT` | `WBK_AI_Walker` (`_isCrawler=true`) | `WBK_Crawler_Idle` (belly-crawl) | 10s | ~0.5–1.5 m/s |
| `Zombie_O_Walker_CSAT` | `WBK_AI_Walker` (`_isCrawler=false`) | `WBK_Walker_Idle_1/2/3` (slow shuffle) | 10s | ~1.5–2.5 m/s |
| `Zombie_O_Shambler_CSAT` | `WBK_AI_Middle` | `WBK_Middle_Idle/1` (moderate shamble) | 4–7s (random) | ~3–4 m/s |
| `Zombie_O_RunnerCalm_CSAT` | `WBK_AI_Runner` (`_isCalm=true`) | `WBK_Runner_Calm_Idle` | 4–7s (random) | ~5–6 m/s |
| `Zombie_O_RunnerAngry_CSAT` | `WBK_AI_Runner` (`_isCalm=false`) | `WBK_Runner_Angry_Idle` | 4–7s (random) | ~6–8 m/s |
| `Zombie_O_Shooter_CSAT` | `WBK_ShooterZombie` | `WBK_ShooterZombie_*` | Event-driven | ~3–4 m/s |

Key naming caveat: despite the name "Shambler," that classname uses `WBK_AI_Middle.sqf` (the middle speed tier) — it's significantly faster than the Walker. Confusingly, "Crawler" and "Walker" both use `WBK_AI_Walker.sqf` (the slowest tier), with Crawler getting the belly-crawl variant.

At a typical `BULWARK_RADIUS` of 200m:
- **Crawler:** ~2–7 min to arrive (belly-crawl + 10s pathfind updates). Unacceptable.
- **Walker:** ~1.5–3 min (slow shuffle + 10s pathfind). Too slow for wave pacing.
- **Shambler:** ~50–70s (moderate speed + 4–7s pathfind). Appropriate "slow horde" feel without dead time.

**Fix:** Removed `Zombie_O_Crawler_CSAT` and `Zombie_O_Walker_CSAT` from the T1 registry. `Zombie_O_Shambler_CSAT` is now the sole T1 horde filler. This affects:
- Normal wave T1 allocation (all T1 budget drains into Shamblers)
- Bloater Rush T1 backfill (40% of budget still draws from registry T1 pool)

The variety lost from removing two T1 classes is offset by the T2–T5 tiers which provide Runners, Shooters, Elites, Smashers, and Goliath in later waves.

| File | Change |
|---|---|
| `hostiles/wbk/fn_initWBKRegistry.sqf` | Removed `Zombie_O_Crawler_CSAT` and `Zombie_O_Walker_CSAT` from T1 entries. `Zombie_O_Shambler_CSAT` is now the only T1 class. |

### Hotfix 3.4 — Periodic Reveal: Fix Zombie Knowledge Decay (2026-04-10)

**Symptom:** Zombies initially rush toward the player but lose interest after ~60–120 seconds. If the player hides in a building and stops shooting, zombies wander aimlessly outside and never enter. The player can hide indefinitely without being found.

**Root Cause — Arma 3 knowledge decay + no refresh mechanism:**

WBK zombies rely entirely on `findNearestEnemy` for all pathfinding decisions (3 concurrent PFHs). This engine command only returns enemies the unit KNOWS about. Knowledge is seeded once at spawn via `reveal [player, 4]` and refreshed only when players shoot nearby (Suppressed/FiredNear EHs call `reveal [instigator, 4]`).

All WBK AI scripts call `disableAI "TARGET"`, preventing autonomous target acquisition. The Arma 3 engine naturally decays knowledge over ~60–120 seconds when a unit cannot see or hear the target. Once knowledge decays below the engine threshold, `findNearestEnemy` returns `objNull`, and all three PFHs hit their null-enemy code path — the zombie stops pursuing, clears `WBK_IsUnitLocked`, and plays idle sounds indefinitely.

Meanwhile, vanilla Bulwarks AI never has this problem because `moveHosToPlayer.sqf` force-issues `doMove` toward the nearest player every 15 seconds regardless of knowledge state. But with the WBK integration, this loop explicitly skips WBK zombies (via the `WBK_AI_ISZombie` guard) to avoid conflicting with the WBK PFH-driven movement system.

The gap: WBK zombies are excluded from vanilla movement orders, and the WBK mod's own pathfinding has no mechanism to refresh stale knowledge. There was no periodic `reveal` to bridge this gap.

**Fix:** Added a periodic `reveal [player, 4]` call for all WBK zombies in the Pass 1 (behaviour) loop of `moveHosToPlayer.sqf`. Every 15 seconds, each WBK zombie is revealed about all alive human players at maximum knowledge level (4). This keeps `findNearestEnemy` permanently returning valid targets, allowing the WBK PFH pathfinding to work as designed — direct-drive when LOS is clear, navmesh fallback (through doorways, around walls) when LOS is blocked.

No `doMove` commands are issued to WBK zombies. The reveal only refreshes the knowledge database; the WBK mod's own PFH system handles all movement decisions and animation.

**Performance impact:** ~400 `reveal` calls per 15s cycle (100 zombies × 4 players). `reveal` is a lightweight engine command with negligible overhead.

| File | Change |
|---|---|
| `hostiles/moveHosToPlayer.sqf` | WBK branch in Pass 1: replaced no-op with `private _zombie = _x; { _zombie reveal [_x, 4]; } forEach _allHPs;` — refreshes knowledge of all alive human players every 15s cycle. Pass 2 (doMove) unchanged — WBK zombies still skip vanilla movement orders. |

### Hotfix 3.5 — WBK Zombie Idle at Spawn: Range-Gated PFH Failsafe (2026-04-11)

**Symptom:** A RunnerCalm zombie spawned in wave 2 stood idle the entire wave. It never moved toward players despite being alive, receiving reveals, and having its deferred init complete successfully.

**Root Cause — Three compounding factors leave far-away zombies without any movement orders:**

1. **WBK PFH range gate (`WBK_Zombies_MoveDistanceLimit = 150m`):** All WBK AI scripts (Runner, Walker, Middle, Shooter) check `_unit distance _nearEnemy >= WBK_Zombies_MoveDistanceLimit` in their pathfinding PFH. When the zombie spawns beyond 150m from the nearest player, the PFH skips all movement logic (no `doMove`, no velocity manipulation). The zombie's spawn range is `BULWARK_RADIUS + 30` to `BULWARK_RADIUS + 150` meters from bulwark center, easily exceeding 150m from any player.

2. **WBK Runner AI cancels initial doMove:** The Runner AI init script (`WBK_AI_Runner.sqf`) executes `_this doMove (getPosATLVisual _this)` 0.5 seconds after spawn — ordering the zombie to its OWN position, effectively cancelling the `doMove` issued by `fn_spawnWBKUnit.sqf`. Shooter zombies (`WBK_ShooterZombie.sqf`) never issue any `doMove` at all — they are designed as stationary units that setBehaviour COMBAT and fire when enemies are known.

3. **`moveHosToPlayer.sqf` no-op for WBK zombies:** The movement loop (Pass 2) explicitly skipped all WBK zombies with a no-op branch, deferring to the WBK PFH. But the PFH was range-gated (factor 1), and the initial doMove was cancelled (factor 2). No system ever issued a replacement movement order.

**Result:** Zombie spawns >150m from players → initial `doMove` cancelled by WBK AI init → PFH skips movement (range gate) → `moveHosToPlayer.sqf` skips movement (no-op) → zombie stands idle until killed or wave ends.

**Fix:** Replaced the no-op WBK branch in `moveHosToPlayer.sqf` Pass 2 with a distance-gated `doMove` failsafe. When a WBK zombie is >100m from the nearest player, `moveHosToPlayer.sqf` now issues `doMove` toward that player every 15 seconds to pull the zombie into PFH coverage range.

The 100m threshold ensures:
- **Far range (>100m):** Our `doMove` provides the only movement. The WBK PFH's range gate skips movement anyway, so there is no conflict.
- **Close range (<100m, within PFH coverage):** No `doMove` is issued. The WBK PFH handles all movement with velocity manipulation and custom animations. If the PFH calls `disableAI "MOVE"` / `doStop` (as it does for close-range direct-drive pathfinding), there is no stale `doMove` to conflict with.

**Why not always issue `doMove`?** The Runner PFH's close-range pathfinding uses `disableAI "MOVE"` + `setVelocityTransformation` for precise animation-synchronized movement. Issuing `doMove` at close range would be immediately cancelled by the PFH's `doStop`/`disableAI "MOVE"` on the next 0.1s tick, but it could cause a brief visible stutter if the engine tries to process the movement order between PFH ticks. The 100m threshold avoids this edge case.

| File | Change |
|---|---|
| `hostiles/moveHosToPlayer.sqf` | Pass 2: WBK zombie branch changed from no-op to distance-gated `doMove`. Nearest-player distance calculation (shared with vanilla branch) moved above the WBK/vanilla fork. WBK zombies >100m from nearest player receive `doMove` toward that player each 15s cycle. |

### Hotfix 3.6 — Merge T1/T2, Tighter Spawn Ring, Always doMove (2026-04-11)

**Symptoms:**
1. Wave 2 only spawned 3 zombies (1 Shambler + 2 Runners). Far too few for engaging gameplay.
2. All 3 wave 2 zombies stood idle outside the zone and never moved toward the player. Wave 1 worked normally.

**Root Cause 1 — T2 cost starves unit count:**

Budget for wave 2 (solo) = `0 + (2-1)*4 + 1*3 = 7`. T2 Runners cost 3 each. Two Runners consumed 6 budget, leaving only 1 for a Shambler = 3 total units. The separate T2 tier at cost 3 produces far too few units in early waves where budget is tight.

Shamblers (T1), Runners (T2), and Shooters (T2) are all "regular" zombie types that should appear in large mixed groups. Having them at different price points creates artificial scarcity.

**Root Cause 2 — Spawn ring too wide + doMove failsafe too conservative:**

The spawn ring was `BULWARK_RADIUS + 30` to `BULWARK_RADIUS + 150` from center. With typical `BULWARK_RADIUS` values (100–200m), the outer ring reaches 250–350m from center — well beyond the WBK PFH's 150m `MoveDistanceLimit`. The Hotfix 3.5 doMove failsafe only fired when `gotoPlayerDistance > 100m`, meaning zombies between 0–100m received no doMove. Additionally, the 15-second moveHosToPlayer cycle meant a fresh spawn waited up to 15s for its first failsafe doMove, while the WBK AI init cancels the adapter's initial doMove at 0.5s via `_this doMove (getPosATLVisual _this)` (self-position order).

**Fix — Three changes:**

1. **Merge T1/T2:** All regular zombies (Shambler, RunnerCalm, RunnerAngry, Shooter) are now tier 1 at cost 1. This maximizes unit count per budget. Variety comes from minWave gating: wave 1 = shamblers only, wave 2 adds calm runners, wave 3 adds shooters, wave 4 adds angry runners. pointMulti preserved for scoring (shamblers 0.5×, runners/shooters 1.0×).

2. **Tighten spawn ring:** `BULWARK_RADIUS + 150` reduced to `BULWARK_RADIUS + 60` in both the main spawn loop and the drip-feed PFH. With `BULWARK_RADIUS = 100`, this gives a 130–160m ring. Players near center will be ~130–160m away, within or near the PFH's 150m range.

3. **Always issue doMove:** Removed the `gotoPlayerDistance > 100` condition in `moveHosToPlayer.sqf`. WBK zombies now receive `doMove` toward the nearest player every 15 seconds unconditionally. At close range (<150m), the WBK PFH overrides within 0.1s via `disableAI "MOVE"` + `setVelocityTransformation` — no visible stutter. At far range, the doMove is the only movement source.

**Budget comparison (wave 2, solo, budget=7):**

| Before | After |
|---|---|
| 1 T1 Shambler (cost 1) + 2 T2 Runners (cost 6) = 3 units | 7 T1 mixed (cost 7) = 7 units |

**Budget comparison (wave 10, solo, budget=39):**

| Before | After |
|---|---|
| ~10 T2 Runners (cost 30) + 1 T3 Elite (cost 8) + 1 T1 (cost 1) = ~12 units | 1 T3 Elite (cost 8) + 31 T1 mixed (cost 31) = ~32 units |

| File | Change |
|---|---|
| `hostiles/wbk/fn_initWBKRegistry.sqf` | RunnerCalm, RunnerAngry, Shooter moved from tier 2 (cost 3) to tier 1 (cost 1). All regular zombies now in a single T1 pool. |
| `hostiles/wbk/fn_spawnWBKWave.sqf` | Spawn ring outer radius reduced from `BULWARK_RADIUS + 150` to `BULWARK_RADIUS + 60` (both main loop and drip-feed PFH). Sort comments updated for merged tiers. |
| `hostiles/moveHosToPlayer.sqf` | Removed `gotoPlayerDistance > 100` condition. WBK zombies now always receive `doMove` toward nearest player every 15s cycle. |

### Hotfix 3.7 — doMove Conflicts with WBK PFH Direct-Drive (2026-04-11)

**Symptom:** Wave 3 (11 units: 2 Shamblers, 6 RunnerCalm, 3 Shooters). Most zombies stood idle, periodically lurching forward for ~1 second then stopping. Only 1 zombie consistently ran. Waves 1 and 2 worked correctly.

**Root Cause — Unconditional `doMove` conflicts with the WBK 0.1s PFH within 150m:**

The Hotfix 3.6 fix (always issue `doMove`) creates a direct conflict with the WBK AI's per-frame-handler pathfinding system. The conflict chain:

1. `moveHosToPlayer.sqf` issues `doMove` → zombie starts walking using a **vanilla Arma animation** (e.g. standard infantry run)
2. Within 0.1s, the WBK `_loopPathfind` PFH fires. It checks `animationState _unit` against the WBK animation whitelist (`wbk_runner_calm_idle`, `wbk_runner_angry_run`, etc.)
3. The vanilla animation is NOT in the list → PFH enters **case 2**: calls `disableAI "MOVE"` → the engine immediately cancels the pending `doMove`
4. Zombie stops dead. The PFH sets `WBK_IsUnitLocked = 0` and rotates the zombie to face the enemy
5. On the next 0.1s tick, the PFH should enter **case 3** (direct-drive) once `enableAI "ANIM"` restores a WBK animation — but by then the zombie has already stopped
6. After 15s, our next `doMove` fires → brief burst → cancelled again in 0.1s

Result: zombie gets a ~0.1s micro-burst of movement every 15 seconds, appearing to "lurch forward then sit idle."

**Why waves 1–2 worked:** Spawns at ~200m from the player are **beyond** `WBK_Zombies_MoveDistanceLimit` (150m). At that range, the PFH's **case 1** fires (`_unit distance _nearEnemy >= WBK_Zombies_MoveDistanceLimit`), which only clears `WBK_IsUnitLocked` and does **not** call `disableAI "MOVE"`. Our `doMove` survives the PFH tick and the zombie walks normally. Once wave 3 had more zombies closer to the player (some spawns within 150m, others already pulled in by our doMove from earlier), the PFH's case 2 started firing and cancelling movement.

**Key takeaway — the WBK PFH has two regimes:**

| Distance | PFH Behaviour | Our doMove compatibility |
|---|---|---|
| `>= MoveDistanceLimit` (150m) | Case 1: clears state, does NOT touch MOVE AI | Safe — doMove survives, is the only movement source |
| `< MoveDistanceLimit` (150m) | Case 2/3: `disableAI "MOVE"`, direct-drive via velocity transform + custom animations | Conflict — doMove cancelled within 0.1s |

**Fix:** Gate the `doMove` on `gotoPlayerDistance >= WBK_Zombies_MoveDistanceLimit`. Beyond that threshold: our `doMove` is the only movement source (PFH does nothing). Within that threshold: the PFH handles all movement via direct-drive. Reads the CBA setting variable `WBK_Zombies_MoveDistanceLimit` directly (default 150m if undefined) for automatic compatibility with user-configured values.

This precisely dovetails with the PFH's range gate: we hand off to the WBK system at the exact same distance where it activates.

| File | Change |
|---|---|
| `hostiles/moveHosToPlayer.sqf` | WBK zombie doMove gated on `gotoPlayerDistance >= WBK_Zombies_MoveDistanceLimit` (reads CBA setting, default 150m). Beyond threshold: issue doMove to pull zombie into PFH range. Within threshold: no doMove, PFH direct-drive handles movement. |

---

### Hotfix 2.4 — Civilian Zombie Appearance (2026-04-11)

**Request:** Zombies spawned in full CSAT military gear (helmet, vest, backpack) making them too armored-looking and visually monotonous. Player wanted civilian-dressed zombie variety.

**Root Cause:** The `_CSAT` classnames carry `WBK_ZombiesOriginalFactionClass="OPF_F"` in their config. WBK's `WBK_ZombiesRandomEquipment` (fired via `Extended_InitPost_EventHandlers`) picks a random soldier from that faction and applies their full loadout — resulting in helmets, vests, and NVGs on every zombie.

**Fix:** Switched T1 classnames from `_CSAT` to `_Civ` variants. These carry `WBK_ZombiesOriginalFactionClass="CIV_F"`, so `WBK_ZombiesRandomEquipment` dresses them in civilian clothes (shirts, pants, hats — no body armour). Also removed the Shooter zombie (`Zombie_O_Shooter_CSAT`) from the pool entirely. Angry runners now gate at wave 3 instead of wave 4.

**Classname Changes:**

| Old | New | Notes |
|---|---|---|
| `Zombie_O_Shambler_CSAT` | `Zombie_O_Shambler_Civ` | `CIV_F` faction loadout |
| `Zombie_O_RunnerCalm_CSAT` | `Zombie_O_RC_Civ` | `CIV_F` faction loadout |
| `Zombie_O_RunnerAngry_CSAT` | `Zombie_O_RA_Civ` | `CIV_F` faction loadout, minWave 4→3 |
| `Zombie_O_Shooter_CSAT` | *(removed)* | Gun-wielding zombie eliminated from pool |

All `_Civ` variants are EAST-side, inherit from the `_CSAT` parent class, and use identical AI scripts via `Extended_InitPost_EventHandlers`. No changes to `fn_spawnWBKUnit.sqf` or scoring required.

| File | Change |
|---|---|
| `hostiles/wbk/fn_initWBKRegistry.sqf` | T1 entries: 3 classnames switched to `_Civ`, Shooter removed, minWave adjusted, comments updated |

---

## Hotfix 7: WBK Zombie Revive System Bypass Fix

**Date:** 2026-04-13
**Status:** Built, pending in-game test

### Problem

WBK zombies instantly kill players instead of triggering the Bulwarks "downed" (INCAPACITATED) state that allows teammate revive or hold-space-to-respawn. Players report that regular zombie melee hits cause instant death, while bloater explosions correctly trigger the down state.

### Root Cause

Bulwarks' revive system depends on the `HandleDamage` event handler (installed in `initPlayerLocal.sqf` / `onPlayerRespawn.sqf`) to intercept lethal hits and route them through `bis_fnc_reviveEhHandleDamage`, which transitions the player to INCAPACITATED state.

WBK zombies bypass this in three ways:

1. **`WBK_CreateDamage` (external mod function):** Called via `remoteExec` on the victim's machine for regular zombie melee, Smasher melee, and bloater supplemental AoE. Uses `setDamage [val, false]` which **skips HandleDamage entirely** — the revive EH never fires.

2. **`WBK_ZombieAttackDamage` INCAPACITATED case (XEH_preInit.sqf line 441):** Explicitly checks `lifeState _x == "INCAPACITATED"` and calls `[_x, [1, false, _zombie]] remoteExec ["setDamage", 2]` — instantly killing any downed player near a zombie.

3. **Goliath `WBK_GoliaphProceedDamage` (XEH_preInit.sqf line 246):** Uses scalar `_enemy setDamage 1` on all MAN units. This triggers HandleDamage but with empty ammo and no external source, which the original Bulwarks EH blocks as "fall damage" — making Goliath melee deal zero damage to players.

The bloater explosion works because it creates an actual `APERSMine` that generates engine-level explosive damage with a proper ammo classname, passing through HandleDamage correctly.

### Fix

#### New file: `hostiles/wbk/fn_initPlayerReviveBridge.sqf`

Central adapter function called on each player's machine that:

1. **Overrides `WBK_CreateDamage`** — For non-players, delegates to original. For players: blocks damage if INCAPACITATED/being revived; on lethal hits, checks Medikit auto-revive then routes through `bis_fnc_reviveEhHandleDamage` via a flag variable; sub-lethal hits applied directly.

2. **Overrides `WBK_Goliath_SpecialAttackGroundShard`** — Thin wrapper that sets `EJ_wbk_pendingRevive` flag before the original function's `setDamage 1` for players, so HandleDamage can route it to the revive system.

3. **Installs revive-aware HandleDamage EH** — Replaces the original inline EH with one that:
   - Sets `IMS_IsUnitInvicibleScripted` when INCAPACITATED (protects from WBK's explicit INCAPACITATED kill in `WBK_ZombieAttackDamage`)
   - Detects `EJ_wbk_pendingRevive` flag and routes to `bis_fnc_reviveEhHandleDamage`
   - Fixed environmental check: only blocks empty-ammo damage when source is null/self (fall damage), not WBK-sourced damage
   - Allows execution animations (`WBK_Smasher_Execution`, `Corrupted_Attack_victim`) to pass through as instant kill
   - Preserves all existing gates: friendly fire, Medikit auto-revive, normal revive routing

#### Server-side overrides in `initServer.sqf`

- **`WBK_GoliaphProceedDamage`** — Replicated with change: player damage routed through `WBK_CreateDamage` (which is now revive-aware) via `remoteExec` on the victim's machine, instead of server-side `setDamage 1`.
- **`WBK_Goliph_RockThrowingAbility`** — Rock-throw projectile loop redirects player damage through `WBK_CreateDamage` instead of `setDamage 1`.

#### Revive cleanup in `fn_revivePlayer.sqf`

After the 15-second invincibility period, clears `IMS_IsUnitInvicibleScripted` so WBK damage detection resumes normally.

### Affected Zombie Types

| Type | Damage Path | Issue | Fix |
|---|---|---|---|
| Walker/Runner/Shambler/Middle/Melee | `WBK_CreateDamage` | Bypasses HandleDamage → instant kill | `WBK_CreateDamage` override |
| Tatzelwurm/Stunden | `WBK_CreateDamage` | Same | Same |
| Bloater melee | `WBK_ZombieAttackDamage` → `WBK_CreateDamage` | Bypasses HandleDamage (melee only) | `WBK_CreateDamage` override |
| Bloater explosion | `APERSMine` engine damage | **Works correctly** | None needed |
| Smasher melee | `WBK_Smasher_Damage_Humanoid` → `WBK_CreateDamage` | Bypasses HandleDamage | `WBK_CreateDamage` override |
| Smasher execution | `WBK_Smasher_ExecutionFnc` → `setDamage 1` | Instant kill | **Keep lethal** (execution animation) |
| Goliath melee | `WBK_GoliaphProceedDamage` → `setDamage 1` | Blocked by fall-damage check | Server override routes through `WBK_CreateDamage` |
| Goliath ground shards | `WBK_Goliath_SpecialAttackGroundShard` → `setDamage 1` | Same | Client-side wrapper with `EJ_wbk_allowLethalDamage` flag — **instant kill** (cinematic impale) |
| Goliath sync kills | `WBK_Goliaph_SyncAnim_1/_2` → `setDamage 1` | Instant kill | **Keep lethal** (execution animation) |
| Goliath rock throw | In-flight loop → `setDamage 1` | Same as Goliath melee | Server override routes through `WBK_CreateDamage` |
| Goliath bone spear | `WBK_fnc_ProjectileCreate_Zombies` | Guided missile (engine damage) | Likely works via HandleDamage already |
| Corrupted grab | `WBK_CorruptedAttack_success` → `setDamage 1` | Instant kill | **Keep lethal** (execution animation) |
| All types vs downed player | `WBK_ZombieAttackDamage` INCAPACITATED case | `setDamage [1, false]` kills downed players | `IMS_IsUnitInvicibleScripted` protection in HandleDamage |

### Files Modified

| File | Change |
|---|---|
| `hostiles/wbk/fn_initPlayerReviveBridge.sqf` | **NEW** — WBK_CreateDamage override + Goliath shard wrapper + revive-aware HandleDamage EH |
| `hostiles/wbk/Functions.hpp` | Added `class initPlayerReviveBridge {}` |
| `initPlayerLocal.sqf` | Replaced inline HandleDamage EH block (~25 lines) with `call EJ_fnc_initPlayerReviveBridge` |
| `onPlayerRespawn.sqf` | Replaced inline HandleDamage EH block (~25 lines) with `call EJ_fnc_initPlayerReviveBridge` |
| `bulwark/functions/fn_revivePlayer.sqf` | Added `IMS_IsUnitInvicibleScripted` cleanup after revive completes |
| `initServer.sqf` | Added `WBK_GoliaphProceedDamage` and `WBK_Goliph_RockThrowingAbility` overrides after WBK registry init |

### Global Variables

| Variable | Set By | Scope | Purpose |
|---|---|---|---|
| `EJ_WBK_CreateDamage_original` | `fn_initPlayerReviveBridge` | Client global | Saved reference to original WBK_CreateDamage |
| `EJ_WBK_GroundShard_original` | `fn_initPlayerReviveBridge` | Client global | Saved reference to original WBK_Goliath_SpecialAttackGroundShard |
| `EJ_wbk_pendingRevive` | `WBK_CreateDamage` override | Per-player (`setVariable`) | Flag: next HandleDamage call should route to `bis_fnc_reviveEhHandleDamage` |
| `EJ_wbk_allowLethalDamage` | `WBK_Goliath_SpecialAttackGroundShard` wrapper | Per-player (`setVariable`) | Flag: next HandleDamage call should allow instant kill (Goliath ground spike impale) |
| `IMS_IsUnitInvicibleScripted` | HandleDamage EH / `fn_revivePlayer` | Per-player (`setVariable`, broadcast) | WBK-standard invincibility flag; set when INCAPACITATED, cleared after revive |
| `EJ_WBK_GoliaphProceedDamage_original` | `initServer.sqf` | Server global | Saved reference to original WBK_GoliaphProceedDamage |
| `EJ_WBK_Goliph_RockThrow_original` | `initServer.sqf` | Server global | Saved reference to original WBK_Goliph_RockThrowingAbility |

---

## Hotfix 8: `goToPlayer` Undefined in `moveHosToPlayer.sqf`

**Date:** 2026-04-13
**Status:** Fixed

**Problem:** On-screen script error spam: `Error Undefined variable in expression: gotoplayer` at line 71 of `moveHosToPlayer.sqf`. Fires every 15 seconds for every EAST unit.

**Root Cause:** The `_aiTargets` array is built by filtering `allPlayers` to only alive, non-INCAPACITATED players. When all players are dead or downed, `_aiTargets` is empty, the `forEach` loop that sets `goToPlayer` never runs, and `goToPlayer` remains undefined. The code below unconditionally uses `getPos goToPlayer`, causing the error.

**Fix:** Reset `goToPlayer = objNull` at the top of each unit iteration. After the target-finding loop, guard with `if (isNull goToPlayer) then { continue }` to skip movement when no valid target exists.

| File | Change |
|---|---|
| `hostiles/moveHosToPlayer.sqf` | Initialise `goToPlayer = objNull` per unit; added null/nil guard before movement block |

---

## Hotfix 9: WBK Zombies Keep Attacking Downed Players

**Date:** 2026-04-13
**Status:** Fixed

**Problem:** After the revive system fix (Hotfix 7), zombies correctly down the player instead of killing them. However, zombies continue pathfinding to and attacking the downed player — crowding the body with melee animations. Players should be ignored while INCAPACITATED to give a chance for teammate revive or bleed-out.

**Root Cause:** WBK zombie AI uses `findNearestEnemy` (engine command) to select targets. Knowledge of INCAPACITATED players persists in the zombie's knowledge base because `moveHosToPlayer.sqf` reveals ALL players (including downed ones) every 15 seconds via `_zombie reveal [_x, 4]`.

**Fix (two-part):**

1. **Active forget:** In the HandleDamage EH (`fn_initPlayerReviveBridge.sqf`), when a player enters INCAPACITATED state, `remoteExec ["forgetTarget", _x]` is called on every WBK zombie. This runs on each zombie's owner machine (server/HC) and immediately clears the downed player from the zombie's knowledge base. The next `findNearestEnemy` call by the PFH will return a standing player instead.

2. **Prevent re-reveal:** In `moveHosToPlayer.sqf`, the 15-second reveal loop now skips INCAPACITATED players. Only standing, alive players are revealed to zombies, preventing downed players from re-entering the knowledge base.

| File | Change |
|---|---|
| `hostiles/wbk/fn_initPlayerReviveBridge.sqf` | INCAPACITATED gate: added `forgetTarget` broadcast via `remoteExec` to all WBK zombies |
| `hostiles/moveHosToPlayer.sqf` | Reveal loop: skip `lifeState == "INCAPACITATED"` players |

---

## Phase 3: Dedicated Server + Headless Client Compatibility — COMPLETE

**Date:** 2026-04-11
**Status:** Implemented, pending dedicated server test

### Root Causes

Two architectural issues prevented scoring from working on dedicated servers:

1. **Headless Client locality:** When AI is offloaded to a Headless Client (HC), zombie event handlers (`HitPart`, `Killed`) fire on the HC, **not** the server. Every scoring function had `if (!isServer) exitWith {}` which silently blocked all scoring on the HC.

2. **`Killed` EH instigator is unreliable:** WBK kills zombies via scripted `setDamage 1` which does not carry a killer context across the network boundary on dedicated servers. `_instigator` in the `Killed` EH is `objNull`, so `fn_killed` never awarded the kill bonus.

Both issues were invisible on LAN/hosted play because the host machine is simultaneously server + client — all event handlers fire locally where `isServer` is true.

### Fix: Relay Pattern + MPKilled

| Problem | Solution |
|---|---|
| HitPart fires on HC, not server | New relay wrapper (`fn_registerHitPartBridge`) pre-extracts data and `remoteExecCall`s to server |
| `Killed` EH fires on HC, not server | Replaced local `Killed` EH with `MPKilled` (fires on ALL machines); `isServer` gate in `fn_killed` processes once |
| `setDamage 1` has no instigator | `fn_wbkHitPartScore` now tracks `EJ_lastScorer` on each zombie; `fn_killed` falls back to this when `_instigator` is null |
| Projectile despawns during remoteExec transit | Relay pre-extracts `getShotParents` before relaying to server |
| Deferred HitPart EH timing on dedicated | Sleep increased 0.5s → 1.0s; registration uses locality-aware dispatch |

### Components Delivered

| # | File | Function Name | Purpose |
|---|---|---|---|
| 1 | `hostiles/wbk/fn_registerHitPartBridge.sqf` | `EJ_fnc_registerHitPartBridge` | **NEW** — HC-aware HitPart EH registration with server relay wrapper |

### Files Modified

| File | Change |
|---|---|
| `hostiles/wbk/fn_spawnWBKUnit.sqf` | Replaced `addEventHandler ["Killed", ...]` with `addMPEventHandler ["MPKilled", ...]`; replaced inline HitPart registration with locality-aware dispatch to `EJ_fnc_registerHitPartBridge`; increased deferred init sleep from 0.5s to 1.0s |
| `hostiles/wbk/fn_wbkHitPartScore.sqf` | Changed params from raw HitPart `_this` format to extracted `[_target, _shooter, _shotParents, _selection, _ammo]`; replaced `getShotParents _projectile` with pre-extracted `_shotParents`; added `EJ_lastScorer` tracking on zombie unit |
| `score/functions/fn_killed.sqf` | Added `EJ_lastScorer` fallback when `_instigator` is null or not a player (fixes WBK's `setDamage 1` kill attribution on dedicated) |
| `hostiles/wbk/Functions.hpp` | Added `class registerHitPartBridge {};` |
| `description.ext` | Added `class registerHitPartBridge{};` to `CfgRemoteExec` |

### Global Variables

#### Written (new/changed adapter variables)

| Variable | Set In | Purpose |
|---|---|---|
| `EJ_lastScorer` | `fn_spawnWBKUnit` (MPHit EH) | Last player to hit this zombie — fallback for `fn_killed` instigator |
| `EJ_lastHitPartTime` | `fn_wbkHitPartScore` | Dedup timestamp so MPHit doesn't double-score when HitPart bridge also fires |

---

## Hotfix 7: Zombie Movement Speed Tuning & Closer Spawns

**Date:** 2026-04-14  
**Status:** Implemented, pending in-game test

### Problem

1. **Regular runner zombies too fast:** Runners zig-zag at full animation speed, making them very difficult to shoot. No WBK mod setting controls animation-driven speed.
2. **Screamers and Boomers walk slowly:** WBK PFH sets `setBehaviour "CARELESS"` every tick. When the PFH can't lock a target (no LOS / `findNearestEnemy` returns null), units fall back to Arma's native movement engine which walks at CARELESS speed. The vanilla AI path in `moveHosToPlayer.sqf` uses `forceSpeed 6` to fix this, but the WBK path intentionally skips it.
3. **Zombies spawn too far from the zone:** 30–60m outside `BULWARK_RADIUS`, sometimes in adjacent compounds that take a long time to exit.

### Fix

| Change | Detail |
|---|---|
| Runner animation speed scaling | New global `EJ_RUNNER_ANIM_SPEED_COEF = 0.85` applied via `setAnimSpeedCoef` at spawn to T1 runner classes (`_RA_` / `_RC_` in classname). Slows all animation playback by 15%, directly reducing root-motion movement speed. |
| Spawn sprint boost with auto-decay | All zombies receive `forceSpeed 6` at spawn. After `EJ_SPAWN_SPRINT_DURATION` (20s), `forceSpeed -1` is called to reset to natural WBK PFH-driven movement. Gets units into the zone quickly, then lets WBK AI take over. |
| Tighter spawn annulus | `BIS_fnc_findSafePos` radius changed from `BULWARK_RADIUS + 30 / + 60` → `BULWARK_RADIUS + 15 / + 40` (both immediate spawn and drip-feed). Halves approach distance while keeping spawns well outside the zone boundary. |

### Why `forceSpeed` Is Safe Alongside WBK PFH

- **During PFH lock** (LOS to player): PFH calls `disableAI "MOVE"`, bypassing Arma's movement engine entirely. `forceSpeed` has no effect — no conflict with `setVelocityTransformation`.
- **During unlock** (no LOS / fallback): `enableAI "MOVE"` re-enables Arma's engine, and `forceSpeed 6` forces running instead of CARELESS walking.
- **After 20s reset**: `forceSpeed -1` returns the unit to natural speed. If the PFH is locked, this is irrelevant. If unlocked, the unit returns to WBK's intended CARELESS walking behaviour.
- No WBK AI script ever calls `forceSpeed`, so nothing resets or conflicts during the boost window.

### Files Modified

| File | Change |
|---|---|
| `hostiles/wbk/fn_initWBKRegistry.sqf` | Added `EJ_RUNNER_ANIM_SPEED_COEF = 0.85` and `EJ_SPAWN_SPRINT_DURATION = 20` in new "Movement Tuning" section |
| `hostiles/wbk/fn_spawnWBKUnit.sqf` | Added `setAnimSpeedCoef` for runner classes; added `forceSpeed 6` with timed `forceSpeed -1` reset after spawn |
| `hostiles/wbk/fn_spawnWBKWave.sqf` | Changed both `BIS_fnc_findSafePos` calls (immediate + drip-feed) from `+30/+60` → `+15/+40` |

### Global Variables

#### Written (new adapter variables)

| Variable | Set In | Default | Purpose |
|---|---|---|---|
| `EJ_RUNNER_ANIM_SPEED_COEF` | `fn_initWBKRegistry` | `0.85` | Animation speed multiplier for T1 runner classes (lower = slower) |
| `EJ_SPAWN_SPRINT_DURATION` | `fn_initWBKRegistry` | `20` | Seconds of forced sprint at spawn before natural WBK movement resumes |

### Tuning Guide

| If... | Adjust |
|---|---|
| Runners still too fast | Lower `EJ_RUNNER_ANIM_SPEED_COEF` (e.g. 0.80). Keep > 0.70 or attacks will feel sluggish. |
| Runners too slow | Raise `EJ_RUNNER_ANIM_SPEED_COEF` (e.g. 0.90). |
| Zombies still walk too long before reaching zone | Increase `EJ_SPAWN_SPRINT_DURATION` (e.g. 30). |
| Sprint boost feels too aggressive / unnatural | Decrease `EJ_SPAWN_SPRINT_DURATION` (e.g. 12). |
| Zombies spawn too close / pop in visibly | Increase `+15/+40` back toward `+25/+50` in `fn_spawnWBKWave.sqf`. |
| Zombies still get stuck in adjacent compounds | Decrease further toward `+10/+30`. |

---

## Hotfix 7a: Sprint Boost — Re-issue doMove After WBK Self-doMove

**Date:** 2026-04-14  
**Status:** Implemented, pending in-game test

### Problem

Screamers (and potentially all WBK zombies) still walked slowly despite the `forceSpeed 6` sprint boost from Hotfix 7. The Screamer walks from spawn instead of sprinting.

### Root Cause

All WBK AI init scripts (`Extended_InitPost_EventHandlers` → `execVM`) issue `doMove (getPosATLVisual _this)` — a "move to your own position" command — **0.5 seconds after spawn**. This cancels the initial `doMove` toward a player that `fn_spawnWBKUnit` sets. With no movement destination, `forceSpeed 6` has nothing to drive toward and the unit idles/walks in place under `CARELESS` behaviour.

Timeline before fix:
1. `0.0s` — `fn_spawnWBKUnit`: `doMove (player)` + `forceSpeed 6` → unit starts running
2. `0.5s` — WBK AI init: `doMove (self)` → **cancels movement**, unit stops
3. `0.1s+` — PFH ticks: if `findNearestEnemy` returns null → no replacement doMove issued
4. Unit walks aimlessly under CARELESS with no destination

### Fix

The sprint boost spawn block now sleeps 1.5s (past the WBK 0.5s self-doMove), then:
1. Refreshes `reveal [_x, 4]` for all players (ensures `findNearestEnemy` works)
2. Re-issues `doMove` toward a random alive player
3. The remaining sprint duration (`EJ_SPAWN_SPRINT_DURATION - 1.5`) then counts down before `forceSpeed -1` resets to natural movement

### Files Modified

| File | Change |
|---|---|
| `hostiles/wbk/fn_spawnWBKUnit.sqf` | Sprint boost spawn block now waits 1.5s, re-issues `reveal` + `doMove` toward a player, then sleeps remaining duration before `forceSpeed -1` reset |

---

## Hotfix 7b: Screamer Stuck in Calm Animation State

**Date:** 2026-04-14  
**Status:** Implemented, pending in-game test

### Problem

Screamers still walk slowly even after Hotfix 7a. Other zombies (Boomers, runners) run correctly. The Screamer has two observed states: a slow walk, and a rare mad sprint (only occurring after being hit).

### Root Cause

The WBK Screamer AI (`WBK_AI_Stunden.sqf`) initialises the unit in `WBK_Runner_Calm_Idle` animation (line 20: `switchMove "WBK_Runner_Calm_Idle"`) but **never transitions it to angry state**. Unlike the regular Runner AI (`WBK_AI_Runner.sqf`) which has an explicit calm→angry transition, the Screamer script has no such code.

The `_loopPathfind` PFH dynamically resolves the movement animation from the **current animation state's action class**:

```sqf
_currentMoveset = getText (configfile >> _skeletalType >> "States" >> animationState _unit >> "actions");
_currentAnimationToPlay = getText (configfile >> _skeletalType >> "Actions" >> _currentMoveset >> "FastF");
```

| State | Action Class | `FastF` Resolves To | Loop Duration |
|---|---|---|---|
| `WBK_Runner_Calm_Idle` | `WBK_Zombie_Sprinter_Calm` | `WBK_Runner_Calm_Walk` | **5.0 seconds** |
| `WBK_Runner_Angry_Idle` | `WBK_Zombie_Sprinter_Angry` | `WBK_Runner_Angry_Sprint` | **1.19 seconds** |

The calm walk is **4.2× slower** than the angry sprint. A config-defined transition animation (`WBK_Runner_Calm_To_Angry`) exists but is never played by script. The rare "mad sprint" occurs only when the Screamer takes a hit-stumble, whose recovery animation (`WBK_Runner_Fall_Back/Forward`) transitions into angry state via the animation graph.

### Fix

In the spawn sprint block (after the 1.5s sleep past WBK init), Screamer classnames now get `switchMove "WBK_Runner_Angry_Idle"`. This puts the Screamer into the angry animation graph so the PFH's `FastF` lookup resolves to `WBK_Runner_Angry_Sprint`. The scream ability is gesture-based (`playActionNow "WBK_Zombie_attack_Scream"`) and is unaffected by the base animation state.

### Files Modified

| File | Change |
|---|---|
| `hostiles/wbk/fn_spawnWBKUnit.sqf` | Sprint boost spawn block now does `switchMove "WBK_Runner_Angry_Idle"` for Screamer classnames (detected via `_className find "Screamer"`); refactored `_unit spawn` to `[_unit, _className] spawn` to pass classname into scheduled scope |

| Variable | Set By | Scope | Purpose |
|---|---|---|---|
| `EJ_lastScorer` | `fn_wbkHitPartScore` | Per-unit (`setVariable`, not public) | Last player who scored a hit — used as `fn_killed` instigator fallback |
| `EJ_hitPartRegistered` | `fn_registerHitPartBridge` | Per-unit (`setVariable`, not public) | Diagnostic flag confirming HitPart bridge was registered |

### Event Handler Architecture (Before/After)

**Before (Phase 1):**
```
HitPart EH (server-local only)
  → EJ_fnc_wbkHitPartScore (isServer guard)
    → killPoints_fnc_add

Killed EH (server-local only)
  → killPoints_fnc_killed (isServer guard)
    → killPoints_fnc_add
```

**After (Phase 3):**
```
HitPart EH (on unit owner: server OR HC)
  → relay wrapper (fn_registerHitPartBridge)
    → pre-extracts data (shotParents, selection, ammo)
    → if server: call EJ_fnc_wbkHitPartScore directly
    → if HC: remoteExecCall to server
      → EJ_fnc_wbkHitPartScore (isServer guard)
        → sets EJ_lastScorer on zombie
        → killPoints_fnc_add

MPKilled (fires on ALL machines)
  → killPoints_fnc_killed (isServer guard — only processes on server)
    → tries _instigator first
    → falls back to EJ_lastScorer if instigator is null
    → killPoints_fnc_add
```

### Compatibility Matrix

| Scenario | HitPart Scoring | Kill Scoring | Notes |
|---|---|---|---|
| Eden Editor (local) | ✓ Direct call | ✓ Direct instigator | Same machine, isServer=true |
| LAN Hosted | ✓ Direct call | ✓ Direct instigator | Host is server+client |
| Dedicated (no HC) | ✓ Direct call | ✓ EJ_lastScorer fallback | Units server-local, setDamage 1 instigator may be null |
| Dedicated + HC | ✓ Relay to server | ✓ MPKilled + EJ_lastScorer | Units HC-local, relay handles transit |

### Hotfix 3.6 — MPHit Primary Scoring Path (2026-04-12)

**Symptom:** Phase 3 HitPart bridge registers successfully (confirmed in server RPT), but shooting and killing zombies on dedicated server still awards zero score and shows no hitmarkers.

**Root Cause — WBK remoteExec timing race:**

WBK's AI scripts (e.g. `WBK_AI_Middle.sqf`) add the HitPart EH via:
```sqf
[_unit, {
    _this removeAllEventHandlers "HitPart";
    _this addEventHandler ["HitPart", { ... WBK damage logic ... }];
}] remoteExec ["spawn", 0, true];
```

This `remoteExec ["spawn", 0, true]` targets ALL machines including the server itself. Even though the server is both sender and recipient, the message goes through the **network layer** (not executed inline). On a dedicated server, this self-addressed network message can take significantly longer than on a hosted/LAN server to process.

Our deferred init waited for `WBK_AI_AttachedHandlers` (set in the synchronous body, AFTER the remoteExec was queued), then slept 1.0s before adding our bridge EH. On dedicated server, the WBK remoteExec can take **more than 1.0s** to process through the network queue. This means:

1. T+0.0s: WBK AI script queues `remoteExec ["spawn", 0, true]`
2. T+0.0s: WBK sets `WBK_AI_AttachedHandlers` (our waitUntil detects this)
3. T+1.0s: Our bridge EH registers (confirmed in RPT)
4. T+1.5s: WBK's remoteExec finally processes on server → `removeAllEventHandlers "HitPart"` **wipes our bridge**
5. T+1.5s: WBK adds its own HitPart handler

Result: our bridge EH is silently destroyed. No scoring, no hitmarkers.

**Fix — MPHit as primary scoring path:**

`addMPEventHandler ["MPHit", ...]` fires on ALL machines for every hit and is completely immune to `removeAllEventHandlers "HitPart"`. MPHit provides `[unit, causedBy, damage, instigator]` — while `damage` is 0 (due to WBK's `allowDamage false`), the `instigator` parameter correctly identifies the shooting player.

MPHit awards a flat hit score (`SCORE_HIT + SCORE_DAMAGE_BASE * 0.5`), while the HitPart bridge (if it survives the race) provides more precise damage-based scoring. A timestamp-based dedup mechanism prevents double-scoring when both fire.

Additionally added diagnostic logging inside the HitPart relay wrapper EH closure to confirm the race condition hypothesis. If `[EJ] HitPart bridge EH FIRED` never appears in the RPT while `[EJ] HitPart bridge registered` does, the race condition is confirmed.

| File | Change |
|---|---|
| `hostiles/wbk/fn_spawnWBKUnit.sqf` | Added `addMPEventHandler ["MPHit", ...]` as primary hit scoring path with flat score award, instigator tracking, and HitPart dedup check |
| `hostiles/wbk/fn_wbkHitPartScore.sqf` | Added `EJ_lastHitPartTime` timestamp after scoring for MPHit dedup |
| `hostiles/wbk/fn_registerHitPartBridge.sqf` | Added diagnostic `diag_log` inside the HitPart EH closure to confirm whether it fires |

#### New Scoring Architecture

```
MPHit (primary — guaranteed to fire, immune to removeAllEventHandlers)
  → fires on ALL machines
  → isServer gate (processes once on server)
  → resolves scorer from instigator/causedBy
  → sets EJ_lastScorer (for kill attribution)
  → checks EJ_lastHitPartTime dedup
  → if not deduped: flat score (SCORE_HIT + SCORE_DAMAGE_BASE * 0.5)

HitPart bridge (secondary — precise damage scoring, may be wiped by race)
  → fires on unit owner (server or HC)
  → relay wrapper pre-extracts data
  → calls fn_wbkHitPartScore on server
  → sets EJ_lastHitPartTime (suppresses MPHit flat scoring)
  → precise score (SCORE_HIT + SCORE_DAMAGE_BASE * normDmg)

MPKilled (kill scoring — unchanged from Phase 3)
  → fires on ALL machines
  → isServer gate
  → EJ_lastScorer fallback for instigator
  → kill bonus + accumulated points
```

#### Global Variables

| Variable | Set By | Scope | Purpose |
|---|---|---|---|
| `EJ_lastHitPartTime` | `fn_wbkHitPartScore` | Per-unit (`setVariable`, not public) | Timestamp for MPHit dedup — prevents double-scoring when HitPart bridge survives |

---

### Hotfix 3.8 — WBK Zombie Stuck-in-Terrain Detection (2026-04-12)

**Symptom:** In a densely built city, a WBK zombie spawned between a building and a fence with shrubs. It was wedged in geometry and could not move. Because WBK zombies are excluded from vanilla stuck-check (Hotfix 3.2), the zombie was never cleaned up. The wave-end condition (`EAST countSide allUnits == 0`) could not fire while this zombie remained alive, stalling the wave indefinitely.

**Root Cause — No stuck safety net for WBK zombies:**

Hotfix 3.2 correctly excluded WBK zombies from the vanilla stuck-check in `clearStuck.sqf` because the vanilla heuristic (15m closer to player in 30s) false-positived on slow zombie types. However, no replacement detection was added. If a WBK zombie is physically wedged in terrain geometry (buildings, fences, brush), its PFH pathfinding runs but produces no actual displacement, and nothing kills it.

The wave loop in `missionLoop.sqf` has no timeout — it exits only when all EAST units are dead or all players are dead. A single stuck zombie blocks progression forever.

**Fix — Position-based stall detection for WBK zombies in `clearStuck.sqf`:**

Replaced the WBK no-op block with a parallel tracking path that uses absolute displacement rather than distance-to-player:

1. **Snapshot phase (tick 0):** Each WBK zombie's `getPosATL` is recorded into `EJ_wbkStuckCheckArray`.
2. **Evaluation phase (tick 30):** For each snapshot, checks if the zombie moved less than 3m total. Even Crawlers (~0.5 m/s) cover ~15m in 30 seconds, so 3m is a ~5× safety margin below the slowest type.
3. **Player-distance guard:** Zombies within 25m of any player are always considered "not stuck" — they may be stationary because they're in melee combat.
4. **Strike system:** A per-unit `EJ_stuckStrikes` variable is incremented on each failed check. At 2 consecutive strikes (60 seconds stationary), the zombie is killed via `setDamage 1`. Strikes reset to 0 whenever the zombie passes a check.
5. **`setDamage 1` (not `deleteVehicle`):** Preserves the WBK Killed EH → score pipeline → `waveUnits` body cleanup. `deleteVehicle` would silently remove the unit and orphan PFH handlers.

**Detection thresholds:**

| Parameter | Value | Rationale |
|---|---|---|
| Movement threshold | 3m per 30s | ~5× below Crawler speed (slowest type: ~15m/30s) |
| Player distance guard | 25m | Prevents flagging zombies in melee range |
| Strike threshold | 2 (60s total) | Conservative — avoids false positives on zombies temporarily blocked by other zombies |

#### Files Modified

| File | Change |
|---|---|
| `hostiles/clearStuck.sqf` | Replaced WBK no-op block (lines 14–17) with position-based stall detection: snapshot on tick 0 into `EJ_wbkStuckCheckArray`, evaluate on tick 30 with 3m movement threshold + 25m player guard + 2-strike kill via `setDamage 1`. Also clears `EJ_wbkStuckCheckArray` alongside `AIStuckCheckArray` when no EAST units remain and at end of each 30s cycle. |
| `hostiles/wbk/fn_initWBKRegistry.sqf` | Added `EJ_wbkStuckCheckArray = []` initialisation in new "Stuck Detection State" section. |

#### Global Variables

| Variable | Set By | Scope | Purpose |
|---|---|---|---|
| `EJ_wbkStuckCheckArray` | `clearStuck.sqf` / `fn_initWBKRegistry` | Server global | Snapshot array `[unit, posATL]` — rebuilt every 30s cycle |
| `EJ_stuckStrikes` | `clearStuck.sqf` | Per-unit (`setVariable`, not public) | Consecutive 30s stall count; kill at ≥ 2 |

---

### Hotfix 2.6 — Increased Magazine Counts for Weapon Loot & Resupply (2026-04-12)

**Request:** Weapon ground loot always spawned with only 1 magazine, making found weapons impractical given the large variety of weapon/magazine types. Spin Box (mystery box) also gave only 1 magazine. FILL AMMO supply drop gave ~3 magazines for standard rifles — wanted ~4.

**Fix:** Added RNG to weapon loot magazine counts (1–4 mags) and increased FILL AMMO round thresholds by ~33%.

#### Changes

| File | Change |
|---|---|
| `loot/spawnLoot.sqf` | Case 0 (weapon + ammo) in both default-pool and whitelist-pool paths: magazine count changed from hard-coded `1` to `1 + (floor random 4)` — weapons now spawn with 1–4 random magazines. |
| `loot/spin/main.sqf` | Spin Box weapon reward: magazine count changed from `1` to `1 + (floor random 4)` — mystery box weapons now come with 1–4 magazines. |
| `supports/ammoDrop.sqf` | FILL AMMO `_maxRounds` thresholds increased ~33%: ≤4 rds→20, 5–10→35, 11–40→120, 41–70→210, 71–100→300, 101–150→450, >150→600. A standard 30-round rifle now yields ~4 magazines instead of ~3. Launcher (3) and handgun (3) unchanged. |

---

## Phase 10: Server Performance Optimisation — COMPLETE

**Date:** 2026-04-14
**Status:** Implemented, pending dedicated server test

### Problem

First dedicated server playtest (3900X CPU, no headless client) revealed severe performance degradation:
- **Wave 1–2:** Noticeable lag; picking up magazines required multiple attempts.
- **Wave 3:** Zombies began desyncing — running in place for several seconds.
- **Wave 4:** Zombies running in place for 20–30 seconds at a time. Mission effectively unplayable.

### Root Cause Analysis

**1. WBK Mod PFH Overhead (primary cause):**
Each WBK zombie registers 3 CBA per-frame handlers (PFHs) for pathfinding, animation, and attack detection:

| Zombie Type | PFH Intervals | Callbacks/sec per zombie |
|---|---|---|
| Runner/Middle (T1) | 0.1s, 0.1s, 4–7s | ~20 |
| Walker (T1) | 0.5s, 0.1s, 10s | ~12 |
| Smasher (T4) | 0.3s, **0.01s**, 2.4s + attacks | ~100–200 |
| Goliath (T5) | 0.5s, **0.01s**, 2.4s | ~100 |

With `EJ_MAX_ACTIVE_ZOMBIES = 100`, the mod alone generated **2000+ PFH callbacks/sec** — overwhelming the Arma 3 scheduler. PFH callbacks queued up and fired late, causing `setVelocityTransformation` calls to miss their timing windows → zombies "run in place" as animations play but velocity isn't applied on time.

**2. Mission Script CPU Waste (compounding):**

| Script | Problem | Wasted CPU |
|---|---|---|
| `revivePlayers.sqf` | `while {true}` with **NO sleep** — full-speed CPU spin | Entire scheduled thread consumed |
| `areaEnforcement.sqf` | `sleep 0.01` — boundary checks at 100 Hz for 1–4 players | 100× more frequent than needed |
| `missionLoop.sqf` inner while | No sleep — `EAST countSide allUnits` polled every engine frame | 50+ allUnits scans/sec |
| `moveHosToPlayer.sqf` | Two `forEach allUnits` passes per 15s cycle; `BIS_fnc_findSafePos` called per unit | 40+ expensive pathfinding calls/cycle |
| `SuicideAudio.sqf` | `allUnits × allPlayers` scan every 1s; stale `_allHPs` cache | 40+ distance checks/sec during bloater rush |

**3. Combined Effect:**
The WBK PFH load (2000+ cb/s) plus three CPU-spinning mission scripts left the Arma scheduler no headroom. Scheduled sleep/waitUntil commands became unreliable, network replication fell behind, and zombie state updates desynchronised between server and clients.

### Fix — Five Phases

#### Phase 1: Critical Script Fixes (immediate CPU recovery)

| File | Change | Impact |
|---|---|---|
| `revivePlayers.sqf` | Added `sleep 1;` to `while {true}` loop body | Eliminated full-speed CPU spin; checks medikit once/sec instead of every frame |
| `area/areaEnforcement.sqf` | Changed `sleep 0.01` → `sleep 1` | 100× reduction in boundary check frequency; 1s response time is imperceptible for boundary enforcement |
| `missionLoop.sqf` | Added `sleep 0.5;` at end of inner `while {runMissionLoop}` loop body | Reduced wave-state polling from ~50/sec to 2/sec; 500ms delay to detect wave-end is imperceptible |

#### Phase 2: Performance-Scaled Zombie Caps

| File | Change | Impact |
|---|---|---|
| `description.ext` | Added `PERFORMANCE_MODE` mission parameter: Low (1), Medium (2, default), High (3) | Players choose tier matching their hardware |
| `hostiles/wbk/fn_initWBKRegistry.sqf` | Replaced fixed caps with dynamic scaling from mission parameter + player count | Automatic hardware adaptation |

**Performance Mode Settings:**

| Mode | Base Cap | Per-Player | Solo Total | 4-Player Total | T3+ Base | T3+ Per-Player |
|---|---|---|---|---|---|---|
| Low (budget hardware) | 20 | +5 | 25 | 40 | 2 | +0 |
| Medium (recommended) | 25 | +8 | 33 | 57 | 2 | +1 |
| High (dedi + HC) | 40 | +10 | 50 | 80 | 3 | +1 |

Formula: `EJ_MAX_ACTIVE_ZOMBIES = baseCap + (playerCount × perPlayerCap)`

The drip-feed overflow system (Spec §4.3) ensures all budget-allocated zombies eventually spawn — they arrive as a continuous stream rather than a burst, which is both smoother for gameplay and better for performance.

#### Phase 3: Spawn Throttle

| File | Change | Impact |
|---|---|---|
| `hostiles/wbk/fn_initWBKRegistry.sqf` | `EJ_SPAWN_BATCH_DELAY` changed from `0.2` → `0.5` | Drip-feed PFH runs at 2Hz instead of 5Hz; reduces `EAST countSide allUnits` queries in PFH |

#### Phase 4: moveHosToPlayer.sqf Optimisation

Complete rewrite from dual-pass to single-pass architecture:

| Before | After |
|---|---|
| Two `forEach allUnits` passes (behaviour + movement) | Single `forEach allUnits` pass handles both |
| Target list rebuilt per-unit via `forEach _allHPs` | Pre-filtered `_aiTargets` built once per cycle |

---

## Hotfix: Horde Sound on Single Zombie

**Date:** 2026-04-17
**Status:** Implemented

### Root Cause

WBK's `WBK_ZombiePlayIdleSounds` function (in `XEH_preInit.sqf`) has a horde sound optimization: when a group has ≥15 alive members, only the **group leader** plays a `wbk_horde_01` sound (with +250m audible range boost). All other group members are completely silenced.

Because Bulwarks puts all wave zombies into a **single shared EAST group** (in `fn_spawnWBKWave.sqf`, for `findNearestEnemy` correctness), the ≥15 threshold is almost always met. This causes:
- Only the group leader emits any sound; all other zombies are silent
- If the leader becomes separated from the pack, a lone zombie sounds like an entire horde
- 30+ zombies near the player make zero noise

### Fix

Override `WBK_ZombiePlayIdleSounds` in `initServer.sqf` (after mod preInit, before any units spawn) to always use the individual-sound code path. Every zombie plays its own spatially-correct sound at its own position.

### Files Modified

| File | Change |
|---|---|
| `initServer.sqf` | Added `WBK_ZombiePlayIdleSounds` override after `EJ_fnc_initWBKRegistry` call |

### Performance Note

More `say3D` calls than the optimized horde path, but calls are staggered across PFH ticks (not simultaneous) and `say3D` has built-in distance attenuation. This is the same code path WBK already uses for groups under 15 — no new performance risk.
| `BIS_fnc_findSafePos` called per unit (expensive navmesh search) | Direct `getPos _nearestPlayer` — WBK PFH handles fine-grained navigation |
| Global variable pollution (`thisNPC`, `goToPlayer`, `gotoPlayerDistance`) | All variables `private` scoped |
| `WBK_Zombies_MoveDistanceLimit` read per-unit | Cached once per 15s cycle |

Estimated improvement: ~50% fewer iterations per cycle, elimination of 40+ `BIS_fnc_findSafePos` calls.

#### Phase 5: Ancillary Script Optimisation

| File | Change | Impact |
|---|---|---|
| `hostiles/SuicideAudio.sqf` | Scan interval `sleep 1` → `sleep 5`; moved `_allHPs` refresh inside loop (was stale from before loop entry) | 5× reduction in allUnits scan frequency during bloater rush; new players mid-wave now detected |
| `hostiles/wbk/fn_initPlayerReviveBridge.sqf` | `forgetTarget` broadcast: replaced `forEach allUnits` + per-unit `isNil` check with pre-filtered `allUnits select { side _x == east && !isNil {...} }` | Skips player/civilian units in the remoteExec burst; cleaner single-expression filter |

### Files Modified

| File | Change |
|---|---|
| `revivePlayers.sqf` | Added `sleep 1;` to while loop |
| `area/areaEnforcement.sqf` | `sleep 0.01` → `sleep 1` |
| `missionLoop.sqf` | Added `sleep 0.5;` to inner while loop |
| `description.ext` | Added `PERFORMANCE_MODE` parameter (Low/Medium/High) |
| `hostiles/wbk/fn_initWBKRegistry.sqf` | Dynamic caps from mission parameter + player count; `EJ_SPAWN_BATCH_DELAY` 0.2→0.5 |
| `hostiles/moveHosToPlayer.sqf` | Complete rewrite: single-pass, removed `BIS_fnc_findSafePos`, private variables, cached targets |
| `hostiles/SuicideAudio.sqf` | Scan interval 1s→5s; `_allHPs` refresh moved inside loop |
| `hostiles/wbk/fn_initPlayerReviveBridge.sqf` | `forgetTarget` uses pre-filtered EAST zombie list |

### Global Variables

| Variable | Change | Notes |
|---|---|---|
| `EJ_MAX_ACTIVE_ZOMBIES` | Fixed 100 → dynamic (25–80 based on mode + players) | Read from `PERFORMANCE_MODE` param |
| `EJ_MAX_ACTIVE_T3_PLUS` | Fixed 6 → dynamic (2–7 based on mode + players) | Read from `PERFORMANCE_MODE` param |
| `EJ_SPAWN_BATCH_DELAY` | 0.2 → 0.5 | Reduces drip-feed PFH frequency |

### Verification Plan

1. **Baseline:** Capture `diag_fps` at waves 1, 3, 5 before changes for comparison.
2. **Phase 1 only:** Apply 3 sleep fixes, test wave 3–4 solo — should see immediate improvement.
3. **Full stack:** All phases, waves 1–10 solo on dedicated without HC — target: no desync, server FPS >20.
4. **HC test:** Same with headless client — verify scoring and zombie behaviour with AI offloaded.
5. **4-player test:** Verify dynamic scaling produces appropriate zombie counts per session size.
6. **Wave 20+ stress:** Verify drip-feed handles overflow at lower caps; gameplay pressure stays constant.

---

## Hotfix 11: Starting Weapons & Loot Magazine Tuning

**Date:** 2026-04-14
**Status:** Implemented

### Changes

| File | Change |
|---|---|
| `description.ext` | `PLAYER_STARTWEAPON` parameter title renamed from "Players start with pistol" to "Players start with weapons" |
| `onPlayerRespawn.sqf` | When `PLAYER_STARTWEAPON` is enabled, players now receive a pistol (P07 + 2 mags) **and** a random non-blacklisted primary weapon with 5 magazines (selected from `List_Primaries`) on spawn/respawn |
| `initServer.sqf` | Added `publicVariable "List_Primaries"` so clients can access the filtered primary weapon list for spawn loadout |
| `loot/spawnLoot.sqf` | Weapon loot crates (case 0: weapon+ammo, case 1: ammo-only) in both default-pool and whitelist-pool paths: magazine count changed from random (1–4 / 1–3) to fixed 5 |

### Global Variables

| Variable | Change | Notes |
|---|---|---|
| `List_Primaries` | Now `publicVariable`'d | Was server-only; clients need it for spawn loadout |
| `PLAYER_STARTWEAPON` | Behaviour expanded | Now grants pistol + random primary instead of pistol only |

---

### Phase 12 — Anti-Barricade-Cheese: WBK Zombies vs Build Structures (2026-04-15)

**Problem:** Players can fully enclose themselves with barricades and mow down zombies indefinitely. Zombies wander aimlessly near barricades, then stand still, and are eventually removed by `clearStuck.sqf` after 60 seconds. No zombie can ever threaten a barricaded player.

**Root Cause — `solidObject.sqf` fights WBK zombie AI:**

`solidObject.sqf` runs a 10Hz per-barricade loop that detects any EAST unit within the object's Radius and forcibly pushes it away (`doStop` → `disableAI "MOVE"` → `doMove` to a random position 10m behind the zombie). This was designed for vanilla Arma AI.

WBK zombies have their own 3-PFH AI system controlling movement. When the PFH's `lineIntersectsSurfaces` raycast detects a barricade blocking LOS: it switches to Arma navmesh mode and issues its own `doMove` toward the player. But `solidObject.sqf` immediately overrides that with a `doMove` pointing AWAY. The two systems fight — producing the jittery wander, eventually settling into idle (the "stand still" phase).

`moveHosToPlayer.sqf` already handles this correctly — it checks for `WBK_AI_ISZombie` and skips WBK zombies within PFH range. `solidObject.sqf` had zero WBK awareness.

**Fix — Three layers in one change:**

**Layer 1 (WBK guard clause):** Added `WBK_AI_ISZombie` variable check to `solidObject.sqf`. WBK zombies are now skipped by the push logic entirely. Their PFH AI handles barricade detection via `lineIntersectsSurfaces` — when LOS is blocked, they switch to Arma navmesh and try to path around. If no path exists, they naturally pile up against the barricade.

**Option A (Smashers/Goliaths break through — free):** With the push logic no longer repelling WBK zombies, Smashers and Goliaths can reach barricades. Their built-in WBK mod functions destroy `Static`-class structures on contact:
- `WBK_Smasher_Damage_Humanoid`: forward raycast (4–6m) → `setDamage 1` on any Static object
- `WBK_GoliaphProceedDamage`: radius scan (5–8m) → `setDamage 1` on Static + CAR objects
- Goliath running state: destroys all Static objects within 9m every 0.5s

No new code needed — removing the push was sufficient to unblock these existing mechanics.

**Option B (Passive degradation):** Each 0.1s tick, the loop counts WBK zombies within the barricade's Radius. Each zombie adds `EJ_BARRICADE_DEGRADE_RATE` damage per tick (default 0.001). At default rate:
- 1 zombie pressing: ~100 seconds to destroy
- 5 zombies: ~20 seconds
- 10 zombies: ~10 seconds
- 20 zombies: ~5 seconds

This scales naturally with cheese severity — a wall blocking 20 zombies crumbles fast; a wall catching a straggler barely degrades. Rate is configurable in `editMe.sqf`; set to 0 to disable (Smashers/Goliaths still break through).

**Performance impact:** Net improvement. Removes the per-WBK-zombie `doStop`/`disableAI`/`enableAI`/`doMove`/`BIS_fnc_findSafePos` cycle that ran every 0.1s and conflicted with the PFH. Replaced with a lightweight integer increment + one `setDamage` call per tick per barricade.

The `suicideWave` check is preserved above the WBK guard — if vanilla suicide wave logic is ever triggered, it still kills the zombie and deletes the barricade for all unit types.

| File | Change |
|---|---|
| `bulwark/solidObject.sqf` | Added `WBK_AI_ISZombie` guard: WBK zombies skip push logic, counted for passive degradation pressure. Degradation rate read from `EJ_BARRICADE_DEGRADE_RATE` (default 0.001). After forEach, applies accumulated pressure damage via `setDamage`. Vanilla AI push logic unchanged. |
| `editMe.sqf` | Added `EJ_BARRICADE_DEGRADE_RATE = 0.001` with comment explaining scaling (1 zombie ≈ 100s, 10 ≈ 10s, 20 ≈ 5s). Set to 0 to disable. |

### Global Variables

| Variable | Scope | Set In | Read In | Purpose |
|---|---|---|---|---|
| `EJ_BARRICADE_DEGRADE_RATE` | Mission config | `editMe.sqf` | `bulwark/solidObject.sqf` | Damage per 0.1s tick per nearby WBK zombie. Default 0.003. Set to 0 to disable passive degradation. |

### Hotfix 12.1 — Degradation Scan Radius + Rate Tuning (2026-04-15)

**Symptom:** Zombies pile up against barricades correctly (Layer 1 working), but barricades never break — degradation appears non-functional after several minutes.

**Root Cause — Two compounding issues:**

1. **Detection radius too tight:** The degradation count used the same `nearEntities` scan as the vanilla AI push (`Radius + 1`, typically 2.5–5m). WBK zombies in navmesh fallback mode stop at the nearest navigable point to their target, which is often a few meters away from the barricade center. They're visually pressed against the barricade but their Arma position is outside the tight scan radius.

2. **Rate too low for real counts:** Even when 1–2 zombies were detected, 0.001/tick = 50–100 seconds to destroy. With most zombies outside the tight radius, effective pressure was near zero.

**Fix:**

1. **Wider pressure scan:** Degradation now uses a separate `nearEntities` call with radius `_objRadius + 5` (typically 7.5–10m). This catches zombies that the navmesh has stopped a few meters from the barricade surface. The tight-radius scan is still used for the vanilla AI push logic (unchanged).

2. **Rate increased 3×:** Default `EJ_BARRICADE_DEGRADE_RATE` bumped from 0.001 to 0.003. New scaling: 1 zombie ≈ 33s, 5 zombies ≈ 7s, 10 zombies ≈ 3s, 20 zombies ≈ 1.5s.

**Performance note:** Adds one `nearEntities` call per barricade per 0.1s tick with a wider radius. Guarded by `_degradeRate > 0` — setting rate to 0 in `editMe.sqf` skips the scan entirely.

| File | Change |
|---|---|
| `bulwark/solidObject.sqf` | Degradation pressure scan moved to separate post-forEach block with wider radius (`_objRadius + 5`). Removed inline `_wbkPressure` counter from main forEach. Default fallback rate changed from 0.001 to 0.003. |
| `editMe.sqf` | `EJ_BARRICADE_DEGRADE_RATE` default changed from 0.001 to 0.003. Comment updated with new scaling numbers. |

### Hotfix 12.2 — Structural HP: Indestructible Object Fix (2026-04-16)

**Symptom:** 4 zombies pressed against barricades for several minutes, zero degradation visible. Hotfix 12.1 (wider radius + rate increase) had no effect.

**Root Cause — Arma 3 `Land_*` static objects are indestructible:**

Most barricade classes (`Land_SandbagBarricade_01_half_F`, `Land_Barricade_01_4m_F`, `Land_HBarrier_3_F`, etc.) have no destruction model in their CfgVehicles config. `setDamage` writes a damage value internally but the engine ignores it — the object never visually degrades or gets removed. `damage _object` may even return 0 regardless of how many times `setDamage` was called.

The existing suicide wave code already works around this by calling `deleteVehicle _object` explicitly after `setDamage 1` — it never relied on damage alone.

**Fix — Custom structural HP system:**

Added `EJ_structHP` variable on each barricade (initialized to 1.0 when `solidObject.sqf` first runs). Degradation now decrements this variable instead of calling `setDamage`. When `EJ_structHP` reaches 0, the barricade is removed via `deleteVehicle`. This mirrors WBK's own `WBK_SynthHP` pattern for zombies.

The `setDamage` call was removed entirely — all damage tracking goes through `EJ_structHP`.

| File | Change |
|---|---|
| `bulwark/solidObject.sqf` | Added `EJ_structHP` variable init (1.0, broadcast). Degradation block now decrements `EJ_structHP` instead of calling `setDamage`. When HP ≤ 0, calls `deleteVehicle`. |

---

### Phase 13 — Barricade Immersion & Balance Suite (2026-04-16)

**Context:** Phase 12 established the anti-cheese core (WBK guard clause, passive degradation, structural HP). Barricades now degrade and break, but the experience lacked immersion — zombies stood idle against walls with no visual/audio feedback. Additionally, the economy had no repair loop (sell refund broken) and no incentive for good barricade placement.

**Five changes implemented as a cohesive balance package:**

#### 13.1 — Fix Sell Refund

**Problem:** `fn_sell.sqf` had the refund line commented out. Players permanently lost points when demolishing barricades, making rebuild/repair impossible.

**Fix:** Uncommented `[_player, _shopPrice] call killPoints_fnc_add` in `fn_sell.sqf`. Players now receive full refund when selling a barricade. This enables the repair loop: sell a damaged wall → buy a fresh one.

#### 13.2 — Zombie Attack Animations on Barricades

**Problem:** WBK zombies stood in walk/run animation against barricades. The `_actFr` PFH only triggers attacks toward `findNearestEnemy`, never at static objects.

**Fix:** In `solidObject.sqf`, zombies in the degradation pressure zone now play melee attack animations toward the barricade on a 3-second cooldown per zombie. Uses `switchMove` via `remoteExec` (safe for all zombie types — no PFH conflict since `switchMove` is the same mechanism WBK uses for its own attacks). Animation selection:
- Crawlers: `WBK_Crawler_Attack`
- Walkers/others: `WBK_Walker_Idle_1_attack` or `WBK_Walker_Idle_2_attack` (random)

Zombies face the barricade (`setDir`) before each attack for visual coherence. Per-zombie `EJ_lastBarricadeAttack` variable prevents animation spam.

#### 13.3 — Audio/Visual Damage Feedback

**Problem:** Barricades silently vanished at 0 HP. No indication they were under stress.

**Fix:** Two feedback layers:
- **Impact sounds:** Each tick where an attack animation fires, a concrete impact sound (`hit_concrete_01/02/03.wss`) plays at the barricade position via `playSound3D`. Limited to one sound per tick regardless of zombie count to prevent audio spam.
- **Destruction effect:** When `EJ_structHP` reaches 0, a `SmallSecondary` explosion effect spawns at the barricade position before `deleteVehicle`. Provides a visual dust puff confirming the wall broke.

#### 13.4 — Wave Survival Bonus

**Problem:** Building was a pure point-sink with no reward for smart placement. No existing event scoring beyond kill/hit/damage.

**Fix:** At wave end in `fn_endWave.sqf`, iterates `PLAYER_OBJECT_LIST` and counts barricades that took damage (`EJ_structHP < 1`) but survived. Each damaged barricade awards `EJ_BARRICADE_SURVIVAL_BONUS * damageTaken` points (default 50 × percentage of HP lost). A barricade at 20% HP awards 40 points; one at 80% awards 10. Total bonus split equally among alive players. Green floating text `+X Fortification Bonus` displays on all clients.

Surviving barricades have their `EJ_structHP` reset to 1.0 for the next wave — they're "repaired" between waves at no cost, but only if they survived.

#### 13.5 — Siege Wave Special Type

**Problem:** No fortification-specific wave threat. Players get complacent after early waves without Smashers.

**Fix:** Added `siegeWave` to the wave 10+ special wave pool (now 6 options instead of 5). When triggered:
- `fn_startWave.sqf` sets `EJ_wbk_siegeWave = true` and shows "SIEGE! Heavy units targeting your fortifications!" warning
- `fn_buildWaveManifest.sqf` reads the flag and overrides normal tier allocation: 2 guaranteed Smashers + 50% chance of a third, remaining budget fills T1 horde. Bypasses normal Smasher cooldown and probability gates.
- Smasher cooldown resets after the wave (they were just spawned), Goliath cooldown increments normally.

**Performance notes:**
- Attack animation `switchMove` adds one `remoteExec` per zombie every 3 seconds (cooldown) — negligible compared to the WBK PFH's 0.1s tick rate
- Impact sound `playSound3D` limited to one per 0.1s tick per barricade — no audio stacking
- Wave survival bonus runs once per wave end — O(n) over `PLAYER_OBJECT_LIST`, no per-frame cost
- Siege wave manifest build is O(budget) — same as bloater rush, runs once per wave start

| File | Change |
|---|---|
| `build/functions/fn_sell.sqf` | Uncommented `[_player, _shopPrice] call killPoints_fnc_add` — sell now refunds full purchase price |
| `bulwark/solidObject.sqf` | Added attack animation system: per-zombie 3s cooldown, `switchMove` with walker/crawler animations, `setDir` toward barricade. Added impact sounds (`playSound3D` with concrete hit SFX). Added `SmallSecondary` destruction effect on HP reaching 0. |
| `bulwark/functions/fn_endWave.sqf` | Added wave survival bonus: iterates `PLAYER_OBJECT_LIST`, awards scaled points for damaged-but-surviving barricades, resets HP, displays green bonus text. |
| `bulwark/functions/fn_startWave.sqf` | Added `siegeWave` to wave 10+ special pool (case 5). Added `EJ_wbk_siegeWave` flag-setting block. Added "SIEGE!" notification with alarm sound. |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | Added siege wave override: 2 guaranteed Smashers + 50% chance of third, remaining budget → T1. Resets Smasher cooldown. Increments Goliath cooldown. |
| `editMe.sqf` | Added `EJ_BARRICADE_SURVIVAL_BONUS = 50` with scaling comment. |

### Global Variables

| Variable | Scope | Set In | Read In | Purpose |
|---|---|---|---|---|
| `EJ_BARRICADE_SURVIVAL_BONUS` | Mission config | `editMe.sqf` | `fn_endWave.sqf` | Base points per damaged-but-surviving barricade. Default 50. Set to 0 to disable. |
| `EJ_wbk_siegeWave` | Wave flag | `fn_startWave.sqf` | `fn_buildWaveManifest.sqf` | Triggers Smasher-heavy siege wave composition. |
| `EJ_lastBarricadeAttack` | Per-zombie | `solidObject.sqf` | `solidObject.sqf` | Timestamp of last attack animation, prevents spam (3s cooldown). |

### Hotfix 13.1 — Attack Positioning + Subtle Destruction Effect (2026-04-16)

**Issue 1:** Zombies played attack animations but stood too far from barricades — melee swings didn't visually connect. The wider pressure scan radius (`_objRadius + 5`) correctly detected them for degradation, but they remained at their navmesh-stopped position several meters out when animating.

**Fix:** Before playing the attack animation, zombies beyond 1.5m from the barricade center are teleported to 1m from the barricade surface via `setPos`. The position is calculated along the barricade→zombie axis (`_object getPos [1, (_object getDir _x)]`) so each zombie approaches from its own side. Z-height is preserved to prevent vertical displacement. Within 1.5m, no repositioning occurs (already close enough).

**Issue 2:** `SmallSecondary` explosion effect on barricade destruction knocked all nearby zombies over — too dramatic for a wall crumbling.

**Fix:** Replaced `SmallSecondary` with a custom particle dust cloud using `#particlesource` and `setParticleParams`. Uses the Arma 3 Universal particle texture with brown/tan colour to simulate concrete dust. Particles rise gently (velocity [0,0,1]), expand from 1.5m to 4m over 2 seconds, and fade out. Source auto-deletes after 0.5s via spawned cleanup. A louder concrete impact sound (volume 2, audible to 25m) plays simultaneously as a "crumble" cue. No physics force is applied — zombies are unaffected.

| File | Change |
|---|---|
| `bulwark/solidObject.sqf` | Attack block: added `distance2D` check and `setPos` to reposition zombies within 1m of barricade before animation. Destruction block: replaced `SmallSecondary` with `#particlesource` dust cloud + louder crumble sound. |

---

## Phase 14 — Bloater Contextual Barricade Targeting (2026-04-17)

**Status:** Implemented, pending in-game test

### Problem

The Phase 12–13 barricade melee system suffered from a "teleport chaining" bug. In `solidObject.sqf`, every 3 seconds each nearby WBK zombie was forcibly `setPos`'d to 1m from the barricade surface for attack animation alignment. When a barricade was destroyed (`deleteVehicle`), the repositioned zombies landed directly inside the next barricade's pressure scan radius (`Radius+5m`). That barricade's independent `solidObject.sqf` loop captured them on its next 0.1s tick and `setPos`'d them again — creating an infinite chain where zombies ate through every barricade sequentially instead of reaching the player after breaking through.

### Root Cause

- `setPos` teleportation in the attack animation block (Hotfix 13.1, `solidObject.sqf` lines 97-103)
- Generous pressure scan radius (`_objRadius + 5`) capturing zombies navigating nearby
- Each barricade's independent per-object loop creating a capture chain
- No "breakthrough immunity" period after barricade destruction

### Design Decision: Replace Passive Degradation with Bloater Breaching

Rather than patching the teleport chain (which would require positional hacks or immunity timers), the entire passive degradation system was replaced with **contextual bloater targeting** — a cleaner, more readable mechanic:

- **Old:** All WBK zombies passively degrade nearby barricades via invisible pressure (10Hz per barricade, `nearEntities` scans, `setPos` teleportation, attack animations)
- **New:** Only Bloaters (T3 special infected) can damage barricades, and only via explosion. Bloaters dynamically detect when a barricade blocks their path to a player and redirect to breach it.

### Architecture

**Single server-side CBA PFH (`fn_bloaterBarricadePFH`), 1.0s interval:**

1. For each alive bloater in `EJ_activeBloaters`:
2. `lineIntersectsSurfaces` raycast from bloater → nearest player
3. If a `PLAYER_OBJECT_LIST` barricade blocks LOS:
   - Distance > `EJ_BLOATER_DETONATE_RANGE` (5m) → **Redirect**: `doMove` toward barricade + override `WBK_AI_LastKnownLoc` to suppress mod's re-targeting for 4-7s
   - Distance ≤ `EJ_BLOATER_DETONATE_RANGE` → **Detonate**: APERS mine (player splash via engine), apply `EJ_BLOATER_BARRICADE_DAMAGE` to all barricades in `EJ_BLOATER_BARRICADE_RADIUS` with LOS
4. If NO barricade blocks path → do nothing (mod handles player-targeting natively)

**Key insight: redirect doesn't fight the mod's PFH.** The mod's `_loopPathfind` (0.1s) only issues `doMove` during one-shot state transitions, and `_loopPathfindDoMove` (random 4-7s) respects `WBK_AI_LastKnownLoc`. Our 1.0s PFH wins the race.

**Key insight: we must trigger detonation ourselves.** The mod's proximity explosion requires `findNearestEnemy` (MAN-class only) within 4m AND `WBK_IsUnitLocked` set. When LOS is blocked by a barricade, `WBK_IsUnitLocked = nil` (navmesh mode), so the mod's explosion never fires near barricades.

### Early Bloater Preview (Waves 3-4)

Bloaters are introduced before the formal T3 unlock (wave 5) to teach the breaching mechanic:
- Wave 3: 2 guaranteed bloaters injected into the manifest
- Wave 4: 3 guaranteed bloaters injected
- Wave 5+: normal T3 tier system handles bloater spawns (minWave gate)
- Bloater Rush special waves: 60% budget to bloaters (unchanged)

Count set by `EJ_wbk_earlyBloaterCount` in `fn_startWave.sqf`, consumed by `fn_buildWaveManifest.sqf`.

### Performance Comparison

| Metric | Old (Passive Degradation) | New (Contextual Targeting) |
|---|---|---|
| Scan frequency | 10 Hz per barricade | 1 Hz total |
| Scan cost/tick | `nearEntities` per barricade | 1× `lineIntersectsSurfaces` per bloater |
| Peak load | 50 zombies × 20 barricades × 10Hz | 12 bloaters × 1Hz = 12 raycasts/s |
| Active during | Entire wave (all zombies) | Only when bloaters alive |
| Network cost | `setVariable` broadcast per tick per degrading barricade | Only on detonation events |

### Components Delivered

| # | File | Function/Change | Purpose |
|---|---|---|---|
| 1 | `hostiles/wbk/fn_bloaterBarricadePFH.sqf` | `EJ_fnc_bloaterBarricadePFH` | Server CBA PFH: raycast → redirect or detonate bloaters at barricades |
| 2 | `hostiles/wbk/fn_barricadeDestroyVFX.sqf` | `EJ_fnc_barricadeDestroyVFX` | Client-side dust burst + crumble sound on barricade destruction |

### Files Modified

| File | Change |
|---|---|
| `bulwark/solidObject.sqf` | Removed entire passive degradation block (~60 lines): pressure scan, attack animations, sounds, `setPos` teleportation, HP drain, destruction VFX. Kept: WBK guard clause, suicide bomber logic, `EJ_structHP` initialization. Removed unused locals (`_degradeRate`, `_attackCooldown`, `_walkerAttacks`, `_runnerAttacks`, `_impactSounds`). Updated header comment. |
| `hostiles/wbk/fn_spawnWBKUnit.sqf` | Added bloater tracking: Boomer-class units pushed to `EJ_activeBloaters` array on spawn. |
| `editMe.sqf` | Replaced `EJ_BARRICADE_DEGRADE_RATE` with three new config globals: `EJ_BLOATER_BARRICADE_DAMAGE` (0.4), `EJ_BLOATER_BARRICADE_RADIUS` (7), `EJ_BLOATER_DETONATE_RANGE` (5). |
| `bulwark/functions/fn_startWave.sqf` | Added early bloater preview logic (waves 3-4: `EJ_wbk_earlyBloaterCount`). Initialize `EJ_activeBloaters = []`. Start bloater barricade PFH via `call EJ_fnc_bloaterBarricadePFH`. |
| `bulwark/functions/fn_endWave.sqf` | Stop bloater barricade PFH via `CBA_fnc_removePerFrameHandler`. Reset `EJ_activeBloaters`. Survival bonus logic unchanged. |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | Added early bloater injection block before PASS 1: reads `EJ_wbk_earlyBloaterCount`, injects guaranteed Boomer entries, deducts from budget. |
| `hostiles/wbk/Functions.hpp` | Registered `bloaterBarricadePFH` and `barricadeDestroyVFX` classes. |
| `description.ext` | Added `bloaterBarricadePFH` and `barricadeDestroyVFX` to CfgRemoteExec. |

### Global Variables

#### Added

| Variable | Defined In | Purpose |
|---|---|---|
| `EJ_BLOATER_BARRICADE_DAMAGE` | `editMe.sqf` | HP fraction removed per explosion per barricade (default 0.4 = 3 bloaters to destroy) |
| `EJ_BLOATER_BARRICADE_RADIUS` | `editMe.sqf` | Blast radius for barricade damage (default 7m, matches APERS mine) |
| `EJ_BLOATER_DETONATE_RANGE` | `editMe.sqf` | Distance at which bloater detonates near a blocking barricade (default 5m) |
| `EJ_activeBloaters` | `fn_startWave.sqf` | Array of alive bloater units for PFH iteration |
| `EJ_bloaterPFHHandle` | `fn_bloaterBarricadePFH.sqf` | CBA PFH handle for cleanup at wave end |
| `EJ_wbk_earlyBloaterCount` | `fn_startWave.sqf` | Number of preview bloaters to inject (waves 3-4 only) |

#### Removed

| Variable | Was In | Reason |
|---|---|---|
| `EJ_BARRICADE_DEGRADE_RATE` | `editMe.sqf` | Passive degradation system removed; replaced by bloater explosion damage |
| `EJ_lastBarricadeAttack` | per-zombie, `solidObject.sqf` | Attack animation cooldown no longer needed |

#### Unchanged

| Variable | Purpose |
|---|---|
| `EJ_structHP` | Per-barricade synthetic HP (still used by bloater explosion damage) |
| `EJ_BARRICADE_SURVIVAL_BONUS` | Wave-end bonus for damaged-but-surviving barricades (still relevant) |
| `PLAYER_OBJECT_LIST` | Master barricade registry (used by PFH for LOS identification and blast scan) |

---

### Hotfix 14.1 — Idle Bloater Recovery (2026-04-17)

**Issue:** During wave 3 early bloater preview, bloater 1 worked correctly (detonated on barricade), but bloater 2 stood idle in the street until cleaned up by the stuck detector at ~60s. Took approximately 1 step then stopped moving permanently.

**Root Cause:** Race condition between the adapter's spawn sequence and the WBK bloater AI initialization. All three WBK PFH handlers depend on `findNearestEnemy` returning a valid target; when it returns `objNull`, they silently exit without issuing any movement command:

- `_loopPathfind` (0.1s): first `switch` case catches `isNull _nearEnemy` → exits with no `doMove`
- `_loopPathfindDoMove` (4-7s): `isNull _nearEnemy` → plays idle sound but issues no `doMove`
- `_actFr` (0.3s): calls `disableAI "TARGET"` every tick, preventing the unit from self-acquiring targets via AI scanning. Only `reveal` can seed knowledge.

The timing chain: adapter's initial `doMove` at t=0s is cancelled by WBK's self-doMove at t=0.5s (`_this doMove (getPosATLVisual _this)` — moves to own position). The adapter re-issues `doMove` + `reveal` at t=1.5s, which normally recovers the zombie. However, if frame-level scheduling causes the `reveal` knowledge to not propagate before the next `findNearestEnemy` evaluation, the bloater enters a permanent idle state where no PFH issues movement and `moveHosToPlayer.sqf` doesn't intervene (it trusts the PFH within 150m).

**Fix (two layers):**

1. **clearStuck.sqf — Recovery on first strike:** When the stuck detector records the first strike (30s idle, moved < 3m), it now issues `reveal [nearestPlayer, 4]` + `doMove` toward that player before incrementing the strike counter. This gives the zombie a recovery window: if the `doMove` works, it will move > 3m in the next 30s cycle and the strike counter resets. If recovery fails, strike 2 kills it at 60s as before.

2. **moveHosToPlayer.sqf — Idle nudge within PFH range:** For WBK zombies within PFH range (< 150m), if `WBK_IsUnitLocked` is `nil` (not in direct-drive) AND `speed < 0.3` (stationary or barely shuffling), issue a `doMove` toward the nearest player. This catches idle zombies on the 15s cycle (much faster than the 30s stuck detector). The `doMove` is a suggestion — once the PFH acquires the target via direct-drive, it overrides naturally. The `speed` check prevents interfering with actively moving zombies.

**Performance:** Both changes are negligible — one extra speed check per WBK zombie per 15s in `moveHosToPlayer`, one extra `reveal` + `doMove` per stuck zombie per 30s in `clearStuck`.

| File | Change |
|---|---|
| `hostiles/clearStuck.sqf` | On first stuck strike: added `reveal` + `doMove` toward nearest player as recovery attempt before incrementing strike counter. Added diag_log for recovery events. |
| `hostiles/moveHosToPlayer.sqf` | WBK zombie path: added idle nudge — if within PFH range, not in direct-drive (`WBK_IsUnitLocked` nil), and speed < 0.3, issue `doMove` toward nearest player. |

---

### Hotfix 14.2 — Bloater Barricade Damage Race Condition (2026-04-17)

**Issue:** Bloaters exploded on barricades (visually correct — APERS mine detonation at the barricade) but barricades took zero HP damage. Even with `EJ_BLOATER_BARRICADE_DAMAGE` set to 0.5, multiple bloater explosions had no effect.

**Root Cause:** The barricade HP damage code lived exclusively in the PFH's detonation block, which only executed when **our PFH** detected and killed the bloater. In practice, the **mod's native explosion** almost always killed the bloater first:

| System | Interval | Condition to Fire |
|---|---|---|
| Our PFH | 1.0s | Bloater within `EJ_BLOATER_DETONATE_RANGE` (5m) of a barricade that blocks LOS to player |
| Mod's `_actFr` | 0.3s | `findNearestEnemy` within 4m AND `WBK_IsUnitLocked` set |

When the bloater approached a barricade, the player was typically right behind it (~3-5m). The mod's `_loopPathfind` (0.1s) detected the player via `checkVisibility` over/around the barricade (visibility ≥ 0.7), set `WBK_IsUnitLocked = 0`, and the mod's `_actFr` triggered the native explosion at 0.3s — killing the bloater before our 1.0s PFH tick could run. On the next PFH tick, the bloater was already dead → lazy cleanup, barricade damage code never executed.

**Fix:** Moved barricade HP damage from the PFH into a **Killed EH** on the bloater, registered at spawn in `fn_spawnWBKUnit.sqf`. The Killed EH fires exactly once regardless of what kills the bloater:
- Mod's native proximity explosion → Killed EH → barricade damage ✓
- Our PFH fallback detonation → Killed EH → barricade damage ✓
- Player shoots bloater near a barricade → Killed EH → barricade damage ✓

The PFH retains its redirect logic (steer bloater toward barricade) and a fallback detonation (APERS mine + kill) for edge cases where the mod's explosion doesn't fire (no player within 4m), but no longer applies barricade damage directly.

| File | Change |
|---|---|
| `hostiles/wbk/fn_spawnWBKUnit.sqf` | Added Killed EH on Boomer-class units: scans `PLAYER_OBJECT_LIST` for barricades within `EJ_BLOATER_BARRICADE_RADIUS`, applies `EJ_BLOATER_BARRICADE_DAMAGE` with LOS check, destroys barricades at 0 HP with VFX. |
| `hostiles/wbk/fn_bloaterBarricadePFH.sqf` | Stripped barricade HP damage from PFH detonation block (kept APERS mine + kill as fallback). Removed unused `_blastRadius` and `_barricadeDmg` params from PFH args. |

---

### Hotfix 14.3 — LOS Check Terrain/Body Clipping (2026-04-17)

**Issue:** Even after Hotfix 14.2 moved barricade damage to the Killed EH, bloater explosions right next to barricades still dealt zero damage. Multiple bloaters detonated on barricades with no HP reduction.

**Root Cause:** Two compounding bugs in the `lineIntersectsSurfaces` LOS check inside the Killed EH:

1. **Terrain clipping:** Both ray endpoints (`AGLToASL _pos` and `AGLToASL (getPos _x)`) were at ground level (z ≈ 0 ATL). With `LOD2 = "NONE"`, `lineIntersectsSurfaces` includes terrain surface intersections. A horizontal ray at terrain height clips against micro-undulations in the terrain mesh → produces a terrain hit. Terrain hits return `objNull` as the hit object, so `(_losCheck select 0 select 2) isEqualTo _x` evaluated to `objNull isEqualTo barricade` → **FALSE** → damage denied.

2. **Dead bloater body not ignored:** `ignore1` was `objNull` (nothing). The dead bloater's ragdoll body retains GEOM collision geometry. The ray from the bloater's feet could hit its own body → non-terrain hit where the object is the dead bloater (not the barricade) → **FALSE** → damage denied.

Combined effect: virtually every LOS check failed, blocking all barricade damage.

**Fix (three layers):**

1. **Raised ray endpoints 1m above ground** (`_pos vectorAdd [0,0,1]`) — clears terrain surface clipping for ground-level explosions
2. **Pass `_unit` as `ignore1`** — dead bloater body skipped by raycast
3. **Terrain pass-through** — if `lineIntersectsSurfaces` returns a hit with `isNull _hitObj` (terrain/water), treat as clear LOS. Only deny damage when a real object (another barricade/structure) blocks the path.

Added diagnostic logging for each barricade damage event (HP before/after, distance, LOS blocked-by) to aid future debugging.

| File | Change |
|---|---|
| `hostiles/wbk/fn_spawnWBKUnit.sqf` | Bloater Killed EH: raised LOS ray 1m above ground, pass dead bloater as ignore1, allow terrain hits through, added diag_log for damage events and LOS blocks. |

---

## Loot Whitelist Conversion

**Date:** 2026-04-17
**Status:** Implemented, pending in-game test

### Scope

Replaced the config-scanning + blacklist loot system with hardcoded whitelist arrays. Only explicitly listed items can spawn as loot. Eliminates the expensive CfgWeapons/CfgVehicles/CfgGlasses/CfgMagazines scanning loops that ran at every mission start.

### Changes

| File | Change |
|---|---|
| `loot/lists.sqf` | Replaced all config-scanning loops and 300+ line blacklist with hardcoded whitelist arrays. No runtime config iteration. Each `List_*` array contains only approved classnames. |
| `editMe.sqf` | Removed `LOOT_BLACKLIST` array, whitelist mode/arrays (`LOOT_WHITELIST_MODE`, `LOOT_WHITELIST_*`). Simplified `LOOT_*_POOL` assignments to reference `List_*` arrays directly without blacklist subtraction. Kept `LOOT_WHITELIST_MODE = 0` for `spawnLoot.sqf` compatibility. |

### Classname Corrections from Editor Prefixes

The Arma 3 editor prefixes item classnames for display. These were stripped to get the actual engine classnames:

| Editor Prefix | Stripped | Example |
|---|---|---|
| `Headgear_` | → (removed) | `Headgear_H_Cap_blk_ION` → `H_Cap_blk_ION` |
| `Item_` | → (removed) | `Item_U_BG_leader` → `U_BG_leader` |
| `Vest_` | → (removed) | `Vest_V_PlateCarrier2_blk` → `V_PlateCarrier2_blk` |
| `Weapon_` | → (removed) | `Weapon_arifle_AK12_F` → `arifle_AK12_F` |

### Explosive/Magazine Classname Corrections

The editor lists CfgVehicles classnames for placed explosives, but the loot system uses `addMagazineCargoGlobal` which requires CfgMagazines classnames:

| Editor Name | CfgMagazines Classname |
|---|---|
| `DemoCharge_F` | `DemoCharge_Remote_Mag` |
| `Claymore_F` | `ClaymoreDirectionalMine_Remote_Mag` |
| `SatchelCharge_F` | `SatchelCharge_Remote_Mag` |

### Backpack List Cleanup

The editor's backpack section included vest classnames (`Vest_V_*`). These are CfgWeapons items, not CfgVehicles backpacks, and would silently fail with `addBackpackCargoGlobal`. Only actual `B_` prefixed backpacks were kept in `List_Backpacks`.

### Magazine Auto-Resolution

Weapon magazines are NOT whitelisted separately. `spawnLoot.sqf` auto-resolves compatible magazines from CfgWeapons config at spawn time via `getArray (configFile >> "CfgWeapons" >> _weapon >> "magazines")`. Each weapon's compatible mags are documented in `lists.sqf` comments for reference.

---

## Hotfix: Weapon Pickup Auto-Grab Magazines

**Date:** 2026-04-17
**Status:** Complete

### Root Cause

When picking up a weapon from a loot container, Arma 3's engine-level auto-pickup of compatible magazines was not triggering. This is because loot is spawned in `WeaponHolderSimulated_Scripted` containers, which do **not** support the engine's built-in magazine auto-grab behaviour. That behaviour only fires for `GroundWeaponHolder` objects (the type the engine creates when a player drops a weapon on the ground).

The weapons and magazines were correctly placed in the same container by `spawnLoot.sqf` — the container type was the sole cause.

### Fix

Added script-based auto-pickup emulation in the `Take` event handler (`onPlayerRespawn.sqf`). When a weapon is taken from a `WeaponHolderSimulated_Scripted` container, the EH:

1. Looks up compatible magazines via `CfgWeapons >> _item >> "magazines"`.
2. Iterates the container's magazine cargo; moves each compatible mag to the player if `canAdd` succeeds, otherwise keeps it in the container.
3. Rebuilds the container's magazine cargo with only the remaining items (`clearMagazineCargoGlobal` + re-add).
4. Delays the `deleteIfEmpty` cleanup call by 0.5 s (via `spawn`/`sleep`) to allow cargo state to sync across the network before the server checks emptiness.

Also fixed two secondary issues with the original `Take` EH:
- **EH accumulation:** Original used `remoteExec ['addEventHandler', 0, true]` (all clients + JIP), causing duplicate EHs to stack on every respawn. Replaced with local `addEventHandler` + `removeEventHandler` guard via `EJ_lootTakeEH` variable.
- **Unnecessary network traffic:** The `Take` EH only needs to run on the player's local machine. Removed the `remoteExec` broadcast.

### Files Modified

| File | Change |
|---|---|
| `onPlayerRespawn.sqf` | Replaced `Take` EH: added auto-pickup logic for compatible magazines, EH accumulation guard (`EJ_lootTakeEH`), 0.5 s delayed cleanup, removed unnecessary `remoteExec` broadcast. |

### Global Variables

| Variable | Scope | Purpose |
|---|---|---|
| `EJ_lootTakeEH` | Client (missionNamespace) | Stores the Take EH index so it can be removed and re-added cleanly on respawn. |

---

## Phase 15: Steam Workshop Publication Assets — COMPLETE

**Date:** 2026-04-17
**Status:** Completed

### Scope

Prepared Steam Workshop publication copy for the public release. The new text consolidates the Bulwarks core loop, the WBK-specific features added during integration, and the initial-publication changelog into Steam-formatted assets.

The workshop description also includes explicit WBK addon-option difficulty guidance for players who want to tune special infected durability and ability cooldowns for solo or small-team play.

The workshop description also states that the current release is built for Altis and links the original Dynamic Bulwarks map-change tutorial while noting that non-Altis WBK ports are not yet personally verified.

**Performance impact:** None. Documentation-only change.

**Spec references:** Summary copy synthesized from Spec §2.1-§2.6, Spec §3.2, and Spec §4.3 where applicable.

### Components Delivered

| # | File | Function Name | Purpose |
|---|---|---|---|
| 1 | `docs/workshop/steam_workshop_description.txt` | — | Steam-formatted workshop description covering Dynamic Bulwarks core mechanics and the WBK features added in this edition |
| 2 | `docs/workshop/steam_workshop_changelog.txt` | — | Steam-formatted initial-publication changelog summarizing the major additions shipped with the WBK conversion |

### Files Modified

| File | Change |
|---|---|
| `docs/workshop/steam_workshop_description.txt` | Added public-facing Steam Workshop description with Bulwarks overview, WBK feature summary, explicit credited links/thank-you notes for Willtop, omNomios, and WebKnight, WBK addon-option difficulty recommendations for solo/duo play, and an Altis/map-porting note with the original tutorial link |
| `docs/workshop/steam_workshop_changelog.txt` | Added Steam Workshop changelog for the initial publication |
| `docs/IMPLEMENTATION_LOG.md` | Added Phase 15 entry documenting the publication asset delivery |

### Global Variables

| Variable | Change |
|---|---|
| None | Documentation-only phase; no mission globals were added or modified |

---

## Hotfix: PLAYER_STARTWEAPON Default Enabled

**Date:** 2026-04-17
**Status:** Implemented

### Scope

Changed the `PLAYER_STARTWEAPON` lobby parameter default from `No` to `Yes` so new sessions start with the starting-weapons option enabled unless the host explicitly turns it off.

**Performance impact:** None. This is a mission-parameter default change evaluated at lobby/setup time only.

**Spec references:** Follows the existing mission-parameter flow described in Spec §2.1 and the runtime parameter handling noted in `docs/Bulwarks/wave-state-machine.md`.

### Components Delivered

| # | File | Function Name | Purpose |
|---|---|---|---|
| 1 | `description.ext` | — | Sets the default selection for the `PLAYER_STARTWEAPON` lobby parameter to enabled |

### Files Modified

| File | Change |
|---|---|
| `description.ext` | Changed `PLAYER_STARTWEAPON` default from `0` (`No`) to `1` (`Yes`) |
| `docs/IMPLEMENTATION_LOG.md` | Added hotfix entry documenting the lobby-parameter default change |

### Global Variables

| Variable | Change |
|---|---|
| `PLAYER_STARTWEAPON` | Default lobby value changed | Now defaults to enabled (`Yes`) for new sessions |

---

## Hotfix: Workshop Parameters Guidance

**Date:** 2026-04-17
**Status:** Implemented

### Scope

Updated the Steam Workshop description to tell hosts to review the mission Parameters menu before starting and to call out that loot spawn density and other Bulwarks mission settings can be adjusted there.

**Performance impact:** None. Documentation-only change.

**Spec references:** Aligns with the mission-parameter flow described in Spec §2.1 and the parameter handling documented in `docs/Bulwarks/wave-state-machine.md`.

### Components Delivered

| # | File | Function Name | Purpose |
|---|---|---|---|
| 1 | `docs/workshop/steam_workshop_description.txt` | — | Adds host guidance to review mission parameters before starting and highlights that loot density and other settings are configurable |

### Files Modified

| File | Change |
|---|---|
| `docs/workshop/steam_workshop_description.txt` | Added a pre-start note telling hosts to review mission parameters and adjust loot density and other Bulwarks settings |
| `docs/IMPLEMENTATION_LOG.md` | Added hotfix entry documenting the workshop-description update |

### Global Variables

| Variable | Change |
|---|---|
| None | Documentation-only hotfix; no mission globals were added or modified |

---

## Hotfix 12: Late-Game Escalation Overhaul

**Date:** 2026-04-17
**Status:** Implemented

### Problem

Late waves (15+) were overwhelmingly T1 filler with rare T4/T5 appearances. In a 2-player session reaching wave 20+:
- Goliath appeared once (wave 15), Smashers appeared once. Acid and Hellbeast variants never showed.
- Bloater Rush fired only 1-2 times across 20+ rounds.
- Players in elaborate structures faced zero threat from hundreds of harmless T1 zombies — the only challenge was ammunition expenditure, not danger.

**Root causes:**
1. **Linear budget too low:** At wave 20 (2p), budget was 82. Goliath costs 60, leaving only 22 — not enough for a Smasher (25). Goliath+Smasher co-spawn was impossible until wave 25.
2. **Long cooldowns:** Goliath 5-wave CD → appeared every 6th wave. Smasher 3-wave CD → every 4th wave.
3. **Late smasher variant unlocks:** Acid at wave 14, Hellbeast at wave 18 — too late, too spread out.
4. **Fixed caps:** Per-wave caps (Smasher=2, Goliath=1) and T3+ combined cap (base 2) never scaled.
5. **T1 drain absorbs all leftover budget:** No cap on filler, so 80%+ of budget became trash zombies.
6. **Bloater rush only from RNG pool:** 1/6 chance per special wave, expected once every 12-18 waves.

### Changes

| File | Change |
|---|---|
| `hostiles/wbk/fn_initWBKRegistry.sqf` | Added late-game budget acceleration: `EJ_BUDGET_LATE_THRESHOLD = 10`, `EJ_BUDGET_LATE_BONUS = 2` — after wave 10 each wave adds +2 bonus budget on top of the linear +4/wave |
| `hostiles/wbk/fn_initWBKRegistry.sqf` | Increased `EJ_BUDGET_PLAYER_SCALE` from 3 to 4 |
| `hostiles/wbk/fn_initWBKRegistry.sqf` | Lowered Smasher variant `minWave`: Acid 14→12, Hellbeast 18→15 — all 3 variants in pool by wave 15 |
| `hostiles/wbk/fn_initWBKRegistry.sqf` | Raised T3+ base cap from 2→3 (all perf modes), Low perf T3+ perPlayer from 0→1 |
| `hostiles/wbk/fn_initWBKRegistry.sqf` | Added `EJ_wavesSinceBloaterRush` cooldown tracker (init 99) |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | New budget formula: `budget = base + (wave-1)*waveScale + max(0,wave-threshold)*lateBonus + players*playerScale` |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | Dynamic Smasher cooldown: 3→2 at wave 15, →1 at wave 20 |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | Dynamic Goliath cooldown: 5→3 at wave 20, →2 at wave 25 |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | Scaling per-wave caps: Smasher 2→3 at w20, →4 at w25; Goliath 1→2 at w25 |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | T3+ combined cap gets +2 bonus after wave 15 for Goliath+Smasher co-spawn |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | Escalating probability gates: Smasher extra-unit 60%→75%→85%, Goliath 40%→55%→70% |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | T3 guaranteed minimum scales: `1 + floor((wave-5)/8)` — w5=1, w13=2, w21=3 |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | T4 shuffle-deal added (matches T3) for Smasher variant diversity |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | T1 horde cap after wave 12: max T1 count = 50% of original budget. Prevents late waves from being all filler |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | Bloater rush intensity scales with wave: 60% base + 2%/wave past 10, capped at 80% |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | Bloater rush cooldown tracker updated each normal wave; reset on bloater rush |
| `bulwark/functions/fn_startWave.sqf` | Bloater rush dual-trigger: guaranteed recurrence every 5 waves after wave 10 via `EJ_wavesSinceBloaterRush`, independent of special wave RNG. Timer overrides other specials if cooldown is met |

### Global Variables

| Variable | Set In | Scope | Purpose |
|---|---|---|---|
| `EJ_BUDGET_LATE_THRESHOLD` | `fn_initWBKRegistry` | Global | Wave number after which late-game budget acceleration starts |
| `EJ_BUDGET_LATE_BONUS` | `fn_initWBKRegistry` | Global | Extra budget per wave beyond late threshold |
| `EJ_wavesSinceBloaterRush` | `fn_initWBKRegistry` / `fn_buildWaveManifest` | `missionNamespace` | Cooldown tracker for guaranteed bloater rush recurrence |

### Budget Table (New vs Old, 2 Players)

| Wave | Old Budget | New Budget | Delta | Best Affordable Combo |
|------|-----------|-----------|-------|----------------------|
| 1 | 6 | 8 | +2 | T1 filler only |
| 5 | 22 | 24 | +2 | T1 + T3 |
| 10 | 42 | 44 | +2 | 1 Smasher + 2 T3 |
| 15 | 62 | 74 | +12 | 1 Goliath + 1 T3 |
| 18 | 74 | 92 | +18 | **1 Goliath + 1 Smasher** (first co-spawn) |
| 20 | 82 | 104 | +22 | 1 Goliath + 1 Smasher + 2 T3 |
| 25 | 102 | 134 | +32 | 1 Goliath + 2 Smashers + 3 T3 |
| 30 | 122 | 164 | +42 | 1 Goliath + 4 Smashers |

### Escalation Summary By Wave Range

| Wave Range | Expected Composition |
|---|---|
| 1-4 | T1 shamblers/runners only, early bloater preview at 3-4 |
| 5-9 | T1 horde + T3 specials (Boomer, Screamer, Leaper entering) |
| 10-14 | First Smashers, T3 specials scaling, bloater rushes begin recurring |
| 15-19 | Goliath enters, all Smasher variants available, Goliath+Smasher possible at 18, shorter cooldowns |
| 20-24 | Goliath+Smasher combo common, 3 Smashers possible, T3 guaranteed 3+, T1 capped at 50% |
| 25+ | 2 Goliaths possible, 4 Smashers possible, probability gates widened, relentless escalation |

### Performance Note

The T1 cap at 50% of budget after wave 12 means late waves actually spawn **fewer total units** than before, but with more high-tier threats. This should be net positive for server FPS since each Smasher/Goliath replaces ~25-60 T1 zombie PFH registrations with a single unit's PFH set.

---

## Hotfix 13: Screamer Incapacitation Bypassing Bulwarks Down/Revive

**Date:** 2026-04-19
**Status:** Implemented

### Problem

When a screamer's scream pushed a player past the lethal damage threshold (≥ 0.89), the player became stuck — alive but unable to act, with no BIS Revive UI (no hold-space-to-respawn, no bleedout timer). The player was trapped under the scream's forceWalk and visual effects with no way to recover.

### Root Cause

**Primary — `EJ_wbk_pendingRevive` flag consumed by wrong HandleDamage call:**

When `WBK_CreateDamage` override detected a lethal hit (no Medikit), it set `EJ_wbk_pendingRevive = true` then called `_target setDamage 1`. Arma 3's engine fires HandleDamage once per hit-point selection PLUS once for the overall "" selection for a single `setDamage` call. The `pendingRevive` gate in HandleDamage cleared the flag on the **first** call (a specific hit-point), routing it to `bis_fnc_reviveEhHandleDamage`. But only the **overall "" selection** call triggers the actual INCAPACITATED transition. By the time the overall call arrived, the flag was already cleared — the call fell through to the environmental damage gate (`_ammo == "" && isNull _source`) which returned 0, blocking the damage. The player never entered INCAPACITATED state.

**Secondary — Scream effects run unconditionally on victims:**

The WBK mod's scream `remoteExec` block applies `playActionNow`, `forceWalk true`, camera shake, and PP effects on the victim **before** calling `WBK_CreateDamage`. Our `WBK_CreateDamage` override blocks damage to INCAPACITATED players, but the animation/forceWalk/effects have already fired. This means a screamer hitting an already-downed player could disrupt BIS Revive animations and lock movement.

**Same issue affected Goliath ground spike:**

The `EJ_wbk_allowLethalDamage` flag had the identical single-consumption problem — only one HandleDamage call passed damage through; subsequent calls (including the critical overall selection) were blocked.

### Fix

**Flag lifecycle change:** Flags (`EJ_wbk_pendingRevive`, `EJ_wbk_allowLethalDamage`) are now cleared **after** `setDamage`/original-function returns, not inside HandleDamage. Since HandleDamage calls are synchronous (all fire and complete before `setDamage` returns), this ensures every per-hitpoint and overall-selection call sees the flag active and routes correctly through `bis_fnc_reviveEhHandleDamage` / passes damage through.

**Defensive `forceWalk false` cleanup:** Added `forceWalk false` calls in the INCAPACITATED gate (HandleDamage), the `WBK_CreateDamage` INCAPACITATED exitWith, the Medikit auto-revive path, and after the lethal `setDamage 1` return. This ensures the screamer's 3-second forceWalk stun is always cleared when a player goes down or is saved by Medikit.

**Performance impact:** Negligible. A few `forceWalk false` calls and moved flag clears, all on damage events only — no polling loops or per-frame work added.

**Spec references:** Relates to the revive bridge design in Spec §2.4 (HandleDamage EH integration).

### Components Delivered

| # | File | Change | Purpose |
|---|---|---|---|
| 1 | `hostiles/wbk/fn_initPlayerReviveBridge.sqf` | `WBK_CreateDamage` lethal path: clear `pendingRevive` + `forceWalk false` after `setDamage 1` returns | Ensures all HandleDamage calls see the flag; clears scream stun on incapacitation |
| 2 | `hostiles/wbk/fn_initPlayerReviveBridge.sqf` | `WBK_CreateDamage` INCAPACITATED exitWith: added `forceWalk false` | Clears scream stun when scream hits already-downed player |
| 3 | `hostiles/wbk/fn_initPlayerReviveBridge.sqf` | `WBK_CreateDamage` Medikit auto-revive: added `forceWalk false` | Clears scream stun on Medikit save |
| 4 | `hostiles/wbk/fn_initPlayerReviveBridge.sqf` | HandleDamage INCAPACITATED gate: added `forceWalk false` + clear stale `pendingRevive` | Belt-and-suspenders cleanup on any damage to downed player |
| 5 | `hostiles/wbk/fn_initPlayerReviveBridge.sqf` | HandleDamage `pendingRevive` gate: removed flag clear | Flag now persists across all HandleDamage calls for a single `setDamage` event |
| 6 | `hostiles/wbk/fn_initPlayerReviveBridge.sqf` | HandleDamage `allowLethalDamage` gate: removed flag clear | Same fix for Goliath ground spike |
| 7 | `hostiles/wbk/fn_initPlayerReviveBridge.sqf` | Goliath override wrapper: clear flag after original returns | Ensures all HandleDamage calls from Goliath spike pass damage through |

### Files Modified

| File | Change |
|---|---|
| `hostiles/wbk/fn_initPlayerReviveBridge.sqf` | Fixed flag lifecycle for `EJ_wbk_pendingRevive` and `EJ_wbk_allowLethalDamage`; added defensive `forceWalk false` in INCAPACITATED, Medikit, and lethal paths |
| `docs/IMPLEMENTATION_LOG.md` | Added Hotfix 13 entry |

### Global Variables

| Variable | Change |
|---|---|
| `EJ_wbk_pendingRevive` | Lifecycle changed: now cleared after `setDamage 1` returns in `WBK_CreateDamage` override, not inside HandleDamage EH |
| `EJ_wbk_allowLethalDamage` | Lifecycle changed: now cleared after `EJ_WBK_GroundShard_original` returns in Goliath wrapper, not inside HandleDamage EH 

---

## Hotfix: Bloater Elevated-Structure Breach (Tower & Platform Support)

**Date:** 2026-04-21
**Status:** Complete

### Problem

Bloaters stopped at the base of player-built guard towers and elevated platforms and never exploded. Players could stand on top of a guard tower and be completely safe from bloater damage even during a Bloater Rush.

### Root Cause Analysis

Three compounding failures, each covering a scenario the existing system missed:

**1. WBK native explosion disabled by elevation gate**

The WBK `WBK_AI_ZombieExplosion.sqf` `_actFr` PFH only fires its melee/explosion logic when the enemy is within 4m AND the bloater is in direct-drive mode. Direct-drive requires `checkVisibility >= 0.7` AND the elevation delta to be within `±1.45m`. A player on a guard tower platform is 6–10m above the bloater — far outside the gate. The mod's native explosion path is therefore permanently disabled for elevated targets.

**2. Bulwarks fallback: open-geometry miss**

The previous `fn_bloaterBarricadePFH` cast one eye-level ray from bloater (0.7m AGL) to player (0.7m AGL). Guard towers have open geometry — there may be no structural element at both eye heights simultaneously. The ray passes between pillars and hits nothing, `count _ins == 0`, and the PFH falls through to do nothing. The bloater receives no redirect and no detonation.

**3. Bulwarks fallback: 3D origin distance check too far**

When the blocking ray DID register a hit (e.g. a pillar or floor edge), the detonation check used `_bloater distance _hitObj` — a 3D distance to the object's model origin. For the guard tower (`Land_Cargo_Patrol_V3_F`), if the origin sits several metres off the ground or horizontally offset from the nearest walkable approach point, the bloater can be physically adjacent to the stairs but still >5m from the origin and never trigger. Stall at the base = permanent inaction.

### Fix

All changes are in `hostiles/wbk/fn_bloaterBarricadePFH.sqf`, keeping the 1 Hz server-side PFH as the sole intervention surface. WBK mod files and the 0.1s/0.3s AI PFHs were not touched.

**Phase 1 — Elevated-support detection (open geometry fallback):**

Before the existing blocking-wall ray, a downward ray is cast from the player's feet (4m down) when `playerZ - bloaterZ > 1.45m`. If the first hit object is in `PLAYER_OBJECT_LIST`, it is stored as the `_supportTarget`. This covers open guard towers, concrete platforms, and any elevated build piece where the bloater–player ray passes through gaps without hitting a wall.

**Phase 2 — Geometry-aware proximity (2D distance):**

The detonation range check was changed from `_bloater distance _hitObj` (3D) to `_bloater distance2D _breachTarget` (ground-plane only). 2D distance is agnostic to object height, so the check reflects how close the bloater is to the structure's footprint rather than its elevated centroid.

**Phase 3 — Stall-based detonation:**

Per-bloater stall state (`EJ_bloaterBreachTarget`, `EJ_bloaterBreachTime`) is tracked across PFH ticks. If the bloater remains locked onto the same breach target for `≥ EJ_BLOATER_STALL_TIME` seconds while within `EJ_BLOATER_STALL_RANGE` 2D metres of its base, mission detonation is forced. This handles the "stuck at the bottom of the stairs" case where Arma's navmesh cannot route the bloater up the stairs but the bloater has clearly arrived at the base.

**Target priority:** A directly blocking wall (`_blockingTarget`) takes priority over the elevated-support fallback (`_supportTarget`). If both exist, the wall wins — it is the more definitive obstruction signal.

**Stall state reset:** When the breach target changes or there is no breach target (clear sightline with no elevated support), the stall clock is reset so stale timers do not linger into future encounters.

**Damage pipeline unchanged:** `EJ_structHP` damage to nearby build objects is still applied exclusively by the bloater's Killed EH in `fn_spawnWBKUnit.sqf`. The PFH only controls when and where the APERS mine + kill fires.

### Performance

| Addition | Cost | When |
|---|---|---|
| Downward ray from player | 1 `lineIntersectsSurfaces` per bloater per second | Only when player is >1.45m above bloater |
| `distance2D` vs `distance` | Cheaper than the 3D version | Every bloater per tick |
| Stall variable reads/writes | Negligible (`getVariable` / `setVariable`) | Every bloater per tick |

The existing PFH already ran 1 × `lineIntersectsSurfaces` per bloater per second. The fix adds at most 1 more (gated on elevation). No new PFH handlers were created. WBK's 0.1s per-unit PFHs are unaffected.

### Files Modified

| File | Change |
|---|---|
| `hostiles/wbk/fn_bloaterBarricadePFH.sqf` | Added elevated-support detection (downward ray), 2D distance proximity, stall-based detonation, per-bloater stall state tracking. Updated header comment. |
| `editMe.sqf` | Added `EJ_BLOATER_STALL_TIME = 8` and `EJ_BLOATER_STALL_RANGE = 10` tuning globals. |

### New Global Variables

| Variable | Set By | Scope | Purpose |
|---|---|---|---|
| `EJ_BLOATER_STALL_TIME` | `editMe.sqf` | Server global | Seconds before stall detonation fires on a locked elevated breach target (default 8) |
| `EJ_BLOATER_STALL_RANGE` | `editMe.sqf` | Server global | 2D radius (m) within which stall detonation is eligible; should exceed `EJ_BLOATER_DETONATE_RANGE` (default 10) |
| `EJ_bloaterBreachTarget` | `fn_bloaterBarricadePFH` | Per-unit (`setVariable`) | Last resolved breach target for stall clock continuity |
| `EJ_bloaterBreachTime` | `fn_bloaterBarricadePFH` | Per-unit (`setVariable`) | `time` when the current breach target was first acquired |

### Verification Checklist

- Player stands on Guard Tower, bloater approaches: should redirect to tower base, then stall-detonate within 8 seconds if unable to climb stairs.
- Player stands on Stairs object: downward ray hits stairs (a PLAYER_OBJECT_LIST object), redirect + stall detonation applies.
- Player stands on ground behind a barricade: original blocking-wall path still fires; 2D distance check gives same effective result as old 3D check for flat ground.
- Player on ground, no build objects between them and bloater: PFH does nothing; WBK native explosion fires when the bloater reaches melee range (unchanged).
- Bloater Rush wave: confirm no scheduler regression; only the 1 Hz PFH is running, no new handlers added.

---

## Hotfix: Bloater Stops Too Far — Oblique Miss & Origin-Anchored Distance

**Date:** 2026-04-22
**Status:** Complete

### Problem

Some bloaters still failed to detonate against flat-ground barricades (sandbags, concrete walls). Two failure modes were observed:

1. A bloater approaching from an oblique angle had its single eye-level LOS ray clear the barrier's collision hull entirely (`count _ins == 0`). No breach target was set, no redirect fired, and the bloater circled until the stuck cleaner killed it.
2. Bloaters that did receive a redirect via `doMove (getPos _breachTarget)` stopped at the object's model origin rather than the wall face. For barriers whose origin sits at their geometric centre, the bloater could be physically adjacent to the exterior face yet still >5m from the origin — outside `EJ_BLOATER_DETONATE_RANGE = 5` — and never detonate.

The same origin-anchoring bug existed in `moveHosToPlayer.sqf`'s cover redirect, causing the issued `doMove` to route zombies to an unreachable point inside wall geometry.

### Root Cause

- `getPos _breachTarget` and `getPos _coverTarget` return the model's local origin, which for most `Land_*` barriers is at the physical centre of the object, not its exterior face.
- The proximity check (`distance2D _breachTarget`) measures to the same origin point, so the detonation gate was never satisfied even when the bloater was touching the wall.
- A single 0.7m eye-level ray cannot reliably detect low barriers (sandbags) from oblique angles where the hull geometry doesn't cross that exact height and direction.

### Fixes

**1. Proximity fallback scan (`fn_bloaterBarricadePFH.sqf`)**

After both ray-based checks (eye-level blocking wall + elevated-support downward ray), if `_breachTarget` is still `objNull`, the PFH now scans `PLAYER_OBJECT_LIST` with a flat 2D distance check against `_detonateRange`. This catches oblique-approach cases where rays miss the collision hull. Cost: only when `_breachTarget` is null AND the bloater is already within `_detonateRange` — zero overhead during the normal approach.

**2. Exterior approach point redirect (`fn_bloaterBarricadePFH.sqf`)**

The `doMove` redirect now computes a point 2m from the breach target's origin in the direction of the bloater, rather than issuing `doMove (getPos _breachTarget)` directly. This gives a navmesh-accessible point just outside the wall face on the bloater's side, guaranteeing the approach target is reachable and within the detonation threshold.

**3. Exterior approach point in movement loop (`moveHosToPlayer.sqf`)**

The same 2m exterior offset is applied to the cover redirect in `moveHosToPlayer`, using `getPosATL` so zombies route to a point just outside the cover exterior rather than attempting to path to the object centre.

**4. Config value increases (`editMe.sqf`)**

- `EJ_BLOATER_DETONATE_RANGE`: 5 → 7. Accounts for the 2m exterior offset: when a bloater is at the approach point 2m from the wall face, `distance2D` to the wall origin is approximately 2–5m depending on wall thickness. 7m ensures the gate is reached before the bloater overshoots.
- `EJ_BLOATER_BARRICADE_RADIUS`: 7 → 10. The explosion now fires slightly further from the wall centre (at the approach point), so the radius needed to reach the inner wall face is correspondingly larger.

### Files Modified

| File | Change |
|---|---|
| `hostiles/wbk/fn_bloaterBarricadePFH.sqf` | Added STEP 2b proximity fallback scan; replaced `getPos`-based redirect with 2m exterior offset calculation. |
| `hostiles/moveHosToPlayer.sqf` | Replaced `getPos`-based cover redirect with 2m exterior offset calculation using `getPosATL`. |
| `editMe.sqf` | `EJ_BLOATER_DETONATE_RANGE` 5→7; `EJ_BLOATER_BARRICADE_RADIUS` 7→10. Updated comments. |

---

## Hotfix: WBK Zombie Cover-Routing Bug (Zombies Stop at ~50m Behind Sandbags)

**Date:** 2026-04-21
**Status:** Complete

### Problem

All WBK zombie types (runners, shamblers, bloaters) stopped advancing at roughly 50 m when the nearest player stepped behind any player-built cover (sandbags, concrete walls, barricades, etc.). The stuck detector in `clearStuck.sqf` then killed them after 60 s of no movement, producing the symptom of "bloater rush deleted by the cleaner". Bloaters never reached cover and the breach PFH never fired.

### Root Cause

`moveHosToPlayer.sqf` always issued `doMove (getPos _nearestPlayer)` — the player's exact world position. When that position is inside or behind a ring of player-built objects, Arma's pathfinding engine treats it as unreachable (the navmesh cannot plan a path through the solid collision geometry). The zombie receives the `doMove` order, fails to plan a route, and halts wherever it stands. This stalls even active, fully-healthy zombies that are not in the WBK direct-drive mode.

The loop runs every 15 s, so each cycle the zombie re-receives the same bad order and remains stationary.

This was a pre-existing limitation that became visible after the bloater tower fix (which drew attention to stalling zombies), but is unrelated to the tower work itself.

### Fix

In `hostiles/moveHosToPlayer.sqf`, inside the WBK zombie branch, a cover-target resolution block was added immediately after the reveal loop:

1. Cast two `lineIntersectsSurfaces` rays from the zombie toward the nearest player at **0.35m** (low, catches sandbags) and **0.9m** (torso, catches taller cover). Two heights are checked so low cover like `Land_SandbagBarricade_01_half_F` is detected before a taller piece behind it wins.
2. If either ray's first hit is a `PLAYER_OBJECT_LIST` object, that object becomes `_coverTarget`.
3. When `_coverTarget` is found:
   - `doMove` is issued toward the cover object's position — a reachable navmesh point just outside the structure.
   - `WBK_AI_LastKnownLoc` is set to that position so the mod's own `_loopPathfindDoMove` (4–7 s random interval) does not immediately overwrite it with a player-targeted order.
4. When no cover is detected, the existing player-targeted distance/speed-gated logic is preserved unchanged.

The bloater breach PFH (`fn_bloaterBarricadePFH`) handles the redirect-to-cover step independently at 1 Hz and is unaffected — after this fix, bloaters arrive at the cover object in a consistent navmesh-reachable position, and the breach PFH then redirects or detonates as designed.

### Performance

The cover-target resolution adds 1–2 `lineIntersectsSurfaces` calls per WBK zombie **per 15 s loop cycle** (the same frequency as the existing `doMove`). There is no per-second or per-frame cost. At 50 active zombies the overhead is ~3–6 raycasts every 15 s — completely negligible.

### Files Modified

| File | Change |
|---|---|
| `hostiles/moveHosToPlayer.sqf` | Added cover-target resolution block (two LOS rays at low/torso heights) in WBK zombie branch; `doMove` redirected to blocking `PLAYER_OBJECT_LIST` object when found, otherwise existing gating logic unchanged. |

### Verification Checklist

- Player stands inside a ring of sandbag barricades: zombies advance to the nearest barricade and stop there, not 50m away.
- Bloater inside sandbag ring: bloater arrives at the barricade, breach PFH redirects or detonates within `EJ_BLOATER_DETONATE_RANGE`.
- Player in open field with no cover: zombies target the player directly and WBK direct-drive takes over as before.
- Stuck cleaner: zombies in cover scenarios should no longer trigger `EJ_stuckStrikes` (they are moving toward cover, not stationary).

---

## Hotfix: Early Bloater Preview — Budget Exhaustion & Redundant Preview Wave

**Date:** 2026-04-21
**Status:** Implemented

### Problem

Waves 3 and 4 spawned as pure-bloater waves even though neither was flagged as a bloater rush special wave.

### Root Cause

The early bloater preview injected `attkWave - 1` bloaters (wave 3 → 2, wave 4 → 3) and deducted 8 budget per bloater. Wave budgets at low player counts:

| Wave | Budget (1P) | Injection cost | Remaining |
|---|---|---|---|
| 3 | 12 | 2 × 8 = 16 | -4 |
| 4 | 16 | 3 × 8 = 24 | -8 |

The T1 filler pass is `while { _budget > 0 }`. With a negative remaining budget it exited immediately, leaving only the injected bloaters in the manifest. At 2+ players the budget was large enough to partially obscure the bug.

Two compounding design issues:
1. Two preview waves (3 and 4) are redundant — one is sufficient to introduce the bloater breaching mechanic before formal bloater rush waves begin at wave 10+.
2. No budget clamp after injection meant a negative balance silently broke T1 filler.

### Fix

**`bulwark/functions/fn_startWave.sqf`:** Changed preview gate from `attkWave >= 3 && attkWave < 5` to `attkWave == 3`. Changed count from `attkWave - 1` to the flat value `1`. Wave 4 is now a clean normal mixed wave (T1 + T2 runners, no injected bloaters). Wave 3 gets exactly 1 bloater (cost: 8) against a budget of 12 (1P), leaving 4 for T1 shamblers.

**`hostiles/wbk/fn_buildWaveManifest.sqf`:** Added `_budget = 0 max _budget` after the injection loop. This clamps any hypothetical negative balance to zero, ensuring the T1 filler pass always runs rather than silently returning nothing.

**Performance impact:** None. Path only executes once on wave 3 start.

### Files Modified

| File | Change |
|---|---|
| `bulwark/functions/fn_startWave.sqf` | Preview gate: `attkWave >= 3 && attkWave < 5` → `attkWave == 3`; count: `attkWave - 1` → `1` |
| `hostiles/wbk/fn_buildWaveManifest.sqf` | Added `_budget = 0 max _budget` after injection loop |

### Global Variables

| Variable | Change |
|---|---|
| `EJ_wbk_earlyBloaterCount` | Now always `1` for wave 3, `0` for all other waves |

---

## Hotfix: Death Cam Delay Before Respawn

**Date:** 2026-04-20
**Status:** Complete

### Problem

During a wave, dying players were immediately teleported back to the Bulwark with no delay. This was especially jarring for Smasher/Goliath special execution kills where a cinematic animation was still playing. Players respawning before the animation finished could see themselves being killed mid-finishing-blow.

### Root Cause

`onPlayerKilled.sqf` hard-coded `[0]` as the argument to `setPlayerRespawnTime` on the normal (tickets-remaining) path. This set the respawn countdown to zero seconds, firing `onPlayerRespawn.sqf` almost immediately — which calls `["Terminate"] call BIS_fnc_EGSpectator`, destroying the death spectator that had just been initialized.

The mission already had all required infrastructure:
- `RESPAWN_TIME` lobby parameter defined in `description.ext` (default 10s, options: 0/5/10/20/30)
- `BIS_fnc_EGSpectator` already initialized in `onPlayerKilled.sqf` immediately after the respawn timer is set
- `fn_startWave.sqf` already used `[RESPAWN_TIME]` correctly for the same call

Only the normal-death branch used `[0]` — the no-tickets branch correctly used `[RESPAWN_TIME]`.

### Fix

Changed `[0]` to `[RESPAWN_TIME]` on the normal-death branch. `BIS_fnc_EGSpectator` was then removed entirely in favour of the native Arma 3 death cam (see below). Players now wait the lobby-configured delay (default 10 seconds) in the native orbiting death cam before auto-teleporting to the Bulwark.

Build-phase deaths are unaffected (guarded by `if (!_buildPhase)` which skips the entire block). No-tickets game-over path is unaffected (sets `RESPAWN_TIME = 99999`).

### Revision: Native Arma Death Cam (same hotfix, same date)

`BIS_fnc_EGSpectator` (free-roam spectator) was replaced with Arma 3's built-in death cam. The native cam starts at the corpse and slowly orbits — it activates automatically during the `setPlayerRespawnTime` delay whenever no other camera system is occupying the slot. No replacement code was required; removing the EGSpectator calls was sufficient.

**Why:** The free-roam cam started first-person on the body, and if the player was sprinting at death, the held movement keys caused the camera to rocket forward at full speed. The native cam has no such issue.

### Files Modified

| File | Change |
|---|---|
| `onPlayerKilled.sqf` | `[0] remoteExec ["setPlayerRespawnTime", 0]` → `[RESPAWN_TIME] remoteExec ["setPlayerRespawnTime", 0]`; removed `sleep 0.1` + `BIS_fnc_EGSpectator Initialize` block |
| `onPlayerRespawn.sqf` | Removed `["Terminate"] call BIS_fnc_EGSpectator` |
| `bulwark/functions/fn_startWave.sqf` | Removed `["Terminate"] remoteExec ["BIS_fnc_EGSpectator", 0]` |
| `bulwark/functions/fn_endWave.sqf` | Removed `["Terminate"] remoteExec ["BIS_fnc_EGSpectator", 0]` |

---

## Hotfix: Bloater Rush — exitWith + All-Bloater Composition

**Date:** 2026-04-20  
**Status:** Complete

### Root Cause

`fn_buildWaveManifest.sqf` used `if (cond) then { ... _manifest }` for both override blocks (bloater rush and siege wave). In SQF, this is **not an early return** — the value of `_manifest` inside the `then` block is silently discarded and execution continues past the closing `};`. Both override blocks fell through to the normal T5→T4→T3→T2→T1 allocation, which rebuilt `_manifest` from scratch. The bloater rush produced only the handful of Boomers that normal T3 RNG happened to select.

### Fix

| Block | Change |
|---|---|
| Bloater rush (`~line 50`) | `then {` → `exitWith {`; removed 60/40 split; entire budget now spent on bloaters (`floor(_budget / 8)`) |
| Siege wave (`~line 100`) | `then {` → `exitWith {`; no composition change |

### Files Modified

| File | Change |
|---|---|
| `hostiles/wbk/fn_buildWaveManifest.sqf` | exitWith on both override blocks; bloater rush is now 100% Boomers |

### Variables Removed

| Variable | Was Used For |
|---|---|
| `_bloaterPct` | 60–80% scaling fraction — removed, replaced by full budget |
| `_bloaterBudget` | Fraction of budget for bloaters — removed |
| `_t1Budget` | Remainder budget for T1 horde — removed |
| `_t1Count` | T1 horde unit count — removed |
| `_t1Pool` | T1 registry filter — removed (bloater rush block only) |

---

## Hotfix: Wave-Complete Notification Sometimes Missing

**Date:** 2026-04-23
**Status:** Complete

### Problem

After killing all zombies in a wave, the "Wave N complete!" popup notification (with sound) intermittently failed to appear. Players were left in silence not knowing whether the round was over or if a zombie was stuck somewhere until the 15-second countdown for the next wave began.

### Root Cause Analysis

Two independent root causes:

**RC1 — Drip-feed PFH not stopped at wave end (Primary)**

`fn_spawnWBKWave` queues overflow zombies into `EJ_spawnQueue` when `EJ_MAX_ACTIVE_ZOMBIES` is hit, and the `EJ_dripFeedHandler` CBA PFH drains the queue during the wave. `fn_endWave` stopped `EJ_bloaterPFHHandle` but had no code to stop `EJ_dripFeedHandler` or clear `EJ_spawnQueue`. After the wave-complete notification fired and `fn_endWave` entered its `sleep _downTime`, the still-running PFH saw EAST count = 0 (below cap) and spawned remaining queued zombies into the build phase. These "ghost" zombies were alive when Wave N+1 started, inflating its EAST count. Wave N+1's end-detection (`EAST countSide allUnits == 0`) could not fire until the ghosts also died, delaying or silencing the Wave N+1 notification entirely.

**RC2 — ClearStuck 60-second silence window (Secondary)**

`clearStuck.sqf`'s WBK path requires two consecutive 30-second stall cycles (60s total) before killing a unit. When one zombie gets terrain-stuck and all others die, players see zero visible zombies but the wave-end check does not fire for up to 60 seconds. The notification eventually fires at T=60+, but players have mentally moved on and perceive it as missing.

### Fix

**Phase 1 — Stop drip-feed at wave end (`bulwark/functions/fn_endWave.sqf`)**

Added drip-feed teardown immediately after the existing bloater PFH teardown block, using the identical guard pattern:
```sqf
if (!isNil "EJ_dripFeedHandler" && {EJ_dripFeedHandler >= 0}) then {
    [EJ_dripFeedHandler] call CBA_fnc_removePerFrameHandler;
    EJ_dripFeedHandler = -1;
};
EJ_spawnQueue = [];
```
Discarding the queue at wave end is correct: if all active zombies died before the queue drained, the wave is over and unspawned overflow units are never needed.

**Phase 2 — Fast-path last-zombie kill in clearStuck (`hostiles/clearStuck.sqf`)**

In the WBK stuck-check block, the kill condition was changed from `_strikes >= 2` to also trigger on strike 1 when the zombie is the sole remaining EAST unit:
```sqf
private _isLastUnit = (EAST countSide allUnits == 1);
if (_strikes >= 2 || _isLastUnit) then { _wbkUnit setDamage 1; ... };
```
The recovery `doMove` attempt (strike 1 path) is only worthwhile when other zombies are alive. When a unit is the last one after 30 seconds of being stuck, the priority shifts to ending the wave. This cuts the maximum silence window from 60s to 30s.

### Files Modified

| File | Change |
|---|---|
| `bulwark/functions/fn_endWave.sqf` | Added `EJ_dripFeedHandler` PFH removal + `EJ_spawnQueue = []` after bloater PFH teardown. |
| `hostiles/clearStuck.sqf` | WBK kill condition: `_strikes >= 2 \|\| (EAST countSide allUnits == 1 && _strikes >= 1)`. Updated diag_log to report `_isLastUnit`. |

---

## Enhancement: Player Damage Visual Feedback

**Date:** 2026-04-23 (initial); revised 2026-04-24 (HP bar removed, replaced with persistent red tint)
**Status:** Built, pending in-game test

### Problem

Players could not tell whether they were taking damage. No visual signal fired when hit by WBK zombies. The HUD showed score, wave, and tickets — no health readout.

### Root Cause

Two systems suppressed all feedback:

1. **`WBK_CreateDamage` sub-lethal path** (`fn_initPlayerReviveBridge.sqf`): applies damage via `setDamage [val, false]` — the array form bypasses the `HandleDamage` EH and with it **all vanilla pain/screen effects** (blood vignette, redness). This is the dominant damage path for every zombie melee hit.

2. **`HandleDamage` EH gates** return `0` on most branches (INCAPACITATED, RevByMedikit, environmental). On the non-lethal sub-threshold branch, `bis_fnc_reviveEhHandleDamage` is called but the vanilla redness effect still does not render because the EH chain returns a value before the engine's own visual code runs.
https://app.klingai.com/global/
### Fix

Two complementary effects — an immediate flash and a persistent red tint — together communicate both the instant of impact and the accumulated health deficit.

#### New file: `hostiles/wbk/fn_playerHitEffect.sqf`

Client-side function that displays a brief **chromatic aberration** ppEffect flash on every hit:
- **Intensity formula:** `(0.02 max (_damage * 0.25)) min 0.08` — 2% minimum, 8% maximum
- A typical zombie melee hit (0.15–0.25 damage) produces ~3.75–6.25% lateral color split
- Uses ppEffect priority 1750 (above `fn_ragePack` ChromAberration at 200; below its ColorInversion at 2500)
- Flash commits instantly, holds 0.1 s, then fades to zero over 0.5 s inside a `spawn` block (non-blocking to caller)
- Handle destroyed after fade — zero ppEffect residue

#### New file: `hostiles/wbk/fn_playerDamageTint.sqf`

Client-side function that maintains a **persistent full-screen red overlay** proportional to current health deficit:

**Implementation note — ppEffect abandoned:** The initial implementation used `ColorCorrections` ppEffect with `contrast=0`, which caused a full-screen bright green render bug (Arma 3 internal color pipeline issue when contrast=0). Replaced with a direct GUI control approach which is format-safe.

- Uses `DamageTintOverlay` (idc 99998) — a full-screen `RscStructuredText` control defined in `score/hud.hpp` with `colorBackground[] = {1,0,0,0}` (red, alpha=0 at rest)
- **Alpha formula:** `alpha = (damage player) * 0.25` → range 0.00 (full health) to ~0.22 (near-incapacitation)
- On first call: registers a 1-second CBA PFH (`EJ_dmgTintPFH`) that continuously refreshes the tint — catches all heal sources (Medikit revive, Bulwark heal) without explicit hooks
- `ctrlSetBackgroundColor` + `ctrlCommit 0.4` — smooth 0.4s transition on both damage and healing
- Because `cutRsc` recreates the `KillPointsHud` display on every score update (resetting `DamageTintOverlay` to alpha=0), `killPoints_fnc_updateHud` calls this function at the end of each update to immediately reapply the tint
- Called from: Hook A (WBK melee hit), Hook B (engine-sourced hit), `initPlayerLocal.sqf` (initialise at load), `onPlayerRespawn.sqf` (clear tint on respawn), `fn_updateHud.sqf` (reapply after cutRsc)

#### Hook A — `WBK_CreateDamage` sub-lethal path (`fn_initPlayerReviveBridge.sqf`)

After `_target setDamage [_newDamage, false]`:
```sqf
[_damage] call EJ_fnc_playerHitEffect;
[] call EJ_fnc_playerDamageTint;
```
Covers all regular WBK zombie melee, Smasher melee, Screamer, Bloater melee.

#### Hook B — HandleDamage EH final else branch (`fn_initPlayerReviveBridge.sqf`)

Before `_this call bis_fnc_reviveEhHandleDamage` in the sub-lethal engine-damage path:
```sqf
[_damage] call EJ_fnc_playerHitEffect;
[] call EJ_fnc_playerDamageTint;
```
Covers engine-sourced damage (explosions, non-WBK projectiles).

### Files Modified

| File | Change |
|---|---|
| `hostiles/wbk/fn_playerHitEffect.sqf` | **New file** — client-side ChromAberration flash scaled to damage |
| `hostiles/wbk/fn_playerDamageTint.sqf` | **New file** — persistent GUI overlay red tint scaled to health deficit; includes 1s CBA PFH for heal tracking. (Replaced broken ppEffect ColorCorrections approach.) |
| `hostiles/wbk/Functions.hpp` | Added `class playerHitEffect {};` and `class playerDamageTint {};` to `class wbk` |
| `hostiles/wbk/fn_initPlayerReviveBridge.sqf` | Hook A: flash + tint update after sub-lethal `setDamage [val, false]`; Hook B: flash + tint update in HandleDamage final else branch |
| `score/hud.hpp` | Added `DamageTintOverlay` (idc 99998) full-screen red control as first entry in `controlsBackground` (renders behind score text) |
| `score/functions/fn_updateHud.sqf` | Added `[] call EJ_fnc_playerDamageTint` at end to reapply tint after each `cutRsc` recreates the display |
| `initPlayerLocal.sqf` | Added `[] call EJ_fnc_playerDamageTint` after `call EJ_fnc_initPlayerReviveBridge` |
| `onPlayerRespawn.sqf` | Added `[] call EJ_fnc_playerDamageTint` after `call EJ_fnc_initPlayerReviveBridge` |

### New Global Variables

| Variable | Set By | Scope | Purpose |
|---|---|---|---|
| `EJ_dmgTintPFH` | `fn_playerDamageTint` | Client-local | CBA PFH handle for 1s heal-tracking refresh |

### Performance Notes

- **Hit flash:** created/destroyed per hit (one `spawn` per hit for fade block). Zero server cost.
- **Persistent tint:** `ctrlSetBackgroundColor` + `ctrlCommit 0.4` on every hit (immediate) and every 1s (PFH poll). `damage player` is a single engine read per tick. Negligible overhead.
- **PFH interval:** 1 s — far below the threshold for perceptible lag in the healing response.
- No server involvement. No additional polling beyond the 1s tint PFH.

---

## Enhancement: Paratrooper Whitelisted Gear + Kill Score Attribution

**Date:** 2026-04-25
**Status:** Implemented

### Problem

Two related issues with the existing `paraDrop` support (1950 pts, 3 units):

1. **Gear**: Paratroopers spawned with whatever the random `List_NATO` unit classname brought — uncontrolled loadouts with inconsistent weapons, ammo counts, and no whitelist governance.
2. **Kill scoring**: Kills made by paratrooper AI were never attributed to the calling player. `fn_killed.sqf` only scored when `isPlayer _instigator`; AI-instigated kills silently awarded zero points.

A third issue was also present: the existing `Killed` EH inside `fn_paraTroop.sqf` had a syntax bug — `removeAllWeapons _self:` (colon instead of semicolon), causing an SQF parser error on every paratrooper death.

### Fix

**Whitelist arrays (`editMe.sqf`):** Five new config globals added below `PARATROOP_CLASS`:

| Array | Purpose |
|---|---|
| `PARA_UNIFORMS` | Outfit pool (vanilla A3 NATO combat uniforms) |
| `PARA_VESTS` | Vest pool (plate carriers and tac vests) |
| `PARA_BACKPACKS` | Backpack pool; swapped in after landing |
| `PARA_PRIMARIES` | Primary weapon pool (rifles + LMGs) |
| `PARA_SECONDARIES` | Sidearm pool |

Magazine classnames are not hardcoded — derived at spawn time via `compatibleMagazines`, so the lists remain mod-compatible.

**Spawn loop rewrite (`supports/functions/fn_paraTroop.sqf`):** The inner `for` loop body was replaced with:

1. Full gear strip (`removeAllWeapons`, `removeAllItems`, `removeAllAssignedItems`, `removeUniform`, `removeVest`) before applying whitelisted loadout.
2. Whitelisted outfit, vest, primary weapon + 1 starter mag, secondary weapon + 1 starter mag — all applied **before** `addBackpack "B_Parachute"` so the single starter mag fills uniform/vest slots and cannot overflow into the parachute (critical for large LMG box mags).
3. `EJ_paraOwner` variable set on each unit (broadcast, `true`) so `fn_killed.sqf` can identify the calling player from a server context.
4. Landing detection thread (`spawn`): polls altitude every 2s; on landing (`getPosATL < 1.5m`), swaps `B_Parachute` for a random `PARA_BACKPACKS` entry, then adds 4 more primary mags and 2 more secondary mags — totalling 5 primary / 3 secondary.
5. Killed EH bug fixed: `removeAllWeapons _self:` → `removeAllWeapons _self;`.

**Kill attribution (`score/functions/fn_killed.sqf`):** A third fallback tier was inserted after the existing `EJ_lastScorer` block and before the `if (isPlayer _instigator)` scoring gate:

```sqf
// Fallback: kill made by a paratrooper AI — attribute to the calling player
if (isNull _instigator || {!isPlayer _instigator}) then {
    if (!isNull _instigator) then {
        private _paraOwner = _instigator getVariable ["EJ_paraOwner", objNull];
        if (!isNull _paraOwner && {isPlayer _paraOwner}) then {
            _instigator = _paraOwner;
        };
    };
};
```

All three fallback tiers (WBK `EJ_lastScorer`, paratrooper `EJ_paraOwner`, direct player instigator) feed into the same existing scoring/hitmarker logic — no changes to scoring math were needed.

### Files Modified

| File | Change |
|---|---|
| `editMe.sqf` | Added `PARA_UNIFORMS`, `PARA_VESTS`, `PARA_BACKPACKS`, `PARA_PRIMARIES`, `PARA_SECONDARIES` below `PARATROOP_CLASS` |
| `supports/functions/fn_paraTroop.sqf` | Replaced for-loop body: full gear strip, whitelisted loadout, 1-mag descent load, `EJ_paraOwner` tag, landing-detection spawn thread for backpack swap + ammo top-up, Killed EH colon bug fixed |
| `score/functions/fn_killed.sqf` | Added third fallback tier for `EJ_paraOwner` after `EJ_lastScorer` block |

### New Global Variables

| Variable | Set By | Scope | Purpose |
|---|---|---|---|
| `PARA_UNIFORMS` | `editMe.sqf` | Server + Client global | Whitelist of paratrooper outfit classnames |
| `PARA_VESTS` | `editMe.sqf` | Server + Client global | Whitelist of paratrooper vest classnames |
| `PARA_BACKPACKS` | `editMe.sqf` | Server + Client global | Whitelist of paratrooper backpack classnames (post-landing) |
| `PARA_PRIMARIES` | `editMe.sqf` | Server + Client global | Whitelist of paratrooper primary weapon classnames |
| `PARA_SECONDARIES` | `editMe.sqf` | Server + Client global | Whitelist of paratrooper sidearm classnames |
| `EJ_paraOwner` | `fn_paraTroop.sqf` | Per-unit (`setVariable`, broadcast) | Reference to the player who called the paradrop; read by `fn_killed.sqf` for score attribution |

### Performance Notes

- Landing detection thread: one `spawn` per unit, polls every 2s, executes once on landing then exits. Zero recurring overhead after touchdown.
- `compatibleMagazines` called once per weapon at spawn time, not recurrently.
- `EJ_paraOwner` variable read in `fn_killed.sqf` only when `_instigator` is non-null and non-player — extremely low frequency.
- No new PFHs. No new polling loops. VTOL cinematic unchanged.

---

## Hotfix: Paratrooper Kill Score — AI Hits Not Attributing to Player

**Date:** 2026-04-25
**Status:** Implemented

### Problem

Kills made by paratrooper AI units awarded zero points to the calling player.

### Root Cause

Two-stage blockade:

**Stage 1 — `fn_wbkHitPartScore.sqf` exits early on AI hits:**
The scorer resolver walks `_shooter → _shotParents[1] → _shotParents[0]`, checking `isPlayer` at each step. A paratrooper AI fails every check. The function exits at `if (isNull _scorer || !isPlayer _scorer) exitWith {}` without ever setting `EJ_lastScorer` on the zombie.

**Stage 2 — `fn_killed.sqf`'s `EJ_paraOwner` fallback cannot fire:**
WBK zombies die via scripted `setDamage 1`, which strips the instigator from the MPKilled event (`_instigator = objNull`). The `EJ_paraOwner` fallback added in the previous enhancement is guarded by `if (!isNull _instigator)` — with a null instigator the guard blocks it. Since Stage 1 also prevented `EJ_lastScorer` from being set, the attribution chain has no viable path.

### Fix

Extended the scorer resolver in `fn_wbkHitPartScore.sqf` with a paratrooper fallback block inserted **after** the existing player-resolver and **before** the `exitWith`. When `_scorer` is `objNull`, `_shooter` is checked for `EJ_paraOwner`. If found and the owner is a player, `_scorer` is set to that player. The function then proceeds normally, setting `EJ_lastScorer` on the zombie to the owner player. `fn_killed.sqf`'s existing `EJ_lastScorer` path handles the rest — no other files required changes.

The `EJ_paraOwner` fallback tier in `fn_killed.sqf` remains in place and correctly handles non-WBK enemies where the AI instigator does survive through MPKilled.

### Files Modified

| File | Change |
|---|---|
| `hostiles/wbk/fn_wbkHitPartScore.sqf` | Added paratrooper owner fallback after player-resolver: if `_scorer` is null, check `_shooter getVariable "EJ_paraOwner"` and use it as scorer |
