# Art provenance

The procedural geometry and flat-color materials in this pass are made for this project from
`astra-brief.md`. No downloaded textures, fonts, HDRIs, or branded graphics are used in the
battle kit. Any third-party character source is recorded here before its export is committed.

Blender is the build tool; its license does not impose its software license on rendered images
or exported models: [Blender license](https://www.blender.org/about/license/).

## Operator human base

- Source: [MakeHuman Community MPFB2](https://github.com/makehumancommunity/mpfb2),
  commit `7fcc8df56f26776923e0a825f4551c3c3779befe`, retrieved 2026-09-25 UTC.
- Used: its human base mesh, parametric shape targets, UV coordinates and game-engine skeleton
  with skin weights. The generated, editable base is `art/vendor/installer_base.blend`.
- Asset license: **CC0 1.0 Universal**. [Official license explanation](https://static.makehumancommunity.org/about/license.html)
  and [pinned asset license](https://github.com/makehumancommunity/mpfb2/blob/7fcc8df56f26776923e0a825f4551c3c3779befe/LICENSE.ASSETS.md).
  A copy is kept in `art/vendor/MPFB-CC0.txt`. The license covers the listed graphics assets
  and their output; the MPFB program itself is GPLv3 and is not bundled with the game.
- `prepare_installer_base.py` records the generation parameters. Normal asset rebuilds read
  the committed base and do not download or install anything. Optional regeneration uses a
  checkout of the pinned revision supplied through `MPFB_SOURCE`.
- Clothes, hair masses, equipment, insignia, wing pattern and all environment models were
  constructed for this pass. No downloaded clothing, hairstyles, photographs or animations.
