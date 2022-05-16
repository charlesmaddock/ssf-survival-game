extends KinematicBody2D


var entity: Entity
var _targeted_player = null
var _is_animal = true


func _on_target_player(player) -> void:
	_targeted_player = player


func _on_AttackTimer_timeout():
	if _targeted_player != null:
		var dir = (_targeted_player.global_position - global_position).normalized()
		Server.melee_attack(entity.id, dir, entity.team)



