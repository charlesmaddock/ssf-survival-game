extends Area2D


export(float) var _damage = 50
export(float) var _speed = 100


var _velocity: Vector2 


func get_damage() -> float:
	return _damage


func fire(pos: Vector2, dir: Vector2) -> void:
	global_position = pos
	_velocity = dir.normalized() * _speed


func _process(delta):
	global_position += _velocity * delta


func _on_Projectile_area_entered(area):
	self.queue_free()


func _on_Projectile_body_entered(body):
	self.queue_free()
