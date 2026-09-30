class_name Rain
extends GPUParticles3D
## Thin streaks falling over an area, unlit so they read as rain in any light. The wet look of the
## ground is the ground shader's; this is only the falling water.

const STREAKS_PER_SQUARE_METRE := 2.2
const SPEED := 22.0
const DROP := 16.0


# Covers the area from corner to corner on the ground, plus a margin all round.
func setup(from: Vector3, to: Vector3, margin: float) -> void:
	var size := (to - from).abs() + Vector3(margin, 0.0, margin) * 2.0
	amount = int(size.x * size.z * STREAKS_PER_SQUARE_METRE)
	lifetime = DROP / SPEED
	preprocess = lifetime
	position = (from + to) / 2.0 + Vector3(0.0, DROP, 0.0)
	visibility_aabb = AABB(Vector3(-size.x / 2.0, -DROP - 2.0, -size.z / 2.0), Vector3(size.x, DROP + 4.0, size.z))
	var fall := ParticleProcessMaterial.new()
	fall.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	fall.emission_box_extents = Vector3(size.x / 2.0, 0.5, size.z / 2.0)
	fall.direction = Vector3(0.08, -1.0, 0.04)
	fall.spread = 2.0
	fall.initial_velocity_min = SPEED * 0.9
	fall.initial_velocity_max = SPEED * 1.1
	fall.gravity = Vector3.ZERO
	process_material = fall
	var streak := QuadMesh.new()
	streak.size = Vector2(0.01, 0.4)
	var look := StandardMaterial3D.new()
	look.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	look.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	look.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	look.albedo_color = Color(0.75, 0.8, 0.95, 0.14)
	streak.material = look
	draw_pass_1 = streak
