extends Node2D


var footstep_scene: PackedScene = preload("res://game/Footstep.tscn")


func _ready():
	Events.connect("add_footstep", self,  "_on_add_footstep")


func _on_add_footstep(pos: Vector2, dir: Vector2) -> void:
	var footstep = footstep_scene.instance()
	add_child(footstep)
	footstep.global_position = pos
	footstep.rotation = dir.angle() - PI/2
