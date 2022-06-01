extends Node2D

var pino_scene: PackedScene = preload("res://entities/Pino.tscn")


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

func _spawn_pino(pino_global_position: Vector2) -> void:
	var pino: Node2D = pino_scene.instance()
	pino.global_position = pino_global_position
	var entities: YSort = $"../Entities"
	entities.add_child(pino)


func _generate_rooms() -> void:
	var current_pos = Vector2.ZERO
	var all_room_data = []
	yield(get_tree().create_timer(1), "timeout")
	for i in _number_of_rooms:
		
#		if i == 0:
#			_spawn_pino(Vector2(100, 100))
		
		
		var prev_room_data = null
		var enter_pos = Vector2.ZERO
		var final_room = i == _number_of_rooms - 1
		if i - 1 >= 0:
			prev_room_data = all_room_data[i - 1]
			enter_pos = prev_room_data.exit_pos + Vector2.UP * prev_room_data.corridor_rect_size.y 
		
		var mobs = generate_mobs(i + 1)
		
		var exit_pos = current_pos + Vector2(ROOM_DIMENSIONS.x / 2, 0)  - Vector2(CORRIDOR_DIMENSIONS.x / 2, 0) 
		var corridor_pos = exit_pos - Vector2(0, ROOM_DIMENSIONS.y)
		
		# Temp just so there is no corridor:
		if final_room:
			exit_pos = Vector2(1000, 1000)
			corridor_pos = Vector2(2000, 2000)
		
		var room_rect = Rect2(current_pos, ROOM_DIMENSIONS)
		var corridor_rect = Rect2(corridor_pos, CORRIDOR_DIMENSIONS)
		
		var data = {
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
		current_pos -= Vector2(0, ROOM_DIMENSIONS.y + CORRIDOR_DIMENSIONS.y) + Vector2.UP
		all_room_data.append(data)
	
	Server.rooms_generated(all_room_data)


func generate_mobs(i) -> Array:
	var mobs = []
	var spawn_currency: float = i * 1.5 + floor(randf() * 2)
	var spawn_same_only: bool = false #i % 3 == 0
	var spawn_iterations: int = i + 1 
	
#	if i == 1:
#		mobs.append({"mob_type": Constants.MobTypes.ROMANS_BOSS, "pos": Vector2(0, -60)})
#	else:
	if !i >= mob_difficulties.keys().size():
		for n in (mob_difficulties.keys().size() - i):
			mobs.append({"mob_type": mob_difficulties.keys()[5 - i], "pos": Vector2.ZERO})
			if i == 4:
				mobs.append({"mob_type": mob_difficulties.keys()[5 - i], "pos": Vector2.ZERO})
	else:
		for amount in spawn_iterations:
			for mob_diff_index in range(0, mob_difficulties.keys().size()):
				var mob_type = mob_difficulties.keys()[mob_diff_index]
				var spawn_cost = mob_difficulties.values()[mob_diff_index]
				randomize()
				if spawn_currency >= spawn_cost:
					if spawn_same_only == true:
						for x in i:
							mobs.append({"mob_type": mob_type, "pos": Vector2.ZERO})
						return mobs
					else:
						spawn_currency -= spawn_cost
						mobs.append({"mob_type": mob_type, "pos": Vector2.ZERO})

			var living_players: Array = Util.get_living_players()
			var player_amount: int = 0
			for player in living_players:
				player_amount += 1
				if player_amount % 2 == 0 && !player_amount > 4:
					randomize()
					var random_mob = mob_difficulties.keys()[randi() % 3 + 2]
					mobs.append({"mob_type": random_mob, "pos": Vector2.ZERO})
#
	return mobs
