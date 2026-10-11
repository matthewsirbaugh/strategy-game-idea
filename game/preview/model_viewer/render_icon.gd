extends SceneTree

func _init() -> void:
	var image := Image.new()
	image.load_svg_from_string(FileAccess.get_file_as_string("res://icon.svg"), 2.0)
	image.save_png(ProjectSettings.globalize_path("res://build/icon.png"))
	quit()
