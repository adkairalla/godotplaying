extends Node3D

@export var storm_gust : PackedScene

var base_damage = 10
var additional_damage_percent = 1.0
var knockback = 80
var mana_cost = 20
var cast_time = 3

var target_position : Vector3

func begin_cast(cast_position:Vector3):
	var player = get_tree().get_first_node_in_group("player")
	if !player:
		return
	
	if !player.check_mana(mana_cost):
		print("No mana for storm gust!")
		return
	
	player.cast(mana_cost, cast_time)
	target_position = cast_position

func finish_cast():
	
	var storm_gust_instance = storm_gust.instantiate() as StormGust
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(storm_gust_instance)
	
	storm_gust_instance.hitbox_component.damage = base_damage
	storm_gust_instance.hitbox_component.knockback = knockback
	storm_gust_instance.global_position = target_position
	storm_gust_instance.global_position.y += 2
