# Archive

Old ideas and assets that still have value but aren't part of this project live outside it, in
`~/Desktop/Archive/strategy-game-idea/`. The archive's own README explains its structure; its
`INDEX.md` lists every batch from every project. Agents don't read the archive unless Bryson asks.

| Date | Batch | What and why |
|---|---|---|
| 2026-10-10 | `2026-10-10-edgerunners-era-art` | 107 files from the retired Edgerunners and Anthropomorphic-facility look: the old references, the Operator, AI partner and compute-pack concepts, and the images sent to Meshy. Bryson abandoned the previous art when the look turned realistic. Last in the project at commit `df98077` |
| 2026-10-11 | AI Strategy Game Model Archive | 35 Meshy downloads (525 MB), every `art/sources/**/meshy-*.glb`, moved out so the repository stops growing by tens of MB per model; Bryson chose this over Git LFS. 29 were committed and remain in git history up to commit `81b161e`; 6 remesh downloads never were |
| 2026-10-13 | `2026-10-13-retired-docs` | Dead docs, at Bryson's request: `explorations/environment-art.md`, `environment-style-study.md` and `battle-mvp.md`, and `claude-and-astra.md` with every closed request in full. Last in the project at commit `0539bde` |
| 2026-10-13 | `2026-10-13-one-off-verifiers` | Eight completed one-off scripts from `tools/`, approved in Request 26: `verify_blocker_menus.gd`, `verify_fog.gd`, `verify_fog_fade.gd`, `verify_fog_outline.gd`, `verify_object_menus.gd`, `verify_vision_ticks.gd`, `review_fog_look.gd` and `fog_prototype.gd`. No adjacent `.uid` files existed. Copied and SHA-256 verified before removal; profilers, permanent tests and production tools remain. Last in the project at `5d1f25d`. Older explorations still link these original paths; restore from the batch's `files/tools/` folder or git history |

Older docs still name these files by their project paths: anything under
`art/reference/retired/`, `art/concepts/companions/`, `art/concepts/operator-turnarounds/`,
`art/concepts/ai-*` or `art/meshy/` as of that date. The archive keeps the same paths under the
batch's `files/` folder, and git has them at `df98077`.

Meshy's raw model downloads live in a second archive of their own,
`~/Desktop/AI Strategy Game Model Archive/`, laid out like `art/sources/`: `<category>/<id>/meshy-*.glb`.

The models the game loads stay in `game/` as placeholders until new art replaces them (Bryson,
2026-10-10).
