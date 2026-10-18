@tool
extends Control


@export var line_color: Color = Color(
	0.40,
	0.90,
	1.0,
	0.28
)

@export var line_width: float = 1.5


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var middle_y: float = size.y * 0.58

	var points: PackedVector2Array = PackedVector2Array([
		Vector2(0.0, middle_y),
		Vector2(size.x * 0.18, middle_y),
		Vector2(size.x * 0.28, middle_y - 3.0),
		Vector2(size.x * 0.36, middle_y),
		Vector2(size.x * 0.46, middle_y),
		Vector2(size.x * 0.54, middle_y - 13.0),
		Vector2(size.x * 0.61, middle_y + 8.0),
		Vector2(size.x * 0.69, middle_y - 5.0),
		Vector2(size.x * 0.77, middle_y),
		Vector2(size.x, middle_y)
	])

	draw_polyline(
		points,
		line_color,
		line_width,
		true
	)
	
