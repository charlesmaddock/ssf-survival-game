extends Node2D


export var _strafe_dist: float = 4
export var _hover_speed: float = 150

onready var AI_node: Node2D = self.get_node("AI")
onready var health_node: Node2D = self.get_node("Health")
onready var movement_node: Node2D = self.get_node("Movement")


var entity: Entity
var boss_node: Node2D
var _is_animal = true
var _init_finished = false

var _strafe_direction: int = 1
var _distance_from_head: float
var _last_hover_dir_norm: Vector2 = Vector2.ZERO


var _behaviour_state: int = behaviourStates.HOVER_AROUND_HEAD

signal slapping_done()


enum behaviourStates {
	HOVER_AROUND_HEAD,
	SLAP,
} 


func init(distance_from_head: float, boss_node_id: String):
	boss_node = Util.get_entity(boss_node_id)
	_distance_from_head = distance_from_head
	print(_distance_from_head, "This is my distance from head")
	_last_hover_dir_norm = boss_node.global_position.direction_to(self.global_position)
	
	_init_finished = true

func _ready():
	_behaviour_state == behaviourStates.HOVER_AROUND_HEAD


func _process(delta) -> void:
	if _init_finished:
		if _behaviour_state == behaviourStates.HOVER_AROUND_HEAD:
			_last_hover_dir_norm = _last_hover_dir_norm.rotated(deg2rad(_hover_speed * delta * _strafe_direction))
			self.global_position = boss_node.global_position + _distance_from_head * _last_hover_dir_norm
			print("This is my own glob-pos: ", self.global_position, " and this is my parents pos: ", boss_node.global_position)


