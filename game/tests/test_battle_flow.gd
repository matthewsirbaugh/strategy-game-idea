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
	# The clicks below are laid out on this map.
	_battle.map = load("res://content/maps/facility_exterior.tres")
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
	await _doors_and_network_options()
	_device_menu_rules()
	print("battle flow tests: " + ("all passed" if _failures == 0 else "%d failed" % _failures))
	quit(1 if _failures > 0 else 0)


func _doors_and_network_options() -> void:
	_battle.queue_free()
	await process_frame
	var map := MapData.new()
	map.layout = "# a # # # z #\n# P . d . X #\n# # # # # # #"
	map.node_kinds = {"a": "access", "d": "door", "z": "cache"}
	map.links = PackedStringArray(["a-d", "d-z"])
	map.node_states = {"d": "locked"}
	var content: BattleContent = load("res://content/battle.tres").duplicate()
	var loadout := Loadout.new()
	loadout.chips = PackedStringArray(["locate", "predict", "extended_thinking"])
	content.operators = [content.operators[0]]
	content.loadouts = [loadout]
	root.get_node("SceneRouter").session = BattleSession.from_presets(map, content)
	_battle = load("res://battle/battle.tscn").instantiate()
	root.add_child(_battle)
	await _idle()
	var state: BattleState = _battle.state
	var alpha := state.active
	await _click(alpha.cell)
	await _press("Move")
	await _click(Vector2i(2, 1))
	await _click(state.node_cell("d"))
	_check(_menu().has("Open door D"), "clicking a locked adjacent door shows its contextual actions")
	var open := _row("Open door D")
	_check(open != null and open.disabled and open.tooltip_text.contains("network"), "the locked door explains how to unlock it")
	await _cancel()
	await _press("AI")
	await _press_mouse("Chips")
	var undeployed := _row("Extended thinking")
	_check(undeployed != null and undeployed.disabled and undeployed.tooltip_text.contains("Deploy"), "chips explain that an undeployed AI must connect first")
	await _cancel()
	await _press("Deploy at A")
	await _press("Move")
	await _click(state.node_cell("d"))
	await _press("Hack D")
	_check(_menu().has("Unlock"), "breaching a locked door opens its Unlock control")
	var context := alpha.context
	var ai_ap := alpha.ai_ap
	await _press("Unlock")
	_check(not state.devices.d.locked and not state.devices.d.open, "unlocking leaves the door closed")
	_check(alpha.context == context + BattleState.VERB_CONTEXT and alpha.ai_ap == ai_ap, "unlock costs context and no AI AP")
	await _press_mouse("Devices")
	await _press_mouse(state.node_def("d").display_name + " D")
	var lock := _row("Lock")
	_check(lock != null and lock.disabled and lock.tooltip_text == "Already used this turn.", "a used device verb stays inspectable with its blocker")
	await _cancel(true)
	_check(_title().contains("DEVICES"), "right-click returns from a device to its group")
	await _cancel()
	_check(_title() == "ALPHA'S AI", "Escape returns from the group to the AI")
	await _press("Chips")
	_check(_row("Locate").disabled and _row("Locate").tooltip_text.contains("unseen"), "Locate explains its missing target")
	_check(_row("Predict").disabled and _row("Predict").tooltip_text.contains("visible guard"), "Predict explains its missing target")
	context = alpha.context
	ai_ap = alpha.ai_ap
	_check(_cost_tags("Extended thinking") == ["+10M", "1 AI AP"], "the unloaded chip shows its load and use costs")
	await _press("Extended thinking")
	_check(alpha.next_hack.has(BattleState.EXTENDED_THINKING), "the active chip is ready for the next hack")
	_check(alpha.context == context + 10 and alpha.ai_ap == ai_ap - 1 and alpha.chips[BattleState.EXTENDED_THINKING] == 2, "the unloaded active chip loads once for 10 context and uses one AI AP")
	await _press("Chips")
	var ready := _row("Extended thinking")
	_check(ready != null and ready.disabled and ready.tooltip_text != "", "the all-disabled Chips group remains browsable")
	ready.mouse_entered.emit()
	_check(_battle._hud._menu_note.text == ready.tooltip_text, "hovering an unavailable action shows its blocking reason")
	await _cancel()
	await _chip_refreshes(alpha)
	await _press("Operator")
	await _click(state.node_cell("d"))
	await _press("Open door D")
	_check(state.devices.d.open and not state.blocks_walk(state.node_cell("d")), "opening makes the doorway walkable")
	_check(not _battle._level._devices.d.model.visible, "the open door's model no longer blocks the view")
	var body := Unit.new(state.units.size(), content.guard, "Doorway guard", state.node_cell("d"))
	body.stun = 3
	state.units.append(body)
	_battle._add_view(body)
	state.refresh()
	_battle._refresh()
	await _click(state.node_cell("d"))
	var close := _row("Close door D")
	_check(close != null and close.disabled and close.tooltip_text.contains("occupied"), "an occupied doorway cannot be closed")
	_check(state.use_door(alpha, "d", "close").is_empty(), "the rules also reject closing the occupied doorway")
	body.down = true
	state.refresh()
	_battle._refresh()
	await _cancel()
	await _press("Move")
	var ap := alpha.ap
	await _click(Vector2i(4, 1))
	_check(alpha.cell == Vector2i(4, 1) and alpha.ap == ap - 2, "walking through the open door reaches the far side for two AP")
	await _click(state.node_cell("d"))
	await _press("Close door D")
	_check(not state.devices.d.open and state.blocks_walk(state.node_cell("d")), "closing blocks the doorway again")
	_check(not state.move_costs(alpha).has(Vector2i(2, 1)), "the closed door blocks routes through it")
	await _click(state.node_cell("d"))
	await _press("Open door D")
	_check(state.move_costs(alpha).has(Vector2i(2, 1)), "reopening immediately restores routes through the door")


func _chip_refreshes(alpha: Unit) -> void:
	await _press("End AI phase")
	await _press("End turn")
	await _click(alpha.cell)
	await _press("AI")
	await _press("Chips")
	var loaded := _row("Extended thinking")
	_check(not loaded.disabled and _cost_tags("Extended thinking") == ["1 AI AP"], "the loaded chip is available again next turn without a load cost")
	await _cancel()
	await _press("Compact")
	await _press("Chips")
	var degraded := _row("Extended thinking")
	_check(alpha.chips[BattleState.EXTENDED_THINKING] == 1 and degraded.tooltip_text.contains("1.5"), "compaction refreshes the chip's degraded effect")
	var context := alpha.context
	await _press("Extended thinking")
	_check(alpha.context == context and alpha.ai_ap == 0, "using a degraded loaded chip costs AI AP without loading again")
	await _press("End AI phase")
	await _press("End turn")
	await _click(alpha.cell)
	await _press("AI")
	await _press("Compact")
	await _press("Chips")
	_check(alpha.chips[BattleState.EXTENDED_THINKING] == 0 and not _row("Extended thinking").disabled, "a second compaction unloads the chip and leaves its action browsable")
	context = alpha.context
	await _press("Extended thinking")
	_check(alpha.context == context + 10 and alpha.chips[BattleState.EXTENDED_THINKING] == 2, "using the unloaded chip loads it again for its listed cost")


func _device_menu_rules() -> void:
	var state := BattleSession.from_presets(load("res://content/maps/facility_yard.tres"), load("res://content/battle.tres")).start()
	var alpha := state.begin_next_turn()
	alpha.ai_node = "b"
	alpha.entry = "b"
	alpha.cell = state.node_cell("b") + Vector2i.RIGHT
	_check(BattleMenus.controlled_devices(state, alpha).is_empty(), "devices require a breach before their controls appear")
	for id in state.devices:
		if state.map.node_kind(id) != "cache":
			state._breach(id)
	var controlled := BattleMenus.controlled_devices(state, alpha)
	_check(controlled.has("o") and not controlled.has("d"), "device access follows the connected network even after both are breached")
	_check(not Devices.can_use(state, alpha, "d", "lock"), "the rules reject a verb on another network")
	state.devices.o.powered = false
	var actions := BattleMenus.device_actions(state, alpha, "o")
	var opening: Dictionary = actions.filter(func(action: Dictionary) -> bool: return action.text == "Open")[0]
	_check(not opening.enabled and opening.tip == "Needs power first.", "an automatic door explains its power requirement")
	var context := alpha.context
	var ap := alpha.ai_ap
	state.use_verb(alpha, "o", "power")
	_check(state.devices.o.powered and alpha.context == context + 5 and alpha.ai_ap == ap, "power on has the listed context cost and no AP cost")
	state.use_verb(alpha, "o", "activate")
	actions = BattleMenus.device_actions(state, alpha, "o")
	var closing: Dictionary = actions.filter(func(action: Dictionary) -> bool: return action.text == "Close")[0]
	_check(state.devices.o.open and not closing.enabled and closing.tip == "Already used this turn.", "activation updates its label and enforces the AI's verb limit")
	state.set_turret_mode(alpha, "t", "target")
	_check(BattleMenus.device_actions(state, alpha, "t")[0].text == "Hold fire", "turret controls name the operation that changes its current mode")
	var bravo: Unit = state.operators()[1]
	state.active = bravo
	bravo.ap = bravo.base_ap
	bravo.ai_node = "b"
	bravo.entry = "b"
	bravo.cell = state.node_cell("b") + Vector2i(1, -1)
	_check(Devices.can_use(state, bravo, "o", "activate"), "another AI has its own use of the same verb")
	for option in state.verb_options(bravo):
		var preview := state.clone()
		var result := preview.use_verb(preview.active, option.node, option.verb, option.direction)
		_check(option.enabled == not result.is_empty(), "device availability agrees with execution for %s:%s" % [option.node, option.verb])


func _cost_tags(text: String) -> Array:
	return _row(text).get_child(0).get_children().map(func(tag: Node) -> String: return tag.get_child(0).text)


func _row(text: String) -> Button:
	for row: Button in _rows():
		if row.text == text:
			return row
	return null


func _cancel(right_click := false) -> void:
	var event: InputEvent
	if right_click:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_RIGHT
		click.pressed = false
		event = click
	else:
		var key := InputEventKey.new()
		key.keycode = KEY_ESCAPE
		key.physical_keycode = KEY_ESCAPE
		key.pressed = true
		event = key
	_battle._hud._input(event)
	await _idle()


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


func _press_mouse(name: String) -> void:
	await process_frame
	var row := _row(name)
	if row == null or row.disabled:
		_check(false, "no '%s' to click in %s" % [name, _menu()])
		return
	var motion := InputEventMouseMotion.new()
	motion.position = row.get_viewport_transform() * row.get_global_rect().get_center()
	Input.parse_input_event(motion)
	await process_frame
	for pressed in [true, false]:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.position = motion.position
		click.pressed = pressed
		Input.parse_input_event(click)
		await process_frame
	await _idle()
	_check(_battle._hud.is_menu_open(), "clicking '%s' keeps its submenu open" % name)


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
