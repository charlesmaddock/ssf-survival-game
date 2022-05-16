extends KinematicBody2D


export(int) var _strafe_distance = 140
export(int) var _movement_speed = 40

onready var AI_node = $AI


var entity: Entity
var _is_animal = true
var _targeted_player = null


func _ready():
	randomize()
	AI_node.strafe_behaviour(_strafe_distance)
	entity.emit_signal("change_movement_speed", _movement_speed)


func on_damage_taken(health, dir) -> void:
	if health <= 0:
		if Lobby.is_host == true:
			Server.despawn_mob(entity.id)


func _on_ShootTimer_timeout():
	AI_node.strafe_behaviour(rand_range(_strafe_distance - 70, _strafe_distance + 70))
	_targeted_player = AI_node.get_closest_player()
	if _targeted_player != null:
		var dir = (_targeted_player.global_position - global_position).normalized()
		Server.shoot_projectile(global_position, dir, entity.id, entity.team)
