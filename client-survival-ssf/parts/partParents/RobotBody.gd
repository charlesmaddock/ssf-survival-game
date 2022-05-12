extends Node2D


onready var parent_entity: Entity = get_parent().entity
#var walk_state: bool = false
#var movement_node: Node

export(float) var weight: float = 100
export(Texture) var body_texture: Texture

#signal change_movement_speed


func _ready():
	
	#if movement_node != null:
	#	connect("change_movement_speed", movement_node, "_on_change_movement_speed")
	#	emit_signal("change_movement_speed", walk_speed)
	
	if body_texture != null:
		get_node("Sprite").texture = body_texture
