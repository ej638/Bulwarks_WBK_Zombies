_player = _this select 0;
// Array form with default true: safe if buildPhase is not yet published.
_buildPhase = missionNamespace getVariable ["buildPhase", true];

if (!_buildPhase) then { // free respawn in build phase
	_respawnTickets = [west, -1] call BIS_fnc_respawnTickets;
	if (_respawnTickets <= 0) then {
		RESPAWN_TIME = 99999;
		publicVariable "RESPAWN_TIME";
	};
	// Always rebroadcast — RESPAWN_TIME is authoritative after fn_startWave
	// restores it from the param at wave start (Issue #12 fix).
	[RESPAWN_TIME] remoteExec ["setPlayerRespawnTime", 0];
};


