@tool
extends Node2D


@export_category("Dimensions")
@export var upper_radius: Vector2 = Vector2(58.0, 30.0)
@export var lower_radius: Vector2 = Vector2(48.0, 24.0)
@export var channel_width: float = 10.0

@export_category("Colors")
@export var upper_color: Color = Color("#5574D9")
@export var lower_color: Color = Color("#7553C6")
@export var outline_color: Color = Color("#B9C8FF")
@export var channel_color: Color = Color("#263244")
@export var glow_color: Color = Color("#305D7CFF")

@export_category("Animation")
@export var pulse_speed: float = 3.2
@export var pulse_strength: float = 0.04

var pulse_time: float = 0.0


func _ready() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	pulse_time += delta * pulse_speed
	queue_redraw()


func _draw() -> void:
	var pulse: float = 1.0 + sin(pulse_time) * pulse_strength

	var upper_size: Vector2 = upper_radius * pulse
	var lower_size: Vector2 = lower_radius * pulse

	# Glow exterior
	draw_custom_ellipse(
		Vector2(0.0, -12.0),
		upper_size + Vector2(12.0, 10.0),
		glow_color
	)

	draw_custom_ellipse(
		Vector2(0.0, 17.0),
		lower_size + Vector2(10.0, 8.0),
		glow_color
	)

	# Subunitat superior
	draw_custom_ellipse(
		Vector2(0.0, -12.0),
		upper_size,
		upper_color
	)

	draw_custom_ellipse_outline(
		Vector2(0.0, -12.0),
		upper_size,
		outline_color,
		2.0
	)

	# Subunitat inferior
	draw_custom_ellipse(
		Vector2(0.0, 17.0),
		lower_size,
		lower_color
	)

	draw_custom_ellipse_outline(
		Vector2(0.0, 17.0),
		lower_size,
		outline_color,
		2.0
	)

	# Canal central per on passarà l’ARN
	draw_rect(
		Rect2(
			Vector2(-channel_width / 2.0, -27.0),
			Vector2(channel_width, 54.0)
		),
		channel_color,
		true
	)

	draw_line(
		Vector2(-channel_width / 2.0, -25.0),
		Vector2(-channel_width / 2.0, 25.0),
		outline_color,
		1.0,
		true
	)

	draw_line(
		Vector2(channel_width / 2.0, -25.0),
		Vector2(channel_width / 2.0, 25.0),
		outline_color,
		1.0,
		true
	)

func draw_custom_ellipse(
	center: Vector2,
	radius: Vector2,
	color: Color
) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var point_count: int = 48

	for index: int in range(point_count):
		var angle: float = TAU * float(index) / float(point_count)

		points.append(
			center + Vector2(
				cos(angle) * radius.x,
				sin(angle) * radius.y
			)
		)

	draw_colored_polygon(points, color)


func draw_custom_ellipse_outline(
	center: Vector2,
	radius: Vector2,
	color: Color,
	width: float
) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var point_count: int = 48

	for index: int in range(point_count + 1):
		var angle: float = TAU * float(index) / float(point_count)

		points.append(
			center + Vector2(
				cos(angle) * radius.x,
				sin(angle) * radius.y
			)
		)

	draw_polyline(
		points,
		color,
		width,
		true
	)
