class_name Hud
extends CanvasLayer

signal action_chosen(id: String)
signal action_hovered(id: String)
signal menu_cancelled
signal network_toggled(shown: bool)
signal scan_toggled(shown: bool)
signal operator_chosen(id: int)

const ENEMY_COLOR := Color(0.91, 0.48, 0.36)
const LOG_LINES := 5
const MENU_OFFSET := Vector2(40, 0)
const SCREEN_MARGIN := 12.0
const CHIP_LOADED := Color(0.45, 0.93, 0.68)
const CHIP_DEGRADED := Color(1.0, 0.8, 0.35)
const CHIP_UNLOADED := Color(0.55, 0.62, 0.64)

@onready var _round: Label = %RoundLabel
@onready var _order: HBoxContainer = %Order
@onready var _objective: Label = %ObjectiveLabel
@onready var _caution: Label = %CautionLabel
@onready var _active_panel: Control = %ActivePanel
@onready var _active_name: Label = %ActiveName
@onready var _active_stats: Label = %ActiveStats
@onready var _context_ring: ContextRing = %ContextRing
@onready var _context_label: Label = %ContextLabel
@onready var _chips: HBoxContainer = %Chips
@onready var _action_menu: Control = %ActionMenu
@onready var _action_list: VBoxContainer = %ActionList
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
var _inspect_text: Label
var _card: Dictionary
var _controls_text: String
# The team member the panel shows: the active unit, or a teammate the player clicked.
var _viewed: Unit


func _ready() -> void:
	_network_toggle.toggled.connect(network_toggled.emit)
	_scan_toggle.toggled.connect(scan_toggled.emit)
	_controls_text = %Controls.text
	_restart.pressed.connect(SceneRouter.restart_battle)
	%ChangeLoadout.pressed.connect(SceneRouter.goto_loadout)
	_quit.pressed.connect(SceneRouter.goto_title)
	_build_inspect()
	_build_card()


# The menu has to close before the pause menu sees Esc, so this runs in _input.
func _input(event: InputEvent) -> void:
	if _action_menu.visible and (event.is_action_pressed("ui_cancel") or event.is_action_released("cancel")):
		get_viewport().set_input_as_handled()
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
	# AP refills when a turn starts, so a waiting teammate shows what they'll start with.
	var turn := "YOUR TURN" if acting else "WAITING  ·  AP AT TURN START"
	var ap := unit.ap if acting else (unit.def.ap if unit.is_robot() else unit.base_ap)
	var ai_ap := unit.ai_ap if acting else (0 if unit.rebooting > 0 else BattleState.AI_AP + unit.incoming)
	_active_name.text = unit.display_name
	if unit.is_robot():
		_phase_label.text = "ROBOT  ·  " + turn
		var stun := "        STUN  ready" if unit.stun_charges > 0 else ("        STUN  used" if unit.def.stun_charges > 0 else "")
		_active_stats.text = "AP  %s  %d/%d%s" % [_pips(ap, unit.def.ap), ap, unit.def.ap, stun]
		%ContextRow.visible = false
		_show_chips(state, null)
		return
	_phase_label.text = (unit.role.get_slice(":", 0).to_upper() if unit.role != "" else "OPERATOR") + "  ·  " + turn
	var shot := "ready"
	if unit.overwatch:
		shot = "overwatch"
	elif unit.sprinted:
		shot = "given up"
	elif unit.shot_used:
		shot = "used"
	var gear := ""
	if unit.robot_def:
		var deployed := unit.robot >= 0 and not state.units[unit.robot].down
		gear = "%s  %s" % [unit.robot_def.display_name.to_upper(), "out" if deployed else "lost" if unit.robot >= 0 else "ready"]
	elif unit.flashbangs > 0:
		gear = "FLASHBANG  ×%d" % unit.flashbangs
	var ai := "backpack"
	if unit.connected():
		ai = unit.ai_node.to_upper() + ("  via relay" if unit.relay >= 0 else "")
	elif unit.rebooting > 0:
		ai = "rebooting"
	_active_stats.text = "AP  %s  %d/%d        AI AP  %s  %d%s\nARMOR  %s        SHOT  %s        AI  %s%s" % [
		_pips(ap, unit.base_ap), ap, unit.base_ap,
		_pips(ai_ap, maxi(ai_ap, BattleState.AI_AP)), ai_ap, "  incl. +%d shared" % unit.incoming if unit.incoming > 0 and not acting else "",
		"■".repeat(unit.max_hits - unit.hits) + "□".repeat(unit.hits), shot, ai, "        " + gear if gear != "" else ""]
	%ContextRow.visible = true
	_context_ring.fill = float(unit.context) / BattleState.CONTEXT_MAX
	_context_label.text = "CONTEXT   %dM / %dM" % [unit.context, BattleState.CONTEXT_MAX]
	_context_label.tooltip_text = "Context used: %d million of %d million tokens. Hacks, chips and verbs fill it; Compact frees space but degrades loaded chips." % [unit.context, BattleState.CONTEXT_MAX]
	_show_chips(state, unit)


func _pips(left: int, total: int) -> String:
	return "●".repeat(maxi(left, 0)) + "○".repeat(maxi(total - left, 0))


# The AI's chips: loaded, degraded or not loaded yet. Clicking one shows what it does.
func _show_chips(state: BattleState, unit: Unit) -> void:
	for child in _chips.get_children():
		_chips.remove_child(child)
		child.queue_free()
	if unit == null:
		return
	for id in unit.chips:
		var chip := state.chip_def(id)
		var level: int = unit.chips[id]
		var button := Button.new()
		var pending := "  ▶" if unit.next_hack.has(id) else ""
		button.text = chip.display_name.to_upper() + pending
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 16)
		button.add_theme_color_override("font_color", [CHIP_UNLOADED, CHIP_DEGRADED, CHIP_LOADED][level])
		button.tooltip_text = _chip_text(chip, level)
		button.pressed.connect(_inspect_chip.bind(chip, level))
		_chips.add_child(button)


func _chip_text(chip: ChipDef, level: int) -> String:
	var kind: String = ["Movement, free", "Passive", "Active, 1 AP a use"][chip.type]
	var state: String = ["Not loaded: using it loads it", "Degraded", "Loaded"][level]
	return "%s\n%s   /   load %dM context\n%s\n\nEffect: %s\nDegraded: %s\n\nEach compaction degrades a loaded chip one step, then unloads it." % [
		chip.display_name.to_upper(), kind, chip.load_cost, state, chip.effect, chip.degraded_effect]


func _inspect_chip(chip: ChipDef, level: int) -> void:
	_inspect_text.text = _chip_text(chip, level)
	_inspect.show()


func _build_inspect() -> void:
	_inspect = PanelContainer.new()
	_inspect.visible = false
	_inspect.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_inspect.position = Vector2(get_viewport().get_visible_rect().size.x - 520, 300)
	_inspect.custom_minimum_size = Vector2(480, 0)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 18)
	var rows := VBoxContainer.new()
	var kicker := Label.new()
	kicker.text = "CHIP / INSPECT"
	kicker.theme_type_variation = &"Kicker"
	_inspect_text = Label.new()
	_inspect_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_inspect_text.custom_minimum_size.x = 440
	_inspect_text.add_theme_font_size_override("font_size", 19)
	var close := Button.new()
	close.text = "CLOSE"
	close.pressed.connect(_inspect.hide)
	rows.add_child(kicker)
	rows.add_child(_inspect_text)
	rows.add_child(close)
	margin.add_child(rows)
	_inspect.add_child(margin)
	$Root.add_child(_inspect)


# actions: dictionaries with "id", "text" and optionally "enabled" and "tip". The menu opens beside
# the given screen point.
func open_menu(at: Vector2, actions: Array, title := "AVAILABLE ACTIONS") -> void:
	for child in _action_list.get_children():
		_action_list.remove_child(child)
		child.queue_free()
	%ActionTitle.text = title
	var first: Button = null
	for action in actions:
		var button := Button.new()
		button.text = action["text"]
		button.custom_minimum_size.y = 36
		button.add_theme_font_size_override("font_size", 19)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.disabled = not action.get("enabled", true)
		button.tooltip_text = action.get("tip", "")
		button.pressed.connect(_choose.bind(action["id"]))
		button.mouse_entered.connect(action_hovered.emit.bind(action["id"]))
		button.focus_entered.connect(action_hovered.emit.bind(action["id"]))
		_action_list.add_child(button)
		if first == null and not button.disabled:
			first = button
	_action_menu.show()
	_action_menu.reset_size()
	var limit := get_viewport().get_visible_rect().size - _action_menu.size - Vector2.ONE * SCREEN_MARGIN
	var corner := at + MENU_OFFSET - Vector2(0, _action_menu.size.y / 2.0)
	_action_menu.position = corner.clamp(Vector2.ONE * SCREEN_MARGIN, limit)
	if first:
		first.grab_focus()


func set_objective(text: String) -> void:
	_objective.text = text


# What the player is being asked to do, in the footer; empty shows the controls again.
func set_hint(text: String) -> void:
	%Controls.text = text if text != "" else _controls_text
	%Controls.add_theme_color_override("font_color", Color(1.0, 0.86, 0.6) if text != "" else Color(0.65, 0.74, 0.74))


func close_menu() -> void:
	_action_menu.hide()
	action_hovered.emit("")


func is_menu_open() -> bool:
	return _action_menu.visible


func set_network_shown(shown: bool) -> void:
	_network_toggle.set_pressed_no_signal(shown)
	_network_toggle.text = "PHYSICAL   [N]" if shown else "NETWORK   [N]"
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
