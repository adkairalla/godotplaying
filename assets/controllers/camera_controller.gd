extends Node3D

@onready var camera_3d = $Pivot/Camera3D

var zoom_speed = 1
var max_zoom = 10
var min_zoom = 30

func _ready():
	rotate_y(-PI/2)

func _physics_process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	global_position = player.global_position
	play_animations(player)
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		play_animations(enemy)

func _input(event: InputEvent):
	if event is InputEventMouseMotion && Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		rotate_y(deg_to_rad(-event.relative.x))
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
		zoom_out()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
		zoom_in()
		
func zoom_out():
	if(camera_3d.size < min_zoom):
		camera_3d.size += zoom_speed

func zoom_in():
	if(camera_3d.size > max_zoom):
		camera_3d.size -= zoom_speed

func get_camera():
	return camera_3d

func get_camera_basis():
	return camera_3d.global_position.basis

func play_animations(character: CharacterBody3D):
	var camera_direction = Utils.get_direction(self)
	var character_direction = Utils.get_direction(character)
	var direction = camera_direction.signed_angle_to(character_direction, Vector3.UP)
#	print(rad_to_deg(direction))
	var angle_shift = PI/8
#	print(snapped(direction, PI/8))
	if abs(direction) < angle_shift:
#		print("n")
		character.play_animation("n")
	elif direction < -angle_shift && direction >= -3 * angle_shift:
#		print("ne")
		character.play_animation("ne")
	elif direction < -3 * angle_shift && direction >= -5 * angle_shift:
#		print("e")
		character.play_animation("e")
	elif direction < -5 * angle_shift && direction >= -7 * angle_shift:
#		print("se")
		character.play_animation("se")
	elif direction < -7 * angle_shift || direction > 7 * angle_shift:
#		print("s")
		character.play_animation("s")
	elif direction > angle_shift && direction <= 3 * angle_shift:
#		print("nw")
		character.play_animation("nw")
	elif direction > 3 * angle_shift && direction <= 5 * angle_shift:
#		print("w")
		character.play_animation("w")
	elif direction > 5 * angle_shift && direction <= 7 * angle_shift:
#		print("sw")
		character.play_animation("sw")
	return Vector3.ZERO
