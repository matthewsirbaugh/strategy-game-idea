shader_type spatial;
// See-through glass for railings and the skybridge, under the fog and the ghosting.
render_mode blend_mix, depth_draw_opaque, cull_disabled;
#include "res://art/shaders/fog.gdshaderinc"
#include "res://art/shaders/ghost.gdshaderinc"

uniform vec3 color : source_color = vec3(0.1, 0.13, 0.15);
uniform float opacity = 0.22;
instance uniform float ghost : instance_index(2) = 0.0;
instance uniform bool scenery : instance_index(5) = false;
varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	if (ghosted(FRAGCOORD.xy, ghost)) {
		discard;
	}
	float visibility = scenery ? fog_visibility(world_position) : 1.0;
	float facing = abs(dot(normalize(NORMAL), normalize(VIEW)));
	ALBEDO = color * visibility;
	ROUGHNESS = 0.05;
	SPECULAR = 0.5 * visibility;
	ALPHA = mix(0.08, opacity + 0.35 * pow(1.0 - facing, 3.0), visibility);
}
