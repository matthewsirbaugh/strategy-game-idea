extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	root.size = Vector2i(640, 480)
	var state := BattleState.new()
	state.map = MapData.new()
	state.map.layout = ". .\n. ."
	state.map.validate()
	state.visible_cells = {Vector2i.ZERO: true}
	var grid := GridView.new()
	root.add_child(grid)
	grid.build(state)
	grid.set_visibility(state.visible_cells, state.lit)
	grid.visible = false
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color.WHITE
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	root.add_child(environment)
	var camera := Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 2
	root.add_child(camera)
	camera.look_at_from_position(Vector3(GridView.CELL, 5, 0.75), Vector3(GridView.CELL, 0, 0.75), Vector3.FORWARD)
	camera.current = true
	var mesh := MeshInstance3D.new()
	mesh.mesh = SphereMesh.new()
	mesh.mesh.radius = 0.4
	mesh.mesh.height = 0.8
	mesh.mesh.radial_segments = 64
	mesh.mesh.rings = 32
	mesh.position = Vector3(GridView.CELL - 0.401, 0.4, 0.75)
	var texture := Image.create(1, 1, false, Image.FORMAT_RGB8)
	texture.fill(Color(0.2, 0.5, 0.7))
	var material := ShaderMaterial.new()
	material.shader = load("res://art/shaders/toon.gdshader")
	material.set_shader_parameter("albedo_texture", ImageTexture.create_from_image(texture))
	var ink := ShaderMaterial.new()
	ink.shader = load("res://art/shaders/ink_outline.gdshader")
	material.next_pass = ink
	mesh.material_override = material
	root.add_child(mesh)
	SceneryFog.apply(mesh)
	var flat: Shader = ink.shader.duplicate()
	var include := FileAccess.get_file_as_string("res://art/shaders/fog.gdshaderinc").replace("SILHOUETTE_INK = true", "SILHOUETTE_INK = false")
	flat.code = flat.code.replace('#include "res://art/shaders/fog.gdshaderinc"', include)
	ink.shader = flat
	var leaks := await _hidden_ink(camera)
	print("Native flat silhouette outline: ", "passed" if leaks == 0 else "FAILED", "; hidden ink pixels=", leaks)
	quit(0 if leaks == 0 else 1)


func _hidden_ink(camera: Camera3D) -> int:
	for i in 30:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var edge := camera.unproject_position(Vector3(GridView.CELL, 0.4, 0.75)) * Vector2(image.get_size()) / root.get_visible_rect().size
	var count := 0
	for y in range(int(edge.y) - 5, int(edge.y) + 6):
		for x in range(ceili(edge.x) + 1, ceili(edge.x) + 6):
			if image.get_pixel(x, y).r < 0.8:
				count += 1
	return count
