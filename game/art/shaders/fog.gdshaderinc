// Fog of war as light: a map with one texel per tile, 1 where the team can see and 0 where it
// can't. Hidden parts of the level keep their shape and texture but sit in the dark; seen parts
// are lit brighter than the bare texture, like a light overhead.
global uniform sampler2D fog_map : filter_nearest;
// The lit area in world metres: x and z of its corner, then its width and depth. Zero size, as
// outside a battle, turns the fog off.
global uniform vec4 fog_bounds;
const float FOG_DARK = 0.42;
const float FOG_LIT = 1.3;

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
