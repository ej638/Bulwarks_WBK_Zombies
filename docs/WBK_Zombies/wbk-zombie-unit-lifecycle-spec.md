# WBK Zombies — Unit Lifecycle Technical Specification
**Role:** Senior SQF Architect & Modding Consultant  
**Purpose:** Feature Extraction and API Audit for integration into the Dynamic Bulwarks wave system.  
**Source files analysed:**
- `Webknights Zombies/WBK_Zombies/config.cpp`
- `Webknights Zombies/WBK_Zombies/WBK_Zombies_Units/config.cpp`
- `Webknights Zombies/WBK_Zombies/special_Infected/config.cpp`
- `Webknights Zombies/WBK_Zombies/AI/` (all 8 files)
- `Webknights Zombies/WBK_Zombies/bootstrap/XEH_preInit.sqf` (HP globals / CBA settings)

---

## 1. Initialization Parameters

### 1.1 Script Call Signatures

All AI scripts share a common **guard block** executed before any initialization:

```sqf
if ((isPlayer _unit) or !(isNil {_unit getVariable "WBK_AI_ISZombie"}) or !(alive _unit)) exitWith {};
```

This means any unit that: is a player, already has `WBK_AI_ISZombie` set, or is dead, will refuse initialization silently.

| Script | Call Pattern | Parameters | Notes |
|--------|-------------|------------|-------|
| `WBK_AI_Walker.sqf` | `[_unit, _isCrawler] execVM "..."` | `params ["_unitWithSword","_isCrawler"]` | `_isCrawler=true` → `WBK_Crawler_Idle`; `false` → random Walker idle |
| `WBK_AI_Runner.sqf` | `[_unit, _isCalm, _isCorrupted] execVM "..."` | `params ["_unitWithSword","_isCalm","_isCorrupted"]` | Three distinct archetypes in one script |
| `WBK_AI_Middle.sqf` | `_unit execVM "..."` | `params ["_unitWithSword"]` | **Unique:** also enforces `!(local _unitWithSword) exitWith {}` |
| `Ai_Melee_Zombie.sqf` | `_unit execVM "..."` | `params ["_unitWithSword"]` | Requires `IMS_Melee_Weapons` global to exist |
| `WBK_ShooterZombie.sqf` | `_unit execVM "..."` | `params ["_mutant"]` | Uses Arma native AI targeting, does not disable `FSM` at startup |
| `WBK_AI_ZombieExplosion.sqf` | `_unit execVM "..."` | `params ["_unitWithSword"]` | Bloater; strips and forces `WBK_SpecialInfected_Bloater` uniform |
| `WBK_AI_Stunden.sqf` | `_unit execVM "..."` | `_unitWithSword = _this` (legacy single-arg) | Screamer; strips and forces `WBK_SpecialInfected_Screamer` uniform |
| `WBK_AI_Tatzelwurm.sqf` | `_unit execVM "..."` | `_unitWithSword = _this` (legacy single-arg) | Leaper; requires Leaper uniform set via `setUnitLoadout` |

#### Runner Archetypes (`WBK_AI_Runner.sqf`)

| `_isCalm` | `_isCorrupted` | Zeus Label | HP Source | Initial Moveset |
|-----------|----------------|------------|-----------|-----------------|
| `true` | `false` | Sprinter (Calm) | `WBK_Zombies_RunnerHP` | `WBK_Runner_Calm_Idle` |
| `false` | `false` | Sprinter (Angry) | `WBK_Zombies_RunnerHP` | `WBK_Runner_Angry_Idle` |
| `false` | `true` | Corrupted Body | `WBK_Zombies_CorruptedHP` | `WBK_Runner_Angry_Idle` |


### 1.2 Mandatory `setVariable` Calls

These three variables **must** be present for any WBK zombie to function. They are set globally (`true` broadcast argument) so all clients may read defensive checks against them.

| Variable | Value | Broadcast | Purpose |
|----------|-------|-----------|---------|
| `"WBK_AI_ISZombie"` | `true` | `true` (global) | Re-initialization guard. If set, no AI script will re-run on this unit. |
| `"WBK_SynthHP"` | `<float>` HP value | `true` (global) | Synthetic HP pool. The HitPart handler modifies this; vanilla Arma damage is ignored entirely. |
| `"WBK_AI_ZombieMoveSet"` | `"<animset_string>"` | `true` (global) | Current locomotion state string. The HitPart handler reads this to gate leg-cripple and stagger logic (e.g., will not apply crawler conversion to a unit already in `"WBK_Crawler_Idle"`). |

#### Secondary `setVariable` calls set during init

| Variable | Set By | Purpose |
|----------|--------|---------|
| `"WBK_AI_AttachedHandlers"` | All scripts (last line) | Array of CBA PFH IDs. Killed/Deleted EHs iterate this to clean up all PFHs. **Absence means leaked handlers on death.** |
| `"WBK_Zombie_CustomSounds"` | Conditional (WW2 units, Corrupted) | 5-element sound pack array `[idle, walk, attack, death, burning]`. Overrides default sound strings in PFH loops. |
| `"WBK_Zombie_WeaponHolders"` | `Ai_Melee_Zombie.sqf` only | `[weaponClass, holderObject]` array. Holder attached to right hand. Must be cleaned up on kill/delete. |
| `"WBK_IsUnitLocked"` | PFH loops (runtime) | Internal pathfinding state: `nil` = free-roaming via `doMove`, `0` = direct-drive via `setVelocityTransformation`. |
| `"WBK_AI_LastKnownLoc"` | `_loopPathfindDoMove` (runtime) | Last recorded target position. Used to throttle `doMove` calls — only re-issues `doMove` if target moves > `WBK_Zombies_TargetPosChanged` (default: 8m). |
| `"isMutant"` | All scripts if `WBK_IsPresent_Necroplague` is defined | Necroplague mod compatibility flag. |
| `"dam_ignore_hit0"` / `"dam_ignore_effect0"` | All scripts if `WBK_IsPresent_PIR` is defined | PIR mod compatibility — suppresses PIR damage processing. |


### 1.3 HP Defaults (CBA Settings, `XEH_preInit.sqf`)

All HP values and global distances are configured via CBA settings and exist as missionNamespace globals by the time any wave script runs.

| CBA Setting Key | Global Variable | Default Value | Description |
|----------------|-----------------|---------------|-------------|
| `WBK_Zommbies_Halth_Walker` | `WBK_Zombies_WalkerHP` | **30** | Walker / Crawler |
| `WBK_Zommbies_Halth_Trig` | `WBK_Zombies_TriggermanHP` | **30** | Triggerman (Shooter) |
| `WBK_Zommbies_Halth_Shamb` | `WBK_Zombies_MiddleHP` | **40** | Shambler |
| `WBK_Zommbies_Halth_Runner` | `WBK_Zombies_RunnerHP` | **50** | Sprinter (all variants) |
| `WBK_ZommbiesMeleeHealthParam` | `WBK_Zombies_MeleeHP` | **60** | Melee Zombie |
| `WBK_ZommbiesBloaterHealthParam` | `WBK_Zombies_BloaterHP` | **80** | Bloater |
| `WBK_ZommbiesLeaperHealthParam` | `WBK_Zombies_LeaperHP` | **120** | Leaper (Tatzelwurm) |
| `WBK_ZommbiesScreamerHealthParam` | `WBK_Zombies_ScreamerHP` | **160** | Screamer (Stunden) |
| `WBK_ZommbiesCorruptedHealthParam` | `WBK_Zombies_CorruptedHP` | **200** | Corrupted Body (Runner variant) |
| `WBK_Zommbies_HeadshotMultiplier` | `WBK_Zombies_HeadshotMP` | **5** | Headshot damage multiplier |
| `WBK_Zommbies_HowFarCanSee` | `WBK_Zombies_MoveDistanceLimit` | **150** | Chase range (m) for regular zombies |
| `WBK_Zommbies_HowFarCanSee_SI` | `WBK_Zombies_SpecialInfected_MoveDistanceLimit` | **300** | Chase range (m) for specials |
| `WBK_Zommbies_PathingPositionChange` | `WBK_Zombies_TargetPosChanged` | **8** | Min target movement (m) to trigger `doMove` recalc |

> **Integration note:** To override HP for a specific spawned unit, call `setVariable ["WBK_SynthHP", yourValue, true]` **after** the AI script executes. The script itself overwrites `WBK_SynthHP` early in its body, so a pre-set value will be clobbered.

---

## 2. State Machine Analysis

### 2.1 Architecture Overview

Every zombie type (except the Shooter) registers exactly **3 CBA PerFrameHandlers** at the end of its AI script and stores their IDs in `WBK_AI_AttachedHandlers`. The three handlers form a separation-of-concerns pipeline:

| Handler | Role | Frequency |
|---------|------|-----------|
| `_actFr` | Combat logic: attack trigger, AI sub-module suppression | Medium–High (0.1–0.5s) |
| `_loopPathfind` | Direct-drive pathing: LOS raycast, velocity steering | High (0.01–0.1s) |
| `_loopPathfindDoMove` | Navigation orders & ambient sound | Low (2.4–10s) |

The **Shooter** (`WBK_ShooterZombie.sqf`) is the exception: it registers only `_loopPathfindDoMove` (at 3s) and relies on native Arma AI for targeting and movement.


### 2.2 Handler Frequencies Per Type

| Type | `_actFr` | `_loopPathfind` | `_loopPathfindDoMove` | Total PFHs |
|------|----------|-----------------|----------------------|------------|
| **Walker / Crawler** | 0.5 s | 0.1 s | 10 s (fixed) | 3 |
| **Shambler** | 0.1 s | 0.1 s | random [4,5,6,7] s | 3 |
| **Runner (all)** | 0.1 s | 0.1 s | random [4,5,6,7] s | 3 |
| **Melee Zombie** | 0.1 s | 0.1 s | random [4,5,6,7] s | 3 |
| **Screamer** | 0.1 s | 0.1 s | random [4,5,6,7] s | 3 |
| **Bloater** | 0.1 s | 0.1 s | — (not confirmed) | 3 |
| **Leaper** | 0.1 s | **0.01 s** | 2.4 s | 3 |
| **Shooter** | — | — | 3 s | **1** |


### 2.3 `_actFr` — Combat Logic Detail

**Entry gate (all types):**
```sqf
if (alive _mutant != isAwake _mutant) exitWith { _mutant setDamage 1; };
_mutant allowDamage false;
if (!(simulationEnabled _mutant) || !(isTouchingGround _mutant) || !(alive _mutant) ||
    !(isNull attachedTo _mutant) || !(animationState _mutant in [<valid locomotion states>])
) exitWith {};
```

- `alive != isAwake` is a kill-switch for the "incapacitated but not dead" edge case — it force-kills the zombie.
- `allowDamage false` is set **every tick**. This actively prevents the vanilla Arma engine from applying HP damage and suppression reactions. If this call stops executing (e.g., handler leaked), the zombie becomes vulnerable to normal Arma damage.
- The animation whitelist acts as the state gate — if the zombie is playing a hit reaction, fall, or attack animation it is not in the whitelist and the handler exits immediately, preventing attack spamming mid-stagger.

**AI module suppression (called every tick inside the whitelist gate):**
```sqf
_mutant disableAI "MINEDETECTION";  _mutant disableAI "WEAPONAIM";
_mutant disableAI "SUPPRESSION";    _mutant disableAI "COVER";
_mutant disableAI "AIMINGERROR";    _mutant disableAI "TARGET";
_mutant disableAI "AUTOCOMBAT";     _mutant disableAI "FSM";
_mutant setBehaviour "CARELESS";
```
This is intentionally called every tick because Arma re-enables AI sub-modules after certain events (e.g., unit taking damage, path recalculation). The repeated disable is the lock that keeps the zombie as a pure animation-driven entity.

**Attack trigger (Walker/Shambler example):**
```sqf
if ((_en distance _mutant) <= 2) and !(isNil {_mutant getVariable "WBK_IsUnitLocked"}) then {
    // play attack animation via remoteExec ["switchMove", 0]
};
```
`WBK_IsUnitLocked` being non-nil signals the zombie is in direct-drive mode (close to target), which is the only condition under which an attack is valid.

**Runner-specific: calm → angry state transition:**
```sqf
case (... (animationState in calm states) and (_en distance _mutant) <= 200): {
    [_mutant, "WBK_Runner_Calm_To_Angry", ...] remoteExec ["switchMove", 0];
    [_mutant, "WBK_Runner_Angry_Idle"] remoteExec ["playMove", 0];
};
```
A Runner spawned with `_isCalm = true` automatically transitions to the angry attack moveset upon detecting an enemy within 200m.


### 2.4 `_loopPathfind` — Chase Exit Conditions

The zombie **stops chasing** and releases direct-drive lock when ANY of these conditions are true:

| Condition | Variable/Check |
|-----------|----------------|
| Simulation disabled (e.g., LOD culled) | `!(simulationEnabled _unit)` |
| Unit is being remote-controlled by a player | `!(isNull (remoteControlled _unit))` |
| No enemy known | `isNull _nearEnemy` |
| Enemy is dead | `!(alive _nearEnemy)` |
| Zombie is dead | `!(alive _unit)` |
| Zombie is attached to a vehicle | `!(isNull attachedTo _unit)` |
| Zombie is incapacitated (crawler downed) | `lifeState _unit == "INCAPACITATED"` |
| Target is beyond engagement range | `_unit distance _nearEnemy >= WBK_Zombies_MoveDistanceLimit` |

On any exit condition: `_unit setVariable ["WBK_IsUnitLocked", nil]` — returning the zombie to the free-roaming `doMove` state.

**In-range path logic (two modes, checked via `lineIntersectsSurfaces`):**

- **LOS clear** and on roughly the same elevation (+/- 1.45m): Direct-drive mode. `WBK_IsUnitLocked = 0`, `disableAI "MOVE"`, manually select the correct animation via config lookup, apply `setVelocityTransformation` toward enemy each tick.
- **LOS blocked** (wall/obstacle between zombie and target): Release direct-drive, `enableAI "MOVE"/"ANIM"`, issue `doMove` to enemy's position.

This two-mode system means the zombie AI tries to walk through walls in direct-drive mode (straight-line), and only falls back to Arma's nav-mesh pathfinding when an obstacle is detected. `WBK_Zombies_TargetPosChanged` throttles how often `doMove` is re-issued in nav-mesh mode.


### 2.5 Shooter — Simplified State Machine

The Shooter does not use `_actFr` or `_loopPathfind`. It relies entirely on Arma's native AI for targeting and firing. Its single `_loopPathfindDoMove` handler (3s) only:
- Checks for a live enemy; if none → `setBehaviour "AWARE"`, play idle animation, play idle sound
- If enemy found → `setBehaviour "COMBAT"`, play armed walk animation, play agro sound


### 2.6 Screamer — Special Ability State

Inside the Screamer's `_actFr` (0.1s), two additional states beyond melee:

| Condition | Action |
|-----------|--------|
| LOS *blocked*, target in `WBK_Zombies_ScreamerDistance` range, no `CanMakeClue` cooldown | Play `screamer_knowsAbout` sound (audio alert only, no mechanic) |
| LOS *clear*, target in range, out of `CanMakeClue` + no `CanScream` cooldown | Play scream animation, rally all nearby zombies (`doMove` toward screamer), run screen-blur/chrom-aberration effect on affected *players* via targeted `remoteExec ["spawn", _x]` |

The scream cooldown is controlled by `WBK_Zombies_ScreamerCooldown` (default 20s).

---

## 3. Damage & Hit Logic

### 3.1 Synthetic HP System — Bypass of Vanilla Arma 3

The WBK damage system completely replaces Arma's native HP. The sequence is:

1. During init, `[_unit, { _this removeAllEventHandlers "HitPart"; _this addEventHandler ["HitPart", {...}] }] remoteExec ["spawn", 0, true]` is called — registering the handler on the **server** persistently.
2. `allowDamage false` is set every `_actFr` tick — preventing the Arma engine from ever modifying native HP.
3. All damage is deducted from the `WBK_SynthHP` variable.
4. A kill is triggered **solely** by: `[_target, [1, false, _shooter]] remoteExec ["setDamage", 2]` — this is only called when `WBK_SynthHP <= 0`.

The native `damage` value of these units is effectively always `0.0` during their lifetime. Vanilla tools like `setDamage 0.5` will have no lasting effect. The only way to kill a WBK zombie from external code is to either call `setDamage 1` or set `WBK_SynthHP` to `0` or below (the PFH will detect it on next trigger and call `alive != isAwake`).


### 3.2 Damage Calculation Table

The `HitPart` handler uses a `switch true do` priority chain. The **first matching case wins**:

| Priority | Condition (`_ammo` array) | Formula | Visual Response |
|----------|--------------------------|---------|-----------------|
| 1st — Explosive | `(_ammo select 3) >= 0.7` **AND** not already a crawler | `WBK_SynthHP -= (_ammo select 0) × 2` | Stagger (fall forward/back animation) |
| 2nd — Headshot | `(_selection select 0) in ["head","neck"]` AND not mid-fall | `WBK_SynthHP -= (_ammo select 0) × WBK_Zombies_HeadshotMP` | Stagger + possible decapitation |
| 3rd — Leg Cripple | `(_selection select 0) in [leg bone selections]` AND not already crawler | No HP deduct | Forced crawler transformation |
| 4th — Body | Default (all other selections) | `WBK_SynthHP -= (_ammo select 0)` | Minor hit gesture animation |

> **Note on `_ammo` indices:** Inside `HitPart`, `_ammo` is the ammo's config data array. Index `0` is the `hit` value (direct hit damage) and index `3` is `explosive` damage rating. A value of `0.7` or higher on index 3 identifies grenades, rockets, and explosive projectiles.


### 3.3 Headshot Multiplier & Decapitation

Default multiplier: **×5** (`WBK_Zombies_HeadshotMP`). Configurable via CBA settings.

On a lethal headshot, additional cosmetic logic fires based on projectile power (`_ammo select 0`):

| Threshold | Effect |
|-----------|--------|
| `< 10.5` | No decapitation; `setDamage 1` only |
| `>= 10.5` | Blood particle + decapitation sound. Hole texture applied: front or back depending on shooter angle. |
| `>= 14` | Full decapitation: headgear/goggles removed, face set to `WBK_DecapatedHead_Zombies_Normal` |


### 3.4 Leg Crippling

A hit on any of the 12 leg bone selections converts a standing zombie to crawler state:

```sqf
[_target, "WBK_Crawler_TransformTo"] remoteExec ["switchMove", 0];
[_target, "WBK_Crawler_Idle"] remoteExec ["playMoveNow", 0];
_target setVariable ["WBK_AI_ZombieMoveSet", "WBK_Crawler_Idle", true];
```

| Type | Behaviour on Leg Hit |
|------|---------------------|
| Walker | **Always** converts to crawler (no HP deduction from this hit) |
| Middle | **Always** converts to crawler |
| Melee | **Not applicable** — Melee zombie has no leg branch; default body-hit applies |
| Runner | **30% chance** converts to crawler; **70% chance** only plays `WBK_Runner_Fall_Forward` (no permanent state change) |
| Screamer | **Always** falls forward only (no crawler conversion branching exists) |


### 3.5 Tatzelwurm (Leaper) Damage Differences

The Leaper has a simplified HitPart handler:
- **No explosive branch** — all hits use 1:1 or headshot multiplier only.
- On every non-lethal hit: `_target enableAI "MOVE"` is called.
- Execution attack (`Leaper_Execution`): Called when target has `damage >= 0.5`, is alive, not a Space Marine, and Leaper is within 2.6m. Attaches Leaper to victim, plays execution animation, sets victim `setDamage 1`.


### 3.6 Bloater Damage Differences

The Bloater has no headshot or leg-cripple branch:
- Explosive (`>= 0.7`): `× 2` stagger
- Default: `× 1` body hit
- At melee range (≤4m) with `WBK_IsUnitLocked` set: triggers `AApersMine` explosion and `setDamage 1` on self — the suicide burst. This deals area damage to nearby non-zombie players within 7m.

---

## 4. Networking & Locality

### 4.1 `remoteExec` Call Inventory

| Call | Target | Persistent (JIP) | Purpose |
|------|--------|-----------------|---------|
| `[_unit, {...}] remoteExec ["spawn", 0, true]` | `0` = server | ✅ | HitPart EH registration |
| `[_unit, "anim"] remoteExec ["switchMove", 0]` | `0` = all machines | ❌ | Animation synchronisation |
| `[_unit, "anim"] remoteExec ["playMove", 0]` | `0` = all machines | ❌ | Animation synchronisation |
| `[_unit, "anim"] remoteExec ["playMoveNow", 0]` | `0` = all machines | ❌ | Immediate anim override sync |
| `[_unit, "face"] remoteExec ["setFace", 0]` | `0` = all machines | ❌ | Face texture sync |
| `[_unit, [...]] remoteExec ["addForce", _unit]` | `_unit` = unit owner | ❌ | Ragdoll force on kill (requires locality) |
| `[_unit, [1, false, _killer]] remoteExec ["setDamage", 2]` | `2` = unit owner | ❌ | Apply kill damage (requires locality) |
| `[_unit, "anim"] remoteExec ["playActionNow", 0]` | `0` = all machines | ❌ | Gesture/attack sync |
| `[victim, {...}] remoteExec ["spawn", victim]` | `victim` = affected player | ❌ | Screamer screen effect (UI must run on player client) |
| `[_unit, n] remoteExec ["concentrationToZero", _unit]` | `_unit` = target zombie | ❌ | Screamer disrupts nearby zombie concentration |


### 4.2 Where AI Logic Physically Runs

CBA PerFrameHandlers are **local** — they execute on the machine that called `CBA_fnc_addPerFrameHandler`. This means:

- If the AI script is `execVM`'d from a client (e.g., Zeus dialog), the PFH loops run **on that client**.
- If the AI script is `execVM`'d from the server (e.g., a wave spawner), the PFH loops run **on the server**.
- **Only `WBK_AI_Middle.sqf` enforces locality via `!(local _unitWithSword) exitWith {}`**. All other scripts will silently run on the wrong machine without error.

This is a critical integration point — **for the Bulwarks wave system, all AI scripts must be executed on the server (or unit owner) to ensure loops run where the unit is local.**

Correct calling pattern for Bulwarks:
```sqf
// From the server wave spawner, after creating unit:
[_spawnedUnit] remoteExec ["\WBK_Zombies\AI\WBK_AI_Walker.sqf", 2]; // target 2 = unit owner
// OR if unit is local to server:
[_spawnedUnit, true] execVM "\WBK_Zombies\AI\WBK_AI_Walker.sqf";
```


### 4.3 Locality Contract Summary

| Operation | Runs On | Requires Locality |
|-----------|---------|-----------------|
| CBA PFH (combat logic, pathfinding) | Calling machine | Yes (should match unit owner) |
| HitPart EH (damage deduction) | Server (remoteExec target 0) | No (always on server) |
| `setDamage 1` kill | Unit owner (remoteExec target 2) | Yes |
| `addForce` ragdoll | Unit owner (remoteExec to `_target`) | Yes |
| Animation changes | All clients (remoteExec target 0) | No |
| `WBK_SynthHP` variable read/write | Any (broadcast `true`) | No |
| Killed / Deleted EHs | Runs wherever unit is local | Yes |

---

## 5. Performance Cost

### 5.1 PFH Count and Interval Summary

| Type | PFH Count | `_actFr` | `_loopPathfind` | `_loopPathfindDoMove` | Hottest Loop |
|------|-----------|----------|-----------------|----------------------|--------------|
| Walker | 3 | 0.5 s | 0.1 s | 10 s | `_loopPathfind` @ 0.1 s |
| Crawler | 3 | 0.5 s | 0.1 s | 10 s | `_loopPathfind` @ 0.1 s |
| Shambler | 3 | 0.1 s | 0.1 s | rnd[4–7] s | Both @ 0.1 s |
| Runner | 3 | 0.1 s | 0.1 s | rnd[4–7] s | Both @ 0.1 s |
| Melee Zombie | 3 | 0.1 s | 0.1 s | rnd[4–7] s | Both @ 0.1 s |
| Screamer | 3 | 0.1 s | 0.1 s | rnd[4–7] s | Both @ 0.1 s |
| Bloater | 3 | 0.1 s | 0.1 s | ~rnd[4–7] s | Both @ 0.1 s |
| Leaper | 3 | 0.1 s | **0.01 s** | 2.4 s | `_loopPathfind` @ **0.01 s** |
| Shooter | **1** | — | — | 3 s | Minimal |

Additionally, every zombie registers these one-time event handlers at init:
- `HitPart` (on server via `remoteExec`)
- `Killed`
- `Deleted`
- `Suppressed`
- `FiredNear`
- `AnimStateChanged` (most types); Shooter uses `PathCalculated` + `Fired` instead


### 5.2 Expensive Operations Inside PFH Loops

Operations are ranked by approximate computational cost per tick:

| Operation | Handler | Cost | Notes |
|-----------|---------|------|-------|
| `lineIntersectsSurfaces [...]` | `_loopPathfind` | **Very High** | Full scene geometry raycast per tick. Called every 0.1s per zombie in range. |
| `checkVisibility [...]` | `_loopPathfind` (Middle only) | High | Visibility fraction check — lighter than `lineIntersectsSurfaces` but still a spatial query. |
| `findNearestEnemy _unit` | `_actFr`, `_loopPathfind` | Medium–High | Full unit scan; cost scales with total unit count in mission. Called up to 20/sec per zombie. |
| `configfile >> "CfgVehicles" >> typeOf >> "moves" >> ...` | `_loopPathfind` | Medium | Config tree walk to get animation action. Called every tick when unit is in direct-drive LOS mode. |
| `animationState`, `gestureState`, `lifeState`, `stance` | `_actFr` | Low-Medium | Native engine reads; cheap individually, significant at scale. |
| `setVelocityTransformation [...]` | `_loopPathfind` | Low | Physics velocity override; lightweight. |
| `allowDamage false` | `_actFr` | Low | Called each 0.1–0.5s tick; very cheap but meaningfully accumulates at scale. |


### 5.3 Horde Load Estimate

**50 Walkers (standard early-wave horde):**

| Handler | Calls/sec | Key Operation/call |
|---------|-----------|--------------------|
| `_actFr` (0.5s) | 100 | `findNearestEnemy`, animation state check |
| `_loopPathfind` (0.1s) | 500 | `lineIntersectsSurfaces` + `findNearestEnemy` |
| `_loopPathfindDoMove` (10s) | 5 | `doMove`, sound |
| **Total raycasts/sec** | **~500** | |

**50 Runners (late-wave horde):**

| Handler | Calls/sec | Key Operation/call |
|---------|-----------|--------------------|
| `_actFr` (0.1s) | 500 | `findNearestEnemy`, evade/attack logic |
| `_loopPathfind` (0.1s) | 500 | `lineIntersectsSurfaces` + `findNearestEnemy` |
| `_loopPathfindDoMove` (rnd 4–7s) | ~9 | `doMove`, sound |
| **Total raycasts/sec** | **~500** | |

**1 Leaper (special):**

| Handler | Calls/sec | Key Operation/call |
|---------|-----------|--------------------|
| `_actFr` (0.1s) | 10 | `findNearestEnemy`, `lineIntersectsSurfaces` (GEOM) |
| `_loopPathfind` (0.01s) | **100** | Velocity steering, `lineIntersectsSurfaces` (FIRE) |
| `_loopPathfindDoMove` (2.4s) | ~0.4 | `doMove`, sound |
| **Leaper total raycasts/sec** | **~110** | Equivalent to ~11 Walkers |

> **Conclusion:** A single Leaper costs roughly as much as 11 Walkers in `_loopPathfind` alone. Waves should budget accordingly. At 4–5 active Leapers, the raycast budget equals ~50 Walkers.


### 5.4 Optimization Notes for Bulwarks Integration

- **Walker is the most performance-efficient** high-volume unit. Its `_actFr` runs only at 0.5s vs 0.1s for all other types.
- The **Shooter generates almost zero CPU overhead** per unit — 1 handler at 3s interval. Suitable for high-count ranged waves.
- The `WBK_Zombies_MoveDistanceLimit` global is the primary performance lever. Reducing it from 150m to 80m halves the number of zombies running `lineIntersectsSurfaces` at any moment (zombies out of range skip the LOS branch entirely).
- **Leaked PFHs are catastrophic.** If `WBK_AI_AttachedHandlers` is not set before the unit is killed (e.g., unit dies during the asset-strip delay at init), the Killed EH will call `forEach nil` and PFHs will run forever. Bulwarks should add a `waitUntil { !(isNil {_unit getVariable "WBK_AI_AttachedHandlers"}) }` guard or use a short `sleep` after `execVM` before allowing the unit to take damage.
- The `_loopPathfindDoMove` interval randomisation (`selectRandom [4,5,6,7]`) in Runners, Shamblers, and Melee zombies is a built-in load-spreading mechanism. This prevents all units in a wave from issuing `doMove` on the same frame.

---

## 6. Unit Type Quick-Reference Card

| Type | Script | `params` Signature | HP (default) | PFHs | Chase Range | Leg Cripple | Special |
|------|--------|--------------------|-------------|------|-------------|-------------|---------|
| Walker | `WBK_AI_Walker.sqf` | `[_unit, false]` | 30 | 3 | 150 m | Always | — |
| Crawler | `WBK_AI_Walker.sqf` | `[_unit, true]` | 30 | 3 | 150 m | N/A (already crawler) | — |
| Shambler | `WBK_AI_Middle.sqf` | `[_unit]` | 40 | 3 | 150 m | Always | **Locality enforced** |
| Runner (Calm) | `WBK_AI_Runner.sqf` | `[_unit, true, false]` | 50 | 3 | 150 m | 30% chance | Auto-aggro at 200m |
| Runner (Angry) | `WBK_AI_Runner.sqf` | `[_unit, false, false]` | 50 | 3 | 150 m | 30% chance | Evade mechanic |
| Corrupted | `WBK_AI_Runner.sqf` | `[_unit, false, true]` | 200 | 3 | 150 m | 30% chance | Forces corrupt head |
| Melee Zombie | `Ai_Melee_Zombie.sqf` | `[_unit]` | 60 | 3 | 300 m | N/A | Weapon holder object |
| Triggerman | `WBK_ShooterZombie.sqf` | `[_unit]` | 30 | **1** | Native | None | Native Arma AI |
| Bloater | `WBK_AI_ZombieExplosion.sqf` | `[_unit]` | 80 | 3 | ~150 m | N/A | Suicide explosion at 4m |
| Screamer | `WBK_AI_Stunden.sqf` | `_unit execVM` | 160 | 3 | 300 m | Fall only | Rally scream, player UI effect |
| Leaper | `WBK_AI_Tatzelwurm.sqf` | `_unit execVM` | 120 | 3 | 300 m | N/A | Pounce/execution, 0.01s loop |
