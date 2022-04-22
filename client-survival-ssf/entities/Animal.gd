extends KinematicBody2D


var entity: Entity
var _targeted_player = null


func _ready():
	get_node("AI").connect("target_player", self, "_on_target_player")


func _on_target_player(player) -> void:
	_targeted_player = player


func _on_AttackTimer_timeout():
	get_node("Combat").attack()
