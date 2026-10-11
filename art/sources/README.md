# Sources

What each asset was made from, outside the game so Godot never loads it. One folder per asset,
matching its place in `game/assets/`:

```
art/sources/<category>/<id>/
├─ the images Astra made for it, which went to Meshy
└─ Meshy's download, before cleanup
```

The asset's record, `game/assets/<category>/<id>/<id>.json`, points here and says how the model
was made. The contract is [game/assets/README.md](../../game/assets/README.md).
