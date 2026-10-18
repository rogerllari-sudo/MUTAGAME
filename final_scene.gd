extends Control


# ============================================================
# REFERÈNCIES DEL BANNER

@onready var banner_glow: Panel = ($FinalUI/ResultBanner/BannerGlow)
@onready var banner_core: Panel = ($FinalUI/ResultBanner/BannerCore)
@onready var top_accent: ColorRect = ($FinalUI/ResultBanner/TopAccent)
@onready var bottom_accent: ColorRect = ($FinalUI/ResultBanner/BottomAccent)
@onready var left_notch: ColorRect = ($FinalUI/ResultBanner/LeftNotch)
@onready var right_notch: ColorRect = ($FinalUI/ResultBanner/RightNotch)
@onready var result_icon: Label = ($FinalUI/ResultBanner/ResultIcon)
@onready var result_title: Label = ($FinalUI/ResultBanner/ResultTitle)
@onready var result_subtitle: Label = ($FinalUI/ResultBanner/ResultSubtitle)
@onready var diagnosis_text: RichTextLabel = ($FinalUI/DiagnosisText)
@onready var icon_frame: Panel = $FinalUI/ResultBanner/IconFrame
@onready var benefit_tick: TextureRect = (
	$FinalUI/ResultBanner/ResultIcon/BenefitTick
)

#----------------
@onready var radiation_row = ($BaselineArea/MedicalMargin/MedicalLayout/DataRows/RadiationRow)
@onready var regeneration_row = ($BaselineArea/MedicalMargin/MedicalLayout/DataRows/RegenerationRow)
@onready var immune_row = ($BaselineArea/MedicalMargin/MedicalLayout/DataRows/ImmuneRow)
@onready var oxidative_row = ($BaselineArea/MedicalMargin/MedicalLayout/DataRows/OxidativeRow)
@onready var genetic_row = ($BaselineArea/MedicalMargin/MedicalLayout/DataRows/GeneticRow)
#----------------
@onready var human: TextureRect = ($FinalUI/SubjectArea/Human)
@onready var hud_frame = ($FinalUI/ResultBanner/HUDFrame)

#requadre del mes important final
@onready var impact_label: Label = (
	$FinalUI/ImpactArea/ImpactLabel
)
@onready var impact_parameter: Label = ($FinalUI/ImpactArea/ImpactParameter)
@onready var impact_before: Label = ($FinalUI/ImpactArea/ImpactBefore)
@onready var impact_after: Label = ($FinalUI/ImpactArea/ImpactAfter)
@onready var impact_arrow: Label = ($FinalUI/ImpactArea/ImpactArrow)
@onready var impact_before_bars: HBoxContainer = (
	$FinalUI/ImpactArea/ImpactBeforeBars
)

@onready var impact_after_bars: HBoxContainer = (
	$FinalUI/ImpactArea/ImpactAfterBars
)
@onready var impact_scan_line: ColorRect = ($FinalUI/ImpactArea/ScanLine)

#nom fragment
@onready var diagnosis_fragment: Label = $FinalUI/DiagnosisFragment
@onready var diagnosis_function: Label = $FinalUI/DiagnosisFunction

# ============================================================
# REFERÈNCIES ANIMACIÓ FINALSCENE

@onready var biological_stats: Control = ($BaselineArea)
@onready var subject_area: Control = ($FinalUI/SubjectArea)
@onready var impact_area: Control = ($FinalUI/ImpactArea)
@onready var recommendation_title: Label = ($FinalUI/RecommendationTitle)
@onready var recommendation_text: RichTextLabel = ($FinalUI/RecommendationText)
@onready var return_panel: Control = ($FinalUI/ReturnPanel)
@onready var result_banner: Control = ($FinalUI/ResultBanner)





# ============================================================
# COLORS

const BENEFICIAL_COLOR := Color("#0072B2")
const NEUTRAL_COLOR := Color("#9E9E9E")
const HARMFUL_COLOR := Color("#D55E00")

const BENEFICIAL_BG := Color("#081A10D9")
const NEUTRAL_BG := Color("#1A1608D9")
const HARMFUL_BG := Color("#1A090CD9")

# ============================================================
# TEXTURES DEL SUBJECTE

const ALPHA_NEUTRAL_TEXTURE := preload(
	"res://characters/alpha_neutral.png"
)

const HUMAN_TEXTURES := {
	"alpha": {
		"BENEFICIOSA": preload("res://characters/alpha_beneficial.png"),
		"PERJUDICIAL": preload("res://characters/alpha_harmful.png")
	},
	"beta": {
		"BENEFICIOSA": preload("res://characters/beta_beneficial.png"),
		"PERJUDICIAL": preload("res://characters/beta_harmful.png")
	},
	"gamma": {
		"BENEFICIOSA": preload("res://characters/gamma_beneficial.png"),
		"PERJUDICIAL": preload("res://characters/gamma_harmful.png")
	},
	"delta": {
		"BENEFICIOSA": preload("res://characters/delta_beneficial.png"),
		"PERJUDICIAL": preload("res://characters/delta_harmful.png")
	},
	"epsilon": {
		"BENEFICIOSA": preload("res://characters/epsilon_beneficial.png"),
		"PERJUDICIAL": preload("res://characters/epsilon_harmful.png")
	}
}
# ============================================================
# INICIALITZACIÓ
func _ready() -> void:
	GameManager.mark_fragment_completed_if_beneficial()
	print(
	"FRAGMENTS COMPLETATS: ",
	GameManager.completed_fragments
	)

	# Només per permetre provar FinalScene directament
	if GameManager.mutation_result == "":
		GameManager.selected_gene = "alpha"
		GameManager.mutation_result = "BENEFICIOSA"

	apply_result_state(
		GameManager.mutation_result
	)

	apply_post_mutation_stats()
	apply_human_texture()
	apply_diagnosis()
	apply_main_impact()
	_update_fragment_info()
	prepare_intro_animation()
	play_intro_animation()

func _update_fragment_info() -> void:
	var gene: Dictionary = GameManager.gene_data[GameManager.selected_gene]

	diagnosis_fragment.text = gene["name"]
	diagnosis_function.text = gene["function"]


# ============================================================
# ESTAT DEL RESULTAT

func apply_result_state(
	result_state: String
) -> void:
	var accent_color: Color
	var background_color: Color
	var icon_text: String
	var title_text: String
	var subtitle_text: String

	match result_state:
		"BENEFICIOSA":
			accent_color = BENEFICIAL_COLOR
			background_color = BENEFICIAL_BG
			icon_text = ""
			benefit_tick.visible = true
			title_text = "BENEFICIAL RESULT"
			subtitle_text = (
				"THE MUTATION HAD A POSITIVE IMPACT ON THE SUBJECT"
			)

		"NEUTRA":
			accent_color = NEUTRAL_COLOR
			background_color = NEUTRAL_BG
			icon_text = "−"
			benefit_tick.visible = false
			title_text = "NEUTRAL RESULT"
			subtitle_text = (
				"THE MUTATION DID NOT PRODUCE SIGNIFICANT CHANGES"
			)

		"PERJUDICIAL":
			accent_color = HARMFUL_COLOR
			background_color = HARMFUL_BG
			icon_text = "×"
			benefit_tick.visible = false
			title_text = "HARMFUL RESULT"
			subtitle_text = (
				"THE MUTATION HAD A NEGATIVE IMPACT ON THE SUBJECT"
			)

		_:
			accent_color = Color("#66E6FF")
			benefit_tick.visible = false
			background_color = Color("#08151BD9")
			icon_text = "?"
			title_text = "UNDEFINED RESULT"
			subtitle_text = (
				"THE RESULT COULD NOT BE CLASSIFIED"
			)

	_apply_banner_style(
		accent_color,
		background_color
	)

	result_icon.text = icon_text
	result_title.text = title_text
	result_subtitle.text = subtitle_text

	result_icon.add_theme_color_override(
		"font_color",
		accent_color
	)

	result_title.add_theme_color_override(
		"font_color",
		accent_color
	)

	result_subtitle.add_theme_color_override(
		"font_color",
		accent_color.lightened(0.35)
	)

# ============================================================
# ANIMACIÓ D'ENTRADA

func prepare_intro_animation() -> void:
	result_banner.modulate.a = 0.0
	result_banner.position.y -= 8

	# El panell queda visible,
	# però les files comencen amagades.
	biological_stats.modulate.a = 1.0

	radiation_row.modulate.a = 0.0
	regeneration_row.modulate.a = 0.0
	immune_row.modulate.a = 0.0
	oxidative_row.modulate.a = 0.0
	genetic_row.modulate.a = 0.0
	
	impact_scan_line.modulate.a = 0.0
	
	# El POST-MUTACIÓ comença buit.
	radiation_row.result_active_bars = 0
	regeneration_row.result_active_bars = 0
	immune_row.result_active_bars = 0
	oxidative_row.result_active_bars = 0
	genetic_row.result_active_bars = 0

	subject_area.modulate.a = 0.0
	subject_area.scale = Vector2(0.96, 0.96)
	diagnosis_text.modulate.a = 0.0
	impact_area.modulate.a = 1.0
	recommendation_title.modulate.a = 0.0
	recommendation_text.modulate.a = 0.0
	return_panel.modulate.a = 0.0

	impact_label.modulate.a = 0.0
	impact_parameter.modulate.a = 0.0
	impact_before.modulate.a = 0.0
	impact_arrow.modulate.a = 0.0
	impact_after.modulate.a = 0.0
	impact_before_bars.modulate.a = 0.0
	impact_after_bars.modulate.a = 0.0

func _set_result_bar_count(
	row,
	bar_count: int
) -> void:
	row.result_active_bars = bar_count

	# El segment que acaba d'encendre's és bar_count - 1
	row.flash_result_bar(
		bar_count - 1
	)

func play_intro_animation() -> void:
	var tween := create_tween()

	tween.set_trans(
		Tween.TRANS_QUAD
	)

	tween.set_ease(
		Tween.EASE_OUT
	)

	# Recuperem els valors finals reals
	var gene: String = GameManager.selected_gene
	var result_state: String = GameManager.mutation_result

	var final_values: Array = (
		GameManager.final_stats[gene][result_state]
	)

	var rows: Array = [
		radiation_row,
		regeneration_row,
		immune_row,
		oxidative_row,
		genetic_row
	]

	# ========================================================
# 1 — BANNER

	var banner_target_y: float = result_banner.position.y + 8.0

	tween.tween_property(
		result_banner,
		"modulate:a",
		1.0,
		0.25
	)

	tween.parallel().tween_property(
		result_banner,
		"position:y",
		banner_target_y,
		0.25
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	tween.tween_interval(0.10)

	banner_glow.modulate.a = 0.35

	tween.tween_property(
		banner_glow,
		"modulate:a",
		0.85,
		0.10
	)

	tween.tween_property(
		banner_glow,
		"modulate:a",
		0.45,
		0.16
	)
	# ========================================================
# 2 — SUBJECTE

	tween.tween_property(
		subject_area,
		"modulate:a",
		1.0,
		0.35
	)

	tween.parallel().tween_property(
		subject_area,
		"scale",
		Vector2(1.02, 1.02),
		0.35
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_OUT
	)

	# Petit settle final
	tween.tween_property(
		subject_area,
		"scale",
		Vector2.ONE,
		0.10
	).set_trans(
		Tween.TRANS_QUAD
	).set_ease(
		Tween.EASE_IN_OUT
	)

# Deixem respirar el subjecte
	tween.tween_interval(
		0.30
	)

	# ========================================================
	# 3 — PARÀMETRES
	# Cada fila:apareix --> calcula POST-MUTACIÓ --> encén les barres una a una

	for index in range(rows.size()):
		var row = rows[index]
		var target_value: int = final_values[index]

		# Apareix la fila
		tween.tween_property(
			row,
			"modulate:a",
			1.0,
			0.16
		)

		# Petita pausa abans del càlcul
		tween.tween_interval(0.05)

		# Encenem cada segment progressivament
		for bar_count in range(1, target_value + 1):
			tween.tween_interval(0.065)

			tween.tween_callback(
				_set_result_bar_count.bind(
					row,
					bar_count
				)
			)

		# Respiració abans de la següent fila
		tween.tween_interval(0.08)

	# ========================================================
	# 4 — PAUSA DESPRÉS DELS RESULTATS

	tween.tween_interval(0.20)

# ========================================================
# 5 — DIAGNÒSTIC

	tween.tween_property(
		diagnosis_text,
		"modulate:a",
		1.0,
		0.32
	)

# Deixem llegir una mica el diagnòstic
	tween.tween_interval(0.18)

# ========================================================
# 6 — SCAN VERTICAL SOBRE IMPACTE PRINCIPAL

	var scan_start_y: float = impact_scan_line.position.y
	var scan_end_y: float = scan_start_y + 90.0

	# Apareix
	tween.tween_callback(
		func():
			impact_scan_line.modulate.a = 1.0
	)

	# Baixa verticalment
	tween.tween_property(
		impact_scan_line,
		"position:y",
		scan_end_y,
		0.30
	).set_trans(
		Tween.TRANS_LINEAR
	)

	# Desapareix
	tween.tween_property(
		impact_scan_line,
		"modulate:a",
		0.0,
		0.10
	)

	# La tornem a la posició inicial
	tween.tween_callback(
		func():
			impact_scan_line.position.y = scan_start_y
	)

	tween.tween_interval(0.05)

# ========================================================
# 7 — IMPACTE PRINCIPAL

# Primer apareix el títol de la secció
	tween.tween_property(
		impact_label,
		"modulate:a",
		1.0,
		0.16
	)

# Després apareix tota la lectura
	tween.tween_property(
		impact_parameter,
		"modulate:a",
		1.0,
		0.20
	)

	tween.parallel().tween_property(
		impact_before,
		"modulate:a",
		1.0,
		0.20
	)

	tween.parallel().tween_property(
		impact_arrow,
		"modulate:a",
		1.0,
		0.20
	)

	tween.parallel().tween_property(
		impact_after,
		"modulate:a",
		1.0,
		0.20
	)

	tween.parallel().tween_property(
		impact_before_bars,
		"modulate:a",
		1.0,
		0.24
	)

	tween.parallel().tween_property(
		impact_after_bars,
		"modulate:a",
		1.0,
		0.24
	)

	tween.tween_interval(0.10)
	# ========================================================
	# 8 — CONSELL

	tween.tween_property(
		recommendation_title,
		"modulate:a",
		1.0,
		0.20
	)

	tween.parallel().tween_property(
		recommendation_text,
		"modulate:a",
		1.0,
		0.25
	)

	tween.tween_interval(0.10)

	# ========================================================
	# 9 — BOTÓ

	tween.tween_property(
		return_panel,
		"modulate:a",
		1.0,
		0.30
	)

# ============================================================
# ESTIL GENERAL DEL BANNER

func _apply_banner_style(
	accent_color: Color,
	background_color: Color
) -> void:
	_apply_panel_style(
		banner_core,
		background_color,
		accent_color,
		8,
		0.28
	)
	hud_frame.accent_color = accent_color

	_apply_panel_style(
		banner_glow,
		Color.TRANSPARENT,
		Color(
			accent_color.r,
			accent_color.g,
			accent_color.b,
			0.32
		),
		12,
		0.34
	)

	top_accent.color = accent_color
	bottom_accent.color = accent_color
	left_notch.color = accent_color
	right_notch.color = accent_color

# ICON FRAME
	var icon_style := icon_frame.get_theme_stylebox("panel").duplicate() as StyleBoxFlat

	icon_style.bg_color = Color(
		accent_color.r,
		accent_color.g,
		accent_color.b,
		0.08
	)

	icon_style.border_color = accent_color

	icon_style.shadow_color = Color(
		accent_color.r,
		accent_color.g,
		accent_color.b,
		0.20
	)

	icon_style.shadow_size = 4

	icon_frame.add_theme_stylebox_override(
		"panel",
		icon_style
	)

# ============================================================
# ESTIL D’UN PANEL

func _apply_panel_style(
	panel: Panel,
	background_color: Color,
	border_color: Color,
	shadow_size: int,
	shadow_alpha: float
) -> void:
	var current_style: StyleBox = (
		panel.get_theme_stylebox("panel")
	)

	if current_style == null:
		push_error(
			panel.name
			+ " no té cap StyleBoxFlat."
		)
		return

	var style: StyleBoxFlat = (
		current_style.duplicate() as StyleBoxFlat
	)

	if style == null:
		push_error(
			panel.name
			+ " no utilitza StyleBoxFlat."
		)
		return

	style.bg_color = background_color
	style.border_color = border_color
	
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8

	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2


	style.shadow_color = Color(
		border_color.r,
		border_color.g,
		border_color.b,
		shadow_alpha
	)

	style.shadow_size = shadow_size

	panel.add_theme_stylebox_override(
		"panel",
		style
	)

func apply_diagnosis() -> void:
	var gene: String = GameManager.selected_gene
	var result_state: String = GameManager.mutation_result

	if not GameManager.gene_data.has(gene):
		diagnosis_text.text = "Fragment data could not be loaded."
		return

	var gene_info: Dictionary = GameManager.gene_data[gene]

	match result_state:
		"BENEFICIOSA":
			diagnosis_text.text = gene_info["success_text"]

		"NEUTRA":
			diagnosis_text.text = gene_info["neutral_text"]

		"PERJUDICIAL":
			diagnosis_text.text = gene_info["failure_text"]

		_:
			diagnosis_text.text = (
				"The impact of the mutation could not be determined."
			)

# ============================================================
# PARÀMETRES BIOLÒGICS POST-MUTACIÓ

func apply_post_mutation_stats() -> void:
	var gene: String = GameManager.selected_gene
	var result_state: String = GameManager.mutation_result

	if not GameManager.final_stats.has(gene):
		push_error("No existeixen dades finals per al gen: " + gene)
		return

	if not GameManager.final_stats[gene].has(result_state):
		push_error(
			"No existeix el resultat "
			+ result_state
			+ " per al gen "
			+ gene
		)
		return

	var values: Array = GameManager.final_stats[gene][result_state]

	var rows = [
		radiation_row,
		regeneration_row,
		immune_row,
		oxidative_row,
		genetic_row
	]

	for index in range(rows.size()):
		var result_value: int = values[index]
		var baseline_value: int = GameManager.baseline_stats[index]

		rows[index].show_result = true

		rows[index].result_active_bars = result_value

		var change_symbol: String = get_change_symbol(
			baseline_value,
			result_value
		)

		rows[index].result_status_text = (
		change_symbol + " " + get_status_text(result_value)
)

		rows[index].result_accent_color = get_result_color(
			baseline_value,
			result_value
		)

func get_change_symbol(
	baseline_value: int,
	result_value: int
) -> String:
	if result_value > baseline_value:
		return "(+)"

	if result_value < baseline_value:
		return "(-)"

	return ""


func get_status_text(value: int) -> String:
	match value:
		0, 1, 2:
			return "LOW"

		3:
			return "NORMAL"

		4, 5:
			return "HIGH"

		_:
			return "NORMAL"

func get_result_color(
	baseline_value: int,
	result_value: int
) -> Color:
	if result_value > baseline_value:
		return BENEFICIAL_COLOR

	if result_value < baseline_value:
		return HARMFUL_COLOR

	return NEUTRAL_COLOR

# ============================================================
# TEXTURA DEL SUBJECTE

func apply_human_texture() -> void:
	var gene: String = GameManager.selected_gene
	var result_state: String = GameManager.mutation_result

	# Cas neutre: sempre fem servir el nen base.
	if result_state == "NEUTRA":
		human.texture = ALPHA_NEUTRAL_TEXTURE
		return

	# Comprovem que existeixi el gen.
	if not HUMAN_TEXTURES.has(gene):
		human.texture = ALPHA_NEUTRAL_TEXTURE
		return

	# Comprovem que existeixi el resultat per aquell gen.
	if not HUMAN_TEXTURES[gene].has(result_state):
		human.texture = ALPHA_NEUTRAL_TEXTURE
		return

	# Assignem la textura correcta.
	human.texture = HUMAN_TEXTURES[gene][result_state]
# ============================================================
# IMPACTE PRINCIPAL

func apply_main_impact() -> void:
	var gene: String = GameManager.selected_gene
	var result_state: String = GameManager.mutation_result

	var parameter_name: String
	var stat_index: int

	match gene:
		"alpha":
			parameter_name = "RADIATION PROTECTION"
			stat_index = 0

		"beta":
			parameter_name = "CELL REGENERATION"
			stat_index = 1

		"gamma":
			parameter_name = "IMMUNE SYSTEM"
			stat_index = 2

		"delta":
			parameter_name = "GENETIC STABILITY"
			stat_index = 4

		"epsilon":
			parameter_name = "ANTIOXIDANT PROTECTION"
			stat_index = 3

		_:
			return

	var baseline_value: int = GameManager.baseline_stats[stat_index]

	var result_value: int = (
		GameManager.final_stats[gene][result_state][stat_index]
	)

	impact_parameter.text = parameter_name

	impact_before.text = get_status_text(
		baseline_value
	)

	impact_after.text = (
		get_change_symbol(baseline_value, result_value)
		+ " "
		+ get_status_text(result_value)
	)

	impact_arrow.text = ">"

	impact_before.add_theme_color_override(
		"font_color",
		Color("#66E6FF")
	)

	impact_arrow.add_theme_color_override(
		"font_color",
		Color("#3FAFC4")
	)

	impact_after.add_theme_color_override(
		"font_color",
		get_result_color(
			baseline_value,
			result_value
		)
	)

	set_impact_bars(
		impact_before_bars,
		baseline_value,
		Color("#66E6FF")
	)

	set_impact_bars(
		impact_after_bars,
		result_value,
		get_result_color(
			baseline_value,
			result_value
		)
	)

	
func set_impact_bars(
	container: HBoxContainer,
	value: int,
	active_color: Color
) -> void:

	var inactive_color := Color("#163744")

	for i in range(container.get_child_count()):
		var bar := container.get_child(i) as ColorRect

		if bar == null:
			continue

		if i < value:
			bar.color = active_color
		else:
			bar.color = inactive_color
