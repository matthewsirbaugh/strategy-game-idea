extends Node3D

const MOVE_COLOR := Color(0.3, 0.6, 1.0, 0.35)
const ATTACK_COLOR := Color(1.0, 0.3, 0.3, 0.5)
const ENEMY_TURN_PAUSE := 0.35

@export var map: MapData
@export var operators: Array[UnitDef] = []
@export var guard: UnitDef
@export var turret: UnitDef

var state: BattleState
var _views := {}
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
	_camera_rig.setup(_grid.center(), _grid.extent())
	_hud.end_turn_pressed.connect(_end_player_turn)
	_hud.undo_pressed.connect(_undo_move)
	_next_turn()


func _process(_delta: float) -> void:
	var active := state.active
	_active_ring.visible = active != null
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
	_grid.clear_overlays()
	var unit := state.begin_next_turn()
	_hud.show_turn(state)
	if unit == null:
		_hud.show_result(state.winner() == BattleState.Winner.PLAYER)
		return
	_camera_rig.keep_in_view(_views[unit.id].position)
	if unit.is_player():
		_show_options()
		_busy = false
		return
	await get_tree().create_timer(ENEMY_TURN_PAUSE, false).timeout
	await _play(EnemyAI.take_turn(state, unit))
	_next_turn()


func _show_options() -> void:
	var unit := state.active
	_grid.clear_overlays()
	var moves := state.destinations(unit)
	moves.erase(unit.cell)
	_grid.set_overlay("move", moves, MOVE_COLOR)
	var targets := state.attack_targets(unit, unit.cell).map(func(target: Unit) -> Vector2i: return target.cell)
	_grid.set_overlay("attack", targets, ATTACK_COLOR)
	_hud.show_active(unit)


func _click(cell: Vector2i) -> void:
	var unit := state.active
	var target := state.unit_at(cell)
	if target and state.can_attack(unit, target, unit.cell):
		_busy = true
		_grid.clear_overlays()
		await _play(state.attack(unit, target))
		_next_turn()
	elif cell != unit.cell and state.destinations(unit).has(cell):
		_busy = true
		_grid.clear_overlays()
		await _play(state.move(unit, cell))
		_show_options()
		_busy = false


func _end_player_turn() -> void:
	if not _busy:
		_next_turn()


func _undo_move() -> void:
	var unit := state.active
	if _busy or not unit.moved or unit.acted:
		return
	state.undo_move(unit)
	_views[unit.id].position = _grid.cell_to_world(unit.cell)
	_show_options()


func _play(events: Array[Dictionary]) -> void:
	for event in events:
		var unit: Unit = event["unit"]
		var view: UnitView = _views[unit.id]
		match event["type"]:
			"move":
				var points: Array[Vector3] = []
				for cell in event["path"]:
					points.append(_grid.cell_to_world(cell))
				await view.walk(points)
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
	for unit_view: UnitView in _views.values():
		unit_view.refresh()
	_hud.show_turn(state)


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
	if unit:
		text += "    %s  HP %d/%d" % [unit.display_name, unit.hp, unit.def.max_hp]
		var active := state.active
		if not _busy and active and active.is_player() and state.can_attack(active, unit, active.cell):
			text += "    Attack: -%d" % active.def.damage
		return text
	var node := state.map.node_at(cell)
	if node != "":
		text += "    " + state.map.node_kind(node).capitalize()
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
