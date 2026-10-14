# Tactics-genre fundamentals vs our rules: gap analysis

Local sources read: [RULES.md](/Users/sirbryson/Documents/Strategy%20Game%20Idea/RULES.md) (V1, all of it) and [DESIGN.md](/Users/sirbryson/Documents/Strategy%20Game%20Idea/DESIGN.md) (Touchstones, Decisions). Rule numbers below (R1–R53) are RULES.md's numbered rules. "Basic" = every tactics game has to define this; "Optional" = a design idea the genre uses, not a requirement.

Source caveat: Subset's GDC 2019 postmortem and Jake Solomon's RPS interview could not be read directly (Vault is members-only; only secondhand coverage found). Several wiki pages were unreachable. Claims marked "(no source fetched)" in Inferences are from general genre knowledge and should be verified before they're relied on.

## How do reference games handle cover/elevation, flanking, terrain, LOS, interrupts, intent telegraphing, enemy roles, hazards/pushes, objectives, turn structure and determinism?

### Takeaway
The genre's positional systems (cover, flanking, height) mostly exist to modify hit chance or damage; in a no-HP, always-hit, always-stun game they have to be re-expressed as modifiers to *being seen* and *line of fire*. The systems that transfer directly are telegraphing (ITB, Fire Emblem danger zones, Slay the Spire intents), escalation pressure (Invisible Inc alarm, ITB spawns/turn limits), and free action ordering (Mario + Rabbids, Gears, Hard West 2), which we already have.

### Cited Findings
**Telegraphing / perfect information**
- Into the Breach: Vek display intended attack direction, movement range and remaining health; new Vek appear after each turn; players can push a Vek "off a line of attack" — [Wikipedia](https://en.wikipedia.org/wiki/Into_the_Breach)
- ITB is sold on "all enemy attacks are telegraphed"; the player analyzes the attack and finds the counter every turn — [Game Developer / Road to the IGF and reviews, via search](https://gamedeveloper.com/game-platforms/road-to-the-igf-subset-games-i-into-the-breach-i-); [Indie Game Reviewer](https://indiegamereviewer.com/into-the-breach-review-pacific-rim-meets-minesweeper/)
- ITB lets the player check the order of enemy attacks by hovering the top-right icon or holding Alt — [KosGames beginner guide](https://kosgames.com/?p=5557)
- Matthew Davis: "Part of our vision for Into the Breach is a push to be more deterministic in the moment-to-moment gameplay," contrasting with XCOM-era reliance on chance; randomness moved to modifiers (e.g., a tsunami submerging a column each turn) and to squad/run setup — [PC Gamer preview, via search summary](https://pcgamer.com/into-the-breach-preview)
- Fire Emblem Three Houses/Engage: hovering an enemy shows its movement and attack range; one button shows the combined danger area of all enemies; Engage draws red lines from enemies to the unit they'd target as you move — [SuperCheats](https://www.supercheats.com/fire-emblem-three-houses/walkthrough/danger-radius); [Prima Games](https://primagames.com/tips/how-to-see-enemy-targeting-in-fire-emblem-engage)
- Engage's targeting lines are not a guarantee of what the enemy will do — [Prima Games](https://primagames.com/tips/how-to-see-enemy-targeting-in-fire-emblem-engage)
- Player criticism of tactics UIs: enemy range should be on the map, not require reading speed stats and counting tiles — [itch.io comment](https://itch.io/post/8015328)
- Slay the Spire: every enemy shows an intent icon (attack, debuff, combined) with numbers; StS2 places multiple intents side by side for legibility; the game offers "almost full information" — [StS wiki data](https://slaythespire.wiki.gg/wiki/Module:Enemies/data); [Untapped StS2 guide](https://sts2.untapped.gg/guides/how-to-read-enemy-intent)
- Chained Echoes' Overdrive bar shows a second arrow previewing where the chosen action will move the gauge — [SI Videogames guide](https://videogames.si.com/guides/chained-echoes-tips-combat-overdrive-sky-armor)

**Cover, flanking, elevation**
- XCOM EU: fixed cover bonuses (25% half, 50% full) made cover the default survival tool; a perfect flank could still fail; Mario + Rabbids lets shots damage cover so pressure continues — [Game Developer, "A Deep Dive Into XCOM and XCOM 2"](https://www.gamedeveloper.com/design/a-deep-dive-into-xcom-and-xcom-2)
- Mario + Rabbids: half cover halves hit chance, full cover blocks; most cover is destructible; height gives a damage bonus and wider view; dash attacks by moving through enemies; team jump to reach heights — [Red Bull guide / reviews via search](https://redbull.com/ca-en/mario-rabbids-tips); [GameSpot review](https://gamespot.com/reviews/mario-rabbids-kingdom-battle-review/1900-6416743/)
- XCOM cover is directional: fire from in front of the cover line is protected, fire from behind it is a flank (informal community description) — [Steam discussion via search](https://steamcommunity.com/app/200510/discussions/0/617335934138804041)
- XCOM "peek": a unit behind low/no cover can step out to an adjacent tile for LOS; high cover blocks peeking; stepping out shifts the vision center and can trigger pods — [UFOpaedia, Line of Sight (EU2012)](https://ufopaedia.org/Line_of_Sight_(EU2012))
- XCOM diagonal objects (lampposts, UFO diagonal walls) are documented exceptions; diagonal cover is the weakest-documented area — [UFOpaedia](https://ufopaedia.org/Line_of_Sight_(EU2012))
- Triangle Strategy: higher ground increases damage and attack range; back attacks are guaranteed crits; an ally behind the target triggers an automatic follow-up; Kudos reward follow-ups, height and attacks from outside enemy range — [Samurai Gamers](https://samurai-gamers.com/triangle-strategy/how-to-earn-kudos/); [RPGFan](https://www.rpgfan.com/2022/02/19/triangle-strategy-prologue-demo-impressions/); [everyeye.it](https://www.everyeye.it/articoli/guida-trucchi-triangle-strategy-esclusiva-nintendo-switch-56643.html)

**Interrupts / overwatch**
- Gears Tactics: overwatch is a cone dragged by the player — farther = wider, less accurate; players see enemy overwatch zones; a pistol ability can pull an enemy out of overwatch — [PC Gamer](https://www.pcgamer.com/uk/gears-tactics-is-a-shockingly-good-strategy-game)
- Gears Tactics: swarm enemies (Wretches) are designed to soak overwatch, leaving tougher enemies free; emergence holes add enemies each turn until closed — [PC Gamer](https://www.pcgamer.com/uk/gears-tactics-is-a-shockingly-good-strategy-game)
- XCOM 2 Chosen became immune to overwatch, removing the player's main lockdown tool with no replacement — [Game Developer](https://www.gamedeveloper.com/design/a-deep-dive-into-xcom-and-xcom-2)
- XCOM 2 concealment play: move into position, set most of the squad on overwatch, then take the first shot — [Game Informer](https://gameinformer.com/games/xcom_2/b/pc/archive/2015/12/10/xcom-2s-board-game-influences-and-the-race-against-the-alien-clock)

**Action economy**
- XCOM: attacking ended the turn; Mario + Rabbids let actions be ordered freely, adding choices — [Game Developer](https://www.gamedeveloper.com/design/a-deep-dive-into-xcom-and-xcom-2)
- Gears Tactics: three freely split actions instead of XCOM's two; executions grant a bonus squad action — [Vice](https://www.vice.com/en/article/gears-tactics-preview-interview); [PC Gamer](https://www.pcgamer.com/uk/gears-tactics-is-a-shockingly-good-strategy-game)
- Hard West 2 Bravado: shooting doesn't end the turn; a kill fully refills the character's 3 AP, enabling chain kills; a miss can collapse the plan — [Gaming Nexus](https://www.gamingnexus.com/Article/7641/Hard-West-2/); [Prima Games](https://primagames.com/featured/hard-west-2-review-pc)
- Jake Solomon on dropping time units: players weren't considering the squad as a whole and how abilities related — [via search summary of Solomon interviews](https://www.usgamer.net/articles/interview-the-death-of-interceptors-iron-man-mode-and-xcom-2s-next-step)

**Escalation / time pressure**
- ITB: each map has a fixed number of turns to complete its objective; the turn counter was used to keep battles short (vs an hour in XCOM), and telegraphing further sped play — [Wikipedia](https://en.wikipedia.org/wiki/Into_the_Breach)
- Invisible Inc: alarm level rises after the player's turn in most locations; higher levels add guards/threats; detection or daemon segments fill the tracker faster; alarm can bring new guards, extra cameras, or raise hacking costs — [Wikipedia](https://en.wikipedia.org/wiki/Invisible,_Inc.); [GameStar](https://www.gamestar.de/artikel/invisible_inc,3086028.html); [Nintendo World Report](https://nintendoworldreport.com/review/54129)
- Invisible Inc: killing raises alarm instantly; KOs are temporary, after which guards search — [Steam review](https://steamcommunity.com/id/netcoder1/recommended/243970?l=romanian); [Invisible Inc wiki archive](https://invisibleinc-archive.fandom.com/wiki/General_Tips)
- Invisible Inc community: alarm level 2 is the major deadline (firewalls go up), so hacking should be done before it — [Nintendo World Report / forum guide via search](https://forums.kleientertainment.com/forums/topic/59447-beginner-experienced-jump-tips/)
- XCOM 2 objective timers made non-progressing actions (hunker down) feel bad — [Game Developer](https://www.gamedeveloper.com/design/a-deep-dive-into-xcom-and-xcom-2)

**Pushes and hazards**
- ITB: push attacks move enemies off their attack line or into objects/other units for collision damage; pushing into water drowns; bump chains — [Indie Game Reviewer](https://indiegamereviewer.com/into-the-breach-review-pacific-rim-meets-minesweeper/); [ITB wiki, Alpha Bouncer](https://intothebreach.fandom.com/wiki/Alpha_Bouncer)
- ITB: collateral damage matters — mechs draw power from buildings, losing grid fails the run; Ma wanted to avoid "the whole city gets demolished, but no one cares" — [Wikipedia](https://en.wikipedia.org/wiki/Into_the_Breach)
- ITB islands have environmental conditions; more hazardous islands give more reward — [Wikipedia](https://en.wikipedia.org/wiki/Into_the_Breach)
- Invisible Inc: laser beams that kill vs stun vs infrared beams that only raise alarm, labeled differently — [Steam discussion](https://steamcommunity.com/app/243970/discussions/0/617336568086845807)

**Objectives**
- ITB levels mix protect, retrieve, avoid and destroy objectives — [Indie Game Reviewer](https://indiegamereviewer.com/into-the-breach-review-pacific-rim-meets-minesweeper/)
- ITB's main goal is protecting civilian structures, with bonus objectives on top — [Wikipedia](https://en.wikipedia.org/wiki/Into_the_Breach)

**Enemy variety / AI**
- XCOM: enemy types with hard-coded behavior and no individual variation made fights repetitive once the squad was strong; "inverse arms race" difficulty curve — [Game Developer](https://www.gamedeveloper.com/design/a-deep-dive-into-xcom-and-xcom-2)
- XCOM pod activation (pods scramble to cover on reveal, chain-triggering) discouraged scouting — [Game Developer](https://www.gamedeveloper.com/design/a-deep-dive-into-xcom-and-xcom-2)
- Invisible Inc endless mode: armored guards make weapons useless; daemons grant guards armor/KO resistance — [Steam guide via search](https://steamcommunity.com/app/243970/discussions/0/35222218567856273)
- Fire Emblem enemies that hold position until you enter range; bosses that don't move — [Prima/guides via search](https://primagames.com/tips/how-to-see-enemy-targeting-in-fire-emblem-engage)

### Inferences
- Cover, flanking and height in reference games all modify hit/damage odds. Ours has no odds (R9, R32, R34), so their only possible currency is perception: whether a cone tier reaches you, and whether a line of fire exists. That is the translation for every positional idea below.
- Our action economy (free interleaving, shot doesn't end turn, R3–R4) already matches the modern consensus (Mario + Rabbids, Gears, Hard West 2). The refund chain (R6) is Hard West 2's Bravado for the AI half: a reward for a decisive action that refills AP. Hard West's lesson — one miss collapses the chain — doesn't apply to us since hacking never fails; the brake is context (R8), which is the right deterministic substitute.
- Our turn structure is nominally initiative-based (R1, speed order), but with Operators at 6 and guards at 5 and team-first ties, the team always acts before guards: functionally side-based, with robots and the turret (3) slotting in. Speed only becomes a real lever once enemy types have different speeds (e.g., a speed-8 drone acting before the team).
- Our aim line (R31) is already an ITB-grade telegraph: a fixed line, a full turn to respond, fire first next turn, hits the first unit in the line (which is exactly ITB's body-block). The genre-standard gap is that *patrol* movement is not telegraphed by default — Predict (V1 chips) exists precisely because it isn't.

### Gaps
- Exact numbers for Triangle Strategy height bonus and Mario + Rabbids height bonus not found.
- Advance Wars (terrain defense stars, fog of war) and Tactics Ogre (Wait/RT initiative) rules: not researched in this pass; no sources fetched.
- Chimera Squad's Breach phase and interleaved initiative timeline: not researched; known to be an interleaved-initiative game (no source fetched).
- Chained Echoes red-zone damage figure conflicts between guides (+25% vs double damage) — [SI](https://videogames.si.com/guides/chained-echoes-tips-combat-overdrive-sky-armor) vs other guides in search.
- No source found on how many enemy types a first level should introduce.

## Into the Breach: which design rules make a deterministic tactics game feel like a puzzle, and which do we lack?

### Takeaway
The publicly confirmed ITB pillars are: determinism in the moment, full telegraphing of every enemy action including order, small board (8×8), few units (3 mechs), a per-map turn limit, constant pressure from new spawns, and a stake beyond your own units (the power grid). We have determinism, a telegraphed aim and a small squad; we lack default telegraphing of guard movement, any time/escalation pressure, and a stake that makes the clean solution matter beyond "don't get seen."

### Cited Findings
- 8×8 board, 3 mechs, each mech moves and fires once per turn — [Wikipedia](https://en.wikipedia.org/wiki/Into_the_Breach); [Indie Game Reviewer](https://indiegamereviewer.com/into-the-breach-review-pacific-rim-meets-minesweeper/)
- Fixed turns per map; turn counter + telegraphing chosen to keep battles short — [Wikipedia](https://en.wikipedia.org/wiki/Into_the_Breach)
- Determinism in moment-to-moment play; randomness lives in setup and modifiers — [PC Gamer, Davis](https://pcgamer.com/into-the-breach-preview)
- Telegraphed enemy direction, range, health; attack order viewable — [Wikipedia](https://en.wikipedia.org/wiki/Into_the_Breach); [KosGames](https://kosgames.com/?p=5557)
- New Vek emerge after each turn — [Wikipedia](https://en.wikipedia.org/wiki/Into_the_Breach)
- Defense over offense: "this game was about defense, not offense"; finale should test skills already learned, not "something brand new" — [Game Developer](https://www.gamedeveloper.com/business/how-subset-games-made-the-jump-from-i-ftl-i-to-i-into-the-breach-i-)
- Build one small piece at a time, each fun and playable immediately — [Game Developer](https://www.gamedeveloper.com/business/how-subset-games-made-the-jump-from-i-ftl-i-to-i-into-the-breach-i-)
- GDC 2019 postmortem (Davis) covered cutting features, stealing design elements, choosing difficulty, and "how much RNG should you use?" — content not accessible — [GDC](https://www.gdconf.com/news/get-inside-look-making-breach-gdc-2019); [GDC Vault](https://gdcvault.com/play/1025772/-Into-the-Breach-Design)
- Davis and Ma came close to abandoning the game; combat came first, then years on the meta-game — [Kotaku](https://kotaku.com/the-creators-of-into-the-breach-came-very-close-to-givi-1833498295)

### Inferences
Checklist, ITB pillar vs ours:

| ITB pillar | Ours | Status |
|---|---|---|
| Deterministic resolution | R9, R32, R34: hacks never fail, shots always hit, no HP | Have |
| Every threat telegraphed | Aim line (R31), cones (R23), move-tile marking (R24), sound preview (R18) | Partly: guard *movement* hidden unless Predict |
| Action order visible | Turn order bar (R1) | Have, but within-enemy-phase order among guards (all speed 5) undefined |
| Small board | Not specified anywhere in RULES.md | Undefined |
| Few units | 3 Operators + robots | Have |
| Time pressure | R22: no battle-wide clock | Missing (deliberate) |
| Escalation (spawns) | None; guards are finite, tied-up guards are permanent (R35) | Missing |
| A stake beyond your units | Stealth itself (alerts, caution R29) | Partial |
| Displacement verbs (push) | Only vehicles (Devices: car "until it hits something") | Mostly absent |
| One reset per battle | R4: no undo in V1 | Missing (ITB has a once-per-battle Reset Turn — no source fetched) |

- Biggest structural difference: ITB's puzzle is "solve this turn, then the board gets worse." Ours, with no clock (R22) and finite, permanently removable guards (R35), is "the board only gets easier." Without some pressure, the dominant strategy is patience: wait for the ideal patrol alignment, lure-overwatch-tie-up (the loop the Overwatch definition itself describes) until the map is empty. That is the opposite of a puzzle. Invisible Inc solves exactly this in the stealth genre with the per-turn alarm tracker.
- Second difference: ITB shows what every enemy will do; ours hides patrol paths by default and sells the information as the Predict chip. That can be good (information as a resource is the AI's role per DESIGN.md "Hacking … gathering battlefield information"), but then the *baseline* must still be readable: at minimum facing after the move, or the patrol route as a static line. Otherwise the player plans against hidden variables and the game drifts from "puzzle" to "guess."

### Gaps
- Could not confirm whether the GDC talk explicitly stated "perfect information" as a rule; this phrase appears only in aggregator summaries.
- ITB's Reset Turn, attack-order numbering on enemy icons, and "units block spawn tiles" rules are well known but not confirmed in fetched sources.

## What do our rules NOT yet say that every tactics game must define?

### Takeaway
RULES.md defines the *systems* thoroughly but leaves most of the *grid geometry* and *edge-case resolution* undefined: the distance metric, diagonal LOS and corners, what blocks sight vs shots vs movement, occupancy, friendly fire, guard tie-breaking, and what enemies do when they can't reach a target. These are true basics; an implementation currently has to guess them.

### Cited Findings
- XCOM needed explicit rules for peeking around corners, center-to-center LOS, low vs high cover blocking peeks, and diagonal-object exceptions — [UFOpaedia](https://ufopaedia.org/Line_of_Sight_(EU2012))
- Gears Tactics AI plans each unit in sequence, later units seeing earlier units' plans, then executes the whole enemy turn; the AI deliberately does not account for player overwatch/mines — [Unreal Engine developer interview](https://www.unrealengine.com/developer-interviews/gears-tactics-uses-the-gears-formula-brilliantly-to-offer-a-fresh-tactical-experience)
- Fire Emblem zoning AI stays just outside player attack range, which interacts with threat-display readability — [FEUniverse](https://feuniverse.us/t/zoning-ai/8431)
- RULES.md marks open edge cases as "Open" and says an implementation "should flag it rather than guess" — [RULES.md](/Users/sirbryson/Documents/Strategy%20Game%20Idea/RULES.md)

### Inferences
Gap list, each with the proposal. "Basic" = must define; "Optional" = idea.

**A. Geometry and sight (all Basic)**
1. Distance metric. "6 tiles in every direction" (R4), shot range 5, tether 2, flashbang radius 2, light radius 3, guard move 4, and sound "walking steps" (R18) have no stated metric. Does a diagonal step cost 1 (Chebyshev), 2 (Manhattan) or 1.5? Proposal: one metric for the whole rulebook; for movement and sound, 8-way with diagonal = 1 but no corner-cutting past a wall; for ranges, the same, so a "range 5" diamond/square is drawn on the grid when aiming (R24-style preview).
2. LOS algorithm and corners. Undefined: does LOS pass diagonally between two wall tiles touching at a corner? Can you see/shoot around a corner from the tile beside it (XCOM "step out")? Proposal: tile-center to tile-center, blocked if the line passes through a wall tile or exactly through a wall corner pinch (two diagonal walls); no step-out peeks (we already have Peek, R4, for doors). Cones (R23) use the same test.
3. Cone shape on a grid. "90° wide" needs a rule for tiles on the cone's edge (center-inside? any part inside?) and for facing (8 directions or free angle?). Proposal: 8 facings; a tile is in the cone if its center is within ±45°; edge tiles shown explicitly.
4. What blocks what. Need a table: walls, closed doors, open doors, low obstacles (crates, vehicles — implied to exist by the drone rule), units, stunned bodies, receptacles. For each: blocks movement? blocks sight? blocks shots? blocks sound? R18 only says closed doors stop sound and R31 says shots hit the first unit. Proposal: walls/closed doors block all; low obstacles block movement, block shots? (decide), do NOT block sight; units block shots and movement but not sight.
5. Low cover / elevation as perception (Optional but high-value). Since there are no hit odds, a low obstacle between guard and Operator could downgrade "seen" to "noticed" (half cover = harder to spot), and high ground (rooftops, the 3D world) could extend Operator vision or let them see over low obstacles. This is the deterministic translation of XCOM/Mario + Rabbids cover and Triangle Strategy height.

**B. Movement and occupancy (Basic)**
6. Move through allies? Through robots? Through stunned/tied-up bodies? Swap with an adjacent ally? Not stated. Proposal: pass through allies, can't end on them; bodies block ending a move but not passing (or are pick-up-able only).
7. Moving through or adjacent to guards. No zone of control and no melee. Is walking directly behind a guard (outside its cone) always safe? Proposal: yes — make it explicit; it is the stealth genre's "flank."
8. Diagonal movement past corners (see 1).
9. Map edges: is the edge a wall? Can an Operator exit except at extraction? What does a car do at the edge ("until it hits something")? Proposal: edge = wall for all purposes.
10. Vehicles (Devices table): what if the car's path contains an Operator, a robot, a body, or a closed door? Rule only covers guards. Proposal: stops before any team unit (no friendly harm) — or explicitly stuns/downs them (friendly fire); decide.

**C. Friendly fire and shots (Basic)**
11. Does an Operator's shot stop at the first unit (ally robot in the way)? R31 says the guard's shot does; Operator shot isn't stated.
12. Do flashbangs blind Operators/robots in the radius? Do Breached turrets hit allies in their line?
13. Does the Operator's shot make sound? R18 says Operators move silently and devices make sound, but the weapon's sound is unstated, while the turret's shot has radius 5. This is a major stealth rule. Proposal: the stun pulse is silent (DESIGN.md: phaser/taser) or makes a small radius-2 sound; decide.
14. What does "finding" a body mean (R36)? Seen tier only, or noticed tier too? Does seeing a guard get stunned (in its cone at the moment of the shot) count as finding?

**D. Overwatch and reactions (Basic)**
15. "Line of fire" (R4 overwatch) undefined: all tiles within range 5 with LOS (XCOM) or a chosen cone (Gears)? Proposal: XCOM-style full circle, previewed; Gears' cone is the optional upgrade/gadget.
16. Triggers: an enemy already in the line at the start of its turn that doesn't move; an enemy that only turns; a woken guard; a robot; two enemies entering simultaneously; does the shot fire mid-move (interrupting the guard before it reaches a tile that would see the Operator)? Proposal: fires at the first tile entered within the area, interrupting the move; stationary enemies don't trigger.
17. Does an alerted-then-immediately-stunned guard still trigger caution (R27 + R29 imply yes)? Worth stating, because it is our de-facto "front vs back attack" rule.

**E. Enemy decision rules (Basic)**
18. Order of guards within a round: all are speed 5. Need a deterministic tie-break among enemies (e.g., fixed map order, shown in the turn bar).
19. Target choice when two Operators are visible (R33 settles Operator vs robot only). Proposal: nearest; tie → most recently seen → map order.
20. "Closest guard in range" ties for sound (R18), camera investigations (R21), receptacle wake (R39); turret "nearest enemy" ties (R17).
21. Unreachable destinations: investigation/last-known position/body behind a locked door or blocked by a car. Proposal: walk to the nearest reachable tile, look around, then resume patrol. Can guards open doors? Unlock them? Not stated.
22. Multiple lures in one round: R18 says an investigating guard ignores new ones, but two lures resolved in the same AI turn before any guard moves — which wins? Proposal: each lure resolves at once in order; later lures skip already-assigned guards.
23. Patrol definition: routes, waits, facing at each step, whether routes are visible to the player. Not in RULES.md at all.

**F. Turn structure (Basic)**
24. Delay/hold a turn: can an Operator wait and act later in the round? (Initiative games usually allow it; side-based ones don't need it.)
25. Turn-end triggers: do cones re-check when a guard turns during its own move, at every step? (Implied by R27 for Operator moves; not stated for guard moves.)

### Gaps
- Exact Fire Emblem/Advance Wars rules for move-through-ally and zone of control were not fetched; from general knowledge, Fire Emblem lets units pass allies but not enemies (no source fetched).
- No source on Invisible Inc's exact guard tie-breaking or LOS corner rules.

## What commonly makes tactics games fail, and where are we exposed?

### Takeaway
The documented failure modes are slow/forced-wait enemy turns, unreadable threats, missing undo/retry friction, dominant defensive loops (cover/overwatch turtling), snowballing (or the inverse, early-hard-then-trivial), and repetitive enemies. Our main exposures are snowballing via permanent tie-ups with no escalation, a repeatable lure-overwatch-tie-up loop with no clock, and enemy-turn length from many hidden guards.

### Cited Findings
- Enemy turns that pause to show each enemy acting one at a time made a player quit on level one — [itch.io comment](https://itch.io/post/9870500)
- Forced inaction is much more painful for the player than for the AI — [itch.io comment](https://itch.io/post/15582926)
- No speed-up for enemy turns and no undo made retries "tenfold" slower (Break Tactics) — [Nintendo Life](https://www.nintendolife.com/games/dsiware/break_tactics/review)
- A dev found enemy-turn delays fine early but tiresome "after the 100th turn" — [itch.io devlog via search](https://swordandquill.itch.io/soulblaze/devlog/907937/devlog-7-overcoming-design-problems)
- Gears Tactics goal: "fast-paced enemy turns with high tactical clarity," planning all AI moves then executing — [Unreal Engine interview](https://www.unrealengine.com/developer-interviews/gears-tactics-uses-the-gears-formula-brilliantly-to-offer-a-fresh-tactical-experience)
- Snowball effect: an early advantage that keeps growing, like Risk continents — [Envato Tuts+](https://code.tutsplus.com/the-snowball-effect-and-how-to-avoid-it-in-game-design--cms-21892a)
- XCOM: cover as the default survival tool squeezed out offense; timers punished setup actions; repetitive enemy behavior; "inverse arms race" — [Game Developer](https://www.gamedeveloper.com/design/a-deep-dive-into-xcom-and-xcom-2)
- Gears designs swarm enemies to soak overwatch and emergence holes to pressure turtling — [PC Gamer](https://www.pcgamer.com/uk/gears-tactics-is-a-shockingly-good-strategy-game)
- Keith Burgun argues for longer strategic arcs inside the battlefield game itself — [Game Developer, "Adding strategy to your tactics"](https://www.gamedeveloper.com/design/adding-strategy-to-your-tactics)
- ITB: avoid a final difficulty spike built on new mechanics — [Game Developer](https://www.gamedeveloper.com/business/how-subset-games-made-the-jump-from-i-ftl-i-to-i-into-the-breach-i-)

### Inferences
Exposure table, with proposals tied to our terms:

| Failure mode | Our exposure | Proposal | Basic / Optional |
|---|---|---|---|
| Snowballing | Tied-up guards are out for good (R35); no reinforcements; each removal shrinks the problem | An escalation track, Invisible Inc style but deterministic and visible: e.g., per-zone or battle-wide "security level" that rises on alerts, found bodies and woken guards (not per turn, to respect R22), adding a guard on a shown spawn point or re-activating cameras. Or: each tie-up/hidden body has a visible "missed check-in" timer after which its zone goes on caution | Basic (some counter-pressure) |
| Patience dominance / overwatch loop | R22 no clock + the Overwatch definition's lure→stun→tie-up loop, repeatable | Soft clock options that don't contradict R22: shift change at round N (new patrols), extraction window closing after the Prime Data Cache is Breached, or bonus objectives tied to rounds (ITB-style). Alternatively make the loop cost something (each lure source usable once; context cost per verb already partly does this, R16) | Basic to decide; the specific form is optional |
| Slow enemy turns | Many guards, including hidden ones (R1), all acting individually | Hidden guards resolve instantly; visible ones move simultaneously where independent; fast-forward toggle; Gears-style plan-then-execute | Basic (UX) |
| Unreadable threats | Cones (R23) and aim lines (R31) are good; patrol paths hidden; "who would respond" only for visible guards (R18) | Default-visible patrol route or end-facing for seen guards; Predict upgrades to exact path + aim. Global "danger view" toggle (Fire Emblem) combining all cones' next-turn reach | Basic (some baseline); exact level is a design call |
| No undo + hidden info | R4 no undo; R50 restarts the phase on loss | ITB-style one reset per phase/battle, restoring the start of the current turn (revealed info doesn't leak because it was already revealed) | Optional, strongly recommended |
| Alpha-strike dominance | Moderate: one shot per Operator per turn, but stun is guaranteed and tie-up permanent; three Operators + turret + dog bot can delete a cluster safely | Fine at V1; watch for it. Enemy roles that resist the single-shot answer without HP: a guard paired so stunning one is seen by the other; a "check-in" guard whose silence raises caution; a heavy who needs a gadget, not a shot (would bend "a hit always stuns" — Bryson's call) | Optional |
| Repetitive enemies | R40: one guard type, deliberate for V1 | V2 roles defined by perception/behavior, not HP: stationary sentry (fixed cone, never investigates), patroller, camera, turret (have), fast drone (speed above 6, acts before Operators), dog/hound (follows sound/scent, short cone), officer (radio: a found body alerts the whole zone), network enemy AIs (deferred, R15) | Optional for V1; Basic for the campaign |
| Inverse difficulty curve | Progression (R53) adds options, not numbers — good guard against it | Keep; ITB's rule "finale tests learned skills, nothing brand new" | Note |

- Map size is a real ITB pillar (8×8) that our rules never state. For a puzzle feel, maps should be small enough that the whole relevant threat picture fits on screen; recommend stating a target size per phase in the map-maker docs rather than RULES.md.
- Our turn order bar plus the aim line already answer two of the three "readability" complaints; the remaining one is patrol intent.

### Gaps
- No primary source found on "overwatch stalemates" as a named failure; the closest evidence is Gears' anti-turtle design and XCOM's cover dominance.
- No primary designer quotes found on alpha-strike dominance.
- Kotaku/Splitscreen and Designer Notes #71 (Davis) were not fetched and may contain more ITB rationale.
