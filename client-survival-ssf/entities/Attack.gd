extends Area2D


export(float) var _damage
var _damage_creator_id: String


func init(pos: Vector2, dir: Vector2, val: float, creator_id: String) -> void:
	_damage = val
	_damage_creator_id = creator_id
	
	set_global_position(pos)
	look_at(pos + dir * 100)
	rotate(PI/2)


func is_made_by(id: String) -> bool:
	return id == _damage_creator_id


func get_damage() -> float:
	return _damage


func _on_Timer_timeout():
	queue_free()
