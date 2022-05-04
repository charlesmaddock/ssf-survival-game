extends StaticBody2D

onready var _room: Node2D = get_parent()


func _ready():
	pass


func _go_next_room() -> void:
	self.queue_free()
