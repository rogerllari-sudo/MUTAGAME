@tool
extends Control

@export var accent_color: Color = Color("#66E6FF"):
	set(value):
		accent_color = value
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	var w := size.x
	var h := size.y

	var cut := 12.0
	var margin := 4.0

	var points := PackedVector2Array([
		Vector2(margin + cut, margin),
		Vector2(w - margin - cut, margin),
		Vector2(w - margin, margin + cut),
		Vector2(w - margin, h - margin - cut),
		Vector2(w - margin - cut, h - margin),
		Vector2(margin + cut, h - margin),
		Vector2(margin, h - margin - cut),
		Vector2(margin, margin + cut),
		Vector2(margin + cut, margin)
	])

	draw_polyline(
		points,
		accent_color,
		1.5,
		true
	)

	# Accent superior esquerre
	draw_line(
		Vector2(28, 8),
		Vector2(120, 8),
		accent_color,
		2.0
	)

	# Accent inferior dret
	draw_line(
		Vector2(w - 180, h - 8),
		Vector2(w - 55, h - 8),
		accent_color,
		2.0
	)

	# Tres ratlles diagonals decoratives
	for i in range(4):
		var x := w - 150.0 + i * 12.0

		draw_line(
			Vector2(x, 7),
			Vector2(x + 7, 12),
			accent_color,
			2.0,
			true
		)
