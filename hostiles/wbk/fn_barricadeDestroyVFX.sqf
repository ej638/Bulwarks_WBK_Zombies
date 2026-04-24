/**
 *  fn_barricadeDestroyVFX
 *
 *  Phase 14 — Client-side barricade destruction visual/audio effects.
 *  Called via remoteExec from server when a barricade's EJ_structHP reaches 0.
 *
 *  Params:
 *    _pos — ATL position of the destroyed barricade
 *
 *  Domain: Client (remoteExec'd to all clients)
 */

params ["_pos"];

if (isDedicated) exitWith {};

// Dust/debris particle burst
private _dust = "#particlesource" createVehicleLocal _pos;
_dust setParticleParams [
    ["\A3\data_f\ParticleEffects\Universal\Universal.p3d", 16, 12, 8, 0], "", "Billboard", 1, 2, [0,0,0.5],
    [0,0,1], 0, 1.2, 0.9, 0.3, [1.5, 3, 4],
    [[0.5,0.45,0.4,0.6],[0.5,0.45,0.4,0.3],[0.5,0.45,0.4,0]],
    [0.5], 0, 0, "", "", _pos
];
_dust setParticleRandom [0.5, [1,1,0.3], [0.5,0.5,0.3], 0, 0.3, [0,0,0,0], 0, 0];
_dust setDropInterval 0.01;

// Crumble sound
private _snd = "\A3\Sounds_F\arsenal\sfx\bullet_hits\hit_concrete_03.wss";
playSound3D [_snd, objNull, false, AGLtoASL _pos, 2, 1, 25];

// Clean up particle source after brief burst
[_dust] spawn { sleep 0.5; deleteVehicle (_this select 0); };
