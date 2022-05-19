extends KinematicBody2D

export(int) var distance_from_player = 70
export(int) var _movement_speed = 40


onready var AI_node = $AI


var entity: Entity
var _targeted_player = null
var _is_animal = true


func _ready():
	entity.emit_signal("change_movement_speed", _movement_speed)
	pass

func _on_target_player(player) -> void:
	_targeted_player = player


func _on_AttackTimer_timeout():
	AI_node.strafe_behaviour(distance_from_player)
	_targeted_player = AI_node.get_closest_player()
	if _targeted_player != null:
		var dir = (_targeted_player.global_position - global_position).normalized()
		Server.melee_attack(entity.id, dir, entity.team, 24)

