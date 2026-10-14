extends Node

var failures: Array[String] = []
var checks := 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error(message)

func click(workshop: Control, at: Vector2, pressed: bool, control := false) -> void:
	var event := InputEventMouseButton.new()
	event.position = at
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.ctrl_pressed = control
	workshop.canvas.gui_input.emit(event)

func tree_click(workshop: Control, id: int, control := false, shift := false) -> void:
	var row: TreeItem = workshop.tree_rows[id]
	await tree_row_click(workshop,row,control,shift)

func tree_row_click(workshop: Control, row: TreeItem, control := false, shift := false) -> void:
	var rectangle: Rect2 = workshop.selection_list.get_item_area_rect(row)
	var at: Vector2 = workshop.selection_list.global_position + rectangle.position + rectangle.size/2
	for pressed in [true,false]:
		var event := InputEventMouseButton.new()
		event.position = at
		event.global_position = at
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.ctrl_pressed = control
		event.shift_pressed = shift
		workshop.get_viewport().push_input(event, true)
	await get_tree().process_frame
	await get_tree().process_frame

func run(workshop: Control) -> void:
	workshop._new_layout()
	for definition in workshop.catalog:
		var template: Node3D = workshop._template(definition.id)
		check(workshop._bounds(template).size.y > 0.01, "Empty model: " + definition.id)
	workshop.brush = "wall"
	workshop._set_mode("place")
	var target := Vector3(2.6, 0, 1.1)
	var screen: Vector2 = workshop.camera.unproject_position(target)
	click(workshop, screen, true)
	click(workshop, screen, false)
	check(workshop.items.size() == 1, "Canvas click did not place wall")
	check(is_equal_approx(workshop.items[0].position[0], 2.25), "Wall did not snap to tile centre")
	workshop.brush = "shipping_crates"
	workshop._set_mode("place")
	target = Vector3(-2.17, 0, 1.13)
	screen = workshop.camera.unproject_position(target)
	click(workshop, screen, true)
	click(workshop, screen, false)
	check(workshop.items.size() == 2, "Canvas click did not place prop")
	check(is_equal_approx(workshop.items[1].position[0], target.x), "Free prop placement snapped unexpectedly")
	workshop._set_mode("select")
	await get_tree().physics_frame
	await get_tree().physics_frame
	var prop_id: int = int(workshop.items[1].id)
	screen = workshop.camera.unproject_position(Vector3(target.x, 0.8, target.z))
	click(workshop, screen, true)
	check(workshop.selected == prop_id, "Ray picking did not select prop")
	var motion := InputEventMouseMotion.new()
	motion.position = workshop.camera.unproject_position(Vector3(-3.5, 0.8, 2.0))
	motion.relative = motion.position-screen
	workshop.canvas.gui_input.emit(motion)
	click(workshop, motion.position, false)
	check(not is_equal_approx(workshop.items[1].position[0], target.x), "Dragging did not move prop")
	workshop._edit_position("y", 0.6)
	workshop._rotate()
	workshop._edit_scale(1.2)
	check(is_equal_approx(workshop._current().position[1], 0.6), "Elevation edit failed")
	check(is_equal_approx(workshop._current().rotation, 90), "Rotation edit failed")
	check(is_equal_approx(workshop._current().scale, 1.2), "Scale edit failed")
	workshop._duplicate_selected()
	check(workshop.items.size() == 3, "Duplicate failed")
	workshop._delete_selected()
	check(workshop.items.size() == 2, "Delete failed")
	workshop._undo()
	check(workshop.items.size() == 3, "Undo delete failed")
	workshop._redo()
	check(workshop.items.size() == 2, "Redo delete failed")
	workshop.title_field.text = "Verification layout"
	workshop.notes.text = "Placement, camera and save/load smoke verification."
	workshop._remember()
	check(workshop._save_layout("verification-roundtrip") == OK, "Save failed")
	var before: Dictionary = workshop._document(true)
	workshop._new_layout()
	var loaded: bool = workshop._load_layout("res://layouts/verification-roundtrip.json")
	check(loaded, "Load failed: " + workshop.status.text)
	check(workshop.items.size() == 2 and workshop.notes.text == before.notes, "Round trip lost items or notes")
	check(not workshop._is_dirty(), "Freshly loaded layout marked dirty")
	var malformed := before.duplicate(true)
	malformed.items[1].id = malformed.items[0].id
	check(not workshop._validate_document(malformed).is_empty(), "Duplicate IDs accepted")
	malformed = before.duplicate(true)
	malformed.items[0].scale = "bad"
	check(not workshop._validate_document(malformed).is_empty(), "Malformed scale accepted")
	var old_yaw: float = workshop.yaw
	var orbit := InputEventMouseButton.new()
	orbit.button_index = MOUSE_BUTTON_RIGHT
	orbit.pressed = true
	workshop.canvas.gui_input.emit(orbit)
	motion.relative = Vector2(30, 15)
	workshop.canvas.gui_input.emit(motion)
	orbit.pressed = false
	workshop.canvas.gui_input.emit(orbit)
	check(workshop.yaw != old_yaw, "Camera orbit failed")
	workshop._top_view()
	check(workshop.pitch > 1.5, "Top view failed")
	await workshop._export_handoff()
	check(workshop.status.text.begins_with("Handoff exported:"), "Handoff export failed")
	await verify_upgrade(workshop)
	check(workshop._load_layout("res://layouts/example-courtyard.json"), "Example layout load failed")
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var capture_error := workshop.get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://verification/workshop-preview.png"))
	check(capture_error == OK, "Native preview capture failed")
	var report := FileAccess.open("res://verification/results.json", FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks,"failures":failures,"native_renderer":RenderingServer.get_video_adapter_name()}, "\t"))
	report.close()
	print("WORKSHOP_VERIFICATION: %d checks, %d failures" % [checks, failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)

func verify_upgrade(workshop: Control) -> void:
	workshop._new_layout()
	workshop.brush = "floor"
	workshop._set_mode("place")
	var initial_history: int = workshop.history_index
	var start: Vector2 = workshop.camera.unproject_position(Vector3(-3.75,0,0.75))
	var finish: Vector2 = workshop.camera.unproject_position(Vector3(3.75,0,0.75))
	click(workshop,start,true)
	var motion := InputEventMouseMotion.new()
	motion.position = finish
	motion.relative = finish-start
	workshop.canvas.gui_input.emit(motion)
	click(workshop,finish,false)
	check(workshop.items.size() == 6, "Painting skipped cells in a fast stroke")
	check(workshop.history_index == initial_history+1, "Painting created more than one undo step")
	workshop._undo()
	check(workshop.items.is_empty(), "Undo did not remove the entire ground stroke")
	workshop._redo()
	check(workshop.items.size() == 6, "Redo did not restore the entire ground stroke")
	workshop.brush = "street"
	workshop._set_mode("place")
	click(workshop,start,true)
	workshop.canvas.gui_input.emit(motion)
	click(workshop,finish,false)
	check(workshop.items.size() == 6 and workshop.items.all(func(item): return item.kind == "street"), "Repainting stacked duplicate ground instead of replacing it")
	workshop.brush = "grass"
	workshop.brush_cells = 3
	workshop._set_mode("place")
	var garden: Vector2 = workshop.camera.unproject_position(Vector3(11.25,0,9.75))
	click(workshop,garden,true)
	click(workshop,garden,false)
	check(workshop.items.size() == 15, "3 × 3 brush did not paint nine cells")
	workshop._place("wall", Vector3(11.25,0,9.75))
	workshop._set_mode("erase")
	click(workshop,garden,true)
	click(workshop,garden,false)
	check(workshop.items.size() == 7 and workshop.items.back().kind == "wall", "Ground eraser removed a wall or left ground cells behind")
	workshop._undo()
	check(workshop.items.size() == 16, "Undo did not restore erased ground")
	workshop._new_layout()
	workshop.brush_cells = 1
	for x in [-7.5,-2.5,2.5,7.5]: workshop._place("shipping_crates", Vector3(x,0,0))
	workshop._set_mode("select")
	await get_tree().physics_frame
	await get_tree().physics_frame
	start = workshop.camera.unproject_position(Vector3(-7.5,0.8,0))
	finish = workshop.camera.unproject_position(Vector3(-2.5,0.8,0))
	click(workshop,start,true)
	click(workshop,start,false)
	click(workshop,finish,true,true)
	click(workshop,finish,false,true)
	check(workshop.selected_ids.size() == 2, "Control-click did not add a second scene object")
	click(workshop,finish,true,true)
	click(workshop,finish,false,true)
	check(workshop.selected_ids.size() == 1, "Control-click did not toggle a scene object off")
	await get_tree().process_frame
	await tree_click(workshop,1)
	await tree_click(workshop,2,true)
	check(workshop.selected_ids.size() == 2, "Control-click in scene tree did not select multiple rows")
	await tree_click(workshop,1)
	await tree_click(workshop,4,false,true)
	check(workshop.selected_ids.size() == 4, "Shift-click in scene tree did not select a range")
	var original_positions := {}
	for item in workshop.items: original_positions[int(item.id)] = workshop.objects[int(item.id)].position
	start = workshop.camera.unproject_position(workshop.objects[1].position+Vector3(0,0.8,0))
	finish = workshop.camera.unproject_position(workshop.objects[1].position+Vector3(3,0.8,3))
	click(workshop,start,true)
	motion.position = finish
	motion.relative = finish-start
	workshop.canvas.gui_input.emit(motion)
	click(workshop,finish,false)
	var moved_by: Vector3 = workshop.objects[1].position-original_positions[1]
	check(moved_by.length() > 0.1 and workshop.items.all(func(item): return (workshop.objects[int(item.id)].position-original_positions[int(item.id)]).distance_to(moved_by) < 0.001), "Multi-selection drag did not move all objects together")
	var folder_id: int = workshop._create_folder("Loading area")
	check(workshop.folders.size() == 1 and workshop.items.all(func(item): return int(item.folder_id) == folder_id), "Folder did not group selected objects")
	workshop.folder_rename_id = folder_id
	workshop.folder_name.text = "Loading bay"
	workshop._fill_folder_options(workshop.folder_parent,folder_id)
	workshop._confirm_folder()
	check(workshop._folder(folder_id).name == "Loading bay", "Folder rename failed")
	await get_tree().process_frame
	await tree_row_click(workshop,workshop.folder_rows[folder_id])
	check(workshop.active_folder == folder_id and workshop.selected_ids.size() == 4, "Clicking a folder did not select its contents")
	var child_id: int = workshop._create_folder("Crates",folder_id)
	check(int(workshop._folder(child_id).parent) == folder_id, "Nested folder parent not recorded")
	workshop._move_selection_to_folder(0)
	check(workshop.items.all(func(item): return int(item.folder_id) == 0), "Move to scene root failed")
	workshop._undo()
	check(workshop.items.all(func(item): return int(item.folder_id) == child_id), "Undo did not restore folder membership")
	workshop.active_folder = folder_id
	workshop._remove_folder()
	check(workshop.items.size() == 4 and int(workshop._folder(child_id).parent) == 0, "Ungroup folder lost objects or nested folders")
	workshop._undo()
	check(workshop.folders.size() == 2 and int(workshop._folder(child_id).parent) == folder_id, "Undo did not restore folder hierarchy")
	workshop._select(1)
	workshop._select(2,true)
	var a: Vector3 = workshop.objects[1].position
	var b: Vector3 = workshop.objects[2].position
	workshop._edit_rotation(90)
	check(is_equal_approx(workshop.objects[1].position.distance_to(workshop.objects[2].position), a.distance_to(b)), "Multi-selection rotation changed relative distance")
	workshop._edit_scale(1.5)
	check(is_equal_approx(workshop.objects[1].position.distance_to(workshop.objects[2].position), a.distance_to(b)*1.5), "Multi-selection scale did not preserve proportions")
	workshop._duplicate_selected()
	check(workshop.items.size() == 6 and workshop.selected_ids.size() == 2, "Multi-selection duplicate failed")
	workshop._delete_selected()
	check(workshop.items.size() == 4, "Multi-selection delete failed")
	workshop._undo()
	check(workshop.items.size() == 6, "Undo did not restore both deleted objects")
	workshop._redo()
	check(workshop.items.size() == 4, "Redo did not delete both objects")
	workshop.title_field.text = "Verification folders"
	check(workshop._save_layout("verification-folders") == OK, "Folder layout save failed")
	workshop._new_layout()
	check(workshop._load_layout("res://layouts/verification-folders.json"), "Folder layout load failed")
	check(workshop.folders.size() == 2 and int(workshop.items[0].folder_id) == child_id, "Save/load lost folder membership")
	var invalid: Dictionary = workshop._document()
	invalid.folders[0].parent = child_id
	check(not workshop._validate_document(invalid).is_empty(), "Cyclic folders accepted")
	workshop._set_ui_size(2)
	check(workshop.theme.default_font_size >= 22, "Text size control did not enlarge the font")
	workshop._set_ui_size(0)
	check(workshop.get_window().content_scale_mode == Window.CONTENT_SCALE_MODE_CANVAS_ITEMS, "Interface does not scale with window resolution")
