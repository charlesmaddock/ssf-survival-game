extends VBoxContainer


export(NodePath) var inventory_path


var crafting_item_1 = null
var crafting_item_2 = null


# Called when the node enters the scene tree for the first time.
func _ready():
	$CraftingSlots/InventorySlot.connect("item_placed", self, "_on_slot_1_placed")
	$CraftingSlots/InventorySlot2.connect("item_placed", self, "_on_slot_2_placed")
	
	$CraftingSlots/InventorySlot.connect("item_removed", self, "_on_slot_1_removed")
	$CraftingSlots/InventorySlot2.connect("item_removed", self, "_on_slot_2_removed")


func _on_slot_1_placed(item) -> void:
	crafting_item_1 = item
	check_crafting()


func _on_slot_2_placed(item) -> void:
	crafting_item_2 = item
	check_crafting()


func _on_slot_1_removed() -> void:
	crafting_item_1 = null


func _on_slot_2_removed() -> void:
	crafting_item_2 = null


func check_crafting() -> void:
	for recipe_array in Constants.crafting_recipes:
		if crafting_item_1 == null || crafting_item_2 == null:
			print("Not enough items")
			return 
		
		if recipe_array[0] == crafting_item_1.item_type && recipe_array[1] == crafting_item_2.item_type || recipe_array[1] == crafting_item_1.item_type && recipe_array[0] == crafting_item_2.item_type:
			Server.spawn_item(recipe_array[2], get_node(inventory_path).get_parent().global_position)
			crafting_item_1.queue_free()
			crafting_item_1 = null
			crafting_item_2.queue_free()
			crafting_item_2 = null
