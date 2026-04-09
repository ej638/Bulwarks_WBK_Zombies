_unitWithSword = _this;
if ((isPlayer _unitWithSword) or !(isNil {_unitWithSword getVariable "WBK_AI_ISZombie"}) or !(alive _unitWithSword)) exitWith {};
removeAllWeapons _unitWithSword;
_unitWithSword setUnitPos "UP";
_unitWithSword setVariable ["WBK_AI_ISZombie",true,true];
[_unitWithSword, "Star_Wars_KaaTirs_idle"] remoteExec ["switchMove", 0];
_unitWithSword setVariable ["WBK_AI_ZombieMoveSet","Star_Wars_KaaTirs_idle", true];
_unitWithSword setVariable ["WBK_SynthHP",WBK_Zombies_LeaperHP,true];
_unitWithSword setSpeaker "NoVoice";
_unitWithSword disableConversation true;
_unitWithSword setCombatMode "BLUE";
_unitWithSword enableAttack false;
if (typeOf _unitWithSword in ["Zombie_Special_OPFOR_Leaper_1","Zombie_Special_BLUFOR_Leaper_1","Zombie_Special_GREENFOR_Leaper_1"]) then {
	_unitWithSword setUnitLoadout [[],[],[],["WBK_SpecialInfected_Leaper_1",[]],[],[],"","",[],["","","","","",""]];
}else{
	_unitWithSword setUnitLoadout [[],[],[],["WBK_SpecialInfected_Leaper_2",[]],[],[],"","",[],["","","","","",""]];
};
if !(isNil "WBK_IsPresent_Necroplague") then {
	_unitWithSword setVariable ['isMutant',true];
};
if !(isNil "WBK_IsPresent_PIR") then {
	_unitWithSword setVariable ["dam_ignore_hit0",true,true];
	_unitWithSword setVariable ["dam_ignore_effect0",true,true];
};
_unitWithSword spawn {
	uisleep 0.5;
	_this doMove (getPosATLVisual _this);
};

_unitWithSword addEventHandler ["Deleted", {
	params ["_zombie"];
	{
		_ifDelete = [_x] call CBA_fnc_removePerFrameHandler;
	} forEach (_zombie getVariable "WBK_AI_AttachedHandlers");
}];


_unitWithSword addEventHandler ["Killed", {
	{
		_ifDelete = [_x] call CBA_fnc_removePerFrameHandler;
	} forEach ((_this select 0) getVariable "WBK_AI_AttachedHandlers");
	_this spawn {
		_zombie = _this select 0;
        [_zombie, selectRandom ["WBK_Leaper_Death_1","WBK_Leaper_Death_2"]] remoteExec ["switchMove", 0]; 
		_zombie spawn {
			uiSleep (0.3 + random 0.1);
			if (isNull _this) exitWith {};
			[_this, selectRandom ["zombie_fall_1","zombie_fall_2","zombie_fall_3"], 50, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		};
		_killer = _this select 1;
		if (!(isNil {_zombie getVariable "WBK_Zombie_CustomSounds"})) then {
			[_zombie, selectRandom ((_zombie getVariable "WBK_Zombie_CustomSounds") select 3), 80, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		}else{
			[_zombie, selectRandom ["leaper_death_1","leaper_death_2"], 80, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		};
	};
}];


_unitWithSword addEventHandler ["Suppressed", {
params ["_unit", "_distance", "_shooter", "_instigator", "_ammoObject", "_ammoClassName", "_ammoConfig"];
if (!(alive _unit)) exitWith {};
_unit reveal [_instigator, 4];
}];
_unitWithSword addEventHandler ["FiredNear", {
params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
if (!(alive _unit)) exitWith {};
_unit reveal [_firer, 4];
}];

_unitWithSword addEventHandler ["AnimStateChanged", { 
	_this spawn {
		 params ["_unit", "_anim"]; 
		 switch _anim do {
				case "star_wars_kaatirs_attack_1": {
					[_unit, selectRandom ["axe_punch_empty_1","axe_punch_empty_2","axe_punch_empty_3"], 30, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  
					uiSleep 0.4;
					if (animationState _unit != "star_wars_kaatirs_attack_1") exitWith {};
					[_unit,1,3,true] call WBK_ZombieAttackDamage;
					[_unit, selectRandom ["axe_punch_empty_1","axe_punch_empty_2","axe_punch_empty_3"], 50, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  
					uiSleep 0.7;
					if (animationState _unit != "star_wars_kaatirs_attack_1") exitWith {};
					[_unit, "Star_Wars_KaaTirs_idle"] remoteExec ["switchMove", 0];
				};
				case "star_wars_kaatirs_attack_2": {
					uiSleep 0.5;
					if (animationState _unit != "star_wars_kaatirs_attack_2") exitWith {};
					[_unit, selectRandom ["axe_punch_empty_1","axe_punch_empty_2","axe_punch_empty_3"], 50, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  
					[_unit,0.25,3,true] call WBK_ZombieAttackDamage;
					uiSleep 0.5;
					if (animationState _unit != "star_wars_kaatirs_attack_2") exitWith {};
					_unit setVariable ["LeaperCanAttack",nil];
					uiSleep 0.4;
					if (animationState _unit != "star_wars_kaatirs_attack_2") exitWith {};
					[_unit, "Star_Wars_KaaTirs_idle"] remoteExec ["switchMove", 0];
				};
				case "star_wars_kaatirs_attack_3": {
					uiSleep 0.3;
					if (animationState _unit != "star_wars_kaatirs_attack_3") exitWith {};
					[_unit, selectRandom ["axe_punch_empty_1","axe_punch_empty_2","axe_punch_empty_3"], 50, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  
					[_unit,0.25,3,true] call WBK_ZombieAttackDamage;
					uiSleep 0.4;
					if (animationState _unit != "star_wars_kaatirs_attack_3") exitWith {};
					_unit setVariable ["LeaperCanAttack",nil];
					uiSleep 0.8;
					if (animationState _unit != "star_wars_kaatirs_attack_3") exitWith {};
					[_unit, "Star_Wars_KaaTirs_idle"] remoteExec ["switchMove", 0];
				};
				case "star_wars_kaatirs_attack_4": {
					uiSleep 0.5;
					if (animationState _unit != "star_wars_kaatirs_attack_4") exitWith {};
					[_unit, selectRandom ["axe_punch_empty_1","axe_punch_empty_2","axe_punch_empty_3"], 50, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  
					[_unit,0.5,3,true] call WBK_ZombieAttackDamage;
					uiSleep 0.8;
					if (animationState _unit != "star_wars_kaatirs_attack_4") exitWith {};
					_unit setVariable ["LeaperCanAttack",nil];
					uiSleep 0.4;
					if (animationState _unit != "star_wars_kaatirs_attack_4") exitWith {};
					[_unit, "Star_Wars_KaaTirs_idle"] remoteExec ["switchMove", 0];
				};
				case "star_wars_kaatirs_dodge": {
					uiSleep 1;
					if (animationState _unit != "star_wars_kaatirs_dodge") exitWith {};
					[_unit, "Star_Wars_KaaTirs_idle"] remoteExec ["switchMove", 0];
				};
				case "star_wars_kaatirs_stanned": {
					uiSleep 0.5;
					if (animationState _unit != "star_wars_kaatirs_stanned") exitWith {};
					_unit setVariable ["LeaperCanAttack",nil];
					uiSleep 1.5;
					if (animationState _unit != "star_wars_kaatirs_stanned") exitWith {};
					[_unit, "Star_Wars_KaaTirs_idle"] remoteExec ["switchMove", 0];
				};
				case "star_wars_kaatirs_scream": {
					if (!(isNil {_unit getVariable "WBK_Zombie_CustomSounds"})) then {
						_snds = (_unit getVariable "WBK_Zombie_CustomSounds") select 2;
						[_unit, selectRandom _snds, 360, 15] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					}else{
						[_unit, "leaper_scream", 360, 15] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					};
					uiSleep 0.6;
					if (animationState _unit != "star_wars_kaatirs_scream") exitWith {};
					{
						if ((isNil {_x getVariable "WBK_AI_ISZombie"}) and (isNil {_x getVariable "IMS_IsUnitInvicibleScripted"}) and (alive _x) and !(_x == _unit) and (simulationEnabled _unit)) then {
							[_x,228,_unit] remoteExec ["concentrationToZero",_x];
						};
					} forEach nearestObjects [getPosATL _unit, ["MAN"], 5.3];
					uiSleep 1.4;
					if (animationState _unit != "star_wars_kaatirs_scream") exitWith {};
					[_unit, "Star_Wars_KaaTirs_idle"] remoteExec ["switchMove", 0];
				};
		 };
	};
}];
[_unitWithSword, {
_this removeAllEventHandlers "HitPart";
_this addEventHandler [
    "HitPart",
    {
		(_this select 0) params ["_target","_shooter","_bullet","_position","_velocity","_selection","_ammo","_direction","_radius","_surface","_direct"];
		if ((_target == _shooter) or !(alive _target)) exitWith {};
		_isExplosive = _ammo select 3;
		_isEnoughDamage = _ammo select 0;
		if !(isNil "WBK_ZombiesShowDebugDamage") then {
			systemChat str _isEnoughDamage;
		};
		_vv = _target getVariable "WBK_SynthHP";
		_new_vv = _vv - _isEnoughDamage;
		if (_new_vv <= 0) exitWith {
			[_target, [1, false, _shooter]] remoteExec ["setDamage",2];
		};
		_target setVariable ["WBK_SynthHP",_new_vv,true];
		_target enableAI "MOVE";
	}
];
}] remoteExec ["spawn",0,true];


Leaper_Execution = {
	params ["_leaper","_victim"];
	_victim setDamage 1;
	_leaper attachTo [_victim,[0,1.1,0]];
	[_victim, "Star_Wars_KaaTirs_attack_execution_victim"] remoteExec ["switchMove", 0];
	[_leaper, "Star_Wars_KaaTirs_attack_execution_creature"] remoteExec ["switchMove", 0];
	[_victim, "Disable_Gesture"] remoteExec ["playActionNow", 0];
	[_leaper, "Disable_Gesture"] remoteExec ["playActionNow", 0];
	[_victim, "rakgul_specAttack_victim", 60, 8] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	if (isNil {_leaper getVariable "WBK_Zombie_CustomSounds"}) then {
		[_leaper, "rakgul_specAttack_attacker", 60, 8] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	};
	uiSleep 4;
	if (animationState _leaper != "Star_Wars_KaaTirs_attack_execution_creature") exitWith {};
	detach _leaper;
	[_leaper, "Star_Wars_KaaTirs_idle"] remoteExec ["switchMove", 0];
	[_leaper, ((getDir _leaper) - 180)] remoteExec ["setDir", 0];
};




_actFr = [{
    _array = _this select 0;
    _mutant = _array select 0;
	if (alive _mutant != isAwake _mutant) exitWith {_mutant setDamage 1;};
	_mutant allowDamage false;
	if (
	!(simulationEnabled _mutant) || 
	!(isTouchingGround _mutant) || 
	!(alive _mutant) ||
	!(isNull attachedTo _mutant) ||
	!(animationState _mutant in ["star_wars_kaatirs_attack_4","star_wars_kaatirs_attack_3","star_wars_kaatirs_attack_2","star_wars_kaatirs_idle","star_wars_kaatirs_runf","star_wars_kaatirs_runlf","star_wars_kaatirs_runrf"])
	) exitWith {};
	removeAllWeapons _mutant;
	_mutant disableAI "MINEDETECTION";
	_mutant disableAI "WEAPONAIM";
	_mutant disableAI "SUPPRESSION";
	_mutant disableAI "COVER";
	_mutant disableAI "AIMINGERROR";
	_mutant disableAI "TARGET";
	_mutant disableAI "AUTOCOMBAT";
	_mutant disableAI "FSM";
	_mutant setBehaviour "CARELESS";
	_en = _mutant findNearestEnemy _mutant;
	_ins = lineIntersectsSurfaces [
		aimPos _mutant,
		aimPos _en,
		_mutant,
		_en,
		true,
		1,
		"GEOM",
		"NONE"
    ];
	switch true do {
		case ((isNil {_mutant getVariable "LeaperCanAttackScream"}) and (animationState _en != "starWars_lightsaber_hit_3") and (animationState _en != "push_backwards") and (gestureState _en != "fp_dash_nostamina") and (lifeState _en != "INCAPACITATED") and (stance _en != "PRONE") and ((random 100) >= 90) and ((_en distance _mutant) <= 30) and (count _ins == 0) and (isNil {_mutant getVariable "LeaperCanAttack"})): {
			[_mutant, "Star_Wars_KaaTirs_scream"] remoteExec ["switchMove", 0];
			_mutant setVariable ["LeaperCanAttackScream",false];
			_mutant spawn {uiSleep 15; _this setVariable ["LeaperCanAttackScream",nil];};
		};
		case ((animationState _en != "starWars_lightsaber_hit_3") and (animationState _en != "push_backwards") and (gestureState _en != "fp_dash_nostamina") and (lifeState _en != "INCAPACITATED") and (stance _en != "PRONE") and ((random 100) >= 90) and ((_en distance _mutant) <= 5) and (count _ins == 0) and (isNil {_mutant getVariable "LeaperCanAttack"})): {
			[_mutant, "Star_Wars_KaaTirs_dodge"] remoteExec ["switchMove", 0];
			[_mutant, selectRandom ["leaper_attack_1","leaper_attack_2","leaper_attack_3","leaper_attack_4","leaper_attack_5"], 80, 10] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
			[_mutant, selectRandom ["axe_punch_empty_1","axe_punch_empty_2","axe_punch_empty_3"], 70, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  	
		};
		case (((random 100) >= 80) and ((_en distance _mutant) <= 6) and (count _ins == 0) and (isNil {_mutant getVariable "LeaperCanAttack"}) and (isNil {_mutant getVariable "LeaperCanAttackSpecial"})): {
			_mutant setVariable ["LeaperCanAttackSpecial",false];
			[_mutant, selectRandom ["leaper_attack_1","leaper_attack_2","leaper_attack_3","leaper_attack_4","leaper_attack_5"], 80, 10] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
			_mutant spawn {uiSleep 30; _this setVariable ["LeaperCanAttackSpecial",nil];};
			[_mutant, "Star_Wars_KaaTirs_attack_1"] remoteExec ["switchMove", 0];
		};
		case (((_en distance _mutant) <= 2.6) and (count _ins == 0) and (isNil {_mutant getVariable "LeaperCanAttack"})): {
			if ((animationState _en != "starWars_lightsaber_hit_3") and (animationState _en != "push_backwards") and (gestureState _en != "fp_dash_nostamina") and (lifeState _en != "INCAPACITATED") and (stance _en != "PRONE") and ((damage _en) >= 0.5) and (isNil {_en getVariable "IMS_IsUnitInvicibleScripted"}) and !(_en isKindOf "TIOWSpaceMarine_Base")) exitWith {
				[_mutant, _en] spawn Leaper_Execution;
			};
			_mutant setVariable ["LeaperCanAttack",false];
			[_mutant, selectRandom ["leaper_attack_1","leaper_attack_2","leaper_attack_3","leaper_attack_4","leaper_attack_5"], 80, 10] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
			switch true do {
				case (animationState _mutant == "Star_Wars_KaaTirs_attack_3"): {[_mutant, "Star_Wars_KaaTirs_attack_4"] remoteExec ["switchMove", 0];};
				case (animationState _mutant == "Star_Wars_KaaTirs_attack_2"): {[_mutant, "Star_Wars_KaaTirs_attack_3"] remoteExec ["switchMove", 0];};
				default {[_mutant, "Star_Wars_KaaTirs_attack_2"] remoteExec ["switchMove", 0];};
			};
		};
		default {};
	};
}, 0.1, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;

_loopPathfind = [{
    _array = _this select 0;
    _unit = _array select 0;
	_isStriderTaked = missionNamespace getVariable["bis_fnc_moduleRemoteControl_unit", player];
	_nearEnemy = _unit findNearestEnemy _unit; 
	switch true do {
		case (animationState _unit == "Star_Wars_KaaTirs_attack_execution_creature"): {};
		case (animationState _unit == "Star_Wars_KaaTirs_stanned"): {
			_positions = [
				getPosASLVisual _unit,
				_unit modelToWorldVisualWorld [0,-0.8,0]
			 ];
			_centroid = _positions call QS_fnc_geomPolygonCentroid;
			_dir = [[0,1,0], -([_unit, _nearEnemy] call BIS_fnc_dirTo)] call BIS_fnc_rotateVector2D;
			_unit setVelocityTransformation [
			  getPosASL _unit,  
			  _centroid,
			  [0,0,(velocity _unit select 2) - 1],  
			  [(velocity _unit select 0),(velocity _unit select 1),(velocity _unit select 2) - 1], 
			  vectorDir _unit,  
			  _dir,  
			  vectorUp _unit,  
			  vectorUp _unit, 
			  0.05
			]; 
		};
		case ((animationState _unit == "Star_Wars_KaaTirs_dodge") and !(isNull _nearEnemy) and (moveTime _nearEnemy <= 0.8)): {
			_insBack = lineIntersectsSurfaces [
				getPosASLVisual _unit,
				_unit modelToWorldVisualWorld [0,-1,0],
				_unit,
				_nearEnemy,
				true,
				1,
				"GEOM",
				"NONE"
			];
			_unit setVariable ["WBK_IsUnitLocked",0];
			_unit enableAI "ANIM";
			_unit disableAI "MOVE";
			if (count _insBack != 0) exitWith {};
			 _positions = [
				getPosASLVisual _unit,
				_unit modelToWorldVisualWorld [0,-1.5,0]
			 ];
			_centroid = _positions call QS_fnc_geomPolygonCentroid;
			_dir = [[0,1,0], -([_unit, _nearEnemy] call BIS_fnc_dirTo)] call BIS_fnc_rotateVector2D;
			_unit setVelocityTransformation [
			  getPosASL _unit,  
			  _centroid,
			  [0,0,(velocity _unit select 2) - 1],  
			  [(velocity _unit select 0),(velocity _unit select 1),(velocity _unit select 2) - 1], 
			  vectorDir _unit,  
			  _dir,  
			  vectorUp _unit,  
			  vectorUp _unit, 
			  0.05
			]; 
		};
		
		case ((animationState _unit == "Star_Wars_KaaTirs_attack_1") and !(isNull _nearEnemy) and (moveTime _nearEnemy <= 0.7)): {
			_unit setVariable ["WBK_IsUnitLocked",0];
			_unit enableAI "ANIM";
			_unit disableAI "MOVE";
			 _positions = [
				getPosASLVisual _unit,
				getPosASLVisual _nearEnemy
			 ];
			_centroid = _positions call QS_fnc_geomPolygonCentroid;
			_dir = [[0,1,0], -([_unit, _nearEnemy] call BIS_fnc_dirTo)] call BIS_fnc_rotateVector2D;
			_unit setVelocityTransformation [
			  getPosASL _unit,  
			  _centroid,
			  [0,0,(velocity _unit select 2) - 1],  
			  [(velocity _unit select 0),(velocity _unit select 1),(velocity _unit select 2) - 1], 
			  vectorDir _unit,  
			  _dir,  
			  vectorUp _unit,  
			  vectorUp _unit, 
			  0.07
			]; 
		};
		case (!(simulationEnabled _unit) || (_unit == _isStriderTaked) || (isNull _nearEnemy) or !(alive _nearEnemy) or !(alive _unit) or !(isNull attachedTo _unit) or (lifeState _unit == "INCAPACITATED") or (_unit distance _nearEnemy >= WBK_Zombies_SpecialInfected_MoveDistanceLimit)): {
			_unit setVariable ["WBK_IsUnitLocked",nil];
		};
		case (!(animationState _unit in ["star_wars_kaatirs_idle","star_wars_kaatirs_runf","star_wars_kaatirs_runlf","star_wars_kaatirs_runrf"])): {
			_unit setVariable ["WBK_IsUnitLocked",0];
			_unit enableAI "ANIM";
			_unit disableAI "MOVE";
			_dir = [[0,1,0], -([_unit, _nearEnemy] call BIS_fnc_dirTo)] call BIS_fnc_rotateVector2D;
			_unit setVelocityTransformation [ 
			  getPosASL _unit,  
			  getPosASL _unit,  
			  [0,0,(velocity _unit select 2) - 1],  
			  [(velocity _unit select 0),(velocity _unit select 1),(velocity _unit select 2) - 1], 
			  vectorDir _unit,  
			  _dir,  
			  vectorUp _unit,  
			  vectorUp _unit, 
			  0.01
			]; 
		};
		default {
			_ifInter = lineIntersectsSurfaces [
				AGLToASL (_nearEnemy modelToWorld [0,0,0.5]), 
				AGLToASL (_unit modelToWorld [0,0,0.5]), 
				_unit,
				_nearEnemy,
				true,
				1,
				"FIRE",
				"NONE"
			];
			_pos1 = (getPosATL _unit select 2);
			_pos2 = (getPosATL _nearEnemy select 2);
			_result1 = _pos1 - _pos2;
			  if (
			  (count _ifInter == 0) and 
			  (_result1 < 1.45) and
			  (_result1 > (-1.45)) and
			  !(lifeState _unit == "INCAPACITATED")
			  ) exitWith {
				_unit setVariable ["WBK_IsUnitLocked",0];
				_unit disableAI "MOVE";
				_unit disableAI "ANIM";
				doStop _unit;
				switch true do {
					case ((_unit distance _nearEnemy) > 16): {_unit playMoveNow "star_wars_kaatirs_runf";};
					case (((_unit distance _nearEnemy) > 12) && ((_unit distance _nearEnemy) <= 16)): {_unit playMoveNow "star_wars_kaatirs_runrf";};
					case ((_unit distance _nearEnemy) > 8): {_unit playMoveNow "star_wars_kaatirs_runlf";};
					case ((_unit distance _nearEnemy) <= 8): {_unit playMoveNow "star_wars_kaatirs_runf";};
					default {_unit playMoveNow "star_wars_kaatirs_idle";};
				};
				_dir = [[0,1,0], -([_unit, _nearEnemy] call BIS_fnc_dirTo)] call BIS_fnc_rotateVector2D;
				_unit setVelocityTransformation [ 
				  getPosASL _unit,  
				  getPosASL _unit,  
				  [0,0,(velocity _unit select 2) - 1],  
				  [(velocity _unit select 0),(velocity _unit select 1),(velocity _unit select 2) - 1], 
				  vectorDir _unit,  
				  _dir,  
				  vectorUp _unit,  
				  vectorUp _unit, 
				  0.1
				]; 
			  };
			  _unit setVariable ["WBK_IsUnitLocked",nil];
			  _unit enableAI "ANIM";
			  _unit enableAI "MOVE";
		};
	};
}, 0.01, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;


_loopPathfindDoMove = [{
    _array = _this select 0;
    _unit = _array select 0;
	_nearEnemy = _unit findNearestEnemy _unit; 
	_unit enableAI "MOVE";
	_unit enableAI "ANIM";
	if (!(simulationEnabled _unit) || !(alive _unit) || !(isNull attachedTo _unit) || (lifeState _unit == "INCAPACITATED")) exitWith {};
		if ((isNull _nearEnemy) or !(alive _nearEnemy) or !(alive _unit) or (_unit distance _nearEnemy >= WBK_Zombies_SpecialInfected_MoveDistanceLimit)) exitWith {
			if (!(isNil {_unit getVariable "WBK_Zombie_CustomSounds"})) then {
				[_unit, selectRandom ((_unit getVariable "WBK_Zombie_CustomSounds") select 0), 25] call CBA_fnc_GlobalSay3D;
			}else{
				[_unit, selectRandom ["leaper_idle_1","leaper_idle_2"], 25] call CBA_fnc_GlobalSay3D;
			};
		};
		_pos = ASLtoAGL getPosASLVisual _nearEnemy;
		_unit doMove _pos;
		if (!(isNil {_unit getVariable "WBK_Zombie_CustomSounds"})) then {
			[_unit, selectRandom ((_unit getVariable "WBK_Zombie_CustomSounds") select 1), 30] call CBA_fnc_GlobalSay3D;
		}else{
			[_unit, selectRandom ["leaper_idle_1","leaper_idle_2"], 30] call CBA_fnc_GlobalSay3D;
		};
}, 2.4, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;
_unitWithSword setVariable ["WBK_AI_AttachedHandlers", [_actFr,_loopPathfindDoMove,_loopPathfind]];