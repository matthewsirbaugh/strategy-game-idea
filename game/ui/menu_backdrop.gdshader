shader_type canvas_item;

void fragment() {
	vec3 art = texture(TEXTURE, UV).rgb;
	float shade = mix(0.12, 0.94, smoothstep(0.1, 0.85, UV.x));
	float edge = smoothstep(0.0, 0.22, UV.y) * smoothstep(0.0, 0.3, 1.0 - UV.y);
	vec3 color = art * shade * mix(0.45, 1.0, edge);
	COLOR = vec4(mix(vec3(0.02, 0.035, 0.043), color, 0.93), 1.0);
}
