extends SceneTree

var battle: Node3D
var output := ""
var baseline := false
var failures := 0
var samples: Array[Dictionary] = []
var moving := false
var finished_at := 0.0
var started := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			output = arg.trim_prefix("--capture=")
		elif arg == "--baseline":
			baseline = true
	if not output.is_empty():
		DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(1280, 800)
	var map := MapData.new()
	map.layout = ". . . . . . . . . . . . . X\nP . . . . . . . . . . . . z\n. . . . . . . . . . . . . ."
	map.node_kinds = {"z": "cache"}
	var content: BattleContent = load("res://content/battle.tres").duplicate()
	var operator: UnitDef = content.operators[0].duplicate()
	operator.sight = 2
	content.operators = [operator]
	content.loadouts = content.loadouts.slice(0, 1)
	root.get_node("SceneRouter").session = BattleSession.from_presets(map, content)
	battle = load("res://battle/battle.tscn").instantiate()
	root.add_child(battle)
	battle._hud.hide()
	var target := Vector2i(2, 0)
	var holder: Node3D = battle._level._place_root(battle._grid.cell_to_world(target), Vector2i(0, 1))
	battle._level._toon_body(holder, [[Vector3(0.8, 1.2, 0.8), Vector3(0, 0.6, 0), Color(0.1, 0.8, 0.7)]])
	SceneryFog.apply(holder)
	var rig: CameraRig = battle._camera_rig
	if rig._focus_tween:
		rig._focus_tween.kill()
	rig.position = battle._grid.cell_to_world(Vector2i(3, 1))
	rig._set_yaw(0)
	rig._set_pitch(60)
	rig._set_distance(14)
	for i in 45:
		await process_frame
	await RenderingServer.frame_post_draw
	_save("run-before")
	var events: Array[Dictionary] = battle.state.move(battle.state.active, Vector2i(3, 1), true)
	_check(not events.is_empty() and events[0].path.size() == 3, "first legal three-square sprint resolves")
	moving = true
	started = Time.get_ticks_usec()
	_play.call_deferred(events)
	var captures := [0.16, 0.24, 0.42, 0.56, 0.70, 0.82, 0.98, 1.20]
	var capture := 0
	while _elapsed() < 1.3:
		await RenderingServer.frame_post_draw
		var elapsed := _elapsed()
		var visibility: float = battle._grid._visibility_image.get_pixel(target.x + 1, target.y + 1).r
		samples.append({"seconds": elapsed, "busy": moving, "seen": battle._grid.cell_visible(target),
			"visibility": visibility, "brightness": battle._grid._light_image.get_pixel(target.x + 1, target.y + 1).r})
		if capture < captures.size() and elapsed >= captures[capture]:
			_save("run-%02d" % (capture + 1))
			capture += 1
	_check(not moving and not battle._grid.cell_visible(target), "sprint ends beyond the transient cell")
	if not baseline:
		_check(samples.any(func(frame: Dictionary) -> bool: return frame.busy and frame.seen and frame.visibility > 0.0 and frame.visibility < 1.0), "reveal fades during actual sprint playback")
		_check(samples.any(func(frame: Dictionary) -> bool: return frame.busy and not frame.seen and frame.visibility > 0.0 and frame.visibility < 1.0), "loss of sight fades while sprint playback continues")
		_check(samples.any(func(frame: Dictionary) -> bool: return not frame.busy and frame.visibility > 0.0 and frame.visibility < 1.0), "final refresh preserves the fade still in progress")
		_check(samples.back().visibility == 0.0 and not battle._grid.is_processing(), "fog settles after the movement without remaining frame work")
	if not output.is_empty():
		var file := FileAccess.open(output.path_join("samples.json"), FileAccess.WRITE)
		file.store_string(JSON.stringify({"baseline": baseline, "finished_at": finished_at, "frames": samples}, "\t"))
	print("Native sprint fog: ", "baseline recorded" if baseline else "passed" if failures == 0 else "FAILED", "; failures=", failures)
	quit(0 if failures == 0 else 1)


func _play(events: Array[Dictionary]) -> void:
	battle._busy = true
	await battle._play(events)
	var next: Array[Dictionary] = battle.state.move(battle.state.active, Vector2i(6, 1), true)
	_check(not next.is_empty() and next[0].path.size() == 3, "second legal three-square sprint resolves")
	await battle._play(next)
	battle._busy = false
	moving = false
	finished_at = _elapsed()


func _elapsed() -> float:
	return (Time.get_ticks_usec() - started) / 1000000.0


func _save(label: String) -> void:
	if not output.is_empty():
		root.get_texture().get_image().save_png(output.path_join(label + ".png"))


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		print("FAIL: ", message)
