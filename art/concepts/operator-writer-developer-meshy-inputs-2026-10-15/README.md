# Request 29: writer and developer Meshy inputs

Candidates generated with the built-in image_gen tool on 2026-10-15.
Based on the [approved brief](../../briefs/operator-writer-developer-meshy-inputs.md).
Bryson activated Request 29 in this chat. These are candidates for his selection.

- [Writer: ten views](operator_writer/README.md)
- [Developer: ten views](operator_developer/README.md)
- [Exact prompts and input references](prompts.json)
- [Image dimensions, hashes and generation provenance](manifest.json)

Each character has body front/back/left profile, head front/left three-quarter/left profile/back,
and pack back/three-quarter/camera-side profile. Body images are 1024 × 1536; heads and packs
are 1024 × 1024. Every image contains one view.

The body views omit packs, pack straps and cameras. The writer's body hair is pinned up clear
of the coat; her isolated head keeps the approved full-length curls. Head images contain no
shoulders or clothing; the masks/gaiters remain wrapped around the neck. Pack views retain
shoulder straps and full camera assemblies, on the writer's left and developer's right.

## Review and handoff

All twenty views were visually inspected for framing, view direction, clothing separation,
hair and equipment placement against the approved sheets. File names, dimensions, PNG
integrity, hashes and gallery links passed verification. Body profiles received a framing
correction to bring them closer to the front/back scale. Pack profiles received a side
correction; the developer's visible right strap also received its missing coiled cable.
Square tool outputs were resized from 1254 × 1254 to 1024 × 1024 without cropping; bodies
were generated at their final size. These generated views are not measured orthographic
renders from a shared mesh, so fine geometric consistency remains to be evaluated in Meshy.

No source images or old pack crops were changed. After Bryson picks, copy his chosen files
unchanged to `art/sources/units/operator_writer/` and `operator_developer/`, replace the
old pack crops as the brief directs, and mark Request 29 delivered. Claude's modeling handoff
is in the brief; no Meshy generation has been run for this request.
