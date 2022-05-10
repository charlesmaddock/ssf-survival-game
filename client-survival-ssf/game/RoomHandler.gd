extends Node2D


const ROOM_DIMENSIONS = Vector2(14, 8)
const CORRIDOR_DIMENSIONS = Vector2(2, 8)


export(int) var _number_of_rooms: int = 10


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
	for i in all_room_data.size():
		var room = room_scene.instance()
		var room_data: Dictionary = all_room_data[i]
		var next_room_data: Dictionary = {}
		if i + 1 < all_room_data.size():
			next_room_data = all_room_data[i + 1]
		room.set_room_data(room_data, next_room_data)
		add_child(room)


var mob_difficulties = {
	Constants.MobTypes.CHOWDER: 5,
	Constants.MobTypes.TURRET_CRAWLER: 3,
	Constants.MobTypes.MOLE: 2,
	Constants.MobTypes.CLOUDER: 1,
}

func _generate_rooms() -> void:
	var current_pos = Vector2.ZERO
	var all_room_data = []
	for i in _number_of_rooms:
		var prev_room_data = null
		var enter_pos = Vector2.ZERO
		var final_room = i == _number_of_rooms - 1
		print("final: ", final_room)
		if i - 1 >= 0:
			prev_room_data = all_room_data[i - 1]
			enter_pos = prev_room_data.exit_pos + Vector2.UP * prev_room_data.corridor_rect.size.y 
		
		var mobs = generate_mobs(i + 1)
		
		var exit_pos = current_pos + Vector2(ROOM_DIMENSIONS.x / 2, 0)  - Vector2(CORRIDOR_DIMENSIONS.x / 2, 0) 
		var corridor_pos = exit_pos - Vector2(0, ROOM_DIMENSIONS.y)
		
		# Temp just so there is no corridor:
		if final_room:
			exit_pos = Vector2(1000, 1000)
			corridor_pos = Vector2(2000, 2000)
		
		var data = {
			"room_rect": Rect2(current_pos, ROOM_DIMENSIONS),
			"corridor_rect": Rect2(corridor_pos, CORRIDOR_DIMENSIONS),
			"exit_pos": exit_pos,
			"enter_pos": enter_pos,
			"mobs": mobs,
			"id": i
		}
		current_pos -= Vector2(0, ROOM_DIMENSIONS.y + CORRIDOR_DIMENSIONS.y) + Vector2.UP
		all_room_data.append(data)
		
	Events.emit_signal("rooms_generated", all_room_data)


func generate_mobs(i) -> Array:
	var mobs = []
	var spawn_currency: float = i * 1.5 + floor(randf() * 2)
	var spawn_same_only: bool = false #i % 3 == 0
	var spawn_iterations: int = i + 1 
	
	for amount in spawn_iterations:
		for mob_diff_index in range(0, mob_difficulties.keys().size()):
			var mob_type = mob_difficulties.keys()[mob_diff_index]
			var spawn_cost = mob_difficulties.values()[mob_diff_index]
			randomize()
			if spawn_currency >= spawn_cost:
				if spawn_same_only == true:
					for x in i:
						mobs.append(mob_type)
					return mobs
				else:
					spawn_currency -= spawn_cost
					mobs.append(mob_type)
	
	return mobs
