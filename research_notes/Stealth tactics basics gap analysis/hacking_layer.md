# Hacking layer: dual-layer network design in other games vs our network rules

Scope note. Our rules referenced below (RULES.md, V1): AI acts on its own 2 AP, interleaved freely with its Operator (rules 3, 5); move 1 AP to any node within 3 hops, Jump through Breached nodes (13); hack 1 AP for 10 hack power, refund on a one-action breach (6); context 0–100 is the battle-long brake, full context halves hack power, compaction 1 AP keeps 25% and degrades chips (8, Context, Compaction); hacking never fails (9); a network is unknown until connected, connecting reveals layout and verbs (14); opposition (ICE, daemons, security hubs, enemy AIs) deferred to V2 (15); verbs cost 0 AP and 5 context, usable from anywhere on the network (16); sound areas and responding guards previewed before a verb (18); no battle-wide clock (22); tether 2 tiles, relays (45); Crashed is defined (42) but nothing in V1 can cause it.

Research budget note: 15 tool calls. The Invisible Inc. fandom wiki blocked fetching (HTTP 402), so Invisible Inc. specifics come from search snippets of the wiki, Klei forums and reviews. Several games in the brief (Watch Dogs, Phantom Doctrine, Satellite Reign, System Shock, Hacknet, Uplink, Ruiner, Republique, Ghostrunner, Tactical Breach Wizards) were not researched with sources; see Gaps.

## How other games handle integration vs separation, hacking economies, counter-hacking, physical effects, readability and turn pacing

### Takeaway
The best-regarded designs (Invisible Inc., Cyber Knights: Flashpoint, Cyberpunk 2077's quickhacks) keep hacking on the same map and the same clock as the physical game, pay for it from a scarce resource, and push back with escalating opposition tied to the physical alarm. Shadowrun Returns' separate Matrix, on a different clock with the decker's body inert, is the cautionary case. Our rules already get integration and pacing right; what we lack is the opposition half.

### Cited Findings
Invisible Inc. (Klei, 2015)
- Incognita is the hacking interface, used to "disable alarms and security cameras" and remove locks on safes; the player "may need to collect power" to use it — [Wikipedia](https://en.wikipedia.org/wiki/Invisible,_Inc.)
- Incognita can take control of cameras, open safes, or override sentry guns or bots — [Game Developer, Road to the IGF](https://gamedeveloper.com/design/road-to-the-igf-klei-entertainment-s-i-invisible-inc-i-) (via search snippet)
- After the player ends a turn, enemies act and in most locations the alarm level goes up; higher alarm levels bring new security forces — [Wikipedia](https://en.wikipedia.org/wiki/Invisible,_Inc.)
- Alarm segments fill from each passing turn, a guard being alerted, or hacking a device that carries a daemon; a full tracker raises the alarm level — [bit-tech review / search snippet](https://bit-tech.net/reviews/gaming/invisible-inc-review/2/)
- An early-build developer update described each alarm stage as triggering at 5 points, the first stage turning on inactive cameras (may be outdated) — [r/incognita, Feb 12 update 8](https://reddit.sudovanilla.org/r/incognita/comments/1xqihm/february_12_update_8)
- Player advice (2015): inactive cameras activate at alarm level 1, and "firewalls go up at alarm level 2", so do most hacking before then; a harder setting triggers effects 5 turns earlier — [Klei forums, beginner/experienced tips](https://forums.kleientertainment.com/forums/topic/59447-beginner-experienced-jump-tips/)
- Daemons are traps on devices. Examples: Blowfish advances the alarm tracker 1–3 turns; Castle adds 3 firewalls to a random uncaptured device and reveals it on the map; Felix temporarily triples firewalls on safes; Echo recaptures devices, giving them 1 firewall; Authority makes safes alarmed so opening one draws a guard and adds 1 alarm; some daemons only appear at set alarm levels or campaign days — [Invisible Inc. wiki, Daemons](https://invisibleinc.fandom.com/wiki/Daemons?oldid=5566) (via search snippet)
- Counter-programs: Hunter kills a daemon; Taurus moves a daemon to another device — [Invisible Inc. wiki, Daemons](https://invisibleinc.fandom.com/wiki/Daemons?oldid=5566) (via search snippet)
- Power economy ties to physical play and augments: Network Siphon gains PWR equal to the alarm level each level; Thermal Generator gives 2 PWR after using an item with cooldown 3+ — [cyberly item guide](https://www.cyberly.org/game-cheats/pc-walkthroughs/invisible,-inc.-item-guide.html)
- A reviewer: "a limited pool of power and the backlashes that come as the threat level climbs soon mandate judicious hacking" — [PC Gamer review](https://pcgamer.com/invisible-inc-review) (via search snippet)
- Incognita is a mode the player switches into to interact with in-game systems — [GamingOnLinux](https://www.gamingonlinux.com/2018/08/play-it-now-invisible-inc/) (via search snippet)

Shadowrun Returns / Dragonfall / Hong Kong (Harebrained Schemes)
- Returns: three decker turns in cyberspace equal one meat-world turn; the decker's body is inert and the party must defend it — [Shacknews, "Shadowrun Returns enters the Matrix"](https://www.shacknews.com/article/78948/shadowrun-returns-enters-the-matrix) (via search snippet)
- Player reaction to Returns: Matrix sections called tedious and "backtracking-intensive", "not difficult, simply dull" — [Steam discussion](https://steamcommunity.com/app/234650/discussions/0/46476145494035844)
- Dragonfall Director's Cut began "streamlining matrix systems by using teleport regions instead of hallways", only for some systems — [Steam changelog](https://steamcommunity.com/sharedfiles/filedetails/changelog/317704781)
- PCWorld called Dragonfall's decking "neutered", with fewer mandatory sessions, and a hacker companion usually joining so the player rarely decks — [PCWorld review](https://www.pcworld.com/article/444220/shadowrun-dragonfall-review-even-better-than-the-original.html)
- A player complaint: decking programs "are only useful once you've already been seen", clashing with the Matrix as a stealth system — [Steam discussion, Hong Kong](https://steamcommunity.com/app/346940/discussions/0/527274088401275541)
- Hong Kong rebuilt the Matrix as real-time stealth past Watcher IC with patrol routes and sight cones; being spotted starts combat and fills an attention meter that, maxed, raises the alarm — [RPGamer review](https://archive.rpgamer.com/games/srun/srunhk/reviews/srunhkstrev1.html) (via search snippet)
- Hong Kong dev update: heat "no longer rises for each turn the player is in the matrix"; a yellow alert comes from line of sight to IC or failing to hack Blocker IC — [GameBanshee, HK Update #13](https://gamebanshee.com/k3auw) (via search snippet)
- Hong Kong's data nodes use a separate Simon-says / pattern minigame, widely skippable — [RPGamer review](https://archive.rpgamer.com/games/srun/srunhk/reviews/srunhkstrev1.html) (via search snippet)

Deus Ex: Human Revolution (2011)
- Each node has a security rating and a detection chance shown before capture; once security is alerted it races to the player's entry node — [GameBanshee preview](https://gamebanshee.com/3a9) (via search snippet)
- Critics called success "far too heavily reliant on luck" and the system "50% guesswork and 50% reload spam" — [Game Developer, "Deus Ex: Non-Revolution"](https://www.gamedeveloper.com/design/deus-ex-non-revolution-)
- Early grids need no strategy (shortest path wins); consumables appear later — [GameBanshee preview](https://gamebanshee.com/9w6h) (via search snippet)
- Mankind Divided's hacking was considered its most significant improvement — [Inverse](https://inverse.com/article/20184-deus-ex-mankind-divided-hacking-praise)

Cyberpunk 2077 quickhacks (2.0 era)
- RAM is the bottleneck resource; investing in max RAM and RAM regeneration is standard advice — [Steam discussion](https://steamcommunity.com/app/1091500/discussions/0/3875968426427378816) (via search snippet)
- Nearly all combat and control quickhacks are "Traceable"; enemy netrunners trace the player, and quickhacks during a trace fill the bar faster — [nukesdragons build guide](https://nukesdragons.com/@tobias/cyberpunk-2077/character/solo-netrunner) (via search snippet)
- Counterplay to trace: Memory Wipe reduces trace 25% out of combat and makes following hacks untraceable; neutralizing an enemy netrunner with System Collapse clears the trace; Self-ICE blocks the first incoming hack — [nukesdragons, Memory Wipe](https://nukesdragons.com/cyberpunk-2077/db/quickhacks/memory-wipe); [Steam discussion](https://steamcommunity.com/app/1091500/discussions/0/603018985919787137)
- A player reports trace ends only by moving about 500 feet away or neutralizing the whole group — [Steam discussion](https://steamcommunity.com/app/1091500/discussions/0/603018985919787137) (anecdotal)

Midnight Protocol (LuGus, 2021)
- Turn-based network board: move, break or tunnel firewalls, with a limited deck of programs per run — [Windows Report review](https://windowsreport.com/midnight-protocol-game-review/)
- Pressure is a turn limit: after a set number of turns the SysOp finds the player's deck, steals money each turn and can delete programs — [indiecator first impressions](https://indiecator.org/2022/01/08/midnight-protocol-first-impressions/) (via search snippet)
- Praised for success requiring "carefully balancing aggressiveness and planning" — [OpenCritic aggregate](https://opencritic.com/game/12145/midnight-protocol)

Cyber Knights: Flashpoint (Trese Brothers, 2024)
- Hacking compared to Deus Ex but turn-based: nodes with varying security, beaten with purchased programs; "a tense, deep puzzle" — [RPGFan review](https://www.rpgfan.com/review/cyber-knights-flashpoint/)
- The Wire Ghost hacker "cannot render systems completely under your control" — [RPGFan review](https://www.rpgfan.com/review/cyber-knights-flashpoint/)
- Hacking gives major stealth advantages by shutting security devices off faster and longer, if the team reaches the right Matrix host; combat, stealth and hacking support the heist theme — [RPG Codex review](https://rpgcodex.net/content.php?id=12625)

### Inferences
- Comparison table (our column from RULES.md; others from findings above):

| Dimension | Invisible Inc. | Shadowrun Returns | DX:HR | Cyberpunk 2077 | Midnight Protocol | Ours (V1) |
|---|---|---|---|---|---|---|
| Layer | Same map, mode toggle | Separate space, own clock (3:1) | Separate minigame screen | Same world, no layer | Network only | Same turn, network view over the map |
| Resource | PWR, scarce, gathered | Program uses, decker HP | Consumables, tries | RAM, regenerates | Program deck size | AI AP 2/turn + context 0–100 (battle-long) |
| Pressure | Alarm rises per turn; firewalls up at alarm 2; daemons | IC, alarm | Detection chance, race to entry | Trace by enemy netrunners | SysOp after N turns | None in V1 (rule 15) |
| Failure | No dice; risk is daemons/alarm | Combat in Matrix | Random detection | Trace reveals you | Deck compromised | Never fails (rule 9) |
| Physical cost | Agents must reach consoles for PWR | Inert body defended | Player standing at terminal | Line of sight to target | n/a | Operator within 2-tile tether (Tether) |
| Pacing | Same turn | Party waits | Pauses action | Real time | n/a | Interleaved in one turn (rule 3) |

- Our interleaving (rule 3) and the tether (Tether, rule 45) already solve the Shadowrun problem: no separate clock, no idle party, and the physical cost is "an Operator parked near a panel", which is the softer, more interesting form of Shadowrun's inert body.
- Our determinism (rule 9) matches Invisible Inc. and Midnight Protocol and avoids DX:HR's luck criticism. Every successful deterministic design moves the risk out of dice and into opposition that escalates (firewalls, daemons, trace, SysOp). We moved risk out of dice but have not put it anywhere yet except context.
- Invisible Inc.'s single best integration trick: the hacking resource is collected in the physical world (consoles), so the network economy pulls the Operators' routes. Our context only drains and is reset by compaction; nothing in the physical map refills or feeds it.

### Gaps
- Exact Invisible Inc. numbers (PWR per console, firewall counts by device, alarm stage thresholds in the release build) could not be fetched; the wiki returned HTTP 402.
- Shadowrun Returns: no Harebrained postmortem was found stating the designers' own view of the Matrix problem; criticism here is reviews and players. The GameBanshee update #51 on deckers returned HTTP 403.
- Not researched with sources (recalled only, unverified): Watch Dogs (one-button environment hacks on a phone, enemy hackers in 2/Legion), Phantom Doctrine, Satellite Reign (hacking via range-limited infiltration, resource "energy"), System Shock (separate cyberspace), Hacknet and Uplink (trace timers as the core pressure), Ruiner, Republique (camera-hopping as the core verb, closest analogue to our camera Breach), Ghostrunner, Tactical Breach Wizards. Republique and Uplink/Hacknet are worth a follow-up: camera-hopping readability, and trace timers as the canonical hacking-pressure mechanic.
- No GDC talk specifically on dual-layer hacking was found; the Invisible Inc. GDC talk ("Designing Procedural Stealth", James Lantz) exists but its content on Incognita was not accessed — [GDC Vault](https://gdcvault.com/play/1021919/contactUs).

## Known failure modes of decker/hacker layers and how successful games avoided them

### Takeaway
Five recurring failures: a separate slow layer the party waits through (Shadowrun Returns), luck masquerading as skill (DX:HR), a repeated shallow puzzle that goes stale, hacking that only matters after stealth breaks (Dragonfall/Hong Kong), and hacking so strong it trivializes stealth (Cyberpunk netrunners, by reputation). Successful games kept hacking on the same clock, made it deterministic but contested, and made it scarce.

### Cited Findings
- Shadowrun Returns' 3:1 Matrix clock and inert body left the rest of the party defending it; players called the Matrix "tedious" and the part they disliked most — [Shacknews](https://www.shacknews.com/article/78948/shadowrun-returns-enters-the-matrix); [Steam discussion](https://steamcommunity.com/app/234650/discussions/0/46476145494035844)
- Players wanted more variety in the Matrix: "puzzles, conversations/interactions with ICs and nodes and more types of programs" — [Steam discussion, Hong Kong](https://steamcommunity.com/app/346940/discussions/0/527274088401275541) (via search snippet)
- Decking "only useful once you've already been seen" undermined it as stealth — [Steam discussion, Hong Kong](https://steamcommunity.com/app/346940/discussions/0/527274088401275541)
- Hong Kong's real-time Matrix stealth split players: "boring stealth real time gameplay is the worse" vs feeling more like a decker — [Steam discussion](https://steamcommunity.com/app/346940/discussions/0/528398719808571175) (via search snippet)
- DX:HR: luck-driven detection produced reload spam — [Game Developer](https://www.gamedeveloper.com/design/deus-ex-non-revolution-)
- Minigames done hundreds of times go stale (Fallout terminals, BioShock pipes); frequent minigames must be quick, rare ones can be longer — [GamesBeat, "The Art of Hacking"](https://gamesbeat.com/the-art-of-hacking-how-hacking-mini-games-miss-the-point/); [bugnet.io design guide](https://bugnet.io/blog/how-to-design-a-hacking-or-lockpicking-minigame)
- A bare "hack computer" button turns a narratively important skill into an "I win" button, while full simulation is expensive — [Mike Russo IF Comp 2024 reviews](https://intfiction.org/t/mike-russos-if-comp-2024-reviews/70780/17)
- Players argue skill investment should eventually auto-solve Cyberpunk's Breach Protocol — [Tildes thread](https://tildes.net/~games/1icz/cyberpunk_2077_breach_protocol_autosolver)
- Unsighted's devs cut a console-typing hack for being "too much like actual coding", then added a timed event because point-and-click attacks needed no skill — [Unsighted devlog](https://unsighted.itch.io/unsighted-agent/devlog/417195/creation-of-the-hacking-minigame)
- Invisible Inc. keeps hacking scarce: limited power plus rising backlash "mandate judicious hacking" — [PC Gamer](https://pcgamer.com/invisible-inc-review) (via search snippet)

### Inferences
| Failure mode | Our exposure | Why |
|---|---|---|
| Separate layer, party waits | Low | Rule 3 interleaving; one turn holds both halves |
| Luck over skill | None | Rule 9, deterministic progress |
| Stale repeated puzzle | Low to medium | No minigame (DESIGN.md: stats, not a minigame). Risk shifts to "hack, hack, hack" being a rote button if every node is just goal ÷ 10 with no opposition |
| Only useful after detection | Low | Our verbs are lures and vision, stealth-first by design |
| "I win" / trivializes stealth | Medium to high | Verbs usable network-wide for 0 AP (rule 16), Breached cameras never report (rule 19), refunds uncapped except by context (rule 6, Refund). With no opposition, a held network only grows stronger |
| Too-abstract node graph | Unknown | Depends on the network view; nodes are physical devices, which helps |

- The highest live risk is the "I win" button: once the network is held, nothing takes it back. Invisible Inc. answers with firewalls rising on alarm and daemons that recapture (Echo); Cyber Knights caps it by design (the hacker can't fully control systems).
- The second risk is rote clicking: deterministic hacking without contest reduces each node to arithmetic the UI can do for the player. Fine as long as the interesting choice is which node and when, not whether.

### Gaps
- No sourced evidence found for the common claim that Cyberpunk 2077 netrunner builds trivialize combat; it is widely held but was not cited here.
- No source found measuring how often players skipped Shadowrun's Matrix when optional.

## What basics our network lacks, with proposals

### Takeaway
Our network has the integration basics (same turn, physical cost via tether, deterministic, layout and verbs revealed on connect, sound previews). The true basics missing are: any opposition or take-back in V1, a pre-breach cost preview, and a link between network pressure and the physical alert. Information hacks, physical refuel points and trace are strong optional ideas.

### Cited Findings
- Escalating network opposition tied to the physical alarm: firewalls up at alarm 2, daemons on devices — [Klei forums](https://forums.kleientertainment.com/forums/topic/59447-beginner-experienced-jump-tips/); [Invisible Inc. wiki](https://invisibleinc.fandom.com/wiki/Daemons?oldid=5566)
- Take-back of held devices: Echo recaptures devices with 1 firewall — [Invisible Inc. wiki](https://invisibleinc.fandom.com/wiki/Daemons?oldid=5566)
- Pre-action risk shown: DX:HR shows each node's detection percent before capture — [GameBanshee preview](https://gamebanshee.com/3a9)
- Trace as counter-hacking that exposes the hacker physically — [nukesdragons](https://nukesdragons.com/@tobias/cyberpunk-2077/character/solo-netrunner)
- Turn-limited network pressure: Midnight Protocol's SysOp — [indiecator](https://indiecator.org/2022/01/08/midnight-protocol-first-impressions/)
- Hacking resource refilled in the physical world (PWR from consoles; augments tie PWR to alarm and items) — [Wikipedia](https://en.wikipedia.org/wiki/Invisible,_Inc.); [cyberly](https://www.cyberly.org/game-cheats/pc-walkthroughs/invisible,-inc.-item-guide.html)
- Hong Kong's alert meter rising per round a watcher sees the decker, distinct by enemy type — [RPGamer](https://archive.rpgamer.com/games/srun/srunhk/reviews/srunhkstrev1.html)

### Inferences
Proposals. "Basic" means most comparable games have it and its absence changes how the system plays; "optional" means a good idea, not a hole. All are recommendations, not decisions.

| # | Gap | Who does it | Why it matters | Proposal (our terms) | Basic? |
|---|---|---|---|---|---|
| 1 | No network opposition at all in V1 (rule 15); Crashed (42) is unreachable | Invisible Inc., Shadowrun, DX:HR, Cyberpunk, Midnight Protocol | Without it, the network only grows; context is the sole brake, and it's a budget, not a threat. This is the "I win" risk | Smallest test that doesn't need node density: a firewall value on some nodes (adds to Goal) instead of separate ICE nodes, so opposition sits on existing devices. One daemon type as a per-node flag revealed on connect (rule 14), e.g. "on Breach: the zone goes on caution". This tests pressure without adding nodes, which was rule 15's worry | Basic |
| 2 | Network pressure isn't tied to the physical alert | Invisible Inc. (firewalls at alarm 2), Hong Kong alert meter | Links the layers: getting seen makes hacking harder, so stealth and network feed each other | During Caution (rule 29), devices in that zone gain a firewall (e.g. +10 Goal) and lose refund eligibility. Uses existing caution and zones; no battle clock needed (rule 22 stays) | Basic |
| 3 | Nothing re-locks a Breached node | Invisible Inc. Echo; our own Security hub idea (Glossary) | Held networks are permanent, so early breaches snowball | A guard who investigates a Breached device (e.g. one lured by a camera going dark, rule 19) resets it to enemy control with progress kept at 0. Physical counter-hacking with no new enemy type | Basic (cheap form) |
| 4 | No pre-breach cost preview | Invisible Inc. shows firewalls; DX:HR shows detection % | Rule 18 previews sound; breaching should be equally readable. Refund chains (rule 6) are hard to plan without it | On hover: hacks needed at current power (after chips and full-context halving), context cost (Numbers: context per hack), and a "Refund" badge if one action will Breach. Show the same for verbs (5 context) | Basic |
| 5 | Readability of two layers | Invisible Inc. Incognita mode | Rule 16 lets verbs fire from anywhere, so the player must see network state on the physical map | Breached state shown on the device in the physical view (icon or tint), the network view as a toggle overlay anchored to device positions, and the circuit lines already in Devices. Show which AI is connected through whom (Relay) | Basic |
| 6 | No physical trace or exposure from hacking | Cyberpunk trace; DX:HR race to entry | Currently the only physical exposure is the tethered Operator. Fine, but no enemy reacts to the AI itself | Optional V2: hacking certain nodes (e.g. Prime Data Cache) marks the access point in use; the closest guard investigates it (rule 18 lure mechanics). Makes the tether a real risk without a timer | Optional |
| 7 | Context only drains | Invisible Inc. consoles give PWR | A physical refuel point makes the network economy pull Operator routes, the strongest integration trick found | Optional: a "server rack" or "console" device that, when Breached, gives a one-time context relief (e.g. −20 context) or a free compaction without chip degradation. Rewards physical routing | Optional |
| 8 | Information hacks are chip-only | Invisible Inc. reveals devices/maps; DESIGN.md says hacking gathers enemy weaknesses and locations | Locate/Predict exist, but no node yields intel itself | Optional: a terminal device whose Breach reveals guard patrol routes in its zone, or reveals a separate network's layout (rule 14) before an Operator gets there | Optional, but promised by DESIGN.md |
| 9 | No turn-limited pressure | Midnight Protocol SysOp; Invisible Inc. alarm per turn; Uplink/Hacknet trace (unverified) | Rule 22 rules out a battle clock; Bryson decided this | Note only: if pressure is wanted later, a per-network trace (rises only while an AI is connected and hacking) keeps rule 22 intact. Hong Kong removed per-turn heat as unpopular, a point for leaving it out | Optional |
| 10 | Hacking never fails (rule 9) | Invisible Inc. and Midnight Protocol are also deterministic | Not a gap. Matches DESIGN.md and avoids DX:HR's criticism. Risk should come from rows 1–3, not dice | Keep | n/a |

- Strengths to keep, found in no worse form elsewhere: interleaving in one turn (rule 3); tether as the physical cost; deterministic progress (rule 9); network layout revealed on connect, no survey action (rule 14); sound previews before verbs (rule 18); relays sending access behind enemy lines (rule 45), a cleaner version of Shadowrun's decker-in-danger.
- Inferred watch item: verbs at 0 AP from anywhere (rule 16) multiply with three AIs. If playtests show turns with many free verbs per AI, a per-turn verb budget or verb AP is the simplest brake; Bryson's cost principle (DESIGN.md, 2026-10-04) says add a cost only when it's game-breakingly overpowered, so this is a watch item, not a proposal.
- Rows 2 and 3 together are the cheapest way to make the network contested in V1 without adding node types, which addresses rule 15's stated reason for deferring opposition (node density).

### Gaps
- No source compared hacking-layer density (opposition nodes per device) across games, which is the exact question rule 15 defers on.
- Whether Invisible Inc. shows daemons before hacking (rather than on trigger) was not confirmed; I recall daemons are hidden until triggered unless revealed by a program, but this is unverified.
- Enemy AIs (our V2 idea) have no close sourced analogue beyond Cyberpunk's enemy netrunners and Midnight Protocol's SysOp; Watch Dogs 2's online hacker invasions may be relevant but were not researched.
