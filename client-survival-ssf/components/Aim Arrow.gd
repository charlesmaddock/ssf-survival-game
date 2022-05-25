extends Node2D


onready var parent_entity: Entity = get_parent().entity

var last_pos
var aim_dir: Vector2


func _ready():
	last_pos = get_parent().global_position
	
	get_parent().entity.connect("is_attacking", self, "_on_is_attacking")


func _on_is_attacking(attack_bool) -> void:
	if attack_bool:
		visible = false
	else:
		visible = true


func _input(event):
	if Input.is_action_pressed("aim_right"):
		aim_dir = Vector2(1, 0)
	
	if Input.is_action_pressed("aim_left"):
		aim_dir = Vector2(-1, 0)
	
	if Input.is_action_pressed("aim_up"):
		aim_dir = Vector2(0, -1)
	
	if Input.is_action_pressed("aim_down"):
		aim_dir = Vector2(0, 1)
	
	#if Input.is_action_pressed("aim_right") || Input.is_action_pressed("aim_left") || Input.is_action_pressed("aim_up") || Input.is_action_pressed("aim_down"):
	#	move_h = int(Input.is_action_pressed("aim_right")) - int(Input.is_action_pressed("aim_left"))
	#	move_v = int(Input.is_action_pressed("aim_down"))  - int(Input.is_action_pressed("aim_up"))
	
	get_parent().entity.emit_signal("aim_dir", aim_dir)
