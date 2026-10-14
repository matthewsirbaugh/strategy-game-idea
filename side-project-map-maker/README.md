# Map maker side project

A simple map maker for placing models and designing levels for Strategy Game Idea,
built by Astra (Codex) for Bryson on 2026-10-04. It started as a side project kept apart from
the main game while other work was under way. Since 2026-10-13 it's part of the project: a
version of it is how Bryson will lay out levels when the game's levels are made (Bryson).

## Bryson's instructions (2026-10-04)

- Create a simple tool for placing the game's models and designing levels.
- The tool does not need to implement the game itself.

## What's in git

The code, layouts, exports and verification are committed. The copied models in `assets/`
(about 217 MB, from the retired look) aren't, so a fresh clone has only `assets/SOURCES.md`;
the working copy on Bryson's Mac still has them. The game's current models live in
`game/assets/`.

## Agreed scope

Bryson chose a dedicated, simple map maker with prefabricated pieces. Walls and
floors use a grid; decorative props support free placement and optional snapping.
The purpose is to see and arrange a preferred level design, then give that visual
intent to an AI as a basis for implementation and iteration. Game-format export
and gameplay simulation are outside this first version.

## Run

Double-click `Launch Map Workshop.command` in this folder. It uses the existing
Godot installation and restores the most recent draft, or opens a blank workshop
if there is no recovery file. The copied models have already
been imported locally; this launcher does not open the main game's editor or run
its import process.

Alternatively, from the main project root:

```sh
godot --path side-project-map-maker
```

If this folder is copied elsewhere without its `.godot` cache, its own models
need a fresh import: `godot --headless --path side-project-map-maker --import`.
Godot may create its normal engine application-data directory; all workshop
layouts, handoffs, copied assets and project imports are stored in this folder.

## Use

1. Choose a piece in the left palette, then click in the workspace to place it.
   Search or filter by Ground, Structures, Props or Prefabs. Ground pieces paint
   while you drag; brush sizes are 1, 3, 5 or 9 tiles across. Painting replaces
   the ground already in a cell. Each stroke is one undoable change.
2. Press V or click Select. Control-click or Command-click objects to add or
   remove them from the selection, then drag them together. In the Scene tab,
   modifier-click selects individual rows and Shift-click selects a range.
3. Use the Details tab for exact position, elevation, rotation and scale.
   In Place mode, elevation, rotation and scale apply to the next placements.
   Multiple objects rotate and scale around their shared centre; position edits
   translate the whole selection. Values use the first selected object.
4. In Scene, choose + Folder to organise the selection. Folders can nest, collapse,
   be renamed, and contain newly placed objects. Move to… changes a selection's
   folder. Clicking a folder selects its contents. Ungroup folder removes that
   folder while preserving its objects and child folders. Folder changes undo.
5. Name the layout and add notes in the Notes tab explaining what the AI should
   preserve or explore. Workspace dimensions also live there.
6. Save stores an editable `.json` file in `layouts/`. Open reopens it,
   including its notes and camera view. Replacing a saved file asks first.
7. Handoff creates a new folder under `exports/`, containing `layout.json`,
   `HANDOFF.md`, `overview.png` and `top-down.png`. Pass that folder to the AI.

The interface scales with window size, including full screen. The Text control
adds Standard, Large and Largest font options and remembers your preference.
Scene, Details and Notes keep the routine controls separate. Help lists shortcuts.

| Action | Control |
|---|---|
| Select / move | V |
| Place the chosen piece | B |
| Paint ground | Choose a ground tile, then drag |
| Erase ground while keeping walls and props | X, then drag |
| Add / remove objects from selection | Control-click or Command-click |
| Select a range in the Scene tree | Shift-click |
| Select all objects | Command-A / Control-A in the workspace |
| Rotate 90 degrees | R |
| Return to Select mode | Escape |
| Duplicate selection | Button, or Command-D / Control-D |
| Delete selection | Button, Delete or Backspace |
| Undo / redo | Buttons, Command-Z / Command-Shift-Z; Control equivalents work |
| Save | Button, Command-S / Control-S |
| Orbit camera | Right drag, or Option-left drag |
| Pan camera | Middle drag, Shift-left drag, or trackpad pan |
| Zoom | Wheel or pinch |
| Frame the layout | F |
| Plan view / angled view | Top view / Perspective buttons |

The grid uses the game's current 1.5-metre spacing. You can resize the visible
workspace from 4 to 128 tiles in each dimension; this changes the ground beneath
the design and does not remove objects. Pieces may extend outside the workspace.
Each room, yard or crate-cluster prefab is selected and moved as a group.

Open `example-courtyard.json` for an optional tool demonstration. It is not a
Bryson-approved game level. Use New to start your own layout.

The workshop writes its latest draft to `recovery.json` after editing and before
closing. This is a recovery copy; Save keeps a named layout in `layouts/`.
`workshop-settings.json` holds the text-size preference. Automated checks do not
replace either file. The original first-version workshop has no recovery feature;
save its layout before closing it to switch to this version.

## Handoff format

The saved layout records piece IDs, positions in metres, Y-axis rotation in
degrees, uniform scale, folder hierarchy, workspace dimensions, notes and the camera. It includes
definitions of the used pieces, including prefab component sizes and placements
and source-model references. X and Z are the ground plane; Y is elevation.

The workshop is a visual authoring tool. Models use plain preview lighting, and
their sizes approximate the game's current display sizes. It does not enforce
movement, collision legality, line of sight, networks, combat or objectives.
The receiving AI must interpret the intent against the game's current rules and
map format, rather than treating this layout as a playable game map.

## Validation

Godot 4.7.2 imported the copied models and ran the native window on the Apple M1
Pro. Scripted interaction checks exercised every catalog piece, click placement,
grid and free positioning, ray selection, dragging, elevation, rotation, scale,
duplicate/delete, undo/redo, save/load, malformed-layout rejection, camera orbit,
top view and screenshot/brief export. The upgrade also exercised fast ground
strokes, repainting, brush sizes, erasing, single-stroke undo, modifier selection
in the scene and tree, range selection, shared transforms, folder creation,
renaming, nesting, ungrouping, persistence and invalid hierarchy rejection.
The native preview was visually inspected at 1440 × 900 and 3456 × 2160.
This was automated verification; Bryson's usability playtest remains to be done.

Verification code and results live in `verification/`.
