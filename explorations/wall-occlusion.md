# Wall occlusion: seeing past walls

- Feeds: [environment-art.md](environment-art.md), [battle-mvp.md](battle-mvp.md)
- Status: open
- Next action: Bryson picks an approach and answers the questions at the bottom. Nothing gets
  built until then.

## The question

How the player sees units and tiles behind walls under a free camera while still knowing where
every wall is. Bryson, 2026-09-28: "I think we need ghosting on the walls so that the player
knows that they're there, instead of what we have now." He asked for research on how RPGs usually
handle it before any work.

## Constraints this inherits

- Walls are rules objects: they block movement and sight, tile by tile. The player has to read
  exactly which tiles are walls, from any angle.
- A free RTS-style camera that orbits and zooms (battle-mvp.md). Walls stand 2.8 to 3 m,
  buildings 9 m, on 1.5 m tiles.
- Fog of war darkens what the team can't see. Panels and cameras set into walls are rules
  nodes and have to stay readable.
- Models use the toon shader with an ink outline.

## What went wrong with the cutaway (Claude, from building it)

What's in the game now: walls between the camera and the point it looks at drop to a 0.3 m stub,
like The Sims.

- A stub reads as low cover, though the wall still blocks sight.
- Which walls drop depends on where the camera looks, so walls rise and fall as you pan and turn.
- Anything on a dropped wall has to vanish or float. Walls holding nodes were kept standing as
  lone pillars instead.
- From above, dropped walls are flat slabs that say nothing about height.
- It hides the whole near half of the level, including walls that weren't in the way.

## How other games handle it

| Game | Approach | Notes |
|---|---|---|
| The Sims 4 | Three player-chosen modes: walls up, cutaway (walls between the camera and the back of the house hidden), walls down | Our current approach, without the choice |
| Diablo I and II | The whole wall covering the hero turns see-through, with a dither | Simple and whole-object; the classic answer |
| Jagged Alliance 3 | Walls near the view go transparent; Ctrl+H hides all walls | Some players ask to turn the transparency off |
| XCOM 2 | Automatic wall transparency that can't be turned off | Players report confusion over what blocks shots |
| Divinity: Original Sin 2 | A see-through cutout in buildings around the characters, made with a dissolve shader | Keeps the building whole except where it matters |
| Baldur's Gate 3 | A dithered sphere with a noisy edge, placed where a cast from the character toward the camera hits a wall. Clicks pass through the hole to the floor behind. Roofs lift when you go inside | The current benchmark |
| Invisible, Inc. | Four fixed camera angles and full walls; the hacking view turns the building into transparent tiles and cubes | Closest to our genre; solves it by limiting the camera |
| Many action RPGs | Units drawn as a flat silhouette through whatever hides them | Cheap, and pairs with any of the above |

Dithering ("screen-door" transparency) comes up again and again because it fades a wall without
the sorting problems of real transparency, so outlines and depth stay correct.

## Candidates

| | Idea | Close to | For us | Against |
|---|---|---|---|---|
| A | **Ghost the walls in the way.** Whole wall tiles between the camera and what matters (units, the cursor) turn see-through with a dither, keep their full height, and keep a solid top edge and outline | Diablo, JA3 | Exact to the tile, like the rules; a ghosted wall still reads as 3 m tall; panels on it stay solid; only walls truly in the way change | Can look blocky; several ghosted layers can get busy |
| B | **See-through bubble.** A dithered circle opens in walls around units and the cursor | BG3, DOS2 | The prettiest; the level stays whole | Cuts walls into partial shapes, harder to read tile by tile; more shader work, one bubble per unit |
| C | **Ghost everything in front of the view.** Today's cutaway, but ghosting instead of dropping | The Sims cutaway | Smallest change from now | Keeps the popping as you pan, just softer |

Add-ons that go with any of them: unit silhouettes through walls; a key that ghosts every wall
(like walls down in The Sims, or Ctrl+H in JA3); and later, for interiors, the roof lifting
over the room the team is in (BG3).

Claude's recommendation: **A, with silhouettes and a ghost-all key.** It matches the rules one to
one, keeps wall height readable, and only touches walls that are actually in the way. B is the
upgrade if A looks too blocky once it's in.

## Questions for Bryson

1. Which approach: A, B or C?
2. What counts as "in the way": units only, units and the cursor, or everything near where the
   camera looks?
3. Silhouettes of units behind walls: yes or no?
4. A key that ghosts every wall: yes or no?
5. How ghosted: a see-through wall with a solid top edge, or only a faint outline?

## Findings

### 2026-09-28 — Research (Claude)

The table above. Sources:

- [The Sims 4 wall modes (EA forums)](https://forums.ea.com/discussions/the-sims-4-general-discussion-en/walls-up-%E2%AC%86%EF%B8%8F-cutaway-%E2%86%98%EF%B8%8Fdown-%E2%AC%87%EF%B8%8F---how-do-you-play-%F0%9F%8F%A1/11246536)
- [Diablo II wall transparency (The Phrozen Keep)](https://d2mods.info/forum/viewtopic.php?t=63795) and
  [Diablo-style wall occlusion (Unreal forums)](https://forums.unrealengine.com/t/community-tutorial-diablo-style-wall-occlusion/667931)
- [Jagged Alliance 3: can the transparent walls be disabled? (Steam)](https://steamcommunity.com/app/1084160/discussions/0/3807282847933646201/)
- [XCOM 2: turn off transparent walls? (Steam)](https://steamcommunity.com/app/268500/discussions/0/3108025660996142742/)
- [Recreating Divinity: Original Sin 2's see-through effect (GitHub)](https://github.com/smkplus/Divinity-Origin-Sin-2)
- [Baldur's Gate 3 occlusion cutout, recreated (80.lv)](https://80.lv/articles/artist-recreated-baldur-s-gate-3-occlusion-cutout-effect)
- [Invisible, Inc. camera angles (Steam)](https://steamcommunity.com/app/243970/discussions/0/626329186869631549/)
- [Screen-door transparency (DigitalRune docs)](https://digitalrune.github.io/DigitalRune-Documentation/html/fa431d48-b457-4c70-a590-d44b0840ab1e.htm) and
  [camera occlusion dither for Godot (Godot Shaders)](https://godotshaders.com/shader/camera-occlusion-dither/)
