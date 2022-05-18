extends Node2D


onready var parent_entity: Entity = get_parent().entity
var able_to_attack: bool = true
var is_dead: bool = false


func _ready():
	Events.connect("player_dead", self, "_on_player_dead")
	Events.connect("player_revived", self, "_on_player_revived")


func _on_player_revived(id) -> void:
	if id == parent_entity.id:
		is_dead = false


func _on_player_dead(id) -> void:
	if id == parent_entity.id:
		is_dead = true


func _input(event):
	if parent_entity.id == Lobby.my_id && is_dead == false:
		rotation = global_position.angle_to_point(get_global_mouse_position()) + PI
		
		if Input.is_action_just_pressed("attack") && able_to_attack == true:
			able_to_attack = false
			var dir = (get_global_mouse_position() - global_position).normalized()
			Server.melee_attack(parent_entity.id, dir, global_position, parent_entity.team)


func _on_Timer_timeout():
	able_to_attack = true
