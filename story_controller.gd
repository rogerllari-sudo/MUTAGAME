extends Node

@export var auto_start: bool = true
var story_running: bool = false

# ============================================================
# REFERÈNCIES PRINCIPALS

@onready var result_scene: Control = get_parent()
@onready var process_progress_overlay: Control = (
	result_scene.get_node("ProcessProgressOverlay")
)

@onready var molecular_stage: Control = $"../MolecularStage"
@onready var molecular_center: Marker2D = molecular_stage.get_node(
	"MolecularCenter"
)

@onready var bottom_progress_overlay: Control = (
	result_scene.get_node("BottomProgressOverlay")
)

# ============================================================
# ACTORS

@onready var dna_actor: Control = molecular_stage.get_node(
	"DNAActor"
)

@onready var rna_actor: Control = molecular_stage.get_node(
	"RNAActor"
)

@onready var ribosome_actor: Control = molecular_stage.get_node(
	"RibosomeActor"
)

@onready var protein_actor: Control = molecular_stage.get_node(
	"ProteinActor"
)

@onready var human_actor: Control = molecular_stage.get_node(
	"HumanActor"
)

@onready var phenotype_effects: Control = molecular_stage.get_node(
	"PhenotypeEffects"
)
@onready var subject_scanner: Control = molecular_stage.get_node(
	"PhenotypeEffects/SubjectScanner"
)

# ============================================================
# ELEMENTS VISUALS

@onready var dna_fragment_visual: Node2D = molecular_stage.get_node(
	"DNAActor/DNACenter/DNAFragmentVisual"
)

@onready var rna_visual: Node2D = molecular_stage.get_node(
	"RNAActor/RNAVisual"
)

@onready var ribosome_visual: Node2D = molecular_stage.get_node(
	"RibosomeActor/RibosomeVisual"
)

@onready var protein_chain_visual: Node2D = molecular_stage.get_node(
	"ProteinActor/ProteinChainVisual"
)

@onready var human_visual: Node2D = molecular_stage.get_node(
	"HumanActor/HumanVisual"
)
@onready var human_texture: Sprite2D = molecular_stage.get_node(
	"HumanActor/HumanTexture"
)

# ============================================================
# INTERFÍCIE

@onready var stage_label: Label = molecular_stage.get_node(
	"StageHeader/StageLabel"
)

@onready var stage_description: Label = molecular_stage.get_node(
	"StageHeader/StageDescription"
)

@onready var mutation_indicator: Control = $"../MutationIndicator"

@onready var process_status: Label = molecular_stage.get_node(
	"StoryTextLayer/ProcessStatus"
)

@onready var result_overlay: Control = $"../ResultOverlay"
@onready var result_transition: ColorRect = (
	$"../ResultTransition"
)

# ============================================================
# POSICIONS INICIALS

var rna_start_position: Vector2
var ribosome_start_position: Vector2
var protein_chain_start_position: Vector2
var human_start_position: Vector2


# ============================================================
# CONFIGURACIÓ DE LA TRADUCCIÓ

@export_category("Translation movement")

@export_range(0.0, 1.0)
var translation_start_progress: float = 0.18

@export_range(0.0, 1.0)
var translation_end_progress: float = 0.82

@export var ribosome_rna_offset: Vector2 = Vector2(-8.0, 0.0)
@export var protein_chain_offset: Vector2 = Vector2(28.0, -48.0)


# ============================================================
# CONFIGURACIÓ DEL PLEGAMENT

@export_category("Protein folding")

@export var protein_center_position: Vector2 = Vector2(502.0, 180.0)
@export var protein_fold_scale: Vector2 = Vector2(1.3, 1.3)


# ============================================================
# CONFIGURACIÓ DE LA PERSONA

@export_category("Human reveal")

@export var human_reveal_scale: Vector2 = Vector2(1.0, 1.0)
@export var human_start_scale: Vector2 = Vector2(0.72, 0.72)


# ============================================================
# SEGUIMENT DE L’ARN

func get_rna_point_for_ribosome(progress: float) -> Vector2:
	var local_point: Vector2 = rna_visual.get_point_at_progress(progress)

	var global_point: Vector2 = (
		rna_visual.global_position
		+ local_point
	)

	var ribosome_parent: Control = ribosome_visual.get_parent()

	return global_point - ribosome_parent.global_position


func update_translation_progress(progress: float) -> void:
	var ribosome_position: Vector2 = get_rna_point_for_ribosome(
		progress
	)

	ribosome_visual.position = (
		ribosome_position
		+ ribosome_rna_offset
	)

	protein_chain_visual.position = (
		ribosome_visual.position
		+ protein_chain_offset
	)


# ============================================================
# INICIALITZACIÓ

func _ready() -> void:
	rna_start_position = rna_visual.position
	ribosome_start_position = ribosome_visual.position
	protein_chain_start_position = protein_chain_visual.position

	var human_parent: Control = human_visual.get_parent()

	human_start_position = (
		human_parent
			.get_global_transform_with_canvas()
			.affine_inverse()
			* molecular_center.global_position
	)

	prepare_story()

	if auto_start:
		await get_tree().process_frame
		await play_story()


func prepare_story() -> void:
	story_running = false

	# Reinici de posicions.
	rna_visual.position = rna_start_position
	ribosome_visual.position = ribosome_start_position
	protein_chain_visual.position = protein_chain_start_position
	human_visual.position = human_start_position

	# ADN.
	dna_actor.visible = true
	dna_actor.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	# ARN.
	rna_actor.visible = true
	rna_actor.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	# Ribosoma.
	ribosome_actor.visible = true
	ribosome_actor.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	# Proteïna.
	protein_actor.visible = true
	protein_actor.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	protein_chain_visual.visible = true
	protein_chain_visual.modulate = Color.WHITE
	protein_chain_visual.scale = Vector2.ONE
	protein_chain_visual.reset_visual()

	# Persona.
	human_actor.visible = true
	human_actor.modulate = Color.WHITE

	human_visual.visible = false

	human_texture.visible = false
	human_texture.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)
	human_texture.scale = Vector2(
		0.19,
		0.19
	)

	# Efectes de fenotip.
	phenotype_effects.visible = true
	phenotype_effects.modulate = Color.WHITE

	subject_scanner.visible = true

	# Informació lateral i textos.
	mutation_indicator.modulate.a = 0.0
	process_status.modulate.a = 0.0

	# Resultat final.
	result_overlay.visible = false
	result_overlay.modulate.a = 0.0

	# Transició final.
	result_transition.visible = true
	result_transition.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	result_transition.scale = Vector2.ONE

# ============================================================
# FLUX GENERAL

func set_process_stage(stage_index: int) -> void:
	process_progress_overlay.set_active_stage(
		stage_index,
		true
	)
	
func set_bottom_step(step_index: int) -> void:
	bottom_progress_overlay.set_active_step(
		step_index,
		true
	)
#---------------------------------
	
func play_story() -> void:
	if story_running:
		return

	story_running = true

	await play_dna_intro()
	await play_transcription()
	await play_translation()
	await play_protein_folding()
	await play_human_reveal()
	await play_phenotype_effect()
	await play_final_result()

	story_running = false


# ============================================================
# ETAPA 01 — ADN

func play_dna_intro() -> void:
	set_process_stage(0)
	set_bottom_step(0)
	stage_label.text = "ETAPA 01 / ADN"
	stage_description.text = "FRAGMENT MUTAT DETECTAT"

	var tween: Tween = create_tween()

	tween.tween_property(
		dna_actor,
		"modulate:a",
		1.0,
		0.6
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_OUT
	)

	await tween.finished

	await show_status(
		"FRAGMENT MUTAT DETECTAT",
		0.8
	)

	var indicator_tween: Tween = create_tween()

	indicator_tween.tween_property(
		mutation_indicator,
		"modulate:a",
		1.0,
		0.4
	)

	await indicator_tween.finished
	await get_tree().create_timer(1.0).timeout


# ============================================================
# ETAPA 02 — TRANSCRIPCIÓ

func play_transcription() -> void:
	set_process_stage(1)
	set_bottom_step(1)
	stage_label.text = "ETAPA 02 / TRANSCRIPCIÓ"
	stage_description.text = "FORMACIÓ D'ARN MISSATGER"

	await show_status(
		"INICIANT TRANSCRIPCIÓ",
		0.35
	)

	await dna_fragment_visual.animate_opening(0.9)

	rna_actor.visible = true
	rna_actor.modulate.a = 0.0

	var transition_tween: Tween = create_tween()
	transition_tween.set_parallel(true)

	transition_tween.tween_property(
		dna_actor,
		"modulate:a",
		0.42,
		0.45
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_OUT
	)

	transition_tween.tween_property(
		rna_actor,
		"modulate:a",
		1.0,
		0.35
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_OUT)

	await rna_visual.animate_reveal(1.35)

	await show_status(
		"ARN MISSATGER GENERAT",
		0.35)

	var rna_exit_tween: Tween = create_tween()
	rna_exit_tween.set_parallel(true)

	rna_exit_tween.tween_property(
		rna_visual,
		"position:x",
		rna_visual.position.x + 75.0,
		0.8
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	rna_exit_tween.tween_property(
		dna_actor,
		"modulate:a",
		0.18,
		0.8
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_OUT
	)

	await rna_exit_tween.finished
	await get_tree().create_timer(0.25).timeout


# ============================================================
# ETAPA 03 — TRADUCCIÓ

func play_translation() -> void:
	set_process_stage(2)
	set_bottom_step(2)
	stage_label.text = "ETAPA 03 / TRADUCCIÓ"
	stage_description.text = "SÍNTESI DE LA CADENA POLIPEPTÍDICA"

	await show_status(
		"INICIANT TRADUCCIÓ",
		0.25
	)

	ribosome_actor.visible = true
	ribosome_actor.modulate.a = 1.0

	protein_actor.visible = true
	protein_actor.modulate.a = 1.0

	var start_position: Vector2 = get_rna_point_for_ribosome(
		translation_start_progress
	)

	# Entrada del ribosoma des de la dreta.
	ribosome_visual.position = (
		start_position + Vector2(150.0, 0.0)
	)

	protein_chain_visual.position = (
		ribosome_visual.position
		+ protein_chain_offset
	)

	var entrance_tween: Tween = create_tween()
	entrance_tween.set_parallel(true)

	entrance_tween.tween_property(
		ribosome_visual,
		"position",
		start_position + ribosome_rna_offset,
		0.75
	).set_trans(
		Tween.TRANS_QUINT
	).set_ease(
		Tween.EASE_OUT
	)

	entrance_tween.tween_method(
		func(current_position: Vector2) -> void:
			protein_chain_visual.position = (
				current_position
				+ protein_chain_offset
			),
		ribosome_visual.position,
		start_position + ribosome_rna_offset,
		0.75
	).set_trans(
		Tween.TRANS_QUINT
	).set_ease(
		Tween.EASE_OUT
	)

	await entrance_tween.finished

	protein_chain_visual.reveal_amount = 0.0
	protein_chain_visual.queue_redraw()

	var translation_duration: float = 2.4

	var translation_tween: Tween = create_tween()

	translation_tween.tween_method(
		update_translation_progress,
		translation_start_progress,
		translation_end_progress,
		translation_duration
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	var protein_tween: Tween = create_tween()

	protein_tween.tween_property(
		protein_chain_visual,
		"reveal_amount",
		1.0,
		translation_duration
	).set_trans(
		Tween.TRANS_LINEAR
	)

	protein_tween.parallel().tween_method(
		func(_value: float) -> void:
			protein_chain_visual.queue_redraw(),
		0.0,
		1.0,
		translation_duration
	)

	await translation_tween.finished
	await protein_tween.finished

	await show_status(
		"CADENA POLIPEPTÍDICA SINTETITZADA",
		0.3
	)


# ============================================================
# ETAPA 04 — PLEGAMENT

func play_protein_folding() -> void:
	set_process_stage(3)
	stage_label.text = "ETAPA 04 / PROTEÏNA"
	stage_description.text = "PLEGAMENT MOLECULAR"

	await show_status(
		"ALLIBERANT CADENA POLIPEPTÍDICA",
		0.25
	)

	var current_global_position: Vector2 = (
	protein_chain_visual.global_position
)

	var protein_parent: Control = (
		protein_chain_visual.get_parent() as Control
	)

	if protein_parent == null:
		push_error(
			"ProteinChainVisual necessita un pare de tipus Control."
		)
		return

	var parent_inverse_transform: Transform2D = (
		protein_parent
			.get_global_transform_with_canvas()
			.affine_inverse()
	)

# Manté la proteïna exactament al mateix lloc visual abans del tween.
	protein_chain_visual.position = (
		parent_inverse_transform
		* current_global_position
	)

# Converteix el marcador central a coordenades locals de ProteinActor.
	var centered_protein_position: Vector2 = (
		parent_inverse_transform
		* molecular_center.global_position
	)

	var transition_tween: Tween = create_tween()
	transition_tween.set_parallel(true)

	transition_tween.tween_property(
		ribosome_actor,
		"modulate:a",
		0.0,
		0.65
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN
	)

	transition_tween.tween_property(
		rna_actor,
		"modulate:a",
		0.0,
		0.75
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN
	)

	transition_tween.tween_property(
		dna_actor,
		"modulate:a",
		0.0,
		0.75
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN
	)

	transition_tween.tween_property(
		protein_chain_visual,
		"position",
		centered_protein_position,
		0.9
	).set_trans(
		Tween.TRANS_QUINT
	).set_ease(
		Tween.EASE_IN_OUT
	)

	await transition_tween.finished

	await show_status(
		"PLEGAMENT DE LA PROTEÏNA",
		0.25
	)

	var scale_tween: Tween = create_tween()

	scale_tween.tween_property(
		protein_chain_visual,
		"scale",
		protein_fold_scale,
		1.6
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN_OUT
	)

	await protein_chain_visual.animate_folding(1.8)

	await show_status(
		"PROTEÏNA SINTETITZADA",
		0.35
	)
# ============================================================
# ETAPA 05 — FENOTIP

func play_human_reveal() -> void:
	set_process_stage(4)
	set_bottom_step(3)

	print("INICIANT HUMAN REVEAL")

	stage_label.text = "ETAPA 05 / FENOTIP"
	stage_description.text = "IMPACTE SOBRE L'ORGANISME"

	await show_status(
		"ANALITZANT FUNCIÓ BIOLÒGICA",
		0.25
	)

	# El contenidor pare ha de ser visible i opac.
	human_actor.visible = true
	human_actor.modulate = Color.WHITE

	# El monigot antic queda permanentment ocult.
	human_visual.visible = false

	# Preparem el PNG real.
	human_texture.visible = true
	human_texture.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	human_texture.global_position = (
		molecular_center.global_position
		+ Vector2(0.0, 18.0)
	)

	# Escala inicial lleugerament menor.
	human_texture.scale = Vector2(
		0.19,
		0.19
	)

	var protein_original_scale: Vector2 = (
		protein_chain_visual.scale
	)

	# Petita anticipació de la proteïna.
	var anticipation_tween: Tween = create_tween()

	anticipation_tween.tween_property(
		protein_chain_visual,
		"scale",
		protein_original_scale * 1.12,
		0.35
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_OUT
	)

	await anticipation_tween.finished

	# Transformació creuada proteïna → personatge.
	var reveal_tween: Tween = create_tween()
	reveal_tween.set_parallel(true)

	reveal_tween.tween_property(
		protein_chain_visual,
		"modulate:a",
		0.0,
		0.75
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN
	)

	reveal_tween.tween_property(
		protein_chain_visual,
		"scale",
		protein_original_scale * 1.45,
		0.75
	).set_trans(
		Tween.TRANS_QUINT
	).set_ease(
		Tween.EASE_IN
	)

	reveal_tween.tween_property(
		human_texture,
		"modulate:a",
		1.0,
		0.85
	).set_delay(
		0.12
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_OUT
	)

	reveal_tween.tween_property(
		human_texture,
		"scale",
		Vector2(0.24, 0.24),
		0.85
	).set_delay(
		0.12
	).set_trans(
		Tween.TRANS_BACK
	).set_ease(
		Tween.EASE_OUT
	)

	await reveal_tween.finished

	print(
		"HUMAN REVEAL COMPLETAT | alpha textura: ",
		human_texture.modulate.a,
		" | alpha pare: ",
		human_actor.modulate.a,
		" | posició: ",
		human_texture.global_position,
		" | escala: ",
		human_texture.scale
	)

	await get_tree().create_timer(
		0.25
	).timeout

	await show_status(
		"FENOTIP GENERAT",
		0.3
	)


func play_phenotype_effect() -> void:
	await get_tree().create_timer(
		0.25
	).timeout

	await subject_scanner.start_scan()


func play_final_result() -> void:
	set_bottom_step(4)

	await get_tree().create_timer(
		0.18
	).timeout

	await play_result_flash()

	get_tree().change_scene_to_file(
		"res://final_scene.tscn"
	)

func play_result_flash() -> void:
	result_transition.visible = true
	result_transition.modulate = Color(
		1.0,
		1.0,
		1.0,
		0.0
	)

	# Primera pulsació curta: el sistema confirma el resultat.
	var pulse_tween: Tween = create_tween()

	pulse_tween.tween_property(
		result_transition,
		"modulate:a",
		0.20,
		0.09
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_OUT
	)

	pulse_tween.tween_property(
		result_transition,
		"modulate:a",
		0.04,
		0.10
	).set_trans(
		Tween.TRANS_SINE
	).set_ease(
		Tween.EASE_IN
	)

	await pulse_tween.finished

	# Cobertura definitiva de la pantalla.
	var cover_tween: Tween = create_tween()

	cover_tween.tween_property(
		result_transition,
		"modulate:a",
		1.0,
		0.30
	).set_trans(
		Tween.TRANS_QUINT
	).set_ease(
		Tween.EASE_IN
	)

	await cover_tween.finished

func show_status(
	text: String,
	visible_time: float
) -> void:
	process_status.text = text
	process_status.modulate.a = 0.0

	var tween_in: Tween = create_tween()

	tween_in.tween_property(
		process_status,
		"modulate:a",
		1.0,
		0.25
	)

	await tween_in.finished
	await get_tree().create_timer(visible_time).timeout

	var tween_out: Tween = create_tween()

	tween_out.tween_property(
		process_status,
		"modulate:a",
		0.0,
		0.2
	)

	await tween_out.finished
	
