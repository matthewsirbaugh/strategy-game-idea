shader_type spatial;
// Concrete walls painted in flat tones rather than photographed: formwork panels with thin joints,
// grime blocked in as shapes and kept to its panel, streaks running down from the cap, a darker
// foot, and on buildings, rows of windows. Darkened where the fog says no one can see.
#include "res://art/shaders/fog.gdshaderinc"
#include "res://art/shaders/ghost.gdshaderinc"
#include "res://art/shaders/painted.gdshaderinc"

const float FLOOR_HEIGHT = 2.8;

uniform vec3 base_color : source_color = vec3(0.4);
// Formwork panels, width along the wall by height, in metres. Their joints are the thin lines
// architecture gets instead of a heavy ink outline.
uniform vec2 panel = vec2(1.5, 1.0);
uniform float grime : hint_range(0.0, 1.0) = 0.5;
uniform float streaks : hint_range(0.0, 1.0) = 0.5;
// Diagonal hazard stripes, for the band along the foot of perimeter walls.
uniform float stripes : hint_range(0.0, 1.0) = 0.0;
uniform vec3 stripe_color : source_color = vec3(1.0, 0.42, 0.1);
// Building facades: floors of windows from this height up, some lit from inside. Zero for none.
// Starting near the ground makes the first floor a row of shopfronts.
uniform float windows_from = 0.0;
// How brightly lit windows glow: the city around the map stays dimmer than the map itself.
uniform float window_glow = 1.0;
// Buildings around the map thin out within this many metres of the camera, so it can pass behind
// them. Zero for the level's own walls, which ghost by line of sight instead.
uniform float camera_fade = 0.0;
instance uniform float ghost = 0.0;
// Each wall's top in world metres: the tone lifts toward it and streaks run down from it. Zero
// for pieces with no top of their own, like caps and plinths.
instance uniform float top = 0.0;
// The light in a building's windows, so each building on a street can have its own.
instance uniform vec3 window_light : source_color = vec3(1.0, 0.8, 0.62);

varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	float near = 0.0;
	if (camera_fade > 0.0) {
		near = 1.0 - smoothstep(camera_fade * 0.5, camera_fade, distance(world_position, CAMERA_POSITION_WORLD));
	}
	if (ghosted(FRAGCOORD.xy, max(ghost, near))) {
		discard;
	}
	bool upright = abs(world_normal.y) < 0.5;
	// A point's place on its face: across and up a wall, or across both ways on a top.
	float along = abs(world_normal.x) > abs(world_normal.z) ? world_position.z : world_position.x;
	vec2 face = upright ? vec2(along, world_position.y) : world_position.xz;
	vec2 panel_size = upright ? panel : vec2(CELL);
	vec2 panel_id = floor(face / panel_size);
	float panel_seed = hash(panel_id + (upright ? 0.0 : 91.0));

	vec3 color = base_color * mix(0.93, 1.07, panel_seed);
	float dirt = patches(face * vec2(1.3, 0.9) + panel_id * 3.7, 0.4 * grime) * mix(0.35, 1.0, panel_seed);
	color *= 1.0 - 0.3 * dirt;
	if (upright && top > 0.0) {
		float below_top = top - world_position.y;
		// Streaks run down from the cap and fade out; a few reach much further than the rest.
		float streak = value_noise(vec2(along * 7.0, world_position.y * 0.35));
		float reach = mix(0.7, 2.8, value_noise(vec2(along * 1.3, 3.0)));
		float run = smoothstep(0.45, 0.85, streak) * (1.0 - smoothstep(0.0, reach, below_top));
		color *= 1.0 - 0.38 * streaks * run;
		float t = clamp(world_position.y / top, 0.0, 1.0);
		color *= mix(0.72, 1.04, (floor(t * 3.0) + smoothstep(0.3, 0.7, fract(t * 3.0))) / 3.0);
		// The shadow of the cap, and the street's dirt splashed up the foot.
		color *= mix(1.0, 0.55, smoothstep(0.08, 0.0, below_top));
		color *= mix(0.68, 1.0, smoothstep(0.02, 0.4, world_position.y + 0.15 * value_noise(vec2(along * 3.0, 0.0))));
	}
	color *= 1.0 - 0.45 * max(joint(face.x, panel_size.x, 0.01), joint(face.y, panel_size.y, 0.008));

	if (stripes > 0.0) {
		float band = step(0.5, fract((along + world_position.y) / 0.5));
		float worn = patches(face * 2.2, 0.25);
		color = mix(color, stripe_color * mix(1.0, 0.7, dirt) * mix(1.0, 0.75, worn), band * stripes);
	}

	float roughness = 0.9;
	vec3 glow = vec3(0.0);
	if (upright && windows_from > 0.0 && world_position.y > windows_from) {
		vec2 bay = vec2(along / CELL, (world_position.y - windows_from) / FLOOR_HEIGHT);
		vec2 bay_id = floor(bay);
		vec2 in_bay = fract(bay);
		bool shopfront = bay_id.y < 0.5 && windows_from < 1.0;
		vec4 pane = shopfront ? vec4(0.06, 0.94, 0.05, 0.85) : vec4(0.2, 0.8, 0.3, 0.78);
		float glass = step(pane.x, in_bay.x) * step(in_bay.x, pane.y) * step(pane.z, in_bay.y) * step(in_bay.y, pane.w);
		float mullion = shopfront ? 1.0 : smoothstep(0.01, 0.025, abs(in_bay.x - 0.5));
		float lit = step(shopfront ? 0.3 : 0.62, hash(bay_id + 5.0));
		// Some lit windows have their blinds down: bands of light between the slats.
		float blinds = step(0.6, hash(bay_id + 13.0)) * step(0.5, fract(in_bay.y * 14.0));
		vec3 inside = window_light * mix(0.55, 1.2, hash(bay_id + 23.0)) * mix(1.0, 0.45, blinds);
		float fall_off = mix(1.0, 0.55, smoothstep(pane.z, pane.w, in_bay.y));
		color = mix(color, vec3(0.04, 0.05, 0.08), glass);
		glow = inside * glass * mullion * lit * fall_off * window_glow;
		roughness = mix(roughness, 0.08, glass);
	}

	float seen = fog_light(world_position);
	ALBEDO = color * seen;
	ROUGHNESS = roughness;
	EMISSION = glow * mix(0.5, 1.0, seen);
}
