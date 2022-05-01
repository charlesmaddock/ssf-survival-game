extends KinematicBody2D


var entity: Entity
var _targeted_player = null
var _is_animal = true


func _ready():
	get_node("AI").connect("target_player", self, "_on_target_player")
	entity.connect("damage_taken", self, "on_damage_taken")
	

func _on_target_player(player) -> void:
	_targeted_player = player

func on_damage_taken(health, dir) -> void:
	if health <= 0:
		if Lobby.is_host == true:
			print("is_host zero health on Animal")
			Server.despawn_mob(entity.id)


func _on_AttackTimer_timeout():
	#get_node("Combat").attack()
	pass



