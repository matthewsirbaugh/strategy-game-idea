class_name MapData
extends Resource

# Legend: explorations/battle-mvp.md, "Map sketch".
@export_multiline var layout := ""
@export var node_kinds := {}
@export var links := PackedStringArray()
# Line N holds guard N+1's waypoints after its start tile, as "x,y x,y".
@export var patrols := PackedStringArray()

var size := Vector2i.ZERO
var _parsed := false
var _walls := {}
var _nodes := {}
var _node_at := {}
var _player_starts: Array[Vector2i] = []
var _guard_starts := {}
var _extraction: Array[Vector2i] = []


func in_bounds(cell: Vector2i) -> bool:
	_parse()
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


func is_wall(cell: Vector2i) -> bool:
	_parse()
	return _walls.has(cell)


func node_at(cell: Vector2i) -> String:
	_parse()
	return _node_at.get(cell, "")


func node_ids() -> Array:
	_parse()
	return _nodes.keys()


func node_cell(id: String) -> Vector2i:
	_parse()
	return _nodes[id]


func node_kind(id: String) -> String:
	return node_kinds.get(id, "")


func player_starts() -> Array[Vector2i]:
	_parse()
	return _player_starts


func extraction() -> Array[Vector2i]:
	_parse()
	return _extraction


func guard_numbers() -> Array:
	_parse()
	var numbers := _guard_starts.keys()
	numbers.sort()
	return numbers


func guard_route(number: int) -> Array[Vector2i]:
	_parse()
	var route: Array[Vector2i] = [_guard_starts[number]]
	if number - 1 < patrols.size():
		for point in patrols[number - 1].split(" ", false):
			var xy := point.split(",")
			route.append(Vector2i(xy[0].to_int(), xy[1].to_int()))
	return route


func _parse() -> void:
	if _parsed:
		return
	_parsed = true
	var rows := layout.strip_edges().split("\n")
	size = Vector2i(0, rows.size())
	for y in rows.size():
		var tiles := rows[y].strip_edges().split(" ", false)
		size.x = maxi(size.x, tiles.size())
		for x in tiles.size():
			_read_tile(tiles[x], Vector2i(x, y))


func _read_tile(tile: String, cell: Vector2i) -> void:
	match tile:
		".":
			pass
		"#":
			_walls[cell] = true
		"X":
			_extraction.append(cell)
		"P":
			_player_starts.append(cell)
		_:
			if tile.is_valid_int():
				_guard_starts[tile.to_int()] = cell
			else:
				_nodes[tile] = cell
				_node_at[cell] = tile
