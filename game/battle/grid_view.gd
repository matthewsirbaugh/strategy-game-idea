class_name GridView
extends Node3D

const TILE_HEIGHT := 0.2
const TILE_GAP := 0.06
const WALL_HEIGHT := 1.2
const EXTRACTION_Y := 0.005
const ACCESS_Y := 0.007
const FOG_Y := 0.009
const OVERLAY_Y := 0.012
const FLOOR_TEXTURE := preload("res://art/textures/corporate_floor.png")
const WALL_TEXTURE := preload("res://art/textures/corporate_wall.png")
const SHELL_TEXTURE := preload("res://art/textures/perimeter_wall.png")
const YARD_TEXTURE := preload("res://art/textures/asphalt.png")
const APRON_TEXTURE := preload("res://art/textures/concrete_paving.png")
const PROP_PATH := "res://art/props/%s/%s.glb"
# Heights in metres, bigger than life where a prop has to read from the battle camera.
const PROP_HEIGHTS := {"access_point": 1.0, "security_camera": 0.55, "server_rack": 2.0, "vault_door": 1.6,
	"loading_dock": 2.2, "delivery_van": 2.6, "shipping_crates": 1.6, "floodlight_pole": 5.0, "guard_booth": 2.8}
# These hang on a wall face; any other prop placed on a wall tile stands in for the wall.
const MOUNTED := ["vault_door", "loading_dock", "security_door", "access_point", "security_camera"]
const NEON := Color(1.0, 0.15, 0.6)
const APRON_WIDTH := 2.0
const YARD_SIZE := 60.0
const FACINGS := {"south": 0.0, "east": PI / 2.0, "north": PI, "west": -PI / 2.0}
const CAMERA_MOUNT_Y := 0.6
const CAMERA_POLE_HEIGHT := 1.3

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
var _zone_range := -1


func build(state: BattleState) -> void:
	map = state.map
	_overlay_mesh.size = Vector2(1.0 - TILE_GAP, 1.0 - TILE_GAP)
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(1.0 - TILE_GAP, TILE_HEIGHT, 1.0 - TILE_GAP)
	var wall_mesh := BoxMesh.new()
	wall_mesh.size = Vector3(1.0, WALL_HEIGHT, 1.0)
	var light := _textured(FLOOR_TEXTURE, Color.WHITE)
	var dark := _textured(FLOOR_TEXTURE, Color(0.85, 0.85, 0.85))
	var wall := _textured(WALL_TEXTURE, Color.WHITE, 0.5)
	var filled := _filled_cells()
	for y in map.size.y:
		for x in map.size.x:
			var cell := Vector2i(x, y)
			if filled.has(cell):
				continue
			if map.is_wall(cell):
				_add_wall(cell, wall_mesh, wall)
			else:
				var tile := light if (x + y) % 2 == 0 else dark
				_add_mesh(floor_mesh, tile, cell_to_world(cell) + Vector3(0, -TILE_HEIGHT / 2.0, 0))
	var extraction := _material(EXTRACTION_COLOR, true)
	for cell in map.extraction():
		_add_mesh(_overlay_mesh, extraction, cell_to_world(cell) + Vector3(0, EXTRACTION_Y, 0))
	for id in map.node_ids():
		_build_node(id)
	_build_shell(wall_mesh)
	for line in map.dressing:
		_build_dressing(line)
	update_nodes(state)


# The physical side of a breach: a door opens, a hacked camera or cache turns the player's color.
func update_nodes(state: BattleState) -> void:
	for id in _nodes:
		var part: Dictionary = _nodes[id]
		if state.breached.has(id):
			part["model"].tint = BREACHED_COLOR
		if map.node_kind(id) == "door":
			part["model"].visible = not state.is_door_open(id)


# A dropped probe: a small glowing marker floating over the node it watches from.
func add_probe(cell: Vector2i) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 0.14
	mesh.height = 0.28
	var material := _material(Color(0.45, 1.0, 0.95))
	material.emission_enabled = true
	material.emission = Color(0.45, 1.0, 0.95)
	_add_mesh(mesh, material, cell_to_world(cell) + Vector3(0, 1.55, 0))


# Where an Operator with this tether range can stand to plug its AI in.
func show_access_zones(tether_range: int) -> void:
	if tether_range == _zone_range:
		return
	_zone_range = tether_range
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
	var at := cell_to_world(cell)
	var wall := _wall_beside(cell)
	var model: ToonModel
	match kind:
		"access":
			model = _add_prop("access_point", at, 0.0, PROP_HEIGHTS["access_point"])
		"camera":
			if wall != Vector2i.ZERO:
				model = _mount_on_wall("security_camera", at + Vector3(wall.x, 0, wall.y) * 0.5 + Vector3(0, CAMERA_MOUNT_Y, 0), -wall)
			else:
				_add_pole(at, CAMERA_POLE_HEIGHT)
				model = _add_prop("security_camera", at + Vector3(0, CAMERA_POLE_HEIGHT, 0), _yaw_toward(center() - at), PROP_HEIGHTS["security_camera"])
		"door":
			var spans_x := map.is_wall(cell + Vector2i(1, 0)) or map.is_wall(cell + Vector2i(-1, 0))
			model = _add_prop("security_door", at, 0.0 if spans_x else PI / 2.0, 0.0, 1.0)
		"cache":
			model = _add_prop("server_rack", at, 0.0, PROP_HEIGHTS["server_rack"])
	_nodes[id] = {"model": model}


# Map dressing, one prop per line: "name x,y facing [tiles]". On a wall tile a mounted prop hangs
# on that face of the wall, and any other prop stands in for the wall across that many tiles,
# along x when it faces north or south and along y when it faces east or west.
func _build_dressing(line: String) -> void:
	var parts := line.split(" ", false)
	var prop := parts[0]
	var cell := _cell(parts[1])
	var yaw: float = FACINGS[parts[2]]
	var tiles := parts[3].to_int() if parts.size() > 3 else 1
	if _is_structure(cell) and prop in MOUNTED:
		var out := Vector3(sin(yaw), 0, cos(yaw))
		_mount_on_wall(prop, cell_to_world(cell) + out * 0.5, Vector2i(roundi(out.x), roundi(out.z)))
	elif map.is_wall(cell):
		var run := _run_direction(yaw)
		var middle := cell_to_world(cell) + Vector3(run.x, 0, run.y) * (tiles - 1) / 2.0
		_add_prop(prop, middle, yaw, 0.0, tiles)
	else:
		_add_prop(prop, cell_to_world(cell), yaw, PROP_HEIGHTS.get(prop, 1.0))


func _filled_cells() -> Dictionary:
	var cells := {}
	for line in map.dressing:
		var parts := line.split(" ", false)
		var cell := _cell(parts[1])
		if parts[0] in MOUNTED or not map.is_wall(cell):
			continue
		var run := _run_direction(FACINGS[parts[2]])
		for i in (parts[3].to_int() if parts.size() > 3 else 1):
			cells[cell + run * i] = true
	return cells


func _run_direction(yaw: float) -> Vector2i:
	return Vector2i(1, 0) if is_zero_approx(sin(yaw)) else Vector2i(0, 1)


func _cell(xy: String) -> Vector2i:
	var parts := xy.split(",")
	return Vector2i(parts[0].to_int(), parts[1].to_int())


# The building around the map: a wall ring one tile out, a paved apron, then the asphalt yard.
func _build_shell(wall_mesh: Mesh) -> void:
	var shell := _textured(SHELL_TEXTURE, Color.WHITE, 0.5)
	for x in range(-1, map.size.x + 1):
		for y in range(-1, map.size.y + 1):
			if _on_shell(Vector2i(x, y)):
				_add_wall(Vector2i(x, y), wall_mesh, shell)
	var apron := PlaneMesh.new()
	apron.size = Vector2(map.size.x + 2.0 + APRON_WIDTH * 2.0, map.size.y + 2.0 + APRON_WIDTH * 2.0)
	_add_mesh(apron, _textured(APRON_TEXTURE, Color(0.8, 0.8, 0.8), 0.5), center() + Vector3(0, -TILE_HEIGHT + 0.005, 0))
	var yard := PlaneMesh.new()
	yard.size = Vector2(YARD_SIZE, YARD_SIZE)
	_add_mesh(yard, _textured(YARD_TEXTURE, Color(0.7, 0.7, 0.75), 0.25), center() + Vector3(0, -TILE_HEIGHT, 0))


func _on_shell(cell: Vector2i) -> bool:
	return (cell.x == -1 or cell.y == -1 or cell.x == map.size.x or cell.y == map.size.y) \
		and cell.x >= -1 and cell.y >= -1 and cell.x <= map.size.x and cell.y <= map.size.y


func _is_structure(cell: Vector2i) -> bool:
	return map.is_wall(cell) or _on_shell(cell)


# A wall block with a dark cap and a neon strip, like the facility's corridors.
func _add_wall(cell: Vector2i, wall_mesh: Mesh, material: Material) -> void:
	var at := cell_to_world(cell)
	_add_mesh(wall_mesh, material, at + Vector3(0, WALL_HEIGHT / 2.0 - TILE_HEIGHT, 0))
	var top := WALL_HEIGHT - TILE_HEIGHT
	var cap := BoxMesh.new()
	cap.size = Vector3(1.02, 0.06, 1.02)
	_add_mesh(cap, _material(Color(0.28, 0.28, 0.32)), at + Vector3(0, top + 0.03, 0))
	var strip := BoxMesh.new()
	strip.size = Vector3(1.015, 0.04, 1.015)
	var neon := _material(NEON)
	neon.emission_enabled = true
	neon.emission = NEON
	neon.emission_energy_multiplier = 2.5
	_add_mesh(strip, neon, at + Vector3(0, top - 0.12, 0))


# Sized to a height, or to a width when one is given.
func _add_prop(prop: String, at: Vector3, yaw: float, height: float, width := 0.0) -> ToonModel:
	var holder := Node3D.new()
	holder.position = at
	add_child(holder)
	var model := ToonModel.new()
	holder.add_child(model)
	model.build(load(PROP_PATH % [prop, prop]))
	if width > 0.0:
		model.fit_width(width)
	else:
		model.fit_height(height)
	holder.rotation.y = yaw
	return model


# Props face +Z with a flat back, so the back goes against the wall and the front faces away.
func _mount_on_wall(prop: String, at: Vector3, facing: Vector2i) -> ToonModel:
	var model := _add_prop(prop, at, 0.0, PROP_HEIGHTS.get(prop, 1.0))
	model.position.z += model.bounds().size.z / 2.0
	model.get_parent_node_3d().rotation.y = _yaw_toward(Vector3(facing.x, 0, facing.y))
	return model


func _add_pole(at: Vector3, height: float) -> void:
	var pole := CylinderMesh.new()
	pole.top_radius = 0.04
	pole.bottom_radius = 0.06
	pole.height = height
	_add_mesh(pole, _material(Color(0.12, 0.12, 0.14)), at + Vector3(0, height / 2.0, 0))


func _wall_beside(cell: Vector2i) -> Vector2i:
	for direction in Grid.DIRECTIONS:
		if map.is_wall(cell + direction):
			return direction
	return Vector2i.ZERO


func _yaw_toward(direction: Vector3) -> float:
	return atan2(direction.x, direction.z)


func _add_mesh(mesh: Mesh, material: Material, at: Vector3) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material
	instance.position = at
	add_child(instance)
	return instance


# World-space UVs, so the pattern runs on across neighbouring tiles. Repeats is per metre.
func _textured(texture: Texture2D, tint: Color, repeats := 1.0) -> StandardMaterial3D:
	var material := _material(tint)
	material.albedo_texture = texture
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3.ONE * repeats
	return material


func _material(color: Color, overlay := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if overlay:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material
