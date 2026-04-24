/**
 *  fn_bloaterBarricadePFH
 *
 *  Phase 14 (updated) — Bloater Contextual Targeting with Elevated Structure Support
 *  Server-side CBA PerFrameHandler that checks alive bloaters for
 *  player-built structure obstructions on their path to the nearest player.
 *
 *  Breach target resolution (runs once per bloater per second):
 *
 *    1. ELEVATED-SUPPORT CHECK — if the nearest player is > 1.45m above the
 *       bloater (WBK's own direct-drive elevation gate), cast a downward ray from
 *       the player to find the player-built object they are standing on.  That
 *       object becomes the breach target even when there is no direct wall between
 *       bloater and player at eye level.  This covers open guard towers, platforms,
 *       and any elevated build structure where the LOS ray passes through gaps.
 *
 *    2. BLOCKING-WALL CHECK — standard eye-level raycast from bloater to player.
 *       If the first hit is a PLAYER_OBJECT_LIST object it becomes the breach
 *       target.  A directly blocking wall takes priority over the support check.
 *
 *    3. PROXIMITY DETONATION — if the bloater is within EJ_BLOATER_DETONATE_RANGE
 *       (2D, ground-plane distance) of the breach target: mission-level detonation.
 *       2D distance is used so tall structures do not push the range check upward
 *       and require the bloater to reach an inaccessible elevated origin point.
 *
 *    4. STALL DETONATION — per-bloater stall tracking.  If the bloater stays on
 *       the same breach target for ≥ EJ_BLOATER_STALL_TIME seconds while within
 *       EJ_BLOATER_STALL_RANGE (2D) of its base, force detonation.  This fires
 *       when Arma's navmesh cannot route the bloater up stairs or through doorways
 *       but the bloater has clearly reached the structure base.
 *
 *    5. REDIRECT — if none of the above detonate: doMove toward the breach target
 *       base position, suppressing the WBK mod's own _loopPathfindDoMove from
 *       overriding our target for a few seconds.
 *
 *    6. NO TARGET — mod handles player-targeting natively (direct-drive when LOS
 *       is clear and elevation gap is within WBK's ±1.45m gate).
 *
 *  Detonation creates an APERS mine for player splash damage (handled by
 *  engine).  EJ_structHP damage to nearby PLAYER_OBJECT_LIST objects is applied
 *  by the bloater's Killed EH in fn_spawnWBKUnit.sqf, which fires on any cause
 *  of death and is not duplicated here.
 *
 *  Lifecycle:
 *    - Started by fn_startWave via call (stores handle in EJ_bloaterPFHHandle)
 *    - Stopped by fn_endWave via CBA_fnc_removePerFrameHandler
 *
 *  Params:  none (reads globals)
 *  Returns: nothing (side-effects: registers CBA PFH, sets EJ_bloaterPFHHandle)
 *
 *  Domain: Server
 */

if (!isServer) exitWith {};

// Config defaults (set in editMe.sqf, fallback here)
private _detonateRange = if (!isNil "EJ_BLOATER_DETONATE_RANGE") then { EJ_BLOATER_DETONATE_RANGE } else { 5 };
private _stallTime     = if (!isNil "EJ_BLOATER_STALL_TIME")     then { EJ_BLOATER_STALL_TIME }     else { 8 };
private _stallRange    = if (!isNil "EJ_BLOATER_STALL_RANGE")    then { EJ_BLOATER_STALL_RANGE }    else { 10 };

EJ_bloaterPFHHandle = [{
    params ["_args"];
    _args params ["_detonateRange", "_stallTime", "_stallRange"];

    // Cache alive players once per tick
    private _allHCs = entities "HeadlessClient_F";
    private _players = (allPlayers - _allHCs) select { alive _x && lifeState _x != "INCAPACITATED" };
    if (count _players == 0) exitWith {};

    // Iterate tracked bloaters
    private _toRemove = [];
    {
        private _bloater = _x;

        // Cleanup dead/null entries lazily
        if (isNull _bloater || !alive _bloater) then {
            _toRemove pushBack _forEachIndex;
        } else {
            // Find nearest player to this bloater
            private _nearestPlayer = objNull;
            private _nearestDist = 1e6;
            {
                private _d = _bloater distance _x;
                if (_d < _nearestDist) then {
                    _nearestDist = _d;
                    _nearestPlayer = _x;
                };
            } forEach _players;

            if (!isNull _nearestPlayer) then {

                // ── STEP 1: Elevated-support target resolution ──
                // Fires only when player is above WBK's direct-drive elevation gate
                // (±1.45m).  At that height WBK's own _loopPathfind exits the direct-
                // drive case, so the bloater's native proximity explosion can never
                // trigger.  Detect the player-built surface they are standing on so
                // the mission fallback can redirect/detonate at the structure base.
                //
                // Cost: 1 extra lineIntersectsSurfaces call per bloater per second,
                // only when elevation delta > 1.45m.  Negligible vs WBK's 0.1s PFHs.
                private _supportTarget = objNull;
                private _elevDelta = (getPosATL _nearestPlayer select 2) - (getPosATL _bloater select 2);
                if (_elevDelta > 1.45) then {
                    private _pASL = AGLToASL (getPosATL _nearestPlayer vectorAdd [0, 0, 0.05]);
                    private _downRay = lineIntersectsSurfaces [
                        _pASL,
                        _pASL vectorAdd [0, 0, -4],
                        _nearestPlayer, objNull,
                        true, 1, "GEOM", "NONE"
                    ];
                    if (count _downRay > 0) then {
                        private _surfObj = (_downRay select 0) select 2;
                        if (!isNull _surfObj && { _surfObj in PLAYER_OBJECT_LIST }) then {
                            _supportTarget = _surfObj;
                        };
                    };
                };

                // ── STEP 2: Standard blocking-wall LOS ray ──
                // Bloater eye-level → player eye-level.  Captures cases where a wall,
                // pillar, or floor panel sits between bloater and player at eye height.
                private _blockingTarget = objNull;
                private _ins = lineIntersectsSurfaces [
                    AGLToASL (_bloater modelToWorld [0, 0, 0.7]),
                    AGLToASL (_nearestPlayer modelToWorld [0, 0, 0.7]),
                    _bloater, _nearestPlayer,
                    true, 1, "GEOM", "NONE"
                ];
                if (count _ins > 0) then {
                    private _hitObj = (_ins select 0) select 2;
                    if (!isNull _hitObj && { _hitObj in PLAYER_OBJECT_LIST }) then {
                        _blockingTarget = _hitObj;
                    };
                };

                // Prefer a directly blocking wall; fall back to elevated support.
                // A wall hit is more definitive — the bloater literally cannot see
                // the player and must breach the structure to reach them.
                private _breachTarget = if (!isNull _blockingTarget) then { _blockingTarget } else { _supportTarget };

                // ── STEP 2b: Proximity fallback ──
                // Both ray checks return null when the bloater approaches a wall from
                // an oblique angle (ray clears the hull), or when it has already walked
                // alongside the wall and the ray no longer intersects it.  Scan
                // PLAYER_OBJECT_LIST directly with a 2D distance check as a safety net.
                // Only runs when breach target is not yet set AND the bloater is already
                // within detonation range, so cost is zero during the normal approach.
                if (isNull _breachTarget) then {
                    {
                        if (!isNull _x && { _bloater distance2D _x <= _detonateRange }) exitWith {
                            _breachTarget = _x;
                        };
                    } forEach PLAYER_OBJECT_LIST;
                };

                if (!isNull _breachTarget) then {

                    // ── STEP 3: Geometry-aware proximity (2D) ──
                    // Use flat ground-plane distance so tall structures (guard towers,
                    // platforms) do not require the bloater to reach an elevated origin
                    // point to satisfy the detonation range check.
                    private _dist2D = _bloater distance2D _breachTarget;

                    // ── STEP 4: Stall tracking ──
                    // If the bloater has been locked onto this structure for too long
                    // without getting within detonation range (e.g. blocked by stairs
                    // it cannot climb), force a detonation at the base.
                    // Per-bloater variables survive PFH ticks via setVariable.
                    private _prevTarget = _bloater getVariable ["EJ_bloaterBreachTarget", objNull];
                    private _stuckStart = _bloater getVariable ["EJ_bloaterBreachTime",   -1e9];

                    if (!(_prevTarget isEqualTo _breachTarget)) then {
                        // New or changed breach target — start the stall clock fresh
                        _bloater setVariable ["EJ_bloaterBreachTarget", _breachTarget];
                        _bloater setVariable ["EJ_bloaterBreachTime",   time];
                        _stuckStart = time;
                    };

                    private _stalled = ((time - _stuckStart) >= _stallTime) && (_dist2D <= _stallRange);

                    if (_dist2D <= _detonateRange || _stalled) then {
                        // ── DETONATE ──
                        // APERS mine provides visual/audio explosion + player splash.
                        // EJ_structHP damage is applied by the Killed EH in
                        // fn_spawnWBKUnit.sqf which fires on any cause of death.
                        if (_stalled) then {
                            diag_log format ["[EJ] Bloater stall detonation: %1 stuck on %2 (%3m 2D) for %4s",
                                typeOf _bloater, typeOf _breachTarget, round _dist2D, round (time - _stuckStart)];
                        };
                        private _detonatePos = getPosATL _bloater;
                        private _mine = createMine ["APERSMine", _detonatePos, [], 0];
                        _mine setDamage 1;
                        _bloater setDamage 1;
                        _toRemove pushBack _forEachIndex;
                    } else {
                        // ── REDIRECT toward structure exterior ──
                        // Compute an approach point 2m from the breach target origin
                        // in the direction of the bloater.  This gives a navmesh-
                        // accessible point just outside the wall face rather than the
                        // model origin which may be at the centre of wall geometry.
                        // Setting WBK_AI_LastKnownLoc suppresses the mod's own
                        // _loopPathfindDoMove from overwriting for 4–7s.
                        private _wallPos  = getPosATL _breachTarget;
                        private _bloatPos = getPosATL _bloater;
                        private _dx   = (_bloatPos select 0) - (_wallPos select 0);
                        private _dy   = (_bloatPos select 1) - (_wallPos select 1);
                        private _dlen = sqrt(_dx * _dx + _dy * _dy) max 0.01;
                        private _approachPos = [
                            (_wallPos select 0) + (_dx / _dlen) * 2,
                            (_wallPos select 1) + (_dy / _dlen) * 2,
                            _wallPos select 2
                        ];
                        _bloater doMove _approachPos;
                        _bloater setVariable ["WBK_AI_LastKnownLoc", _approachPos];
                    };

                } else {
                    // No breach target — clear stall tracking so it does not linger
                    // if the bloater later re-approaches the same structure from a
                    // different angle where the target is legitimately reachable.
                    _bloater setVariable ["EJ_bloaterBreachTarget", objNull];
                };

            };  // end if (!isNull _nearestPlayer)
        };
    } forEach EJ_activeBloaters;

    // Remove dead/detonated entries (reverse order to preserve indices)
    reverse _toRemove;
    { EJ_activeBloaters deleteAt _x; } forEach _toRemove;

}, 1.0, [_detonateRange, _stallTime, _stallRange]] call CBA_fnc_addPerFrameHandler;

diag_log format ["[EJ] Bloater barricade PFH started (handle: %1)", EJ_bloaterPFHHandle];
