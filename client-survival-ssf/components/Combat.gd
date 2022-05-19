extends Node2D


onready var parent_entity: Entity = get_parent().entity
var able_to_attack: bool = false


func _input(event):
	if Input.is_action_just_pressed("attack") && parent_entity.id == Lobby.my_id && able_to_attack == true:
		able_to_attack = false
		var dir = (get_global_mouse_position() - global_position).normalized()
		Server.melee_attack(parent_entity.id, dir, parent_entity.team, 20)


func _on_Timer_timeout():
	able_to_attack = true
