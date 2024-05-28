extends Node
class_name VelocityComponent

@export var max_speed = 5
@export var acceleration = 0
@export var fall_acceleration = 50
@export var jump_impulse = 12

var terrain_grid : GridMap
var target_velocity : Vector3 = Vector3.ZERO
var velocity = Vector3.ZERO

var jump = false

func _ready():
	terrain_grid = get_tree().get_first_node_in_group("terrain") as GridMap

func accelerate_to_player():
	var owner_node3d = owner
	if !owner_node3d:
		return
		
	var player = get_tree().get_first_node_in_group("player") as Node3D
	if !player:
		return
	
	var player_direction = (player.global_position - owner_node3d.global_position).normalized()
	accelerate_in_direction(player_direction)

func accelerate_in_direction(direction: Vector3):
	var save_velocity_y = velocity.y
	direction.y = 0
	velocity = direction * max_speed
	velocity = velocity.limit_length(max_speed)
	velocity.y = save_velocity_y
	
func decelerate():
	accelerate_in_direction(Vector3.ZERO)

func drag_to_grid(character_body: CharacterBody3D):
	if velocity == Vector3.ZERO:
		var grid_position = terrain_grid.local_to_map(character_body.global_position)
		var desired_position = terrain_grid.map_to_local(grid_position)
		if abs(character_body.global_position - desired_position).length() < 0.7:
			return
		desired_position.y = character_body.position.y
		character_body.global_position = lerp(character_body.global_position, desired_position, 0.05)

func move(character_body: CharacterBody3D, delta):
	if character_body.is_on_floor():
		if jump:
			jump = false
			velocity.y = jump_impulse
		else:
			velocity.y = 0
	else:
		velocity.y = velocity.y - (fall_acceleration * delta)
	character_body.velocity = velocity
	character_body.move_and_slide()
	velocity = character_body.velocity

func knockback(origin: Vector3, ammount: float):
	var knockback_direction = (origin - owner.global_position).normalized()
	velocity = knockback_direction * -1 * ammount
	move(owner, get_process_delta_time())
