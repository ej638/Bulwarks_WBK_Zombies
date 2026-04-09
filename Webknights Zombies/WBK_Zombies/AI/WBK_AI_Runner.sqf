params ["_unitWithSword","_isCalm","_isCorrupted"];
if is3DEN exitWith {
	systemChat "Zombie AI loaded on this unit";
};
if ((isPlayer _unitWithSword) or !(isNil {_unitWithSword getVariable "WBK_AI_ISZombie"}) or !(alive _unitWithSword)) exitWith {};
if (primaryWeapon _unitWithSword != "") then {
	{
		_unitWithSword removeWeapon _x;
	} forEach [primaryWeapon _unitWithSword,handGunWeapon _unitWithSword,secondaryWeapon _unitWithSword];
};
_unitWithSword setSpeaker "NoVoice";
_unitWithSword disableConversation true;
_unitWithSword setUnitPos "UP";
_unitWithSword setCombatMode "BLUE";
_unitWithSword enableAttack false;
_unitWithSword setVariable ["WBK_AI_ISZombie",true,true];
_unitWithSword setVariable ["WBK_AI_ZombieMoveSet","WBK_Runner_Angry_Idle", true];
if (_isCorrupted) then {
    removeHeadgear _unitWithSword;
	removeGoggles _unitWithSword;
	_unitWithSword unlinkItem hmd _unitWithSword;
	[_unitWithSword, "WBK_Runner_Angry_Idle"] remoteExec ["switchMove",0];
	_unitWithSword setVariable ["WBK_SynthHP",WBK_Zombies_CorruptedHP,true];
	[_unitWithSword,"WBK_DosHead_Corrupted"] remoteExec ["setFace", 0];
	_unitWithSword setVariable ["WBK_Zombie_CustomSounds",[
		["corrupted_head_attack_1","corrupted_head_attack_2","corrupted_head_attack_3","corrupted_head_attack_4","corrupted_head_attack_5"],
		["corrupted_idle_1","corrupted_idle_2","corrupted_idle_3","corrupted_idle_4"],
		["corrupted_head_attack_1","corrupted_head_attack_2","corrupted_head_attack_3","corrupted_head_attack_4","corrupted_head_attack_5"],
		["corrupted_dead_1","corrupted_dead_2","corrupted_dead_3"],
		["corrupted_dead_1","corrupted_dead_2","corrupted_dead_3"]
	]];
}else{
	[_unitWithSword, selectRandom ["WBK_ZombieFace_1","WBK_ZombieFace_2","WBK_ZombieFace_3","WBK_ZombieFace_4","WBK_ZombieFace_5","WBK_ZombieFace_6"]] remoteExec ["setFace", 0];
	if (_isCalm) then {
		[_unitWithSword, "WBK_Runner_Calm_Idle"] remoteExec ["switchMove",0];
	}else{
		[_unitWithSword, "WBK_Runner_Angry_Idle"] remoteExec ["switchMove",0];
	};
	_unitWithSword setVariable ["WBK_SynthHP",WBK_Zombies_RunnerHP,true];
	if (getText (configfile >> "CfgVehicles" >> typeOf _unitWithSword >> "editorSubcategory") in ["WBK_Zombies_WW2_US","WBK_Zombies_WW2_RKKA","WBK_Zombies_WW2_German","LIB_WEHRMACHT","LIB_US_ARMY","LIB_RKKA"]) then {
		_unitWithSword setVariable ["WBK_Zombie_CustomSounds",[
		["WW2_Zombie_idle1","WW2_Zombie_idle2","WW2_Zombie_idle3","WW2_Zombie_idle4","WW2_Zombie_idle5","WW2_Zombie_idle6"],
		["WW2_Zombie_walker1","WW2_Zombie_walker2","WW2_Zombie_walker3","WW2_Zombie_walker4","WW2_Zombie_walker5"],
		["WW2_Zombie_attack1","WW2_Zombie_attack2","WW2_Zombie_attack3","WW2_Zombie_attack4","WW2_Zombie_attack5"],
		["WW2_Zombie_death1","WW2_Zombie_death2","WW2_Zombie_death3","WW2_Zombie_death4","WW2_Zombie_death5"],
		["WW2_Zombie_burning1","WW2_Zombie_burning2","WW2_Zombie_burning3"]
		]];
	};
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
		_zombie spawn {
			uiSleep (0.3 + random 0.1);
			if (isNull _this) exitWith {};
			[_this, selectRandom ["zombie_fall_1","zombie_fall_2","zombie_fall_3"], 50, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		};
		_killer = _this select 1;
		uiSleep 0.2;
		if ((isNull _zombie) || (face _zombie in ["WBK_DecapatedHead_Zombies_Normal","WBK_DosHead_BackHole","WBK_DosHead_FrontHole"])) exitWith {};
		if (!(isNil {_zombie getVariable "WBK_Zombie_CustomSounds"})) then {
			[_zombie, selectRandom ((_zombie getVariable "WBK_Zombie_CustomSounds") select 3), 50, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		}else{
			[_zombie, selectRandom ["runner_death_1","runner_death_2","runner_death_3","runner_death_4","runner_death_5"], 50, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
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
				case "wbk_crawler_attack": {
					uiSleep 0.6;
					if (animationState _unit != "wbk_crawler_attack") exitWith {};
					[_unit,0.1,2,false] call WBK_ZombieAttackDamage;
				};
				case "wbk_walker_idle_1_attack": {
					uiSleep 0.6;
					if (animationState _unit != "wbk_walker_idle_1_attack") exitWith {};
					[_unit,0.1,2,false] call WBK_ZombieAttackDamage;
				};
				case "wbk_walker_idle_2_attack": {
					uiSleep 0.6;
					if (animationState _unit != "wbk_walker_idle_2_attack") exitWith {};
					[_unit,0.1,2,false] call WBK_ZombieAttackDamage;
				};
				case "wbk_runner_attack_unconscious": {
					uiSleep 0.4;
					if (animationState _unit != "wbk_runner_attack_unconscious") exitWith {};
					[_unit, "leg_hit1", 40, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					[_unit,0.1,2.2,false] call WBK_ZombieAttackDamage;
					uiSleep 0.5;
					if (animationState _unit != "wbk_runner_attack_unconscious") exitWith {};
					[_unit, "leg_hit2", 40, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					[_unit,0.1,2.2,false] call WBK_ZombieAttackDamage;
					uiSleep 0.6;
					if (animationState _unit != "wbk_runner_attack_unconscious") exitWith {};
					[_unit, "leg_hit3", 40, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					[_unit,0.1,2.2,false] call WBK_ZombieAttackDamage;
					uiSleep 1.3;
					if (animationState _unit != "wbk_runner_attack_unconscious") exitWith {};
					[_unit, "boxing_hit_00", 40, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					[_unit,0.1,2.2,false] call WBK_ZombieAttackDamage;
					uiSleep 0.9;
					if (animationState _unit != "wbk_runner_attack_unconscious") exitWith {};
					[_unit, "boxing_hit_01", 40, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					[_unit,0.1,2.2,false] call WBK_ZombieAttackDamage;
					uiSleep 0.6;
					if (animationState _unit != "wbk_runner_attack_unconscious") exitWith {};
					[_unit, "boxing_hit_02", 40, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					[_unit,0.1,2.2,false] call WBK_ZombieAttackDamage;
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
		switch true do {
			case (((_ammo select 3) >= 0.7) && (_target getVariable "WBK_AI_ZombieMoveSet" != "WBK_Crawler_Idle")): {
				_new_vv = (_target getVariable "WBK_SynthHP") - ((_ammo select 0) * 2);
				if (_new_vv <= 0) exitWith {
					if (isNil "WBK_IsPresent_DAH") then {
						[_target, [_shooter vectorModelToWorld [random 500,random 500,100], _target selectionPosition "head", false]] remoteExec ["addForce", _target];
					};
					_target removeAllEventHandlers "HitPart"; 
					[_target, [1, false, _shooter]] remoteExec ["setDamage",2];
				};
				_target setVariable ["WBK_SynthHP",_new_vv,true];
				[_target, selectRandom ["WBK_Runner_Fall_Back","WBK_Runner_Fall_Forward"]] remoteExec ["switchMove", 0]; 
			};
			case (((_selection select 0) in ["head","neck"]) && !(animationState _target in ["wbk_runner_fall_forward","wbk_runner_fall_back"])): {
				_new_vv = (_target getVariable "WBK_SynthHP") - ((_ammo select 0) * WBK_Zombies_HeadshotMP);
				if (_new_vv <= 0) exitWith {
					if (isNil "WBK_IsPresent_DAH") then {
						[_target, [_shooter vectorModelToWorld [0,500,50], _target selectionPosition "head", false]] remoteExec ["addForce", _target];
					};
					_target removeAllEventHandlers "HitPart"; 
					[_target, [1, false, _shooter]] remoteExec ["setDamage",2];
					if ((_ammo select 0) >= 10.5) then {
						_target call WBK_Zombies_CreateBloodParticle;
						[_target, selectRandom ["decapetadet_sound_1","decapetadet_sound_2"], 80, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
						switch true do {
							case ((_ammo select 0) >= 14): {
								_target unlinkItem hmd _target;
								removeGoggles _target;
								removeHeadgear _target;
								[_target, "WBK_DecapatedHead_Zombies_Normal"] remoteExec ["setFace",0];
							};
							case (((_target worldToModel (_shooter modelToWorld [0, 0, 0])) select 1) < 0): {
								[_target, "WBK_DosHead_BackHole"] remoteExec ["setFace",0];
							};
							default {
								[_target, "WBK_DosHead_FrontHole"] remoteExec ["setFace",0];
							};
						};
					};
				};
				_target setVariable ["WBK_SynthHP",_new_vv,true];
				if (_target getVariable "WBK_AI_ZombieMoveSet" == "WBK_Crawler_Idle") exitWith {};
				if (((_target worldToModel (_shooter modelToWorld [0, 0, 0])) select 1) < 0) exitWith {
					[_target, "WBK_Runner_Fall_Forward"] remoteExec ["switchMove", 0]; 
				};
				[_target, "WBK_Runner_Fall_Back"] remoteExec ["switchMove", 0];
			};
			case (((_selection select 0) in [
				"leftfoot",
				"lefttoebase",
				"leftleg",
				"leftlegroll",
				"leftupleg",
				"leftuplegroll",
				"rightupleg",
				"rightuplegroll",
				"rightleg",
				"rightlegroll",
				"rightfoot",
				"righttoebase"
			]) && (_target getVariable "WBK_AI_ZombieMoveSet" != "WBK_Crawler_Idle") && (animationState _target != "WBK_Runner_Fall_Forward")): {
				[_target, "dobi_fall_2", 50, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				if ((random 100) >= 30) exitWith {
					[_target, "WBK_Runner_Fall_Forward"] remoteExec ["switchMove", 0];
				};
				[_target, "WBK_Crawler_TransformTo"] remoteExec ["switchMove", 0];
				[_target, "WBK_Crawler_Idle"] remoteExec ["playMoveNow", 0];
				_target setVariable ["WBK_AI_ZombieMoveSet","WBK_Crawler_Idle",true];
			};
			default {
				_new_vv = (_target getVariable "WBK_SynthHP") - (_ammo select 0);
				if (_new_vv <= 0) exitWith {
					if (isNil "WBK_IsPresent_DAH") then {
						[_target, [_shooter vectorModelToWorld [0,500,50], _target selectionPosition (_selection select 0), false]] remoteExec ["addForce", _target];
					};
					_target removeAllEventHandlers "HitPart"; 
					[_target, [1, false, _shooter]] remoteExec ["setDamage",2];
				};
				_target setVariable ["WBK_SynthHP",_new_vv,true];
				[_target, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_target];
			};
		};
	}
];
}] remoteExec ["spawn",0,true];

_actFr = [{
    _array = _this select 0;
    _mutant = _array select 0;
	if (alive _mutant != isAwake _mutant) exitWith {_mutant setDamage 1;};
	_mutant allowDamage false;
	if (animationState _mutant in ["wbk_runner_hit_b","wbk_runner_hit_f_2","wbk_runner_hit_f_1","wbk_runner_shoved_b","wbk_zombie_evade_b","wbk_runner_shoved_f"]) exitWith {
		_insCount = lineIntersectsSurfaces [
			_mutant modelToWorldWorld (_mutant selectionPosition "pelvis"),
			_mutant modelToWorldWorld (_mutant selectionPosition "pelvis"),
			_mutant,
			objNull,
			true,
			1,
			"GEOM",
			"FIRE"
		];
		if (count _insCount != 0) then {
			[_mutant, "dobi_fall_2", 40, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
			_mutant playMoveNow "WBK_Runner_Shoved_B_Stunned";
			_mutant playMove "WBK_Runner_Angry_Idle";
		};
	};
	if (
	!(simulationEnabled _mutant) || 
	!(isTouchingGround _mutant) || 
	!(alive _mutant) ||
	!(isNull attachedTo _mutant) ||
	!(animationState _mutant in ["wbk_crawler_idle","wbk_crawler_walk","wbk_runner_angry_idle","wbk_runner_angry_run","wbk_runner_angry_sprint","wbk_runner_angry_turnl","wbk_runner_angry_turnr","wbk_runner_calm_idle","wbk_runner_calm_turn","wbk_runner_calm_turn_l","wbk_runner_calm_walk"])
	) exitWith {};
	if (primaryWeapon _mutant != "") then {
		{
			_mutant removeWeapon _x;
		} forEach [primaryWeapon _mutant,handGunWeapon _mutant,secondaryWeapon _mutant];
	};
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
	if (!(isNull _en) && (alive _en)) then {
		switch true do {
			case ((_mutant getVariable "WBK_AI_ZombieMoveSet" != "WBK_Crawler_Idle") and ((_en distance _mutant) <= 200) && (animationState _mutant in ["wbk_runner_calm_idle","wbk_runner_calm_turn","wbk_runner_calm_turn_l","wbk_runner_calm_walk"])): {
				[_mutant,["WBK_Runner_Calm_To_Angry", 0, 0.2, false]] remoteExec ["switchMove",0];
				[_mutant, "WBK_Runner_Angry_Idle"] remoteExec ["playMove",0];
				if (!(isNil {_mutant getVariable "WBK_Zombie_CustomSounds"})) then {
					[_mutant, selectRandom ((_mutant getVariable "WBK_Zombie_CustomSounds") select 2), 35, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				}else{
					[_mutant, selectRandom ["runner_dodge_1","runner_dodge_2","runner_dodge_3","runner_dodge_4"], 35, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				};
			};
			case ((animationState _en != "starWars_lightsaber_hit_3") and (animationState _en != "push_backwards") and (gestureState _en != "fp_dash_nostamina") and (lifeState _en != "INCAPACITATED") and (stance _en != "PRONE") and (_mutant getVariable "WBK_AI_ZombieMoveSet" != "WBK_Crawler_Idle") and ((random 100) >= 80) and ((_en distance _mutant) <= 4) and !(isNil {_mutant getVariable "WBK_IsUnitLocked"}) and !(gestureState _mutant in ["wbk_zombie_attack_left","wbk_zombie_attack_right"]) and !(animationState _mutant in ["wbk_zombie_evade_l","wbk_zombie_evade_r","wbk_zombie_evade_b"])): {
				_mutant playActionNow "Disable_Gesture";
				[_mutant, selectRandom ["WBK_Zombie_Evade_L","WBK_Zombie_Evade_R","WBK_Zombie_Evade_B"]] remoteExec ["switchMove", 0];
				[_mutant, "WBK_Runner_Angry_Idle"] remoteExec ["playMove", 0];
				if (!(isNil {_mutant getVariable "WBK_Zombie_CustomSounds"})) then {
					[_mutant, selectRandom ((_mutant getVariable "WBK_Zombie_CustomSounds") select 2), 35, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				}else{
					[_mutant, selectRandom ["runner_dodge_1","runner_dodge_2","runner_dodge_3","runner_dodge_4"], 35, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				};
			};
			case ((lifeState _en == "INCAPACITATED" || stance _en == "PRONE" || gestureState _en == "fp_dash_nostamina" || animationState _en == "push_backwards") && ((_en distance _mutant) <= 1.5) && !(isNil {_mutant getVariable "WBK_IsUnitLocked"}) && (_mutant getVariable "WBK_AI_ZombieMoveSet" != "WBK_Crawler_Idle")): {
				[_mutant,["WBK_Runner_Attack_Unconscious", 0, 0.2, false]] remoteExec ["switchMove",0];
				[_mutant, "WBK_Runner_Angry_Sprint"] remoteExec ["playMove", 0];
			};
			case ((animationState _en != "push_backwards") and (gestureState _en != "fp_dash_nostamina") and (lifeState _en != "INCAPACITATED") and (stance _en != "PRONE") and ((_en distance _mutant) <= 2.2) and !(isNil {_mutant getVariable "WBK_IsUnitLocked"}) and !(gestureState _mutant in ["wbk_zombie_attack_left","wbk_zombie_attack_right"]) and !(animationState _mutant in ["wbk_zombie_evade_l","wbk_zombie_evade_r","wbk_zombie_evade_b"])): {
				if (!(isNil {_mutant getVariable "WBK_Zombie_CustomSounds"})) then {
					[_mutant, selectRandom ((_mutant getVariable "WBK_Zombie_CustomSounds") select 2), 55, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				}else{
					[_mutant, selectRandom ["runner_attack_1","runner_attack_2","runner_attack_3","runner_attack_4","runner_attack_5","runner_attack_6"], 55, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				};
				if (_mutant getVariable "WBK_AI_ZombieMoveSet" == "WBK_Crawler_Idle") exitWith {
					[_mutant,["WBK_Crawler_Attack", 0, 0.2, false]] remoteExec ["switchMove",0];
					[_mutant, "WBK_Crawler_Idle"] remoteExec ["playMove", 0];
				};
				_mutant spawn {
					_this playActionNow selectRandom ["wbk_zombie_attack_left","wbk_zombie_attack_right"];
					uiSleep 0.25;
					if !(gestureState _this in ["wbk_zombie_attack_left","wbk_zombie_attack_right"]) exitWith {};
					[_this,0.1,2,false] call WBK_ZombieAttackDamage;
				};
			};
			default {};
		};
	};
}, 0.1, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;

_loopPathfind = [{
    _array = _this select 0;
    _unit = _array select 0;
	_nearEnemy = _unit findNearestEnemy _unit; 
	switch true do {
		case (!(simulationEnabled _unit) || !(isNull (remoteControlled _unit)) || (isNull _nearEnemy) or !(alive _nearEnemy) or !(alive _unit) or !(isNull attachedTo _unit) or (lifeState _unit == "INCAPACITATED") or (_unit distance _nearEnemy >= WBK_Zombies_MoveDistanceLimit)): {
			switch true do {
				case !(isNil {_unit getVariable "WBK_IsUnitLocked"}): {_unit setVariable ["WBK_IsUnitLocked",nil];};
				default {};
			};
		};
		case !(animationState _unit in ["wbk_zombie_evade_l","wbk_zombie_evade_r","wbk_zombie_evade_b","wbk_crawler_idle","wbk_crawler_walk","wbk_runner_angry_idle","wbk_runner_angry_run","wbk_runner_angry_sprint","wbk_runner_angry_turnl","wbk_runner_angry_turnr","wbk_runner_calm_idle","wbk_runner_calm_turn","wbk_runner_calm_turn_l","wbk_runner_calm_walk"]): {
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
			  0.1
			]; 
		};
		case (!(isNull _nearEnemy) && (alive _nearEnemy)): {
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
			switch true do {
				case ((count _ifInter == 0) and (((getPosATL _unit select 2) - (getPosATL _nearEnemy select 2)) < 1.45) and (((getPosATL _unit select 2) - (getPosATL _nearEnemy select 2)) > (-1.45))): {
					_unit setVariable ["WBK_IsUnitLocked",0];
					_unit disableAI "MOVE";
					_unit disableAI "ANIM";
					doStop _unit;
					switch true do {
						case (lifeState _nearEnemy == "INCAPACITATED" || stance _nearEnemy == "PRONE" || gestureState _nearEnemy == "fp_dash_nostamina" || animationState _nearEnemy == "push_backwards"): {
							_skeletalType = getText (configfile >> "CfgVehicles" >> typeOf _unit >> "moves");
							_currentMoveset = getText (configfile >> _skeletalType >> "States" >> animationState _unit >> "actions");
							_currentAnimationToPlay = getText (configfile >> _skeletalType >> "Actions" >> _currentMoveset >> "WalkF");
							_unit playMoveNow _currentAnimationToPlay;
						};
						case ((_unit distance _nearEnemy) > 2): {
							_skeletalType = getText (configfile >> "CfgVehicles" >> typeOf _unit >> "moves");
							_currentMoveset = getText (configfile >> _skeletalType >> "States" >> animationState _unit >> "actions");
							_currentAnimationToPlay = getText (configfile >> _skeletalType >> "Actions" >> _currentMoveset >> "FastF");
							_unit playMoveNow _currentAnimationToPlay;
						};
						default {
							_skeletalType = getText (configfile >> "CfgVehicles" >> typeOf _unit >> "moves");
							_currentMoveset = getText (configfile >> _skeletalType >> "States" >> animationState _unit >> "actions");
							_currentAnimationToPlay = getText (configfile >> _skeletalType >> "Actions" >> _currentMoveset >> "default");
							_unit playMoveNow _currentAnimationToPlay;
						};
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
					  0.5
					]; 
				};
				default {
					switch true do {
						case !(isNil {_unit getVariable "WBK_IsUnitLocked"}): {
							_unit setVariable ["WBK_IsUnitLocked",nil];
							_unit enableAI "ANIM";
							_unit enableAI "MOVE";
							_unit doMove (getPosATLVisual _nearEnemy);
							_unit setVariable ["WBK_AI_LastKnownLoc",getPosATLVisual _nearEnemy];
						};
						default {};
					};
				};
			};
		};
		default {
			switch true do {
				case !(isNil {_unit getVariable "WBK_IsUnitLocked"}): {
					_unit setVariable ["WBK_IsUnitLocked",nil];
					_unit enableAI "ANIM";
					_unit enableAI "MOVE";
					_unit doMove (getPosATLVisual _nearEnemy);
					_unit setVariable ["WBK_AI_LastKnownLoc",getPosATLVisual _nearEnemy];
				};
				default {};
			};
		};
	};
}, 0.1, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;


_loopPathfindDoMove = [{
    _array = _this select 0;
    _unit = _array select 0;
	switch true do {
		case !(isNil {_unit getVariable "WBK_IsUnitLocked"}): {
			if (!(isNil {_unit getVariable "WBK_Zombie_CustomSounds"})) then {
				[_unit, selectRandom ((_unit getVariable "WBK_Zombie_CustomSounds") select 1), 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
			}else{
				[_unit, selectRandom ["runned_agro_1","runned_agro_2","runned_agro_3","runned_agro_4","runned_agro_5","runned_agro_6","runned_agro_7","runned_agro_8"], 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
			};
		};
		default {
			_nearEnemy = _unit findNearestEnemy _unit; 
			_unit enableAI "MOVE";
			_unit enableAI "ANIM";
			switch true do {
				case (!(simulationEnabled _unit) || !(alive _unit) || !(isNull attachedTo _unit) || (lifeState _unit == "INCAPACITATED")): {};
				case ((isNull _nearEnemy) or !(alive _nearEnemy) or !(alive _unit) or (_unit distance _nearEnemy >= WBK_Zombies_MoveDistanceLimit)): {
					if (!(isNil {_unit getVariable "WBK_Zombie_CustomSounds"})) then {
						[_unit, selectRandom ((_unit getVariable "WBK_Zombie_CustomSounds") select 0), 30, "wbk_horde_calm_01", false] call WBK_ZombiePlayIdleSounds;
					}else{
						[_unit, selectRandom ["runned_idle_1","runned_idle_2","runned_idle_3","runned_idle_4"], 30, "wbk_horde_calm_01", false] call WBK_ZombiePlayIdleSounds;
					};
				};
				case !(isNil {_unit getVariable "WBK_AI_LastKnownLoc"}): {
					switch true do {
						case ((_nearEnemy distance (_unit getVariable "WBK_AI_LastKnownLoc")) >= WBK_Zombies_TargetPosChanged): {
							_unit doMove (getPosATLVisual _nearEnemy);
							_unit setVariable ["WBK_AI_LastKnownLoc",getPosATLVisual _nearEnemy];
						};
						default {};
					};
					if (!(isNil {_unit getVariable "WBK_Zombie_CustomSounds"})) then {
						[_unit, selectRandom ((_unit getVariable "WBK_Zombie_CustomSounds") select 1), 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
					}else{
						[_unit, selectRandom ["runned_agro_1","runned_agro_2","runned_agro_3","runned_agro_4","runned_agro_5","runned_agro_6","runned_agro_7","runned_agro_8"], 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
					};
				};
				case (!(isNull _nearEnemy) && (alive _nearEnemy)): {
					_unit doMove (getPosATLVisual _nearEnemy);
					_unit setVariable ["WBK_AI_LastKnownLoc",getPosATLVisual _nearEnemy];
					if (!(isNil {_unit getVariable "WBK_Zombie_CustomSounds"})) then {
						[_unit, selectRandom ((_unit getVariable "WBK_Zombie_CustomSounds") select 1), 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
					}else{
						[_unit, selectRandom ["runned_agro_1","runned_agro_2","runned_agro_3","runned_agro_4","runned_agro_5","runned_agro_6","runned_agro_7","runned_agro_8"], 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
					};
				};
				default {};
			};
		};
	};
}, selectRandom [4,5,6,7], [_unitWithSword]] call CBA_fnc_addPerFrameHandler;
_unitWithSword setVariable ["WBK_AI_AttachedHandlers", [_actFr,_loopPathfindDoMove,_loopPathfind]];