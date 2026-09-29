shader_type spatial;
// Floors, walls and the yard: a texture laid in world space, so it runs on across tiles and never
// stretches when a wall is cut down, and darkened where the fog says no one can see.
#include "res://art/shaders/fog.gdshaderinc"
#include "res://art/shaders/ghost.gdshaderinc"

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable, hint_default_white;
uniform vec3 tint : source_color = vec3(1.0);
uniform float repeats_per_metre = 1.0;
instance uniform float ghost = 0.0;

varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	if (ghosted(FRAGCOORD.xy, ghost)) {
		discard;
	}
	vec3 blend = abs(world_normal);
	blend /= blend.x + blend.y + blend.z;
	vec3 p = world_position * repeats_per_metre;
	vec3 color = texture(albedo_texture, p.zy).rgb * blend.x
		+ texture(albedo_texture, p.xz).rgb * blend.y
		+ texture(albedo_texture, p.xy).rgb * blend.z;
	ALBEDO = color * tint * fog_light(world_position);
}
