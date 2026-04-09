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
 *
 *  Returns: the created unit, or objNull on failure
 *
 *  Domain: Server
 */

if (!isServer) exitWith { objNull };

params [
    "_pos",
    "_className",
    ["_pointMulti", 1]
];

// --- Create the unit on an EAST group ---
private _group = createGroup [EAST, true];
private _unit  = _group createUnit [_className, _pos, [], 0.5, "FORM"];

if (isNull _unit) exitWith {
    diag_log format ["[EJ] ERROR: createUnit failed for class '%1' at %2", _className, _pos];
    objNull
};

// --- Initial movement order toward a player ---
if (count playableUnits > 0) then {
    _unit doMove (getPos (selectRandom playableUnits));
};

// --- Bulwarks scoring integration ---
// killPointMulti and points[] are read by score/functions/fn_killed.sqf
_unit setVariable ["killPointMulti", _pointMulti];
_unit setVariable ["points", []];

// Killed EH — fires when WBK's HitPart calls setDamage 1 on SynthHP depletion
_unit addEventHandler ["Killed", killPoints_fnc_killed];

// HitPart-to-Score bridge — additive alongside WBK's own HitPart EH
_unit addEventHandler ["HitPart", EJ_fnc_wbkHitPartScore];

// --- Snapshot max HP for score normalisation ---
// WBK_SynthHP is set by the AI script executed via Extended_InitPost (async execVM).
// We wait until it is available, then store the initial value as the max HP baseline.
[_unit] spawn {
    params ["_u"];
    private _timeout = diag_tickTime + 5;
    waitUntil {
        !isNil { _u getVariable "WBK_SynthHP" }
        OR { diag_tickTime > _timeout }
        OR { !alive _u }
    };
    if (alive _u) then {
        _u setVariable ["EJ_wbk_maxHP", _u getVariable ["WBK_SynthHP", 50]];
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
