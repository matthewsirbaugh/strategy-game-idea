extends Control

@onready var _main: Control = %Main
@onready var _settings: SettingsMenu = %SettingsMenu
@onready var _new_game: Button = %NewGame
@onready var _settings_button: Button = %SettingsButton
@onready var _quit: Button = %Quit


func _ready() -> void:
	_new_game.pressed.connect(SceneRouter.goto_loadout)
	_settings_button.pressed.connect(_open_settings)
	_quit.pressed.connect(get_tree().quit)
	_settings.closed.connect(_close_settings)
	_new_game.grab_focus()


func _open_settings() -> void:
	_main.hide()
	_settings.show()


func _close_settings() -> void:
	_settings.hide()
	_main.show()
	_settings_button.grab_focus()
