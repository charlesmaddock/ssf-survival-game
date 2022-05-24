extends Node2D


onready var sprite: Node = get_node("Sprite")

#export(Constants.PartTypes) var type = Constants.PartTypes.ARM
var _part_texture
var _part


func init(pos: Vector2, part: int):
	global_position = pos
	
	_part = Constants.PartScenes[part]
	var _part_scene = _part.instance()
	
	get_node("Sprite").texture = _part_scene.get_sprite()
