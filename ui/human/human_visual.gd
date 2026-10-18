@tool
extends Node2D


@export_category("Dimensions")
@export var head_radius: float = 25.0
@export var torso_width: float = 54.0
@export var torso_height: float = 78.0
@export var limb_width: float = 13.0

@export_category("Colors")
@export var body_color: Color = Color("#284554")
@export var body_outline_color: Color = Color("#A7EFFF")
@export var inner_glow_color: Color = Color("#2466E6FF")
@export var face_color: Color = Color("#DDF9FF")

@export_category("Animation")
@export var breathing_strength: float = 2.0
@export var breathing_speed: float = 2.0

var breathing_time: float = 0.0


func _ready() -> void:
	queue_redraw()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	breathing_time += delta * breathing_speed
	queue_redraw()


func _draw() -> void:
	var breathing_offset: float = (
		sin(breathing_time)
		* breathing_strength
	)

	# Glow interior subtil
	draw_circle(
		Vector2(0.0, 8.0),
		74.0 + breathing_offset,
		inner_glow_color
	)

	# Cames
	draw_rounded_limb(
		Vector2(-18.0, 92.0),
		Vector2(-24.0, 154.0),
		limb_width
	)

	draw_rounded_limb(
		Vector2(18.0, 92.0),
		Vector2(24.0, 154.0),
		limb_width
	)

	# Braços
	draw_rounded_limb(
		Vector2(-30.0, 15.0),
		Vector2(-54.0, 82.0),
		limb_width
	)

	draw_rounded_limb(
		Vector2(30.0, 15.0),
		Vector2(54.0, 82.0),
		limb_width
	)

	# Tors
	var torso_rect: Rect2 = Rect2(
		Vector2(
			-torso_width / 2.0,
			0.0
		),
		Vector2(
			torso_width,
			torso_height + breathing_offset
		)
	)

	draw_rect(
		torso_rect,
		body_color,
		true
	)

	draw_rect(
		torso_rect,
		body_outline_color,
		false,
		2.5
	)

	# Coll
	draw_rect(
		Rect2(
			Vector2(-9.0, -15.0),
			Vector2(18.0, 18.0)
		),
		body_color,
		true
	)

	# Cap
	draw_circle(
		Vector2(0.0, -43.0),
		head_radius,
		body_color
	)

	draw_arc(
		Vector2(0.0, -43.0),
		head_radius,
		0.0,
		TAU,
		32,
		body_outline_color,
		2.5,
		true
	)

	# Ulls
	draw_circle(
		Vector2(-8.0, -47.0),
		2.5,
		face_color
	)

	draw_circle(
		Vector2(8.0, -47.0),
		2.5,
		face_color
	)

	# Expressió neutra
	draw_line(
		Vector2(-7.0, -34.0),
		Vector2(7.0, -34.0),
		face_color,
		2.0,
		true
	)


func draw_rounded_limb(
	start_position: Vector2,
	end_position: Vector2,
	width: float
) -> void:
	draw_line(
		start_position,
		end_position,
		body_outline_color,
		width + 4.0,
		true
	)

	draw_line(
		start_position,
		end_position,
		body_color,
		width,
		true
	)
