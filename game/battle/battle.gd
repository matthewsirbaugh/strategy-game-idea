extends Node3D

const MOVE_COLOR := Color(0.3, 0.6, 1.0, 0.35)
const ATTACK_COLOR := Color(1.0, 0.3, 0.3, 0.5)
const NETWORK_COLOR := Color(0.2, 0.85, 1.0, 0.5)
const AGENT_NODE_COLOR := Color(1.0, 1.0, 1.0, 0.45)
const FOG_COLOR := Color(0.02, 0.02, 0.06, 0.68)
const GHOST_ALPHA := 0.3
const ENEMY_TURN_PAUSE := 0.35
const HOP_SECONDS := 0.15
const AGENT_Y := 1.9
const CHOICE_LAYERS: Array[String] = ["move", "attack", "network", "agent"]

@export var map: MapData
@export var operators: Array[UnitDef] = []
@export var guard: UnitDef
@export var turret: UnitDef
@export var node_defs: Array[NodeDef] = []

var state: BattleState
var _views := {}
var _ghosts := {}
var _agents := {}
var _tethers := {}
var _busy := true

@onready var _grid: GridView = $GridView
@onready var _camera_rig: CameraRig = $CameraRig
@onready var _hover: MeshInstance3D = $HoverHighlight
@onready var _active_ring: MeshInstance3D = $ActiveRing
@onready var _hud: Hud = $Hud


func _ready() -> void:
	state = BattleState.new(map, operators, guard, turret, node_defs)
	_grid.build(state, operators[0].tether_range)
	for unit in state.units:
		var view := UnitView.new()
		add_child(view)
		view.setup(unit, _grid.cell_to_world(unit.cell))
		_views[unit.id] = view
		if unit.is_player():
			_agents[unit.id] = _make_agent(unit)
			_tethers[unit.id] = GridView.make_beam(0.03, Color(unit.def.color, 0.8))
			add_child(_tethers[unit.id])
		else:
			_ghosts[unit.id] = _make_ghost(unit)
	_camera_rig.setup(_grid.center(), _grid.extent())
	_hud.end_turn_pressed.connect(_end_player_turn)
	_hud.undo_pressed.connect(_undo_move)
	_hud.hack_pressed.connect(_hack)
	_hud.compact_pressed.connect(_compact)
	_hud.door_pressed.connect(_toggle_door)
	_refresh_fog()
	_next_turn()


func _process(_delta: float) -> void:
	var active := state.active
	_active_ring.visible = active != null and _views[active.id].visible
	if active:
		_active_ring.position = _views[active.id].position + Vector3(0, 0.02, 0)
	for id in _tethers:
		var unit: Unit = state.units[id]
		var tether: MeshInstance3D = _tethers[id]
		if unit.entry == "" or unit.is_down():
			tether.visible = false
		else:
			GridView.place_beam(tether, _views[id].position + Vector3(0, 0.9, 0), _grid.node_position(unit.entry, 0.8))
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
	if state.phase == BattleState.Phase.AGENT:
		var nodes := state.agent_destinations(unit).map(func(id: String) -> Vector2i: return state.map.node_cell(id))
		_grid.set_overlay("network", nodes, NETWORK_COLOR)
		_grid.set_overlay("agent", [state.map.node_cell(unit.agent_node)], AGENT_NODE_COLOR)
	else:
		var moves := state.destinations(unit)
		moves.erase(unit.cell)
		_grid.set_overlay("move", moves, MOVE_COLOR)
		var targets := state.attack_targets(unit, unit.cell).map(func(target: Unit) -> Vector2i: return target.cell)
		_grid.set_overlay("attack", targets, ATTACK_COLOR)
	_hud.show_active(state)


func _click(cell: Vector2i) -> void:
	var unit := state.active
	if state.phase == BattleState.Phase.AGENT:
		var id := state.map.node_at(cell)
		if id == unit.agent_node:
			if state.can_hack(unit):
				_hack()
			elif state.can_toggle_door(unit):
				_toggle_door()
		elif id != "" and state.agent_destinations(unit).has(id):
			_agent_action(state.agent_move(unit, id))
		return
	var target := state.unit_at(cell)
	if target and state.player_sees(target) and state.can_attack(unit, target, unit.cell):
		_busy = true
		_clear_choices()
		await _play(state.attack(unit, target))
		_finish_human_phase()
	elif cell != unit.cell and state.destinations(unit).has(cell):
		_busy = true
		_clear_choices()
		await _play(state.move(unit, cell))
		_show_options()
		_busy = false


func _finish_human_phase() -> void:
	_busy = true
	_clear_choices()
	await _play(state.end_human_phase(state.active))
	if state.phase == BattleState.Phase.AGENT:
		_show_options()
		_busy = false
	else:
		_next_turn()


func _end_player_turn() -> void:
	if _busy:
		return
	if state.phase == BattleState.Phase.HUMAN:
		_finish_human_phase()
	else:
		_next_turn()


func _undo_move() -> void:
	var unit := state.active
	if _busy or not state.can_undo(unit):
		return
	state.undo_move(unit)
	_views[unit.id].position = _grid.cell_to_world(unit.cell)
	_refresh_agents()
	_refresh_fog()
	_show_options()


func _hack() -> void:
	if _agent_ready() and state.can_hack(state.active):
		_agent_action(state.hack(state.active))


func _compact() -> void:
	if _agent_ready() and state.active.context > 0:
		_agent_action(state.compact(state.active))


func _toggle_door() -> void:
	if _agent_ready() and state.can_toggle_door(state.active):
		_agent_action(state.toggle_door(state.active))


func _agent_ready() -> bool:
	return not _busy and state.phase == BattleState.Phase.AGENT


func _agent_action(events: Array[Dictionary]) -> void:
	_busy = true
	_clear_choices()
	await _play(events)
	_next_turn()


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
			"connect":
				_refresh_agents()
				_hud.log_line("%s's AI connects" % unit.display_name)
			"disconnect":
				_refresh_agents()
				_hud.log_line("%s left the access point's range. The AI was pulled out" % unit.display_name)
			"agent_move":
				await _move_agent(unit, event["path"])
			"hack":
				var node: String = event["node"]
				_float_text(_grid.node_position(node, 1.8), "+%d" % event["points"], GridView.NODE_COLORS["access"])
				_hud.log_line("%s's AI hacks the %s: +%d" % [unit.display_name, state.node_def(node).display_name.to_lower(), event["points"]])
				_grid.update_nodes(state)
				await get_tree().create_timer(0.35, false).timeout
			"breach":
				_hud.log_line("%s breached" % state.node_def(event["node"]).display_name)
			"compact":
				_hud.log_line("%s's AI compacts its context: %d to %d" % [unit.display_name, event["before"], unit.context])
			"door":
				_hud.log_line("Door %s" % ("opened" if event["open"] else "locked"))
	for unit_view: UnitView in _views.values():
		unit_view.refresh()
	_grid.update_nodes(state)
	_refresh_agents()
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


func _move_agent(unit: Unit, path: Array) -> void:
	var orb: MeshInstance3D = _agents[unit.id]
	var tween := create_tween()
	for id in path:
		tween.tween_property(orb, "position", _agent_position(unit, id), HOP_SECONDS)
	await tween.finished


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


func _refresh_agents() -> void:
	for id in _agents:
		var unit: Unit = state.units[id]
		var orb: MeshInstance3D = _agents[id]
		orb.visible = unit.agent_node != ""
		if orb.visible:
			orb.position = _agent_position(unit, unit.agent_node)


# Side by side, so several AIs on one node stay readable.
func _agent_position(unit: Unit, node: String) -> Vector3:
	return _grid.node_position(node, AGENT_Y) + Vector3((unit.id - 1) * 0.3, 0, 0)


func _make_agent(unit: Unit) -> MeshInstance3D:
	var sphere := SphereMesh.new()
	sphere.radius = 0.17
	sphere.height = 0.34
	var material := StandardMaterial3D.new()
	material.albedo_color = unit.def.color
	material.emission_enabled = true
	material.emission = unit.def.color
	material.emission_energy_multiplier = 1.5
	var orb := MeshInstance3D.new()
	orb.mesh = sphere
	orb.material_override = material
	orb.visible = false
	add_child(orb)
	return orb


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


func _float_text(at: Vector3, text: String, color: Color) -> void:
	var label := UnitView.make_label(56, 0.0)
	label.text = text
	label.modulate = color
	label.position = at
	add_child(label)
	var tween := create_tween()
	tween.tween_property(label, "position:y", at.y + 0.8, 0.7)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.7)
	tween.tween_callback(label.queue_free)


func _tracer(from: Vector3, to: Vector3) -> void:
	var beam := GridView.make_beam(0.05, Color(1.0, 0.95, 0.6))
	add_child(beam)
	GridView.place_beam(beam, from + Vector3(0, 0.8, 0), to + Vector3(0, 0.8, 0))
	var tween := create_tween()
	tween.tween_property(beam.material_override, "albedo_color:a", 0.0, 0.25)
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
	else:
		for id in state.known:
			var other: Unit = state.units[id]
			if state.known[id] == cell and not state.player_sees(other):
				text += "    %s was last seen here" % other.display_name
	var node := state.map.node_at(cell)
	if node != "":
		var def := state.node_def(node)
		text += "    " + def.display_name
		if state.breached.has(node):
			text += " (breached)"
		elif def.goal > 0:
			text += "  breach %d/%d, context cost %d" % [state.breach.get(node, 0), def.goal, def.context_cost]
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
