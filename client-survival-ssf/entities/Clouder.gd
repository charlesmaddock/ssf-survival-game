extends KinematicBody2D


export(int) var _strafe_distance: int = 80


onready var AI_node = $"AI"


var entity: Entity
var _is_animal = true
var _is_dashing = false



func _ready():
	get_node("AI").connect("target_player", self, "_on_target_player")
	entity.connect("damage_taken", self, "on_damage_taken")


func on_damage_taken(health, dir) -> void:
	if health <= 0:
		if Lobby.is_host == true:
			Server.despawn_mob(entity.id)



func _on_TargetEnemyTimer_timeout():
	if _is_dashing == true:
	  #var dir = global_position.direction_to(closest_player.global_position) * 100
	  #Movement.add_force(dir)
	  #damage_area.activate()
		pass
	else:
		var closest_player = Util.get_closest_player(self.global_position)
		if closest_player != null:
			var strafe_pos = AI_node.get_strafe_position(_strafe_distance, closest_player)
			AI_node.get_target_path(strafe_pos)

