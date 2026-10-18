extends Panel

enum State {
	IDLE,
	HOVER,
	SELECTED
}

var current_state = State.IDLE

var tool_id = ""
var tool_name = ""
var tool_description = ""
var tool_icon: Texture2D

var accent_color: Color = Color("#66E6FF")

@onready var card_frame: Control = $CardFrame
@onready var card_glow: Control = $CardGlow
@onready var icon_texture: TextureRect = $Icon

var icon_base_position: Vector2


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	card_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE

	$Icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE

	card_glow.modulate.a = 0.0

	pivot_offset = size / 2.0

	icon_base_position = icon_texture.position

	_make_root_panel_transparent()

	update_visual()


func set_state(new_state) -> void:
	current_state = new_state
	update_visual()


func set_tool(
	id: String,
	display_name: String,
	description: String,
	icon: Texture2D,
	color: Color
) -> void:

	tool_id = id
	tool_name = display_name
	tool_description = description
	tool_icon = icon
	accent_color = color

	$Title.text = tool_name
	$Subtitle.text = tool_description

	icon_texture.texture = tool_icon

	_update_icon_offset()
	update_visual()


func update_visual() -> void:
	var idle_color: Color = accent_color.darkened(0.30)
	var hover_color: Color = accent_color.lightened(0.12)
	var selected_color: Color = accent_color.lightened(0.28)

	match current_state:

		State.IDLE:
			_set_frame_visual(
				idle_color,
				Color("#07101870"),
				0.0
			)

			icon_texture.modulate = Color(
				1.0,
				1.0,
				1.0,
				0.82
			)

			$Title.add_theme_color_override(
				"font_color",
				Color("#EEF7FB")
			)

			$Subtitle.add_theme_color_override(
				"font_color",
				Color("#91A8B8")
			)


		State.HOVER:
			_set_frame_visual(
				hover_color,
				Color(
					accent_color.r * 0.07,
					accent_color.g * 0.07,
					accent_color.b * 0.07,
					0.72
				),
				0.34
			)

			icon_texture.modulate = Color.WHITE

			$Title.add_theme_color_override(
				"font_color",
				hover_color
			)

			$Subtitle.add_theme_color_override(
				"font_color",
				Color("#C7D9E4")
			)


		State.SELECTED:
			_set_frame_visual(
				selected_color,
				Color(
					accent_color.r * 0.10,
					accent_color.g * 0.10,
					accent_color.b * 0.10,
					0.82
				),
				0.62
			)

			icon_texture.modulate = Color.WHITE

			$Title.add_theme_color_override(
				"font_color",
				selected_color
			)

			$Subtitle.add_theme_color_override(
				"font_color",
				Color("#E1F6FA")
			)

	animate_state()


func animate_state() -> void:
	var target_scale := Vector2.ONE

	match current_state:

		State.IDLE:
			target_scale = Vector2.ONE

		State.HOVER:
			target_scale = Vector2(1.018, 1.018)

		State.SELECTED:
			target_scale = Vector2(1.012, 1.012)

	var tween := create_tween()

	tween.set_trans(
		Tween.TRANS_QUINT
	)

	tween.set_ease(
		Tween.EASE_OUT
	)

	tween.tween_property(
		self,
		"scale",
		target_scale,
		0.12
	)


func _on_mouse_entered() -> void:
	if current_state != State.SELECTED:
		set_state(State.HOVER)


func _on_mouse_exited() -> void:
	if current_state != State.SELECTED:
		set_state(State.IDLE)


signal tool_selected(selected_tool)


func _gui_input(event) -> void:
	if event is InputEventMouseButton:
		if (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			set_state(State.SELECTED)
			tool_selected.emit(tool_id)


func _make_root_panel_transparent() -> void:
	var transparent_style := StyleBoxFlat.new()

	transparent_style.bg_color = Color.TRANSPARENT

	transparent_style.border_width_left = 0
	transparent_style.border_width_top = 0
	transparent_style.border_width_right = 0
	transparent_style.border_width_bottom = 0

	transparent_style.shadow_size = 0

	add_theme_stylebox_override(
		"panel",
		transparent_style
	)


func _set_frame_visual(
	color: Color,
	fill: Color,
	glow_alpha: float
) -> void:

	card_frame.set(
		"frame_color",
		color
	)

	card_frame.set(
		"fill_color",
		fill
	)

	card_frame.set(
		"detail_color",
		Color(
			color.r,
			color.g,
			color.b,
			0.38
		)
	)

	card_frame.queue_redraw()

	card_glow.set(
		"frame_color",
		color
	)

	card_glow.queue_redraw()

	var glow_tween: Tween = create_tween()

	glow_tween.set_trans(
		Tween.TRANS_SINE
	)

	glow_tween.set_ease(
		Tween.EASE_OUT
	)

	glow_tween.tween_property(
		card_glow,
		"modulate:a",
		glow_alpha,
		0.14
	)


func _update_icon_offset() -> void:
	icon_texture.position = icon_base_position

	match tool_id:

		"IR":
			icon_texture.position += Vector2(0, 0)

		"UV":
			icon_texture.position += Vector2(0, 0)

		"INTERCALAR":
			icon_texture.position += Vector2(2, 0)

		"VIRUS":
			icon_texture.position += Vector2(2, -1)
