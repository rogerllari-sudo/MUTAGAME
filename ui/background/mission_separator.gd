@tool
extends Control


@export var line_color: Color = Color(
	0.40,
	0.90,
	1.0,
	0.45
)

@export var line_width: float = 1.2
@export var end_block_size: Vector2 = Vector2(5.0, 3.0)
@export var right_margin: float = 26.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if size.x <= 0.0:
		return

	var center_y: float = size.y / 2.0

	var line_end_x: float = (
		size.x
		- right_margin
		- end_block_size.x
		- 5.0
	)

	draw_line(
		Vector2(0.0, center_y),
		Vector2(line_end_x, center_y),
		line_color,
		line_width,
		true
	)

	draw_rect(
		Rect2(
			Vector2(
				size.x - right_margin - end_block_size.x,
				center_y - end_block_size.y / 2.0
			),
			end_block_size
		),
		line_color
	)
