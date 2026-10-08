class_name HoverInfo

# What the hover card says about a tile, read from the player's side of the fog. The card leads
# with the most important thing on the tile (a unit, then a device, then a hiding place) and keeps
# the tile itself for the footer. A card is a dictionary the Hud draws:
#   kicker, title, color, and either icon (a texture) or initial (a letter)
#   lines: [{text, color}], progress: Vector2i(done, goal) or absent, footer
# Nothing here changes the battle.

const TEXT := Color(0.88, 0.94, 0.9)
const MUTED := Color(0.62, 0.7, 0.7)
const GOOD := Color(0.45, 0.93, 0.68)
const WARN := Color(1.0, 0.78, 0.3)
const DANGER := Color(1.0, 0.42, 0.34)
const ENEMY := NetworkView.ENEMY
const TASKS := ["Patrolling", "Investigating", "ALERTED", "Searching"]


# pick: while choosing a tile, {"cost": AP, "mover": Unit} for a tile that can be chosen.
# token: the AI token under the cursor in the network view.
static func card(state: BattleState, cell: Vector2i, pick := {}, token: Unit = null) -> Dictionary:
	var result := {}
	var unit := state.unit_at(cell)
	var node := state.node_at(cell)
	var receptacle := state.receptacle_at(cell)
	if token:
		result = _ai(state, token)
	elif unit and state.player_sees(unit) and not unit.is_turret():
		result = _unit(state, unit)
	elif node != "" and not state.is_hidden_turret(node):
		result = _device(state, node)
		if unit and unit.is_turret() and not unit.is_player():
			result.lines.append_array(_unit(state, unit).lines)
	elif receptacle != "":
		result = _receptacle(state, receptacle)
	else:
		result = _tile(state, cell)
		return _with_pick(state, result, cell, pick)
	if node != "" and token:
		result.lines.append({"text": "On %s %s" % [state.node_def(node).display_name, node.to_upper()], "color": MUTED})
	for id in state.known:
		if state.known[id] == cell and not state.player_sees(state.units[id]):
			result.lines.append({"text": "%s was last seen here" % state.units[id].display_name, "color": DANGER})
	result.footer = _tile_line(state, cell)
	return _with_pick(state, result, cell, pick)


static func _with_pick(state: BattleState, result: Dictionary, cell: Vector2i, pick: Dictionary) -> Dictionary:
	if pick.is_empty():
		return result
	var mover: Unit = pick.mover
	var lines: Array = []
	var exposure := state.exposure(cell) if mover.is_player() else 0
	lines.append({"text": "%d AP%s" % [pick.cost, ["", "   ·   would get you NOTICED", "   ·   would get you SEEN"][exposure]],
		"color": [TEXT, WARN, DANGER][exposure]})
	var tether := _tether_text(state, mover, cell)
	if tether != "":
		lines.append({"text": tether, "color": GOOD if tether == "AI stays connected" else DANGER})
	result.lines = lines + result.lines
	return result


static func _unit(state: BattleState, unit: Unit) -> Dictionary:
	var lines: Array = []
	if unit.is_operator():
		lines.append({"text": "Armor   " + "■".repeat(unit.max_hits - unit.hits) + "□".repeat(unit.hits), "color": TEXT})
		if unit.down:
			lines.append({"text": "DOWN", "color": DANGER})
		if unit.carrying >= 0:
			lines.append({"text": "Carrying " + state.units[unit.carrying].display_name, "color": MUTED})
		var ai := "AI in the backpack"
		if unit.connected():
			ai = "AI on %s" % unit.ai_node.to_upper()
		elif unit.rebooting > 0:
			ai = "AI rebooting"
		lines.append({"text": ai, "color": MUTED})
		return {"kicker": "OPERATOR" + ("  ·  " + unit.role.get_slice(":", 0).to_upper() if unit.role != "" else ""), "title": unit.display_name,
			"initial": unit.display_name.left(1), "color": unit.def.color.lightened(0.2), "lines": lines}
	if unit.is_robot():
		if unit.down:
			lines.append({"text": "DOWN", "color": DANGER})
		return {"kicker": "ROBOT", "title": unit.display_name, "initial": unit.def.display_name.left(1),
			"color": unit.def.color.lightened(0.2), "lines": lines}
	var kicker := "TURRET" if unit.is_turret() else "GUARD"
	if unit.tied:
		lines.append({"text": "Tied up", "color": GOOD})
	elif unit.stun > 0:
		lines.append({"text": "Stunned   %d turn%s" % [unit.stun, "s" if unit.stun != 1 else ""], "color": GOOD})
	elif unit.down:
		lines.append({"text": "Down", "color": GOOD})
	else:
		lines.append({"text": TASKS[unit.task], "color": [TEXT, WARN, DANGER, WARN][unit.task]})
		if unit.blind > 0:
			lines.append({"text": "Blinded   %d turn%s" % [unit.blind, "s" if unit.blind != 1 else ""], "color": GOOD})
		if not unit.aim.is_empty():
			lines.append({"text": "Aiming at " + state.units[unit.aim.target].display_name, "color": DANGER})
	if unit.max_hits > 1:
		lines.append({"text": "Armor   " + "■".repeat(unit.max_hits - unit.hits) + "□".repeat(unit.hits), "color": TEXT})
	if unit.receptacle != "":
		lines.append({"text": "Hidden away", "color": MUTED})
	return {"kicker": kicker, "title": unit.display_name, "initial": unit.display_name.left(1), "color": ENEMY, "lines": lines}


static func _ai(state: BattleState, unit: Unit) -> Dictionary:
	var lines: Array = [
		{"text": "AI AP   %d" % unit.ai_ap, "color": TEXT},
		{"text": "Context   %dM / %dM" % [unit.context, BattleState.CONTEXT_MAX], "color": TEXT},
	]
	return {"kicker": "AI", "title": "%s's AI" % unit.display_name, "initial": unit.display_name.left(1),
		"color": unit.def.color.lightened(0.3), "lines": lines}


static func _device(state: BattleState, id: String) -> Dictionary:
	var def := state.node_def(id)
	var kind := state.map.node_kind(id)
	var lines: Array = []
	var result := {"kicker": def.category.to_upper() if def.category != "" else "DEVICE", "title": "%s %s" % [def.display_name, id.to_upper()],
		"icon": NetworkView.ICONS[kind], "color": NetworkView.COLORS[kind], "lines": lines}
	var status := NetworkView.status(state, id)
	if status != "":
		lines.append({"text": status, "color": TEXT})
	if id == state.objective:
		result.kicker = "OBJECTIVE"
	if kind == "access":
		result.kicker = "ACCESS POINT"
		lines.append({"text": "AI entry to the %s network" % state.map.network_of(id), "color": MUTED})
	elif state.breached.has(id):
		result.color = NetworkView.BREACHED
		lines.append({"text": "BREACHED", "color": GOOD})
		var verbs := ", ".join(def.verbs) if not def.verbs.is_empty() else ("target or hold" if kind == "turret" else "")
		if verbs != "":
			lines.append({"text": "Controls   " + verbs, "color": MUTED})
	elif not state.revealed_networks.has(state.map.network_of(id)):
		lines.append({"text": "Network unknown", "color": MUTED})
	elif def.goal > 0:
		result.progress = Vector2i(state.progress.get(id, 0), def.goal)
	var facts: Array[String] = []
	if def.sound_radius > 0:
		facts.append("Sound %d%s" % [def.sound_radius, ", draws all" if def.sound_all else ""])
	if state.map.hub_of(id) != "":
		facts.append("Circuit " + state.map.hub_of(id).to_upper())
	if not facts.is_empty():
		lines.append({"text": "   ·   ".join(facts), "color": MUTED})
	return result


static func _receptacle(state: BattleState, id: String) -> Dictionary:
	var inside := state.units.filter(func(body: Unit) -> bool: return body.receptacle == id).size()
	return {"kicker": "HIDING PLACE", "title": "Hiding place", "initial": "▣", "color": MUTED,
		"lines": [{"text": "%d inside" % inside if inside > 0 else "Empty", "color": TEXT}]}


static func _tile(state: BattleState, cell: Vector2i) -> Dictionary:
	var zone := state.map.zone_at(cell)
	var lines: Array = []
	if state.map.night and not state.map.is_wall(cell):
		lines.append({"text": "Lit" if state.is_lit(cell) else "Dark", "color": WARN if state.is_lit(cell) else TEXT})
	if state.caution.has(zone):
		lines.append({"text": "Caution %d" % state.caution[zone], "color": WARN})
	for id in state.known:
		if state.known[id] == cell and not state.player_sees(state.units[id]):
			lines.append({"text": "%s was last seen here" % state.units[id].display_name, "color": DANGER})
	if not state.visible_cells.has(cell):
		lines.append({"text": "No vision", "color": MUTED})
	return {"kicker": "TILE %d, %d" % [cell.x, cell.y], "title": zone if zone != "" else ("Wall" if state.map.is_wall(cell) else "Open ground"),
		"color": MUTED, "lines": lines, "small": true}


static func _tile_line(state: BattleState, cell: Vector2i) -> String:
	var parts: Array[String] = ["Tile %d, %d" % [cell.x, cell.y]]
	var zone := state.map.zone_at(cell)
	if zone != "":
		parts.append(zone + ("  caution %d" % state.caution[zone] if state.caution.has(zone) else ""))
	if state.map.night and not state.map.is_wall(cell):
		parts.append("lit" if state.is_lit(cell) else "dark")
	if not state.visible_cells.has(cell):
		parts.append("no vision")
	return "   ·   ".join(parts)


# The AIs this unit tethers, itself or as a relay, and whether moving to the tile keeps them in.
static func _tether_text(state: BattleState, mover: Unit, cell: Vector2i) -> String:
	var tethered := false
	var dropped: Array[String] = []
	for operator in state.operators():
		var source := operator.relay if operator.relay >= 0 else operator.id
		if operator.connected() and source == mover.id:
			tethered = true
			if Grid.distance(cell, state.node_cell(operator.entry)) > BattleState.TETHER:
				dropped.append(operator.display_name)
	if not tethered:
		return ""
	if dropped.is_empty():
		return "AI stays connected"
	return "%s's AI will be pulled out" % ", ".join(dropped)
