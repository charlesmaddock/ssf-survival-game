extends Area2D


export(float) var _damage
var _damage_creator_id: String


func init(val: float, creator_id: String) -> void:
	_damage = val
	_damage_creator_id = creator_id


func is_made_by(id: String) -> bool:
	return id == _damage_creator_id


func get_damage() -> float:
	return _damage


func _on_Timer_timeout():
	queue_free()
