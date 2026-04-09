
["WebKnight's Zombies", "WBK_ZombieAI_Load", ["(Zeus only!) Load Zombie AI on unit", "Load zombie ai on a whole group of the selected unit."], {  
if (isNull(findDisplay 312)) exitWith {};
createDialog "WBK_SelectZombieType";
}, {}, [45, [true, true, false]]] call cba_fnc_addKeybind;  


[ 
    "WBK_Zommbies_PathingPositionChange", 
    "EDITBOX", 
    ["Target repositioning distance","When caltulatic a path, any infected will first check if the position of the target changed to a set distance from previous, and if its further then this number, ai will calculate path. Lesser number makes ai pathing more accurate, but will decrease performance."],
    ["WebKnight's Zombies","0) General"],
    "8",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_TargetPosChanged = _number;
    }
] call CBA_fnc_addSetting;

[ 
    "WBK_Zommbies_PathingDebug", 
    "CHECKBOX", 
    ["Enable ai pathing debugging?","Enabling pathing debbuging to see how ai navigates. Usefull when changing pathing params and see how that affects ai. ONLY FOR SINGLEPLAYER!"],
    ["WebKnight's Zombies","0) General"],
    false,
    1,
    {   
        params ["_value"]; 
        WBK_Zombies_Debug = _value; 
    },
	true
] call CBA_fnc_addSetting;



[ 
    "WBK_Zommbies_HowFarCanSee", 
    "EDITBOX", 
    ["Path calculation distance","How far must be the target in order for regular zombies to start running towards ai. Lowering the number will increase performance, as ARMA dont like to calculate path on longer distances."],
    ["WebKnight's Zombies","1) Regular infected"],
    "150",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_MoveDistanceLimit = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_Zommbies_HeadshotMultiplier", 
    "EDITBOX", 
    ["Headshot multiplier","Damage will be multiplied if zombie is hit in the head"],
    ["WebKnight's Zombies","1) Regular infected"],
    "5",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_HeadshotMP = _number;
    }
] call CBA_fnc_addSetting;

[ 
    "WBK_Zommbies_Halth_Walker", 
    "EDITBOX", 
    "(Walker) Health",
    ["WebKnight's Zombies","1) Regular infected"],
    "30",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_WalkerHP = _number;
    }
] call CBA_fnc_addSetting;

[ 
    "WBK_Zommbies_Halth_Trig", 
    "EDITBOX", 
    "(Triggerman) Health",
    ["WebKnight's Zombies","1) Regular infected"],
    "30",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_TriggermanHP = _number;
    }
] call CBA_fnc_addSetting;

[ 
    "WBK_Zommbies_Halth_Shamb", 
    "EDITBOX", 
    "(Shambler) Health",
    ["WebKnight's Zombies","1) Regular infected"],
    "40",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_MiddleHP = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_Zommbies_Halth_Runner", 
    "EDITBOX", 
    "(Runner) Health",
    ["WebKnight's Zombies","1) Regular infected"],
    "50",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_RunnerHP = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesMeleeHealthParam", 
    "EDITBOX", 
    "(Zombie with Melee) Health",
    ["WebKnight's Zombies","1) Regular infected"],
    "60",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_MeleeHP = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_Zommbies_HowFarCanSee_SI", 
    "EDITBOX", 
    ["Path calculation distance","How far must be the target in order for special to start running towards ai. Lowering the number will increase performance, as ARMA dont like to calculate path on longer distances."],
    ["WebKnight's Zombies","2) Special infected"],
    "300",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_SpecialInfected_MoveDistanceLimit = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesBloaterHealthParam", 
    "EDITBOX", 
    "(Bloater) Health",
    ["WebKnight's Zombies","2) Special infected"],
    "80",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_BloaterHP = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesLeaperHealthParam", 
    "EDITBOX", 
    "(Leaper) Health",
    ["WebKnight's Zombies","2) Special infected"],
    "120",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_LeaperHP = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesScreamerHealthParam", 
    "EDITBOX", 
    "(Screamer) Health",
    ["WebKnight's Zombies","2) Special infected"],
    "160",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_ScreamerHP = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesScreamerDistParam", 
    "EDITBOX", 
    "(Screamer) Distance of the scream",
    ["WebKnight's Zombies","2) Special infected"],
    "100",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_ScreamerDistance = _number;
    }
] call CBA_fnc_addSetting;



[ 
    "WBK_ZommbiesScreamerCoolParam", 
    "EDITBOX", 
    "(Screamer) Scream cooldown",
    ["WebKnight's Zombies","2) Special infected"],
    "20",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_ScreamerCooldown = _number;
    }
] call CBA_fnc_addSetting;



[ 
    "WBK_ZommbiesCorruptedHealthParam", 
    "EDITBOX", 
    "(Corrupted zombie) Health",
    ["WebKnight's Zombies","2) Special infected"],
    "200",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_CorruptedHP = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesCorruptedTakeParam", 
    "CHECKBOX", 
    ["Give player controlls if they become corrupted?","If enabled, player will have direct controlls over the corrupted body, if disabled - corrupted will just kill a player"],
    ["WebKnight's Zombies","2) Special infected"],
    true,
    1,
    {   
        params ["_value"]; 
        WBK_Zombies_Corrupted_PlayerControlls = _value; 
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesCorruptedTakeTimeParam", 
    "EDITBOX", 
    "Time that player can controll corrupted",
    ["WebKnight's Zombies","2) Special infected"],
    "40",
    1,
    {   
        params ["_value"];  
        _number = parseNumber _value;
		WBK_Zombies_Corrupted_PlayerControlls_Time = _number;
    }
] call CBA_fnc_addSetting;


[ 
    "WBK_ZommbiesCorruptedTakeMusicParam", 
    "CHECKBOX", 
    ["Play specific track when player becomes corrupted?","Plays a 40 second long track when player is transformed into the corrupted, you can disable it so it will not interfiere with already playing music."],
    ["WebKnight's Zombies","2) Special infected"],
    true,
    1,
    {   
        params ["_value"]; 
        WBK_Zombies_Corrupted_PlayerControlls_Music = _value; 
    }
] call CBA_fnc_addSetting;



if ("pir" in activatedAddons) then {
	WBK_IsPresent_PIR = true;
};

if ("dev_common" in activatedAddons) then {
	WBK_IsPresent_Necroplague = true;
};

if ("wbk_dyinganimationsmod" in activatedAddons) then {
	WBK_IsPresent_DAH = true;
};


WBK_getClasses = { 
  params ["_faction", "_array"]; 
  _array = []; 
  _cfg = (configFile >> "CfgVehicles");
  { 
   if (((configName _x) isKindoF "CAManBase") and (getNumber (configFile >> "CfgVehicles" >> (configName _x)>> "scope") == 2) and (getText (configfile >> "CfgVehicles" >> (configName _x) >> "editorSubcategory") == "EdSubcat_Personnel")) then { 
    _array pushback (configName _x); 
   }; 
  } forEach ("getText (_x >> 'faction') == _faction" configClasses (configfile >> "CfgVehicles")); 
  _array 
};


///Default faction classes:  "OPF_T_F" "OPF_R_F" "OPF_F" "blu_F" "BLU_G_F" "BLU_CTRG_F" "BLU_GEN_F" "BLU_T_F" "BLU_W_F" "CIV_F" "CIV_IDAP_F" "IND_C_F" "IND_E_F" "IND_F" "IND_L_F"
WBK_ZombiesRandomEquipment = {
	_unit = _this select 0;
	_faction = _this select 1;
	_UnitArray = [_faction] call WBK_getClasses;
	_outFit = getUnitLoadout (selectRandom _UnitArray);
	if (_unit isKindOf "Zombie_O_Shooter_CSAT") exitWith {
		_unit setUnitLoadout _outFit;
	};
	_outFit set [0, []];
	_outFit set [1, []];
	_outFit set [2, []];
	_unit setUnitLoadout _outFit;
	removeAllItemsWithMagazines _unit;
	removeAllAssignedItems _unit;
};


WBK_LoadAIThroughEden = {
_unit = _this select 0;
_loadScript = _this select 1;
if (_loadScript == 0) exitWith {};
switch (_loadScript) do
{
    case 1: { 
		[_unit, true] execVM '\WBK_Zombies\AI\WBK_AI_Walker.sqf';
	};
	case 2: { 
		[_unit, false] execVM '\WBK_Zombies\AI\WBK_AI_Walker.sqf';
	};
	case 3: { 
		_unit execVM '\WBK_Zombies\AI\WBK_AI_Middle.sqf';
	};
	case 4: { 
		[_unit, false, false] execVM '\WBK_Zombies\AI\WBK_AI_Runner.sqf';
	};
	case 5: { 
		[_unit, true, false] execVM '\WBK_Zombies\AI\WBK_AI_Runner.sqf';
	};
	case 6: { 
		_unit execVM '\WBK_Zombies\AI\WBK_ShooterZombie.sqf';
	};
	case 7: { 
		[_unit, false, true] execVM '\WBK_Zombies\AI\WBK_AI_Runner.sqf';
	};
	case 8: { 
		_unit execVM '\WBK_Zombies\AI\Ai_Melee_Zombie.sqf';
	};
};

};


/*
Custom zombie sounds


this setVariable ["WBK_Zombie_CustomSounds",
[
["WW2_Zombie_idle1","WW2_Zombie_idle2","WW2_Zombie_idle3","WW2_Zombie_idle4","WW2_Zombie_idle5","WW2_Zombie_idle6"],
["WW2_Zombie_walker1","WW2_Zombie_walker2","WW2_Zombie_walker3","WW2_Zombie_walker4","WW2_Zombie_walker5"],
["WW2_Zombie_attack1","WW2_Zombie_attack2","WW2_Zombie_attack3","WW2_Zombie_attack4","WW2_Zombie_attack5"],
["WW2_Zombie_death1","WW2_Zombie_death2","WW2_Zombie_death3","WW2_Zombie_death4","WW2_Zombie_death5"],
["WW2_Zombie_burning1","WW2_Zombie_burning2","WW2_Zombie_burning3"]
],true];

this setVariable ["WBK_Zombie_CustomSounds",
[
["WW2_Zombie_walker1","WW2_Zombie_walker2","WW2_Zombie_walker3","WW2_Zombie_walker4","WW2_Zombie_walker5"],
["WW2_Zombie_sprinter1","WW2_Zombie_sprinter2","WW2_Zombie_sprinter3","WW2_Zombie_sprinter4","WW2_Zombie_sprinter5","WW2_Zombie_sprinter6","WW2_Zombie_sprinter7","WW2_Zombie_sprinter8","WW2_Zombie_sprinter9"],
["WW2_Zombie_attack1","WW2_Zombie_attack2","WW2_Zombie_attack3","WW2_Zombie_attack4","WW2_Zombie_attack5"],
["WW2_Zombie_death1","WW2_Zombie_death2","WW2_Zombie_death3","WW2_Zombie_death4","WW2_Zombie_death5"],
["WW2_Zombie_burning1","WW2_Zombie_burning2","WW2_Zombie_burning3"]
],true];


for special infected
this setVariable ["WBK_Zombie_CustomSounds",
[
["WW2_Zombie_walker1","WW2_Zombie_walker2","WW2_Zombie_walker3","WW2_Zombie_walker4","WW2_Zombie_walker5"], - idle
["WW2_Zombie_sprinter1","WW2_Zombie_sprinter2","WW2_Zombie_sprinter3","WW2_Zombie_sprinter4","WW2_Zombie_sprinter5","WW2_Zombie_sprinter6","WW2_Zombie_sprinter7","WW2_Zombie_sprinter8","WW2_Zombie_sprinter9"], - attack
["WW2_Zombie_attack1","WW2_Zombie_attack2","WW2_Zombie_attack3","WW2_Zombie_attack4","WW2_Zombie_attack5"], - special
["WW2_Zombie_death1","WW2_Zombie_death2","WW2_Zombie_death3","WW2_Zombie_death4","WW2_Zombie_death5"], -death
["WW2_Zombie_burning1","WW2_Zombie_burning2","WW2_Zombie_burning3"]
],true];




*/


WBK_ZombiePlayIdleSounds = {
	params ["_zombie","_sound","_dist","_soundHorde","_isAngrySnd"];
	switch true do {
		case ((_isAngrySnd) && (({alive _x} count units group _zombie) >= 15) && (_zombie == leader group _zombie)): {
			[_zombie,[_soundHorde,_dist + 250]] remoteExecCall ["say3D",[0,-2] select isDedicated,false];
		};
		case ((_isAngrySnd) && (({alive _x} count units group _zombie) >= 15) && (_zombie != leader group _zombie)): {
		};
		case (!(_isAngrySnd) && (({alive _x} count units group _zombie) >= 15) && (_zombie == leader group _zombie)): {
			[selectRandom units _zombie,[_soundHorde,_dist + 300]] remoteExecCall ["say3D",[0,-2] select isDedicated,false];
		};
		case (!(_isAngrySnd) && (({alive _x} count units group _zombie) >= 15) && (_zombie != leader group _zombie)): {
		};
		default {[_zombie,[_sound,_dist]] remoteExecCall ["say3D",[0,-2] select isDedicated,false];};
	};
};


WBK_ZombieAttackDamage = {
	params ["_zombie","_damage","_dist","_isMetal"];
	if !(alive _zombie) exitWith {};
	_x = _zombie findNearestEnemy _zombie;
	if ((_zombie distance _x) <= _dist) then {
		switch true do {
			case ((_x == _zombie) || (side _zombie == side _x) || (((_zombie worldToModel (_x modelToWorld [0, 0, 0])) select 1) < 0)): {};
			case (!(isNil {_x getVariable "IMS_IsUnitInvicibleScripted"}) || (animationState _x == "STAR_WARS_FIGHT_DODGE_LEFT") || (animationState _x == "STAR_WARS_FIGHT_DODGE_LEFT") || (animationState _x == "STAR_WARS_FIGHT_DODGE_RIGHT") || (animationState _x == "starWars_landRoll") || (animationState _x == "starWars_landRoll_b") || ((typeOf _x isKindOf "WBK_SpecialZombie_Smasher_1") && (side _x == side _zombie)) || ((typeOf _x isKindOf "WBK_Goliaph_1") && (side _x == side _zombie)) || ((_x == _zombie) || !(alive _zombie) || !(alive _x) || (animationState _x == "WBK_Smasher_Execution"))): {};
			case (lifeState _x == "INCAPACITATED"): {
				[_x, [1, false, _zombie]] remoteExec ["setDamage",2];
			};
			case ((((_zombie worldToModel (_x modelToWorld [0, 0, 0])) select 1) > 0) && ((gestureState _x in ["fp_hit_afterblock_2","fp_hit_afterblock_1","fp_knife_block_2","fp_knife_block_1","fp_knife_block","fp_rapier_block","fp_rapier_block_2","fp_rapier_block_1","fp_twohanded_blocked_2","fp_twohanded_blocked_1","fp_onehanded_blocked_2","fp_onehanded_blocked_1","twohanded_sword_heavy_block","wbk_ims_zweitype_block","star_wars_twohandblock","shield_block","twohanded_block","starwars_lightsaber_block_loop","star_wars_fight_alebarda_block_gesture"]) or (_x getVariable "actualSwordBlock" == 1) or (animationState _x in ["starwars_lightsaber_block_1","starwars_lightsaber_block_2","starwars_lightsaber_block_3","starwars_lightsaber_block_heavy"]))): {
				if (_isMetal) then {
					[_x, selectRandom ["wood_block_1","wood_block_2","wood_block_3","wood_block_4"], 50, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
				}else{
					[_x, "dobi_fall_2", 50, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";  
				};
				[_x, _zombie] remoteExec ["concentrationMinus", _x];   
			};
			case !(isNil {_x getVariable "WBK_AI_ISZombie"}): {
				[_x,_zombie,0.05,"Fists"] remoteExec ["WBK_ZombiesProcessDamage", _x];
				if (_isMetal) then {
					[_x, selectRandom ["sword_hit_1","sword_hit_2","sword_hit_3","sword_hit_4","sword_hit_5","sword_hit_6"], 60, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
				}else{
					[_x, selectRandom ["PF_Hit_1","PF_Hit_2"], 60, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				};
			};
			case (!(isNil {_x getVariable "IMS_ISAI"}) || (currentWeapon _x in IMS_Melee_Weapons) || (_x isKindOf "WBK_DOS_Squig_Normal") || (_x isKindOf "WBK_DOS_Huge_ORK") || (_x isKindOf "TIOWSpaceMarine_Base")): {
				[_x,_zombie] remoteExec ["WBK_CreateMeleeHitAnim", _x];
				[_x,_damage,_zombie] remoteExec ["WBK_CreateDamage", _x];
				if (_isMetal) then {
					[_x, selectRandom ["sword_hit_1","sword_hit_2","sword_hit_3","sword_hit_4","sword_hit_5","sword_hit_6"], 60, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
				}else{
					[_x, selectRandom ["PF_Hit_1","PF_Hit_2"], 60, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				};
				if (isPlayer _x) then {
					[_x, {
						[30] call BIS_fnc_bloodEffect;
						["ChromAberration", 200, [0.04, 0.04, true]] spawn {
							AddChromAbber = true;
							params["_name", "_priority", "_effect", "_handle"];
							while {
								_handle = ppEffectCreate[_name, _priority];
								_handle < 0
							}
							do {
								_priority = _priority + 1;
							};
							_handle ppEffectEnable true;
							_handle ppEffectAdjust _effect;
							_handle ppEffectCommit 0.4;
							uiSleep 0.4;
							_handle ppEffectAdjust[0, 0, false];
							_handle ppEffectCommit 0.4;
							uiSleep 0.5;
							ppEffectDestroy _handle;
							AddChromAbber = nil;
						};
					}] remoteExec ["spawn",_x];
				};
			};
			default {
				[_x,_damage,_zombie] remoteExec ["WBK_CreateDamage", _x];
				if (_isMetal) then {
					[_x, selectRandom ["sword_hit_1","sword_hit_2","sword_hit_3","sword_hit_4","sword_hit_5","sword_hit_6"], 60, 3] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
				}else{
					[_x, selectRandom ["PF_Hit_1","PF_Hit_2"], 60, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				};
				if (isPlayer _x) then {
					[_x, {
						[30] call BIS_fnc_bloodEffect;
						["ChromAberration", 200, [0.04, 0.04, true]] spawn {
							AddChromAbber = true;
							params["_name", "_priority", "_effect", "_handle"];
							while {
								_handle = ppEffectCreate[_name, _priority];
								_handle < 0
							}
							do {
								_priority = _priority + 1;
							};
							_handle ppEffectEnable true;
							_handle ppEffectAdjust _effect;
							_handle ppEffectCommit 0.4;
							uiSleep 0.4;
							_handle ppEffectAdjust[0, 0, false];
							_handle ppEffectCommit 0.4;
							uiSleep 0.5;
							ppEffectDestroy _handle;
							AddChromAbber = nil;
						};
					}] remoteExec ["spawn",_x];
				};
				if ((currentWeapon _x == "") || (currentWeapon _x == handgunWeapon _x)) exitWith {
					[_x, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_x];
				};
				[_x, selectRandom ["WBK_ZombieHitGest_1_weapon","WBK_ZombieHitGest_2_weapon","WBK_ZombieHitGest_3_weapon"]] remoteExec ["playActionNow",_x];
			};
		};
	};
};


WBK_ZombiesProcessDamage = {
params ["_zombie","_hitter","_damageVar","_weaponThatDealsDamage"];
if !(isNil {_zombie getVariable "IMS_EventHandler_Hit"}) then {
	[_zombie,_hitter,_weaponThatDealsDamage] spawn (_zombie getVariable "IMS_EventHandler_Hit");
};
_zombie reveal [_hitter, 4]; 
switch true do {
	case (_zombie isKindOf "WBK_Goliaph_1"): {};
	case (_zombie isKindOf "WBK_SpecialZombie_Corrupted_1"): {
		[_zombie, [1, false, _hitter]] remoteExec ["setDamage",2];
	};
	case (_zombie isKindOf "WBK_SpecialZombie_Smasher_1"): {
		if ((animationState _zombie == "WBK_Smasher_Execution") or !(alive _zombie)) exitWith {};
		_new_vv = (_zombie getVariable "WBK_SynthHP") - (WBK_Zombies_SmasherHP / 30);
		if !(isNil "WBK_ZombiesShowDebugDamage") then {
			systemChat str (WBK_Zombies_SmasherHP / 30);
		};
		if (_new_vv <= 0) exitWith {
			[_zombie, [1, false, _hitter]] remoteExec ["setDamage",2];
		};
		_zombie setVariable ["WBK_SynthHP",_new_vv,true];
		if ((_hitter isKindOf "TIOWSpaceMarine_Base") and !(animationState _zombie == "WBK_Smasher_HitHard") and (isNil {_zombie getVariable "CanBeStunnedIMS"})) then { 
			[_zombie, "Smasher_eat_voice", 120, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf"; 
			[_zombie, "WBK_Smasher_HitHard"] remoteExec ["switchMove", 0]; 
			[_zombie, "WBK_Smasher_Run"] remoteExec ["playMoveNow", 0];
			_zombie setVariable ["CanBeStunnedIMS",1,true]; 
			_zombie spawn {uisleep 10; _this setVariable ["CanBeStunnedIMS",nil,true];};
		};
	};
	case ((lifeState _zombie == "INCAPACITATED") || (animationState _zombie in ["wbk_crawler_walk","wbk_crawler_transformto","wbk_crawler_idle","wbk_crawler_attack","wbk_middle_fall_forward_1","wbk_middle_fall_forward","wbk_middle_fall_back_1","wbk_middle_fall_back","wbk_runner_fall_back","wbk_runner_fall_forward","wbk_walker_fall_back_moveset_1","wbk_walker_fall_back_moveset_2","wbk_walker_fall_back_moveset_3","wbk_walker_fall_forward_moveset_1","wbk_walker_fall_forward_moveset_2","wbk_walker_fall_forward_moveset_3"])): {
		if (isNil "WBK_IsPresent_DAH") then {
			[_zombie, [_hitter vectorModelToWorld [0,400,40], _zombie selectionPosition "head", false]] remoteExec ["addForce", _zombie];
		};
		[_zombie, [1, false, _hitter]] remoteExec ["setDamage",2];
	};
	case (_zombie getVariable "WBK_AI_ZombieMoveSet" == "WBK_ShooterZombie_unnarmed_idle"): {
		[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
		[_zombie, selectRandom ["dobi_CriticalHit","decapetadet_sound_1","decapetadet_sound_2"], 40, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		if (isNil "WBK_IsPresent_DAH") then {
			[_zombie, [_hitter vectorModelToWorld [0,300,50], _zombie selectionPosition "head", false]] remoteExec ["addForce", _zombie];
		};
		[_zombie, [1, false, _hitter]] remoteExec ["setDamage",2];
	};
	case (_hitter isKindOf "TIOWSpaceMarine_Base"): {
		if (isNil "WBK_IsPresent_DAH") then {
			[_zombie, [_hitter vectorModelToWorld [0,700,90], _zombie selectionPosition "head", false]] remoteExec ["addForce", _zombie];
		};
		[_zombie, [1, false, _hitter]] remoteExec ["setDamage",2];
		if ((random 100) >= 70) then {
			_zombie call WBK_Zombies_CreateBloodParticle;
			[_zombie, selectRandom ["decapetadet_sound_1","decapetadet_sound_2"], 80, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
			_zombie unlinkItem hmd _zombie;
			removeGoggles _zombie;
			removeHeadgear _zombie;
			[_zombie, "WBK_DecapatedHead_Zombies_Normal"] remoteExec ["setFace",0];
		};
	};
	case (_zombie getVariable "WBK_AI_ZombieMoveSet" == "Star_Wars_KaaTirs_idle"): {
		if (_weaponThatDealsDamage == "Fists") exitWith {
			switch true do {
				case (animationState _zombie in ["star_wars_kaatirs_stanned","star_wars_kaatirs_idle","star_wars_kaatirs_runf","star_wars_kaatirs_runlf","star_wars_kaatirs_runrf"]): {
					[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
				};
				default {
					_zombie setVariable ["WBK_SynthHP",5,true];
					[_zombie, "Disable_Gesture"] remoteExec ["playActionNow",_zombie];
					[_zombie, "Star_Wars_KaaTirs_stanned"] remoteExec ["switchMove", 0];
				};
			};
		};
		_new_vv = (_zombie getVariable "WBK_SynthHP") - (_damageVar * 100);
		if !(isNil "WBK_ZombiesShowDebugDamage") then {
			systemChat str (_damageVar * 100);
		};
		if (_new_vv <= 0) exitWith {
			[_zombie, selectRandom ["WBK_Leaper_Death_1","WBK_Leaper_Death_2"]] remoteExec ["switchMove", 0]; 
			[_zombie, [1, false, _hitter]] remoteExec ["setDamage",2];
		};
		_zombie setVariable ["WBK_SynthHP",_new_vv,true];
		[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
	};
	case (_zombie getVariable "WBK_AI_ZombieMoveSet" == "WBK_CustomCreature"): {
		_new_vv = (_zombie getVariable "WBK_SynthHP") - (_damageVar * 100);
		if !(isNil "WBK_ZombiesShowDebugDamage") then {
			systemChat str (_damageVar * 100);
		};
		if (_new_vv <= 0) exitWith {
			[_zombie, [1, false, _hitter]] remoteExec ["setDamage",2];
		};
		_zombie setVariable ["WBK_SynthHP",_new_vv,true];
	};
	default {
		if (_weaponThatDealsDamage == "Fists") exitWith {
			 _vv = _zombie getVariable "WBK_SynthHP";
			_new_vv = (_zombie getVariable "WBK_SynthHP") - 5;
			if !(isNil "WBK_ZombiesShowDebugDamage") then {
				systemChat "5";
			};
			if (_new_vv <= 0) exitWith {
				[_zombie, selectRandom ["PF_Hit_1","PF_Hit_2"], 40, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
				[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
				[_zombie, [1, false, _hitter]] remoteExec ["setDamage",2];
				if (isNil "WBK_IsPresent_DAH") then {
					[_zombie, [_hitter vectorModelToWorld [0,400,50], _zombie selectionPosition "head", false]] remoteExec ["addForce", _zombie];
				};
			};
			_zombie setVariable ["WBK_SynthHP",_new_vv,true];
			switch (_zombie getVariable "WBK_AI_ZombieMoveSet") do {
				case "WBK_Zombie_Melee_Idle": {
					switch true do {
						case (animationState _zombie in ["wbk_zombie_melee_hit_1","wbk_zombie_melee_hit_2","wbk_zombie_melee_hit_b","wbk_zombie_melee_hit_fall"]): {
							[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
						};
						default {
							[_zombie, "Disable_Gesture"] remoteExec ["playActionNow",_zombie];
							[_zombie,["WBK_Zombie_Melee_Hit_1", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Zombie_Melee_Idle"] remoteExec ["playMove", _zombie];
						};
					};
				};
				case "WBK_Runner_Angry_Idle": {
					switch true do {
						case (animationState _zombie in ["wbk_runner_shoved_b","wbk_runner_shoved_f","wbk_runner_shoved_b_stunned"]): {
							[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
						};
						case (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0): {
							[_zombie, "Disable_Gesture"] remoteExec ["playActionNow",_zombie];
							[_zombie,["WBK_Runner_Shoved_F", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Runner_Angry_Idle"] remoteExec ["playMove", _zombie];
						};
						default {
							[_zombie, "Disable_Gesture"] remoteExec ["playActionNow",_zombie];
							[_zombie,["WBK_Runner_Shoved_B", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Runner_Angry_Idle"] remoteExec ["playMove", _zombie];
						};
					};
				};
				case "WBK_Middle_Idle": {
					switch true do {
						case (animationState _zombie in ["wbk_middle_shoved_b","wbk_middle_shoved_f","wbk_middle_shoved_b_stunned"]): {
							[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
						};
						case (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0): {
							[_zombie, "Disable_Gesture"] remoteExec ["playActionNow",_zombie];
							[_zombie,["WBK_Middle_Shoved_F", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Middle_Idle"] remoteExec ["playMove", _zombie];
						};
						default {
							[_zombie, "Disable_Gesture"] remoteExec ["playActionNow",_zombie];
							[_zombie,["WBK_Middle_Shoved_B", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Middle_Idle"] remoteExec ["playMove", _zombie];
						};
					};
				};
				case "WBK_Middle_Idle_1": {
					switch true do {
						case (animationState _zombie in ["wbk_middle_shoved_b_1","wbk_middle_shoved_f_1","wbk_middle_shoved_b_stunned_1"]): {
							[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
						};
						case (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0): {
							[_zombie, "Disable_Gesture"] remoteExec ["playActionNow",_zombie]; 
							[_zombie,["WBK_Middle_Shoved_F_1", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Middle_Idle_1"] remoteExec ["playMove", _zombie];
						};
						default {
							[_zombie, "Disable_Gesture"] remoteExec ["playActionNow",_zombie];
							[_zombie,["WBK_Middle_Shoved_B_1", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Middle_Idle_1"] remoteExec ["playMove", _zombie];
						};
					};
				};
				case "WBK_Walker_Idle_1": {
					switch true do {
						case (animationState _zombie in ["wbk_walker_hit_b","wbk_walker_hit_f_2","wbk_walker_fall_forward_moveset_1","wbk_walker_fall_back_moveset_1"]): {
							[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
						};
						case (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0): {
							[_zombie,["WBK_Walker_Hit_B", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Walker_Idle_1"] remoteExec ["playMove", _zombie];
						};
						default {
							[_zombie,["WBK_Walker_Hit_F_2", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Walker_Idle_1"] remoteExec ["playMove", _zombie];
						};
					};
				};
				case "WBK_Walker_Idle_2": {
					switch true do {
						case (animationState _zombie in ["wbk_walker_hit_b_1","wbk_walker_hit_f_2_2","wbk_walker_fall_back_moveset_2","wbk_walker_fall_forward_moveset_2"]): {
							[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
						};
						case (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0): {
							[_zombie,["WBK_Walker_Hit_B_1", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Walker_Idle_2"] remoteExec ["playMove", _zombie];
						};
						default {
							[_zombie,["WBK_Walker_Hit_F_2_2", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Walker_Idle_2"] remoteExec ["playMove", _zombie];
						};
					};
				};
				case "WBK_Walker_Idle_3": {
					switch true do {
						case (animationState _zombie in ["wbk_walker_hit_b","wbk_walker_hit_f_2","wbk_walker_fall_forward_moveset_1","wbk_walker_fall_back_moveset_1"]): {
							[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
						};
						case (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0): {
							[_zombie,["WBK_Walker_Hit_B", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Walker_Idle_1"] remoteExec ["playMove", _zombie];
						};
						default {
							[_zombie,["WBK_Walker_Hit_F_2", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Walker_Idle_1"] remoteExec ["playMove", _zombie];
						};
					};
				};
			};
		};
		 _vv = _zombie getVariable "WBK_SynthHP";
		_new_vv = (_zombie getVariable "WBK_SynthHP") - (_damageVar * 100);
		if !(isNil "WBK_ZombiesShowDebugDamage") then {
			systemChat str (_damageVar * 100);
		};
		if (_new_vv <= 0) exitWith {
			[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
			[_zombie, selectRandom ["dobi_CriticalHit","decapetadet_sound_1","decapetadet_sound_2"], 60, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
			[_zombie, [1, false, _hitter]] remoteExec ["setDamage",2];
			if (isNil "WBK_IsPresent_DAH") then {
				[_zombie, [_hitter vectorModelToWorld [0,400,50], _zombie selectionPosition "head", false]] remoteExec ["addForce", _zombie];
			};
			if (((random 100) >= 80) && !(_weaponThatDealsDamage in IMS_Melee_Knifes)) then {
				_zombie call WBK_Zombies_CreateBloodParticle;
				[_zombie, "WBK_DecapatedHead_Zombies_Normal"] remoteExec ["setFace",0];
				if (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0) exitWith {
					[_zombie, "WBK_DosHead_BackHole"] remoteExec ["setFace",0];
				};
				[_zombie, "WBK_DosHead_FrontHole"] remoteExec ["setFace",0];
			};
		};
		_zombie setVariable ["WBK_SynthHP",_new_vv,true];
		if (_weaponThatDealsDamage in IMS_Melee_Knifes) exitWith {
			[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
		};
		switch (_zombie getVariable "WBK_AI_ZombieMoveSet") do {
			case "WBK_Zombie_Melee_Idle": { 
				switch true do {
					case (((animationState _zombie == "WBK_Zombie_Melee_Hit_2") or (animationState _zombie == "WBK_Zombie_Melee_Hit_Fall")) or ((!(_weaponThatDealsDamage == "Rifle") and !(_weaponThatDealsDamage in IMS_Melee_Heavy) and !(_weaponThatDealsDamage in IMS_Melee_Greatswords)) and ((animationState _zombie == "WBK_Zombie_Melee_Attack_1") or (animationState _zombie == "WBK_Zombie_Melee_Attack_2") or (animationState _zombie == "WBK_Zombie_Melee_Attack_4") or (animationState _zombie == "WBK_Zombie_Melee_Attack_3")))): {
						[_zombie, selectRandom ["WBK_ZombieHitGest_1","WBK_ZombieHitGest_2","WBK_ZombieHitGest_3"]] remoteExec ["playActionNow",_zombie];
					};
					case (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0): {
						[_zombie, "Disable_Gesture"] remoteExec ["playActionNow", _zombie];
						if (animationState _zombie == "WBK_Zombie_Melee_Hit_B") exitWith {
							[_zombie, "dobi_fall", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
							[_zombie,["WBK_Zombie_Melee_Hit_Fall", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Zombie_Melee_Walk"] remoteExec ["playMove", _zombie];
						};
						[_zombie,["WBK_Zombie_Melee_Hit_B", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Zombie_Melee_Walk"] remoteExec ["playMove", _zombie];
					};
					case (animationState _zombie == "WBK_Zombie_Melee_Hit_1"): {
						[_zombie, "Disable_Gesture"] remoteExec ["playActionNow", _zombie];
						[_zombie,["WBK_Zombie_Melee_Hit_2", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Zombie_Melee_Walk"] remoteExec ["playMove", _zombie];
					};
					default {
						[_zombie, "Disable_Gesture"] remoteExec ["playActionNow", _zombie];
						[_zombie,["WBK_Zombie_Melee_Hit_1", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Zombie_Melee_Walk"] remoteExec ["playMove", _zombie];
					};
				};
			};
			case "WBK_Middle_Idle": {
				switch true do {
					case (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0): {
						if (animationState _zombie == "WBK_Middle_hit_b_1") exitWith {
							[_zombie, "dobi_fall", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
							[_zombie,["WBK_Middle_Fall_Forward", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Middle_Idle"] remoteExec ["playMove", _zombie];
						};
						[_zombie,["WBK_Middle_hit_b_1", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Middle_Idle"] remoteExec ["playMove", _zombie];
					};
					case (animationState _zombie == "WBK_Middle_hit_f_2_1"): {
						[_zombie, "dobi_fall", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
						[_zombie,["WBK_Middle_Fall_Back", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Middle_Idle"] remoteExec ["playMove", _zombie];
					};
					case (animationState _zombie == "WBK_Middle_hit_f_1_1"): {
						[_zombie,["WBK_Middle_hit_f_2_1", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Middle_Idle"] remoteExec ["playMove", _zombie];
					};
					default {
						[_zombie,["WBK_Middle_hit_f_1_1", 0, 0.2, false]] remoteExec ["switchMove",0];						
						[_zombie, "WBK_Middle_Idle"] remoteExec ["playMove", _zombie];
					};
				};
			};
			case "WBK_Middle_Idle_1": {
				switch true do {
					case (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0): {
						if (animationState _zombie == "WBK_Middle_hit_b_2") exitWith {
							[_zombie, "dobi_fall", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
							[_zombie,["WBK_Middle_Fall_Forward_1", 0, 0.2, false]] remoteExec ["switchMove",0];		
							[_zombie, "WBK_Middle_Idle_1"] remoteExec ["playMove", _zombie];
						};
						[_zombie,["WBK_Middle_hit_b_2", 0, 0.2, false]] remoteExec ["switchMove",0];	
						[_zombie, "WBK_Middle_Idle_1"] remoteExec ["playMove", _zombie];
					};
					case (animationState _zombie == "WBK_Middle_hit_f_2_2"): {
						[_zombie, "dobi_fall", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
						[_zombie,["WBK_Middle_Fall_Back_1", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Middle_Idle_1"] remoteExec ["playMove", _zombie];
					};
					case (animationState _zombie == "WBK_Middle_hit_f_1_2"): {
						[_zombie,["WBK_Middle_hit_f_2_2", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Middle_Idle_1"] remoteExec ["playMove", _zombie];
					};
					default {
						[_zombie,["WBK_Middle_hit_f_1_2", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Middle_Idle_1"] remoteExec ["playMove", _zombie];
					};
				};
			};
			case "WBK_Runner_Angry_Idle": {
				switch true do {
					case (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0): {
						if (animationState _zombie == "WBK_Runner_hit_b") exitWith {
							[_zombie, "dobi_fall", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
							[_zombie,["WBK_Runner_Fall_Forward", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Runner_Angry_Idle"] remoteExec ["playMove", _zombie];
						};
						[_zombie,["WBK_Runner_hit_b", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Runner_Angry_Idle"] remoteExec ["playMove", _zombie];
					};
					case (animationState _zombie == "WBK_Runner_hit_f_2"): {
						[_zombie, "dobi_fall", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
						[_zombie,["WBK_Runner_Fall_Back", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Runner_Angry_Idle"] remoteExec ["playMove", _zombie];
					};
					case (animationState _zombie == "WBK_Runner_hit_f_1"): {
						[_zombie,["WBK_Runner_hit_f_2", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Runner_Angry_Idle"] remoteExec ["playMove", _zombie];
					};
					default {
						[_zombie,["WBK_Runner_hit_f_1", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Runner_Angry_Idle"] remoteExec ["playMove", _zombie];
					};
				};
			};
			case "WBK_Walker_Idle_1": {
				switch true do {
					case (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0): {
						if (animationState _zombie == "WBK_Walker_Hit_B") exitWith {
							[_zombie, "dobi_fall", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
							[_zombie,["WBK_Walker_Fall_Forward_Moveset_1", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Walker_Idle_1"] remoteExec ["playMove", _zombie];
						};
						[_zombie,["WBK_Walker_Hit_B", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Walker_Idle_1"] remoteExec ["playMove", _zombie];
					};
					case (animationState _zombie == "WBK_Walker_Hit_F_2"): {
						[_zombie, "dobi_fall", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
						[_zombie,["WBK_Walker_Fall_Back_Moveset_1", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Walker_Idle_1"] remoteExec ["playMove", _zombie];
					};
					case (animationState _zombie == "WBK_Walker_Hit_F_1"): {
						[_zombie,["WBK_Walker_Hit_F_2", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Walker_Idle_1"] remoteExec ["playMove", _zombie];
					};
					default {
						[_zombie,["WBK_Walker_Hit_F_1", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Walker_Idle_1"] remoteExec ["playMove", _zombie];
					};
				};
			};
			case "WBK_Walker_Idle_2": {
				switch true do {
					case (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0): {
						if (animationState _zombie == "WBK_Walker_Hit_B_1") exitWith {
							[_zombie, "dobi_fall", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
							[_zombie,["WBK_Walker_Fall_Forward_Moveset_2", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Walker_Idle_2"] remoteExec ["playMove", _zombie];
						};
						[_zombie,["WBK_Walker_Hit_B_1", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Walker_Idle_2"] remoteExec ["playMove", _zombie];
					};
					case (animationState _zombie == "WBK_Walker_Hit_F_2_2"): {
						[_zombie, "dobi_fall", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
						[_zombie,["WBK_Walker_Fall_Back_Moveset_2", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Walker_Idle_2"] remoteExec ["playMove", _zombie];
					};
					case (animationState _zombie == "WBK_Walker_Hit_F_1_2"): {
						[_zombie,["WBK_Walker_Hit_F_2_2", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Walker_Idle_2"] remoteExec ["playMove", _zombie];
					};
					default {
						[_zombie,["WBK_Walker_Hit_F_1_2", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Walker_Idle_2"] remoteExec ["playMove", _zombie];
					};
				};
			};
			case "WBK_Walker_Idle_3": {
				switch true do {
					case (((_zombie worldToModel (_hitter modelToWorld [0, 0, 0])) select 1) < 0): {
						if (animationState _zombie == "WBK_Walker_Hit_B_1") exitWith {
							[_zombie, "dobi_fall", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
							[_zombie,["WBK_Walker_Fall_Forward_Moveset_2", 0, 0.2, false]] remoteExec ["switchMove",0];
							[_zombie, "WBK_Walker_Idle_2"] remoteExec ["playMove", _zombie];
						};
						[_zombie,["WBK_Walker_Hit_B_1", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Walker_Idle_2"] remoteExec ["playMove", _zombie];
					};
					case (animationState _zombie == "WBK_Walker_Hit_F_2_2"): {
						[_zombie, "dobi_fall", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
						[_zombie,["WBK_Walker_Fall_Back_Moveset_2", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Walker_Idle_2"] remoteExec ["playMove", _zombie];
					};
					case (animationState _zombie == "WBK_Walker_Hit_F_1_2"): {
						[_zombie,["WBK_Walker_Hit_F_2_2", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Walker_Idle_2"] remoteExec ["playMove", _zombie];
					};
					default {
						[_zombie,["WBK_Walker_Hit_F_1_2", 0, 0.2, false]] remoteExec ["switchMove",0];
						[_zombie, "WBK_Walker_Idle_2"] remoteExec ["playMove", _zombie];
					};
				};
			};
		};
	};
};
};


WBK_Zombies_CreateBloodParticle = {
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
				[0,0, 4],         
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
		uisleep 0.2;
		deleteVehicle _breath; 
		uisleep 0.9;
		deleteVehicle _blood; 
	}] remoteExec ["spawn",0];
};