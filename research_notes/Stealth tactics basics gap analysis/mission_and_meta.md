# Mission structure, pressure, failure and the campaign loop: comparison against our rules

Scope: how tactics and stealth-tactics games structure missions, apply pressure, handle failure, and tie battles to a campaign or hub, compared with RULES.md (Missions rules 47 to 51, Defeat and recovery rules 41 and 42, Progression rules 52 and 53, rule 22 "There is no battle-wide clock") and DESIGN.md (Decisions: no permadeath, a stable roster of three, a Persona-like town; Constraints: 10 hrs/week, no budget, AI-executed art and code).

Our current state, from the local files (no web source needed):
- One objective type: breach the Prime Data Cache (goal 60), then get every standing Operator to extraction (rules 49 and 51).
- Optional Secondary and Tertiary caches are defined but left out of the V1 map (rule 51).
- No battle-wide clock (rule 22). The pressures that exist are local and short: caution for 3 rounds (rule 29), guard search for 2 turns (rule 28), stunned guards waking after 3 turns (rule 34), and context as a battle-long resource for each AI (rule 8).
- Loss means all three Operators downed, and it restarts the current phase with its entry conditions (rule 50). Downed Operators can be left behind; "for now their escape is handwaved" (rule 49).
- Loadout is chosen before the battle and locked (rule 10). Progression is V2 (rule 53). Town between battles (DESIGN.md Decisions).

Source quality warning: several primary pages (the XCOM fandom wiki and the Invisible Inc. fandom wiki) returned HTTP 402 and could not be read. GDC talk content (Into the Breach postmortem, Mimimi's Shadow Tactics talk) was only available as session listings, not transcripts. Where a claim rests on a review, a fan guide or a forum, that is noted.

## 1. Time and pressure: how games stop players from waiting forever, and what our missing clock risks

### Takeaway
Every comparable game applies some escalating pressure: a per-turn alarm (Invisible Inc.), hard turn timers (XCOM 2), a fixed turn count (Into the Breach), or check-ins and reinforcements (Phantom Doctrine, Shadow Tactics). Our rules have none beyond 2-to-3-round local timers that reset, so the turtling strategy of waiting out patrols, and repeating the lure-overwatch-tie-up loop, is probably free. This is a basic that needs at least a deliberate decision before more maps get built.

### Cited Findings
- Invisible Inc.: after the player ends each turn, enemies move and in most locations the alarm level rises; higher alarm levels bring new security forces and threats. — [Wikipedia: Invisible, Inc.](https://en.wikipedia.org/wiki/Invisible,_Inc.)
- A reviewer describes the alarm counter as rising slightly every turn so difficulty creeps up steadily; a player review argues that without it there would be little challenge "because of the nature of the game: it's a stealth game." — search summaries of [PC Gamer review](https://pcgamer.com/invisible-inc-review) and a [Steam review](https://steamcommunity.com/id/netcoder1/recommended/243970?l=swedish) (secondary; the snippets came from a search summary, not a full read)
- The same player review says killing guards raises the alarm instantly, while knocking them out is only temporary. — [Steam review](https://steamcommunity.com/id/netcoder1/recommended/243970?l=swedish) (player source)
- Exact Invisible Inc. alarm thresholds could not be confirmed. A tabletop adaptation describes Alarm 0 to 6 with 5 points per level and a point each round, but that is the adapter's design, not Klei's. — [r/DnDBehindTheScreen post](https://libreddit.neb.cx/r/DnDBehindTheScreen/comments/l2a8pm/a_system_for_making_stealth_and_infiltration)
- Invisible Inc. also has a campaign-level clock: three days (72 hours) before the final mission, with travel and missions using up that time. — [Wikipedia: Invisible, Inc.](https://en.wikipedia.org/wiki/Invisible,_Inc.)
- XCOM 2: timers and procedural maps were introduced to stop the defensive, slow play of the first game (secondary fan guide). Solomon, quoted second-hand on a forum, said the backlash surprised him, that "the experience is better for turn-timers", and that the game is at its best when the player takes risks; he also admitted that "blind allegiance to mechanics" may have kept them in despite complaints. — [Quarter to Three forum thread](https://forum.quartertothree.com/t/xcom-2-give-me-real-ap-or-give-me-death/76898?page=82) (second-hand transcription); [Matchstick Eyes on the RPS interview](https://www.matchstickeyes.com/2016/02/29/clippings-firaxis-february/) describes the timer as a case where theme and mechanics clash
- Player complaint: timers are fixed regardless of map size or type, "always 8 turns for Guerrilla ops and 12 turns for council missions." — [Steam discussion](https://steamcommunity.com/app/268500/discussions/0/1698293255129519888) (player claim)
- Players defended timers as what stops turtling ("Timed missions and the Avatar clock strangle the turtle"); untimed civilian-rescue missions get the same forward pressure from enemies killing a civilian or two each turn. War of the Chosen added a difficulty option that doubles all timers, and mods remove or extend them. — [GameGeeker review](https://gamegeeker.com/dlc/xcom-2-war-of-the-chosen); [Steam discussion](https://steamcommunity.com/app/268500/discussions/0/2262439950670010558); [Timer mod comments](https://steamcommunity.com/sharedfiles/filedetails/comments/1125412463)
- XCOM 2 missions start with the squad concealed, so the player can set up a coordinated ambush. The campaign has an alien win condition that can be delayed through sabotage but never permanently, a structure Solomon took from co-op board games like Pandemic ("You're playing against the system") to avoid a late-game "victory lap." — [Game Informer](https://gameinformer.com/games/xcom_2/b/pc/archive/2015/12/10/xcom-2s-board-game-influences-and-the-race-against-the-alien-clock)
- Into the Breach: each scenario gives a fixed number of turns to complete its objective, and the turn limit is a key tool for keeping battles short; the developers contrasted this with XCOM, where a simple battle could take up to an hour. — [Wikipedia: Into the Breach](https://en.wikipedia.org/wiki/Into_the_Breach)
- Phantom Doctrine: missions have an infiltration mode and a combat mode; alarms (gunfire, bodies found, being spotted in restricted zones) switch to combat; guards who fail to check in send others looking for them. — [Wikipedia: Phantom Doctrine](https://en.wikipedia.org/wiki/Phantom_Doctrine); [The Sixth Axis review](https://thesixthaxis.com/2018/08/14/phantom-doctrine-review); [bit-tech review](https://bit-tech.net/reviews/gaming/pc/phantom-doctrine-review/1/)
- One reviewer found Phantom Doctrine's stealth phase boring, with "no sense of escalating pressure or suspicion," and compared it unfavourably to Invisible Inc. — [bit-tech review](https://bit-tech.net/reviews/phantom-doctrine-review/1) (as summarized in search results)
- Shadow Tactics: being spotted or a body being found sounds the alarm and sends extra patrols to secure the area, and a badge rewards finishing under a time limit. — [Wikipedia: Shadow Tactics](https://en.wikipedia.org/wiki/Shadow_Tactics:_Blades_of_the_Shogun)
- Persona 5: each Palace has a calendar deadline for the whole operation, and missing one can end the run; Mementos, the procedural dungeon, has no deadline. — [Gfinity guide](https://www.gfinityesports.com/guides/persona-5-royal-palaces); [GamerGuides walkthrough](https://gamerguides.com/persona-5/guide/story-walkthrough/july/a-new-threat-2) (fan guides)

### Inferences
- The turtling risk under our rules: guards return to patrol after investigating (rule 23), caution ends after 3 rounds (rule 29), searches end after 2 turns (rule 28), and patrols are deterministic. Nothing escalates, so the safest play is almost always to wait one more round for a patrol to pass. The overwatch setup that RULES.md itself describes ("lure a guard into a hallway, stun it from overwatch, tie it up next turn") can be repeated on every guard at no cost except time, and time costs nothing.
- Context (rule 8) is our only battle-long brake, and it limits only AIs. Operators can stall indefinitely. Waiting also costs no context, so an AI can idle until the moment is perfect.
- Tied-up guards are out of the battle permanently unless found (rule 35), so a patient team can clear a whole map one guard at a time. Phantom Doctrine's check-in mechanic is the closest existing answer to exactly this.
- The XCOM 2 debate suggests hard fail-timers are the most resented form. Escalating pressure (Invisible Inc.) and score-style time pressure (Shadow Tactics badges) are better received. Our "puzzle, not a statistical back-and-forth" north star and the Into the Breach touchstone argue for pressure that is visible and deterministic.
- Options ranked from cheapest to most systemic. These are proposals, not decisions:
  1. Rating-only pressure (basic, cheap): rounds taken shows on the end screen with a par, like a Shadow Tactics time badge. No fail state. One counter and one label.
  2. Exfil clock (basic): breaching the Prime Data Cache starts a visible countdown, or escalates the map (every zone goes on caution, reinforcements arrive at entry points). This pressures only the end of the phase, which fits the heist feel of "grab it and run", and it leaves the planning phase untouched.
  3. Check-ins (optional, strong fit): a tied-up or hidden guard misses a check-in after N rounds, and the closest guard goes to investigate their last patrol point. It reuses Investigate (rule 23) and Hidden (rule 38), and it directly prices the clear-the-map strategy.
  4. Security level (systemic, the Invisible Inc. answer): a per-phase counter rising each round and with each full alert. Thresholds turn on cameras, add a patrol, or shorten Noticed-to-Seen. It is the most effective and the most work: new map data, new UI and tuning.
  5. Fixed round budget (the Into the Breach answer): it fits the puzzle north star, but a hard fail timer in a stealth game is what XCOM 2 players fought against most. Not recommended as the default; possibly for specific missions.
- DESIGN.md's principle is "add a cost only when something is game-breakingly overpowered." The honest framing for Bryson is that playtesting should first show whether waiting is dominant. The research suggests it almost always is in stealth games without a clock, so it's worth watching for in the very next playtest.

### Gaps
- Klei's exact alarm-tracker numbers and the reasons behind them (the fandom wiki returned 402; no developer postmortem found).
- Into the Breach's specific turn counts per mission and Subset's reasoning; the GDC 2019 postmortem ([GDC Vault](https://gdcvault.com/play/1025772/-Into-the-Breach-Design)) wasn't available as text. Commonly cited as 4 to 5 turns, but I did not confirm this.
- Hitman's pressure model (it has essentially none; time pressure is self-imposed through ratings). Not separately sourced.

## 2. Mission variety: objective types, optional objectives, ratings and replay challenges

### Takeaway
We have one objective verb (breach the Prime cache, then extract) and no ratings. Comparable games vary objectives per facility type (Invisible Inc.), add optional feats as badges or challenges (Shadow Tactics, Hitman), and use mastery to make replays meaningful. For a story-driven campaign with hand-built maps, a small set of objective variants built from verbs we already have, plus 2 to 4 badges per mission, gives most of the value cheaply.

### Cited Findings
- Invisible Inc. gives each facility type its own objective; most objectives mean retrieving an item from a secure location and escaping, and some are about stealing as much money and equipment as possible. — [Wikipedia: Invisible, Inc.](https://en.wikipedia.org/wiki/Invisible,_Inc.)
- Reviewers list Invisible Inc. mission goals as downloading corporate files, stealing covert technology, and rescuing fellow agents from holding cells. — [Game Informer review](https://www.gameinformer.com/games/invisible_inc/b/pc/archive/2015/05/13/invisible-inc-game-informer-review.aspx?amp) (via search summary); [SRF review](https://www.srf.ch/radio-srf-3/games-review-invisible-inc)
- The Invisible Inc. wiki advises players to "make use of the Alarm Level to maximize your objectives": the clock and optional loot are designed to trade against each other. — [Invisible Inc. wiki, Game Objectives](https://invisibleinc.gamepedia.com/Game_Objectives)
- Shadow Tactics badges per mission: a time limit, Hardcore difficulty, and feats such as unique kills, not harming enemies, or not using certain skills. — [Wikipedia: Shadow Tactics](https://en.wikipedia.org/wiki/Shadow_Tactics:_Blades_of_the_Shogun)
- Hitman 2's progression centers on mastering locations; mastery unlocks new starting locations, agency pickups and items, earned through challenges or Performance XP for actions such as silent takedowns and hiding bodies. — [Checkpoint Gaming interview with Andreas Krogh](https://checkpointgaming.net/news/2018/10/hitman-2s-lead-designer-andreas-krogh-talks-progression-difficulty)
- Tore Blystad: "That's the essence of Hitman; it is made to be replayed"; scoring was designed for "a big spread of scores." — [GameWatcher](https://www.gamewatcher.com/2012-11-09-hitman-sniper-challenge-dev-considering-standalone-title)
- Critique: Hitman 2016 locked many opportunities behind mastery, which made creative first-time play frustrating and felt like forced replay value. — [Inverse](https://www.inverse.com/article/27668-hitman-season-1-review-impressions)
- Phantom Doctrine: every mission can be completed in infiltration mode with careful planning, so a full ghost is always possible. — [bit-tech review](https://bit-tech.net/reviews/gaming/pc/phantom-doctrine-review/1/) (via search summary)
- Into the Breach: islands with more hazardous conditions give greater rewards, and the player chooses which island to protect next. — [Wikipedia: Into the Breach](https://en.wikipedia.org/wiki/Into_the_Breach)

### Inferences
- Objective variants we could build almost entirely from existing rules. These are proposals:
  - Steal (physical): an item to carry out, reusing Carry (rule 37: carrying means only moving, while the AI stays free). A natural second objective after "breach the cache."
  - Rescue or extract a person: a resistance contact or captured cell member, carried or escorted. It reuses Carry, and could also be the consequence mission for a captured Operator (section 3).
  - Sabotage: breach and use a specific device, such as a power hub's blackout (rule 26) or a server, then leave. It reuses Breach and device verbs.
  - Plant (the reverse of steal): get an Operator or a relay robot to a node and hold tether (rule 45). It reuses the relay rules.
  - Ghost or no-trace: a badge rather than a mission type ("no full alerts", "no tied-up guards").
- Badges are basic and cheap. They need only end-of-mission counters for things the rules already track: full alerts, rounds taken, guards tied up, optional caches taken, Operators downed. 2 to 4 per mission, shown before the mission, never gating story content, which avoids the Hitman critique. They give replay value to hand-built maps without procedural generation, which matters at 10 hrs/week.
- Optional caches already fill the "secondary objective" slot (rule 51). The missing piece is a reason to trade risk for them, which is the pressure system in section 1. Without a clock, optional caches are free and always taken, so they stop being a choice. This links gap 1 and gap 2: optional objectives only work as risk and reward if time or alert costs something.
- Mission rating (S/A/B or similar) is optional. Badges are clearer and fit the puzzle north star better.

### Gaps
- No developer source found on how Mimimi chose badges per mission (the GDC 2018 talk by Moritz Wagner, [Game Developer](https://gamedeveloper.com/design/video-the-production-behind-i-shadow-tactics-i-), was not available as text).
- Invisible Inc.'s end-of-run scoring was not sourced.

## 3. Failure and consequence without permadeath

### Takeaway
Our failure model is binary: win, or restart the phase. There's no partial success, and a downed Operator costs nothing after the battle ("their escape is handwaved," rule 49). Games without permadeath keep failure meaningful through capture and rescue (Invisible Inc. holding cells), lost growth (Triangle Strategy), lost time on a calendar (Persona), or carrying a downed ally out (Invisible Inc. drag-to-exit). This is a basic gap: Bryson needs to choose what a downed Operator costs.

### Cited Findings
- Invisible Inc.: agents go down to a single shot. A downed agent stays out for the run unless revived with a medkit or dragged to the exit by another agent, and the game ends if all agents die. — [Wikipedia: Invisible, Inc.](https://en.wikipedia.org/wiki/Invisible,_Inc.)
- TV Tropes notes a downed Invisible Inc. agent is only unconscious, and good as new after one dose of medgel. — [TV Tropes](https://www.tvtropes.org/pmwiki/pmwiki.php/VideoGame/InvisibleInc)
- Rescuing fellow agents from holding cells is an Invisible Inc. mission goal, and the run starts with two agents, with more freed during missions. — [Game Informer review](https://www.gameinformer.com/games/invisible_inc/b/pc/archive/2015/05/13/invisible-inc-game-informer-review.aspx?amp); [Wikipedia](https://en.wikipedia.org/wiki/Invisible,_Inc.)
- Triangle Strategy: no permadeath; fallen allies return next map, but a fallen unit earns no more XP that battle, so its cost is missed growth. Players can retreat at any time during their turn and keep earned XP and kudos. — [RPGFan review](https://www.rpgfan.com/review/triangle-strategy); [ProGameGuides](https://progameguides.com/project-triangle-strategy/is-there-permadeath-in-triangle-strategy/)
- A Triangle Strategy reviewer says some battles can be incredibly difficult even without the threat of losing units. — [Sportskeeda review](https://www.sportskeeda.com/esports/triangle-strategy-review-a-silly-name-hides-glorious-tragic-experience)
- Fire Emblem: Intelligent Systems was divided over Awakening's Casual mode. Higuchi argued permadeath makes "each victory all the more exhilarating", but admitted it kept people from trying the game; Casual was made because many players lack the patience to restart a map each time a unit dies. — [Engadget](https://www.engadget.com/2013-04-03-intelligent-systems-divided-over-fire-emblem-awakenings-casual.html); [Nintendo Life](https://www.nintendolife.com/news/2013/04/talking_point_fire_emblem_awakening_the_big_casual_mode_debate)
- Nintendo Life notes that without permadeath a unit can be thrown into certain doom as a distraction, a tactic that weakens stakes. A fan suggested losses should matter to the story instead, for example by removing some story elements. — [Nintendo Life](https://www.nintendolife.com/news/2013/04/talking_point_fire_emblem_awakening_the_big_casual_mode_debate)
- Persona 5: missing a Palace deadline can end a run, while most other mistakes are recoverable; a team wipe costs calendar days. — [Gfinity guide](https://www.gfinityesports.com/guides/persona-5-royal-palaces) (fan guide)

### Inferences
- What "handwaved escape" leaves unresolved:
  1. Sacrifice is free. Fire Emblem's casual-mode problem applies directly: under rule 49 the optimal play can be to spend an Operator as a decoy, since a downed Operator costs nothing after the battle. Heavy armor (3 hits) makes Operator B an ideal sacrificial blocker.
  2. No partial success. A mission is won or restarted. There's no "won, but at a cost" outcome, which is where much of the drama in XCOM and Invisible Inc. comes from.
  3. Story. With three Persona-style stable Operators and the Andor-style cell theme, "the team left someone behind and they walked home" is a narrative hole.
- Proposals (Bryson decides; ranked by cost):
  1. Drag them out (basic, nearly free): let Carry (rule 37) apply to downed Operators. A downed Operator who is carried to extraction is fine; one left behind triggers a consequence. It reuses an existing rule.
  2. A consequence for one left behind (basic; pick one):
     - Captured: the next story beat or mission becomes a rescue (Invisible Inc. holding cells). Strong for the story, and the most content-heavy option.
     - Lost town time: the Operator is unavailable for some town days, which only works if the town has a calendar (section 4), as Persona uses time as the currency.
     - Heat or intel loss: OpenBrain learns something, and the next mission starts with extra security (one more camera, a patrol, or Caution already on). Cheap, systemic, and on-theme.
  3. Downed costs a reward (optional): optional caches taken by a downed Operator are lost unless carried out. A simple risk-and-reward link.
  4. Retreat (optional, a Triangle Strategy idea): a voluntary pullout that keeps nothing, offered as an alternative to restarting the phase. Low value while a mission has no meta to protect.
- Rule 50's phase restart, with no undo in V1 (rule 4), is a reasonable default for a puzzle game; Into the Breach-style hard-failure is less relevant since we have no run structure. Restarting a whole phase could take a long time on large maps, so it interacts with the mission length targets in section 5.

### Gaps
- Mario + Rabbids' failure handling (no permadeath, retry) wasn't researched within the tool budget.
- How XCOM 2 wounds and recovery time are tuned; the XCOM fandom wiki returned HTTP 402.

## 4. The campaign loop: hub, pacing, pre-mission choices and economy

### Takeaway
The best-regarded loops connect hub and battle through a shared scarce resource: time (Persona's calendar, Invisible Inc.'s 72 hours), a campaign threat clock (XCOM 2's alien win condition), or a choice of where to go next (Into the Breach islands). Our town is defined only as walk, talk, investigate, buy and install upgrades. Nothing yet connects what the player does in town to how a battle plays, except locked loadouts (rule 10). The cheapest basic link is pre-mission intel and loadout selection in town.

### Cited Findings
- Persona 5's calendar splits each day into periods, so every slot competes with other goals; players are pushed to optimize their days because of deadlines and progression requirements. — [Persona 5 analysis PDF](https://advocacy.ccrjustice.org/Resources/cEyQJB/8AD264/Persona5RoyalDayToDayGuide.pdf) (no clear author; low confidence); [vehikl blog](https://npm.vehikl.com/blog/persona-5-should-you-rush-palaces-or-take-your-time-1764814375)
- A Persona 5 palace normally takes several visits: securing the route, leaving to send the calling card, and returning for the treasure and boss. — [GamerGuides](https://gamerguides.com/persona-5/guide/story-walkthrough/july/a-new-threat-2)
- Invisible Inc.: three days before the final mission, with travel and missions using that time; stations sell upgrades and equipment for money; each run starts with two chosen agents. — [Wikipedia: Invisible, Inc.](https://en.wikipedia.org/wiki/Invisible,_Inc.)
- XCOM 2: the aliens have their own campaign win condition, which can be delayed through sabotage but never permanently, so the endgame plays as a race. — [Game Informer](https://gameinformer.com/games/xcom_2/b/pc/archive/2015/12/10/xcom-2s-board-game-influences-and-the-race-against-the-alien-clock)
- Into the Breach: after the first island the player chooses which island to protect next; harder islands give bigger rewards; permanent unlocks come at milestones. — [Wikipedia: Into the Breach](https://en.wikipedia.org/wiki/Into_the_Breach)
- Triangle Strategy offers repeatable Mental Mock Battles for XP in the encampment; underleveled units gain boosted XP. — [GameSpot](https://gamespot.com/articles/triangle-strategy-easy-xp-guide-how-to-level-up-all-units-fast/1100-6501362/); [ProGameGuides](https://progameguides.com/project-triangle-strategy/is-there-permadeath-in-triangle-strategy/)
- Hitman 2 unlocks starting locations and agency pickups through mastery: an entry-point choice and a pre-mission loadout choice earned through play. — [Checkpoint Gaming](https://checkpointgaming.net/news/2018/10/hitman-2s-lead-designer-andreas-krogh-talks-progression-difficulty)

### Inferences
- What our loop lacks, in order of how basic it is:
  1. Pre-mission planning screen (basic): choose each AI's 3 chips (rule 10 already locks them per battle, so the choice exists but has no screen) and each Operator's gear (V1 loadouts are "one robot or two gadgets"). Without a choice, locked loadouts are just a fixed setup. It's cheap and testable in V1 with the existing chips.
  2. Intel from town (basic, a story-strong link): investigating in town reveals things about the next map, such as which networks exist (rule 14 hides them until connected), camera positions, patrol routes, or an alternative entry. It's the Persona "secure the route" idea in our verbs, and it makes the town matter to battle without needing V2 progression.
  3. Entry choice (optional): two or three starting points per phase, unlocked by intel (Hitman's starting locations). It needs level design support (section 5).
  4. A time resource in town (decision needed): a Persona-style calendar or deadline ("the facility moves its data on day X"). Strong pacing tool, but it adds a whole system. Bryson's "built to explore the story I need to tell" phrasing in DESIGN.md suggests deciding this alongside the plot.
  5. Economy (V2, keep minimal): cryptocurrency from Tertiary caches and blueprints from Secondary caches (rule 51) are already one currency and one unlock track. Invisible Inc. shows one currency plus a shop is enough. Avoid a second currency until the town exists.
  6. Practice or replay battles (optional): Triangle Strategy's mock battles suggest replaying cleared missions for badges in place of grinding, which fits "upgrades add options, not bigger numbers."
- Pacing of battle versus town: none of the sources gave numbers. Persona's palaces take several visits within a deadline; a reasonable starting assumption for us, untested, is one mission per story chapter, with one or two town days before it.

### Gaps
- No source found on Fire Emblem: Three Houses' monastery-to-battle ratio, Chained Echoes' structure, or measured hub-versus-battle time splits in Persona. Not researched within the tool budget.
- No developer source on how XCOM 2's Avatar clock was tuned.

## 5. Level design basics for stealth tactics: routes, risk and reward areas, entries, landmarks, mission length

### Takeaway
The sources here were thin: developer talks exist (Mimimi GDC 2018, Subset GDC 2019) but couldn't be read as text. What is sourced: missions with multiple approaches and full-ghost possibilities (Phantom Doctrine), restricted zones that change detection rules (Phantom Doctrine), environmental modifiers like snow and darkness (Shadow Tactics), and short missions as a deliberate design goal (Into the Breach versus XCOM's hour-long battles). Our zones (rule 29) and light rules (rule 25) already support most of this. What's missing is written targets for mission length and route count.

### Cited Findings
- Into the Breach deliberately kept battles short with a turn limit and telegraphed enemy moves, against XCOM battles of up to an hour. — [Wikipedia: Into the Breach](https://en.wikipedia.org/wiki/Into_the_Breach)
- Phantom Doctrine has restricted areas where being spotted triggers an alarm, while agents move freely elsewhere; every mission can be completed fully in infiltration; scouting patrol patterns and timing moves is key. — [The Sixth Axis](https://thesixthaxis.com/2018/08/14/phantom-doctrine-review); [bit-tech](https://bit-tech.net/reviews/gaming/pc/phantom-doctrine-review/1/)
- Shadow Tactics uses environmental elements like snow and darkness to change enemy behavior. — [Wikipedia: Shadow Tactics](https://en.wikipedia.org/wiki/Shadow_Tactics:_Blades_of_the_Shogun)
- Invisible Inc. shuffles hallways, security, objectives and extraction points procedurally. — [PC Gamer review](https://pcgamer.com/invisible-inc-review)
- Hitman's core tenets, per IO's principal level designer and game director, are elaborate levels, depth of options and player freedom. — [Inverse 25th anniversary interview](https://www.inverse.com/gaming/hitman-turns-25-retrospective-interview) (from search summary)
- Mimimi's GDC 2018 talk by Moritz Wagner covers how the levels were designed and paced; Mimimi has since ended its activities. — [Game Developer](https://gamedeveloper.com/design/video-the-production-behind-i-shadow-tactics-i-); [Game*Spark interview, March 2026](https://www.gamespark.jp/article/2026/03/19/164105.html)

### Inferences
- Proposed level-design checklist for each phase map, for Bryson to approve or change:
  1. At least two routes to the Prime Data Cache: a physical route and a network route, such as relaying a robot to a far access point (rule 45) or using a separate network (rule 14). The network-versus-physical split is our unique angle and should be visible in every map.
  2. One optional risk-and-reward area per phase holding a Secondary or Tertiary cache, placed off the main route, ideally in a more watched zone.
  3. A restricted zone (Phantom Doctrine): the V2 note in rule 21 ("deep inside an enemy headquarters... every enemy in the zone") is already this idea.
  4. Readable landmarks: one per zone (a lit ad screen, a parked diesel truck, the power hub). Devices double as landmarks because they're the interactive pieces.
  5. Extraction placement: not the same as the entry, so getting out after the Prime breach is a second short puzzle. This pairs with the exfil clock from section 1.
  6. A ghost route that exists (Phantom Doctrine's point): every phase should be completable without a full alert, so the ghost badge is fair.
- Mission length target (my proposal; not sourced): with three Operators acting through both halves of each turn, 10 to 20 rounds per phase and 20 to 40 minutes per phase keeps phase restarts (rule 50) tolerable. Measure it in the next playtest rather than assume it.
- Scope note: hand-built maps at 10 hrs/week rule out Invisible Inc.-style procedural generation. Badges and objective variants on reused maps are the cheap replayability route.

### Gaps
- No readable developer source on map size, route counts or mission length targets in Shadow Tactics, Desperados III or Invisible Inc. The two GDC talks would be the primary sources if Bryson wants them watched.
- No data on average real-time minutes per mission in any of the compared games.

## Summary of gaps against our rules, basics versus optional

| # | Gap | Our rule | Basic or optional | Cheapest proposal |
|---|---|---|---|---|
| 1 | No pressure, so waiting is free | Rule 22 | Basic: needs a decision | Exfil clock after the Prime breach, plus a rounds-taken badge; check-ins for tied-up guards as a next step |
| 2 | One objective type | Rule 51 | Basic for a campaign; not for V1 | Steal, rescue and sabotage variants built from Carry, Breach and verbs |
| 3 | No ratings or replay goals | None | Optional, cheap | 2 to 4 badges per mission from counters we already track |
| 4 | Downed Operators cost nothing; sacrifice is free | Rules 41 and 49 | Basic | Carry downed Operators (extend rule 37); a left-behind consequence: heat, capture or lost time |
| 5 | No partial success | Rules 49 and 50 | Basic | Falls out of 4 plus optional caches lost with a downed carrier |
| 6 | Town doesn't affect battle | DESIGN.md town decision | Basic | Pre-mission planning screen plus intel from town |
| 7 | No campaign clock or time resource | None | Decision for Bryson, with the plot | Persona-style deadline per mission, if the story wants it |
| 8 | No level-design checklist or length target | None | Basic for content work | Two routes (physical and network), one optional area, extraction separate from entry, measure rounds per phase |
