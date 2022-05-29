extends Node2D


enum behaviour {
	SEARCH,
	HUNT
}


export(NodePath) var movement_component_path
export(int) var _strafe_dist = 80
export(float) var _follow_player_dist = 0

onready var Movement: Node2D = get_node(movement_component_path)
onready var nav: Navigation2D = Util.get_game_node().get_node("Navigation2D")
onready var gameNode = Util.get_game_node()
onready var base = Util.get_entity("base")
onready var parent_entity: Node2D = self.get_parent()


var move_path = []
var attack_path = []
var threshold = 16
var _strafe_direction: int = 1
var _is_first_strafe_position: bool = true
var _custom_strafe_center_point: Vector2

var room_point: Node2D = null
var unchecked_room_points: Array = []

var players_in_view: Array = []
var current_movement_behaviour = movementBehaviour.MOTIONLESS

enum movementBehaviour {
	FOLLOW_PLAYER,
	STRAFE,
	CUSTOM_STRAFE,
	MOTIONLESS,
	CUSTOM
}


func _physics_process(delta):
	if Lobby.is_host == true:
		if move_path.size() > 0:
			move_to_target()


func strafe_player_behaviour(strafe_dist: int) -> void:
	current_movement_behaviour = movementBehaviour.STRAFE
	_strafe_dist = strafe_dist


func strafe_custom_behaviour(strafe_dist: int, custom_point: Vector2) -> void:
	#Need to add a small difference to custom_point for special case of strafe on current global_pos, Vector will otherwise be 0
	_custom_strafe_center_point = custom_point  + Vector2(0.1, 0.1)
	_strafe_dist = strafe_dist
	current_movement_behaviour = movementBehaviour.CUSTOM_STRAFE
	

func follow_player_behaviour(follow_player_dist) -> void:
	current_movement_behaviour = movementBehaviour.FOLLOW_PLAYER
	_follow_player_dist = follow_player_dist


func motionless_behaviour() -> void:
	current_movement_behaviour = movementBehaviour.MOTIONLESS


func custom_behaviour() -> void:
	current_movement_behaviour = movementBehaviour.CUSTOM


func stop_moving() -> void:
	move_path = []
	Movement.set_velocity(Vector2.ZERO)


func move_to_target():
	if global_position.distance_to(move_path[0]) < threshold:
		move_path.remove(0)
	else:
		var direction = global_position.direction_to(move_path[0])
		Movement.set_velocity(direction)


func set_target_walking_path(target_pos):
	move_path = nav.get_simple_path(global_position, target_pos, false)


func set_target_attack_path(target_pos):
	attack_path = nav.get_simple_path(global_position, target_pos, false)


func reset_first_strafe_pos() -> void:
	_is_first_strafe_position = true


func _on_Damage_body_entered(body):
	if Util.is_player(body):
		body.emit_signal("take_damage", 30, global_position.direction_to(body.global_position))


func _get_strafe_position() -> Vector2:
	var strafe_center_point: Vector2 
	if current_movement_behaviour == movementBehaviour.STRAFE:
		if get_closest_player() != null:
			strafe_center_point = get_closest_player().global_position
			
		else:
			return parent_entity.global_position
			
	elif current_movement_behaviour == movementBehaviour.CUSTOM_STRAFE:
		strafe_center_point = _custom_strafe_center_point
		
	var strafe_dir_normalized = strafe_center_point.direction_to(self.global_position)
	if _is_first_strafe_position:
		randomize()
		var nums = [-1, 1] 
		_strafe_direction = nums[randi() % nums.size()]
		var rand_rotation: float = deg2rad(rand_range(90, 270))
		strafe_dir_normalized.rotated(rand_rotation)
		_is_first_strafe_position = false
	
	var strafe_pos: Vector2  = strafe_center_point + (strafe_dir_normalized.rotated(deg2rad(_strafe_direction * 40)) * _strafe_dist)
	return strafe_pos


"""
func _get_follow_position() -> Vector2:
	var follow_dir_normalized = get_closest_player().global_position.direction_to(self.global_position)
	var follow_dir: Vector2 = get_closest_player().global_position + strafe_dir_normalized * _strafe_dist
	return follow_dir
"""


func get_closest_player() -> Object:
	var parent_position = parent_entity.global_position
	var living_players: Array = Util.get_living_players()
	var closest_player
	var distance_to_closest_player = 99999
	for player in living_players:
		var distance_between_positions = parent_position.distance_to(player.global_position)
		if distance_between_positions < distance_to_closest_player:
			distance_to_closest_player = distance_between_positions
			closest_player = player
	return closest_player


func _on_MovementActionTimer_timeout():
	if current_movement_behaviour != movementBehaviour.MOTIONLESS:
		if current_movement_behaviour == movementBehaviour.FOLLOW_PLAYER:
			_is_first_strafe_position = true
			set_target_walking_path(parent_entity.direction_to(get_closest_player().global_position))
		elif current_movement_behaviour == movementBehaviour.STRAFE:
			set_target_walking_path(_get_strafe_position())
		elif current_movement_behaviour == movementBehaviour.CUSTOM_STRAFE:
			set_target_walking_path(_get_strafe_position())
		elif current_movement_behaviour == movementBehaviour.CUSTOM:
			_is_first_strafe_position = true
			pass
	elif current_movement_behaviour == movementBehaviour.MOTIONLESS:
		_is_first_strafe_position = true
		stop_moving()
