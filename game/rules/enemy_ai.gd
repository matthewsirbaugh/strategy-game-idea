class_name EnemyAI

# Enemies act only on what they can see right now, plus a memory of where they last saw an
# Operator. A patrolling guard that spots someone is alerted and acts on its next turn, so walking
# into view is dangerous but not instantly punished.


static func take_turn(state: BattleState, unit: Unit) -> Array[Dictionary]:
	if unit.disabled:
		return []
	var seen := state.seen_enemies(unit)
	if not seen.is_empty():
		return _engage(state, unit, seen)
	if unit.def.move == 0:
		unit.alerted = false
		return []
	if unit.has_lead:
		return _investigate(state, unit)
	unit.alerted = false
	var events := _patrol(state, unit)
	_notice(state, unit, events)
	return events


static func _engage(state: BattleState, unit: Unit, seen: Array[Unit]) -> Array[Dictionary]:
	_remember(unit, seen)
	var events: Array[Dictionary] = []
	if _targets(state, unit, unit.cell, seen).is_empty() and unit.def.move > 0:
		var destination := _attack_position(state, unit, seen)
		if destination == unit.cell:
			destination = _toward(state, unit, unit.lead)
		if destination != unit.cell:
			events.append_array(state.move(unit, destination))
	# Looks again after moving, so it can shoot someone the move revealed.
	var in_range := _targets(state, unit, unit.cell, state.seen_enemies(unit))
	if not in_range.is_empty():
		events.append_array(state.attack(unit, _weakest(in_range)))
	return events


static func _targets(state: BattleState, unit: Unit, from: Vector2i, seen: Array[Unit]) -> Array[Unit]:
	var result: Array[Unit] = []
	for target in state.attack_targets(unit, from):
		if seen.has(target):
			result.append(target)
	return result


# Heads for where it last saw an Operator, and gives up once there with nobody in sight.
static func _investigate(state: BattleState, unit: Unit) -> Array[Dictionary]:
	unit.alerted = false
	unit.searching = true
	var events: Array[Dictionary] = []
	var start := unit.cell
	var destination := _toward(state, unit, unit.lead)
	if destination != unit.cell:
		events.append_array(state.move(unit, destination))
	if _notice(state, unit, events):
		return events
	if unit.cell == unit.lead or unit.cell == start:
		unit.has_lead = false
		unit.searching = false
		events.append({"type": "lost", "unit": unit})
	return events


static func _notice(state: BattleState, unit: Unit, events: Array[Dictionary]) -> bool:
	var seen := state.seen_enemies(unit)
	if seen.is_empty():
		return false
	_remember(unit, seen)
	events.append({"type": "alert", "unit": unit})
	return true


static func _remember(unit: Unit, seen: Array[Unit]) -> void:
	unit.alerted = true
	unit.searching = false
	unit.has_lead = true
	unit.lead = _nearest(unit, seen).cell


static func _patrol(state: BattleState, unit: Unit) -> Array[Dictionary]:
	if unit.route.size() < 2:
		return []
	if unit.cell == unit.route[unit.route_index]:
		unit.route_index = (unit.route_index + 1) % unit.route.size()
	var destination := _toward(state, unit, unit.route[unit.route_index])
	if destination == unit.cell:
		unit.route_index = (unit.route_index + 1) % unit.route.size()
		return []
	return state.move(unit, destination)


# The cheapest tile this turn from which a seen target can be attacked; the current tile if none.
static func _attack_position(state: BattleState, unit: Unit, seen: Array[Unit]) -> Vector2i:
	var costs := state.reach(unit, unit.def.move).cost
	var best := unit.cell
	var best_cost := -1
	for cell in state.destinations(unit):
		if _targets(state, unit, cell, seen).is_empty():
			continue
		if best_cost < 0 or costs[cell] < best_cost:
			best = cell
			best_cost = costs[cell]
	return best


# The farthest tile along a path to the goal that the unit can end on this turn.
static func _toward(state: BattleState, unit: Unit, goal: Vector2i) -> Vector2i:
	var passable := func(cell: Vector2i) -> bool: return cell == goal or state.can_pass(unit, cell)
	var path := Reach.new(unit.cell, 999, passable).path_to(goal)
	var allowed := state.destinations(unit)
	var best := unit.cell
	for i in mini(path.size(), unit.def.move):
		if allowed.has(path[i]):
			best = path[i]
	return best


static func _nearest(unit: Unit, targets: Array[Unit]) -> Unit:
	var best: Unit = targets[0]
	for target in targets:
		if Grid.distance(unit.cell, target.cell) < Grid.distance(unit.cell, best.cell):
			best = target
	return best


static func _weakest(targets: Array[Unit]) -> Unit:
	var best: Unit = targets[0]
	for target in targets:
		if target.hp < best.hp:
			best = target
	return best
