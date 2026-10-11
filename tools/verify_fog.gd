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
	battle = load("res://battle/battle.tscn").instantiate()
	root.add_child(battle)
	await _capture("level-initial")
	var state: BattleState = battle.state
	var level: LevelView = battle._level
	var grid: GridView = battle._grid
	for view: UnitView in battle._views.values():
		_check(view.find_children("FogBox", "MeshInstance3D", true, false).is_empty(), "characters have no scenery proxies")
	var car: Dictionary = level._devices["r"]
	var car_cell := Vector2i(13, 13)
	state.devices["r"].cell = car_cell
	car.root.position = grid.cell_to_world(car_cell)
	car.root.scale.z = 2.5
	car.root.position.z = car_cell.y * GridView.CELL
	_set_half(car_cell.y)
	var target: Vector3 = car.root.position
	_pose_camera(target, 30, 13)
	await _capture("level-car-partial")
	_check(car.fog.coverage == SceneryFog.Coverage.PARTIAL, "multi-tile car crosses the mask")
	car.root.rotation.y = PI / 4
	level.refresh_visibility()
	await _capture("level-car-rotated")
	_pose_camera(target, -55, 13)
	await _capture("level-car-reverse")
	await level.drive("r", [car_cell + Vector2i(0, -1), car_cell + Vector2i(0, 1)])
	_check(car.fog._transform == car.root.global_transform, "driving refreshes coverage with the final pose")
	_check(car.fog.proxy.global_position.is_equal_approx(car.root.to_global(car.fog.bounds.get_center())), "vehicle proxy follows its model")
	var door: Dictionary = level._devices["d"]
	state.visible_cells.clear()
	grid.set_visibility(state)
	level.refresh_visibility()
	var guard: Unit = state.units[3]
	guard.located = 1
	battle._refresh_fog()
	_check(battle._views[guard.id].visible, "Locate retains character visibility outside the mask")
	guard.located = 0
	state.known[guard.id] = guard.cell
	battle._refresh_fog()
	_check(not battle._views[guard.id].visible and battle._last_seen[guard.id].visible, "unseen guard disappears and its last-seen marker remains")
	_check(battle._views[0].visible and battle._views[1].visible, "team visibility is retained")
	state.devices["d"].open = true
	level.update_nodes(state)
	level.refresh_visibility()
	_check(not door.fog.proxy.visible, "an open hidden door has no proxy")
	state.devices["d"].open = false
	level.update_nodes(state)
	level.refresh_visibility()
	_check(door.fog.proxy.visible, "closing a hidden door restores its box")
	var screen: Dictionary = level._devices["s"]
	car.root.visible = false
	var screen_cell := Vector2i(13, 13)
	screen.root.position = grid.cell_to_world(screen_cell) + Vector3(0, 2.4, -GridView.CELL / 2)
	screen.root.rotation.y = PI / 4
	screen.root.position.z = screen_cell.y * GridView.CELL
	_set_half(screen_cell.y)
	_pose_camera(screen.root.position, 30, 8)
	await _capture("level-sign-partial")
	state.devices["s"].powered = false
	level.update_nodes(state)
	level.refresh_visibility()
	_check(not screen.glows[0].visible, "power-off screen state survives fog updates")
	state.devices["s"].powered = true
	level.update_nodes(state)
	level.refresh_visibility()
	_check(screen.glows[0].visible, "power-on screen returns in the visible half")
	var walls := InputEventAction.new()
	walls.action = "toggle_walls"
	walls.pressed = true
	Input.parse_input_event(walls)
	for i in 20:
		await process_frame
	_check(level._ghost_all, "wall-ghost input reached the level")
	_check(level._scenery.any(func(asset: SceneryFog): return not asset.ghost_cells.is_empty() and asset.proxy.get_instance_shader_parameter("ghost") == 1.0), "wall proxies ghost with their assemblies")
	await _capture("level-walls-ghosted")
	await battle._on_network_toggled(true)
	_check(battle._network_shown and not battle._network_moving, "Network view transition completed")
	await _capture("level-network")
	await battle._on_network_toggled(false)
	_check(not battle._network_shown and not battle._network_moving, "physical view restored")
	await _capture("level-physical-restored")
	print("Native fog checks: ", "passed" if failures == 0 else "FAILED", "; assets=", level._scenery.size())
	battle.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)


func _set_half(row: int) -> void:
	battle.state.visible_cells.clear()
	for y in battle.state.map.size.y:
		for x in battle.state.map.size.x:
			if y >= row:
				battle.state.visible_cells[Vector2i(x, y)] = true
	battle._refresh_fog()


func _pose_camera(target: Vector3, yaw: float, distance: float) -> void:
	var rig: CameraRig = battle._camera_rig
	if rig._focus_tween:
		rig._focus_tween.kill()
	rig.position = target
	rig._set_yaw(yaw)
	rig._set_pitch(45)
	rig._set_distance(distance)


func _capture(label: String) -> void:
	for i in 30:
		await process_frame
	await RenderingServer.frame_post_draw
	if not output.is_empty():
		root.get_texture().get_image().save_png(output.path_join(label + ".png"))


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		print("FAIL: ", message)
