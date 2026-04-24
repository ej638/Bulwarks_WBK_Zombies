/**
 *  fn_playerDamageTint
 *
 *  Maintains a persistent full-screen red overlay that reflects current
 *  player health.  Full health = invisible (alpha 0); more damage = more
 *  opaque red.  The overlay fades smoothly so it naturally tracks all
 *  heal sources (Medikit revive, Bulwark heal, any setDamage 0 call)
 *  without needing explicit hooks at each site.
 *
 *  Implementation: updates the DamageTintOverlay control (idc 99998)
 *  defined in score/hud.hpp.  Uses ctrlSetBackgroundColor so there are
 *  no ppEffect format concerns.  The display is owned by KillPointsHud
 *  (cutRsc layer 1000) which is recreated on every score update;
 *  killPoints_fnc_updateHud calls this function after each cutRsc to
 *  immediately re-apply the tint to the fresh control.
 *
 *  Alpha scale:
 *    damage 0.00  → alpha 0.00  (invisible)
 *    damage 0.30  → alpha 0.075 (faint blush)
 *    damage 0.60  → alpha 0.15  (noticeable red wash)
 *    damage 0.89  → alpha 0.22  (strong red; near incapacitation)
 *
 *  A 1-second CBA PFH (EJ_dmgTintPFH) handles healing between hits.
 *
 *  Domain: Client (player's own machine only — never remoteExec this)
 **/

// ── Start 1-second heal-tracking PFH on first call ──────────────────
if (isNil "EJ_dmgTintPFH") then {
    EJ_dmgTintPFH = [{
        [] call EJ_fnc_playerDamageTint;
    }, 1] call CBA_fnc_addPerFrameHandler;
};

// ── Find the persistent HUD display ─────────────────────────────────
disableSerialization;
private _display = uiNamespace getVariable ["KillPointsHud", displayNull];
if (isNull _display) exitWith {};

private _ctrl = _display displayCtrl 99998;
if (isNull _ctrl) exitWith {};

// ── Scale alpha to current damage ───────────────────────────────────
private _alpha = (damage player) * 0.25;

_ctrl ctrlSetBackgroundColor [1, 0, 0, _alpha];
// Smooth transition: fast enough to feel responsive on a hit, gradual
// enough that healing fades the tint naturally over ~0.4 s.
_ctrl ctrlCommit 0.4;
