extends Node3D
class_name ManaComponent

@onready var sprite_3d = $Sprite3D
@onready var progress_bar = $Sprite3D/SubViewport/ProgressBar

signal mana_changed

@export var max_mana: float = 100

var current_mana

func _ready():
	current_mana = max_mana
	update_mana_bar()

func spend(mana_amount:float):
	current_mana = clamp(current_mana - mana_amount, 0, max_mana)
	update_mana_bar()
	mana_changed.emit()
	
func restore(restore_amount: float):
	spend(-restore_amount)

func get_mana_percent():
	if max_mana <= 0:
		return 0	
	return min(current_mana/max_mana, 1)

func update_mana_bar():
	progress_bar.value = get_mana_percent()

func check_mana(amount):
	return amount <= current_mana
