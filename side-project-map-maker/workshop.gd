extends Control

const Catalog = preload("res://catalog.gd")
const FORMAT := "bryson-visual-layout"
const VERSION := 1
const TILE := Catalog.TILE
const ACCENT := Color("7ee1ce")
const INK := Color("e5ecee")

var catalog: Array[Dictionary] = Catalog.entries()
var definitions := {}
var templates := {}
var items: Array[Dictionary] = []
var objects := {}
var next_id := 1
var selected := -1
var selected_ids: Array[int] = []
var folders: Array[Dictionary] = []
var active_folder := 0
var next_folder_id := 1
var tree_rows := {}
var folder_rows := {}
var tree_refreshing := false
var drag_positions := {}
var painting := false
var paint_last: Variant = null
var stroke_cells := {}
var stroke_changed := false
var brush_cells := 1
var ui_size := 1.0
var verification_mode := false
var mode := "select"
var brush := "floor"
var placement_y := 0.0
var placement_rotation := 0.0
var placement_scale := 1.0
var grid_width := 32
var grid_depth := 24
var snap_props := false
var history: Array[Dictionary] = []
var history_index := -1
var saved_content := ""
var refreshing := false
var dragging := false
var drag_offset := Vector3.ZERO
var orbiting := false
var panning := false
var hover := Vector2.ZERO
var focus := Vector3.ZERO
var yaw := -0.55
var pitch := 0.85
var distance := 37.0
var world: Node3D
var object_root: Node3D
var grid_root: Node3D
var camera: Camera3D
var viewport: SubViewport
var canvas: SubViewportContainer
var preview: Node3D
var selection_outline: MeshInstance3D
var palette: ItemList
var search: LineEdit
var category: OptionButton
var title_field: LineEdit
var notes: TextEdit
var status: Label
var count_label: Label
var selected_label: Label
var selection_list: Tree
var select_button: Button
var place_button: Button
var undo_button: Button
var redo_button: Button
var position_fields := {}
var rotation_field: SpinBox
var scale_field: SpinBox
var placement_label: Label
var save_dialog: ConfirmationDialog
var save_name: LineEdit
var load_dialog: ConfirmationDialog
var load_list: ItemList
var pending_new: ConfirmationDialog
var erase_button: Button
var brush_size_field: OptionButton
var snap_toggle: CheckButton
var inspector_tabs: TabContainer
var mode_help: Label
var folder_label: Label
var folder_dialog: ConfirmationDialog
var folder_name: LineEdit
var folder_parent: OptionButton
var move_dialog: ConfirmationDialog
var move_target: OptionButton
var ui_size_field: OptionButton
var folder_rename_id := 0
var folder_selected := false
var recovery_timer: Timer


func _ready() -> void:
	verification_mode = "--verify-workshop" in OS.get_cmdline_user_args() or "--capture-workshop" in OS.get_cmdline_user_args()
	get_window().gui_embed_subwindows = true
	var recovered: Variant = null
	if not verification_mode and FileAccess.file_exists("res://recovery.json"):
		recovered = JSON.parse_string(FileAccess.get_file_as_string("res://recovery.json"))
	for definition in catalog:
		definitions[definition.id] = definition
	_build_interface()
	if not verification_mode and FileAccess.file_exists("res://workshop-settings.json"):
		var settings = JSON.parse_string(FileAccess.get_file_as_string("res://workshop-settings.json"))
		if settings is Dictionary and _valid_number(settings.get("text_size"),0,2):
			ui_size_field.select(int(settings.text_size))
			_set_ui_size(int(settings.text_size))
	_build_world()
	recovery_timer = Timer.new()
	recovery_timer.one_shot = true
	recovery_timer.wait_time = 0.8
	recovery_timer.timeout.connect(_save_recovery)
	add_child(recovery_timer)
	_update_palette()
	_remember()
	saved_content = _content_key()
	_refresh()
	_message("Choose a piece on the left, then click in the workspace to place it.")
	if recovered != null and _validate_document(recovered).is_empty():
		_apply_document(recovered)
		history.clear()
		history_index = -1
		_remember()
		saved_content = ""
		_refresh_dirty()
		_message("Restored your previous workspace. Save layout keeps a named copy.")
	get_tree().auto_accept_quit = false
	if "--verify-workshop" in OS.get_cmdline_user_args():
		call_deferred("_verify")
	elif "--capture-workshop" in OS.get_cmdline_user_args():
		call_deferred("_capture_demo")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _is_dirty():
			_save_recovery()
			get_tree().quit()
		else:
			get_tree().quit()


func _style(background: Color, border := Color("31434d"), radius := 7) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 12
	box.content_margin_right = 12
	box.content_margin_top = 9
	box.content_margin_bottom = 9
	return box


func _build_interface() -> void:
	var theme_value := Theme.new()
	theme_value.default_font_size = 18
	for kind in ["Label", "Button", "LineEdit", "TextEdit", "ItemList", "OptionButton", "CheckButton", "Tree", "TabContainer", "PopupMenu"]:
		theme_value.set_color("font_color", kind, INK)
	for kind in ["Button", "OptionButton"]:
		theme_value.set_stylebox("normal", kind, _style(Color("24323c")))
		theme_value.set_stylebox("hover", kind, _style(Color("334852"), ACCENT))
		theme_value.set_stylebox("pressed", kind, _style(Color("305951"), ACCENT))
		theme_value.set_stylebox("disabled", kind, _style(Color("19252c")))
	for kind in ["LineEdit", "TextEdit", "ItemList", "Tree"]:
		theme_value.set_stylebox("normal", kind, _style(Color("101c24")))
		theme_value.set_stylebox("focus", kind, _style(Color("172a33"), ACCENT))
		theme_value.set_stylebox("selected", kind, _style(Color("315a53"), ACCENT))
		theme_value.set_stylebox("selected_focus", kind, _style(Color("315a53"), ACCENT))
	theme_value.set_stylebox("panel", "TabContainer", _style(Color("15212a")))
	theme_value.set_constant("item_margin", "Tree", 8)
	theme_value.set_constant("v_separation", "Tree", 8)
	theme = theme_value
	var backdrop := ColorRect.new()
	backdrop.color = Color("15212a")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	add_child(margin)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	margin.add_child(page)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	page.add_child(header)
	var brand := _label("MAP WORKSHOP", 24)
	brand.add_theme_color_override("font_color", ACCENT)
	header.add_child(brand)
	title_field = LineEdit.new()
	title_field.text = "Untitled layout"
	title_field.placeholder_text = "Name this place"
	title_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_field.text_changed.connect(func(_value): _refresh_dirty())
	title_field.focus_exited.connect(_remember)
	header.add_child(title_field)
	_button(header, "New", _request_new)
	_button(header, "Open", _open_load)
	_button(header, "Save", _open_save)
	_button(header, "Handoff", _export_handoff).tooltip_text = "Export two screenshots, an editable layout, and your design notes."
	ui_size_field = OptionButton.new()
	for label in ["Text: Standard", "Text: Large", "Text: Largest"]:
		ui_size_field.add_item(label)
	ui_size_field.item_selected.connect(_set_ui_size)
	header.add_child(ui_size_field)
	_button(header, "Help", _show_help)
	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 8)
	page.add_child(toolbar)
	select_button = _button(toolbar, "Select  [V]", func(): _set_mode("select"))
	place_button = _button(toolbar, "Paint  [B]", func(): _set_mode("place"))
	erase_button = _button(toolbar, "Erase ground  [X]", func(): _set_mode("erase"))
	undo_button = _button(toolbar, "Undo", _undo)
	redo_button = _button(toolbar, "Redo", _redo)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(spacer)
	_button(toolbar, "Map size…", _open_map_size)
	_button(toolbar, "Top", _top_view)
	_button(toolbar, "Angled", func(): camera.projection = Camera3D.PROJECTION_PERSPECTIVE; pitch = 0.85; _update_camera())
	_button(toolbar, "Fit  [F]", _frame_layout)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(body)
	var left := VBoxContainer.new()
	left.custom_minimum_size.x = 260
	left.add_theme_constant_override("separation", 10)
	body.add_child(left)
	left.add_child(_label("BUILD PALETTE", 18))
	search = LineEdit.new()
	search.placeholder_text = "Find a piece…"
	search.text_changed.connect(func(_text): _update_palette())
	left.add_child(search)
	category = OptionButton.new()
	for label in ["All pieces", "Ground", "Structures", "Props", "Prefabs"]:
		category.add_item(label)
	category.item_selected.connect(func(_index): _update_palette())
	left.add_child(category)
	palette = ItemList.new()
	palette.size_flags_vertical = Control.SIZE_EXPAND_FILL
	palette.custom_minimum_size.y = 220
	palette.add_theme_constant_override("v_separation", 12)
	palette.item_selected.connect(_choose_piece)
	left.add_child(palette)
	placement_label = _label("", 16)
	placement_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(placement_label)
	var brush_row := HBoxContainer.new()
	var brush_title := _label("Brush", 16)
	brush_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brush_row.add_child(brush_title)
	brush_size_field = OptionButton.new()
	for label in ["1 tile", "3 × 3", "5 × 5", "9 × 9"]:
		brush_size_field.add_item(label)
	brush_size_field.item_selected.connect(func(index): brush_cells = [1,3,5,9][index]; _update_preview())
	brush_row.add_child(brush_size_field)
	left.add_child(brush_row)
	snap_toggle = CheckButton.new()
	snap_toggle.text = "Snap props to grid"
	snap_toggle.toggled.connect(func(value): snap_props = value; _update_preview())
	left.add_child(snap_toggle)
	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(center)
	canvas = SubViewportContainer.new()
	canvas.stretch = true
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas.custom_minimum_size = Vector2(380, 300)
	canvas.focus_mode = Control.FOCUS_ALL
	canvas.gui_input.connect(_workspace_input)
	canvas.mouse_entered.connect(func(): _update_preview())
	canvas.mouse_exited.connect(func():
		if preview: preview.visible = false
		paint_last = null
	)
	center.add_child(canvas)
	viewport = SubViewport.new()
	viewport.size = Vector2i(800, 650)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.handle_input_locally = false
	canvas.add_child(viewport)
	count_label = _label("", 14)
	center.add_child(count_label)
	inspector_tabs = TabContainer.new()
	inspector_tabs.custom_minimum_size.x = 305
	body.add_child(inspector_tabs)
	var scene_tab := VBoxContainer.new()
	scene_tab.name = "Scene"
	scene_tab.add_theme_constant_override("separation", 10)
	inspector_tabs.add_child(scene_tab)
	folder_label = _label("Scene root", 16)
	folder_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scene_tab.add_child(folder_label)
	var folder_buttons := HBoxContainer.new()
	scene_tab.add_child(folder_buttons)
	_button(folder_buttons, "+ Folder", func(): _open_folder(false))
	_button(folder_buttons, "Move to…", _open_move_folder)
	var folder_actions := HBoxContainer.new()
	scene_tab.add_child(folder_actions)
	_button(folder_actions, "Rename", func(): _open_folder(true))
	_button(folder_actions, "Ungroup folder", _remove_folder)
	selection_list = Tree.new()
	selection_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	selection_list.hide_root = true
	selection_list.select_mode = Tree.SELECT_MULTI
	selection_list.allow_reselect = true
	selection_list.scroll_horizontal_enabled = false
	selection_list.gui_input.connect(_scene_tree_input)
	selection_list.multi_selected.connect(func(_row, _column, _value):
		if not tree_refreshing: _tree_selection_changed.call_deferred()
	)
	scene_tab.add_child(selection_list)
	scene_tab.add_child(_label("Ctrl / Cmd: add or remove\nShift: select a range\nClick a folder: select its contents", 14))
	var details_scroll := ScrollContainer.new()
	details_scroll.name = "Details"
	details_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inspector_tabs.add_child(details_scroll)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.custom_minimum_size.x = 278
	details.add_theme_constant_override("separation", 12)
	details_scroll.add_child(details)
	selected_label = _label("No selection", 18)
	selected_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.add_child(selected_label)
	var actions := HBoxContainer.new()
	details.add_child(actions)
	_button(actions, "Duplicate", _duplicate_selected)
	_button(actions, "Delete", _delete_selected)
	for axis in ["x", "y", "z"]:
		position_fields[axis] = _spin_row(details, axis.to_upper() + " position (m)", -500, 500, 0.05, func(value): _edit_position(axis, value))
	rotation_field = _spin_row(details, "Rotation (°)", -3600, 3600, 15, _edit_rotation)
	scale_field = _spin_row(details, "Scale", 0.1, 10, 0.1, _edit_scale)
	scale_field.value = 1.0
	details.add_child(_label("Drag objects to move them.\nValues above use the first object\nwhen several are selected.", 14))
	var notes_tab := VBoxContainer.new()
	notes_tab.name = "Notes"
	notes_tab.add_theme_constant_override("separation", 12)
	inspector_tabs.add_child(notes_tab)
	notes_tab.add_child(_label("DESIGN NOTES", 18))
	notes = TextEdit.new()
	notes.size_flags_vertical = Control.SIZE_EXPAND_FILL
	notes.custom_minimum_size.y = 220
	notes.placeholder_text = "What is this area for?\n\nWhat should the AI preserve or explore?"
	notes.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	notes.text_changed.connect(_refresh_dirty)
	notes.focus_exited.connect(_remember)
	notes_tab.add_child(notes)
	mode_help = _label("", 16)
	mode_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(mode_help)
	status = _label("", 14)
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(status)
	save_dialog = ConfirmationDialog.new()
	save_dialog.title = "Save visual layout"
	save_dialog.ok_button_text = "Save"
	var save_box := VBoxContainer.new()
	save_box.add_child(_label("Saved inside the workshop's layouts folder.", 16))
	save_name = LineEdit.new()
	save_name.placeholder_text = "Layout filename"
	save_box.add_child(save_name)
	save_dialog.add_child(save_box)
	save_dialog.confirmed.connect(_save_from_dialog)
	add_child(save_dialog)
	load_dialog = ConfirmationDialog.new()
	load_dialog.title = "Open a visual layout"
	load_dialog.ok_button_text = "Open"
	load_list = ItemList.new()
	load_list.custom_minimum_size = Vector2(520, 300)
	load_dialog.add_child(load_list)
	load_dialog.confirmed.connect(_load_from_dialog)
	add_child(load_dialog)
	pending_new = ConfirmationDialog.new()
	pending_new.title = "Start a new layout"
	pending_new.dialog_text = "Discard the current unsaved layout and start fresh?"
	pending_new.ok_button_text = "Discard and start new"
	pending_new.confirmed.connect(_new_layout)
	add_child(pending_new)
	folder_dialog = ConfirmationDialog.new()
	folder_dialog.title = "Create folder"
	var folder_box := VBoxContainer.new()
	folder_box.add_child(_label("Folder name", 16))
	folder_name = LineEdit.new()
	folder_box.add_child(folder_name)
	folder_box.add_child(_label("Parent folder", 16))
	folder_parent = OptionButton.new()
	folder_box.add_child(folder_parent)
	folder_dialog.add_child(folder_box)
	folder_dialog.confirmed.connect(_confirm_folder)
	add_child(folder_dialog)
	move_dialog = ConfirmationDialog.new()
	move_dialog.title = "Move selected objects to a folder"
	move_dialog.ok_button_text = "Move"
	move_target = OptionButton.new()
	move_dialog.add_child(move_target)
	move_dialog.confirmed.connect(func(): _move_selection_to_folder(move_target.get_selected_id()))
	add_child(move_dialog)


func _label(text_value: String, font_size: int) -> Label:
	var result := Label.new()
	result.text = text_value
	result.add_theme_font_size_override("font_size", font_size)
	result.set_meta("base_font_size", font_size)
	return result


func _button(parent: Node, text_value: String, action: Callable) -> Button:
	var result := Button.new()
	result.text = text_value
	result.focus_mode = Control.FOCUS_NONE
	result.pressed.connect(action)
	parent.add_child(result)
	return result


func _spin_row(parent: Node, text_value: String, minimum: float, maximum: float, step_value: float, action: Callable) -> SpinBox:
	var row := HBoxContainer.new()
	var label := _label(text_value, 16)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var field := SpinBox.new()
	field.min_value = minimum
	field.max_value = maximum
	field.step = step_value
	field.custom_minimum_size.x = 100
	row.add_child(field)
	parent.add_child(row)
	field.value_changed.connect(action)
	return field


func _build_world() -> void:
	world = Node3D.new()
	viewport.add_child(world)
	object_root = Node3D.new()
	world.add_child(object_root)
	grid_root = Node3D.new()
	world.add_child(grid_root)
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("24353f")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("d6e6f0")
	settings.ambient_light_energy = 0.35
	settings.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	environment.environment = settings
	world.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-55, -35, 0)
	light.light_energy = 0.65
	light.shadow_enabled = true
	world.add_child(light)
	camera = Camera3D.new()
	camera.far = 1500
	camera.fov = 48
	world.add_child(camera)
	camera.current = true
	selection_outline = MeshInstance3D.new()
	selection_outline.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	world.add_child(selection_outline)
	_rebuild_grid()
	_update_camera()


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material


func _box(parent: Node3D, size_value: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size_value
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = _material(color)
	instance.position = at
	parent.add_child(instance)
	return instance


func _map_rect(width := grid_width, depth := grid_depth) -> Rect2:
	# Keep the tile lattice fixed when an odd dimension adds a cell on the positive side.
	return Rect2(Vector2(-floorf(width/2.0)*TILE, -floorf(depth/2.0)*TILE), Vector2(width*TILE, depth*TILE))


func _ground_cell_allowed(at: Vector3) -> bool:
	var bounds := _map_rect()
	var half := Vector2.ONE*TILE/2.0
	var center := Vector2(at.x, at.z)
	return _position_allowed(at) and center.x >= bounds.position.x+half.x-0.001 and center.y >= bounds.position.y+half.y-0.001 and center.x <= bounds.end.x-half.x+0.001 and center.y <= bounds.end.y-half.y+0.001


func _open_map_size() -> void:
	_finish_gesture()
	var dialog := ConfirmationDialog.new()
	dialog.title = "Map size"
	dialog.get_ok_button().text = "Apply size"
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	dialog.add_child(content)
	var width_field := _spin_row(content, "Width (tiles)", 4, 128, 1, func(_value): pass)
	var depth_field := _spin_row(content, "Depth (tiles)", 4, 128, 1, func(_value): pass)
	width_field.value = grid_width
	depth_field.value = grid_depth
	var description := _label("", 18)
	content.add_child(description)
	var update_description := func(_value = 0):
		description.text = "%.1f × %.1f metres · 1 tile = %.1f metres\n\nExisting objects keep their positions, including objects\noutside a smaller map. Ground painting stays inside\nthe new boundary. Undo restores the previous size." % [width_field.value*TILE, depth_field.value*TILE, TILE]
	width_field.value_changed.connect(update_description)
	depth_field.value_changed.connect(update_description)
	update_description.call()
	dialog.confirmed.connect(func():
		_resize_map(int(width_field.value), int(depth_field.value))
		dialog.queue_free()
	)
	dialog.canceled.connect(dialog.queue_free)
	add_child(dialog)
	dialog.popup_centered(Vector2i(650, 300))


func _resize_map(width: int, depth: int) -> void:
	if width < 4 or width > 128 or depth < 4 or depth > 128: return
	_finish_gesture()
	_remember()
	grid_width = width
	grid_depth = depth
	_rebuild_grid()
	_remember()
	_update_preview()
	_message("Map resized to %d × %d tiles. Existing objects kept; Undo restores the size." % [width, depth])


func _rebuild_grid() -> void:
	if not grid_root:
		return
	for child in grid_root.get_children():
		child.free()
	var bounds := _map_rect()
	var width_m := bounds.size.x
	var depth_m := bounds.size.y
	_box(grid_root, Vector3(width_m, 0.1, depth_m), Vector3(bounds.get_center().x, -0.14, bounds.get_center().y), Color("4a5c63"))
	var lines := ImmediateMesh.new()
	var material := _material(Color("718389"))
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lines.surface_begin(Mesh.PRIMITIVE_LINES, material)
	for x in range(grid_width + 1):
		var at := bounds.position.x + x*TILE
		lines.surface_add_vertex(Vector3(at, -0.075, bounds.position.y))
		lines.surface_add_vertex(Vector3(at, -0.075, bounds.end.y))
	for z in range(grid_depth + 1):
		var at := bounds.position.y + z*TILE
		lines.surface_add_vertex(Vector3(bounds.position.x, -0.075, at))
		lines.surface_add_vertex(Vector3(bounds.end.x, -0.075, at))
	lines.surface_end()
	var instance := MeshInstance3D.new()
	instance.mesh = lines
	grid_root.add_child(instance)
	_refresh_dirty()


func _bounds(node: Node3D, accumulated := Transform3D.IDENTITY) -> AABB:
	var transform_value: Transform3D = accumulated * node.transform
	var result := AABB()
	if node is MeshInstance3D and node.mesh:
		result = transform_value * node.get_aabb()
	for child in node.get_children():
		if child is Node3D:
			var child_bounds := _bounds(child, transform_value)
			if child_bounds.size != Vector3.ZERO:
				result = child_bounds if result.size == Vector3.ZERO else result.merge(child_bounds)
	return result


func _template(kind: String) -> Node3D:
	if templates.has(kind):
		return templates[kind]
	var definition: Dictionary = definitions[kind]
	var root := Node3D.new()
	root.set_meta("piece_kind", kind)
	if definition.has("size"):
		var size_value: Vector3 = definition.size
		_box(root, size_value, Vector3(0, size_value.y/2.0 + definition.get("base", 0.0), 0), definition.color)
	elif definition.has("assembly"):
		_build_assembly(root, definition.assembly)
	else:
		var scene := load("res://assets/%s.glb" % kind) as PackedScene
		if not scene:
			push_error("Missing copied model: " + kind)
			_box(root, Vector3.ONE, Vector3(0, 0.5, 0), Color.MAGENTA)
		else:
			var model := scene.instantiate() as Node3D
			root.add_child(model)
			var bounds := _bounds(model)
			var ratio: float = definition.height / maxf(bounds.size.y, 0.001)
			model.scale *= ratio
			model.position -= Vector3(bounds.get_center().x, bounds.position.y, bounds.get_center().z) * ratio
			_disable_animations(model)
	templates[kind] = root
	return root


func _disable_animations(node: Node) -> void:
	if node is AnimationPlayer:
		node.stop()
		node.autoplay = ""
	for child in node.get_children():
		_disable_animations(child)


func _build_assembly(root: Node3D, assembly: String) -> void:
	if assembly == "crates":
		for at in [Vector3(-0.9, 0, 0), Vector3(0.9, 0, 0), Vector3(0, 1.6, 0)]:
			var prop := _template("shipping_crates").duplicate() as Node3D
			prop.position = at
			root.add_child(prop)
		return
	var cells := 4 if assembly == "room" else 6
	var side := cells*TILE
	_box(root, Vector3(side, 0.08, side), Vector3(0, -0.04, 0), Color("829398") if assembly == "room" else Color("637970"))
	for i in range(cells):
		var along := -side/2.0 + TILE/2.0 + i*TILE
		var height := 2.8 if assembly == "room" else 0.9
		var color := Color("c4c5bc") if assembly == "room" else Color("849894")
		_box(root, Vector3(TILE, height, 0.22), Vector3(along, height/2.0, -side/2.0), color)
		if i != cells/2:
			_box(root, Vector3(TILE, height, 0.22), Vector3(along, height/2.0, side/2.0), color)
		_box(root, Vector3(0.22, height, TILE), Vector3(-side/2.0, height/2.0, along), color)
		_box(root, Vector3(0.22, height, TILE), Vector3(side/2.0, height/2.0, along), color)


func _collider(parent: Node3D, bounds: AABB, id: int) -> void:
	var body := StaticBody3D.new()
	body.set_meta("item_id", id)
	var shape := BoxShape3D.new()
	shape.size = bounds.size.max(Vector3(0.05, 0.05, 0.05))
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = bounds.get_center()
	body.add_child(collision)
	parent.add_child(body)


func _assembly_colliders(root: Node3D, node: Node3D, id: int, accumulated := Transform3D.IDENTITY) -> void:
	var transform_value: Transform3D = accumulated * node.transform
	if node is MeshInstance3D and node.mesh:
		_collider(root, transform_value * node.get_aabb(), id)
	for child in node.get_children():
		if child is Node3D and not child is StaticBody3D:
			_assembly_colliders(root, child, id, transform_value)


func _spawn(item: Dictionary) -> void:
	var root := Node3D.new()
	root.name = "Piece_%d" % int(item.id)
	object_root.add_child(root)
	var visual := _template(item.kind).duplicate() as Node3D
	root.add_child(visual)
	if definitions[item.kind].has("assembly"):
		_assembly_colliders(root, visual, int(item.id))
	else:
		_collider(root, _bounds(visual), int(item.id))
	objects[int(item.id)] = root
	_sync_object(item)


func _sync_object(item: Dictionary) -> void:
	var object: Node3D = objects[int(item.id)]
	object.position = Vector3(item.position[0], item.position[1], item.position[2])
	object.rotation.y = deg_to_rad(item.rotation)
	object.scale = Vector3.ONE * item.scale
	_update_outline()


func _current() -> Dictionary:
	for item in items:
		if int(item.id) == selected:
			return item
	return {}


func _selection_items() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item in items:
		if selected_ids.has(int(item.id)):
			result.append(item)
	return result


func _set_selection(ids: Array[int], primary := -1) -> void:
	selected_ids.clear()
	for id in ids:
		if objects.has(id) and not selected_ids.has(id):
			selected_ids.append(id)
	selected = primary if selected_ids.has(primary) else (selected_ids[0] if not selected_ids.is_empty() else -1)


func _selection_center() -> Vector3:
	var center := Vector3.ZERO
	for item in _selection_items():
		center += Vector3(item.position[0], item.position[1], item.position[2])
	return center/maxi(selected_ids.size(), 1)


func _position_allowed(at: Vector3) -> bool:
	return at.is_finite() and absf(at.x) <= 500 and absf(at.y) <= 500 and absf(at.z) <= 500


func _limited_delta(delta: Vector3, source: Array[Dictionary]) -> Vector3:
	for item in source:
		for axis in range(3):
			delta[axis] = clampf(delta[axis], -500-item.position[axis], 500-item.position[axis])
	return delta


func _move_drag_selection(delta: Vector3) -> void:
	var source: Array[Dictionary] = []
	for item in _selection_items():
		source.append({"position":_vector_array(drag_positions[int(item.id)])})
	delta = _limited_delta(delta, source)
	for item in _selection_items():
		item.position = _vector_array(drag_positions[int(item.id)]+delta)
		_sync_object(item)
	_refresh_dirty()


func _is_ground(kind: String) -> bool:
	return kind in ["floor", "street", "grass"]


func _begin_stroke() -> void:
	_remember()
	painting = true
	paint_last = null
	stroke_changed = false
	stroke_cells.clear()


func _finish_gesture() -> void:
	if painting:
		painting = false
		paint_last = null
		if stroke_changed:
			_remember()
			_message("Ground stroke complete. Undo reverses the whole stroke.")
		stroke_changed = false
	if dragging:
		dragging = false
		_remember()
	panning = false
	orbiting = false


func _paint_to(point: Vector3) -> void:
	if not point.is_finite() or not _map_rect().has_point(Vector2(point.x, point.z)):
		paint_last = null
		return
	var at := _snapped(point, "floor")
	var previous: Vector3 = at if paint_last == null else paint_last
	var count := maxi(1, int(ceil(maxf(absf(at.x-previous.x), absf(at.z-previous.z))/TILE*2)))
	for step_index in range(count+1):
		var center := _snapped(previous.lerp(at, float(step_index)/count), "floor")
		var radius := brush_cells/2
		for x in range(-radius, radius+1):
			for z in range(-radius, radius+1):
				var cell := center + Vector3(x*TILE, 0, z*TILE)
				var cell_key := Vector3i(roundi((cell.x-TILE/2)/TILE), roundi(cell.y*100), roundi((cell.z-TILE/2)/TILE))
				if not stroke_cells.has(cell_key) and _ground_cell_allowed(cell):
					stroke_cells[cell_key] = true
					_paint_cell(cell)
	paint_last = at
	_refresh_dirty()


func _paint_cell(at: Vector3) -> void:
	if not _ground_cell_allowed(at): return
	var existing: Array[Dictionary] = []
	for item in items:
		if _is_ground(item.kind) and Vector3(item.position[0],item.position[1],item.position[2]).distance_to(at) < 0.01:
			existing.append(item)
	if mode != "erase" and existing.size() == 1 and existing[0].kind == brush:
		return
	for item in existing:
		objects[int(item.id)].free()
		objects.erase(int(item.id))
		items.erase(item)
		stroke_changed = true
	if mode != "erase" and items.size() < 5000:
		var item := {"id":next_id, "kind":brush, "position":_vector_array(at), "rotation":0.0, "scale":1.0, "folder_id":active_folder}
		next_id += 1
		items.append(item)
		_spawn(item)
		stroke_changed = true


func _folder(id: int) -> Dictionary:
	for folder in folders:
		if int(folder.id) == id:
			return folder
	return {}


func _folder_path(id: int) -> String:
	var names: Array[String] = []
	while id != 0:
		var folder := _folder(id)
		if folder.is_empty(): break
		names.push_front(folder.name)
		id = int(folder.parent)
	return " / ".join(names) if not names.is_empty() else "Scene root"


func _belongs_to_folder(id: int, target: int) -> bool:
	while id != 0:
		if id == target: return true
		var folder := _folder(id)
		if folder.is_empty(): return false
		id = int(folder.parent)
	return false


func _rebuild_scene_tree() -> void:
	if not selection_list: return
	tree_refreshing = true
	var collapsed := {}
	for id in folder_rows:
		collapsed[id] = folder_rows[id].collapsed
	selection_list.clear()
	tree_rows.clear()
	folder_rows.clear()
	var root := selection_list.create_item()
	_build_tree_branch(root, 0, collapsed)
	_sync_tree_selection()
	tree_refreshing = false


func _build_tree_branch(parent: TreeItem, folder_id: int, collapsed: Dictionary) -> void:
	for folder in folders:
		if int(folder.parent) != folder_id: continue
		var row := selection_list.create_item(parent)
		row.set_text(0, "▤  " + folder.name)
		row.set_metadata(0, {"folder":int(folder.id)})
		row.set_custom_color(0, ACCENT)
		folder_rows[int(folder.id)] = row
		_build_tree_branch(row, int(folder.id), collapsed)
		row.collapsed = collapsed.get(int(folder.id), false)
	for item in items:
		if int(item.get("folder_id", 0)) != folder_id: continue
		var row := selection_list.create_item(parent)
		row.set_text(0, "%s · %d" % [definitions[item.kind].name, int(item.id)])
		row.set_metadata(0, {"item":int(item.id)})
		tree_rows[int(item.id)] = row


func _sync_tree_selection() -> void:
	if not selection_list: return
	var was_refreshing := tree_refreshing
	tree_refreshing = true
	selection_list.deselect_all()
	if folder_selected and folder_rows.has(active_folder):
		folder_rows[active_folder].select(0)
	else:
		for id in selected_ids:
			if tree_rows.has(id): tree_rows[id].select(0)
	tree_refreshing = was_refreshing


func _tree_selection_changed() -> void:
	if tree_refreshing: return
	var ids: Array[int] = []
	var chosen_folders: Array[int] = []
	var row := selection_list.get_next_selected(null)
	while row:
		var data: Dictionary = row.get_metadata(0)
		if data.has("item") and not ids.has(int(data.item)):
			ids.append(int(data.item))
		elif data.has("folder"):
			chosen_folders.append(int(data.folder))
			for item in items:
				if _belongs_to_folder(int(item.get("folder_id",0)), int(data.folder)) and not ids.has(int(item.id)):
					ids.append(int(item.id))
		row = selection_list.get_next_selected(row)
	folder_selected = chosen_folders.size() == 1
	active_folder = chosen_folders[0] if folder_selected else 0
	_set_selection(ids)
	_set_mode("select", false)


func _scene_tree_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and (event.ctrl_pressed or event.meta_pressed):
		if event.pressed:
			var row := selection_list.get_item_at_position(event.position)
			if row:
				if row.is_selected(0): row.deselect(0)
				else: row.select(0)
				selection_list.grab_focus()
				_tree_selection_changed.call_deferred()
		selection_list.accept_event()


func _refresh_folder_label() -> void:
	if folder_label:
		folder_label.text = "%s\n%d selected" % [_folder_path(active_folder), selected_ids.size()]


func _fill_folder_options(field: OptionButton, exclude := 0) -> void:
	field.clear()
	field.add_item("Scene root", 0)
	for folder in folders:
		if exclude != 0 and _belongs_to_folder(int(folder.id), exclude): continue
		field.add_item(_folder_path(int(folder.id)), int(folder.id))
	for index in field.item_count:
		if field.get_item_id(index) == active_folder:
			field.select(index)


func _open_folder(rename: bool) -> void:
	if rename and active_folder == 0:
		_message("Select a folder in the scene tree to rename it.")
		return
	folder_rename_id = active_folder if rename else 0
	folder_dialog.title = "Rename or move folder" if rename else "Create folder"
	folder_name.text = _folder(active_folder).name if rename else "New folder"
	_fill_folder_options(folder_parent, folder_rename_id)
	if rename:
		for index in folder_parent.item_count:
			if folder_parent.get_item_id(index) == int(_folder(active_folder).parent): folder_parent.select(index)
	folder_dialog.popup_centered(Vector2i(560, 220))
	folder_name.grab_focus()
	folder_name.select_all()


func _confirm_folder() -> void:
	var name_value := folder_name.text.strip_edges().left(80)
	if name_value.is_empty():
		_message("Give the folder a name.")
		return
	var parent := folder_parent.get_selected_id()
	if folder_rename_id != 0:
		var folder := _folder(folder_rename_id)
		folder.name = name_value
		folder.parent = parent
		_remember()
	else:
		_create_folder(name_value, parent)
	_refresh()


func _create_folder(name_value: String, parent := 0) -> int:
	if folders.size() >= 5000 or (parent != 0 and _folder(parent).is_empty()):
		_message("Cannot create that folder: the parent is missing or the folder limit was reached.")
		return -1
	var id := next_folder_id
	next_folder_id += 1
	folders.append({"id":id, "name":name_value, "parent":parent})
	for item in _selection_items(): item.folder_id = id
	active_folder = id
	folder_selected = true
	_remember()
	_refresh()
	return id


func _open_move_folder() -> void:
	if selected_ids.is_empty():
		_message("Select the objects you want to organise, then choose Move to…")
		return
	_fill_folder_options(move_target)
	move_dialog.popup_centered(Vector2i(560, 160))


func _move_selection_to_folder(id: int) -> void:
	if id != 0 and _folder(id).is_empty(): return
	for item in _selection_items(): item.folder_id = id
	active_folder = id
	folder_selected = false
	_remember()
	_refresh()


func _remove_folder() -> void:
	var folder := _folder(active_folder)
	if folder.is_empty():
		_message("Select a folder to ungroup it. Its objects will be kept.")
		return
	for item in items:
		if int(item.get("folder_id",0)) == active_folder: item.folder_id = int(folder.parent)
	for child in folders:
		if int(child.parent) == active_folder: child.parent = int(folder.parent)
	folders.erase(folder)
	active_folder = int(folder.parent)
	folder_selected = false
	_remember()
	_refresh()


func _set_ui_size(index: int) -> void:
	ui_size = [1.0,1.12,1.24][index]
	theme.default_font_size = roundi(18*ui_size)
	_resize_labels(self)
	if not verification_mode:
		_write_json("res://workshop-settings.json", {"text_size":index})


func _resize_labels(node: Node) -> void:
	if node is Control and node.has_meta("base_font_size"):
		node.add_theme_font_size_override("font_size", roundi(node.get_meta("base_font_size")*ui_size))
	for child in node.get_children(): _resize_labels(child)


func _show_help() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Workshop controls"
	dialog.dialog_text = "Paint ground: choose a ground tile and drag. X erases ground.\nBrush sizes: 1, 3, 5 or 9 tiles across. Each stroke is one undo.\n\nSelection: Ctrl / Cmd-click adds or removes objects.\nScene tree: Ctrl / Cmd adds rows; Shift selects a range.\nFolders organise objects; clicking a folder selects its contents.\nDrag, rotate, resize, duplicate or delete a selection together.\n\nV: select   B: paint / place   R: rotate 90°   F: fit\nCmd / Ctrl-Z: undo   Cmd / Ctrl-D: duplicate\nShift-left or middle drag: pan   Option-left or right drag: orbit\nWheel or pinch: zoom\n\nScene: folders and objects   Details: precise transforms\nMap size: change width and depth, in tiles\nNotes: design notes\nHandoff: two screenshots, layout data, and your design notes."
	add_child(dialog)
	dialog.popup_centered(Vector2i(850, 540))
	dialog.confirmed.connect(dialog.queue_free)


func _save_recovery() -> void:
	if not verification_mode and notes:
		_write_json("res://recovery.json", _document(true))


func _ground_point(at: Vector2, height: float) -> Variant:
	var origin := camera.project_ray_origin(at)
	var direction := camera.project_ray_normal(at)
	return Plane(Vector3.UP, height).intersects_ray(origin, direction)


func _snapped(at: Vector3, kind: String) -> Vector3:
	if definitions[kind].grid or snap_props:
		var offset := 0.0 if kind in ["room", "yard", "building"] else TILE/2.0
		at.x = snappedf(at.x-offset, TILE)+offset
		at.z = snappedf(at.z-offset, TILE)+offset
	at.x = clampf(at.x, -499.5, 499.5)
	at.z = clampf(at.z, -499.5, 499.5)
	return at


func _pick(at: Vector2) -> int:
	var origin := camera.project_ray_origin(at)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + camera.project_ray_normal(at)*1500)
	var hit := world.get_world_3d().direct_space_state.intersect_ray(query)
	return int(hit.collider.get_meta("item_id", -1)) if not hit.is_empty() else -1


func _workspace_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		hover = event.position
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			distance = maxf(3, distance*0.9)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			distance = minf(500, distance*1.1)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			orbiting = event.pressed
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			panning = event.pressed
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				canvas.grab_focus()
				if event.shift_pressed:
					panning = true
				elif event.alt_pressed:
					orbiting = true
				elif mode == "erase" or (mode == "place" and _is_ground(brush)):
					_begin_stroke()
					var point = _ground_point(event.position, placement_y)
					if point != null: _paint_to(point)
				elif mode == "place":
					var point = _ground_point(event.position, placement_y)
					if point != null: _place(brush, _snapped(point, brush), placement_rotation, placement_scale)
				else:
					var hit := _pick(event.position)
					var additive: bool = event.ctrl_pressed or event.meta_pressed
					if additive:
						_select(hit, true, true)
					elif not selected_ids.has(hit):
						_select(hit)
					var item := _current()
					if not additive and not item.is_empty():
						var point = _ground_point(event.position, item.position[1])
						if point != null:
							dragging = true
							drag_offset = objects[selected].position - point
							drag_positions.clear()
							for selected_item in _selection_items():
								drag_positions[int(selected_item.id)] = Vector3(selected_item.position[0], selected_item.position[1], selected_item.position[2])
			else:
				_finish_gesture()
	elif event is InputEventMouseMotion:
		hover = event.position
		if orbiting:
			yaw -= event.relative.x*0.008
			pitch = clampf(pitch + event.relative.y*0.008, 0.12, PI/2.0 - 0.001)
			_update_camera()
		elif panning:
			var factor := distance*0.0015
			focus += (-camera.global_basis.x*event.relative.x + Vector3(sin(yaw), 0, cos(yaw))*event.relative.y)*factor
			_update_camera()
		elif painting:
			var point = _ground_point(event.position, placement_y)
			if point != null: _paint_to(point)
		elif dragging:
			var item := _current()
			if not item.is_empty():
				var point = _ground_point(event.position, item.position[1])
				if point != null:
					var destination := _snapped(point + drag_offset, item.kind)
					var delta: Vector3 = destination - drag_positions[selected]
					_move_drag_selection(delta)
					_refresh_inspector()
		_update_preview()
	elif event is InputEventMagnifyGesture:
		distance = clampf(distance/event.factor, 3, 500)
		_update_camera()
	elif event is InputEventPanGesture:
		focus += (-camera.global_basis.x*event.delta.x + Vector3(sin(yaw), 0, cos(yaw))*event.delta.y)*distance*0.01
		_update_camera()
	canvas.accept_event()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_finish_gesture()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			orbiting = false
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			panning = false


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	var focused := get_viewport().gui_get_focus_owner()
	if focused is LineEdit or focused is TextEdit:
		return
	if event.ctrl_pressed or event.meta_pressed:
		match event.keycode:
			KEY_Z:
				if event.shift_pressed: _redo()
				else: _undo()
			KEY_Y: _redo()
			KEY_S: _open_save()
			KEY_D: _duplicate_selected()
			KEY_A:
				var ids: Array[int] = []
				for item in items: ids.append(int(item.id))
				_set_selection(ids)
				_sync_tree_selection()
				_refresh(false)
	else:
		match event.keycode:
			KEY_ESCAPE, KEY_V: _set_mode("select")
			KEY_B: _set_mode("place")
			KEY_X: _set_mode("erase")
			KEY_R: _rotate()
			KEY_DELETE, KEY_BACKSPACE: _delete_selected()
			KEY_F: _frame_layout()
	get_viewport().set_input_as_handled()


func _update_camera() -> void:
	if not camera:
		return
	camera.position = focus + Vector3(sin(yaw)*cos(pitch), sin(pitch), cos(yaw)*cos(pitch))*distance
	camera.size = distance*0.85
	camera.look_at(focus, Vector3.UP)
	_update_preview()


func _top_view() -> void:
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	pitch = PI/2.0 - 0.001
	yaw = 0
	_update_camera()


func _frame_layout() -> void:
	if items.is_empty():
		focus = Vector3.ZERO
		distance = maxf(grid_width, grid_depth)*TILE*1.3
	else:
		var bounds := AABB()
		for item in items:
			var object: Node3D = objects[int(item.id)]
			var piece := object.transform * _bounds(_template(item.kind))
			bounds = piece if bounds.size == Vector3.ZERO else bounds.merge(piece)
		focus = bounds.get_center()
		distance = maxf(8, maxf(bounds.size.x, bounds.size.z)*1.7 + bounds.size.y)
	distance = clampf(distance, 3, 500)
	_update_camera()


func _update_palette() -> void:
	palette.clear()
	for definition in catalog:
		if category.selected > 0 and definition.category != category.get_item_text(category.selected):
			continue
		if not search.text.is_empty() and not definition.name.to_lower().contains(search.text.to_lower()):
			continue
		var index := palette.add_item(definition.name)
		palette.set_item_metadata(index, definition.id)
		palette.set_item_tooltip(index, "%s • %s" % [definition.category, "Grid snapped" if definition.grid else "Free placement; optional grid snap"])
		if definition.id == brush:
			palette.select(index)


func _choose_piece(index: int) -> void:
	brush = palette.get_item_metadata(index)
	selected = -1
	placement_rotation = 0
	placement_scale = 1
	placement_y = 0
	_set_mode("place")
	_rebuild_preview()
	_refresh()


func _set_mode(value: String, refresh_tree := true) -> void:
	_finish_gesture()
	mode = value
	_update_palette()
	select_button.modulate = ACCENT if mode == "select" else Color.WHITE
	place_button.modulate = ACCENT if mode == "place" else Color.WHITE
	erase_button.modulate = Color("ffb69b") if mode == "erase" else Color.WHITE
	if mode in ["place", "erase"]:
		selected = -1
		selected_ids.clear()
		folder_selected = false
		_rebuild_preview()
	elif preview:
		preview.visible = false
	_refresh(refresh_tree)


func _rebuild_preview() -> void:
	if preview:
		preview.free()
	preview = _template("floor" if mode == "erase" else brush).duplicate() as Node3D
	world.add_child(preview)
	var material := _material(Color(1, 0.45, 0.25, 0.38) if mode == "erase" else Color(0.42, 0.95, 0.8, 0.38))
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ghost_material(preview, material)
	_update_preview()


func _ghost_material(node: Node, material: Material) -> void:
	if node is MeshInstance3D:
		node.material_override = material
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for child in node.get_children():
		_ghost_material(child, material)


func _update_preview() -> void:
	if not preview:
		return
	preview.visible = mode in ["place", "erase"] and canvas.get_global_rect().has_point(get_global_mouse_position())
	if not preview.visible:
		return
	var point = _ground_point(hover, placement_y)
	if point == null:
		preview.visible = false
		return
	if (mode == "erase" or _is_ground(brush)) and not _map_rect().has_point(Vector2(point.x, point.z)):
		preview.visible = false
		return
	preview.position = _snapped(point, "floor" if mode == "erase" else brush)
	preview.rotation.y = 0 if mode == "erase" or _is_ground(brush) else deg_to_rad(placement_rotation)
	preview.scale = Vector3(brush_cells,1,brush_cells) if mode == "erase" or _is_ground(brush) else Vector3.ONE*placement_scale
	if mode == "erase" or _is_ground(brush):
		var extent := Vector2.ONE*brush_cells*TILE
		var footprint := Rect2(Vector2(preview.position.x, preview.position.z)-extent/2, extent).intersection(_map_rect())
		preview.position.x = footprint.get_center().x
		preview.position.z = footprint.get_center().y
		preview.scale = Vector3(footprint.size.x/TILE, 1, footprint.size.y/TILE)


func _place(kind: String, at: Vector3, rotation_value := 0.0, scale_value := 1.0) -> void:
	if items.size() >= 5000:
		_message("The workspace supports up to 5,000 pieces.")
		return
	var definition: Dictionary = definitions[kind]
	if definition.grid:
		for item in items:
			if item.kind == kind and Vector3(item.position[0], item.position[1], item.position[2]).distance_to(at) < 0.01 and is_equal_approx(item.rotation, rotation_value):
				_message("That grid piece is already here. Select it to move or rotate it.")
				return
	var item := {"id":next_id, "kind":kind, "position":[at.x, at.y, at.z], "rotation":rotation_value, "scale":scale_value, "folder_id":active_folder}
	next_id += 1
	items.append(item)
	_spawn(item)
	_remember()
	_refresh()
	_message("Placed %s. Keep clicking to place more; V selects and moves pieces." % definition.name)


func _select(id: int, additive := false, toggle := false) -> void:
	var ids: Array[int] = []
	if additive: ids.assign(selected_ids)
	if id >= 0 and objects.has(id):
		if toggle and ids.has(id): ids.erase(id)
		elif not ids.has(id): ids.append(id)
	folder_selected = false
	_set_selection(ids, id)
	if id >= 0:
		active_folder = int(_current().get("folder_id", 0)) if not _current().is_empty() else 0
	_sync_tree_selection()
	_refresh_inspector()
	_update_outline()
	_refresh_folder_label()


func _update_outline() -> void:
	if not selection_outline: return
	selection_outline.visible = not selected_ids.is_empty()
	if not selection_outline.visible: return
	var lines := ImmediateMesh.new()
	var material := _material(ACCENT)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = true
	lines.surface_begin(Mesh.PRIMITIVE_LINES, material)
	for item in _selection_items():
		var object: Node3D = objects[int(item.id)]
		var bounds := _bounds(_template(item.kind)).grow(0.045)
		var low := bounds.position
		var high := bounds.end
		var corners := [Vector3(low.x,low.y,low.z), Vector3(high.x,low.y,low.z), Vector3(high.x,low.y,high.z), Vector3(low.x,low.y,high.z), Vector3(low.x,high.y,low.z), Vector3(high.x,high.y,low.z), Vector3(high.x,high.y,high.z), Vector3(low.x,high.y,high.z)]
		for edge in [[0,1],[1,2],[2,3],[3,0],[4,5],[5,6],[6,7],[7,4],[0,4],[1,5],[2,6],[3,7]]:
			lines.surface_add_vertex(object.transform * corners[edge[0]])
			lines.surface_add_vertex(object.transform * corners[edge[1]])
	lines.surface_end()
	selection_outline.mesh = lines
	selection_outline.transform = Transform3D.IDENTITY


func _refresh(refresh_tree := true) -> void:
	if not selected_label: return
	_refresh_inspector()
	if refresh_tree: _rebuild_scene_tree()
	_update_outline()
	_refresh_dirty()
	undo_button.disabled = history_index <= 0
	redo_button.disabled = history_index >= history.size()-1
	place_button.text = "Paint  [B]" if _is_ground(brush) else "Place  [B]"
	brush_size_field.disabled = not _is_ground(brush) and mode != "erase"
	snap_toggle.visible = not definitions[brush].grid
	placement_label.text = "%s\n%s" % [definitions[brush].name, "Drag to paint ground" if _is_ground(brush) else ("Click to place · grid snapped" if definitions[brush].grid else "Click to place · free positioning")]
	if mode == "erase": mode_help.text = "Erase ground: drag across tiles. Props and walls are preserved. One undo per stroke."
	elif mode == "place" and _is_ground(brush): mode_help.text = "Paint ground: click and drag. Choose a brush size on the left. One undo per stroke."
	elif mode == "place": mode_help.text = "Place: click to add a piece. R rotates it. V returns to selection."
	else: mode_help.text = "Select: Ctrl / Cmd-click adds objects. Drag the selection to move it together."
	_refresh_folder_label()


func _refresh_inspector() -> void:
	refreshing = true
	var item := _current()
	selected_label.text = definitions[item.kind].name + " · #%d" % selected if not item.is_empty() else ("Placing: " + definitions[brush].name if mode == "place" else "Select a piece in the scene\nor in the object list below.")
	if selected_ids.size() > 1:
		selected_label.text = "%d objects selected\nTransforms apply together" % selected_ids.size()
	for axis in ["x", "y", "z"]:
		var index: int = ["x", "y", "z"].find(axis)
		position_fields[axis].value = item.position[index] if not item.is_empty() else (placement_y if axis == "y" else 0)
		position_fields[axis].editable = not item.is_empty() or (mode == "place" and axis == "y")
	rotation_field.value = item.rotation if not item.is_empty() else placement_rotation
	scale_field.value = item.scale if not item.is_empty() else placement_scale
	rotation_field.editable = not item.is_empty() or mode == "place"
	scale_field.editable = not item.is_empty() or mode == "place"
	refreshing = false


func _edit_position(axis: String, value: float) -> void:
	if refreshing: return
	var item := _current()
	if item.is_empty():
		if axis == "y":
			placement_y = value
			_update_preview()
		return
	var origin := Vector3(item.position[0], item.position[1], item.position[2])
	var destination := origin
	destination[["x", "y", "z"].find(axis)] = value
	destination = _snapped(destination, item.kind)
	var delta := _limited_delta(destination-origin, _selection_items())
	for selected_item in _selection_items():
		var at := Vector3(selected_item.position[0], selected_item.position[1], selected_item.position[2]) + delta
		selected_item.position = _vector_array(at)
		_sync_object(selected_item)
	_remember()
	_refresh_inspector()


func _edit_rotation(value: float) -> void:
	if refreshing: return
	var item := _current()
	if item.is_empty():
		placement_rotation = value
		_update_preview()
	else:
		var delta := value-float(item.rotation)
		var pivot := _selection_center()
		var changed: Array[Dictionary] = []
		for selected_item in _selection_items():
			var at := pivot + (Vector3(selected_item.position[0], selected_item.position[1], selected_item.position[2])-pivot).rotated(Vector3.UP, deg_to_rad(delta))
			if not _position_allowed(at):
				_message("Rotation would move a piece outside the workspace's 500-metre limit.")
				_refresh_inspector()
				return
			changed.append({"item":selected_item, "position":at})
		for change in changed:
			change.item.rotation = wrapf(change.item.rotation+delta, -360, 360)
			change.item.position = _vector_array(change.position)
			_sync_object(change.item)
		_remember()


func _edit_scale(value: float) -> void:
	if refreshing: return
	var item := _current()
	if item.is_empty():
		placement_scale = value
		_update_preview()
	else:
		var ratio := value/float(item.scale)
		var pivot := _selection_center()
		var changed: Array[Dictionary] = []
		for selected_item in _selection_items():
			var at := pivot + (Vector3(selected_item.position[0], selected_item.position[1], selected_item.position[2])-pivot)*ratio
			var new_scale: float = selected_item.scale*ratio
			if not _position_allowed(at) or new_scale < 0.1 or new_scale > 10:
				_message("That scale would move a piece too far or exceed its supported size.")
				_refresh_inspector()
				return
			changed.append({"item":selected_item, "position":at, "scale":new_scale})
		for change in changed:
			change.item.scale = change.scale
			change.item.position = _vector_array(change.position)
			_sync_object(change.item)
		_remember()


func _rotate() -> void:
	if mode == "place":
		placement_rotation = fposmod(placement_rotation + 90, 360)
		_update_preview()
	else:
		var item := _current()
		if not item.is_empty():
			_edit_rotation(fposmod(item.rotation + 90, 360))
	_refresh_inspector()


func _duplicate_selected() -> void:
	var source := _selection_items()
	if source.is_empty():
		_message("Select one or more pieces to duplicate.")
		return
	if items.size()+source.size() > 5000:
		_message("The workspace supports up to 5,000 pieces.")
		return
	var delta := _limited_delta(Vector3(TILE, 0, TILE), source)
	var copies: Array[int] = []
	for original in source:
		var item := original.duplicate(true)
		item.id = next_id
		next_id += 1
		item.position = _vector_array(Vector3(item.position[0],item.position[1],item.position[2])+delta)
		items.append(item)
		_spawn(item)
		copies.append(int(item.id))
	folder_selected = false
	_set_selection(copies)
	_remember()
	_refresh()


func _delete_selected() -> void:
	if selected_ids.is_empty(): return
	for item in _selection_items():
		objects[int(item.id)].free()
		objects.erase(int(item.id))
		items.erase(item)
	selected_ids.clear()
	selected = -1
	folder_selected = false
	_remember()
	_refresh()


func _document(include_camera := false) -> Dictionary:
	var used_definitions := {}
	for item in items:
		if not used_definitions.has(item.kind):
			used_definitions[item.kind] = _piece_spec(item.kind)
	var document := {"format":FORMAT, "version":VERSION, "title":title_field.text, "notes":notes.text,
		"tile_size_m":TILE, "grid":{"width":grid_width, "depth":grid_depth}, "items":items.duplicate(true), "folders":folders.duplicate(true), "piece_definitions":used_definitions}
	if include_camera:
		document["camera"] = {"focus":[focus.x,focus.y,focus.z], "yaw":yaw, "pitch":pitch, "distance":distance, "projection":camera.projection}
	return document


func _vector_array(value: Vector3) -> Array:
	return [value.x, value.y, value.z]


func _piece_spec(kind: String) -> Dictionary:
	var definition: Dictionary = definitions[kind]
	var template := _template(kind)
	var bounds := _bounds(template)
	var spec := {"name":definition.name, "category":definition.category, "grid_snapped":definition.grid,
		"bounds":{"position":_vector_array(bounds.position), "size":_vector_array(bounds.size)}}
	if definition.has("size"):
		spec["shape"] = "box"
		spec["size"] = _vector_array(definition.size)
		spec["base_y"] = definition.get("base", 0.0)
	elif definition.has("assembly"):
		spec["parts"] = []
		for child in template.get_children():
			if child is MeshInstance3D and child.mesh is BoxMesh:
				spec.parts.append({"shape":"box", "size":_vector_array(child.mesh.size), "center":_vector_array(child.position)})
			elif child is Node3D and child.has_meta("piece_kind"):
				spec.parts.append({"kind":child.get_meta("piece_kind"), "position":_vector_array(child.position), "definition":_piece_spec(child.get_meta("piece_kind"))})
	else:
		spec["source_model"] = "game/art/props/%s/%s.glb" % [kind, kind]
		spec["normalized_height_m"] = definition.height
	return spec


func _content_key() -> String:
	return JSON.stringify(_document())


func _is_dirty() -> bool:
	return _content_key() != saved_content


func _refresh_dirty() -> void:
	if not count_label or not notes:
		return
	count_label.text = "%d pieces   ·   %d × %d tiles   ·   %.1f × %.1f metres   ·   %s" % [items.size(), grid_width, grid_depth, grid_width*TILE, grid_depth*TILE, "Unsaved changes" if _is_dirty() else "Saved"]
	DisplayServer.window_set_title("Map Workshop — %s%s" % [title_field.text, " *" if _is_dirty() else ""])
	if recovery_timer and not verification_mode:
		recovery_timer.start()


func _remember() -> void:
	if refreshing or not notes:
		return
	var document := _document()
	if history_index >= 0 and JSON.stringify(history[history_index]) == JSON.stringify(document):
		return
	history.resize(history_index + 1)
	history.append(document)
	if history.size() > 100:
		history.pop_front()
	history_index = history.size() - 1
	_refresh()


func _undo() -> void:
	_finish_gesture()
	_remember()
	if history_index <= 0:
		return
	history_index -= 1
	_apply_document(history[history_index])
	_message("Undid the last change.")


func _redo() -> void:
	if history_index >= history.size()-1:
		return
	history_index += 1
	_apply_document(history[history_index])
	_message("Restored the next change.")


func _apply_document(document: Dictionary) -> void:
	refreshing = true
	for object in objects.values():
		object.free()
	objects.clear()
	selected = -1
	selected_ids.clear()
	active_folder = 0
	folder_selected = false
	folders.clear()
	next_folder_id = 1
	for folder in document.get("folders", []):
		var loaded_folder: Dictionary = folder.duplicate(true)
		loaded_folder.id = int(loaded_folder.id)
		loaded_folder.parent = int(loaded_folder.parent)
		folders.append(loaded_folder)
		next_folder_id = maxi(next_folder_id, int(folder.id)+1)
	items.clear()
	for item in document.items:
		var loaded_item: Dictionary = item.duplicate(true)
		loaded_item.id = int(loaded_item.id)
		loaded_item.folder_id = int(loaded_item.get("folder_id",0))
		items.append(loaded_item)
	next_id = 1
	for item in items:
		next_id = maxi(next_id, int(item.id)+1)
		_spawn(item)
	title_field.text = document.title
	notes.text = document.notes
	grid_width = int(document.grid.width)
	grid_depth = int(document.grid.depth)
	_rebuild_grid()
	if document.has("camera"):
		var values: Dictionary = document.camera
		focus = Vector3(values.focus[0], values.focus[1], values.focus[2])
		yaw = values.yaw
		pitch = values.pitch
		distance = values.distance
		camera.projection = int(values.get("projection", Camera3D.PROJECTION_PERSPECTIVE))
		_update_camera()
	refreshing = false
	_refresh()


func _request_new() -> void:
	if _is_dirty():
		pending_new.popup_centered()
	else:
		_new_layout()


func _new_layout() -> void:
	_apply_document({"title":"Untitled layout", "notes":"", "grid":{"width":32,"depth":24}, "items":[]})
	history.clear()
	history_index = -1
	_remember()
	saved_content = _content_key()
	focus = Vector3.ZERO
	yaw = -0.55
	pitch = 0.85
	distance = 37
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	_update_camera()
	_set_mode("select")
	_message("New blank layout. Choose a piece to begin.")


func _slug(value: String) -> String:
	var result := ""
	for character in value.to_lower():
		if "abcdefghijklmnopqrstuvwxyz0123456789-_".contains(character):
			result += character
		elif character == " ":
			result += "-"
	return result.left(80) if not result.is_empty() else "layout"


func _write_json(path: String, document: Dictionary) -> Error:
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if not file:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(document, "\t") + "\n")
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return error
	return DirAccess.rename_absolute(temporary, path)


func _save_layout(name_value: String) -> Error:
	var path := "res://layouts/%s.json" % _slug(name_value)
	var error := _write_json(path, _document(true))
	if error == OK:
		saved_content = _content_key()
		_refresh_dirty()
		_message("Saved: " + ProjectSettings.globalize_path(path))
	else:
		_message("Could not save layout: " + error_string(error))
	return error


func _open_save() -> void:
	save_name.text = _slug(title_field.text)
	save_dialog.popup_centered(Vector2i(480, 140))
	save_name.grab_focus()
	save_name.select_all()


func _save_from_dialog() -> void:
	var name_value := _slug(save_name.text)
	if FileAccess.file_exists("res://layouts/%s.json" % name_value):
		var overwrite := ConfirmationDialog.new()
		overwrite.title = "Replace saved layout?"
		overwrite.dialog_text = "Replace %s.json with this layout?" % name_value
		overwrite.ok_button_text = "Replace"
		overwrite.confirmed.connect(func(): _save_layout(name_value); overwrite.queue_free())
		overwrite.canceled.connect(overwrite.queue_free)
		add_child(overwrite)
		overwrite.popup_centered()
	else:
		_save_layout(name_value)


func _open_load() -> void:
	load_list.clear()
	var directory := DirAccess.open("res://layouts")
	var filenames := directory.get_files()
	filenames.sort()
	for filename in filenames:
		if filename.ends_with(".json"):
			load_list.add_item(filename)
	if load_list.item_count > 0:
		load_list.select(0)
	load_dialog.dialog_text = "Opening another layout will discard unsaved changes." if _is_dirty() else ""
	load_dialog.popup_centered(Vector2i(500, 340))


func _load_from_dialog() -> void:
	var selection := load_list.get_selected_items()
	if selection.is_empty():
		_message("Choose a saved layout to open.")
		return
	_load_layout("res://layouts/" + load_list.get_item_text(selection[0]))


func _valid_number(value: Variant, minimum: float, maximum: float) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= minimum and value <= maximum


func _validate_document(value: Variant) -> String:
	if not value is Dictionary:
		return "The file must contain a layout object."
	if value.get("format") != FORMAT or value.get("version") != VERSION:
		return "Unsupported layout format or version."
	if value.get("tile_size_m") != TILE:
		return "Unsupported grid spacing."
	if not value.get("title") is String or not value.get("notes") is String:
		return "The title and notes must be text."
	if not value.get("grid") is Dictionary:
		return "Missing workspace dimensions."
	for dimension in ["width", "depth"]:
		var number = value.grid.get(dimension)
		if not _valid_number(number, 4, 128) or int(number) != number:
			return "Workspace dimensions must be whole numbers from 4 to 128."
	if not value.get("items") is Array or value.items.size() > 5000:
		return "The layout needs an item list with at most 5,000 pieces."
	if not value.get("folders", []) is Array or value.get("folders", []).size() > 5000:
		return "The folder list is invalid."
	var folder_ids := {0:true}
	var parents := {}
	for folder in value.get("folders", []):
		if not folder is Dictionary or not folder.get("name") is String or folder.name.strip_edges().is_empty():
			return "Each folder needs a name."
		if not _valid_number(folder.get("id"), 1, 10000000) or int(folder.id) != folder.id or folder_ids.has(int(folder.id)):
			return "Folder IDs must be unique positive whole numbers."
		if not _valid_number(folder.get("parent"), 0, 10000000) or int(folder.parent) != folder.parent:
			return "A folder has an invalid parent."
		folder_ids[int(folder.id)] = true
		parents[int(folder.id)] = int(folder.parent)
	for id in parents:
		var visited := {}
		var cursor: int = id
		while cursor != 0:
			if visited.has(cursor) or not parents.has(cursor):
				return "Folders must refer to existing parents and cannot form a cycle."
			visited[cursor] = true
			if visited.size() > 64:
				return "Folders can be nested up to 64 levels."
			cursor = parents[cursor]
	var ids := {}
	for item in value.items:
		if not item is Dictionary or not item.get("kind") is String or not definitions.has(item.kind):
			return "An item refers to an unknown piece."
		if not _valid_number(item.get("id"), 1, 10000000) or int(item.id) != item.id or ids.has(int(item.id)):
			return "Each piece needs a unique positive whole-number ID."
		ids[int(item.id)] = true
		var folder_id = item.get("folder_id", 0)
		if not _valid_number(folder_id, 0, 10000000) or int(folder_id) != folder_id or not folder_ids.has(int(folder_id)):
			return "A piece refers to an invalid folder."
		if not item.get("position") is Array or item.position.size() != 3:
			return "An item has an invalid position."
		for number in item.position:
			if not _valid_number(number, -500, 500):
				return "Item positions must be finite and within 500 metres of the origin."
		if not _valid_number(item.get("rotation"), -3600, 3600) or not _valid_number(item.get("scale"), 0.1, 10):
			return "An item has an invalid rotation or scale."
	if value.has("camera"):
		var values = value.camera
		if not values is Dictionary or not values.get("focus") is Array or values.focus.size() != 3:
			return "Invalid saved camera."
		for number in values.focus:
			if not _valid_number(number, -1000, 1000):
				return "Invalid camera focus."
		if not _valid_number(values.get("yaw"), -100000, 100000) or not _valid_number(values.get("pitch"), 0.12, PI/2.0) or not _valid_number(values.get("distance"), 3, 500):
			return "Invalid saved camera angle or zoom."
		var projection_value = values.get("projection", 0)
		if not _valid_number(projection_value, 0, 1) or int(projection_value) != projection_value:
			return "Invalid saved camera projection."
	return ""


func _load_layout(path: String) -> bool:
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		_message("Could not open layout: " + parser.get_error_message())
		return false
	var problem := _validate_document(parser.data)
	if not problem.is_empty():
		_message("Could not open layout: " + problem)
		return false
	_apply_document(parser.data)
	history.clear()
	history_index = -1
	_remember()
	saved_content = _content_key()
	_set_mode("select")
	_message("Opened: " + path.get_file())
	return true


func _export_handoff() -> void:
	var folder := "res://exports/%s-%s" % [_slug(title_field.text), Time.get_datetime_string_from_system().replace(":", "-")]
	var suffix := 2
	var base := folder
	while DirAccess.dir_exists_absolute(folder):
		folder = base + "-%d" % suffix
		suffix += 1
	var error := DirAccess.make_dir_recursive_absolute(folder)
	if error != OK:
		_message("Could not create handoff folder: " + error_string(error))
		return
	error = _write_json(folder + "/layout.json", _document(true))
	if error != OK:
		_message("Could not export layout: " + error_string(error))
		return
	var brief := "# %s\n\nThis is Bryson's visual level-design intent, made in the isolated Map Workshop.\nUse it as a basis for iteration; it does not define or implement gameplay rules.\n\n## Bryson's notes\n\n%s\n\n## Dimensions and coordinates\n\n- Workspace: %d × %d tiles, %.1f × %.1f metres.\n- Grid spacing: %.1f metres. X and Z are the ground plane; Y is elevation.\n- Grid lines stay on multiples of the tile spacing. Even dimensions center on zero; odd dimensions add a tile on the positive side. Positive Z is south, negative Z is north.\n- Rotation is Godot's Y-axis rotation in degrees; scale is a uniform multiplier.\n- Walls and floors use the grid; props may be freely positioned.\n- Prefabs stay grouped; piece_definitions in layout.json records their geometry.\n- Model sizes here are visual approximations. Map Workshop uses plain lighting and\n  copied models; the game may have different shaders, mounting and placement rules.\n- layout.json contains every position, rotation and scale. overview.png captures\n  the chosen camera view. top-down.png gives a plan view.\n- Implement and validate gameplay separately in the game's current map format.\n\n## Placement list\n\n| ID | Piece | Folder | X | Y | Z | Rotation | Scale |\n|---|---|---|---:|---:|---:|---:|---:|\n" % [title_field.text, notes.text if not notes.text.is_empty() else "No notes supplied.", grid_width, grid_depth, grid_width*TILE, grid_depth*TILE, TILE]
	for item in items:
		brief += "| %d | %s | %s | %.2f | %.2f | %.2f | %.1f° | %.2f |\n" % [int(item.id), definitions[item.kind].name, _folder_path(int(item.get("folder_id",0))).replace("|", "\\|"), item.position[0], item.position[1], item.position[2], item.rotation, item.scale]
	var file := FileAccess.open(folder + "/HANDOFF.md", FileAccess.WRITE)
	if not file:
		_message("Could not write handoff brief.")
		return
	file.store_string(brief)
	file.close()
	var previous_preview := preview.visible if preview else false
	var previous_outline := selection_outline.visible
	if preview: preview.visible = false
	selection_outline.visible = false
	await RenderingServer.frame_post_draw
	error = viewport.get_texture().get_image().save_png(ProjectSettings.globalize_path(folder + "/overview.png"))
	var old_focus := focus
	var old_yaw := yaw
	var old_pitch := pitch
	var old_distance := distance
	var old_projection := camera.projection
	_frame_layout()
	_top_view()
	if preview: preview.visible = false
	await RenderingServer.frame_post_draw
	var top_error := viewport.get_texture().get_image().save_png(ProjectSettings.globalize_path(folder + "/top-down.png"))
	focus = old_focus
	yaw = old_yaw
	pitch = old_pitch
	distance = old_distance
	camera.projection = old_projection
	_update_camera()
	if preview: preview.visible = previous_preview
	selection_outline.visible = previous_outline
	if error != OK or top_error != OK:
		_message("Layout and brief exported, but a screenshot could not be saved.")
	else:
		_message("Handoff exported: " + ProjectSettings.globalize_path(folder))


func _message(value: String) -> void:
	if status:
		status.text = value


func _exit_tree() -> void:
	for template in templates.values():
		template.free()


func _verify() -> void:
	await get_tree().process_frame
	var verifier = load("res://verification/verify.gd").new()
	add_child(verifier)
	await verifier.run(self)


func _capture_demo() -> void:
	_load_layout("res://layouts/example-courtyard.json")
	await _export_handoff()
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://verification/workshop-preview.png"))
	print("WORKSHOP_CAPTURE_SAVED")
	get_tree().quit()
