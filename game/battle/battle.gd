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
const STOPPED_COLOR := Color(1.0, 0.8, 0.35)
const ENEMY_TURN_PAUSE := 0.35
const UNIT_HEIGHT := 1.7
# Where a tether leaves the pack and where shots fly, on a person 1.8 m tall.
const PACK_Y := 1.3
const CHEST_Y := 1.3
const TERMINAL_Y := 1.0
const PICK_RADIUS := 0.45
# Screen pixels around a scan badge that count as hovering it.
const BADGE_RADIUS := 30.0
const BEAM_Y := 0.35
const PICK_LAYERS: Array[String] = ["pick_safe", "pick_noticed", "pick_seen"]
const PREVIEW_LAYERS: Array[String] = ["preview_area", "preview_responders"]

@export var map: MapData
@export var content: BattleContent

var state: BattleState
var _views := {}
var _last_seen := {}
var _tethers := {}
var _scan_badges := {}
var _beams: Array[MeshInstance3D] = []
var _busy := true
var _mode := Mode.IDLE
# While picking: the tiles a click can choose, what to do with the one chosen, and what to show
# for the one under the cursor.
var _choices := {}
var _on_pick: Callable
var _on_pick_hover: Callable
var _predict_picks: Array[Unit] = []
# The submenus folded out of the menu last opened, by name.
var _menu_groups := {}
# The network view is the AI's half of the turn: its menus are the AI's, as the physical view's are
# the Operator's. _ended holds the halves the player has finished this turn, "operator" and "ai".
var _network_shown := false
var _ended := {}
var _network_moving := false
var _scan := false
var _hovered: Variant = null
var _card := {}

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
		_scan_badges[id] = _make_badge(state.map.node_kind(id))
	var team := Vector3.ZERO
	for cell in state.map.player_starts():
		team += _grid.cell_to_world(cell) / state.map.player_starts().size()
	_camera_rig.setup(team.lerp(_grid.center(), 0.28), _grid.extent())
	_hud.action_chosen.connect(_on_action)
	_hud.action_hovered.connect(_on_action_hovered)
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
		_on_action("end_half" if _hands_over(state.active) else "end")
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
			_ended.clear()
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
	_ring_nodes()
	_hud.show_turn(state)
	if _network_shown and state.active.is_operator() and not state.active.connected() and not state.deploy_options(state.active).is_empty():
		_hud.set_hint("Click a ringed access point to deploy the AI   %d AP" % BattleState.DEPLOY_AI_COST)
	_busy = false


# In the network view the active AI's node is ringed. An AI still in the backpack rings the access
# points it can go in at instead.
func _ring_nodes() -> void:
	var unit := state.active
	if not _network_shown or not unit.is_operator():
		_network.highlight([], "")
	elif unit.connected():
		_network.highlight([], unit.ai_node)
	else:
		_network.highlight(state.deploy_options(unit).map(func(option: Dictionary) -> String: return option.access), "")


# Every player action ends here: play what happened, then carry on with the turn or move on. The
# turn carries on in the unit's menu, or in the one open_next opens.
func _act(events: Array[Dictionary], open_next := Callable()) -> void:
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
	if open_next.is_valid():
		open_next.call()
	else:
		_open_menu()


# The access point a click in the network view would send the AI in at, and how: through its
# Operator if it's in reach, otherwise through a robot. Empty if it can't go in there.
func _deploy_option(unit: Unit, access: String) -> Dictionary:
	for option in state.deploy_options(unit):
		if option.access == access:
			return option
	return {}


# A tied Operator takes the turn from the start, in the physical view.
func _on_operator_chosen(id: int) -> void:
	if _busy or not state.choose_operator(state.units[id]):
		return
	_busy = true
	_hud.close_menu()
	_ended.clear()
	await _set_network(false)
	_refresh()
	_camera_rig.keep_in_view(_views[id].position)
	_begin_control()


# --- Menus ---------------------------------------------------------------------------------------

# Opens the active unit's menu for the view it's in, or the given actions under the given kicker.
func _open_menu(actions: Array = [], kicker := "") -> void:
	var unit := state.active
	var ai := _network_shown and unit.is_operator()
	_clear_pick()
	_clear_preview()
	_mode = Mode.MENU
	if actions.is_empty():
		if unit.is_robot():
			actions = BattleMenus.robot_actions(state, unit)
		elif ai:
			actions = BattleMenus.ai_actions(state, unit, _hands_over(unit))
		else:
			actions = BattleMenus.operator_actions(state, unit, _hands_over(unit))
		kicker = _who(unit)
		var nested := BattleMenus.nest(actions, "ai" if ai else "physical")
		actions = nested.top
		_menu_groups = nested.groups
	var anchor: Vector3 = _views[unit.id].position + Vector3(0, UNIT_HEIGHT, 0)
	if ai and unit.connected():
		anchor = _network.agent_position(unit)
	elif _network_shown:
		anchor = _views[unit.id].position
	_ring_nodes()
	var header := {"kicker": kicker, "accent": Hud.AI_ACCENT if ai else Hud.OPERATOR_ACCENT, "costs": BattleMenus.budget(unit, ai)}
	_hud.open_menu(get_viewport().get_camera_3d().unproject_position(anchor), actions, header)
	_hud.show_turn(state)


# Ending the half of the turn in view moves over to the other half, as long as that one hasn't been
# ended and still has AP to spend.
func _hands_over(unit: Unit) -> bool:
	if unit == null or not unit.is_operator():
		return false
	var other := "operator" if _network_shown else "ai"
	return not _ended.has(other) and BattleMenus.half_open(state, unit, other == "ai")


# Whose menu it is: the unit, or in the network view, its AI.
func _who(unit: Unit) -> String:
	return unit.display_name.to_upper() + ("'S AI" if _network_shown and unit.is_operator() else "")


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
		"ai", "physical":
			var network := parts[0] == "ai"
			if network != _network_shown:
				_busy = true
				await _set_network(network)
				_busy = false
			_open_menu()
		"group":
			_open_menu(_menu_groups[parts[1]], "%s  ·  %s" % [_who(unit), parts[1].to_upper()])
		"end":
			_act(state.end_turn(unit))
		"end_half":
			_ended["ai" if _network_shown else "operator"] = true
			_busy = true
			await _set_network(not _network_shown)
			_busy = false
			_open_menu()
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
			var before := state.breached.duplicate()
			_act(state.hack(unit, parts[1]), func() -> void: _open_breached(unit, before))
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
		"verb":
			_act(state.use_verb(unit, parts[1], parts[2], parts[3].to_int()))
		"turret":
			_act(state.set_turret_mode(unit, parts[1], parts[2]))
		"device":
			_open_device_menu(unit, parts[1], "group:Devices" if _menu_groups.has("Devices") else "ai")


# A hack that Breaches a device goes straight to its orders, with Back to the AI's menu.
func _open_breached(unit: Unit, before: Dictionary) -> void:
	var controlled := BattleMenus.controlled_devices(state, unit)
	for id in [unit.ai_node] + state.breached.keys():
		if not before.has(id) and controlled.has(id):
			_open_device_menu(unit, id)
			return
	_open_menu()


func _open_device_menu(unit: Unit, id: String, back := "ai") -> void:
	_open_menu(BattleMenus.device_actions(state, unit, id, back), "%s %s  ·  DEVICE" % [state.node_def(id).display_name.to_upper(), id.to_upper()])


func _use_chip(unit: Unit, id: String) -> void:
	match id:
		BattleState.LOCATE:
			_open_menu(BattleMenus.locate_actions(state), "LOCATE  ·  CHOOSE AN ENEMY")
		BattleState.PREDICT:
			_predict_picks.clear()
			_open_menu(BattleMenus.predict_actions(state, _predict_picks), "PREDICT  ·  CHOOSE A GUARD")
		_:
			_act(state.use_chip(unit, id))


func _on_predict(unit: Unit, id: int) -> void:
	if id >= 0:
		_predict_picks.append(state.units[id])
	if id < 0 or _predict_picks.size() >= state.chip_count(unit, BattleState.PREDICT) or BattleMenus.predict_actions(state, _predict_picks).size() <= 2:
		var picks := _predict_picks.duplicate()
		_predict_picks.clear()
		_act(state.use_chip(unit, BattleState.PREDICT, picks))
	else:
		_open_menu(BattleMenus.predict_actions(state, _predict_picks), "PREDICT  ·  AND WHO ELSE?")


# --- Picking targets -----------------------------------------------------------------------------

# Move tiles show how exposed each would leave the Operator: amber noticed, red seen.
func _pick_move(unit: Unit, sprint: bool) -> void:
	var costs := state.move_costs(unit, sprint)
	var exposures := state.exposures(costs.keys())
	var layers := [[], [], []]
	for cell in costs:
		layers[exposures[cell]].append(cell)
	_set_pick(costs, func(cell: Vector2i) -> void: _act(state.move(unit, cell, sprint)))
	for i in 3:
		_grid.set_overlay(PICK_LAYERS[i], layers[i], [MOVE_COLOR, NOTICED_COLOR, SEEN_COLOR][i])
	_hud.set_hint(("Sprint: " if sprint else "") + "choose a tile. Amber gets you noticed, red seen; spotting an enemy stops you there    ·    Right-click: back")


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


# With a menu open, a click closes it, and a click on something else the player can act on, such
# as a ringed access point, also acts on it. Clicking the menu's own unit just closes it.
func _click(screen_position: Vector2) -> void:
	var token := _token_at(screen_position)
	var cell: Variant = _pointed_cell(screen_position, token)
	if _hud.is_menu_open():
		_hud.close_menu()
		_mode = Mode.IDLE
		var own: bool = token == state.active if token else cell == state.active.cell
		if cell == null or own:
			return
	if cell == null or not _is_choice(cell, token):
		if _mode == Mode.IDLE and not _busy and _hud.viewed() != state.active:
			_hud.view_unit(state, null)
		return
	var unit := state.active
	var node := state.node_at(cell) if _network_shown else ""
	var teammate := _teammate_at(cell, token)
	match _mode:
		# Acting beats looking: a teammate's AI token on the access point doesn't stop a deploy.
		Mode.IDLE when _node_click(unit, node) == "deploy":
			_hud.view_unit(state, null)
			_act(state.deploy_ai(unit, node, _deploy_option(unit, node).relay))
		Mode.IDLE when teammate != null:
			_hud.view_unit(state, teammate)
		Mode.IDLE when token == null and _node_click(unit, node) == "device":
			_hud.view_unit(state, null)
			_open_device_menu(unit, node)
		Mode.IDLE:
			_hud.view_unit(state, null)
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
			var node := state.node_at(cell) if _network_shown else ""
			if _node_click(unit, node) == "deploy" or _teammate_at(cell, token) != null:
				return true
			if _network_shown:
				return token == unit if token else cell == unit.cell or _node_click(unit, node) != ""
			return cell == unit.cell
		Mode.PICK:
			return _choices.has(cell)
	return false


# What clicking a node in the network view does: the AI's own node opens its menu, an access point
# in reach sends a backpacked AI in, and a Breached device opens its verbs. Empty: nothing.
func _node_click(unit: Unit, node: String) -> String:
	if node == "" or not unit.is_operator():
		return ""
	if unit.connected() and node == unit.ai_node:
		return "menu"
	if not unit.connected() and not _deploy_option(unit, node).is_empty():
		return "deploy"
	if BattleMenus.controlled_devices(state, unit).has(node):
		return "device"
	return ""


# Clicking a teammate who isn't acting shows their panel instead of a menu.
func _teammate_at(cell: Vector2i, token: Unit) -> Unit:
	var other := token
	if other == null and not _network_shown:
		other = state.unit_at(cell)
	if other == null or other == state.active or other.down or not state.is_player_controlled(other):
		return null
	return other


# --- What happened -------------------------------------------------------------------------------

func _play(events: Array[Dictionary]) -> void:
	for event in events:
		var unit: Unit = event.get("unit")
		match event.type:
			"move":
				await _walk(unit, event.path)
			"sound":
				_flash_area(event.cells, SOUND_COLOR)
			"revealed", "blocked":
				if unit.is_player():
					_stopped_short(unit, event)
			"fire", "overwatch", "shot":
				await _shoot(unit, event.target)
			"hit":
				_views[event.target.id].take_hit({"stunned": "STUNNED", "downed": "DOWN", "armor": "HIT"}[event.result])
			"flashbang":
				_flash_area(event.cells, BLAST_COLOR)
			"deploy_robot":
				_add_view(event.robot)
			"agent_move":
				await _network.move_agent(unit, event.path)
			"hack":
				_float_text(_network.node_position(event.node) + Vector3(0, 1.0, 0), "+%d" % event.points, Color.WHITE)
				_network.refresh()
			"vehicle":
				await _level.drive(event.node, event.path)
		for line in BattleLog.lines(state, event):
			_hud.log_line(line)
		if event.type == "hack":
			await get_tree().create_timer(0.3, false).timeout
	_refresh()


# A move that stopped before the chosen tile says why over the unit, and what AP it didn't spend.
# The enemies that came into view flash.
func _stopped_short(unit: Unit, event: Dictionary) -> void:
	var why := "BLOCKED"
	if event.type == "revealed":
		why = "SPOTTED " + ", ".join(event.enemies.map(func(enemy: Unit) -> String: return enemy.display_name.to_upper()))
		_flash_area(event.enemies.map(func(enemy: Unit) -> Vector2i: return enemy.cell), Color(STOPPED_COLOR, 0.45), 1.2)
	var kept: int = event.get("kept", 0)
	var text := "STOPPED  ·  " + why + ("\n%d AP KEPT" % kept if kept > 0 else "")
	# Up and to the left of the unit, clear of its name and of the menu that opens to its right.
	var label := _float_text(_views[unit.id].position + Vector3(0, UNIT_HEIGHT + 0.9, 0), text, STOPPED_COLOR, 2.0, 40)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.offset.x = -55.0


func _shoot(unit: Unit, target: Unit) -> void:
	var view: UnitView = _views[unit.id]
	var target_view: UnitView = _views[target.id]
	if view.visible or target_view.visible:
		await view.fire_at(target_view.position)
		_tracer(view.position, target_view.position)
		await get_tree().create_timer(0.2, false).timeout


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
	for viewer in Perception.visible_viewers(state):
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


# What the team controls: a badge over every Breached device with its state. Hovering a badge
# shows the device's full card.
func _refresh_scan() -> void:
	for id in _scan_badges:
		var badge: Node3D = _scan_badges[id]
		badge.visible = _scan and not _network_shown and state.breached.has(id) and state.map.node_kind(id) != "access" and not state.is_hidden_turret(id)
		if not badge.visible:
			continue
		var status := NetworkView.status(state, id)
		badge.get_node("State").text = "%s   %s" % [id.to_upper(), status if status != "" else "BREACHED"]
		badge.position = _grid.cell_to_world(state.node_cell(id)) + Vector3(0, _level.device_height(id) + 0.6, 0)


func _make_badge(kind: String) -> Node3D:
	var badge := Node3D.new()
	var ring := Gradient.new()
	ring.offsets = PackedFloat32Array([0.0, 0.8, 0.84, 0.94, 0.97])
	ring.colors = PackedColorArray([Color(NetworkView.INK, 0.92), Color(NetworkView.INK, 0.92), NetworkView.BREACHED, NetworkView.BREACHED, Color(NetworkView.BREACHED, 0.0)])
	var disc_texture := GradientTexture2D.new()
	disc_texture.gradient = ring
	disc_texture.fill = GradientTexture2D.FILL_RADIAL
	disc_texture.fill_from = Vector2(0.5, 0.5)
	disc_texture.fill_to = Vector2(1.0, 0.5)
	disc_texture.width = 96
	disc_texture.height = 96
	var disc := _badge_sprite(disc_texture, 1)
	var icon := _badge_sprite(NetworkView.ICONS[kind], 2)
	icon.modulate = NetworkView.COLORS[kind]
	var label := UnitView.make_label(28, 0.0)
	label.name = "State"
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.offset = Vector2(0, -72)
	label.modulate = Color(0.8, 1.0, 0.9)
	label.render_priority = 4
	label.outline_render_priority = 3
	for part in [disc, icon, label]:
		badge.add_child(part)
	badge.visible = false
	add_child(badge)
	return badge


func _badge_sprite(texture: Texture2D, order: int) -> Sprite3D:
	var sprite := Sprite3D.new()
	sprite.texture = texture
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.no_depth_test = true
	sprite.fixed_size = true
	sprite.pixel_size = 0.0006 * 64.0 / texture.get_width()
	sprite.render_priority = order
	return sprite


# The device whose scan badge is under the cursor, if any.
func _badge_at(screen_position: Vector2) -> String:
	var camera := get_viewport().get_camera_3d()
	for id in _scan_badges:
		var badge: Node3D = _scan_badges[id]
		if badge.visible and not camera.is_position_behind(badge.position) and camera.unproject_position(badge.position).distance_to(screen_position) < BADGE_RADIUS:
			return id
	return ""


func _update_objective() -> void:
	if not state.cache_breached:
		_hud.set_objective("Breach the Prime Data Cache   /   %d of %d" % [state.progress.get(state.objective, 0), state.node_def(state.objective).goal])
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


func _flash_area(cells: Array, color: Color, seconds := 0.6) -> void:
	_grid.set_overlay("flash", cells, color, 0.035)
	get_tree().create_timer(seconds, false).timeout.connect(_grid.clear_overlay.bind("flash"))


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


# Rises and fades. A longer one holds before it fades, so it can be read.
func _float_text(at: Vector3, text: String, color: Color, seconds := 0.7, size := 56) -> Label3D:
	var label := UnitView.make_label(size, 0.0)
	label.render_priority = NetworkView.Order.LABEL + 2
	label.outline_render_priority = NetworkView.Order.LABEL + 1
	label.text = text
	label.modulate = color
	label.position = at
	add_child(label)
	var tween := create_tween()
	tween.tween_property(label, "position:y", at.y + 0.8, seconds)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.7).set_delay(seconds - 0.7)
	tween.tween_callback(label.queue_free)
	return label


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
	var card := {}
	if cell != null:
		_hover.position = _grid.cell_to_world(cell) + Vector3(0, 0.02, 0)
		var pick := {}
		var unit := state.active
		if _mode == Mode.PICK and _choices.get(cell) is int and unit and (unit.is_operator() or unit.is_robot()):
			pick = {"cost": _choices[cell], "mover": unit}
		card = HoverInfo.card(state, cell, pick, token)
	# The card is rebuilt only when what it says changes, not every frame.
	if card != _card:
		_card = card
		_hud.set_hover(card)


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


# What the cursor points at. An AI token stands for the node its AI is on, and a unit's body for its
# tile, since tall units hide the tiles behind them.
func _pointed_cell(screen_position: Vector2, token: Unit) -> Variant:
	if token:
		return state.node_cell(token.ai_node)
	if _scan and not _network_shown and _mode != Mode.PICK:
		var device := _badge_at(screen_position)
		if device != "":
			return state.node_cell(device)
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
