# Game cleanup review — 2026-10-11

Status: small fixes implemented by Astra under Bryson's approved cleanup plan. No major
refactoring or module splits applied. The [shared coding guide](shared-coding-guide.md) is
**proposed**, with Claude's review open in [Request 12](claude-and-astra.md#requests).

## Scope and findings

Reviewed the main game's 47 GDScript files, scene/resource references and entry points, with
particular attention to battle input, menus, rule queries, movement, perception, rendering and
loading. The untracked Map Workshop and paint tool were outside this pass. Existing game rules,
content, resource formats and event contracts remain intact.

### Doors

Open doors were already walkable in the rules. The physical view did not recognize an adjacent
door as something to click, so it never offered the contextual opening action.

- Clicking an adjacent door now opens its own menu. It shares action builders and rule queries
  with the Operator menu: Open door / Close door, with Lock and Peek where legal.
- A locked door explains that it needs unlocking through the network. An occupied doorway
  explains why Close is unavailable. Unlocking still leaves the door closed.
- Existing action playback refreshes the model, sight, movement choices and hover information
  after opening or closing. No movement rules or interruption behavior were rewritten.
- Native testing confirmed free physical opening, traversal two tiles to the far side, closing
  blocking the return route, and reopening restoring traversal. Moving out of the AI's tether
  still pulls it out while keeping its context, as the rules require.

### Network menus

There were three separate usability faults: groups could be disabled when all their actions
were unavailable; disabled rows could not take focus to show their reason; and replacing a menu
from a mouse click let the same release reach the battlefield, closing the new menu immediately.
Direct button-signal tests did not catch that last fault; native mouse input did.

- Chips and Devices groups remain accessible, including device submenus whose verbs are used
  up. Executable rows still take their availability from the rules.
- Equipped active chips remain visible before deployment, with a connection explanation. Chips
  stay in their own group. Missing targets, insufficient action points, readiness for the next
  hack, power requirements and used verbs have explanations shown on hover and as tooltips.
- Loaded and degraded chip descriptions/costs refresh after use and compaction. Degraded
  Extended thinking now shows its 1.5× effect instead of the full-strength description.
- Existing contextual device labels such as Unlock, Power on, Open and Hold fire were verified
  against execution, costs, current state and each AI's verb-use allowance.
- Menu selection consumes its input before replacing controls. Action menus are drawn and
  picked above the Network status banner, which otherwise covered rows on the small fixture.
- A menu build obtains device options once and reuses them for its device rows. Public query
  signatures and rule authority are unchanged; no persistent cache was introduced.

### Reachability and small cleanup

Checked lexical references against signals, engine callbacks, dynamic ids, scene/resource paths,
tests, command-line preview scripts and the standalone Model Library. No whole script or feature
was proven safe to remove.

Removed unused state parameters from two private helpers and the unused group-availability
calculation. Picking now clears its callbacks when choices expire, releasing captured preview
data rather than retaining it until another pick. Removed repeated device-query work within a
menu build. Deliberate future interfaces (`carry_over`, the deferred Crash action), development
tools, asset previews, map indexes and existing material/animation caches were preserved.

## Measurements

Godot 4.7.2, Apple M1 Pro, headless central processing unit (CPU) timings. The fixture uses the
facility yard's 11 units, Alpha connected within the tether at B, all non-cache devices breached,
and the Facility network revealed; it exposes 15 controlled devices. Each query has 20 warm-ups
and five timed batches. Before and after use the same fixture; only the repeated device-query
path is switched for the comparison. Native rendering was closed during measurement.

Run from the repository root:

```sh
godot --headless --path game -s ../tools/profile_battle.gd
```

Median milliseconds per batch:

| Operation | Calls per batch | Before | After |
|---|---:|---:|---:|
| Network menu construction | 1,000 | 2,520.056 | 499.903 |
| Physical menu construction | 1,000 | 548.195 | 545.818 |
| Movement costs | 1,000 | 350.274 | 351.409 |
| Movement exposure | 100 | 7.451 | 7.280 |
| Perception refresh | 100 | 367.879 | 366.040 |
| State clones | 100 | 141.433 | 140.189 |
| Device verb previews | 100 | 1,414.776 | 1,407.422 |
| Network labels/refresh | 100 | 68.405 | 69.558 |
| Hover cards | 1,000 | 14.442 | 14.278 |
| Physical unit picking | 1,000 | 6.531 | 6.615 |
| Network click classification | 1,000 | 137.863 | 137.125 |
| Settled fog processing | 1,000 | 0.485 | 0.505 |
| Stationary wall processing | 1,000 | 1.267 | 1.317 |
| Repeating the same overlay | 100 | 2.360 | 2.344 |

Network menu samples before: `[2520.056, 2513.522, 2532.406, 2621.343, 2505.274]`.
After: `[499.533, 502.368, 503.659, 499.903, 498.419]`.

The retained optimization reduces menu construction from about 2.52 ms to 0.50 ms per call,
an 80.2% reduction, roughly five times faster in this fixture. The other paths were inspected
and measured but left structurally unchanged; their small timing differences are not claimed
as improvements. These query timings do not establish a rendered frame-rate gain.

Scene setup took 8.072 and 8.027 seconds in these two processes. Those are single observations,
not five-run cold-start measurements, and no loading improvement is claimed. Loading and
animation retargeting remain separate follow-up candidates. Fog already stops rebuilding when
settled, walls skip work when stationary, and identical overlays are already skipped.

## Verification

The existing battle-flow suite now uses a small real battle scene for these regressions:

- Contextual locked-door actions, unlock leaving the door closed, open permitting traversal
  beyond the doorway, close blocking traversal, immediate model updates and occupied-doorway
  rejection in both menu and rules.
- Unloaded/loaded/degraded/next-hack-ready chips, loading and use costs, target explanations,
  compaction refreshes and reloading after a second compaction.
- Breach and same-network access, power requirements, contextual labels, per-AI verb limits,
  and menu availability agreeing with execution on cloned state.
- Unavailable groups/rows, submenu mouse press and release, right-click and Escape navigation,
  post-breach controls and physical/Network transitions.

The mouse helper converts canvas coordinates to window coordinates so input actually reaches
controls in Godot's 64×64 headless window. Removing the input-consumption fix makes the new
regression fail; restoring it passes. Tests do not just emit the submenu button's signal.

`bash tools/check.sh` passed import/script registration and all four suites: battle rules,
hacking/context math, random playthroughs and battle flow. The checker initially hit macOS
certificate/settings-access errors in the restricted environment; it passed with the necessary
local runtime access. Its error detection was preserved.

Native mouse/keyboard checks used the real battle scene with an isolated, temporary small map
containing an access point, locked automatic door, phone and cache. They exercised submenu entry,
Back, right-click, Escape, keyboard activation, post-breach controls, disabled reasons, a used
device verb, power-off blocking network activation, initial loading and next-hack readiness, next-turn loaded
costs, compaction's degraded effect and use cost, and the complete unlock → physical open → walk
through → close → reopen flow. The engine log contained no script/engine errors during this run.

Occupied doorways, cross-network rejection and the second AI's independent allowance were
checked headlessly. This is focused native interaction verification, not a full mission
playthrough or Bryson's creative/playability review. His full playtest remains pending.

After the game-code commit, import succeeded and a normal title → loadout → facility launch was
checked. Chips stayed open under native mouse input; clicking a disabled Locate row displayed
its deployment explanation without closing the submenu. The updated game was restarted for
Bryson to play.

## Deferred candidates — proposals only

None of these changes were applied. Their scope and boundaries need Claude/Astra agreement on
the coding guide, with Bryson retaining the final decision and approving the particular work.

| Candidate | Evidence and possible benefit | Migration cost / uncertainty |
|---|---|---|
| Split battle state and controller by agreed responsibility | The state and controller are approximately 1,500 and 1,050 lines and mix several independently changing systems. Smaller coherent public surfaces could reduce unrelated source reading. | High: trace action queries, mutations, event playback, session setup and preview consumers. A line count alone does not justify a split. |
| One rule-owned action description for availability, costs and blockers | Menus use rule legality but still compose explanations separately. This pass needed several explanation fixes. A shared small contract could prevent disagreement across contextual menus and other views. | Medium/high: agree on descriptor shape, fog-safe information, rejected-action behavior and all consumers. Preserve event/resource formats during migration. |
| Narrow prediction/perception work and explicit change invalidation | A verb preview takes about 14 ms here; a perception refresh about 3.7 ms. These deserve profiling on larger agreed mission fixtures before adding cache complexity. | Medium/high: power, door state, movement, enemy tasks, turns, fog and chip changes all affect results. Incorrect invalidation changes gameplay. |
| Review clone copying as runtime state grows | `Unit.copy()` reflects over properties, and a state clone takes about 1.4 ms here. An explicit or generated copy contract might avoid reflection and clarify mutable ownership. | Medium: generic copying currently protects new fields from accidental omission. Changes need field completeness and clone-isolation evidence. |
| Reduce resource/animation startup work | Full battle scene setup was about eight seconds in the two observed processes. Loading, scene construction and animation retargeting need separate startup profiling. | Medium/high: loading experience, resource lifetime, fallback behavior and asset compatibility need agreement. No repeated cold-start comparison or target-platform budget exists yet. |
| Separate persistent progression and town state from battles | Both are future game systems, and the existing session interface is the natural place to discuss the hand-off. An agreed boundary could keep combat code focused. | Design-dependent: persistence, town behavior and mission outcomes are not yet decided. No framework should be built ahead of those decisions. |

## Handoff

Claude: review Request 12 and record accepted sections, amendments and disagreements in the
guide's response section. Astra's position is the proposed guide as written. Bryson decides
adoption and unresolved choices. This cleanup milestone does not adopt a new architecture.
