@tool
extends Control


@export_group("Colors")
@export var frame_color: Color = Color("#83949D")
@export var fill_color: Color = Color("#141B20")
@export var inner_color: Color = Color("#83949D55")


@export_group("Geometry")
@export var line_width: float = 1.5
@export var diagonal_size: float = 14.0
@export var outer_inset: float = 4.0
@export var inner_inset: float = 12.0


@export_group("Appearance")
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

	var outer_points: PackedVector2Array = _create_chamfered_shape(
		outer_inset,
		diagonal_size
	)

	if draw_fill:
		draw_colored_polygon(
			outer_points,
			fill_color
		)

	_draw_closed_shape(
		outer_points,
		frame_color,
		line_width
	)

	if draw_inner_frame:
		var inner_points: PackedVector2Array = _create_chamfered_shape(
			inner_inset,
			diagonal_size * 0.65
		)

		_draw_closed_shape(
			inner_points,
			inner_color,
			1.0
		)

	if draw_details:
		_draw_terminal_marks()


func _create_chamfered_shape(
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


func _draw_terminal_marks() -> void:
	var top_y: float = outer_inset + 8.0
	var bottom_y: float = size.y - outer_inset - 8.0

	# Marques superiors
	draw_line(
		Vector2(size.x * 0.18, top_y),
		Vector2(size.x * 0.27, top_y),
		inner_color,
		1.0,
		true
	)

	draw_line(
		Vector2(size.x * 0.73, top_y),
		Vector2(size.x * 0.82, top_y),
		inner_color,
		1.0,
		true
	)

	# Marques inferiors
	draw_line(
		Vector2(size.x * 0.10, bottom_y),
		Vector2(size.x * 0.16, bottom_y),
		inner_color,
		1.0,
		true
	)

	draw_line(
		Vector2(size.x * 0.84, bottom_y),
		Vector2(size.x * 0.90, bottom_y),
		inner_color,
		1.0,
		true
	)
