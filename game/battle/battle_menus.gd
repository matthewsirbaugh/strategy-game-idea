class_name BattleMenus

# What the action menus offer, read from what the rules allow right now. Nothing here changes the
# battle. Each action is a dictionary:
#   id       what the battle controller acts on
#   text     the action's name
#   costs    [text, kind] tags drawn after the name, the AP cost last. Kinds: "ap" the Operator's
#            AP, "ai" the AI's AP, "context", "good" (what it gains), "free", "info", "key"
#   tip      one line on what it does, shown while it's highlighted
#   enabled  false greys it out; its tip says why
#   group    folds it into a submenu with the rest of its group (see nest)
#   submenu  it opens another menu
#   style    "back" or "end": a way out, drawn under the rest. "note": a line that isn't a choice
#   cancel   right-click or Esc picks it: the way back out of a submenu


# Returns the top-level actions and each folded group's actions, which end with a way back. A group
# of one stays inline.
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
			groups[group] = members[group] + [_back(back_id)]
			var usable: bool = members[group].any(func(entry: Dictionary) -> bool: return entry.get("enabled", true))
			var names: Array = members[group].map(func(entry: Dictionary) -> String: return entry.text)
			top.append({"id": "group:" + group, "text": group, "submenu": true, "enabled": usable, "tip": ", ".join(names)})
	return {"top": top, "groups": groups}


# A group's members are listed together, so the menu keeps its order whether a group folds or not.
# hand_over: the AI's half of the turn is still open, so ending this half moves over to it.
static func operator_actions(state: BattleState, unit: Unit, hand_over := false) -> Array:
	var actions := []
	if not state.move_costs(unit).is_empty():
		actions.append({"id": "move", "text": "Move", "costs": [["1 AP / tile", "ap"]],
			"tip": "Tiles that would get you noticed are amber; seen, red."})
	if not state.move_costs(unit, true).is_empty():
		actions.append({"id": "sprint", "text": "Sprint", "costs": [["%d tiles" % BattleState.SPRINT_TILES, "info"], ["%d AP" % BattleState.SPRINT_COST, "ap"]],
			"tip": "Gives up this turn's shot. Cut short, it costs what walking would have."})
	if not state.shot_targets(unit).is_empty():
		actions.append({"group": "Shoot", "id": "shoot", "text": "Shoot", "costs": [["Once a turn", "info"], ["Free", "free"]],
			"tip": "Range %d, with line of sight. A hit stuns an enemy for %d turns." % [unit.def.shot_range, BattleState.STUN_TURNS]})
	if state.can_shoot(unit):
		actions.append({"group": "Shoot", "id": "overwatch", "text": "Overwatch", "costs": [["Uses the shot", "info"]],
			"tip": "Fires at the first enemy that moves into your line of fire, until your next turn."})
	for option in state.door_options(unit):
		var locking: bool = option.action == "lock"
		actions.append({"group": "Interact", "id": "door:%s:%s" % [option.node, option.action], "text": "%s door %s" % [option.action.capitalize(), option.node.to_upper()],
			"costs": [["%d AP" % BattleState.LOCK_COST, "ap"] if locking else ["Free", "free"]], "tip": "Only an AI can unlock it again." if locking else ""})
	for id in state.peek_options(unit):
		actions.append({"group": "Interact", "id": "peek:" + id, "text": "Peek through %s" % id.to_upper(), "costs": [["%d AP" % BattleState.PEEK_COST, "ap"]],
			"tip": "See past the door until your turn ends."})
	for body in state.tie_targets(unit):
		actions.append({"group": "Interact", "id": "tie:%d" % body.id, "text": "Tie up %s" % body.display_name, "costs": [["%d AP" % BattleState.TIE_COST, "ap"]],
			"tip": "Out of the battle unless another guard finds and frees them."})
	for body in state.pickup_targets(unit):
		actions.append({"group": "Interact", "id": "pickup:%d" % body.id, "text": "Pick up %s" % body.display_name, "costs": [["Free", "free"]],
			"tip": "While carrying, you can only move."})
	if not state.putdown_cells(unit).is_empty():
		actions.append({"group": "Interact", "id": "putdown", "text": "Put down %s" % state.units[unit.carrying].display_name, "costs": [["Free", "free"]],
			"tip": "On a dumpster or in a trunk, the body is hidden inside."})
	if not state.flashbang_cells(unit).is_empty():
		actions.append({"group": "Gear", "id": "flashbang", "text": "Flashbang", "costs": [["%d left" % unit.flashbangs, "info"], ["%d AP" % BattleState.FLASHBANG_COST, "ap"]],
			"tip": "Thrown up to %d tiles; blinds the guards within %d for %d turns." % [BattleState.FLASHBANG_RANGE, BattleState.FLASHBANG_RADIUS, BattleState.BLIND_TURNS]})
	if not state.robot_cells(unit).is_empty():
		actions.append({"group": "Gear", "id": "robot", "text": "Deploy %s" % unit.robot_def.display_name.to_lower(), "costs": [["%d AP" % BattleState.ROBOT_COST, "ap"]],
			"tip": "It sets down beside you and acts from next round."})
	actions.append({"id": "ai", "text": "AI", "submenu": true,
		"tip": "Switch to the network, where the AI deploys and acts on its own AP."})
	for other in state.tied_operators():
		actions.append({"group": "Switch Operator", "id": "choose:%d" % other.id, "text": "Act with %s first" % other.display_name,
			"tip": "%s shares your speed. Hand them the turn before you act." % other.display_name})
	if hand_over:
		actions.append(_end_half("End Operator phase", "Over to the AI, which still has %d AP to spend." % unit.ai_ap))
	else:
		actions.append(_end())
	return actions


# The AI's own menu, in the network view. An AI still in the backpack is offered the access points it
# can go in at first. hand_over: the Operator's half of the turn is still open.
static func ai_actions(state: BattleState, unit: Unit, hand_over := false) -> Array:
	var actions := []
	var deploys := state.deploy_options(unit)
	for option in deploys:
		actions.append(_deploy_action(state, unit, option))
	if not unit.connected() and deploys.is_empty():
		actions.append({"id": "none", "style": "note", "text": _deploy_blocker(state, unit)})
	if unit.connected():
		if not state.network_destinations(unit).is_empty():
			var loading: bool = unit.chips[BattleState.MOVEMENT] == 0
			var costs := [["1 AI AP", "ai"]]
			if loading:
				costs.push_front(["+%dM" % state.chip_def(BattleState.MOVEMENT).load_cost, "context"])
			actions.append({"id": "ai_move", "text": "Move", "costs": costs,
				"tip": "Up to %d hops; hops out of Breached nodes are free.%s" % [BattleState.NETWORK_RANGE, " Loads the movement chip." if loading else ""]})
		if state.can_hack(unit):
			var id := unit.ai_node
			var power := state.hack_power(unit, id)
			var context := ["+%dM" % state.hack_context(unit, id), "context"]
			var left: int = state.node_def(id).goal - state.progress.get(id, 0)
			actions.append({"group": "Hack", "id": "hack:", "text": "Hack %s" % id.to_upper(), "costs": [["+%d" % power, "good"], context, ["1 AI AP", "ai"]],
				"tip": "%d to go. A one-action breach from untouched refunds the AP." % left})
			for linked in state.subagent_links(unit):
				var extra := state.subagent_points(unit, power)
				actions.append({"group": "Hack", "id": "hack:" + linked, "text": "Hack %s, subagent on %s" % [id.to_upper(), linked.to_upper()],
					"costs": [["+%d  +%d" % [power, extra], "good"], context, ["1 AI AP", "ai"]],
					"tip": "The subagent adds %d to %s for no extra context. One refund at most." % [extra, linked.to_upper()]})
	if state.can_compact(unit):
		actions.append({"id": "compact", "text": "Compact", "costs": [["%dM → %dM" % [unit.context, state.compacted(unit.context)], "context"], ["1 AI AP", "ai"]],
			"tip": "Keeps a quarter of the context. Every loaded chip degrades a step."})
	for id in state.load_options(unit):
		var chip := state.chip_def(id)
		actions.append({"group": "Chips", "id": "load:" + id, "text": "Load %s" % chip.display_name, "costs": [["+%dM" % chip.load_cost, "context"]], "tip": chip.effect})
	for id in unit.chips:
		var chip := state.chip_def(id)
		if chip.type != ChipDef.Type.ACTIVE or not unit.connected():
			continue
		var costs := [["1 AI AP", "ai"]]
		if unit.next_hack.has(id):
			costs.push_front(["Ready", "good"])
		elif unit.chips[id] == 0:
			costs.push_front(["+%dM" % chip.load_cost, "context"])
		var ready := state.chip_ready(unit, id)
		actions.append({"group": "Chips", "id": "chip:" + id, "text": chip.display_name, "costs": costs, "enabled": ready,
			"tip": chip.effect if ready else _chip_blocker(state, unit, id)})
	for id in controlled_devices(state, unit):
		var controls := device_actions(state, unit, id)
		controls.pop_back()
		var orders := ", ".join(controls.map(func(action: Dictionary) -> String: return action.text.to_lower()))
		actions.append({"group": "Devices", "id": "device:" + id, "text": "%s %s" % [state.node_def(id).display_name, id.to_upper()], "submenu": true,
			"enabled": controls.any(func(action: Dictionary) -> bool: return action.enabled), "tip": orders.left(1).to_upper() + orders.substr(1) + "."})
	for other in state.share_targets(unit):
		actions.append({"id": "share:%d" % other.id, "text": "Give %s's AI 1 AP" % other.display_name, "costs": [["1 AI AP", "ai"]],
			"tip": "Shared compute: it arrives on their next turn, and lapses if unused."})
	if actions.is_empty():
		var spent := "The AI's AP is spent for this turn." if unit.ai_ap <= 0 else "Nothing the AI can do from here."
		actions.append({"id": "none", "style": "note", "text": spent})
	actions.append({"id": "physical", "text": "Operator", "style": "back", "costs": [["N", "key"]],
		"tip": "Switch to the physical view without ending the AI's half of the turn."})
	if hand_over:
		actions.append(_end_half("End AI phase", "Back to %s, who still has %d AP to spend." % [unit.display_name, unit.ap]))
	else:
		actions.append(_end())
	return actions


# The Breached devices the AI can give orders to, each once.
static func controlled_devices(state: BattleState, unit: Unit) -> Array[String]:
	var ids: Array[String] = []
	for option in state.verb_options(unit):
		if not ids.has(option.node):
			ids.append(option.node)
	for id in state.turret_controls(unit):
		if not ids.has(id):
			ids.append(id)
	return ids


# One device's orders. The header names the device, so each row is just the order.
static func device_actions(state: BattleState, unit: Unit, id: String, back := "ai") -> Array:
	var actions := []
	for option in state.verb_options(unit):
		if option.node == id:
			actions.append(_verb_action(state, unit, option))
	if state.turret_controls(unit).has(id):
		var mode := "hold" if state.devices[id].mode == "target" else "target"
		actions.append({"id": "turret:%s:%s" % [id, mode], "text": "Hold fire" if mode == "hold" else "Target enemies", "costs": [["Free", "free"]],
			"enabled": true, "tip": "It picks the nearest enemy itself; you only say whether it fires."})
	actions.append(_back(back))
	return actions


static func robot_actions(state: BattleState, unit: Unit) -> Array:
	var actions := []
	if not state.move_costs(unit).is_empty():
		actions.append({"id": "move", "text": "Move", "costs": [["1 AP / tile", "ap"]], "tip": "Robots can't sprint, open doors or carry bodies."})
	if not state.dog_stun_targets(unit).is_empty():
		actions.append({"id": "dog_stun", "text": "Stun", "costs": [["Once a battle", "info"], ["%d AP" % BattleState.DOG_STUN_COST, "ap"]],
			"tip": "Stuns an adjacent enemy for %d turns." % BattleState.STUN_TURNS})
	actions.append(_end())
	return actions


static func locate_actions(state: BattleState) -> Array:
	var actions := []
	for target in state.locate_targets():
		actions.append({"id": "locate:%d" % target.id, "text": target.display_name, "tip": "Shows where they are, live, for their next turns."})
	actions.append(_back("ai"))
	return actions


# Predict follows up to 2 guards (1 degraded): pick them one by one.
static func predict_actions(state: BattleState, picks: Array[Unit]) -> Array:
	var actions := []
	for target in state.predict_targets():
		if not picks.has(target):
			actions.append({"id": "predict:%d" % target.id, "text": target.display_name, "tip": "Shows their next turn: the path, and where they'd aim."})
	if not picks.is_empty():
		actions.append({"id": "predict:-1", "text": "Just %s" % picks[0].display_name})
	actions.append(_back("ai"))
	return actions


# Whether one half of an Operator's turn still has AP and something to spend it on. If it does,
# ending the other half moves over to it instead of ending the turn.
static func half_open(state: BattleState, unit: Unit, ai: bool) -> bool:
	if ai:
		return unit.ai_ap > 0 and _spends(ai_actions(state, unit), ["ai", "ap"])
	return unit.ap > 0 and _spends(operator_actions(state, unit), ["ap"])


static func _spends(actions: Array, kinds: Array) -> bool:
	return actions.any(func(action: Dictionary) -> bool:
		return action.get("enabled", true) and action.get("costs", []).any(func(cost: Array) -> bool: return cost[1] in kinds))


# What a menu's header shows the unit has to spend.
static func budget(unit: Unit, ai: bool) -> Array:
	var remaining := [["%d AP remaining" % unit.ap, "ap"]]
	if ai and unit.is_operator():
		remaining.append_array([["%d AI AP remaining" % unit.ai_ap, "ai"], ["%dM" % unit.context, "context"]])
	return remaining


static func _back(id: String) -> Dictionary:
	return {"id": id, "text": "Back", "style": "back", "cancel": true, "costs": [["Esc", "key"]]}


static func _end() -> Dictionary:
	return {"id": "end", "text": "End turn", "style": "end", "costs": [["Space", "key"]], "tip": "Unspent AP doesn't carry over."}


static func _end_half(text: String, tip: String) -> Dictionary:
	return {"id": "end_half", "text": text, "style": "end", "costs": [["Space", "key"]], "tip": tip}


static func _deploy_action(state: BattleState, unit: Unit, option: Dictionary) -> Dictionary:
	var source: Unit = unit if option.relay < 0 else state.units[option.relay]
	var via: String = "" if option.relay < 0 else " via the " + source.def.display_name.to_lower()
	return {"id": "deploy:%s:%d" % [option.access, option.relay], "text": "Deploy at %s%s" % [option.access.to_upper(), via], "costs": [["%d AP" % BattleState.DEPLOY_AI_COST, "ap"]],
		"tip": "The AI goes into the network here. It stays in while %s stays within %d tiles." % [source.display_name, BattleState.TETHER]}


# Why a backpacked AI can't go in yet.
static func _deploy_blocker(state: BattleState, unit: Unit) -> String:
	if unit.rebooting > 0:
		return "The AI is rebooting this turn."
	if unit.carrying >= 0:
		return "Put the body down to deploy the AI."
	if unit.ap < BattleState.DEPLOY_AI_COST:
		return "Deploying takes %d of %s's AP." % [BattleState.DEPLOY_AI_COST, unit.display_name]
	return "Get within %d tiles of an access point to deploy." % BattleState.TETHER


static func _chip_blocker(state: BattleState, unit: Unit, id: String) -> String:
	if unit.ai_ap < 1:
		return "Needs 1 AI AP."
	if unit.next_hack.has(id):
		return "Already waiting for the next hack."
	match id:
		BattleState.LOCATE:
			return "Every enemy is already in sight."
		BattleState.PREDICT:
			return "No guard in sight to predict."
	return ""


static func _verb_id(option: Dictionary) -> String:
	return "verb:%s:%s:%d" % [option.node, option.verb, option.direction]


static func _verb_action(state: BattleState, unit: Unit, option: Dictionary) -> Dictionary:
	var id: String = option.node
	var device: Dictionary = state.devices[id]
	var what := ""
	match option.verb:
		"power":
			what = "power off" if device.powered else "power on"
		"lock":
			what = "unlock" if device.locked else "lock"
		"activate":
			match state.map.node_kind(id):
				"autodoor":
					what = "close" if device.open else "open"
				"phone":
					what = "ring"
				"adscreen":
					what = "flash"
				_:
					what = "drive forward" if option.direction == 1 else "drive backward"
	return {"id": _verb_id(option), "text": what.left(1).to_upper() + what.substr(1), "costs": [["+%dM" % BattleState.VERB_CONTEXT, "context"]], "enabled": option.enabled,
		"tip": _verb_effect(state, id, option.verb, device) if option.enabled else _verb_blocker(state, unit, option)}


# What using a verb will set off: a sound and who it draws, a visual lure, or nothing at all.
static func _verb_effect(state: BattleState, id: String, verb: String, device: Dictionary) -> String:
	var def := state.node_def(id)
	var kind := state.map.node_kind(id)
	var switching_on: bool = verb == "power" and not device.powered
	if (verb == "activate" or switching_on) and def.sound_radius > 0 and verb not in def.silent_verbs:
		return "A sound carries %d steps and draws %s." % [def.sound_radius, "every guard in range" if def.sound_all else "the closest guard"]
	if verb == "power" and device.powered and (kind == "light" or kind in NodeDef.CAMERAS or kind == "hub"):
		return "Going dark draws a guard to look." if kind != "hub" else "Its circuit goes dark; each light and camera is a lure."
	if verb == "activate" and kind == "adscreen":
		return "Draws the closest guard who can see the screen."
	return "Silent."


static func _verb_blocker(state: BattleState, unit: Unit, option: Dictionary) -> String:
	var id: String = option.node
	var device: Dictionary = state.devices[id]
	if unit.verb_uses.has(id + ":" + option.verb):
		return "Already used this turn."
	match option.verb:
		"power":
			return "Its power hub is off."
		"activate":
			if not device.powered:
				return "Needs power first."
			if device.locked:
				return "Unlock it first."
			return "Something is in the way."
		"lock":
			return "Close it first."
	return ""
