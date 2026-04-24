/**
 *  fn_registerHitPartBridge
 *
 *  Registers the HitPart scoring bridge EH on the given unit, with a
 *  relay wrapper that supports both server-local and headless-client-local
 *  units.
 *
 *  When the unit is server-local, the EH calls EJ_fnc_wbkHitPartScore
 *  directly.  When the unit lives on a Headless Client, the EH
 *  pre-extracts all volatile data (projectile parents especially, since
 *  the projectile object may despawn before a remote call lands) and
 *  relays to the server via remoteExecCall.
 *
 *  This function is compiled on ALL machines via CfgFunctions so it can
 *  be called locally or via remoteExecCall from the server to the HC.
 *
 *  Params:
 *    _unit — the zombie unit to attach the EH to (must be local)
 *
 *  Domain: Any (server or headless client)
 */

params ["_unit"];

if (isNull _unit || !alive _unit) exitWith {};
if (!local _unit) exitWith {
    diag_log format ["[EJ] registerHitPartBridge: unit %1 is not local, skipping.", _unit];
};

_unit addEventHandler ["HitPart", {
    (_this select 0) params [
        "_target",
        "_shooter",
        "_projectile",
        "_position",
        "_velocity",
        "_selection",
        "_ammo"
    ];

    // Diagnostic: confirm this EH is firing (if this never appears in RPT,
    // WBK's removeAllEventHandlers "HitPart" wiped it via a late remoteExec)
    diag_log format ["[EJ] HitPart bridge EH FIRED on %1. shooter=%2, isServer=%3",
        typeOf _target, _shooter, isServer];

    // Pre-extract shot parents NOW — projectile may despawn during remoteExec transit
    private _shotParents = if (!isNull _projectile) then {
        getShotParents _projectile
    } else {
        []
    };

    private _extractedData = [_target, _shooter, _shotParents, _selection, _ammo];

    if (isServer) then {
        // Unit is server-local — call scoring directly
        _extractedData call EJ_fnc_wbkHitPartScore;
    } else {
        // Unit is on a Headless Client — relay to server
        _extractedData remoteExecCall ["EJ_fnc_wbkHitPartScore", 2];
    };
}];

// Snapshot max HP for score normalisation (read by fn_wbkHitPartScore)
_unit setVariable ["EJ_wbk_maxHP", _unit getVariable ["WBK_SynthHP", 50]];

// Mark registration complete for diagnostics
_unit setVariable ["EJ_hitPartRegistered", true];

diag_log format ["[EJ] HitPart bridge registered on %1 (local: %2, isServer: %3). maxHP=%4",
    typeOf _unit, local _unit, isServer, _unit getVariable "EJ_wbk_maxHP"];
