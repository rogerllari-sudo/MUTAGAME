extends Area2D


@onready var hover_glow: Polygon2D = $HoverGlow

var hover_tween: Tween


func _ready() -> void:
	hover_glow.modulate.a = 0.0

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	if hover_tween != null and hover_tween.is_valid():
		hover_tween.kill()

	hover_tween = create_tween()

	hover_tween.tween_property(
		hover_glow,
		"modulate:a",
		0.42,
		0.16
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_OUT
	)


func _on_mouse_exited() -> void:
	if hover_tween != null and hover_tween.is_valid():
		hover_tween.kill()

	hover_tween = create_tween()

	hover_tween.tween_property(
		hover_glow,
		"modulate:a",
		0.0,
		0.18
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_OUT
	)
