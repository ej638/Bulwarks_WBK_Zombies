/**
 *  fn_buildWaveManifest
 *
 *  Phase 2 — Weight-Class Budget System
 *  Builds a spawn manifest (array of [className, pointMulti]) using
 *  the Top-Down "Hierarchy Spend" algorithm from Spec §2.4.
 *
 *  Priority order: T5 → T4 → T3 → T2 → T1
 *  Each tier has a probability gate, per-wave cap, and cooldown check.
 *  The FIRST unit of each eligible tier is GUARANTEED (no RNG gate).
 *  Additional units beyond the first are probability-gated per spec.
 *  Remaining budget always drains into T1 horde filler.
 *
 *  Params:
 *    _waveNum      — current wave number (attkWave)
 *    _playerCount  — number of live WEST players
 *
 *  Returns: Array of [className, pointMulti] tuples
 *
 *  Domain: Server
 */

if (!isServer) exitWith { [] };

params ["_waveNum", "_playerCount"];

// ── Calculate total budget — Spec §2.3 (Late-Game Escalation) ──
// (wave-1) so wave 1 is a gentle warmup; scaling kicks in from wave 2.
// After EJ_BUDGET_LATE_THRESHOLD, each wave adds bonus budget on top of
// the linear scale so the factory can afford Goliath+Smasher combos.
private _lateBonus = ((_waveNum - EJ_BUDGET_LATE_THRESHOLD) max 0) * EJ_BUDGET_LATE_BONUS;
private _budget = floor (
    EJ_BUDGET_BASE
    + ((_waveNum - 1) * EJ_BUDGET_WAVE_SCALE)
    + _lateBonus
    + (_playerCount * EJ_BUDGET_PLAYER_SCALE)
);

private _startBudget = _budget;
private _manifest = [];

// ══════════════════════════════════════════════════════════
//  BLOATER RUSH OVERRIDE
//  When EJ_wbk_bloaterRush is set by fn_startWave (replaces suicideWave),
//  skip normal tier allocation. Bloater budget share scales with wave:
//  Entire budget spent on Boomers (floor(budget / 8) units).
//  No T1 filler — this is a pure Boomer wave.
// ══════════════════════════════════════════════════════════

if (!isNil "EJ_wbk_bloaterRush" AND { EJ_wbk_bloaterRush }) exitWith {
    EJ_wbk_bloaterRush = false;
    missionNamespace setVariable ["EJ_wavesSinceBloaterRush", 0];

    // Entire budget spent on bloaters — all bloaters, no T1 filler
    private _bloaterCount = floor (_budget / 8);

    for "_i" from 1 to _bloaterCount do {
        _manifest pushBack ["Zombie_Special_OPFOR_Boomer", 2.00];
    };

    // Update cooldown trackers (no Smasher/Goliath this wave)
    missionNamespace setVariable ["EJ_wavesSinceSmasher",
        (missionNamespace getVariable ["EJ_wavesSinceSmasher", 0]) + 1];
    missionNamespace setVariable ["EJ_wavesSinceGoliath",
        (missionNamespace getVariable ["EJ_wavesSinceGoliath", 0]) + 1];

    diag_log format [
        "[EJ] BLOATER RUSH wave %1: %2 Bloaters (budget: %3)",
        _waveNum, _bloaterCount, _startBudget
    ];

    _manifest
};

// ══════════════════════════════════════════════════════════
//  SIEGE WAVE OVERRIDE
//  When EJ_wbk_siegeWave is set by fn_startWave, force guaranteed
//  Smasher spawns (2-3) plus T1 horde to assault fortifications.
//  Bypasses normal cooldown and probability gates for Smashers.
// ══════════════════════════════════════════════════════════

if (!isNil "EJ_wbk_siegeWave" AND { EJ_wbk_siegeWave }) exitWith {
    EJ_wbk_siegeWave = false;

    // Guaranteed 2 Smashers + 1 more at 50% chance (max 3)
    private _smasherPool = EJ_wbk_unit_registry select {
        (_x select 1) == 4 AND { _waveNum >= (_x select 5) }
    };

    private _smasherCount = 0;
    if (count _smasherPool > 0) then {
        // 2 guaranteed
        for "_i" from 1 to 2 do {
            private _entry = selectRandom _smasherPool;
            _entry params ["_class", "", "_cost", "_pointMulti"];
            _budget = _budget - _cost;
            _manifest pushBack [_class, _pointMulti];
            _smasherCount = _smasherCount + 1;
        };
        // 50% chance of a third
        if (random 1 < 0.5) then {
            private _entry = selectRandom _smasherPool;
            _entry params ["_class", "", "_cost", "_pointMulti"];
            _budget = _budget - _cost;
            _manifest pushBack [_class, _pointMulti];
            _smasherCount = _smasherCount + 1;
        };
    };

    // Fill remaining budget with T1 horde
    private _t1Pool = EJ_wbk_unit_registry select {
        (_x select 1) == 1 AND { _waveNum >= (_x select 5) }
    };
    private _t1Count = 0;
    if (count _t1Pool > 0) then {
        while { _budget > 0 } do {
            private _entry = selectRandom _t1Pool;
            _budget = _budget - (_entry select 2);
            _manifest pushBack [_entry select 0, _entry select 3];
            _t1Count = _t1Count + 1;
        };
    };

    // Reset Smasher cooldown (just spawned them)
    missionNamespace setVariable ["EJ_wavesSinceSmasher", 0];
    missionNamespace setVariable ["EJ_wavesSinceGoliath",
        (missionNamespace getVariable ["EJ_wavesSinceGoliath", 0]) + 1];

    diag_log format [
        "[EJ] SIEGE WAVE %1: %2 Smashers + %3 T1 horde (budget: %4)",
        _waveNum, _smasherCount, _t1Count, _startBudget
    ];

    _manifest
};

// Combined T3+ counter (enforces EJ_MAX_ACTIVE_T3_PLUS across all high tiers)
// Late-game bonus: +2 headroom after wave 15 so Goliath+Smashers can co-spawn
private _t3PlusCap = EJ_MAX_ACTIVE_T3_PLUS + (if (_waveNum >= 15) then { 2 } else { 0 });
private _t3Count = 0;
private _t4Count = 0;
private _t5Count = 0;

// ══════════════════════════════════════════════════════════
//  EARLY BLOATER PREVIEW (waves 3-4)
//  Inject a small number of guaranteed bloaters before the normal
//  tier system unlocks them at wave 5. Count set by fn_startWave
//  in EJ_wbk_earlyBloaterCount (wave 3 → 1).
//  Deducted from budget. Budget is clamped to 0 after injection so a
//  negative value cannot silently starve the T1 filler pass.
//  Does not count toward T3 cap since the count is always 1.
// ══════════════════════════════════════════════════════════

private _earlyBloaters = if (!isNil "EJ_wbk_earlyBloaterCount") then { EJ_wbk_earlyBloaterCount } else { 0 };
if (_earlyBloaters > 0) then {
    for "_i" from 1 to _earlyBloaters do {
        _manifest pushBack ["Zombie_Special_OPFOR_Boomer", 2.00];
        _budget = _budget - 8;
    };
    // Clamp so T1 filler pass is not skipped on a negative budget
    _budget = 0 max _budget;
    // Reset so it doesn't carry over
    EJ_wbk_earlyBloaterCount = 0;
    _t3Count = _t3Count + _earlyBloaters;
    diag_log format ["[EJ] Early bloater preview: %1 bloaters injected (budget remaining: %2)", _earlyBloaters, _budget];
};

// ══════════════════════════════════════════════════════════
//  PASS 1: HIGH-TIER SELECTION (T5 → T4 → T3)
//  "Spend the big coins first" — Spec §2.4
//  FIRST unit per eligible tier is GUARANTEED (no RNG gate).
//  Additional units are probability-gated.
//  Cooldowns, per-wave caps, and probability gates all scale
//  with wave number to ensure late-game escalation.
//  No use of `continue` — nested if-then for SQF compat.
// ══════════════════════════════════════════════════════════

private _tiersToCheck = [5, 4, 3];

{
    private _tier = _x;

    // Filter registry to entries matching this tier AND unlocked by minWave
    private _pool = EJ_wbk_unit_registry select {
        (_x select 1) == _tier AND { _waveNum >= (_x select 5) }
    };

    if (count _pool > 0) then {

        // Per-tier max spawns this wave — scales with wave number
        private _maxThisWave = switch (_tier) do {
            case 5: {
                // Goliath: 1 base, +1 at wave 25 (max 2)
                if (_waveNum >= 25) then { 2 } else { 1 }
            };
            case 4: {
                // Smasher: 2 base, +1 at wave 20, +1 at wave 25 (max 4)
                2 + (if (_waveNum >= 20) then { 1 } else { 0 }) + (if (_waveNum >= 25) then { 1 } else { 0 })
            };
            case 3: {
                // T3 specials: 4 base, +1 per 5 waves past 10
                4 + (((_waveNum - 10) max 0) / 5)
            };
            default { 999 };
        };

        // Dynamic cooldown gate — shortens as waves increase
        private _cooldownMet = switch (_tier) do {
            case 5: {
                // Goliath cooldown: 5 base, 3 after wave 20, 2 after wave 25
                private _cd = if (_waveNum >= 25) then { 2 }
                    else { if (_waveNum >= 20) then { 3 } else { 5 } };
                (missionNamespace getVariable ["EJ_wavesSinceGoliath", 99]) >= _cd
            };
            case 4: {
                // Smasher cooldown: 3 base, 2 after wave 15, 1 after wave 20
                private _cd = if (_waveNum >= 20) then { 1 }
                    else { if (_waveNum >= 15) then { 2 } else { 3 } };
                (missionNamespace getVariable ["EJ_wavesSinceSmasher", 99]) >= _cd
            };
            default { true };
        };

        if (_cooldownMet) then {

            // Probability gate per tier — escalates in late game
            // Applied only to units BEYOND the guaranteed first
            private _rollChance = switch (_tier) do {
                case 5: {
                    // Goliath extra-unit: 40% base, 55% after w20, 70% after w25
                    if (_waveNum >= 25) then { 0.70 }
                        else { if (_waveNum >= 20) then { 0.55 } else { 0.40 } }
                };
                case 4: {
                    // Smasher extra-unit: 60% base, 75% after w15, 85% after w20
                    if (_waveNum >= 20) then { 0.85 }
                        else { if (_waveNum >= 15) then { 0.75 } else { 0.60 } }
                };
                case 3: { 0.80 };
                default { 1.0 };
            };

            // Minimum cost in this tier's pool
            private _minCost = (_pool select 0) select 2;
            private _tierCount = 0;
            private _combinedT3Plus = _t3Count + _t4Count + _t5Count;
            private _tierClasses = [];

            // T3 uses shuffle-deal: cycle through each pool entry once
            // before repeats, guaranteeing variety when 2-3 specials spawn.
            // Other tiers also shuffle for T4 variant diversity.
            private _shuffled = +_pool;  // shallow copy
            if (_tier == 3 OR _tier == 4) then {
                _shuffled call BIS_fnc_arrayShuffle;
            };
            private _shuffleIdx = 0;

            // Guaranteed minimum per tier — T3 scales with wave
            private _guaranteedMin = switch (_tier) do {
                case 3: {
                    // 1 + floor((wave-5)/8): w5=1, w13=2, w21=3, w29=4
                    1 + (floor (((_waveNum - 5) max 0) / 8))
                };
                default { 1 };
            };

            // ── GUARANTEED units (no RNG gate) ──
            while {
                _budget >= _minCost
                AND { _tierCount < _guaranteedMin }
                AND { _tierCount < _maxThisWave }
                AND { (_combinedT3Plus + _tierCount) < _t3PlusCap }
            } do {
                private _entry = if (_tier == 3 OR _tier == 4) then {
                    if (_shuffleIdx >= count _shuffled) then {
                        _shuffled call BIS_fnc_arrayShuffle;
                        _shuffleIdx = 0;
                    };
                    private _e = _shuffled select _shuffleIdx;
                    _shuffleIdx = _shuffleIdx + 1;
                    _e
                } else {
                    selectRandom _pool
                };
                _entry params ["_class", "", "_cost", "_pointMulti"];
                _budget   = _budget - _cost;
                _manifest pushBack [_class, _pointMulti];
                _tierClasses pushBack _class;
                _tierCount = _tierCount + 1;
            };

            // ── Additional units: probability-gated ──
            while {
                _budget >= _minCost
                AND { _tierCount < _maxThisWave }
                AND { (_combinedT3Plus + _tierCount) < _t3PlusCap }
                AND { random 1 < _rollChance }
            } do {
                private _entry = if (_tier == 3 OR _tier == 4) then {
                    // Re-shuffle when deck exhausted
                    if (_shuffleIdx >= count _shuffled) then {
                        _shuffled call BIS_fnc_arrayShuffle;
                        _shuffleIdx = 0;
                    };
                    private _e = _shuffled select _shuffleIdx;
                    _shuffleIdx = _shuffleIdx + 1;
                    _e
                } else {
                    selectRandom _pool
                };
                _entry params ["_class", "", "_cost", "_pointMulti"];
                _budget   = _budget - _cost;
                _manifest pushBack [_class, _pointMulti];
                _tierClasses pushBack _class;
                _tierCount = _tierCount + 1;
            };

            // Accumulate into combined counters
            switch (_tier) do {
                case 5: { _t5Count = _t5Count + _tierCount };
                case 4: { _t4Count = _t4Count + _tierCount };
                case 3: { _t3Count = _t3Count + _tierCount };
            };

            diag_log format ["[EJ] Manifest T%1: %2 units allocated [%3] (budget remaining: %4)",
                _tier, _tierCount, _tierClasses, _budget];
        } else {
            diag_log format ["[EJ] Manifest T%1: SKIPPED (cooldown not met)", _tier];
        };
    } else {
        diag_log format ["[EJ] Manifest T%1: SKIPPED (no eligible classes for wave %2)",
            _tier, _waveNum];
    };

} forEach _tiersToCheck;

// ══════════════════════════════════════════════════════════
//  PASS 2: T2 FILL (Runners / Shooters)
//  Guaranteed minimum scales with wave: 1 + floor(wave/5).
//  After guaranteed minimum, 95% gate for extras.
//  Late-game: after wave 12, T1 drain is capped at 50% of original
//  budget — unspent T1 budget is pre-converted into T2 slots here.
// ══════════════════════════════════════════════════════════

private _t2Count = 0;
private _t2Pool = EJ_wbk_unit_registry select {
    (_x select 1) == 2 AND { _waveNum >= (_x select 5) }
};

// Calculate how much T1 budget will be capped (spills into T2)
private _t1MaxBudget = if (_waveNum >= 12) then {
    floor (_startBudget * 0.5)
} else {
    _budget  // no cap before wave 12
};
private _t1Spillover = ((_budget - _t1MaxBudget) max 0);

if (count _t2Pool > 0) then {
    private _t2Cost = (_t2Pool select 0) select 2;

    // Guaranteed minimum: 1 + floor(wave/5)
    // wave 5=2, wave 10=3, wave 15=4, wave 20=5
    private _t2GuaranteedMin = 1 + floor (_waveNum / 5);

    // ── GUARANTEED T2 units (no RNG gate) ──
    private _t2Guaranteed = 0;
    while { _budget >= _t2Cost AND { _t2Guaranteed < _t2GuaranteedMin } } do {
        private _entry = selectRandom _t2Pool;
        _budget   = _budget - (_entry select 2);
        _manifest pushBack [_entry select 0, _entry select 3];
        _t2Count = _t2Count + 1;
        _t2Guaranteed = _t2Guaranteed + 1;
    };

    // ── Additional T2: 95% gate per unit ──
    while { _budget >= _t2Cost AND { random 1 < 0.95 } } do {
        private _entry = selectRandom _t2Pool;
        _budget   = _budget - (_entry select 2);
        _manifest pushBack [_entry select 0, _entry select 3];
        _t2Count = _t2Count + 1;
    };

    // ── T1→T2 spillover: convert capped T1 budget into extra T2 ──
    if (_t1Spillover > 0 AND { _budget >= _t2Cost }) then {
        private _spillT2 = floor (_t1Spillover / _t2Cost);
        for "_i" from 1 to _spillT2 do {
            if (_budget < _t2Cost) exitWith {};
            private _entry = selectRandom _t2Pool;
            _budget   = _budget - (_entry select 2);
            _manifest pushBack [_entry select 0, _entry select 3];
            _t2Count = _t2Count + 1;
        };
    };
};

diag_log format ["[EJ] Manifest T2: %1 units allocated (budget remaining: %2, T1 cap: %3)",
    _t2Count, _budget, _t1MaxBudget];

// ══════════════════════════════════════════════════════════
//  PASS 3: T1 REMAINDER (Horde drain)
//  After wave 12, T1 count is capped at 50% of original budget
//  to prevent late waves from being all harmless filler.
//  Remaining budget is discarded (already converted to T2 above).
// ══════════════════════════════════════════════════════════

private _t1Count = 0;
private _t1Pool = EJ_wbk_unit_registry select {
    (_x select 1) == 1 AND { _waveNum >= (_x select 5) }
};

private _t1Limit = if (_waveNum >= 12) then { _t1MaxBudget } else { 999999 };

while { _budget > 0 AND { count _t1Pool > 0 } AND { _t1Count < _t1Limit } } do {
    private _entry = selectRandom _t1Pool;
    _budget   = _budget - (_entry select 2);
    _manifest pushBack [_entry select 0, _entry select 3];
    _t1Count = _t1Count + 1;
};

// ══════════════════════════════════════════════════════════
//  UPDATE COOLDOWN TRACKERS — Spec §2.5
//  Persisted in missionNamespace for cross-wave survival
// ══════════════════════════════════════════════════════════

if (_t4Count > 0) then {
    missionNamespace setVariable ["EJ_wavesSinceSmasher", 0];
} else {
    missionNamespace setVariable ["EJ_wavesSinceSmasher",
        (missionNamespace getVariable ["EJ_wavesSinceSmasher", 0]) + 1];
};

if (_t5Count > 0) then {
    missionNamespace setVariable ["EJ_wavesSinceGoliath", 0];
} else {
    missionNamespace setVariable ["EJ_wavesSinceGoliath",
        (missionNamespace getVariable ["EJ_wavesSinceGoliath", 0]) + 1];
};

// Bloater rush cooldown (incremented here for normal waves; reset in bloater rush block above)
missionNamespace setVariable ["EJ_wavesSinceBloaterRush",
    (missionNamespace getVariable ["EJ_wavesSinceBloaterRush", 0]) + 1];

// ── Final manifest summary ──
diag_log format [
    "[EJ] Wave %1 manifest COMPLETE: %2 units (T1:%3 T2:%4 T3:%5 T4:%6 T5:%7) | budget: %8/%9 spent",
    _waveNum, count _manifest, _t1Count, _t2Count, _t3Count, _t4Count, _t5Count,
    _startBudget - _budget, _startBudget
];

_manifest
