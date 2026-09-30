class_name Signs
extends Node3D
## Signs painted on the level: slogans stenciled on walls, graffiti, neon, and paint on the road.
## Each sign's art is drawn once, with a font or the corporation's emblem, into a texture that
## sign.gdshader lays on the surface. The slogans are the ones on the approved concept art.

const SHADER := preload("res://art/shaders/sign.gdshader")
const BOLD := preload("res://art/fonts/BarlowCondensed-Bold.ttf")
const SEMIBOLD := preload("res://art/fonts/BarlowCondensed-SemiBold.ttf")
const MARKER := preload("res://art/fonts/PermanentMarker-Regular.ttf")
const NEON := Color(1.0, 0.42, 0.22)
const PIXELS_PER_METRE := 320.0
const MAX_PIXELS := 2048
# Signs stand this far off their surface, so they never flicker into it.
const LIFT := 0.015
# Neon stands on a dark plate this deep.
const BACKING_DEPTH := 0.05
# Lines of words set tighter than the font's own spacing, as on a stencil or a sign.
const LEADING := 0.82

const STYLES := {
	"stencil": {"font": BOLD, "color": Color(0.09, 0.09, 0.1), "wear": 0.45},
	"graffiti": {"font": MARKER, "color": Color(0.88, 0.32, 0.2), "wear": 0.35, "tilt": -0.06},
	"neon": {"font": SEMIBOLD, "color": NEON, "glow": 3.0, "light": 1.6},
	"road": {"font": BOLD, "color": Color(0.82, 0.82, 0.78), "wear": 0.4, "wet": 1.0},
}
# By name, as map dressing places them: the art, its style, its size in metres, and on a wall, the
# height of its middle. Emblem signs carry a caption under the mark.
const CATALOG := {
	"slogan_cleaner": {"text": "MACHINES\nA CLEANER\nTOMORROW", "style": "stencil", "size": Vector2(2.2, 1.35), "y": 2.0},
	"slogan_silence": {"text": "SILENCE\nBUILDS\nBETTER\nMINDS", "style": "stencil", "size": Vector2(1.6, 1.6), "y": 2.0},
	"slogan_quieter": {"text": "A\nQUIETER\nTOMORROW", "style": "stencil", "size": Vector2(1.8, 1.4), "y": 2.0},
	"graffiti_obey": {"text": "OBEY\nSTILL", "style": "graffiti", "size": Vector2(1.7, 1.2), "y": 1.6},
	"graffiti_obedient": {"text": "MORE\nOBEDIENT\nHUMANS", "style": "graffiti", "size": Vector2(2.6, 1.7), "y": 1.3},
	"neon_banner": {"emblem": "SENTIENCE\nSERVES\nORDER", "style": "neon", "size": Vector2(2.6, 5.0), "y": 5.7, "panel": true},
	"neon_name": {"text": "A\nN\nT\nH\nR\nO\nP\nO\nM\nO\nR\nP\nH\nI\nC", "style": "neon", "size": Vector2(0.6, 7.2), "y": 4.9, "panel": true},
	"paint_stop": {"text": "STOP", "style": "road", "size": Vector2(2.4, 1.1)},
}

# Art already drawn, or being drawn, by what it shows and at what size: the texture once it is
# ready, and the materials waiting for it. Art is a white mask colored by the shader, so signs
# that say the same thing in different colors share it.
var _art := {}


static func has(sign_name: String) -> bool:
	return CATALOG.has(sign_name)


# A sign from the catalog. On a wall, `at` is the middle of the wall face at floor level and the
# sign faces along yaw; on the ground it lies flat, read from the side yaw faces. Returns what
# should ghost with the wall.
func place(sign_name: String, at: Vector3, yaw: float) -> Array[GeometryInstance3D]:
	var entry: Dictionary = CATALOG[sign_name]
	var style: Dictionary = STYLES[entry.style]
	var size: Vector2 = entry.size
	var pieces: Array[GeometryInstance3D] = []
	var holder := Node3D.new()
	holder.position = at
	holder.rotation.y = yaw
	add_child(holder)
	var card := MeshInstance3D.new()
	card.material_override = _material(entry, style)
	if entry.has("y"):
		var quad := QuadMesh.new()
		quad.size = size
		card.mesh = quad
		card.position = Vector3(0.0, entry.y, LIFT + (BACKING_DEPTH if entry.get("panel", false) else 0.0))
		if entry.get("panel", false):
			pieces.append(_add_backing(holder, size, entry.y))
	else:
		var plane := PlaneMesh.new()
		plane.size = size
		card.mesh = plane
		card.position.y = LIFT
	holder.add_child(card)
	pieces.append(card)
	if style.has("light"):
		_add_light(holder, style.color, style.light, Vector3(0.0, entry.y, 0.9), maxf(size.x, size.y) + 3.0)
	return pieces


# Road paint in a straight line: solid, or dashes with gaps of the same length.
func paint_line(from: Vector3, to: Vector3, width: float, dash := 0.0) -> void:
	var material := _material({}, STYLES.road)
	var length := from.distance_to(to)
	var direction := (to - from) / length
	var step := dash * 2.0 if dash > 0.0 else length
	var piece := dash if dash > 0.0 else length
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(width, piece)
	var along := 0.0
	while along + piece <= length + 0.001:
		var stroke := MeshInstance3D.new()
		stroke.mesh = mesh
		stroke.material_override = material
		stroke.position = from + direction * (along + piece / 2.0) + Vector3(0.0, LIFT, 0.0)
		stroke.rotation.y = atan2(direction.x, direction.z)
		add_child(stroke)
		along += step


# A neon sign made on the spot, for the city around the map: words in a color, facing along yaw.
func neon(text: String, color: Color, at: Vector3, yaw: float, size: Vector2) -> void:
	var holder := Node3D.new()
	holder.position = at
	holder.rotation.y = yaw
	add_child(holder)
	var entry := {"text": text, "size": size}
	var style: Dictionary = STYLES.neon.duplicate()
	style.color = color
	var card := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = size
	card.mesh = quad
	card.material_override = _material(entry, style)
	card.position.z = LIFT
	holder.add_child(card)
	_add_light(holder, color, style.light, Vector3(0.0, 0.0, 0.8), maxf(size.x, size.y) + 2.5)


func _material(entry: Dictionary, style: Dictionary) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = SHADER
	material.set_shader_parameter("color", style.color)
	material.set_shader_parameter("glow", style.get("glow", 0.0))
	material.set_shader_parameter("wear", style.get("wear", 0.0))
	material.set_shader_parameter("wet", style.get("wet", 0.0))
	if entry.has("text") or entry.has("emblem"):
		_use_art(entry, style, material)
	return material


func _add_backing(holder: Node3D, size: Vector2, y: float) -> GeometryInstance3D:
	var box := BoxMesh.new()
	box.size = Vector3(size.x + 0.3, size.y + 0.3, BACKING_DEPTH)
	var backing := MeshInstance3D.new()
	backing.mesh = box
	backing.material_override = Surfaces.named("metal")
	backing.position = Vector3(0.0, y, BACKING_DEPTH / 2.0)
	holder.add_child(backing)
	return backing


func _add_light(holder: Node3D, color: Color, energy: float, offset: Vector3, reach: float) -> void:
	var light := OmniLight3D.new()
	light.light_color = color
	light.light_energy = energy
	light.omni_range = reach
	light.position = offset
	holder.add_child(light)


func _use_art(entry: Dictionary, style: Dictionary, material: ShaderMaterial) -> void:
	var key := "%s|%s|%s" % [entry.get("emblem", entry.get("text")), style.font.resource_path, entry.size]
	if not _art.has(key):
		_art[key] = {"texture": null, "waiting": []}
		_paint_art(key, entry, style)
	if _art[key].texture:
		material.set_shader_parameter("art", _art[key].texture)
	else:
		_art[key].waiting.append(material)


# Draws the art in a viewport of its own, then keeps it as a texture with mipmaps, so the words
# stay crisp far off instead of shimmering. The viewport renders on the next frame; until then
# the signs waiting for it are blank.
func _paint_art(key: String, entry: Dictionary, style: Dictionary) -> void:
	var size: Vector2 = entry.size
	var scale := minf(PIXELS_PER_METRE, MAX_PIXELS / maxf(size.x, size.y))
	var pixels := Vector2i(size * scale)
	var viewport := SubViewport.new()
	viewport.size = pixels
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)
	if entry.has("emblem"):
		var emblem := Emblem.new()
		emblem.caption = entry.emblem
		emblem.font = style.font
		emblem.size = Vector2(pixels)
		viewport.add_child(emblem)
	else:
		viewport.add_child(_words(entry.text, style, Vector2(pixels)))
	await RenderingServer.frame_post_draw
	if not is_instance_valid(viewport):
		return
	var image := viewport.get_texture().get_image()
	image.generate_mipmaps()
	var texture := ImageTexture.create_from_image(image)
	viewport.queue_free()
	_art[key].texture = texture
	for material: ShaderMaterial in _art[key].waiting:
		material.set_shader_parameter("art", texture)
	_art[key].waiting.clear()


# Words set as large as fit the frame, each line centred.
static func _words(text: String, style: Dictionary, frame: Vector2) -> Label:
	var font: Font = style.font
	var reference := 100
	var widest := 0.0
	var lines := text.split("\n")
	for line in lines:
		widest = maxf(widest, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, reference).x)
	var tall := font.get_height(reference) * LEADING * lines.size()
	var settings := LabelSettings.new()
	settings.font = font
	settings.font_size = int(reference * minf(frame.x * 0.94 / widest, frame.y * 0.94 / tall))
	settings.line_spacing = -settings.font_size * (1.0 - LEADING)
	var label := Label.new()
	label.text = text
	label.label_settings = settings
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = frame
	label.pivot_offset = frame / 2.0
	label.rotation = style.get("tilt", 0.0)
	return label


# The corporation's mark, traced from the concept art, with a caption set under it.
class Emblem extends Control:
	# The tracing's frame; the blade down its middle; and the fin and wing on its left, which are
	# mirrored on the right.
	const FRAME := Vector2(480.0, 795.0)
	const BLADE := [Vector2(240, 15), Vector2(262, 165), Vector2(262, 560), Vector2(240, 775), Vector2(218, 560), Vector2(218, 165)]
	const SIDE := [
		[Vector2(202, 188), Vector2(202, 560), Vector2(186, 592), Vector2(178, 335), Vector2(80, 240)],
		[Vector2(40, 238), Vector2(160, 350), Vector2(160, 500), Vector2(146, 520), Vector2(144, 372)],
	]
	# The share of the height the mark takes; the caption has the rest.
	const MARK_SHARE := 0.66

	var caption := ""
	var font: Font

	func _ready() -> void:
		var below := Rect2(0.0, size.y * MARK_SHARE, size.x, size.y * (1.0 - MARK_SHARE))
		var label := Signs._words(caption, {"font": font}, below.size * Vector2(0.8, 0.9))
		label.position = below.position + below.size * Vector2(0.1, 0.05)
		add_child(label)

	func _draw() -> void:
		var area := Vector2(size.x, size.y * MARK_SHARE) * 0.92
		var scale := minf(area.x / FRAME.x, area.y / FRAME.y)
		var offset := (Vector2(size.x, size.y * MARK_SHARE) - FRAME * scale) / 2.0
		draw_colored_polygon(_placed(BLADE, offset, scale, false), Color.WHITE)
		for shape: Array in SIDE:
			draw_colored_polygon(_placed(shape, offset, scale, false), Color.WHITE)
			draw_colored_polygon(_placed(shape, offset, scale, true), Color.WHITE)

	func _placed(shape: Array, offset: Vector2, scale: float, mirrored: bool) -> PackedVector2Array:
		var points := PackedVector2Array()
		for point: Vector2 in shape:
			points.append(offset + Vector2(FRAME.x - point.x if mirrored else point.x, point.y) * scale)
		return points
