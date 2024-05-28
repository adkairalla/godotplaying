extends Node3D
class_name HealthComponent

@onready var sprite_3d = $Sprite3D
@onready var progress_bar = $Sprite3D/SubViewport/ProgressBar

signal died
signal health_changed

@export var max_health: float = 100

var current_health

func _ready():
	current_health = max_health
	update_health_bar()

func damage(damage_amount:float):
	current_health = clamp(current_health - damage_amount, 0, max_health)
	update_health_bar()
	health_changed.emit()
	Callable(check_death).call_deferred()
	
func heal(heal_amount: float):
	damage(-heal_amount)

func get_health_percent():
	if max_health <= 0:
		return 0
	
	return min(current_health/max_health, 1)

func check_death():
	if current_health == 0:
		print("Died, not dying though")
		died.emit()
#		owner.queue_free()

func update_health_bar():
	progress_bar.value = current_health/max_health
