class_name VisionTick
extends RefCounted

var cells: Dictionary
var lit: Dictionary
var shown := {}
var known: Dictionary


static func capture(state: BattleState) -> VisionTick:
	var tick := VisionTick.new()
	tick.cells = state.visible_cells.duplicate()
	tick.lit = state.lit.duplicate()
	tick.known = state.known.duplicate()
	for unit in state.units:
		if not unit.is_player() and (state.player_sees(unit) or (unit.down and state.visible_cells.has(unit.cell))):
			tick.shown[unit.id] = unit.cell
	return tick
