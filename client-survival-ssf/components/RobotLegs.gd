extends Node2D


onready var parent_entity: Entity = get_parent().entity
var walk_state: bool = false
var movement_node: Node

export(float) var walk_speed: float = 0.3
export(Texture) var leg_texture: Texture


func _ready():
	get_node("Timer").wait_time = walk_speed
	movement_node = get_parent().get_node("Movement")
	
	if leg_texture != null:
		get_node("Sprite1").texture = leg_texture
		get_node("Sprite2").texture = leg_texture


func _on_Timer_timeout():
	if movement_node == null:
		return
	if movement_node.walking == false:
		walk_state = false
		get_node("Sprite1").rotation_degrees = 0
		get_node("Sprite2").rotation_degrees = 0
	else:
		walk_state = !walk_state
		if walk_state == true:
			get_node("Sprite1").rotation_degrees =-60
			get_node("Sprite2").rotation_degrees = 60
		else:
			get_node("Sprite1").rotation_degrees = 0
			get_node("Sprite2").rotation_degrees = 0
