class_name Hud
extends CanvasLayer

signal action_chosen(id: String)
signal action_hovered(id: String)
signal menu_cancelled
signal network_toggled(shown: bool)
signal scan_toggled(shown: bool)
signal operator_chosen(id: int)

const ENEMY_COLOR := Color(0.91, 0.48, 0.36)
const TEXT := Color(0.91, 0.92, 0.86)
const MUTED := Color(0.6, 0.68, 0.68)
const LOG_LINES := 5
const MENU_OFFSET := Vector2(40, 0)
const SCREEN_MARGIN := 12.0
# Each phase's menus are edged in the color of the AP they spend.
const OPERATOR_ACCENT := Color(0.98, 0.7, 0.47)
const AI_ACCENT := Color(0.4, 0.87, 0.9)
# A tag's kind sets its color: the same resource reads the same everywhere.
const TAG_COLORS := {
	"ap": Color(0.98, 0.77, 0.55),
	"ai": Color(0.4, 0.87, 0.9),
	"context": Color(0.5, 0.69, 1.0),
	"good": Color(0.45, 0.93, 0.68),
	"warn": Color(1.0, 0.8, 0.35),
	"info": Color(0.8, 0.86, 0.83),
	"free": Color(0.58, 0.66, 0.66),
	"key": Color(0.58, 0.66, 0.66),
}
const CHIP_LEVELS: Array[String] = ["free", "warn", "good"]
const CHIP_STATES: Array[String] = ["Not loaded", "Degraded", "Loaded"]
# Space between a row's name and its tags, and between the tags and the row's edge.
const TAG_GAP := 18.0
const ROW_PADDING := 10
const ROW_STATES: Array[String] = ["normal", "hover", "pressed", "hover_pressed", "focus", "disabled"]

@onready var _round: Label = %RoundLabel
@onready var _order: HBoxContainer = %Order
@onready var _objective: Label = %ObjectiveLabel
@onready var _caution: Label = %CautionLabel
@onready var _active_panel: Control = %ActivePanel
@onready var _active_name: Label = %ActiveName
@onready var _active_stats: GridContainer = %ActiveStats
@onready var _context_ring: ContextRing = %ContextRing
@onready var _context_label: Label = %ContextLabel
@onready var _chips: HBoxContainer = %Chips
@onready var _action_menu: PanelContainer = %ActionMenu
@onready var _action_list: VBoxContainer = %ActionList
@onready var _footer_list: VBoxContainer = %FooterList
@onready var _menu_note: Label = %MenuNote
@onready var _network_toggle: Button = %NetworkToggle
@onready var _scan_toggle: Button = %ScanToggle
@onready var _log: VBoxContainer = %Log
@onready var _result: Control = %Result
@onready var _result_label: Label = %ResultLabel
@onready var _restart: Button = %Restart
@onready var _quit: Button = %QuitToTitle
@onready var _phase_label: Label = %PhaseLabel
@onready var _initial: Label = %Initial
@onready var _badge: PanelContainer = %Badge
var _inspect: PanelContainer
var _banner: PanelContainer
var _banner_title: Label
var _banner_detail: Label
var _inspect_parts := {}
var _card: Dictionary
var _controls_text: String
# The team member the panel shows: the active unit, or a teammate the player clicked.
var _viewed: Unit
# The way back out of the open submenu, which Esc and right-click take.
var _cancel_id := ""
var _stats := {}
var _styles := {}


func _ready() -> void:
	_network_toggle.toggled.connect(network_toggled.emit)
	_scan_toggle.toggled.connect(scan_toggled.emit)
	_controls_text = %Controls.text
	_restart.pressed.connect(SceneRouter.restart_battle)
	%ChangeLoadout.pressed.connect(SceneRouter.goto_loadout)
	_quit.pressed.connect(SceneRouter.goto_title)
	_build_stats()
	_build_inspect()
	_build_card()
	_build_banner()


# The menu has to close before the pause menu sees Esc, so this runs in _input. In a submenu, Esc
# and right-click go back a step instead.
func _input(event: InputEvent) -> void:
	if _action_menu.visible and (event.is_action_pressed("ui_cancel") or event.is_action_released("cancel")):
		get_viewport().set_input_as_handled()
		if _cancel_id != "":
			_choose(_cancel_id)
			return
		close_menu()
		menu_cancelled.emit()
	elif _inspect.visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_inspect.hide()


func show_turn(state: BattleState) -> void:
	_round.text = "ROUND %02d   /   TURN ORDER" % state.round_number
	for chip in _order.get_children():
		_order.remove_child(chip)
		chip.queue_free()
	var tied := state.tied_operators()
	for unit in state.upcoming():
		_order.add_child(_turn_chip(unit, unit == state.active, tied.has(unit)))
	var zones: Array[String] = []
	for zone in state.caution:
		zones.append("%s %d" % [zone if zone != "" else "Map", state.caution[zone]])
	_caution.visible = not zones.is_empty()
	_caution.text = "CAUTION   " + "   /   ".join(zones)
	var active := state.active
	_active_panel.visible = active != null and state.is_player_controlled(active)
	if _active_panel.visible:
		if _viewed == null or _viewed.down or not _viewed.on_map() or not state.is_player_controlled(_viewed):
			_viewed = active
		_show_unit(state, _viewed)
	set_hint("")


# Shows a teammate's resources without giving them the turn. null goes back to the active unit.
func view_unit(state: BattleState, unit: Unit) -> void:
	_viewed = unit
	show_turn(state)


func viewed() -> Unit:
	return _viewed


# --- The unit panel ------------------------------------------------------------------------------

# One cell per resource or state, a small name over its value, laid out three to a row.
func _build_stats() -> void:
	for id in ["ap", "ai_ap", "armor", "shot", "ai", "gear"]:
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", -3)
		var title := Label.new()
		title.theme_type_variation = &"Kicker"
		title.add_theme_font_size_override("font_size", 14)
		var value := Label.new()
		value.add_theme_font_size_override("font_size", 20)
		cell.add_child(title)
		cell.add_child(value)
		_active_stats.add_child(cell)
		_stats[id] = [cell, title, value]


func _stat(id: String, title: String, value: String, color: Color) -> void:
	var parts: Array = _stats[id]
	parts[0].visible = true
	parts[1].text = title
	parts[2].text = value
	parts[2].add_theme_color_override("font_color", color)


func _show_unit(state: BattleState, unit: Unit) -> void:
	var accent := unit.def.color.lightened(0.2)
	var acting := unit == state.active
	_initial.text = unit.display_name.left(1)
	_initial.add_theme_color_override("font_color", accent)
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color(accent, 0.12 if acting else 0.05)
	badge_style.border_color = accent if acting else Color(accent, 0.5)
	badge_style.set_border_width_all(1)
	badge_style.border_width_bottom = 3 if acting else 1
	_badge.add_theme_stylebox_override("panel", badge_style)
	# AP refills when a turn starts, so a waiting teammate shows what they'll start their next turn with.
	var turn := "YOUR TURN" if acting else "WAITING"
	var ap_title := "AP REMAINING" if acting else "AP NEXT TURN"
	var ap := unit.ap if acting else (unit.def.ap if unit.is_robot() else unit.base_ap)
	_active_name.text = unit.display_name
	for id in _stats:
		_stats[id][0].visible = false
	if unit.is_robot():
		_phase_label.text = "ROBOT  ·  " + turn
		_stat("ap", ap_title, "%s  %d/%d" % [_pips(ap, unit.def.ap), ap, unit.def.ap], TAG_COLORS.ap)
		if unit.def.stun_charges > 0:
			_stat("shot", "STUN", "READY" if unit.stun_charges > 0 else "USED", TAG_COLORS.good if unit.stun_charges > 0 else MUTED)
		%ContextRow.visible = false
		_show_chips(state, null)
		return
	_phase_label.text = (unit.role.get_slice(":", 0).to_upper() if unit.role != "" else "OPERATOR") + "  ·  " + turn
	var ai_ap := unit.ai_ap if acting else (0 if unit.rebooting > 0 else BattleState.AI_AP + unit.incoming)
	_stat("ap", ap_title, "%s  %d/%d" % [_pips(ap, unit.base_ap), ap, unit.base_ap], TAG_COLORS.ap)
	var shared := "  ·  +%d SHARED" % unit.incoming if unit.incoming > 0 and not acting else ""
	_stat("ai_ap", "AI " + ap_title + shared, "%s  %d" % [_pips(ai_ap, maxi(ai_ap, BattleState.AI_AP)), ai_ap], TAG_COLORS.ai)
	_stat("armor", "ARMOR", "■".repeat(unit.max_hits - unit.hits) + "□".repeat(unit.hits), TEXT)
	if unit.overwatch:
		_stat("shot", "SHOT", "OVERWATCH", TAG_COLORS.warn)
	elif unit.sprinted or unit.shot_used:
		_stat("shot", "SHOT", "GIVEN UP" if unit.sprinted else "USED", MUTED)
	else:
		_stat("shot", "SHOT", "READY", TAG_COLORS.good)
	if unit.connected():
		_stat("ai", "AI", "ON " + unit.ai_node.to_upper() + ("  VIA RELAY" if unit.relay >= 0 else ""), TAG_COLORS.ai)
	elif unit.rebooting > 0:
		_stat("ai", "AI", "REBOOTING", TAG_COLORS.warn)
	else:
		_stat("ai", "AI", "BACKPACK", MUTED)
	if unit.robot_def:
		var deployed := unit.robot >= 0 and not state.units[unit.robot].down
		var status := "OUT" if deployed else "LOST" if unit.robot >= 0 else "READY"
		_stat("gear", unit.robot_def.display_name.to_upper(), status, TAG_COLORS.good if status == "READY" else MUTED if status == "LOST" else TEXT)
	elif unit.flashbangs > 0:
		_stat("gear", "FLASHBANGS", "×%d" % unit.flashbangs, TEXT)
	%ContextRow.visible = true
	_context_ring.fill = float(unit.context) / BattleState.CONTEXT_MAX
	_context_label.text = "CONTEXT   %dM / %dM" % [unit.context, BattleState.CONTEXT_MAX]
	_context_label.tooltip_text = "Context used: %d million of %d million tokens. Hacks, chips and verbs fill it; Compact frees space but degrades loaded chips." % [unit.context, BattleState.CONTEXT_MAX]
	_show_chips(state, unit)


func _pips(left: int, total: int) -> String:
	return "●".repeat(maxi(left, 0)) + "○".repeat(maxi(total - left, 0))


# The AI's chips as tags, loaded, degraded or not loaded yet. Clicking one shows what it does.
func _show_chips(state: BattleState, unit: Unit) -> void:
	for child in _chips.get_children():
		_chips.remove_child(child)
		child.queue_free()
	if unit == null:
		return
	for id in unit.chips:
		var chip := state.chip_def(id)
		var level: int = unit.chips[id]
		var color: Color = TAG_COLORS[CHIP_LEVELS[level]]
		var button := Button.new()
		button.text = chip.display_name.to_upper() + ("  ▸ READY" if unit.next_hack.has(id) else "")
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 15)
		for font_state in ["font_color", "font_hover_color", "font_pressed_color"]:
			button.add_theme_color_override(font_state, color.lightened(0.15) if font_state != "font_color" else color)
		for style_state in ["normal", "hover", "pressed", "hover_pressed"]:
			button.add_theme_stylebox_override(style_state, _chip_style(color, style_state != "normal"))
		button.tooltip_text = "%s: %s. Click for details." % [chip.display_name, CHIP_STATES[level].to_lower()]
		button.pressed.connect(_inspect_chip.bind(chip, level))
		_chips.add_child(button)


func _chip_style(color: Color, hot: bool) -> StyleBoxFlat:
	var key := "chip %s %s" % [color, hot]
	if not _styles.has(key):
		var style := StyleBoxFlat.new()
		style.bg_color = Color(color, 0.16 if hot else 0.07)
		style.border_color = Color(color, 0.8 if hot else 0.45)
		style.set_border_width_all(1)
		style.set_corner_radius_all(2)
		style.content_margin_left = 9
		style.content_margin_right = 9
		style.content_margin_top = 3
		style.content_margin_bottom = 3
		_styles[key] = style
	return _styles[key]


# A card like the hover card: what kind of chip, its state, what it does, and what it costs.
func _build_inspect() -> void:
	_inspect = PanelContainer.new()
	_inspect.visible = false
	_inspect.custom_minimum_size = Vector2(460, 0)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 16)
	margin.add_theme_constant_override("margin_left", 18)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 10)
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	var names := VBoxContainer.new()
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	names.add_theme_constant_override("separation", -2)
	var kicker := Label.new()
	kicker.theme_type_variation = &"Kicker"
	var title := Label.new()
	title.add_theme_font_size_override("font_size", 30)
	names.add_child(kicker)
	names.add_child(title)
	var state := HBoxContainer.new()
	header.add_child(names)
	header.add_child(state)
	# Wrapping text needs its width up front, or it measures one word a line and the card grows tall.
	var effect := Label.new()
	effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect.custom_minimum_size.x = 424
	effect.add_theme_font_size_override("font_size", 19)
	var degraded := Label.new()
	degraded.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	degraded.custom_minimum_size.x = 424
	degraded.add_theme_font_size_override("font_size", 17)
	degraded.add_theme_color_override("font_color", MUTED)
	var costs := HBoxContainer.new()
	costs.add_theme_constant_override("separation", 6)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	var note := Label.new()
	note.theme_type_variation = &"Kicker"
	note.add_theme_font_size_override("font_size", 14)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size.x = 320
	note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var close := Button.new()
	close.text = "Close"
	close.theme_type_variation = &"MenuBack"
	for style_state in ROW_STATES:
		close.add_theme_stylebox_override(style_state, _row_style(MUTED, style_state))
	close.pressed.connect(_inspect.hide)
	footer.add_child(note)
	footer.add_child(close)
	for part in [header, effect, degraded, costs, HSeparator.new(), footer]:
		rows.add_child(part)
	margin.add_child(rows)
	_inspect.add_child(margin)
	$Root.add_child(_inspect)
	_inspect_parts = {"kicker": kicker, "title": title, "state": state, "effect": effect, "degraded": degraded, "costs": costs, "note": note}


func _inspect_chip(chip: ChipDef, level: int) -> void:
	var color: Color = TAG_COLORS[CHIP_LEVELS[level]]
	var style: StyleBoxFlat = _accented_panel(color)
	_inspect.add_theme_stylebox_override("panel", style)
	_inspect_parts.kicker.text = ["MOVEMENT", "PASSIVE", "ACTIVE"][chip.type] + "  ·  CHIP"
	_inspect_parts.title.text = chip.display_name
	_inspect_parts.effect.text = chip.effect
	_inspect_parts.degraded.text = "Degraded:  " + chip.degraded_effect
	_set_tags(_inspect_parts.state, [[CHIP_STATES[level], CHIP_LEVELS[level]]])
	var costs := [["Load +%dM" % chip.load_cost, "context"]]
	costs.append(["1 AI AP a use", "ai"] if chip.type == ChipDef.Type.ACTIVE else ["Free once loaded", "free"])
	_set_tags(_inspect_parts.costs, costs)
	_inspect_parts.note.text = "UNLOADS ONLY IF A COMPACTION TAKES CONTEXT BELOW ITS COST" if chip.type == ChipDef.Type.MOVEMENT \
		else "EACH COMPACTION DEGRADES A LOADED CHIP A STEP, THEN UNLOADS IT"
	_inspect.show()
	_place_inspect.call_deferred()


# Once its text has wrapped: against the right edge, centered top to bottom.
func _place_inspect() -> void:
	_inspect.reset_size()
	var screen := get_viewport().get_visible_rect().size
	_inspect.position = Vector2(screen.x - _inspect.size.x - 40, (screen.y - _inspect.size.y) / 2.0)


# --- The action menu -----------------------------------------------------------------------------

# actions: BattleMenus' dictionaries. header: "kicker", "accent" (a Color), and "costs", tags for
# what the unit has to spend. The menu opens beside the given screen point.
func open_menu(at: Vector2, actions: Array, header := {}) -> void:
	for list in [_action_list, _footer_list]:
		for child in list.get_children():
			list.remove_child(child)
			child.queue_free()
	var accent: Color = header.get("accent", OPERATOR_ACCENT)
	_action_menu.add_theme_stylebox_override("panel", _accented_panel(accent))
	%ActionTitle.text = header.get("kicker", "")
	_set_tags(%Budget, header.get("costs", []))
	_cancel_id = ""
	var first: Button = null
	var tips: Array[String] = []
	for action in actions:
		var style: String = action.get("style", "")
		var row := _menu_row(action, accent)
		(_footer_list if style in ["back", "end"] else _action_list).add_child(row)
		if row is Button:
			_fit_row(row)
			if first == null and not row.disabled:
				first = row
		if action.get("cancel", false):
			_cancel_id = action.id
		tips.append(action.get("tip", ""))
	%FooterLine.visible = _action_list.get_child_count() > 0 and _footer_list.get_child_count() > 0
	_fit_note(tips)
	_action_menu.show()
	_action_menu.reset_size()
	var limit := get_viewport().get_visible_rect().size - _action_menu.size - Vector2.ONE * SCREEN_MARGIN
	var corner := at + MENU_OFFSET - Vector2(0, _action_menu.size.y / 2.0)
	_action_menu.position = corner.clamp(Vector2.ONE * SCREEN_MARGIN, limit)
	if first:
		first.grab_focus()


# A row is its name, with its tags and, for a submenu, a chevron set against the right edge. The
# highlight follows the mouse by taking focus, so only one row is ever lit.
func _menu_row(action: Dictionary, accent: Color) -> Control:
	var style: String = action.get("style", "")
	if style == "note":
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 14)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_top", 6)
		margin.add_theme_constant_override("margin_bottom", 6)
		var note := Label.new()
		note.text = action.text
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		note.custom_minimum_size.x = _action_list.custom_minimum_size.x - 26.0
		note.add_theme_color_override("font_color", MUTED)
		note.add_theme_font_size_override("font_size", 18)
		margin.add_child(note)
		return margin
	var row := Button.new()
	row.text = action.text
	row.alignment = HORIZONTAL_ALIGNMENT_LEFT
	row.theme_type_variation = &"MenuBack" if style == "back" else &"MenuRow"
	row.disabled = not action.get("enabled", true)
	for state_name in ROW_STATES:
		row.add_theme_stylebox_override(state_name, _row_style(accent, state_name))
	var tags := HBoxContainer.new()
	tags.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tags.add_theme_constant_override("separation", 5)
	tags.alignment = BoxContainer.ALIGNMENT_END
	_set_tags(tags, action.get("costs", []))
	if action.get("submenu", false):
		var chevron := Label.new()
		chevron.text = "›"
		chevron.add_theme_font_size_override("font_size", 26)
		chevron.add_theme_color_override("font_color", MUTED)
		chevron.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tags.add_child(chevron)
	if row.disabled:
		tags.modulate.a = 0.45
	row.add_child(tags)
	row.pressed.connect(_choose.bind(action.id))
	row.mouse_entered.connect(row.grab_focus)
	row.focus_entered.connect(_on_row_focused.bind(action.id, action.get("tip", "")))
	return row


# Pins a row's tags to its right edge and widens the row so they never overlap its name.
func _fit_row(row: Button) -> void:
	var tags: Control = row.get_child(0)
	tags.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT, Control.PRESET_MODE_MINSIZE, ROW_PADDING)
	row.custom_minimum_size.x = row.get_minimum_size().x + tags.get_combined_minimum_size().x + TAG_GAP


# The note under the menu says what the highlighted row does. It's sized for the longest tip, so
# the menu doesn't jump as the highlight moves.
func _fit_note(tips: Array[String]) -> void:
	var width := maxf(_action_list.get_combined_minimum_size().x, _footer_list.get_combined_minimum_size().x) - 26.0
	var font := _menu_note.get_theme_font("font")
	var size := _menu_note.get_theme_font_size("font_size")
	var tallest := 0.0
	for tip in tips:
		if tip != "":
			var lines := ceilf(font.get_multiline_string_size(tip, HORIZONTAL_ALIGNMENT_LEFT, width, size).y / font.get_height(size))
			tallest = maxf(tallest, lines * (font.get_height(size) + 3.0))
	_menu_note.text = ""
	_menu_note.custom_minimum_size = Vector2(width, tallest)
	%NoteLine.visible = tallest > 0.0
	_menu_note.get_parent().visible = tallest > 0.0


func _on_row_focused(id: String, tip: String) -> void:
	_menu_note.text = tip
	action_hovered.emit(id)


func _row_style(accent: Color, state_name: String) -> StyleBoxFlat:
	var key := "row %s %s" % [accent, state_name]
	if not _styles.has(key):
		var style := StyleBoxFlat.new()
		style.content_margin_left = 14
		style.content_margin_right = 12
		style.content_margin_top = 6
		style.content_margin_bottom = 6
		style.border_width_left = 3
		style.set_corner_radius_all(2)
		match state_name:
			"focus":
				style.bg_color = Color(accent, 0.13)
				style.border_color = accent
			"pressed", "hover_pressed":
				style.bg_color = Color(accent, 0.3)
				style.border_color = accent
			_:
				style.bg_color = Color(accent, 0.0)
				style.border_color = Color(accent, 0.0)
		_styles[key] = style
	return _styles[key]


# The theme's panel, edged on the left in an accent color, as the hover card is.
func _accented_panel(accent: Color) -> StyleBoxFlat:
	var key := "panel %s" % accent
	if not _styles.has(key):
		var style: StyleBoxFlat = ThemeDB.get_project_theme().get_stylebox("panel", "PanelContainer").duplicate()
		style.border_width_left = 3
		style.border_color = accent
		_styles[key] = style
	return _styles[key]


# Fills a container with tags: [text, kind] pairs.
func _set_tags(box: Container, tags: Array) -> void:
	for child in box.get_children():
		box.remove_child(child)
		child.queue_free()
	for tag in tags:
		box.add_child(_tag(tag[0], tag[1]))


func _tag(text: String, kind: String) -> PanelContainer:
	var color: Color = TAG_COLORS.get(kind, TAG_COLORS.info)
	var key := "tag " + kind
	if not _styles.has(key):
		var style := StyleBoxFlat.new()
		style.bg_color = Color(color, 0.0 if kind in ["free", "key"] else 0.1)
		style.border_color = Color(color, 0.55)
		style.set_border_width_all(1)
		if kind == "key":
			style.border_width_bottom = 2
		style.set_corner_radius_all(2)
		style.content_margin_left = 6
		style.content_margin_right = 6
		style.content_margin_top = 0
		style.content_margin_bottom = 0
		_styles[key] = style
	var tag := PanelContainer.new()
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tag.add_theme_stylebox_override("panel", _styles[key])
	var label := Label.new()
	label.text = text.to_upper()
	label.theme_type_variation = &"ChipLabel"
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag.add_child(label)
	return tag


func set_objective(text: String) -> void:
	_objective.text = text


# What the player is being asked to do, in the footer; empty shows the controls again.
func set_hint(text: String) -> void:
	%Controls.text = text if text != "" else _controls_text
	%Controls.add_theme_color_override("font_color", Color(1.0, 0.86, 0.6) if text != "" else Color(0.65, 0.74, 0.74))


# A notice under the header for something the player has to know before acting here, such as an
# AI still in its backpack while the network is in view. An empty title hides it.
func set_banner(title: String, detail := "") -> void:
	_banner.visible = title != ""
	_banner_title.text = title
	_banner_detail.text = detail
	_banner_detail.visible = detail != ""


func _build_banner() -> void:
	_banner = PanelContainer.new()
	_banner.add_theme_stylebox_override("panel", _accented_panel(AI_ACCENT))
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE)
	_banner.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_banner.position.y = 132.0
	var margin := MarginContainer.new()
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 22)
	for side in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 2)
	_banner_title = Label.new()
	_banner_title.add_theme_font_size_override("font_size", 24)
	_banner_title.add_theme_color_override("font_color", AI_ACCENT)
	_banner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_detail = Label.new()
	_banner_detail.add_theme_font_size_override("font_size", 18)
	_banner_detail.add_theme_color_override("font_color", TEXT)
	_banner_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rows.add_child(_banner_title)
	rows.add_child(_banner_detail)
	margin.add_child(rows)
	_banner.add_child(margin)
	_banner.visible = false
	$Root.add_child(_banner)


func close_menu() -> void:
	_action_menu.hide()
	_cancel_id = ""
	action_hovered.emit("")


func is_menu_open() -> bool:
	return _action_menu.visible


func set_network_shown(shown: bool) -> void:
	_network_toggle.set_pressed_no_signal(shown)
	_network_toggle.text = "OPERATOR   [N]" if shown else "AI   [N]"
	%NetworkLegend.visible = shown


func set_scan_shown(shown: bool) -> void:
	_scan_toggle.set_pressed_no_signal(shown)


# card: what HoverInfo.card returns, or empty to hide the panel.
func set_hover(card: Dictionary) -> void:
	%HoverPanel.visible = not card.is_empty()
	if card.is_empty():
		return
	var accent: Color = card.color
	var small: bool = card.get("small", false)
	var style: StyleBoxFlat = %HoverPanel.get_theme_stylebox("panel").duplicate()
	style.border_width_left = 4
	style.border_color = Color(accent, 0.9)
	%HoverPanel.add_theme_stylebox_override("panel", style)
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color(accent, 0.12)
	badge_style.border_color = Color(accent, 0.8)
	badge_style.set_border_width_all(1)
	badge_style.set_corner_radius_all(2)
	_card.badge.add_theme_stylebox_override("panel", badge_style)
	_card.badge.visible = not small
	_card.icon.visible = card.has("icon")
	_card.initial.visible = not card.has("icon")
	if card.has("icon"):
		_card.icon.texture = card.icon
		_card.icon.modulate = accent
	else:
		_card.initial.text = card.get("initial", "")
		_card.initial.add_theme_color_override("font_color", accent)
	_card.kicker.text = card.kicker
	_card.kicker.add_theme_color_override("font_color", accent.lerp(Color.WHITE, 0.15) if not small else Color(0.65, 0.74, 0.74))
	_card.title.text = card.title
	_card.title.add_theme_font_size_override("font_size", 22 if small else 28)
	for child in _card.lines.get_children():
		_card.lines.remove_child(child)
		child.queue_free()
	for line in card.lines:
		var label := Label.new()
		label.text = line.text
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_color_override("font_color", line.color)
		label.add_theme_font_size_override("font_size", 19)
		_card.lines.add_child(label)
	_card.lines.visible = not card.lines.is_empty()
	_card.breach.visible = card.has("progress")
	if card.has("progress"):
		_card.bar.max_value = card.progress.y
		_card.bar.value = card.progress.x
		_card.breach_label.text = "BREACH   %d / %d" % [card.progress.x, card.progress.y]
	_card.footer.text = card.get("footer", "")
	_card.footer_row.visible = _card.footer.text != ""
	# Waits a frame for the removed lines to leave, or the panel keeps its old height.
	%HoverPanel.reset_size.call_deferred()


func _build_card() -> void:
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 14)
	margin.add_theme_constant_override("margin_left", 16)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 10)
	rows.custom_minimum_size.x = 360
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 14)
	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(54, 54)
	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(40, 40)
	var initial := Label.new()
	initial.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initial.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	initial.add_theme_font_size_override("font_size", 30)
	badge.add_child(icon)
	badge.add_child(initial)
	var names := VBoxContainer.new()
	names.add_theme_constant_override("separation", -2)
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	names.alignment = BoxContainer.ALIGNMENT_CENTER
	var kicker := Label.new()
	kicker.theme_type_variation = &"Kicker"
	var title := Label.new()
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	names.add_child(kicker)
	names.add_child(title)
	header.add_child(badge)
	header.add_child(names)
	var lines := VBoxContainer.new()
	lines.add_theme_constant_override("separation", 3)
	var breach := VBoxContainer.new()
	breach.add_theme_constant_override("separation", 4)
	var breach_label := Label.new()
	breach_label.theme_type_variation = &"Kicker"
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size.y = 8
	breach.add_child(breach_label)
	breach.add_child(bar)
	var footer_row := VBoxContainer.new()
	footer_row.add_theme_constant_override("separation", 6)
	footer_row.add_child(HSeparator.new())
	var footer := Label.new()
	footer.theme_type_variation = &"Kicker"
	footer.add_theme_font_size_override("font_size", 15)
	footer_row.add_child(footer)
	for part in [header, lines, breach, footer_row]:
		rows.add_child(part)
	margin.add_child(rows)
	%HoverPanel.add_child(margin)
	for control in [margin, rows, header, badge, icon, initial, names, kicker, title, lines, breach, breach_label, bar, footer_row, footer]:
		control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_card = {"badge": badge, "icon": icon, "initial": initial, "kicker": kicker, "title": title, "lines": lines,
		"breach": breach, "breach_label": breach_label, "bar": bar, "footer_row": footer_row, "footer": footer}


func log_line(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = 406
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 18)
	_log.add_child(label)
	%LogPanel.show()
	while _log.get_child_count() > LOG_LINES:
		var oldest := _log.get_child(0)
		_log.remove_child(oldest)
		oldest.queue_free()
	for i in _log.get_child_count():
		_log.get_child(i).modulate = Color(0.91, 0.94, 0.89, 0.5 + 0.5 * float(i + 1) / _log.get_child_count())


func show_result(won: bool) -> void:
	_active_panel.hide()
	close_menu()
	_result_label.text = "EXTRACTION COMPLETE" if won else "TEAM LOST"
	_restart.text = "PLAY AGAIN" if won else "RESTART THE PHASE"
	_result.show()
	_restart.grab_focus()


func show_errors(errors: PackedStringArray) -> void:
	_active_panel.hide()
	_result_label.text = "This battle's content is broken"
	var details := Label.new()
	details.text = "\n".join(errors)
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.custom_minimum_size.x = 900
	details.add_theme_font_size_override("font_size", 18)
	_result_label.add_sibling(details)
	_restart.hide()
	_result.show()
	_quit.grab_focus()


func _choose(id: String) -> void:
	close_menu()
	action_chosen.emit(id)


# A tied Operator's chip is a button: the player picks who acts next.
func _turn_chip(unit: Unit, is_active: bool, choosable: bool) -> Control:
	var style := StyleBoxFlat.new()
	var accent := unit.def.color.lightened(0.2) if unit.is_player() else ENEMY_COLOR
	style.bg_color = Color(accent, 0.2 if is_active else 0.06)
	style.border_width_bottom = 3 if is_active or choosable else 1
	style.border_color = accent if is_active else Color(accent, 0.75 if choosable else 0.4)
	style.set_corner_radius_all(2)
	style.set_content_margin_all(7)
	var text := unit.display_name.to_upper().replace("GUARD ", "G")
	if unit.is_robot():
		text = unit.def.display_name.to_upper()
	if choosable:
		var button := Button.new()
		button.text = text
		button.focus_mode = Control.FOCUS_NONE
		button.tooltip_text = "%s shares this speed: click to act with them first" % unit.display_name
		for state_name in ["normal", "hover", "pressed"]:
			button.add_theme_stylebox_override(state_name, style)
		button.add_theme_font_size_override("font_size", 17)
		button.pressed.connect(operator_chosen.emit.bind(unit.id))
		return button
	var chip := PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_STOP
	chip.tooltip_text = unit.display_name + (" / active" if is_active else " / upcoming")
	chip.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", accent if is_active else Color(0.67, 0.74, 0.74))
	label.add_theme_font_size_override("font_size", 17)
	chip.add_child(label)
	return chip
