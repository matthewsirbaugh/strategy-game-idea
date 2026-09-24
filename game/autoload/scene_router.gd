extends Node

const TITLE := "res://ui/title_menu.tscn"
const BATTLE := "res://battle/battle.tscn"


func goto_title() -> void:
	_go(TITLE)


func goto_battle() -> void:
	_go(BATTLE)


func _go(path: String) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(path)
