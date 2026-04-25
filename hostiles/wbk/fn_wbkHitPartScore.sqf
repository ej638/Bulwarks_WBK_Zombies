/**
 *  fn_wbkHitPartScore
 *
 *  Core Adapter — Phase 1 / Phase 3 (Dedicated-Server + HC fix)
 *  Bridges WBK synthetic damage into the Bulwarks scoring pipeline.
 *
 *  WBK zombies call allowDamage false every tick, which breaks the
 *  vanilla Arma "Hit" EH (damage is always 0). This function reads
 *  the ammo config data and mirrors the WBK damage calculation to
 *  derive a normalised damage value for scoring.
 *
 *  Called in two ways (both via fn_registerHitPartBridge relay):
 *    - Directly on server when the zombie is server-local
 *    - Via remoteExecCall from a Headless Client when the zombie
 *      has been offloaded
 *
 *  Expected params (pre-extracted by the relay wrapper):
 *    [_target, _shooter, _shotParents, _selection, _ammo]
 *
 *  Domain: Server only (relay ensures this)
 */

if (!isServer) exitWith {};

params [
    "_target",
    "_shooter",
    "_shotParents",
    "_selection",
    "_ammo"
];

// --- Guard: no self-hits, no dead targets ---
if (_target == _shooter) exitWith {};
if (!alive _target)      exitWith {};

// Resolve the actual player who caused the hit
// _shooter may be a vehicle; use pre-extracted _shotParents
// (_projectile may have despawned during remoteExec transit)
private _scorer = if (isPlayer _shooter) then {
    _shooter
} else {
    if (count _shotParents > 1 && { isPlayer (_shotParents select 1) }) then {
        _shotParents select 1
    } else {
        if (count _shotParents > 0 && { isPlayer (_shotParents select 0) }) then {
            _shotParents select 0
        } else {
            objNull
        };
    };
};

// Paratrooper AI fallback: if the shooter is not a player, check if it is
// an AI owned by a player (EJ_paraOwner). This covers WBK zombie kills by
// paratroopers — WBK's setDamage 1 strips the instigator from MPKilled, so
// EJ_lastScorer is the only reliable attribution path for these units.
if (isNull _scorer) then {
    private _owner = _shooter getVariable ["EJ_paraOwner", objNull];
    if (!isNull _owner && {isPlayer _owner}) then {
        _scorer = _owner;
    };
};

if (isNull _scorer || !isPlayer _scorer) exitWith {};

// --- Track last scorer for Killed EH fallback ---
// WBK kills via setDamage 1 which may not pass instigator across the
// network boundary on dedicated server. This gives fn_killed a fallback.
_target setVariable ["EJ_lastScorer", _scorer];

// --- Determine the effective damage this hit dealt ---
// Mirror WBK's HitPart priority chain (simplified for scoring only):
//   1. Explosive hit (_ammo select 3 >= 0.7): baseDmg × 2
//   2. Headshot (_selection in [head, neck]):  baseDmg × WBK_Zombies_HeadshotMP
//   3. Leg hit: no HP damage in WBK (just cripple), skip scoring
//   4. Body hit: baseDmg × 1
private _baseDmg     = _ammo select 0;  // ammo config "hit" value
private _explosive   = _ammo select 3;  // ammo config "explosive" value
private _hitSel      = _selection select 0;

private _effectiveDmg = 0;

if (_explosive >= 0.7) then {
    // Explosive: WBK applies ×2 multiplier
    _effectiveDmg = _baseDmg * 2;
} else {
    if (_hitSel in ["head", "neck", "face_hub"]) then {
        // Headshot: WBK applies headshot multiplier
        private _hsMulti = if (!isNil "WBK_Zombies_HeadshotMP") then {
            WBK_Zombies_HeadshotMP
        } else {
            5  // CBA default
        };
        _effectiveDmg = _baseDmg * _hsMulti;
    } else {
        if (_hitSel in [
            "leftfoot","lefttoebase","leftleg","leftlegroll",
            "leftupleg","leftuplegroll","rightupleg","rightuplegroll",
            "rightleg","rightlegroll","rightfoot","righttoebase"
        ]) then {
            // Leg hit: WBK does not deduct HP, only cripples.
            // Award a small flat score so the player gets feedback.
            _effectiveDmg = _baseDmg * 0.25;
        } else {
            // Body hit: 1:1
            _effectiveDmg = _baseDmg;
        };
    };
};

if (_effectiveDmg <= 0) exitWith {};

// --- Normalise damage to a 0–1 range for fn_hit parity ---
// EJ_wbk_maxHP is snapshotted from WBK_SynthHP at spawn time
private _maxHP  = _target getVariable ["EJ_wbk_maxHP", 50];
private _normDmg = (_effectiveDmg / _maxHP) min 1;

// --- Award score identically to score/functions/fn_hit.sqf ---
private _scoreVal = SCORE_HIT + (SCORE_DAMAGE_BASE * _normDmg);

// Mark this hit as scored by HitPart (for MPHit dedup).
// MPHit also fires for the same hit; if this timestamp is recent,
// MPHit skips its flat scoring since HitPart has more precise data.
_target setVariable ["EJ_lastHitPartTime", diag_tickTime];

// Add to player's total score
[_scorer, _scoreVal] call killPoints_fnc_add;

// Accumulate into the unit's points array (read by fn_killed for kill bonus)
private _pointsArr = _target getVariable ["points", []];
_pointsArr pushBack _scoreVal;
_target setVariable ["points", _pointsArr];

// Render hit marker on the shooter's client
[_target, round _scoreVal, [0.1, 1, 0.1]] remoteExec ["killPoints_fnc_hitMarker", _scorer];
