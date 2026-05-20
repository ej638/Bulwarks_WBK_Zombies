/**
 *  fn_wbkHitPartSmasher
 *
 *  Patch 2 — Authoritative Smasher HitPart handler.
 *  The available audit material confirms a dedicated incoming-hit path and
 *  a documented stun cooldown trigger, but not the full stock branch body.
 *  This handler therefore keeps damage conservative (ammo hit value) while
 *  preserving the documented stun-cooldown side effect.
 *
 *  Domain: Unit owner
 */

private _eventData = _this;
if !(_eventData isEqualType [] && {count _eventData >= 7}) exitWith {
    diag_log format ["[EJ] Invalid HitPart payload for wbkHitPartSmasher: %1", _eventData];
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
private _explosive = if ((_ammo isEqualType []) && {count _ammo > 3}) then { _ammo select 3 } else { 0 };

private _hpDelta = _baseDmg min _synthHPBefore;
private _synthHPAfter = (_synthHPBefore - _hpDelta) max 0;
private _isLethal = _hpDelta > 0 && {_synthHPAfter <= 0};

if (_hpDelta > 0) then {
    _unit setVariable ["WBK_SynthHP", _synthHPAfter, true];
};

if ((_explosive >= 0.7 || {_baseDmg >= 100}) && {isNil {_unit getVariable "CanBeStunnedIMS"}}) then {
    _unit setVariable ["CanBeStunnedIMS", true];
    [_unit] spawn {
        params ["_unit"];
        sleep 6;
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
    ["smasher", "body"]
];

if (isServer) then {
    _payload call EJ_fnc_wbkCommitHitAndMaybeKill;
} else {
    _payload remoteExecCall ["EJ_fnc_wbkCommitHitAndMaybeKill", 2];
};