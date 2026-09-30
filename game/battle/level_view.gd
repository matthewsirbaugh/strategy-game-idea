class_name LevelView
extends Node3D
## The level as a place: ground, walls and buildings, the props that stand for its nodes and dress
## it, its signs and lights, and outdoors the rain and the city around it. Walls and wall-standing
## props between the camera and the player's units ghost out, thinned to a dot pattern, the way
## Diablo and Baldur's Gate 3 keep the party in view; H ghosts every wall. L switches the models
## between soft and hard-edged shading, to compare them.

const TILE_HEIGHT := 0.2
const GHOST_SECONDS := 0.2
# Points on a unit checked for a clear line to the camera: feet, waist, head.
const SIGHT_HEIGHTS := [0.3, 1.0, 1.7]
const SIGHT_STEP := 0.25
# Each kind of wall, by the name of its surface: its height in metres, whether neon runs under its
# cap, and whether a fence runs along its top.
const WALLS := {
	"indoor": {"height": 2.8, "neon": true, "fence": false},
	"perimeter": {"height": 3.0, "neon": false, "fence": true},
	"building": {"height": 9.0, "neon": true, "fence": false},
}
# The kit around each wall block, heights above the floor: a plinth proud of the face, a cap that
# overhangs it, a hazard band on walls without neon, and posts, wires and razor wire on a fence.
const PLINTH_HEIGHT := 0.2
const PLINTH_PROUD := 0.04
const CAP_THICKNESS := 0.1
const CAP_OVERHANG := 0.05
const HAZARD_TOP := 1.1
const FENCE_HEIGHT := 1.1
const WIRE_HEIGHTS := [0.35, 0.65]
const RAZOR_RADIUS := 0.17
const RAZOR_LOOPS := 9
# Buildings carry a second neon line at storefront height, where it lights the street.
const STOREFRONT_NEON_Y := 2.6
const NEON := Color(1.0, 0.42, 0.22)
const NEON_LIGHT_RANGE := 6.5
const NEON_LIGHT_ENERGY := 1.5
const FLOODLIGHT := Color(1.0, 0.93, 0.82)
const FLOODLIGHT_HEAD_Y := 5.7
# The ground beyond the map, under the city around it.
const GROUND_SIZE := 400.0
# Rain falls on the map and this far around it; the haze hides the rest.
const RAIN_MARGIN := 10.0
const PROP_PATH := "res://art/props/%s/%s.glb"
# Heights in metres, a little bigger than life where a prop has to read from far off.
const PROP_HEIGHTS := {"access_point": 1.2, "security_camera": 0.6, "server_rack": 2.2, "vault_door": 2.6,
	"loading_dock": 2.8, "delivery_van": 2.6, "shipping_crates": 1.6, "floodlight_pole": 6.0,
	"guard_booth": 2.6, "security_door": 2.4}
# These hang on a wall face; any other prop placed on a wall tile stands in for the wall.
const MOUNTED := ["vault_door", "loading_dock", "security_door", "access_point", "security_camera"]
# Wall stand-ins sized by height rather than stretched to fill their tiles.
const KEEP_HEIGHT := ["guard_booth"]
const CAMERA_MOUNT_Y := 2.1
# A wall panel's bottom edge, so its screen sits at chest height.
const PANEL_MOUNT_Y := 0.6
const CAMERA_POLE_HEIGHT := 2.2
const BREACHED_COLOR := Color(0.35, 1.0, 0.6)
# The two shadings L switches between, as toon.gdshader's softness; soft is the project default.
const SOFT_SHADING := 0.12
const HARD_SHADING := 0.015

var map: MapData
# The units whose view the walls get out of.
var watched: Array[Node3D] = []
var _grid: GridView
var _signs := Signs.new()
var _nodes := {}
# Each wall tile: its top, how ghosted it is now, and whether a fence runs along it.
var _walls := {}
# What ghosts with the walls: each block, the hazard band on its face, and each sign on a wall,
# with the tiles it covers.
var _ghosting: Array[Dictionary] = []
# Props that stand in for wall tiles, by tile, and each of them once.
var _standins := {}
var _standin_models: Array[ToonModel] = []
var _ghost_all := false
var _soft_shading := true
var _neon_material: StandardMaterial3D


func build(state: BattleState, grid: GridView) -> void:
	map = state.map
	_grid = grid
	add_child(_signs)
	# Every battle starts soft, whatever the last one was switched to.
	RenderingServer.global_shader_parameter_set("toon_softness", SOFT_SHADING)
	_neon_material = _glow(NEON, 2.5)
	_build_ground()
	for id in map.node_ids():
		_build_node(id)
	# After the nodes, since some are set into walls and the fence runs over them too.
	_build_fences()
	_build_rooftops()
	for item in map.dressing_items():
		_build_dressing(item)
	if not map.indoors:
		var city := CityBackdrop.new()
		add_child(city)
		city.build(map, grid, _signs)
		var rain := Rain.new()
		add_child(rain)
		rain.setup(Vector3.ZERO, grid.extent(), RAIN_MARGIN)
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
	elif event.is_action_pressed("toggle_shading"):
		_soft_shading = not _soft_shading
		RenderingServer.global_shader_parameter_set("toon_softness", SOFT_SHADING if _soft_shading else HARD_SHADING)


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
		_walls[cell].ghost = move_toward(_walls[cell].ghost, 1.0 if _ghost_all or in_the_way.has(cell) else 0.0, step)
	for piece in _ghosting:
		var ghost := 0.0
		for cell: Vector2i in piece.cells:
			ghost = maxf(ghost, _walls[cell].ghost if _walls.has(cell) else 0.0)
		if ghost != piece.ghost:
			piece.ghost = ghost
			piece.node.set_instance_shader_parameter("ghost", ghost)
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


# Tiles meet edge to edge as one surface; the paving's joints are the grid.
func _build_ground() -> void:
	var tile := BoxMesh.new()
	tile.size = Vector3(GridView.CELL, TILE_HEIGHT, GridView.CELL)
	var floor_surface := Surfaces.named("corporate" if map.indoors else "paving")
	var street_surface := Surfaces.named("asphalt")
	var filled := _filled_cells()
	for y in map.size.y:
		for x in map.size.x:
			var cell := Vector2i(x, y)
			if filled.has(cell):
				continue
			if map.is_wall(cell):
				_add_wall(cell, _wall_style(cell))
			else:
				_add_mesh(tile, street_surface if map.is_street(cell) else floor_surface, _grid.cell_to_world(cell) + Vector3(0, -TILE_HEIGHT / 2.0, 0))
	var ground := PlaneMesh.new()
	ground.size = Vector2(GROUND_SIZE, GROUND_SIZE)
	_add_mesh(ground, Surfaces.named("corporate" if map.indoors else "sidewalk"), _grid.center() + Vector3(0, -0.03, 0))


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


# A sign goes on the face of its wall tile, or flat on a floor tile. On a wall tile a mounted prop
# hangs on that face of the wall, and any other prop stands in for the wall across its tiles,
# along x when it faces north or south and along y when it faces east or west. Anywhere else a
# prop just stands on the floor.
func _build_dressing(item: Dictionary) -> void:
	var prop: String = item.prop
	var cell: Vector2i = item.cell
	var yaw: float = item.yaw
	var tiles: int = item.tiles
	var facing := Vector2i(roundi(sin(yaw)), roundi(cos(yaw)))
	var run := _run_direction(yaw)
	var middle := _grid.cell_to_world(cell) + Vector3(run.x, 0, run.y) * GridView.CELL * (tiles - 1) / 2.0
	if Signs.has(prop):
		var on_wall := map.is_wall(cell)
		var face := middle + Vector3(facing.x, 0, facing.y) * GridView.CELL / 2.0 if on_wall else middle
		var covered: Array[Vector2i] = []
		for i in tiles:
			covered.append(cell + run * i)
		for piece in _signs.place(prop, face, yaw):
			if on_wall:
				_ghosting.append({"node": piece, "cells": covered, "ghost": 0.0})
	elif _walls.has(cell) and prop in MOUNTED:
		_hang(prop, cell, facing, 0.0)
	elif map.is_wall(cell):
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
		if item.prop in MOUNTED or Signs.has(item.prop) or not map.is_wall(cell):
			continue
		for i: int in item.tiles:
			cells[cell + _run_direction(item.yaw) * i] = true
	return cells


func _run_direction(yaw: float) -> Vector2i:
	return Vector2i(1, 0) if is_zero_approx(sin(yaw)) else Vector2i(0, 1)


# A wall block with its plinth and cap, and neon or a hazard band by style. The block and the band
# on its face ghost; the plinth and cap stay, to show where the wall stands and how tall it is.
# Neighbouring pieces overlap on the same planes; the world-space shaders draw them identically,
# so no seam shows.
func _add_wall(cell: Vector2i, style: String) -> void:
	var look: Dictionary = WALLS[style]
	var height: float = look.height
	var bottom := -TILE_HEIGHT
	var top := bottom + height
	var at := _grid.cell_to_world(cell)
	var block := _add_box(Vector3(GridView.CELL, height, GridView.CELL), Surfaces.named(style), at + Vector3(0, bottom + height / 2.0, 0))
	block.set_instance_shader_parameter("top", top)
	_walls[cell] = {"top": top, "ghost": 0.0, "fence": look.fence}
	_ghosting.append({"node": block, "cells": [cell], "ghost": 0.0})
	var plinth_width := GridView.CELL + PLINTH_PROUD * 2.0
	_add_box(Vector3(plinth_width, PLINTH_HEIGHT - bottom, plinth_width), Surfaces.named("plinth"), at + Vector3(0, (bottom + PLINTH_HEIGHT) / 2.0, 0))
	var cap_width := GridView.CELL + CAP_OVERHANG * 2.0
	_add_box(Vector3(cap_width, CAP_THICKNESS, cap_width), Surfaces.named("cap"), at + Vector3(0, top + CAP_THICKNESS / 2.0 - 0.02, 0))
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
		var band := _add_box(Vector3(band_width, band_height, band_width), Surfaces.named("hazard"), at + Vector3(0, PLINTH_HEIGHT + band_height / 2.0, 0))
		_ghosting.append({"node": band, "cells": [cell], "ghost": 0.0})


# A post on every fenced wall tile, and wire and razor wire to its fenced neighbours east and south.
func _build_fences() -> void:
	var post := BoxMesh.new()
	post.size = Vector3(0.06, FENCE_HEIGHT, 0.06)
	var wire := _wire_mesh()
	var wire_material := StandardMaterial3D.new()
	wire_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	wire_material.albedo_color = Color(0.05, 0.05, 0.06)
	for cell: Vector2i in _walls:
		if not _walls[cell].fence:
			continue
		var base := _grid.cell_to_world(cell) + Vector3(0, _walls[cell].top + CAP_THICKNESS - 0.02, 0)
		_add_mesh(post, Surfaces.named("metal"), base + Vector3(0, FENCE_HEIGHT / 2.0, 0))
		for direction: Vector2i in [Vector2i(1, 0), Vector2i(0, 1)]:
			var next := cell + direction
			if _walls.has(next) and _walls[next].fence:
				var span := _add_mesh(wire, wire_material, base)
				span.rotation.y = 0.0 if direction.x == 1 else -PI / 2.0
				span.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


# Air conditioners and vents on the building's roof, away from its edges, so it has a skyline of
# its own from above. Each tile's hash decides, so the roof comes out the same every time.
func _build_rooftops() -> void:
	for cell: Vector2i in _walls:
		if not map.is_building(cell) or Grid.DIRECTIONS.any(func(d: Vector2i) -> bool: return not map.is_building(cell + d)):
			continue
		var roll := hash(cell)
		if roll % 5 != 0:
			continue
		var size := Vector3(0.7 + (roll >> 4) % 5 * 0.15, 0.5 + (roll >> 8) % 4 * 0.2, 0.7 + (roll >> 12) % 5 * 0.15)
		var roof := _grid.cell_to_world(cell) + Vector3(0, _walls[cell].top + CAP_THICKNESS - 0.02, 0)
		_add_box(size, Surfaces.named("metal"), roof + Vector3(0, size.y / 2.0, 0))


# Lines along +x for one tile: straight wires, and a coil of razor wire along the top.
func _wire_mesh() -> ArrayMesh:
	var points := PackedVector3Array()
	for height: float in WIRE_HEIGHTS:
		points.append(Vector3(0, height, 0))
		points.append(Vector3(GridView.CELL, height, 0))
	var steps := RAZOR_LOOPS * 10
	var center := FENCE_HEIGHT - RAZOR_RADIUS
	for i in steps:
		for end: int in [i, i + 1]:
			var turn := TAU * RAZOR_LOOPS * end / steps
			points.append(Vector3(GridView.CELL * end / steps, center + cos(turn) * RAZOR_RADIUS, sin(turn) * RAZOR_RADIUS))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	return mesh


# Neon that lights its surroundings: a short-range light off the open faces of every third wall
# tile, so the glow pools on the wet ground in front of it without flooding the whole yard.
func _add_neon_lights(cell: Vector2i, y: float) -> void:
	if (cell.x + cell.y) % 3 != 0:
		return
	for direction in Grid.DIRECTIONS:
		var beside := cell + direction
		if not map.in_bounds(beside) or map.is_wall(beside):
			continue
		var light := OmniLight3D.new()
		light.light_color = NEON
		light.light_energy = NEON_LIGHT_ENERGY
		light.omni_range = NEON_LIGHT_RANGE
		light.light_specular = 1.0
		light.position = _grid.cell_to_world(cell) + Vector3(direction.x, 0, direction.y) * (GridView.CELL / 2.0 + 0.4) + Vector3(0, y, 0)
		add_child(light)


# A wide cone straight down from the pole's head, with shadows, and a beam that shows in the haze.
# Its reflection is kept low, so wet ground under it shines without a blinding spot.
func _add_floodlight(at: Vector3) -> void:
	var light := SpotLight3D.new()
	light.light_color = FLOODLIGHT
	light.light_energy = 7.0
	light.light_specular = 0.15
	light.light_volumetric_fog_energy = 2.0
	light.spot_range = 18.0
	light.spot_angle = 62.0
	light.spot_attenuation = 0.8
	light.shadow_enabled = true
	add_child(light)
	light.look_at_from_position(at + Vector3(0, FLOODLIGHT_HEAD_Y, 0), at + Vector3(0.01, 0, 0.3))


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
	_add_mesh(pole, Surfaces.named("metal"), at + Vector3(0, height / 2.0, 0))


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
