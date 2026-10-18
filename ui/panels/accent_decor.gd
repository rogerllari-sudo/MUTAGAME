extends Control

@export var line_color: Color = Color("#39D8FF")
@export_range(0.0, 1.0) var opacity: float = 0.45

@export var line_width: float = 1.5

@export var margin: float = 55.0
@export var segment_length: float = 55.0
@export var gap: float = 120.0

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()


func _draw():

	var c = line_color
	c.a = opacity

	var center = size.x / 2.0

	# ---------- SUPERIOR ----------

	draw_line(
		Vector2(margin, margin),
		Vector2(center - gap/2.0, margin),
		c,
		line_width
	)

	draw_line(
		Vector2(center + gap/2.0, margin),
		Vector2(size.x - margin, margin),
		c,
		line_width
	)

	# ---------- INFERIOR ----------

	draw_line(
		Vector2(margin, size.y - margin),
		Vector2(center - gap/2.0, size.y - margin),
		c,
		line_width
	)

	draw_line(
		Vector2(center + gap/2.0, size.y - margin),
		Vector2(size.x - margin, size.y - margin),
		c,
		line_width
	)
