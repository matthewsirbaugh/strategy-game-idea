class_name GridView
extends Node3D

const TILE_HEIGHT := 0.2
const TILE_GAP := 0.06

@export var map: MapData


func _ready() -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.0 - TILE_GAP, TILE_HEIGHT, 1.0 - TILE_GAP)
	var light := _material(Color(0.36, 0.39, 0.44))
	var dark := _material(Color(0.3, 0.33, 0.38))
	for y in map.size.y:
		for x in map.size.x:
			var tile := MeshInstance3D.new()
			tile.mesh = mesh
			tile.material_override = light if (x + y) % 2 == 0 else dark
			tile.position = cell_to_world(Vector2i(x, y)) + Vector3(0, -TILE_HEIGHT / 2.0, 0)
			add_child(tile)


func cell_to_world(cell: Vector2i) -> Vector3:
	return Vector3(cell.x + 0.5, 0.0, cell.y + 0.5)


func world_to_cell(point: Vector3) -> Vector2i:
	return Vector2i(floori(point.x), floori(point.z))


func center() -> Vector3:
	return extent() / 2.0


func extent() -> Vector3:
	return Vector3(map.size.x, 0.0, map.size.y)


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material
