params ["_mutant"];
if is3DEN exitWith {
	systemChat "Zombie AI loaded on this unit";
};
if ((isPlayer _mutant) or !(isNil {_mutant getVariable "WBK_AI_ISZombie"}) or !(alive _mutant)) exitWith {};
group _mutant setSpeedMode "FULL";
_mutant setSpeaker "NoVoice";
_mutant setUnitPos "UP";
_mutant setVariable ["WBK_AI_ISZombie",true,true];
_mutant setVariable ["WBK_SynthHP",WBK_Zombies_TriggermanHP,true];
[_mutant, "WBK_ShooterZombie_unnarmed_idle"] remoteExec ["switchMove", 0];
_mutant setVariable ["WBK_AI_ZombieMoveSet","WBK_ShooterZombie_unnarmed_idle", true];
[_mutant, selectRandom ["WBK_ZombieFace_blood_1","WBK_ZombieFace_blood_2","WBK_ZombieFace_blood_3","WBK_ZombieFace_blood_4"]] remoteExec ["setFace", 0];

if !(isNil "WBK_IsPresent_Necroplague") then {
	_mutant setVariable ['isMutant',true];
};
if !(isNil "WBK_IsPresent_PIR") then {
	_mutant setVariable ["dam_ignore_hit0",true,true];
	_mutant setVariable ["dam_ignore_effect0",true,true];
};


_mutant addEventHandler ["PathCalculated",
{ 
	_unit = _this select 0;
	_unit spawn {
		uisleep 0.5;
		if (behaviour _this == "COMBAT") exitWith {_this playMoveNow "WBK_ShooterZombie_armed_walk";};
		_this playMoveNow "WBK_ShooterZombie_unnarmed_walk";
		uisleep 20;
		if (behaviour _this == "COMBAT") exitWith {_this playMoveNow "WBK_ShooterZombie_armed_idle";};
		_this playMoveNow "WBK_ShooterZombie_unnarmed_idle";
	};
}];
_mutant addEventHandler ["Fired", {  
	_obj = _this select 0; 
	_obj setAmmo [currentWeapon _obj, 50];
	[_obj] spawn {
		_obj = _this select 0;
		_val = _obj getVariable "WBK_AmountOfAmmunition";
		_val = _val - 1;
		if (_val > 0) then {
			_obj setVariable ["WBK_AmountOfAmmunition",_val];
		}else{
			_obj playActionNow "WBK_ShooterZombie_reload";
			_value = getNumber (configfile >> "CfgMagazines" >> currentMagazine _obj >> "count");
			_obj setVariable ["WBK_AmountOfAmmunition",_value];
		};
	};
}];


_mutant addEventHandler ["Deleted", {
	params ["_zombie"];
	{
		_ifDelete = [_x] call CBA_fnc_removePerFrameHandler;
	} forEach (_zombie getVariable "WBK_AI_AttachedHandlers");
}];


_mutant addEventHandler ["Killed", {
	{
		_ifDelete = [_x] call CBA_fnc_removePerFrameHandler;
	} forEach ((_this select 0) getVariable "WBK_AI_AttachedHandlers");
	_this spawn {
		_zombie = _this select 0;
		_zombie spawn {
			uiSleep (0.4 + random 0.25);
			if (isNull _this) exitWith {};
			[_this, selectRandom ["zombie_fall_1","zombie_fall_2","zombie_fall_3"], 50, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		};
		_killer = _this select 1;
		uiSleep 0.2;
		if ((isNull _zombie) || (face _zombie in ["WBK_DecapatedHead_Zombies_Normal","WBK_DosHead_BackHole","WBK_DosHead_FrontHole"])) exitWith {};
		if (!(isNil {_zombie getVariable "WBK_Zombie_CustomSounds"})) then {
			[_zombie, selectRandom ((_zombie getVariable "WBK_Zombie_CustomSounds") select 3), 50, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		}else{
			[_zombie, selectRandom ["plagued_death_1","plagued_death_2","plagued_death_3","plagued_death_4","plagued_death_5","plagued_death_6","plagued_death_7","plagued_death_8","plagued_death_9"], 50, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
		};
	};
}];

[_mutant, {
_this removeAllEventHandlers "HitPart";
_this addEventHandler [
    "HitPart",
    {
		(_this select 0) params ["_target","_shooter","_bullet","_position","_velocity","_selection","_ammo","_direction","_radius","_surface","_direct"];
		if ((_target == _shooter) or !(alive _target)) exitWith {};
		switch true do {
			case ((_selection select 0) in ["head","neck"]): {
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
				[_target, selectRandom ["WBK_ZombieHitGest_1_weapon","WBK_ZombieHitGest_2_weapon","WBK_ZombieHitGest_3_weapon"]] remoteExec ["playActionNow",_target];
			};
		};
	}
];
}] remoteExec ["spawn",0,true];


uisleep 0.5;
_value = getNumber (configfile >> "CfgMagazines" >> currentMagazine _mutant >> "count");
_mutant setVariable ["WBK_AmountOfAmmunition",(_value) + 1];
_mutant setSkill ["aimingSpeed", 0.1];
_mutant setSkill ["aimingAccuracy", 0.3];
_mutant setSkill ["aimingShake", 0.4];
_mutant setSkill ["spotDistance", 1];
_mutant setSkill ["spotTime", 0.55];
_loopPathfindDoMove = [{
    _array = _this select 0;
    _unit = _array select 0;
	if (alive _unit != isAwake _unit) exitWith {_unit setDamage 1;};
	_unit disableAI "MINEDETECTION";
	_unit disableAI "WEAPONAIM";
	_unit disableAI "SUPPRESSION";
	_unit disableAI "COVER";
	_unit disableAI "AIMINGERROR";
	_unit disableAI "TARGET";
	_unit disableAI "AUTOCOMBAT";
	_unit disableAI "FSM";
	_unit allowDamage false;
	_nearEnemy = _unit findNearestEnemy _unit; 
		if ((isNull _nearEnemy) or !(alive _nearEnemy) or !(alive _unit)) exitWith {
			_unit setBehaviour "AWARE";
			if (animationState _unit in ["wbk_shooterzombie_armed_idle","wbk_shooterzombie_armed_walk"]) then {
				_unit playMoveNow "WBK_ShooterZombie_unnarmed_idle";
			};
			if (!(isNil {_unit getVariable "WBK_Zombie_CustomSounds"})) then {
				[_unit, selectRandom ((_unit getVariable "WBK_Zombie_CustomSounds") select 0), 20] call CBA_fnc_GlobalSay3D;
			}else{
				[_unit, selectRandom ["middle_idle_1","middle_idle_2","middle_idle_3","middle_idle_4"], 25] call CBA_fnc_GlobalSay3D;
			};
		};
		_unit setBehaviour "COMBAT";
		if (animationState _unit in ["wbk_shooterzombie_unnarmed_idle","wbk_shooterzombie_unnarmed_walk"]) then {
			_unit playMoveNow "WBK_ShooterZombie_armed_idle";
		};
		if (!(isNil {_unit getVariable "WBK_Zombie_CustomSounds"})) then {
            [_unit, selectRandom ((_unit getVariable "WBK_Zombie_CustomSounds") select 1), 20] call CBA_fnc_GlobalSay3D;
		}else{
			[_unit, selectRandom ["middle_agro_1","middle_agro_2","middle_agro_3","middle_agro_4","middle_agro_5","middle_agro_6","middle_agro_7","middle_agro_8"], 20] call CBA_fnc_GlobalSay3D;
		};
}, 3, [_mutant]] call CBA_fnc_addPerFrameHandler;
_mutant setVariable ["WBK_AI_AttachedHandlers", [_loopPathfindDoMove]];