# Briefs: batch 3, the vehicles and the research park's fixtures

The last two device kinds, the vehicles, and the fixtures and props that fill the research park
in the references (2026-10-11). The doors aren't here: Claude builds them in Blender, sized to the
grid.

## For Astra

Everything in [the proof run's "What every image needs"](proof-run.md#what-every-image-needs-for-meshy)
applies. Each prompt is the proof run's style block, then the object below, then its framing block.

- Attach the [forecourt](../reference/openbrain-front-vehicle-forecourt.png),
  [threshold](../reference/openbrain-front-security-threshold.png) and
  [river crossing](../reference/openbrain-research-park-river-crossing.png) references for design
  only, and the finished images in `art/sources/devices/`, so every batch shares one design
  language.
- Where the emblem appears, attach [the logo](../reference/openbrain-logo-white.png) and match it
  exactly.
- Main view only, except the two vehicles: they also need a straight side view of the same
  vehicle, sent as a follow-up in the same chat, because Meshy may need both for a shape this
  complex.
- Long thin parts (poles, barrier arms) are left out on purpose: AI 3D tools make them lumpy, so
  Claude builds them. Each brief says what to leave out.
- Save Bryson's chosen images as `art/sources/<category>/<id>/01-main.png` (and `02-side.png`).

## Vehicles (devices)

### 1. Fleet car: `devices/fleet_car`

- **In the game:** a car: cover, and a device the AI can take over.
- **Size:** about 4.6 m long, 1.9 m wide, 1.5 m tall.

> The object: a sleek autonomous electric car from OpenBrain's campus fleet, around 2040. About
> 4.6 metres long. Smooth, low and minimal, close to today's electric cars but cleaner: white
> body, black glass roof and windows wrapping the cabin, a thin warm white light bar across the
> front, a thin red light bar across the back, a small black lidar dome on the roof, flush door
> handles, black aerodynamic wheels. The OpenBrain emblem from the attached logo, small, on the
> front door. No driver visible, no number plate, no text.

Follow-up: the same car from a straight side view at its own height.

### 2. Service van: `devices/service_van`

- **In the game:** the rules' truck: larger cover, and a device the AI can take over.
- **Size:** about 5.5 m long, 2.1 m wide, 2.4 m tall.

> The object: an autonomous electric service van from OpenBrain's campus fleet, around 2040, like
> the van in the attached forecourt reference. About 5.5 metres long and 2.4 metres tall. A boxy
> white body with a short sloped black glass front, no driver's cab windows on the sides, a
> sliding side door, a thin warm white light bar at the front and a red one at the back, roof
> sensors, black wheels. The OpenBrain emblem from the attached logo, small, on the side. No
> driver visible, no number plate, no text.

Follow-up: the same van from a straight side view at its own height.

## Fixtures

### 3. Pole light head: `props/pole_light_head`

- **In the world:** the tall lights along the paths and the forecourt. Claude builds the pole.
- **Size:** the head about 60 cm long.

> The object: the head of a modern campus street light, with no pole. About 60 cm long. A slim
> flat black anodized aluminum blade with chamfered edges and a warm white LED panel underneath,
> glowing softly, with a short black collar where it would clamp onto the top of a pole.

### 4. Security scanner head: `devices/scanner_head`

- **In the world:** the sensors on poles across the campus, beside the cameras. Claude builds the
  pole. A variant of the camera; it may become its own device later.
- **Size:** about 35 cm tall.

> The object: a pole-mounted security sensor, with no pole. About 35 cm tall. A white rounded
> capsule with chamfered edges and a black glass band around its middle, a small black lidar
> puck on top, one small red status light, and a black clamp bracket at its back where it would
> fix to a pole.

### 5. Barrier gate housing: `props/barrier_housing`

- **In the world:** the vehicle barrier at the forecourt. Claude builds the arm.
- **Size:** about 1.1 m tall, 35 cm square.

> The object: the motor housing of a modern vehicle barrier gate, with no barrier arm. About 1.1
> metres tall and 35 cm square. A white pillar with chamfered edges, a black round hub on one side
> where the arm would attach, a thin red light strip down the front edge, a small black camera
> lens near the top, and a flush black base plate.

### 6. EV charger: `props/ev_charger`

- **In the world:** the chargers at the forecourt and the car park.
- **Size:** about 1.5 m tall, 40 cm wide, 25 cm deep.

> The object: a modern electric vehicle charging post. About 1.5 metres tall. A slim white pillar
> with chamfered edges, a black glass face with a small screen, a black charging cable coiled
> neatly in a holster on its side, a thin warm white light ring around the connector dock, and a
> flush black base plate. The OpenBrain emblem from the attached logo, small, near the top.

## Props

### 7. Concrete planter: `props/planter`

- **In the world:** the white concrete planters across the campus, with shrubs.
- **Size:** about 1.5 m long, 0.75 m wide, 0.6 m tall, to fit the grid.

> The object: a long rectangular planter of smooth white precast concrete with crisp chamfered
> edges, about 1.5 metres long, 0.75 metres wide and 0.6 metres tall, filled with dark soil and
> low, neat green ornamental grasses and small shrubs. A thin warm white uplight set into one end.

### 8. Bench: `props/bench`

- **In the world:** benches along the paths and terraces; cover in the game.
- **Size:** about 1.8 m long, 0.6 m deep, 0.45 m tall.

> The object: a modern campus bench, about 1.8 metres long. A solid block of smooth white precast
> concrete with chamfered edges and a warm wood slat seat on top, with no back. Minimal and heavy,
> built to stay outdoors.
