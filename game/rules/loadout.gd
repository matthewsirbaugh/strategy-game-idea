class_name Loadout
extends Resource

enum Armor { NONE, BASIC, HEAVY }
enum Gear { DRONE, DOG_BOT, FLASHBANGS }

const MAX_CHIPS := 3
const HITS := [1, 2, 3]
const ARMOR_NAMES := ["None", "Basic", "Heavy"]
const GEAR_NAMES := ["Drone", "Dog bot", "Two flashbangs"]
const FLASHBANGS := 2
const HEAVY_AP_COST := 1

@export var armor := Armor.NONE
@export var gear := Gear.FLASHBANGS
# Chip ids, at most MAX_CHIPS. The movement chip comes free on top.
@export var chips := PackedStringArray()
@export var role := ""
