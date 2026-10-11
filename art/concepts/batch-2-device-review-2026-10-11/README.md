# Batch 2 device images for Bryson's review

Request 5, activated by Bryson: "Generate them please, per the instructions." Six main-view
candidates generated with the built-in image generation tool on 2026-10-11, from
[Claude's briefs](../../briefs/batch-2-devices.md). These await Bryson's design review and selection.

| # | Device | Main-view candidate | Intended source after selection |
|---|---|---|---|
| 1 | Turret | [01-turret-main.png](01-turret-main.png) | `art/sources/devices/turret/01-main.png` |
| 2 | Prime Data Cache | [02-prime-data-cache-main.png](02-prime-data-cache-main.png) | `art/sources/devices/prime_data_cache/01-main.png` |
| 3 | Phone / campus intercom | [03-phone-main.png](03-phone-main.png) | `art/sources/devices/phone/01-main.png` |
| 4 | Machine / backup generator | [04-machine-main.png](04-machine-main.png) | `art/sources/devices/machine/01-main.png` |
| 5 | Ad screen | [05-ad-screen-main.png](05-ad-screen-main.png) | `art/sources/devices/ad_screen/01-main.png` |
| 6 | Power hub | [06-power-hub-main.png](06-power-hub-main.png) | `art/sources/devices/power_hub/01-main.png` |

No new image for the night-vision camera: Claude has already made it by retexturing the camera
head. Only one main view per device is required by the brief.

## Generation and inspection

Each prompt uses the proof-run style block, the device description and the framing block.
Design references were attached: the campus forecourt and security threshold, plus approved
proof-run props. For the three branded devices, the tool's five-reference limit required omitting
the bollard so the authoritative logo could be included with the camera, terminal and campus pair.
The complete prompts and actual reference lists are in [generation-record.json](generation-record.json).

Astra visually inspected all six final candidates: one whole object each, including its base
where applicable, on grey without floor, cast shadow, text or scene clutter. The turret has a
single short barrel and sensor eye above it; the cache has server blades visible behind smoked
glass; the intercom has its lens, illuminated speaker grille and one button; the generator has
vents, exhaust, service door and skid; the ad screen has its complete post and base; the power hub
has two doors, status lights and conduits into its plinth. All six saved files are valid PNGs.

The first ad screen had a white outer casing; a targeted edit changed it to the brief's thin black
frame. The cache, ad screen and power hub each had one emblem correction using the
[authoritative logo](../../reference/openbrain-logo-white.png). The generated emblems still
approximate some stroke and crossing details; exact logo reproduction is not confirmed. These
images are useful for reviewing the object designs, but the original PNG should be used for exact
branding during model preparation, subject to Bryson's acceptance of that approach.

The turret pedestal and ad-screen support are included as requested. Their reconstruction quality
is untested. No Meshy jobs, model cleanup, Godot checks or playtests were performed for this batch.

## Next

Bryson chooses or revises the six designs. Save only his selections to the source paths above,
then update Request 5's delivery status and handoff for Claude. Image generation is complete;
selection and final source delivery remain pending.
