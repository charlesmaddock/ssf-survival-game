extends Node2D


onready var parent_entity: Entity = get_parent().entity
var walk_state: bool = false
var movement_node: Node


func _ready():
	get_node("Timer").start()
	movement_node = get_parent().get_node("Movement")


func _on_Timer_timeout():
	if movement_node == null:
		return
	if movement_node.walking == false:
		walk_state = false
		get_node("Sprite").rotation_degrees = 0
		get_node("Sprite2").rotation_degrees = 0
	else:
		walk_state = !walk_state
		if walk_state == true:
			get_node("Sprite").rotation_degrees = -60
			get_node("Sprite2").rotation_degrees = 60
		else:
			get_node("Sprite").rotation_degrees = 0
			get_node("Sprite2").rotation_degrees = 0
