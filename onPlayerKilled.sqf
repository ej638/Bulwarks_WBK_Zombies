_player = _this select 0;
_buildPhase = missionNamespace getVariable "buildPhase";

if (!_buildPhase) then { // free respawn in build phase
	_respawnTickets = [west, -1] call BIS_fnc_respawnTickets;
	if (_respawnTickets <= 0) then {
		RESPAWN_TIME = 99999;
		publicVariable "RESPAWN_TIME";
		[RESPAWN_TIME] remoteExec ["setPlayerRespawnTime", 0];
	} else {
    [RESPAWN_TIME] remoteExec ["setPlayerRespawnTime", 0];
  }
};


