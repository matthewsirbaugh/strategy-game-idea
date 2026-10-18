shader_type spatial;
// Glass with a lit room behind it, faked by tracing the view ray into a box in the piece's own
// space (interior mapping), so windows show depth without modelled interiors. The room has no side
// walls, so neighbouring bays show one continuous open lab. Hidden by the fog, it goes dark.
#include "res://art/shaders/fog.gdshaderinc"
#include "res://art/shaders/ghost.gdshaderinc"
#include "res://art/shaders/painted.gdshaderinc"

uniform float room_depth = 7.5;
uniform float floor_height = 0.05;
uniform float ceiling_height = 3.9;
uniform vec3 floor_color : source_color = vec3(0.62, 0.62, 0.6);
uniform vec3 wall_color : source_color = vec3(0.78, 0.78, 0.76);
uniform vec3 bench_color : source_color = vec3(0.86, 0.86, 0.85);
uniform vec3 light_color : source_color = vec3(1.0, 0.86, 0.68);
uniform float light_energy = 1.4;
uniform vec3 tint : source_color = vec3(0.82, 0.88, 0.9);
instance uniform float ghost : instance_index(2) = 0.0;
instance uniform bool scenery : instance_index(5) = false;
varying vec3 world_position;
varying vec3 world_normal;

const float STRIPS[3] = float[3](-1.2, -3.6, -6.0);

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

// Light falling on a point from the ceiling's strips, which run along the bay.
float strip_light(float z) {
	float light = 0.25;
	for (int i = 0; i < 3; i++) {
		float d = z - STRIPS[i];
		light += 0.75 * exp(-d * d * 0.6);
	}
	return light;
}

// Benches stand in rows across the room; true where (x, z) is under a bench top.
bool bench(vec2 xz) {
	bool in_row = (xz.y < -2.2 && xz.y > -3.0) || (xz.y < -4.6 && xz.y > -5.4);
	return in_row && fract(xz.x / 3.0) < 0.75;
}

void fragment() {
	if (ghosted(FRAGCOORD.xy, ghost)) {
		discard;
	}
	mat4 to_local = inverse(MODEL_MATRIX);
	vec3 eye = (to_local * vec4(CAMERA_POSITION_WORLD, 1.0)).xyz;
	vec3 start = (to_local * vec4(world_position, 1.0)).xyz;
	vec3 ray = normalize(start - eye);

	float t = 1e5;
	int surface = 0;  // 0 back wall, 1 floor, 2 ceiling
	if (ray.z < 0.0) {
		t = (-room_depth - start.z) / ray.z;
	}
	if (ray.y < 0.0) {
		float to_floor = (floor_height - start.y) / ray.y;
		if (to_floor > 0.0 && to_floor < t) {
			t = to_floor;
			surface = 1;
		}
	} else if (ray.y > 0.0) {
		float to_ceiling = (ceiling_height - start.y) / ray.y;
		if (to_ceiling > 0.0 && to_ceiling < t) {
			t = to_ceiling;
			surface = 2;
		}
	}
	vec3 hit = start + ray * t;
	vec3 room;
	if (surface == 1) {
		float tiles = max(joint(hit.x, 0.75, 0.01), joint(hit.z, 0.75, 0.01));
		room = floor_color * (1.0 - 0.25 * tiles) * strip_light(hit.z);
		if (bench(hit.xz + ray.xz * 0.2)) {
			room *= 0.4;  // the shadow under a bench
		}
	} else if (surface == 2) {
		room = wall_color * 0.35;
		for (int i = 0; i < 3; i++) {
			if (abs(hit.z - STRIPS[i]) < 0.12) {
				room = light_color * 3.0;
			}
		}
	} else {
		room = wall_color * strip_light(-room_depth + 1.0) * (hit.y < 1.0 ? 0.6 : 1.0);
	}
	if (ray.y < 0.0) {
		float to_bench = (0.9 - start.y) / ray.y;
		vec3 top = start + ray * to_bench;
		if (to_bench > 0.0 && to_bench < t && bench(top.xz)) {
			room = bench_color * strip_light(top.z) * 1.15;
		}
	}
	vec3 world_hit = (MODEL_MATRIX * vec4(hit, 1.0)).xyz;
	room *= light_color * light_energy * mix(0.55, 1.15, fbm(world_hit.xz * 0.12));

	float visibility = scenery ? fog_visibility(world_position) : 1.0;
	float facing = abs(dot(normalize(NORMAL), normalize(VIEW)));
	float fresnel = pow(1.0 - facing, 4.0);
	ALBEDO = vec3(0.015) * visibility;
	EMISSION = mix(fog_silhouette(world_normal), room * tint * (1.0 - 0.7 * fresnel), visibility);
	ROUGHNESS = mix(1.0, 0.04, visibility);
	SPECULAR = 0.5 * visibility;
}
