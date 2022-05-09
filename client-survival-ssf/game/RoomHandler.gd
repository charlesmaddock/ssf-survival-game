extends Node2D


const ROOM_DIMENSIONS = Vector2(14, 8)
const CORRIDOR_DIMENSIONS = Vector2(2, 8)


export(int) var _number_of_rooms: int = 9


var room_data = []
var _room_coordinates: PoolVector2Array = [Vector2(0, 0)]
#generate_rooms generar datan, emittar sedan signal till saker som ska göra allt som behövs
#ha en rect/bitmap och gör en set-cell utifrån den
#array med 2d-åunkter, kolla ifall kollision med andra rum
#is_host skickar packet med all data till clients (icl. host)


func _ready():
	Events.connect("rooms_generated", self, "_on_rooms_generated")
	
	if Lobby.is_host:
		_generate_rooms() 


func _on_rooms_generated(all_room_data: Array) -> void:
	var room_scene = load("res://game/Room.tscn")
	for room_data in all_room_data:
		print("room_data: ", room_data)
		var room = room_scene.instance()
		room.set_room_data(room_data)
		add_child(room)


func _generate_rooms() -> void:
	var current_pos = Vector2.ZERO
	var all_room_data = []
	for i in _number_of_rooms:
		var prev_room_data = null
		if i - 1 >= 0:
			prev_room_data = all_room_data[i - 1]
		
		var exit_pos = current_pos + Vector2(ROOM_DIMENSIONS.x / 2, 0)  - Vector2(CORRIDOR_DIMENSIONS.x / 2, 0)
		var corridor_pos = exit_pos + Vector2(0, ROOM_DIMENSIONS.y)
		var data = {
			"room_rect": Rect2(current_pos, ROOM_DIMENSIONS),
			"corridor_rect": Rect2(corridor_pos, CORRIDOR_DIMENSIONS),
			"door_pos": exit_pos,
			"id": i
		}
		current_pos -= Vector2(0, ROOM_DIMENSIONS.y + CORRIDOR_DIMENSIONS.y)
		all_room_data.append(data)
		
		Events.emit_signal("rooms_generated", all_room_data)
