extends Node

const PATH := "user://settings.cfg"

var master_volume: float = 1.0
var fullscreen: bool = false
var vsync: bool = true


func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) == OK:
		master_volume = cfg.get_value("audio", "master_volume", master_volume)
		fullscreen = cfg.get_value("display", "fullscreen", fullscreen)
		vsync = cfg.get_value("display", "vsync", vsync)
	apply()


func apply() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	)
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
	)


func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master_volume", master_volume)
	cfg.set_value("display", "fullscreen", fullscreen)
	cfg.set_value("display", "vsync", vsync)
	cfg.save(PATH)
