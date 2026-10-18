extends Control


@export_category("Accent")

@export var accent_color: Color = Color("#66E6FF")

@export var line_width: float = 1.5

@export var top_line_length: float = 105.0

@export var bottom_line_length: float = 38.0


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var panel_width: float = size.x
	var panel_height: float = size.y

	# Línia curta sota el títol
	draw_line(
		Vector2(28.0, 58.0),
		Vector2(
			28.0 + top_line_length,
			58.0
		),
		accent_color,
		line_width,
		true
	)

	# Línia decorativa inferior dreta
	draw_line(
		Vector2(
			panel_width - 28.0 - bottom_line_length,
			panel_height - 28.0
		),
		Vector2(
			panel_width - 28.0,
			panel_height - 28.0
		),
		accent_color,
		line_width,
		true
	)

	# Tres petits punts terminals
	for point_index: int in range(3):
		draw_circle(
			Vector2(
				panel_width
				- 34.0
				- float(point_index) * 8.0,
				panel_height - 24.0
			),
			1.5,
			accent_color
		)
