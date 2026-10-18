extends Node

var selected_gene = "alpha"
var selected_tool = ""
var mutations = []

# Resultat final
var mutation_result = ""

# ============================================================
# PROGRÉS DEL JOC

var completed_fragments: Dictionary = {
	"alpha": false,
	"beta": false,
	"gamma": false,
	"delta": false,
	"epsilon": false
}
var newly_completed_fragment: String = ""

# Base de dades dels gens
var gene_data = {
	"alpha": {
		"name": "FRAGMENT α",
		"function": "RADIATION SHIELD",
		"summary": "This fragment produces a protective protein that reduces radiation-induced damage, increasing the cell's resistance to its effects.",
		
		"fragment_id": "ID: FRAG-α-01",
		"icon": "⛨",
		"type": "PROTECTIVE",
		"conservation_level": 5,
		"effect": "RADIATION RESISTANCE",
		"impact": "HIGH",
		
		"conservation": "★★★★★",
		"description": "Produces a protective protein against radiation.",
		"hint": "Highly conserved. Small changes are more likely to preserve its function.",
		
		"recommended_mutations": ["point_mutation"],
		"max_recommended_mutations": 1,
		"mutation_scores": {
			"point_mutation": 2,
			"insertion": -4,
			"deletion": -4,
			"frameshift": -4
		},

		"mutation_limits": {
			"point_mutation": 1,
			"insertion": 0,
			"deletion": 0,
			"frameshift": 0
		},

		"max_total_mutations": 1,
		"beneficial_threshold": 2,
		"harmful_threshold": -1,

#textos resultants
"success_title": "Enhanced protection",
"success_text": "The mutation has modified the protective protein.\nThe radiation shield now works more effectively.",

"neutral_title": "No significant change",
"neutral_text": "The mutation has caused little change to the protein.\nThe subject maintains normal protection against radiation.",

"failure_title": "Protection lost",
"failure_text": "The mutation has severely altered the protective protein.\nThe radiation shield no longer functions correctly.",

		"starting_sequence": [
			["A", "T"],
			["C", "G"],
			["G", "C"],
			["A", "T"],
			["T", "A"],
			["C", "G"],
			["G", "C"],
			["A", "T"]
		],
	},
#------------------------------------------------------------------------------------
	"beta": {
		"name": "FRAGMENT β",
		"function": "CELL REGENERATION",
		"summary": "This fragment helps regenerate tissues damaged by radiation. When functioning correctly, cells can recover more effectively after damage.",
		
		"fragment_id": "ID: FRAG-β-02",
		"icon": "✚",
		"type": "REGENERATIVE",
		"conservation_level": 3,
		"effect": "TISSUE REPAIR",
		"impact": "MEDIUM",
		
		"conservation": "★★★☆☆",
		"description": "Helps regenerate tissues damaged by radiation.",
		"hint": "It tolerates some changes, but excessive alteration may disrupt regeneration.",
	
		"recommended_mutations": ["insertion"],
		"max_recommended_mutations": 1,

		"mutation_scores": {
			"point_mutation": 1,
			"insertion": 2,
			"deletion": -3,
			"frameshift": -2
		},

		"mutation_limits": {
			"point_mutation": 2,
			"insertion": 3,
			"deletion": 0,
			"frameshift": 1
		},

		"max_total_mutations": 4,
		"beneficial_threshold": 2,
		"harmful_threshold": -1,
		
		"success_title": "Enhanced regeneration",
		"success_text": "The mutation has improved cell regeneration.\nTissues recover more effectively after radiation damage.",

		"neutral_title": "Normal regeneration",
		"neutral_text": "The mutation has caused little change to its function.\nCells continue to regenerate at a normal rate.",

		"failure_title": "Impaired regeneration",
		"failure_text": "The mutation has disrupted the regeneration system.\nTissues can no longer recover properly.",

		"starting_sequence": [
			["G", "C"],
			["A", "T"],
			["T", "A"],
			["C", "G"],
			["G", "C"],
			["T", "A"],
			["A", "T"],
			["C", "G"]
		],
	},
#------------------------------------------------------------------------------------
	"gamma": {
		"name": "FRAGMENT γ",
		"function": "IMMUNE SYSTEM",
		"summary": "This fragment helps the immune system detect and eliminate cells damaged by radiation.",
			
		"fragment_id": "ID: FRAG-γ-03",
		"icon": "◈",
		"type": "IMMUNOREGULATORY",
		"conservation_level": 4,
		"effect": "CELL ELIMINATION",
		"impact": "HIGH",
			
		"conservation": "★★★★☆",
		"description": "Helps eliminate radiation-damaged cells.",
		"hint": "Small changes may improve its function, major changes can weaken it.",
	
	
		"recommended_mutations": ["frameshift"],
		"max_recommended_mutations": 1,
		"mutation_scores": {
			"point_mutation": 0,
			"insertion": -2,
			"deletion": -3,
			"frameshift": 2
		},

		"mutation_limits": {
			"point_mutation": 1,
			"insertion": 0,
			"deletion": 0,
			"frameshift": 1
		},

		"max_total_mutations": 2,
		"beneficial_threshold": 2,
		"harmful_threshold": -1,

		"success_title": "Strengthened defenses",
		"success_text": "The mutation has improved the immune response.\nThe body eliminates damaged cells more effectively.",

		"neutral_title": "Stable response",
		"neutral_text": "The mutation has caused little change to the immune system.\nThe response remains normal.",

		"failure_title": "Weakened defenses",
		"failure_text": "The mutation has disrupted the immune system.\nThe body's defenses fail, making the subject more vulnerable.",

		"starting_sequence": [
			["C", "G"],
			["G", "C"],
			["A", "T"],
			["A", "T"],
			["T", "A"],
			["G", "C"],
			["C", "G"],
			["T", "A"]
		],
	},
#------------------------------------------------------------------------------------
	"delta": {
		"name": "FRAGMENT δ",
		"function": "DNA REPAIR",
		"summary": "This fragment is involved in repairing damage directly affecting DNA. If it fails, genetic errors can accumulate.",
		
		"fragment_id": "ID: FRAG-δ-04",
		"icon": "⌬",
		"type": "REPAIR",
		"conservation_level": 5,
		"effect": "GENETIC STABILITY",
		"impact": "CRITICAL",
		
		"conservation": "★★★★★",
		"description": "Repairs damage occurring directly in DNA.",
		"hint": "Highly sensitive. Only small changes are likely to be beneficial.",
	
		"recommended_mutations": ["point_mutation"],
		"max_recommended_mutations": 1,
		"mutation_scores": {
			"point_mutation": 2,
			"insertion": -4,
			"deletion": -4,
			"frameshift": -4
		},

		"mutation_limits": {
			"point_mutation": 1,
			"insertion": 0,
			"deletion": 0,
			"frameshift": 0
		},
		
		"max_total_mutations": 1,
		"beneficial_threshold": 2,
		"harmful_threshold": -1,
		
		"success_title": "Enhanced DNA repair",
		"success_text": "The mutation has improved the repair protein.\nThe cell can correct DNA damage more effectively.",

		"neutral_title": "Normal DNA repair",
		"neutral_text": "The mutation has caused little change to DNA repair.\nThe cell continues to function normally.",

		"failure_title": "Vulnerable DNA",
		"failure_text": "The mutation has impaired DNA repair.\nGenetic errors accumulate, leaving the cell more vulnerable.",

		"starting_sequence": [
			["A", "T"],
			["T", "A"],
			["C", "G"],
			["G", "C"],
			["C", "G"],
			["A", "T"],
			["G", "C"],
			["T", "A"]
		],
	},
#------------------------------------------------------------------------------------
	"epsilon": {
		"name": "FRAGMENT ε",
		"function": "ANTIOXIDANTS",
		"summary": "This fragment helps reduce free radicals generated by radiation, decreasing oxidative stress and cellular damage.",
		
		"fragment_id": "ID: FRAG-ε-05",
		"icon": "ϟ",
		"type": "ANTIOXIDANT",
		"conservation_level": 2,
		"effect": "OXIDATIVE CONTROL",
		"impact": "MEDIUM",
			
		"conservation": "★★☆☆☆",
		"description": "Reduces free radicals generated by radiation.",
		"hint": "Adding genetic material may increase the production of protective molecules.",
		
		"recommended_mutations": ["insertion"],
		"min_recommended_mutations": 2,
		"max_recommended_mutations": 2,
		"mutation_scores": {
			"point_mutation": 1,
			"insertion": 2,
			"deletion": -2,
			"frameshift": 0
		},

		"mutation_limits": {
			"point_mutation": 2,
			"insertion": 3,
			"deletion": 1,
			"frameshift": 1
		},

		"max_total_mutations": 5,
		"beneficial_threshold": 2,
		"harmful_threshold": -2,

		"success_title": "Enhanced antioxidant protection",
		"success_text": "The mutation has increased antioxidant protection.\nThe cell can better withstand radiation-induced oxidative stress.",

		"neutral_title": "Normal antioxidant levels",
		"neutral_text": "The mutation has caused little change to antioxidant production.\nProtection remains stable.",

		"failure_title": "Elevated oxidative stress",
		"failure_text": "The mutation has reduced antioxidant protection.\nFree radicals cause greater cellular damage.",

		"starting_sequence": [
			["T", "A"],
			["C", "G"],
			["A", "T"],
			["G", "C"],
			["T", "A"],
			["A", "T"],
			["C", "G"],
			["G", "C"]
		],
	}
}

# ============================================================
# ESTAT BIOLÒGIC BASAL
# Ordre:
# [radiació, regeneració, immunitari, antioxidants, genètica]

var baseline_stats = [2, 3, 3, 3, 3]


# ============================================================
# ESTATS POST-MUTACIÓ

var final_stats = {
	"alpha": {
		"BENEFICIOSA": [5, 4, 3, 4, 3],
		"NEUTRA":      [2, 3, 3, 3, 3],
		"PERJUDICIAL": [1, 3, 3, 2, 3],
	},

	"beta": {
		"BENEFICIOSA": [2, 5, 4, 3, 3],
		"NEUTRA":      [2, 3, 3, 3, 3],
		"PERJUDICIAL": [2, 1, 2, 3, 3],
	},

	"gamma": {
		"BENEFICIOSA": [2, 4, 5, 3, 3],
		"NEUTRA":      [2, 3, 3, 3, 3],
		"PERJUDICIAL": [2, 2, 1, 3, 3],
	},

	"delta": {
		"BENEFICIOSA": [3, 4, 3, 3, 5],
		"NEUTRA":      [2, 3, 3, 3, 3],
		"PERJUDICIAL": [1, 3, 3, 3, 1],
	},

	"epsilon": {
		"BENEFICIOSA": [3, 3, 3, 5, 4],
		"NEUTRA":      [2, 3, 3, 3, 3],
		"PERJUDICIAL": [2, 3, 3, 1, 2],
	},
}

func mark_fragment_completed_if_beneficial() -> void:
	if mutation_result != "BENEFICIOSA":
		return

	if not completed_fragments.has(selected_gene):
		return

	# Només és "nou" si encara no estava completat
	if completed_fragments[selected_gene] == false:
		completed_fragments[selected_gene] = true
		newly_completed_fragment = selected_gene

func all_fragments_completed() -> bool:
	for completed in completed_fragments.values():
		if not completed:
			return false

	return true

func reset_game():
	selected_gene = "alpha"
	selected_tool = ""
	mutations.clear()
	mutation_result = ""

func reset_full_game() -> void:
	selected_gene = "alpha"
	selected_tool = ""
	mutations.clear()
	mutation_result = ""

	completed_fragments = {
		"alpha": false,
		"beta": false,
		"gamma": false,
		"delta": false,
		"epsilon": false
	}

	newly_completed_fragment = ""
