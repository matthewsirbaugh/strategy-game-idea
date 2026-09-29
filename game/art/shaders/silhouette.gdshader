shader_type spatial;
// A unit hidden behind something else shows through it as a flat shape in its color. Drawn last,
// over everything, then kept only where the scene in front of the unit is well in front of it,
// so a unit's own arm behind its body never counts.
render_mode unshaded, depth_test_disabled, depth_draw_never, cull_back, shadows_disabled;

instance uniform vec4 silhouette : source_color, instance_index(3) = vec4(0.0);
uniform sampler2D depth_texture : hint_depth_texture, filter_nearest;
const float HIDDEN_BY = 0.4;

void fragment() {
	if (silhouette.a <= 0.0) {
		discard;
	}
	float depth = texture(depth_texture, SCREEN_UV).r;
	vec4 view = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
	float in_front = -view.z / view.w;
	if (-VERTEX.z - in_front < HIDDEN_BY) {
		discard;
	}
	ALBEDO = silhouette.rgb;
	ALPHA = silhouette.a;
}
