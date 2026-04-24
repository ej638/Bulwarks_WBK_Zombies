# Smasher Unit — Technical Specification
**Purpose:** Wave balancing reference for the WBK_Zombies_Smasher heavy-threat unit.  
**Source files:** `Webknights Zombies\WBK_Zombies_Smasher\config.cpp`, `Webknights Zombies\WBK_Zombies_Smasher\AI\WBK_AI_Smasher.sqf`, `Webknights Zombies\WBK_Zombies_Smasher\XEH_preInit.sqf`

---

## 1. Movement State

The Smasher does **not** use any standard ArmA 3 walking animation states. Every movement state in the `WBK_Zombie_SMASHER_Moveset` action class inside `config.cpp` is remapped to `WBK_Smasher_Run`:

```cpp
// config.cpp — WBK_Zombie_SMASHER_Moveset
WalkF  = "WBK_Smasher_Run";
SlowF  = "WBK_Smasher_Run";
FastF  = "WBK_Smasher_Run";
TactF  = "WBK_Smasher_Run";
// … all 40+ directional states map identically
stop   = "WBK_Smasher_Idle";
default= "WBK_Smasher_Idle";
```

Locomotion is driven entirely by the AI script's `_loopPathfind` per-frame handler (`WBK_AI_Smasher.sqf`), which calls:
- `_unit playMoveNow "WBK_Smasher_Run"` — when the enemy is more than 3.3 m away.
- `_unit playMoveNow "WBK_Smasher_Idle"` — when standing over the target.

Attack animations are triggered exclusively via `remoteExec ["switchMove", 0]` followed immediately by `remoteExec ["playMoveNow", 0]` to queue the recovery run cycle:

```sqf
// WBK_AI_Smasher.sqf — combat decision switch
[_mutant, selectRandom ["wbk_smasher_attack_1","wbk_smasher_attack_2","wbk_smasher_attack_3","wbk_smasher_attack_vehicle"]] remoteExec ["switchMove", 0];
[_mutant, "WBK_Smasher_Run"] remoteExec ["playMoveNow", 0];
```

**Charge / Jump attack (`wbk_smasher_attack_air`):** This is the unit's high-threat "charge" behaviour. It is not a `switchMove` loop by itself; rather, `WBK_ChargerJump` launches a dedicated `CBA_fnc_addPerFrameHandler` at 0.01 s that drives a `setVelocityTransformation`-based arc toward the target, interpolating the centroid between attacker and victim. `CanFly` variable is set to block re-entry for `10 + random 5` seconds.

---

## 2. Interaction with Environment (Bulwark Objects)

**Yes — the Smasher actively targets and destroys non-unit objects.** Two separate functions are responsible.

### 2a. `WBK_Smasher_Damage_Vehicles` (`XEH_preInit.sqf`)

Responsible for destroying vehicles and static weapons within melee range. Called on every `wbk_smasher_attack_vehicle` animation event and on landed `wbk_smasher_attack_air` / `wbk_smasher_inair_end` hits.

```sqf
WBK_Smasher_Damage_Vehicles = {
    if !(alive _this) exitWith {};
    {
        // Physics fling first
        _dir = getDirVisual _this;
        _vel = velocity _x;
        [_x, [(_vel select 0)+(sin _dir*15),(_vel select 1)+(cos _dir*15),5]] remoteExec ["setVelocity", _x];
        // Instant-kill cars, helicopters, static weapons; half-damage everything else
        if ((_x isKindOf "CAR") or (_x isKindOf "Helicopter") or (_x isKindOf "StaticWeapon")) then {
            _x setDamage 1;
        } else {
            _x setDamage ((damage _x) + 0.5);
        };
    } forEach nearestObjects [_this, ["CAR","TANK","Air","StaticWeapon"], 7];
};
```

**Detection radius:** 7 m around the Smasher.  
**Categories destroyed instantly:** `CAR`, `Helicopter`, `StaticWeapon`.  
**Categories dealt 0.5 damage:** `TANK`, `Air` (non-heli).

### 2b. `WBK_Smasher_Damage_Humanoid` — `Static` object check (`XEH_preInit.sqf`)

After resolving humanoid hits, the function casts a forward `lineIntersectsSurfaces` ray (`GEOM`/`FIRE`) in the attack direction. Any `Static`-class object intercepting that ray is set to `setDamage 1`:

```sqf
_ins = lineIntersectsSurfaces [
    _smasher modelToWorldWorld [0,0,2],
    _smasher modelToWorldWorld [0,_dist,2],
    _smasher, objNull, true, 1, "GEOM", "FIRE"
];
if (count _ins != 0) then {
    _obj = (_ins select 0 select 2);
    if (_obj isKindOf "Static") then { _obj setDamage 1; };
};
```

This means any `Static` object (which includes `Bulwark`-placed objects that inherit `Static`) that lies along the melee swing vector is instantly destroyed. The detection range equals the `_dist` parameter passed by the calling attack handler (4–6 m depending on the attack variant).

---

## 3. Initialization DNA — `WBK_AI_AttachedHandlers`

At the end of `WBK_AI_Smasher.sqf`, three `CBA_fnc_addPerFrameHandler` handles are stored on the unit and registered in the standard `WBK_AI_AttachedHandlers` array:

```sqf
_unitWithSword setVariable ["WBK_AI_AttachedHandlers", [_actFr, _loopPathfindDoMove, _loopPathfind]];
```

| Index | Variable | Interval | Role |
|-------|----------|----------|------|
| `[0]` | `_actFr` | 0.3 s | **Combat decision tree.** Selects between teleport (Hellbeast), fire/acid ranged attack, rock throw, execution grab, jump charge, vehicle smash, roar, or normal melee based on distance, line-of-sight, and per-ability cooldown variables (`CanFly`, `CanThrowRocks`, `CanThrowAcid`, `WBK_CanMakeRoar`, `WBK_CanEatSomebody`). Also resets AI flags (`removeAllWeapons`, all `disableAI` calls) every tick. |
| `[1]` | `_loopPathfindDoMove` | 2.4 s | **Pathfinding / `doMove` issuer.** Plays ambient idle audio, then calls `_unit doMove` toward the nearest enemy's current `getPosATL`. Skipped entirely while any attacking or airborne animation is active. |
| `[2]` | `_loopPathfind` | 0.01 s | **Low-level velocity / MOVE AI controller.** While engaged and in a clear LOS corridor at the same elevation (±1.45 m), it disables the engine's MOVE/ANIM AI and drives velocity directly via `setVelocityTransformation`. During attack animations it re-enables ANIM/MOVE and applies a backward velocity nudge to prevent sliding into the target. |

Both the `Deleted` and `Killed` event handlers iterate this array and call `CBA_fnc_removePerFrameHandler` on each entry to cleanly shut down all loops on death.

---

## 4. Crowd Control — Stun and Knockback Effects

The Smasher has **no traditional stun** (no `setUnconscious`, no incapacitation timer applied to the victim). It does have two distinct crowd-control effects broadcast to the victim client:

### 4a. Camera Shake — `WBK_Smasher_CreateCamShake`

Triggered on every melee hit, jump landing, rock throw impact, execution grab, and roar. The function broadcasts to **all clients** (`remoteExec ["spawn", 0]`) and applies a camera shake locally if the player is within 20 m:

```sqf
WBK_Smasher_CreateCamShake = {
    [_this, {
        if (isDedicated) exitWith {};
        if (((missionNamespace getVariable["bis_fnc_moduleRemoteControl_unit", player]) distance _this) <= 20) then {
            enableCamShake true;
            addCamShake [5, 5, 25];   // strength 5, duration 5 s, frequency 25 Hz
        };
    }] remoteExec ["spawn", 0];
};
```

This is a **perceptual stun** effect only — it disorientation the player's view but does not lock input or movement.

### 4b. Physics Knockback — `addForce` via `WBK_Smasher_Damage_Humanoid`

For all standard humanoid targets (default case), a physics force is applied **on the victim's own machine** using `remoteExec` targeted at the victim object:

```sqf
// WBK_Smasher_Damage_Humanoid — default case
[_x, [_smasher vectorModelToWorld _position, _x selectionPosition "head", false]] remoteExec ["addForce", _x];
```

- `remoteExec ["addForce", _x]` — the third argument being the victim object means execution happens on the machine that owns `_x` (the player's client for player units).
- The force vector originates from the smasher's model-space attack position transformed to world space (`vectorModelToWorld _position`), applied at the victim's head selection. This produces a directional launch/stumble rather than a uniform pushback.

### 4c. Vehicle Knockback — `setVelocity` via `WBK_Smasher_Damage_Vehicles`

Vehicles within 7 m receive a velocity impulse before the damage call:

```sqf
[_x, [(_vel select 0)+(sin _dir*15), (_vel select 1)+(cos _dir*15), 5]] remoteExec ["setVelocity", _x];
```

Again targeted at the vehicle object (`_x`), so the command runs on the machine that owns the vehicle.

---

## Balancing Notes Summary

| Property | Value |
|----------|-------|
| Base HP (Regular) | `WBK_Zombies_SmasherHP` (default 3500) |
| Base HP (Spewer/Acid) | `WBK_Zombies_SmasherHP_Acid` (default 4000) |
| Base HP (Hellspawn) | `WBK_Zombies_SmasherHP_Hell` (default 5000) |
| Stun immunity window | 6 s (`CanBeStunnedIMS`) after being hit by explosive or ≥100-damage shot |
| Jump attack cooldown | `10 + random 5` s (`CanFly`) |
| Rock throw cooldown | `WBK_Zombies_Smasher_RockAttackCooldown` (default 45 s) |
| Acid throw cooldown | `WBK_Zombies_Smasher_AcidAttackCooldown` (default 20 s) |
| Fire attack cooldown | `WBK_Zombies_Smasher_FireAttackCooldown` (default 15 s) |
| Teleport cooldown | `WBK_Zombies_Smasher_TeleportAttackCooldown` (default 40 s) |
| Pathfinding distance limit | `WBK_Zombies_Smasher_MoveDistanceLimit` (default 500 m) |
| Vehicle destruction range | 7 m (`nearestObjects` scan in `WBK_Smasher_Damage_Vehicles`) |
| Static object destruction range | 4–6 m (forward ray in `WBK_Smasher_Damage_Humanoid`) |
| Camera shake radius | 20 m (`addCamShake [5, 5, 25]`) |
