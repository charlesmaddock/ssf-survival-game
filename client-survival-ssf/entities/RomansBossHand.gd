extends Node2D


export var passive_moving_distance: float = 25
export var entity_scale: float = 0.7

onready var AI_node: Node2D = self.get_node("AI")
onready var health_node: Node2D = self.get_node("Health")
onready var movemen_node: Node2D = self.get_node("Movement")
onready var raycast_player_detection: Node2D = self.get_node("RayCastContainer")


var entity: Entity
var _is_animal = true

var original_spawn_pos: Vector2
var _strafe_center_pos: Vector2
var _is_first_strafe_pos: bool = true
var strafe_direction: int = 1

var is_left_hand: bool = true


var _behaviour_state = behaviourState.HOVER


enum behaviourState {
	HOVER,
	FORWARD_CHARGE
} 

func init(left_hand: bool, spawn_pos: Vector2):
	is_left_hand = left_hand
	original_spawn_pos = spawn_pos


func _ready():
	
	if self.get_name() == "LeftRomansBossHand":
		self.set_scale(Vector2(entity_scale, entity_scale))
	elif self.get_name() == "RightRomansBossHand":
		self.set_scale(Vector2(-entity_scale, entity_scale))
		
	AI_node.motionless_behaviour()
	_hovering_mode()


func _process(delta):

	var strafe_center_point = original_spawn_pos
		
	var strafe_dir_normalized = strafe_center_point.direction_to(self.global_position)
	if _is_first_strafe_pos:
		_is_first_strafe_position = false
	
	var strafe_pos: Vector2  = strafe_center_point + (strafe_dir_normalized.rotated(deg2rad(_strafe_direction * 40)) * _strafe_dist)
	return strafe_pos


func _hovering_mode() -> void:
	_behaviour_state = behaviourState.PASSIVE_MODE
	AI_node.strafe_custom_behaviour(passive_moving_distance, self.global_position)

