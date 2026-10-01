shader_type spatial;
// A tile marked for a choice: a bright border over a faint fill, like a marking projected onto
// the ground, so it reads at a glance without hiding the floor. Unlit, so it reads the same in
// light and dark; the border is bright enough to bloom a little.
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 color : source_color = vec4(1.0);
uniform float border_strength : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec2 from_middle = abs(UV - 0.5) * 2.0;
	float border = smoothstep(0.91, 0.95, max(from_middle.x, from_middle.y)) * border_strength;
	ALBEDO = color.rgb * (1.0 + border * 0.8);
	ALPHA = clamp(color.a * 0.65 + border * 0.8, 0.0, 1.0);
}
