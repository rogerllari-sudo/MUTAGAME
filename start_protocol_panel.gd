extends Control


# ============================================================
# NODES DEL BOTÓ

@onready var start_background: Panel = $StartBackground
@onready var start_glow: Control = $StartGlow
@onready var start_frame: Control = $StartFrame

@onready var start_title: Label = (
	$StartMargin/StartLayout/StartTitle
)

@onready var start_arrow: Label = (
	$StartMargin/StartLayout/ArrowArea/StartArrow
)

@onready var protocol_status: Label = (
	$StartMargin/StartLayout/ProtocolStatus
)

@onready var click_area: Button = $ClickArea


# ============================================================
# ANIMACIÓ HUMÀ → ADN

@onready var human_portrait: TextureRect = (
	$"../../../../SubjectArea/SubjectMargin/SubjectLayout/HumanArea/HumanPortrait"
)

@onready var right_area: Control = $"../../../"

@onready var subject_panel: Control = (
	$"../../../../SubjectArea/SubjectPanel"
)


@onready var zoom_point: Marker2D = (
	$"../../../../SubjectArea/SubjectMargin/SubjectLayout/ZoomPoint"
)

@onready var transition_flash: ColorRect = (
	get_tree().current_scene.get_node("TransitionFlash")
)


# ============================================================
# COLORS

const NORMAL_BACKGROUND := Color("#15212B")
const HOVER_BACKGROUND := Color("#2A586B")
const PRESSED_BACKGROUND := Color("#3A7185")

const NORMAL_FRAME := Color("#39D8FF")
const HOVER_FRAME := Color("#9AFAFF")
const PRESSED_FRAME := Color("#FFFFFF")

const NORMAL_TEXT := Color("#FFFFFF")
const HOVER_TEXT := Color("#FFFFFF")
const PRESSED_TEXT := Color("#FFFFFF")

const NORMAL_STATUS := Color("#66E6FF")
const HOVER_STATUS := Color("#9AFAFF")
const PRESSED_STATUS := Color("#FFFFFF")


# ============================================================
# INTENSITAT DEL GLOW

const NORMAL_GLOW_ALPHA := 0.16
const HOVER_GLOW_ALPHA := 0.82
const PRESSED_GLOW_ALPHA := 1.00


# ============================================================
# VARIABLES

var interaction_tween: Tween
var glow_tween: Tween
var flash_material: ShaderMaterial

var is_hovering: bool = false
var is_transitioning: bool = false


# ============================================================
# INICIALITZACIÓ

func _ready() -> void:
	# El node arrel no ha d'interceptar el ratolí.
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Les capes visuals no han d'interferir amb ClickArea.
	start_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	start_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	start_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# El text tampoc ha d'interceptar el ratolí.
	start_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	start_arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	protocol_status.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# ClickArea cobreix tota la superfície interactiva.
	click_area.mouse_filter = Control.MOUSE_FILTER_STOP
	click_area.mouse_default_cursor_shape = (
		Control.CURSOR_POINTING_HAND
	)

	pivot_offset = size / 2.0
	start_arrow.pivot_offset = start_arrow.size / 2.0

	flash_material = (
		transition_flash.material as ShaderMaterial
	)

	if flash_material == null:
		push_error(
			"TransitionFlash necessita un ShaderMaterial "
			+ "amb radial_transition.gdshader."
		)
		return

	transition_flash.z_index = 1000

	flash_material.set_shader_parameter(
		"progress",
		0.0
	)

	click_area.mouse_entered.connect(
		_on_mouse_entered
	)

	click_area.mouse_exited.connect(
		_on_mouse_exited
	)

	click_area.pressed.connect(
		_on_pressed
	)

	_apply_normal_state()


func _notification(what: int) -> void:
	if what != NOTIFICATION_RESIZED:
		return

	pivot_offset = size / 2.0

	if is_node_ready() and is_instance_valid(start_arrow):
		start_arrow.pivot_offset = start_arrow.size / 2.0


# ============================================================
# ESTAT NORMAL

func _apply_normal_state() -> void:
	_apply_background_style(
		NORMAL_BACKGROUND,
		NORMAL_FRAME,
		Color("#39D8FF40"),
		5
	)

	_apply_frame_color(
		NORMAL_FRAME
	)

	_apply_text_color(
		NORMAL_TEXT,
		NORMAL_STATUS
	)

	_animate_glow(
		NORMAL_GLOW_ALPHA,
		0.18
	)

	_animate_interaction(
		Vector2.ONE,
		Vector2.ONE,
		0.18
	)


# ============================================================
# HOVER

func _on_mouse_entered() -> void:
	if is_transitioning:
		return

	is_hovering = true

	protocol_status.text = "PROTOCOL AVAILABLE"

	_apply_background_style(
		HOVER_BACKGROUND,
		HOVER_FRAME,
		Color("#66E6FFB0"),
		16
	)

	_apply_frame_color(
		HOVER_FRAME
	)

	_apply_text_color(
		HOVER_TEXT,
		HOVER_STATUS
	)

	_animate_glow(
		HOVER_GLOW_ALPHA,
		0.15
	)

	_animate_interaction(
		Vector2(1.018, 1.018),
		Vector2(1.10, 1.10),
		0.15
	)


func _on_mouse_exited() -> void:
	if is_transitioning:
		return

	is_hovering = false

	protocol_status.text = "SEQUENCE READY"

	_apply_normal_state()


# ============================================================
# CLIC

func _on_pressed() -> void:
	if is_transitioning:
		return

	is_transitioning = true
	click_area.disabled = true

	protocol_status.text = "STARTING PROTOCOL"

	_apply_background_style(
		PRESSED_BACKGROUND,
		PRESSED_FRAME,
		Color("#C4FAFFFF"),
		20
	)

	_apply_frame_color(
		PRESSED_FRAME
	)

	_apply_text_color(
		PRESSED_TEXT,
		PRESSED_STATUS
	)

	_animate_glow(
		PRESSED_GLOW_ALPHA,
		0.07
	)

	_animate_interaction(
		Vector2(0.97, 0.97),
		Vector2(0.94, 0.94),
		0.07
	)

	await get_tree().create_timer(0.08).timeout

	_animate_interaction(
		Vector2.ONE,
		Vector2.ONE,
		0.14
	)

	await get_tree().create_timer(0.14).timeout

	await play_subject_zoom_transition()

	get_tree().change_scene_to_file(
		"res://main.tscn"
	)


# ============================================================
# FONS IL·LUMINAT

func _apply_background_style(
	background_color: Color,
	border_color: Color,
	shadow_color: Color,
	shadow_size: int
) -> void:
	var current_style: StyleBox = (
		start_background.get_theme_stylebox("panel")
	)

	if current_style == null:
		push_error(
			"StartBackground no té cap StyleBoxFlat assignat."
		)
		return

	var style: StyleBoxFlat = (
		current_style.duplicate() as StyleBoxFlat
	)

	if style == null:
		push_error(
			"L'estil de StartBackground no és un StyleBoxFlat."
		)
		return

	style.bg_color = background_color
	style.border_color = border_color
	style.shadow_color = shadow_color
	style.shadow_size = shadow_size

	start_background.add_theme_stylebox_override(
		"panel",
		style
	)


# ============================================================
# MARC I GLOW

func _apply_frame_color(color: Color) -> void:
	start_frame.set(
		"frame_color",
		color
	)

	start_frame.queue_redraw()

	start_glow.set(
		"frame_color",
		color
	)

	start_glow.queue_redraw()


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
		start_glow,
		"modulate:a",
		target_alpha,
		duration
	)


# ============================================================
# TEXTOS

func _apply_text_color(
	main_color: Color,
	status_color: Color
) -> void:
	start_title.add_theme_color_override(
		"font_color",
		main_color
	)

	start_arrow.add_theme_color_override(
		"font_color",
		main_color
	)

	protocol_status.add_theme_color_override(
		"font_color",
		status_color
	)


# ============================================================
# ESCALA DEL BOTÓ I DE LA FLETXA

func _animate_interaction(
	target_scale: Vector2,
	arrow_scale: Vector2,
	duration: float
) -> void:
	if (
		interaction_tween != null
		and interaction_tween.is_valid()
	):
		interaction_tween.kill()

	interaction_tween = create_tween()
	interaction_tween.set_parallel(true)

	interaction_tween.set_trans(
		Tween.TRANS_QUINT
	)

	interaction_tween.set_ease(
		Tween.EASE_OUT
	)

	interaction_tween.tween_property(
		self,
		"scale",
		target_scale,
		duration
	)

	interaction_tween.tween_property(
		start_arrow,
		"scale",
		arrow_scale,
		duration
	)


# ============================================================
# ZOOM CAP AL PIT DEL SUBJECTE

func play_subject_zoom_transition() -> void:
	var viewport_size: Vector2 = (
		get_viewport_rect().size
	)

	var screen_center: Vector2 = (
		viewport_size / 2.0
	)

	var texture: Texture2D = human_portrait.texture

	if texture == null:
		push_error(
			"HumanPortrait no té cap textura."
		)
		return

	var texture_size: Vector2 = texture.get_size()

	var display_scale: float = min(
		human_portrait.size.x / texture_size.x,
		human_portrait.size.y / texture_size.y
	)

	var displayed_size: Vector2 = (
		texture_size * display_scale
	)

	var displayed_top_left: Vector2 = (
		human_portrait.global_position
		+ (
			human_portrait.size
			- displayed_size
		) / 2.0
	)

	var zoom_global_position: Vector2 = (
		zoom_point.global_position
	)

	var zoom_actor: Node2D = Node2D.new()

	get_tree().current_scene.add_child(
		zoom_actor
	)

	zoom_actor.global_position = (
		zoom_global_position
	)

	zoom_actor.z_index = 10

	var zoom_sprite: Sprite2D = Sprite2D.new()

	zoom_actor.add_child(
		zoom_sprite
	)

	zoom_sprite.texture = texture
	zoom_sprite.centered = false

	zoom_sprite.scale = Vector2(
		display_scale,
		display_scale
	)

	zoom_sprite.position = (
		displayed_top_left
		- zoom_global_position
	)

	human_portrait.visible = false

	var transition_tween: Tween = create_tween()
	transition_tween.set_parallel(true)

	transition_tween.tween_property(
		right_area,
		"modulate:a",
		0.0,
		0.35
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN
	)

	transition_tween.tween_property(
		subject_panel,
		"modulate:a",
		0.0,
		0.40
	)

	transition_tween.tween_property(
		zoom_actor,
		"global_position",
		screen_center,
		0.90
	).set_trans(
		Tween.TRANS_QUINT
	).set_ease(
		Tween.EASE_IN
	)

	transition_tween.tween_property(
		zoom_actor,
		"scale",
		Vector2(4.5, 4.5),
		0.90
	).set_trans(
		Tween.TRANS_QUINT
	).set_ease(
		Tween.EASE_IN
	)

	await transition_tween.finished

	await play_radial_flash(
		screen_center
	)


# ============================================================
# COBERTURA RADIAL CIÀ

func play_radial_flash(
	origin_global_position: Vector2
) -> void:
	var viewport_size: Vector2 = (
		get_viewport_rect().size
	)

	flash_material.set_shader_parameter(
		"aspect_ratio",
		viewport_size.x / viewport_size.y
	)

	var normalized_center: Vector2 = Vector2(
		origin_global_position.x / viewport_size.x,
		origin_global_position.y / viewport_size.y
	)

	flash_material.set_shader_parameter(
		"center",
		normalized_center
	)

	flash_material.set_shader_parameter(
		"progress",
		0.0
	)

	var flash_tween: Tween = create_tween()

	flash_tween.tween_method(
		func(value: float) -> void:
			flash_material.set_shader_parameter(
				"progress",
				value
			),
		0.0,
		1.0,
		0.42
	).set_trans(
		Tween.TRANS_QUINT
	).set_ease(
		Tween.EASE_IN
	)

	await flash_tween.finished
