extends SceneTree

# Rules that are easy to break quietly: guards playing fair with the fog.
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


func _state(layout: String, operator_names: Array, node_kinds := {"z": "cache"}) -> BattleState:
	var map := MapData.new()
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


func _place(state: BattleState, unit_name: String, cell: Vector2i) -> void:
	for unit in state.units:
		if unit.display_name == unit_name:
			unit.cell = cell
	state.refresh_vision()


func _guard_to_act(state: BattleState) -> Unit:
	for unit in state.units:
		if unit.display_name == "Guard 1":
			state.active = unit
			return unit
	return null


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
