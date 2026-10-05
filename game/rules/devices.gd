class_name Devices

# What a Breached device's verbs do: power, activate and lock, the circuits power hubs feed, and
# vehicles that drive until they hit something. BattleState checks who may use a verb; this does it.


static func can_use(state: BattleState, unit: Unit, id: String, verb: String, direction := 1) -> bool:
	var def := state.node_def(id)
	var device: Dictionary = state.devices[id]
	if not unit.connected() or not state.breached.has(id) or verb not in def.verbs \
			or state.map.network_of(id) != state.map.network_of(unit.ai_node) or unit.verb_uses.has(id + ":" + verb):
		return false
	match verb:
		"power":
			return device.powered or not hub_cut(state, id)
		"activate":
			if not device.powered:
				return false
			match def.kind:
				"autodoor":
					return not device.locked and (not device.open or state.unit_at(device.cell) == null)
				"car", "truck":
					var drive := vehicle_path(state, id, direction)
					return not drive.path.is_empty() or drive.struck != null
			return true
		"lock":
			return device.locked or not device.open
	return false


# A device on a circuit whose hub is off can't be powered on by itself.
static func hub_cut(state: BattleState, id: String) -> bool:
	var hub := state.map.hub_of(id)
	return hub != "" and not state.devices[hub].powered


static func use(state: BattleState, unit: Unit, id: String, verb: String, direction := 1) -> Array[Dictionary]:
	var def := state.node_def(id)
	var device: Dictionary = state.devices[id]
	unit.verb_uses[id + ":" + verb] = true
	state.add_context(unit, BattleState.VERB_CONTEXT)
	var events: Array[Dictionary] = []
	var lures: Array[String] = []
	match verb:
		"power":
			device.powered = not device.powered
			if def.kind == "hub":
				for member in state.map.circuit(id):
					if state.devices[member].powered != device.powered:
						state.devices[member].powered = device.powered
						if not device.powered:
							lures.append(member)
			elif not device.powered:
				lures.append(id)
		"activate":
			match def.kind:
				"autodoor":
					device.open = not device.open
				"adscreen":
					lures.append(id)
				"car", "truck":
					events.append(_drive(state, id, direction))
		"lock":
			device.locked = not device.locked
	events.push_front({"type": "verb", "unit": unit, "node": id, "verb": verb})
	state.refresh()
	# Switching on and activating make the device's sound. Switching off and locking are silent.
	var makes_sound: bool = verb == "activate" or (verb == "power" and device.powered)
	if def.sound_radius > 0 and makes_sound and verb not in def.silent_verbs:
		events.append(sound(state, id, state.node_cell(id), def.sound_radius, def.sound_all))
	for lure_id in lures:
		var lure := _lure(state, lure_id, verb == "activate")
		if not lure.is_empty():
			events.append(lure)
	events.append_array(Perception.sweep(state))
	return events


static func sound(state: BattleState, source: String, cell: Vector2i, radius: int, everyone: bool) -> Dictionary:
	var responders := Perception.responders_to(state, cell, radius, everyone)
	for guard in responders:
		Perception.investigate(state, guard, cell)
	return {"type": "sound", "unit": null, "node": source, "cell": cell, "radius": radius,
		"cells": Perception.sound_reach(state, cell, radius).keys(), "responders": responders}


# A light or camera going dark, or an ad screen flashing. Lights and screens draw the closest guard
# who can see them; a camera's feed going dark draws the closest guard wherever it is.
static func _lure(state: BattleState, id: String, flash: bool) -> Dictionary:
	var kind := state.map.node_kind(id)
	if not flash and kind != "light" and kind not in NodeDef.CAMERAS:
		return {}
	var cell := state.node_cell(id)
	var responders := Perception.responders_to(state, cell, 999, false, kind not in NodeDef.CAMERAS)
	for guard in responders:
		Perception.investigate(state, guard, cell)
	return {"type": "lure", "unit": null, "node": id, "cell": cell, "responders": responders}


# Where a vehicle would drive: straight along its facing (or backwards) until the next tile is
# blocked. A guard in the way is the thing it hits, and is stunned.
static func vehicle_path(state: BattleState, id: String, direction: int) -> Dictionary:
	var step: Vector2i = state.devices[id].facing * direction
	var cell := state.node_cell(id)
	var path: Array[Vector2i] = []
	var struck: Unit = null
	while true:
		var next := cell + step
		if state.blocks_walk(next):
			break
		var other := state.unit_at(next)
		if other:
			if other.is_guard() and other.team == UnitDef.Team.ENEMY and not other.is_body():
				struck = other
			break
		cell = next
		path.append(cell)
	return {"path": path, "struck": struck}


static func _drive(state: BattleState, id: String, direction: int) -> Dictionary:
	var drive := vehicle_path(state, id, direction)
	var path: Array[Vector2i] = drive.path
	if not path.is_empty():
		state.move_node(id, path.back())
	if drive.struck:
		state.stun(drive.struck)
	return {"type": "vehicle", "unit": null, "node": id, "path": path, "struck": drive.struck}
