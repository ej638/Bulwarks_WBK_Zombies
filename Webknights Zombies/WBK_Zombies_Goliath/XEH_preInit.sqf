WBK_Goliath_ShardKill = {
if ((getText (configfile >> 'CfgVehicles' >> typeOf _this >> 'moves') != 'CfgMovesMaleSdr') and (getText (configfile >> 'CfgVehicles' >> typeOf _this >> 'moves') != 'CfgMovesMaleSpaceMarine')) exitWith {};
_this setDamage 1;
_Shard = "Goliath_Shard_1" createVehicle [0,0,0];
_Shard attachTo [_this,[0,-0.7,0.6]]; 
_y = 0;        
_p = 60;        
_r  = 0;        
[_Shard,[               
 [sin _y * cos _p, cos _y * cos _p, sin _p],               
 [[sin _r, -sin _p, cos _r * cos _p], -_y] call BIS_fnc_rotateVector2D               
]] remoteExec ["setVectorDirAndUp",0];  
if (_this isKindOf "TIOWSpaceMarine_Base") then {
	[_Shard,1.3] remoteExec ["setObjectScale",0];
};
[_this, "Goliaph_Sync_ImpaledThrust"] remoteExec ["switchMove",0];
[_this, "Disable_Gesture"] remoteExec ["playActionNow",0];
[_this, "dobi_blood_1", 250, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
[_this, { 
	 _object = _this; 
	 if (isDedicated) exitWith {}; 
	 _blood = "#particlesource" createVehicleLocal (getposATL _object);          
	_blood attachTo [_object,[0,0,0],"Spine3"];  
	_blood setParticleParams [ 
			["\a3\Data_f\ParticleEffects\Universal\Universal", 16, 13, 1, 32],   //model name            
			"",   //animation            
			"billboard", //type            
			0.1, 2, //period and lifecycle            
			[0, 0, 0], //position            

			[3 + random -6, 3 + random -6, 2], //movement vector            
			5, 6, 0.4, 0.4, //rotation, weight, volume , rubbing            
			[0.05, 0.7], //size transform            
			[[0.5,0,0,0.6], [0.8,0,0,0.1], [0.1,0,0,0.03]],    
			[0.00001],    
			0.4,    
			0.4,    
			"",    
			"",    
			"",   
			360, //angle             
			false, //on surface             
			0 //bounce on surface     
		];  
	_blood setdropinterval 0.01;  
	 _breath = "#particlesource" createVehicleLocal (getposATL _object);                       
	 _breath setParticleParams             
	  [             
	   ["\a3\Data_f\ParticleEffects\Universal\meat_ca", 1, 0, 1], //shape name             
	   "", //anim name             
	   "spaceObject",         
	   0.5, 12, //timer period & life time             
	   [0, 0, 0], //pos          
	   [3 + random -3, 2 + random -2, random 3], //moveVel        
	   1,1.275,0.2,0, //rotation vel, weight, volume, rubbing             
	   [1.6,0], //size transform            
	   [[0.005,0,0,0.05], [0.006,0,0,0.06], [0.2,0,0,0]],       
	   [1000], //animationPhase (speed in config)             
	   1, //randomdirection period             
	   0.1, //random direction intensity             
	   "", //onTimer             
	   "", //before destroy             
	   "", //object             
	   0, //angle             
	   false, //on surface             
	   0.0 //bounce on surface             
	  ];             
	 _breath setParticleRandom [0.5, [0, 0, 0], [3.25, 0.25, 2.25], 1, 0.5, [0, 0, 0, 0.1], 0, 0, 10];       
	 _breath setDropInterval 0.01;             
	 _breath attachTo [_object,[0,0,0],"Spine3"];   
	 uisleep 0.7; 
	 deleteVehicle _breath;  
	 uisleep 0.7; 
	 deleteVehicle _blood;  
	}] remoteExec ["spawn", [0,-2] select isDedicated,false]; 
};

WBK_Goliath_SpecialAttackGroundShard = {
if ((getText (configfile >> 'CfgVehicles' >> typeOf _this >> 'moves') != 'CfgMovesMaleSdr') and (getText (configfile >> 'CfgVehicles' >> typeOf _this >> 'moves') != 'CfgMovesMaleSpaceMarine')) exitWith {};
_this setDamage 1;
_Shard = "Goliath_Shard_1" createVehicle [0,0,0]; 
_Shard attachTo [_this,[-0.038,-0.1,0.68]];   
_y = 0;          
_p = -90;          
_r  = 0;          
[_Shard,[                 
 [sin _y * cos _p, cos _y * cos _p, sin _p],                 
 [[sin _r, -sin _p, cos _r * cos _p], -_y] call BIS_fnc_rotateVector2D                 
]] remoteExec ["setVectorDirAndUp",0];  
if (_this isKindOf "TIOWSpaceMarine_Base") then {
	[_Shard,1.3] remoteExec ["setObjectScale",0];
};
_lamd = "Land_RoadCrack_01_4x4_F" createVehicle position _this; 
_lamd attachto [_this,[0,0,0]];  
detach _lamd;
_rndAnim = selectRandom ["Goliaph_Sync_ImpaledGround_1","Goliaph_Sync_ImpaledGround_2","Goliaph_Sync_ImpaledGround_3","Goliaph_Sync_ImpaledGround_4"];
[_this, _rndAnim] remoteExec ["switchMove",0];
if (_rndAnim == "Goliaph_Sync_ImpaledGround_2") then {
	[_this, "WBK_DosHead_FrontHole"] remoteExec ["setFace",0];
	removeGoggles _this;
};
[_this, "Disable_Gesture"] remoteExec ["playActionNow",0];
[_this, selectRandom ["Goliath_Taunt_1","Goliath_Taunt_2"], 250, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
[_this, selectRandom ["sword_hit_1","sword_hit_2","sword_hit_3","sword_hit_4","sword_hit_5","sword_hit_6"], 250, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
[_this, { 
	 _object = _this; 
	 if (isDedicated) exitWith {}; 
	_aslLoc = _this;
	_col = [0,0,0];
	_c1 = _col select 0;
	_c2 = _col select 1;
	_c3 = _col select 2;
	_rocks1 = "#particlesource" createVehicleLocal getPosAsl _aslLoc;
	_rocks1 setposasl getPosAsl _aslLoc;
	_rocks1 setParticleParams [["\A3\data_f\ParticleEffects\Universal\Mud.p3d", 1, 0, 1], "", "SpaceObject", 1, 12.5, [0, 0, 0], [0, 0, 15], 5, 100, 7.9, 1, [.11, .11], [[0.1, 0.1, 0.1, 1], [0.25, 0.25, 0.25, 0.5], [0.5, 0.5, 0.5, 0]], [0.08], 1, 0, "", "", _aslLoc,0,false,0.3];
	_rocks1 setParticleRandom [0, [1, 1, 0], [6, 6, 2], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
	_rocks1 setDropInterval 0.01;
	_rocks1 setParticleCircle [0, [0, 0, 0]];

	_rocks2 = "#particlesource" createVehicleLocal getPosAsl _aslLoc;
	_rocks2 setposasl getPosAsl _aslLoc;
	_rocks2 setParticleParams [["\A3\data_f\ParticleEffects\Universal\Mud.p3d", 1, 0, 1], "", "SpaceObject", 1, 12.5, [0, 0, 0], [0, 0, 15], 5, 100, 7.9, 1, [.06, .06], [[0.1, 0.1, 0.1, 1], [0.25, 0.25, 0.25, 0.5], [0.5, 0.5, 0.5, 0]], [0.08], 1, 0, "", "", _aslLoc,0,false,0.3];
	_rocks2 setParticleRandom [0, [1, 1, 0], [6, 6, 2], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
	_rocks2 setDropInterval 0.01;
	_rocks2 setParticleCircle [0, [0, 0, 0]];

	_rocks3 = "#particlesource" createVehicleLocal getPosAsl _aslLoc;
	_rocks3 setposasl getPosAsl _aslLoc;
	_rocks3 setParticleParams [["\A3\data_f\ParticleEffects\Universal\Mud.p3d", 1, 0, 1], "", "SpaceObject", 1, 12.5, [0, 0, 0], [0, 0, 15], 5, 100, 7.9, 1, [.03, .03], [[0.1, 0.1, 0.1, 1], [0.25, 0.25, 0.25, 0.5], [0.5, 0.5, 0.5, 0]], [0.08], 1, 0, "", "", _aslLoc,0,false,0.3];
	_rocks3 setParticleRandom [0, [1, 1, 0], [6, 6, 2], 3, 0.25, [0, 0, 0, 0.1], 0, 0];
	_rocks3 setDropInterval 0.01;
	_rocks3 setParticleCircle [0, [0, 0, 0]];
	_rocks = [_rocks1,_rocks2, _rocks3];

	 
	 _blood = "#particlesource" createVehicleLocal (getposATL _object);          
	_blood attachTo [_object,[0,0,0],"Spine3"];  
	_blood setParticleParams [ 
			["\a3\Data_f\ParticleEffects\Universal\Universal", 16, 13, 1, 32],   //model name            
			"",   //animation            
			"billboard", //type            
			0.1, 2, //period and lifecycle            
			[0, 0, 0], //position            

			[3 + random -6, 3 + random -6, 2], //movement vector            
			5, 6, 0.4, 0.4, //rotation, weight, volume , rubbing            
			[0.05, 0.7], //size transform            
			[[0.5,0,0,0.6], [0.8,0,0,0.1], [0.1,0,0,0.03]],    
			[0.00001],    
			0.4,    
			0.4,    
			"",    
			"",    
			"",   
			360, //angle             
			false, //on surface             
			0 //bounce on surface     
		];  
	_blood setdropinterval 0.01;  
	 _breath = "#particlesource" createVehicleLocal (getposATL _object);                       
	 _breath setParticleParams             
	  [             
	   ["\a3\Data_f\ParticleEffects\Universal\meat_ca", 1, 0, 1], //shape name             
	   "", //anim name             
	   "spaceObject",         
	   0.5, 12, //timer period & life time             
	   [0, 0, 0], //pos          
	   [3 + random -3, 2 + random -2, random 3], //moveVel        
	   1,1.275,0.2,0, //rotation vel, weight, volume, rubbing             
	   [1.6,0], //size transform            
	   [[0.005,0,0,0.05], [0.006,0,0,0.06], [0.2,0,0,0]],       
	   [1000], //animationPhase (speed in config)             
	   1, //randomdirection period             
	   0.1, //random direction intensity             
	   "", //onTimer             
	   "", //before destroy             
	   "", //object             
	   0, //angle             
	   false, //on surface             
	   0.0 //bounce on surface             
	  ];             
	 _breath setParticleRandom [0.5, [0, 0, 0], [3.25, 0.25, 2.25], 1, 0.5, [0, 0, 0, 0.1], 0, 0, 10];       
	 _breath setDropInterval 0.01;             
	 _breath attachTo [_object,[0,0,0],"Spine3"];   
	 uiSleep 0.3;
	 {
		deletevehicle _x;
	 } foreach _rocks;
	 uisleep 0.5; 
	 deleteVehicle _breath;  
	 uisleep 0.7; 
	 deleteVehicle _blood;  
	}] remoteExec ["spawn", [0,-2] select isDedicated,false]; 
};

WBK_fnc_ProjectileCreate_Zombies = {   
params   
[   
 ["_shooter", objNull, [objNull]],   
 ["_startPos", [0.0 , 0.0, 0.0], [[]]],   
 ["_class", "M_Titan_AT", ["", objNull]],   
 ["_target", objNull, [objNull]],   
 ["_tgtPos", [0.0 , 0.0, 0.0], [[]]],   
 ["_speed", 100.0, [0.0]],   
 ["_destroyTarget", true, [true]],   
 ["_localOffset", [0.0, 0.0, 0.0], [[]]],   
 ["_minDistanceToTarget", 8.0, [0.0]],   
 ["_function", "", [""]],   
 ["_isGlobalFunction", false, [true]]   
];   
if (count _startPos != 3 || {{typeName _x != typeName 0} count _startPos > 0}) exitWith {"fn_guidedProjectile invalid position, not a 3D vector" call BIS_fnc_error};   
if (_startPos isEqualTo [0,0,0]) exitWith {"fn_guidedProjectile invalid position, at 0,0,0" call BIS_fnc_error};   
if (typeName _class == typeName "" && {_class == ""}) exitWith {"fn_guidedProjectile invalid class provided" call BIS_fnc_error};   
if (typeName _class == typeName objNull && {isNull _class}) exitWith {"fn_guidedProjectile invalid object provided" call BIS_fnc_error};   
if (isNull _target) exitWith {"fn_guidedProjectile invalid target provided" call BIS_fnc_error};   
private _rocket = if (typeName _class == typeName "") then {createVehicle [_class, [0,0,1000], [], 0, "CAN_COLLIDE"]} else {_class};   
 
if (isNull _rocket) exitWith   
{   
 ["fn_guidedProjectile could not spawn rocket of class %1 at %2", _class, _startPos] call BIS_fnc_error;   
};   
if (_function != "" && {call compile format["!isNil {%1}", _function]}) then   
{   
 [_rocket] remoteExec [_function, if (_isGlobalFunction) then {0} else {2}];   
};   
_rocket setPosASL [((_shooter modelToWorldVisualWorld [0.3,3,0]) select 0),((_shooter modelToWorldVisualWorld [0.3,3,0]) select 1),_startPos select 2];   
_rocket setShotParents [vehicle _shooter, _shooter];  
 
 private _currentPos = getPosASLVisual _rocket;   
 private _targetPos = _tgtPos;   
   
 private _forwardVector = vectorNormalized (_targetPos vectorDiff _currentPos);   
 private _rightVector = (_forwardVector vectorCrossProduct [0,0,1]) vectorMultiply -1;   
 private _upVector = _forwardVector vectorCrossProduct _rightVector;   
   
 private _targetVelocity = _forwardVector vectorMultiply _speed;   
 
 [_rocket,[_forwardVector, _upVector]] remoteExec ["setVectorDirAndUp",0];   
 [_rocket,_targetVelocity] remoteExec ["setVelocity",0];   
 uisleep 20;   
 deleteVehicle _rocket;   
};



WBK_GoliaphProceedDamage = {
	params ["_goliaph","_anim","_AttackDist"];
	if (!(alive _goliaph) || (animationState _goliaph != _anim)) exitWith {};
	_goliaph spawn WBK_Smasher_CreateCamShake;
	[_goliaph, selectRandom ["Goliath_Swing_1","Goliath_Swing_2","Goliath_Swing_3"], 300, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	if (animationState _goliaph == "goliaph_melee_2" || animationState _goliaph == "goliaph_melee_3") then {
		[_goliaph, "Goliath_GroundHit", 245, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	};
	{
		switch true do {
			case ((typeOf _x isKindOf "WBK_Goliaph_1") && (side _x == side _goliaph)): {};
			case ((typeOf _x isKindOf "WBK_SpecialZombie_Smasher_1") && (side _x == side _goliaph)): {};
			case ((_x == _goliaph) || !(alive _goliaph) || !(alive _x) || (animationState _x == "WBK_Smasher_Execution")): {};
			default {
				[_goliaph, _x] spawn {
					_zombie = _this select 0;
					_enemy = _this select 1;
					[_enemy, selectRandom ["Goliath_human_hit_1","Goliath_human_hit_2","Goliath_human_hit_3"], 200, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
					_enemy setDamage 1;
					uisleep 0.05;
					if (animationState _zombie == "goliaph_melee_2" || animationState _zombie == "goliaph_melee_3") then {
						[_enemy, [_zombie vectorModelToWorld [0,1000,2500], _enemy selectionPosition "head", false]] remoteExec ["addForce", _enemy];
					}else{
						[_enemy, [_zombie vectorModelToWorld [0,4000,800], _enemy selectionPosition "head", false]] remoteExec ["addForce", _enemy];
					};
				};
			};
		};
	} forEach nearestObjects [_goliaph,["MAN"],_AttackDist];
	{
		_x setDamage 1;
		[_x, "Smasher_hit_vehicle", 245, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		_dir = getDirVisual _goliaph;
		_vel = velocity _x;
		[_x, [(_vel select 0)+(sin _dir*10),(_vel select 1)+(cos _dir*10),4]] remoteExec ["setVelocity", _x];
	} forEach nearestObjects [_goliaph,["CAR","TANK","AIR","StaticWeapon"],_AttackDist + 1];
	{_x setDamage 1;} forEach nearestObjects [_goliaph,["Static"],_AttackDist + 2];
	{_x setDamage 1;} forEach nearestTerrainObjects [_goliaph,[],_AttackDist + 2];
	_ins = lineIntersectsSurfaces [
		AGLToASL (_goliaph modelToWorld [0,0,0.5]), 
		AGLToASL (_goliaph modelToWorld [0,5,0.5]), 
		_goliaph,
		objNull,
		true,
		1,
		"FIRE",
		"GEOM"
	];
	if (count _ins == 0) exitWith {};
	(_ins select 0 select 2) setDamage 1;
};

WBK_Goliaph_ThrowSpike = {
	_mutant = _this;
	[_mutant, "Goliaph_Throw"] remoteExec ["switchMove",0]; 
	[_mutant, "Goliaph_Walk"] remoteExec ["playMoveNow",0]; 
	_mutant setVariable ["Goliaph_CanThrowSpike",1];
	_mutant spawn {
		uiSleep 30; 
		_this setVariable ["Goliaph_CanThrowSpike",nil];
	};
	uiSleep 0.5;
	if (!(alive _mutant) or !(animationState _mutant == "goliaph_throw")) exitWith {};
	[_mutant, selectRandom ["Goliath_human_hit_1","Goliath_human_hit_2","Goliath_human_hit_3"], 200, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	uiSleep 1;
	_en = _mutant findNearestEnemy _mutant;
	if ((isNull _en) or !(alive _mutant) or !(animationState _mutant == "goliaph_throw")) exitWith {}; 
	[_mutant, selectRandom ["Smasher_swoosh_1","Smasher_swoosh_2"], 250, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_mutant,(_mutant modelToWorldVisualWorld [-0.7,5,2.3]),"Goliath_Projectile",_en,aimPos (vehicle _en), 365, false, [0,0,0]] spawn WBK_fnc_ProjectileCreate_Zombies; 
};


WBK_Goliaph_SyncAnim_1 = {
(_this select 1) attachTo [(_this select 0),[0,0,0]];
(_this select 1) setDamage 1;
{
[_x, "Goliaph_Sync_1"] remoteExec ["switchMove",0];
} forEach _this;
[(_this select 1), "Disable_Gesture"] remoteExec ["playActionNow",0];
[(_this select 0), "Goliaph_Walk"] remoteExec ["playMoveNow",0];  
if (isNil {(_this select 1) getVariable "WBK_AI_ISZombie"}) then {
	(_this select 1) spawn {
		_prtSrc = "#particlesource" createVehicle (getPosATL _this);
		_prtSrc setPosATL (getPosATL _this);
		[_prtSrc, selectRandom ["Smasher_human_scream_1","Smasher_human_scream_2","Smasher_human_scream_3"], 220] call CBA_fnc_GlobalSay3d;
		uiSleep 0.3;
		deleteVehicle _prtSrc;
		[_this, selectRandom ["New_Death_7","New_Death_5","New_Death_6"], 220, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	};
};
uiSleep 0.3;
[(_this select 0),"Goliaph_Sync_1",4] call WBK_GoliaphProceedDamage;
[(_this select 1), "dobi_CriticalHit", 200, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
[(_this select 1), "dobi_bones", 150, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
[(_this select 1), {
	_object = _this;
	if (isDedicated) exitWith {};
	_breath = "#particlesource" createVehicleLocal (getposATL _object);                      
	_breath setParticleParams            
		[            
			["\a3\Data_f\ParticleEffects\Universal\meat_ca", 1, 0, 1], //shape name            
			"", //anim name            
			"spaceObject",        
			0.5, 12, //timer period & life time            
			[0, 0, 0], //pos         
			[3 + random -3, 2 + random -2, random 3], //moveVel       
			1,1.275,0.2,0, //rotation vel, weight, volume, rubbing            
			[1.6,0], //size transform           
			[[0.005,0,0,0.05], [0.006,0,0,0.06], [0.2,0,0,0]],      
			[1000], //animationPhase (speed in config)            
			1, //randomdirection period            
			0.1, //random direction intensity            
			"", //onTimer            
			"", //before destroy            
			"", //object            
			0, //angle            
			false, //on surface            
			0.0 //bounce on surface            
		];            
	_breath setParticleRandom [0.5, [0, 0, 0], [3.25, 0.25, 2.25], 1, 0.5, [0, 0, 0, 0.1], 0, 0, 10];      
	_breath setDropInterval 0.01;            
	_breath attachTo [_object,[0,0,0.2], "head"];  
	uisleep 0.25;
	deleteVehicle _breath; 
}] remoteExec ["spawn", [0,-2] select isDedicated,false];
uiSleep 0.5;
detach (_this select 1);
};




WBK_Goliaph_SyncAnim_2 = {  
(_this select 1) attachTo [(_this select 0),[0,0,0]];  
(_this select 1) setDamage 1;  
{  
[_x, "Goliaph_Sync_2"] remoteExec ["switchMove",0];  
} forEach _this;  
[(_this select 1), "Disable_Gesture"] remoteExec ["playActionNow",0]; 
[(_this select 0), "Goliaph_Walk"] remoteExec ["playMoveNow",0];  
if (isNil {(_this select 1) getVariable "WBK_AI_ISZombie"}) then {  
 (_this select 1) spawn {  
  _prtSrc = "#particlesource" createVehicle (getPosATL _this);  
  _prtSrc attachTo [_this,[0,0,0],"head"];
  [_prtSrc, selectRandom ["get_deathScream_1","get_deathScream_2","get_deathScream_3"], 220] call CBA_fnc_GlobalSay3d;  
  uiSleep 1.9;  
  deleteVehicle _prtSrc;  
  [_this, selectRandom ["bloodCought_1","bloodCought_2","bloodCought_3"], 120, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  
 };  
};  
uiSleep 0.3; 
[(_this select 1), "dobi_bones", 200, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  
uiSleep 1.3;
[(_this select 0),"Goliaph_Sync_2",4] call WBK_GoliaphProceedDamage;
[(_this select 0), selectRandom ["Goliath_V_Roar_1","Goliath_V_Roar_2"], 300, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
[(_this select 1), "dobi_CriticalHit", 200, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  
[(_this select 1), "dobi_blood_1", 150, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  
[(_this select 1), {  
 _object = _this;  
 if (isDedicated) exitWith {};  
 _blood = "#particlesource" createVehicleLocal (getposATL _object);           
_blood attachTo [_object,[0,0,0.3],"head"];   
_blood setParticleParams [  
  ["\a3\Data_f\ParticleEffects\Universal\Universal", 16, 13, 1, 32],   //model name             
  "",   //animation             
  "billboard", //type             
  0.1, 2, //period and lifecycle             
  [0, 0, 0], //position             
 
  [3 + random -6, 3 + random -6, 2], //movement vector             
  5, 6, 0.4, 0.4, //rotation, weight, volume , rubbing             
  [0.05, 0.7], //size transform             
  [[0.5,0,0,0.6], [0.8,0,0,0.1], [0.1,0,0,0.03]],     
  [0.00001],     
  0.4,     
  0.4,     
  "",     
  "",     
  "",    
  360, //angle              
  false, //on surface              
  0 //bounce on surface      
 ];   
_blood setdropinterval 0.01;   
 _breath = "#particlesource" createVehicleLocal (getposATL _object);                        
 _breath setParticleParams              
  [              
   ["\a3\Data_f\ParticleEffects\Universal\meat_ca", 1, 0, 1], //shape name              
   "", //anim name              
   "spaceObject",          
   0.5, 12, //timer period & life time              
   [0, 0, 0], //pos           
   [3 + random -3, 2 + random -2, random 3], //moveVel         
   1,1.275,0.2,0, //rotation vel, weight, volume, rubbing              
   [1.6,0], //size transform             
   [[0.005,0,0,0.05], [0.006,0,0,0.06], [0.2,0,0,0]],        
   [1000], //animationPhase (speed in config)              
   1, //randomdirection period              
   0.1, //random direction intensity              
   "", //onTimer              
   "", //before destroy              
   "", //object              
   0, //angle              
   false, //on surface              
   0.0 //bounce on surface              
  ];              
 _breath setParticleRandom [0.5, [0, 0, 0], [3.25, 0.25, 2.25], 1, 0.5, [0, 0, 0, 0.1], 0, 0, 10];        
 _breath setDropInterval 0.01;              
 _breath attachTo [_object,[0,0,0.2], "head"];    
 uisleep 0.3;  
 deleteVehicle _breath;   
 uisleep 0.7;  
 deleteVehicle _blood;   
}] remoteExec ["spawn", [0,-2] select isDedicated,false];  
uiSleep 0.5;  
[(_this select 1), "dobi_blood_2", 150, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  
uiSleep 0.55;  
[(_this select 1), "dobi_fall_2", 100, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  
detach (_this select 1);  
};



WBK_Goliph_RockThrowingAbility = {
	_zombie = _this;
	_zombie setVariable ["CanThrowRocks",1];
	_zombie spawn {uiSleep 45; _this setVariable ["CanThrowRocks",nil];};
	[_zombie, "Goliaph_RockThrow"] remoteExec ["switchMove", 0]; 
	[_zombie, "Goliaph_Walk"] remoteExec ["playMoveNow",0]; 
	_throwableItem = "Smasher_RockGrenade" createVehicle [0,0,12000];
	uiSleep 0.6;
	if (!(animationState _zombie == "Goliaph_RockThrow") or !(alive _zombie)) exitWith {};
	[_zombie, selectRandom ["Goliath_V_Attack_1","Goliath_V_Attack_2","Goliath_V_Attack_3","Goliath_V_Attack_4"], 545, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_zombie, "Smasher_hit", 120, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
	_zombie spawn WBK_Smasher_CreateCamShake;
	_electra = "#particlesource" createVehicle position _zombie; 
	_electra setParticleClass "HDustVTOL1"; 
	_electra attachTo [_zombie,[0,0,0]];
	detach _electra;
	_electra spawn {uiSleep 2; deleteVehicle _this;};
	uiSleep 0.65;
	if (!(animationState _zombie == "Goliaph_RockThrow") or !(alive _zombie)) exitWith {};
	_throwableItem attachTo [_zombie,[0,-1,0],"G_Fist_R",true];
	[_zombie, "Smasher_hit", 150, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
	uiSleep 1.7;
	if (!(animationState _zombie == "Goliaph_RockThrow") or !(alive _zombie)) exitWith {deleteVehicle _throwableItem;};
	[_zombie, selectRandom ["Smasher_swoosh_1","Smasher_swoosh_2"], 340, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_zombie, selectRandom ["Goliath_V_Roar_1","Goliath_V_Roar_1"], 645, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	uiSleep 0.1;
	detach _throwableItem;
	_enemy = _zombie findNearestEnemy _zombie; 
	_dir = (_zombie getDir _enemy);
	_vel = velocity _zombie;
	_distance = (_zombie distance _enemy) * 0.8;
	_pos = (getPosASL _enemy) select 2;
	_pos1 = (getPosASL _zombie) select 2;
	_actPos = _pos - _pos1;
	switch true do {
		case (_actPos < 0): {_throwableItem setVelocity [(_vel select 0)+(sin _dir*_distance),(_vel select 1)+(cos _dir*_distance),_actPos + 6.2];};
		case (_actPos > 4): {_throwableItem setVelocity [(_vel select 0)+(sin _dir*_distance),(_vel select 1)+(cos _dir*_distance),_actPos + 3];};
		default {_distance = (_zombie distance _enemy) * 0.86; _throwableItem setVelocity [(_vel select 0)+(sin _dir*_distance),(_vel select 1)+(cos _dir*_distance),_actPos + 4.6];};
	};
	uiSleep 0.1;
	[_throwableItem, _zombie] spawn {
		_grenade = _this select 0;
		_actualHitClass = "#particlesource" createVehicle position _grenade; 
		_actualHitClass attachTo [_grenade,[0,0,0]];
		_zombie = _this select 1;
		while {alive _grenade} do {
		{
		if ((alive _x) and !(_x == _zombie)) then {
			_x setDamage 1;
			[_x, selectRandom ["Goliath_human_hit_1","Goliath_human_hit_2","Goliath_human_hit_3"], 200, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
		};
		} forEach nearestObjects [_grenade,["MAN"],3];
		uiSleep 0.1;
		};
		[_actualHitClass, "Smash_rockHit", 450] call CBA_fnc_GlobalSay3d;
		_actualHitClass spawn WBK_Smasher_CreateCamShake;
		[_actualHitClass, {
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
			uiSleep 0.3;
			{
				deletevehicle _x;
			} foreach _rocks;
		}] remoteExec ["spawn", [0,-2] select isDedicated,false];
		uisleep 15;
		deleteVehicle _actualHitClass;
	};
};



WBK_Goliaph_ThrowAVehicle = {
_goliaph = _this select 0;
_goliaph setVariable ["CanThrowVic",1];
_goliaph spawn {uiSleep 60; _this setVariable ["CanThrowVic",nil];};
_x = _this select 1;
[_goliaph, "Goliaph_VehicleGrab"] remoteExec ["switchMove", 0]; 
[_goliaph, "Goliaph_Walk"] remoteExec ["playMoveNow",0];
uiSleep 0.2;
if (!(animationState _goliaph == "Goliaph_VehicleGrab") or !(alive _goliaph)) exitWith {};
[_x, "Smasher_hit_vehicle", 345, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
_x attachTo [_goliaph,[-2,0,0],"G_Fist_R",true];
sleep 2;
if (!(animationState _goliaph == "Goliaph_VehicleGrab") or !(alive _goliaph)) exitWith {};
[_goliaph, selectRandom ["Goliath_Swing_1","Goliath_Swing_2","Goliath_Swing_3"], 300, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
detach _x;
sleep 0.1;
_dir = getDirVisual _goliaph; 
_vel = velocity _x; 
[_x, [(_vel select 0)+(sin _dir*23),(_vel select 1)+(cos _dir*23),6]] remoteExec ["setVelocity", _x];
};


[ 
    "WBK_Zommbies_HowFarCanSee_Goliath", 
    "EDITBOX", 
    ["Path calculation distance","How far must be the target in order for a goliath to start running towards ai. Lowering the number will increase performance, as ARMA dont like to calculate path on longer distances."],
    ["WebKnight's Zombies","4) Goliath"],
    "600",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_Goliath_MoveDistanceLimit = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesGoliathHealthParam", 
    "EDITBOX", 
    "Health",
    ["WebKnight's Zombies","4) Goliath"],
    "15000",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_GoliathHP = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesGoliathThrowParam", 
    "CHECKBOX", 
    "Can throw rocks?",
    ["WebKnight's Zombies","4) Goliath"],
    true,
    1,
    {   
        params ["_value"]; 
        WBK_Zombies_GoliatRockAbil = _value; 
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesGoliathThrowShardsParam", 
    "CHECKBOX", 
    "Can throw bone shards?",
    ["WebKnight's Zombies","4) Goliath"],
    true,
    1,
    {   
        params ["_value"]; 
        WBK_Zombies_GoliatSpearAbil = _value; 
    }
] call CBA_fnc_addSetting;



[ 
    "WBK_ZommbiesGoliathUndergroundAttackParam", 
    "CHECKBOX", 
    "Can use AOE spike attack?",
    ["WebKnight's Zombies","4) Goliath"],
    true,
    1,
    {   
        params ["_value"]; 
        WBK_Zombies_GoliatUndergroundAbil = _value; 
    }
] call CBA_fnc_addSetting;



[ 
    "WBK_ZommbiesGoliathUndergroundAttackParam_max", 
    "EDITBOX", 
    "How many targets can be killed by AOE attack?",
    ["WebKnight's Zombies","4) Goliath"],
    "10",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_GoliathMaxAmountAEO = _number;
    }
] call CBA_fnc_addSetting;



[ 
    "WBK_ZommbiesGoliathUndergroundAttackParam_distance", 
    "EDITBOX", 
    "AOE attack radius",
    ["WebKnight's Zombies","4) Goliath"],
    "50",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_GoliathRadiusAEO = _number;
    }
] call CBA_fnc_addSetting;



[ 
    "WBK_ZommbiesGoliathPickupAttackParam", 
    "CHECKBOX", 
    "Can pick up and throw vehicles?",
    ["WebKnight's Zombies","4) Goliath"],
    true,
    1,
    {   
        params ["_value"]; 
        WBK_Zombies_GoliatPickUpAbil = _value; 
    }
] call CBA_fnc_addSetting;
