class_name Hud
extends CanvasLayer

signal action_chosen(id: String)
signal actions_requested
signal menu_cancelled
signal network_toggled(shown: bool)

const ENEMY_COLOR := Color(0.91, 0.48, 0.36)
const LOG_LINES := 4
const MENU_OFFSET := Vector2(40, 0)
const SCREEN_MARGIN := 12.0

@onready var _round: Label = %RoundLabel
@onready var _order: HBoxContainer = %Order
@onready var _hover: Label = %HoverLabel
@onready var _objective: Label = %ObjectiveLabel
@onready var _active_panel: Control = %ActivePanel
@onready var _active_name: Label = %ActiveName
@onready var _active_stats: Label = %ActiveStats
@onready var _context_ring: ContextRing = %ContextRing
@onready var _context_label: Label = %ContextLabel
@onready var _hint: Label = %Hint
@onready var _action_menu: Control = %ActionMenu
@onready var _action_list: VBoxContainer = %ActionList
@onready var _network_toggle: Button = %NetworkToggle
@onready var _log: VBoxContainer = %Log
@onready var _result: Control = %Result
@onready var _result_label: Label = %ResultLabel
@onready var _restart: Button = %Restart
@onready var _quit: Button = %QuitToTitle
@onready var _phase_label: Label = %PhaseLabel
@onready var _initial: Label = %Initial
@onready var _badge: PanelContainer = %Badge
@onready var _health: ProgressBar = %Health


func _ready() -> void:
	_network_toggle.toggled.connect(network_toggled.emit)
	%ActionsButton.pressed.connect(actions_requested.emit)
	_restart.pressed.connect(SceneRouter.goto_battle)
	_quit.pressed.connect(SceneRouter.goto_title)


# The menu has to close before the pause menu sees Esc, so this runs in _input.
func _input(event: InputEvent) -> void:
	if _action_menu.visible and (event.is_action_pressed("ui_cancel") or event.is_action_released("cancel")):
		get_viewport().set_input_as_handled()
		close_menu()
		menu_cancelled.emit()


func show_turn(state: BattleState) -> void:
	_round.text = "ROUND %02d   /   TURN ORDER" % state.round_number
	for chip in _order.get_children():
		_order.remove_child(chip)
		chip.queue_free()
	for unit in state.upcoming():
		_order.add_child(_chip(unit, unit == state.active))
	var active := state.active
	_active_panel.visible = active != null and active.is_player()
	if _active_panel.visible:
		show_active(state)


func show_active(state: BattleState) -> void:
	var unit := state.active
	var accent := unit.def.color.lightened(0.2)
	_phase_label.text = "OPERATOR / YOUR TURN" if state.phase == BattleState.Phase.HUMAN else "ARTIFICIAL INTELLIGENCE / YOUR TURN"
	_initial.text = unit.display_name.left(1)
	_initial.add_theme_color_override("font_color", accent)
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color(accent, 0.12)
	badge_style.border_color = accent
	badge_style.set_border_width_all(1)
	badge_style.border_width_bottom = 3
	_badge.add_theme_stylebox_override("panel", badge_style)
	_health.max_value = unit.def.max_hp
	_health.value = unit.hp
	_health.visible = state.phase == BattleState.Phase.HUMAN
	_context_ring.fill = float(unit.context) / BattleState.CONTEXT_MAX
	var skills := "  /  MOVEMENT LOADED" if unit.skills.has(BattleState.NETWORK_SKILL) else ""
	_context_label.text = "CONTEXT   %dM / %dM%s" % [unit.context, BattleState.CONTEXT_MAX, skills]
	_context_label.tooltip_text = "Context used: %d million of %d million tokens. Hacking and loading skills fill it; Compact frees space." % [unit.context, BattleState.CONTEXT_MAX]
	if state.phase == BattleState.Phase.HUMAN or unit.agent_node == "":
		_active_name.text = unit.display_name
		_active_stats.text = "HEALTH  %d / %d     MOVE  %d     DAMAGE  %d     RANGE  %d" % [
			unit.hp, unit.def.max_hp, unit.def.move, unit.def.damage, unit.def.attack_range
		]
		_hint.text = "Select %s on the map, or open Actions" % unit.display_name
		return
	var node := state.node_def(unit.agent_node)
	var progress := ""
	if node.goal > 0:
		progress = "  (breached)" if state.breached.has(unit.agent_node) else "  %d/%d" % [state.breach.get(unit.agent_node, 0), node.goal]
	_active_name.text = "%s / AI" % unit.display_name
	_active_stats.text = "On: %s%s" % [node.display_name, progress]
	_hint.text = "Click %s's AI for actions" % unit.display_name


# actions: dictionaries with "id", "text" and optionally "enabled". The menu opens beside the
# given screen point.
func open_menu(at: Vector2, actions: Array) -> void:
	for child in _action_list.get_children():
		_action_list.remove_child(child)
		child.queue_free()
	var first: Button = null
	for action in actions:
		var button := Button.new()
		button.text = action["text"]
		button.custom_minimum_size.y = 44
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.disabled = not action.get("enabled", true)
		button.pressed.connect(_choose.bind(action["id"]))
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


func set_hint(text: String) -> void:
	_hint.text = text


func close_menu() -> void:
	_action_menu.hide()


func is_menu_open() -> bool:
	return _action_menu.visible


func set_network_shown(shown: bool) -> void:
	_network_toggle.set_pressed_no_signal(shown)
	_network_toggle.text = "PHYSICAL   [N]" if shown else "NETWORK   [N]"
	%NetworkLegend.visible = shown


func set_hover(text: String) -> void:
	_hover.text = text
	%HoverPanel.visible = not text.is_empty()


func log_line(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size.x = 406
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 19)
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


func _chip(unit: Unit, is_active: bool) -> Control:
	var style := StyleBoxFlat.new()
	var accent := unit.def.color.lightened(0.2) if unit.is_player() else ENEMY_COLOR
	style.bg_color = Color(accent, 0.2 if is_active else 0.06)
	style.border_width_bottom = 3 if is_active else 1
	style.border_color = accent if is_active else Color(accent, 0.4)
	style.set_corner_radius_all(2)
	style.set_content_margin_all(7)
	var chip := PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_STOP
	chip.tooltip_text = unit.display_name + (" / active" if is_active else " / upcoming")
	chip.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = unit.display_name.to_upper().replace("GUARD ", "G")
	label.add_theme_color_override("font_color", accent if is_active else Color(0.67, 0.74, 0.74))
	label.add_theme_font_size_override("font_size", 17)
	chip.add_child(label)
	return chip
