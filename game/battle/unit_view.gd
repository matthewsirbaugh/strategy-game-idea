class_name UnitView
extends Node3D

const STEP_SECONDS := 0.12
const TURRET_HEIGHT := 1.3
# A skinned mesh's bounds don't track its height reliably, so people get a fixed one.
const PERSON_HEIGHT := 1.8
const DOWNED_TINT := Color(0.4, 0.4, 0.45)
const SHOT_SECONDS := 0.45

var unit: Unit
var _model := ToonModel.new()
var _label := make_label(40, 0.0)
var _alert := make_label(96, 0.0)
var _flash: Tween


# Must be in the tree first: the model is placed from world positions.
func setup(p_unit: Unit, at: Vector3) -> void:
	unit = p_unit
	position = at
	add_child(_model)
	_model.build(load(unit.def.model), load(unit.def.pack) if unit.def.pack else null)
	add_child(_ring(unit.def.color))
	var top := PERSON_HEIGHT
	if unit.def.kind == UnitDef.Kind.TURRET:
		_model.fit_height(TURRET_HEIGHT)
		top = TURRET_HEIGHT
	_label.position.y = top + 0.3
	_alert.position.y = top + 0.75
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
	_model.tint = DOWNED_TINT if unit.is_down() or unit.disabled else Color.WHITE
	_label.text = "%s\n%s" % [unit.display_name, status]
	_alert.text = "!" if unit.alerted else "?"
	_alert.visible = (unit.alerted or unit.searching) and not unit.is_down()


func set_cloaked(cloaked: bool) -> void:
	_model.set_cloaked(cloaked)


# shown[i] says whether the player can see the unit on points[i]; walking in the fog is instant.
func walk(points: Array[Vector3], shown: Array[bool] = []) -> void:
	if points.is_empty():
		return
	var tween := create_tween()
	var was_shown := visible
	var from := position
	_model.play("Run", GridView.CELL / STEP_SECONDS)
	for i in points.size():
		var is_shown: bool = shown.is_empty() or shown[i]
		if is_shown:
			tween.tween_callback(set_visible.bind(true))
		tween.tween_callback(_model.face.bind(points[i] - from))
		tween.tween_property(self, "position", points[i], STEP_SECONDS if is_shown or was_shown else 0.0)
		if not is_shown:
			tween.tween_callback(set_visible.bind(false))
		was_shown = is_shown
		from = points[i]
	await tween.finished
	if not unit.is_down():
		_model.play(_model.idle)


# The attack: characters draw and fire, a turret swings round and kicks back.
func lunge(toward: Vector3) -> void:
	_model.face(toward - position)
	if unit.def.kind == UnitDef.Kind.TURRET:
		var home := _model.position
		var tween := create_tween()
		tween.tween_property(_model, "position", home - (toward - position).normalized() * 0.15, 0.06)
		tween.tween_property(_model, "position", home, 0.16)
		await tween.finished
	else:
		_model.play("Cowboy_Quick_Draw_Shooting")
		await get_tree().create_timer(SHOT_SECONDS, false).timeout


func take_hit(damage: int) -> void:
	if _flash:
		_flash.kill()
	_model.flash = 0.8
	_flash = create_tween()
	_flash.tween_property(_model, "flash", 0.0, 0.3)
	if not unit.is_down():
		_model.play("Hit_Reaction")
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
	_model.flash = 0.0
	_model.idle = ""
	_model.play("Knock_Down")
	refresh()


# A ring on the floor in the unit's color, so who's who reads at a glance from any distance.
static func _ring(color: Color) -> MeshInstance3D:
	var torus := TorusMesh.new()
	torus.inner_radius = 0.42
	torus.outer_radius = 0.52
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	var ring := MeshInstance3D.new()
	ring.mesh = torus
	ring.material_override = material
	ring.scale = Vector3(1.0, 0.1, 1.0)
	ring.position.y = 0.03
	return ring


static func make_label(font_size: int, height: float) -> Label3D:
	var label := Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.font_size = font_size
	label.outline_size = 12
	# Same size on screen at any zoom.
	label.fixed_size = true
	label.pixel_size = 0.0003
	label.position.y = height
	return label
