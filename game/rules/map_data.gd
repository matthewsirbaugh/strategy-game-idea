class_name MapData
extends Resource

# The layout is rows of space-separated tiles: . floor, # wall, B a wall that belongs to a
# building, a comma street, X extraction, P an Operator's start, a number a guard's start, and any
# other name a node. = is a low obstacle such as crates: it blocks walking and a person's sight,
# but a drone flies over it and cameras see past it.
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
# Which way a node faces, as north, south, east or west. Without an entry it faces its first open
# side. Cameras, turrets and vehicles use it.
@export var node_facings := {}
# Networks that don't connect, by name: the nodes on each, as "a d e". Empty means one network
# holding every node.
@export var networks := {}
# Each power hub's circuit, as "hub id": "h i j".
@export var circuits := {}
# Zones by name, each a list of rectangles "x0,y0-x1,y1", tiles "x,y" and node ids. Every open tile
# and every node belongs to exactly one. Empty means the map has no zones.
@export var zones := {}
# Where bodies can be hidden: "dumpster x,y" on a low obstacle, or "trunk id" on a vehicle.
@export var receptacles := PackedStringArray()
# Starting states that differ from the device's default, as "id": "off", "on", "locked" or "open".
@export var node_states := {}
# At night every tile without a powered light is dark.
@export var night := false

const FACINGS := {"south": 0.0, "east": PI / 2.0, "north": PI, "west": -PI / 2.0}
const STATE_WORDS := ["on", "off", "locked", "open"]

var size := Vector2i.ZERO
var _parsed := false
var _parse_errors := PackedStringArray()
var _walls := {}
var _buildings := {}
var _street := {}
var _low := {}
var _nodes := {}
var _node_at := {}
var _player_starts: Array[Vector2i] = []
var _guard_starts := {}
var _extraction: Array[Vector2i] = []
var _zone_of_cell := {}
var _zone_of_node := {}
var _network_of := {}
var _circuit_of := {}
var _receptacles := {}


# Everything that would corrupt a battle, each naming this resource and the field at fault.
# Empty when the map is valid. The other functions assume it is.
func validate() -> PackedStringArray:
	_parse()
	var errors := _parse_errors.duplicate()
	for id in _nodes:
		if node_kind(id) == "":
			errors.append(field_error("node_kinds", "has no kind for node '%s' at %s" % [id, _xy(_nodes[id])]))
	for id in node_kinds:
		if not _nodes.has(id):
			errors.append(field_error("node_kinds", "names node '%s', which isn't on the layout" % id))
		if not node_kinds[id] is String:
			errors.append(field_error("node_kinds", "kind for '%s' must be a string" % id))
	for i in links.size():
		var ends := links[i].split("-")
		if ends.size() != 2 or ends[0] == ends[1]:
			errors.append(field_error("links[%d]" % i, "'%s' should join two different nodes, like 'a-e'" % links[i]))
			continue
		for end in ends:
			if not _nodes.has(end):
				errors.append(field_error("links[%d]" % i, "'%s' names node '%s', which isn't on the layout" % [links[i], end]))
		if _network_of.has(ends[0]) and _network_of.has(ends[1]) and _network_of[ends[0]] != _network_of[ends[1]]:
			errors.append(field_error("links[%d]" % i, "'%s' joins two networks, %s and %s" % [links[i], _network_of[ends[0]], _network_of[ends[1]]]))
	for i in patrols.size():
		if not _guard_starts.has(i + 1):
			errors.append(field_error("patrols[%d]" % i, "is for guard %d, who isn't on the layout" % (i + 1)))
		for point in patrols[i].split(" ", false):
			var cell: Variant = _cell(point)
			if cell == null:
				errors.append(field_error("patrols[%d]" % i, "waypoint '%s' should be 'x,y'" % point))
			elif not in_bounds(cell) or is_wall(cell):
				errors.append(field_error("patrols[%d]" % i, "waypoint %s is off the map or a wall" % _xy(cell)))
	for id in node_facings:
		if not _nodes.has(id) or not FACINGS.has(node_facings[id]):
			errors.append(field_error("node_facings", "'%s: %s' should name a node on the layout and a facing" % [id, node_facings[id]]))
	for i in dressing.size():
		var parts := dressing[i].split(" ", false)
		if parts.size() not in [3, 4] or _cell(parts[1]) == null or not FACINGS.has(parts[2]) \
				or (parts.size() == 4 and not parts[3].is_valid_int()):
			errors.append(field_error("dressing[%d]" % i, "'%s' should read 'name x,y facing', with an optional tile count" % dressing[i]))
		elif parts.size() == 4 and parts[3].to_int() < 1:
			errors.append(field_error("dressing[%d]" % i, "tile count must be positive"))
	errors.append_array(_validate_networks())
	errors.append_array(_validate_circuits())
	errors.append_array(_validate_zones())
	for i in receptacles.size():
		var parts := receptacles[i].split(" ", false)
		if parts.size() != 2 or parts[0] not in ["dumpster", "trunk"]:
			errors.append(field_error("receptacles[%d]" % i, "'%s' should read 'dumpster x,y' or 'trunk id'" % receptacles[i]))
		elif parts[0] == "dumpster" and (_cell(parts[1]) == null or not _low.has(_cell(parts[1]))):
			errors.append(field_error("receptacles[%d]" % i, "'%s' should stand on a low obstacle (=)" % receptacles[i]))
		elif parts[0] == "trunk" and node_kind(parts[1]) not in NodeDef.VEHICLES:
			errors.append(field_error("receptacles[%d]" % i, "'%s' should name a car or truck node" % receptacles[i]))
	for id in node_states:
		if not _nodes.has(id) or not node_states[id] is String or node_states[id] not in STATE_WORDS:
			errors.append(field_error("node_states", "'%s: %s' should name a node and one of %s" % [id, node_states[id], ", ".join(STATE_WORDS)]))
	if _player_starts.is_empty():
		errors.append(field_error("layout", "has no player start (P)"))
	if _extraction.is_empty():
		errors.append(field_error("layout", "has no extraction tile (X)"))
	return errors


func _validate_networks() -> PackedStringArray:
	var errors := PackedStringArray()
	var listed := {}
	for network in networks:
		for id in str(networks[network]).split(" ", false):
			if not _nodes.has(id):
				errors.append(field_error("networks", "%s names node '%s', which isn't on the layout" % [network, id]))
			elif listed.has(id):
				errors.append(field_error("networks", "puts node '%s' on both %s and %s" % [id, listed[id], network]))
			listed[id] = network
		if not Array(str(networks[network]).split(" ", false)).any(func(id: String) -> bool: return node_kind(id) == "access"):
			errors.append(field_error("networks", "%s has no access point" % network))
	if not networks.is_empty():
		for id in _nodes:
			if not listed.has(id):
				errors.append(field_error("networks", "puts node '%s' on no network" % id))
	return errors


func _validate_circuits() -> PackedStringArray:
	var errors := PackedStringArray()
	var listed := {}
	for hub in circuits:
		if node_kind(hub) != "hub":
			errors.append(field_error("circuits", "'%s' isn't a power hub" % hub))
		for id in str(circuits[hub]).split(" ", false):
			if not _nodes.has(id):
				errors.append(field_error("circuits", "%s's circuit names node '%s', which isn't on the layout" % [hub, id]))
			elif listed.has(id):
				errors.append(field_error("circuits", "puts node '%s' on two circuits" % id))
			listed[id] = hub
	return errors


func _validate_zones() -> PackedStringArray:
	var errors := PackedStringArray()
	if zones.is_empty():
		return errors
	var cell_zone := {}
	for zone in zones:
		for token in str(zones[zone]).split(" ", false):
			if _nodes.has(token):
				continue
			var cells := _zone_cells(token)
			if cells.is_empty():
				errors.append(field_error("zones", "%s has '%s', which is no node, tile or 'x0,y0-x1,y1' rectangle on the map" % [zone, token]))
			for cell in cells:
				if cell_zone.has(cell) and cell_zone[cell] != zone:
					errors.append(field_error("zones", "puts tile %s in both %s and %s" % [_xy(cell), cell_zone[cell], zone]))
				cell_zone[cell] = zone
	for y in size.y:
		for x in size.x:
			var cell := Vector2i(x, y)
			if not _walls.has(cell) and not _node_at.has(cell) and not cell_zone.has(cell):
				errors.append(field_error("zones", "leaves tile %s in no zone" % _xy(cell)))
	for id in _nodes:
		var cell: Vector2i = _nodes[id]
		var named: String = _zone_of_node.get(id, "")
		if named != "" and cell_zone.has(cell) and cell_zone[cell] != named:
			errors.append(field_error("zones", "puts node '%s' in %s, but its tile is in %s" % [id, named, cell_zone[cell]]))
		elif named == "" and not cell_zone.has(cell):
			errors.append(field_error("zones", "leaves node '%s' in no zone" % id))
	return errors


# Each dressing line as {prop, cell, yaw, tiles}. Assumes validate() found no errors.
func dressing_items() -> Array[Dictionary]:
	var items: Array[Dictionary] = []
	for line in dressing:
		var parts := line.split(" ", false)
		items.append({
			"prop": parts[0],
			"cell": _cell(parts[1]),
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


func is_low(cell: Vector2i) -> bool:
	_parse()
	return _low.has(cell)


# A node with walls on both sides of it, in a line, is set into that wall: a panel, a wall camera,
# a door. It blocks sight like the wall does, unless it's an open door. A row of devices along a
# wall, like the dock's, counts as wall all the way along.
func in_wall(cell: Vector2i) -> bool:
	_parse()
	var walled := func(other: Vector2i) -> bool: return _walls.has(other) or _node_at.has(other)
	return (walled.call(cell + Vector2i(-1, 0)) and walled.call(cell + Vector2i(1, 0))) \
		or (walled.call(cell + Vector2i(0, -1)) and walled.call(cell + Vector2i(0, 1)))


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


func node_ids() -> Array:
	_parse()
	return _nodes.keys()


func node_cell(id: String) -> Vector2i:
	_parse()
	return _nodes[id]


func node_kind(id: String) -> String:
	return str(node_kinds.get(id, ""))


func network_of(id: String) -> String:
	_parse()
	return _network_of.get(id, "")


func circuit(hub: String) -> PackedStringArray:
	return str(circuits.get(hub, "")).split(" ", false)


func hub_of(id: String) -> String:
	_parse()
	return _circuit_of.get(id, "")


# The zone a tile belongs to, or the zone named for a node set on it. "" on a map without zones.
func zone_at(cell: Vector2i) -> String:
	_parse()
	var id: String = _node_at.get(cell, "")
	if _zone_of_node.has(id):
		return _zone_of_node[id]
	return _zone_of_cell.get(cell, "")


# Each receptacle by key, "dumpster:x,y" or "trunk:id": the dumpster's tile, or the id of the
# vehicle the trunk rides on.
func receptacle_places() -> Dictionary:
	_parse()
	return _receptacles


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
			route.append(_cell(point))
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
	for network in networks:
		for id in str(networks[network]).split(" ", false):
			_network_of[id] = network
	if networks.is_empty():
		for id in _nodes:
			_network_of[id] = "Network"
	for hub in circuits:
		for id in str(circuits[hub]).split(" ", false):
			_circuit_of[id] = hub
	for zone in zones:
		for token in str(zones[zone]).split(" ", false):
			if _nodes.has(token):
				_zone_of_node[token] = zone
			else:
				for cell in _zone_cells(token):
					_zone_of_cell[cell] = zone
	for line in receptacles:
		var parts := line.split(" ", false)
		if parts.size() == 2 and parts[0] == "dumpster" and _cell(parts[1]) != null:
			_receptacles["dumpster:" + parts[1]] = _cell(parts[1])
		elif parts.size() == 2 and parts[0] == "trunk":
			_receptacles["trunk:" + parts[1]] = parts[1]


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
		"=":
			_low[cell] = true
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


# A zone token's tiles: one tile "x,y" or a rectangle "x0,y0-x1,y1", clipped to the map.
func _zone_cells(token: String) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var corners := token.split("-")
	var first: Variant = _cell(corners[0])
	var last: Variant = _cell(corners[1]) if corners.size() == 2 else first
	if first == null or last == null or corners.size() > 2:
		return cells
	for x in range(mini(first.x, last.x), maxi(first.x, last.x) + 1):
		for y in range(mini(first.y, last.y), maxi(first.y, last.y) + 1):
			if in_bounds(Vector2i(x, y)):
				cells.append(Vector2i(x, y))
	return cells


static func _cell(text: String) -> Variant:
	var xy := text.split(",")
	if xy.size() != 2 or not xy[0].is_valid_int() or not xy[1].is_valid_int():
		return null
	return Vector2i(xy[0].to_int(), xy[1].to_int())


# Coordinates the way the map sketch and patrols write them.
static func _xy(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]
