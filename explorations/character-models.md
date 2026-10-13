# Character models: how the people and robots get made

- Feeds: DESIGN.md's look, [art-pipeline.md](art-pipeline.md) (tool research, and the 2026-09-27
  Meshy characters from the retired look: generated, rigged and animated), the story in
  [core-idea-and-story.md](core-idea-and-story.md)
- Status: parked
- Next action: parked until every current prop has its image and its model (Bryson,
  2026-10-11). Then research the options below, with examples, and bring Bryson a comparison.
  Start it with `/exploration character-models` in a fresh chat.

## The question

What are our options for making the game's characters: the Operators, OpenBrain's guards, and the
robot dogs and drones? Which one puts our best foot forward, before we commit to making any?

## What Bryson has said

- 2026-10-10: characters come after V1, when the story is fleshed out. Their appearance should
  reflect their personality, which isn't decided yet.
- 2026-10-11: two big things are left, the character models and the architecture. Each gets an
  exploration before we commit, so he understands the options and we put our best foot forward. Not
  yet: first every current prop gets its image and its model.
- 2026-10-11: Operators cover their faces, each in their own way. V1's models are masked only (mask,
  helmet or visor); unmasked versions are planned for V2
  ([lore](core-idea-and-story.md#follow-ups-2026-10-11)).
- 2026-10-13, on the first concept sheets ([Request 19](../art/concepts/operator-looks-2026-10-12/README.md)):
  he doesn't like the outfits, they're bad, and he'd rather the Operators just look cool. Maybe the
  humans aren't anime characters, but they aren't realistic either: he's not a fan. Not decided yet.
- 2026-10-13, decided: the characters are stylized, the world stays realistic: "we'll miss the
  target, but we'll get close enough to be visually impressive." The styles to test are painterly
  (Dishonored, Deathloop) and clean hero (Overwatch, Valorant), in
  [the style test](../art/briefs/operator-style-test.md), Request 20. DESIGN.md's "characters
  included" wording changes once Bryson approves it.

Claude's reading: this exploration covers *how* characters get made. *What* each one looks like
still waits on the story.

## Constraints this inherits

- The look: realistic, around 2040, visually close to today; guards are ordinary people with work
  equipment, AR glasses and compute pucks
  ([threshold reference](../art/reference/openbrain-front-security-threshold.png)); robot dogs
  patrol with them ([river crossing](../art/reference/openbrain-research-park-river-crossing.png)).
- The game: seen from above at about 50 degrees, a person about 55 pixels tall at the default
  zoom. Silhouette, team colour and pose matter more than faces at that size; close-ups, if any,
  matter for faces.
- They must animate: idle, walk, run, crouch behind cover, shoot, hack, take a hit, fall. Several
  share clips. The four legacy characters are rigged and still in the game as placeholders.
- Godot 4.7 on an M1 Pro with 16 GB; no budget beyond the subscriptions; Meshy credits shared
  with props.

## Options to research (Claude's starting list, not yet researched)

| Option | In short |
|---|---|
| Meshy, image to 3D, rigged and animated in Meshy | Astra's character sheets in, auto-rig and stock clips out. Tried in September for the retired look |
| Meshy or another generator, then a proper rig | Generated mesh, rigged with Mixamo or Blender's Rigify, clips from Mixamo or motion capture libraries |
| A shared base body, dressed per character | One rigged, animated human; heads, clothes and gear swapped on it. Consistent proportions, one set of animations |
| MetaHuman-style or parametric humans | MakeHuman / MPFB in Blender, or similar: realistic bodies and faces from sliders, already rigged |
| Bought or free character packs | Modern or near-future soldier and civilian packs, restyled |
| Different routes for people and robots | Robots are hard surface, like the props, so Meshy suits them; people may need another route |

For each: how it reads from the battle camera, how faces hold up if we ever zoom in, animation
quality and how clips get shared, cost, and what Astra could contribute.

## Findings

None yet.

## Open questions

None yet.
