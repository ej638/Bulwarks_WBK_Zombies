waitUntil {!isNil "bulwarkBox"};
player setVariable ["buildItemHeld", false];

// WBK revive bridge: overrides WBK_CreateDamage + installs revive-aware HandleDamage EH
call EJ_fnc_initPlayerReviveBridge;
// Respawn resets damage to 0 — immediately clear the tint.
[] call EJ_fnc_playerDamageTint;

// Delete empty containers + auto-pickup compatible magazines.
// WeaponHolderSimulated_Scripted does not trigger the engine's built-in
// magazine auto-pickup (that only fires for GroundWeaponHolder), so we
// emulate it: when a weapon is taken, grab its compatible mags from the
// same holder and add them to the player's inventory.
if (!isNil "EJ_lootTakeEH") then {
    player removeEventHandler ["Take", EJ_lootTakeEH];
};
EJ_lootTakeEH = player addEventHandler ["Take", {
    params ["_unit", "_container", "_item"];

    if (typeOf _container != "WeaponHolderSimulated_Scripted") exitWith {};

    // If the taken item is a weapon, auto-grab compatible magazines
    private _compatMags = getArray (configFile >> "CfgWeapons" >> _item >> "magazines");
    if (_compatMags isNotEqualTo []) then {
        private _containerMags = magazineCargo _container;
        private _toKeep = [];
        {
            if (_x in _compatMags && {_unit canAdd _x}) then {
                _unit addMagazine _x;
            } else {
                _toKeep pushBack _x;
            };
        } forEach _containerMags;

        clearMagazineCargoGlobal _container;
        { _container addMagazineCargoGlobal [_x, 1] } forEach _toKeep;
    };

    // Delay cleanup to let cargo state sync across the network
    [_container] spawn {
        params ["_container"];
        sleep 0.5;
        if (isNull _container) exitWith {};
        [_container] remoteExecCall ["loot_fnc_deleteIfEmpty", 2];
    };
}];

//remove and add gear
removeHeadgear player;
removeGoggles player;
removeVest player;
removeBackpack player;
removeAllWeapons player;
removeAllAssignedItems player;
player setPosASL ([bulwarkBox] call bulwark_fnc_findPlaceAround);

if(PLAYER_STARTWEAPON) then {
    // Random primary weapon (1 mag loaded, no spares)
    if (!isNil "List_Primaries" && {count List_Primaries > 0}) then {
        _primary = selectRandom List_Primaries;
        player addWeapon _primary;
        _ammoArray = getArray (configFile >> "CfgWeapons" >> _primary >> "magazines");
        if (count _ammoArray > 0) then {
            player addWeaponItem [_primary, selectRandom _ammoArray];
        };
    };

    player addMagazine "16Rnd_9x21_Mag";
    player addMagazine "16Rnd_9x21_Mag";
    player addWeapon "hgun_P07_F";
};

if(PLAYER_STARTMAP) then {
    player addItem "ItemMap";
    player assignItem "ItemMap";
    player linkItem "ItemMap";
};

if(PLAYER_STARTNVG) then {
    player addItem "Integrated_NVG_F";
    player assignItem "Integrated_NVG_F";
    player linkItem "Integrated_NVG_F";
};

player addItem "ItemCompass";
player assignItem "ItemCompass";
player linkItem "ItemCompass";

player addItem "ItemGPS";
player assignItem "ItemGPS";
player linkItem "ItemGPS";

if (isClass (configfile >> "CfgVehicles" >> "tf_anarc164")) then {
  player addItem "tf_anprc152";
};

waituntil {alive player};

//Disarm mines and explosives
_disarm =
{
    _explosive = nearestObject [player, "TimeBombCore"];
	deleteVehicle _explosive;
    _explosiveClass = typeOf _explosive;
    _count =  count (configFile >> "CfgMagazines");
    for "_x" from 0 to (_count-1) do {
        _item=((configFile >> "CfgMagazines") select _x);
		if (getText (_item >> "ammo") isEqualTo _explosiveClass) then {
			player addMagazine configName _item;
		};
    };
	player playAction "PutDown";
};
player addAction ["Disarm Explosive",_disarm,nil,2,false,true,"","(player distance2D nearestObject [player, 'TimeBombCore']) <= 1.6"];
_disarmMine =
{
    _explosive = nearestObject [player, "mineBase"];
	deleteVehicle _explosive;
    player playAction "PutDown";
};
player addAction ["Disarm Mine",_disarmMine,nil,2,false,true,"","(player distance2D nearestObject [player, 'mineBase']) <= 1.6"];

[] remoteExec ["killPoints_fnc_updateHud", 0];
