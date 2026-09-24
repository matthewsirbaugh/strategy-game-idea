class_name SettingsMenu
extends Control

signal closed

@onready var _volume: HSlider = %Volume
@onready var _fullscreen: CheckButton = %Fullscreen
@onready var _vsync: CheckButton = %Vsync
@onready var _back: Button = %Back


func _ready() -> void:
	_volume.value = Settings.master_volume * 100.0
	_fullscreen.button_pressed = Settings.fullscreen
	_vsync.button_pressed = Settings.vsync
	_volume.value_changed.connect(_on_volume_changed)
	_fullscreen.toggled.connect(_on_fullscreen_toggled)
	_vsync.toggled.connect(_on_vsync_toggled)
	_back.pressed.connect(closed.emit)
	visibility_changed.connect(_on_visibility_changed)


func _unhandled_input(event: InputEvent) -> void:
	if is_visible_in_tree() and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		closed.emit()


func _on_visibility_changed() -> void:
	if visible:
		_back.grab_focus()


func _on_volume_changed(value: float) -> void:
	Settings.master_volume = value / 100.0
	_commit()


func _on_fullscreen_toggled(on: bool) -> void:
	Settings.fullscreen = on
	_commit()


func _on_vsync_toggled(on: bool) -> void:
	Settings.vsync = on
	_commit()


func _commit() -> void:
	Settings.apply()
	Settings.save()
