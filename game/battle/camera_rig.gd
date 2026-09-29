class_name CameraRig
extends Node3D

## A free, RTS-style camera around a point on the floor: pan it, orbit it, zoom in close.

# Pan speed is in screen heights per second, so it feels the same at any zoom.
@export var pan_speed := 0.8
@export var pitch_degrees := 50.0
# Which way the view first faces: 0 looks north from the south edge of the map.
@export var start_yaw := 45.0
@export var min_distance := 3.0
@export var max_distance := 45.0
@export var zoom_factor := 1.15
@export var turn_degrees_per_second := 90.0
@export var overhead_distance := 44.0
@export var overhead_seconds := 0.5
# How far past the map the view can pan, to take in the building around it.
@export var pan_margin := 9.0
@export var drag_threshold := 8.0
@export var orbit_degrees_per_pixel := 0.3
@export var min_pitch := 10.0
@export var max_pitch := 85.0

# The last press moved far enough to be a drag, so letting go isn't a click.
var dragged := false

var _bounds_min := Vector3.ZERO
var _bounds_max := Vector3.ZERO
var _distance := 26.0
var _pitch := 50.0
var _yaw := 0.0
var _focus_tween: Tween
var _before_overhead := {}
var _drag_button := MOUSE_BUTTON_NONE
var _press_at := Vector2.ZERO

@onready var _camera: Camera3D = $Camera3D


func setup(center: Vector3, extent: Vector3) -> void:
	position = center
	_bounds_min = -Vector3(pan_margin, 0, pan_margin)
	_bounds_max = extent + Vector3(pan_margin, 0, pan_margin)
	_pitch = pitch_degrees
	_yaw = start_yaw
	rotation.y = deg_to_rad(_yaw)
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
	var turn := Input.get_axis("camera_rotate_left", "camera_rotate_right")
	if turn != 0.0:
		_yaw += turn * turn_degrees_per_second * delta
		rotation.y = deg_to_rad(_yaw)
	var input := Input.get_vector("camera_left", "camera_right", "camera_forward", "camera_back")
	if input != Vector2.ZERO:
		var screen_height := _camera.get_viewport().get_visible_rect().size.y
		_pan_by(input * pan_speed * screen_height * delta * Vector2(-1, -1))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_zoom_in"):
		_set_distance(_distance / zoom_factor)
	elif event.is_action_pressed("camera_zoom_out"):
		_set_distance(_distance * zoom_factor)
	elif event is InputEventMagnifyGesture:
		_set_distance(_distance / event.factor)
	elif event is InputEventMouseButton:
		_on_button(event)
	elif event is InputEventMouseMotion and _drag_button != MOUSE_BUTTON_NONE:
		_on_drag(event)


# Left-drag orbits: sideways turns the view, up and down tilts it. Middle-drag, or Option/Alt
# with left-drag on a trackpad, pans.
func _on_button(event: InputEventMouseButton) -> void:
	if event.button_index not in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_MIDDLE]:
		return
	if not event.pressed:
		_drag_button = MOUSE_BUTTON_NONE
		return
	var panning := event.button_index == MOUSE_BUTTON_MIDDLE or event.alt_pressed
	_drag_button = MOUSE_BUTTON_MIDDLE if panning else MOUSE_BUTTON_LEFT
	_press_at = event.position
	dragged = false


func _on_drag(event: InputEventMouseMotion) -> void:
	if not dragged and event.position.distance_to(_press_at) < drag_threshold:
		return
	dragged = true
	if _drag_button == MOUSE_BUTTON_MIDDLE:
		_pan_by(event.relative)
		return
	_yaw -= event.relative.x * orbit_degrees_per_pixel
	rotation.y = deg_to_rad(_yaw)
	_set_pitch(clampf(_pitch + event.relative.y * orbit_degrees_per_pixel, min_pitch, max_pitch))


# Grabs the ground: whatever is under the cursor stays under it.
func _pan_by(pixels: Vector2) -> void:
	var metres := 2.0 * _distance * tan(deg_to_rad(_camera.fov) / 2.0) / _camera.get_viewport().get_visible_rect().size.y
	var move := Vector3(-pixels.x, 0.0, -pixels.y / sin(deg_to_rad(_pitch))) * metres
	position = (position + move.rotated(Vector3.UP, rotation.y)).clamp(_bounds_min, _bounds_max)


func _set_distance(distance: float) -> void:
	_distance = clampf(distance, min_distance, max_distance)
	_update_camera()


func _set_pitch(pitch: float) -> void:
	_pitch = pitch
	_update_camera()


func _update_camera() -> void:
	var pitch := deg_to_rad(_pitch)
	_camera.position = Vector3(0.0, sin(pitch), cos(pitch)) * _distance
	_camera.rotation = Vector3(-pitch, 0.0, 0.0)
