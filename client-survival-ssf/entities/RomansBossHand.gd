extends Node2D


export var _strafe_dist: float = 4
export var _strafe_speed: float = 350
export var _charge_speed: float = 400
export var _time_to_charge: float = 2.0
export var _chargeback_speed: float = 100
export var _time_to_chargeback: float = 0.8

onready var AI_node: Node2D = self.get_node("AI")
onready var health_node: Node2D = self.get_node("Health")
onready var movement_node: Node2D = self.get_node("Movement")

onready var raycast_player_detection: Node2D = self.get_node("RayCastPlayerDetection")
onready var raycast_wall_detection: Node2D = self.get_node("RayCastWallDetection")
onready var timer_to_charge: Timer = self.get_node("TimerToCharge")
onready var timer_to_chargeback: Timer = self.get_node("TimerToChargeback")


var entity: Entity
var _is_animal = true
var _init_finished = false
var _is_left_hand: bool = true

var _passive_position: Vector2
var _strafe_center_pos: Vector2
var _is_first_strafe_pos: bool = true
var _strafe_direction: int = 1

var _behaviour_state: int = behaviourState.HOVER


enum behaviourState {
	HOVER,
	CHARGE,
	CHARGEBACK
} 


func init(left_hand: bool, spawn_pos: Vector2):
	_passive_position = spawn_pos
	_is_left_hand = left_hand
	
	if !_is_left_hand:
		_strafe_direction = -1
	
	_init_finished = true

func _ready():
	
	timer_to_charge.set_wait_time(_time_to_charge)
	timer_to_chargeback.set_wait_time(_time_to_chargeback)
	
	AI_node.motionless_behaviour()
	_hover_mode()


func _process(delta):
	if Lobby.is_host == true && _init_finished: 
		
		if _behaviour_state == behaviourState.HOVER: 
			print("I am in hover hover mode! :" , entity.id)
			if raycast_player_detection.is_colliding_with_layers(Constants.collisionLayers.PLAYER):
				print("Player detected in hover mode")
				_charge_mode()
			else:
				_hover_movement(delta)
		
		elif _behaviour_state == behaviourState.CHARGE:
			
			if timer_to_charge.is_stopped():
				if raycast_wall_detection.is_colliding_with_layers(Constants.collisionLayers.SOLID):
					_chargeback_mode()
		
		elif _behaviour_state == behaviourState.CHARGEBACK:
			if self.global_position.distance_to(_passive_position) <= 10:
				_hover_mode()

func _hover_movement(delta: float) -> void:
	var up_or_down_start: Vector2
	
	if _is_first_strafe_pos:
		if _is_left_hand:
			up_or_down_start = Vector2(0.0, 0.1)
		else:
			up_or_down_start = -Vector2(0.0, 0.1)
		_is_first_strafe_pos = false
	
	var strafe_center_point = _passive_position + up_or_down_start
	var strafe_dir_normalized = strafe_center_point.direction_to(self.global_position).normalized()
	
	
	var strafe_pos: Vector2  = strafe_center_point + (strafe_dir_normalized.rotated(deg2rad(_strafe_direction * _strafe_speed * delta)) * _strafe_dist)
	self.global_position = strafe_pos


func _hover_mode() -> void:
	_behaviour_state = behaviourState.HOVER


func _charge_mode() -> void:
	_behaviour_state = behaviourState.CHARGE
	timer_to_charge.start()

func _chargeback_mode() -> void:
	_behaviour_state = behaviourState.CHARGEBACK
	AI_node.stop_moving()
	timer_to_chargeback.start()


func _on_TimerToCharge_timeout():
	entity.emit_signal("change_movement_speed", _charge_speed)
	AI_node.set_target_walking_path(self.global_position + Vector2(0, 1000))


func _on_TimerToChargeback_timeout():	
	entity.emit_signal("change_movement_speed", _chargeback_speed)
	AI_node.set_target_walking_path(_passive_position)
