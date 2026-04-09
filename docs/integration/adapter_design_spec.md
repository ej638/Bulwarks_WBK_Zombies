# WBK-Bulwarks Integration Factory — Adapter Design Specification

**Role:** Senior Arma 3 Systems Architect  
**Date:** 2026-04-09  
**Status:** Design complete, pending implementation  
**Scope:** Middleware spawning factory that replaces vanilla Bulwarks unit selection with a weighted, budget-based WBK zombie system.

---

## Table of Contents

1. [Architectural Conflict Resolution](#1-architectural-conflict-resolution)
2. [Weight-Class Budget System](#2-weight-class-budget-system)
3. [Scoring & State Synchronization](#3-scoring--state-synchronization)
4. [Performance Guardrails](#4-performance-guardrails)
5. [Pseudocode Prototype — `EJ_fnc_spawnWBKWave`](#5-pseudocode-prototype--ej_fnc_spawnwbkwave)
6. [Migration Checklist](#6-migration-checklist)

---

## 1. Architectural Conflict Resolution

### 1.1 Problem Statement

Bulwarks creates vanilla Arma infantry via `createUnit` inside `hostiles/spawnSquad.sqf`, then attaches `Hit`/`Killed` event handlers for scoring. WBK zombies require three mandatory `setVariable` calls (`WBK_AI_ISZombie`, `WBK_SynthHP`, `WBK_AI_ZombieMoveSet`) and run custom AI scripts that **override the Arma damage model entirely** — calling `allowDamage false` every tick and using a synthetic HP pool decremented via `HitPart` event handlers.

If we simply swap classnames without initialisation, the zombies are "brain dead": no AI scripts fire, no synthetic HP is set, and the units stand idle.

### 1.2 The Auto-Init Mechanism — Why It Already Works

**Critical finding:** All WBK zombie classnames define `Extended_InitPost_EventHandlers` in their `config.cpp`. When `createUnit` instantiates a WBK class, the engine **automatically** fires the init handler on the machine that owns the unit (the server, for server-created units). Examples:

| Unit Type | Classname (EAST) | Auto-Fired Script |
|---|---|---|
| Crawler | `Zombie_O_Crawler_CSAT` | `[_unit, true] execVM "\WBK_Zombies\AI\WBK_AI_Walker.sqf"` |
| Walker | `Zombie_O_Walker_CSAT` | `[_unit, false] execVM "\WBK_Zombies\AI\WBK_AI_Walker.sqf"` |
| Shambler | `Zombie_O_Shambler_CSAT` | `_unit execVM "\WBK_Zombies\AI\WBK_AI_Middle.sqf"` |
| Runner (Calm) | `Zombie_O_RunnerCalm_CSAT` | `[_unit, true, false] execVM "\WBK_Zombies\AI\WBK_AI_Runner.sqf"` |
| Runner (Angry) | `Zombie_O_RunnerAngry_CSAT` | `[_unit, false, false] execVM "\WBK_Zombies\AI\WBK_AI_Runner.sqf"` |
| Triggerman | `Zombie_O_Shooter_CSAT` | `_unit execVM "\WBK_Zombies\AI\WBK_ShooterZombie.sqf"` |
| Bloater | `Zombie_Special_OPFOR_Boomer` | `_unit execVM "\WBK_Zombies\AI\WBK_AI_ZombieExplosion.sqf"` |
| Screamer | `Zombie_Special_OPFOR_Screamer` | `_unit execVM "\WBK_Zombies\AI\WBK_AI_Stunden.sqf"` |
| Leaper | `Zombie_Special_OPFOR_Leaper_1` | `_unit execVM "\WBK_Zombies\AI\WBK_AI_Tatzelwurm.sqf"` |
| Melee Zombie | *(via Zeus action)* | `_unit execVM "\WBK_Zombies\AI\Ai_Melee_Zombie.sqf"` |
| Smasher | `WBK_SpecialZombie_Smasher_2` | `_unit execVM "\WBK_Zombies_Smasher\AI\WBK_AI_Smasher.sqf"` |
| Goliath | `WBK_Goliaph_1` | `_unit execVM "\WBK_Zombies_Goliath\AI\WBK_Goliath_AI.sqf"` |
| Corrupted | `WBK_SpecialZombie_Corrupted_2` | `_unit execVM "\WBK_Zombies_Corrupted\AI\WBK_AI_CorruptedHead.sqf"` |

**Therefore: The adapter does NOT need to manually call AI scripts or set WBK variables.** Using the correct classname with `createUnit` is sufficient — `Extended_InitPost` handles initialisation automatically. Each AI script internally sets `WBK_AI_ISZombie`, `WBK_SynthHP`, `WBK_AI_ZombieMoveSet`, and registers all PFH handlers.

### 1.3 The Exact Hook Point

**File:** `hostiles/createWave.sqf`  
**Location:** The three `for` loops that call `execVM "hostiles/spawnSquad.sqf"`.

The adapter replaces the infantry spawning section of `createWave.sqf`. The vehicle spawning prefix (armour/cars) remains untouched for now — vehicle waves are orthogonal to zombie integration.

**Before (vanilla):**
```sqf
// Level 1 SQUADS
for "_i" from 1 to (floor (attkWave * _multiplierBase)) do {
    _script = [HOSTILE_LEVEL_1, attkWave, _noOfPlayers, HOSTILE_LEVEL_1_POINT_SCORE]
        execVM "hostiles\spawnSquad.sqf";
    waitUntil {scriptDone _script};
};
// Level 2 SQUADS (wave 6+), Level 3 SQUADS (wave 12+) ...
```

**After (adapter):**
```sqf
// Replace entire infantry section with budget-based WBK spawning
[attkWave, _noOfPlayers, _multiplierBase] call EJ_fnc_spawnWBKWave;
```

The adapter consumes `attkWave`, player count, and the multiplier base — then internally manages the zombie type selection, budget allocation, staggered spawning, and scoring bridge.

### 1.4 Side Requirement

Bulwarks detects wave completion via `EAST countSide allUnits == 0`. All WBK classnames used must be **EAST (side 1)**:

| Type | Required Classname |
|---|---|
| Standard Zombies | `Zombie_O_*_CSAT` variants (side=1) |
| Special Infected | `Zombie_Special_OPFOR_*` variants (side=1) |
| Smasher | `WBK_SpecialZombie_Smasher_2` (side=1) |
| Goliath | `WBK_Goliaph_1` (side=1) |
| Corrupted | `WBK_SpecialZombie_Corrupted_2` (side=1) |

### 1.5 Weapon Stripping

Vanilla Bulwarks applies weapon randomisation, pistol-only phases, and suicide wave weapon stripping. **None of these apply to WBK zombies.** The WBK AI scripts internally strip weapons and apply melee-only behaviour. The adapter must **not** run any weapon logic on spawned WBK units. Suicide wave and defector wave modifiers are incompatible with zombies and should be skipped (see §2.5).

---

## 2. Weight-Class Budget System

### 2.1 Tier Definitions

All zombie types are grouped into four weight classes. Each class has a **budget cost**, point multiplier, and population constraints.

| Weight Class | Tier | Budget Cost | Point Multiplier | Max Per Wave | Cooldown (Waves) |
|---|---|---|---|---|---|
| **Horde** | T1 | 1 | 0.50 | Unlimited | — |
| **Horde** | T1 | 1 | 0.50 | Unlimited | — |
| **Pack** | T2 | 3 | 1.00 | Unlimited | — |
| **Elite** | T3 | 8 | 2.00 | 4 | — |
| **Mini-Boss** | T4 | 25 | 4.00 | 2 | 3 |
| **Boss** | T5 | 60 | 8.00 | 1 | 5 |

### 2.2 Unit Registry — `EJ_wbk_unit_registry`

A global array-of-arrays initialised at mission start. Each entry is a tuple:

```sqf
// [className, tier, budgetCost, pointMulti, aiScriptAuto, minWave]
EJ_wbk_unit_registry = [
    // ── T1: HORDE (cannon fodder) ──
    ["Zombie_O_Crawler_CSAT",       1,  1,  0.50, true,  1],
    ["Zombie_O_Walker_CSAT",        1,  1,  0.50, true,  1],
    ["Zombie_O_Shambler_CSAT",      1,  1,  0.50, true,  1],

    // ── T2: PACK (fast threats) ──
    ["Zombie_O_RunnerCalm_CSAT",    2,  3,  1.00, true,  3],
    ["Zombie_O_RunnerAngry_CSAT",   2,  3,  1.00, true,  5],
    ["Zombie_O_Shooter_CSAT",       2,  3,  1.00, true,  4],

    // ── T3: ELITE (special infected) ──
    ["Zombie_Special_OPFOR_Boomer", 3,  8,  2.00, true,  7],
    ["Zombie_Special_OPFOR_Screamer",3, 8,  2.00, true,  8],
    ["Zombie_Special_OPFOR_Leaper_1",3, 8,  2.00, true,  9],
    ["Zombie_Special_OPFOR_Leaper_2",3, 8,  2.00, true,  9],

    // ── T4: MINI-BOSS (Smasher variants — heavy PFH cost) ──
    ["WBK_SpecialZombie_Smasher_2",         4, 25, 4.00, true, 10],
    ["WBK_SpecialZombie_Smasher_Acid_2",    4, 25, 4.00, true, 14],
    ["WBK_SpecialZombie_Smasher_Hellbeast_2",4, 25, 4.00, true, 18],

    // ── T5: BOSS (Goliath — extreme PFH cost) ──
    ["WBK_Goliaph_1",              5, 60, 8.00, true, 15]
];
```

> **Note:** Corrupted Head (`WBK_SpecialZombie_Corrupted_2`) is omitted from the standard registry because it has a unique player-conversion mechanic that requires explicit opt-in. It can be added as a special-wave-only spawn in a future iteration.

### 2.3 Wave Budget Formula

The total budget available for a wave scales with wave number and player count:

$$\text{waveBudget} = \left\lfloor \text{baseBudget} + (\text{attkWave} \times \text{waveScale}) + (\text{playerCount} \times \text{playerScale}) \right\rfloor$$

| Parameter | Value | Rationale |
|---|---|---|
| `baseBudget` | 8 | Minimum viable wave (8 crawlers) |
| `waveScale` | 4 | Linear ramp — each wave adds ~4 T1 units worth of budget |
| `playerScale` | 6 | Each additional player adds ~6 T1 equivalent |

**Example budgets:**

| Wave | Players | Budget | Approx. Composition |
|---|---|---|---|
| 1 | 4 | 36 | 36× T1 horde |
| 5 | 4 | 52 | 40× T1 + 4× T2 |
| 10 | 4 | 72 | 30× T1 + 8× T2 + 1× T3 + 1× T4 (Smasher) |
| 15 | 4 | 92 | 20× T1 + 10× T2 + 2× T3 + 1× T4 + 1× T5 (Goliath) |
| 20 | 8 | 136 | variable mix, all tiers active |

### 2.4 Weighted Selection Algorithm

Budget is spent top-down from the highest affordable tier to the lowest ("spend the big coins first"):

```
1. Resolve available tiers for this wave (filter by minWave).
2. FOR EACH tier from T5 down to T1:
     a. Check "Max Per Wave" cap for this tier.
     b. Check "Cooldown" — skip if tier was last used within cooldown window.
     c. Roll a probability gate:
          T5: 40% chance if budget ≥ cost AND wave ≥ minWave
          T4: 60% chance if budget ≥ cost AND wave ≥ minWave
          T3: 80% chance if budget ≥ cost AND wave ≥ minWave
          T2: 90% chance if budget ≥ cost AND wave ≥ minWave
          T1: always
     d. If accepted: select a random classname from this tier's pool,
        deduct cost from budget, increment tier count.
     e. If rejected or capped: fall through to next lower tier.
3. WHILE remaining budget > 0:
     Spend remaining budget on T1 units (cost 1 each).
4. Return spawn manifest: array of [className, pointMulti] tuples.
```

### 2.5 Cooldown & Cap Tracking

Two global variables track boss spawning:

```sqf
EJ_wavesSinceSmasher = 0;    // Incremented each wave; reset to 0 when a Smasher spawns
EJ_wavesSinceGoliath = 0;    // Incremented each wave; reset to 0 when a Goliath spawns
EJ_smasherThisWave   = 0;    // Per-wave counter, reset at wave start
EJ_goliathThisWave   = 0;    // Per-wave counter, reset at wave start
```

| Tier | Max/Wave | Cooldown | Gate |
|---|---|---|---|
| T4 (Smasher) | 2 | 3 waves | `EJ_smasherThisWave < 2 AND EJ_wavesSinceSmasher >= 3` |
| T5 (Goliath) | 1 | 5 waves | `EJ_goliathThisWave < 1 AND EJ_wavesSinceGoliath >= 5` |

### 2.6 Incompatible Special Wave Handling

Several Bulwarks special wave modifiers are gun-centric and incompatible with melee zombies:

| Special Wave | Disposition | Rationale |
|---|---|---|
| `suicideWave` | **Replace** with "Bloater Rush" | Bloaters already explode. Spawn 60% Bloaters, 40% T1. |
| `defectorWave` | **Skip** (treat as normal wave) | No "friendly-looking" zombies concept. |
| `demineWave` | **Keep as-is** | Drones are independent of infantry classnames. |
| `fogWave` | **Keep as-is** | Cosmetic modifier, fully compatible. |
| `nightWave` | **Keep as-is** | Cosmetic modifier, fully compatible. |
| `specCivs` | **Keep as-is** | Civilian spawning is independent of hostile infantry. |
| `specMortarWave` | **Skip** (treat as normal wave) | Mortar crews are vanilla soldiers, not zombies. |
| `swticharooWave` | **Replace** with "Breach Horde" | Spawn T1/T2 directly around `bulwarkBox` using same positioning. |

---

## 3. Scoring & State Synchronization

### 3.1 The Problem

Bulwarks attaches two event handlers to every spawned unit:

```sqf
_unit addEventHandler ["Hit",    killPoints_fnc_hit];     // Accumulate damage score
_unit addEventHandler ["Killed", killPoints_fnc_killed];  // Award kill score
```

WBK zombies call `allowDamage false` **every tick** inside `_actFr`. This means:

- **`Killed` EH:** Still fires correctly. When `WBK_SynthHP` reaches ≤ 0, the WBK `HitPart` handler calls `[_target, [1, false, _shooter]] remoteExec ["setDamage", 2]`. This forces `setDamage 1` on the server, which kills the unit and fires the `Killed` EH chain. The Bulwarks `fn_killed.sqf` will execute and award kill score. **No bridge needed for kills.**

- **`Hit` EH:** Broken. With `allowDamage false`, Arma's `Hit` event either does not fire or fires with `_dmg = 0`. The accumulated damage points in `_unit getVariable "points"` will be empty. Players lose the damage-scoring component.

### 3.2 Solution: HitPart-to-Score Bridge

We inject a **wrapper function** that the adapter attaches as an additional `HitPart` EH alongside the WBK one (or the WBK auto-attached one). When the WBK `HitPart` detects non-zero damage to `WBK_SynthHP`, we fire the Bulwarks scoring logic manually.

**New function: `EJ_fnc_wbkHitPartScoreBridge`**

```sqf
/*
 * EJ_fnc_wbkHitPartScoreBridge
 *
 * Attached as a HitPart EH to every WBK zombie spawned by the adapter.
 * Bridges WBK synthetic damage into the Bulwarks scoring pipeline.
 *
 * The WBK AI scripts auto-attach their own HitPart EH via Extended_InitPost.
 * This bridge is additive — it does not replace or interfere with WBK logic.
 */
EJ_fnc_wbkHitPartScoreBridge = {
    params ["_target", "_shooter", "_projectile", "_position",
            "_velocity", "_selection", "_ammo", "_unit", "_instigator"];

    if (!isServer) exitWith {};

    // Resolve instigator — _instigator may be objNull for indirect fire
    private _scorer = if (!isNull _instigator) then { _instigator } else { _shooter };
    if (!isPlayer _scorer) exitWith {};

    // Calculate the damage this hit dealt to SynthHP
    // (mirror the WBK headshot/body logic, simplified)
    private _baseDmg = _ammo select 0;  // ammo config hit value
    private _isHeadshot = (_selection select 0) in ["head", "neck", "face_hub"];
    private _effectiveDmg = if (_isHeadshot) then {
        _baseDmg * WBK_Zombies_HeadshotMP
    } else {
        _baseDmg
    };

    // Normalise to 0–1 range for fn_hit compatibility
    // WBK_SynthHP pools range from 30 (Walker) to 15000 (Goliath)
    private _maxHP = _target getVariable ["EJ_wbk_maxHP", 50];
    private _normDmg = (_effectiveDmg / _maxHP) min 1;

    // Invoke Bulwarks scoring manually
    private _scoreVal = SCORE_HIT + (SCORE_DAMAGE_BASE * _normDmg);
    [_scorer, _scoreVal] call killPoints_fnc_add;

    // Accumulate into the points array for kill bonus
    private _pointsArr = _target getVariable ["points", []];
    _pointsArr pushBack _scoreVal;
    _target setVariable ["points", _pointsArr];

    // Fire hit marker on the player's client
    [_target, round _scoreVal, [0.1, 1, 0.1]]
        remoteExec ["killPoints_fnc_hitMarker", _scorer];
};
```

### 3.3 Attachment Timing

The bridge EH must be attached **after** the WBK AI script's `Extended_InitPost` handler has finished, to avoid race conditions. The adapter uses a deferred attachment:

```sqf
// In the per-unit spawn loop (see §5):
_unit addEventHandler ["HitPart", EJ_fnc_wbkHitPartScoreBridge];
```

Since `Extended_InitPost` fires synchronously during `createUnit`, and our adapter code runs after `createUnit` returns, the WBK EH is already attached. Adding ours afterwards is safe — both fire in registration order.

### 3.4 Max HP Snapshot for Normalisation

The bridge needs to know the unit's max HP to normalise damage. Since WBK AI scripts set `WBK_SynthHP` during init, we snapshot it immediately after spawn:

```sqf
// After createUnit + waitUntil not null:
[_unit, {
    _this setVariable ["EJ_wbk_maxHP", _this getVariable ["WBK_SynthHP", 50]];
}] remoteExec ["call", 2];  // Execute on server after init completes
```

However, since `Extended_InitPost` uses `execVM` (async script execution), `WBK_SynthHP` may not be set yet when our line runs. The robust approach is a waitUntil guard:

```sqf
[_unit] spawn {
    params ["_u"];
    waitUntil { !isNil { _u getVariable "WBK_SynthHP" } };
    _u setVariable ["EJ_wbk_maxHP", _u getVariable "WBK_SynthHP"];
};
```

### 3.5 Wave-End Detection — No Changes Needed

Bulwarks detects wave completion via `EAST countSide allUnits == 0`. All WBK classnames in the registry are EAST side. When a zombie's `WBK_SynthHP` drops to zero, the `setDamage 1` call kills it, removing it from `allUnits`. The wave-end detection pipeline is fully compatible without modification.

### 3.6 Body Cleanup Compatibility

Bodies are tracked in `waveUnits[0]`. The adapter appends each spawned unit to this array identically to vanilla `spawnSquad.sqf`. The existing 3-wave sliding window cleanup in `fn_startWave.sqf` deletes these objects normally. WBK's `Killed`/`Deleted` event handlers clean up CBA PFH handles, so deletion of dead units is safe.

---

## 4. Performance Guardrails

### 4.1 The Threat

WBK zombie AI is **vastly** more expensive than vanilla Arma AI. Each non-Shooter zombie registers 3 CBA per-frame handlers:

| Handler | Horde T1 Freq | Leaper T3 Freq | Smasher T4 Freq | Goliath T5 Freq |
|---|---|---|---|---|
| `_actFr` | 0.1–0.5 s | 0.1 s | 0.3 s | 0.5 s |
| `_loopPathfind` | 0.1 s | **0.01 s** | **0.01 s** | **0.01 s** |
| `_loopPathfindDoMove` | 4–10 s | 2.4 s | 2.4 s | 2.4 s |

Spawning 50 T1 zombies simultaneously means 150 PFH registrations in one frame — a guaranteed server hitch.

### 4.2 Spawning Throttle: Staggered Batch System

The adapter spawns units in **batches** with configurable inter-batch delays:

```sqf
EJ_SPAWN_BATCH_SIZE    = 4;     // Units per batch
EJ_SPAWN_BATCH_DELAY   = 0.5;   // Seconds between batches
EJ_SPAWN_BOSS_DELAY    = 2.0;   // Extra delay after spawning a T4/T5 unit
```

**Rationale:**
- 4 units per batch × 3 PFH = 12 PFH registrations per 0.5s tick — light load.
- A 50-unit wave takes `(50 / 4) × 0.5 = 6.25 seconds` to fully spawn.
- Boss units get an extra 2-second gap to allow their expensive init (PFH, hitbox attachment, `remoteExec` broadcasts) to settle.

### 4.3 Active Unit Cap

A hard ceiling prevents runaway AI load on the server:

```sqf
EJ_MAX_ACTIVE_ZOMBIES = 60;    // Includes all tiers
EJ_MAX_ACTIVE_T3_PLUS = 6;     // T3 + T4 + T5 combined
```

During the spawn loop, if `EAST countSide allUnits >= EJ_MAX_ACTIVE_ZOMBIES`, the remaining budget is **banked** and units are spawned as existing ones die (drip-feed). This is implemented as a secondary CBA PFH that monitors the live count and spawns from a queue:

```sqf
EJ_spawnQueue = [];  // Array of [className, pointMulti] waiting to enter the world

// Drip-feed PFH — registered once per wave, removed at wave end
EJ_dripFeedHandler = [{
    if (count EJ_spawnQueue == 0) exitWith {};
    if (EAST countSide allUnits >= EJ_MAX_ACTIVE_ZOMBIES) exitWith {};

    private _batch = EJ_spawnQueue deleteRange [0, EJ_SPAWN_BATCH_SIZE min count EJ_spawnQueue];
    {
        _x params ["_class", "_pointMulti"];
        [_class, _pointMulti] call EJ_fnc_spawnSingleZombie;
    } forEach _batch;
}, EJ_SPAWN_BATCH_DELAY] call CBA_fnc_addPerFrameHandler;
```

### 4.4 Goliath-Specific Restrictions

The Goliath's `_loopPathfind` runs at **100 Hz (0.01s)** with `lineIntersectsSurfaces` per tick. Combined with its hitbox proxy entity, one Goliath costs approximately as much as 15–20 regular zombies. Restrictions:

- **Maximum 1 Goliath alive at any time** (enforced by T5 max-per-wave = 1 AND active count check).
- **5-wave cooldown** minimum between Goliath spawns.
- Goliath is always spawned **last** in the wave, after all other units are active and their PFH registrations have stabilised.

### 4.5 Headless Client Distribution

If headless clients (`entities "HeadlessClient_F"`) are present, the adapter should transfer ownership of T3+ units to a headless client after spawn. Standard Arma `setOwner` won't work for AI that uses local-only event handlers. Instead, the `Extended_InitPost` guard `if (local _unit)` in the config.cpp init strings means the AI script runs on whatever machine **creates** the unit. For HC support, create the unit on the HC:

```sqf
// Future HC extension — not in initial release
private _hcs = entities "HeadlessClient_F";
if (count _hcs > 0 && _tier >= 3) then {
    private _hc = _hcs select (EJ_hcRoundRobin % count _hcs);
    [_class, _location, _group] remoteExec ["EJ_fnc_createUnitOnHC", owner _hc];
    EJ_hcRoundRobin = EJ_hcRoundRobin + 1;
};
```

This is documented as a **Phase 2** optimisation and is not part of the initial adapter.

---

## 5. Pseudocode Prototype — `EJ_fnc_spawnWBKWave`

### 5.1 Registry Initialisation (called once from `initServer.sqf`)

```sqf
// ──────────────────────────────────────────────────────────
// EJ_fnc_initWBKRegistry
// Called once from initServer.sqf after locationLists.sqf
// ──────────────────────────────────────────────────────────
EJ_fnc_initWBKRegistry = {
    // [className, tier, cost, pointMulti, autoInit, minWave]
    EJ_wbk_unit_registry = [
        // T1: HORDE
        ["Zombie_O_Crawler_CSAT",        1, 1,  0.50, true,  1],
        ["Zombie_O_Walker_CSAT",         1, 1,  0.50, true,  1],
        ["Zombie_O_Shambler_CSAT",       1, 1,  0.50, true,  1],

        // T2: PACK
        ["Zombie_O_RunnerCalm_CSAT",     2, 3,  1.00, true,  3],
        ["Zombie_O_RunnerAngry_CSAT",    2, 3,  1.00, true,  5],
        ["Zombie_O_Shooter_CSAT",        2, 3,  1.00, true,  4],

        // T3: ELITE
        ["Zombie_Special_OPFOR_Boomer",  3, 8,  2.00, true,  7],
        ["Zombie_Special_OPFOR_Screamer",3, 8,  2.00, true,  8],
        ["Zombie_Special_OPFOR_Leaper_1",3, 8,  2.00, true,  9],
        ["Zombie_Special_OPFOR_Leaper_2",3, 8,  2.00, true,  9],

        // T4: MINI-BOSS
        ["WBK_SpecialZombie_Smasher_2",          4, 25, 4.00, true, 10],
        ["WBK_SpecialZombie_Smasher_Acid_2",     4, 25, 4.00, true, 14],
        ["WBK_SpecialZombie_Smasher_Hellbeast_2", 4, 25, 4.00, true, 18],

        // T5: BOSS
        ["WBK_Goliaph_1",               5, 60, 8.00, true, 15]
    ];

    // Cooldown trackers
    EJ_wavesSinceSmasher = 99;   // Allow first-eligible-wave spawn
    EJ_wavesSinceGoliath = 99;
    EJ_spawnQueue        = [];
    EJ_dripFeedHandler   = -1;

    // Performance caps
    EJ_SPAWN_BATCH_SIZE  = 4;
    EJ_SPAWN_BATCH_DELAY = 0.5;
    EJ_SPAWN_BOSS_DELAY  = 2.0;
    EJ_MAX_ACTIVE_ZOMBIES = 60;
    EJ_MAX_ACTIVE_T3_PLUS = 6;

    // Budget formula parameters
    EJ_BUDGET_BASE        = 8;
    EJ_BUDGET_WAVE_SCALE  = 4;
    EJ_BUDGET_PLAYER_SCALE = 6;

    diag_log "[EJ] WBK Unit Registry initialised.";
};
```

### 5.2 Manifest Builder — `EJ_fnc_buildWaveManifest`

```sqf
// ──────────────────────────────────────────────────────────
// EJ_fnc_buildWaveManifest
// Builds a spawn manifest (array of [className, pointMulti])
// from the budget system.
//
// Params: [_waveNum, _playerCount]
// Returns: Array of [className, pointMulti]
// ──────────────────────────────────────────────────────────
EJ_fnc_buildWaveManifest = {
    params ["_waveNum", "_playerCount"];

    private _budget = floor (EJ_BUDGET_BASE
                           + (_waveNum * EJ_BUDGET_WAVE_SCALE)
                           + (_playerCount * EJ_BUDGET_PLAYER_SCALE));

    private _manifest = [];
    private _t3Count  = 0;
    private _t4Count  = 0;
    private _t5Count  = 0;

    // ── Pass 1: High-tier selection (T5 → T3) ──
    private _tiersToCheck = [5, 4, 3];
    {
        private _tier = _x;

        // Eligible entries for this tier and wave
        private _pool = EJ_wbk_unit_registry select {
            (_x select 1) == _tier AND { _waveNum >= (_x select 5) }
        };
        if (count _pool == 0) then { continue };

        // Per-tier caps and cooldown checks
        private _maxThisWave = switch (_tier) do {
            case 5: { 1 };
            case 4: { 2 };
            case 3: { 4 };
            default { 999 };
        };

        private _cooldownMet = switch (_tier) do {
            case 5: { EJ_wavesSinceGoliath >= 5 };
            case 4: { EJ_wavesSinceSmasher >= 3 };
            default { true };
        };
        if (!_cooldownMet) then { continue };

        // T3+ combined cap
        private _combinedT3Plus = _t3Count + _t4Count + _t5Count;

        // Probability gate per tier
        private _rollChance = switch (_tier) do {
            case 5: { 0.40 };
            case 4: { 0.60 };
            case 3: { 0.80 };
            default { 1.0 };
        };

        private _tierCount = 0;

        while {
            _budget >= ((_pool select 0) select 2)
            AND { _tierCount < _maxThisWave }
            AND { (_combinedT3Plus + _tierCount) < EJ_MAX_ACTIVE_T3_PLUS }
            AND { random 1 < _rollChance }
        } do {
            private _entry = selectRandom _pool;
            _entry params ["_class", "", "_cost", "_pointMulti"];
            _budget = _budget - _cost;
            _manifest pushBack [_class, _pointMulti];
            _tierCount = _tierCount + 1;
        };

        // Update counters
        switch (_tier) do {
            case 5: { _t5Count = _t5Count + _tierCount };
            case 4: { _t4Count = _t4Count + _tierCount };
            case 3: { _t3Count = _t3Count + _tierCount };
        };
    } forEach _tiersToCheck;

    // ── Pass 2: T2 fill ──
    private _t2Pool = EJ_wbk_unit_registry select {
        (_x select 1) == 2 AND { _waveNum >= (_x select 5) }
    };

    if (count _t2Pool > 0) then {
        private _t2Cost = (_t2Pool select 0) select 2;  // All T2 cost the same
        while { _budget >= _t2Cost AND { random 1 < 0.9 } } do {
            private _entry = selectRandom _t2Pool;
            _budget = _budget - (_entry select 2);
            _manifest pushBack [_entry select 0, _entry select 3];
        };
    };

    // ── Pass 3: T1 remainder ──
    private _t1Pool = EJ_wbk_unit_registry select {
        (_x select 1) == 1 AND { _waveNum >= (_x select 5) }
    };

    while { _budget > 0 AND { count _t1Pool > 0 } } do {
        private _entry = selectRandom _t1Pool;
        _budget = _budget - (_entry select 2);
        _manifest pushBack [_entry select 0, _entry select 3];
    };

    // ── Update cooldown trackers ──
    if (_t4Count > 0) then { EJ_wavesSinceSmasher = 0 } else { EJ_wavesSinceSmasher = EJ_wavesSinceSmasher + 1 };
    if (_t5Count > 0) then { EJ_wavesSinceGoliath = 0 } else { EJ_wavesSinceGoliath = EJ_wavesSinceGoliath + 1 };

    diag_log format ["[EJ] Wave %1 manifest: %2 units (T1:%3 T2:%4 T3:%5 T4:%6 T5:%7), remaining budget: %8",
        _waveNum, count _manifest,
        { (_x select 0) in ["Zombie_O_Crawler_CSAT","Zombie_O_Walker_CSAT","Zombie_O_Shambler_CSAT"] } count _manifest,
        { (_x select 0) in ["Zombie_O_RunnerCalm_CSAT","Zombie_O_RunnerAngry_CSAT","Zombie_O_Shooter_CSAT"] } count _manifest,
        _t3Count, _t4Count, _t5Count, _budget];

    _manifest
};
```

### 5.3 Single Unit Spawner — `EJ_fnc_spawnSingleZombie`

```sqf
// ──────────────────────────────────────────────────────────
// EJ_fnc_spawnSingleZombie
// Spawns one WBK zombie with all Bulwarks integration hooks.
//
// Params: [_className, _pointMulti]
// Returns: unit object
// ──────────────────────────────────────────────────────────
EJ_fnc_spawnSingleZombie = {
    params ["_className", "_pointMulti"];

    // ── Spawn position ──
    private _location = [bulwarkCity,
        BULWARK_RADIUS + 30,
        BULWARK_RADIUS + 150,
        1, 0
    ] call BIS_fnc_findSafePos;

    // ── Create unit ──
    private _group = createGroup [EAST, true];
    private _unit = _group createUnit [_className, _location, [], 0.5, "FORM"];

    if (isNull _unit) exitWith {
        diag_log format ["[EJ] ERROR: Failed to create %1", _className];
        objNull
    };

    // ── Initial movement order ──
    _unit doMove (getPos (selectRandom playableUnits));

    // ── Bulwarks scoring integration ──
    // Killed EH — fires when WBK setDamage 1 triggers death
    _unit addEventHandler ["Killed", killPoints_fnc_killed];
    _unit setVariable ["killPointMulti", _pointMulti];
    _unit setVariable ["points", []];

    // HitPart bridge — replaces broken Hit EH for damage scoring
    _unit addEventHandler ["HitPart", EJ_fnc_wbkHitPartScoreBridge];

    // Snapshot max HP for score normalisation (deferred — waits for AI init)
    [_unit] spawn {
        params ["_u"];
        private _timeout = diag_tickTime + 5;
        waitUntil {
            !isNil { _u getVariable "WBK_SynthHP" }
            OR { diag_tickTime > _timeout }
        };
        _u setVariable ["EJ_wbk_maxHP",
            _u getVariable ["WBK_SynthHP", 50]];
    };

    // ── Zeus visibility ──
    mainZeus addCuratorEditableObjects [[_unit], true];

    // ── Wave tracking ──
    (waveUnits select 0) pushBack _unit;

    _unit
};
```

### 5.4 Main Entry Point — `EJ_fnc_spawnWBKWave`

```sqf
// ──────────────────────────────────────────────────────────
// EJ_fnc_spawnWBKWave
// Replaces the infantry section of createWave.sqf.
// Called from createWave.sqf in place of the spawnSquad loops.
//
// Params: [_waveNum, _playerCount, _multiplierBase]
//   _multiplierBase: currently unused (budget system replaces it)
//                    but accepted for call-site compatibility.
// ──────────────────────────────────────────────────────────
EJ_fnc_spawnWBKWave = {
    params ["_waveNum", "_playerCount", ["_multiplierBase", 1]];

    // ── Build the manifest ──
    private _manifest = [_waveNum, _playerCount] call EJ_fnc_buildWaveManifest;

    // ── Sort: T1/T2 first, bosses last ──
    // This ensures the server absorbs cheap PFH load first,
    // then adds expensive units after stabilisation.
    _manifest sort true;  // Alphabetical is good enough — boss classes sort later

    // Better: explicit tier-based sort
    private _sorted = [];
    { if ((_x select 1) <= 1.0)  then { _sorted pushBack _x } } forEach _manifest;  // T1 (0.50)
    { if ((_x select 1) > 1.0 AND (_x select 1) <= 1.5) then { _sorted pushBack _x } } forEach _manifest;  // T2 (1.00)
    { if ((_x select 1) > 1.5 AND (_x select 1) <= 3.0) then { _sorted pushBack _x } } forEach _manifest;  // T3 (2.00)
    { if ((_x select 1) > 3.0 AND (_x select 1) <= 5.0) then { _sorted pushBack _x } } forEach _manifest;  // T4 (4.00)
    { if ((_x select 1) > 5.0)  then { _sorted pushBack _x } } forEach _manifest;  // T5 (8.00)

    // ── Immediate batch spawning (up to active cap) ──
    private _spawnedCount = 0;
    private _batchCount   = 0;
    private _remaining    = [];

    {
        _x params ["_class", "_pointMulti"];

        // Check active cap
        if (EAST countSide allUnits >= EJ_MAX_ACTIVE_ZOMBIES) then {
            // Overflow → queue for drip-feed
            _remaining pushBack _x;
        } else {
            [_class, _pointMulti] call EJ_fnc_spawnSingleZombie;
            _spawnedCount = _spawnedCount + 1;
            _batchCount   = _batchCount + 1;

            // ── Throttle ──
            if (_batchCount >= EJ_SPAWN_BATCH_SIZE) then {
                _batchCount = 0;

                // Extra delay for boss units
                private _isBoss = _pointMulti >= 4.0;
                if (_isBoss) then {
                    sleep EJ_SPAWN_BOSS_DELAY;
                } else {
                    sleep EJ_SPAWN_BATCH_DELAY;
                };
            };
        };
    } forEach _sorted;

    // ── Queue overflow for drip-feed ──
    EJ_spawnQueue = EJ_spawnQueue + _remaining;

    if (count _remaining > 0) then {
        diag_log format ["[EJ] %1 units queued for drip-feed (active cap reached).",
            count _remaining];
    };

    // ── Start drip-feed PFH if queue is non-empty ──
    if (count EJ_spawnQueue > 0 AND { EJ_dripFeedHandler < 0 }) then {
        EJ_dripFeedHandler = [{
            if (count EJ_spawnQueue == 0) exitWith {
                [EJ_dripFeedHandler] call CBA_fnc_removePerFrameHandler;
                EJ_dripFeedHandler = -1;
            };
            if (EAST countSide allUnits >= EJ_MAX_ACTIVE_ZOMBIES) exitWith {};

            private _batch = [];
            for "_i" from 1 to (EJ_SPAWN_BATCH_SIZE min count EJ_spawnQueue) do {
                _batch pushBack (EJ_spawnQueue deleteAt 0);
            };
            {
                (_x select 0) params ["_class"];
                (_x select 1) params ["_pointMulti"];
                [_class, _pointMulti] call EJ_fnc_spawnSingleZombie;
            } forEach _batch;
        }, EJ_SPAWN_BATCH_DELAY] call CBA_fnc_addPerFrameHandler;
    };

    diag_log format ["[EJ] Wave %1 spawning complete. %2 immediate, %3 queued.",
        _waveNum, _spawnedCount, count _remaining];
};
```

### 5.5 Call-Site Integration in `createWave.sqf`

Replace the three infantry `for` loops with:

```sqf
// ── WBK ZOMBIE SPAWNING (replaces vanilla infantry) ──
private _noOfPlayers = 1 max floor (playersNumber west);
[attkWave, _noOfPlayers, _multiplierBase] call EJ_fnc_spawnWBKWave;
```

---

## 6. Migration Checklist

### 6.1 Files That MUST Be Modified

| # | File | Change | Risk |
|---|---|---|---|
| 1 | `initServer.sqf` | Add `call EJ_fnc_initWBKRegistry` after `locationLists.sqf` completes and before `missionLoop.sqf` execVM. | Low — additive only |
| 2 | `hostiles/createWave.sqf` | Replace the three `for` loops (L1/L2/L3 infantry spawning) with a single `call EJ_fnc_spawnWBKWave`. Keep the vehicle spawning prefix intact. | **Medium** — core spawn logic replacement |
| 3 | `editMe.sqf` | Add WBK budget tuning parameters (`EJ_BUDGET_BASE`, `EJ_BUDGET_WAVE_SCALE`, etc.) alongside existing params. Keep original `HOSTILE_LEVEL_*` variables for backward compatibility. | Low — additive |
| 4 | `hostiles/lists.sqf` | No direct modification needed — WBK classnames come from the registry, not from `lists.sqf`. However, the zombie list stubs (`List_ZombieFast`, `List_ZombieSlow`, etc.) can be removed or left inert. | None if untouched |
| 5 | `description.ext` | Add `#include` for any new `Functions.hpp` if the adapter functions are compiled as CfgFunctions. Alternatively, `execVM`/`compileFinal preprocessFileLineNumbers` from `initServer.sqf`. | Low |
| 6 | `bulwark/functions/fn_startWave.sqf` | Modify suicide wave handling: replace weapon-strip branch with "Bloater Rush" override. Modify switcharoo wave spawn to use WBK T1/T2 classes. | **Medium** — special wave rework |
| 7 | `hostiles/moveHosToPlayer.sqf` | **Review only.** WBK zombies have their own pathfinding PFH (`_loopPathfindDoMove`). The vanilla `moveHosToPlayer.sqf` issues `doMove` every 15s to EAST units — this is redundant but not harmful. WBK's `doMove` inside the PFH will override. Can be disabled for WBK units by checking `_unit getVariable ["WBK_AI_ISZombie", false]`. | Low — optional optimisation |

### 6.2 Files That MUST Be Created

| # | File | Purpose |
|---|---|---|
| 1 | `hostiles/wbk/fn_initWBKRegistry.sqf` | Registry initialisation (§5.1) |
| 2 | `hostiles/wbk/fn_buildWaveManifest.sqf` | Budget allocation algorithm (§5.2) |
| 3 | `hostiles/wbk/fn_spawnSingleZombie.sqf` | Per-unit spawn + integration hooks (§5.3) |
| 4 | `hostiles/wbk/fn_spawnWBKWave.sqf` | Main entry point (§5.4) |
| 5 | `hostiles/wbk/fn_wbkHitPartScoreBridge.sqf` | HitPart → Bulwarks score bridge (§3.2) |
| 6 | `hostiles/wbk/Functions.hpp` | CfgFunctions class declarations |

### 6.3 Files That Remain UNTOUCHED

| File | Reason |
|---|---|
| `missionLoop.sqf` | Outer/inner loop unchanged — wave detection via `EAST countSide allUnits` is compatible |
| `bulwark/functions/fn_endWave.sqf` | Body cleanup, respawn, phase transition all compatible |
| `score/functions/fn_killed.sqf` | Fires correctly via WBK's `setDamage 1` → Killed EH chain |
| `score/functions/fn_hit.sqf` | Bypassed — replaced by `EJ_fnc_wbkHitPartScoreBridge` |
| `score/functions/fn_add.sqf` | Called by the bridge; no changes needed |
| `score/functions/fn_hitMarker.sqf` | Called by the bridge; no changes needed |
| `hostiles/spawnVehicle.sqf` | Vehicle spawning is independent of infantry |
| `hostiles/spawnCar.sqf` | Vehicle spawning is independent of infantry |
| `hostiles/clearStuck.sqf` | Anti-stuck deletion works on any EAST unit |
| `hostiles/solidObjects.sqf` | Independent system |
| `loot/*` | Loot system is independent of hostile type |
| `supports/*` | Support system is independent of hostile type |
| `build/*` | Build system is independent of hostile type |
| `area/*` | Area enforcement is independent of hostile type |
| `revivePlayers.sqf` | Player revive logic is independent |
| `onPlayerKilled.sqf` | Player death logic is independent |
| `onPlayerRespawn.sqf` | Player respawn logic is independent |
| `initPlayerLocal.sqf` | Client-side init is independent |

### 6.4 Implementation Order

| Step | Task | Dependencies |
|---|---|---|
| 1 | Create `hostiles/wbk/` directory and all 6 files | None |
| 2 | Add `Functions.hpp` include to `description.ext` | Step 1 |
| 3 | Add `call EJ_fnc_initWBKRegistry` to `initServer.sqf` | Step 2 |
| 4 | Replace infantry loops in `createWave.sqf` | Steps 1–3 |
| 5 | Add `WBK_AI_ISZombie` check to `moveHosToPlayer.sqf` | Step 4 (optional) |
| 6 | Modify special wave handling in `fn_startWave.sqf` | Step 4 |
| 7 | Playtest wave 1 (T1 only) — verify spawn, pathfinding, scoring, wave-end | Steps 1–4 |
| 8 | Playtest wave 10+ (T3/T4) — verify boss caps, cooldowns, server FPS | Step 7 |
| 9 | Playtest wave 15+ (T5 Goliath) — verify performance under full load | Step 8 |

---

## Appendix A: Data Flow Diagram

```
┌───────────────────────────────────────────────────────────────┐
│                     missionLoop.sqf                           │
│  ┌─────────────────────┐    ┌──────────────────────────────┐  │
│  │ bulwark_fnc_startWave│───▶│ hostiles/createWave.sqf      │  │
│  │  (countdown, flags)  │    │                              │  │
│  └─────────────────────┘    │  ┌────────────────────────┐  │  │
│                              │  │ Vehicle Spawning       │  │  │
│                              │  │ (UNCHANGED)            │  │  │
│                              │  └────────────────────────┘  │  │
│                              │                              │  │
│                              │  ┌────────────────────────┐  │  │
│                              │  │ EJ_fnc_spawnWBKWave    │◀─── NEW
│                              │  │  ├─ buildWaveManifest  │  │  │
│                              │  │  ├─ spawnSingleZombie  │  │  │
│                              │  │  │   ├─ createUnit     │  │  │
│                              │  │  │   ├─ [Auto] WBK AI  │  │  │
│                              │  │  │   ├─ Killed EH      │  │  │
│                              │  │  │   ├─ HitPart Bridge │  │  │
│                              │  │  │   └─ waveUnits[0]   │  │  │
│                              │  │  └─ drip-feed PFH      │  │  │
│                              │  └────────────────────────┘  │  │
│                              └──────────────────────────────┘  │
│                                                               │
│  ┌─────────────────────────────────────────────┐              │
│  │ Inner Loop: EAST countSide allUnits == 0    │ (UNCHANGED)  │
│  └─────────────────────────────────────────────┘              │
│                                                               │
│  ┌─────────────────────┐                                      │
│  │ bulwark_fnc_endWave │ (UNCHANGED)                          │
│  └─────────────────────┘                                      │
└───────────────────────────────────────────────────────────────┘
```

## Appendix B: Scoring Data Flow

```
  Player fires weapon
         │
         ▼
  ┌──────────────┐
  │ HitPart EH   │ ◀── Arma engine (fires regardless of allowDamage)
  │ (WBK native) │
  └──────┬───────┘
         │  Decrements WBK_SynthHP
         │
  ┌──────┴───────────────────┐
  │ HitPart EH               │
  │ (EJ_fnc_wbkHitPartScore  │ ◀── Adapter bridge (additive EH)
  │  Bridge)                  │
  │  ├─ killPoints_fnc_add   │ ─── Awards hit score to player
  │  └─ points[] pushBack    │ ─── Accumulates for kill bonus
  └──────────────────────────┘
         │
         │  When WBK_SynthHP ≤ 0:
         │  WBK calls setDamage 1
         ▼
  ┌──────────────┐
  │ Killed EH    │ ◀── Arma engine (fires on setDamage 1)
  │ fn_killed.sqf│
  │  ├─ Reads killPointMulti
  │  ├─ Reads points[]
  │  └─ Awards kill score
  └──────────────┘
```
