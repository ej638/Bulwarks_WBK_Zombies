/**
 *  fn_wbkHitPartScore
 *
 *  Core Adapter — Phase 1
 *  Additive HitPart Event Handler that bridges WBK synthetic damage
 *  into the Bulwarks scoring pipeline.
 *
 *  WBK zombies call allowDamage false every tick, which breaks the
 *  vanilla Arma "Hit" EH (damage is always 0). This handler reads
 *  the ammo config data from HitPart and mirrors the WBK damage
 *  calculation to derive a normalised damage value for scoring.
 *
 *  This EH is registered ALONGSIDE the WBK-native HitPart EH.
 *  It does NOT modify WBK_SynthHP — that is WBK's responsibility.
 *  It only observes the hit data and feeds it to Bulwarks scoring.
 *
 *  HitPart signature:
 *    [[_target, _shooter, _projectile, _position, _velocity,
 *      _selection, _ammo, _direction, _radius, _surface, _direct]]
 *
 *  Domain: Server (HitPart fires on the machine owning the unit)
 */

if (!isServer) exitWith {};

(_this select 0) params [
    "_target",
    "_shooter",
    "_projectile",
    "_position",
    "_velocity",
    "_selection",
    "_ammo",
    "_direction",
    "_radius",
    "_surface",
    "_direct"
];

// --- Guard: no self-hits, no dead targets, shooter must be a player ---
if (_target == _shooter) exitWith {};
if (!alive _target)      exitWith {};

// Resolve the actual player who caused the hit
// _shooter may be a vehicle; check instigator via getShotParents
private _scorer = if (isPlayer _shooter) then {
    _shooter
} else {
    // For indirect fire (vehicles, explosions), try to resolve the player
    private _parents = getShotParents _projectile;
    if (count _parents > 1 && { isPlayer (_parents select 1) }) then {
        _parents select 1
    } else {
        if (count _parents > 0 && { isPlayer (_parents select 0) }) then {
            _parents select 0
        } else {
            objNull
        };
    };
};

if (isNull _scorer || !isPlayer _scorer) exitWith {};

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

// Add to player's total score
[_scorer, _scoreVal] call killPoints_fnc_add;

// Accumulate into the unit's points array (read by fn_killed for kill bonus)
private _pointsArr = _target getVariable ["points", []];
_pointsArr pushBack _scoreVal;
_target setVariable ["points", _pointsArr];

// Render hit marker on the shooter's client
[_target, round _scoreVal, [0.1, 1, 0.1]] remoteExec ["killPoints_fnc_hitMarker", _scorer];
