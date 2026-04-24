AIstuckcheck = 0;

while {true} do {
  if (east countSide allUnits == 0) then {
    AIStuckCheckArray = [];
    EJ_wbkStuckCheckArray = [];
    AIstuckcheck = -1;
  };
  if (AIstuckcheck == 0) then {
    _allHCs = entities "HeadlessClient_F";
    _allHPs = allPlayers - _allHCs;
    {
      if ((side _x == east) && (alive _x)) then {
        // WBK zombies: position-based stall detection (separate from vanilla)
        // Records current position; evaluated at tick 30 for movement < 3m.
        if (!isNil {_x getVariable "WBK_AI_ISZombie"}) then {
          EJ_wbkStuckCheckArray pushBack [_x, getPosATL _x];
        } else {
          _AIunit = _x;
          nearestPlayerDistance = 9999;
          {
            _distToPlayer = (_AIunit distance2d _x);
            if (_distToPlayer < nearestPlayerDistance) then {
              nearestPlayerDistance = _distToPlayer;
              nearestPlayerPos = getPos _x;
            };
          } forEach _allHPs;
          AIStuckCheckArray pushBack [_x, nearestPlayerDistance, nearestPlayerPos];
        };
      };
    } forEach allUnits;
  };
  AIstuckcheck = AIstuckcheck + 1;
  sleep(1);
  if (AIstuckcheck == 30) then {
    _allHCs = entities "HeadlessClient_F";
    _allHPs = allPlayers - _allHCs;

    // ── Vanilla stuck check (unchanged) ──
    {
      _AItoCheck = _x select 0;
      _OriginalDistToPlayer = _x select 1;
      _OriginalPlayerPos = _x select 2;
      nearestPlayerDistance = 9999;
      {
        _playerHostDistance = _AItoCheck distance2d _x;
        if ((_playerHostDistance < nearestPlayerDistance)) then {
          nearestPlayerDistance = _playerHostDistance;
        };
      } forEach _allHPs;
      _newDistToPlayerPos = _AItoCheck distance2d _OriginalPlayerPos;
      if ((alive _AItoCheck) && (_newDistToPlayerPos > (_OriginalDistToPlayer - 15))) then {
        if (((west knowsAbout _AItoCheck) < 3.5) && (nearestPlayerDistance > 35) && (_AItoCheck distance bulwarkBox > 20)) then {
          if (isNull objectParent _AItoCheck) then {
            deleteVehicle _AItoCheck;
          }else{
            if (nearestPlayerDistance >= BULWARK_RADIUS) then {
              objectParent _AItoCheck setDamage 1;
            };
          };
        };
      };
    } forEach AIStuckCheckArray;

    // ── WBK zombie stuck check — position-based stall detection ──
    // WBK PFH pathfinding doesn't use doMove, so vanilla distance-to-player
    // heuristic causes false positives on slow types (Hotfix 3.2).
    // Instead: check if the zombie moved at all in 30 seconds.
    // Even Crawlers (~0.5 m/s) cover ~15m in 30s; threshold is 3m.
    // Guard: skip zombies within 25m of a player (may be in melee combat
    // and legitimately stationary while attacking).
    // Strike system: 2 consecutive stalls (60s total) → setDamage 1.
    // Uses setDamage 1 (not deleteVehicle) to preserve WBK Killed EH,
    // score pipeline, and waveUnits body cleanup.
    {
      _wbkUnit     = _x select 0;
      _snapshotPos = _x select 1;

      if (alive _wbkUnit) then {
        private _moved = _wbkUnit distance2d _snapshotPos;

        // Find nearest player distance
        private _nearPlayerDist = 9999;
        {
          private _d = _wbkUnit distance2d _x;
          if (_d < _nearPlayerDist) then { _nearPlayerDist = _d };
        } forEach _allHPs;

        if (_moved < 3 && _nearPlayerDist > 25) then {
          // Zombie barely moved and is not near any player — increment strike
          private _strikes = _wbkUnit getVariable ["EJ_stuckStrikes", 0];
          _strikes = _strikes + 1;
          // Fast-path: kill immediately on strike 1 if this is the sole remaining
          // EAST unit. Recovery doMove is only useful when other zombies are alive;
          // when it's the last one, waiting a full extra 30s just leaves players
          // in silence wondering if the wave is over.
          private _isLastUnit = (EAST countSide allUnits == 1);
          if (_strikes >= 2 || _isLastUnit) then {
            // 2 consecutive stalls (60s) OR last zombie after 30s stall — kill it
            _wbkUnit setDamage 1;
            diag_log format ["[EJ] Stuck WBK zombie killed: %1 at %2 (moved %3m, %4m from player, last=%5)",
              typeOf _wbkUnit, getPosATL _wbkUnit, _moved, _nearPlayerDist, _isLastUnit];
          } else {
            _wbkUnit setVariable ["EJ_stuckStrikes", _strikes];
            // Recovery attempt: refresh target knowledge and issue doMove.
            // Covers the case where findNearestEnemy returns objNull due to
            // stale knowledge (disableAI "TARGET" prevents self-acquisition).
            // If this works, the zombie will move >3m in the next 30s cycle
            // and the strike counter resets. If it doesn't, strike 2 kills it.
            private _nearPlayer = objNull;
            private _bestDist = 1e6;
            {
              private _d = _wbkUnit distance _x;
              if (_d < _bestDist) then { _bestDist = _d; _nearPlayer = _x; };
            } forEach _allHPs;
            if (!isNull _nearPlayer) then {
              _wbkUnit reveal [_nearPlayer, 4];
              _wbkUnit doMove (getPos _nearPlayer);
              diag_log format ["[EJ] Stuck WBK zombie recovery: %1 — doMove toward player at %2m",
                typeOf _wbkUnit, round _bestDist];
            };
          };
        } else {
          // Zombie is moving or near a player — reset strikes
          _wbkUnit setVariable ["EJ_stuckStrikes", 0];
        };
      };
    } forEach EJ_wbkStuckCheckArray;

    AIstuckcheck = 0;
    AIStuckCheckArray = [];
    EJ_wbkStuckCheckArray = [];
  };
};
