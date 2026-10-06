extends SceneTree

# The battle scene's way into the AI, driven through its real menus and clicks. The AI phase is the
# network view: choosing it always switches there and opens the AI's menu, deployed or not. A
# backpacked AI deploys from that menu or by clicking a ringed access point, even under a
# teammate's token. Every turn starts in the physical view on the Operator's own menu. This broke
# twice (2026-10-05).
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
	_check(_title() == "ALPHA  ·  OPERATOR PHASE", "clicking Alpha opens her menu, got %s" % _title())
	await _press("AI phase")
	_check(_battle._network_shown and _title() == "ALPHA'S AI  ·  AI PHASE", "the AI phase switches to the network even with the AI in the backpack")
	await _press("Operator phase")
	_check(not _battle._network_shown and _title() == "ALPHA  ·  OPERATOR PHASE", "the Operator phase switches back")
	await _press("Move")
	await _click(Vector2i(3, 13))
	await _press("AI phase")
	_check(_menu().has("Deploy at A"), "the backpacked AI's menu offers access point a: %s" % [_menu()])
	await _press("Deploy at A")
	_check(alpha.connected() and _battle._network_shown and _title() == "ALPHA'S AI  ·  AI PHASE", "after deploying, the AI's menu stays open in the network")
	await _press("End turn")
	var bravo := state.active
	_check(bravo.display_name == "Bravo" and not _battle._network_shown, "Bravo's turn starts in the physical view")
	await _click(bravo.cell)
	_check(_title() == "BRAVO  ·  OPERATOR PHASE", "Bravo's turn starts on his own menu, got %s" % _title())
	await _press("Move")
	await _click(Vector2i(4, 13))
	_battle._hud.close_menu()
	_battle._mode = _battle.Mode.IDLE
	await _battle._on_network_toggled(true)
	await _click(state.node_cell("a"))
	_check(bravo.connected() and _battle._network_shown and _title() == "BRAVO'S AI  ·  AI PHASE", "clicking a ringed access point under Alpha's token sends Bravo's AI in")
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


# The menu's rows by name, without a back row's arrow.
func _menu() -> Array:
	if not _battle._hud.is_menu_open():
		return []
	return _rows().map(func(row: Button) -> String: return row.text.trim_prefix("‹   "))


func _rows() -> Array:
	var rows := []
	for list in [_battle._hud.get_node("%ActionList"), _battle._hud.get_node("%FooterList")]:
		rows.append_array(list.get_children().filter(func(row: Node) -> bool: return row is Button and not row.is_queued_for_deletion()))
	return rows


func _press(name: String) -> void:
	for row: Button in _rows():
		if row.text.trim_prefix("‹   ").begins_with(name) and not row.disabled:
			row.pressed.emit()
			await _idle()
			return
	_check(false, "no '%s' to press in %s" % [name, _menu()])


func _click(cell: Vector2i) -> void:
	var at: Vector3 = _battle._grid.cell_to_world(cell)
	_battle._click(_battle.get_viewport().get_camera_3d().unproject_position(at))
	await _idle()


func _check(condition: bool, what: String) -> void:
	if not condition:
		_failures += 1
		printerr("FAIL: " + what)
