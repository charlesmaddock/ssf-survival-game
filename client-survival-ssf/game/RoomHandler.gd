tool
extends Node2D


const ROOM_DIMENSIONS = Vector2(16, 10)
const CORRIDOR_DIMENSIONS = Vector2(2, 8)


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


var test_spawn: int = -1


var mob_levels: Dictionary = {
	Constants.RoomDifficulties.EASY: [
		[
			{"mob": Constants.MobTypes.CLOUDER, "amount": 2, "more_per_player": 1}
		], 
		[
			{"mob": Constants.MobTypes.TURRET_CRAWLER, "amount": 2, "more_per_player": 1}
		], 
		[
			{"mob": Constants.MobTypes.MOLE, "amount": 2, "more_per_player": 1}
		],
	],
	Constants.RoomDifficulties.MEDIUM: [
		[
			{"mob": Constants.MobTypes.TURRET_CRAWLER, "amount": 3, "more_per_player": 1},
			{"mob": Constants.MobTypes.MOLE, "amount": 2, "more_per_player": 0.5}
		], 
		[
			{"mob": Constants.MobTypes.TURRET_CRAWLER, "amount": 2, "more_per_player": 1},
			{"mob": Constants.MobTypes.LOVE_BULL, "amount": 2, "more_per_player": 0.5}
		], 
		[
			{"mob": Constants.MobTypes.MOLE, "amount": 2, "more_per_player": 1},
			{"mob": Constants.MobTypes.LOVE_BULL, "amount": 2, "more_per_player": 0.5}
		], 
		[
			{"mob": Constants.MobTypes.CLOUDER, "amount": 2, "more_per_player": 1},
			{"mob": Constants.MobTypes.MOLE, "amount": 2, "more_per_player": 0.1},
		], 
		[
			{"mob": Constants.MobTypes.CHOWDER, "amount": 2, "more_per_player": 0.5},
		], 
	],
	Constants.RoomDifficulties.HARD: [
		[
			{"mob": Constants.MobTypes.CLOUDER, "amount": 1, "more_per_player": 1},
			{"mob": Constants.MobTypes.MOLE, "amount": 2, "more_per_player": 0.5},
			{"mob": Constants.MobTypes.CHOWDER, "amount": 1, "more_per_player": 0.1}
		], 
		[
			{"mob": Constants.MobTypes.CHOWDER, "amount": 2, "more_per_player": 0.5},
			{"mob": Constants.MobTypes.LOVE_BULL, "amount": 3, "more_per_player": 0.5},
		], 
		[
			{"mob": Constants.MobTypes.MOLE, "amount": 3, "more_per_player": 1},
			{"mob": Constants.MobTypes.CHOWDER, "amount": 3, "more_per_player": 0.5},
		], 
	]
}

var temp_mob_levels: Dictionary


func _generate_rooms() -> void:
	temp_mob_levels = mob_levels.duplicate(true) 
	var all_room_data = []
	var mob_i = 0
	yield(get_tree().create_timer(1), "timeout")

	for i in Constants.NUMBER_OF_ROOMS:
		var prev_room_data = null
		var final_room = i == Constants.NUMBER_OF_ROOMS - 1
		
		if i - 1 >= 0:
			prev_room_data = all_room_data[i - 1]
			var prev_corridor_size = prev_room_data.corridor_rect_size
		
		var mobs = []
		if i % 4 != 0:
			mob_i += 1
			mobs = generate_mobs(mob_i, final_room)
		
		var room_pos: Vector2 = Vector2.ZERO
		
		var prev_room_exit_direction = Constants.ExitDirections.NORTH
		var enter_pos = Vector2.ZERO
		var new_room_size = Vector2(ROOM_DIMENSIONS.x, ROOM_DIMENSIONS.y) + (Vector2.ONE * (clamp(mobs.size() / 2, 2, 4) - 2) * 2)
		
		if final_room:
			new_room_size = Vector2(16, 12)
		
		if prev_room_data != null:
			prev_room_exit_direction = prev_room_data.exit_dir
			match prev_room_exit_direction:
				Constants.ExitDirections.NORTH:
					enter_pos = prev_room_data.corridor_rect_pos + Vector2.UP
					room_pos = prev_room_data.corridor_rect_pos + Vector2(prev_room_data.corridor_rect_size.x / 2, 0) - Vector2(new_room_size.x / 2, new_room_size.y) 
				Constants.ExitDirections.EAST:
					enter_pos = prev_room_data.corridor_rect_end - Vector2(0, CORRIDOR_DIMENSIONS.x) 
					room_pos = prev_room_data.corridor_rect_end - Vector2(0, prev_room_data.corridor_rect_size.y / 2) - Vector2(0, new_room_size.y / 2) 
				Constants.ExitDirections.WEST:
					enter_pos = prev_room_data.corridor_rect_pos + Vector2.LEFT
					room_pos = prev_room_data.corridor_rect_pos + Vector2(0, prev_room_data.corridor_rect_size.y / 2) - Vector2(new_room_size.x, new_room_size.y / 2) 
		
		var room_rect = Rect2(room_pos, new_room_size)
		randomize()
		var available_directions = [Constants.ExitDirections.NORTH, Constants.ExitDirections.WEST, Constants.ExitDirections.EAST]
		if prev_room_data != null:
			if prev_room_data.exit_dir == Constants.ExitDirections.WEST:
				available_directions.erase(Constants.ExitDirections.EAST)
			elif prev_room_data.exit_dir == Constants.ExitDirections.EAST:
				available_directions.erase(Constants.ExitDirections.WEST)
		
		if i == Constants.NUMBER_OF_ROOMS - 2:
			available_directions = [Constants.ExitDirections.NORTH]
		
		var exit_dir: int = available_directions[randi() % available_directions.size()]
		var exit_pos: Vector2 = Vector2.ZERO
		var corridor_dim = Vector2.ZERO
		var corridor_pos: Vector2 = Vector2.ZERO
		
		match exit_dir:
			Constants.ExitDirections.NORTH:
				corridor_dim = Vector2(CORRIDOR_DIMENSIONS.x, CORRIDOR_DIMENSIONS.y)
				exit_pos = room_pos + Vector2(new_room_size.x / 2, 0) - Vector2(corridor_dim.x / 2, 0)
				corridor_pos = exit_pos - Vector2(0, corridor_dim.y)
			Constants.ExitDirections.EAST:
				corridor_dim = Vector2(CORRIDOR_DIMENSIONS.y, CORRIDOR_DIMENSIONS.x)
				exit_pos = room_pos + Vector2(new_room_size.x, new_room_size.y / 2) - Vector2(0, corridor_dim.y / 2) + Vector2.LEFT
				corridor_pos = exit_pos + Vector2.RIGHT
			Constants.ExitDirections.WEST:
				corridor_dim = Vector2(CORRIDOR_DIMENSIONS.y, CORRIDOR_DIMENSIONS.x)
				exit_pos = room_pos + Vector2(0, new_room_size.y / 2) - Vector2(0, corridor_dim.y / 2)
				corridor_pos = room_pos + Vector2(0, new_room_size.y / 2) - Vector2(corridor_dim.x, corridor_dim.y / 2)
		
		# Temp just so there is no corridor:
		if final_room:
			exit_pos = Vector2(1000, 1000)
			corridor_pos = Vector2(2000, 2000)
		if i == 0:
			enter_pos = Vector2(1000, 1000)
		
		var contains_bull: bool = false
		for mob_data in mobs:
			if mob_data.mob_type == Constants.MobTypes.LOVE_BULL:
				contains_bull = true
				break
		
		var room_type = Constants.RoomTypes.EMPTY
		
		if i > 0 && i % 4 == 0:
			var room_types = [Constants.RoomTypes.REVIVE, Constants.RoomTypes.LOOT]
			room_type = room_types[randi() % room_types.size()]
		elif contains_bull == true:
			room_type = Constants.RoomTypes.EMPTY
		elif i > 0:
			room_type = Constants.RoomTypes.CHIP
		elif i > 4:
			var room_types = [Constants.RoomTypes.SPIKES, Constants.RoomTypes.CHIP]
			room_type = room_types[randi() % room_types.size()]
		
		room_type = Constants.RoomTypes.LOOT
		
		if final_room:
			room_type = Constants.RoomTypes.BOSS
		
		var corridor_rect = Rect2(corridor_pos, corridor_dim)
		var data = {
			"room_type": room_type,
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
			"id": i
		}
		all_room_data.append(data)
	
	Server.rooms_generated(all_room_data)



func generate_mobs(i, final_room) -> Array:
	var mobs = []
	var difficulty = Constants.RoomDifficulties.HARD
	if i <= 3:
		difficulty = Constants.RoomDifficulties.EASY
	elif i <= 7:
		difficulty = Constants.RoomDifficulties.MEDIUM
	
	randomize()
	
	if i == 0 && test_spawn != -1:
		mobs.append({"mob_type": test_spawn, "pos": Vector2.ZERO})
	
	elif final_room:
		mobs.append({"mob_type": Constants.MobTypes.BOSS, "pos": Vector2(0, -100)})
		
	elif i != 0:
		if temp_mob_levels[difficulty].size() == 0:
			temp_mob_levels[difficulty] = mob_levels[difficulty].duplicate(true)
		
		var index = randi() % temp_mob_levels[difficulty].size()
		var mob_data_array: Array = temp_mob_levels[difficulty][index]
		
		temp_mob_levels[difficulty].remove(index)
		
		for mob_data in mob_data_array:
			var amount = mob_data.amount + int((Lobby.players_data.size() - 1) * mob_data.more_per_player)
			for i in amount:
				mobs.append({"mob_type": mob_data.mob, "pos": Vector2.ZERO})
			
	
	return mobs
