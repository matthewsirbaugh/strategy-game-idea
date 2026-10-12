// Animated brightness and visibility, each with one texel per tile.
global uniform sampler2D fog_map : filter_linear, repeat_disable;
global uniform sampler2D fog_visibility_map : filter_linear, repeat_disable;
// The lit area in world metres: x and z of its corner, then its width and depth. Zero size, as
// outside a battle, turns the fog off.
global uniform vec4 fog_bounds;
const float FOG_DARK = 0.42;
const float FOG_LIT = 1.3;
// What the team can see also glows faintly, a cool moonlit lift, so seen ground reads at night
// even where no lamp reaches. A seen tile in the dark gets half of it.
const vec3 VISION_GLOW = vec3(0.13, 0.16, 0.22);
const vec3 SILHOUETTE_TONE = vec3(0.014, 0.018, 0.026);
const float SILHOUETTE_FORM = 0.12;
const bool SILHOUETTE_INK = true;
const float FOG_EDGE_WIDTH = 0.2;

vec3 fog_silhouette(vec3 normal) {
	return SILHOUETTE_TONE * (1.0 + SILHOUETTE_FORM * (normal.y > 0.5 ? 1.0 : -0.5));
}

// Soften toward darker neighbours inside the cell, never leaking detail into a hidden cell.
float fog_sample(sampler2D field, vec2 uv) {
	vec2 size = vec2(textureSize(field, 0));
	vec2 tile = uv * size;
	vec2 center = floor(tile) + vec2(0.5);
	vec2 part = fract(tile);
	vec2 direction = step(vec2(0.5), part) * 2.0 - 1.0;
	vec2 weight = smoothstep(vec2(0.0), vec2(FOG_EDGE_WIDTH), min(part, vec2(1.0) - part));
	float current = texture(field, center / size).r;
	float across = min(current, texture(field, (center + vec2(direction.x, 0.0)) / size).r);
	float along = min(current, texture(field, (center + vec2(0.0, direction.y)) / size).r);
	return min(mix(across, current, weight.x), mix(along, current, weight.y));
}

float fog_visibility(vec3 world) {
	if (fog_bounds.z <= 0.0) {
		return 1.0;
	}
	vec2 uv = (world.xz - fog_bounds.xy) / fog_bounds.zw;
	if (any(lessThan(uv, vec2(0.0))) || any(greaterThanEqual(uv, vec2(1.0)))) {
		return 1.0;
	}
	return fog_sample(fog_visibility_map, uv);
}

// How much the team sees here: 0 hidden, 1 seen and lit. Outside a battle, 0.
float fog_seen(vec3 world) {
	if (fog_bounds.z <= 0.0) {
		return 0.0;
	}
	vec2 uv = (world.xz - fog_bounds.xy) / fog_bounds.zw;
	if (any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0)))) {
		return 0.0;
	}
	return fog_sample(fog_map, uv);
}

float fog_light(vec3 world) {
	if (fog_bounds.z <= 0.0) {
		return 1.0;
	}
	vec2 uv = (world.xz - fog_bounds.xy) / fog_bounds.zw;
	if (any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0)))) {
		return 1.0;
	}
	return mix(FOG_DARK, FOG_LIT, fog_sample(fog_map, uv));
}

vec3 vision_glow(vec3 albedo, vec3 world) {
	return albedo * VISION_GLOW * fog_seen(world) * 4.0;
}
