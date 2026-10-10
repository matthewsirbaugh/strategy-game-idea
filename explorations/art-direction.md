# Art direction: back to the drawing board

## The question

What should the game look like, so it's cohesive, detailed and visually interesting? Bryson,
2026-10-08: it's in the right direction and he loves that it's coming together, but it isn't
cohesive, he isn't a fan of the look in its current state, and he doesn't yet know what good would
be. He wants more detail and visual interest, variations of the models we have (walls and the
like), and to be more experimental with the palette, since we've been locked into one aesthetic
from the start.

## What Bryson has said that stands

- The enemy is like OpenAI: black and white, very modern, mostly white, with red accents in very
  few places, after Nothing's design philosophy. It leans into the tech oligarchy, and bright
  enemies stand out against dim backgrounds. Built in the interface on 2026-10-08.
- Everything is going to be dim.
- V1 favors more information that's easy to get; limits come later, if playtesting asks for them.

## Constraints this inherits

DESIGN.md's decisions on the look are what is under review here: gritty cyberpunk anime after
Cyberpunk: Edgerunners, the technofeudal world full of ads, 3D models with 2D portraits, the
camera far back. Final art is deferred toward the end (AGENTS.md); this thread sets the direction
the placeholder art follows. The corps are OpenBrain and Anthropomorphic, and the facility is
Anthropomorphic's, in clay and cream ([environment-art.md](environment-art.md)).

## Method (Claude's recommendation, not yet agreed)

1. Pick three or four candidate directions, each with references from games, film and product
   design.
2. Render our own facility yard in each one, changing only palette, materials and lighting, so
   Bryson compares the actual game instead of mood boards.
3. Bryson picks one, or mixes them.
4. Only then add model variety in the chosen direction: wall variants, floor detail, props.

## Candidate directions (Claude's, to compare)

| Direction | The idea | References |
|---|---|---|
| Clean tower, dirty street | The corp's ground is white, black and sterile, with red signal accents; the street around it is grime, rain and neon ads. The contrast says whose territory you're in | Mirror's Edge, Deus Ex: Human Revolution, Nothing and OpenAI's product design, Edgerunners for the street |
| Monochrome with signal colors | The world is mostly greyscale; only meaning gets color: enemy white, danger red, the team's neon, devices cyan | Superhot, Ruiner, Into the Breach's readability |
| Neon noir, richer | The current night look done properly: deeper blues and magentas, more light sources, more surface variety | Blade Runner 2049, Cyberpunk 2077, The Ascent |
| Brutalist dusk | Less night: concrete brutalism under cold dusk light, controlled color, hard shadows | Control, Mirror's Edge Catalyst, Death Stranding |

Model variety the game needs whichever direction wins: wall variants (panels, vents, pipes,
damage, mounts for signs), floor detail (markings, drains, puddles, cables), and more props
(barriers, lockers, vending machines, AC units, light fixtures).

## Findings

### 2026-10-08 — Preferred theme and follow-up studies

Bryson likes the clean-tower / surrounding-city concept most of the four initial images, but
wants different compositions, landscaping and building designs. He likes the California Valley
feel: still mostly modern, with advanced-looking technology around, and pristine OpenBrain
territory whose palette stands out from the surrounding city. He asks for slightly different
realistic art styles with less of the oil-painting texture and grime in the first image.

The initial four concepts and their prompts are in
[aesthetic-study-2026-10-08](../art/concepts/aesthetic-study-2026-10-08/prompts.md).
The requested follow-up explores a boulevard campus, a civic plaza, a downtown corner and a
creekside campus, with different realistic finishes; the prompts are in
[valley-composition-study-2026-10-08](../art/concepts/valley-composition-study-2026-10-08/prompts.md).
These are concepts for Bryson's review; the final direction remains open.

### 2026-10-08 — Realism, not Edgerunners; OpenBrain is the villain (Bryson)

- The main villain is OpenBrain, the OpenAI clone. Anthropomorphic, Anthropic's stand-in, are
  probably on the good side.
- The Edgerunners look is out. The game's rules aim at AI realism, real AI concepts, and the look
  should follow: what would it really be like?
- Modern America, somewhere in Silicon Valley, California. Visually the world isn't that different
  from today. The main differences: more places are "the poor part of town" than ever, and cars
  are a little sleeker, since electric vehicles have largely taken over, like whatever a Tesla
  would look like in 10 to 15 years.
- A stark contrast between a city that's very familiar but obviously poorer, and pristine white
  buildings with black and red accents.
- Bryson is generating images with GPT-Sol to show what he's going for.

### 2026-10-08 — No humanoid robots; the AI is text and voice only (Bryson)

- Robotics gets better, but general humanoid robots, with a human's dexterity and athleticism and
  the ability to adapt to any environment, never really materialize. AI-controlled drones and
  robot dogs do exist.
- The AI isn't anthropomorphised visually: no appearance, only text and voice. Its personality
  comes through dialogue, so the player makes up their own mind. It has a lot of agency, since it's
  "always on", with the context of the world as well as the digital context.
- The relationship dynamics stay, but the game doesn't make the AIs cutesy characters. The story
  is serious and interesting, for someone living through the mid to late 2020s.
- This retires the 2026-09-24 direction of cute or chibi AIs ([art-pipeline.md](art-pipeline.md))
  and the AI concepts once in `art/concepts/companions/`, archived on 2026-10-10
  ([ARCHIVE.md](../ARCHIVE.md)).

### 2026-10-08 — When, whose facility, how realistic (Bryson)

- The game is set in the late 2030s to early 2040s.
- The facility is OpenBrain's.
- Characters are realistic.
- In-battle lines from the AIs (a comms strip) are not for now.
- The creekside campus ([04-creekside-campus-v2](../art/concepts/valley-composition-study-2026-10-08/04-creekside-campus-v2.png))
  is the latest concept Bryson shared: the white OpenBrain campus across a creek from a run-down
  stucco street, the Operators hidden in the brush between them.

### 2026-10-09 — Graduated to DESIGN.md (Bryson approved)

The setting, the realistic look, no humanoid robots, and the AI as text and voice only are now
decisions in DESIGN.md. The AI line reads "a serious story for a player living through the
current birth of AI", in Bryson's words. The Edgerunners house style in art-pipeline.md is marked
retired.

### 2026-10-10 — City and campus concept batch (Bryson approved generation)

Bryson says the preferred creekside revision captures the intended aesthetic. He asks for
city-proper views combining poverty, advanced technology, modern American architecture and
fashion, with a California Valley / Los Angeles feel. He also asks for additional OpenBrain
exteriors showing autonomous vehicles, cameras, scanners and human security officers whose
headsets let the AI direct them. White and black with sparse red accents should feel clinical,
modern and quietly sinister; the guards are ordinary people using their work equipment.

He approved the six-scene prompt set for generation, commit and push, with the additional
instruction to match his original attached image's aesthetic. The original supplies the
overall visual mood; the creekside revision supplies the refined campus, darker public streets
and friendly emblem. Previous requirements remain: varied neglected streets, sparse people,
aged and partially failed lighting, and no explicit text in new concepts.

The [approved prompt set](../art/concepts/city-and-campus-study-2026-10-10/prompt-review.md)
contains three city scenes and three exterior views of the same campus. The batch explores
specific clothing and hardware designs; no resulting image has yet been selected as a final
game reference.

During generation, Bryson chose the first commercial-street render's lighting over a darker
edit. The city must retain enough light for a playable environment and for other AIs to inspect
the concept details. Keep partial fixture failures and aged light, with readable exposure.

Six standalone concepts are now generated and agent visually checked: commercial street,
residential courtyard, service/transit edge, campus exterior/approach, autonomous vehicle
forecourt and headset security threshold. The [gallery and exact prompt record](../art/concepts/city-and-campus-study-2026-10-10/README.md)
preserve the selected native PNGs and source references. These are concepts, not game-integrated
assets or a gameplay visibility test. Bryson's first-city lighting selection is retained exactly.

### 2026-10-10 — How the art work runs; the game and interface while it does (Bryson)

- Bryson works on the art with GPT-6 Sol and posts the images he likes most, with any
  documentation that goes with them. Claude takes them in as the central project architect:
  documents them, adopts what Bryson picks into `art/reference/`, and keeps the threads current.
- The game stays as it is while new art is made: the current models remain as placeholders.
- The interface's colors are part of the reset. Its structure stays: it works, it's clear, and
  it's cool, with room for tweaks.
- "ANTHROPOMORPHIC" on the title screen and the map's sign stays until there's new art; then a
  full update pass.
- The previous art went to the archive outside the project ([ARCHIVE.md](../ARCHIVE.md)).

## Open questions

1. Answered: the facility is OpenBrain's.
2. Which candidate directions are worth rendering, and is any missing?
3. Answered: characters are realistic.
