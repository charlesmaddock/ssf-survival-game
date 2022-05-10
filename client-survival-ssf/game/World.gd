extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("rooms_generated", self, "_on_rooms_generated")


func _on_rooms_generated(all_room_data: Array) -> void:
	for room_data in all_room_data:
		var room_rect = room_data.room_rect
		var corridor_rect = room_data.corridor_rect
		var exit_pos = room_data.exit_pos
		var enter_pos = room_data.enter_pos
		
		for y in range(room_rect.position.y, room_rect.end.y):
			for x in range(room_rect.position.x, room_rect.end.x): 
				if y == room_rect.position.y || x == room_rect.position.x || y == room_rect.end.y - 1 || x == room_rect.end.x - 1:
					set_cell(x, y, 6)
				else:
					set_cell(x, y, 1)
		
		for y in range(corridor_rect.position.y, corridor_rect.end.y):
			for x in range(corridor_rect.position.x - 1, corridor_rect.end.x + 1): 
				if x == corridor_rect.position.x - 1 || x == corridor_rect.end.x:
					set_cell(x, y, 6)
				else:
					set_cell(x, y, 1)
		
		for i in 2:
			set_cell(exit_pos.x + i, exit_pos.y, 1)
		
		if enter_pos != Vector2.ZERO:
			for i in 2:
				set_cell(enter_pos.x + i, enter_pos.y, 1)
	
	update_bitmask_region()
