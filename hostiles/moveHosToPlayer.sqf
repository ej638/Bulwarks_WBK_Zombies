/**
*  moveHosToPlayer
*
*  Moves AI to Player — single-pass optimised loop.
*  Reveals players to WBK zombies (refreshes findNearestEnemy knowledge),
*  finds nearest valid player, and issues movement commands.
*
*  Domain: Server
**/

While {true} do {
  // ── Cache player list once per cycle ──
  private _allHCs = entities "HeadlessClient_F";
  private _allHPs = allPlayers - _allHCs;

  // ── Pre-filter valid targets (alive, non-incapacitated) once per cycle ──
  private _aiTargets = _allHPs select { alive _x && lifeState _x != "INCAPACITATED" };

  // ── Cache WBK move distance limit once per cycle ──
  private _moveDistLimit = if (isNil "WBK_Zombies_MoveDistanceLimit") then { 150 } else { WBK_Zombies_MoveDistanceLimit };

  // ── Single pass over all EAST units ──
  {
    if (side _x == east && alive _x) then {
      private _unit = _x;

      // ── Find nearest valid player ──
      private _nearestPlayer = objNull;
      private _nearestDist = 1e6;
      {
        private _d = _unit distance _x;
        if (_d < _nearestDist) then {
          _nearestDist = _d;
          _nearestPlayer = _x;
        };
      } forEach _aiTargets;

      // No valid target → skip this unit entirely
      if (isNull _nearestPlayer) then { continue };

      if (!isNil {_unit getVariable "WBK_AI_ISZombie"}) then {
        // ── WBK ZOMBIE PATH ──

        // Reveal standing players to refresh findNearestEnemy knowledge
        _unit allowFleeing 0;
        { _unit reveal [_x, 4]; } forEach _aiTargets;

        // ── Cover-target resolution ──
        // When a player is behind player-built cover (sandbags, walls, etc.)
        // the exact player position is unreachable and Arma pathfinding stalls
        // the zombie far out.  Cast two short rays at low (0.35m) and torso
        // (0.9m) heights.  If a PLAYER_OBJECT_LIST object blocks either ray,
        // advance toward that object instead.  This keeps every zombie type
        // (runners, shamblers, bloaters) moving up to the barrier, at which
        // point WBK direct-drive or the bloater breach PFH takes over.
        // Cost: 1–2 lineIntersectsSurfaces per zombie per 15s loop — negligible.
        private _playerObjects = if (isNil "PLAYER_OBJECT_LIST") then { [] } else { PLAYER_OBJECT_LIST };
        private _advancePos  = getPos _nearestPlayer;
        private _coverTarget = objNull;

        {
          private _sampleZ = _x;
          private _ins = lineIntersectsSurfaces [
            AGLToASL (_unit modelToWorld [0, 0, _sampleZ]),
            AGLToASL (_nearestPlayer modelToWorld [0, 0, _sampleZ]),
            _unit,
            _nearestPlayer,
            true,
            1,
            "GEOM",
            "NONE"
          ];
          if (count _ins > 0) then {
            private _hitObj = (_ins select 0) select 2;
            if (!isNull _hitObj && { _hitObj in _playerObjects }) exitWith {
              _coverTarget = _hitObj;
            };
          };
        } forEach [0.35, 0.9];

        if (!isNull _coverTarget) then {
          // Player is behind cover — advance toward the exterior of the structure.
          // Compute a point 2m from the cover origin toward the zombie so the
          // doMove target is a navmesh-accessible exterior point rather than the
          // model origin which may sit inside wall geometry.
          private _wPos = getPosATL _coverTarget;
          private _uPos = getPosATL _unit;
          private _cx   = (_uPos select 0) - (_wPos select 0);
          private _cy   = (_uPos select 1) - (_wPos select 1);
          private _cl   = sqrt(_cx * _cx + _cy * _cy) max 0.01;
          _advancePos = [
            (_wPos select 0) + (_cx / _cl) * 2,
            (_wPos select 1) + (_cy / _cl) * 2,
            _wPos select 2
          ];
          _unit setVariable ["WBK_AI_LastKnownLoc", _advancePos];
          _unit doMove _advancePos;
        } else {
          // No cover detected — use normal distance/speed-gated doMove.
          // Only issue doMove beyond PFH coverage range — within range the
          // WBK PFH drives movement via disableAI "MOVE" + setVelocityTransformation.
          if (_nearestDist >= _moveDistLimit) then {
            _unit doMove _advancePos;
          } else {
            // Idle nudge: if the zombie is within PFH range but NOT in
            // direct-drive mode and barely moving, the PFH's findNearestEnemy
            // may be returning objNull (stale knowledge despite reveal).
            // Issue a doMove to get it moving — the PFH will override with
            // direct-drive once it acquires the target. Speed < 0.3 m/s
            // catches stationary and barely-shuffling zombies without
            // interfering with active ones.
            if (isNil {_unit getVariable "WBK_IsUnitLocked"} && {speed _unit < 0.3}) then {
              _unit doMove _advancePos;
            };
          };
        };

      } else {
        // ── VANILLA AI PATH ──
        _unit allowFleeing 0;
        if ((_unit findNearestEnemy _unit) == objNull || suicideWave) then {
          _unit playActionNow "FastF";
          _unit setBehaviour "CARELESS";
          _unit setUnitPos "UP";
          _unit forceSpeed 6;
        } else {
          _unit setBehaviour "AWARE";
        };

        // Move vanilla AI toward nearest player
        _unit doMove (getPos _nearestPlayer);
      };
    };
  } forEach allUnits;

  sleep 15;
};
