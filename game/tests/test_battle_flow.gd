extends SceneTree

# The battle scene's way into the AI, driven through its real menus and clicks: deploying from the
# Operator's menu or the AI's switches to the network with the AI's menu open; a backpacked AI can
# go in by clicking a ringed access point in the network view; every turn starts on the physical
# view and the Operator's own menu. This broke once (2026-10-05).
# Run: godot --headless --path game -s tests/test_battle_flow.gd

var _battle: Node3D
var _failures := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_battle = load("res://battle/battle.tscn").instantiate()
	root.add_child(_battle)
	await _idle()
	var state: BattleState = _battle.state
	var alpha := state.active
	await _click(alpha.cell)
	await _press("Move")
	await _click(Vector2i(3, 13))
	await _press("AI   →")
	await _press("AI actions")
	_check(_title() == "ALPHA'S AI" and _menu().has("Deploy AI at A   1 AP"), "the backpacked AI's menu offers access point a: %s" % [_menu()])
	await _press("Deploy AI at A")
	_check(alpha.connected() and _battle._network_shown and _title() == "ALPHA'S AI", "deploying switches to the network with the AI's menu")
	await _press("End turn")
	var bravo := state.active
	_check(bravo.display_name == "Bravo" and not _battle._network_shown, "Bravo's turn starts in the physical view")
	await _click(bravo.cell)
	_check(_title() == "BRAVO", "Bravo's turn starts on his own menu, got %s" % _title())
	await _press("Move")
	await _click(Vector2i(4, 13))
	_battle._hud.close_menu()
	_battle._mode = _battle.Mode.IDLE
	await _battle._on_network_toggled(true)
	await _click(state.node_cell("a"))
	_check(bravo.connected() and _battle._network_shown and _title() == "BRAVO'S AI", "clicking a ringed access point sends the AI in")
	print("battle flow tests: " + ("all passed" if _failures == 0 else "%d failed" % _failures))
	quit(1 if _failures > 0 else 0)


func _idle() -> void:
	for i in 1200:
		await process_frame
		if not _battle._busy and not _battle._network_moving:
			return
	_check(false, "the battle never became idle")


func _title() -> String:
	return _battle._hud.get_node("%ActionTitle").text if _battle._hud.is_menu_open() else "<menu closed>"


func _menu() -> Array:
	if not _battle._hud.is_menu_open():
		return []
	return _buttons().map(func(button: Button) -> String: return button.text)


func _buttons() -> Array:
	return _battle._hud.get_node("%ActionList").get_children().filter(func(button: Node) -> bool: return not button.is_queued_for_deletion())


func _press(prefix: String) -> void:
	for button: Button in _buttons():
		if button.text.begins_with(prefix) and not button.disabled:
			button.pressed.emit()
			await _idle()
			return
	_check(false, "no '%s' to press in %s" % [prefix, _menu()])


func _click(cell: Vector2i) -> void:
	var at: Vector3 = _battle._grid.cell_to_world(cell)
	_battle._click(_battle.get_viewport().get_camera_3d().unproject_position(at))
	await _idle()


func _check(condition: bool, what: String) -> void:
	if not condition:
		_failures += 1
		printerr("FAIL: " + what)
