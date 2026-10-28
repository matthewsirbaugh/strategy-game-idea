# Art pipeline: how 3D assets get made

- Feeds: DESIGN.md open question 2
- Status: open
- Next action: none here for now. Props are settled in [environment-assets.md](environment-assets.md);
  characters in [character-models.md](character-models.md); buildings in [architecture.md](architecture.md).
  The tool facts below still hold.

> 2026-10-28: trimmed. The retired house style, the September Operators and their Meshy trials
> are in the archive (ARCHIVE.md, batch `2026-10-28-docs-and-galleries`).

## The question

Which art pipeline this project uses, what each costs in money and in Bryson's time, and what each
actually produces.

## Constraints this inherits

- About 10 hours a week (DESIGN.md).
- No budget beyond the existing AI subscriptions, though Fable- or Astra-level spending is on
  the table when it is genuinely needed or for polish (AGENTS.md).
- Final polished assets are deliberately deferred toward the end of the project. The style and
  scale decisions are not.
- Bryson directs the art. Agents and external tools execute it.

## Findings

### 2026-10-09 — Tools and pipelines for the realistic look (Claude; research, not yet agreed)

What's available now:
- Meshy: 2,465 credits. Its image tools can also make concept images (gpt-image-2, 9 to 12
  credits; nano-banana, 3 to 9).
- Blender 5.2 LTS is installed and runs headless by script. The Blender MCP needs Blender open
  with its add-on; it also bridges to Hyper3D Rodin, Hunyuan3D, Sketchfab and Poly Haven, each
  of which needs its own key or trial.
- The machine: M1 Pro, 16 GB. Local generators such as Hunyuan3D want 24 GB or more of GPU memory,
  so generation stays in the cloud.

What people get strong results with (sources below; most are vendor pages or anecdote):
- The common 2026 chain: concept images from an image model, image to 3D (Meshy, Tripo, Rodin,
  Hunyuan3D), cleanup and rigging (Meshy, Tripo or Blender), animation (Meshy's library or
  Mixamo).
- The quality is decided at the first step. Clean, consistent turnaround sheets (A or T-pose, even
  light, plain background) beat any later fix.
- For realistic humans, reviews favor Hyper3D Rodin on skin and faces, and Meshy for the most
  dependable production output. Tripo's strength is rigging breadth; Hunyuan3D trails on humans.
  No source ran a fair head-to-head on realistic humans.
- MetaHuman is licensed for Godot and other engines since June 2025, free under $1M a year in
  revenue. It's the realism ceiling, but it's assembled in Unreal Engine 5.6, with no official
  Blender exporter.
- AI agents driving Blender through MCP (retopology, rigging) are early: feature lists, no
  independent results.

What matters for this game:
- At the battle camera's default distance an Operator is about 55 pixels tall (2026-09-27).
  Silhouette, clothing, palette and animation carry the realism there; faces don't. Faces carry
  it in the 2D dialogue portraits.
- Meshy's three Operators cost 150 credits in all, and each step worked on the first try. The
  realistic-human kit before that (MPFB, cloth simulation) cost hours per character, and Bryson
  dropped it on 2026-09-27.

Sources: [AI-to-3D chain (X)](https://x.com/_summer_plays_/status/2048170520890245409),
[Meshy guide](https://github.com/meshy-dev/Meshy-guide),
[Meshy image to 3D](https://www.meshy.ai/features/image-to-3d),
[Meshy vs Tripo vs Rodin](https://coruzant.com/ai/best-ai-for-3d-models-honest-comparison/),
[Meshy, Tripo, Rodin, Hunyuan 3D](https://marcellinusprevailer.com/meshy-vs-tripo-ai-vs-rodin-vs-hunyuan-3d-best-ai-3d-generator-2077dd4d4533),
[MetaHuman in other engines (CG Channel)](https://www.cgchannel.com/2025/06/you-can-now-sell-metahumans-or-use-them-in-unity-or-godot/),
[MetaHuman license](https://www.metahuman.com/license),
[Agents in DCC apps, SIGGRAPH 2026](https://www.jonpeddie.com/news/sidefx-and-nvidia-bring-mcp-powered-ai-agents-to-houdini-22s-rigging-workflow-at-siggraph-2026/).

### 2026-09-27 — What Meshy can do for us (Claude)

Bryson installed the Meshy MCP server (key in the macOS Keychain, launcher `~/.local/bin/meshy-mcp`)
and asked what it offers, especially rigging and animation. From Meshy's docs and the server's
own tool definitions (v0.5.2); nothing generated yet. Balance on 2026-09-27: 3,100 credits.

| Step | Tool | Credits | Notes |
|---|---|---|---|
| Model from front and back views | `meshy_multi_image_to_3d` | 30 textured | Ask for a T-pose when it will be rigged |
| Lower the polycount | `meshy_remesh` | 5 | Rigging needs 300k faces or fewer |
| Rig | `meshy_rig` | 5 | Humanoid only, textured, facing +Z. Walk and run included |
| Each extra animation | `meshy_animate` | 3 | Library of 590+ clips: idles, crouch walks, shooting, reloads, hit reactions, deaths, climbing, vaulting |

- Paid plans own their output outright; the free tier is CC BY 4.0.
- Limits: non-humanoids (a bot or a drone partner) can't be auto-rigged. Clips are generic motion
  capture, so anything specific to the game, such as hacking at a terminal, may not exist.
  Every rigged character shares Meshy's skeleton, so clips carry across all three Operators.

## Questions to answer

1. How much does this depend on what the game turns out to be?
2. What does each pipeline cost per asset, in money and in Bryson's own hours?
3. What counts as "substantial enough to judge the look" for a prototype asset?
4. What has to be decided early anyway — style, scale, camera, animation needs — even though
   final assets come late?

## Decision

None yet.
