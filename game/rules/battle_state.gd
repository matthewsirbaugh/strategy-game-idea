class_name BattleState
extends RefCounted

# Actions return events (plain dictionaries with a "type") so the view can animate them in
# order without the rules knowing anything about the view.

enum Winner { NONE, PLAYER, ENEMY }
# An Operator's turn is split: the human acts, then their AI does.
enum Phase { HUMAN, AGENT }

const CONTEXT_MAX := 100
const FULL_CONTEXT_YIELD := 0.5
const COMPACT_KEEPS := 0.25

var map: MapData
var units: Array[Unit] = []
var round_number := 0
var active: Unit
var phase := Phase.HUMAN
# The player's side of the fog: tiles in live vision, and where each enemy was last seen.
var visible_cells := {}
var known := {}
var vision_sources: Array[Dictionary] = []
var breach := {}
var breached := {}
var cache_breached := false
var _node_defs := {}
var _links := {}
var _queue: Array[Unit] = []
var _open_doors := {}


func _init(p_map: MapData, operators: Array[UnitDef], guard: UnitDef, turret: UnitDef, node_defs: Array[NodeDef]) -> void:
	map = p_map
	for def in node_defs:
		_node_defs[def.kind] = def
	for link in map.links:
		var ends := link.split("-")
		_links.get_or_add(ends[0], []).append(ends[1])
		_links.get_or_add(ends[1], []).append(ends[0])
	var starts := map.player_starts()
	for i in mini(starts.size(), operators.size()):
		_add(operators[i], operators[i].display_name, starts[i])
	for number in map.guard_numbers():
		var route := map.guard_route(number)
		var unit := _add(guard, "Guard %d" % number, route[0])
		unit.route = route
	for id in map.node_ids():
		if map.node_kind(id) == "turret":
			_add(turret, turret.display_name, map.node_cell(id))
	# Pre-mission intel: the player starts knowing where every enemy was posted.
	for unit in units:
		if not unit.is_player():
			known[unit.id] = unit.cell
	refresh_vision()


func begin_next_turn() -> Unit:
	active = null
	if winner() != Winner.NONE:
		return null
	while active == null:
		if _queue.is_empty():
			round_number += 1
			_queue = living()
			_queue.sort_custom(_acts_before)
		var next: Unit = _queue.pop_front()
		if not next.is_down():
			active = next
	phase = Phase.HUMAN
	active.moved = false
	active.acted = false
	active.revealed = false
	active.move_origin = active.cell
	active.agent_origin = active.agent_node
	active.entry_origin = active.entry
	return active


func upcoming() -> Array[Unit]:
	var result: Array[Unit] = []
	if active:
		result.append(active)
	for unit in _queue:
		if not unit.is_down():
			result.append(unit)
	return result


func living() -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in units:
		if not unit.is_down():
			result.append(unit)
	return result


func unit_at(cell: Vector2i) -> Unit:
	for unit in units:
		if unit.cell == cell and not unit.is_down():
			return unit
	return null


func blocks_movement(cell: Vector2i) -> bool:
	if not map.in_bounds(cell) or map.is_wall(cell):
		return true
	var node := map.node_at(cell)
	return node != "" and (map.node_kind(node) != "door" or not _open_doors.has(node))


func blocks_sight(cell: Vector2i) -> bool:
	if not map.in_bounds(cell) or map.is_wall(cell):
		return true
	var node := map.node_at(cell)
	return node != "" and map.node_kind(node) == "door" and not _open_doors.has(node)


func has_line_of_sight(from: Vector2i, to: Vector2i) -> bool:
	return Grid.line_clear(from, to, blocks_sight)


func sees(viewer: Unit, cell: Vector2i) -> bool:
	return Grid.distance(viewer.cell, cell) <= viewer.def.sight and has_line_of_sight(viewer.cell, cell)


func seen_enemies(viewer: Unit) -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in units:
		if not unit.is_down() and unit.is_enemy_of(viewer) and sees(viewer, unit.cell):
			result.append(unit)
	return result


# Structures like the turret are always on the map; everything else needs live vision.
func player_sees(unit: Unit) -> bool:
	return unit.is_player() or unit.def.move == 0 or visible_cells.has(unit.cell)


func refresh_vision() -> void:
	visible_cells.clear()
	for unit in living():
		if unit.is_player():
			_add_vision(unit.cell, unit.def.sight)
	for source in vision_sources:
		_add_vision(source["cell"], source["radius"])
	for unit in living():
		if unit.is_player():
			continue
		if player_sees(unit):
			known[unit.id] = unit.cell
		elif known.has(unit.id) and visible_cells.has(known[unit.id]):
			known.erase(unit.id)


# Players plan around what they can see: hidden enemies don't block their plans, they
# interrupt the move when walked into.
func can_pass(unit: Unit, cell: Vector2i) -> bool:
	if blocks_movement(cell):
		return false
	var other := unit_at(cell)
	if other == null or not other.is_enemy_of(unit):
		return true
	return unit.is_player() and not player_sees(other)


func reach(unit: Unit, max_cost: int) -> Reach:
	return Reach.new(unit.cell, max_cost, func(cell: Vector2i) -> bool: return can_pass(unit, cell))


# Includes the unit's own tile, so staying put is always an option.
func destinations(unit: Unit) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if unit.moved:
		return result
	for cell in reach(unit, unit.def.move).cost:
		var other := unit_at(cell)
		if other == null or other == unit or (unit.is_player() and other.is_enemy_of(unit) and not player_sees(other)):
			result.append(cell)
	return result


func can_attack(unit: Unit, target: Unit, from: Vector2i) -> bool:
	if unit.acted or target.is_down() or not unit.is_enemy_of(target):
		return false
	var distance := Grid.distance(from, target.cell)
	return distance <= unit.def.attack_range and (distance <= 1 or has_line_of_sight(from, target.cell))


func attack_targets(unit: Unit, from: Vector2i) -> Array[Unit]:
	var result: Array[Unit] = []
	for target in units:
		if can_attack(unit, target, from) and (not unit.is_player() or player_sees(target)):
			result.append(target)
	return result


func move(unit: Unit, cell: Vector2i) -> Array[Dictionary]:
	var start := unit.cell
	var walked: Array[Vector2i] = []
	var blocker: Unit = null
	for step in reach(unit, unit.def.move).path_to(cell):
		var other := unit_at(step)
		if other and other.is_enemy_of(unit):
			blocker = other
			break
		walked.append(step)
	while not walked.is_empty() and unit_at(walked.back()) != null:
		walked.pop_back()
	if not walked.is_empty():
		unit.cell = walked.back()
	unit.moved = true
	if not unit.is_player():
		_track(unit, [start] + walked)
	var seen_before := _seen_enemy_ids()
	refresh_vision()
	unit.revealed = blocker != null
	for id in _seen_enemy_ids():
		if not seen_before.has(id):
			unit.revealed = true
	var events: Array[Dictionary] = [{"type": "move", "unit": unit, "path": walked}]
	if blocker:
		events.append({"type": "blocked", "unit": unit, "by": blocker})
	if unit.agent_node != "" and Grid.distance(unit.cell, map.node_cell(unit.entry)) > unit.def.tether_range:
		_disconnect(unit)
		events.append({"type": "disconnect", "unit": unit})
	return events


func can_undo(unit: Unit) -> bool:
	return phase == Phase.HUMAN and unit.moved and not unit.acted and not unit.revealed


func undo_move(unit: Unit) -> void:
	unit.cell = unit.move_origin
	unit.moved = false
	unit.agent_node = unit.agent_origin
	unit.entry = unit.entry_origin
	refresh_vision()


func attack(unit: Unit, target: Unit) -> Array[Dictionary]:
	target.hp = maxi(target.hp - unit.def.damage, 0)
	unit.acted = true
	var events: Array[Dictionary] = [
		{"type": "attack", "unit": unit, "target": target, "damage": unit.def.damage}
	]
	if target.is_down():
		_disconnect(target)
		events.append({"type": "downed", "unit": target})
		refresh_vision()
	return events


func node_def(id: String) -> NodeDef:
	return _node_defs.get(map.node_kind(id))


func is_door_open(id: String) -> bool:
	return _open_doors.has(id)


func network_path(from: String, to: String) -> Array[String]:
	var came_from := {from: from}
	var frontier: Array[String] = [from]
	while not frontier.is_empty():
		var current: String = frontier.pop_front()
		for next in _links.get(current, []):
			if not came_from.has(next):
				came_from[next] = current
				frontier.append(next)
	var path: Array[String] = []
	if not came_from.has(to):
		return path
	var step := to
	while step != from:
		path.push_front(step)
		step = came_from[step]
	return path


func agent_destinations(unit: Unit) -> Array[String]:
	var result: Array[String] = []
	if unit.agent_node == "":
		return result
	for id in map.node_ids():
		var hops := network_path(unit.agent_node, id).size()
		if hops > 0 and hops <= unit.def.network_range:
			result.append(id)
	return result


func access_point_in_reach(unit: Unit) -> String:
	var best := ""
	var best_distance := 0
	for id in map.node_ids():
		var distance := Grid.distance(unit.cell, map.node_cell(id))
		if map.node_kind(id) == "access" and distance <= unit.def.tether_range and (best == "" or distance < best_distance):
			best = id
			best_distance = distance
	return best


func can_connect(unit: Unit) -> bool:
	return unit.agent_node != "" or access_point_in_reach(unit) != ""


# The AI plugs in when the human's part of the turn ends near an access point.
func end_human_phase(unit: Unit) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	if unit.agent_node == "":
		var access := access_point_in_reach(unit)
		if access != "":
			unit.agent_node = access
			unit.entry = access
			events.append({"type": "connect", "unit": unit, "node": access})
	if unit.agent_node != "":
		phase = Phase.AGENT
	return events


func agent_move(unit: Unit, id: String) -> Array[Dictionary]:
	var path := network_path(unit.agent_node, id)
	unit.agent_node = id
	return [{"type": "agent_move", "unit": unit, "path": path}]


func can_hack(unit: Unit) -> bool:
	var def := node_def(unit.agent_node)
	return def != null and def.goal > 0 and not breached.has(unit.agent_node)


func hack_yield(unit: Unit) -> int:
	if unit.context >= CONTEXT_MAX:
		return int(unit.def.hack_power * FULL_CONTEXT_YIELD)
	return unit.def.hack_power


func hack(unit: Unit) -> Array[Dictionary]:
	var id := unit.agent_node
	var def := node_def(id)
	var points := hack_yield(unit)
	breach[id] = breach.get(id, 0) + points
	unit.context = mini(CONTEXT_MAX, unit.context + def.context_cost)
	var events: Array[Dictionary] = [{"type": "hack", "unit": unit, "node": id, "points": points}]
	if breach[id] >= def.goal:
		events.append(_breach(unit, id))
	return events


func compacted(context: int) -> int:
	return roundi(context * COMPACT_KEEPS)


func compact(unit: Unit) -> Array[Dictionary]:
	var before := unit.context
	unit.context = compacted(before)
	return [{"type": "compact", "unit": unit, "before": before}]


func can_toggle_door(unit: Unit) -> bool:
	var id := unit.agent_node
	return breached.has(id) and map.node_kind(id) == "door" and unit_at(map.node_cell(id)) == null


func toggle_door(unit: Unit) -> Array[Dictionary]:
	var id := unit.agent_node
	if _open_doors.has(id):
		_open_doors.erase(id)
	else:
		_open_doors[id] = true
	refresh_vision()
	return [{"type": "door", "unit": unit, "node": id, "open": _open_doors.has(id)}]


func _breach(unit: Unit, id: String) -> Dictionary:
	breached[id] = true
	match map.node_kind(id):
		"door":
			_open_doors[id] = true
		"camera":
			vision_sources.append({"cell": map.node_cell(id), "radius": node_def(id).vision_radius})
		"turret":
			var turret := unit_at(map.node_cell(id))
			if turret:
				turret.disabled = true
		"cache":
			cache_breached = true
	refresh_vision()
	return {"type": "breach", "unit": unit, "node": id}


func _disconnect(unit: Unit) -> void:
	unit.agent_node = ""
	unit.entry = ""


func winner() -> Winner:
	var players := false
	var enemies := false
	for unit in living():
		if unit.is_player():
			players = true
		else:
			enemies = true
	if not players:
		return Winner.ENEMY
	if not enemies:
		return Winner.PLAYER
	return Winner.NONE


func _add(def: UnitDef, unit_name: String, cell: Vector2i) -> Unit:
	var unit := Unit.new(units.size(), def, unit_name, cell)
	units.append(unit)
	return unit


func _add_vision(from: Vector2i, radius: int) -> void:
	for x in range(from.x - radius, from.x + radius + 1):
		for y in range(from.y - radius, from.y + radius + 1):
			var cell := Vector2i(x, y)
			if map.in_bounds(cell) and Grid.distance(from, cell) <= radius and has_line_of_sight(from, cell):
				visible_cells[cell] = true


func _seen_enemy_ids() -> Dictionary:
	var ids := {}
	for unit in living():
		if not unit.is_player() and player_sees(unit):
			ids[unit.id] = true
	return ids


# The tile where the player watched an enemy vanish into the fog becomes its last known position.
func _track(unit: Unit, steps: Array) -> void:
	var in_view := false
	for step in steps:
		if visible_cells.has(step):
			known[unit.id] = step
			in_view = true
		elif in_view:
			known[unit.id] = step
			in_view = false


func _acts_before(a: Unit, b: Unit) -> bool:
	if a.def.speed != b.def.speed:
		return a.def.speed > b.def.speed
	if a.is_player() != b.is_player():
		return a.is_player()
	return a.id < b.id
