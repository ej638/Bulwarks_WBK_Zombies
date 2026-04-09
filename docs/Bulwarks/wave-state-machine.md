# Wave State Machine — Technical Analysis
**Role:** Senior SQF Systems Architect  
**Scope:** Core round lifecycle, global state variables, and parameter injection  
**Files analysed:** `missionLoop.sqf`, `initServer.sqf`, `description.ext`, `editMe.sqf`,  
`bulwark/functions/fn_startWave.sqf`, `bulwark/functions/fn_endWave.sqf`, `hostiles/createWave.sqf`, `hostiles/spawnInfantry.sqf`

---

## 1. Loop Lifecycle

### 1.1 Server Bootstrap (`initServer.sqf`)

The mission has **no root `init.sqf`**. All server-side bootstrap logic lives in `initServer.sqf`.

Execution order at server start:

```
initServer.sqf
 ├─ locationLists.sqf   (async, waitUntil scriptDone)
 ├─ loot\lists.sqf      (async, waitUntil scriptDone)
 ├─ hostiles\lists.sqf  (async, waitUntil scriptDone)
 ├─ editMe.sqf          (async, waitUntil scriptDone)  ← ALL params resolved here
 ├─ bulwark\createBase.sqf  (async, waitUntil scriptDone)  ← sets bulwarkRoomPos
 ├─ Broadcast all globals (publicVariable)
 └─ [bulwarkRoomPos] execVM "missionLoop.sqf"  ← main loop starts
```

`buildPhase` is set to `true` **twice** here — once as a bare global at the top, and once via
`missionNamespace setVariable ["buildPhase", true, true]`. The missionNamespace form is authoritative
because it broadcasts to all machines.

---

### 1.2 Outer Loop — Mission Tick (`missionLoop.sqf`)

The file begins with a **one-time revive block** (executed before the outer `while`), then initialises
all counters and enters the outer loop:

```sqf
while {runMissionLoop} do {
    AIstuckcheck = 0;
    AIStuckCheckArray = [];

    [] call bulwark_fnc_startWave;   // ← LOOTING → COMBAT transition

    while {runMissionLoop} do { ... };  // inner combat poll loop

    if (missionFailure) exitWith {};
    if (attkWave == _maxWaves) exitWith { "End2" call BIS_fnc_endMissionServer; };

    [] call bulwark_fnc_endWave;    // ← COMBAT → LOOTING transition
};
```

Each iteration of the **outer loop** is exactly one wave.

---

### 1.3 Phase Transition: Looting → Combat (`bulwark_fnc_startWave`)

**File:** `bulwark/functions/fn_startWave.sqf`

Sequence of actions before `buildPhase` is cleared:

| Step | Action |
|------|--------|
| 1 | Terminate any active spectator mode (`BIS_fnc_EGSpectator`) |
| 2 | Update HUD for all clients |
| 3 | 15-second countdown (`sleep 1` × 15, audio beeps for last 4) |
| 4 | **Body cleanup**: `waveUnits[BODY_CLEANUP]` are deleted; array window rotated: `[2]←[1]←[0]←[]` |
| 5 | Snapshot `playersInWave` (UID array, publicVariable) |
| 6 | `attkWave += 1`, publicVariable |
| 7 | `waveSpawned = false` |
| 8 | Revert any `nightWave` time skip |
| 9 | Clear fog (`15 setFog 0`) |
| 10 | Adjust `RESPAWN_TIME` → `99999` if tickets exhausted |
| **11** | **`missionNamespace setVariable ["buildPhase", false, true]`** ← **COMBAT START** |
| 12 | Determine `specialWave` (bool) and `SpecialWaveType` (string) |
| 13 | Launch special wave side-scripts (suicide bombers, mortars, drones, etc.) |
| 14 | Broadcast wave notifications to all players |
| 15 | Delete remaining dead vehicles (`allMissionObjects "LandVehicle"`, `"Air"`) |
| 16 | `execVM "hostiles\createWave.sqf"` → `waitUntil {scriptDone}` → `waveSpawned = true` |
| 17 | `loot_fnc_cleanup` → `spawnLoot.sqf` (waves > 1 only) |

The function **blocks** (runs on server, uses `sleep` and `waitUntil`) so the calling context in
`missionLoop.sqf` does not advance until all spawning is complete.

---

### 1.4 Inner Loop — Combat Poll

```sqf
while {runMissionLoop} do {
    _allHCs = entities "HeadlessClient_F";
    _allHPs  = allPlayers - _allHCs;

    // Wave-over condition — PURE POLL, no event handler
    if (EAST countSide allUnits == 0) exitWith {};

    // Wipe condition — triple-checked with sleep 1 between each check
    _deadUnconscious = [...];
    if (count (_allHPs - _deadUnconscious) <= 0 && _respawnTickets <= 0) then {
        sleep 1; // check #2
        if (...) then {
            sleep 1; // check #3
            if (...) then {
                runMissionLoop = false;
                missionFailure = true;
                "End1" call BIS_fnc_endMissionServer;
            };
        };
    };

    // Zeus visibility
    { mainZeus addCuratorEditableObjects [[_x], true]; } foreach _allHPs;
};
```

There is **no `addEventHandler` for wave-end detection**. The loop polls every frame with no explicit
`sleep`, making it effectively a busy-wait on the EAST side count. The `EAST countSide allUnits`
expression counts all living EAST units on all machines in real time.

The wipe detection uses a **triple-redundant check** with `sleep 1` between each to guard against
the narrow window where all players are down but a medikit auto-revive is still in progress
(handled client-side via a `HandleDamage` EH in `initPlayerLocal.sqf`).

---

### 1.5 Phase Transition: Combat → Looting (`bulwark_fnc_endWave`)

**File:** `bulwark/functions/fn_endWave.sqf`

| Step | Action |
|------|--------|
| 1 | `playersInWave = []` (publicVariable) — gate opens for rejoin slots |
| **2** | **`missionNamespace setVariable ["buildPhase", true, true]`** ← **LOOT/BUILD START** |
| 3 | Show "Wave N complete!" notification |
| 4 | `RESPAWN_TIME = 0` (publicVariable) — immediate respawn during build |
| 5 | `forceRespawn` all DEAD players |
| 6 | `BIS_fnc_reviveOnState` (#rev) for all INCAPACITATED players |
| 7 | Terminate spectator mode |
| 8 | Delete all `MIND_CONTROLLED_AI` units; clear array |
| **9** | **`sleep _downTime`** ← inter-wave pause (value from `DOWN_TIME` param) |

After `fn_endWave` returns, the outer `while` loop immediately calls `bulwark_fnc_startWave` again,
beginning the next wave's countdown.

---

## 2. Global State Variables

### 2.1 Phase / Wave Lifecycle

| Variable | Type | Scope | Set in | Description |
|----------|------|-------|--------|-------------|
| `buildPhase` | Bool | `missionNamespace` (global broadcast) | `initServer`, `fn_startWave`, `fn_endWave` | **The authoritative phase flag.** `true` = loot/build; `false` = combat |
| `runMissionLoop` | Bool | Global | `missionLoop.sqf` | Master loop guard. `false` halts the outer `while` |
| `missionFailure` | Bool | Global | `missionLoop.sqf` | Set alongside `End1` to prevent extra `endWave` call |
| `attkWave` | Number | Global (publicVariable) | `fn_startWave` | Current wave number, 1-indexed after first increment. Starts at `0` |
| `waveSpawned` | Bool | Global | `fn_startWave` (false), `createWave.sqf` (true) | Indicates all hostile spawning scripts have completed |

### 2.2 Enemy Count

There is **no stored variable** for the remaining enemy count. The check is always evaluated inline:

```sqf
EAST countSide allUnits   // Returns live count of all EAST-side units network-wide
```

Enemy units are accumulated in `waveUnits`:

| Variable | Type | Description |
|----------|------|-------------|
| `waveUnits` | Array `[[],[],[]]` | Sliding 3-wave window of spawned unit references, used for body cleanup. Index 0 = current wave. Rotated at the start of each `fn_startWave`. |

### 2.3 Special Wave Flags

| Variable | Description |
|----------|-------------|
| `specialWave` | Bool — `true` if this wave has a special modifier |
| `SpecialWaveType` | String enum — one of: `""`, `"specCivs"`, `"fogWave"`, `"swticharooWave"`, `"suicideWave"`, `"specMortarWave"`, `"nightWave"`, `"demineWave"`, `"defectorWave"` |
| `suicideWave` | Bool — convenience flag, mirrors `SpecialWaveType == "suicideWave"` |
| `specMortarWave` | Bool — mirrors `SpecialWaveType == "specMortarWave"` |
| `specCivs` | Bool — mirrors `SpecialWaveType == "specCivs"` |
| `nightWave` | Bool — also stores time context for `currentTime` restore |
| `fogWave` | Bool — mirrors `SpecialWaveType == "fogWave"` |
| `swticharooWave` | Bool — mirrors `SpecialWaveType == "swticharooWave"` |
| `demineWave` | Bool — mirrors `SpecialWaveType == "demineWave"` |
| `defectorWave` | Bool — mirrors `SpecialWaveType == "defectorWave"` |
| `wavesSinceSpecial` | Number — decremented cooldown counter; forces a special wave when `>= maxSinceSpecial` |
| `droneCount` | Number — used by `droneFire.sqf` during demineWave |

### 2.4 Escalation Counters

| Variable | Description |
|----------|-------------|
| `wavesSinceArmour` | Waves elapsed without an armoured vehicle spawn |
| `wavesSinceCar` | Waves elapsed without a car spawn |
| `ArmourChance`, `ArmourMaxSince`, `ArmourCount` | Recalculated each wave based on `attkWave` vs `ARMOUR_START_WAVE` |
| `carChance`, `carMaxSince`, `carCount` | Same pattern for cars |

### 2.5 Player Tracking

| Variable | Scope | Description |
|----------|-------|-------------|
| `playersInWave` | Global (publicVariable) | Array of player UIDs who were alive when the wave started. Used to kill late-joiners. Cleared in `fn_endWave`. |
| `revivedPlayers` | Global | Array, populated elsewhere; initialised to `[]` at loop start |
| `MIND_CONTROLLED_AI` | Global (publicVariable) | Units converted by Mind Control Gas; killed and cleared in `fn_endWave` |

### 2.6 Respawn System

| Variable | Scope | Description |
|----------|-------|-------------|
| `RESPAWN_TICKETS` | Global (publicVariable) | Resolved from `RESPAWN_TICKETS` param; passed to `BIS_fnc_respawnTickets` |
| `RESPAWN_TIME` | Global (publicVariable) | Resolved from `RESPAWN_TIME` param. Overridden to `99999` during combat if tickets = 0; reset to `0` in `fn_endWave` |

---

## 3. "Wave Over" Detection — Method

> **It is a polling loop. No event handler is used for wave-end detection.**

```sqf
// missionLoop.sqf — inner while loop, runs every frame with no sleep
if (EAST countSide allUnits == 0) exitWith {};
```

The expression `EAST countSide allUnits` is a built-in Arma function that counts all units of
the EAST side that are **alive** across the entire simulation network. When it reaches `0`,
the `exitWith` immediately breaks the inner `while`, and the outer loop falls through to
`bulwark_fnc_endWave`.

**Score/kill tracking** uses per-unit event handlers added in `spawnInfantry.sqf`:
```sqf
_unit addEventHandler ["Hit",    killPoints_fnc_hit];
_unit addEventHandler ["Killed", killPoints_fnc_killed];
```
These fire `score/functions/fn_hit.sqf` and `fn_killed.sqf` respectively for points accounting only.
They do **not** contribute to wave-end logic.

---

## 4. Parameter Injection

All lobby parameters are defined in `description.ext → class Params` and read at runtime
via `BIS_fnc_getParamValue`. They are injected at **three distinct points**:

### 4.1 `editMe.sqf` (server init, runs once before loop)

This is the primary resolution site. All parameters become named globals:

| Param key | Global variable | Notes |
|-----------|----------------|-------|
| `HOSTILE_MULTIPLIER` | `HOSTILE_MULTIPLIER` | Wave size scalar (`squadCount = attkWave × HOSTILE_MULTIPLIER`) |
| `HOSTILE_TEAM_MULTIPLIER` | `HOSTILE_TEAM_MULTIPLIER` | Divided by 100; extra units per player |
| `PISTOL_HOSTILES` | `PISTOL_HOSTILES` | Wave threshold for pistol-only arms |
| `BULWARK_RADIUS` | `BULWARK_RADIUS` | Mission area size in metres |
| `BULWARK_MINSIZE` | `BULWARK_MINSIZE` | Min qualifying spawn room (m²) |
| `BULWARK_LANDRATIO` | `BULWARK_LANDRATIO` | Min land coverage % |
| `LOOT_HOUSE_DENSITY` | `LOOT_HOUSE_DENSITY` | Min buildings in radius |
| `LOOT_HOUSE_DISTRIBUTION` | `LOOT_HOUSE_DISTRIBUTION` | Every Nth building gets loot |
| `LOOT_ROOM_DISTRIBUTION` | `LOOT_ROOM_DISTRIBUTION` | Every Nth room position gets loot |
| `LOOT_SUPPLYDROP` | `LOOT_SUPPLYDROP` | Divided by 100 → radius fraction |
| `RESPAWN_TIME` | `RESPAWN_TIME` | Default respawn timer |
| `RESPAWN_TICKETS` | `RESPAWN_TICKETS` | Total team tickets |
| `PARATROOP_COUNT` | `PARATROOP_COUNT` | Units in paratroop support |
| `SCORE_KILL` | `SCORE_KILL` | Base kill score |
| `SCORE_HIT` | `SCORE_HIT` | Per-hit score |
| `SCORE_DAMAGE_BASE` | `SCORE_DAMAGE_BASE` | Damage bonus scalar |
| `DAY_TIME_FROM` | `DAY_TIME_FROM` | Earliest mission start hour |
| `DAY_TIME_TO` | `DAY_TIME_TO` | Latest mission start hour |

These globals are then `publicVariable`'d in `initServer.sqf` immediately after `editMe.sqf` completes.

### 4.2 `missionLoop.sqf` (read inline at loop start, stored as locals)

Three parameters are read **directly** into local variables before the outer `while`:

```sqf
_downTime    = ("DOWN_TIME"      call BIS_fnc_getParamValue);  // inter-wave sleep duration
_specialWaves = ("SPECIAL_WAVES" call BIS_fnc_getParamValue);  // flag (READ BUT UNUSED — dead code)
_maxWaves    = ("MAX_WAVES"      call BIS_fnc_getParamValue);  // win condition
```

> **Note:** `_specialWaves` is read into a local variable but **never referenced anywhere in the loop
> body**. Special wave logic is instead gated on `attkWave >= 5` inside `fn_startWave`. This variable
> is a dead parameter binding — a potential hook for Opus to implement a hard special-waves toggle.

### 4.3 `hostiles/createWave.sqf` (read inline per wave)

```sqf
_armourStartWave = "ARMOUR_START_WAVE" call BIS_fnc_getParamValue;
```

Read fresh each wave to drive all armour/car spawn probability tables.

---

## 5. Wave Lifecycle — Flowchart

```
[SERVER STARTUP]
       │
       ▼
[initServer.sqf]
  Load lists (locationLists, loot\lists, hostiles\lists)
  editMe.sqf → resolve ALL params → named globals
  createBase.sqf → bulwarkRoomPos
  Broadcast globals (publicVariable)
  buildPhase = true (missionNamespace, broadcast)
       │
       ▼
[missionLoop.sqf — preamble]
  Revive/unstick all players
  Read _downTime, _specialWaves (dead), _maxWaves
  attkWave = 0, waveUnits = [[],[],[]]
  revivedPlayers = [], MIND_CONTROLLED_AI = []
  wavesSinceArmour = 0, wavesSinceCar = 0, wavesSinceSpecial = 0
  SatUnlocks = []
  spawnLoot.sqf (initial loot)
  sleep 15
  runMissionLoop = true, missionFailure = false
  buildPhase = true (missionNamespace)
  BIS_fnc_respawnTickets → RESPAWN_TICKETS
       │
       ▼
┌──────────────────────────────────────────────────────────┐
│  OUTER LOOP  while { runMissionLoop }  [one iter = 1 wave]│
│                                                          │
│  ┌── [LOOT / BUILD PHASE] ──────────────────────────┐   │
│  │  buildPhase = TRUE                               │   │
│  │  (fn_endWave sleeping _downTime seconds here)    │   │
│  └──────────────────────────────────────────────────┘   │
│       │                                                  │
│       ▼                                                  │
│  bulwark_fnc_startWave ──────────────────────────────┐   │
│  │  Countdown 15 s                                   │   │
│  │  Rotate waveUnits window; delete old corpses      │   │
│  │  attkWave += 1  (publicVariable)                  │   │
│  │  Snapshot playersInWave (publicVariable)          │   │
│  │  waveSpawned = false                              │   │
│  │  buildPhase = FALSE  ◄── COMBAT STARTS HERE       │   │
│  │  Determine specialWave / SpecialWaveType          │   │
│  │  Launch special scripts (suicideWave, etc.)       │   │
│  │  Notify players (BIS_fnc_showNotification)        │   │
│  │  Clean dead vehicles                              │   │
│  │  execVM createWave.sqf → waitUntil scriptDone     │   │
│  │   └─ Spawn squads (LEVEL_1, 2, 3), vehicles       │   │
│  │   └─ waveSpawned = true                           │   │
│  │  Spawn new loot (waves > 1)                       │   │
│  └───────────────────────────────────────────────────┘   │
│       │                                                  │
│       ▼                                                  │
│  ┌── [COMBAT PHASE] ────────────────────────────────┐   │
│  │  buildPhase = FALSE                              │   │
│  │                                                  │   │
│  │  INNER LOOP while { runMissionLoop }             │   │
│  │  (no sleep — tight poll)                         │   │
│  │                                                  │   │
│  │  ┌─ POLL: EAST countSide allUnits == 0 ?         │   │
│  │  │   YES ──► exitWith {}  ────────────────────────── WAVE CLEARED
│  │  │   NO  ──► continue                            │   │
│  │  │                                               │   │
│  │  └─ POLL: all _allHPs dead/incapacitated         │   │
│  │       AND _respawnTickets <= 0 ?                 │   │
│  │       YES (×3 checks, sleep 1 each) ──►          │   │
│  │         runMissionLoop = false                   │   │
│  │         missionFailure = true                    │   │
│  │         "End1" BIS_fnc_endMissionServer ─────────────► [GAME OVER]
│  └──────────────────────────────────────────────────┘   │
│       │                                                  │
│       ▼ (inner loop exited by EAST == 0)                │
│  if missionFailure exitWith {}                           │
│  if attkWave == _maxWaves exitWith {                     │
│       "End2" BIS_fnc_endMissionServer  ─────────────────► [VICTORY]
│  }                                                       │
│       │                                                  │
│       ▼                                                  │
│  bulwark_fnc_endWave ───────────────────────────────┐   │
│  │  playersInWave = [] (publicVariable)             │   │
│  │  buildPhase = TRUE  ◄── LOOT PHASE STARTS        │   │
│  │  Show "Wave N complete!" notification            │   │
│  │  RESPAWN_TIME = 0 (publicVariable)               │   │
│  │  forceRespawn DEAD players                       │   │
│  │  Revive INCAPACITATED players                    │   │
│  │  Delete MIND_CONTROLLED_AI                       │   │
│  │  sleep _downTime  ◄─── DOWN_TIME param           │   │
│  └───────────────────────────────────────────────────┘   │
│       │                                                  │
│       └──────────────────── (back to outer loop top)     │
└──────────────────────────────────────────────────────────┘
```

---

## 6. State Variables — Hook Reference for Opus

The following is the complete list of variables Opus should read or mutate to integrate with the wave system.

### Read-Only (observe, do not write)

| Variable | Read from | Meaning |
|----------|-----------|---------|
| `attkWave` | Global | Current wave number (1 after first wave starts) |
| `buildPhase` | `missionNamespace getVariable ["buildPhase", true]` | `true` = safe to act; `false` = wave in progress |
| `EAST countSide allUnits` | Inline expression | Live enemy count |
| `waveSpawned` | Global | All spawn scripts for this wave have completed |
| `specialWave` | Global | This wave has a special modifier |
| `SpecialWaveType` | Global | String name of special modifier |
| `suicideWave`, `nightWave`, `fogWave`, etc. | Global | Individual special booleans |
| `playersInWave` | Global | UID array of players locked into this wave |
| `wavesSinceSpecial` | Global | Cooldown counter for special wave cadence |

### Write Targets (mutate to drive state changes)

| Variable | Location | Effect if mutated |
|----------|----------|-------------------|
| `runMissionLoop` | Global | Set to `false` to halt the outer `while` loop |
| `missionFailure` | Global | Set to `true` alongside `runMissionLoop=false` to trigger End1 instead of endWave |
| `attkWave` | Global + `publicVariable` | Changing before wave start alters difficulty scaling and armour unlock tables |
| `wavesSinceSpecial` | Global | Set to `maxSinceSpecial` to force a special wave next round |
| `MIND_CONTROLLED_AI` | Global | Push units here for guaranteed kill in `fn_endWave` |
| `waveUnits select 0` | Global array index | Push unit refs here for automatic body-cleanup scheduling |
| `RESPAWN_TIME` | Global + `publicVariable` + `remoteExec setPlayerRespawnTime` | Override respawn timer; must also `remoteExec` manually |

### Parameters (resolved once; do not re-read during runtime unless restarting the loop)

| Param key | Runtime variable | Default |
|-----------|-----------------|---------|
| `DOWN_TIME` | `_downTime` (local in missionLoop.sqf) | `60` s |
| `MAX_WAVES` | `_maxWaves` (local in missionLoop.sqf) | `"infinite"` |
| `SPECIAL_WAVES` | `_specialWaves` — **dead code, unread** | `1` |
| `HOSTILE_MULTIPLIER` | `HOSTILE_MULTIPLIER` | `1` |
| `HOSTILE_TEAM_MULTIPLIER` | `HOSTILE_TEAM_MULTIPLIER` | `0.5` (50/100) |
| `ARMOUR_START_WAVE` | Read inline in `createWave.sqf` per wave | `5` |
| `RESPAWN_TICKETS` | `RESPAWN_TICKETS` | `0` |
| `RESPAWN_TIME` | `RESPAWN_TIME` | `10` |
| `BODY_CLEANUP` | read inline in `fn_startWave` | `0` |

---

## 7. Known Issues / Integration Notes

1. **`_specialWaves` param is a dead binding.** `description.ext` exposes `SPECIAL_WAVES` (default `1`,
   values `0`/`1`), `initServer.sqf` publicizes it, and `missionLoop.sqf` reads it into `_specialWaves`.
   However, `_specialWaves` is **never checked** in `fn_startWave` — special wave logic is gated only
   on `attkWave >= 5`. Disabling special waves from the lobby has no effect. This is a bug and a clear
   hook point: `fn_startWave.sqf` line ~`if (...)then{specialWave=true}` should include
   `&& _specialWaves != 0` (but `_specialWaves` is a local in `missionLoop.sqf`, so it would need to
   be made global or the param re-read inside `fn_startWave`).

2. **No sleep in the inner combat loop.** The `while {runMissionLoop}` loop has no `sleep` call on
   the happy path. On servers with many units this loop runs every simulation frame on the machine
   executing `missionLoop.sqf`. A `sleep 0.1` or `sleep 0.5` would reduce server load with no
   perceptible effect on wave-end detection latency.

3. **`EAST countSide allUnits` is not filtered.** If any non-wave EAST unit exists on the map
   (e.g. a placed module, a static object mis-classified as EAST, or a scripted unit someone forgot
   to clean up), the wave will never end. `waveUnits select 0` provides the correct filtered list
   to check against instead.

4. **`waveUnits` is never used for the end-of-wave check.** It accumulates unit references for
   corpse cleanup but is not used to count remaining enemies. The two sources of truth (side count
   vs. tracked array) can drift if a hostile is re-sided (e.g. Mind Control Gas).
