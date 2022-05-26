extends Node2D

export(float) var _charge_speed: float = 200.0 


onready var sprite_node = $Sprite
onready var AI_node = $AI
onready var damage_node = $Damage

onready var ray_cast_player_detector = $RayCastContainerPlayerDetection
onready var ray_cast_wall_detection = $RayCastContainerWallDetection
onready var charge_collision_node = $ChargeCollision

onready var charge_buildup_timer = $ChargeBuildupTimer
onready var aimless_walking_timer = $AimlessWalkingTimer


var entity: Entity
var _targeted_player = null
var _is_animal = true
var _is_looking_at_player: bool
var _behaviour_state = behaviourState.AIMLESS_WALKING
var _direction_faced: String


enum behaviourState {
	AIMLESS_WALKING,
	CHARGE_ATTACK
} 


func _ready():
	_behaviour_state = behaviourState.AIMLESS_WALKING
	entity.emit_signal("change_movement_speed", 60.0)
	damage_node.init(entity.id, entity.team)
	damage_node.deactivate_damage()
	AI_node.motionless_behaviour()
	_new_aimless_walking_path()
	AI_node.custom_behaviour()


func _physics_process(delta):
	var detected_walls: Array = _detect_walls()
	if _behaviour_state == behaviourState.AIMLESS_WALKING:
		if _detect_player().size() != 0:
			_charge_at_player()
			print("detected a player I wanna charge")
		elif detected_walls.size() != 0:
			for detection in detected_walls:
				if detection["ray_cast_name"] == _direction_faced:
					_new_aimless_walking_path()
					break
		elif aimless_walking_timer.is_paused():
			print("For some reason walking timer paused so I started it again")
			aimless_walking_timer.start()
	elif _behaviour_state == behaviourState.CHARGE_ATTACK:
		if detected_walls.size() != 0:
			_detected_collision_in_charge(detected_walls) 


func _detect_walls() -> Array:
	return ray_cast_wall_detection.is_colliding_with_layers([Constants.collisionLayers.SOLID])


func _detect_player() -> Array:
	return ray_cast_player_detector.is_colliding_with_layers([Constants.collisionLayers.PLAYER])


func _detected_collision_in_charge(detected_walls) -> void:
	if _behaviour_state == behaviourState.CHARGE_ATTACK:
		for direction in detected_walls:
			if direction["ray_cast_name"] == _direction_faced:
				entity.emit_signal("change_movement_speed", 60.0)
				AI_node.stop_moving()
				yield(get_tree().create_timer(0.20), "timeout")
				_behaviour_state = behaviourState.AIMLESS_WALKING
				damage_node.deactivate_damage()


func _charge_at_player() -> void:
	AI_node.stop_moving()
	entity.emit_signal("change_movement_speed", _charge_speed)
	_behaviour_state = behaviourState.CHARGE_ATTACK
	charge_buildup_timer.start()


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
					sprite_node.set_frame(0)
					ray_cast_player_detector.rotation_degrees = 180
					break
			1:
				if !_direction_faced == "Down":
					_direction_faced = "Down"
					target_pos = self.global_position + Vector2(0, random_distance)
					sprite_node.set_frame(1)
					ray_cast_player_detector.rotation_degrees = 0
					break
			2:
				if !_direction_faced == "Left":
					_direction_faced = "Left"
					target_pos = self.global_position + Vector2(-random_distance, 0)
					sprite_node.set_frame(2)
					ray_cast_player_detector.rotation_degrees = 90
					break
			3:
				if !_direction_faced == "Right":
					_direction_faced = "Right"
					target_pos = self.global_position + Vector2(random_distance, 0)
					sprite_node.set_frame(3)
					ray_cast_player_detector.rotation_degrees = 270
					break
	
	AI_node.set_target_walking_path(target_pos)
	aimless_walking_timer.start()


func _on_ChargeBuildupTimer_timeout():
	damage_node.activate_damage()
	match(sprite_node.get_frame()):
		0:
			AI_node.set_target_walking_path(self.global_position + Vector2(0, -1000))
		1:
			AI_node.set_target_walking_path(self.global_position + Vector2(0, 1000))
		2:
			AI_node.set_target_walking_path(self.global_position + Vector2(-1000, 0))
		3:
			AI_node.set_target_walking_path(self.global_position + Vector2(1000, 0))


func _on_AimlessWalkingTimer_timeout():
	if _behaviour_state == behaviourState.AIMLESS_WALKING:
		_new_aimless_walking_path()

