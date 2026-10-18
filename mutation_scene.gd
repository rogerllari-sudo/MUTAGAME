extends Node2D

@onready var toolbar_panel = $UI/ToolbarFrame/ToolbarPanel

@onready var ir_card = toolbar_panel.get_node("IRCard")
@onready var uv_card = toolbar_panel.get_node("UVCard")
@onready var intercalar_card = toolbar_panel.get_node("IntercalarCard")
@onready var virus_card = toolbar_panel.get_node("VirusCard")
@onready var scan_line: ColorRect = $DNAPanelArt/ScanLine
@onready var scan_glow: ColorRect = $DNAPanelArt/ScanGlow
@onready var analysis_status: Label = $DNAPanelArt/AnalysisStatus
@onready var analysis_status_bg: Panel = $DNAPanelArt/AnalysisStatusBackground
@onready var execute_button = $UI/ExecuteButton
var is_analyzing := false

@onready var undo_button = $UI/UndoButton
var action_history: Array[int] = []

const IR_ICON: Texture2D = preload(
	"res://ui/toolcards/tool_ir.png"
)

const UV_ICON: Texture2D = preload(
	"res://ui/toolcards/tool_uv.png"
)

const INTERCALAR_ICON: Texture2D = preload(
	"res://ui/toolcards/tool_intercalar.png"
)

const VIRUS_ICON: Texture2D = preload(
	"res://ui/toolcards/tool_virus.png"
)

@onready var base_pairs: Array = [
	$DNAPanelArt/DNAFragment/BasePair1,
	$DNAPanelArt/DNAFragment/BasePair2,
	$DNAPanelArt/DNAFragment/BasePair3,
	$DNAPanelArt/DNAFragment/BasePair4,
	$DNAPanelArt/DNAFragment/BasePair5,
	$DNAPanelArt/DNAFragment/BasePair6,
	$DNAPanelArt/DNAFragment/BasePair7,
	$DNAPanelArt/DNAFragment/BasePair8
]

func _ready():
	print("Laboratori carregat")
	print("Gen seleccionat: " + GameManager.selected_gene)

	var gene = GameManager.gene_data[GameManager.selected_gene]
	$UI/GeneInfoPanel/FragmentTitle.text = gene["name"]
	$UI/GeneInfoPanel/FragmentLabel.text = gene["description"]
	set_conservation_bars(gene["conservation_level"])
	$UI/GeneInfoPanel/HintLabel.text = gene["hint"]
	$UI/GeneInfoPanel/RecommendedMutation.text = mutation_to_text(
		gene["recommended_mutations"][0]
	).to_upper()
	
	#reset de les eines/mutacions
	GameManager.selected_tool = ""
	GameManager.mutations.clear()

	ir_card.set_tool(
		"IR",
		"IR",
		"Ionizing rad.",
		IR_ICON,
		Color("#E69F00")
	)

	uv_card.set_tool(
		"UV",
		"UV",
		"Ultraviolet rad.",
		UV_ICON,
		Color("#CC79A7")
	)

	intercalar_card.set_tool(
		"INTERCALAR",
		"INTERC.",
		"Chemical agent",
		INTERCALAR_ICON,
		Color("#56B4E9")
	)

	virus_card.set_tool(
		"VIRUS",
		"VIRUS",
		"Biological agent",
		VIRUS_ICON,
		Color("#E6E6E6")
	)

	ir_card.tool_selected.connect(_on_tool_card_selected)
	uv_card.tool_selected.connect(_on_tool_card_selected)
	intercalar_card.tool_selected.connect(_on_tool_card_selected)
	virus_card.tool_selected.connect(_on_tool_card_selected)

	$DNAPanelArt/DNAFragment/BasePair1.reset_pair()
	$DNAPanelArt/DNAFragment/BasePair2.reset_pair()
	$DNAPanelArt/DNAFragment/BasePair3.reset_pair()
	$DNAPanelArt/DNAFragment/BasePair4.reset_pair()
	$DNAPanelArt/DNAFragment/BasePair5.reset_pair()
	$DNAPanelArt/DNAFragment/BasePair6.reset_pair()
	$DNAPanelArt/DNAFragment/BasePair7.reset_pair()
	$DNAPanelArt/DNAFragment/BasePair8.reset_pair()
	
	load_gene_sequence()
	scan_line.visible = false
	scan_glow.visible = false
	analysis_status.visible = false
	analysis_status_bg.visible = false

	execute_button.pressed.connect(_on_execute_button_pressed)

	undo_button.pressed.connect(_on_undo_button_pressed)

	action_history.clear()
	update_undo_button()

func set_conservation_bars(level: int) -> void:
	var bars: HBoxContainer = $UI/GeneInfoPanel/ConservationBars

	for i in range(bars.get_child_count()):
		var bar := bars.get_child(i) as ColorRect

		if bar == null:
			continue

		if i < level:
			bar.color = Color("#66E6FF")
		else:
			bar.color = Color("#163744")

func select_tool(tool_name: String):
	GameManager.selected_tool = tool_name
	print("Eina seleccionada: " + GameManager.selected_tool)

func reset_tool_cards():
	ir_card.set_state(ir_card.State.IDLE)
	uv_card.set_state(uv_card.State.IDLE)
	intercalar_card.set_state(intercalar_card.State.IDLE)
	virus_card.set_state(virus_card.State.IDLE)

func _on_tool_card_selected(tool_name):
	reset_tool_cards()

	if tool_name == "IR":
		ir_card.set_state(ir_card.State.SELECTED)
	elif tool_name == "UV":
		uv_card.set_state(uv_card.State.SELECTED)
	elif tool_name == "INTERCALAR":
		intercalar_card.set_state(intercalar_card.State.SELECTED)
	elif tool_name == "VIRUS":
		virus_card.set_state(virus_card.State.SELECTED)

	select_tool(tool_name)

func _on_ir_button_pressed() -> void:
	select_tool("IR")

func _on_uv_button_pressed() -> void:
	select_tool("UV")

func _on_intercalar_button_pressed() -> void:
	select_tool("INTERCALAR")

func _on_virus_button_pressed() -> void:
	select_tool("VIRUS")

func apply_tool_to_basepair(base_pair) -> void:
	if is_analyzing:
		return

	print("HE CLICAT UNA BASEPAIR")
	print("Eina actual: " + GameManager.selected_tool)
	print("BasePair: " + base_pair.name)

	if GameManager.selected_tool == "":
		print("Primer selecciona una eina")
		return

	# Si aquesta parella ja està mutada, no fem res.
	if base_pair.mutation_type != "none":
		print("Aquesta BasePair ja té una mutació aplicada")
		return

	var pair_index: int = base_pairs.find(base_pair)

	if pair_index == -1:
		return

	# Apliquem la mutació i esperem que acabi la seva animació.
	match GameManager.selected_tool:
		"UV":
			await base_pair.apply_uv()

		"IR":
			await base_pair.apply_ir()

		"VIRUS":
			await base_pair.apply_virus()

		"INTERCALAR":
			await base_pair.apply_intercalant()

		_:
			return

	# Guardem QUINA parella acabem de modificar.
	action_history.append(pair_index)

	update_undo_button()

#area dels botons
func _on_clickarea_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		apply_tool_to_basepair($DNAPanelArt/DNAFragment/BasePair1)

func _on_clickarea_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		apply_tool_to_basepair($DNAPanelArt/DNAFragment/BasePair2)

func _on_clickarea_3_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		apply_tool_to_basepair($DNAPanelArt/DNAFragment/BasePair3)

func _on_clickarea_4_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		apply_tool_to_basepair($DNAPanelArt/DNAFragment/BasePair4)

func _on_clickarea_5_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		apply_tool_to_basepair($DNAPanelArt/DNAFragment/BasePair5)

func _on_clickarea_6_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		apply_tool_to_basepair($DNAPanelArt/DNAFragment/BasePair6)

func _on_clickarea_7_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		apply_tool_to_basepair($DNAPanelArt/DNAFragment/BasePair7)

func _on_clickarea_8_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		apply_tool_to_basepair($DNAPanelArt/DNAFragment/BasePair8)

# ============================================================
# DESFER ÚLTIMA ACCIÓ

func _on_undo_button_pressed() -> void:
	if is_analyzing:
		return

	if action_history.is_empty():
		return

	var pair_index: int = action_history.pop_back()

	if pair_index < 0 or pair_index >= base_pairs.size():
		return

	var base_pair = base_pairs[pair_index]

	base_pair.reset_pair()

	print(
		"DESFETA MUTACIÓ DEL PARELL ",
		pair_index + 1
	)

	update_undo_button()

func update_undo_button() -> void:
	undo_button.set_disabled(
		action_history.is_empty()
	)

#excutar amb canvis fets
func _on_execute_button_pressed() -> void:
	if is_analyzing:
		return

	is_analyzing = true

	print("EXECUTANT...")	

	GameManager.mutations.clear()

	GameManager.mutations.append($DNAPanelArt/DNAFragment/BasePair1.tool_history)
	GameManager.mutations.append($DNAPanelArt/DNAFragment/BasePair2.tool_history)
	GameManager.mutations.append($DNAPanelArt/DNAFragment/BasePair3.tool_history)
	GameManager.mutations.append($DNAPanelArt/DNAFragment/BasePair4.tool_history)
	GameManager.mutations.append($DNAPanelArt/DNAFragment/BasePair5.tool_history)
	GameManager.mutations.append($DNAPanelArt/DNAFragment/BasePair6.tool_history)
	GameManager.mutations.append($DNAPanelArt/DNAFragment/BasePair7.tool_history)
	GameManager.mutations.append($DNAPanelArt/DNAFragment/BasePair8.tool_history)

	print("Mutacions guardades:")
	print(GameManager.mutations)

	await run_dna_scan()

	get_tree().change_scene_to_file("res://result_scene.tscn")
	
func mutation_to_text(mutation_type):
	if mutation_type == "point_mutation":
		return "point mutation"
	elif mutation_type == "insertion":
		return "insertion"
	elif mutation_type == "deletion":
		return "deletion"
	elif mutation_type == "frameshift":
		return "frameshift"
	return mutation_type

func load_gene_sequence():
	var gene = GameManager.gene_data[GameManager.selected_gene]
	var sequence = gene["starting_sequence"]

	$DNAPanelArt/DNAFragment/BasePair1.set_bases(sequence[0][0], sequence[0][1])
	$DNAPanelArt/DNAFragment/BasePair2.set_bases(sequence[1][0], sequence[1][1])
	$DNAPanelArt/DNAFragment/BasePair3.set_bases(sequence[2][0], sequence[2][1])
	$DNAPanelArt/DNAFragment/BasePair4.set_bases(sequence[3][0], sequence[3][1])
	$DNAPanelArt/DNAFragment/BasePair5.set_bases(sequence[4][0], sequence[4][1])
	$DNAPanelArt/DNAFragment/BasePair6.set_bases(sequence[5][0], sequence[5][1])
	$DNAPanelArt/DNAFragment/BasePair7.set_bases(sequence[6][0], sequence[6][1])
	$DNAPanelArt/DNAFragment/BasePair8.set_bases(sequence[7][0], sequence[7][1])

func run_dna_scan() -> void:
	scan_line.visible = true
	scan_glow.visible = true
	analysis_status.visible = true
	analysis_status_bg.visible = true

	scan_line.modulate.a = 0.0
	scan_glow.modulate.a = 0.0

	analysis_status.text = "ANALYZING SEQUENCE..."
	analysis_status.add_theme_color_override(
		"font_color",
		Color("#EAFBFF")
	)

	var start_y: float = 14.0
	scan_line.position.y = start_y
	scan_glow.position.y = start_y - 4.5

	var intro_tween: Tween = create_tween()
	intro_tween.set_parallel(true)

	intro_tween.tween_property(
		scan_line,
		"modulate:a",
		1.0,
		0.18
	)

	intro_tween.tween_property(
		scan_glow,
		"modulate:a",
		1.0,
		0.18
	)

	await intro_tween.finished
	await get_tree().create_timer(0.30).timeout

	var detected_mutations := 0

	for base_pair in base_pairs:
		# Converteix la posició global de la BasePair
		# en una posició local dins de DNAPanelArt.
		var target_y: float = (
			base_pair.global_position.y
			- $DNAPanelArt.global_position.y
		)

		var move_tween: Tween = create_tween()
		move_tween.set_parallel(true)
		move_tween.set_trans(Tween.TRANS_LINEAR)

		move_tween.tween_property(
			scan_line,
			"position:y",
			target_y,
			0.18
		)

		move_tween.tween_property(
			scan_glow,
			"position:y",
			target_y - 4.5,
			0.18
		)

		await move_tween.finished

		if base_pair.mutation_type != "none":
			detected_mutations += 1

			analysis_status.text = (
				"MUTATIONS DETECTED: "
				+ str(detected_mutations)
			)

			base_pair.play_scan_ping()
			await get_tree().create_timer(0.10).timeout

	analysis_status.text = "ANALYSIS COMPLETE"
	analysis_status.add_theme_color_override(
		"font_color",
		Color("#66E6FF")
	)	

	await get_tree().create_timer(0.85).timeout

	var end_tween: Tween = create_tween()
	end_tween.set_parallel(true)

	end_tween.tween_property(
		scan_line,
		"modulate:a",
		0.0,
		0.20
	)

	end_tween.tween_property(
		scan_glow,
		"modulate:a",
		0.0,
		0.20
	)

	await end_tween.finished

	scan_line.visible = false
	scan_glow.visible = false
	analysis_status.visible = false
	analysis_status_bg.visible = false
