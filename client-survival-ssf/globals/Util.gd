extends Node


var has_used_touch: bool = false 


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
