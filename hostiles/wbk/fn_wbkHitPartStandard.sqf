/**
 *  fn_wbkHitPartStandard
 *
 *  Patch 2 — Authoritative regular-zombie HitPart handler.
 *  Mirrors the documented standard WBK damage chain for Shamblers,
 *  runners, and Screamers, including subtype-specific leg behavior.
 *
 *  Domain: Unit owner
 */

private _eventData = _this;
if !(_eventData isEqualType [] && {count _eventData >= 7}) exitWith {
    diag_log format ["[EJ] Invalid HitPart payload for wbkHitPartStandard: %1", _eventData];
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
private _hitSel = if ((_selection isEqualType []) && {count _selection > 0}) then { toLower (_selection select 0) } else { "" };
private _animState = toLower animationState _unit;
private _moveSet = toLower (_unit getVariable ["WBK_AI_ZombieMoveSet", ""]);
private _isCrawler = _moveSet find "crawler" >= 0;
private _isMidFall = _animState find "fall" >= 0;
private _hsMulti = if (!isNil "WBK_Zombies_HeadshotMP") then { WBK_Zombies_HeadshotMP } else { 5 };
private _legSelections = [
    "leftfoot","lefttoebase","leftleg","leftlegroll",
    "leftupleg","leftuplegroll","rightupleg","rightuplegroll",
    "rightleg","rightlegroll","rightfoot","righttoebase"
];
private _className = typeOf _unit;
private _subtype = switch true do {
    case (_className == "Zombie_Special_OPFOR_Screamer"): { "screamer" };
    case (_className == "Zombie_O_Shambler_Civ"): { "shambler" };
    default { "runner" };
};

private _hpDelta = 0;
private _scoringDamage = 0;
private _isHeadshot = _hitSel in ["head", "neck", "face_hub"];
private _isLegHit = _hitSel in _legSelections;

switch true do {
    case (_explosive >= 0.7 && {!_isCrawler}): {
        _hpDelta = (_baseDmg * 2) min _synthHPBefore;
        _scoringDamage = _hpDelta;
    };
    case (_isHeadshot && {!_isMidFall}): {
        _hpDelta = (_baseDmg * _hsMulti) min _synthHPBefore;
        _scoringDamage = _hpDelta;
    };
    case (_isLegHit && {!_isCrawler}): {
        _scoringDamage = _baseDmg * 0.25;

        switch (_subtype) do {
            case "shambler": {
                [_unit, "WBK_Crawler_TransformTo"] remoteExec ["switchMove", 0];
                [_unit, "WBK_Crawler_Idle"] remoteExec ["playMoveNow", 0];
                _unit setVariable ["WBK_AI_ZombieMoveSet", "WBK_Crawler_Idle", true];
            };
            case "screamer": {
                [_unit, "WBK_Runner_Fall_Forward"] remoteExec ["switchMove", 0];
            };
            default {
                if (random 1 < 0.3) then {
                    [_unit, "WBK_Crawler_TransformTo"] remoteExec ["switchMove", 0];
                    [_unit, "WBK_Crawler_Idle"] remoteExec ["playMoveNow", 0];
                    _unit setVariable ["WBK_AI_ZombieMoveSet", "WBK_Crawler_Idle", true];
                } else {
                    [_unit, "WBK_Runner_Fall_Forward"] remoteExec ["switchMove", 0];
                };
            };
        };
    };
    default {
        _hpDelta = _baseDmg min _synthHPBefore;
        _scoringDamage = _hpDelta;
    };
};

private _synthHPAfter = (_synthHPBefore - _hpDelta) max 0;
if (_hpDelta > 0) then {
    _unit setVariable ["WBK_SynthHP", _synthHPAfter, true];
};

private _isLethal = _hpDelta > 0 && {_synthHPAfter <= 0};
if (_isHeadshot && {_isLethal} && {_baseDmg >= 10.5}) then {
    if (_baseDmg >= 14) then {
        removeHeadgear _unit;
        removeGoggles _unit;
        [_unit, "WBK_DecapatedHead_Zombies_Normal"] remoteExec ["setFace", 0];
    } else {
        private _face = "WBK_DosHead_FrontHole";
        if (!isNull _shooter) then {
            private _relativePos = _unit worldToModelVisual (getPosASL _shooter);
            if (count _relativePos > 1 && {(_relativePos select 1) < 0}) then {
                _face = "WBK_DosHead_BackHole";
            };
        };
        [_unit, _face] remoteExec ["setFace", 0];
    };
};

if (_scoringDamage <= 0 && {!_isLethal}) exitWith {};

private _hitSeq = (_unit getVariable ["EJ_wbkHitSeq", 0]) + 1;
_unit setVariable ["EJ_wbkHitSeq", _hitSeq];

private _payload = [
    _unit,
    _scorer,
    _hitSeq,
    _synthHPBefore,
    _synthHPAfter,
    _scoringDamage,
    _isLethal,
    [format ["standard:%1", _subtype], _hitSel]
];

if (isServer) then {
    _payload call EJ_fnc_wbkCommitHitAndMaybeKill;
} else {
    _payload remoteExecCall ["EJ_fnc_wbkCommitHitAndMaybeKill", 2];
};