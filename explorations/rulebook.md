# Rulebook V1

- Status: V1 implemented (2026-10-04), not yet played. V2 items below.
- Output: `RULES.md` at the root is the working copy. Once V1 is done, it's published to Google
  Drive as a document for sharing and comments (Bryson, 2026-10-02).
- Scope: the whole game, not only battle: upgrades, enemies, abilities, the Operators' own
  upgrade path, and whatever outside battle feeds them (Bryson, 2026-10-02).
- Method: one concept at a time, like any exploration. Tangents for research are welcome.
- Inherits: the rules so far in [battle-core.md](battle-core.md) and [battle-mvp.md](battle-mvp.md).

## Order of work

1. Action system (built in V1, 2026-10-04).
2. Combat: cover, hit model, what a non-lethal weapon means for enemies.
3. Stealth and detection.
4. Downed and recovery.
5. Hacking depth.
6. Enemy AIs and enemy hacking.
7. Mission structure: phases, handover, the vault rule.
8. Progression: stats, the AI's three pipelines, the Operators' upgrade path.

## 2026-10-02 — Action system: direction (Bryson)

- Why it's needed: few units, so each one needs real flexibility, doing several things in one
  turn. Creative play is rewarded, not punished, without becoming overpowered.
- No Fire Emblem rigidity. Its simplicity works because of the weapon triangle and units that
  persist across the game; here it would be boring and limiting.
- Context stays its own resource, not part of the action economy. Compaction and skills get
  formalized later as a system that works alongside it.
- Direction: stealth tactics, plus letting clever, risky play continue the turn.
- The split economy, a working idea: Operators play in the style of Invisible Inc., careful and
  stealth-first, because they're real people. AIs play in the style of Gears Tactics,
  aggressive with refunds, because a crashed AI isn't gone for good.
- Only AIs get refunds. It abstracts the idea that AI capability grows exponentially, while
  human capability grows linearly.
- A downed Operator is out for the rest of the battle. Nothing carries over.
- An AI that "dies" is kicked back to the backpack and its context is wiped.
- The network needs a rework to give the aggressive AI economy something to work on, since it
  is nearly empty of enemies before the first boss. This needs research first.

## 2026-10-03 — Network rework: direction (Bryson, after research)

- Playtest finding: on small maps a hacked camera mostly shows what the team already sees. A
  camera is worth hacking when it watches somewhere far off, like a chokepoint. Cloak has the
  mirror problem: it matters against surveillance, not against a guard looking right at you.
- Surveillance is an enemy. Every camera in a level starts out enemy-controlled and can spot
  Operators. Hacking one is mainly about disabling the threat; the vision is a bonus. Bryson
  thought this was already in the build, and it isn't. It's a gap to fill.
- The network gets its own opposition, and the AI uses enemy pieces as lily pads to set up
  bigger plays, the way checkers lets you jump twice in one turn. Taking out an enemy piece
  sets up a combo.
- Breaches pull physical levers, as many as we can conceive of. Hacking's identity lives in its
  utility.
- A playground: anything the team can access, it should be able to manipulate somehow. How you
  beat a level depends on creativity and strategy, not on pattern recognition finding the one
  optimal route. The hard part is keeping quality high while widening player agency.
- Lily pads aren't only enemies: anything the AI hacks can be one. An idea, not yet confirmed
  for the game: finishing a hack in a single action refunds that action point, so the AI can
  start another action. The reasoning: a smarter, more efficient model finishes a hack in fewer
  tokens, so it has time left over to attempt another.
- Enemy AIs ramping up after the first boss (battle-core, 2026-09-23) is still the intent. Its
  shape waits until more of the rulebook is filled in.
- No battle-wide clock, like an alarm or trace. Most hacks are limited by whether they can be
  done, not by time.

Research behind this, all from the chat on 2026-10-02: Invisible Inc. (cameras as threats,
daemons, PWR), Midnight Protocol (trace, ICE, a deck of programs), Watch Dogs (environment as a
weapon), Rainbow Six Siege (cameras worth having because the level hides the key spots).

## 2026-10-03 — Closing the network loop (Bryson)

- "Breached" is the formal term for a node that has been hacked.
- The refund is in: a single hack action that takes a node from untouched to breached refunds
  that action point. Finishing the last part of a breach that took several turns doesn't count.
- Context is the only brake on chains, with no hard cap. It mimics the real world: someone who
  knows nothing about AI could get good at this game and come away with the basic principles of
  steering one.
- Overflow (leftover hack points carrying into the next hack) is dropped. There's no real-world
  correlate for it, and on top of the refund it's a hat on a hat that risks being overpowered.
- An AI starts with 2 AP, and moving through the network costs 1. Upgrades can raise the AP an
  AI starts with or can hold.
- Network opposition: ICE that blocks a route until it's broken, daemons that trigger when a
  node is breached, and security hubs that re-lock things. They get fleshed out with the network
  layer's UI later.
- A camera that spots an Operator alerts guards that someone is in the area, and the closest
  guards go to investigate. Tougher areas, such as deep inside an enemy headquarters, can alert
  every enemy in a zone.
- Cloak hides an Operator from surveillance only, never from a guard's own eyes. The fiction:
  the AI edits the video stream in real time to cut the Operator out.
- Device verbs are the backbone of the playground. Every device mixes from a short list, such as
  power, sense, move, lock, signal and harm. Bryson imagines a radial menu: point the stick to
  pick a verb, or press its key (L for lock, M for move).
- Lily pads: Jump is in (a compromised node extends the AI's reach that turn). Borrowed power
  (a compromised piece lends its abilities for the turn) is liked, but it needs a way to make
  moving power between pieces intuitive in the UI.

## 2026-10-03 — The Operator half (Bryson, after studying Invisible Inc.)

Research in the chat: Invisible Inc. (AP spent only on movement and peeking, attacks free and
capped at one per turn, sprint trades noise for AP, knockouts that wear off unless the guard is
pinned, ambush stance, always-visible vision cones), XCOM 2 concealment, Mutant Year Zero
silent takedowns, Desperados III and Shadow Tactics (readable cones, queued combos).

- The lessons Bryson adopted: movement is the scarce resource, attacks are capped separately,
  the rules are readable, risk dials, a non-lethal hit buys time and creates follow-up
  decisions, and the player chooses when a fight starts.
- HP-based combat trades a good puzzle for more RPG. The puzzle wins.
- Operators spend AP from one pool on movement, so moving is part of the turn's whole economy.
- One shot per turn, outside the AP pool, and it doesn't end the turn: it can come in the middle.
- Sprint is in. It needs every guard's vision cone visible at all times while the guard is
  outside the fog.
- An ambush or overwatch stance is in.
- The Operator's and the AI's AP interleave freely within a unit's turn. This replaces TURN-01
  and TURN-02 in [battle-core.md](battle-core.md).
- Gear: weapons and gadgets that restrain enemies non-lethally are equipment, gained outside
  battle and used in it. Bryson's example: a drone with a small circle of vision, upgradable
  with a single-use ability, such as stunning an enemy or hacking one small target (a goal-10
  node at today's numbers).
- Level design follows from this: medium-small maps, dense with things to manipulate, which
  suits an AI moving around a network. It means investing in good environment models and
  objects so maps read as tactical spaces, not mazes of one repeated wall.

## 2026-10-03 — Enemies, Operators and gear (Bryson)

- North star: "more of a puzzle with RPG progression and a story, like Into the Breach if it were
  a stealth game and had a story and proper upgrades."
- Enemies have no HP. Enemy variety comes from mixing traits, alone or in combination: needs two
  stuns, immune to the basic shot so it takes a specific gadget, wakes up faster, wakes nearby
  guards.
- Operators follow the Invisible Inc. model: one or two hits and they're downed. Getting spotted
  is the real cost.
- A stun lasts 4 turns by default, to be tuned. That leaves time for an Operator to tie the guard
  up, which takes them out for the battle unless another enemy finds and unties them.
- Gear is the Operators' upgrade path, alongside the AI's three pipelines. Upgrades should feel
  like new abilities and options, not a bigger number.

## 2026-10-03 — Armor, the warning beat, turns and stuns (Bryson)

- Every Operator starts at one hit. Basic armor absorbs one more. Heavy armor absorbs two, but
  costs 1 AP because it's heavier and slows the Operator down.
- The warning beat, in Bryson's example: an Operator moves forward, and the move stops when it
  reveals a guard. The guard is alerted at once if the Operator is in its cone, but it's still the
  player's turn. The Operator sprints behind cover, and their AI spends an action to cloak them,
  so they drop off the radar. If the guard can't reach them on its next turn, the Operator moves
  around the other side of the cover, the guard loses track, gives up the search and goes back to
  its patrol.
- Tying up costs 2 AP, adjacent only.
- A round is every unit on the map taking a turn. Hidden enemies take theirs out of sight and join
  the turn-order display once revealed. An Operator's turn lasts until their AP is spent or they
  end it.
- A stun lasts a number of turns, not rounds, and drops from 4 to 3 for testing. The stunned enemy
  stays in place with no vision. The point is time to tie them up without stuns being
  overpowered.
- The Into the Breach comparison is about being a puzzle rather than a statistical back-and-forth.
  It isn't about copying its mechanics.

## 2026-10-03 — Clarifications and the end-game feeling (Bryson)

- Cloak works in the warning-beat example because the Operator is behind cover: it erases them
  from the cameras and the enemy network the guard's search relies on.
- A stun counts the stunned enemy's own turns, so 3 turns is roughly 3 rounds.
- Heavy armor means three hits in total.
- An alerted guard acts on its own turn, never during the player's (rule 17 as worded).
- An early upgrade: a predictive algorithm that shows what each enemy intends to do next turn,
  given the current situation.
- What hacking is for: gather intelligence on enemies, keep yourself hidden, and use the
  environment to stay hidden on the way to the goal, incapacitate enemies, or open shortcuts. The
  map itself should feel manipulable if the player's hacking is strong enough. By the end of the
  game, the player enters a new level, surveys it, and is already planning how to chain abilities
  into a combo.
- So the visuals and the UI have to make clear what can be manipulated and how. Some cases are
  easy (a light switch, a self-driving car rolling into a guard); harder ones need real thought.
- Map size: not as small as Into the Breach's 8×8, but small and dense. Spending most of your AP
  on movement should be an intentional positioning choice, because the same AP could go to any
  number of other actions.

## 2026-10-03 — Operator AP, overwatch, gadgets and robots (Bryson)

- Operators start with 8 AP, to see how it plays.
- Opening an unlocked door is free; locking one costs 1 AP. Deploying the AI to the network costs
  1 AP.
- Overwatch belongs to the weapon economy, one per turn. It's a disposition, almost a status: the
  Operator can still move after setting it if they have AP, and when the turn ends they're in
  overwatch.
- Gadgets cost different amounts of AP. Example: a flashbang costs 2 AP and blinds the guards in
  its blast radius for 3 turns.
- Robots are gadgets with a high deployment cost (3 AP) and then their own action economy: an AP
  pool, a speed that puts them in the turn order, and vision shared with the Operators. They
  scout, distract, and can carry a simple hack or a single-use stun. One hit downs them, and no
  upgrade changes that. Two so far: a drone, and a dog bot like Boston Dynamics' Spot.
- Peeking needs its own aside: Bryson isn't sure what it is or how it would work here.

## 2026-10-03 — Peeking, overwatch, robots as relays (Bryson)

- Peeking (option a of three, after an aside on Invisible Inc.'s peek): through doors only, 1 AP,
  and the Operator sees into the space beyond until their turn ends.
- Overwatch fires at the first enemy that moves into the Operator's line of fire. It should be
  something the player controls, as in Bryson's example: a drone lures a guard down a hallway,
  an Operator in overwatch shoots him, and an Operator ties him up next turn.
- A downed robot is gone for the rest of the battle and rebuilt afterwards.
- Robots never hack on their own. Bryson confirmed dropping that entirely: a robot is a relay
  for the Operator's AI instead, so it can be sent behind enemy lines for intelligence and
  access. Its fragility is the counterweight.
- Gadgets sit outside the one-shot limit. They cost AP and count as an Operator action.

## 2026-10-03 — Relays, sprint, and narrowing down (Bryson)

- A robot relays like an Operator's tether, from near an access point. If it's hit while there,
  the connection is severed at once; the AI is pulled out and keeps its context.
- The robot's link back to the Operators has no range limit. Add one only if that proves
  overpowered.
- An AI connects through one Operator or robot at a time.
- Connecting through a robot costs the same 1 AP. A robot ends its turn on an access point, and
  on their next turn any Operator can choose to send their AI in through it.
- Sprint adds no AP and makes no noise. It's 3 tiles for 2 AP, so 8 AP moves up to 12 tiles.
- As written, sprint beat walking in every case. The catch (option b of four): an Operator who
  sprints can't shoot or set overwatch that turn. Move far, or keep your shot ready.
- The AI's AP is separate from the Operator's, because autonomy is the point of an AI. Whether it
  should be the same kind of AP system is open: study which system gives the most dynamic,
  combo-able network phase. This is the next topic.
- Enemy types and their traits go on the back burner. One vanilla standard enemy until the rules
  are tuned. Bryson didn't like the stun variants (noise wakes them, passing guards wake them,
  shorter counts for heavy enemies).

## 2026-10-03 — The AI's action system: skills as cards (Bryson)

Research in the chat: Gears Tactics executions (+1 AP to every other squad member), Shin Megami
Tensei's Press Turn (efficiency costs half a turn, failure costs extra), Persona 5's Baton Pass,
Slay the Spire and Midnight Protocol (energy plus a deck), Transistor's Turn() and Functions,
and banking in Triangle Strategy and Octopath.

- Lean into cards, like the battle chips in Mega Man Battle Network. The player sees what the AI
  can do this turn from its preloaded, predetermined skills.
- New skills are created in the upgrade sections outside battle.
- The player can see which skills are loaded in context and which are available but not yet
  loaded, and can look closer at any skill to see what it does.
- Missing and important: an easy way to get information on skills and abilities. The menus also
  need an aesthetic overhaul; they feel plain.
- No Press Turn. It's compelling, but it may overcomplicate things without a clear strategic
  throughline.
- Shared compute is in: one AI gives up compute it would have used so another AI runs faster
  and does more that turn.
- No planning mode. The AI acts one action at a time, interleaved with its Operator. Making the
  human plan every step is the opposite of the fantasy: the AI does lots of things.

## 2026-10-03 — Skill chips (Bryson)

- A full loadout, no randomness. Retro-futurism: skills come on a futuristic floppy disk, loaded
  into the AI's context, holding all the information it needs to perform the action.
- A firm cap of 3 chips per AI. Enough for variety and specialization, and the cap is strategic
  substance: one AI can't specialize in several things. Bryson imagines skills that make an AI
  better at hacking specific things.
- AIs have no internet access. They know only what they recall from training and what's on
  their chips.
- No Program Advance in V1. Playtesting might show it adds fun, but on its face it isn't enough of
  a value-add.
- Loading a chip costs context only.
- Device verbs are not skills. That would be too limiting and cumbersome.
- Shared compute is 1 AP given for 1 AP received, only while the Operators stand close together.
  They physically link, like daisy-chaining Mac Minis.
- There's no failure in hacking, only progress. A complete failure just means no progress.

## 2026-10-03 — Who specializes how, and chips that degrade (Bryson)

- Revised: AIs start out fairly general. Chips, post-training and the context/memory file system
  give them their specialties.
- Operators have physical strengths and weaknesses, plus abilities and skills of their own from
  their backgrounds. Like Elden Ring, where any character can become anything and the start only
  sets stats and loadout: the player might choose aspects of each character to specialize them
  early, or leave everyone roughly equal by default and specialize over the game once they know
  the mechanics. A direction, not settled.
- A hacking chip is a plain 1.5× multiplier: hack for 10 becomes hack for 15. Bryson relaxes "no
  bigger numbers" for the network specifically, because it gives a reason to load chips. Their
  context cost is nontrivial, so loading everything on turn one isn't the play.
- Compaction degrades chips: 1.5× becomes 1.25× after the first compaction, and the second
  removes it, so it has to be loaded again. The movement skill is the exception: it only reloads
  if compaction takes context below its own size (if it takes 10, compacting to 9 unloads it).
  This replaces CTX-05.
- Chips are locked for the whole battle. Compute sharing needs the Operators adjacent.
- Clarified the same day: two of the characters already had their AIs, whose personalities are
  set. The protagonist meets his new partner AI at the start of the game, as he joins the
  resistance, and that's how the mechanics are taught. His AI starts fairly generic. After a
  tutorial battle, the player answers a series of questions, like the opening of Pokémon Mystery
  Dungeon, that set the AI's characteristics, starting abilities and specialization.

## 2026-10-04 — Chips revisited, identical Operators (Bryson)

- The two existing AIs arrive with set starting specialties, but can be shaped into anything,
  as in Elden Ring.
- For V1, every Operator has exactly the same in-game stats; the only difference is personality.
  The value of Operator builds can't be gauged yet. Playtesting may change this. This sets aside
  the Elden Ring idea for Operators from 2026-10-03.
- Correction: every AI skill is a chip. Cloak is a chip. Movement is the one free chip: it
  doesn't count toward the cap of 3, but it still has to be loaded. The 1.5× multiplier is one
  example of a kind of chip, not what every chip is.
- Chip categories are a side assignment. Bryson's starting guess: Surveillance, Weapon Systems,
  and Infrastructure. Nothing is solid yet; explore the options.
- Linking for shared compute costs nothing: standing adjacent is enough. Principle: add a cost
  only when something is game-breakingly overpowered, like a free peek in Invisible Inc.
  Otherwise a cost just limits the places a thing is useful.
- "Memory" was the context window, not a new memory system; it's out of rule 12.
- How compaction degrades a chip is defined chip by chip.
- All existing abilities (Probe, Locate, Cloak, their uses and cooldowns) get reworked as new
  chips are created, so the whole set is coherent with the updated rules.
- The DESIGN.md decision on character abilities is replaced (2026-10-04). "The network is the one
  place plain multipliers are allowed" stays out of it: that's a principle that can be broken,
  not a restriction.

## 2026-10-04 — Stealth and detection (Bryson, after a study of stealth games)

Research in the chat: Invisible Inc. (two-tier cones, where the noticed tier draws a guard to
investigate), Mark of the Ninja (show everything the character would know; Nels Anderson's
rules), XCOM 2 (red detection tiles while planning a move), Metal Gear Solid (alert phases,
caution), Thief and Splinter Cell (light as visibility, lights as lures), Shadow Tactics and
Hitman (evidence, restricted zones).

- Cones have two tiers, noticed and seen.
- Moves preview which tiles would get the Operator noticed or seen, as in XCOM 2.
- Light controls visibility, and that's a big part of hacking. Splinter Cell is the lesson:
  lights work both as a lure and to hide the Operators.
- After an alert, the area stays on caution for a while before settling.
- A found stunned or tied-up guard raises an alert. That calls for a dragging system that isn't
  unintuitive: no AP cost. An Operator next to the body drags it along with normal movement, or
  pushes it ahead and steps forward with it.
- No sound. Detection is visibility only.

## 2026-10-04 — Sound returns, cameras, hiding and carrying (Bryson)

- No "no sound" rule. What Bryson described next is a sound system; it just doesn't apply to the
  Operators, who are assumed to move silently.
- Darkness (option a of three): the seen tier shrinks to a short range and the rest of the cone
  counts as noticed. Same effect as "only noticed in the dark", but it meshes better with the
  other systems.
- All cameras see only in light. An upgraded camera with night vision needs a higher-level hack.
- What makes the game work: guards share vision through the cameras. It's their biggest strength
  and their biggest weakness, because false data from our hacked cameras is why none of them
  see anything wrong.
- Distraction: lights, opening a door, moving a car, switching on a machine that does nothing on
  its own but draws a guard within range. Every object has a sound radius, depending on the
  object: around 5 tiles for a typical one, about 1 for an electric car, about 10 for a diesel
  truck. Guards who hear something head toward it. Only seeing an Operator directly causes a
  full alert. Why the change: opening a door right next to a guard who acts as if nothing
  happened breaks immersion. Bryson wants a full session to iron this out.
- Caution: Bryson asked for research into how other games handle it before deciding.
- Hiding a body: out of sight is enough, and there are receptacles too (a dumpster, a car's
  trunk, a gym locker, a closet, a trash can). Tossing a body in is a free action when adjacent.
- Carrying replaces dragging: an Operator picks up a tied-up guard over their shoulder. While
  carrying, they can only move, but there's no movement penalty.

## 2026-10-04 — Vocabulary, caution, carrying (Bryson)

- Hearing a sound means investigating, not a full alert. "Alerted" stays reserved for a full
  alert.
- A standing rule: whenever something new is defined or an in-game term is used, put the
  definition at the top of the message. RULES.md defines every term twice, briefly in a glossary
  and in full with edge cases, so the AI implementing the rules understands them deeply. Now in
  AGENTS.md.
- Caution for V1 is option (a), as in Metal Gear: a zone stays on caution for a few rounds with a
  visible countdown, the noticed tier counts as seen, then it resets.
- Picking up and putting down a body are both free. Putting a body down on a receptacle's tile
  puts it inside, hidden.
- A stunned enemy can be carried too, not only a tied-up one. One that isn't tied up can make
  noise when it wakes and draw another guard to let it out.

## 2026-10-04 — Closing the open edge cases (Bryson)

- Overwatch drops at the start of the Operator's next turn, so they can choose again.
- No AP carry-over in V1 (V2 idea below).
- ICE, daemons and enemy AIs can crash an AI. Revised: a crashed AI goes back to the backpack or
  its original access point and keeps its context, because the context lives in the backpack.
  This reverses "context wiped" from 2026-10-02.
- What a crash costs, settled after comparing three options (keep context, wipe it, or a forced
  compaction, each with a one-turn reboot): a forced compaction. Keeping context is a pure tempo
  loss. Wiping it is a better reset than compaction, so players would crash on purpose. A forced
  compaction is never better than compacting on purpose, keeps a silver lining, matches how real
  agents resume from a summary, and adds no new mechanic. Bryson: "the best middle ground." The
  crashed AI goes back to the backpack; after the reboot turn the Operator can deploy it again
  for 1 AP or cut their losses.
- Caution lasts 3 rounds for V1.
- Guards don't search receptacles. The exception: a guard inside one who isn't tied up and is no
  longer stunned makes noise, which guards walking by within the sound area can hear.
- A stunned guard who wakes up unfound, and wasn't tied up, raises an alert.
- Compaction: Claude picked 1 AP as the default, at Bryson's request. Bryson judges it in
  playtesting.

## 2026-10-04 — The sound session (Bryson, after research)

Research in the chat: Hitman (only the closest NPC investigates; Instinct mode highlights what
can be interacted with), Shadow Tactics (Yuki's flute pulls every guard in range; tougher enemies
only glance), Mark of the Ninja (every sound drawn as a ring), Watch Dogs (device hacks as lures).

- Who responds is set by the device (option c of three): a small sound draws the closest guard in
  range, a big one every guard in range.
- Sound radius is counted in walking steps (option b of two): around walls, through open doors,
  stopped by closed ones, drawn as highlighted tiles.
- Before using a device verb, the sound area is shown and the visible guards who would respond
  are marked. Guards in the fog respond too, unseen.
- A guard who hears a sound walks to the source, looks around for one turn, and returns to its
  patrol.
- In V1 each sound is a single moment.
- Zones are named areas the map author draws, roughly one per room or yard.

## 2026-10-04 — Hacking depth: verbs and autonomous things (Bryson, after research)

Research in the chat: Breath of the Wild's chemistry engine (states, elements, multiplicative
gameplay), Divinity: Original Sin 2 (surfaces combining), Watch Dogs (camera hopping, families of
hacks), Cyberpunk 2077 (Ping reveals the network), Hitman (Instinct highlights interactables).

- Harm is dropped. Powering an electric fence has the same effect, so a harm verb shouldn't exist.
- Devices and non-autonomous systems share one verb list: power, sense, move, lock, signal.
- Autonomous things (turrets, drones, dog bots) give manual control through a layout specific to
  their type. A turret's: the player doesn't choose targets, but can tell it, independently and
  for free, to target enemies and shoot or to target nothing.
- V1: every verb of a Breached device can be used, each once per turn. An electric car can be
  powered on and moved in one turn, not powered on and off. The player's options grow as they
  hack more things, and it stays self-limiting.

- Once per turn means per AI turn (option a): each AI uses a device's verbs in its own turn.
  Unlocking devices stays a continual benefit, and the player has a reason to set up big combos,
  with access to every device hacked so far.
- Verbs are free in AP and cost context.
- An AI connected to a network can use every hacked device on it, without being on its node.
- A hacked turret picks the nearest enemy: guards and anything they control, robots, drones,
  even other turrets. Hack one of two neighbouring turrets to shoot the other; the other only
  treats it as hostile after the first hit, and shoots back once it recovers from the stun.
- A hacked enemy robot joins the turn order with its own AP. It has its base version, or any
  upgrade it had. A one-time ability is only usable if the robot hadn't used it before the hack.
- States and verbs as the backbone (the chemistry-engine approach) is a foregone conclusion: it's
  what defining the verbs means.
- Bryson wants to review the verb list's names and functions.

- Revised: breaching doesn't automatically do anything. It gives access to the device's verbs.
- Sense is dropped. A camera is on when you hack it, so you get its vision; power covers it.
- Signal is specifically a lure: always a fake or spoofed signal sent to a device. Through a
  camera, it sends the enemy an AI-generated video of an Operator, so they think someone is on
  camera who isn't. A phone powered on makes no sound; signal sends it a fake call.

- Revised again: signal is dropped, and move becomes activate, which does what move did and
  covers the phone case too. The verbs are now power, activate and lock.
- A Breached camera sends a spoofed feed by default: Operators don't appear to the enemy, even
  directly in front of it. Activating it spoofs an Operator on the feed, drawing enemies toward
  the camera.

- Wording: not "spoof". A Breached camera simply doesn't alert the enemy to the team's Operators
  and units, because it's no longer an enemy camera; we hacked it.
- A device has to be powered on before it can be activated.
- Cameras can't be activated. Powering a camera off is how it lures the enemy.
- Doors: Operators open most doors; the AI unlocks and locks them. An Operator can also lock a
  door, but has to be physically at it, while the AI can lock one remotely from the network.
- No new verbs: power, activate, lock.

## 2026-10-04 — Device sheets (Bryson)

- Claude drafted 16 V1 devices with states, verbs, sound and goals (all placeholders). Bryson:
  that covers V1; more can come in V2 without muddying the water. The sheet is in RULES.md under
  Devices.
- Cars accelerate forward or backward, the player's choice, until they hit something.
- A powered-off electric fence is still a wall, just a harmless one.
- A hub killing several cameras at once is wanted, especially for a mission that calls for it.
  In a blackout the guards run their routes and search room to room, and the darkness applies to
  both sides: Operators and guards each see only a small window, and everything else is greyed
  out like the fog. The guards can't see you, and you can't see them.
- An ad screen's flash is a visual lure: only guards who can see the screen respond.
- Anyone in the dark can still see into a lit area beyond their small window.

## 2026-10-04 — Network opposition deferred (Bryson)

Research in the chat: Shadowrun Returns (white and black ICE, escalating with alertness),
Invisible Inc. (firewalls, hidden daemons that hit resources), Hacknet (ports that need specific
tools), Midnight Protocol (ICE as a hazard). Claude offered options for ICE (wall, patrol, both),
daemons (crash, context spike, re-lock, tip-off; a "?" marker revealed by Ping) and security hubs
(re-lock on caution).

- Bryson isn't feeling any of them; they're V2 material. The network's topology may need to
  change, or at least its real density has to be seen first: several enemy types on today's
  maps would mean an enemy on every other node. Held until Bryson playtests.

## 2026-10-04 — Circuits, separate networks, revealing a network (Bryson)

- Circuits as Claude proposed: a hub's circuit is a list in the map data; a device is on at most
  one; a dead circuit can't power its devices; the network view draws lines from the hub, and
  hovering the hub highlights its devices.
- A map can hold several networks that don't connect. An AI is on one at a time. The vault idea
  is a separate, air-gapped network.
- No survey action (option b of three): an AI connecting to a network unlocks that network on the
  map, but doesn't show the other networks connecting other devices on the map.

## 2026-10-04 — Mission structure (Bryson, after research)

Research in the chat: Invisible Inc. (exit elevator, dragging downed agents out, rescuing those
left behind), Hitman (routes, optional challenges, unlocks), Into the Breach (bonus objectives),
XCOM 2 (loot, choosing extraction).

- The facility mission is one battle with two phases.
- At a handover, context, loaded chips, downed Operators, hit armor and robots with the team
  carry across; guards, caution and the fog reset.
- Downed Operators can be left behind. Their escape is handwaved for now, sorted out in V2.
- Optional caches: new skills, blueprints for things the team can 3D-print like gadgets, or a
  small to large amount of cryptocurrency.
- Losing restarts the current phase, with exactly the conditions the team entered it with.

## 2026-10-04 — Progression deferred (Bryson)

- Claude noted that the specialization triangle is what post-training was meant to be, and
  proposed V1 hardware (AP, context size, tether range). Bryson: progression as a whole goes to
  V2. V1 tests the systems, not how they progress.
- Caches are cut from the V1 test map; their rewards do nothing until progression exists.

## 2026-10-04 — The guard's turn (Bryson, after research)

Research in the chat: Invisible Inc. (a spotting guard goes into overwatch; the agent has 1 AP
to break line of sight; guards always hit), Into the Breach (telegraphed attacks), XCOM 2 (hit
chances, ruled out).

- Aim, then fire (option b of three): an alerted guard moves, aims at a unit it can see, shown as
  a line, and fires at the start of its next turn only if the unit is still in the line. The
  player gets a full turn to break it.
- Guards move a flat 4 tiles (placeholder), with no AP.
- A guard's range is its seen tier, with line of sight.
- Guards shoot robots too, and prefer Operators when both are in line.
- The shot hits the first unit in the line, so a robot can body-block for an Operator.
- On its next turn the guard fires first, if still valid, then moves and aims again.

## 2026-10-04 — The V1 chips (Bryson)

Claude drafted six chips from the old abilities plus multipliers: Cloak, Probe, Locate, and
Surveillance, Weapons and Infrastructure exploits (1.5×). Shared rules: loading costs context
once (CTX-04), an active chip costs 1 AP per use, no uses-per-battle or cooldowns, and compaction
degrades every chip in two steps.

- Multipliers are 2×, degrading to 1.5×, then unloading.
- Cloak is dropped entirely; with Breached cameras never reporting the team, it isn't useful
  anymore.
- Probe is dropped; borrowing a device's sensors felt too contrived.
- Locate stays: "an awesome ability you would want to use every turn. We need more like that."
- Surveillance, Weapon Systems and Infrastructure are the right placeholder categories, exactly
  the split Bryson had in mind.

- What makes Locate work (Claude's reading): useful every turn, answers a real question, maps onto
  something real AI does, and sets up other plays. Claude drafted Predict, Voice clone, Extended
  thinking and Fork in that mold.
- Kept: Locate, Predict, Extended thinking, and Fork renamed Subagent. Voice clone is dropped as
  too powerful. The V1 chip table is in RULES.md.
- One action earns at most one refund, so Subagent can't snowball on its own.

## 2026-10-04 — V1 setup and the hand-off

Claude drafted test loadouts, robot numbers and a placeholder table in the chat. Agreed so far:
when Operators share a speed, the player picks which acts next. Bryson then approved the whole
draft, and it's in RULES.md under V1 setup. He asked Claude to draft a placeholder test map on the
facility exterior (level layout stays his call) and to write all the documentation: another AI
will draft an implementation plan from it, and a third will implement it. The hand-off is
[v1-implementation-brief.md](v1-implementation-brief.md), with the test map, the changes from the
current build, and the defaults Claude filled in that Bryson hasn't reviewed.

## 2026-10-04 — Astra's plan review (Bryson)

Astra drafted an implementation plan from the brief and raised 23 review points: five on
architecture, Claude's nine defaults, the electric fence, and eight gaps in the rules. It also
caught a real bug: a turn ended when the Operator's AP ran out, stranding the AI's AP and the
shot. Claude recommended an answer for each; Bryson accepted all of them. The answers are in
RULES.md and summarized in the brief's "Decided after Astra's review" section.

## 2026-10-04 — V1 implemented (Claude, from Astra's final plan; scripted runs, not played)

Bryson asked Claude to implement Astra's final plan (increments A to H) without checking in. The
build in `game/` now plays the V1 rules on the brief's test map, with the loadout screen in front.
Verified by the two test suites and by scripted runs of the real battle scene with screenshots;
nobody has played it yet.

Where Astra flagged the documents, the build reads them as below. These are Claude's readings,
not decisions; RULES.md is unchanged.

1. Turn glossary: built as rule 1 says, ending when both pools are spent. Proposed glossary
   wording: "One unit acting. An Operator's turn lasts until the player ends it, or until both the
   Operator's and the AI's AP are spent."
2. Rule 2's two halves apply to Operators only; robots, guards and turrets just act.
3. Full alerts follow the full Alerted definition: seeing an Operator or robot in the seen tier,
   finding a body, being freed, or waking untied. A camera never alerts.
4. Untying: a guard who finds a tied-up body is alerted, walks to it, and spends the first turn it
   starts next to the body untying it.
5. Sound: the device sheet wins. Only devices with a sound radius make noise, and powering a phone
   on is silent.
6. A robot can relay into the facility network; the brief's note about needing an Operator at b or
   c is read as describing the level.
7. Blackout: each light and camera the hub switches off is its own lure, plus the hub's own sound.
   There is no separate room-to-room search. Night-vision camera g goes dark with the hub.
8. One hit downs any robot, enemy or not. No enemy robots are on the map, so this is untested.
9. Zones cover every open tile and every device; walls belong to none.
10. Dock door o starts closed, unlocked and powered, since hub w powers its circuit.
11. When both pools reach zero the turn ends, and an unused shot goes with it.

Where the rules were silent, Claude chose the following. All are easy to change:

12. Low obstacles (the crates, dumpsters and vehicles) block walking and a person's sight.
    Cameras and drones see over them, and drones fly over them. The crates used to be walls.
13. Cones and light pools are round. Sight, shot, tether and flashbang ranges count walking
    distance, as before.
14. The target tile's light decides how well it's seen. Enemy turrets use a camera's cone (6 and
    9) with a guard's darkness rule: seen within 2 tiles in the dark, noticed beyond. Ordinary
    cameras see nothing in the dark.
15. A camera reports a unit once, when it comes into view, and a guard notices a unit once per
    sighting, so a lingering Operator doesn't pull every guard over.
16. Only patrolling guards answer lures and camera reports; investigating, alerted, searching and
    blinded guards ignore them. "Closest" counts walking steps. Lights and ad screens draw the
    closest guard who can see them; a camera going dark draws the closest guard anywhere.
17. A guard looks around at an investigation spot on its next turn, in all four directions.
    Noticing anything while looking starts the check over. A search is two such turns at the
    last-known position.
18. Guards don't open doors. No patrol on this map needs one, and door d starts locked.
19. An alerted guard that can aim from where it stands doesn't move. A guard that spots someone
    mid-walk stops there and aims.
20. Aim range comes from the target's tile: 5 if lit, 2 if dark. At the start of the guard's next
    turn the line counts only as far as the guard can now see, and up to anything newly in the
    way, so cutting the lights or closing a door breaks it. Aim lines show even from a guard in the
    fog, so a shot is always telegraphed.
21. Sprinting isn't allowed while in overwatch. Sprinting after shooting is allowed.
22. Operators can lock a door by hand for 1 AP, but only an AI unlocks a locked door. Automatic
    doors open only through an AI.
23. Overwatch fires at the first enemy that steps onto a tile the Operator can see, within 5.
24. A flashbang needs line of sight to where it lands. Its radius counts walking distance with line
    of sight from the blast. Blinded enemies hold still, see nothing and lose their aim. It makes
    no sound.
25. Bodies block movement. A body in a trunk goes with the vehicle. A carried guard who wakes is
    dropped beside the carrier, alerted.
26. The guard who lets a woken guard out of a receptacle is alerted too, as finding a stunned enemy.
27. A vehicle stops in front of whatever is in the way. It stuns a guard it runs into and never
    hurts the team; its sound comes from where it stops.
28. Powering a hub on switches its whole circuit on.
29. Predict: the player picks the guards, and the ghost lines update as the team acts, until that
    guard's turn ends. Locate counts the located enemy's own turns.
30. Passive chips (the exploits, movement) load with a Load action: context, no AP. Movement also
    loads on the first network move. "Next hack" chips lapse at the end of the turn, and a chip
    that compaction unloads cancels its waiting effect.
31. Subagent's linked node is picked when hacking; its extra progress costs no extra context.
32. Compacting, loading a passive chip and sharing compute work in the backpack; moving, hacking,
    active chips, verbs and turret controls need the AI connected.
33. Jump: a hop out of a Breached node the AI passes through is free. The first hop, out of the
    node it's on, always counts.
34. Tied Operators: the player can switch to another until the active one has done anything.
35. A Breached turret reaches as far as its seen tier, in any direction, and starts on hold. Every
    turret shot makes the turret's sound.
36. Robots see like Operators, with the 2-tile window in the dark; the drone sees over low obstacles.
37. A stunned enemy wakes after skipping 3 of its own turns. Caution goes on the alerting guard's
    zone.

Also built from Astra's plan: the loadout screen, restarting a phase from the session it began
with, the handover data (`BattleState.carry_over`), and a crash response that nothing in V1
triggers yet. Placeholder art: robots, the car, truck, generator, phone, hub, ad screen and
dumpsters are boxes until their models exist.

## 2026-10-04 — Answers after the cleanup pass (Bryson)

- Turrets follow the rule: an enemy turret the team can't see is hidden, like any enemy, and
  shows in the turn order once revealed. (The build had kept turrets always visible.)
- Rule 21's zones, where every enemy investigates a camera report, are V2.
- Switching a device off, or locking it, makes no sound. Turning off a car, for example, stops the
  noise it makes. A light going out is a visual lure, not a sound: "it is explicitly not the sound
  that attracts, it's the fact that a light that was on is off." It draws one guard, who walks
  back afterwards like any lure. Bryson isn't sure whether that lure should also follow the sound
  rules' reach. This replaces reading 7's hub sound on switching off.
- A speed tie between the team and the enemy goes to the team, for V1. V2 reworks the speed
  system for the turn order queue.
- The level's main data cache is the Prime Data Cache. Optional ones are Secondary Data Caches,
  such as a 3D print for a new gadget or a new skill, and Tertiary Data Caches, such as a small
  amount of cryptocurrency.
- The unused prop models (reception desk, delivery van, vault door) are deleted for now; folders
  can be made again when needed.
- Splitting `battle.gd` into menus, event-log text and the controller: agreed.

## 2026-10-05 — Full sweep of the rules (Claude, at Bryson's request)

Bryson asked for a full sweep and systems test of every rule and function. Claude checked each
numbered rule, the device sheet and the V1 setup against the code: a scenario per rule (67 checks,
run against the code before and after), thousands of random turns checking that every action the
menus offer is honored, and the content files against the V1 tables, which all match.

Fixed:
- Rule 36: a guard knocked out a second time could never be found again; the enemy remembered its
  first discovery for the rest of the battle.
- Rule 17: a Breached turret coming back from an enemy turret's stun woke "alerted" and put its
  zone on caution.

Two more readings for Bryson's review, numbered on from the list above:

38. Sprint isn't offered below 2 AP. With 1 AP it would only be a one-tile walk that gives up the
    shot.
39. A drone can end its move over a crate or a vehicle, since it flies over them.

Bryson accepted both the same day; they're in RULES.md, rule 4 and the robots table.

Not exercised: the handover between phases (rule 48), since there's no second map yet, and
crashing (rule 42), which nothing in V1 triggers.

## V2: after implementation and playtesting

- Rework the speed system for the turn order queue (Bryson, 2026-10-04).
- Zones where every enemy investigates a camera report, such as deep inside an enemy
  headquarters (RULES.md rule 21).

- Repeated lures: a guard lured to the same spot twice grows suspicious.
- How downed Operators left behind escape.
- Electric fences: as written a fence is a wall, so nothing can move into it to be stunned.
- Progression as a whole: hardware (Claude's proposal: more AP, a bigger context window, a longer
  tether; no raw hack power), post-training, how chips and hardware are acquired, prices, and
  the questionnaire's effect on the protagonist's AI.
- The harness, and AI specialization as a rock-paper-scissors triangle like Fire Emblem's: each
  AI has a natural bonus against one device category and a natural resistance against another,
  which reduces how much it hacks each turn. The harness can double the natural bonus, cancel the
  resistance, or add a second bonus for the third category. (Bryson, 2026-10-04.)
- Network opposition (ICE, daemons, security hubs), once playtesting shows the network's density
  and whether its topology should change. Options from 2026-10-04 are in the dated entry above.
- Manual control for devices with continuous noise, such as a boom box. Once Breached, its verbs
  are available every turn: switch it on for one turn, free, or leave it running.

- AP generation with a maximum: for example, generate 8 a turn up to a cap of 12. Spend a little
  on positioning one turn, then have 12 for an elaborate play the next.

- Caution as escalation through a chain of command (from option b, Shadow Tactics). Intelligent
  guards wouldn't see several suspicious things, or even an intruder, and then forget about it
  without telling a manager or leader. The leader pieces the separate reports together, decides
  there's a real intruder, and puts the area on high alert. Bryson finds this the most
  intriguing option, but V1 stays simple.

## Parked for playtesting, outside V1

- Injuries or permadeath. There may be good narrative reasons for some form of permadeath, or
  for injuries that do more than cost health, such as a movement or aiming penalty. Bryson
  prefers Chained Echoes-style full recovery for now. Revisit only after a lot of playtesting.
