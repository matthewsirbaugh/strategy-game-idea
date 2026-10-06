extends SceneTree

# The battle scene's two halves of a turn, driven through its real menus, clicks and keys. "AI"
# switches to the network view and the AI's menu, deployed or not; a backpacked AI deploys from that
# menu or by clicking a ringed access point. Ending one half while the other still has AP to spend
# moves over to it, by the end row or Space; ending both ends the turn. Every turn starts in the
# physical view on the Operator's own menu. This broke twice (2026-10-05).
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
	_check(_title() == "ALPHA", "clicking Alpha opens her menu, got %s" % _title())
	await _press("AI")
	_check(_battle._network_shown and _title() == "ALPHA'S AI", "AI switches to the network even with the AI in the backpack")
	_check(_menu().has("End AI phase"), "with Alpha's AP left, the AI's end row hands back to her: %s" % [_menu()])
	await _press("Operator")
	_check(not _battle._network_shown and _title() == "ALPHA", "Operator switches back")
	await _press("Move")
	await _click(Vector2i(3, 13))
	_check(_menu().has("End Operator phase"), "next to an access point, the Operator's end row hands over to the AI: %s" % [_menu()])
	await _key(KEY_SPACE)
	_check(_battle._network_shown and _title() == "ALPHA'S AI", "Space ends the Operator's half and moves to the AI")
	_check(_menu().has("Deploy at A") and _menu().has("End turn"), "the AI can deploy, and ending its half now ends the turn: %s" % [_menu()])
	await _press("Deploy at A")
	_check(alpha.connected() and _battle._network_shown and _title() == "ALPHA'S AI", "after deploying, the AI's menu stays open in the network")
	await _press("End turn")
	var bravo := state.active
	_check(bravo.display_name == "Bravo" and not _battle._network_shown, "Bravo's turn starts in the physical view")
	await _click(bravo.cell)
	_check(_title() == "BRAVO" and _menu().has("End turn"), "with nothing for his AI to spend AP on, Bravo just ends the turn: %s" % [_menu()])
	await _press("Move")
	await _click(Vector2i(4, 13))
	await _press("AI")
	await _click(state.node_cell("a"))
	_check(bravo.connected() and _title() == "BRAVO'S AI", "clicking the ringed access point under Alpha's pin sends Bravo's AI in")
	await _press("End AI phase")
	_check(not _battle._network_shown and _title() == "BRAVO" and _menu().has("End turn"), "ending the AI's half goes back to Bravo to finish: %s" % [_menu()])
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
	return _rows().map(func(row: Button) -> String: return row.text)


func _rows() -> Array:
	var rows := []
	for list in [_battle._hud.get_node("%ActionList"), _battle._hud.get_node("%FooterList")]:
		rows.append_array(list.get_children().filter(func(row: Node) -> bool: return row is Button and not row.is_queued_for_deletion()))
	return rows


func _press(name: String) -> void:
	for row: Button in _rows():
		if row.text == name and not row.disabled:
			row.pressed.emit()
			await _idle()
			return
	_check(false, "no '%s' to press in %s" % [name, _menu()])


func _key(keycode: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	event.pressed = true
	_battle._unhandled_input(event)
	await _idle()


func _click(cell: Vector2i) -> void:
	var at: Vector3 = _battle._grid.cell_to_world(cell)
	_battle._click(_battle.get_viewport().get_camera_3d().unproject_position(at))
	await _idle()


func _check(condition: bool, what: String) -> void:
	if not condition:
		_failures += 1
		printerr("FAIL: " + what)
