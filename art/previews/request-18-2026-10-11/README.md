# Request 18 native review

Fog transition repair, 2026-10-11. Tone B remains faint form shading with dark ink edges.
Godot 4.7.2, Apple M1 Pro, native Metal Forward+, 1280 × 800.

| Comparison | Previous build | Fading build |
|---|---|---|
| Initial framing, including thin walls and border | [before](before/form-initial.png) | [after](after/form-initial.png) |
| Close framing | [before](before/form-close.png) | [after](after/form-close.png) |
| Car across the boundary | [before](before/form-car.png) | [after](after/form-car.png) |
| Sprint, revealing | [before](before-run/run-02.png) | [after](after-run/run-02.png) |
| Sprint, fading back to silhouette | [before](before-run/run-05.png) | [after](after-run/run-05.png) |

`before-run/` and `after-run/` each contain the settled starting frame and eight native frames
through two consecutive legal three-square sprints, plus [before samples](before-run/samples.json)
and [after samples](after-run/samples.json). The fixture uses a copied Operator with sight 2
and a temporary map, with real rules events and `_play` playback. A cyan prop enters sight for
the first three squares, then leaves it. Raw samples distinguish immediate binary sight from
the fading texture, including after movement's final refresh. Capture writes can affect wall-clock
timing; this is a behavior/visual comparison, not a performance benchmark.

`static/` contains partial cars from two angles, a partial sign, wall ghosting and both Network
transitions. Characters opt out of scenery fog; power/door state remains independent. The gradient
stays inside the brighter cell, avoiding hidden-side texture/glow bleed. Compared settled framing
visually against the prior build; texture, dark tone B and scene appearance remain the same except
the requested soft boundary. Rain and hover position can differ between captures.

See [implementation findings](../../../explorations/fog-fade-and-object-menus.md#findings).
The fog milestone passed all six headless checks and both native sprint/full-level probes with
clean rendering logs. Menu captures and final validation follow in the second milestone.
Bryson's playtest remains open.
