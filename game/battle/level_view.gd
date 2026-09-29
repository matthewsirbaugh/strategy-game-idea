class_name LevelView
extends Node3D
## The level as a place: ground, walls and buildings, and the props that stand for its nodes and
## dress it. Walls between the camera and what it looks at drop to a stub, the way The Sims cuts
## walls away, so the view stays free.

const TILE_HEIGHT := 0.2
const CUT_HEIGHT := 0.3
const CUT_SPEED := 10.0
# Looking down steeper than this, walls hide little, so none are cut.
const CUT_BELOW_PITCH := 65.0
const WORLD := preload("res://art/shaders/world.gdshader")
# Each kind of wall: its texture, height in metres, and whether a neon strip runs under its cap.
const WALLS := {
	"indoor": {"texture": preload("res://art/textures/corporate_wall.png"), "tint": Color.WHITE, "height": 2.8, "neon": true},
	"perimeter": {"texture": preload("res://art/textures/perimeter_wall.png"), "tint": Color(0.85, 0.85, 0.85), "height": 3.0, "neon": false},
	"building": {"texture": preload("res://art/textures/perimeter_wall.png"), "tint": Color(0.32, 0.32, 0.38), "height": 9.0, "neon": true},
}
const INDOOR_FLOOR := preload("res://art/textures/corporate_floor.png")
const YARD_FLOOR := preload("res://art/textures/concrete_paving.png")
const STREET := preload("res://art/textures/asphalt.png")
# The ground beyond the map, so the street runs on out of sight.
const GROUND_SIZE := 120.0
const PROP_PATH := "res://art/props/%s/%s.glb"
# Heights in metres, a little bigger than life where a prop has to read from far off.
const PROP_HEIGHTS := {"access_point": 1.2, "security_camera": 0.6, "server_rack": 2.2, "vault_door": 2.6,
	"loading_dock": 2.8, "delivery_van": 2.6, "shipping_crates": 1.6, "floodlight_pole": 6.0,
	"guard_booth": 2.6, "security_door": 2.4}
# These hang on a wall face; any other prop placed on a wall tile stands in for the wall.
const MOUNTED := ["vault_door", "loading_dock", "security_door", "access_point", "security_camera"]
# Wall stand-ins sized by height rather than stretched to fill their tiles.
const KEEP_HEIGHT := ["guard_booth"]
const NEON := Color(1.0, 0.15, 0.6)
const HAZARD := Color(1.0, 0.42, 0.1)
const CAMERA_MOUNT_Y := 2.1
# A wall panel's bottom edge, so its screen sits at chest height.
const PANEL_MOUNT_Y := 0.6
const CAMERA_POLE_HEIGHT := 2.2
const BREACHED_COLOR := Color(0.35, 1.0, 0.6)

var map: MapData
var _grid: GridView
var _nodes := {}
# Each wall that can be cut away: its parts, full and current height, and the dressing hung on it.
var _walls := {}
var _materials := {}
var _cap_material: ShaderMaterial
var _neon_material: StandardMaterial3D
var _hazard_material: ShaderMaterial


func build(state: BattleState, grid: GridView) -> void:
	map = state.map
	_grid = grid
	for style in WALLS:
		_materials[style] = _world(WALLS[style].texture, WALLS[style].tint, 0.5)
	_cap_material = _world(null, Color(0.45, 0.45, 0.5))
	_neon_material = _glow(NEON, 2.5)
	_hazard_material = _world(null, HAZARD)
	_build_ground()
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
		var height := move_toward(wall.height, CUT_HEIGHT if in_front else wall.full, CUT_SPEED * delta)
		if height != wall.height:
			_set_wall_height(wall, height)


# Where the camera is looking, on the floor.
func _focus(camera: Camera3D) -> Vector3:
	var forward := -camera.global_basis.z
	if forward.y > -0.01:
		return camera.global_position
	return camera.global_position + forward * (-camera.global_position.y / forward.y)


func _build_ground() -> void:
	var tile := BoxMesh.new()
	tile.size = Vector3(GridView.CELL - GridView.TILE_GAP, TILE_HEIGHT, GridView.CELL - GridView.TILE_GAP)
	var street := BoxMesh.new()
	street.size = Vector3(GridView.CELL, TILE_HEIGHT, GridView.CELL)
	var floor_texture := INDOOR_FLOOR if map.indoors else YARD_FLOOR
	var light := _world(floor_texture, Color.WHITE, 1.0 / GridView.CELL)
	var dark := _world(floor_texture, Color(0.85, 0.85, 0.85), 1.0 / GridView.CELL)
	var asphalt := _world(STREET, Color(0.75, 0.75, 0.8), 0.25)
	var filled := _filled_cells()
	for y in map.size.y:
		for x in map.size.x:
			var cell := Vector2i(x, y)
			var at := _grid.cell_to_world(cell) + Vector3(0, -TILE_HEIGHT / 2.0, 0)
			if filled.has(cell):
				continue
			if map.is_wall(cell):
				_add_wall(cell, _wall_style(cell))
			elif map.is_street(cell):
				_add_mesh(street, asphalt, at)
			else:
				_add_mesh(tile, light if (x + y) % 2 == 0 else dark, at)
	var ground := PlaneMesh.new()
	ground.size = Vector2(GROUND_SIZE, GROUND_SIZE)
	_add_mesh(ground, _world(STREET, Color(0.55, 0.55, 0.6), 0.25), _grid.center() + Vector3(0, -TILE_HEIGHT, 0))


func _wall_style(cell: Vector2i) -> String:
	if map.is_building(cell):
		return "building"
	return "indoor" if map.indoors else "perimeter"


func _build_node(id: String) -> void:
	var kind := map.node_kind(id)
	if kind == "turret":
		return
	var cell := map.node_cell(id)
	var at := _grid.cell_to_world(cell)
	var set_in_wall := map.in_wall(cell) and kind != "door"
	var facing := map.node_facing(id)
	if set_in_wall:
		_add_wall(cell, _wall_style(_wall_beside(cell) + cell), false)
	var model: ToonModel
	match kind:
		"access":
			# Set into a wall it's a panel. In the open it stands on the floor until the terminal
			# model exists.
			if set_in_wall:
				model = _hang("access_point", cell, facing, PANEL_MOUNT_Y)
			else:
				model = _add_prop("access_point", at, _yaw_toward(Vector3(facing.x, 0, facing.y)), PROP_HEIGHTS["access_point"])
		"camera":
			if set_in_wall:
				model = _hang("security_camera", cell, facing, CAMERA_MOUNT_Y)
			else:
				_add_pole(at, CAMERA_POLE_HEIGHT)
				model = _add_prop("security_camera", at + Vector3(0, CAMERA_POLE_HEIGHT, 0), _yaw_toward(_grid.center() - at), PROP_HEIGHTS["security_camera"])
		"door":
			var spans_x := map.is_wall(cell + Vector2i(1, 0)) or map.is_wall(cell + Vector2i(-1, 0))
			model = _add_prop("security_door", at, 0.0 if spans_x else PI / 2.0, 0.0, GridView.CELL)
		"cache":
			if set_in_wall:
				model = _hang("server_rack", cell, facing, 0.0)
			else:
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
	var facing := Vector2i(roundi(sin(yaw)), roundi(cos(yaw)))
	if _walls.has(cell) and prop in MOUNTED:
		_hang(prop, cell, facing, 0.0)
	elif map.is_wall(cell):
		var run := _run_direction(yaw)
		var middle := _grid.cell_to_world(cell) + Vector3(run.x, 0, run.y) * GridView.CELL * (tiles - 1) / 2.0
		if prop in KEEP_HEIGHT:
			_add_prop(prop, middle, yaw, PROP_HEIGHTS[prop])
		else:
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


# A wall block with a cap, and a neon strip or a hazard band by style. A wall holding a node is
# never cut away, so the node stays in view.
func _add_wall(cell: Vector2i, style: String, cuttable := true) -> void:
	var look: Dictionary = WALLS[style]
	var block := BoxMesh.new()
	block.size = Vector3(GridView.CELL, 1.0, GridView.CELL)
	var cap := BoxMesh.new()
	cap.size = Vector3(GridView.CELL + 0.02, 0.06, GridView.CELL + 0.02)
	var strip := BoxMesh.new()
	strip.size = Vector3(GridView.CELL + 0.015, 0.04 if look.neon else 0.35, GridView.CELL + 0.015)
	var at := _grid.cell_to_world(cell)
	var wall := {
		"block": _add_mesh(block, _materials[style], at),
		"cap": _add_mesh(cap, _cap_material, at),
		"strip": _add_mesh(strip, _neon_material if look.neon else _hazard_material, at),
		"neon": look.neon,
		"full": look.height,
		"height": 0.0,
		"hung": [],
	}
	_set_wall_height(wall, look.height)
	if cuttable:
		_walls[cell] = wall


func _set_wall_height(wall: Dictionary, height: float) -> void:
	wall.height = height
	var bottom := -TILE_HEIGHT
	wall.block.scale.y = height
	wall.block.position.y = bottom + height / 2.0
	wall.cap.position.y = bottom + height + 0.03
	# Neon runs just under the cap; the hazard band stays near the foot of the wall.
	wall.strip.position.y = bottom + height - 0.12 if wall.neon else bottom + minf(0.5, height / 2.0)
	for hung: Node3D in wall.hung:
		hung.visible = height > wall.full * 0.8


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


# On one face of a wall tile, facing out from it, at a height; it hides if that wall is cut.
# Props face +Z with a flat back, so the back goes against the wall.
func _hang(prop: String, cell: Vector2i, facing: Vector2i, height: float) -> ToonModel:
	var at := _grid.cell_to_world(cell) + Vector3(facing.x, 0, facing.y) * GridView.CELL / 2.0 + Vector3(0, height, 0)
	var model := _add_prop(prop, at, 0.0, PROP_HEIGHTS.get(prop, 1.0))
	model.position.z += model.bounds().size.z / 2.0
	model.get_parent_node_3d().rotation.y = _yaw_toward(Vector3(facing.x, 0, facing.y))
	if _walls.has(cell):
		_walls[cell].hung.append(model.get_parent_node_3d())
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


static func _glow(color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material


# A texture laid in world space, repeats per metre, and dimmed by the fog.
static func _world(texture: Texture2D, tint: Color, repeats := 1.0) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = WORLD
	if texture:
		material.set_shader_parameter("albedo_texture", texture)
	material.set_shader_parameter("tint", tint)
	material.set_shader_parameter("repeats_per_metre", repeats)
	return material
