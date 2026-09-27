# Design

Status: early. The first design decisions are under Decisions; everything else here is still
open. This file records what I want from the project, what I'm drawing on, what I've decided,
and what is still open. It is written in my voice — "I" is the designer. How we work is in
AGENTS.md.

## Why this project matters

This project is worth doing if it feels like artistic expression. I'm a systems designer at
heart. I love the intricacies and the details, and I love story, characters and video games.
A game is the best avenue I have to express that. The dream isn't a specific game or genre,
it's having a conduit to express through.

I want it to tell a story, to be a fun experience for players, and to give them the same
wonder, excitement and determination to succeed that my favorite games gave me.

Finished means other people can play it, and ideally that I can start distributing it. The
only commercial motivation is that getting paid for this would let me do more of it. The
pie-in-the-sky version is doing it full time.

## Touchstones

What I love in other games and why. These are inspirations, not commitments. Nothing here has
been chosen for this game.

### Fights that work like strategy puzzles

Chained Echoes. Every character is needed, so you balance status effects, party boosts,
healing and damage, and the overheat mechanic adds another layer on top of that. Every fight
felt interesting.

### Every fight can be a real challenge

Chained Echoes heals the party after every fight. That removes the busywork of keeping a
potion stock, and it lets every fight be tuned to be genuinely hard. The alternative is quick,
grindy encounters where managing health between fights is an inconvenience rather than a
strategy.

### Solving puzzles with what I've gained

The Legend of Zelda. Combat is a puzzle of its own and also part of a larger one: use the
tools and weapons gathered across the game to their greatest effect, to open new areas and
beat new enemies. Racking my brain until I find the answer makes me feel like a genius.

### Discovery that makes travelling worth it

Breath of the Wild. Spot something in the distance, make the journey to it on limited stamina
that forces creative and precise movement, and find out what is there: enemies I might take on
indirectly or in creative ways, gear, an easter egg, or a piece of lore that expands the
world. From that high point, spot the next thing and glide toward it. Later upgrades expand
what is reachable without removing the need to manage it.

### Collectibles as a reason to search every inch

Donkey Kong Bananza and Super Mario Odyssey put traversal and exploration first, driven by
collecting. A known count per area, scattered everywhere, each one usually a small piece of
creative problem solving. Korok seeds work the same way in Breath of the Wild.

### Story and characters

Dragon Ball Z: The Legacy of Goku II and Buu's Fury are favorites because of the story and the
characters. Zelda's aesthetic and story matter to me too.

### Small, stable teams with real power

Triangle Strategy is maybe one of my favorite SRPGs. Where it fell short: the story still felt
like generic fantasy, everything outside battle was cookie cutter when it could have been
incredible, and it didn't go far enough in making the player and enemies feel genuinely
powerful, with many strategic options and specializations. I also stop liking these games when
the roster gets so big that I have to use characters I don't like to stay competitive.

### Not unpacked yet

Adventure, building up a team over time, and strategy games in general. Pokémon Emerald, Fire
Emblem: Three Houses, South Park: The Stick of Truth and The Fractured But Whole.

## Constraints

- About 10 hours a week, sometimes a bit more.
- No budget beyond the AI subscriptions I already have.
- I direct everything. Art and code are executed by AI. See AGENTS.md for who does what.

## Decisions

Decided 2026-09-23 unless dated otherwise. The reasoning, and the working models that are not
locked yet, are in
[the battle core exploration](explorations/battle-core.md).

- Hacking is how the team uses the environment, completes objectives and gathers battlefield
  information, such as enemy weaknesses and locations. It resolves through stats, not a
  minigame, and is as deterministic as possible.
- Hidden information. Fog of war like StarCraft: the whole map is visible, but only what you
  have vision on is live. Hacks can reveal, hide and spoof information.
- Three playable characters, with a stable roster through the game, like Persona.
- Each character has one bespoke ability theme with many abilities in it that synergize in
  different ways, developed through hardware, harness and post-training upgrades. It is broad
  enough that no two players play alike. Builds change tactics, not just numbers.
- No permadeath.
- The game is 3D, and it should be good looking. The MVP uses basic greybox shapes; art comes
  once the playtest validates it. (2026-09-24)
- The world is solarpunk meets a corporate AI future full of advertisements. (2026-09-24)
- The look is simple and cel-shaded, anime-inspired: Ghibli style, but cyberpunk. It replaces the
  earlier realistic direction, and all art made before it was removed. Cyberpunk 2077's color
  palette on Ghibli-style characters and places, with ink outlines and Ghibli proportions, which
  should read better on the map. Flat color for now. The three Operators' references, the main character
  included, are in [art/reference/](art/reference/). Details are in
  [the art-pipeline exploration](explorations/art-pipeline.md). (2026-09-27)
- 3D models in the world and in battle; 2D portraits in dialogue scenes, like Persona 4. Battle
  keeps the camera far enough back that faces don't need to hold up close. (2026-09-27)
- The Operators' weapon is non-lethal, like a phaser or taser: it fires a disabling energy pulse.
  (2026-09-27)
- Between battles there is a town, like Persona: walk around, talk to people, investigate, and
  buy and install upgrades. It starts small, and it gets built to explore the story I need to
  tell rather than the story being made to fit the game.

## Open questions

1. Scope. How big this is follows from the idea we land on, so it gets decided after the
   brainstorm.
2. How the art gets made. The look is set (see Decisions); the pipeline is being worked out
   in [the art-pipeline exploration](explorations/art-pipeline.md).
3. How exploring connects to turn-based fights, including taking enemies on indirectly or in
   creative ways.
4. Whether the touchstones above are ingredients the brainstorm has to use, or inspiration it
   is free to leave behind.
5. The core idea and story. In progress in
   [the exploration](explorations/core-idea-and-story.md#topic-index); no final conclusion has
   graduated here. See [the board](EXPLORATIONS.md) for the next action.
