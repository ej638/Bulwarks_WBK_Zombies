/**
 *  fn_initWBKRegistry
 *
 *  Phase 2 — Weight-Class Budget System
 *  Initialises the WBK unit registry, budget formula parameters,
 *  cooldown trackers, and performance caps.
 *
 *  Called ONCE from initServer.sqf after editMe.sqf completes.
 *
 *  Domain: Server
 */

if (!isServer) exitWith {};

// ══════════════════════════════════════════════════════════
//  UNIT REGISTRY — Spec §2.2
//  [className, tier, budgetCost, pointMulti, autoInit, minWave]
// ══════════════════════════════════════════════════════════

EJ_wbk_unit_registry = [

    // ── T1: HORDE (civilian-dressed zombies — mixed speed & threat) ──
    // _Civ variants use WBK_ZombiesOriginalFactionClass="CIV_F" so
    // WBK_ZombiesRandomEquipment dresses them in civilian clothes (no armour).
    // Variety comes from minWave gating: wave 1 = shamblers only, wave 2 adds
    // calm runners, wave 3 adds angry runners.
    // pointMulti differentiates scoring: shamblers 0.5×, runners 1.0×.
    ["Zombie_O_Shambler_Civ",           1,  1,  0.50, true,  1],
    ["Zombie_O_RC_Civ",                 1,  1,  1.00, true,  2],
    ["Zombie_O_RA_Civ",                 1,  1,  1.00, true,  3],

    // ── T3: ELITE (special infected) ──
    // Leaper_2 removed — duplicate caused 50% Leaper bias in selectRandom.
    // minWave lowered: Boomer w5, Screamer w6, Leaper w7.
    ["Zombie_Special_OPFOR_Boomer",     3,  8,  2.00, true,  5],
    ["Zombie_Special_OPFOR_Screamer",   3,  8,  2.00, true,  6],
    ["Zombie_Special_OPFOR_Leaper_1",   3,  8,  2.00, true,  7],

    // ── T4: MINI-BOSS (Smasher variants) — _3 suffix = EAST (side=0) ──
    // Acid w12, Hellbeast w15 — all 3 variants in pool by wave 15 when intensity picks up
    ["WBK_SpecialZombie_Smasher_3",              4, 25, 4.00, true, 10],
    ["WBK_SpecialZombie_Smasher_Acid_3",         4, 25, 4.00, true, 12],
    ["WBK_SpecialZombie_Smasher_Hellbeast_3",    4, 25, 4.00, true, 15],

    // ── T5: BOSS (Goliath) — _3 suffix = EAST (side=0) ──
    ["WBK_Goliaph_3",                   5, 60, 8.00, true, 15]
];

// ══════════════════════════════════════════════════════════
//  COOLDOWN TRACKERS — Spec §2.5
//  Initialised to 99 so first-eligible-wave spawn is allowed
// ══════════════════════════════════════════════════════════

missionNamespace setVariable ["EJ_wavesSinceSmasher", 99];
missionNamespace setVariable ["EJ_wavesSinceGoliath", 99];
missionNamespace setVariable ["EJ_wavesSinceBloaterRush", 99];

// ══════════════════════════════════════════════════════════
//  PERFORMANCE CAPS — Spec §4
//  Read from mission parameter "PERFORMANCE_MODE" (1=Low, 2=Medium, 3=High).
//  Base cap set by tier; dynamic player scaling adds per-player headroom.
//  Solo players get a manageable count; 4-player groups get a larger horde.
// ══════════════════════════════════════════════════════════

private _perfMode = "PERFORMANCE_MODE" call BIS_fnc_getParamValue;
private _playerCount = 1 max (playersNumber west);

// [baseCap, baseT3Plus, perPlayerCap, perPlayerT3Plus]
private _perfSettings = switch (_perfMode) do {
    case 1: { [20, 3, 5, 1] };  // Low:    20 + 5/player   → solo=25,  4p=40
    case 3: { [40, 4, 10, 1] }; // High:   40 + 10/player  → solo=50,  4p=80
    default { [25, 3, 8, 1] };  // Medium: 25 + 8/player   → solo=33,  4p=57  (T3+ base raised 2→3)
};

_perfSettings params ["_baseCap", "_baseT3", "_perPlayerCap", "_perPlayerT3"];

EJ_MAX_ACTIVE_ZOMBIES  = _baseCap + (_playerCount * _perPlayerCap);
EJ_MAX_ACTIVE_T3_PLUS  = _baseT3 + (_playerCount * _perPlayerT3);

diag_log format ["[EJ] Performance mode %1: MAX_ZOMBIES=%2, T3+=%3 (%4 players)",
    _perfMode, EJ_MAX_ACTIVE_ZOMBIES, EJ_MAX_ACTIVE_T3_PLUS, _playerCount];

// ══════════════════════════════════════════════════════════
//  SPAWN THROTTLE — Spec §4.2
// ══════════════════════════════════════════════════════════

EJ_SPAWN_BATCH_SIZE    = 4;     // Units per batch
EJ_SPAWN_BATCH_DELAY   = 0.5;   // Seconds between batches
EJ_SPAWN_BOSS_DELAY    = 2.0;   // Extra delay after T4/T5 unit

// ══════════════════════════════════════════════════════════
//  BUDGET FORMULA PARAMETERS — Spec §2.3 (Late-Game Escalation)
//  Budget = base + (wave-1)*waveScale + max(0,wave-lateThreshold)*lateBonusScale + players*playerScale
//  Wave 1 solo ≈ 4 zombies; linear +4/wave early, accelerates +6/wave after threshold.
//  Late-game bonus ensures budget can support Goliath+Smasher combos by wave 18-20.
// ══════════════════════════════════════════════════════════

EJ_BUDGET_BASE         = 0;     // No fixed floor — wave 1 is a warmup
EJ_BUDGET_WAVE_SCALE   = 4;     // Budget added per wave (applied from wave 2)
EJ_BUDGET_PLAYER_SCALE = 4;     // Budget added per player (raised from 3)
EJ_BUDGET_LATE_THRESHOLD = 10;  // Wave after which late-game acceleration kicks in
EJ_BUDGET_LATE_BONUS   = 2;     // Extra budget per wave beyond threshold (stacks with waveScale)

// ══════════════════════════════════════════════════════════
//  MOVEMENT TUNING
//  Runner animation speed coefficient: 1.0 = default, 0.85 = 15% slower.
//  Applied via setAnimSpeedCoef to T1 runner classes (_RA_ / _RC_) at spawn.
//  Scales all animation playback — movement AND attacks — so keep > 0.7.
// ══════════════════════════════════════════════════════════

EJ_RUNNER_ANIM_SPEED_COEF = 0.80;

// Sprint-boost duration (seconds) applied at spawn via forceSpeed 6.
// After this many seconds, forceSpeed resets to -1 (natural WBK movement).
// Gets all zombies into the zone quickly before WBK PFH takes over.
EJ_SPAWN_SPRINT_DURATION  = 20;

// ══════════════════════════════════════════════════════════
//  DRIP-FEED STATE
// ══════════════════════════════════════════════════════════

EJ_spawnQueue          = [];    // Overflow queue: array of [className, pointMulti]
EJ_dripFeedHandler     = -1;    // CBA PFH handle, -1 = inactive

// ══════════════════════════════════════════════════════════
//  STUCK DETECTION STATE — used by clearStuck.sqf WBK branch
// ══════════════════════════════════════════════════════════

EJ_wbkStuckCheckArray  = [];    // Snapshot array: [unit, posATL] — rebuilt every 30s cycle

diag_log "[EJ] WBK Unit Registry initialised.";
