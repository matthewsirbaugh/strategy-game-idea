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
var _parse_errors := PackedStringArray()
var _walls := {}
var _nodes := {}
var _node_at := {}
var _player_starts: Array[Vector2i] = []
var _guard_starts := {}
var _extraction: Array[Vector2i] = []


# Everything that would corrupt a battle, each naming this resource and the field at fault.
# Empty when the map is valid. The other functions assume it is.
func validate() -> PackedStringArray:
	_parse()
	var errors := _parse_errors.duplicate()
	for id in _nodes:
		if node_kinds.get(id, "") == "":
			errors.append(field_error("node_kinds", "has no kind for node '%s' at %s" % [id, _xy(_nodes[id])]))
	for id in node_kinds:
		if not _nodes.has(id):
			errors.append(field_error("node_kinds", "names node '%s', which isn't on the layout" % id))
	for i in links.size():
		var ends := links[i].split("-")
		if ends.size() != 2 or ends[0] == ends[1]:
			errors.append(field_error("links[%d]" % i, "'%s' should join two different nodes, like 'a-e'" % links[i]))
			continue
		for end in ends:
			if not _nodes.has(end):
				errors.append(field_error("links[%d]" % i, "'%s' names node '%s', which isn't on the layout" % [links[i], end]))
	for i in patrols.size():
		if not _guard_starts.has(i + 1):
			errors.append(field_error("patrols[%d]" % i, "is for guard %d, who isn't on the layout" % (i + 1)))
		for point in patrols[i].split(" ", false):
			var xy := point.split(",")
			if xy.size() != 2 or not xy[0].is_valid_int() or not xy[1].is_valid_int():
				errors.append(field_error("patrols[%d]" % i, "waypoint '%s' should be 'x,y'" % point))
				continue
			var cell := Vector2i(xy[0].to_int(), xy[1].to_int())
			if not in_bounds(cell) or is_wall(cell):
				errors.append(field_error("patrols[%d]" % i, "waypoint %s is off the map or a wall" % _xy(cell)))
	if _player_starts.is_empty():
		errors.append(field_error("layout", "has no player start (P)"))
	if _extraction.is_empty():
		errors.append(field_error("layout", "has no extraction tile (X)"))
	return errors


func field_error(field: String, problem: String) -> String:
	return "%s: %s %s" % [resource_path if resource_path != "" else "Unsaved map", field, problem]


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
	if layout.strip_edges() == "":
		_parse_errors.append(field_error("layout", "is empty"))
		return
	var rows := layout.strip_edges().split("\n")
	size = Vector2i(0, rows.size())
	for y in rows.size():
		var tiles := rows[y].strip_edges().split(" ", false)
		if y == 0:
			size.x = tiles.size()
		elif tiles.size() != size.x:
			_parse_errors.append(field_error("layout", "row %d has %d tiles, but row 0 has %d" % [y, tiles.size(), size.x]))
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
				var number := tile.to_int()
				if number < 1:
					_parse_errors.append(field_error("layout", "has guard %s at %s, but guards are numbered from 1" % [tile, _xy(cell)]))
				elif _guard_starts.has(number):
					_parse_errors.append(field_error("layout", "has guard %d at %s and again at %s" % [number, _xy(_guard_starts[number]), _xy(cell)]))
				else:
					_guard_starts[number] = cell
			elif _nodes.has(tile):
				_parse_errors.append(field_error("layout", "has node '%s' at %s and again at %s" % [tile, _xy(_nodes[tile]), _xy(cell)]))
			else:
				_nodes[tile] = cell
				_node_at[cell] = tile


# Coordinates the way the map sketch and patrols write them.
static func _xy(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]
