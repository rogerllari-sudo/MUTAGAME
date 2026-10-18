@tool
extends Control


@export_category("Frame")

@export var frame_margin: float = 14.0
@export var corner_cut: float = 20.0
@export var line_width: float = 1.4

@export var frame_color: Color = Color(
	0.25,
	0.85,
	1.0,
	0.72
)


@export_category("Decorations")

@export var segment_length: float = 270.0
@export var small_segment_length: float = 110.0

@export var dot_radius: float = 2.2
@export var decoration_alpha: float = 0.55


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var panel_size: Vector2 = size

	if panel_size.x <= 0.0 or panel_size.y <= 0.0:
		return

	var left: float = frame_margin
	var top: float = frame_margin
	var right: float = panel_size.x - frame_margin
	var bottom: float = panel_size.y - frame_margin

	var decoration_color: Color = frame_color
	decoration_color.a *= decoration_alpha

	# Cantonada superior esquerra
	draw_polyline(
		PackedVector2Array([
			Vector2(left, top + corner_cut),
			Vector2(left, top),
			Vector2(left + corner_cut, top),
			Vector2(left + segment_length, top)
		]),
		frame_color,
		line_width,
		true
	)

	# Cantonada superior dreta
	draw_polyline(
		PackedVector2Array([
			Vector2(right - segment_length, top),
			Vector2(right - corner_cut, top),
			Vector2(right, top),
			Vector2(right, top + corner_cut)
		]),
		frame_color,
		line_width,
		true
	)

	# Cantonada inferior esquerra
	draw_polyline(
		PackedVector2Array([
			Vector2(left, bottom - corner_cut),
			Vector2(left, bottom),
			Vector2(left + corner_cut, bottom),
			Vector2(left + segment_length, bottom)
		]),
		frame_color,
		line_width,
		true
	)

	# Cantonada inferior dreta
	draw_polyline(
		PackedVector2Array([
			Vector2(right - segment_length, bottom),
			Vector2(right - corner_cut, bottom),
			Vector2(right, bottom),
			Vector2(right, bottom - corner_cut)
		]),
		frame_color,
		line_width,
		true
	)

	# Segments superiors centrals
	draw_line(
		Vector2(left + segment_length + 30.0, top),
		Vector2(
			panel_size.x * 0.46,
			top
		),
		decoration_color,
		line_width,
		true
	)

	draw_line(
		Vector2(panel_size.x * 0.54, top),
		Vector2(
			right - segment_length - 30.0,
			top
		),
		decoration_color,
		line_width,
		true
	)

	# Segments inferiors centrals
	draw_line(
		Vector2(left + segment_length + 40.0, bottom),
		Vector2(
			panel_size.x * 0.43,
			bottom
		),
		decoration_color,
		line_width,
		true
	)

	draw_line(
		Vector2(panel_size.x * 0.57, bottom),
		Vector2(
			right - segment_length - 40.0,
			bottom
		),
		decoration_color,
		line_width,
		true
	)

	# Petites marques superiors
	draw_circle(
		Vector2(left + 38.0, top + 32.0),
		dot_radius,
		decoration_color
	)

	draw_circle(
		Vector2(left + 50.0, top + 32.0),
		dot_radius,
		decoration_color
	)

	draw_circle(
		Vector2(left + 62.0, top + 32.0),
		dot_radius,
		decoration_color
	)

	# Marques inferiors
	for index: int in range(4):
		draw_circle(
			Vector2(
				panel_size.x * 0.27
				+ float(index) * 12.0,
				bottom - 16.0
			),
			dot_radius,
			decoration_color
		)

	# Petits blocs inferiors
	for index: int in range(4):
		var block_position: Vector2 = Vector2(
			panel_size.x * 0.31
			+ float(index) * 11.0,
			bottom - 19.0
		)

		draw_rect(
			Rect2(
				block_position,
				Vector2(7.0, 6.0)
			),
			decoration_color
		)
