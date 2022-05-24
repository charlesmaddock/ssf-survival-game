extends Node2D


onready var sprite: Node = get_node("Sprite")

export(Constants.PartTypes) var type = Constants.PartTypes.ARM
export(Texture) var part_texture
export(Resource) var part_path


func _ready():
	sprite.texture = part_texture
