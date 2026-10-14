# Pressure, intent and undo: our three missing basics

Our rules already do the hard, distinctive parts of a stealth-tactics game well, at or above the genre's standard: two-tier cones that are always visible, sound areas previewed before use, a telegraphed aim line instead of shoot-on-sight, binary light, and a hacking layer that runs on the same turn as the map. What the rules lack are the plain basics that comparable games treat as load-bearing. Five independent research angles each surfaced the same top three. The first is **pressure**: nothing gets worse over time, so waiting and the lure-overwatch-tie-up loop cost nothing. The second is **readable guard intent**: patrol paths are hidden unless the Predict chip is spent. The third is **undo, save and restart granularity**: the only recovery is replaying a whole phase. Behind those three is a layer of definitions that an AI-written implementation is quietly guessing at today: the distance metric, line of sight at corners, what blocks what, which Operator actions make noise, what "finding" a body means, and how guards break ties. None of this argues for more systems. It argues for finishing the ones we have, so that a player who loses knows why and a player who wins had to commit. Everything below is a recommendation, not a decision; the decisions Bryson needs to make are listed at the end.

## Terms used in this report

In-game terms follow RULES.md. "Rule N" means RULES.md's numbered rule N. The numbers in **bold** (**1**, **2**, …) are this report's recommendations and questions, numbered continuously so each can be answered by number alone.

| Term | Meaning here |
|---|---|
| Caution | A zone's heightened state after a full alert: noticed counts as seen, for 3 rounds (rule 29) |
| Noticed / Seen | The cone's outer tier (draws an investigation) and its core (a full alert) (rule 23) |
| Aim line | An alerted guard's fixed line; it fires next turn if the target is still in it (rule 31) |
| Lure | Anything that sends a guard to investigate: a device sound, a light or camera going dark (rule 18) |
| Predict | The chip that shows two visible guards' next-turn paths and aim targets |
| Tie-up | Restraining a stunned enemy for 2 AP; out of the battle unless found (rule 35) |
| Downed | An Operator out for the rest of the battle after their last hit (rule 41) |
| Escalation (new, not a game term) | Any pressure that makes the map harder as the battle goes on and doesn't reset by waiting |
| Check-in (new, proposed) | A proposed rule: a guard who's been tied up or hidden for N rounds is missed, and someone comes looking |
| Telegraph (new, not a game term) | Showing an enemy action one turn before it happens, the way the aim line does |
| Commit point (new, proposed) | The moment an action can no longer be undone because it revealed information or made the world respond |
| Firewall (new, proposed) | Extra breach goal added to a node, as a lightweight form of network opposition |

How each item is labelled: **Rules say** is what RULES.md or DESIGN.md states. **Other games** is what the research found, with sources. **Inferred** is my reading, not established. **Recommended** is a proposal for Bryson. **Undecided** is an open question.

## Five research angles converged on the same handful of gaps

The research ran as five separate threads: stealth systems, tactics fundamentals, player-facing UX, mission structure and campaign loop, and the hacking layer. Where several threads independently flagged the same gap, that's the strongest evidence it's a true basic rather than one researcher's preference.

| Gap | Stealth | Tactics | UX | Mission | Hacking | Tier |
|---|---|---|---|---|---|---|
| No pressure or escalation; waiting is free | yes | yes | yes | yes | yes | Basic |
| Guard intent (patrol paths) not readable by default | yes | yes | yes | | | Basic |
| No undo, no mid-mission save, phase-only restart | yes | yes | yes | yes | | Basic |
| Noise from Operator actions unstated (shot, flashbang, sprint) | yes | yes | | | | Basic |
| Grid geometry and enemy tie-breaks undefined | | yes | | | | Basic |
| Alerts don't spread between guards | yes | | | | | Basic |
| Body "finding" undefined | yes | yes | | | | Basic |
| Downed Operators cost nothing; sacrifice is free | | | | yes | | Basic |
| No network opposition; held networks only grow | | | | | yes | Basic |
| Enemy-turn speed and an event log | | yes | yes | | | Basic (UX) |
| One guard type | yes | yes | | | | Basic for the campaign, deliberately not V1 |
| One objective type, no badges | | yes | | yes | | Basic for the campaign |
| Onboarding order, accessibility double-coding | | | yes | | | Basic before others play it |

Rules say the V1 omissions are mostly deliberate: one guard type (rule 40), no network opposition (rule 15), no undo (rule 4), progression in V2 (rule 53). That makes them fine for a systems test, but it also means V1 can't show whether the game is a puzzle. Without pressure, the dominant strategy might simply be patience, and a test of the rules won't distinguish "this is a good puzzle" from "this is a solved puzzle you just have to sit through".

What to keep, because the research found nothing better elsewhere: sound previews with the responding guards marked (rule 18) match Mark of the Ninja's sound rings, which Klei added because players couldn't make sense of the game without them ([Game Informer](https://gameinformer.com/b/features/archive/2012/10/15/afterwords-mark-of-the-ninja)). The aim line (rule 31) is an Into the Breach-grade telegraph, body-block included. Free interleaving of Operator and AI actions (rule 3) avoids Shadowrun Returns' separate Matrix, where the decker's body sat inert and players called the layer "tedious" ([Shacknews](https://www.shacknews.com/article/78948/shadowrun-returns-enters-the-matrix); [Steam](https://steamcommunity.com/app/234650/discussions/0/46476145494035844)). Deterministic hacking (rule 9) avoids Deus Ex: Human Revolution's "50% guesswork and 50% reload spam" ([Game Developer](https://www.gamedeveloper.com/design/deus-ex-non-revolution-)). The Noticed tier does the job other games give to a crouch stance, so its absence isn't a gap.

## Tier 1: the genre basics we're missing

### Nothing gets worse, so patience is the dominant strategy

**Rules say.** "There is no battle-wide clock" (rule 22). The rulebook exploration records the reason: "No battle-wide clock, like an alarm or trace. Most hacks are limited by whether they can be done, not by time." Every pressure that does exist is short and local: caution lasts 3 rounds in one zone (rule 29), a search 2 turns (rule 28), a stun 3 turns (rule 34). Tied-up guards are out for good (rule 35). Guards, caution and fog reset at a handover (rule 48). Context (rule 8) limits only the AIs, and waiting costs no context.

**Other games.** Every comparable game puts something in this slot. Invisible Inc.'s alarm meter fills, and each level adds threats: more cameras, then turrets, then new guards ([GameStar](https://www.gamestar.de/artikel/invisible-inc-taktischer-geniestreich,3086028.html); [Gamereactor](https://www.gamereactor.eu/invisible-inc-review/)). Klei's alpha notes show they moved it from a single late trigger to gradual stages "that start off small but get bigger each time" ([update notes mirror](https://reddit.sudovanilla.org/r/incognita/comments/1xqihm/february_12_update_8)). Into the Breach gives each map a fixed turn count, partly to keep battles short against XCOM's hour-long fights ([Wikipedia](https://en.wikipedia.org/wiki/Into_the_Breach)). Metal Gear Solid steps down through Alert, Evasion and Caution ([Metal Gear Wiki](https://metalgear.fandom.com/wiki/Enemy_status)). Phantom Doctrine has guards who fail to check in, and others go looking for them ([Wikipedia](https://en.wikipedia.org/wiki/Phantom_Doctrine); [bit-tech](https://bit-tech.net/reviews/gaming/pc/phantom-doctrine-review/1/)). The same reviewer found its stealth phase dull, with "no sense of escalating pressure or suspicion" ([bit-tech](https://bit-tech.net/reviews/phantom-doctrine-review/1)). The form players resent most is the hard fail timer: XCOM 2's mission timers drew a backlash, and War of the Chosen added an option to double them ([GameGeeker](https://gamegeeker.com/dlc/xcom-2-war-of-the-chosen); [Quarter to Three](https://forum.quartertothree.com/t/xcom-2-give-me-real-ap-or-give-me-death/76898?page=82)).

**Inferred.** Into the Breach's puzzle is "solve this turn, then the board gets worse." With no clock and permanent tie-ups, ours is "the board only gets easier." The overwatch setup RULES.md itself describes (lure a guard into a hallway, stun it from overwatch, tie it up next turn) can be repeated on every guard, and its only cost is time, which costs nothing. Optional caches (rule 51) have the same problem: without a cost to staying, they're always taken, so they stop being a choice. This is inferred from the rules, not yet observed in play.

**Recommended.** Options that leave rule 22 standing, cheapest first:

1. **Undecided: does rule 22 rule out only a turn-driven clock, or any lasting escalation?** The recorded reason names "an alarm or trace", which is exactly Invisible Inc.'s model. An event-driven "security level" (it rises on full alerts and found bodies, never on turns) is close to what Bryson rejected, so I'm not recommending it unless he says that's in bounds.
2. **Check-ins.** A guard who's been tied up or hidden for N rounds (placeholder 4) is missed: the closest guard investigates their last patrol tile, using the existing Investigate rule. A countdown icon sits on the body. This puts a price on clearing the map one guard at a time, without a clock. It's Phantom Doctrine's answer, applied to our tie-up rule.
3. **Exfil escalation.** Breaching the Prime Data Cache puts every zone on caution, or opens a map-authored reinforcement door. It pressures only the escape, gives "grab it and run" its heist feel, and leaves the planning phase untouched.
4. **A rounds-taken par on the end screen.** No fail state, just a target, like Shadow Tactics' time badge ([Wikipedia](https://en.wikipedia.org/wiki/Shadow_Tactics:_Blades_of_the_Shogun)). One counter, one label.
5. **Log rounds per phase and rounds spent with no Operator action, in the build.** DESIGN.md's principle is to add a cost only when something is game-breakingly strong. This puts numbers on whether waiting is dominant, rather than assuming it.

### Guards act alone, so one mistake never cascades

**Rules say.** An alerted guard aims and fires by itself (rules 28, 31). Caution changes cone tiers in the zone (rule 29), but no other guard is told. A camera sighting sends only the closest guard (rule 21). The rulebook exploration parks "caution as escalation through a chain of command": a leader pieces separate reports together and puts the area on high alert. It records this as the option Bryson finds "the most intriguing", with V1 kept simple.

**Other games.** In MGS1, one exclamation mark means only nearby enemies react, while a second, or a camera, brings reinforcements ([Metal Gear Wiki](https://metalgear.fandom.com/wiki/Exclamation_point)). Commandos: Origins has clerks who can't fight but call reinforcements, and three local alarms trigger a global one ([Epic guide](https://store.epicgames.com/news/commandos-origins-guide-tips-survive-behind-enemy-lines)). Shadow Gambit made alarms local, but added bell-carriers who summon help and paired monks who must be taken out together ([Shadow Gambit](https://www.shadowgambit.com/8-new-gameplay-features/)).

**Inferred.** Communication creates the most interesting stealth decision: stun them before they report. Shadow Gambit's change suggests the modern answer is escalation the player can see coming and intercept, not a blanket penalty. Our aim line is already that pattern.

**Recommended.**

6. **A telegraphed radio call (V1-sized).** An alerted guard who still has an Operator in sight at the start of its next turn calls its zone. Every guard there turns Searching toward the last-known position. It's shown like the aim line, as a "calls next turn" icon, and stunning, blinding or breaking line of sight cancels it. Same one-full-turn-to-answer rule as rule 31.
7. **Later, build Bryson's parked chain of command on the same telegraph.** Investigations, camera sightings and radio calls feed a visible leader. When enough reports arrive, the leader raises the area. This also answers how cameras matter without breaking rule 21.

### Patrols are hidden, so planning drifts from puzzle to guesswork

**Rules say.** Cones are always shown (rule 23), and so are aim lines (rule 31). Patrol paths aren't shown, except through Predict (two guards, one turn, costs context). Hidden enemies act unseen (rule 1). The guard's state (patrolling, investigating, searching) isn't required to be displayed.

**Other games.** Into the Breach shows every enemy's attack and the order they resolve in ([Wikipedia](https://en.wikipedia.org/wiki/Into_the_Breach); [KosGames](https://kosgames.com/?p=5557)). Subset described the project as "a push to be more deterministic in the moment-to-moment gameplay" ([PC Gamer](https://pcgamer.com/into-the-breach-preview)). Justin Ma: "we would sacrifice cool ideas for the sake of clarity every time" ([RPS interview repost](https://reads.mhlakhani.com/posts/582127219_10156233399322220)). Mark of the Ninja's rule is that if a guard's behaviour changes, the player "will immediately understand what set it off" ([Game Developer](https://gamedeveloper.com/design/-i-mark-of-the-ninja-i-s-five-stealth-design-rules)). Fire Emblem has one button for every enemy's combined danger area, and lets you pin single-enemy ranges ([SuperCheats](https://www.supercheats.com/fire-emblem-three-houses/walkthrough/danger-radius); [Siliconera](https://www.siliconera.com/2013/01/24/the-things-you-can-do-on-fire-emblem-awakenings-world-map-2/)).

**Inferred.** DESIGN.md's north star is "Into the Breach if it were a stealth game." Selling patrol information through a chip fits the AI's role, since hacking gathers battlefield information. But the baseline still has to be readable, or the player plans against hidden variables. That's the "statistical back-and-forth" Bryson wants to avoid, with memorisation standing in for dice.

**Recommended.**

8. **Free guard-state icons.** Patrolling; investigating, with a line to the spot; alerted; searching, with the last-known position; stunned, with turns left. This tells the player what a guard is doing, while Predict still tells them where it's going.
9. **Undecided: how much of the patrol route is free.** Options: (a) a visible guard's route is drawn once the team has watched it for a full loop; (b) only its facing after its next move; (c) nothing, Predict only. I lean (a): it rewards scouting, and Predict keeps its value for guards you haven't watched, for aim targets and for reroutes caused by an investigation.
10. **A danger-zone toggle.** The union of every visible cone's seen and noticed tiers, plus pinnable single-guard overlays. With four or more guards and cameras, overlapping cones become unreadable. Players raised this about both Mario + Rabbids and Shadow Tactics ([God is a Geek](https://godisageek.com/?p=196353); [Steam](https://steamcommunity.com/app/418240/discussions/0/1290691937705159737)).

### No undo turns a misclick into a replayed phase

**Rules say.** "There is no undo in V1" (rule 4). A loss restarts the current phase (rule 50). No save is specified.

**Other games.** The touchstone doesn't have "no undo". Into the Breach lets you undo any unit's move until that unit acts, plus one full-turn reset per battle ([Nintendo Life](https://nintendolife.com/reviews/switch-eshop/into_the_breach)). Fire Emblem has had a turn rewind in every game since Echoes' Mila's Turnwheel ([Fire Emblem Wiki](https://fireemblemwiki.org/wiki/Mila%27s_Turnwheel_II)). Invisible Inc. scales its rewinds by difficulty, and Ironman removes them ([Slant](https://slantmagazine.com/games/invisible-inc)). Mimimi made quicksave central and gave Shadow Gambit's rewind a fiction, because a rewind with no in-world reason felt "fourth-wall breaking" ([Game Developer](https://www.gamedeveloper.com/design/how-shadow-gambit-the-cursed-crew-was-able-to-make-save-scumming-a-central-mechanic)). Triangle Strategy added a battle retry and periodic autosaves after demo feedback ([Nova Crystallis](https://novacrystallis.com/2021/09/triangle-strategy-shares-changes-built-on-demo-versions-survey/)). A review of Break Tactics found that no undo plus slow enemy turns made retries "tenfold" slower ([Nintendo Life](https://www.nintendolife.com/games/dsiware/break_tactics/review)).

**Inferred.** In a deterministic game, failing because you misread a preview feels like a UI failure, not a tactical one. Sprint makes this sharper: a misclicked sprint silently costs the turn's shot. Phases are long, with three Operators, two robots and three AIs each.

**Recommended.**

11. **Undo anything that taught you nothing.** Free undo of Operator and robot movement, and of AI moves through a known network, until a commit point: a reveal (rule 27), entering a cone, a peek, a shot, a hack, a verb, a chip load. This changes an agreed rule (rule 4), so it needs Bryson's yes.
12. **A suspend save.** Quit mid-phase and resume exactly there, loading once. It's needed just to end a playtest session anywhere other than a phase boundary.
13. **"Restart from the start of round N"** for the last few rounds, alongside rule 50's phase restart. Items 11–13 and the event log (item 28) all rest on battle-state snapshots, which is an architecture choice to design together, per AGENTS.md.
14. **Later, a once-per-battle turn reset in the fiction:** the AI forks a simulation, which might cost context. This is a difficulty dial, not V1.

### Unstated noise rules are where "I didn't know that would happen" comes from

**Rules say.** Operators move silently, devices make sound (rule 18), and a turret's shot is "5, all". Nothing says whether the Operator's own shot, a flashbang, tying up, a door, a downed robot or a car crash makes sound. Sprint is silent and costs only the shot.

**Other games.** In Invisible Inc. sprinting makes noise that players use as a lure ([Steam](https://steamcommunity.com/app/243970/discussions/0/1644292549028032445)), and shots attract guards ([Nintendo World Report](https://www.nintendoworldreport.com/review/54129)). Mark of the Ninja's whole fix for comprehension was making every sound's real radius visible ([Game Developer](https://gamedeveloper.com/design/reinventing-stealth-in-2d-with-i-mark-of-the-ninja-i-)).

**Recommended.**

15. **A sound table for Operator and robot actions,** in the device table's format, with the ring previewed before confirming, per rule 18. A starting proposal: shot none (the silent pulse as a selling point of the non-lethal weapon); flashbang 4, closest; tie-up, carry and doors none; a robot downed 2, closest; a car impact the truck's or car's radius.
16. **Undecided: should sprint make a small sound (2, closest)?** It would give sprint a stealth cost and make the Operator a lure, as in Invisible Inc. It's a design change, not a gap fill.
17. **Define "finding" a body (rule 36).** Proposal: a body in a guard's seen tier is found (full alert); one in the noticed tier is investigated and found on arrival; an enemy camera that sees a body sends the closest guard, consistent with rule 21. Also undefined: does a guard who sees a colleague get stunned count as finding them?

### The definitions an AI-written build is silently guessing

**Rules say.** RULES.md says an open edge case should be flagged, not guessed. But the rulebook doesn't define the grid itself, so any implementation has to make these calls.

**Inferred.** This is the "basics AI-assisted development takes for granted" gap. Every one of these has an answer in the code right now, chosen by whichever agent wrote it. Those answers are decisions made by implementation, not by Bryson. I haven't audited the code for what it currently does.

**Recommended.**

18. **A geometry section for RULES.md.** The distance metric: "6 tiles", "range 5", "radius 2" and "walking steps" all need one, and I suggest 8-way movement with a diagonal step costing 1 and no cutting past wall corners. Line of sight from tile centre to tile centre, blocked at a diagonal wall pinch, the same test for cones and shots. Cone edges: 8 facings, with a tile inside if its centre is within 45°. A blocks table covering walls, closed and open doors, low obstacles (implied by the drone), units, bodies and receptacles, against movement, sight, shots and sound. XCOM needed exactly these rules spelled out ([UFOpaedia](https://ufopaedia.org/Line_of_Sight_(EU2012))).
19. **Enemy decision rules.** The order among guards who share speed 5. Which Operator a guard targets when it sees two (rule 33 only settles Operator against robot). Ties for "closest guard" (rules 18, 21, 39) and "nearest enemy" (rule 17). What a guard does when its target is behind a locked door, and whether guards open or unlock doors. Which lure wins when two fire before any guard moves. Overwatch triggers: does it fire mid-move, and on a guard that only turns? And what a patrol actually is (route, waits, facings), which RULES.md never defines.
20. **Friendly fire.** A car's path with an Operator, robot, body or closed door in it (the rules cover only guards). Whether a flashbang blinds allies. Whether the Operator's shot stops at the first unit, as the guard's does. Whether walking directly behind a guard, outside its cone, is always safe (I recommend yes, and saying so).

### A downed Operator costs nothing, so sacrifice is free

**Rules say.** A downed Operator is out for the battle, can be left behind, and "for now their escape is handwaved" (rule 49). There's no permadeath (DESIGN.md), and Bryson prefers Chained Echoes-style full recovery for now (rulebook, parked).

**Other games.** In Invisible Inc. a downed agent can be dragged to the exit, and rescuing agents from holding cells is a mission type ([Wikipedia](https://en.wikipedia.org/wiki/Invisible,_Inc.); [Game Informer](https://www.gameinformer.com/games/invisible_inc/b/pc/archive/2015/05/13/invisible-inc-game-informer-review.aspx?amp)). Nintendo Life notes that without permadeath, units get thrown into certain doom as distractions ([Nintendo Life](https://www.nintendolife.com/news/2013/04/talking_point_fire_emblem_awakening_the_big_casual_mode_debate)).

**Inferred.** Operator B's heavy armor makes them an ideal free decoy. There's also no "won, at a cost" outcome, and "the team walked off and left someone" is a story hole for a stable squad of three.

**Recommended.**

21. **Let Carry (rule 37) apply to downed Operators,** so they can be carried to extraction.
22. **Undecided: what being left behind costs.** Options: OpenBrain gains heat, so the next mission starts with an extra camera or a patrol, or a zone already on caution (cheap, and on-theme); the Operator is captured and the next mission becomes a rescue (strongest for story, the most content); or lost town time, which only works if the town has a calendar. This keeps full recovery and changes only what's lost when nobody brings them home.

### The network only ever grows

**Rules say.** Network opposition is deferred until playtesting shows the network's density (rule 15). Verbs cost 0 AP and 5 context, and work from anywhere on the network (rule 16). Refunds are uncapped except by context (rule 6). Nothing re-locks a Breached node. Crashed (rule 42) can't happen in V1.

**Other games.** Every successful deterministic hacking layer moves risk out of dice and into opposition that escalates. Invisible Inc.'s firewalls go up at alarm level 2 ([Klei forums](https://forums.kleientertainment.com/forums/topic/59447-beginner-experienced-jump-tips/)), and its Echo daemon recaptures devices ([Invisible Inc. wiki](https://invisibleinc.fandom.com/wiki/Daemons?oldid=5566)). Cyber Knights' hacker "cannot render systems completely under your control" ([RPGFan](https://www.rpgfan.com/review/cyber-knights-flashpoint/)). In Gunpoint, Tom Francis cut remote activation of circuit devices because it made puzzles trivial ([Wikipedia](https://en.wikipedia.org/wiki/Gunpoint_(video_game))).

**Inferred.** The live risk is the "I win" button: once the network is held, nothing takes it back. Three AIs, each with free verbs, multiply that risk.

**Recommended.** These test opposition without adding node types, which was rule 15's worry:

23. **A pre-breach preview on hover:** the hacks needed at current power (chips and the full-context halving applied), the context cost, and a "Refund" badge if one action will breach. The same for verbs. This is the hacking counterpart of rule 18's sound preview.
24. **Caution reaches the network.** While a zone is on caution, its devices gain a firewall (placeholder +10 goal) and can't refund. This links the layers: getting seen makes hacking harder.
25. **Physical counter-hacking.** A guard who investigates a Breached device (for example, one lured by a camera going dark) returns it to enemy control, with progress at 0.
26. **Watch item, not a proposal:** free verbs per AI per turn. If playtests show long chains of them, a per-turn verb budget is the simplest brake.

### Enemy turns, feedback and colour: the UX floor

**Rules say.** Nothing in RULES.md or DESIGN.md covers enemy-turn speed, a history log, tooltips, onboarding or accessibility.

**Other games.** XCOM 2's most popular quality-of-life mod cut pauses from about 3 seconds to 0.6 ([Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/changelog/620600092)). One player quit a game on level one because its enemy turns paused to show each enemy acting in turn ([itch.io](https://itch.io/post/9870500)). Gears Tactics aimed for "fast-paced enemy turns with high tactical clarity" by planning every AI move first, then executing ([Unreal Engine](https://www.unrealengine.com/developer-interviews/gears-tactics-uses-the-gears-formula-brilliantly-to-offer-a-fresh-tactical-experience)). XCOM 2's movement preview bands path cost by colour and flags exposure at the destination ([Pixel Twelve](https://pixeltwelve.com/guides/xcom-2-beginner-guide-first-mission-cover-overwatch)). The Game Accessibility Guidelines' first rule is that no essential information is carried by colour alone ([GAG](https://gameaccessibilityguidelines.com/ensure-no-essential-information-is-conveyed-by-a-fixed-colour-alone/)).

**Recommended.**

27. **Enemy-turn speed settings** (normal, fast, instant) and a skip key. The camera frames an enemy only when something the player cares about changes; hidden guards' turns take no screen time.
28. **A round-by-round event log** ("Guard 3 noticed B → investigating", "Refund +1 AP", "Context 74 → 89"). In a deterministic puzzle, learning from a loss needs the causal chain.
29. **Move previews.** AP-cost bands for walk and sprint, with "costs your shot" on sprint tiles. An end-of-move summary on the destination: seen or noticed by whom, in the aim line, beyond the tether. Outcome previews for a car's path, a flashbang's radius and the lures a power hub would create.
30. **Double-code everything coloured.** Seen as solid fill plus an eye; noticed as hatched fill plus a "?"; caution as a changed pattern, not just a changed hue. Dark tiles and fog currently look the same by rule (rule 25), so they need separate glyphs. And flag the art-direction collision: OpenBrain's red accents (DESIGN.md) against red as the warning colour.
31. **An "end turn with AP left?" prompt.** With two AP pools per unit, forgetting the AI's 2 AP will be common.

## Tier 2: basics for a campaign, not for the V1 test

These are deliberately out of V1 (rules 40, 51, 53), and that's correct for a systems test. They become basics once there's more than one map.

32. **Guard roles, when rule 40 opens.** Roles defined by perception and behaviour, not HP. An officer who ignores device lures (Shadow Tactics' samurai ignore the sake lure, per [KeenGamer](https://www.keengamer.com/articles/guides/7-shadow-tactics-blades-of-the-shogun-tips/)). A radio carrier, who's the only guard who can make item 6's call. Paired guards: stun one in the other's sight and it's an instant alert. A stationary sentry. A fast drone above speed 6 that acts before the team. With every guard at speed 5 and the team winning ties, turn order is currently fixed; a faster enemy is what makes it matter.
33. **Objective variants built from existing verbs:** steal (Carry an item), rescue (Carry a person), sabotage (breach and use a specific device), plant (hold a relay at a node). This pairs with Bryson's 2026-10-12 parked idea of several win and lose conditions per level.
34. **2–4 badges per mission,** from counters the rules already track: no full alerts, under par, no tie-ups, all caches. Shown before the mission, never gating story content. That avoids the Hitman critique that locking opportunities behind mastery felt like forced replay ([Inverse](https://www.inverse.com/article/27668-hitman-season-1-review-impressions)).
35. **A pre-mission planning screen,** for choosing chips (rule 10 already locks them per battle) and gear, plus **intel from town** that reveals something about the next map: a network's layout, a patrol, an alternate entry. This is the cheapest link between the town and the battle.
36. **An onboarding ladder, one interlocking system per map:** movement and cones, then bodies, then the AI and breaching, then cameras and refunds, then lures, then light and blackout, then context and chips, then robots as relays, then caution and aim. A first-time callout names each rule the first time it triggers.
37. **A level checklist and a length target:** a physical route and a network route to the Prime cache; one optional risk area; extraction away from the entry; a ghost route that exists. My untested target is 10–20 rounds per phase, measured rather than assumed.

## Tier 3: optional ideas worth keeping on the list

These are common in the genre but not holes. Each would add a system, so DESIGN.md's cost principle applies.

| # | Idea | Who does it | Fit with our rules |
|---|---|---|---|
| 38 | Operators hide in closets or lockers | Shadow Tactics bushes, Commandos | Partly reopens the Cloak skill dropped on 2026-10-04; Bryson's call |
| 39 | Low cover downgrades seen to noticed; height extends vision | XCOM and Mario + Rabbids cover, Triangle Strategy height ([Game Developer](https://www.gamedeveloper.com/design/a-deep-dive-into-xcom-and-xcom-2)) | The deterministic translation of cover, since we have no hit odds |
| 40 | Credentials: a breached badge node lets one Operator be noticed rather than seen outside restricted zones | Phantom Doctrine disguises ([Gameranx](https://gameranx.com/features/id/159152/article/phantom-doctrine-7-infiltration-tips-to-help-you-stealth-missions-how-sneaking-works/)) | Strong setting fit; V2 or later |
| 41 | Civilians who run to the nearest guard | Shadow Tactics, Commandos clerks | Fits the Andor theme; an alert you can intercept |
| 42 | Noisy tiles (gravel, glass) | Shadow Tactics snow and water | Map spice through the existing sound rules |
| 43 | A console device that relieves context when breached | Invisible Inc.'s power from consoles ([Wikipedia](https://en.wikipedia.org/wiki/Invisible,_Inc.)) | Makes the network economy shape physical routes |
| 44 | An intel terminal that reveals a zone's patrols or another network's layout | Invisible Inc. | DESIGN.md already promises hacking that gathers enemy locations |
| 45 | Hacking key nodes draws a guard to the access point in use | Cyberpunk 2077's trace ([nukesdragons](https://nukesdragons.com/@tobias/cyberpunk-2077/character/solo-netrunner)) | Makes the tether a real risk, without a clock |

## Conclusion

The pattern across all five research angles is that our rules are strongest where they're most original (the telegraphed aim, previewed lures, two layers in one turn) and thinnest where every other game is boringly the same. That's what you'd expect from a rulebook built from distinctive ideas outward, and it's also why an AI-assisted build is risky here: the unglamorous rules (corners, tie-breaks, noise, finding a body) get filled in by whichever agent writes the code, and nobody notices because the game runs. The most useful next step is less about adding mechanics and more about writing down the geometry and enemy decision rules, then adding the one thing that makes the clean solution matter.

The deeper takeaway concerns pressure. The research consistently shows the genre doesn't need a clock. It needs failure that's visible, costs something, and can be stopped mid-step. Check-ins, radio calls and caution reaching the network all reuse the aim line's "telegraph now, resolve next turn" pattern. That pattern gives Bryson most of what Invisible Inc.'s alarm provides, while keeping rule 22's intent and the puzzle north star intact. Whether it's needed at all is something the next build can measure (item 5) rather than assume.

## Decisions needed from Bryson

46. Does rule 22 rule out all lasting escalation, or only a turn-driven alarm or trace? (Item 1.) If only the latter, which of items 2, 3 and 6 should go into the next build?
47. How much guard intent is free: state icons only (item 8), routes once observed (item 9a), or more?
48. Should rule 4's "no undo" become "undo anything that taught you nothing" (item 11), with a suspend save (item 12)? And shall we design the battle-state snapshot architecture together, since items 11–13 and 28 depend on it?
49. Is the Operator's shot silent, and should sprint make sound? (Items 15–16.)
50. Shall I draft a geometry and enemy-decision section for RULES.md (items 18–20), as a proposal for your review, starting with an audit of what the code already does?
51. What does leaving a downed Operator behind cost: heat, capture or lost time? (Item 22.)
52. Should items 24 and 25 (caution firewalls, guards re-locking devices) go into V1 as the minimal network opposition, or wait as rule 15 says?
