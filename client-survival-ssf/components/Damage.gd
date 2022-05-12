extends Area2D


export(float) var _damage
var _damage_creator_id: String = ""
var _damage_creator_team: int = Constants.Teams.NONE


func init(damage_creator_id: String, damage_creator_team: int):
	_damage_creator_id = damage_creator_id
	_damage_creator_team = damage_creator_team

func same_creator_or_team(id: String, team: int) -> bool:
	return id == _damage_creator_id || _damage_creator_team == team


func activate_damage():
	self.monitorable = true


func deactivate_damage():
	self.monitorable = false


func get_damage() -> float:
	return _damage

