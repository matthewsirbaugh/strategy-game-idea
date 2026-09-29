class_name LevelView
extends Node3D
## The level as a place: floors, full-height walls, the building around the map, and the props
## that stand for its nodes and dress it. Walls between the camera and what it looks at drop to
## a stub, the way The Sims cuts walls away, so the view stays free.

const TILE_HEIGHT := 0.2
const WALL_HEIGHT := 2.8
const CUT_HEIGHT := 0.3
const CUT_SPEED := 8.0
# Looking down steeper than this, walls hide little, so none are cut.
const CUT_BELOW_PITCH := 65.0
const FLOOR_TEXTURE := preload("res://art/textures/corporate_floor.png")
const WALL_TEXTURE := preload("res://art/textures/corporate_wall.png")
const SHELL_TEXTURE := preload("res://art/textures/perimeter_wall.png")
const YARD_TEXTURE := preload("res://art/textures/asphalt.png")
const APRON_TEXTURE := preload("res://art/textures/concrete_paving.png")
const WORLD := preload("res://art/shaders/world.gdshader")
const PROP_PATH := "res://art/props/%s/%s.glb"
# Heights in metres, a little bigger than life where a prop has to read from far off.
const PROP_HEIGHTS := {"access_point": 1.2, "security_camera": 0.6, "server_rack": 2.2, "vault_door": 2.6,
	"loading_dock": 2.8, "delivery_van": 2.6, "shipping_crates": 1.6, "floodlight_pole": 6.0, "guard_booth": 2.8}
# These hang on a wall face; any other prop placed on a wall tile stands in for the wall.
const MOUNTED := ["vault_door", "loading_dock", "security_door", "access_point", "security_camera"]
const NEON := Color(1.0, 0.15, 0.6)
const CAMERA_MOUNT_Y := 2.1
const CAMERA_POLE_HEIGHT := 2.2
const APRON_WIDTH := 3.0
const YARD_SIZE := 90.0
const BREACHED_COLOR := Color(0.35, 1.0, 0.6)

var map: MapData
var _grid: GridView
var _nodes := {}
# Each wall: its parts, how tall it stands now, and the dressing hung on it.
var _walls := {}
var _wall_material: ShaderMaterial
var _shell_material: ShaderMaterial
var _cap_material: ShaderMaterial
var _neon_material: StandardMaterial3D


func build(state: BattleState, grid: GridView) -> void:
	map = state.map
	_grid = grid
	_wall_material = _world(WALL_TEXTURE, Color.WHITE, 0.5)
	_shell_material = _world(SHELL_TEXTURE, Color.WHITE, 0.5)
	_cap_material = _world(null, Color(0.45, 0.45, 0.5))
	_neon_material = StandardMaterial3D.new()
	_neon_material.albedo_color = NEON
	_neon_material.emission_enabled = true
	_neon_material.emission = NEON
	_neon_material.emission_energy_multiplier = 2.5
	_build_floor()
	_build_surroundings()
	for id in map.node_ids():
		_build_node(id)
	for item in map.dressing_items():
		_build_dressing(item)
	update_nodes(state)


# The physical side of a breach: a door opens, a hacked camera or cache turns the player's color.
func update_nodes(state: BattleState) -> void:
	for id in _nodes:
		if state.breached.has(id):
			_nodes[id].tint = BREACHED_COLOR
		if map.node_kind(id) == "door":
			_nodes[id].visible = not state.is_door_open(id)


func _process(delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if not camera or _walls.is_empty():
		return
	var cutting := rad_to_deg(-camera.global_rotation.x) < CUT_BELOW_PITCH
	var focus := _focus(camera)
	var toward_camera := camera.global_position - focus
	toward_camera.y = 0.0
	toward_camera = toward_camera.normalized()
	for cell in _walls:
		var wall: Dictionary = _walls[cell]
		var in_front := cutting and (_grid.cell_to_world(cell) - focus).dot(toward_camera) > GridView.CELL * 0.3
		var height := move_toward(wall.height, CUT_HEIGHT if in_front else WALL_HEIGHT, CUT_SPEED * delta)
		if height != wall.height:
			_set_wall_height(wall, height)


# Where the camera is looking, on the floor.
func _focus(camera: Camera3D) -> Vector3:
	var forward := -camera.global_basis.z
	if forward.y > -0.01:
		return camera.global_position
	return camera.global_position + forward * (-camera.global_position.y / forward.y)


func _build_floor() -> void:
	var tile := BoxMesh.new()
	tile.size = Vector3(GridView.CELL - GridView.TILE_GAP, TILE_HEIGHT, GridView.CELL - GridView.TILE_GAP)
	var light := _world(FLOOR_TEXTURE, Color.WHITE, 1.0 / GridView.CELL)
	var dark := _world(FLOOR_TEXTURE, Color(0.85, 0.85, 0.85), 1.0 / GridView.CELL)
	var filled := _filled_cells()
	for y in map.size.y:
		for x in map.size.x:
			var cell := Vector2i(x, y)
			if filled.has(cell):
				continue
			if map.is_wall(cell):
				_add_wall(cell, _wall_material)
			else:
				_add_mesh(tile, light if (x + y) % 2 == 0 else dark, _grid.cell_to_world(cell) + Vector3(0, -TILE_HEIGHT / 2.0, 0))


# The building around the map: a wall ring one tile out, a paved apron, then the asphalt yard.
func _build_surroundings() -> void:
	for x in range(-1, map.size.x + 1):
		for y in range(-1, map.size.y + 1):
			if _on_shell(Vector2i(x, y)):
				_add_wall(Vector2i(x, y), _shell_material)
	var inner := Vector2(map.size) * GridView.CELL + Vector2.ONE * GridView.CELL * 2.0
	var apron := PlaneMesh.new()
	apron.size = inner + Vector2.ONE * APRON_WIDTH * 2.0
	_add_mesh(apron, _world(APRON_TEXTURE, Color(0.8, 0.8, 0.8), 0.5), _grid.center() + Vector3(0, -TILE_HEIGHT + 0.005, 0))
	var yard := PlaneMesh.new()
	yard.size = Vector2(YARD_SIZE, YARD_SIZE)
	_add_mesh(yard, _world(YARD_TEXTURE, Color(0.7, 0.7, 0.75), 0.25), _grid.center() + Vector3(0, -TILE_HEIGHT, 0))


func _build_node(id: String) -> void:
	var kind := map.node_kind(id)
	if kind == "turret":
		return
	var cell := map.node_cell(id)
	var at := _grid.cell_to_world(cell)
	var wall := _wall_beside(cell)
	var model: ToonModel
	match kind:
		"access":
			model = _add_prop("access_point", at, 0.0, PROP_HEIGHTS["access_point"])
		"camera":
			if _walls.has(cell + wall) and wall != Vector2i.ZERO:
				model = _mount_on_wall("security_camera", at + Vector3(wall.x, 0, wall.y) * GridView.CELL / 2.0 + Vector3(0, CAMERA_MOUNT_Y, 0), -wall)
				_walls[cell + wall].hung.append(model.get_parent_node_3d())
			else:
				_add_pole(at, CAMERA_POLE_HEIGHT)
				model = _add_prop("security_camera", at + Vector3(0, CAMERA_POLE_HEIGHT, 0), _yaw_toward(_grid.center() - at), PROP_HEIGHTS["security_camera"])
		"door":
			var spans_x := map.is_wall(cell + Vector2i(1, 0)) or map.is_wall(cell + Vector2i(-1, 0))
			model = _add_prop("security_door", at, 0.0 if spans_x else PI / 2.0, 0.0, GridView.CELL)
		"cache":
			model = _add_prop("server_rack", at, 0.0, PROP_HEIGHTS["server_rack"])
	_nodes[id] = model


# On a wall tile a mounted prop hangs on that face of the wall, and any other prop stands in for
# the wall across its tiles, along x when it faces north or south and along y when it faces east
# or west. Anywhere else a prop just stands on the floor.
func _build_dressing(item: Dictionary) -> void:
	var prop: String = item.prop
	var cell: Vector2i = item.cell
	var yaw: float = item.yaw
	var tiles: int = item.tiles
	if _walls.has(cell) and prop in MOUNTED:
		var out := Vector3(sin(yaw), 0, cos(yaw))
		var model := _mount_on_wall(prop, _grid.cell_to_world(cell) + out * GridView.CELL / 2.0, Vector2i(roundi(out.x), roundi(out.z)))
		_walls[cell].hung.append(model.get_parent_node_3d())
	elif map.is_wall(cell):
		var run := _run_direction(yaw)
		var middle := _grid.cell_to_world(cell) + Vector3(run.x, 0, run.y) * GridView.CELL * (tiles - 1) / 2.0
		_add_prop(prop, middle, yaw, 0.0, tiles * GridView.CELL)
	else:
		_add_prop(prop, _grid.cell_to_world(cell), yaw, PROP_HEIGHTS.get(prop, 1.0))


# Wall tiles that a prop stands in for, so no wall block is built there.
func _filled_cells() -> Dictionary:
	var cells := {}
	for item in map.dressing_items():
		var cell: Vector2i = item.cell
		if item.prop in MOUNTED or not map.is_wall(cell):
			continue
		for i: int in item.tiles:
			cells[cell + _run_direction(item.yaw) * i] = true
	return cells


func _run_direction(yaw: float) -> Vector2i:
	return Vector2i(1, 0) if is_zero_approx(sin(yaw)) else Vector2i(0, 1)


func _on_shell(cell: Vector2i) -> bool:
	return (cell.x == -1 or cell.y == -1 or cell.x == map.size.x or cell.y == map.size.y) \
		and cell.x >= -1 and cell.y >= -1 and cell.x <= map.size.x and cell.y <= map.size.y


# A wall block with a dark cap and a neon strip below it, like the facility's corridors.
func _add_wall(cell: Vector2i, material: Material) -> void:
	var block := BoxMesh.new()
	block.size = Vector3(GridView.CELL, 1.0, GridView.CELL)
	var cap := BoxMesh.new()
	cap.size = Vector3(GridView.CELL + 0.02, 0.06, GridView.CELL + 0.02)
	var strip := BoxMesh.new()
	strip.size = Vector3(GridView.CELL + 0.015, 0.04, GridView.CELL + 0.015)
	var at := _grid.cell_to_world(cell)
	var wall := {
		"block": _add_mesh(block, material, at),
		"cap": _add_mesh(cap, _cap_material, at),
		"strip": _add_mesh(strip, _neon_material, at),
		"height": 0.0,
		"hung": [],
	}
	_walls[cell] = wall
	_set_wall_height(wall, WALL_HEIGHT)


func _set_wall_height(wall: Dictionary, height: float) -> void:
	wall.height = height
	var bottom := -TILE_HEIGHT
	wall.block.scale.y = height
	wall.block.position.y = bottom + height / 2.0
	wall.cap.position.y = bottom + height + 0.03
	wall.strip.position.y = bottom + height - 0.12
	for hung: Node3D in wall.hung:
		hung.visible = height > WALL_HEIGHT * 0.8


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
	_add_mesh(pole, _world(null, Color(0.12, 0.12, 0.14)), at + Vector3(0, height / 2.0, 0))


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


# A texture laid in world space, repeats per metre, and dimmed by the fog.
static func _world(texture: Texture2D, tint: Color, repeats := 1.0) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = WORLD
	if texture:
		material.set_shader_parameter("albedo_texture", texture)
	material.set_shader_parameter("tint", tint)
	material.set_shader_parameter("repeats_per_metre", repeats)
	return material
