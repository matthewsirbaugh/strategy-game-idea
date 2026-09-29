// Ghosting: a wall or prop in the way of the camera is thinned out with a fixed 4×4 dot pattern
// ("screen-door" transparency) instead of blended, so depth and outlines stay right.
// ghost runs 0 (solid) to 1 (as thin as it gets); even then a quarter of it is left, so the
// player still sees where it is.
const float GHOST_KEEP = 0.25;

bool ghosted(vec2 frag_coord, float ghost) {
	if (ghost <= 0.0) {
		return false;
	}
	const float bayer[16] = float[16](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);
	ivec2 p = ivec2(frag_coord) % 4;
	return (bayer[p.y * 4 + p.x] + 0.5) / 16.0 < ghost * (1.0 - GHOST_KEEP);
}
