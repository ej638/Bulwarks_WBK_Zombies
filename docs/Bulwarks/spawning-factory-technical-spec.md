# Spawning Factory — Technical Specification
**Audience:** WBK Adapter Engineers  
**Source Revision:** Analysed April 9, 2026  
**Scope:** Unit creation mechanics in `hostiles/` and `editMe.sqf`. This document is the authoritative reference for building the WBK Adapter that replaces this subsystem.

---

## Table of Contents
1. [Architecture Overview](#1-architecture-overview)
2. [Unit Selection Matrix](#2-unit-selection-matrix)
3. [Difficulty Scaling Algorithm](#3-difficulty-scaling-algorithm)
4. [Spawn Positioning](#4-spawn-positioning)
5. [Vehicle vs. Infantry Branching](#5-vehicle-vs-infantry-branching)
6. [Special Wave Dispatch Table](#6-special-wave-dispatch-table)
7. [Anti-Stuck System](#7-anti-stuck-system)
8. [WBK Adapter Contract](#8-wbk-adapter-contract)

---

## 1. Architecture Overview

The spawning pipeline runs **server-side only** and is orchestrated by two functions:

```
missionLoop.sqf
  └─ bulwark_fnc_startWave          (fn_startWave.sqf)
       ├─ Increments attkWave
       ├─ Resolves special wave type → sets boolean flags
       └─ execVM "hostiles\createWave.sqf"
            ├─ Resolves vehicle tier config
            ├─ (optional) execVM spawnVehicle.sqf
            ├─ (optional) execVM spawnCar.sqf
            └─ for-loop → execVM spawnSquad.sqf  (×N)
                 └─ createUnit per class in loop
```

All state is carried in **global missionNamespace variables** (`attkWave`, `suicideWave`, `demineWave`, `waveUnits`, etc.). The WBK Adapter must publish compatible globals if any downstream script reads them.

---

## 2. Unit Selection Matrix

### 2.1 Storage Format

Unit classnames are stored in **flat, unweighted arrays** — there is no weight column or probability table. Selection is always `selectRandom <array>`, giving each entry a uniform $\frac{1}{n}$ chance.

### 2.2 List Population (`hostiles/lists.sqf`)

Lists are built at runtime by iterating `configFile >> "CfgVehicles"` and `configFile >> "CfgGroups"`. They are never hardcoded in source.

| Global Variable | Source Config Path | Filter |
|---|---|---|
| `List_Bandits` | `CfgGroups/Indep/IND_C_F/Infantry/BanditCombatGroup` | All child classes (vehicles) |
| `List_ParaBandits` | `CfgGroups/Indep/IND_C_F/Infantry/ParaCombatGroup` | All child classes |
| `List_OPFOR` | `CfgGroups/East/OPF_F/Infantry/OIA_InfSquad` | All child classes |
| `List_INDEP` | `CfgGroups/Indep/IND_F/Infantry/HAF_InfSquad` | All child classes |
| `List_NATO` | `CfgGroups/West/BLU_F/Infantry/BUS_InfSquad` | All child classes |
| `List_Viper` | `CfgGroups/East/OPF_F/SpecOps/OI_ViperTeam` | All child classes |
| `List_Armour` | `CfgVehicles` | `vehicleClass == "Armored"`, `scope != 0`, not `O_MBT_02_arty_F` |
| `List_ArmedCars` | `CfgVehicles` | `vehicleClass == "Car"`, `scope != 0`, has turret with weapons |
| `List_ZombieFast` | `CfgVehicles` | `vehicleClass == "Ryanzombiesfast"`, `scope == 2` |
| `List_ZombieSlow` | `CfgVehicles` | `vehicleClass == "Ryanzombiesslow"`, `scope == 2` |
| `List_ZombieMedium` | `CfgVehicles` | `vehicleClass == "Ryanzombiesmedium"`, `scope == 2` |
| `List_ZombieCrawler` | `CfgVehicles` | `vehicleClass == "RyanzombiesCrawler"`, `scope == 2` |
| `List_ZombieBoss` | `CfgVehicles` | `vehicleClass == "Ryanzombiesboss"`, `scope == 2` |
| `List_ZombieWalker` | `CfgVehicles` | `vehicleClass == "Ryanzombieswalker"`, `scope == 2` |
| `List_ZombieSpider` | `CfgVehicles` | `vehicleClass == "Ryanzombiesspider"`, `scope == 2` |
| `List_ZombiePlayer` | `CfgVehicles` | `vehicleClass == "Ryanzombiesplayer"`, `scope == 2` |

> **Note:** The zombie lists are populated but are **not currently assigned to any `HOSTILE_LEVEL_*`** variable in `editMe.sqf`. They exist as WBK integration stubs.

### 2.3 Tier Assignment (`editMe.sqf`)

Three global tier handles are assigned in `editMe.sqf` and are the only identifiers `createWave.sqf` and `spawnSquad.sqf` consume:

```sqf
HOSTILE_LEVEL_1 = List_Bandits;   // active from wave 1
HOSTILE_LEVEL_2 = List_OPFOR;     // introduced at wave > 6
HOSTILE_LEVEL_3 = List_Viper;     // introduced at wave > 12
```

Additional handles for vehicles and special roles:
```sqf
HOSTILE_ARMED_CARS = List_Armour;      // NOTE: variable name mismatch — holds Armour
HOSTILE_ARMOUR     = List_ArmedCars;   // NOTE: variable name mismatch — holds Cars
PARATROOP_CLASS    = List_NATO;
DEFECTOR_CLASS     = List_NATO;
```

> **Bug / Naming Hazard:** `HOSTILE_ARMED_CARS` is assigned `List_Armour` and `HOSTILE_ARMOUR` is assigned `List_ArmedCars`. The variable names are swapped from their semantic meaning. `spawnVehicle.sqf` reads `List_Armour` directly and `spawnCar.sqf` reads `List_ArmedCars` directly, bypassing these globals — so the mission works correctly despite the mislabeling. The WBK Adapter should **not** replicate this naming and should access the lists directly.

---

## 3. Difficulty Scaling Algorithm

Scaling operates on **both quantity and quality** simultaneously. There is no single difficulty number; it emerges from three independent axes.

### 3.1 Quantity: Squad Count

Calculated in `createWave.sqf`:

```sqf
_multiplierBase = HOSTILE_MULTIPLIER          // mission param, configurable
if (attkWave <= 2) then { _multiplierBase = 1 };  // floor for early waves

_SoldierMulti = attkWave / 5

// Level 1 squads (always spawned)
squadCount_L1 = floor(attkWave * _multiplierBase)

// Level 2 squads (wave > 6 gate)
squadCount_L2 = if (attkWave > 6) then { floor(_SoldierMulti) + 1 } else { 0 }

// Level 3 squads (wave > 12 gate)
squadCount_L3 = if (attkWave > 12) then { floor(_SoldierMulti) + 1 } else { 0 }
```

**Total squads per wave** (example values, `HOSTILE_MULTIPLIER = 2`):

| Wave | L1 Squads | L2 Squads | L3 Squads | Total |
|------|-----------|-----------|-----------|-------|
| 1 | 1 | 0 | 0 | 1 |
| 2 | 2 | 0 | 0 | 2 |
| 5 | 10 | 0 | 0 | 10 |
| 7 | 14 | 2 | 0 | 16 |
| 13 | 26 | 3 | 3 | 32 |
| 20 | 40 | 5 | 5 | 50 |

### 3.2 Quantity: Units per Squad

Each `spawnSquad.sqf` call receives `_unitCount`:

```sqf
_noOfPlayers = 1 max floor(playersNumber(west) * HOSTILE_TEAM_MULTIPLIER)
```

- `HOSTILE_TEAM_MULTIPLIER` is a mission param (stored as a fraction: `param / 100`).
- Minimum of 1 unit per squad is enforced by the `1 max` clamp.
- With 4 players and `HOSTILE_TEAM_MULTIPLIER = 0.5`: `1 max floor(4 * 0.5)` = **2 units per squad**.

### 3.3 Quality: Tier Introduction Thresholds

| Condition | Effect |
|---|---|
| Always | HOSTILE_LEVEL_1 squads spawn |
| `attkWave > 6` | HOSTILE_LEVEL_2 squads begin appearing alongside L1 |
| `attkWave > 12` | HOSTILE_LEVEL_3 squads begin appearing alongside L1 and L2 |

### 3.4 Quality: AI Skill Ramp (`spawnSquad.sqf`)

`hosSkill` is set as a stepped function of `attkWave`. The same value is applied to `setUnitAbility`, `aimingAccuracy`, `aimingShake`, and a 0.75× factor for `aimingSpeed`.

| Wave Range | hosSkill | aimingSpeed |
|---|---|---|
| 0 – 4 | 0.05 | 0.0375 |
| 5 – 9 | 0.075 | 0.05625 |
| 10 – 14 | 0.10 | 0.075 |
| 15 – 19 | 0.15 | 0.1125 |
| 20 – 24 | 0.40 | 0.30 |
| 25 – 29 | 0.50 | 0.375 |
| 30+ | 1.00 | 0.75 |

> **Bug:** Two `if` blocks cover `attkWave < 25 && attkWave >= 20` — the second silently overrides the first (`0.2` → `0.4`). Effective skill at wave 20–24 is **0.4**, not 0.2.

`spawnInfantry.sqf` (used by some special waves) uses a simpler **linear** formula:

$$\text{hosSkill} = \min\!\left(\frac{\text{attkWave}}{40},\ 1.0\right)$$

This reaches maximum at wave 40, rather than wave 30.

### 3.5 Quality: Pistol-Only Early Waves

```sqf
if (attkWave <= PISTOL_HOSTILES) then {
    removeAllWeapons _unit;
    _unit addWeapon "hgun_P07_F";
    // 2× 16Rnd_9x21_Mag
};
```

`PISTOL_HOSTILES` is a mission param. Units below this wave threshold have all weapons stripped and receive only a pistol. This is the primary "easy start" mechanism.

### 3.6 Random Weapons Mode

When `RANDOM_WEAPONS == 1`, after normal unit creation:
1. The unit's default primary weapon and all matching magazines are stripped.
2. A random weapon from `List_Primaries` is selected.
3. A random compatible magazine from that weapon's `CfgWeapons` entry is added (×3).

This is a cosmetic/variety layer and does not affect AI skill.

---

## 4. Spawn Positioning

All spawns are **procedural ring queries** — there are no fixed spawn point objects or area markers.

### 4.1 Core Function

All spawn location queries use the Arma built-in:
```sqf
BIS_fnc_findSafePos [center, minDist, maxDist, minLandRatio, waterMode]
```

The **center reference object is always `bulwarkCity`** (the city/location object selected during mission init), except for the Switcharoo wave which centres on `bulwarkBox`.

### 4.2 Spawn Annuli by Type

| Spawn Type | Min Distance | Max Distance | Min Clear Radius | Notes |
|---|---|---|---|---|
| Infantry (standard) | `BULWARK_RADIUS + 30` | `BULWARK_RADIUS + 150` | 1 m | `landRatio=1`, `waterMode=0` |
| Armour / Car | `BULWARK_RADIUS` | `BULWARK_RADIUS + 150` | 10 m | Wider clear area for vehicles |
| Mortar | `BULWARK_RADIUS − 15` | `BULWARK_RADIUS − 5` | 3 m | Spawns **inside** the bulwark perimeter |
| Switcharoo units | `bulwarkBox` position | n/a | — | `bulwark_fnc_findPlaceAround` — places directly around box |
| Civilians | Inside `lootHouses` rooms | — | — | `buildingPos -1` → `selectRandom` |
| Drones (demine) | `_location` (inherits squad pos) | `+50 m` | — | Spawned at infantry location, `flyInHeight 30` |

**Key anchor objects:**
- `bulwarkCity` — city/location center; origin for all standard spawn rings.
- `bulwarkBox` — the physical Bulwark prop; target for AI `doMove` and Switcharoo spawn center.
- `bulwarkRoomPos` — interior Bulwark room position; used for Mortar positioning and Switcharoo player teleport destination.

> There are no editor-placed spawn markers consumed by this pipeline. `BULWARK_RADIUS` (a mission param) is the only configurable distance variable.

### 4.3 AI Movement After Spawn

After creation, every infantry unit executes:
```sqf
_unit doMove (getPos (selectRandom playableUnits));
```
This is the **initial** move order only. The persistent `moveHosToPlayer.sqf` loop (running every 15 s) overrides this with a targeted nearest-player pursuit:
- Infantry: finds safe position within 15 m of nearest player.
- Vehicles: finds safe position 15–55 m from nearest player.

---

## 5. Vehicle vs. Infantry Branching

Vehicle spawning is **independent of infantry spawning** and runs as a prefix step in `createWave.sqf` before the infantry loops.

### 5.1 Tier Configuration Table

Both Armour and Armed Cars share the same 1-in-N / max-since trigger pattern. Config is driven by `(attkWave - _armourStartWave)` where `_armourStartWave` is a mission param.

| Relative Wave | ArmourChance | ArmourMaxSince | ArmourCount | carChance | carMaxSince | carCount |
|---|---|---|---|---|---|---|
| < 5 | 0 — **disabled** | — | 0 | 3 | 2 | 1 |
| 5 – 9 | 4 | 4 | 1 | 3 | 3 | `1 + ⌊players/4⌋` |
| 10 – 14 | 3 | 3 | `1 + ⌊players/4⌋` | 2 | 2 | `2 + ⌊players/4⌋` |
| 15 – 19 | 2 | 2 | `2 + ⌊players/4⌋` | 1 | 2 | `2 + ⌊players/4⌋` |
| 20+ | 2 | 1 | `3 + ⌊players/4⌋` | 1 | 1 | `3 + ⌊players/4⌋` |

### 5.2 Trigger Logic

```sqf
// Armour
if ((attkWave >= _armourStartWave && floor(random ArmourChance) == 1)
    || (attkWave >= _armourStartWave && wavesSinceArmour >= ArmourMaxSince))
then {
    execVM "hostiles\spawnVehicle.sqf";
    wavesSinceArmour = 0;
} else {
    wavesSinceArmour = wavesSinceArmour + 1;
};
```

The same pattern applies to Cars (substituting Car variables). Two independent cooldown counters (`wavesSinceArmour`, `wavesSinceCar`) ensure vehicles cannot be absent for more than `MaxSince` consecutive waves.

When `ArmourChance = 0` (relative wave < 5), `floor random 0` is always 0, so the random branch never fires. Armour is gated purely by `_armourStartWave`.

### 5.3 Vehicle Scoring

| Type | Score Multiplier Variable |
|---|---|
| Infantry L1 | `HOSTILE_LEVEL_1_POINT_SCORE` = 0.75 |
| Infantry L2 | `HOSTILE_LEVEL_2_POINT_SCORE` = 1.0 |
| Infantry L3 | `HOSTILE_LEVEL_3_POINT_SCORE` = 1.5 |
| Armed Car | `HOSTILE_CAR_POINT_SCORE` = 2.0 |
| Armour | `HOSTILE_ARMOUR_POINT_SCORE` = 4.0 |

Multipliers are stored per-unit as `_unit setVariable ["killPointMulti", ...]` and applied by the score event handlers.

---

## 6. Special Wave Dispatch Table

Special waves are **wave-level modifiers**, not separate spawn pipelines. They set boolean flags before `createWave.sqf` runs, and those flags alter `spawnSquad.sqf` behaviour inline.

### 6.1 Trigger Logic

Evaluated in `fn_startWave.sqf` immediately after `attkWave` increments:

| Wave Range | randSpecChance | maxSinceSpecial | maxSpecialLimit | Min Wave |
|---|---|---|---|---|
| < 10 | 4 | 4 | 1 | 5 |
| 10 – 14 | 3 | 3 | 1 | 5 |
| 15+ | 2 | 2 | 0 | 5 |

```sqf
if ((floor random randSpecChance == 1 || wavesSinceSpecial >= maxSinceSpecial)
    && attkWave >= 5
    && wavesSinceSpecial >= maxSpecialLimit)
then { specialWave = true; }
```

`maxSpecialLimit = 1` at early waves prevents two consecutive special waves. At wave 15+ this guard is removed (`maxSpecialLimit = 0`).

### 6.2 Special Wave Type Pool

Type is selected by `floor random N` from the applicable pool:

**Waves 5–9** (pool of 3):

| Index | `SpecialWaveType` | Mechanism |
|---|---|---|
| 0 | `specCivs` | Spawns 20 random civilians who walk toward `bulwarkRoomPos`; kill penalty via `killPoints_fnc_civKilled` |
| 1 | `fogWave` | Sets `15 setFog 1`; cleared at wave end |
| 2 | `swticharooWave` | Teleports players away from bulwark → spawns `⌊attkWave/2⌋ + ⌊players × 1.5⌋` L1 units directly around `bulwarkBox` |

**Waves 10+** (pool of 8, adds):

| Index | `SpecialWaveType` | Mechanism |
|---|---|---|
| 3 | `suicideWave` | Sets boolean; `spawnSquad.sqf` strips weapons + attaches `CreateHostiles_fnc_suiExplode` kill handler; `suicideWave.sqf` loop kills units within 10 m of any player |
| 4 | `specMortarWave` | Spawns `O_Mortar_01_F` at `bulwarkRoomPos ± 5–15 m`; fires every 30 s at bulwark ±45 m scatter until gunner killed |
| 5 | `nightWave` | `skipTime(24 - currentTime)`; reverts via `skipTime currentTime` at wave end |
| 6 | `demineWave` | In `spawnSquad.sqf`: 50 % per unit spawns `C_IDAP_UAV_06_antimine_F` drone at squad location; capped at 15 drones; `droneFire.sqf` loop fires at `bulwarkBox` every 30 s |
| 7 | `defectorWave` | Overrides `unitClasses = DEFECTOR_CLASS` in `spawnSquad.sqf`; classnames come from `List_NATO` (friendly-looking units as enemies) |

### 6.3 Flag Interaction with `spawnSquad.sqf`

`spawnSquad.sqf` checks flags in this order per unit:

```
1. if defectorWave  → unitClasses = DEFECTOR_CLASS (overrides tier pool)
2. normal unit creation from unitClasses
3. if RANDOM_WEAPONS == 1 → replace primary weapon
4. if attkWave <= PISTOL_HOSTILES → strip & replace with pistol
5. if suicideWave → strip all weapons, attach suicide EH
6. if demineWave && random 2 == 0 && droneCount <= 15 → spawn drone alongside unit
```

---

## 7. Anti-Stuck System

`clearStuck.sqf` runs on a 30-second polling cycle and deletes units that have failed to close distance on players. Deletion criteria (all must be true):

1. Unit is alive.
2. Unit's new distance to the player's **original position** has not decreased by ≥ 15 m.
3. Player `knowsAbout` score for this unit is < 3.5 (i.e., the unit is not in active combat).
4. Player is > 35 m away.
5. Unit is > 20 m from `bulwarkBox`.

For vehicles: if the nearest player distance is ≥ `BULWARK_RADIUS`, the vehicle is destroyed instead of deleted.

This system silently removes stuck units from `waveUnits` tracking without awarding kill points.

---

## 8. WBK Adapter Contract

The following is the minimal interface the WBK Adapter must satisfy to be a drop-in replacement.

### 8.1 Inputs (globals must exist before adapter is called)

| Variable | Type | Description |
|---|---|---|
| `attkWave` | Integer | Current wave number (1-based) |
| `HOSTILE_LEVEL_1` | Array | Flat array of infantry classname strings |
| `HOSTILE_LEVEL_2` | Array | Flat array of infantry classname strings |
| `HOSTILE_LEVEL_3` | Array | Flat array of infantry classname strings |
| `HOSTILE_MULTIPLIER` | Number | Base squad count multiplier |
| `HOSTILE_TEAM_MULTIPLIER` | Number | Units-per-squad player scaling (0–1) |
| `PISTOL_HOSTILES` | Integer | Waves below this threshold use pistols only |
| `bulwarkCity` | Object | Location center reference |
| `bulwarkBox` | Object | Physical Bulwark prop |
| `BULWARK_RADIUS` | Number | Radius of the bulwark zone (meters) |
| `suicideWave` | Boolean | Suicide bomber modifier active |
| `demineWave` | Boolean | Drone modifier active |
| `defectorWave` | Boolean | Defector class override active |
| `waveUnits` | Array `[[],[],[]]` | Ring buffer: index 0 = current wave units |

### 8.2 Outputs (globals the adapter must publish)

| Variable | Type | Description |
|---|---|---|
| `waveSpawned` | Boolean | Set `true` when all units have been created |
| `waveUnits[0]` | Array | Appended with each created unit object |
| `droneSquad` | Array | (if demineWave) Appended with each drone group |
| `droneCount` | Integer | (if demineWave) Incremented per drone spawned |

### 8.3 Per-Unit Event Handlers

Each spawned unit must have these event handlers attached to integrate with the score system:

```sqf
_unit addEventHandler ["Hit",   killPoints_fnc_hit];
_unit addEventHandler ["Killed", killPoints_fnc_killed];
_unit setVariable ["killPointMulti", <tier_multiplier>];
_unit setVariable ["points", []];
```

### 8.4 Zeus Visibility

```sqf
mainZeus addCuratorEditableObjects [[_unit], true];
```

Required for all spawned objects (units and vehicles). Omitting this does not break gameplay but removes Zeus operator visibility.

### 8.5 Recommended Replacement Strategy

The WBK Adapter should expose a single callable entry point:

```sqf
// Signature:
[unitClassArray, waveNumber, unitCount, pointMultiplier] call WBK_fnc_spawnSquad;
```

This mirrors the existing `spawnSquad.sqf` argument list for compatibility with `createWave.sqf`'s call sites, minimising changes to the wave orchestration layer.
