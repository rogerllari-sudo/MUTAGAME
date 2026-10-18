@tool
extends Control


@export var frame_color: Color = Color("#B86B16")
@export var line_width: float = 1.2

@export var corner_length: float = 22.0
@export var diagonal_size: float = 8.0
@export var inset: float = 5.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var left: float = inset
	var top: float = inset
	var right: float = size.x - inset
	var bottom: float = size.y - inset

	# Superior esquerra
	draw_polyline(
		PackedVector2Array([
			Vector2(left, top + diagonal_size),
			Vector2(left + diagonal_size, top),
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
			Vector2(right - diagonal_size, top),
			Vector2(right, top + diagonal_size)
		]),
		frame_color,
		line_width,
		true
	)

	# Inferior esquerra
	draw_polyline(
		PackedVector2Array([
			Vector2(left, bottom - diagonal_size),
			Vector2(left + diagonal_size, bottom),
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
			Vector2(right - diagonal_size, bottom),
			Vector2(right, bottom - diagonal_size)
		]),
		frame_color,
		line_width,
		true
	)
