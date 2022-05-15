extends KinematicBody2D


var entity: Entity
var _is_animal = true
var _targeted_player = null


func _ready():
	get_node("AI").connect("target_player", self, "_on_target_player")


func _on_target_player(player) -> void:
	_targeted_player = player


func on_damage_taken(health, dir) -> void:
	if health <= 0:
		if Lobby.is_host == true:
			Server.despawn_mob(entity.id)


func _on_ShootTimer_timeout():
	if _targeted_player != null:
		var dir = (_targeted_player.global_position - global_position).normalized()
		Server.shoot_projectile(global_position, dir, entity.id, entity.team)
