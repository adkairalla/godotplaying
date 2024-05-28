extends Node3D

@export var bowling_bash : PackedScene

var base_damage = 5
var additional_damage_percent = 1.0
var knockback = 100
var mana_cost = 5
var cast_time = 0
var base_wait_time
var angle

func begin_cast(casting_angle: float):
	var player = get_tree().get_first_node_in_group("player")
	if !player:
		return
	
	if !player.check_mana(mana_cost):
		print("No mana for bowling bash!")
		return
		
	angle = casting_angle
	player.cast(mana_cost, 0)

func finish_cast():
	var player = get_tree().get_first_node_in_group("player")
	if !player:
		return
		
	var bowling_bash_instance = bowling_bash.instantiate()
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(bowling_bash_instance)
	
#	var player_direction = Utils.get_direction(player)
#	bowling_bash_instance.rotation.y = Vector3.FORWARD.signed_angle_to(player_direction, Vector3.UP)
	bowling_bash_instance.hitbox_component.damage = base_damage
	bowling_bash_instance.hitbox_component.knockback = knockback
	bowling_bash_instance.rotation.y = angle
	player.rotation.y = angle
	bowling_bash_instance.global_position = player.global_position + Vector3.MODEL_FRONT.rotated(Vector3.UP, angle)
	

#func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
#	if upgrade.id == "sword_rate":
#		var percent_reduction = current_upgrades["sword_rate"]["quantity"] * 0.1
#		$Timer.wait_time = base_wait_time * (1 - percent_reduction)
#		$Timer.start()
#	elif upgrade.id == "sword_damage":
#		additional_damage_percent = 1 + current_upgrades["sword_damage"]["quantity"] * 0.15
