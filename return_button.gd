extends Control

@onready var glow: Control = $ReturnGlow
@onready var click_area: Control = $ClickArea


func _ready() -> void:
	click_area.mouse_entered.connect(_on_mouse_entered)
	click_area.mouse_exited.connect(_on_mouse_exited)
	click_area.gui_input.connect(_on_gui_input)

	glow.modulate.a = 0.0


func _on_mouse_entered() -> void:
	var tween := create_tween()

	tween.tween_property(
		glow,
		"modulate:a",
		0.75,
		0.18
	)


func _on_mouse_exited() -> void:
	var tween := create_tween()

	tween.tween_property(
		glow,
		"modulate:a",
		0.0,
		0.18
	)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			_return_to_main()


func _return_to_main() -> void:
	if GameManager.all_fragments_completed():
		get_tree().change_scene_to_file(
			"res://end_scene.tscn"
		)
	else:
		get_tree().change_scene_to_file(
			"res://main.tscn"
		)
