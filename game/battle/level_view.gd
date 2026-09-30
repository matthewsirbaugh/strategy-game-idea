class_name LevelView
extends Node3D
## The level as a place: ground, walls and buildings, and the props that stand for its nodes and
## dress it. Walls and wall-standing props between the camera and the player's units ghost out,
## thinned to a dot pattern, the way Diablo and Baldur's Gate 3 keep the party in view; H ghosts
## every wall.

const TILE_HEIGHT := 0.2
const GHOST_SECONDS := 0.2
# Points on a unit checked for a clear line to the camera: feet, waist, head.
const SIGHT_HEIGHTS := [0.3, 1.0, 1.7]
const SIGHT_STEP := 0.25
const WORLD := preload("res://art/shaders/world.gdshader")
# Each kind of wall: its texture, height in metres, and whether a neon strip runs under its cap.
const WALLS := {
	"indoor": {"texture": preload("res://art/textures/corporate_wall.png"), "tint": Color.WHITE, "height": 2.8, "neon": true},
	"perimeter": {"texture": preload("res://art/textures/perimeter_wall.png"), "tint": Color(0.85, 0.85, 0.85), "height": 3.0, "neon": false},
	"building": {"texture": preload("res://art/textures/perimeter_wall.png"), "tint": Color(0.32, 0.32, 0.38), "height": 9.0, "neon": true},
}
# The wall kit around each block: a darker plinth proud of the face, a lighter cap that overhangs
# it, and on perimeter walls a striped hazard band. Heights are above the floor.
const PLINTH_HEIGHT := 0.2
const PLINTH_PROUD := 0.04
const CAP_THICKNESS := 0.1
const CAP_OVERHANG := 0.05
const CAP_COLOR := Color(0.55, 0.53, 0.5)
const HAZARD_TOP := 1.1
const HAZARD_BASE := Color(0.58, 0.56, 0.53)
# Buildings carry a second neon line at storefront height, where it lights the street.
const STOREFRONT_NEON_Y := 2.6
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
const NEON := Color(1.0, 0.42, 0.22)
const HAZARD := Color(1.0, 0.42, 0.1)
const NEON_LIGHT_RANGE := 6.5
const NEON_LIGHT_ENERGY := 2.2
const FLOODLIGHT := Color(1.0, 0.93, 0.82)
const FLOODLIGHT_HEAD_Y := 5.7
# Rain over the whole map outdoors: streaks per second across it, and how fast they fall.
const RAIN := true
const RAIN_AMOUNT := 3500
const RAIN_SPEED := 22.0
const CAMERA_MOUNT_Y := 2.1
# A wall panel's bottom edge, so its screen sits at chest height.
const PANEL_MOUNT_Y := 0.6
const CAMERA_POLE_HEIGHT := 2.2
const BREACHED_COLOR := Color(0.35, 1.0, 0.6)

var map: MapData
# The units whose view the walls get out of.
var watched: Array[Node3D] = []
var _grid: GridView
var _nodes := {}
# Each wall tile: its block, its height, and how ghosted it is now.
var _walls := {}
# Props that stand in for wall tiles, by tile, and each of them once.
var _standins := {}
var _standin_models: Array[ToonModel] = []
var _ghost_all := false
var _materials := {}
var _plinth_materials := {}
var _cap_material: ShaderMaterial
var _neon_material: StandardMaterial3D
var _hazard_material: ShaderMaterial


func build(state: BattleState, grid: GridView) -> void:
	map = state.map
	_grid = grid
	for style in WALLS:
		var look: Dictionary = WALLS[style]
		_materials[style] = _world(look.texture, look.tint, 0.5)
		_materials[style].set_shader_parameter("wall_height", look.height)
		_plinth_materials[style] = _world(look.texture, look.tint * 0.6, 0.5)
	_cap_material = _world(null, CAP_COLOR)
	_neon_material = _glow(NEON, 2.5)
	_hazard_material = _world(null, HAZARD_BASE)
	_hazard_material.set_shader_parameter("stripes", 1.0)
	_hazard_material.set_shader_parameter("stripe_color", HAZARD * 0.85)
	_build_ground()
	for id in map.node_ids():
		_build_node(id)
	for item in map.dressing_items():
		_build_dressing(item)
	if RAIN and not map.indoors:
		_build_rain()
	update_nodes(state)


# The physical side of a breach: a door opens, a hacked camera or cache turns the player's color.
func update_nodes(state: BattleState) -> void:
	for id in _nodes:
		if state.breached.has(id):
			_nodes[id].tint = BREACHED_COLOR
		if map.node_kind(id) == "door":
			_nodes[id].visible = not state.is_door_open(id)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_walls"):
		_ghost_all = not _ghost_all


func _process(delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if not camera or _walls.is_empty():
		return
	var in_the_way := {}
	for unit in watched:
		if unit.is_visible_in_tree():
			for height in SIGHT_HEIGHTS:
				_mark_between(unit.global_position + Vector3(0, height, 0), camera.global_position, in_the_way)
	var step := delta / GHOST_SECONDS
	for cell in _walls:
		var wall: Dictionary = _walls[cell]
		var ghost := move_toward(wall.ghost, 1.0 if _ghost_all or in_the_way.has(cell) else 0.0, step)
		if ghost != wall.ghost:
			wall.ghost = ghost
			wall.block.set_instance_shader_parameter("ghost", ghost)
	for model in _standin_models:
		model.ghost = move_toward(model.ghost, 1.0 if _ghost_all or in_the_way.has(model) else 0.0, step)


# Walks the line from a point on a unit to the camera and marks every wall, or wall-standing prop,
# it passes through below its top.
func _mark_between(from: Vector3, to: Vector3, marks: Dictionary) -> void:
	var start_cell := _grid.world_to_cell(from)
	var length := from.distance_to(to)
	var direction := (to - from) / length
	var distance := SIGHT_STEP
	while distance < length:
		var point := from + direction * distance
		distance += SIGHT_STEP
		var cell := _grid.world_to_cell(point)
		if cell == start_cell:
			continue
		if _walls.has(cell) and point.y < _walls[cell].top:
			marks[cell] = true
		elif _standins.has(cell) and point.y < _standins[cell].bounds().end.y:
			marks[_standins[cell]] = true
		elif point.y > WALLS.building.height:
			return


func _build_ground() -> void:
	# One continuous surface: tiles meet edge to edge and the shader's seam lines carry the grid.
	var tile := BoxMesh.new()
	tile.size = Vector3(GridView.CELL, TILE_HEIGHT, GridView.CELL)
	var wet := 0.0 if map.indoors else 1.0
	var paving := _world(INDOOR_FLOOR if map.indoors else YARD_FLOOR, Color.WHITE, 1.0 / GridView.CELL)
	paving.set_shader_parameter("grid_lines", 1.0)
	paving.set_shader_parameter("wet", wet)
	var asphalt := _world(STREET, Color(0.6, 0.6, 0.64), 0.25)
	asphalt.set_shader_parameter("wet", wet)
	var filled := _filled_cells()
	for y in map.size.y:
		for x in map.size.x:
			var cell := Vector2i(x, y)
			var at := _grid.cell_to_world(cell) + Vector3(0, -TILE_HEIGHT / 2.0, 0)
			if filled.has(cell):
				continue
			if map.is_wall(cell):
				_add_wall(cell, _wall_style(cell))
			else:
				_add_mesh(tile, asphalt if map.is_street(cell) else paving, at)
	var ground := PlaneMesh.new()
	ground.size = Vector2(GROUND_SIZE, GROUND_SIZE)
	var beyond := _world(STREET, Color(0.45, 0.45, 0.5), 0.25)
	beyond.set_shader_parameter("wet", wet)
	_add_mesh(ground, beyond, _grid.center() + Vector3(0, -TILE_HEIGHT, 0))


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
		_add_wall(cell, _wall_style(_wall_beside(cell) + cell))
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
		var model: ToonModel
		if prop in KEEP_HEIGHT:
			model = _add_prop(prop, middle, yaw, PROP_HEIGHTS[prop])
		else:
			model = _add_prop(prop, middle, yaw, 0.0, tiles * GridView.CELL)
		_standin_models.append(model)
		for i in tiles:
			_standins[cell + run * i] = model
	else:
		_add_prop(prop, _grid.cell_to_world(cell), yaw, PROP_HEIGHTS.get(prop, 1.0))
		if prop == "floodlight_pole":
			_add_floodlight(_grid.cell_to_world(cell))


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


# A wall block with its plinth and cap, and neon or a hazard band by style. Only the block ghosts,
# so the plinth, cap and band keep showing where the wall stands and how tall it is. Neighbouring
# pieces overlap on the same planes; the world-space shader draws them identically, so no seam shows.
func _add_wall(cell: Vector2i, style: String) -> void:
	var look: Dictionary = WALLS[style]
	var height: float = look.height
	var bottom := -TILE_HEIGHT
	var top := bottom + height
	var at := _grid.cell_to_world(cell)
	var block := BoxMesh.new()
	block.size = Vector3(GridView.CELL, height, GridView.CELL)
	_walls[cell] = {
		"block": _add_mesh(block, _materials[style], at + Vector3(0, bottom + height / 2.0, 0)),
		"top": top,
		"ghost": 0.0,
	}
	var plinth_width := GridView.CELL + PLINTH_PROUD * 2.0
	_add_box(Vector3(plinth_width, PLINTH_HEIGHT - bottom, plinth_width), _plinth_materials[style], at + Vector3(0, (bottom + PLINTH_HEIGHT) / 2.0, 0))
	var cap_width := GridView.CELL + CAP_OVERHANG * 2.0
	_add_box(Vector3(cap_width, CAP_THICKNESS, cap_width), _cap_material, at + Vector3(0, top + CAP_THICKNESS / 2.0 - 0.02, 0))
	var band_width := GridView.CELL + 0.015
	if look.neon:
		_add_box(Vector3(band_width, 0.04, band_width), _neon_material, at + Vector3(0, top - 0.12, 0))
		var light_y := top - 0.4
		if style == "building":
			_add_box(Vector3(band_width, 0.06, band_width), _neon_material, at + Vector3(0, STOREFRONT_NEON_Y, 0))
			light_y = STOREFRONT_NEON_Y - 0.2
		_add_neon_lights(cell, light_y)
	else:
		var band_height := HAZARD_TOP - PLINTH_HEIGHT
		_add_box(Vector3(band_width, band_height, band_width), _hazard_material, at + Vector3(0, PLINTH_HEIGHT + band_height / 2.0, 0))


# Neon that lights its surroundings: a short-range light off every other open face of the wall,
# so the glow pools on the wet ground in front of it.
func _add_neon_lights(cell: Vector2i, y: float) -> void:
	if (cell.x + cell.y) % 2 != 0:
		return
	for direction in Grid.DIRECTIONS:
		var beside := cell + direction
		if not map.in_bounds(beside) or map.is_wall(beside):
			continue
		var light := OmniLight3D.new()
		light.light_color = NEON
		light.light_energy = NEON_LIGHT_ENERGY
		light.omni_range = NEON_LIGHT_RANGE
		light.position = _grid.cell_to_world(cell) + Vector3(direction.x, 0, direction.y) * (GridView.CELL / 2.0 + 0.4) + Vector3(0, y, 0)
		add_child(light)


func _add_floodlight(at: Vector3) -> void:
	var light := SpotLight3D.new()
	light.light_color = FLOODLIGHT
	light.light_energy = 5.0
	light.spot_range = 18.0
	light.spot_angle = 62.0
	light.spot_attenuation = 0.8
	light.shadow_enabled = true
	add_child(light)
	light.look_at_from_position(at + Vector3(0, FLOODLIGHT_HEAD_Y, 0), at + Vector3(0.01, 0, 0.3))


# Thin streaks falling over the whole map, lit by nothing, so they read as rain in any light.
func _build_rain() -> void:
	var rain := GPUParticles3D.new()
	rain.amount = RAIN_AMOUNT
	rain.lifetime = 0.8
	rain.preprocess = 1.0
	var extent := _grid.extent()
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(extent.x / 2.0 + 10.0, 0.5, extent.z / 2.0 + 10.0)
	process.direction = Vector3(0.08, -1.0, 0.04)
	process.spread = 2.0
	process.initial_velocity_min = RAIN_SPEED * 0.9
	process.initial_velocity_max = RAIN_SPEED * 1.1
	process.gravity = Vector3.ZERO
	rain.process_material = process
	var streak := QuadMesh.new()
	streak.size = Vector2(0.01, 0.35)
	var look := StandardMaterial3D.new()
	look.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	look.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	look.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	look.albedo_color = Color(0.75, 0.8, 0.95, 0.16)
	streak.material = look
	rain.draw_pass_1 = streak
	rain.visibility_aabb = AABB(Vector3(-extent.x, -20.0, -extent.z), Vector3(extent.x * 2.0, 40.0, extent.z * 2.0))
	rain.position = _grid.center() + Vector3(0, 14.0, 0)
	add_child(rain)


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


# On one face of a wall tile, facing out from it, at a height. It stays solid when the wall
# ghosts. Props face +Z with a flat back, so the back goes against the wall.
func _hang(prop: String, cell: Vector2i, facing: Vector2i, height: float) -> ToonModel:
	var at := _grid.cell_to_world(cell) + Vector3(facing.x, 0, facing.y) * GridView.CELL / 2.0 + Vector3(0, height, 0)
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


func _add_box(size: Vector3, material: Material, at: Vector3) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = size
	return _add_mesh(box, material, at)


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
