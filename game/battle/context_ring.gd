class_name ContextRing
extends Control

const WIDTH := 5.0
const TRACK_COLOR := Color(1, 1, 1, 0.15)
const BLUE := Color(0.36, 0.62, 1.0)
const YELLOW := Color(1.0, 0.8, 0.25)
const RED := Color(1.0, 0.38, 0.33)
const YELLOW_FROM := 0.5
const RED_FROM := 0.8

var fill := 0.0:
	set(value):
		fill = clampf(value, 0.0, 1.0)
		queue_redraw()


func _draw() -> void:
	var center := size / 2.0
	var radius := minf(size.x, size.y) / 2.0 - WIDTH / 2.0
	draw_arc(center, radius, 0.0, TAU, 64, TRACK_COLOR, WIDTH, true)
	if fill <= 0.0:
		return
	var color := BLUE if fill < YELLOW_FROM else YELLOW if fill < RED_FROM else RED
	# Screen y points down, so a growing angle runs clockwise from twelve o'clock.
	draw_arc(center, radius, -PI / 2.0, -PI / 2.0 + TAU * fill, maxi(8, int(64 * fill)), color, WIDTH, true)
