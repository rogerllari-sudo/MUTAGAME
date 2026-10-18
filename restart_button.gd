extends Control

@onready var glow: Control = $ReturnGlow
@onready var click_area: Control = $ClickArea


const NORMAL_GLOW_ALPHA := 0.02
const HOVER_GLOW_ALPHA := 0.16
const PRESSED_GLOW_ALPHA := 0.28

var glow_tween: Tween


func _ready() -> void:
	click_area.mouse_entered.connect(_on_mouse_entered)
	click_area.mouse_exited.connect(_on_mouse_exited)
	click_area.gui_input.connect(_on_gui_input)

	# Glow gris-cian, molt menys neó que els botons principals.
	glow.modulate = Color("#78909A")
	glow.modulate.a = NORMAL_GLOW_ALPHA


func _on_mouse_entered() -> void:
	_animate_glow(
		HOVER_GLOW_ALPHA,
		0.20
	)


func _on_mouse_exited() -> void:
	_animate_glow(
		NORMAL_GLOW_ALPHA,
		0.22
	)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		if event.pressed:
			_animate_glow(
				PRESSED_GLOW_ALPHA,
				0.07
			)
		else:
			_restart_game()


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
		glow,
		"modulate:a",
		target_alpha,
		duration
	)


func _restart_game() -> void:
	GameManager.reset_full_game()

	get_tree().change_scene_to_file(
		"res://cover_scene.tscn"
	)
