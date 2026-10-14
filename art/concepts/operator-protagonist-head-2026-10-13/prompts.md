# Request 27 generation prompts

Built-in image_gen mode, 2026-10-13. Candidates for Bryson's review.

The original brief included collar and tee edges. Bryson superseded that instruction
with head and bare neck only during generation. The first front draft is retained
as a superseded version; all four current head views omit clothing.

Native generated references were 1254 × 1254. Saved candidates were resized with
`sips -z 1024 1024` without cropping. Reference numbering below matches the tool
argument order. All calls used `transparent_background: false`.

## Superseded head-front-with-collar-v1.png

Input 1: `art/sources/units/operator_protagonist/body-front.png`

Input 2: `art/sources/units/operator_protagonist/01-main.png`

```text
Use case: identity-preserve.
Asset type: Request 27, one close-up multi-view image-to-3D input for Meshy.
Primary request: Redraw only the exact approved protagonist's HEAD AND NECK as one standalone straight-on FRONT view. Output one square 1024 x 1024 image, one view only.
Input image 1: authoritative body-front reference for identity, exact front-facing hairstyle, face, glasses, respirator, palette, collar, tee and polished stylized 3D rendering.
Input image 2: authoritative approved character sheet, supporting fine details; use only this same protagonist.
Subject: the same young adult man with warm medium tan skin, thick sculpted almost-black curls swept as in the reference, heavy dark eyebrows, amber orange-tinted safety glasses with black frames, and the same charcoal grey respirator with two circular side filters edged in orange. Preserve the exact face proportions, serious neutral expression, mask geometry and orange filter rims. The dark teal jacket's raised collar with orange edging and grey tee neckline form the bottom of the image.
Composition: eye-level orthographic-like straight-on front, head upright without tilt. A large centered head and neck; the topmost curl is around 6 percent below the top edge, collar cut line around 94 percent down. Include every curl, both ears, glasses, respirator filters, complete neck down to the TOP of the jacket collar and tee neckline. Head fills most of the frame. Show only minimal collar at the cut line; no chest, shoulders, body, pack or pole. This will be the scale and lighting reference for matching side, back and three-quarter views.
Materials/details: curls are opaque dark hair throughout, including their side surfaces and gaps, with skin only at the existing hairline, ears and sideburn boundary. Mask body and straps are dark grey and black on all edges. Glasses are a separate physical object, black frames and amber lenses sitting above the mask on the nose and ears, not paint on the face. Maintain the approved design exactly.
Scene/backdrop: plain uniform mid-grey background, even soft neutral studio light, no cast shadow, floor, vignette or scene. Match the body reference's rendering, materials, complexion and colors.
Constraints: no redesign or new decoration; no uncovered face variant, added hair ornaments or equipment. No labels, text, logo, emblem, brand mark, watermark or extra views. Nothing cropped above or beside the head.
```

## head-front.png — bare-neck correction

Input 1: `art/concepts/operator-protagonist-head-2026-10-13/head-front-with-collar-v1.png (edit target before replacement)`

```text
Use case: precise-object-edit.
Asset type: Request 27, isolated head-and-neck input for a separate Meshy head graft.
Primary request: Edit this FRONT head image only to REMOVE ALL CLOTHING. Output one square 1024 x 1024 image.
Input image 1: edit target; keep this exact head, hair, face, ears, eyes, amber glasses, charcoal respirator, orange-rimmed filters and black mask straps unchanged.
Composition: same straight-on eye-level front and same large head size. Keep the head upright, all curls and equipment fully framed. Delete the entire jacket, collar, orange clothing piping, zipper, tee, shoulder fabric and chest. Replace those regions with the same plain mid-grey background. Show only the HEAD and a BARE SKIN NECK, with no shoulders, torso or chest. The bare neck ends cleanly in a flat horizontal cut at the level where it would be grafted into the body's jacket collar, around 92 percent down the image, leaving a small background margin below the neck. This is an isolated game asset head with a neck stem, not a portrait bust on a pedestal.
Materials/details: preserve exact warm tan skin, opaque almost-black curls all the way through, dark grey mask and black straps on every edge, black physical glasses frames and amber lenses. All face equipment remains in place.
Scene/backdrop: plain mid-grey, same even soft neutral light and polished stylized 3D rendering as the target. No cast shadow or environment.
Constraints: change only the clothing removal and termination of the bare neck. Do not change identity, head geometry, hairstyle, glasses, mask, filters, skin tone, camera, head scale or rendering. No clothing, necklace, pack, pole, stand, base, pedestal, shoulders, torso, text, logos, labels, watermark or additional views.
```

## head-side.png

Input 1: `art/concepts/operator-protagonist-head-2026-10-13/head-front.png (native 1254 × 1254 output used as reference)`

Input 2: `art/sources/units/operator_protagonist/body-back.png`

```text
Use case: identity-preserve.
Asset type: Request 27, matching isolated head-and-neck multi-view input for Meshy.
Primary request: Rotate the exact bare-neck head in input image 1 into a TRUE LEFT PROFILE, camera looking at HIS anatomical LEFT side, nose pointing toward the LEFT edge of the image. Output one square 1024 x 1024 image, one view only.
Input image 1: exact front head reference for identity, proportions, scale, opaque dark curls, amber glasses, dark respirator and orange-rimmed filters, bare neck, background and rendering.
Input image 2: authoritative approved BACK body reference, ONLY for the rear hairstyle and the single dark respirator head band with its central rectangular buckle. Ignore its body and all clothing.
Composition: eye-level, orthographic-like true 90-degree side profile; no three-quarter angle, no turning toward camera. Show exactly one side of face. Same head scale, camera height and distance as input image 1; align the highest curls and the clean base of the neck at the same vertical positions as the front image. All hair, ear, glasses, mask and filter edges inside frame. HEAD AND BARE NECK ONLY, terminating in the same clean horizontal graft cut, with background margin below. No clothing, shoulders, torso, chest, collar or tee.
Details: same warm medium tan skin and young adult facial anatomy. Same thick almost-black curls and asymmetric hair silhouette, opaque dark hair on all surfaces; skin only at the established temple/hairline, sideburn border, ear and exposed neck. Same respirator, same black/charcoal side filter with its orange rim and dark end cap. All mask strap side surfaces and edges are black/charcoal. The side straps connect to the SAME single black rear head band shown in input 2, under the curls with its buckle at the rear center. The amber glasses must be a separate physical object: visible black lens frame and temple arm going back above the ear, with a natural gap from skin. Preserve the front reference's design; only reveal its side surfaces.
Scene/backdrop: identical plain mid-grey background and even soft neutral studio light; match polished stylized 3D rendering, material detail, skin tone and colors.
Constraints: change only viewpoint. No redesign, no added straps, hairstyle change or new equipment. No clothing, pack, pole, necklace, stand, pedestal, text, logo, emblem, brand mark, watermark or multiple views.
```

## head-back.png

Input 1: `art/concepts/operator-protagonist-head-2026-10-13/head-front.png (native 1254 × 1254 output used as reference)`

Input 2: `art/concepts/operator-protagonist-head-2026-10-13/head-side.png (native 1254 × 1254 output used as reference)`

Input 3: `art/sources/units/operator_protagonist/body-back.png`

```text
Use case: identity-preserve.
Asset type: Request 27, matching isolated head-and-neck multi-view input for Meshy.
Primary request: Show the exact protagonist's head and bare neck in a straight-on BACK view, rotated 180 degrees from input image 1. Output one square 1024 x 1024 image, one view only.
Input image 1: exact bare-neck front head for identity, scale, curls, skin, mask/glasses design, lighting and rendering.
Input image 2: exact generated LEFT PROFILE of the same head, showing glasses temple arm, opaque dark side hair, charcoal mask and its black side strap routing.
Input image 3: authoritative approved body-back reference, ONLY for the rear hairstyle silhouette and the single broad black rear head band with the small central dark rectangular buckle. Ignore its body and clothes.
Composition: eye-level, orthographic-like direct rear, no three-quarter angle, no head tilt or looking back. Same head size, camera height and distance as the front and profile; align highest curls and lowest neck base vertically with them. Only the HEAD and BARE NECK, ending at a clean flat horizontal graft cut at the bottom, with a small grey margin below. Include all curls, both ears and any naturally visible equipment edges. No clothing, collar, tee, shoulders, torso or chest.
Details: preserve same thick almost-black sculpted curls and their opaque dark side/back surfaces, including the smaller curls below the rear head band. Skin only on ears, the existing nape/hairline boundary and exposed warm tan neck. The same broad black textured respirator head band runs across the rear, with its single dark rectangular adjustment buckle centered as in input image 3. Retain the mask/glasses hardware from input images 1 and 2, only where genuinely visible from this rear angle; strap edges stay black or charcoal, never skin-colored. The mask's orange-rimmed filters may be partly visible symmetrically beside the ears as in the approved rear reference. Do not paint the front of the mask or glasses on the back of the head.
Scene/backdrop: identical plain mid-grey background and soft even neutral light; match the front's polished stylized 3D rendering and colors.
Constraints: change only viewpoint. No redesign, altered hairstyle, extra straps or new equipment. No clothing, backpack, pole, necklace, stand, pedestal, text, label, logo, emblem, brand mark, watermark or additional views.
```

## head-three-quarter.png

Input 1: `art/concepts/operator-protagonist-head-2026-10-13/head-front.png (native 1254 × 1254 output used as reference)`

Input 2: `art/concepts/operator-protagonist-head-2026-10-13/head-side.png (native 1254 × 1254 output used as reference)`

Input 3: `art/concepts/operator-protagonist-head-2026-10-13/head-back.png (native 1254 × 1254 output used as reference)`

```text
Use case: identity-preserve.
Asset type: Request 27, matching isolated head-and-neck multi-view input for Meshy.
Primary request: Show the exact bare-neck protagonist head in a THREE-QUARTER FRONT view of HIS anatomical LEFT side. The head is halfway between input image 1's front and input image 2's left profile: nose points slightly toward the LEFT of the image. Output one square 1024 x 1024 image, one view only.
Input image 1: exact front head, authoritative identity, face, eyes, hair, glasses, mask, filters, bare neck and rendering.
Input image 2: same head's true left profile, authoritative visible left-side glasses temple, hair surfaces and respirator strap routing.
Input image 3: same head's rear view for the dark rear curls and broad black rear mask band and buckle where visible.
Composition: eye-level orthographic-like view around 45 degrees from front; head upright, no tilt, no looking upward or downward. Same head size, camera height and distance as the other views; align crown and neck base vertically. Include complete hair silhouette, near ear, glasses, entire mask and both filters as naturally visible in this angle; far filter partly occluded. Only head and BARE SKIN NECK ending at the same clean horizontal graft cut with a small background margin below. No clothing, shoulders, torso, chest, collar or tee.
Details: preserve the same warm tan complexion and young adult facial proportions, thick almost-black sculpted curls with opaque dark side surfaces, heavy eyebrows, amber glasses with black frames and a separate physical temple arm above the ear, charcoal-grey respirator with unchanged orange-rimmed circular filters and dark vented filter end caps. All mask straps are black/dark charcoal including edges; preserve exactly the side view's strap routing. The glasses sit on the nose and ears above the mask and remain clearly distinct from skin and hair. No design changes.
Scene/backdrop: identical plain mid-grey background with soft even neutral studio light. Same polished stylized 3D rendering, material finish, skin tone and palette.
Constraints: change only viewpoint. Do not redesign identity, hairstyle, gear, materials or proportions. No clothing, pack, pole, necklace, stand, pedestal, text, labels, logo, emblem, brand mark, watermark or additional views.
```

## pack-side.png

Input 1: `art/sources/units/operator_protagonist/pack-back.png`

Input 2: `art/sources/units/operator_protagonist/pack-three-quarter.png`

```text
Use case: precise-object-edit.
Asset type: Request 27, matching separate backpack multi-view input for Meshy.
Primary request: Rotate the exact approved protagonist's pack and camera pole into a TRUE 90-DEGREE SIDE PROFILE, viewed directly from the side where the pole is mounted. Output one square 1024 x 1024 image, one view only.
Input image 1: authoritative straight-on BACK view of the pack, showing the complete exact design. The pole is on the viewer's LEFT in this reference; look at that physical mounted-pole side for the new profile. Do not mirror or move the pole.
Input image 2: authoritative matching three-quarter pack reference for thickness, rounded shell, side hardware, black padded shoulder straps, complete pole and cables, material wear and rendering. Change only the camera angle.
Subject: same worn olive-grey hard-shell rectangular compute backpack with rounded corners, black edge bumpers, dark fasteners, top carry handle and existing ventilation panels. Same padded olive-webbing shoulder straps with black mesh insides, dark buckles and lower waist straps, all still attached. Same black telescoping camera pole fixed to the same side of the case by the same clamps, black ribbed cable sheath and orange cable path. Complete original dark compact cylindrical camera head with blue-green lens glass where visible from this side. Preserve exact relative sizes, pole height and case depth.
Composition: strict orthographic-like true SIDE PROFILE from the mounted-pole side, NOT a three-quarter view. The broad vented outer rear panel is edge-on at the RIGHT edge of the pack profile; the padded body-facing back and shoulder strap loops extend to the LEFT of the shell. The pole and its clamps and orange/black cables are on the near side, visible clearly in profile rather than hidden behind the case. Reveal the existing side geometry; do not create a new broad vented front face. Hardware on the opposite side is naturally occluded. Keep all straps attached and the complete camera, pole, case, buckles and cables in frame. Same camera height, object scale, top camera level and bottom case level as the references; centered with small margins.
Scene/backdrop: same plain mid-grey background and even soft neutral studio light as both approved pack images. No floor line, environment or cast shadow.
Style/medium: same polished stylized 3D prop rendering, olive shell finish, black padding, warm orange cables and restrained wear.
Constraints: reproduce exactly the same pack and hardware; change only viewpoint. No redesign, mirror, missing pole, different camera head, new accessories, detached objects, person or clothing. No text, logo, emblem, brand mark, label, watermark or additional views.
```
