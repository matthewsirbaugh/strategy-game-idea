class_name MapData
extends Resource

@export var size := Vector2i(12, 12)


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y
