extends Node2D


onready var sprite: Node = get_node("Sprite")

var _part_name: int

func init(pos: Vector2, part_name: int):
	global_position = pos
	
	_part_name = part_name
	var part_scene = Constants.PartScenes[part_name].duplicate(true).instance()
	
	get_node("Sprite").texture = part_scene.get_sprite()


func get_part_name():
	return _part_name
