@tool
extends Node2D


@export_category("Dimensions")
@export var strand_height: float = 220.0
@export var strand_amplitude: float = 18.0
@export var strand_width: float = 5.0
@export var curve_resolution: int = 80
@export var base_count: int = 8

@export_category("Colors")
@export var strand_color: Color = Color("#F3B65C")
@export var glow_color: Color = Color("#55F3B65C")
@export var base_fill_color: Color = Color("#2A2117")
@export var base_outline_color: Color = Color("#FFD28A")
@export var text_color: Color = Color("#FFF4DD")

@export_category("Appearance")
@export var base_radius: float = 13.0

var reveal_amount: float = 0.0

var rna_bases: Array[String] = [
	"U",
	"G",
	"C",
	"A",
	"U",
	"C",
	"G",
	"A"
]


func _ready() -> void:
	queue_redraw()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	queue_redraw()


func _draw() -> void:
	var visible_height: float = strand_height * reveal_amount

	if visible_height <= 0.5:
		return

	var strand_points: PackedVector2Array = PackedVector2Array()

	for index: int in range(curve_resolution + 1):
		var progress: float = float(index) / float(curve_resolution)

		if progress > reveal_amount:
			break

		var y_position: float = lerpf(
			-strand_height / 2.0,
			strand_height / 2.0,
			progress
		)

		var x_position: float = sin(progress * TAU * 1.25) * strand_amplitude

		strand_points.append(
			Vector2(x_position, y_position)
		)

	if strand_points.size() < 2:
		return

	draw_polyline(
		strand_points,
		glow_color,
		strand_width + 10.0,
		true
	)

	draw_polyline(
		strand_points,
		strand_color,
		strand_width,
		true
	)

	for base_index: int in range(base_count):
		var progress: float = float(base_index + 1) / float(base_count + 1)

		if progress > reveal_amount:
			continue

		var y_position: float = lerpf(
			-strand_height / 2.0,
			strand_height / 2.0,
			progress
		)

		var x_position: float = sin(progress * TAU * 1.25) * strand_amplitude

		var base_position: Vector2 = Vector2(
			x_position + 24.0,
			y_position
		)

		draw_base(
			base_position,
			rna_bases[base_index % rna_bases.size()]
		)

func get_point_at_progress(progress: float) -> Vector2:
	var safe_progress: float = clampf(progress, 0.0, 1.0)

	var y_position: float = lerpf(
		-strand_height / 2.0,
		strand_height / 2.0,
		safe_progress
	)

	var x_position: float = sin(
		safe_progress * TAU * 1.25
	) * strand_amplitude

	return Vector2(
		x_position,
		y_position
	)

func draw_base(
	center: Vector2,
	letter: String
) -> void:
	draw_circle(
		center,
		base_radius,
		base_fill_color
	)

	draw_arc(
		center,
		base_radius,
		0.0,
		TAU,
		24,
		base_outline_color,
		2.0,
		true
	)

	draw_line(
		center - Vector2(24.0, 0.0),
		center - Vector2(base_radius, 0.0),
		base_outline_color,
		2.0,
		true
	)

	var font: Font = ThemeDB.fallback_font
	var font_size: int = 12

	var text_size: Vector2 = font.get_string_size(
		letter,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size
	)

	draw_string(
		font,
		center + Vector2(
			-text_size.x / 2.0,
			text_size.y / 3.0
		),
		letter,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		text_color
	)


func animate_reveal(duration: float = 1.3) -> void:
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
