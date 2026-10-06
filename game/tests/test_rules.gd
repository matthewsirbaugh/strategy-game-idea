extends SceneTree

# Rules that are easy to break quietly: when a turn ends, donated compute, aim lines, guards playing
# fair with the fog, the rules refusing actions the menus would never offer, broken content, and
# restarting a phase exactly.
# Run: godot --headless --path game -s tests/test_rules.gd

# A guard (1) at the end of a corridor, facing west down it, already in sight.
const CORRIDOR := ". . . . . . . . . X
. . P . . . . 1 . z
. . . . . . . . . ."

# The guard (1) hides behind the wall at x=4 until someone walks to x=3 on the bottom row.
const CORNER := ". . . . # . . X
. . . . # . 1 z
. . P . . . . ."

var _failures := 0


func _initialize() -> void:
	_turn_ends_when_both_pools_are_spent()
	_donated_compute_waits_for_the_next_turn()
	_a_sprint_cut_short_costs_what_walking_would()
	_aim_lines_are_fixed_when_the_guard_aims()
	_predict_matches_the_guards_real_turn()
	_guards_ignore_operators_they_cannot_see()
	_stuns_end_the_way_the_rules_say()
	_illegal_actions_change_nothing()
	_broken_content_is_reported()
	_the_test_map_keeps_its_shape()
	_restarting_rebuilds_the_phase_exactly()
	print("rules tests: " + ("all passed" if _failures == 0 else "%d failed" % _failures))
	quit(1 if _failures > 0 else 0)


# The Operator's AP running out doesn't end the turn while the AI has AP, and a refund on the
# AI's last action keeps the turn open.
func _turn_ends_when_both_pools_are_spent() -> void:
	var state := _state("P a n . X\n. . . . z", {"a": "access", "n": "light", "z": "cache"}, ["a-n"])
	var alpha := state.begin_next_turn()
	state.deploy_ai(alpha, "a")
	alpha.ap = 1
	state.move(alpha, Vector2i(0, 1))
	_check(alpha.ap == 0 and not state.turn_over, "spending the Operator's last AP leaves the turn open for the AI")
	state.ai_move(alpha, "n")
	var events := state.hack(alpha)
	_check(not events.is_empty() and events[0].refund and alpha.ai_ap == 1, "a one-action breach refunds its AP")
	_check(not state.turn_over, "a refunded last action doesn't end the turn")
	state.compact(alpha)
	_check(state.turn_over, "the turn ends once both pools are spent")


func _donated_compute_waits_for_the_next_turn() -> void:
	var state := _state("P P a X\n. . . z", {"a": "access", "z": "cache"}, [], 2)
	var alpha := state.begin_next_turn()
	var bravo := _unit(state, "Bravo")
	state.share_compute(alpha, bravo)
	_check(alpha.ai_ap == 1 and bravo.incoming == 1 and bravo.ai_ap == 0, "donated AP leaves the donor at once and waits for the receiver")
	state.end_turn(alpha)
	state.begin_next_turn()
	_check(state.active == bravo and bravo.ai_ap == 3, "the receiver gets it on its next turn, got %d" % bravo.ai_ap)
	state.end_turn(bravo)
	state.begin_next_turn()
	state.end_turn(alpha)
	state.begin_next_turn()
	_check(bravo.ai_ap == 2, "unused donated AP lapses after that turn, got %d" % bravo.ai_ap)


func _a_sprint_cut_short_costs_what_walking_would() -> void:
	var state := _state(CORNER)
	var alpha := state.begin_next_turn()
	var events := state.move(alpha, Vector2i(5, 2), true)
	_check(alpha.cell == Vector2i(3, 2) and events.any(func(event: Dictionary) -> bool: return event.type == "revealed"),
		"revealing the guard stops the sprint where it showed up, at %s" % alpha.cell)
	_check(alpha.ap == alpha.base_ap - 1 and alpha.sprinted, "one tile of a cut-short sprint costs 1 AP, left %d" % alpha.ap)


# The line runs from the guard through its target's tile, out to its range, and stays put. A
# target that moves along it is still hit; one that steps off it isn't; a robot in front takes it.
func _aim_lines_are_fixed_when_the_guard_aims() -> void:
	for case in ["along", "off", "robot"]:
		var state := _state(CORRIDOR)
		var alpha := state.begin_next_turn()
		var guard := _unit(state, "Guard 1")
		guard.facing = Vector2(-1, 0)
		state.move(alpha, Vector2i(3, 1))
		_check(guard.task == Unit.Task.ALERTED, "walking into the seen tier alerts the guard at once")
		state.end_turn(alpha)
		state.begin_next_turn()
		state.take_automatic_turn()
		_check(guard.aim.get("cells", []) == [Vector2i(6, 1), Vector2i(5, 1), Vector2i(4, 1), Vector2i(3, 1), Vector2i(2, 1)],
			"the aim line runs through Alpha out to range 5, got %s" % [guard.aim.get("cells", [])])
		state.begin_next_turn()
		match case:
			"along":
				state.move(alpha, Vector2i(2, 1))
			"off":
				state.move(alpha, Vector2i(3, 0))
			"robot":
				state.deploy_robot(alpha, Vector2i(4, 1))
		state.end_turn(alpha)
		state.begin_next_turn()
		var fired := state.take_automatic_turn().filter(func(event: Dictionary) -> bool: return event.type == "fire")
		match case:
			"along":
				_check(fired.size() == 1 and fired[0].target == alpha and alpha.hits == 1, "a target moving along the line is still hit")
			"off":
				_check(fired.is_empty() and alpha.hits == 0, "stepping off the line breaks the aim")
			"robot":
				var drone := state.units[alpha.robot]
				_check(fired.size() == 1 and fired[0].target == drone and drone.down and alpha.hits == 0,
					"a robot in front takes the shot for the Operator")


func _predict_matches_the_guards_real_turn() -> void:
	var state := _state(null)
	for unit in state.units:
		if not unit.is_guard():
			continue
		var predicted := state.prediction(unit)
		state.active = unit
		var path: Array[Vector2i] = [unit.cell]
		for event in EnemyAI.take_turn(state, unit):
			if event.type == "move" and event.unit == unit:
				path.append_array(event.path)
		_check(predicted.path == path, "Predict shows %s's real path: %s, then %s" % [unit.display_name, predicted.path, path])


# Adding, removing or moving an Operator the guard can't see must not change its turn.
func _guards_ignore_operators_they_cannot_see() -> void:
	var turns: Array[String] = []
	for hidden: Variant in [null, Vector2i(7, 0), Vector2i(7, 2)]:
		var state := _state(CORNER.replace(". . P", "P . P"), {"z": "cache"}, [], 2, func(map: MapData) -> void:
			map.patrols = PackedStringArray(["3,1 2,1"]))
		var bravo := _unit(state, "Bravo")
		if hidden == null:
			bravo.down = true
		else:
			bravo.cell = hidden
		state.refresh()
		var guard := _unit(state, "Guard 1")
		state.active = guard
		turns.append(str(EnemyAI.take_turn(state, guard).map(func(event: Dictionary) -> String: return "%s %s" % [event.type, event.get("path", "")])))
	_check(turns[0].contains("move"), "the guard walks its patrol, got %s" % turns[0])
	_check(turns[1] == turns[0], "a hidden Operator changed the guard's turn: %s vs %s" % [turns[1], turns[0]])
	_check(turns[2] == turns[0], "moving the hidden Operator changed the guard's turn: %s vs %s" % [turns[2], turns[0]])


# A guard is found every time it goes down, not just the first. A Breached turret shot by an enemy
# turret comes back from the stun without putting the zone on caution.
func _stuns_end_the_way_the_rules_say() -> void:
	var state := _state(". . . . . . X\nP . 1 . 2 . z\n. . . . . . .")
	var alpha := state.begin_next_turn()
	var guard := _unit(state, "Guard 1")
	_unit(state, "Guard 2").facing = Vector2(-1, 0)
	for time in ["first", "second"]:
		guard.stun = 0
		state.hit(guard, alpha)
		var found := Perception.sweep(state).filter(func(event: Dictionary) -> bool: return event.type == "found_body")
		_check(found.size() == 1, "a stunned guard in sight is found the %s time it goes down" % time)
	state = _state("P a t . X\n. . . . z", {"a": "access", "t": "turret", "z": "cache"}, ["a-t"])
	var turret: Unit = state.units.filter(func(unit: Unit) -> bool: return unit.is_turret())[0]
	state._breach("t")
	state.hit(turret, alpha)
	for i in BattleState.STUN_TURNS:
		state.active = turret
		EnemyAI.take_turn(state, turret)
	_check(turret.stun == 0 and state.caution.is_empty(), "a Breached turret recovers from a stun quietly, caution %s" % state.caution)


# Each one is a direct call the menus would never make.
func _illegal_actions_change_nothing() -> void:
	var state := _state(null)
	var alpha := state.begin_next_turn()
	var bravo := _unit(state, "Bravo")
	var guard := _unit(state, "Guard 1")
	_refused(state, func() -> Array: return state.move(bravo, Vector2i(3, 14)), "moving out of turn")
	_refused(state, func() -> Array: return state.move(alpha, Vector2i(19, 13)), "walking further than the AP allow")
	_refused(state, func() -> Array: return state.shoot(alpha, guard), "shooting a guard out of range and out of sight")
	_refused(state, func() -> Array: return state.ai_move(alpha, "e"), "a network move before the AI is deployed")
	_refused(state, func() -> Array: return state.deploy_ai(alpha, "a"), "deploying at an access point beyond the tether")
	state.move(alpha, Vector2i(3, 13))
	state.deploy_ai(alpha, "a")
	_refused(state, func() -> Array: return state.hack(alpha), "hacking an access point")
	_refused(state, func() -> Array: return state.ai_move(alpha, "b"), "a network move onto another network")
	_refused(state, func() -> Array: return state.use_verb(alpha, "d", "lock"), "using a verb on a device that isn't Breached")
	state.set_overwatch(alpha)
	_refused(state, func() -> Array: return state.move(alpha, Vector2i(3, 14), true), "sprinting after setting overwatch")
	_refused(state, func() -> Array: return state.set_overwatch(alpha), "a second overwatch in one turn")
	state.end_turn(alpha)
	_refused(state, func() -> Array: return state.move(alpha, Vector2i(1, 13)), "moving after ending the turn")


func _broken_content_is_reported() -> void:
	var map := MapData.new()
	map.layout = "X . a . a\n. 1 . 1\nP . 0 . q"
	map.node_kinds = {"a": "vault", "b": "door"}
	map.links = PackedStringArray(["a-b", "a"])
	map.patrols = PackedStringArray(["1,1 9,9", "7;7"])
	map.dressing = PackedStringArray(["crates 2,1 up"])
	map.networks = {"Lab": "q"}
	map.circuits = {"q": "a"}
	map.zones = {"Yard": "0,0-1,1 9;9"}
	map.receptacles = PackedStringArray(["dumpster 0,1", "trunk q"])
	map.node_states = {"q": "melted"}
	var content: BattleContent = load("res://content/battle.tres")
	var errors := "\n".join(BattleState.validate(map, content, content.loadouts))
	for expected in [
		"Unsaved map: layout row 1 has 4 tiles, but row 0 has 5",
		"layout has node 'a' at 2,0 and again at 4,0",
		"layout has guard 1 at 1,1 and again at 3,1",
		"layout has guard 0 at 2,2",
		"node_kinds has no kind for node 'q'",
		"node_kinds names node 'b', which isn't on the layout",
		"node_kinds gives node 'a' the kind 'vault', which has no NodeDef",
		"links[0] 'a-b' names node 'b'",
		"links[1] 'a' should join two different nodes",
		"patrols[0] waypoint 9,9 is off the map",
		"patrols[1] is for guard 2, who isn't on the layout",
		"patrols[1] waypoint '7;7' should be 'x,y'",
		"dressing[0] 'crates 2,1 up' should read 'name x,y facing'",
		"networks Lab has no access point",
		"networks puts node 'a' on no network",
		"circuits 'q' isn't a power hub",
		"zones Yard has '9;9', which is no node",
		"zones leaves tile 2,1 in no zone",
		"receptacles[0] 'dumpster 0,1' should stand on a low obstacle",
		"receptacles[1] 'trunk q' should name a car or truck node",
		"node_states 'q: melted' should name a node",
		"layout has 1 player starts (P) for 3 Operators",
		"node_kinds has no node of kind 'cache', so the mission has no objective",
	]:
		_check(errors.contains(expected), "broken content should report: " + expected)
	var loadout: Loadout = content.loadouts[0].duplicate()
	loadout.chips = PackedStringArray(["locate", "locate", "predict", "cloak"])
	var loadouts: Array[Loadout] = [loadout]
	errors = "\n".join(BattleState.validate(load("res://content/maps/facility_exterior.tres"), content, loadouts))
	for expected in ["1 loadouts for 3 Operators", "carries 4 chips; the most is 3", "has chip 'locate', which isn't a chip it can carry once",
			"has chip 'cloak'"]:
		_check(errors.contains(expected), "a broken loadout should report: " + expected)


# The brief's map, as the level depends on it: two networks that don't touch, the cache 4 hops
# from b and 1 from c, and a hub whose circuit reaches a light on the other network.
func _the_test_map_keeps_its_shape() -> void:
	var state := _state(null)
	_check(state.errors.is_empty(), "the test map is valid: %s" % state.errors)
	var from_b: Dictionary = state._network_search("b").hops
	_check(from_b.get("z") == 4 and state._network_search("c").hops.get("z") == 1, "the cache is 4 hops from b and 1 from c")
	_check(not state._network_search("a").hops.has("z"), "the street network doesn't reach the facility")
	_check(state.map.network_of("i") == "Street" and state.map.hub_of("i") == "w", "light i is on the street network and hub w's circuit")


func _restarting_rebuilds_the_phase_exactly() -> void:
	var session := BattleSession.from_presets(load("res://content/maps/facility_exterior.tres"), load("res://content/battle.tres"))
	var first := session.start()
	var entry := _snapshot(first)
	var alpha := first.begin_next_turn()
	first.move(alpha, Vector2i(3, 13))
	first.deploy_ai(alpha, "a")
	first.ai_move(alpha, "e")
	_check(not first.hack(alpha).is_empty(), "the first phase plays on")
	_check(_snapshot(session.start()) == entry, "a restart starts from exactly the conditions the phase began with")


func _refused(state: BattleState, action: Callable, what: String) -> void:
	var before := _snapshot(state)
	var events: Array = action.call()
	_check(events.is_empty() and _snapshot(state) == before, "%s should be refused and change nothing" % what)


func _snapshot(state: BattleState) -> String:
	var units := []
	for u in state.units:
		units.append([u.cell, u.team, u.ap, u.ai_ap, u.incoming, u.hits, u.shot_used, u.sprinted, u.overwatch, u.ai_node,
			u.context, u.chips, u.task, u.aim, u.stun, u.tied, u.carrying, u.robot, u.located, u.facing])
	return var_to_str([units, state.round_number, state.active.id if state.active else -1, state.turn_over, state.devices,
		state.progress, state.breached, state.known, state.visible_cells, state.caution, state.revealed_networks])


# A null layout means the facility exterior with the V1 loadouts. Other layouts play in light.
func _state(layout: Variant, node_kinds := {"z": "cache"}, links := [], operators := 1, setup := Callable()) -> BattleState:
	var map: MapData = load("res://content/maps/facility_exterior.tres")
	var base: BattleContent = load("res://content/battle.tres")
	var content := base
	if layout != null:
		map = MapData.new()
		map.layout = layout
		map.node_kinds = node_kinds
		map.links = PackedStringArray(links)
		content = BattleContent.new()
		for field in ["guard", "turret", "drone", "dog_bot", "node_defs", "chips"]:
			content.set(field, base.get(field))
		content.operators = base.operators.slice(0, operators)
		content.loadouts = base.loadouts.slice(0, operators)
	if setup.is_valid():
		setup.call(map)
	var loadouts: Array[Loadout] = []
	for loadout in content.loadouts:
		loadouts.append(loadout.duplicate())
	return BattleState.new(map, content, loadouts)


func _unit(state: BattleState, unit_name: String) -> Unit:
	for unit in state.units:
		if unit.display_name == unit_name:
			return unit
	return null


func _check(condition: bool, what: String) -> void:
	if not condition:
		_failures += 1
		printerr("FAIL: " + what)
