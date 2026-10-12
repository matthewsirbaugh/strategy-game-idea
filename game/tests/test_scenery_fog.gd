extends SceneTree

var failures := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var map := MapData.new()
	map.layout = ". . . .\n. . . .\n. . . .\n. . . ."
	map.validate()
	map.night = true
	var state := BattleState.new()
	state.map = map
	state.visible_cells = {Vector2i(1, 1): true}
	var grid := GridView.new()
	root.add_child(grid)
	grid.build(state)
	grid.set_visibility(state.visible_cells, state.lit)
	_check(grid.cell_visible(Vector2i(1, 1)), "visible darkness is visible before lighting animates")
	_check(grid._visibility_image.get_pixel(2, 2).r == 0.0 and grid._light_image.get_pixel(2, 2).r == 0.0, "binary vision updates before either visual fade")
	grid._process(0.1)
	var revealing := grid._visibility_image.get_pixel(2, 2).r
	_check(revealing > 0.0 and revealing < 1.0, "new vision fades in instead of switching")
	grid.set_visibility({}, {})
	_check(not grid.cell_visible(Vector2i(1, 1)), "losing sight remains immediate in the binary query")
	grid._process(0.12)
	var hiding := grid._visibility_image.get_pixel(2, 2).r
	_check(hiding > 0.0 and hiding < revealing, "one hidden step leaves a gradual fade in progress")
	grid.set_visibility(state.visible_cells, state.lit)
	_check(grid._visibility_image.get_pixel(2, 2).r == hiding, "returning vision retargets the current fade without a snap")
	grid._process(0.05)
	grid.set_visibility(state.visible_cells, state.lit)
	_check(grid._visibility_image.get_pixel(2, 2).r > hiding and grid._visibility_image.get_pixel(2, 2).r < 1.0, "final refresh preserves the fade instead of restarting or completing it")
	grid._process(0.4)
	_check(grid._visibility_image.get_pixel(2, 2).r == 1.0 and not grid.is_processing(), "settled fog stops processing")
	state.lit[Vector2i(2, 1)] = true
	grid.set_visibility(state.visible_cells, state.lit)
	_check(not grid.cell_visible(Vector2i(2, 1)), "light cannot reveal a hidden tile")
	_check(not grid.cell_visible(Vector2i(-1, 1)) and grid.cell_visible(Vector2i(-2, 1)), "fog includes exactly its existing border")
	var holder := Node3D.new()
	root.add_child(holder)
	holder.position = Vector3(2.25, 0, 2.25)
	var detail := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.8, 1.2, 0.8)
	detail.mesh = mesh
	holder.add_child(detail)
	SceneryFog.apply(holder)
	_check(detail.get_instance_shader_parameter("scenery") == true, "registered scenery opts in")
	state.visible_cells.clear()
	grid.set_visibility(state.visible_cells, state.lit)
	_check(detail.visible and holder.get_child_count() == 1, "hidden scenery stays drawn without proxies")
	detail.visible = false
	state.visible_cells[Vector2i(1, 1)] = true
	grid.set_visibility(state.visible_cells, state.lit)
	_check(not detail.visible, "visibility uploads preserve power and door state")
	var actor := MeshInstance3D.new()
	actor.mesh = mesh
	root.add_child(actor)
	_check(actor.get_instance_shader_parameter("scenery") != true and actor.get_child_count() == 0, "unregistered characters have no fog box")
	holder.queue_free()
	actor.queue_free()
	grid.queue_free()
	await process_frame
	print("Scenery fog: binary visibility, shader opt-in and state checks passed" if failures == 0 else "FAIL: scenery fog")
	quit(0 if failures == 0 else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		print("FAIL: ", message)
