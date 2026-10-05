class_name BattleLog

# What the log says about each event the rules return, told from the player's side of the fog: an
# enemy the team can't see is "Someone", and some of its events go unmentioned. Read after the
# event has played, so it describes the state as it is now.


static func lines(state: BattleState, event: Dictionary) -> Array[String]:
	var unit: Unit = event.get("unit")
	match event.type:
		"blocked":
			if state.player_sees(unit) or unit.is_player():
				return ["%s ran into %s!" % [unit.display_name, event.by.display_name]]
		"revealed":
			return ["%s spots %s and stops" % [unit.display_name, ", ".join(event.enemies.map(func(enemy: Unit) -> String: return enemy.display_name))]]
		"alert":
			return ["%s sees %s! Full alert" % [_who(state, unit), event.target.display_name]]
		"notice":
			if state.player_sees(unit):
				return ["%s noticed something" % unit.display_name]
		"camera_report":
			return [_responders(state, "Camera %s spotted something" % event.node.to_upper(), event.responders)]
		"sound":
			return [_responders(state, "A sound carries %d step%s" % [event.radius, "" if event.radius == 1 else "s"], event.responders)]
		"lure":
			return [_responders(state, "%s %s draws attention" % [state.node_def(event.node).display_name, event.node.to_upper()], event.responders)]
		"found_body":
			return ["%s found %s! Full alert" % [_who(state, unit), event.body.display_name]]
		"aim":
			return ["%s aims at %s" % [_who(state, unit), event.target.display_name]]
		"aim_lapsed":
			if state.player_sees(unit):
				return ["%s lost the shot" % unit.display_name]
		"overwatch":
			return ["%s fires from overwatch!" % unit.display_name]
		"hit":
			return [_hit(state, event)]
		"dog_stun":
			return ["%s stuns %s" % [unit.display_name, event.target.display_name]]
		"stunned":
			if state.player_sees(unit):
				return ["%s is out cold%s" % [unit.display_name, "" if event.turns == 0 else ", %d more turns" % event.turns]]
		"blinded":
			if state.player_sees(unit):
				return ["%s is still blinded" % unit.display_name]
		"wake":
			return ["Someone is banging inside a receptacle" if event.hidden else "%s wakes up, alerted" % _who(state, unit)]
		"free":
			return ["%s frees %s" % [_who(state, unit), event.target.display_name]]
		"searching":
			if state.player_sees(unit):
				return ["%s lost track and searches" % unit.display_name]
		"gave_up":
			if state.player_sees(unit):
				return ["%s goes back to its post" % unit.display_name]
		"tie":
			return ["%s ties up %s" % [unit.display_name, event.target.display_name]]
		"pick_up":
			return ["%s picks up %s" % [unit.display_name, event.target.display_name]]
		"put_down":
			return ["%s puts %s down%s" % [unit.display_name, event.target.display_name, ", hidden" if event.hidden else ""]]
		"flashbang":
			return ["Flashbang: %d blinded" % event.blinded.size()]
		"deploy_robot":
			return ["%s deploys the %s. It acts from next round" % [unit.display_name, event.robot.def.display_name.to_lower()]]
		"connect":
			return ["%s's AI connects at %s%s" % [unit.display_name, event.node.to_upper(), ", revealing the %s network" % event.network if event.revealed else ""]]
		"disconnect":
			return ["%s's AI is pulled out, its context kept" % unit.display_name]
		"agent_move":
			if event.loaded:
				return ["%s's AI loads the movement chip" % unit.display_name]
		"hack":
			var extra := "" if event.linked == "" else ", +%d on %s" % [event.linked_points, event.linked.to_upper()]
			return ["%s's AI hacks %s: +%d%s%s" % [unit.display_name, event.node.to_upper(), event.points, extra, ". Refund!" if event.refund else ""]]
		"breach":
			var result: Array[String] = ["%s %s breached" % [state.node_def(event.node).display_name, event.node.to_upper()]]
			if event.node == state.objective:
				result.append("Data secured. Get everyone to extraction!")
			return result
		"compact":
			return ["%s's AI compacts: %dM to %dM%s" % [unit.display_name, event.before, unit.context, ", chips degraded" if not event.degraded.is_empty() else ""]]
		"chip":
			var chip := state.chip_def(event.chip)
			return ["%s's AI %s %s%s" % [unit.display_name, "uses" if event.used else "loads", chip.display_name,
				" on " + ", ".join(event.targets.map(func(target: Unit) -> String: return target.display_name)) if not event.targets.is_empty() else ""]]
		"verb":
			return ["%s %s %s" % [state.node_def(event.node).display_name, event.node.to_upper(), _verb_result(state, event)]]
		"vehicle":
			if event.struck:
				return ["The %s hits %s!" % [state.node_def(event.node).display_name.to_lower(), event.struck.display_name]]
		"door":
			return ["%s: door %s %s" % [unit.display_name, event.node.to_upper(), {"open": "opened", "close": "closed", "lock": "locked"}[event.action]]]
		"peek":
			return ["%s peeks through %s" % [unit.display_name, event.node.to_upper()]]
		"share":
			return ["%s's AI gives 1 AP to %s's, for their next turn" % [unit.display_name, event.target.display_name]]
		"turret_mode":
			return ["Turret %s: %s" % [event.node.to_upper(), "targeting enemies" if event.mode == "target" else "holding fire"]]
		"overwatch_set":
			return ["%s sets overwatch" % unit.display_name]
		"crash":
			return ["%s's AI crashed" % unit.display_name]
	return []


static func _hit(state: BattleState, event: Dictionary) -> String:
	var target: Unit = event.target
	match event.result:
		"stunned":
			var by: String = _who(state, event.unit) if event.unit else "Something"
			return "%s stuns %s for %d turns" % [by, target.display_name, BattleState.STUN_TURNS]
		"downed":
			return "%s is down" % target.display_name
	return "%s takes a hit: %d left" % [target.display_name, event.left]


# What a verb did, read from the device afterwards.
static func _verb_result(state: BattleState, event: Dictionary) -> String:
	var device: Dictionary = state.devices[event.node]
	match event.verb:
		"power":
			return "powered on" if device.powered else "powered off"
		"lock":
			return "locked" if device.locked else "unlocked"
	match state.map.node_kind(event.node):
		"autodoor":
			return "opens" if device.open else "closes"
		"phone":
			return "rings"
		"adscreen":
			return "flashes"
	return "drives"


static func _who(state: BattleState, unit: Unit) -> String:
	return unit.display_name if state.player_sees(unit) else "Someone"


static func _responders(state: BattleState, what: String, responders: Array) -> String:
	var seen := responders.filter(func(guard: Unit) -> bool: return state.player_sees(guard))
	if seen.is_empty():
		return what
	return "%s: %s goes to check" % [what, ", ".join(seen.map(func(guard: Unit) -> String: return guard.display_name))]
