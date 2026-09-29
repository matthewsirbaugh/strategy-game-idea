class_name Hud
extends CanvasLayer

signal action_chosen(id: String)
signal menu_cancelled
signal network_toggled(shown: bool)

const PLAYER_COLOR := Color(0.22, 0.5, 0.85)
const ENEMY_COLOR := Color(0.8, 0.28, 0.25)
const LOG_LINES := 7
const FULL_CONTEXT_COLOR := Color(1.0, 0.45, 0.4)
const MENU_OFFSET := Vector2(40, 0)
const SCREEN_MARGIN := 12.0

@onready var _round: Label = %RoundLabel
@onready var _order: HBoxContainer = %Order
@onready var _hover: Label = %HoverLabel
@onready var _objective: Label = %ObjectiveLabel
@onready var _active_panel: Control = %ActivePanel
@onready var _active_name: Label = %ActiveName
@onready var _active_stats: Label = %ActiveStats
@onready var _context: ProgressBar = %ContextBar
@onready var _hint: Label = %Hint
@onready var _action_menu: Control = %ActionMenu
@onready var _action_list: VBoxContainer = %ActionList
@onready var _network_toggle: Button = %NetworkToggle
@onready var _log: VBoxContainer = %Log
@onready var _result: Control = %Result
@onready var _result_label: Label = %ResultLabel
@onready var _restart: Button = %Restart
@onready var _quit: Button = %QuitToTitle


func _ready() -> void:
	_network_toggle.toggled.connect(network_toggled.emit)
	_restart.pressed.connect(SceneRouter.goto_battle)
	_quit.pressed.connect(SceneRouter.goto_title)


# The menu has to close before the pause menu sees Esc, so this runs in _input.
func _input(event: InputEvent) -> void:
	if _action_menu.visible and (event.is_action_pressed("ui_cancel") or event.is_action_released("cancel")):
		get_viewport().set_input_as_handled()
		close_menu()
		menu_cancelled.emit()


func show_turn(state: BattleState) -> void:
	_round.text = "Round %d" % state.round_number
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
	_context.value = unit.context
	_context.modulate = FULL_CONTEXT_COLOR if unit.context >= BattleState.CONTEXT_MAX else Color.WHITE
	if state.phase == BattleState.Phase.HUMAN or unit.agent_node == "":
		_active_name.text = unit.display_name
		_active_stats.text = "HP %d/%d    Move %d    Damage %d    Range %d    Context %d" % [
			unit.hp, unit.def.max_hp, unit.def.move, unit.def.damage, unit.def.attack_range, unit.context
		]
		_hint.text = "Click %s for actions" % unit.display_name
		return
	var node := state.node_def(unit.agent_node)
	var progress := ""
	if node.goal > 0:
		progress = "  (breached)" if state.breached.has(unit.agent_node) else "  %d/%d" % [state.breach.get(unit.agent_node, 0), node.goal]
	_active_name.text = "%s  ·  AI" % unit.display_name
	_active_stats.text = "On: %s%s    Context %d/%d" % [node.display_name, progress, unit.context, BattleState.CONTEXT_MAX]
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


func set_hover(text: String) -> void:
	_hover.text = text


func log_line(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	_log.add_child(label)
	while _log.get_child_count() > LOG_LINES:
		var oldest := _log.get_child(0)
		_log.remove_child(oldest)
		oldest.queue_free()


func show_result(won: bool) -> void:
	_active_panel.hide()
	close_menu()
	_result_label.text = "Victory" if won else "Defeat"
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
	style.bg_color = PLAYER_COLOR if unit.is_player() else ENEMY_COLOR
	if is_active:
		style.set_border_width_all(2)
		style.border_color = Color.WHITE
	else:
		style.bg_color = style.bg_color.darkened(0.45)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(6)
	var chip := PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = unit.display_name
	label.add_theme_font_size_override("font_size", 16)
	chip.add_child(label)
	return chip
