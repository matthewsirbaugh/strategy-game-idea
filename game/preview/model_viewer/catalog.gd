extends RefCounted

const REQUIRED := {
	"spec": TYPE_FLOAT, "id": TYPE_STRING, "name": TYPE_STRING,
	"category": TYPE_STRING, "status": TYPE_STRING, "model": TYPE_STRING,
	"height_m": TYPE_FLOAT, "fit_to_height": TYPE_BOOL, "description": TYPE_STRING,
	"animations": TYPE_ARRAY, "notes": TYPE_STRING,
}
const NULLABLE := {"device": TYPE_STRING, "brief": TYPE_STRING, "sources": TYPE_STRING, "made_with": TYPE_DICTIONARY}
const CATEGORIES := ["architecture", "devices", "props", "nature", "units"]
const STATUSES := ["legacy", "proof", "approved", "rejected"]
var assets: Array[Dictionary] = []
var issues: PackedStringArray = []
var folders: PackedStringArray = []
var root := ""

func scan(path: String) -> void:
	root = path.simplify_path().trim_suffix("/")
	assets.clear()
	issues.clear()
	folders.clear()
	if not DirAccess.dir_exists_absolute(root):
		issues.append("Asset folder unavailable: " + root)
		return
	_walk(root, {})
	if OS.get_name() == "macOS" and not assets.is_empty():
		var args := PackedStringArray(["-f", "%B"])
		for asset in assets:
			args.append(asset._path)
		var output: Array = []
		if OS.execute("/usr/bin/stat", args, output) == 0:
			var times: PackedStringArray = str(output[0]).strip_edges().split("\n")
			if times.size() == assets.size():
				for i in assets.size():
					if times[i].is_valid_int() and int(times[i]) > 0:
						assets[i]._added = int(times[i])
	folders.sort()

func _walk(path: String, ids: Dictionary) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		issues.append("Cannot read folder: " + path.trim_prefix(root + "/"))
		return
	if path != root:
		folders.append(path.trim_prefix(root + "/"))
	var record := path.path_join(path.get_file() + ".json")
	if FileAccess.file_exists(record):
		var parser := JSON.new()
		var error := parser.parse(FileAccess.get_file_as_string(record))
		var reason := ""
		if error != OK:
			reason = "Invalid JSON at line %d: %s" % [parser.get_error_line(), parser.get_error_message()]
		elif not parser.data is Dictionary:
			reason = "Record must be an object"
		else:
			reason = _validate(parser.data, path, ids)
		if not reason.is_empty():
			issues.append("%s — %s" % [record.trim_prefix(root + "/"), reason])
		else:
			var asset: Dictionary = parser.data
			ids[asset.id] = record
			asset["_record"] = record
			asset["_folder"] = path.trim_prefix(root + "/")
			asset["_path"] = path.path_join(asset.model)
			asset["_added"] = FileAccess.get_modified_time(asset._path)
			asset["_modified"] = FileAccess.get_modified_time(asset._path)
			assets.append(asset)
	for folder in dir.get_directories():
		if not folder.begins_with(".") and not dir.is_link(path.path_join(folder)):
			_walk(path.path_join(folder), ids)

func _validate(record: Dictionary, path: String, ids: Dictionary) -> String:
	for field in REQUIRED:
		if not record.has(field):
			return "Missing field: " + field
		if typeof(record[field]) != REQUIRED[field]:
			return "Wrong type for " + field
	for field in NULLABLE:
		if not record.has(field):
			return "Missing field: " + field
		if record[field] != null and typeof(record[field]) != NULLABLE[field]:
			return "Wrong type for " + field
	if record.spec != 1:
		return "Unsupported spec version"
	var identifier := RegEx.new()
	identifier.compile("^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$")
	if identifier.search(record.id) == null or record.id != path.get_file():
		return "id must be snake_case and match its folder"
	if ids.has(record.id):
		return "Duplicate id: " + record.id
	var location := path.trim_prefix(root + "/").get_slice("/", 0)
	if location != "legacy" and location != record.category:
		return "Asset must be under its category folder"
	if not record.category in CATEGORIES or not record.status in STATUSES:
		return "Unknown category or status"
	if record.height_m <= 0 or not is_finite(record.height_m):
		return "height_m must be a positive finite number"
	if record.fit_to_height and record.status != "legacy":
		return "fit_to_height is only allowed for legacy models"
	for filename in [record.model] + record.animations:
		if not filename is String or filename.is_empty() or filename != filename.get_file() or filename in [".", ".."]:
			return "Model and animation paths must be file names within the asset folder"
		if not filename.get_extension().to_lower() in ["glb", "gltf"]:
			return "Unsupported model format: " + filename
		if not FileAccess.file_exists(path.path_join(filename)):
			return "Missing model file: " + filename
	return ""
