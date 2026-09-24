class_name GridView
extends Node3D

const TILE_HEIGHT := 0.2
const TILE_GAP := 0.06
const WALL_HEIGHT := 1.2
const EXTRACTION_Y := 0.005
const OVERLAY_Y := 0.012

const NODE_COLORS := {
	"access": Color(0.2, 0.85, 1.0),
	"camera": Color(1.0, 0.82, 0.3),
	"door": Color(0.85, 0.55, 0.2),
	"cache": Color(0.95, 0.3, 0.8),
}
const NODE_LABELS := {
	"access": "ACCESS",
	"camera": "CAMERA",
	"door": "DOOR",
	"cache": "DATA CACHE",
}
const EXTRACTION_COLOR := Color(0.3, 1.0, 0.5, 0.3)

var map: MapData
var _overlay_mesh := PlaneMesh.new()
var _overlays := {}
var _node_views := {}


func build(state: BattleState) -> void:
	map = state.map
	_overlay_mesh.size = Vector2(1.0 - TILE_GAP, 1.0 - TILE_GAP)
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(1.0 - TILE_GAP, TILE_HEIGHT, 1.0 - TILE_GAP)
	var wall_mesh := BoxMesh.new()
	wall_mesh.size = Vector3(1.0, WALL_HEIGHT, 1.0)
	var light := _material(Color(0.3, 0.33, 0.38))
	var dark := _material(Color(0.25, 0.28, 0.33))
	var wall := _material(Color(0.5, 0.53, 0.6))
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
		if NODE_COLORS.has(map.node_kind(id)):
			_build_node(id)


func set_overlay(layer: String, cells: Array, color: Color) -> void:
	clear_overlay(layer)
	var material := _material(color, true)
	var meshes: Array[MeshInstance3D] = []
	for cell in cells:
		meshes.append(_add_mesh(_overlay_mesh, material, cell_to_world(cell) + Vector3(0, OVERLAY_Y, 0)))
	_overlays[layer] = meshes


func clear_overlay(layer: String) -> void:
	for mesh in _overlays.get(layer, []):
		mesh.queue_free()
	_overlays.erase(layer)


func clear_overlays() -> void:
	for layer in _overlays.keys():
		clear_overlay(layer)


func cell_to_world(cell: Vector2i) -> Vector3:
	return Vector3(cell.x + 0.5, 0.0, cell.y + 0.5)


func world_to_cell(point: Vector3) -> Vector2i:
	return Vector2i(floori(point.x), floori(point.z))


func center() -> Vector3:
	return extent() / 2.0


func extent() -> Vector3:
	return Vector3(map.size.x, 0.0, map.size.y)


func _build_node(id: String) -> void:
	var kind := map.node_kind(id)
	var cell := map.node_cell(id)
	var root := Node3D.new()
	root.position = cell_to_world(cell)
	add_child(root)
	var color: Color = NODE_COLORS[kind]
	var material := _material(color)
	material.emission_enabled = true
	material.emission = color * 0.35
	match kind:
		"access":
			_add_box(root, Vector3(0.45, 0.8, 0.45), 0.4, material)
		"camera":
			_add_box(root, Vector3(0.08, 1.0, 0.08), 0.5, material)
			_add_box(root, Vector3(0.4, 0.25, 0.25), 1.05, material)
		"door":
			var spans_x := map.is_wall(cell + Vector2i(1, 0)) or map.is_wall(cell + Vector2i(-1, 0))
			_add_box(root, Vector3(1.0, 1.0, 0.2) if spans_x else Vector3(0.2, 1.0, 1.0), 0.5, material)
		"cache":
			_add_box(root, Vector3(0.7, 1.3, 0.7), 0.65, material)
	var label := UnitView.make_label(32, 1.55)
	label.text = NODE_LABELS[kind]
	label.modulate = color
	root.add_child(label)
	_node_views[id] = root


func _add_box(parent: Node3D, size: Vector3, center_y: float, material: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position.y = center_y
	parent.add_child(instance)


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
