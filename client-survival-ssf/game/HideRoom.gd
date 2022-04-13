extends Control


onready var HideColorRect: ColorRect = $ColorRect
onready var ShowAreaShape: CollisionShape2D = $ColorRect/ShowArea/CollisionShape2D
onready var ShowArea: Area2D = $ColorRect/ShowArea
onready var HideEntityShape: CollisionShape2D = $ColorRect/HideEntityArea/CollisionShape2D


var opacity: float = 1
var players: Array
var _our_player_is_in_room: bool = false

var other_entities_in_room: Array


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("switched_spectate", self, "_on_switched_spectate")
	
	var shape: RectangleShape2D = ShowAreaShape.get_shape()
	shape.set_extents(Vector2(rect_size.x / 2, rect_size.y / 2) + Vector2.ONE * 32)
	ShowAreaShape.position = rect_size / 2 
	
	var hide_entity_shape: RectangleShape2D = HideEntityShape.get_shape()
	hide_entity_shape.set_extents(Vector2(rect_size.x / 2, rect_size.y / 2))
	HideEntityShape.position = rect_size / 2 


func _on_switched_spectate(entity: Node) -> void:
	var remove_at = other_entities_in_room.find(entity)
	if remove_at != -1:
		other_entities_in_room.remove(remove_at)
		set_entity_modulate(entity, 1)
	
	if ShowArea.get_overlapping_bodies().find(entity) != -1:
		_our_player_is_in_room = true
	


func _process(delta):
	if _our_player_is_in_room:
		opacity -= delta * 10
	else:
		opacity += delta * 10
	
	opacity = clamp(opacity, 0, 1)
	for body in other_entities_in_room:
		set_entity_modulate(body, 1 - opacity)
	
	HideColorRect.modulate = Color(1, 1, 1, opacity)


func set_entity_modulate(body, opacity) -> void:
	body.get_node("Sprite").modulate = Color(1, 1, 1, opacity)
	if body.has_node("Health"):
		body.get_node("Health").modulate = Color(1, 1, 1, opacity)
	if body.has_node("UsernameLabel"):
		body.get_node("UsernameLabel").modulate = Color(1, 1, 1, opacity)


func is_my_entity(body: PhysicsBody2D) -> bool:
	if body != null:
		if body.has_method("get_id") == true:
			if body.get_id() == Lobby.specating_player_w_id:
				return true
	
	return false


func _on_HideEntityArea_body_entered(body):
	if is_my_entity(body) == false && body is KinematicBody2D:
		set_entity_modulate(body, 1 - opacity)
		other_entities_in_room.append(body)


func _on_HideEntityArea_body_exited(body):
	if is_my_entity(body) == false && body is KinematicBody2D:
		var remove_at = other_entities_in_room.find(body)
		if remove_at != -1:
			set_entity_modulate(body, 1)
			other_entities_in_room.remove(remove_at)


func _on_ShowArea_body_entered(body):
	if is_my_entity(body):
		_our_player_is_in_room = true


func _on_ShowArea_body_exited(body):
	if is_my_entity(body):
		_our_player_is_in_room = false
