class_name CameraRig
extends Node3D

@export var pan_speed := 8.0
@export var pitch_degrees := 50.0
@export var min_distance := 12.0
@export var max_distance := 50.0
@export var zoom_step := 2.0
@export var rotate_seconds := 0.25
@export var overhead_distance := 34.0
@export var overhead_seconds := 0.5

var _bounds_min := Vector3.ZERO
var _bounds_max := Vector3.ZERO
var _distance := 34.0
var _pitch := 50.0
var _yaw_steps := 0
var _rotate_tween: Tween
var _focus_tween: Tween
var _before_overhead := {}

@onready var _camera: Camera3D = $Camera3D


func setup(center: Vector3, extent: Vector3) -> void:
	position = center
	_bounds_max = extent
	_pitch = pitch_degrees
	rotation.y = _yaw()
	_update_camera()


# Moves only when the target is near the screen edge, so the view doesn't swing every turn.
func keep_in_view(target: Vector3) -> void:
	var screen := _camera.get_viewport().get_visible_rect()
	if not screen.grow(-screen.size.y * 0.2).has_point(_camera.unproject_position(target)):
		focus(target)


func focus(target: Vector3) -> void:
	if _focus_tween:
		_focus_tween.kill()
	_focus_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_focus_tween.tween_property(self, "position", target.clamp(_bounds_min, _bounds_max), 0.35)


# Tilts to look straight down on the whole field. restore_view() tilts back to where it was.
func overhead(center: Vector3) -> void:
	_before_overhead = {"position": position, "distance": _distance, "pitch": _pitch}
	await _glide(center, overhead_distance, 90.0)


func restore_view() -> void:
	await _glide(_before_overhead["position"], _before_overhead["distance"], _before_overhead["pitch"])


func _glide(to_position: Vector3, to_distance: float, to_pitch: float) -> void:
	if _focus_tween:
		_focus_tween.kill()
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", to_position, overhead_seconds)
	tween.tween_method(_set_distance, _distance, to_distance, overhead_seconds)
	tween.tween_method(_set_pitch, _pitch, to_pitch, overhead_seconds)
	await tween.finished


func _process(delta: float) -> void:
	var input := Input.get_vector("camera_left", "camera_right", "camera_forward", "camera_back")
	if input == Vector2.ZERO:
		return
	var direction := Vector3(input.x, 0.0, input.y).rotated(Vector3.UP, rotation.y)
	position = (position + direction * pan_speed * delta).clamp(_bounds_min, _bounds_max)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_rotate_left"):
		_rotate(-1)
	elif event.is_action_pressed("camera_rotate_right"):
		_rotate(1)
	elif event.is_action_pressed("camera_zoom_in"):
		_set_distance(_distance - zoom_step)
	elif event.is_action_pressed("camera_zoom_out"):
		_set_distance(_distance + zoom_step)


func _rotate(steps: int) -> void:
	_yaw_steps += steps
	if _rotate_tween:
		_rotate_tween.kill()
	_rotate_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_rotate_tween.tween_property(self, "rotation:y", _yaw(), rotate_seconds)


func _set_distance(distance: float) -> void:
	_distance = clampf(distance, min_distance, max_distance)
	_update_camera()


func _set_pitch(pitch: float) -> void:
	_pitch = pitch
	_update_camera()


# Starts at 45° so the grid reads as a diamond, the usual tactics view.
func _yaw() -> float:
	return deg_to_rad(45.0 + 90.0 * _yaw_steps)


func _update_camera() -> void:
	var pitch := deg_to_rad(_pitch)
	_camera.position = Vector3(0.0, sin(pitch), cos(pitch)) * _distance
	_camera.rotation = Vector3(-pitch, 0.0, 0.0)
