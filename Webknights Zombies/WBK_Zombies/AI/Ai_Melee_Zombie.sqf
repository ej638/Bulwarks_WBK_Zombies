params ["_unitWithSword"];
if is3DEN exitWith {
	systemChat "Zombie AI loaded on this unit";
};
if ((isPlayer _unitWithSword) or !(isNil {_unitWithSword getVariable "WBK_AI_ISZombie"}) or !(alive _unitWithSword)) exitWith {};
if (primaryWeapon _unitWithSword != "") then {
	{
		_unitWithSword removeWeapon _x;
	} forEach [primaryWeapon _unitWithSword,secondaryWeapon _unitWithSword];
};
if !(handgunWeapon _unitWithSword in IMS_Melee_Weapons) then {
	_unitWithSword removeWeapon handgunWeapon _unitWithSword;
	_unitWithSword addWeapon selectRandom ["Axe","WBK_pipeStyledSword","WBK_survival_weapon_3"];
};
_weapon = handgunWeapon _unitWithSword;
_unitWithSword removeWeapon handgunWeapon _unitWithSword;
_weaponHolder = createVehicle ["Weapon_Empty", [0, 0, 0], [], 0, "CAN_COLLIDE"];
_weaponHolder addWeaponCargoGlobal[_weapon, 1];
_weaponHolder attachTo [_unitWithSword,[0,0,0.07],"rightHand",true];
_unitWithSword setVariable ["WBK_Zombie_WeaponHolders",[_weapon,_weaponHolder]];

_unitWithSword setUnitPos "UP";
_unitWithSword setVariable ["WBK_AI_ISZombie",true,true];
_unitWithSword setVariable ["WBK_AI_ZombieMoveSet","WBK_Zombie_Melee_Idle",true];
[_unitWithSword, "WBK_Zombie_Melee_Idle"] remoteExec ["switchMove",0];
_unitWithSword setVariable ["WBK_SynthHP",WBK_Zombies_MeleeHP,true];
_unitWithSword setSpeaker "NoVoice";
_unitWithSword disableConversation true;
_unitWithSword setCombatMode "BLUE";
_unitWithSword enableAttack false;

if (getText (configfile >> "CfgVehicles" >> typeOf _unitWithSword >> "editorSubcategory") in ["WBK_Zombies_WW2_US","WBK_Zombies_WW2_RKKA","WBK_Zombies_WW2_German","LIB_WEHRMACHT","LIB_US_ARMY","LIB_RKKA"]) then {
	_unitWithSword setVariable ["WBK_Zombie_CustomSounds",
	[
	["WW2_Zombie_idle1","WW2_Zombie_idle2","WW2_Zombie_idle3","WW2_Zombie_idle4","WW2_Zombie_idle5","WW2_Zombie_idle6"],
	["WW2_Zombie_walker1","WW2_Zombie_walker2","WW2_Zombie_walker3","WW2_Zombie_walker4","WW2_Zombie_walker5"],
	["WW2_Zombie_attack1","WW2_Zombie_attack2","WW2_Zombie_attack3","WW2_Zombie_attack4","WW2_Zombie_attack5"],
	["WW2_Zombie_death1","WW2_Zombie_death2","WW2_Zombie_death3","WW2_Zombie_death4","WW2_Zombie_death5"],
	["WW2_Zombie_burning1","WW2_Zombie_burning2","WW2_Zombie_burning3"]
	]];
};



if !(isNil "WBK_IsPresent_Necroplague") then {
	_unitWithSword setVariable ['isMutant',true];
};
if !(isNil "WBK_IsPresent_PIR") then {
	_unitWithSword setVariable ["dam_ignore_hit0",true,true];
	_unitWithSword setVariable ["dam_ignore_effect0",true,true];
};

[_unitWithSword, selectRandom ["WBK_ZombieFace_blood_1","WBK_ZombieFace_blood_2","WBK_ZombieFace_blood_3","WBK_ZombieFace_blood_4","WBK_ZombieFace_1","WBK_ZombieFace_2","WBK_ZombieFace_3","WBK_ZombieFace_4","WBK_ZombieFace_5","WBK_ZombieFace_6"]] remoteExec ["setFace", 0];
_unitWithSword spawn {
	uisleep 0.5;
	_this doMove (getPosATLVisual _this);
};


_unitWithSword addEventHandler ["Deleted", {
	params ["_zombie"];
	{
		_ifDelete = [_x] call CBA_fnc_removePerFrameHandler;
	} forEach (_zombie getVariable "WBK_AI_AttachedHandlers");
	deleteVehicle ((_zombie getVariable "WBK_Zombie_WeaponHolders") select 1);
}];


_unitWithSword addEventHandler ["Killed", {
	{
		_ifDelete = [_x] call CBA_fnc_removePerFrameHandler;
	} forEach ((_this select 0) getVariable "WBK_AI_AttachedHandlers");
	deleteVehicle (((_this select 0) getVariable "WBK_Zombie_WeaponHolders") select 1);
	(_this select 0) addWeapon (((_this select 0) getVariable "WBK_Zombie_WeaponHolders") select 0);
	_this spawn {
		_zombie = _this select 0;
		_zombie spawn {
			uiSleep (0.3 + random 0.1);
			if (isNull _this) exitWith {};
			[_this, selectRandom ["zombie_fall_1","zombie_fall_2","zombie_fall_3"], 50, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		};
		if (goggles _zombie == "EoO_Fant_SkeletonEyes_FW_1") then {
			removeGoggles _zombie;
		};
		_killer = _this select 1;
		uiSleep 0.2;
		if ((isNull _zombie) || (face _zombie in ["WBK_DecapatedHead_Zombies_Normal","WBK_DosHead_BackHole","WBK_DosHead_FrontHole"])) exitWith {};
		if (!(isNil {_zombie getVariable "WBK_Zombie_CustomSounds"})) then {
			[_zombie, selectRandom ((_zombie getVariable "WBK_Zombie_CustomSounds") select 3), 50, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		}else{
			[_zombie, selectRandom ["middle_death_1","middle_death_2","middle_death_3","middle_death_4","middle_death_5"], 60, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
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
				case "wbk_zombie_melee_attack_1": {
					uiSleep 0.42;
					if (animationState _unit != "wbk_zombie_melee_attack_1") exitWith {};
					[_unit, selectRandom ["generis_empty_1","generis_empty_2","generis_empty_3","generis_empty_4","generis_empty_5"], 100, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";   
					uiSleep 0.15; 
					if (animationState _unit != "wbk_zombie_melee_attack_1") exitWith {};
					[_unit,0.1,3,true] call WBK_ZombieAttackDamage;
				};
				case "wbk_zombie_melee_attack_2": {
					uiSleep 0.55;
					if (animationState _unit != "wbk_zombie_melee_attack_2") exitWith {};
					[_unit, selectRandom ["generis_empty_1","generis_empty_2","generis_empty_3","generis_empty_4","generis_empty_5"], 100, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";   
					uiSleep 0.28; 
					if (animationState _unit != "wbk_zombie_melee_attack_2") exitWith {};
					[_unit,0.1,3,true] call WBK_ZombieAttackDamage;
				};
				case "wbk_zombie_melee_attack_3": {
					uisleep 0.55; 
					if (animationState _unit != "wbk_zombie_melee_attack_3") exitWith {};
					[_unit, selectRandom ["generis_empty_1","generis_empty_2","generis_empty_3","generis_empty_4","generis_empty_5"], 100, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";   
					uisleep 0.34; 
					if (animationState _unit != "wbk_zombie_melee_attack_3") exitWith {};
					[_unit,0.1,3,true] call WBK_ZombieAttackDamage;
					uisleep 0.5;
					if (animationState _unit != "wbk_zombie_melee_attack_3") exitWith {};
					[_unit, selectRandom ["generis_empty_1","generis_empty_2","generis_empty_3","generis_empty_4","generis_empty_5"], 100, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";   
					uisleep 0.15; 
					if (animationState _unit != "wbk_zombie_melee_attack_3") exitWith {};
					[_unit,0.1,3,true] call WBK_ZombieAttackDamage;
				};
				case "wbk_zombie_melee_attack_4": {
					uisleep 0.7; 
					if (animationState _unit != "wbk_zombie_melee_attack_4") exitWith {};
					[_unit, selectRandom ["generis_empty_1","generis_empty_2","generis_empty_3","generis_empty_4","generis_empty_5"], 100, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";   
					uisleep 0.34; 
					if (animationState _unit != "wbk_zombie_melee_attack_4") exitWith {};
					[_unit,0.1,3,true] call WBK_ZombieAttackDamage;
					uisleep 1;
					if (animationState _unit != "wbk_zombie_melee_attack_4") exitWith {};
					[_unit, selectRandom ["generis_empty_1","generis_empty_2","generis_empty_3","generis_empty_4","generis_empty_5"], 100, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";   
					uisleep 0.15; 
					if (animationState _unit != "wbk_zombie_melee_attack_4") exitWith {};
					[_unit,0.1,3,true] call WBK_ZombieAttackDamage;
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
			case ((_ammo select 3) >= 0.7): {
				_new_vv = (_target getVariable "WBK_SynthHP") - ((_ammo select 0) * 2);
				if (_new_vv <= 0) exitWith {
					if (isNil "WBK_IsPresent_DAH") then {
						[_target, [_shooter vectorModelToWorld [random 500,random 500,100], _target selectionPosition "head", false]] remoteExec ["addForce", _target];
					};
					_target removeAllEventHandlers "HitPart"; 
					[_target, [1, false, _shooter]] remoteExec ["setDamage",2];
				};
				_target setVariable ["WBK_SynthHP",_new_vv,true];
				[_target, selectRandom ["WBK_Zombie_Melee_Hit_2","WBK_Zombie_Melee_Hit_Fall"]] remoteExec ["switchMove", 0]; 
			};
			case (((_selection select 0) in ["head","neck"]) && !(animationState _target in ["wbk_zombie_melee_hit_fall","wbk_zombie_melee_hit_2"])): {
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
				if (((_target worldToModel (_shooter modelToWorld [0, 0, 0])) select 1) < 0) exitWith {
					[_target, "WBK_Zombie_Melee_Hit_Fall"] remoteExec ["switchMove", 0]; 
				};
				[_target, "WBK_Zombie_Melee_Hit_2"] remoteExec ["switchMove", 0];
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
	if (
	!(simulationEnabled _mutant) || 
	!(isTouchingGround _mutant) || 
	!(alive _mutant) ||
	!(isNull attachedTo _mutant) ||
	!(animationState _mutant in ["wbk_zombie_melee_idle","wbk_zombie_melee_run","wbk_zombie_melee_walk"])
	) exitWith {};
	if (primaryWeapon _mutant != "") then {
		{
			_mutant removeWeapon _x;
		} forEach [primaryWeapon _mutant,secondaryWeapon _mutant];
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
		if (((_en distance _mutant) <= 2.5) and !(isNil {_mutant getVariable "WBK_IsUnitLocked"})) then {
			if (!(isNil {_mutant getVariable "WBK_Zombie_CustomSounds"})) then {
				[_mutant, selectRandom ((_mutant getVariable "WBK_Zombie_CustomSounds") select 2), 55, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
			}else{
				[_mutant, selectRandom ["middle_attack_1","middle_attack_2","middle_attack_3","middle_attack_4","middle_attack_5","middle_attack_6"], 45, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
			};
			[_mutant, selectRandom ["WBK_Zombie_Melee_Attack_1","WBK_Zombie_Melee_Attack_2","WBK_Zombie_Melee_Attack_3","WBK_Zombie_Melee_Attack_4"]] remoteExec ["switchMove", 0];
			[_mutant, "WBK_Zombie_Melee_Idle"] remoteExec ["playMoveNow", 0];
		};
	};
}, 0.1, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;

_loopPathfind = [{
    _array = _this select 0;
    _unit = _array select 0;
	_nearEnemy = _unit findNearestEnemy _unit; 
	switch true do {
		case (!(simulationEnabled _unit) || !(isNull (remoteControlled _unit)) || (isNull _nearEnemy) or !(alive _nearEnemy) or !(alive _unit) or !(isNull attachedTo _unit) or (lifeState _unit == "INCAPACITATED") or (_unit distance _nearEnemy >= WBK_Zombies_SpecialInfected_MoveDistanceLimit)): {
			switch true do {
				case !(isNil {_unit getVariable "WBK_IsUnitLocked"}): {_unit setVariable ["WBK_IsUnitLocked",nil];};
				default {};
			};
		};
		case !(animationState _unit in ["wbk_zombie_melee_idle","wbk_zombie_melee_run","wbk_zombie_melee_walk"]): {
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
			_ifInter = [_nearEnemy, "FIRE", _unit] checkVisibility [_unit modelToWorldVisualWorld [0,0,0.7], _nearEnemy modelToWorldVisualWorld [0,0,0.7]];
			switch true do {
				case ((_ifInter >= 0.7) and (((getPosATL _unit select 2) - (getPosATL _nearEnemy select 2)) < 1.45) and (((getPosATL _unit select 2) - (getPosATL _nearEnemy select 2)) > (-1.45))): {
					_unit setVariable ["WBK_IsUnitLocked",0];
					_unit disableAI "MOVE";
					_unit disableAI "ANIM";
					doStop _unit;
					if  ((_unit distance _nearEnemy) > 2) then {
						_skeletalType = getText (configfile >> "CfgVehicles" >> typeOf _unit >> "moves");
						_currentMoveset = getText (configfile >> _skeletalType >> "States" >> animationState _unit >> "actions");
						_currentAnimationToPlay = getText (configfile >> _skeletalType >> "Actions" >> _currentMoveset >> "FastF");
						_unit playMoveNow _currentAnimationToPlay;
					}else{
						_skeletalType = getText (configfile >> "CfgVehicles" >> typeOf _unit >> "moves");
						_currentMoveset = getText (configfile >> _skeletalType >> "States" >> animationState _unit >> "actions");
						_currentAnimationToPlay = getText (configfile >> _skeletalType >> "Actions" >> _currentMoveset >> "default");
						_unit playMoveNow _currentAnimationToPlay;
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
				[_unit, selectRandom ["middle_agro_1","middle_agro_2","middle_agro_3","middle_agro_4","middle_agro_5","middle_agro_6","middle_agro_7","middle_agro_8"], 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
			};
		};
		default {
			_nearEnemy = _unit findNearestEnemy _unit; 
			_unit enableAI "MOVE";
			_unit enableAI "ANIM";
			switch true do {
				case (!(simulationEnabled _unit) || !(alive _unit) || !(isNull attachedTo _unit) || (lifeState _unit == "INCAPACITATED")): {};
				case ((isNull _nearEnemy) or !(alive _nearEnemy) or !(alive _unit) or (_unit distance _nearEnemy >= WBK_Zombies_SpecialInfected_MoveDistanceLimit)): {
					if (!(isNil {_unit getVariable "WBK_Zombie_CustomSounds"})) then {
						[_unit, selectRandom ((_unit getVariable "WBK_Zombie_CustomSounds") select 0), 30, "wbk_horde_calm_01", false] call WBK_ZombiePlayIdleSounds;
					}else{
						[_unit, selectRandom ["middle_idle_1","middle_idle_2","middle_idle_3","middle_idle_4"], 30, "wbk_horde_calm_01", false] call WBK_ZombiePlayIdleSounds;
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
						[_unit, selectRandom ["middle_agro_1","middle_agro_2","middle_agro_3","middle_agro_4","middle_agro_5","middle_agro_6","middle_agro_7","middle_agro_8"], 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
					};
				};
				case (!(isNull _nearEnemy) && (alive _nearEnemy)): {
					_unit doMove (getPosATLVisual _nearEnemy);
					_unit setVariable ["WBK_AI_LastKnownLoc",getPosATLVisual _nearEnemy];
					if (!(isNil {_unit getVariable "WBK_Zombie_CustomSounds"})) then {
						[_unit, selectRandom ((_unit getVariable "WBK_Zombie_CustomSounds") select 1), 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
					}else{
						[_unit, selectRandom ["middle_agro_1","middle_agro_2","middle_agro_3","middle_agro_4","middle_agro_5","middle_agro_6","middle_agro_7","middle_agro_8"], 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
					};
				};
				default {};
			};
		};
	};
}, selectRandom [4,5,6,7], [_unitWithSword]] call CBA_fnc_addPerFrameHandler;
_unitWithSword setVariable ["WBK_AI_AttachedHandlers", [_actFr,_loopPathfindDoMove,_loopPathfind]];