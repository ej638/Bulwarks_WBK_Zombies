/**
 *  fn_spawnWBKWave
 *
 *  Phase 2 — Weight-Class Budget System
 *  Main entry point that replaces the infantry section of createWave.sqf.
 *  Builds a wave manifest via the budget system, sorts it T1-first / bosses-last,
 *  then spawns units in throttled batches inside a spawn block.
 *
 *  Sets EJ_wbkSpawnComplete = true when all immediate spawning finishes.
 *  The caller in createWave.sqf gates on this via waitUntil.
 *
 *  Overflow units (beyond EJ_MAX_ACTIVE_ZOMBIES) are queued for drip-feed
 *  via a CBA PerFrameHandler that trickles them in as existing zombies die.
 *
 *  Params:
 *    _waveNum        — current wave number (attkWave)
 *    _playerCount    — number of live WEST players
 *    _multiplierBase — (accepted for call-site compat, unused by budget system)
 *
 *  Domain: Server
 */

if (!isServer) exitWith {};

params ["_waveNum", "_playerCount", ["_multiplierBase", 1]];

// ── Signal: spawning in progress ──
EJ_wbkSpawnComplete = false;

// ── Clear any stale overflow from the previous wave ──
// EJ_spawnQueue accumulates overflow across waves; reset here to ensure
// drip-feed entries from a prior wave don't bleed into the new one.
// If the previous drip-feed PFH is still running, it will hit an empty
// queue on its next tick, self-remove, and set EJ_dripFeedHandler = -1.
EJ_spawnQueue = [];

// ── Build the manifest via top-down budget allocation ──
private _manifest = [_waveNum, _playerCount] call EJ_fnc_buildWaveManifest;

// ══════════════════════════════════════════════════════════
//  SORT: Horde first, Bosses last — Spec §5.4
//  Ensures cheap PFH registrations land before expensive ones,
//  giving the server time to absorb load before Smasher/Goliath init.
//  Sorted by pointMulti ascending (T1=0.50-1.00, T3=2.00, T4=4.00, T5=8.00)
// ══════════════════════════════════════════════════════════

private _sorted = [];
{ if ((_x select 1) <= 0.50) then { _sorted pushBack _x } } forEach _manifest;  // T1 shamblers
{ if ((_x select 1) > 0.50 AND (_x select 1) <= 1.00) then { _sorted pushBack _x } } forEach _manifest;  // T1 runners/shooters
{ if ((_x select 1) > 1.00 AND (_x select 1) <= 2.00) then { _sorted pushBack _x } } forEach _manifest;  // T3
{ if ((_x select 1) > 2.00 AND (_x select 1) <= 4.00) then { _sorted pushBack _x } } forEach _manifest;  // T4
{ if ((_x select 1) > 4.00) then { _sorted pushBack _x } } forEach _manifest;  // T5

// ════════════════════════════════════════════════════════
//  SHARED GROUP — All wave zombies in one EAST group.
//  Prevents findNearestEnemy from returning groupmates (fixes
//  zombie-on-zombie attacks) and enables group knowledge sharing.
// ════════════════════════════════════════════════════════

private _waveGroup = createGroup [EAST, true];
EJ_currentWaveGroup = _waveGroup;

// ══════════════════════════════════════════════════════════
//  SPAWN LOOP — wrapped in `spawn` for scheduled sleep
//  Spec §4.2: batches of EJ_SPAWN_BATCH_SIZE with EJ_SPAWN_BATCH_DELAY
// ══════════════════════════════════════════════════════════

[_sorted, _waveNum, _waveGroup] spawn {
    params ["_sorted", "_waveNum", "_waveGroup"];

    private _spawnedCount = 0;
    private _batchCount   = 0;
    private _overflow      = [];

    {
        _x params ["_class", "_pointMulti"];

        // ── Active cap check — Spec §4.3 ──
        if (EAST countSide allUnits >= EJ_MAX_ACTIVE_ZOMBIES) then {
            _overflow pushBack _x;
        } else {
            // ── Resolve spawn position — outside bulwark perimeter ──
            // waterMode=0 (land only) prevents water-edge spawns that produce
            // zombies running parallel to the zone along the shoreline.
            // Ring: +30 to +55 from BULWARK_RADIUS — pushed out from old +15/+40
            // so spawns clear the zone perimeter with more margin.
            private _pos = [bulwarkCity,
                BULWARK_RADIUS + 30,
                BULWARK_RADIUS + 55,
                0, 0
            ] call BIS_fnc_findSafePos;
            // Validate: BIS_fnc_findSafePos returns [0,0,0] or the input
            // center on failure. Fall back to a computed perimeter position.
            if (_pos isEqualTo [0,0,0] || { (_pos distance2D bulwarkCity) < BULWARK_RADIUS }) then {
                _pos = bulwarkCity getPos [BULWARK_RADIUS + 30, random 360];
            };

            // ── Spawn via Phase 1 Core Adapter (shared group) ──
            [_pos, _class, _pointMulti, _waveGroup] call EJ_fnc_spawnWBKUnit;

            _spawnedCount = _spawnedCount + 1;
            _batchCount   = _batchCount + 1;

            // ── Throttle between batches ──
            if (_batchCount >= EJ_SPAWN_BATCH_SIZE) then {
                _batchCount = 0;

                // Boss units (T4/T5) get extra settling time — Spec §4.4
                if (_pointMulti >= 4.00) then {
                    sleep EJ_SPAWN_BOSS_DELAY;
                } else {
                    sleep EJ_SPAWN_BATCH_DELAY;
                };
            };
        };

    } forEach _sorted;

    // ══════════════════════════════════════════════════════
    //  OVERFLOW → DRIP-FEED QUEUE — Spec §4.3
    // ══════════════════════════════════════════════════════

    EJ_spawnQueue = EJ_spawnQueue + _overflow;

    if (count _overflow > 0) then {
        diag_log format ["[EJ] %1 units queued for drip-feed (active cap %2 reached).",
            count _overflow, EJ_MAX_ACTIVE_ZOMBIES];
    };

    // Start drip-feed PFH if queue is non-empty and handler isn't already running
    if (count EJ_spawnQueue > 0 AND { EJ_dripFeedHandler < 0 }) then {
        EJ_dripFeedHandler = [{
            // Queue drained → remove this handler
            if (count EJ_spawnQueue == 0) exitWith {
                [EJ_dripFeedHandler] call CBA_fnc_removePerFrameHandler;
                EJ_dripFeedHandler = -1;
                diag_log "[EJ] Drip-feed queue empty. Handler removed.";
            };

            // Still at cap → wait
            if (EAST countSide allUnits >= EJ_MAX_ACTIVE_ZOMBIES) exitWith {};

            // Spawn a batch from the queue
            private _batchSize = EJ_SPAWN_BATCH_SIZE min count EJ_spawnQueue;
            for "_i" from 1 to _batchSize do {
                if (count EJ_spawnQueue == 0) exitWith {};
                private _entry = EJ_spawnQueue deleteAt 0;
                _entry params ["_class", "_pointMulti"];

                private _pos = [bulwarkCity,
                    BULWARK_RADIUS + 30,
                    BULWARK_RADIUS + 55,
                    0, 0
                ] call BIS_fnc_findSafePos;
                if (_pos isEqualTo [0,0,0] || { (_pos distance2D bulwarkCity) < BULWARK_RADIUS }) then {
                    _pos = bulwarkCity getPos [BULWARK_RADIUS + 30, random 360];
                };

                // Use current wave group if still alive, else create new one
                private _grp = if (!isNull EJ_currentWaveGroup) then {
                    EJ_currentWaveGroup
                } else {
                    private _newGrp = createGroup [EAST, true];
                    EJ_currentWaveGroup = _newGrp;
                    _newGrp
                };

                [_pos, _class, _pointMulti, _grp] call EJ_fnc_spawnWBKUnit;
            };
        }, EJ_SPAWN_BATCH_DELAY] call CBA_fnc_addPerFrameHandler;
    };

    // ── Signal completion ──
    EJ_wbkSpawnComplete = true;

    diag_log format [
        "[EJ] Wave %1 spawn complete. %2 immediate, %3 queued for drip-feed.",
        _waveNum, _spawnedCount, count _overflow
    ];
};
