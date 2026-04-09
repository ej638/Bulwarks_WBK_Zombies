# Hostiles: Selection & Spawning — Overview

This document analyzes the `hostiles` folder and explains how enemies are selected and spawned. It highlights where selection happens today and which files you will need to update to replace soldiers with custom Zombies/Creatures.

**Summary**
- The core flow is: build unit lists -> mission config selects which lists are “hostile levels” -> wave orchestrator calls spawn routines -> spawn routines pick concrete classnames and create units/vehicles.
- Key files: [hostiles/lists.sqf](hostiles/lists.sqf), [hostiles/createWave.sqf](hostiles/createWave.sqf), [hostiles/spawnSquad.sqf](hostiles/spawnSquad.sqf) (and the vehicle/car spawners).

**Files and purpose**
- [hostiles/lists.sqf](hostiles/lists.sqf): Scans CfgVehicles and CfgGroups and builds global arrays used by spawners (List_Bandits, List_OPFOR, List_Armour, List_ArmedCars, and several List_Zombie* arrays). This is where custom vehicleClass tags are detected and grouped.
- [hostiles/createWave.sqf](hostiles/createWave.sqf): Wave orchestration. Decides how many squads/vehicles/cars to spawn for the current `attkWave`, computes player-based multipliers, and calls the concrete spawners (spawnSquad, spawnVehicle, spawnCar).
- [hostiles/spawnSquad.sqf](hostiles/spawnSquad.sqf): Creates a squad of infantry units. It receives a unit-class-array (first parameter) and picks concrete classes with `selectRandom`. Also sets AI skill (scaled by wave), applies weapons/ammo (if enabled), handles suicide/demine behaviors, and appends spawned units to `waveUnits`.
- [hostiles/spawnInfantry.sqf](hostiles/spawnInfantry.sqf): Spawns a single unit (same selection method as spawnSquad but for one unit).
- [hostiles/spawnVehicle.sqf](hostiles/spawnVehicle.sqf): Spawns one armour class chosen from `List_Armour` and registers its crew into the spawned wave list.
- [hostiles/spawnCar.sqf](hostiles/spawnCar.sqf): Spawns armed cars chosen from `List_ArmedCars`.
- [hostiles/CivWave.sqf](hostiles/CivWave.sqf): Special civilian-spawn routine (not used for hostile waves, but shows alternative spawn patterns).
- [hostiles/specSwticharooWave.sqf](hostiles/specSwticharooWave.sqf): Special event wave that teleports players and spawns HOSTILE_LEVEL_1 units directly.
- [hostiles/specMortar.sqf](hostiles/specMortar.sqf): Spawns and controls a mortar vehicle for a special wave.
- [hostiles/suicideWave.sqf](hostiles/suicideWave.sqf): Suicide-wave handler (forces immediate death when close, used with explosive AI handlers from spawnSquad).
- [hostiles/moveHosToPlayer.sqf](hostiles/moveHosToPlayer.sqf): AI movement loop that directs hostile units toward the nearest player and enforces behavior changes (speeds, positions, fleeing disabled).
- [hostiles/clearStuck.sqf](hostiles/clearStuck.sqf): Periodic cleanup for stuck or unreachable AI.
- [hostiles/solidObjects.sqf](hostiles/solidObjects.sqf): Deprecated/legacy prevention of AI walking through player-built objects.
- [hostiles/droneFire.sqf](hostiles/droneFire.sqf): Handles drone firing behavior for waves that spawned UAVs.
- [hostiles/functions.hpp](hostiles/functions.hpp) and [hostiles/functions/fn_suiExplode.sqf](hostiles/functions/fn_suiExplode.sqf): Cfg/function registration and suicide-explosion helper.

**Selection flow (step-by-step)**
1. Mission start / init: [hostiles/lists.sqf](hostiles/lists.sqf) runs and creates arrays like `List_Bandits`, `List_OPFOR`, `List_Armour`, `List_ArmedCars` and `List_Zombie*`. The script inspects `configFile` (CfgVehicles and CfgGroups) and groups classnames by vehicleClass and group definitions.
2. `editMe.sqf` (mission config) assigns which lists become the three hostile levels (HOSTILE_LEVEL_1, HOSTILE_LEVEL_2, HOSTILE_LEVEL_3). These constants are the main switch that determines which units get used for each wave level.
3. Wave start: [hostiles/createWave.sqf](hostiles/createWave.sqf) runs for a given `attkWave`. It:
   - computes `_noOfPlayers` and `_squadCount` using `playersNumber`, `HOSTILE_TEAM_MULTIPLIER`, and `HOSTILE_MULTIPLIER` (so squads scale with players and with the wave number);
   - decides whether to spawn armour/cars (based on `ARMOUR_START_WAVE` mission param and chance counters);
   - spawns `HOSTILE_LEVEL_1` squads `_squadCount` times and adds additional `HOSTILE_LEVEL_2`/`HOSTILE_LEVEL_3` spawns once `attkWave` passes thresholds (>6, >12).
4. Squad spawn: [hostiles/spawnSquad.sqf](hostiles/spawnSquad.sqf) is called with parameters `[unitArray, attkWave, unitsPerSquad, pointScore]`. Inside it:
   - `unitClass = selectRandom unitClasses` picks a concrete classname from the passed-in array;
   - creates the unit and group at a safe position;
   - sets per-wave AI skill (`hosSkill`) using several wave thresholds so AI accuracy/speed increases with wave;
   - optionally replaces weapons (if RANDOM_WEAPONS param) or forces pistols for very early waves;
   - assigns event handlers (`Hit`, `Killed`) and adds the unit to `waveUnits`.

**How waves get harder**
- More squads per wave: `_squadCount = floor(attkWave * HOSTILE_MULTIPLIER)` in [hostiles/createWave.sqf](hostiles/createWave.sqf).
- Higher-tier squads: Additional `HOSTILE_LEVEL_2` appear starting around wave 7 and `HOSTILE_LEVEL_3` around wave 13 via additional loops keyed to `attkWave`.
- More units per squad when more players join: `_noOfPlayers = 1 max floor((playersNumber west) * HOSTILE_TEAM_MULTIPLIER)` — increases group sizes with player count.
- Higher AI skill: `spawnSquad.sqf` raises `hosSkill` as `attkWave` increases (multiple thresholds in that file).
- Vehicles/Cars: `createWave.sqf` increases `ArmourCount` and `carCount` at higher waves and increases spawn chance once `attkWave` exceeds `ARMOUR_START_WAVE`.

**Exact places that pick concrete enemy classes (these must be updated for Zombies)**
- [hostiles/lists.sqf](hostiles/lists.sqf): builds the `List_` arrays. If custom creatures/classes exist in CfgVehicles, `lists.sqf` is the place that discovers and groups them (matches on `vehicleClass` or CfgGroups entries).
- [editMe.sqf](editMe.sqf): assigns which lists are used for HOSTILE_LEVEL_1/2/3. Changing these points the existing spawn pipeline at the highest level to use Zombies instead of soldiers.
- [hostiles/createWave.sqf](hostiles/createWave.sqf): decides when and which hostiles to spawn (it calls the spawners with the arrays defined above).
- [hostiles/spawnSquad.sqf](hostiles/spawnSquad.sqf): picks a concrete classname with `selectRandom unitClasses` and performs per-unit initialization. This file contains code that assumes conventional soldier units (weapons, magazines); it will likely need to be adapted for zombie/creature-specific initialization.
- [hostiles/spawnVehicle.sqf](hostiles/spawnVehicle.sqf) and [hostiles/spawnCar.sqf](hostiles/spawnCar.sqf): pick vehicle classnames from `List_Armour` and `List_ArmedCars` respectively.

**Notes & recommendations for converting to Zombies/Creatures**
1. Fast experiment (minimal changes): change HOSTILE_LEVEL_* assignments in [editMe.sqf](editMe.sqf) to point at the `List_Zombie*` arrays created by [hostiles/lists.sqf](hostiles/lists.sqf). This will make the existing spawn pipeline create zombie classnames instead of soldiers with minimal file edits.
2. Spawn initialization: `spawnSquad.sqf` assumes weapons/magazines and sets ranged-weapon-related skills. For melee/creature units you should:
   - Remove or disable the weapon-replacement blocks (RANDOM_WEAPONS / PISTOL_HOSTILES) — or gate them behind a creature flag.
   - Instead, set creature-specific variables (e.g., movement speed, playAction animations, damage handling, melee attack handlers).
   - If creature types use different config entries (not vehicleClass or group definitions used by `lists.sqf`), update `lists.sqf` to detect them.
3. Movement/behaviour tuning: `moveHosToPlayer.sqf` centralizes movement decisions. For melee creatures you will likely want to adjust the safe-distance logic, forceSpeed, and the doMove targets so creatures close to players behave appropriately (charge, surround, climb, etc.).
4. Special waves & bosses: `specSwticharooWave.sqf`, `specMortar.sqf` and `suicideWave.sqf` are special-case scripts. Decide whether to keep/repurpose them (for example, a "horde" special wave that spawns fast/zombie crawlers).
5. Vehicles and cars: If Zombies should not use vehicles, remove or adjust calls to [hostiles/spawnVehicle.sqf](hostiles/spawnVehicle.sqf) / [hostiles/spawnCar.sqf](hostiles/spawnCar.sqf) and any `Armour` logic in [hostiles/createWave.sqf](hostiles/createWave.sqf).
6. Function registration: For new behaviors you can add helper functions to [hostiles/functions](hostiles/functions) and register them in [hostiles/functions.hpp](hostiles/functions.hpp).

**Quick checklist: exact files to edit when implementing zombies**
- [editMe.sqf](editMe.sqf) — remap HOSTILE_LEVEL_* to zombie lists (quick toggle to test).
- [hostiles/lists.sqf](hostiles/lists.sqf) — ensure it detects your custom creature classes (vehicleClass/group tags) or add categories.
- [hostiles/spawnSquad.sqf](hostiles/spawnSquad.sqf) — replace weapon initialization with creature-specific setup; tune `hosSkill` or add a creature-behaviour mapping.
- [hostiles/createWave.sqf](hostiles/createWave.sqf) — adjust spawn thresholds/counts for creature waves (e.g., increase swarm counts, remove armour logic).
- [hostiles/moveHosToPlayer.sqf](hostiles/moveHosToPlayer.sqf) — tune movement/engage logic for melee creatures.
- Optional: add a new `hostiles/spawnZombieGroup.sqf` if creature spawning logic diverges significantly from infantry spawning.

If you want, I can do the minimal change now (assign HOSTILE_LEVEL_* to zombie lists in `editMe.sqf`) and then create a prototype `hostiles/spawnZombieGroup.sqf` that shows how to initialize creature units (no weapons, custom animations, melee handler). Say the word and I will implement the quick test and update the todo list.

----
Document created by analysis run. See the referenced files for the exact selection lines and per-wave math.
