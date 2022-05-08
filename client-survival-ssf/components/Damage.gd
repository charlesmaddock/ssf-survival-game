extends Area2D


export(float) var _damage
var _damage_creator_id: String = ""
var _damage_creator_team: int = Constants.Teams.NONE


func same_creator_or_team(id: String, team: int) -> bool:
	return id == _damage_creator_id || _damage_creator_team == team


func get_damage() -> float:
	return _damage

