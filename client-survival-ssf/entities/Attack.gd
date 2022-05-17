extends Area2D


export(float) var _damage
var _damage_creator_id: String
var _damage_creator_team: int
var _pos: Vector2
var _dir: Vector2


func _ready():
	set_global_position(_pos)
	look_at(_pos + _dir * 120)
	rotate(PI/2)


func init(pos: Vector2, dir: Vector2, val: float, creator_id: String, creator_team: int) -> void:
	_damage = val
	_damage_creator_id = creator_id
	_damage_creator_team = creator_team
	_pos = pos
	_dir = dir


func same_creator_or_team(id: String, team: int) -> bool:
	return id == _damage_creator_id || _damage_creator_team == team


func get_damage() -> float:
	return _damage


func _on_Timer_timeout():
	queue_free()
