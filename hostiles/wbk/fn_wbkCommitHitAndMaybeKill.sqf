/**
 *  fn_wbkCommitHitAndMaybeKill
 *
 *  Patch 1 — Authoritative WBK Scoring Core
 *  Server-side commit point for owner-local WBK hit transactions.
 *  Persists scorer state, awards the hit score, and stages the kill
 *  ticket before triggering the lethal engine kill.
 *
 *  Expected params:
 *    [_target, _scorer, _hitSeq, _synthHPBefore, _synthHPAfter,
 *     _scoringDamage, _isLethal, _hitMeta]
 *
 *  Domain: Server
 */

if (!isServer) exitWith {};

params [
    "_target",
    ["_scorer", objNull],
    ["_hitSeq", -1],
    ["_synthHPBefore", -1],
    ["_synthHPAfter", -1],
    ["_scoringDamage", 0],
    ["_isLethal", false],
    ["_hitMeta", []]
];

if (isNull _target) exitWith {};

private _lastCommittedSeq = _target getVariable ["EJ_wbkLastCommittedSeq", -1];
if (_hitSeq <= _lastCommittedSeq) exitWith {
    diag_log format [
        "[EJ] WBK commit dropped stale seq on %1: seq=%2 last=%3 meta=%4",
        typeOf _target,
        _hitSeq,
        _lastCommittedSeq,
        _hitMeta
    ];
};

_target setVariable ["EJ_wbkLastCommittedSeq", _hitSeq];

private _hasValidScorer = !isNull _scorer && {isPlayer _scorer};
if (_hasValidScorer) then {
    _target setVariable ["EJ_lastScorer", _scorer];
};

private _hasScorableDamage = _hasValidScorer && {_scoringDamage > 0};
private _lastMPHitTime = _target getVariable ["EJ_lastMPHitTime", -1];
private _mpHitWonRace = false;

if (_hasScorableDamage) then {
    _target setVariable ["EJ_lastHitPartTime", diag_tickTime];
    _mpHitWonRace = diag_tickTime - _lastMPHitTime < 0.05;
};

if (_hasScorableDamage && {!_mpHitWonRace}) then {
    private _maxHP = (_target getVariable ["EJ_wbk_maxHP", 1]) max 1;
    private _normDmg = ((_scoringDamage / _maxHP) max 0) min 1;
    private _scoreVal = SCORE_HIT + (SCORE_DAMAGE_BASE * _normDmg);

    [_scorer, _scoreVal] call killPoints_fnc_add;

    private _pointsArr = _target getVariable ["points", []];
    _pointsArr pushBack _scoreVal;
    _target setVariable ["points", _pointsArr];

    [_target, round _scoreVal, [0.1, 1, 0.1]] remoteExec ["killPoints_fnc_hitMarker", _scorer];
} else {
    if (_mpHitWonRace) then {
        diag_log format [
            "[EJ] WBK commit dedup: MPHit won race on %1 (seq=%2 meta=%3).",
            typeOf _target,
            _hitSeq,
            _hitMeta
        ];
    };
};

if (_isLethal) then {
    if (_hasValidScorer) then {
        _target setVariable ["EJ_pendingKillScorer", _scorer];
        _target setVariable ["EJ_pendingKillSeq", _hitSeq];
    };

    if (local _target) then {
        _target setDamage 1;
    } else {
        [_target, 1] remoteExecCall ["setDamage", owner _target];
    };
};