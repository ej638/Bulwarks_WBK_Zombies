/**
 *  fn_initPlayerReviveBridge
 *
 *  Installs a revive-aware HandleDamage EH and overrides WBK_CreateDamage
 *  so that WBK zombie melee damage flows through Bulwarks' revive system
 *  instead of bypassing it.
 *
 *  Call once per player machine (initPlayerLocal + onPlayerRespawn).
 *
 *  Domain: Client (each player)
 **/

// ── Guard: wait for TEAM_DAMAGE to be published ──
waitUntil {!isNil "TEAM_DAMAGE"};

// ── Phase 1: Override WBK_CreateDamage ──────────────────────────────
// WBK_CreateDamage is defined in the external WebKnight_StarWars_Mechanic
// mod. It is remoteExec'd on the victim's machine with params
// [_victim, _damage, _source]. It applies damage via setDamage [val, false]
// which bypasses HandleDamage entirely — breaking Bulwarks revive.
//
// We wrap it: for non-players, delegate to the original. For players,
// route through the revive system.

if (isNil "EJ_WBK_CreateDamage_original" && {!isNil "WBK_CreateDamage"}) then {
    EJ_WBK_CreateDamage_original = WBK_CreateDamage;
};

WBK_CreateDamage = {
    params ["_target", "_damage", "_source"];

    // Non-player targets: delegate to original WBK function
    if !(isPlayer _target) exitWith {
        if (!isNil "EJ_WBK_CreateDamage_original") then {
            _this call EJ_WBK_CreateDamage_original;
        };
    };

    // Player is already downed or being revived — block all damage
    // Also clear forceWalk in case a screamer stun is active on the
    // downed player (scream effects fire before WBK_CreateDamage).
    if (lifeState _target == "INCAPACITATED") exitWith {
        _target forceWalk false;
    };
    if (_target getVariable ["RevByMedikit", false]) exitWith {};

    // Player is in an execution animation — allow instant kill
    private _anim = animationState _target;
    if (_anim in ["WBK_Smasher_Execution", "Corrupted_Attack_victim"]) exitWith {
        _target setDamage 1;
    };

    // Calculate prospective total damage
    private _currentDamage = damage _target;
    private _newDamage = _currentDamage + _damage;

    if (_newDamage >= 0.89) then {
        // Lethal hit — check for Medikit auto-revive
        private _playerItems = items _target;
        if ("Medikit" in _playerItems) then {
            _target removeItem "Medikit";
            _target setVariable ["RevByMedikit", true, true];
            _target forceWalk false;
            [_target] remoteExec ["bulwark_fnc_revivePlayer", 2];
            // Block the lethal damage
        } else {
            // Pre-set IMS invincibility so WBK's zombie attack handlers
            // (which check IMS before the INCAPACITATED case) see it
            // immediately and skip the downed player.  Must be set BEFORE
            // setDamage 1 triggers the transition to INCAPACITATED.
            _target setVariable ["IMS_IsUnitInvicibleScripted", 1, true];
            // Set flag so HandleDamage knows this is a WBK-triggered
            // incapacitation, not fall damage
            _target setVariable ["EJ_wbk_pendingRevive", true];
            // Scalar setDamage 1 triggers HandleDamage on this machine,
            // which will detect the flag and call bis_fnc_reviveEhHandleDamage.
            // HandleDamage fires once per hit-point PLUS once for overall —
            // the flag must persist across ALL calls so the overall-selection
            // call reaches bis_fnc_reviveEhHandleDamage (only that call
            // triggers the INCAPACITATED transition).  Clear AFTER return.
            _target setDamage 1;
            _target setVariable ["EJ_wbk_pendingRevive", false];
            _target forceWalk false;
        };
    } else {
        // Sub-lethal: apply damage directly, bypass HandleDamage to avoid
        // double-processing.  Use array form [damage, false] to skip EH.
        _target setDamage [_newDamage, false];
        // Notify player of the hit — setDamage [val, false] bypasses all
        // vanilla screen effects so we trigger the flash manually.
        [_damage] call EJ_fnc_playerHitEffect;
        // Update the persistent damage tint to the new health level.
        [] call EJ_fnc_playerDamageTint;
    };
};

// ── Phase 2: Override WBK_Goliath_SpecialAttackGroundShard ──────────
// This function runs on the victim's machine (remoteExec'd to victim).
// It calls setDamage 1 (scalar) which would either be blocked by
// HandleDamage's environmental check or bypass revive.  Wrap it to set
// the pending-revive flag for players before the original runs.

if (isNil "EJ_WBK_GroundShard_original" && {!isNil "WBK_Goliath_SpecialAttackGroundShard"}) then {
    EJ_WBK_GroundShard_original = WBK_Goliath_SpecialAttackGroundShard;
};

WBK_Goliath_SpecialAttackGroundShard = {
    if (isPlayer _this) then {
        // Ground spike is a cinematic instant-kill (impale animation)
        // Set flag so HandleDamage allows the lethal damage through.
        // Clear AFTER the original returns — setDamage inside the
        // original fires HandleDamage synchronously for every hit-point
        // plus overall; all calls must see the flag.
        _this setVariable ["EJ_wbk_allowLethalDamage", true];
    };
    _this call EJ_WBK_GroundShard_original;
    if (isPlayer _this) then {
        _this setVariable ["EJ_wbk_allowLethalDamage", false];
    };
};

// ── Phase 3: Install revive-aware HandleDamage EH ───────────────────
player removeAllEventHandlers "HandleDamage";
player addEventHandler ["HandleDamage", {
    private _unit    = _this select 0;
    private _damage  = _this select 2;
    private _source  = _this select 3;
    private _ammo    = _this select 4;
    private _hitIdx  = _this select 5;

    private _beingRevived = player getVariable ["RevByMedikit", false];

    // ── Gate: player is incapacitated → block all damage and protect
    // from WBK's explicit INCAPACITATED kill via IMS variable
    if (lifeState player == "INCAPACITATED") exitWith {
        player setVariable ["IMS_IsUnitInvicibleScripted", 1, true];
        // Clean up stale flags and screamer forceWalk in case a scream
        // stun was active when the player went down.
        player setVariable ["EJ_wbk_pendingRevive", false];
        player forceWalk false;
        // Make all EAST zombies forget this player so they retarget to
        // standing players instead of crowding the downed one.
        // forgetTarget must run where the zombie is local (server/HC).
        // Pre-filter to EAST side to skip player/civilian iteration.
        {
            [_x, player] remoteExec ["forgetTarget", _x];
        } forEach (allUnits select { side _x == east && !isNil { _x getVariable "WBK_AI_ISZombie" } });
        0
    };

    // ── Gate: being revived by Medikit → block damage
    if (_beingRevived) exitWith { 0 };

    // ── Gate: execution animations → allow full damage through
    private _anim = animationState player;
    if (_anim in ["WBK_Smasher_Execution", "Corrupted_Attack_victim"]) exitWith {
        _damage
    };

    // ── Gate: Goliath ground spike — cinematic impale, allow instant kill
    // Flag is cleared by the Goliath override wrapper after setDamage
    // returns — do NOT clear here (HandleDamage fires per-hitpoint
    // plus overall; all calls must pass damage through).
    if (player getVariable ["EJ_wbk_allowLethalDamage", false]) exitWith {
        _damage
    };

    // ── Gate: WBK pending revive flag → this is a scripted setDamage 1
    // from our WBK_CreateDamage override or Goliath override; route it
    // into the BIS revive system for incapacitation
    // Flag is cleared by WBK_CreateDamage override after setDamage 1
    // returns — do NOT clear here (HandleDamage fires per-hitpoint
    // plus overall; all calls must reach bis_fnc_reviveEhHandleDamage
    // so the overall-selection call triggers the INCAPACITATED transition).
    if (player getVariable ["EJ_wbk_pendingRevive", false]) exitWith {
        // Reinforce IMS protection — belt-and-suspenders with the
        // pre-set in WBK_CreateDamage override
        player setVariable ["IMS_IsUnitInvicibleScripted", 1, true];
        _this call bis_fnc_reviveEhHandleDamage
    };

    // ── Gate: environmental / fall damage (empty ammo, no external source)
    // Only block when there is no real source (fall damage, self-damage).
    // WBK Goliath's scalar setDamage 1 arrives with _ammo "" but we handle
    // that via the pendingRevive flag above.
    if (_ammo == "" && {isNull _source || {_source isEqualTo player}}) exitWith { 0 };

    // ── Gate: friendly fire (when disabled)
    TEAM_DAMAGE = missionNamespace getVariable "TEAM_DAMAGE";
    private _players = allPlayers;
    if (_source in _players && !TEAM_DAMAGE && !(_source isEqualTo player)) exitWith { 0 };

    // ── Normal damage routing (engine-sourced damage: bullets, explosions)
    private _currentPointDamage = player getHitIndex _hitIdx;
    private _totalDamage = _damage + _currentPointDamage;

    if (_totalDamage >= 0.89) then {
        private _playerItems = items player;
        if ("Medikit" in _playerItems) then {
            player removeItem "Medikit";
            player setVariable ["RevByMedikit", true, true];
            [player] remoteExec ["bulwark_fnc_revivePlayer", 2];
            0
        } else {
            _this call bis_fnc_reviveEhHandleDamage
        };
    } else {
        // Engine-sourced sub-lethal hit (explosion, non-WBK bullet).
        // Vanilla HandleDamage would normally drive screen effects but the
        // revive EH chain suppresses them; fire the flash manually.
        [_damage] call EJ_fnc_playerHitEffect;
        // Update the persistent damage tint to the new health level.
        [] call EJ_fnc_playerDamageTint;
        _this call bis_fnc_reviveEhHandleDamage
    };
}];
