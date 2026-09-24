class_name UnitDef
extends Resource

enum Team { PLAYER, ENEMY }
enum Kind { OPERATOR, GUARD, TURRET }

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
