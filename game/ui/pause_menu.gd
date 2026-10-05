extends CanvasLayer

@onready var _root: Control = %Root
@onready var _main: Control = %Main
@onready var _settings: SettingsMenu = %SettingsMenu
@onready var _resume: Button = %Resume
@onready var _settings_button: Button = %SettingsButton
@onready var _restart: Button = %Restart
@onready var _quit_to_title: Button = %QuitToTitle


func _ready() -> void:
	_root.hide()
	_resume.pressed.connect(_close)
	_settings_button.pressed.connect(_open_settings)
	_restart.pressed.connect(SceneRouter.restart_battle)
	_quit_to_title.pressed.connect(SceneRouter.goto_title)
	_settings.closed.connect(_close_settings)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		if _root.visible:
			_close()
		else:
			_open()


func _open() -> void:
	get_tree().paused = true
	_root.show()
	_main.show()
	_settings.hide()
	_resume.grab_focus()


func _close() -> void:
	get_tree().paused = false
	_root.hide()


func _open_settings() -> void:
	_main.hide()
	_settings.show()


func _close_settings() -> void:
	_settings.hide()
	_main.show()
	_settings_button.grab_focus()
