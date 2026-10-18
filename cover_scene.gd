extends Control


@onready var title_area: Control = $TitleArea
@onready var game_title: Label = $TitleArea/GameTitle
@onready var protocol_title: Label = $TitleArea/ProtocolTitle
@onready var system_label: Label = $TitleArea/SystemLabel
@onready var transition_overlay: ColorRect = $TransitionOverlay


var is_transitioning: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_overlay.modulate.a = 0.0

	_prepare_intro()
	await _play_intro()



func _input(event: InputEvent) -> void:
	if is_transitioning:
		return

	if event is InputEventMouseButton:
		if (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			get_viewport().set_input_as_handled()
			_start_game()


func _prepare_intro() -> void:
	title_area.modulate.a = 0.0
	title_area.scale = Vector2(0.97, 0.97)

	title_area.pivot_offset = (
		title_area.size / 2.0
	)


func _play_intro() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		title_area,
		"modulate:a",
		1.0,
		0.75
	)

	tween.tween_property(
		title_area,
		"scale",
		Vector2.ONE,
		0.90
	)

	await tween.finished


func _start_game() -> void:
	set_process_input(false)
	is_transitioning = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN)

	# El bloc central desapareix lleugerament.
	tween.tween_property(
		title_area,
		"modulate:a",
		0.0,
		0.38
	)

	tween.tween_property(
		title_area,
		"scale",
		Vector2(1.025, 1.025),
		0.38
	)

	# Fosa cap al color base.
	tween.tween_property(
		transition_overlay,
		"modulate:a",
		1.0,
		0.42
	)

	await tween.finished

	get_tree().change_scene_to_file(
		"res://start_scene.tscn"
	)
