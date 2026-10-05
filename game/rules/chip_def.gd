class_name ChipDef
extends Resource

# Movement is passive and free; passive chips work once loaded; active chips cost 1 AP a use.
enum Type { MOVEMENT, PASSIVE, ACTIVE }

@export var id := ""
@export var display_name := ""
@export var type := Type.ACTIVE
@export var load_cost := 10
# Exploits only: the node category they multiply hack power against.
@export var category := ""
# The chip's number at full strength and degraded: a multiplier, a duration in turns, a count of
# guards, or the share of progress a subagent adds.
@export var strength := 2.0
@export var degraded_strength := 1.5
@export_multiline var effect := ""
@export_multiline var degraded_effect := ""
