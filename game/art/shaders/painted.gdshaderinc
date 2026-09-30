// Shared by the painted surfaces: noise, joints and cracks, all laid out in world metres so a
// pattern runs on across tiles and never stretches when a wall is cut down.
const float CELL = 1.5;

float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm(vec2 p) {
	return value_noise(p) * 0.55 + value_noise(p * 2.03 + 17.0) * 0.3 + value_noise(p * 4.1 + 41.0) * 0.15;
}

// Soft-edged patches covering about `coverage` of the surface, the way a painter blocks in grime:
// shapes with an edge, not speckle.
float patches(vec2 p, float coverage) {
	float n = fbm(p);
	return smoothstep(1.0 - coverage - 0.05, 1.0 - coverage + 0.05, n);
}

// 1 on the joints of a grid with this period, antialiased so a joint stays about a pixel wide far off.
float joint(float c, float period, float width) {
	float d = abs(fract(c / period + 0.5) - 0.5) * period;
	return 1.0 - smoothstep(width, width + fwidth(c) * 1.5, d);
}

// How far a point is from the nearest border between the cells of a jittered grid: near 0 along
// the borders, which read as cracks in pavement.
float cell_border(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float nearest = 8.0;
	float second = 8.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 o = vec2(float(x), float(y));
			vec2 d = o + vec2(hash(i + o), hash(i + o + 19.1)) - f;
			float dd = dot(d, d);
			if (dd < nearest) {
				second = nearest;
				nearest = dd;
			} else if (dd < second) {
				second = dd;
			}
		}
	}
	return sqrt(second) - sqrt(nearest);
}
