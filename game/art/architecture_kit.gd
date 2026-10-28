class_name ArchitectureKit
## Dresses a piece of the architecture kit (assets/architecture/) for the game: its imported
## materials become the kit's fog-aware shaders, and glass in a building's wall shows a lit room
## behind it. Materials are made once per source material and shared.

const SOLID := preload("res://art/shaders/architecture.gdshader")
const INTERIOR := preload("res://art/shaders/window_interior.gdshader")
const CLEAR := preload("res://art/shaders/clear_glass.gdshader")
# Pieces whose glass is a building's outer wall; any other glass is see-through.
const ROOM_GLASS := ["wall_glass", "wall_door", "wall_ribbon"]

static var _materials := {}


static func dress(piece: Node3D, id: String) -> void:
	for mesh: MeshInstance3D in piece.find_children("*", "MeshInstance3D", true, false):
		for surface in mesh.mesh.get_surface_count():
			mesh.set_surface_override_material(surface, _material(mesh.get_active_material(surface), id in ROOM_GLASS))
	SceneryFog.apply(piece)


static func _material(source: Material, room_glass: bool) -> ShaderMaterial:
	var key := [source, room_glass]
	if _materials.has(key):
		return _materials[key]
	var made := ShaderMaterial.new()
	var base := source as BaseMaterial3D
	if source.resource_name == "glass":
		made.shader = INTERIOR if room_glass else CLEAR
	else:
		made.shader = SOLID
		made.set_shader_parameter("color", base.albedo_color)
		made.set_shader_parameter("roughness", base.roughness)
		made.set_shader_parameter("metallic", base.metallic)
		if source.resource_name == "stone":
			made.set_shader_parameter("paving", 0.75)
		if base.emission_enabled:
			made.set_shader_parameter("glow_color", base.emission)
			made.set_shader_parameter("glow_energy", base.emission_energy_multiplier * 2.0)
	_materials[key] = made
	return made
