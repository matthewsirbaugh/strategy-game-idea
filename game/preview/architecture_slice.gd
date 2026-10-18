extends Node3D
## The architecture slice: one corner of the research park built from the kit in
## assets/architecture/, under the battle's lighting and seen from the battle camera.
## Run with `godot --path game res://preview/architecture_slice.tscn`. Q and E turn, the wheel
## zooms, right-drag orbits. `-- --capture <file.png>` saves one frame and quits;
## `--distance <m>` sets the zoom first.

const CELL := 1.5
const STOREY := 4.5
const RISE := 2.25
const WIDE := 8  # the building, in tiles
const DEEP := 6
const KIT := "res://assets/architecture/%s/%s.glb"
const PROP := "res://assets/props/%s/%s.glb"
const OPERATORS := ["operator_protagonist", "operator_writer", "operator_developer"]

var _yaw := 45.0
var _pitch := 50.0
var _distance := 32.0
var _scenes := {}

@onready var _rig: Node3D = $Rig
@onready var _camera: Camera3D = $Rig/Camera3D


func _ready() -> void:
	_build_building()
	_build_stair()
	_build_skybridge()
	_build_roof()
	_build_ground()
	_light_interiors()
	_place_operators()
	_update_camera()
	var args := OS.get_cmdline_user_args()
	var zoom := args.find("--distance")
	if zoom >= 0 and zoom + 1 < args.size():
		_distance = float(args[zoom + 1])
		_update_camera()
	var at := args.find("--capture")
	if at >= 0 and at + 1 < args.size():
		_capture(args[at + 1])


func _piece(id: String, at: Vector3, yaw := 0.0, folder := KIT) -> Node3D:
	if not _scenes.has(id):
		_scenes[id] = load(folder % [id, id])
	var node: Node3D = _scenes[id].instantiate()
	node.position = at
	node.rotation_degrees.y = yaw
	add_child(node)
	return node


# A wall bay on one side of the building: i counts tiles along that side, west to east or
# north to south.
func _wall(id: String, side: String, i: int, storey: int) -> void:
	var y := storey * STOREY
	var along := (i + 0.5) * CELL
	match side:
		"south": _piece(id, Vector3(along, y, DEEP * CELL), 0)
		"north": _piece(id, Vector3(along, y, 0), 180)
		"east": _piece(id, Vector3(WIDE * CELL, y, along), 90)
		"west": _piece(id, Vector3(0, y, along), -90)


func _build_building() -> void:
	for storey in 2:
		for i in WIDE:
			_wall(("wall_door" if i == 3 else "wall_glass") if storey == 0 else "wall_ribbon", "south", i, storey)
			_wall("wall_panel", "north", i, storey)
		for i in DEEP:
			var east := "wall_panel"
			if storey == 1 and i < 2:
				east = "wall_header"  # the skybridge's opening
			elif storey == 1 and i == DEEP - 1:
				east = "wall_door"  # from the stair's landing
			_wall(east, "east", i, storey)
			_wall("wall_panel", "west", i, storey)
		for corner in [Vector2(0, 0), Vector2(WIDE, 0), Vector2(0, DEEP), Vector2(WIDE, DEEP)]:
			_piece("corner_post", Vector3(corner.x * CELL, storey * STOREY, corner.y * CELL))
	for x in WIDE:
		for z in DEEP:
			var at := Vector3((x + 0.5) * CELL, 0, (z + 0.5) * CELL)
			_piece("floor_slab", at + Vector3(0, STOREY - 0.3, 0))
			_piece("floor_slab", at + Vector3(0, 2 * STOREY - 0.3, 0))


# A switchback up the east side: two lanes, flights between z 4.5 and 7.5, landings north and
# south of them, arriving on the upper floor's door and then the roof.
func _build_stair() -> void:
	var lane_a := WIDE * CELL + CELL / 2
	var lane_b := lane_a + CELL
	var flights_z := 4.0 * CELL
	var north_z := 2.5 * CELL
	var south_z := 5.5 * CELL
	for level in 4:
		var y := level * RISE
		var climbing_north := level % 2 == 0
		_piece("stair_flight", Vector3(lane_a if climbing_north else lane_b, y, flights_z), 0 if climbing_north else 180)
		var landing_z := north_z if climbing_north else south_z
		for lane in [lane_a, lane_b]:
			_piece("stair_landing", Vector3(lane, y + RISE - 0.1, landing_z))
		_piece("stair_rail", Vector3(lane_b, y + RISE - 0.1, landing_z), 90)
		for lane in [lane_a, lane_b]:
			_piece("stair_rail", Vector3(lane, y + RISE - 0.1, landing_z), 180 if climbing_north else 0)
		for post in level + 1:
			_piece("steel_post", Vector3(lane_b + CELL / 2 - 0.08, post * RISE - 0.1, landing_z + (-1 if climbing_north else 1) * (CELL / 2 - 0.08)))


func _build_skybridge() -> void:
	for span in 3:
		_piece("skybridge_span", Vector3(WIDE * CELL + (span + 0.5) * CELL, STOREY, CELL), 90)
	for z in [0.15, 2 * CELL - 0.15]:
		for post in 2:
			_piece("steel_post", Vector3(WIDE * CELL + 3 * CELL - 0.15, post * RISE, z))


func _build_roof() -> void:
	var top := 2 * STOREY
	for i in WIDE:
		_wall("parapet", "south", i, 2)
		_wall("parapet", "north", i, 2)
	for i in DEEP:
		if i != DEEP - 1:  # the stair arrives here
			_wall("parapet", "east", i, 2)
		_wall("parapet", "west", i, 2)
	for unit in [Vector3(2.5, 0, 1.5), Vector3(5.0, 0, 1.5)]:
		_piece("rooftop_unit", unit * Vector3(CELL, 1, CELL) + Vector3(0, top, 0), 0, PROP)
	for i in 3:
		_piece("solar_rack", Vector3((1.0 + i * 2.2) * CELL, top, 3.0 * CELL), 0, PROP)
	var green := MeshInstance3D.new()
	var bed := BoxMesh.new()
	bed.size = Vector3(WIDE * CELL - 1.2, 0.15, CELL)
	green.mesh = bed
	var moss := StandardMaterial3D.new()
	moss.albedo_color = Color(0.13, 0.2, 0.1)
	moss.roughness = 0.9
	green.material_override = moss
	green.position = Vector3(WIDE * CELL / 2, top + 0.075, 4.5 * CELL)
	add_child(green)
	for x in [1.0, 7.0]:
		_piece("planter", Vector3(x * CELL, top, 5.5 * CELL), 0, PROP)


func _build_ground() -> void:
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(60, 60)
	ground.mesh = plane
	var wet := StandardMaterial3D.new()
	wet.albedo_color = Color(0.3, 0.3, 0.29)
	wet.roughness = 0.18
	ground.material_override = wet
	ground.position = Vector3(WIDE * CELL / 2, 0, DEEP * CELL / 2)
	add_child(ground)
	for i in 4:
		var x := (1.0 + i * 2.0) * CELL
		_piece("uplight", Vector3(x, 0, DEEP * CELL + 0.8), 0, PROP)
		var wash := SpotLight3D.new()
		wash.light_color = Color(1.0, 0.72, 0.42)
		wash.light_energy = 8.0
		wash.spot_range = 10.0
		wash.spot_angle = 35.0
		wash.shadow_enabled = true
		wash.position = Vector3(x, 0.1, DEEP * CELL + 0.8)
		add_child(wash)
		wash.look_at(Vector3(x, 6.0, DEEP * CELL))
	_piece("pole_light", Vector3(-2.0, 0, DEEP * CELL + 4.0), 0, PROP)
	var lamp := SpotLight3D.new()
	lamp.light_color = Color(1.0, 0.8, 0.58)
	lamp.light_energy = 6.0
	lamp.spot_range = 9.0
	lamp.spot_angle = 55.0
	lamp.position = Vector3(-1.75, 5.0, DEEP * CELL + 4.0)
	lamp.rotation_degrees.x = -90
	add_child(lamp)
	_piece("bench", Vector3(3.0, 0, DEEP * CELL + 3.0), 0, PROP)


# Greybox interiors: a lit ceiling and a few lab benches seen through the glass.
func _light_interiors() -> void:
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color(1.0, 0.86, 0.68)
	glow.emission_enabled = true
	glow.emission = Color(1.0, 0.82, 0.6)
	glow.emission_energy_multiplier = 1.6
	for storey in 2:
		var ceiling := MeshInstance3D.new()
		var panel := BoxMesh.new()
		panel.size = Vector3(WIDE * CELL - 0.6, 0.04, DEEP * CELL - 0.6)
		ceiling.mesh = panel
		ceiling.material_override = glow
		ceiling.position = Vector3(WIDE * CELL / 2, (storey + 1) * STOREY - 0.34, DEEP * CELL / 2)
		add_child(ceiling)
		for x in [0.3, 0.7]:
			var fill := OmniLight3D.new()
			fill.light_color = Color(1.0, 0.82, 0.62)
			fill.light_energy = 5.0
			fill.omni_range = 9.0
			fill.position = Vector3(WIDE * CELL * x, storey * STOREY + 3.2, DEEP * CELL * 0.6)
			add_child(fill)
	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.72, 0.72, 0.7)
	floor_mat.roughness = 0.35
	var lobby := MeshInstance3D.new()
	var slab := BoxMesh.new()
	slab.size = Vector3(WIDE * CELL - 0.3, 0.04, DEEP * CELL - 0.3)
	lobby.mesh = slab
	lobby.material_override = floor_mat
	lobby.position = Vector3(WIDE * CELL / 2, 0.02, DEEP * CELL / 2)
	add_child(lobby)
	var bench_mat := StandardMaterial3D.new()
	bench_mat.albedo_color = Color(0.75, 0.76, 0.77)
	for x in [2.5, 6.0, 9.5]:
		var bench := MeshInstance3D.new()
		var top := BoxMesh.new()
		top.size = Vector3(2.4, 0.9, 0.8)
		bench.mesh = top
		bench.material_override = bench_mat
		bench.position = Vector3(x, 0.45, 6.5)
		add_child(bench)
	var bridge_light := OmniLight3D.new()
	bridge_light.light_color = Color(1.0, 0.82, 0.62)
	bridge_light.light_energy = 2.0
	bridge_light.omni_range = 5.0
	bridge_light.position = Vector3(WIDE * CELL + 2.0, STOREY + 3.0, CELL)
	add_child(bridge_light)


func _place_operators() -> void:
	var spots := [Vector3(4.0, 0, 7.4), Vector3(5.2, 0, 7.9), Vector3(9.0, 0, 7.2)]
	for i in OPERATORS.size():
		var id: String = OPERATORS[i]
		var path := "res://assets/units/%s/%s.glb" % [id, id]
		if not ResourceLoader.exists(path):
			continue
		var unit := ToonModel.new()
		add_child(unit)
		unit.build(load(path))
		unit.position = spots[i] + Vector3(0, 2 * STOREY, 0)
		unit.rotation_degrees.y = 30.0 + i * 50.0
		unit.play("Neutral")


func _update_camera() -> void:
	_rig.position = Vector3(WIDE * CELL / 2 + 2.0, 4.5, DEEP * CELL / 2)
	_rig.rotation_degrees.y = _yaw
	var pitch := deg_to_rad(_pitch)
	_camera.position = Vector3(0, sin(pitch), cos(pitch)) * _distance
	_camera.rotation = Vector3(-pitch, 0, 0)


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key and key.pressed and key.keycode in [KEY_Q, KEY_E]:
		_yaw += -15.0 if key.keycode == KEY_Q else 15.0
	var button := event as InputEventMouseButton
	if button and button.pressed and button.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		_distance = clampf(_distance * (0.9 if button.button_index == MOUSE_BUTTON_WHEEL_UP else 1.1), 6.0, 60.0)
	var motion := event as InputEventMouseMotion
	if motion and motion.button_mask & MOUSE_BUTTON_MASK_RIGHT:
		_yaw -= motion.relative.x * 0.3
		_pitch = clampf(_pitch + motion.relative.y * 0.3, 10.0, 85.0)
	_update_camera()


func _capture(path: String) -> void:
	for i in 12:
		await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(path)
	get_tree().quit()
