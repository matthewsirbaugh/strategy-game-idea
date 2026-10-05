extends Node

const TITLE := "res://ui/title_menu.tscn"
const LOADOUT := "res://ui/loadout_menu.tscn"
const BATTLE := "res://battle/battle.tscn"

# The battle being set up or played: its map, content, loadouts and what carries into the phase.
# Restarting the phase builds it again from this.
var session: BattleSession


func goto_title() -> void:
	_go(TITLE)


func goto_loadout() -> void:
	_go(LOADOUT)


func goto_battle(next: BattleSession = null) -> void:
	if next:
		session = next
	_go(BATTLE)


func restart_battle() -> void:
	_go(BATTLE)


func _go(path: String) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
