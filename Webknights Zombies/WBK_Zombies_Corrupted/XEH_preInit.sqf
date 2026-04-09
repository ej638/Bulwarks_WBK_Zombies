WBK_CorruptedAttack_success = { 
	params ["_main","_victim"];
	_side = side _main;
	_victim setVariable ['IMS_IsUnitInvicibleScripted',1,true];
	_victim setVariable ["AI_CanTurn",1,true];  
	_victim setVariable ["canMakeAttack",1,true];   
	_main disableAI "RADIOPROTOCOL";
	if (((_victim worldToModel (_main modelToWorld [0, 0, 0])) select 1) > 0) then {
		[_main, "Corrupted_attack_success_front"] remoteExec ["switchMove", 0];  
	}else{
		[_main, "Corrupted_attack_success_back"] remoteExec ["switchMove", 0];  
	};
	[_victim, "Corrupted_Attack_victim"] remoteExec ["switchMove", 0];  
	[_victim, "Disable_Gesture"] remoteExec ["playActionNow", _victim];
	_main attachTo [_victim,[0,0,0]];    
	_victim setDamage 0;  
	_main setDamage 0;
	[_main, selectRandom ["corrupted_head_attack_1","corrupted_head_attack_2"], 45, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	uisleep 1;
	if (!(alive _victim) or !(alive _main) or (animationState _victim != "Corrupted_Attack_victim") or !(animationState _main in ["corrupted_attack_success_back","corrupted_attack_success_front"])) exitWith {
		[_victim, [_victim vectorModelToWorld [0,-200,10], _victim selectionPosition "head", false]] remoteExec ["addForce", _victim];
		detach _main;
		[_main, "Corrupted_attack_success_failed"] remoteExec ["switchMove",0];
		_victim setVariable ['IMS_IsUnitInvicibleScripted',nil,true];
	};
	if (isNil {_victim getVariable "WBK_AI_ISZombie"}) then {
		[_victim, selectRandom ["Smasher_human_scream_1","Smasher_human_scream_2","Smasher_human_scream_3"], 110, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	};
	[_victim, selectRandom ["corrupted_head_attack_3","corrupted_head_attack_4"], 45, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	uisleep 1.8;
	if (!(alive _victim) or !(alive _main) or (animationState _victim != "Corrupted_Attack_victim") or !(animationState _main in ["corrupted_attack_success_back","corrupted_attack_success_front"])) exitWith {
		[_victim, [_victim vectorModelToWorld [0,-200,10], _victim selectionPosition "head", false]] remoteExec ["addForce", _victim];
		detach _main;
		[_main, "Corrupted_attack_success_failed"] remoteExec ["switchMove",0];
		_victim setVariable ['IMS_IsUnitInvicibleScripted',nil,true];
	};
	[_victim, selectRandom ["corrupted_head_attack_1","corrupted_head_attack_2"], 45, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_victim, "PF_Hit_2", 40, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
    _victim call WBK_Zombies_CreateBloodParticle;
	uisleep 0.95;
	if (!(alive _victim) or !(alive _main) or (animationState _victim != "Corrupted_Attack_victim") or !(animationState _main in ["corrupted_attack_success_back","corrupted_attack_success_front"])) exitWith {
		_victim setDamage 1;
		[_victim, [_victim vectorModelToWorld [0,-200,10], _victim selectionPosition "head", false]] remoteExec ["addForce", _victim];
		detach _main;
		[_main, "Corrupted_attack_success_failed"] remoteExec ["switchMove",0];
		_victim setVariable ['IMS_IsUnitInvicibleScripted',nil,true];
	};
	[_victim, selectRandom ["corrupted_head_attack_1","corrupted_head_attack_2","corrupted_head_attack_3","corrupted_head_attack_4"], 45, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_victim, "decapetadet_sound_1", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	_victim unlinkItem hmd _victim;
	removeGoggles _victim;
	removeHeadgear _victim;
	_victim call WBK_Zombies_CreateBloodParticle;
	[_victim, "WBK_DecapatedHead_Zombies_Normal"] remoteExec ["setFace",0];
	if ((isPlayer _victim) && !(WBK_Zombies_Corrupted_PlayerControlls)) exitWith {
		_victim setDamage 1;
		uiSleep 0.5;
		[_victim, [_victim vectorModelToWorld [0,-200,10], _victim selectionPosition "head", false]] remoteExec ["addForce", _victim];
		detach _main;
		[_main, "Corrupted_attack_success_failed"] remoteExec ["switchMove",0];
		_victim setVariable ['IMS_IsUnitInvicibleScripted',nil,true];
	};
	uisleep 1.5;
	if (!(alive _victim) or !(alive _main) or (animationState _victim != "Corrupted_Attack_victim") or !(animationState _main in ["corrupted_attack_success_back","corrupted_attack_success_front"])) exitWith {
		_victim setDamage 1;
		[_victim, [_victim vectorModelToWorld [0,-200,10], _victim selectionPosition "head", false]] remoteExec ["addForce", _victim];
		detach _main;
		[_main, "Corrupted_attack_success_failed"] remoteExec ["switchMove",0];
		_victim setVariable ['IMS_IsUnitInvicibleScripted',nil,true];
	};
	[_victim, selectRandom ["corrupted_head_attack_1","corrupted_head_attack_2","corrupted_head_attack_3","corrupted_head_attack_4"], 45, 5] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_victim, selectRandom ["dobi_blood_1","dobi_blood_2"], 80, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_victim, "decapetadet_sound_2", 50, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	[_victim, "Smasher_Eat", 80, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	_victim call WBK_Zombies_CreateBloodParticle;
	uisleep 1.3;
	if (!(alive _victim) or !(alive _main) or (animationState _victim != "Corrupted_Attack_victim") or !(animationState _main in ["corrupted_attack_success_back","corrupted_attack_success_front"])) exitWith {
		_victim setDamage 1;
		[_victim, [_victim vectorModelToWorld [0,-200,10], _victim selectionPosition "head", false]] remoteExec ["addForce", _victim];
		detach _main;
		[_main, "Corrupted_attack_success_failed"] remoteExec ["switchMove",0];
		_victim setVariable ['IMS_IsUnitInvicibleScripted',nil,true];
	};
	if (handgunWeapon _victim in IMS_Melee_Weapons) then {
		_victim removeWeapon handgunWeapon _victim;
	};
	_main removeAllEventHandlers "HandleDamage";
	[_victim, "corrupted_transformed", 150, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	if! (isPlayer _victim) then {
		[_victim] joinSilent (createGroup _side);
	};
	{
		_x setVariable ['IMS_IsUnitInvicibleScripted',1,true];
		_x allowDamage false;
	} forEach [_main,_victim];
	uiSleep 0.45;
	{
		_victim reveal [_x,4];
	} forEach allUnits;
	uiSleep 1;
	_victim setVariable ['IMS_IsUnitInvicibleScripted',nil,true];
	deleteVehicle _main;
	if (isPlayer _victim) exitWith {
		_victim remoteExec ["WBK_SpawnPlayerCorruptedControlls",_victim];
	};
	[_victim, false,true] execVM '\WBK_Zombies\AI\WBK_AI_Runner.sqf';
};

WBK_SpawnPlayerCorruptedControlls = {
	if (WBK_Zombies_Corrupted_PlayerControlls_Music) then {
		playMusic "Music_Arrival";
	};
	titleText ["", "WHITE IN",0.6];
	Corrupted_PPeffect_colorC = ppEffectCreate ["ColorCorrections",1500]; 
	Corrupted_PPeffect_colorC ppEffectAdjust [1,1,0,[1,0,0,0.2],[1,1,1,1],[0.299, 0.587, 0.114, 0]]; 
	Corrupted_PPeffect_colorC ppEffectEnable true; 
	Corrupted_PPeffect_colorC ppEffectCommit 0; 
	Corrupted_PPeffect_grain = ppEffectCreate ["FilmGrain",1550]; 
	Corrupted_PPeffect_grain ppEffectAdjust [.27,0.5,0,0.2,0.1]; 
	Corrupted_PPeffect_grain ppEffectEnable true; 
	Corrupted_PPeffect_grain ppEffectCommit 0;
	cutText ["<t color='#ff0000' size='5' font='PuristaSemibold'>KILL AS MUCH AS YOU CAN</t><br/><t color='#cdd9ff' size='3' font='PuristaMedium'>LMB TO ATTACK / RMB TO DODGE</t>", "PLAIN DOWN", -1, true, true];
	if (handgunWeapon player in IMS_Melee_Weapons) then {
		player removeWeapon handgunWeapon player;
	};
	private _wantedRating = (-9000);
	player addRating (_wantedRating - rating player);
	player unlinkItem hmd player;
	removeGoggles player;
	removeHeadgear player;
	player setVariable ["WBK_Zombie_CustomSounds",[
		["corrupted_head_attack_1","corrupted_head_attack_2","corrupted_head_attack_3","corrupted_head_attack_4","corrupted_head_attack_5"],
		["corrupted_idle_1","corrupted_idle_2","corrupted_idle_3","corrupted_idle_4"],
		["corrupted_head_attack_1","corrupted_head_attack_2","corrupted_head_attack_3","corrupted_head_attack_4","corrupted_head_attack_5"],
		["corrupted_dead_1","corrupted_dead_2","corrupted_dead_3"],
		["corrupted_dead_1","corrupted_dead_2","corrupted_dead_3"]
	]];
	[player, "WBK_Runner_Angry_Idle"] remoteExec ["switchMove",0];
	player setVariable ["WBK_SynthHP",WBK_Zombies_CorruptedHP,true];
	player setVariable ["WBK_AI_ISZombie",true,true];
	player setVariable ["WBK_AI_ZombieMoveSet","WBK_Runner_Angry_Idle", true];
	[player,"WBK_DosHead_Corrupted"] remoteExec ["setFace",0];
	player setDamage 0;
	if !(isNil "WBK_IsPresent_Necroplague") then {
		player setVariable ['isMutant',true];
	};
	if !(isNil "WBK_IsPresent_PIR") then {
		player setVariable ["dam_ignore_hit0",true,true];
		player setVariable ["dam_ignore_effect0",true,true];
	};
	[player, {
	_this removeAllEventHandlers "HitPart";
	_this addEventHandler [
		"HitPart",
		{
			(_this select 0) params ["_target","_shooter","_bullet","_position","_velocity","_selection","_ammo","_direction","_radius","_surface","_direct"];
			if ((_target == _shooter) or !(alive _target)) exitWith {};
			switch true do {
				case (((_ammo select 3) >= 0.7) && (_target getVariable "WBK_AI_ZombieMoveSet" != "WBK_Crawler_Idle")): {
					_new_vv = (_target getVariable "WBK_SynthHP") - ((_ammo select 0) * 2);
					if (_new_vv <= 0) exitWith {
						[_target, [_shooter vectorModelToWorld [random 500,random 500,100], _target selectionPosition "head", false]] remoteExec ["addForce", _target];
						_target removeAllEventHandlers "HitPart"; 
						[_target, [1, false, _shooter]] remoteExec ["setDamage",2];
					};
					_target setVariable ["WBK_SynthHP",_new_vv,true];
					[_target, selectRandom ["WBK_Runner_Fall_Back","WBK_Runner_Fall_Forward"]] remoteExec ["switchMove", 0]; 
				};
				case (((_selection select 0) in ["head","neck"]) && !(animationState _target in ["wbk_runner_fall_forward","wbk_runner_fall_back"])): {
					_new_vv = (_target getVariable "WBK_SynthHP") - ((_ammo select 0) * WBK_Zombies_HeadshotMP);
					if (_new_vv <= 0) exitWith {
						[_target, [_shooter vectorModelToWorld [0,500,50], _target selectionPosition "head", false]] remoteExec ["addForce", _target];
						_target removeAllEventHandlers "HitPart"; 
						[_target, [1, false, _shooter]] remoteExec ["setDamage",2];
					};
					_target setVariable ["WBK_SynthHP",_new_vv,true];
					if (_target getVariable "WBK_AI_ZombieMoveSet" == "WBK_Crawler_Idle") exitWith {};
					if (((_target worldToModel (_shooter modelToWorld [0, 0, 0])) select 1) < 0) exitWith {
						[_target, "WBK_Runner_Fall_Forward"] remoteExec ["switchMove", 0]; 
					};
					[_target, "WBK_Runner_Fall_Back"] remoteExec ["switchMove", 0];
				};
				case (((_selection select 0) in [
					"leftfoot",
					"lefttoebase",
					"leftleg",
					"leftlegroll",
					"leftupleg",
					"leftuplegroll",
					"rightupleg",
					"rightuplegroll",
					"rightleg",
					"rightlegroll",
					"rightfoot",
					"righttoebase"
				]) && (_target getVariable "WBK_AI_ZombieMoveSet" != "WBK_Crawler_Idle") && (animationState _target != "WBK_Runner_Fall_Forward")): {
					[_target, "dobi_fall_2", 50, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					[_target, "WBK_Runner_Fall_Forward"] remoteExec ["switchMove", 0];
				};
				default {
					_new_vv = (_target getVariable "WBK_SynthHP") - (_ammo select 0);
					if (_new_vv <= 0) exitWith {
						[_target, [_shooter vectorModelToWorld [0,500,50], _target selectionPosition (_selection select 0), false]] remoteExec ["addForce", _target];
						_target removeAllEventHandlers "HitPart"; 
						[_target, [1, false, _shooter]] remoteExec ["setDamage",2];
					};
					_target setVariable ["WBK_SynthHP",_new_vv,true];
				};
			};
		}
	];
	}] remoteExec ["spawn",0,true];
	player spawn {
		[WBK_Zombies_Corrupted_PlayerControlls_Time, "#900000"] spawn { 
			params [["_time",0, [0]],["_colour", "#FFFFFF", ["#FFFFFF"]]];
			private _timeout = time + _time;
			RscFiringDrillTime_done = false; 
			1 cutRsc ["RscFiringDrillTime", "PLAIN"];
			while { time < _timeout && !RscFiringDrillTime_done } do { 
				private _remainingTime = _timeout - time;
				private _timeFormat = [_remainingTime, "MM:SS.MS", true] call BIS_fnc_secondsToString; 
				private _text = format ["<t align='left' color='%1'><img image='%2' />%3:%4<t size='0.8'>.%5</t>", _colour, "A3\Modules_F_Beta\data\FiringDrills\timer_ca", _timeFormat select 0, _timeFormat select 1, _timeFormat select 2 ]; 
				RscFiringDrillTime_current = parseText _text; 
				uisleep 0.01; 
			}; 
			private _timeFormat = [0, "MM:SS.MS", true] call BIS_fnc_secondsToString; 
			RscFiringDrillTime_current = parseText format ["<t align='left' color='%1'><img image='%2' />%3:%4<t size='0.8'>.%5</t>", _colour, "A3\Modules_F_Beta\data\FiringDrills\timer_ca", _timeFormat select 0, _timeFormat select 1, _timeFormat select 2]; 
			uisleep 4; 
			RscFiringDrillTime_done = true; 
		};
		uiSleep WBK_Zombies_Corrupted_PlayerControlls_Time;
		if !(alive _this) exitWith {};
		_this setDamage 1;
	};
	player spawn {
		while {alive _this && lifeState _this != "INCAPACITATED"} do {
			if (animationState _this in ["wbk_runner_hit_b","wbk_runner_hit_f_2","wbk_runner_hit_f_1","wbk_runner_shoved_b","wbk_zombie_evade_b","wbk_runner_shoved_f"]) then {
				_insCount = lineIntersectsSurfaces [
					_this modelToWorldWorld (_this selectionPosition "pelvis"),
					_this modelToWorldWorld (_this selectionPosition "pelvis"),
					_this,
					objNull,
					true,
					1,
					"GEOM",
					"FIRE"
				];
				if (count _insCount != 0) then {
					[_this, "dobi_fall_2", 40, 6] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
					_this playMoveNow "WBK_Runner_Shoved_B_Stunned";
					_this playMove "WBK_Runner_Angry_Idle";
				};
			};
			_this allowDamage false;
			_this enableStamina false;
			uiSleep 0.1;
		};
		Corrupted_PPeffect_colorC ppEffectEnable false;
		ppEffectDestroy Corrupted_PPeffect_colorC;
		Corrupted_PPeffect_grain ppEffectEnable false;
		ppEffectDestroy Corrupted_PPeffect_grain;
		_this setDamage 1;
		_this call WBK_SpawnCorruptedHead;
		_this setVariable ["WBK_SynthHP",nil,true];
		_this setVariable ["WBK_AI_ISZombie",nil,true];
		_this setVariable ["WBK_AI_ZombieMoveSet",nil,true];
		[_this,{
			_this removeAllEventHandlers "HitPart";
		}] remoteExec ["spawn",0,true];
	};
};

WBK_SpawnCorruptedHead = {
	_unit = _this;
	_unit setDamage 1;
	[_unit, selectRandom ["decapetadet_sound_1","decapetadet_sound_2"], 60, 4] execVM "\WebKnight_StarWars_Mechanic\createSoundGlobal.sqf";
	_unit unlinkItem hmd _unit;
	removeGoggles _unit;
	removeHeadgear _unit;
	_unit call WBK_Zombies_CreateBloodParticle;
	[_unit, "WBK_DecapatedHead_Zombies_Normal"] remoteExec ["setFace",0];
	switch true do {
		case ((side group _unit == civilian) || (isPlayer _unit)): {
			_grp = createGroup [civilian,true];
			_headcrab = _grp createUnit ["WBK_SpecialZombie_Corrupted_1",getPosATL _unit, [], 0, "CAN_COLLIDE"];
			[_headcrab] joinSilent _grp;
			[_headcrab, "Corrupted_attack_success_failed"] remoteExec ["switchMove",0];
			_headcrab setSpeaker "NoVoice";
			[_headcrab,{
				{
				_x addCuratorEditableObjects [[_this], true];
				} forEach allCurators;
			}] remoteExec ["call",2];
		};
		case (side group _unit == resistance): {
			_headcrab = group _unit createUnit ["WBK_SpecialZombie_Corrupted_1",getPosATL _unit, [], 0, "CAN_COLLIDE"];
			[_headcrab, "Corrupted_attack_success_failed"] remoteExec ["switchMove",0];
			_headcrab setSpeaker "NoVoice";
			[_headcrab,{
				{
				_x addCuratorEditableObjects [[_this], true];
				} forEach allCurators;
			}] remoteExec ["call",2];
		};
		case (side group _unit == west): {
			_headcrab = group _unit createUnit ["WBK_SpecialZombie_Corrupted_2",getPosATL _unit, [], 0, "CAN_COLLIDE"];
			[_headcrab, "Corrupted_attack_success_failed"] remoteExec ["switchMove",0];
			_headcrab setSpeaker "NoVoice";
			[_headcrab,{
				{
				_x addCuratorEditableObjects [[_this], true];
				} forEach allCurators;
			}] remoteExec ["call",2];
		};
		case (side group _unit == east): {
			_headcrab = group _unit createUnit ["WBK_SpecialZombie_Corrupted_3",getPosATL _unit, [], 0, "CAN_COLLIDE"];
			[_headcrab, "Corrupted_attack_success_failed"] remoteExec ["switchMove",0];
			_headcrab setSpeaker "NoVoice";
			[_headcrab,{
				{
				_x addCuratorEditableObjects [[_this], true];
				} forEach allCurators;
			}] remoteExec ["call",2];
		};
	};
};