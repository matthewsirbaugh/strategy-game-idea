# Strategy Game Idea

Design docs live at the top level (start with AGENTS.md and EXPLORATIONS.md). The playable
prototype lives in `game/`.

## Running the prototype

Needs Godot 4.7 (`brew install --cask godot`).

- Play: `godot --path game`. After a pull, run `godot --headless --path game --import` first, or
  scripts added elsewhere fail with "Identifier not declared".
- Edit: open `game/project.godot` in the Godot editor, then press F5 to run.
- Preview a character with the toon shader and its animations: `godot --path game res://preview/character_preview.tscn`
- Verify imports and both test suites: `bash tools/check.sh`. Prints one line per successful
  check; on failure, prints the Godot output and exits nonzero, including script errors that
  Godot itself can report with a successful exit code. This checks code, not rendering or feel.
- Test the network and context math (Jump, refunds, Subagent, chip multipliers, compaction,
  progress kept when pulled out, circuits): `godot --headless --path game -s tests/test_hacking.gd`
- Test the rules (turn ending, donated compute, a cut-short sprint, aim lines, Predict, fog
  fairness, illegal actions, broken content, the test map, restarting a phase): `godot --headless --path game -s tests/test_rules.gd`

Deploy to facility, on the title screen, opens the loadout screen, a test tool for swapping each Operator's armor, gear and chips;
restarting after a loss keeps what was picked there.

Battle camera: left-drag, WASD or the arrow keys pan; right-drag (or Option-drag, or middle-drag) orbits; Q
and E turn; the wheel or a pinch zooms; H ghosts every wall; L switches the characters and props
between soft and hard-edged shading, to compare them. A click without a drag selects, and a
right-click without a drag steps back. In battle, N switches to the network, I scans every device,
and Space ends the turn. Esc pauses.

## How `game/` is organized

| Folder | Holds |
|---|---|
| `rules/` | Battle rules as plain data and logic, with no visuals |
| `battle/` | The 3D battle scene that draws the rules' state |
| `ui/` | Title, loadout, settings and pause menus |
| `content/` | Tunable data as `.tres` files: `battle.tres` gathers the units, devices, chips and V1 loadouts; the map is in `maps/` |
| `tests/` | The few tests that earn their keep, run headless |
| `autoload/` | The two globals: settings and scene switching |
| `art/` | Models, fonts and shared shaders the game loads: the toon look for models, and the painted walls, ground and signs, all under the fog. `surfaces.gd` holds every surface's colors and wear |
| `preview/` | Look-dev scenes that aren't part of the game |

## Code reading routes

Start with AGENTS.md and EXPLORATIONS.md, then the relevant exploration and the source below.
Read the named functions first (`rg -n '^func |^static func ' <file>`); expand to their callers
when needed. `rg --files game -g '*.gd' -g '*.tscn' -g '*.gdshader*' -g '!*.uid'` lists source
without walking through model imports. Read content resources only for the values involved in
the task. Historical findings, concept art and binary assets need not be loaded for code work.

| Task | Start here | Follow only as needed |
|---|---|---|
| Turns, AP, actions, hacking, chips, bodies, victory | [battle_state.gd](game/rules/battle_state.gd) | [unit.gd](game/rules/unit.gd), [RULES.md](RULES.md) |
| Who sees what: light and dark, cones, team vision, sound | [perception.gd](game/rules/perception.gd) | `BattleState.blocks_sight`, `has_line_of_sight` |
| Device verbs, circuits, vehicles | [devices.gd](game/rules/devices.gd) | `BattleState.use_verb`, `verb_preview` |
| Guard and turret turns, aim and fire | [enemy_ai.gd](game/rules/enemy_ai.gd) | `Perception.sweep`, `BattleState.step` |
| Map parsing, zones, networks, circuits, receptacles | [map_data.gd](game/rules/map_data.gd) | [reach.gd](game/rules/reach.gd), [grid.gd](game/rules/grid.gd) |
| Loadouts and restarting a phase | [battle_session.gd](game/rules/battle_session.gd) | `ui/loadout_menu.gd`, `autoload/scene_router.gd` |
| Actions, menus, picking, previews, event playback | [battle.gd](game/battle/battle.gd) | [battle_menus.gd](game/battle/battle_menus.gd), [battle_log.gd](game/battle/battle_log.gd), [hud.gd](game/battle/hud.gd), [network_view.gd](game/battle/network_view.gd) |
| Camera and mouse gestures | [camera_rig.gd](game/battle/camera_rig.gd) | `battle.gd` input and picking functions, `project.godot` input actions |
| Fog, overlays and wall visibility | [grid_view.gd](game/battle/grid_view.gd), [level_view.gd](game/battle/level_view.gd) | `art/shaders/fog.gdshaderinc`, `ghost.gdshaderinc` |
| Character rendering and animation | [unit_view.gd](game/battle/unit_view.gd), [toon_model.gd](game/art/toon_model.gd) | [character_rig.gd](game/art/characters/character_rig.gd), `preview/` |
| Environment and device props | [level_view.gd](game/battle/level_view.gd) | `city_backdrop.gd`, `signs.gd`, `rain.gd`, `art/surfaces.gd`, `art/shaders/` |
| Menus and saved settings | `ui/`, `autoload/` | The matching `.tscn` and `.gd` pair |

## Implementation boundaries

- `BattleState` owns action legality and state changes. Its actions return event dictionaries;
  `battle.gd` animates them and refreshes the views. Menu availability uses the same rules.
  `Perception`, `Devices` and `EnemyAI` are plain helpers that work on a `BattleState`; nothing
  else changes it. Downed units and finished battles reject actions.
- Predict and the verb previews run the real rules on `BattleState.clone()`, so a preview can't
  promise something play won't do. Units refer to each other by id so a clone shares nothing
  that changes.
- Definitions (`UnitDef`, `NodeDef`, `ChipDef`, `Loadout`) never change during a battle; what
  changes lives in `Unit` and `BattleState.devices`, including which side owns a turret. Map
  validation and broken content surface errors before scene construction.
- Network links, zones and circuits are fixed for a battle; vehicles move, so node positions come
  from `BattleState.node_cell`, not the map. `LevelView` and `NetworkView` follow them.
- `BattleSession` carries the map, content, chosen loadouts and anything carried into the phase.
  Restarting rebuilds the phase from it. It lives on the scene router; there are no other globals.
- The battle controller caches choices only while picking and clears them on state transitions;
  execution still validates through `BattleState`. Fog processes changing cells until they settle.
- Character retargeting resolves animation tracks once per clip, then samples the same poses.
  Shared model materials and animation libraries remain in `ToonModel`; surface appearance
  stays in `Surfaces` and the shaders. No rendering settings are chosen by the test runner.

Keep permanent tests to the subtle rules and regressions in `tests/`. For view/input changes,
run the native battle, exercise the changed interaction, inspect the engine output, and report
that separately from headless checks and from Bryson's playtest.
