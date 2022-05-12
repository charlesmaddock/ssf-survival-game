extends Node


onready var _room_scene: PackedScene = preload("res://game/Room.tscn")

var has_used_touch: bool = false 


func is_player(body) -> bool:
	return body.get("is_player") != null


func is_dead(body) -> bool:
	if is_entity(body):
		var health_node = body.get_node("Health")
		if health_node != null:
			return health_node.get_is_dead()
	
	return false


func _input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		has_used_touch = true


func generate_id() -> String: 
	return str(randi())


func is_entity(body: Node) -> bool:
	return body.get("entity") != null


func is_my_entity(entity: Node) -> bool:
	return entity.entity.id == Lobby.my_id


func is_mobile() -> bool:
	return has_used_touch


func get_game_node() -> Node:
	return get_node("/root/GameWrapper/Game")


func get_entity(id: String) -> Node:
	return get_node("/root/GameWrapper/Game/Entities").get_entity(id)

func get_closest_player(position) -> Object:
	var living_players: Array = Util.get_living_players()
	var closest_player
	var distance_to_closest_player = 99999
	for player in living_players:
		var distance_between_positions = position.distance_to(player.global_position)
		if distance_between_positions < distance_to_closest_player:
			distance_to_closest_player = distance_between_positions
			closest_player = player
	return closest_player

func get_living_players() -> Array:
	var entities = get_node("/root/GameWrapper/Game/Entities").get_children()
	var players = []
	for e in entities:
		if e.get("is_player") != null && e.visible == true:
			players.append(e)
	return players


func get_sprite_for_class(className: String) -> Texture:
	for info in Constants.class_info:
		if info.name == className:
			return info.tex
	
	return null


func generate_room(room_handler: Node2D, room_type, room_coordinates, entry_direction, exit_direction) -> void:
	var new_room: Node2D = _room_scene.instance()
	new_room.global_position = room_coordinates
	var room_door: StaticBody2D = new_room.get_node("Door")
	var room_door_passage: Area2D = room_door.get_node("Passage")
	
	
	match(entry_direction):
		Constants.DoorDirections.UP:
			pass
		Constants.DoorDirections.DOWN:
			pass
		Constants.DoorDirections.LEFT:
			pass
		Constants.DoorDirections.RIGHT:
			pass
	
	match(exit_direction):
		Constants.DoorDirections.UP:
			pass
		Constants.DoorDirections.DOWN:
			room_door.rotation_degrees = 180
		Constants.DoorDirections.LEFT:
			room_door.position.y += 96
			room_door.rotation_degrees = 270
		Constants.DoorDirections.RIGHT:
			room_door.position.y += 96
			room_door.rotation_degrees = 90
	
	
	room_handler.add_child(new_room)
