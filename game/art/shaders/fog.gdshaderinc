// Fog of war as light: a map with one texel per tile, 1 where the team can see and 0 where it
// can't. Hidden parts of the level keep their shape and texture but sit in the dark; seen parts
// are lit brighter than the bare texture, like a light overhead.
global uniform sampler2D fog_map : filter_nearest;
// The lit area in world metres: x and z of its corner, then its width and depth. Zero size, as
// outside a battle, turns the fog off.
global uniform vec4 fog_bounds;
const float FOG_DARK = 0.42;
const float FOG_LIT = 1.3;
// What the team can see also glows faintly, a cool moonlit lift, so seen ground reads at night
// even where no lamp reaches. A seen tile in the dark gets half of it.
const vec3 VISION_GLOW = vec3(0.13, 0.16, 0.22);

// How much the team sees here: 0 hidden, 1 seen and lit. Outside a battle, 0.
float fog_seen(vec3 world) {
	if (fog_bounds.z <= 0.0) {
		return 0.0;
	}
	vec2 uv = (world.xz - fog_bounds.xy) / fog_bounds.zw;
	if (any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0)))) {
		return 0.0;
	}
	return texture(fog_map, uv).r;
}

float fog_light(vec3 world) {
	if (fog_bounds.z <= 0.0) {
		return 1.0;
	}
	vec2 uv = (world.xz - fog_bounds.xy) / fog_bounds.zw;
	if (any(lessThan(uv, vec2(0.0))) || any(greaterThan(uv, vec2(1.0)))) {
		return 1.0;
	}
	return mix(FOG_DARK, FOG_LIT, texture(fog_map, uv).r);
}

vec3 vision_glow(vec3 albedo, vec3 world) {
	return albedo * VISION_GLOW * fog_seen(world) * 4.0;
}
