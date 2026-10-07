# Level design: a map that exercises everything

## The question

How do we lay out a map so the systems we have get tested together, in the combos players will
want to try? Bryson, 2026-10-07: research level design, set up a level from it, and update the
map. It should be at least twice as large as the last one, with guards, devices, patrol routes,
the start and the lines of sight all placed with combos in mind.

## Constraints this inherits

- Every rule in [RULES.md](../RULES.md) as built in V1: three Operators with fixed loadouts, AI AP
  2, tether 2 steps (Manhattan), sound in walking steps, cones in two tiers, night, jump, refunds.
- The map format in `game/rules/map_data.gd`: tiles, nodes, links, networks, circuits, zones,
  receptacles, patrols, dressing. Guards and turrets are the only enemies a map can place.
- Facility mission, exterior phase (rule 47). The vault interior stays out of V1.

## Findings

### 2026-10-07 — Research (Claude)

What the reference games and writing agree on, and what each principle became on this map:

| Principle | Where it comes from | On this map |
|---|---|---|
| Layered security, an "onion": public outside, guarded middle, a core with several ways in | Hitman's level topologies | Street → yards → annex, each layer on its own network |
| Several viable routes into each layer | Hitman, Mimimi (Shadow Tactics, Desperados III), Deus Ex | Yard: gate, side door, drone over the barricade. Annex: front autodoor, locked back door |
| Guards guard guards: overlapping coverage, so taking one out has a cost | Shadow Tactics; Celia Wagar's "Taking Apart Stealth" | Guard 7 can see the gateway where Guard 1 gets rammed; Guard 3 is often closer to the ad screen than Guard 4 |
| Readable patterns: the player must be able to observe and plan | Stealth level design writing; Invisible Inc's UI rule that a loss should be your fault | Short, regular patrol loops; Predict and the cones show the rest |
| Light and dark as terrain, and lights as targets | Thief | Lit yards and gate; dark alley, rear lane, annex; a hub that blacks out the yards |
| Safe space to stage, and recoverable mistakes | Stealth design writing; Invisible Inc | The street west of the lamp is dark and unwatched; zones keep caution local |
| Small and dense: nothing filler, every tile can matter | Into the Breach | Every device has a combo it exists for |

Sources: [Topology of Hitman levels](https://azhdarchid.bearblog.dev/topology-of-hitman-levels/),
[Taking Apart Stealth](https://critpoints.net/2015/05/18/taking-apart-stealth/),
[How to design a stealth level](https://bugnet.io/blog/how-to-design-a-stealth-level),
[Designing Procedural Stealth for Invisible Inc. (GDC)](https://gdcvault.com/play/1021919/Designing-Procedural-Stealth-for-Invisible),
[Mimimi on multiple paths in Desperados III](https://www.pressreader.com/usa/pc-gamer-us/20180911/281547996740318),
[Thief case study](https://wemakestuffforfun.myblog.arts.ac.uk/?p=29),
[Into the Breach review](https://www.giantbomb.com/into-the-breach/3030-58234/user-reviews/2200-31048/).

### 2026-10-07 — The facility yard map (Bryson asked; Claude built it; rules-checked, not played)

`game/content/maps/facility_yard.tres`, 34 × 22 with 562 open tiles. The old map is 20 × 16
(320 tiles). It is now the map the game plays; `facility_exterior.tres` stays, since the rules
tests are written against it.

```
# # # # # # # # # # # # # # # # # # # # # # n # # z # # # # # # # #
# X X . . . . . . . . . = . . . . # . . . . . . . . . . . . . . . #
# X X . . . . . . . . . . . . 6 . u . . 5 . . . . . . . . . . . . #
# # # # # # # q # # # # # w # # # # . . = = = = . . . = = = = . . #
# B B B # . . . . . . . . . . . . g . . . . . . . . . . . . . . . #
# B B B # = . . . . . . . . . . . # # . # # # # # # # # # # # . # #
# B B B # . . . . i . . f . . . . # . . . . . . . . . . . . . . . #
# B B B # . . . . . . . . . . . . # . . . . . . . . . . . . . . . #
# B B B b . . . . . . . . . . . . # # # # # # s # # o # # # h # # #
# B B B # . . . . . . . . . = . . 7 . . . . . . . . . . . . . . . #
# . . . # . . 2 . . . . . . = . . . . . . = . . . . 4 . . . . v . #
# . . . # . . . B B B B . . . . . . . 3 . . . . . . . . . . . . . #
# . . . d . . . B B B B . . . . . . . . . . . . . . . . x . . . . #
# = . . # m = . B B B B . . . . . . . . . . k . . . . . . . . . . #
# . . . # = . . B B B B . . . . . . . . . . . . . . . . . . . . t #
# . . = # . . . . . . . . . . . . . . . . . . . = = . . . . = = = #
# . . . # . . . . . . . . j . . . 1 # # # = . . . . . . . . = . . c
# . . . # . . . . . . . . . . . . . # # # . . . . . . . . . = . . #
# . . . # # a # # # # # # # e # . . p # # # # # # # # # # # # = = #
, , , , , , , , , = , , , , , , , , , , , , , , , , , , , , , , , ,
, P P , , , , , , , , , , , l , , , , , , , , , y , , , , , , , , ,
, P , , , , , , , , , , , , , , , r , , , , , , , , , , , , , , , ,
```

North is up; x runs 0–33 left to right, y 0–21 top to bottom. P start, X extraction, numbers are
guards, `=` crates, dumpsters and the barricade.

| Network | Nodes |
|---|---|
| Street (public) | a access, d side door (locked), l and y street lamps, e gate camera, p payphone, r parked car |
| Facility (the yards) | b and c access, w power hub, q back gate, u annex back door (locked), o annex autodoor, f, h cameras, g night-vision camera, i, j, k, x floodlights, m generator, s ad screen, v truck, t turret |
| Vault (the annex) | n access, z Prime Data Cache |

The hub's circuit is the four floodlights, cameras f and h, and the gate camera e on the Street
network. The night-vision camera and the ad screen stay powered through a blackout.

#### The layers and routes

- **Street.** Start in the dark at the west end; access point a is two steps from the start and out
  of every cone. The lamp l and gate camera e cover the approach to the gate.
- **Into the yards.** The main gate (lit, Guards 1 and 7, the car lane); the side door from the
  dark alley (locked, unlockable from the Street network); or the drone hops the barricade into a
  crate-walled pocket where only it can reach access point c.
- **Annex.** The front autodoor, watched by Guard 4, or the locked back door from the rear lane,
  which enters in the night-vision camera's blind corner. Inside, vault access point n sits in that
  camera's seen tier, and Guard 5 walks the server hall in the dark.
- **Out.** The rear lane, dark, walked by Guard 6, through the back gate q or the annex back door.

#### Combos, and what each piece is for

| Combo | Pieces | Who it suits | Checked |
|---|---|---|---|
| Ring the payphone; the gate guard steps into the gateway; drive the parked car into him | p, r, Guard 1 (only within 4 steps at his post end); Guard 7 can see the gateway | Breacher (one-action breaches) | Yes: Guard 1 stands at the gateway, the car stuns him |
| The car lane: the gate and the yards' seam are one straight column, so the car can hit anyone on it | r, Guards 1 and 7 | Anyone with the car | Path checked |
| Scout takes the gate camera turn 1, then the Breacher chains refunds through it: a → d / l → e → p → r | Street network | Scout, Breacher | Not run |
| Generator ambush: the generator sits in a crate nook whose only open tile is just inside the side door. Wait in the dark alley, open the door, stun, tie, dump in the alley dumpster | m, d, Guard 2, alley dumpster | Anyone; overwatch | Yes: Guard 2 walks to that tile |
| Drone relay over the barricade into the pocket, then any AI goes in through c | c, barricade, Scout's drone | Scout, then everyone | Tether reach checked |
| Turret takeover from c: t is one hop away, and weapons + extended thinking breaches it in one action | t, c | Breacher | Not run |
| Blackout: the hub cuts four floodlights and three cameras; each one draws a guard | w (goal 30) | Breacher | Yes: six guards drawn, lit tiles 189 → 56 |
| Flash the ad screen to pull Guard 4 off the annex door, then open the autodoor, whose sound would otherwise draw him | s, o, Guards 3 and 4 | Anyone | Yes: works on the rounds Guard 4 is at the west end of his beat and Guard 3 is farther away |
| The truck: power it and it drives the loading lane, stunning Guard 4, but its noise draws the east yard | v, Guards 3 and 4 | Anyone, as a loud play | Yes |
| Prep the annex from outside: breach the night-vision camera from the Facility network before anyone goes in | g (goal 30, two hacks or two AIs) | Scout plus one; shared compute | Not run |
| Cut the night-vision camera instead: its lure pulls Guard 5 to the hall's west end | g, Guard 5 | Anyone | Not run |
| Locate Guard 6 in the dark rear lane before the exfil; Predict for every timing combo above | Guard 6 | Scout | Not run |

#### Guards

| Guard | Route | Why it's there |
|---|---|---|
| 1 | Gate post, (17,16) ↔ (14,16) | The payphone and car combo; only within the phone's reach at his post end |
| 2 | Loop round the storage shed, west yard | The generator ambush; walks under camera f and floodlight i |
| 3 | Big loop across the east yard | Overlapping coverage with Guard 4; competes for the ad screen lure |
| 4 | Annex door post, (26,10) ↔ (24,10), on the truck's lane | The ad screen and autodoor combo; the truck ram |
| 5 | Loop round the server racks in the annex | The vault's inner threat, in the dark |
| 6 | Rear lane loop | Exfil pressure; Locate's job |
| 7 | The seam column, (17,9) ↔ (17,14) | Watches the gateway: the counter to the car ram |

Zones: Street, Alley, West yard, Gate, East yard, Annex, Rear lane, so caution stays local.

Verified: the map validates; the rules test suites pass; three random 250-turn battles on this map
broke no rule; the combos marked "Yes" were run through the rules engine step by step. Screenshots
of a native run show it renders. Not played.

Claude's choices, open to change:
- The new map replaces the old one in play rather than being picked from a menu.
- Night, like the old map.
- The annex is a walled compound with razor wire, not a roofed building, because the map has one
  indoors setting for the whole map.
- The east yard is the most watched place on the map on purpose: it's where the combos earn the
  annex door. The rear lane and back door are the quiet alternative.

## Open questions

1. Is the east yard too watched to cross without a combo, or is that the right pressure?
2. Seven guards and a turret: right density for 34 × 22, or too many turns to watch?
3. Should the annex get a roof, which needs indoor and outdoor areas on one map?
4. Should the old map stay as a second, smaller test map players can pick?
