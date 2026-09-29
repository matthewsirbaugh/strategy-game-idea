extends Node3D
## Look-dev stage for character models: the toon shader, their clips, and the battle camera's
## view. Run with `godot --path game res://preview/character_preview.tscn`.

# Character folder in art/characters/ and the pack each one wears, if any.
const CHARACTERS := {
	"main_character": "pack_main_character",
	"operator_sage": "pack_operator_sage",
	"operator_headband": "pack_operator_headband",
	"guard": "",
}
const FIRST_CLIPS := ["Walk", "Neutral"]
const CLOSE := {"distance": 4.0, "pitch": 12.0, "height": 1.0, "fov": 40.0}
const BATTLE := {"distance": 34.0, "pitch": 50.0, "height": 0.9, "fov": 40.0}

var _names: Array = CHARACTERS.keys()
var _character_index := 0
var _model: ToonModel
var _clips: Array[String] = []
var _clip := 0
var _toon := true
var _view := CLOSE
var _yaw := 0.0

@onready var _camera: Camera3D = $Camera3D
@onready var _label: Label = $Label


func _ready() -> void:
	_load_character()


func _load_character() -> void:
	if _model:
		_model.free()
	var character_name: String = _names[_character_index]
	var pack: String = CHARACTERS[character_name]
	_model = ToonModel.new()
	add_child(_model)
	_model.build(load("res://art/characters/%s/%s.glb" % [character_name, character_name]), load("res://art/characters/packs/%s.glb" % pack) if pack else null)
	_clips.assign(_model.clips())
	_clips.sort()
	for clip_name in FIRST_CLIPS:
		_clips.erase(clip_name)
		_clips.push_front(clip_name)
	_clip = mini(_clip, _clips.size() - 1)
	_apply()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_RIGHT: _clip = (_clip + 1) % _clips.size()
		KEY_LEFT: _clip = (_clip - 1 + _clips.size()) % _clips.size()
		KEY_C:
			_character_index = (_character_index + 1) % _names.size()
			_load_character()
			return
		KEY_T: _toon = not _toon
		KEY_V: _view = BATTLE if _view == CLOSE else CLOSE
		KEY_Q: _yaw -= 45.0
		KEY_E: _yaw += 45.0
		KEY_ESCAPE: get_tree().quit()
	_apply()


func _apply() -> void:
	# The chosen clip is also the one to fall back to, so one-shot clips replay and can be studied.
	_model.idle = _clips[_clip]
	_model.play(_clips[_clip])
	_model.set_toon(_toon)
	var pitch := deg_to_rad(_view.pitch as float)
	var yaw := deg_to_rad(_yaw)
	var target := Vector3(0, _view.height, 0)
	var offset := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * (_view.distance as float)
	_camera.fov = _view.fov
	_camera.look_at_from_position(target + offset, target)
	_label.text = "%s — %s   (%d/%d)\nC character   ←/→ clip   T toon %s   V view: %s   Q/E rotate   Esc quit" % [
		_names[_character_index], _clips[_clip], _clip + 1, _clips.size(), "on" if _toon else "off", "battle camera" if _view == BATTLE else "close"]
