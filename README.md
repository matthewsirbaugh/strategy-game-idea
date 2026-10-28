# Strategy Game Idea

Design docs live at the top level (start with AGENTS.md and EXPLORATIONS.md). The playable
prototype lives in `game/`.

## Running the prototype

Needs Godot 4.7 (`brew install --cask godot`).

- Play: `godot --path game`. After a pull, run `godot --headless --path game --import` first, or
  scripts added elsewhere fail with "Identifier not declared".
- Edit: open `game/project.godot` in the Godot editor, then press F5 to run.
- Review all recorded 3D assets in Model Library: `godot --path game/preview/model_viewer`. The standalone Mac app, controls and build instructions are in [the viewer README](game/preview/model_viewer/README.md).
- Preview a character with the toon shader and its animations: `godot --path game res://preview/character_preview.tscn`
- Preview new props under night light, close up and from the battle camera: `godot --path game res://preview/prop_preview.tscn`. It shows every new model in `game/assets/` (not `legacy/`).
- See the architecture slice from the battle camera: `godot --path game res://preview/architecture_slice.tscn`. Q and E turn, the wheel zooms, right-drag orbits, H ghosts every piece, F shows a stand-in fog.
- Ready a Meshy model for the game (real height, origin at its base, a triangle budget): `blender -b --python tools/prep_prop.py -- in.glb out.glb --height 1.0 --max-tris 8000`
- Install the optional GDScript linter: `pipx install 'gdtoolkit>=4,<5'`. The check runner finds it on `PATH` or in the pipx bin directory.
- Verify imports, every test suite and the linter when installed: `bash tools/check.sh`. Prints one line per successful
  check; on failure, prints the Godot output and exits nonzero, including script errors that
  Godot itself can report with a successful exit code. This checks code, not rendering or feel.
- Test the network and context math (Jump, refunds, Subagent, chip multipliers, compaction,
  progress kept when pulled out, circuits): `godot --headless --path game -s tests/test_hacking.gd`
- Test the rules (turn ending, donated compute, a cut-short sprint, aim lines, Predict, fog
  fairness, stuns ending, illegal actions, broken content, the test map, restarting a phase): `godot --headless --path game -s tests/test_rules.gd`
- Play three seeded random battles and check every offered action is honored, nothing impossible
  happens, and Predict and the verb previews tell the truth: `godot --headless --path game -s tests/test_playthrough.gd`
- Drive the battle scene's way into the AI through its real menus and clicks: `godot --headless --path game -s tests/test_battle_flow.gd`

Deploy to facility, on the title screen, opens the loadout screen, a test tool for swapping each Operator's armor, gear and chips;
restarting after a loss keeps what was picked there.

Battle camera: left-drag, WASD or the arrow keys pan; right-drag (or Option-drag, or middle-drag) orbits; Q
and E turn; the wheel or a pinch zooms; H ghosts every wall; L switches the characters and props
between soft and hard-edged shading, to compare them. A click without a drag selects, and a
right-click without a drag steps back, and in a submenu goes back a level. In battle, clicking a
teammate shows their panel, I marks every Breached device, and Space ends the turn. Esc pauses.
The network view is the AI's half of the turn: "AI" in the Operator's menu, or N, switches to it,
and the AI's menu lives there. An AI still in the backpack deploys from that menu, or by clicking a
ringed access point. Ending one half while the other still has AP to spend moves over to it ("End
Operator phase", "End AI phase"), and Space does what the end row says.

## How `game/` is organized

| Folder | Holds |
|---|---|
| `rules/` | Battle rules as plain data and logic, with no visuals |
| `battle/` | The 3D battle scene that draws the rules' state |
| `ui/` | Title, loadout, settings and pause menus |
| `content/` | Tunable data as `.tres` files: `battle.tres` gathers the units, devices, chips and V1 loadouts; maps are in `maps/`: `facility_yard.tres` is played, `facility_exterior.tres` is the rules tests' map |
| `tests/` | The few tests that earn their keep, run headless |
| `autoload/` | The two globals: settings and scene switching |
| `assets/` | Every model, one folder each with a record; the contract is `assets/README.md`. `legacy/` holds the retired models still used as placeholders |
| `art/` | Fonts, shaders and code for the game's look: the toon look for models, and the painted walls, ground and signs, all under the fog. `surfaces.gd` holds every surface's colors and wear |
| `preview/` | Look-dev scenes that aren't part of the game |

## Code reading routes

Use the already-loaded AGENTS.md, EXPLORATIONS.md and the relevant exploration's opening context
and task-specific sections. `python3 tools/read_section.py <file.md>` lists headings; add an exact
heading in quotes to read that section and its children. For code work, read this table,
**Implementation boundaries**, and the coding guide's **Working standard**, not its review history.
The agreement's **Requests** section holds assignments and file claims.

Read named functions first (`rg -n '^func |^static func ' <file>`), then their callers as needed.
`rg --files game -g '*.gd' -g '*.tscn' -g '*.gdshader*'` lists source; use `rg -l` to locate files
before reading matches. `.rgignore` keeps binary assets, imports, UIDs and captures out of default
searches, without changing Git or Godot. Pass an explicit file or use `--no-ignore` on a scoped
directory for asset/import work: `rg --no-ignore -n '^compress/mode=' game/assets -g '*.import'`.
Scenes, `.tres` content and JSON asset records remain searchable. Read only relevant resource values.

| Task | Start here | Follow only as needed |
|---|---|---|
| Turns, AP, actions, hacking, chips, bodies, victory | [battle_state.gd](game/rules/battle_state.gd) | [unit.gd](game/rules/unit.gd), [RULES.md](RULES.md) |
| Who sees what: light and dark, cones, team vision, sound | [perception.gd](game/rules/perception.gd) | `BattleState.blocks_sight`, `has_line_of_sight` |
| Device verbs, circuits, vehicles | [devices.gd](game/rules/devices.gd) | `BattleState.use_verb`, `verb_preview` |
| Guard and turret turns, aim and fire | [enemy_ai.gd](game/rules/enemy_ai.gd) | `Perception.sweep`, `BattleState.step` |
| Map parsing, zones, networks, circuits, receptacles | [map_data.gd](game/rules/map_data.gd) | [reach.gd](game/rules/reach.gd), [grid.gd](game/rules/grid.gd) |
| Loadouts and restarting a phase | [battle_session.gd](game/rules/battle_session.gd) | `ui/loadout_menu.gd`, `autoload/scene_router.gd` |
| Actions, menus, picking, previews, event playback | [battle.gd](game/battle/battle.gd) | [battle_menus.gd](game/battle/battle_menus.gd), [battle_log.gd](game/battle/battle_log.gd), [hover_info.gd](game/battle/hover_info.gd), [hud.gd](game/battle/hud.gd), [network_view.gd](game/battle/network_view.gd) |
| Camera and mouse gestures | [camera_rig.gd](game/battle/camera_rig.gd) | `battle.gd` input and picking functions, `project.godot` input actions |
| Fog, overlays and wall visibility | [grid_view.gd](game/battle/grid_view.gd), [level_view.gd](game/battle/level_view.gd) | `art/shaders/fog.gdshaderinc`, `ghost.gdshaderinc` |
| Fog fades and menus named after objects | [grid_view.gd](game/battle/grid_view.gd), [battle_menus.gd](game/battle/battle_menus.gd) | Request 18 findings and one-off verification scripts are [archived](ARCHIVE.md) |
| Shader scenery silhouettes, vision ticks and startup measurements | [scenery_fog.gd](game/battle/scenery_fog.gd), [vision_tick.gd](game/rules/vision_tick.gd), [startup_timing.gd](game/battle/startup_timing.gd) | `game/tests/test_scenery_fog.gd`, `tools/profile_startup.py`; the fog repair findings and one-off probes are [archived](ARCHIVE.md) |
| Character rendering and animation | [unit_view.gd](game/battle/unit_view.gd), [toon_model.gd](game/art/toon_model.gd) | [character_rig.gd](game/art/character_rig.gd), `preview/` |
| Environment and device props | [level_view.gd](game/battle/level_view.gd) | `city_backdrop.gd`, `signs.gd`, `rain.gd`, `art/surfaces.gd`, `art/shaders/` |
| Menus and saved settings | `ui/`, `autoload/` | The matching `.tscn` and `.gd` pair |

## Implementation boundaries

- `BattleState` owns action legality and state changes. Its actions return event dictionaries;
  `battle.gd` animates them and refreshes the views. Menu availability uses the same rules.
  `Perception`, `Devices` and `EnemyAI` are plain helpers that work on a `BattleState`; nothing
  else changes it. Downed units and finished battles reject actions.
- Door, device, chip and deploy checks return blocker codes from the rules; menus own their wording.
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
- Movement and vehicle events carry detached VisionTicks for each walked square. The controller
  applies them on arrival, with a final state refresh after playback; previews remain isolated.
- GridView keeps visible cells and adjacent walls/border cells binary for queries, while their
  visibility and brightness textures fade. The shader edge softens inside brighter cells so hidden
  neighbours gain no detail. SceneryFog opts level meshes into shared shaders once at build: hidden
  fragments show the model's own dark silhouette; screens, glow and lettering hide. Ground retains
  its textured fog-darkened look. Characters opt out and retain Locate/last-seen behavior.
- Character retargeting resolves animation tracks once per clip, then samples the same poses.
  Shared model materials and animation libraries remain in `ToonModel`; surface appearance
  stays in `Surfaces` and the shaders. No rendering settings are chosen by the test runner.

Keep permanent tests to the subtle rules and regressions in `tests/`. For view/input changes,
run the native battle, exercise the changed interaction, inspect the engine output, and report
that separately from headless checks and from Bryson's playtest.

## Tools

| Tool | Purpose |
|---|---|
| `bash tools/check.sh` | Imports, every test suite and the optional linter; quiet success, full failure output |
| `python3 tools/read_section.py <file.md> ["Exact heading"]` | Live Markdown outline, or one verbatim section including children; line ranges identify the source. Unknown/duplicate headings fail instead of guessing. Supports `#` headings outside fenced code |
| `tools/profile_startup.py`, `profile_startup.gd` | Startup timing |
| `tools/profile_battle.gd` | Battle-query timing |
| `tools/prep_prop.py` | Prepare a Meshy prop in Blender: scale, origin, triangle budget |
| `tools/prep_operator.py` | Graft the separate Meshy head, remesh body/head/pack, bake colour |
| `tools/add_fingers.py` | After `prep_operator.py --rig`: finger bones, knuckle loops and weights for a Meshy rig; a relaxed curl becomes the rest pose |
| `tools/render_review.py` | Render a model at fixed framings in Blender, optionally posed from a clip or framed on a bone, for before-and-after comparisons |
| `tools/build_fixtures.py` | Build pole fixtures and the barrier gate in Blender |
| `tools/build_architecture_kit.py` | Build the architecture kit's pieces to the 1.5 m grid in Blender and export each with its record |
