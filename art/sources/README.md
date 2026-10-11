# Sources

What each asset was made from, outside the game so Godot never loads it. One folder per asset,
matching its place in `game/assets/`:

```
art/sources/<category>/<id>/
├─ 01-main.png, 02-side.png …   the images Bryson chose, which went to Meshy (the only finals)
└─ prepared.glb                 only where a build script starts from it (the fleet car and van)
```

Meshy's raw downloads (`meshy-*.glb`) live outside the repository, in
`~/Desktop/AI Strategy Game Model Archive/`, in the same `<category>/<id>/` layout (Bryson,
2026-10-11). Download new ones straight there.

The asset's record, `game/assets/<category>/<id>/<id>.json`, points here and says how the model
was made. The contract is [game/assets/README.md](../../game/assets/README.md).
