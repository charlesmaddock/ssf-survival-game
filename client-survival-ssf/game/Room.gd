extends Area2D



#onready var _door: Node2D = 
onready var _room_collision_shape: CollisionShape2D = $CollisionShape2D
onready var _door: Node2D = $Door

export(int) var _monster_amount: int = 5
export(preload("res://globals/Constants.gd").EntityTypes) var _monster_type: int = 1


var room_center_position = self.global_position

var _mobs_in_room: Array = [] 
var _mobs_entered_room: bool = false
var _room_completed: bool = false





func _ready():
	Server.connect("packet_received", self, "_on_packet_received")

#lagra array av ids på spawnade mobs, ifall lista.size = 0 then room_completed = true
	#ELLER en collider som känner ifall det är mobs kvar i rummet, om ej ? room_completed = true
	#lyssna på paket - ifall mob dör så kan vi minska antalet mobs i member var
	#dörr: onready var i dett adock
	#när man entrar room_body, då ska man komma till nytt rum
	#tänk på kamera!
	#192-96 area


func _on_Room_body_entered(body):
	if Util.is_entity(body) && body.get("_is_animal") == null && _room_completed == false && _mobs_entered_room == false:
		print("player has entered a room!")
		for i in _monster_amount:
			var id = Util.generate_id()
			var pos = Vector2(rand_range(room_center_position.x - 96, room_center_position.y + 96), rand_range(room_center_position.x - 48, room_center_position.y + 48))
			Server.spawn_mob(id, _monster_type, pos)
			_mobs_in_room.append(id)
		_mobs_entered_room = true


func _on_Room_body_exited(body):
	pass


#must be refined later with server-site support
func _on_packet_received(packet: Dictionary) -> void:
	if packet.type == Constants.PacketTypes.DESPAWN_MOB:
		print("I found a packet that I will deal with! -Yours sincerely, Room ;3", packet.id)
		print("The list of mobs in this room!: ",_mobs_in_room)
		var id_index =_mobs_in_room.find(packet.id)
		if id_index != -1:
			_mobs_in_room.remove(id_index)
			print("- You defeated a mob in the room! -")
			if _mobs_in_room.size() == 0:
				print("- Room is completed! -")
				_door._go_next_room()

