extends SceneTree

# The hack and context math, the one place tests earn their keep for now.
# Run: godot --headless --path game -s tests/test_hacking.gd

var _failures := 0


func _initialize() -> void:
	_context_fills_and_caps()
	_full_context_halves_the_yield()
	_compaction_keeps_a_quarter()
	_progress_survives_being_pulled_out()
	print("hacking tests: " + ("all passed" if _failures == 0 else "%d failed" % _failures))
	quit(1 if _failures > 0 else 0)


func _context_fills_and_caps() -> void:
	var state := _state()
	var alpha := _connected_at(state, "z")
	for i in 4:
		state.hack(_agent_turn(state, alpha))
	_check(alpha.context == BattleState.CONTEXT_MAX, "context caps at the max, got %d" % alpha.context)
	_check(state.breach["z"] == 40, "four clean hacks bank 40, got %d" % state.breach["z"])


func _full_context_halves_the_yield() -> void:
	var state := _state()
	var alpha := _connected_at(state, "z")
	alpha.context = BattleState.CONTEXT_MAX
	state.hack(_agent_turn(state, alpha))
	_check(state.breach["z"] == 5, "a hack at full context yields half, got %d" % state.breach["z"])


func _compaction_keeps_a_quarter() -> void:
	var state := _state()
	var alpha := _connected_at(state, "z")
	alpha.context = 90
	state.compact(_agent_turn(state, alpha))
	_check(alpha.context == 23, "compacting 90 leaves 23, got %d" % alpha.context)


func _progress_survives_being_pulled_out() -> void:
	var state := _state()
	var alpha := _connected_at(state, "z")
	state.hack(_agent_turn(state, alpha))
	state.hack(_agent_turn(state, alpha))
	state.phase = BattleState.Phase.HUMAN
	state.move(alpha, Vector2i(10, 11))
	_check(alpha.agent_node == "", "walking out of range pulls the AI out")
	alpha = _connected_at(state, "z")
	_check(state.breach["z"] == 20, "breach progress stays on the node, got %d" % state.breach["z"])
	_check(alpha.context == 60, "context stays with the AI, got %d" % alpha.context)
	while state.can_hack(_agent_turn(state, alpha)):
		state.hack(alpha)
	_check(state.cache_breached and state.breach["z"] == 60, "the cache is breached on reaching its goal")


func _state() -> BattleState:
	var operators: Array[UnitDef] = [load("res://content/units/alpha.tres")]
	var nodes: Array[NodeDef] = []
	for kind in ["access", "door", "camera", "turret", "cache"]:
		nodes.append(load("res://content/nodes/%s.tres" % kind))
	return BattleState.new(
		load("res://content/maps/mvp.tres"), operators, load("res://content/units/guard.tres"),
		load("res://content/units/turret.tres"), nodes
	)


func _connected_at(state: BattleState, node: String) -> Unit:
	var alpha := state.units[0]
	alpha.cell = Vector2i(7, 11)
	alpha.moved = false
	alpha.agent_node = node
	alpha.entry = "a"
	state.active = alpha
	return alpha


# Gives the AI a fresh action, the way its next turn would.
func _agent_turn(state: BattleState, unit: Unit) -> Unit:
	state.phase = BattleState.Phase.AGENT
	return unit


func _check(condition: bool, what: String) -> void:
	if not condition:
		_failures += 1
		printerr("FAIL: " + what)
