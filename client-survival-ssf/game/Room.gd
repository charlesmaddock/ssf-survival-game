extends Area2D



export(bool) var _final_room: bool = false
export(NodePath) var _next_room_path: NodePath

onready var _room_collision_shape: CollisionShape2D = $CollisionShape2D
onready var _door: Node2D = $Door
onready var room_center_position = self.global_position
onready var _next_room_spawn_pos = $Door/NextRoomSpawnPos.global_position
onready var _next_room: Area2D = get_node(_next_room_path)


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


func _ready():
	print(self.name, " - This is my room pos!: ", room_center_position)
	Server.connect("packet_received", self, "_on_packet_received")

#lagra array av ids på spawnade mobs, ifall lista.size = 0 then room_completed = true
	#ELLER en collider som känner ifall det är mobs kvar i rummet, om ej ? room_completed = true
	#lyssna på paket - ifall mob dör så kan vi minska antalet mobs i member var
	#dörr: onready var i dett adock
	#när man entrar room_body, då ska man komma till nytt rum
	#tänk på kamera!
	#192-96 area


func _on_Room_body_entered(body):
	if Lobby.is_host:
		randomize()
		if Util.is_entity(body) && body.get("_is_animal") == null && _room_completed == false && _mobs_entered_room == false:
			var mob_spawn_data = [{"type": mob_type_1, "amount": mob_type_1_amount}, {"type": mob_type_2, "amount": mob_type_2_amount}, {"type": mob_type_3, "amount": mob_type_3_amount}]
			for data in mob_spawn_data:
				for i in data["amount"]:
					var id = Util.generate_id()
					var pos = Vector2(rand_range(room_center_position.x - 96, room_center_position.x + 96), rand_range(room_center_position.y - 48, room_center_position.y + 48))
					Server.spawn_mob(id, data["type"], pos)
					_mobs_in_room.append(id)
				
				_mobs_entered_room = true


func _on_Room_body_exited(body):
	print("I can see that these is a body leaving: ", body, "And room is: ", _room_completed)
	if _room_completed == true && Util.is_entity(body) && body.get("_is_animal") == null:
		print("I will now _go_next_room!")
		_go_next_room()


func _go_next_room() -> void:
	print("Go Next Room")
	if Lobby.is_host == true:
		Server.switch_rooms(_next_room.global_position)
		yield(get_tree().create_timer(0.6), "timeout")
		print("Go next and lobby is host is true mah dude, this is living players: ", Util.get_living_players())
		for player in Util.get_living_players(): 
			print("looping through players for go next room")
			player.global_position = _next_room_spawn_pos


#must be refined later with server-site support
func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.DESPAWN_MOB:
		#print("I found a packet that I will deal with! -Yours sincerely, Room ;3", packet.id)
		#print("The list of mobs in this room!: ",_mobs_in_room)
		var id_index =_mobs_in_room.find(packet.id)
		if id_index != -1:
			_mobs_in_room.remove(id_index)
			print("- You defeated a mob in the room! - ", _mobs_in_room)
			if _mobs_in_room.size() == 0:
				_room_completed = true
				if _final_room == false:
					print("- Room is completed! -")
					_door._open()
				if _final_room == true:
					Events.emit_signal("game_over")

