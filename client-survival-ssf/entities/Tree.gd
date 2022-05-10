extends Node2D


var entity: Entity

func _ready():
	entity.connect("damage_taken", self, "on_damage_taken")


func on_damage_taken(health, dir) -> void:
	if health <= 0:
		if Lobby.is_host == true:
			Server.despawn_environment(entity.id)
