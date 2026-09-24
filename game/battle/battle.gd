extends Node3D

const MOVE_COLOR := Color(0.3, 0.6, 1.0, 0.35)
const ATTACK_COLOR := Color(1.0, 0.3, 0.3, 0.5)
const FOG_COLOR := Color(0.02, 0.02, 0.06, 0.68)
const GHOST_ALPHA := 0.3
const ENEMY_TURN_PAUSE := 0.35
const CHOICE_LAYERS: Array[String] = ["move", "attack"]

@export var map: MapData
@export var operators: Array[UnitDef] = []
@export var guard: UnitDef
@export var turret: UnitDef

var state: BattleState
var _views := {}
var _ghosts := {}
var _busy := true

@onready var _grid: GridView = $GridView
@onready var _camera_rig: CameraRig = $CameraRig
@onready var _hover: MeshInstance3D = $HoverHighlight
@onready var _active_ring: MeshInstance3D = $ActiveRing
@onready var _hud: Hud = $Hud


func _ready() -> void:
	state = BattleState.new(map, operators, guard, turret)
	_grid.build(state)
	for unit in state.units:
		var view := UnitView.new()
		add_child(view)
		view.setup(unit, _grid.cell_to_world(unit.cell))
		_views[unit.id] = view
		if not unit.is_player():
			_ghosts[unit.id] = _make_ghost(unit)
	_camera_rig.setup(_grid.center(), _grid.extent())
	_hud.end_turn_pressed.connect(_end_player_turn)
	_hud.undo_pressed.connect(_undo_move)
	_refresh_fog()
	_next_turn()


func _process(_delta: float) -> void:
	var active := state.active
	_active_ring.visible = active != null and _views[active.id].visible
	if active:
		_active_ring.position = _views[active.id].position + Vector3(0, 0.02, 0)
	_update_hover()


func _unhandled_input(event: InputEvent) -> void:
	if _busy:
		return
	if event.is_action_pressed("end_turn"):
		_end_player_turn()
	elif event.is_action_pressed("undo_move"):
		_undo_move()
	else:
		var click := event as InputEventMouseButton
		if click and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
			var cell: Variant = _cell_at(click.position)
			if cell != null:
				_click(cell)


func _next_turn() -> void:
	_busy = true
	_clear_choices()
	var unit := state.begin_next_turn()
	_hud.show_turn(state)
	if unit == null:
		_hud.show_result(state.winner() == BattleState.Winner.PLAYER)
		return
	if unit.is_player():
		_camera_rig.keep_in_view(_views[unit.id].position)
		_show_options()
		_busy = false
		return
	var was_seen := state.player_sees(unit)
	var events := EnemyAI.take_turn(state, unit)
	if was_seen or _any_seen(events):
		_camera_rig.keep_in_view(_views[unit.id].position)
		await get_tree().create_timer(ENEMY_TURN_PAUSE, false).timeout
	await _play(events)
	_next_turn()


func _show_options() -> void:
	var unit := state.active
	_clear_choices()
	var moves := state.destinations(unit)
	moves.erase(unit.cell)
	_grid.set_overlay("move", moves, MOVE_COLOR)
	var targets := state.attack_targets(unit, unit.cell).map(func(target: Unit) -> Vector2i: return target.cell)
	_grid.set_overlay("attack", targets, ATTACK_COLOR)
	_hud.show_active(state)


func _click(cell: Vector2i) -> void:
	var unit := state.active
	var target := state.unit_at(cell)
	if target and state.player_sees(target) and state.can_attack(unit, target, unit.cell):
		_busy = true
		_clear_choices()
		await _play(state.attack(unit, target))
		_next_turn()
	elif cell != unit.cell and state.destinations(unit).has(cell):
		_busy = true
		_clear_choices()
		await _play(state.move(unit, cell))
		_show_options()
		_busy = false


func _end_player_turn() -> void:
	if not _busy:
		_next_turn()


func _undo_move() -> void:
	var unit := state.active
	if _busy or not state.can_undo(unit):
		return
	state.undo_move(unit)
	_views[unit.id].position = _grid.cell_to_world(unit.cell)
	_refresh_fog()
	_show_options()


func _play(events: Array[Dictionary]) -> void:
	for event in events:
		var unit: Unit = event["unit"]
		var view: UnitView = _views[unit.id]
		match event["type"]:
			"move":
				await _walk(unit, event["path"])
			"blocked":
				_hud.log_line("%s ran into %s!" % [unit.display_name, event["by"].display_name])
			"attack":
				var target: Unit = event["target"]
				var target_view: UnitView = _views[target.id]
				_hud.log_line("%s hits %s for %d" % [unit.display_name, target.display_name, event["damage"]])
				await view.lunge(target_view.position)
				if Grid.distance(unit.cell, target.cell) > 1:
					_tracer(view.position, target_view.position)
				target_view.take_hit(event["damage"])
				await get_tree().create_timer(0.3, false).timeout
			"downed":
				view.set_downed()
				_hud.log_line("%s is down" % unit.display_name)
			"alert":
				_hud.log_line("%s spotted an Operator" % unit.display_name)
			"lost":
				if state.player_sees(unit):
					_hud.log_line("%s lost track" % unit.display_name)
	for unit_view: UnitView in _views.values():
		unit_view.refresh()
	_refresh_fog()
	_hud.show_turn(state)


func _walk(unit: Unit, path: Array) -> void:
	var view: UnitView = _views[unit.id]
	var points: Array[Vector3] = []
	var shown: Array[bool] = []
	for cell in path:
		points.append(_grid.cell_to_world(cell))
		shown.append(unit.is_player() or state.visible_cells.has(cell))
	if view.visible or shown.has(true):
		if _ghosts.has(unit.id):
			_ghosts[unit.id].hide()
		await view.walk(points, shown)
	elif not points.is_empty():
		view.position = points.back()


func _any_seen(events: Array[Dictionary]) -> bool:
	for event in events:
		if event["type"] == "attack":
			return true
		if event["type"] == "move":
			for cell in event["path"]:
				if state.visible_cells.has(cell):
					return true
	return false


func _refresh_fog() -> void:
	var fog: Array[Vector2i] = []
	for y in state.map.size.y:
		for x in state.map.size.x:
			var cell := Vector2i(x, y)
			if not state.map.is_wall(cell) and not state.visible_cells.has(cell):
				fog.append(cell)
	_grid.set_overlay("fog", fog, FOG_COLOR, GridView.FOG_Y)
	for id in _ghosts:
		var unit: Unit = state.units[id]
		var view: UnitView = _views[id]
		view.visible = unit.is_down() or state.player_sees(unit)
		var ghost: Node3D = _ghosts[id]
		ghost.visible = not view.visible and state.known.has(id)
		if ghost.visible:
			ghost.position = _grid.cell_to_world(state.known[id])


func _make_ghost(unit: Unit) -> Node3D:
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.26
	capsule.height = 1.1
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(unit.def.color, GHOST_ALPHA)
	var body := MeshInstance3D.new()
	body.mesh = capsule
	body.material_override = material
	body.position.y = 0.55
	var label := UnitView.make_label(36, 1.55)
	label.text = "%s\nlast seen" % unit.display_name
	label.modulate = Color(1, 1, 1, 0.6)
	var ghost := Node3D.new()
	ghost.add_child(body)
	ghost.add_child(label)
	ghost.visible = false
	add_child(ghost)
	return ghost


func _clear_choices() -> void:
	for layer in CHOICE_LAYERS:
		_grid.clear_overlay(layer)


func _tracer(from: Vector3, to: Vector3) -> void:
	var start := from + Vector3(0, 0.8, 0)
	var end := to + Vector3(0, 0.8, 0)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.05, 0.05, start.distance_to(end))
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1.0, 0.95, 0.6)
	var beam := MeshInstance3D.new()
	beam.mesh = mesh
	beam.material_override = material
	add_child(beam)
	beam.look_at_from_position((start + end) / 2.0, end, Vector3.UP)
	var tween := create_tween()
	tween.tween_property(material, "albedo_color:a", 0.0, 0.25)
	tween.tween_callback(beam.queue_free)


func _update_hover() -> void:
	var cell: Variant = _cell_at(get_viewport().get_mouse_position())
	_hover.visible = cell != null
	if cell == null:
		_hud.set_hover("")
		return
	_hover.position = _grid.cell_to_world(cell) + Vector3(0, 0.02, 0)
	_hud.set_hover(_describe(cell))


func _describe(cell: Vector2i) -> String:
	var text := "Tile %d, %d" % [cell.x, cell.y]
	var unit := state.unit_at(cell)
	if unit and state.player_sees(unit):
		text += "    %s  HP %d/%d" % [unit.display_name, unit.hp, unit.def.max_hp]
		var active := state.active
		if not _busy and active and active.is_player() and state.can_attack(active, unit, active.cell):
			text += "    Attack: -%d" % active.def.damage
		return text
	for id in state.known:
		var other: Unit = state.units[id]
		if state.known[id] == cell and not state.player_sees(other):
			return text + "    %s was last seen here" % other.display_name
	var node := state.map.node_at(cell)
	if node != "":
		text += "    " + state.map.node_kind(node).capitalize()
	if not state.visible_cells.has(cell):
		text += "    (no vision)"
	return text


func _cell_at(screen_position: Vector2) -> Variant:
	var camera := get_viewport().get_camera_3d()
	var hit: Variant = Plane(Vector3.UP, 0.0).intersects_ray(
		camera.project_ray_origin(screen_position), camera.project_ray_normal(screen_position)
	)
	if hit == null:
		return null
	var cell := _grid.world_to_cell(hit)
	return cell if state.map.in_bounds(cell) else null
