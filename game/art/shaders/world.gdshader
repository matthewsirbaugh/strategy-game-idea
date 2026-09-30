shader_type spatial;
// Floors, walls and the yard, painted rather than photographic: the texture laid in world space so
// it runs on across tiles and never stretches when a wall is cut down, flattened toward its
// average so only soft grime survives, then shaped by height, seams and large, slow variation.
// Darkened where the fog says no one can see.
#include "res://art/shaders/fog.gdshaderinc"
#include "res://art/shaders/ghost.gdshaderinc"

const float CELL = 1.5;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_enable, hint_default_white;
uniform vec3 tint : source_color = vec3(1.0);
uniform float repeats_per_metre = 1.0;
// How much of the texture's own contrast survives: 0 is one flat tone, 1 the raw texture.
uniform float detail : hint_range(0.0, 1.0) = 0.35;
// Walls: darker at the base, lighter toward the top over this many metres, and a thin line at
// every tile seam. Zero turns both off.
uniform float wall_height = 0.0;
// Floors: faint seam lines so the grid reads without gaps between tiles.
uniform float grid_lines : hint_range(0.0, 1.0) = 0.0;
// Wet ground: 0 dry, 1 rain-soaked, with puddles that turn nearly to mirror.
uniform float wet : hint_range(0.0, 1.0) = 0.0;
// Diagonal hazard stripes, for the band along the foot of perimeter walls.
uniform vec3 stripe_color : source_color = vec3(1.0);
uniform float stripes : hint_range(0.0, 1.0) = 0.0;
instance uniform float ghost = 0.0;

varying vec3 world_position;
varying vec3 world_normal;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

// 1 on a seam line along coordinate c, antialiased so it stays about a pixel wide far off.
float seam(float c, float width) {
	float d = abs(fract(c / CELL + 0.5) - 0.5) * CELL;
	return 1.0 - smoothstep(width, width + fwidth(c) * 1.5, d);
}

vec3 triplanar(vec3 p, vec3 blend, float lod_bias) {
	return texture(albedo_texture, p.zy, lod_bias).rgb * blend.x
		+ texture(albedo_texture, p.xz, lod_bias).rgb * blend.y
		+ texture(albedo_texture, p.xy, lod_bias).rgb * blend.z;
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	if (ghosted(FRAGCOORD.xy, ghost)) {
		discard;
	}
	vec3 blend = abs(world_normal);
	blend /= blend.x + blend.y + blend.z;
	// Each tile shifts its texture, so the repeat never lines up from one tile to the next.
	vec2 tile = floor(world_position.xz / CELL);
	vec3 shift = vec3(hash(tile), hash(tile + 17.0), hash(tile + 41.0)) * 7.0;
	vec3 p = world_position * repeats_per_metre + shift;
	vec3 raw = triplanar(p, blend, 0.0);
	vec3 average = textureLod(albedo_texture, vec2(0.5), 12.0).rgb;
	vec3 color = mix(average, raw, detail) * tint;

	float slow = value_noise(world_position.xz / 6.0) * 0.6 + value_noise(world_position.xz / 2.3) * 0.4;
	color *= mix(0.86, 1.08, slow) * mix(0.95, 1.04, hash(tile + 5.0));

	float upward = step(0.7, world_normal.y);
	if (stripes > 0.0) {
		float along = blend.x > blend.z ? world_position.z : world_position.x;
		float band = step(0.5, fract((along + world_position.y) / 0.45));
		color = mix(color, stripe_color * mix(0.85, 1.0, slow), band * stripes);
	}
	if (wall_height > 0.0 && upward < 0.5) {
		float t = clamp(world_position.y / wall_height, 0.0, 1.0);
		float stepped = (floor(t * 3.0) + smoothstep(0.35, 0.65, fract(t * 3.0))) / 3.0;
		color *= mix(0.62, 1.05, stepped);
		color *= mix(0.7, 1.0, smoothstep(0.05, 0.25, world_position.y));
		float along = blend.x > blend.z ? world_position.z : world_position.x;
		color *= 1.0 - 0.6 * seam(along, 0.012);
	}
	if (grid_lines > 0.0 && upward > 0.5) {
		// Joints catch the light rather than darken, so the grid still reads where the fog is dark.
		float lines = max(seam(world_position.x, 0.01), seam(world_position.z, 0.01));
		color *= 1.0 + 0.45 * grid_lines * lines;
	}

	float roughness = 0.85;
	if (wet > 0.0 && upward > 0.5) {
		float puddle = smoothstep(0.58, 0.66, value_noise(world_position.xz / 3.1 + 11.0));
		color *= mix(1.0, 0.8, wet * (0.3 + 0.7 * puddle));
		roughness = mix(0.85, mix(0.38, 0.12, puddle), wet);
	}
	ALBEDO = color * fog_light(world_position);
	ROUGHNESS = roughness;
}
