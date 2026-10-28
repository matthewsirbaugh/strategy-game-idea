shader_type spatial;
// OpenBrain's emblem on a wall: the logo's dark loops cut out of a flat card, under the fog and
// the ghosting like the wall behind it. A mesh rather than a Decal, since decals can't take the fog.
#include "res://art/shaders/fog.gdshaderinc"
#include "res://art/shaders/ghost.gdshaderinc"

uniform sampler2D mark : source_color, filter_linear_mipmap;
uniform vec3 color : source_color = vec3(0.03);
instance uniform float ghost : instance_index(2) = 0.0;
instance uniform bool scenery : instance_index(5) = false;
varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	if (ghosted(FRAGCOORD.xy, ghost)) {
		discard;
	}
	float ink = 1.0 - texture(mark, UV).r;
	float visibility = scenery ? fog_visibility(world_position) : 1.0;
	ALBEDO = color * visibility;
	ROUGHNESS = 0.35;
	EMISSION = fog_silhouette(world_normal) * (1.0 - visibility);
	ALPHA = ink;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
