extends Node2D


onready var entity_id = get_parent().entity.id


var attack_scene: PackedScene = preload("res://entities/Attack.tscn")


func _input(event):
	if Input.is_action_just_pressed("attack") && entity_id == Lobby.my_id:
		var dir = (get_global_mouse_position() - global_position).normalized()
		var attack = attack_scene.instance()
		var spawn_pos = global_position 
		attack.init(spawn_pos, dir, 100, entity_id)
		get_parent().get_parent().add_child(attack)
