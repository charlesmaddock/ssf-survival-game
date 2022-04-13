extends Node2D


onready var is_my_combat = get_parent().get_id() == Lobby.my_id


var attack_scene: PackedScene = preload("res://entities/Attack.tscn")


func _input(event):
	if Input.is_action_just_pressed("attack") && is_my_combat:
		var dir = (get_global_mouse_position() - global_position).normalized()
		var attack = attack_scene.instance()
		attack.set_damage(10)
		attack.global_position = global_position + dir * 32
		attack.look_at(global_position + dir * 100)
		attack.rotate(PI/2)
		get_parent().get_parent().add_child(attack)
