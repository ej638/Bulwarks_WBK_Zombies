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
 *    [_target, _shooter, _shotParents, _selection, _ammo,
 *     _preHitSynthHP, _wasAliveAtHit, _hitEventTime]
 *
 *  _preHitSynthHP  — WBK_SynthHP captured at HitPart event-fire time
 *  _wasAliveAtHit  — alive state of target at HitPart event-fire time
 *  _hitEventTime   — diag_tickTime at HitPart event-fire time (for dedup)
 *
 *  Domain: Server only (relay ensures this)
 */

if (!isServer) exitWith {};

params [
    "_target",
    "_shooter",
    "_shotParents",
    "_selection",
    "_ammo",
    ["_preHitSynthHP", -1],
    ["_wasAliveAtHit", true],
    ["_hitEventTime",  -1]
];

// --- Guard: no self-hits ---
if (_target == _shooter) exitWith {};

// Resolve the actual player who caused the hit via the shared Patch 1 helper.
private _scorer = [_shooter, objNull, _shotParents] call EJ_fnc_wbkResolveScorer;

if (isNull _scorer || !isPlayer _scorer) exitWith {};

// --- Persist scorer BEFORE any further validity exits ---
// EJ_lastScorer is kill-attribution state, not a hit-score side effect.
// fn_killed needs it even if this hit is suppressed by dedup or pre-hit
// validity checks. This guarantees attribution for first-hit lethal kills
// where MPKilled fires before our relay arrives.
_target setVariable ["EJ_lastScorer", _scorer];

// --- Pre-hit validity guard (replaces post-hit liveness check) ---
// Reject corpse hits: if the target was dead when HitPart fired, there is
// no real damage to score. Also reject stale relay payloads where WBK had
// already zeroed synthetic HP before the event was raised.
// Do NOT exit merely because the target is dead now — terminal hits arrive
// after WBK forces setDamage 1 and the unit may already be dead on server.
if (!_wasAliveAtHit) exitWith {};
if (_preHitSynthHP <= 0) exitWith {};

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

// --- Clamp to remaining synthetic HP (prevents overkill over-credit) ---
// _preHitSynthHP is guaranteed > 0 by the guard above.
_effectiveDmg = _effectiveDmg min _preHitSynthHP;

// --- Normalise damage to a 0–1 range for fn_hit parity ---
// EJ_wbk_maxHP is snapshotted from WBK_SynthHP at spawn time
private _maxHP  = _target getVariable ["EJ_wbk_maxHP", 50];
private _normDmg = (_effectiveDmg / _maxHP) min 1;

// --- Award score identically to score/functions/fn_hit.sqf ---
private _scoreVal = SCORE_HIT + (SCORE_DAMAGE_BASE * _normDmg);

// --- Symmetric dedup ---
// Mark this event for MPHit (MPHit skips flat score if this is recent).
// Then check if MPHit already awarded this impact: if so, skip our award
// to avoid double-scoring. EJ_lastScorer is already persisted above.
private _lastMPHitTime = _target getVariable ["EJ_lastMPHitTime", -1];
_target setVariable ["EJ_lastHitPartTime", diag_tickTime];

if (diag_tickTime - _lastMPHitTime < 0.05) exitWith {
    // MPHit already awarded a score for this impact; skip double-award.
    diag_log format ["[EJ] HitPart dedup: MPHit won race on %1 (delta=%2ms), skipping score.",
        typeOf _target, round ((diag_tickTime - _lastMPHitTime) * 1000)];
};

// Add to player's total score
[_scorer, _scoreVal] call killPoints_fnc_add;

// Accumulate into the unit's points array (read by fn_killed for kill bonus)
private _pointsArr = _target getVariable ["points", []];
_pointsArr pushBack _scoreVal;
_target setVariable ["points", _pointsArr];

// Render hit marker on the shooter's client
[_target, round _scoreVal, [0.1, 1, 0.1]] remoteExec ["killPoints_fnc_hitMarker", _scorer];
