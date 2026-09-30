class_name NodeDef
extends Resource

const KINDS := ["access", "door", "camera", "turret", "cache"]

@export var kind := ""
@export var display_name := ""
@export var goal := 0
@export var context_cost := 0
@export var vision_radius := 0
