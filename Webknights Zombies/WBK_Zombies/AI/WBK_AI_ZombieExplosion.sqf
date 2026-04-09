params ["_unitWithSword"];
if is3DEN exitWith {
	systemChat "Zombie AI loaded on this unit";
};
if ((isPlayer _unitWithSword) or !(isNil {_unitWithSword getVariable "WBK_AI_ISZombie"}) or !(alive _unitWithSword)) exitWith {};
removeAllWeapons _unitWithSword;
removeAllItems _unitWithSword;
removeAllAssignedItems _unitWithSword;
removeUniform _unitWithSword;
removeVest _unitWithSword;
removeBackpack _unitWithSword;
removeHeadgear _unitWithSword;
removeGoggles _unitWithSword;
_unitWithSword forceAddUniform "WBK_SpecialInfected_Bloater";
_unitWithSword setUnitPos "UP";
_unitWithSword setVariable ["WBK_AI_ISZombie",true,true];
[_unitWithSword, "WBK_Middle_Idle"] remoteExec ["switchMove", 0];
_unitWithSword setVariable ["WBK_AI_ZombieMoveSet","WBK_Middle_Idle", true];
_unitWithSword setVariable ["WBK_SynthHP",WBK_Zombies_BloaterHP,true];
_unitWithSword setSpeaker "NoVoice";
_unitWithSword disableConversation true;
_unitWithSword setCombatMode "BLUE";
_unitWithSword enableAttack false;

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
	[(_this select 0), "blower_dead", 60, 7] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	(_this select 0) spawn {
		uiSleep (0.3 + random 0.1);
		if ((isNull _this) || (isHidden _this)) exitWith {};
		[_this, selectRandom ["zombie_fall_1","zombie_fall_2","zombie_fall_3"], 50, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
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
					[_unit,0.1,2] call WBK_ZombieAttackDamage;
				};
				case "wbk_walker_idle_1_attack": {
					uiSleep 0.6;
					if (animationState _unit != "wbk_walker_idle_1_attack") exitWith {};
					[_unit,0.1,2] call WBK_ZombieAttackDamage;
				};
				case "wbk_walker_idle_2_attack": {
					uiSleep 0.6;
					if (animationState _unit != "wbk_walker_idle_2_attack") exitWith {};
					[_unit,0.1,2] call WBK_ZombieAttackDamage;
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
				[_target, selectRandom ["WBK_Middle_Fall_Back","WBK_Middle_Fall_Forward"]] remoteExec ["switchMove", 0]; 
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
	!(animationState _mutant in ["wbk_crawler_idle","wbk_crawler_walk","wbk_middle_idle","wbk_middle_idle_1","wbk_middle_run","wbk_middle_run_1"])
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
		if (((_en distance _mutant) <= 4) and !(isNil {_mutant getVariable "WBK_IsUnitLocked"}) and !(gestureState _mutant in ["wbk_zombie_attack_left","wbk_zombie_attack_right"])) then {
			if (!(isNil {_mutant getVariable "WBK_Zombie_CustomSounds"})) then {
				[_mutant, selectRandom ((_mutant getVariable "WBK_Zombie_CustomSounds") select 2), 90, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
			}else{
				[_mutant, selectRandom ["blower_blow_1","blower_blow_2"], 90, 7] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
			};
			_mutant spawn {
				_this playActionNow selectRandom ["wbk_zombie_attack_left","wbk_zombie_attack_right"];
				uiSleep 0.5;
				if (!(gestureState _this in ["wbk_zombie_attack_left","wbk_zombie_attack_right"]) or !(alive _this)) exitWith {};
				_mine = createMine ["APERSMine",unitAimPosition _this, [], 0];
				_mine setDamage 1;
				_this setDamage 1;
				[_this, "blower_explode", 400, 7] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				{
					_ins = lineIntersectsSurfaces [
						eyePos _this,
						eyePos _x,
						_this,
						_x,
						true,
						1,
						"GEOM",
						"NONE"
					];
					if (!(_x == _this) and (isNil {_x getVariable "WBK_AI_ISZombie"}) and (alive _x) and (isNil {_x getVariable "IMS_IsUnitInvicibleScripted"}) and (count _ins == 0)) then {
						[_x, 0.2, _this] remoteExec ["WBK_CreateDamage", _x, false];  
						if (isNil "WBK_IsPresent_DAH") then {
							[_x, [_this vectorModelToWorld [0,200,30], _x selectionPosition "head",false]] remoteExec ["addForce", _x];
						};
					};
				} forEach nearestObjects [_this,["MAN"],7];
				[_this, {
					_object = _this;
					if (isDedicated) exitWith {};
					_deathBlood = "BloodPool_01_Large_New_F" createVehicleLocal getPosATL _object;
					_deathBlood setPosATL (getPosATL _object);
					_deathBlood setVectorUp surfaceNormal getposatl _deathBlood;
					_t1 = "BloodTrail_01_New_F" createVehicleLocal getPosATL _deathBlood;
					_t2 = "BloodTrail_01_New_F" createVehicleLocal getPosATL _deathBlood;
					_t3 = "BloodTrail_01_New_F" createVehicleLocal getPosATL _deathBlood;
					_t4 = "BloodTrail_01_New_F" createVehicleLocal getPosATL _deathBlood;
					_t1 attachTo [_deathBlood,[2.5,1.4,0]]; 
					detach _t1; 
					_t1 setDir 70; 
					_t2 attachTo [_deathBlood,[-2.5,-1.4,0]]; 
					detach _t2; 
					_t2 setDir 70; 
					_t3 attachTo [_deathBlood,[2.1,-2.3,0]];  
					detach _t3;  
					_t3 setDir 140; 
					_t4 attachTo [_deathBlood,[-2.1,2.3,0]];   
					detach _t4;   
					_t4 setDir 140; 
					_object hideObject true;
					_electra1 = "#particlesource" createVehicleLocal position _object;  
					_electra1 setParticleClass "VehExpSmokeSmall"; 
					_electra2 = "#particlesource" createVehicleLocal position _object;  
					_electra2 setParticleClass "MineExplosionParticles";
					_blood = "#particlesource" createVehicleLocal (getposATL _object);          
					_blood attachTo [_object,[0,0,0],"pelvis"];  
					_blood setParticleParams [ 
							["\a3\Data_f\ParticleEffects\Universal\Universal", 16, 13, 1, 32],            
							"",         
							"billboard",    
							0.1, 2,         
							[0, 0, 0],     
							[0,0, 4],         
							5, 6, 0.4, 0.4,         
							[0.05, 1.4],        
							[[0.5,0,0,1], [1,0,0,0.4], [0.1,0,0,0.03]],    
							[0.00001],    
							0.4,    
							0.4,    
							"",    
							"",    
							"",   
							360,           
							false,            
							0.4
						];  
					_blood setParticleRandom [0.5, [0, 0, 0], [5.25, 5.25, 2.25], 1, 0.5, [0, 0, 0, 0.1], 0, 0, 10];    
					_blood setdropinterval 0.01;  
					_breath = "#particlesource" createVehicleLocal (getposATL _object);                      
					_breath setParticleParams            
						[            
							["\a3\Data_f\ParticleEffects\Universal\meat_ca", 1, 0, 1],      
							"",          
							"spaceObject",        
							0.5, 12,        
							[0, 0, 0],    
							[0, 0, random 3],
							1,1.275,0.2,0,          
							[5.6,0],     
							[[0.005,0,0,0.05], [0.006,0,0,0.06], [0.2,0,0,0]],      
							[1000],     
							1,         
							0.1,        
							"",    
							"",     
							"",         
							0,       
							false,          
							0.1          
						];            
					_breath setParticleRandom [0.5, [0, 0, 0], [5.25, 5.25, 2.25], 1, 0.5, [0, 0, 0, 0.1], 0, 0, 10];      
					_breath setDropInterval 0.01;            
					_breath attachTo [_object,[0,0,0.2], "pelvis"];  
					uisleep 0.3;
					deleteVehicle _breath; 
					deleteVehicle _electra1;
					deleteVehicle _electra2;
					uisleep 0.6;
					deleteVehicle _blood; 
				}] remoteExec ["spawn",0];
				uiSleep 10;
				deleteVehicle _this;
			};
		};
	};
}, 0.3, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;

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
		case !(animationState _unit in ["wbk_crawler_idle","wbk_crawler_walk","wbk_middle_idle","wbk_middle_idle_1","wbk_middle_run","wbk_middle_run_1"]): {
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
			[_unit, selectRandom ((_unit getVariable "WBK_Zombie_CustomSounds") select 0), 70] call CBA_fnc_GlobalSay3D;
			}else{
				[_unit, selectRandom ["blower_scream_1","blower_scream_2"], 70] call CBA_fnc_GlobalSay3D;
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
						[_unit, selectRandom ["blower_scream_1","blower_scream_2"], 30, "wbk_horde_calm_01", false] call WBK_ZombiePlayIdleSounds;
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
						[_unit, selectRandom ["blower_scream_1","blower_scream_2"], 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
					};
				};
				case (!(isNull _nearEnemy) && (alive _nearEnemy)): {
					_unit doMove (getPosATLVisual _nearEnemy);
					_unit setVariable ["WBK_AI_LastKnownLoc",getPosATLVisual _nearEnemy];
					if (!(isNil {_unit getVariable "WBK_Zombie_CustomSounds"})) then {
						[_unit, selectRandom ((_unit getVariable "WBK_Zombie_CustomSounds") select 1), 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
					}else{
						[_unit, selectRandom ["blower_scream_1","blower_scream_2"], 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
					};
				};
				default {};
			};
		};
	};
}, selectRandom [4,5,6,7], [_unitWithSword]] call CBA_fnc_addPerFrameHandler;
_unitWithSword setVariable ["WBK_AI_AttachedHandlers", [_actFr,_loopPathfindDoMove,_loopPathfind]];