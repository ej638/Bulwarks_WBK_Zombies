_unitWithSword = _this;
if ((isPlayer _unitWithSword) or !(isNil {_unitWithSword getVariable "WBK_AI_ISZombie"}) or !(alive _unitWithSword)) exitWith {};
_unitWithSword setSpeaker "NoVoice";
_unitWithSword setUnitPos "UP";
_unitWithSword setVariable ["WBK_AI_ISZombie",true,true];
_unitWithSword setVariable ["WBK_SynthHP",WBK_Zombies_GoliathHP,true];
_unitWithSword setVariable ['IMS_IsUnitInvicibleScripted',1,true];

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

_unitWithSword addEventHandler ["Suppressed", {
params ["_unit", "_distance", "_shooter", "_instigator", "_ammoObject", "_ammoClassName", "_ammoConfig"];
_unit reveal [_instigator, 4];
}];


_unitWithSword addEventHandler ["FiredNear", {
	params ["_unit", "_firer", "_distance", "_weapon", "_muzzle", "_mode", "_ammo", "_gunner"];
	_unit reveal [_firer, 4];
}];

_unitWithSword addEventHandler ["Deleted", {
	params ["_zombie"];
	{
		_ifDelete = [_x] call CBA_fnc_removePerFrameHandler;
	} forEach (_zombie getVariable "WBK_AI_AttachedHandlers");
}];


_unitWithSword addEventHandler ["Killed",{
	{
		_ifDelete = [_x] call CBA_fnc_removePerFrameHandler;
	} forEach ((_this select 0) getVariable "WBK_AI_AttachedHandlers");
	{_x setDamage 1;} forEach nearestTerrainObjects [(_this select 0),[],13];
	(_this select 0) spawn {[_this, "Goliath_V_Death", 400, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";uiSleep 0.8; if (isNull _this) exitWith {}; [_this, "Goliath_Taunt_1", 450, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; uisleep 1; if (isNull _this) exitWith {}; [_this, "Smasher_hit", 450, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; _this spawn WBK_Smasher_CreateCamShake;};
}];


_unitWithSword addEventHandler ["AnimStateChanged", { 
	_this spawn {
		 params ["_unit", "_anim"]; 
		 switch _anim do {
				case "goliaph_staggered": {
					uiSleep 1;
					[_unit, selectRandom ["Goliath_V_Roar_1","Goliath_V_Roar_2"], 300, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				};
				case "goliaph_spikes": {
					_unit setVariable ["Goliaph_CanThrowSpikeUnderGround",1];
					_unit spawn {
						uiSleep 120; 
						_this setVariable ["Goliaph_CanThrowSpikeUnderGround",nil];
					};
					_unit spawn WBK_Smasher_CreateCamShake;
					[_unit, {
						if (isDedicated) exitWith {};
						if (player distance _this <= 100) then {
							[3] spawn BIS_fnc_earthquake;
						};
						if (player distance _this <= 50) then {
							_this say3D [selectRandom ["Goliath_V_Roar_1","Goliath_V_Roar_2"],1000];
						}else{
							_this say3D [selectRandom ["Goliath_V_Roar_Dist_1","Goliath_V_Roar_Dist_2"],2100];
						};
					}] remoteExec ["spawn",0];
					uiSleep 0.8;
					if (!(alive _unit) or !(animationState _unit == "goliaph_spikes")) exitWith {}; 
					[_unit,_anim, 5] call WBK_GoliaphProceedDamage;
					[_unit, "Goliath_Taunt_1", 245, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					_lamd = "Land_RoadCrack_01_4x4_F" createVehicle position _unit; 
					_lamd attachto [_unit,[-0.45,2.6,0]];  
					detach _lamd;
					uiSleep 0.2;
					if (!(alive _unit) or !(animationState _unit == "goliaph_spikes")) exitWith {}; 
					[_unit,_anim, 5] call WBK_GoliaphProceedDamage;
					[_unit, "Goliath_Taunt_2", 245, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					_lamd = "Land_RoadCrack_01_4x4_F" createVehicle position _unit; 
					_lamd attachto [_unit,[0.45,2.6,0]];  
					detach _lamd;
					uiSleep 0.2;
					if (!(alive _unit) or !(animationState _unit == "goliaph_spikes")) exitWith {}; 
					[_unit, "Earthquake_03", 1305, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 0.3;
					if (!(alive _unit) or !(animationState _unit == "goliaph_spikes")) exitWith {}; 
					[_unit, "Goliath_rangeAttack", 500, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 0.7;
					if (!(alive _unit) or !(animationState _unit == "goliaph_spikes")) exitWith {}; 
					_maxCanBeKilled = WBK_Zombies_GoliathMaxAmountAEO;
					{
						_ifInter = lineIntersectsSurfaces [
							aimPos _unit, 
							aimPos _x, 
							_unit,
							_x,
							true,
							1,
							"VIEW",
							"GEOM"
						];
						if (!(isObjectHidden _x) and (_x isKindOf "CAManBase") and (_maxCanBeKilled > 0) and (count _ifInter == 0) and !(_x == _unit) and (alive _unit) and (alive _x) and (animationState _x != "WBK_Smasher_Execution")) then {
							_x remoteExec ["WBK_Goliath_SpecialAttackGroundShard",_x];
							_maxCanBeKilled = _maxCanBeKilled -1;
							uiSleep (0.1 + random 0.1);
						};
					} forEach nearestObjects [_unit,["MAN"],WBK_Zombies_GoliathRadiusAEO];
				};
				case "goliaph_taunt": {
					uiSleep 0.8;
					if (!(alive _unit) or !(animationState _unit == "goliaph_taunt")) exitWith {}; 
					[_unit,_anim, 5] call WBK_GoliaphProceedDamage;
					[_unit, "Goliath_Taunt_1", 345, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					_lamd = "Land_RoadCrack_01_4x4_F" createVehicle position _unit; 
					_lamd attachto [_unit,[-0.35,2.6,0]];  
					detach _lamd;
					uiSleep 0.45;
					if (!(alive _unit) or !(animationState _unit == "goliaph_taunt")) exitWith {}; 
					[_unit,_anim, 5] call WBK_GoliaphProceedDamage;
					[_unit, "Goliath_Taunt_2", 345, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 0.35;
					if (!(alive _unit) or !(animationState _unit == "goliaph_taunt")) exitWith {}; 
					_unit spawn WBK_Smasher_CreateCamShake;
					[_unit, {
						if (isDedicated) exitWith {};
						if (player distance _this <= 40) then {
							_this say3D [selectRandom ["Goliath_V_Roar_1","Goliath_V_Roar_2"],1000];
						}else{
							_this say3D [selectRandom ["Goliath_V_Roar_Dist_1","Goliath_V_Roar_Dist_2"],2100];
						};
					}] remoteExec ["spawn",0];
				};
				case "goliaph_melee_1": {
					uiSleep 1;
					if (!(alive _unit) or !(animationState _unit == "goliaph_melee_1")) exitWith {}; 
					[_unit,_anim, 5] call WBK_GoliaphProceedDamage;
				};
				case "goliaph_melee_2": {
					uiSleep 1;
					if (!(alive _unit) or !(animationState _unit == "goliaph_melee_2")) exitWith {}; 
					[_unit, selectRandom ["Goliath_V_Roar_1","Goliath_V_Roar_2"], 300, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					[_unit,_anim, 8] call WBK_GoliaphProceedDamage;
					_lamd = "Land_RoadCrack_01_4x4_F" createVehicle position _unit; 
					_lamd attachto [_unit,[-0.35,2.6,0]];  
					detach _lamd;
					[_lamd, {
						if (isDedicated) exitWith {};
						_aslLoc = _this;
							_col = [0,0,0];
							_c1 = _col select 0;
							_c2 = _col select 1;
							_c3 = _col select 2;
							_rocks1 = "#particlesource" createVehicleLocal getPosAsl _aslLoc;
							_rocks1 setposasl getPosAsl _aslLoc;
							_rocks1 setParticleParams [["\A3\data_f\ParticleEffects\Universal\Mud.p3d", 1, 0, 1], "", "SpaceObject", 1, 12.5, [0, 0, 0], [0, 0, 15], 5, 100, 7.9, 1, [.45, .45], [[0.1, 0.1, 0.1, 1], [0.25, 0.25, 0.25, 0.5], [0.5, 0.5, 0.5, 0]], [0.08], 1, 0, "", "", _aslLoc,0,false,0.3];
							_rocks1 setParticleRandom [0, [1, 1, 0], [20, 20, 15], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
							_rocks1 setDropInterval 0.01;
							_rocks1 setParticleCircle [0, [0, 0, 0]];

							_rocks2 = "#particlesource" createVehicleLocal getPosAsl _aslLoc;
							_rocks2 setposasl getPosAsl _aslLoc;
							_rocks2 setParticleParams [["\A3\data_f\ParticleEffects\Universal\Mud.p3d", 1, 0, 1], "", "SpaceObject", 1, 12.5, [0, 0, 0], [0, 0, 15], 5, 100, 7.9, 1, [.27, .27], [[0.1, 0.1, 0.1, 1], [0.25, 0.25, 0.25, 0.5], [0.5, 0.5, 0.5, 0]], [0.08], 1, 0, "", "", _aslLoc,0,false,0.3];
							_rocks2 setParticleRandom [0, [1, 1, 0], [25, 25, 15], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
							_rocks2 setDropInterval 0.01;
							_rocks2 setParticleCircle [0, [0, 0, 0]];

							_rocks3 = "#particlesource" createVehicleLocal getPosAsl _aslLoc;
							_rocks3 setposasl getPosAsl _aslLoc;
							_rocks3 setParticleParams [["\A3\data_f\ParticleEffects\Universal\Mud.p3d", 1, 0, 1], "", "SpaceObject", 1, 12.5, [0, 0, 0], [0, 0, 15], 5, 100, 7.9, 1, [.09, .09], [[0.1, 0.1, 0.1, 1], [0.25, 0.25, 0.25, 0.5], [0.5, 0.5, 0.5, 0]], [0.08], 1, 0, "", "", _aslLoc,0,false,0.3];
							_rocks3 setParticleRandom [0, [1, 1, 0], [30, 30, 15], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
							_rocks3 setDropInterval 0.01;
							_rocks3 setParticleCircle [0, [0, 0, 0]];
							_rocks = [_rocks1,_rocks2, _rocks3];
							uisleep 0.3;
							{
								deletevehicle _x;
							} foreach _rocks;
				}] remoteExec ["spawn", [0,-2] select isDedicated,false];
				};
				case "goliaph_melee_3": {
					uiSleep 0.8;
					if (!(alive _unit) or !(animationState _unit == "goliaph_melee_3")) exitWith {}; 
					[_unit, selectRandom ["Goliath_V_Roar_1","Goliath_V_Roar_2"], 300, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					[_unit,_anim, 7] call WBK_GoliaphProceedDamage;
					_lamd = "Land_RoadCrack_01_4x4_F" createVehicle position _unit; 
					_lamd attachto [_unit,[-0.35,2.6,0]];  
					detach _lamd;
					[_lamd, {
						if (isDedicated) exitWith {};
						_aslLoc = _this;
							_col = [0,0,0];
							_c1 = _col select 0;
							_c2 = _col select 1;
							_c3 = _col select 2;
							_rocks1 = "#particlesource" createVehicleLocal getPosAsl _aslLoc;
							_rocks1 setposasl getPosAsl _aslLoc;
							_rocks1 setParticleParams [["\A3\data_f\ParticleEffects\Universal\Mud.p3d", 1, 0, 1], "", "SpaceObject", 1, 12.5, [0, 0, 0], [0, 0, 15], 5, 100, 7.9, 1, [.45, .45], [[0.1, 0.1, 0.1, 1], [0.25, 0.25, 0.25, 0.5], [0.5, 0.5, 0.5, 0]], [0.08], 1, 0, "", "", _aslLoc,0,false,0.3];
							_rocks1 setParticleRandom [0, [1, 1, 0], [20, 20, 15], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
							_rocks1 setDropInterval 0.01;
							_rocks1 setParticleCircle [0, [0, 0, 0]];

							_rocks2 = "#particlesource" createVehicleLocal getPosAsl _aslLoc;
							_rocks2 setposasl getPosAsl _aslLoc;
							_rocks2 setParticleParams [["\A3\data_f\ParticleEffects\Universal\Mud.p3d", 1, 0, 1], "", "SpaceObject", 1, 12.5, [0, 0, 0], [0, 0, 15], 5, 100, 7.9, 1, [.27, .27], [[0.1, 0.1, 0.1, 1], [0.25, 0.25, 0.25, 0.5], [0.5, 0.5, 0.5, 0]], [0.08], 1, 0, "", "", _aslLoc,0,false,0.3];
							_rocks2 setParticleRandom [0, [1, 1, 0], [25, 25, 15], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
							_rocks2 setDropInterval 0.01;
							_rocks2 setParticleCircle [0, [0, 0, 0]];

							_rocks3 = "#particlesource" createVehicleLocal getPosAsl _aslLoc;
							_rocks3 setposasl getPosAsl _aslLoc;
							_rocks3 setParticleParams [["\A3\data_f\ParticleEffects\Universal\Mud.p3d", 1, 0, 1], "", "SpaceObject", 1, 12.5, [0, 0, 0], [0, 0, 15], 5, 100, 7.9, 1, [.09, .09], [[0.1, 0.1, 0.1, 1], [0.25, 0.25, 0.25, 0.5], [0.5, 0.5, 0.5, 0]], [0.08], 1, 0, "", "", _aslLoc,0,false,0.3];
							_rocks3 setParticleRandom [0, [1, 1, 0], [30, 30, 15], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
							_rocks3 setDropInterval 0.01;
							_rocks3 setParticleCircle [0, [0, 0, 0]];
							_rocks = [_rocks1,_rocks2, _rocks3];
							uisleep 0.3;
							{
								deletevehicle _x;
							} foreach _rocks;
				}] remoteExec ["spawn", [0,-2] select isDedicated,false];
				};
				case "goliaph_melee_run_1": {
					uiSleep 0.4;
					if (!(alive _unit) or !(animationState _unit == "goliaph_melee_run_1")) exitWith {}; 
					[_unit,_anim, 5] call WBK_GoliaphProceedDamage;
				};
		 };
	};
}];



_hitbox = "Goliath_HitBox" createVehicle getPos _unitWithSword;
_hitbox attachTo [_unitWithSword,[0,-1.5,-0.6],"pilot"];
_hitbox setVariable ["WBK_CustomHitboxOriginalTarget",_unitWithSword,true];
[_hitbox, {
_this removeAllEventHandlers "HitPart";
_this addEventHandler [
    "HitPart",
    {
		(_this select 0) params ["_hitbox","_shooter","_bullet","_position","_velocity","_selection","_ammo","_direction","_radius","_surface","_direct"];
		_target = _hitbox getVariable "WBK_CustomHitboxOriginalTarget";
		if ((_target == _shooter) or (isNull _shooter) or !(alive _target) or (animationState _target == "Goliaph_Staggered") or (animationState _target == "Goliaph_Throw") or (animationState _target == "Goliaph_Taunt") or (animationState _target == "Goliaph_VehicleGrab") or (animationState _target == "Goliaph_RockThrow") or (animationState _target == "Goliaph_Spikes") or (animationState _target == "Goliaph_Sync_1") or (animationState _target == "Goliaph_Sync_2")) exitWith {};
		_isExplosive = _ammo select 3;
		_isEnoughDamage = _ammo select 0;
		if !(isNil "WBK_ZombiesShowDebugDamage") then {
        systemChat str _isEnoughDamage;
		};
		if ( (_isEnoughDamage >= 300) and (isNil {_target getVariable "CanBeStunnedIMS"})) exitWith {
			[_target, "Goliaph_Staggered"] remoteExec ["switchMove", 0]; 
			[_target, "Goliaph_Walk"] remoteExec ["playMove", 0]; 
			_target setVariable ["CanBeStunnedIMS",1,true]; 
			_target spawn {uisleep 90; _this setVariable ["CanBeStunnedIMS",nil,true];};
			_vv = _target getVariable "WBK_SynthHP";
			_new_vv = _vv - _isEnoughDamage;
			if (_new_vv <= 0) exitWith {_target removeAllEventHandlers "HitPart"; _target setDamage 1;};
			_target setVariable ["WBK_SynthHP",_new_vv,true];
		};
		_vv = _target getVariable "WBK_SynthHP";
		_new_vv = _vv - _isEnoughDamage;
		if (_new_vv <= 0) exitWith {_target removeAllEventHandlers "HitPart"; _target setDamage 1;};
		_target setVariable ["WBK_SynthHP",_new_vv,true];
	}
];
}] remoteExec ["spawn",0,true];




if !(WBK_Zombies_GoliatPickUpAbil) then {
	_unitWithSword setVariable ["CanThrowVic",0];
};
if !(WBK_Zombies_GoliatUndergroundAbil) then {
	_unitWithSword setVariable ["Goliaph_CanThrowSpikeUnderGround",0];
};
if !(WBK_Zombies_GoliatSpearAbil) then {
	_unitWithSword setVariable ["Goliaph_CanThrowSpike",0];
};
if !(WBK_Zombies_GoliatRockAbil) then {
	_unitWithSword setVariable ["CanThrowRocks",0];
};


uiSleep 0.2;




_actFr = [{
    _array = _this select 0;
    _mutant = _array select 0;
	if ((animationState _mutant == "Goliaph_VehicleGrab") or (animationState _mutant == "Goliaph_Staggered") or (animationState _mutant == "Goliaph_RockThrow") or (animationState _mutant == "Goliaph_Spikes") or (animationState _mutant == "Goliaph_Sync_2") or (animationState _mutant == "Goliaph_Sync_1") or (animationState _mutant == "Goliaph_Throw") or (animationState _mutant == "Goliaph_Melee_Run_1") or (animationState _mutant == "Goliaph_Taunt") or (animationState _mutant == "Goliaph_Melee_3") or (animationState _mutant == "Goliaph_Melee_2") or (animationState _mutant == "Goliaph_Melee_1") or !(isTouchingGround _mutant) or !(alive _mutant) or !(isNull attachedTo _mutant) or (lifeState _mutant == "INCAPACITATED")) exitWith {};
	{ 
		_mutant reveal [_x, 4]; 
	} forEach nearestObjects [_mutant, ["Man"], 50];  
	_mutant allowDamage false;
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
	if (animationState _mutant == "Goliaph_Run" || animationState _mutant == "Goliaph_Walk") then {
		{_x setDamage 1;} forEach nearestTerrainObjects [_mutant,[],9];
		{_x setDamage 1;} forEach nearestObjects [_mutant,["Static"],9];
	};
	switch true do {
		case (((_mutant distance _en) <= 7) && !((vehicle _en) isKindOf "MAN") && (isNil {_mutant getVariable "CanThrowVic"})): {[_mutant,(vehicle _en)] spawn WBK_Goliaph_ThrowAVehicle;};
		case (((_mutant distance _en) >= 30) and ((_mutant distance _en) <= 350) && (isNil {_mutant getVariable "CanThrowRocks"})): {_mutant spawn WBK_Goliph_RockThrowingAbility;};
		case (((_mutant distance _en) <= 7) && ((vehicle _en) isKindOf "TANK")): {[_mutant, selectRandom ["Goliath_V_Attack_1","Goliath_V_Attack_2","Goliath_V_Attack_3","Goliath_V_Attack_4"], 545, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; [_mutant, selectRandom ["Goliaph_Melee_1","Goliaph_Melee_2","Goliaph_Melee_3"]] remoteExec ["switchMove",0]; [_mutant, "Goliaph_Walk"] remoteExec ["playMoveNow",0];};
		case (((_mutant distance _en) <= 30) && (isNil {_mutant getVariable "Goliaph_CanThrowSpikeUnderGround"}) && ((vehicle _en) isKindOf "MAN")): {
			[_mutant, "Goliaph_Spikes"] remoteExec ["switchMove",0]; 
			[_mutant, "Goliaph_Walk"] remoteExec ["playMoveNow",0];  
		};
		case ( (((_mutant distance _en) > 10) && ((_mutant distance _en) <= 600) && (isNil {_mutant getVariable "Goliaph_CanThrowSpike"})) || ((vehicle _en) isKindOf "AIR")): {
			_mutant spawn WBK_Goliaph_ThrowSpike;
		};
		case (((_mutant distance _en) <= 130) && (isNil {_mutant getVariable "Goliaph_CanTaunt"})): {[_mutant, "Goliaph_Taunt"] remoteExec ["switchMove",0];  [_mutant, "Goliaph_Walk"] remoteExec ["playMoveNow",0]; _mutant setVariable ["Goliaph_CanTaunt",1]; _mutant spawn {uiSleep 120; _this setVariable ["Goliaph_CanTaunt",nil];};};
		case (((_mutant distance _en) <= 4.5) && (isNil {_mutant getVariable "Goliaph_CanSyncMelee"}) && ((vehicle _en) isKindOf "MAN") && ((getText (configfile >> 'CfgVehicles' >> typeOf _en >> 'moves') == 'CfgMovesMaleSdr') or (getText (configfile >> 'CfgVehicles' >> typeOf _en >> 'moves') == 'CfgMovesMaleSpaceMarine'))): {[_mutant, _en] spawn selectRandom [WBK_Goliaph_SyncAnim_1,WBK_Goliaph_SyncAnim_2]; _mutant setVariable ["Goliaph_CanSyncMelee",1]; _mutant spawn {uiSleep 30; _this setVariable ["Goliaph_CanSyncMelee",nil];};};
		case (((_mutant distance _en) <= 4.4) && (animationState _mutant != "Goliaph_Run")): {[_mutant, selectRandom ["Goliath_V_Attack_1","Goliath_V_Attack_2","Goliath_V_Attack_3","Goliath_V_Attack_4"], 545, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; [_mutant, selectRandom ["Goliaph_Melee_1","Goliaph_Melee_2","Goliaph_Melee_3"]] remoteExec ["switchMove",0]; [_mutant, "Goliaph_Walk"] remoteExec ["playMoveNow",0];};
		case (((_mutant distance _en) > 4.4) && ((_mutant distance _en) <= 7.8) && (animationState _mutant == "Goliaph_Run") && ((vehicle _en) isKindOf "MAN")): {[_mutant, selectRandom ["Goliath_V_Attack_1","Goliath_V_Attack_2","Goliath_V_Attack_3","Goliath_V_Attack_4"], 545, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; [_mutant, "Goliaph_Melee_Run_1"] remoteExec ["switchMove",0]; [_mutant, "Goliaph_Run"] remoteExec ["playMoveNow",0];};
		default {};
	};
}, 0.5, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;

_loopPathfind = [{
    _array = _this select 0;
    _unit = _array select 0;
	_isStriderTaked = missionNamespace getVariable["bis_fnc_moduleRemoteControl_unit", player];
	if ((_unit == _isStriderTaked) || (animationState _unit == "Goliaph_VehicleGrab") || (animationState _unit == "Goliaph_Spikes") || (animationState _unit == "Goliaph_Sync_1") || (animationState _unit == "Goliaph_Sync_2")) exitWith {};
	_nearEnemy = _unit findNearestEnemy _unit; 
	if ((isNull _nearEnemy) or !(alive _nearEnemy) or !(alive _unit) or !(isNull attachedTo _unit) or (lifeState _unit == "INCAPACITATED") or (_unit distance _nearEnemy >= WBK_Zombies_Goliath_MoveDistanceLimit)) exitWith {
		_unit setVariable ["WBK_IsUnitLocked",nil];
	};
	if (animationState _unit in ["goliaph_melee_1","goliaph_melee_2","goliaph_melee_3","goliaph_melee_run_1","goliaph_taunt","goliaph_staggered"]) exitWith {
		_unit setVariable ["WBK_IsUnitLocked",0];
		_unit enableAI "ANIM";
		_unit enableAI "MOVE";
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
      (
	  (count _ifInter == 0) and 
	  (_result1 < 1.45) and
	  (_result1 > (-1.45)) and
	  !(lifeState _unit == "INCAPACITATED")) || (animationState _unit == "Goliaph_Throw") || (animationState _unit == "Goliaph_RockThrow")
      ) exitWith {
		_unit setVariable ["WBK_IsUnitLocked",0];
	    _unit disableAI "MOVE";
	    _unit disableAI "ANIM";
		doStop _unit;
		if  ((_unit distance _nearEnemy) > 4.3) then {
			_unit playMoveNow "Goliaph_Run";
		}else{
			_unit playMoveNow "Goliaph_Idle_1";
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
}, 0.01, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;


_loopPathfindDoMove = [{
    _array = _this select 0;
    _unit = _array select 0;
	_nearEnemy = _unit findNearestEnemy _unit; 
	if (isNil {_unit getVariable "Goliath_CanIdle"}) then {
		_unit setVariable ["Goliath_CanIdle",1]; _unit spawn {uiSleep (5 + random 5); _this setVariable ["Goliath_CanIdle",nil];};
		[_unit, selectRandom ["Goliath_V_idle_1","Goliath_V_idle_2","Goliath_V_idle_3","Goliath_V_idle_4","Goliath_V_idle_5","Goliath_V_idle_6"], 395, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	};
	if ((animationState _unit == "Goliaph_VehicleGrab") or (animationState _unit == "Goliaph_Staggered") or (animationState _unit == "Goliaph_RockThrow") or (animationState _unit == "Goliaph_Spikes") or (animationState _unit == "Goliaph_Sync_2") or (animationState _unit == "Goliaph_Sync_1") or (animationState _unit == "Goliaph_Throw") or (animationState _unit == "Goliaph_Taunt") or (animationState _unit == "Goliaph_Melee_Run_1") or (animationState _unit == "Goliaph_Melee_3") or (animationState _unit == "Goliaph_Melee_2") or (animationState _unit == "Goliaph_Melee_1") or !(isNil {_unit getVariable "WBK_IsUnitLocked"})) exitWith {};
		_unit enableAI "MOVE";
		_unit enableAI "ANIM";
		if ((isNull _nearEnemy) or !(alive _nearEnemy) or !(alive _unit)) exitWith {};
		_pos = ASLtoAGL getPosASLVisual _nearEnemy;
		_unit doMove _pos;
}, 2.4, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;
_unitWithSword setVariable ["WBK_AI_AttachedHandlers", [_actFr,_loopPathfindDoMove,_loopPathfind]];