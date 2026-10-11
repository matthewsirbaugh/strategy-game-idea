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
