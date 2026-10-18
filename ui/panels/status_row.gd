@tool
extends Control

@export_category("Baseline data")

@export var icon_texture: Texture2D:
	set(value):
		icon_texture = value
		_update_row()

@export var parameter_name: String = "PROTECCIÓ RADIACIÓ":
	set(value):
		parameter_name = value
		_update_row()

@export var status_text: String = "BAIXA":
	set(value):
		status_text = value
		_update_row()

@export_range(0, 5, 1) var active_bars: int = 2:
	set(value):
		active_bars = clampi(value, 0, 5)
		_update_row()

@export_category("Post-mutation result")

@export var show_result: bool = false:
	set(value):
		show_result = value
		_update_row()

@export var result_status_text: String = "ALTA":
	set(value):
		result_status_text = value
		_update_row()

@export_range(0, 5, 1) var result_active_bars: int = 4:
	set(value):
		result_active_bars = clampi(value, 0, 5)
		_update_row()
		
@export_category("Colors")

@export var accent_color: Color = Color("#66E6FF"):
	set(value):
		accent_color = value
		_update_row()

@export var result_accent_color: Color = Color(
	0.30,
	1.0,
	0.50,
	1.0
):
	set(value):
		result_accent_color = value
		_update_row()

@export var inactive_bar_color: Color = Color(
	0.08,
	0.20,
	0.27,
	1.0
):
	set(value):
		inactive_bar_color = value
		_update_row()


@onready var icon_rect: TextureRect = $MainLayout/IconArea/Icon
@onready var name_label: Label = $MainLayout/NameLabel

@onready var value_label: Label = $MainLayout/ValueLabel
@onready var level_bars: HBoxContainer = $MainLayout/LevelBars

@onready var compare_spacer: Control = $MainLayout/CompareSpacer
@onready var arrow_label: Label = $MainLayout/ArrowLabel
@onready var result_value_label: Label = $MainLayout/ResultValueLabel
@onready var result_value_spacer: Control = $MainLayout/ResultValueSpacer
@onready var result_level_bars: HBoxContainer = $MainLayout/ResultLevelBars


func _ready() -> void:
	_update_row()


func _update_row() -> void:
	if not is_node_ready():
		return

	icon_rect.texture = icon_texture

	name_label.text = parameter_name
	value_label.text = status_text
	result_value_label.text = result_status_text

	icon_rect.modulate = Color.WHITE

	value_label.add_theme_color_override(
		"font_color",
		accent_color
	)

	arrow_label.add_theme_color_override(
		"font_color",
		Color(0.40, 0.90, 1.0, 1.0)
	)

	result_value_label.add_theme_color_override(
		"font_color",
		result_accent_color
	)

	_set_bar_colors(
		level_bars,
		active_bars,
		accent_color
	)

	_set_bar_colors(
		result_level_bars,
		result_active_bars,
		result_accent_color
	)

	_set_result_visible(show_result)


func _set_bar_colors(
	bars_container: HBoxContainer,
	filled_bars: int,
	active_color: Color
) -> void:
	for index: int in range(bars_container.get_child_count()):
		var bar := bars_container.get_child(index) as ColorRect

		if bar == null:
			continue

		if index < filled_bars:
			bar.color = active_color
		else:
			bar.color = inactive_bar_color


func _set_result_visible(is_visible: bool) -> void:
	compare_spacer.visible = is_visible
	arrow_label.visible = is_visible
	result_value_label.visible = is_visible
	result_value_spacer.visible = is_visible
	result_level_bars.visible = is_visible
	
func flash_result_bar(index: int) -> void:
	if index < 0 or index >= result_level_bars.get_child_count():
		return

	var bar := result_level_bars.get_child(index) as ColorRect

	if bar == null:
		return

	bar.scale = Vector2(1.0, 1.0)

	var tween := create_tween()

	tween.tween_property(
		bar,
		"scale",
		Vector2(1.18, 1.18),
		0.06
	)

	tween.tween_property(
		bar,
		"scale",
		Vector2.ONE,
		0.08
	)
