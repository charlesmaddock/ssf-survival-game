extends KinematicBody2D


export(int) var _strafe_distance: int = 80
export(int) var _dashing_multiplier: int = 350
export(int) var _movement_speed: int = 100

onready var damage_node = $Damage
onready var AI_node = $AI
onready var movement_node: Node2D = $Movement

onready var dash_timer_node: Timer = $DashTimer
onready var stop_dashing_timer_node: Timer = $StopDashingTimer


var entity: Entity
var _is_animal = true

var _is_dashing: bool = false
var _has_dashed: bool = false



func _ready():
	entity.emit_signal("change_movement_speed", _movement_speed)
	AI_node.strafe_player_behaviour(_strafe_distance)
	damage_node.init(entity.id, entity.team)


func _on_DashTimer_timeout():
	if _has_dashed == false:
		_is_dashing = true
		var closest_player = AI_node.get_closest_player()
		if closest_player != null:
			var dir = self.global_position.direction_to(closest_player.global_position) * _dashing_multiplier
			AI_node.motionless_behaviour()
			entity.emit_signal("dashed", dir)
		else:
			print("Somehow, get_closest_player() == null")
		_has_dashed = true
		stop_dashing_timer_node.start()


func _on_StopDashingTimer_timeout():
	AI_node.strafe_player_behaviour(_strafe_distance)
	_is_dashing = false
	_has_dashed = false
	dash_timer_node.start()
