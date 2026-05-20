/**
*  fn_killed
*
*  Event handler for unit death.
*  Called via MPKilled (fires on all machines); isServer gate ensures
*  scoring only runs once on the server.
*
*  WBK zombies may die through the authoritative kill-ticket path,
*  where the server writes EJ_pendingKillScorer before triggering the
*  lethal engine kill. Direct player instigator remains first priority,
*  then the pending kill ticket, then EJ_lastScorer, then EJ_paraOwner.
*
*  Domain: Event (server-gated)
**/

if (isServer) then {
    private _unit = _this select 0;
    private _directInstigator = _this select 2;
    private _instigator = _directInstigator;
    private _pendingKillScorer = _unit getVariable ["EJ_pendingKillScorer", objNull];
    private _pendingKillSeq = _unit getVariable ["EJ_pendingKillSeq", -1];
    private _hadPendingKillTicket = !isNull _pendingKillScorer || {_pendingKillSeq >= 0};

    // Fallback order for WBK lethals:
    //   1. direct player instigator,
    //   2. pending kill ticket written by authoritative commit,
    //   3. EJ_lastScorer broad fallback,
    //   4. EJ_paraOwner for AI-instigator cases.
    if (isNull _instigator || {!isPlayer _instigator}) then {
        if (!isNull _pendingKillScorer && {isPlayer _pendingKillScorer}) then {
            _instigator = _pendingKillScorer;
        } else {
            _instigator = _unit getVariable ["EJ_lastScorer", objNull];
        };
    };

    // Fallback: kill made by a paratrooper AI — attribute to the calling player.
    // Try the original engine instigator first, then whatever fallback candidate remains.
    if (isNull _instigator || {!isPlayer _instigator}) then {
        private _paraOwner = objNull;

        if (!isNull _directInstigator) then {
            _paraOwner = _directInstigator getVariable ["EJ_paraOwner", objNull];
        };

        if (isNull _paraOwner && {!isNull _instigator}) then {
            _paraOwner = _instigator getVariable ["EJ_paraOwner", objNull];
        };

        if (!isNull _paraOwner && {isPlayer _paraOwner}) then {
            _instigator = _paraOwner;
        };
    };

    if (isPlayer _instigator) then {
        private _kilPointMulti = _unit getVariable ["killPointMulti", 1];
        [_instigator, (SCORE_KILL * _kilPointMulti)] call killPoints_fnc_add;
        private _killPoints = (SCORE_KILL * _kilPointMulti);
        private _pointsArr = _unit getVariable ["points", []];
        {
            _killPoints = _killPoints + _x;
        } forEach _pointsArr;

        [_unit, round (SCORE_KILL * _kilPointMulti), [0.1, 1, 0.1]] remoteExec ["killPoints_fnc_hitMarker", _instigator];
    };

    // Dead bodies must not retain stale lethal tickets.
    if (_hadPendingKillTicket) then {
        _unit setVariable ["EJ_pendingKillScorer", nil];
        _unit setVariable ["EJ_pendingKillSeq", nil];
    };
};
