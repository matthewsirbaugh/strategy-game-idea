class_name BattleContent
extends Resource

# Every definition a battle draws on, in one place to tune: the team, the enemy, the robots, the
# devices and the chips.
@export var operators: Array[UnitDef] = []
# The V1 loadouts, one per Operator, that the loadout screen starts from.
@export var loadouts: Array[Loadout] = []
@export var guard: UnitDef
@export var turret: UnitDef
@export var drone: UnitDef
@export var dog_bot: UnitDef
@export var node_defs: Array[NodeDef] = []
@export var chips: Array[ChipDef] = []
