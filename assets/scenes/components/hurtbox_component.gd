extends Area3D
class_name HurtboxComponent

signal hit

@export var health_component: HealthComponent
@export var velocity_component: VelocityComponent

var floating_text_scene = preload("res://assets/scenes/UI/floating_text.tscn")

func _ready():
	area_entered.connect(on_area_entered)

func on_area_entered(other_area : Area3D):
	if not other_area is HitboxComponent:
		return
	
	print("ouch")
	if !health_component:
		return
	
	var hitbox_component = other_area as HitboxComponent
	hit.emit()
	health_component.damage(hitbox_component.damage)
	
	var floating_text = floating_text_scene.instantiate() as Node3D
	get_tree().get_first_node_in_group("foreground_layer").add_child(floating_text)
	
	floating_text.global_position = global_position + (Vector3.UP * 1.5)
	var format_string = "%0.1f"
	if round(hitbox_component.damage) == hitbox_component.damage:
		format_string = "%0.0f"
	floating_text.start(format_string % hitbox_component.damage)
	if hitbox_component.knockback != 0:
		velocity_component.knockback(hitbox_component.global_position, hitbox_component.knockback)
