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
	root.size = Vector2i(1280, 800)
	var map := MapData.new()
	map.layout = "# a # # # # z #\n# P . o . . X #\n# # # # # # # #"
	map.node_kinds = {"a": "access", "o": "autodoor", "z": "cache"}
	map.links = PackedStringArray(["a-o", "o-z"])
	var content: BattleContent = load("res://content/battle.tres").duplicate()
	var loadout := Loadout.new()
	loadout.chips = PackedStringArray(["extended_thinking", "locate", "predict"])
	content.operators = [content.operators[0]]
	content.loadouts = [loadout]
	root.get_node("SceneRouter").session = BattleSession.from_presets(map, content)
	battle = load("res://battle/battle.tscn").instantiate()
	root.add_child(battle)
	var state: BattleState = battle.state
	var actor := state.active
	actor.ap = 0
	await battle._on_action("ai")
	var deploy_note: Dictionary = BattleMenus.ai_actions(state, actor).filter(func(action: Dictionary): return action.get("style", "") == "note")[0]
	_check(deploy_note.blocker == "no_ap" and deploy_note.text == BattleMenus.blocker_text("no_ap", "deploy", {"cost": BattleState.DEPLOY_AI_COST, "unit": actor.display_name}), "deploy note uses the rules code and formatted cost")
	_check(battle._hud.get_node("%ActionList").find_children("*", "Label", true, false).any(func(label: Label): return label.text == deploy_note.text and label.is_visible_in_tree()), "deploy refusal reaches the native menu")
	await _capture("deploy-no-ap")
	actor.ap = 2
	state.deploy_ai(actor, "a")
	state._breach("o")
	state.devices.o.powered = false
	battle._refresh()
	battle._open_device_menu(actor, "o")
	await _refusal("Open", "no_power", "")
	await _capture("device-no-power")
	actor.next_hack[BattleState.EXTENDED_THINKING] = true
	battle._open_menu()
	await battle._on_action("group:Chips")
	await _refusal("Extended thinking", "waiting", BattleState.EXTENDED_THINKING)
	await _capture("chip-waiting")
	await battle._on_action("physical")
	actor.cell = Vector2i(2, 1)
	battle._views[actor.id].position = battle._grid.cell_to_world(actor.cell)
	state.devices.o.locked = true
	state.refresh()
	battle._refresh()
	battle._open_menu(BattleMenus.door_actions(state, actor, "o"), "DOOR O")
	await _refusal("Open", "locked", "door")
	await _capture("door-locked")
	print("Native blocker menus: ", "passed" if failures == 0 else "FAILED")
	battle.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)


func _refusal(label: String, code: String, kind: String) -> void:
	await process_frame
	var row: Button = null
	for child in battle._hud.get_node("%ActionList").get_children():
		if child is Button and child.text == label and not child.is_queued_for_deletion():
			row = child
	_check(row != null, "native menu contains " + label)
	if row == null:
		return
	_check(row.disabled and row.tooltip_text == BattleMenus.blocker_text(code, kind), "native disabled row has the correct refusal: " + label)
	row.mouse_entered.emit()
	_check(battle._hud._menu_note.text == row.tooltip_text, "hover displays the refusal: " + label)


func _capture(label: String) -> void:
	for i in 20:
		await process_frame
	await RenderingServer.frame_post_draw
	if not output.is_empty():
		root.get_texture().get_image().save_png(output.path_join(label + ".png"))


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		print("FAIL: ", message)
