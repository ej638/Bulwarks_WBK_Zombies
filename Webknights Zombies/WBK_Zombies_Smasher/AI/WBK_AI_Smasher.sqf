_unitWithSword = _this;
if ((isPlayer _unitWithSword) or !(isNil {_unitWithSword getVariable "WBK_AI_ISZombie"}) or !(alive _unitWithSword)) exitWith {};
sleep 0.1;
_unitWithSword setUnitPos "UP";
_unitWithSword setVariable ["WBK_AI_ISZombie",0, true];
_unitWithSword setSpeaker "NoVoice";
_unitWithSword disableConversation true;
_unitWithSword setVariable ["WBK_AI_ZombieMoveSet","WBK_Smasher_Idle",true];


if !(isNil "WBK_IsPresent_Necroplague") then {
	_unitWithSword setVariable ['isMutant',true];
};
if !(isNil "WBK_IsPresent_PIR") then {
	_unitWithSword setVariable ["dam_ignore_hit0",true,true];
	_unitWithSword setVariable ["dam_ignore_effect0",true,true];
};


switch true do {
	case (_unitWithSword isKindOf "WBK_SpecialZombie_Smasher_Acid_1"): {
		_unitWithSword setVariable ["WBK_SynthHP",WBK_Zombies_SmasherHP_Acid,true];
		[_unitWithSword,{
			_fulgi  = "#particlesource" createVehiclelocal getposaTL _this; 
			_fulgi setParticleRandom [0,[0.2,0.2,0],[0.5,0.5,0.2],1,0,[0,0,0,0.1],1,1];
			_fulgi setDropInterval 0.1;
			_fulgi setParticleCircle [3,[0,0,0]];
			_fulgi setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1],"","Billboard",1,14,[0,0,1],[0,0,0.5],13,1.3,1,0,[0.1],[[0.01,1,0.1,1]],[1],0,0,"","",_this, 0, false, 0.1, [[0.01,100,0.005,1],[0.01,100,0.005,1],[0.01,100,0.005,1]]];
			_fulgi attachTo [_this,[0,0,0]];
			_smlfirelight = "#lightpoint" createVehicleLocal (getpos _this);
			_smlfirelight setPosATL (getPosATL _this);
			_smlfirelight setLightAmbient [0.3, 1, 0]; 
			_smlfirelight setLightColor [0.3, 1, 0]; 
			_smlfirelight setLightBrightness 0.2;
			_smlfirelight setLightUseFlare false;
			_smlfirelight setLightDayLight true;
			_smlfirelight attachTo [_this,[0,0,0],"Smash_Pelvis"];
			while {alive _this} do {
			_fulgi say3D ["smasher_idle_acid",50];
			uiSleep 9.8;
			};
			deleteVehicle _fulgi;
			deleteVehicle _smlfirelight;
	   }] remoteExec ["spawn",0];
	};
	case (_unitWithSword isKindOf "WBK_SpecialZombie_Smasher_Hellbeast_1"): {
		_unitWithSword setVariable ["WBK_SynthHP",WBK_Zombies_SmasherHP_Hell,true];
	};
	default {_unitWithSword setVariable ["WBK_SynthHP",WBK_Zombies_SmasherHP,true];};
};


if !(WBK_Zombies_SmasherRockAbil) then {
	_unitWithSword setVariable ["CanThrowRocks",0];
};
if !(WBK_Zombies_SmasherFlyAbil) then {
	_unitWithSword setVariable ["CanFly",0];
};




_unitWithSword addEventHandler ["AnimStateChanged", { 
	_this spawn {
		 params ["_unit", "_anim"]; 
		 switch _anim do {
				case "wbk_smasher_hithard": {
					[_unit, "Smasher_eat_voice", 120, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				};
				case "wbk_smasher_roar": {
					_unit setVariable ["WBK_CanMakeRoar",1];
					[_unit, "Smasher_Roar", 600, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					_unit spawn {uiSleep 60; _this setVariable ["WBK_CanMakeRoar",nil];};
					uiSleep 0.5;
					if (animationState _unit != "wbk_smasher_roar") exitWith {};
					_unit spawn WBK_Smasher_CreateCamShake;
				};
				case "wbk_smasher_attack_vehicle": {
					[_unit, selectRandom ["Smasher_attack_1","Smasher_attack_2","Smasher_attack_3","Smasher_attack_5"], 140, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 1;
					if (animationState _unit != "wbk_smasher_attack_vehicle") exitWith {};
					[_unit, selectRandom ["Smasher_attack_5","Smasher_attack_6","Smasher_attack_7","Smasher_attack_8"], 140, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					_unit call WBK_Smasher_CreateCamShake;
					_unit call WBK_Smasher_Damage_Vehicles;
					[_unit,1,[0,4000,800],5] call WBK_Smasher_Damage_Humanoid;
					uiSleep 1;
					if (animationState _unit != "wbk_smasher_attack_vehicle") exitWith {};
					[_unit, {
						if (isDedicated) exitWith {};
						if (player distance _this <= 150) then {
							playSound3D [selectRandom ["\WBK_Zombies_Smasher\sounds\Smasher_scream_1.ogg","\WBK_Zombies_Smasher\sounds\Smasher_scream_2.ogg"], _this,false,getPosASL _this, 5, 1, 1000, 0, true];
						}else{
							playSound3D [selectRandom ["\WBK_Zombies_Smasher\sounds\Smasher_scream_dist_1.ogg","\WBK_Zombies_Smasher\sounds\Smasher_scream_dist_2.ogg"], _this,false,getPosASL _this, 5, 1, 1000, 0, true];
						};
					}] remoteExec ["spawn",0];
			   };
			   case "wbk_smasher_attack_1": {
					[_unit, selectRandom ["Smasher_attack_1","Smasher_attack_2","Smasher_attack_3","Smasher_attack_4","Smasher_attack_5","Smasher_attack_6","Smasher_attack_7","Smasher_attack_8","Smasher_attack_9"], 120, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 0.9;
					if (animationState _unit != "wbk_smasher_attack_1") exitWith {};
					[_unit, selectRandom ["Smasher_swoosh_1","Smasher_swoosh_2"], 100, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					_unit call WBK_Smasher_CreateCamShake;
					[_unit,0.49,[0,1000,200],4] call WBK_Smasher_Damage_Humanoid;
					uiSleep 1.4;
					if (animationState _unit != "wbk_smasher_attack_1") exitWith {};
					[_unit, selectRandom ["Smasher_attack_1","Smasher_attack_2","Smasher_attack_3","Smasher_attack_4","Smasher_attack_5","Smasher_attack_6","Smasher_attack_7","Smasher_attack_8","Smasher_attack_9"], 120, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					[_unit, selectRandom ["Smasher_swoosh_1","Smasher_swoosh_2"], 100, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					_unit call WBK_Smasher_CreateCamShake;
					[_unit,1,[0,1000,200],4] call WBK_Smasher_Damage_Humanoid;
			   };
			   case "wbk_smasher_attack_2": {
					[_unit, selectRandom ["Smasher_attack_1","Smasher_attack_2","Smasher_attack_3","Smasher_attack_4","Smasher_attack_5","Smasher_attack_6","Smasher_attack_7","Smasher_attack_8","Smasher_attack_9"], 120, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 1;
					if (animationState _unit != "wbk_smasher_attack_2") exitWith {};
					[_unit, selectRandom ["Smasher_swoosh_1","Smasher_swoosh_2"], 100, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 0.4;
					if (animationState _unit != "wbk_smasher_attack_2") exitWith {};
					[_unit, "Smasher_hit", 120, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
					_unit call WBK_Smasher_CreateCamShake;
					[_unit,0.5,[0,200,200],4] call WBK_Smasher_Damage_Humanoid;
					_electra = "#particlesource" createVehicle position _unit; 
					_electra setParticleClass "HDustVTOL1"; 
					_electra attachTo [_unit,[0,0.4,0]];
					uisleep 1;
					deleteVehicle _electra;
			   };
			   case "wbk_smasher_attack_3": {
					[_unit, selectRandom ["Smasher_attack_1","Smasher_attack_2","Smasher_attack_3","Smasher_attack_4","Smasher_attack_5","Smasher_attack_6","Smasher_attack_7","Smasher_attack_8","Smasher_attack_9"], 120, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 0.5;
					if (animationState _unit != "wbk_smasher_attack_3") exitWith {};
					[_unit, "Smasher_hit", 120, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
					_unit call WBK_Smasher_CreateCamShake;
					[_unit,0.5,[0,500,100],4] call WBK_Smasher_Damage_Humanoid;
					_electra = "#particlesource" createVehicle position _unit; 
					_electra setParticleClass "HDustVTOL1"; 
					_electra attachTo [_unit,[0,0.4,0]];
					uiSleep 0.5;
					deleteVehicle _electra;
					if (animationState _unit != "wbk_smasher_attack_3") exitWith {};
					[_unit, selectRandom ["Smasher_attack_1","Smasher_attack_2","Smasher_attack_3","Smasher_attack_4","Smasher_attack_5","Smasher_attack_6","Smasher_attack_7","Smasher_attack_8","Smasher_attack_9"], 120, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					[_unit, selectRandom ["Smasher_swoosh_1","Smasher_swoosh_2"], 100, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					_unit call WBK_Smasher_CreateCamShake;
					[_unit,0.5,[0,1000,100],4] call WBK_Smasher_Damage_Humanoid;
			   };
			   case "wbk_smasher_attack_air": {
					[_unit, selectRandom ["Smasher_attack_1","Smasher_attack_2","Smasher_attack_3","Smasher_attack_4","Smasher_attack_5","Smasher_attack_6","Smasher_attack_7","Smasher_attack_8","Smasher_attack_9"], 120, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 0.3;
					if (animationState _unit != "wbk_smasher_attack_air") exitWith {};
					[_unit, selectRandom ["Smasher_swoosh_1","Smasher_swoosh_2"], 200, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 0.9;
					if (animationState _unit != "wbk_smasher_attack_air") exitWith {};
					[_unit, "Smasher_hit", 170, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
					_unit call WBK_Smasher_CreateCamShake;
					[_unit,1,[0,200,200],6] call WBK_Smasher_Damage_Humanoid;
					_unit call WBK_Smasher_Damage_Vehicles;
					_electra = "#particlesource" createVehicle position _unit; 
					_electra setParticleClass "HDustVTOL1"; 
					_electra attachTo [_unit,[0,0.4,0]];
					uisleep 1;
					deleteVehicle _electra;
			   };
			   case "wbk_smasher_inair_end": {
					[_unit, selectRandom ["Smasher_attack_1","Smasher_attack_2","Smasher_attack_3","Smasher_attack_4","Smasher_attack_5","Smasher_attack_6","Smasher_attack_7","Smasher_attack_8","Smasher_attack_9"], 120, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 0.3;
					if (animationState _unit != "wbk_smasher_inair_end") exitWith {};
					[_unit, selectRandom ["Smasher_swoosh_1","Smasher_swoosh_2"], 200, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					[_unit, "Smasher_hit", 170, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
					_unit call WBK_Smasher_CreateCamShake;
					[_unit,0.5,[0,200,200],4] call WBK_Smasher_Damage_Humanoid;
					_unit call WBK_Smasher_Damage_Vehicles;
					_electra = "#particlesource" createVehicle position _unit; 
					_electra setParticleClass "HDustVTOL1"; 
					_electra attachTo [_unit,[0,0.4,0]];
					uisleep 1;
					deleteVehicle _electra;
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


_unitWithSword spawn {
	uisleep 0.5;
	_this doMove (getPosATLVisual _this);
};


_unitWithSword addEventHandler ["Killed", {
	{
		_ifDelete = [_x] call CBA_fnc_removePerFrameHandler;
	} forEach ((_this select 0) getVariable "WBK_AI_AttachedHandlers");
	_zombie = _this select 0;
	switch true do {
		case (_zombie isKindOf "WBK_SpecialZombie_Smasher_Hellbeast_1"): {
			hideBody _zombie;
			_zombie spawn {
				[_this, "hellspawn_fireball_idle", 155, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
				[_this, {
				if (isDedicated) exitWith {};
				_fulgi  = "#particlesource" createVehiclelocal getposaTL _this; 
				_fulgi setPosATL (getPosATL _this);
				_fulgi setParticleRandom [0, [1, 1, 0], [5, 5, 8], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
				_fulgi setDropInterval 0.01;
				_fulgi setParticleCircle [0, [0, 0, 0]];
				_fulgi setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1],"","Billboard",1,15,[0,0,0],[0,0,0],0,1.7,1,0,[0.15],[[1,1,1,1]],[1],0,0,"","",_fulgi, 0, false, -1, [[200,100,0.005,1],[200,100,0.005,1],[200,100,0.005,1]]]; 
				_fog1 = "#particlesource" createVehicleLocal getposaTL _this;
				_fog1 setPosATL (getPosATL _this);
				_fog1 setParticleParams [ 
						["\A3\data_f\cl_exp", 1, 0, 1], "", "Billboard", 1, 1, 
							[0, 0, 0], [0, 0, 0], 20, 1.25, 1, 0, 
							[0.9,1.3], [[1, 1, 1, 0.2], [1, 1, 1, 0.2], [1, 1, 1, 0.2]], [1000], 1, 0, "", "", _fog1, 0, false, -1, [[200,100,0.005,1],[200,100,0.005,1],[200,100,0.005,1]]
						]; 
				_fog1 setParticleRandom [3, [1, 1, 0.3], [0, 0, 1.4], 2, 0.15, [0, 0, 0, 0.1], 0, 0]; 
				_fog1 setParticleCircle [0.001, [0, 0, -0.12]]; 
				_fog1 setDropInterval 0.01; 
				_smlfirelight = "#lightpoint" createVehicleLocal (getpos _fulgi);
				_smlfirelight setPosATL (getPosATL _this);
				_smlfirelight setLightAmbient [1, 0.3, 0.1];
				_smlfirelight setLightColor [1, 0.3, 0.1];
				_smlfirelight setLightBrightness 0.51;
				_smlfirelight setLightUseFlare true;
				_smlfirelight setLightDayLight true;
				_smlfirelight setLightFlareSize 12;
				_smlfirelight setLightFlareMaxDistance 400; 
				uiSleep 8;
				deleteVehicle _fulgi;
				deleteVehicle _smlfirelight;
				deleteVehicle _fog1;
				}] remoteExec ["spawn",0];
				uiSleep 8;
				if (isNull _this) exitWith {};
				_this call WBK_CreateHellSpawnParticle;
				uiSleep 0.2;
				deleteVehicle _this;
			};
		};
		case (_zombie isKindOf "WBK_SpecialZombie_Smasher_Acid_1"): {
			[_zombie, {
				if (isDedicated) exitWith {};
				_fireflies  = "#particlesource" createVehiclelocal getposaTL _this; 
				_fireflies setParticleRandom [0,[0.5,0.5,0],[0.9,0.9,0.5],1,0,[0,0,0,0.1],1,1];
				_fireflies setDropInterval 0.1;
				_fireflies setParticleCircle [7,[0,0,0]];
				_fireflies setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1],"","Billboard",1,14,[0,0,0.1],[0,0,0.5],13,1.3,1,0,[0.1],[[0.01,1,0.1,1]],[1],0,0,"","",_this, 0, false, 0.1, [[0.01,100,0.005,1],[0.01,100,0.005,1],[0.01,100,0.005,1]]];
				_fulgi  = "#particlesource" createVehiclelocal getposaTL _this; 
				_fulgi setParticleRandom [0, [1, 1, 0], [5, 5, 8], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
				_fulgi setDropInterval 0.01;
				_fulgi setParticleCircle [0, [0, 0, 0]];
				_fulgi setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1],"","Billboard",1,15,[0,0,0],[0,0,0],0,1.7,1,0,[0.15],[[0.01,1,0.1,1]],[1],0,0,"","",_this, 0, false, 0.4, [[0.01,100,0.005,1],[0.01,100,0.005,1],[0.01,100,0.005,1]]]; 
				_fog1 = "#particlesource" createVehicleLocal getposaTL _this;
				_fog1 setParticleParams [ 
						["\A3\data_f\cl_exp", 1, 0, 1], "", "Billboard", 1, 1, 
							[0, 0, 0], [0, 0, 0], 1, 1.25, 1, 0, 
							[1.3,1.6],[[0.01,1,0.1,1]], [1000], 1, 0, "", "", _this, 0, false, -1, [[0.01,100,0.005,1],[0.01,100,0.005,1],[0.01,100,0.005,1]]
						]; 
				_fog1 setParticleRandom [3, [4, 4, 0.3], [0, 0, -0.1], 2, 0.15, [0, 0, 0, 0.1], 0, 0]; 
				_fog1 setParticleCircle [2, [0, 0, -0.12]]; 
				_fog1 setDropInterval 0.01; 
				_fog1 setParticleFire [15,2,0.1];
				_bubles = "#particlesource" createVehicleLocal getposaTL _this; 
				_bubles setParticleCircle [2, [0, 0, 0]]; 
				_bubles setParticleRandom [0, [4, 4, 0], [0, 0, 0], 0, 0, [0, 0, 0, 0], 0, 0]; 
				_bubles setDropInterval 0.1; 
				_bubles setParticleParams [["\A3\data_f\ParticleEffects\Universal\UnderWaterSmoke",4,0,15,1], "", 
				"Billboard", 10, 10, [0,0,-0.3], [0,0,0], 0, 0.3, 0.2353, 0, [1], [[0.01,1,0.1,1]],[1],0,0,"","",_bubles,0,false,-1,[[0.01,100,0.005,1],[0.01,100,0.005,1],[0.01,100,0.005,1]]]; 
				_smlfirelight = "#lightpoint" createVehicleLocal (getpos _fulgi);
				_smlfirelight setPosATL (getPosATL _this);
				_smlfirelight setLightAmbient [0.3, 1, 0]; 
				_smlfirelight setLightColor [0.3, 1, 0]; 
				_smlfirelight setLightBrightness 1;
				_smlfirelight setLightUseFlare true;
				_smlfirelight setLightDayLight true;
				_smlfirelight setLightFlareSize 5;
				_smlfirelight setLightFlareMaxDistance 400; 
				_fog1 say3D ["acid_hit",400];
				uisleep 1;
				deleteVehicle _fulgi;
				_fog1 say3D ["acid_idle",100];
				uisleep 39;
				deleteVehicle _smlfirelight;
				deleteVehicle _fog1;
				deleteVehicle _bubles;
				deleteVehicle _fireflies;
			}] remoteExec ["spawn", 0];
		};
	};
	[_zombie, "WBK_Smasher_Die"] remoteExec ["switchMove", 0]; 
	[_zombie, selectRandom ["Smasher_die_1","Smasher_die_2","Smasher_die_3","Smasher_die_4"], 225, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
	_zombie spawn {sleep 0.8; if (isNull _this) exitWith {}; [_this, "Smasher_hit", 155, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; };
}];

[_unitWithSword, {
_this removeAllEventHandlers "HitPart";
_this addEventHandler [
    "HitPart",
    {
		(_this select 0) params ["_target","_shooter","_bullet","_position","_velocity","_selection","_ammo","_direction","_radius","_surface","_direct"];
		if ((animationState _target == "WBK_Smasher_inAir") or (animationState _target == "WBK_Smasher_inAir_end") or (animationState _target == "WBK_Smasher_inAir_start_onRun") or (animationState _target == "wbk_smasher_attack_air") or (animationState _target == "wbk_smasher_roar") or (animationState _target == "WBK_Smasher_Attack_VEHICLE") or (animationState _target == "WBK_Smasher_Throw") or (animationState _target == "WBK_Smasher_HitHard") or (animationState _target == "WBK_Smasher_Execution") or (_target == _shooter) or (isNull _shooter) or !(alive _target)) exitWith {};
		_isExplosive = _ammo select 3;
		_isEnoughDamage = _ammo select 0;
		if !(isNil "WBK_ZombiesShowDebugDamage") then {
			systemChat str _isEnoughDamage;
		};
		if (((_isExplosive == 1) or (_isEnoughDamage >= 100)) and (isNil {_target getVariable "CanBeStunnedIMS"})) exitWith {
			[_target, "WBK_Smasher_HitHard"] remoteExec ["switchMove", 0]; 
			[_target, "WBK_Smasher_Run"] remoteExec ["playMoveNow", 0];
			_target setVariable ["CanBeStunnedIMS",1,true]; 
			_target spawn {uisleep 6; _this setVariable ["CanBeStunnedIMS",nil,true];};
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

_actFr = [{
    _array = _this select 0;
    _mutant = _array select 0;
	_mutant allowDamage false;
	if (!(simulationEnabled _mutant) or (animationState _mutant == "WBK_Smasher_Attack_Fire") or (animationState _mutant == "WBK_Smasher_Attack_Acid") or (animationState _mutant == "WBK_Smasher_inAir_end") or (animationState _mutant == "wbk_smasher_attack_air") or (animationState _mutant == "WBK_Smasher_Throw") or (animationState _mutant == "WBK_Smasher_HitHard") or (animationState _mutant == "WBK_Smasher_Attack_3") or (animationState _mutant == "WBK_Smasher_Attack_1") or (animationState _mutant == "WBK_Smasher_Attack_2") or (animationState _mutant == "WBK_Smasher_inAir") or (animationState _mutant == "WBK_Smasher_inAir_start") or (animationState _mutant == "WBK_Smasher_inAir_start_onRun") or (animationState _mutant == "WBK_Smasher_inAir_end") or (animationState _mutant == "WBK_Smasher_Execution") or (animationState _mutant == "WBK_Smasher_Roar") or (animationState _mutant == "WBK_Smasher_Attack_VEHICLE") or (animationState _mutant == "WBK_Smasher_Die") or !(isTouchingGround _mutant) or !(alive _mutant)) exitWith {};
    _mutant action ["SwitchWeapon", _mutant, _mutant, 100]; 
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
		case ((_mutant isKindOf "WBK_SpecialZombie_Smasher_Hellbeast_1") and (isNil {_mutant getVariable "CanTeleport"}) and ((_en distance _mutant) > 25) and ((_en distance _mutant) <= 500) and (alive _mutant)): {
			_mutant spawn WBK_Hellspawn_Teleport;
		};
		case ((count _ins == 0) and (_mutant isKindOf "WBK_SpecialZombie_Smasher_Hellbeast_1") and (isNil {_mutant getVariable "CanThrowAcid"}) and ((_en distance _mutant) > 10) and ((_en distance _mutant) <= 150) and (alive _mutant)): {
			_mutant spawn WBK_Smasher_FireAttack;
		};
		case ((count _ins == 0) and (_mutant isKindOf "WBK_SpecialZombie_Smasher_Acid_1") and (isNil {_mutant getVariable "CanThrowAcid"}) and ((_en distance _mutant) > 10) and ((_en distance _mutant) <= 70) and (alive _mutant)): {
			_mutant spawn WBK_Smasher_AcidThrow;
		};
		case ((isNil {_mutant getVariable "CanThrowRocks"}) and !(currentWeapon _en in IMS_Melee_Weapons) and ((_en distance _mutant) > 10) and ((_en distance _mutant) <= 70) and (alive _mutant) and (!((vehicle _en) isKindOf "MAN") or ((speed (vehicle _en)) >= 13) or ((_en distance _mutant) >= 35) or (_en isKindOf "TIOWSpaceMarine_Base"))): {
			[_mutant, vehicle _en] spawn WBK_Smasher_RockThrowing;
		};
		case ((animationState _en != "unconscious") and !(currentWeapon _en in IMS_Melee_Weapons) and (count _ins == 0) and ((_en distance _mutant) <= 4) and (alive _mutant) and (isNil {_mutant getVariable "WBK_CanEatSomebody"}) and (getText (configfile >> 'CfgVehicles' >> typeOf _en >> 'moves') == 'CfgMovesMaleSdr')): {
			_mutant setVariable ["WBK_CanEatSomebody",1];
			[_mutant, _en] spawn WBK_Smasher_ExecutionFnc;
		};
		case ((count _ins == 0) and (isNil {_mutant getVariable "CanFly"}) and ((_en distance _mutant) <= 25) and ((_en distance _mutant) > 8) and !(isNull _en) and (alive _en)): {
			_mutant setFormDir (_mutant getDir _en);
			[_mutant, _en] spawn WBK_ChargerJump;
		};
		case (((_en distance _mutant) <= 6.3) and !((vehicle _en) isKindOf "MAN") and (alive _mutant)): {
			[_mutant, "wbk_smasher_attack_vehicle"] remoteExec ["switchMove", 0]; 
			[_mutant, "WBK_Smasher_Run"] remoteExec ["playMoveNow", 0];
		};
		case ((count _ins == 0) and (isNil {_mutant getVariable "WBK_CanMakeRoar"}) and ((_en distance _mutant) <= 45) and ((_en distance _mutant) > 15) and !(isNull _en) and (alive _en)): {
			[_mutant, "wbk_smasher_roar"] remoteExec ["switchMove", 0]; 
			[_mutant, "WBK_Smasher_Run"] remoteExec ["playMoveNow", 0];
		};
		case ((count _ins == 0) and ((_en distance _mutant) <= 4) and (alive _mutant)): {
			[_mutant, selectRandom ["wbk_smasher_attack_1","wbk_smasher_attack_2","wbk_smasher_attack_3","wbk_smasher_attack_vehicle"]] remoteExec ["switchMove", 0]; 
			[_mutant, "WBK_Smasher_Run"] remoteExec ["playMoveNow", 0];
		};
	};
}, 0.3, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;

_loopPathfind = [{
    _array = _this select 0;
    _unit = _array select 0;
	_isStriderTaked = missionNamespace getVariable["bis_fnc_moduleRemoteControl_unit", player];
	if (!(simulationEnabled _unit) || (_unit == _isStriderTaked) || (animationState _unit == "wbk_smasher_attack_fire") || (animationState _unit == "wbk_smasher_attack_acid") || (animationState _unit == "wbk_smasher_inair") || (animationState _unit == "wbk_smasher_inair_start_onrun") || (animationState _unit == "wbk_smasher_inair_end") || (animationState _unit == "wbk_smasher_throw") || (animationState _unit == "wbk_smasher_inair") || (animationState _unit == "wbk_smasher_execution")) exitWith {};
	_nearEnemy = _unit findNearestEnemy _unit; 
	if ((animationState _unit == "wbk_smasher_attack_air") or (isNull _nearEnemy) or !(alive _nearEnemy) or !(alive _unit) or !(isNull attachedTo _unit) or (lifeState _unit == "INCAPACITATED") or (_unit distance _nearEnemy >= WBK_Zombies_Smasher_MoveDistanceLimit)) exitWith {
		_unit setVariable ["WBK_IsUnitLocked",nil];
	};
	if (animationState _unit in ["wbk_smasher_hithard","wbk_smasher_roar","wbk_smasher_attack_1","wbk_smasher_attack_2","wbk_smasher_attack_3","wbk_smasher_attack_vehicle"]) exitWith {
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
	  (count _ifInter == 0) and 
	  (_result1 < 1.45) and
	  (_result1 > (-1.45)) and
	  !(lifeState _unit == "INCAPACITATED")
      ) exitWith {
		_unit setVariable ["WBK_IsUnitLocked",0];
	    _unit disableAI "MOVE";
	    _unit disableAI "ANIM";
		doStop _unit;
		if  ((_unit distance _nearEnemy) > 3.3) then {
			_unit playMoveNow "WBK_Smasher_Run";
		}else{
			_unit playMoveNow "WBK_Smasher_Idle";
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
	[_unit, selectRandom ["Smasher_idle_1","Smasher_idle_2","Smasher_idle_3","Smasher_idle_4"],40] call CBA_fnc_GlobalSay3d;
	if (!(simulationEnabled _unit) || !(isNil {_unit getVariable "WBK_IsUnitLocked"}) or (animationState _unit == "wbk_smasher_attack_fire") or (animationState _unit == "wbk_smasher_attack_acid") or (animationState _unit == "wbk_smasher_attack_air") or (animationState _unit == "wbk_smasher_hithard") || (animationState _unit == "wbk_smasher_throw") || (animationState _unit == "wbk_smasher_inair") || (animationState _unit == "wbk_smasher_execution")) exitWith {};
		_unit enableAI "MOVE";
		_unit enableAI "ANIM";
		if ((isNull _nearEnemy) or !(alive _nearEnemy) or !(alive _unit)) exitWith {};
		_pos = ASLtoAGL getPosASLVisual _nearEnemy;
		_unit doMove _pos;
}, 2.4, [_unitWithSword]] call CBA_fnc_addPerFrameHandler;
_unitWithSword setVariable ["WBK_AI_AttachedHandlers", [_actFr,_loopPathfindDoMove,_loopPathfind]];