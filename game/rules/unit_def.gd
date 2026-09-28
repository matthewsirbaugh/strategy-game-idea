class_name UnitDef
extends Resource

enum Team { PLAYER, ENEMY }
enum Kind { OPERATOR, GUARD, TURRET }
enum Ability { NONE, PROBE, LOCATE, CLOAK }

@export var display_name := ""
@export var team := Team.PLAYER
@export var kind := Kind.OPERATOR
@export var max_hp := 10
@export var move := 4
@export var damage := 3
@export var attack_range := 1
@export var speed := 5
@export var sight := 5
@export var color := Color.WHITE

# Paths rather than loaded scenes, so the rules and their tests never load art.
@export_group("Art")
@export_file("*.glb") var model := ""
# Operators only: the compute pack hung on the model's back.
@export_file("*.glb") var pack := ""

@export_group("Agent")
@export var hack_power := 10
@export var network_range := 3
@export var tether_range := 2

@export_group("Ability")
@export var ability := Ability.NONE
# Uses per battle, or -1 for unlimited.
@export var ability_uses := -1
# Rounds before it can be used again.
@export var ability_cooldown := 0
# Rounds it lasts, for effects that wear off.
@export var ability_duration := 0
@export var ability_radius := 0
