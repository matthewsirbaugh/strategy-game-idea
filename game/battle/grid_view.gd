class_name GridView
extends Node3D
## The grid as the player reads it: where tiles are in the world, the colored overlays that show
## choices, and the fog, drawn as light that comes on where the team can see.

# One tile is this many metres across, so people and props sit at real scale.
const CELL := 1.5
const TILE_GAP := 0.06
const EXTRACTION_Y := 0.005
const ACCESS_Y := 0.007
const OVERLAY_Y := 0.012
const PROBE_Y := 2.3
const LIGHT_OFF_SECONDS := 0.35
# A tile comes on like a fluorescent tube: how lit it is (0 to 1) over its first moments in view.
const FLICKER := [[0.06, 0.9], [0.11, 0.0], [0.17, 0.75], [0.22, 0.0], [0.3, 1.0]]

const NODE_COLORS := {
	"access": Color(0.2, 0.85, 1.0),
	"camera": Color(1.0, 0.82, 0.3),
	"door": Color(0.85, 0.55, 0.2),
	"turret": Color(0.95, 0.55, 0.2),
	"cache": Color(0.95, 0.3, 0.8),
}
const OVERLAY := preload("res://art/shaders/overlay.gdshader")
const EXTRACTION_COLOR := Color(0.3, 1.0, 0.5, 0.3)
const ACCESS_ZONE_COLOR := Color(0.2, 0.85, 1.0, 0.12)
# The access zones' outer edge, drawn above the move tiles so both stay readable where they overlap.
const ACCESS_EDGE_COLOR := Color(0.45, 1.0, 0.95)
const ACCESS_EDGE_GLOW := 3.0
const ACCESS_EDGE_WIDTH := 0.18
const ACCESS_EDGE_Y := 0.02
const SIDES := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]

var map: MapData
var _overlay_mesh := PlaneMesh.new()
var _overlays := {}
var _zone_range := -1
# The fog map covers the map plus a one-tile ring, so the building's outer wall darkens too.
var _light_image: Image
var _light_texture: ImageTexture
var _lit := {}
var _brightness := {}
var _lit_since := {}
var _changing := {}


func build(state: BattleState) -> void:
	map = state.map
	_overlay_mesh.size = Vector2(CELL - TILE_GAP, CELL - TILE_GAP)
	var extraction := _overlay_material(EXTRACTION_COLOR)
	for cell in map.extraction():
		_add_mesh(_overlay_mesh, extraction, cell_to_world(cell) + Vector3(0, EXTRACTION_Y, 0))
	_light_image = Image.create(map.size.x + 2, map.size.y + 2, false, Image.FORMAT_R8)
	_light_image.fill(Color.BLACK)
	_light_texture = ImageTexture.create_from_image(_light_image)
	RenderingServer.global_shader_parameter_set("fog_map", _light_texture)
	RenderingServer.global_shader_parameter_set("fog_bounds", Vector4(-CELL, -CELL, (map.size.x + 2) * CELL, (map.size.y + 2) * CELL))
	set_process(false)


func _exit_tree() -> void:
	RenderingServer.global_shader_parameter_set("fog_bounds", Vector4.ZERO)


# Tiles the team can see are lit, and so is any wall beside one; everything else goes dark.
func set_visible_cells(visible: Dictionary) -> void:
	var lit := {}
	for cell in visible:
		lit[cell] = true
		for direction in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
			if not map.in_bounds(cell + direction) or map.is_wall(cell + direction):
				lit[cell + direction] = true
	for cell in lit:
		if not _lit.has(cell):
			_lit_since[cell] = 0.0
			_changing[cell] = true
	for cell in _lit:
		if not lit.has(cell):
			_lit_since.erase(cell)
			_changing[cell] = true
	_lit = lit
	set_process(not _changing.is_empty())


func _process(delta: float) -> void:
	if not _light_image:
		return
	var changed := false
	for cell: Vector2i in _changing.keys():
		var current: float = _brightness.get(cell, 0.0)
		var target := _target_brightness(cell, delta)
		if not is_equal_approx(current, target):
			_brightness[cell] = target
			_light_image.set_pixel(cell.x + 1, cell.y + 1, Color(target, target, target))
			changed = true
		if not _lit_since.has(cell) and is_equal_approx(target, 1.0 if _lit.has(cell) else 0.0):
			_changing.erase(cell)
	if changed:
		_light_texture.update(_light_image)
	set_process(not _changing.is_empty())


func _target_brightness(cell: Vector2i, delta: float) -> float:
	if not _lit.has(cell):
		_lit_since.erase(cell)
		return move_toward(_brightness.get(cell, 0.0), 0.0, delta / LIGHT_OFF_SECONDS)
	if not _lit_since.has(cell):
		return 1.0
	_lit_since[cell] += delta
	for step in FLICKER:
		if _lit_since[cell] < step[0]:
			return step[1]
	_lit_since.erase(cell)
	return 1.0


# A dropped probe: a small glowing marker floating over the node it watches from.
func add_probe(cell: Vector2i) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 0.14
	mesh.height = 0.28
	var material := _material(Color(0.45, 1.0, 0.95))
	material.emission_enabled = true
	material.emission = Color(0.45, 1.0, 0.95)
	_add_mesh(mesh, material, cell_to_world(cell) + Vector3(0, PROBE_Y, 0))


# Where an Operator with this tether range can stand to plug its AI in.
func show_access_zones(tether_range: int) -> void:
	if tether_range == _zone_range:
		return
	_zone_range = tether_range
	var zone := {}
	for id in map.node_ids():
		if map.node_kind(id) != "access":
			continue
		var center_cell := map.node_cell(id)
		for x in range(center_cell.x - tether_range, center_cell.x + tether_range + 1):
			for y in range(center_cell.y - tether_range, center_cell.y + tether_range + 1):
				var cell := Vector2i(x, y)
				if map.in_bounds(cell) and not map.is_wall(cell) and Grid.distance(cell, center_cell) <= tether_range:
					zone[cell] = true
	set_overlay("access", zone.keys(), ACCESS_ZONE_COLOR, ACCESS_Y)
	_outline("access_edge", zone)


# Draws the border of a set of cells: a strip along every side that faces a cell outside the set,
# inset so it reads as the inside edge of the zone. Opaque, so it covers the overlays beneath it.
func _outline(layer: String, cells: Dictionary) -> void:
	clear_overlay(layer)
	var strip := PlaneMesh.new()
	strip.size = Vector2(CELL, ACCESS_EDGE_WIDTH)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color.BLACK
	material.emission_enabled = true
	material.emission = ACCESS_EDGE_COLOR
	material.emission_energy_multiplier = ACCESS_EDGE_GLOW
	var meshes: Array[MeshInstance3D] = []
	for cell: Vector2i in cells:
		for side: Vector2i in SIDES:
			if cells.has(cell + side):
				continue
			var offset := Vector3(side.x, 0, side.y) * (CELL - ACCESS_EDGE_WIDTH) / 2.0
			var edge := _add_mesh(strip, material, cell_to_world(cell) + offset + Vector3(0, ACCESS_EDGE_Y, 0))
			if side.x != 0:
				edge.rotation.y = PI / 2.0
			meshes.append(edge)
	_overlays[layer] = meshes


func node_position(id: String, height := 0.0) -> Vector3:
	return cell_to_world(map.node_cell(id)) + Vector3(0, height, 0)


func set_overlay(layer: String, cells: Array, color: Color, height := OVERLAY_Y) -> void:
	clear_overlay(layer)
	var material := _overlay_material(color)
	var meshes: Array[MeshInstance3D] = []
	for cell in cells:
		meshes.append(_add_mesh(_overlay_mesh, material, cell_to_world(cell) + Vector3(0, height, 0)))
	_overlays[layer] = meshes


func clear_overlay(layer: String) -> void:
	for mesh in _overlays.get(layer, []):
		mesh.queue_free()
	_overlays.erase(layer)


func cell_to_world(cell: Vector2i) -> Vector3:
	return Vector3((cell.x + 0.5) * CELL, 0.0, (cell.y + 0.5) * CELL)


func world_to_cell(point: Vector3) -> Vector2i:
	return Vector2i(floori(point.x / CELL), floori(point.z / CELL))


func center() -> Vector3:
	return extent() / 2.0


func extent() -> Vector3:
	return Vector3(map.size.x, 0.0, map.size.y) * CELL


static func make_beam(thickness: float, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(thickness, thickness, 1.0)
	var beam := MeshInstance3D.new()
	beam.mesh = mesh
	beam.material_override = _material(color)
	return beam


static func place_beam(beam: MeshInstance3D, from: Vector3, to: Vector3) -> void:
	var length := from.distance_to(to)
	beam.visible = length > 0.01
	if beam.visible:
		var basis := Basis.looking_at(to - from, Vector3.UP) * Basis.from_scale(Vector3(1, 1, length))
		beam.transform = Transform3D(basis, (from + to) / 2.0)


func _add_mesh(mesh: Mesh, material: Material, at: Vector3) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = at
	add_child(instance)
	return instance


static func _overlay_material(color: Color) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = OVERLAY
	material.set_shader_parameter("color", color)
	return material


# Beams and markers are flat and unlit so they read the same in light and dark.
static func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material
