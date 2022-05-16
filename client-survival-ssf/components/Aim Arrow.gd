extends Node2D


onready var parent_entity: Entity = get_parent().entity
onready var sprite: Node = get_node("Sprite")
var last_pos
var move_dir: Vector2


func _ready():
	last_pos = get_parent().global_position
	
	get_parent().entity.connect("is_attacking", self, "_on_is_attacking")


func _on_is_attacking(attack_bool) -> void:
	if attack_bool:
		visible = false
	else:
		visible = true


func _process(delta):
	sprite.rotation_degrees = rad2deg(get_angle_to(last_pos))
	
	if get_parent().global_position != last_pos:
		move_dir = lerp(move_dir, last_pos.direction_to(get_parent().global_position), 0.05)
	#move_dir = (get_global_mouse_position() - global_position).normalized()
	sprite.rotation_degrees = rad2deg(move_dir.angle())
	get_parent().entity.emit_signal("move_dir", move_dir)
	last_pos = get_parent().global_position
