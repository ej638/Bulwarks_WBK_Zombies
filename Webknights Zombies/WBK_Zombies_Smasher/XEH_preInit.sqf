[ 
    "WBK_Zommbies_HowFarCanSee_Smash", 
    "EDITBOX", 
    ["Path calculation distance","How far must be the target in order for a smasher to start running towards ai. Lowering the number will increase performance, as ARMA dont like to calculate path on longer distances."],
    ["WebKnight's Zombies","3) Smasher"],
    "500",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_Smasher_MoveDistanceLimit = _number;
    }
] call CBA_fnc_addSetting;



[ 
    "WBK_ZommbiesSmasherHealthParam", 
    "EDITBOX", 
    "Regular Smasher Health",
    ["WebKnight's Zombies","3) Smasher"],
    "3500",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_SmasherHP = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesSmasherHealthParam_Acid", 
    "EDITBOX", 
    "Spewer Smasher Health",
    ["WebKnight's Zombies","3) Smasher"],
    "4000",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_SmasherHP_Acid = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesSmasherHealthParam_Hell", 
    "EDITBOX", 
    "Hellspawn Smasher Health",
    ["WebKnight's Zombies","3) Smasher"],
    "5000",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_SmasherHP_Hell = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesSmasherThrowParam", 
    "CHECKBOX", 
    "(All Variants) Can throw rocks?",
    ["WebKnight's Zombies","3) Smasher"],
    true,
    1,
    {   
        params ["_value"]; 
        WBK_Zombies_SmasherRockAbil = _value; 
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesSmasherThrowParam_Deb", 
    "EDITBOX", 
    "(All Variants) Rock attack cooldown",
    ["WebKnight's Zombies","3) Smasher"],
    "45",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_Smasher_RockAttackCooldown = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesSmasherJumpParam", 
    "CHECKBOX", 
    "(All Variants) Can do jump attack?",
    ["WebKnight's Zombies","3) Smasher"],
    true,
    1,
    {   
        params ["_value"]; 
        WBK_Zombies_SmasherFlyAbil = _value; 
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesSmasherThrowParam_Deb_Spewer", 
    "EDITBOX", 
    "(Spewer) Acid attack cooldown",
    ["WebKnight's Zombies","3) Smasher"],
    "20",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_Smasher_AcidAttackCooldown = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesSmasherThrowParam_Deb_Fire", 
    "EDITBOX", 
    "(Hellspawn) Fire attack cooldown",
    ["WebKnight's Zombies","3) Smasher"],
    "15",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_Smasher_FireAttackCooldown = _number;
    }
] call CBA_fnc_addSetting;

[ 
    "WBK_ZommbiesSmasherThrowParam_Deb_TP", 
    "EDITBOX", 
    "(Hellspawn) Teleport attack cooldown",
    ["WebKnight's Zombies","3) Smasher"],
    "40",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_Smasher_TeleportAttackCooldown = _number;
    }
] call CBA_fnc_addSetting;



WBK_Smasher_Damage_Vehicles = {
	if !(alive _this) exitWith {};
	{
		[_this, "Smasher_hit", 245, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		[_x, "Smasher_hit_vehicle", 245, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		_dir = getDirVisual _this;
		_vel = velocity _x;
		[_x, [(_vel select 0)+(sin _dir*15),(_vel select 1)+(cos _dir*15),5]] remoteExec ["setVelocity", _x];
		if ((_x isKindOf "CAR") or (_x isKindOf "Helicopter") or (_x isKindOf "StaticWeapon")) then {
			_x setDamage 1;
		}else{
			_x setDamage ((damage _x) + 0.5);
		};
	} forEach nearestObjects [_this,["CAR","TANK","Air","StaticWeapon"],7];
};


WBK_Smasher_Damage_Humanoid = {
	params ["_smasher","_damage","_position","_dist"];
	if !(alive _smasher) exitWith {};
	{
		switch true do {
			case (_x == _smasher): {};
			case (!(isNil {_x getVariable "IMS_IsUnitInvicibleScripted"}) || (animationState _x == "STAR_WARS_FIGHT_DODGE_LEFT") || (animationState _x == "STAR_WARS_FIGHT_DODGE_LEFT") || (animationState _x == "STAR_WARS_FIGHT_DODGE_RIGHT") || (animationState _x == "starWars_landRoll") || (animationState _x == "starWars_landRoll_b") || ((typeOf _x isKindOf "WBK_SpecialZombie_Smasher_1") && (side _x == side _smasher)) || ((typeOf _x isKindOf "WBK_Goliaph_1") && (side _x == side _smasher)) || ((_x == _smasher) || !(alive _smasher) || !(alive _x) || (animationState _x == "WBK_Smasher_Execution"))): {};
			case (!(isNil {_x getVariable "WBK_AI_ISZombie"}) || !(isNil {_x getVariable "IMS_ISAI"})): {
				[_x, [1, false, _smasher]] remoteExec ["setDamage",2];
				[_x, [_smasher vectorModelToWorld _position, _x selectionPosition "head",false]] remoteExec ["addForce", _x];
				[_x, selectRandom ["Smasher_hit_human_1","Smasher_hit_human_2"], 105, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
			};
			case ((currentWeapon _x in IMS_Melee_Weapons) or (_x isKindOf "WBK_DOS_Squig_Normal") or (_x isKindOf "WBK_DOS_Huge_ORK") or (_x isKindOf "TIOWSpaceMarine_Base")): {
				[_x,_damage,_smasher] remoteExec ["WBK_CreateDamage", _x];
				[_x,_smasher] remoteExec ["WBK_CreateMeleeHitAnim", _x];
				[_x, selectRandom ["Smasher_hit_human_1","Smasher_hit_human_2"], 150, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
			};
			default {
				[_x, selectRandom ["Smasher_hit_human_1","Smasher_hit_human_2"], 105, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				[_x,_damage,_smasher] remoteExec ["WBK_CreateDamage", _x];
				[_x, [_smasher vectorModelToWorld _position, _x selectionPosition "head",false]] remoteExec ["addForce", _x];
			};
		};
	} forEach nearestObjects [_smasher,["MAN"],_dist];
	_ins = lineIntersectsSurfaces [
		_smasher modelToWorldWorld [0,0,2],
		_smasher modelToWorldWorld [0,_dist,2],
		_smasher,
		objNull,
		true,
		1,
		"GEOM",
		"FIRE"
    ];
	if (count _ins != 0) then {
		_obj = (_ins select 0 select 2);
		if (_obj isKindOf "Static") then {_obj setDamage 1;};
	};
};


WBK_Smasher_CreateBloodParticle = {
	[_this, {
		_object = _this;
		if (isDedicated) exitWith {};
		_blood = "#particlesource" createVehicleLocal (getposATL _object);          
		_blood attachTo [_object,[0,0,0],"head"];  
		_blood setParticleParams [ 
				["\a3\Data_f\ParticleEffects\Universal\Universal", 16, 13, 1, 32],            
				"",         
				"billboard",    
				0.1, 2,         
				[0, 0, 0],     
				[3 + random -6, 3 + random -6, 2],         
				5, 6, 0.4, 0.4,         
				[0.05, 1.4],        
				[[0.5,0,0,0.6], [0.8,0,0,0.1], [0.1,0,0,0.03]],    
				[0.00001],    
				0.4,    
				0.4,    
				"",    
				"",    
				"",   
				360,           
				false,            
				0    
			];  
		_blood setdropinterval 0.01;  
		_breath = "#particlesource" createVehicleLocal (getposATL _object);                      
		_breath setParticleParams            
			[            
				["\a3\Data_f\ParticleEffects\Universal\meat_ca", 1, 0, 1],      
				"",          
				"spaceObject",        
				0.5, 12,        
				[0, 0, 0],    
				[3 + random -3, 2 + random -2, random 3],
				1,1.275,0.2,0,          
				[1.6,0],     
				[[0.005,0,0,0.05], [0.006,0,0,0.06], [0.2,0,0,0]],      
				[1000],     
				1,         
				0.1,        
				"",    
				"",     
				"",         
				0,       
				false,          
				0.0          
			];            
		_breath setParticleRandom [0.5, [0, 0, 0], [3.25, 0.25, 2.25], 1, 0.5, [0, 0, 0, 0.1], 0, 0, 10];      
		_breath setDropInterval 0.01;            
		_breath attachTo [_object,[0,0,0.2], "head"];  
		uisleep 0.15;
		deleteVehicle _breath; 
		uisleep 0.9;
		deleteVehicle _blood; 
	}] remoteExec ["spawn",0];
};


WBK_Smasher_ExecutionFnc = { 
	_main = _this select 0;  
	_main spawn {uiSleep 60; _this setVariable ["WBK_CanEatSomebody",nil];};
	_victim = _this select 1;  
	_victim setVariable ["AI_CanTurn",1,true];  
	_victim setVariable ["canMakeAttack",1,true];   
	_main setVariable ["canMakeAttack",1];  
	_main setVariable ["AI_CanTurn",1];  
	_main setVariable ["actualSwordBlock",0, true];  
	[_main, "WBK_Smasher_Execution"] remoteExec ["switchMove", 0];  
	[_victim, "WBK_Smasher_Execution"] remoteExec ["switchMove", 0];  
	[_victim, "Disable_Gesture"] remoteExec ["playActionNow", _victim];  
	_victim attachTo [_main,[0,3.51,0]];    
	_victim setDamage 0;  
	_main setDamage 0;
	[_victim, 180] remoteExec ["setDir", 0];  
	[_victim, "dead"] remoteExec ["setMimic", 0];  
	uisleep 0.1;
	[_main, selectRandom ["Smasher_attack_8","Smasher_attack_9"], 120, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_victim, "PF_Hit_2", 120, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_victim, "dobi_fall_2", 120, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	if (isNil {_victim getVariable "WBK_AI_ISZombie"}) then {
	[_victim, selectRandom ["Smasher_human_scream_1","Smasher_human_scream_2","Smasher_human_scream_3"], 110, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	};
	_victim setDamage 0; 
	uisleep 1.9;
	_victim setDamage 1;
	[_victim, 1.25] remoteExec ["setAnimSpeedCoef", 0];  
	[_main, selectRandom ["Smasher_attack_6","Smasher_attack_7"], 120, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_victim, "dobi_CriticalHit", 120, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	_main spawn WBK_Smasher_CreateCamShake;
	if (isNil {_victim getVariable "WBK_AI_ISZombie"}) then {
	[_victim, selectRandom ["New_Death_1","New_Death_2","New_Death_3","New_Death_4","New_Death_5","New_Death_6","New_Death_7","New_Death_8","New_Death_9"], 120, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	};
	_victim call WBK_Smasher_CreateBloodParticle;
	uisleep 1.5;
	[_main, "Smasher_eat_voice", 120, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_main, "Smasher_Eat", 100, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_victim, "PF_Hit_1", 40, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_victim, selectRandom ["dobi_blood_1","dobi_blood_2"], 80, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_victim, "Smasher_hit_human_1", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	_victim unlinkItem hmd _victim;
	removeGoggles _victim;
	removeHeadgear _victim;
	_victim call WBK_Smasher_CreateBloodParticle;
	[_victim, "WBK_DecapatedHead_Zombies_Normal"] remoteExec ["setFace",0];
	uisleep 2.5;
	[_main, "Smasher_execution_end", 90, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	uisleep 0.2;
	[_victim, "Smasher_hit_human_2", 120, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	_victim spawn WBK_Smasher_CreateCamShake;
	_victim call WBK_Smasher_CreateBloodParticle;
	[_main,0.5,[0,200,-100],3] call WBK_Smasher_Damage_Humanoid;
	uisleep 0.8;
	[_main, "WBK_Smasher_Run"] remoteExec ["playMoveNow", 0];
	detach _victim;
};


QS_fnc_geomPolygonCentroid = {
_count = count _this;
private _vectors = _this select 0;
for '_i' from 1 to (_count - 1) step 1 do {
	_vectors = _vectors vectorAdd (_this select _i);
};
(_vectors vectorMultiply (1 / _count))
};


WBK_ChargerJump = {
(_this select 0) setVariable ["CanFly",1];
[(_this select 0), "wbk_smasher_attack_air"] remoteExec ["switchMove", 0]; 
[(_this select 0), "WBK_Smasher_Run"] remoteExec ["playMoveNow", 0];
_loopPathfindDoMove = [{
    _array = _this select 0;
    _unit = _array select 0;
	_nearEnemy = _array select 1;
	_anim = _array select 2;
	if (!(animationState _unit == _anim) or (lifeState _unit == "INCAPACITATED") or !(alive _unit)) exitWith {};
	if (isNil {_unit getVariable "LeapToTarget"}) exitWith {
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
        0.1
    ]; 
}, 0.01, [(_this select 0), (_this select 1), "wbk_smasher_attack_air"]] call CBA_fnc_addPerFrameHandler;
(_this select 0) spawn {uisleep 0.7; _this setVariable ["LeapToTarget",1]; uisleep 0.4; _this setVariable ["LeapToTarget",nil];};
_loopPathfindDoMove spawn {uisleep 1.15; [_this] call CBA_fnc_removePerFrameHandler;};
uiSleep (10 + random 5);
(_this select 0) setVariable ["CanFly",nil];
};


WBK_Smasher_RockThrowing = {
	_zombie = _this select 0;
	if (!(isNil {_zombie getVariable "CanThrowRocks"}) or (animationState _zombie == "WBK_Smasher_Execution")) exitWith {};
	_zombie setVariable ["CanThrowRocks",1];
	_zombie spawn {uiSleep WBK_Zombies_Smasher_RockAttackCooldown; _this setVariable ["CanThrowRocks",nil];};
	_enemy = _this select 1;
	[_zombie, selectRandom ["Smasher_attack_1","Smasher_attack_2","Smasher_attack_3","Smasher_attack_4","Smasher_attack_5","Smasher_attack_6","Smasher_attack_7","Smasher_attack_8","Smasher_attack_9"], 120, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_zombie, "WBK_Smasher_Throw"] remoteExec ["switchMove", 0]; 
	[_zombie, "WBK_Smasher_Run"] remoteExec ["playMoveNow", 0];
	_zombie allowDamage false;
	doStop _zombie;
	_zombie disableAI "ANIM";
	_throwableItem = "Smasher_RockGrenade" createVehicle [0,0,(4000 + random 2500)];
	_loopPathfindDoMove = [{
		_array = _this select 0;
		_unit = _array select 0;
		_nearEnemy = _array select 1;
		_anim = _array select 2;
		if (!(animationState _unit == _anim) or (lifeState _unit == "INCAPACITATED") or !(alive _unit)) exitWith {};
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
	}, 0.01, [_zombie, _enemy, "WBK_Smasher_Throw"]] call CBA_fnc_addPerFrameHandler;
	sleep 0.5;
	if (!(animationState _zombie == "WBK_Smasher_Throw") or !(alive _zombie)) exitWith {
	[_loopPathfindDoMove] call CBA_fnc_removePerFrameHandler;
	_zombie enableAI "ANIM";
	deleteVehicle _throwableItem;
	};
	[_zombie, "Smasher_hit", 120, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
	_zombie spawn WBK_Smasher_CreateCamShake;
	[_zombie,0.5,[0,200,200],4] call WBK_Smasher_Damage_Humanoid;
	_zombie enableAI "ANIM";
	_electra = "#particlesource" createVehicle position _zombie; 
	_electra setParticleClass "HDustVTOL1"; 
	_electra attachTo [_zombie,[0,0,0]];
	detach _electra;
	_electra spawn {sleep 2; deleteVehicle _this;};
	sleep 0.95;
	if (!(animationState _zombie == "WBK_Smasher_Throw") or !(alive _zombie)) exitWith {
	[_loopPathfindDoMove] call CBA_fnc_removePerFrameHandler;
	_zombie enableAI "ANIM";
	deleteVehicle _throwableItem;
	};
	_throwableItem attachTo [_zombie,[0,-1,0],"Smash_Hand_R",true];
	[_zombie, "Smasher_hit", 150, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
	sleep 0.65;
	if (!(animationState _zombie == "WBK_Smasher_Throw") or !(alive _zombie)) exitWith {
	[_loopPathfindDoMove] call CBA_fnc_removePerFrameHandler;
	_zombie enableAI "ANIM";
	deleteVehicle _throwableItem;
	};
	[_zombie, selectRandom ["Smasher_swoosh_1","Smasher_swoosh_2"], 340, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	sleep 0.1;
	detach _throwableItem;
	_dir = (_zombie getDir _enemy);
	_vel = velocity _zombie;
	_distance = (_zombie distance _enemy) * 0.8;
	_pos = (getPosASL _enemy) select 2;
	_pos1 = (getPosASL _zombie) select 2;
	_actPos = _pos - _pos1;
	switch true do {
		case (_actPos < 0): {
			_throwableItem setVelocity [(_vel select 0)+(sin _dir*_distance),(_vel select 1)+(cos _dir*_distance),_actPos + 6.2];
		};
		case (_actPos > 4): {
			_throwableItem setVelocity [(_vel select 0)+(sin _dir*_distance),(_vel select 1)+(cos _dir*_distance),_actPos + 3];
		};
		default {
			_distance = (_zombie distance _enemy) * 0.86;
			_throwableItem setVelocity [(_vel select 0)+(sin _dir*_distance),(_vel select 1)+(cos _dir*_distance),_actPos + 4.6];
		};
	};
	sleep 0.1;
	[_throwableItem, _zombie] spawn {
	_grenade = _this select 0;
	_actualHitClass = "#particlesource" createVehicle position _grenade; 
	_actualHitClass attachTo [_grenade,[0,0,0]];
	_zombie = _this select 1;
	waitUntil {sleep 0.1; !(alive _grenade)};
	[_actualHitClass, "Smash_rockHit", 850] call CBA_fnc_GlobalSay3d;
	_actualHitClass spawn WBK_Smasher_CreateCamShake;
	[_actualHitClass, {
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
		sleep 0.3;
		{
			deletevehicle _x;
		} foreach _rocks;
	}] remoteExec ["spawn", [0,-2] select isDedicated,false];
	uisleep 15;
	deleteVehicle _actualHitClass;
	};
	sleep 0.1;
	[_loopPathfindDoMove] call CBA_fnc_removePerFrameHandler;
	_zombie enableAI "ANIM";
	if (!(animationState _zombie == "WBK_Smasher_Throw") or !(alive _zombie)) exitWith {};
	[_zombie, selectRandom ["Smasher_attack_1","Smasher_attack_2","Smasher_attack_3","Smasher_attack_4","Smasher_attack_5","Smasher_attack_6","Smasher_attack_7","Smasher_attack_8","Smasher_attack_9"], 120, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
};


WBK_Smasher_AcidThrow = {
	_this setVariable ["CanThrowAcid",1];
	_this spawn {uiSleep WBK_Zombies_Smasher_AcidAttackCooldown; _this setVariable ["CanThrowAcid",nil];};
	[_this, "WBK_Smasher_Attack_Acid"] remoteExec ["switchMove", 0];
	[_this, "WBK_Smasher_Run"] remoteExec ["playMoveNow", 0];
	_enemy = _this findNearestEnemy _this;
	[_this, selectRandom ["Smasher_attack_4","Smasher_attack_6","Smasher_attack_7"], 170, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";		
	_loopPathfindDoMove = [{
		_array = _this select 0;
		_unit = _array select 0;
		_nearEnemy = _array select 1;
		_anim = _array select 2;
		if (!(animationState _unit == _anim) or (lifeState _unit == "INCAPACITATED") or !(alive _unit)) exitWith {};
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
	}, 0.01, [_this, _enemy, "WBK_Smasher_Attack_Acid"]] call CBA_fnc_addPerFrameHandler;
	_loopPathfindDoMove spawn {uiSleep 1.8; [_this] call CBA_fnc_removePerFrameHandler;};
	uiSleep 0.75;
	if (animationState _this != "wbk_smasher_attack_acid") exitWith {};
	[_this, "Smasher_execution_end", 170, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_this, "acid_attack_start", 170, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_this, {
		if (isDedicated) exitWith {};
		_fulgi  = "#particlesource" createVehiclelocal getposaTL _this; 
		_fulgi setParticleRandom [0, [1, 1, 0], [0, 0, 3], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
		_fulgi setDropInterval 0.01;
		_fulgi setParticleCircle [0, [0, 0, 0]];
		_fulgi setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1],"","Billboard",1,15,[0,0,0],[0,0,0],0,1.7,1,0,[0.15],[[0.01,1,0.1,1]],[1],0,0,"","",_fulgi, 0, false, -1, [[0.01,100,0.005,1],[0.01,100,0.005,1],[0.01,100,0.005,1]]]; 
		_fulgi attachTo [_this,[0,0,0],"Smash_Hand_R"];
		_smlfirelight = "#lightpoint" createVehicleLocal (getpos _fulgi);
		_smlfirelight setPosATL (getPosATL _this);
		_smlfirelight setLightAmbient [0.3, 1, 0]; 
		_smlfirelight setLightColor [0.3, 1, 0]; 
		_smlfirelight setLightBrightness 0.4;
		_smlfirelight setLightUseFlare true;
		_smlfirelight setLightDayLight true;
		_smlfirelight setLightFlareSize 1;
		_smlfirelight setLightFlareMaxDistance 400; 
		_smlfirelight attachTo [_this,[0,0,0],"Smash_Hand_R"];
		_smlfirelight say3D ["acid_idle",200];
		uiSleep 1;
		deleteVehicle _fulgi;
		deleteVehicle _smlfirelight;
	}] remoteExec ["spawn", 0];
	uiSleep 0.75;
	if (animationState _this != "wbk_smasher_attack_acid") exitWith {};
	_throwableItem = "Smasher_AcidGrenade" createVehicle [0,0,(4000 + random 2500)];
	uiSleep 0.2;
	if (animationState _this != "wbk_smasher_attack_acid") exitWith {deleteVehicle _throwableItem;};
	[_this, selectRandom ["Smasher_swoosh_1","Smasher_swoosh_2"], 200, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_throwableItem, {
		if (isDedicated) exitWith {};
		_fulgi  = "#particlesource" createVehiclelocal getposaTL _this; 
		_fulgi setParticleRandom [0, [1, 1, 0], [0, 0, 3], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
		_fulgi setDropInterval 0.01;
		_fulgi setParticleCircle [0, [0, 0, 0]];
		_fulgi setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1],"","Billboard",1,15,[0,0,0],[0,0,0],0,1.7,1,0,[0.15],[[0.01,1,0.1,1]],[1],0,0,"","",_this, 0, false, -1, [[0.01,100,0.005,1],[0.01,100,0.005,1],[0.01,100,0.005,1]]]; 
		_fulgi attachTo [_this,[0,0,0]];
		_fog1 = "#particlesource" createVehicleLocal getposaTL _this;
		_fog1 setParticleParams [ 
				["\A3\data_f\cl_exp", 1, 0, 1], "", "Billboard", 1, 1, 
					[0, 0, 0], [0, 0, 0], 1, 1.25, 1, 0, 
					[1.3,1.6],[[0.01,1,0.1,1]], [1000], 1, 0, "", "", _this, 0, false, -1, [[0.01,100,0.005,1],[0.01,100,0.005,1],[0.01,100,0.005,1]]
				]; 
		_fog1 setParticleRandom [3, [0.1, 0.1, 0.1], [0, 0, -0.1], 2, 0.15, [0, 0, 0, 0.1], 0, 0]; 
		_fog1 setParticleCircle [0.001, [0, 0, -0.12]]; 
		_fog1 setDropInterval 0.01; 
		_fog1 attachTo [_this,[0,0,0]];
		_smlfirelight = "#lightpoint" createVehicleLocal (getpos _fulgi);
		_smlfirelight setPosATL (getPosATL _this);
		_smlfirelight setLightAmbient [0.3, 1, 0]; 
		_smlfirelight setLightColor [0.3, 1, 0]; 
		_smlfirelight setLightBrightness 0.4;
		_smlfirelight setLightUseFlare true;
		_smlfirelight setLightDayLight true;
		_smlfirelight setLightFlareSize 1;
		_smlfirelight setLightFlareMaxDistance 400; 
		_smlfirelight attachTo [_this,[0,0,0]];
		_fog1 setParticleFire [5,1,0.1];
		_fog1 say3D ["acid_loop",150];
		waitUntil {sleep 0.1; !(alive _this)};
		deleteVehicle _fulgi;
		deleteVehicle _smlfirelight;
		deleteVehicle _fog1;
	}] remoteExec ["spawn", 0];
	_throwableItem setPosATL (_this modelToWorldVisual [1.8,4,1.3]);
	detach _throwableItem;
	_dir = (_this getDir _enemy);
	_vel = velocity _this;
	_distance = (_this distance _enemy) * 0.7;
	_pos = (getPosASL _enemy) select 2;
	_pos1 = (getPosASL _this) select 2;
	_actPos = _pos - _pos1;
	switch true do {
		case (_actPos < 0): {
			_throwableItem setVelocity [(_vel select 0)+(sin _dir*_distance),(_vel select 1)+(cos _dir*_distance),_actPos + 6.2];
		};
		case (_actPos > 4): {
			_throwableItem setVelocity [(_vel select 0)+(sin _dir*_distance),(_vel select 1)+(cos _dir*_distance),_actPos + 3];
		};
		default {
			_distance = (_this distance _enemy) * 0.86;
			_throwableItem setVelocity [(_vel select 0)+(sin _dir*_distance),(_vel select 1)+(cos _dir*_distance),_actPos + 4.6];
		};
	};
	uiSleep 0.1;
	_throwableItem spawn {
	_grenade = _this;
	_actualHitClass = "#particlesource" createVehicle position _grenade; 
	_actualHitClass attachTo [_grenade,[0,0,0]];
	waitUntil {sleep 0.1; !(alive _grenade)};
	{
		if ((alive _x) and (getText (configfile >> 'CfgVehicles' >> typeOf _x >> 'moves') == 'CfgMovesMaleSdr')) then {
				_x setDamage 1;
				_rndAnim = selectRandom ["acid_death_human_1","acid_death_human_2","acid_death_human_3"];
				[_x, _rndAnim] remoteExec ["switchMove",0];
				[_x, _rndAnim, 100, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				_x call WBK_Smasher_CreateBloodParticle;
		};
	} forEach nearestObjects [_actualHitClass,["MAN"],7];
	_actualHitClass spawn WBK_Smasher_CreateCamShake;
	[_actualHitClass, {
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
	uisleep 40;
	deleteVehicle _actualHitClass;
	};
};


WBK_Smasher_CreateCamShake = {
	[_this, {
		if (isDedicated) exitWith {};
		if (((missionNamespace getVariable["bis_fnc_moduleRemoteControl_unit", player]) distance _this) <= 20) then {
			enableCamShake true;
			addCamShake [5, 5, 25];
		};
	}] remoteExec ["spawn",0];
};


WBK_CreateHellFireball = {
	params ["_smasher","_enemy","_position"];
	_throwableItem = "Smasher_AcidGrenade" createVehicle [0,0,(4000 + random 2500)];
	uiSleep 0.1;
	[_smasher, selectRandom ["Smasher_swoosh_1","Smasher_swoosh_2"], 200, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_throwableItem, {
		if (isDedicated) exitWith {};
		_fulgi  = "#particlesource" createVehiclelocal getposaTL _this; 
		_fulgi setParticleRandom [0, [1, 1, 0], [0, 0, 3], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
		_fulgi setDropInterval 0.01;
		_fulgi setParticleCircle [0, [0, 0, 0]];
		_fulgi setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1],"","Billboard",1,15,[0,0,0],[0,0,0],0,1.7,1,0,[0.15],[[1,0.2,0,1]],[1],0,0,"","",_fulgi, 0, false, -1, [[255,40,0,1],[255,40,0,1],[255,40,0,1]]]; 
		_fulgi attachTo [_this,[0,0,0]];
		_fog1 = "#particlesource" createVehicleLocal getposaTL _this;
		_fog1 setParticleParams [ 
				["\A3\data_f\cl_exp", 1, 0, 1], "", "Billboard", 1, 1, 
					[0, 0, 0], [0, 0, 0], 1, 1.25, 1, 0, 
					[1.3,1.6],[[1,0.2,0,1]], [1000], 1, 0, "", "", _this, 0, false, -1, [[255,40,0,1],[255,40,0,1],[255,40,0,1]]
				]; 
		_fog1 setParticleRandom [3, [0.1, 0.1, 0.1], [0, 0, -0.1], 2, 0.15, [0, 0, 0, 0.1], 0, 0]; 
		_fog1 setParticleCircle [0.001, [0, 0, -0.12]]; 
		_fog1 setDropInterval 0.01; 
		_fog1 attachTo [_this,[0,0,0]];
		_smlfirelight = "#lightpoint" createVehicleLocal (getpos _fulgi);
		_smlfirelight setPosATL (getPosATL _this);
		_smlfirelight setLightAmbient [1, 0.2, 0]; 
		_smlfirelight setLightColor [1, 0.2, 0]; 
		_smlfirelight setLightBrightness 0.4;
		_smlfirelight setLightUseFlare true;
		_smlfirelight setLightDayLight true;
		_smlfirelight setLightFlareSize 1;
		_smlfirelight setLightFlareMaxDistance 400; 
		_smlfirelight attachTo [_this,[0,0,0]];
		_fog1 setParticleFire [5,1,0.1];
		_fog1 say3D ["hellspawn_fireball_loop",150];
		waitUntil {sleep 0.1; !(alive _this)};
		deleteVehicle _fulgi;
		deleteVehicle _smlfirelight;
		deleteVehicle _fog1;
	}] remoteExec ["spawn", 0];
	_throwableItem setPosATL (_smasher modelToWorldVisual _position);
	detach _throwableItem;
	_dir = (_smasher getDir _enemy);
	_vel = velocity _smasher;
	_distance = (_smasher distance _enemy) * 0.7;
	_pos = (getPosASL _enemy) select 2;
	_pos1 = (getPosASL _smasher) select 2;
	_actPos = _pos - _pos1;
	switch true do {
		case (_actPos < 0): {
			_throwableItem setVelocity [(_vel select 0)+(sin _dir*_distance),(_vel select 1)+(cos _dir*_distance),_actPos + 6.2];
		};
		case (_actPos > 4): {
			_throwableItem setVelocity [(_vel select 0)+(sin _dir*_distance),(_vel select 1)+(cos _dir*_distance),_actPos + 3];
		};
		default {
			_distance = (_smasher distance _enemy) * 0.86;
			_throwableItem setVelocity [(_vel select 0)+(sin _dir*_distance),(_vel select 1)+(cos _dir*_distance),_actPos + 4.6];
		};
	};
	uiSleep 0.1;
	_throwableItem spawn {
	_grenade = _this;
	_actualHitClass = "#particlesource" createVehicle position _grenade; 
	_actualHitClass attachTo [_grenade,[0,0,0]];
	waitUntil {sleep 0.1; !(alive _grenade)};
	{
		if ((alive _x) and (getText (configfile >> 'CfgVehicles' >> typeOf _x >> 'moves') == 'CfgMovesMaleSdr')) then {
				_x setDamage 1;
				_rndAnim = selectRandom ["acid_death_human_1","acid_death_human_2","acid_death_human_3"];
				[_x, _rndAnim] remoteExec ["switchMove",0];
				[_x, _rndAnim, 100, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				_x call WBK_Smasher_CreateBloodParticle;
		};
	} forEach nearestObjects [_actualHitClass,["MAN"],7];
	_actualHitClass spawn WBK_Smasher_CreateCamShake;
	[_actualHitClass, {
		if (isDedicated) exitWith {};
		_fireflies  = "#particlesource" createVehiclelocal getposaTL _this; 
		_fireflies setParticleRandom [0,[0.5,0.5,0],[0.9,0.9,0.5],1,0,[0,0,0,0.1],1,1];
		_fireflies setDropInterval 0.1;
		_fireflies setParticleCircle [7,[0,0,0]];
		_fireflies setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1],"","Billboard",1,14,[0,0,0.1],[0,0,0.5],13,1.3,1,0,[0.1],[[1,0.2,0,1]],[1],0,0,"","",_this, 0, false, 0.1, [[255,40,0,1],[255,40,0,1],[255,40,0,1]]];
		_fulgi  = "#particlesource" createVehiclelocal getposaTL _this; 
		_fulgi setParticleRandom [0, [1, 1, 0], [5, 5, 8], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
		_fulgi setDropInterval 0.01;
		_fulgi setParticleCircle [0, [0, 0, 0]];
		_fulgi setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1],"","Billboard",1,15,[0,0,0],[0,0,0],0,1.7,1,0,[0.15],[[1,0.2,0,1]],[1],0,0,"","",_this, 0, false, 0.4, [[255,40,0,1],[255,40,0,1],[255,40,0,1]]]; 
		_fog1 = "#particlesource" createVehicleLocal getposaTL _this;
		_fog1 setParticleParams [ 
				["\A3\data_f\cl_exp", 1, 0, 1], "", "Billboard", 1, 1, 
					[0, 0, 0], [0, 0, 0], 1, 1.25, 1, 0, 
					[1.3,1.6],[[1,0.2,0,1]], [1000], 1, 0, "", "", _this, 0, false, -1, [[255,40,0,1],[255,40,0,1],[255,40,0,1]]
				]; 
		_fog1 setParticleRandom [3, [4, 4, 0.3], [0, 0, -0.1], 2, 0.15, [0, 0, 0, 0.1], 0, 0]; 
		_fog1 setParticleCircle [2, [0, 0, -0.12]]; 
		_fog1 setDropInterval 0.01; 
		_fog1 setParticleFire [15,2,0.1];
		_smlfirelight = "#lightpoint" createVehicleLocal (getpos _fulgi);
		_smlfirelight setPosATL (getPosATL _this);
		_smlfirelight setLightAmbient [1, 0.2, 0]; 
		_smlfirelight setLightColor [1, 0.2, 0]; 
		_smlfirelight setLightBrightness 1;
		_smlfirelight setLightUseFlare true;
		_smlfirelight setLightDayLight true;
		_smlfirelight setLightFlareSize 5;
		_smlfirelight setLightFlareMaxDistance 400; 
		_fog1 say3D ["hellspawn_fireball_hit",400];
		deleteVehicle _fulgi;
		uisleep 4;
		_fog1 say3D ["hellspawn_fireball_idle",170];
		uisleep 18;
		deleteVehicle _smlfirelight;
		deleteVehicle _fog1;
		deleteVehicle _fireflies;
	}] remoteExec ["spawn", 0];
	uisleep 22;
	deleteVehicle _actualHitClass;
	};
};


WBK_Smasher_FireAttack = {
	_this setVariable ["CanThrowAcid",1];
	_this spawn {uiSleep WBK_Zombies_Smasher_FireAttackCooldown; _this setVariable ["CanThrowAcid",nil];};
	[_this, "WBK_Smasher_Attack_Fire"] remoteExec ["switchMove", 0];
	[_this, "WBK_Smasher_Run"] remoteExec ["playMoveNow", 0];
	_enemy = _this findNearestEnemy _this;
	[_this, selectRandom ["Smasher_attack_4","Smasher_attack_6","Smasher_attack_7"], 170, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";		
	_loopPathfindDoMove = [{
		_array = _this select 0;
		_unit = _array select 0;
		_nearEnemy = _array select 1;
		_anim = _array select 2;
		if (!(animationState _unit == _anim) or (lifeState _unit == "INCAPACITATED") or !(alive _unit)) exitWith {};
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
	}, 0.01, [_this, _enemy, "WBK_Smasher_Attack_Fire"]] call CBA_fnc_addPerFrameHandler;
	_loopPathfindDoMove spawn {uiSleep 2.4; [_this] call CBA_fnc_removePerFrameHandler;};
	uiSleep 0.75;
	if (animationState _this != "WBK_Smasher_Attack_Fire") exitWith {};
	[_this, "Smasher_execution_end", 170, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_this, selectRandom ["hellspawn_fireball_start_1","hellspawn_fireball_start_2"], 300, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_this, {
		if (isDedicated) exitWith {};
		_fulgi  = "#particlesource" createVehiclelocal getposaTL _this; 
		_fulgi setParticleRandom [0, [1, 1, 0], [0, 0, 3], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
		_fulgi setDropInterval 0.01;
		_fulgi setParticleCircle [0, [0, 0, 0]];
		_fulgi setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1],"","Billboard",1,15,[0,0,0],[0,0,0],0,1.7,1,0,[0.15],[[1,0.2,0,1]],[1],0,0,"","",_fulgi, 0, false, -1, [[255,40,0,1],[255,40,0,1],[255,40,0,1]]]; 
		_fulgi attachTo [_this,[0,0,0],"Smash_Hand_R"];
		_smlfirelight = "#lightpoint" createVehicleLocal (getpos _fulgi);
		_smlfirelight setPosATL (getPosATL _this);
		_smlfirelight setLightAmbient [1, 0.2, 0]; 
		_smlfirelight setLightColor [1, 0.2, 0]; 
		_smlfirelight setLightBrightness 0.4;
		_smlfirelight setLightUseFlare true;
		_smlfirelight setLightDayLight true;
		_smlfirelight setLightFlareSize 1;
		_smlfirelight setLightFlareMaxDistance 400; 
		_smlfirelight attachTo [_this,[0,0,0],"Smash_Hand_R"];
		uiSleep 0.55;
		deleteVehicle _fulgi;
		deleteVehicle _smlfirelight;
	}] remoteExec ["spawn", 0];
	[_this, {
		if (isDedicated) exitWith {};
		_fulgi  = "#particlesource" createVehiclelocal getposaTL _this; 
		_fulgi setParticleRandom [0, [1, 1, 0], [0, 0, 3], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
		_fulgi setDropInterval 0.01;
		_fulgi setParticleCircle [0, [0, 0, 0]];
		_fulgi setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1],"","Billboard",1,15,[0,0,0],[0,0,0],0,1.7,1,0,[0.15],[[1,0.2,0,1]],[1],0,0,"","",_fulgi, 0, false, -1, [[255,40,0,1],[255,40,0,1],[255,40,0,1]]]; 
		_fulgi attachTo [_this,[0,0,0],"Smash_Hand_L"];
		_smlfirelight = "#lightpoint" createVehicleLocal (getpos _fulgi);
		_smlfirelight setPosATL (getPosATL _this);
		_smlfirelight setLightAmbient [1, 0.2, 0]; 
		_smlfirelight setLightColor [1, 0.2, 0]; 
		_smlfirelight setLightBrightness 0.4;
		_smlfirelight setLightUseFlare true;
		_smlfirelight setLightDayLight true;
		_smlfirelight setLightFlareSize 1;
		_smlfirelight setLightFlareMaxDistance 400; 
		_smlfirelight attachTo [_this,[0,0,0],"Smash_Hand_L"];
		uiSleep 1.1;
		deleteVehicle _fulgi;
		deleteVehicle _smlfirelight;
	}] remoteExec ["spawn", 0];
	uiSleep 0.55;
	if (animationState _this != "WBK_Smasher_Attack_Fire") exitWith {};
	[_this, _enemy, [1.8,4,1.3]] spawn WBK_CreateHellFireball;
	uiSleep 0.55;
	if (animationState _this != "WBK_Smasher_Attack_Fire") exitWith {};
	[_this, _enemy, [-1.8,4,1.3]] spawn WBK_CreateHellFireball;
};




WBK_CreateHellSpawnParticle = {
	[_this,{ 
		if (isDedicated) exitWith {}; 
		playSound3D [selectRandom ["\WBK_Zombies_Smasher\sounds\hellspawn_fireball_start_1.ogg","\WBK_Zombies_Smasher\sounds\hellspawn_fireball_start_2.ogg"], _this, false, getPosASL _this, 5, 1, 500, 0, true];
		_dustEffect = "#particlesource" createVehicleLocal getPosATL _this;  
		_dustEffect setParticleClass "HDustVTOL1";  
		_dustEffect setPosATL (getPosATL _this);
		_ripple = "#particlesource" createVehicleLocal getposatl _this; 
		_ripple setParticleCircle [0,[0,0,0]]; 
		_ripple setParticleRandom [0,[0.25,0.25,0],[0.175,0.175,0],0,0.25,[0,0,0,0.1],0,0]; 
		_ripple setParticleParams [["\A3\data_f\ParticleEffects\Universal\Refract.p3d",1,0,1], "", "Billboard", 1, 0.5, [0, 0, 0], [0, 0, 0],0,10,7.9,0, [30,1000], [[1, 1, 1, 1], [1, 1, 1, 1]], [0.08], 1, 0, "", "", _ripple]; 
		_ripple setDropInterval 0.1; 
		_ripple spawn {uisleep 1;deleteVehicle _this;}; 
		_jdam_bomb = _this; 
		_size_rad = 10; 
		_li_exp = "#lightpoint" createVehicleLocal getPosATL _jdam_bomb; 
		_li_exp attachTo [_jdam_bomb, [0,0,1]]; 
		_li_exp setLightAttenuation [ 0, 0,  0,  0, _size_rad,800]; 
		_li_exp setLightIntensity 1500; 
		_li_exp setLightBrightness _size_rad; 
		_li_exp setLightDayLight true; 
		_li_exp setLightFlareSize 10; 
		_li_exp setLightFlareMaxDistance 2000; 
		_li_exp setLightAmbient [1, 0.2, 0];  
		_li_exp setLightColor [1, 0.2, 0];  
		_li_exp setLightBrightness 6;  
		_li_exp setLightUseFlare true;   
		detach _li_exp;
		_fog1 = "#particlesource" createVehicleLocal getposaTL _this; 
		 _fog1 setParticleParams [  
		   ["\A3\data_f\cl_exp", 1, 0, 1], "", "Billboard", 1, 1,  
			[0, 0, -1], [0, 0, -8], 1, 1.25, 1, 0,  
			[1.3,1.6],[[1,0.2,0,1]], [1000], 1, 0, "", "", _fog1, 0, false, -1, [[255,40,0,1],[255,40,0,1],[255,40,0,1]] 
		   ];  
		 _fog1 setParticleRandom [0, [1, 1, 2], [15, 15, 0], 0, 0.25, [0.05, 0.05, 0.05, 0.1], 0, 0]; 
		 _fog1 setParticleCircle [0.001, [0, 0, -0.12]];  
		 _fog1 setDropInterval .0004; 
		 _fog1 attachTo [_this,[0,0,3]]; 
		 detach _fog1;
		uisleep 0.4; 
		deletevehicle _fog1; 
		uisleep 0.4; 
		deleteVehicle _li_exp; 
		uisleep 1; 
		deleteVehicle _dustEffect; 
	}] remoteExec ["spawn", 0];
};


WBK_Hellspawn_Teleport = {
	_smaher = _this;
	_smaher setVariable ["CanTeleport",1];
	_smaher spawn {uiSleep WBK_Zombies_Smasher_TeleportAttackCooldown; _this setVariable ["CanTeleport",nil];};
	_enemy = _this findNearestEnemy _this;
	_smaher call WBK_CreateHellSpawnParticle;
	[_smaher, "WBK_Smasher_inAir_start_onRun"] remoteExec ["switchMove", 0]; 
	uiSleep 0.2;
	_smaher setPos [0,0,5000];
	uiSleep 1;
	[_smaher, "WBK_Smasher_inAir"] remoteExec ["switchMove", 0]; 
	[_smaher, "WBK_Smasher_Run"] remoteExec ["playMoveNow", 0];
	_smaher setDir (getDir _enemy);
	_smaher setPosATL (_enemy modelToWorldVisual [0,-3,4]);
	_smaher call WBK_CreateHellSpawnParticle;
};