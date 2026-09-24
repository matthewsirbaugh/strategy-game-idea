# Strategy Game Idea

Design docs live at the top level (start with AGENTS.md and EXPLORATIONS.md). The playable
prototype lives in `game/`.

## Running the prototype

Needs Godot 4.7 (`brew install --cask godot`).

- Play: `godot --path game`
- Edit: open `game/project.godot` in the Godot editor, then press F5 to run.

## How `game/` is organized

| Folder | Holds |
|---|---|
| `rules/` | Battle rules as plain data and logic, with no visuals |
| `battle/` | The 3D battle scene that draws the rules' state |
| `ui/` | Title, settings and pause menus |
| `content/` | Tunable data (maps, later units and abilities) as `.tres` files |
| `autoload/` | The two globals: settings and scene switching |
