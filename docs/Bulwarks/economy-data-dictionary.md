# Mission Economy: Technical Data Dictionary

**Scope:** Kill → Reward pipeline; Loot distribution; Point spending API  
**Analyst:** Technical Solution Lead  
**Date:** April 9, 2026

---

## 1. The Score Hook

### How points are awarded on kill

Points are **not** polled by a global monitoring loop. They are wired via per-unit event handlers attached at spawn time inside `hostiles/spawnInfantry.sqf`:

```sqf
_unit addEventHandler ["Hit",    killPoints_fnc_hit];
_unit addEventHandler ["Killed", killPoints_fnc_killed];
```

Both handlers run **server-side** (`isServer` guard inside each function). This pattern is replicated wherever units are spawned (infantry, squads, etc.). There is no post-hoc scanning of the unit list.

### Event handler chain

| Stage | Script | Domain | Trigger |
|---|---|---|---|
| Unit spawns | `hostiles/spawnInfantry.sqf` | Server | `createUnit` |
| Bullet connects | `score/functions/fn_hit.sqf` | Server (EH) | `Hit` EH |
| Unit dies | `score/functions/fn_killed.sqf` | Server (EH) | `Killed` EH |
| HUD refresh | `score/functions/fn_updateHud.sqf` | Client (remoteExec) | After every point change |
| Civilian killed | `score/functions/fn_civKilled.sqf` | Server (EH) | `Killed` EH on civilian units |

### Point formulas

**Hit (before kill):**
```
points_awarded = SCORE_HIT + (SCORE_DAMAGE_BASE × damage_fraction)
```
`damage_fraction` is the raw ArmA damage value (0.0–1.0). Points are awarded immediately on each hit and accumulated in a per-unit `points` array.

**Kill:**
```
points_awarded = SCORE_KILL × killPointMulti
```
`killPointMulti` is a unit variable set at spawn to one of the multipliers below. The incremental hit-points already awarded per bullet are **not** revoked on kill; kills grant a separate bonus on top.

> ⚠️ **Dead code in `fn_killed.sqf`:** The script fetches the unit's accumulated `points` array and sums it into a local `_killPoints` variable, but never passes the result to `killPoints_fnc_add`. Only the flat `SCORE_KILL * _kilPointMulti` bonus is actually sent. This looks like an unfinished "kill-bonus replaces hit-bonus" feature.

**Civilian kill (penalty):**
```
points_deducted = SCORE_KILL × 10
```
Applied via `killPoints_fnc_spend`, so it cannot push the player below zero.

### Kill-point multipliers (configured in `editMe.sqf`)

| Enemy Tier | Variable | Multiplier |
|---|---|---|
| Wave tier 1 enemies | `HOSTILE_LEVEL_1_POINT_SCORE` | 0.75× |
| Wave tier 2 enemies | `HOSTILE_LEVEL_2_POINT_SCORE` | 1.00× |
| Wave tier 3 enemies | `HOSTILE_LEVEL_3_POINT_SCORE` | 1.50× |
| Armed cars | `HOSTILE_CAR_POINT_SCORE` | 2.00× |
| Armour | `HOSTILE_ARMOUR_POINT_SCORE` | 4.00× |

All base score constants (`SCORE_KILL`, `SCORE_HIT`, `SCORE_DAMAGE_BASE`) are mission parameters fetched via `BIS_fnc_getParamValue` and can be configured per-session without editing scripts.

---

## 2. The `killPoints` Variable — Storage & Broadcast

The player's balance is stored as a single integer on the player object:

```sqf
_player setVariable ["killPoints", _killPoints, true];  // third arg = broadcast globally
```

The `true` flag means the value is replicated to **all connected machines** (JIP-inclusive). Any machine can read a player's balance, but **only the server is authorised to write it**:

- `killPoints_fnc_add` — guarded by `isServer`
- `killPoints_fnc_spend` — guarded by `isServer`
- All callers use `remoteExec [..., 2]` (target = server) so authority is enforced even when the action fires on a client.

---

## 3. Loot Table Analysis

### Loot pool construction (`loot/lists.sqf`)

The loot pool is built **dynamically at mission start** by iterating over `configFile`. There are no hardcoded weapon class names in the pool definition. All items currently loaded by the server (vanilla + mods) are eligible unless blacklisted.

| Pool variable | Source |
|---|---|
| `LOOT_WEAPON_POOL` | `CfgWeapons` where `type` ∈ {1=primary, 3=secondary, 4=launcher} |
| `LOOT_APPAREL_POOL` | `CfgWeapons` where `ItemInfo.Type` ∈ {605=hat, 801=uniform, 701=vest} |
| `LOOT_ITEM_POOL` | `CfgWeapons` where `ItemInfo.Type` ∈ {201=optic, 301=rail, 601/620/621/616/619/401=misc items} |
| `LOOT_EXPLOSIVE_POOL` | `CfgMagazines` filtered by mine/grenade markers |
| `LOOT_STORAGE_POOL` | `CfgVehicles` where `vehicleClass == "Backpacks"` |

All pools are then filtered: `Pool - LOOT_BLACKLIST`. The blacklist in `editMe.sqf` explicitly excludes CSAT UAV items (to prevent round-blocking designator bugs) and IR grenades.

A full override is available via `LOOT_WHITELIST_MODE`:
- `0` = off (use full configured pools)
- `1` = only classes in whitelist arrays spawn
- `2` = whitelist items are added to pools (increases their probability)

### Loot distribution algorithm (`loot/spawnLoot.sqf`)

```
Domain: Server
Executes: Once per wave (cleaned and re-run at wave start)
```

Every building in `lootHouses` is iterated. Two counters control density:

| Parameter | Controls |
|---|---|
| `LOOT_HOUSE_DISTRIBUTION` | Every *n*th house gets any loot at all |
| `LOOT_ROOM_DISTRIBUTION` | Within a qualifying house, every *n*th room position gets a container |

Each qualifying room position gets one `WeaponHolderSimulated_Scripted` container. The container receives one of 6 item categories chosen by `floor random 6`:

| Roll | Category |
|---|---|
| 0 | Weapon + matching magazine |
| 1 | Magazine(s) only (1–3 count) |
| 2 | Clothing/vest/hat |
| 3 | Misc item (optic, NVG, first-aid, etc.) |
| 4 | Backpack |
| 5 | Explosive (mine/grenade/charge, 1–3 count) |

Three special world objects are also spawned inside buildings each wave:

| Object class | Colour/action | Purpose | Points value |
|---|---|---|---|
| `Box_C_UAV_06_Swifd_F` | Purple — "Reveal loot" | Runs `supports/lootDrone.sqf` to reveal all loot on map | None |
| `Land_SatelliteAntenna_01_F` | Purple — "Unlock Support Menu" | One-time flag: sets `SUPPORTMENU = true`; awards finders bonus | `20 × SCORE_KILL` |
| `Land_Money_F` | Green — "Collect Points" | Direct point pickup; deleted on collect | `50 × SCORE_KILL` |

The satellite antenna **only spawns if `SUPPORTMENU` is false**, so it disappears permanently once found. The money bag and drone box spawn every wave.

### Is loot regenerated per wave?

**Yes — full regeneration.** At the start of each wave, `fn_startWave.sqf` calls:

```sqf
[] call loot_fnc_cleanup;           // delete all existing loot containers
_spawnLoot = execVM "loot\spawnLoot.sqf";
waitUntil { scriptDone _spawnLoot };  // block wave countdown until loot is placed
```

This means the map is wiped and re-seeded every wave. Players cannot "save" loot from the previous round by leaving items on the ground — containers are deleted by `loot_fnc_cleanup` regardless of whether they still have contents.

---

## 4. The "Bulwark Box" Spending API

### `killPoints_fnc_spend` — the authoritative deduction function

**File:** `score/functions/fn_spend.sqf`  
**Domain:** Server (`isServer` guard)

```sqf
params: [_player, _points]
```

Logic:
1. Read `_player getVariable "killPoints"` (defaults to `0` if unset)
2. Check `_killPoints - _points >= 0` — **purchases are rejected silently if balance is insufficient**; the player cannot go negative
3. If valid: deduct, broadcast new value globally (`setVariable [..., true]`), trigger HUD refresh on that player

### Purchase entry points (all calls route to `killPoints_fnc_spend` on the server)

| Context | Script | Cost |
|---|---|---|
| Build item (barricades, defences, vehicles) | `bulwark/purchase.sqf` | `BULWARK_BUILDITEMS[n][0]` (25–∞ pts, see shop list) |
| Self-heal at Bulwark Box | `bulwark/createBase.sqf` | 500 pts (hardcoded) |
| Spin the Random Loot Box | `loot/spin/main.sqf` | `SCORE_RANDOMBOX` (950 pts default) |
| Spin the Random Loot Box (inline action) | `bulwark/createBase.sqf` | `SCORE_RANDOMBOX` |
| Support ability (CAS, UAV, etc.) | `supports/purchase.sqf` | `BULWARK_SUPPORTITEMS[n][0]` (800–7500 pts) |

### `killPoints_fnc_add` — the credit function

**File:** `score/functions/fn_add.sqf`  
**Domain:** Server (`isServer` guard)

```sqf
params: [_player, _points]
```

Adds `_points` (rounded) to `killPoints`, broadcasts, triggers HUD. All game events that grant points call this function — there is no other write path.

### Build item shop reference (`BULWARK_BUILDITEMS` in `editMe.sqf`)

Format: `[price, displayName, className, rotation, radius, hasAI]`

Sample entries (prices in points):

| Price | Item |
|---|---|
| 25 | Long Plank (8m) |
| 50 | Junk Barricade |
| 75 | Small Ramp |
| 85 | Flat Triangle |
| … | … (defined in `editMe.sqf`) |

> ⚠️ **Sell is broken:** `build/functions/fn_sell.sqf` deletes the placed object with `deleteVehicle` but the refund line `[_player, _shopPrice] call killPoints_fnc_add` is **commented out**. Players permanently lose points when demolishing their own defences.

### Support menu reference (`BULWARK_SUPPORTITEMS` in `editMe.sqf`)

| Price | Ability |
|---|---|
| 800 | Recon UAV |
| 1,680 | Emergency Teleport |
| 1,950 | Paratroopers |
| 3,850 | Missile CAS |
| 4,220 | Mine Cluster Shell |
| 4,690 | Rage Stimpack |
| 5,930 | Mind Control Gas |
| 6,666 | ARMAKART™ |
| 7,500 | Predator Drone |

The support menu is **locked behind the satellite dish find**. `SUPPORTMENU` defaults to `false`; finding and interacting with the `Land_SatelliteAntenna_01_F` loot object globally broadcasts `SUPPORTMENU = true`, which then populates the support tab of the Bulwark Box GUI.

---

## 5. Performance — Server vs. Client; Entity Bloat Controls

### Execution authority summary

| System | Runs on |
|---|---|
| Loot pool construction (`lists.sqf`) | Server |
| Loot spawning (`spawnLoot.sqf`) | Server |
| Loot existence query (`loot_fnc_get`) | Client (returns local `nearestObjects` query) |
| Loot cleanup (`loot_fnc_cleanup`) | Server |
| Empty container check (`loot_fnc_deleteIfEmpty`) | Client — `remoteExec ["deleteVehicle", 2]` to server |
| Point add/spend | Server |
| HUD update | Local client (`remoteExec` to specific player machine) |
| Hit/Kill event handlers | Server |
| Hit marker rendering | Client (`remoteExec` to instigating player) |

### Entity bloat controls

| Mechanism | Where | Effect |
|---|---|---|
| `loot_fnc_cleanup` at wave start | `fn_startWave.sqf` lines 301–303 | Deletes **all** loot containers zone-wide before re-seeding. Prevents accumulation across waves. |
| `loot_fnc_deleteIfEmpty` | Called client-side after player loots a container | Deletes `WeaponHolderSimulated_Scripted` containers that are completely emptied. |
| `waveUnits` body cleanup | `fn_startWave.sqf` line ~14 | Rotates dead unit bodies through a 3-slot ring buffer; oldest slot is deleted each wave (`BODY_CLEANUP` param controls which slot). |
| `spawnLoot.sqf` blocks on `waitUntil {scriptDone}` | `fn_startWave.sqf` | Ensures loot is fully placed before the wave countdown ends — eliminates a race condition where players could start the wave before loot is queryable. |

> ⚠️ **Potential bloat — dead weapon holders:** `loot_fnc_deleteIfEmpty` runs on the **client** that empties a container. If a player disconnects mid-loot or the client crashes before the check runs, the empty container is never deleted. The wave-start `loot_fnc_cleanup` will catch these on the *next* wave, so the worst-case accumulation window is one wave.

> ⚠️ **`loot_fnc_get` is client-local:** It uses `nearestObjects` which is a local query. If called on a different machine from where cleanup runs, results may be stale for one frame. In practice this is not a problem because cleanup runs on the server and `deleteVehicle` is a server call.

---

## 6. Complete Economy Data Dictionary

| Symbol | Type | Domain | Description |
|---|---|---|---|
| `killPoints` | player variable (integer) | Global (broadcast) | A player's current point balance. Written only by server. |
| `killPoints_fnc_add` | function | Server | Credits `_points` to `_player`. Entry point for all earning events. |
| `killPoints_fnc_spend` | function | Server | Debits `_points` from `_player`. Guards against negative balance. No-ops silently if insufficient funds. |
| `killPoints_fnc_hit` | EH function | Server | Awards `SCORE_HIT + (SCORE_DAMAGE_BASE × dmg)` per bullet hit. Accumulates hit values in unit's `points` array. |
| `killPoints_fnc_killed` | EH function | Server | Awards `SCORE_KILL × killPointMulti` on unit death. `killPointMulti` set at spawn. |
| `killPoints_fnc_civKilled` | EH function | Server | Deducts `SCORE_KILL × 10` when a player kills a civilian. |
| `killPoints_fnc_updateHud` | function | Client | Re-renders the score HUD for the local player. Called via `remoteExec` after every balance change. |
| `killPoints_fnc_hitMarker` | function | Client | Pushes a floating damage number to the `hitMarkers` array for screen rendering. |
| `killPointMulti` | unit variable (float) | Global | Per-enemy kill reward multiplier. Set during spawn. Ranges 0.75–4.0 based on enemy tier. |
| `points` | unit variable (array) | Server | Running accumulation of hit-point values on a live enemy. Currently unused at kill resolution (dead code in `fn_killed`). |
| `SCORE_KILL` | mission param | Global | Base kill reward in points. |
| `SCORE_HIT` | mission param | Global | Flat reward per bullet hit. |
| `SCORE_DAMAGE_BASE` | mission param | Global | Scales damage-proportional hit reward (100% dmg = full value). |
| `SCORE_RANDOMBOX` | constant (`editMe.sqf`) | Global | Cost to spin the random loot box. Default: 950. |
| `SUPPORTMENU` | global bool | Global (publicVariable) | Unlocks the support tab in the Bulwark Box GUI once the satellite dish is found. |
| `LOOT_HOUSE_DISTRIBUTION` | mission param | Server | Every *n*th house in the zone receives loot. |
| `LOOT_ROOM_DISTRIBUTION` | mission param | Server | Within a loot house, every *n*th room position receives a container. |
| `LOOT_WHITELIST_MODE` | config (`editMe.sqf`) | Server | 0=off, 1=whitelist-only, 2=whitelist additive. |
| `LOOT_BLACKLIST` | array (`editMe.sqf`) | Server | Classnames excluded from all loot pools. |
| `buildPhase` | global bool | Global (publicVariable) | `true` during inter-wave build/shopping phase; `false` during active wave. |
| `bulwarkBox` | object | Global | The central supply crate. Shop, heal, and spin actions are attached to it. |
| `BULWARK_BUILDITEMS` | array (`editMe.sqf`) | Client | `[price, name, class, rotation, radius, hasAI]` — defines the purchasable defence catalogue. |
| `BULWARK_SUPPORTITEMS` | array (`editMe.sqf`) | Client | `[price, name, ability]` — defines the support ability catalogue (requires `SUPPORTMENU`). |
| `loot_fnc_cleanup` | function | Server | Deletes all loot containers within `BULWARK_RADIUS × 1.2`. Called at wave start before re-seeding. |
| `loot_fnc_get` | function | Client | Returns `nearestObjects` list of all loot container types in the zone. Used as input to cleanup. |
| `loot_fnc_deleteIfEmpty` | function | Client → Server | Deletes a `WeaponHolderSimulated_Scripted` if all cargo arrays are empty; `deleteVehicle` sent to server. |
| `SatUnlocks` | array | Global (publicVariable) | Tracks all spawned satellite antenna objects so they can all be deleted once one is found. |
| `waveUnits` | 3-slot array | Server | Ring buffer of enemy unit arrays across the last 3 waves. Oldest wave's corpses are cleaned on wave start. |
