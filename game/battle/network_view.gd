class_name NetworkView
extends Node3D

# The network as its own layer. When shown, the backdrop blurs and blue-washes the physical map,
# and everything here draws on top of it. Depth testing is off, so render priority alone sets the
# draw order within the layer.

enum Order { BACKDROP = 1, LINK, RIM, DISC, RING, AGENT_RIM, AGENT, LABEL_OUTLINE, LABEL }

const BACKDROP_SHADER := preload("res://battle/network_backdrop.gdshader")
const FLOOR_Y := 0.08
const AGENT_Y := 0.3
const HOP_SECONDS := 0.15
const INK := Color(0.07, 0.13, 0.3)
const REACHABLE := Color(0.1, 0.45, 1.0)
const CURRENT := Color(1.0, 1.0, 1.0)
const BREACHED := Color(0.25, 0.85, 0.45)

var _state: BattleState
var _grid: GridView
var _nodes := {}
var _agents := {}


func build(state: BattleState, grid: GridView) -> void:
	_state = state
	_grid = grid
	add_child(_make_backdrop())
	for link in state.map.links:
		var ends := link.split("-")
		var beam := GridView.make_beam(0.07, Color(INK, 0.85))
		_draw_on_top(beam.material_override, Order.LINK)
		add_child(beam)
		GridView.place_beam(beam, node_position(ends[0]), node_position(ends[1]))
	for id in state.map.node_ids():
		_build_node(id)
	for unit in state.units:
		if unit.is_player():
			_agents[unit.id] = _build_agent(unit)
	visible = false
	refresh()


func node_position(id: String) -> Vector3:
	return _grid.cell_to_world(_state.map.node_cell(id)) + Vector3(0, FLOOR_Y, 0)


func refresh() -> void:
	for id in _nodes:
		var part: Dictionary = _nodes[id]
		var def := _state.node_def(id)
		var kind := _state.map.node_kind(id)
		var label: Label3D = part["label"]
		var disc: StandardMaterial3D = part["disc"]
		label.text = def.display_name
		if _state.breached.has(id):
			label.text += "\n" + _status(id, kind)
			disc.albedo_color = BREACHED
		else:
			disc.albedo_color = GridView.NODE_COLORS[kind]
			if def.goal > 0:
				label.text += "\n%d/%d" % [_state.breach.get(id, 0), def.goal]
	for id in _agents:
		var unit: Unit = _state.units[id]
		var agent: Node3D = _agents[id]
		agent.visible = unit.agent_node != ""
		if agent.visible:
			agent.position = _agent_position(unit, unit.agent_node)


func highlight(reachable: Array, current: String) -> void:
	for id in _nodes:
		var ring: MeshInstance3D = _nodes[id]["ring"]
		ring.visible = id == current or reachable.has(id)
		var material: StandardMaterial3D = ring.material_override
		material.albedo_color = CURRENT if id == current else REACHABLE


func move_agent(unit: Unit, path: Array) -> void:
	var agent: Node3D = _agents[unit.id]
	var tween := create_tween()
	for id in path:
		tween.tween_property(agent, "position", _agent_position(unit, id), HOP_SECONDS)
	await tween.finished


func _build_node(id: String) -> void:
	var at := node_position(id)
	_add_disc(at, 0.4, INK, Order.RIM)
	var disc := _add_disc(at, 0.32, GridView.NODE_COLORS[_state.map.node_kind(id)], Order.DISC)
	var torus := TorusMesh.new()
	torus.inner_radius = 0.46
	torus.outer_radius = 0.56
	var ring := MeshInstance3D.new()
	ring.mesh = torus
	ring.material_override = _material(CURRENT, Order.RING)
	ring.position = at
	ring.visible = false
	add_child(ring)
	var label := Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.render_priority = Order.LABEL
	label.outline_render_priority = Order.LABEL_OUTLINE
	label.font_size = 44
	label.outline_size = 16
	label.pixel_size = 0.006
	label.modulate = INK
	label.outline_modulate = Color.WHITE
	label.position = at + Vector3(0, 0.95, 0)
	add_child(label)
	_nodes[id] = {"disc": disc, "ring": ring, "label": label}


func _build_agent(unit: Unit) -> Node3D:
	var agent := Node3D.new()
	agent.add_child(_sphere(0.3, Color.WHITE, Order.AGENT_RIM))
	agent.add_child(_sphere(0.24, unit.def.color, Order.AGENT))
	agent.visible = false
	add_child(agent)
	return agent


# Centered on the node, or side by side when several AIs share it.
func _agent_position(unit: Unit, id: String) -> Vector3:
	var sharing: Array[int] = []
	for other in _state.units:
		if other.is_player() and other.agent_node == id:
			sharing.append(other.id)
	var offset := 0.0
	if sharing.has(unit.id):
		offset = (sharing.find(unit.id) - (sharing.size() - 1) / 2.0) * 0.45
	return node_position(id) + Vector3(offset, AGENT_Y, 0)


func _add_disc(at: Vector3, radius: float, color: Color, order: int) -> StandardMaterial3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.02
	var material := _material(color, order)
	var disc := MeshInstance3D.new()
	disc.mesh = mesh
	disc.material_override = material
	disc.position = at
	add_child(disc)
	return material


func _sphere(radius: float, color: Color, order: int) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var sphere := MeshInstance3D.new()
	sphere.mesh = mesh
	sphere.material_override = _material(color, order)
	return sphere


func _make_backdrop() -> MeshInstance3D:
	var quad := QuadMesh.new()
	quad.size = Vector2(2, 2)
	var material := ShaderMaterial.new()
	material.shader = BACKDROP_SHADER
	material.render_priority = Order.BACKDROP
	var backdrop := MeshInstance3D.new()
	backdrop.mesh = quad
	backdrop.material_override = material
	# The shader places the quad over the whole screen, so it must never be frustum-culled.
	backdrop.extra_cull_margin = 16384.0
	return backdrop


func _status(id: String, kind: String) -> String:
	match kind:
		"door":
			return "open" if _state.is_door_open(id) else "locked"
		"camera":
			return "yours"
		"turret":
			return "offline"
		"cache":
			return "secured"
	return ""


static func _material(color: Color, order: int) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	_draw_on_top(material, order)
	return material


static func _draw_on_top(material: StandardMaterial3D, order: int) -> void:
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = true
	material.render_priority = order
