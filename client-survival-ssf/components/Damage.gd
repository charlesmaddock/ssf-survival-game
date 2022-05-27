extends Area2D


onready var parent_node: Node2D = self.get_parent()


export(float) var _damage
var _damage_creator_id: String = ""
var _damage_creator_team: int = Constants.Teams.NONE


func _ready():
	_damage_creator_id = parent_node.entity.id
	_damage_creator_team = parent_node.entity.team


func same_creator_or_team(id: String, team: int) -> bool:
	return id == _damage_creator_id || _damage_creator_team == team


func activate_damage():
	self.monitorable = true


func deactivate_damage():
	self.monitorable = false


func get_damage() -> float:
	return _damage

