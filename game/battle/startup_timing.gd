class_name StartupTiming
extends RefCounted

# Opt-in measurements only; nested resource/animation work is subtracted from construction.
static var enabled := false
static var milliseconds := {}
static var rigs := {}
static var resources := {}


static func reset() -> void:
	milliseconds.clear()
	rigs.clear()
	resources.clear()
	enabled = true


static func begin() -> int:
	return Time.get_ticks_usec() if enabled else 0


static func end(stage: String, started: int, nested := 0.0) -> float:
	if not enabled:
		return 0.0
	var elapsed := (Time.get_ticks_usec() - started) / 1000.0 - nested
	milliseconds[stage] = milliseconds.get(stage, 0.0) + elapsed
	return elapsed


static func nested() -> float:
	return milliseconds.get("resources", 0.0) + milliseconds.get("animations", 0.0)


static func loaded(path: String, started: int) -> void:
	var elapsed := end("resources", started)
	if enabled:
		resources[path] = resources.get(path, 0.0) + elapsed
