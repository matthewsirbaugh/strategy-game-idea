extends Control

const Catalog = preload("res://catalog.gd")
const Stage = preload("res://stage.gd")
const INK := Color("e7edf4")
const MUTED := Color("96a5b6")
const ACCENT := Color("86dcc5")
var catalog := Catalog.new()
var stage: Stage
var config := ConfigFile.new()
var root_path := ""
var selected: Dictionary = {}
var tree: Tree
var tabs: TabBar
var search: LineEdit
var sort_order: OptionButton
var status_filter: OptionButton
var footer: Label
var headline: Label
var subtitle: Label
var overlay: Label
var details: VBoxContainer
var inspector: PanelContainer
var inspector_toggle: Button
var animation_select: OptionButton
var animation_play: Button
var animation_slider: HSlider
var animation_time: Label
var animation_row: HBoxContainer
var issues_button: Button
var dialog: FileDialog
var capture_dialog: FileDialog
var issue_dialog: AcceptDialog
var details_scroll: ScrollContainer
var playing := false
var loading_model := false
var updating_tree := false
var expanded_folders: Dictionary = {}
var stats: Dictionary = {}
var animation_names: PackedStringArray = []

func _ready() -> void:
	Engine.max_fps = 60
	DisplayServer.window_set_title("Model Library")
	config.load("user://preferences.cfg")
	root_path = str(config.get_value("library", "root", ""))
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--assets="):
			root_path = arg.trim_prefix("--assets=")
	if root_path.is_empty():
		var local := ProjectSettings.globalize_path("res://../../assets").simplify_path()
		if DirAccess.dir_exists_absolute(local):
			root_path = local
		elif FileAccess.file_exists(OS.get_executable_path().get_base_dir().path_join("../Resources/library_path.txt")):
			root_path = FileAccess.get_file_as_string(OS.get_executable_path().get_base_dir().path_join("../Resources/library_path.txt")).strip_edges()
	_apply_theme()
	_build_ui()
	_refresh()
	if root_path.is_empty():
		_choose_folder()
	get_window().close_requested.connect(_save)
	await get_tree().process_frame
	DisplayServer.window_set_title("Model Library")

func _apply_theme() -> void:
	var theme := Theme.new()
	theme.default_font_size = 14
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["SF Pro Text", "Helvetica Neue", "Arial"])
	theme.default_font = font
	for type in ["Label", "Button", "LineEdit", "OptionButton", "Tree", "TabBar", "CheckButton"]:
		theme.set_color("font_color", type, INK)
		theme.set_color("font_hover_color", type, Color.WHITE)
		theme.set_color("font_focus_color", type, INK)
		theme.set_color("font_pressed_color", type, ACCENT)
		theme.set_color("font_disabled_color", type, MUTED)
	for type in ["Button", "OptionButton", "LineEdit"]:
		theme.set_stylebox("normal", type, _box(Color("27313e"), 7))
		theme.set_stylebox("hover", type, _box(Color("354354"), 7))
		theme.set_stylebox("pressed", type, _box(Color("315047"), 7))
		theme.set_stylebox("focus", type, _box(Color(0, 0, 0, 0), 7, ACCENT))
		theme.set_stylebox("disabled", type, _box(Color("222b36"), 7))
	theme.set_stylebox("panel", "Tree", _box(Color("19222d"), 0))
	theme.set_stylebox("selected", "Tree", _box(Color("2a4945"), 5))
	theme.set_stylebox("selected_focus", "Tree", _box(Color("2a4945"), 5))
	theme.set_color("font_selected_color", "Tree", Color("d9fff3"))
	theme.set_color("guide_color", "Tree", Color("354151"))
	theme.set_constant("v_separation", "Tree", 12)
	theme.set_constant("h_separation", "Tree", 10)
	theme.set_constant("indent", "Tree", 16)
	theme.set_stylebox("tab_selected", "TabBar", _box(Color("2a4945"), 6))
	theme.set_stylebox("tab_unselected", "TabBar", _box(Color("222d39"), 6))
	theme.set_color("font_selected_color", "TabBar", ACCENT)
	theme.set_color("font_unselected_color", "TabBar", MUTED)
	theme.set_constant("h_separation", "HBoxContainer", 10)
	theme.set_constant("separation", "VBoxContainer", 10)
	self.theme = theme

func _box(color: Color, corner := 0, border := Color.TRANSPARENT) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(corner)
	box.content_margin_left = 12
	box.content_margin_right = 12
	box.content_margin_top = 9
	box.content_margin_bottom = 9
	if border.a > 0:
		box.border_color = border
		box.set_border_width_all(1)
	return box

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color("121b25")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	var outer := VBoxContainer.new()
	outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer.add_theme_constant_override("separation", 0)
	add_child(outer)
	var header_panel := _panel(outer, Color("17212c"))
	var header := HBoxContainer.new()
	header_panel.add_child(header)
	var title := _label(header, "◈  Model Library", 21, INK)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button(header, "Open library…", _choose_folder, "Choose the project's assets folder")
	issues_button = _button(header, "Issues", _show_issues)
	_button(header, "Refresh", _refresh, "Find new and updated models · ⌘R")
	var split := HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.split_offset = int(config.get_value("ui", "sidebar_width", 312))
	split.dragged.connect(func(offset: int): config.set_value("ui", "sidebar_width", offset))
	outer.add_child(split)
	var sidebar := _panel(split, Color("19222d"))
	sidebar.custom_minimum_size.x = 260
	var side := VBoxContainer.new()
	sidebar.add_child(side)
	tabs = TabBar.new()
	tabs.add_tab("Folders")
	tabs.add_tab("All models")
	tabs.current_tab = int(config.get_value("ui", "view", 0))
	tabs.tab_changed.connect(func(index: int): config.set_value("ui", "view", index); _populate())
	side.add_child(tabs)
	search = LineEdit.new()
	search.placeholder_text = "Search models…"
	search.clear_button_enabled = true
	search.text_changed.connect(func(_value: String): _populate())
	side.add_child(search)
	sort_order = _option(side, ["Newest added", "Oldest added", "Name A–Z", "Name Z–A", "Folder", "Recently updated"], func(_index: int): _populate())
	sort_order.select(int(config.get_value("ui", "sort", 0)))
	status_filter = _option(side, ["All statuses", "Proof", "Approved", "Rejected", "Legacy"], func(_index: int): _populate())
	tree = Tree.new()
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree.hide_root = true
	tree.select_mode = Tree.SELECT_ROW
	tree.item_selected.connect(_tree_selected)
	tree.item_collapsed.connect(func(item: TreeItem):
		var metadata: Variant = item.get_metadata(0)
		if metadata is String: expanded_folders[metadata] = not item.collapsed)
	side.add_child(tree)
	footer = _label(side, "", 12, MUTED)
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.add_child(right)
	right.add_theme_constant_override("separation", 0)
	var heading_panel := _panel(right, Color("1c2733"))
	var heading := HBoxContainer.new()
	heading_panel.add_child(heading)
	var names := VBoxContainer.new()
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(names)
	headline = _label(names, "Choose a model", 22, INK)
	headline.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	subtitle = _label(names, "Your library, in one place.", 12, MUTED)
	inspector_toggle = _button(heading, "Details", func(): inspector.visible = not inspector.visible; config.set_value("ui", "details", inspector.visible))
	inspector_toggle.toggle_mode = true
	inspector_toggle.button_pressed = bool(config.get_value("ui", "details", true))
	var tools_panel := _panel(right, Color("1c2733"))
	var tools := HBoxContainer.new()
	tools_panel.add_child(tools)
	_button(tools, "Frame", func(): stage.frame_model(), "Center and fit the model · F / double-click")
	_option(tools, ["Studio", "Bright", "Contrast"], func(index: int): stage.set_lighting(index))
	_option(tools, ["Materials", "Clay", "Albedo", "Normals", "Wireframe"], func(index: int): stage.set_mode(index))
	var views := MenuButton.new()
	views.text = "View"
	views.get_popup().add_item("Front", 0)
	views.get_popup().add_item("Back", 1)
	views.get_popup().add_item("Right", 2)
	views.get_popup().add_item("Left", 3)
	views.get_popup().add_item("Top", 4)
	views.get_popup().add_item("Bottom", 5)
	views.get_popup().add_separator()
	views.get_popup().add_check_item("Orthographic", 6)
	views.get_popup().add_check_item("Turntable", 7)
	views.get_popup().add_check_item("Ground grid", 8)
	views.get_popup().set_item_checked(8, true)
	views.get_popup().id_pressed.connect(func(id: int):
		if id < 6: stage.preset(id)
		else:
			var checked := not views.get_popup().is_item_checked(id)
			views.get_popup().set_item_checked(id, checked)
			if id == 6: stage.orthographic = checked; stage._update_camera()
			if id == 7: stage.turntable = checked; stage.redraw()
			if id == 8: stage.floor_mesh.visible = checked; stage.redraw())
	tools.add_child(views)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tools.add_child(spacer)
	_button(tools, "Capture…", _capture, "Save a clean PNG of the model")
	var view_split := HSplitContainer.new()
	view_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	view_split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_child(view_split)
	var stage_wrap := Control.new()
	stage_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_wrap.custom_minimum_size = Vector2(380, 300)
	view_split.add_child(stage_wrap)
	stage = Stage.new()
	stage.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage_wrap.add_child(stage)
	stage.model_ready.connect(_model_ready)
	stage.load_failed.connect(_load_failed)
	stage.loading.connect(func(message: String): overlay.text = message; overlay.show())
	stage.animation_ready.connect(_animations_ready)
	overlay = Label.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	overlay.grow_horizontal = Control.GROW_DIRECTION_BOTH
	overlay.grow_vertical = Control.GROW_DIRECTION_BOTH
	overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay.add_theme_font_size_override("font_size", 18)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_wrap.add_child(overlay)
	inspector = _panel(view_split, Color("19222d"))
	inspector.custom_minimum_size.x = 260
	inspector.visible = inspector_toggle.button_pressed
	details_scroll = ScrollContainer.new()
	details_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inspector.add_child(details_scroll)
	details = VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details_scroll.add_child(details)
	_label(details, "MODEL DETAILS", 12, ACCENT)
	_paragraph(details, "Select a model to inspect its geometry, materials and asset record.")
	var bottom_panel := _panel(right, Color("17212c"))
	var bottom := VBoxContainer.new()
	bottom_panel.add_child(bottom)
	animation_row = HBoxContainer.new()
	bottom.add_child(animation_row)
	_label(animation_row, "Animation", 12, MUTED)
	animation_select = _option(animation_row, ["Still"], _animation_selected)
	animation_play = _button(animation_row, "Play", _toggle_play)
	animation_slider = HSlider.new()
	animation_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	animation_slider.step = 0.001
	animation_slider.value_changed.connect(_scrub)
	animation_row.add_child(animation_slider)
	animation_time = _label(animation_row, "0.00 s", 12, MUTED)
	animation_row.hide()
	_label(bottom, "Left-drag  Pan    ·    Right-drag / Option-drag  Orbit    ·    Scroll / pinch  Zoom    ·    F  Frame", 12, MUTED)
	dialog = FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.use_native_dialog = true
	dialog.title = "Choose the assets folder"
	dialog.dir_selected.connect(func(path: String): root_path = path; selected = {}; _refresh(); _save())
	add_child(dialog)
	capture_dialog = FileDialog.new()
	capture_dialog.access = FileDialog.ACCESS_FILESYSTEM
	capture_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	capture_dialog.use_native_dialog = true
	capture_dialog.filters = PackedStringArray(["*.png ; PNG image"])
	capture_dialog.file_selected.connect(_save_capture)
	add_child(capture_dialog)
	issue_dialog = AcceptDialog.new()
	issue_dialog.title = "Library issues"
	issue_dialog.min_size = Vector2i(720, 350)
	add_child(issue_dialog)

func _panel(parent: Node, color: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _box(color))
	parent.add_child(panel)
	return panel

func _label(parent: Node, value: String, font_size := 14, color := INK) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _button(parent: Node, value: String, callback: Callable, hint := "") -> Button:
	var button := Button.new()
	button.text = value
	button.tooltip_text = hint
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _option(parent: Node, values: Array, callback: Callable) -> OptionButton:
	var option := OptionButton.new()
	for value in values: option.add_item(value)
	option.item_selected.connect(callback)
	parent.add_child(option)
	return option

func _paragraph(parent: Node, value: String, color := MUTED) -> Label:
	var label := _label(parent, value, 13, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = 220
	return label

func _choose_folder() -> void:
	dialog.current_dir = root_path if DirAccess.dir_exists_absolute(root_path) else OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	dialog.popup_centered_ratio(0.75)

func _refresh() -> void:
	stage.invalidate_cache()
	catalog.scan(root_path)
	issues_button.text = "Issues (%d)" % catalog.issues.size()
	issues_button.visible = not catalog.issues.is_empty()
	var previous_id: String = selected.get("id", str(config.get_value("library", "selected", "")))
	var found := false
	for asset in catalog.assets:
		if asset.id == previous_id:
			selected = asset
			found = true
			break
	if not found:
		selected = {}
	_populate()
	if not selected.is_empty():
		_select(selected)
	elif not catalog.assets.is_empty():
		_select(_filtered()[0] if not _filtered().is_empty() else catalog.assets[0])
	else:
		overlay.text = "No models yet\nAdd an asset record, then click Refresh."
		overlay.show()
		headline.text = "Library is empty"
		subtitle.text = root_path
	_save()

func _filtered() -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var query := search.text.strip_edges().to_lower()
	var filter := status_filter.get_item_text(status_filter.selected).to_lower()
	for asset in catalog.assets:
		if status_filter.selected > 0 and asset.status != filter: continue
		if not query.is_empty() and not (str(asset.name) + " " + str(asset.id) + " " + str(asset._folder) + " " + str(asset.category)).to_lower().contains(query): continue
		results.append(asset)
	results.sort_custom(func(a: Dictionary, b: Dictionary):
		match sort_order.selected:
			0: if a._added != b._added: return a._added > b._added
			1: if a._added != b._added: return a._added < b._added
			3: return str(a.name).naturalnocasecmp_to(str(b.name)) > 0
			4: if a._folder != b._folder: return str(a._folder).naturalnocasecmp_to(str(b._folder)) < 0
			5: if a._modified != b._modified: return a._modified > b._modified
		return str(a.name).naturalnocasecmp_to(str(b.name)) < 0)
	return results

func _populate() -> void:
	if tree == null: return
	updating_tree = true
	tree.clear()
	var root := tree.create_item()
	var results := _filtered()
	var folder_items := {"": root}
	if tabs.current_tab == 0:
		var visible_folders := PackedStringArray()
		if search.text.is_empty() and status_filter.selected == 0:
			visible_folders = catalog.folders
		else:
			for asset in results:
				var pieces: PackedStringArray = str(asset._folder).split("/")
				var path := ""
				for piece in pieces:
					path = path.path_join(piece) if not path.is_empty() else piece
					if not visible_folders.has(path): visible_folders.append(path)
			visible_folders.sort()
		for folder in visible_folders:
			var parent_path := str(folder).get_base_dir()
			if parent_path == ".": parent_path = ""
			var item := tree.create_item(folder_items.get(parent_path, root))
			item.set_text(0, "▱  " + str(folder).get_file())
			item.set_custom_color(0, MUTED)
			item.set_metadata(0, folder)
			item.set_selectable(0, false)
			item.collapsed = not bool(expanded_folders.get(folder, str(folder).get_slice_count("/") <= 2 or not search.text.is_empty()))
			folder_items[folder] = item
	for asset in results:
		var parent: TreeItem = folder_items.get(asset._folder, root) if tabs.current_tab == 0 else root
		var item := tree.create_item(parent)
		item.set_text(0, asset.name)
		item.set_metadata(0, asset)
		item.set_tooltip_text(0, "%s\n%s · %s\nAdded %s" % [asset._folder, asset.category, asset.status, _date(asset._added)])
		if asset.id == selected.get("id", ""):
			item.select(0)
			var ancestor := item.get_parent()
			while ancestor != null and ancestor != root:
				ancestor.collapsed = false
				ancestor = ancestor.get_parent()
	footer.text = "%d of %d models\n%s" % [results.size(), catalog.assets.size(), "assets/" if root_path.get_file() == "assets" else root_path.get_file()]
	footer.tooltip_text = root_path
	sort_order.visible = tabs.current_tab == 1
	config.set_value("ui", "sort", sort_order.selected)
	updating_tree = false

func _tree_selected() -> void:
	if updating_tree: return
	var item := tree.get_selected()
	if item != null and item.get_metadata(0) is Dictionary:
		_select.call_deferred(item.get_metadata(0))

func _select(asset: Dictionary) -> void:
	selected = asset
	config.set_value("library", "selected", asset.id)
	headline.text = asset.name
	subtitle.text = "%s  ·  %s" % [asset._folder, str(asset.status).capitalize()]
	headline.tooltip_text = asset.description
	loading_model = true
	animation_row.hide()
	stage.request_model(asset)
	_populate()
	_save()

func _model_ready(info: Dictionary) -> void:
	loading_model = false
	stats = info
	overlay.hide()
	_build_details()
	animation_row.visible = not selected.animations.is_empty() or animation_names.size() > 0
	animation_select.clear()
	animation_select.add_item("Still")
	animation_select.set_item_metadata(0, "")
	for filename in selected.animations:
		animation_select.add_item(str(filename).get_basename().capitalize())
		animation_select.set_item_metadata(animation_select.item_count - 1, "file:" + str(filename))
	animation_play.text = "Play"
	animation_slider.set_value_no_signal(0)
	playing = false

func _animations_ready(names: PackedStringArray) -> void:
	animation_names = names
	if loading_model: return
	for animation_name in names:
		if animation_name == "RESET" or animation_name.begins_with("run/") or animation_name.begins_with("walk/"): continue
		var exists := false
		for i in animation_select.item_count:
			if animation_select.get_item_metadata(i) == "embedded:" + animation_name: exists = true
		if not exists:
			animation_select.add_item(animation_name)
			animation_select.set_item_metadata(animation_select.item_count - 1, "embedded:" + animation_name)
	animation_row.visible = animation_select.item_count > 1
	overlay.hide()
	playing = stage.player != null and stage.player.is_playing()
	animation_play.text = "Pause" if playing else "Play"

func _load_failed(message: String) -> void:
	loading_model = false
	overlay.text = message
	overlay.show()

func _build_details() -> void:
	for child in details.get_children(): child.queue_free()
	_label(details, "ASSET", 12, ACCENT)
	_paragraph(details, selected.description, INK)
	var rows := {
		"Status": str(selected.status).capitalize(), "Category": str(selected.category).capitalize(),
		"Added": _date(selected._added), "Updated": _date(selected._modified),
		"File": selected.model, "Size": String.humanize_size(stats.bytes),
		"Triangles": _number(stats.triangles), "Vertices": _number(stats.vertices),
		"Meshes / surfaces": "%d / %d" % [stats.meshes, stats.surfaces],
	}
	for label in rows: _detail_row(label, str(rows[label]))
	var box: AABB = stats.bounds
	_label(details, "DIMENSIONS", 12, ACCENT)
	_detail_row("Width", "%.3f m" % box.size.x)
	_detail_row("Height", "%.3f m" % box.size.y)
	_detail_row("Depth", "%.3f m" % box.size.z)
	_detail_row("Record height", "%.3f m" % selected.height_m)
	if selected.fit_to_height: _paragraph(details, "Legacy model fitted to the recorded height.")
	elif absf(box.size.y - float(selected.height_m)) > maxf(0.01, float(selected.height_m) * 0.02):
		_paragraph(details, "Measured height differs from the record.", Color("efc58b"))
	_label(details, "MATERIALS · %d" % stats.materials.size(), 12, ACCENT)
	for material in stats.materials:
		_paragraph(details, material.name, INK)
		_paragraph(details, "\n".join(material.maps) if not material.maps.is_empty() else "No texture maps")
	if selected.made_with != null:
		_label(details, "PROVENANCE", 12, ACCENT)
		for key in selected.made_with:
			_detail_row(str(key).capitalize(), str(selected.made_with[key]))
	if not str(selected.notes).is_empty():
		_label(details, "NOTES", 12, ACCENT)
		_paragraph(details, selected.notes)
	_button(details, "Reveal model in Finder", func(): OS.shell_show_in_file_manager(selected._path))
	_button(details, "Open asset record", func(): OS.shell_open(selected._record))

func _detail_row(key: String, value: String) -> void:
	var row := HBoxContainer.new()
	details.add_child(row)
	var label := _label(row, key, 12, MUTED)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var content := _label(row, value, 12, INK)
	content.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	content.custom_minimum_size.x = 100
	content.tooltip_text = value

func _date(timestamp: int) -> String:
	var local_timestamp := timestamp + int(Time.get_time_zone_from_system().bias) * 60
	return Time.get_datetime_string_from_unix_time(local_timestamp).replace("T", " ").left(16)

func _number(value: int) -> String:
	var output := str(value)
	var position := output.length() - 3
	while position > 0:
		output = output.insert(position, ",")
		position -= 3
	return output

func _animation_selected(index: int) -> void:
	var metadata := str(animation_select.get_item_metadata(index))
	if index == 0:
		stage.request_clip("")
		playing = false
	elif metadata.begins_with("file:"):
		stage.request_clip(metadata.trim_prefix("file:"))
		playing = true
	elif metadata.begins_with("embedded:") and stage.player != null:
		var clip: String = metadata.trim_prefix("embedded:")
		stage.player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
		stage.player.play(clip)
		playing = true
	animation_play.text = "Pause" if playing else "Play"

func _toggle_play() -> void:
	if stage.player == null or animation_select.selected == 0: return
	if stage.player.is_playing():
		stage.player.pause()
		playing = false
	else:
		stage.player.play()
		playing = true
	animation_play.text = "Pause" if playing else "Play"
	stage.redraw()

func _scrub(value: float) -> void:
	if stage.player == null or stage.player.current_animation.is_empty(): return
	stage.player.pause()
	stage.player.seek(value, true)
	stage.redraw()
	playing = false
	animation_play.text = "Play"

func _process(_delta: float) -> void:
	if stage == null or stage.player == null or stage.player.current_animation.is_empty(): return
	animation_slider.max_value = stage.player.current_animation_length
	if not animation_slider.has_focus() or playing:
		animation_slider.set_value_no_signal(stage.player.current_animation_position)
	animation_time.text = "%.2f / %.2f s" % [stage.player.current_animation_position, stage.player.current_animation_length]

func _show_issues() -> void:
	issue_dialog.dialog_text = "The rest of the library remains available.\n\n" + "\n\n".join(catalog.issues)
	issue_dialog.popup_centered(Vector2i(780, 460))

func _capture() -> void:
	capture_dialog.current_file = str(selected.get("id", "model")) + ".png"
	capture_dialog.popup_centered_ratio(0.7)

func _save_capture(path: String) -> void:
	stage.redraw()
	await RenderingServer.frame_post_draw
	var error: int = stage.viewport.get_texture().get_image().save_png(path)
	if error != OK:
		_load_failed("Could not save capture (error %d)." % error)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if event.keycode == KEY_R and (event.meta_pressed or event.ctrl_pressed): _refresh(); accept_event()
	elif event.keycode == KEY_F and not get_viewport().gui_get_focus_owner() is LineEdit: stage.frame_model(); accept_event()
	elif event.keycode == KEY_SPACE and not get_viewport().gui_get_focus_owner() is LineEdit: _toggle_play(); accept_event()
	elif event.keycode == KEY_ESCAPE: search.release_focus()

func _save() -> void:
	config.set_value("library", "root", root_path)
	config.save("user://preferences.cfg")

func _exit_tree() -> void:
	_save()
