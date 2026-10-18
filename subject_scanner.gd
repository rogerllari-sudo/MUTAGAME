extends Control


signal scan_finished


# ============================================================
# REFERÈNCIES

@onready var subject: Sprite2D = (
	$"../../HumanActor/HumanTexture"
)

@onready var scanner_status: Label = (
	$ScannerStatus
)


# ============================================================
# COLORS

const CYAN := Color("#66E6FF")
const BRIGHT_CYAN := Color("#B9FAFF")
const GREEN := Color("#0072B2")


# ============================================================
# VARIABLES

var scan_progress: float = 0.0
var scanner_alpha: float = 0.0
var pulse_time: float = 0.0
var scan_running: bool = false


# ============================================================
# INICIALITZACIÓ

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	scanner_status.mouse_filter = (
		Control.MOUSE_FILTER_IGNORE
	)

	visible = true
	modulate.a = 1.0

	scanner_status.modulate.a = 0.0

	set_process(false)
	queue_redraw()


func _process(delta: float) -> void:
	if not scan_running:
		return

	pulse_time += delta
	queue_redraw()


# ============================================================
# FLUX PRINCIPAL DE L’ESCÀNER

func start_scan() -> void:
	if scan_running:
		return

	if subject.texture == null:
		push_error(
			"HumanTexture no té cap textura assignada."
		)
		return

	scan_running = true

	scan_progress = 0.0
	scanner_alpha = 0.0
	pulse_time = 0.0

	visible = true
	set_process(true)

	_position_status_label()

	# Cada escaneig comença en cian.
	scanner_status.add_theme_color_override(
		"font_color",
		BRIGHT_CYAN
	)

	# ========================================================
	# 1. CALIBRATGE

	scanner_status.text = (
		"CALIBRATING BIOLOGICAL MODEL"
	)

	var entrance_tween: Tween = create_tween()
	entrance_tween.set_parallel(true)

	entrance_tween.tween_method(
		_set_scanner_alpha,
		0.0,
		1.0,
		0.22
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_OUT
	)

	entrance_tween.tween_property(
		scanner_status,
		"modulate:a",
		1.0,
		0.20
	)

	await entrance_tween.finished

	await get_tree().create_timer(
		0.38
	).timeout

	# ========================================================
	# 2. PRIMERA PASSADA

	scanner_status.text = (
		"CORRELATING MUTATIONS AND PHENOTYPE"
	)

	var first_pass: Tween = create_tween()

	first_pass.tween_method(
		_set_scan_progress,
		0.0,
		1.0,
		1.10
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	await first_pass.finished

	# ========================================================
	# 3. PASSADA DE RETORN

	scanner_status.text = (
		"ASSESSING BENEFITS AND RISKS"
	)

	var return_pass: Tween = create_tween()

	return_pass.tween_method(
		_set_scan_progress,
		1.0,
		0.0,
		0.72
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	await return_pass.finished

	# ========================================================
	# 4. GENERACIÓ DE L’INFORME

	scanner_status.text = (
		"GENERATING TECHNICAL REPORT"
	)

	await get_tree().create_timer(
		0.48
	).timeout

	# ========================================================
	# 5. FINAL

	scanner_status.text = (
		"ANALYSIS COMPLETE"
	)

	scanner_status.add_theme_color_override(
		"font_color",
		GREEN
	)

	await get_tree().create_timer(
		0.55
	).timeout

	var exit_tween: Tween = create_tween()
	exit_tween.set_parallel(true)

	exit_tween.tween_method(
		_set_scanner_alpha,
		1.0,
		0.0,
		0.28
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN
	)

	exit_tween.tween_property(
		scanner_status,
		"modulate:a",
		0.0,
		0.24
	)

	await exit_tween.finished

	scan_running = false
	set_process(false)

	queue_redraw()

	scan_finished.emit()


# ============================================================
# ACTUALITZACIÓ DE VARIABLES ANIMADES

func _set_scan_progress(value: float) -> void:
	scan_progress = value
	queue_redraw()


func _set_scanner_alpha(value: float) -> void:
	scanner_alpha = value
	queue_redraw()


# ============================================================
# POSICIÓ DEL TEXT

func _position_status_label() -> void:
	var subject_rect: Rect2 = _get_subject_rect()

	scanner_status.size = Vector2(
		320.0,
		28.0
	)

	var target_y: float = max(
		subject_rect.position.y - 40.0,
		34.0
	)

	scanner_status.position = Vector2(
		subject_rect.get_center().x
			- scanner_status.size.x / 2.0,
		target_y
	)


# ============================================================
# MOVIMENT INDEPENDENT DE LES LÍNIES

func _get_ping_pong_progress(
	speed: float,
	phase: float
) -> float:
	var raw_progress: float = fposmod(
		pulse_time * speed + phase,
		2.0
	)

	if raw_progress <= 1.0:
		return raw_progress

	return 2.0 - raw_progress


# ============================================================
# RECTANGLE REAL DEL PERSONATGE

func _get_subject_rect() -> Rect2:
	var texture_size: Vector2 = (
		subject.texture.get_size()
	)

	var displayed_size: Vector2 = Vector2(
		texture_size.x * abs(subject.global_scale.x),
		texture_size.y * abs(subject.global_scale.y)
	)

	var global_top_left: Vector2 = (
		subject.global_position
		- displayed_size / 2.0
	)

	var local_top_left: Vector2 = (
		get_global_transform_with_canvas()
			.affine_inverse()
			* global_top_left
	)

	return Rect2(
		local_top_left,
		displayed_size
	)


# ============================================================
# DIBUIX GENERAL

func _draw() -> void:
	if scanner_alpha <= 0.001:
		return

	if subject.texture == null:
		return

	var subject_rect: Rect2 = (
		_get_subject_rect()
	)

	# Marc una mica més ample que el cos.
	var frame_rect: Rect2 = (
		subject_rect.grow(18.0)
	)

	# Evita que el marc envaeixi els textos superiors
	# o surti per la zona inferior del panell.
	var top_limit: float = 78.0
	var bottom_limit: float = size.y - 22.0

	if frame_rect.position.y < top_limit:
		var top_difference: float = (
			top_limit - frame_rect.position.y
		)

		frame_rect.position.y = top_limit
		frame_rect.size.y -= top_difference

	if frame_rect.end.y > bottom_limit:
		frame_rect.size.y = (
			bottom_limit
			- frame_rect.position.y
		)

	_draw_corner_frame(
		frame_rect
	)

	_draw_scan_lines(
		subject_rect
	)

	_draw_reticles(
		subject_rect
	)

	_draw_side_readouts(
		frame_rect
	)


# ============================================================
# MARC DE CANTONADES

func _draw_corner_frame(
	frame_rect: Rect2
) -> void:
	var corner_length: float = 26.0
	var width: float = 2.0

	var frame_color: Color = Color(
		CYAN.r,
		CYAN.g,
		CYAN.b,
		0.72 * scanner_alpha
	)

	var top_left: Vector2 = (
		frame_rect.position
	)

	var top_right: Vector2 = Vector2(
		frame_rect.end.x,
		frame_rect.position.y
	)

	var bottom_left: Vector2 = Vector2(
		frame_rect.position.x,
		frame_rect.end.y
	)

	var bottom_right: Vector2 = (
		frame_rect.end
	)

	# Superior esquerra.
	draw_line(
		top_left,
		top_left + Vector2(
			corner_length,
			0.0
		),
		frame_color,
		width
	)

	draw_line(
		top_left,
		top_left + Vector2(
			0.0,
			corner_length
		),
		frame_color,
		width
	)

	# Superior dreta.
	draw_line(
		top_right,
		top_right + Vector2(
			-corner_length,
			0.0
		),
		frame_color,
		width
	)

	draw_line(
		top_right,
		top_right + Vector2(
			0.0,
			corner_length
		),
		frame_color,
		width
	)

	# Inferior esquerra.
	draw_line(
		bottom_left,
		bottom_left + Vector2(
			corner_length,
			0.0
		),
		frame_color,
		width
	)

	draw_line(
		bottom_left,
		bottom_left + Vector2(
			0.0,
			-corner_length
		),
		frame_color,
		width
	)

	# Inferior dreta.
	draw_line(
		bottom_right,
		bottom_right + Vector2(
			-corner_length,
			0.0
		),
		frame_color,
		width
	)

	draw_line(
		bottom_right,
		bottom_right + Vector2(
			0.0,
			-corner_length
		),
		frame_color,
		width
	)


# ============================================================
# LÍNIES D’ESCANEIG

func _draw_scan_lines(
	subject_rect: Rect2
) -> void:
	# Línia principal, controlada directament
	# per les fases de start_scan().
	var main_scan_y: float = lerp(
		subject_rect.position.y,
		subject_rect.end.y,
		scan_progress
	)

	_draw_scanner_line(
		subject_rect,
		main_scan_y,
		1.0,
		2.0,
		24.0
	)

	# Línies auxiliars independents.
	var auxiliary_progresses: Array[float] = [
		_get_ping_pong_progress(
			0.38,
			0.12
		),
		_get_ping_pong_progress(
			0.57,
			0.73
		),
		_get_ping_pong_progress(
			0.81,
			1.36
		)
	]

	var auxiliary_alphas: Array[float] = [
		0.34,
		0.26,
		0.20
	]

	var auxiliary_widths: Array[float] = [
		1.2,
		1.0,
		1.0
	]

	var auxiliary_extensions: Array[float] = [
		15.0,
		9.0,
		19.0
	]

	for index: int in range(
		auxiliary_progresses.size()
	):
		var line_y: float = lerp(
			subject_rect.position.y,
			subject_rect.end.y,
			auxiliary_progresses[index]
		)

		_draw_scanner_line(
			subject_rect,
			line_y,
			auxiliary_alphas[index],
			auxiliary_widths[index],
			auxiliary_extensions[index]
		)

	# Línies anatòmiques de referència.
	var reference_positions: Array[float] = [
		0.22,
		0.48,
		0.72
	]

	for progress: float in reference_positions:
		var reference_y: float = lerp(
			subject_rect.position.y,
			subject_rect.end.y,
			progress
		)

		draw_line(
			Vector2(
				subject_rect.position.x - 7.0,
				reference_y
			),
			Vector2(
				subject_rect.end.x + 7.0,
				reference_y
			),
			Color(
				CYAN.r,
				CYAN.g,
				CYAN.b,
				0.09 * scanner_alpha
			),
			1.0
		)


func _draw_scanner_line(
	subject_rect: Rect2,
	line_y: float,
	line_alpha: float,
	line_width: float,
	horizontal_extension: float
) -> void:
	# Halo vertical de cada línia.
	for offset: int in range(-4, 5):
		var normalized_distance: float = (
			abs(float(offset)) / 4.0
		)

		var glow_alpha: float = (
			0.10
			* (1.0 - normalized_distance)
			* line_alpha
			* scanner_alpha
		)

		draw_line(
			Vector2(
				subject_rect.position.x
					- horizontal_extension,
				line_y + float(offset)
			),
			Vector2(
				subject_rect.end.x
					+ horizontal_extension,
				line_y + float(offset)
			),
			Color(
				CYAN.r,
				CYAN.g,
				CYAN.b,
				glow_alpha
			),
			1.0
		)

	# Nucli lluminós.
	draw_line(
		Vector2(
			subject_rect.position.x
				- horizontal_extension,
			line_y
		),
		Vector2(
			subject_rect.end.x
				+ horizontal_extension,
			line_y
		),
		Color(
			BRIGHT_CYAN.r,
			BRIGHT_CYAN.g,
			BRIGHT_CYAN.b,
			0.86
				* line_alpha
				* scanner_alpha
		),
		line_width
	)

	# Terminals als extrems.
	var terminal_size: float = 3.0

	draw_line(
		Vector2(
			subject_rect.position.x
				- horizontal_extension,
			line_y - terminal_size
		),
		Vector2(
			subject_rect.position.x
				- horizontal_extension,
			line_y + terminal_size
		),
		Color(
			CYAN.r,
			CYAN.g,
			CYAN.b,
			0.55
				* line_alpha
				* scanner_alpha
		),
		1.0
	)

	draw_line(
		Vector2(
			subject_rect.end.x
				+ horizontal_extension,
			line_y - terminal_size
		),
		Vector2(
			subject_rect.end.x
				+ horizontal_extension,
			line_y + terminal_size
		),
		Color(
			CYAN.r,
			CYAN.g,
			CYAN.b,
			0.55
				* line_alpha
				* scanner_alpha
		),
		1.0
	)


# ============================================================
# RETICLES ANATÒMICS

func _draw_reticles(
	subject_rect: Rect2
) -> void:
	var pulse: float = (
		0.65
		+ sin(pulse_time * 5.0) * 0.20
	)

	var reticle_color: Color = Color(
		CYAN.r,
		CYAN.g,
		CYAN.b,
		pulse * scanner_alpha
	)

	var reticle_positions: Array[Vector2] = [
		Vector2(
			subject_rect.get_center().x,
			lerp(
				subject_rect.position.y,
				subject_rect.end.y,
				0.20
			)
		),
		Vector2(
			subject_rect.get_center().x,
			lerp(
				subject_rect.position.y,
				subject_rect.end.y,
				0.45
			)
		),
		Vector2(
			subject_rect.get_center().x,
			lerp(
				subject_rect.position.y,
				subject_rect.end.y,
				0.68
			)
		)
	]

	for center: Vector2 in reticle_positions:
		draw_arc(
			center,
			8.0,
			0.0,
			TAU,
			24,
			reticle_color,
			1.5
		)

		draw_line(
			center + Vector2(-12.0, 0.0),
			center + Vector2(-5.0, 0.0),
			reticle_color,
			1.0
		)

		draw_line(
			center + Vector2(5.0, 0.0),
			center + Vector2(12.0, 0.0),
			reticle_color,
			1.0
		)

		draw_line(
			center + Vector2(0.0, -12.0),
			center + Vector2(0.0, -5.0),
			reticle_color,
			1.0
		)

		draw_line(
			center + Vector2(0.0, 5.0),
			center + Vector2(0.0, 12.0),
			reticle_color,
			1.0
		)


# ============================================================
# LECTURES LATERALS

func _draw_side_readouts(
	frame_rect: Rect2
) -> void:
	var readout_color: Color = Color(
		CYAN.r,
		CYAN.g,
		CYAN.b,
		0.38 * scanner_alpha
	)

	var left_x: float = (
		frame_rect.position.x - 18.0
	)

	var right_x: float = (
		frame_rect.end.x + 18.0
	)

	for index: int in range(5):
		var y_position: float = (
			frame_rect.position.y
			+ 30.0
			+ float(index) * 19.0
		)

		draw_line(
			Vector2(
				left_x - 14.0,
				y_position
			),
			Vector2(
				left_x,
				y_position
			),
			readout_color,
			1.0
		)

		draw_line(
			Vector2(
				right_x,
				y_position
			),
			Vector2(
				right_x
					+ 14.0
					+ float(index % 2) * 8.0,
				y_position
			),
			readout_color,
			1.0
		)
