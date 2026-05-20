/**
 *  fn_wbkHitPartGoliath
 *
 *  Patch 2 — Authoritative Goliath HitPart handler.
 *  Runs on the Goliath hitbox owner path, preserves documented animation-
 *  based invulnerability windows, and applies the documented stagger gate.
 *
 *  Domain: Unit owner / Goliath hitbox owner
 */

private _eventData = _this;
if !(_eventData isEqualType [] && {count _eventData >= 7}) exitWith {
    diag_log format ["[EJ] Invalid HitPart payload for wbkHitPartGoliath: %1", _eventData];
};

_eventData params [
    "_target",
    ["_shooter", objNull],
    ["_projectile", objNull],
    ["_position", []],
    ["_velocity", []],
    ["_selection", []],
    ["_ammo", []]
];

private _unit = _target getVariable ["EJ_wbkOwnerUnit", objNull];
if (isNull _unit || {!alive _unit}) exitWith {};

_unit setVariable ["EJ_wbkScoreHookVerified", true, true];

private _immuneStates = [
    "goliaph_staggered",
    "goliaph_throw",
    "goliaph_taunt",
    "goliaph_vehiclegrab",
    "goliaph_rockthrow",
    "goliaph_spikes",
    "goliaph_sync_1",
    "goliaph_sync_2"
];

if ((toLower animationState _unit) in _immuneStates) exitWith {};

private _synthHPBefore = _unit getVariable ["WBK_SynthHP", 0];
if (_synthHPBefore <= 0) exitWith {};

private _scorer = [_shooter, _projectile] call EJ_fnc_wbkResolveScorer;
private _baseDmg = if ((_ammo isEqualType []) && {count _ammo > 0}) then { _ammo select 0 } else { 0 };

private _hpDelta = _baseDmg min _synthHPBefore;
private _synthHPAfter = (_synthHPBefore - _hpDelta) max 0;
private _isLethal = _hpDelta > 0 && {_synthHPAfter <= 0};

if (_hpDelta > 0) then {
    _unit setVariable ["WBK_SynthHP", _synthHPAfter, true];
};

if (_baseDmg >= 300 && {isNil {_unit getVariable "CanBeStunnedIMS"}}) then {
    _unit setVariable ["CanBeStunnedIMS", true];
    [_unit, "Goliaph_Staggered"] remoteExec ["switchMove", 0];
    [_unit] spawn {
        params ["_unit"];
        sleep 90;
        if (!isNull _unit) then {
            _unit setVariable ["CanBeStunnedIMS", nil];
        };
    };
};

if (_hpDelta <= 0 && {!_isLethal}) exitWith {};

private _hitSeq = (_unit getVariable ["EJ_wbkHitSeq", 0]) + 1;
_unit setVariable ["EJ_wbkHitSeq", _hitSeq];

private _payload = [
    _unit,
    _scorer,
    _hitSeq,
    _synthHPBefore,
    _synthHPAfter,
    _hpDelta,
    _isLethal,
    ["goliath", "body"]
];

if (isServer) then {
    _payload call EJ_fnc_wbkCommitHitAndMaybeKill;
} else {
    _payload remoteExecCall ["EJ_fnc_wbkCommitHitAndMaybeKill", 2];
};