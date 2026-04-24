# Corrupted Zombie Variant — Technical Audit

**Author:** Senior SQF Architect  
**Date:** 2026-04-09  
**Files Reviewed:**
- `Webknights Zombies\WBK_Zombies_Corrupted\config.cpp`
- `Webknights Zombies\WBK_Zombies_Corrupted\AI\WBK_AI_CorruptedHead.sqf`
- `Webknights Zombies\WBK_Zombies_Corrupted\XEH_preInit.sqf`
- `Webknights Zombies\WBK_Zombies\AI\WBK_AI_Runner.sqf` (reference baseline)
- `Webknights Zombies\WBK_Zombies\bootstrap\XEH_preInit.sqf` (HP setting definitions)

---

## 1. Variant Differences: Corrupted vs Standard Runner

### Initialization entry-point

The Runner AI (`WBK_AI_Runner.sqf`) is a **shared script** that handles both standard Runners and the on-body "Corrupted body" conversion (the Runner that has infected a player). It is dispatched by the `_isCorrupted` boolean parameter:

```sqf
[_unit, false, false] execVM '\WBK_Zombies\AI\WBK_AI_Runner.sqf'; // standard angry runner
[_unit, true,  false] execVM '\WBK_Zombies\AI\WBK_AI_Runner.sqf'; // standard calm runner
[_unit, false, true ] execVM '\WBK_Zombies\AI\WBK_AI_Runner.sqf'; // corrupted-body runner
```

The **Corrupted Head** is a separate, independent unit (`WBK_SpecialZombie_Corrupted_1/2/3`) whose AI is loaded directly through `Extended_InitPost_EventHandlers` in `config.cpp`, calling `WBK_AI_CorruptedHead.sqf`. It never passes through `WBK_AI_Runner.sqf`.

### State variables unique to the Corrupted Head

| Variable | Scope | Purpose |
|---|---|---|
| `WBK_AI_ISZombie` | Global (`true,true`) | Standard zombie flag, shared with all variants. |
| `WBK_AI_AttachedHandlers` | Local | Array of CBA per-frame handler IDs (`[_actFr, _loopPathfindDoMove, _loopPathfind]`). Cleaned up on `Killed` and `Deleted`. |
| `WBK_IsUnitLocked` | Local/Global | Pathfinding lock. Set to `0` when the unit is inside the direct-approach logic, cleared to `nil` when released. Used to gate sound calls and `doMove` re-issue. **Absent in the Walker; present in Runner with different semantics.** |
| `WBK_AI_LastKnownLoc` | Local | Last recorded target position used to suppress redundant `doMove` calls. |
| `WBK_Zombie_CustomSounds` | Global (`true,false`) | Five-element array of sound name arrays: `[idle_calm, idle_aggro, attack, death, burning]`. |

### Behavioural differences versus the Runner

| Aspect | Standard Runner | Corrupted Head |
|---|---|---|
| **Base model** | Human character (`I_Survivor_F` derivative) | Custom `.p3d` skull model (`cryingHead.p3d`) |
| **Moveset/Skeleton** | `WBK_Runner_*` RTM animations | `Corrupted_*` RTM animations, custom skeleton `WBK_ZombieCreatureCorrupted_Skeleton` |
| **Attack trigger** | `WBK_ZombieAttackDamage` call inside `AnimStateChanged` | Custom `WBK_CorruptedAttack_success` function via `attachTo` mechanic — the Corrupted physically attaches to its victim |
| **Attack animations** | `wbk_runner_*` / `wbk_walker_*` melee states | `corrupted_attack` (close) + `corrupted_attack_far` (2-step), with a `Corrupted_attack_success_*` grab sequence |
| **Grab/transform sequence** | None | Full grab: attaches to victim, plays 4–5 seconds of animations, applies `setFace "WBK_DecapatedHead_Zombies_Normal"`, plays eating sounds, then either kills the victim or converts them to a Corrupted Runner |
| **Player conversion** | None | If `WBK_Zombies_Corrupted_PlayerControlls` is true, the victim is converted to a playable Corrupted Runner via `WBK_SpawnPlayerCorruptedControlls` |
| **HandleDamage quirk** | Standard WBK synthetic HP logic | **Same** synthetic HP, but also adds `_unit setDamage ((damage _unit) + 0.5)` on any hit from an external source — drives the engine damage value up to enable the hit-stagger animations independently of `WBK_SynthHP` |
| **AI disables** | `MINEDETECTION`, `WEAPONAIM`, `SUPPRESSION`, `COVER`, `AIMINGERROR`, `TARGET`, `AUTOCOMBAT` | Same as Runner, plus `FSM` explicitly disabled each frame tick |
| **Per-frame tick rate** | Runner actFr at a fixed rate | Corrupted actFr rate randomly chosen from `[4,5,6,7]` seconds — intentionally varied to reduce server load synchronisation |
| **Sound whoosh on swing** | No swing whoosh | Calls `createSoundGlobal.sqf` with `melee_whoosh_00/01/02` 0.8 s into both attack animations |
| **Weapon strip** | Only if the unit spawns with a weapon | Runner strips weapons unconditionally; Corrupted Head never has weapons — no strip needed |

---

## 2. Custom Visuals and Face Handling via `remoteExec`

### Face assignment

The `setFace` command must execute on **all machines** to keep the visual consistent for every connected client. The codebase uses `remoteExec ["setFace", 0]` throughout, where broadcast target `0` means *all machines including the server*.

**Corrupted Head spawn (in `WBK_AI_Runner.sqf`, `_isCorrupted` branch):**

```sqf
[_unitWithSword, "WBK_DosHead_Corrupted"] remoteExec ["setFace", 0];
```

This sets the face to the custom `WBK_DosHead_Corrupted` face texture immediately on initialization — before any combat begins.

**Runner (standard, non-corrupted branch):**

```sqf
[_unitWithSword, selectRandom ["WBK_ZombieFace_1","WBK_ZombieFace_2",
    "WBK_ZombieFace_3","WBK_ZombieFace_4","WBK_ZombieFace_5","WBK_ZombieFace_6"]] 
    remoteExec ["setFace", 0];
```

A random face from six variants is chosen, giving visible diversity within the horde.

**During the grab sequence (`WBK_CorruptedAttack_success` in `XEH_preInit.sqf`):**

The face is changed dynamically during the animation as a storytelling device:

```sqf
// ~2.75 s in — decapitation visual applied to the victim
[_victim, "WBK_DecapatedHead_Zombies_Normal"] remoteExec ["setFace", 0];

// ~5.25 s in — victim's face replaced just before conversion, still broadcast globally
[_victim, "WBK_DecapatedHead_Zombies_Normal"] remoteExec ["setFace", 0];
```

The Corrupted Head's own `HandleDamage` EH (inside `WBK_AI_CorruptedHead.sqf`) and the high-calibre/headshot branches in the shared `HitPart` EH also call `setFace` to apply decapitation visuals on kill:

```sqf
[_target, "WBK_DecapatedHead_Zombies_Normal"] remoteExec ["setFace", 0]; // full decap
[_target, "WBK_DosHead_BackHole"]             remoteExec ["setFace", 0]; // rear entry
[_target, "WBK_DosHead_FrontHole"]            remoteExec ["setFace", 0]; // front entry
```

Face selection for headshots depends on shooter direction:

```sqf
switch true do {
    case ((_ammo select 0) >= 14):                          { /* full decap */ };
    case (worldToModel(...) select 1) < 0:                  { /* back hole */ };
    default                                                 { /* front hole */ };
};
```

### Custom sound arrays

Sound classes are defined in `CfgSounds` inside `config.cpp`. All volumes use `3.1622777` (≈ 10 dB, i.e. `10^(10/10)` in linear scale) and a pitch of `1`. Sounds are grouped semantically:

| Group | Class names | Count |
|---|---|---|
| Attack (head-specific) | `corrupted_head_attack_1` – `corrupted_head_attack_5` | 5 |
| Idle (head-specific) | `corrupted_head_idle_1` – `corrupted_head_idle_2` | 2 |
| Idle (body) | `corrupted_idle_1` – `corrupted_idle_4` | 4 |
| Death | `corrupted_dead_1` – `corrupted_dead_3` | 3 |
| Transformation | `corrupted_transformed` | 1 |

The `WBK_Zombie_CustomSounds` variable stores a **5-element array** matching the structure consumed by `WBK_ZombiePlayIdleSounds`:

```sqf
_unitWithSword setVariable ["WBK_Zombie_CustomSounds", [
    /* [0] calm idle  */ ["corrupted_head_attack_1","corrupted_head_attack_2","corrupted_head_attack_3","corrupted_head_attack_4","corrupted_head_attack_5"],
    /* [1] aggro idle */ ["corrupted_idle_1","corrupted_idle_2","corrupted_idle_3","corrupted_idle_4"],
    /* [2] attack     */ ["corrupted_head_attack_1","corrupted_head_attack_2","corrupted_head_attack_3","corrupted_head_attack_4","corrupted_head_attack_5"],
    /* [3] death      */ ["corrupted_dead_1","corrupted_dead_2","corrupted_dead_3"],
    /* [4] burning    */ ["corrupted_dead_1","corrupted_dead_2","corrupted_dead_3"]
]];
```

> **Note:** Slots `[0]` (calm idle) and `[2]` (attack) are populated with the attack sounds. This appears intentional for the Corrupted Head, as it has no "calm" state — its idle and engaged states should both sound aggressive. The head-idle sounds (`corrupted_head_idle_1/2`) are used directly by the pathfinding loop, bypassing the CustomSounds array for that specific call.

Sound playback during the grab sequence uses `createSoundGlobal.sqf` with explicit ranges and distances rather than `CfgSounds`-registered names, e.g.:

```sqf
[_main, selectRandom ["corrupted_head_attack_1","corrupted_head_attack_2"], 45, 5] 
    execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
```

---

## 3. Health Scaling

### Default values (from `WBK_Zombies\bootstrap\XEH_preInit.sqf`)

| CBA Setting Key | Runtime Variable | Default | Category |
|---|---|---|---|
| `WBK_Zommbies_Halth_Runner` | `WBK_Zombies_RunnerHP` | **50** | Regular infected |
| `WBK_ZommbiesCorruptedHealthParam` | `WBK_Zombies_CorruptedHP` | **200** | Special infected |

The Corrupted has **4× the base HP of a standard Runner** by default.

### Comparison with other special infected

| Variant | Default HP | Multiplier vs Runner |
|---|---|---|
| Runner | 50 | 1× |
| Middle (Walker) | 40 *(from bootstrap line ~97)* | 0.8× |
| Melee Zombie | 60 | 1.2× |
| Bloater | 80 | 1.6× |
| Leaper | 120 | 2.4× |
| Screamer | 160 | 3.2× |
| **Corrupted** | **200** | **4×** |

### How `WBK_SynthHP` works

The entire damage model bypasses Arma's native hit-point system. On init the unit receives `allowDamage false` inside the per-frame handler (prevents engine death), and `WBK_SynthHP` is decremented manually inside the `HitPart` EH:

- **High-calibre torso hit** (`_ammo select 3 >= 0.7`): damage multiplied by 2.
- **Headshot**: damage multiplied by `WBK_Zombies_HeadshotMP` (configurable, typically higher than 2).
- **Leg hit**: triggers a fall animation but does **not** decrement HP.

When `WBK_SynthHP` reaches ≤ 0, the handler calls:
```sqf
[_target, [1, false, _shooter]] remoteExec ["setDamage", 2];
```
Broadcasting to machine `2` (the server) to apply fatal damage authoritatively. This ensures the kill credit and death event fire server-side.

The Corrupted Head AI script (`WBK_AI_CorruptedHead.sqf`) also has its own `HandleDamage` EH that increments engine damage on every external hit (`_unit setDamage ((damage _unit) + 0.5)`). This is **in addition to** the `HitPart` mechanic — it serves to push the unit toward the Arma incapacitation threshold, enabling stagger animations without overriding the synthetic HP gating kill authority.

---

## 4. Integration Hooks — Spawn Sequence Injection Points

### Corrupted Head (`WBK_SpecialZombie_Corrupted_*` class units)

The Corrupted Head is a distinct unit class. Its variables are injected automatically via `Extended_InitPost_EventHandlers`:

```cpp
// config.cpp
class Extended_InitPost_EventHandlers {
    class WBK_SpecialZombie_Corrupted_1 {
        class Zombie_Corrupted_Init {
            init = "_unit = _this select 0; if (local _unit) then {
                _unit execVM '\WBK_Zombies_Corrupted\AI\WBK_AI_CorruptedHead.sqf';
            };";
        };
    };
};
```

All state variables (`WBK_AI_ISZombie`, `WBK_AI_AttachedHandlers`, `WBK_Zombie_CustomSounds`) are set inside `WBK_AI_CorruptedHead.sqf`. No external caller needs to inject them beforehand.

**Required pre-condition:** `WBK_Zombies_Corrupted_PreInit` (in `Extended_PreInit_EventHandlers`) must have run before any Corrupted Head unit initializes, as it defines `WBK_CorruptedAttack_success` and `WBK_SpawnPlayerCorruptedControlls`. This is guaranteed by CBA's XEH execution order (PreInit → InitPost), but only if the `WBK_Zombies_Corrupted` addon is loaded.

### Corrupted Body (conversion of a Runner unit via `WBK_AI_Runner.sqf`)

This path is taken when an existing Runner-class unit needs to be marked as Corrupted. The critical injection window is **before `WBK_AI_Runner.sqf` is called**. All Corrupted-specific variables are written inside the `if (_isCorrupted)` branch:

```sqf
// Inside WBK_AI_Runner.sqf — _isCorrupted = true branch
[_unitWithSword, "WBK_Runner_Angry_Idle"]   remoteExec ["switchMove", 0];          // animation state
_unitWithSword setVariable ["WBK_SynthHP", WBK_Zombies_CorruptedHP, true];           // HP
[_unitWithSword, "WBK_DosHead_Corrupted"]   remoteExec ["setFace", 0];              // face
_unitWithSword setVariable ["WBK_Zombie_CustomSounds", [...], false];                // sound table
```

**Injection point summary:** pass `true` as the third argument (`_isCorrupted`) when calling `WBK_AI_Runner.sqf`. Do **not** pre-set `WBK_SynthHP` or `WBK_Zombie_CustomSounds` externally before this call — the script overwrites them unconditionally in the Corrupted branch.

### Ensuring custom death sounds trigger

The death sound is played inside the `Killed` EH (added in `WBK_AI_Runner.sqf`):

```sqf
_unitWithSword addEventHandler ["Killed", {
    ...
    if (!(isNil {_zombie getVariable "WBK_Zombie_CustomSounds"})) then {
        [_zombie, selectRandom ((_zombie getVariable "WBK_Zombie_CustomSounds") select 3), 50, 6]
            execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
    } else {
        [_zombie, selectRandom ["runner_death_1",...], 50, 6]
            execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
    };
}];
```

**`WBK_Zombie_CustomSounds` must be set before the `Killed` EH fires.** Since it is set synchronously before any `addEventHandler` call in the `_isCorrupted` branch of `WBK_AI_Runner.sqf`, it is always available by the time the unit dies in normal gameplay. However, if a unit is killed in the same frame as (or before) `execVM` returns from `WBK_AI_Runner.sqf`, the EH would not yet be registered. This is mitigated by the `uisleep 0.5` at the end of the script before `doMove`, but is not a concern in practice for specially spawned units.

For the **Corrupted Head** (`WBK_AI_CorruptedHead.sqf`), there is **no `Killed` EH that plays a death sound**. The death sound for the head unit is played inside `WBK_CorruptedAttack_success` via the `corrupted_dead_*` entries in `WBK_Zombie_CustomSounds`, or — if the head is simply shot down without triggering a grab — the death sound is **not automatically played**. To close this gap, a `Killed` EH mirroring the one in `WBK_AI_Runner.sqf` should be added to `WBK_AI_CorruptedHead.sqf`:

```sqf
// Recommended addition to WBK_AI_CorruptedHead.sqf
_unitWithSword addEventHandler ["Killed", {
    params ["_zombie", "_killer"];
    {
        [_x] call CBA_fnc_removePerFrameHandler;
    } forEach (_zombie getVariable ["WBK_AI_AttachedHandlers", []]);
    _zombie spawn {
        uiSleep (0.3 + random 0.1);
        if (isNull _this) exitWith {};
        if (!(isNil {_this getVariable "WBK_Zombie_CustomSounds"})) then {
            [_this, selectRandom ((_this getVariable "WBK_Zombie_CustomSounds") select 3), 50, 6]
                execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
        };
    };
}];
```

> The existing `Killed` EH inside `WBK_AI_CorruptedHead.sqf` only removes the CBA per-frame handlers — it does not play a death sound.

### Ensuring custom death animations trigger

The `Corrupted_die` animation is driven by the moveset mapping in `config.cpp`:

```cpp
class WBK_Zombie_CORRUPTED_Moveset: NoActions {
    Die = "Corrupted_die";
    ...
};
```

This fires automatically when the engine marks the unit as dead (i.e. when `setDamage 1` is applied on the server via `remoteExec ["setDamage", 2]`). No additional scripting injection is needed for the death animation — it is handled entirely by the CfgMoves state machine and Arma's death transition.

---

## Summary of Key Findings

1. **Corrupted Head** is a distinct entity from the "Corrupted body" mode of the Runner. They share the `WBK_Zombie_CustomSounds` variable structure and `WBK_DosHead_Corrupted` face, but use entirely separate AI scripts and unit classes.
2. **All face changes** are broadcast globally via `remoteExec ["setFace", 0]`, correctly ensuring visual consistency across all clients.
3. **`WBK_Zombies_CorruptedHP` defaults to 200** — exactly 4× the Runner's 50 HP — placing it at the top of the special infected HP table.
4. **Corrupted Head has no death sound EH.** Death sounds only play during the grab sequence. A dedicated `Killed` EH should be added to `WBK_AI_CorruptedHead.sqf` to handle cases where the head is killed by gunfire.
5. **Injection point for Corrupted variables** in the Runner conversion path is the `_isCorrupted = true` call to `WBK_AI_Runner.sqf`. The `WBK_Zombie_CustomSounds` array (index 3 = death sounds) **must be populated before the `Killed` EH is added**, which the current script guarantees.
