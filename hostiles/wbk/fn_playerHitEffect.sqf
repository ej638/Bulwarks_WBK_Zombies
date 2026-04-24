/**
 *  fn_playerHitEffect
 *
 *  Displays a brief chromatic aberration flash to signal that the player
 *  has taken sub-lethal damage.  Intensity scales linearly with the raw
 *  damage value so a glancing hit produces a subtle shimmer and a heavy
 *  hit produces a more pronounced distortion.
 *
 *  A typical WBK zombie melee hit delivers 0.15–0.25 damage, producing
 *  roughly 3.75–6.25% chromatic aberration — clearly perceptible without
 *  impairing vision or aiming.
 *
 *  Uses ppEffect priority 1750 (above fn_ragePack ChromAberration at 200,
 *  below fn_ragePack ColorInversion at 2500).  The spawn'd fade block
 *  self-destructs the handle after 0.6 s total — no residue.
 *
 *  Params: [_damage] - raw damage value (0–1 scale; e.g. 0.20 for a hit
 *                      that costs 20% of the player's total health pool)
 *
 *  Domain: Client (player's own machine only — never remoteExec this)
 **/

params [["_damage", 0, [0]]];

// Intensity range: 2% minimum, 8% maximum, linearly scaled to damage.
private _intensity = (0.02 max (_damage * 0.25)) min 0.08;

[_intensity] spawn {
    params ["_intensity"];

    // Acquire an effect slot.  Increment priority on collision (matches
    // the pattern used in fn_ragePack.sqf).
    private _handle = -1;
    private _priority = 1750;
    while {
        _handle = ppEffectCreate ["ChromAberration", _priority];
        _handle < 0
    } do {
        _priority = _priority + 1;
    };

    _handle ppEffectEnable true;

    // Instant flash to peak intensity.
    _handle ppEffectAdjust [_intensity, _intensity, true];
    _handle ppEffectCommit 0;
    waitUntil {ppEffectCommitted _handle};

    // Hold briefly so the flash registers before fading.
    uiSleep 0.1;

    // Smooth fade to zero over 0.5 seconds.
    _handle ppEffectAdjust [0, 0, true];
    _handle ppEffectCommit 0.5;
    waitUntil {ppEffectCommitted _handle};

    _handle ppEffectEnable false;
    ppEffectDestroy _handle;
};
