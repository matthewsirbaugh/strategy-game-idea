# Art pipeline: how 3D assets get made

- Feeds: DESIGN.md open question 2
- Status: open
- Next action: Astra makes a first pass from [the art brief](../art/astra-brief.md) (Priority 1
  only); Bryson reviews the previews

## The question

Which art pipeline this project uses. Bryson wants to understand the available pipelines, what
they cost in money and in his time, and see examples of what each one actually produces before
committing to anything.

2026-09-24: the game is 3D, and Bryson wants it to be good looking (DESIGN.md). He plans to
start on art with the Blender MCP as soon as the battle MVP playtest validates the game. The
MVP's 3D scene is built so that models can replace its greybox shapes directly.

## Constraints this inherits

- About 10 hours a week (DESIGN.md).
- No budget beyond the existing AI subscriptions, though Fable- or Astra-level spending is on
  the table when it is genuinely needed or for polish (AGENTS.md).
- Final polished assets are deliberately deferred toward the end of the project. The style and
  scale decisions are not.
- Bryson directs the art. Agents and external tools execute it.

## Candidates

The full list, with what each is for and its license caveats, is in section 7 of
[the art brief](../art/astra-brief.md#7-how-to-make-it-a-free-pipeline-that-ai-can-drive). In
short: headless Blender driven by Python build scripts for hard-surface work; MPFB2 or an
image-to-3D generator (TRELLIS, Hunyuan3D, Hyper3D Rodin) for organic shapes; Rigify, Mixamo and
Quaternius's CC0 animation library for rigging and motion; Poly Haven and ambientCG for textures.

## Findings

### 2026-09-24 — Bryson's art direction, and what this Mac can do (Claude)

- Bryson: "stylized but realistic," and "a sort of solar punk meets corporate AI future with
  advertisements." He asked Claude to design one Operator and AI pair plus set pieces as a brief
  for Astra's first Blender pass, with advice on free, AI-driven ways to make 3D models. The brief
  is [art/astra-brief.md](../art/astra-brief.md).
- Checked on Bryson's Mac: Blender 5.2 LTS runs headless Python build scripts and exports glTF, so
  an agent can build, render and export assets without the UI. The brief's preview-camera code
  was run there, and a 1.7 m figure comes out about 55 pixels tall from the battle camera at
  default zoom.
- The Blender MCP server is configured and its addon is installed, but it only responds while
  Blender is open and connected, so which generators it has enabled (Hyper3D, Hunyuan3D, Poly
  Haven, Sketchfab) is still unchecked. MPFB2 (MakeHuman for Blender) is not installed.

## Questions to answer

1. How much does this depend on what the game turns out to be?
2. What does each pipeline cost per asset, in money and in Bryson's own hours?
3. What counts as "substantial enough to judge the look" for a prototype asset?
4. What has to be decided early anyway — style, scale, camera, animation needs — even though
   final assets come late?

## Decision

None yet.
