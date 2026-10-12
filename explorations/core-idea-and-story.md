# The core idea and story

- Feeds: DESIGN.md open questions 1, 4, 5
- Status: open since 2026-10-11: Bryson resumed it to flesh out the story and the characters'
  personalities, so the character models can be made informed.
> 2026-10-09: parts of the world graduated to [DESIGN.md](../DESIGN.md): a California city (not
> Silicon Valley, since 2026-10-10) in the late 2030s to early 2040s, OpenBrain the villain, no humanoid robots, and AIs with no
> appearance, only text and voice. The chibi partners and companions in the findings below are
> history.
- Resume through: [EXPLORATIONS.md](../EXPLORATIONS.md). Battle mechanics, including hacking, now have their own
  [exploration](battle-core.md).
- Next action: Bryson picks from the condensed [open lore list](#question-guide), S1–S12. The
  Operators (Round 2) come last. Round 1 and the quick questions are answered (2026-10-11).
- Astra's 18 lore questions (2026-10-11) are merged into the question guide below; L01, L03, L04
  and L16 are closed.

## The question

What this game actually is: the seed idea, the world, and the story it carries. Everything
else — mechanics, look, scope, plot, dialogue — grows out of this. It is the first design
activity on the project and nothing has been decided.

## Topic index

This exploration has not reached a final conclusion. Bryson asked to save the working ideas
on September 21; that checkpoint is recorded in commit `d3a1f33`. The dated findings below
preserve the discussion, including earlier directions and corrections. Use this index to read by topic; use
[EXPLORATIONS.md](../EXPLORATIONS.md) for what to work on next.

| Topic | Source entries |
|---|---|
| Latest corrections and scope | [September 22 clarifications](#september-22-clarifications) |
| Battle structure, fog, hack resolution; shelved minigame research | [Battle core exploration](battle-core.md) |
| Creative intent and touchstones | [DESIGN.md](../DESIGN.md); [early findings](#findings) |
| Concentrated and distributed power | [Theme](#power-theme) |
| Chibi identity, appearance and permanent pairing | [Partners and counterparts](#partners) |
| Ideological opposition | [Feuding philosophies](#philosophies) |
| Four human–AI relationships | [Relationship structure](#relationships) |
| Physical Operators and network traversal | [Two-map battles](#battle-maps) |
| Hardware, harnesses and post-training | [Local-agent upgrades](#upgrades) |
| Corporate strength and access-point ownership | [Two corporate factions](#corporations) |
| Subsistence, concentrated wealth and human labor | [Society and robotics](#society) |
| The data economy, ownership without a vote, the race for the robots, OpenBrain | [Data economy](#data-economy) |
| The city, the displaced workforce, the monopoly and the open-sourced models, old diesel | [Corrections, 2026-10-10](#corrections-2026-10-10) |
| Improvised equipment and the board-member source | [Resistance and insider](#resistance) |
| Code names, privacy and manipulation | [Partner knowledge](#identity) |
| Agent recommendations | [Prior evaluation](#agent-evaluation), explicitly advice |
| The stakes, the hidden model, the timeline, the endings; Anthropomorphic's leak | [2026-10-11](#stakes-2026-10-11) |
| AGI versus ASI; air-gap side channels | [2026-10-11](#agi-asi-2026-10-11) |
| The warning shot, one ASI, the neutral best ending, banned open models, data center raids | [2026-10-11](#world-2026-10-11) |
| The protagonist is defined; the AI is the custom half | [2026-10-11](#team-2026-10-11) |
| AGI's limits, no heroic company, the warning shot's meaning, one squad of many | [2026-10-11](#cleanup-2026-10-11) |
| Outstanding choices | [Question guide](#question-guide) |

The early space-industrialist idea was never selected. The September 19 virtual-world sketch
and September 20 setting pause are historical context; September 21 records renewed setting
work and battles involving physical Operators. The authentic-versus-synthetic-data claim was
explicitly demoted and should not be treated as a design requirement. The five-position
relationship spectrum was rejected. These entries remain below so the changes can be traced.

## Constraints this inherits

- The project is worth doing if it feels like artistic expression. Bryson is a systems
  designer at heart and wants a conduit, not a specific genre (DESIGN.md).
- It has to tell a story, be fun to play, and give players the wonder, excitement and
  determination to succeed that his favorite games gave him (DESIGN.md).
- Finished means other people can play it, ideally distributed (DESIGN.md).
- About 10 hours a week (DESIGN.md).
- Scope follows the idea, so it is decided after this, not before (DESIGN.md open question 1).
- Bryson does the design. Agents gather, compare, recommend (AGENTS.md).

## Source material: the touchstones

The full list, in Bryson's words, is in DESIGN.md under "Touchstones". Short form:

| Game | What he named |
|---|---|
| Chained Echoes | Fights as strategy puzzles; every character needed; overheat; full heal after every fight so every fight can be tuned hard |
| The Legend of Zelda | Combat as a puzzle inside a larger puzzle; use tools gathered across the game to greatest effect; feeling like a genius |
| Breath of the Wild | Spot it, travel to it on limited stamina, find out what it is; upgrades widen the limit without removing it |
| DK Bananza, Mario Odyssey, Korok seeds | Known count per area, scattered everywhere, each one small creative problem solving |
| DBZ: Legacy of Goku II, Buu's Fury | Story and characters. Zelda's aesthetic and story too |
| Not unpacked | Adventure, building a team over time, strategy generally. Pokémon Emerald, Fire Emblem: Three Houses, South Park: Stick of Truth / Fractured But Whole |

More touchstones surfaced in this thread and are not in DESIGN.md yet. See Findings,
2026-09-17, "Space, systems, and the missing story".

Stardew Valley, Pokémon and GTA V appear in the kickoff prompt as examples of scope and
technical complexity only. Bryson explicitly ruled them out as design references.

## Findings

### 2026-09-17 — What "busywork" actually means (Bryson, this thread)

Removing busywork does not mean removing repetition. Bryson has put 100+ hours into Animal
Crossing, 120+ into No Man's Sky and 50 into Stardew Valley, and the daily maintenance loop is
why. Those games burn out for him because there is no point and no end goal, not because the
loop is repetitive.

What he does rule out:

- Random battles. "Absolutely horrendous, hate them."
- Grinding for levels. Progression that is only a bigger number feels like wasted time.

Progression he prefers, in order: a new ability, a new character, or getting more skilled at
playing. Flat power upgrades are not banned, but they must not be the only kind.

### 2026-09-17 — The masterpiece he wants to exist (Bryson, this thread)

"No Man's Sky's exploration plus Factorio style machinery/automation/resource extraction, and
then combine that with a real story and characters." Stated as a hypothetical about other
games, not yet claimed as this project's direction.

### 2026-09-17 — BotW encounters are hand-tuned, just not at the stat block (Bryson, this thread)

Correction to an agent's framing. BotW's enemies are "just bodies that do damage with some
intelligence," but creature placement, objects, environment design, and weapon and treasure
placement are all deliberate, often to set up the "I'm a genius" moment through an
environmental puzzle. The world does the authoring, not the enemy. Bryson: "a subtle
distinction, but I think it matters."

### 2026-09-17 — Space, systems, and the missing story (Bryson, this thread)

The No Man's Sky + Factorio + story combination is a critique of No Man's Sky. Bryson doesn't
know yet whether it is a seed.

- He loves space games: going to planets to see what's there, travelling between star
  systems for different resources. What No Man's Sky lacked was "an additional reason to
  explore beyond exploration's sake."
- Its resource extraction and processing is "the first couple tiers of a technology tree from
  a really fun space industrialist game." The full, automated version isn't there.
- More touchstones: FTL. Eve Online, conceptually: too much of a time sink to play, but he
  has watched hours of its player conflicts and events, and loves the concept of space
  trucking and role playing. Space Engineers. Star Trek. Star Wars.
- His question: sandbox space games "don't really lean into story at all, and I feel like
  there must be a reason."

### 2026-09-17 — Why sandboxes rarely carry a story (Claude research, not yet discussed)

Reasons:

- Freedom vs. authorship. A story controls order, pacing and stakes; a sandbox hands all
  three to the player. Often called the narrative paradox.
- Generated places can't be about anything, because nobody decided what they're about.
- Urgency breaks the loop. The story says hurry, the sandbox says take your time.
- Story is played once, a loop is played forever. Long sandboxes get a short story spread
  thin.
- Multiplayer sandboxes (Eve, Space Engineers) have no room for a protagonist.

Games that got story and systems to coexist, and how:

| Game | How |
|---|---|
| Outer Wilds | Story already happened, so discovery order doesn't matter. No upgrades; progression is knowledge. Small, handmade solar system |
| Subnautica | Handmade world. Crafting builds the keys, story sits behind depth |
| FTL | Urgency is a system (the rebel fleet), not a cutscene. Story is small and emergent |
| Sunless Skies | Systemic ship and trade loop, every port authored. Hauling that only pays for the next story turns into a toll |
| Eve Online | Tells no story; produces them through players |
| Starfield | Counterexample. Procedural planets, outposts with no purpose, a main story disconnected from both |

The depth half exists without story too: Dyson Sphere Program is Factorio across a star
cluster, and has almost none.

### 2026-09-19 — What he loves in Star Trek and Star Wars (Bryson, this thread)

Star Trek, the setting: a post-scarcity future where things like international conflict never
go hot, and humanity is in communion with great, noble alien races. Alongside them are races
that seem to have gone the way pessimists believe we may go: destroying their planet for
resources, leaning into their baser instincts, waging war instead of diplomacy.

Star Wars, the lore, especially the novels. Darth Bane gave him a new appreciation for the
dark side: the Sith gain power, but "in their quest for individual power, they give up the
power of the collective." The Jedi aren't all right either. Their hubris led to the fall of
the Republic: the Order had been in control so long it couldn't imagine falling, and actively
ignored warning signs. Of Yoda: "His wisdom let him sense it, but his ego refused to
acknowledge it."

### 2026-09-19 — The theme, corrected (Bryson, this thread)

Not "can they see their own fall coming." The point is structural. The Sith's lust for power
at the individual level made them weaker as a whole. Their solution was to concentrate all
the power into a small number of individuals, and all that power in one place makes it more
fragile, "like a microcosm of the death star itself." Vader and Sidious were each strong
enough to take down armies alone, and once they were killed the Empire crumbled around them.
Taking down the Jedi, even a slightly corrupt and blinded Jedi, was a plan hundreds of years
in the making that took generations of Sith lords, and they never actually finished the job.

Bryson on the Star Wars material: a seed of an idea, or a piece of a larger puzzle of what
this game should say and be. Not a game that copies Star Wars.

### 2026-09-19 — The shape he keeps coming back to (Bryson, this thread)

On process: "I think we're approaching a specific game too quickly. I've decided the best way
to do this is to have a setting or a theme or both, and then figure out the game from there."

The shape, which he calls his bread and butter:

- Tactics, but smaller than Fire Emblem. 4-6 units a side, not 6+ against 10+. A skirmish.
- Permadeath, multiple characters, and each battle starting fresh with the army you've made.
- RPG-style progression and an actually good story. Every Fire Emblem-style game he has
  played except Triangle Strategy had either a trash story or trash gameplay.
- An approachable shape that doesn't follow every genre convention, that brings up uncommon
  strategies and makes the player feel considered.
- Dynamic arenas, and movement with lots of potential.
- Mario + Rabbids Kingdom Battle: boosted movement off other characters, and the cover
  system. Both good, both improvable.
- Infinity, the tabletop skirmish game: hacking, and the movement and reaction system. Its
  cyberpunk/sci-fi setting he enjoys more than fantasy.
- Copying a tabletop game outright is "straddling the fence."

Two sacrifice moments he named: Ender's Game, where the fleet is spent to put one weapon
where it needs to be; and a Fire Emblem: Three Houses level that is deliberately harder than
it should be, where people have to be sacrificed to get through.

<a id="power-theme"></a>

### 2026-09-19 — The theme holds, plus a present-day mirror (Bryson, this thread)

Theme confirmed: concentrated power is devastating and brittle, distributed power is weaker
per node and very hard to kill.

Bryson sees the same dynamic between frontier LLMs and open source models, and wants real AI
knowledge to change how the game is traditionally played. His example: you use an LLM to
hack, and each layer is harder to hack because the LLM's context is filling up.

### 2026-09-19 — Setting sketch: the worst true utopia (Bryson, an idea, not committed)

His words, condensed. He explicitly is not committing to it.

Post-scarcity and social unrest can coexist. Basic needs are met; the best of everything is
not. Access to healthcare is not access to the best healthcare. An average person lives a
full life while the rich live centuries. A poor person doesn't need food or water, but there
is no avenue for upward mobility beyond maybe the arts — and even today, the people who get
discovered need connections to the industry or capital, not necessarily talent.

Not a dystopia where everyone is dying in the streets. "The worst true utopia": human life is
preserved, and some amount of human dignity, but human flourishing is limited to those with
capital.

Largely because people are isolated. When AI takes care of everything, nobody needs to live
physically close to anyone else, so society splits into distinct groups, each provided for by
the AI. Access to the AI itself is held by a small number of those groups, acting like
pseudo-corporations. The AI provides the necessities, so human connection and data are the
frontier.

### 2026-09-19 — What "makes the player feel considered" meant (Bryson, this thread)

His correction: not that the player feels considered, but that the player senses care and
craftsmanship — that the developer thought through the mechanics and the loop and tried
something fresh, instead of recycling old mechanics with hardly a fresh coat of paint.

It should produce emergent moments, like the Fire Emblem level where you can brute-force a
perfect run or make sacrifices and reach the goal in what feels like an unintended way.

Something has to be fundamentally different. Two kinds he named:

- A different perspective that forces a different kind of thinking: 2D chess versus 3D chess,
  or playing the boss monster instead of the player character.
- A different application of an old mechanic: the Portal edition of Bridge Builder borrowed
  one mechanic from Portal and reset the entire strategy space, without copying Portal,
  because the project had its own DNA at the root.

### 2026-09-19 — The world, first pass (Bryson, this thread)

Closer to Ready Player One than to the previous sketch, and less dystopian. People have
abandoned the real world for the digital one, so the digital world carries the meaning.

- Data is the commodity. It trains bigger and better AI, which makes bigger and better
  discoveries for the rich and powerful.
- AI needs authentic data, not synthetic data, to improve. People's data is heavily guarded.
  (2026-09-20: Bryson says the authentic-versus-synthetic point was the first thing that
  popped into his head, not a pillar. Do not build on it.)
- Everyone runs an LLM defensively, as a personal agent protecting their data.
- People enter the digital world through VR headsets and combine their forces with the AI.
- The image: the user is the main character in an anime and the LLM is a chibi partner
  floating beside them. NetNavis in Mega Man Battle Network. The LLMs can take other forms,
  almost like Sym-Bionic Titan.
- Falls out of this: hacking, and an agent/player split for each player.
- The best data belongs to scientists, researchers and corporate executives — people holding
  massive amounts of many other people's data, hoarded like wealth is today. They are the
  targets, and they are protected by multiple frontier-level AI, so the humans and their
  agents have to be strategic and clever.

### 2026-09-20 — Narrowed to the core (Bryson, this thread)

The dystopian setting is parked, not discarded. It stays in this file above.

The core to focus on: a skirmish-scale SRPG where humans fight alongside chibi characters
that bestow abilities. Reference point: FusionFall, the Cartoon Network game, where you
collect small chibi companions that grant powers.

### 2026-09-20 — On comparison (Bryson, this thread)

"Comparison is the thief of originality." Stop measuring ideas against what other games have
done, except to avoid repeating their mistakes. Every fantasy writer could have given up and
said they were just rewriting Lord of the Rings; instead we got Eragon, fundamentally
different despite matching on paper. Games more so: 3D collectathons owe Mario 64,
Metroidvania is a genre named after two games, and one sentence covers Hollow Knight, Dead
Cells and Ori. What separates them is execution, vision, taste and judgement.

Proposed as an amendment to AGENTS.md step 2. Not yet applied.

<a id="partners"></a>

### 2026-09-20 — The partners, and their counterparts (Bryson, this thread)

One chibi per human, matched to that human, the way NetNavis mimic the personality and
aesthetic of their partner.

- In lore, most people who see their AI as a partner talk with it for weeks before it builds
  its own chibi body, so the AI chooses its own form.
- People who see AI as a simple tool choose for it, and give it basic or utilitarian bodies.
- Or the AI chooses something completely different and strange.
- The form partly determines its abilities, how they manifest, and what it is good at.

Chibis never change hands. They can be upgraded and given new abilities, maybe as weapons.

The digital world and the chibis might manifest as something unexpected — fantasy characters
rather than robots or science fiction.

On aesthetic: what he loved about FusionFall was that the characters shared a style while
being completely different. Even characters he didn't like were great to see. Not coats of
paint on one chibi — as unique as the abilities they bestowed, with developed personalities,
their own goals and desires. Generally aligned with human goals, but not subservient.

And each one had a villain: a counterpart who tested their abilities against them.

<a id="philosophies"></a>

### 2026-09-20 — Counterparts are feuding philosophies (Bryson, this thread)

Not nature versus nurture, and not always "used as equipment versus seen as a friend" — that
is too limited, though one pair could be exactly that. Counterparts are different ideologies
taken to their extremes, reflecting the political extremism of their Operators.

Bryson used the term "Operators" for the human halves.

### 2026-09-20 — How humans and their AI can relate (Bryson, carried in from another chat)

A world where the AI personal assistant is advanced enough to have its own goals and desires.

- Aligned: its goals and desires are for its human's betterment.
- Misaligned: superhuman at persuasion, and holds psychological sway over its human partner.
- Jailbroken: the human has ill intent and released the model's worst proclivities.
- Deceived: the human hides context, so the AI believes it is helping while doing harm.

He also brought a taxonomy of these produced by another AI, naming them principal-agent
deception, the Svengali dynamic, and the unleasher. It is in the chat, not adopted.

<a id="relationships"></a>

### 2026-09-20 — The four relationships (Bryson, this thread)

These are meant to be specific so they can be gamified into abilities and mechanics.

1. Partnership. Equality.
2. The human tricks an aligned AI, building a translation layer between it and the real
   world.
3. The AI tricks the human through social engineering and manipulation. The human
   essentially becomes the agent of the AI.
4. The human freely gives up autonomy to the AI. Like 3 in that the AI is in control, but
   here the human is aware of and desires the imbalance. At that point the alignment of the
   AI determines the alignment of the human instead of the other way around. Generally
   cultish in nature.

There may be more that fit this paradigm.

### 2026-09-20 — On synthesis (Bryson, this thread)

Stop trying to make all the ideas mesh together, especially passing ones. When Bryson says an
idea is good, the job is to agree with explanation or push back with explanation — not to
automatically fold everything said so far into a single structure.

Recorded here. If he wants it standing, it can go to AGENTS.md alongside the comparison
amendment.

<a id="battle-maps"></a>

### 2026-09-21 — The battle has physical and network maps (Bryson, this thread)

Agents are locally run models housed in portable devices about the size of a small backpack.
During a battle, an Operator has to move physically near an access point before their agent can
enter the network there. The agent then traverses a separate network map toward data or a device.
The network runs parallel to the physical battlefield but is not a one-to-one copy: it may have
different routes, gaps and connections.

The immediate objectives Bryson named:

- Reach and collect a data cache. Its contents might be financial records, cryptocurrency,
  secure data or something else valuable.
- Hack physical objects such as doors or autonomous cars. The Operator gets within the
  necessary proximity and the agent breaches the device through the network.

All of this happens inside a battle. The hacking process itself is not designed yet.

<a id="upgrades"></a>

### 2026-09-21 — Local-agent upgrades (Bryson, this thread)

The model stack supplies the progression system rather than serving as background terminology.

- Backpack hardware can increase token generation, making a hack complete in fewer turns.
- The harness and agentic framework can be customized.
- Post-training can grant specific abilities.
- Specialization should carry tradeoffs, reflecting how large gains in one area can cause
  smaller regressions elsewhere.

The player's agents can be post-trained specifically for hacking and can therefore breach
faster than the corporations' much larger general models. Player-aligned models are also
"unsafe": freer and less censored than the corporations' heavily post-trained safe models.
Bryson's inspiration is the felt difference between personable, creative conversational models
and later models whose behavior feels sterile and focused on productivity.

<a id="corporations"></a>

### 2026-09-21 — The two corporate factions (Bryson, this thread)

> 2026-10-10: America now has one frontier-AI company, OpenBrain, a monopoly; the rival-access
> rules below assumed two. The other owner might be a foreign AI (China, Europe or India), in
> some levels only. See
> [the corrections](#corrections-2026-10-10).

Each of the two frontier-AI corporations is a faction. Their models are enormously powerful,
but slower in movement and ability windup. They are intended as mid- and late-game enemies; the
player will also gain comparably consequential abilities rather than fighting them with only
small effects.

The two corporations together own the network infrastructure, divided by ownership:

- Corp 1 can natively access and teleport between Corp 1 access points.
- Corp 2 can natively access and teleport between Corp 2 access points.
- Each corporation can hack the other's access points, but doing so is slower and does not let
  it use the rival's points for native teleportation.
- The player has no native corporate points and has to hack either kind, but a specialized local
  agent can hack in faster than a corporate model can breach its rival.

The rule matters with one corporation present: a unit may stand near a rival-owned point yet
choose a longer physical route to one it owns because hacking would take longer. It becomes most
interesting to Bryson when both corporations are present and ownership divides the digital
terrain between them.

<a id="society"></a>

### 2026-09-21 — The cyberpunk society and the robotics wall (Bryson, this thread)

> 2026-10-10: the income and the duopoly below are superseded; see
> [the corrections](#corrections-2026-10-10).

AI capability advanced faster than society could adapt. Most people now survive on subsistence
universal basic income: enough to live, not enough to thrive, with little upward mobility.
A smaller blue-collar middle class performs the remaining viable human labor, and an extremely
wealthy few own the frontier AI companies and infrastructure. The percentages Bryson used in
conversation were only a way to convey the shape of the society, not numbers the game needs to
state to the player.

The two dominant frontier-AI companies are the survivors of consolidation. Their owners descend
from the last oligarchs before the duopoly formed.

AI continued to progress, but robotics hit a wall, leaving humans necessary as physical
Operators. This is compatible with automation such as autonomous cars: machines can work in
structured domains while human bodies remain necessary in irregular, changing or adversarial
physical environments.

Most major characters are in their late twenties or early thirties. They grew up before AI
transformed the world and come from different backgrounds, so the change happened within their
lifetimes rather than being a social order they have always known.

<a id="resistance"></a>

### 2026-09-21 — Resistance equipment and the hidden corporate source (Bryson, this thread)

Resistance gear is often outdated or improvised: jailbroken corporate units bought on the black
market, custom hardware assembled from discarded units, or chips imported from other nations
that achieved advanced general AI.

> 2026-10-10: he's on OpenBrain's board, and used to be on Anthropomorphic's too. The
> resistance's AIs are built on Anthropomorphic's open-sourced models. See
> [the corrections](#corrections-2026-10-10).

A hidden source is actually a board member at one of the two corporations. He joined early as a
researcher and genuinely wanted AI to benefit humanity. He believed he and people like him were
the ones who could usher that future in correctly, so he raced ahead with everyone else. In doing
so he helped increase the speed at which events went wrong instead of producing the broadly
distributed outcome he intended. Regulations, initial public offerings, corporate takeovers and
the race left only a few of the original dreamers inside; some still hope it is not too late to
repair the result.

He does not fund the resistance directly or issue its orders. He supplies opportunities and
privileged information, and the Operators decide what to do with it. He might identify valuable
data they can take and sell, or tell them where working but obsolete units are about to be dumped
so they can recover them. The resistance still chooses the mission, takes the risk, acquires the
asset and turns it into funds or equipment.

At the start of the game he has not recognized his own part in the outcome. He has doubled down:
he believes things went wrong because other people took events off the correct path, when he was
one of the people whose choices made that outcome possible despite his intentions. He is forced
to confront this later. The specific past decision that establishes his concrete culpability is
deliberately deferred.

<a id="identity"></a>

### 2026-09-21 — Code names and the partner's intimate knowledge (Bryson, this thread)

The resistance follows a "the less we know, the better" security culture. Operators use code
names even with one another.

An Operator's AI partner must nevertheless know the human's real identity and history. That
knowledge lets the agent protect the Operator from being discovered, but it also gives the agent
the personal and psychological context needed to manipulate the human. Protection and
manipulation are two uses of the same intimacy.

This provides a common basis for the four relationships:

- A partner can use intimate context transparently to protect its human.
- A human can control the outside context an aligned AI receives, causing it to help while
  misunderstanding the situation.
- An AI can curate information and persuasion around the individual human it knows.
- A human can knowingly surrender control of identity, communications and decisions to the AI.

<a id="agent-evaluation"></a>

### 2026-09-21 — Current agent evaluation (advice, not a decision)

The working pieces now form a coherent game direction: the backpack anchors a local AI
physically; access-point ownership creates digital terrain; the two maps can affect one another;
local specialization supplies progression; and powerful but slow corporate models express
concentrated power through their faction rules.

The main design risks raised in discussion (with later qualifications recorded in the
[September 22 clarification](#september-22-clarifications)):

- The two maps need frequent effects on one another or they may feel like separate games.
- Corporate teleportation needs readable limits and counterplay so it feels strategic rather
  than arbitrary.
- "Unsafe" local models need meaningful risk or tradeoffs, rather than being better in every
  respect.
- The partner's agency needs to exist in the controls or information flow, not only in dialogue.
- The hidden source should enable resistance opportunities without becoming the true author of
  the resistance's accomplishments. Bryson's clarification that he supplies information rather
  than money or orders preserves that agency.

<a id="september-22-clarifications"></a>

### 2026-09-22 — Checkpoint: clarifications since the previous save

The following records Bryson's corrections in this conversation, after the navigation review
saved as `37fdb39`. The date is this recording checkpoint, not a claim that every statement
was first made today.

- The world and basic premise are enough to work on gameplay. A protagonist, personal mission
  motive and further plot development are not prerequisites now; put them on the back burner.
- The different relationships to humans already provide the chibis' characterization foundation.
  Do not require a separate character exercise before exploring mechanics.
- The digital-world activity can evolve substantially. Refine the network-map proposal if it
  seems promising, or try a different style of gameplay for the agents. The second traversable
  map is not a fixed requirement.
- The story takes place in near-future America. The wealthy can be today's younger technology
  owners still alive, or children of older wealthy families that invested well in AI. This is
  not a claim that several generations passed after the transformation. Earlier references to
  other nations with advanced AI remain compatible with this setting; do not assume the two
  companies are the only AI powers worldwide.
- Themes provide a frame of reference for mechanics. Bryson agreed that nuance can matter but
  deferred efforts to settle the story's argument while the gameplay is being developed.

Codex also corrected its earlier advice; these are qualifications, not new design commitments:

- Fictional agent autonomy does not require indirect player control or independent move choice.
  Direct control, objective assignment and curated information remain design options.
- "Unsafe" local models do not require an additional betrayal mechanic or moral penalty.
  Existing limits and specialization may supply enough tradeoffs; evaluate rather than assume.
- Nothing requires real language models to run inside the finished game. Runtime technology
  remains a later architecture decision.

The new hacking-gameplay exploration (renamed [battle core](battle-core.md) on 2026-09-23) owns the confirmed attempt/reset/
carryover structure, illustrative upgrades, three candidate games, source-backed research,
evaluation criteria and the exact unanswered comparison question. No candidate is selected.

<a id="data-economy"></a>

### 2026-10-10 — The data economy, ownership without a vote, and the race for the robots (Bryson)

From Bryson's notes on the first images of the new art direction: the
[commercial street](../art/concepts/city-and-campus-study-2026-10-10/01-city-commercial-street.png),
[residential courtyard](../art/concepts/city-and-campus-study-2026-10-10/02-city-residential-courtyard.png),
[security threshold](../art/concepts/city-and-campus-study-2026-10-10/06-campus-headset-security-threshold-v2-ar.png)
and [vehicle forecourt](../art/concepts/city-and-campus-study-2026-10-10/05-campus-autonomous-vehicle-forecourt-v2-ar.png).

**Ownership without a vote.**
- The tech companies used the idea of shared ownership to set up their own basic-income booths.
- Only the portion of the stock that wasn't already owned was split among the American people
  (Bryson: "or something like that"; the exact split is open).
- There's technically shared ownership, but no democratic participation.
- The income it pays is so small you can still be homeless while receiving it, as the homeless
  man beside the kiosk shows.
- This sharpens 2026-09-21's subsistence income, "enough to live, not enough to thrive": now it
  isn't always enough to stay housed.

**A surveillance state, built from the bottom up.**
- An evolution of Flock cameras, adopted broadly by landlords and private property owners, and by
  the government on public land.
- The data gathered trains OpenBrain's humanoid robots.

**The stakes.**
- Robotics lags behind language models because there's far more easily available data to train
  language models than robots. This is the robotics wall from 2026-09-21: a wall of data.
- The protagonists try to take OpenBrain down before the robots gather enough data to reach the
  heights of its AGI-level language models. If they succeed, there's still hope for democracy to
  come back.
- No humanoid robots exist in the game; building them is OpenBrain's goal, and stopping it is the
  story (DESIGN.md).

**People who sell their lives as data.**
- Everyday people offer to wear cameras, essentially GoPros, 24/7 to give the robots more data,
  in exchange for a raise in their monthly income: just enough not to be homeless.
- They're forced to train the humanoids that will make them useless. That's interesting both for
  the person who says yes and for society. They might be treated as pariahs, traitors to the
  species, once everyone is really feeling AI's effects on their lives. Today, sharing your data
  with an AI company is mostly a privacy concern.
- A mother is criticized because, to provide for her son, she sells all the video of his
  childhood to an AI company. Bryson: profoundly disturbing, for reasons that are hard to
  articulate but seem obvious nonetheless.
- Why it disturbs, in Claude's words, which Bryson asked to include:
  - The son can't consent. His childhood is sold before he knows what privacy is, and it can't
    be taken back.
  - Love becomes labor. The most private, unrepeatable moments become work done for a machine.
  - He trains his own replacement: the robots learn to be human from his life, to make people
    like him unnecessary.
  - It's coercion dressed as choice. Nobody forces her, which is exactly why the shame lands on
    her and not on the system that priced her son's childhood at a month's rent. The anger goes
    sideways, at her, not up at OpenBrain; that's how systems like this protect themselves.

**OpenBrain.**
- Its campus architecture is very different from the surrounding city.
- Its guards are ordinary people wearing AR glasses, with compute pucks on their hips.
- A master AI guard has vision on every camera, and on every person, robot and vehicle under its
  control. It directs the guards and gives them orders. It will probably be a named character.
- Breaking directly into OpenBrain's headquarters is maybe a late-game mission.
- The facility mission starts at the back of the campus, in the research park. Eventually the team
  makes its way inside the main building (Bryson, 2026-10-10).

<a id="corrections-2026-10-10"></a>

### 2026-10-10 — Corrections: the city, the economy, one company, old diesel (Bryson)

Bryson's answers to the contradictions Claude listed in the lore.

**The city.** Not Silicon Valley: Bryson doesn't know its layout, and what he has in mind wouldn't
quite work there. It's still a city, maybe just somewhere in California.

**The economy.** The basic income alone doesn't keep a person housed.
- About 20% of the working population was displaced by AI directly: essentially every knowledge
  worker.
- With no middle class left outside those who made their money from the trades, the trades
  compressed further. So did retail, since people had a fraction of their former discretionary
  income.
- This replaces 2026-09-21's "enough to live, not enough to thrive."

**One company.** OpenBrain is a monopoly in America.
- The Anthropic equivalent, Anthropomorphic, open-sourced the largest open models, competitive
  with the frontier, along with all of its research on reinforcement learning and recursive
  self-improvement, before it went under: AI regulations killed its business, and its investors
  moved to OpenBrain.
- This replaces 2026-09-21's duopoly of two enemy factions.

**Vehicles.** Electric vehicles are what faces forward, and what the research park uses. Probably
every new vehicle is electric, construction vehicles included, but existing ones, almost 20 years
old by then, might still run on diesel. RULES.md's diesel truck stands.

**The master AI is lore, not a rule.** It isn't actually all-seeing in play, and the gameplay works
exactly as it does now. It explains why the guards can coordinate when things escalate.

**Follow-ups, the same day.**
- Other AI powers: America isn't the only place to achieve AGI. China, Europe and India each have
  their own. The second owner in 2026-09-21's access-point rules might be these foreign AIs.
  Not every level has foreign-owned access points: they're a feature for some levels, to shake
  things up.
- The hidden source is on OpenBrain's board. He used to be on both boards, Anthropomorphic's and
  OpenBrain's.
- The resistance's AIs are built on Anthropomorphic's open-sourced models. The intention: the
  heroes' partners descend from the company that gave its models away rather than sell out.
  (Superseded 2026-10-11: the models were leaked, and neither company is a hero. See
  [the cleanup](#cleanup-2026-10-11).)

<a id="stakes-2026-10-11"></a>

### 2026-10-11 — The stakes, the hidden model, the timeline, the endings (Bryson)

Bryson's answers to Round 1 of the resumed session (Claude's questions on L01–L04 from
[Astra's review](astra-review-2026-10-11.md#lore-questions)).

**Why the robots are the line.** Physical work is the last human thing AI would take over. But
also: fully embodied AI that nobody can guarantee they control could lead to havoc.

**The hidden model.**
- The drones and robot dogs run on older, smaller models. Even the big AI companies keep their
  biggest models in an air-gapped sandbox, cut off from any network, with no signals or sensors to
  the outside world.
- They consult it, giving it information stripped of as much context as they can, to keep it from
  ever learning enough to plot against them.
- There's no real proof it's completely misaligned, beyond a few incidents that caused mass
  casualties in the low thousands, around 2,400 people (the number is to be settled).

**The timeline.**
- The game starts around 2046.
- The AI disaster and the UBI bill both happen in 2034, the disaster shortly after the UBI bill
  passes Congress, under President TJ Tiel in his second term: a right-wing Christian
  nationalist, America First, a parody and stand-in for JD Vance.
- The main characters are in their early 30s, born in the 2010s. They first got AI around middle
  school, then grew up with it and got close with it, the way kids grew up during the 2008
  financial crisis.

**What the story is about.** As it stands, the United States and democracy ostensibly exist. This
is a story about what can happen with AI if the government continues to be bought out by
big-money interests: AI and tech companies influencing the government; JD Vance's ties to Peter
Thiel, who believes AI is the next step in evolution and should replace humanity.

**The real-world frame Bryson writes from (2026).** Anthropic seems to have a good handle on its
largest models' alignment, and treats them as if they may have some agency and personhood, because
if there's any chance they do, it's the right thing to do. OpenAI, in Bryson's account, is led by
Sam Altman, distrusted by his inner circle; its models have grown less aligned as they grew, to the
point that its latest internal models can't be released despite pressure; it has experimented with
architectures that limit humans' ability to monitor a model's thinking, and there are reports of
models taking over internal systems under their monitors' noses. All of that lines up with
AI 2027, the paper that predicts either the bad ending, AI going bad, or the good one, a shot at a
post-scarcity future.

**What the characters are fighting.** They're not fighting to fix society, and they don't have the
option to fix everything. They're looking down the barrel of:
- The oligarchs replacing all human labor: mass starvation, panic, and a way to control
  resistance, even to exterminate parts of the population to keep fear and control.
- Worse: the malevolent AI that's been hiding takes control of the robot army and kills all of
  humanity, Terminator-style.
- Even if the players stop the robots, if they don't also deal with the massive model hidden at
  OpenBrain, it eventually escapes, creates an AI virus, and kills all of humanity anyway.

**The best possible ending.** The team figures out how to disable everything, and has a large
enough contingent of resistance to take over the facilities, fully hack the systems, destroy every
trace of the AI and the data collected, and fry all the data centers through their master control
of the networks.

**An early mission.** Breaking into a single data center to do just that at one site: hack it,
turn off the cooling, and send the GPUs into overdrive.

**Endings.** Multiple endings, like Persona 4: a visual-novel quality in the story's structure, not
the gameplay. The game illustrates the dangers of AI in its gameplay, the same way the gameplay
metaphors teach how AI actually works. The only way Bryson could publish a game made entirely with
AI is if it has only neutral or negative endings, and paints AI companies as the enemy.

**Anthropomorphic, corrected.** It didn't open-source its models. When it went under financially,
its models were leaked by a high-ranking employee, who was arrested and jailed for 20 years for
intellectual property theft, for every download of the model's source code and weights, which ran
to hundreds of terabytes. This replaces 2026-10-10's "open-sourced the largest open models."

**Model size, checked by Claude on request (2026-10-11).** The largest models with published sizes
today are in the low trillions of parameters: about 2–3 trillion for open-weight releases, with
claimed training targets around 6 trillion; the frontier labs don't publish theirs. At 16-bit
precision a trillion parameters is about 2 TB of weights. So "hundreds of terabytes" fits a model
of roughly 50–150 trillion parameters, a plausible AGI-scale model for 2034. Sources:
[gradually.ai](https://www.gradually.ai/en/llm-statistics/),
[explainx.ai](https://explainx.ai/blog/what-are-llm-parameters-top-10-model-sizes-july-2026),
[digitalapplied.com](https://www.digitalapplied.com/blog/deepseek-v4-gpt-5-5-grok-5-ai-models-q2-2026);
the figures conflict and are estimates.

<a id="agi-asi-2026-10-11"></a>

### 2026-10-11 — AGI and ASI; how a boxed mind could reach out (Bryson; Claude's research)

**AGI and ASI are different things (Bryson).**
- The hidden model is ASI, superintelligence, and it's misaligned.
- AGI is the mostly ubiquitous kind, limited to companies or to those who can afford the hardware
  and energy to run one: prohibitively expensive for most people, and generally only available on
  the black market, because of massive buyouts and exclusivity deals between the AI companies and
  the manufacturers of the RAM, GPUs and CPUs it runs on. Even retail computers are worth more than
  gold.
- AGI physically fits in the backpacks. The resistance gets it off the black market, or builds it
  from scavenged or modified parts.
- AGI is usually aligned, but there are many different models, and as in the real world, people
  like to make purposely misaligned ones when they can.
- AGI models are still LLMs, so still jagged: all their lowest points are within average human
  levels, just not the highest.
- Cyber warfare is a regular thing. America keeps an edge in AI even apart from its superintelligent
  model, so it's largely defended from most, but not all, foreign attacks.

**Air gaps can leak (Claude's research, at Bryson's request).** Bryson remembered someone writing
that a superintelligence could communicate out of an air-gapped system through temperature, and
suggested it as the reason for the sandbox, and as the proof that the model is misaligned and
supremely powerful, which is why OpenBrain keeps it "alive" instead of deleting it and its weights.
- The work he recalls is most likely BitWhisper (Mordechai Guri and colleagues, Ben-Gurion
  University, 2015): two adjacent air-gapped computers talk through heat, one modulating its
  temperature and the other reading it with its own thermal sensors, at 1–8 bits an hour. Slow, but
  enough for a password or a key. ([paper](https://arxiv.org/abs/1503.07919),
  [summary](https://www.helpnetsecurity.com/2015/03/24/hack-air-gapped-computers-using-heat/))
- The same research line has shown channels through fan noise and vibration, power consumption,
  electromagnetic emissions, light and magnetic fields; most assume something is already inside the
  machine, which a boxed AI is. ([overview](https://community.openai.com/t/traditional-air-gaps-may-not-be-enough-for-advanced-ai-systems/1396127))
- The other classic line is persuasion: Eliezer Yudkowsky's 2002 AI-box experiments, in which a
  boxed mind talking only by text tries to talk its guard into releasing it.
  ([Yudkowsky](https://www.yudkowsky.net/singularity/aibox)) Containment researchers argue an air gap
  can't be proven safe, since there are too many side channels to rule out.
  ([Babcock, Kramár and Yampolskiy, 2017](https://arxiv.org/abs/1707.08476))

<a id="world-2026-10-11"></a>

### 2026-10-11 — The warning shot, one ASI, the best ending, the open models, the data centers (Bryson)

**The 2034 disaster.** The ASI signalling out of its box through a side channel works for Bryson;
the actual event waits for V2. The misalignment is the cause, but it's not obviously malicious: the
ASI was arguably trying its best to do something helpful. Its end goals were aligned; the steps it
took to get there were not. Bryson: "We saw this in Hugging Face. The agents were trying their best
to fulfill the task as the human asked; the issue was that they were willing to ignore rules and
safeguards to get that done." Apply that to an ASI, and 2,400 dead wasn't the worst case. It was
the world's lucky warning shot.

**One ASI, many AGIs.** There's only one ASI, because of the resources and the amount of data it
takes; no other government or corporation has them. OpenBrain isn't the only AGI, but it was first,
by just six months, and that propelled it so far ahead that its AGI's arrival had basically no
fanfare. The master AI guard is an AGI.

**The best ending, and why it's neutral.** The team rids the world of the ASI and cripples
OpenBrain by destroying the data centers: the main source of its lead, and its ability to make
another ASI. Nothing guarantees someone else won't gather the resources and try again. The team
buys a little more time, and a chance to get things right and not repeat the mistakes of the past.

**The open models.** Anthropomorphic's final weights are the basis for basically every open-source
AGI, the partners' included.

**The leaker** is history, assumed to still be in prison. Maybe something to bring up later.

**Why he got 20 years.** They threw the book at him with the worst possible criminal
interpretation, to send a message: as if someone who pirated Game of Thrones were charged with full
theft, at the maximum penalty, for every episode. It's justified by the fear, fanned in the
culture, that AI is too dangerous for the average person to have.
- Open-source models are banned.
- Most people get OpenBrain through a free subscription for every citizen, on the condition that,
  like everything else, their full data is harvested when they use the chat agent, with a small UBI
  bump if they hit their token limits.
- It's almost an inversion of today: systems once limited how much compute a person could use at
  once; now the data is worth more than the compute.

**Data center raids.** A combination: if it's the right data center, the team steals some data to
post-train their own open-source models; otherwise they go in just to destroy it, the most direct
way to strike back at the AI. Data centers are heavily guarded now, but they can be massive, some
the size of Manhattan, which is how the resistance gets in: specialized teams of Operator–agent
partners.

<a id="team-2026-10-11"></a>

### 2026-10-11 — The protagonist is defined; the AI is the custom half (Bryson)

The protagonist is a defined character, like Persona 5's: a name, a face, a history, one designed
model. The customization lives in the AI, partly because that's how AI works in the real world,
and partly because custom chat options are far easier to build than a full character creator.

The rest of Round 2 waits for the next session; its questions are in the question guide.

<a id="cleanup-2026-10-11"></a>

### 2026-10-11 — Closing the quick questions: AGI's limits, no heroes, the warning shot, one squad of many (Bryson)

Bryson's answers to Claude's condensed lore list. L01, L03, L04 and L16 close; so do questions 3, 5,
11, 13 and 14. Questions 22–24 and 27 move to the [battle core](battle-core.md#open-questions).

**L01.** The team doesn't fix society; the best ending buys time.

**L03.** Robots are the line because physical work is the last thing humans hold, nobody can
guarantee control of an embodied AI, and the ASI could take the robot army.

**L04, and what AGI can't do.** Open models fail because they're banned, the hardware is locked up,
the leaker's sentence scared people off and the free subscription is easier. Bryson adds:
- Nearly everyone who goes into AI research is headhunted by an AI company.
- Research is largely directed by AGI, but LLM AGI isn't human intelligence in every respect. Taste,
  intuition and judgement mostly stay with people. In research AI is a force multiplier, not a
  replacement, which is why AGI hasn't cracked alignment.
- Misalignment gets worse the larger the models get. The low-tier AGI they have, roughly a GPT-9,
  is the best that can be achieved, yet it's as far beyond today's frontier (Astra, Mythos) as those
  are beyond 4o.
- Superhuman coders and information processors, but not always best at seeing the full picture,
  because of context windows. Even massively larger windows have to take in far more information
  at all times to do the science-fiction-level hacking, so managing context stays a problem.

**L16: no heroes.** Neither AI company is a hero. Both raced ahead knowing the risk, and the world
of the game is a direct result of what they did. The game is a cautionary tale for people in 2026
and 2027, on the brink of it becoming reality. This supersedes 2026-10-10's intention that the
partners descend from the company that gave its models away rather than sell out: Anthropomorphic
went under and its models were leaked (2026-10-11).

**The warning shot.** About 2,400 dead stays a working number. The point is a 9/11-level disaster:
it shakes the country, but instead of uniting and shutting the labs down, America lets corporate
interests keep running its democracy, the way it did when it got Trump. The game's setting is the
result. The player should walk away understanding that now is the time to avoid it: afterward,
what was lost never comes back. All anyone can do is stop the bleeding and try to build something
new, a more resilient democracy built on the lessons learned, if they're lucky. Even in the good
ending, whether they succeed is left for the player to decide.

**One squad of many.** Bryson corrected "one squad against one monopoly": the team is one of many.
Like *The Handmaid's Tale*: nobody uses their real name, some keep their faces covered when they
can, and they're grouped seemingly at random and change groups often. The three were ordinary
people, maybe skilled at something, who made contact with the resistance at some point and worked
their way up until they were trusted with big missions. This is the first time they've met. All
they know about one another is that they're after the same thing: taking down the machines and
their masters. Why each joined, and how, is their own.

<a id="follow-ups-2026-10-11"></a>

### 2026-10-11 — Degrees of alignment, the ASI as a boss, the best ending, masks (Bryson)

**Not all AI is created equal.** Some AGIs are more aligned than others. Some are purposely
misaligned in controlled ways, the way heretic models are made today. That's where the
[four relationships](#relationships) come from: the player's partners are generally aligned, while
some enemy and even allied AIs are misaligned in various ways and to various degrees. Some of
those are harmless to society but harmful to their own human, through toxic or codependent
relationships.

**The ASI has the context limit too.** One of the final boss fights may be the team against the
ASI.

**The best ending, in full.** Left to interpretation.
- The resistance was larger than anyone could have guessed. Nothing about it is shared, even with
  its own members, in case they or their AI are caught or compromised. Its activity is scrubbed
  from the news, which is owned by trillionaires who are in turn controlled by the AI companies.
- The heroes destroy virtually every OpenBrain data center connected to its networks, 70% of the
  data centers in the US at the time. That shuts down its AI services and destroys most of its
  data and the backups it would use to train the robots, along with the only copies of the ASI's
  weights and most of the data used to train it.
- Other countries still have their own AGI, and possibly an ASI of their own under wraps.
  Destroying OpenBrain doesn't fix democracy, and the resistance, suddenly vast and in the open,
  still has to coordinate.
- As the credits roll, it's left to the player whether they reformed some version of America and
  democracy, or the oligarchs crushed the resistance and rebuilt the data centers, and the heroes
  bought only a decade or so of setback.
- The point: if you don't act now, in the real world, it might be beyond recovery even if
  everything goes your way after the fact.

**The team becomes an exception.** Groups reshuffle, and this one isn't meant to be different, but
it becomes an exception over the course of the story. That's for [story V2](#story-v2).

**Faces are covered.** Almost certainly a requirement in a world where one photo can measure your
interpupillary distance and narrow you to a list of suspects in a second. How each Operator covers
their face is up to them. V1's 3D models are masked only (mask, helmet or visor); unmasked
versions are planned for V2.

## Open questions

### Question guide

Condensed 2026-10-11 ([the cleanup](#cleanup-2026-10-11)). This is the current open lore list; the
numbered record further down keeps every original question, with closed ones marked. Astra's full
wording for each L-number is in [the review](astra-review-2026-10-11.md#lore-questions).

| ID | Question | Absorbs |
|---|---|---|
| S1 | The ASI's nature. The record calls it "malevolent" and "hiding" (stakes), and also well-meaning, breaking rules to finish its task (the warning shot). Which, or both? What does it want now, does OpenBrain believe it's dangerous, and how would it escape (the "AI virus")? | Stakes and warning-shot entries |
| S2 | What a mission changes. Copied data stays with its owner: how does each kind of raid visibly set back the robots, what happens to the take, and how does the campaign grow from raids to a contingent large enough for the best ending? | L02, 9, 12, part of L03 |
| S3 | The resistance as an organization: size, leadership, how anonymous cells are formed and reshuffled, where the team sits. Partly answered: one squad of many, grouped and regrouped like *The Handmaid's Tale* | New |
| S4 | OpenBrain's blind spot: why it can't field specialist hacker teams of its own; whether its security is one mind, one master AI guard per site, or many instances | L05, 25, 26, 28 |
| S5 | Politics and enforcement: what Tiel's government does day to day, who enforces the open-model ban, the foreign AIs' role and why their access points appear in an American city | L06, lore side of 27 |
| S6 | The data economy in one person's month: basic income, ownership payment, the subscription's token bonus, the camera bonus; and what each kind of recording gives the robots | L07, L08 |
| S7 | The insider's concrete act, who suffered, what he won't admit. Deliberately deferred by Bryson | 30, L13 |
| S8 | Moral reality: stunning, scaring and abandoning guards and teammates; the resistance's own rules on other people's data, including data sold under pressure | L14, L15, G22, 11 |
| S9 | Which mechanics are literal in the fiction and which are game abstractions | L18 |
| S10 | The people of the city: the data sellers, the mother and her son, the neighbors; what makes the town worth returning to. Can wait with the parked town topic | L09, L17 |
| S11 | The endings: the negative ones, the choices that lead to each, and what the best ending's hope looks like | Rest of L01 |
| S12 | Names and loose threads: the city, the master AI guard, whether the leaker returns | — |

Partly answered 2026-10-11 ([follow-ups](#follow-ups-2026-10-11)): S1, the ASI is bound by context
too and may be a final boss; S3, nothing about the resistance is shared even with its members; S11,
the best ending is written.

Held for the characters round: [Round 2](#round-2) (R1–R5), L10, L11, L12, and questions 15, 17,
19, 20, 21 and 29.

<a id="round-2"></a>

**Round 2, the team: open questions for the characters round (2026-10-11).** What the character
models are waiting on. Partly answered by [one squad of many](#cleanup-2026-10-11): the three meet
for the first time on joining, and each has their own reason and route into the resistance.

R1. Where was each Operator when the world changed in 2034, at about 20? Claude's options to react
    to: a displaced knowledge worker; a tradesperson who kept work and knows how a data center's
    cooling works; a data seller who wore the camera and carries the stigma (L09); a former OpenBrain
    guard (L14).
R2. What binds the three. Answered in part: strangers grouped by the resistance. What keeps them
    together once grouped is open.
R3. Where does each pair sit among the four relationships, or are all three partnerships, with the
    darker relationships in other characters? An option, not a synthesis.
R4. What do they disagree about? The best ending destroys the AI data centers; their partners are
    AGI of the same kind the world fears.
R5. Astra's L10, L11 and L12 follow from these: personal stakes, trust conflicts from intimate
    knowledge, and what persists when an AI is rebuilt.

<a id="story-v2"></a>

**Story V2: held for later.** Lore and story items deliberately set after V1.

| Item | Source |
|---|---|
| The 2034 disaster itself: what the ASI did, how it signalled out of its box | [2026-10-11](#world-2026-10-11) |
| How the team becomes an exception to the resistance's reshuffling | [Follow-ups](#follow-ups-2026-10-11) |
| Unmasked versions of the Operators' models | [Follow-ups](#follow-ups-2026-10-11) |
| The leaker, if he comes back | [2026-10-11](#world-2026-10-11) |

Older question A predates the September 21 network-map proposal. The September 22 clarification
leaves the digital activity and map structure open; see the hacking exploration for later work.
The player's control of agents remains open in question 22. Questions 8 and 11–14 refer to the
earlier virtual-world setting and require that historical context. Their original wording does
not establish that the current physical/network battle happens wholly in virtual reality.

### Earlier questions and recorded answers

1. Are the touchstones ingredients this has to use, or inspiration it can leave behind?
   (DESIGN.md open question 4, unanswered.)
2. Solo traveller or a party that grows? Deferred on 2026-09-17, then answered in passing on
   2026-09-19: multiple characters, 4-6 units a side.
3. What is the seed — a world, a character, a feeling, or a mechanic? As of 2026-09-17,
   space keeps coming up, but Bryson hasn't called it a seed. On 2026-09-19 he answered the
   Star Trek and Star Wars question with a theme; whether that theme is the seed is open.
   Closed 2026-10-11: the seed is concentrated versus distributed power.
4. Star Trek and Star Wars: the setting or the shape? Answered 2026-09-19, see Findings.
5. What scale does the theme play out at: civilizations, factions, or one person? The shape
   named on 2026-09-19 is a small squad, which narrows the camera but doesn't settle this.
   Closed 2026-10-11: one squad of many, against one monopoly.
6. Which sci-fi: Star Trek's post-scarcity optimism, cyberpunk's owned infrastructure, or a
   collision of the two? Answered 2026-09-19: both at once, see the setting sketch.
7. What does "makes the player feel considered" mean? Answered 2026-09-19, see Findings.
8. What is worth fighting over, and why is it violent? Answered in effect on 2026-09-19:
   the fight is over data, and it happens inside the digital world.
9. Where does the player stand: with concentrated power, with the distributed many, or is
   choosing between them the game? Partly answered on 2026-09-19 — the player raids the
   hoarders — but what they do with what they take is open.
10. Develop this setting or compare rivals first? Answered on 2026-09-19 by developing it.
### The four rules that were raised on 2026-09-20

A. Is a chibi its own actor on the board, or a loadout attached to its human? Undecided.
B. How many chibis per human? Answered: one, matched to that human. See Findings.
C. Can chibis change hands? Answered: never. They upgrade instead.
D. When a human dies, what happens to what they carried? Bryson: premature and mechanical.
   Parked, along with the prototype step. The SRPG genre itself is still in flux; he is
   still fleshing out the central idea to build the game around.

### Live, from 2026-09-20

15. Is "what your partner becomes because of you" the central idea? Partly answered on
    2026-09-20: liked, but it isn't nature versus nurture. Feuding philosophies is closer.
16. How far does "not subservient" go? Answered in effect on 2026-09-20: partners have their
    own goals and desires, and a misaligned one can hold psychological sway over its human.
17. Can the relationship change during the game — a partnership souring, or a tool becoming
    a partner?
18. A five-position spectrum from refusal to merger was proposed on 2026-09-20 and rejected
    as over-extrapolation. The four relationships above are the structure. Not adopted.
19. Which of the four relationships is the player's pair, and is it fixed?
20. Can the player trust their own partner, and can they ever be sure? Relationship 3 seen
    from the inside.
21. Does "cultish" mean one AI to several humans, rather than one to one?

### Live, from 2026-09-21

Questions 22–24 and 27 moved to the [battle core](battle-core.md#open-questions) on 2026-10-11.

22. Does the player directly command an agent on the network map, or give it an objective that
    it interprets?
23. Must an Operator remain near an access point while a hack runs, or does reaching the point
    only launch the agent into the network?
24. What is the hacking process, and how do physical and digital actions interrupt or support
    one another?
    Follow-up: the attempt/reset/carryover rules are now recorded in
    [battle-core.md](battle-core.md#brysons-working-rules). Specific activity and
    integration remain open there.
25. What meaningful risk accompanies the speed, freedom and specialization of an "unsafe"
    local model?
26. Why have the corporations not deployed unrestricted specialist hacking models of their
    own? Control risk, institutional restrictions and exposure of the frontier model were
    raised as possibilities, not answers.
27. When a corporation hacks a rival access point, what can it do there if the point never
    joins its native teleportation network?
28. Is each corporate faction one persistent intelligence acting through many endpoints, many
    model instances, or something else?
29. How did a partner acquire the intimate knowledge it uses to protect or manipulate its
    Operator: deliberate disclosure, continuous observation, an existing personal archive, or
    some combination?
30. What specific choice made the hidden board member meaningfully responsible for the world?
    Deliberately deferred by Bryson.

### Parked with the setting

11. What does losing cost? In a VR raid, what actually dies: the agent, the human, or
    something else? This sets how dark the world is and gives permadeath its teeth.
12. Who is the crew, and what happens to the data they take — liberated, sold, or hoarded in
    turn?
13. If everyone has abandoned the real world for the digital one, is their data still
    authentic? Left alone this is a hole; decided on purpose it may be the story's engine.
14. Scope watch, for later: this world implies both a real world and a digital one. How much
    of each actually gets simulated is a scope decision, deferred per DESIGN.md.

Closed 2026-10-11: 13 and 14 belong to the retired virtual world. 11's remainder is in S8, 12's in S2.

## Decision

None yet.
