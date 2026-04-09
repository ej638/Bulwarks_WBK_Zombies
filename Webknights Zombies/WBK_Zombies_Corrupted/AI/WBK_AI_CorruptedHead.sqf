_unitWithSword = _this;
if ((isPlayer _unitWithSword) or !(isNil {_unitWithSword getVariable "WBK_AI_ISZombie"}) or !(alive _unitWithSword)) exitWith {};
_unitWithSword setUnitPos "UP";
_unitWithSword setVariable ["WBK_AI_ISZombie",true,true];
_unitWithSword setSpeaker "NoVoice";
_unitWithSword disableConversation true;
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


_unitWithSword addEventHandler ["AnimStateChanged", {
	_this spawn {
		 params ["_unit", "_anim"]; 
		 switch _anim do {
				case "corrupted_attack": {
					uiSleep 0.8;
					if (animationState _unit != "corrupted_attack") exitWith {};
					[_unit, selectRandom ["melee_whoosh_00","melee_whoosh_01","melee_whoosh_02"], 35, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 0.1;
					if (animationState _unit != "corrupted_attack") exitWith {};
					_enemy = _unit findNearestEnemy _unit;
					if ((isNil {_enemy getVariable "WBK_AI_ISZombie"}) && (isNil {_enemy getVariable "IMS_IsUnitInvicibleScripted"}) && (animationState _enemy != "Corrupted_Attack_victim") && (alive _unit) && (alive _enemy) && ((_unit distance _enemy) <= 2)) then {
						[_unit,_enemy] spawn WBK_CorruptedAttack_success;
					};
				};
				case "corrupted_attack_far": {
					uiSleep 0.5;
					if (animationState _unit != "corrupted_attack_far") exitWith {};
					[_unit, selectRandom ["melee_whoosh_00","melee_whoosh_01","melee_whoosh_02"], 35, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 0.1;
					if (animationState _unit != "corrupted_attack_far") exitWith {};
					_enemy = _unit findNearestEnemy _unit;
					if ((isNil {_enemy getVariable "WBK_AI_ISZombie"}) && (isNil {_enemy getVariable "IMS_IsUnitInvicibleScripted"}) && (animationState _enemy != "Corrupted_Attack_victim") && (alive _unit) && (alive _enemy) && ((_unit distance _enemy) <= 2)) then {
						[_unit,_enemy] spawn WBK_CorruptedAttack_success;
					};
				};
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
}];

_unitWithSword addEventHandler ["HandleDamage", {
	_unit = _this select 0;
	_hitter = _this select 3;
	if !(_unit == _hitter) then {
		_unit setDamage ((damage _unit) + 0.5);
	};
}];

_actFr = [{
    _array = _this select 0;
    _mutant = _array select 0;
	_mutant allowDamage false;
	if (
	!(simulationEnabled _mutant) || 
	!(isTouchingGround _mutant) || 
	!(alive _mutant) ||
	!(isNull attachedTo _mutant) ||
	(lifeState _mutant == "INCAPACITATED") ||
	!(animationState _mutant in ["corrupted_idle","corrupted_run","corrupted_turn_l","corrupted_turn_r","corrupted_walk"])
	) exitWith {};
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
		if (((_en distance _mutant) <= 2) and !(isNil {_mutant getVariable "WBK_IsUnitLocked"})) then {
			[_mutant, selectRandom ["Corrupted_Attack","Corrupted_Attack_Far"]] remoteExec ["switchMove",0];
		};
	};
}, 0.3, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;

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
		case !(animationState _unit in ["corrupted_idle","corrupted_run","corrupted_turn_l","corrupted_turn_r","corrupted_walk"]): {
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
				[_unit, selectRandom ["corrupted_head_idle_1","corrupted_head_idle_2"], 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
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
						[_unit, selectRandom ["corrupted_head_idle_1","corrupted_head_idle_2"], 30, "wbk_horde_calm_01", false] call WBK_ZombiePlayIdleSounds;
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
						[_unit, selectRandom ["corrupted_head_idle_1","corrupted_head_idle_2"], 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
					};
				};
				case (!(isNull _nearEnemy) && (alive _nearEnemy)): {
					_unit doMove (getPosATLVisual _nearEnemy);
					_unit setVariable ["WBK_AI_LastKnownLoc",getPosATLVisual _nearEnemy];
					if (!(isNil {_unit getVariable "WBK_Zombie_CustomSounds"})) then {
						[_unit, selectRandom ((_unit getVariable "WBK_Zombie_CustomSounds") select 1), 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
					}else{
						[_unit, selectRandom ["corrupted_head_idle_1","corrupted_head_idle_2"], 50, "wbk_horde_01", true] call WBK_ZombiePlayIdleSounds;
					};
				};
				default {};
			};
		};
	};
}, selectRandom [4,5,6,7], [_unitWithSword]] call CBA_fnc_addPerFrameHandler;
_unitWithSword setVariable ["WBK_AI_AttachedHandlers", [_actFr,_loopPathfindDoMove,_loopPathfind]];