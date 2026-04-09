/**
 *  MVP Test Script — Core Adapter Phase 1
 *
 *  Paste this into the Arma 3 Debug Console (server/host) and Execute.
 *  It spawns ONE WBK Angry Runner 20m in front of the player and
 *  verifies that the scoring bridge is active.
 *
 *  Expected results:
 *    1. A zombie appears 20m ahead, begins chasing immediately.
 *    2. Shooting it produces hit-marker score popups on your HUD.
 *    3. Killing it awards the full kill score (SCORE_KILL × pointMulti).
 *    4. systemChat messages confirm each integration hook is wired.
 *
 *  Prerequisites:
 *    - WBK_Zombies mod loaded
 *    - Mission running with Bulwarks scoring globals (SCORE_HIT, etc.)
 */

// --- Spawn position: 20m in front of the player ---
private _dir   = getDir player;
private _pos   = player getPos [20, _dir];

// --- Spawn the unit via the Core Adapter ---
private _unit = [_pos, "Zombie_O_RunnerAngry_CSAT", 1] call EJ_fnc_spawnWBKUnit;

if (isNull _unit) exitWith {
    systemChat "[EJ TEST] FAILED: Unit is null. Check classname and mod loading.";
};

systemChat format ["[EJ TEST] Spawned %1 at %2", typeOf _unit, _pos];

// --- Verify: deferred check that WBK auto-init fired ---
[_unit] spawn {
    params ["_u"];
    private _timeout = diag_tickTime + 6;
    waitUntil {
        !isNil { _u getVariable "WBK_AI_ISZombie" }
        OR { diag_tickTime > _timeout }
    };

    if (!isNil { _u getVariable "WBK_AI_ISZombie" }) then {
        systemChat format [
            "[EJ TEST] OK — WBK auto-init confirmed. SynthHP: %1 | MoveSet: %2",
            _u getVariable ["WBK_SynthHP", "NOT SET"],
            _u getVariable ["WBK_AI_ZombieMoveSet", "NOT SET"]
        ];
    } else {
        systemChat "[EJ TEST] WARNING: WBK_AI_ISZombie not set after 6s. Check Extended_InitPost.";
    };

    // Verify scoring variables
    private _km = _u getVariable ["killPointMulti", -1];
    private _pts = _u getVariable ["points", nil];
    if (_km == 1 && !isNil "_pts") then {
        systemChat "[EJ TEST] OK — Bulwarks scoring hooks attached (killPointMulti=1, points=[]).";
    } else {
        systemChat format ["[EJ TEST] WARNING: Scoring vars unexpected. killPointMulti=%1", _km];
    };

    systemChat "[EJ TEST] Shoot the zombie to verify hit-marker score popups.";
};
