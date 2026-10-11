class_name SceneryFog
extends RefCounted

const BOX_SHADER := preload("res://art/shaders/fog_box.gdshader")
const SURFACE_SHADER := preload("res://art/shaders/fog_surface.gdshader")
enum Coverage { VISIBLE, HIDDEN, PARTIAL }

static var _box_mesh := BoxMesh.new()
static var _box_material: ShaderMaterial
static var _surface_materials := {}

var root: Node3D
var proxy: MeshInstance3D
var bounds: AABB
var details: Array[MeshInstance3D] = []
var coverage := Coverage.PARTIAL
var enabled := true
var ghost_cells: Array[Vector2i] = []
var ghost_model: ToonModel
var _wanted := {}
var _cells: Array[Vector2i] = []
var _transform := Transform3D()


func _init(asset: Node3D) -> void:
	root = asset
	if root is MeshInstance3D:
		details.append(root)
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		details.append(mesh)
	var inverse := root.global_transform.affine_inverse()
	for i in details.size():
		var mesh := details[i]
		var part := inverse * mesh.global_transform * mesh.get_aabb()
		bounds = part if i == 0 else bounds.merge(part)
		_wanted[mesh] = mesh.visible
		_mask_materials(mesh)
		mesh.set_instance_shader_parameter("scenery", true)
	if not _box_material:
		_box_mesh.size = Vector3.ONE
		_box_material = ShaderMaterial.new()
		_box_material.shader = BOX_SHADER
	proxy = MeshInstance3D.new()
	proxy.name = "FogBox"
	proxy.mesh = _box_mesh
	proxy.material_override = _box_material
	proxy.position = bounds.get_center()
	proxy.scale = bounds.size.max(Vector3.ONE * 0.002)
	root.add_child(proxy)


func set_detail_visible(mesh: MeshInstance3D, shown: bool) -> void:
	_wanted[mesh] = shown
	mesh.visible = shown and enabled and coverage != Coverage.HIDDEN


func refresh(grid: GridView) -> void:
	if _cells.is_empty() or _transform != root.global_transform:
		_transform = root.global_transform
		_cells.clear()
		var world_bounds := _transform * bounds
		var first := grid.world_to_cell(world_bounds.position)
		var inset := Vector3(0.00001 if world_bounds.size.x > 0.0 else 0.0, 0, 0.00001 if world_bounds.size.z > 0.0 else 0.0)
		var last := grid.world_to_cell(world_bounds.end - inset)
		for y in range(first.y, last.y + 1):
			for x in range(first.x, last.x + 1):
				_cells.append(Vector2i(x, y))
	var seen := false
	var hidden := false
	for cell in _cells:
		seen = seen or grid.cell_visible(cell)
		hidden = hidden or not grid.cell_visible(cell)
		if seen and hidden:
			break
	coverage = Coverage.PARTIAL if seen and hidden else Coverage.VISIBLE if seen else Coverage.HIDDEN
	var partial := coverage == Coverage.PARTIAL
	for mesh in details:
		mesh.visible = enabled and seen and _wanted[mesh]
		mesh.set_instance_shader_parameter("fog_partial", partial)
	proxy.visible = enabled and hidden
	proxy.set_instance_shader_parameter("fog_partial", partial)


func sync_ghost(walls: Dictionary) -> void:
	var ghost := ghost_model.ghost if ghost_model else 0.0
	for cell in ghost_cells:
		if walls.has(cell):
			ghost = maxf(ghost, walls[cell].ghost)
	proxy.set_instance_shader_parameter("ghost", ghost)


static func _mask_materials(mesh: MeshInstance3D) -> void:
	if mesh.material_override:
		mesh.material_override = _masked(mesh.material_override)
	else:
		for surface in mesh.mesh.get_surface_count():
			mesh.set_surface_override_material(surface, _masked(mesh.get_active_material(surface)))


static func _masked(material: Material) -> Material:
	if material is ShaderMaterial:
		return material
	if not _surface_materials.has(material):
		var masked := ShaderMaterial.new()
		masked.shader = SURFACE_SHADER
		if material is BaseMaterial3D:
			masked.set_shader_parameter("color", material.albedo_color)
			masked.set_shader_parameter("albedo_texture", material.albedo_texture)
			masked.set_shader_parameter("roughness", material.roughness)
			masked.set_shader_parameter("unshaded", material.shading_mode == BaseMaterial3D.SHADING_MODE_UNSHADED)
			if material.emission_enabled:
				masked.set_shader_parameter("glow_color", material.emission)
				masked.set_shader_parameter("glow_energy", material.emission_energy_multiplier)
		_surface_materials[material] = masked
	return _surface_materials[material]
