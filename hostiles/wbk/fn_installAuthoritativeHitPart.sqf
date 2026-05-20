/**
 *  fn_installAuthoritativeHitPart
 *
 *  Patch 2 — Authoritative owner-local HitPart installation.
 *  Installs the adapter-owned HitPart handler on the local unit owner,
 *  replacing the stock WBK handler on the unit body or Goliath hitbox.
 *
 *  Params:
 *    _unit — WBK zombie unit whose owner-local HitPart path should be replaced
 *
 *  Domain: Any (must run where the unit is local)
 */

params ["_unit", ["_markReady", true]];

if (isNull _unit || {!alive _unit}) exitWith {};
if (!local _unit) exitWith {
    diag_log format ["[EJ] installAuthoritativeHitPart: %1 is not local, skipping.", _unit];
};

private _className = typeOf _unit;
private _family = switch true do {
    case (_className == "Zombie_Special_OPFOR_Leaper_1"): { "leaper" };
    case (_className == "Zombie_Special_OPFOR_Boomer"): { "bloater" };
    case (_className in [
        "WBK_SpecialZombie_Smasher_3",
        "WBK_SpecialZombie_Smasher_Acid_3",
        "WBK_SpecialZombie_Smasher_Hellbeast_3"
    ]): { "smasher" };
    case (_className == "WBK_Goliaph_3"): { "goliath" };
    default { "standard" };
};

private _hookObject = _unit;
if (_family == "goliath") then {
    _hookObject = objNull;

    {
        if (!isNull _x) exitWith {
            _hookObject = _x;
        };
    } forEach [
        _unit getVariable ["Goliath_HitBox", objNull],
        _unit getVariable ["WBK_Goliath_HitBox", objNull],
        _unit getVariable ["EJ_wbkGoliathHitBox", objNull]
    ];

    if (isNull _hookObject) then {
        private _attachedHitboxes = attachedObjects _unit select {
            !isNull _x && {typeOf _x == "Goliath_HitBox"}
        };

        if (count _attachedHitboxes > 0) then {
            _hookObject = _attachedHitboxes select 0;
        };
    };

    if (isNull _hookObject) exitWith {
        _unit setVariable ["EJ_wbkScoreHookReady", false, true];
        _unit setVariable ["EJ_wbkScoreHookVerified", false, true];
        _unit setVariable ["EJ_wbkHitFamily", _family, true];
        diag_log format [
            "[EJ] installAuthoritativeHitPart: Goliath hitbox not found for %1.",
            _unit
        ];
    };
};

if (!local _hookObject) exitWith {
    _unit setVariable ["EJ_wbkScoreHookReady", false, true];
    _unit setVariable ["EJ_wbkScoreHookVerified", false, true];
    _unit setVariable ["EJ_wbkHitFamily", _family, true];
    diag_log format [
        "[EJ] installAuthoritativeHitPart: hook object %1 for %2 is not local.",
        _hookObject,
        _className
    ];
};

_unit setVariable ["EJ_wbkScoreHookReady", false, true];
_unit setVariable ["EJ_wbkScoreHookVerified", false, true];
_unit setVariable ["EJ_wbkHitFamily", _family, true];
_unit setVariable ["EJ_wbk_maxHP", _unit getVariable ["WBK_SynthHP", 50], true];

_hookObject setVariable ["EJ_wbkOwnerUnit", _unit];
_hookObject setVariable ["EJ_wbkHitFamily", _family];
_hookObject removeAllEventHandlers "HitPart";

private _ehId = switch (_family) do {
    case "leaper": {
        _hookObject addEventHandler ["HitPart", {
            (_this select 0) call EJ_fnc_wbkHitPartLeaper;
        }]
    };
    case "bloater": {
        _hookObject addEventHandler ["HitPart", {
            (_this select 0) call EJ_fnc_wbkHitPartBloater;
        }]
    };
    case "smasher": {
        _hookObject addEventHandler ["HitPart", {
            (_this select 0) call EJ_fnc_wbkHitPartSmasher;
        }]
    };
    case "goliath": {
        _hookObject addEventHandler ["HitPart", {
            (_this select 0) call EJ_fnc_wbkHitPartGoliath;
        }]
    };
    default {
        _hookObject addEventHandler ["HitPart", {
            (_this select 0) call EJ_fnc_wbkHitPartStandard;
        }]
    };
};

_unit setVariable ["EJ_wbkAuthoritativeHitPartId", _ehId];
_unit setVariable ["EJ_wbkScoreHookReady", _markReady && {_ehId >= 0}, true];

diag_log format [
    "[EJ] Authoritative HitPart installed: class=%1 family=%2 hook=%3 local=%4 maxHP=%5 ready=%6 verified=%7",
    _className,
    _family,
    typeOf _hookObject,
    local _hookObject,
    _unit getVariable ["EJ_wbk_maxHP", -1],
    _unit getVariable ["EJ_wbkScoreHookReady", false],
    _unit getVariable ["EJ_wbkScoreHookVerified", false]
];