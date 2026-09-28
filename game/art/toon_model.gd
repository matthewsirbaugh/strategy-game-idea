class_name ToonModel
extends Node3D
## A Meshy model drawn with the toon shader and ink outline. A rigged character also gets its
## pack, the shared clips, and plays whatever clip the battle asks for.

const TOON := preload("res://art/shaders/toon.gdshader")
const INK := preload("res://art/shaders/ink_outline.gdshader")
const CLIP_SOURCE := "res://art/characters/clip_source/"
const LOOPING := ["Idle", "Walk", "Run", "Cautious_Crouch_Walk_Forward"]

# Shared by every copy: one toon material per source material, one clip library per rig.
static var _toon_materials := {}
static var _cloak_materials := {}
static var _libraries := {}

var tint := Color.WHITE:
	set(value):
		tint = value
		_set_instance("tint", value)
var flash := 0.0:
	set(value):
		flash = value
		_set_instance("flash", value)
# The clip to fall back to when a one-shot clip ends; empty once the unit is down.
var idle := "Idle"
var player: AnimationPlayer
var _surfaces: Array[Dictionary] = []


# Call once the model is in the tree: the pack is placed from world positions.
func build(scene: PackedScene, pack: PackedScene = null) -> void:
	var body: Node3D = scene.instantiate()
	add_child(body)
	var skeletons := body.find_children("*", "Skeleton3D", true, false)
	if not skeletons.is_empty():
		var skeleton: Skeleton3D = skeletons[0]
		if pack:
			CharacterRig.attach_pack(skeleton, skeleton.find_children("*", "MeshInstance3D", false, false)[0], pack.instantiate())
		player = body.find_child("AnimationPlayer", true, false)
		player.remove_animation_library("")
		player.add_animation_library("", _library(scene.resource_path, skeleton))
		player.animation_finished.connect(_on_clip_finished)
		play(idle)
	for mesh: MeshInstance3D in find_children("*", "MeshInstance3D", true, false):
		for surface in mesh.mesh.get_surface_count():
			var original := mesh.get_active_material(surface)
			_surfaces.append({"mesh": mesh, "surface": surface, "original": original})
			mesh.set_surface_override_material(surface, _toon(original))


# Props come at whatever size Meshy made them: scale to a real size, standing centred on the parent.
func fit_height(metres: float) -> void:
	scale *= metres / bounds().size.y
	_stand_on_parent()


func fit_width(metres: float) -> void:
	scale *= metres / bounds().size.x
	_stand_on_parent()


func _stand_on_parent() -> void:
	var box := bounds()
	var origin := get_parent_node_3d().global_position
	global_position += Vector3(origin.x - box.get_center().x, origin.y - box.position.y, origin.z - box.get_center().z)


func bounds() -> AABB:
	var box := AABB()
	for i in _surfaces.size():
		var mesh: MeshInstance3D = _surfaces[i].mesh
		var part := mesh.global_transform * mesh.get_aabb()
		box = part if i == 0 else box.merge(part)
	return box


func clips() -> PackedStringArray:
	return player.get_animation_list() if player else PackedStringArray()


# move_speed in metres per second matches a walk or run clip's feet to how fast the unit travels.
func play(clip: String, move_speed := 0.0) -> void:
	if not player:
		return
	var native: float = player.get_animation(clip).get_meta("speed", 0.0)
	player.speed_scale = move_speed / native if move_speed > 0.0 and native > 0.0 else 1.0
	player.play(clip, 0.15)


func face(direction: Vector3) -> void:
	if Vector2(direction.x, direction.z).length() > 0.01:
		rotation.y = atan2(direction.x, direction.z)


func set_cloaked(cloaked: bool) -> void:
	for entry in _surfaces:
		entry.mesh.set_surface_override_material(entry.surface, _cloak(entry.original) if cloaked else _toon(entry.original))


func set_toon(on: bool) -> void:
	for entry in _surfaces:
		entry.mesh.set_surface_override_material(entry.surface, _toon(entry.original) if on else entry.original)


func _on_clip_finished(clip: String) -> void:
	if idle != "" and clip != idle:
		play(idle)


func _set_instance(parameter: String, value: Variant) -> void:
	for entry in _surfaces:
		entry.mesh.set_instance_shader_parameter(parameter, value)


static func _toon(original: Material) -> ShaderMaterial:
	if not _toon_materials.has(original):
		var toon := ShaderMaterial.new()
		toon.shader = TOON
		toon.set_shader_parameter("albedo_texture", (original as BaseMaterial3D).albedo_texture)
		var ink := ShaderMaterial.new()
		ink.shader = INK
		toon.next_pass = ink
		_toon_materials[original] = toon
	return _toon_materials[original]


static func _cloak(original: Material) -> StandardMaterial3D:
	if not _cloak_materials.has(original):
		var cloak := StandardMaterial3D.new()
		cloak.albedo_texture = (original as BaseMaterial3D).albedo_texture
		cloak.albedo_color = Color(1, 1, 1, 0.3)
		cloak.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		cloak.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_cloak_materials[original] = cloak
	return _cloak_materials[original]


# Walk and run come with each rig; the other clips were bought once, for clip_source/, and are
# retargeted onto each rig the first time it loads.
static func _library(path: String, skeleton: Skeleton3D) -> AnimationLibrary:
	if _libraries.has(path):
		return _libraries[path]
	var folder := path.get_base_dir()
	var library := AnimationLibrary.new()
	var walk := _first_clip(folder + "/walk.glb")
	library.add_animation("Walk", walk)
	library.add_animation("Run", _first_clip(folder + "/run.glb"))
	var source: Node = load(CLIP_SOURCE + "clip_source.glb").instantiate()
	var source_player: AnimationPlayer = source.find_child("AnimationPlayer", true, false)
	var source_skeleton: Skeleton3D = source.find_children("*", "Skeleton3D", true, false)[0]
	var source_walk := _first_clip(CLIP_SOURCE + "walk.glb")
	for clip_name in source_player.get_animation_list():
		library.add_animation(clip_name, CharacterRig.retarget(source_player.get_animation(clip_name), source_skeleton, source_walk, skeleton, walk))
	source.free()
	var metres := skeleton.global_transform.basis.get_scale().x
	for clip_name in library.get_animation_list():
		var clip := library.get_animation(clip_name)
		clip.loop_mode = Animation.LOOP_LINEAR if clip_name in LOOPING else Animation.LOOP_NONE
		_keep_in_place(clip, metres)
	_libraries[path] = library
	return library


static func _first_clip(path: String) -> Animation:
	var source: Node = load(path).instantiate()
	var player: AnimationPlayer = source.find_child("AnimationPlayer", true, false)
	var clip := player.get_animation(player.get_animation_list()[0])
	source.free()
	return clip


# Meshy clips walk the hips forward; a tactics unit moves by code, so the clips play in place.
# How far the hips travelled is kept as the clip's speed, to match the feet to real movement.
static func _keep_in_place(clip: Animation, metres: float) -> void:
	for track in clip.get_track_count():
		if clip.track_get_type(track) != Animation.TYPE_POSITION_3D or not str(clip.track_get_path(track)).ends_with(":Hips"):
			continue
		var keys := clip.track_get_key_count(track)
		var start: Vector3 = clip.track_get_key_value(track, 0)
		var end: Vector3 = clip.track_get_key_value(track, keys - 1)
		if not clip.has_meta("speed"):
			clip.set_meta("speed", Vector2(end.x - start.x, end.z - start.z).length() * metres / clip.length)
		for key in keys:
			var value: Vector3 = clip.track_get_key_value(track, key)
			clip.track_set_key_value(track, key, Vector3(start.x, value.y, start.z))
