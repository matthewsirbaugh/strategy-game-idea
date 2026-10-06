class_name BattleMenus

# What the action menus offer, read from what the rules allow right now. Each action is a
# dictionary: an "id" the battle controller acts on, the "text", and optionally "enabled", a
# "tip" and a "group". nest() folds each group of two or more into one submenu entry. Nothing here
# changes the battle.


# Returns the top-level actions and each folded group's actions, which end with a way back.
static func nest(actions: Array, back_id: String) -> Dictionary:
	var members := {}
	for action in actions:
		if action.has("group"):
			members[action.group] = members.get(action.group, []) + [action]
	var top := []
	var groups := {}
	for action in actions:
		var group: String = action.get("group", "")
		if group == "" or members[group].size() == 1:
			top.append(action)
		elif not groups.has(group):
			groups[group] = members[group] + [{"id": back_id, "text": "←   Back"}]
			var usable: bool = members[group].any(func(entry: Dictionary) -> bool: return entry.get("enabled", true))
			top.append({"id": "group:" + group, "text": group + "   →", "enabled": usable})
	return {"top": top, "groups": groups}


# A group's members are listed together, so the menu keeps its order whether a group folds or not.
static func operator_actions(state: BattleState, unit: Unit) -> Array:
	var actions := []
	if not state.move_costs(unit).is_empty():
		actions.append({"id": "move", "text": "Move   1 AP a tile", "tip": "Tiles that would get you noticed are amber, seen red"})
	if not state.move_costs(unit, true).is_empty():
		actions.append({"id": "sprint", "text": "Sprint   %d tiles for %d AP" % [BattleState.SPRINT_TILES, BattleState.SPRINT_COST], "tip": "Gives up this turn's shot. Cut short, it costs what walking would have"})
	if not state.shot_targets(unit).is_empty():
		actions.append({"group": "Shoot", "id": "shoot", "text": "Shoot   free, once a turn", "tip": "Range %d, line of sight. A hit stuns an enemy for %d turns" % [unit.def.shot_range, BattleState.STUN_TURNS]})
	if state.can_shoot(unit):
		actions.append({"group": "Shoot", "id": "overwatch", "text": "Overwatch   holds the shot", "tip": "Fires at the first enemy that moves into your line of fire, until your next turn"})
	for option in state.door_options(unit):
		var cost := "   %d AP" % BattleState.LOCK_COST if option.action == "lock" else "   free"
		actions.append({"group": "Interact", "id": "door:%s:%s" % [option.node, option.action], "text": "%s door %s%s" % [option.action.capitalize(), option.node.to_upper(), cost]})
	for id in state.peek_options(unit):
		actions.append({"group": "Interact", "id": "peek:" + id, "text": "Peek through %s   %d AP" % [id.to_upper(), BattleState.PEEK_COST], "tip": "See past the door until your turn ends"})
	for body in state.tie_targets(unit):
		actions.append({"group": "Interact", "id": "tie:%d" % body.id, "text": "Tie up %s   %d AP" % [body.display_name, BattleState.TIE_COST]})
	for body in state.pickup_targets(unit):
		actions.append({"group": "Interact", "id": "pickup:%d" % body.id, "text": "Pick up %s   free" % body.display_name, "tip": "While carrying you can only move"})
	if not state.putdown_cells(unit).is_empty():
		actions.append({"group": "Interact", "id": "putdown", "text": "Put down %s   free" % state.units[unit.carrying].display_name, "tip": "On a dumpster or trunk, it's hidden inside"})
	if not state.flashbang_cells(unit).is_empty():
		actions.append({"group": "Gear", "id": "flashbang", "text": "Flashbang   %d AP  (%d left)" % [BattleState.FLASHBANG_COST, unit.flashbangs],
			"tip": "Thrown up to %d tiles; blinds guards within %d for %d turns" % [BattleState.FLASHBANG_RANGE, BattleState.FLASHBANG_RADIUS, BattleState.BLIND_TURNS]})
	if not state.robot_cells(unit).is_empty():
		actions.append({"group": "Gear", "id": "robot", "text": "Deploy %s   %d AP" % [unit.robot_def.display_name.to_lower(), BattleState.ROBOT_COST], "tip": "It acts from next round"})
	for option in state.deploy_options(unit):
		actions.append(_deploy_action(state, option, "AI"))
	for other in state.share_targets(unit):
		actions.append({"group": "AI", "id": "share:%d" % other.id, "text": "Give %s's AI 1 AP" % other.display_name, "tip": "Shared compute: it arrives on their next turn, and lapses if unused"})
	actions.append({"group": "AI", "id": "ai", "text": "AI actions   →", "tip": "The AI's own actions, on its own AP"})
	for other in state.tied_operators():
		actions.append({"group": "Switch Operator", "id": "choose:%d" % other.id, "text": "Act with %s first" % other.display_name})
	actions.append({"id": "end", "text": "End turn"})
	return actions


# An AI still in the backpack is offered the access points it can go in at first.
static func ai_actions(state: BattleState, unit: Unit) -> Array:
	var actions := []
	for option in state.deploy_options(unit):
		actions.append(_deploy_action(state, option))
	if unit.connected():
		if not state.network_destinations(unit).is_empty():
			var load := "   loads movement +%dM" % state.chip_def(BattleState.MOVEMENT).load_cost if unit.chips[BattleState.MOVEMENT] == 0 else ""
			actions.append({"id": "ai_move", "text": "Move   1 AP" + load, "tip": "Up to %d hops; hops out of Breached nodes are free" % BattleState.NETWORK_RANGE})
		if state.can_hack(unit):
			var id := unit.ai_node
			var text := "Hack %s  +%d   1 AP, +%dM" % [id.to_upper(), state.hack_power(unit, id), state.hack_context(unit, id)]
			actions.append({"group": "Hack", "id": "hack:", "text": text, "tip": "A one-action breach from untouched refunds the AP"})
			for linked in state.subagent_links(unit):
				actions.append({"group": "Hack", "id": "hack:" + linked, "text": "Hack with a subagent on %s  +%d" % [linked.to_upper(), state.subagent_points(unit, state.hack_power(unit, id))]})
	if state.can_compact(unit):
		actions.append({"id": "compact", "text": "Compact   1 AP: %dM to %dM" % [unit.context, state.compacted(unit.context)], "tip": "Degrades every loaded chip a step"})
	for id in state.load_options(unit):
		actions.append({"group": "Chips", "id": "load:" + id, "text": "Load %s   +%dM" % [state.chip_def(id).display_name, state.chip_def(id).load_cost]})
	for id in unit.chips:
		var chip := state.chip_def(id)
		if chip.type != ChipDef.Type.ACTIVE or not unit.connected():
			continue
		var load := "   +%dM to load" % chip.load_cost if unit.chips[id] == 0 else ""
		var waiting := "   (ready for the next hack)" if unit.next_hack.has(id) else ""
		actions.append({"group": "Chips", "id": "chip:" + id, "text": "%s   1 AP%s%s" % [chip.display_name, load, waiting], "enabled": state.chip_ready(unit, id), "tip": chip.effect})
	for option in state.verb_options(unit):
		actions.append({"group": "Devices", "id": _verb_id(option), "text": _verb_text(state, option), "enabled": option.enabled,
			"tip": "Verbs cost no AP and %dM context each" % BattleState.VERB_CONTEXT})
	for id in state.turret_controls(unit):
		var mode := "hold" if state.devices[id].mode == "target" else "target"
		actions.append({"group": "Devices", "id": "turret:%s:%s" % [id, mode], "text": "Turret %s: %s   free" % [id.to_upper(), "hold fire" if mode == "hold" else "target enemies"]})
	if actions.is_empty():
		actions.append({"id": "none", "text": "Nothing the AI can do yet", "enabled": false})
	actions.append({"id": "physical", "text": "←   Operator"})
	actions.append({"id": "end", "text": "End turn"})
	return actions


static func device_actions(state: BattleState, unit: Unit, only := "") -> Array:
	var actions := []
	for option in state.verb_options(unit):
		if only != "" and option.node != only:
			continue
		actions.append({"id": _verb_id(option), "text": _verb_text(state, option), "enabled": option.enabled})
	actions.append({"id": "ai", "text": "←   Back"})
	return actions


static func _deploy_action(state: BattleState, option: Dictionary, group := "") -> Dictionary:
	var via: String = "" if option.relay < 0 else " via " + state.units[option.relay].def.display_name.to_lower()
	var action := {"id": "deploy:%s:%d" % [option.access, option.relay], "tip": "The AI goes into the network, and the view follows it",
		"text": "Deploy AI at %s%s   %d AP" % [option.access.to_upper(), via, BattleState.DEPLOY_AI_COST]}
	if group != "":
		action.group = group
	return action


static func _verb_id(option: Dictionary) -> String:
	return "verb:%s:%s:%d" % [option.node, option.verb, option.direction]


static func _verb_text(state: BattleState, option: Dictionary) -> String:
	var id: String = option.node
	var device: Dictionary = state.devices[id]
	var what := "%s %s: " % [state.node_def(id).display_name, id.to_upper()]
	match option.verb:
		"power":
			what += "power off" if device.powered else "power on"
		"lock":
			what += "unlock" if device.locked else "lock"
		"activate":
			match state.map.node_kind(id):
				"autodoor":
					what += "close" if device.open else "open"
				"phone":
					what += "ring"
				"adscreen":
					what += "flash"
				_:
					what += "drive forward" if option.direction == 1 else "drive backward"
	return what + "   +%dM" % BattleState.VERB_CONTEXT


static func robot_actions(state: BattleState, unit: Unit) -> Array:
	var actions := []
	if not state.move_costs(unit).is_empty():
		actions.append({"id": "move", "text": "Move   1 AP a tile"})
	if not state.dog_stun_targets(unit).is_empty():
		actions.append({"id": "dog_stun", "text": "Stun   %d AP, once a battle" % BattleState.DOG_STUN_COST})
	actions.append({"id": "end", "text": "End turn"})
	return actions


static func locate_actions(state: BattleState) -> Array:
	var actions := []
	for target in state.locate_targets():
		actions.append({"id": "locate:%d" % target.id, "text": target.display_name})
	actions.append({"id": "ai", "text": "←   Back"})
	return actions


# Predict follows up to 2 guards (1 degraded): pick them one by one.
static func predict_actions(state: BattleState, picks: Array[Unit]) -> Array:
	var actions := []
	for target in state.predict_targets():
		if not picks.has(target):
			actions.append({"id": "predict:%d" % target.id, "text": target.display_name})
	if not picks.is_empty():
		actions.append({"id": "predict:-1", "text": "Just %s" % picks[0].display_name})
	actions.append({"id": "ai", "text": "←   Back"})
	return actions
