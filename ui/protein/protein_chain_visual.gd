@tool
extends Node2D


@export_category("Dimensions")
@export var amino_acid_count: int = 10
@export var spacing: float = 24.0
@export var amino_acid_radius: float = 8.0
@export var line_width: float = 3.0

@export_category("Shape")
@export var wave_amplitude: float = 13.0
@export var wave_frequency: float = 0.8

@export_category("Colors")
@export var chain_color: Color = Color("#79D8FF")
@export var amino_acid_color: Color = Color("#1A3B4B")
@export var amino_acid_outline: Color = Color("#B8F1FF")
@export var glow_color: Color = Color("#3579D8FF")

var reveal_amount: float = 0.0
var fold_amount: float = 0.0

func _ready() -> void:
	queue_redraw()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	queue_redraw()

func get_extended_position(index: int) -> Vector2:
	var x_position: float = float(index) * spacing

	var y_position: float = sin(
		float(index) * wave_frequency
	) * wave_amplitude

	return Vector2(
		x_position,
		y_position
	)


func get_folded_position(index: int) -> Vector2:
	var folded_points: Array[Vector2] = [
		Vector2(-44.0, -8.0),
		Vector2(-31.0, -34.0),
		Vector2(-7.0, -43.0),
		Vector2(17.0, -31.0),
		Vector2(38.0, -12.0),
		Vector2(29.0, 12.0),
		Vector2(8.0, 34.0),
		Vector2(-18.0, 28.0),
		Vector2(-34.0, 11.0),
		Vector2(-6.0, 2.0)]
	return folded_points[index % folded_points.size()]

func _draw() -> void:
	if reveal_amount <= 0.0:
		return

	var visible_count: int = ceili(
		float(amino_acid_count) * reveal_amount
	)

	visible_count = clampi(
		visible_count,
		0,
		amino_acid_count
	)

	var points: PackedVector2Array = PackedVector2Array()

	for index: int in range(visible_count):
		var extended_position: Vector2 = get_extended_position(index)
		var folded_position: Vector2 = get_folded_position(index)

		var current_position: Vector2 = extended_position.lerp(
			folded_position,
			fold_amount)

		points.append(current_position)

	if points.size() >= 2:
		draw_polyline(
			points,
			glow_color,
			line_width + 8.0,
			true
		)

		draw_polyline(
			points,
			chain_color,
			line_width,
			true
		)

	if fold_amount > 0.55 and points.size() >= 9:
		var internal_color: Color = chain_color
		internal_color.a = (fold_amount - 0.55) / 0.45 * 0.45

		draw_line(
			points[1],
			points[7],
			internal_color,
			2.0,
			true
		)

		draw_line(
			points[2],
			points[6],
			internal_color,
			2.0,
			true
		)

		draw_line(
			points[3],
			points[8],
			internal_color,
			2.0,
			true
		)

		draw_line(
			points[4],
			points[9],
			internal_color,
			2.0,
			true
		)


	for index: int in range(points.size()):
		draw_amino_acid(
			points[index],
			index
		)


func draw_amino_acid(
	center: Vector2,
	index: int
) -> void:
	var pulse: float = 1.0

	if index == ceili(float(amino_acid_count) * reveal_amount) - 1:
		pulse = 1.15

	var radius: float = amino_acid_radius * pulse

	draw_circle(
		center,
		radius + 5.0,
		Color(glow_color, 0.22)
	)

	draw_circle(
		center,
		radius,
		amino_acid_color
	)

	draw_arc(
		center,
		radius,
		0.0,
		TAU,
		24,
		amino_acid_outline,
		2.0,
		true
	)


func animate_reveal(duration: float = 1.7) -> void:
	reveal_amount = 0.0
	queue_redraw()

	var tween: Tween = create_tween()

	tween.tween_property(
		self,
		"reveal_amount",
		1.0,
		duration
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	tween.parallel().tween_method(
		func(_value: float) -> void:
			queue_redraw(),
		0.0,
		1.0,
		duration
	)

	await tween.finished

func animate_folding(duration: float = 1.8) -> void:
	var tween: Tween = create_tween()

	tween.tween_property(
		self,
		"fold_amount",
		1.0,
		duration
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_IN_OUT
	)

	tween.parallel().tween_method(
		func(_value: float) -> void:
			queue_redraw(),
		0.0,
		1.0,
		duration)

	await tween.finished
	
func reset_visual() -> void:
	reveal_amount = 0.0
	fold_amount = 0.0
	queue_redraw()
