/**
*  fn_killed
*
*  Event handler for unit death.
*  Called via MPKilled (fires on all machines); isServer gate ensures
*  scoring only runs once on the server.
*
*  WBK zombies die via scripted setDamage 1 which may not populate
*  _instigator on dedicated servers. Falls back to EJ_lastScorer
*  (set by fn_wbkHitPartScore on every hit) when instigator is missing.
*
*  Domain: Event (server-gated)
**/

if (isServer) then {
    _unit = _this select 0;
    _instigator = _this select 2;

    // Fallback: WBK's setDamage 1 often does not carry instigator
    // across the network boundary on dedicated servers.
    if (isNull _instigator || {!isPlayer _instigator}) then {
        _instigator = _unit getVariable ["EJ_lastScorer", objNull];
    };

    if (isPlayer _instigator) then {
        _kilPointMulti = _unit getVariable "killPointMulti";
        [_instigator, (SCORE_KILL * _kilPointMulti)] call killPoints_fnc_add;
        _killPoints = (SCORE_KILL * _kilPointMulti);
        _pointsArr = _unit getVariable "points";
        {
          _killPoints = _killPoints + _x;
        } forEach _pointsArr;

        [_unit, round (SCORE_KILL * _kilPointMulti), [0.1, 1, 0.1]] remoteExec ["killPoints_fnc_hitMarker", _instigator];
    };
};
