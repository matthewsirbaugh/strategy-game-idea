shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur : hint_range(0.0, 6.0) = 2.5;
uniform float amount : hint_range(0.0, 1.0) = 1.0;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec3 world = textureLod(screen_texture, SCREEN_UV, blur).rgb;
	vec2 pixel = SCREEN_UV * VIEWPORT_SIZE;
	vec2 cell = abs(fract(pixel / 36.0) - 0.5);
	float grid = 1.0 - smoothstep(0.012, 0.035, min(cell.x, cell.y));
	float vignette = 1.0 - 0.42 * length((SCREEN_UV - 0.5) * vec2(1.2, 1.0));
	vec3 dark = world * 0.025 + vec3(0.002, 0.006, 0.009);
	ALBEDO = (dark + grid * vec3(0.0006, 0.0018, 0.0023)) * vignette;
	ALPHA = amount;
}
