class_name NetworkView
extends Node3D

# The topology stays aligned with the physical devices beneath it. A network stays hidden until an
# AI first connects to it; access points always show, since they're panels on the map. Lines from
# a power hub run to every device on its circuit. Render priority keeps the diagram readable
# through world geometry without changing picking or network rules. The team and the enemies the
# team can see show as flat markers on their tiles, under the network. Each AI is a pin standing on
# top of its node, in its Operator's color, so the node itself stays in view.

enum Order { BACKDROP = 1, MARKER, MARKER_TEXT, CIRCUIT, LINK, PACKET, RIM, DISC, RING, ICON, AGENT_RIM, AGENT, LABEL_OUTLINE, LABEL }

const BACKDROP_SHADER := preload("res://battle/network_backdrop.gdshader")
const FLOOR_Y := 0.08
const AGENT_Y := 0.3
const PIN_BODY := preload("res://art/ui/ai_pin_body.svg")
const PIN_EDGE := preload("res://art/ui/ai_pin_edge.svg")
const PIN_PIXEL := 0.0095
# Screen-up distances in world units: from a node's center to its pins' tips, and to their heads.
# The texture's tip sits 82 pixels below its center and the head's center 24 above.
const PIN_TIP := 0.8
const PIN_HEAD := PIN_TIP + (82 + 24) * PIN_PIXEL
const PIN_HEAD_RADIUS := 0.42
const PIN_SPACING := 0.82
const PIN_BOB := 4.0
# Half a node's footprint for laying out labels, and the gap between it and its label, in world
# units. The footprint is a square, so it's a little inside the round rim.
const NODE_EXTENT := 0.68
const LABEL_GAP := 0.25
const HOP_SECONDS := 0.15
const INK := Color(0.035, 0.075, 0.095)
const LINK_COLOR := Color(0.24, 0.5, 0.55)
const REACHABLE := Color(0.4, 0.87, 0.9)
const CURRENT := Color(1.0, 0.94, 0.76)
const BREACHED := Color(0.45, 0.93, 0.68)
const CIRCUIT := Color(1.0, 0.68, 0.28)
const UNPOWERED := 0.45
# The enemy is clean white and black, with red kept for danger alone, like Nothing's design.
const ENEMY := Color(0.94, 0.95, 0.96)
const ALERTED := Color(0.92, 0.12, 0.14)
const MARKER_RADIUS := 0.48
const FONT := preload("res://art/fonts/BarlowCondensed-SemiBold.ttf")
const ICONS := {
	"access": preload("res://art/ui/access.svg"),
	"door": preload("res://art/ui/door.svg"),
	"autodoor": preload("res://art/ui/door.svg"),
	"camera": preload("res://art/ui/camera.svg"),
	"nvcamera": preload("res://art/ui/camera.svg"),
	"turret": preload("res://art/ui/turret.svg"),
	"cache": preload("res://art/ui/cache.svg"),
	"light": preload("res://art/ui/light.svg"),
	"phone": preload("res://art/ui/phone.svg"),
	"machine": preload("res://art/ui/machine.svg"),
	"adscreen": preload("res://art/ui/adscreen.svg"),
	"car": preload("res://art/ui/car.svg"),
	"truck": preload("res://art/ui/truck.svg"),
	"hub": preload("res://art/ui/hub.svg"),
}
const COLORS := {
	"access": Color(0.4, 0.84, 0.88),
	"door": Color(0.95, 0.68, 0.42),
	"autodoor": Color(0.95, 0.68, 0.42),
	"camera": Color(0.68, 0.71, 0.96),
	"nvcamera": Color(0.6, 0.95, 0.7),
	"turret": Color(1.0, 0.46, 0.36),
	"cache": Color(0.98, 0.84, 0.48),
	"light": Color(1.0, 0.9, 0.62),
	"phone": Color(0.75, 0.86, 0.95),
	"machine": Color(0.8, 0.85, 0.6),
	"adscreen": Color(0.35, 0.9, 0.95),
	"car": Color(0.55, 0.85, 0.9),
	"truck": Color(0.95, 0.65, 0.4),
	"hub": Color(1.0, 0.72, 0.3),
}

# The fade in: the network appears over the still-sharp map, holds so it can be seen lining up,
# then the map blurs away behind it.
@export var fade_seconds := 0.35
@export var lineup_seconds := 0.35

var _state: BattleState
var _grid: GridView
var _nodes := {}
var _agents := {}
var _markers := {}
var _fading: Array[Array] = []
var _labels: Array[Label3D] = []
var _backdrop: ShaderMaterial
var _icons: Array[Sprite3D] = []
# Pin sprites with the opacity each fades back up to.
var _pins: Array[Array] = []
var _links: Array[Dictionary] = []
var _circuits: Array[Dictionary] = []
var _diagram_environment: Environment
var _previous_environment: Environment


func build(state: BattleState, grid: GridView) -> void:
	_state = state
	_grid = grid
	_diagram_environment = get_world_3d().environment.duplicate()
	_diagram_environment.fog_enabled = false
	_diagram_environment.volumetric_fog_enabled = false
	_diagram_environment.glow_enabled = false
	_diagram_environment.adjustment_enabled = false
	_diagram_environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	add_child(_make_backdrop())
	for link in state.map.links:
		var beam := GridView.make_beam(0.035, Color(LINK_COLOR, 0.7))
		_draw_on_top(beam.material_override, Order.LINK)
		_fading.append([beam.material_override, 0.7])
		add_child(beam)
		var packet := _sphere(0.065, Color(0.48, 0.86, 0.86, 0.85), Order.PACKET)
		add_child(packet)
		_links.append({"ends": link.split("-"), "beam": beam, "packet": packet})
	for hub in state.map.circuits:
		for member in state.map.circuit(hub):
			var wire := GridView.make_beam(0.025, Color(CIRCUIT, 0.55))
			_draw_on_top(wire.material_override, Order.CIRCUIT)
			_fading.append([wire.material_override, 0.55])
			add_child(wire)
			_circuits.append({"hub": hub, "member": member, "beam": wire})
	for id in state.map.node_ids():
		_build_node(id)
	for unit in state.operators():
		_agents[unit.id] = _build_agent(unit)
	visible = false
	refresh()


func fade_in() -> void:
	_set_opacity(0.0)
	_set_backdrop(0.0)
	visible = true
	refresh()
	var tween := create_tween()
	tween.tween_method(_set_opacity, 0.0, 1.0, fade_seconds)
	tween.tween_interval(lineup_seconds)
	tween.tween_method(_set_backdrop, 0.0, 1.0, fade_seconds)
	tween.tween_callback(func() -> void:
		var camera := get_viewport().get_camera_3d()
		_previous_environment = camera.environment
		camera.environment = _diagram_environment
	)
	await tween.finished


func fade_out() -> void:
	get_viewport().get_camera_3d().environment = _previous_environment
	var tween := create_tween()
	tween.tween_method(_set_backdrop, 1.0, 0.0, fade_seconds)
	tween.tween_method(_set_opacity, 1.0, 0.0, fade_seconds * 0.7)
	await tween.finished
	visible = false


func node_position(id: String) -> Vector3:
	return _grid.cell_to_world(_state.node_cell(id)) + Vector3(0, FLOOR_Y, 0)


# Where the AI's pin head is drawn: above its node on screen, beside any pins that share it.
func agent_position(unit: Unit) -> Vector3:
	var agent: Node3D = _agents[unit.id]
	var basis := get_viewport().get_camera_3d().global_basis
	return agent.position + basis.x * float(agent.get_meta("slot", 0.0)) * PIN_SPACING + basis.y * PIN_HEAD


# Where an AI's pin stands among the pins sharing its node, in pin widths from the middle.
func pin_slot(unit: Unit) -> float:
	return _agents[unit.id].get_meta("slot", 0.0)


# Access points always show; anything else only once its network is known.
func is_shown(id: String) -> bool:
	return _state.map.node_kind(id) == "access" or _state.revealed_networks.has(_state.map.network_of(id))


# The shown nodes and the active unit, whose menu opens beside it.
func framing_bounds() -> Rect2:
	var bounds := Rect2(Vector2(_grid.center().x, _grid.center().z), Vector2.ZERO)
	var points: Array[Vector3] = []
	for id in _nodes:
		if is_shown(id):
			points.append(node_position(id))
	if _state.active and _state.active.on_map():
		points.append(_grid.cell_to_world(_state.active.cell))
	for at in points:
		bounds = bounds.expand(Vector2(at.x, at.z))
	# Extra room at the bottom, under the Operator's panel.
	return bounds.grow_individual(1.6, 1.6 + PIN_HEAD, 1.6, 7.0)


func refresh() -> void:
	for id in _nodes:
		_refresh_node(id)
	for link in _links:
		var shown: bool = is_shown(link.ends[0]) and is_shown(link.ends[1])
		link.beam.visible = shown
		link.packet.visible = shown
		link.from = node_position(link.ends[0])
		link.to = node_position(link.ends[1])
		if shown:
			GridView.place_beam(link.beam, link.from, link.to)
	for wire in _circuits:
		var shown := is_shown(wire.hub)
		GridView.place_beam(wire.beam, node_position(wire.hub), node_position(wire.member))
		wire.beam.visible = shown and wire.beam.visible
	for unit in _state.units:
		_refresh_marker(unit)
	var sharing := {}
	for id in _agents:
		var unit: Unit = _state.units[id]
		if unit.connected():
			sharing[unit.ai_node] = sharing.get(unit.ai_node, []) + [id]
	for id in _agents:
		var unit: Unit = _state.units[id]
		var agent: Node3D = _agents[id]
		agent.visible = unit.connected()
		if agent.visible:
			var group: Array = sharing[unit.ai_node]
			agent.position = node_position(unit.ai_node) + Vector3(0, AGENT_Y, 0)
			agent.set_meta("slot", group.find(id) - (group.size() - 1) / 2.0)
	_place_labels()


func _refresh_node(id: String) -> void:
	var part: Dictionary = _nodes[id]
	var shown := is_shown(id)
	for piece: Node3D in part.pieces:
		piece.visible = shown
		piece.position = node_position(id) + part.offsets[piece]
	if not shown:
		return
	var def := _state.node_def(id)
	var kind := _state.map.node_kind(id)
	var device: Dictionary = _state.devices[id]
	var label: Label3D = part["label"]
	var color: Color = COLORS[kind]
	label.text = "%s / %s" % [id.to_upper(), def.display_name.to_upper()]
	var status := status(_state, id)
	if _state.breached.has(id):
		color = BREACHED
	elif def.goal > 0:
		status = ("%s   " % status if status != "" else "") + "%d / %d" % [_state.progress.get(id, 0), def.goal]
	else:
		status = "ENTRY"
	if status != "":
		label.text += "\n" + status
	if def.verbs.has("power") and not device.powered:
		color = color.darkened(1.0 - UNPOWERED)
	var rim: StandardMaterial3D = part["rim"]
	rim.albedo_color = Color(color, rim.albedo_color.a)
	var icon: Sprite3D = part["icon"]
	icon.modulate = Color(color, icon.modulate.a)
	var progress := 1.0 if _state.breached.has(id) else float(_state.progress.get(id, 0)) / maxf(def.goal, 1)
	if part["progress_value"] != progress:
		part["progress"].mesh = _arc_mesh(progress)
		part["progress_value"] = progress


# Robots and units deployed mid-battle get their marker the first time they show.
func _refresh_marker(unit: Unit) -> void:
	var shown := unit.on_map() and not unit.is_turret() and (unit.is_player() or _state.player_sees(unit))
	if not shown:
		if _markers.has(unit.id):
			_markers[unit.id].visible = false
		return
	if not _markers.has(unit.id):
		_markers[unit.id] = _build_marker(unit)
	var marker: Node3D = _markers[unit.id]
	marker.visible = true
	marker.position = _grid.cell_to_world(unit.cell) + Vector3(0, FLOOR_Y * 0.5, 0)
	if not unit.is_player():
		var fill: StandardMaterial3D = marker.get_meta("fill")
		var alerted := unit.task == Unit.Task.ALERTED and not unit.down and unit.stun <= 0
		fill.albedo_color = Color(ALERTED if alerted else ENEMY, fill.albedo_color.a)


# A disc with the initial for the team, a diamond for an enemy.
func _build_marker(unit: Unit) -> Node3D:
	var marker := Node3D.new()
	var shape: MeshInstance3D
	var color: Color
	if unit.is_player():
		color = unit.def.color.lightened(0.25)
		var disc := CylinderMesh.new()
		disc.top_radius = MARKER_RADIUS
		disc.bottom_radius = MARKER_RADIUS
		disc.height = 0.01
		shape = MeshInstance3D.new()
		shape.mesh = disc
	else:
		color = ENEMY
		var plane := PlaneMesh.new()
		plane.size = Vector2.ONE * MARKER_RADIUS * 1.5
		shape = MeshInstance3D.new()
		shape.mesh = plane
		shape.rotation.y = PI / 4.0
	shape.material_override = _ink(Color(color, 0.85), Order.MARKER)
	marker.set_meta("fill", shape.material_override)
	marker.add_child(shape)
	var initial := Label3D.new()
	initial.text = unit.display_name.get_slice(" ", 1)
	if unit.is_operator():
		initial.text = unit.display_name.left(1)
	elif unit.is_robot():
		initial.text = unit.def.display_name.left(1)
	initial.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	initial.no_depth_test = true
	initial.render_priority = Order.MARKER_TEXT
	initial.font = FONT
	initial.font_size = 64
	initial.pixel_size = 0.0095
	initial.modulate = INK
	initial.outline_size = 0
	initial.position.y = 0.05
	marker.add_child(initial)
	_labels.append(initial)
	add_child(marker)
	return marker


# Lays the labels out so none covers another label, a node or a unit's marker: under the node where
# there's room, else beside it, then at a corner, else further down. The view looks straight down with north up, so a label's footprint
# on the floor is its footprint on screen.
func _place_labels() -> void:
	var shown: Array = _nodes.keys().filter(is_shown)
	shown.sort_custom(func(a: String, b: String) -> bool:
		var first := node_position(a)
		var second := node_position(b)
		return first.z < second.z or (first.z == second.z and first.x < second.x))
	var taken: Array[Rect2] = []
	for id in shown:
		var at := node_position(id)
		taken.append(Rect2(at.x - NODE_EXTENT, at.z - NODE_EXTENT, NODE_EXTENT * 2.0, NODE_EXTENT * 2.0))
	for marker: Node3D in _markers.values():
		if marker.visible:
			taken.append(Rect2(marker.position.x - MARKER_RADIUS, marker.position.z - MARKER_RADIUS, MARKER_RADIUS * 2.0, MARKER_RADIUS * 2.0))
	var near := NODE_EXTENT + LABEL_GAP
	for id in shown:
		var label: Label3D = _nodes[id]["label"]
		var size := _label_size(label)
		var at := node_position(id)
		var corner := near * 0.75
		var spots := [
			[Vector2(0, near), HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_TOP, Rect2(at.x - size.x / 2.0, at.z + near, size.x, size.y)],
			[Vector2(near, 0), HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, Rect2(at.x + near, at.z - size.y / 2.0, size.x, size.y)],
			[Vector2(-near, 0), HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_CENTER, Rect2(at.x - near - size.x, at.z - size.y / 2.0, size.x, size.y)],
			[Vector2(corner, corner), HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_TOP, Rect2(at.x + corner, at.z + corner, size.x, size.y)],
			[Vector2(-corner, corner), HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_TOP, Rect2(at.x - corner - size.x, at.z + corner, size.x, size.y)],
			[Vector2(corner, -corner), HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_BOTTOM, Rect2(at.x + corner, at.z - corner - size.y, size.x, size.y)],
			[Vector2(-corner, -corner), HORIZONTAL_ALIGNMENT_RIGHT, VERTICAL_ALIGNMENT_BOTTOM, Rect2(at.x - corner - size.x, at.z - corner - size.y, size.x, size.y)],
		]
		for row in range(1, 4):
			var drop := near + row * (size.y + LABEL_GAP)
			spots.append([Vector2(0, drop), HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_TOP, Rect2(at.x - size.x / 2.0, at.z + drop, size.x, size.y)])
		var pick: Array = spots.back()
		for spot: Array in spots:
			var rect: Rect2 = spot[3].grow(-0.05)
			if not taken.any(func(other: Rect2) -> bool: return other.intersects(rect)):
				pick = spot
				break
		label.horizontal_alignment = pick[1]
		label.vertical_alignment = pick[2]
		label.offset = Vector2(pick[0].x, -pick[0].y) / label.pixel_size
		taken.append(pick[3])


# A label's footprint, in world units.
func _label_size(label: Label3D) -> Vector2:
	var lines := label.text.split("\n")
	var width := 0.0
	for line in lines:
		width = maxf(width, FONT.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, label.font_size).x)
	var height := lines.size() * FONT.get_height(label.font_size)
	return (Vector2(width, height) + Vector2.ONE * label.outline_size * 2.0) * label.pixel_size


func highlight(reachable: Array, current: String) -> void:
	for id in _nodes:
		var ring: MeshInstance3D = _nodes[id]["ring"]
		ring.visible = is_shown(id) and (id == current or reachable.has(id))
		ring.position = node_position(id)
		var material: StandardMaterial3D = ring.material_override
		material.albedo_color = Color(CURRENT if id == current else REACHABLE, material.albedo_color.a)
	for link in _links:
		var emphasized: bool = (link.ends[0] == current or reachable.has(link.ends[0])) and (link.ends[1] == current or reachable.has(link.ends[1]))
		var material: StandardMaterial3D = link.beam.material_override
		material.albedo_color = Color(REACHABLE if emphasized else LINK_COLOR, material.albedo_color.a)


func _process(_delta: float) -> void:
	if not visible:
		return
	var clock := Time.get_ticks_msec() / 1000.0
	for id in _agents:
		pose_pin(_agents[id], pin_slot(_state.units[id]), PIN_TIP, _state.active and _state.active.id == id)
	for i in _links.size():
		var link: Dictionary = _links[i]
		var length: float = maxf(link.from.distance_to(link.to), 0.01)
		link.packet.position = link.from.lerp(link.to, fposmod(clock * 1.8 + i * 2.1, length) / length)


# Hit-tests the pins' heads where they're drawn, which depends on which way the camera faces.
func agent_at(ray_origin: Vector3, ray_normal: Vector3) -> Unit:
	var best: Unit = null
	var best_depth := INF
	for id in _agents:
		if not _agents[id].is_visible_in_tree():
			continue
		var head := agent_position(_state.units[id])
		var depth := (head - ray_origin).dot(ray_normal)
		if depth < 0.0:
			continue
		if head.distance_to(ray_origin + ray_normal * depth) <= PIN_HEAD_RADIUS and depth < best_depth:
			best = _state.units[id]
			best_depth = depth
	return best


func move_agent(unit: Unit, path: Array) -> void:
	var agent: Node3D = _agents[unit.id]
	agent.visible = true
	var tween := create_tween()
	for id in path:
		tween.tween_property(agent, "position", node_position(id) + Vector3(0, AGENT_Y, 0), HOP_SECONDS)
	await tween.finished


func _build_node(id: String) -> void:
	var at := node_position(id)
	var kind := _state.map.node_kind(id)
	var rim := _add_disc(0.73, COLORS[kind], Order.RIM)
	var disc := _add_disc(0.66, INK, Order.DISC)
	var progress := MeshInstance3D.new()
	progress.material_override = _ink(BREACHED, Order.RING)
	add_child(progress)
	var torus := TorusMesh.new()
	torus.inner_radius = 0.91
	torus.outer_radius = 0.98
	var ring := MeshInstance3D.new()
	ring.mesh = torus
	ring.material_override = _ink(CURRENT, Order.RING)
	ring.position = at
	ring.visible = false
	add_child(ring)
	var icon := Sprite3D.new()
	icon.texture = ICONS[kind]
	icon.pixel_size = 0.018
	icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	icon.no_depth_test = true
	icon.render_priority = Order.ICON
	icon.modulate = COLORS[kind]
	add_child(icon)
	_icons.append(icon)
	var label := Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.render_priority = Order.LABEL
	label.outline_render_priority = Order.LABEL_OUTLINE
	label.font = FONT
	label.font_size = 38
	label.outline_size = 5
	label.pixel_size = 0.015
	label.modulate = Color(0.88, 0.95, 0.91)
	label.outline_modulate = INK
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	add_child(label)
	_labels.append(label)
	var offsets := {rim: Vector3.ZERO, disc: Vector3.ZERO, progress: Vector3.ZERO, icon: Vector3(0, 0.025, 0), label: Vector3.ZERO}
	_nodes[id] = {"rim": rim.material_override, "ring": ring, "label": label, "icon": icon, "progress": progress, "progress_value": -1.0,
		"pieces": offsets.keys(), "offsets": offsets}


func _arc_mesh(fill: float) -> ImmediateMesh:
	var mesh := ImmediateMesh.new()
	if fill <= 0.0:
		return mesh
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	var steps := maxi(1, ceili(fill * 48))
	for i in steps:
		var start := -PI / 2.0 + TAU * fill * float(i) / steps
		var end := -PI / 2.0 + TAU * fill * float(i + 1) / steps
		var a := Vector3(cos(start), 0, sin(start))
		var b := Vector3(cos(end), 0, sin(end))
		for vertex in [a * 0.77, b * 0.77, a * 0.84, a * 0.84, b * 0.77, b * 0.84]:
			mesh.surface_add_vertex(vertex)
	mesh.surface_end()
	return mesh


func _build_agent(unit: Unit) -> Node3D:
	var agent := make_pin(unit)
	for sprite: Sprite3D in agent.get_children():
		_pins.append([sprite, sprite.modulate.a])
	agent.visible = false
	add_child(agent)
	return agent


# A pin in the Operator's color: a dark body under a colored rim and the AI's glyph, with a flat
# shadow behind for depth. Billboarded, so it stands upright on screen whichever way the camera turns.
# The physical view stands one over the AI's device too.
static func make_pin(unit: Unit) -> Node3D:
	var pin := Node3D.new()
	var layers := [[PIN_BODY, Color(0, 0, 0, 0.45), Order.AGENT_RIM, Vector2(3, -4)], [PIN_BODY, INK, Order.AGENT_RIM, Vector2.ZERO],
		[PIN_EDGE, unit.def.color, Order.AGENT, Vector2.ZERO]]
	for layer in layers:
		var sprite := Sprite3D.new()
		sprite.texture = layer[0]
		sprite.modulate = layer[1]
		sprite.render_priority = layer[2]
		sprite.set_meta("shift", layer[3])
		sprite.pixel_size = PIN_PIXEL
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sprite.no_depth_test = true
		pin.add_child(sprite)
	return pin


# Stands the pin's tip `tip` world units above its origin on screen, `slot` pin widths aside. The
# active AI's pin bobs.
static func pose_pin(pin: Node3D, slot: float, tip: float, bobbing: bool) -> void:
	var bob := PIN_BOB * sin(Time.get_ticks_msec() / 1000.0 * 3.0) if bobbing else 0.0
	for sprite: Sprite3D in pin.get_children():
		sprite.offset = Vector2(slot * PIN_SPACING / PIN_PIXEL, tip / PIN_PIXEL + 82.0 + bob) + sprite.get_meta("shift", Vector2.ZERO)


func _add_disc(radius: float, color: Color, order: int) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.02
	var disc := MeshInstance3D.new()
	disc.mesh = mesh
	disc.material_override = _ink(color, order)
	add_child(disc)
	return disc


func _sphere(radius: float, color: Color, order: int) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	var sphere := MeshInstance3D.new()
	sphere.mesh = mesh
	sphere.material_override = _ink(color, order)
	return sphere


func _make_backdrop() -> MeshInstance3D:
	var quad := QuadMesh.new()
	quad.size = Vector2(2, 2)
	_backdrop = ShaderMaterial.new()
	_backdrop.shader = BACKDROP_SHADER
	_backdrop.render_priority = Order.BACKDROP
	var backdrop := MeshInstance3D.new()
	backdrop.mesh = quad
	backdrop.material_override = _backdrop
	# The shader places the quad over the whole screen, so it must never be frustum-culled.
	backdrop.extra_cull_margin = 16384.0
	return backdrop


func _set_opacity(amount: float) -> void:
	for entry in _fading:
		var material: StandardMaterial3D = entry[0]
		material.albedo_color.a = entry[1] * amount
	for icon in _icons:
		icon.modulate.a = amount
	for pin in _pins:
		pin[0].modulate.a = pin[1] * amount
	for label in _labels:
		label.modulate.a = amount
		label.outline_modulate.a = amount


func _set_backdrop(amount: float) -> void:
	_backdrop.set_shader_parameter("amount", amount)


static func status(state: BattleState, id: String) -> String:
	var device: Dictionary = state.devices[id]
	var words: Array[String] = []
	match state.map.node_kind(id):
		"door", "autodoor":
			words.append("OPEN" if device.open else "SHUT")
			if device.locked:
				words.append("LOCKED")
		"turret":
			if state.breached.has(id):
				words.append("TARGETING" if device.mode == "target" else "HOLDING")
		"cache":
			if state.breached.has(id):
				words.append("SECURED")
	if state.node_def(id).verbs.has("power") and state.map.node_kind(id) not in NodeDef.DOORS:
		words.push_front("ON" if device.powered else "OFF")
	return "   ".join(words)


func _ink(color: Color, order: int) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	_draw_on_top(material, order)
	_fading.append([material, color.a])
	return material


static func _draw_on_top(material: StandardMaterial3D, order: int) -> void:
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.no_depth_test = true
	material.disable_fog = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.render_priority = order
