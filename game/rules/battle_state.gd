class_name BattleState
extends RefCounted

# Actions return events (plain dictionaries with a "type") so the view can animate them in
# order without the rules knowing anything about the view.

enum Winner { NONE, PLAYER, ENEMY }

var map: MapData
var units: Array[Unit] = []
var round_number := 0
var active: Unit
# The player's side of the fog: tiles in live vision, and where each enemy was last seen.
var visible_cells := {}
var known := {}
var vision_sources: Array[Dictionary] = []
var _queue: Array[Unit] = []
var _open_doors := {}


func _init(p_map: MapData, operators: Array[UnitDef], guard: UnitDef, turret: UnitDef) -> void:
	map = p_map
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
	active.moved = false
	active.acted = false
	active.revealed = false
	active.move_origin = active.cell
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
	return events


func can_undo(unit: Unit) -> bool:
	return unit.moved and not unit.acted and not unit.revealed


func undo_move(unit: Unit) -> void:
	unit.cell = unit.move_origin
	unit.moved = false
	refresh_vision()


func attack(unit: Unit, target: Unit) -> Array[Dictionary]:
	target.hp = maxi(target.hp - unit.def.damage, 0)
	unit.acted = true
	var events: Array[Dictionary] = [
		{"type": "attack", "unit": unit, "target": target, "damage": unit.def.damage}
	]
	if target.is_down():
		events.append({"type": "downed", "unit": target})
		refresh_vision()
	return events


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
