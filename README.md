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
- Test the hacking math: `godot --headless --path game -s tests/test_hacking.gd`
- Test the rules (fog fairness, illegal actions, map checks): `godot --headless --path game -s tests/test_rules.gd`

Battle camera: left-drag or WASD pans; right-drag (or Option-drag, or middle-drag) orbits; Q
and E turn; the wheel or a pinch zooms; H ghosts every wall; L switches the characters and props
between soft and hard-edged shading, to compare them. A click without a drag selects, and a
right-click without a drag steps back.

## How `game/` is organized

| Folder | Holds |
|---|---|
| `rules/` | Battle rules as plain data and logic, with no visuals |
| `battle/` | The 3D battle scene that draws the rules' state |
| `ui/` | Title, settings and pause menus |
| `content/` | Tunable data as `.tres` files: the map, units, network nodes |
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
| Action legality, turn halves, context, victory | [battle_state.gd](game/rules/battle_state.gd) | [unit.gd](game/rules/unit.gd), [battle-core.md](explorations/battle-core.md#2026-09-29--context-as-a-battle-long-resource-and-interim-turn-rules-bryson) |
| Guard perception, patrols and investigation | [enemy_ai.gd](game/rules/enemy_ai.gd) | `BattleState.seen_enemies`, `can_pass`, `attack_targets` |
| Map parsing, routes and sight | [map_data.gd](game/rules/map_data.gd) | [reach.gd](game/rules/reach.gd), [grid.gd](game/rules/grid.gd) |
| Actions, selection and event playback | [battle.gd](game/battle/battle.gd) | [hud.gd](game/battle/hud.gd), [network_view.gd](game/battle/network_view.gd) |
| Camera and mouse gestures | [camera_rig.gd](game/battle/camera_rig.gd) | `battle.gd` input and picking functions, `project.godot` input actions |
| Fog and wall visibility | [grid_view.gd](game/battle/grid_view.gd), [level_view.gd](game/battle/level_view.gd) | `art/shaders/fog.gdshaderinc`, `ghost.gdshaderinc` |
| Character rendering and animation | [unit_view.gd](game/battle/unit_view.gd), [toon_model.gd](game/art/toon_model.gd) | [character_rig.gd](game/art/characters/character_rig.gd), `preview/` |
| Environment rendering | [level_view.gd](game/battle/level_view.gd) | `city_backdrop.gd`, `signs.gd`, `rain.gd`, `art/surfaces.gd`, `art/shaders/` |
| Menus and saved settings | `ui/`, `autoload/` | The matching `.tscn` and `.gd` pair |

## Implementation boundaries

- `BattleState` owns action legality and state changes. Its actions return event dictionaries;
  `battle.gd` animates them and refreshes the views. Menu availability uses the same rules.
  Downed/disabled units and finished battles reject actions. Guards plan from perceived targets
  and keep an investigation lead until they reach it, see a target, or cannot make progress.
- Maps and network links are fixed for the lifetime of a battle. `MapData` caches parsed layout;
  `BattleState` caches network searches. Map validation and missing or duplicate battle
  definitions surface errors before scene construction. `UnitDef` holds art paths so headless
  rule tests do not load models.
- The battle controller caches choices only while selecting an action and clears them on state
  transitions; execution still validates through `BattleState`. Fog processes changing cells
  until they settle. Wall visibility recalculates when the camera or watched units move, and
  updates shader parameters while ghosting changes. Revisit these assumptions before adding
  dynamic terrain, movable scenery or edits to a live map.
- Character retargeting resolves animation tracks once per clip, then samples the same poses.
  Shared model materials and animation libraries remain in `ToonModel`; surface appearance
  stays in `Surfaces` and the shaders. No rendering settings are chosen by the test runner.

Keep permanent tests to the subtle rules and regressions in `tests/`. For view/input changes,
run the native battle, exercise the changed interaction, inspect the engine output, and report
that separately from headless checks and from Bryson's playtest.
