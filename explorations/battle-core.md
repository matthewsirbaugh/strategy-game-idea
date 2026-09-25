# Battle core: turns, fog, network and hacking

- Feeds: [DESIGN.md decisions](../DESIGN.md#decisions); core idea questions 22–25.
- Status: open. Several conclusions graduated to DESIGN.md on 2026-09-23. The battle structure,
  hack resolution and stat axes below are working models, not locked.
- Resume through: [EXPLORATIONS.md](../EXPLORATIONS.md), which owns the current next action.
- Renamed on 2026-09-23 from "Hacking gameplay: repeatable escalating attempts". The minigame
  work this thread started with is [shelved](#shelved-the-hacking-minigame) and kept below for
  its reasoning and research.

## Read this first

On 2026-09-23 Bryson stepped back from a hacking minigame. Hacking exists so the team can use
the environment, complete objectives and gather battlefield information, and it resolves
through stats rather than a minigame. This file now covers the battle as a whole: turn order,
the split human/AI turn, the node network, fog of war and how hacks resolve.

For a cold start, read AGENTS.md, EXPLORATIONS.md, the DESIGN.md decisions, and this file down
to [Open questions](#open-questions). Everything after that is the shelved 2026-09-22 record.
Nothing has been built.

## 2026-09-23 — Stepping back (Bryson, Claude Code chat)

- What hacking is for: the AI hacks so the team can use the environment, capture data and
  complete objectives, and get information on the rest of the battlefield, such as enemy
  weaknesses and locations.
- Hidden information, StarCraft style: the whole map is visible, but only what you have vision
  on is live. Hacks can uncover information, which works thematically.
- Three playable characters with a stable roster, like Persona. The only way to make the player
  care about the story is through the characters, and a small cast means effort goes into fewer
  character models, which suits a solo project.
- Permadeath is off.
- Builds must change tactics. Each character's abilities, gained through the LLM-themed upgrade
  pipelines, are bespoke to that character: one ability theme, many abilities within it that
  synergize in different ways, broad enough that no two players end up with the same playstyle.
- The minigame is out: "There's not room, and I'm not going to replicate a Tetris level
  experience in this, otherwise I would just ship that."
- Between battles, a town or world like Persona: walk around, talk to people, investigate, and
  buy and install upgrades. Start small. Figure out the story that needs telling and build the
  town to explore it, rather than crafting a story to fit a game.

The commitments graduated to [DESIGN.md](../DESIGN.md#decisions). Triangle Strategy, and
Bryson's critique of it, went into the DESIGN.md touchstones.

## 2026-09-24 — The vision sharpens (Bryson, after playing the MVP build)

- "This is actually the first time I've felt genuinely confident this might be a good game." The
  overhead transition added the juice that makes the network layer feel like a real mechanic.
- What the game wants to be: a stealth/cover-shooter-style SRPG, with the network layer allowing
  Watch Dogs-style environmental controls.
- Bryson's caveat: that is far off and contingent on execution. It sharpens the vision; it isn't a
  scope commitment.

## Working model: battle structure

Bryson's first ideas, not locked.

- Normal battles might be 3 against 5.
- Every player and enemy unit has a speed stat that orders a turn queue, as in Triangle
  Strategy.
- The turn splits. A character's human moves, then that character's AI acts. The AI works
  differently from the human movement and environment system but interacts with the physical
  world, acting roughly like half a character.
- The AI map is a network of nodes mapped to network ports on the physical map. The AI moves
  from node to connected node, unconstrained by physical distance. AI turns stay quick; the
  humans carry the traditional SRPG.
- First fog-of-war ability ideas: drop a stationary probe that gives vision of an area; uncover
  an enemy's location; hide your own location; and, as a rare character-specific defense, make
  an enemy that successfully hacks you believe you are somewhere else.

## Working model: hack resolution

Bryson's model, not locked.

- As deterministic as possible, most of the time. Early hacks, and hacks that are easy relative
  to the AI character's level, are basically guaranteed.
- Each hack adds hack points toward the node's goal number. Progress accumulates across turns
  (this carries over rules 4, 6 and 7 from the [shelved record](#brysons-working-rules)).
- Each successful hack fills the agent's context window by some amount.
- When the context window is full, hacks get harder. The chance of success does not drop;
  instead, a smaller percentage of the agent's hack points counts toward the node's goal.
- Context compaction exists as a way to recover. How it works and what it costs are open.
- The grounding: real LLMs pushed to their limits fail more. Hallucination rates rise on
  long-horizon tasks with many steps, when a context window fills, and when parsing something
  particularly difficult, like a legal document.

## Working model: stat axes

Claude's suggestion. Bryson asked to keep it as the working model for how stats will function,
without locking it in.

| Pipeline | Varies |
|---|---|
| Hardware | How much: range, actions, breach speed |
| Harness | How: new verbs and tools |
| Post-training | Specialization, with regressions elsewhere |

## Agent recommendations Bryson agreed with

2026-09-23. Bryson agreed with these; they are recorded as agreed direction, not as locked rules.

- Enemy AI plays by the fog rules and acts only on what it knows. Otherwise hiding and spoofing
  do nothing.
- The network displays as an overlay on the physical map, like a subway map over a city, rather
  than a separate screen.
- Nodes such as cameras are a source of physical vision, which is where the fog and the
  network meet.
- The corporate teleport rule from 2026-09-21 maps directly onto the node network: corporate
  agents move between nodes they own and have to breach the rest.
- The town starts as a single neighborhood. Its final size is decided later.

## 2026-09-23 — Answers for the MVP (Bryson)

1. The tether. The agent runs locally in the backpack, so hacking requires the Operator to stay
   close to the access point. The AI does not "live in" the node. There is a little room to
   move while connected, and the range can be upgraded, but it works as a tether: go too far
   and the agent is pulled out.
2. Compaction uses the AI's action for the turn. Like real compaction, it clears most of the
   context, not all of it.
3. Enemy intentions are hidden. Seeing them could come later as an upgrade, something like
   access to a state-of-the-art prediction algorithm.
4. No enemy hacking in the MVP. In the game, AI-equipped enemies are rare early: a group might
   be 3 humans and 1 AI, and not every human enemy has one. Until the first big boss fight the
   player's AI has the node network almost to itself, so players learn to control it with low
   pressure. After the first boss, most enemies have an AI. The training wheels come off and
   the design can get more creative, because the player has a frame of reference.

The MVP itself is specified in [battle-mvp.md](battle-mvp.md).

## Open questions

Questions 1–4 from the first list were answered above.

5. Does the context window reset between battles, or carry over within a mission?
6. Beyond how full the context is, does a node's difficulty also reduce the share of points
   that count, as the legal-document example suggests? (Claude's reading, not confirmed.)

<a id="shelved-the-hacking-minigame"></a>

## Shelved: the hacking minigame

Everything from here to the end of the file is the 2026-09-22 record, unchanged except for this
note. Bryson shelved the minigame on 2026-09-23. Rules 4, 6 and 7 below carry into the
hack-resolution model; the other rules described the minigame.

- Provenance: Bryson's clarifications, Codex's proposals and web research in the project task
  "Review project status and ideas" (`01a0c148-6d45-7c20-95d2-eea44332b86d`).

### What the minigame thread said first

Bryson wants hacking to be an enjoyable repeatable activity inside a mostly turn-based
strategy role-playing game (SRPG). A tactical turn offers a fresh attempt at a challenge
that becomes harder as play continues. Failure ends the attempt; the next turn starts a
new game, while the target keeps the breach progress already earned.

Tetris illustrates the structure and desired replayability. It is not the chosen minigame.
Codex proposed Packet Press, Ricochet and Loopforge below. Bryson has asked to preserve the
ideas and research, but has not selected or approved any candidate for implementation.
No candidate has been built, run or playtested. Paper reasoning establishes possible
decisions, not fun, balance, accessibility or long-term replayability.

For a cold start, read AGENTS.md, EXPLORATIONS.md and this file. Broader setting detail is in
[the core exploration](core-idea-and-story.md#topic-index); it is optional for comparing these
minigames. Avoid restarting the protagonist interview: Bryson has deferred that work.

## Navigation

- [Inherited context](#inherited-context)
- [Bryson's working rules](#brysons-working-rules)
- [Upgrade examples](#upgrade-examples)
- [Research and its limits](#research-and-its-limits)
- [Packet Press](#packet-press)
- [Ricochet](#ricochet)
- [Loopforge](#loopforge)
- [Comparison and recommendation](#comparison-and-recommendation)
- [Evaluation criteria](#evaluation-criteria)
- [Unresolved choices and resumption](#unresolved-choices-and-resumption)
- [Source register](#source-register)

## Inherited context

- Humans carry local AI partners in backpack-sized hardware and approach access points to
  hack data caches or physical devices such as doors and autonomous cars.
- Local hardware, harnesses and post-training provide possible progression and specialization.
  The two powerful corporate factions have native access to their own infrastructure and
  slower breaches against each other's points. Detailed integration remains open.
- The parallel traversable network map is a candidate structure, not a fixed requirement.
  Bryson is willing to refine it or use a substantially different kind of gameplay for agents.
- The world and basic premise are enough to proceed with mechanics. Protagonist, personal
  mission motives and further thematic/story development are on the back burner.
- Existing human–AI relationship types already supply the characterization foundation.
- Engine, input platform, art pipeline and architecture remain undecided. Models and training
  describe the fiction and progression; no decision requires running real language models.
- About ten hours a week and the existing AI-subscription budget are inherited constraints.
- This is concept exploration. AGENTS.md requires conceptual narrowing before construction.

## Bryson's working rules

These are Bryson's explicit clarifications, not Codex's choice of a candidate implementation.

1. Hacking should be enjoyable in itself, with players looking forward to doing it again.
   Repetition must support continued engagement and improvement, rather than become a chore.
2. Short bursts of real-time play inside the otherwise turn-based game are a possibility.
   Bryson likes that broad shape but dislikes bullet hell.
3. Within an attempt, the activity becomes progressively harder. A skilled player can earn
   much more progress before failure than a less-skilled player.
4. A target has a total breach requirement. Progress earned during separate attempts adds up.
5. Failure ends the hacking challenge for that turn. The next available turn permits a fresh
   game with reset board/challenge state and difficulty. Do not resume the failed board.
6. The target's accumulated breach progress survives failure. Failure costs another tactical
   turn, rather than erasing completed work.
7. Reaching the remaining requirement completes the hack during that attempt.
8. Agent-specific active or passive boosts and training tradeoffs are a proposed direction
   Bryson wants explored; exact powers and numbers are not settled.

### Bryson's illustrative Tetris example

A door requires 50 lines in total. The numbers are examples, not balance targets:

| Performance | Accumulated progress | Turns |
|---|---|---:|
| 10 lines, then 40 | 10 → 50 | 2 |
| About 15 lines per attempt | 15 → 30 → 45 → 50 | 4 |
| 50 in one attempt | 50 | 1 |

The distinction is between losing an attempt and being permanently unable to open the target.
A lower-skill player can make progress across attempts. Whether spending more turns is
dangerous depends on the encounter. No extra failure penalty or permanent lockout was agreed.

## Upgrade examples

Bryson suggested an agent that can slow time for three seconds once. Training could increase
duration or number of uses, with a cost such as starting at a higher difficulty or needing
55 progress instead of 50. These illustrate specialization, not selected powers or prices.
He also raised the broader possibility of a harder hacking activity completing in fewer turns.

Unresolved: whether limited ability charges refresh per attempt, per target, per battle or
otherwise. Resetting the game after failure does not settle that question.

Codex suggested two optional distinctions:

- Hardware could change useful breach progress produced by performance, while training changes
  tools inside the activity. This division has not been adopted.
- An aggressive hacking mode could trade difficulty for speed without every hardware upgrade
  automatically making the minigame harder. This is advice, not a rejection of Bryson's example.

## Research and its limits

Research gathered on 2026-09-22. Source facts, designer testimony and our inferences are
separated here. The source register provides direct links, provenance and reading locations.
"Best" means useful lessons for this project, not a measured ranking of all hacking games.

| Reference | Supported observation | Codex's proposed lesson |
|---|---|---|
| Tetris [R1](#r1) | Pajitnov describes simplicity and the pleasure of building arrangements from incoming pieces. | Choices should visibly shape the next problem; completion should create relief and room for a new plan. A rising meter alone misses this. |
| Bricktopia / Breakout [R2](#r2) | A practitioner analysis discusses paddle control variables, fair misses, power-up decisions and measurement during testing. | Readable control is fundamental. Players should be able to attribute outcomes to their decisions and execution. |
| Shatter [R3](#r3), [R4](#r4) | Developers addressed limited interaction and the final-brick problem, and offered optional extra balls for risk and faster progress. | Avoid idle waiting and tedious cleanup; mastery can unlock productive risk. Do not copy multiball wholesale given Bryson's taste. |
| Holedown [R5](#r5) | Its creator shaped generated layouts around satisfying shots into pockets, adjusted pacing through testing, and shortened overly long early sessions. | Arrange opportunities for deliberate setup and payoff; measure actual duration as well as tactical turns. |
| Skyrim [R6](#r6) | A pick nearer the correct angle permits more lock rotation before breakage. | Inputs should give useful feedback before failure. A hidden-angle search alone appears too narrow for the desired repeated mastery. |
| Deus Ex: Human Revolution [R7](#r7) | Networks contain directional routes, optional rewards, fortification and a pursuing security process. | Borrow competing priorities and a spatially understandable threat. Its finite destination would need adaptation to renewable play. |
| BioShock [R8](#r8) | Players uncover and swap pipe tiles to route a moving flow, with hazardous pieces. | Building ahead of a moving deadline combines prediction and recovery. A finite puzzle is not automatically an endless score game. |
| BioShock 2 interview [R9](#r9) | Its creative director reports that even fans tired of the original hacking, prompting a different relationship with the surrounding game. | Test repetition and interruption cost. This shooter example does not establish that pausing a turn-based game is wrong. |
| Starfield [R10](#r10) | Players fit rotatable configurations into rings of gaps; complexity and assists vary. | A piece fitting somewhere now is not enough to justify spending it there. Repeated isolated locks could still become routine worksheets. |
| Motivation research [R11](#r11) | Four studies associate perceived competence and autonomy with enjoyment and preference for further play. | Look for felt mastery and meaningful choice. Association does not prove a particular new mechanic will be fun. |
| Tetris difficulty study [R12](#r12) | A 77-participant study reports highest flow and positive affect in its optimal-difficulty condition. | Escalation needs to fit player skill. "Faster forever" is not a complete explanation of enjoyment or retention. |

### Synthesis: recommendations, not additional requirements

- Create a renewable source of decisions, not only progressively shorter reaction windows.
- Let prior choices shape future opportunities and problems.
- Give readable warnings, useful feedback and recoverable mistakes before terminal failure.
- Bank useful accomplishments rather than requiring an entire stage to be completed.
- Start fresh attempts promptly; repeated openings must not become a long compulsory warm-up.
- Vary openings without letting randomness decide whether useful progress is possible.
- Test both the standalone activity and its repeated use inside a tactical battle.

## Candidate designs

All three are Codex proposals. Working names are labels, not selected titles or claims of
uniqueness. All end immediately when the remaining target quota is reached. Otherwise they
continue with escalating pressure until failure. Their numerical scales require playtesting.

### Packet Press

**Activity:** four kinds of data packets arrive on a conveyor, distinguished by shape and
color. Three small buffers each hold one packet type at a time. The player places packets,
then chooses a batch to transmit. Sending clears that buffer and banks progress; a shared
transmitter must recharge before another batch can go. A batch of four uses the same dispatch
cycle as one packet, so batching improves throughput but ties up scarce storage.

**Decision:** take progress and free space now, or retain a batch while preparing for incoming
traffic? A visible preview makes this a planning problem as well as a timed activity.

**Paper example:** capacity four per buffer, current contents `AA | BBB | C`; the next packets
are `D, A, B`, all arriving before another dispatch can be made.

- Sending `BBB` earns three progress immediately. D takes the empty buffer, A fits its existing
  buffer, but the incoming B has no matching buffer available.
- Sending `C` earns only one immediately but accommodates all arrivals: `AAA | BBBB | D`.

This demonstrates an opportunity cost under those timing assumptions. If an incoming queue
has spare capacity, the greedy choice need not cause immediate failure; it still creates
backlog. It proves neither enjoyable controls nor repeated fun.

**Escalation/failure:** arrivals accelerate. A short incoming queue supplies recovery room;
overflow ends the attempt. Empty buffers, fresh traffic and starting speed return next turn.
All previously transmitted progress remains on the target.

**Possible abilities:** temporarily allow mixed packet types in one buffer; reveal more upcoming
packets but increase transmitter recharge time; pause arrivals briefly with a higher breach
requirement. Exact costs and refresh rules remain open.

**Expected appeal:** anticipate traffic, convert congestion into order, release a satisfying
batch, and improve through scheduling rather than input speed alone.

**Risks/rejection tests:** sorting may feel like office work. If matching symbols and clearing
the fullest buffer usually succeeds, the planning depth is weak. Cooldown and arrival timing
must be immediately legible. Three packet types and three buffers would allow permanent type
assignments; the four-type/three-buffer mismatch is intentional.

### Ricochet

**Activity:** a compact single-ball paddle game with firewall blocks advancing toward the
player. Some blocks visibly support connected sections. Breaking a support collapses its
section and credits the destroyed blocks. Paddle contact controls the return angle. The player
can catch the ball on a return and briefly aim again while the firewall continues advancing.

**Decision:** make easy, safe returns for modest progress or spend space/time arranging a
difficult shot through a gap to a valuable support? Good geometry should produce intentional
large payoffs rather than rewards determined chiefly by lucky bounces.

**Escalation/failure:** new barriers arrive; encroachment and ball speed increase pressure.
Losing the ball or letting a barrier cross the bottom boundary ends the attempt. The next
turn resets field, ball and starting pace. Destroyed-block progress remains banked.

**Possible abilities:** a shot that penetrates the first barrier at the cost of a narrower
paddle; brief ball slowdown at the cost of a larger target quota. Values are illustrative.

**Expected appeal:** recognize an opening, execute the shot, watch a larger structure collapse,
then recover control. Continuous new targets plus a quota avoid requiring the final isolated
brick to be hunted down. One ball preserves legibility without bullet-hell dodging.

**Risks/rejection tests:** reject or revise if lucky ricochets dominate deliberate aiming, if
players routinely wait for useful contact, or if support relationships are unclear before the
shot. Reliable paddle/aim behavior and readable collisions require careful tuning. Adding many
balls would obscure the intended precision and may conflict with Bryson's preference.

### Loopforge

**Activity:** a small board contains data symbols. Straight and corner circuit pieces arrive
in a visible limited queue. The player rotates and places pieces into closed loops. A closure
captures the data inside, banks progress and clears the circuit and enclosed space. New data
appears in cleared areas so the activity can continue. Empty loops earn no progress.

**Decision:** close a small circuit for progress and workspace now, or extend it around more
data while unfinished construction consumes space and the queue keeps filling?

**Escalation/failure:** pieces arrive increasingly quickly. Queue overflow ends the attempt.
A fresh board, queue and starting pace return next turn; captured data remains credited.

**Possible abilities:** temporarily make a piece a universal connector, with a smaller incoming
queue as the cost; move one placed piece, with an increased target requirement as the cost.

**Expected appeal:** construct a shape of one's own, recognize efficient enclosures, reclaim a
crowded board, and turn earlier unfinished plans into later opportunities.

**Risks/rejection tests:** this candidate has the most unresolved rules work. Exact placement,
enclosure geometry, data replenishment and piece supply are not specified. Reject or revise if
repeating tiny loops always dominates, if the queue withholds necessary pieces, or if assembly
feels fiddly. Upcoming-piece visibility and a controlled piece supply are necessary hypotheses,
not proof of solvability or fun. Larger enclosures need useful efficiency rather than an
arbitrary reward multiplier doing all the work.

## Comparison and recommendation

| Candidate | Core skill | Failure | Expected payoff | Main uncertainty |
|---|---|---|---|---|
| Packet Press | Scheduling, preview reading, storage management | Incoming queue overflows | Clear a batch and untangle congestion | Planning versus routine sorting |
| Ricochet | Aiming, prediction, recovery | Lost ball or barrier reaches boundary | Deliberate shot collapses a structure | Skill versus luck; control feel |
| Loopforge | Spatial construction, foresight, space management | Piece queue overflows | Close a large circuit and reclaim space | Fair piece supply; dominant small loops |

Codex recommended exploring Packet Press and Ricochet first as contrasting experiences:
thinking under pressure versus deliberate action and destruction. Loopforge remains an option
if constructing and clearing a board is the desired attraction. This is not Bryson's selection.
These are alternatives, not a proposal to build three minigames for the finished game.

## Evaluation criteria

Suggested checks, not an adopted testing policy or authorization to implement:

1. Can a newcomer explain a failure and deliberately improve on the next attempt?
2. Can better decisions beat merely faster input?
3. Does an agent boost change a plan, create an opportunity or recover a mistake?
4. Without the door reward, does the player voluntarily want another attempt?
5. Does that interest survive later sessions and repeated hacks inside tactical encounters?
6. Does a skilled player earn more per turn without creating excessively long real-time turns?

Repeated modest attempts are intentional, not an exploit. A separate concern is whether
deliberately ending runs early yields the best real-time progress with negligible tactical
cost. Compare shallow and sustained runs before inventing a punishment.

The quota ends an attempt successfully, but does not guarantee a short session. Measure actual
duration alongside breach progress, tactical turns, failure causes and voluntary replay.
These are observations to make in a future bounded prototype, after Bryson narrows a concept.
No formal duration target, scoring curve, input device or accessibility approach is chosen.

## Unresolved choices and resumption

The last unanswered question presented to Bryson was which imagined moment appeals most:
untangling packet traffic, landing a firewall-collapsing shot, or closing a large circuit
before the board jams. He requested this save instead of choosing.

Continue by comparing the experiences, refining a candidate or considering a new proposal.
Do not treat the save request as approval to choose a winner, build all three, or begin code.

Questions to resolve as they become relevant:

- Which activity, if any, should be narrowed toward a prototype?
- How do active/passive boosts recharge, and which tradeoffs feel worthwhile?
- How much real time should a typical attempt and a skilled attempt occupy?
- How do varied targets alter meaningful decisions rather than only quotas?
- How does a hack relate to the digital map, physical exposure and Operator actions?
- Does an Operator need to maintain proximity/connection throughout the hack?
- How does player execution coexist with the fictional agent's autonomy and specialization?
- How are enemy hacking attempts resolved, and how do corporate strengths and slower windups
  translate into this activity?

## Source register

Direct sources gathered during the preceding research discussion on 2026-09-22, preserved
here rather than freshly rechecked for this save. Summaries above are short paraphrases.
Manuals establish mechanics; designer interviews report development experience; research
papers offer limited empirical evidence. None validates our unbuilt candidates.

<a id="r1"></a>

- **R1 — Tetris creators Alexey Pajitnov and Henk Rogers, CNN interview (2009).** Primary
  interview transcript; find Pajitnov's explanation of simplicity and constructing arrangements.
  [Transcript](https://transcripts.cnn.com/show/smn/date/2009-06-13/segment/01).

<a id="r2"></a>

- **R2 — Mark Nelson, Breaking Down Breakout: System and Level Design for Breakout-style
  Games (2007).** Practitioner article from a LEGO Bricktopia level designer, including
  developer interviews. Read paddle controls, power-ups, and testing sections.
  [Article](https://www.gamedeveloper.com/design/breaking-down-breakout-system-and-level-design-for-breakout-style-games).

<a id="r3"></a>

- **R3 — Sidhe interview on Shatter, TheSixthAxis (2009).** Primary developer interview;
  discussion of limited interaction, static fields, last-brick frustration and prototyping.
  [Interview](https://www.thesixthaxis.com/2009/07/21/interview-sidhe-on-shatter/).

<a id="r4"></a>

- **R4 — Sidhe developer Q&A on Shatter, Digital Chumps (2009).** Primary developer answers
  on controls and voluntarily launching more balls for increased risk, multiplier and speed.
  [Q&A](https://digitalchumps.com/2009/07/22/sidhe-developer-qanda-on-shatter-for-psn/).

<a id="r5"></a>

- **R5 — Martin Jonasson on Holedown, interview by Joel Couture (2018).** Primary developer
  account; pocket shots, generation, long early sessions and upgrade complexity.
  [Interview](https://www.gamedeveloper.com/design/the-ins-and-outs-of-bouncing-balls-in-the-joyful-brick-breaker-i-holedown-i-).

<a id="r6"></a>

- **R6 — Bethesda, Skyrim PC manual.** Official documentation, printed p. 14, Lockpicking.
  [Manual](https://cdn.akamai.steamstatic.com/steam/apps/72850/manuals/skyrim_gfw_manual-07.pdf).

<a id="r7"></a>

- **R7 — Deus Ex: Human Revolution — Director's Cut PC manual.** Official documentation,
  printed pp. 12–14, Hacking. Do not silently substitute mechanics from Mankind Divided.
  [Manual](https://cdn.akamai.steamstatic.com/steam/apps/238010/manuals/DXHR-DC_PC_MAN_EN.pdf).

<a id="r8"></a>

- **R8 — BioShock PC manual.** Publisher documentation, printed p. 26, hacking pipe flow.
  [Manual](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/7670/manuals/manual_en.pdf).

<a id="r9"></a>

- **R9 — Jordan Thomas, BioShock 2 interview, GamesBeat (2010).** Primary creative-director
  interview; find the question about the hacking minigame and fatigue with the original.
  [Interview](https://gamesbeat.com/bioshock-2-interview/).

<a id="r10"></a>

- **R10 — Bethesda, Hacking — Systems — Starfield.** Official support explanation of ring
  gaps, rotating configurations, lock complexity and auto-attempts.
  [Guide](https://help.bethesda.net/app/answers/detail/a_id/61029/~/hacking---systems---starfield).

<a id="r11"></a>

- **R11 — Ryan, Rigby and Przybylski (2006), The Motivational Pull of Video Games: A
  Self-Determination Theory Approach.** Four studies; DOI 10.1007/s11031-006-9051-8.
  [Author-uploaded paper](https://www.researchgate.net/publication/225998888_The_Motivational_Pull_of_Video_Games_A_Self-Determination_Theory_Approach).
  The authors' later synthesis was also consulted:
  [A Motivational Model of Video Game Engagement (2010)](https://selfdeterminationtheory.org/SDT/documents/2010_PrzybylskiRigbyRyan_ROGP.pdf).

<a id="r12"></a>

- **R12 — Harmat et al. (2015), Physiological correlates of the flow experience during
  computer game playing.** DOI 10.1016/j.ijpsycho.2015.05.001. The reported abstract compares
  easy, optimal and difficult Tetris conditions in 77 participants. Limited laboratory evidence,
  not a retention study; the publisher page was not consistently retrievable during research.
  [Publisher record](https://www.sciencedirect.com/science/article/pii/S0167876015001683).

## Decision

2026-09-23: the minigame is shelved. Hacking is resolved through stats, and its role (use the
environment, complete objectives, gather information) graduated to
[DESIGN.md](../DESIGN.md#decisions) along with fog of war, three characters, no permadeath and
the town. The battle structure, hack resolution and stat axes remain working models. The
exploration stays open.
