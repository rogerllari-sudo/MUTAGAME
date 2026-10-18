@tool
extends Node2D


@export_category("Dimensions")
@export var fragment_height: float = 240.0
@export var helix_width: float = 115.0
@export var strand_width: float = 5.0
@export var pair_count: int = 8
@export var curve_resolution: int = 80

@export_category("Colors")
@export var left_strand_color: Color = Color("#66E6FF")
@export var right_strand_color: Color = Color("#8A7CFF")
@export var bond_color: Color = Color("#5B7883")
@export var base_fill_color: Color = Color("#142731")
@export var base_outline_color: Color = Color("#C9F7FF")
@export var text_color: Color = Color("#EAFBFF")

@export_category("Base appearance")
@export var base_radius: float = 15.0
@export var bond_width: float = 2.0

@export_category("Opening")
@export var opening_distance: float = 72.0


var helix_phase: float = 0.0
var opening_amount: float = 0.0

var mutation_color_by_pair: Dictionary = {}
var mutation_pulse: float = 0.0


var base_pairs: Array[Array] = [
	["A", "T"],
	["C", "G"],
	["G", "C"],
	["T", "A"],
	["A", "T"],
	["G", "C"],
	["C", "G"],
	["T", "A"]
]


func _init() -> void:
	mutation_color_by_pair = {}


func _ready() -> void:
	if mutation_color_by_pair == null:
		mutation_color_by_pair = {}

	queue_redraw()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	mutation_pulse = (
		sin(Time.get_ticks_msec() / 260.0) + 1.0
	) / 2.0

	queue_redraw()


func set_mutations(mutation_data: Dictionary) -> void:
	mutation_color_by_pair = mutation_data.duplicate(true)
	queue_redraw()


func clear_mutations() -> void:
	mutation_color_by_pair = {}
	queue_redraw()


func _draw() -> void:
	var left_points: PackedVector2Array = PackedVector2Array()
	var right_points: PackedVector2Array = PackedVector2Array()

	# Construcció de les dues cadenes.
	# Mentre s’obren, perden progressivament la torsió helicoidal.
	for index: int in range(curve_resolution + 1):
		var progress: float = float(index) / float(curve_resolution)

		var y_position: float = lerpf(
			-fragment_height / 2.0,
			fragment_height / 2.0,
			progress
		)

		var angle: float = progress * TAU * 1.5 + helix_phase
		var helix_offset: float = sin(angle) * helix_width / 2.0

		var remaining_helix: float = helix_offset * (1.0 - opening_amount)
		var separation: float = opening_amount * opening_distance

		var left_x: float = remaining_helix - separation
		var right_x: float = -remaining_helix + separation

		left_points.append(
			Vector2(left_x, y_position)
		)

		right_points.append(
			Vector2(right_x, y_position)
		)

	# Glow posterior subtil
	var left_glow_color: Color = left_strand_color
	left_glow_color.a = 0.14

	var right_glow_color: Color = right_strand_color
	right_glow_color.a = 0.14

	draw_polyline(
		left_points,
		left_glow_color,
		strand_width + 10.0,
		true
	)

	draw_polyline(
		right_points,
		right_glow_color,
		strand_width + 10.0,
		true
	)

	# Cadenes principals
	draw_polyline(
		left_points,
		left_strand_color,
		strand_width,
		true
	)

	draw_polyline(
		right_points,
		right_strand_color,
		strand_width,
		true
	)

	# Parells de bases
	for pair_index: int in range(pair_count):
		var progress: float = float(pair_index + 1) / float(pair_count + 1)

		var y_position: float = lerpf(
			-fragment_height / 2.0,
			fragment_height / 2.0,
			progress
		)

		var angle: float = progress * TAU * 1.5 + helix_phase
		var helix_offset: float = sin(angle) * helix_width / 2.0

		var remaining_helix: float = helix_offset * (1.0 - opening_amount)
		var separation: float = opening_amount * opening_distance

		var left_position: Vector2 = Vector2(
			remaining_helix - separation,
			y_position
		)

		var right_position: Vector2 = Vector2(
			-remaining_helix + separation,
			y_position
		)

		draw_base_pair(
			pair_index,
			left_position,
			right_position
		)


func get_mutation_color(pair_index: int) -> Color:
	var mutation_data: Variant = mutation_color_by_pair

	if typeof(mutation_data) != TYPE_DICTIONARY:
		return Color.TRANSPARENT

	var safe_dictionary: Dictionary = mutation_data
	var stored_color: Variant = safe_dictionary.get(pair_index, null)

	if typeof(stored_color) != TYPE_COLOR:
		return Color.TRANSPARENT

	return stored_color


func draw_base_pair(
	pair_index: int,
	left_position: Vector2,
	right_position: Vector2
) -> void:
	var direction: Vector2 = right_position - left_position
	var distance: float = direction.length()

	if distance < 1.0:
		return

	var normalized_direction: Vector2 = direction.normalized()

	var bond_start: Vector2 = (
		left_position
		+ normalized_direction * base_radius
	)

	var bond_end: Vector2 = (
		right_position
		- normalized_direction * base_radius
	)

	var highlight_color: Color = get_mutation_color(pair_index)
	var has_mutation: bool = highlight_color.a > 0.0

	# Glow de la mutació, darrere de les bases
	if has_mutation:
		var glow_color: Color = highlight_color
		glow_color.a = (
			0.10
			+ mutation_pulse * 0.10
		) * (1.0 - opening_amount)

		var glow_radius: float = (
			base_radius
			+ 9.0
			+ mutation_pulse * 4.0
		)

		draw_circle(
			left_position,
			glow_radius,
			glow_color
		)

		draw_circle(
			right_position,
			glow_radius,
			glow_color
		)

	# Els ponts d’hidrogen desapareixen mentre l’ADN s’obre
	var current_bond_color: Color = bond_color
	current_bond_color.a *= 1.0 - opening_amount

	if current_bond_color.a > 0.01:
		draw_line(
			bond_start,
			bond_end,
			current_bond_color,
			bond_width,
			true
		)

	# Bases
	draw_hexagon(
		left_position,
		base_radius
	)

	draw_hexagon(
		right_position,
		base_radius
	)

	var pair: Array = base_pairs[
		pair_index % base_pairs.size()
	]

	var left_letter: String = str(pair[0])
	var right_letter: String = str(pair[1])

	draw_base_letter(
		left_position,
		left_letter
	)

	draw_base_letter(
		right_position,
		right_letter
	)

	# Contorn i pont ressaltats
	if has_mutation:
		var mutation_alpha: float = 1.0 - opening_amount

		if mutation_alpha > 0.01:
			var current_highlight_color: Color = highlight_color
			current_highlight_color.a *= mutation_alpha

			draw_arc(
				left_position,
				base_radius + 4.0,
				0.0,
				TAU,
				32,
				current_highlight_color,
				2.5,
				true
			)

			draw_arc(
				right_position,
				base_radius + 4.0,
				0.0,
				TAU,
				32,
				current_highlight_color,
				2.5,
				true
			)

			draw_line(
				bond_start,
				bond_end,
				current_highlight_color,
				bond_width + 1.5,
				true
			)


func draw_hexagon(
	center: Vector2,
	radius: float
) -> void:
	var points: PackedVector2Array = PackedVector2Array()

	for point_index: int in range(6):
		var angle: float = deg_to_rad(
			60.0 * float(point_index) - 30.0
		)

		var point: Vector2 = (
			center
			+ Vector2(cos(angle), sin(angle)) * radius
		)

		points.append(point)

	draw_colored_polygon(
		points,
		base_fill_color
	)

	var outline_points: PackedVector2Array = PackedVector2Array()

	for point: Vector2 in points:
		outline_points.append(point)

	outline_points.append(points[0])

	draw_polyline(
		outline_points,
		base_outline_color,
		2.0,
		true
	)


func draw_base_letter(
	center: Vector2,
	letter: String
) -> void:
	var font: Font = ThemeDB.fallback_font
	var font_size: int = 13

	var text_size: Vector2 = font.get_string_size(
		letter,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size
	)

	var text_position: Vector2 = center + Vector2(
		-text_size.x / 2.0,
		text_size.y / 3.0
	)

	draw_string(
		font,
		text_position,
		letter,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		text_color
	)


func animate_opening(duration: float = 0.9) -> void:
	var tween: Tween = create_tween()

	tween.tween_property(
		self,
		"opening_amount",
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


func animate_closing(duration: float = 0.7) -> void:
	var tween: Tween = create_tween()

	tween.tween_property(
		self,
		"opening_amount",
		0.0,
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
