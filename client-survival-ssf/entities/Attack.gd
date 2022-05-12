extends Area2D


export(float) var _damage
var _damage_creator_id: String
var _damage_creator_team: int


func init(pos: Vector2, dir: Vector2, val: float, creator_id: String, creator_team: int) -> void:
	_damage = val
	_damage_creator_id = creator_id
	_damage_creator_team = creator_team
	
	set_global_position(pos)
	look_at(pos + dir * 100)
	rotate(PI/2)


func same_creator_or_team(id: String, team: int) -> bool:
	return id == _damage_creator_id || _damage_creator_team == team


func get_damage() -> float:
	return _damage


func _on_Timer_timeout():
	queue_free()
