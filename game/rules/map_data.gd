class_name MapData
extends Resource

# Legend: explorations/battle-mvp.md, "Map sketch". B is a wall that belongs to a building and
# a comma is street; to the rules they are a wall and a floor like any other.
@export_multiline var layout := ""
@export var node_kinds := {}
@export var links := PackedStringArray()
# Line N holds guard N+1's waypoints after its start tile, as "x,y x,y".
@export var patrols := PackedStringArray()
# Props with no rules role, one per line: "name x,y facing [tiles]", facing north, south, east or
# west. The name is a folder in art/props/, or a sign in Signs.CATALOG. The rules ignore these;
# the level view draws them.
@export var dressing := PackedStringArray()
# Indoors the floor and walls are the corporate interior; outdoors, paving and concrete. Only the
# look changes.
@export var indoors := false
# Which way a node set into a wall faces, as north, south, east or west. Without an entry it
# faces its first open side.
@export var node_facings := {}

const FACINGS := {"south": 0.0, "east": PI / 2.0, "north": PI, "west": -PI / 2.0}

var size := Vector2i.ZERO
var _parsed := false
var _parse_errors := PackedStringArray()
var _walls := {}
var _buildings := {}
var _street := {}
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
	for id in node_facings:
		if not _nodes.has(id) or not FACINGS.has(node_facings[id]):
			errors.append(field_error("node_facings", "'%s: %s' should name a node on the layout and a facing" % [id, node_facings[id]]))
	for i in dressing.size():
		var parts := dressing[i].split(" ", false)
		var xy := parts[1].split(",") if parts.size() > 1 else PackedStringArray()
		if parts.size() not in [3, 4] or xy.size() != 2 or not xy[0].is_valid_int() or not xy[1].is_valid_int() \
				or not FACINGS.has(parts[2]) or (parts.size() == 4 and not parts[3].is_valid_int()):
			errors.append(field_error("dressing[%d]" % i, "'%s' should read 'name x,y facing', with an optional tile count" % dressing[i]))
	if _player_starts.is_empty():
		errors.append(field_error("layout", "has no player start (P)"))
	if _extraction.is_empty():
		errors.append(field_error("layout", "has no extraction tile (X)"))
	return errors


# Each dressing line as {prop, cell, yaw, tiles}. Assumes validate() found no errors.
func dressing_items() -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for line in dressing:
		var parts := line.split(" ", false)
		var xy := parts[1].split(",")
		items.append({
			"prop": parts[0],
			"cell": Vector2i(xy[0].to_int(), xy[1].to_int()),
			"yaw": FACINGS[parts[2]],
			"tiles": parts[3].to_int() if parts.size() > 3 else 1,
		})
	return items


func field_error(field: String, problem: String) -> String:
	return "%s: %s %s" % [resource_path if resource_path != "" else "Unsaved map", field, problem]


func in_bounds(cell: Vector2i) -> bool:
	_parse()
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


func is_wall(cell: Vector2i) -> bool:
	_parse()
	return _walls.has(cell)


func is_building(cell: Vector2i) -> bool:
	_parse()
	return _buildings.has(cell)


func is_street(cell: Vector2i) -> bool:
	_parse()
	return _street.has(cell)


# A node with walls on both sides of it, in a line, is set into that wall: a panel, a wall camera,
# a door. It blocks sight like the wall does, unless it's an open door.
func in_wall(cell: Vector2i) -> bool:
	_parse()
	return (_walls.has(cell + Vector2i(-1, 0)) and _walls.has(cell + Vector2i(1, 0))) \
		or (_walls.has(cell + Vector2i(0, -1)) and _walls.has(cell + Vector2i(0, 1)))


# The side of the tile a node faces, as a step on the grid.
func node_facing(id: String) -> Vector2i:
	_parse()
	if node_facings.has(id):
		var yaw: float = FACINGS[node_facings[id]]
		return Vector2i(roundi(sin(yaw)), roundi(cos(yaw)))
	var cell: Vector2i = _nodes[id]
	for step in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
		if in_bounds(cell + step) and not _walls.has(cell + step):
			return step
	return Vector2i(0, 1)


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
		"B":
			_walls[cell] = true
			_buildings[cell] = true
		",":
			_street[cell] = true
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
