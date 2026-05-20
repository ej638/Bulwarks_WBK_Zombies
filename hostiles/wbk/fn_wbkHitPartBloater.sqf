/**
 *  fn_wbkHitPartBloater
 *
 *  Patch 2 — Authoritative Bloater HitPart handler.
 *  Mirrors the documented Bloater path: explosive x2, body x1,
 *  with no headshot or leg-specific branch.
 *
 *  Domain: Unit owner
 */

params ["_eventData"];

_eventData params [
    "_target",
    ["_shooter", objNull],
    ["_projectile", objNull],
    ["_position", []],
    ["_velocity", []],
    ["_selection", []],
    ["_ammo", []]
];

private _unit = _target getVariable ["EJ_wbkOwnerUnit", _target];
if (isNull _unit || {!alive _unit}) exitWith {};

private _synthHPBefore = _unit getVariable ["WBK_SynthHP", 0];
if (_synthHPBefore <= 0) exitWith {};

private _scorer = [_shooter, _projectile] call EJ_fnc_wbkResolveScorer;
private _baseDmg = if ((_ammo isEqualType []) && {count _ammo > 0}) then { _ammo select 0 } else { 0 };
private _explosive = if ((_ammo isEqualType []) && {count _ammo > 3}) then { _ammo select 3 } else { 0 };

private _hpDelta = if (_explosive >= 0.7) then {
    (_baseDmg * 2) min _synthHPBefore
} else {
    _baseDmg min _synthHPBefore
};

private _synthHPAfter = (_synthHPBefore - _hpDelta) max 0;
private _isLethal = _hpDelta > 0 && {_synthHPAfter <= 0};

if (_hpDelta > 0) then {
    _unit setVariable ["WBK_SynthHP", _synthHPAfter, true];
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
    ["bloater", "body"]
];

if (isServer) then {
    _payload call EJ_fnc_wbkCommitHitAndMaybeKill;
} else {
    _payload remoteExecCall ["EJ_fnc_wbkCommitHitAndMaybeKill", 2];
};