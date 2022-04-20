extends Area2D


export(float) var _damage = 50
export(float) var _speed = 100


var _velocity: Vector2 
var _damage_creator_id: String


func init(pos: Vector2, dir: Vector2, val: float, creator_id: String) -> void:
	_damage = val
	_damage_creator_id = creator_id
	
	global_position = pos
	_velocity = dir.normalized() * _speed


func is_made_by(id: String) -> bool:
	return id == _damage_creator_id


func get_damage() -> float:
	return _damage


func _process(delta):
	global_position += _velocity * delta


func _on_Projectile_area_entered(area):
	self.queue_free()


func _on_Projectile_body_entered(body):
	self.queue_free()
