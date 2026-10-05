class_name NodeDef
extends Resource

const KINDS := ["access", "door", "autodoor", "camera", "nvcamera", "turret", "cache", "light", "phone",
	"machine", "adscreen", "car", "truck", "hub"]
const VERBS := ["power", "activate", "lock"]

@export var kind := ""
@export var display_name := ""
@export var goal := 0
# Context each hack on this node adds.
@export var context_cost := 0
# Which exploit chip multiplies hacks on it: surveillance, weapons or infrastructure.
@export var category := ""
# What the AI can do with it once Breached, from VERBS.
@export var verbs := PackedStringArray()
# Walking steps the sound of a verb carries, and whether it draws every guard in range or only
# the closest.
@export var sound_radius := 0
@export var sound_all := false
@export var silent_verbs := PackedStringArray()
@export var light_radius := 0
# Cameras: the cone's two tiers, and whether it sees in the dark.
@export var seen_range := 0
@export var noticed_range := 0
@export var sees_dark := false
@export var starts_powered := false
