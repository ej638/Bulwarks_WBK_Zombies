if (!(hasInterface) or (isDedicated)) exitWith {};
[] spawn
{
	waitUntil {!(isNull findDisplay 46)};
	if (isClass (configFile >> "CfgPatches" >> "zen_custom_modules")) then {
	["WBK Zombie Modules", "(Sound) Play Smasher SCREAM (distance)", {
		params ["_pos","_unit"];
		[_pos,{
			if (isDedicated) exitWith {};
			playSound3D [selectRandom ["WBK_Zombies_Smasher\sounds\Smasher_scream_dist_1.ogg","WBK_Zombies_Smasher\sounds\Smasher_scream_dist_2.ogg"], objNull, false, _this, 4, 1, 1000, 0, true];
		}] remoteExec ["spawn",0];
	}] call zen_custom_modules_fnc_register;
	
	["WBK Zombie Modules", "(Sound) Play Smasher SCREAM (close)", {
		params ["_pos","_unit"];
		[_pos,{
			if (isDedicated) exitWith {};
			playSound3D [selectRandom ["WBK_Zombies_Smasher\sounds\Smasher_scream_1.ogg","WBK_Zombies_Smasher\sounds\Smasher_scream_2.ogg"], objNull, false, _this, 4, 1, 1000, 0, true];
		}] remoteExec ["spawn",0];
	}] call zen_custom_modules_fnc_register;
	
	["WBK Zombie Modules", "(Sound) Play Goliath SCREAM (close)", {
		params ["_pos","_unit"];
		[_pos,{
			if (isDedicated) exitWith {};
			playSound3D [selectRandom ["WBK_Zombies_Goliath\sounds\G_Roar_1.ogg","WBK_Zombies_Goliath\sounds\G_Roar_2.ogg"], objNull, false, _this, 4, 1, 1000, 0, true];
		}] remoteExec ["spawn",0];
	}] call zen_custom_modules_fnc_register;
	
	["WBK Zombie Modules", "(Sound) Play Goliath SCREAM (distance)", {
		params ["_pos","_unit"];
		[_pos,{
			if (isDedicated) exitWith {};
			playSound3D [selectRandom ["WBK_Zombies_Goliath\sounds\G_Roar_Far_1.ogg","WBK_Zombies_Goliath\sounds\G_Roar_Far_2.ogg"], objNull, false, _this, 4, 1, 1000, 0, true];
		}] remoteExec ["spawn",0];
	}] call zen_custom_modules_fnc_register;
	
	["WBK Zombie Modules", "(Sound) Play Screamers SCREAM", {
		params ["_pos","_unit"];
		[_pos,{
			if (isDedicated) exitWith {};
			playSound3D [selectRandom ["WBK_Zombies\Sounds\Screamer\screamer_scream_1.ogg","WBK_Zombies\Sounds\Screamer\screamer_scream_2.ogg"], objNull, false, _this, 4, 1, 1000, 0, true];
		}] remoteExec ["spawn",0];
	}] call zen_custom_modules_fnc_register;
	
	["WBK Zombie Modules", "(Sound) Play Screamers CLUE", {
		params ["_pos","_unit"];
		[_pos,{
			if (isDedicated) exitWith {};
			playSound3D [selectRandom ["WBK_Zombies\Sounds\Screamer\screamer_knowsAbout_1.ogg","WBK_Zombies\Sounds\Screamer\screamer_knowsAbout_2.ogg"], objNull, false, _this, 4, 1, 1000, 0, true];
		}] remoteExec ["spawn",0];
	}] call zen_custom_modules_fnc_register;
	
	
	["WBK Zombie Modules", "Kill unit with goliath shard", {
		params ["_pos","_unit"];
		if ((isNull _unit) || !(_unit isKindOf "MAN") || !(alive _unit)) exitWith {systemChat "Must be placed on the unit (AI or PLAYER)";};
		_unit remoteExec ["WBK_Goliath_SpecialAttackGroundShard",_unit];
	}] call zen_custom_modules_fnc_register;
	
	["WBK Zombie Modules", "Turn unit into a zombie", {
		params ["_pos","_unit"];
		if ((isNull _unit) || !(_unit isKindOf "MAN") || (isPlayer _unit) || !(alive _unit)) exitWith {systemChat "Must be placed on the unit (AI)";};
		WBK_ZombieObjectZeus = _unit;
		createDialog "WBK_SelectZombieType";
	}] call zen_custom_modules_fnc_register;
	
	["WBK Zombie Modules", "Place smashers acid", {
		params ["_pos","_unit"];
		_lamd = "Land_RoadCrack_01_4x4_F" createVehicle _pos; 
		[_lamd,{
			{
			_x addCuratorEditableObjects [[_this], true];
			} forEach allCurators;
		}] remoteExec ["call",2];
		[_lamd, {
			if (isDedicated) exitWith {};
			_fireflies  = "#particlesource" createVehiclelocal getposaTL _this; 
			_fireflies setParticleRandom [0,[0.5,0.5,0],[0.9,0.9,0.5],1,0,[0,0,0,0.1],1,1];
			_fireflies setDropInterval 0.1;
			_fireflies setParticleCircle [7,[0,0,0]];
			_fireflies setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1],"","Billboard",1,14,[0,0,0.1],[0,0,0.5],13,1.3,1,0,[0.1],[[0.01,1,0.1,1]],[1],0,0,"","",_fireflies, 0, false, 0.1, [[0.01,100,0.005,1],[0.01,100,0.005,1],[0.01,100,0.005,1]]];
			_fireflies attachTo [_this,[0,0,0.1]];
			_fog1 = "#particlesource" createVehicleLocal getposaTL _this;
			_fog1 setParticleParams [ 
					["\A3\data_f\cl_exp", 1, 0, 1], "", "Billboard", 1, 1, 
						[0, 0, 0], [0, 0, 0], 1, 1.25, 1, 0, 
						[1.3,1.6],[[0.01,1,0.1,1]], [1000], 1, 0, "", "", _fog1, 0, false, -1, [[0.01,100,0.005,1],[0.01,100,0.005,1],[0.01,100,0.005,1]]
					]; 
			_fog1 setParticleRandom [3, [4, 4, 0.3], [0, 0, -0.1], 2, 0.15, [0, 0, 0, 0.1], 0, 0]; 
			_fog1 setParticleCircle [2, [0, 0, -0.12]]; 
			_fog1 setDropInterval 0.01; 
			_fog1 setParticleFire [15,2,0.1];
			_fog1 attachTo [_this,[0,0,0.1]];
			_bubles = "#particlesource" createVehicleLocal getposaTL _this; 
			_bubles attachTo [_this,[0,0,0.1]];
			_bubles setParticleCircle [2, [0, 0, 0]]; 
			_bubles setParticleRandom [0, [4, 4, 0], [0, 0, 0], 0, 0, [0, 0, 0, 0], 0, 0]; 
			_bubles setDropInterval 0.1; 
			_bubles setParticleParams [["\A3\data_f\ParticleEffects\Universal\UnderWaterSmoke",4,0,15,1], "", 
			"Billboard", 10, 10, [0,0,-0.3], [0,0,0], 0, 0.3, 0.2353, 0, [1], [[0.01,1,0.1,1]],[1],0,0,"","",_bubles,0,false,-1,[[0.01,100,0.005,1],[0.01,100,0.005,1],[0.01,100,0.005,1]]]; 
			_smlfirelight = "#lightpoint" createVehicleLocal (getpos _bubles);
			_smlfirelight setPosATL (getPosATL _this);
			_smlfirelight setLightAmbient [0.3, 1, 0]; 
			_smlfirelight setLightColor [0.3, 1, 0]; 
			_smlfirelight setLightBrightness 1;
			_smlfirelight setLightUseFlare true;
			_smlfirelight setLightDayLight true;
			_smlfirelight setLightFlareSize 5;
			_smlfirelight setLightFlareMaxDistance 400; 
			_smlfirelight attachTo [_this,[0,0,0.4]];
			_fog1 spawn {
				while {!isNull _this} do {
					_this say3D ["acid_idle",70];
					uiSleep 40;
				};
			};
			waitUntil {sleep 1; isNull _this};
			deleteVehicle _smlfirelight;
			deleteVehicle _fog1;
			deleteVehicle _bubles;
			deleteVehicle _fireflies;
		}] remoteExec ["spawn", 0];
	}] call zen_custom_modules_fnc_register;
	
	
	["WBK Zombie Modules", "Place smashers hellfire", {
		params ["_pos","_unit"];
		_lamd = "Land_RoadCrack_01_4x4_F" createVehicle _pos; 
		[_lamd,{
			{
			_x addCuratorEditableObjects [[_this], true];
			} forEach allCurators;
		}] remoteExec ["call",2];
		[_lamd, {
			if (isDedicated) exitWith {};
			_fireflies  = "#particlesource" createVehiclelocal getposaTL _this; 
			_fireflies setParticleRandom [0,[0.5,0.5,0],[0.9,0.9,0.5],1,0,[0,0,0,0.1],1,1];
			_fireflies setDropInterval 0.1;
			_fireflies setParticleCircle [7,[0,0,0]];
			_fireflies setParticleParams [["\A3\data_f\cl_exp", 1, 0, 1],"","Billboard",1,14,[0,0,0.1],[0,0,0.5],13,1.3,1,0,[0.1],[[1,0.2,0,1]],[1],0,0,"","",_fireflies, 0, false, 0.1, [[255,40,0,1],[255,40,0,1],[255,40,0,1]]];
		    _fireflies attachTo [_this,[0,0,0.1]];
			_fog1 = "#particlesource" createVehicleLocal getposaTL _this;
			_fog1 setParticleParams [ 
					["\A3\data_f\cl_exp", 1, 0, 1], "", "Billboard", 1, 1, 
						[0, 0, 0], [0, 0, 0], 1, 1.25, 1, 0, 
						[1.3,1.6],[[1,0.2,0,1]], [1000], 1, 0, "", "", _fog1, 0, false, -1, [[255,40,0,1],[255,40,0,1],[255,40,0,1]]
					]; 
			_fog1 setParticleRandom [3, [4, 4, 0.3], [0, 0, -0.1], 2, 0.15, [0, 0, 0, 0.1], 0, 0]; 
			_fog1 setParticleCircle [2, [0, 0, -0.12]]; 
			_fog1 setDropInterval 0.01; 
			_fog1 setParticleFire [15,2,0.1];
			_fog1 attachTo [_this,[0,0,0.1]];
			_smlfirelight = "#lightpoint" createVehicleLocal (getpos _fog1);
			_smlfirelight setPosATL (getPosATL _this);
			_smlfirelight setLightAmbient [1, 0.2, 0]; 
			_smlfirelight setLightColor [1, 0.2, 0]; 
			_smlfirelight setLightBrightness 1;
			_smlfirelight setLightUseFlare true;
			_smlfirelight setLightDayLight true;
			_smlfirelight setLightFlareSize 5;
			_smlfirelight setLightFlareMaxDistance 400; 
			_smlfirelight attachTo [_this,[0,0,0.4]];
			_fog1 spawn {
				while {!isNull _this} do {
					_this say3D ["hellspawn_fireball_idle",60];
					uiSleep 18;
				};
			};
			waitUntil {sleep 1; isNull _this};
			deleteVehicle _smlfirelight;
			deleteVehicle _fog1;
			deleteVehicle _fireflies;
		}] remoteExec ["spawn", 0];
	}] call zen_custom_modules_fnc_register;
	
	};
	
	(findDisplay 46) displayAddEventHandler ["MouseButtonDown", {
		_mutant = missionNamespace getVariable["bis_fnc_moduleRemoteControl_unit", player];
		if (!(isNil "WBK_ZombiePlayerAttack") or !(animationState _mutant in ["wbk_runner_angry_idle","wbk_runner_angry_run","wbk_runner_angry_sprint","wbk_runner_angry_turnl","wbk_runner_angry_turnr"]) or !(alive _mutant) or !(isNull attachedTo _mutant) or (lifeState _mutant == "INCAPACITATED")) exitWith {};
		switch true do {
			case (_this select 1 == 0): {
				if (!(isNil {_mutant getVariable "WBK_Zombie_CustomSounds"})) then {
					[_mutant, selectRandom ((_mutant getVariable "WBK_Zombie_CustomSounds") select 2), 35, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				}else{
					[_mutant, selectRandom ["runner_attack_1","runner_attack_2","runner_attack_3","runner_attack_4","runner_attack_5","runner_attack_6"], 35, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				};
				_mutant spawn {
					WBK_ZombiePlayerAttack = true; [] spawn {uiSleep 0.7; WBK_ZombiePlayerAttack = nil};
					if (gestureState _this == "wbk_zombie_attack_left") then {
						_this playActionNow "wbk_zombie_attack_right";
					}else{
						_this playActionNow "wbk_zombie_attack_left";
					};
					uiSleep 0.1;
					if !(gestureState _this in ["wbk_zombie_attack_left","wbk_zombie_attack_right"]) exitWith {};
					[_this, selectRandom ["melee_whoosh_00","melee_whoosh_01","melee_whoosh_02"], 35, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					uiSleep 0.15;
					if !(gestureState _this in ["wbk_zombie_attack_left","wbk_zombie_attack_right"]) exitWith {};
					{
						switch true do {
							case ((_x == _this) || (((_this worldToModel (_x modelToWorld [0, 0, 0])) select 1) < 0)): {};
							case (!(isNil {_x getVariable "IMS_IsUnitInvicibleScripted"}) || (animationState _x == "STAR_WARS_FIGHT_DODGE_LEFT") || (animationState _x == "STAR_WARS_FIGHT_DODGE_LEFT") || (animationState _x == "STAR_WARS_FIGHT_DODGE_RIGHT") || (animationState _x == "starWars_landRoll") || (animationState _x == "starWars_landRoll_b") || ((typeOf _x isKindOf "WBK_SpecialZombie_Smasher_1") && (side _x == side _this)) || ((typeOf _x isKindOf "WBK_Goliaph_1") && (side _x == side _this)) || ((_x == _this) || !(alive _this) || !(alive _x) || (animationState _x == "WBK_Smasher_Execution"))): {};
							case (lifeState _x == "INCAPACITATED"): {
								[_x, [1, false, _this]] remoteExec ["setDamage",2];
							};
							case ((((_this worldToModel (_x modelToWorld [0, 0, 0])) select 1) > 0) && ((gestureState _x in ["fp_hit_afterblock_2","fp_hit_afterblock_1","fp_knife_block_2","fp_knife_block_1","fp_knife_block","fp_rapier_block","fp_rapier_block_2","fp_rapier_block_1","fp_twohanded_blocked_2","fp_twohanded_blocked_1","fp_onehanded_blocked_2","fp_onehanded_blocked_1","twohanded_sword_heavy_block","wbk_ims_zweitype_block","star_wars_twohandblock","shield_block","twohanded_block","starwars_lightsaber_block_loop","star_wars_fight_alebarda_block_gesture"]) or (_x getVariable "actualSwordBlock" == 1) or (animationState _x in ["starwars_lightsaber_block_1","starwars_lightsaber_block_2","starwars_lightsaber_block_3","starwars_lightsaber_block_heavy"]))): {
								[_x, "dobi_fall_2", 50, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  
								[_x, _this] remoteExec ["concentrationMinus", _x];   
							};
							default {
								[_x,0.48,_this] remoteExec ["WBK_CreateDamage", _x];
								[_x, selectRandom ["PF_Hit_1","PF_Hit_2"], 60, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
							};
						};
				    } forEach nearestObjects [_this,["MAN"],2.8];
				};
			};
			case (_this select 1 == 1): {
				if (!(isNil {_mutant getVariable "WBK_Zombie_CustomSounds"})) then {
					[_mutant, selectRandom ((_mutant getVariable "WBK_Zombie_CustomSounds") select 2), 35, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				}else{
					[_mutant, selectRandom ["runner_dodge_1","runner_dodge_2","runner_dodge_3","runner_dodge_4"], 35, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				};
				_mutant spawn {
					_this setVariable ["IMS_IsUnitInvicibleScripted",1,true];
					uiSleep 0.5;
					_this setVariable ["IMS_IsUnitInvicibleScripted",nil,true];
				};
				switch true do {
					case (jumpDirection == "Right"): {[_mutant, "WBK_Zombie_Evade_R"] remoteExec ["switchMove", 0];};
					case (jumpDirection == "Left"): {[_mutant, "WBK_Zombie_Evade_L"] remoteExec ["switchMove", 0];};
					default {[_mutant, "WBK_Zombie_Evade_B"] remoteExec ["switchMove", 0];};
				};
			};
		};
	}];
	uiSleep 3;
	if (WBK_Zombies_Debug && !isMultiplayer) then {
		onEachFrame {
			{
				if !(isNil {_x getVariable "WBK_AI_ISZombie"}) then {
					_pos = unitAimPositionVisual  _x;    
					_pos set [2,((unitAimPositionVisual _x) select 2) + 0.75];  
					_nearEnemy = _x findNearestEnemy _x;
					switch true do {
						case ((isNull _nearEnemy) or !(alive _nearEnemy) or !(alive _x)): {
							drawIcon3D ["\A3\Ui_f\data\GUI\Cfg\Ranks\lieutenant_gs.paa",[1,0,0,1],_pos,1,1,0,"TARGET NON-EXISTENT",0,0.04]; 
						};
						case (_x distance _nearEnemy >= WBK_Zombies_MoveDistanceLimit): {
							drawIcon3D ["\A3\Ui_f\data\GUI\Cfg\Ranks\lieutenant_gs.paa",[1,0,0,1],_pos,1,1,0,"TARGET TOO FAR",0,0.04]; 
						};
						default {
							if !(isNil {_x getVariable "WBK_IsUnitLocked"}) then {
								_pos = unitAimPositionVisual  _x;    
								_pos set [2,((unitAimPositionVisual _x) select 2) + 0.75];    
								drawIcon3D ["\A3\Ui_f\data\GUI\Cfg\Ranks\lieutenant_gs.paa",[0,1,0,1],_pos,1,1,0,"TRACKING",0,0.04]; 
								drawIcon3D ["\A3\Ui_f\data\GUI\Cfg\Ranks\lieutenant_gs.paa",[0,1,0,1],getPosATL _nearEnemy,1,1,0,"TRACKED POSITION",0,0.04];
								drawLine3D [getPosATL _x, getPosATL _nearEnemy, [0,1,0,1], 6];
							}else{
								_pos = unitAimPositionVisual  _x;    
								_pos set [2,((unitAimPositionVisual _x) select 2) + 0.75];    
								drawIcon3D ["\A3\Ui_f\data\GUI\Cfg\Ranks\lieutenant_gs.paa",[0.8,1,0,1],_pos,1,1,0,"NOT TRACKING",0,0.04]; 
								if !(isNil {_x getVariable "WBK_AI_LastKnownLoc"}) then {
									drawIcon3D ["\A3\Ui_f\data\GUI\Cfg\Ranks\lieutenant_gs.paa",[0.8,1,0,1],_x getVariable "WBK_AI_LastKnownLoc",1,1,0,"POSITION TO MOVE",0,0.04];
									drawLine3D [getPosATL _x,_x getVariable "WBK_AI_LastKnownLoc",[0.8,1,0,1], 5];							
								};
							};
						};
					};
				};
			} forEach allUnits;
		};
	};
	waitUntil {sleep 1; !(isNull findDisplay 312) };
	systemChat "WBK Zombies modules are loaded";
	WBK_ZombieObjectZeus = objNull;
	{ 
		_x addEventHandler ["CuratorObjectSelectionChanged", {
			params ["_curator", "_entity"];
			WBK_ZombieObjectZeus = _entity;
		}];
	} forEach AllCurators; 
	["WebKnight's Zombies", "WBK_ZombieAI_Load", ["(Zeus only!) Load Zombie AI on unit", "Load zombie ai on a whole group of the selected unit."], {  
	if (isNull(findDisplay 312)) exitWith {};
	createDialog "WBK_SelectZombieType";
	}, {}, [45, [true, true, false]]] call cba_fnc_addKeybind;  
};
