extends Area2D



export(NodePath) var _next_room_path: NodePath

onready var _room_collision_shape: CollisionShape2D = $CollisionShape2D
onready var _door: Node2D = $Door
onready var room_center_position = self.global_position
onready var _next_room_spawn_pos = $NextRoomSpawnPos


export(int) var _monster_amount: int = 3
export(preload("res://globals/Constants.gd").MobTypes) var mob_type_1: int 
export(int) var mob_type_1_amount: int = 1
export(preload("res://globals/Constants.gd").MobTypes) var mob_type_2: int 
export(int) var mob_type_2_amount: int = 0
export(preload("res://globals/Constants.gd").MobTypes) var mob_type_3: int 
export(int) var mob_type_3_amount: int = 0


var _mobs_in_room: Array = [] 
var _mobs_entered_room: bool = false
var _room_completed: bool = false
var _final_room: bool = false

var _room_data: Dictionary = {}
var _next_room_data: Dictionary = {}


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	
	global_position = (Vector2(_room_data.room_rect_pos.x, _room_data.room_rect_pos.y) + Vector2(_room_data.room_rect_size.x, _room_data.room_rect_size.y) / 2) * Constants.TILE_SIZE.x
	_door.global_position = Vector2(_room_data.exit_pos.x, _room_data.exit_pos.y) * Constants.TILE_SIZE
	if _next_room_data.empty() == false:
		_next_room_spawn_pos.global_position = (Vector2(_next_room_data.enter_pos.x, _next_room_data.enter_pos.y) + Vector2.RIGHT + Vector2.DOWN * 3) * Constants.TILE_SIZE 
	
	print_mobs()
	
	if name == str(0):
		Server.switch_rooms(global_position)


func print_mobs() -> void:
	var mobs = ""
	for mobt in _room_data.mobs:
		mobs += Constants.MobTypes.keys()[mobt] + ", "
	print("Generated mobs: ", mobs)


func get_next_room() -> Node:
	return get_parent().get_node(str(_room_data.id + 1))


func get_available_spawn_points() -> Array:
	var spawn_points = []
	for y in range(_room_data.room_rect_pos.y + 1, _room_data.room_rect_end.y - 1):
		for x in range(_room_data.room_rect_pos.x + 1, _room_data.room_rect_end.x - 1):
			var space_state = get_world_2d().direct_space_state
			var result: Dictionary = space_state.intersect_ray(Vector2(x, y) * Constants.TILE_SIZE, (Vector2(x, y) + Vector2.ONE) * Constants.TILE_SIZE, [])
			if result.empty() == false:
				spawn_points.append(Vector2(x, y) * Constants.TILE_SIZE)
	
	return spawn_points


#lagra array av ids på spawnade mobs, ifall lista.size = 0 then room_completed = true
	#ELLER en collider som känner ifall det är mobs kvar i rummet, om ej ? room_completed = true
	#lyssna på paket - ifall mob dör så kan vi minska antalet mobs i member var
	#dörr: onready var i dett adock
	#när man entrar room_body, då ska man komma till nytt rum
	#tänk på kamera!
	#192-96 area


func set_room_data(room_data: Dictionary, next_room_data: Dictionary) -> void:
	name = str(room_data.id)
	_room_data = room_data
	_next_room_data = next_room_data
	
	if _next_room_data.empty() == true:
		_final_room = true


func _on_Room_body_entered(body):
	if Lobby.is_host:
		randomize()
		if Util.is_entity(body) && body.get("_is_animal") == null && _room_completed == false && _mobs_entered_room == false:
			for mob_type in _room_data.mobs:
				var room_extents = _room_collision_shape.get_shape().extents
				var global_spawn_points = get_available_spawn_points()
				var id = Util.generate_id()
				var pos = global_spawn_points[randi() % global_spawn_points.size()] + (Vector2.ONE * Constants.TILE_SIZE / 2)
				Server.spawn_mob(id, mob_type, pos)
				_mobs_in_room.append(id)
				_mobs_entered_room = true


func _on_NextRoomDetector_body_entered(body) -> void:
	if _room_completed == true && Util.is_entity(body):
		var next_room = get_next_room()
		
		if Lobby.is_host == true && next_room != null:
			Server.switch_rooms(next_room.global_position)
			yield(get_tree().create_timer(0.6), "timeout")
			for player in Util.get_living_players(): 
				player.global_position = _next_room_spawn_pos.global_position
		elif Lobby.is_host == true && next_room == null:
			printerr("Room was null.")


#must be refined later with server-site support
func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.COMPLETE_ROOM:
		if packet.name == self.name:
			if _final_room == true:
				Events.emit_signal("game_over", true)
			else:
				_door._open()
	if packet.type == Constants.PacketTypes.DESPAWN_MOB:
		var id_index =_mobs_in_room.find(packet.id)
		if id_index != -1 && Lobby.is_host:
			_mobs_in_room.remove(id_index)
			if _mobs_in_room.size() == 0:
				_room_completed = true
				Server.room_completed(self.name)

