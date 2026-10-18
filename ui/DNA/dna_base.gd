extends Node2D


var base_letter: String = "T"

@onready var glow_hexagon: Polygon2D = $GlowHexagon
@onready var outer_hexagon: Polygon2D = $OuterHexagon
@onready var hexagon: Polygon2D = $Hexagon
@onready var inner_hexagon: Polygon2D = $InnerHexagon

@onready var base_label: Label = $BaseLabel
@onready var damage_line: Line2D = $DamageLine


func _ready() -> void:
	damage_line.visible = false
	update_visual()


func set_base(new_base: String) -> void:
	base_letter = new_base
	update_visual()


func set_damaged(is_damaged: bool) -> void:
	damage_line.visible = is_damaged


func update_visual() -> void:
	base_label.text = base_letter

	var base_color: Color = _get_base_color(base_letter)
	var bright_color: Color = base_color.lightened(0.28)

	# Halo exterior: visible, però sense convertir-se en una taca sòlida
	glow_hexagon.color = Color(
		bright_color.r,
		bright_color.g,
		bright_color.b,
		0.20
	)

	# Contorn principal brillant
	outer_hexagon.color = bright_color

	# Interior acolorit i fosc, però no gairebé negre
	hexagon.color = base_color.darkened(0.42)

	# Aquest quart hexàgon ara embruta més que no pas ajuda
	inner_hexagon.visible = false

	base_label.add_theme_color_override(
		"font_color",
		Color("#F5FDFF")
	)
	


func _get_base_color(letter: String) -> Color:
	match letter:
		"A":
			return Color("#009E73")

		"T":
			return Color("#52B6FF")

		"C":
			return Color("#C084FF")

		"G":
			return Color("#E69F00")

		"X":
			return Color("#3A4450")

		_:
			return Color("#A7B4C0")
