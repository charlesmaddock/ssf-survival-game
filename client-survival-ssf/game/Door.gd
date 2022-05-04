extends StaticBody2D

onready var _room: Node2D = get_parent()
onready var _collisionShape2D: CollisionShape2D = $CollisionShape2D


func _ready():
	pass


func _open() -> void:
	self.visible = false
	_collisionShape2D.disabled = true
	
