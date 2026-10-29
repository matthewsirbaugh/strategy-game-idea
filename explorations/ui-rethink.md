# UI rethink: how the player sees and drives the battle

- Status: open. Phase 1, independent research: one Claude session and Astra each write their own
  proposals without seeing the other's. Then Bryson and Claude compare them, pick the most
  promising avenues and start small, quickly iterated experiments.
- Started 2026-10-29 from Bryson's request.

## The question

How should the battle's interface and controls work so the game feels seamless, the effects of
an action are clear before and after it happens, and the screen stays uncluttered? This covers
both halves of a turn and the move between them.

## What Bryson said (2026-10-29)

- The fantasy: you're a resistance operative working with an AI partner against the technocratic
  corporations that control America's government and society in the near future. Each
  character's turn is really two: the Operator moves in the physical world, and the AI jumps
  around the network, hacking devices and manipulating electronics and data to help the Operator
  complete the mission. It's a stealth SRPG where the stealth is part of an environmental puzzle.
- The current build is a decent approximation, and many of the elements the game needs are
  already there.
- The problems aren't in the rules. They are:
  - the gameplay isn't seamless enough;
  - the UI needs redesigning so it's more intuitive and less visually obstructive;
  - the implementation is clunky overall, especially the network view.
- The network view feels cluttered even when very little is on screen. Color coding and unique
  symbols have helped, but they still don't make the actual effects of what you're doing clear.
- Ideally the UI is intelligent: clear and intuitive to use, and it reacts to the current state of
  the board.
- The visuals and the player's way of interacting need to be completely rethought.
- Order of work: deep discussion and research first, then small-scale, quickly iterable
  experiments to find the UI and menu systems that feel best.

## Outputs

| Who | Report | Images and mockups |
|---|---|---|
| Claude (a separate session) | [ui-rethink/claude.md](ui-rethink/claude.md) | `art/concepts/ui-rethink-2026-10-29/claude/` |
| Astra (Request 32) | [ui-rethink/astra.md](ui-rethink/astra.md) | `art/concepts/ui-rethink-2026-10-29/astra/` |

## The prompt

Bryson points each agent here. The same text serves both.

> You're researching a redesign of the battle UI for Bryson's game. Work alone: don't open
> `explorations/ui-rethink/` files other than your own, or the other agent's mockup folder, until
> Bryson says both are done. Independent ideas are the point.
>
> **Read first.** AGENTS.md (Claude already has it), then this file from the top through this
> prompt. Then RULES.md's glossary, so you know what the player is doing. README.md's
> **Running the prototype** and **Code reading routes** show how to run the game and where the
> battle's UI lives (`game/battle/`: `battle.gd`, `battle_menus.gd`, `hud.gd`, `hover_info.gd`,
> `network_view.gd`, `grid_view.gd`, `battle_log.gd`). Read code only as far as you need to
> understand what the player sees and does.
>
> **1. Know the current UI.** Run the game (`godot --path game`, Deploy to facility) and play
> through both halves of several turns if you can. Capture what you need to point at specific
> problems. If you can't drive the game, work from the code and say so. In your report, keep what
> you saw separate from what you read.
>
> **2. Diagnose.** List the concrete problems: what's clunky, what's obstructive, what's
> cluttered, and where an action's effect isn't clear before or after you do it. Give specific
> moments and screens, not general complaints. Give the network view and the switch between the
> two halves of a turn particular attention.
>
> **3. Research.** Study how other games and interfaces handle the same jobs: two linked layers
> (physical and network), previewing consequences, showing enemy intent, reading stealth state,
> and context-sensitive UI that reacts to the board. Start from these and go further: Invisible
> Inc., Into the Breach, XCOM 2, Shadow Tactics, Desperados III, Mark of the Ninja, Hacknet,
> Watch Dogs, Cyber Knights: Flashpoint, Phantom Doctrine, Mario + Rabbids, Gears Tactics,
> Frozen Synapse, Tactical Breach Wizards. Look at good non-game interfaces too where they fit.
> Cite sources. Say what each example teaches and what doesn't transfer here.
> `explorations/genre-basics.md` and its report hold earlier research; build on it rather than
> repeat it.
>
> **4. Propose three to six distinct directions,** from conservative to radical. They should be
> genuinely different approaches, not variations on one. For each:
> - the core idea, in a sentence or two;
> - how the player moves through a turn: selecting, acting on both layers, and switching between
>   them (or not having to switch at all);
> - how it makes the effect of an action clear before and after the action;
> - how it reacts to the board's state, the "intelligent UI";
> - what it removes or hides compared with today;
> - a mockup: a sketch, a diagram or a quick image, whatever makes it clear;
> - risks and costs;
> - the smallest experiment that would test it: something buildable in a day or two, ideally a
>   standalone Godot scene or a toggle, that Bryson can try and judge by feel.
>
> **5. Recommend.** Your top one or two directions and why, and which experiments to run first.
>
> **6. Questions for Bryson,** numbered.
>
> **Limits.**
> - Don't change game code, rules or shared files. Write only your report and your mockup folder.
> - The rules aren't the target. Where a rule makes the UI's job much harder, note it, but don't
>   propose rule changes as the main fix.
> - Keep the established 3D look and the camera unless a direction depends on changing them; if
>   it does, say so plainly.
> - No paid credits (Meshy or otherwise).
> - Follow AGENTS.md's Communication rules: new terms defined at the top, tables where they help,
>   and what you observed, inferred and recommend kept separate.
>
> **Where it goes.** Claude: `explorations/ui-rethink/claude.md`, images in
> `art/concepts/ui-rethink-2026-10-29/claude/`. Astra: `explorations/ui-rethink/astra.md`, images
> in `art/concepts/ui-rethink-2026-10-29/astra/`. Commit only those paths, following AGENTS.md's
> git rules (Astra's subject ends with `(Astra)`), and push. Then tell Bryson in one line that
> it's done.

## Findings

None yet.

## Open questions

Come from the two reports.
