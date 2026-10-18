@tool
extends Control


@export var frame_color: Color = Color("#66E6FF")
@export var fill_color: Color = Color("#07101880")
@export var detail_color: Color = Color("#66E6FF55")

@export var line_width: float = 1.2
@export var diagonal_size: float = 8.0
@export var outer_inset: float = 2.0
@export var inner_inset: float = 7.0

@export var draw_fill: bool = true
@export var draw_inner_frame: bool = true
@export var draw_details: bool = true


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var outer_shape := _create_shape(
		outer_inset,
		diagonal_size
	)

	if draw_fill:
		draw_colored_polygon(
			outer_shape,
			fill_color
		)

	_draw_closed_shape(
		outer_shape,
		frame_color,
		line_width
	)

	if draw_inner_frame:
		var inner_shape := _create_shape(
			inner_inset,
			diagonal_size * 0.55
		)

		_draw_closed_shape(
			inner_shape,
			detail_color,
			0.8
		)

	if draw_details:
		_draw_details()


func _create_shape(
	inset: float,
	cut: float
) -> PackedVector2Array:
	var left: float = inset
	var top: float = inset
	var right: float = size.x - inset
	var bottom: float = size.y - inset

	return PackedVector2Array([
		Vector2(left + cut, top),
		Vector2(right - cut, top),
		Vector2(right, top + cut),
		Vector2(right, bottom - cut),
		Vector2(right - cut, bottom),
		Vector2(left + cut, bottom),
		Vector2(left, bottom - cut),
		Vector2(left, top + cut)
	])


func _draw_closed_shape(
	points: PackedVector2Array,
	color: Color,
	width: float
) -> void:
	var closed_points := PackedVector2Array(points)
	closed_points.append(points[0])

	draw_polyline(
		closed_points,
		color,
		width,
		true
	)


func _draw_details() -> void:
	var top_y: float = outer_inset + 6.0
	var bottom_y: float = size.y - outer_inset - 6.0

	draw_line(
		Vector2(size.x * 0.14, top_y),
		Vector2(size.x * 0.30, top_y),
		detail_color,
		0.8,
		true
	)

	draw_line(
		Vector2(size.x * 0.70, bottom_y),
		Vector2(size.x * 0.88, bottom_y),
		detail_color,
		0.8,
		true
	)

	draw_circle(
		Vector2(size.x * 0.91, bottom_y),
		1.5,
		frame_color
	)
