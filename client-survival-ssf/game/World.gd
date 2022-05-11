extends TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	Server.connect("packet_received", self, "_on_packet_received")



func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.ROOMS_GENERATED:
		_on_rooms_generated(packet.rooms)


func _on_rooms_generated(all_room_data: Array) -> void:
	print("all_room_data: ", all_room_data)
	for rd in all_room_data:
		var exit_pos = rd.exit_pos
		var enter_pos = rd.enter_pos
		
		for y in range(rd.room_rect_pos.y, rd.room_rect_end.y):
			for x in range(rd.room_rect_pos.x, rd.room_rect_end.x): 
				if y == rd.room_rect_pos.y || x == rd.room_rect_pos.x || y == rd.room_rect_end.y - 1 || x == rd.room_rect_end.x - 1:
					set_cell(x, y, 6)
				else:
					set_cell(x, y, 1)
		
		for y in range(rd.corridor_rect_pos.y, rd.corridor_rect_end.y):
			for x in range(rd.corridor_rect_pos.x - 1, rd.corridor_rect_end.x + 1): 
				if x == rd.corridor_rect_pos.x - 1 || x == rd.corridor_rect_end.x:
					set_cell(x, y, 6)
				else:
					set_cell(x, y, 1)
		
		for i in 2:
			set_cell(exit_pos.x + i, exit_pos.y, 1)
		
		if enter_pos.x != 0 && enter_pos.y != 0:
			for i in 2:
				set_cell(enter_pos.x + i, enter_pos.y, 1)
	
	update_bitmask_region()
