/**
*  loot/scanCfg
*
*  Builds an expanded weapon pool from the full merged config tree (base game +
*  all loaded DLC and mods) and overwrites LOOT_WEAPON_POOL.
*
*  Only LOOT_WEAPON_POOL is changed -- all other pools keep their vanilla values
*  from editMe.sqf in both modes.
*
*  Called by initServer.sqf when LOOT_POOL_MODE == 1.
*
*  Three filters per CfgWeapons class:
*    isClass             - skip raw config properties (e.g. 'access') at the
*                          CfgWeapons root level; they are not weapon definitions
*    scope >= 2          - public classes only; skips internal/placeholder entries
*    type in [1, 2, 4]   - primary weapons (1), handguns/pistols (2), launchers (4)
*                          only; excludes equipment, binoculars, static weapon
*                          parts, and all UAV/carry-disassembled item types.
*                          NOTE: type 2 = handgun in actual A3 CfgWeapons, not 3.
*    magazines count > 0 - class must declare at least one compatible magazine;
*                          eliminates any remaining dummy or display-only weapons
*
*  Uses count/select/for loop -- see previous hotfix note for why configClasses
*  and forEach/continue are avoided.
*
*  Domain: Server
**/

private _primaries   = [];
private _secondaries = [];
private _launchers   = [];

private _cfgWeapons = configFile >> "CfgWeapons";
private _wepCount   = count _cfgWeapons;

for "_i" from 0 to (_wepCount - 1) do {
    private _class = _cfgWeapons select _i;

    if (isClass _class) then {
        if (getNumber (_class >> "scope") >= 2) then {
            private _type = getNumber (_class >> "type");
            if (_type in [1, 2, 4]) then {
                if (count (getArray (_class >> "magazines")) > 0) then {
                    private _className = configName _class;
                    switch (_type) do {
                        case 1: { _primaries   pushBack _className; };
                        case 2: { _secondaries pushBack _className; };
                        case 4: { _launchers   pushBack _className; };
                    };
                };
            };
        };
    };
};

private _combined = _primaries + _secondaries + _launchers;

if (count _combined == 0) then {
    // Should not happen in any valid Arma 3 install -- vanilla alone yields 30+ weapons
    diag_log "[scanCfg] WARNING: scan produced empty weapon pool -- reverting to List_AllWeapons";
    LOOT_WEAPON_POOL = List_AllWeapons;
} else {
    LOOT_WEAPON_POOL = _combined;
};

diag_log format [
    "[scanCfg] Weapon pool expanded -- Primaries: %1  Secondaries: %2  Launchers: %3  Total: %4",
    count _primaries,
    count _secondaries,
    count _launchers,
    count _combined
];
