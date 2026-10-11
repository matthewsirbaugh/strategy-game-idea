# Briefs: the proof run

Three props for the first test of how close Meshy gets us (2026-10-10). Each one is a device the
rules already use, standing in OpenBrain's research park at night. Design them with Astra, then hand
Claude the final images.

## What every image needs, for Meshy

Meshy rebuilds exactly what it sees, so these matter more than the art style:

- One object, whole, centered, filling most of the frame. Nothing else: no people, no ground
  clutter, no second object.
- A plain mid-grey background, the same in every view.
- Soft, even studio light. No cast shadows, no strong reflections, no dramatic night lighting:
  lighting is added in the game.
- Lights shown switched on but softly, so their shape is still clear.
- Little perspective distortion, like a product photo from a few metres back with a long lens.
- No text anywhere. OpenBrain's emblem only where the real object would carry it, and small.
- The same object in every view: generate the main view first, then ask Astra for the other views
  of that exact object.

Views: a three-quarter front view from slightly above is the main one. Add front, side and back
views where the brief asks; Meshy takes up to four images of one object.

The shared style, to open every prompt: photorealistic product render of a single object for a
game set in a California city around 2040, belonging to OpenBrain, a powerful AI company. Clean,
modern, minimal design: matte white composite panels, black anodized aluminum, brushed steel,
chamfered edges, warm white LED accents, red used sparingly. New and well kept.

## 1. Bollard light

- **In the world:** the low lights lining the research park's paths and bridges.
- **In the game:** a light. It lights the tiles around it, and the AI can switch it off, which
  draws a guard to look.
- **Size:** about 1 m tall, about 18 cm across.
- **Look:** like the black bollards in the references
  ([forecourt](../reference/openbrain-front-vehicle-forecourt.png),
  [river crossing](../reference/openbrain-research-park-river-crossing.png)): a square or round
  post in black anodized aluminum, a warm white light band near the top, chamfered edges. A
  tiny red status dot is fine.
- **Must read from the battle camera** (looking down at about 50 degrees, a person is about 55
  pixels tall): the lit top has to show as a light source.
- **Images:** the three-quarter view is enough; it's symmetric.

## 2. Camera head

- **In the world:** the security cameras on black poles and walls across the campus
  ([forecourt](../reference/openbrain-front-vehicle-forecourt.png),
  [threshold](../reference/openbrain-front-security-threshold.png)).
- **In the game:** a camera. Its cone shows where it watches, and the AI can take it over.
- **Size:** the head and its bracket, about 60 cm long. **Only the head and bracket:** Claude
  builds the pole, because AI 3D tools turn long thin poles into lumpy ones.
- **Look:** a white housing with a black glass face, a small sensor beside it (a scanner or
  lidar puck), a black bracket that would bolt to a pole or wall, one small red recording light.
- **Must read from the battle camera:** which way it points. Make the housing clearly longer
  front to back than it is wide.
- **Images:** the three-quarter view, plus a side view that shows the length and the bracket.

## 3. Access terminal

- **In the world:** a service terminal for the campus network, the kind of pillar in the
  references with a black glass face and a red light strip
  ([forecourt](../reference/openbrain-front-vehicle-forecourt.png),
  [threshold](../reference/openbrain-front-security-threshold.png)).
- **In the game:** an access point. An Operator stands within two tiles and their AI enters the
  network here. It's the most-used device in the game.
- **Size:** about 1.3 m tall, about 40 cm wide, about 30 cm deep.
- **Look:** a white monolith with chamfered edges; a black glass front with a small screen and a
  face or palm scanner; a thin vertical red light strip on one edge; a small OpenBrain emblem; a
  discreet service panel or port, since this is where the network is reached.
- **Must read from the battle camera:** that it's a terminal, from its glowing front and the red
  strip.
- **Images:** the three-quarter front view, plus a back view.

## Prompts for Astra

Paste-ready, one per prop (2026-10-11). Send the main prompt first. Once Bryson approves the image,
send the follow-up in the same chat, so the design doesn't drift between views. Attach the two
references each brief links, for design only: their night light and backgrounds must not carry
over. Reject any image with a cast shadow, a floor, text, a second object or a cropped edge,
because Meshy builds whatever it sees.

The terminal carries OpenBrain's emblem, the one Astra designed for the creekside campus: attach
[04-creekside-campus-v2.png](../concepts/valley-composition-study-2026-10-08/04-creekside-campus-v2.png)
and match the emblem on it (Bryson, 2026-10-11).

Save Bryson's chosen images, as numbered PNGs with the main view first, to
`art/sources/devices/<id>/` (`bollard_light`, `camera_head`, `access_terminal`).

Every prompt opens with the style block:

> Photorealistic product render of a single object for a game set in a California city around
> 2040, belonging to OpenBrain, a powerful AI company. Clean, modern, minimal design: matte white
> composite panels, black anodized aluminum, brushed steel, chamfered edges, warm white LED
> accents, red used sparingly. New and well kept.

And ends with the framing block:

> Framing: one object, whole and centered, filling most of the frame, three-quarter front view
> from slightly above, long-lens product-photo perspective with little distortion. Plain flat
> mid-grey background. Soft, even studio lighting, no cast shadows, no strong reflections, no
> ground, no people, no other objects, no text.

### 1. Bollard light: main view only

> The object: a landscape bollard light that lines the paths and footbridges of a corporate
> research park. About 1 metre tall and 18 cm across. A square post in black anodized aluminum
> with chamfered vertical edges, a flat or slightly bevelled cap, and a band of warm white light
> wrapping all four sides just below the cap, behind a frosted diffuser. The light is on but soft,
> so the band's shape stays crisp. One tiny red status dot low on the front face. A flush square
> base plate, as if bolted to paving.

### 2. Camera head: main view, then a side view

> The object: an outdoor security camera head with its mounting bracket, with no pole and no wall.
> About 60 cm long overall. A white housing with chamfered edges, clearly longer front to back
> than it is wide, so it obviously points one way. A black glass face at the front. A small black
> sensor puck (a lidar or scanner) on top of or beside the housing. One small red recording light
> near the face. A black anodized aluminum bracket at the back with a swivel joint and a flat
> mounting plate, as if it would bolt to a pole.

Follow-up:

> Now show this exact same camera head and bracket from a straight side view (profile, at eye
> level), so its full length front to back and the bracket's shape are clear. Same object, same
> materials, same plain mid-grey background and soft even studio lighting. No other changes.

### 3. Access terminal: main view, then a back view

> The object: a freestanding network access terminal on a corporate research campus. About 1.3
> metres tall, 40 cm wide and 30 cm deep. A white monolith pillar with chamfered edges. The front
> is a panel of black glass holding a small, softly glowing screen at chest height and a palm
> scanner below it. A thin vertical red light strip runs along one front edge. Above the screen,
> a small OpenBrain emblem, flat black on the white panel: the same interlocking rounded-loop
> rosette with an open center as in the attached campus image, calm and compact, no lettering. A
> low plinth in black aluminum.

Follow-up:

> Now show this exact same terminal from directly behind, at eye level. The back is white, with a
> discreet flush service panel and a small covered data port, as if technicians open it to reach
> the network. Same object, same materials, same plain mid-grey background and soft even studio
> lighting. No other changes.
