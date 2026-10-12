shader_type spatial;
// Inverted-hull ink line, pushed out in screen space so it stays the same width at any zoom.
// It skips pixels toon.gdshader marked, so only the outer silhouette gets a line. Stencil reads
// only work in the transparent pass, which is why it sets ALPHA.
render_mode unshaded, cull_front, shadows_disabled;
stencil_mode read, compare_not_equal, 1;
#include "res://art/shaders/ghost.gdshaderinc"
#include "res://art/shaders/fog.gdshaderinc"

uniform vec3 ink : source_color = vec3(0.13, 0.1, 0.1);
uniform float width_pixels = 2.0;
// Thinned with the model, so a ghosted prop doesn't show its own dark hull through the gaps.
instance uniform float ghost : instance_index(2) = 0.0;
instance uniform bool scenery : instance_index(5) = false;
instance uniform bool detail_only : instance_index(6) = false;
varying vec3 world_position;

void vertex() {
	vec4 clip = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec2 push = (PROJECTION_MATRIX * vec4(MODELVIEW_NORMAL_MATRIX * NORMAL, 0.0)).xy;
	clip.xy += normalize(push) * width_pixels * 2.0 / VIEWPORT_SIZE * clip.w;
	POSITION = clip;
	vec4 expanded = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * clip;
	world_position = expanded.xyz / expanded.w;
}

void fragment() {
	// Screen-space expansion can cross a cell even when the mesh bounds do not.
	float visibility = scenery ? fog_visibility(world_position) : 1.0;
	if ((detail_only && visibility <= 0.5) || (!SILHOUETTE_INK && visibility <= 0.0)) {
		discard;
	}
	if (ghosted(FRAGCOORD.xy, ghost)) {
		discard;
	}
	ALBEDO = mix(SILHOUETTE_TONE * 0.55, ink, detail_only ? 1.0 : visibility);
	ALPHA = SILHOUETTE_INK || detail_only ? 1.0 : visibility;
}
