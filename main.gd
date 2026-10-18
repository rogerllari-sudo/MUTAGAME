extends Node2D

const GENE_ALPHA_ICON: Texture2D = preload("res://ui/gene_icons/gene_alpha.png")
const GENE_BETA_ICON: Texture2D = preload("res://ui/gene_icons/gene_beta.png")
const GENE_GAMMA_ICON: Texture2D = preload("res://ui/gene_icons/gene_gamma.png")
const GENE_DELTA_ICON: Texture2D = preload("res://ui/gene_icons/gene_delta.png")
const GENE_EPSILON_ICON: Texture2D = preload("res://ui/gene_icons/gene_epsilon.png")

@onready var fragment_icon: TextureRect = $FragmentWindow/IconArea/IconFrame/IconPlaceholder

@onready var alpha_status: Label = $FragmentProgress/AlphaStatus
@onready var beta_status: Label = $FragmentProgress/BetaStatus
@onready var gamma_status: Label = $FragmentProgress/GammaStatus
@onready var delta_status: Label = $FragmentProgress/DeltaStatus
@onready var epsilon_status: Label = $FragmentProgress/EpsilonStatus

func _ready() -> void:
	$FragmentWindow.visible = false
	update_fragment_progress()

	await get_tree().process_frame

	animate_newly_completed_fragment()

func update_fragment_progress() -> void:
	_update_fragment_status(
		alpha_status,
		GameManager.completed_fragments["alpha"]
	)

	_update_fragment_status(
		beta_status,
		GameManager.completed_fragments["beta"]
	)

	_update_fragment_status(
		gamma_status,
		GameManager.completed_fragments["gamma"]
	)

	_update_fragment_status(
		delta_status,
		GameManager.completed_fragments["delta"]
	)

	_update_fragment_status(
		epsilon_status,
		GameManager.completed_fragments["epsilon"]
	)

func _update_fragment_status(
	label: Label,
	completed: bool
) -> void:

	var tick_icon: TextureRect = label.get_node("TickIcon")

	if completed:
		label.text = ""
		tick_icon.visible = true

		var box := StyleBoxFlat.new()

		box.bg_color = Color("#0072B218")
		box.border_color = Color("#0072B2")
		box.set_border_width_all(1)

		box.corner_radius_top_left = 3
		box.corner_radius_top_right = 3
		box.corner_radius_bottom_left = 3
		box.corner_radius_bottom_right = 3

		label.add_theme_stylebox_override(
			"normal",
			box
		)

	else:
		label.text = ""
		tick_icon.visible = false

		label.remove_theme_stylebox_override(
			"normal"
		)

func open_fragment_window(gene_id: String) -> void:
	GameManager.selected_gene = gene_id

	var gene: Dictionary = GameManager.gene_data[gene_id]

	$FragmentWindow.visible = true

	# Informació principal
	$FragmentWindow/Title.text = gene["name"]
	$FragmentWindow/Function.text = gene["function"]
	$FragmentWindow/Description.text = gene["summary"]

	# Capçalera tècnica
	$FragmentWindow/FragmentID.text = gene["fragment_id"]

	# Icona provisional
	fragment_icon.texture = get_gene_icon(gene_id)

	# Metadades inferiors
	$FragmentWindow/MetadataRow/TypeBlock/TypeValue.text = gene["type"]
	$FragmentWindow/MetadataRow/EffectBlock/EffectValue.text = gene["effect"]
	$FragmentWindow/MetadataRow/ImpactBlock/ImpactValue.text = gene["impact"]

	_update_impact_color(gene["impact"])

func get_gene_icon(gene_id: String) -> Texture2D:
	match gene_id:
		"alpha":
			return GENE_ALPHA_ICON

		"beta":
			return GENE_BETA_ICON

		"gamma":
			return GENE_GAMMA_ICON

		"delta":
			return GENE_DELTA_ICON

		"epsilon":
			return GENE_EPSILON_ICON

	return null

func _update_impact_color(impact: String) -> void:
	var impact_label: Label = (
		$FragmentWindow/MetadataRow/ImpactBlock/ImpactValue
	)

	match impact:
		"CRÍTIC":
			impact_label.add_theme_color_override(
				"font_color",
				Color("#FF3B4F")
			)

		"ALT":
			impact_label.add_theme_color_override(
				"font_color",
				Color("#FF5A4F")
			)

		"MITJÀ":
			impact_label.add_theme_color_override(
				"font_color",
				Color("#F4C542")
			)

		_:
			impact_label.add_theme_color_override(
				"font_color",
				Color("#66E6FF")
			)

#fucions que determinen cada botó corresponent a cada fragment
func _on_gene_1_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		open_fragment_window("alpha")

func _on_gene_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		open_fragment_window("beta")

func _on_gene_3_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		open_fragment_window("gamma")

func _on_gene_4_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		open_fragment_window("delta")

func _on_gene_5_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		open_fragment_window("epsilon")

#botó executar
func _on_modify_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mutation_scene.tscn")

func _on_back_button_pressed() -> void:
	var tween := create_tween()

	tween.tween_property(
		$FragmentWindow,
		"modulate:a",
		0.0,
		0.15
	)

	await tween.finished

	$FragmentWindow.visible = false
	$FragmentWindow.modulate.a = 1.0

#animacions ticks
func animate_newly_completed_fragment() -> void:
	var gene_id: String = GameManager.newly_completed_fragment

	if gene_id == "":
		return

	var target_label: Label

	match gene_id:
		"alpha":
			target_label = alpha_status

		"beta":
			target_label = beta_status

		"gamma":
			target_label = gamma_status

		"delta":
			target_label = delta_status

		"epsilon":
			target_label = epsilon_status

		_:
			return

	_play_completion_animation(target_label)

	# Un cop l'hem animat, esborrem la marca temporal
	GameManager.newly_completed_fragment = ""
	
func _play_completion_animation(label: Label) -> void:
	label.pivot_offset = label.size / 2.0

	label.scale = Vector2(0.75, 0.75)
	label.modulate = Color(1.35, 1.35, 1.35, 0.0)

	var tween := create_tween()

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		label,
		"modulate:a",
		1.0,
		0.12
	)

	tween.parallel().tween_property(
		label,
		"scale",
		Vector2(1.25, 1.25),
		0.20
	)

	tween.tween_property(
		label,
		"scale",
		Vector2.ONE,
		0.18
	)
