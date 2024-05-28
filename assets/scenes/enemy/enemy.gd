extends CharacterBody3D

@onready var player_walk_grid : GridMap = %PlayerWalkGrid
@onready var navigation_agent = $NavigationAgent3D
@onready var animated_sprite = $AnimatedSprite3D
@onready var velocity_component = $VelocityComponent
@onready var player = %Player

var navigation = true
var casting = false

@onready var target_position : Vector3 = global_position
@onready var health_component = $HealthComponent


var RAY_LENGTH = 20
var activity = "idle"
var direction = Vector3.ZERO
var nav_wait = 0
var attack_range = 1.5

func _ready():
	velocity_component.max_speed = 2
	animated_sprite.set_modulate(Color.RED)

func _physics_process(delta):
	set_target_position(player.global_position)
	if nav_wait > 5:
		direction = navigation_movement(delta)
	else:
		nav_wait = nav_wait+1
		return
	
	if $AnimationPlayer.is_playing():
		return
	
	activity_update()
	check_floor()
	
	velocity_component.accelerate_in_direction(direction)
	update_look_direction()
	velocity_component.move(self, delta)
	
	if is_player_in_range():
		activity = "attack"
		attack_player()
		return

func attack_player():
	$AnimationPlayer.play("attack")

func is_player_in_range():
	if player.global_position.distance_to(global_position) < attack_range:
		return true
	return false

func activity_update():
	if activity == "attack":
		return
	elif velocity == Vector3.ZERO:
		activity = "idle"
	else:
		activity = "walk"
	
func navigation_movement(_delta):
	var new_direction = Vector3.ZERO
	
	navigation_agent.target_position = self.target_position
	new_direction = navigation_agent.get_next_path_position() - global_position
	new_direction = new_direction.normalized()
	
	if navigation_agent.is_navigation_finished():
		navigation = false
		velocity_component.decelerate()
	
	return new_direction

func check_floor():
	var space_state = get_world_3d().direct_space_state

	var origin = global_position
	var end = global_position + RAY_LENGTH * Vector3.DOWN
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	if !result.is_empty():
		change_grid_walk(player_walk_grid.local_to_map(result["position"]))

func change_grid_walk(coords):
	coords.y -= 1
	player_walk_grid.clear()
	player_walk_grid.set_cell_item(coords, 3)

func update_look_direction():
	var compare = velocity
	compare.y = 0
	if !compare.is_equal_approx(Vector3.ZERO) && abs(global_position + compare).normalized() != Vector3.UP:
		self.look_at(global_position + velocity, Vector3.UP, true)

func play_animation(animation: String):
	if activity == "attack":
		activity = "cast"
	if activity == "idle" || activity == "cast":
		if animation == "e":
			animation = "se"
		elif animation == "w":
			animation = "sw"
		elif animation == "n":
			animation = "ne"
		elif animation == "s":
			animation = "sw"
	animated_sprite.play(activity + "_" + animation)

func set_target_position(new_position):
	var target_position_adjustment = new_position - global_position
	target_position_adjustment = target_position_adjustment.limit_length(.5)
	target_position = new_position - target_position_adjustment
