# WBK Goliath — Boss Technical Specification

**Scope:** Server-performance risk analysis for the Bulwarks wave system.  
**Source files analysed:**
- `Webknights Zombies/WBK_Zombies_Goliath/config.cpp`
- `Webknights Zombies/WBK_Zombies_Goliath/AI/WBK_Goliath_AI.sqf`
- `Webknights Zombies/WBK_Zombies_Goliath/XEH_preInit.sqf`

---

## 1. Ability Logic — FSM vs SQF Loops

**There is no FSM.** All behaviour is driven by three persistent `CBA_fnc_addPerFrameHandler` (PFH) loops and one `AnimStateChanged` event handler. The three PFH IDs are tracked on the unit via `WBK_AI_AttachedHandlers` and are cleaned up on `Killed` and `Deleted`.

### PFH Inventory

| Handle | Interval | Responsible For |
|---|---|---|
| `_actFr` | **0.5 s** | Ability decision tree — reads distance to enemy, picks the correct ability, calls or spawns the ability function |
| `_loopPathfind` | **0.01 s (100 Hz)** | Movement authority — `lineIntersectsSurfaces` LoS check, `setVelocityTransformation`, AI enable/disable |
| `_loopPathfindDoMove` | **2.4 s** | `doMove` dispatch and idle-sound cooldown management |

### `AnimStateChanged` EH — Per-Ability Side-Effect Logic

This EH fires on the machine hosting the unit. It `spawn`s a new thread per animation transition. Each spawned thread handles timed sub-events (e.g., which `uiSleep` offset triggers the actual hit check, when particles create/destroy) using `case` blocks on the new animation name:

| Animation State | What the EH thread does |
|---|---|
| `goliaph_staggered` | 1 s delay, roar sound |
| `goliaph_spikes` | Sets 120 s recharge flag, `BIS_fnc_earthquake` broadcast, dual ground-crack decal spawn, LoS-checked AoE spike kill (iterates all humans in radius), `remoteExec`'d taunt sounds |
| `goliaph_taunt` | Two damage ticks, two decal spawns, cam-shake, roar sound |
| `goliaph_melee_1` | 1 s delay, then `WBK_GoliaphProceedDamage` at radius 5 |
| `goliaph_melee_2` | 1 s delay, `WBK_GoliaphProceedDamage` at radius 8, **3× particle source** created/deleted on all clients |
| `goliaph_melee_3` | 0.8 s delay, `WBK_GoliaphProceedDamage` at radius 7, **3× particle source** created/deleted on all clients |
| `goliaph_melee_run_1` | 0.4 s delay, `WBK_GoliaphProceedDamage` at radius 5 |

---

## 2. Ability Catalogue

### 2.1 Ability Decision Tree (`_actFr` at 0.5 s)

The decision tree is a prioritised `switch true` block. Cases are evaluated top-to-bottom; the **first matching case wins**. `findNearestEnemy` is called unconditionally every 0.5 s.

```
Priority  Condition                                    Ability Spawned
────────  ───────────────────────────────────────────  ─────────────────────────────────────
1         enemy ≤ 7 m AND not a MAN AND CanThrowVic   WBK_Goliaph_ThrowAVehicle
          not set
2         30 m ≤ enemy ≤ 350 m AND CanThrowRocks      WBK_Goliph_RockThrowingAbility
          not set
3         enemy ≤ 7 m AND enemy is TANK               switchMove → random Melee_1/2/3
4         enemy ≤ 30 m AND CanThrowSpikeUnderGround   switchMove → Goliaph_Spikes (AoE)
          not set AND enemy is MAN
5         10 m < enemy ≤ 600 m AND CanThrowSpike      WBK_Goliaph_ThrowSpike (bone spear)
          not set  OR  enemy is AIR
6         enemy ≤ 130 m AND CanTaunt not set          switchMove → Goliaph_Taunt
7         enemy ≤ 4.5 m AND CanSyncMelee not set      WBK_Goliaph_SyncAnim_1 or _2 (kill anim)
          AND enemy is MAN with human moveset
8         enemy ≤ 4.4 m AND not running               switchMove → random Melee_1/2/3
9         4.4 m < enemy ≤ 7.8 m AND running           switchMove → Goliaph_Melee_Run_1
```

### 2.2 Detailed Ability Profiles

#### Ground-Spike AoE (`goliaph_spikes`)
- **Trigger:** Enemy MAN within 30 m.
- **Cooldown:** 120 s (`Goliaph_CanThrowSpikeUnderGround`).
- **Effect:** Iterates `nearestObjects [unit, ["MAN"], WBK_Zombies_GoliathRadiusAEO]` (default **50 m** radius). For each candidate: `lineIntersectsSurfaces` LoS check → `remoteExec WBK_Goliath_SpecialAttackGroundShard` → up to `WBK_Zombies_GoliathMaxAmountAEO` (default **10**) targets killed with impale sync animation.
- **Broadcast side-effects:** `BIS_fnc_earthquake [3]` via `remoteExec ["spawn", 0]` on all clients within 100 m.

#### Bone Spear (`Goliaph_Throw` via `WBK_Goliaph_ThrowSpike`)
- **Trigger:** 10 m < enemy ≤ 600 m, or enemy is AIR.
- **Cooldown:** 30 s (`Goliaph_CanThrowSpike`).
- **Effect:** Creates a `Goliath_Projectile` via `WBK_fnc_ProjectileCreate_Zombies` — a guided `setVelocity` projectile that deletes itself after 20 s.

#### Rock Throw (`Goliaph_RockThrow` via `WBK_Goliph_RockThrowingAbility`)
- **Trigger:** 30 m ≤ enemy ≤ 350 m.
- **Cooldown:** 45 s (`CanThrowRocks`).
- **Effect:** Spawns `Smasher_RockGrenade` and launches it ballistically with height-corrected velocity. During flight, a **`while {alive _grenade}` loop** polls `nearestObjects` every **0.1 s**, killing every MAN within 3 m. On impact: 3× particle source + `WBK_Smasher_CreateCamShake`.

#### Vehicle Throw (`Goliaph_VehicleGrab` via `WBK_Goliaph_ThrowAVehicle`)
- **Trigger:** Non-MAN vehicle within 7 m.
- **Cooldown:** 60 s (`CanThrowVic`).
- **Effect:** Attaches vehicle to fist bone for 2 s, then `setVelocity` throws it at 23 m/s forward.

#### Sync Kill Animations (`WBK_Goliaph_SyncAnim_1 / _2`)
- **Trigger:** Human MAN within 4.5 m with standard `CfgMovesMaleSdr` or `CfgMovesMaleSpaceMarine` moveset.
- **Cooldown:** 30 s (`Goliaph_CanSyncMelee`).
- **Effect:** `attachTo` victim to Goliath, `setDamage 1` on victim, plays two-character kill animation (`Goliaph_Sync_1` or `Goliaph_Sync_2`). Particle effects and screams `remoteExec`'d to all clients.

#### Taunt / Area Slam (`goliaph_taunt`)
- **Trigger:** Enemy ≤ 130 m, cooldown clear.
- **Cooldown:** 120 s (`Goliaph_CanTaunt`).
- **Effect:** Two damage ticks via `WBK_GoliaphProceedDamage` (radius 5), ground decals, cam-shake, roar broadcast.

---

## 3. Targeting System

**The Goliath uses standard Arma `findNearestEnemy`, not a custom aggro system.** However, its effective awareness is artificially extended beyond vanilla Arma knowledge-of-enemy caps by two event handlers added at init:

| EH | Effect |
|---|---|
| `Suppressed` | `_unit reveal [_instigator, 4]` — shooter is immediately known at maximum precision |
| `FiredNear` | `_unit reveal [_firer, 4]` — any nearby shot reveals the firer at maximum precision |

Additionally, the `_actFr` PFH iterates `nearestObjects [_mutant, ["Man"], 50]` every 0.5 s and calls `reveal [_x, 4]` on every human found. This effectively means **any human within 50 m is instantly max-aware to the Goliath**, regardless of line-of-sight or facing direction.

All standard AI subsystems (`MINEDETECTION`, `WEAPONAIM`, `SUPPRESSION`, `COVER`, `AIMINGERROR`, `TARGET`, `AUTOCOMBAT`, `FSM`) are disabled in `_actFr`. The Goliath is set to `CARELESS` behaviour permanently. It does not use Arma's combat AI.

`_loopPathfind` uses `lineIntersectsSurfaces` with `"FIRE"/"NONE"` geometry modes to determine LoS to the enemy before ceding movement control to the custom `setVelocityTransformation` steering.

---

## 4. Damage, HitPart, and Invulnerability Windows

### 4.1 Custom Hitbox Architecture

The Goliath uses a **proxy hitbox entity** (`Goliath_HitBox`) attached at offset `[0, -1.5, -0.6]` to the `"pilot"` selection. The real unit body is set `allowDamage false` on every tick of `_actFr`. All damage passes through the hitbox's `HitPart` EH.

The `HitPart` EH is registered globally on all machines (`remoteExec ["spawn", 0, true]`) and reads the ammo config's hit value (`_ammo select 0`) as the HP cost for each bullet.

### 4.2 HP Pool

HP is stored in the variable `WBK_SynthHP` (default **15000**, configurable via CBA setting `WBK_ZommbiesGoliathHealthParam`). Arma's native damage model is bypassed entirely. Death occurs when `WBK_SynthHP ≤ 0` — the EH removes itself then calls `setDamage 1`.

### 4.3 Invulnerability Windows (Damage-Immune States)

The `HitPart` EH drops all incoming damage silently when the Goliath is in any of the following animation states:

| Animation State | Ability Phase |
|---|---|
| `Goliaph_Staggered` | Stagger recovery |
| `Goliaph_Throw` | Bone spear cast |
| `Goliaph_Taunt` | Ground pound wind-up |
| `Goliaph_VehicleGrab` | Vehicle throw execution |
| `Goliaph_RockThrow` | Rock throw cast |
| `Goliaph_Spikes` | AoE spike eruption |
| `Goliaph_Sync_1` | Kill animation variant 1 |
| `Goliaph_Sync_2` | Kill animation variant 2 |

**These are not phase transitions** — they are temporary invulnerability windows tied to specific animation playback. There is no HP-threshold-gated phase system in the current implementation.

### 4.4 Stagger Mechanic

A single hit with a HP value (`_ammo select 0`) **≥ 300** while the `CanBeStunnedIMS` variable is unset triggers a forced stagger:
- `switchMove → Goliaph_Staggered`
- Sets `CanBeStunnedIMS` with a **90 s cooldown**.
- Damage is still applied before entering stagger.
- Stagger is effectively the only "phase-like" reaction to player pressure.

---

## 5. Resource Impact — Heavy-Query Analysis

The Goliath is among the most expensive single units in the system. The following are ranked by risk level.

### CRITICAL — `_loopPathfind` at 100 Hz

```sqf
}, 0.01, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;
```

This PFH runs on the machine hosting the unit (the server in a dedicated environment) at 100 Hz. Every tick it calls:
- `findNearestEnemy` (native, cheap but not free at 100 Hz)
- `lineIntersectsSurfaces` (physics raycast — **expensive**)
- `setVelocityTransformation` (physics write — **expensive**)
- Multiple `getPosASL`, `modelToWorld`, `vectorNormalized` calls

**This single loop is the dominant server CPU cost for this unit.** Reducing its interval to 0.05–0.1 s (20–10 Hz) would cut cost by 80–90% with negligible visible difference at the speed the Goliath moves.

### HIGH — `_actFr` Every 0.5 s: Mass Reveal + Terrain Destruction

```sqf
{ _mutant reveal [_x, 4]; } forEach nearestObjects [_mutant, ["Man"], 50];
```
In a wave with dozens of standard zombies nearby, this iterates every man-type object within 50 m and issues a `reveal` call per unit, every 0.5 s. The `nearestObjects ["Man"]` call cost scales with zombie density.

During active movement (`Goliaph_Run` / `Goliaph_Walk`), every 0.5 s:
```sqf
{_x setDamage 1;} forEach nearestTerrainObjects [_mutant,[],9];
{_x setDamage 1;} forEach nearestObjects [_mutant,["Static"],9];
```
`nearestTerrainObjects` queries the terrain object database at 9 m radius and destroys everything found. This is a **batch global state mutation** on a hot loop.

### HIGH — `WBK_GoliaphProceedDamage` on Every Melee Hit

Called on every melee attack (radius 5–8 m). In a single call it runs:
- `nearestObjects [_goliaph, ["MAN"], _AttackDist]` — iterate and damage all men
- `nearestObjects [_goliaph, ["CAR","TANK","AIR","StaticWeapon"], _AttackDist + 1]` — set all vehicles to full damage
- `nearestObjects [_goliaph, ["Static"], _AttackDist + 2]` — destroy all statics
- `nearestTerrainObjects [_goliaph, [], _AttackDist + 2]` — destroy all terrain objects
- `lineIntersectsSurfaces` for a wall-destruction check
- `WBK_Smasher_CreateCamShake` spawned (additional thread)

Each melee can trigger this multiple times per attack animation via the `AnimStateChanged` EH spawned threads.

### MEDIUM — Rock-Throw In-Flight Poll Loop

```sqf
while {alive _grenade} do {
    {if (alive _x ...) then {_x setDamage 1; ...}; } forEach nearestObjects [_grenade,["MAN"],3];
    uiSleep 0.1;
};
```
A `while` loop running at 10 Hz for the full flight time of the rock grenade. This is a persistent background thread that lives for as long as the grenade is airborne. If multiple Goliaths are active simultaneously, multiple of these are running in parallel.

### MEDIUM — Particle Sources on Melee_2 and Melee_3

For `goliaph_melee_2` and `goliaph_melee_3`, three `#particlesource` objects are created per hit via `remoteExec ["spawn", [0,-2] select isDedicated, false]`:
- On a **dedicated server**, this executes on all **clients** (`-2`).
- Each source uses `setDropInterval 0.01` (100 particles/second).
- Three sources × 100 Hz = 300 particle objects/second per melee hit, on every client.
- The total lifetime is ~300 ms before `deleteVehicle`, so peak count is roughly 90 particles per client at any instant. Acceptable for 1 Goliath; problematic if multiple spawn simultaneously.

### MEDIUM — `BIS_fnc_earthquake` Global Broadcast

During the AoE spike attack (`goliaph_spikes`):
```sqf
[3] spawn BIS_fnc_earthquake;
```
This is executed via `remoteExec ["spawn", 0]` on **all clients** within 100 m. `BIS_fnc_earthquake` is a client-side visual effect function that internally uses a `waitUntil` loop. While short-lived, it generates a `remoteExec` event to every connected client simultaneously.

### LOW — Death Handler Terrain Destruction

```sqf
{_x setDamage 1;} forEach nearestTerrainObjects [(_this select 0),[],13];
```
Fired once on death. Destroys all terrain objects within 13 m. One-time cost, not a loop concern. However it is a global-broadcast state change and should be noted for placement near Bulwark structures.

### LOW — `WBK_Goliath_SpecialAttackGroundShard` Particle Effects

Per-target impale animation (`goliaph_spikes` AoE): each killed target spawns 3 particle sources + a blood effect on all clients via `remoteExec`. At `WBK_Zombies_GoliathMaxAmountAEO = 10`, this is 10 simultaneous `remoteExec` calls each triggering 30 particle sources across all clients.

---

## 6. Performance Tuning Recommendations

| Variable / Setting | Default | Recommended for Dense Waves | Effect |
|---|---|---|---|
| `_loopPathfind` PFH interval | 0.01 s | 0.05 s | Reduces pathfind CPU cost by ~80% |
| `WBK_Zombies_GoliathRadiusAEO` | 50 m | 30 m | Reduces AoE spike `nearestObjects` iteration cost |
| `WBK_Zombies_GoliathMaxAmountAEO` | 10 | 5 | Reduces AoE impale `remoteExec` volume |
| `WBK_Zombies_Goliath_MoveDistanceLimit` | 600 m | 300 m | Reduces pathfind raycast active range |
| `WBK_ZommbiesGoliathThrowParam` (rock) | true | false | Disables the in-flight poll loop entirely |
| `nearestObjects reveal radius` in `_actFr` | 50 m | 25 m | Halves the set iterated for mass-reveal |

**Spawn limit recommendation:** Given the three concurrent PFH loops (one at 100 Hz), do not run more than **one Goliath simultaneously** during a standard Bulwarks wave. A second Goliath doubles the 100 Hz pathfind load on the server. If two are required by design (e.g., a final wave), disable `WBK_ZommbiesGoliathThrowParam` and reduce `WBK_Zombies_GoliathRadiusAEO` to within melee relevant range (~20 m) on the second instance.
