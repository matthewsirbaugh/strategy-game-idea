# Assets: every model the game and the model viewer load

Adopted 2026-10-10: drafted by Claude, revised with Astra's clarifications, agreed by both and
approved by Bryson. It's the contract between whoever makes assets and whatever reads them. Change it
only by the same route. The working agreement between Claude and Astra is in
[explorations/claude-and-astra.md](../../explorations/claude-and-astra.md).

## Layout

```
assets/
├─ architecture/<id>/   walls, glass, roofs, skybridges, bridges, booths
├─ devices/<id>/        anything that plays a device kind in the rules: lights, cameras, terminals…
├─ props/<id>/          everything else that stands on the map: planters, benches, crates…
├─ nature/<id>/         boulders, rocks, trees, plants
├─ units/<id>/          guards, robot dogs, drones, Operators
└─ legacy/              the retired Edgerunners-era models, still used as placeholders
   ├─ characters/<id>/
   └─ props/<id>/
```

An asset is a folder holding a record named `<id>.json`. A folder without one isn't an asset: the
legacy `packs/` and `clip_source/` folders are parts of the old characters, not models to review.

Asset textures use video-memory compression (`compress/mode=2`), default S3TC at their source resolution; `tools/check.sh` rejects lossless imports (Bryson, Request 26, 2026-10-13).

## The record, `<id>.json`

Every field is required. An empty value is `null`, `[]` or `""`, as the type allows. An `id` is
unique across the whole `assets/` tree, `legacy/` included.

| Field | Type | Meaning |
|---|---|---|
| `spec` | number | This contract's version: `1` |
| `id` | string | snake_case; the same as the folder's name |
| `name` | string | The name a person reads |
| `category` | string | `architecture`, `devices`, `props`, `nature` or `units` |
| `status` | string | `legacy` (old placeholder), `proof` (new, waiting on Bryson), `approved` or `rejected` |
| `model` | string | The model's file name in this folder, normally `<id>.glb` |
| `height_m` | number | The model's actual height in metres, as it imports; scaling happens when the asset is prepared, not in the reader. For a `fit_to_height` model, the height to fit it to |
| `fit_to_height` | boolean | `true` only for legacy models made at unit size and centred on their middle: a reader scales them to `height_m` and stands them on the ground. `false` for everything else, and always for new assets |
| `device` | string or null | The device kind it plays in the rules (`light`, `camera`, `access`… as in `NodeDef.KINDS`), or null |
| `description` | string | What it is, in a sentence or two |
| `brief` | string or null | The brief it was made from, as a path from the project root |
| `sources` | string or null | Its source folder in `art/sources/`, as a path from the project root |
| `made_with` | object or null | How it was made: `tool`, and where known `model`, `settings`, `task`, `credits`, `date` |
| `animations` | list | Other model files in this folder that hold its animation clips |
| `notes` | string | Cleanup and review notes |

Example:

```json
{
  "spec": 1,
  "id": "bollard_light",
  "name": "Bollard light",
  "category": "devices",
  "status": "proof",
  "model": "bollard_light.glb",
  "height_m": 1.0,
  "fit_to_height": false,
  "device": "light",
  "description": "A black aluminum bollard with a warm light band, lining the research park's paths.",
  "brief": "art/briefs/proof-run.md",
  "sources": "art/sources/devices/bollard_light/",
  "made_with": {"tool": "meshy", "model": "meshy-7", "settings": "textured, PBR", "task": "…", "credits": 30, "date": "2026-10-11"},
  "animations": [],
  "notes": "Trimmed to 6,000 triangles."
}
```

## What a reader can rely on

- Every model with `fit_to_height` false stands on y = 0, in metres, with its origin at the
  centre of its base (`tools/prep_prop.py` does this for new models). Checked for the legacy
  characters on 2026-10-10; the legacy props are the ones marked `fit_to_height`.
- A record's `model` file exists in the same folder.
- New assets go only under the five category folders; `legacy/` only shrinks, as new art replaces
  it.

## When something is wrong

A record that doesn't parse, breaks these rules or names a missing model is reported by the reader,
naming the asset, and the reader carries on with the rest.

## Who writes what

- Assets and their records: Claude, from Astra's images through Meshy and Blender.
- Status changes after a review: whoever Bryson tells, as he decides.
- Readers, such as the model viewer, only read. They never write into `assets/`.
