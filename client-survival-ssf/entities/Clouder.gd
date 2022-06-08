extends KinematicBody2D


export(int) var _strafe_distance: int = 85
export(int) var _strafe_distance_variability: int = 10
export(int) var _dashing_multiplier: int = 350
export(int) var _movement_speed: int = 100
export(float) var _time_before_dashing = 2.5
export(float) var _time_before_dashing_variability_intervall = 0.3
export(float) var _time_before_stop_dashing = 0.2

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
	_start_strafe()
	dash_timer_node.set_wait_time(_time_before_dashing)
	stop_dashing_timer_node.set_wait_time(_time_before_stop_dashing)
	_start_dash_timer()


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
		_start_stop_dashing_timer()


func _on_StopDashingTimer_timeout():
	_start_strafe()
	_is_dashing = false
	_has_dashed = false
	_start_dash_timer()


func _start_strafe() -> void: 
	var strafe_distance: int = _strafe_distance
	strafe_distance += rand_range(-_strafe_distance_variability, _strafe_distance_variability)
	AI_node.strafe_player_behaviour(strafe_distance)

func _start_dash_timer() -> void:
	randomize()
	var time_before_dashing = _time_before_dashing
	time_before_dashing += rand_range(-_time_before_dashing_variability_intervall, _time_before_dashing_variability_intervall)
	dash_timer_node.start(time_before_dashing)


func _start_stop_dashing_timer() -> void:
	stop_dashing_timer_node.start()
