extends Node2D


onready var parent_entity: Entity = get_parent().entity
onready var sprite: Node = get_node("Sprite")
var last_pos


func _ready():
	last_pos = get_parent().global_position


func _process(delta):
	sprite.rotation_degrees = rad2deg(get_angle_to(last_pos))
	
	#print(sprite.rotation_degrees)
	
	last_pos = get_parent().global_position
