# Briefs: batch 2, the remaining standalone devices

Seven devices the rules use, all in OpenBrain's research park at night (2026-10-11). With these and
the [proof run](proof-run.md), every device kind has a model except the vehicles and the doors,
which Claude builds in Blender.

Six need images from Astra. The night-vision camera doesn't: Claude makes it by having Meshy
re-texture the proof run's camera head, so the two share one shape.

## For Astra

Everything in [the proof run's "What every image needs"](proof-run.md#what-every-image-needs-for-meshy)
applies. Each prompt is the proof run's style block, then the object below, then its framing block.
Only the main view is needed: smart topology, our default, takes one image.

- Where the emblem appears, attach [the logo](../reference/openbrain-logo-white.png) and match it
  exactly. Don't redraw it.
- For design, attach the [forecourt](../reference/openbrain-front-vehicle-forecourt.png) and
  [threshold](../reference/openbrain-front-security-threshold.png) references, and the proof run's
  finished images in `art/sources/devices/`, so the batch shares one design language. Use the
  references for design only: their night light and backgrounds must not carry over.
- Save Bryson's chosen image as `art/sources/devices/<id>/01-main.png`.

## 1. Turret: `turret`

- **In the game:** an autonomous turret. It targets the nearest enemy by itself, or holds fire;
  the AI can take it over.
- **Size:** about 1.4 m tall, 0.7 m across.
- **Must read from the battle camera:** which way the gun faces, and that it's dangerous.

> The object: an autonomous security turret on a corporate research campus. About 1.4 metres
> tall. A sleek white armored head with chamfered edges, more premium consumer product than
> military hardware, holding one short black barrel and a black glass sensor eye above it, with a
> small red status light. The head sits on a black anodized aluminum yoke that turns on a slim
> black round pedestal with a flush base plate, as if bolted to paving. Quietly menacing, clean,
> no visible ammunition belts and no camouflage.

## 2. Prime Data Cache: `prime_data_cache`

- **In the game:** the level's main objective. Breaching it completes the mission.
- **Size:** about 2.2 m tall, 1.2 m wide, 0.8 m deep.
- **Must read from the battle camera:** that it's the most important object on the map.

> The object: OpenBrain's high-security data vault, the most valuable machine on the campus. About
> 2.2 metres tall, 1.2 metres wide and 0.8 metres deep. A tall black server monolith behind a
> front of thick smoked glass, with dense rows of server blades visible inside and a slow red
> glow through the glass. A white chamfered frame wraps the glass, standing on a black plinth. The
> OpenBrain emblem from the attached logo, small and flat black on the white frame above the
> glass. Imposing, pristine and sealed: no handles, no keyboard.

## 3. Phone: `phone`

- **In the game:** a phone. The AI can make it ring with a fake call, which draws a guard.
- **Size:** about 40 cm tall, 25 cm wide, 8 cm deep; Claude mounts it on walls and posts.
- **Must read from the battle camera:** a small panel with a lit speaker grille.

> The object: a wall-mounted campus intercom and call panel, with no wall behind it. About 40 cm
> tall, 25 cm wide and 8 cm deep. A white slab with chamfered edges and a black glass face holding
> a small round camera lens, a circular speaker grille ringed with a soft warm white light, and a
> single call button. A tiny red status light. Shown from three-quarter front so its depth shows.

## 4. Machine: `machine`

- **In the game:** a machine, here a backup generator. The AI can start it, and its noise draws
  guards.
- **Size:** about 2.0 m long, 1.0 m wide, 1.4 m tall.
- **Must read from the battle camera:** an industrial box, distinct from the clean devices.

> The object: a backup diesel generator on a corporate campus, in a white weatherproof enclosure.
> About 2 metres long, 1 metre wide and 1.4 metres tall. A white panelled housing with chamfered
> edges, louvered black vents along both sides, a short black exhaust stack on top, a small
> service door with a recessed handle, and a black steel skid base. Well kept but plainly
> utilitarian, a little older than the campus's other equipment. One small red status light.

## 5. Ad screen: `ad_screen`

- **In the game:** an ad screen. Powered on, it lights a small area; the AI can flash it to draw
  guards who can see it.
- **Size:** about 2.2 m tall, the screen about 1.0 m wide, 12 cm deep.
- **Must read from the battle camera:** a lit rectangle, the brightest light around it.

> The object: a freestanding digital advertising sign on a corporate campus. About 2.2 metres
> tall. A slim portrait screen about 1 metre wide in a thin black aluminum frame, on a single slim
> black post with a flush base plate. The screen glows softly with an abstract, calm OpenBrain
> brand image: a soft white and pale grey gradient with the emblem from the attached logo small
> and centred. No words, no numbers, no people on the screen.

## 6. Power hub: `power_hub`

- **In the game:** a power hub. The AI can switch every device on its circuit at once.
- **Size:** about 1.4 m tall, 0.9 m wide, 0.4 m deep.
- **Must read from the battle camera:** a utility cabinet that powers things around it.

> The object: an electrical distribution cabinet on a corporate campus. About 1.4 metres tall,
> 0.9 metres wide and 0.4 metres deep. A white cabinet with chamfered edges and two flush doors, a
> narrow black glass status panel with a row of small warm white lights and one red light, black
> conduits running from its base down into a black concrete plinth, and a small OpenBrain emblem
> from the attached logo, flat black on one door.

## 7. Night-vision camera: `night_vision_camera`

- **In the game:** as a camera, but sees in the dark.
- **Made by Claude:** Meshy re-textures `devices/camera_head` (about 10 credits) with a dark grey
  housing and a ring of infrared emitters around the lens, so it reads as the camera's
  darker sibling.
