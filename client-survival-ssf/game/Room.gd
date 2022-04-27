extends Area2D



#onready var _door: Node2D = 
onready var _room_collision_shape: CollisionShape2D = $CollisionShape2D

export(int) var _monster_amount: int = 5
export(preload("res://globals/Constants.gd").EntityTypes) var _monster_type: int = 1


var room_center_position = self.global_position

var _mobs_entered_room: bool = false
var _room_completed: bool = false

var _mobs_in_room: Array = []




func _ready():
	pass # Replace with function body.

#lagra array av ids på spawnade mobs, ifall lista.size = 0 then room_completed = true
	#ELLER en collider som känner ifall det är mobs kvar i rummet, om ej ? room_completed = true
	#lyssna på paket - ifall mob dör så kan vi minska antalet mobs i member var
	#dörr: onready var i dett adock
	#när man entrar room_body, då ska man komma till nytt rum
	#tänk på kamera!
	#192-96


func _on_Room_body_entered(body):
	if Util.is_entity(body) && body.get("_is_animal") == null && _room_completed == false:
		print("player has entered a room!")
		for i in _monster_amount:
			var id = Util.generate_id()
			var pos = Vector2(rand_range(room_center_position.x - 96, room_center_position.y + 96), rand_range(room_center_position.x - 48, room_center_position.y + 48))
			Server.spawn_mob(id, _monster_type, pos)
	if Util.is_entity(body) && body.get("_is_animal") != null:
		_mobs_in_room.append(body)
		_mobs_entered_room = true
	


func _on_Room_body_exited(body):
	"""
	if Util.is_entity(body) && body.get("_is_animal") == null:
		print("player has entered a room!")
		for i in _monster_amount:
			var id = Util.generate_id()
			var pos = Vector2(rand_range(room_center_position.x - 96, room_center_position.y + 96), rand_range(room_center_position.x - 48, room_center_position.y + 48))
			Server.spawn_mob(id, _monster_type, pos)
	"""
	if Util.is_entity(body) && body.get("_is_animal") != null:
		_mobs_in_room.erase(body)
		if _mobs_in_room.size() == 0:
			_room_completed = true
