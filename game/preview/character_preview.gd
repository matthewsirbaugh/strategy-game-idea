extends Node3D
## Look-dev stage for character models: the toon shader on a Meshy character, its clips, and the
## battle camera's view. Run with `godot --path game res://preview/character_preview.tscn`.

# Each folder in art/characters/ holds <name>.glb (mesh and rig) plus armature-only walk.glb and run.glb.
# The other clips were bought once, on the old main character, and are shared through CharacterRig.
const CHARACTERS := {
	"main_character_v2": "pack_main_character",
	"operator_sage_v2": "pack_operator_sage",
	"operator_headband_v2": "pack_operator_headband",
}
const CLIP_SOURCE := "main_character"
const FIRST_CLIPS := ["Walk", "Idle"]
const TOON := preload("res://art/shaders/toon.gdshader")
const INK := preload("res://art/shaders/ink_outline.gdshader")
const CLOSE := {"distance": 4.0, "pitch": 12.0, "height": 1.0, "fov": 40.0}
const BATTLE := {"distance": 34.0, "pitch": 50.0, "height": 0.9, "fov": 40.0}

var _names: Array[String] = []
var _character_index := 0
var _character: Node3D
var _player: AnimationPlayer
var _clips: Array[String] = []
var _clip := 0
var _toon := true
var _view := CLOSE
var _yaw := 0.0
var _surfaces: Array[Dictionary] = []
var _shared_clips: Dictionary[String, Animation] = {}
var _clip_skeleton: Skeleton3D
var _clip_walk: Animation

@onready var _camera: Camera3D = $Camera3D
@onready var _label: Label = $Label


func _ready() -> void:
	for character_name in CHARACTERS:
		if ResourceLoader.exists(_path(character_name, character_name)):
			_names.append(character_name)
	var clip_source: Node = load(_path(CLIP_SOURCE, CLIP_SOURCE)).instantiate()
	var clip_player: AnimationPlayer = clip_source.find_child("AnimationPlayer", true, false)
	for clip_name in clip_player.get_animation_list():
		_shared_clips[clip_name] = clip_player.get_animation(clip_name)
	_clip_skeleton = clip_source.find_children("*", "Skeleton3D", true, false)[0]
	_clip_walk = _first_clip(_path(CLIP_SOURCE, "walk"))
	_load_character()


func _path(character_name: String, file: String) -> String:
	return "res://art/characters/%s/%s.glb" % [character_name, file]


func _load_character() -> void:
	if _character:
		_character.free()
	_clips.clear()
	_surfaces.clear()
	var character_name := _names[_character_index]
	_character = load(_path(character_name, character_name)).instantiate()
	add_child(_character)
	_player = _character.find_child("AnimationPlayer", true, false)
	var skeleton: Skeleton3D = _character.find_children("*", "Skeleton3D", true, false)[0]
	var body: MeshInstance3D = skeleton.find_children("*", "MeshInstance3D", false, false)[0]
	CharacterRig.attach_pack(skeleton, body, load("res://art/characters/packs/%s.glb" % CHARACTERS[character_name]).instantiate())
	var library := AnimationLibrary.new()
	library.add_animation("Walk", _first_clip(_path(character_name, "walk")))
	library.add_animation("Run", _first_clip(_path(character_name, "run")))
	for clip_name in _shared_clips:
		library.add_animation(clip_name, CharacterRig.retarget(_shared_clips[clip_name], _clip_skeleton, _clip_walk, skeleton, library.get_animation("Walk")))
	_player.remove_animation_library("")
	_player.add_animation_library("", library)
	for clip_name in _player.get_animation_list():
		var clip := _player.get_animation(clip_name)
		clip.loop_mode = Animation.LOOP_LINEAR
		_keep_in_place(clip)
		_clips.append(clip_name)
	_clips.sort()
	for clip_name in FIRST_CLIPS:
		_clips.erase(clip_name)
		_clips.push_front(clip_name)
	_clip = mini(_clip, _clips.size() - 1)
	for mesh: MeshInstance3D in _character.find_children("*", "MeshInstance3D", true, false):
		for surface in mesh.mesh.get_surface_count():
			var original := mesh.get_active_material(surface)
			var toon := ShaderMaterial.new()
			toon.shader = TOON
			toon.set_shader_parameter("albedo_texture", (original as BaseMaterial3D).albedo_texture)
			var ink := ShaderMaterial.new()
			ink.shader = INK
			toon.next_pass = ink
			_surfaces.append({"mesh": mesh, "surface": surface, "original": original, "toon": toon})
	_apply()


func _first_clip(path: String) -> Animation:
	var source: Node = load(path).instantiate()
	var player: AnimationPlayer = source.find_child("AnimationPlayer", true, false)
	var clip := player.get_animation(player.get_animation_list()[0])
	source.free()
	return clip


# Meshy clips walk the hips forward; a tactics unit moves by code, so the clips play in place.
func _keep_in_place(clip: Animation) -> void:
	for track in clip.get_track_count():
		if clip.track_get_type(track) != Animation.TYPE_POSITION_3D or not str(clip.track_get_path(track)).ends_with(":Hips"):
			continue
		var start: Vector3 = clip.track_get_key_value(track, 0)
		for key in clip.track_get_key_count(track):
			var value: Vector3 = clip.track_get_key_value(track, key)
			clip.track_set_key_value(track, key, Vector3(start.x, value.y, start.z))


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
	_player.play(_clips[_clip])
	for entry in _surfaces:
		entry.mesh.set_surface_override_material(entry.surface, entry.toon if _toon else entry.original)
	var pitch := deg_to_rad(_view.pitch as float)
	var yaw := deg_to_rad(_yaw)
	var target := Vector3(0, _view.height, 0)
	var offset := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * (_view.distance as float)
	_camera.fov = _view.fov
	_camera.look_at_from_position(target + offset, target)
	_label.text = "%s — %s   (%d/%d)\nC character   ←/→ clip   T toon %s   V view: %s   Q/E rotate   Esc quit" % [
		_names[_character_index], _clips[_clip], _clip + 1, _clips.size(), "on" if _toon else "off", "battle camera" if _view == BATTLE else "close"]
