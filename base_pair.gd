extends Node2D

var left_base = ""
var right_base = ""
var mutation_type = "none"
var tool_history = []

var original_left_base = ""
var original_right_base = ""
var original_left_visual_position = Vector2.ZERO
var original_right_visual_position = Vector2.ZERO
var original_viral_insert_position = Vector2.ZERO

@onready var bond1 = $Bond1
@onready var bond2 = $Bond2
@onready var bond3 = $Bond3
@onready var left_dna_base = $LeftDNABase
@onready var right_dna_base = $RightDNABase
@onready var viral_insert = $ViralInsert
@onready var click_area = $Clickarea

var hover_tween: Tween
var is_hovered := false

func _ready():
	left_base = left_dna_base.base_letter
	right_base = right_dna_base.base_letter

	original_left_base = left_base
	original_right_base = right_base

	original_left_visual_position = left_dna_base.position
	original_right_visual_position = right_dna_base.position
	original_viral_insert_position = viral_insert.position

	viral_insert.hide()
	update_visual()

	click_area.mouse_entered.connect(_on_basepair_mouse_entered)
	click_area.mouse_exited.connect(_on_basepair_mouse_exited)

func reset_pair():
	left_base = original_left_base
	right_base = original_right_base
	mutation_type = "none"
	tool_history.clear()
	
	if hover_tween != null and hover_tween.is_valid():
		hover_tween.kill()

	scale = Vector2.ONE

	bond1.self_modulate = Color.WHITE
	bond2.self_modulate = Color.WHITE
	bond3.self_modulate = Color.WHITE
	
	left_dna_base.position = original_left_visual_position
	right_dna_base.position = original_right_visual_position

	left_dna_base.scale = Vector2.ONE
	right_dna_base.scale = Vector2.ONE

	bond1.scale.x = 1
	bond2.scale.x = 1
	bond3.scale.x = 1

	bond1.modulate.a = 1.0
	bond2.modulate.a = 1.0
	bond3.modulate.a = 1.0

	viral_insert.position = original_viral_insert_position
	viral_insert.scale = Vector2.ONE
	viral_insert.hide()

	update_visual()

func update_visual():
	left_dna_base.set_base(left_base)
	right_dna_base.set_base(right_base)

	left_dna_base.set_damaged(mutation_type == "point_mutation")
	right_dna_base.set_damaged(false)

	update_bonds()

func can_apply_mutation() -> bool:
	if mutation_type != "none":
		print("Aquesta BasePair ja té una mutació aplicada")
		return false

	return true

func apply_uv() -> void:
	if not can_apply_mutation():
		return

	mutation_type = "point_mutation"

	# Guardem l'estat visual inicial.
	var original_modulate: Color = left_dna_base.modulate

	# FASE 1: flash i contracció.
	var impact_tween: Tween = create_tween()
	impact_tween.set_trans(Tween.TRANS_QUAD)
	impact_tween.set_ease(Tween.EASE_OUT)
	impact_tween.set_parallel(true)

	impact_tween.tween_property(
		left_dna_base,
		"scale",
		Vector2(0.80, 0.80),
		0.07
	)

	impact_tween.tween_property(
		left_dna_base,
		"modulate",
		Color(1.7, 1.7, 1.7, 1.0),
		0.05
	)

	await impact_tween.finished

	# Canvi real de la base.
	left_base = "G"
	update_visual()

	# FASE 2: petit rebot i retorn al color normal.
	var recovery_tween := create_tween()
	recovery_tween.set_trans(Tween.TRANS_BACK)
	recovery_tween.set_ease(Tween.EASE_OUT)

	recovery_tween.set_parallel(true)

	recovery_tween.tween_property(
		left_dna_base,
		"scale",
		Vector2(1.12, 1.12),
		0.08
	)

	recovery_tween.tween_property(
		left_dna_base,
		"modulate",
		original_modulate,
		0.08
	)

	await recovery_tween.finished

	var settle_tween := create_tween()
	settle_tween.set_trans(Tween.TRANS_QUAD)
	settle_tween.set_ease(Tween.EASE_OUT)

	settle_tween.tween_property(
		left_dna_base,
		"scale",
		Vector2.ONE,
		0.08
	)

	await settle_tween.finished

	print("UV: canvi puntual de base")
	tool_history.append("UV")

func apply_ir() -> void:
	if not can_apply_mutation():
		return

	mutation_type = "deletion"

	# Guardem la posició actual del BasePair.
	var start_pos: Vector2 = position

	# FASE 1: petit impacte abans del trencament.
	var shake: Tween = create_tween()
	shake.set_trans(Tween.TRANS_LINEAR)

	shake.tween_property(
		self,
		"position",
		start_pos + Vector2(-3, 0),
		0.03
	)

	shake.tween_property(
		self,
		"position",
		start_pos + Vector2(3, 0),
		0.03
	)

	shake.tween_property(
		self,
		"position",
		start_pos,
		0.03
	)

	await shake.finished

	# FASE 2: separació de les bases i ruptura dels ponts.
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		left_dna_base,
		"position",
		original_left_visual_position + Vector2(-24, -4),
		0.12
	)

	tween.tween_property(
		right_dna_base,
		"position",
		original_right_visual_position + Vector2(24, 4),
		0.12
	)

	tween.tween_property(
		bond1,
		"scale",
		Vector2(0.2, 1.0),
		0.10
	)

	tween.tween_property(
		bond2,
		"scale",
		Vector2(0.2, 1.0),
		0.10
	)

	tween.tween_property(
		bond3,
		"scale",
		Vector2(0.2, 1.0),
		0.10
	)

	tween.tween_property(
		bond1,
		"modulate:a",
		0.0,
		0.10
	)

	tween.tween_property(
		bond2,
		"modulate:a",
		0.0,
		0.10
	)

	tween.tween_property(
		bond3,
		"modulate:a",
		0.0,
		0.10
	)

	await tween.finished

	# Petita pausa perquè es percebi el trencament.
	await get_tree().create_timer(0.04).timeout

	# FASE 3: convertim les bases en X.
	left_base = "X"
	right_base = "X"
	update_visual()

	print("IR: fragment trencat/eliminat")
	tool_history.append("IR")

func apply_virus() -> void:
	if not can_apply_mutation():
		return

	mutation_type = "insertion"

	# Preparem el fragment viral.
	viral_insert.set_insert("C", "G")
	viral_insert.show()

	var original_insert_position: Vector2 = viral_insert.position

	viral_insert.scale = Vector2(0.2, 0.2)
	viral_insert.position = original_insert_position + Vector2(0, -18)

	# FASE 1: el fragment entra i apareix amb efecte pop.
	var entry_tween: Tween = create_tween()
	entry_tween.set_parallel(true)
	entry_tween.set_trans(Tween.TRANS_BACK)
	entry_tween.set_ease(Tween.EASE_OUT)

	entry_tween.tween_property(
		viral_insert,
		"scale",
		Vector2.ONE,
		0.18
	)

	entry_tween.tween_property(
		viral_insert,
		"position",
		original_insert_position,
		0.18
	)

	# Les bases reaccionen lleugerament quan entra el fragment.
	entry_tween.tween_property(
		left_dna_base,
		"position",
		original_left_visual_position + Vector2(-4, 0),
		0.18
	)

	entry_tween.tween_property(
		right_dna_base,
		"position",
		original_right_visual_position + Vector2(4, 0),
		0.18
	)

	entry_tween.tween_property(
		left_dna_base,
		"scale",
		Vector2(1.05, 1.05),
		0.12
	)

	entry_tween.tween_property(
		right_dna_base,
		"scale",
		Vector2(1.05, 1.05),
		0.12
	)

	await entry_tween.finished

	# FASE 2: les bases tornen a mida normal,
	# però mantenen la petita separació causada per la inserció.
	var settle_tween: Tween = create_tween()
	settle_tween.set_parallel(true)
	settle_tween.set_trans(Tween.TRANS_QUAD)
	settle_tween.set_ease(Tween.EASE_OUT)

	settle_tween.tween_property(
		left_dna_base,
		"scale",
		Vector2.ONE,
		0.08
	)

	settle_tween.tween_property(
		right_dna_base,
		"scale",
		Vector2.ONE,
		0.08
	)

	await settle_tween.finished

	update_visual()

	print("Virus: inserció de fragment")
	tool_history.append("VIRUS")

func apply_intercalant() -> void:
	if not can_apply_mutation():
		return

	mutation_type = "frameshift"

	# FASE 1: obertura progressiva de la parella.
	var open_tween: Tween = create_tween()
	open_tween.set_parallel(true)
	open_tween.set_trans(Tween.TRANS_QUAD)
	open_tween.set_ease(Tween.EASE_OUT)

	open_tween.tween_property(
		left_dna_base,
		"position",
		original_left_visual_position + Vector2(-35, 0),
		0.18
	)

	open_tween.tween_property(
		right_dna_base,
		"position",
		original_right_visual_position + Vector2(35, 0),
		0.18
	)

	open_tween.tween_property(
		bond1,
		"scale:x",
		1.45,
		0.18
	)

	open_tween.tween_property(
		bond2,
		"scale:x",
		1.45,
		0.18
	)

	open_tween.tween_property(
		bond3,
		"scale:x",
		1.45,
		0.18
	)

	await open_tween.finished

	# FASE 2: vibració curta de tensió.
	var start_pos: Vector2 = position

	var tension_tween: Tween = create_tween()
	tension_tween.set_trans(Tween.TRANS_LINEAR)

	tension_tween.tween_property(
		self,
		"position",
		start_pos + Vector2(-2, 0),
		0.025
	)

	tension_tween.tween_property(
		self,
		"position",
		start_pos + Vector2(2, 0),
		0.025
	)

	tension_tween.tween_property(
		self,
		"position",
		start_pos,
		0.025
	)

	await tension_tween.finished

	update_visual()

	print("Intercalant: ADN separat")
	tool_history.append("INTERCALAR")

func set_bases(new_left, new_right):
	left_base = new_left
	right_base = new_right

	original_left_base = new_left
	original_right_base = new_right

	mutation_type = "none"
	tool_history.clear()

	update_visual()

func update_bonds():
	if mutation_type == "deletion":
		bond1.visible = false
		bond2.visible = false
		bond3.visible = false
		return

	bond1.visible = true
	bond2.visible = true
	bond3.visible = false

	if left_base == "C" or left_base == "G":
		bond3.visible = true

func _on_basepair_mouse_entered() -> void:
	_animate_hover(Vector2(1.05, 1.05))

	var hover_color := Color("#BDEFFF")

	bond1.self_modulate = hover_color
	bond2.self_modulate = hover_color
	bond3.self_modulate = hover_color


func _on_basepair_mouse_exited() -> void:
	_animate_hover(Vector2.ONE)

	bond1.self_modulate = Color.WHITE
	bond2.self_modulate = Color.WHITE
	bond3.self_modulate = Color.WHITE


func _animate_hover(target_scale: Vector2) -> void:
	if hover_tween != null and hover_tween.is_valid():
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.set_trans(Tween.TRANS_QUAD)
	hover_tween.set_ease(Tween.EASE_OUT)
	hover_tween.tween_property(
		self,
		"scale",
		target_scale,
		0.12
	)

func play_scan_ping() -> void:
	if mutation_type == "none":
		return

	var original_modulate: Color = self_modulate

	var ping_tween: Tween = create_tween()
	ping_tween.set_parallel(true)
	ping_tween.set_trans(Tween.TRANS_QUAD)
	ping_tween.set_ease(Tween.EASE_OUT)

	ping_tween.tween_property(
		self,
		"scale",
		Vector2(1.10, 1.10),
		0.07
	)

	ping_tween.tween_property(
		self,
		"self_modulate",
		Color("#A7F4FF"),
		0.07
	)

	await ping_tween.finished

	var settle_tween: Tween = create_tween()
	settle_tween.set_parallel(true)
	settle_tween.set_trans(Tween.TRANS_QUAD)
	settle_tween.set_ease(Tween.EASE_OUT)

	settle_tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		0.10
	)

	settle_tween.tween_property(
		self,
		"self_modulate",
		original_modulate,
		0.10
	)

	await settle_tween.finished
