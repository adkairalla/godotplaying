extends CharacterBody3D

@export var inventory_data : InventoryData

signal toggle_inventory()

@onready var navigation_agent = $NavigationAgent3D
@onready var animated_sprite = $AnimatedSprite3D
@onready var velocity_component = $VelocityComponent
@onready var player_walk_grid = %PlayerWalkGrid
@onready var target_position : Vector3 = global_position
@onready var mana_component : ManaComponent = $ManaComponent
@onready var cast_component : CastComponent = $CastComponent
@onready var interact_ray = $InteractRay

var camera_controller : Node3D
var RAY_LENGTH = 20
var activity = "idle"
var direction = Vector3.ZERO
var navigation = false
var casting = false
var spell_controller = null

func _ready():
	camera_controller = get_tree().get_first_node_in_group("camera_controller")

func _physics_process(delta):
	if !casting:
		direction = input_movement(delta)
		if navigation:
			direction = navigation_movement(delta)
		activity_update()
		check_floor()
		jump()
		velocity_component.accelerate_in_direction(direction)
		update_look_direction()
		velocity_component.move(self, delta)
	else:
		print("is casting!")

func _unhandled_input(event) -> void:
	if Input.is_action_just_pressed("inventory_action"):
		toggle_inventory.emit()
	elif Input.is_action_just_pressed("interact"):
		if interact_ray.is_colliding():
			interact_ray.get_collider().player_interact()

func activity_update():
	if velocity == Vector3.ZERO:
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
	var velocity_ignore_y = velocity
	velocity_ignore_y.y = 0
	if velocity_ignore_y != Vector3.ZERO:
		self.look_at(global_position + velocity_ignore_y, Vector3.UP, true)

func input_movement(delta):
	var input := Vector3.ZERO
	var new_direction = Vector3.ZERO
	var camera_basis: Basis = camera_controller.get_camera().global_transform.basis
	
	if Input.is_action_pressed("forward"):
		input.z -= 1
	if Input.is_action_pressed("backward"):
		input.z += 1
	if Input.is_action_pressed("left"):
		input.x -= 1
	if Input.is_action_pressed("right"):
		input.x += 1
	
	if input != Vector3.ZERO && navigation:
		navigation = false
	elif navigation:
		return
		
	if input == Vector3.ZERO:
		velocity_component.decelerate()
		velocity_component.move(self, delta)
		velocity_component.drag_to_grid(self)
		return Vector3.ZERO
	
	new_direction = camera_basis * input
	new_direction = new_direction.normalized()
	
	return new_direction

func play_animation(animation: String):
	if activity == "idle" || activity == "cast":
		if animation == "e":
			animation = "se"
		elif animation == "w":
			animation = "sw"
		elif animation == "n":
			animation = "ne"
		elif animation == "s":
			animation = "sw"
	
	if casting:
		animated_sprite.play(activity + "_" + animation)
		animated_sprite.set_frame_and_progress(1, 0)
		animated_sprite.pause()
	else:
		if !animated_sprite.is_playing():
			animated_sprite.play()
		else:
			animated_sprite.play(activity + "_" + animation)

func set_target_position(new_position):
	var target_position_adjustment = new_position - global_position
	target_position_adjustment = target_position_adjustment.limit_length(.5)
	target_position = new_position + target_position_adjustment

func jump():
	if Input.is_action_just_pressed("jump"):
		velocity_component.jump = true;

func cast_storm_gust(target):
	spell_controller = %StormGustController
	var cost = spell_controller.mana_cost
	var cast_time = spell_controller.cast_time
	if spell_controller.begin_cast(target):
		cast(cost, cast_time)

func cast_bowling_bash(target_direction):
	spell_controller = %BowlingBashController
	var cost = spell_controller.mana_cost
	var cast_time = spell_controller.cast_time
	if spell_controller.begin_cast(target_direction):
		cast(cost, cast_time)

func cast(mana_cost, cast_time):
	cast_component.casting_finished.connect(on_casting_finished)
	casting = true
	activity = "cast"
	cast_component.cast(cast_time)
	mana_component.spend(mana_cost)

func check_mana(amount):
	return mana_component.check_mana(amount)

func on_casting_finished():
	cast_component.casting_finished.disconnect(on_casting_finished)
	spell_controller.finish_cast()
	print("settings casting to false")
	casting = false
	print("casting: ", casting)
	activity = "idle"
	print("hmm", activity)
	print("casting is finished")

func get_drop_position() -> Vector3:
	var direction = global_transform.basis.z
	return global_position + direction
