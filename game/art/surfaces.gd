class_name Surfaces
## The painted surfaces levels are built from, by name: walls, their trims, and the ground. Colors
## and wear live here, so the look of every map is tuned in one place. Each material is made once
## and shared.

const WALL := preload("res://art/shaders/wall.gdshader")
const GROUND := preload("res://art/shaders/ground.gdshader")
const HAZARD := Color(1.0, 0.42, 0.1)

const KINDS := {
	# Walls. Their tops are set per mesh, as the instance parameter "top".
	"perimeter": [WALL, {"base_color": Color(0.47, 0.47, 0.48), "panel": Vector2(1.5, 1.0), "grime": 0.7, "streaks": 0.9}],
	"building": [WALL, {"base_color": Color(0.26, 0.26, 0.29), "panel": Vector2(1.5, 2.5), "grime": 0.35, "streaks": 0.4, "windows_from": 3.4}],
	"indoor": [WALL, {"base_color": Color(0.64, 0.62, 0.6), "panel": Vector2(1.5, 0.7), "grime": 0.15, "streaks": 0.0}],
	# The city around the map: the same concrete, fading near the camera so it can pass behind.
	"city": [WALL, {"base_color": Color(0.23, 0.23, 0.26), "panel": Vector2(1.5, 3.0), "grime": 0.5, "streaks": 0.6, "windows_from": 0.3, "window_glow": 0.35, "camera_fade": 10.0}],
	"skyline": [WALL, {"base_color": Color(0.14, 0.15, 0.19), "panel": Vector2(1.5, 3.5), "grime": 0.2, "streaks": 0.2, "windows_from": 1.0, "window_glow": 0.8}],
	# Trim: the plinth along a wall's foot, the cap along its top, the hazard band, and curbs.
	"plinth": [WALL, {"base_color": Color(0.27, 0.27, 0.28), "panel": Vector2(1.5, 1.0), "grime": 0.6, "streaks": 0.0}],
	"cap": [WALL, {"base_color": Color(0.52, 0.51, 0.49), "panel": Vector2(1.5, 1.0), "grime": 0.35, "streaks": 0.0}],
	"hazard": [WALL, {"base_color": Color(0.6, 0.58, 0.55), "panel": Vector2(1.5, 1.0), "grime": 0.55, "streaks": 0.0, "stripes": 1.0, "stripe_color": HAZARD}],
	"metal": [WALL, {"base_color": Color(0.13, 0.13, 0.15), "panel": Vector2(1.5, 1.0), "grime": 0.3, "streaks": 0.0}],
	# Ground. Paving slabs line up with the tiles, so their joints are the grid.
	"paving": [GROUND, {"base_color": Color(0.36, 0.36, 0.37), "slab": 1.5, "grime": 0.5, "wet": 1.0}],
	"asphalt": [GROUND, {"base_color": Color(0.19, 0.19, 0.21), "grime": 0.6, "cracks": 1.0, "wet": 1.0}],
	"sidewalk": [GROUND, {"base_color": Color(0.3, 0.3, 0.31), "slab": 1.0, "joint_lift": 0.15, "grime": 0.5, "wet": 1.0}],
	"corporate": [GROUND, {"base_color": Color(0.56, 0.55, 0.54), "slab": 1.5, "joint_lift": -0.3, "grime": 0.1}],
}

static var _made := {}


static func named(kind: String) -> ShaderMaterial:
	if not _made.has(kind):
		var material := ShaderMaterial.new()
		material.shader = KINDS[kind][0]
		var parameters: Dictionary = KINDS[kind][1]
		for parameter in parameters:
			material.set_shader_parameter(parameter, parameters[parameter])
		_made[kind] = material
	return _made[kind]
