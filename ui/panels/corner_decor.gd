extends Control

@export var line_color: Color = Color("#39D8FF")
@export_range(0.0, 1.0) var line_opacity: float = 0.85
@export var line_width: float = 2.0
@export var corner_length: float = 28.0
@export var diagonal_size: float = 10.0
@export var inset: float = 4.0
@export var inner_offset: float = 10.0
@export var inner_length: float = 24.0
@export var inner_opacity: float = 0.35

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	var color := line_color
	color.a = line_opacity

	var left := inset
	var top := inset
	var right := size.x - inset
	var bottom := size.y - inset

	var length := corner_length
	var cut := diagonal_size

	# Cantonada superior esquerra
	draw_line(
		Vector2(left, top + cut),
		Vector2(left + cut, top),
		color,
		line_width
	)
	draw_line(
		Vector2(left + cut, top),
		Vector2(left + length, top),
		color,
		line_width
	)
	draw_line(
		Vector2(left, top + cut),
		Vector2(left, top + length),
		color,
		line_width
	)

	# Cantonada superior dreta
	draw_line(
		Vector2(right - cut, top),
		Vector2(right, top + cut),
		color,
		line_width
	)
	draw_line(
		Vector2(right - length, top),
		Vector2(right - cut, top),
		color,
		line_width
	)
	draw_line(
		Vector2(right, top + cut),
		Vector2(right, top + length),
		color,
		line_width
	)

	# Cantonada inferior esquerra
	draw_line(
		Vector2(left, bottom - cut),
		Vector2(left + cut, bottom),
		color,
		line_width
	)
	draw_line(
		Vector2(left + cut, bottom),
		Vector2(left + length, bottom),
		color,
		line_width
	)
	draw_line(
		Vector2(left, bottom - cut),
		Vector2(left, bottom - length),
		color,
		line_width
	)

	# Cantonada inferior dreta
	draw_line(
		Vector2(right - cut, bottom),
		Vector2(right, bottom - cut),
		color,
		line_width
	)
	draw_line(
		Vector2(right - length, bottom),
		Vector2(right - cut, bottom),
		color,
		line_width
	)
	draw_line(
		Vector2(right, bottom - cut),
		Vector2(right, bottom - length),
		color,
		line_width
	)
	
		# LÍNIES INTERIORS DECORATIVES
	var inner_color := line_color
	inner_color.a = inner_opacity

	# Superior esquerra
	draw_line(
		Vector2(left + inner_offset + cut, top + inner_offset),
		Vector2(left + inner_offset + inner_length, top + inner_offset),
		inner_color,
		1.0
	)

	# Superior dreta
	draw_line(
		Vector2(right - inner_offset - inner_length, top + inner_offset),
		Vector2(right - inner_offset - cut, top + inner_offset),
		inner_color,
		1.0
	)

	# Inferior esquerra
	draw_line(
		Vector2(left + inner_offset + cut, bottom - inner_offset),
		Vector2(left + inner_offset + inner_length, bottom - inner_offset),
		inner_color,
		1.0
	)

	# Inferior dreta
	draw_line(
		Vector2(right - inner_offset - inner_length, bottom - inner_offset),
		Vector2(right - inner_offset - cut, bottom - inner_offset),
		inner_color,
		1.0
	)
