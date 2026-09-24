class_name CameraRig
extends Node3D

@export var pan_speed := 8.0
@export var pitch_degrees := 50.0
@export var min_distance := 12.0
@export var max_distance := 50.0
@export var zoom_step := 2.0
@export var rotate_seconds := 0.25

var _bounds_min := Vector3.ZERO
var _bounds_max := Vector3.ZERO
var _distance := 34.0
var _yaw_steps := 0
var _rotate_tween: Tween
var _focus_tween: Tween

@onready var _camera: Camera3D = $Camera3D


func setup(center: Vector3, extent: Vector3) -> void:
	position = center
	_bounds_max = extent
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
		_zoom(-zoom_step)
	elif event.is_action_pressed("camera_zoom_out"):
		_zoom(zoom_step)


func _rotate(steps: int) -> void:
	_yaw_steps += steps
	if _rotate_tween:
		_rotate_tween.kill()
	_rotate_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_rotate_tween.tween_property(self, "rotation:y", _yaw(), rotate_seconds)


func _zoom(amount: float) -> void:
	_distance = clampf(_distance + amount, min_distance, max_distance)
	_update_camera()


# Starts at 45° so the grid reads as a diamond, the usual tactics view.
func _yaw() -> float:
	return deg_to_rad(45.0 + 90.0 * _yaw_steps)


func _update_camera() -> void:
	var pitch := deg_to_rad(pitch_degrees)
	_camera.position = Vector3(0.0, sin(pitch), cos(pitch)) * _distance
	_camera.rotation = Vector3(-pitch, 0.0, 0.0)
