tool
extends Node2D
var part_type: int = Constants.PartTypes.BODY
var part_name: int = Constants.PartNames.DefaultBody


onready var parent_entity: Entity = get_parent().entity

var movement_node: Node

export(Texture) var body_texture: Texture
export(float) var weight: float = 100
export(float) var health_modifier: float = 0
export(float) var body_scale: float = 1

export(String) var title: String = ""
export(String) var optional_desc: String = ""
export(String) var optional_perk_desc: String = ""
export(String) var optional_con_desc: String = ""


func _ready():
	if get_parent() != null:
		yield(get_tree(), "idle_frame")
		get_parent().entity.emit_signal("add_weight", weight)
		get_parent().entity.emit_signal("add_health_modifier", health_modifier)
	
	if body_texture != null:
		get_node("Sprite").texture = body_texture
	
	get_node("Sprite").scale = Vector2(body_scale, body_scale)


func _process(delta):
	if Engine.editor_hint:
		if body_texture != null:
			get_node("Sprite").texture = body_texture
			get_node("Sprite").scale = Vector2(body_scale, body_scale)


func remove() -> void:
	get_parent().entity.emit_signal("remove_health_modifier", health_modifier)
	get_parent().entity.emit_signal("remove_weight", weight)


func get_sprite():
	return(body_texture)
