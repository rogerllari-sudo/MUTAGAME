extends Control


enum StageState {
	INACTIVE,
	ACTIVE,
	COMPLETED
}


@onready var stages: Array[Panel] = [
	$Stage01,
	$Stage02,
	$Stage03,
	$Stage04,
	$Stage05
]


const INACTIVE_BG := Color("#45E7FF00")
const ACTIVE_BG := Color("#45E7FF06")
const COMPLETED_BG := Color("#0072B20A")

const INACTIVE_BORDER := Color("#66E6FF00")
const ACTIVE_BORDER := Color("#A0F7FFCC")
const COMPLETED_BORDER := Color("#0072B288")

const INACTIVE_SHADOW := Color("#66E6FF00")
const ACTIVE_SHADOW := Color("#66E6FF44")
const COMPLETED_SHADOW := Color("#0072B228")


var stage_tweens: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	for stage: Panel in stages:
		stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stage.pivot_offset = stage.size / 2.0

		var arrow: Label = stage.get_node("ActiveArrow")
		arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		arrow.visible = false

	set_active_stage(
		0,
		false
	)


func set_active_stage(
	stage_index: int,
	animate: bool = true
) -> void:
	for index: int in range(stages.size()):
		if index < stage_index:
			_apply_stage_state(
				index,
				StageState.COMPLETED,
				animate
			)

		elif index == stage_index:
			_apply_stage_state(
				index,
				StageState.ACTIVE,
				animate
			)

		else:
			_apply_stage_state(
				index,
				StageState.INACTIVE,
				animate
			)


func complete_all() -> void:
	for index: int in range(stages.size()):
		_apply_stage_state(
			index,
			StageState.COMPLETED,
			true
		)


func _apply_stage_state(
	stage_index: int,
	state: StageState,
	animate: bool
) -> void:
	if stage_index < 0 or stage_index >= stages.size():
		return

	var stage: Panel = stages[stage_index]
	var arrow: Label = stage.get_node("ActiveArrow")
	var completed_check: TextureRect = stage.get_node("CompletedCheck")

	var check_visible: bool
	var check_alpha: float
	var target_bg: Color
	var target_border: Color
	var target_shadow: Color
	var target_shadow_size: int
	var target_scale: Vector2
	var arrow_visible: bool
	var arrow_alpha: float

	match state:
		StageState.INACTIVE:
			target_bg = INACTIVE_BG
			target_border = INACTIVE_BORDER
			target_shadow = INACTIVE_SHADOW
			target_shadow_size = 0
			target_scale = Vector2.ONE
			arrow_visible = false
			arrow_alpha = 0.0
			check_visible = false
			check_alpha = 0.0

		StageState.ACTIVE:
			target_bg = ACTIVE_BG
			target_border = ACTIVE_BORDER
			target_shadow = ACTIVE_SHADOW
			target_shadow_size = 5
			target_scale = Vector2(1.006, 1.006)
			arrow_visible = true
			arrow_alpha = 1.0
			check_visible = false
			check_alpha = 0.0
			
		StageState.COMPLETED:
			target_bg = COMPLETED_BG
			target_border = COMPLETED_BORDER
			target_shadow = COMPLETED_SHADOW
			target_shadow_size = 2
			target_scale = Vector2.ONE
			arrow_visible = false
			arrow_alpha = 0.0
			check_visible = true
			check_alpha = 1.0

	arrow.visible = arrow_visible
	completed_check.visible = check_visible

	if not animate:
		_apply_style_immediately(
			stage,
			target_bg,
			target_border,
			target_shadow,
			target_shadow_size
		)
		completed_check.modulate.a = check_alpha
		stage.scale = target_scale
		arrow.modulate.a = arrow_alpha
		return

	_animate_stage(
		stage,
		arrow,
		completed_check,
		target_bg,
		target_border,
		target_shadow,
		target_shadow_size,
		target_scale,
		arrow_alpha,
		check_alpha
	)


func _apply_style_immediately(
	stage: Panel,
	bg_color: Color,
	border_color: Color,
	shadow_color: Color,
	shadow_size: int
) -> void:
	var current_style: StyleBox = stage.get_theme_stylebox(
		"panel"
	)

	if current_style == null:
		push_error(
			stage.name
			+ " no té cap StyleBoxFlat assignat."
		)
		return

	var style: StyleBoxFlat = (
		current_style.duplicate() as StyleBoxFlat
	)

	if style == null:
		push_error(
			stage.name
			+ " no utilitza un StyleBoxFlat."
		)
		return

	style.bg_color = bg_color
	style.border_color = border_color
	style.shadow_color = shadow_color
	style.shadow_size = shadow_size

	stage.add_theme_stylebox_override(
		"panel",
		style
	)


func _animate_stage(
	stage: Panel,
	arrow: Label,
	completed_check: TextureRect,
	bg_color: Color,
	border_color: Color,
	shadow_color: Color,
	shadow_size: int,
	target_scale: Vector2,
	arrow_alpha: float,
	check_alpha: float
) -> void:
	if stage_tweens.has(stage):
		var previous_tween: Tween = stage_tweens[stage]

		if previous_tween != null and previous_tween.is_valid():
			previous_tween.kill()

	var current_style: StyleBox = stage.get_theme_stylebox(
		"panel"
	)

	if current_style == null:
		return

	var style: StyleBoxFlat = (
		current_style.duplicate() as StyleBoxFlat
	)

	if style == null:
		return

	stage.add_theme_stylebox_override(
		"panel",
		style
	)

	var tween: Tween = create_tween()
	stage_tweens[stage] = tween

	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		style,
		"bg_color",
		bg_color,
		0.22
	)

	tween.tween_property(
		style,
		"border_color",
		border_color,
		0.22
	)

	tween.tween_property(
		style,
		"shadow_color",
		shadow_color,
		0.22
	)

	tween.tween_property(
		style,
		"shadow_size",
		shadow_size,
		0.22
	)

	tween.tween_property(
		stage,
		"scale",
		target_scale,
		0.22
	)

	tween.tween_property(
		arrow,
		"modulate:a",
		arrow_alpha,
		0.16
	)
	
	tween.tween_property(
		completed_check,
		"modulate:a",
		check_alpha,
		0.16
	)
	
