extends SceneTree

# Rules that are easy to break quietly: guards playing fair with the fog, and the rules refusing
# actions the menus would never offer.
# Run: godot --headless --path game -s tests/test_rules.gd

# The guard (1) sees an Operator 5 tiles west (P). The walls at x=6 hide the tiles behind them,
# and the one at 4,2 hides 3,1 until the guard steps west.
const FOG_MAP := "X . . . . . # . z
. . . . . . # . .
. . . . # . # . .
P . . . . 1 . . .
P . . . . . . . ."

var _failures := 0


func _initialize() -> void:
	_guards_ignore_operators_they_cannot_see()
	_guards_attack_operators_their_move_reveals()
	_illegal_actions_change_nothing()
	print("rules tests: " + ("all passed" if _failures == 0 else "%d failed" % _failures))
	quit(1 if _failures > 0 else 0)


# Adding, removing or moving an Operator the guard can't see must not change its plan.
func _guards_ignore_operators_they_cannot_see() -> void:
	var plans: Array[String] = []
	for hidden in [null, Vector2i(7, 1), Vector2i(8, 1)]:
		var state := _state(FOG_MAP, ["alpha"] if hidden == null else ["alpha", "bravo"])
		if hidden != null:
			_place(state, "Bravo", hidden)
		var guard := _guard_to_act(state)
		var options := state.destinations(guard)
		options.sort()
		plans.append("%s -> %s" % [options, _summary(EnemyAI.take_turn(state, guard))])
	_check(plans[0].ends_with("-> moved to (3, 3), attacked Alpha"), "the guard closes in on the Operator it sees, got %s" % plans[0])
	_check(plans[1] == plans[0], "a hidden Operator changed the guard's plan: %s vs %s" % [plans[1], plans[0]])
	_check(plans[2] == plans[0], "moving the hidden Operator changed the guard's plan: %s vs %s" % [plans[2], plans[0]])


func _guards_attack_operators_their_move_reveals() -> void:
	var state := _state(FOG_MAP, ["bravo", "alpha"])
	_place(state, "Alpha", Vector2i(3, 1))
	var guard := _guard_to_act(state)
	_check(state.seen_enemies(guard).size() == 1, "the guard should start seeing only Bravo")
	var summary := _summary(EnemyAI.take_turn(state, guard))
	_check(summary == "moved to (3, 3), attacked Alpha", "the guard shoots the weaker Operator its move revealed, got %s" % summary)


# Each one is a direct call the menus would never make.
func _illegal_actions_change_nothing() -> void:
	var state := _state(null, ["alpha", "bravo"])
	var alpha := state.begin_next_turn()
	var bravo := _unit(state, "Bravo")
	var guard_2 := _unit(state, "Guard 2")
	var guard_4 := _unit(state, "Guard 4")
	_refused(state, func() -> Array: return state.move(bravo, Vector2i(9, 9)), "moving out of turn")
	_refused(state, func() -> Array: return state.attack(alpha, guard_2), "attacking from 11 tiles with range 3")
	state.move(alpha, Vector2i(6, 11))
	_refused(state, func() -> Array: return state.move(alpha, Vector2i(7, 11)), "a second move")
	state.attack(alpha, guard_4)
	_refused(state, func() -> Array: return state.attack(alpha, guard_4), "a second attack")
	state.end_human_phase(alpha)
	_check(alpha.agent_node == "a", "Alpha's AI connects at the access point")
	_refused(state, func() -> Array: return state.agent_move(alpha, "z"), "a network move of 4 hops with range 3")
	_refused(state, func() -> Array: return state.hack(alpha), "hacking an access point")
	state.agent_move(alpha, "e")
	_refused(state, func() -> Array: return state.hack(alpha), "a second AI action in one turn")


func _refused(state: BattleState, action: Callable, what: String) -> void:
	var before := _snapshot(state)
	var events: Array = action.call()
	_check(events.is_empty() and _snapshot(state) == before, "%s should be refused and change nothing" % what)


func _snapshot(state: BattleState) -> String:
	var units := []
	for u in state.units:
		units.append([u.cell, u.hp, u.moved, u.acted, u.agent_node, u.entry, u.context, u.ability_uses_left, u.cloaked_until, u.located_until])
	return var_to_str([units, state.phase, state.active, state.breach, state.breached, state.known, state.visible_cells, state.vision_sources])


# A null layout means the MVP map.
func _state(layout: Variant, operator_names: Array, node_kinds := {"z": "cache"}) -> BattleState:
	var map: MapData = load("res://content/maps/mvp.tres")
	if layout != null:
		map = MapData.new()
		map.layout = layout
		map.node_kinds = node_kinds
	var operators: Array[UnitDef] = []
	for operator_name in operator_names:
		operators.append(load("res://content/units/%s.tres" % operator_name))
	var nodes: Array[NodeDef] = []
	for kind in ["access", "door", "camera", "turret", "cache"]:
		nodes.append(load("res://content/nodes/%s.tres" % kind))
	return BattleState.new(
		map, operators, load("res://content/units/guard.tres"), load("res://content/units/turret.tres"), nodes
	)


func _unit(state: BattleState, unit_name: String) -> Unit:
	for unit in state.units:
		if unit.display_name == unit_name:
			return unit
	return null


func _place(state: BattleState, unit_name: String, cell: Vector2i) -> void:
	_unit(state, unit_name).cell = cell
	state.refresh_vision()


func _guard_to_act(state: BattleState) -> Unit:
	state.active = _unit(state, "Guard 1")
	return state.active


func _summary(events: Array[Dictionary]) -> String:
	var parts: Array[String] = []
	for event in events:
		match event["type"]:
			"move":
				parts.append("moved to %s" % event["unit"].cell)
			"attack":
				parts.append("attacked %s" % event["target"].display_name)
	return ", ".join(parts)


func _check(condition: bool, what: String) -> void:
	if not condition:
		_failures += 1
		printerr("FAIL: " + what)
