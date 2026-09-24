class_name Reach
extends RefCounted

var cost := {}
var _came_from := {}


func _init(start: Vector2i, max_cost: int, passable: Callable) -> void:
	cost[start] = 0
	_came_from[start] = start
	var frontier: Array[Vector2i] = [start]
	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		if cost[current] >= max_cost:
			continue
		for next in Grid.neighbors(current):
			if cost.has(next) or not passable.call(next):
				continue
			cost[next] = cost[current] + 1
			_came_from[next] = current
			frontier.append(next)


func has(cell: Vector2i) -> bool:
	return cost.has(cell)


func path_to(cell: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	if not cost.has(cell):
		return path
	var current := cell
	while current != _came_from[current]:
		path.push_front(current)
		current = _came_from[current]
	return path
