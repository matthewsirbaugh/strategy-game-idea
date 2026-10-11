extends SceneTree

# Fresh entry: one invocation. Restarts: -- --restarts (one warm-up plus five samples).
func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var restarts := "--restarts" in OS.get_cmdline_user_args()
	var headless := DisplayServer.get_name() == "headless"
	root.size = Vector2i(1280, 800)
	if not headless:
		RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(), true)
	for run in (6 if restarts else 1):
		root.get_node("SceneRouter").session = null
		StartupTiming.reset()
		var started := Time.get_ticks_usec()
		var loading := StartupTiming.begin()
		var scene := load("res://battle/battle.tscn") as PackedScene
		StartupTiming.loaded("res://battle/battle.tscn", loading)
		var battle := scene.instantiate()
		root.add_child(battle)
		var setup_ms := (Time.get_ticks_usec() - started) / 1000.0
		var first_frame_ms := 0.0
		if not headless:
			await RenderingServer.frame_post_draw
			first_frame_ms = (Time.get_ticks_usec() - started) / 1000.0
		var sample := {"run": run, "scenario": "restart" if restarts and run > 0 else "fresh", "headless": headless,
			"setup_ms": setup_ms, "first_frame_ms": first_frame_ms,
			"stages_ms": StartupTiming.milliseconds.duplicate(), "rigs_ms": StartupTiming.rigs.duplicate(),
			"resources_ms": StartupTiming.resources.duplicate()}
		StartupTiming.enabled = false
		if not headless:
			for i in 60:
				await process_frame
			var cpu := []
			var gpu := []
			var draws := []
			for i in 120:
				await process_frame
				cpu.append(RenderingServer.viewport_get_measured_render_time_cpu(root.get_viewport_rid()) + RenderingServer.get_frame_setup_time_cpu())
				gpu.append(RenderingServer.viewport_get_measured_render_time_gpu(root.get_viewport_rid()))
				draws.append(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
			cpu.sort()
			gpu.sort()
			draws.sort()
			sample["render_cpu_median_ms"] = cpu[60]
			sample["render_gpu_median_ms"] = gpu[60]
			sample["draw_calls_median"] = draws[60]
		if not restarts or run > 0:
			print("STARTUP_SAMPLE ", JSON.stringify(sample))
		battle.queue_free()
		await process_frame
	quit()
