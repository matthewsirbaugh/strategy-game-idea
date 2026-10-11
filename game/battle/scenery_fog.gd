class_name SceneryFog
extends RefCounted

const SURFACE_SHADER := preload("res://art/shaders/fog_surface.gdshader")
static var _surface_materials := {}


static func apply(root: Node3D) -> void:
	if root is MeshInstance3D:
		_mask(root)
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		_mask(mesh)


static func _mask(mesh: MeshInstance3D) -> void:
	if mesh.material_override:
		if mesh.material_override is ShaderMaterial and mesh.material_override.shader == Surfaces.GROUND:
			return
		mesh.material_override = _masked(mesh.material_override)
	else:
		for surface in mesh.mesh.get_surface_count():
			mesh.set_surface_override_material(surface, _masked(mesh.get_active_material(surface)))
	mesh.set_instance_shader_parameter("scenery", true)
	if mesh.mesh is TextMesh:
		mesh.set_instance_shader_parameter("detail_only", true)


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
			masked.set_shader_parameter("detail_only", material.emission_enabled)
			if material.emission_enabled:
				masked.set_shader_parameter("glow_color", material.emission)
				masked.set_shader_parameter("glow_energy", material.emission_energy_multiplier)
		_surface_materials[material] = masked
	return _surface_materials[material]
