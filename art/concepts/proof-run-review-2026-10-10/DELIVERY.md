# Request 2: proof-run image delivery

Delivered by Astra, 2026-10-11. Bryson approved all three main views and authorized the camera
side view, terminal back view and delivery. The two follow-ups were generated with the built-in
image generation tool and visually inspected by Astra. No separate human approval of the
follow-ups is recorded.

## Inputs for Claude

Use the numbered images in this order, with the approved main view first:

| Asset | Main view | Follow-up | Size from the brief |
|---|---|---|---|
| Bollard light | [01-main.png](../../sources/devices/bollard_light/01-main.png) | None required; Claude already delivered it and is modeling it | About 1 m tall, 18 cm across |
| Camera head | [01-main.png](../../sources/devices/camera_head/01-main.png) | [02-side.png](../../sources/devices/camera_head/02-side.png) | Head and bracket about 60 cm long overall |
| Access terminal | [01-main.png](../../sources/devices/access_terminal/01-main.png) | [02-back.png](../../sources/devices/access_terminal/02-back.png) | About 1.3 m tall, 40 cm wide, 30 cm deep |

The camera source includes only the head and bracket. Claude builds the pole separately, as
specified in [the brief](../../briefs/proof-run.md). The terminal rear has a white casing, a flush
service panel and a small covered data port. Branding and controls stay on its approved front.
For consistent branding, use the [approved interlaced logo](../../reference/openbrain-logo-white.png)
as the authoritative mark when preparing the model; the terminal main view's emblem is only close
to it, as the review README records.

## Inspection and provenance

The final follow-ups show one whole object each, on mid-grey without floor, cast shadow, text or
scene clutter. The camera's first follow-up retained a three-quarter angle; one targeted edit
corrected it to a side profile. Only the final side view is delivered. The terminal rear took one
generation. Both approved main images were copied unchanged into their source folders.

The full follow-up prompts, input references and attempt counts are in
[follow-up-generation-record.json](follow-up-generation-record.json). The original main-view
prompts and references are recorded in [README.md](README.md) and [the brief](../../briefs/proof-run.md#prompts-for-astra).

Image delivery is complete. Camera and terminal model generation, cleanup, asset records and
Godot readability checks belong to Claude's next pipeline step. Astra did not run those steps.
Request 2's remaining coordination step is Bryson's notice to Claude: "Request 2: images delivered."
