shader_type spatial;
render_mode unshaded;
#include "res://art/shaders/fog.gdshaderinc"
#include "res://art/shaders/ghost.gdshaderinc"

instance uniform float ghost : instance_index(2) = 0.0;
instance uniform bool fog_partial : instance_index(6) = true;
varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	if ((fog_partial && fog_visible(world_position)) || ghosted(FRAGCOORD.xy, ghost)) {
		discard;
	}
	float shade = world_normal.y > 0.5 ? 0.48 : (abs(world_normal.x) > 0.5 ? 0.28 : 0.34);
	ALBEDO = vec3(shade);
}
