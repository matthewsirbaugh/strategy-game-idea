# The core idea and story

- Feeds: DESIGN.md open questions 1, 4, 5
- Status: open
- Next action: define how partners use identity and context to change control, information and
  abilities in one battle

## The question

What this game actually is: the seed idea, the world, and the story it carries. Everything
else — mechanics, look, scope, plot, dialogue — grows out of this. It is the first design
activity on the project and nothing has been decided.

## Topic index

This exploration remains open. Bryson asked to save the working ideas on September 21; that
checkpoint is recorded in commit `d3a1f33`. The dated findings below preserve the discussion,
including earlier directions and corrections. Use this index to read by topic; use
[EXPLORATIONS.md](../EXPLORATIONS.md) for what to work on next.

| Topic | Source entries |
|---|---|
| Creative intent and touchstones | [DESIGN.md](../DESIGN.md); [early findings](#findings) |
| Concentrated and distributed power | [Theme](#power-theme) |
| Chibi identity, appearance and permanent pairing | [Partners and counterparts](#partners) |
| Ideological opposition | [Feuding philosophies](#philosophies) |
| Four human–AI relationships | [Relationship structure](#relationships) |
| Physical Operators and network traversal | [Two-map battles](#battle-maps) |
| Hardware, harnesses and post-training | [Local-agent upgrades](#upgrades) |
| Corporate strength and access-point ownership | [Two corporate factions](#corporations) |
| Subsistence, concentrated wealth and human labor | [Society and robotics](#society) |
| Improvised equipment and the board-member source | [Resistance and insider](#resistance) |
| Code names, privacy and manipulation | [Partner knowledge](#identity) |
| Agent recommendations | [Prior evaluation](#agent-evaluation), explicitly advice |
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

The main design risks raised in discussion:

- The two maps need frequent effects on one another or they may feel like separate games.
- Corporate teleportation needs readable limits and counterplay so it feels strategic rather
  than arbitrary.
- "Unsafe" local models need meaningful risk or tradeoffs, rather than being better in every
  respect.
- The partner's agency needs to exist in the controls or information flow, not only in dialogue.
- The hidden source should enable resistance opportunities without becoming the true author of
  the resistance's accomplishments. Bryson's clarification that he supplies information rather
  than money or orders preserves that agency.

## Open questions

### Question guide

The numbered record below includes answered, deferred and rejected questions as well as open
ones. Original numbers are retained for references. This guide groups the unresolved subjects
without making the whole historical list a work queue.

| Subject | Questions in the record |
|---|---|
| Player relationship, trust and change | 17, 19, 20, 21 |
| Agent control, connection and hacking process | 22, 23, 24 |
| Specialization and corporate restrictions | 25, 26 |
| Rival access and corporate model structure | 27, 28 |
| How partners learn their human's identity | 29 |
| Insider's concrete culpability | 30; expressly deferred by Bryson |
| Scope, exploration, loss and permadeath | DESIGN.md questions 1–3 and the parked board topics |

Older question A predates the network-map proposal: agents now traverse a digital map, while
the player's control of them remains open in question 22. Questions 8 and 11–14 refer to the
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
4. Star Trek and Star Wars: the setting or the shape? Answered 2026-09-19, see Findings.
5. What scale does the theme play out at: civilizations, factions, or one person? The shape
   named on 2026-09-19 is a small squad, which narrows the camera but doesn't settle this.
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

22. Does the player directly command an agent on the network map, or give it an objective that
    it interprets?
23. Must an Operator remain near an access point while a hack runs, or does reaching the point
    only launch the agent into the network?
24. What is the hacking process, and how do physical and digital actions interrupt or support
    one another?
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

## Decision

None yet.
