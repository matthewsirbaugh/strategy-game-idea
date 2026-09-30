shader_type spatial;
// A sign laid on a wall or the ground: its art is a mask, drawn either in paint that has worn in
// patches, or in neon that lights up. Cut out rather than blended, so it sits in the opaque pass
// with the surface under it, takes the fog like that surface, and ghosts with its wall.
render_mode cull_back;
#include "res://art/shaders/fog.gdshaderinc"
#include "res://art/shaders/ghost.gdshaderinc"
#include "res://art/shaders/painted.gdshaderinc"

uniform sampler2D art : source_color, filter_linear_mipmap, hint_default_white;
uniform vec3 color : source_color = vec3(0.9);
// Brighter than 0 makes it neon: it glows at this strength, whatever the light around it.
uniform float glow = 0.0;
// How much of the paint has worn away, in patches.
uniform float wear : hint_range(0.0, 1.0) = 0.3;
// Paint on a wet road shines like the road.
uniform float wet : hint_range(0.0, 1.0) = 0.0;
instance uniform float ghost = 0.0;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	if (ghosted(FRAGCOORD.xy, ghost)) {
		discard;
	}
	float grain = fbm(world_position.xz * 2.5 + world_position.y * 3.1);
	float worn = smoothstep(1.0 - wear * 0.6, 1.05 - wear * 0.6, grain);
	float seen = fog_light(world_position);
	ALBEDO = color * seen * mix(1.0, 0.8, grain * wear);
	ROUGHNESS = mix(0.8, 0.2, wet);
	EMISSION = color * glow * mix(0.5, 1.0, seen);
	ALPHA = texture(art, UV).a * (1.0 - worn);
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ALPHA_ANTIALIASING_EDGE = 0.3;
	ALPHA_TEXTURE_COORDINATE = UV * vec2(textureSize(art, 0));
}
