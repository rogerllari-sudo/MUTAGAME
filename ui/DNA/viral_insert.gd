extends Node2D

@onready var left_base = $LeftDNABase
@onready var right_base = $RightDNABase

func _ready():
	set_insert("C", "G")

func set_insert(left, right):
	left_base.set_base(left)
	right_base.set_base(right)
