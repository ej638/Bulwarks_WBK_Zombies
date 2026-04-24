/**
*  solidObject
*
*  Per-barricade server-side loop.
*  Vanilla AI: pushed away from barricade (original behaviour).
*  WBK zombies: skipped by push logic — their PFH AI handles pathing
*  around or through barricades. Smashers/Goliaths destroy Static-class
*  objects with built-in melee attacks when they reach them.
*  Barricade destruction is handled by Bloater explosions (fn_bloaterBarricadePFH)
*  which apply damage to EJ_structHP and deleteVehicle when HP reaches 0.
*
*  Domain: Server
**/

_object  = _this select 0;
_isHeld = _object getVariable "buildItemHeld";
_loopCount = 0;
_foundAIArr = [];

// Structural HP — many Land_* static objects are indestructible (no destruction
// model), so setDamage has no visible effect. Track HP manually and deleteVehicle
// when it reaches zero, similar to WBK's WBK_SynthHP for zombies.
if (isNil {_object getVariable "EJ_structHP"}) then {
    _object setVariable ["EJ_structHP", 1, true];
};

while {!(_object isEqualTo objNull) && !_isHeld} do {
    if (_loopcount >= 20) then {
        _loopCount = 0;
        _foundAIArr = [];
    };
    _loopCount = _loopCount + 1;
    _objRadius = (_object getVariable "Radius") + 1;
    _nearAI = _object nearEntities _objRadius;
    _isPlaced = _object getVariable "buildItemHeld";
    {
      if (suicideWave && (alive _x) && (side _x == east)) then {
        _x setDamage 1;
        deleteVehicle _object;
      }else{
        if (!isNil {_x getVariable "WBK_AI_ISZombie"}) then {
          // WBK zombies: don't push. PFH AI handles pathing.
          // Smashers/Goliaths destroy barricades with built-in melee.
        }else{
          // Vanilla AI: push away from barricade (original behaviour)
          if (side _x == east && !(_x in _foundAIArr) && (alive _x)) then {
            doStop _x;
            _x disableAI "MOVE";
            _aiDir = _object getDir _x;
            _x setDir _aiDir;
            _aiGoToPos = _object getRelPos [random [-10,0,-10], _aiDir];
            _x setBehaviour "CARELESS";
            _x setUnitPos "UP";
            _x playActionNow "FastF";
            _x forceSpeed 6;
            _safePos = [_aiGoToPos, 0, 8, 2, 0] call BIS_fnc_findSafePos;
            _x enableAI "MOVE";
            _x doMove _safePos;
            _foundAIArr pushBack _x;
          };
        };
      };
    } foreach _nearAI;
    sleep 0.1;
};
