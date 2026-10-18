extends Control

var current_result: String = ""
var current_gene: Dictionary = {}
@onready var dna_fragment_visual: Node2D = (
	$MolecularStage/DNAActor/DNACenter/DNAFragmentVisual
)

@onready var mutation_details: Label = (
	$MutationIndicator/MutationDetails
)

func _ready() -> void:
	print("RESULT SCENE")
	print("Gen: " + GameManager.selected_gene)
	print(GameManager.gene_data[GameManager.selected_gene]["name"])
	print("Mutacions rebudes:")
	print(GameManager.mutations)

	current_gene = GameManager.gene_data[GameManager.selected_gene]
	current_result = calculate_result()

	GameManager.mutation_result = current_result
	var mutation_visual_data: Dictionary = build_mutation_visual_data()
	dna_fragment_visual.set_mutations(mutation_visual_data)

	mutation_details.text = build_mutation_description()

	print("Resultat calculat: ", current_result)


# Extreu el resultat de les mutacions aplicades
func calculate_result() -> String:
	var gene: Dictionary = (
		GameManager.gene_data[
			GameManager.selected_gene
		]
	)

	var mutation_types: Array[String] = []

	for base_history in GameManager.mutations:
		for tool in base_history:
			mutation_types.append(
				tool_to_mutation(tool)
			)

	var total_mutations: int = mutation_types.size()

	# Sense mutacions = resultat neutre.
	if total_mutations == 0:
		return "NEUTRA"


	# ========================================================
	# LÍMIT TOTAL DE MUTACIONS

	var max_total: int = gene["max_total_mutations"]

	if total_mutations > max_total:
		return "PERJUDICIAL"


	# ========================================================
	# COMPTEM QUANTES MUTACIONS HI HA DE CADA TIPUS

	var mutation_counts: Dictionary = {
		"point_mutation": 0,
		"insertion": 0,
		"deletion": 0,
		"frameshift": 0
	}

	for mutation in mutation_types:
		if mutation_counts.has(mutation):
			mutation_counts[mutation] += 1


	# ========================================================
	# COMPROVEM ELS LÍMITS PARTICULARS DEL GEN

	var limits: Dictionary = gene["mutation_limits"]

	for mutation_type in mutation_counts:
		var count: int = mutation_counts[mutation_type]
		var limit: int = limits[mutation_type]

		if count > limit:
			return "PERJUDICIAL"


	# ========================================================
	# CALCULEM LA PUNTUACIÓ BIOLÒGICA

	var scores: Dictionary = gene["mutation_scores"]
	var score: int = 0

	for mutation in mutation_types:
		score += scores.get(mutation, -4)


	print("MUTACIONS: ", mutation_types)
	print("PUNTUACIÓ: ", score)


	# ========================================================
	# RESULTAT

	var beneficial_threshold: int = gene["beneficial_threshold"]
	var harmful_threshold: int = gene["harmful_threshold"]


	# ========================================================
	# RESULTAT PERJUDICIAL

	if score <= harmful_threshold:
		return "PERJUDICIAL"


	# ========================================================
	# RESULTAT BENEFICIÓS

	if score >= beneficial_threshold:
		var min_recommended: int = gene.get(
			"min_recommended_mutations",
			0
		)

		var recommended: Array = gene[
			"recommended_mutations"
		]

		var recommended_count: int = 0

		for mutation in mutation_types:
			if mutation in recommended:
				recommended_count += 1

		if recommended_count >= min_recommended:
			return "BENEFICIOSA"


	# Si té una puntuació acceptable però no compleix
	# els requisits per ser beneficiós, queda neutre.

	return "NEUTRA"


# Relació entre l'eina utilitzada i el tipus de mutació
func tool_to_mutation(tool: String) -> String:
	match tool:
		"UV":
			return "point_mutation"

		"IR":
			return "deletion"

		"VIRUS":
			return "insertion"

		"INTERCALAR":
			return "frameshift"

		_:
			return "unknown"


func return_to_main() -> void:
	get_tree().change_scene_to_file("res://main.tscn")

func build_mutation_visual_data() -> Dictionary:
	var mutation_data: Dictionary = {}

	var pair_limit: int = mini(
		GameManager.mutations.size(),
		8
	)

	for pair_index: int in range(pair_limit):
		var base_history: Array = GameManager.mutations[pair_index]

		if base_history.is_empty():
			continue

		# Per seguretat, agafem l’última mutació guardada
		var tool: String = str(base_history[-1])

		mutation_data[pair_index] = get_tool_color(tool)

	return mutation_data

func get_tool_color(tool: String) -> Color:
	match tool:
		"UV":
			return Color("#FF4FD8")
		"IR":
			return Color("#FF5A5F")
		"VIRUS":
			return Color("#0072B2")
		"INTERCALAR":
			return Color("#A7B0B8")
		_:
			return Color("#66E6FF")

func build_mutation_description() -> String:
	var descriptions: Array[String] = []

	for pair_index: int in range(GameManager.mutations.size()):
		var base_history: Array = GameManager.mutations[pair_index]

		if base_history.is_empty():
			continue

		var tool: String = str(base_history[-1])

		descriptions.append(
			get_tool_display_name(tool)
			+ " · PAIR "
			+ str(pair_index + 1)
		)

	if descriptions.is_empty():
		return "NO MUTATIONS DETECTED"

	return "\n".join(descriptions)


func get_tool_display_name(tool: String) -> String:
	match tool:
		"UV":
			return "UV SUBSTITUTION"

		"IR":
			return "IR BREAK"

		"VIRUS":
			return "VIRAL INSERTION"

		"INTERCALAR":
			return "INTERCALATION"

		_:
			return "UNKNOWN MUTATION"
