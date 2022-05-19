tool

extends Node2D


onready var parent_entity: Entity = get_parent().entity

var movement_node: Node

export(Texture) var body_texture: Texture
export(float) var weight: float = 100


func _ready():
	if get_parent() != null:
		movement_node = get_parent().get_node("Movement")
		
		if movement_node != null:
			get_parent().entity.emit_signal("change_weight", weight)
	
	if body_texture != null:
		get_node("Sprite").texture = body_texture


func _process(delta):
	if Engine.editor_hint:
		if body_texture != null:
			get_node("Sprite").texture = body_texture
