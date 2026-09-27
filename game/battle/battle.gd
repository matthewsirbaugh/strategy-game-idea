extends Node3D

# A turn starts with only the active unit highlighted. Clicking it (or its AI, in the network phase)
# opens the action menu; Move, Attack and network moves then ask for a target, and right-click steps
# back to the menu.
enum Mode { IDLE, MENU, MOVE, TARGET, NODE }

const MOVE_COLOR := Color(0.3, 0.6, 1.0, 0.35)
const ATTACK_COLOR := Color(1.0, 0.3, 0.3, 0.5)
const FOG_COLOR := Color(0.02, 0.02, 0.06, 0.68)
const GHOST_ALPHA := 0.3
const ENEMY_TURN_PAUSE := 0.35
const UNIT_HEIGHT := 1.1
const PICK_RADIUS := 0.4
const CHOICE_LAYERS: Array[String] = ["move", "attack"]

@export var map: MapData
@export var operators: Array[UnitDef] = []
@export var guard: UnitDef
@export var turret: UnitDef
@export var node_defs: Array[NodeDef] = []

var state: BattleState
var _views := {}
var _ghosts := {}
var _tethers := {}
var _busy := true
var _mode := Mode.IDLE
var _network_shown := false
var _network_moving := false

@onready var _grid: GridView = $GridView
@onready var _network: NetworkView = $NetworkView
@onready var _camera_rig: CameraRig = $CameraRig
@onready var _hover: MeshInstance3D = $HoverHighlight
@onready var _active_ring: MeshInstance3D = $ActiveRing
@onready var _hud: Hud = $Hud


func _ready() -> void:
	state = BattleState.new(map, operators, guard, turret, node_defs)
	if not state.errors.is_empty():
		set_process(false)
		_hud.show_errors(state.errors)
		return
	_grid.build(state, operators[0].tether_range)
	_network.build(state, _grid)
	for unit in state.units:
		var view := UnitView.new()
		add_child(view)
		view.setup(unit, _grid.cell_to_world(unit.cell))
		_views[unit.id] = view
		if unit.is_player():
			_tethers[unit.id] = GridView.make_beam(0.03, Color(unit.def.color, 0.8))
			add_child(_tethers[unit.id])
		else:
			_ghosts[unit.id] = _make_ghost(unit)
	_camera_rig.setup(_grid.center(), _grid.extent())
	_hud.action_chosen.connect(_on_action)
	_hud.menu_cancelled.connect(_on_menu_cancelled)
	_hud.network_toggled.connect(_on_network_toggled)
	_refresh_fog()
	_next_turn()


func _process(_delta: float) -> void:
	var active := state.active
	_active_ring.visible = active != null and _views[active.id].visible and state.phase == BattleState.Phase.HUMAN
	if _active_ring.visible:
		_active_ring.position = _views[active.id].position + Vector3(0, 0.02, 0)
		_active_ring.scale = Vector3.ONE * (1.0 + 0.08 * sin(Time.get_ticks_msec() / 160.0))
	for id in _tethers:
		var unit: Unit = state.units[id]
		var tether: MeshInstance3D = _tethers[id]
		if unit.entry == "" or unit.is_down():
			tether.visible = false
		else:
			GridView.place_beam(tether, _views[id].position + Vector3(0, 0.9, 0), _grid.node_position(unit.entry, 0.8))
	_update_hover()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_network"):
		_on_network_toggled(not _network_shown)
		return
	if _busy or _network_moving:
		return
	if event.is_action_pressed("end_turn"):
		_end_player_turn()
	elif event.is_action_pressed("cancel"):
		if _mode in [Mode.MOVE, Mode.TARGET, Mode.NODE]:
			_open_menu()
	else:
		var click := event as InputEventMouseButton
		if click and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
			_click(click.position)


func _next_turn() -> void:
	_busy = true
	_mode = Mode.IDLE
	_hud.close_menu()
	_clear_choices()
	await _set_network(false)
	var unit := state.begin_next_turn()
	_refresh_units()
	_refresh_fog()
	_hud.show_turn(state)
	if unit == null:
		_hud.show_result(state.winner() == BattleState.Winner.PLAYER)
		return
	if unit.is_player():
		_camera_rig.keep_in_view(_views[unit.id].position)
		_begin_control()
		return
	var was_seen := state.player_sees(unit)
	var events := EnemyAI.take_turn(state, unit)
	if was_seen or _any_seen(events):
		_camera_rig.keep_in_view(_views[unit.id].position)
		await get_tree().create_timer(ENEMY_TURN_PAUSE, false).timeout
	await _play(events)
	_next_turn()


func _begin_control() -> void:
	_mode = Mode.IDLE
	_clear_choices()
	var unit := state.active
	_network.highlight([], unit.agent_node if state.phase == BattleState.Phase.AGENT else "")
	_hud.show_active(state)
	_busy = false


func _click(screen_position: Vector2) -> void:
	if _hud.is_menu_open():
		_hud.close_menu()
		_mode = Mode.IDLE
		return
	var token := _token_at(screen_position)
	var cell: Variant = _pointed_cell(screen_position, token)
	if cell == null or not _is_choice(cell, token):
		return
	var unit := state.active
	match _mode:
		Mode.IDLE:
			_open_menu()
		Mode.MOVE:
			_busy = true
			_clear_choices()
			await _play(state.move(unit, cell))
			if state.winner() != BattleState.Winner.NONE:
				_next_turn()
				return
			_busy = false
			_open_menu()
		Mode.TARGET:
			_busy = true
			_clear_choices()
			await _play(state.attack(unit, state.unit_at(cell)))
			_finish_human_phase()
		Mode.NODE:
			_agent_action(state.agent_move(unit, state.map.node_at(cell)))


func _open_menu() -> void:
	var unit := state.active
	var agent_phase := state.phase == BattleState.Phase.AGENT
	_clear_choices()
	_network.highlight([], unit.agent_node if agent_phase else "")
	_mode = Mode.MENU
	var anchor: Vector3 = _network.agent_position(unit) if agent_phase else _views[unit.id].position + Vector3(0, UNIT_HEIGHT, 0)
	var at := get_viewport().get_camera_3d().unproject_position(anchor)
	_hud.open_menu(at, _agent_actions(unit) if agent_phase else _human_actions(unit))
	_hud.show_active(state)


func _human_actions(unit: Unit) -> Array:
	var actions := []
	if not state.destinations(unit).is_empty():
		actions.append({"id": "move", "text": "Move"})
	if not state.attack_targets(unit, unit.cell).is_empty():
		actions.append({"id": "attack", "text": "Attack"})
	if state.can_undo(unit):
		actions.append({"id": "undo", "text": "Undo move"})
	actions.append({"id": "end", "text": "AI phase" if state.can_connect(unit) else "End turn"})
	return actions


func _agent_actions(unit: Unit) -> Array:
	var actions := []
	if not state.agent_destinations(unit).is_empty():
		actions.append({"id": "network_move", "text": "Move"})
	if state.can_hack(unit):
		actions.append({"id": "hack", "text": "Hack  +%d" % state.hack_yield(unit)})
	if state.can_compact(unit):
		actions.append({"id": "compact", "text": "Compact  (%d to %d)" % [unit.context, state.compacted(unit.context)]})
	if state.can_toggle_door(unit):
		actions.append({"id": "door", "text": "Close door" if state.is_door_open(unit.agent_node) else "Open door"})
	if unit.def.ability != UnitDef.Ability.NONE:
		actions.append({"id": "ability", "text": _ability_label(unit), "enabled": state.can_use_ability(unit)})
	actions.append({"id": "end", "text": "End turn"})
	return actions


func _ability_label(unit: Unit) -> String:
	var label := state.ability_name(unit)
	if unit.ability_uses_left == 0:
		return label + "  (used up)"
	if state.round_number < unit.ability_ready_round:
		return label + "  (ready in %d)" % (unit.ability_ready_round - state.round_number)
	if unit.ability_uses_left > 0:
		return label + "  (%d left)" % unit.ability_uses_left
	return label


func _on_action(id: String) -> void:
	var unit := state.active
	match id:
		"move":
			_mode = Mode.MOVE
			_grid.set_overlay("move", state.destinations(unit), MOVE_COLOR)
			_hud.set_hint("Choose a blue tile    ·    Right-click: back")
		"attack":
			_mode = Mode.TARGET
			var targets := state.attack_targets(unit, unit.cell).map(func(target: Unit) -> Vector2i: return target.cell)
			_grid.set_overlay("attack", targets, ATTACK_COLOR)
			_hud.set_hint("Choose an enemy on red    ·    Right-click: back")
		"undo":
			_undo_move()
		"end":
			_end_player_turn()
		"network_move":
			_mode = Mode.NODE
			_network.highlight(state.agent_destinations(unit), unit.agent_node)
			_hud.set_hint("Choose a ringed node    ·    Right-click: back")
		"ability":
			if unit.def.ability == UnitDef.Ability.LOCATE:
				_choose_locate_target()
			else:
				_agent_action(state.use_ability(unit))
		"back":
			_open_menu()
		"hack":
			_agent_action(state.hack(unit))
		"compact":
			_agent_action(state.compact(unit))
		"door":
			_agent_action(state.toggle_door(unit))
		_ when id.begins_with("locate:"):
			_agent_action(state.use_ability(unit, state.units[id.trim_prefix("locate:").to_int()]))


# Locate asks which unseen enemy to pin, as a second menu in the same place.
func _choose_locate_target() -> void:
	var actions := []
	for target in state.locate_targets():
		actions.append({"id": "locate:%d" % target.id, "text": target.display_name})
	actions.append({"id": "back", "text": "Back"})
	var at := get_viewport().get_camera_3d().unproject_position(_network.agent_position(state.active))
	_mode = Mode.MENU
	_hud.open_menu(at, actions)


func _on_menu_cancelled() -> void:
	_mode = Mode.IDLE


func _finish_human_phase() -> void:
	_busy = true
	_mode = Mode.IDLE
	_hud.close_menu()
	_clear_choices()
	await _play(state.end_human_phase(state.active))
	if state.phase == BattleState.Phase.AGENT:
		await _set_network(true)
		_begin_control()
	else:
		_next_turn()


func _end_player_turn() -> void:
	if _busy:
		return
	_hud.close_menu()
	if state.phase == BattleState.Phase.HUMAN:
		_finish_human_phase()
	else:
		_next_turn()


func _undo_move() -> void:
	var unit := state.active
	if not state.can_undo(unit):
		return
	state.undo_move(unit)
	_views[unit.id].position = _grid.cell_to_world(unit.cell)
	_network.refresh()
	_refresh_fog()
	_open_menu()


func _agent_action(events: Array[Dictionary]) -> void:
	_busy = true
	_mode = Mode.IDLE
	_clear_choices()
	await _play(events)
	_next_turn()


func _on_network_toggled(shown: bool) -> void:
	if _busy or _network_moving or state.active == null:
		_hud.set_network_shown(_network_shown)
		return
	_hud.close_menu()
	_clear_choices()
	_mode = Mode.IDLE
	_set_network(shown)


# The camera tilts to look straight down, the network fades in over the map, and then the map blurs
# away behind it. Hiding runs the same steps backwards.
func _set_network(shown: bool) -> void:
	while _network_moving:
		await get_tree().process_frame
	if shown == _network_shown:
		return
	_network_moving = true
	_network_shown = shown
	_hud.set_network_shown(shown)
	var hover: StandardMaterial3D = _hover.material_override
	hover.no_depth_test = shown
	hover.render_priority = NetworkView.Order.RING if shown else 0
	if shown:
		await _camera_rig.overhead(_grid.center())
		await _network.fade_in()
	else:
		await _network.fade_out()
		await _camera_rig.restore_view()
	_network_moving = false


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
				_network.refresh()
				_hud.log_line("%s's AI connects" % unit.display_name)
			"disconnect":
				_network.refresh()
				_hud.log_line("%s left the access point's range. The AI was pulled out" % unit.display_name)
			"agent_move":
				await _network.move_agent(unit, event["path"])
			"hack":
				var node: String = event["node"]
				_float_text(_network.node_position(node) + Vector3(0, 1.0, 0), "+%d" % event["points"], Color.WHITE)
				_hud.log_line("%s's AI hacks the %s: +%d" % [unit.display_name, state.node_def(node).display_name.to_lower(), event["points"]])
				_network.refresh()
				await get_tree().create_timer(0.35, false).timeout
			"breach":
				_hud.log_line("%s breached" % state.node_def(event["node"]).display_name)
				if state.map.node_kind(event["node"]) == "cache":
					_hud.log_line("Data secured. Get everyone to the exit!")
			"compact":
				_hud.log_line("%s's AI compacts its context: %d to %d" % [unit.display_name, event["before"], unit.context])
			"door":
				_hud.log_line("Door %s" % ("opened" if event["open"] else "locked"))
			"ability":
				_play_ability(event)
	_refresh_units()
	_grid.update_nodes(state)
	_network.refresh()
	_refresh_fog()
	_hud.show_turn(state)


func _play_ability(event: Dictionary) -> void:
	var unit: Unit = event["unit"]
	match unit.def.ability:
		UnitDef.Ability.PROBE:
			_grid.add_probe(state.map.node_cell(event["node"]))
			_hud.log_line("%s's AI drops a probe on the %s" % [unit.display_name, state.node_def(event["node"]).display_name.to_lower()])
		UnitDef.Ability.LOCATE:
			_hud.log_line("%s's AI locates %s for %d rounds" % [unit.display_name, event["target"].display_name, unit.def.ability_duration])
		UnitDef.Ability.CLOAK:
			_hud.log_line("%s is cloaked for %d rounds" % [unit.display_name, unit.def.ability_duration])


func _refresh_units() -> void:
	for id in _views:
		var unit: Unit = state.units[id]
		var view: UnitView = _views[id]
		view.refresh()
		if unit.is_player():
			view.set_cloaked(state.is_cloaked(unit))
	_update_objective()


func _update_objective() -> void:
	if not state.cache_breached:
		var progress := [state.breach.get(state.objective, 0), state.node_def(state.objective).goal]
		_hud.set_objective("Objective: breach the data cache  (%d/%d)" % progress)
		return
	var standing := state.living().filter(func(unit: Unit) -> bool: return unit.is_player()).size()
	_hud.set_objective("Objective: get everyone to the exit  (%d/%d there)" % [state.extracted(), standing])


func _walk(unit: Unit, path: Array) -> void:
	var view: UnitView = _views[unit.id]
	var points: Array[Vector3] = []
	var shown: Array[bool] = []
	for cell in path:
		points.append(_grid.cell_to_world(cell))
		shown.append(unit.is_player() or state.visible_cells.has(cell) or state.is_located(unit))
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


func _float_text(at: Vector3, text: String, color: Color) -> void:
	var label := UnitView.make_label(56, 0.0)
	label.render_priority = NetworkView.Order.LABEL + 2
	label.outline_render_priority = NetworkView.Order.LABEL + 1
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
	var mouse := get_viewport().get_mouse_position()
	var over_ui := _hud.is_menu_open() or get_viewport().gui_get_hovered_control() != null
	var token: Unit = null if over_ui else _token_at(mouse)
	var cell: Variant = null if over_ui else _pointed_cell(mouse, token)
	_hover.visible = cell != null and _is_choice(cell, token)
	if cell == null:
		_hud.set_hover("")
		return
	_hover.position = _grid.cell_to_world(cell) + Vector3(0, 0.02, 0)
	var text := _describe(cell)
	if token:
		_hover.position = _network.agent_position(token) * Vector3(1, 0, 1) + Vector3(0, 0.02, 0)
		text = "%s's AI    %s" % [token.display_name, text]
	if _network_shown and state.phase == BattleState.Phase.HUMAN:
		text += "    ·    Network view: press N to return to the map"
	_hud.set_hover(text)


# The hover highlight only marks what a click would act on right now, and clicks act only there.
func _is_choice(cell: Vector2i, token: Unit = null) -> bool:
	var unit := state.active
	if _busy or _network_moving or unit == null or not unit.is_player():
		return false
	match _mode:
		Mode.IDLE:
			if state.phase == BattleState.Phase.AGENT:
				return token == unit if token else state.map.node_at(cell) == unit.agent_node
			return not _network_shown and cell == unit.cell
		Mode.MOVE:
			return state.can_move(unit, cell)
		Mode.TARGET:
			var target := state.unit_at(cell)
			return target != null and state.can_attack(unit, target)
		Mode.NODE:
			return state.agent_destinations(unit).has(state.map.node_at(cell))
	return false


func _describe(cell: Vector2i) -> String:
	var text := "Tile %d, %d" % [cell.x, cell.y]
	var unit := state.unit_at(cell)
	if unit and state.player_sees(unit):
		text += "    %s  HP %d/%d" % [unit.display_name, unit.hp, unit.def.max_hp]
		var active := state.active
		if _mode == Mode.TARGET and state.can_attack(active, unit):
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


# What the cursor points at. An AI token stands for the node its AI is on, and a unit's body for its
# tile, since tall units hide the tiles behind them.
func _pointed_cell(screen_position: Vector2, token: Unit) -> Variant:
	if token:
		return state.map.node_cell(token.agent_node)
	var cell: Variant = _cell_at(screen_position)
	if cell != null and not _network_shown:
		var picked := _unit_at_screen(screen_position)
		if picked:
			cell = picked.cell
	return cell


func _token_at(screen_position: Vector2) -> Unit:
	if not _network_shown:
		return null
	var camera := get_viewport().get_camera_3d()
	return _network.agent_at(camera.project_ray_origin(screen_position), camera.project_ray_normal(screen_position))


func _unit_at_screen(screen_position: Vector2) -> Unit:
	var camera := get_viewport().get_camera_3d()
	var from := camera.project_ray_origin(screen_position)
	var to := from + camera.project_ray_normal(screen_position) * 500.0
	var best: Unit = null
	var best_depth := INF
	for unit in state.living():
		if not state.player_sees(unit):
			continue
		var base: Vector3 = _views[unit.id].position
		var points := Geometry3D.get_closest_points_between_segments(from, to, base, base + Vector3(0, UNIT_HEIGHT, 0))
		var depth := from.distance_to(points[0])
		if points[0].distance_to(points[1]) < PICK_RADIUS and depth < best_depth:
			best = unit
			best_depth = depth
	return best


func _cell_at(screen_position: Vector2) -> Variant:
	var camera := get_viewport().get_camera_3d()
	var hit: Variant = Plane(Vector3.UP, 0.0).intersects_ray(
		camera.project_ray_origin(screen_position), camera.project_ray_normal(screen_position)
	)
	if hit == null:
		return null
	var cell := _grid.world_to_cell(hit)
	return cell if state.map.in_bounds(cell) else null
