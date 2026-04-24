/**
 *  fn_spawnWBKUnit
 *
 *  Core Adapter — Phase 1
 *  Spawns a single WBK zombie at the given position, relying on
 *  Extended_InitPost_EventHandlers to auto-initialise the three
 *  mandatory variables (WBK_AI_ISZombie, WBK_SynthHP, WBK_AI_ZombieMoveSet)
 *  and the appropriate AI script.
 *
 *  Attaches Bulwarks scoring hooks:
 *    - Killed EH  → killPoints_fnc_killed (fires when WBK calls setDamage 1)
 *    - HitPart EH → EJ_fnc_wbkHitPartScore (bridges synthetic damage → score)
 *
 *  Params:
 *    _pos           — ATL position to spawn at
 *    _className     — WBK EAST-side classname (e.g. "Zombie_O_RunnerAngry_CSAT")
 *    _pointMulti    — (optional) kill-score multiplier, default 1
 *    _group         — (optional) pre-created EAST group; if grpNull, a new group is created
 *
 *  Returns: the created unit, or objNull on failure
 *
 *  Domain: Server
 */

if (!isServer) exitWith { objNull };

params [
    "_pos",
    "_className",
    ["_pointMulti", 1],
    ["_group", grpNull]
];

// --- Use provided group or create a new one ---
if (isNull _group) then {
    _group = createGroup [EAST, true];
};
private _unit = _group createUnit [_className, _pos, [], 0.5, "FORM"];

if (isNull _unit) exitWith {
    diag_log format ["[EJ] ERROR: createUnit failed for class '%1' at %2", _className, _pos];
    objNull
};

// --- Reveal players to seed findNearestEnemy knowledge ---
// WBK AI scripts use findNearestEnemy which requires the unit to
// KNOW about enemies. With disableAI "TARGET" (set by all WBK AI),
// units cannot acquire targets via standard AI scanning.
// reveal [_player, 4] gives maximum knowledge immediately, so
// findNearestEnemy returns valid player targets on the first PFH tick.
// This is critical for Smasher/Goliath whose pathfinding PFH loops
// exitWith {} when findNearestEnemy returns objNull.
{
    _unit reveal [_x, 4];
} forEach playableUnits;

// --- Initial movement order toward a player ---
if (count playableUnits > 0) then {
    _unit doMove (getPos (selectRandom playableUnits));
};

// --- Movement tuning ---
// Runner speed reduction: scale animation playback for T1 runner classes.
// Slows their zig-zag approach without touching special infected.
if (_className find "_RA_" >= 0 || _className find "_RC_" >= 0) then {
    _unit setAnimSpeedCoef EJ_RUNNER_ANIM_SPEED_COEF;
};

// Sprint boost: force all zombies to run at spawn so they reach the zone
// quickly instead of walking under CARELESS behaviour.  Resets after
// EJ_SPAWN_SPRINT_DURATION seconds so natural WBK PFH movement takes over.
//
// WBK AI init scripts (Extended_InitPost_EventHandlers) issue
// "doMove (getPosATLVisual _this)" at 0.5s after spawn, cancelling our
// initial doMove toward a player.  The delayed block below waits for that
// self-doMove to fire, then re-issues doMove + refreshes reveal so the
// unit has a valid destination for forceSpeed to drive toward.
//
// Screamer fix: WBK_AI_Stunden starts the Screamer in WBK_Runner_Calm_Idle
// but never transitions to angry.  The PFH derives FastF from the current
// animation's action class, so calm → FastF = WBK_Runner_Calm_Walk (5s loop)
// instead of WBK_Runner_Angry_Sprint (1.19s loop).  Switching to angry state
// makes the PFH drive sprinting.  Scream ability is gesture-based and still works.
_unit forceSpeed 6;
[_unit, _className] spawn {
    params ["_unit", "_className"];
    sleep 1.5;
    if (!alive _unit) exitWith {};

    // Screamer: switch from calm to angry animation state so PFH FastF
    // resolves to WBK_Runner_Angry_Sprint instead of WBK_Runner_Calm_Walk.
    if (_className find "Screamer" >= 0) then {
        [_unit, "WBK_Runner_Angry_Idle"] remoteExec ["switchMove", 0];
    };

    // Refresh player knowledge so findNearestEnemy returns valid targets
    { _unit reveal [_x, 4]; } forEach playableUnits;
    // Re-issue movement order (replaces WBK's 0.5s self-doMove)
    private _players = allPlayers select { alive _x && lifeState _x != "INCAPACITATED" };
    if (count _players > 0) then {
        _unit doMove (getPos (selectRandom _players));
    };
    sleep (EJ_SPAWN_SPRINT_DURATION - 1.5);
    if (alive _unit) then { _unit forceSpeed -1; };
};

// --- Bloater tracking for contextual barricade targeting ---
// The bloater barricade PFH (fn_bloaterBarricadePFH) iterates EJ_activeBloaters
// to check for barricade obstructions. Track bloaters on spawn and clean up on death.
if (_className == "Zombie_Special_OPFOR_Boomer") then {
    if (isNil "EJ_activeBloaters") then { EJ_activeBloaters = []; };
    EJ_activeBloaters pushBack _unit;

    // Killed EH: apply barricade HP damage on death regardless of what killed
    // the bloater (mod's native proximity explosion, PFH detonation, or player
    // gunfire). The mod's _actFr (0.3s) frequently beats our PFH (1.0s) to
    // the kill when a player is behind the barricade, so barricade damage
    // MUST be event-driven, not PFH-tick-driven.
    _unit addEventHandler ["Killed", {
        params ["_unit"];
        if (!isServer) exitWith {};
        private _pos = getPosATL _unit;
        private _blastRadius = if (!isNil "EJ_BLOATER_BARRICADE_RADIUS") then { EJ_BLOATER_BARRICADE_RADIUS } else { 7 };
        private _barricadeDmg = if (!isNil "EJ_BLOATER_BARRICADE_DAMAGE") then { EJ_BLOATER_BARRICADE_DAMAGE } else { 0.4 };

        diag_log format ["[EJ] Bloater Killed EH: pos=%1, barricades in list=%2, blastR=%3, dmg=%4",
            _pos, count PLAYER_OBJECT_LIST, _blastRadius, _barricadeDmg];

        // Raise ray origin 1m above ground to avoid terrain surface clipping.
        // lineIntersectsSurfaces with LOD2="NONE" includes terrain hits;
        // a ground-level ray clips the surface and falsely blocks LOS.
        private _rayZ = 1.0;

        {
            if (!isNull _x) then {
                private _distToObj = _pos distance (getPos _x);
                if (_distToObj <= _blastRadius) then {
                    // LOS check: explosion shouldn't damage through other walls.
                    // ignore1 = _unit (dead bloater body still has GEOM collision)
                    // ignore2 = _x (the target barricade — we're checking if something
                    //   ELSE blocks the path, not the barricade itself)
                    private _startASL = AGLToASL (_pos vectorAdd [0,0,_rayZ]);
                    private _endASL   = AGLToASL ((getPos _x) vectorAdd [0,0,_rayZ]);
                    private _losCheck = lineIntersectsSurfaces [
                        _startASL,
                        _endASL,
                        _unit,
                        _x,
                        true,
                        1,
                        "GEOM",
                        "NONE"
                    ];
                    // Allow damage if:
                    //   - nothing blocks the ray, OR
                    //   - the hit is terrain/water (objNull), OR
                    //   - the hit is the target barricade itself (shouldn't happen since ignored, but safe)
                    private _blocked = false;
                    if (count _losCheck > 0) then {
                        private _hitObj = (_losCheck select 0) select 2;
                        if (!isNull _hitObj && {!(_hitObj isEqualTo _x)}) then {
                            _blocked = true;
                        };
                    };
                    if (!_blocked) then {
                        private _hp = _x getVariable ["EJ_structHP", 1];
                        _hp = _hp - _barricadeDmg;
                        diag_log format ["[EJ] Bloater barricade damage: %1 at %2m — HP %3 -> %4",
                            typeOf _x, round _distToObj, _hp + _barricadeDmg, _hp];
                        if (_hp <= 0) then {
                            private _objPos = getPos _x;
                            [_objPos] remoteExec ["EJ_fnc_barricadeDestroyVFX", 0];
                            deleteVehicle _x;
                        } else {
                            _x setVariable ["EJ_structHP", _hp, true];
                        };
                    } else {
                        diag_log format ["[EJ] Bloater barricade LOS BLOCKED: %1 at %2m — blocked by %3",
                            typeOf _x, round _distToObj, typeOf ((_losCheck select 0) select 2)];
                    };
                };
            };
        } forEach PLAYER_OBJECT_LIST;
    }];
};

// --- Bulwarks scoring integration ---
// killPointMulti and points[] are read by score/functions/fn_killed.sqf
_unit setVariable ["killPointMulti", _pointMulti];
_unit setVariable ["points", []];

// MPKilled EH — fires on ALL machines (including server) regardless of
// unit locality.  fn_killed gates on isServer so only processes once.
// This replaces a local "Killed" EH that broke when AI was offloaded
// to a Headless Client (the EH would fire on the HC, where isServer is
// false, and scoring was silently skipped).
_unit addMPEventHandler ["MPKilled", {
    _this call killPoints_fnc_killed;
}];

// MPHit EH — PRIMARY hit scoring path.  Fires on ALL machines for every hit,
// immune to WBK's removeAllEventHandlers "HitPart".
// With allowDamage false (set every tick by WBK PFH), damage param is 0,
// but instigator/causedBy are still valid. Awards a flat hit score.
// If the HitPart bridge (below) also fires, it provides more precise
// damage-based scoring and sets a dedup timestamp so we don't double-score.
_unit addMPEventHandler ["MPHit", {
    if (!isServer) exitWith {};
    params ["_unit", "_causedBy", "_damage", "_instigator"];

    // Resolve the player who caused the hit
    private _scorer = if (isPlayer _instigator) then {
        _instigator
    } else {
        if (isPlayer _causedBy) then { _causedBy } else { objNull }
    };
    if (isNull _scorer || {!isPlayer _scorer}) exitWith {};

    // Always update last scorer for Killed EH instigator fallback
    _unit setVariable ["EJ_lastScorer", _scorer];

    // Dedup: if HitPart bridge already scored this hit (within 50ms), skip
    // flat scoring (HitPart provides more precise damage-based scoring).
    private _lastHPTime = _unit getVariable ["EJ_lastHitPartTime", -1];
    if (diag_tickTime - _lastHPTime < 0.05) exitWith {};

    // Award flat hit score (can't get ammo data from MPHit, so use average)
    private _scoreVal = SCORE_HIT + (SCORE_DAMAGE_BASE * 0.5);

    [_scorer, _scoreVal] call killPoints_fnc_add;

    // Accumulate for kill bonus (read by fn_killed)
    private _pointsArr = _unit getVariable ["points", []];
    _pointsArr pushBack _scoreVal;
    _unit setVariable ["points", _pointsArr];

    // Hit marker on the shooter's client
    [_unit, round _scoreVal, [0.1, 1, 0.1]] remoteExec ["killPoints_fnc_hitMarker", _scorer];
}];

// --- Deferred init: HitPart bridge + maxHP snapshot ---
// WBK's AI script (fired async via Extended_InitPost → execVM) ends with:
//   1. PFH registrations → stores IDs in WBK_AI_AttachedHandlers  (last sync line)
//   2. remoteExec ["spawn", 0, true] → removeAllEventHandlers "HitPart" + add WBK HitPart
//
// If we add our HitPart EH immediately, WBK's removeAllEventHandlers wipes it.
// Solution: wait for WBK_AI_AttachedHandlers (confirms script body done),
// then sleep to let the queued remoteExec land, THEN register our bridge EH.
//
// The bridge EH is registered via fn_registerHitPartBridge, which handles
// HC locality: if the unit was offloaded to a HC during the wait, the
// registration is remoteExec'd to the HC so the EH fires there and relays
// score data back to the server.
[_unit] spawn {
    params ["_u"];
    private _timeout = diag_tickTime + 8;

    // Phase 1: Wait for WBK AI script to finish its synchronous body
    waitUntil {
        !isNil { _u getVariable "WBK_AI_AttachedHandlers" }
        OR { diag_tickTime > _timeout }
        OR { !alive _u }
    };
    if (!alive _u) exitWith {};

    // Phase 2: Yield frames to let WBK's remoteExec ["spawn",0,true] process.
    // The remoteExec was queued during Phase 1; it needs scheduler time to execute
    // removeAllEventHandlers "HitPart" and add WBK's own HitPart EH.
    sleep 1.0;
    if (!alive _u) exitWith {};

    // Phase 3: Register HitPart bridge on wherever the unit currently lives.
    // If the unit is still server-local, register directly.
    // If it was offloaded to a Headless Client, remoteExec to that machine.
    if (local _u) then {
        [_u] call EJ_fnc_registerHitPartBridge;
    } else {
        [_u] remoteExecCall ["EJ_fnc_registerHitPartBridge", owner _u];
    };
};

// --- Zeus editability ---
if (!isNil "mainZeus") then {
    mainZeus addCuratorEditableObjects [[_unit], true];
};

// --- Wave tracking (append to waveUnits[0] for body cleanup) ---
if (!isNil "waveUnits") then {
    if (count waveUnits > 0) then {
        (waveUnits select 0) pushBack _unit;
    };
};

diag_log format ["[EJ] Spawned %1 at %2 (pointMulti: %3)", _className, _pos, _pointMulti];

_unit
