# Copilot Instructions — Bulwarks WBK Zombies

## Project Summary

This is an **Arma 3 multiplayer mission** written in SQF (Arma 3 scripting language).
It integrates the **WBK Zombies mod** into the **Bulwarks wave-survival framework**.
Players defend a randomly selected city against escalating zombie waves.

The integration is a custom middleware adapter (`hostiles/wbk/`) that bridges:
- **Bulwarks**: the wave-state machine, scoring pipeline, loot, and base-building framework
- **WBK Zombies**: a mod providing synthetic-HP zombie units with custom PFH-driven AI scripts

All adapter functions are prefixed `EJ_fnc_` (CfgFunctions tag `EJ`, subclass `wbk`).
All adapter global variables are prefixed `EJ_`.

---

## Implementation Log — Always Update

**After every change, update `docs/IMPLEMENTATION_LOG.md`.**

- Add a new hotfix or phase section for meaningful changes.
- Record: files modified, variables added/changed, root cause and fix for bugs.
- Follow the established table format for "Components Delivered", "Files Modified", and "Global Variables".
- Reference spec section numbers (e.g. `Spec §2.4`) where applicable.

---

## Performance Awareness — Always Consider

This mission suffered severe desync and FPS collapse on a dedicated server (Phase 10) due to mission script CPU waste compounding WBK mod PFH overhead. The root causes were tight polling loops, expensive per-unit global scans, and unnecessary repeated work — none of which were individually catastrophic, but together overwhelmed the Arma 3 scheduler.

**For every feature, fix, or code change, consider the performance implications before implementing.** This does not mean avoiding all potentially expensive patterns — sometimes there is no better option. It means:

- Identify whether the change runs during a wave (high-load period) or only at setup/teardown.
- Consider alternative approaches and their relative cost (e.g. event-driven vs. polling, single-pass vs. multi-pass, cached vs. recomputed).
- If a performance trade-off exists, raise it explicitly when presenting a plan or recommending a change — describe what the cost is, when it occurs, and whether a cheaper alternative exists.
- If the chosen approach has a known performance impact that cannot be avoided, note it in the implementation log entry.

Each WBK zombie runs 3 CBA PFHs, so at wave-scale unit counts the mod alone generates thousands of callbacks per second. Any mission script overhead compounds directly on top of that baseline — what looks cheap in isolation can be significant in context.

---

## Project Layout

| Path | Purpose |
|---|---|
| `editMe.sqf` | All mission config globals (BULWARK_RADIUS, SCORE_*, etc.) — read-only for adapter |
| `initServer.sqf` | Server startup; `EJ_fnc_initWBKRegistry` is called here after `editMe.sqf` |
| `missionLoop.sqf` | Main wave loop; `waveUnits` tracked here |
| `hostiles/createWave.sqf` | Wave spawn entry point — infantry section replaced with `EJ_fnc_spawnWBKWave` |
| `hostiles/wbk/` | All WBK adapter files (functions + Functions.hpp) |
| `bulwark/functions/fn_startWave.sqf` | Special wave pool; sets wave flags like `EJ_wbk_bloaterRush` |
| `hostiles/moveHosToPlayer.sqf` | Redirects hostile AI onto players; WBK units are guarded and skipped |
| `description.ext` | CfgFunctions includes and CfgRemoteExec declarations for all functions |
| `docs/IMPLEMENTATION_LOG.md` | Chronological record of all changes — must be kept current |
| `docs/integration/adapter_design_spec.md` | Authoritative architecture and spec (Spec §) |

---

## Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.