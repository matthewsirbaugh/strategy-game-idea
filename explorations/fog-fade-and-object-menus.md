# Playtest fixes: fog that fades, menus named after objects

- Status: approved by Bryson 2026-10-11, handed to Astra as [Request 18](claude-and-astra.md#requests).
- Author: Claude. Follows Bryson's playtest of [Request 17](fog-vision-ticks-fix.md#request-17-implementation-findings).

## What Bryson asked for

1. The fog updates too fast. Running, it flashes between lit and unlit at the speed of the run.
   It should be smooth.
2. Standing next to a door, the top-level menu should say what you can interact with, not
   "Interact" with the door inside it. Submenus are fine.

## 1. Fog fades instead of switching

Cause, found by reading the code (not reproduced in a running build): a character crosses a
square in 0.12 s (`UnitView.STEP_SECONDS`). On every tick, the silhouette ↔ real-model swap is
instant. Every newly seen tile also plays the `GridView.FLICKER` "fluorescent tube" sequence,
which lasts 0.3 s, so tiles are still strobing when the next tick lands.

Approved fix:

| | Change |
|---|---|
| A | Remove the reveal flicker. A newly seen tile fades up like any other brightness change |
| B | Fade the visibility instead of switching it: about 0.2 s in and 0.4 s out, as tunable constants. The rules stay per-square and binary. Only the drawing blends between silhouette and real model |
| C | Soften the seen/unseen edge spatially, so the boundary is a short gradient instead of a hard tile edge |

The fluorescent flicker can come back later where it means something, such as a light switched
on by a hack. That is out of scope here.

Pitfalls:

- Keep `_visible_cells` and `cell_visible()` binary. Only the texture the shaders read fades.
  Animate it per cell, the way brightness already is, with no per-frame perception queries.
- Every shader that branches on `fog_visible()` needs a blend instead: toon, wall, fog surface, sign
  and ink outline. That includes the `light()` gates, or lamp light pops while the colour fades.
- Lettering, screens and glows discard when hidden. Cut them at a threshold, such as half faded,
  rather than fading them, which keeps them cheap; they'll pop, but they're small.
- A fade out longer than a step is what stops a tile that blinks out for one square from
  flickering. Don't let the final `_refresh()` reconcile snap fades to their end values.
- C: filtering a one-texel-per-tile texture linearly blurs across a whole tile. Sharpen it so the
  gradient is a fraction of a tile. Check that partial cars, thin walls and the map's border
  ring don't leak hidden detail at the soft edge.
- Units still appear and vanish instantly. Seeing an enemy is information, not ambience.
- Look check: same camera framings as the Step 1 captures, with tone B unchanged. The only
  intended change is the motion. Flag anything else.

## 2. Menus named after the object

Group interactions by the object they act on, labelled with its name:

| Next to | Top level | Submenu |
|---|---|---|
| One door | Door D1 › | Open · Lock (2 AP) · Peek through |
| Two doors | Door D1 › and Door D2 › | one each |
| A downed guard | [guard's name] › | Tie up · Pick up |
| One door, one action possible | Open door D1 | none: a group of one stays inline, as today |

"Put down" stays its own top-level line. Shoot, Gear and the AI menu don't change.

Pitfalls:

- `BattleMenus.nest` uses `group` as both the key and the label. Two doors need distinct keys,
  so key by object id and carry the label separately.
- An action needs two names: short inside its submenu ("Open"), full when it sits inline
  ("Open door D1"). The direct door menu, `door_actions`, is already one door's menu, so it
  takes the short names too.
- Keep the action ids (`door:…`, `peek:…`, `tie:…`, `pickup:…`). The controller and the
  battle-flow test act on them.
- Peek goes in its door's group; the peek id is the door id.

## Done when

Both fixes are committed separately, the fade is captured mid-run in native frames for Bryson,
`bash tools/check.sh` passes, and the game is restarted for Bryson to play. Record findings
below.

## Findings

### 2026-10-11 — Astra: fog implementation

Removed the fluorescent reveal sequence. GridView still accepts binary vision at every square;
only its visibility texture fades, with `FOG_IN_SECONDS = 0.2` and `FOG_OUT_SECONDS = 0.4`.
Brightness moves steadily toward its target over the existing 0.35 s scale. Retargeting starts
from the current values, including when the final refresh submits the same vision again. Only
changing cells process, with no perception queries between ticks.

Toon colour and its light contributions, walls, generic surfaces and ink blend between the
original tone B and actual detail. Screens, lettering and glow-only surfaces use a half-visible
cutoff. Units still show/hide immediately. The edge gradient occupies 0.2 of a tile (0.3 m),
inside the brighter cell. The first linear-filter attempt exposed wall texture on the hidden
side; the delivered sampling instead softens toward darker neighbours without increasing a
hidden cell's value. Tone B's constants and the ground material stay unchanged.

[Native capture index](../art/previews/request-18-2026-10-11/README.md): matched initial, close
and car framings, plus actual per-square playback of two legal three-square sprints. The native
probe checks reveal/loss during playback, continued fading after the final refresh, and settled
processing. Its copied Operator has sight 2, and the temporary map has no guards; no shipped
rules, stats or maps changed. This is scripted native verification, not Bryson's playtest.

All six `bash tools/check.sh` checks passed. Native sprint and full-level checks passed with
clean rendering logs, including partial cars/signs, power state, character opt-out, wall ghosting
and both Network transitions. The restricted import's editor-settings write failed; the full
check succeeded with the required filesystem access. Menu implementation follows in the second
milestone.
