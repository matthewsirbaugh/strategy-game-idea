shader_type spatial;
// Anime shading lit by the scene, shared by characters and props so they stand in the same light
// as the level. Each light paints its side of the model in one soft-edged band of its own color,
// the scene's ambient light is the shadow side, and every light that grazes an edge leaves a rim
// of its color, which holds the silhouette against a dark street.
// Marks the model's pixels so ink_outline.gdshader draws only outside the silhouette.
stencil_mode write, compare_always, 1;
#include "res://art/shaders/fog.gdshaderinc"
#include "res://art/shaders/ghost.gdshaderinc"

// How gradually light gives way to shadow, for every model at once: near 0 is hard cel, higher is
// softer and more painterly.
global uniform float toon_softness;
// Where light turns to shadow, as the cosine of the angle to the light. Above 0 leaves more of the
// model in shadow, the way anime lights a figure.
const float TERMINATOR = 0.1;
const float RIM_WIDTH = 0.3;
const float RIM_STRENGTH = 0.9;
// A faint edge that needs no light at all, so a figure still separates from a dark wall.
const vec3 EDGE_GLOW = vec3(0.16, 0.18, 0.32);

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
// Per model, so every copy can share one material: tint greys out a downed unit, flash whitens a hit,
// ghost thins out a prop in the camera's way. The ink and silhouette passes read the same slots,
// so the indices are pinned and must match across the three shaders.
instance uniform vec3 tint : source_color, instance_index(0) = vec3(1.0);
instance uniform float flash : instance_index(1) = 0.0;
instance uniform float ghost : instance_index(2) = 0.0;

float rim(vec3 normal, vec3 view) {
	return smoothstep(1.0 - RIM_WIDTH, 1.0 - RIM_WIDTH * 0.6, 1.0 - clamp(dot(normal, view), 0.0, 1.0));
}

void fragment() {
	if (ghosted(FRAGCOORD.xy, ghost)) {
		discard;
	}
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float seen = fog_light(world);
	ALBEDO = mix(texture(albedo_texture, UV).rgb * tint * seen, vec3(1.0), flash);
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
	EMISSION = EDGE_GLOW * rim(NORMAL, VIEW) * seen + vec3(flash) * 2.0;
}

void light() {
	float facing = dot(NORMAL, LIGHT);
	float band = smoothstep(TERMINATOR - toon_softness, TERMINATOR + toon_softness, facing);
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * band / PI;
	float grazing = smoothstep(-0.1, 0.3, facing);
	SPECULAR_LIGHT += LIGHT_COLOR * ATTENUATION * rim(NORMAL, VIEW) * grazing * RIM_STRENGTH / PI;
}
