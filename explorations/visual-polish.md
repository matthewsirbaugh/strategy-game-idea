# Visual polish: interface and Network mode

- Status: open; implemented for Bryson's review.
- Next action: play this pass, especially the Network view and its return to the physical map.
- Inherits the [house style](art-pipeline.md#house-style) and the facility's approved clay-orange
  and cream direction in [environment-art.md](environment-art.md).

## Request — 2026-09-30

Bryson asked for a broad visual improvement pass, including the map, assets, interface, and
Network mode, to move the presentation toward a polished game. This pass executes that request;
its appearance is still awaiting Bryson's review.

## Implemented

- A title screen built around the approved exterior establishing image, with a matching
  deployment menu. The game keeps its existing provisional title.
- A shared dark interface theme using the existing Barlow fonts, cream text, and clay accents.
  The title, settings, pause, battle, action, and result screens use it.
- A mission header and compact turn order, an Operator card with health and context displays,
  an Actions button, and a contained activity feed. Actions switches to the view appropriate
  to the current phase before opening the menu.
- Network mode: original vector device icons, legible device IDs and status, breach progress
  arcs, animated connection markers, reachable routes, and separate Operator initials.
  Scene haze and tone mapping do not wash out the diagram. The original environment returns
  when leaving the view.
- Network framing fits the device graph between the interface panels and faces north on entry.
  The previous physical camera position, rotation, and zoom return on exit. Shared-node tokens
  retain separate picking positions.
- A wider opening battle composition, thinner movement/access markings, and service/loading
  stencils in the yard. Walkable tiles, cover, patrols, and mission rules are unchanged.
- Lower rim-light intensity on models and a larger self-occlusion tolerance on human silhouettes,
  plus character labels matching the interface font.

## Source and art provenance

- `game/art/ui/facility-title.png` is an unchanged copy of
  `art/reference/environment-facility/0A-exterior-establishing.png`.
- The five SVG device symbols in `game/art/ui/` were authored for this pass.
- Fonts and their license files already live in `game/art/fonts/`.
- No new downloaded asset packs, paid services, or generated character models were used.

## Where it lives

| Area | Source |
|---|---|
| Shared controls and type | `game/ui/theme.tres` |
| Illustrated title | `game/ui/title_menu.tscn`, `game/ui/menu_backdrop.gdshader` |
| Battle interface | `game/battle/hud.tscn`, `game/battle/hud.gd` |
| Network presentation | `game/battle/network_view.gd`, `network_backdrop.gdshader` |
| View framing | `game/battle/camera_rig.gd` |
| Yard markings | `game/battle/signs.gd`, `game/content/maps/facility_exterior.tres` |
| Visual review captures | `art/previews/visual-polish/` |

## Verification

- `bash tools/check.sh`: import/registration, battle rules, and hacking/context math passed.
- Rendered with Godot 4.7.2 on the Mac's Metal renderer. Inspected the title, settings, battle,
  movement overlays, action menu, connected Network view, reachable routes, breached device,
  pause, and result screens.
- A temporary native interaction script exercised deployment, legal movement into access range,
  AI connection, network travel, hacking a door, shared-node picking for all three Operators,
  camera/environment restoration, pause/resume, and menu clamping at 1280 × 720.
- These are scripted gameplay and visual checks. A full human mission playtest and a controlled
  performance comparison have not been done. This is a presentation pass, not final-art approval.
