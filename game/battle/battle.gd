extends Node3D

@onready var _grid: GridView = $GridView
@onready var _camera_rig: CameraRig = $CameraRig
@onready var _hover: MeshInstance3D = $HoverHighlight
@onready var _cell_label: Label = %CellLabel


func _ready() -> void:
	_camera_rig.setup(_grid.center(), _grid.extent())


func _process(_delta: float) -> void:
	var cell: Variant = _hovered_cell()
	_hover.visible = cell != null
	if cell == null:
		_cell_label.text = ""
		return
	_hover.position = _grid.cell_to_world(cell) + Vector3(0, 0.01, 0)
	_cell_label.text = "Tile %d, %d" % [cell.x, cell.y]


func _hovered_cell() -> Variant:
	var camera := get_viewport().get_camera_3d()
	var mouse := get_viewport().get_mouse_position()
	var hit: Variant = Plane(Vector3.UP, 0.0).intersects_ray(
		camera.project_ray_origin(mouse), camera.project_ray_normal(mouse)
	)
	if hit == null:
		return null
	var cell := _grid.world_to_cell(hit)
	return cell if _grid.map.in_bounds(cell) else null
