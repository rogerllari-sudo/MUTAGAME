extends Control


enum StepState {
	INACTIVE,
	ACTIVE,
	COMPLETED
}


@onready var steps: Array[Panel] = [
	$StepDNA,
	$StepRNA,
	$StepProtein,
	$StepPhenotype,
	$StepResult
]

@onready var large_glows: Array[Panel] = [
	$StepDNAGlowLarge,
	$StepRNAGlowLarge,
	$StepProteinGlowLarge,
	$StepPhenotypeGlowLarge,
	$StepResultGlowLarge
]


const INACTIVE_BG := Color("#45E7FF00")
const ACTIVE_BG := Color("#45E7FF0A")
const COMPLETED_BG := Color("#45E7FF05")

const INACTIVE_BORDER := Color("#66E6FF00")
const ACTIVE_BORDER := Color("#B8F9FFFF")
const COMPLETED_BORDER := Color("#66E6FF66")

const INACTIVE_SHADOW := Color("#66E6FF00")
const ACTIVE_SHADOW := Color("#66E6FF66")
const COMPLETED_SHADOW := Color("#66E6FF20")

const LARGE_GLOW_INACTIVE := Color("#66E6FF00")
const LARGE_GLOW_ACTIVE := Color("#66E6FF38")
const LARGE_GLOW_COMPLETED := Color("#66E6FF10")


var step_tweens: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	for index: int in range(steps.size()):
		var step: Panel = steps[index]
		var large_glow: Panel = large_glows[index]

		step.mouse_filter = Control.MOUSE_FILTER_IGNORE
		large_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

		step.pivot_offset = step.size / 2.0
		large_glow.pivot_offset = large_glow.size / 2.0

	set_active_step(
		0,
		false
	)


func set_active_step(
	step_index: int,
	animate: bool = true
) -> void:
	for index: int in range(steps.size()):
		if index < step_index:
			_apply_step_state(
				index,
				StepState.COMPLETED,
				animate
			)

		elif index == step_index:
			_apply_step_state(
				index,
				StepState.ACTIVE,
				animate
			)

		else:
			_apply_step_state(
				index,
				StepState.INACTIVE,
				animate
			)


func complete_all() -> void:
	for index: int in range(steps.size()):
		_apply_step_state(
			index,
			StepState.COMPLETED,
			true
		)


func _apply_step_state(
	step_index: int,
	state: StepState,
	animate: bool
) -> void:
	if step_index < 0 or step_index >= steps.size():
		return

	var step: Panel = steps[step_index]
	var large_glow: Panel = large_glows[step_index]

	var target_bg: Color
	var target_border: Color
	var target_shadow: Color
	var target_shadow_size: int
	var target_scale: Vector2
	var large_glow_color: Color
	var large_glow_shadow_size: int
	var large_glow_scale: Vector2

	match state:
		StepState.INACTIVE:
			target_bg = INACTIVE_BG
			target_border = INACTIVE_BORDER
			target_shadow = INACTIVE_SHADOW
			target_shadow_size = 0
			target_scale = Vector2.ONE

			large_glow_color = LARGE_GLOW_INACTIVE
			large_glow_shadow_size = 0
			large_glow_scale = Vector2.ONE

		StepState.ACTIVE:
			target_bg = ACTIVE_BG
			target_border = ACTIVE_BORDER
			target_shadow = ACTIVE_SHADOW
			target_shadow_size = 6
			target_scale = Vector2(1.10, 1.10)

			large_glow_color = LARGE_GLOW_ACTIVE
			large_glow_shadow_size = 12
			large_glow_scale = Vector2(1.05, 1.05)

		StepState.COMPLETED:
			target_bg = COMPLETED_BG
			target_border = COMPLETED_BORDER
			target_shadow = COMPLETED_SHADOW
			target_shadow_size = 2
			target_scale = Vector2.ONE

			large_glow_color = LARGE_GLOW_COMPLETED
			large_glow_shadow_size = 4
			large_glow_scale = Vector2.ONE

	if not animate:
		_apply_step_style(
			step,
			target_bg,
			target_border,
			target_shadow,
			target_shadow_size
		)

		_apply_large_glow_style(
			large_glow,
			large_glow_color,
			large_glow_shadow_size
		)

		step.scale = target_scale
		large_glow.scale = large_glow_scale
		return

	_animate_step(
		step,
		large_glow,
		target_bg,
		target_border,
		target_shadow,
		target_shadow_size,
		target_scale,
		large_glow_color,
		large_glow_shadow_size,
		large_glow_scale
	)


func _apply_step_style(
	step: Panel,
	bg_color: Color,
	border_color: Color,
	shadow_color: Color,
	shadow_size: int
) -> void:
	var current_style: StyleBox = step.get_theme_stylebox(
		"panel"
	)

	if current_style == null:
		push_error(
			step.name
			+ " no té cap StyleBoxFlat."
		)
		return

	var style: StyleBoxFlat = (
		current_style.duplicate() as StyleBoxFlat
	)

	if style == null:
		push_error(
			step.name
			+ " no utilitza StyleBoxFlat."
		)
		return

	style.bg_color = bg_color
	style.border_color = border_color
	style.shadow_color = shadow_color
	style.shadow_size = shadow_size

	step.add_theme_stylebox_override(
		"panel",
		style
	)


func _apply_large_glow_style(
	large_glow: Panel,
	glow_color: Color,
	shadow_size: int
) -> void:
	var current_style: StyleBox = (
		large_glow.get_theme_stylebox("panel")
	)

	if current_style == null:
		push_error(
			large_glow.name
			+ " no té cap StyleBoxFlat."
		)
		return

	var style: StyleBoxFlat = (
		current_style.duplicate() as StyleBoxFlat
	)

	if style == null:
		push_error(
			large_glow.name
			+ " no utilitza StyleBoxFlat."
		)
		return

	style.bg_color = Color("#45E7FF00")
	style.border_color = glow_color
	style.shadow_color = glow_color
	style.shadow_size = shadow_size

	large_glow.add_theme_stylebox_override(
		"panel",
		style
	)


func _animate_step(
	step: Panel,
	large_glow: Panel,
	bg_color: Color,
	border_color: Color,
	shadow_color: Color,
	shadow_size: int,
	target_scale: Vector2,
	large_glow_color: Color,
	large_glow_shadow_size: int,
	large_glow_scale: Vector2
) -> void:
	if step_tweens.has(step):
		var previous_tween: Tween = (
			step_tweens[step]
		)

		if (
			previous_tween != null
			and previous_tween.is_valid()
		):
			previous_tween.kill()

	var step_current_style: StyleBox = (
		step.get_theme_stylebox("panel")
	)

	var glow_current_style: StyleBox = (
		large_glow.get_theme_stylebox("panel")
	)

	if (
		step_current_style == null
		or glow_current_style == null
	):
		return

	var step_style: StyleBoxFlat = (
		step_current_style.duplicate()
		as StyleBoxFlat
	)

	var glow_style: StyleBoxFlat = (
		glow_current_style.duplicate()
		as StyleBoxFlat
	)

	if step_style == null or glow_style == null:
		return

	step.add_theme_stylebox_override(
		"panel",
		step_style
	)

	large_glow.add_theme_stylebox_override(
		"panel",
		glow_style
	)

	var tween: Tween = create_tween()
	step_tweens[step] = tween

	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		step_style,
		"bg_color",
		bg_color,
		0.20
	)

	tween.tween_property(
		step_style,
		"border_color",
		border_color,
		0.20
	)

	tween.tween_property(
		step_style,
		"shadow_color",
		shadow_color,
		0.20
	)

	tween.tween_property(
		step_style,
		"shadow_size",
		shadow_size,
		0.20
	)

	tween.tween_property(
		step,
		"scale",
		target_scale,
		0.20
	)

	tween.tween_property(
		glow_style,
		"border_color",
		large_glow_color,
		0.22
	)

	tween.tween_property(
		glow_style,
		"shadow_color",
		large_glow_color,
		0.22
	)

	tween.tween_property(
		glow_style,
		"shadow_size",
		large_glow_shadow_size,
		0.22
	)

	tween.tween_property(
		large_glow,
		"scale",
		large_glow_scale,
		0.22
	)
	
