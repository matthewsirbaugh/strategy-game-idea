extends SceneTree

# Manual CPU comparison on the facility yard, with 20 warm-ups and five batches per query.
# Run from the project root: godot --headless --path game -s ../tools/profile_battle.gd
# Scene setup is a single startup observation; these timings do not measure rendered frames.

func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var started := Time.get_ticks_usec()
	var battle: Node3D = load("res://battle/battle.tscn").instantiate()
	root.add_child(battle)
	for i in 10:
		await process_frame
	print("scene_setup_ms=", (Time.get_ticks_usec() - started) / 1000.0)
	var state: BattleState = battle.state
	var unit := state.active
	unit.ai_node = "b"
	unit.entry = "b"
	unit.cell = state.node_cell("b") + Vector2i.RIGHT
	for id in state.devices:
		if state.map.node_kind(id) != "cache":
			state._breach(id)
	state.revealed_networks["Facility"] = true
	state.refresh()
	battle._refresh()
	print("fixture: ", state.map.resource_path, "; units=", state.units.size(), "; controlled_devices=", BattleMenus.controlled_devices(state, unit).size())
	var costs := state.move_costs(unit)
	_measure("network_menu_1000", func(): BattleMenus.ai_actions(state, unit), 1000)
	_measure("physical_menu_1000", func(): BattleMenus.operator_actions(state, unit), 1000)
	_measure("movement_queries_1000", func(): state.move_costs(unit), 1000)
	_measure("exposure_queries_100", func(): state.exposures(costs.keys()), 100)
	_measure("perception_refresh_100", func(): state.refresh(), 100)
	_measure("state_clones_100", func(): state.clone(), 100)
	_measure("verb_previews_100", func(): state.verb_preview(unit, "w", "power"), 100)
	_measure("network_labels_100", func(): battle._network.refresh(), 100)
	_measure("hover_cards_1000", func(): HoverInfo.card(state, unit.cell), 1000)
	var screen := battle.get_viewport().get_camera_3d().unproject_position(battle._views[unit.id].position)
	_measure("physical_picking_1000", func(): battle._unit_at_screen(screen), 1000)
	_measure("network_click_queries_1000", func(): battle._node_click(unit, "o"), 1000)
	for i in 10:
		battle._grid._process(1.0)
		battle._level._process(1.0)
	_measure("settled_fog_1000", func(): battle._grid._process(0.016), 1000)
	_measure("stationary_walls_1000", func(): battle._level._process(0.016), 1000)
	_measure("identical_overlays_100", func(): battle._grid.set_overlay("benchmark", costs.keys(), Color(0.3, 0.6, 1.0, 0.35)), 100)
	await process_frame
	quit()


func _measure(label: String, action: Callable, count: int) -> void:
	for i in 20:
		action.call()
	var samples := []
	for run in 5:
		var started := Time.get_ticks_usec()
		for i in count:
			action.call()
		samples.append((Time.get_ticks_usec() - started) / 1000.0)
	var ordered := samples.duplicate()
	ordered.sort()
	print(label, ": median_ms=", ordered[2], "; samples_ms=", samples)
