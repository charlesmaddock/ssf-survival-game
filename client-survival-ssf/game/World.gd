extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("rooms_generated", self, "_on_rooms_generated")


func _on_rooms_generated(all_room_data: Array) -> void:
	for room_data in all_room_data:
		var room_rect = room_data.room_rect
		var corridor_rect = room_data.corridor_rect
		
		for y in range(room_rect.position.y , room_rect.end.y ):
			for x in range(room_rect.position.x , room_rect.end.x ): 
				if y == 0 || x == 0 || y == room_rect.end.y|| x == room_rect.end.x:
					set_cell(x, y, 6)
				else:
					set_cell(x, y, 1)
		
		for y in range(corridor_rect.position.y, corridor_rect.end.y):
			for x in range(corridor_rect.position.x, corridor_rect.end.x): 
				set_cell(x, y, 1)
	
	update_bitmask_region()
