extends SceneTree

var output := ""
var tone := "form"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			output = arg.trim_prefix("--capture=")
		elif arg.begins_with("--tone="):
			tone = arg.trim_prefix("--tone=")
	if tone == "flat":
		var fog := FileAccess.get_file_as_string("res://art/shaders/fog.gdshaderinc")
		fog = fog.replace("SILHOUETTE_FORM = 0.12", "SILHOUETTE_FORM = 0.0").replace("SILHOUETTE_INK = true", "SILHOUETTE_INK = false")
		for name in ["toon", "wall", "fog_surface", "ink_outline"]:
			var shader: Shader = load("res://art/shaders/%s.gdshader" % name)
			shader.code = shader.code.replace('#include "res://art/shaders/fog.gdshaderinc"', fog)
	root.size = Vector2i(1280, 800)
	var battle: Node3D = load("res://battle/battle.tscn").instantiate()
	root.add_child(battle)
	if tone == "pre":
		for mesh: MeshInstance3D in battle._level.find_children("*", "MeshInstance3D", true, false):
			mesh.set_instance_shader_parameter("scenery", false)
	await _capture("initial")
	var rig: CameraRig = battle._camera_rig
	if rig._focus_tween:
		rig._focus_tween.kill()
	rig.position = battle._grid.cell_to_world(battle.state.units[0].cell) + Vector3(2.5, 0, -2.5)
	rig._set_yaw(45)
	rig._set_pitch(50)
	rig._set_distance(20)
	await _capture("close")
	var car: Dictionary = battle._level._devices["r"]
	car.root.position = battle._grid.cell_to_world(Vector2i(13, 13))
	car.root.scale.z = 2.5
	car.root.position.z = 13 * GridView.CELL
	car.root.rotation.y = PI / 4
	var cells := {}
	for y in battle.state.map.size.y:
		for x in battle.state.map.size.x:
			if y >= 13:
				cells[Vector2i(x, y)] = true
	battle._grid.set_visibility(cells, battle.state.lit)
	rig.position = car.root.position
	rig._set_yaw(30)
	rig._set_pitch(45)
	rig._set_distance(13)
	await _capture("car")
	print("Fog look captured: ", tone)
	quit()


func _capture(label: String) -> void:
	for i in 45:
		await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(output)
	root.get_texture().get_image().save_png(output.path_join("%s-%s.png" % [tone, label]))
