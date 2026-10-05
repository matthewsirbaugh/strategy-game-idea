extends Node3D

# The battle on screen. It asks the rules what's possible, offers it in menus, hands the player's
# choices back to the rules, and plays the events they return. A turn starts with only the active
# unit highlighted: clicking it (or its AI, in the network view) opens its menu. Actions that need
# a target mark the tiles they can go to; right-click steps back to the menu.
enum Mode { IDLE, MENU, PICK }

const MOVE_COLOR := Color(0.3, 0.6, 1.0, 0.35)
const NOTICED_COLOR := Color(1.0, 0.75, 0.2, 0.42)
const SEEN_COLOR := Color(1.0, 0.25, 0.2, 0.5)
const TARGET_COLOR := Color(1.0, 0.3, 0.3, 0.5)
const PLACE_COLOR := Color(0.45, 1.0, 0.75, 0.35)
const CONE_SEEN := Color(1.0, 0.3, 0.22, 0.16)
const CONE_NOTICED := Color(1.0, 0.78, 0.25, 0.07)
const AIM_COLOR := Color(1.0, 0.2, 0.15, 0.85)
const GHOST_COLOR := Color(0.75, 0.55, 1.0, 0.8)
const SOUND_COLOR := Color(0.55, 0.85, 1.0, 0.22)
const BLAST_COLOR := Color(1.0, 1.0, 0.8, 0.35)
const CIRCUIT_COLOR := Color(1.0, 0.68, 0.28, 0.45)
const RESPONDER_COLOR := Color(1.0, 0.95, 0.4, 0.7)
const LAST_SEEN_COLOR := Color(1.0, 0.3, 0.25, 0.7)
const ENEMY_TURN_PAUSE := 0.35
const UNIT_HEIGHT := 1.7
# Where a tether leaves the pack and where shots fly, on a person 1.8 m tall.
const PACK_Y := 1.3
const CHEST_Y := 1.3
const TERMINAL_Y := 1.0
const PICK_RADIUS := 0.45
const BEAM_Y := 0.35
const PICK_LAYERS: Array[String] = ["pick_safe", "pick_noticed", "pick_seen"]
const PREVIEW_LAYERS: Array[String] = ["preview_area", "preview_responders"]

@export var map: MapData
@export var content: BattleContent

var state: BattleState
var _views := {}
var _last_seen := {}
var _tethers := {}
var _scan_labels := {}
var _beams: Array[MeshInstance3D] = []
var _busy := true
var _mode := Mode.IDLE
# While picking: the tiles a click can choose, what to do with the one chosen, and what to show
# for the one under the cursor.
var _choices := {}
var _on_pick: Callable
var _on_pick_hover: Callable
var _predict_picks: Array[Unit] = []
var _network_shown := false
var _network_moving := false
var _scan := false
var _hovered: Variant = null

@onready var _grid: GridView = $GridView
@onready var _level: LevelView = $LevelView
@onready var _network: NetworkView = $NetworkView
@onready var _camera_rig: CameraRig = $CameraRig
@onready var _hover: MeshInstance3D = $HoverHighlight
@onready var _active_ring: MeshInstance3D = $ActiveRing
@onready var _hud: Hud = $Hud


func _ready() -> void:
	if SceneRouter.session == null:
		SceneRouter.session = BattleSession.from_presets(map, content)
	state = SceneRouter.session.start()
	if not state.errors.is_empty():
		set_process(false)
		_hud.show_errors(state.errors)
		return
	_grid.build(state)
	_level.build(state, _grid)
	_hover.scale = Vector3.ONE * GridView.CELL
	_network.build(state, _grid)
	for unit in state.units:
		_add_view(unit)
	for id in state.devices:
		var label := UnitView.make_label(34, 0.0)
		label.modulate = Color(0.75, 1.0, 0.95)
		label.visible = false
		add_child(label)
		_scan_labels[id] = label
	var team := Vector3.ZERO
	for cell in state.map.player_starts():
		team += _grid.cell_to_world(cell) / state.map.player_starts().size()
	_camera_rig.setup(team.lerp(_grid.center(), 0.28), _grid.extent())
	_hud.action_chosen.connect(_on_action)
	_hud.action_hovered.connect(_on_action_hovered)
	_hud.actions_requested.connect(_on_actions_requested)
	_hud.menu_cancelled.connect(func() -> void: _mode = Mode.IDLE)
	_hud.network_toggled.connect(_on_network_toggled)
	_hud.scan_toggled.connect(_set_scan)
	_hud.operator_chosen.connect(_on_operator_chosen)
	_refresh()
	_run_turns()


func _add_view(unit: Unit) -> void:
	var view := UnitView.new()
	add_child(view)
	view.setup(unit, _grid.cell_to_world(unit.cell))
	_views[unit.id] = view
	if unit.is_player():
		_level.watched.append(view)
	if unit.is_operator():
		_tethers[unit.id] = GridView.make_beam(0.03, Color(unit.def.color, 0.8))
		add_child(_tethers[unit.id])
	elif not unit.is_player():
		_last_seen[unit.id] = _make_last_seen(unit)


func _process(_delta: float) -> void:
	var active := state.active
	_active_ring.visible = active != null and state.is_player_controlled(active) and _views[active.id].visible and not _network_shown
	if _active_ring.visible:
		_active_ring.position = _views[active.id].position + Vector3(0, 0.02, 0)
		_active_ring.scale = Vector3.ONE * GridView.CELL * (1.0 + 0.08 * sin(Time.get_ticks_msec() / 160.0))
	for id in _tethers:
		var unit: Unit = state.units[id]
		var tether: MeshInstance3D = _tethers[id]
		tether.visible = unit.connected() and not unit.down
		if tether.visible:
			var source: Node3D = _views[unit.relay] if unit.relay >= 0 else _views[id]
			GridView.place_beam(tether, source.position + Vector3(0, PACK_Y, 0), _grid.cell_to_world(state.node_cell(unit.entry)) + Vector3(0, TERMINAL_Y, 0))
	_update_hover()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_network"):
		_on_network_toggled(not _network_shown)
		return
	if event.is_action_pressed("toggle_scan"):
		_set_scan(not _scan)
		return
	if _busy or _network_moving:
		return
	if event.is_action_pressed("end_turn"):
		_hud.close_menu()
		_act(state.end_turn(state.active))
	elif event.is_action_released("cancel"):
		if _mode == Mode.PICK:
			_open_menu()
	else:
		# On release: the camera swallows the release that ends a drag, so this is a plain click.
		var click := event as InputEventMouseButton
		if click and not click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
			_click(click.position)


# --- Turns ---------------------------------------------------------------------------------------

# Plays turns until one needs the player: enemy turns run on their own, out of sight or not.
func _run_turns() -> void:
	_busy = true
	_mode = Mode.IDLE
	_hud.close_menu()
	_clear_pick()
	await _set_network(false)
	while true:
		var unit := state.begin_next_turn()
		_refresh()
		if unit == null:
			_hud.show_result(state.winner() == BattleState.Winner.PLAYER)
			return
		if state.is_player_controlled(unit):
			_grid.show_access_zones(BattleState.TETHER)
			_camera_rig.keep_in_view(_views[unit.id].position)
			if unit.is_operator() and unit.incoming > 0:
				_hud.log_line("%s's AI has %d donated AP this turn" % [unit.display_name, unit.incoming])
			_begin_control()
			return
		var was_seen := state.player_sees(unit)
		var events := state.take_automatic_turn()
		if was_seen or _any_seen(events):
			_camera_rig.keep_in_view(_views[unit.id].position)
			await get_tree().create_timer(ENEMY_TURN_PAUSE, false).timeout
		await _play(events)


func _begin_control() -> void:
	_mode = Mode.IDLE
	_clear_pick()
	_network.highlight([], state.active.ai_node if _network_shown and state.active.is_operator() else "")
	_hud.show_turn(state)
	_busy = false


# Every player action ends here: play what happened, then carry on with the turn or move on.
func _act(events: Array[Dictionary]) -> void:
	if events.is_empty():
		return
	_busy = true
	_mode = Mode.IDLE
	_clear_pick()
	_clear_preview()
	_hud.close_menu()
	await _play(events)
	if state.turn_over or state.winner() != BattleState.Winner.NONE:
		_run_turns()
		return
	_begin_control()
	_open_menu()


func _on_operator_chosen(id: int) -> void:
	if _busy or not state.choose_operator(state.units[id]):
		return
	_hud.close_menu()
	_refresh()
	_camera_rig.keep_in_view(_views[id].position)
	_begin_control()


# --- Menus ---------------------------------------------------------------------------------------

func _on_actions_requested() -> void:
	if _busy or _network_moving or not state.is_player_controlled(state.active):
		return
	_open_menu()


func _open_menu(actions: Array = [], title := "") -> void:
	var unit := state.active
	_clear_pick()
	_clear_preview()
	_mode = Mode.MENU
	if actions.is_empty():
		if unit.is_robot():
			actions = _robot_actions(unit)
			title = unit.display_name.to_upper()
		elif _network_shown:
			actions = _ai_actions(unit)
			title = "%s'S AI" % unit.display_name.to_upper()
		else:
			actions = _operator_actions(unit)
			title = unit.display_name.to_upper()
	var anchor: Vector3 = _views[unit.id].position + Vector3(0, UNIT_HEIGHT, 0)
	if _network_shown and unit.is_operator() and unit.connected():
		anchor = _network.agent_position(unit)
	_network.highlight([], unit.ai_node if _network_shown and unit.is_operator() else "")
	_hud.open_menu(get_viewport().get_camera_3d().unproject_position(anchor), actions, title)
	_hud.show_turn(state)


func _operator_actions(unit: Unit) -> Array:
	var actions := []
	if not state.move_costs(unit).is_empty():
		actions.append({"id": "move", "text": "Move   1 AP a tile", "tip": "Tiles that would get you noticed are amber, seen red"})
	if not state.move_costs(unit, true).is_empty():
		actions.append({"id": "sprint", "text": "Sprint   3 tiles for 2 AP", "tip": "Gives up this turn's shot. Cut short, it costs what walking would have"})
	if not state.shot_targets(unit).is_empty():
		actions.append({"id": "shoot", "text": "Shoot   free, once a turn", "tip": "Range %d, line of sight. A hit stuns an enemy for %d turns" % [unit.def.shot_range, BattleState.STUN_TURNS]})
	if state.can_shoot(unit):
		actions.append({"id": "overwatch", "text": "Overwatch   holds the shot", "tip": "Fires at the first enemy that moves into your line of fire, until your next turn"})
	for option in state.door_options(unit):
		var cost := "   %d AP" % BattleState.LOCK_COST if option.action == "lock" else "   free"
		actions.append({"id": "door:%s:%s" % [option.node, option.action], "text": "%s door %s%s" % [option.action.capitalize(), option.node.to_upper(), cost]})
	for id in state.peek_options(unit):
		actions.append({"id": "peek:" + id, "text": "Peek through %s   1 AP" % id.to_upper(), "tip": "See past the door until your turn ends"})
	for option in state.deploy_options(unit):
		var via: String = "" if option.relay < 0 else " via " + state.units[option.relay].def.display_name.to_lower()
		actions.append({"id": "deploy:%s:%d" % [option.access, option.relay], "text": "Deploy AI at %s%s   1 AP" % [option.access.to_upper(), via]})
	for body in state.tie_targets(unit):
		actions.append({"id": "tie:%d" % body.id, "text": "Tie up %s   2 AP" % body.display_name})
	for body in state.pickup_targets(unit):
		actions.append({"id": "pickup:%d" % body.id, "text": "Pick up %s   free" % body.display_name, "tip": "While carrying you can only move"})
	if not state.putdown_cells(unit).is_empty():
		actions.append({"id": "putdown", "text": "Put down %s   free" % state.units[unit.carrying].display_name, "tip": "On a dumpster or trunk, it's hidden inside"})
	if not state.flashbang_cells(unit).is_empty():
		actions.append({"id": "flashbang", "text": "Flashbang   2 AP  (%d left)" % unit.flashbangs, "tip": "Thrown up to 5 tiles; blinds guards within 2 for 3 turns"})
	if not state.robot_cells(unit).is_empty():
		actions.append({"id": "robot", "text": "Deploy %s   3 AP" % unit.robot_def.display_name.to_lower(), "tip": "It acts from next round"})
	for other in state.share_targets(unit):
		actions.append({"id": "share:%d" % other.id, "text": "Give %s's AI 1 AP" % other.display_name, "tip": "Shared compute: it arrives on their next turn, and lapses if unused"})
	actions.append({"id": "ai", "text": "AI   →", "tip": "The AI's own actions, on its own AP"})
	for other in state.tied_operators():
		actions.append({"id": "choose:%d" % other.id, "text": "Act with %s first" % other.display_name})
	actions.append({"id": "end", "text": "End turn"})
	return actions


func _ai_actions(unit: Unit) -> Array:
	var actions := []
	if unit.connected():
		if not state.network_destinations(unit).is_empty():
			var load := "   loads movement +%dM" % state.chip_def(BattleState.MOVEMENT).load_cost if unit.chips[BattleState.MOVEMENT] == 0 else ""
			actions.append({"id": "ai_move", "text": "Move   1 AP" + load, "tip": "Up to %d hops; hops out of Breached nodes are free" % BattleState.NETWORK_RANGE})
		if state.can_hack(unit):
			var id := unit.ai_node
			var text := "Hack %s  +%d   1 AP, +%dM" % [id.to_upper(), state.hack_power(unit, id), state.hack_context(unit, id)]
			actions.append({"id": "hack:", "text": text, "tip": "A one-action breach from untouched refunds the AP"})
			for linked in state.subagent_links(unit):
				actions.append({"id": "hack:" + linked, "text": "   + subagent on %s  +%d" % [linked.to_upper(), state.subagent_points(unit, state.hack_power(unit, id))]})
	if state.can_compact(unit):
		actions.append({"id": "compact", "text": "Compact   1 AP: %dM to %dM" % [unit.context, state.compacted(unit.context)], "tip": "Degrades every loaded chip a step"})
	for id in state.load_options(unit):
		actions.append({"id": "load:" + id, "text": "Load %s   +%dM" % [state.chip_def(id).display_name, state.chip_def(id).load_cost]})
	for id in unit.chips:
		var chip := state.chip_def(id)
		if chip.type != ChipDef.Type.ACTIVE or not unit.connected():
			continue
		var load := "   +%dM to load" % chip.load_cost if unit.chips[id] == 0 else ""
		var waiting := "   (ready for the next hack)" if unit.next_hack.has(id) else ""
		actions.append({"id": "chip:" + id, "text": "%s   1 AP%s%s" % [chip.display_name, load, waiting], "enabled": state.chip_ready(unit, id), "tip": chip.effect})
	if not state.verb_options(unit).is_empty():
		actions.append({"id": "devices", "text": "Devices   →", "tip": "Verbs cost no AP and %dM context each" % BattleState.VERB_CONTEXT})
	for id in state.turret_controls(unit):
		var mode := "hold" if state.devices[id].mode == "target" else "target"
		actions.append({"id": "turret:%s:%s" % [id, mode], "text": "Turret %s: %s   free" % [id.to_upper(), "hold fire" if mode == "hold" else "target enemies"]})
	if actions.is_empty():
		actions.append({"id": "none", "text": "Nothing the AI can do yet", "enabled": false})
	actions.append({"id": "physical", "text": "←   Operator"})
	actions.append({"id": "end", "text": "End turn"})
	return actions


func _device_actions(unit: Unit, only := "") -> Array:
	var actions := []
	for option in state.verb_options(unit):
		if only != "" and option.node != only:
			continue
		actions.append({"id": "verb:%s:%s:%d" % [option.node, option.verb, option.direction], "text": _verb_text(option), "enabled": option.enabled})
	actions.append({"id": "ai", "text": "←   Back"})
	return actions


func _verb_text(option: Dictionary) -> String:
	var id: String = option.node
	var device: Dictionary = state.devices[id]
	var what := "%s %s: " % [state.node_def(id).display_name, id.to_upper()]
	match option.verb:
		"power":
			what += "power off" if device.powered else "power on"
		"lock":
			what += "unlock" if device.locked else "lock"
		"activate":
			match state.map.node_kind(id):
				"autodoor":
					what += "close" if device.open else "open"
				"phone":
					what += "ring"
				"adscreen":
					what += "flash"
				_:
					what += "drive forward" if option.direction == 1 else "drive backward"
	return what + "   +%dM" % BattleState.VERB_CONTEXT


func _robot_actions(unit: Unit) -> Array:
	var actions := []
	if not state.move_costs(unit).is_empty():
		actions.append({"id": "move", "text": "Move   1 AP a tile"})
	if not state.dog_stun_targets(unit).is_empty():
		actions.append({"id": "dog_stun", "text": "Stun   1 AP, once a battle"})
	actions.append({"id": "end", "text": "End turn"})
	return actions


func _on_action(id: String) -> void:
	var unit := state.active
	var parts := id.split(":")
	match parts[0]:
		"move", "sprint":
			_pick_move(unit, parts[0] == "sprint")
		"shoot":
			_pick_units(state.shot_targets(unit), "Choose an enemy to shoot", func(target: Unit) -> void: _act(state.shoot(unit, target)))
		"dog_stun":
			_pick_units(state.dog_stun_targets(unit), "Choose an enemy to stun", func(target: Unit) -> void: _act(state.dog_stun(unit, target)))
		"overwatch":
			_act(state.set_overwatch(unit))
		"door":
			_act(state.use_door(unit, parts[1], parts[2]))
		"peek":
			_act(state.peek(unit, parts[1]))
		"deploy":
			_act(state.deploy_ai(unit, parts[1], parts[2].to_int()))
		"tie":
			_act(state.tie_up(unit, state.units[parts[1].to_int()]))
		"pickup":
			_act(state.pick_up(unit, state.units[parts[1].to_int()]))
		"putdown":
			_pick_cells(state.putdown_cells(unit), PLACE_COLOR, "Choose where to put the body down", func(cell: Vector2i) -> void: _act(state.put_down(unit, cell)))
		"flashbang":
			_pick_cells(state.flashbang_cells(unit), TARGET_COLOR, "Choose where to throw it", func(cell: Vector2i) -> void: _act(state.throw_flashbang(unit, cell)),
				func(cell: Vector2i) -> void: _grid.set_overlay("preview_area", state.flashbang_area(cell), BLAST_COLOR, 0.03))
		"robot":
			_pick_cells(state.robot_cells(unit), PLACE_COLOR, "Choose where the robot goes", func(cell: Vector2i) -> void: _act(state.deploy_robot(unit, cell)))
		"share":
			_act(state.share_compute(unit, state.units[parts[1].to_int()]))
		"choose":
			_on_operator_chosen(parts[1].to_int())
		"ai":
			if unit.connected() and not _network_shown:
				_busy = true
				await _set_network(true)
				_busy = false
			_open_menu(_ai_actions(unit), "%s'S AI" % unit.display_name.to_upper())
		"physical":
			if _network_shown:
				_busy = true
				await _set_network(false)
				_busy = false
			_open_menu(_operator_actions(unit), unit.display_name.to_upper())
		"end":
			_act(state.end_turn(unit))
		"ai_move":
			var nodes := state.network_destinations(unit)
			_choices.clear()
			for node in nodes:
				_choices[state.node_cell(node)] = node
			_mode = Mode.PICK
			_on_pick = func(cell: Vector2i) -> void: _act(state.ai_move(unit, _choices[cell]))
			_on_pick_hover = Callable()
			_network.highlight(nodes, unit.ai_node)
			_hud.set_hint("Choose a ringed node    ·    Right-click: back")
		"hack":
			_act(state.hack(unit, parts[1]))
		"compact":
			_act(state.compact(unit))
		"load":
			_act(state.load_chip(unit, parts[1]))
		"chip":
			_use_chip(unit, parts[1])
		"locate":
			_act(state.use_chip(unit, BattleState.LOCATE, [state.units[parts[1].to_int()]]))
		"predict":
			_on_predict(unit, parts[1].to_int())
		"devices":
			_open_menu(_device_actions(unit), "DEVICES")
		"verb":
			_act(state.use_verb(unit, parts[1], parts[2], parts[3].to_int()))
		"turret":
			_act(state.set_turret_mode(unit, parts[1], parts[2]))


func _use_chip(unit: Unit, id: String) -> void:
	match id:
		BattleState.LOCATE:
			var actions := []
			for target in state.locate_targets():
				actions.append({"id": "locate:%d" % target.id, "text": target.display_name})
			actions.append({"id": "ai", "text": "←   Back"})
			_open_menu(actions, "LOCATE WHO?")
		BattleState.PREDICT:
			_predict_picks.clear()
			_open_menu(_predict_menu(unit), "PREDICT WHO?")
		_:
			_act(state.use_chip(unit, id))


# Predict follows up to 2 guards (1 degraded): pick them one by one.
func _predict_menu(unit: Unit) -> Array:
	var actions := []
	for target in state.predict_targets():
		if not _predict_picks.has(target):
			actions.append({"id": "predict:%d" % target.id, "text": target.display_name})
	if not _predict_picks.is_empty():
		actions.append({"id": "predict:-1", "text": "Just %s" % _predict_picks[0].display_name})
	actions.append({"id": "ai", "text": "←   Back"})
	return actions


func _on_predict(unit: Unit, id: int) -> void:
	if id >= 0:
		_predict_picks.append(state.units[id])
	var room: int = state.chip_count(unit, BattleState.PREDICT) if unit.chips[BattleState.PREDICT] > 0 else int(state.chip_def(BattleState.PREDICT).strength)
	if id < 0 or _predict_picks.size() >= room or _predict_menu(unit).size() <= 2:
		var picks := _predict_picks.duplicate()
		_predict_picks.clear()
		_act(state.use_chip(unit, BattleState.PREDICT, picks))
	else:
		_open_menu(_predict_menu(unit), "AND WHO ELSE?")


# --- Picking targets -----------------------------------------------------------------------------

# Move tiles show how exposed each would leave the Operator: amber noticed, red seen.
func _pick_move(unit: Unit, sprint: bool) -> void:
	var costs := state.move_costs(unit, sprint)
	var layers := [[], [], []]
	for cell in costs:
		layers[state.exposure(cell) if unit.is_player() else 0].append(cell)
	_set_pick(costs, func(cell: Vector2i) -> void: _act(state.move(unit, cell, sprint)))
	for i in 3:
		_grid.set_overlay(PICK_LAYERS[i], layers[i], [MOVE_COLOR, NOTICED_COLOR, SEEN_COLOR][i])
	_hud.set_hint(("Sprint: " if sprint else "") + "choose a tile. Amber gets you noticed, red seen    ·    Right-click: back")


func _pick_units(targets: Array[Unit], hint: String, on_pick: Callable) -> void:
	var cells := {}
	for target in targets:
		cells[target.cell] = target
	_set_pick(cells, func(cell: Vector2i) -> void: on_pick.call(cells[cell]))
	_grid.set_overlay(PICK_LAYERS[2], cells.keys(), TARGET_COLOR)
	_hud.set_hint(hint + "    ·    Right-click: back")


func _pick_cells(cells: Array[Vector2i], color: Color, hint: String, on_pick: Callable, on_hover := Callable()) -> void:
	var choices := {}
	for cell in cells:
		choices[cell] = true
	_set_pick(choices, on_pick, on_hover)
	_grid.set_overlay(PICK_LAYERS[0], cells, color)
	_hud.set_hint(hint + "    ·    Right-click: back")


func _set_pick(choices: Dictionary, on_pick: Callable, on_hover := Callable()) -> void:
	_clear_pick()
	_choices = choices
	_on_pick = on_pick
	_on_pick_hover = on_hover
	_mode = Mode.PICK


func _clear_pick() -> void:
	_choices = {}
	for layer in PICK_LAYERS:
		_grid.clear_overlay(layer)
	_grid.clear_overlay("preview_area")


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
			var node := state.node_at(cell) if _network_shown else ""
			if node != "" and token == null and state.verb_options(unit).any(func(option: Dictionary) -> bool: return option.node == node):
				_open_menu(_device_actions(unit, node), "%s %s" % [state.node_def(node).display_name.to_upper(), node.to_upper()])
			else:
				_open_menu()
		Mode.PICK:
			_on_pick.call(cell)


# The hover highlight only marks what a click would act on right now, and clicks act only there.
func _is_choice(cell: Vector2i, token: Unit = null) -> bool:
	var unit := state.active
	if _busy or _network_moving or not state.is_player_controlled(unit):
		return false
	match _mode:
		Mode.IDLE:
			if _network_shown:
				if token:
					return token == unit
				var node := state.node_at(cell)
				return (unit.is_operator() and unit.connected() and node == unit.ai_node) \
					or (node != "" and state.verb_options(unit).any(func(option: Dictionary) -> bool: return option.node == node))
			return cell == unit.cell
		Mode.PICK:
			return _choices.has(cell)
	return false


# --- What happened -------------------------------------------------------------------------------

func _play(events: Array[Dictionary]) -> void:
	for event in events:
		var unit: Unit = event.get("unit")
		match event.type:
			"move":
				await _walk(unit, event.path)
			"blocked":
				if state.player_sees(unit) or unit.is_player():
					_hud.log_line("%s ran into %s!" % [unit.display_name, event.by.display_name])
			"revealed":
				_hud.log_line("%s spots %s and stops" % [unit.display_name, ", ".join(event.enemies.map(func(enemy: Unit) -> String: return enemy.display_name))])
			"alert":
				_hud.log_line("%s sees %s! Full alert" % [_who(unit), event.target.display_name])
			"notice":
				if state.player_sees(unit):
					_hud.log_line("%s noticed something" % unit.display_name)
			"camera_report":
				_log_responders("Camera %s spotted something" % event.node.to_upper(), event.responders)
			"sound":
				_flash_area(event.cells, SOUND_COLOR)
				_log_responders("A sound carries %d step%s" % [event.radius, "" if event.radius == 1 else "s"], event.responders)
			"lure":
				_log_responders("%s %s draws attention" % [state.node_def(event.node).display_name, event.node.to_upper()], event.responders)
			"found_body":
				_hud.log_line("%s found %s! Full alert" % [_who(unit), event.body.display_name])
			"aim":
				_hud.log_line("%s aims at %s" % [_who(unit), event.target.display_name])
			"aim_lapsed":
				if state.player_sees(unit):
					_hud.log_line("%s lost the shot" % unit.display_name)
			"fire", "overwatch", "shot":
				await _shoot(unit, event.target, event.type == "overwatch")
			"hit":
				_hit(event)
			"dog_stun":
				_hud.log_line("%s stuns %s" % [unit.display_name, event.target.display_name])
			"stunned":
				if state.player_sees(unit):
					_hud.log_line("%s is out cold%s" % [unit.display_name, "" if unit.stun == 0 else ", %d more turns" % unit.stun])
			"blinded":
				if state.player_sees(unit):
					_hud.log_line("%s is still blinded" % unit.display_name)
			"wake":
				if event.hidden:
					_hud.log_line("Someone is banging inside a receptacle")
				else:
					_hud.log_line("%s wakes up, alerted" % _who(unit))
			"free":
				_hud.log_line("%s frees %s" % [_who(unit), event.target.display_name])
			"searching":
				if state.player_sees(unit):
					_hud.log_line("%s lost track and searches" % unit.display_name)
			"gave_up":
				if state.player_sees(unit):
					_hud.log_line("%s goes back to its post" % unit.display_name)
			"tie":
				_hud.log_line("%s ties up %s" % [unit.display_name, event.target.display_name])
			"pick_up":
				_hud.log_line("%s picks up %s" % [unit.display_name, event.target.display_name])
			"put_down":
				_hud.log_line("%s puts %s down%s" % [unit.display_name, event.target.display_name, ", hidden" if event.hidden else ""])
			"flashbang":
				_flash_area(event.cells, BLAST_COLOR)
				_hud.log_line("Flashbang: %d blinded" % event.blinded.size())
			"deploy_robot":
				_add_view(event.robot)
				_hud.log_line("%s deploys the %s. It acts from next round" % [unit.display_name, event.robot.def.display_name.to_lower()])
			"connect":
				_hud.log_line("%s's AI connects at %s%s" % [unit.display_name, event.node.to_upper(), ", revealing the %s network" % event.network if event.revealed else ""])
			"disconnect":
				_hud.log_line("%s's AI is pulled out, its context kept" % unit.display_name)
			"agent_move":
				await _network.move_agent(unit, event.path)
				if event.loaded:
					_hud.log_line("%s's AI loads the movement chip" % unit.display_name)
			"hack":
				_float_text(_network.node_position(event.node) + Vector3(0, 1.0, 0), "+%d" % event.points, Color.WHITE)
				var extra := "" if event.linked == "" else ", +%d on %s" % [event.linked_points, event.linked.to_upper()]
				_hud.log_line("%s's AI hacks %s: +%d%s%s" % [unit.display_name, event.node.to_upper(), event.points, extra, ". Refund!" if event.refund else ""])
				_network.refresh()
				await get_tree().create_timer(0.3, false).timeout
			"breach":
				_hud.log_line("%s %s breached" % [state.node_def(event.node).display_name, event.node.to_upper()])
				if event.node == state.objective:
					_hud.log_line("Data secured. Get everyone to extraction!")
			"compact":
				_hud.log_line("%s's AI compacts: %dM to %dM%s" % [unit.display_name, event.before, unit.context, ", chips degraded" if not event.degraded.is_empty() else ""])
			"chip":
				var chip := state.chip_def(event.chip)
				_hud.log_line("%s's AI %s %s%s" % [unit.display_name, "uses" if event.used else "loads", chip.display_name,
					" on " + ", ".join(event.targets.map(func(target: Unit) -> String: return target.display_name)) if not event.targets.is_empty() else ""])
			"verb":
				_hud.log_line("%s %s %s" % [state.node_def(event.node).display_name, event.node.to_upper(), _verb_result(event)])
			"vehicle":
				await _level.drive(event.node, event.path)
				if event.struck:
					_hud.log_line("The %s hits %s!" % [state.node_def(event.node).display_name.to_lower(), event.struck.display_name])
			"door":
				_hud.log_line("%s: door %s %s" % [unit.display_name, event.node.to_upper(), {"open": "opened", "close": "closed", "lock": "locked"}[event.action]])
			"peek":
				_hud.log_line("%s peeks through %s" % [unit.display_name, event.node.to_upper()])
			"share":
				_hud.log_line("%s's AI gives 1 AP to %s's, for their next turn" % [unit.display_name, event.target.display_name])
			"turret_mode":
				_hud.log_line("Turret %s: %s" % [event.node.to_upper(), "targeting enemies" if event.mode == "target" else "holding fire"])
			"overwatch_set":
				_hud.log_line("%s sets overwatch" % unit.display_name)
			"crash":
				_hud.log_line("%s's AI crashed" % unit.display_name)
	_refresh()


# What a verb did, read from the device afterwards.
func _verb_result(event: Dictionary) -> String:
	var device: Dictionary = state.devices[event.node]
	match event.verb:
		"power":
			return "powered on" if device.powered else "powered off"
		"lock":
			return "locked" if device.locked else "unlocked"
	match state.map.node_kind(event.node):
		"autodoor":
			return "opens" if device.open else "closes"
		"phone":
			return "rings"
		"adscreen":
			return "flashes"
	return "drives"


func _who(unit: Unit) -> String:
	return unit.display_name if state.player_sees(unit) else "Someone"


func _log_responders(what: String, responders: Array) -> void:
	var seen := responders.filter(func(guard: Unit) -> bool: return state.player_sees(guard))
	if seen.is_empty():
		_hud.log_line(what)
	else:
		_hud.log_line("%s: %s goes to check" % [what, ", ".join(seen.map(func(guard: Unit) -> String: return guard.display_name))])


func _shoot(unit: Unit, target: Unit, overwatch: bool) -> void:
	var view: UnitView = _views[unit.id]
	var target_view: UnitView = _views[target.id]
	if overwatch:
		_hud.log_line("%s fires from overwatch!" % unit.display_name)
	if view.visible or target_view.visible:
		await view.fire_at(target_view.position)
		_tracer(view.position, target_view.position)
		await get_tree().create_timer(0.2, false).timeout


func _hit(event: Dictionary) -> void:
	var target: Unit = event.target
	var text: String = {"stunned": "STUNNED", "downed": "DOWN", "armor": "HIT"}[event.result]
	_views[target.id].take_hit(text)
	var by: String = _who(event.unit) if event.unit else "Something"
	match event.result:
		"stunned":
			_hud.log_line("%s stuns %s for %d turns" % [by, target.display_name, BattleState.STUN_TURNS])
		"downed":
			_hud.log_line("%s is down" % target.display_name)
		"armor":
			_hud.log_line("%s takes a hit: %d left" % [target.display_name, target.max_hits - target.hits])


# --- Showing the state ---------------------------------------------------------------------------

func _refresh() -> void:
	for id in _views:
		var unit: Unit = state.units[id]
		var view: UnitView = _views[id]
		view.refresh(state)
		view.position = _grid.cell_to_world(unit.cell)
	_level.update_nodes(state)
	_network.refresh()
	_refresh_fog()
	_refresh_cones()
	_refresh_lines()
	_refresh_scan()
	_update_objective()
	_hud.show_turn(state)


# Unseen tiles go dark and unseen enemies vanish; where one was last seen, a marker stays.
func _refresh_fog() -> void:
	_grid.set_visibility(state)
	for id in _views:
		var unit: Unit = state.units[id]
		var view: UnitView = _views[id]
		view.visible = state.player_sees(unit) or (unit.down and state.visible_cells.has(unit.cell))
	for id in _last_seen:
		var unit: Unit = state.units[id]
		var marker: Node3D = _last_seen[id]
		marker.visible = not _views[id].visible and state.known.has(id)
		if marker.visible:
			marker.position = _grid.cell_to_world(state.known[id])


# Every enemy cone the player can see, in its two tiers: the guards outside the fog, turrets, and
# the cameras still working for the enemy.
func _refresh_cones() -> void:
	var seen := {}
	var noticed := {}
	for viewer in Perception.viewers(state):
		if not viewer.camera and not state.player_sees(viewer.unit):
			continue
		var cells := Perception.cone_cells(state, viewer)
		for cell in cells:
			if cells[cell] == Perception.Tier.SEEN:
				seen[cell] = true
			else:
				noticed[cell] = true
	for cell in seen:
		noticed.erase(cell)
	_grid.set_overlay("cone_seen", seen.keys(), CONE_SEEN, 0.008, 0.0)
	_grid.set_overlay("cone_noticed", noticed.keys(), CONE_NOTICED, 0.008, 0.0)


# Aim lines, Predict's ghost paths, and a hub's circuit when the cursor is on it.
func _refresh_lines() -> void:
	for beam in _beams:
		beam.queue_free()
	_beams.clear()
	var aimed := []
	for unit in state.units:
		if unit.aim.is_empty():
			continue
		var cells: Array = unit.aim.cells
		aimed.append_array(cells)
		if not cells.is_empty():
			_add_beam(unit.cell, cells.back(), AIM_COLOR, 0.06)
	_grid.set_overlay("aim", aimed, Color(AIM_COLOR, 0.3), 0.02)
	for id in state.predicted:
		var guard: Unit = state.units[id]
		if not state.player_sees(guard) or guard.is_out():
			continue
		var ghost := state.prediction(guard)
		var path: Array = ghost.path
		for i in range(1, path.size()):
			_add_beam(path[i - 1], path[i], GHOST_COLOR, 0.05)
		if not ghost.aim.is_empty():
			_add_beam(path.back(), ghost.aim.back(), Color(GHOST_COLOR, 0.5), 0.04)


func _add_beam(from: Vector2i, to: Vector2i, color: Color, thickness: float) -> void:
	var beam := GridView.make_beam(thickness, color)
	add_child(beam)
	GridView.place_beam(beam, _grid.cell_to_world(from) + Vector3(0, BEAM_Y, 0), _grid.cell_to_world(to) + Vector3(0, BEAM_Y, 0))
	_beams.append(beam)


func _set_scan(shown: bool) -> void:
	_scan = shown
	_hud.set_scan_shown(shown)
	_refresh_scan()


# Hitman's Instinct, for devices: what each one is, its state, and what the team can do with it.
func _refresh_scan() -> void:
	var unit := state.active
	for id in _scan_labels:
		var label: Label3D = _scan_labels[id]
		label.visible = _scan and not _network_shown
		if not label.visible:
			continue
		var def := state.node_def(id)
		var device: Dictionary = state.devices[id]
		var lines: Array[String] = ["%s %s" % [def.display_name.to_upper(), id.to_upper()]]
		var known := state.revealed_networks.has(state.map.network_of(id))
		if def.kind == "access":
			lines.append("AI entry · " + state.map.network_of(id))
		elif not known:
			lines.append("network unknown")
		elif state.breached.has(id):
			var verbs := ", ".join(def.verbs) if not def.verbs.is_empty() else ("controls: target or hold" if def.kind == "turret" else "secured")
			lines.append("BREACHED   " + verbs)
		elif def.goal > 0:
			lines.append("Hack %d / %d   %s" % [state.progress.get(id, 0), def.goal, def.category])
		var status: Array[String] = []
		if def.verbs.has("power"):
			status.append("on" if device.powered else "off")
		if def.kind in BattleState.DOORS:
			status.append(("open" if device.open else "shut") + (", locked" if device.locked else ""))
		if def.sound_radius > 0:
			status.append("sound %d%s" % [def.sound_radius, " all" if def.sound_all else ""])
		if state.map.hub_of(id) != "":
			status.append("circuit " + state.map.hub_of(id).to_upper())
		if not status.is_empty():
			lines.append("  ·  ".join(status))
		label.text = "\n".join(lines)
		label.position = _grid.cell_to_world(state.node_cell(id)) + Vector3(0, _level.device_height(id) + 0.6, 0)
	if unit and _scan:
		var spots: Array[Vector2i] = []
		for line in state.map.receptacles:
			var key := line.replace(" ", ":")
			spots.append(state.receptacle_cell(key))
		_grid.set_overlay("scan_receptacles", spots, PLACE_COLOR, 0.025)
	else:
		_grid.clear_overlay("scan_receptacles")


func _update_objective() -> void:
	if not state.cache_breached:
		_hud.set_objective("Breach the data cache   /   %d of %d" % [state.progress.get(state.objective, 0), state.node_def(state.objective).goal])
		return
	var standing := state.operators().filter(func(unit: Unit) -> bool: return not unit.down).size()
	_hud.set_objective("Extract the team   /   %d of %d at extraction" % [state.extracted(), standing])


# What a verb would do, shown before it's used: the sound's reach and the guards it would draw. A
# guard the player can't see still comes, but isn't marked.
func _on_action_hovered(id: String) -> void:
	_clear_preview()
	if not id.begins_with("verb:") or not state.active:
		return
	var parts := id.split(":")
	var area := []
	var responders := []
	for event in state.verb_preview(state.active, parts[1], parts[2], parts[3].to_int()):
		if event.type == "sound":
			area.append_array(event.cells)
		if event.type in ["sound", "lure", "camera_report"]:
			for guard: Unit in event.responders:
				if state.player_sees(state.units[guard.id]):
					responders.append(state.units[guard.id].cell)
	_grid.set_overlay("preview_area", area, SOUND_COLOR, 0.03)
	_grid.set_overlay("preview_responders", responders, RESPONDER_COLOR, 0.04)
	if not area.is_empty() or not responders.is_empty():
		_hud.set_hint("Sound reaches the blue area. Marked guards would come to look; unseen ones may too.")


func _clear_preview() -> void:
	for layer in PREVIEW_LAYERS:
		_grid.clear_overlay(layer)


func _flash_area(cells: Array, color: Color) -> void:
	_grid.set_overlay("flash", cells, color, 0.035)
	get_tree().create_timer(0.6, false).timeout.connect(_grid.clear_overlay.bind("flash"))


# --- Network view --------------------------------------------------------------------------------

func _on_network_toggled(shown: bool) -> void:
	if _busy or _network_moving or state.active == null:
		_hud.set_network_shown(_network_shown)
		return
	_hud.close_menu()
	_clear_pick()
	_mode = Mode.IDLE
	await _set_network(shown)
	_refresh_scan()
	if state.is_player_controlled(state.active):
		_begin_control()


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
		await _camera_rig.overhead(_network.framing_bounds())
		await _network.fade_in()
	else:
		await _network.fade_out()
		await _camera_rig.restore_view()
	_network_moving = false


# --- Moving units on screen ----------------------------------------------------------------------

func _walk(unit: Unit, path: Array) -> void:
	var view: UnitView = _views[unit.id]
	var points: Array[Vector3] = []
	var shown: Array[bool] = []
	for cell in path:
		points.append(_grid.cell_to_world(cell))
		shown.append(unit.is_player() or state.visible_cells.has(cell) or unit.located > 0)
	if view.visible or shown.has(true):
		if _last_seen.has(unit.id):
			_last_seen[unit.id].hide()
		await view.walk(points, shown)
	elif not points.is_empty():
		view.position = points.back()


func _any_seen(events: Array[Dictionary]) -> bool:
	for event in events:
		if event.type in ["fire", "aim"]:
			return true
		if event.type == "move":
			for cell in event.path:
				if state.visible_cells.has(cell):
					return true
	return false


# A red ring on the floor with the enemy's name, not its body: the player knows where, not what now.
func _make_last_seen(unit: Unit) -> Node3D:
	var ring := TorusMesh.new()
	ring.inner_radius = 0.42
	ring.outer_radius = 0.5
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = LAST_SEEN_COLOR
	var mesh := MeshInstance3D.new()
	mesh.mesh = ring
	mesh.material_override = material
	mesh.scale = Vector3(1.0, 0.1, 1.0)
	mesh.position.y = 0.02
	var label := UnitView.make_label(36, 0.4)
	label.text = "%s\nlast seen" % unit.display_name
	label.modulate = Color(1, 0.7, 0.65, 0.8)
	var marker := Node3D.new()
	marker.add_child(mesh)
	marker.add_child(label)
	marker.visible = false
	add_child(marker)
	return marker


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
	GridView.place_beam(beam, from + Vector3(0, CHEST_Y, 0), to + Vector3(0, CHEST_Y, 0))
	var tween := create_tween()
	tween.tween_property(beam.material_override, "albedo_color:a", 0.0, 0.25)
	tween.tween_callback(beam.queue_free)


# --- Hover ---------------------------------------------------------------------------------------

func _update_hover() -> void:
	var mouse := get_viewport().get_mouse_position()
	var over_ui := _hud.is_menu_open() or get_viewport().gui_get_hovered_control() != null
	var token: Unit = null if over_ui else _token_at(mouse)
	var cell: Variant = null if over_ui else _pointed_cell(mouse, token)
	_hover.visible = cell != null and _is_choice(cell, token)
	if cell != _hovered:
		_hovered = cell
		_on_hover_changed(cell)
	if cell == null:
		_hud.set_hover("")
		return
	_hover.position = _grid.cell_to_world(cell) + Vector3(0, 0.02, 0)
	var text := _describe(cell)
	if token:
		_hover.position = _network.agent_position(token) * Vector3(1, 0, 1) + Vector3(0, 0.02, 0)
		text = "%s's AI    %s" % [token.display_name, text]
	_hud.set_hover(text)


# Hovering a power hub lights up its circuit; hovering a flashbang target shows the blast.
func _on_hover_changed(cell: Variant) -> void:
	var hub := state.node_at(cell) if cell != null else ""
	if hub != "" and state.map.node_kind(hub) == "hub":
		var members: Array[Vector2i] = []
		for member in state.map.circuit(hub):
			members.append(state.node_cell(member))
		_grid.set_overlay("circuit", members, CIRCUIT_COLOR, 0.03)
	else:
		_grid.clear_overlay("circuit")
	if _mode == Mode.PICK and _on_pick_hover.is_valid():
		if cell != null and _choices.has(cell):
			_on_pick_hover.call(cell)
		else:
			_grid.clear_overlay("preview_area")


func _describe(cell: Vector2i) -> String:
	var parts: Array[String] = ["Tile %d, %d" % [cell.x, cell.y]]
	var zone := state.map.zone_at(cell)
	if zone != "":
		parts[0] += "  ·  " + zone + ("  (caution %d)" % state.caution[zone] if state.caution.has(zone) else "")
	if state.map.night and not state.map.is_wall(cell):
		parts[0] += "  ·  " + ("lit" if state.is_lit(cell) else "dark")
	var unit := state.active
	if _mode == Mode.PICK and _choices.has(cell) and unit and (unit.is_operator() or unit.is_robot()):
		var cost: Variant = _choices[cell]
		if cost is int:
			parts.append("%d AP" % cost + ["", "   would get you NOTICED", "   would get you SEEN"][state.exposure(cell) if unit.is_player() else 0])
		if unit.is_operator() and unit.connected() and cost is int:
			parts.append("AI stays connected" if Grid.distance(cell, state.node_cell(unit.entry)) <= BattleState.TETHER else "AI will be pulled out")
	var other := state.unit_at(cell)
	if other and state.player_sees(other):
		parts.append(_unit_status(other))
	else:
		for id in state.known:
			if state.known[id] == cell and not state.player_sees(state.units[id]):
				parts.append("%s was last seen here" % state.units[id].display_name)
	var node := state.node_at(cell)
	if node != "":
		var def := state.node_def(node)
		var line := "%s %s" % [def.display_name, node.to_upper()]
		if state.breached.has(node):
			line += "  (breached)"
		elif def.goal > 0:
			line += "  breach %d/%d" % [state.progress.get(node, 0), def.goal]
		parts.append(line)
	var receptacle := state.receptacle_at(cell)
	if receptacle != "":
		var hidden := state.units.filter(func(body: Unit) -> bool: return body.receptacle == receptacle).size()
		parts.append("Hiding place%s" % (": %d inside" % hidden if hidden > 0 else ""))
	if not state.visible_cells.has(cell):
		parts.append("(no vision)")
	return "    ".join(parts)


func _unit_status(unit: Unit) -> String:
	if unit.is_operator():
		return "%s  hits left %d/%d" % [unit.display_name, unit.max_hits - unit.hits, unit.max_hits]
	var states := ["patrolling", "investigating", "ALERTED", "searching"]
	var text := "%s  %s" % [unit.display_name, states[unit.task]]
	if unit.tied:
		text = "%s  tied up" % unit.display_name
	elif unit.stun > 0:
		text = "%s  stunned, %d turns" % [unit.display_name, unit.stun]
	elif unit.blind > 0:
		text = "%s  blinded, %d turns" % [unit.display_name, unit.blind]
	return text


# What the cursor points at. An AI token stands for the node its AI is on, and a unit's body for its
# tile, since tall units hide the tiles behind them.
func _pointed_cell(screen_position: Vector2, token: Unit) -> Variant:
	if token:
		return state.node_cell(token.ai_node)
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
	for unit in state.units:
		if not unit.on_map() or not _views[unit.id].visible:
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
