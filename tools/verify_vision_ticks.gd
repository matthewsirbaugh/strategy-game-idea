extends SceneTree

var output := ""
var battle: Node3D
var failures := 0
var samples: Array = []

const OBSERVER := '''extends "res://battle/battle.gd"
var review_label := ""
var review_actor := 0
var review_node := ""
var review_target := Vector2i.ZERO
var review_limit := 0
var review_output := ""
var review_frames: Array = []
var review_pending := 0

func _show_vision(tick: VisionTick) -> void:
	var started := Time.get_ticks_usec()
	super._show_vision(tick)
	var elapsed := Time.get_ticks_usec() - started
	if review_label.is_empty() or review_frames.size() >= review_limit:
		return
	var at: Vector3 = _level._devices[review_node].root.position if review_node != "" else _views[review_actor].position
	review_frames.append({"cell": str(_grid.world_to_cell(at)), "busy": _busy,
		"target_seen": tick.cells.has(review_target), "mask_seen": _grid.cell_visible(review_target),
		"actor_shown": tick.shown.has(review_actor), "display_us": elapsed})
	if not review_output.is_empty():
		review_pending += 1
		_review_frame.call_deferred(review_frames.size() - 1)

func _review_frame(index: int) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(review_output.path_join("%s-%02d.png" % [review_label, index + 1]))
	review_pending -= 1
'''


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			output = arg.trim_prefix("--capture=")
	root.size = Vector2i(1280, 800)
	if not output.is_empty():
		DirAccess.make_dir_recursive_absolute(output)
	var map := MapData.new()
	map.layout = ". . . . . . . . . . . . . X\nP . . . . . . . . . . . . z\n. . . . . . . . . . . . . ."
	map.node_kinds = {"z": "cache"}
	await _start(map, 2)
	var state: BattleState = battle.state
	var alpha := state.active
	var target := Vector2i(2, 0)
	var holder: Node3D = battle._level._place_root(battle._grid.cell_to_world(target), Vector2i(0, 1))
	battle._level._toon_body(holder, [[Vector3(0.8, 1.2, 0.8), Vector3(0, 0.6, 0), Color(0.1, 0.8, 0.7)]])
	SceneryFog.apply(holder)
	await _save("operator-before")
	await _play("operator", state.move(alpha, Vector2i(6, 1)), alpha.id, target)
	var seen: Array = battle.review_frames.map(func(frame: Dictionary) -> bool: return frame.target_seen)
	_check(seen == [true, true, true, false, false, false], "native playback preserves the midway reveal and loss")
	_check(battle.review_frames.all(func(frame: Dictionary) -> bool: return frame.busy and frame.target_seen == frame.mask_seen), "each movement frame applies vision while playback is busy")
	var robot_def: UnitDef = state.content.drone.duplicate()
	robot_def.sight = 2
	var robot := Unit.new(state.units.size(), robot_def, "Review drone", Vector2i(0, 1))
	state.units.append(robot)
	battle._add_view(robot)
	state.active = robot
	state.turn_over = false
	robot.ap = 8
	state.refresh()
	battle._refresh()
	var stationary := alpha.cell
	await _play("drone", state.move(robot, Vector2i(6, 2)), robot.id, target)
	_check(alpha.cell == stationary and battle.review_frames.any(func(frame: Dictionary) -> bool: return frame.target_seen), "a drone reveals while its Operator stays still")
	var guard_def: UnitDef = state.content.guard.duplicate()
	guard_def.move = 8
	guard_def.seen_range = 0
	guard_def.noticed_range = 0
	var guard := Unit.new(state.units.size(), guard_def, "Review guard", Vector2i(1, 0))
	guard.route.assign([Vector2i(1, 0), Vector2i(10, 0)])
	state.units.append(guard)
	battle._add_view(guard)
	state.active = guard
	state.turn_over = false
	state.refresh()
	battle._refresh()
	await _play("enemy", state.take_automatic_turn(), guard.id, target)
	var shown: Array = battle.review_frames.map(func(frame: Dictionary) -> bool: return frame.actor_shown)
	_check(shown.has(true) and shown.has(false) and not shown.back(), "an enemy crosses sight and leaves it during one action")
	map = MapData.new()
	map.layout = ". . . . . . . . . . . . . X\nP a . r . . . . . . . . . z\n. . . . . . . . . . . . . .\n. . . . . k . . . . . . . .\n. . . . . . . . . . . . . .\n. . . . . . . . . . . . . ."
	map.node_kinds = {"a": "access", "r": "car", "k": "camera", "z": "cache"}
	map.node_facings = {"r": "south", "k": "east"}
	map.links = PackedStringArray(["a-r", "a-k"])
	await _start(map, 8)
	state = battle.state
	alpha = state.active
	state.deploy_ai(alpha, "a")
	alpha.ai_node = "r"
	state.breached["r"] = true
	state.refresh()
	battle._refresh()
	target = Vector2i(6, 1)
	_check(not state.visible_cells.has(target), "the car starts across the Operator's sight line")
	await _play("vehicle-power", state.use_verb(alpha, "r", "power"), alpha.id, target)
	await _play("vehicle", state.use_verb(alpha, "r", "activate"), alpha.id, target, "r")
	_check(battle.review_frames.size() == 4 and battle.review_frames[0].target_seen, "a vehicle uncovers sight on its first square, not its last")
	alpha.ai_node = "k"
	await _play("camera-chip", state.load_chip(alpha, "surveillance_exploit"), alpha.id, target)
	target = Vector2i(11, 3)
	_check(not state.visible_cells.has(target), "the camera target starts beyond Operator sight")
	await _play("camera", state.hack(alpha), alpha.id, target)
	_check(state.breached.has("k") and battle._grid.cell_visible(target), "camera breach grants scenery vision")
	guard_def = state.content.guard.duplicate()
	guard_def.seen_range = 0
	guard_def.noticed_range = 0
	guard = Unit.new(state.units.size(), guard_def, "Locate target", Vector2i(13, 5))
	state.units.append(guard)
	battle._add_view(guard)
	await _play("camera-off", state.use_verb(alpha, "k", "power"), alpha.id, guard.cell)
	_check(not battle._views[guard.id].visible and not battle._grid.cell_visible(guard.cell), "camera power-off removes its sight")
	await _play("locate", state.use_chip(alpha, BattleState.LOCATE, [guard]), alpha.id, guard.cell)
	_check(battle._views[guard.id].visible and not battle._grid.cell_visible(guard.cell), "Locate shows the enemy without granting surrounding scenery")
	map = MapData.new()
	map.layout = "# a # # # z #\n# P . d . X #\n# # # # # # #"
	map.node_kinds = {"a": "access", "d": "door", "z": "cache"}
	map.links = PackedStringArray(["a-d", "d-z"])
	await _start(map, 6)
	state = battle.state
	alpha = state.active
	await _play("door-approach", state.move(alpha, Vector2i(2, 1)), alpha.id, Vector2i(4, 1))
	target = Vector2i(4, 1)
	_check(not battle._grid.cell_visible(target), "a closed door blocks the far side")
	await _play("door-open", state.use_door(alpha, "d", "open"), alpha.id, target)
	_check(battle._grid.cell_visible(target) and not battle._level._devices.d.model.visible, "opening a door reveals its far side")
	await battle._on_network_toggled(true)
	await battle._on_network_toggled(false)
	_check(battle._grid.cell_visible(target), "the current vision survives a Network round trip")
	await _yard_timing()
	if not output.is_empty():
		var file := FileAccess.open(output.path_join("samples.json"), FileAccess.WRITE)
		file.store_string(JSON.stringify(samples, "\t"))
	print("Native vision ticks: ", "passed" if failures == 0 else "FAILED", "; failures=", failures)
	quit(0 if failures == 0 else 1)


func _start(map: MapData, sight: int, full_team := false) -> void:
	if is_instance_valid(battle):
		battle.queue_free()
		await process_frame
	root.get_node("SceneRouter").session = null
	var content: BattleContent = load("res://content/battle.tres").duplicate()
	if not full_team:
		var operator: UnitDef = content.operators[0].duplicate()
		operator.sight = sight
		content.operators = [operator]
		content.loadouts = content.loadouts.slice(0, 1)
	var observer := GDScript.new()
	observer.source_code = OBSERVER
	_check(observer.reload() == OK, "the native observer compiles")
	battle = load("res://battle/battle.tscn").instantiate()
	battle.set_script(observer)
	battle.map = map
	battle.content = content
	root.add_child(battle)
	await process_frame
	battle._hud.hide()
	battle.review_output = output
	if full_team:
		battle._hud.show()
		return
	var rig: CameraRig = battle._camera_rig
	if rig._focus_tween:
		rig._focus_tween.kill()
	rig.position = battle._grid.cell_to_world(Vector2i(3, 1))
	rig._set_yaw(0)
	rig._set_pitch(60)
	rig._set_distance(14)


func _play(label: String, events: Array[Dictionary], actor: int, target: Vector2i, node := "") -> void:
	_check(not events.is_empty(), label + " produced an action")
	if events.is_empty():
		return
	battle.review_label = label
	battle.review_actor = actor
	battle.review_target = target
	battle.review_node = node
	battle.review_frames.clear()
	battle.review_limit = 1
	for event in events:
		if event.type in ["move", "vehicle"]:
			battle.review_limit = event.path.size()
	battle._busy = true
	await battle._play(events)
	battle._busy = false
	while battle.review_pending > 0:
		await process_frame
	samples.append({"action": label, "frames": battle.review_frames.duplicate(true)})
	battle.review_label = ""


func _yard_timing() -> void:
	await _start(load("res://content/maps/facility_yard.tres"), 6, true)
	for i in 60:
		await process_frame
	var state: BattleState = battle.state
	samples.append({"action": "yard-fixture", "operators": state.operators().size(), "units": state.units.size(), "map_size": str(state.map.size), "viewport": str(root.size)})
	var original := state.units[0].cell
	var positions: Array = state.move_costs(state.active).keys()
	for run in 5:
		var worst := 0
		var worst_display := 0
		for step in 120:
			state.units[0].cell = positions[step % positions.size()]
			state.refresh()
			var begin := Time.get_ticks_usec()
			var tick := VisionTick.capture(state)
			var captured := Time.get_ticks_usec()
			battle._show_vision(tick)
			var ended := Time.get_ticks_usec()
			worst = maxi(worst, ended - begin)
			worst_display = maxi(worst_display, ended - captured)
		samples.append({"action": "yard-timing", "run": run + 1, "capture_and_display_worst_us": worst, "display_worst_us": worst_display})
	state.units[0].cell = original
	state.refresh()
	battle._refresh()
	for i in 60:
		await process_frame
	samples.append({"action": "yard-settled", "draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)})
	await _save("yard-final")


func _save(label: String) -> void:
	for i in 20:
		await process_frame
	await RenderingServer.frame_post_draw
	if not output.is_empty():
		root.get_texture().get_image().save_png(output.path_join(label + ".png"))


func _check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		print("FAIL: ", message)
