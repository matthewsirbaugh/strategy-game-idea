# Example courtyard

This is Bryson's visual level-design intent, made in the isolated Map Workshop.
Use it as a basis for iteration; it does not define or implement gameplay rules.

## Bryson's notes

An optional example to show the tool, not an adopted game level. Open this to experiment, or start a blank layout with New. The room, yard and crate cluster are assembled visual prefabs.

## Dimensions and coordinates

- Workspace: 24 × 20 tiles, 36.0 × 30.0 metres.
- Grid spacing: 1.5 metres. X and Z are the ground plane; Y is elevation.
- Workspace centered on the origin. Positive Z is south, negative Z is north.
- Rotation is Godot's Y-axis rotation in degrees; scale is a uniform multiplier.
- Walls and floors use the grid; props may be freely positioned.
- Prefabs stay grouped; piece_definitions in layout.json records their geometry.
- Model sizes here are visual approximations. Map Workshop uses plain lighting and
  copied models; the game may have different shaders, mounting and placement rules.
- layout.json contains every position, rotation and scale. overview.png captures
  the chosen camera view. top-down.png gives a plan view.
- Implement and validate gameplay separately in the game's current map format.

## Placement list

| ID | Piece | X | Y | Z | Rotation | Scale |
|---|---|---:|---:|---:|---:|---:|
| 1 | Concrete floor | -6.75 | 0.00 | -5.25 | 0.0° | 1.00 |
| 2 | Concrete floor | -6.75 | 0.00 | -3.75 | 0.0° | 1.00 |
| 3 | Concrete floor | -6.75 | 0.00 | -2.25 | 0.0° | 1.00 |
| 4 | Concrete floor | -6.75 | 0.00 | -0.75 | 0.0° | 1.00 |
| 5 | Concrete floor | -6.75 | 0.00 | 0.75 | 0.0° | 1.00 |
| 6 | Concrete floor | -6.75 | 0.00 | 2.25 | 0.0° | 1.00 |
| 7 | Concrete floor | -6.75 | 0.00 | 3.75 | 0.0° | 1.00 |
| 8 | Concrete floor | -6.75 | 0.00 | 5.25 | 0.0° | 1.00 |
| 9 | Concrete floor | -6.75 | 0.00 | 6.75 | 0.0° | 1.00 |
| 10 | Concrete floor | -5.25 | 0.00 | -5.25 | 0.0° | 1.00 |
| 11 | Concrete floor | -5.25 | 0.00 | -3.75 | 0.0° | 1.00 |
| 12 | Concrete floor | -5.25 | 0.00 | -2.25 | 0.0° | 1.00 |
| 13 | Concrete floor | -5.25 | 0.00 | -0.75 | 0.0° | 1.00 |
| 14 | Concrete floor | -5.25 | 0.00 | 0.75 | 0.0° | 1.00 |
| 15 | Concrete floor | -5.25 | 0.00 | 2.25 | 0.0° | 1.00 |
| 16 | Concrete floor | -5.25 | 0.00 | 3.75 | 0.0° | 1.00 |
| 17 | Concrete floor | -5.25 | 0.00 | 5.25 | 0.0° | 1.00 |
| 18 | Concrete floor | -5.25 | 0.00 | 6.75 | 0.0° | 1.00 |
| 19 | Concrete floor | -3.75 | 0.00 | -5.25 | 0.0° | 1.00 |
| 20 | Concrete floor | -3.75 | 0.00 | -3.75 | 0.0° | 1.00 |
| 21 | Concrete floor | -3.75 | 0.00 | -2.25 | 0.0° | 1.00 |
| 22 | Concrete floor | -3.75 | 0.00 | -0.75 | 0.0° | 1.00 |
| 23 | Concrete floor | -3.75 | 0.00 | 0.75 | 0.0° | 1.00 |
| 24 | Concrete floor | -3.75 | 0.00 | 2.25 | 0.0° | 1.00 |
| 25 | Concrete floor | -3.75 | 0.00 | 3.75 | 0.0° | 1.00 |
| 26 | Concrete floor | -3.75 | 0.00 | 5.25 | 0.0° | 1.00 |
| 27 | Concrete floor | -3.75 | 0.00 | 6.75 | 0.0° | 1.00 |
| 28 | Concrete floor | -2.25 | 0.00 | -5.25 | 0.0° | 1.00 |
| 29 | Concrete floor | -2.25 | 0.00 | -3.75 | 0.0° | 1.00 |
| 30 | Concrete floor | -2.25 | 0.00 | -2.25 | 0.0° | 1.00 |
| 31 | Concrete floor | -2.25 | 0.00 | -0.75 | 0.0° | 1.00 |
| 32 | Concrete floor | -2.25 | 0.00 | 0.75 | 0.0° | 1.00 |
| 33 | Concrete floor | -2.25 | 0.00 | 2.25 | 0.0° | 1.00 |
| 34 | Concrete floor | -2.25 | 0.00 | 3.75 | 0.0° | 1.00 |
| 35 | Concrete floor | -2.25 | 0.00 | 5.25 | 0.0° | 1.00 |
| 36 | Concrete floor | -2.25 | 0.00 | 6.75 | 0.0° | 1.00 |
| 37 | Concrete floor | -0.75 | 0.00 | -5.25 | 0.0° | 1.00 |
| 38 | Concrete floor | -0.75 | 0.00 | -3.75 | 0.0° | 1.00 |
| 39 | Concrete floor | -0.75 | 0.00 | -2.25 | 0.0° | 1.00 |
| 40 | Concrete floor | -0.75 | 0.00 | -0.75 | 0.0° | 1.00 |
| 41 | Concrete floor | -0.75 | 0.00 | 0.75 | 0.0° | 1.00 |
| 42 | Concrete floor | -0.75 | 0.00 | 2.25 | 0.0° | 1.00 |
| 43 | Concrete floor | -0.75 | 0.00 | 3.75 | 0.0° | 1.00 |
| 44 | Concrete floor | -0.75 | 0.00 | 5.25 | 0.0° | 1.00 |
| 45 | Concrete floor | -0.75 | 0.00 | 6.75 | 0.0° | 1.00 |
| 46 | Concrete floor | 0.75 | 0.00 | -5.25 | 0.0° | 1.00 |
| 47 | Concrete floor | 0.75 | 0.00 | -3.75 | 0.0° | 1.00 |
| 48 | Concrete floor | 0.75 | 0.00 | -2.25 | 0.0° | 1.00 |
| 49 | Concrete floor | 0.75 | 0.00 | -0.75 | 0.0° | 1.00 |
| 50 | Concrete floor | 0.75 | 0.00 | 0.75 | 0.0° | 1.00 |
| 51 | Concrete floor | 0.75 | 0.00 | 2.25 | 0.0° | 1.00 |
| 52 | Concrete floor | 0.75 | 0.00 | 3.75 | 0.0° | 1.00 |
| 53 | Concrete floor | 0.75 | 0.00 | 5.25 | 0.0° | 1.00 |
| 54 | Concrete floor | 0.75 | 0.00 | 6.75 | 0.0° | 1.00 |
| 55 | Concrete floor | 2.25 | 0.00 | -5.25 | 0.0° | 1.00 |
| 56 | Concrete floor | 2.25 | 0.00 | -3.75 | 0.0° | 1.00 |
| 57 | Concrete floor | 2.25 | 0.00 | -2.25 | 0.0° | 1.00 |
| 58 | Concrete floor | 2.25 | 0.00 | -0.75 | 0.0° | 1.00 |
| 59 | Concrete floor | 2.25 | 0.00 | 0.75 | 0.0° | 1.00 |
| 60 | Concrete floor | 2.25 | 0.00 | 2.25 | 0.0° | 1.00 |
| 61 | Concrete floor | 2.25 | 0.00 | 3.75 | 0.0° | 1.00 |
| 62 | Concrete floor | 2.25 | 0.00 | 5.25 | 0.0° | 1.00 |
| 63 | Concrete floor | 2.25 | 0.00 | 6.75 | 0.0° | 1.00 |
| 64 | Concrete floor | 3.75 | 0.00 | -5.25 | 0.0° | 1.00 |
| 65 | Concrete floor | 3.75 | 0.00 | -3.75 | 0.0° | 1.00 |
| 66 | Concrete floor | 3.75 | 0.00 | -2.25 | 0.0° | 1.00 |
| 67 | Concrete floor | 3.75 | 0.00 | -0.75 | 0.0° | 1.00 |
| 68 | Concrete floor | 3.75 | 0.00 | 0.75 | 0.0° | 1.00 |
| 69 | Concrete floor | 3.75 | 0.00 | 2.25 | 0.0° | 1.00 |
| 70 | Concrete floor | 3.75 | 0.00 | 3.75 | 0.0° | 1.00 |
| 71 | Concrete floor | 3.75 | 0.00 | 5.25 | 0.0° | 1.00 |
| 72 | Concrete floor | 3.75 | 0.00 | 6.75 | 0.0° | 1.00 |
| 73 | Concrete floor | 5.25 | 0.00 | -5.25 | 0.0° | 1.00 |
| 74 | Concrete floor | 5.25 | 0.00 | -3.75 | 0.0° | 1.00 |
| 75 | Concrete floor | 5.25 | 0.00 | -2.25 | 0.0° | 1.00 |
| 76 | Concrete floor | 5.25 | 0.00 | -0.75 | 0.0° | 1.00 |
| 77 | Concrete floor | 5.25 | 0.00 | 0.75 | 0.0° | 1.00 |
| 78 | Concrete floor | 5.25 | 0.00 | 2.25 | 0.0° | 1.00 |
| 79 | Concrete floor | 5.25 | 0.00 | 3.75 | 0.0° | 1.00 |
| 80 | Concrete floor | 5.25 | 0.00 | 5.25 | 0.0° | 1.00 |
| 81 | Concrete floor | 5.25 | 0.00 | 6.75 | 0.0° | 1.00 |
| 82 | Concrete floor | 6.75 | 0.00 | -5.25 | 0.0° | 1.00 |
| 83 | Concrete floor | 6.75 | 0.00 | -3.75 | 0.0° | 1.00 |
| 84 | Concrete floor | 6.75 | 0.00 | -2.25 | 0.0° | 1.00 |
| 85 | Concrete floor | 6.75 | 0.00 | -0.75 | 0.0° | 1.00 |
| 86 | Concrete floor | 6.75 | 0.00 | 0.75 | 0.0° | 1.00 |
| 87 | Concrete floor | 6.75 | 0.00 | 2.25 | 0.0° | 1.00 |
| 88 | Concrete floor | 6.75 | 0.00 | 3.75 | 0.0° | 1.00 |
| 89 | Concrete floor | 6.75 | 0.00 | 5.25 | 0.0° | 1.00 |
| 90 | Concrete floor | 6.75 | 0.00 | 6.75 | 0.0° | 1.00 |
| 91 | Concrete floor | 8.25 | 0.00 | -5.25 | 0.0° | 1.00 |
| 92 | Concrete floor | 8.25 | 0.00 | -3.75 | 0.0° | 1.00 |
| 93 | Concrete floor | 8.25 | 0.00 | -2.25 | 0.0° | 1.00 |
| 94 | Concrete floor | 8.25 | 0.00 | -0.75 | 0.0° | 1.00 |
| 95 | Concrete floor | 8.25 | 0.00 | 0.75 | 0.0° | 1.00 |
| 96 | Concrete floor | 8.25 | 0.00 | 2.25 | 0.0° | 1.00 |
| 97 | Concrete floor | 8.25 | 0.00 | 3.75 | 0.0° | 1.00 |
| 98 | Concrete floor | 8.25 | 0.00 | 5.25 | 0.0° | 1.00 |
| 99 | Concrete floor | 8.25 | 0.00 | 6.75 | 0.0° | 1.00 |
| 100 | Wall segment | -6.75 | 0.00 | -6.00 | 0.0° | 1.00 |
| 101 | Wall segment | -5.25 | 0.00 | -6.00 | 0.0° | 1.00 |
| 102 | Wall segment | -3.75 | 0.00 | -6.00 | 0.0° | 1.00 |
| 103 | Wall segment | -2.25 | 0.00 | -6.00 | 0.0° | 1.00 |
| 104 | Wall segment | -0.75 | 0.00 | -6.00 | 0.0° | 1.00 |
| 105 | Wall segment | 0.75 | 0.00 | -6.00 | 0.0° | 1.00 |
| 106 | Wall segment | 2.25 | 0.00 | -6.00 | 0.0° | 1.00 |
| 107 | Wall segment | 3.75 | 0.00 | -6.00 | 0.0° | 1.00 |
| 108 | Wall segment | 5.25 | 0.00 | -6.00 | 0.0° | 1.00 |
| 109 | Wall segment | 6.75 | 0.00 | -6.00 | 0.0° | 1.00 |
| 110 | Wall segment | 8.25 | 0.00 | -6.00 | 0.0° | 1.00 |
| 111 | Wall segment | -7.50 | 0.00 | -5.25 | 90.0° | 1.00 |
| 112 | Wall segment | -7.50 | 0.00 | -3.75 | 90.0° | 1.00 |
| 113 | Wall segment | -7.50 | 0.00 | -2.25 | 90.0° | 1.00 |
| 114 | Wall segment | -7.50 | 0.00 | -0.75 | 90.0° | 1.00 |
| 115 | Wall segment | -7.50 | 0.00 | 0.75 | 90.0° | 1.00 |
| 116 | Wall segment | -7.50 | 0.00 | 2.25 | 90.0° | 1.00 |
| 117 | Low barrier | 9.00 | 0.00 | 2.25 | 90.0° | 1.00 |
| 118 | Wall segment | -7.50 | 0.00 | 3.75 | 90.0° | 1.00 |
| 119 | Low barrier | 9.00 | 0.00 | 3.75 | 90.0° | 1.00 |
| 120 | Wall segment | -7.50 | 0.00 | 5.25 | 90.0° | 1.00 |
| 121 | Low barrier | 9.00 | 0.00 | 5.25 | 90.0° | 1.00 |
| 122 | Wall segment | -7.50 | 0.00 | 6.75 | 90.0° | 1.00 |
| 123 | Low barrier | 9.00 | 0.00 | 6.75 | 90.0° | 1.00 |
| 124 | Room • 4 × 4 tiles | 4.50 | 0.00 | -3.00 | 0.0° | 1.00 |
| 125 | Guard booth | -5.50 | 0.00 | 3.60 | 0.0° | 1.00 |
| 126 | Delivery van | 3.50 | 0.00 | 3.40 | -90.0° | 1.00 |
| 127 | Three-crate cluster | -3.20 | 0.00 | -2.70 | 0.0° | 0.80 |
| 128 | Shipping crates | -5.50 | 0.00 | -4.00 | 30.0° | 0.85 |
| 129 | Server rack | 4.80 | 0.00 | -5.70 | 180.0° | 1.00 |
| 130 | Access panel | -7.90 | 0.70 | 0.00 | 90.0° | 1.00 |
| 131 | Floodlight pole | -7.00 | 0.00 | 5.50 | 0.0° | 1.00 |
| 132 | Floodlight pole | 7.40 | 0.00 | 5.70 | 0.0° | 1.00 |
