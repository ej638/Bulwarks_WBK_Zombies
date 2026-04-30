civClassArr = [];
_spawnedCivs = [];
_currentWave = attkWave;
_distFromBulwark = "BULWARK_RADIUS" call BIS_fnc_getParamValue;

//Create array of all Civ classes
_civSide = 3;
_cfgVehiclesConfig = configFile >> "CfgVehicles";
_cfgVehiclesConfigCount = count _cfgVehiclesConfig;
for [{_i = 0}, {_i < _cfgVehiclesConfigCount}, {_i = _i + 1}] do
{
  _config = _cfgVehiclesConfig select _i;
  if (isClass _config) then
  {
    _typeMan = getNumber (_config >> "isMan");
    if (_typeMan != 0) then
    {
      _side = getNumber (_config >> "side");
      if (_side == _civSide) then
      {
        civClassArr set [count civClassArr, configName _config];
      }
    }
  };
};

for [{_i=0}, {_i<20}, {_i=_i+1}] do {
  //find random location for Civ to spawn
  _civRoom = while {true} do {
    _civBulding = selectRandom lootHouses;
    _civRooms = _civBulding buildingPos -1;
    _civRoom = selectRandom _civRooms;
    if(!isNil "_civRoom") exitWith {_civRoom};
  };

  //spawn Civ
  _civClass = selectRandom civClassArr;
  _civgroup = createGroup [civilian, true];
  _civUnit = _civgroup createUnit [_civClass, _civRoom, [], 0.5, "FORM"];
  mainZeus addCuratorEditableObjects [[_civUnit], true];
  _civUnit addEventHandler ["Killed", killPoints_fnc_civKilled];
  // Prevent civ AI from entering COMBAT mode and triggering bis_fnc_cp_main,
  // a BIS cover-point function that is undefined without an AI module placed.
  // AUTOTARGET stops enemy detection; TARGET disables acquisition; FSM disables
  // the AI state machine that calls it. doMove still works without these.
  _civUnit disableAI "AUTOTARGET";
  _civUnit disableAI "TARGET";
  _civUnit disableAI "FSM";
  _spawnedCivs pushBack _civUnit;
};

while {EAST countSide allUnits > 0} do {
  {
    _civGoToPos = [bulwarkRoomPos, 0, _distFromBulwark - 5,0,0,70,0] call BIS_fnc_findSafePos;
    _x doMove _civGoToPos;
    _x allowFleeing 0;
    _x setBehaviour "CARELESS";
  } forEach _spawnedCivs;
  sleep 20;
};

{
  _nBuilding = nearestBuilding _x;
  _civRooms = _nBuilding buildingPos -1;
  _civRoom = selectRandom _civRooms;
  if(!isNil "_civRoom") then {
    _x doMove _civRoom;
  };
} forEach _spawnedCivs;

waitUntil {_currentWave != attkWave};

{
  deleteVehicle _x;
} forEach _spawnedCivs;
