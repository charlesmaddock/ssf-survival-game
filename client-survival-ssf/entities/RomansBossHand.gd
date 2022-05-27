extends Node2D


export var passive_moving_distance: float = 25


onready var AI_node: Node2D = self.get_node("AI")
onready var health_node: Node2D = self.get_node("Health")
onready var movemen_node: Node2D = self.get_node("Movement")
onready var raycast_player_detection: Node2D = self.get_node("RayCastContainer")


var entity: Entity
var _strafe_center_pos

func _ready():
	AI_node.motionless_behaviour()
	_passive_moving()
	pass 


func _passive_moving() -> void:
	AI_node.strafe_custom_behaviour(passive_moving_distance, self.global_position)
	pass
