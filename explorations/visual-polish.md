# Visual polish: interface and Network mode

- Status: open; implemented for Bryson's review.
- Next action: play the 2026-10-05 pass (hover card, unit panel, scan badges, network markers,
  nested menus). The broader aesthetic overhaul of the menus is still open.
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

## 2026-10-05 — Playtest feedback: panel, scan, network markers, menus (Bryson)

Bryson, after playing V1:
- The Operator panel (bottom left) should be condensed to essential information, with no
  options in it. It should follow the Operator clicked: as in other tactics games, clicking a
  teammate whose turn it isn't shows their status and resources, with no actions.
- Scan shows every object. It should show only what the team has hacked (fully Breached), drawn
  in the interface's style with the device icons, not white text.
- In the network view, the team and the enemies the team can see should show through the blurred
  map as colored symbols. Enemies out of sight don't show, not even where they were last seen.
- Nest the menus; both the Operator's and the AI's are too long. Grouping agreed: Operator Shoot,
  Interact, Gear, AI; AI Hack, Chips, Devices.
- The hover info in the top left is a favorite: lean into it and make it look better.

Built the same day, one commit each, in this order: hover card, unit panel, scan badges, network
markers, nested menus. Verified with `tools/check.sh` and scripted screenshots on the container's
OpenGL renderer; not played. Claude's choices, open to change:
- The hover card leads with a unit, then a device, then a hiding place; the tile goes in its
  footer. It works on scan badges and on network nodes and AI tokens.
- A waiting teammate's panel shows the AP they'll start their turn with. Clicking anything that
  isn't a teammate returns the panel to the active unit. Pick hints moved to the footer bar.
- Hiding places no longer show under Scan; the hover card still names them.
- A group with one action stays inline. "Act with Bravo first" folds into Switch Operator.

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
