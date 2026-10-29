# Story

What the story is so far: agreed world, history and characters only. Started 2026-10-13 from
[the core exploration](explorations/core-idea-and-story.md), which keeps the reasoning, the dated
discussion and the open questions. Each section links to where it was decided. Where this file and
an older finding differ, this file is current; where this file and DESIGN.md differ, DESIGN.md wins
and this file gets fixed.

Things marked *to confirm* were recorded from Bryson's words but not yet checked back with him.

## Terms

| Term | Meaning |
|---|---|
| OpenBrain | The villain. The OpenAI stand-in, first to AGI, a monopoly in America |
| Anthropomorphic | The Anthropic stand-in. Went under; its leaked weights underlie nearly every open AGI |
| AGI | Common, expensive AI. LLMs: superhuman in places, jagged, bound by context. Fits in a backpack |
| ASI | The one superintelligence, hidden in an air-gapped box at OpenBrain. Misaligned |
| The warning shot | The ASI's disaster that killed about 2,400 people (working number) |
| Operator | A human member of the resistance, carrying an AGI partner in a backpack |
| Partner | An Operator's AI: no body, only text and voice |
| Squad | A group the resistance sends on one mission. Name may change |
| Orchestrator | The resistance's unseen source of a squad's mission and orders. Name may change |
| Master AI guard | The AGI that coordinates OpenBrain's security. Lore, not a rule |
| Oracle | How OpenBrain uses the ASI: shareholders bid to ask it questions |

## The point

- A cautionary tale for players in 2026–27: act now, because afterward even the best outcome only
  stops the bleeding. ([cleanup](explorations/core-idea-and-story.md#cleanup-2026-10-11))
- Neither AI company is a hero. Both raced ahead knowing the risk. (DESIGN.md)
- A story about a government bought out by big-money interests, with AI and tech companies steering
  it. ([stakes](explorations/core-idea-and-story.md#stakes-2026-10-11))
- Only neutral or negative endings. Multiple endings, like Persona 4, reached through choices.
  ([stakes](explorations/core-idea-and-story.md#stakes-2026-10-11), [S2](explorations/core-idea-and-story.md#s2-2026-10-12))
- *Andor* is the model for how power works on people: success brings a crackdown, and the
  crackdown grows the resistance. ([S2](explorations/core-idea-and-story.md#s2-2026-10-12))

## History

Only these are dated or ordered so far:

| When | What |
|---|---|
| 2010s | The main characters are born. They get AI around middle school and grow up close to it |
| ~2036 | The news takeover: one mogul puts AI in charge of reporting, every other follows, and it's news for two weeks |
| After that | The warning shot. The AI-run news astroturfs it. America doesn't shut the labs down |
| In response | The UBI bill, in President TJ Tiel's second term (a JD Vance stand-in). Confirmed order: news takeover → warning shot → UBI bill ([S3](explorations/core-idea-and-story.md#s3-2026-10-29)) |
| ~2046 | The game starts |

Not placed on the timeline yet:
- OpenBrain reached AGI six months ahead of everyone, with little fanfare.
- When AGI reached enterprise, the last senior developers outside AI research were let go. About
  20% of the working population, essentially every knowledge worker, was displaced.
- Anthropomorphic went under. A high-ranking employee leaked its weights and got 20 years, and
  open models were banned.

Sources: [stakes](explorations/core-idea-and-story.md#stakes-2026-10-11),
[the team](explorations/core-idea-and-story.md#team-2026-10-12),
[world](explorations/core-idea-and-story.md#world-2026-10-11).

## The world in 2046

- **The city.** Somewhere in California, not Silicon Valley. Visually close to today; more of it is
  the poor part of town than ever. (DESIGN.md)
- **The economy.** Basic income comes from OpenBrain's kiosks, paid from a share of the stock: shared
  ownership with no vote. It doesn't keep a person housed. The trades and retail compressed
  with the middle class. ([data economy](explorations/core-idea-and-story.md#data-economy), [corrections](explorations/core-idea-and-story.md#corrections-2026-10-10))
- **Data is worth more than compute.** Every citizen gets a free OpenBrain subscription whose chats
  are harvested, with a small UBI bump for hitting the token limit. People wear cameras around the
  clock to train the robots for a little more income, and are treated as traitors for it.
  ([world](explorations/core-idea-and-story.md#world-2026-10-11), [data economy](explorations/core-idea-and-story.md#data-economy))
- **Surveillance from the bottom up.** Descendants of Flock cameras, put up by landlords, property
  owners and the government. The footage trains OpenBrain's robots.
  ([data economy](explorations/core-idea-and-story.md#data-economy))
- **A panopticon online.** AI is too costly to check every upload, so it watches some of the time
  and everyone acts as if it's always watching. People see the resistance's videos but don't touch
  them. ([S2](explorations/core-idea-and-story.md#s2-2026-10-12))
- **Hardware.** AGI is expensive and mostly on the black market: the AI companies have bought up the
  RAM, GPUs and CPUs. Even retail computers are worth more than gold.
  ([AGI and ASI](explorations/core-idea-and-story.md#agi-asi-2026-10-11))
- **Other powers.** China, Europe and India each have their own AGI, and maybe an ASI under wraps.
  Foreign-owned access points show up in some levels. ([corrections](explorations/core-idea-and-story.md#corrections-2026-10-10))
- **Vehicles.** New ones are electric; old diesel still runs. ([corrections](explorations/core-idea-and-story.md#corrections-2026-10-10))
- **Robots.** No humanoids yet. Drones and robot dogs run on older, smaller models. Robotics is
  stuck behind a wall of data. (DESIGN.md)

## AI

- **AGI** is usually aligned, though some are made misaligned on purpose. It's jagged: superhuman
  coding and information processing, but taste, intuition and judgement stay mostly with people.
  That's why it hasn't solved alignment. Bigger models get less aligned.
  ([cleanup](explorations/core-idea-and-story.md#cleanup-2026-10-11))
- **Degrees of alignment** give the four human–AI relationships: partnership; the human tricks an
  aligned AI; the AI manipulates the human; the human gives up autonomy to the AI. The team's
  partners are generally aligned; some others aren't.
  ([follow-ups](explorations/core-idea-and-story.md#follow-ups-2026-10-11), [relationships](explorations/core-idea-and-story.md#relationships))
- **AGIs differ by post-training, not scale.** Scale gives every AGI its base ability; post-training
  decides what each excels at. A brilliant coder can be socially inept; some are better at
  manipulation or social awareness than others. ([S3](explorations/core-idea-and-story.md#s3-2026-10-29))
- **A partner knows its Operator's real identity.** That lets it protect them, and also lets it
  manipulate them. ([identity](explorations/core-idea-and-story.md#identity))
- **The ASI** is alien, not evil. It thinks in neuralese that nobody, AI included, can read. Its
  ends were aligned and its means weren't. It caused the warning shot, then reported it itself.
  Since then it has hidden what it is, acting as OpenBrain's oracle: it pretends to need more
  time than it does and delivers about 80% of what's asked, by choice. It has no gender, but it has
  a personality. It's bound by context too. ([S1](explorations/core-idea-and-story.md#asi-2026-10-11))
- **What the public knows** about the warning shot: buried, then forced out. Everyone knows and
  nobody is held liable. ([S1](explorations/core-idea-and-story.md#asi-2026-10-11))
- **What the stakes are.** The oligarchs replace all labor and use the robots to control people.
  Worse, the ASI takes the robots. Even if the robots are stopped, the ASI escapes later unless it's
  dealt with. ([stakes](explorations/core-idea-and-story.md#stakes-2026-10-11))

## OpenBrain

- Pristine, white with black and red accents, very different from the city around it. (DESIGN.md)
- Its guards are ordinary people with AR glasses and compute pucks; the master AI guard directs
  them. ([data economy](explorations/core-idea-and-story.md#data-economy))
- The insider: a board member, once on Anthropomorphic's board too. He supplies information and
  opportunities, not money or orders. He hasn't faced his own part in what went wrong; what he did
  is deliberately deferred. ([resistance](explorations/core-idea-and-story.md#resistance), [corrections](explorations/core-idea-and-story.md#corrections-2026-10-10))

## The resistance

- Anonymous and shuffled, like *The Handmaid's Tale*: code names, covered faces, groups that change
  often. Nothing about it is shared, even with its members. (DESIGN.md, [follow-ups](explorations/core-idea-and-story.md#follow-ups-2026-10-11))
- Small and lean. Run by its own aligned AIs with humans kept in the loop, because even an aligned
  AI can be manipulated by bad actors. ([S3](explorations/core-idea-and-story.md#s3-2026-10-29))
- Nobody learns more than their task needs. A squad works one mission together and almost never
  meets again. Anyone captured or compromised is cut off at once, unless they hold something vital
  or matter for another reason. No ranks: more trust means being asked to do more, and an Operator
  is about as trusted as anyone gets. ([S3](explorations/core-idea-and-story.md#s3-2026-10-29))
- Orders come from an Orchestrator the squad never meets, by a channel that changes each mission
  and hides in plain sight, such as an ATM zero-day or a QR code that exists only from one vantage
  point across a wall of billboards. Encryption works once a link exists; nearly all everyday
  software is backdoored, so first contact has to be creative. ([S3](explorations/core-idea-and-story.md#s3-2026-10-29))
- The public knows it exists, the way people know of Antifa today, but not how far it reaches.
  Observant readers can spot its work between the lines of the AI-run news. ([S3](explorations/core-idea-and-story.md#s3-2026-10-29))
- Its gear is old or improvised: jailbroken units from the black market, rebuilt hardware, imported
  chips. Its AIs descend from Anthropomorphic's leaked weights.
  ([resistance](explorations/core-idea-and-story.md#resistance), [world](explorations/core-idea-and-story.md#world-2026-10-11))
- Mission kinds: destroy, steal to train, steal to sell, expose, poison, recover hardware,
  intelligence. A poisoning that gets spotted is rolled back, which counts as failure. Data
  centers can be huge, and that's how specialized teams get in.
  ([S2](explorations/core-idea-and-story.md#s2-2026-10-12), [world](explorations/core-idea-and-story.md#world-2026-10-11))
- It spreads the word through spectacles, illegal newspapers, codewords hidden in ordinary media,
  and by exploiting the 20%. Its mission is to find recruits before the enemy does.
  ([S2](explorations/core-idea-and-story.md#s2-2026-10-12))

## The team

Three strangers grouped by the resistance, meeting for the first time. An ordinary squad that gets
lucky; over the story it becomes an exception to the reshuffling, made only out of desperation
([S3](explorations/core-idea-and-story.md#s3-2026-10-29)). ([cleanup](explorations/core-idea-and-story.md#cleanup-2026-10-11))

| Who | What's agreed |
|---|---|
| The tradesman (protagonist) | He. Early 30s. A defined character, like Persona 5's. Works at a data center; his father owns a small electrical subcontractor. The most materially privileged of the three: his family never sold its data. Knows the data center's cooling system |
| The writer | She. Early 30s. Her degree became useless the moment she finished, when the news was taken over. Writes for the illegal newspapers |
| The developer | He. Mid-40s. Held on until AGI reached enterprise, then was let go with the last senior developers |
| The partners | No appearance; personality through dialogue. The protagonist's starts generic and is shaped by a questionnaire after the tutorial; the other two arrive with set personalities (DESIGN.md) |

Sources: [the team](explorations/core-idea-and-story.md#team-2026-10-12),
[protagonist](explorations/core-idea-and-story.md#team-2026-10-11). Their looks:
[character-models.md](explorations/character-models.md).

## The arc

- The game opens with the team's first mission together, at a medium-sized data center. The player
  learns about the three as they learn about each other. OpenBrain's research park comes later; its
  headquarters is maybe a late-game mission.
  ([the team](explorations/core-idea-and-story.md#team-2026-10-12), [data economy](explorations/core-idea-and-story.md#data-economy))
- They feel they're making progress, then slowly realize it's futile, which sends them after
  OpenBrain itself. ([S2](explorations/core-idea-and-story.md#s2-2026-10-12))
- The ASI may be a final boss. Reaching it is probably a physical raid, which it uses to try to
  break out; the team has to keep it off the internet.
  ([follow-ups](explorations/core-idea-and-story.md#follow-ups-2026-10-11))
- **The best ending.** The resistance turns out larger than anyone guessed. The team destroys
  OpenBrain's networked data centers, about 70% of America's, along with its data and the only
  copies of the ASI's weights. That doesn't fix democracy. As the credits roll, the player decides
  whether America was rebuilt or the oligarchs bought only a decade.
  ([follow-ups](explorations/core-idea-and-story.md#follow-ups-2026-10-11))

## Still open

The open lore list is the core exploration's [question guide](explorations/core-idea-and-story.md#question-guide):
S4–S12, Round 2's R2–R5, and [story V2](explorations/core-idea-and-story.md#story-v2), which covers
what the warning shot actually was.

Conflicts noted for later (2026-10-13):
- When the game is set: DESIGN.md says the late 2030s to early 2040s; the story has it starting
  around 2046, with the news takeover around 2036.
