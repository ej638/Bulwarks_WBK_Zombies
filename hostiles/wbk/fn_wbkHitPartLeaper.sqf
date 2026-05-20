/**
 *  fn_wbkHitPartLeaper
 *
 *  Patch 2 — Authoritative Leaper HitPart handler.
 *  Mirrors the documented Leaper damage path: no explosive branch,
 *  headshot multiplier, body otherwise, and MOVE re-enabled on non-lethal hits.
 *
 *  Domain: Unit owner
 */

private _eventData = _this;
if !(_eventData isEqualType [] && {count _eventData >= 7}) exitWith {
    diag_log format ["[EJ] Invalid HitPart payload for wbkHitPartLeaper: %1", _eventData];
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

private _unit = _target getVariable ["EJ_wbkOwnerUnit", _target];
if (isNull _unit || {!alive _unit}) exitWith {};

_unit setVariable ["EJ_wbkScoreHookVerified", true, true];

private _synthHPBefore = _unit getVariable ["WBK_SynthHP", 0];
if (_synthHPBefore <= 0) exitWith {};

private _scorer = [_shooter, _projectile] call EJ_fnc_wbkResolveScorer;
private _baseDmg = if ((_ammo isEqualType []) && {count _ammo > 0}) then { _ammo select 0 } else { 0 };
private _hitSel = if ((_selection isEqualType []) && {count _selection > 0}) then { toLower (_selection select 0) } else { "" };
private _hsMulti = if (!isNil "WBK_Zombies_HeadshotMP") then { WBK_Zombies_HeadshotMP } else { 5 };
private _isHeadshot = _hitSel in ["head", "neck", "face_hub"];

private _hpDelta = if (_isHeadshot) then {
    (_baseDmg * _hsMulti) min _synthHPBefore
} else {
    _baseDmg min _synthHPBefore
};

private _synthHPAfter = (_synthHPBefore - _hpDelta) max 0;
private _isLethal = _hpDelta > 0 && {_synthHPAfter <= 0};

if (_hpDelta > 0) then {
    _unit setVariable ["WBK_SynthHP", _synthHPAfter, true];
};

if (!_isLethal) then {
    _unit enableAI "MOVE";
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
    ["leaper", _hitSel]
];

if (isServer) then {
    _payload call EJ_fnc_wbkCommitHitAndMaybeKill;
} else {
    _payload remoteExecCall ["EJ_fnc_wbkCommitHitAndMaybeKill", 2];
};