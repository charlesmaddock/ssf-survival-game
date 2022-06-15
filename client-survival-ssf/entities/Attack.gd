extends Area2D


export(float) var _damage
var _damage_creator_id: String
var _damage_creator_team: int
var _dir: Vector2
var _damage_mod: float =1


func _ready():
	look_at(global_position + _dir * 120)
	rotate(PI/2)
	position.y -= 12


func init(dir: Vector2, val: float, creator_id: String, creator_team: int) -> void:
	_damage = val
	_damage_creator_id = creator_id
	_damage_creator_team = creator_team
	_dir = dir
	
	var creator: Node = Util.get_entity(creator_id)
	if creator != null:
		_damage_mod = 0.5 if Lobby.easy_mode && Util.is_player(creator) == false else 1


func same_creator_or_team(id: String, team: int) -> bool:
	return id == _damage_creator_id || _damage_creator_team == team


func get_damage() -> float:
	return _damage * _damage_mod


func _on_Timer_timeout():
	queue_free()
