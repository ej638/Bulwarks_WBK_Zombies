// variable to prevent players rejoining during a wave
playersInWave = [];
publicVariable "playersInWave";
missionNamespace setVariable ["buildPhase", true, true];

["<t size = '.5'>Loading lists.<br/>Please wait...</t>", 0, 0, 10, 0] remoteExec ["BIS_fnc_dynamicText", 0];
_hLocation = [] execVM "locationLists.sqf";
_hLoot     = [] execVM "loot\lists.sqf";
_hHostiles = [] execVM "hostiles\lists.sqf";
waitUntil {
    scriptDone _hLocation &&
    scriptDone _hLoot &&
    scriptDone _hHostiles
};
_hConfig   = [] execVM "editMe.sqf";
waitUntil { scriptDone _hConfig };

// ── WBK Integration: mission param overrides for WBK difficulty ──
// Overwrites CBA preInit defaults before any wave spawns.
// WBK AI scripts read these globals at unit spawn time (HP params).
// Screamer cooldown and headshot multiplier are read at ability-fire time.
WBK_Zombies_RunnerHP         = "WBK_T1_HP"               call BIS_fnc_getParamValue;
WBK_Zombies_MiddleHP         = "WBK_T1_HP"               call BIS_fnc_getParamValue;
WBK_Zombies_BloaterHP        = "WBK_BLOATER_HP"          call BIS_fnc_getParamValue;
WBK_Zombies_LeaperHP         = "WBK_LEAPER_HP"           call BIS_fnc_getParamValue;
WBK_Zombies_ScreamerHP       = "WBK_SCREAMER_HP"         call BIS_fnc_getParamValue;
WBK_Zombies_ScreamerCooldown = "WBK_SCREAMER_COOLDOWN"   call BIS_fnc_getParamValue;
WBK_Zombies_SmasherHP        = "WBK_SMASHER_HP"          call BIS_fnc_getParamValue;
WBK_Zombies_SmasherHP_Acid   = "WBK_SMASHER_HP"          call BIS_fnc_getParamValue;
WBK_Zombies_SmasherHP_Hell   = "WBK_SMASHER_HP"          call BIS_fnc_getParamValue;
WBK_Zombies_GoliathHP        = "WBK_GOLIATH_HP"          call BIS_fnc_getParamValue;
WBK_Zombies_HeadshotMP       = "WBK_HEADSHOT_MULTIPLIER" call BIS_fnc_getParamValue;

// Expand weapon pool to all DLC + loaded mods if host enabled it
if (LOOT_POOL_MODE == 1) then {
    _hScan = [] execVM "loot\scanCfg.sqf";
    waitUntil { scriptDone _hScan };
};

// ── WBK Integration: initialise unit registry and budget system ──
[] call EJ_fnc_initWBKRegistry;

// ── WBK Integration: override horde sound optimization ──
// WBK_ZombiePlayIdleSounds silences all non-leader zombies when the group
// has ≥15 alive members, playing a single "horde" sound on the leader.
// Because Bulwarks puts all wave zombies in one shared group (for
// findNearestEnemy reasons), this causes a lone leader zombie to sound
// like an entire horde while every other zombie is silent.
// Override: always play individual sounds per zombie at their own position.
WBK_ZombiePlayIdleSounds = {
    params ["_zombie", "_sound", "_dist", "_soundHorde", "_isAngrySnd"];
    [_zombie, [_sound, _dist]] remoteExecCall ["say3D", [0,-2] select isDedicated, false];
};

// ── WBK Integration: override Goliath melee + rock throw damage for revive ──
// WBK_GoliaphProceedDamage runs server-side and does _enemy setDamage 1
// (scalar) on all MAN units.  For players, we need to route through the
// revive system instead.  We also override the rock-throw projectile loop.
EJ_WBK_GoliaphProceedDamage_original = WBK_GoliaphProceedDamage;

WBK_GoliaphProceedDamage = {
    params ["_goliaph", "_anim", "_AttackDist"];
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
                    if (isPlayer _enemy) then {
                        // Route player damage through the revive bridge
                        [_enemy, 1, _zombie] remoteExec ["WBK_CreateDamage", _enemy];
                    } else {
                        _enemy setDamage 1;
                    };
                    uisleep 0.05;
                    if (animationState _zombie == "goliaph_melee_2" || animationState _zombie == "goliaph_melee_3") then {
                        [_enemy, [_zombie vectorModelToWorld [0,1000,2500], _enemy selectionPosition "head", false]] remoteExec ["addForce", _enemy];
                    } else {
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

// Override Goliath rock-throw projectile loop to route player damage
// through the revive-aware WBK_CreateDamage on the player's machine.
EJ_WBK_Goliph_RockThrow_original = WBK_Goliph_RockThrowingAbility;

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
    // Rock projectile in-flight loop: remoteExec player damage through
    // the revive-aware WBK_CreateDamage instead of direct setDamage 1
    [_throwableItem, _zombie] spawn {
        _grenade = _this select 0;
        _actualHitClass = "#particlesource" createVehicle position _grenade;
        _actualHitClass attachTo [_grenade,[0,0,0]];
        _zombie = _this select 1;
        while {alive _grenade} do {
            {
                if ((alive _x) and !(_x == _zombie)) then {
                    if (isPlayer _x) then {
                        [_x, 1, _zombie] remoteExec ["WBK_CreateDamage", _x];
                    } else {
                        _x setDamage 1;
                    };
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
            _rocks = [_rocks1,_rocks2,_rocks3];
            uisleep 0.3;
            { deletevehicle _x; } foreach _rocks;
        }] remoteExec ["spawn", [0,-2] select isDedicated,false];
        {_x setDamage 1;} forEach nearestTerrainObjects [_actualHitClass,[],9];
        {_x setDamage 1;} forEach nearestObjects [_actualHitClass,["Static"],9];
        deleteVehicle _actualHitClass;
    };
};

["<t size = '.5'>Creating Base...</t>", 0, 0, 30, 0] remoteExec ["BIS_fnc_dynamicText", 0];
_basepoint = [] execVM "bulwark\createBase.sqf";
waitUntil { scriptDone _basepoint };

["<t size = '.5'>Ready</t>", 0, 0, 0.5, 0] remoteExec ["BIS_fnc_dynamicText", 0];

publicVariable "bulwarkBox";
publicVariable "PARATROOP_CLASS";
publicVariable "BULWARK_SUPPORTITEMS";
publicVariable "BULWARK_BUILDITEMS";
publicVariable "PLAYER_STARTWEAPON";
publicVariable "PLAYER_STARTMAP";
publicVariable "PLAYER_STARTNVG";
publicVariable "List_Primaries";
publicVariable "PISTOL_HOSTILES";
publicVariable "DOWN_TIME";
publicVariable "RESPAWN_TICKETS";
publicVariable "RESPAWN_TIME";
publicVariable "PLAYER_OBJECT_LIST";
publicVariable "MIND_CONTROLLED_AI";
publicVariable "SCORE_RANDOMBOX";

//determine if Support Menu is available
_supportParam = ("SUPPORT_MENU" call BIS_fnc_getParamValue);
if (_supportParam == 1) then {
  SUPPORTMENU = false;
}else{
  SUPPORTMENU = true;
};
publicVariable 'SUPPORTMENU';

//Determine team damage Settings
_teamDamageParam = ("TEAM_DAMAGE" call BIS_fnc_getParamValue);
if (_teamDamageParam == 0) then {
  TEAM_DAMAGE = false;
}else{
  TEAM_DAMAGE = true;
};
publicVariable 'TEAM_DAMAGE';

//determine if hitmarkers appear on HUD
HITMARKERPARAM = ("HUD_POINT_HITMARKERS" call BIS_fnc_getParamValue);
publicVariable 'HITMARKERPARAM';

_dayTimeHours = DAY_TIME_TO - DAY_TIME_FROM;
_randTime = floor random _dayTimeHours;
_timeToSet = DAY_TIME_FROM + _randTime;
setDate [2018, 7, 1, _timeToSet, 0];

//[] execVM "revivePlayers.sqf";
[bulwarkRoomPos] execVM "missionLoop.sqf";

[] execVM "area\areaEnforcement.sqf";
[] execVM "hostiles\clearStuck.sqf";
//[] execVM "hostiles\solidObjects.sqf";
[] execVM "hostiles\moveHosToPlayer.sqf";
