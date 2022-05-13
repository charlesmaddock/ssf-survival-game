extends KinematicBody2D


export(int) var _strafe_distance: int = 80
export(int) var _dashing_multiplier: int = 350


onready var damage_node = $"Damage"
onready var AI_node = $"AI"
onready var movement_node: Node2D = $"Movement"

onready var dash_timer_node: Timer = $"DashTimer"
onready var stop_dashing_timer_node: Timer = $"StopDashingTimer"


var entity: Entity
var _is_animal = true

var _is_dashing: bool = false
var _has_dashed: bool = false



func _ready():
	get_node("AI").connect("target_player", self, "_on_target_player")
	entity.connect("damage_taken", self, "on_damage_taken")
	
	damage_node.init(entity.id, entity.team)


func on_damage_taken(health, dir) -> void:
	if health <= 0:
		if Lobby.is_host == true:
			Server.despawn_mob(entity.id)


func _on_TargetEnemyTimer_timeout():
	var closest_player = Util.get_closest_player(self.global_position)
	if _is_dashing == true:
		var dir = self.global_position.direction_to(closest_player.global_position) * _dashing_multiplier
		if _has_dashed == false:
			AI_node.stop_moving()
			entity.emit_signal("dashed", dir)
			_has_dashed = true
	else:
		if closest_player != null:
			var strafe_pos = AI_node.get_strafe_position(_strafe_distance, closest_player)
			AI_node.get_target_path(strafe_pos)



func _on_DashTimer_timeout():
	_is_dashing = true
	stop_dashing_timer_node.start()


func _on_StopDashingTimer_timeout():
	_is_dashing = false
	_has_dashed = false
	dash_timer_node.start()
