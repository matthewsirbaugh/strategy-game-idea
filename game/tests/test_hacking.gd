extends SceneTree

# The network and context math: Jump, refunds, chip multipliers and rounding, compaction, and
# power circuits.
# Run: godot --headless --path game -s tests/test_hacking.gd

# A line of nodes: access point a, then lights b to f, each a hop further.
const LINE := "P a b c d e f X
. . . . . . . z"

var _failures := 0


func _initialize() -> void:
	_jump_extends_reach_as_soon_as_a_node_falls()
	_only_a_one_action_breach_refunds()
	_subagent_earns_one_refund_from_either_node()
	_multipliers_multiply_and_round()
	_compaction_degrades_chips_a_step()
	_progress_survives_being_pulled_out()
	_a_hub_switches_its_whole_circuit()
	print("hacking tests: " + ("all passed" if _failures == 0 else "%d failed" % _failures))
	quit(1 if _failures > 0 else 0)


func _jump_extends_reach_as_soon_as_a_node_falls() -> void:
	var state := _line_state()
	var alpha := _connected(state, "a")
	_check(_sorted(state.network_destinations(alpha)) == ["b", "c", "d"], "three hops reach b to d, got %s" % [state.network_destinations(alpha)])
	state.ai_move(alpha, "b")
	state.hack(alpha)
	state.ai_move(alpha, "a")
	alpha.ai_ap = BattleState.AI_AP
	_check(state.network_destinations(alpha).has("e") and not state.network_destinations(alpha).has("f"),
		"a hop out of Breached b is free, so e is in reach right after the breach, got %s" % [state.network_destinations(alpha)])
	state.breached["c"] = true
	_check(state.network_destinations(alpha).has("f"), "holding b and c reaches f")
	_check(state.network_path("a", "f") == ["b", "c", "d", "e", "f"], "the AI travels the whole way, got %s" % [state.network_path("a", "f")])


func _only_a_one_action_breach_refunds() -> void:
	var state := _state("P a k X\n. . . z", {"a": "access", "k": "camera", "z": "cache"}, ["a-k"])
	var alpha := _connected(state, "k")
	var events := state.hack(alpha)
	_check(not events[0].refund and alpha.ai_ap == 1, "a hack that doesn't breach doesn't refund")
	events = state.hack(alpha)
	_check(state.breached.has("k") and not events[0].refund and alpha.ai_ap == 0, "finishing a breach begun earlier doesn't refund")


func _subagent_earns_one_refund_from_either_node() -> void:
	var state := _state("P P P a b c X\n. . . . . . z", {"a": "access", "b": "light", "c": "light", "z": "cache"}, ["a-b", "b-c"], 3)
	var charlie := _connected(state, "b", "Charlie")
	state.use_chip(charlie, BattleState.SUBAGENT)
	_check(charlie.ai_ap == 1 and charlie.context == 20, "Subagent costs 1 AP and loads for 20 context")
	var events := state.hack(charlie, "c")
	_check(state.breached.has("b") and state.breached.has("c"), "the subagent adds the same progress to the linked node")
	_check(events[0].refund and charlie.ai_ap == 1, "two nodes breached in one action still earn one refund, AP %d" % charlie.ai_ap)
	state = _state("P P P a k c X\n. . . . . . z", {"a": "access", "k": "camera", "c": "light", "z": "cache"}, ["a-k", "k-c"], 3)
	charlie = _connected(state, "k", "Charlie")
	state.progress["k"] = 10
	state.use_chip(charlie, BattleState.SUBAGENT)
	events = state.hack(charlie, "c")
	_check(state.breached.has("k") and events[0].refund, "the linked node going from untouched to Breached earns the refund")


# Bravo carries Extended thinking and the Infrastructure exploit. Hack power multiplies and rounds
# down; context rounds up.
func _multipliers_multiply_and_round() -> void:
	var state := _state("P P a k X\n. . . . z", {"a": "access", "k": "camera", "z": "cache"}, ["a-k"], 2)
	var bravo := _connected(state, "k", "Bravo")
	bravo.chips["infrastructure_exploit"] = 2
	_check(state.hack_power(bravo, "k") == 10, "an exploit only multiplies its own category")
	bravo.next_hack[BattleState.EXTENDED_THINKING] = true
	bravo.chips[BattleState.EXTENDED_THINKING] = 2
	_check(state.hack_power(bravo, "k") == 20 and state.hack_context(bravo, "k") == 30, "Extended thinking doubles power and context")
	bravo.chips[BattleState.EXTENDED_THINKING] = 1
	_check(state.hack_context(bravo, "k") == 23, "degraded, it's 1.5x context, rounded up: 15 to 23, got %d" % state.hack_context(bravo, "k"))
	state.map.node_kinds["k"] = "light"
	bravo.chips["infrastructure_exploit"] = 1
	_check(state.hack_power(bravo, "k") == 22, "1.5x and 1.5x multiply to 2.25x, 22 after rounding down, got %d" % state.hack_power(bravo, "k"))
	bravo.context = BattleState.CONTEXT_MAX
	_check(state.hack_power(bravo, "k") == 11, "a full context halves it, got %d" % state.hack_power(bravo, "k"))
	var events := state.use_chip(bravo, BattleState.EXTENDED_THINKING)
	_check(events.is_empty(), "activating a next-hack chip again before that hack does nothing")


func _compaction_degrades_chips_a_step() -> void:
	var state := _line_state()
	var alpha := _connected(state, "a")
	alpha.context = 90
	alpha.chips["surveillance_exploit"] = 2
	alpha.chips[BattleState.MOVEMENT] = 2
	state.compact(alpha)
	_check(alpha.context == 23, "compacting 90 keeps 23, got %d" % alpha.context)
	_check(alpha.chips["surveillance_exploit"] == 1 and alpha.chips[BattleState.MOVEMENT] == 2, "a multiplier degrades to 1.5x; movement stays")
	state.compact(alpha)
	_check(alpha.chips["surveillance_exploit"] == 0, "the second compaction unloads it")
	_check(alpha.context == 6 and alpha.chips[BattleState.MOVEMENT] == 0, "movement unloads once context drops below its cost")
	alpha.ai_ap = 1
	state.ai_move(alpha, "b")
	_check(alpha.context == 16, "the next move loads movement again, for 10")


func _progress_survives_being_pulled_out() -> void:
	var state := _state("P a k . . . X\n. . . . . . z", {"a": "access", "k": "camera", "z": "cache"}, ["a-k"])
	var alpha := _connected(state, "k")
	state.hack(alpha)
	state.move(alpha, Vector2i(5, 0))
	_check(not alpha.connected(), "walking out of the tether pulls the AI out")
	_check(state.progress["k"] == 10 and alpha.context == 15, "progress stays on the node and context with the AI")


# Cutting a hub switches off every device on its circuit, each one its own lure, even one on
# another network; while the hub is off they can't be powered on alone.
func _a_hub_switches_its_whole_circuit() -> void:
	var state := _state("P a w . . . X\n. b h . . . z", {"a": "access", "b": "access", "w": "hub", "h": "light", "z": "cache"},
		["a-w"], 1, func(map: MapData) -> void:
			map.networks = {"One": "a w z", "Two": "b h"}
			map.circuits = {"w": "h"}
			map.night = true)
	var alpha := _connected(state, "a")
	state.breached["w"] = true
	state.breached["h"] = true
	_check(state.is_lit(Vector2i(3, 1)), "light h lights its pool")
	state.use_verb(alpha, "w", "power")
	_check(not state.devices["h"].powered and not state.is_lit(Vector2i(3, 1)), "the hub switches h off on the other network")
	alpha.ai_node = "b"
	alpha.entry = "b"
	_check(not Devices.can_use(state, alpha, "h", "power"), "h can't be powered on while its hub is off")


func _line_state() -> BattleState:
	return _state(LINE, {"a": "access", "b": "light", "c": "light", "d": "light", "e": "light", "f": "light", "z": "cache"},
		["a-b", "b-c", "c-d", "d-e", "e-f"])


# Maps play in light unless the setup says otherwise. Operators come in roster order.
func _state(layout: String, node_kinds: Dictionary, links: Array, operators := 1, setup := Callable()) -> BattleState:
	var map := MapData.new()
	map.layout = layout
	map.node_kinds = node_kinds
	map.links = PackedStringArray(links)
	if setup.is_valid():
		setup.call(map)
	var base: BattleContent = load("res://content/battle.tres")
	var content := BattleContent.new()
	for field in ["guard", "turret", "drone", "dog_bot", "node_defs", "chips"]:
		content.set(field, base.get(field))
	content.operators = base.operators.slice(0, operators)
	content.loadouts = base.loadouts.slice(0, operators)
	var loadouts: Array[Loadout] = []
	for loadout in content.loadouts:
		loadouts.append(loadout.duplicate())
	return BattleState.new(map, content, loadouts)


# Makes the named Operator active with a fresh turn, its AI on the given node.
func _connected(state: BattleState, node: String, unit_name := "Alpha") -> Unit:
	var unit: Unit
	for other in state.units:
		if other.display_name == unit_name:
			unit = other
	state.active = unit
	state.turn_over = false
	unit.ap = unit.base_ap
	unit.ai_ap = BattleState.AI_AP
	unit.ai_node = node
	unit.entry = node if state.map.node_kind(node) == "access" else state.map.node_ids().filter(
		func(id: String) -> bool: return state.map.node_kind(id) == "access")[0]
	unit.chips[BattleState.MOVEMENT] = 2
	return unit


func _sorted(items: Array) -> Array:
	var copy := items.duplicate()
	copy.sort()
	return copy


func _check(condition: bool, what: String) -> void:
	if not condition:
		_failures += 1
		printerr("FAIL: " + what)
