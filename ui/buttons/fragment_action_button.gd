extends Button


@onready var red_frame: Control = $RedFrame
@onready var red_glow: Control = $RedGlow
@onready var action_chevrons: Label = $ActionChevrons

var interaction_tween: Tween

const NORMAL_FRAME_COLOR := Color("#B86B16")
const HOVER_FRAME_COLOR := Color("#E69F00")
const PRESSED_FRAME_COLOR := Color("#FFF0D6")

const NORMAL_TEXT_COLOR := Color("#B86B16")
const HOVER_TEXT_COLOR := Color("#E69F00")
const PRESSED_TEXT_COLOR := Color("#FFF0D6")


func _ready() -> void:
	# L’escala es farà des del centre del botó.
	pivot_offset = size / 2.0

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	red_glow.modulate.a = 0.12

	_apply_visual_state(
		NORMAL_FRAME_COLOR,
		NORMAL_TEXT_COLOR,
		Vector2.ONE
	)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		pivot_offset = size / 2.0


func _on_mouse_entered() -> void:
	if disabled:
		return

	
	_animate_visual_state(
		HOVER_FRAME_COLOR,
		HOVER_TEXT_COLOR,
		Vector2(1.035, 1.035),
		0.14
	)
	_animate_glow(0.55, 0.14)

func _on_mouse_exited() -> void:
	if disabled:
		return

	_animate_visual_state(
		NORMAL_FRAME_COLOR,
		NORMAL_TEXT_COLOR,
		Vector2.ONE,
		0.16
	)
	_animate_glow(0.12, 0.16)

func _on_button_down() -> void:
	if disabled:
		return

	_animate_visual_state(
		PRESSED_FRAME_COLOR,
		PRESSED_TEXT_COLOR,
		Vector2(0.97, 0.97),
		0.07
	)
	_animate_glow(0.85, 0.07)

func _on_button_up() -> void:
	if disabled:
		return

	var mouse_is_inside: bool = get_global_rect().has_point(
		get_global_mouse_position()
	)

	if mouse_is_inside:
		_animate_visual_state(
			HOVER_FRAME_COLOR,
			HOVER_TEXT_COLOR,
			Vector2(1.035, 1.035),
			0.11
		)
	else:
		_animate_visual_state(
			NORMAL_FRAME_COLOR,
			NORMAL_TEXT_COLOR,
			Vector2.ONE,
			0.11
		)
	
	if mouse_is_inside:
		_animate_glow(0.55, 0.11)
	else:
		_animate_glow(0.12, 0.11)

func _animate_visual_state(
	frame_color: Color,
	text_color: Color,
	target_scale: Vector2,
	duration: float
) -> void:
	if interaction_tween != null and interaction_tween.is_valid():
		interaction_tween.kill()

	interaction_tween = create_tween()
	interaction_tween.set_parallel(true)

	interaction_tween.tween_property(
		self,
		"scale",
		target_scale,
		duration
	).set_trans(
		Tween.TRANS_QUINT
	).set_ease(
		Tween.EASE_OUT
	)

	interaction_tween.tween_method(
		_set_frame_color,
		_get_frame_color(),
		frame_color,
		duration
	)

	interaction_tween.tween_property(
		action_chevrons,
		"modulate",
		text_color,
		duration
	)

	interaction_tween.tween_method(
		_set_button_text_color,
		_get_button_text_color(),
		text_color,
		duration
	)


func _apply_visual_state(
	frame_color: Color,
	text_color: Color,
	target_scale: Vector2
) -> void:
	scale = target_scale
	_set_frame_color(frame_color)
	_set_button_text_color(text_color)
	action_chevrons.modulate = text_color


func _set_frame_color(color: Color) -> void:
	red_frame.set(
		"frame_color",
		color
	)
	red_frame.queue_redraw()


func _get_frame_color() -> Color:
	var current_color: Variant = red_frame.get(
		"frame_color"
	)

	if current_color is Color:
		return current_color

	return NORMAL_FRAME_COLOR


func _set_button_text_color(color: Color) -> void:
	add_theme_color_override(
		"font_color",
		color
	)
	add_theme_color_override(
		"font_hover_color",
		color
	)
	add_theme_color_override(
		"font_pressed_color",
		color
	)


func _get_button_text_color() -> Color:
	return get_theme_color(
		"font_color"
	)

func _animate_glow(
	target_alpha: float,
	duration: float
) -> void:
	var glow_tween: Tween = create_tween()

	glow_tween.tween_property(
		red_glow,
		"modulate:a",
		target_alpha,
		duration
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_OUT
	)
	
