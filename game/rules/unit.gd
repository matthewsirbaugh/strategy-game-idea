class_name Unit
extends RefCounted

var id: int
var def: UnitDef
var display_name: String
var cell: Vector2i
var hp: int
var moved := false
var acted := false
var move_origin: Vector2i
# This turn's move uncovered an enemy, so undoing it would un-learn information.
var revealed := false
var route: Array[Vector2i] = []
var route_index := 0
var alerted := false
var searching := false
var has_lead := false
var lead: Vector2i
var disabled := false
# The AI half. agent_node is where it sits in the network ("" when disconnected), entry is the
# access point it plugged in through, which the human has to stay near.
var agent_node := ""
var entry := ""
var context := 0
var agent_origin := ""
var entry_origin := ""


func _init(p_id: int, p_def: UnitDef, p_name: String, p_cell: Vector2i) -> void:
	id = p_id
	def = p_def
	display_name = p_name
	cell = p_cell
	hp = p_def.max_hp


func is_player() -> bool:
	return def.team == UnitDef.Team.PLAYER


func is_down() -> bool:
	return hp <= 0


func is_enemy_of(other: Unit) -> bool:
	return def.team != other.def.team
