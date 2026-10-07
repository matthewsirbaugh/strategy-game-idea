shader_type spatial;
// Ground painted in flat tones: paving slabs lined up with the tiles so their joints are the grid,
// or asphalt with worn patches, oil and cracks. Outdoors it is wet: puddles turn to mirror and
// ripple in the rain. Darkened where the fog says no one can see.
#include "res://art/shaders/fog.gdshaderinc"
#include "res://art/shaders/painted.gdshaderinc"

uniform vec3 base_color : source_color = vec3(0.3);
// Slabs this many metres square; zero for asphalt, which has no joints.
uniform float slab = 0.0;
// How much lighter the joints are than the slabs, as a share: they catch the light, so the grid
// reads in the dark. Below zero, they are darker.
uniform float joint_lift = 0.5;
uniform float grime : hint_range(0.0, 1.0) = 0.5;
uniform float cracks : hint_range(0.0, 1.0) = 0.0;
uniform float wet : hint_range(0.0, 1.0) = 0.0;

varying vec3 world_position;
varying vec3 world_normal;

// The slope of the water where rings spread from raindrops, one drop to a cell of this grid.
vec2 ripple_slope(vec2 p, float time) {
	vec2 i = floor(p);
	vec2 offset = fract(p) - 0.5 - (vec2(hash(i), hash(i + 7.3)) - 0.5) * 0.5;
	float age = fract(time * 0.8 + hash(i + 3.1));
	float r = length(offset);
	float x = r - age * 0.45;
	float wave = cos(x * 45.0) * exp(-x * x * 900.0) * (1.0 - age);
	return offset / max(r, 0.001) * wave;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec2 p = world_position.xz;
	vec3 color = base_color * mix(0.86, 1.1, fbm(p * 0.12));
	if (slab > 0.0) {
		color *= mix(0.9, 1.1, hash(floor(p / slab)));
	}
	color *= 1.0 - 0.25 * patches(p * 0.6, 0.35 * grime);
	color *= 1.0 - 0.35 * patches(p * 0.35 + 50.0, 0.1 * grime);
	if (cracks > 0.0) {
		float border = cell_border(p * 0.9);
		float line = 1.0 - smoothstep(0.012, 0.012 + fwidth(border) * 1.5, border);
		float cracked = smoothstep(0.55, 0.7, fbm(p * 0.25 + 9.0));
		color *= 1.0 - 0.55 * line * cracked * cracks;
	}
	if (slab > 0.0) {
		float joints = max(joint(p.x, slab, 0.016), joint(p.y, slab, 0.016));
		color *= 1.0 + joint_lift * joints;
	}

	float roughness = 0.9;
	bool facing_up = world_normal.y > 0.7;
	if (wet > 0.0 && facing_up) {
		float puddle = smoothstep(0.5, 0.56, fbm(p * 0.3 + 11.0));
		color *= mix(1.0, 0.55, wet * (0.3 + 0.7 * puddle));
		roughness = mix(0.9, mix(0.32, 0.04, puddle), wet);
		vec2 slope = (ripple_slope(p * 3.0, TIME) + ripple_slope(p * 3.0 + 0.5, TIME + 0.37)) * 0.08 * puddle * wet;
		NORMAL = normalize((VIEW_MATRIX * vec4(normalize(vec3(-slope.x, 1.0, -slope.y)), 0.0)).xyz);
	}

	ALBEDO = color * fog_light(world_position);
	EMISSION = vision_glow(color, world_position);
	ROUGHNESS = roughness;
}
