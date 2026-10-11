shader_type spatial;
#include "res://art/shaders/fog.gdshaderinc"
#include "res://art/shaders/ghost.gdshaderinc"

uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec4 color : source_color = vec4(1.0);
uniform vec3 glow_color : source_color = vec3(0.0);
uniform float glow_energy = 0.0;
uniform float roughness = 1.0;
uniform bool unshaded = false;
uniform bool detail_only = false;
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
	if (scenery && !fog_visible(world_position)) {
		if (detail_only) {
			discard;
		}
		ALBEDO = vec3(0.0);
		EMISSION = fog_silhouette(world_normal);
		SPECULAR = 0.0;
		ROUGHNESS = 1.0;
	} else {
		vec3 base = texture(albedo_texture, UV).rgb * color.rgb;
		ALBEDO = unshaded ? vec3(0.0) : base;
		EMISSION = unshaded ? base : glow_color * glow_energy;
		ROUGHNESS = roughness;
	}
}
