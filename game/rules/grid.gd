class_name Grid

const DIRECTIONS: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
# Cones are 90° wide: a tile is inside when it's within 45° of the facing.
const CONE_COS := 0.7071


static func neighbors(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for direction in DIRECTIONS:
		result.append(cell + direction)
	return result


# Walking distance on an open floor. Movement, sight, shots and the tether count this way.
static func distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


# Light pools and vision cones are round. The half tile keeps a radius-3 pool from losing its
# diagonals.
static func within(a: Vector2i, b: Vector2i, radius: float) -> bool:
	return Vector2(a - b).length_squared() <= (radius + 0.5) * (radius + 0.5)


static func in_cone(origin: Vector2i, facing: Vector2, cell: Vector2i) -> bool:
	var offset := Vector2(cell - origin)
	if offset == Vector2.ZERO or facing == Vector2.ZERO:
		return true
	return facing.normalized().dot(offset.normalized()) >= CONE_COS - 0.0001


# The tiles the straight line between two tile centers crosses, as offsets from its start and
# without either end. Two walls that only touch at a corner leave a gap it slips through. The
# tiles depend only on the offset between the ends, so each line is worked out once.
static var _lines := {}


static func line(offset: Vector2i) -> Array[Vector2i]:
	if _lines.has(offset):
		return _lines[offset]
	var cells: Array[Vector2i] = []
	var end := Vector2(offset)
	var steps := ceili(end.length() * 4.0)
	for i in range(1, steps):
		var point := Vector2(0.5, 0.5) + end * (float(i) / steps)
		var cell := Vector2i(floori(point.x), floori(point.y))
		if cell != Vector2i.ZERO and cell != offset and (cells.is_empty() or cells.back() != cell):
			cells.append(cell)
	_lines[offset] = cells
	return cells


# The tiles a line from `from` through `toward` crosses, in order, out to `radius`, ending before
# the first tile that blocks it.
static func ray(from: Vector2i, toward: Vector2i, radius: float, blocks: Callable) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if toward == from:
		return result
	var start := Vector2(from) + Vector2(0.5, 0.5)
	var direction := Vector2(toward - from).normalized()
	var travelled := 0.1
	while travelled <= radius + 0.5:
		var point := start + direction * travelled
		travelled += 0.1
		var cell := Vector2i(floori(point.x), floori(point.y))
		if cell == from or (not result.is_empty() and result.back() == cell):
			continue
		if not within(from, cell, radius) or blocks.call(cell):
			break
		result.append(cell)
	return result
