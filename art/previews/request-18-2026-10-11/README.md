# Request 18 native review

Fog transition and object-menu repair, 2026-10-11. Tone B remains faint form shading with dark ink edges.
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
Both milestones passed all six headless checks. Native sprint/full-level and object-menu probes
passed with clean rendering logs. Bryson's playtest remains open.

| Object menu | Native capture |
|---|---|
| Two doors and a guard, each named at top level | [objects](menus/objects.png) |
| Door submenu: short actions and object heading | [Door D1](menus/door-d1.png) |
| Guard submenu | [Guard K](menus/guard.png) |
| Put down at top level while carrying | [carrying](menus/carrying.png) |
| A single door action stays inline with its full name | [one action](menus/one-action.png) |
| Direct door menu also uses short names | [direct door](menus/direct-door.png) |

`tools/verify_object_menus.gd` drives mouse press/release and keyboard events through Godot's
viewport input dispatch in a temporary map. It executes Peek, Tie up, Pick up, Put down, Open
and Close; checks the correct target ids; and checks right-click, Escape and Network return.
Its guard starts stunned, so it is a body under the rules. This is scripted native interaction,
not a human mission playthrough. Costs remain rule-owned: Lock is 1 AP, as RULES.md specifies.
