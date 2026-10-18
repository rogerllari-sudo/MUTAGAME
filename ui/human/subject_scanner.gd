@tool
extends Control


@export_category("Scanner geometry")

@export var scanner_center: Vector2 = Vector2(0.5, 0.48)

@export var main_radius: float = 92.0
@export var inner_radius: float = 70.0
@export var outer_radius: float = 108.0

@export var arc_width: float = 2.0
@export var segment_count: int = 10


@export_category("Colors")

@export var main_color: Color = Color(
	0.40,
	0.90,
	1.0,
	0.20
)

@export var accent_color: Color = Color(
	0.10,
	0.72,
	0.95,
	0.30
)

@export var faint_color: Color = Color(
	0.15,
	0.55,
	0.75,
	0.10
)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return

	var center: Vector2 = Vector2(
		size.x * scanner_center.x,
		size.y * scanner_center.y
	)

	# Cercle interior molt subtil
	draw_arc(
		center,
		inner_radius,
		0.0,
		TAU,
		96,
		faint_color,
		1.0,
		true
	)

	# Cercle exterior
	draw_arc(
		center,
		outer_radius,
		0.0,
		TAU,
		96,
		faint_color,
		1.0,
		true
	)

	# Quatre arcs principals incomplets
	var arc_length: float = deg_to_rad(54.0)

	for quadrant: int in range(4):
		var base_angle: float = (
			float(quadrant) * TAU / 4.0
			+ deg_to_rad(18.0)
		)

		draw_arc(
			center,
			main_radius,
			base_angle,
			base_angle + arc_length,
			28,
			main_color,
			arc_width,
			true
		)

	# Petits segments tècnics al cercle exterior
	for index: int in range(segment_count):
		var angle: float = (
			float(index)
			/ float(segment_count)
			* TAU
		)

		var segment_is_active: bool = (
			index % 3 != 1
		)

		if not segment_is_active:
			continue

		var radial_direction: Vector2 = Vector2(
			cos(angle),
			sin(angle)
		)

		var tangent_direction: Vector2 = Vector2(
			-radial_direction.y,
			radial_direction.x
		)

		var segment_center: Vector2 = (
			center
			+ radial_direction * outer_radius
		)

		draw_line(
			segment_center - tangent_direction * 5.0,
			segment_center + tangent_direction * 5.0,
			accent_color,
			1.4,
			true
		)

	# Creu biomètrica central molt subtil
	draw_line(
		center + Vector2(-14.0, 0.0),
		center + Vector2(14.0, 0.0),
		faint_color,
		1.0,
		true
	)

	draw_line(
		center + Vector2(0.0, -14.0),
		center + Vector2(0.0, 14.0),
		faint_color,
		1.0,
		true
	)
