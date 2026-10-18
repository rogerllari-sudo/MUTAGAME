@tool
extends Control


@export_category("Grid")

@export var grid_spacing: float = 34.0

@export var grid_color: Color = Color(
	0.25,
	0.85,
	1.0,
	0.035
)

@export var major_grid_every: int = 4

@export var major_grid_color: Color = Color(
	0.25,
	0.85,
	1.0,
	0.065
)


@export_category("Digital details")

@export var detail_color: Color = Color(
	0.40,
	0.90,
	1.0,
	0.15
)

@export var faint_detail_color: Color = Color(
	0.20,
	0.60,
	0.80,
	0.07
)

@export var dot_radius: float = 1.4


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	_draw_grid()
	_draw_digital_details()
	_draw_scan_marks()


func _draw_grid() -> void:
	var column_index: int = 0
	var x_position: float = 0.0

	while x_position <= size.x:
		var current_color: Color = grid_color

		if column_index % major_grid_every == 0:
			current_color = major_grid_color

		draw_line(
			Vector2(x_position, 0.0),
			Vector2(x_position, size.y),
			current_color,
			1.0
		)

		x_position += grid_spacing
		column_index += 1

	var row_index: int = 0
	var y_position: float = 0.0

	while y_position <= size.y:
		var current_color: Color = grid_color

		if row_index % major_grid_every == 0:
			current_color = major_grid_color

		draw_line(
			Vector2(0.0, y_position),
			Vector2(size.x, y_position),
			current_color,
			1.0
		)

		y_position += grid_spacing
		row_index += 1


func _draw_digital_details() -> void:
	var detail_positions: Array[Vector2] = [
		Vector2(size.x * 0.08, size.y * 0.18),
		Vector2(size.x * 0.91, size.y * 0.16),
		Vector2(size.x * 0.63, size.y * 0.12),
		Vector2(size.x * 0.86, size.y * 0.72),
		Vector2(size.x * 0.57, size.y * 0.88),
		Vector2(size.x * 0.17, size.y * 0.82)
	]

	for position: Vector2 in detail_positions:
		_draw_cross_marker(
			position,
			5.0,
			faint_detail_color
		)

	var dot_groups: Array[Vector2] = [
		Vector2(size.x * 0.055, size.y * 0.09),
		Vector2(size.x * 0.75, size.y * 0.91),
		Vector2(size.x * 0.93, size.y * 0.44)
	]

	for group_position: Vector2 in dot_groups:
		for index: int in range(4):
			draw_circle(
				group_position
				+ Vector2(float(index) * 9.0, 0.0),
				dot_radius,
				detail_color
			)


func _draw_scan_marks() -> void:
	var left_x: float = size.x * 0.035
	var right_x: float = size.x * 0.965

	var mark_positions: Array[float] = [
		size.y * 0.28,
		size.y * 0.31,
		size.y * 0.62,
		size.y * 0.65
	]

	for y_position: float in mark_positions:
		draw_line(
			Vector2(left_x, y_position),
			Vector2(left_x + 18.0, y_position),
			faint_detail_color,
			1.0
		)

		draw_line(
			Vector2(right_x - 18.0, y_position),
			Vector2(right_x, y_position),
			faint_detail_color,
			1.0
		)

	# Petites línies decoratives disperses
	draw_line(
		Vector2(size.x * 0.48, size.y * 0.18),
		Vector2(size.x * 0.60, size.y * 0.18),
		faint_detail_color,
		1.0
	)

	draw_rect(
		Rect2(
			Vector2(size.x * 0.605, size.y * 0.176),
			Vector2(5.0, 5.0)
		),
		detail_color
	)


func _draw_cross_marker(
	center: Vector2,
	marker_size: float,
	color: Color
) -> void:
	draw_line(
		center + Vector2(-marker_size, 0.0),
		center + Vector2(marker_size, 0.0),
		color,
		1.0
	)

	draw_line(
		center + Vector2(0.0, -marker_size),
		center + Vector2(0.0, marker_size),
		color,
		1.0
	)
