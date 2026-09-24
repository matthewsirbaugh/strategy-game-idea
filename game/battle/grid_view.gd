class_name GridView
extends Node3D

const TILE_HEIGHT := 0.2
const TILE_GAP := 0.06
const WALL_HEIGHT := 1.2
const EXTRACTION_Y := 0.005
const ACCESS_Y := 0.007
const FOG_Y := 0.009
const OVERLAY_Y := 0.012

const NODE_COLORS := {
	"access": Color(0.2, 0.85, 1.0),
	"camera": Color(1.0, 0.82, 0.3),
	"door": Color(0.85, 0.55, 0.2),
	"turret": Color(0.95, 0.55, 0.2),
	"cache": Color(0.95, 0.3, 0.8),
}
const BREACHED_COLOR := Color(0.35, 1.0, 0.6)
const EXTRACTION_COLOR := Color(0.3, 1.0, 0.5, 0.3)
const ACCESS_ZONE_COLOR := Color(0.2, 0.85, 1.0, 0.12)

var map: MapData
var _overlay_mesh := PlaneMesh.new()
var _overlays := {}
var _nodes := {}


func build(state: BattleState, tether_range: int) -> void:
	map = state.map
	_overlay_mesh.size = Vector2(1.0 - TILE_GAP, 1.0 - TILE_GAP)
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(1.0 - TILE_GAP, TILE_HEIGHT, 1.0 - TILE_GAP)
	var wall_mesh := BoxMesh.new()
	wall_mesh.size = Vector3(1.0, WALL_HEIGHT, 1.0)
	var light := _material(Color(0.38, 0.41, 0.47))
	var dark := _material(Color(0.33, 0.36, 0.42))
	var wall := _material(Color(0.56, 0.59, 0.66))
	for y in map.size.y:
		for x in map.size.x:
			var cell := Vector2i(x, y)
			if map.is_wall(cell):
				_add_mesh(wall_mesh, wall, cell_to_world(cell) + Vector3(0, WALL_HEIGHT / 2.0 - TILE_HEIGHT, 0))
			else:
				var tile := light if (x + y) % 2 == 0 else dark
				_add_mesh(floor_mesh, tile, cell_to_world(cell) + Vector3(0, -TILE_HEIGHT / 2.0, 0))
	var extraction := _material(EXTRACTION_COLOR, true)
	for cell in map.extraction():
		_add_mesh(_overlay_mesh, extraction, cell_to_world(cell) + Vector3(0, EXTRACTION_Y, 0))
	for id in map.node_ids():
		_build_node(id)
	_build_access_zones(tether_range)
	update_nodes(state)


# The physical side of a breach: a door opens, a hacked camera or cache turns the player's color.
func update_nodes(state: BattleState) -> void:
	for id in _nodes:
		var part: Dictionary = _nodes[id]
		if state.breached.has(id):
			var material: StandardMaterial3D = part["material"]
			material.albedo_color = BREACHED_COLOR
			material.emission = BREACHED_COLOR * 0.35
		if map.node_kind(id) == "door":
			part["shape"].visible = not state.is_door_open(id)


func node_position(id: String, height := 0.0) -> Vector3:
	return cell_to_world(map.node_cell(id)) + Vector3(0, height, 0)


func set_overlay(layer: String, cells: Array, color: Color, height := OVERLAY_Y) -> void:
	clear_overlay(layer)
	var material := _material(color, true)
	var meshes: Array[MeshInstance3D] = []
	for cell in cells:
		meshes.append(_add_mesh(_overlay_mesh, material, cell_to_world(cell) + Vector3(0, height, 0)))
	_overlays[layer] = meshes


func clear_overlay(layer: String) -> void:
	for mesh in _overlays.get(layer, []):
		mesh.queue_free()
	_overlays.erase(layer)


func cell_to_world(cell: Vector2i) -> Vector3:
	return Vector3(cell.x + 0.5, 0.0, cell.y + 0.5)


func world_to_cell(point: Vector3) -> Vector2i:
	return Vector2i(floori(point.x), floori(point.z))


func center() -> Vector3:
	return extent() / 2.0


func extent() -> Vector3:
	return Vector3(map.size.x, 0.0, map.size.y)


static func make_beam(thickness: float, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(thickness, thickness, 1.0)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = color
	var beam := MeshInstance3D.new()
	beam.mesh = mesh
	beam.material_override = material
	return beam


static func place_beam(beam: MeshInstance3D, from: Vector3, to: Vector3) -> void:
	var length := from.distance_to(to)
	beam.visible = length > 0.01
	if beam.visible:
		var basis := Basis.looking_at(to - from, Vector3.UP) * Basis.from_scale(Vector3(1, 1, length))
		beam.transform = Transform3D(basis, (from + to) / 2.0)


func _build_node(id: String) -> void:
	var kind := map.node_kind(id)
	if kind == "turret":
		return
	var cell := map.node_cell(id)
	var root := Node3D.new()
	root.position = cell_to_world(cell)
	add_child(root)
	var color: Color = NODE_COLORS[kind]
	var material := _material(color)
	material.emission_enabled = true
	material.emission = color * 0.35
	var shape: MeshInstance3D = null
	match kind:
		"access":
			shape = _add_box(root, Vector3(0.45, 0.8, 0.45), 0.4, material)
		"camera":
			_add_box(root, Vector3(0.08, 1.0, 0.08), 0.5, material)
			shape = _add_box(root, Vector3(0.4, 0.25, 0.25), 1.05, material)
		"door":
			var spans_x := map.is_wall(cell + Vector2i(1, 0)) or map.is_wall(cell + Vector2i(-1, 0))
			shape = _add_box(root, Vector3(1.0, 1.0, 0.2) if spans_x else Vector3(0.2, 1.0, 1.0), 0.5, material)
		"cache":
			shape = _add_box(root, Vector3(0.7, 1.3, 0.7), 0.65, material)
	_nodes[id] = {"material": material, "shape": shape}


func _build_access_zones(tether_range: int) -> void:
	var zone: Array[Vector2i] = []
	for id in map.node_ids():
		if map.node_kind(id) != "access":
			continue
		var center_cell := map.node_cell(id)
		for x in range(center_cell.x - tether_range, center_cell.x + tether_range + 1):
			for y in range(center_cell.y - tether_range, center_cell.y + tether_range + 1):
				var cell := Vector2i(x, y)
				if map.in_bounds(cell) and not map.is_wall(cell) and Grid.distance(cell, center_cell) <= tether_range and not zone.has(cell):
					zone.append(cell)
	set_overlay("access", zone, ACCESS_ZONE_COLOR, ACCESS_Y)


func _add_box(parent: Node3D, size: Vector3, center_y: float, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position.y = center_y
	parent.add_child(instance)
	return instance


func _add_mesh(mesh: Mesh, material: Material, at: Vector3) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = at
	add_child(instance)
	return instance


func _material(color: Color, overlay := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if overlay:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material
