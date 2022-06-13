extends Area2D


export(NodePath) var _next_room_path: NodePath


onready var _room_collision_shape: CollisionShape2D = $CollisionShape2D
onready var _next_room_detector: CollisionShape2D = $NextRoomDetector/CollisionShape2D
onready var _door: Node2D = $Door
onready var _enter_door: Node2D = $EnterDoor
onready var _next_room_spawn_pos = $NextRoomSpawnPos


export(int) var _monster_amount: int = 3
export(preload("res://globals/Constants.gd").MobTypes) var mob_type_1: int 
export(int) var mob_type_1_amount: int = 1
export(preload("res://globals/Constants.gd").MobTypes) var mob_type_2: int 
export(int) var mob_type_2_amount: int = 0
export(preload("res://globals/Constants.gd").MobTypes) var mob_type_3: int 
export(int) var mob_type_3_amount: int = 0


var spike_pattern1_scene = preload("res://patterns/SpikesPattern1.tscn")
var spike_pattern2_scene = preload("res://patterns/SpikesPattern2.tscn")
var spike_pattern3_scene = preload("res://patterns/SpikesPattern3.tscn")
var chip_pattern1_scene = preload("res://patterns/ChipPattern1.tscn")
var chip_pattern2_scene = preload("res://patterns/ChipPattern2.tscn")
var loot_scene = preload("res://patterns/LootPattern1.tscn")
var revive_scene = preload("res://patterns/RevivePattern1.tscn")

var _room_center_position: Vector2
var _mobs_in_room: Array = [] 
var _mobs_entered_room: bool = false
var _room_completed: bool = false
var _final_room: bool = false

var _room_data: Dictionary = {}
var _next_room_data: Dictionary = {}


func _ready():
	Server.connect("packet_received", self, "_on_packet_received")
	
	var room_type: int = _room_data.room_type
	var corridor_rect_size: Vector2 = Vector2(_room_data.corridor_rect_size.x, _room_data.corridor_rect_size.y)
	var room_rect_size: Vector2 = Vector2(_room_data.room_rect_size.x, _room_data.room_rect_size.y)
	
	_room_collision_shape.shape.set_extents(room_rect_size / 2 * Constants.TILE_SIZE)
	_next_room_detector.shape.set_extents(corridor_rect_size / 2 * Constants.TILE_SIZE)
	
	global_position = (Vector2(_room_data.room_rect_pos.x, _room_data.room_rect_pos.y) + Vector2(_room_data.room_rect_size.x, _room_data.room_rect_size.y) / 2) * Constants.TILE_SIZE.x
	
	var entities_ysort = Util.get_game_node().get_node("Entities")
	Util.reparent(self, entities_ysort, _door)
	Util.reparent(self, entities_ysort, _enter_door)
	_door.global_position = Vector2(_room_data.exit_pos.x, _room_data.exit_pos.y) * Constants.TILE_SIZE
	_enter_door.global_position = Vector2(_room_data.enter_pos.x, _room_data.enter_pos.y) * Constants.TILE_SIZE
	
	generate_environment(room_type)
	
	if _next_room_data.empty() == false:
		var exit_direction: int = _room_data.exit_dir
		var enter_direction: int = _room_data.enter_dir
		
		if exit_direction == Constants.ExitDirections.EAST || exit_direction == Constants.ExitDirections.WEST:
			_door.rotation_degrees = 90
			_door.global_position += Vector2.RIGHT * Constants.TILE_SIZE
		
		if enter_direction == Constants.ExitDirections.EAST || enter_direction == Constants.ExitDirections.WEST:
			_enter_door.rotation_degrees = 90
			_enter_door.global_position += Vector2.RIGHT * Constants.TILE_SIZE
		
		match(exit_direction):
			Constants.ExitDirections.NORTH:
				_next_room_detector.global_position = (Vector2(_room_data.exit_pos.x, _room_data.exit_pos.y) + Vector2(corridor_rect_size.x / 2, -corridor_rect_size.y / 2)) * Constants.TILE_SIZE
				_next_room_spawn_pos.global_position = (Vector2(_next_room_data.enter_pos.x, _next_room_data.enter_pos.y) + Vector2(1, 0)) * Constants.TILE_SIZE
			Constants.ExitDirections.EAST:
				_next_room_detector.global_position = (Vector2(_room_data.exit_pos.x, _room_data.exit_pos.y) + corridor_rect_size / 2) * Constants.TILE_SIZE
				_next_room_spawn_pos.global_position = (Vector2(_next_room_data.enter_pos.x, _next_room_data.enter_pos.y) + Vector2(1, 1)) * Constants.TILE_SIZE
			Constants.ExitDirections.WEST:
				_next_room_detector.global_position = (Vector2(_room_data.exit_pos.x, _room_data.exit_pos.y) + Vector2(-corridor_rect_size.x, corridor_rect_size.y) / 2) * Constants.TILE_SIZE
				_next_room_spawn_pos.global_position = (Vector2(_next_room_data.enter_pos.x, _next_room_data.enter_pos.y) + Vector2(-1, 1)) * Constants.TILE_SIZE
	
	if _room_data.mobs.size() == 0:
		Server.room_completed(self.name)
	
	_room_center_position  = self.global_position + room_rect_size 
	print_mobs()
	
	if name == str(0):
		Server.switch_rooms(_room_center_position, -1)


func print_mobs() -> void:
	var mobs = ""
	for mob in _room_data.mobs:
		mobs += Constants.MobTypes.keys()[mob["mob_type"]] + ", "
	print("Generated mobs: ", mobs)


func get_room_center_position() -> Vector2:
	return _room_center_position


func get_next_room() -> Node:
	return get_parent().get_node(str(_room_data.id + 1))


func get_available_spawn_points() -> Array:
	var spawn_points = []
	for y in range(_room_data.room_rect_pos.y + 1, _room_data.room_rect_end.y - 1):
		for x in range(_room_data.room_rect_pos.x + 1, _room_data.room_rect_end.x - 1):
			var space_state = get_world_2d().direct_space_state
			var result: Dictionary = space_state.intersect_ray(Vector2(x, y) * Constants.TILE_SIZE, (Vector2(x, y) + Vector2.ONE) * Constants.TILE_SIZE, [], pow(2, Constants.collisionLayers.SOLID))
			
			if result.empty() == true:
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


func generate_environment(room_type: int) -> void:
	match room_type:
		Constants.RoomTypes.START:
			$Tutorial.set_visible(true)
		Constants.RoomTypes.SPIKES:
			var spike_patterns = [spike_pattern1_scene, spike_pattern2_scene, spike_pattern3_scene]
			var pattern_scene = spike_patterns[randi() % spike_patterns.size()]
			var pattern = pattern_scene.instance()
			add_child(pattern)
		Constants.RoomTypes.CHIP:
			var chip_patterns = [chip_pattern1_scene, chip_pattern2_scene]
			var pattern_scene = chip_patterns[randi() % chip_patterns.size()]
			var pattern = pattern_scene.instance()
			add_child(pattern)
		Constants.RoomTypes.LOOT:
			var pattern = loot_scene.instance()
			add_child(pattern)
		Constants.RoomTypes.REVIVE:
			var pattern = revive_scene.instance()
			add_child(pattern)


func _on_Room_body_entered(body):
	if Lobby.is_host:
		randomize()
		if Util.is_entity(body) && _room_completed == false && _mobs_entered_room == false:
			if body.get("_is_animal") == null:
				for mob in _room_data.mobs:
					var mob_type = mob["mob_type"]
					var room_extents = _room_collision_shape.get_shape().extents
					var global_spawn_points = get_available_spawn_points()
					var id = Util.generate_id()
					var rel_mob_pos_given = Vector2(mob["pos"]["x"], mob["pos"]["y"])
					var pos: Vector2
					if rel_mob_pos_given == Vector2.ZERO:
						pos = global_spawn_points[randi() % global_spawn_points.size()] + (Vector2.ONE * Constants.TILE_SIZE / 2)
					else:
						pos = _room_center_position + rel_mob_pos_given
					Server.spawn_mob(id, mob_type, pos)
					_mobs_in_room.append(id)
					_mobs_entered_room = true
		elif Util.is_entity(body) && body.get("_is_animal") == true && _mobs_entered_room == true:
			if _mobs_in_room.find(body.entity.id) == -1:
				_mobs_in_room.append(body.entity.id)
#				body.entity.residing_room_center_pos = _room_center_position


func _on_NextRoomDetector_body_entered(body) -> void:
	if _room_completed == true && Util.is_entity(body):
		var next_room = get_next_room()
		
		if Lobby.is_host == true && next_room != null:
			Server.switch_rooms(next_room.get_room_center_position(), _room_data.id + 1)
			yield(get_tree().create_timer(0.6), "timeout")
			var player_index: int
			for player in Util.get_living_players(): 
				player.global_position = _next_room_spawn_pos.global_position + (Vector2.DOWN * player_index * Constants.TILE_SIZE)
				#player_index += 1
		elif Lobby.is_host == true && next_room == null:
			printerr("Room was null.")


#must be refined later with server-site support
func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.COMPLETE_ROOM:
		if packet.name == self.name:
			_room_completed = true
			if _final_room == true:
				Events.emit_signal("game_over", true)
			else:
				_door._open()
	
	if packet.type == Constants.PacketTypes.SWITCH_ROOMS:
		if packet.room_id == int(self.name):
			_enter_door.set_visible(false)
			yield(get_tree().create_timer(1), "timeout")
			_enter_door.set_visible(true)
	if packet.type == Constants.PacketTypes.DESPAWN_MOB:
		var id_index =_mobs_in_room.find(packet.id)
		if id_index != -1 && Lobby.is_host:
			_mobs_in_room.remove(id_index)
			if _mobs_in_room.size() == 0:
				Server.room_completed(self.name)

