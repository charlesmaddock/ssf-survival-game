extends Node2D


onready var sprite: Node = get_node("Sprite")

#export(Constants.PartTypes) var type = Constants.PartTypes.ARM
var _part_id: int

func init(pos: Vector2, part: int):
	global_position = pos
	
	_part_id = part
	var part_scene = Constants.PartScenes[_part_id].duplicate(true).instance()
	
	get_node("Sprite").texture = part_scene.get_sprite()


func get_part_id():
	return _part_id
