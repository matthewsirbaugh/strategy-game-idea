extends SceneTree

var state := BattleState.new()
var grid := GridView.new()
var level := LevelView.new()
var camera := Camera3D.new()
var car: SceneryFog
var output := ""


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(1280, 800)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			output = arg.trim_prefix("--capture=")
	var map := MapData.new()
	map.layout = ""
	for y in 8:
		map.layout += " ".join(PackedStringArray([".", ".", ".", ".", ".", ".", ".", "."])) + "\n"
	map.validate()
	map.night = true
	state.map = map
	root.add_child(grid)
	grid.build(state)
	root.add_child(level)
	level.add_child(level._signs)
	level._grid = grid
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.08, 0.1, 0.14)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	env.environment.ambient_light_energy = 0.7
	root.add_child(env)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50, -30, 0)
	light.shadow_enabled = true
	root.add_child(light)
	var floor := PlaneMesh.new()
	floor.size = Vector2(15, 15)
	var ground := level._add_mesh(floor, Surfaces.named("paving"), Vector3(6, -0.01, 6))
	ground.set_instance_shader_parameter("scenery", true)
	var building := Node3D.new()
	building.position = Vector3(2.0, 0, 6)
	level.add_child(building)
	_part(building, Vector3(3.0, 3.8, 3.0), Vector3(0, 1.9, 0), Surfaces.named("building"))
	_part(building, Vector3(3.2, 0.12, 3.2), Vector3(0, 3.86, 0), Surfaces.named("cap"))
	level.register_scenery(building)
	var holder := level._place_root(Vector3(7.5, 0, 6), Vector2i(0, 1))
	level._toon_body(holder, [[Vector3(1.3, 0.65, 3.6), Vector3(0, 0.45, 0), Color(0.1, 0.7, 0.8)],
		[Vector3(1.1, 0.6, 1.5), Vector3(0, 1.0, -0.25), Color(0.07, 0.12, 0.18)]])
	level._glow_quad(holder, Vector2(0.9, 0.12), Vector3(0, 0.55, 1.81), Color(1, 0.85, 0.5), 3)
	car = level.register_scenery(holder)
	var sign := level._place_root(Vector3(4.8, 2.2, 6), Vector2i(1, 1))
	level._toon_body(sign, [[Vector3(3.0, 1.2, 0.12), Vector3.ZERO, Color(0.15, 0.18, 0.2)]])
	level._ad_screen(sign)
	level.register_scenery(sign)
	root.add_child(camera)
	camera.current = true
	_set_mask()
	if output.is_empty():
		camera.look_at_from_position(Vector3(13, 10, 15), Vector3(5, 1, 6))
		return
	DirAccess.make_dir_recursive_absolute(output)
	for angle in 3:
		car.root.rotation.y = 0.0 if angle == 0 else PI / 4.0
		level.refresh_visibility()
		camera.look_at_from_position([Vector3(13, 10, 15), Vector3(13, 10, 15), Vector3(-6, 10, 15)][angle], Vector3(5, 1, 6))
		for i in 8:
			await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(output.path_join("prototype-%d.png" % angle))
	print("Fog prototype: three native views captured.")
	quit()


func _set_mask() -> void:
	state.visible_cells.clear()
	for y in 8:
		for x in 8:
			if y >= 4:
				state.visible_cells[Vector2i(x, y)] = true
	grid.set_visibility(state)
	level.refresh_visibility()


func _part(parent: Node3D, size: Vector3, at: Vector3, material: Material) -> void:
	var part := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	part.mesh = mesh
	part.material_override = material
	part.position = at
	parent.add_child(part)
