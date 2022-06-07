extends Node2D

export(float) var _charge_speed: float = 150.0 


onready var sprite_node = $Sprite
onready var AI_node = $AI
onready var damage_node = $Damage
onready var movement_node = $Movement

onready var player_detector = $DetectPlayerArea
onready var ray_cast_wall_detection = $RayCastContainerWallDetection

onready var charge_buildup_timer = $ChargeBuildupTimer
onready var aimless_walking_timer = $AimlessWalkingTimer


var entity: Entity
var _players_in_view: Array
var _charge_at_player: Vector2
var _charge_dir: Vector2

var _is_animal = true
var _behaviour_state = behaviourState.AIMLESS_WALKING
var _direction_faced: String
var _prev_pos: Vector2


enum behaviourState {
	AIMLESS_WALKING,
	BUILD_UP_CHARGE,
	CHARGE_ATTACK,
	RAN_INTO_WALL
} 


func _ready():
	_behaviour_state = behaviourState.AIMLESS_WALKING
	entity.emit_signal("change_movement_speed", 60.0)
	damage_node.deactivate_damage()
	AI_node.motionless_behaviour()
	_new_aimless_walking_path()
	AI_node.custom_behaviour()


func _physics_process(delta):
	var move_dir: Vector2 = _prev_pos.direction_to(global_position).normalized()
	var rounded_move_dir: Vector2 = Vector2(round(move_dir.x), round(move_dir.y))
	
	if rounded_move_dir.y == -1:
		_direction_faced = "Up"
		sprite_node.set_frame(0)
		player_detector.rotation_degrees = 180
	if rounded_move_dir.y == 1:
		_direction_faced = "Down"
		sprite_node.set_frame(1)
		player_detector.rotation_degrees = 0
	if rounded_move_dir.x == -1:
		_direction_faced = "Left"
		sprite_node.set_frame(2)
		player_detector.rotation_degrees = 90
	if rounded_move_dir.x == 1:
		_direction_faced = "Right"
		sprite_node.set_frame(3)
		player_detector.rotation_degrees = 270
	
	var detected_walls: Array = _detect_walls()
	if _behaviour_state == behaviourState.AIMLESS_WALKING:
		if _players_in_view.size() != 0:
			_charge_at_player(_players_in_view[0])
		elif detected_walls.size() != 0:
			for detection in detected_walls:
				if detection["ray_cast_name"] == _direction_faced:
					_new_aimless_walking_path()
					break
		
		if aimless_walking_timer.is_paused():
			aimless_walking_timer.start()
		
	elif _behaviour_state == behaviourState.CHARGE_ATTACK:
		if _players_in_view.size() > 0:
			var dir_to_player = global_position.direction_to(_players_in_view[0].global_position)
			_charge_dir = _charge_dir.linear_interpolate(dir_to_player, delta)
		
		movement_node.set_velocity(_charge_dir)
		
		if detected_walls.size() != 0:
			_detected_collision_in_charge(detected_walls) 
	
	_prev_pos = global_position


func _detect_walls() -> Array:
	var wall_data = ray_cast_wall_detection.is_colliding_with_layers([Constants.collisionLayers.SOLID])
	#if wall_data.size() != 0:
	#	print("walls: ", wall_data)
	return wall_data


func _detected_collision_in_charge(detected_walls) -> void:
	if _behaviour_state == behaviourState.CHARGE_ATTACK:
		for direction in detected_walls:
			if direction["ray_cast_name"] == _direction_faced:
				_behaviour_state = behaviourState.RAN_INTO_WALL
				entity.emit_signal("change_movement_speed", 60.0)
				AI_node.stop_moving()
				yield(get_tree().create_timer(0.5), "timeout")
				_behaviour_state = behaviourState.AIMLESS_WALKING
				damage_node.deactivate_damage()


func _new_aimless_walking_path() -> void:
	randomize()
	var random_distance = rand_range(100, 600)
	var target_pos = Vector2.ZERO
	
	while true:
		var random_direction = randi() % 4
		match random_direction:
			0:
				if !_direction_faced == "Up":
					_direction_faced = "Up"
					target_pos = self.global_position + Vector2(0, -random_distance)
					break
			1:
				if !_direction_faced == "Down":
					_direction_faced = "Down"
					target_pos = self.global_position + Vector2(0, random_distance)
					break
			2:
				if !_direction_faced == "Left":
					_direction_faced = "Left"
					target_pos = self.global_position + Vector2(-random_distance, 0)
					break
			3:
				if !_direction_faced == "Right":
					_direction_faced = "Right"
					target_pos = self.global_position + Vector2(random_distance, 0)
					break
	
	AI_node.set_target_walking_path(target_pos)
	aimless_walking_timer.start()


func _charge_at_player(player) -> void:
	AI_node.stop_moving()
	_behaviour_state = behaviourState.BUILD_UP_CHARGE
	get_node("BullAnimator").play("jump")
	_charge_dir = global_position.direction_to(player.global_position)
	charge_buildup_timer.start()


func _on_ChargeBuildupTimer_timeout():
	damage_node.activate_damage()
	_behaviour_state = behaviourState.CHARGE_ATTACK
	entity.emit_signal("change_movement_speed", _charge_speed)


func _on_AimlessWalkingTimer_timeout():
	if _behaviour_state == behaviourState.AIMLESS_WALKING:
		_new_aimless_walking_path()


func _on_DetectPlayerArea_body_entered(body):
	_players_in_view.append(body)


func _on_DetectPlayerArea_body_exited(body):
	_players_in_view.erase(body)
