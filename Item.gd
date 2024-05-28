extends Node2D

var item_name
var item_quantity

func _ready():
	var stack_size = 0
	if randi() % 2 == 0:
		$TextureRect.texture = load("res://assets/sprites/inventory/Iron Sword.png")
		stack_size = 1
	else:
		$TextureRect.texture = load("res://assets/sprites/inventory/Blue jeans.png")
		stack_size = 99

	item_quantity = randi() % stack_size + 1
	
	if stack_size == 1:
		$Label.visible = false
	else:
		$Label.visible = true
	
	$Label.text = str(item_quantity)

func add_item_quantity(amount_to_add):
	item_quantity += amount_to_add
	$Label.text = str(item_quantity)

func decrease_item_quantity(amount_to_remove):
	item_quantity -= amount_to_remove
	$Label.text = str(item_quantity)
