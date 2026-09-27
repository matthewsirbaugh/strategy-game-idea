shader_type spatial;
// Inverted-hull ink line, pushed out in screen space so it stays the same width at any zoom.
// It skips pixels toon.gdshader marked, so only the outer silhouette gets a line. Stencil reads
// only work in the transparent pass, which is why it sets ALPHA.
render_mode unshaded, cull_front;
stencil_mode read, compare_not_equal, 1;

uniform vec3 ink : source_color = vec3(0.13, 0.1, 0.1);
uniform float width_pixels = 2.0;

void vertex() {
	vec4 clip = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec2 push = (PROJECTION_MATRIX * vec4(MODELVIEW_NORMAL_MATRIX * NORMAL, 0.0)).xy;
	clip.xy += normalize(push) * width_pixels * 2.0 / VIEWPORT_SIZE * clip.w;
	POSITION = clip;
}

void fragment() {
	ALBEDO = ink;
	ALPHA = 1.0;
}
