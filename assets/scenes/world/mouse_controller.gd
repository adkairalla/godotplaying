extends Node3D

const RAY_LENGTH = 1000

@onready var camera_controller = $"../CameraController"
@onready var mouse_cursor_grid = $"../MouseCursorGrid"
@onready var bowling_bash_controller = %BowlingBashController
@onready var storm_gust_controller = %StormGustController

@onready var player = %Player

var grid_position : Vector3

var mouse_grid_pos : Vector3
var using_skill = false
var using_spell = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	var space_state = get_world_3d().direct_space_state
	var mousepos = get_viewport().get_mouse_position()

	var origin = camera_controller.get_camera().project_ray_origin(mousepos)
	var end = origin + camera_controller.get_camera().project_ray_normal(mousepos) * RAY_LENGTH
#	print(origin, end)
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)
	if !result.is_empty():
		grid_position = mouse_cursor_grid.local_to_map(result["position"])
		change_color()
	else:
		grid_position = Vector3.UP

func _unhandled_input(event):
	if event.is_action_pressed("left_click"):
		if using_skill:
			var player_grid_position = mouse_cursor_grid.local_to_map(player.global_position)
			var mouse_player_vector = grid_position - Vector3(player_grid_position)
			var calc_rotation = mouse_player_vector.signed_angle_to(Vector3.MODEL_FRONT, Vector3.UP)
			player.cast_bowling_bash(-calc_rotation)
			using_skill = false
		elif using_spell:
			player.cast_storm_gust(mouse_cursor_grid.map_to_local(grid_position))
			using_spell = false
		else:
			if grid_position != Vector3.UP:
				player.navigation = true
				player.set_target_position(grid_position)
				get_viewport().set_input_as_handled()
	if event.is_action_pressed("right_click") && using_skill:
		using_skill = false
		using_spell = false
	if event.is_action_pressed("cast_1"):
		using_spell = false
		using_skill = true
	if event.is_action_pressed("cast_2"):
		using_skill = false
		using_spell = true

func change_color():
	mouse_cursor_grid.clear()
	grid_position.y -= 1
	mouse_cursor_grid.set_cell_item(grid_position, 2)
	if using_skill:
		mark_floor_bowling_bash()
	if using_spell:
		mark_floor_storm_gust()

func mark_floor_bowling_bash():
	var player_grid_position = mouse_cursor_grid.local_to_map(player.global_position)
	player_grid_position.y = 0
	var mouse_player_vector = Vector3(player_grid_position) - grid_position
	player_grid_position.y = 0
	var calc_rotation = mouse_player_vector.signed_angle_to(Vector3.FORWARD, Vector3.UP)
	
	var skill_format = PackedVector3Array()
	#middle line
	skill_format.append(Vector3(0,0,1))
	skill_format.append(Vector3(0,0,2))
	skill_format.append(Vector3(0,0,3))
	skill_format.append(Vector3(0,0,4))
	#side line up
	skill_format.append(Vector3(1,0,2))
	skill_format.append(Vector3(1,0,3))
	skill_format.append(Vector3(1,0,4))
	#side line down
	skill_format.append(Vector3(-1,0,2))
	skill_format.append(Vector3(-1,0,3))
	skill_format.append(Vector3(-1,0,4))
	#next line up
	skill_format.append(Vector3(2,0,3))
	skill_format.append(Vector3(2,0,4))
	#next line down
	skill_format.append(Vector3(-2,0,3))
	skill_format.append(Vector3(-2,0,4))
	#points
	skill_format.append(Vector3(-3,0,4))
	skill_format.append(Vector3(3,0,4))
	skill_format = Utils.rotate_points(skill_format, calc_rotation)
	for cell in skill_format:
		mouse_cursor_grid.set_cell_item(cell + Vector3(player_grid_position), 3)

func mark_floor_storm_gust():
	var skill_format = PackedVector3Array()
	
	skill_format.append(Vector3(0,0,1))
	skill_format.append(Vector3(0,0,2))
	skill_format.append(Vector3(0,0,3))
	#side line up
	skill_format.append(Vector3(0,0,-1))
	skill_format.append(Vector3(0,0,-2))
	skill_format.append(Vector3(0,0,-3))
	#side line down
	skill_format.append(Vector3(1,0,0))
	skill_format.append(Vector3(2,0,0))
	skill_format.append(Vector3(3,0,0))
	#next line up
	skill_format.append(Vector3(-1,0,0))
	skill_format.append(Vector3(-2,0,0))
	skill_format.append(Vector3(-3,0,0))

	for cell in skill_format:
		mouse_cursor_grid.set_cell_item(cell + grid_position, 3)
