tool
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
	Server.connect("packet_received", self, "_on_packet_received")
	
	if Lobby.is_host:
		_generate_rooms() 


func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.ROOMS_GENERATED:
		_on_rooms_generated(packet.rooms)


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


#From highest cost to lowest - otherwise generate_mobs() breaks
var mob_difficulties = {
	Constants.MobTypes.CHOWDER: 6,
	Constants.MobTypes.LOVE_BULL: 4,
	Constants.MobTypes.MOLE: 3,
	Constants.MobTypes.TURRET_CRAWLER: 2,
	Constants.MobTypes.CLOUDER: 1,
}


func _generate_rooms() -> void:
	var all_room_data = []
	yield(get_tree().create_timer(0.2), "timeout")
	for i in _number_of_rooms:
		var prev_room_data = null
		var final_room = i == _number_of_rooms - 1
		if i - 1 >= 0:
			prev_room_data = all_room_data[i - 1]
			var prev_corridor_size = prev_room_data.corridor_rect_size
		
		var mobs = generate_mobs(i)
		var env = generate_environment(i + 1)
		
		var room_pos: Vector2 = Vector2.ZERO
		
		var prev_room_exit_direction = Constants.ExitDirections.NORTH
		var enter_pos = Vector2.ZERO
		
		if prev_room_data != null:
			prev_room_exit_direction = prev_room_data.exit_dir
			match prev_room_exit_direction:
				Constants.ExitDirections.NORTH:
					enter_pos = prev_room_data.corridor_rect_pos + Vector2.UP
					room_pos = prev_room_data.corridor_rect_pos + Vector2(prev_room_data.corridor_rect_size.x / 2, 0) - Vector2(ROOM_DIMENSIONS.x / 2, ROOM_DIMENSIONS.y) 
				Constants.ExitDirections.EAST:
					enter_pos = prev_room_data.corridor_rect_end - Vector2(0, CORRIDOR_DIMENSIONS.x) 
					room_pos = prev_room_data.corridor_rect_end - Vector2(0, prev_room_data.corridor_rect_size.y / 2) - Vector2(0, ROOM_DIMENSIONS.y / 2) 
				Constants.ExitDirections.WEST:
					enter_pos = prev_room_data.corridor_rect_pos + Vector2.LEFT
					room_pos = prev_room_data.corridor_rect_pos + Vector2(0, prev_room_data.corridor_rect_size.y / 2) - Vector2(ROOM_DIMENSIONS.x, ROOM_DIMENSIONS.y / 2) 
		
		var room_rect = Rect2(room_pos, ROOM_DIMENSIONS)
		randomize()
		var available_directions = [Constants.ExitDirections.NORTH, Constants.ExitDirections.WEST, Constants.ExitDirections.EAST]
		if prev_room_data != null:
			if prev_room_data.exit_dir == Constants.ExitDirections.WEST:
				available_directions.erase(Constants.ExitDirections.EAST)
			elif prev_room_data.exit_dir == Constants.ExitDirections.EAST:
				available_directions.erase(Constants.ExitDirections.WEST)
		
		if i == _number_of_rooms - 2:
			available_directions = [Constants.ExitDirections.NORTH]
		
		var exit_dir: int = available_directions[randi() % available_directions.size()]
		var exit_pos: Vector2 = Vector2.ZERO
		var corridor_dim = Vector2.ZERO
		var corridor_pos: Vector2 = Vector2.ZERO
		
		match exit_dir:
			Constants.ExitDirections.NORTH:
				corridor_dim = Vector2(CORRIDOR_DIMENSIONS.x, CORRIDOR_DIMENSIONS.y)
				exit_pos = room_pos + Vector2(ROOM_DIMENSIONS.x / 2, 0) - Vector2(corridor_dim.x / 2, 0)
				corridor_pos = exit_pos - Vector2(0, corridor_dim.y)
			Constants.ExitDirections.EAST:
				corridor_dim = Vector2(CORRIDOR_DIMENSIONS.y, CORRIDOR_DIMENSIONS.x)
				exit_pos = room_pos + Vector2(ROOM_DIMENSIONS.x, ROOM_DIMENSIONS.y / 2) - Vector2(0, corridor_dim.y / 2) + Vector2.LEFT
				corridor_pos = exit_pos + Vector2.RIGHT
			Constants.ExitDirections.WEST:
				corridor_dim = Vector2(CORRIDOR_DIMENSIONS.y, CORRIDOR_DIMENSIONS.x)
				exit_pos = room_pos + Vector2(0, ROOM_DIMENSIONS.y / 2) - Vector2(0, corridor_dim.y / 2)
				corridor_pos = room_pos + Vector2(0, ROOM_DIMENSIONS.y / 2) - Vector2(corridor_dim.x, corridor_dim.y / 2)
		
		# Temp just so there is no corridor:
		if final_room:
			exit_pos = Vector2(1000, 1000)
			corridor_pos = Vector2(2000, 2000)
		
		var corridor_rect = Rect2(corridor_pos, corridor_dim)
		var data = {
			"exit_dir": exit_dir,
			"enter_dir": prev_room_exit_direction,
			"room_rect_pos": room_rect.position,
			"room_rect_end": room_rect.end,
			"room_rect_size": room_rect.size,
			"corridor_rect_pos": corridor_rect.position,
			"corridor_rect_end": corridor_rect.end,
			"corridor_rect_size": corridor_rect.size,
			"exit_pos": exit_pos,
			"enter_pos": enter_pos,
			"mobs": mobs,
			"env": env,
			"id": i
		}
		all_room_data.append(data)
	
	Server.rooms_generated(all_room_data)


func generate_environment(i) -> Array:
	var environment = []
	return environment


func generate_mobs(i) -> Array:
	var mobs = []
	var spawn_currency: float = i * 1.5
	var spawn_iterations: int = i + 1 
	
	if i == _number_of_rooms:
		mobs.append({"mob_type": Constants.MobTypes.ROMANS_BOSS, "pos": Vector2(0, -60)})
	elif i != 0:
		if i < mob_difficulties.keys().size():
			for n in (mob_difficulties.keys().size() - (i - 1)):
				mobs.append({"mob_type": mob_difficulties.keys()[mob_difficulties.keys().size() - i], "pos": Vector2.ZERO})
		else:
			for amount in spawn_iterations:
				for mob_diff_index in range(0, mob_difficulties.keys().size()):
					var mob_type = mob_difficulties.keys()[mob_diff_index]
					var spawn_cost = mob_difficulties.values()[mob_diff_index]
					randomize()
					if spawn_currency >= spawn_cost:
							spawn_currency -= spawn_cost
							mobs.append({"mob_type": mob_type, "pos": Vector2.ZERO})
	return mobs
