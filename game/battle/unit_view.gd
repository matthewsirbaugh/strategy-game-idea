class_name UnitView
extends Node3D

const STEP_SECONDS := 0.12
const TURRET_HEIGHT := 1.3
# The turret is about this deep, so its own body never counts as hiding it.
const TURRET_DEPTH := 1.2
# A skinned mesh's bounds don't track its height reliably, so people get a fixed one.
const PERSON_HEIGHT := 1.8
const PERSON_DEPTH := 0.75
const DRONE_HOVER := 1.6
const OUT_TINT := Color(0.45, 0.45, 0.5)
const BREACHED_TINT := Color(0.55, 1.0, 0.7)
const SHOT_SECONDS := 0.45
const SILHOUETTE_ALPHA := 0.75
# An Operator's pack glows softly in its color, so the team reads on a dark street and lights the
# ground around it. Enemies carry none: a light would give them away in the fog.
const PACK_LIGHT_ENERGY := 1.8
const PACK_LIGHT_RANGE := 4.5
const ALERT_COLOR := Color(1.0, 0.35, 0.25)
const QUESTION_COLOR := Color(1.0, 0.85, 0.2)

var unit: Unit
var _model := ToonModel.new()
var _label := make_label(40, 0.0)
var _alert := make_label(96, 0.0)
var _flash: Tween
var _pack_light: OmniLight3D
var _lying := false


# Must be in the tree first: the model is placed from world positions.
func setup(p_unit: Unit, at: Vector3) -> void:
	unit = p_unit
	position = at
	add_child(_model)
	var top := PERSON_HEIGHT
	if unit.def.model != "":
		_model.build(load(unit.def.model), load(unit.def.pack) if unit.def.pack else null)
	else:
		_model.adopt(_robot_body(unit.def))
		top = DRONE_HOVER + 0.3 if unit.def.flies else 0.9
	add_child(_ring(unit.def.color))
	if unit.is_operator():
		_pack_light = OmniLight3D.new()
		_pack_light.light_color = unit.def.color
		_pack_light.omni_range = PACK_LIGHT_RANGE
		_pack_light.position = Vector3(0.0, 1.3, -0.3)
		add_child(_pack_light)
	_model.silhouette = Color(unit.def.color, SILHOUETTE_ALPHA)
	_model.hidden_by = PERSON_DEPTH
	if unit.is_turret():
		_model.fit_height(TURRET_HEIGHT)
		_model.hidden_by = TURRET_DEPTH
		top = TURRET_HEIGHT
	_label.position.y = top + 0.3
	_alert.position.y = top + 0.75
	add_child(_label)
	add_child(_alert)
	_model.face(Vector3(unit.facing.x, 0, unit.facing.y))


# Status, read from the rules: hits left, a stun or blindness counting down, alerts.
func refresh(state: BattleState) -> void:
	var lines: Array[String] = [unit.display_name]
	var status := ""
	if unit.is_operator():
		status = "DOWN" if unit.down else "■".repeat(unit.max_hits - unit.hits) + "□".repeat(unit.hits)
		if unit.overwatch:
			status += "   OVERWATCH"
		if unit.carrying >= 0:
			status += "   carrying " + state.units[unit.carrying].display_name
	elif unit.is_robot():
		status = "DOWN" if unit.down else ""
	elif unit.tied:
		status = "TIED UP"
	elif unit.stun > 0:
		status = "STUNNED %d" % unit.stun
	elif unit.blind > 0:
		status = "BLINDED %d" % unit.blind
	elif unit.is_turret() and unit.is_player():
		status = "BREACHED   " + ("TARGETING" if state.devices[unit.node].mode == "target" else "HOLDING")
	if unit.located > 0:
		status += "   LOCATED %d" % unit.located
	if status != "":
		lines.append(status)
	_label.text = "\n".join(lines)
	var out := unit.down or unit.is_body()
	_model.tint = OUT_TINT if out else BREACHED_TINT if unit.is_turret() and unit.is_player() else Color.WHITE
	if _pack_light:
		_pack_light.light_energy = 0.0 if unit.down else PACK_LIGHT_ENERGY
	var alerted := unit.task == Unit.Task.ALERTED
	_alert.text = "!" if alerted else "?"
	_alert.modulate = ALERT_COLOR if alerted else QUESTION_COLOR
	_alert.visible = not unit.is_player() and not out and unit.blind == 0 and unit.task != Unit.Task.PATROL
	_set_lying(unit.is_body() or (unit.down and unit.is_operator()))
	if not _lying and not unit.is_body():
		_model.face(Vector3(unit.facing.x, 0, unit.facing.y))
	if unit.is_robot() and unit.down:
		_model.rotation.z = PI / 2.0


func _set_lying(lying: bool) -> void:
	if lying == _lying or not _model.player:
		_lying = lying
		return
	_lying = lying
	if lying:
		_model.idle = ""
		_model.play("Knock_Down")
	else:
		_model.idle = "Neutral"
		_model.play("Neutral")


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
	if not _lying:
		_model.play(_model.idle)


# The shot: characters draw and fire, a turret swings round and kicks back.
func fire_at(toward: Vector3) -> void:
	_model.face(toward - position)
	if unit.is_turret() or not _model.player:
		var home := _model.position
		var tween := create_tween()
		tween.tween_property(_model, "position", home - (toward - position).normalized() * 0.15, 0.06)
		tween.tween_property(_model, "position", home, 0.16)
		await tween.finished
	else:
		_model.play("Cowboy_Quick_Draw_Shooting")
		await get_tree().create_timer(SHOT_SECONDS, false).timeout


func take_hit(text: String) -> void:
	if _flash:
		_flash.kill()
	_model.flash = 0.8
	_flash = create_tween()
	_flash.tween_property(_model, "flash", 0.0, 0.3)
	if not _lying and _model.player:
		_model.play("Hit_Reaction")
	var number := make_label(56, PERSON_HEIGHT)
	number.text = text
	number.modulate = Color(1.0, 0.55, 0.4)
	add_child(number)
	var rise := create_tween()
	rise.tween_property(number, "position:y", PERSON_HEIGHT + 0.8, 0.9)
	rise.parallel().tween_property(number, "modulate:a", 0.0, 0.9)
	rise.tween_callback(number.queue_free)


# Stand-ins until the robots have models: a quadcopter that hovers, and a boxy four-legged bot.
static func _robot_body(def: UnitDef) -> Node3D:
	var body := Node3D.new()
	var shell := ToonModel.flat(def.color.darkened(0.35))
	var trim := ToonModel.flat(def.color)
	var dark := ToonModel.flat(Color(0.08, 0.09, 0.1))
	if def.flies:
		_part(body, _box(Vector3(0.45, 0.14, 0.45)), shell, Vector3(0, DRONE_HOVER, 0))
		for corner in [Vector3(1, 0, 1), Vector3(-1, 0, 1), Vector3(1, 0, -1), Vector3(-1, 0, -1)]:
			_part(body, _box(Vector3(0.36, 0.04, 0.06)), dark, Vector3(0, DRONE_HOVER, 0) + corner * 0.16).rotation.y = atan2(corner.x, corner.z)
			var rotor := CylinderMesh.new()
			rotor.top_radius = 0.16
			rotor.bottom_radius = 0.16
			rotor.height = 0.02
			_part(body, rotor, trim, Vector3(0, DRONE_HOVER + 0.06, 0) + corner * 0.3)
		_part(body, _box(Vector3(0.12, 0.1, 0.1)), trim, Vector3(0, DRONE_HOVER - 0.1, 0.2))
	else:
		_part(body, _box(Vector3(0.42, 0.32, 0.85)), shell, Vector3(0, 0.62, 0))
		_part(body, _box(Vector3(0.3, 0.26, 0.32)), trim, Vector3(0, 0.82, 0.52))
		for corner in [Vector3(1, 0, 1), Vector3(-1, 0, 1), Vector3(1, 0, -1), Vector3(-1, 0, -1)]:
			_part(body, _box(Vector3(0.09, 0.48, 0.09)), dark, Vector3(corner.x * 0.17, 0.24, corner.z * 0.32))
	return body


static func _box(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh


static func _part(body: Node3D, mesh: Mesh, material: Material, at: Vector3) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.set_surface_override_material(0, material)
	part.position = at
	body.add_child(part)
	return part


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
	label.font = preload("res://art/fonts/BarlowCondensed-SemiBold.ttf")
	label.font_size = font_size
	label.outline_size = 6
	label.modulate = Color(0.93, 0.95, 0.89)
	label.outline_modulate = Color(0.025, 0.04, 0.05)
	# Same size on screen at any zoom.
	label.fixed_size = true
	label.pixel_size = 0.0003
	label.position.y = height
	return label
