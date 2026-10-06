extends SceneTree

# Whole battles on the test map, played by picking at random among everything the rules offer.
# Checks after every action that an offer was honored, that nothing impossible happened, and that
# Predict and the verb previews told the truth. Seeded, so a failure replays exactly.
# Run: godot --headless --path game -s tests/test_playthrough.gd

const SEEDS := 3
const TURNS := 250

var _failures := 0


func _initialize() -> void:
	var map: MapData = load("res://content/maps/facility_exterior.tres")
	var content: BattleContent = load("res://content/battle.tres")
	for seed in SEEDS:
		_play(BattleSession.from_presets(map, content).start(), seed)
	print("playthrough tests: " + ("all passed" if _failures == 0 else "%d failed" % _failures))
	quit(1 if _failures > 0 else 0)


func _play(state: BattleState, seed: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	for turn in TURNS:
		var unit := state.begin_next_turn()
		if unit == null:
			return
		var where := "seed %d, round %d, %s" % [seed, state.round_number, unit.display_name]
		if not state.is_player_controlled(unit):
			var ghost := state.prediction(unit) if unit.is_guard() and unit.team == UnitDef.Team.ENEMY else {}
			var path: Array = ghost.get("path", []).slice(0, 1)
			for event in state.take_automatic_turn():
				if event.type == "move" and event.unit == unit:
					path.append_array(event.path)
			_check(ghost.is_empty() or ghost.path == path, "%s: Predict showed %s, the guard walked %s" % [where, ghost.get("path"), path])
			_invariants(state, where)
			continue
		for action in 30:
			if state.active != unit or state.turn_over:
				break
			var choice := _choose(_options(state, unit, rng), rng)
			_check(not choice.run.call().is_empty(), "%s: the rules refused '%s', which they offered" % [where, choice.label])
			_invariants(state, "%s, after %s" % [where, choice.label])
		state.end_turn(unit)


func _choose(options: Array[Dictionary], rng: RandomNumberGenerator) -> Dictionary:
	var roll: float = rng.randf() * options.reduce(func(total: float, option: Dictionary) -> float: return total + option.weight, 0.0)
	for option in options:
		roll -= option.weight
		if roll <= 0.0:
			return option
	return options.back()


# A runnable choice for each kind of action the menus would offer the unit, with targets drawn from
# the same lists the menus use. The weights steer the team toward the network, where most of the
# rules are, and keep each turn going for a while.
func _options(state: BattleState, unit: Unit, rng: RandomNumberGenerator) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var add := func(label: String, weight: float, run: Callable) -> void: result.append({"label": label, "weight": weight, "run": run})
	var pick := func(items: Array) -> Variant: return items[rng.randi() % items.size()]
	add.call("end turn", 0.3, func() -> Array: return state.end_turn(unit))
	for sprint in [false, true]:
		var costs := state.move_costs(unit, sprint)
		if costs.is_empty():
			continue
		var cells := costs.keys()
		var goal := _goal(state, unit)
		var nearest: Vector2i = cells.reduce(func(best: Vector2i, cell: Vector2i) -> Vector2i:
			return cell if Grid.distance(cell, goal) < Grid.distance(best, goal) else best, cells[0])
		var any: Vector2i = pick.call(cells)
		add.call("move to %s" % nearest, 2.0, func() -> Array: return state.move(unit, nearest, sprint))
		add.call("move to %s" % any, 1.0, func() -> Array: return state.move(unit, any, sprint))
	if unit.is_robot():
		for target in state.dog_stun_targets(unit):
			add.call("dog stun", 2.0, func() -> Array: return state.dog_stun(unit, target))
		return result
	for target in state.shot_targets(unit):
		add.call("shoot %s" % target.display_name, 2.0, func() -> Array: return state.shoot(unit, target))
	if state.can_shoot(unit):
		add.call("overwatch", 0.3, func() -> Array: return state.set_overwatch(unit))
	for option in state.door_options(unit):
		add.call("%s door %s" % [option.action, option.node], 0.5, func() -> Array: return state.use_door(unit, option.node, option.action))
	for id in state.peek_options(unit):
		add.call("peek %s" % id, 0.3, func() -> Array: return state.peek(unit, id))
	for option in state.deploy_options(unit):
		add.call("deploy at %s" % option.access, 4.0, func() -> Array: return state.deploy_ai(unit, option.access, option.relay))
	for body in state.tie_targets(unit):
		add.call("tie up", 2.0, func() -> Array: return state.tie_up(unit, body))
	for body in state.pickup_targets(unit):
		add.call("pick up", 1.0, func() -> Array: return state.pick_up(unit, body))
	for cell in state.putdown_cells(unit):
		add.call("put down at %s" % cell, 1.0, func() -> Array: return state.put_down(unit, cell))
	for cell in state.flashbang_cells(unit).slice(0, 1):
		add.call("flashbang", 0.3, func() -> Array: return state.throw_flashbang(unit, cell))
	for cell in state.robot_cells(unit).slice(0, 1):
		add.call("deploy robot", 0.5, func() -> Array: return state.deploy_robot(unit, cell))
	for other in state.share_targets(unit):
		add.call("share compute", 0.3, func() -> Array: return state.share_compute(unit, other))
	var hops := state.network_destinations(unit)
	if not hops.is_empty():
		var id: String = pick.call(hops)
		add.call("network move to %s" % id, 3.0, func() -> Array: return state.ai_move(unit, id))
	if state.can_hack(unit):
		add.call("hack %s" % unit.ai_node, 6.0, func() -> Array: return state.hack(unit))
		for linked in state.subagent_links(unit):
			add.call("hack with a subagent on %s" % linked, 6.0, func() -> Array: return state.hack(unit, linked))
	if state.can_compact(unit):
		add.call("compact", 2.0 if unit.context >= 80 else 0.1, func() -> Array: return state.compact(unit))
	for id in state.load_options(unit):
		add.call("load %s" % id, 0.5, func() -> Array: return state.load_chip(unit, id))
	for id in unit.chips:
		if state.chip_ready(unit, id):
			var targets: Array[Unit] = []
			if id == BattleState.LOCATE:
				targets.append(state.locate_targets()[0])
			elif id == BattleState.PREDICT:
				targets.append(state.predict_targets()[0])
			add.call("use %s" % id, 1.0, func() -> Array: return state.use_chip(unit, id, targets))
	for option in state.verb_options(unit):
		if option.enabled:
			add.call("%s %s" % [option.verb, option.node], 0.6, func() -> Array:
				var preview := state.verb_preview(unit, option.node, option.verb, option.direction)
				var events := state.use_verb(unit, option.node, option.verb, option.direction)
				_check(_types(preview) == _types(events), "the preview of %s %s showed %s, play did %s" % [option.verb, option.node, _types(preview), _types(events)])
				return events)
	for id in state.turret_controls(unit):
		var mode := "hold" if state.devices[id].mode == "target" else "target"
		add.call("turret %s %s" % [id, mode], 0.5, func() -> Array: return state.set_turret_mode(unit, id, mode))
	return result


# Where an Operator heads: an access point while its AI is out, then extraction once the cache is
# breached. Robots head for the facility's access points, to relay.
func _goal(state: BattleState, unit: Unit) -> Vector2i:
	if state.cache_breached:
		return state.map.extraction()[0]
	if unit.is_robot() or unit.id == 2:
		return state.node_cell("c")
	return state.node_cell("b" if unit.cell.y < 12 else "a")


# Nothing impossible: AP and context in range, no two units on one tile, nobody in a wall or on a
# device a person can't stand on, and every connected AI within its tether, on its own network.
func _invariants(state: BattleState, where: String) -> void:
	var taken := {}
	for unit in state.units:
		_check(unit.ap >= 0 and unit.ai_ap >= 0 and unit.context >= 0 and unit.context <= BattleState.CONTEXT_MAX,
			"%s: %s has AP %d, AI AP %d, context %d" % [where, unit.display_name, unit.ap, unit.ai_ap, unit.context])
		if not unit.on_map():
			continue
		_check(not taken.has(unit.cell), "%s: %s and %s share %s" % [where, unit.display_name, taken.get(unit.cell, unit).display_name, unit.cell])
		taken[unit.cell] = unit
		_check(unit.is_turret() or not state.blocks_walk(unit.cell, true), "%s: %s stands somewhere it can't, %s" % [where, unit.display_name, unit.cell])
		if unit.connected():
			var source: Unit = state.units[unit.relay] if unit.relay >= 0 else unit
			_check(not source.down and Grid.distance(source.cell, state.node_cell(unit.entry)) <= BattleState.TETHER
				and state.map.network_of(unit.ai_node) == state.map.network_of(unit.entry), "%s: %s's AI is connected out of reach" % [where, unit.display_name])


func _types(events: Array) -> Array:
	return events.map(func(event: Dictionary) -> String: return event.type)


func _check(condition: bool, what: String) -> void:
	if not condition:
		_failures += 1
		printerr("FAIL: " + what)
