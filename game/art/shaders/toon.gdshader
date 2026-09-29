shader_type spatial;
// Flat cel shading: two tones from a fixed key light, so every model reads the same regardless of
// scene lighting. Shadows are tinted rather than darkened, like painted anime cels.
render_mode unshaded;
// Marks the model's pixels so ink_outline.gdshader draws only outside the silhouette.
stencil_mode write, compare_always, 1;
#include "res://art/shaders/fog.gdshaderinc"

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
uniform vec3 light_direction = vec3(-0.5, -1.0, -0.4);
uniform vec3 shadow_tint : source_color = vec3(0.72, 0.68, 0.84);
uniform float band_softness : hint_range(0.0, 0.2) = 0.03;
// Per model, so every copy can share one material: tint greys out a downed unit, flash whitens a hit.
instance uniform vec3 tint : source_color = vec3(1.0);
instance uniform float flash = 0.0;

void fragment() {
	vec3 world_normal = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float lit = smoothstep(0.0, band_softness, dot(world_normal, -normalize(light_direction)));
	vec3 world = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	ALBEDO = mix(texture(albedo_texture, UV).rgb * mix(shadow_tint, vec3(1.0), lit) * tint * fog_light(world), vec3(1.0), flash);
}
