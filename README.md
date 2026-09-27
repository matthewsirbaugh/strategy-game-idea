# Strategy Game Idea

Design docs live at the top level (start with AGENTS.md and EXPLORATIONS.md). The playable
prototype lives in `game/`.

## Running the prototype

Needs Godot 4.7 (`brew install --cask godot`).

- Play: `godot --path game`
- Edit: open `game/project.godot` in the Godot editor, then press F5 to run.
- Preview a character with the toon shader and its animations: `godot --path game res://preview/character_preview.tscn`
- Test the hacking math: `godot --headless --path game -s tests/test_hacking.gd`
- Test the rules (fog fairness, illegal actions, map checks): `godot --headless --path game -s tests/test_rules.gd`

## How `game/` is organized

| Folder | Holds |
|---|---|
| `rules/` | Battle rules as plain data and logic, with no visuals |
| `battle/` | The 3D battle scene that draws the rules' state |
| `ui/` | Title, settings and pause menus |
| `content/` | Tunable data as `.tres` files: the map, units, network nodes |
| `tests/` | The few tests that earn their keep, run headless |
| `autoload/` | The two globals: settings and scene switching |
| `art/` | Models the game loads, and shared shaders such as the toon look |
| `preview/` | Look-dev scenes that aren't part of the game |
