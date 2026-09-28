extends Node3D
## Look-dev stage for character models: the toon shader on a Meshy character, its clips, and the
## battle camera's view. Run with `godot --path game res://preview/character_preview.tscn`.

# Each folder in art/characters/ holds <name>.glb (mesh, rig, clips) plus armature-only walk.glb and run.glb.
# An unrigged model (just <name>.glb) shows as a still T-pose.
const CHARACTERS := ["main_character_v2", "operator_sage_v2", "operator_headband_v2", "main_character", "operator_sage", "operator_headband"]
const HEIGHT := 1.7
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
var _original: Array[Material] = []
var _toon_materials: Array[Material] = []
var _mesh: MeshInstance3D

@onready var _camera: Camera3D = $Camera3D
@onready var _label: Label = $Label


func _ready() -> void:
	for character_name in CHARACTERS:
		if ResourceLoader.exists(_path(character_name, character_name)):
			_names.append(character_name)
	_load_character()


func _path(character_name: String, file: String) -> String:
	return "res://art/characters/%s/%s.glb" % [character_name, file]


func _load_character() -> void:
	if _character:
		_character.free()
	_clips.clear()
	_original.clear()
	_toon_materials.clear()
	var character_name := _names[_character_index]
	_character = load(_path(character_name, character_name)).instantiate()
	add_child(_character)
	_player = _character.find_child("AnimationPlayer", true, false)
	_mesh = _find_mesh(_character)
	if not _player:
		_stand_up()
	for clip_name in {"Walk": "walk", "Run": "run"}.keys() if _player else []:
		var source: Node = load(_path(character_name, clip_name.to_lower())).instantiate()
		var source_player: AnimationPlayer = source.find_child("AnimationPlayer", true, false)
		_player.get_animation_library("").add_animation(clip_name, source_player.get_animation(source_player.get_animation_list()[0]))
		source.free()
	for clip_name in _player.get_animation_list() if _player else []:
		var clip := _player.get_animation(clip_name)
		clip.loop_mode = Animation.LOOP_LINEAR
		_keep_in_place(clip)
		_clips.append(clip_name)
	_clips.sort()
	for clip_name in FIRST_CLIPS:
		_clips.erase(clip_name)
		_clips.push_front(clip_name)
	_clip = clampi(_clip, 0, maxi(_clips.size() - 1, 0))
	for surface in _mesh.mesh.get_surface_count():
		var original := _mesh.get_active_material(surface)
		_original.append(original)
		var toon := ShaderMaterial.new()
		toon.shader = TOON
		toon.set_shader_parameter("albedo_texture", (original as BaseMaterial3D).albedo_texture)
		var ink := ShaderMaterial.new()
		ink.shader = INK
		toon.next_pass = ink
		_toon_materials.append(toon)
	_apply()


# Unrigged Meshy output comes at an arbitrary scale and origin; stand it on the floor at person height.
func _stand_up() -> void:
	var box := _mesh.global_transform * _mesh.get_aabb()
	_character.scale *= HEIGHT / box.size.y
	box = _mesh.global_transform * _mesh.get_aabb()
	_character.position -= Vector3(box.get_center().x, box.position.y, box.get_center().z)


# Meshy clips walk the hips forward; a tactics unit moves by code, so the clips play in place.
func _keep_in_place(clip: Animation) -> void:
	for track in clip.get_track_count():
		if clip.track_get_type(track) != Animation.TYPE_POSITION_3D or not str(clip.track_get_path(track)).ends_with(":Hips"):
			continue
		var start: Vector3 = clip.track_get_key_value(track, 0)
		for key in clip.track_get_key_count(track):
			var value: Vector3 = clip.track_get_key_value(track, key)
			clip.track_set_key_value(track, key, Vector3(start.x, value.y, start.z))


func _find_mesh(node: Node) -> MeshInstance3D:
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
		var found := _find_mesh(child)
		if found:
			return found
	return null


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_RIGHT: _clip = (_clip + 1) % maxi(_clips.size(), 1)
		KEY_LEFT: _clip = (_clip - 1 + _clips.size()) % maxi(_clips.size(), 1)
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
	if _player:
		_player.play(_clips[_clip])
	for surface in _original.size():
		_mesh.set_surface_override_material(surface, _toon_materials[surface] if _toon else _original[surface])
	var pitch := deg_to_rad(_view.pitch as float)
	var yaw := deg_to_rad(_yaw)
	var target := Vector3(0, _view.height, 0)
	var offset := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * (_view.distance as float)
	_camera.fov = _view.fov
	_camera.look_at_from_position(target + offset, target)
	_label.text = "%s — %s   (%d/%d)\nC character   ←/→ clip   T toon %s   V view: %s   Q/E rotate   Esc quit" % [
		_names[_character_index], _clips[_clip] if _player else "T-pose, no rig yet", _clip + 1 if _player else 0, _clips.size(), "on" if _toon else "off", "battle camera" if _view == BATTLE else "close"]
