extends Node2D


onready var entity_id = get_parent().entity.id
var able_to_attack: bool = false


func _input(event):
	if Input.is_action_just_pressed("attack") && entity_id == Lobby.my_id && able_to_attack == true:
		able_to_attack = false
		var dir = (get_global_mouse_position() - global_position).normalized()
		print("telling server to send a packet of attack")
		Server.melee_attack(entity_id, dir)


func _on_Timer_timeout():
	able_to_attack = true
