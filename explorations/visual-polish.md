# Visual polish: interface and Network mode

- Status: open; implemented for Bryson's review.
- Next action: play the 2026-10-05 passes: hover card, unit panel, scan badges, network markers,
  the menus' overhaul, the two halves of a turn, AI pins and the network's label layout.
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

## 2026-10-05 — AI mode didn't start (Bryson's report)

Bryson: clicking into AI mode near an access point didn't start it. When the menus were nested,
deploying became an item inside the AI group, and it left the view physical with the Operator's
menu open; "AI actions" with the AI still in the backpack had no way to deploy at all. While
fixing it, Claude found the AI's menu also carried into the next Operator's turn.

Fixed the same day, with `tests/test_battle_flow.gd` to keep it fixed. Claude's choices, open to
change:
- Deploying, from either menu, switches to the network view with the AI's menu open.
- The AI's own menu lists the access points in reach first, while the AI is in the backpack.
- In the network view, a backpacked AI's access points in reach are ringed, and a click on one
  sends it in. Acting beats looking: a click there deploys even when a teammate's AI token sits on
  the access point, instead of showing the teammate.
- Each turn starts on the physical view and the Operator's own menu. Clicking the Operator opens
  the Operator's menu; clicking the AI's token opens the AI's.
- A menu group keeps its place whether it folds or not.

Verified headless through every menu path, and with screenshots of a native run; not played.
Noticed, not changed: in the network view, the labels of D, A, P and E overlap, since the four
nodes sit on neighboring tiles.

## 2026-10-05 — The AI phase, and the menus' overhaul (Bryson)

Bryson, after playing the fix above:
- Clicking AI phase still didn't switch to the network view. (It only switched after deploying;
  with the AI in the backpack, the AI's menu opened in the physical view.)
- The AI's marker needs to be something other than a letter, maybe a different kind of marker:
  it looks like a node and covers the node it's on, so occupied and empty nodes are hard to tell
  apart. Claude to suggest solutions.
- A cost written straight after the action's name, in the same font, doesn't look good. Bring the
  same style and attention to detail to every part of the design, the menus most of all, since the
  player uses them most.

Built the same day. Claude's choices, open to change:
- The AI phase is the network view. "AI phase" in the Operator's menu, and N, always switch to it
  and open the AI's menu there; "Operator phase" switches back. Deploying and shared compute moved
  into the AI's menu, which says why the AI can't deploy yet when it can't. The view toggle reads
  AI PHASE and OPERATOR.
- Menu rows: the name on the left; costs as small tags on the right, the AP cost last; a chevron
  for a submenu. Tag colors follow the resource everywhere: the Operator's AP clay, the AI's AP
  cyan, context blue, gains mint, free and info grey. The header names whose menu it is and what
  they have to spend. Back, Operator phase and End turn sit under a rule with their keys (Esc, N,
  Space). The highlight follows the mouse, so only one row is ever lit, and the line under the menu
  says what the highlighted row does, why it's greyed out, or what sound a verb will make. Right-
  click or Esc in a submenu goes back a level.
- Operator menus are edged in clay and the AI's in cyan, the colors of the AP they spend.
- The unit panel: AP, AI AP, armor, shot, AI and gear as a grid of small names over their values.
  Chips are tags in their load state's color; clicking one opens a card in the hover card's style.

AI marker options, shown to Bryson as mockups: a halo ring around the occupied node, in each AI's
color with a small sigil (Claude's recommendation); pins above the node; or corner badges. Bryson
chose pins (below).

Verified with the test suites and screenshots of a native run; not played.

## 2026-10-05 — The two halves of a turn, AI pins, labels (Bryson)

Bryson, after playing the menus' overhaul:
- Ending the AI phase while the Operator still has AP should say "End AI Phase" and go back to the
  Operator to finish the turn. The other way too: ending the Operator's turn while the AI still has
  AP says "End Operator Phase" and jumps to the AI.
- Pins for the AI marker, but the pins have to be well designed. The tag colors read well.
- Not "AI phase" in the interface: just "AI", except when ending either half of the turn.
- Fix the overlapping labels in the network view.

Built the same day. Claude's choices, open to change:
- The end row hands over only when the other half has AP and something to spend it on. A half
  the player has ended doesn't take the turn back, so ending both ends the turn. Space does what
  the end row says. The rows read "End AI phase" and "End Operator phase", in the menus' sentence
  case.
- Menus read "AI" and "Operator"; the view button reads AI and OPERATOR; headers name the unit or
  its AI.
- With a menu open, a click on something the player can act on, such as a ringed access point,
  closes the menu and acts. A click on the menu's own unit just closes it.
- Pins: a teardrop in the Operator's color standing with its tip on the node's top edge, a dark
  body, a colored rim and the AI's four-pointed glyph, with a flat shadow for depth. AIs that
  share a node stand side by side. The active AI's pin bobs gently. One glyph for every AI for
  now; each AI could get its own once their personalities are drawn.
- Labels: each sits under its node if there's room, else beside it, then at a corner, else
  further down, never over another label, a node or a unit's marker.

Verified with the test suites and screenshots of a native run; not played.

## 2026-10-05 — AP remaining, and moves that stop short (Bryson)

Bryson read "AP 8/8" as eight used, not eight left, and asked for "AP Remaining" on both the unit
panel and the menu headers. Built: "AP REMAINING" and "AI AP REMAINING" on the panel, "5 AP
REMAINING" tags in the menu headers. Claude's choice: a waiting teammate's panel reads "AP NEXT
TURN", since their AP refills when their turn starts.

A move that reveals a guard stops there (rule 27) and only charges the tiles walked; the stop was
easy to miss. Bryson agreed to a callout: over the Operator, "STOPPED · SPOTTED GUARD 1" and the
AP kept, up and to the left so the menu doesn't cover it; the guard's tile flashes, the log line
adds the AP kept, and the move hint warns that spotting an enemy stops you there.

## 2026-10-06 — Device orders and the pin in the physical view (Bryson)

Bryson asked:
- A hack that Breaches a device goes straight to its orders, with a way back out.
- Devices lists the Breached devices; each opens that device's orders.
- The AI's pin always stands over the node the AI is on, not only after clicking.

Built the same day. Claude's choices, open to change:
- The orders menu is headed with the device's name, so its rows are just the orders ("Unlock",
  "Power off"). A Breached turret's hold/target is one of its orders, and clicking its node opens
  them like any other device.
- Back from orders returns to the AI's menu, or to Devices when they were opened from there.
- With only one device under control, it sits in the AI's menu as "Door D ›", as every group of
  one does.
- The pin bug read as the physical view: in the network view the pin already showed in every path
  tried. The physical view now stands the same pin over the AI's device, and it bobs on the AI's
  own turn.

Verified with the test suites and screenshots of a native run; not played.

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
| Hover card content | `game/battle/hover_info.gd` |
| Menu groups and folding | `game/battle/battle_menus.gd` (`nest`) |
| The way into the AI: deploying, rings, clicks | `game/battle/battle.gd` (`_node_click`, `_ring_nodes`) |
| The halves of a turn and their end rows | `game/battle/battle.gd` (`_hands_over`), `game/battle/battle_menus.gd` (`half_open`) |
| AI pins and the label layout | `game/battle/network_view.gd` (`make_pin`, `pose_pin`, `_place_labels`), `game/art/ui/ai_pin_*.svg` |
| Device orders | `game/battle/battle_menus.gd` (`controlled_devices`, `device_actions`), `game/battle/battle.gd` (`_open_breached`) |
| Scan badges | `game/battle/battle.gd` (`_refresh_scan`) |
| Network presentation, unit markers | `game/battle/network_view.gd`, `network_backdrop.gdshader` |
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
