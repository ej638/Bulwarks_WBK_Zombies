/**
*  fn_paraTroop
*
*  Calls VTOL to drop a group of paratroopers on the specified location
*
*  Domain: Server
**/
params ["_player", "_targetPos", "_unitCount", "_aircraft", "_classList"];

if (count _targetPos == 0) then {
  [_player, "paraDrop"] remoteExec ["BIS_fnc_addCommMenuItem", _player]; //refund the support if looking at sky when activated
}else{
  _angle = round random 180;
  _height = 300;
  _offsX = 0;
  _offsY = 1000;
  _pointX = _offsX*(cos _angle) - _offsY*(sin _angle);
  _pointY = _offsX*(sin _angle) + _offsY*(cos _angle);

  _dropStart  = _targetPos vectorAdd [_pointX, _pointY, _height];
  _dropTarget = [(_targetPos select 0), (_targetPos select 1), 200];
  _dropEnd    = _targetPos vectorAdd [-_pointX*2, -_pointY*2, _height];;

  _targetSmoker = "SmokeShellOrange" createVehicle (_targetPos vectorAdd [0,0,0.3]);

  _agSpawn = [_dropStart, 0, _aircraft, WEST] call bis_fnc_spawnvehicle;
  _agVehicle = _agSpawn select 0;	//the aircraft
  _agCrew = _agSpawn select 1;	//the units that make up the crew
  _ag = _agSpawn select 2;	//the group
  {_x allowFleeing 0} forEach units _ag;

  _agVehicle flyInHeight 100;
  _agVehicle setpos [getposATL _agVehicle select 0, getposATL _agVehicle select 1, _height];

  _relDir = [_dropStart, _targetPos] call BIS_fnc_dirTo;
  _agVehicle setdir _relDir;

  paraTroopLatch = false;

  _waypoint0 = _ag addwaypoint[_dropTarget, 0];
  _waypoint0 setwaypointtype "Move";
  _waypoint0 setWaypointCompletionRadius 5;
  _waypoint0 setWaypointStatements ["true", "paraTroopLatch = true;"];

  _waypoint1 = _ag addwaypoint[_dropEnd, 0];
  _waypoint1 setwaypointtype "Move";

  [_ag, 1] setWaypointSpeed "FULL";
  [_ag, 1] setWaypointCombatMode "RED";
  [_ag, 1] setWaypointBehaviour "CARELESS";

  _agVehicle animateDoor ['Door_1_source', 1];
  waitUntil {paraTroopLatch};

  sleep 0.5;

  coreGroup = group _player;
  [group _player, _player] remoteExec ["selectLeader", groupOwner group _player];

  for ("_i") from 1 to PARATROOP_COUNT do {
      _location = getPos _agVehicle;
      _unitClass = selectRandom _classList;
      _unit = objNull;
      _unit = coreGroup createUnit [_unitClass, _location vectorAdd [0,0,-2], [], 0.5, "CAN_COLLIDE"];
      mainZeus addCuratorEditableObjects [[_unit], true];
      sleep 0.3;
      waitUntil {!isNull _unit};

      // Strip default class gear before applying whitelisted loadout
      removeAllWeapons _unit;
      removeAllItems _unit;
      removeAllAssignedItems _unit;
      removeUniform _unit;
      removeVest _unit;
      removeHeadgear _unit;
      removeGoggles _unit;

      // Select random whitelisted loadout
      _selUniform   = selectRandom PARA_UNIFORMS;
      _selVest      = selectRandom PARA_VESTS;
      _selPrimary   = selectRandom PARA_PRIMARIES;
      _selSecondary = selectRandom PARA_SECONDARIES;
      _selHat       = selectRandom PARA_HATS;
      _selGlasses   = selectRandom PARA_GLASSES;
      _magPrimary   = selectRandom (compatibleMagazines _selPrimary);
      _magSecondary = selectRandom (compatibleMagazines _selSecondary);

      // Apply outfit, armour, weapons, and 1 starter mag each
      // Mags added before backpack so they fill uniform/vest — no overflow into parachute
      _unit forceAddUniform _selUniform;
      _unit addVest _selVest;
      _unit addHeadgear _selHat;
      _unit addGoggles _selGlasses;
      _unit addWeapon _selPrimary;
      _unit addMagazines [_magPrimary, 1];
      _unit addWeapon _selSecondary;
      _unit addMagazines [_magSecondary, 1];
      _unit addBackpack "B_Parachute";

      // Tag calling player for kill-score attribution (read by fn_killed.sqf)
      _unit setVariable ["EJ_paraOwner", _player, true];

      _unit setSkill ["aimingAccuracy", 0.8];
      _unit setSkill ["aimingSpeed", 0.7];
      _unit setSkill ["aimingShake", 0.8];
      _unit setSkill ["spotTime", 1];
      _unit doMove _targetPos;

      // On landing: swap parachute for whitelisted backpack and top up ammo
      // Polls altitude every 2s — cheap, 3 units max, one-shot thread
      [_unit, _magPrimary, _magSecondary] spawn {
          params ["_u", "_magP", "_magS"];
          private _landed = false;
          while {alive _u && !_landed} do {
              sleep 2;
              if ((getPosATL _u select 2) < 1.5) then { _landed = true; };
          };
          if (alive _u) then {
              removeBackpack _u;
              _u addBackpack (selectRandom PARA_BACKPACKS);
              _u addMagazines [_magP, 7];  // +7 = 8 total primary
              _u addMagazines [_magS, 2];  // +2 = 3 total secondary
          };
      };

      _unit addEventHandler ["Killed", {
          _self = _this select 0;
          removeVest _self;
          removeBackpack _self;
          removeAllWeapons _self;
          removeAllAssignedItems _self;
      }];
  };

  sleep 20;
  deleteVehicle _agVehicle;
  {deleteVehicle _x} foreach _agCrew;
};
