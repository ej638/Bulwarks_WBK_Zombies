/**
 *  fn_registerHitPartBridge
 *
 *  Patch 6 — compatibility wrapper.
 *  The observer bridge is no longer part of the live correctness path.
 *  If this function is reached during rollout, log the unexpected call
 *  and forward to the authoritative installer instead of re-creating the
 *  legacy observer EH.
 *
 *  Params:
 *    _unit — the WBK zombie unit whose owner-local authoritative hook should exist
 *
 *  Domain: Any (server or headless client)
 */

params ["_unit"];

if (isNull _unit || !alive _unit) exitWith {};

diag_log format [
    "[EJ] COMPAT: registerHitPartBridge reached for %1. Forwarding to authoritative installer.",
    typeOf _unit
];

if (local _unit) then {
    [_unit, true] call EJ_fnc_installAuthoritativeHitPart;
} else {
    [_unit, true] remoteExecCall ["EJ_fnc_installAuthoritativeHitPart", owner _unit];
};

_unit setVariable ["EJ_hitPartRegistered", false];
