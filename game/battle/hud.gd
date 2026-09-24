class_name Hud
extends CanvasLayer

signal end_turn_pressed
signal undo_pressed

const PLAYER_COLOR := Color(0.22, 0.5, 0.85)
const ENEMY_COLOR := Color(0.8, 0.28, 0.25)
const LOG_LINES := 7

@onready var _round: Label = %RoundLabel
@onready var _order: HBoxContainer = %Order
@onready var _hover: Label = %HoverLabel
@onready var _active_panel: Control = %ActivePanel
@onready var _active_name: Label = %ActiveName
@onready var _active_stats: Label = %ActiveStats
@onready var _undo: Button = %Undo
@onready var _end_turn: Button = %EndTurn
@onready var _log: VBoxContainer = %Log
@onready var _result: Control = %Result
@onready var _result_label: Label = %ResultLabel
@onready var _restart: Button = %Restart
@onready var _quit: Button = %QuitToTitle


func _ready() -> void:
	_undo.pressed.connect(undo_pressed.emit)
	_end_turn.pressed.connect(end_turn_pressed.emit)
	_restart.pressed.connect(SceneRouter.goto_battle)
	_quit.pressed.connect(SceneRouter.goto_title)


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
		show_active(active)


func show_active(unit: Unit) -> void:
	_active_name.text = unit.display_name
	_active_stats.text = "HP %d/%d    Move %d    Damage %d    Range %d" % [
		unit.hp, unit.def.max_hp, unit.def.move, unit.def.damage, unit.def.attack_range
	]
	_undo.disabled = not unit.moved or unit.acted


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
	_result_label.text = "Victory" if won else "Defeat"
	_result.show()
	_restart.grab_focus()


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
