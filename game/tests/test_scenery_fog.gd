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
	grid.set_visibility(state)
	_check(grid.cell_visible(Vector2i(1, 1)), "visible darkness is visible before lighting animates")
	_check(grid._visibility_image.get_pixel(2, 2).r == 1.0 and grid._light_image.get_pixel(2, 2).r == 0.0, "visibility is independent of brightness")
	state.lit[Vector2i(2, 1)] = true
	grid.set_visibility(state)
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
	var fog := SceneryFog.new(holder)
	fog.refresh(grid)
	_check(detail.visible and not fog.proxy.visible, "fully visible assets suppress proxy draws")
	state.visible_cells.clear()
	grid.set_visibility(state)
	fog.refresh(grid)
	_check(not detail.visible and fog.proxy.visible, "lost visibility suppresses detail immediately")
	state.visible_cells[Vector2i(1, 1)] = true
	grid.set_visibility(state)
	holder.position.x = 3.0
	fog.refresh(grid)
	_check(detail.visible and fog.proxy.visible and fog.coverage == SceneryFog.Coverage.PARTIAL, "a moved asset crosses the binary boundary")
	_check(detail.get_instance_shader_parameter("scenery") == true, "only registered scenery opts in")
	fog.set_detail_visible(detail, false)
	fog.refresh(grid)
	_check(not detail.visible, "power state survives fog culling")
	fog.set_detail_visible(detail, true)
	fog.enabled = false
	fog.refresh(grid)
	_check(not detail.visible and not fog.proxy.visible, "open doors have no proxy")
	fog.enabled = true
	holder.rotation.y = PI / 4
	fog.refresh(grid)
	_check(fog.proxy.global_transform.basis.get_rotation_quaternion().is_equal_approx(holder.global_transform.basis.get_rotation_quaternion()), "proxy follows asset rotation")
	var actor := MeshInstance3D.new()
	actor.mesh = mesh
	root.add_child(actor)
	_check(actor.get_instance_shader_parameter("scenery") != true and actor.get_child_count() == 0, "unregistered characters have no fog box")
	holder.queue_free()
	actor.queue_free()
	grid.queue_free()
	await process_frame
	print("Scenery fog: binary visibility, moving coverage, culling and state checks passed" if failures == 0 else "FAIL: scenery fog")
	quit(0 if failures == 0 else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		print("FAIL: ", message)
