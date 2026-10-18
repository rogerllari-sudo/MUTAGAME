@tool
extends Control


@export_category("Geometry")

@export var outer_margin: float = 1.0
@export var corner_length: float = 18.0
@export var corner_cut: float = 7.0
@export var line_width: float = 1.0

@export_range(0.0, 1.0) var top_gap_start: float = 0.34
@export_range(0.0, 1.0) var top_gap_end: float = 0.56

@export_range(0.0, 1.0) var bottom_gap_start: float = 0.28
@export_range(0.0, 1.0) var bottom_gap_end: float = 0.68


@export_category("Colors")

@export var frame_color: Color = Color(
	0.40,
	0.90,
	1.0,
	0.62
)

@export var secondary_color: Color = Color(
	0.20,
	0.68,
	0.84,
	0.32
)

@export var detail_color: Color = Color(
	0.55,
	0.96,
	1.0,
	0.55
)


@export_category("Calibration details")

@export var show_top_blocks: bool = true
@export var show_bottom_blocks: bool = true
@export var block_size: Vector2 = Vector2(4.0, 2.0)
@export var block_spacing: float = 7.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	_draw_corner_frame()
	_draw_segmented_edges()
	_draw_calibration_marks()

func _draw_corner_frame() -> void:
	var left: float = outer_margin
	var top: float = outer_margin
	var right: float = size.x - outer_margin
	var bottom: float = size.y - outer_margin

	# Superior esquerra
	draw_polyline(
		PackedVector2Array([
			Vector2(left, top + corner_length),
			Vector2(left, top + corner_cut),
			Vector2(left + corner_cut, top),
			Vector2(left + corner_length, top)
		]),
		frame_color,
		line_width,
		true
	)

	# Superior dreta
	draw_polyline(
		PackedVector2Array([
			Vector2(right - corner_length, top),
			Vector2(right - corner_cut, top),
			Vector2(right, top + corner_cut),
			Vector2(right, top + corner_length)
		]),
		frame_color,
		line_width,
		true
	)

	# Inferior esquerra
	draw_polyline(
		PackedVector2Array([
			Vector2(left, bottom - corner_length),
			Vector2(left, bottom - corner_cut),
			Vector2(left + corner_cut, bottom),
			Vector2(left + corner_length, bottom)
		]),
		frame_color,
		line_width,
		true
	)

	# Inferior dreta
	draw_polyline(
		PackedVector2Array([
			Vector2(right - corner_length, bottom),
			Vector2(right - corner_cut, bottom),
			Vector2(right, bottom - corner_cut),
			Vector2(right, bottom - corner_length)
		]),
		frame_color,
		line_width,
		true
	)


func _draw_segmented_edges() -> void:
	var left: float = outer_margin
	var top: float = outer_margin
	var right: float = size.x - outer_margin
	var bottom: float = size.y - outer_margin

	var top_left_end: float = size.x * top_gap_start
	var top_right_start: float = size.x * top_gap_end

	draw_line(
		Vector2(left + corner_length + 10.0, top),
		Vector2(top_left_end, top),
		secondary_color,
		line_width,
		true
	)

	draw_line(
		Vector2(top_right_start, top),
		Vector2(right - corner_length - 10.0, top),
		secondary_color,
		line_width,
		true
	)

	var bottom_left_end: float = size.x * bottom_gap_start
	var bottom_right_start: float = size.x * bottom_gap_end

	draw_line(
		Vector2(left + corner_length + 10.0, bottom),
		Vector2(bottom_left_end, bottom),
		secondary_color,
		line_width,
		true
	)

	draw_line(
		Vector2(bottom_right_start, bottom),
		Vector2(right - corner_length - 10.0, bottom),
		secondary_color,
		line_width,
		true
	)

# Lateral esquerre superior
	draw_line(
		Vector2(left, top + corner_length + 12.0),
		Vector2(left, size.y * 0.24),
		secondary_color,
		line_width,
		true
)

# Lateral esquerre inferior
	draw_line(
		Vector2(left, size.y * 0.78),
		Vector2(left, bottom - corner_length - 12.0),
		secondary_color,
		line_width,
		true
	)

# Lateral dret superior
	draw_line(
		Vector2(right, top + corner_length + 12.0),
		Vector2(right, size.y * 0.20),
		secondary_color,
		line_width,
		true
	)

# Lateral dret inferior
	draw_line(
		Vector2(right, size.y * 0.82),
		Vector2(right, bottom - corner_length - 12.0),
		secondary_color,
		line_width,
		true
	)

func _draw_calibration_marks() -> void:
	if show_top_blocks:
		var start_x: float = size.x - 78.0
		var y_position: float = 12.0

		for index: int in range(3):
			var current_color: Color = secondary_color

			if index == 3:
				current_color = detail_color

			draw_rect(
				Rect2(
					Vector2(
						start_x + float(index) * block_spacing,
						y_position
					),
					block_size
				),
				current_color
			)

	if show_bottom_blocks:
		var start_x: float = size.x - 72.0
		var y_position: float = size.y - 15.0

		for index: int in range(4):
			var current_color: Color = secondary_color

			if index >= 3:
				current_color = detail_color

			draw_rect(
				Rect2(
					Vector2(
						start_x + float(index) * block_spacing,
						y_position
					),
					block_size
				),
				current_color
			)

	# Petites marques tècniques
	draw_line(
		Vector2(24.0, 14.0),
		Vector2(48.0, 14.0),
		detail_color,
		1.0,
		true
	)

	draw_line(
		Vector2(size.x - 50.0, size.y - 12.0),
		Vector2(size.x - 24.0, size.y - 12.0),
		detail_color,
		1.0,
		true
	)
	
