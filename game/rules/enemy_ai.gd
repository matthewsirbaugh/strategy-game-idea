class_name EnemyAI

# Enemies act only on what they can see right now. A patrolling guard that spots an Operator is
# alerted and acts on its next turn, so walking into view is dangerous but not instantly punished.


static func take_turn(state: BattleState, unit: Unit) -> Array[Dictionary]:
	if state.seen_enemies(unit).is_empty():
		unit.alerted = false
		var patrol_events := _patrol(state, unit)
		if not state.seen_enemies(unit).is_empty():
			unit.alerted = true
			patrol_events.append({"type": "alert", "unit": unit})
		return patrol_events
	unit.alerted = true
	var events: Array[Dictionary] = []
	if state.attack_targets(unit, unit.cell).is_empty() and unit.def.move > 0:
		var destination := _attack_position(state, unit)
		if destination == unit.cell:
			destination = _toward(state, unit, _nearest(unit, state.seen_enemies(unit)).cell)
		if destination != unit.cell:
			events.append_array(state.move(unit, destination))
	var in_range := state.attack_targets(unit, unit.cell)
	if not in_range.is_empty():
		events.append_array(state.attack(unit, _weakest(in_range)))
	return events


static func _patrol(state: BattleState, unit: Unit) -> Array[Dictionary]:
	if unit.route.size() < 2 or unit.def.move == 0:
		return []
	if unit.cell == unit.route[unit.route_index]:
		unit.route_index = (unit.route_index + 1) % unit.route.size()
	var destination := _toward(state, unit, unit.route[unit.route_index])
	if destination == unit.cell:
		unit.route_index = (unit.route_index + 1) % unit.route.size()
		return []
	return state.move(unit, destination)


# The cheapest tile this turn from which some target can be attacked; the current tile if none.
static func _attack_position(state: BattleState, unit: Unit) -> Vector2i:
	var costs := state.reach(unit, unit.def.move).cost
	var best := unit.cell
	var best_cost := -1
	for cell in state.destinations(unit):
		if state.attack_targets(unit, cell).is_empty():
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
