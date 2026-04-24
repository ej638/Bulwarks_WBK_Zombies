/**
*  fn_startWave
*
*  starts a new Wave
*
*  Domain: Server
**/


[] remoteExec ["killPoints_fnc_updateHud", 0];

for ("_i") from 0 to 14 do {
	if(_i > 10) then {"beep_target" remoteExec ["playsound", 0];} else {"readoutClick" remoteExec ["playsound", 0];};
	[format ["<t>%1</t>", 15-_i], 0, 0, 1, 0] remoteExec ["BIS_fnc_dynamicText", 0];
	sleep 1;
};

// Delete
_final = waveUnits select ("BODY_CLEANUP" call BIS_fnc_getParamValue);
{deleteVehicle _x} foreach _final;
// Shuffle
waveUnits set [2, waveUnits select 1];
waveUnits set [1, waveUnits select 0];
waveUnits set [0, []];

playersInWave = [];
_allHCs = entities "HeadlessClient_F";
_allHPs = allPlayers - _allHCs;
{ playersInWave pushBack getPlayerUID _x; } foreach _allHPs;
publicVariable "playersInWave";

attkWave = (attkWave + 1);
publicVariable "attkWave";

waveSpawned = false;

//If last wave was a night time wave then skip back to the time it was previously
if(!isNil "nightWave") then {
	if (nightWave) then {
		skipTime currentTime;
	};
};

15 setFog 0;

[] remoteExec ["killPoints_fnc_updateHud", 0];

_respawnTickets = [west] call BIS_fnc_respawnTickets;
if (_respawnTickets <= 0) then {
	RESPAWN_TIME = 99999;
	publicVariable "RESPAWN_TIME";
};
[RESPAWN_TIME] remoteExec ["setPlayerRespawnTime", 0];

missionNamespace setVariable ["buildPhase", false, true];

//determine if Special wave

if (attkWave < 10) then {
	randSpecChance = 4;
	maxSinceSpecial = 4;
	maxSpecialLimit = 1;
};

if (attkWave >= 10 && attkWave < 15) then {
	randSpecChance = 3;
	maxSinceSpecial = 3;
	maxSpecialLimit = 1;
};

if (attkWave >= 15) then {
	randSpecChance = 2;
	maxSinceSpecial = 2;
	maxSpecialLimit = 0;
};

if ((floor random randSpecChance == 1 || wavesSinceSpecial >= maxSinceSpecial) && attkWave >= 5 && wavesSinceSpecial >= maxSpecialLimit) then {
	specialWave = true;
}else{
	wavesSinceSpecial = wavesSinceSpecial + 1;
	specialWave = false;
};

SpecialWaveType = "";
droneCount = 0;

if (specialWave && attkWave >= 5 and attkWave < 10) then {
	_randWave = floor random 2;
	switch (_randWave) do
	{
		case 0:
		{
			SpecialWaveType = "specCivs";
		};
		case 1:
		{
			SpecialWaveType = "fogWave";
		};
	};
	wavesSinceSpecial = 0;
};

if (specialWave && attkWave >= 10) then {
	_randWave = floor random 6;
	switch (_randWave) do
	{
		case 0:
		{
			SpecialWaveType = "specCivs";
		};
		case 1:
		{
			SpecialWaveType = "fogWave";
		};
		case 2:
		{
			SpecialWaveType = "bloaterRush";
		};
		case 3:
		{
			SpecialWaveType = "nightWave";
		};
		case 4:
		{
			SpecialWaveType = "demineWave";
		};
		case 5:
		{
			SpecialWaveType = "siegeWave";
		};
	};
	wavesSinceSpecial = 0;
};

// ── Bloater Rush (replaces vanilla suicideWave) ──
// Sets flag for fn_buildWaveManifest to override with scaled Bloaters + T1.
// DUAL TRIGGER: fires from special wave RNG pool OR from guaranteed recurrence
// timer (every 5 waves after wave 10). Timer takes priority if both activate.
private _bloaterRushCooldown = missionNamespace getVariable ["EJ_wavesSinceBloaterRush", 99];
if (attkWave >= 10 AND { _bloaterRushCooldown >= 5 } AND { SpecialWaveType != "bloaterRush" }) then {
	// Force bloater rush via recurrence timer, overriding whatever special was rolled
	SpecialWaveType = "bloaterRush";
	if (!specialWave) then {
		specialWave = true;
		wavesSinceSpecial = 0;
	};
	diag_log format ["[EJ] Forced bloater rush via recurrence timer (waves since last: %1)", _bloaterRushCooldown];
};

if (SpecialWaveType == "bloaterRush") then {
	EJ_wbk_bloaterRush = true;
	execVM "hostiles\suicideAudio.sqf";
} else {
	EJ_wbk_bloaterRush = false;
};

// ── Early Bloater Preview (wave 3 only) ──
// A single bloater appears in wave 3 to introduce the breaching mechanic
// before the formal bloater rush (wave 10+). One preview wave is enough —
// wave 4 reverts to a normal mixed wave. From wave 5+ the normal tier
// system handles bloater spawns (minWave = 5 in registry).
if (attkWave == 3 && !EJ_wbk_bloaterRush) then {
	EJ_wbk_earlyBloaterCount = 1;
} else {
	EJ_wbk_earlyBloaterCount = 0;
};

// ── Bloater Barricade PFH ──
// Initialize bloater tracker and start the contextual targeting PFH.
// The PFH checks alive bloaters for barricade obstructions each second.
// Runs every wave (bloaters may appear in normal waves from T3 pool at wave 5+,
// or from early preview at waves 3-4).
EJ_activeBloaters = [];
call EJ_fnc_bloaterBarricadePFH;

// ── Siege Wave — guaranteed Smasher-heavy assault on fortifications ──
if (SpecialWaveType == "siegeWave") then {
	EJ_wbk_siegeWave = true;
} else {
	EJ_wbk_siegeWave = false;
};

suicideWave = false;

specMortarWave = false;

if (SpecialWaveType == "specCivs") then {
	specCivs = true;
	[] execVM "hostiles\civWave.sqf";
}else{
	specCivs = false;
};

if (SpecialWaveType == "nightWave") then {
	nightWave = true;
	currentTime = daytime;
	skipTime (24 - currentTime);
}else{
	nightWave = false;
};

if (SpecialWaveType == "fogWave") then {
	fogWave = true;
	15 setFog 1;
}else{
	fogWave = false;
};

swticharooWave = false;

if (SpecialWaveType == "demineWave") then {
	demineWave = true;
	droneSquad = [];
	execVM "hostiles\droneFire.sqf";
}else{
	demineWave = false;
};

defectorWave = false;

//Notify start of wave and type of wave
if (EJ_wbk_bloaterRush) then {
	["SpecialWarning",["BLOATER RUSH! Don't Let Them Get Close!"]] remoteExec ["BIS_fnc_showNotification", 0];
	["Alarm"] remoteExec ["playSound", 0];
};

if (specCivs) then {
	["SpecialWarning",["CIVILIANS Are Fleeing! Don't Shoot Them!"]] remoteExec ["BIS_fnc_showNotification", 0];
	["Alarm"] remoteExec ["playSound", 0];
};

if (nightWave) then {
	["SpecialWarning",["They mostly come at night. Mostly..."]] remoteExec ["BIS_fnc_showNotification", 0];
	["Alarm"] remoteExec ["playSound", 0];
};

if (fogWave) then {
	["SpecialWarning",["A dense fog is rolling in!"]] remoteExec ["BIS_fnc_showNotification", 0];
	["Alarm"] remoteExec ["playSound", 0];
};

if (demineWave) then {
	["SpecialWarning",["Look up! They're sending drones!"]] remoteExec ["BIS_fnc_showNotification", 0];
	["Alarm"] remoteExec ["playSound", 0];
};

if (EJ_wbk_siegeWave) then {
	["SpecialWarning",["SIEGE! Heavy units targeting your fortifications!"]] remoteExec ["BIS_fnc_showNotification", 0];
	["Alarm"] remoteExec ["playSound", 0];
};

if (!specialWave) then {
	["TaskAssigned",["In-coming","Wave " + str attkWave]] remoteExec ["BIS_fnc_showNotification", 0];
};

{
	if (!alive _x) then {
		deleteVehicle _x;
	};
} foreach allMissionObjects "LandVehicle";

{
	if (!alive _x) then {
		deleteVehicle _x;
	};
} foreach allMissionObjects "Air";

// Spawn
_createHostiles = execVM "hostiles\createWave.sqf";
waitUntil {scriptDone _createHostiles};

if (attkWave > 1) then { //if first wave give player extra time before spawning enemies
	{deleteMarker _x} foreach lootDebugMarkers;
	[] call loot_fnc_cleanup;
	_spawnLoot = execVM "loot\spawnLoot.sqf";
	waitUntil { scriptDone _spawnLoot};
};
