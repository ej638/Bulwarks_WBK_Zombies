/**
 *  fn_wbkResolveScorer
 *
 *  Patch 1 — Authoritative WBK Scoring Core
 *  Resolves the player who should receive credit for a WBK hit from
 *  the immediate shooter, projectile shot-parent metadata, and the
 *  paratrooper owner fallback.
 *
 *  Params:
 *    _shooter     — direct shooter / instigator candidate
 *    _projectile  — projectile object (optional)
 *    _shotParents — pre-extracted getShotParents result (optional)
 *
 *  Returns: player object or objNull
 *
 *  Domain: Any
 */

params [
    ["_shooter", objNull],
    ["_projectile", objNull],
    ["_shotParents", []]
];

private _resolvedShotParents = +_shotParents;
if ((count _resolvedShotParents) == 0 && {!isNull _projectile}) then {
    _resolvedShotParents = getShotParents _projectile;
};

private _scorer = if (isPlayer _shooter) then {
    _shooter
} else {
    if (count _resolvedShotParents > 1 && {isPlayer (_resolvedShotParents select 1)}) then {
        _resolvedShotParents select 1
    } else {
        if (count _resolvedShotParents > 0 && {isPlayer (_resolvedShotParents select 0)}) then {
            _resolvedShotParents select 0
        } else {
            objNull
        };
    };
};

if (isNull _scorer && {!isNull _shooter}) then {
    private _owner = _shooter getVariable ["EJ_paraOwner", objNull];
    if (!isNull _owner && {isPlayer _owner}) then {
        _scorer = _owner;
    };
};

_scorer