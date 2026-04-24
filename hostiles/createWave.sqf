/**
*  createWave
*
*  Creates all the WBK zombie hostiles for the given round.
*  Vehicle/armour spawning removed — this is a zombies-only mission.
*
*  Domain: Server
**/

_noOfPlayers = 1 max floor ((playersNumber west) * HOSTILE_TEAM_MULTIPLIER);
_multiplierBase = HOSTILE_MULTIPLIER;
_SoldierMulti = attkWave / 5;

if (attkWave <= 2) then {
	_multiplierBase = 1
};

// ── WBK ZOMBIE SPAWNING (replaces vanilla infantry for-loops) ──
// Budget system handles all tier selection, caps, and throttling.
// See: hostiles/wbk/fn_spawnWBKWave.sqf (Spec §5.4)
EJ_wbkSpawnComplete = false;
[attkWave, _noOfPlayers, _multiplierBase] call EJ_fnc_spawnWBKWave;
waitUntil { EJ_wbkSpawnComplete };

waveSpawned = true;
