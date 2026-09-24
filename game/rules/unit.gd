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
var route: Array[Vector2i] = []
var route_index := 0
var alerted := false


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
