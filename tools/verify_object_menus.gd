extends SceneTree

var battle: Node3D
var output := ""
var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			output = arg.trim_prefix("--capture=")
	if not output.is_empty():
		DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(1280, 800)
	root.grab_focus()
	var map := MapData.new()
	map.layout = "# # # a # z #\n# . d1 P d2 . #\n# . . . . . #\n# # # X # # #"
	map.node_kinds = {"a": "access", "d1": "door", "d2": "door", "z": "cache"}
	map.links = PackedStringArray(["a-d1", "a-d2", "d2-z"])
	var content: BattleContent = load("res://content/battle.tres").duplicate()
	content.operators = content.operators.slice(0, 1)
	content.loadouts = content.loadouts.slice(0, 1)
	root.get_node("SceneRouter").session = BattleSession.from_presets(map, content)
	battle = load("res://battle/battle.tscn").instantiate()
	root.add_child(battle)
	await _idle()
	var state: BattleState = battle.state
	var actor := state.active
	var body := Unit.new(state.units.size(), content.guard, "Guard K", Vector2i(3, 2))
	body.stun = BattleState.STUN_TURNS
	state.units.append(body)
	battle._add_view(body)
	state.refresh()
	battle._refresh()
	battle._open_menu()
	_check(_row("Door D1") != null and _row("Door D2") != null and _row("Guard K") != null and _row("Interact") == null, "objects get separate top-level groups")
	await _capture("objects")
	await _press("Door D1")
	_check(_row("Open") != null and _row("Lock") != null and _row("Peek through") != null and _title().contains("DOOR D1"), "door submenu has short names and its object heading")
	await _capture("door-d1")
	await _mouse(Vector2(20, 400), MOUSE_BUTTON_RIGHT)
	_check(_row("Door D1") != null, "right-click returns from the object group")
	await _press("Door D2")
	await _key(KEY_ESCAPE)
	_check(_row("Door D2") != null, "Escape returns from the object group")
	await _press("Door D2")
	await _press("Peek through")
	_check(actor.peeks.has("d2") and not actor.peeks.has("d1"), "Peek keeps its own door id")
	await _press("Guard K")
	_check(_row("Tie up") != null and _row("Pick up") != null, "guard submenu contains the short body actions")
	await _capture("guard")
	await _press("Tie up")
	_check(body.tied and _row("Pick up Guard K") != null, "tying the guard leaves the one remaining action inline")
	await _press("Pick up Guard K")
	_check(actor.carrying == body.id and _row("Put down Guard K") != null and _row("Interact") == null, "Put down stays at top level")
	await _capture("carrying")
	await _press("Put down Guard K")
	await _click_cell(Vector2i(3, 2))
	_check(actor.carrying == -1 and body.cell == Vector2i(3, 2), "the original put-down picker still executes")
	await _press("Door D1")
	await _press("Open")
	_check(state.devices.d1.open and not state.devices.d2.open and _row("Close door D1") != null and _row("Door D1") == null, "one door action stays inline with its full name")
	await _capture("one-action")
	await _press("Close door D1")
	await _click_cell(state.node_cell("d1"))
	_check(_row("Open") != null and _row("Open door D1") == null and _title().begins_with("DOOR D1"), "direct door menu also uses short names")
	await _capture("direct-door")
	await _key(KEY_ESCAPE)
	await _press("AI")
	_check(battle._network_shown, "AI menu still opens from the object menu's parent")
	await _press("Operator")
	_check(not battle._network_shown and _row("Door D1") != null, "Network round trip restores current object choices")
	print("Native object menus: ", "passed" if failures == 0 else "FAILED", "; failures=", failures)
	quit(0 if failures == 0 else 1)


func _row(text: String) -> Button:
	for list in [battle._hud.get_node("%ActionList"), battle._hud.get_node("%FooterList")]:
		for child in list.get_children():
			if child is Button and child.text == text and not child.is_queued_for_deletion():
				return child
	return null


func _title() -> String:
	return battle._hud.get_node("%ActionTitle").text


func _press(text: String) -> void:
	await process_frame
	var row := _row(text)
	_check(row != null and not row.disabled, "menu offers " + text)
	if row:
		await _mouse(row.get_global_rect().get_center(), MOUSE_BUTTON_LEFT)


func _click_cell(cell: Vector2i) -> void:
	var at: Vector2 = root.get_camera_3d().unproject_position(battle._grid.cell_to_world(cell))
	await _mouse(at, MOUSE_BUTTON_LEFT)


func _mouse(at: Vector2, button: MouseButton) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = at
	root.push_input(motion, true)
	await process_frame
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = at
		event.global_position = at
		event.button_index = button
		event.pressed = pressed
		root.push_input(event, true)
		await process_frame
	await _idle()


func _key(code: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		root.push_input(event, true)
		await process_frame
	await _idle()


func _idle() -> void:
	for i in 300:
		await process_frame
		if not battle._busy and not battle._network_moving:
			await process_frame
			return
	_check(false, "native action finishes")


func _capture(label: String) -> void:
	for i in 20:
		await process_frame
	RenderingServer.force_draw(false)
	if not output.is_empty():
		root.get_texture().get_image().save_png(output.path_join(label + ".png"))


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		print("FAIL: ", message)
