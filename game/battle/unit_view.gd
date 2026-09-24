class_name UnitView
extends Node3D

const STEP_SECONDS := 0.12
const DOWNED_COLOR := Color(0.25, 0.25, 0.28)

var unit: Unit
var _material := StandardMaterial3D.new()
var _body := MeshInstance3D.new()
var _label := make_label(40, 1.55)
var _alert := make_label(96, 2.05)
var _flash: Tween


func setup(p_unit: Unit, at: Vector3) -> void:
	unit = p_unit
	position = at
	_material.albedo_color = unit.def.color
	_body.material_override = _material
	if unit.def.kind == UnitDef.Kind.TURRET:
		_build_turret()
	else:
		var capsule := CapsuleMesh.new()
		capsule.radius = 0.26
		capsule.height = 1.1
		_body.mesh = capsule
		_body.position.y = 0.55
	add_child(_body)
	add_child(_label)
	_alert.text = "!"
	_alert.modulate = Color(1.0, 0.85, 0.2)
	add_child(_alert)
	refresh()


func refresh() -> void:
	var status := "%d/%d" % [unit.hp, unit.def.max_hp]
	if unit.is_down():
		status = "down"
	elif unit.disabled:
		status = "offline"
		_material.albedo_color = DOWNED_COLOR
	_label.text = "%s\n%s" % [unit.display_name, status]
	_alert.text = "!" if unit.alerted else "?"
	_alert.visible = (unit.alerted or unit.searching) and not unit.is_down()


# shown[i] says whether the player can see the unit on points[i]; walking in the fog is instant.
func walk(points: Array[Vector3], shown: Array[bool] = []) -> void:
	if points.is_empty():
		return
	var tween := create_tween()
	var was_shown := visible
	for i in points.size():
		var is_shown: bool = shown.is_empty() or shown[i]
		if is_shown:
			tween.tween_callback(set_visible.bind(true))
		tween.tween_property(self, "position", points[i], STEP_SECONDS if is_shown or was_shown else 0.0)
		if not is_shown:
			tween.tween_callback(set_visible.bind(false))
		was_shown = is_shown
	await tween.finished


func lunge(toward: Vector3) -> void:
	var home := position
	var tween := create_tween()
	tween.tween_property(self, "position", home + (toward - home).normalized() * 0.3, 0.08)
	tween.tween_property(self, "position", home, 0.14)
	await tween.finished


func take_hit(damage: int) -> void:
	_material.albedo_color = Color.WHITE
	_flash = create_tween()
	_flash.tween_property(_material, "albedo_color", unit.def.color, 0.3)
	var number := make_label(56, 1.3)
	number.text = "-%d" % damage
	number.modulate = Color(1.0, 0.4, 0.35)
	add_child(number)
	var rise := create_tween()
	rise.tween_property(number, "position:y", 2.3, 0.7)
	rise.parallel().tween_property(number, "modulate:a", 0.0, 0.7)
	rise.tween_callback(number.queue_free)
	refresh()


func set_downed() -> void:
	if _flash:
		_flash.kill()
	_material.albedo_color = DOWNED_COLOR
	if unit.def.kind != UnitDef.Kind.TURRET:
		var tween := create_tween()
		tween.tween_property(_body, "rotation:z", PI / 2.0, 0.3)
		tween.parallel().tween_property(_body, "position:y", 0.28, 0.3)
	refresh()


func _build_turret() -> void:
	var base := CylinderMesh.new()
	base.top_radius = 0.32
	base.bottom_radius = 0.42
	base.height = 0.7
	_body.mesh = base
	_body.position.y = 0.35
	var barrel := MeshInstance3D.new()
	var barrel_mesh := BoxMesh.new()
	barrel_mesh.size = Vector3(0.14, 0.14, 0.6)
	barrel.mesh = barrel_mesh
	barrel.material_override = _material
	barrel.position = Vector3(0.0, 0.3, 0.3)
	_body.add_child(barrel)


static func make_label(font_size: int, height: float) -> Label3D:
	var label := Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = font_size
	label.outline_size = 12
	label.pixel_size = 0.006
	label.position.y = height
	return label
