shader_type spatial;
// The architecture kit's solid surfaces: the imported colour, metal and roughness kept (the props'
// fog shader drops metal), under the fog and the ghosting like every other piece of scenery.
#include "res://art/shaders/fog.gdshaderinc"
#include "res://art/shaders/ghost.gdshaderinc"
#include "res://art/shaders/painted.gdshaderinc"

uniform vec4 color : source_color = vec4(1.0);
uniform float roughness = 0.5;
uniform float metallic = 0.0;
uniform vec3 glow_color : source_color = vec3(0.0);
uniform float glow_energy = 0.0;
// Faint tone drift, so long runs of white panel don't read as one flat colour.
uniform float variation = 0.06;
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
	float visibility = scenery ? fog_visibility(world_position) : 1.0;
	vec2 p = world_position.xz + world_position.yy * vec2(0.7, -0.4);
	vec3 base = color.rgb * (1.0 - variation + variation * 2.0 * fbm(p * 0.35));
	ALBEDO = base * visibility;
	METALLIC = metallic * visibility;
	ROUGHNESS = mix(1.0, roughness, visibility);
	SPECULAR = 0.5 * visibility;
	EMISSION = mix(fog_silhouette(world_normal), glow_color * glow_energy, visibility);
}
