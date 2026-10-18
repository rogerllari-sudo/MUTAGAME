extends Area2D


@onready var hover_light: Sprite2D = $HoverLight

var hover_tween: Tween


func _ready() -> void:
	var shader_material: ShaderMaterial = (
		hover_light.material as ShaderMaterial
	)

	shader_material.set_shader_parameter(
		"intensity",
		0.0
	)

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	animate_glow(1.0)


func _on_mouse_exited() -> void:
	animate_glow(0.0)


func animate_glow(target_intensity: float) -> void:
	if hover_tween != null and hover_tween.is_valid():
		hover_tween.kill()

	var shader_material: ShaderMaterial = (
		hover_light.material as ShaderMaterial
	)

	var current_intensity: float = float(
		shader_material.get_shader_parameter(
			"intensity"
		)
	)

	hover_tween = create_tween()

	hover_tween.tween_method(
		func(value: float) -> void:
			shader_material.set_shader_parameter(
				"intensity",
				value
			),
		current_intensity,
		target_intensity,
		0.20
	).set_trans(
		Tween.TRANS_QUINT
	).set_ease(
		Tween.EASE_OUT
	)
	
