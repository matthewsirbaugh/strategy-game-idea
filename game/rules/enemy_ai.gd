class_name EnemyAI

# The enemy's turns, and the team's Breached turrets. Guards act only on what they know: what they
# see, what their cameras show, and what they hear. An alerted guard never shoots on sight: it aims
# on its turn and fires at the start of its next, if its target is still in the line. Predict runs
# these same turns on a copy of the battle.


static func take_turn(state: BattleState, unit: Unit) -> Array[Dictionary]:
	if unit.is_turret():
		return _team_turret(state, unit) if unit.is_player() else _turret(state, unit)
	if unit.is_guard() and unit.team == UnitDef.Team.ENEMY:
		return _guard(state, unit)
	return []


static func _guard(state: BattleState, guard: Unit) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	if _skip(state, guard, events):
		return events
	events.append_array(_fire(state, guard))
	if guard.is_out() or state.winner() != BattleState.Winner.NONE:
		return events
	if guard.freeing >= 0 and _free(state, guard, events):
		return events
	match guard.task:
		Unit.Task.ALERTED:
			_chase(state, guard, events)
		Unit.Task.SEARCHING:
			_check_spot(state, guard, events)
		Unit.Task.INVESTIGATE:
			_check_spot(state, guard, events)
		_:
			_patrol(state, guard, events)
	_aim(state, guard, events)
	return events


# Stunned, blinded, or shut in a receptacle: the unit loses its turn. Turns count down here, so a
# stun of 3 skips the unit's next 3 turns.
static func _skip(state: BattleState, unit: Unit, events: Array[Dictionary]) -> bool:
	if unit.stun > 0:
		unit.stun -= 1
		events.append({"type": "stunned", "unit": unit, "turns": unit.stun})
		if unit.stun == 0 and not unit.tied:
			_wake(state, unit, events)
		return true
	if unit.receptacle != "" or unit.carried_by >= 0:
		return true
	if unit.blind > 0:
		unit.blind -= 1
		events.append({"type": "blinded", "unit": unit, "turns": unit.blind})
		return true
	return false


# Waking untied means waking alerted, with the zone on caution. Inside a receptacle the guard
# makes a noise instead, and the closest guard comes to let it out.
static func _wake(state: BattleState, unit: Unit, events: Array[Dictionary]) -> void:
	if unit.receptacle != "":
		var sound := Devices.sound(state, "", state.receptacle_cell(unit.receptacle), BattleState.WAKE_SOUND, false)
		for guard: Unit in sound.responders:
			guard.freeing = unit.id
		events.append({"type": "wake", "unit": unit, "hidden": true})
		events.append(sound)
		return
	if unit.carried_by >= 0:
		var carrier := state.units[unit.carried_by]
		carrier.carrying = -1
		unit.carried_by = -1
		unit.cell = _free_cell_near(state, carrier.cell)
	_rouse(state, unit)
	events.append({"type": "wake", "unit": unit, "hidden": false})
	state.refresh()
	events.append_array(Perception.sweep(state))


static func _rouse(state: BattleState, unit: Unit) -> void:
	unit.task = Unit.Task.ALERTED
	unit.target = -1
	unit.lead = unit.cell
	unit.look = 0
	unit.search = 0
	state.raise_caution(unit)


# A guard next to the body it came for spends its turn untying it, or letting it out of a
# receptacle. The freed guard is alerted, and so is the one who found it.
static func _free(state: BattleState, guard: Unit, events: Array[Dictionary]) -> bool:
	var body := state.units[guard.freeing]
	var inside := body.receptacle != ""
	if not (body.tied or inside) or body.carried_by >= 0 or body.down:
		guard.freeing = -1
		return false
	if Grid.distance(guard.cell, body.cell) != 1:
		return false
	body.tied = false
	body.stun = 0
	if inside:
		body.receptacle = ""
		body.cell = _free_cell_near(state, body.cell)
	_rouse(state, body)
	guard.freeing = -1
	if guard.task != Unit.Task.ALERTED:
		_rouse(state, guard)
	events.append({"type": "free", "unit": guard, "target": body})
	state.refresh()
	events.append_array(Perception.sweep(state))
	return true


static func _free_cell_near(state: BattleState, cell: Vector2i) -> Vector2i:
	for neighbor in Grid.neighbors(cell):
		if not state.blocks_walk(neighbor) and state.unit_at(neighbor) == null:
			return neighbor
	return cell


# Goes after its target's last-known position, unless it can aim from where it stands. Losing
# track there turns the alert into a search.
static func _chase(state: BattleState, guard: Unit, events: Array[Dictionary]) -> void:
	if guard.freeing >= 0:
		_walk(state, guard, state.units[guard.freeing].cell, events)
		return
	if _aim_target(state, guard) != null:
		return
	var start := guard.cell
	_walk(state, guard, guard.lead, events)
	if guard.is_out() or guard.task != Unit.Task.ALERTED or _aim_target(state, guard) != null:
		return
	if guard.cell == guard.lead or guard.cell == start:
		guard.task = Unit.Task.SEARCHING
		guard.search = BattleState.SEARCH_TURNS
		guard.lead = guard.cell
		events.append({"type": "searching", "unit": guard})


# Investigating or searching: walk to the spot, then look around there, one turn for an
# investigation and two for a search, then go back to the patrol. Noticing something while looking
# starts the check over.
static func _check_spot(state: BattleState, guard: Unit, events: Array[Dictionary]) -> void:
	if guard.cell != guard.lead and _walk(state, guard, guard.lead, events) > 0:
		return
	if _look_around(state, guard, events):
		return
	if guard.task == Unit.Task.SEARCHING:
		guard.search -= 1
		if guard.search > 0:
			return
	else:
		guard.look -= 1
		if guard.look > 0:
			return
	guard.task = Unit.Task.PATROL
	guard.target = -1
	events.append({"type": "gave_up", "unit": guard})


# Turns through all four directions. True if it noticed or saw anything.
static func _look_around(state: BattleState, guard: Unit, events: Array[Dictionary]) -> bool:
	events.append({"type": "look", "unit": guard})
	var spotted := false
	for i in 4:
		guard.facing = guard.facing.rotated(PI / 2.0)
		var seen := Perception.sweep(state)
		spotted = spotted or seen.any(func(event: Dictionary) -> bool: return event.unit == guard)
		events.append_array(seen)
		if guard.task == Unit.Task.ALERTED:
			break
	return spotted


static func _patrol(state: BattleState, guard: Unit, events: Array[Dictionary]) -> void:
	if guard.route.size() < 2:
		return
	if guard.cell == guard.route[guard.route_index]:
		guard.route_index = (guard.route_index + 1) % guard.route.size()
	if _walk(state, guard, guard.route[guard.route_index], events) == 0:
		guard.route_index = (guard.route_index + 1) % guard.route.size()


# Up to the guard's move, tile by tile, around what it knows is in the way. Walking into a hidden
# Operator stops it a tile short. It stops early to aim at someone it spots.
static func _walk(state: BattleState, guard: Unit, goal: Vector2i, events: Array[Dictionary]) -> int:
	var passable := func(cell: Vector2i) -> bool:
		if cell == goal:
			return true
		var other := state.unit_at(cell)
		return not state.blocks_walk(cell) and (other == null or not state.knows(guard, other))
	var path := Reach.new(guard.cell, 999, passable).path_to(goal)
	var was_alerted := guard.task == Unit.Task.ALERTED
	var walked: Array[Vector2i] = []
	var later: Array[Dictionary] = []
	for cell in path:
		if walked.size() >= guard.def.move or state.blocks_walk(cell):
			break
		var other := state.unit_at(cell)
		if other:
			if other.is_enemy_of(guard) and not state.knows(guard, other):
				later.append({"type": "blocked", "unit": guard, "by": other})
			break
		walked.append(cell)
		later.append_array(state.step(guard, cell))
		if guard.is_out():
			break
		if guard.task == Unit.Task.ALERTED and (not was_alerted or _aim_target(state, guard) != null):
			break
	if not walked.is_empty():
		events.append({"type": "move", "unit": guard, "path": walked})
	events.append_array(later)
	return walked.size()


# Who an alerted guard or turret would aim at from where it is: a team unit in its seen tier,
# an Operator before a robot, then the nearest.
static func _aim_target(state: BattleState, unit: Unit) -> Unit:
	var viewer := {"origin": unit.cell, "facing": unit.facing, "seen": unit.def.seen_range, "noticed": unit.def.noticed_range,
		"dark": false, "high": false, "camera": false}
	var best: Unit = null
	for target in _targets(state, unit):
		if Perception.tier(state, viewer, target.cell, false) != Perception.Tier.SEEN:
			continue
		if best == null or (target.is_operator() and not best.is_operator()) \
				or (target.is_operator() == best.is_operator() and (target.cell - unit.cell).length_squared() < (best.cell - unit.cell).length_squared()):
			best = target
	return best


static func _targets(state: BattleState, unit: Unit) -> Array[Unit]:
	var result := state.team_targets()
	for id in unit.hostile:
		if not state.units[id].is_out() and state.units[id].is_player():
			result.append(state.units[id])
	return result


# The line is fixed when the guard aims: from the guard through the target's tile, out to its
# range, which is its seen tier, shorter if the target stands in the dark.
static func _aim(state: BattleState, unit: Unit, events: Array[Dictionary]) -> void:
	if unit.task != Unit.Task.ALERTED or unit.is_out() or unit.blind > 0:
		return
	var target := _aim_target(state, unit)
	if target == null:
		return
	unit.facing = Vector2(target.cell - unit.cell).normalized()
	var reach := unit.def.seen_range if state.is_lit(target.cell) else BattleState.DARK_RANGE
	var cells := Grid.ray(unit.cell, target.cell, reach, func(cell: Vector2i) -> bool: return state.blocks_sight(cell))
	unit.aim = {"target": target.id, "cells": cells}
	unit.target = target.id
	unit.lead = target.cell
	events.append({"type": "aim", "unit": unit, "target": target, "cells": cells})


# The aim's tiles that still count: up to anything now in the way, such as a closed door, and only
# as far as the shooter can now see, so cutting the lights shortens it.
static func live_line(state: BattleState, unit: Unit, cells: Array) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell: Vector2i in cells:
		if state.blocks_sight(cell):
			break
		var reach := unit.def.seen_range if state.is_lit(cell) else BattleState.DARK_RANGE
		if not Grid.within(unit.cell, cell, reach):
			break
		result.append(cell)
	return result


# At the start of its turn: fires if its target is still in the line. The shot always hits, and
# it hits the first unit in the line, so a robot can take it for an Operator.
static func _fire(state: BattleState, unit: Unit) -> Array[Dictionary]:
	if unit.aim.is_empty():
		return []
	var aim := unit.aim
	unit.aim = {}
	var target := state.units[aim.target]
	var line := live_line(state, unit, aim.cells)
	if not target.on_map() or target.is_out() or not line.has(target.cell):
		return [{"type": "aim_lapsed", "unit": unit, "target": target}]
	var struck := target
	var candidates := _targets(state, unit)
	for cell in line:
		var in_line := candidates.filter(func(other: Unit) -> bool: return other.cell == cell)
		if not in_line.is_empty():
			struck = in_line[0]
			break
	var events: Array[Dictionary] = [{"type": "fire", "unit": unit, "target": struck}]
	events.append_array(state.hit(struck, unit))
	if unit.is_turret():
		events.append(_shot_sound(state, unit))
	state.refresh()
	events.append_array(Perception.sweep(state))
	return events


static func _shot_sound(state: BattleState, turret: Unit) -> Dictionary:
	var def := state.node_def(turret.node)
	return Devices.sound(state, turret.node, turret.cell, def.sound_radius, def.sound_all)


# An enemy turret is a guard that can't move, with a camera's cone. It turns to look at what it
# noticed, and back to its own facing when it loses track.
static func _turret(state: BattleState, turret: Unit) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	if _skip(state, turret, events):
		return events
	events.append_array(_fire(state, turret))
	if turret.is_out():
		return events
	for id in turret.hostile:
		var other := state.units[id]
		if not other.is_out() and other.is_player():
			turret.task = Unit.Task.ALERTED
			turret.lead = other.cell
	match turret.task:
		Unit.Task.ALERTED:
			if _aim_target(state, turret) == null and turret.lead != turret.cell:
				turret.facing = Vector2(turret.lead - turret.cell).normalized()
				events.append_array(Perception.sweep(state))
			if _aim_target(state, turret) == null:
				turret.task = Unit.Task.PATROL
				turret.target = -1
				turret.facing = turret.rest_facing
				events.append({"type": "gave_up", "unit": turret})
		Unit.Task.INVESTIGATE:
			if turret.lead != turret.cell:
				turret.facing = Vector2(turret.lead - turret.cell).normalized()
			events.append({"type": "look", "unit": turret})
			events.append_array(Perception.sweep(state))
			if turret.task == Unit.Task.INVESTIGATE:
				turret.task = Unit.Task.PATROL
		_:
			turret.facing = turret.rest_facing
			events.append_array(Perception.sweep(state))
	_aim(state, turret, events)
	return events


# Set to target, a Breached turret fires on its own turn at the nearest enemy it can see.
static func _team_turret(state: BattleState, turret: Unit) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	if _skip(state, turret, events) or state.devices[turret.node].mode != "target":
		return events
	var best: Unit = null
	for enemy in state.units:
		if enemy.team != UnitDef.Team.ENEMY or not enemy.on_map() or enemy.is_out():
			continue
		var reach := turret.def.seen_range if state.is_lit(enemy.cell) else BattleState.DARK_RANGE
		if not Grid.within(turret.cell, enemy.cell, reach) or not state.has_line_of_sight(turret.cell, enemy.cell):
			continue
		if best == null or (enemy.cell - turret.cell).length_squared() < (best.cell - turret.cell).length_squared():
			best = enemy
	if best == null:
		return events
	turret.facing = Vector2(best.cell - turret.cell).normalized()
	events.append({"type": "fire", "unit": turret, "target": best})
	events.append_array(state.hit(best, turret))
	if best.is_turret():
		best.hostile[turret.id] = true
	events.append(_shot_sound(state, turret))
	state.refresh()
	events.append_array(Perception.sweep(state))
	return events
