extends Node3D
## Look-dev stage for new props: each new model in assets/ (not legacy/) under night light like the references,
## cool moonlight, a warm uplight and dry ground, beside a 1.8 m person for scale. Run with
## `godot --path game res://preview/prop_preview.tscn`. Left and right change prop, V switches
## between the battle camera's view and a close one, Q and E turn the prop.

const ASSET_DIR := "res://assets/"
const CLOSE := {"distance": 4.5, "pitch": 14.0, "height": 0.7, "fov": 40.0}
const BATTLE := {"distance": 34.0, "pitch": 50.0, "height": 0.9, "fov": 40.0}

var _paths: Array[String] = []
var _index := 0
var _prop: Node3D
var _view := CLOSE
var _yaw := 35.0

@onready var _camera: Camera3D = $Camera3D
@onready var _label: Label = $Label


func _ready() -> void:
	_build_stage()
	_find_models(ASSET_DIR)
	_show()


func _find_models(dir: String) -> void:
	for file in DirAccess.get_files_at(dir):
		if file.ends_with(".glb"):
			_paths.append(dir + file)
	for sub in DirAccess.get_directories_at(dir):
		if sub != "legacy":
			_find_models(dir + sub + "/")


func _build_stage() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.02, 0.03, 0.06)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.35, 0.4, 0.55)
	environment.ambient_light_energy = 0.35
	environment.tonemap_mode = Environment.TONE_MAPPER_AGX
	environment.ssr_enabled = true
	environment.ssao_enabled = true
	environment.glow_enabled = true
	var world := WorldEnvironment.new()
	world.environment = environment
	add_child(world)
	var moon := DirectionalLight3D.new()
	moon.light_color = Color(0.62, 0.7, 0.95)
	moon.light_energy = 0.35
	moon.shadow_enabled = true
	moon.rotation_degrees = Vector3(-55, -30, 0)
	add_child(moon)
	var uplight := SpotLight3D.new()
	uplight.light_color = Color(1.0, 0.72, 0.42)
	uplight.light_energy = 6.0
	uplight.spot_range = 6.0
	uplight.spot_angle = 50.0
	uplight.shadow_enabled = true
	uplight.position = Vector3(1.2, 0.15, 1.6)
	add_child(uplight)
	uplight.look_at(Vector3(0, 1.0, 0))
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(30, 30)
	ground.mesh = plane
	var dry := StandardMaterial3D.new()
	dry.albedo_color = Color(0.42, 0.41, 0.4)
	dry.roughness = 0.85
	ground.material_override = dry
	add_child(ground)
	var person := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.height = 1.8
	capsule.radius = 0.22
	person.mesh = capsule
	person.position = Vector3(-1.2, 0.9, 0)
	var grey := StandardMaterial3D.new()
	grey.albedo_color = Color(0.45, 0.45, 0.47)
	person.material_override = grey
	add_child(person)


func _show() -> void:
	if _prop:
		_prop.free()
		_prop = null
	if _paths.is_empty():
		_label.text = "No new models in %s yet" % ASSET_DIR
		_place_camera()
		return
	_prop = (load(_paths[_index]) as PackedScene).instantiate()
	add_child(_prop)
	_prop.rotation_degrees.y = _yaw
	var size := _size(_prop)
	_label.text = "%s   %.2f x %.2f x %.2f m   (%d of %d)   Left/Right prop · V view · Q/E turn" % [
		_paths[_index].get_file(), size.x, size.y, size.z, _index + 1, _paths.size()]
	_place_camera()


func _size(root: Node3D) -> Vector3:
	var box := AABB()
	var first := true
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		var bounds := mesh.global_transform * mesh.get_aabb()
		box = bounds if first else box.merge(bounds)
		first = false
	return box.size


func _place_camera() -> void:
	var pitch := deg_to_rad(_view.pitch)
	_camera.fov = _view.fov
	_camera.position = Vector3(0, _view.height, 0) + Vector3(0, sin(pitch), cos(pitch)) * _view.distance
	_camera.look_at(Vector3(0, _view.height, 0))


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if not key or not key.pressed or _paths.is_empty() and key.keycode != KEY_V:
		return
	match key.keycode:
		KEY_RIGHT:
			_index = (_index + 1) % _paths.size()
			_show()
		KEY_LEFT:
			_index = (_index - 1 + _paths.size()) % _paths.size()
			_show()
		KEY_V:
			_view = BATTLE if _view == CLOSE else CLOSE
			_place_camera()
		KEY_Q, KEY_E:
			_yaw += -20.0 if key.keycode == KEY_Q else 20.0
			if _prop:
				_prop.rotation_degrees.y = _yaw
