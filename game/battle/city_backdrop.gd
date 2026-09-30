class_name CityBackdrop
extends Node3D
## The city around the map, none of it part of the battle: the street running on past the map
## with its far lane, curb and pavement; low buildings with lit shopfronts across the road and on
## every other side; and a skyline beyond, in the haze. The same seed builds the same city every
## time. Buildings near the camera thin out so it can pass behind them.

const ROAD_LENGTH := 300.0
const CURB := Vector2(0.3, 0.15)
const PAVEMENT := 4.0
# How far the buildings stand back: across the road from the far pavement, which keeps them behind
# a camera looking over the street, and elsewhere from the map's edge.
const SETBACK := 6.0
# The row across the road runs this far past each end of the map, as far as the camera sees along it.
const ACROSS_OVERRUN := 45.0
const SKYLINE_TOWERS := 44
const SKYLINE_DISTANCE := Vector2(95.0, 170.0)
const SHOP_COLORS := [Color(1.0, 0.8, 0.58), Color(1.0, 0.42, 0.22), Color(0.3, 0.88, 0.95), Color(1.0, 0.35, 0.62), Color(0.92, 0.94, 1.0)]
# Most windows glow warm or cool white; some take a shop's color.
const WINDOW_LIGHTS := [Color(1.0, 0.8, 0.62), Color(1.0, 0.72, 0.5), Color(0.75, 0.8, 0.95), Color(1.0, 0.5, 0.32), Color(0.4, 0.8, 0.9)]
const SHOP_WORDS := ["24H", "RAMEN", "PAWN", "CLINIC", "NOODLES", "REPAIR", "KARAOKE", "BAR", "HOTEL"]
const SEED := 1207
const EDGES := {"north": Vector3.FORWARD, "south": Vector3.BACK, "west": Vector3.LEFT, "east": Vector3.RIGHT}

var _rng := RandomNumberGenerator.new()
var _signs: Signs
# Ground no building may stand on: the road and its pavements.
var _keep_clear: Array[AABB] = []


func build(map: MapData, grid: GridView, signs: Signs) -> void:
	_rng.seed = SEED
	_signs = signs
	var street := _street_edge(map)
	# The road first, so the buildings know to leave it clear.
	if not street.is_empty():
		_build_road(grid, EDGES[street.edge], street.width)
	for edge: String in EDGES:
		var outward: Vector3 = EDGES[edge]
		var middle := _edge_middle(grid, outward)
		var length := absf(_along(outward).dot(grid.extent()))
		if edge == street.get("edge", ""):
			_build_row(middle + outward * (street.width + CURB.x + PAVEMENT + SETBACK), outward, length + 2.0 * ACROSS_OVERRUN, Vector2(3.5, 8.0))
		else:
			_build_row(middle + outward * SETBACK, outward, length + 2.0 * SETBACK, Vector2(5.0, 14.0))
	_build_skyline(grid.center())


static func _along(outward: Vector3) -> Vector3:
	return Vector3(absf(outward.z), 0.0, absf(outward.x))


static func _edge_middle(grid: GridView, outward: Vector3) -> Vector3:
	return grid.center() + outward * absf(outward.dot(grid.extent())) / 2.0


# The side of the map its street tiles run along, and how deep the street is, if they fill whole
# rows or columns along one edge.
func _street_edge(map: MapData) -> Dictionary:
	var rows := {}
	var columns := {}
	for y in map.size.y:
		for x in map.size.x:
			if map.is_street(Vector2i(x, y)):
				rows[y] = rows.get(y, 0) + 1
				columns[x] = columns.get(x, 0) + 1
	var full_rows := rows.keys().filter(func(y: int) -> bool: return rows[y] == map.size.x)
	var full_columns := columns.keys().filter(func(x: int) -> bool: return columns[x] == map.size.y)
	if full_rows.has(map.size.y - 1):
		return {"edge": "south", "width": full_rows.size() * GridView.CELL}
	if full_rows.has(0):
		return {"edge": "north", "width": full_rows.size() * GridView.CELL}
	if full_columns.has(map.size.x - 1):
		return {"edge": "east", "width": full_columns.size() * GridView.CELL}
	if full_columns.has(0):
		return {"edge": "west", "width": full_columns.size() * GridView.CELL}
	return {}


# The street's far lane beyond the map's edge, so the edge becomes the road's centre line, then
# the far curb and pavement. Past the map's ends the near side gets a curb and pavement too.
func _build_road(grid: GridView, outward: Vector3, width: float) -> void:
	var middle := _edge_middle(grid, outward)
	var along := _along(outward)
	var across := outward.abs()
	var to_end := along * ROAD_LENGTH / 2.0
	var reach := width + CURB.x + PAVEMENT
	_keep_clear.append(AABB(middle - to_end - across * reach, to_end * 2.0 + across * reach * 2.0 + Vector3.UP * 100.0))
	_add_box(to_end * 2.0 + across * width * 2.0 + Vector3(0.0, 0.02, 0.0), "asphalt", middle + Vector3(0.0, -0.015, 0.0))
	_signs.paint_line(middle - to_end, middle + to_end, 0.14, 3.0)
	var far_line := middle + outward * (width - 0.35)
	_signs.paint_line(far_line - to_end, far_line + to_end, 0.12)
	_add_pavement(middle + outward * width, along, outward, ROAD_LENGTH)
	var map_length := absf(along.dot(grid.extent()))
	var past_end := (ROAD_LENGTH - map_length) / 2.0
	for side: float in [-1.0, 1.0]:
		_add_pavement(middle - outward * width + along * side * (map_length + past_end) / 2.0, along, -outward, past_end)


# A curb along the road's edge, and the pavement behind it, both raised to the curb's height.
func _add_pavement(edge: Vector3, along: Vector3, outward: Vector3, length: float) -> void:
	var run := along * length + Vector3(0.0, CURB.y, 0.0)
	var raised := edge + Vector3(0.0, CURB.y / 2.0 - 0.01, 0.0)
	_add_box(run + outward.abs() * CURB.x, "cap", raised + outward * CURB.x / 2.0)
	_add_box(run + outward.abs() * PAVEMENT, "sidewalk", raised + outward * (CURB.x + PAVEMENT / 2.0))


# Buildings shoulder to shoulder along a line, fronts on the line and facing back toward the map,
# leaving the road clear.
func _build_row(line_middle: Vector3, outward: Vector3, length: float, heights: Vector2) -> void:
	var along := _along(outward)
	var at := -length / 2.0
	while at < length / 2.0:
		var width := _rng.randf_range(6.0, 14.0)
		var depth := _rng.randf_range(8.0, 14.0)
		var height := _rng.randf_range(heights.x, heights.y)
		var front := line_middle + along * (at + width / 2.0)
		var size := along * width + outward.abs() * depth + Vector3(0.0, height, 0.0)
		var middle := front + outward * depth / 2.0 + Vector3(0.0, height / 2.0 - 0.02, 0.0)
		at += width + _rng.randf_range(0.0, 1.6)
		if _keep_clear.any(func(clear: AABB) -> bool: return clear.intersects(AABB(middle - size / 2.0, size))):
			continue
		var block := _add_box(size, "city", middle)
		block.set_instance_shader_parameter("top", height)
		block.set_instance_shader_parameter("window_light", WINDOW_LIGHTS[_rng.randi() % WINDOW_LIGHTS.size()])
		_dress_rooftop(front + outward * depth / 2.0 + Vector3(0.0, height, 0.0), width, depth, along)
		_dress_front(front, along, -outward, width)


# Air conditioners and tanks, so the roofs have a skyline of their own from above.
func _dress_rooftop(roof: Vector3, width: float, depth: float, along: Vector3) -> void:
	var across := Vector3(along.z, 0.0, along.x)
	for i in _rng.randi_range(1, 4):
		var size := Vector3(_rng.randf_range(0.8, 2.4), _rng.randf_range(0.6, 1.8), _rng.randf_range(0.8, 2.4))
		var spot := along * _rng.randf_range(-0.35, 0.35) * width + across * _rng.randf_range(-0.35, 0.35) * depth
		_add_box(size, "metal", roof + spot + Vector3(0.0, size.y / 2.0, 0.0))


# A light spilling from some shopfronts onto the pavement, and a neon word over some.
func _dress_front(front: Vector3, along: Vector3, facing: Vector3, width: float) -> void:
	var yaw := atan2(facing.x, facing.z)
	if _rng.randf() < 0.35:
		var light := OmniLight3D.new()
		light.light_color = WINDOW_LIGHTS[_rng.randi() % WINDOW_LIGHTS.size()]
		light.light_energy = 1.2
		light.omni_range = 6.0
		light.position = front + facing * 1.2 + Vector3(0.0, 2.2, 0.0)
		add_child(light)
	if _rng.randf() < 0.45:
		var word: String = SHOP_WORDS[_rng.randi() % SHOP_WORDS.size()]
		var color: Color = SHOP_COLORS[_rng.randi() % SHOP_COLORS.size()]
		var at := front + facing * 0.05 + along * _rng.randf_range(-0.2, 0.2) * width + Vector3(0.0, 3.2, 0.0)
		_signs.neon(word, color, at, yaw, Vector2(0.45 * word.length() + 0.4, 0.8))


# Towers far off in a ring, with lit windows, and on some a neon edge or a billboard on the face
# toward the map, and a red light on the tallest. They stay square to the grid, like the
# world-space patterns on their walls.
func _build_skyline(center: Vector3) -> void:
	for i in SKYLINE_TOWERS:
		var angle := TAU * (i + _rng.randf_range(-0.3, 0.3)) / SKYLINE_TOWERS
		var distance := _rng.randf_range(SKYLINE_DISTANCE.x, SKYLINE_DISTANCE.y)
		var size := Vector3(_rng.randf_range(12.0, 30.0), _rng.randf_range(28.0, 95.0), _rng.randf_range(12.0, 30.0))
		var foot := center + Vector3(cos(angle), 0.0, sin(angle)) * distance
		var tower := _add_box(size, "skyline", foot + Vector3(0.0, size.y / 2.0, 0.0))
		tower.set_instance_shader_parameter("top", size.y)
		var toward := center - foot
		var front := Vector3(signf(toward.x), 0.0, 0.0) if absf(toward.x) > absf(toward.z) else Vector3(0.0, 0.0, signf(toward.z))
		var yaw := atan2(front.x, front.z)
		var color: Color = SHOP_COLORS[_rng.randi() % SHOP_COLORS.size()]
		if _rng.randf() < 0.35:
			var corner := Vector3(signf(toward.x) * size.x, size.y, signf(toward.z) * size.z) / 2.0
			_add_glow(Vector3(0.3, size.y * 0.9, 0.3), color, foot + corner, 0.0)
		if _rng.randf() < 0.3:
			var face := foot + front * (absf(front.dot(size)) / 2.0 + 0.1) + Vector3(0.0, size.y * _rng.randf_range(0.45, 0.75), 0.0)
			_add_glow(Vector3(absf(_along(front).dot(size)) * 0.5, size.y * 0.18, 0.1), color, face, yaw)
		if size.y > 70.0:
			_add_glow(Vector3(0.6, 0.6, 0.6), Color(1.0, 0.15, 0.1), foot + Vector3(0.0, size.y + 0.3, 0.0), 0.0)


func _glow_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color * 0.3
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.1
	return material


func _add_glow(size: Vector3, color: Color, at: Vector3, yaw: float) -> void:
	var box := BoxMesh.new()
	box.size = size
	var glow := MeshInstance3D.new()
	glow.mesh = box
	glow.material_override = _glow_material(color)
	glow.position = at
	glow.rotation.y = yaw
	add_child(glow)


func _add_box(size: Vector3, surface: String, at: Vector3) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = box
	instance.material_override = Surfaces.named(surface)
	instance.position = at
	add_child(instance)
	return instance
