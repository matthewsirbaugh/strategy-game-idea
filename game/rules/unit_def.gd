class_name UnitDef
extends Resource

enum Team { PLAYER, ENEMY }
enum Kind { OPERATOR, GUARD, TURRET, ROBOT }

@export var display_name := ""
@export var team := Team.PLAYER
@export var kind := Kind.OPERATOR
@export var speed := 5
# Operators and robots: action points each turn.
@export var ap := 0
# Guards: tiles a turn, with no AP.
@export var move := 0
# Operators and robots: how far they see in light, in every direction.
@export var sight := 0
# Guards and turrets: the cone's two tiers. A guard's range is its seen tier.
@export var seen_range := 0
@export var noticed_range := 0
@export var shot_range := 0
# A drone flies over low obstacles, and sees over them.
@export var flies := false
# The dog bot's single-use stun.
@export var stun_charges := 0
@export var color := Color.WHITE

# Paths rather than loaded scenes, so the rules and their tests never load art.
@export_group("Art")
@export_file("*.glb") var model := ""
# Operators only: the compute pack hung on the model's back.
@export_file("*.glb") var pack := ""
