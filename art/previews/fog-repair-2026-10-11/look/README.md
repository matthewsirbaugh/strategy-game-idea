# Request 17 look review

Status: Bryson selected B, faint form shading with dark ink edges, 2026-10-11. Captured with Godot 4.7.2,
Metal Forward+, 1280 × 800, current facility yard. No gameplay content changed.

| Pose | A: flat charcoal | B: form and ink | Pre-fog treatment on current map |
|---|---|---|---|
| Initial | [flat-initial.png](flat-initial.png) | [form-initial.png](form-initial.png) | [pre-initial.png](pre-initial.png) |
| Close | [flat-close.png](flat-close.png) | [form-close.png](form-close.png) | [pre-close.png](pre-close.png) |
| Partial car | [flat-car.png](flat-car.png) | [form-car.png](form-car.png) | [pre-car.png](pre-car.png) |

The initial framing matches [the prior box build](../../startup-and-fog-2026-10-11/level-initial.png).
The pre-fog column disables scenery opt-in for this diagnostic; it reproduces that treatment
on current content, rather than claiming to run an older build. Rain timing differs among runs.
The older [vision-glow reference](../../visual-polish/vision-glow.png) is retained for direction;
its older map/pose does not support an exact pixel comparison.

Reproduce with `tools/review_fog_look.gd -- --tone=flat|form|pre --capture=<absolute folder>`.
The tone override is confined to the diagnostic process; it changes no saved shader/material.
