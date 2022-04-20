extends Control


export(bool) var can_drag_to = true


var available: bool = true


signal item_placed(item)
signal item_removed()


func try_set_item(item, dragged_to) -> bool:
	if dragged_to == true && can_drag_to == false:
		return false  
	
	item.position = rect_global_position + rect_size / 2
	available = false
	var prev_inventory_slot = item.get_inventory_slot()
	if prev_inventory_slot != null:
		prev_inventory_slot.remove_item()
	item.set_inventory_slot(self)
	emit_signal("item_placed", item)
	return true


func remove_item() -> void:
	emit_signal("item_removed")
	available = true
