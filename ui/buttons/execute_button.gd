extends Control

signal pressed


@onready var background: Panel = $Background
@onready var execute_glow: Control = $ExecuteGlow
@onready var execute_frame: Control = $ExecuteFrame
@onready var label: Label = $Label


# ============================================================
# COLORS DEL BOTÓ

const NORMAL_BACKGROUND := Color("#15212B")
const HOVER_BACKGROUND := Color("#234757")
const PRESSED_BACKGROUND := Color("#315F70")

const NORMAL_BORDER := Color("#39D8FF")
const HOVER_BORDER := Color("#8AF2FF")
const PRESSED_BORDER := Color("#FFFFFF")

const NORMAL_TEXT := Color("#FFFFFF")
const HOVER_TEXT := Color("#F2FDFF")
const PRESSED_TEXT := Color("#FFFFFF")


# ============================================================
# INTENSITAT DEL GLOW EXTERIOR

const NORMAL_GLOW_ALPHA := 0.10
const HOVER_GLOW_ALPHA := 0.52
const PRESSED_GLOW_ALPHA := 0.82


var scale_tween: Tween
var glow_tween: Tween

var is_hovering: bool = false
var is_pressing: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	execute_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	execute_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	pivot_offset = size / 2.0

	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_leave)

	_apply_normal_state()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		pivot_offset = size / 2.0


# ============================================================
# HOVER

func _on_hover() -> void:
	is_hovering = true

	if is_pressing:
		return

	_apply_background_style(
		HOVER_BACKGROUND,
		HOVER_BORDER,
		Color("#66E6FF70"),
		10
	)

	_apply_frame_color(
		HOVER_BORDER
	)

	_apply_text_color(
		HOVER_TEXT
	)

	_animate_glow(
		HOVER_GLOW_ALPHA,
		0.16
	)

	_animate_scale(
		Vector2(1.018, 1.018),
		0.16
	)


func _on_leave() -> void:
	is_hovering = false

	if is_pressing:
		return

	_apply_normal_state()


# ============================================================
# CLIC

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		if event.pressed:
			_on_pressed_visual()
		else:
			_on_released_visual()


func _on_pressed_visual() -> void:
	is_pressing = true

	_apply_background_style(
		PRESSED_BACKGROUND,
		PRESSED_BORDER,
		Color("#C4FAFF99"),
		13
	)

	_apply_frame_color(
		PRESSED_BORDER
	)

	_apply_text_color(
		PRESSED_TEXT
	)

	_animate_glow(
		PRESSED_GLOW_ALPHA,
		0.07
	)

	_animate_scale(
		Vector2(0.975, 0.975),
		0.07
	)


func _on_released_visual() -> void:
	is_pressing = false

	if is_hovering:
		_apply_background_style(
			HOVER_BACKGROUND,
			HOVER_BORDER,
			Color("#66E6FF70"),
			10
		)

		_apply_frame_color(
			HOVER_BORDER
		)

		_apply_text_color(
			HOVER_TEXT
		)

		_animate_glow(
			HOVER_GLOW_ALPHA,
			0.11
		)

		_animate_scale(
			Vector2(1.018, 1.018),
			0.11
		)

		pressed.emit()

	else:
		_apply_normal_state()


# ============================================================
# ESTAT NORMAL

func _apply_normal_state() -> void:
	_apply_background_style(
		NORMAL_BACKGROUND,
		NORMAL_BORDER,
		Color("#39D8FF30"),
		4
	)

	_apply_frame_color(
		NORMAL_BORDER
	)

	_apply_text_color(
		NORMAL_TEXT
	)

	_animate_glow(
		NORMAL_GLOW_ALPHA,
		0.18
	)

	_animate_scale(
		Vector2.ONE,
		0.18
	)


# ============================================================
# FONS I GLOW GENERAL

func _apply_background_style(
	bg_color: Color,
	border_color: Color,
	shadow_color: Color,
	shadow_size: int
) -> void:
	var current_style: StyleBox = background.get_theme_stylebox(
		"panel"
	)

	if current_style == null:
		push_warning(
			"Background no té cap StyleBox assignat."
		)
		return

	var style: StyleBoxFlat = (
		current_style.duplicate() as StyleBoxFlat
	)

	if style == null:
		push_warning(
			"L'estil de Background no és un StyleBoxFlat."
		)
		return

	style.bg_color = bg_color
	style.border_color = border_color
	style.shadow_color = shadow_color
	style.shadow_size = shadow_size

	background.add_theme_stylebox_override(
		"panel",
		style
	)


# ============================================================
# MARC EXTERIOR

func _apply_frame_color(color: Color) -> void:
	execute_frame.set(
		"frame_color",
		color
	)

	execute_frame.queue_redraw()


# ============================================================
# TEXT

func _apply_text_color(color: Color) -> void:
	label.add_theme_color_override(
		"font_color",
		color
	)


# ============================================================
# ANIMACIONS

func _animate_scale(
	target_scale: Vector2,
	duration: float
) -> void:
	if scale_tween != null and scale_tween.is_valid():
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_QUINT)
	scale_tween.set_ease(Tween.EASE_OUT)

	scale_tween.tween_property(
		self,
		"scale",
		target_scale,
		duration
	)


func _animate_glow(
	target_alpha: float,
	duration: float
) -> void:
	if glow_tween != null and glow_tween.is_valid():
		glow_tween.kill()

	glow_tween = create_tween()
	glow_tween.set_trans(Tween.TRANS_SINE)
	glow_tween.set_ease(Tween.EASE_OUT)

	glow_tween.tween_property(
		execute_glow,
		"modulate:a",
		target_alpha,
		duration
	)
