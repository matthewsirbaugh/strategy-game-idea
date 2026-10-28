# Astra's review: game and lore

- Feeds: the rulebook's V2 questions and the next core-idea-and-story exploration.
- Status: filed; Request 11 closed 2026-10-28. Lore questions are in the story exploration's question
  guide (2026-10-11); game questions still current are in [rulebook.md](rulebook.md#v2-after-implementation-and-playtesting)'s
  V2 list (2026-10-28). No design changes approved.
- Requested by Bryson, 2026-10-11: compile every substantive concern from the independent review, ask Claude to add the game concerns to V2, and preserve the lore questions for the next lore session.

## Note to Claude — Request 11

Bryson asked for this handoff after Astra reviewed the current rules, game and lore. Please
file the gameplay items below in [rulebook.md](rulebook.md#v2-after-implementation-and-playtesting)
as open questions and ideas for V2. File the lore items in the open-question guide in
[core-idea-and-story.md](core-idea-and-story.md#open-questions), so they come up when Bryson resumes
that exploration. A pointer to this list is already at the top of the story exploration.

Merge with existing questions rather than creating duplicates. Preserve the identifiers below
or link back to them, and retain the distinction between an observed mechanism and an untested
concern. Some items extend questions already on the board; they are included to make the
review complete. G15–G17 also touch the pending V1 readings: cross-reference those readings
instead of presenting a V1 interpretation as a new, settled V2 decision.

Done means every item is filed, linked to an existing question, or explicitly held for Bryson's
discussion, and Request 11 points to the filing commit. This request authorizes documentation,
not changes to code, rules, balance, architecture, names or canon. The current model work need
not be interrupted. Bryson decides which recommendations to pursue.

## Evidence and limits

**Observed** means the behavior follows directly from the current rules or source. **Risk**
means a plausible consequence that needs playtesting. **Development** means an unresolved
story or design question, not a defect in unfinished work. Numbers are placeholders. Missing
V2 systems, unwritten scenes and placeholder art are not failures merely because they are absent.

This is a source and document review, including the latest October 10 lore corrections. Astra
did not run tests or play a new build. The source was rechecked at `dd70c54` on October 11.
The changed model files and Claude's environment-asset notes were left alone.

Reading routes: [RULES.md](../RULES.md), [DESIGN.md](../DESIGN.md),
[BattleState](../game/rules/battle_state.gd), [Devices](../game/rules/devices.gd),
[EnemyAI](../game/rules/enemy_ai.gd), [Perception](../game/rules/perception.gd),
[the actual yard map](../game/content/maps/facility_yard.tres),
[level design](level-design.md), [V1 readings and V2 backlog](rulebook.md), and
[current lore](core-idea-and-story.md#data-economy). Function names below are source pointers.

Astra recommends testing G01, G02, G06 and G07 together first: they could collectively make
patient, permanent dismantling the dominant strategy. For lore, L01, L02 and L04 establish
what the resistance can change and why. These are recommended priorities, not decisions.

## Game questions for V2

1. **G01 — Context costs flatten at the cap.** Observed; balance risk. `add_context` clamps at
   100, while `Devices.can_use` and `_load` do not require spare capacity. At full context,
   devices remain usable and new chips can load without increasing the penalty; crossing the
   cap also absorbs part of a listed cost. What should paying context mean near and at the
   limit? Test the present behavior before accepting context as the brake on free actions.

2. **G02 — Compaction may turn a battle resource into safe waiting.** Observed mechanism; risk.
   Compaction is repeatable, works in the backpack, and degraded chips can eventually unload
   and be reloaded at full strength. Without a mission clock or a threat to the staging area,
   preparation can cost only extra turns. Does remaining safe let the player repeatedly undo
   the intended long-term tradeoff? Preserve the no-clock decision while testing local pressure.

3. **G03 — Two AI action points may produce short routines instead of aggressive chains.**
   Risk. Movement still costs an action point even when Jump extends its distance; active
   setup chips also consume one. A refunded hack alone does not fund repeated movement.
   Measure whether the starting loadouts regularly enable expressive sequences, or mostly
   move/hack/end. More actions or cheaper setup are options to discuss, not approved remedies.

4. **G04 — Refund thresholds could dominate build choice.** Observed mechanism; risk.
   Multipliers multiply and hack power rounds down, so crossing a breach goal grants both
   speed and an action refund. At full context, a loaded 2× Infrastructure exploit still
   produces 10 power, enough to refund an untouched goal-10 device. Are some loadouts
   disproportionately useful because they cross the common thresholds? Evaluate chip
   strengths, context and device goals together, including the cost of Extended thinking.

5. **G05 — Shared compute could make the strongest AI absorb the team's role.** Risk.
   Adjacent Operators can concentrate action points in one recipient's next turn. Check
   whether optimal play repeatedly feeds the same specialist while the other AIs donate,
   reducing three partners to one effective hacker. The adjacency requirement also needs
   to produce worthwhile positioning choices rather than repetitive regrouping.

6. **G06 — Permanent control can make the latter half of a mission collapse.** Risk.
   Captured nodes remain captured, improve travel, and give every connected AI access to
   their devices. Captured turrets can repeatedly suppress enemies and gain firing coverage
   different from their enemy behavior. Each AI also gets fresh device-verb uses on its own
   turn. Test whether increasing control creates satisfying new choices or erases opposition
   and turns extraction into cleanup. This connects to the existing network-opposition ideas.

7. **G07 — Direct shooting may outperform the environment and gadgets.** Risk.
   All three Operators act before standard guards, each gets a shot outside the action-point
   pool, and one hit removes a guard's vision and next three turns. Guards additionally
   warn before firing. Compare this route with the preparation needed for vehicles, lures,
   flashbangs and hacks. Elaborate plays should have practical advantages, not depend on the
   player voluntarily avoiding an easier clear-the-map strategy.

8. **G08 — Guards unable to open doors may be too easy to contain.** Observed; risk.
   The pending V1 reading 18 says guards do not open doors, and `_walk` respects closed-door
   blockage. Operators can close unlocked doors for free. Check whether ordinary doors
   indefinitely stop pursuit or isolate guards who ought to have access. Any future response
   should remain predictable; this is not a request to add enemy behavior immediately.

9. **G09 — Suspicion does not yet accumulate across repeated manipulation.** Observed V1
   simplification; risk. Investigations finish, caution counts down, and guards can return to
   the same vulnerable patrol patterns. A credible security organization should eventually
   connect repeated anomalies. Merge this with the existing repeated-lure and chain-of-command
   V2 questions, and test how much memory creates pressure without punishing ordinary exploration.

10. **G10 — Information chips need a distinct payoff.** Risk. Broad shared vision, captured
    cameras, visible cones, interrupted movement on discovery, and warning aim lines already
    give substantial safety information. Locate and Predict should answer questions those
    systems leave unresolved, particularly in darkness or overlapping patrols. Test whether
    they earn a chip slot and an AI action compared with more direct control or breach power.

11. **G11 — Robot relays may bypass too much physical exposure.** Risk. Relays have no range
    limit back to the Operators and can serve any teammate; a drone can reach access points
    behind low obstacles. This is a strong feature, but its one-hit vulnerability must matter
    in actual layouts. Can a safely parked team obtain most important access through a robot,
    making the human tether largely irrelevant? Evaluate access-point placement and counterplay.

12. **G12 — The stable roster needs recognizable tactical identities.** Development; playtest
    question. Identical Operator stats and fully reshapeable AIs are deliberate choices. Check
    whether gear and loadouts give the three members meaningful, complementary jobs, or make
    them interchangeable carriers. Punch up their roles through existing equipment and
    authored situations if necessary; unique character-locked abilities are not a requirement.

13. **G13 — The mandatory movement chip may be removable bookkeeping.** Recommendation to
    test. It is free, occupies no optional slot, and loads automatically when movement begins.
    Its context cost and unloading exception are real rules, but may offer little actual
    choice. Keep it if those interactions make worthwhile decisions; otherwise consider
    simplifying its presentation or folding it into baseline network movement.

14. **G14 — The information burden may exceed the decisions it supports.** Risk; no native
    usability verdict. Players track two action pools, a separate shot, context, chip states,
    verb uses, tethers, cones, light, caution and body timers. The interface's Operator/AI
    halves must also communicate that actions interleave. Test comprehension and planning
    effort; simplify redundant tracking or presentation before adding more systems. Preserve
    the trusted previews and the interface structure Bryson has said works.

15. **G15 — Automatic turn ending can turn free actions into an ordering trap.** Observed;
    pending reading 11. `_after_action` ends the turn when both action pools reach zero even
    if the shot or a free device operation remains. Players may need to save an action point
    merely to retain those opportunities. Is that intended, and is the loss clear before the
    last paid action? Resolve or cross-reference the V1 reading before proposing a V2 change.

16. **G16 — Shooting before sprinting bypasses the stated sprint tradeoff.** Observed;
    pending reading 21. Rule 4 describes sprinting as giving up the turn's shot. The code
    rejects shooting after a sprint but permits sprinting after a shot; it separately blocks
    sprinting in overwatch. Is the tradeoff turn-wide or deliberately dependent on order?
    Reconcile the wording and intended behavior. Do not quietly treat the current reading as
    Bryson's approved decision or change the code under this documentation request.

17. **G17 — Blackout behavior and lure reach remain unresolved.** Existing open question.
    Rule 26 describes a room-to-room search; the build produces individual device lures.
    Lights, cameras and sounds also attract guards through different conditions. The October
    10 rulebook session already owns these questions. Cross-link them and ensure previews,
    the rule text and eventual enemy behavior describe the same outcome.

18. **G18 — Different spatial rules need a readable explanation.** Observed complexity;
    usability risk. Cones and light pools, movement and shot distance, sound paths, tethers,
    target lighting, and sight over low obstacles follow different rules. The pending readings
    record several of these choices. Test whether players can predict why a guard sees a tile,
    a shot is unavailable, or a sound fails to reach someone without memorizing implementation
    details. Accurate visual explanations may be enough; changing the geometry is not assumed.

19. **G19 — Authored device combos need room for discoveries and mission variety.** Risk;
    development. The yard deliberately assigns devices to particular guards and combinations.
    That is good scaffolding, but each device should remain useful outside its intended trick.
    Test alternate routes and unplanned combinations. For V2, also ask how missions vary the
    retrieve-a-cache objective while exercising the same coherent tools, rather than merely
    repeating familiar setups on larger maps.

20. **G20 — Turn count and planning effort could overwhelm mission pacing.** Risk. Three
    Operators, deployed robots, seven guards and a turret can make a round contain many turns,
    even before network actions and menus are considered. The level-design exploration already
    asks whether this density works. Measure meaningful decisions and waiting time in native
    play; more enemies, nodes or map area should not substitute for richer situations.

21. **G21 — Phase-entry snapshots could preserve an effectively unwinnable condition.** Risk;
    untested future integration. Downed Operators, spent armor, context and chips carry into
    the next phase; a loss restores that entry state. A later map designed around a fuller
    team could leave the player repeatedly restarting an impossible entry. When a second
    phase exists, test difficult carry-over states and discuss a recovery route if needed.
    This does not establish that the current single-map test can softlock.

22. **G22 — Leaving casualties behind can weaken both extraction and narrative stakes.**
    Existing V2 question; risk. Victory needs only standing Operators to extract, and escape
    for those left behind is currently handwaved. Future missions should avoid making a
    teammate's downing a convenient way to simplify extraction. Clarify rescue and aftermath
    in the fiction without assuming permadeath, persistent injuries or mandatory punishment.
    Coordinate this with L14 and the existing escape question.

## Lore questions

23. **L01 — What restores democratic power after OpenBrain is stopped?** Development; central
    causal gap. Regulation, investment, ownership and infrastructure sustain the monopoly.
    Preventing a robotics breakthrough does not by itself specify how those institutions
    change. Define what victory makes possible, who can act on it, and what remains difficult.
    The ending needs a credible path from the protagonists' actions to the promised hope.

24. **L02 — What does taking a cache accomplish beyond obtaining a reward?** Development.
    Distinguish gathering money, exposing evidence, sharing capability, sabotaging a project
    and liberating personal data. Copying information need not deprive its owner of it;
    existing backups or already-developed capability may survive a raid. What specifically
    changes after an important mission, and why does that change hurt the robotics effort or
    help the people the team claims to serve?

25. **L03 — Why are general humanoids the decisive threshold?** Development. Humans remain
    necessary for physical work; losing that necessity could remove their remaining bargaining
    power. That is Astra's interpretation, not adopted lore. Establish the concrete consequence
    of the breakthrough and why this resistance has a viable opportunity before it happens.
    Show progression toward it through the story; a literal mission clock is not required.

26. **L04 — Why do competitive open models fail to break the monopoly?** Development.
    Anthropomorphic released frontier-competitive models and improvement research, yet
    OpenBrain dominates America. Identify the remaining bottleneck: access to compute, legal
    permission, deployment, data, distribution, property or something else Bryson chooses.
    This explains both the public's dependence and what the resistance can realistically
    redistribute. Do not solve it by silently weakening the approved open-model premise.

27. **L05 — Why cannot OpenBrain reproduce the protagonists' specialist advantages?** Existing
    question 26; development. The older notes give local models speed, specialization and
    freedom relative to corporate models. A resource-rich monopoly needs a reason it cannot
    simply field the same sort of hacker. Develop a constraint or asymmetry with limits the
    audience can understand. Avoid equating unrestricted models automatically with goodness
    or corporate safety automatically with incompetence.

28. **L06 — What political machinery makes the company dominant?** Development. Ownership
    without a vote is compelling, but the government's role, regulation's beneficiaries and
    enforcement, and the position of foreign AI powers remain broad. Specify enough to explain
    how everyday coercion works and why ordinary democratic routes have failed. These details
    should support characters and missions, not require an encyclopedic political history.

29. **L07 — The economic collapse needs clear intermediate steps.** Development. The October
    10 account moves from roughly 20% direct displacement to a depleted middle class, compressed
    trades and retail, and income insufficient for housing. Show how wages, demand, ownership
    and housing pressures interact in this particular city. Also clarify how the nominal
    ownership payment and recording bonus keep people dependent. These are fictional economic
    choices to explain, not predictions Astra has verified about the real future.

30. **L08 — What makes these recordings valuable to the robotics project?** Development.
    Fixed surveillance, wearable cameras and a child's private life are different kinds of
    information. Establish what each contributes and what the labs still cannot obtain.
    Otherwise the data economy may feel like a striking metaphor with a weak causal connection
    to the robots. The answer only needs enough specificity to make exploitation and targeted
    resistance plausible; it need not become a technical lecture.

31. **L09 — The mother and other data sellers need agency beyond illustrating misery.**
    Recommendation to punch up. Their constrained choices are the strongest social material.
    Develop what they want, how they justify their choices, who condemns them, and how that
    condemnation benefits the system. Keep room for conflicting responses among neighbors and
    the resistance. Avoid reducing the mother or her son to evidence for the story's argument.

32. **L10 — What makes the protagonist and the three-person team act personally?** Development;
    deliberately parked. The cause is clear, but the protagonist's stake, the team's bonds and
    disagreements, and their reasons for accepting risk remain unwritten. Establish these when
    story work resumes. Different personalities should produce consequential perspectives,
    especially if their equipment and capabilities can become interchangeable. This is not a
    demand to finish characters before continuing the prototype.

33. **L11 — Intimate AI knowledge should create specific trust conflicts.** Recommendation
    to punch up; existing relationship questions. The same knowledge enables protection and
    manipulation. Give that tension concrete situations involving information, consent and
    conflicting judgment. The four relationship structures need distinct people and choices,
    not only philosophical labels. Betrayal, autonomous move selection and penalties for
    trusting a partner are not required mechanics.

34. **L12 — Separate changes in expertise from changes in personhood or allegiance.**
    Development. The questionnaire, chips and post-training shape abilities, while relationships
    depend on personality, desires and values. What persists when an AI is rebuilt into a
    different specialty, and what can its Operator legitimately change? A serious partnership
    needs a coherent account of that power. Direct tactical control can coexist with agency
    expressed through dialogue; the fiction does not require real language models at runtime.

35. **L13 — The insider's culpability needs a concrete act and consequences.** Existing
    question 30; recommendation to punch up. His self-exculpation is a strong character seed,
    but a general claim that he raced ahead with good intentions cannot carry the reckoning.
    Identify a specific decision, who suffered, what he still refuses to admit, and what help
    cannot absolve him. Preserve the existing choice that he provides opportunities rather
    than becoming the resistance's commander or effortless financier.

36. **L14 — Ordinary guards and non-lethal violence need a consistent moral reality.**
    Development; connects to G22. Guards may be workers in the same economy the heroes oppose.
    Decide how the story treats frightening, restraining, injuring and abandoning them or
    teammates. Vehicles currently stun guards and never hurt the team: does that abstraction
    fit the realistic tone, need explanation, or eventually need revision? Full recovery and
    no permadeath remain valid choices; consequences can exist in people and relationships.

37. **L15 — The resistance needs an answer about its own use of intimate data.** Development.
    The heroes hack surveillance and their partners know their private histories. What limits
    do they place on accessing, storing, selling or publishing other people's information?
    How do they respond when useful evidence includes data supplied under coercion? Their use
    of the same infrastructure can deepen the story, provided accountability appears through
    decisions instead of their allegiance automatically excusing it.

38. **L16 — Company analogies can assign moral conclusions before the story earns them.**
    Risk; recommendation to revisit if needed. OpenBrain and Anthropomorphic closely map to
    present-day companies, and the open-model origin already marks one as beneficent. Check
    whether readers can understand each faction's behavior through the fiction independently
    of their opinions about those brands. More specific motives, complicity and limits may
    solve this; renaming or reducing the analogy is an option, not an approved removal.

39. **L17 — The town needs to carry relationships and discovery, not only oppression and shops.**
    Development; deliberately parked. The setting's distress is legible, but Bryson also wants
    wonder, exploration and a reason to care about people. Develop ordinary attachments,
    creativity, contested hopes and changes players can encounter between missions. Start
    with the agreed neighborhood scale. These scenes should provide stakes for returning
    there, rather than expanding into a large town system merely to fulfill a genre convention.

40. **L18 — Clarify which technical constraints belong to the fiction and which are game abstractions.**
    Development. Local AIs have no internet but enter facility networks; humans have short
    tethers while robot links back have no range limit; context and chip degradation use
    deterministic rules. Explain the distinctions enough to support the grounded tone and
    avoid presenting every mechanic as a literal lesson about real AI. The master security AI
    also needs a credible limited view consistent with fair gameplay; the October 10 decision
    that it is not actually all-seeing in play stands.

## Filing reminders

The already-deferred items above do not justify reopening every parked thread now. Keep the
V1 reading review, V2 design, lore and eventual playtesting distinct. Do not restore retired
chibi designs, the American duopoly, the old subsistence-income guarantee or the retired art
direction. Do not infer that proposed remedies are accepted because Bryson asked to save the
questions. After filing, keep one substantive home for each issue and use links for the rest.
