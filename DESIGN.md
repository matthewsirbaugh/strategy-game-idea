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

Decided 2026-09-23 unless dated otherwise. The reasoning is in
[the battle core exploration](explorations/battle-core.md) for the early decisions, and in
[the rulebook exploration](explorations/rulebook.md) from 2026-10-02 on.

- North star: more of a puzzle with RPG progression and a story, like Into the Breach if it were
  a stealth game with a story and proper upgrades. A puzzle, not a statistical back-and-forth.
  The rules are in [RULES.md](RULES.md). (2026-10-03)
- Hacking is how the team uses the environment, completes objectives and gathers battlefield
  information, such as enemy weaknesses and locations. It resolves through stats, not a
  minigame, and is as deterministic as possible.
- Hidden information. Fog of war like StarCraft: the whole map is visible, but only what you
  have vision on is live. Hacks reveal information and spoof it: a Breached camera stops reporting
  the team. Hiding, the Cloak skill, was dropped on 2026-10-04.
- Three playable characters, with a stable roster through the game, like Persona.
- Operators share the same stats in V1 and differ in personality. AIs specialize through skill
  chips and post-training. Two arrive with set personalities and starting specialties; the
  protagonist's new AI starts generic and is shaped by a questionnaire after the tutorial. Any AI
  can be reshaped into anything. Builds change tactics, not just numbers. Replaces the bespoke
  ability theme per character. (2026-10-04)
- Design principle: add a cost only when something is game-breakingly overpowered, like a free
  peek in Invisible Inc. Otherwise a cost just limits where a thing is useful. Principles like this
  one can be broken when that makes the game better. (2026-10-04)
- No permadeath.
- The game is 3D, and it should be good looking. The models and textures in the game now are
  alpha placeholder art, there to judge the look in play; final art comes later. (2026-09-28)
- The world is a gritty, technofeudal corporate AI future full of advertisements, all the way
  through. It replaces "solarpunk meets corporate AI future." I was trying to reinvent the wheel;
  the classic technofeudal future looks alike across media for a reason, and I think it's the
  most likely one. Our unique angle is that this game is made in a world where this AI now
  exists: we know how it really works and what its limits are, and we build the game around
  them. (2026-09-27)
- The look is gritty cyberpunk anime, in the vein of Cyberpunk: Edgerunners: bold ink outlines,
  cel shading (soft or hard-edged is still open; the build starts soft and L compares), saturated colors and realistic adult proportions. Clothes are
  near-future street techwear, layered, asymmetric and worn, and each character is a little
  eccentric. Grimy neutral bases with one strong accent per character. If players say it looks
  like Edgerunners, it worked. It replaces the Ghibli
  direction from earlier the same day, which replaced a realistic one. The Operators'
  references are in [art/reference/](art/reference/); the house style for image prompts is in
  [the art-pipeline exploration](explorations/art-pipeline.md#house-style). (2026-09-27)
- The enemy is like OpenAI: black and white, very modern, mostly white, with red accents in very
  few places, after Nothing's design philosophy. It leans into the tech oligarchy and stands out
  against dim backgrounds. The rest of the look is back on the drawing board, in
  [the art-direction exploration](explorations/art-direction.md). (2026-10-08)
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
