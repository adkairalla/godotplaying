extends Node3D

const pick_up_scene = preload("res://assets/scenes/interactable/pick_up.tscn")

@onready var player = %Player
@onready var inventory_interface: Control = %InventoryInterface

func _ready() -> void:
	inventory_interface.drop_slot_data.connect(_on_inventory_interface_drop_slot_data)
	inventory_interface.set_player_inventory_data(player.inventory_data)
	player.toggle_inventory.connect(on_toggle_inventory)
	
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_inventory.connect(on_toggle_inventory)
	
func on_toggle_inventory(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		
	if external_inventory_owner && inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()

func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	print("?")
	var pick_up = pick_up_scene.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = player.get_drop_position()
	add_child(pick_up)
