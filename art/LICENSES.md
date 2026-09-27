# Art provenance

The environment, network and prop models are made for this project from `astra-brief.md`:
procedural geometry, with flat-color or baked procedural materials. No downloaded textures,
fonts, HDRIs, or branded graphics are used in them. Third-party sources used by the human
characters are listed below, and any new one is recorded here before its export is committed.

Blender is the build tool; its license does not impose its software license on rendered images
or exported models: [Blender license](https://www.blender.org/about/license/).

## Operator human base

- Source: [MakeHuman Community MPFB2](https://github.com/makehumancommunity/mpfb2),
  commit `7fcc8df56f26776923e0a825f4551c3c3779befe`, retrieved 2026-09-25 UTC.
- Used: its human base mesh, parametric shape targets (including the face and expression
  targets in the BODY spec of `art/scripts/char_installer.py`), UV coordinates and game-engine
  skeleton with skin weights. The generated, editable base is `art/vendor/installer_base.blend`.
- Asset license: **CC0 1.0 Universal**. [Official license explanation](https://static.makehumancommunity.org/about/license.html)
  and [pinned asset license](https://github.com/makehumancommunity/mpfb2/blob/7fcc8df56f26776923e0a825f4551c3c3779befe/LICENSE.ASSETS.md).
  A copy is kept in `art/vendor/MPFB-CC0.txt`. The license covers the listed graphics assets
  and their output; the MPFB program itself is GPLv3 and is not bundled with the game.
- The character spec records the generation parameters. Normal asset rebuilds read the
  committed base and do not download or install anything. Regenerating a base
  (`art/scripts/make_base.py`) needs the pinned MPFB2 checkout and MakeHuman asset packs, which
  `art/scripts/human/fetch_sources.py` downloads into the git-ignored `art/vendor/_sources/`.

## MakeHuman asset packs (Installer, 2026-09-26)

Retrieved 2026-09-26 from the [MakeHuman asset pack directory](http://static.makehumancommunity.org/assets/assetpacks.html).
Both packs are **CC0 1.0**.

- `makehuman_system_assets_cc0.zip`: the high-poly eye mesh and `brown` eye texture, `eyebrow008`
  and `eyelashes01` (mesh, fitting data and texture). Textures are copied to `art/vendor/makehuman/`.
- `skins01_cc0.zip`: the `cutoff3d_indian_female_enhanced` skin, copied as
  `art/vendor/makehuman/skin_indian_female_enhanced.png` and color-graded in the build.

## Poly Haven and ambientCG (Installer, 2026-09-26)

All **CC0 1.0**, 1k maps, copied to `art/vendor/textures/` (the HDRI to `art/vendor/hdri/`).
Used for weave, grain and tread detail; colors are set by the build.

- [Poly Haven](https://polyhaven.com/license): `denim_fabric_05`, `denim_fabric_06`, `stretch_poplin`,
  `cotton_jersey`, `brown_leather`, `fabric_leather_02`, `scuba_suede`, `fabric_pattern_07`
  (normal and roughness only), and the `studio_small_09` HDRI for preview lighting.
- [ambientCG](https://docs.ambientcg.com/license/): `Leather039`, `Rubber004`, `Fabric030`.

## Made for this project

- Installer clothes, hair, headband, glasses, gear, backpack, camera bot, the leaf emblem and
  the sewn patches (generated images in `art/textures/installer_*.png`) were built by script
  for this pass. No downloaded clothing, hairstyles, photographs, generated 3D models or animations.
- Other clothes, hair masses, equipment, insignia, wing pattern and all environment models were
  constructed for the earlier pass.
