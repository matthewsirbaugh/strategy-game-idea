class_name Grid

const DIRECTIONS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]


static func neighbors(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for direction in DIRECTIONS:
		result.append(cell + direction)
	return result


static func distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


# Walks the straight line between tile centers. Two walls that only touch at a corner don't
# block it.
static func line_clear(a: Vector2i, b: Vector2i, blocks: Callable) -> bool:
	var start := Vector2(a) + Vector2(0.5, 0.5)
	var end := Vector2(b) + Vector2(0.5, 0.5)
	var steps := ceili(start.distance_to(end) * 4.0)
	for i in range(1, steps):
		var point := start.lerp(end, float(i) / steps)
		var cell := Vector2i(floori(point.x), floori(point.y))
		if cell != a and cell != b and blocks.call(cell):
			return false
	return true
