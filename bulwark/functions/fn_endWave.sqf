/**
*  fn_endWave
*
*  Wave ended (mission complete)
*
*  Domain: Server
**/

// variable to prevent players rejoining during a wave
playersInWave = [];
publicVariable "playersInWave";

missionNamespace setVariable ["buildPhase", true, true];

["TaskSucceeded",["Complete","Wave " + str attkWave + " complete!"]] remoteExec ["BIS_fnc_showNotification", 0];
RESPAWN_TIME = 0;
publicVariable "RESPAWN_TIME";
[RESPAWN_TIME] remoteExec ["setPlayerRespawnTime", 0];

// ── Stop Bloater Barricade PFH ──
// Clean up the contextual targeting handler — no point running between waves.
if (!isNil "EJ_bloaterPFHHandle" && {EJ_bloaterPFHHandle >= 0}) then {
	[EJ_bloaterPFHHandle] call CBA_fnc_removePerFrameHandler;
	EJ_bloaterPFHHandle = -1;
};
EJ_activeBloaters = [];

// ── Stop Drip-Feed PFH + clear spawn queue ──
// The overflow queue must be drained here, not left running into the build phase.
// If any queue entries remain when the wave ends, the PFH would spawn them into
// downtime — those ghost zombies bleed into the next wave's EAST count and delay
// (or entirely prevent) Wave N+1's end-notification from firing on time.
if (!isNil "EJ_dripFeedHandler" && {EJ_dripFeedHandler >= 0}) then {
	[EJ_dripFeedHandler] call CBA_fnc_removePerFrameHandler;
	EJ_dripFeedHandler = -1;
};
EJ_spawnQueue = [];

// ── Barricade survival bonus ──
// Award points for barricades that took damage but survived the wave.
// The worse the damage, the higher the bonus (defending under pressure).
private _survivalBonus = if (!isNil "EJ_BARRICADE_SURVIVAL_BONUS") then { EJ_BARRICADE_SURVIVAL_BONUS } else { 50 };
if (_survivalBonus > 0) then {
  private _allHCs = entities "HeadlessClient_F";
  private _allHPs = allPlayers - _allHCs;
  private _totalBonus = 0;
  {
    private _hp = _x getVariable ["EJ_structHP", 1];
    // Only award for structures that took damage (HP < 1) but survived
    if (_hp < 1 && _hp > 0) then {
      private _damageTaken = 1 - _hp;
      _totalBonus = _totalBonus + (round (_survivalBonus * _damageTaken));
      // Reset HP back to full for next wave
      _x setVariable ["EJ_structHP", 1, true];
    };
  } forEach PLAYER_OBJECT_LIST;
  if (_totalBonus > 0) then {
    // Split bonus equally among all alive players
    private _perPlayer = round (_totalBonus / (count _allHPs max 1));
    {
      if (alive _x) then {
        [_x, _perPlayer] call killPoints_fnc_add;
      };
    } forEach _allHPs;
    [format ["<t color='#66ff66'>+%1 Fortification Bonus</t>", _perPlayer], 0, 0.15, 3, 0.5] remoteExec ["BIS_fnc_dynamicText", 0];
  };
};

{
	// Revive players that died at the end of the round.
	if (lifeState _x == "DEAD") then {
		forceRespawn _x;
	};
} foreach allPlayers;

{
	// Revive players that are INCAPACITATED.
	if (lifeState _x == "INCAPACITATED") then {
		["#rev", 1, _x] remoteExecCall ["BIS_fnc_reviveOnState",_x];
	};
} foreach allPlayers;

//Kill all mind controlled AI
{
	 _x setDamage 1;
}foreach MIND_CONTROLLED_AI;
MIND_CONTROLLED_AI = [];
publicVariable "MIND_CONTROLLED_AI";

sleep _downTime;
