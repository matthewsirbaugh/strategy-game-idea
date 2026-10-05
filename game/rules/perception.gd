class_name Perception

# Who sees what: light and dark, the team's vision, the enemy's cones and cameras, and sound. The
# same queries feed the previews and the real thing, so a preview can't promise what play won't do.

enum Tier { NONE, NOTICED, SEEN }



static func compute_lit(state: BattleState) -> Dictionary:
	var result := {}
	if not state.map.night:
		return result
	for id in state.devices:
		var def := state.node_def(id)
		if def.light_radius <= 0 or not state.devices[id].powered:
			continue
		var origin := state.node_cell(id)
		for x in range(origin.x - def.light_radius, origin.x + def.light_radius + 1):
			for y in range(origin.y - def.light_radius, origin.y + def.light_radius + 1):
				var cell := Vector2i(x, y)
				if state.map.in_bounds(cell) and not state.map.is_wall(cell) and Grid.within(origin, cell, def.light_radius) \
						and state.has_line_of_sight(origin, cell, true):
					result[cell] = true
	return result


# Every enemy eye on the map: guards and turrets that can see, and the cameras still reporting to
# the enemy.
static func viewers(state: BattleState) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for unit in state.units:
		if unit.team != UnitDef.Team.ENEMY or unit.is_out() or unit.blind > 0 or unit.receptacle != "":
			continue
		if unit.is_guard() or unit.is_turret():
			result.append({"unit": unit, "origin": unit.cell, "facing": unit.facing, "seen": unit.def.seen_range,
				"noticed": unit.def.noticed_range, "dark": false, "high": false, "camera": false})
	for id in state.devices:
		if state.map.node_kind(id) in NodeDef.CAMERAS and state.devices[id].powered and not state.breached.has(id):
			result.append(camera_viewer(state, id))
	return result


static func camera_viewer(state: BattleState, id: String) -> Dictionary:
	var def := state.node_def(id)
	return {"node": id, "origin": state.node_cell(id), "facing": Vector2(state.devices[id].facing), "seen": def.seen_range,
		"noticed": def.noticed_range, "dark": def.sees_dark, "high": true, "camera": true}


# How well a viewer sees a tile. Guards in the dark still see a short way and notice the rest of the
# cone; ordinary cameras see only lit tiles. During caution, the noticed tier counts as seen.
static func tier(state: BattleState, viewer: Dictionary, cell: Vector2i, with_caution := true) -> Tier:
	var origin: Vector2i = viewer.origin
	if cell == origin or not Grid.in_cone(origin, viewer.facing, cell) or not Grid.within(origin, cell, viewer.noticed):
		return Tier.NONE
	if not state.has_line_of_sight(origin, cell, viewer.high):
		return Tier.NONE
	var result := Tier.NOTICED
	if viewer.dark or state.is_lit(cell):
		result = Tier.SEEN if Grid.within(origin, cell, viewer.seen) else Tier.NOTICED
	elif viewer.camera:
		return Tier.NONE
	elif Grid.within(origin, cell, BattleState.DARK_RANGE):
		result = Tier.SEEN
	if result == Tier.NOTICED and with_caution and not viewer.camera and state.caution.has(state.map.zone_at(origin)):
		result = Tier.SEEN
	return result


# Every tile a viewer's cone covers, by tier, for drawing it.
static func cone_cells(state: BattleState, viewer: Dictionary) -> Dictionary:
	var result := {}
	var origin: Vector2i = viewer.origin
	var reach: int = ceili(viewer.noticed)
	for x in range(origin.x - reach, origin.x + reach + 1):
		for y in range(origin.y - reach, origin.y + reach + 1):
			var cell := Vector2i(x, y)
			if state.map.in_bounds(cell) and not state.map.is_wall(cell):
				var level := tier(state, viewer, cell)
				if level != Tier.NONE:
					result[cell] = level
	return result


# The team's live vision: Operators and robots (a small window in the dark, but lit tiles as far as
# they can see), peeks through doors, and Breached cameras that are powered on.
static func team_vision(state: BattleState) -> Dictionary:
	var result := {}
	for unit in state.units:
		if not unit.is_player() or not unit.on_map() or unit.is_out():
			continue
		if unit.is_operator() or unit.is_robot():
			_add_sight(state, result, unit.cell, unit.def.sight, unit.def.flies)
	if state.active and state.active.is_operator():
		for door in state.active.peeks:
			_add_sight(state, result, state.node_cell(door), state.active.def.sight, false)
	for id in state.devices:
		if state.map.node_kind(id) in NodeDef.CAMERAS and state.breached.has(id) and state.devices[id].powered:
			var viewer := camera_viewer(state, id)
			for cell in cone_cells(state, viewer):
				result[cell] = true
			result[viewer.origin] = true
	return result


static func _add_sight(state: BattleState, result: Dictionary, origin: Vector2i, radius: int, high: bool) -> void:
	for x in range(origin.x - radius, origin.x + radius + 1):
		for y in range(origin.y - radius, origin.y + radius + 1):
			var cell := Vector2i(x, y)
			var distance := Grid.distance(origin, cell)
			if not state.map.in_bounds(cell) or distance > radius:
				continue
			if distance > BattleState.DARK_RANGE and not state.is_lit(cell):
				continue
			if state.has_line_of_sight(origin, cell, high):
				result[cell] = true


# What the enemy notices right now. A guard or turret that sees a team unit is alerted at once; one
# that notices it marks the spot. A camera never alerts: it sends the closest guard to look. A guard
# who sees a body raises a full alert.
static func sweep(state: BattleState) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	var targets := state.team_targets()
	var seen_by_cameras := {}
	for viewer in viewers(state):
		var in_view := {}
		var was: Dictionary = state.camera_views.get(viewer.node, {}) if viewer.camera else viewer.unit.in_view
		for target in targets:
			var level := tier(state, viewer, target.cell)
			if level == Tier.NONE:
				continue
			in_view[target.id] = true
			if viewer.camera:
				seen_by_cameras[target.id] = target.cell
				if not was.has(target.id):
					_camera_report(state, viewer.node, target.cell, events)
				continue
			var unit: Unit = viewer.unit
			if unit.task == Unit.Task.ALERTED and unit.target == target.id:
				unit.lead = target.cell
			if level == Tier.SEEN:
				_alert(state, unit, target, events)
			elif not was.has(target.id):
				_notice(state, unit, target.cell, events)
		for body in state.bodies():
			if state.discovered.has(body.id):
				continue
			var level := tier(state, viewer, body.cell)
			if level == Tier.NONE:
				continue
			if viewer.camera:
				in_view[body.id] = true
				if not was.has(body.id):
					_camera_report(state, viewer.node, body.cell, events)
			elif level == Tier.SEEN and viewer.unit.is_guard():
				_discover(state, viewer.unit, body, events)
		if viewer.camera:
			state.camera_views[viewer.node] = in_view
		else:
			viewer.unit.in_view = in_view
	for unit in state.units:
		if unit.task == Unit.Task.ALERTED and seen_by_cameras.has(unit.target):
			unit.lead = seen_by_cameras[unit.target]
	return events


static func _alert(state: BattleState, unit: Unit, target: Unit, events: Array[Dictionary]) -> void:
	# An alerted guard sticks to its target, unless it was a robot and now it can see an Operator.
	if unit.task == Unit.Task.ALERTED and unit.target >= 0:
		var current := state.units[unit.target]
		if unit.target == target.id or (not current.is_out() and (current.is_operator() or not target.is_operator())):
			return
	unit.task = Unit.Task.ALERTED
	unit.target = target.id
	unit.lead = target.cell
	unit.look = 0
	unit.search = 0
	unit.freeing = -1
	state.raise_caution(unit)
	events.append({"type": "alert", "unit": unit, "target": target})


static func _notice(state: BattleState, unit: Unit, cell: Vector2i, events: Array[Dictionary]) -> void:
	if unit.task == Unit.Task.ALERTED:
		return
	if unit.task != Unit.Task.SEARCHING:
		unit.task = Unit.Task.INVESTIGATE
		unit.look = BattleState.LOOK_TURNS
	unit.lead = cell if unit.is_turret() else approach(state, cell)
	events.append({"type": "notice", "unit": unit, "cell": cell})


static func _camera_report(state: BattleState, camera: String, cell: Vector2i, events: Array[Dictionary]) -> void:
	var responders := responders_to(state, cell, 999, false)
	for guard in responders:
		investigate(state, guard, cell)
	events.append({"type": "camera_report", "unit": null, "node": camera, "cell": cell, "responders": responders})


static func _discover(state: BattleState, unit: Unit, body: Unit, events: Array[Dictionary]) -> void:
	state.discovered[body.id] = true
	if unit.task != Unit.Task.ALERTED:
		unit.task = Unit.Task.ALERTED
		unit.target = -1
		unit.lead = approach(state, body.cell)
	if body.tied:
		unit.freeing = body.id
	state.raise_caution(unit)
	events.append({"type": "found_body", "unit": unit, "body": body})


static func investigate(state: BattleState, guard: Unit, cell: Vector2i) -> void:
	guard.task = Unit.Task.INVESTIGATE
	guard.lead = approach(state, cell)
	guard.look = BattleState.LOOK_TURNS


# Guards free to answer a lure: patrolling, not out, not blinded. "Closest" counts walking steps.
# A visual lure only draws guards who can see it.
static func responders_to(state: BattleState, cell: Vector2i, radius: int, everyone: bool, must_see := false) -> Array[Unit]:
	var steps := sound_reach(state, cell, radius)
	var result: Array[Unit] = []
	var best := -1
	for unit in state.units:
		if not unit.is_guard() or unit.team != UnitDef.Team.ENEMY or unit.is_out() or unit.blind > 0 \
				or unit.receptacle != "" or unit.task != Unit.Task.PATROL or not steps.has(unit.cell):
			continue
		if must_see and (not Grid.within(unit.cell, cell, unit.def.noticed_range) or not state.has_line_of_sight(unit.cell, cell)):
			continue
		if everyone:
			result.append(unit)
		elif best < 0 or steps[unit.cell] < best:
			best = steps[unit.cell]
			result = [unit]
	return result


# Walking steps from a source, around walls and through open doors; a closed door stops it.
static func sound_reach(state: BattleState, from: Vector2i, radius: int) -> Dictionary:
	var steps := {from: 0}
	var frontier: Array[Vector2i] = [from]
	var next := 0
	while next < frontier.size():
		var current := frontier[next]
		next += 1
		if steps[current] >= radius:
			continue
		for cell in Grid.neighbors(current):
			if steps.has(cell) or not _carries_sound(state, cell):
				continue
			steps[cell] = steps[current] + 1
			frontier.append(cell)
	return steps


static func _carries_sound(state: BattleState, cell: Vector2i) -> bool:
	if not state.map.in_bounds(cell) or state.map.is_wall(cell):
		return false
	var id := state.node_at(cell)
	if id == "":
		return true
	if state.map.node_kind(id) in NodeDef.DOORS:
		return state.devices[id].open
	return not state.map.in_wall(cell)


# The walkable tile nearest a spot, where a guard goes to check it.
static func approach(state: BattleState, cell: Vector2i) -> Vector2i:
	if not state.blocks_walk(cell):
		return cell
	var steps := sound_reach(state, cell, 6)
	var best := cell
	var best_steps := 999
	for other in steps:
		if other != cell and not state.blocks_walk(other) and steps[other] < best_steps:
			best = other
			best_steps = steps[other]
	return best
