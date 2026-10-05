class_name Unit
extends RefCounted

# What a unit is doing and has, as it changes during a battle. Definitions stay in UnitDef. Units
# refer to each other by id, so a copy of the whole battle (Predict, previews) shares nothing.

enum Task { PATROL, INVESTIGATE, ALERTED, SEARCHING }

var id: int
var def: UnitDef
var display_name: String
var cell: Vector2i
# Ownership changes when the team breaches something autonomous, like a turret.
var team: UnitDef.Team
var facing := Vector2(0, 1)
# The node of something autonomous the team can breach, like a turret.
var node := ""
var down := false
var located := 0

# Operators and robots.
var ap := 0
var spent := false
# Operators.
var base_ap := 0
var hits := 0
var max_hits := 1
var shot_used := false
var sprinted := false
var overwatch := false
var peeks: Array[String] = []
var carrying := -1
var flashbangs := 0
var robot_def: UnitDef
var robot := -1
var role := ""

# The AI, in its Operator's backpack. ai_node is where it is in the network ("" when not
# connected), entry the access point it came in through, relay the robot it connects through.
var ai_node := ""
var entry := ""
var relay := -1
var context := 0
# Every chip the AI carries, by id, at its level: 2 loaded, 1 degraded, 0 not loaded.
var chips := {}
var ai_ap := 0
# Donated compute waiting for this AI's next turn.
var incoming := 0
var verb_uses := {}
# "Next hack" chips activated this turn, by id.
var next_hack := {}
# Crashed: turn ends left until the AI is back. It sits out its whole next turn, even if the
# player hands that turn to a tied Operator and takes it up again.
var rebooting := 0

# Robots.
var stun_charges := 0

# Guards and turrets.
var route: Array[Vector2i] = []
var route_index := 0
var task := Task.PATROL
var target := -1
var lead := Vector2i.ZERO
var look := 0
var search := 0
var freeing := -1
var aim := {}
var stun := 0
var blind := 0
var tied := false
var carried_by := -1
var receptacle := ""
# Units already in this guard's or camera's view, so a sighting only counts when it starts.
var in_view := {}
# A turret's own facing, which it returns to after an alert.
var rest_facing := Vector2(0, 1)
# Breached turrets that have shot this turret, which it treats as hostile.
var hostile := {}


func _init(p_id: int, p_def: UnitDef, p_name: String, p_cell: Vector2i) -> void:
	id = p_id
	def = p_def
	display_name = p_name
	cell = p_cell
	if p_def:
		team = p_def.team


func copy() -> Unit:
	var other := Unit.new(id, def, display_name, cell)
	for property in get_property_list():
		if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var value: Variant = get(property.name)
			if value is Dictionary or value is Array:
				value = value.duplicate(true)
			other.set(property.name, value)
	return other


func is_player() -> bool:
	return team == UnitDef.Team.PLAYER


func is_enemy_of(other: Unit) -> bool:
	return team != other.team


func is_operator() -> bool:
	return def.kind == UnitDef.Kind.OPERATOR


func is_guard() -> bool:
	return def.kind == UnitDef.Kind.GUARD


func is_turret() -> bool:
	return def.kind == UnitDef.Kind.TURRET


func is_robot() -> bool:
	return def.kind == UnitDef.Kind.ROBOT


# A stunned or tied-up enemy.
func is_body() -> bool:
	return stun > 0 or tied


# Out of play for now: down, a body, or carried. Such a unit sees nothing and acts on nothing.
func is_out() -> bool:
	return down or is_body() or carried_by >= 0


func on_map() -> bool:
	return not down and carried_by < 0 and receptacle == ""


func connected() -> bool:
	return ai_node != ""
