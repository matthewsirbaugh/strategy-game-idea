shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled;

// Covers the screen with a blurred, blue-washed copy of the physical map, so the network drawn on
// top reads as its own layer. The screen copy only holds opaque geometry, so labels and overlays
// drawn earlier drop out as well.
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform vec3 wash : source_color = vec3(0.62, 0.8, 1.0);
uniform float wash_strength : hint_range(0.0, 1.0) = 0.55;
uniform float blur : hint_range(0.0, 6.0) = 3.0;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec3 world = textureLod(screen_texture, SCREEN_UV, blur).rgb;
	ALBEDO = mix(world, wash, wash_strength);
	ALPHA = 1.0;
}
