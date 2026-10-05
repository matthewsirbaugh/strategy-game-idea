class_name BattleState
extends RefCounted

# The battle's rules and state, with no visuals. Actions return events (plain dictionaries with a
# "type") so the view can animate them in order without the rules knowing anything about the view.
# An illegal action changes nothing and returns no events; the can_ and list functions below are
# the checks, shared with the menus. Perception, Devices and EnemyAI are helpers that work on this
# state. The numbers are RULES.md's V1 placeholders.

enum Winner { NONE, PLAYER, ENEMY }

# Context counts millions of tokens: 100 is the setting's standard 100M window.
const CONTEXT_MAX := 100
const FULL_CONTEXT_YIELD := 0.5
const COMPACT_KEEPS := 0.25
const AI_AP := 2
const HACK_POWER := 10
const NETWORK_RANGE := 3
const TETHER := 2
const VERB_CONTEXT := 5
const SPRINT_TILES := 3
const SPRINT_COST := 2
const PEEK_COST := 1
const LOCK_COST := 1
const DEPLOY_AI_COST := 1
const TIE_COST := 2
const ROBOT_COST := 3
const FLASHBANG_COST := 2
const FLASHBANG_RANGE := 5
const FLASHBANG_RADIUS := 2
const BLIND_TURNS := 3
const STUN_TURNS := 3
const CAUTION_ROUNDS := 3
const SEARCH_TURNS := 2
const LOOK_TURNS := 1
# In the dark a guard's seen tier, and an Operator's window, shrink to this.
const DARK_RANGE := 2
const WAKE_SOUND := 4
const DOG_STUN_COST := 1

const DOORS := ["door", "autodoor"]
const VEHICLES := ["car", "truck"]
const MOVEMENT := "movement"
const LOCATE := "locate"
const PREDICT := "predict"
const EXTENDED_THINKING := "extended_thinking"
const SUBAGENT := "subagent"

var map: MapData
var content: BattleContent
# Why the content can't make a valid battle. When there are any, the battle is left empty.
var errors := PackedStringArray()
var units: Array[Unit] = []
var round_number := 0
var active: Unit
var turn_over := false
# Each node's device, as it is now: powered, open, locked, its tile and facing, a turret's mode.
var devices := {}
var progress := {}
var breached := {}
var revealed_networks := {}
# The player's side of the fog: where each enemy was last seen, and which enemies have shown up
# at all, for the turn order.
var known := {}
var revealed := {}
var caution := {}
# Bodies the enemy has found, so each one raises one alert.
var discovered := {}
# Guards Predict is following until their next turn ends.
var predicted := {}
var camera_views := {}
# The data cache this mission is about: the one node of kind "cache" on the map.
var objective := ""
var cache_breached := false
var lit := {}
var visible_cells := {}
var _queue: Array[int] = []
var _node_defs := {}
var _chips := {}
var _links := {}
var _node_at := {}


func _init(p_map: MapData = null, p_content: BattleContent = null, loadouts: Array[Loadout] = [], carry := {}) -> void:
	if p_map == null and p_content == null:
		return
	map = p_map
	content = p_content
	errors = validate(map, content, loadouts)
	for error in errors:
		push_error(error)
	if not errors.is_empty():
		return
	for def in content.node_defs:
		_node_defs[def.kind] = def
	for chip in content.chips:
		_chips[chip.id] = chip
	for link in map.links:
		var ends := link.split("-")
		_links.get_or_add(ends[0], []).append(ends[1])
		_links.get_or_add(ends[1], []).append(ends[0])
	for id in map.node_ids():
		devices[id] = _device_start(id)
		if map.node_kind(id) == "cache":
			objective = id
	for hub in map.circuits:
		if not devices[hub].powered:
			for member in map.circuit(hub):
				devices[member].powered = false
	_index_nodes()
	var starts := map.player_starts()
	for i in content.operators.size():
		_add_operator(content.operators[i], loadouts[i], starts[i])
	for number in map.guard_numbers():
		var route := map.guard_route(number)
		var guard := _add(content.guard, "Guard %d" % number, route[0])
		guard.route = route
		if route.size() > 1:
			guard.facing = Vector2(route[1] - route[0]).normalized()
	for id in map.node_ids():
		if map.node_kind(id) == "turret":
			var turret := _add(content.turret, "Turret", map.node_cell(id))
			turret.node = id
			turret.facing = Vector2(devices[id].facing)
			turret.rest_facing = turret.facing
	_apply_carry(carry)
	refresh()


# Why this content can't make a valid battle. Empty when it can.
static func validate(p_map: MapData, p_content: BattleContent, loadouts: Array[Loadout]) -> PackedStringArray:
	if p_map == null:
		return PackedStringArray(["Battle: map is missing"])
	if p_content == null:
		return PackedStringArray(["Battle: content is missing"])
	var result := p_map.validate()
	var kinds := {}
	for i in p_content.node_defs.size():
		var def := p_content.node_defs[i]
		if def == null:
			result.append("Battle: node_defs[%d] is missing" % i)
		elif def.kind not in NodeDef.KINDS:
			result.append("Battle: node_defs[%d] has unsupported kind '%s'" % [i, def.kind])
		elif kinds.has(def.kind):
			result.append("Battle: node_defs[%d] repeats kind '%s'" % [i, def.kind])
		else:
			kinds[def.kind] = true
	var chips := {}
	for chip in p_content.chips:
		if chip != null:
			chips[chip.id] = chip
	if not chips.has(MOVEMENT):
		result.append("Battle: chips has no '%s' chip" % MOVEMENT)
	for field in ["guard", "turret", "drone", "dog_bot"]:
		if p_content.get(field) == null:
			result.append("Battle: content has no %s" % field)
	if p_content.operators.is_empty():
		result.append("Battle: operators is empty")
	if loadouts.size() != p_content.operators.size():
		result.append("Battle: %d loadouts for %d Operators" % [loadouts.size(), p_content.operators.size()])
	for i in p_content.operators.size():
		if p_content.operators[i] == null:
			result.append("Battle: operators[%d] is missing" % i)
	for i in loadouts.size():
		var loadout := loadouts[i]
		if loadout == null:
			result.append("Battle: loadouts[%d] is missing" % i)
			continue
		if loadout.chips.size() > Loadout.MAX_CHIPS:
			result.append("Battle: loadouts[%d] carries %d chips; the most is %d" % [i, loadout.chips.size(), Loadout.MAX_CHIPS])
		for chip in loadout.chips:
			if not chips.has(chip) or chip == MOVEMENT or loadout.chips.count(chip) > 1:
				result.append("Battle: loadouts[%d] has chip '%s', which isn't a chip it can carry once" % [i, chip])
	var caches: Array[String] = []
	for id in p_map.node_ids():
		var kind := p_map.node_kind(id)
		if kind != "" and not kinds.has(kind):
			result.append(p_map.field_error("node_kinds", "gives node '%s' the kind '%s', which has no NodeDef in this battle" % [id, kind]))
		if kind == "cache":
			caches.append(id)
	if caches.is_empty():
		result.append(p_map.field_error("node_kinds", "has no node of kind 'cache', so the mission has no objective"))
	elif caches.size() > 1:
		result.append(p_map.field_error("node_kinds", "has %d nodes of kind 'cache' (%s), so the objective is ambiguous" % [caches.size(), ", ".join(caches)]))
	if p_map.player_starts().size() < p_content.operators.size():
		result.append(p_map.field_error("layout", "has %d player starts (P) for %d Operators" % [p_map.player_starts().size(), p_content.operators.size()]))
	return result


# A copy that shares nothing that changes, for trying things out: Predict and the previews.
func clone() -> BattleState:
	var copy := BattleState.new()
	copy.map = map
	copy.content = content
	copy._node_defs = _node_defs
	copy._chips = _chips
	copy._links = _links
	for unit in units:
		copy.units.append(unit.copy())
	copy.active = copy.units[active.id] if active else null
	for field in ["round_number", "turn_over", "objective", "cache_breached"]:
		copy.set(field, get(field))
	for field in ["devices", "progress", "breached", "revealed_networks", "known", "revealed", "caution", "discovered",
			"predicted", "camera_views", "lit", "visible_cells", "_node_at"]:
		copy.set(field, get(field).duplicate(true))
	copy._queue = _queue.duplicate()
	return copy


# What a later phase starts with, per Operator: context, loaded chips, hits taken, downed, and
# whether their robot is still with them. Guards, caution and the fog reset with the map.
func carry_over() -> Dictionary:
	var result := {}
	for unit in operators():
		var robot_lost := unit.robot >= 0 and units[unit.robot].down
		result[unit.display_name] = {"context": unit.context, "chips": unit.chips.duplicate(),
			"hits": unit.hits, "down": unit.down, "robot_lost": robot_lost}
	return result


func _apply_carry(carry: Dictionary) -> void:
	for unit in operators():
		var entry: Dictionary = carry.get(unit.display_name, {})
		unit.context = entry.get("context", 0)
		unit.hits = entry.get("hits", 0)
		unit.down = entry.get("down", false)
		for chip in entry.get("chips", {}):
			if unit.chips.has(chip):
				unit.chips[chip] = entry.chips[chip]
		if entry.get("robot_lost", false):
			unit.robot_def = null


func _device_start(id: String) -> Dictionary:
	var def := node_def(id)
	var word: String = map.node_states.get(id, "")
	return {
		"powered": (def.starts_powered or word == "on") and word != "off",
		"open": word == "open",
		"locked": word == "locked",
		"cell": map.node_cell(id),
		"facing": map.node_facing(id),
		"mode": "hold",
	}


func _add_operator(def: UnitDef, loadout: Loadout, cell: Vector2i) -> void:
	var unit := _add(def, def.display_name, cell)
	unit.max_hits = Loadout.HITS[loadout.armor]
	unit.base_ap = def.ap - (Loadout.HEAVY_AP_COST if loadout.armor == Loadout.Armor.HEAVY else 0)
	unit.flashbangs = Loadout.FLASHBANGS if loadout.gear == Loadout.Gear.FLASHBANGS else 0
	match loadout.gear:
		Loadout.Gear.DRONE:
			unit.robot_def = content.drone
		Loadout.Gear.DOG_BOT:
			unit.robot_def = content.dog_bot
	unit.chips[MOVEMENT] = 0
	for chip in loadout.chips:
		unit.chips[chip] = 0
	unit.role = loadout.role
	unit.facing = Vector2(0, -1)


func _add(def: UnitDef, unit_name: String, cell: Vector2i) -> Unit:
	var unit := Unit.new(units.size(), def, unit_name, cell)
	units.append(unit)
	return unit


# --- Turns ---------------------------------------------------------------------------------------

func begin_next_turn() -> Unit:
	active = null
	turn_over = false
	if winner() != Winner.NONE:
		return null
	while active == null:
		if _queue.is_empty():
			if round_number > 0:
				_end_round()
			round_number += 1
			for unit in units.filter(_takes_turns):
				_queue.append(unit.id)
			_queue.sort_custom(func(a: int, b: int) -> bool: return _acts_before(units[a], units[b]))
			if _queue.is_empty():
				return null
		var next := units[_queue.pop_front()]
		if _takes_turns(next):
			active = next
	_start_turn(active)
	return active


# The units still to act this round, active first. Enemies the player hasn't seen yet stay off it.
func upcoming() -> Array[Unit]:
	var result: Array[Unit] = []
	if active and _shown_in_order(active):
		result.append(active)
	for id in _queue:
		if _takes_turns(units[id]) and _shown_in_order(units[id]):
			result.append(units[id])
	return result


func _shown_in_order(unit: Unit) -> bool:
	return unit.is_player() or unit.is_turret() or revealed.has(unit.id)


# Operators who share the active Operator's speed and haven't acted yet this round. The player
# can hand the turn to one of them, as long as the active one hasn't done anything.
func tied_operators() -> Array[Unit]:
	var result: Array[Unit] = []
	if active == null or not active.is_operator() or active.spent or turn_over:
		return result
	for id in _queue:
		var unit := units[id]
		if unit.is_operator() and _takes_turns(unit) and unit.def.speed == active.def.speed:
			result.append(unit)
	return result


func choose_operator(unit: Unit) -> bool:
	if not tied_operators().has(unit):
		return false
	_queue.erase(unit.id)
	active.incoming = maxi(0, active.ai_ap - AI_AP)
	active.ap = 0
	active.ai_ap = 0
	_queue.push_front(active.id)
	active = unit
	_start_turn(unit)
	return true


# Operators and the team's robots wait for the player; everyone else takes an automatic turn.
func is_player_controlled(unit: Unit) -> bool:
	return unit != null and unit.is_player() and (unit.is_operator() or unit.is_robot())


func take_automatic_turn() -> Array[Dictionary]:
	if active == null or is_player_controlled(active) or turn_over:
		return []
	var events := EnemyAI.take_turn(self, active)
	_finish_turn()
	return events


func end_turn(unit: Unit) -> Array[Dictionary]:
	if unit != active or turn_over or not is_player_controlled(unit):
		return []
	_finish_turn()
	return [{"type": "end_turn", "unit": unit}]


func _takes_turns(unit: Unit) -> bool:
	return not unit.down and not unit.tied


func _acts_before(a: Unit, b: Unit) -> bool:
	if a.def.speed != b.def.speed:
		return a.def.speed > b.def.speed
	if a.is_player() != b.is_player():
		return a.is_player()
	return a.id < b.id


func _start_turn(unit: Unit) -> void:
	unit.spent = false
	if unit.is_operator():
		unit.ap = unit.base_ap
		unit.ai_ap = 0 if unit.rebooting else AI_AP + unit.incoming
		unit.rebooting = false
		unit.shot_used = false
		unit.sprinted = false
		unit.overwatch = false
		unit.peeks.clear()
		unit.verb_uses.clear()
		unit.next_hack.clear()
	elif unit.is_robot() and unit.is_player():
		unit.ap = unit.def.ap
	refresh()


func _finish_turn() -> void:
	turn_over = true
	var unit := active
	if unit.is_operator():
		unit.incoming = 0
		unit.ap = 0
		unit.ai_ap = 0
		unit.peeks.clear()
		unit.next_hack.clear()
	elif unit.is_robot():
		unit.ap = 0
	if unit.located > 0:
		unit.located -= 1
	predicted.erase(unit.id)
	refresh()


func _end_round() -> void:
	for zone in caution.keys():
		caution[zone] -= 1
		if caution[zone] <= 0:
			caution.erase(zone)


# A turn ends on its own once the Operator and the AI have both spent all their AP, checked after
# the whole action, refund included.
func _after_action(unit: Unit) -> void:
	unit.spent = true
	if unit != active or turn_over:
		return
	if (unit.is_operator() and unit.ap <= 0 and unit.ai_ap <= 0) or (unit.is_robot() and unit.ap <= 0):
		_finish_turn()


func raise_caution(unit: Unit) -> void:
	caution[map.zone_at(unit.cell)] = CAUTION_ROUNDS


# --- The map and who's on it ---------------------------------------------------------------------

func node_def(id: String) -> NodeDef:
	return _node_defs.get(map.node_kind(id))


func chip_def(id: String) -> ChipDef:
	return _chips.get(id)


func node_cell(id: String) -> Vector2i:
	return devices[id].cell


func node_at(cell: Vector2i) -> String:
	return _node_at.get(cell, "")


func _index_nodes() -> void:
	_node_at.clear()
	for id in devices:
		_node_at[devices[id].cell] = id


# A vehicle that drove somewhere. Bodies in its trunk go with it.
func move_node(id: String, cell: Vector2i) -> void:
	devices[id].cell = cell
	_index_nodes()
	for unit in units:
		if unit.receptacle == "trunk:" + id:
			unit.cell = cell


func operators() -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in units:
		if unit.is_operator():
			result.append(unit)
	return result


func unit_at(cell: Vector2i) -> Unit:
	for unit in units:
		if unit.cell == cell and unit.on_map():
			return unit
	return null


# The team's units the enemy can see and shoot: Operators and robots on the map.
func team_targets() -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in units:
		if unit.is_player() and (unit.is_operator() or unit.is_robot()) and unit.on_map() and not unit.is_out():
			result.append(unit)
	return result


# Stunned or tied-up guards lying in the open.
func bodies() -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in units:
		if unit.is_guard() and unit.is_body() and unit.on_map():
			result.append(unit)
	return result


func blocks_walk(cell: Vector2i, flying := false) -> bool:
	if not map.in_bounds(cell) or map.is_wall(cell):
		return true
	var id := node_at(cell)
	if id != "":
		var kind := map.node_kind(id)
		if kind in DOORS:
			return not devices[id].open
		return kind not in VEHICLES or not flying
	return map.is_low(cell) and not flying


# High viewers, cameras and drones, see over low obstacles; people don't.
func blocks_sight(cell: Vector2i, high := false) -> bool:
	if not map.in_bounds(cell) or map.is_wall(cell):
		return true
	var id := node_at(cell)
	if id != "":
		var kind := map.node_kind(id)
		if kind in DOORS:
			return not devices[id].open
		if kind in VEHICLES:
			return not high
		return map.in_wall(cell)
	return map.is_low(cell) and not high


func has_line_of_sight(from: Vector2i, to: Vector2i, high := false) -> bool:
	return Grid.line_clear(from, to, func(cell: Vector2i) -> bool: return blocks_sight(cell, high))


func is_lit(cell: Vector2i) -> bool:
	return not map.night or lit.has(cell)


func refresh() -> void:
	lit = Perception.compute_lit(self)
	visible_cells = Perception.team_vision(self)
	_update_known()


func _update_known() -> void:
	for unit in units:
		if unit.is_player():
			continue
		if player_sees(unit):
			known[unit.id] = unit.cell
			revealed[unit.id] = true
		elif known.has(unit.id) and visible_cells.has(known[unit.id]):
			known.erase(unit.id)


# The team shares its vision. Turrets are structures, always on the map; everyone else needs live
# vision, or Locate.
func player_sees(unit: Unit) -> bool:
	if unit.is_player():
		return true
	if unit.down or unit.carried_by >= 0 or unit.receptacle != "":
		return false
	return unit.is_turret() or visible_cells.has(unit.cell) or unit.located > 0


# Enemies plan around the team's units they have in view, and the team around the enemies it sees.
# Anyone else gets walked into.
func knows(viewer: Unit, other: Unit) -> bool:
	if not viewer.is_enemy_of(other):
		return true
	if viewer.is_player():
		return player_sees(other)
	return viewer.in_view.has(other.id)


func can_pass(unit: Unit, cell: Vector2i) -> bool:
	if blocks_walk(cell, unit.def.flies):
		return false
	var other := unit_at(cell)
	return other == null or not other.is_enemy_of(unit) or not knows(unit, other)


func reach(unit: Unit, max_cost: int) -> Reach:
	return Reach.new(unit.cell, max_cost, func(cell: Vector2i) -> bool: return can_pass(unit, cell))


# What a single tile looks like to the enemy cones the player can see, for the move preview.
func exposure(cell: Vector2i) -> int:
	var worst := 0
	for viewer in Perception.viewers(self):
		if viewer.camera or player_sees(viewer.unit):
			worst = maxi(worst, Perception.tier(self, viewer, cell))
	return worst


# --- Moving --------------------------------------------------------------------------------------

# Where the active Operator or robot can move, and what each tile costs. A sprint covers up to 3
# tiles for 2 AP; cut short, it costs what walking would have.
func move_costs(unit: Unit, sprint := false) -> Dictionary:
	var result := {}
	if not _can_act(unit) or (sprint and (not unit.is_operator() or unit.overwatch)):
		return result
	var budget := unit.ap
	if sprint:
		budget = SPRINT_TILES if unit.ap >= SPRINT_COST else unit.ap
	var costs := reach(unit, budget).cost
	for cell in costs:
		if cell != unit.cell and _free_to_stand(unit, cell):
			result[cell] = mini(SPRINT_COST, costs[cell]) if sprint else costs[cell]
	return result


func _free_to_stand(unit: Unit, cell: Vector2i) -> bool:
	if blocks_walk(cell, unit.def.flies):
		return false
	var other := unit_at(cell)
	return other == null or (other.is_enemy_of(unit) and not knows(unit, other))


# Moves tile by tile. Revealing an enemy stops the move there; walking into a hidden one stops it a
# tile short. Each step can get the unit noticed or seen.
func move(unit: Unit, cell: Vector2i, sprint := false) -> Array[Dictionary]:
	var costs := move_costs(unit, sprint)
	if not costs.has(cell):
		return []
	var budget := unit.ap
	if sprint:
		budget = SPRINT_TILES if unit.ap >= SPRINT_COST else unit.ap
	var path := reach(unit, budget).path_to(cell)
	var walked: Array[Vector2i] = []
	var later: Array[Dictionary] = []
	for step in path:
		var other := unit_at(step)
		if other and other.is_enemy_of(unit):
			later.append({"type": "blocked", "unit": unit, "by": other})
			break
		var before := _visible_enemies()
		_place(unit, step)
		walked.append(step)
		refresh()
		later.append_array(Perception.sweep(self))
		var newly := _visible_enemies().filter(func(enemy: Unit) -> bool: return not before.has(enemy))
		if not newly.is_empty() and step != path.back() and not _shared(step, unit):
			later.append({"type": "revealed", "unit": unit, "enemies": newly})
			break
	var cost := mini(SPRINT_COST, walked.size()) if sprint else walked.size()
	unit.ap -= cost
	if sprint:
		unit.sprinted = true
	var events: Array[Dictionary] = [{"type": "move", "unit": unit, "path": walked, "cost": cost}]
	events.append_array(later)
	events.append_array(_check_tethers())
	_after_action(unit)
	return events


func _shared(cell: Vector2i, unit: Unit) -> bool:
	return units.any(func(other: Unit) -> bool: return other != unit and other.cell == cell and other.on_map())


func _visible_enemies() -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in units:
		if not unit.is_player() and not unit.is_turret() and not unit.is_out() and player_sees(unit):
			result.append(unit)
	return result


func _place(unit: Unit, cell: Vector2i) -> void:
	if cell != unit.cell:
		unit.facing = Vector2(cell - unit.cell)
	unit.cell = cell
	if unit.carrying >= 0:
		units[unit.carrying].cell = cell


# One step of an enemy's move, during its own turn: the team may see it go, the enemy may spot
# someone, and an Operator in overwatch may fire.
func step(unit: Unit, cell: Vector2i) -> Array[Dictionary]:
	var was_seen := player_sees(unit)
	_place(unit, cell)
	if was_seen and not player_sees(unit):
		known[unit.id] = cell
	_update_known()
	var events := Perception.sweep(self)
	events.append_array(check_overwatch(unit))
	return events


# An AI connects through its Operator, or a robot relaying, within 2 tiles of the access point.
# Ending a move beyond that pulls it out, with its context kept.
func _check_tethers() -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for unit in operators():
		if not unit.connected():
			continue
		var source := units[unit.relay] if unit.relay >= 0 else unit
		if source.down or Grid.distance(source.cell, node_cell(unit.entry)) > TETHER:
			pull_out(unit)
			events.append({"type": "disconnect", "unit": unit, "relay": source != unit})
	return events


func pull_out(unit: Unit) -> void:
	unit.ai_node = ""
	unit.entry = ""
	unit.relay = -1


# --- The Operator's actions ----------------------------------------------------------------------

func _can_act(unit: Unit) -> bool:
	return unit != null and unit == active and not turn_over and is_player_controlled(unit) and not unit.is_out() \
		and winner() == Winner.NONE


# Anything but moving, which is all a carrying Operator can do.
func _hands_free(unit: Unit) -> bool:
	return _can_act(unit) and unit.is_operator() and unit.carrying < 0


func can_shoot(unit: Unit) -> bool:
	return _hands_free(unit) and not unit.shot_used and not unit.sprinted


func shot_targets(unit: Unit) -> Array[Unit]:
	var result: Array[Unit] = []
	if not can_shoot(unit):
		return result
	for target in units:
		if target.is_enemy_of(unit) and target.on_map() and not target.is_out() and player_sees(target) \
				and Grid.distance(unit.cell, target.cell) <= unit.def.shot_range and has_line_of_sight(unit.cell, target.cell):
			result.append(target)
	return result


func shoot(unit: Unit, target: Unit) -> Array[Dictionary]:
	if not shot_targets(unit).has(target):
		return []
	unit.shot_used = true
	var events: Array[Dictionary] = [{"type": "shot", "unit": unit, "target": target}]
	events.append_array(hit(target, unit))
	refresh()
	events.append_array(Perception.sweep(self))
	_after_action(unit)
	return events


func set_overwatch(unit: Unit) -> Array[Dictionary]:
	if not can_shoot(unit):
		return []
	unit.shot_used = true
	unit.overwatch = true
	_after_action(unit)
	return [{"type": "overwatch_set", "unit": unit}]


# Fires at the first enemy that steps into an overwatching Operator's line of fire.
func check_overwatch(mover: Unit) -> Array[Dictionary]:
	if mover.is_player() or mover.is_out():
		return []
	for unit in operators():
		if unit.overwatch and not unit.down and Grid.distance(unit.cell, mover.cell) <= unit.def.shot_range \
				and sees_from(unit, mover.cell):
			unit.overwatch = false
			var events: Array[Dictionary] = [{"type": "overwatch", "unit": unit, "target": mover}]
			events.append_array(hit(mover, unit))
			return events
	return []


# What one of the team's own units can see from where it stands.
func sees_from(unit: Unit, cell: Vector2i) -> bool:
	var distance := Grid.distance(unit.cell, cell)
	return distance <= unit.def.sight and (distance <= DARK_RANGE or is_lit(cell)) \
		and has_line_of_sight(unit.cell, cell, unit.def.flies)


# A hit stuns an enemy, downs a robot, or costs an Operator one of their hits.
func hit(target: Unit, by: Unit) -> Array[Dictionary]:
	var result := "stunned"
	if target.is_operator():
		target.hits += 1
		result = "armor"
		if target.hits >= target.max_hits:
			result = "downed"
	elif target.is_robot():
		result = "downed"
	var events: Array[Dictionary] = [{"type": "hit", "unit": by, "target": target, "result": result}]
	if result == "downed":
		events.append_array(_down(target))
	elif result == "stunned":
		stun(target)
	return events


func stun(target: Unit) -> void:
	target.stun = STUN_TURNS
	target.aim = {}
	target.in_view = {}
	target.look = 0
	target.search = 0
	target.freeing = -1


func _down(unit: Unit) -> Array[Dictionary]:
	unit.down = true
	var events: Array[Dictionary] = []
	if unit.carrying >= 0:
		units[unit.carrying].carried_by = -1
		units[unit.carrying].cell = unit.cell
		unit.carrying = -1
	if unit.is_operator() and unit.connected():
		pull_out(unit)
		events.append({"type": "disconnect", "unit": unit, "relay": false})
	events.append_array(_check_tethers())
	return events


func door_options(unit: Unit) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not _hands_free(unit):
		return result
	for id in _adjacent_nodes(unit.cell, ["door"]):
		var device: Dictionary = devices[id]
		if device.locked:
			continue
		if device.open:
			if unit_at(device.cell) == null:
				result.append({"node": id, "action": "close"})
		else:
			result.append({"node": id, "action": "open"})
			if unit.ap >= LOCK_COST:
				result.append({"node": id, "action": "lock"})
	return result


# Opening and closing an unlocked door is free. Locking it by hand costs 1 AP; only an AI unlocks
# a locked door.
func use_door(unit: Unit, id: String, action: String) -> Array[Dictionary]:
	if not door_options(unit).has({"node": id, "action": action}):
		return []
	match action:
		"open":
			devices[id].open = true
		"close":
			devices[id].open = false
		"lock":
			devices[id].locked = true
			unit.ap -= LOCK_COST
	refresh()
	var events: Array[Dictionary] = [{"type": "door", "unit": unit, "node": id, "action": action}]
	events.append_array(Perception.sweep(self))
	_after_action(unit)
	return events


func peek_options(unit: Unit) -> Array[String]:
	var result: Array[String] = []
	if not _hands_free(unit) or unit.ap < PEEK_COST:
		return result
	for id in _adjacent_nodes(unit.cell, DOORS):
		if not devices[id].open and not unit.peeks.has(id):
			result.append(id)
	return result


func peek(unit: Unit, id: String) -> Array[Dictionary]:
	if not peek_options(unit).has(id):
		return []
	unit.ap -= PEEK_COST
	unit.peeks.append(id)
	refresh()
	_after_action(unit)
	return [{"type": "peek", "unit": unit, "node": id}]


func _adjacent_nodes(cell: Vector2i, kinds: Array) -> Array[String]:
	var result: Array[String] = []
	for neighbor in Grid.neighbors(cell):
		var id := node_at(neighbor)
		if id != "" and map.node_kind(id) in kinds:
			result.append(id)
	return result


# Where the AI can go in: access points within the tether, or through a robot near one.
func deploy_options(unit: Unit) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not _hands_free(unit) or unit.connected() or unit.rebooting or unit.ap < DEPLOY_AI_COST:
		return result
	var sources: Array[Unit] = [unit]
	for robot in units:
		if robot.is_robot() and robot.is_player() and not robot.down:
			sources.append(robot)
	for source in sources:
		for id in devices:
			if map.node_kind(id) == "access" and Grid.distance(source.cell, node_cell(id)) <= TETHER:
				result.append({"access": id, "relay": -1 if source == unit else source.id})
	return result


func deploy_ai(unit: Unit, access: String, relay := -1) -> Array[Dictionary]:
	if not deploy_options(unit).has({"access": access, "relay": relay}):
		return []
	unit.ap -= DEPLOY_AI_COST
	unit.ai_node = access
	unit.entry = access
	unit.relay = relay
	var network := map.network_of(access)
	var first := not revealed_networks.has(network)
	revealed_networks[network] = true
	_after_action(unit)
	return [{"type": "connect", "unit": unit, "node": access, "relay": relay, "network": network, "revealed": first}]


func tie_targets(unit: Unit) -> Array[Unit]:
	var result: Array[Unit] = []
	if not _hands_free(unit) or unit.ap < TIE_COST:
		return result
	for body in bodies():
		if not body.tied and Grid.distance(unit.cell, body.cell) == 1:
			result.append(body)
	return result


func tie_up(unit: Unit, body: Unit) -> Array[Dictionary]:
	if not tie_targets(unit).has(body):
		return []
	unit.ap -= TIE_COST
	body.tied = true
	_after_action(unit)
	return [{"type": "tie", "unit": unit, "target": body}]


func pickup_targets(unit: Unit) -> Array[Unit]:
	var result: Array[Unit] = []
	if not _hands_free(unit):
		return result
	for body in bodies():
		if Grid.distance(unit.cell, body.cell) == 1:
			result.append(body)
	return result


func pick_up(unit: Unit, body: Unit) -> Array[Dictionary]:
	if not pickup_targets(unit).has(body):
		return []
	body.carried_by = unit.id
	body.cell = unit.cell
	unit.carrying = body.id
	refresh()
	_after_action(unit)
	return [{"type": "pick_up", "unit": unit, "target": body}]


# A free tile next to the Operator, or a receptacle there, which hides the body.
func putdown_cells(unit: Unit) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if not _can_act(unit) or unit.carrying < 0:
		return result
	for cell in Grid.neighbors(unit.cell):
		if receptacle_at(cell) != "" or (not blocks_walk(cell) and unit_at(cell) == null):
			result.append(cell)
	return result


func put_down(unit: Unit, cell: Vector2i) -> Array[Dictionary]:
	if not putdown_cells(unit).has(cell):
		return []
	var body := units[unit.carrying]
	unit.carrying = -1
	body.carried_by = -1
	body.cell = cell
	body.receptacle = receptacle_at(cell)
	refresh()
	var events: Array[Dictionary] = [{"type": "put_down", "unit": unit, "target": body, "cell": cell, "hidden": body.receptacle != ""}]
	events.append_array(Perception.sweep(self))
	_after_action(unit)
	return events


func receptacle_at(cell: Vector2i) -> String:
	for line in map.receptacles:
		var parts := line.split(" ", false)
		if parts[0] == "dumpster" and MapData._cell(parts[1]) == cell:
			return "dumpster:" + parts[1]
		if parts[0] == "trunk" and node_cell(parts[1]) == cell:
			return "trunk:" + parts[1]
	return ""


func receptacle_cell(key: String) -> Vector2i:
	var parts := key.split(":")
	return node_cell(parts[1]) if parts[0] == "trunk" else MapData._cell(parts[1])


func flashbang_cells(unit: Unit) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if not _hands_free(unit) or unit.flashbangs <= 0 or unit.ap < FLASHBANG_COST:
		return result
	for x in range(unit.cell.x - FLASHBANG_RANGE, unit.cell.x + FLASHBANG_RANGE + 1):
		for y in range(unit.cell.y - FLASHBANG_RANGE, unit.cell.y + FLASHBANG_RANGE + 1):
			var cell := Vector2i(x, y)
			if Grid.distance(unit.cell, cell) <= FLASHBANG_RANGE and not blocks_sight(cell) and has_line_of_sight(unit.cell, cell):
				result.append(cell)
	return result


func flashbang_area(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for x in range(cell.x - FLASHBANG_RADIUS, cell.x + FLASHBANG_RADIUS + 1):
		for y in range(cell.y - FLASHBANG_RADIUS, cell.y + FLASHBANG_RADIUS + 1):
			var other := Vector2i(x, y)
			if map.in_bounds(other) and not map.is_wall(other) and Grid.distance(cell, other) <= FLASHBANG_RADIUS \
					and has_line_of_sight(cell, other):
				result.append(other)
	return result


# Blinded enemies hold still and see nothing for their next 3 turns, and lose their aim.
func throw_flashbang(unit: Unit, cell: Vector2i) -> Array[Dictionary]:
	if not flashbang_cells(unit).has(cell):
		return []
	unit.ap -= FLASHBANG_COST
	unit.flashbangs -= 1
	var area := flashbang_area(cell)
	var blinded: Array[Unit] = []
	for enemy in units:
		if enemy.team == UnitDef.Team.ENEMY and enemy.on_map() and not enemy.is_out() and area.has(enemy.cell):
			enemy.blind = BLIND_TURNS
			enemy.aim = {}
			enemy.in_view = {}
			blinded.append(enemy)
	_after_action(unit)
	return [{"type": "flashbang", "unit": unit, "cell": cell, "cells": area, "blinded": blinded}]


func robot_cells(unit: Unit) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if not _hands_free(unit) or unit.robot_def == null or unit.robot >= 0 or unit.ap < ROBOT_COST:
		return result
	for cell in Grid.neighbors(unit.cell):
		if not blocks_walk(cell) and unit_at(cell) == null:
			result.append(cell)
	return result


# A deployed robot joins the turn order from the next round.
func deploy_robot(unit: Unit, cell: Vector2i) -> Array[Dictionary]:
	if not robot_cells(unit).has(cell):
		return []
	unit.ap -= ROBOT_COST
	var robot := _add(unit.robot_def, "%s's %s" % [unit.display_name, unit.robot_def.display_name.to_lower()], cell)
	robot.owner = unit.id
	robot.stun_charges = unit.robot_def.stun_charges
	robot.facing = unit.facing
	unit.robot = robot.id
	refresh()
	var events: Array[Dictionary] = [{"type": "deploy_robot", "unit": unit, "robot": robot}]
	events.append_array(Perception.sweep(self))
	_after_action(unit)
	return events


func dog_stun_targets(robot: Unit) -> Array[Unit]:
	var result: Array[Unit] = []
	if not _can_act(robot) or not robot.is_robot() or robot.stun_charges <= 0 or robot.ap < DOG_STUN_COST:
		return result
	for target in units:
		if target.is_enemy_of(robot) and target.on_map() and not target.is_out() and Grid.distance(robot.cell, target.cell) == 1:
			result.append(target)
	return result


func dog_stun(robot: Unit, target: Unit) -> Array[Dictionary]:
	if not dog_stun_targets(robot).has(target):
		return []
	robot.ap -= DOG_STUN_COST
	robot.stun_charges -= 1
	var events: Array[Dictionary] = [{"type": "dog_stun", "unit": robot, "target": target}]
	events.append_array(hit(target, robot))
	refresh()
	events.append_array(Perception.sweep(self))
	_after_action(robot)
	return events


# Shared compute: AP one AI gives up goes to an adjacent Operator's AI for its next turn only.
func share_targets(unit: Unit) -> Array[Unit]:
	var result: Array[Unit] = []
	if not _can_act(unit) or not unit.is_operator() or unit.ai_ap < 1:
		return result
	for other in operators():
		if other != unit and not other.down and Grid.distance(unit.cell, other.cell) == 1:
			result.append(other)
	return result


func share_compute(unit: Unit, other: Unit) -> Array[Dictionary]:
	if not share_targets(unit).has(other):
		return []
	unit.ai_ap -= 1
	other.incoming += 1
	_after_action(unit)
	return [{"type": "share", "unit": unit, "target": other}]


# --- The AI's actions ----------------------------------------------------------------------------

func _can_ai(unit: Unit) -> bool:
	return _can_act(unit) and unit.is_operator() and unit.connected()


# Hops along the AI's network from where it is. Jump: a hop out of a Breached node it passes
# through is free, so held ground extends its reach. Breaches change it, so it isn't cached.
func network_hops(unit: Unit) -> Dictionary:
	return _network_search(unit.ai_node).hops


func _network_search(from: String) -> Dictionary:
	var hops := {from: 0}
	var came_from := {from: from}
	var frontier: Array[String] = [from]
	while not frontier.is_empty():
		var current: String = frontier.pop_front()
		var cost := 0 if current != from and breached.has(current) else 1
		for neighbor in _links.get(current, []):
			if hops.has(neighbor) and hops[neighbor] <= hops[current] + cost:
				continue
			hops[neighbor] = hops[current] + cost
			came_from[neighbor] = current
			if cost == 0:
				frontier.push_front(neighbor)
			else:
				frontier.append(neighbor)
	return {"hops": hops, "came_from": came_from}


func network_destinations(unit: Unit) -> Array[String]:
	var result: Array[String] = []
	if not _can_ai(unit) or unit.ai_ap < 1:
		return result
	var hops := network_hops(unit)
	for id in hops:
		if id != unit.ai_node and hops[id] <= NETWORK_RANGE:
			result.append(id)
	return result


func network_path(from: String, to: String) -> Array[String]:
	var came_from: Dictionary = _network_search(from).came_from
	var path: Array[String] = []
	if not came_from.has(to):
		return path
	var current := to
	while current != from:
		path.push_front(current)
		current = came_from[current]
	return path


# The first move loads the movement chip, if it isn't loaded yet.
func ai_move(unit: Unit, id: String) -> Array[Dictionary]:
	if not network_destinations(unit).has(id):
		return []
	var path := network_path(unit.ai_node, id)
	var loaded: bool = unit.chips[MOVEMENT] == 0
	if loaded:
		_load(unit, MOVEMENT)
	unit.ai_ap -= 1
	unit.ai_node = id
	_after_action(unit)
	return [{"type": "agent_move", "unit": unit, "path": path, "loaded": loaded}]


func can_hack(unit: Unit) -> bool:
	return _can_ai(unit) and unit.ai_ap >= 1 and is_hackable(unit.ai_node)


func is_hackable(id: String) -> bool:
	return node_def(id).goal > 0 and not breached.has(id)


func chip_strength(unit: Unit, id: String) -> float:
	var level: int = unit.chips.get(id, 0)
	if level == 0:
		return 1.0
	var chip := chip_def(id)
	return chip.strength if level == 2 else chip.degraded_strength


# Multipliers multiply, and the result rounds down. A full context halves it.
func hack_power(unit: Unit, id: String) -> int:
	var power := float(HACK_POWER)
	for chip_id in unit.chips:
		var chip := chip_def(chip_id)
		if chip.type == ChipDef.Type.PASSIVE and chip.category != "" and chip.category == node_def(id).category:
			power *= chip_strength(unit, chip_id)
	if unit.next_hack.has(EXTENDED_THINKING):
		power *= chip_strength(unit, EXTENDED_THINKING)
	if unit.context >= CONTEXT_MAX:
		power *= FULL_CONTEXT_YIELD
	return floori(power + 0.0001)


# Extended thinking scales the context a hack costs too, rounded up.
func hack_context(unit: Unit, id: String) -> int:
	var cost := float(node_def(id).context_cost)
	if unit.next_hack.has(EXTENDED_THINKING):
		cost *= chip_strength(unit, EXTENDED_THINKING)
	return ceili(cost - 0.0001)


# With Subagent waiting, the linked nodes it can work on alongside the hack.
func subagent_links(unit: Unit) -> Array[String]:
	var result: Array[String] = []
	if not unit.next_hack.has(SUBAGENT):
		return result
	for id in _links.get(unit.ai_node, []):
		if is_hackable(id):
			result.append(id)
	return result


func subagent_points(unit: Unit, points: int) -> int:
	return floori(points * chip_strength(unit, SUBAGENT) + 0.0001)


# A single hack that takes a node from untouched to Breached refunds its AP. With Subagent, either
# node can earn it, but one action earns one refund at most.
func hack(unit: Unit, linked := "") -> Array[Dictionary]:
	if not can_hack(unit) or (linked != "" and not subagent_links(unit).has(linked)):
		return []
	var id := unit.ai_node
	var points := hack_power(unit, id)
	var context := hack_context(unit, id)
	unit.ai_ap -= 1
	add_context(unit, context)
	var events: Array[Dictionary] = []
	var refund := _add_progress(unit, id, points, events)
	var linked_points := 0
	if linked != "":
		linked_points = subagent_points(unit, points)
		refund = _add_progress(unit, linked, linked_points, events) or refund
	unit.next_hack.clear()
	if refund:
		unit.ai_ap += 1
	events.push_front({"type": "hack", "unit": unit, "node": id, "points": points, "context": context,
		"linked": linked, "linked_points": linked_points, "refund": refund})
	refresh()
	events.append_array(Perception.sweep(self))
	_after_action(unit)
	return events


# True when this progress took the node from untouched to Breached.
func _add_progress(unit: Unit, id: String, points: int, events: Array[Dictionary]) -> bool:
	var untouched: bool = progress.get(id, 0) == 0
	progress[id] = progress.get(id, 0) + points
	if progress[id] < node_def(id).goal:
		return false
	_breach(id)
	events.append({"type": "breach", "unit": unit, "node": id})
	return untouched


# Breaching gives the team the device's verbs. A camera stops reporting the team, and something
# autonomous, like a turret, changes sides.
func _breach(id: String) -> void:
	breached[id] = true
	camera_views.erase(id)
	for unit in units:
		if unit.node == id:
			unit.team = UnitDef.Team.PLAYER
			unit.aim = {}
			unit.task = Unit.Task.PATROL
			unit.target = -1
			unit.in_view = {}
	if map.node_kind(id) == "cache":
		cache_breached = true


func add_context(unit: Unit, amount: int) -> void:
	unit.context = mini(CONTEXT_MAX, unit.context + amount)


func compacted(context: int) -> int:
	return roundi(context * COMPACT_KEEPS)


func can_compact(unit: Unit) -> bool:
	return _can_act(unit) and unit.is_operator() and unit.ai_ap >= 1 and unit.context > 0


func compact(unit: Unit) -> Array[Dictionary]:
	if not can_compact(unit):
		return []
	unit.ai_ap -= 1
	var before := unit.context
	var degraded := _compact_context(unit)
	_after_action(unit)
	return [{"type": "compact", "unit": unit, "before": before, "degraded": degraded}]


# Keeps a quarter of the context and degrades every loaded chip a step. The movement chip only
# unloads if what's left is below its own cost.
func _compact_context(unit: Unit) -> Array[String]:
	unit.context = compacted(unit.context)
	var degraded: Array[String] = []
	for id in unit.chips:
		if unit.chips[id] == 0:
			continue
		if id == MOVEMENT:
			if unit.context < chip_def(id).load_cost:
				unit.chips[id] = 0
				degraded.append(id)
			continue
		unit.chips[id] -= 1
		degraded.append(id)
		if unit.chips[id] == 0:
			unit.next_hack.erase(id)
	return degraded


# Knocked out by network opposition: back to the backpack, a forced compaction, and the next turn
# lost to rebooting. Nothing in V1 causes it; V2's ICE and daemons will.
func crash(unit: Unit) -> Array[Dictionary]:
	if not unit.connected():
		return []
	pull_out(unit)
	var degraded := _compact_context(unit)
	unit.rebooting = true
	return [{"type": "crash", "unit": unit, "degraded": degraded}]


# Passive chips are loaded on their own, for context and no AP. Active ones load when first used.
func load_options(unit: Unit) -> Array[String]:
	var result: Array[String] = []
	if not _can_act(unit) or not unit.is_operator():
		return result
	for id in unit.chips:
		if unit.chips[id] == 0 and chip_def(id).type != ChipDef.Type.ACTIVE:
			result.append(id)
	return result


func load_chip(unit: Unit, id: String) -> Array[Dictionary]:
	if not load_options(unit).has(id):
		return []
	_load(unit, id)
	_after_action(unit)
	return [{"type": "chip", "unit": unit, "chip": id, "loaded": true, "used": false, "targets": []}]


func _load(unit: Unit, id: String) -> void:
	add_context(unit, chip_def(id).load_cost)
	unit.chips[id] = 2


func chip_ready(unit: Unit, id: String) -> bool:
	if not _can_ai(unit) or unit.ai_ap < 1 or not unit.chips.has(id) or chip_def(id).type != ChipDef.Type.ACTIVE:
		return false
	match id:
		LOCATE:
			return not locate_targets().is_empty()
		PREDICT:
			return not predict_targets().is_empty()
	return not unit.next_hack.has(id)


# How many turns Locate lasts, or how many guards Predict follows, at the chip's level.
func chip_count(unit: Unit, id: String) -> int:
	var level: int = unit.chips.get(id, 0)
	var chip := chip_def(id)
	return int(chip.degraded_strength if level == 1 else chip.strength)


func locate_targets() -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in units:
		if unit.team == UnitDef.Team.ENEMY and not unit.is_turret() and not unit.down and unit.carried_by < 0 \
				and unit.receptacle == "" and not player_sees(unit):
			result.append(unit)
	return result


func predict_targets() -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in units:
		if unit.is_guard() and unit.team == UnitDef.Team.ENEMY and not unit.is_out() and player_sees(unit) and not predicted.has(unit.id):
			result.append(unit)
	return result


func use_chip(unit: Unit, id: String, targets: Array[Unit] = []) -> Array[Dictionary]:
	if not chip_ready(unit, id):
		return []
	match id:
		LOCATE:
			if targets.size() != 1 or not locate_targets().has(targets[0]):
				return []
		PREDICT:
			if targets.is_empty() or targets.size() > chip_count(unit, id) \
					or targets.any(func(target: Unit) -> bool: return not predict_targets().has(target)):
				return []
	var loaded: bool = unit.chips[id] == 0
	if loaded:
		_load(unit, id)
	unit.ai_ap -= 1
	match id:
		LOCATE:
			targets[0].located = chip_count(unit, id)
		PREDICT:
			for target in targets:
				predicted[target.id] = true
		_:
			unit.next_hack[id] = true
	refresh()
	_after_action(unit)
	return [{"type": "chip", "unit": unit, "chip": id, "loaded": loaded, "used": true, "targets": targets}]


# What a predicted guard will do on its next turn if nothing changes: its path, and the line it
# would aim along. It runs the guard's real turn on a copy of the battle.
func prediction(guard: Unit) -> Dictionary:
	var copy := clone()
	var ghost := copy.units[guard.id]
	copy.active = ghost
	var path: Array[Vector2i] = [ghost.cell]
	var fires := false
	for event in EnemyAI.take_turn(copy, ghost):
		if event.type == "move" and event.unit == ghost:
			path.append_array(event.path)
		elif event.type == "fire" and event.unit == ghost:
			fires = true
	return {"path": path, "aim": ghost.aim.get("cells", []), "target": ghost.aim.get("target", -1), "fires": fires}


func verb_options(unit: Unit) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not _can_ai(unit):
		return result
	for id in devices:
		if not breached.has(id) or map.network_of(id) != map.network_of(unit.ai_node):
			continue
		for verb in node_def(id).verbs:
			var directions := [1, -1] if verb == "activate" and map.node_kind(id) in VEHICLES else [1]
			for direction in directions:
				result.append({"node": id, "verb": verb, "direction": direction,
					"enabled": Devices.can_use(self, unit, id, verb, direction)})
	return result


func use_verb(unit: Unit, id: String, verb: String, direction := 1) -> Array[Dictionary]:
	if not _can_ai(unit) or not Devices.can_use(self, unit, id, verb, direction):
		return []
	var events := Devices.use(self, unit, id, verb, direction)
	events.append_array(_check_tethers())
	_after_action(unit)
	return events


# What a verb would do, tried on a copy: its sound, and the guards it would draw.
func verb_preview(unit: Unit, id: String, verb: String, direction := 1) -> Array[Dictionary]:
	var copy := clone()
	return copy.use_verb(copy.units[unit.id], id, verb, direction)


func turret_controls(unit: Unit) -> Array[String]:
	var result: Array[String] = []
	if not _can_ai(unit):
		return result
	for id in devices:
		if map.node_kind(id) == "turret" and breached.has(id) and map.network_of(id) == map.network_of(unit.ai_node):
			result.append(id)
	return result


# Free: a Breached turret either targets enemies on its own turn, or holds.
func set_turret_mode(unit: Unit, id: String, mode: String) -> Array[Dictionary]:
	if not turret_controls(unit).has(id) or mode not in ["hold", "target"] or devices[id].mode == mode:
		return []
	devices[id].mode = mode
	return [{"type": "turret_mode", "unit": unit, "node": id, "mode": mode}]


# --- The end -------------------------------------------------------------------------------------

# Win: breach the cache, then get every Operator still standing onto the extraction tiles. Lose:
# every Operator downed. Robots don't count either way.
func winner() -> Winner:
	var standing := operators().filter(func(unit: Unit) -> bool: return not unit.down)
	if standing.is_empty():
		return Winner.ENEMY
	if cache_breached and extracted() == standing.size():
		return Winner.PLAYER
	return Winner.NONE


func extracted() -> int:
	var count := 0
	for unit in operators():
		if not unit.down and map.extraction().has(unit.cell):
			count += 1
	return count
